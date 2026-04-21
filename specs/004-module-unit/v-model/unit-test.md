# Unit Test Plan: Module Design ↔ Unit Testing

**Feature Branch**: `004-module-unit`
**Created**: 2026-04-20
**Status**: Draft
**Source**: `specs/004-module-unit/v-model/module-design.md`

## Overview

This document defines the Unit Test Plan for the V-Model Extension Pack v0.4.0 Module Design
feature. Every module design (`MOD-NNN`) in `module-design.md` has one or more Test Cases
(`UTP-NNN-X`), and every Test Case has one or more executable Unit Scenarios (`UTS-NNN-X#`) in
white-box Arrange/Act/Assert format.

Unit tests verify **internal module logic** — control flow, data transformations, state
transitions, and variable boundaries. They do NOT test module boundaries (integration), user
journeys (acceptance), or system-level behavior (system tests).

## ID Schema

- **Unit Test Case**: `UTP-{NNN}-{X}` — where NNN matches the parent MOD, X is a letter suffix (A, B, C...)
- **Unit Test Scenario**: `UTS-{NNN}-{X}{#}` — nested under the parent UTP, with numeric suffix (1, 2, 3...)
- Example: `UTS-001-A1` → Scenario 1 of Test Case A verifying MOD-001
- ID lineage: from `UTS-001-A1`, a regex extracts `UTP-001-A` and `MOD-001`. To find the `ARCH-NNN` ancestor, consult the "Parent Architecture Modules" field in `module-design.md`.

## ISO 29119-4 White-Box Techniques

Each test case MUST identify its technique by name and anchor to a specific module design view:

| Technique | Source View | What It Tests |
|-----------|------------|---------------|
| **Statement & Branch Coverage** | Algorithmic/Logic View | Every line and every True/False branch outcome |
| **Boundary Value Analysis** | Internal Data Structures | Scalar variable boundaries: min-1, min, mid, max, max+1 |
| **Equivalence Partitioning** | Internal Data Structures | Discrete non-scalar types: Booleans, Enums |
| **Strict Isolation** | Architecture Interface View | Every external dependency mocked/stubbed |
| **State Transition Testing** | State Machine View | Every transition including invalid ones |

## Unit Tests

---

### Module: MOD-001 (Module Design Command Orchestrator)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `commands/module-design.md`

#### Test Case: UTP-001-A (Statement and Branch Coverage of execute_module_design_command)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies all conditional branches inside `execute_module_design_command`: setup script exit-code check, `arch_modules` empty guard, template-not-found guard, existing-MOD lifecycle detection, and routing_decision dispatch (`wrapper_only`, `decompose_full`, `cross_cutting`, `flag_derived`).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `run_shell` | Architecture Interface View (ARCH-001) | Stub: configurable exit_code and stdout JSON | Isolate from live Bash environment |
| `read_file` | Architecture Interface View (ARCH-001) | Stub: returns fixture strings per path | Prevent real filesystem reads |
| `write_file` | Architecture Interface View (ARCH-001) | Spy: captures path and content args | Verify output without real disk write |
| `parse_json` | Architecture Interface View (ARCH-001) | Stub: returns pre-built context dict | Remove JSON parsing variability |
| `route_module_tag` (MOD-024) | Algorithmic/Logic View | Stub: returns configurable RoutingDecision | Isolate tag-routing logic |

* **Unit Scenario: UTS-001-A1** — Setup script failure branch
  * **Arrange**: Set `run_shell` stub to return `exit_code=1` and `stdout=None`
  * **Act**: Call `execute_module_design_command(arguments="")`
  * **Assert**: Returns `Error("Setup script failed — check feature branch or missing prerequisites")`; `write_file` spy is never called; `generated_mods` remains empty `[]`

* **Unit Scenario: UTS-001-A2** — Empty architecture modules guard
  * **Arrange**: Set `run_shell` stub to return `exit_code=0` and valid context JSON; set `read_file` stub for `arch_design_path` to return content with zero `ARCH-NNN` matches; set `extract_arch_modules` stub to return `[]`
  * **Act**: Call `execute_module_design_command(arguments="")`
  * **Assert**: Returns `Error("No architecture modules found in architecture-design.md — cannot generate module design")`; `write_file` is never called

* **Unit Scenario: UTS-001-A3** — Successful nominal path with one standard module
  * **Arrange**: Set `run_shell` stub to return `exit_code=0`; set `extract_arch_modules` stub to return one `ArchModule` with `tag=""`; set `route_module_tag` stub to return `RoutingDecision.DECOMPOSE_FULL`; set `decompose_arch_module` stub to return one `ModuleSpec` with non-empty `parent_archs`; set `"module-design.md"` absent from `available_docs`
  * **Act**: Call `execute_module_design_command(arguments="")`
  * **Assert**: `generated_mods` length equals 1; `write_file` is called once with path ending in `module-design.md`; `mod_counter` equals 2 after loop; `derived_flags` equals `[]`

#### Test Case: UTP-001-B (State Transition Testing of command orchestrator lifecycle)

**Technique**: State Transition Testing
**Target View**: State Machine View
**Description**: Verifies each state transition in the `execute_module_design_command` state machine: `Setup→LoadingContext`, `Setup→Error`, `LoadingContext→Error` (arch empty), `CheckingExisting→LifecycleReview`, `LifecycleReview→GeneratingModules`, `GeneratingModules→AssemblingDocument`, `WritingOutput→CoverageGate`, `CoverageGate→Complete`.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `run_shell` | Architecture Interface View (ARCH-001) | Stub: configurable exit_code | Drive transitions from Setup |
| `read_file` | Architecture Interface View (ARCH-001) | Stub: fixture content | Prevent filesystem side-effects |
| `write_file` | Architecture Interface View (ARCH-001) | Spy | Verify WritingOutput transition |

* **Unit Scenario: UTS-001-B1** — Valid transition Setup→LoadingContext→GeneratingModules→Complete
  * **Arrange**: Set `run_shell` stub exit_code=0; `extract_arch_modules` returns one module; `"module-design.md"` absent from `available_docs`; `route_module_tag` returns `DECOMPOSE_FULL`
  * **Act**: Call `execute_module_design_command(arguments="")`
  * **Assert**: Internal state machine visits `Setup`, `LoadingContext`, `CheckingExisting`, `GeneratingModules`, `AssemblingDocument`, `WritingOutput`, `CoverageGate`, `Complete` in sequence; `write_file` called once

* **Unit Scenario: UTS-001-B2** — Invalid transition: Setup→Error (setup_script_failure)
  * **Arrange**: Set `run_shell` stub exit_code=1
  * **Act**: Call `execute_module_design_command(arguments="")`
  * **Assert**: State machine transitions from `Setup` directly to `Error`; no further states are entered; function returns `Error` result immediately

* **Unit Scenario: UTS-001-B3** — CheckingExisting→LifecycleReview when existing module design found
  * **Arrange**: Set `run_shell` stub exit_code=0; set `available_docs` to include `"module-design.md"`; set `parse_existing_mods` stub to return one existing `ModuleEntry` with a parent ARCH that `get_arch_status` returns `"deprecated"`
  * **Act**: Call `execute_module_design_command(arguments="")`
  * **Assert**: `existing_mod_map` entry has `tag` set to `"[SUSPECT — Parent ARCH-001 deprecated]"`; state machine passes through `LifecycleReview` before `GeneratingModules`

---

### Module: MOD-002 (Algorithmic / Logic View Generator)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `commands/module-design.md`

#### Test Case: UTP-002-A (Statement and Branch Coverage of generate_algorithmic_view)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies all branches inside `generate_algorithmic_view`: the input-validation block only fires for contracts with direction=="Input" and constraint containing "MUST"; decision_points with and without false_branch; vague-prose detection branch raising `StructuralFailure`.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `find_data_flow_entry` | Architecture Interface View (ARCH-002) | Stub: returns fixture `DataFlowEntry` | Isolate from architecture content parser |
| `find_interface_contracts` | Architecture Interface View (ARCH-002) | Stub: returns configurable contract list | Drive input-validation loop |
| `contains_vague_prose` | Architecture Interface View (ARCH-002) | Stub: configurable Boolean return | Control StructuralFailure branch |

* **Unit Scenario: UTS-002-A1** — Input contract with MUST constraint generates validation IF block
  * **Arrange**: Set `find_interface_contracts` stub to return one `InterfaceContract` with `direction="Input"` and `constraint="Parameter MUST not be null"`; set `decision_points` to `[]`; set `contains_vague_prose` stub to return `False`
  * **Act**: Call `generate_algorithmic_view(arch_module, mod_spec)`
  * **Assert**: `pseudocode_lines` contains a line matching `"    IF Parameter IS NULL OR invalid:"`; returned string is wrapped in `` ```pseudocode `` fence

* **Unit Scenario: UTS-002-A2** — Contract with direction!="Input" is skipped
  * **Arrange**: Set `find_interface_contracts` stub to return one contract with `direction="Exception"`; set `contains_vague_prose` stub to return `False`
  * **Act**: Call `generate_algorithmic_view(arch_module, mod_spec)`
  * **Assert**: `pseudocode_lines` does NOT contain any `"IF"` validation block; length of `pseudocode_lines` equals function-header line + transformation lines + return line

* **Unit Scenario: UTS-002-A3** — Vague prose detected raises StructuralFailure
  * **Arrange**: Set `find_interface_contracts` stub to return `[]`; set `contains_vague_prose` stub to return `True`
  * **Act**: Call `generate_algorithmic_view(arch_module, mod_spec)`
  * **Assert**: `StructuralFailure` exception is raised with message `"Vague prose detected in algorithmic view — replace with explicit code expressions"`; no string is returned

#### Test Case: UTP-002-B (Strict Isolation of external data-flow lookup)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies that when `find_data_flow_entry` raises `MissingContextWarning`, the function falls back to using Interface View contracts for transformation context without propagating the exception to the caller.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `find_data_flow_entry` | Architecture Interface View (ARCH-002) | Stub: raises `MissingContextWarning` | Trigger fallback branch |
| `find_interface_contracts` | Architecture Interface View (ARCH-002) | Stub: returns one valid contract | Confirm fallback uses Interface View |
| `contains_vague_prose` | Architecture Interface View (ARCH-002) | Stub: returns `False` | Allow execution to complete |

* **Unit Scenario: UTS-002-B1** — MissingContextWarning triggers Interface View fallback
  * **Arrange**: Set `find_data_flow_entry` stub to raise `MissingContextWarning`; set `find_interface_contracts` stub to return one contract with `direction="Input"` and `constraint="MUST be string"`
  * **Act**: Call `generate_algorithmic_view(arch_module, mod_spec)`
  * **Assert**: No exception propagates to the caller; returned string is a non-empty `` ```pseudocode `` block; `pseudocode_lines` is non-empty

---

### Module: MOD-003 (State Machine View Generator)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `commands/module-design.md`

#### Test Case: UTP-003-A (Statement and Branch Coverage of generate_state_machine_view)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies the stateless bypass branch (returns `"N/A — Stateless"`), the stateful branch (builds Mermaid diagram), the error-state injection branch (no ERROR_STATE in states → append), and the recovery-transition injection branch.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `detect_stateful_behavior` | Architecture Interface View (ARCH-002) | Stub: configurable Boolean | Control is_stateful branch |
| `find_process_diagrams` | Architecture Interface View (ARCH-002) | Stub: returns fixture diagrams | Isolate from architecture parser |
| `extract_states` | Architecture Interface View (ARCH-002) | Stub: returns configurable List[State] | Control error-state injection |
| `extract_transitions` | Architecture Interface View (ARCH-002) | Stub: returns fixture transitions | Drive Mermaid diagram lines |

* **Unit Scenario: UTS-003-A1** — Stateless module: returns canonical bypass string
  * **Arrange**: Set `detect_stateful_behavior` stub to return `False`
  * **Act**: Call `generate_state_machine_view(arch_module, mod_spec)`
  * **Assert**: Returns exactly `"N/A — Stateless"`; `mermaid_lines` is never initialized; no external stubs are called after `detect_stateful_behavior`

