---
description: V-Model-aware planning bridge — wraps spec-kit-core /speckit.plan to synthesise a canonical plan.md from the V-Model artifact set with additive enrichment, pinned-schema validation, and a structured run summary.
handoffs:
  - label: Break Into Tasks
    agent: speckit.v-model.tasks
    prompt: Break the V-Model-enriched plan into TDD-ordered tasks
    send: true
  - label: Implement Plan
    agent: speckit.v-model.implement
    prompt: Implement the V-Model-enriched plan
scripts:
  sh: scripts/bash/setup-plan.sh --json
  ps: scripts/powershell/setup-plan.ps1 -Json
---

<!-- Implements: REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-027, REQ-IF-001, REQ-NF-005, SYS-001, SYS-005, SYS-010, SYS-012, ARCH-001, ARCH-002, ARCH-008, ARCH-013, ARCH-014, ARCH-016, MOD-001, MOD-002, MOD-011, MOD-021, D-001, D-010 -->

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Synthesise a **spec-kit-core canonical `plan.md`** (and its sibling artifacts: `data-model.md`, `contracts/`, `quickstart.md`, `research.md`) from the V-Model artifact set, while embedding V-Model traceability metadata as **purely additive** HTML-comment enrichment. This command is the left-hand bridge between V-Model engineering rigour and spec-kit-core's downstream toolchain — its output is byte-for-byte schema-compatible with what `/speckit.plan` would have produced, so unmodified `/speckit.tasks` and `/speckit.implement` can consume it (REQ-002, REQ-IF-001, ARCH-001, ARCH-002, MOD-001, MOD-002).

This command is a **superset of `/speckit.plan`**, not a replacement. The canonical body is generated faithfully per spec-kit-core's pinned v0.7.0 schema; V-Model context (REQ→SYS→ARCH→MOD chains, hazard previews, derived-requirement flags) is layered on top inside HTML comments and optional end-of-document Markdown sections — never inside core-parsed structures (REQ-007, REQ-NF-003 → ARCH-008, MOD-011). The paradigm is Markdown prompt + shell + YAML; no Python is introduced (D-001).

The command is **graceful**: when optional V-Model artefacts (e.g. `hazard-analysis.md`, `system-test.md`) are absent it switches to a reduced-enrichment mode, names every skipped artefact in the structured summary, and exits 0 (REQ-008, REQ-NF-005, ARCH-014). On every exit path — success or failure — it emits a machine-readable summary block (REQ-027, ARCH-016, MOD-021, SYS-012). Quality of the prompt-section output is verified by the `tests/evals/` structural eval suite (D-010).

**Non-goals**: This command does NOT execute, mutate any V-Model artefact, generate test code, run hazard analysis, or build the traceability matrix. It is purely a synthesis-and-enrichment step.

## Execution Steps

### 1. Setup

Run `{SCRIPT}` from the repository root and parse the JSON output. Required keys:

- `FEATURE_SPEC` — path to `spec.md`
- `IMPL_PLAN` — target path for `plan.md`
- `SPECS_DIR` — path to `specs/<feature>/`
- `BRANCH` — current branch
- `VMODEL_DIR` — path to `specs/<feature>/v-model/` (may be absent on greenfield features)

For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

Read `.specify/memory/constitution.md` and the spec-kit-core plan template (already copied into `IMPL_PLAN` by the setup script).

If `VMODEL_DIR` exists, read **every** V-Model artefact present in it natively as Markdown — no parser is shipped (ARCH-019 deferred). Record the read set as `inputs_read[]` and the missing optional set as `artifacts_skipped[]` for the §Structured Summary (MOD-001, REQ-001, REQ-IF-001).

**Refuse to proceed** if `requirements.md` is absent: emit §Structured Summary with `fatal_errors: ["requirements.md required"]`, exit 1.

### 2. Run the spec-kit-core /speckit.plan workflow

Faithfully execute the core procedure documented in `.github/agents/speckit.plan.agent.md` (Phase 0 → Phase 1):

