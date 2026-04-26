# Unit Test Plan: Bridge Commands (007)

**Feature Branch**: `feature/007-bridge-commands`
**Created**: 2026-04-26
**Status**: Draft
**Source**: `specs/007-bridge-commands/v-model/module-design.md`

## Overview

This document defines the Unit Test Plan for the **Bridge Commands** feature
(`/speckit.v-model.plan`, `/speckit.v-model.tasks`, `/speckit.v-model.implement`).
Every module (`MOD-NNN`) in `module-design.md` has at least one Test Case
(`UTP-NNN-X`), and every Test Case has at least one executable Unit Scenario
(`UTS-NNN-X#`) in white-box Arrange/Act/Assert format.

Unit tests verify **internal module logic** — control flow, data transformations,
state transitions, and variable boundaries inside individual modules. They do NOT
test module boundaries (covered by `integration-test.md`), user journeys (covered
by `acceptance-plan.md`), or system-level behavior (covered by `system-test.md`).

**No domain overlay** is configured (`v-model-config.yml` absent) → safety-critical
techniques (MC/DC Coverage, Variable-Level Fault Injection) are **skipped** per
ISO/IEC/IEEE 29119-4:2021 base profile rules.

## ID Schema

- **Unit Test Case**: `UTP-{NNN}-{X}` — NNN matches the parent MOD; X is a letter
  suffix encoding the technique:
  - `-A` → Statement & Branch Coverage (one per MOD, mandatory)
  - `-B` → Boundary Value Analysis or Equivalence Partitioning (data-driven)
  - `-C` → Strict Isolation (MODs with external dependencies)
  - `-D` → State Transition Testing (stateful modules only)
- **Unit Test Scenario**: `UTS-{NNN}-{X}{#}` — nested under the parent UTP, with
  numeric suffix.
- Example: `UTS-001-A1` → Scenario 1 of Test Case A verifying MOD-001.
- ID lineage: from `UTS-001-A1`, regex extracts `UTP-001-A` and `MOD-001`. To find
  the `ARCH-NNN` ancestor, consult the **Parent Architecture Modules** field in
  `module-design.md`.

## ISO 29119-4 White-Box Techniques

Each test case names its technique and anchors to a specific module design view.

| Technique | Source View | What It Tests |
|-----------|------------|---------------|
| **Statement & Branch Coverage** | Algorithmic/Logic View | Every line and every True/False branch outcome |
| **Boundary Value Analysis** | Internal Data Structures | Scalar variable boundaries: min-1, min, mid, max, max+1 |
| **Equivalence Partitioning** | Internal Data Structures | Discrete non-scalar types: Booleans, Enums |
| **Strict Isolation** | Architecture Interface View | Every external dependency mocked/stubbed |
| **State Transition Testing** | State Machine View | Every transition including invalid ones |

<!-- SAFETY-CRITICAL TECHNIQUES: Skipped — no domain overlay configured. -->

## Unit Tests

---

### Module: MOD-001 (Plan Synthesis Orchestrator — `run`)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `src/v_model_extension/commands/plan.py`

#### Test Case: UTP-001-A (Orchestration control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every branch of the LOAD→VALIDATE→ENRICH→EMIT→REPORT pipeline including the validation-failure short-circuit and the optional overlay branch.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `MOD-024 load_artifacts` | ARCH Interface View | Stub: returns canned artifact bundle | Isolate orchestrator from filesystem |
| `MOD-017 validate_plan_schema` | ARCH Interface View | Stub: returns `(ok, errors)` tuple | Drive validation branches deterministically |
| `MOD-002 emit_canonical_outputs` | ARCH Interface View | Spy: record call & args | Verify emission step occurs only on validation success |
| `MOD-015 apply_overlay` | ARCH Interface View | Stub: returns enriched plan | Drive overlay-present branch |
| `MOD-021 emit_summary` | ARCH Interface View | Spy: capture summary payload | Verify report step always runs |

* **Unit Scenario: UTS-001-A1** (happy-path true-branch)
  * **Arrange**: All stubs return success; `overlay_present = False`.
  * **Act**: Call `run(feature_dir="/tmp/specs/007")`.
  * **Assert**: Returns `exit_code = 0`; `emit_canonical_outputs` spy called exactly once; `apply_overlay` spy not called.
* **Unit Scenario: UTS-001-A2** (validation-failure short-circuit)
  * **Arrange**: `validate_plan_schema` stub returns `(False, ["E001"])`.
  * **Act**: Call `run(feature_dir="/tmp/specs/007")`.
  * **Assert**: Returns `exit_code = 2`; `emit_canonical_outputs` spy NOT called; `emit_summary` spy called with `status="validation_failed"`.
* **Unit Scenario: UTS-001-A3** (overlay-present branch)
  * **Arrange**: `overlay_present = True`; all stubs succeed.
  * **Act**: Call `run(...)`.
  * **Assert**: `apply_overlay` spy called exactly once before `emit_canonical_outputs` spy.

#### Test Case: UTP-001-B (Artifact-bundle size boundaries)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Boundary-test the internal `artifact_count` integer (valid range 1..1000) used to size the in-memory bundle.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Same registry as UTP-001-A | — | — | Inherits orchestrator dependencies |

* **Unit Scenario: UTS-001-B1** (min-1 = 0)
  * **Arrange**: Stub `load_artifacts` returns empty bundle (`artifact_count = 0`).
  * **Act**: Call `run(...)`.
  * **Assert**: Raises `EmptyBundleError`; `exit_code = 3`.
* **Unit Scenario: UTS-001-B2** (min = 1)
  * **Arrange**: Stub returns 1-item bundle.
  * **Act**: Call `run(...)`.
  * **Assert**: Returns `exit_code = 0`; bundle accepted.
* **Unit Scenario: UTS-001-B3** (mid = 50)
  * **Arrange**: Stub returns 50-item bundle.
  * **Act**: Call `run(...)`.
  * **Assert**: Returns `exit_code = 0`.
* **Unit Scenario: UTS-001-B4** (max = 1000)
  * **Arrange**: Stub returns 1000-item bundle.
  * **Act**: Call `run(...)`.
  * **Assert**: Returns `exit_code = 0`.
* **Unit Scenario: UTS-001-B5** (max+1 = 1001)
  * **Arrange**: Stub returns 1001-item bundle.
  * **Act**: Call `run(...)`.
  * **Assert**: Raises `BundleTooLargeError`; `exit_code = 4`.

#### Test Case: UTP-001-C (External dependency isolation)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Confirm orchestrator never touches real filesystem, subprocess, or git layer when all collaborators are mocked.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `MOD-027 atomic_write` | ARCH Interface View | Spy: capture (path, bytes) | Confirm no real disk write |
| `MOD-026 run_subprocess` | ARCH Interface View | Stub: returns `(0, "", "")` | Confirm no real shell exec |
| `MOD-024 load_artifacts` | ARCH Interface View | Stub: returns in-memory bundle | Confirm no real disk read |

* **Unit Scenario: UTS-001-C1** (filesystem isolation)
  * **Arrange**: All MOD-027 / MOD-026 / MOD-024 collaborators replaced with spies.
  * **Act**: Call `run(...)` with valid input.
  * **Assert**: `atomic_write` spy received N calls; no real file appears under `/tmp/specs/007/`.