* **Unit Scenario: UTS-003-A2** — Stateful module without ERROR_STATE: injects error state
  * **Arrange**: Set `detect_stateful_behavior` stub to return `True`; set `extract_states` stub to return two states `["Idle", "Running"]` with no `"Error"` state; set `extract_transitions` stub to return one transition `Idle→Running`; set `extract_guards` stub to return `[]`
  * **Act**: Call `generate_state_machine_view(arch_module, mod_spec)`
  * **Assert**: `states` list length equals 3 after injection (Idle, Running, Error); `mermaid_lines` contains `"    Error --> [*]"` as terminal; returned string contains `` ```mermaid `` fence and `stateDiagram-v2`

* **Unit Scenario: UTS-003-A3** — Stateful module with existing ERROR_STATE: no duplicate injection
  * **Arrange**: Set `detect_stateful_behavior` stub to return `True`; set `extract_states` stub to return `["Idle", "Error"]`; set `extract_transitions` stub to return transitions including one with `from_state="Error"` and `to_state="Idle"` (recovery)
  * **Act**: Call `generate_state_machine_view(arch_module, mod_spec)`
  * **Assert**: `states` list length remains 2 (no additional Error appended); no duplicate `State("Error", ...)` in `states`

#### Test Case: UTP-003-B (Equivalence Partitioning of is_stateful Boolean)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions the `is_stateful` Boolean variable into its two valid classes (True, False) and an invalid class (None/undefined) to verify the correct branch is taken in each case.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `detect_stateful_behavior` | Architecture Interface View (ARCH-002) | Stub: returns partition value | Inject each equivalence class |

* **Unit Scenario: UTS-003-B1** — Partition: is_stateful=True → Mermaid diagram path
  * **Arrange**: Set `detect_stateful_behavior` stub to return `True`; configure `extract_states` to return `["Idle", "Done"]`; configure `extract_transitions` to return `[Idle→Done]`
  * **Act**: Call `generate_state_machine_view(arch_module, mod_spec)`
  * **Assert**: `is_stateful` equals `True`; returned value contains `"stateDiagram-v2"`

* **Unit Scenario: UTS-003-B2** — Partition: is_stateful=False → bypass string path
  * **Arrange**: Set `detect_stateful_behavior` stub to return `False`
  * **Act**: Call `generate_state_machine_view(arch_module, mod_spec)`
  * **Assert**: `is_stateful` equals `False`; returned value equals `"N/A — Stateless"`

---

### Module: MOD-004 (Internal Data Structures View Generator)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `commands/module-design.md`

#### Test Case: UTP-004-A (Statement and Branch Coverage of generate_data_structures_view)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies: the type-explicitness rejection branch (raises `TypeError` for type in `["any", "object", "unknown"]`), the buffer-without-size-constraint branch (raises `ConstraintError`), and the nominal path that correctly renders a Markdown table row per variable.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `mod_spec` inputs | Architecture Interface View (ARCH-002) | Stub `ModuleSpec` with configurable variable list | Drive variable loop |

* **Unit Scenario: UTS-004-A1** — Generic type "any" raises TypeError
  * **Arrange**: Construct `mod_spec` with `local_variables=[Variable(name="data", explicit_type="any", is_buffer=False)]`
  * **Act**: Call `generate_data_structures_view(arch_module, mod_spec)`
  * **Assert**: `TypeError` is raised with message `"Variable 'data' must have an explicit language-level type"`; `table_rows` remains `[]`

* **Unit Scenario: UTS-004-A2** — Buffer variable missing size_or_constraints raises ConstraintError
  * **Arrange**: Construct `mod_spec` with `local_variables=[Variable(name="buf", explicit_type="bytes", is_buffer=True, size_or_constraints=None)]`
  * **Act**: Call `generate_data_structures_view(arch_module, mod_spec)`
  * **Assert**: `ConstraintError` is raised with message `"Buffer 'buf' requires explicit size constraint for BVA"`

* **Unit Scenario: UTS-004-A3** — Nominal path: one valid variable renders correct Markdown row
  * **Arrange**: Construct `mod_spec` with `local_variables=[Variable(name="counter", explicit_type="Integer", is_buffer=False, size_or_constraints="≥0", default_value="0", purpose="Loop counter")]`
  * **Act**: Call `generate_data_structures_view(arch_module, mod_spec)`
  * **Assert**: Returned string contains `"| \`counter\` | \`Integer\` | ≥0 | \`0\` | Loop counter |"`; `table_rows` length equals 1

---

### Module: MOD-005 (Error Handling & Return Codes View Generator)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `commands/module-design.md`

#### Test Case: UTP-005-A (Statement and Branch Coverage of generate_error_handling_view)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies: the branch where `exception_entries` is empty (emits only catch-all row), the branch where contracts exist (one row per contract + catch-all), and the recovery-classification conditionals inside `determine_recovery_action`.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `find_interface_contracts` | Architecture Interface View (ARCH-002) | Stub: configurable contract list | Drive exception_entries loop |
| `filter_exceptions` | Architecture Interface View (ARCH-002) | Stub: returns filtered contracts | Isolate filtering logic |
| `determine_recovery_action` | Architecture Interface View (ARCH-002) | Stub: returns fixture recovery string | Isolate recovery classification |

* **Unit Scenario: UTS-005-A1** — No interface contracts: emit single catch-all row only
  * **Arrange**: Set `find_interface_contracts` stub to return `[]`; set `filter_exceptions` stub to return `[]`
  * **Act**: Call `generate_error_handling_view(arch_module, mod_spec)`
  * **Assert**: `table_rows` length equals 1; `table_rows[0].code_or_exc` equals `"UnexpectedError"`; `table_rows[0].recovery` equals `"Re-thrown to orchestrator (MOD-001 or MOD-006)"`; returned Markdown table has exactly 3 lines (header + separator + catch-all)

* **Unit Scenario: UTS-005-A2** — Two exception contracts: emit two contract rows + catch-all
  * **Arrange**: Set `filter_exceptions` stub to return two contracts with `error_condition="Null input"` and `error_condition="Timeout"` respectively; set `determine_recovery_action` stub to return `"Abort: fatal"` for both
  * **Act**: Call `generate_error_handling_view(arch_module, mod_spec)`
  * **Assert**: `table_rows` length equals 3; `table_rows[2].code_or_exc` equals `"UnexpectedError"` (catch-all is always last); returned Markdown table has 5 lines

---

### Module: MOD-006 (Unit Test Command Orchestrator)

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `commands/unit-test.md`

#### Test Case: UTP-006-A (Statement and Branch Coverage of execute_unit_test_command)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies all conditional branches inside `execute_unit_test_command`: setup script failure, `mod_modules` empty guard, template not found, routing_decision "skip_utp" vs standard (generating UTPs), and domain_config None vs non-None for safety-critical section.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `run_shell` | Architecture Interface View (ARCH-003) | Stub: configurable exit_code and stdout | Isolate from live Bash |
| `read_file` | Architecture Interface View (ARCH-003) | Stub: fixture content per path | Prevent filesystem reads |
| `write_file` | Architecture Interface View (ARCH-003) | Spy | Verify file write occurs |
| `parse_json` | Architecture Interface View (ARCH-003) | Stub: pre-built context dict | Remove JSON parsing variability |
| `route_module_tag` (MOD-024) | Algorithmic/Logic View | Stub: configurable RoutingDecision | Isolate tag routing |
| `generate_utp_and_uts` | Architecture Interface View (ARCH-003) | Stub: returns fixture UTPEntry list | Isolate UTP generation |

* **Unit Scenario: UTS-006-A1** — Setup failure branch
  * **Arrange**: Set `run_shell` stub exit_code=1
  * **Act**: Call `execute_unit_test_command(arguments="")`
  * **Assert**: Returns `Error("Setup failed — module-design.md missing or prerequisites not met")`; `write_file` spy is never called; `generated_utps` is never initialized

* **Unit Scenario: UTS-006-A2** — [EXTERNAL] module routing: skip_utp path
  * **Arrange**: Set `run_shell` stub exit_code=0; `extract_mod_modules` returns one `ModuleSpec` with `tag="[EXTERNAL]"`; `route_module_tag` returns `RoutingDecision.SKIP_UTP`
  * **Act**: Call `execute_unit_test_command(arguments="")`
  * **Assert**: `generated_utps` contains one `SkipEntry` (not `UTPEntry`); `generate_utp_and_uts` stub is never called; `write_file` is called once

* **Unit Scenario: UTS-006-A3** — Nominal path: standard module generates UTPs
  * **Arrange**: Set `run_shell` stub exit_code=0; `extract_mod_modules` returns one `ModuleSpec` with `tag=""`; `route_module_tag` returns `RoutingDecision.DECOMPOSE_FULL`; `generate_utp_and_uts` stub returns `[UTPEntry(id="UTP-001-A")]`
  * **Act**: Call `execute_unit_test_command(arguments="")`
  * **Assert**: `generated_utps` length equals 1; `generated_utps[0]` is a `UTPEntry` with `id="UTP-001-A"`; `write_file` is called once with path ending in `unit-test.md`

#### Test Case: UTP-006-B (State Transition Testing of unit test command lifecycle)

**Technique**: State Transition Testing
**Target View**: State Machine View
**Description**: Verifies transitions in the `execute_unit_test_command` state machine: `Setup→LoadingModuleDesign` (success), `Setup→Error` (failure), `LoadingModuleDesign→Error` (empty mod list), `ProcessingModules→AssemblingDocument`, `WritingOutput→CoverageGate`, `CoverageGate→Complete` (both pass and fail-with-report).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `run_shell` | Architecture Interface View (ARCH-003) | Stub: configurable exit_code | Drive state transitions |
| `write_file` | Architecture Interface View (ARCH-003) | Spy | Observe WritingOutput→CoverageGate |

* **Unit Scenario: UTS-006-B1** — Valid path Setup→LoadingModuleDesign→ProcessingModules→Complete
  * **Arrange**: Set `run_shell` stubs: first call exit_code=0 (setup), second call exit_code=0 (coverage gate); `extract_mod_modules` returns one module; `route_module_tag` returns `DECOMPOSE_FULL`
  * **Act**: Call `execute_unit_test_command(arguments="")`
  * **Assert**: State sequence is `Setup→LoadingModuleDesign→ProcessingModules→AssemblingDocument→WritingOutput→CoverageGate→Complete`; `write_file` called once; final result includes coverage_result from second `run_shell` call

* **Unit Scenario: UTS-006-B2** — LoadingModuleDesign→Error (empty mod list)
  * **Arrange**: Set `run_shell` first call exit_code=0; `extract_mod_modules` returns `[]`
  * **Act**: Call `execute_unit_test_command(arguments="")`
  * **Assert**: Returns `Error("No module design entries found in module-design.md — cannot generate unit tests")`; state transitions to `Error` from `LoadingModuleDesign`; `write_file` never called

* **Unit Scenario: UTS-006-B3** — CoverageGate→Complete with coverage_fail_with_report (non-fatal)
  * **Arrange**: Set first `run_shell` exit_code=0 (setup); `extract_mod_modules` returns one module; second `run_shell` exit_code=1 (coverage gate reports gaps)
  * **Act**: Call `execute_unit_test_command(arguments="")`
  * **Assert**: State machine still reaches `Complete` (non-fatal); `write_file` is called; `coverage_result` contains gap report from second `run_shell`; no exception is raised

---

### Module: MOD-007 (White-Box Technique Selector)

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `commands/unit-test.md`

#### Test Case: UTP-007-A (Statement and Branch Coverage of select_white_box_technique)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies: Statement & Branch Coverage is always appended first; BVA is appended for scalar_ordered_type variables; EP is appended for discrete_non_scalar variables; Strict Isolation appended with non-empty mock_targets when external deps exist; State Transition Testing appended when state_machine_view is not stateless bypass.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `find_interface_contracts` | Architecture Interface View (ARCH-004) | Stub: configurable contract list | Drive external_deps detection |
| `filter_external_dependencies` | Architecture Interface View (ARCH-004) | Stub: configurable filtered list | Control Strict Isolation branch |
| `compute_bva_boundaries` | Architecture Interface View (ARCH-004) | Stub: returns fixture boundaries | Isolate BVA computation |
| `enumerate_equivalence_classes` | Architecture Interface View (ARCH-004) | Stub: returns fixture partitions | Isolate EP enumeration |

* **Unit Scenario: UTS-007-A1** — Scalar Integer variable: BVA appended; Statement/Branch always first
  * **Arrange**: Construct `mod_module` with `internal_data_structures=[Variable(name="count", type="Integer")]`; set `filter_external_dependencies` stub to return `[]`; set `mod_module.state_machine_view` to `"N/A — Stateless"`
  * **Act**: Call `select_white_box_technique(mod_module)`
  * **Assert**: `techniques[0].technique` equals `"Statement & Branch Coverage"`; `techniques[1].technique` equals `"Boundary Value Analysis"`; `techniques[1].target_var` equals `"count"`; total `techniques` length equals 3 (S&BC + BVA + Strict Isolation self-contained)

* **Unit Scenario: UTS-007-A2** — Boolean variable: EP appended instead of BVA
  * **Arrange**: Construct `mod_module` with `internal_data_structures=[Variable(name="is_active", type="Boolean")]`; set `filter_external_dependencies` stub to return `[]`; `state_machine_view` is stateless bypass
  * **Act**: Call `select_white_box_technique(mod_module)`
  * **Assert**: No `TechniqueAssignment` with `technique="Boundary Value Analysis"` in result; `techniques` contains one entry with `technique="Equivalence Partitioning"` and `target_var="is_active"`

* **Unit Scenario: UTS-007-A3** — Stateful module: State Transition Testing appended
  * **Arrange**: Construct `mod_module` with `state_machine_view` containing valid Mermaid content (not stateless bypass); set `extract_states` stub to return 2 states; `extract_transitions` stub returns 2 transitions; `compute_invalid_transitions` stub returns 1 invalid
  * **Act**: Call `select_white_box_technique(mod_module)`
  * **Assert**: `techniques` contains one entry with `technique="State Transition Testing"`; `transitions` list on that entry has length 3 (2 valid + 1 invalid)

#### Test Case: UTP-007-B (Equivalence Partitioning of variable type classification)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions `SCALAR_ORDERED_TYPES` and `DISCRETE_NON_SCALAR_TYPES` sets to verify correct technique assignment for members of each class and for types not in either set.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `filter_external_dependencies` | Architecture Interface View (ARCH-004) | Stub: returns `[]` | Isolate to type-classification branch |

* **Unit Scenario: UTS-007-B1** — Type "uint8_t" (SCALAR_ORDERED_TYPES member) → BVA
  * **Arrange**: `mod_module.internal_data_structures = [Variable(type="uint8_t")]`; `state_machine_view` is stateless; `filter_external_dependencies` returns `[]`
  * **Act**: Call `select_white_box_technique(mod_module)`
  * **Assert**: Result contains `TechniqueAssignment(technique="Boundary Value Analysis")`; no EP entry present

* **Unit Scenario: UTS-007-B2** — Type "Enum" (DISCRETE_NON_SCALAR_TYPES member) → EP
  * **Arrange**: `mod_module.internal_data_structures = [Variable(type="Enum")]`; `state_machine_view` is stateless; `filter_external_dependencies` returns `[]`
  * **Act**: Call `select_white_box_technique(mod_module)`
  * **Assert**: Result contains `TechniqueAssignment(technique="Equivalence Partitioning")`; no BVA entry present

* **Unit Scenario: UTS-007-B3** — Type "String" (not in either set) → no BVA or EP
  * **Arrange**: `mod_module.internal_data_structures = [Variable(type="String")]`; `state_machine_view` is stateless; `filter_external_dependencies` returns `[]`
  * **Act**: Call `select_white_box_technique(mod_module)`
  * **Assert**: Result has length 2 (Statement & Branch + Strict Isolation only); neither BVA nor EP present

---

### Module: MOD-008 (UTP Test Case Generator)

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `commands/unit-test.md`

#### Test Case: UTP-008-A (Statement and Branch Coverage of generate_utp_case)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies: mock registry "None — self-contained" branch when `mock_targets` is empty; populated mock registry for non-empty `mock_targets`; correct UTP ID construction from `mod_number + utp_letter`; all five technique-specific `test_definition` branches (S&BC, BVA, EP, Strict Isolation, State Transition Testing).

**Dependency & Mock Registry:**

None — module is self-contained (operates on in-memory data structures only)

* **Unit Scenario: UTS-008-A1** — Empty mock_targets: "None — self-contained" row
  * **Arrange**: Set `technique.mock_targets = []`; set `mod_module.id = "MOD-005"`; set `utp_letter = "A"`; set `technique.technique = "Statement & Branch Coverage"`
  * **Act**: Call `generate_utp_case(mod_module, technique, utp_letter="A")`
  * **Assert**: `utp_id` equals `"UTP-005-A"`; `mock_registry_rows[0]` equals `"None — module is self-contained"`; `technique.technique` equals `"Statement & Branch Coverage"` in returned entry

* **Unit Scenario: UTS-008-A2** — Non-empty mock_targets: mock registry row constructed
  * **Arrange**: Set `technique.mock_targets = [Dep(name="file_system", type="File I/O", mock_behavior="returns empty string")]`; set `mod_module.id = "MOD-012"`; set `utp_letter = "B"`; set `technique.technique = "Strict Isolation"`
  * **Act**: Call `generate_utp_case(mod_module, technique, utp_letter="B")`
  * **Assert**: `utp_id` equals `"UTP-012-B"`; `mock_registry_rows[0].dependency` equals `"file_system"`; `mock_registry_rows[0].mock_strategy` contains `"returns empty string"`

#### Test Case: UTP-008-B (Boundary Value Analysis of utp_letter)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests the `utp_letter` Char variable at boundary values: minimum valid value 'A', a mid value 'M', maximum valid value 'Z', and beyond-max value signaling `IDOverflowError`.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-008-B1** — utp_letter='A' (minimum): valid UTP-NNN-A
  * **Arrange**: Set `utp_letter = "A"`; set `mod_module.id = "MOD-001"`
  * **Act**: Call `generate_utp_case(mod_module, technique, utp_letter="A")`
  * **Assert**: Returned `utp_id` equals `"UTP-001-A"`; no error raised

* **Unit Scenario: UTS-008-B2** — utp_letter='Z' (maximum): valid UTP-NNN-Z
  * **Arrange**: Set `utp_letter = "Z"`; set `mod_module.id = "MOD-001"`
  * **Act**: Call `generate_utp_case(mod_module, technique, utp_letter="Z")`
  * **Assert**: Returned `utp_id` equals `"UTP-001-"` + `"Z"` (letter Z); no error raised

* **Unit Scenario: UTS-008-B3** — utp_letter beyond 'Z': IDOverflowError raised
  * **Arrange**: Set `utp_letter = "AA"` (simulate overflow condition where caller passes double-letter)
  * **Act**: Call `generate_utp_case(mod_module, technique, utp_letter="AA")`
  * **Assert**: `IDOverflowError` is raised; warning is logged about >26 techniques per MOD

---

### Module: MOD-009 (UTS Scenario Generator)

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `commands/unit-test.md`

#### Test Case: UTP-009-A (Statement and Branch Coverage of generate_uts_scenarios)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies each technique branch in `generate_uts_scenarios`: Statement & Branch Coverage (one scenario per extracted branch), BVA (five boundary scenarios), Equivalence Partitioning (one per partition), State Transition Testing (valid + invalid transitions), and Strict Isolation (nominal + one per mock failure).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `extract_branches` | Architecture Interface View (ARCH-004) | Stub: configurable branch list | Drive S&BC scenario count |
| `build_uts_scenario` | Architecture Interface View (ARCH-004) | Spy-stub: records calls, returns fixture UTSEntry | Verify call count per technique |

* **Unit Scenario: UTS-009-A1** — S&BC technique: scenario count equals branch count
  * **Arrange**: Set `utp_entry.technique = "Statement & Branch Coverage"`; set `extract_branches` stub to return 3 branches; set `build_uts_scenario` stub to return fixture `UTSEntry`
  * **Act**: Call `generate_uts_scenarios(utp_entry, mod_module)`
  * **Assert**: `scenarios` length equals 3; `scenario_counter` ends at 4; `build_uts_scenario` spy called exactly 3 times; UTS IDs would be `UTS-NNN-A1`, `UTS-NNN-A2`, `UTS-NNN-A3`

* **Unit Scenario: UTS-009-A2** — BVA technique: exactly 5 boundary scenarios generated
  * **Arrange**: Set `utp_entry.technique = "Boundary Value Analysis"`; set `utp_entry.boundaries` with `min_minus_1=-1`, `min=0`, `mid=128`, `max=255`, `max_plus_1=256`
  * **Act**: Call `generate_uts_scenarios(utp_entry, mod_module)`
  * **Assert**: `scenarios` length equals 5; `scenario_counter` ends at 6; `build_uts_scenario` spy called with conditions `"Input=-1"`, `"Input=0"`, `"Input=128"`, `"Input=255"`, `"Input=256"` in that order

* **Unit Scenario: UTS-009-A3** — Strict Isolation: nominal + mock failure scenarios
  * **Arrange**: Set `utp_entry.technique = "Strict Isolation"`; set `utp_entry.mock_registry = [MockRegistryRow(dependency="db_conn"), MockRegistryRow(dependency="file_sys")]` (both non-"None — self-contained")
  * **Act**: Call `generate_uts_scenarios(utp_entry, mod_module)`
  * **Assert**: `scenarios` length equals 3 (1 nominal + 2 mock failures); first `build_uts_scenario` call condition equals `"All dependencies return expected"`; subsequent calls conditions are `"db_conn returns error"` and `"file_sys returns error"`

#### Test Case: UTP-009-B (Boundary Value Analysis of scenario_counter)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests `scenario_counter` Integer variable at min (1), incremented mid values, and verifies it never drops below 1 (initialized from 1, not 0).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `build_uts_scenario` | Architecture Interface View (ARCH-004) | Stub: returns fixture UTSEntry | Allow execution to complete |
| `extract_branches` | Architecture Interface View (ARCH-004) | Stub: configurable branch count | Drive scenario_counter increments |

* **Unit Scenario: UTS-009-B1** — scenario_counter starts at 1 (minimum): first UTS ID suffix is "1"
  * **Arrange**: Set `utp_entry.technique = "Statement & Branch Coverage"`; set `extract_branches` stub to return 1 branch; `build_uts_scenario` spy records `number` argument
  * **Act**: Call `generate_uts_scenarios(utp_entry, mod_module)`
  * **Assert**: First `build_uts_scenario` call receives `number=1`; `scenario_counter` equals 2 after loop ends; `uts_id` for scenario would be `utp.id + "1"` (e.g., `"UTS-001-A1"`)

* **Unit Scenario: UTS-009-B2** — scenario_counter increments correctly for 3 branches
  * **Arrange**: Set `extract_branches` stub to return 3 branches
  * **Act**: Call `generate_uts_scenarios(utp_entry, mod_module)`
  * **Assert**: `build_uts_scenario` spy called with `number=1`, `number=2`, `number=3` in sequence; `scenarios` length equals 3; no scenario receives `number=0`

---

### Module: MOD-010 (Module Design Template Loader)

**Parent Architecture Modules**: ARCH-005
**Target Source File(s)**: `templates/module-design-template.md`

#### Test Case: UTP-010-A (Statement and Branch Coverage of load_module_design_template)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies: the `file_exists` false branch (raises `TemplateNotFoundError`); the section-validation loop raising `TemplateValidationError` for each missing required section (`module_stub`, `coverage_table`, `derived_section`); and the nominal path returning a populated `TemplateContent` object.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `file_exists` | Architecture Interface View (ARCH-005) | Stub: configurable Boolean | Control file-not-found branch |
| `read_file` | Architecture Interface View (ARCH-005) | Stub: fixture Markdown content | Prevent real filesystem reads |
| `parse_markdown_sections` | Architecture Interface View (ARCH-005) | Stub: configurable section dict | Drive validation loop |
| `extract_commented_blocks` | Architecture Interface View (ARCH-005) | Stub: returns `[]` | Isolate safety-critical block extraction |

* **Unit Scenario: UTS-010-A1** — Template file not found: raises TemplateNotFoundError
  * **Arrange**: Set `file_exists` stub to return `False` for `resolved_path`
  * **Act**: Call `load_module_design_template("templates/module-design-template.md")`
  * **Assert**: `TemplateNotFoundError` raised with message `"Template not found: templates/module-design-template.md"`; `read_file` is never called

* **Unit Scenario: UTS-010-A2** — Required section "module_stub" is None: raises TemplateValidationError
  * **Arrange**: Set `file_exists` stub to return `True`; set `parse_markdown_sections` stub to return `{module_stub: None, coverage_table: "...", derived_section: "..."}`
  * **Act**: Call `load_module_design_template("templates/module-design-template.md")`
  * **Assert**: `TemplateValidationError` raised with message `"Missing required section: module_stub"`

* **Unit Scenario: UTS-010-A3** — All required sections present: returns TemplateContent
  * **Arrange**: Set `file_exists` stub to return `True`; set `parse_markdown_sections` stub to return all required sections non-empty; `extract_commented_blocks` returns `[]`
  * **Act**: Call `load_module_design_template("templates/module-design-template.md")`
  * **Assert**: Returns `TemplateContent` object with `module_stub` non-empty; `coverage_table` non-empty; `derived_section` non-empty; `safety_placeholders` equals `[]`

---

### Module: MOD-011 (Unit Test Template Loader)

**Parent Architecture Modules**: ARCH-006
**Target Source File(s)**: `templates/unit-test-template.md`

#### Test Case: UTP-011-A (Statement and Branch Coverage of load_unit_test_template)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies: `TemplateNotFoundError` raised when file absent; `TemplateValidationError` raised for each missing required section (`utp_stub`, `uts_stub`, `mock_registry_stub`); nominal path returning complete `TemplateContent`.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `file_exists` | Architecture Interface View (ARCH-006) | Stub: configurable Boolean | Control not-found branch |
| `read_file` | Architecture Interface View (ARCH-006) | Stub: fixture Markdown content | Prevent real filesystem reads |
| `parse_markdown_sections` | Architecture Interface View (ARCH-006) | Stub: configurable section dict | Drive validation loop |

* **Unit Scenario: UTS-011-A1** — Template file absent: raises TemplateNotFoundError
  * **Arrange**: Set `file_exists` stub to return `False`
  * **Act**: Call `load_unit_test_template("templates/unit-test-template.md")`
  * **Assert**: `TemplateNotFoundError` raised with message `"Template not found: templates/unit-test-template.md"`; `read_file` never called

* **Unit Scenario: UTS-011-A2** — "uts_stub" section is empty string: raises TemplateValidationError
  * **Arrange**: Set `file_exists` to return `True`; set `parse_markdown_sections` to return `{utp_stub: "...", uts_stub: "", mock_registry: "..."}`
  * **Act**: Call `load_unit_test_template("templates/unit-test-template.md")`
  * **Assert**: `TemplateValidationError` raised with message `"Missing required section: uts_stub"`

* **Unit Scenario: UTS-011-A3** — All sections present: returns TemplateContent with mock_registry_stub
  * **Arrange**: Set `file_exists` to return `True`; set `parse_markdown_sections` to return all three required sections non-empty
  * **Act**: Call `load_unit_test_template("templates/unit-test-template.md")`
  * **Assert**: Returns `TemplateContent` with `utp_stub`, `uts_stub`, and `mock_registry_stub` all non-empty

---

### Module: MOD-012 (Forward Coverage Parser — Bash)

**Parent Architecture Modules**: ARCH-007
**Target Source File(s)**: `scripts/bash/validate-module-coverage.sh`

#### Test Case: UTP-012-A (Statement and Branch Coverage of parse_forward_coverage)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies all branches: the regex match for `ARCH-NNN` lines, deprecated-ARCH filtering branch, `arch_id NOT IN covered_archs` branch (gap detection), the orphaned-MOD branch (parent ARCH not in arch_ids), and `total_arch=0` division guard.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `read_file` | Architecture Interface View (ARCH-007) | Stub: fixture Markdown content | Prevent real filesystem reads |
| `arch_is_deprecated` | Architecture Interface View (ARCH-007) | Stub: configurable Boolean per arch_id | Control deprecated-filtering branch |
| `mod_is_deprecated` | Architecture Interface View (ARCH-007) | Stub: configurable Boolean per mod_id | Control skip-deprecated branch |

* **Unit Scenario: UTS-012-A1** — All ARCH covered by MOD: coverage_pct=100, no gaps
  * **Arrange**: Set `read_file` stub for arch content to contain `"| ARCH-001 |"`; set arch content to contain `"**Parent Architecture Modules**: ARCH-001"` for MOD-001; set all `arch_is_deprecated` stubs to `False`; set all `mod_is_deprecated` stubs to `False`
  * **Act**: Call `parse_forward_coverage(arch_design_path, module_design_path)`
  * **Assert**: `arch_without_mod` equals `[]`; `coverage_pct` equals 100; `has_gaps` equals `False`; `covered_count` equals 1

* **Unit Scenario: UTS-012-A2** — One ARCH has no MOD: gap detected
  * **Arrange**: Set `read_file` arch content to contain `"| ARCH-001 |"` and `"| ARCH-002 |"`; module design content covers only ARCH-001; `mod_to_parents["MOD-001"] = ["ARCH-001"]`
  * **Act**: Call `parse_forward_coverage(arch_design_path, module_design_path)`
  * **Assert**: `arch_without_mod` equals `["ARCH-002"]`; `coverage_pct` equals 50; `has_gaps` equals `True`

* **Unit Scenario: UTS-012-A3** — total_arch=0: coverage_pct returns 0 (division guard)
  * **Arrange**: Set `read_file` arch content to contain no `ARCH-NNN` matches
  * **Act**: Call `parse_forward_coverage(arch_design_path, module_design_path)`
  * **Assert**: `total_arch` equals 0; `coverage_pct` equals 0 (not division-by-zero error); `arch_without_mod` equals `[]`

#### Test Case: UTP-012-B (Boundary Value Analysis of coverage_pct)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests `coverage_pct` Integer variable (range 0–100) at boundary values: 0 (all gaps), 50 (half covered), 100 (full coverage).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `read_file` | Architecture Interface View (ARCH-007) | Stub: fixture content | Drive coverage computation |

* **Unit Scenario: UTS-012-B1** — coverage_pct=0 (min): zero ARCH covered
  * **Arrange**: `arch_ids = ["ARCH-001", "ARCH-002"]`; `covered_archs = Set()` (no MODs point to any ARCH)
  * **Act**: Invoke coverage computation: `covered_count=0`, `total_arch=2`
  * **Assert**: `coverage_pct` equals 0; `arch_without_mod` equals `["ARCH-001", "ARCH-002"]`

* **Unit Scenario: UTS-012-B2** — coverage_pct=50 (mid): half ARCH covered
  * **Arrange**: `arch_ids = ["ARCH-001", "ARCH-002"]`; `covered_archs = {"ARCH-001"}`
  * **Act**: Invoke coverage computation: `covered_count=1`, `total_arch=2`
  * **Assert**: `coverage_pct` equals 50; `arch_without_mod` equals `["ARCH-002"]`

* **Unit Scenario: UTS-012-B3** — coverage_pct=100 (max): all ARCH covered
  * **Arrange**: `arch_ids = ["ARCH-001", "ARCH-002"]`; `covered_archs = {"ARCH-001", "ARCH-002"}`
  * **Act**: Invoke coverage computation: `covered_count=2`, `total_arch=2`
  * **Assert**: `coverage_pct` equals 100; `arch_without_mod` equals `[]`; `has_gaps` equals `False`

---

### Module: MOD-013 (Backward Coverage Parser — Bash)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `scripts/bash/validate-module-coverage.sh`

#### Test Case: UTP-013-A (Statement and Branch Coverage of parse_backward_coverage)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies: the `unit_test_path` absent branch (returns partial-mode result with `skipped=True`); the `[EXTERNAL]` module bypass branch (adds to `external_mods`, not `testable_mods`); the `mod_without_utp` gap detection branch; the orphaned-UTP detection branch; and `[COTS]` tag treated as standard testable MOD.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `read_file` | Architecture Interface View (ARCH-008) | Stub: fixture content per path | Prevent real filesystem reads |
| `file_exists` | Architecture Interface View (ARCH-008) | Stub: configurable Boolean | Control partial-mode branch |
| `mod_is_deprecated` | Architecture Interface View (ARCH-008) | Stub: returns `False` | Avoid skip-deprecated in test |
| `mod_is_external` | Architecture Interface View (ARCH-008) | Stub: configurable Boolean per mod_id | Drive external_mods vs testable_mods split |

* **Unit Scenario: UTS-013-A1** — unit_test_path absent: returns partial mode result
  * **Arrange**: Set `file_exists` stub to return `False` for `unit_test_path`
  * **Act**: Call `parse_backward_coverage(module_design_path, unit_test_path=None)`
  * **Assert**: Returned `BackwardCoverageResult.partial_mode` equals `True`; `skipped` equals `True`; `total_testable` equals 0; `coverage_pct` equals 0; no `read_file` calls occur for module content

* **Unit Scenario: UTS-013-A2** — [EXTERNAL] module excluded from testable_mods
  * **Arrange**: Set `file_exists` to return `True`; module design content has `"### Module: MOD-003"` and `"### Module: MOD-004 [EXTERNAL]"`; set `mod_is_external("MOD-003")=False`, `mod_is_external("MOD-004")=True`; unit test content has `"UTP-003-A"` covering MOD-003
  * **Act**: Call `parse_backward_coverage(module_design_path, unit_test_path)`
  * **Assert**: `testable_mods` equals `["MOD-003"]`; `external_mods` equals `["MOD-004"]`; `mod_without_utp` equals `[]`; `coverage_pct` equals 100

* **Unit Scenario: UTS-013-A3** — Testable MOD with no UTP: gap detected
  * **Arrange**: `testable_mods = ["MOD-005"]`; unit test content contains no `UTP-005-*` identifier of any letter
  * **Act**: Call `parse_backward_coverage(module_design_path, unit_test_path)`
  * **Assert**: `mod_without_utp` equals `["MOD-005"]`; `has_gaps` equals `True`; `coverage_pct` equals 0

#### Test Case: UTP-013-B (Strict Isolation of file system dependencies)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies the module correctly handles `read_file` returning empty string and `file_exists` returning False independently, without masking the partial-mode vs gap scenarios.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `read_file` | Architecture Interface View (ARCH-008) | Stub: returns empty string | Test empty content handling |
| `file_exists` | Architecture Interface View (ARCH-008) | Stub: returns `True` then `False` | Test file-exists vs absent |

* **Unit Scenario: UTS-013-B1** — All mocks return expected values: nominal parse succeeds
  * **Arrange**: Set `file_exists` to return `True`; set `read_file` for module content to return well-formed fixture with `"### Module: MOD-001"`; set `read_file` for unit content to return `"UTP-001-A"` and `"UTS-001-A1"` identifiers; set all `mod_is_external` and `mod_is_deprecated` stubs to `False`
  * **Act**: Call `parse_backward_coverage(module_design_path, unit_test_path)`
  * **Assert**: Returns `BackwardCoverageResult` with `skipped=False`; `total_testable=1`; `covered_count=1`; `has_gaps=False`

* **Unit Scenario: UTS-013-B2** — read_file returns empty string: zero testable mods, no crash
  * **Arrange**: Set `file_exists` to return `True`; set `read_file` for module content to return `""`; set `read_file` for unit content to return `""`
  * **Act**: Call `parse_backward_coverage(module_design_path, unit_test_path)`
  * **Assert**: `testable_mods` equals `[]`; `total_testable` equals 0; `coverage_pct` equals 0; no exception raised

---

### Module: MOD-014 (Module Coverage Validator — PowerShell)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `scripts/powershell/validate-module-coverage.ps1`

#### Test Case: UTP-014-A (Statement and Branch Coverage of Invoke-ModuleCoverageValidator)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies: `Test-Path` false for `arch_path` triggers Exit 1; `Test-Path` false for `module_path` triggers Exit 1; `has_gaps=True` triggers Exit 1; `has_gaps=False` triggers Exit 0; the `Json` flag routes to `ConvertTo-Json` vs `Write-HumanReadableReport`.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `Test-Path` | Architecture Interface View (ARCH-009) | Stub: configurable Boolean per path | Control file-not-found branches |
| `Parse-ForwardCoverage` (MOD-012 equivalent) | Architecture Interface View (ARCH-009) | Stub: returns fixture `ForwardCoverageResult` | Isolate forward parse |
| `Parse-BackwardCoverage` (MOD-013 equivalent) | Architecture Interface View (ARCH-009) | Stub: returns fixture `BackwardCoverageResult` | Isolate backward parse |
| `Write-HumanReadableReport` | Architecture Interface View (ARCH-009) | Spy | Verify human-readable path |

* **Unit Scenario: UTS-014-A1** — arch_path not found: Write-Error and Exit 1
  * **Arrange**: Set `Test-Path(arch_path)` stub to return `$false`; set `Test-Path(module_path)` stub to return `$true`
  * **Act**: Call `Invoke-ModuleCoverageValidator(VModelDir="/path", Json=$false)`
  * **Assert**: `Write-Error` is called with message containing `"architecture-design.md not found"`; process exits with code 1; `Parse-ForwardCoverage` is never called

* **Unit Scenario: UTS-014-A2** — Coverage gaps found: Exit 1
  * **Arrange**: Set both `Test-Path` stubs to `$true`; set `Parse-ForwardCoverage` stub to return `{has_gaps=$true}`; set `Parse-BackwardCoverage` stub to return `{has_gaps=$false}`
  * **Act**: Call `Invoke-ModuleCoverageValidator(VModelDir="/path", Json=$false)`
  * **Assert**: `has_gaps` equals `$true`; process exits with code 1; `Write-HumanReadableReport` spy is called once

#### Test Case: UTP-014-B (Equivalence Partitioning of Json Boolean flag)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions the `Json` Boolean parameter into True (JSON output path) and False (human-readable path) to verify correct output function is invoked.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `Test-Path` | Architecture Interface View (ARCH-009) | Stub: returns `$true` | Allow execution past file-check |
| `Parse-ForwardCoverage` | Architecture Interface View (ARCH-009) | Stub: returns no-gap result | Allow execution to Step 5 |
| `Parse-BackwardCoverage` | Architecture Interface View (ARCH-009) | Stub: returns no-gap result | Allow execution to Step 5 |
| `Write-Output` | Architecture Interface View (ARCH-009) | Spy | Verify JSON output path |
| `Write-HumanReadableReport` | Architecture Interface View (ARCH-009) | Spy | Verify human-readable path |

* **Unit Scenario: UTS-014-B1** — Json=$true: ConvertTo-Json output path invoked
  * **Arrange**: Set all prerequisites to success; `has_gaps=$false`
  * **Act**: Call `Invoke-ModuleCoverageValidator(VModelDir="/path", Json=$true)`
  * **Assert**: `Write-Output` spy receives JSON-formatted string containing keys `total_arch`, `has_gaps`; `Write-HumanReadableReport` spy is never called

* **Unit Scenario: UTS-014-B2** — Json=$false: human-readable report path invoked
  * **Arrange**: Set all prerequisites to success; `has_gaps=$false`
  * **Act**: Call `Invoke-ModuleCoverageValidator(VModelDir="/path", Json=$false)`
  * **Assert**: `Write-HumanReadableReport` spy is called once; `Write-Output` spy does not receive JSON string; process exits with code 0

---

### Module: MOD-015 (Matrix D Data Extractor — Bash)

**Parent Architecture Modules**: ARCH-010
**Target Source File(s)**: `scripts/bash/build-matrix.sh`

#### Test Case: UTP-015-A (Statement and Branch Coverage of extract_matrix_d_data)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies: `[CROSS-CUTTING]` line match populates `arch_sys_map` with `"[CROSS-CUTTING]"` value; `unit_path` absent → `mod_to_utps` and `utp_to_uts` remain empty `{}`; `mod_tags` populated when `[EXTERNAL]` present in module header line; UTP and UTS regex matching populates correct maps.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `read_file` | Architecture Interface View (ARCH-010) | Stub: fixture Markdown content | Prevent real filesystem reads |
| `file_exists` | Architecture Interface View (ARCH-010) | Stub: configurable Boolean | Control unit_path optional branch |

* **Unit Scenario: UTS-015-A1** — unit_path absent: mod_to_utps and utp_to_uts are empty
  * **Arrange**: Set `file_exists(unit_path)` to return `False`; arch content has `"| ARCH-001 | ... | SYS-001 |"`; module content has `"### Module: MOD-001"` and `"**Parent Architecture Modules**: ARCH-001"`
  * **Act**: Call `extract_matrix_d_data(arch_path, module_path, unit_path=None)`
  * **Assert**: `mod_to_utps` equals `{}`; `utp_to_uts` equals `{}`; `arch_to_mods["ARCH-001"]` equals `["MOD-001"]`

* **Unit Scenario: UTS-015-A2** — [CROSS-CUTTING] ARCH: arch_sys_map entry is "[CROSS-CUTTING]"
  * **Arrange**: Arch content line is `"| ARCH-017 | ... [CROSS-CUTTING] ..."`; module content covers ARCH-017 with MOD-024
  * **Act**: Call `extract_matrix_d_data(arch_path, module_path, unit_path=None)`
  * **Assert**: `arch_sys_map["ARCH-017"]` equals `"[CROSS-CUTTING]"`; `arch_to_mods["ARCH-017"]` equals `["MOD-024"]`

* **Unit Scenario: UTS-015-A3** — unit_path present: UTP and UTS maps populated from unit content
  * **Arrange**: Set `file_exists(unit_path)` to return `True`; unit content contains `"UTP-001-A"` and `"UTS-001-A1"`, `"UTS-001-A2"`
  * **Act**: Call `extract_matrix_d_data(arch_path, module_path, unit_test_path)`
  * **Assert**: `mod_to_utps["MOD-001"]` equals `["UTP-001-A"]`; `utp_to_uts["UTP-001-A"]` equals `["UTS-001-A1", "UTS-001-A2"]`

---

### Module: MOD-016 (Available Artifacts Detector)

**Parent Architecture Modules**: ARCH-011
**Target Source File(s)**: `commands/trace.md`

#### Test Case: UTP-016-A (Statement and Branch Coverage of detect_available_artifacts)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies each conditional branch: `has_module_design=True AND has_unit_test=True` → full Matrix D; `has_module_design=True AND has_unit_test=False` → partial mode; neither present → silent backward-compatible skip (matrices A/B/C only, no warning).

**Dependency & Mock Registry:**

None — module is self-contained (operates on the `available_docs` list argument only)

* **Unit Scenario: UTS-016-A1** — Both module-design.md and unit-test.md present: full mode
  * **Arrange**: Set `available_docs = ["module-design.md", "unit-test.md"]`
  * **Act**: Call `detect_available_artifacts(available_docs)`
  * **Assert**: `plan.matrices` equals `["A", "B", "C", "D"]`; `plan.matrix_d_mode` equals `"full"`; `plan.unit_test_col_text` equals `NULL`

* **Unit Scenario: UTS-016-A2** — module-design.md present, unit-test.md absent: partial mode
  * **Arrange**: Set `available_docs = ["module-design.md"]`
  * **Act**: Call `detect_available_artifacts(available_docs)`
  * **Assert**: `plan.matrices` equals `["A", "B", "C", "D"]`; `plan.matrix_d_mode` equals `"partial"`; `plan.unit_test_col_text` equals `"Unit test plan not yet generated"`

* **Unit Scenario: UTS-016-A3** — Neither artifact present: silent skip with matrices A/B/C
  * **Arrange**: Set `available_docs = ["requirements.md"]`
  * **Act**: Call `detect_available_artifacts(available_docs)`
  * **Assert**: `plan.matrices` equals `["A", "B", "C"]`; `plan.matrix_d_mode` equals `"skip"`; `plan.emit_warning` equals `False`; no warning is raised

#### Test Case: UTP-016-B (Equivalence Partitioning of Boolean flags)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions `has_module_design` and `has_unit_test` Boolean variables into all four (True/False × True/False) combinations to verify each routes to the correct plan.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-016-B1** — has_module_design=False, has_unit_test=False: matrices=["A","B","C"]
  * **Arrange**: `available_docs = []`
  * **Act**: Call `detect_available_artifacts(available_docs)`
  * **Assert**: `has_module_design=False`; `has_unit_test=False`; `plan.matrix_d_mode` equals `"skip"`

* **Unit Scenario: UTS-016-B2** — has_module_design=False, has_unit_test=True: treated as skip (no module design → no Matrix D)
  * **Arrange**: `available_docs = ["unit-test.md"]` (unit test without module design — invalid state)
  * **Act**: Call `detect_available_artifacts(available_docs)`
  * **Assert**: `has_module_design=False`; plan falls through to skip branch; `plan.matrices` equals `["A", "B", "C"]`

---

### Module: MOD-017 (Matrix D Table Renderer)

**Parent Architecture Modules**: ARCH-011
**Target Source File(s)**: `commands/trace.md`

#### Test Case: UTP-017-A (Statement and Branch Coverage of render_matrix_d_table)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies: `plan.matrix_d_mode="skip"` → returns empty string immediately; `[EXTERNAL]` MOD → `"N/A — External"` columns; `partial` mode → `plan.unit_test_col_text` as column value; `full` mode with no UTPs → `"❌ No UTP"` cell; `full` mode with UTPs → UTS IDs joined in cell.

**Dependency & Mock Registry:**

None — module is self-contained (operates on in-memory MatrixDData and MatrixGenerationPlan)

* **Unit Scenario: UTS-017-A1** — matrix_d_mode="skip": returns empty string
  * **Arrange**: Set `plan.matrix_d_mode = "skip"`
  * **Act**: Call `render_matrix_d_table(matrix_data, plan)`
  * **Assert**: Returns `""` (empty string); `table_lines` is never initialized

* **Unit Scenario: UTS-017-A2** — [EXTERNAL] MOD in full mode: "N/A — External" in UTP/UTS columns
  * **Arrange**: Set `plan.matrix_d_mode = "full"`; set `matrix_data.mod_tags["MOD-001"] = "[EXTERNAL]"`; set `matrix_data.arch_to_mods["ARCH-001"] = ["MOD-001"]`; `arch_sys_map["ARCH-001"] = "SYS-001"`
  * **Act**: Call `render_matrix_d_table(matrix_data, plan)`
  * **Assert**: `table_lines` contains a row with `"MOD-001 [EXTERNAL]"`, `"N/A — External"` in UTP column, `"N/A — External"` in UTS column

* **Unit Scenario: UTS-017-A3** — Full mode: MOD with no UTPs renders "❌ No UTP" cell
  * **Arrange**: Set `plan.matrix_d_mode = "full"`; `matrix_data.mod_to_utps["MOD-002"] = []`; `mod_tags["MOD-002"] = ""`; `arch_to_mods["ARCH-002"] = ["MOD-002"]`
  * **Act**: Call `render_matrix_d_table(matrix_data, plan)`
  * **Assert**: `table_lines` contains a row with `"MOD-002"` and `"❌ No UTP"` in UTP column; UTS column is `"—"`

#### Test Case: UTP-017-B (Equivalence Partitioning of first_mod_row Boolean)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions `first_mod_row` into True (ARCH-ID and SYS-col rendered) and False ("—" rendered in those columns) to verify the row-collapse logic works correctly for multi-MOD ARCH entries.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-017-B1** — first_mod_row=True: ARCH-ID and sys_col in first row
  * **Arrange**: Set `plan.matrix_d_mode = "full"`; `arch_to_mods["ARCH-001"] = ["MOD-001", "MOD-002"]`; both MODs have UTPs; `arch_sys_map["ARCH-001"] = "SYS-001"`
  * **Act**: Call `render_matrix_d_table(matrix_data, plan)`
  * **Assert**: First row for ARCH-001 contains `"ARCH-001"` and `"(SYS-001)"`; subsequent MOD-002 row contains `"—"` and `"—"` in those columns

* **Unit Scenario: UTS-017-B2** — first_mod_row=False: "—" in ARCH and SYS columns
  * **Arrange**: Same as UTS-017-B1 setup (two MODs for same ARCH)
  * **Act**: Inspect second rendered row for ARCH-001's second MOD (MOD-002)
  * **Assert**: Second row starts with `"| — | — | MOD-002 |"`; `first_mod_row` was reset to `False` after first iteration

---

### Module: MOD-018 (Matrix D Data Extractor — PowerShell)

**Parent Architecture Modules**: ARCH-012
**Target Source File(s)**: `scripts/powershell/build-matrix.ps1`

#### Test Case: UTP-018-A (Statement and Branch Coverage of Get-MatrixDData)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies: `Get-Content` reads arch and module files; regex `-match` for ARCH→SYS mapping populates `arch_sys_map`; `[CROSS-CUTTING]` regex match adds cross-cutting entry; `arch_to_mods` is built from Parent Architecture Modules field; `UnitPath=$null` leaves `mod_to_utps` and `utp_to_uts` empty.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `Get-Content` | Architecture Interface View (ARCH-012) | Mock: returns fixture string array | Prevent real filesystem reads |
| `Test-Path` | Architecture Interface View (ARCH-012) | Stub: configurable Boolean | Control UnitPath optional branch |

* **Unit Scenario: UTS-018-A1** — UnitPath=$null: mod_to_utps and utp_to_uts are empty hashtables
  * **Arrange**: Set `Get-Content` mock for arch path to return arch fixture; `Get-Content` for module path to return module fixture; `UnitPath=$null`
  * **Act**: Call `Get-MatrixDData(ArchPath, ModulePath, UnitPath=$null)`
  * **Assert**: `mod_to_utps` equals `@{}`; `utp_to_uts` equals `@{}`; `arch_sys_map` is populated from arch content

* **Unit Scenario: UTS-018-A2** — Cross-cutting ARCH: arch_sys_map entry equals "[CROSS-CUTTING]"
  * **Arrange**: Arch content line is `"| ARCH-017 | ... [CROSS-CUTTING] ..."`
  * **Act**: Call `Get-MatrixDData(ArchPath, ModulePath, UnitPath=$null)`
  * **Assert**: `arch_sys_map["ARCH-017"]` equals `"[CROSS-CUTTING]"` in returned PSCustomObject

* **Unit Scenario: UTS-018-A3** — File not found: Write-Error and Exit 1
  * **Arrange**: Set `Test-Path(ArchPath)` stub to return `$false`
  * **Act**: Call `Get-MatrixDData(ArchPath="nonexistent.md", ModulePath, UnitPath=$null)`
  * **Assert**: `Write-Error` is called with message containing `"File not found: nonexistent.md"`; process exits 1; no data maps are returned

---

### Module: MOD-019 (Setup Module-Level Flag Handler)

**Parent Architecture Modules**: ARCH-013
**Target Source File(s)**: `scripts/bash/setup-v-model.sh, scripts/powershell/setup-v-model.ps1`

#### Test Case: UTP-019-A (Statement and Branch Coverage of handle_module_level_flags)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies: `--require-module-design` flag present + module-design.md absent → stderr + Exit 1; `--require-unit-test` flag present + unit-test.md absent → stderr + Exit 1; both flags absent → backward-compatible output with no new validation; module-design.md present → appended to `available_docs`.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `detect_available_docs` | Architecture Interface View (ARCH-013) | Stub: returns base doc list | Isolate base detection |
| `file_exists` | Architecture Interface View (ARCH-013) | Stub: configurable per path | Control module-level file detection |
| `get_repo_root` | Architecture Interface View (ARCH-013) | Stub: returns "/repo" | Deterministic path resolution |
| `get_current_branch` | Architecture Interface View (ARCH-013) | Stub: returns "004-module-unit" | Deterministic branch name |

* **Unit Scenario: UTS-019-A1** — --require-module-design flag and module-design.md absent: stderr + Exit 1
  * **Arrange**: Set `args = ["--require-module-design"]`; set `file_exists(vmodel_dir + "/module-design.md")` to return `False`
  * **Act**: Call `handle_module_level_flags(args, vmodel_dir, json_mode=True)`
  * **Assert**: Stderr contains `"module-design.md is required but not found in " + vmodel_dir`; process exits with code 1; `result` is never constructed

* **Unit Scenario: UTS-019-A2** — No new flags: backward-compatible output, available_docs unchanged
  * **Arrange**: Set `args = ["--json"]` (no new flags); set `detect_available_docs` stub to return `["requirements.md"]`; set `file_exists` for module-design.md to return `False`, unit-test.md to return `False`
  * **Act**: Call `handle_module_level_flags(args, vmodel_dir, json_mode=True)`
  * **Assert**: `require_module_design` equals `False`; `require_unit_test` equals `False`; `available_docs` equals `["requirements.md"]` (no new items appended); `result.MODULE_DESIGN` path is present in JSON output

* **Unit Scenario: UTS-019-A3** — Both new files present: both appended to available_docs
  * **Arrange**: Set `file_exists(module-design.md)` to return `True`; set `file_exists(unit-test.md)` to return `True`; `detect_available_docs` returns base list `["requirements.md"]`
  * **Act**: Call `handle_module_level_flags(args, vmodel_dir, json_mode=False)`
  * **Assert**: `available_docs` contains `"module-design.md"` and `"unit-test.md"` appended; `result.AVAILABLE_DOCS` length equals 3

#### Test Case: UTP-019-B (Equivalence Partitioning of require_module_design Boolean)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions `require_module_design` Boolean into True-with-file-present, True-with-file-absent, and False to verify correct validation behavior per partition.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `file_exists` | Architecture Interface View (ARCH-013) | Stub: configurable Boolean | Inject each partition condition |

* **Unit Scenario: UTS-019-B1** — require_module_design=True and file present: validation passes
  * **Arrange**: `args = ["--require-module-design"]`; `file_exists(module-design.md)` returns `True`
  * **Act**: Call `handle_module_level_flags(args, vmodel_dir, json_mode=False)`
  * **Assert**: No stderr output; no Exit 1; `available_docs` contains `"module-design.md"`

* **Unit Scenario: UTS-019-B2** — require_module_design=True and file absent: Exit 1
  * **Arrange**: `args = ["--require-module-design"]`; `file_exists(module-design.md)` returns `False`
  * **Act**: Call `handle_module_level_flags(args, vmodel_dir, json_mode=False)`
  * **Assert**: Exit 1; stderr message contains `"module-design.md is required but not found"`

* **Unit Scenario: UTS-019-B3** — require_module_design=False: no validation, continues normally
  * **Arrange**: `args = []`; `file_exists(module-design.md)` returns `False`
  * **Act**: Call `handle_module_level_flags(args, vmodel_dir, json_mode=False)`
  * **Assert**: No Exit 1; `require_module_design` equals `False`; function completes and returns result

---

### Module: MOD-020 (Extension Manifest v0.4.0 Registrar)

**Parent Architecture Modules**: ARCH-014
**Target Source File(s)**: `extension.yml`

#### Test Case: UTP-020-A (Statement and Branch Coverage of update_extension_manifest)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies: the `command_exists` check preventing duplicate registration; `ManifestError` raised when final command count ≠ 9; `ManifestError` raised when hook count ≠ 1; each new ID prefix appended only when not already present; version set to "0.4.0".

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `parse_yaml` | Architecture Interface View (ARCH-014) | Stub: returns fixture manifest dict | Prevent real YAML parse |
| `read_file` | Architecture Interface View (ARCH-014) | Stub: returns fixture YAML string | Prevent real filesystem reads |
| `write_file` | Architecture Interface View (ARCH-014) | Spy | Verify manifest write |

* **Unit Scenario: UTS-020-A1** — Nominal update: version set to 0.4.0, 2 commands added, count=9
  * **Arrange**: Set `parse_yaml` stub to return manifest with `version="0.3.0"`, 7 commands (none named "speckit.v-model.module-design" or "speckit.v-model.unit-test"), 1 hook, `id_prefixes=["REQ","SYS","ARCH"]`
  * **Act**: Call `update_extension_manifest(manifest_path)`
  * **Assert**: `current_manifest["version"]` equals `"0.4.0"`; `current_commands` length equals 9; `id_prefixes` contains `"MOD"`, `"UTP"`, `"UTS"`; `write_file` spy is called once

* **Unit Scenario: UTS-020-A2** — Command already registered: duplicate skip branch taken
  * **Arrange**: Manifest has 8 commands including `"speckit.v-model.module-design"` but not `"speckit.v-model.unit-test"`; `hooks` count=1
  * **Act**: Call `update_extension_manifest(manifest_path)`
  * **Assert**: `"speckit.v-model.module-design"` appears exactly once in final `current_commands`; total command count equals 9 after adding only unit-test command

* **Unit Scenario: UTS-020-A3** — Hook count ≠ 1: ManifestError raised before write
  * **Arrange**: Manifest has 7 commands, 2 hooks
  * **Act**: Call `update_extension_manifest(manifest_path)`
  * **Assert**: `ManifestError` raised with message `"Expected exactly 1 hook; got 2"`; `write_file` spy is never called

#### Test Case: UTP-020-B (Boundary Value Analysis of current_commands length)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests `current_commands` List length at boundary values relative to the expected v0.3.0 baseline (7): min-1=6 (triggers warning), min=7 (nominal baseline), expected-post=9 (successful update), max+1=10 (triggers ManifestError).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `parse_yaml` | Architecture Interface View (ARCH-014) | Stub: configurable command count | Drive boundary conditions |
| `write_file` | Architecture Interface View (ARCH-014) | Spy | Verify write behavior |

* **Unit Scenario: UTS-020-B1** — 6 commands (min-1): WARN emitted, update proceeds
  * **Arrange**: Manifest has 6 commands, 1 hook; neither new command is present
  * **Act**: Call `update_extension_manifest(manifest_path)`
  * **Assert**: `WARN` is called with message containing `"Expected 7 commands at v0.3.0 baseline; found 6"`; update still adds 2 commands; final count=8; `ManifestError` raised (8 ≠ 9); `write_file` not called

* **Unit Scenario: UTS-020-B2** — 7 commands (min): nominal baseline, no warning
  * **Arrange**: Manifest has 7 commands, 1 hook; neither new command is present
  * **Act**: Call `update_extension_manifest(manifest_path)`
  * **Assert**: No `WARN` emitted about command count; after adding 2 commands, `length(current_commands)` equals 9; `write_file` is called once

* **Unit Scenario: UTS-020-B3** — 10 commands post-update (max+1): ManifestError raised
  * **Arrange**: Manifest has 9 commands initially but neither new command is present (so after adding 2: count=11); hooks=1
  * **Act**: Call `update_extension_manifest(manifest_path)`
  * **Assert**: `ManifestError` raised with message `"Expected exactly 9 commands after update; got 11"`; `write_file` spy is never called

---

### Module: MOD-021 (Module Design Structural Evaluator)

**Parent Architecture Modules**: ARCH-015
**Target Source File(s)**: `tests/evals/test_module_design_eval.py`

#### Test Case: UTP-021-A (Statement and Branch Coverage of evaluate_module_design_structure)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies each assertion branch: deprecated MOD skipped; `[EXTERNAL]` MOD pseudocode assertion bypassed; missing pseudocode block appends failure; State Machine View missing both Mermaid and stateless bypass appends failure; missing data structures section appends failure; missing Target Source File(s) field appends failure; all assertions passed → returned result has `passed=True`.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `read_file` | Architecture Interface View (ARCH-015) | Stub: fixture module-design.md content | Prevent real filesystem reads |
| `parse_mod_entries` | Architecture Interface View (ARCH-015) | Stub: returns configurable List[ModEntry] | Drive assertion loop without full parser |

* **Unit Scenario: UTS-021-A1** — Non-EXTERNAL MOD missing pseudocode block: failure appended
  * **Arrange**: Set `parse_mod_entries` stub to return `[ModEntry(id="MOD-007", header="", algorithmic_view_section="no fenced block here", state_machine_section="N/A — Stateless", data_structures_section="| Name |", error_handling_section="| Error |", header_block="**Target Source File(s)**: ...\n**Parent Architecture Modules**: ...")]`
  * **Act**: Call `evaluate_module_design_structure(module_design_path)`
  * **Assert**: `failures` contains `"MOD-007: missing fenced pseudocode block"`; `result.passed` equals `False`; `result.total` equals 1

* **Unit Scenario: UTS-021-A2** — Deprecated MOD: all assertions skipped
  * **Arrange**: Set `parse_mod_entries` stub to return `[ModEntry(id="MOD-003", header="[DEPRECATED — Withdrawn: reason]", ...)]`
  * **Act**: Call `evaluate_module_design_structure(module_design_path)`
  * **Assert**: `failures` remains `[]`; `result.passed` equals `True`; no assertions run against that MOD

* **Unit Scenario: UTS-021-A3** — All assertions pass for valid non-EXTERNAL MOD
  * **Arrange**: `ModEntry` has `algorithmic_view_section` containing `` ```pseudocode ``; `state_machine_section` containing `"N/A — Stateless"`; non-empty `data_structures_section`; non-empty `error_handling_section`; `header_block` with both required fields
  * **Act**: Call `evaluate_module_design_structure(module_design_path)`
  * **Assert**: `failures` equals `[]`; `result.passed` equals `True`; `result.total` equals 1

