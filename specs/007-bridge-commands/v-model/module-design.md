# Module Design: Bridge Commands

**Feature Branch**: `feature/007-bridge-commands`
**Created**: 2026-04-26
**Reworked**: 2026-05-01 (paradigm-drift correction per `drift-diff-plan.md`)
**Status**: Draft
**Source**: `specs/007-bridge-commands/v-model/architecture-design.md`
**Standards**: IEEE 1016:2009 §5 (Software Design Description), ISO/IEC/IEEE 12207:2017 §8.4.4 (Software Detailed Design Process)

## Overview

This document decomposes the 21 architecture modules from
`architecture-design.md` into 27 low-level module designs (`MOD-001` …
`MOD-027`). Each `MOD-NNN` is realised in the project's actual delivery
paradigm — **LLM prompt sections inside Markdown command files**,
**POSIX shell scripts**, **declarative YAML configuration consumed by
Spec Kit Core**, or a **deferred-risk note** carried for traceability
only. There is no Python runtime, no in-process orchestrator class, and
no runtime function-call graph: orchestration logic lives in the LLM
prompt; deterministic checks live in shell; registration is declarative
YAML; in-process abstractions that exist only to bridge a Python
implementation (artifact reader, subprocess runner, filesystem writer,
Python-level CI harness wrapper) are dropped because the chosen
paradigm has no use for them.

The realisation classes follow the paradigm-drift audit
(`drift-diff-plan.md`):

- **`NEW-PROMPT-SECTION`** — a named section inside a `commands/<name>.md`
  prompt file (with YAML frontmatter declaring `description`,
  `handoffs`, and a `scripts:` entry pointing at one Bash + PowerShell
  pair). The contract is encoded as preconditions / expected sub-sections
  / post-conditions the LLM must produce, plus the error path it must
  follow.
- **`NEW-SHELL`** — a POSIX shell script under `scripts/bash/<name>.sh`
  (with a `scripts/powershell/<Name>.ps1` mirror), invoked either from a
  command's `scripts:` frontmatter or via `bash <script>` from inside
  the LLM-orchestrated flow.
- **`REUSE-CORE`** — declarative YAML payload added to `extension.yml`
  at the repository root; registration is performed by Spec Kit Core's
  `CommandRegistrar` class in `src/specify_cli/extensions.py`
  (lines 579–884). This feature ships no new registration code.
- **`DROP-recharacterized`** — the module's responsibility is dissolved
  by the chosen paradigm (LLM reads Markdown natively, shell calls
  shell natively, atomic write is a 3-line `mktemp` + `mv` cliché, the
  CI quality harness is a GitHub Actions workflow). The MOD identifier
  is preserved as a deferred-risk note for forward traceability and
  carries no functional contract.

The runtime model is **single-shell, sequential per command invocation**
(see `architecture-design.md` §Process View). No MOD has inter-invocation
state. Concurrent runs against the same `feature_dir` are explicitly
out of scope for v0.7.0; SYS-013 / `architecture-design.md` §Concurrent-
Write Safety records this as a paradigm-level deferred risk note.

No domain overlay is loaded for this feature (`v-model-config.yml`
absent at the repository root); only the base IEEE 1016:2009 / ISO/IEC/
IEEE 12207:2017 §8.4.4 sections are populated. The MISRA / Memory
Management / Single Entry-Exit safety-critical sections are omitted
entirely.

## ID Schema

- **Module Design**: `MOD-NNN` — sequential identifier (3-digit
  zero-padded), independent of ARCH numbering.
- **Parent Architecture Modules**: comma-separated `ARCH-NNN` list per
  MOD (many-to-many; authoritative for traceability — coverage
  validators use this field, not ID parsing).
- **Classification**: one of `NEW-PROMPT-SECTION`, `NEW-SHELL`,
  `REUSE-CORE`, `DROP-recharacterized`.
- **Target Source File(s)**: repository-relative path to the realising
  artifact (a `commands/*.md` section anchor, a `scripts/bash/*.sh`
  script, `extension.yml`, or `[NO RUNTIME ARTIFACT — DEFERRED]`).
- **Implements REQ / Traced From**: comma-separated list of
  `REQ-NNN`, `SYS-NNN`, `ARCH-NNN`, `HAZ-NNN` identifiers; every cited
  identifier is verified to exist in `requirements.md`,
  `system-design.md`, `architecture-design.md`, or `hazard-analysis.md`
  respectively.

## Module Map (Summary Index)

| MOD | Name | Classification | Target Source File |
|-----|------|----------------|--------------------|
| MOD-001 | Plan Synthesis Orchestrator | NEW-PROMPT-SECTION | `commands/plan.md` §Execution Flow |
| MOD-002 | Canonical Output Emitter | NEW-PROMPT-SECTION | `commands/plan.md` §Output Artifacts |
| MOD-003 | Tasks Synthesis Orchestrator | NEW-PROMPT-SECTION | `commands/tasks.md` §Execution Flow |
| MOD-004 | TDD Task List Builder | NEW-PROMPT-SECTION | `commands/tasks.md` §TDD Ordering |
| MOD-005 | Implementation Orchestrator | NEW-PROMPT-SECTION | `commands/implement.md` §Execution Flow |
| MOD-006 | Code Generator (per-MOD dispatch) | NEW-PROMPT-SECTION | `commands/implement.md` §Code Generation |
| MOD-007 | Module Source Renderer | NEW-PROMPT-SECTION | `commands/implement.md` §Traceability Comments |
| MOD-008 | Test Generator (per-level dispatch) | NEW-PROMPT-SECTION | `commands/implement.md` §Test Generation |
| MOD-009 | Per-Level Test Renderer | NEW-PROMPT-SECTION | `commands/implement.md` §Test Levels |
| MOD-010 | Pre-Implementation Gate Coordinator | NEW-SHELL | `scripts/bash/run-v-model-gate.sh` |
| MOD-011 | Plan Enrichment Encoder | NEW-PROMPT-SECTION | `commands/plan.md` §Enrichment |
| MOD-012 | Tasks Traceability Comment Encoder | NEW-PROMPT-SECTION | `commands/tasks.md` §Traceability Comments |
| MOD-013 | Hallucination Guard | NEW-SHELL | `scripts/bash/validate-implements-ids.sh` |
| MOD-014 | Source Region Splicer | NEW-SHELL | `scripts/bash/splice-managed-regions.sh` |
| MOD-015 | Domain Overlay Adapter | NEW-PROMPT-SECTION | `commands/implement.md` §Domain Overlay |
| MOD-016 | Hazard-Driven Task Enricher | NEW-PROMPT-SECTION | `commands/tasks.md` §Hazard Enrichment |
| MOD-017 | Plan Schema Validator | NEW-SHELL | `scripts/bash/validate-core-schema.sh` (`--plan`) |
| MOD-018 | Tasks Schema Validator | NEW-SHELL | `scripts/bash/validate-core-schema.sh` (`--tasks`) |
| MOD-019 | Hybrid Path Enrichment Detector | NEW-PROMPT-SECTION | `commands/tasks.md` §Hybrid Path Detection |
| MOD-020 | Hook Registrar | REUSE-CORE | `extension.yml` (3 YAML entries) |
| MOD-021 | Structured Summary Reporter | NEW-PROMPT-SECTION | `commands/plan.md`, `commands/tasks.md`, `commands/implement.md` §Structured Summary |
| MOD-022 | Quality Compliance Harness | DROP-recharacterized | `[NO RUNTIME ARTIFACT — DEFERRED]` |
| MOD-023 | Commit Annotator | NEW-PROMPT-SECTION | `commands/implement.md` §Commit Annotation |
| MOD-024 | V-Model Artifact Loader | DROP-recharacterized | `[NO RUNTIME ARTIFACT — DEFERRED]` |
| MOD-025 | Canonical ID-Set Extractor | NEW-SHELL | `scripts/bash/validate-implements-ids.sh` (inline `grep`) |
| MOD-026 | Subprocess Runner | DROP-recharacterized | `[NO RUNTIME ARTIFACT — DEFERRED]` |
| MOD-027 | Atomic Filesystem Writer | DROP-recharacterized | `[NO RUNTIME ARTIFACT — DEFERRED]` |

## Module Designs

---

### MOD-001 — Plan Synthesis Orchestrator

| Field | Value |
|-------|-------|
| Classification | NEW-PROMPT-SECTION |
| Target Source File | `commands/plan.md` §Execution Flow |
| Traced From | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-026, REQ-027, REQ-NF-005, REQ-IF-001; SYS-001; ARCH-001 |

**Description**: The LLM-orchestrator section of `commands/plan.md` that
drives `/speckit.v-model.plan` end-to-end. Following the same vocabulary
used by `commands/audit-report.md` and `commands/test-results.md`, the
section names every input artifact the LLM must read, the
deterministic helpers it must invoke, the output sections it must
produce, and the structured summary it must emit on every exit path.

