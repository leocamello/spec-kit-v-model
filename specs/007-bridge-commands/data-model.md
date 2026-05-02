# Data Model: Bridge Commands (V-Model ↔ Spec-Kit Core)

**Feature**: 007-bridge-commands
**Branch**: `feature/007-bridge-commands` @ `8a2dc5d`
**Source of truth**: `specs/007-bridge-commands/v-model/system-design.md` §Data Design View (lines 435–456) and §Interface View — External (lines 395–433).

This document enumerates the eleven persistent / transient data
entities that cross a bridge-command boundary. Every entity is
traced to the parent SYS-NNN that owns it. No new database, key /
value store, message queue, encryption layer, or signing
authority is introduced.

> **Sensitivity statement (system-design.md lines 452–455)**: No
> personally-identifiable, secret, or otherwise-sensitive data
> flows through any bridge-command boundary. All data is project
> source under repository ACLs; consequently no
> encryption-at-rest, TLS-in-transit, or signing requirements
> arise from these requirements (REQ-NF-006, HAZ-022).

---

## Entity 1 — V-Model artifact set (input)

- **Files**: `requirements.md`, `acceptance-plan.md`,
  `system-design.md`, `system-test.md`, `architecture-design.md`,
  `integration-test.md`, `module-design.md`, `unit-test.md`,
  `hazard-analysis.md`, `traceability-matrix.md`.
- **Owners**: read by SYS-001, SYS-002, SYS-003 (via the LLM
  directly) and SYS-006 (via `grep`).
- **Storage**: Git-tracked files under
  `specs/<feature>/v-model/`.
- **Protection**: repository ACLs; Git history is the audit
  trail.
- **In-transit**: N/A (local file reads, same host).
- **Retention**: permanent in Git history; lifecycle-tagged
  (`[DEPRECATED]`, `[SUSPECT]`) per project rules — never
  deleted (cf. SYS-013 in `system-design.md` Decomposition View
  and the matching Addendum in `drift-diff-plan.md`).
- **Schema invariants** (enforced by D-008, D-015, ARCH-009):
  every ID-shaped token of the form
  `(REQ|SYS|ARCH|MOD|HAZ|UTP|ITP|STP|ATP|UTS|ITS|STS|SCN)-…` is
  defined exactly once across this set; downstream artefacts
  (research.md, plan.md, generated source) MUST cite only IDs
  drawn from this canonical set (REQ-023, REQ-NF-002).

---

## Entity 2 — Project constitution

- **File**: `.specify/memory/constitution.md`.
- **Owner**: read by SYS-001 (via the LLM directly).
- **Storage / Protection / Retention**: as Entity 1.
- **Schema invariants**: five named principles (cited in
  `plan.md` Constitution Check); §Testing Stack pins
  `bats-core`, `Pester`, `pytest`, `DeepEval` with
  `gemini-2.5-flash`.
- **Bridge-command consumers**: Constitution Check sections of
  `plan.md`; the §Constitution Sanity prompt section of
  `commands/plan.md` (MOD-002).

---

## Entity 3 — Domain overlay configuration

- **File**: `v-model-config.yml` at the repository root
  (optional).
- **Owner**: read by SYS-008 (via the LLM directly via the
  §Domain Overlay prompt section in `commands/implement.md`).
- **Storage / Protection / In-transit / Retention**: as Entity 1.
- **Schema invariants**: an absent file is a valid
  configuration meaning "no domain"; a present file MUST resolve
  to a directory under `commands/overlays/{domain}/_domain.yml`
  or the implement command aborts (REQ-024, MOD-008).
- **Bridge-command consumers**: §Domain Overlay prompt section
  of `commands/implement.md` (MOD-008).

---

## Entity 4 — Canonical spec-kit-core outputs

- **Files**: `plan.md`, `data-model.md`, `contracts/`,
  `quickstart.md`, `research.md`, `tasks.md` (and any other
  outputs already standardised by spec-kit core under
  `specs/<feature>/`).
- **Owners**: written by SYS-001 / SYS-002 (via the LLM,
  schema-validated by SYS-010 via
  `scripts/bash/validate-core-schema.sh` — D-002).
- **Storage / Protection / In-transit**: as Entity 1.
- **Retention**: permanent in Git history; regenerable from
  V-Model inputs (REQ-NF-005 ≥95% structural identity on
  re-runs).
- **Schema invariants** (enforced by ARCH-013 / MOD-017 /
  MOD-018):
  - `plan.md` MUST contain the spec-kit-core sections
    (`## Technical Context`, `## Constitution Check`, etc.) AND
    the V-Model enrichment (Entity 5) — verifier runs against
    both on every regen.
  - `tasks.md` MUST honour TDD ordering (tests-before-code) per
    REQ-011 / ATP-011-A.
- **Bridge-command consumers**: produced by `commands/plan.md`
  (MOD-001, MOD-002), `commands/tasks.md` (MOD-003, MOD-004),
  and consumed by `commands/implement.md` (MOD-005 .. MOD-009).

---

## Entity 5 — V-Model enrichment metadata