* **Unit Scenario: UTS-001-C2** (subprocess isolation)
  * **Arrange**: `run_subprocess` spy raises `AssertionError("real subprocess invoked")` if called outside allowed list.
  * **Act**: Call `run(...)`.
  * **Assert**: No assertion fires; spy invoked only with allowed verbs.

#### Test Case: UTP-001-D (Lifecycle state transitions)

**Technique**: State Transition Testing
**Target View**: State Machine View
**Description**: Exercise every transition in the LOAD→VALIDATE→ENRICH→EMIT→REPORT state diagram and reject illegal transitions.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Same registry as UTP-001-A | — | — | Inherits orchestrator dependencies |

* **Unit Scenario: UTS-001-D1** (valid transition LOAD → VALIDATE)
  * **Arrange**: Initialize state machine in `LOAD`; stub returns valid bundle.
  * **Act**: Send `bundle_loaded` event.
  * **Assert**: State transitions to `VALIDATE`; entry action invokes `validate_plan_schema` once.
* **Unit Scenario: UTS-001-D2** (terminal transition EMIT → REPORT)
  * **Arrange**: Initialize state machine in `EMIT`; stub `emit_canonical_outputs` returns success.
  * **Act**: Send `emit_complete` event.
  * **Assert**: State transitions to `REPORT`; cleanup action releases bundle reference.
* **Unit Scenario: UTS-001-D3** (invalid transition LOAD → REPORT)
  * **Arrange**: Initialize state machine in `LOAD`.
  * **Act**: Send `report_now` event (no transition defined from LOAD).
  * **Assert**: State remains `LOAD`; `InvalidTransitionError` raised.

---

### Module: MOD-002 (`emit_canonical_outputs`)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `src/v_model_extension/emit/canonical.py`

#### Test Case: UTP-002-A (Canonical emission control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise the per-artifact iteration loop including the schema-version branch and the missing-section guard.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `MOD-027 atomic_write` | ARCH Interface View | Spy: capture (path, bytes) | Avoid real disk |

* **Unit Scenario: UTS-002-A1** (true-branch: schema_version present)
  * **Arrange**: Plan dict has `schema_version = "1.0"`.
  * **Act**: Call `emit_canonical_outputs(plan, out_dir="/tmp/x")`.
  * **Assert**: `atomic_write` spy invoked with header containing `schema_version: "1.0"`.
* **Unit Scenario: UTS-002-A2** (false-branch: schema_version absent → default)
  * **Arrange**: Plan dict missing `schema_version` key.
  * **Act**: Call `emit_canonical_outputs(plan, out_dir="/tmp/x")`.
  * **Assert**: Spy receives header with default `schema_version: "0.1"`.
* **Unit Scenario: UTS-002-A3** (loop zero iterations)
  * **Arrange**: Plan with empty `artifacts` list.
  * **Act**: Call function.
  * **Assert**: Spy never invoked; returns empty `written_paths` list.

#### Test Case: UTP-002-B (Output payload size boundaries)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Boundary-test the internal `payload_bytes` (valid 1..10_485_760 = 10 MiB).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `MOD-027 atomic_write` | ARCH Interface View | Spy | — |

* **Unit Scenario: UTS-002-B1** (min-1 = 0): Arrange empty payload; Act call; Assert raises `EmptyPayloadError`.
* **Unit Scenario: UTS-002-B2** (min = 1): Arrange 1-byte payload; Act call; Assert spy called once.
* **Unit Scenario: UTS-002-B3** (mid = 65536): Arrange 64 KiB payload; Act call; Assert spy called once.
* **Unit Scenario: UTS-002-B4** (max = 10_485_760): Arrange 10 MiB payload; Act call; Assert spy called once.
* **Unit Scenario: UTS-002-B5** (max+1 = 10_485_761): Arrange 10 MiB+1 payload; Act call; Assert raises `PayloadTooLargeError`.

#### Test Case: UTP-002-C (Filesystem dependency isolation)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Confirm `emit_canonical_outputs` writes only via `MOD-027 atomic_write` and never via raw `open()`.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `MOD-027 atomic_write` | ARCH Interface View | Spy | Capture all writes |
| `builtins.open` | (forbidden) | Patch to raise | Detect leakage |

* **Unit Scenario: UTS-002-C1** (no raw open): Arrange `builtins.open` patched to raise `RuntimeError`; Act call function; Assert function completes; no `RuntimeError` propagated.
* **Unit Scenario: UTS-002-C2** (single write path): Arrange spy; Act call; Assert all spy invocations have `path.startswith(out_dir)`.

---

### Module: MOD-003 (Tasks Synthesis Orchestrator — `run`)

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `src/v_model_extension/commands/tasks.py`

#### Test Case: UTP-003-A (Tasks orchestration control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise BUILD→HAZARD_ENRICH→VALIDATE→EMIT branches including hazard-overlay-absent fallback.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `MOD-004 build_tdd_task_list` | ARCH Interface View | Stub: returns task list | Isolate sequencing |
| `MOD-016 enrich_with_hazards` | ARCH Interface View | Stub: returns enriched list | Drive hazard branch |
| `MOD-018 validate_tasks_schema` | ARCH Interface View | Stub: `(ok, errors)` | Drive validation branches |
| `MOD-002 emit_canonical_outputs` | ARCH Interface View | Spy | — |

* **Unit Scenario: UTS-003-A1** (overlay-absent branch): Arrange `overlay_present = False`; Act call `run(...)`; Assert `enrich_with_hazards` NOT called; tasks emitted unchanged.
* **Unit Scenario: UTS-003-A2** (overlay-present branch): Arrange `overlay_present = True`; Act call; Assert `enrich_with_hazards` called once between build and validate.
* **Unit Scenario: UTS-003-A3** (validation-failure short-circuit): Arrange validate stub returns `(False, ["E007"])`; Act call; Assert `emit_canonical_outputs` NOT called; exit_code = 2.

#### Test Case: UTP-003-B (Task-count boundaries)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Boundary-test the internal `task_count` (valid 1..500).

**Dependency & Mock Registry:** Same as UTP-003-A.

* **Unit Scenario: UTS-003-B1** (min-1 = 0): Arrange empty task list; Act call; Assert raises `EmptyTaskListError`.
* **Unit Scenario: UTS-003-B2** (min = 1): Arrange 1 task; Act call; Assert exit_code = 0.
* **Unit Scenario: UTS-003-B3** (mid = 100): Arrange 100 tasks; Act call; Assert exit_code = 0.
* **Unit Scenario: UTS-003-B4** (max = 500): Arrange 500 tasks; Act call; Assert exit_code = 0.
* **Unit Scenario: UTS-003-B5** (max+1 = 501): Arrange 501 tasks; Act call; Assert raises `TaskListTooLargeError`.

#### Test Case: UTP-003-C (Collaborator isolation)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Confirm orchestrator never reaches real disk or git.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `MOD-027 atomic_write` | ARCH Interface View | Spy | — |
| `MOD-024 load_artifacts` | ARCH Interface View | Stub | — |

* **Unit Scenario: UTS-003-C1**: Arrange spies; Act `run(...)`; Assert `atomic_write` invoked only with paths under `out_dir`.
* **Unit Scenario: UTS-003-C2**: Arrange `load_artifacts` patched to raise if called more than once; Act `run(...)`; Assert no exception (single read).

#### Test Case: UTP-003-D (Lifecycle state transitions)

**Technique**: State Transition Testing
**Target View**: State Machine View
**Description**: Cover BUILD→HAZARD_ENRICH→VALIDATE→EMIT and invalid skip.