**Responsibilities**:
- Invoke Spec Kit Core's `setup-plan.sh` (via the `scripts:` frontmatter
  on `commands/plan.md`) to materialise the canonical artifact
  skeleton.
- Read every V-Model artifact present in `feature_dir/v-model/` as
  Markdown — natively, no parser.
- Refuse to proceed when `requirements.md` is absent (emit
  `fatal_errors[]` via §Structured Summary, exit 1).
- Drive the §Enrichment (MOD-011), §Output Artifacts (MOD-002), and
  §Structured Summary (MOD-021) sub-sections in sequence.
- Invoke `scripts/bash/validate-core-schema.sh --plan <path>` (MOD-017)
  before declaring an emitted artifact final.

**Pseudocode / Structural Sketch** (prompt outline):

```
## Execution Flow

1. Run `bash scripts/bash/setup-plan.sh` (Spec Kit Core) and read its
   stdout for skeleton paths.
2. Read each V-Model artifact present in `<feature_dir>/v-model/`
   as Markdown. If `requirements.md` is absent → emit
   §Structured Summary with `fatal_errors: ["requirements.md required"]`,
   exit 1.
3. Synthesise the canonical `plan.md` body per the v0.7.0 schema
   (§Output Artifacts contract).
4. Apply §Enrichment (MOD-011) — inject `<!-- vmodel:traces ... -->`
   HTML comment block immediately after the document title.
5. For each candidate output: write via the inline `mktemp` + `mv`
   pattern, then run `bash scripts/bash/validate-core-schema.sh
   --plan <path>`. Non-zero ⇒ delete the candidate, emit
   §Structured Summary with `fatal_errors[]`, exit 1.
6. Emit §Structured Summary (MOD-021) listing inputs_read[],
   outputs_produced[], artifacts_skipped[], warnings[]. Exit 0.

## LLM-checkable preconditions
- `commands/plan.md` frontmatter declares
  `scripts: { sh: scripts/bash/validate-core-schema.sh, ps: ... }`.
- `<feature_dir>/v-model/requirements.md` exists.

## Expected output sections (in order)
- §Execution Flow, §Output Artifacts, §Enrichment,
  §Structured Summary.
```

**Dependencies**:
- `commands/plan.md` (host file).
- Spec Kit Core: `scripts/bash/setup-plan.sh`,
  `scripts/bash/check-prerequisites.sh`,
  `scripts/bash/common.sh`.
- `scripts/bash/validate-core-schema.sh` (MOD-017).
- §Enrichment (MOD-011), §Output Artifacts (MOD-002),
  §Structured Summary (MOD-021).

**Verification**: BATS end-to-end test invoking the rendered
`commands/plan.md` against a fixture `feature_dir`; LLM structural-eval
in `tests/evals/` asserting the four expected sections are present in
canonical order.

---

### MOD-002 — Canonical Output Emitter

| Field | Value |
|-------|-------|
| Classification | NEW-PROMPT-SECTION |
| Target Source File | `commands/plan.md` §Output Artifacts |
| Traced From | REQ-001, REQ-008, REQ-026, REQ-IF-001; SYS-001; ARCH-002 |

**Description**: Prompt section that names every canonical spec-kit-core
output the LLM must write and the inline `mktemp` + `mv` write pattern
it must use.

**Responsibilities**:
- Enumerate the five canonical outputs: `plan.md`, `data-model.md`,
  `contracts/<name>.md`, `quickstart.md`, `research.md`.
- For each output, list the required spec-kit-core v0.7.0 sections.
- Specify the atomic-write cliché:
  `tmp=$(mktemp -p "$(dirname "$f")"); printf '%s' "$content" > "$tmp"; mv "$tmp" "$f"`.
- When an upstream input is absent, the LLM MUST skip the corresponding
  output and append the file name to `artifacts_skipped[]` in the
  §Structured Summary.

**Pseudocode / Structural Sketch** (prompt outline):

```
## Output Artifacts

For each artifact in {plan.md, data-model.md, contracts/<name>.md,
quickstart.md, research.md}:
  - Verify required sections per the v0.7.0 schema fixture.
  - Render canonical body.
  - Write via inline `mktemp -p "$(dirname "$target")"` + `mv` pair.
  - Append the resolved path to `outputs_produced[]`.
  - On any write failure, propagate as `fatal_errors[]` and exit 1.

If a required upstream input is `null`, skip the output and append the
filename to `artifacts_skipped[]` (graceful degradation per REQ-008).
```

**Dependencies**:
- `commands/plan.md` (host file).
- `scripts/bash/validate-core-schema.sh` (MOD-017) — invoked by
  MOD-001 before this section's emission.

**Verification**: BATS test asserting (a) the five expected files are
written when all inputs present, (b) the skipped subset is populated
correctly when an input is absent, (c) atomic-rename semantics —
killing the LLM mid-emission leaves either the prior content or the
new content, never a partial file.

---

### MOD-003 — Tasks Synthesis Orchestrator

| Field | Value |
|-------|-------|
| Classification | NEW-PROMPT-SECTION |
| Target Source File | `commands/tasks.md` §Execution Flow |
| Traced From | REQ-009, REQ-010, REQ-011, REQ-013, REQ-014, REQ-026, REQ-027, REQ-NF-005, REQ-IF-002; SYS-002; ARCH-003 |

**Description**: The LLM-orchestrator section of `commands/tasks.md`
that drives `/speckit.v-model.tasks` end-to-end.

**Responsibilities**:
- Read every V-Model artifact present plus any `plan.md` (V-Model-
  enriched or core-only).
- Invoke §Hybrid Path Detection (MOD-019) to decide whether upstream
  enrichment is present.
- Drive §TDD Ordering (MOD-004), §Hazard Enrichment (MOD-016),
  §Traceability Comments (MOD-012), and §Structured Summary (MOD-021).
- Invoke `scripts/bash/validate-core-schema.sh --tasks <path>`
  (MOD-018) before atomically writing `tasks.md`.

**Pseudocode / Structural Sketch** (prompt outline):

```
## Execution Flow

1. Run `bash scripts/bash/check-prerequisites.sh` (Spec Kit Core).
2. Read V-Model artifacts + optional `plan.md`.
3. §Hybrid Path Detection (MOD-019): grep upstream `plan.md` for
   `<!-- vmodel:traces`. If absent ⇒ derive traceability directly from
   V-Model artifacts.
4. §TDD Ordering (MOD-004): build the ordered task list
   (unit-test → impl → integration → system → acceptance).
5. §Hazard Enrichment (MOD-016): if `hazard-analysis.md` present,
   raise mitigation-task priority and emit one verification task per
   `HAZ-NNN`.
6. §Traceability Comments (MOD-012): inject
   `<!-- traces-to: MOD → ARCH → SYS → REQ -->` after each task line.
7. Write candidate `tasks.md` via inline `mktemp` + `mv`.
8. Run `bash scripts/bash/validate-core-schema.sh --tasks tasks.md`.
   Non-zero ⇒ delete candidate, emit `fatal_errors[]`, exit 1.
9. Emit §Structured Summary (MOD-021), exit 0.

## LLM-checkable preconditions
- `<feature_dir>/v-model/requirements.md` exists.
- `commands/tasks.md` frontmatter declares
  `scripts: { sh: scripts/bash/validate-core-schema.sh, ps: ... }`.

## Expected output sections (in order)
- §Execution Flow, §Hybrid Path Detection, §TDD Ordering,
  §Hazard Enrichment, §Traceability Comments, §Structured Summary.
```

**Dependencies**:
- `commands/tasks.md` (host file).
- Spec Kit Core: `scripts/bash/check-prerequisites.sh`.
- `scripts/bash/validate-core-schema.sh` (MOD-018).
- §Hybrid Path Detection (MOD-019), §TDD Ordering (MOD-004),
  §Hazard Enrichment (MOD-016), §Traceability Comments (MOD-012),
  §Structured Summary (MOD-021).

**Verification**: BATS end-to-end test against a fixture `feature_dir`
with and without `hazard-analysis.md` present; LLM structural-eval
asserting the six expected sections appear in canonical order.

---

### MOD-004 — TDD Task List Builder

| Field | Value |
|-------|-------|
| Classification | NEW-PROMPT-SECTION |
| Target Source File | `commands/tasks.md` §TDD Ordering |
| Traced From | REQ-009, REQ-010, REQ-013; SYS-002; ARCH-003 |

**Description**: Prompt section that specifies the TDD ordering
invariant (unit-test → impl → integration → system → acceptance) and
the `[P]` parallel-execution marker rule for independent modules.

**Responsibilities**:
- For each `MOD-NNN` in `module-design.md`, emit a `unit_test_write`
  task before any `implement` task.