- **Storage**: inline within Entity 4 (HTML comments and
  optional Markdown sections; see
  `system-design.md §Data Flow View` for the layout grammar).
- **Owners**: written by SYS-005 from `commands/plan.md` and
  `commands/tasks.md` (MOD-011, MOD-012).
- **Protection / Retention**: inseparable from the host file's
  lifecycle.
- **Schema invariants** (REQ-007, REQ-012, REQ-NF-003):
  - Additive only — MUST NOT modify the spec-kit-core sections
    around them.
  - HTML-comment shape: `<!-- v-model: ... -->`, machine
    parseable, never executed.
- **Hazard mitigations**: HAZ-002 (enrichment overwrites core
  output), HAZ-011 (enrichment shape drift) — both fail-closed
  via the schema validator (ARCH-013).
- **Bridge-command consumers**: §Plan Enrichment prompt section
  of `commands/plan.md` (MOD-011); §Tasks Enrichment prompt
  section of `commands/tasks.md` (MOD-012).

---

## Entity 6 — Generated source code

- **Storage**: Git-tracked files under paths declared by each
  `MOD-NNN` Target Source File entry in `module-design.md`
  §Module Map (lines 80–110 of that file).
- **Owners**: written by SYS-003 (via the LLM,
  region-preserved by SYS-007 via
  `scripts/bash/splice-managed-regions.sh` — D-005).
- **Protection / Retention**: as Entity 1; user-authored regions
  outside V-Model sentinels preserved across re-runs (REQ-022).
- **Schema invariants** (D-015):
  - V-Model regions demarcated by
    `<!-- BEGIN MANAGED id="<MOD-NNN>" -->` and
    `<!-- END MANAGED id="<MOD-NNN>" -->` (or
    language-equivalent comment syntax).
  - Each region MUST contain an `Implements <MOD-NNN>`
    annotation; the Hallucination Guard (ARCH-009 / D-004)
    refuses to commit the file otherwise (REQ-023, REQ-NF-002).
- **Hazard mitigations**: HAZ-014 (region-marker corruption) →
  splicer fail-closed; HAZ-007 (hallucinated `Implements <ID>`
  comment) → guard fail-closed; HAZ-025 (truncated content) →
  caller-side `mktemp`+`mv` atomic rename (D-016).
- **Bridge-command consumers**: produced by
  `commands/implement.md` §Artefact Generation (MOD-005);
  validated by §Hallucination Guard (MOD-013).

---

## Entity 7 — Generated tests (unit / integration / system / acceptance)

- **Storage**: Git-tracked files under the project's existing
  test directories (`tests/bats/`, `tests/pester/`, `tests/`,
  `tests/evals/`).
- **Owners**: written by SYS-003 (via the LLM).
- **Protection / Retention**: as Entity 1; regenerable.
- **Schema invariants**:
  - Tests MUST exist (and fail) before the corresponding
    implementation is written (Constitution Principle I; D-006;
    REQ-011).
  - Each test file carries an `Implements <UTP|ITP|STP|ATP>-NNN`
    annotation, scanned by the Hallucination Guard.
- **Bridge-command consumers**: produced by
  `commands/implement.md` §Artefact Generation (MOD-005); also
  produced by `commands/tasks.md` for the Hazard Verification
  task family (MOD-016, REQ-014, ATP-014-A, ATP-014-B).

---

## Entity 8 — Pre-implementation gate report

- **Producer**: SYS-004 — `scripts/bash/run-v-model-gate.sh`
  stdout (D-003).
- **Storage**: stdout stream (transient).
- **Protection**: process boundary.
- **Retention**: not retained; surfaced into CI logs and the
  SYS-012 structured summary (Entity 10).
- **Schema invariants** (ARCH-007 — D-003):
  - Each inner script's stdout is forwarded verbatim, prefixed
    with `=== <script-name> ===`.
  - Final line is exactly `GATE: PASS` or `GATE: FAIL`.
  - Exit code: `0` iff every inner script returned `0`; `1`
    otherwise.
- **Hazard mitigations**: HAZ-009 (false-negative gate) — addressed
  by reuse of validated inner scripts (REQ-017, REQ-CN-002);
  HAZ-010 (false-positive gate) — same.
- **Bridge-command consumers**: §Pre-Implementation Gate prompt
  section of `commands/implement.md` (MOD-009, MOD-010); refusal
  conditions enforced by the prompt per REQ-NF-004.

---

## Entity 9 — Hallucination report

- **Producer**: SYS-006 —
  `scripts/bash/validate-implements-ids.sh` stdout (D-004).
- **Storage / Protection / Retention**: as Entity 8 (transient
  stdout); on hallucination, **no commit occurs** so the report
  is the only evidence — MUST be captured by CI.
- **Schema invariants** (ARCH-009 — D-004):
  - One `<file>:<line>: unknown id <id>` line per offending
    occurrence.
  - Final line is exactly `GUARD: PASS` or `GUARD: FAIL`.
  - Exit code: `0` on PASS; `1` on FAIL.