---

### Module: MOD-022 (Unit Test Structural Evaluator)

**Parent Architecture Modules**: ARCH-015
**Target Source File(s)**: `tests/evals/test_unit_test_eval.py`

#### Test Case: UTP-022-A (Statement and Branch Coverage of evaluate_unit_test_structure)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies each assertion branch: invalid technique name appends failure; missing mock registry table appends failure; UTP with zero UTS appends failure; orphaned UTP (parent MOD not found) appends failure; `[EXTERNAL]` MOD missing skip notation appends failure; all assertions passed → `passed=True`.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `read_file` | Architecture Interface View (ARCH-015) | Stub: fixture content | Prevent real filesystem reads |
| `parse_utp_entries` | Architecture Interface View (ARCH-015) | Stub: returns configurable List[UTPEntry] | Drive assertion loop |
| `parse_mod_entries` | Architecture Interface View (ARCH-015) | Stub: returns configurable List[ModEntry] | Drive orphan and EXTERNAL checks |

* **Unit Scenario: UTS-022-A1** — UTP with invalid technique name: failure appended
  * **Arrange**: `parse_utp_entries` returns `[UTPEntry(id="UTP-003-A", technique_field="Random Method", mock_registry_section="| Dependency | Mock |", uts_list=["UTS-003-A1"])]`; `parse_mod_entries` returns `[ModEntry(id="MOD-003")]`
  * **Act**: Call `evaluate_unit_test_structure(unit_test_path, module_design_path)`
  * **Assert**: `failures` contains `"UTP-003-A: missing or invalid technique name"`; `result.passed` equals `False`

