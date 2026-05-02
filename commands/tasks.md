---
description: V-Model-aware tasks bridge — wraps spec-kit-core /speckit.tasks to synthesise a TDD-ordered, hazard-priority-elevated tasks.md from the V-Model artifact set, with per-HAZ verification tasks, additive enrichment, pinned-schema validation, and a structured run summary.
handoffs:
  - label: Implement Tasks
    agent: speckit.v-model.implement
    prompt: Implement the V-Model-ordered tasks
    send: true
  - label: Re-Plan
    agent: speckit.v-model.plan
    prompt: Re-run V-Model planning to refresh upstream enrichment
scripts:
  sh: .specify/scripts/bash/check-prerequisites.sh --json
  ps: .specify/scripts/powershell/check-prerequisites.ps1 -Json
---

<!-- Implements: REQ-011, REQ-012, REQ-013, REQ-014, REQ-027, REQ-IF-002, SYS-002, SYS-005, SYS-009, SYS-010, SYS-012, ARCH-003, ARCH-008, ARCH-012, ARCH-013, ARCH-014, ARCH-016, MOD-003, MOD-004, MOD-012, MOD-016, MOD-019, MOD-021, HAZ-016, D-001, D-006, D-011 -->

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Synthesise a **spec-kit-core canonical `tasks.md`** from the V-Model artifact set, ordered TDD-style and elevated where hazards demand it. This command is the middle of the three bridge commands: it consumes a (possibly V-Model-enriched) `plan.md` plus the upstream V-Model artefacts and emits a `tasks.md` that is byte-for-byte schema-compatible with what spec-kit-core's `/speckit.tasks` would have produced — so unmodified `/speckit.implement` can consume it (REQ-IF-002, SYS-002, SYS-010, ARCH-003, MOD-003).

The **operative V-Model "shall"** is REQ-011: every user story's tasks are emitted in strict TDD order — write unit tests → implement modules → run unit tests → write integration tests → run integration tests → write system tests → run system tests → write acceptance tests. This sequence is the right-hand side of the V-Model collapsed into linear executable form (REQ-011, MOD-004, D-006). Independent modules carry the canonical `[P]` parallel-execution marker so downstream tooling continues to schedule them concurrently (REQ-013).

The **distinguishing V-Model behaviour** beyond plain `/speckit.tasks` is hazard-driven priority elevation plus per-`HAZ-NNN` verification-task emission: when `hazard-analysis.md` is present, every mitigation task is flagged at higher priority and one dedicated verification task is emitted per HAZ identifier, citing both the HAZ and the verification artefact (UTP / ITP / STP / ATP) that closes the loop (REQ-014, SYS-009, ARCH-012, MOD-016, HAZ-016, D-011). Per-task traceability is encoded as `<!-- traces-to: MOD-NNN → ARCH-NNN → SYS-NNN → REQ-NNN -->` HTML comments — invisible to spec-kit-core parsers, discoverable by V-Model tooling (REQ-012, ARCH-008, MOD-012). The paradigm remains Markdown prompt + shell + YAML; no Python is introduced (D-001).

The command is **graceful**: when `hazard-analysis.md` is absent or upstream `plan.md` lacks V-Model enrichment markers, it switches to reduced-enrichment / Hybrid-path mode (ARCH-014, MOD-019), names the degraded behaviour explicitly, and exits 0. On every exit path it emits a machine-readable structured summary (REQ-027, ARCH-016, MOD-021, SYS-012).

**Non-goals**: this command does NOT execute tasks, mutate any V-Model artefact, run hazard analysis, generate test code, or build the traceability matrix. It is a synthesis-and-enrichment step only.

## Execution Steps

### 1. Setup

Run `{SCRIPT}` from the repository root and parse the JSON output. Required keys: `FEATURE_DIR`, `AVAILABLE_DOCS`, `BRANCH`. The V-Model directory is `FEATURE_DIR/v-model/` (may be absent on greenfield features).

For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

Read `.specify/memory/constitution.md`. Read `FEATURE_DIR/plan.md` (required). Read `FEATURE_DIR/spec.md` for user-story priorities. Read every optional design doc named in `AVAILABLE_DOCS` (`data-model.md`, `contracts/`, `research.md`, `quickstart.md`).