- **Hazard mitigations**: HAZ-007 (hallucinated `Implements`
  comment), HAZ-012 (false-negative), HAZ-023 (scanner runs on
  stale snapshot — invocation order forced by
  `commands/implement.md` per D-004).
- **Bridge-command consumers**: §Hallucination Guard prompt
  section of `commands/implement.md` (MOD-013, MOD-025).

---

## Entity 10 — Structured stdout summary

- **Producer**: SYS-012 — emitted by the LLM at the end of every
  bridge command (MOD-021).
- **Storage / Protection / Retention**: stdout stream
  (transient); captured by CI tooling per the existing
  `v-model.test-results` / `v-model.audit-report` conventions.
- **Schema invariants** (ARCH-016 / MOD-021):
  - Wrapped in `--- v-model run summary ---` … `---` fences.
  - Best-effort: never blocks the parent command from
    completing (system-design.md §Interface View row 433).
  - Flushed on every exit path including failures (mitigates
    HAZ-025 truncation).

---

## Entity 11 — Git commit annotations

- **Producer**: SYS-014 — LLM-issued `git commit -m` suffix
  (MOD-023).
- **Storage**: Git commit message metadata.
- **Protection**: Git history (signed if the contributor signs
  commits).
- **Retention**: permanent in Git history.
- **Schema invariants** (REQ-021, ARCH-018, MOD-023):
  - Suffix lists every `Implements <ID>` cited by the commit's
    diff, comma-separated.
  - Warning on failure; commit proceeds without annotation
    (verification by Inspection per ATP-021-A).

---

## Entity 12 — Hook registrations

- **Storage**: `extension.yml` at the repository root
  (Git-tracked).
- **Owner**: SYS-011 (the registrations themselves are owned by
  this feature; the *infrastructure* that interprets them remains
  in spec-kit core, REQ-NF-006).
- **Protection / Retention**: as Entity 1.
- **Schema invariants** (D-007 / ARCH-015 / MOD-020):
  - Three new entries: `after_specify` →
    `speckit.v-model.requirements`; `before_implement` →
    `speckit.v-model.trace`; `after_implement` →
    `speckit.v-model.trace`.
  - Existing `after_tasks: speckit.v-model.trace` entry is
    preserved unchanged.
  - File MUST validate against spec-kit core's
    `CommandRegistrar` schema; malformed YAML produces an
    install-time error (HAZ-019 mitigation).

---

## Cross-cutting properties

- **Concurrency** (REQ-CN-003, REQ-CN-004, SYS-015): all writes
  are guarded by the `mktemp`+`mv` same-directory atomic rename
  idiom (D-016). Process-wide locking is deferred for v0.7.0
  (SYS-015 §Risk Note); concurrent same-feature-directory
  invocations remain out of scope.
- **Idempotency** (REQ-NF-005): re-running any bridge command on
  the same inputs yields ≥95% structural identity in Entity 4
  outputs and 100% sentinel preservation in Entity 6 outputs
  (D-010, D-015).
- **Determinism** (Constitution Principle II, REQ-NF-002): the
  validators that gate Entity 4 (SYS-010 / ARCH-013) and Entity
  6 / 7 (SYS-006 / ARCH-009) are pure shell — no LLM call is
  involved in their pass / fail decisions.
- **Audit trail**: every bridge-command invocation produces (a)
  the SYS-012 structured summary (Entity 10) and (b) git
  history (Entities 1, 4, 5, 6, 7, 11, 12). No separate audit
  database is introduced.

---

## Coverage cross-reference

| SYS-NNN | Entities owned | Realised by |
|---------|----------------|-------------|
| SYS-001 | 4 (write) | `commands/plan.md` (MOD-001) |
| SYS-002 | 4 (write) | `commands/tasks.md` (MOD-003) |
| SYS-003 | 4 (read), 6, 7 (write) | `commands/implement.md` (MOD-005) |
| SYS-004 | 8 | `run-v-model-gate.sh` (MOD-010) |
| SYS-005 | 5 | §Plan/Tasks Enrichment (MOD-011, MOD-012) |
| SYS-006 | 9 | `validate-implements-ids.sh` (MOD-013, MOD-025) |
| SYS-007 | 6 (region-preserve) | `splice-managed-regions.sh` (MOD-014) |
| SYS-008 | 3 | §Domain Overlay (MOD-008) |
| SYS-009 | 7 (hazard subset) | §Hazard Enrichment (MOD-016) |
| SYS-010 | 4 (validate) | `validate-core-schema.sh` (MOD-017, MOD-018) |
| SYS-011 | 12 | `extension.yml` entries (MOD-020) |
| SYS-012 | 10 | §Observability (MOD-021) |
| SYS-013 | — (deprecated stub; see D-013) | — |
| SYS-014 | 11 | §Commit Annotation (MOD-023) |
| SYS-015 | 6, 7 (atomic-write) | `mktemp`+`mv` idiom at call sites (D-016) |

All twelve entities are covered; all fifteen SYS-NNN are
accounted for (SYS-013 retained as deprecated stub per D-013).