**Dependency & Mock Registry:** Same as UTP-003-A.

* **Unit Scenario: UTS-003-D1** (valid transition BUILD → HAZARD_ENRICH with overlay): Arrange state `BUILD`, overlay_present=true; Act `tasks_built` event; Assert state `HAZARD_ENRICH`.
* **Unit Scenario: UTS-003-D2** (valid skip BUILD → VALIDATE without overlay): Arrange state `BUILD`, overlay_present=false; Act `tasks_built` event; Assert state `VALIDATE`.
* **Unit Scenario: UTS-003-D3** (invalid transition BUILD → EMIT): Arrange state `BUILD`; Act `emit_now` event; Assert state remains `BUILD`; `InvalidTransitionError`.

---

### Module: MOD-004 (`build_tdd_task_list`)

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `src/v_model_extension/tasks/sequencer.py`

#### Test Case: UTP-004-A (TDD ordering control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise the test-before-impl invariant including the empty-test-set branch.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-004-A1** (true-branch: tests precede impl): Arrange artifact list with 3 UTPs and 3 MODs; Act call `build_tdd_task_list(artifacts)`; Assert resulting list has every UTP-task at index < its MOD-task.
* **Unit Scenario: UTS-004-A2** (false-branch: empty test set): Arrange artifact list with 0 UTPs; Act call; Assert raises `MissingTestArtifactsError`.
* **Unit Scenario: UTS-004-A3** (loop one iteration): Arrange single (UTP, MOD) pair; Act call; Assert returns 2-element list `[UTP_task, MOD_task]`.

#### Test Case: UTP-004-B (Test/impl pair count boundaries)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Boundary-test internal `pair_count` (valid 1..200).

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-004-B1** (min-1 = 0): Arrange 0 pairs; Act call; Assert raises `EmptyPairListError`.
* **Unit Scenario: UTS-004-B2** (min = 1): Arrange 1 pair; Act call; Assert returns 2-task list.
* **Unit Scenario: UTS-004-B3** (mid = 50): Arrange 50 pairs; Act call; Assert returns 100-task list ordered.
* **Unit Scenario: UTS-004-B4** (max = 200): Arrange 200 pairs; Act call; Assert returns 400-task list.
* **Unit Scenario: UTS-004-B5** (max+1 = 201): Arrange 201 pairs; Act call; Assert raises `PairListTooLargeError`.

---

### Module: MOD-005 (Implementation Orchestrator — `run`)

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `src/v_model_extension/commands/implement.py`

#### Test Case: UTP-005-A (Implement orchestration control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise GATE→GENERATE→VERIFY→COMMIT branches including gate-block, verification-fail, and dry-run paths.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `MOD-010 evaluate_gate` | ARCH Interface View | Stub: returns gate decision enum | Drive gate branches |
| `MOD-006 generate_code` | ARCH Interface View | Stub: returns generated artifacts | Drive generation branch |
| `MOD-008 generate_tests` | ARCH Interface View | Stub: returns test artifacts | — |
| `MOD-013 verify_ids` | ARCH Interface View | Stub: returns `(ok, missing_ids)` | Drive verification branches |
| `MOD-023 annotate_commit` | ARCH Interface View | Spy | Verify commit only on success |

* **Unit Scenario: UTS-005-A1** (gate=allow → success path): Arrange gate stub returns `ALLOW`; verify stub returns `(True, [])`; Act `run(...)`; Assert `annotate_commit` spy invoked once; exit_code = 0.
* **Unit Scenario: UTS-005-A2** (gate=block short-circuit): Arrange gate stub returns `BLOCK`; Act `run(...)`; Assert `generate_code` NOT called; exit_code = 5; `annotate_commit` NOT invoked.
* **Unit Scenario: UTS-005-A3** (verify-fail branch): Arrange verify stub returns `(False, ["MOD-099"])`; Act `run(...)`; Assert `annotate_commit` NOT invoked; exit_code = 6.
* **Unit Scenario: UTS-005-A4** (dry-run branch): Arrange `dry_run = True`; Act `run(...)`; Assert all generators called; `annotate_commit` NOT invoked.

#### Test Case: UTP-005-B (Gate decision partitions)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition the `gate_decision` enum (ALLOW, WARN, BLOCK, plus invalid).

**Dependency & Mock Registry:** Same as UTP-005-A.

* **Unit Scenario: UTS-005-B1** (valid: ALLOW): Arrange gate=ALLOW; Act call; Assert pipeline proceeds.
* **Unit Scenario: UTS-005-B2** (valid: WARN): Arrange gate=WARN; Act call; Assert pipeline proceeds with warning logged.
* **Unit Scenario: UTS-005-B3** (valid: BLOCK): Arrange gate=BLOCK; Act call; Assert pipeline halts; exit_code = 5.
* **Unit Scenario: UTS-005-B4** (invalid: unknown enum): Arrange gate stub returns `"UNDEFINED"`; Act call; Assert raises `UnknownGateDecisionError`.

#### Test Case: UTP-005-C (External dependency isolation)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Confirm orchestrator never touches real git or filesystem.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `MOD-026 run_subprocess` | ARCH Interface View | Stub: returns `(0, "", "")` | Block real shell |
| `MOD-027 atomic_write` | ARCH Interface View | Spy | Block real disk |

* **Unit Scenario: UTS-005-C1** (no real subprocess): Arrange spy; Act `run(...)`; Assert all spy calls have argv[0] in allowlist `["git"]`.
* **Unit Scenario: UTS-005-C2** (no real disk): Arrange spy; Act `run(...)`; Assert all spy paths under `out_dir`.

#### Test Case: UTP-005-D (Lifecycle state transitions)

**Technique**: State Transition Testing
**Target View**: State Machine View
**Description**: Cover GATE→GENERATE→VERIFY→COMMIT transitions plus blocked-from-GATE terminal.

**Dependency & Mock Registry:** Same as UTP-005-A.

* **Unit Scenario: UTS-005-D1** (valid GATE → GENERATE): Arrange state `GATE`, gate=ALLOW; Act `gate_decided` event; Assert state `GENERATE`.
* **Unit Scenario: UTS-005-D2** (terminal GATE → BLOCKED): Arrange state `GATE`, gate=BLOCK; Act `gate_decided` event; Assert state `BLOCKED`; cleanup releases bundle.
* **Unit Scenario: UTS-005-D3** (invalid GENERATE → COMMIT skip): Arrange state `GENERATE`; Act `commit_now` event; Assert state remains `GENERATE`; `InvalidTransitionError`.

---

### Module: MOD-006 (`generate_code` — dispatcher)

**Parent Architecture Modules**: ARCH-005
**Target Source File(s)**: `src/v_model_extension/codegen/generator.py`

#### Test Case: UTP-006-A (Dispatch control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise the per-MOD dispatch loop and the unsupported-language fallback branch.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `MOD-007 render_module_source` | ARCH Interface View | Stub: returns rendered source | — |

* **Unit Scenario: UTS-006-A1** (loop zero iterations): Arrange empty MOD list; Act call `generate_code([])`; Assert returns empty dict.
* **Unit Scenario: UTS-006-A2** (loop N iterations true-branch): Arrange 3 supported MODs; Act call; Assert renderer stub invoked 3 times.
* **Unit Scenario: UTS-006-A3** (false-branch unsupported language): Arrange MOD with `language="cobol"`; Act call; Assert raises `UnsupportedLanguageError`.