* **Unit Scenario: UTS-022-A2** — UTP with no UTS scenarios: failure appended
  * **Arrange**: `parse_utp_entries` returns `[UTPEntry(id="UTP-005-A", technique_field="Statement & Branch Coverage", mock_registry_section="| Dependency | Mock |", uts_list=[])]`; `parse_mod_entries` returns `[ModEntry(id="MOD-005")]`
  * **Act**: Call `evaluate_unit_test_structure(unit_test_path, module_design_path)`
  * **Assert**: `failures` contains `"UTP-005-A: no UTS scenarios found"`; `result.passed` equals `False`

* **Unit Scenario: UTS-022-A3** — All assertions pass: result.passed=True
  * **Arrange**: `parse_utp_entries` returns one valid UTPEntry with recognized technique, mock registry table, and one UTS scenario; `parse_mod_entries` returns matching MOD with same number
  * **Act**: Call `evaluate_unit_test_structure(unit_test_path, module_design_path)`
  * **Assert**: `failures` equals `[]`; `result.passed` equals `True`; `result.total` equals 1

---

### Module: MOD-023 (Semantic Pseudocode Quality Evaluator)

**Parent Architecture Modules**: ARCH-016
**Target Source File(s)**: `tests/evals/test_module_design_eval.py`

#### Test Case: UTP-023-A (Statement and Branch Coverage of evaluate_pseudocode_quality)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies: zero pseudocode blocks → returns empty QualityResult with `passed=True`; LLM judge returns "FAIL" → `QualityFailure` appended with mod_id and reason; LLM judge returns "PASS" → no failure appended; `JudgeUnavailableError` → log warning and skip (mark inconclusive, no crash).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `read_file` | Architecture Interface View (ARCH-016) | Stub: fixture content with/without pseudocode | Drive block extraction |
| `llm_judge.evaluate` | Architecture Interface View (ARCH-016) | Mock: configurable judgment response | Isolate LLM from real API |
| `re.findall` | Architecture Interface View (ARCH-016) | Stub: returns configurable block list | Isolate regex from content |