- For each `ITP-NNN` in `integration-test.md`, emit a
  `integration_test_write` task after all `implement` tasks.
- For each `STP-NNN`/`STS-NNN` in `system-test.md`, emit a
  `system_test_write` task.
- For each `ATP-NNN` in `acceptance-plan.md`, emit an
  `acceptance_test_write` task.
- Apply `[P]` to tasks whose parent ARCHs are disjoint and whose
  Target Source Files do not overlap.

**Pseudocode / Structural Sketch** (prompt outline):

```
## TDD Ordering

For each MOD in module-design.md:
  - emit `T-<n>: write unit tests for MOD-NNN` (parents: MOD's ARCHs)
  - emit `T-<n+1>: implement MOD-NNN`            (parents: MOD's ARCHs)
For each ITP in integration-test.md:
  - emit `T-<n>: write integration test ITP-NNN` (parent: ITP's ARCH)
For each STP in system-test.md:
  - emit `T-<n>: write system test STP-NNN`     (parent: STP's SYS)
For each ATP in acceptance-plan.md:
  - emit `T-<n>: write acceptance test ATP-NNN` (parent: ATP's REQ)

Mark a task `[P]` iff its parents are disjoint from every preceding
unmarked task in the same level AND no Target Source File overlap.
```

**Dependencies**:
- `commands/tasks.md` (host file).
- §Execution Flow (MOD-003) which invokes this section.

**Verification**: LLM structural-eval asserting the four-tier ordering
appears in the rendered `tasks.md` for a fixture artifact set, plus a
property assertion that no `implement` task precedes its sibling
`unit_test_write`.

---

### MOD-005 — Implementation Orchestrator

| Field | Value |
|-------|-------|
| Classification | NEW-PROMPT-SECTION |
| Target Source File | `commands/implement.md` §Execution Flow |
| Traced From | REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005; SYS-003; ARCH-004 |

**Description**: The LLM-orchestrator section of `commands/implement.md`
that drives `/speckit.v-model.implement` end-to-end with hard ordering
gate → generate → verify → commit, fail-closed at every step.

**Responsibilities**:
- Invoke `scripts/bash/check-prerequisites.sh` (Spec Kit Core).
- Invoke `scripts/bash/run-v-model-gate.sh <feature_dir>` (MOD-010);
  non-zero exit ⇒ abort before any generation.
- Drive §Domain Overlay (MOD-015) — read `v-model-config.yml` if
  present.
- Drive §Code Generation (MOD-006) and §Test Generation (MOD-008).
- Invoke `scripts/bash/validate-implements-ids.sh <feature_dir>`
  (MOD-013) before commit; non-zero ⇒ abort.
- Drive §Commit Annotation (MOD-023) and §Structured Summary (MOD-021).

**Pseudocode / Structural Sketch** (prompt outline):

```
## Execution Flow

1. `bash scripts/bash/check-prerequisites.sh`
2. `bash scripts/bash/run-v-model-gate.sh <feature_dir>` (MOD-010)
   non-zero ⇒ §Structured Summary fatal_errors[], exit 1.
3. §Domain Overlay (MOD-015): if `v-model-config.yml` exists, parse
   `domain:` and apply additive overlay rules to subsequent generation.
   Malformed YAML ⇒ exit 1.
4. §Code Generation (MOD-006): for each MOD in module-design.md,
   render Target Source File via §Traceability Comments (MOD-007) and
   `bash scripts/bash/splice-managed-regions.sh` (MOD-014); write via
   inline `mktemp` + `mv`. Splicer non-zero ⇒ exit 1.
5. §Test Generation (MOD-008): emit unit/integration/system/acceptance
   tests via §Test Levels (MOD-009).
6. `bash scripts/bash/validate-implements-ids.sh <feature_dir>`
   (MOD-013). Non-zero ⇒ exit 1 BEFORE any commit.
7. §Commit Annotation (MOD-023): `git commit -m "<msg> — <ID>, <ID>"`.
8. §Structured Summary (MOD-021), exit 0.

## LLM-checkable preconditions
- All four V-Model test plans + `module-design.md` exist in
  `<feature_dir>/v-model/`.
- `commands/implement.md` frontmatter declares
  `scripts: { sh: scripts/bash/run-v-model-gate.sh, ps: ... }`.

## Expected output sections (in order)
- §Execution Flow, §Domain Overlay, §Code Generation,
  §Traceability Comments, §Test Generation, §Test Levels,
  §Commit Annotation, §Structured Summary.
```

**Dependencies**:
- `commands/implement.md` (host file).
- Spec Kit Core: `scripts/bash/check-prerequisites.sh`.
- `scripts/bash/run-v-model-gate.sh` (MOD-010),
  `scripts/bash/validate-implements-ids.sh` (MOD-013),
  `scripts/bash/splice-managed-regions.sh` (MOD-014).
- §Domain Overlay (MOD-015), §Code Generation (MOD-006),
  §Traceability Comments (MOD-007), §Test Generation (MOD-008),
  §Test Levels (MOD-009), §Commit Annotation (MOD-023),
  §Structured Summary (MOD-021).

**Verification**: BATS end-to-end test exercising the full flow;
explicit fail-closed assertions for {gate-fail, splicer-conflict,
hallucination-detected}; LLM structural-eval over the eight expected
sections.

---

### MOD-006 — Code Generator (per-MOD dispatch)

| Field | Value |
|-------|-------|
| Classification | NEW-PROMPT-SECTION |
| Target Source File | `commands/implement.md` §Code Generation |
| Traced From | REQ-018, REQ-022, REQ-024; SYS-003; ARCH-005 |

**Description**: Prompt section that instructs the LLM to walk the MOD
table in `module-design.md` and emit source code into the path declared
by each MOD's Target Source File.

**Responsibilities**:
- For each `MOD-NNN`, resolve Target Source File and target language
  from the MOD row.
- Render new content per §Traceability Comments (MOD-007).
- Pipe new content through
  `bash scripts/bash/splice-managed-regions.sh <target> <new> <lang>`
  (MOD-014) — splicer non-zero ⇒ abort the whole orchestrator before
  any write.
- Write via inline `mktemp` + `mv` cliché.

**Pseudocode / Structural Sketch** (prompt outline):

```
## Code Generation

For each MOD in module-design.md (skip DROP-recharacterized rows):
  language  := <derived from Target Source File extension>
  new_body  := § Traceability Comments header + rendered body
  spliced   := bash scripts/bash/splice-managed-regions.sh \
                 <target_source_file> <(echo "$new_body") <language>
  if exit != 0: emit fatal_errors[], exit 1.
  Write `spliced` via inline `mktemp` + `mv`.
```

**Dependencies**:
- `commands/implement.md` (host file).
- `scripts/bash/splice-managed-regions.sh` (MOD-014).
- §Traceability Comments (MOD-007).

**Verification**: BATS test asserting (a) each emitted file contains at
least one `Implements <ID>` comment, (b) splicer-conflict aborts before
any write, (c) idempotency on a second run (≥95% structural identity
per REQ-025).

---

### MOD-007 — Module Source Renderer

| Field | Value |
|-------|-------|
| Classification | NEW-PROMPT-SECTION |
| Target Source File | `commands/implement.md` §Traceability Comments |
| Traced From | REQ-018, REQ-024; SYS-003; ARCH-005 |

**Description**: Prompt section that specifies the comment syntax per
language and the rule that every generated MOD body MUST be preceded by
at least one `Implements <ID>` comment naming the MOD plus each parent
ARCH.

**Responsibilities**:
- Define the language→comment-prefix mapping (`#` for shell / python /
  yaml / powershell, `//` for typescript / c, `<!-- ... -->` for
  Markdown / HTML).
- Emit one `Implements <MOD-NNN>` comment plus one
  `Implements <ARCH-NNN>` comment per parent ARCH at the top of every
  generated region.

**Pseudocode / Structural Sketch** (prompt outline):

```
## Traceability Comments

Comment syntax per language:
  shell, python, yaml, powershell : `#`
  typescript, c                   : `//`
  markdown, html                  : `<!-- ... -->`

For every generated region in §Code Generation:
  emit `<comment_prefix> Implements <MOD-NNN>` on the first line,
  then one `<comment_prefix> Implements <ARCH-NNN>` per parent ARCH.