#### Test Case: UTP-006-B (Language enum partitions)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition the `language` enum (python, typescript, plus invalid).

**Dependency & Mock Registry:** Same as UTP-006-A.

* **Unit Scenario: UTS-006-B1** (valid: python): Arrange MOD lang=python; Act call; Assert renderer stub called with python.
* **Unit Scenario: UTS-006-B2** (valid: typescript): Arrange MOD lang=typescript; Act call; Assert renderer stub called with typescript.
* **Unit Scenario: UTS-006-B3** (invalid: null): Arrange MOD with `language=None`; Act call; Assert raises `MissingLanguageError`.

---

### Module: MOD-007 (`render_module_source`)

**Parent Architecture Modules**: ARCH-005
**Target Source File(s)**: `src/v_model_extension/codegen/renderer.py`

#### Test Case: UTP-007-A (Source rendering control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise pseudocode-to-source translation including empty-body branch.

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-007-A1** (true-branch non-empty body): Arrange MOD with 3-line pseudocode; Act call `render_module_source(mod, "python")`; Assert returned source contains all 3 translated lines.
* **Unit Scenario: UTS-007-A2** (false-branch empty body): Arrange MOD with empty pseudocode; Act call; Assert returned source contains only signature + `pass` stub.
* **Unit Scenario: UTS-007-A3** (loop N iterations): Arrange MOD with 10 lines; Act call; Assert returned source has ≥10 non-blank lines.

#### Test Case: UTP-007-B (Generated line-count boundaries)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Boundary-test the internal `line_count` (valid 1..2000).

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-007-B1** (min-1 = 0): Arrange MOD with no signature; Act call; Assert raises `EmptyModuleError`.
* **Unit Scenario: UTS-007-B2** (min = 1): Arrange single-line stub; Act call; Assert returns 1-line source.
* **Unit Scenario: UTS-007-B3** (mid = 100): Arrange 100-line MOD; Act call; Assert returns ~100-line source.
* **Unit Scenario: UTS-007-B4** (max = 2000): Arrange 2000-line MOD; Act call; Assert returns ≤2000-line source; no truncation.
* **Unit Scenario: UTS-007-B5** (max+1 = 2001): Arrange 2001-line MOD; Act call; Assert raises `ModuleTooLargeError`.

---

### Module: MOD-008 (`generate_tests` — dispatcher)

**Parent Architecture Modules**: ARCH-006
**Target Source File(s)**: `src/v_model_extension/testgen/generator.py`

#### Test Case: UTP-008-A (Dispatch control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise per-level dispatch and unsupported-level fallback.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `MOD-009 render_test_file_for_level` | ARCH Interface View | Stub: returns rendered test file | — |

* **Unit Scenario: UTS-008-A1** (loop zero): Arrange empty plan; Act call; Assert returns empty list.
* **Unit Scenario: UTS-008-A2** (loop true-branch all 4 levels): Arrange plan with UTP/ITP/STP/ATP entries; Act call; Assert renderer stub invoked 4 times (once per level).
* **Unit Scenario: UTS-008-A3** (false-branch unknown level): Arrange plan with level="fuzz"; Act call; Assert raises `UnknownTestLevelError`.

#### Test Case: UTP-008-B (Test-level enum partitions)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition `test_level` (UTP, ITP, STP, ATP, plus invalid).

**Dependency & Mock Registry:** Same as UTP-008-A.

* **Unit Scenario: UTS-008-B1** (valid: UTP): Arrange level=UTP; Act call; Assert renderer invoked with UTP.
* **Unit Scenario: UTS-008-B2** (valid: ITP): Arrange level=ITP; Act call; Assert renderer invoked with ITP.
* **Unit Scenario: UTS-008-B3** (valid: STP): Arrange level=STP; Act call; Assert renderer invoked with STP.
* **Unit Scenario: UTS-008-B4** (valid: ATP): Arrange level=ATP; Act call; Assert renderer invoked with ATP.
* **Unit Scenario: UTS-008-B5** (invalid: empty string): Arrange level=""; Act call; Assert raises `UnknownTestLevelError`.

---

### Module: MOD-009 (`render_test_file_for_level`)

**Parent Architecture Modules**: ARCH-006
**Target Source File(s)**: `src/v_model_extension/testgen/renderer.py`

#### Test Case: UTP-009-A (Per-level rendering control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise scenario translation loop including empty-scenario fallback.

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-009-A1** (true-branch non-empty scenarios): Arrange UTP with 3 UTSs; Act call; Assert output contains 3 `def test_*` blocks.
* **Unit Scenario: UTS-009-A2** (false-branch zero scenarios): Arrange UTP with 0 UTSs; Act call; Assert raises `EmptyTestCaseError`.
* **Unit Scenario: UTS-009-A3** (loop N iterations): Arrange UTP with 10 UTSs; Act call; Assert output has ≥10 `def test_*` declarations.

#### Test Case: UTP-009-B (Scenario count boundaries)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Boundary-test internal `scenario_count` (valid 1..100).

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-009-B1** (min-1 = 0): Arrange empty scenarios; Act call; Assert raises `EmptyTestCaseError`.
* **Unit Scenario: UTS-009-B2** (min = 1): Arrange 1 scenario; Act call; Assert 1 `def test_*` block.
* **Unit Scenario: UTS-009-B3** (mid = 25): Arrange 25 scenarios; Act call; Assert 25 blocks.
* **Unit Scenario: UTS-009-B4** (max = 100): Arrange 100 scenarios; Act call; Assert 100 blocks.
* **Unit Scenario: UTS-009-B5** (max+1 = 101): Arrange 101 scenarios; Act call; Assert raises `TooManyScenariosError`.

---

### Module: MOD-010 (`evaluate_gate`)

**Parent Architecture Modules**: ARCH-007
**Target Source File(s)**: `src/v_model_extension/gate/coordinator.py`

#### Test Case: UTP-010-A (Gate evaluation control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise the coverage-threshold branch and the orphan-detected branch.

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-010-A1** (true-branch coverage≥threshold AND no orphans): Arrange `coverage=100, orphans=[]`; Act call; Assert returns `ALLOW`.
* **Unit Scenario: UTS-010-A2** (false-branch coverage<threshold): Arrange `coverage=70, orphans=[]`; Act call; Assert returns `BLOCK`.
* **Unit Scenario: UTS-010-A3** (false-branch orphans present): Arrange `coverage=100, orphans=["MOD-099"]`; Act call; Assert returns `BLOCK`.

#### Test Case: UTP-010-B (Gate status partitions)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition `gate_status` (PASS, WARN, FAIL, plus invalid sentinel).

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-010-B1** (valid: PASS): Arrange status PASS; Act call; Assert returns `ALLOW`.
* **Unit Scenario: UTS-010-B2** (valid: WARN): Arrange status WARN; Act call; Assert returns `WARN`.
* **Unit Scenario: UTS-010-B3** (valid: FAIL): Arrange status FAIL; Act call; Assert returns `BLOCK`.
* **Unit Scenario: UTS-010-B4** (invalid: None): Arrange status=None; Act call; Assert raises `InvalidGateStatusError`.

---

### Module: MOD-011 (`embed_enrichment`)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `src/v_model_extension/enrich/encoder.py`