* **Unit Scenario: UTS-023-A1** — LLM judge returns FAIL: QualityFailure appended
  * **Arrange**: Set `re.findall` stub to return one pseudocode block with `mod_id="MOD-007"`; set `llm_judge.evaluate` mock to return `Judgment(score="FAIL", reason="Uses vague phrase 'process data'")`
  * **Act**: Call `evaluate_pseudocode_quality(module_design_path, llm_judge)`
  * **Assert**: `quality_failures` length equals 1; `quality_failures[0].mod_id` equals `"MOD-007"`; `quality_failures[0].message` contains `"pseudocode lacks implementation-level specificity"`; `result.passed` equals `False`

* **Unit Scenario: UTS-023-A2** — LLM judge returns PASS: no failure appended
  * **Arrange**: Set `re.findall` stub to return one block; set `llm_judge.evaluate` mock to return `Judgment(score="PASS", reason="")`
  * **Act**: Call `evaluate_pseudocode_quality(module_design_path, llm_judge)`
  * **Assert**: `quality_failures` equals `[]`; `result.passed` equals `True`; `result.total_evaluated` equals 1

* **Unit Scenario: UTS-023-A3** — No pseudocode blocks: returns empty QualityResult
  * **Arrange**: Set `re.findall` stub to return `[]`
  * **Act**: Call `evaluate_pseudocode_quality(module_design_path, llm_judge)`
  * **Assert**: `pseudocode_blocks` equals `[]`; `quality_failures` equals `[]`; `result.total_evaluated` equals 0; `llm_judge.evaluate` is never called