If `FEATURE_DIR/v-model/` exists, read **every** V-Model artefact present natively as Markdown — no parser is shipped. Record the read set as `inputs_read[]` and the missing optional set as `artifacts_skipped[]` for the §Structured Summary (MOD-003, ARCH-014).

**Refuse to proceed** if `plan.md` cannot be parsed at all: emit §Structured Summary with `fatal_errors: ["plan.md unparseable"]`, exit 1 (ARCH-014 fail-closed).

### 2. Run the spec-kit-core /speckit.tasks workflow

Faithfully execute the canonical procedure documented in `.github/agents/speckit.tasks.agent.md` to produce a `tasks.md` skeleton: load plan.md + spec.md, extract tech stack and user stories with priorities, map entities/contracts/scenarios to stories, generate the per-story task lists, build the dependency graph, and emit parallel-execution examples (SYS-010, REQ-IF-002).

**Do NOT mutate the canonical structure.** The V-Model overlay is purely additive (D-001, D-011 layered on the canonical document). The operative additivity contract is ARCH-008 + MOD-012.

### 3. TDD-ordered synthesis (per ARCH-003, MOD-004, D-006, REQ-011)

Within each user story, enforce strict ordering — no exceptions:

1. **Write unit tests** (RED) — one task per unit under test; cite ≥1 `UTP-NNN` / `UTS-NNN-XN`.
2. **Implement modules** (GREEN) — one task per `MOD-NNN` named in `module-design.md`; cite the MOD plus its parent `ARCH-NNN`.
3. **Run unit tests** — gate task; cites the UTP set.
4. **Write integration tests** — cite ≥1 `ITP-NNN` / `ITS-NNN-XN`.
5. **Run integration tests** — gate task.
6. **Write system tests** — cite ≥1 `STP-NNN` / `STS-NNN-XN`.
7. **Run system tests** — gate task.
8. **Write acceptance tests** — cite ≥1 `ATP-NNN` / `SCN-NNN-XN`.

Each task carries the `[P]` marker iff it is parallel-safe (different files, no shared state) per spec-kit-core's convention (REQ-013, REQ-IF-002, SCN-013-A1). Every task MUST cite at least one source ID from the V-Model artefact set (REQ / SYS / ARCH / MOD / UTP / ITP / STP / ATP / SCN / HAZ / D-NNN) — verified by structural eval UTP-011-A.

### 4. Hazard-driven priority elevation + per-HAZ verification task emission (per ARCH-012, MOD-016, HAZ-016, D-011, REQ-014)

If `hazard-analysis.md` is present and parseable:

1. For **every** `HAZ-NNN` row whose Mitigation column names verification by test (UTP / ITP / STP / ATP), emit exactly **one** dedicated verification task whose title begins `Verify mitigation for HAZ-NNN` and that cites both the HAZ and the verification artefact (SCN-014-B1, ATP-014-B).
2. **Elevate priority** of any task whose subject MOD/ARCH appears in a HAZ's Mitigation column — promote it above its peers within the same user story and prefix it with `**[HAZARD-ELEVATED]**` so the elevation is visible in rendered Markdown (SCN-014-A1, ATP-014-A).
3. Each enriched task carries a `<!-- traces-to: MOD-NNN → ARCH-NNN → SYS-NNN → REQ-NNN, HAZ-NNN -->` comment per ARCH-008 + MOD-012 (REQ-012, SCN-012-A1).

If `hazard-analysis.md` is **malformed** (cannot be parsed into the row schema): abort fail-closed with `fatal_errors: ["hazard-analysis.md malformed"]`, exit 1 — **never** silently emit an unelevated task list (HAZ-016 is the in-force risk; D-011 mandates this behaviour).

### 5. Apply V-Model additive enrichment (per ARCH-008, MOD-012, MOD-019)

Inject a single `<!-- v-model:traces ... -->` HTML comment block immediately after the H1 title of `tasks.md`, listing the parent identifiers consolidated from the read artefact set (requirements, system, architecture, modules, hazards, version: v0.7.0).