#### Test Case: UTP-011-A (Enrichment embedding control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise tag insertion loop and the duplicate-tag rejection branch.

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-011-A1** (loop zero): Arrange empty tag list; Act call `embed_enrichment(source, [])`; Assert source returned unchanged.
* **Unit Scenario: UTS-011-A2** (true-branch new tags): Arrange 3 unique tags; Act call; Assert output contains 3 `# enrichment:` comments.
* **Unit Scenario: UTS-011-A3** (false-branch duplicate tags): Arrange 2 identical tags; Act call; Assert raises `DuplicateTagError`.

#### Test Case: UTP-011-B (Tag count boundaries)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Boundary-test internal `tag_count` (valid 0..50).

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-011-B1** (min-1 = -1, conceptually invalid): Arrange `tags=None`; Act call; Assert raises `NullTagListError`.
* **Unit Scenario: UTS-011-B2** (min = 0): Arrange `tags=[]`; Act call; Assert returns source unchanged.
* **Unit Scenario: UTS-011-B3** (mid = 25): Arrange 25 unique tags; Act call; Assert 25 enrichment comments.
* **Unit Scenario: UTS-011-B4** (max = 50): Arrange 50 unique tags; Act call; Assert 50 enrichment comments.
* **Unit Scenario: UTS-011-B5** (max+1 = 51): Arrange 51 tags; Act call; Assert raises `TooManyTagsError`.

---

### Module: MOD-012 (`embed_traceability_comments`)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `src/v_model_extension/enrich/encoder.py`

#### Test Case: UTP-012-A (Traceability embedding control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise the comment-insertion loop and the missing-ID-set fallback.

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-012-A1** (true-branch IDs present): Arrange `id_set={REQ-001, MOD-007}`; Act call; Assert source contains both IDs in header comment.
* **Unit Scenario: UTS-012-A2** (false-branch empty IDs): Arrange `id_set=set()`; Act call; Assert source contains placeholder comment `# trace: (none)`.
* **Unit Scenario: UTS-012-A3** (loop N iterations): Arrange 5 IDs; Act call; Assert all 5 appear in comment block.

#### Test Case: UTP-012-B (ID count boundaries)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Boundary-test internal `id_count` (valid 0..200).

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-012-B1** (min-1 = -1): Arrange `id_set=None`; Act call; Assert raises `NullIdSetError`.
* **Unit Scenario: UTS-012-B2** (min = 0): Arrange empty set; Act call; Assert placeholder comment present.
* **Unit Scenario: UTS-012-B3** (mid = 100): Arrange 100 IDs; Act call; Assert all 100 appear.
* **Unit Scenario: UTS-012-B4** (max = 200): Arrange 200 IDs; Act call; Assert all 200 appear.
* **Unit Scenario: UTS-012-B5** (max+1 = 201): Arrange 201 IDs; Act call; Assert raises `TooManyTraceIdsError`.

---

### Module: MOD-013 (`verify_ids`)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `src/v_model_extension/guard/hallucination.py`

#### Test Case: UTP-013-A (ID verification control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise the per-ID lookup loop including the not-found branch.

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-013-A1** (true-branch all IDs found): Arrange `referenced={REQ-001}, valid={REQ-001}`; Act call; Assert returns `(True, [])`.
* **Unit Scenario: UTS-013-A2** (false-branch missing ID): Arrange `referenced={REQ-999}, valid={REQ-001}`; Act call; Assert returns `(False, ["REQ-999"])`.
* **Unit Scenario: UTS-013-A3** (loop zero iterations): Arrange `referenced=set()`; Act call; Assert returns `(True, [])`.

#### Test Case: UTP-013-B (ID validity partitions)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition the `id_validity` discrete classes (well-formed-known, well-formed-unknown, malformed).

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-013-B1** (well-formed-known): Arrange `referenced={MOD-001}, valid={MOD-001}`; Act call; Assert `(True, [])`.
* **Unit Scenario: UTS-013-B2** (well-formed-unknown): Arrange `referenced={MOD-555}, valid={MOD-001}`; Act call; Assert `(False, ["MOD-555"])`.
* **Unit Scenario: UTS-013-B3** (malformed): Arrange `referenced={"FOO-bar"}, valid={MOD-001}`; Act call; Assert raises `MalformedIdError`.

---

### Module: MOD-014 (`splice_managed_regions`)

**Parent Architecture Modules**: ARCH-010
**Target Source File(s)**: `src/v_model_extension/codegen/splicer.py`

#### Test Case: UTP-014-A (Region splicing control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise managed-region detection loop including the no-region-found branch.

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-014-A1** (true-branch region present): Arrange source with `# BEGIN MANAGED ... # END MANAGED`; Act call `splice_managed_regions(source, new_block)`; Assert region replaced verbatim.
* **Unit Scenario: UTS-014-A2** (false-branch no region marker): Arrange source without markers; Act call; Assert raises `MissingManagedRegionError`.
* **Unit Scenario: UTS-014-A3** (loop N iterations multiple regions): Arrange source with 3 named regions; Act call passing block per region; Assert all 3 regions replaced.

#### Test Case: UTP-014-B (Region count boundaries)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Boundary-test internal `region_count` (valid 1..20).

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-014-B1** (min-1 = 0): Arrange source with 0 regions; Act call; Assert raises `MissingManagedRegionError`.
* **Unit Scenario: UTS-014-B2** (min = 1): Arrange 1 region; Act call; Assert 1 region replaced.
* **Unit Scenario: UTS-014-B3** (mid = 10): Arrange 10 regions; Act call; Assert all 10 replaced.
* **Unit Scenario: UTS-014-B4** (max = 20): Arrange 20 regions; Act call; Assert all 20 replaced.
* **Unit Scenario: UTS-014-B5** (max+1 = 21): Arrange 21 regions; Act call; Assert raises `TooManyRegionsError`.

---

### Module: MOD-015 (`apply_overlay`)

**Parent Architecture Modules**: ARCH-011
**Target Source File(s)**: `src/v_model_extension/overlay/loader.py`

#### Test Case: UTP-015-A (Overlay application control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise overlay-merge branch and overlay-absent fallback branch.

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-015-A1** (true-branch overlay present): Arrange `overlay={domain: "iso_26262"}`; Act call `apply_overlay(plan, overlay)`; Assert returned plan has `domain="iso_26262"` field.
* **Unit Scenario: UTS-015-A2** (false-branch overlay None): Arrange `overlay=None`; Act call; Assert returned plan equals input plan unchanged.
* **Unit Scenario: UTS-015-A3** (true-branch deep merge): Arrange overlay with nested keys; Act call; Assert nested merge preserved per layer.

#### Test Case: UTP-015-B (Overlay-present partition)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition the `overlay_present` boolean.

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-015-B1** (valid: True): Arrange `overlay={...}`; Act call; Assert `overlay_present` flag in result is `True`.
* **Unit Scenario: UTS-015-B2** (valid: False): Arrange `overlay=None`; Act call; Assert flag is `False`.
* **Unit Scenario: UTS-015-B3** (invalid: malformed dict): Arrange `overlay="not-a-dict"`; Act call; Assert raises `InvalidOverlayTypeError`.

---

### Module: MOD-016 (`enrich_with_hazards`)

**Parent Architecture Modules**: ARCH-012
**Target Source File(s)**: `src/v_model_extension/tasks/hazards.py`