```

**Dependencies**:
- `commands/implement.md` (host file).
- §Code Generation (MOD-006) which consumes this section.

**Verification**: LLM structural-eval asserting comment syntax is
correct per language; BATS assertion that
`scripts/bash/validate-implements-ids.sh` exits 0 for the rendered
tree.

---

### MOD-008 — Test Generator (per-level dispatch)

| Field | Value |
|-------|-------|
| Classification | NEW-PROMPT-SECTION |
| Target Source File | `commands/implement.md` §Test Generation |
| Traced From | REQ-019, REQ-020; SYS-003; ARCH-006 |

**Description**: Prompt section that instructs the LLM to walk the four
V-Model test artifacts (`unit-test.md`, `integration-test.md`,
`system-test.md`, `acceptance-plan.md`) and emit one test file per
test case.

**Responsibilities**:
- For each level in {unit, integration, system, acceptance}: read the
  corresponding test plan; if absent, skip silently and append the
  artifact name to `artifacts_skipped[]`.
- For each test case in the plan, dispatch to §Test Levels (MOD-009).

**Pseudocode / Structural Sketch** (prompt outline):

```
## Test Generation

For each (level, artifact, target_dir) in:
  (unit,        unit-test.md,        tests/<harness>/unit/),
  (integration, integration-test.md, tests/<harness>/integration/),
  (system,      system-test.md,      tests/<harness>/system/),
  (acceptance,  acceptance-plan.md,  tests/<harness>/acceptance/):
  if artifact absent: append to artifacts_skipped[], continue.
  Render per §Test Levels (MOD-009).
```

**Dependencies**:
- `commands/implement.md` (host file).
- §Test Levels (MOD-009).

**Verification**: BATS test confirming graceful skip when a test
artifact is absent; LLM structural-eval that all four levels are
exercised when present.

---

### MOD-009 — Per-Level Test Renderer

| Field | Value |
|-------|-------|
| Classification | NEW-PROMPT-SECTION |
| Target Source File | `commands/implement.md` §Test Levels |
| Traced From | REQ-019, REQ-020; SYS-003; ARCH-006 |

**Description**: Prompt section mapping each V-Model test level to its
target test directory and asserting that every emitted test file
references its source test-plan ID via an `Implements <ID>` comment.

**Responsibilities**:
- Map level → directory: `unit` → `tests/bats/unit/` (or `tests/pester/`
  on Windows mirror), `integration` → `tests/bats/integration/`,
  `system` → `tests/bats/system/`, `acceptance` → `tests/bats/acceptance/`.
- Emit one test file per `UTP-NNN` / `ITP-NNN` / `STP-NNN` / `ATP-NNN`,
  with `# Implements <ID>` (BATS) or `// Implements <ID>` (TypeScript)
  comment as the first non-shebang line.

**Pseudocode / Structural Sketch** (prompt outline):

```
## Test Levels

Per-level target directory map:
  unit        → tests/bats/unit/
  integration → tests/bats/integration/
  system      → tests/bats/system/
  acceptance  → tests/bats/acceptance/

For each test case (TC) at a level:
  path := <target_dir>/test_<lower(TC.id)>.bats
  body := `#!/usr/bin/env bats\n# Implements <TC.id>\n` + scenarios
  Write via inline `mktemp` + `mv`.
```

**Dependencies**:
- `commands/implement.md` (host file).
- §Test Generation (MOD-008) which dispatches into this section.

**Verification**: BATS smoke test that every emitted test file is
syntactically valid and contains the expected `Implements` comment.

---

### MOD-010 — Pre-Implementation Gate Coordinator

| Field | Value |
|-------|-------|
| Classification | NEW-SHELL |
| Target Source File | `scripts/bash/run-v-model-gate.sh` (PLANNED) + `scripts/powershell/Run-VModel-Gate.ps1` mirror |
| Traced From | REQ-016, REQ-017, REQ-NF-004, REQ-CN-002; SYS-004; ARCH-007; HAZ-009 |

**Description**: Thin POSIX shell wrapper (~30 lines) composing
the existing `build-matrix.sh` + five `validate-*-coverage.sh` scripts.
Introduces no parallel gating logic — only sequential composition with
fail-closed exit propagation. The structural twin of the
`commands/audit-report.md` deterministic-script vocabulary.

**Responsibilities**:
- Accept a single `<feature-dir>` argument.
- Run `scripts/bash/build-matrix.sh <feature-dir>` first; non-zero ⇒
  exit 1 with `GATE: FAIL`.
- Run each of `validate-requirement-coverage.sh`,
  `validate-system-coverage.sh`, `validate-architecture-coverage.sh`,
  `validate-module-coverage.sh`, `validate-hazard-coverage.sh` in
  sequence; aggregate stdout; any non-zero ⇒ exit 1.
- Emit final line `GATE: PASS` (exit 0) or `GATE: FAIL` (exit 1).

**Pseudocode / Structural Sketch**:

```bash
#!/usr/bin/env bash
# Implements MOD-010
# Implements ARCH-007
set -euo pipefail
source "$(dirname "$0")/common.sh"  # Spec Kit Core helper

FEATURE_DIR="${1:?usage: run-v-model-gate.sh <feature-dir>}"
VMODEL_DIR="${FEATURE_DIR%/}/v-model"

scripts=(
  "scripts/bash/build-matrix.sh                 ${FEATURE_DIR}"
  "scripts/bash/validate-requirement-coverage.sh ${VMODEL_DIR}"
  "scripts/bash/validate-system-coverage.sh      ${VMODEL_DIR}"
  "scripts/bash/validate-architecture-coverage.sh ${VMODEL_DIR}"
  "scripts/bash/validate-module-coverage.sh      ${VMODEL_DIR}"
  "scripts/bash/validate-hazard-coverage.sh      ${VMODEL_DIR}"
)

failed=0
for cmd in "${scripts[@]}"; do
  echo "--- ${cmd}" >&2
  bash ${cmd} || failed=1
done

if (( failed != 0 )); then
  echo "GATE: FAIL"
  exit 1
fi
echo "GATE: PASS"
```

**Dependencies**:
- Existing project shell scripts: `scripts/bash/build-matrix.sh`,
  `scripts/bash/validate-requirement-coverage.sh`,
  `scripts/bash/validate-system-coverage.sh`,
  `scripts/bash/validate-architecture-coverage.sh`,
  `scripts/bash/validate-module-coverage.sh`,
  `scripts/bash/validate-hazard-coverage.sh`.
- Spec Kit Core helper: `scripts/bash/common.sh`.

**Verification**: BATS unit tests against fixture matrices: (a) all
inner scripts pass ⇒ `GATE: PASS`, exit 0; (b) any inner script fails
⇒ `GATE: FAIL`, exit 1; (c) missing inner script ⇒ exit 1 with
diagnostic on stderr; (d) HAZ-009 fail-closed assertion (incomplete
matrix MUST NOT produce code).

---

### MOD-011 — Plan Enrichment Encoder

| Field | Value |
|-------|-------|
| Classification | NEW-PROMPT-SECTION |
| Target Source File | `commands/plan.md` §Enrichment |
| Traced From | REQ-007, REQ-NF-003, REQ-IF-001; SYS-005; ARCH-008 |

**Description**: Prompt section instructing the LLM to inject a single
`<!-- vmodel:traces ... -->` HTML comment block immediately under the
`plan.md` document title, plus optional `## V-Model Trace Summary`
Markdown sections at the end of the document — never modifying any
canonical spec-kit-core section.

**Responsibilities**:
- Inject the HTML comment block immediately after the H1 title.
- Append optional Markdown sections at end-of-document only.
- Guarantee that ARCH-013 (`scripts/bash/validate-core-schema.sh
  --plan`) still exits 0 after enrichment is applied (additive-only
  invariant).

**Pseudocode / Structural Sketch** (prompt outline):

```
## Enrichment

1. Locate the H1 title line of the canonical `plan.md`.
2. Immediately after it, insert one HTML comment block:
     <!-- vmodel:traces
       requirements: [REQ-001, REQ-002, ...]
       hazards:      [HAZ-001, ...]
       version:      v0.7.0
     -->
3. Optionally append `## V-Model Trace Summary` as the last section.
4. NEVER modify any canonical section heading, ordering, or body.
5. After enrichment, MOD-001 re-runs MOD-017 to confirm the canonical
   schema still validates.
```

**Dependencies**:
- `commands/plan.md` (host file).
- §Execution Flow (MOD-001) which invokes this section.
- `scripts/bash/validate-core-schema.sh` (MOD-017) for the
  post-enrichment validation re-check.

**Verification**: LLM structural-eval asserting (a) HTML-comment
present after H1, (b) every canonical heading still present in
canonical order, (c) MOD-017 still exits 0.

---

### MOD-012 — Tasks Traceability Comment Encoder

| Field | Value |
|-------|-------|
| Classification | NEW-PROMPT-SECTION |
| Target Source File | `commands/tasks.md` §Traceability Comments |
| Traced From | REQ-012, REQ-NF-003, REQ-IF-002; SYS-005; ARCH-008 |

**Description**: Prompt section instructing the LLM, for each task line
in `tasks.md`, to append on the immediately following line a single
`<!-- traces-to: MOD-NNN → ARCH-NNN → SYS-NNN → REQ-NNN -->` HTML
comment.

**Responsibilities**:
- Match each task line by `T-<n>:` prefix or table row.
- Look up the trace chain from the in-context V-Model artifact set.
- If no chain is found for a given task, emit no comment (silent
  additive-only behaviour).
- Never modify the task line itself.

**Pseudocode / Structural Sketch** (prompt outline):

```
## Traceability Comments