For per-task traceability, append the `<!-- traces-to: ... -->` comment to the **same line** as each task entry, **after** any `[P]` marker, so the canonical task-line grammar is preserved (REQ-012, ARCH-008, MOD-012).

**Crucial constraint**: outside the HTML-comment regions and any explicitly trailing `## V-Model Trace Summary` Markdown section, every byte must match what spec-kit-core `/speckit.tasks` would have produced. This is the additive-only invariant (REQ-NF-003 conceptually; ARCH-008, MOD-012; mitigates HAZ-002, HAZ-011 enrichment-shape-drift).

### 6. Schema validation (per ARCH-013)

Write `tasks.md` via the inline atomic-rename idiom:

```bash
tmp=$(mktemp -p "$(dirname "$f")")
printf '%s' "$content" > "$tmp"
mv "$tmp" "$f"
```

Then validate against the pinned v0.7.0 schema:

```bash
bash scripts/bash/validate-core-schema.sh "$FEATURE_DIR/tasks.md" --tasks
```

Expected stdout terminates with `SCHEMA: PASS (pinned_version=v0.7.0)` and exit code 0. On any other outcome:

1. Delete the candidate file (atomic-rename means the prior content, if any, remains intact).
2. Append the validator's stdout lines to `fatal_errors[]` of the §Structured Summary.
3. Exit 1 — do **not** proceed to handoff.

(REQ-IF-002, SYS-010, ARCH-013.)

### 7. Reduced-enrichment / Hybrid Path fallback (per ARCH-014, MOD-019)

The Hybrid path detector classifies the upstream `plan.md`:

- **Full path**: V-Model enrichment markers (`<!-- v-model:traces ... -->`) present → consume them as-is and emit complete per-task `<!-- traces-to: -->` comments derived from those markers.
- **Hybrid path**: enrichment markers absent (e.g. `plan.md` came from spec-kit-core `/speckit.plan` rather than `/speckit.v-model.plan`) → derive traceability directly from the V-Model artefact set if present; otherwise emit the canonical task list with no per-task `traces-to` comments and document the degradation explicitly inside `<!-- v-model:traces -->`:

  ```
  <!-- v-model: enrichment reduced — upstream plan.md lacks v-model markers; hybrid path engaged -->
  ```

If `hazard-analysis.md` is **missing or empty** (distinct from malformed; see Step 4): skip Step 4 entirely, proceed without elevation, and document explicitly:

```
<!-- v-model: hazard-driven elevation skipped — hazard-analysis.md missing/empty -->
```

Reduced-enrichment is a successful, observable outcome — exit 0 with `warnings[]` populated, not `fatal_errors[]`. **Never silently degrade** (ARCH-014, MOD-019).

### 8. Structured Summary (per ARCH-016, MOD-021, SYS-012, REQ-027, REQ-IF-004)

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
enrichment: full | reduced (<reason>)
tasks_emitted: <N>
hazard_elevated: <K>
hazard_verification_tasks: <H>
branch: <name>
tasks: <path>
--- end summary ---
```

This block is the contract for downstream consumers — CI parsers, the `v-model.implement` bridge, audit tooling. Truncation is itself a hazard (HAZ-025 mitigation).

### 9. Handoffs

On success, recommend `/speckit.v-model.implement` to execute the TDD-ordered task list. The frontmatter's secondary handoff exposes a re-plan path when upstream enrichment must be refreshed.

## Quality criteria

Self-check **every** invariant below; any violation forces re-emission with the offending step's `fatal_errors[]` populated:

- `bash scripts/bash/validate-core-schema.sh <tasks.md> --tasks` exits 0 with `SCHEMA: PASS (pinned_version=v0.7.0)` (REQ-IF-002, ARCH-013).
- Every user story's task block is in strict TDD order per Step 3 — verified by structural eval UTP-011-A (REQ-011, MOD-004, D-006).
- `[P]` parallel marker appears on every task that is genuinely parallel-safe and on no task that is not (REQ-013, SCN-013-A1).
- Every task carries at least one `<!-- traces-to: -->` HTML comment naming ≥1 V-Model ID; no fabricated identifiers — every cited ID is grep-resolvable in `FEATURE_DIR/v-model/` or `research.md` (REQ-012, ARCH-008, MOD-012, SCN-012-A1).
- When `hazard-analysis.md` is present and parseable, exactly one `Verify mitigation for HAZ-NNN` task exists per HAZ row whose mitigation is verification-by-test (REQ-014, SCN-014-B1, ATP-014-B, MOD-016).
- When `hazard-analysis.md` is present and parseable, every task subject named in a HAZ Mitigation column carries the `**[HAZARD-ELEVATED]**` prefix (SCN-014-A1, ATP-014-A).
- Outside `<!-- v-model: ... -->` regions and the optional trailing `## V-Model Trace Summary`, no bytes differ from a plain `/speckit.tasks` synthesis — additive-only invariant (ARCH-008, MOD-012).
- Every emitted file was written via `mktemp` + `mv`; no partial overwrite is observable.
- `inputs_read[]` lists every artefact actually read; `artifacts_skipped[]` lists every optional artefact that was missing; `fatal_errors[]` is empty on success and present-with-content on every failure path; the summary block is flushed before `exit` (REQ-027, REQ-IF-004, MOD-021).