#### Test Case: UTP-016-A (Hazard enrichment control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise hazard-tag insertion loop including the unknown-hazard fallback branch.

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-016-A1** (true-branch known hazards): Arrange tasks list and `hazard_map={MOD-007: ["HAZ-001"]}`; Act call; Assert task for MOD-007 has `hazards=["HAZ-001"]` field.
* **Unit Scenario: UTS-016-A2** (false-branch empty hazard map): Arrange `hazard_map={}`; Act call; Assert all tasks have `hazards=[]`.
* **Unit Scenario: UTS-016-A3** (loop N iterations): Arrange 5 tasks each with 2 hazards; Act call; Assert each task has 2 hazard entries.

#### Test Case: UTP-016-B (Hazard-overlay-present partition)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition `hazard_overlay_loaded` boolean.

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-016-B1** (valid: True with entries): Arrange overlay loaded; Act call; Assert tasks enriched.
* **Unit Scenario: UTS-016-B2** (valid: False): Arrange overlay not loaded; Act call; Assert tasks unchanged; logs `"hazard_overlay=missing"`.
* **Unit Scenario: UTS-016-B3** (invalid: corrupted overlay object): Arrange overlay set to integer; Act call; Assert raises `InvalidHazardOverlayError`.

---

### Module: MOD-017 (`validate_plan_schema`)

**Parent Architecture Modules**: ARCH-013
**Target Source File(s)**: `src/v_model_extension/schema/validator.py`

#### Test Case: UTP-017-A (Plan schema validation control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise the per-field validation loop including the missing-required-field branch.

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-017-A1** (true-branch valid plan): Arrange complete plan dict; Act call; Assert returns `(True, [])`.
* **Unit Scenario: UTS-017-A2** (false-branch missing required field): Arrange plan missing `schema_version`; Act call; Assert returns `(False, ["missing: schema_version"])`.
* **Unit Scenario: UTS-017-A3** (loop N iterations all fields validated): Arrange plan with 10 fields; Act call; Assert internal counter equals 10.

#### Test Case: UTP-017-B (Plan validity partitions)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition `plan_validity` (well-formed, missing-field, type-mismatch).

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-017-B1** (well-formed): Arrange valid plan; Act call; Assert `(True, [])`.
* **Unit Scenario: UTS-017-B2** (missing-field): Arrange plan missing `artifacts`; Act call; Assert `(False, [...])`.
* **Unit Scenario: UTS-017-B3** (type-mismatch): Arrange plan with `artifacts="not-a-list"`; Act call; Assert `(False, ["type_mismatch: artifacts"])`.

---

### Module: MOD-018 (`validate_tasks_schema`)

**Parent Architecture Modules**: ARCH-013
**Target Source File(s)**: `src/v_model_extension/schema/validator.py`

#### Test Case: UTP-018-A (Tasks schema validation control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise the per-task validation loop and the duplicate-task-id branch.

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-018-A1** (true-branch valid tasks): Arrange list of 3 unique tasks; Act call; Assert `(True, [])`.
* **Unit Scenario: UTS-018-A2** (false-branch duplicate task id): Arrange 2 tasks with same id; Act call; Assert `(False, ["duplicate: T-001"])`.
* **Unit Scenario: UTS-018-A3** (loop zero iterations): Arrange empty task list; Act call; Assert `(False, ["empty"])`.

#### Test Case: UTP-018-B (Tasks validity partitions)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition `tasks_validity` (well-formed, duplicate-id, missing-id).

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-018-B1** (well-formed): Arrange unique well-typed tasks; Act call; Assert `(True, [])`.
* **Unit Scenario: UTS-018-B2** (duplicate-id): Arrange duplicates; Act call; Assert `(False, [...])`.
* **Unit Scenario: UTS-018-B3** (missing-id): Arrange task without id; Act call; Assert `(False, ["missing_id"])`.

---

### Module: MOD-019 (`detect_enrichment`)

**Parent Architecture Modules**: ARCH-014
**Target Source File(s)**: `src/v_model_extension/schema/fallback.py`

#### Test Case: UTP-019-A (Enrichment-detection control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise enrichment-marker scan loop and the no-marker fallback.

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-019-A1** (true-branch marker present): Arrange source with `# enrichment: HAZ-001`; Act call; Assert returns `True`.
* **Unit Scenario: UTS-019-A2** (false-branch marker absent): Arrange source without marker; Act call; Assert returns `False`.
* **Unit Scenario: UTS-019-A3** (loop N iterations multiple markers): Arrange source with 3 markers; Act call; Assert returns `True`; internal counter equals 3.

#### Test Case: UTP-019-B (Enrichment-found partition)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition `enrichment_found` boolean.

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-019-B1** (valid: True): Arrange marker present; Act call; Assert `True`.
* **Unit Scenario: UTS-019-B2** (valid: False): Arrange marker absent; Act call; Assert `False`.
* **Unit Scenario: UTS-019-B3** (invalid: source=None): Arrange `source=None`; Act call; Assert raises `NullSourceError`.

---

### Module: MOD-020 (`register_hooks`)

**Parent Architecture Modules**: ARCH-015
**Target Source File(s)**: `src/v_model_extension/hooks/registrar.py`

#### Test Case: UTP-020-A (Hook registration control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise per-hook registration loop and the duplicate-name rejection branch.

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-020-A1** (true-branch unique hooks): Arrange 3 unique hook descriptors; Act call `register_hooks(registry, hooks)`; Assert registry contains 3 entries.
* **Unit Scenario: UTS-020-A2** (false-branch duplicate name): Arrange 2 hooks with same name; Act call; Assert raises `DuplicateHookError`.
* **Unit Scenario: UTS-020-A3** (loop zero): Arrange empty hook list; Act call; Assert registry unchanged.

#### Test Case: UTP-020-B (Hook-kind enum partitions)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition the `hook_kind` enum (pre, post, on_error, plus invalid).

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-020-B1** (valid: pre): Arrange hook kind=pre; Act call; Assert registered under `pre` slot.
* **Unit Scenario: UTS-020-B2** (valid: post): Arrange hook kind=post; Act call; Assert registered under `post` slot.
* **Unit Scenario: UTS-020-B3** (valid: on_error): Arrange hook kind=on_error; Act call; Assert registered under `on_error` slot.
* **Unit Scenario: UTS-020-B4** (invalid: unknown): Arrange hook kind=`"middle"`; Act call; Assert raises `UnknownHookKindError`.

---

### Module: MOD-021 (`emit_summary`)

**Parent Architecture Modules**: ARCH-016
**Target Source File(s)**: `src/v_model_extension/report/summary.py`

#### Test Case: UTP-021-A (Summary emission control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise per-section assembly loop and the verbose-mode branch.

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-021-A1** (true-branch verbose=True): Arrange status report with details; Act call `emit_summary(report, verbose=True)`; Assert output contains `# Detailed:` section.
* **Unit Scenario: UTS-021-A2** (false-branch verbose=False): Arrange same report; Act call with verbose=False; Assert output omits `# Detailed:` section.
* **Unit Scenario: UTS-021-A3** (loop zero sections): Arrange empty report; Act call; Assert output equals stub `"(no data)"`.

#### Test Case: UTP-021-B (Section count boundaries)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Boundary-test internal `section_count` (valid 0..20).

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-021-B1** (min-1 = -1): Arrange `report=None`; Act call; Assert raises `NullReportError`.
* **Unit Scenario: UTS-021-B2** (min = 0): Arrange empty report; Act call; Assert returns stub.
* **Unit Scenario: UTS-021-B3** (mid = 10): Arrange 10 sections; Act call; Assert output has 10 section headings.
* **Unit Scenario: UTS-021-B4** (max = 20): Arrange 20 sections; Act call; Assert output has 20 headings.
* **Unit Scenario: UTS-021-B5** (max+1 = 21): Arrange 21 sections; Act call; Assert raises `TooManySectionsError`.