#### Test Case: UTP-023-B (Strict Isolation of LLM judge dependency)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies that when `llm_judge.evaluate` raises `JudgeUnavailableError`, the function logs a warning, skips quality evaluation for that block, and does not propagate the exception.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `llm_judge.evaluate` | Architecture Interface View (ARCH-016) | Mock: raises `JudgeUnavailableError` | Simulate API failure |
| `re.findall` | Architecture Interface View (ARCH-016) | Stub: returns one block | Force one llm_judge call |
| `LOG_WARNING` | Architecture Interface View (ARCH-016) | Spy | Verify warning is emitted |

* **Unit Scenario: UTS-023-B1** — JudgeUnavailableError: warning logged, no crash, no failure appended
  * **Arrange**: Set `re.findall` stub to return one block; set `llm_judge.evaluate` mock to raise `JudgeUnavailableError("API timeout")`
  * **Act**: Call `evaluate_pseudocode_quality(module_design_path, llm_judge)`
  * **Assert**: No exception propagates from `evaluate_pseudocode_quality`; `LOG_WARNING` spy is called; `quality_failures` remains `[]`; CI result is `"inconclusive"`

* **Unit Scenario: UTS-023-B2** — JudgeParseError: retry once, then default PASS
  * **Arrange**: Set `llm_judge.evaluate` mock to raise `JudgeParseError` on first call, then return `Judgment(score="PASS")` on second call
  * **Act**: Call `evaluate_pseudocode_quality(module_design_path, llm_judge)`
  * **Assert**: `llm_judge.evaluate` spy called exactly twice; `quality_failures` remains `[]` (conservative PASS default); no exception raised