For each line `task_line` in the rendered task list:
  if task_line matches /^T-\d+:/ or /^\| T-\d+ \|/:
    chain := lookup_chain(task_id)
    if chain is not None:
      emit on the next line:
        `<!-- traces-to: <chain.mod> → <chain.arch> → <chain.sys> → <chain.req> -->`
  else: no-op.
```

**Dependencies**:
- `commands/tasks.md` (host file).
- §Execution Flow (MOD-003) which invokes this section.

**Verification**: LLM structural-eval asserting every `T-<n>:` task in
the rendered `tasks.md` is followed by a `traces-to:` comment when an
in-context chain exists; BATS assertion that
`validate-core-schema.sh --tasks` still exits 0.

---

### MOD-013 — Hallucination Guard

| Field | Value |
|-------|-------|
| Classification | NEW-SHELL |
| Target Source File | `scripts/bash/validate-implements-ids.sh` (PLANNED, ~80 lines) + `scripts/powershell/Validate-Implements-Ids.ps1` mirror |
| Traced From | REQ-023, REQ-NF-002; SYS-006; ARCH-009; HAZ-012 |

**Description**: Deterministic POSIX shell script that scans the
generated source set for `# Implements <ID>` / `// Implements <ID>` /
`<!-- Implements <ID> -->` comments via `grep -E`, cross-references
each cited identifier against the canonical V-Model ID set extracted
inline by MOD-025, and exits non-zero on any unknown identifier. Zero
LLM involvement.

**Responsibilities**:
- Accept a single `<feature-dir>` argument.
- Discover generated source files (project-relative, excluding
  `specs/` and `tests/fixtures/`).
- Run MOD-025 (inline) to build the canonical ID set from
  `<feature-dir>/v-model/*.md`.
- Print one line per offending occurrence:
  `<file>:<line>: unknown id <id>`.
- Emit `GUARD: PASS` (exit 0) or `GUARD: FAIL` (exit 1).

**Pseudocode / Structural Sketch**:

```bash
#!/usr/bin/env bash
# Implements MOD-013
# Implements MOD-025
# Implements ARCH-009
set -euo pipefail
FEATURE_DIR="${1:?usage: validate-implements-ids.sh <feature-dir>}"
VMODEL_DIR="${FEATURE_DIR%/}/v-model"

# MOD-025 — extract canonical ID universe from V-Model artifacts
canonical_ids=$(
  grep -rhoE '(REQ|SYS|ARCH|MOD|HAZ|ATP|ITP|STP|UTP|SCN|ITS|UTS|STS)-[A-Z0-9-]+' \
    "$VMODEL_DIR" 2>/dev/null \
    | sort -u
)

# Scan generated tree for `Implements <ID>` annotations
hits=$(
  grep -rEn '(#|//|<!--)\s*Implements\s+[A-Z]+-[A-Z0-9-]+' \
    --include='*.sh' --include='*.ps1' --include='*.py' \
    --include='*.ts' --include='*.js' --include='*.md' \
    --exclude-dir=specs --exclude-dir=tests \
    . 2>/dev/null || true
)

failed=0
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  id=$(printf '%s' "$line" | grep -oE '[A-Z]+-[A-Z0-9-]+' | tail -1)
  if ! grep -qx "$id" <<<"$canonical_ids"; then
    printf '%s: unknown id %s\n' "${line%%:*:*}" "$id"
    failed=1
  fi
done <<<"$hits"

if (( failed != 0 )); then
  echo "GUARD: FAIL"
  exit 1
fi
echo "GUARD: PASS"
```

**Dependencies**:
- POSIX `grep`, `awk`, `sort` (system binaries).
- V-Model artifact tree under `<feature-dir>/v-model/` (read-only).
- MOD-025 is implemented inline as the `canonical_ids=$(grep ...)` step.

**Verification**: BATS unit tests covering (a) every comment cites a
known ID ⇒ exit 0; (b) injected `REQ-999` phantom ⇒ exit 1 with the
expected `unknown id REQ-999` line; (c) HAZ-012 false-negative rate
assertion (no valid ID misclassified as hallucinated across the
fixture artifact set).

---

### MOD-014 — Source Region Splicer

| Field | Value |
|-------|-------|
| Classification | NEW-SHELL |
| Target Source File | `scripts/bash/splice-managed-regions.sh` (PLANNED, awk-based, ~80 lines) + `scripts/powershell/Splice-Managed-Regions.ps1` mirror |
| Traced From | REQ-022; SYS-007; ARCH-010; HAZ-023 |

**Description**: POSIX shell script using `awk` to splice generated
content into a target file's V-Model-managed region (delimited by
language-appropriate `VMODEL-MANAGED-BEGIN` / `VMODEL-MANAGED-END`
sentinel comments), preserving everything outside the markers. Aborts
non-zero with a diff report on stderr if markers are unbalanced,
overlapping, or duplicated.

**Responsibilities**:
- Accept `<target_file> <generated_content_path> <language>`.
- If `<target_file>` does not exist, wrap `<generated_content>` in the
  language-appropriate `VMODEL-MANAGED-BEGIN`/`END` markers and print
  the wrapped content to stdout (caller writes via `mktemp`+`mv`).
- If `<target_file>` exists, locate the single managed region via
  `awk` and replace its interior with `<generated_content>`, preserving
  pre/post bytes.
- Detect (a) unbalanced markers, (b) overlapping markers, (c) more
  than one managed region — exit 1 with a diff on stderr.

**Pseudocode / Structural Sketch**:

```bash
#!/usr/bin/env bash
# Implements MOD-014
# Implements ARCH-010
set -euo pipefail
TARGET="${1:?target}"
NEW="${2:?generated_content}"
LANG="${3:?language}"

case "$LANG" in
  shell|python|yaml|powershell) PFX="#"  ;;
  typescript|c|js)              PFX="//" ;;
  markdown|html)                PFX="<!--" SFX=" -->" ;;
  *) echo "unsupported language: $LANG" >&2; exit 1 ;;
esac
SFX="${SFX:-}"
OPEN="${PFX} VMODEL-MANAGED-BEGIN${SFX}"
CLOSE="${PFX} VMODEL-MANAGED-END${SFX}"

if [[ ! -f "$TARGET" ]]; then
  printf '%s\n' "$OPEN"; cat "$NEW"; printf '%s\n' "$CLOSE"
  exit 0
fi

opens=$(grep -cFx "$OPEN"  "$TARGET" || true)
closes=$(grep -cFx "$CLOSE" "$TARGET" || true)
if (( opens != closes )); then
  echo "unbalanced markers: ${opens} OPEN vs ${closes} CLOSE" >&2; exit 1
fi
if (( opens > 1 )); then
  echo "more than one managed region not supported" >&2; exit 1
fi

awk -v open="$OPEN" -v close="$CLOSE" -v newfile="$NEW" '
  $0 == open  { print; while ((getline l < newfile) > 0) print l; in_region=1; next }
  $0 == close { in_region=0; print; next }
  !in_region  { print }
' "$TARGET"
```

**Dependencies**:
- POSIX `awk`, `grep`, `cat` (system binaries).
- Caller (MOD-006) is responsible for `mktemp` + `mv` of the spliced
  stdout.

**Verification**: BATS unit tests for (a) absent target ⇒ wrapped
content; (b) present target with one managed region ⇒ correct splice
preserving pre/post bytes; (c) unbalanced markers ⇒ exit 1 + diff on
stderr; (d) overlapping / duplicated markers ⇒ exit 1; (e) HAZ-023
mitigation: scanner consumes the spliced output without re-entry
(deterministic, no in-process recursion).

---

### MOD-015 — Domain Overlay Adapter

| Field | Value |
|-------|-------|
| Classification | NEW-PROMPT-SECTION |
| Target Source File | `commands/implement.md` §Domain Overlay |
| Traced From | REQ-024; SYS-008; ARCH-011; HAZ-024 |

**Description**: Prompt section instructing the LLM to read
`v-model-config.yml` if present at the repository root and apply
domain-specific generation rules (`automotive` ⇒ ISO 26262 ASIL test
depth; `medical` ⇒ IEC 62304 traceability; `aerospace` ⇒ DO-178C MC/DC
unit-test coverage) additively to the base instructions.

**Responsibilities**:
- File-presence check via the LLM's native filesystem read.
- On YAML parse failure (malformed `v-model-config.yml`, missing
  `domain:` key) ⇒ abort fail-closed with a `fatal_errors[]` entry and
  non-zero exit.