## Failure modes & recovery

| Failure | Detection | User-facing recovery |
|---|---|---|
| `plan.md` unparseable | Step 1 read | `fatal_errors: ["plan.md unparseable"]`, exit 1; user runs `/speckit.v-model.plan` first (ARCH-014 fail-closed). |
| Optional V-Model artefact missing | Step 1 read | Reduced-enrichment fallback (Step 7); warning logged; exit 0 (ARCH-014, MOD-019). |
| `hazard-analysis.md` malformed | Step 4 parse | `fatal_errors: ["hazard-analysis.md malformed"]`, exit 1 — fail-closed per HAZ-016 (ARCH-012, D-011). |
| `hazard-analysis.md` missing/empty | Step 4 read | Skip elevation; emit explanatory `<!-- v-model: hazard-driven elevation skipped -->`; exit 0 (ARCH-014). |
| Upstream `plan.md` lacks v-model markers | Step 7 detector | Hybrid path engaged; per-task `traces-to` derived from V-Model artefacts directly or omitted with explicit comment; exit 0 (REQ-028, MOD-019). |
| Schema validator non-zero | Step 6 | Delete candidate; emit validator stdout into `fatal_errors[]`; exit 1; user inspects diff against `templates/tasks-template.md` (ARCH-013). |
| Enrichment leaks into canonical line grammar | Step 6 re-validation after Step 5 | Same as schema-validator failure; the post-enrichment validation re-check is the gate (ARCH-008, MOD-012, HAZ-011). |
| Atomic-rename failure (disk full, permissions) | `mv` non-zero | `fatal_errors: ["write failed: <path>"]`, exit 1; no partial file remains. |
| Structured summary truncated | Step 8 flush failure | Last-resort: emit `--- v-model run summary --- fatal_errors: [summary truncated] --- end summary ---`; exit 1 (HAZ-025, MOD-021). |

## Operating Constraints

### Additive-only enrichment

V-Model overlay is confined to `<!-- v-model: ... -->` HTML comments (block-level near the title and inline `<!-- traces-to: -->` per task) and the optional trailing `## V-Model Trace Summary` section. Canonical task-line grammar — including the `[P]` marker, story grouping, and dependency-graph block — is immutable (REQ-IF-002, ARCH-008, MOD-012).

### Round-trip compatibility

The output `tasks.md` must be consumable by **unmodified** `/speckit.implement`. The schema validator (ARCH-013) is the local gate; the integration test in `quickstart.md` Walkthrough 2 is the end-to-end gate (REQ-IF-002, SYS-010).

### Graceful degradation

Missing optional V-Model artefacts trigger reduced enrichment via MOD-019; missing/empty `hazard-analysis.md` skips elevation only — **never** a hard failure. A **malformed** `hazard-analysis.md` IS a hard failure: this is the deliberate fail-closed posture demanded by HAZ-016 (ARCH-012, ARCH-014, D-011, SYS-012).

### Stateless re-runnability

Every run regenerates `tasks.md` from `plan.md` + the V-Model artefact set; there is no cache. Re-running on an unchanged input set produces structurally identical output (idempotency NFR; D-006 TDD discipline applies to the bridge command itself, not just its output).