---

### Module: MOD-024 (Tag Routing Logic) [CROSS-CUTTING]

**Parent Architecture Modules**: ARCH-017
**Target Source File(s)**: `commands/module-design.md, commands/unit-test.md, scripts/bash/validate-module-coverage.sh, scripts/powershell/validate-module-coverage.ps1, scripts/bash/build-matrix.sh, scripts/powershell/build-matrix.ps1, commands/trace.md`

#### Test Case: UTP-024-A (Statement and Branch Coverage of route_module_tag)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies every tag branch in `route_module_tag`: `[EXTERNAL]` routes to context-specific decisions; `[CROSS-CUTTING]` routes to context-specific decisions; `[DERIVED MODULE:]` prefix returns `FLAG_DERIVED` regardless of context; `[COTS]` logs warning and returns `DECOMPOSE_FULL`; unrecognized tag returns `DECOMPOSE_FULL`; no-tag (empty string) returns `DECOMPOSE_FULL`.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| `LOG_WARNING` | Architecture Interface View (ARCH-017) | Spy | Verify [COTS] and unrecognized tags emit warning |

* **Unit Scenario: UTS-024-A1** — [EXTERNAL] tag in unit_test_command context: returns SKIP_UTP
  * **Arrange**: Set `tag_string = "[EXTERNAL]"`; set `context = RoutingContext.unit_test_command`
  * **Act**: Call `route_module_tag(tag_string, context)`
  * **Assert**: Returns `RoutingDecision.SKIP_UTP`; `normalized_tag` equals `"[EXTERNAL]"`; `LOG_WARNING` spy is never called

* **Unit Scenario: UTS-024-A2** — [CROSS-CUTTING] tag in validation_script context: returns REQUIRE_COVERAGE
  * **Arrange**: Set `tag_string = " [CROSS-CUTTING] "` (with leading/trailing whitespace); set `context = RoutingContext.validation_script`
  * **Act**: Call `route_module_tag(tag_string, context)`
  * **Assert**: `normalized_tag` equals `"[CROSS-CUTTING]"` (whitespace stripped); returns `RoutingDecision.REQUIRE_COVERAGE`

* **Unit Scenario: UTS-024-A3** — [COTS] tag: LOG_WARNING emitted, returns DECOMPOSE_FULL
  * **Arrange**: Set `tag_string = "[COTS]"`; set `context = RoutingContext.module_design_command`
  * **Act**: Call `route_module_tag(tag_string, context)`
  * **Assert**: `LOG_WARNING` spy is called with message containing `"[COTS] tag not recognized"`; returns `RoutingDecision.DECOMPOSE_FULL`

* **Unit Scenario: UTS-024-A4** — [DERIVED MODULE:] tag: returns FLAG_DERIVED regardless of context
  * **Arrange**: Set `tag_string = "[DERIVED MODULE: untraceable module]"`; set `context = RoutingContext.matrix_builder`
  * **Act**: Call `route_module_tag(tag_string, context)`
  * **Assert**: Returns `RoutingDecision.FLAG_DERIVED`; `LOG_WARNING` is never called; no context-specific sub-branch is entered

#### Test Case: UTP-024-B (Equivalence Partitioning of context RoutingContext enum)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: For a fixed `[EXTERNAL]` tag, partitions the `context` RoutingContext enum into all four values to verify each maps to its expected RoutingDecision.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-024-B1** — context=module_design_command: returns WRAPPER_ONLY
  * **Arrange**: Set `tag_string = "[EXTERNAL]"`; `context = RoutingContext.module_design_command`
  * **Act**: Call `route_module_tag(tag_string, context)`
  * **Assert**: Returns `RoutingDecision.WRAPPER_ONLY`