---

### Module: MOD-022 (`compute_coverage_report`)

**Parent Architecture Modules**: ARCH-017
**Target Source File(s)**: `src/v_model_extension/quality/harness.py`

#### Test Case: UTP-022-A (Coverage computation control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise division branch including the divide-by-zero guard.

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-022-A1** (true-branch nominal): Arrange `covered=8, total=10`; Act call; Assert returns `pct=80.0`.
* **Unit Scenario: UTS-022-A2** (false-branch divide-by-zero guard): Arrange `covered=0, total=0`; Act call; Assert returns `pct=0.0`; no `ZeroDivisionError`.
* **Unit Scenario: UTS-022-A3** (loop N iterations all metrics): Arrange 4 metrics; Act call; Assert returned dict has 4 entries.

#### Test Case: UTP-022-B (Coverage percent boundaries)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Boundary-test internal `pct` (valid 0..100).

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-022-B1** (min-1 = -1): Arrange `covered=-1, total=10`; Act call; Assert raises `NegativeCoverageError`.
* **Unit Scenario: UTS-022-B2** (min = 0): Arrange `covered=0, total=10`; Act call; Assert `pct=0.0`.
* **Unit Scenario: UTS-022-B3** (mid = 50): Arrange `covered=5, total=10`; Act call; Assert `pct=50.0`.
* **Unit Scenario: UTS-022-B4** (max = 100): Arrange `covered=10, total=10`; Act call; Assert `pct=100.0`.
* **Unit Scenario: UTS-022-B5** (max+1 = 101): Arrange `covered=11, total=10`; Act call; Assert raises `OverCoverageError`.

---

### Module: MOD-023 (`annotate_commit`)

**Parent Architecture Modules**: ARCH-018
**Target Source File(s)**: `src/v_model_extension/git/annotator.py`

#### Test Case: UTP-023-A (Commit annotation control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise the trailer-build branch and the no-trailer fallback.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `MOD-026 run_subprocess` | ARCH Interface View | Spy: capture argv | Avoid real git |

* **Unit Scenario: UTS-023-A1** (true-branch trailer added): Arrange annotation `{trace: "REQ-001"}`; Act call `annotate_commit(annotation)`; Assert spy invoked with argv containing `--trailer Trace=REQ-001`.
* **Unit Scenario: UTS-023-A2** (false-branch annotation empty): Arrange annotation `{}`; Act call; Assert spy NOT invoked; returns early.
* **Unit Scenario: UTS-023-A3** (loop N iterations multiple trailers): Arrange annotation with 3 keys; Act call; Assert spy argv contains 3 `--trailer` flags.

#### Test Case: UTP-023-B (Annotate-yes-no partition)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition the `should_annotate` boolean (True, False, plus invalid None).

**Dependency & Mock Registry:** Same as UTP-023-A.

* **Unit Scenario: UTS-023-B1** (valid: True): Arrange `should_annotate=True`; Act call; Assert spy invoked.
* **Unit Scenario: UTS-023-B2** (valid: False): Arrange `should_annotate=False`; Act call; Assert spy NOT invoked.
* **Unit Scenario: UTS-023-B3** (invalid: None): Arrange `should_annotate=None`; Act call; Assert raises `MissingAnnotationFlagError`.

#### Test Case: UTP-023-C (Subprocess isolation)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Confirm `annotate_commit` never invokes git directly.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `MOD-026 run_subprocess` | ARCH Interface View | Spy | Capture all subprocess calls |
| `subprocess.Popen` | (forbidden) | Patch to raise | Detect leakage |

* **Unit Scenario: UTS-023-C1** (no raw popen): Arrange `subprocess.Popen` patched to raise; Act call; Assert no propagation.
* **Unit Scenario: UTS-023-C2** (only allowlisted argv): Arrange spy; Act call; Assert all spy argv start with `["git"]`.

---

### Module: MOD-024 (`load_artifacts`) [CROSS-CUTTING]

**Parent Architecture Modules**: ARCH-019
**Target Source File(s)**: `src/v_model_extension/io/artifact_reader.py`

#### Test Case: UTP-024-A (Artifact-loading control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise per-file loading loop including missing-file fallback and non-UTF8 branch.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `pathlib.Path.read_text` | ARCH Interface View | Stub: returns canned text | Avoid real disk |
| `pathlib.Path.exists` | ARCH Interface View | Stub: returns bool | Drive existence branches |

* **Unit Scenario: UTS-024-A1** (true-branch all files exist): Arrange exists=True for all; Act call; Assert returns dict with all keys populated.
* **Unit Scenario: UTS-024-A2** (false-branch missing optional file): Arrange exists=False for `system-test.md`; Act call; Assert dict has key `system-test.md` set to `None`.
* **Unit Scenario: UTS-024-A3** (false-branch missing required file): Arrange exists=False for `requirements.md`; Act call; Assert raises `MissingRequiredArtifactError`.

#### Test Case: UTP-024-B (File count boundaries)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Boundary-test internal `file_count` (valid 1..30).

**Dependency & Mock Registry:** Same as UTP-024-A.

* **Unit Scenario: UTS-024-B1** (min-1 = 0): Arrange empty manifest; Act call; Assert raises `EmptyManifestError`.
* **Unit Scenario: UTS-024-B2** (min = 1): Arrange 1-entry manifest; Act call; Assert dict has 1 entry.
* **Unit Scenario: UTS-024-B3** (mid = 15): Arrange 15-entry manifest; Act call; Assert dict has 15 entries.
* **Unit Scenario: UTS-024-B4** (max = 30): Arrange 30-entry manifest; Act call; Assert dict has 30 entries.
* **Unit Scenario: UTS-024-B5** (max+1 = 31): Arrange 31-entry manifest; Act call; Assert raises `ManifestTooLargeError`.

#### Test Case: UTP-024-C (Filesystem isolation)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Confirm `load_artifacts` reads only via stubbed `Path.read_text`.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `pathlib.Path.read_text` | ARCH Interface View | Spy | Capture all reads |
| `builtins.open` | (forbidden) | Patch to raise | Detect leakage |

* **Unit Scenario: UTS-024-C1** (no raw open): Arrange `builtins.open` patched to raise; Act call; Assert no propagation.
* **Unit Scenario: UTS-024-C2** (all reads under feature_dir): Arrange spy; Act call; Assert every spy call has `path.startswith(feature_dir)`.

---

### Module: MOD-025 (`extract_id_set`) [CROSS-CUTTING]

**Parent Architecture Modules**: ARCH-019
**Target Source File(s)**: `src/v_model_extension/io/artifact_reader.py`

#### Test Case: UTP-025-A (ID extraction control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise the per-line regex match loop and the no-match fallback.

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-025-A1** (true-branch matches present): Arrange text `"REQ-001 and MOD-007"`; Act call `extract_id_set(text)`; Assert returns `{"REQ-001", "MOD-007"}`.
* **Unit Scenario: UTS-025-A2** (false-branch no matches): Arrange text `"plain prose"`; Act call; Assert returns `set()`.
* **Unit Scenario: UTS-025-A3** (loop N iterations dedup): Arrange text with `"REQ-001 REQ-001"`; Act call; Assert returns `{"REQ-001"}` (single element).