- For unknown `domain` value ⇒ log a `warnings[]` entry and continue
  with no overlay (overlay is opt-in).

**Pseudocode / Structural Sketch** (prompt outline):

```
## Domain Overlay

1. If `<repo_root>/v-model-config.yml` is absent → no overlay; continue
   with base prompt.
2. Read the file as YAML. On parse failure → emit `fatal_errors[]`,
   exit 1 (HAZ-024 fail-closed).
3. domain := config["domain"]
   if domain == "iso_26262"  : apply ASIL-driven test-depth rules.
   if domain == "do_178c"    : require MC/DC unit-test coverage.
   if domain == "iec_62304"  : require traceability matrix in every
                               commit.
   else                      : warnings[] += "Unknown domain '$domain' —
                               overlay skipped".
4. Overlay rules are additive only — they NEVER override the base
   §Code Generation / §Test Generation instructions.
```

**Dependencies**:
- `commands/implement.md` (host file).
- §Execution Flow (MOD-005) which invokes this section before
  §Code Generation.
- Optional `v-model-config.yml` at repo root.

**Verification**: LLM structural-eval over fixture configs covering
{absent, valid-iso26262, valid-do178c, valid-iec62304, unknown-domain,
malformed-yaml}; BATS assertion that the malformed-yaml case produces
`fatal_errors[]` and exit 1.

---

### MOD-016 — Hazard-Driven Task Enricher

| Field | Value |
|-------|-------|
| Classification | NEW-PROMPT-SECTION |
| Target Source File | `commands/tasks.md` §Hazard Enrichment |
| Traced From | REQ-014; SYS-009; ARCH-012; HAZ-001..HAZ-025 (any present) |

**Description**: Prompt section that activates when
`hazard-analysis.md` is present in `<feature-dir>/v-model/`. Instructs
the LLM to (a) raise the priority of any task whose target equals a
HAZ row's mitigation requirement, (b) append one verification task per
`HAZ-NNN` naming the hazard explicitly.

**Responsibilities**:
- Read `<feature-dir>/v-model/hazard-analysis.md` natively.
- Validate each HAZ row has the canonical columns (`HAZ-NNN`, severity,
  mitigation, verification ID); malformed row ⇒ emit `fatal_errors[]`
  and exit 1.
- For each valid HAZ row, mutate the in-context task list per the
  rules above.

**Pseudocode / Structural Sketch** (prompt outline):

```
## Hazard Enrichment

If `hazard-analysis.md` is absent → identity (no-op).

For each row HAZ in hazard-analysis.md:
  if row is malformed (missing required column) → fatal_errors[], exit 1.
  for each task T in current task list:
    if T.target == HAZ.mitigation_id:
      T.priority := max(T.priority, HAZARD_MITIGATION_PRIORITY=90)
  append a new task:
    kind:     hazard_verification
    target:   HAZ.id           (e.g. HAZ-009)
    parents:  [HAZ.id]
    priority: HAZARD_VERIFICATION_PRIORITY=95
    text:     "Verify mitigation of <HAZ.id>: <HAZ.description>"
```

**Dependencies**:
- `commands/tasks.md` (host file).
- §Execution Flow (MOD-003).
- Optional `<feature-dir>/v-model/hazard-analysis.md`.

**Verification**: LLM structural-eval over fixture `hazard-analysis.md`
files; BATS assertion that one verification task per HAZ row is
present in the rendered `tasks.md` and that mitigation-target tasks
have `priority >= 90`.

---

### MOD-017 — Plan Schema Validator

| Field | Value |
|-------|-------|
| Classification | NEW-SHELL |
| Target Source File | `scripts/bash/validate-core-schema.sh` (PLANNED, ~50 lines) invoked with `--plan` |
| Traced From | REQ-028, REQ-029, REQ-IF-001, REQ-CN-001; SYS-010; ARCH-013 |

**Description**: One half of the shared schema validator. With `--plan`
it greps the candidate `plan.md` against the pinned spec-kit-core
v0.7.0 list of required sections (`## Technical Context`,
`## Constitution Check`, etc.) and exits non-zero if any are missing
or out of canonical order.

**Responsibilities**:
- Accept `<file> --plan`.
- For each required section in the pinned v0.7.0 plan-template list:
  `grep -q '^## <Section Name>' <file>` ⇒ if no match, append to a
  `MISSING:` list.
- Emit final `SCHEMA: PASS` (exit 0; print `pinned_version=v0.7.0`)
  or `SCHEMA: FAIL` (exit 1; print each missing section).

**Pseudocode / Structural Sketch**: see MOD-018 (shared script). The
`--plan` branch sets `REQUIRED=("Technical Context" "Constitution
Check" "Project Structure" "Phase 0" "Phase 1" "Phase 2" "Complexity
Tracking")` per the pinned v0.7.0 `plan-template.md`.

**Dependencies**:
- POSIX `grep`, `awk` (system binaries).
- Pinned v0.7.0 required-section list (inline `case` statement in the
  script — no separate fixture file).

**Verification**: BATS unit tests for (a) all required sections present
⇒ exit 0; (b) any required section missing ⇒ exit 1 with
`<section>: MISSING` line; (c) `pinned_version=v0.7.0` printed in the
PASS path.

---

### MOD-018 — Tasks Schema Validator

| Field | Value |
|-------|-------|
| Classification | NEW-SHELL |
| Target Source File | `scripts/bash/validate-core-schema.sh` (PLANNED, ~50 lines) invoked with `--tasks` |
| Traced From | REQ-028, REQ-029, REQ-IF-002, REQ-CN-001; SYS-010; ARCH-013 |

**Description**: Sibling half of the shared schema validator. With
`--tasks` it greps the candidate `tasks.md` against the pinned
spec-kit-core v0.7.0 tasks-template required sections and the
canonical task-row pattern.

**Responsibilities**:
- Accept `<file> --tasks`.
- For each required section in the pinned v0.7.0 tasks-template list:
  `grep -q '^## <Section Name>' <file>` ⇒ if no match, append to
  `MISSING:` list.
- Spot-check that at least one task line matches the canonical
  `^T-[0-9]+:` row pattern.
- Emit final `SCHEMA: PASS` (exit 0) or `SCHEMA: FAIL` (exit 1).

**Pseudocode / Structural Sketch** (shared script for MOD-017 +
MOD-018):

```bash
#!/usr/bin/env bash
# Implements MOD-017
# Implements MOD-018
# Implements ARCH-013
set -euo pipefail
FILE="${1:?usage: validate-core-schema.sh <file> --plan|--tasks}"
MODE="${2:?--plan or --tasks}"

case "$MODE" in
  --plan)
    REQUIRED=(
      "Technical Context" "Constitution Check" "Project Structure"
      "Phase 0" "Phase 1" "Phase 2" "Complexity Tracking"
    )
    ;;
  --tasks)
    REQUIRED=("Tasks" "Dependencies" "Parallel Execution Notes")
    ;;
  *) echo "unknown mode: $MODE" >&2; exit 1 ;;
esac

failed=0
for section in "${REQUIRED[@]}"; do
  if ! grep -qE "^## ${section}\b" "$FILE"; then
    printf '%s: MISSING\n' "$section"
    failed=1
  fi
done

if [[ "$MODE" == "--tasks" ]] && ! grep -qE '^T-[0-9]+:' "$FILE"; then
  echo "Tasks: NO_CANONICAL_ROWS"
  failed=1
fi

if (( failed != 0 )); then
  echo "SCHEMA: FAIL"
  exit 1
fi
echo "SCHEMA: PASS pinned_version=v0.7.0"
```

**Dependencies**:
- POSIX `grep` (system binary).
- Inline pinned v0.7.0 section lists.

**Verification**: BATS unit tests for (a) full-conformance fixture ⇒
exit 0; (b) section deletion ⇒ exit 1 with the expected
`<section>: MISSING` line; (c) canonical row pattern absent in
`--tasks` mode ⇒ exit 1.

---

### MOD-019 — Hybrid Path Enrichment Detector

| Field | Value |
|-------|-------|
| Classification | NEW-PROMPT-SECTION |
| Target Source File | `commands/tasks.md` §Hybrid Path Detection |
| Traced From | REQ-028; SYS-010; ARCH-014 |

**Description**: Prompt section that, on entry to
`/speckit.v-model.tasks`, performs a one-line `grep` (executed by the
LLM via `run_command`) to detect whether an upstream `plan.md` carries
V-Model enrichment markers; if absent, the LLM derives traceability
directly from the V-Model artifact set (Hybrid path per REQ-028).

**Responsibilities**:
- Probe `<feature-dir>/plan.md` (if present) for the substring
  `<!-- vmodel:traces`.