1. Fill **Technical Context** from `requirements.md` (functional, NF, interface, constraint requirements) and `system-design.md` if present. Mark unresolved items as `NEEDS CLARIFICATION`.
2. Fill **Constitution Check** from `.specify/memory/constitution.md`.
3. **Phase 0**: emit `research.md` capturing every `[DERIVED REQUIREMENT]` / `[DERIVED MODULE]` flag found in `system-design.md`, `architecture-design.md`, `module-design.md` — each linked back to the artefact that introduced it (REQ-006).
4. **Phase 1**:
   - `data-model.md` ← Data Design view of `system-design.md` (REQ-003).
   - `contracts/<name>.md` ← Interface view of `architecture-design.md`, one file per ARCH module that owns an external contract (REQ-004).
   - `quickstart.md` ← top critical BDD scenarios from `acceptance-plan.md` (REQ-005).
   - Run `.specify/scripts/bash/update-agent-context.sh copilot` per the core flow.
5. Re-evaluate the Constitution Check post-design.

**Do NOT mutate the canonical structure.** The V-Model overlay is purely additive (REQ-007, REQ-NF-003, D-010).

### 3. Apply V-Model additive enrichment (per ARCH-008, MOD-011)

Inject a single `<!-- v-model:traces ... -->` HTML comment block immediately after the H1 title of `plan.md`, listing the parent identifiers consolidated from the read artefact set:

```
<!-- v-model:traces
  requirements: [REQ-001, REQ-002, ...]
  system:       [SYS-001, ...]
  architecture: [ARCH-001, ...]
  modules:      [MOD-001, ...]
  hazards:      [HAZ-001, ...]   # omit key if hazard-analysis.md absent
  version:      v0.7.0
-->
```

Optionally append a `## V-Model Trace Summary` Markdown section at the **end** of `plan.md` only — never between canonical sections. Apply the same comment-only enrichment to `data-model.md`, each `contracts/<name>.md`, `quickstart.md`, and `research.md` where useful (REQ-007, REQ-IF-001).

**Crucial constraint**: outside the HTML-comment regions and any explicitly trailing Markdown section, every byte must match what spec-kit-core would have produced. The post-enrichment document MUST still pass schema validation (Step 4). This is the additive-only invariant (ARCH-008, MOD-011, hazards HAZ-002, HAZ-011).

If a future synthesis pass needs to splice region-managed content into a sibling source file, use `scripts/bash/splice-managed-regions.sh` (caller is responsible for the `mktemp` + `mv` atomic-write idiom — D-016, SYS-015). The plan-time enrichment in this step is single-write so the splicer is not invoked here.

### 4. Schema validation (per ARCH-013, MOD-017)

For each candidate output, write via the inline atomic-rename idiom (ARCH-002, MOD-002, REQ-NF-005):

```bash
tmp=$(mktemp -p "$(dirname "$f")")
printf '%s' "$content" > "$tmp"
mv "$tmp" "$f"
```

Then validate the canonical `plan.md`:

```bash
bash scripts/bash/validate-core-schema.sh <plan.md> --plan
```

Expected stdout terminates with `SCHEMA: PASS (pinned_version=v0.7.0)` and exit code 0. On any other outcome:

1. Delete the candidate file (atomic-rename means the prior content, if any, is intact).
2. Append the validator's stdout lines to `fatal_errors[]` of the §Structured Summary.
3. Exit 1 — do **not** proceed to handoff.

(REQ-002, REQ-IF-001, REQ-NF-005, ARCH-013, MOD-017.)

### 5. Reduced-enrichment fallback (per ARCH-014)

For each **optional** V-Model artefact missing from `VMODEL_DIR` (`hazard-analysis.md`, `system-test.md`, `integration-test.md`, `unit-test.md`, `acceptance-plan.md`, `module-design.md`, `architecture-design.md`, `traceability-matrix.md`):

1. Skip the corresponding canonical output if its sole upstream input is absent (e.g. `contracts/` if `architecture-design.md` is missing) and append the file name to `artifacts_skipped[]` (REQ-008, REQ-NF-005).
2. Inside the `<!-- v-model:traces -->` block of `plan.md`, append a single explanatory line: `<!-- v-model: enrichment reduced — missing <artefact>; behaving as plain /speckit.plan for the affected sections -->`. **Never silently degrade.**
3. Continue the run; reduced-enrichment is a successful, observable outcome — exit 0 with `warnings[]` populated, not `fatal_errors[]` (REQ-008, ARCH-014, REQ-NF-005).

### 6. Structured Summary (per ARCH-016, MOD-021, SYS-012)

On every exit path (success **and** failure), flush stdout and emit:

```
--- v-model run summary ---
inputs_read:
  - <path1>
  - <path2>
outputs_produced:
  - <path>
artifacts_skipped:
  - <name>
warnings:
  - <text>
fatal_errors:
  - <text>          # omit key entirely on success
schema_validation: PASS | FAIL
enrichment: full | reduced
branch: <name>
plan: <path>
--- end summary ---
```