#### Test Case: UTP-025-B (ID-pattern partitions)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition the `id_pattern_class` (canonical, lowercase, malformed).

**Dependency & Mock Registry:** None — self-contained.

* **Unit Scenario: UTS-025-B1** (canonical): Arrange `"REQ-001"`; Act call; Assert `{"REQ-001"}`.
* **Unit Scenario: UTS-025-B2** (lowercase): Arrange `"req-001"`; Act call; Assert returns `set()` (case-sensitive).
* **Unit Scenario: UTS-025-B3** (malformed): Arrange `"REQ001"` (no hyphen); Act call; Assert returns `set()`.

---

### Module: MOD-026 (`run_subprocess`) [CROSS-CUTTING]

**Parent Architecture Modules**: ARCH-020
**Target Source File(s)**: `src/v_model_extension/io/subprocess_runner.py`

#### Test Case: UTP-026-A (Subprocess invocation control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise success branch, non-zero exit branch, and timeout branch.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `subprocess.run` | ARCH Interface View | Stub: returns CompletedProcess | Avoid real exec |

* **Unit Scenario: UTS-026-A1** (true-branch success): Arrange stub returns `(returncode=0, stdout="ok", stderr="")`; Act call `run_subprocess(["echo","ok"])`; Assert returns `(0, "ok", "")`.
* **Unit Scenario: UTS-026-A2** (false-branch non-zero): Arrange stub returns `returncode=2`; Act call; Assert returns `(2, "", "boom")`; logs warning.
* **Unit Scenario: UTS-026-A3** (timeout branch): Arrange stub raises `TimeoutExpired`; Act call with `timeout=1`; Assert raises `SubprocessTimeoutError`.

#### Test Case: UTP-026-B (Timeout boundaries)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Boundary-test the internal `timeout_seconds` parameter (valid 1..600).

**Dependency & Mock Registry:** Same as UTP-026-A.

* **Unit Scenario: UTS-026-B1** (min-1 = 0): Arrange `timeout=0`; Act call; Assert raises `InvalidTimeoutError`.
* **Unit Scenario: UTS-026-B2** (min = 1): Arrange `timeout=1`; Act call; Assert stub invoked with `timeout=1`.
* **Unit Scenario: UTS-026-B3** (mid = 60): Arrange `timeout=60`; Act call; Assert stub invoked with `timeout=60`.
* **Unit Scenario: UTS-026-B4** (max = 600): Arrange `timeout=600`; Act call; Assert stub invoked with `timeout=600`.
* **Unit Scenario: UTS-026-B5** (max+1 = 601): Arrange `timeout=601`; Act call; Assert raises `TimeoutTooLargeError`.

#### Test Case: UTP-026-C (Subprocess isolation)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Confirm wrapper never bypasses `subprocess.run` (e.g., via `os.system`).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `subprocess.run` | ARCH Interface View | Spy | Capture all calls |
| `os.system` | (forbidden) | Patch to raise | Detect leakage |
| `subprocess.Popen` | (forbidden) | Patch to raise | Detect leakage |

* **Unit Scenario: UTS-026-C1** (no os.system): Arrange `os.system` patched to raise; Act call; Assert no propagation.
* **Unit Scenario: UTS-026-C2** (no raw Popen): Arrange `subprocess.Popen` patched to raise; Act call; Assert no propagation.

---

### Module: MOD-027 (`atomic_write`) [CROSS-CUTTING]

**Parent Architecture Modules**: ARCH-021
**Target Source File(s)**: `src/v_model_extension/io/fs_writer.py`

#### Test Case: UTP-027-A (Atomic write control flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise temp-file → fsync → rename happy path and the rename-failure rollback branch.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `os.replace` | ARCH Interface View | Stub: succeeds or raises | Drive rollback branch |
| `os.fsync` | ARCH Interface View | Stub: no-op | Avoid real fsync |
| `tempfile.NamedTemporaryFile` | ARCH Interface View | Stub: returns in-memory buffer | Avoid real disk |

* **Unit Scenario: UTS-027-A1** (happy-path success): Arrange stubs succeed; Act call `atomic_write(path, b"data")`; Assert `os.replace` invoked once with (tmp, target).
* **Unit Scenario: UTS-027-A2** (rename-failure rollback): Arrange `os.replace` raises `OSError`; Act call; Assert temp file removal attempted; raises `AtomicWriteError`.
* **Unit Scenario: UTS-027-A3** (loop N iterations no leftover): Arrange 5 sequential calls succeed; Act call; Assert no temp files remain in stub registry.

#### Test Case: UTP-027-B (Payload size boundaries)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Boundary-test internal `size_bytes` parameter (valid 0..104_857_600 = 100 MiB).

**Dependency & Mock Registry:** Same as UTP-027-A.

* **Unit Scenario: UTS-027-B1** (min-1 = -1, conceptually invalid): Arrange `payload=None`; Act call; Assert raises `NullPayloadError`.
* **Unit Scenario: UTS-027-B2** (min = 0): Arrange empty payload; Act call; Assert `os.replace` invoked; file size 0.
* **Unit Scenario: UTS-027-B3** (mid = 1_048_576): Arrange 1 MiB payload; Act call; Assert succeeds.
* **Unit Scenario: UTS-027-B4** (max = 104_857_600): Arrange 100 MiB payload; Act call; Assert succeeds.
* **Unit Scenario: UTS-027-B5** (max+1 = 104_857_601): Arrange 100 MiB+1 payload; Act call; Assert raises `PayloadTooLargeError`.

#### Test Case: UTP-027-C (Filesystem isolation)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Confirm wrapper never uses raw `open()` for writes.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `tempfile.NamedTemporaryFile` | ARCH Interface View | Spy | Capture all writes |
| `builtins.open` (write mode) | (forbidden) | Patch to raise on `'w'` or `'wb'` mode | Detect leakage |

* **Unit Scenario: UTS-027-C1** (no raw open-write): Arrange `builtins.open` patched to raise on write modes; Act call; Assert no propagation.
* **Unit Scenario: UTS-027-C2** (all writes via temp file): Arrange spy; Act call; Assert every spy call uses temp suffix `.tmp`.

---

## External Module Bypass

No `[EXTERNAL]` modules in module-design.md. All 27 modules (including the
4 `[CROSS-CUTTING]` modules) carry full white-box unit test coverage.

<!-- SAFETY-CRITICAL TECHNIQUES: Skipped — no domain overlay configured. -->

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Modules (MOD) | 27 (27 active, 0 deprecated) |
| Modules tested | 27 (excludes [EXTERNAL]) |
| Modules bypassed ([EXTERNAL]) | 0 |
| Total Test Cases (UTP) | 65 |
| Total Scenarios (UTS) | 221 |
| Modules with ≥1 UTP | 27 / 27 (100%) |
| Test Cases with ≥1 UTS | 65 / 65 (100%) |
| **Overall Coverage (MOD→UTP)** | **100%** |

### Technique Distribution

| Technique | Test Cases | Percentage |
|-----------|-----------|------------|
| Statement & Branch Coverage | 27 | 41.5% |
| Boundary Value Analysis | 14 | 21.5% |
| Equivalence Partitioning | 13 | 20.0% |
| Strict Isolation | 8 | 12.3% |
| State Transition Testing | 3 | 4.6% |

## Uncovered Modules

None — full coverage achieved.