- If absent ⇒ emit a `warnings[]` entry stating "Reduced-enrichment
  path — upstream plan.md lacks vmodel markers; downstream
  traceability derived directly from V-Model artifacts."
- If present ⇒ consume markers as-is.

**Pseudocode / Structural Sketch** (prompt outline):

```
## Hybrid Path Detection

if not exists(<feature-dir>/plan.md):
  enriched := false (no upstream)
else:
  run: grep -q '<!-- vmodel:traces' <feature-dir>/plan.md
  enriched := (exit code == 0)

if not enriched:
  warnings[] += "Reduced-enrichment path — upstream plan.md lacks
    vmodel markers; deriving traceability directly from V-Model
    artifacts (REQ-028 Hybrid path)."
```

**Dependencies**:
- `commands/tasks.md` (host file).
- §Execution Flow (MOD-003).

**Verification**: LLM structural-eval over fixture
`{absent, enriched, core-only}` upstream `plan.md` cases; assertion
that the warnings entry appears exactly once in the core-only case.

---

### MOD-020 — Hook Registrar

| Field | Value |
|-------|-------|
| Classification | REUSE-CORE |
| Target Source File | `extension.yml` (3 YAML entries appended at the repository root) |
| Traced From | REQ-IF-003, REQ-IF-005, REQ-NF-006; SYS-011; ARCH-015 |

**Description**: Three declarative YAML entries appended to
`extension.yml` at the repository root. Registration is performed at
install time by Spec Kit Core's `CommandRegistrar` class in
`src/specify_cli/extensions.py` (lines 579–884). This feature ships
**no new registration code**.

**Responsibilities** (all delegated to Spec Kit Core):
- Discover extensions at install time by reading `extension.yml`.
- Wire the three V-Model hooks (`after_specify` →
  `v-model.requirements`; `before_implement`, `after_implement` →
  `v-model.trace`) into the spec-kit CLI namespace.
- Register the three new commands (`v-model.plan`, `v-model.tasks`,
  `v-model.implement`) per the agent-specific format
  (`AGENT_CONFIGS` dict in `extensions.py`).
- Idempotency: re-runs do not duplicate entries.

**Pseudocode / Structural Sketch** — YAML payload (the entire
implementation):

```yaml
# extension.yml
hooks:
  after_specify:
    - v-model.requirements
  before_implement:
    - v-model.trace
  after_implement:
    - v-model.trace

commands:
  - id: v-model.plan
    file: commands/plan.md
  - id: v-model.tasks
    file: commands/tasks.md
  - id: v-model.implement
    file: commands/implement.md
```

**Dependencies**:
- Spec Kit Core's `CommandRegistrar` class —
  `src/specify_cli/extensions.py` lines 579–884.
- `extension.yml` at the repository root.

**Verification**: BATS test asserting the three YAML entries exist in
`extension.yml`; integration test installing the extension under each
supported AI agent (`AGENT_CONFIGS` list in `extensions.py`) and
asserting the commands appear in the expected `.<agent>/commands/`
directory.

---

### MOD-021 — Structured Summary Reporter

| Field | Value |
|-------|-------|
| Classification | NEW-PROMPT-SECTION |
| Target Source File | `commands/plan.md`, `commands/tasks.md`, `commands/implement.md` §Structured Summary |
| Traced From | REQ-027, REQ-IF-004; SYS-012; ARCH-016; HAZ-025 |

**Description**: Identical §Structured Summary section appended to each
of the three command files. Specifies the exact stdout grammar shared
by `commands/audit-report.md` and `commands/test-results.md`,
guaranteeing every run — successful or failed — emits a machine-
readable summary block.

**Responsibilities**:
- Emit on every exit path (success and failure both flow through this
  section before exit) — HAZ-025 mitigation.
- Print the canonical envelope:
  `--- v-model run summary ---` header,
  `inputs_read:`, `outputs_produced:`, `artifacts_skipped:`,
  `warnings:`, `fatal_errors:` (each as a YAML-style sequence),
  `--- end summary ---` footer.
- Flush stdout before exit.

**Pseudocode / Structural Sketch** (prompt outline, identical in all
three command files):

```
## Structured Summary

Always emit, even on failure paths, before exit:

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
  - <text>          # only when present; empty list ⇒ omit the key
--- end summary ---

Then: exit with the appropriate exit code (0 success, 1 fatal).
```

**Dependencies**:
- `commands/plan.md`, `commands/tasks.md`, `commands/implement.md`
  (host files).
- Vocabulary borrowed from `commands/audit-report.md` and
  `commands/test-results.md`.

**Verification**: LLM structural-eval over fixture runs of each of the
three commands, asserting (a) the envelope is present on every exit
path, (b) all five list keys are emitted (or `fatal_errors:` omitted
on success), (c) HAZ-025 mitigation: stdout is flushed before exit so
the summary is observable even when the LLM aborts.

---

### MOD-022 — Quality Compliance Harness

| Field | Value |
|-------|-------|
| Classification | DROP-recharacterized |
| Target Source File | `[NO RUNTIME ARTIFACT — DEFERRED]` |
| Traced From | REQ-NF-001, REQ-CN-003, REQ-CN-004; SYS-013 (paradigm-level deferred risk note); ARCH-017 |

**Description**: `[DEFERRED — no runtime module]`. The quality harness
is a CI / meta concern, not a runtime command component. The four
existing test stacks — `tests/bats/`, `tests/pester/`, `tests/evals/`
(structural eval), and the LLM-eval suite under `tests/evals/` —
already satisfy REQ-NF-001 / REQ-CN-003 / REQ-CN-004 when invoked from
GitHub Actions. Merge-gate enforcement is GitHub Actions branch
protection, not a runtime Python module.

**Pseudocode / Structural Sketch**: `[NO PSEUDOCODE — DEFERRED]`

**Replacement**: The CI workflow under `.github/workflows/` is the
sole runtime locus. The MOD identifier is preserved as a deferred-risk
note for forward traceability; should a future release introduce a
local pre-commit harness, that work will be tracked under a new MOD.

**Dependencies**: None at the runtime level.

**Verification**: CI workflow runs the four-stack harness on every PR;
no in-tree assertion is owned by this MOD.

---

### MOD-023 — Commit Annotator

| Field | Value |
|-------|-------|
| Classification | NEW-PROMPT-SECTION |
| Target Source File | `commands/implement.md` §Commit Annotation |
| Traced From | REQ-021; SYS-014; ARCH-018 |

**Description**: Prompt section instructing the LLM, after MOD-013
exits 0, to issue `git commit -m "<base-message> — <ID>, <ID>, …"`
where the suffix is the comma-separated list of V-Model identifiers
fulfilled by the change. Best-effort: an annotation-construction
failure is a `warnings[]` entry, not fatal; a `git commit` invocation
failure is fatal.

**Responsibilities**:
- Compute the ID list from the in-context generation plan.
- If the list is empty ⇒ emit a `warnings[]` entry and commit with the
  unannotated base message.
- Invoke `git commit -m "<annotated-message>"`.
- Propagate `git commit` non-zero as `fatal_errors[]` and exit 1.

**Pseudocode / Structural Sketch** (prompt outline):

```
## Commit Annotation

Precondition: MOD-013 exited 0.

ids := derive_ids_from(generation_plan)
if len(ids) == 0:
  warnings[] += "annotate_commit invoked with empty id list — suffix omitted"
  message := base_message
else:
  message := base_message + " — " + ", ".join(ids)

run: git commit -m "<message>"
if exit != 0:
  fatal_errors[] += "git commit failed: <stderr>"; exit 1
```

**Dependencies**:
- `commands/implement.md` (host file).
- §Execution Flow (MOD-005).
- System binary `git`.

**Verification**: LLM structural-eval over a fixture generation plan;
BATS assertion that the produced commit message ends with the canonical
` — <ID>, <ID>` suffix and that the empty-ID case still produces a
commit (with a warnings entry).

---

### MOD-024 — V-Model Artifact Loader

| Field | Value |
|-------|-------|
| Classification | DROP-recharacterized |
| Target Source File | `[NO RUNTIME ARTIFACT — DEFERRED]` |
| Traced From | REQ-NF-003 (parser-drift prevention); ARCH-019 (deferred-risk note) |

**Description**: `[DEFERRED — no runtime module]`. In the chosen
paradigm the LLM reads V-Model Markdown artifacts natively as text;
no parser ships with this feature. Spec Kit Core's
`scripts/bash/check-prerequisites.sh` already handles `FEATURE_DIR` /
`AVAILABLE_DOCS` discovery. The parser-drift risk that motivated this
MOD (REQ-NF-003) is structurally eliminated by having no parser to
drift.

**Pseudocode / Structural Sketch**: `[NO PSEUDOCODE — DEFERRED]`