This block is the contract for downstream consumers — CI parsers, the `v-model.tasks` bridge, audit tooling (REQ-027, REQ-IF-004, HAZ-025 mitigation).

### 7. Handoffs

On success, recommend `/speckit.v-model.tasks` to break the enriched plan into TDD-ordered tasks (REQ-009, REQ-010 — downstream tasks bridge consumes this command's output unchanged). The handoff buttons in frontmatter expose both the tasks and implement next steps.

## Quality criteria

Before declaring success, self-check **every** invariant below; any violation forces re-emission with the offending step's `fatal_errors[]` populated:

- `bash scripts/bash/validate-core-schema.sh <plan.md> --plan` exits 0 (REQ-002, REQ-IF-001, ARCH-013).
- Every canonical heading required by the v0.7.0 plan template is present in canonical order (no deletions, no reorders) (ARCH-002, MOD-002).
- Outside HTML-comment regions and the optional trailing `## V-Model Trace Summary`, no bytes differ from a plain `/speckit.plan` synthesis (REQ-007, REQ-NF-003, ARCH-008, MOD-011).
- Every emitted file was written via `mktemp` + `mv` — no partial overwrite is observable (REQ-NF-005, MOD-002, D-016, HAZ-014).
- `inputs_read[]` lists every V-Model artefact actually read; `artifacts_skipped[]` lists every optional artefact that was missing (REQ-001, REQ-008).
- `fatal_errors[]` is empty on success and present-with-content on every failure path; the summary block is flushed before `exit` (REQ-027, MOD-021, HAZ-025).
- No fabricated V-Model identifiers appear anywhere in the enrichment — every cited ID is grep-resolvable in the V-Model artefact set (D-010).
- The H1 title line is unmodified; the `<!-- v-model:traces -->` block sits **immediately after** it (MOD-011).

## Failure modes & recovery

| Failure | Detection | User-facing recovery |
|---|---|---|
| `requirements.md` absent | Step 1 read | `fatal_errors: ["requirements.md required"]`, exit 1; user runs `/speckit.v-model.requirements` first (REQ-001). |
| Optional artefact missing | Step 1 read | Reduced-enrichment fallback; warning logged; exit 0 (REQ-008, REQ-NF-005, ARCH-014). |
| Schema validator non-zero | Step 4 | Delete candidate; emit validator stdout into `fatal_errors[]`; exit 1; user inspects diff against `templates/plan-template.md` (REQ-002, ARCH-013, HAZ-002). |
| Enrichment leaks into canonical section | Step 4 re-run after Step 3 | Same as schema-validator failure; the post-enrichment validation re-check is the gate (MOD-011, HAZ-011). |
| Atomic-rename failure (disk full, permissions) | `mv` non-zero | `fatal_errors: ["write failed: <path>"]`, exit 1; no partial file remains (REQ-NF-005, MOD-002, HAZ-014, HAZ-025). |
| Splicer error on a sibling source file | `splice-managed-regions.sh` non-zero | Original file untouched (script writes to stdout only); propagate stderr into `fatal_errors[]`, exit 1 (D-005, D-015, D-016). |
| Structured summary truncated | Step 6 flush failure | Last-resort: emit a single `--- v-model run summary --- fatal_errors: [summary truncated] --- end summary ---` line; exit 1 (HAZ-025, MOD-021). |

## Operating Constraints

### Additive-only enrichment

V-Model overlay is confined to `<!-- v-model: ... -->` HTML comments and the optional trailing `## V-Model Trace Summary` section. Canonical headings, ordering, and prose are immutable (REQ-007, REQ-NF-003, ARCH-008, MOD-011).

### Round-trip compatibility

The output `plan.md` must be consumable by **unmodified** `/speckit.tasks` and `/speckit.implement`. The schema validator (ARCH-013) is the local gate; the integration test in `quickstart.md` Walkthrough 1 is the end-to-end gate (REQ-IF-001, REQ-009, REQ-010).

### Graceful degradation

Missing optional artefacts trigger reduced enrichment, **never** a hard failure. The set of skipped artefacts is reported in the structured summary so progressive adoption is observable (REQ-008, REQ-NF-005, ARCH-014, SYS-012).

### Stateless re-runnability

Every run regenerates outputs from the V-Model artefact set; there is no cache. Re-running on an unchanged input set produces structurally identical output (≥95% byte-identity per the idempotency NFR; D-010).