* **Unit Scenario: UTS-024-B2** — context=unit_test_command: returns SKIP_UTP
  * **Arrange**: Set `tag_string = "[EXTERNAL]"`; `context = RoutingContext.unit_test_command`
  * **Act**: Call `route_module_tag(tag_string, context)`
  * **Assert**: Returns `RoutingDecision.SKIP_UTP`

* **Unit Scenario: UTS-024-B3** — context=validation_script: returns BYPASS_VALIDATION
  * **Arrange**: Set `tag_string = "[EXTERNAL]"`; `context = RoutingContext.validation_script`
  * **Act**: Call `route_module_tag(tag_string, context)`
  * **Assert**: Returns `RoutingDecision.BYPASS_VALIDATION`

* **Unit Scenario: UTS-024-B4** — context=matrix_builder: returns EXTERNAL_ANNOTATION
  * **Arrange**: Set `tag_string = "[EXTERNAL]"`; `context = RoutingContext.matrix_builder`
  * **Act**: Call `route_module_tag(tag_string, context)`
  * **Assert**: Returns `RoutingDecision.EXTERNAL_ANNOTATION`

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Modules (MOD) | 24 (24 active, 0 deprecated) |
| Modules tested | 24 (no [EXTERNAL] modules) |
| Modules bypassed ([EXTERNAL]) | 0 |
| Total Test Cases (UTP) | 40 |
| Total Scenarios (UTS) | 110 |
| Modules with ≥1 UTP | 24 / 24 (100%) |
| Test Cases with ≥1 UTS | 40 / 40 (100%) |
| **Overall Coverage (MOD→UTP)** | **100%** |

### Technique Distribution

| Technique | Test Cases | Percentage |
|-----------|-----------|------------|
| Statement & Branch Coverage | 24 | 60% |
| Boundary Value Analysis | 4 | 10% |
| Equivalence Partitioning | 8 | 20% |
| Strict Isolation | 2 | 5% |
| State Transition Testing | 2 | 5% |

## Uncovered Modules

None — full coverage achieved.

---

## Coverage Gate (IEEE 1012:2016 / ISO/IEC/IEEE 29119-4:2021)

### Script Validation

`validate-module-coverage.sh specs/004-module-unit/v-model` — **PASS**

```
=== Module-Level Coverage Validation ===

Totals: 17 ARCH | 24 MOD (0 external) | 40 UTPs | 110 UTSs
ARCH → MOD coverage: 17/17 (100%)
MOD → UTP coverage: 24/24 (100%) [excluding 0 external]
UTP → UTS coverage: 40/40 (100%)

✅ Full module-level coverage — all architecture modules decomposed, all testable modules have unit tests.
```

1. **Forward coverage**: every ARCH-NNN has at least one MOD-NNN — ✅ 17/17 (100%)
2. **Backward coverage**: every non-`[EXTERNAL]` MOD-NNN has at least one UTP-NNN-X — ✅ 24/24 (100%)

### IEEE 1012:2016 §5.7 V&V Completeness Check

3. **Every `MOD-NNN` (excluding `[EXTERNAL]`) has at least one `UTP-NNN-X` test case** — ✅ PASS

   | Module | UTP(s) |
   |--------|--------|
   | MOD-001 | UTP-001-A, UTP-001-B |
   | MOD-002 | UTP-002-A, UTP-002-B |
   | MOD-003 | UTP-003-A, UTP-003-B |
   | MOD-004 | UTP-004-A |
   | MOD-005 | UTP-005-A |
   | MOD-006 | UTP-006-A, UTP-006-B |
   | MOD-007 | UTP-007-A, UTP-007-B |
   | MOD-008 | UTP-008-A, UTP-008-B |
   | MOD-009 | UTP-009-A, UTP-009-B |
   | MOD-010 | UTP-010-A |
   | MOD-011 | UTP-011-A |
   | MOD-012 | UTP-012-A, UTP-012-B |
   | MOD-013 | UTP-013-A, UTP-013-B |
   | MOD-014 | UTP-014-A, UTP-014-B |
   | MOD-015 | UTP-015-A |
   | MOD-016 | UTP-016-A, UTP-016-B |
   | MOD-017 | UTP-017-A, UTP-017-B |
   | MOD-018 | UTP-018-A |
   | MOD-019 | UTP-019-A, UTP-019-B |
   | MOD-020 | UTP-020-A, UTP-020-B |
   | MOD-021 | UTP-021-A |
   | MOD-022 | UTP-022-A |
   | MOD-023 | UTP-023-A, UTP-023-B |
   | MOD-024 | UTP-024-A, UTP-024-B |

   No `[EXTERNAL]` modules — all 24 modules are testable and have UTP coverage. No `[V&V GAP]` entries.

4. **Every `UTP-NNN-X` has at least one `UTS-NNN-X#` executable scenario** — ✅ PASS (40/40)

   | UTP | UTS Count | UTS IDs |
   |-----|-----------|---------|
   | UTP-001-A | 3 | UTS-001-A1, UTS-001-A2, UTS-001-A3 |
   | UTP-001-B | 3 | UTS-001-B1, UTS-001-B2, UTS-001-B3 |
   | UTP-002-A | 3 | UTS-002-A1, UTS-002-A2, UTS-002-A3 |
   | UTP-002-B | 1 | UTS-002-B1 |
   | UTP-003-A | 3 | UTS-003-A1, UTS-003-A2, UTS-003-A3 |
   | UTP-003-B | 2 | UTS-003-B1, UTS-003-B2 |
   | UTP-004-A | 3 | UTS-004-A1, UTS-004-A2, UTS-004-A3 |
   | UTP-005-A | 2 | UTS-005-A1, UTS-005-A2 |
   | UTP-006-A | 3 | UTS-006-A1, UTS-006-A2, UTS-006-A3 |
   | UTP-006-B | 3 | UTS-006-B1, UTS-006-B2, UTS-006-B3 |
   | UTP-007-A | 3 | UTS-007-A1, UTS-007-A2, UTS-007-A3 |
   | UTP-007-B | 3 | UTS-007-B1, UTS-007-B2, UTS-007-B3 |
   | UTP-008-A | 2 | UTS-008-A1, UTS-008-A2 |
   | UTP-008-B | 3 | UTS-008-B1, UTS-008-B2, UTS-008-B3 |
   | UTP-009-A | 3 | UTS-009-A1, UTS-009-A2, UTS-009-A3 |
   | UTP-009-B | 2 | UTS-009-B1, UTS-009-B2 |
   | UTP-010-A | 3 | UTS-010-A1, UTS-010-A2, UTS-010-A3 |
   | UTP-011-A | 3 | UTS-011-A1, UTS-011-A2, UTS-011-A3 |
   | UTP-012-A | 3 | UTS-012-A1, UTS-012-A2, UTS-012-A3 |
   | UTP-012-B | 3 | UTS-012-B1, UTS-012-B2, UTS-012-B3 |
   | UTP-013-A | 3 | UTS-013-A1, UTS-013-A2, UTS-013-A3 |
   | UTP-013-B | 2 | UTS-013-B1, UTS-013-B2 |
   | UTP-014-A | 2 | UTS-014-A1, UTS-014-A2 |
   | UTP-014-B | 2 | UTS-014-B1, UTS-014-B2 |
   | UTP-015-A | 3 | UTS-015-A1, UTS-015-A2, UTS-015-A3 |
   | UTP-016-A | 3 | UTS-016-A1, UTS-016-A2, UTS-016-A3 |
   | UTP-016-B | 2 | UTS-016-B1, UTS-016-B2 |
   | UTP-017-A | 3 | UTS-017-A1, UTS-017-A2, UTS-017-A3 |
   | UTP-017-B | 2 | UTS-017-B1, UTS-017-B2 |
   | UTP-018-A | 3 | UTS-018-A1, UTS-018-A2, UTS-018-A3 |
   | UTP-019-A | 3 | UTS-019-A1, UTS-019-A2, UTS-019-A3 |
   | UTP-019-B | 3 | UTS-019-B1, UTS-019-B2, UTS-019-B3 |
   | UTP-020-A | 3 | UTS-020-A1, UTS-020-A2, UTS-020-A3 |
   | UTP-020-B | 3 | UTS-020-B1, UTS-020-B2, UTS-020-B3 |
   | UTP-021-A | 3 | UTS-021-A1, UTS-021-A2, UTS-021-A3 |
   | UTP-022-A | 3 | UTS-022-A1, UTS-022-A2, UTS-022-A3 |
   | UTP-023-A | 3 | UTS-023-A1, UTS-023-A2, UTS-023-A3 |
   | UTP-023-B | 2 | UTS-023-B1, UTS-023-B2 |
   | UTP-024-A | 4 | UTS-024-A1, UTS-024-A2, UTS-024-A3, UTS-024-A4 |
   | UTP-024-B | 4 | UTS-024-B1, UTS-024-B2, UTS-024-B3, UTS-024-B4 |

   All 40 test cases have at least one executable UTS scenario. No runnable gap detected.

5. **No `MOD-NNN` is left without any V&V activity** — ✅ PASS

   All 24 non-`[EXTERNAL]` modules have at least one UTP. No `[V&V GAP: MOD-NNN has no unit-level V&V activity — IEEE 1012:2016 §5.7]` entries required.

6. **Every UTP declares an ISO 29119-4 technique** — ✅ PASS (40/40)

   All 40 test cases declare a valid ISO 29119-4 technique in their `**Technique**:` field:

   | Technique | Count | UTPs |
   |-----------|-------|------|
   | Statement & Branch Coverage | 24 | UTP-001-A, UTP-002-A, UTP-003-A, UTP-004-A, UTP-005-A, UTP-006-A, UTP-007-A, UTP-008-A, UTP-009-A, UTP-010-A, UTP-011-A, UTP-012-A, UTP-013-A, UTP-014-A, UTP-015-A, UTP-016-A, UTP-017-A, UTP-018-A, UTP-019-A, UTP-020-A, UTP-021-A, UTP-022-A, UTP-023-A, UTP-024-A |
   | Equivalence Partitioning | 7 | UTP-003-B, UTP-007-B, UTP-014-B, UTP-016-B, UTP-017-B, UTP-019-B, UTP-024-B |
   | Boundary Value Analysis | 4 | UTP-008-B, UTP-009-B, UTP-012-B, UTP-020-B |
   | Strict Isolation | 3 | UTP-002-B, UTP-013-B, UTP-023-B |
   | State Transition Testing | 2 | UTP-001-B, UTP-006-B |

   No missing technique declaration detected.

### Coverage Gate Result: ✅ PASS

All six coverage gate checks passed. This unit test plan satisfies the IEEE 1012:2016 §5.7 V&V completeness requirements and the ISO/IEC/IEEE 29119-4:2021 technique mandates.

---

## Governing Standards

This unit test plan is governed by the following standards:

| Standard | Full Name | Role in this Plan |
|----------|-----------|-------------------|
| **ISO/IEC/IEEE 29119-4:2021** | Software and Systems Engineering — Software Testing — Part 4: Test Techniques | Primary test technique standard: defines the five mandatory white-box unit test techniques (Statement & Branch Coverage, Boundary Value Analysis, Equivalence Partitioning, State Transition Testing, Strict Isolation), their application criteria per module view, and the Arrange/Act/Assert scenario format used in all UTS scenarios |
| **IEEE 1012:2016** | IEEE Standard for System, Software, and Hardware Verification and Validation | V&V governance: ensures every module has at least one white-box V&V activity (Coverage Gate §5.7); defines unit testing as a verification activity confirming that each module implements its design correctly; prescribes entry/exit criteria for unit test activities |

> **Domain extensions:** If a domain overlay is loaded (Safety-Critical Techniques), additional structural coverage techniques (e.g., MC/DC per ISO 26262-6 §9.4.4 by ASIL, DO-178C §6.4.4.2 coverage objectives by DAL, IEC 62304 §5.5.3 unit testing by safety class) are applied on top of the ISO 29119-4 base techniques. No domain overlay was active for this plan.