**Replacement**: Native LLM Markdown reading + Spec Kit Core's
`check-prerequisites.sh`.

**Dependencies**: None at the runtime level.

**Verification**: ARCH-019 deferred-risk note assertion in
`architecture-design.md`; no in-tree code asserts this MOD.

---

### MOD-025 — Canonical ID-Set Extractor

| Field | Value |
|-------|-------|
| Classification | NEW-SHELL |
| Target Source File | `scripts/bash/validate-implements-ids.sh` (PLANNED) — implemented inline as the `canonical_ids=$(grep …)` step |
| Traced From | REQ-NF-002 (feeds the hallucination guard); ARCH-019 (deferred-risk note for the original Python loader) |

**Description**: ~15 lines of shell embedded inside MOD-013's script
that build the canonical ID universe by `grep -roE` across every
Markdown artifact in `<feature-dir>/v-model/`. There is no separate
script file: the audit determined a separate file would be code-bloat
without functional benefit. The MOD identifier remains for forward
traceability into MOD-013.

**Responsibilities**:
- Walk every `*.md` under `<feature-dir>/v-model/`.
- Extract every match of the regex
  `(REQ|SYS|ARCH|MOD|HAZ|ATP|ITP|STP|UTP|SCN|ITS|UTS|STS)-[A-Z0-9-]+`.
- Deduplicate via `sort -u`.
- Expose the result as a Bash variable consumed by the line-by-line
  comparison loop in MOD-013.

**Pseudocode / Structural Sketch** (excerpt from MOD-013's script):

```bash
# Implements MOD-025
canonical_ids=$(
  grep -rhoE '(REQ|SYS|ARCH|MOD|HAZ|ATP|ITP|STP|UTP|SCN|ITS|UTS|STS)-[A-Z0-9-]+' \
    "$VMODEL_DIR" 2>/dev/null \
  | sort -u
)
```

**Dependencies**:
- POSIX `grep`, `sort` (system binaries).
- V-Model artifact tree (read-only).
- Embedded inside `scripts/bash/validate-implements-ids.sh` (MOD-013).

**Verification**: BATS unit tests over a fixture `v-model/` containing
all canonical ID prefixes; assertion that each one is present in the
extracted set and that no duplicates appear.

---

### MOD-026 — Subprocess Runner

| Field | Value |
|-------|-------|
| Classification | DROP-recharacterized |
| Target Source File | `[NO RUNTIME ARTIFACT — DEFERRED]` |
| Traced From | REQ-CN-002; ARCH-020 (deferred-risk note) |

**Description**: `[DEFERRED — no runtime module]`. Shell scripts invoke
other shell scripts via `bash <script>` directly; there is no Python
runtime that needs a subprocess wrapper. The REQ-CN-002 allowlist is
self-evident: it is the set of executable scripts under `scripts/bash/`
plus the explicit system-binary list (`git`, `bats`, `pwsh`, `bash`,
`grep`, `awk`, `sort`) used by the four new shell scripts.

**Pseudocode / Structural Sketch**: `[NO PSEUDOCODE — DEFERRED]`

**Replacement**: Direct `bash <script>` invocations from inside the
LLM-orchestrated flow; system-binary calls inline in shell.

**Dependencies**: None at the runtime level.

**Verification**: ARCH-020 deferred-risk note in
`architecture-design.md`; no in-tree code asserts this MOD.

---

### MOD-027 — Atomic Filesystem Writer

| Field | Value |
|-------|-------|
| Classification | DROP-recharacterized |
| Target Source File | `[NO RUNTIME ARTIFACT — DEFERRED]` |
| Traced From | REQ-022, REQ-025; ARCH-021 (deferred-risk note) |

**Description**: `[DEFERRED — no runtime module]`. Atomic write is the
3-line `mktemp` + `mv` cliché used inline in every shell script that
mutates a tracked file:

```
tmp=$(mktemp -p "$(dirname "$f")")
printf '%s' "$content" > "$tmp"
mv "$tmp" "$f"
```

This pattern is documented in `architecture-design.md` §Overview and
enforced by code review. There is no centralised writer module to
ship.

**Pseudocode / Structural Sketch**: `[NO PSEUDOCODE — DEFERRED]`

**Replacement**: Inline `mktemp`+`mv` cliché in every shell script and
in every LLM prompt section that writes a file.

**Dependencies**: POSIX `mktemp`, `mv` (system binaries).

**Verification**: BATS assertion across the four new shell scripts that
no script writes a tracked file via direct redirection (`> $target`)
without going through the `mktemp`+`mv` pattern.

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Module Designs (MOD) | 27 (all preserved; MOD-001..MOD-027) |
| **NEW-PROMPT-SECTION** (sections inside `commands/{plan,tasks,implement}.md`) | **16** — MOD-001, 002, 003, 004, 005, 006, 007, 008, 009, 011, 012, 015, 016, 019, 021, 023 |
| **NEW-SHELL** (POSIX shell scripts under `scripts/bash/`) | **6** — MOD-010, 013, 014, 017, 018, 025 |
| **REUSE-CORE** (declarative YAML; no new code) | **1** — MOD-020 |
| **DROP-recharacterized** (deferred-risk notes; no functional contract) | **4** — MOD-022, 024, 026, 027 |
| **Total** | **27** ✓ |
| Net-new shell script files | 4 (`run-v-model-gate.sh`, `validate-implements-ids.sh`, `splice-managed-regions.sh`, `validate-core-schema.sh`) — MOD-013 + MOD-025 share one script; MOD-017 + MOD-018 share one script |
| Net-new command Markdown files | 3 (`commands/plan.md`, `commands/tasks.md`, `commands/implement.md`) hosting the 16 NEW-PROMPT-SECTION entries |
| Net-new Python files | **0** |
| **Forward Coverage (ARCH→MOD)** | **21 / 21 (100%)** — every ARCH-NNN in `architecture-design.md` is realised by at least one active MOD or, for ARCH-019/020/021, by a paired DROP-recharacterized MOD that preserves the trace |

### ARCH → MOD coverage table (forward)

| ARCH | Realised By |
|------|-------------|
| ARCH-001 | MOD-001 |
| ARCH-002 | MOD-002 |
| ARCH-003 | MOD-003, MOD-004 |
| ARCH-004 | MOD-005 |
| ARCH-005 | MOD-006, MOD-007 |
| ARCH-006 | MOD-008, MOD-009 |
| ARCH-007 | MOD-010 |
| ARCH-008 | MOD-011, MOD-012 |
| ARCH-009 | MOD-013 |
| ARCH-010 | MOD-014 |
| ARCH-011 | MOD-015 |
| ARCH-012 | MOD-016 |
| ARCH-013 | MOD-017, MOD-018 |
| ARCH-014 | MOD-019 |
| ARCH-015 | MOD-020 |
| ARCH-016 | MOD-021 |
| ARCH-017 | MOD-022 (DROP-recharacterized — CI workflow replaces runtime) |
| ARCH-018 | MOD-023 |
| ARCH-019 | MOD-024 (DROP-recharacterized) + MOD-025 (NEW-SHELL inline) |
| ARCH-020 | MOD-026 (DROP-recharacterized) |
| ARCH-021 | MOD-027 (DROP-recharacterized) |

## Standards Governance

This document is a Software Design Description (SDD) per
**IEEE 1016:2009 §5** (Required SDD Information Items) and a Software
Detailed Design output per **ISO/IEC/IEEE 12207:2017 §8.4.4**
(Software Detailed Design Process). Required IEEE 1016 §5 elements:

- **Identification** — feature branch, version (Reworked 2026-05-01),
  status, sources (architecture-design.md).
- **Stakeholders & Concerns** — implementers (V-Model command authors),
  reviewers (paradigm-drift auditor), Spec Kit Core maintainers
  (interface contract via `extension.yml`).
- **Design Views (§5.1)** — Decomposition (Module Map + per-MOD
  rows), Dependency (per-MOD Dependencies field), Interface (per-MOD
  Pseudocode / Structural Sketch + Verification field).
- **Design Overlays** — none (no domain overlay loaded; base
  IEEE 1016 only).
- **Design Rationale** — captured as the Classification + Description
  per MOD; full rationale lives in `drift-diff-plan.md`.

ISO/IEC/IEEE 12207:2017 §8.4.4.3 (formal interface definition per
module) is satisfied by (a) the per-MOD Target Source File anchor
(naming the exact file and section), (b) the structured-sketch
specifying inputs / outputs / preconditions / error paths, and (c)
the per-MOD Verification field naming the BATS / structural-eval test
that exercises the contract.

## Derived Modules

None — every active MOD traces to one or more active `ARCH-NNN`. Four
deferred-risk MODs (MOD-022, MOD-024, MOD-026, MOD-027) carry explicit
`DROP-recharacterized` rationale and no functional contract; none
qualify as derived.
