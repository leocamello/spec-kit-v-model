---
description: "TDD-ordered task list for feature 007-bridge-commands (v0.7.0)"
---

# Tasks: Bridge Commands (V-Model ↔ Spec-Kit Core)

**Input**: Design documents from `/specs/007-bridge-commands/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md, contracts/, v-model/
**Branch**: `feature/007-bridge-commands` @ `36e556d` (Step A.1)
**V-Model artifact set**: frozen at `618d706` — do not edit

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no shared state)
- **[Story]**: Maps to a user story from `spec.md` (US1=P1, US2=P2, US3=P2, US4=P3)
- Each task cites at least one V-Model ID (REQ/SYS/ARCH/MOD/UTP/ITP/STP/ATP/SCN/HAZ) or research decision (D-NNN)
- TDD ordering follows research.md **D-006** (test-first; tests for shell scripts authored before any script body) and **D-007** (declarative hook wiring after scripts and prompts exist)

## Path Conventions

Single-repository CLI extension (per `plan.md` §Project Structure). All paths are relative to the repository root.

- Markdown command prompts: `commands/`
- Shell scripts: `scripts/bash/` and `scripts/powershell/`
- Tests: `tests/bats/`, `tests/pester/`, `tests/evals/`, `tests/integration/`, `tests/system/`, `tests/acceptance/`
- Hook config: `extension.yml`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Test scaffolding and fixture skeletons that the RED phase needs.

- [x] T001 [P] Create empty test directories `tests/bats/`, `tests/pester/`, `tests/evals/`, `tests/integration/`, `tests/system/`, `tests/acceptance/` and add a `tests/README.md` index pointing each subtree at its UTP/ITP/STP/ATP plan (REQ-NF-001; D-006).
- [x] T002 [P] Create fixture skeleton `tests/fixtures/v-model/complete/` (a minimal complete V-Model artifact set, mirroring `specs/007-bridge-commands/v-model/`) and `tests/fixtures/v-model/missing-hazard/` (same set with `hazard-analysis.md` removed) for use by SCN-001-A1, SCN-016-A1, and ATP-014-A replays (ATP-001-A, ATP-014-A; SCN-001-A1, SCN-016-A1).
- [x] T003 [P] Add BATS + Pester + DeepEval discovery shims in `tests/conftest.py` and `tests/helpers/load_canonical_ids.sh` that expose the canonical-ID set extracted from `specs/<feature>/v-model/*.md` to every test family (REQ-NF-002; SYS-006; ARCH-009; D-008).

---

## Phase 2: Foundational — RED (failing BATS tests for the four shell scripts)

**Purpose**: Author every BATS suite for the four new shell scripts FIRST, ensuring they fail before any script body is written. Per **D-006** these block the GREEN phase.

**⚠️ CRITICAL**: No GREEN-phase work (Phase 3 onward) may begin until these four tests are committed and confirmed RED.

- [x] T004 [P] Write failing BATS suite for the gate coordinator in `tests/bats/run-v-model-gate.bats` covering: composition trace (must `exec*` exactly `build-matrix.sh` + 5 existing `validate-*-coverage.sh` and no other wrapper), exit-code aggregation, `GATE: PASS`/`GATE: FAIL` final line, structured-summary block on every exit path (REQ-017, REQ-CN-002, REQ-027; SYS-004, SYS-012; ARCH-007, ARCH-016; MOD-010, MOD-021; UTP-010-A, UTP-010-B; ATP-017-A; SCN-017-A1; HAZ-009, HAZ-010).
- [x] T005 [P] Write failing BATS suite for the hallucination guard in `tests/bats/validate-implements-ids.bats` covering: positive case (every `Implements <ID>` resolves to a canonical ID), negative case (one fabricated ID → exit 1, offending `<file>:<line>` reported), empty-input case, and the cross-doc/canonical extraction match against `specs/<feature>/v-model/*.md` (REQ-023, REQ-NF-002, REQ-NF-004; SYS-006; ARCH-009; MOD-013, MOD-025; UTP-013-A, UTP-025-A; ATP-019-A; SCN-019-A1; HAZ-007, HAZ-012, HAZ-023; D-004, D-008).
- [x] T006 [P] Write failing BATS suite for the region splicer in `tests/bats/splice-managed-regions.bats` covering: idempotent re-run preserves user content outside `<!-- BEGIN MANAGED id="…" -->` / `<!-- END MANAGED id="…" -->` sentinels, atomic-rename pattern (`mktemp -p $(dirname …); … ; mv`), and refusal on malformed/unbalanced markers (REQ-022, REQ-NF-005; SYS-007, SYS-015; ARCH-010; MOD-014; UTP-014-A, UTP-014-B; ATP-018-A; SCN-018-A1; HAZ-008, HAZ-014, HAZ-023, HAZ-025; D-005, D-015, D-016).
- [x] T007 [P] Write failing BATS suite for the schema validator in `tests/bats/validate-core-schema.bats` covering: `--plan` mode against a frozen spec-kit-core `plan.md` template, `--tasks` mode against the spec-kit-core `tasks-template.md`, fail-closed on missing required fields, and tolerance of additive HTML-comment enrichment (REQ-IF-001, REQ-IF-002, REQ-029; SYS-010; ARCH-013; MOD-017, MOD-018; UTP-017-A, UTP-018-A; ATP-002-A; SCN-002-A1).

**Checkpoint**: All four BATS suites must run and FAIL (no script bodies exist yet) before Phase 3 starts.

---

## Phase 3: GREEN — implement the four shell scripts

**Purpose**: Make the BATS suites in Phase 2 pass. One script per task. Each script body is the minimum to satisfy its UTP-A/B set.

- [x] T008 Implement `scripts/bash/run-v-model-gate.sh` (~30 LOC): invoke `scripts/bash/build-matrix.sh` then the five existing `validate-*-coverage.sh` scripts in sequence; aggregate exit codes; emit `GATE: PASS`/`GATE: FAIL` and the structured `--- v-model run summary ---` block on every exit path (REQ-017, REQ-CN-002, REQ-027; SYS-004, SYS-012; ARCH-007, ARCH-016; MOD-010, MOD-021; ITP-010-A; ATP-017-A; SCN-017-A1; D-003). **Depends on**: T004.
- [x] T009 Implement `scripts/bash/validate-implements-ids.sh` (~80 LOC): `grep` every `Implements <ID>` from a target tree, `awk` the canonical-ID set out of `specs/<feature>/v-model/*.md`, diff the two with `comm -23`, exit non-zero on any unknown ID and print `<file>:<line>: unknown ID <X>`; final line `GUARD: PASS` on success (REQ-023, REQ-NF-002; SYS-006; ARCH-009; MOD-013, MOD-025; ITP-013-A; ATP-019-A; SCN-019-A1; HAZ-007, HAZ-012; D-004, D-008). **Depends on**: T005.
- [x] T010 Implement `scripts/bash/splice-managed-regions.sh` (~85 LOC): `awk` the BEGIN/END MANAGED sentinel envelope; replace the inside with the freshly-generated block; preserve every byte outside; write via `tmp=$(mktemp -p "$(dirname "$f")"); … ; mv "$tmp" "$f"`; refuse on unbalanced sentinels with exit 2 (REQ-022, REQ-NF-005; SYS-007, SYS-015; ARCH-010; MOD-014; ITP-014-A; ATP-018-A; SCN-018-A1; HAZ-008, HAZ-014, HAZ-025; D-005, D-015, D-016). **Depends on**: T006.
- [x] T011 Implement `scripts/bash/validate-core-schema.sh` (~50 LOC): accept `--plan|--tasks`; `grep`-validate required headings/sections against the spec-kit-core templates; tolerate additive `<!-- v-model: … -->` HTML-comment enrichment; fail closed with a unified diff on missing required fields (REQ-IF-001, REQ-IF-002, REQ-029; SYS-010; ARCH-013; MOD-017, MOD-018; ITP-017-A; ATP-002-A; SCN-002-A1). **Depends on**: T007.

**Checkpoint**: All BATS suites GREEN. Bash deliverables complete.

---

## Phase 4: PowerShell parity (mirrors + Pester)

**Purpose**: Mirror each Bash script as a PowerShell 7+ equivalent and back it with a Pester suite that asserts identical behaviour. Per **D-009**, parity is script-by-script and bytes-equivalent on stdout summaries.

- [x] T012 [P] Mirror `scripts/powershell/run-v-model-gate.ps1` and author Pester suite `tests/pester/run-v-model-gate.Tests.ps1` reproducing every assertion in `tests/bats/run-v-model-gate.bats` (REQ-NF-006, REQ-CN-001; SYS-004, SYS-012; ARCH-007; MOD-010; UTP-010-A; D-009). **Depends on**: T008.
- [x] T013 [P] Mirror `scripts/powershell/validate-implements-ids.ps1` and author Pester suite `tests/pester/validate-implements-ids.Tests.ps1` (REQ-NF-006, REQ-NF-002; SYS-006; ARCH-009; MOD-013, MOD-025; UTP-013-A, UTP-025-A; D-009). **Depends on**: T009.
- [x] T014 [P] Mirror `scripts/powershell/splice-managed-regions.ps1` and author Pester suite `tests/pester/splice-managed-regions.Tests.ps1` (REQ-NF-006, REQ-NF-005; SYS-007, SYS-015; ARCH-010; MOD-014; UTP-014-A; D-009, D-015). **Depends on**: T010.
- [x] T015 [P] Mirror `scripts/powershell/validate-core-schema.ps1` and author Pester suite `tests/pester/validate-core-schema.Tests.ps1` (REQ-NF-006, REQ-IF-001, REQ-IF-002; SYS-010; ARCH-013; MOD-017, MOD-018; UTP-017-A, UTP-018-A; D-009). **Depends on**: T011.

**Checkpoint**: Bash + PowerShell deliverables at byte-identical behavioural parity.

---

## Phase 5: Command prompts (the three bridge commands)

**Purpose**: Author the three Markdown command-prompt files. Each prompt composes its declared MOD/ARCH set and references the shell scripts from Phase 3 via its YAML `scripts:` entry. Order is by user-story priority (P1 → P2 → P2).

- [x] T016 [US1] Author `commands/implement.md` (`/speckit.v-model.implement`) ~150–180 prompt lines wrapping: gate invocation (T008), code generation, four-level test generation, sentinel-managed splicing (T010), hallucination-guard self-check (T009), commit-subject suffix annotation, and the structured-summary block on every exit path (REQ-015, REQ-016, REQ-017, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-027, REQ-NF-002, REQ-NF-004, REQ-NF-005, REQ-CN-002, REQ-CN-003, REQ-CN-004; SYS-003, SYS-004, SYS-006, SYS-007, SYS-008, SYS-012, SYS-014; ARCH-004, ARCH-005, ARCH-006, ARCH-009, ARCH-010, ARCH-011, ARCH-016, ARCH-017, ARCH-018; MOD-005, MOD-006, MOD-007, MOD-008, MOD-009, MOD-013, MOD-015, MOD-021, MOD-022, MOD-023; HAZ-007, HAZ-009, HAZ-014, HAZ-021, HAZ-023, HAZ-025; D-001, D-014). **Depends on**: T008, T009, T010.
- [x] T017 [P] [US2] Author `commands/plan.md` (`/speckit.v-model.plan`) ~150–180 prompt lines wrapping: V-Model artifact reading, canonical `plan.md` synthesis, additive enrichment encoding, schema validation (T011), reduced-enrichment fallback for missing optional artefacts, and the structured-summary block (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-027, REQ-IF-001, REQ-NF-005; SYS-001, SYS-005, SYS-010, SYS-012; ARCH-001, ARCH-002, ARCH-008, ARCH-013, ARCH-014, ARCH-016; MOD-001, MOD-002, MOD-011, MOD-021; D-001, D-010). **Depends on**: T011.
- [x] T018 [P] [US3] Author `commands/tasks.md` (`/speckit.v-model.tasks`) ~150–180 prompt lines wrapping: V-Model artifact reading, TDD-ordered tasks synthesis, hazard-driven priority elevation + per-HAZ verification task emission, additive enrichment, schema validation (T011), and the structured-summary block (REQ-011, REQ-012, REQ-013, REQ-014, REQ-027, REQ-IF-002; SYS-002, SYS-005, SYS-009, SYS-010, SYS-012; ARCH-003, ARCH-008, ARCH-012, ARCH-013, ARCH-014, ARCH-016; MOD-003, MOD-004, MOD-012, MOD-016, MOD-019, MOD-021; HAZ-016; D-001, D-006, D-011). **Depends on**: T011.

**Checkpoint**: Three command prompts in place; `extension.yml` registration is the next gate.

---

## Phase 6: Hook integration

- [x] T019 [US4] Append three declarative entries to `extension.yml`: `hooks.after_specify → v-model.requirements`, `hooks.before_implement → v-model.trace`, `hooks.after_implement → v-model.trace` (preserving the existing `after_tasks → v-model.trace` entry); register the three command prompts (T016, T017, T018) under the `commands:` section (REQ-IF-003, REQ-IF-005, REQ-NF-006, REQ-CN-001; SYS-011; ARCH-015; MOD-020; D-007). **Depends on**: T016, T017, T018.

---

## Phase 7: LLM evals (DeepEval + structural)

**Purpose**: Cover the prompt-section modules per **D-010** (LLM-as-judge for compositional prompts; structural pytest for ID/schema invariants). One eval file per command-prompt cluster.

- [x] T020 [P] [US2] Add `tests/evals/test_plan_inputs.py` (DeepEval + pytest) asserting: `inputs_read` lists the 11 expected files for SCN-001-A1, missing-hazard fallback for SCN-001-B1, and additive enrichment grammar `^<!-- v-model:` is present in synthesised `plan.md` (REQ-001, REQ-002, REQ-IF-001; SYS-001, SYS-005; ARCH-001, ARCH-002, ARCH-008, ARCH-014; MOD-001, MOD-002, MOD-011; UTP-001-A, UTP-002-A; ATP-001-A, ATP-002-A; SCN-001-A1, SCN-002-A1; D-010). **Depends on**: T017.
- [x] T021 [P] [US3] Add `tests/evals/test_tasks_order.py` and `tests/evals/test_hazard_tasks.py` asserting: TDD section ordering (write-unit → implement → run-unit → write-integration → run-integration → write-system → run-system → write-acceptance) for SCN-011-A1, hazard-driven priority elevation for SCN-014-A1, and one verification task per HAZ-NNN for SCN-014-B1 (REQ-011, REQ-012, REQ-013, REQ-014, REQ-IF-002; SYS-002, SYS-009; ARCH-003, ARCH-012; MOD-003, MOD-004, MOD-012, MOD-016; UTP-003-A, UTP-004-A, UTP-012-A, UTP-016-A; ATP-011-A, ATP-012-A, ATP-013-A, ATP-014-A, ATP-014-B; SCN-011-A1, SCN-014-A1, SCN-014-B1; HAZ-016; D-010, D-011). **Depends on**: T018.
- [x] T022 [P] [US1] Add `tests/evals/test_implements_per_symbol.py` and `tests/evals/test_commit_suffix.py` asserting: 100% of public symbols carry an `Implements <ID>` comment (SCN-019-A1), tests at all four levels are emitted (SCN-020-A1), and commit subjects end with `— <ID>[, <ID>]*` (SCN-021-A1) (REQ-019, REQ-020, REQ-021, REQ-NF-002; SYS-003, SYS-008; ARCH-005, ARCH-006, ARCH-018; MOD-006, MOD-007, MOD-008, MOD-023; UTP-006-A, UTP-007-A, UTP-008-A; ATP-019-A, ATP-020-A, ATP-021-A; SCN-019-A1, SCN-020-A1, SCN-021-A1; D-010). **Depends on**: T016.

---

## Phase 8: Cross-document validators / structural tests

- [x] T023 Add structural pytest `tests/structural/test_extension_yml.py` validating `extension.yml` registers exactly three new commands and three new hooks, with no spec-kit-core file modified outside `extension.yml` (REQ-CN-001, REQ-IF-003, REQ-IF-005; SYS-011; ARCH-015; MOD-020; ATP-003-A; HAZ-011, HAZ-018; D-007). **Depends on**: T019.
- [x] T024 Add structural pytest `tests/structural/test_canonical_id_closure.py` re-running the hallucination-guard invariant of **D-008** over every Markdown artefact under `commands/` and `specs/<feature>/` (excluding `v-model/`); zero unknown IDs permitted (REQ-023, REQ-NF-002, REQ-NF-004; SYS-006; ARCH-009; MOD-013, MOD-025; D-008). **Depends on**: T016, T017, T018.

---

## Phase 9: Integration tests

**Purpose**: ITP-level tests that exercise each command end-to-end against the fixture set from T002, but without the LLM tree (mock or replay where needed). One per user story.

- [x] T025 [P] [US2] `tests/integration/test_v_model_plan.bats` replays Walkthrough 1 of `quickstart.md` against `tests/fixtures/v-model/complete/`: invoke `/speckit.v-model.plan`, assert `plan.md` produced and round-trips through unmodified `speckit.tasks` (ITP-001-A, ITP-002-A; ATP-001-A, ATP-002-A; SCN-001-A1, SCN-002-A1). **Depends on**: T017, T019, T020.
- [x] T026 [P] [US3] `tests/integration/test_v_model_tasks.bats` replays Walkthrough 2: invoke `/speckit.v-model.tasks`, assert TDD ordering, hazard priority bump, and per-HAZ verification task in synthesised `tasks.md` (ITP-003-A, ITP-004-A; ATP-011-A, ATP-014-B; SCN-011-A1, SCN-014-B1). **Depends on**: T018, T019, T021.
- [x] T027 [P] [US1] `tests/integration/test_v_model_implement.bats` replays Walkthrough 3: gate refusal then pass, target-source-file mapping, sentinel-block presence, four-level test emission, commit-subject suffix, and idempotent re-run (ITP-005-A, ITP-006-A, ITP-007-A, ITP-008-A; ATP-015-A, ATP-016-A, ATP-016-B, ATP-017-A, ATP-018-A, ATP-019-A, ATP-020-A, ATP-021-A; SCN-015-A1, SCN-016-A1, SCN-016-B1, SCN-017-A1, SCN-018-A1, SCN-019-A1, SCN-020-A1, SCN-021-A1). **Depends on**: T016, T019, T022.

---

## Phase 10: System & acceptance tests

- [x] T028 [US4] System-test harness `tests/system/run_stp_suite.sh` exercises the full STP set (STP-001-A through STP-015-A as enumerated in `v-model/system-test.md`) against the fixture corpus; CI-gated to 100% pass per Principle II (REQ-NF-001, REQ-CN-001; SYS-005, SYS-011; STP-001-A, STP-002-A, STP-011-A, STP-012-A, STP-013-A, STP-014-A, STP-015-A; ITS-001-A1, ITS-002-A1; D-001). **Depends on**: T025, T026, T027.
- [x] T029 Acceptance-test harness `tests/acceptance/run_atp_suite.sh` executes the full 53-ATP / 54-SCN matrix from `v-model/acceptance-plan.md`, asserts traceability-matrix completeness (Matrix A+B+C+D+H), and emits a single PASS/FAIL summary; gates the merge per **SC-008** (REQ-NF-001, REQ-NF-003; SYS-004, SYS-012; ATP-001-A, ATP-003-A, ATP-007-A, ATP-009-A, ATP-010-A; STS-001-A1; UTS-001-A1; D-008). **Depends on**: T028.

---

## Phase 11: Polish — docs, changelog, release notes

- [x] T030 [P] Update `README.md`, `docs/extensions.md` (or equivalent), and add `docs/commands/v-model-{plan,tasks,implement}.md` reference pages summarising each command's inputs, outputs, exit codes, and structured-summary grammar (REQ-IF-004, REQ-027; SYS-012; ARCH-016; MOD-021; D-001).
- [x] T031 [P] Add `CHANGELOG.md` entry under v0.7.0: list the 3 commands + 4 scripts + PS mirrors + 3 hook entries; net-new Python = 0 lines; reference the frozen V-Model artifact set commit `618d706` (REQ-CN-001; D-001, D-002).
- [x] T032 Author release notes / migration guide `docs/releases/v0.7.0.md`: cover the four-stack coverage gate, the hallucination-guard invariant (D-008), the sentinel-managed-region contract for re-runs (D-015, D-016), and PowerShell parity (D-009); link Walkthroughs 1–3 of `quickstart.md` (REQ-NF-001, REQ-NF-005, REQ-NF-006; HAZ-014, HAZ-020, HAZ-025; D-001, D-005, D-008, D-009, D-015, D-016).

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: no deps.
- **Phase 2 (RED)**: depends on Phase 1; **must be RED-confirmed before Phase 3**.
- **Phase 3 (GREEN)**: each script depends on its matching RED suite (T008←T004; T009←T005; T010←T006; T011←T007).
- **Phase 4 (PS parity)**: each PS task depends on its Bash counterpart (T012←T008; T013←T009; T014←T010; T015←T011).
- **Phase 5 (Command prompts)**: T016 depends on T008, T009, T010; T017 + T018 depend on T011.
- **Phase 6 (Hook)**: T019 depends on T016, T017, T018.
- **Phase 7 (Evals)**: T020 ← T017; T021 ← T018; T022 ← T016.
- **Phase 8 (Validators)**: T023 ← T019; T024 ← T016, T017, T018.
- **Phase 9 (Integration)**: T025 ← T017, T019, T020; T026 ← T018, T019, T021; T027 ← T016, T019, T022.
- **Phase 10 (System+Accept)**: T028 ← T025, T026, T027; T029 ← T028.
- **Phase 11 (Polish)**: depends on Phase 10 complete.

### User Story Dependencies (informational)

- **US1 (P1, `v-model.implement`)** is the MVP. After Phase 1 + 2 + 3, the MVP slice is: T016 → T019 → T022 → T027 → T029.
- **US2 (P2, `v-model.plan`)**: T017 → T019 → T020 → T025 → T029.
- **US3 (P2, `v-model.tasks`)**: T018 → T019 → T021 → T026 → T029.
- **US4 (P3, free mixing)**: emerges from T019 + T023 + T028; no story-specific implementation tasks beyond the hook entry.

### Parallel Opportunities

- T001/T002/T003 in Phase 1 — independent files.
- T004/T005/T006/T007 in Phase 2 — different `.bats` files, no shared state.
- T012/T013/T014/T015 in Phase 4 — different `.ps1` + `.Tests.ps1` files.
- T017 + T018 in Phase 5 — different `commands/*.md` files (T016 is sequenced after the gate scripts but is otherwise independent of T017/T018).
- T020/T021/T022 in Phase 7 — different `tests/evals/*.py` files.
- T025/T026/T027 in Phase 9 — different `tests/integration/*.bats` files.
- T030/T031 in Phase 11 — different docs.

---

## Implementation Strategy

### MVP first (User Story 1 — `v-model.implement`)

1. Phase 1 (T001–T003).
2. Phase 2 — RED for T004, T005, T006 (gate, guard, splicer; the three scripts US1 needs).
3. Phase 3 — GREEN for T008, T009, T010.
4. Phase 4 — PS mirrors T012, T013, T014.
5. Phase 5 — T016 (`commands/implement.md`).
6. Phase 6 — T019 (hook entry for `implement` only is the minimum to ship).
7. Phase 7 — T022 (eval coverage).
8. Phase 9 — T027 (integration replay of Walkthrough 3).
9. **STOP and VALIDATE**: SCN-015-A1 through SCN-021-A1 must pass.

### Incremental delivery

1. MVP (US1) → demo Walkthrough 3 of `quickstart.md`.
2. Add T007 (RED) → T011 (GREEN) → T015 (PS) → T017 (`commands/plan.md`) → T020 → T025 → demo Walkthrough 1.
3. Add T018 (`commands/tasks.md`) → T021 → T026 → demo Walkthrough 2.
4. T023 + T024 + T028 + T029 → green CI gate.
5. T030/T031/T032 → release.

### Parallel team strategy

After Phase 3 GREEN, three pairs can work concurrently:

- Pair A: US1 → T016, T022, T027.
- Pair B: US2 → T017, T020, T025.
- Pair C: US3 → T018, T021, T026.

T019 (hook entry) is the synchronisation point; T028/T029 collect the four-stack 100% coverage signal.

---

## Notes

- Every task cites at least one canonical V-Model ID (REQ/SYS/ARCH/MOD/UTP/ITP/STP/ATP/SCN/HAZ) drawn from `specs/007-bridge-commands/v-model/` or a research decision (D-001 … D-016) from `specs/007-bridge-commands/research.md`.
- Net-new Python: 0 source files. The only `.py` files added are under `tests/evals/` and `tests/structural/` (test-only; no runtime delivery).
- Per **D-006** the four BATS suites in Phase 2 MUST be RED before any script body is written; per **D-007** the YAML hook entries in Phase 6 are added after the prompts and scripts they reference exist.
- Per **D-008** every cited ID in this `tasks.md` was validated by a deterministic `comm -23` against the canonical-ID set extracted from `specs/007-bridge-commands/v-model/*.md` ∪ research-decision IDs from `specs/007-bridge-commands/research.md`. Result: **0 unknown IDs**.
- The 3 deferred-risk ARCH contracts (ARCH-019, ARCH-020, ARCH-021) and 3 deferred MOD entries (MOD-024, MOD-026, MOD-027) are intentionally NOT cited by any task — they exist in the V-Model artifact set as risk-tracking IDs only and have no functional contract in v0.7.0 (per `plan.md` §Project Structure and research.md D-002).
