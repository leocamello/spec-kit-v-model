# Unit Test Plan: Architecture Design ↔ Integration Testing

**Feature Branch**: `003-architecture-integration`
**Created**: 2026-04-20
**Status**: Draft
**Source**: `specs/003-architecture-integration/v-model/module-design.md`

## Overview

This document defines the Unit Test Plan for the Architecture Design ↔ Integration Testing feature. Every module design (`MOD-NNN`) in `module-design.md` has one or more Test Cases (`UTP-NNN-X`), and every Test Case has one or more executable Unit Scenarios (`UTS-NNN-X#`) in white-box Arrange/Act/Assert format.

Unit tests verify **internal module logic** — control flow, data transformations, state transitions, and variable boundaries. They do NOT test module boundaries (integration), user journeys (acceptance), or system-level behavior (system tests).

All 44 modules (MOD-001 through MOD-044) are stateless single-invocation functions. No domain overlay is configured — safety-critical techniques (MC/DC, Variable-Level Fault Injection) are omitted. There are zero `[EXTERNAL]` modules, so all 44 require unit test coverage.

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

### Module: MOD-001 (Parse Decomposition View)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `commands/architecture-design.md`

#### Test Case: UTP-001-A (Branch paths through parse_decomposition_view)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `parse_decomposition_view`. Branches: section detection toggle, table row validation, column count < 5 skip, id_match NULL skip, empty id/name skip, empty components RAISE.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-001-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `parse_decomposition_view`
  * **Act**: Call `parse_decomposition_view(system_design_content, sys_pattern)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-001-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (table row validation)
  * **Act**: Call `parse_decomposition_view` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-001-A3** (error-path: EMPTY_INPUT)
  * **Arrange**: Set up input that triggers error condition: Zero SYS identifiers found
  * **Act**: Call `parse_decomposition_view` with error-triggering input
  * **Assert**: Raises `EMPTY_INPUT`; no partial output produced

#### Test Case: UTP-001-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `components.length` (0..200), `cells.length` (3..10).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-001-B1** (min-1: `components.length` = -1)
  * **Arrange**: Configure input so `components.length` evaluates to -1
  * **Act**: Call `parse_decomposition_view` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `components.length` below valid range
* **Unit Scenario: UTS-001-B2** (min: `components.length` = 0)
  * **Arrange**: Configure input so `components.length` evaluates to 0
  * **Act**: Call `parse_decomposition_view` with minimum valid input
  * **Assert**: Accepted — returns valid output with `components.length` = 0
* **Unit Scenario: UTS-001-B3** (mid: `components.length` = 100)
  * **Arrange**: Configure input so `components.length` evaluates to 100
  * **Act**: Call `parse_decomposition_view` with nominal input
  * **Assert**: Accepted — returns valid output with `components.length` = 100
* **Unit Scenario: UTS-001-B4** (max: `components.length` = 200)
  * **Arrange**: Configure input so `components.length` evaluates to 200
  * **Act**: Call `parse_decomposition_view` with maximum valid input
  * **Assert**: Accepted — returns valid output with `components.length` = 200
* **Unit Scenario: UTS-001-B5** (max+1: `components.length` = 201)
  * **Arrange**: Configure input so `components.length` evaluates to 201
  * **Act**: Call `parse_decomposition_view` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `components.length` exceeds valid range

#### Test Case: UTP-001-C (Equivalence partitions for discrete types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition discrete non-scalar variables: `in_decomposition_section` (Boolean: true/false).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-001-C1** (valid partition: `in_decomposition_section` = true)
  * **Arrange**: Set `in_decomposition_section` to `true`
  * **Act**: Call `parse_decomposition_view` with `in_decomposition_section` = true
  * **Assert**: True-path logic executes; output reflects `in_decomposition_section` = true behavior
* **Unit Scenario: UTS-001-C2** (valid partition: `in_decomposition_section` = false)
  * **Arrange**: Set `in_decomposition_section` to `false`
  * **Act**: Call `parse_decomposition_view` with `in_decomposition_section` = false
  * **Assert**: False-path logic executes; output reflects `in_decomposition_section` = false behavior

---

### Module: MOD-002 (Parse Dependency View)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `commands/architecture-design.md`

#### Test Case: UTP-002-A (Branch paths through parse_dependency_view)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `parse_dependency_view`. Branches: section detection toggle, table row validation, column count < 4 skip, empty source/target IDs skip, nested FOR loop over source×target pairs.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-002-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `parse_dependency_view`
  * **Act**: Call `parse_dependency_view(system_design_content, sys_pattern)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-002-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (table row validation)
  * **Act**: Call `parse_dependency_view` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-002-A3** (loop-zero: empty input collection)
  * **Arrange**: Provide empty collection as input to `parse_dependency_view`
  * **Act**: Call `parse_dependency_view` with empty input
  * **Assert**: Returns empty result; loop body never executed

#### Test Case: UTP-002-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `dependencies.length` (0..500), `source_ids.length` (1..10), `target_ids.length` (1..10).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-002-B1** (min-1: `dependencies.length` = -1)
  * **Arrange**: Configure input so `dependencies.length` evaluates to -1
  * **Act**: Call `parse_dependency_view` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `dependencies.length` below valid range
* **Unit Scenario: UTS-002-B2** (min: `dependencies.length` = 0)
  * **Arrange**: Configure input so `dependencies.length` evaluates to 0
  * **Act**: Call `parse_dependency_view` with minimum valid input
  * **Assert**: Accepted — returns valid output with `dependencies.length` = 0
* **Unit Scenario: UTS-002-B3** (mid: `dependencies.length` = 250)
  * **Arrange**: Configure input so `dependencies.length` evaluates to 250
  * **Act**: Call `parse_dependency_view` with nominal input
  * **Assert**: Accepted — returns valid output with `dependencies.length` = 250
* **Unit Scenario: UTS-002-B4** (max: `dependencies.length` = 500)
  * **Arrange**: Configure input so `dependencies.length` evaluates to 500
  * **Act**: Call `parse_dependency_view` with maximum valid input
  * **Assert**: Accepted — returns valid output with `dependencies.length` = 500
* **Unit Scenario: UTS-002-B5** (max+1: `dependencies.length` = 501)
  * **Arrange**: Configure input so `dependencies.length` evaluates to 501
  * **Act**: Call `parse_dependency_view` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `dependencies.length` exceeds valid range

#### Test Case: UTP-002-C (Equivalence partitions for discrete types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition discrete non-scalar variables: `in_dependency_section` (Boolean: true/false).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-002-C1** (valid partition: `in_dependency_section` = true)
  * **Arrange**: Set `in_dependency_section` to `true`
  * **Act**: Call `parse_dependency_view` with `in_dependency_section` = true
  * **Assert**: True-path logic executes; output reflects `in_dependency_section` = true behavior
* **Unit Scenario: UTS-002-C2** (valid partition: `in_dependency_section` = false)
  * **Arrange**: Set `in_dependency_section` to `false`
  * **Act**: Call `parse_dependency_view` with `in_dependency_section` = false
  * **Assert**: False-path logic executes; output reflects `in_dependency_section` = false behavior

---

### Module: MOD-003 (Parse Interface View)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `commands/architecture-design.md`

#### Test Case: UTP-003-A (Branch paths through parse_interface_view)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `parse_interface_view`. Branches: section detection toggle, subsection heading with SYS ID extraction, table row < 6 columns skip, current_component NULL guard.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-003-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `parse_interface_view`
  * **Act**: Call `parse_interface_view(system_design_content, sys_pattern)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-003-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (subsection heading with SYS ID extraction)
  * **Act**: Call `parse_interface_view` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries

#### Test Case: UTP-003-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `interfaces.length` (0..200), `cells.length` (0..10).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-003-B1** (min-1: `interfaces.length` = -1)
  * **Arrange**: Configure input so `interfaces.length` evaluates to -1
  * **Act**: Call `parse_interface_view` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `interfaces.length` below valid range
* **Unit Scenario: UTS-003-B2** (min: `interfaces.length` = 0)
  * **Arrange**: Configure input so `interfaces.length` evaluates to 0
  * **Act**: Call `parse_interface_view` with minimum valid input
  * **Assert**: Accepted — returns valid output with `interfaces.length` = 0
* **Unit Scenario: UTS-003-B3** (mid: `interfaces.length` = 100)
  * **Arrange**: Configure input so `interfaces.length` evaluates to 100
  * **Act**: Call `parse_interface_view` with nominal input
  * **Assert**: Accepted — returns valid output with `interfaces.length` = 100
* **Unit Scenario: UTS-003-B4** (max: `interfaces.length` = 200)
  * **Arrange**: Configure input so `interfaces.length` evaluates to 200
  * **Act**: Call `parse_interface_view` with maximum valid input
  * **Assert**: Accepted — returns valid output with `interfaces.length` = 200
* **Unit Scenario: UTS-003-B5** (max+1: `interfaces.length` = 201)
  * **Arrange**: Configure input so `interfaces.length` evaluates to 201
  * **Act**: Call `parse_interface_view` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `interfaces.length` exceeds valid range

#### Test Case: UTP-003-C (Equivalence partitions for discrete types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition discrete non-scalar variables: `in_interface_section` (Boolean: true/false).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-003-C1** (valid partition: `in_interface_section` = true)
  * **Arrange**: Set `in_interface_section` to `true`
  * **Act**: Call `parse_interface_view` with `in_interface_section` = true
  * **Assert**: True-path logic executes; output reflects `in_interface_section` = true behavior
* **Unit Scenario: UTS-003-C2** (valid partition: `in_interface_section` = false)
  * **Arrange**: Set `in_interface_section` to `false`
  * **Act**: Call `parse_interface_view` with `in_interface_section` = false
  * **Assert**: False-path logic executes; output reflects `in_interface_section` = false behavior

---

### Module: MOD-004 (Decompose SYS to ARCH)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `commands/architecture-design.md`

#### Test Case: UTP-004-A (Branch paths through decompose_sys_to_arch)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `decompose_sys_to_arch`. Branches: empty sys_components RAISE, spans_multiple_sys append, shared concern traceable merge vs append, existing module found vs not.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-004-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `decompose_sys_to_arch`
  * **Act**: Call `decompose_sys_to_arch(sys_components, dependencies, interfaces)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-004-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (spans_multiple_sys append)
  * **Act**: Call `decompose_sys_to_arch` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-004-A3** (error-path: TRANSLATOR_VIOLATION)
  * **Arrange**: Set up input that triggers error condition: Empty SYS component list
  * **Act**: Call `decompose_sys_to_arch` with error-triggering input
  * **Assert**: Raises `TRANSLATOR_VIOLATION`; no partial output produced

#### Test Case: UTP-004-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `arch_modules.length` (0..100), `cross_cutting_candidates.length` (0..20), `responsibility_groups.length` (1..10).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-004-B1** (min-1: `arch_modules.length` = -1)
  * **Arrange**: Configure input so `arch_modules.length` evaluates to -1
  * **Act**: Call `decompose_sys_to_arch` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `arch_modules.length` below valid range
* **Unit Scenario: UTS-004-B2** (min: `arch_modules.length` = 0)
  * **Arrange**: Configure input so `arch_modules.length` evaluates to 0
  * **Act**: Call `decompose_sys_to_arch` with minimum valid input
  * **Assert**: Accepted — returns valid output with `arch_modules.length` = 0
* **Unit Scenario: UTS-004-B3** (mid: `arch_modules.length` = 50)
  * **Arrange**: Configure input so `arch_modules.length` evaluates to 50
  * **Act**: Call `decompose_sys_to_arch` with nominal input
  * **Assert**: Accepted — returns valid output with `arch_modules.length` = 50
* **Unit Scenario: UTS-004-B4** (max: `arch_modules.length` = 100)
  * **Arrange**: Configure input so `arch_modules.length` evaluates to 100
  * **Act**: Call `decompose_sys_to_arch` with maximum valid input
  * **Assert**: Accepted — returns valid output with `arch_modules.length` = 100
* **Unit Scenario: UTS-004-B5** (max+1: `arch_modules.length` = 101)
  * **Arrange**: Configure input so `arch_modules.length` evaluates to 101
  * **Act**: Call `decompose_sys_to_arch` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `arch_modules.length` exceeds valid range

---

### Module: MOD-005 (Assign ARCH Identifiers)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `commands/architecture-design.md`

#### Test Case: UTP-005-A (Branch paths through assign_arch_identifiers)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `assign_arch_identifiers`. Branches: iterate arch_modules assign ID, iterate cross_cutting: is_derived branch vs normal assignment, ID overflow check.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-005-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `assign_arch_identifiers`
  * **Act**: Call `assign_arch_identifiers(arch_modules, cross_cutting_modules, existing_highest_id)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-005-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (iterate cross_cutting: is_derived branch vs normal assignment)
  * **Act**: Call `assign_arch_identifiers` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-005-A3** (error-path: TRANSLATOR_VIOLATION)
  * **Arrange**: Set up input that triggers error condition: next_id exceeds 999
  * **Act**: Call `assign_arch_identifiers` with error-triggering input
  * **Assert**: Raises `TRANSLATOR_VIOLATION`; no partial output produced
* **Unit Scenario: UTS-005-A4** (loop-zero: empty input collection)
  * **Arrange**: Provide empty collection as input to `assign_arch_identifiers`
  * **Act**: Call `assign_arch_identifiers` with empty input
  * **Assert**: Returns empty result or raises appropriate error; loop body never executed

#### Test Case: UTP-005-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `next_id` (1..999), `all_modules.length` (0..120).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-005-B1** (min-1: `next_id` = 0)
  * **Arrange**: Configure input so `next_id` evaluates to 0
  * **Act**: Call `assign_arch_identifiers` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `next_id` below valid range
* **Unit Scenario: UTS-005-B2** (min: `next_id` = 1)
  * **Arrange**: Configure input so `next_id` evaluates to 1
  * **Act**: Call `assign_arch_identifiers` with minimum valid input
  * **Assert**: Accepted — returns valid output with `next_id` = 1
* **Unit Scenario: UTS-005-B3** (mid: `next_id` = 500)
  * **Arrange**: Configure input so `next_id` evaluates to 500
  * **Act**: Call `assign_arch_identifiers` with nominal input
  * **Assert**: Accepted — returns valid output with `next_id` = 500
* **Unit Scenario: UTS-005-B4** (max: `next_id` = 999)
  * **Arrange**: Configure input so `next_id` evaluates to 999
  * **Act**: Call `assign_arch_identifiers` with maximum valid input
  * **Assert**: Accepted — returns valid output with `next_id` = 999
* **Unit Scenario: UTS-005-B5** (max+1: `next_id` = 1000)
  * **Arrange**: Configure input so `next_id` evaluates to 1000
  * **Act**: Call `assign_arch_identifiers` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `next_id` exceeds valid range

---

### Module: MOD-006 (Classify and Tag Modules)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `commands/architecture-design.md`

#### Test Case: UTP-006-A (Branch paths through classify_and_tag_modules)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `classify_and_tag_modules`. Branches: CROSS-CUTTING tag skip, empty parent_sys DERIVED tag, type NULL/empty derive, derive_type: script/CLI→Utility, template/library→Library, endpoint/handler→Service, default→Component.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-006-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `classify_and_tag_modules`
  * **Act**: Call `classify_and_tag_modules(modules, sys_components)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-006-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (empty parent_sys DERIVED tag)
  * **Act**: Call `classify_and_tag_modules` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-006-A3** (error-path: DERIVED_MODULE_HALT)
  * **Arrange**: Set up input that triggers error condition: Empty parent_sys no cross-cutting
  * **Act**: Call `classify_and_tag_modules` with error-triggering input
  * **Assert**: Raises `DERIVED_MODULE_HALT`; no partial output produced

#### Test Case: UTP-006-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `sys_type_map.size` (0..50), `parent_types.length` (0..10).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-006-B1** (min-1: `sys_type_map.size` = -1)
  * **Arrange**: Configure input so `sys_type_map.size` evaluates to -1
  * **Act**: Call `classify_and_tag_modules` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `sys_type_map.size` below valid range
* **Unit Scenario: UTS-006-B2** (min: `sys_type_map.size` = 0)
  * **Arrange**: Configure input so `sys_type_map.size` evaluates to 0
  * **Act**: Call `classify_and_tag_modules` with minimum valid input
  * **Assert**: Accepted — returns valid output with `sys_type_map.size` = 0
* **Unit Scenario: UTS-006-B3** (mid: `sys_type_map.size` = 25)
  * **Arrange**: Configure input so `sys_type_map.size` evaluates to 25
  * **Act**: Call `classify_and_tag_modules` with nominal input
  * **Assert**: Accepted — returns valid output with `sys_type_map.size` = 25
* **Unit Scenario: UTS-006-B4** (max: `sys_type_map.size` = 50)
  * **Arrange**: Configure input so `sys_type_map.size` evaluates to 50
  * **Act**: Call `classify_and_tag_modules` with maximum valid input
  * **Assert**: Accepted — returns valid output with `sys_type_map.size` = 50
* **Unit Scenario: UTS-006-B5** (max+1: `sys_type_map.size` = 51)
  * **Arrange**: Configure input so `sys_type_map.size` evaluates to 51
  * **Act**: Call `classify_and_tag_modules` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `sys_type_map.size` exceeds valid range

#### Test Case: UTP-006-C (Equivalence partitions for discrete types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition discrete non-scalar variables: `module.type` (Enum: Utility, Library, Service, Component).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-006-C1** (valid partition: `module.type` = "Utility")
  * **Arrange**: Set `module.type` to `"Utility"`
  * **Act**: Call `classify_and_tag_modules` with `module.type` = "Utility"
  * **Assert**: Returns output specific to `module.type` = "Utility" partition
* **Unit Scenario: UTS-006-C2** (valid partition: `module.type` = "Library")
  * **Arrange**: Set `module.type` to `"Library"`
  * **Act**: Call `classify_and_tag_modules` with `module.type` = "Library"
  * **Assert**: Returns output specific to `module.type` = "Library" partition
* **Unit Scenario: UTS-006-C3** (valid partition: `module.type` = "Service")
  * **Arrange**: Set `module.type` to `"Service"`
  * **Act**: Call `classify_and_tag_modules` with `module.type` = "Service"
  * **Assert**: Returns output specific to `module.type` = "Service" partition
* **Unit Scenario: UTS-006-C4** (valid partition: `module.type` = "Component")
  * **Arrange**: Set `module.type` to `"Component"`
  * **Act**: Call `classify_and_tag_modules` with `module.type` = "Component"
  * **Assert**: Returns output specific to `module.type` = "Component" partition
* **Unit Scenario: UTS-006-C5** (invalid partition: `module.type` = null/unknown)
  * **Arrange**: Set `module.type` to `null` or an undefined value
  * **Act**: Call `classify_and_tag_modules` with invalid `module.type`
  * **Assert**: Raises validation error or returns default; invalid partition rejected

---

### Module: MOD-007 (Generate Logical View Table)

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `commands/architecture-design.md`

#### Test Case: UTP-007-A (Branch paths through generate_logical_view_table)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `generate_logical_view_table`. Branches: CROSS-CUTTING tag → rationale cell vs join parent_sys, sys_coverage tracking, uncovered > 0 RAISE INCOMPLETE_COVERAGE.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-007-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `generate_logical_view_table`
  * **Act**: Call `generate_logical_view_table(arch_modules, template_structure)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-007-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (sys_coverage tracking)
  * **Act**: Call `generate_logical_view_table` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-007-A3** (error-path: INCOMPLETE_COVERAGE)
  * **Arrange**: Set up input that triggers error condition: SYS-NNN has no ARCH parent
  * **Act**: Call `generate_logical_view_table` with error-triggering input
  * **Assert**: Raises `INCOMPLETE_COVERAGE`; no partial output produced

#### Test Case: UTP-007-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `rows.length` (1..100), `uncovered.length` (0..50).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-007-B1** (min-1: `rows.length` = 0)
  * **Arrange**: Configure input so `rows.length` evaluates to 0
  * **Act**: Call `generate_logical_view_table` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `rows.length` below valid range
* **Unit Scenario: UTS-007-B2** (min: `rows.length` = 1)
  * **Arrange**: Configure input so `rows.length` evaluates to 1
  * **Act**: Call `generate_logical_view_table` with minimum valid input
  * **Assert**: Accepted — returns valid output with `rows.length` = 1
* **Unit Scenario: UTS-007-B3** (mid: `rows.length` = 50)
  * **Arrange**: Configure input so `rows.length` evaluates to 50
  * **Act**: Call `generate_logical_view_table` with nominal input
  * **Assert**: Accepted — returns valid output with `rows.length` = 50
* **Unit Scenario: UTS-007-B4** (max: `rows.length` = 100)
  * **Arrange**: Configure input so `rows.length` evaluates to 100
  * **Act**: Call `generate_logical_view_table` with maximum valid input
  * **Assert**: Accepted — returns valid output with `rows.length` = 100
* **Unit Scenario: UTS-007-B5** (max+1: `rows.length` = 101)
  * **Arrange**: Configure input so `rows.length` evaluates to 101
  * **Act**: Call `generate_logical_view_table` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `rows.length` exceeds valid range

---

### Module: MOD-008 (Generate Sequence Diagrams)

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `commands/architecture-design.md`

#### Test Case: UTP-008-A (Branch paths through generate_sequence_diagrams)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `generate_sequence_diagrams`. Branches: arch lookup NULL check, is_async → dashed arrow vs solid, has_response → response line, mermaid validation failure RAISE.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-008-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `generate_sequence_diagrams`
  * **Act**: Call `generate_sequence_diagrams(arch_modules, dependencies, template_structure)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-008-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (is_async → dashed arrow vs solid)
  * **Act**: Call `generate_sequence_diagrams` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-008-A3** (error-path: INVALID_MERMAID)
  * **Arrange**: Set up input that triggers error condition: Mermaid validation fails
  * **Act**: Call `generate_sequence_diagrams` with error-triggering input
  * **Assert**: Raises `INVALID_MERMAID`; no partial output produced

#### Test Case: UTP-008-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `interaction_paths.length` (1..20), `diagrams.length` (1..20), `participants.length` (2..20).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-008-B1** (min-1: `interaction_paths.length` = 0)
  * **Arrange**: Configure input so `interaction_paths.length` evaluates to 0
  * **Act**: Call `generate_sequence_diagrams` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `interaction_paths.length` below valid range
* **Unit Scenario: UTS-008-B2** (min: `interaction_paths.length` = 1)
  * **Arrange**: Configure input so `interaction_paths.length` evaluates to 1
  * **Act**: Call `generate_sequence_diagrams` with minimum valid input
  * **Assert**: Accepted — returns valid output with `interaction_paths.length` = 1
* **Unit Scenario: UTS-008-B3** (mid: `interaction_paths.length` = 10)
  * **Arrange**: Configure input so `interaction_paths.length` evaluates to 10
  * **Act**: Call `generate_sequence_diagrams` with nominal input
  * **Assert**: Accepted — returns valid output with `interaction_paths.length` = 10
* **Unit Scenario: UTS-008-B4** (max: `interaction_paths.length` = 20)
  * **Arrange**: Configure input so `interaction_paths.length` evaluates to 20
  * **Act**: Call `generate_sequence_diagrams` with maximum valid input
  * **Assert**: Accepted — returns valid output with `interaction_paths.length` = 20
* **Unit Scenario: UTS-008-B5** (max+1: `interaction_paths.length` = 21)
  * **Arrange**: Configure input so `interaction_paths.length` evaluates to 21
  * **Act**: Call `generate_sequence_diagrams` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `interaction_paths.length` exceeds valid range

---

### Module: MOD-009 (Document Concurrency Model)

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `commands/architecture-design.md`

#### Test Case: UTP-009-A (Branch paths through document_concurrency_model)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `document_concurrency_model`. Branches: has_parallel → parallel model, ELSE has_async → async model, ELSE sequential default, empty interaction path → default.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-009-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `document_concurrency_model`
  * **Act**: Call `document_concurrency_model(interaction_path, arch_modules)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-009-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (ELSE has_async → async model)
  * **Act**: Call `document_concurrency_model` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries

#### Test Case: UTP-009-B (Equivalence partitions for discrete types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition discrete non-scalar variables: `has_parallel` (Boolean: true/false); `has_async` (Boolean: true/false); `execution_model` (Enum: Sequential single-process execution, Parallel execution with synchronization barriers, Asynchronous message-passing with callbacks).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-009-B1** (valid partition: `has_parallel` = true)
  * **Arrange**: Set `has_parallel` to `true`
  * **Act**: Call `document_concurrency_model` with `has_parallel` = true
  * **Assert**: True-path logic executes; output reflects `has_parallel` = true behavior
* **Unit Scenario: UTS-009-B2** (valid partition: `has_parallel` = false)
  * **Arrange**: Set `has_parallel` to `false`
  * **Act**: Call `document_concurrency_model` with `has_parallel` = false
  * **Assert**: False-path logic executes; output reflects `has_parallel` = false behavior
* **Unit Scenario: UTS-009-B3** (valid partition: `has_async` = true)
  * **Arrange**: Set `has_async` to `true`
  * **Act**: Call `document_concurrency_model` with `has_async` = true
  * **Assert**: True-path logic executes; output reflects `has_async` = true behavior
* **Unit Scenario: UTS-009-B4** (valid partition: `has_async` = false)
  * **Arrange**: Set `has_async` to `false`
  * **Act**: Call `document_concurrency_model` with `has_async` = false
  * **Assert**: False-path logic executes; output reflects `has_async` = false behavior
* **Unit Scenario: UTS-009-B5** (valid partition: `execution_model` = "Sequential single-process execution")
  * **Arrange**: Set `execution_model` to `"Sequential single-process execution"`
  * **Act**: Call `document_concurrency_model` with `execution_model` = "Sequential single-process execution"
  * **Assert**: Returns output specific to `execution_model` = "Sequential single-process execution" partition
* **Unit Scenario: UTS-009-B6** (valid partition: `execution_model` = "Parallel execution with synchronization barriers")
  * **Arrange**: Set `execution_model` to `"Parallel execution with synchronization barriers"`
  * **Act**: Call `document_concurrency_model` with `execution_model` = "Parallel execution with synchronization barriers"
  * **Assert**: Returns output specific to `execution_model` = "Parallel execution with synchronization barriers" partition
* **Unit Scenario: UTS-009-B7** (valid partition: `execution_model` = "Asynchronous message-passing with callbacks")
  * **Arrange**: Set `execution_model` to `"Asynchronous message-passing with callbacks"`
  * **Act**: Call `document_concurrency_model` with `execution_model` = "Asynchronous message-passing with callbacks"
  * **Assert**: Returns output specific to `execution_model` = "Asynchronous message-passing with callbacks" partition
* **Unit Scenario: UTS-009-B8** (invalid partition: `execution_model` = null/unknown)
  * **Arrange**: Set `execution_model` to `null` or an undefined value
  * **Act**: Call `document_concurrency_model` with invalid `execution_model`
  * **Assert**: Raises validation error or returns default; invalid partition rejected

---

### Module: MOD-010 (Generate Contract Tables)

**Parent Architecture Modules**: ARCH-005
**Target Source File(s)**: `commands/architecture-design.md`

#### Test Case: UTP-010-A (Branch paths through generate_contract_tables)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `generate_contract_tables`. Branches: filter interfaces per module, derive inputs/outputs from description, empty inputs AND outputs → BLACK_BOX_WARNING.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-010-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `generate_contract_tables`
  * **Act**: Call `generate_contract_tables(arch_modules, sys_interfaces, template_structure)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-010-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (derive inputs/outputs from description)
  * **Act**: Call `generate_contract_tables` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-010-A3** (error-path: BLACK_BOX_WARNING)
  * **Arrange**: Set up input that triggers error condition: No derivable inputs/outputs
  * **Act**: Call `generate_contract_tables` with error-triggering input
  * **Assert**: Raises `BLACK_BOX_WARNING`; no partial output produced

#### Test Case: UTP-010-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `tables.length` (1..100), `inputs.length` (0..20), `outputs.length` (0..20), `exceptions.length` (0..10).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-010-B1** (min-1: `tables.length` = 0)
  * **Arrange**: Configure input so `tables.length` evaluates to 0
  * **Act**: Call `generate_contract_tables` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `tables.length` below valid range
* **Unit Scenario: UTS-010-B2** (min: `tables.length` = 1)
  * **Arrange**: Configure input so `tables.length` evaluates to 1
  * **Act**: Call `generate_contract_tables` with minimum valid input
  * **Assert**: Accepted — returns valid output with `tables.length` = 1
* **Unit Scenario: UTS-010-B3** (mid: `tables.length` = 50)
  * **Arrange**: Configure input so `tables.length` evaluates to 50
  * **Act**: Call `generate_contract_tables` with nominal input
  * **Assert**: Accepted — returns valid output with `tables.length` = 50
* **Unit Scenario: UTS-010-B4** (max: `tables.length` = 100)
  * **Arrange**: Configure input so `tables.length` evaluates to 100
  * **Act**: Call `generate_contract_tables` with maximum valid input
  * **Assert**: Accepted — returns valid output with `tables.length` = 100
* **Unit Scenario: UTS-010-B5** (max+1: `tables.length` = 101)
  * **Arrange**: Configure input so `tables.length` evaluates to 101
  * **Act**: Call `generate_contract_tables` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `tables.length` exceeds valid range

---

### Module: MOD-011 (Generate Data Flow Tables)

**Parent Architecture Modules**: ARCH-006
**Target Source File(s)**: `commands/architecture-design.md`

#### Test Case: UTP-011-A (Branch paths through generate_data_flow_tables)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `generate_data_flow_tables`. Branches: module_ref NULL → DISCONNECTED_MODULE skip, stage_num increment per step.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-011-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `generate_data_flow_tables`
  * **Act**: Call `generate_data_flow_tables(arch_modules, dependencies, template_structure)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-011-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (stage_num increment per step)
  * **Act**: Call `generate_data_flow_tables` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-011-A3** (error-path: DISCONNECTED_MODULE)
  * **Arrange**: Set up input that triggers error condition: Module with no data flow connections
  * **Act**: Call `generate_data_flow_tables` with error-triggering input
  * **Assert**: Raises `DISCONNECTED_MODULE`; no partial output produced

#### Test Case: UTP-011-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `flow_chains.length` (1..20), `stage_num` (1..50).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-011-B1** (min-1: `flow_chains.length` = 0)
  * **Arrange**: Configure input so `flow_chains.length` evaluates to 0
  * **Act**: Call `generate_data_flow_tables` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `flow_chains.length` below valid range
* **Unit Scenario: UTS-011-B2** (min: `flow_chains.length` = 1)
  * **Arrange**: Configure input so `flow_chains.length` evaluates to 1
  * **Act**: Call `generate_data_flow_tables` with minimum valid input
  * **Assert**: Accepted — returns valid output with `flow_chains.length` = 1
* **Unit Scenario: UTS-011-B3** (mid: `flow_chains.length` = 10)
  * **Arrange**: Configure input so `flow_chains.length` evaluates to 10
  * **Act**: Call `generate_data_flow_tables` with nominal input
  * **Assert**: Accepted — returns valid output with `flow_chains.length` = 10
* **Unit Scenario: UTS-011-B4** (max: `flow_chains.length` = 20)
  * **Arrange**: Configure input so `flow_chains.length` evaluates to 20
  * **Act**: Call `generate_data_flow_tables` with maximum valid input
  * **Assert**: Accepted — returns valid output with `flow_chains.length` = 20
* **Unit Scenario: UTS-011-B5** (max+1: `flow_chains.length` = 21)
  * **Arrange**: Configure input so `flow_chains.length` evaluates to 21
  * **Act**: Call `generate_data_flow_tables` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `flow_chains.length` exceeds valid range

---

### Module: MOD-012 (Parse Logical View)

**Parent Architecture Modules**: ARCH-007
**Target Source File(s)**: `commands/integration-test.md`

#### Test Case: UTP-012-A (Branch paths through parse_logical_view)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `parse_logical_view`. Branches: section detection toggle, table row < 5 columns skip, id_match NULL skip, CROSS-CUTTING parent_sys handling, empty modules RAISE.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-012-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `parse_logical_view`
  * **Act**: Call `parse_logical_view(arch_design_content, arch_pattern)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-012-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (table row < 5 columns skip)
  * **Act**: Call `parse_logical_view` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-012-A3** (error-path: MISSING_VIEW)
  * **Arrange**: Set up input that triggers error condition: Logical View absent or empty
  * **Act**: Call `parse_logical_view` with error-triggering input
  * **Assert**: Raises `MISSING_VIEW`; no partial output produced

#### Test Case: UTP-012-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `modules.length` (0..100).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-012-B1** (min-1: `modules.length` = -1)
  * **Arrange**: Configure input so `modules.length` evaluates to -1
  * **Act**: Call `parse_logical_view` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `modules.length` below valid range
* **Unit Scenario: UTS-012-B2** (min: `modules.length` = 0)
  * **Arrange**: Configure input so `modules.length` evaluates to 0
  * **Act**: Call `parse_logical_view` with minimum valid input
  * **Assert**: Accepted — returns valid output with `modules.length` = 0
* **Unit Scenario: UTS-012-B3** (mid: `modules.length` = 50)
  * **Arrange**: Configure input so `modules.length` evaluates to 50
  * **Act**: Call `parse_logical_view` with nominal input
  * **Assert**: Accepted — returns valid output with `modules.length` = 50
* **Unit Scenario: UTS-012-B4** (max: `modules.length` = 100)
  * **Arrange**: Configure input so `modules.length` evaluates to 100
  * **Act**: Call `parse_logical_view` with maximum valid input
  * **Assert**: Accepted — returns valid output with `modules.length` = 100
* **Unit Scenario: UTS-012-B5** (max+1: `modules.length` = 101)
  * **Arrange**: Configure input so `modules.length` evaluates to 101
  * **Act**: Call `parse_logical_view` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `modules.length` exceeds valid range

#### Test Case: UTP-012-C (Equivalence partitions for discrete types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition discrete non-scalar variables: `in_logical_section` (Boolean: true/false); `is_cross_cutting` (Boolean: true/false).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-012-C1** (valid partition: `in_logical_section` = true)
  * **Arrange**: Set `in_logical_section` to `true`
  * **Act**: Call `parse_logical_view` with `in_logical_section` = true
  * **Assert**: True-path logic executes; output reflects `in_logical_section` = true behavior
* **Unit Scenario: UTS-012-C2** (valid partition: `in_logical_section` = false)
  * **Arrange**: Set `in_logical_section` to `false`
  * **Act**: Call `parse_logical_view` with `in_logical_section` = false
  * **Assert**: False-path logic executes; output reflects `in_logical_section` = false behavior
* **Unit Scenario: UTS-012-C3** (valid partition: `is_cross_cutting` = true)
  * **Arrange**: Set `is_cross_cutting` to `true`
  * **Act**: Call `parse_logical_view` with `is_cross_cutting` = true
  * **Assert**: True-path logic executes; output reflects `is_cross_cutting` = true behavior
* **Unit Scenario: UTS-012-C4** (valid partition: `is_cross_cutting` = false)
  * **Arrange**: Set `is_cross_cutting` to `false`
  * **Act**: Call `parse_logical_view` with `is_cross_cutting` = false
  * **Assert**: False-path logic executes; output reflects `is_cross_cutting` = false behavior

---

### Module: MOD-013 (Parse Architecture Views)

**Parent Architecture Modules**: ARCH-007
**Target Source File(s)**: `commands/integration-test.md`

#### Test Case: UTP-013-A (Branch paths through parse_architecture_views)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `parse_architecture_views`. Branches: three sub-parsers (process/interface/data_flow), missing_views accumulation, any NULL view → RAISE, mermaid block open/close, contracts per ARCH, chain stages.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-013-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `parse_architecture_views`
  * **Act**: Call `parse_architecture_views(arch_design_content)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-013-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (missing_views accumulation)
  * **Act**: Call `parse_architecture_views` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-013-A3** (error-path: MISSING_VIEW)
  * **Arrange**: Set up input that triggers error condition: One or more mandatory views missing
  * **Act**: Call `parse_architecture_views` with error-triggering input
  * **Assert**: Raises `MISSING_VIEW`; no partial output produced

#### Test Case: UTP-013-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `mermaid_blocks.length` (0..20), `chains.length` (0..10).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-013-B1** (min-1: `mermaid_blocks.length` = -1)
  * **Arrange**: Configure input so `mermaid_blocks.length` evaluates to -1
  * **Act**: Call `parse_architecture_views` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `mermaid_blocks.length` below valid range
* **Unit Scenario: UTS-013-B2** (min: `mermaid_blocks.length` = 0)
  * **Arrange**: Configure input so `mermaid_blocks.length` evaluates to 0
  * **Act**: Call `parse_architecture_views` with minimum valid input
  * **Assert**: Accepted — returns valid output with `mermaid_blocks.length` = 0
* **Unit Scenario: UTS-013-B3** (mid: `mermaid_blocks.length` = 10)
  * **Arrange**: Configure input so `mermaid_blocks.length` evaluates to 10
  * **Act**: Call `parse_architecture_views` with nominal input
  * **Assert**: Accepted — returns valid output with `mermaid_blocks.length` = 10
* **Unit Scenario: UTS-013-B4** (max: `mermaid_blocks.length` = 20)
  * **Arrange**: Configure input so `mermaid_blocks.length` evaluates to 20
  * **Act**: Call `parse_architecture_views` with maximum valid input
  * **Assert**: Accepted — returns valid output with `mermaid_blocks.length` = 20
* **Unit Scenario: UTS-013-B5** (max+1: `mermaid_blocks.length` = 21)
  * **Arrange**: Configure input so `mermaid_blocks.length` evaluates to 21
  * **Act**: Call `parse_architecture_views` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `mermaid_blocks.length` exceeds valid range

#### Test Case: UTP-013-C (Equivalence partitions for discrete types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition discrete non-scalar variables: `in_process` (Boolean: true/false); `in_interface` (Boolean: true/false); `in_data_flow` (Boolean: true/false).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-013-C1** (valid partition: `in_process` = true)
  * **Arrange**: Set `in_process` to `true`
  * **Act**: Call `parse_architecture_views` with `in_process` = true
  * **Assert**: True-path logic executes; output reflects `in_process` = true behavior
* **Unit Scenario: UTS-013-C2** (valid partition: `in_process` = false)
  * **Arrange**: Set `in_process` to `false`
  * **Act**: Call `parse_architecture_views` with `in_process` = false
  * **Assert**: False-path logic executes; output reflects `in_process` = false behavior
* **Unit Scenario: UTS-013-C3** (valid partition: `in_interface` = true)
  * **Arrange**: Set `in_interface` to `true`
  * **Act**: Call `parse_architecture_views` with `in_interface` = true
  * **Assert**: True-path logic executes; output reflects `in_interface` = true behavior
* **Unit Scenario: UTS-013-C4** (valid partition: `in_interface` = false)
  * **Arrange**: Set `in_interface` to `false`
  * **Act**: Call `parse_architecture_views` with `in_interface` = false
  * **Assert**: False-path logic executes; output reflects `in_interface` = false behavior
* **Unit Scenario: UTS-013-C5** (valid partition: `in_data_flow` = true)
  * **Arrange**: Set `in_data_flow` to `true`
  * **Act**: Call `parse_architecture_views` with `in_data_flow` = true
  * **Assert**: True-path logic executes; output reflects `in_data_flow` = true behavior
* **Unit Scenario: UTS-013-C6** (valid partition: `in_data_flow` = false)
  * **Arrange**: Set `in_data_flow` to `false`
  * **Act**: Call `parse_architecture_views` with `in_data_flow` = false
  * **Assert**: False-path logic executes; output reflects `in_data_flow` = false behavior

---

### Module: MOD-014 (Generate ITP Cases)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `commands/integration-test.md`

#### Test Case: UTP-014-A (Branch paths through generate_itp_cases)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `generate_itp_cases`. Branches: interface_contracts present → ITP, data_flows present → ITP, error_contracts present → ITP, process_interactions present → ITP, letter_index == 0 → NO_TECHNIQUE_MATCH.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-014-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `generate_itp_cases`
  * **Act**: Call `generate_itp_cases(arch_modules, view_data, template_structure)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-014-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (data_flows present → ITP)
  * **Act**: Call `generate_itp_cases` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-014-A3** (error-path: NO_TECHNIQUE_MATCH)
  * **Arrange**: Set up input that triggers error condition: Module with no matching technique
  * **Act**: Call `generate_itp_cases` with error-triggering input
  * **Assert**: Raises `NO_TECHNIQUE_MATCH`; no partial output produced

#### Test Case: UTP-014-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `test_cases.length` (1..200), `arch_num` (1..999), `letter_index` (0..25).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-014-B1** (min-1: `test_cases.length` = 0)
  * **Arrange**: Configure input so `test_cases.length` evaluates to 0
  * **Act**: Call `generate_itp_cases` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `test_cases.length` below valid range
* **Unit Scenario: UTS-014-B2** (min: `test_cases.length` = 1)
  * **Arrange**: Configure input so `test_cases.length` evaluates to 1
  * **Act**: Call `generate_itp_cases` with minimum valid input
  * **Assert**: Accepted — returns valid output with `test_cases.length` = 1
* **Unit Scenario: UTS-014-B3** (mid: `test_cases.length` = 100)
  * **Arrange**: Configure input so `test_cases.length` evaluates to 100
  * **Act**: Call `generate_itp_cases` with nominal input
  * **Assert**: Accepted — returns valid output with `test_cases.length` = 100
* **Unit Scenario: UTS-014-B4** (max: `test_cases.length` = 200)
  * **Arrange**: Configure input so `test_cases.length` evaluates to 200
  * **Act**: Call `generate_itp_cases` with maximum valid input
  * **Assert**: Accepted — returns valid output with `test_cases.length` = 200
* **Unit Scenario: UTS-014-B5** (max+1: `test_cases.length` = 201)
  * **Arrange**: Configure input so `test_cases.length` evaluates to 201
  * **Act**: Call `generate_itp_cases` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `test_cases.length` exceeds valid range

---

### Module: MOD-015 (Assign ISO Techniques)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `commands/integration-test.md`

#### Test Case: UTP-015-A (Branch paths through assign_iso_techniques)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `assign_iso_techniques`. Branches: technique NOT IN technique_map → RAISE, anchored_view mismatch → correct, view_content NULL/empty → coverage_warning.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-015-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `assign_iso_techniques`
  * **Act**: Call `assign_iso_techniques(test_case, view_data)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-015-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (anchored_view mismatch → correct)
  * **Act**: Call `assign_iso_techniques` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-015-A3** (error-path: NO_TECHNIQUE_MATCH)
  * **Arrange**: Set up input that triggers error condition: Unknown technique name
  * **Act**: Call `assign_iso_techniques` with error-triggering input
  * **Assert**: Raises `NO_TECHNIQUE_MATCH`; no partial output produced

#### Test Case: UTP-015-B (Equivalence partitions for discrete types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition discrete non-scalar variables: `test_case.technique` (Enum: Interface Contract Testing, Data Flow Testing, Interface Fault Injection, Concurrency & Race Condition Testing).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-015-B1** (valid partition: `test_case.technique` = "Interface Contract Testing")
  * **Arrange**: Set `test_case.technique` to `"Interface Contract Testing"`
  * **Act**: Call `assign_iso_techniques` with `test_case.technique` = "Interface Contract Testing"
  * **Assert**: Returns output specific to `test_case.technique` = "Interface Contract Testing" partition
* **Unit Scenario: UTS-015-B2** (valid partition: `test_case.technique` = "Data Flow Testing")
  * **Arrange**: Set `test_case.technique` to `"Data Flow Testing"`
  * **Act**: Call `assign_iso_techniques` with `test_case.technique` = "Data Flow Testing"
  * **Assert**: Returns output specific to `test_case.technique` = "Data Flow Testing" partition
* **Unit Scenario: UTS-015-B3** (valid partition: `test_case.technique` = "Interface Fault Injection")
  * **Arrange**: Set `test_case.technique` to `"Interface Fault Injection"`
  * **Act**: Call `assign_iso_techniques` with `test_case.technique` = "Interface Fault Injection"
  * **Assert**: Returns output specific to `test_case.technique` = "Interface Fault Injection" partition
* **Unit Scenario: UTS-015-B4** (valid partition: `test_case.technique` = "Concurrency & Race Condition Testing")
  * **Arrange**: Set `test_case.technique` to `"Concurrency & Race Condition Testing"`
  * **Act**: Call `assign_iso_techniques` with `test_case.technique` = "Concurrency & Race Condition Testing"
  * **Assert**: Returns output specific to `test_case.technique` = "Concurrency & Race Condition Testing" partition
* **Unit Scenario: UTS-015-B5** (invalid partition: `test_case.technique` = null/unknown)
  * **Arrange**: Set `test_case.technique` to `null` or an undefined value
  * **Act**: Call `assign_iso_techniques` with invalid `test_case.technique`
  * **Assert**: Raises validation error or returns default; invalid partition rejected

---

### Module: MOD-016 (Generate BDD Scenarios)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `commands/integration-test.md`

#### Test Case: UTP-016-A (Branch paths through generate_bdd_scenarios)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `generate_bdd_scenarios`. Branches: technique type switch (4 branches), tests_internal_logic → SCOPE_VIOLATION skip, tests_user_journey → SCOPE_VIOLATION skip.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-016-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `generate_bdd_scenarios`
  * **Act**: Call `generate_bdd_scenarios(test_cases, template_structure)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-016-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (tests_internal_logic → SCOPE_VIOLATION skip)
  * **Act**: Call `generate_bdd_scenarios` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-016-A3** (error-path: SCOPE_VIOLATION)
  * **Arrange**: Set up input that triggers error condition: Scenario tests internal logic
  * **Act**: Call `generate_bdd_scenarios` with error-triggering input
  * **Assert**: Raises `SCOPE_VIOLATION`; no partial output produced

#### Test Case: UTP-016-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `scenarios.length` (1..500), `scenario_index` (1..99).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-016-B1** (min-1: `scenarios.length` = 0)
  * **Arrange**: Configure input so `scenarios.length` evaluates to 0
  * **Act**: Call `generate_bdd_scenarios` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `scenarios.length` below valid range
* **Unit Scenario: UTS-016-B2** (min: `scenarios.length` = 1)
  * **Arrange**: Configure input so `scenarios.length` evaluates to 1
  * **Act**: Call `generate_bdd_scenarios` with minimum valid input
  * **Assert**: Accepted — returns valid output with `scenarios.length` = 1
* **Unit Scenario: UTS-016-B3** (mid: `scenarios.length` = 250)
  * **Arrange**: Configure input so `scenarios.length` evaluates to 250
  * **Act**: Call `generate_bdd_scenarios` with nominal input
  * **Assert**: Accepted — returns valid output with `scenarios.length` = 250
* **Unit Scenario: UTS-016-B4** (max: `scenarios.length` = 500)
  * **Arrange**: Configure input so `scenarios.length` evaluates to 500
  * **Act**: Call `generate_bdd_scenarios` with maximum valid input
  * **Assert**: Accepted — returns valid output with `scenarios.length` = 500
* **Unit Scenario: UTS-016-B5** (max+1: `scenarios.length` = 501)
  * **Arrange**: Configure input so `scenarios.length` evaluates to 501
  * **Act**: Call `generate_bdd_scenarios` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `scenarios.length` exceeds valid range

#### Test Case: UTP-016-C (Equivalence partitions for discrete types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition discrete non-scalar variables: `case.technique` (Enum: Interface Contract Testing, Data Flow Testing, Interface Fault Injection, Concurrency & Race Condition Testing).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-016-C1** (valid partition: `case.technique` = "Interface Contract Testing")
  * **Arrange**: Set `case.technique` to `"Interface Contract Testing"`
  * **Act**: Call `generate_bdd_scenarios` with `case.technique` = "Interface Contract Testing"
  * **Assert**: Returns output specific to `case.technique` = "Interface Contract Testing" partition
* **Unit Scenario: UTS-016-C2** (valid partition: `case.technique` = "Data Flow Testing")
  * **Arrange**: Set `case.technique` to `"Data Flow Testing"`
  * **Act**: Call `generate_bdd_scenarios` with `case.technique` = "Data Flow Testing"
  * **Assert**: Returns output specific to `case.technique` = "Data Flow Testing" partition
* **Unit Scenario: UTS-016-C3** (valid partition: `case.technique` = "Interface Fault Injection")
  * **Arrange**: Set `case.technique` to `"Interface Fault Injection"`
  * **Act**: Call `generate_bdd_scenarios` with `case.technique` = "Interface Fault Injection"
  * **Assert**: Returns output specific to `case.technique` = "Interface Fault Injection" partition
* **Unit Scenario: UTS-016-C4** (valid partition: `case.technique` = "Concurrency & Race Condition Testing")
  * **Arrange**: Set `case.technique` to `"Concurrency & Race Condition Testing"`
  * **Act**: Call `generate_bdd_scenarios` with `case.technique` = "Concurrency & Race Condition Testing"
  * **Assert**: Returns output specific to `case.technique` = "Concurrency & Race Condition Testing" partition
* **Unit Scenario: UTS-016-C5** (invalid partition: `case.technique` = null/unknown)
  * **Arrange**: Set `case.technique` to `null` or an undefined value
  * **Act**: Call `generate_bdd_scenarios` with invalid `case.technique`
  * **Assert**: Raises validation error or returns default; invalid partition rejected

---

### Module: MOD-017 (Invoke Coverage Gate)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `commands/integration-test.md`

#### Test Case: UTP-017-A (Branch paths through invoke_coverage_gate)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `invoke_coverage_gate`. Branches: script_path NULL → return false, json_mode → append --json, exit_code 0 → pass, exit_code 1 → fail with summary, exit_code > 1 → fail with stderr.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| execute_subprocess | ARCH-009 Interface View | Stub: returns predefined (exit_code, stdout, stderr) | Avoid real subprocess execution in unit test |
| resolve_validation_script | ARCH-009 Interface View | Stub: returns fixed path or NULL | Isolate file system lookup |

* **Unit Scenario: UTS-017-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `invoke_coverage_gate`
  * **Act**: Call `invoke_coverage_gate(vmodel_dir, json_mode)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-017-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (json_mode → append --json)
  * **Act**: Call `invoke_coverage_gate` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-017-A3** (error-path: script_path NULL)
  * **Arrange**: Set up input that triggers error condition: Validation script not found
  * **Act**: Call `invoke_coverage_gate` with error-triggering input
  * **Assert**: Raises `script_path NULL`; no partial output produced

#### Test Case: UTP-017-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `exit_code` (0..255).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| execute_subprocess | ARCH-009 Interface View | Stub: returns predefined (exit_code, stdout, stderr) | Avoid real subprocess execution in unit test |
| resolve_validation_script | ARCH-009 Interface View | Stub: returns fixed path or NULL | Isolate file system lookup |

* **Unit Scenario: UTS-017-B1** (min-1: `exit_code` = -1)
  * **Arrange**: Configure input so `exit_code` evaluates to -1
  * **Act**: Call `invoke_coverage_gate` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `exit_code` below valid range
* **Unit Scenario: UTS-017-B2** (min: `exit_code` = 0)
  * **Arrange**: Configure input so `exit_code` evaluates to 0
  * **Act**: Call `invoke_coverage_gate` with minimum valid input
  * **Assert**: Accepted — returns valid output with `exit_code` = 0
* **Unit Scenario: UTS-017-B3** (mid: `exit_code` = 127)
  * **Arrange**: Configure input so `exit_code` evaluates to 127
  * **Act**: Call `invoke_coverage_gate` with nominal input
  * **Assert**: Accepted — returns valid output with `exit_code` = 127
* **Unit Scenario: UTS-017-B4** (max: `exit_code` = 255)
  * **Arrange**: Configure input so `exit_code` evaluates to 255
  * **Act**: Call `invoke_coverage_gate` with maximum valid input
  * **Assert**: Accepted — returns valid output with `exit_code` = 255
* **Unit Scenario: UTS-017-B5** (max+1: `exit_code` = 256)
  * **Arrange**: Configure input so `exit_code` evaluates to 256
  * **Act**: Call `invoke_coverage_gate` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `exit_code` exceeds valid range

#### Test Case: UTP-017-C (Equivalence partitions for discrete types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition discrete non-scalar variables: `json_mode` (Boolean: true/false).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| execute_subprocess | ARCH-009 Interface View | Stub: returns predefined (exit_code, stdout, stderr) | Avoid real subprocess execution in unit test |
| resolve_validation_script | ARCH-009 Interface View | Stub: returns fixed path or NULL | Isolate file system lookup |

* **Unit Scenario: UTS-017-C1** (valid partition: `json_mode` = true)
  * **Arrange**: Set `json_mode` to `true`
  * **Act**: Call `invoke_coverage_gate` with `json_mode` = true
  * **Assert**: True-path logic executes; output reflects `json_mode` = true behavior
* **Unit Scenario: UTS-017-C2** (valid partition: `json_mode` = false)
  * **Arrange**: Set `json_mode` to `false`
  * **Act**: Call `invoke_coverage_gate` with `json_mode` = false
  * **Assert**: False-path logic executes; output reflects `json_mode` = false behavior

#### Test Case: UTP-017-D (Strict isolation of external dependencies)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verify `invoke_coverage_gate` operates correctly with all external dependencies mocked: execute_subprocess, resolve_validation_script.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| execute_subprocess | ARCH-009 Interface View | Stub: returns predefined (exit_code, stdout, stderr) | Avoid real subprocess execution in unit test |
| resolve_validation_script | ARCH-009 Interface View | Stub: returns fixed path or NULL | Isolate file system lookup |

* **Unit Scenario: UTS-017-D1** (all mocks return nominal values)
  * **Arrange**: Configure all mocks (execute_subprocess, resolve_validation_script) to return valid nominal responses
  * **Act**: Call `invoke_coverage_gate` with mocked dependencies
  * **Assert**: Returns expected output; no real external calls made; mock call counts verified
* **Unit Scenario: UTS-017-D2** (mock `execute_subprocess` returns failure)
  * **Arrange**: Configure `execute_subprocess` mock to return error/false; other mocks return nominal
  * **Act**: Call `invoke_coverage_gate` with failing primary dependency
  * **Assert**: Error propagated correctly; no side effects from other mocked dependencies
* **Unit Scenario: UTS-017-D3** (verify zero real I/O calls)
  * **Arrange**: Configure all mocks with call-tracking spies
  * **Act**: Call `invoke_coverage_gate` in fully mocked context
  * **Assert**: All external interactions routed through mocks; spy logs confirm zero real file/network/subprocess calls

---

### Module: MOD-018 (Validate Forward Coverage)

**Parent Architecture Modules**: ARCH-010
**Target Source File(s)**: `scripts/bash/validate-architecture-coverage.sh, scripts/powershell/validate-architecture-coverage.ps1`

#### Test Case: UTP-018-A (Branch paths through validate_forward_coverage)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `validate_forward_coverage`. Branches: system_design_path missing → FILE_NOT_FOUND, arch_design_path missing → FILE_NOT_FOUND, section parsing, CROSS-CUTTING skip, sys_ids empty → coverage 0, coverage percentage calculation.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-010 Interface View | Stub: returns true/false per test case | Isolate file system access |
| read_lines | ARCH-010 Interface View | Stub: returns predefined line arrays | Provide controlled input data |

* **Unit Scenario: UTS-018-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `validate_forward_coverage`
  * **Act**: Call `validate_forward_coverage(system_design_path, arch_design_path, sys_pattern, arch_pattern)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-018-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (arch_design_path missing → FILE_NOT_FOUND)
  * **Act**: Call `validate_forward_coverage` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-018-A3** (error-path: FILE_NOT_FOUND)
  * **Arrange**: Set up input that triggers error condition: system-design.md not found
  * **Act**: Call `validate_forward_coverage` with error-triggering input
  * **Assert**: Raises `FILE_NOT_FOUND`; no partial output produced

#### Test Case: UTP-018-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `sys_ids.length` (0..50), `coverage_pct` (0..100).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-010 Interface View | Stub: returns true/false per test case | Isolate file system access |
| read_lines | ARCH-010 Interface View | Stub: returns predefined line arrays | Provide controlled input data |

* **Unit Scenario: UTS-018-B1** (min-1: `sys_ids.length` = -1)
  * **Arrange**: Configure input so `sys_ids.length` evaluates to -1
  * **Act**: Call `validate_forward_coverage` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `sys_ids.length` below valid range
* **Unit Scenario: UTS-018-B2** (min: `sys_ids.length` = 0)
  * **Arrange**: Configure input so `sys_ids.length` evaluates to 0
  * **Act**: Call `validate_forward_coverage` with minimum valid input
  * **Assert**: Accepted — returns valid output with `sys_ids.length` = 0
* **Unit Scenario: UTS-018-B3** (mid: `sys_ids.length` = 25)
  * **Arrange**: Configure input so `sys_ids.length` evaluates to 25
  * **Act**: Call `validate_forward_coverage` with nominal input
  * **Assert**: Accepted — returns valid output with `sys_ids.length` = 25
* **Unit Scenario: UTS-018-B4** (max: `sys_ids.length` = 50)
  * **Arrange**: Configure input so `sys_ids.length` evaluates to 50
  * **Act**: Call `validate_forward_coverage` with maximum valid input
  * **Assert**: Accepted — returns valid output with `sys_ids.length` = 50
* **Unit Scenario: UTS-018-B5** (max+1: `sys_ids.length` = 51)
  * **Arrange**: Configure input so `sys_ids.length` evaluates to 51
  * **Act**: Call `validate_forward_coverage` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `sys_ids.length` exceeds valid range

#### Test Case: UTP-018-C (Equivalence partitions for discrete types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition discrete non-scalar variables: `in_decomposition` (Boolean: true/false); `in_logical` (Boolean: true/false).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-010 Interface View | Stub: returns true/false per test case | Isolate file system access |
| read_lines | ARCH-010 Interface View | Stub: returns predefined line arrays | Provide controlled input data |

* **Unit Scenario: UTS-018-C1** (valid partition: `in_decomposition` = true)
  * **Arrange**: Set `in_decomposition` to `true`
  * **Act**: Call `validate_forward_coverage` with `in_decomposition` = true
  * **Assert**: True-path logic executes; output reflects `in_decomposition` = true behavior
* **Unit Scenario: UTS-018-C2** (valid partition: `in_decomposition` = false)
  * **Arrange**: Set `in_decomposition` to `false`
  * **Act**: Call `validate_forward_coverage` with `in_decomposition` = false
  * **Assert**: False-path logic executes; output reflects `in_decomposition` = false behavior
* **Unit Scenario: UTS-018-C3** (valid partition: `in_logical` = true)
  * **Arrange**: Set `in_logical` to `true`
  * **Act**: Call `validate_forward_coverage` with `in_logical` = true
  * **Assert**: True-path logic executes; output reflects `in_logical` = true behavior
* **Unit Scenario: UTS-018-C4** (valid partition: `in_logical` = false)
  * **Arrange**: Set `in_logical` to `false`
  * **Act**: Call `validate_forward_coverage` with `in_logical` = false
  * **Assert**: False-path logic executes; output reflects `in_logical` = false behavior

#### Test Case: UTP-018-D (Strict isolation of external dependencies)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verify `validate_forward_coverage` operates correctly with all external dependencies mocked: file_exists, read_lines.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-010 Interface View | Stub: returns true/false per test case | Isolate file system access |
| read_lines | ARCH-010 Interface View | Stub: returns predefined line arrays | Provide controlled input data |

* **Unit Scenario: UTS-018-D1** (all mocks return nominal values)
  * **Arrange**: Configure all mocks (file_exists, read_lines) to return valid nominal responses
  * **Act**: Call `validate_forward_coverage` with mocked dependencies
  * **Assert**: Returns expected output; no real external calls made; mock call counts verified
* **Unit Scenario: UTS-018-D2** (mock `file_exists` returns failure)
  * **Arrange**: Configure `file_exists` mock to return error/false; other mocks return nominal
  * **Act**: Call `validate_forward_coverage` with failing primary dependency
  * **Assert**: Error propagated correctly; no side effects from other mocked dependencies
* **Unit Scenario: UTS-018-D3** (verify zero real I/O calls)
  * **Arrange**: Configure all mocks with call-tracking spies
  * **Act**: Call `validate_forward_coverage` in fully mocked context
  * **Assert**: All external interactions routed through mocks; spy logs confirm zero real file/network/subprocess calls

---

### Module: MOD-019 (Validate Backward Coverage)

**Parent Architecture Modules**: ARCH-011
**Target Source File(s)**: `scripts/bash/validate-architecture-coverage.sh, scripts/powershell/validate-architecture-coverage.ps1`

#### Test Case: UTP-019-A (Branch paths through validate_backward_coverage)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `validate_backward_coverage`. Branches: arch_design_path missing → FILE_NOT_FOUND, integration_test_path missing → partial_mode, normal mode parsing, ITP matching per ARCH, coverage calculation, empty arch_ids → 0%.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-011 Interface View | Stub: returns true/false per test case | Isolate file system access |
| read_lines | ARCH-011 Interface View | Stub: returns predefined line arrays | Provide controlled input data |

* **Unit Scenario: UTS-019-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `validate_backward_coverage`
  * **Act**: Call `validate_backward_coverage(arch_design_path, integration_test_path, arch_pattern, itp_pattern)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-019-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (integration_test_path missing → partial_mode)
  * **Act**: Call `validate_backward_coverage` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-019-A3** (error-path: FILE_NOT_FOUND)
  * **Arrange**: Set up input that triggers error condition: architecture-design.md not found
  * **Act**: Call `validate_backward_coverage` with error-triggering input
  * **Assert**: Raises `FILE_NOT_FOUND`; no partial output produced

#### Test Case: UTP-019-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `arch_ids.length` (0..100), `itp_ids.length` (0..500), `coverage_pct` (0..100).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-011 Interface View | Stub: returns true/false per test case | Isolate file system access |
| read_lines | ARCH-011 Interface View | Stub: returns predefined line arrays | Provide controlled input data |

* **Unit Scenario: UTS-019-B1** (min-1: `arch_ids.length` = -1)
  * **Arrange**: Configure input so `arch_ids.length` evaluates to -1
  * **Act**: Call `validate_backward_coverage` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `arch_ids.length` below valid range
* **Unit Scenario: UTS-019-B2** (min: `arch_ids.length` = 0)
  * **Arrange**: Configure input so `arch_ids.length` evaluates to 0
  * **Act**: Call `validate_backward_coverage` with minimum valid input
  * **Assert**: Accepted — returns valid output with `arch_ids.length` = 0
* **Unit Scenario: UTS-019-B3** (mid: `arch_ids.length` = 50)
  * **Arrange**: Configure input so `arch_ids.length` evaluates to 50
  * **Act**: Call `validate_backward_coverage` with nominal input
  * **Assert**: Accepted — returns valid output with `arch_ids.length` = 50
* **Unit Scenario: UTS-019-B4** (max: `arch_ids.length` = 100)
  * **Arrange**: Configure input so `arch_ids.length` evaluates to 100
  * **Act**: Call `validate_backward_coverage` with maximum valid input
  * **Assert**: Accepted — returns valid output with `arch_ids.length` = 100
* **Unit Scenario: UTS-019-B5** (max+1: `arch_ids.length` = 101)
  * **Arrange**: Configure input so `arch_ids.length` evaluates to 101
  * **Act**: Call `validate_backward_coverage` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `arch_ids.length` exceeds valid range

#### Test Case: UTP-019-C (Equivalence partitions for discrete types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition discrete non-scalar variables: `partial_mode` (Boolean: true/false); `in_logical` (Boolean: true/false).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-011 Interface View | Stub: returns true/false per test case | Isolate file system access |
| read_lines | ARCH-011 Interface View | Stub: returns predefined line arrays | Provide controlled input data |

* **Unit Scenario: UTS-019-C1** (valid partition: `partial_mode` = true)
  * **Arrange**: Set `partial_mode` to `true`
  * **Act**: Call `validate_backward_coverage` with `partial_mode` = true
  * **Assert**: True-path logic executes; output reflects `partial_mode` = true behavior
* **Unit Scenario: UTS-019-C2** (valid partition: `partial_mode` = false)
  * **Arrange**: Set `partial_mode` to `false`
  * **Act**: Call `validate_backward_coverage` with `partial_mode` = false
  * **Assert**: False-path logic executes; output reflects `partial_mode` = false behavior
* **Unit Scenario: UTS-019-C3** (valid partition: `in_logical` = true)
  * **Arrange**: Set `in_logical` to `true`
  * **Act**: Call `validate_backward_coverage` with `in_logical` = true
  * **Assert**: True-path logic executes; output reflects `in_logical` = true behavior
* **Unit Scenario: UTS-019-C4** (valid partition: `in_logical` = false)
  * **Arrange**: Set `in_logical` to `false`
  * **Act**: Call `validate_backward_coverage` with `in_logical` = false
  * **Assert**: False-path logic executes; output reflects `in_logical` = false behavior

#### Test Case: UTP-019-D (Strict isolation of external dependencies)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verify `validate_backward_coverage` operates correctly with all external dependencies mocked: file_exists, read_lines.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-011 Interface View | Stub: returns true/false per test case | Isolate file system access |
| read_lines | ARCH-011 Interface View | Stub: returns predefined line arrays | Provide controlled input data |

* **Unit Scenario: UTS-019-D1** (all mocks return nominal values)
  * **Arrange**: Configure all mocks (file_exists, read_lines) to return valid nominal responses
  * **Act**: Call `validate_backward_coverage` with mocked dependencies
  * **Assert**: Returns expected output; no real external calls made; mock call counts verified
* **Unit Scenario: UTS-019-D2** (mock `file_exists` returns failure)
  * **Arrange**: Configure `file_exists` mock to return error/false; other mocks return nominal
  * **Act**: Call `validate_backward_coverage` with failing primary dependency
  * **Assert**: Error propagated correctly; no side effects from other mocked dependencies
* **Unit Scenario: UTS-019-D3** (verify zero real I/O calls)
  * **Arrange**: Configure all mocks with call-tracking spies
  * **Act**: Call `validate_backward_coverage` in fully mocked context
  * **Assert**: All external interactions routed through mocks; spy logs confirm zero real file/network/subprocess calls

---

### Module: MOD-020 (Detect Orphaned Identifiers)

**Parent Architecture Modules**: ARCH-012
**Target Source File(s)**: `scripts/bash/validate-architecture-coverage.sh, scripts/powershell/validate-architecture-coverage.ps1`

#### Test Case: UTP-020-A (Branch paths through detect_orphaned_identifiers)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `detect_orphaned_identifiers`. Branches: is_cross_cutting → skip, parent_sys NOT IN sys_ids → orphaned, itp_ids empty → skip ITP check, parent_arch NOT IN known_arch_ids → orphaned ITP.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-020-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `detect_orphaned_identifiers`
  * **Act**: Call `detect_orphaned_identifiers(sys_ids, arch_data, itp_ids, arch_pattern)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-020-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (parent_sys NOT IN sys_ids → orphaned)
  * **Act**: Call `detect_orphaned_identifiers` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries

#### Test Case: UTP-020-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `orphaned_arch.length` (0..50), `orphaned_itps.length` (0..200).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-020-B1** (min-1: `orphaned_arch.length` = -1)
  * **Arrange**: Configure input so `orphaned_arch.length` evaluates to -1
  * **Act**: Call `detect_orphaned_identifiers` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `orphaned_arch.length` below valid range
* **Unit Scenario: UTS-020-B2** (min: `orphaned_arch.length` = 0)
  * **Arrange**: Configure input so `orphaned_arch.length` evaluates to 0
  * **Act**: Call `detect_orphaned_identifiers` with minimum valid input
  * **Assert**: Accepted — returns valid output with `orphaned_arch.length` = 0
* **Unit Scenario: UTS-020-B3** (mid: `orphaned_arch.length` = 25)
  * **Arrange**: Configure input so `orphaned_arch.length` evaluates to 25
  * **Act**: Call `detect_orphaned_identifiers` with nominal input
  * **Assert**: Accepted — returns valid output with `orphaned_arch.length` = 25
* **Unit Scenario: UTS-020-B4** (max: `orphaned_arch.length` = 50)
  * **Arrange**: Configure input so `orphaned_arch.length` evaluates to 50
  * **Act**: Call `detect_orphaned_identifiers` with maximum valid input
  * **Assert**: Accepted — returns valid output with `orphaned_arch.length` = 50
* **Unit Scenario: UTS-020-B5** (max+1: `orphaned_arch.length` = 51)
  * **Arrange**: Configure input so `orphaned_arch.length` evaluates to 51
  * **Act**: Call `detect_orphaned_identifiers` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `orphaned_arch.length` exceeds valid range

---

### Module: MOD-021 (Detect Circular Dependencies)

**Parent Architecture Modules**: ARCH-012
**Target Source File(s)**: `scripts/bash/validate-architecture-coverage.sh, scripts/powershell/validate-architecture-coverage.ps1`

#### Test Case: UTP-021-A (Branch paths through detect_circular_dependencies)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `detect_circular_dependencies`. Branches: ARCH pattern match vs alias match, alias resolution NULL check, DFS: unvisited → recurse, visited AND in rec_stack → cycle detected, no cycles → empty return.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-021-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `detect_circular_dependencies`
  * **Act**: Call `detect_circular_dependencies(process_view_content, arch_pattern)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-021-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (alias resolution NULL check)
  * **Act**: Call `detect_circular_dependencies` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries

#### Test Case: UTP-021-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `adjacency.size` (0..100), `circular_chains.length` (0..20).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-021-B1** (min-1: `adjacency.size` = -1)
  * **Arrange**: Configure input so `adjacency.size` evaluates to -1
  * **Act**: Call `detect_circular_dependencies` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `adjacency.size` below valid range
* **Unit Scenario: UTS-021-B2** (min: `adjacency.size` = 0)
  * **Arrange**: Configure input so `adjacency.size` evaluates to 0
  * **Act**: Call `detect_circular_dependencies` with minimum valid input
  * **Assert**: Accepted — returns valid output with `adjacency.size` = 0
* **Unit Scenario: UTS-021-B3** (mid: `adjacency.size` = 50)
  * **Arrange**: Configure input so `adjacency.size` evaluates to 50
  * **Act**: Call `detect_circular_dependencies` with nominal input
  * **Assert**: Accepted — returns valid output with `adjacency.size` = 50
* **Unit Scenario: UTS-021-B4** (max: `adjacency.size` = 100)
  * **Arrange**: Configure input so `adjacency.size` evaluates to 100
  * **Act**: Call `detect_circular_dependencies` with maximum valid input
  * **Assert**: Accepted — returns valid output with `adjacency.size` = 100
* **Unit Scenario: UTS-021-B5** (max+1: `adjacency.size` = 101)
  * **Arrange**: Configure input so `adjacency.size` evaluates to 101
  * **Act**: Call `detect_circular_dependencies` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `adjacency.size` exceeds valid range

---

### Module: MOD-022 (Format Coverage Report)

**Parent Architecture Modules**: ARCH-013
**Target Source File(s)**: `scripts/bash/validate-architecture-coverage.sh, scripts/powershell/validate-architecture-coverage.ps1`

#### Test Case: UTP-022-A (Branch paths through format_coverage_report)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `format_coverage_report`. Branches: json_mode → serialize JSON, text mode: partial_mode → SKIPPED, uncovered_sys > 0 → list, uncovered_arch > 0 → list, orphaned_arch > 0 → list, orphaned_itps > 0 → list.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-022-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `format_coverage_report`
  * **Act**: Call `format_coverage_report(forward_result, backward_result, orphan_result, json_mode)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-022-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (text mode: partial_mode → SKIPPED)
  * **Act**: Call `format_coverage_report` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries

#### Test Case: UTP-022-B (Equivalence partitions for discrete types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition discrete non-scalar variables: `json_mode` (Boolean: true/false).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-022-B1** (valid partition: `json_mode` = true)
  * **Arrange**: Set `json_mode` to `true`
  * **Act**: Call `format_coverage_report` with `json_mode` = true
  * **Assert**: True-path logic executes; output reflects `json_mode` = true behavior
* **Unit Scenario: UTS-022-B2** (valid partition: `json_mode` = false)
  * **Arrange**: Set `json_mode` to `false`
  * **Act**: Call `format_coverage_report` with `json_mode` = false
  * **Assert**: False-path logic executes; output reflects `json_mode` = false behavior

---

### Module: MOD-023 (Compute Coverage Verdict)

**Parent Architecture Modules**: ARCH-013
**Target Source File(s)**: `scripts/bash/validate-architecture-coverage.sh, scripts/powershell/validate-architecture-coverage.ps1`

#### Test Case: UTP-023-A (Branch paths through compute_coverage_verdict)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `compute_coverage_verdict`. Branches: uncovered_sys > 0 → gap, NOT partial_mode AND uncovered_arch > 0 → gap, orphaned_arch > 0 → gap, orphaned_itps > 0 → gap, circular_deps > 0 → gap, has_gaps → return 1, else → return 0.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-023-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `compute_coverage_verdict`
  * **Act**: Call `compute_coverage_verdict(forward_result, backward_result, orphan_result)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-023-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (NOT partial_mode AND uncovered_arch > 0 → gap)
  * **Act**: Call `compute_coverage_verdict` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-023-A3** (error-path: Exit code 1)
  * **Arrange**: Set up input that triggers error condition: Any gap detected
  * **Act**: Call `compute_coverage_verdict` with error-triggering input
  * **Assert**: Raises `Exit code 1`; no partial output produced

#### Test Case: UTP-023-B (Equivalence partitions for discrete types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition discrete non-scalar variables: `has_gaps` (Boolean: true/false).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-023-B1** (valid partition: `has_gaps` = true)
  * **Arrange**: Set `has_gaps` to `true`
  * **Act**: Call `compute_coverage_verdict` with `has_gaps` = true
  * **Assert**: True-path logic executes; output reflects `has_gaps` = true behavior
* **Unit Scenario: UTS-023-B2** (valid partition: `has_gaps` = false)
  * **Arrange**: Set `has_gaps` to `false`
  * **Act**: Call `compute_coverage_verdict` with `has_gaps` = false
  * **Assert**: False-path logic executes; output reflects `has_gaps` = false behavior

---

### Module: MOD-024 (Load Architecture Template)

**Parent Architecture Modules**: ARCH-014
**Target Source File(s)**: `templates/architecture-design-template.md`

#### Test Case: UTP-024-A (Branch paths through load_architecture_template)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `load_architecture_template`. Branches: file missing → TEMPLATE_NOT_FOUND, content empty → TEMPLATE_NOT_FOUND, each of 4 mandatory sections missing → TEMPLATE_NOT_FOUND, all present → return content.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-014 Interface View | Stub: returns true/false | Isolate file system |
| read_file | ARCH-014 Interface View | Stub: returns predefined template content | Provide controlled template data |

* **Unit Scenario: UTS-024-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `load_architecture_template`
  * **Act**: Call `load_architecture_template(template_dir)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-024-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (content empty → TEMPLATE_NOT_FOUND)
  * **Act**: Call `load_architecture_template` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-024-A3** (error-path: TEMPLATE_NOT_FOUND)
  * **Arrange**: Set up input that triggers error condition: Template file missing
  * **Act**: Call `load_architecture_template` with error-triggering input
  * **Assert**: Raises `TEMPLATE_NOT_FOUND`; no partial output produced

#### Test Case: UTP-024-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `content.length` (1..50000).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-014 Interface View | Stub: returns true/false | Isolate file system |
| read_file | ARCH-014 Interface View | Stub: returns predefined template content | Provide controlled template data |

* **Unit Scenario: UTS-024-B1** (min-1: `content.length` = 0)
  * **Arrange**: Configure input so `content.length` evaluates to 0
  * **Act**: Call `load_architecture_template` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `content.length` below valid range
* **Unit Scenario: UTS-024-B2** (min: `content.length` = 1)
  * **Arrange**: Configure input so `content.length` evaluates to 1
  * **Act**: Call `load_architecture_template` with minimum valid input
  * **Assert**: Accepted — returns valid output with `content.length` = 1
* **Unit Scenario: UTS-024-B3** (mid: `content.length` = 25000)
  * **Arrange**: Configure input so `content.length` evaluates to 25000
  * **Act**: Call `load_architecture_template` with nominal input
  * **Assert**: Accepted — returns valid output with `content.length` = 25000
* **Unit Scenario: UTS-024-B4** (max: `content.length` = 50000)
  * **Arrange**: Configure input so `content.length` evaluates to 50000
  * **Act**: Call `load_architecture_template` with maximum valid input
  * **Assert**: Accepted — returns valid output with `content.length` = 50000
* **Unit Scenario: UTS-024-B5** (max+1: `content.length` = 50001)
  * **Arrange**: Configure input so `content.length` evaluates to 50001
  * **Act**: Call `load_architecture_template` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `content.length` exceeds valid range

#### Test Case: UTP-024-C (Strict isolation of external dependencies)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verify `load_architecture_template` operates correctly with all external dependencies mocked: file_exists, read_file.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-014 Interface View | Stub: returns true/false | Isolate file system |
| read_file | ARCH-014 Interface View | Stub: returns predefined template content | Provide controlled template data |

* **Unit Scenario: UTS-024-C1** (all mocks return nominal values)
  * **Arrange**: Configure all mocks (file_exists, read_file) to return valid nominal responses
  * **Act**: Call `load_architecture_template` with mocked dependencies
  * **Assert**: Returns expected output; no real external calls made; mock call counts verified
* **Unit Scenario: UTS-024-C2** (mock `file_exists` returns failure)
  * **Arrange**: Configure `file_exists` mock to return error/false; other mocks return nominal
  * **Act**: Call `load_architecture_template` with failing primary dependency
  * **Assert**: Error propagated correctly; no side effects from other mocked dependencies
* **Unit Scenario: UTS-024-C3** (verify zero real I/O calls)
  * **Arrange**: Configure all mocks with call-tracking spies
  * **Act**: Call `load_architecture_template` in fully mocked context
  * **Assert**: All external interactions routed through mocks; spy logs confirm zero real file/network/subprocess calls

---

### Module: MOD-025 (Load Integration Test Template)

**Parent Architecture Modules**: ARCH-015
**Target Source File(s)**: `templates/integration-test-template.md`

#### Test Case: UTP-025-A (Branch paths through load_integration_test_template)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `load_integration_test_template`. Branches: file missing → TEMPLATE_NOT_FOUND, content empty → TEMPLATE_NOT_FOUND, each of 4 required elements missing → TEMPLATE_NOT_FOUND, all present → return content.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-015 Interface View | Stub: returns true/false | Isolate file system |
| read_file | ARCH-015 Interface View | Stub: returns predefined template content | Provide controlled template data |

* **Unit Scenario: UTS-025-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `load_integration_test_template`
  * **Act**: Call `load_integration_test_template(template_dir)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-025-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (content empty → TEMPLATE_NOT_FOUND)
  * **Act**: Call `load_integration_test_template` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-025-A3** (error-path: TEMPLATE_NOT_FOUND)
  * **Arrange**: Set up input that triggers error condition: Template file missing
  * **Act**: Call `load_integration_test_template` with error-triggering input
  * **Assert**: Raises `TEMPLATE_NOT_FOUND`; no partial output produced

#### Test Case: UTP-025-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `content.length` (1..50000).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-015 Interface View | Stub: returns true/false | Isolate file system |
| read_file | ARCH-015 Interface View | Stub: returns predefined template content | Provide controlled template data |

* **Unit Scenario: UTS-025-B1** (min-1: `content.length` = 0)
  * **Arrange**: Configure input so `content.length` evaluates to 0
  * **Act**: Call `load_integration_test_template` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `content.length` below valid range
* **Unit Scenario: UTS-025-B2** (min: `content.length` = 1)
  * **Arrange**: Configure input so `content.length` evaluates to 1
  * **Act**: Call `load_integration_test_template` with minimum valid input
  * **Assert**: Accepted — returns valid output with `content.length` = 1
* **Unit Scenario: UTS-025-B3** (mid: `content.length` = 25000)
  * **Arrange**: Configure input so `content.length` evaluates to 25000
  * **Act**: Call `load_integration_test_template` with nominal input
  * **Assert**: Accepted — returns valid output with `content.length` = 25000
* **Unit Scenario: UTS-025-B4** (max: `content.length` = 50000)
  * **Arrange**: Configure input so `content.length` evaluates to 50000
  * **Act**: Call `load_integration_test_template` with maximum valid input
  * **Assert**: Accepted — returns valid output with `content.length` = 50000
* **Unit Scenario: UTS-025-B5** (max+1: `content.length` = 50001)
  * **Arrange**: Configure input so `content.length` evaluates to 50001
  * **Act**: Call `load_integration_test_template` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `content.length` exceeds valid range

#### Test Case: UTP-025-C (Strict isolation of external dependencies)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verify `load_integration_test_template` operates correctly with all external dependencies mocked: file_exists, read_file.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-015 Interface View | Stub: returns true/false | Isolate file system |
| read_file | ARCH-015 Interface View | Stub: returns predefined template content | Provide controlled template data |

* **Unit Scenario: UTS-025-C1** (all mocks return nominal values)
  * **Arrange**: Configure all mocks (file_exists, read_file) to return valid nominal responses
  * **Act**: Call `load_integration_test_template` with mocked dependencies
  * **Assert**: Returns expected output; no real external calls made; mock call counts verified
* **Unit Scenario: UTS-025-C2** (mock `file_exists` returns failure)
  * **Arrange**: Configure `file_exists` mock to return error/false; other mocks return nominal
  * **Act**: Call `load_integration_test_template` with failing primary dependency
  * **Assert**: Error propagated correctly; no side effects from other mocked dependencies
* **Unit Scenario: UTS-025-C3** (verify zero real I/O calls)
  * **Arrange**: Configure all mocks with call-tracking spies
  * **Act**: Call `load_integration_test_template` in fully mocked context
  * **Assert**: All external interactions routed through mocks; spy logs confirm zero real file/network/subprocess calls

---

### Module: MOD-026 (Generate Matrix C Table)

**Parent Architecture Modules**: ARCH-016
**Target Source File(s)**: `commands/trace.md`

#### Test Case: UTP-026-A (Branch paths through generate_matrix_c_table)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `generate_matrix_c_table`. Branches: empty mapping → EMPTY_MAPPING, req_list > 0 → annotated cell, cross-cutting pseudo-rows append, coverage calculation with total_arch 0 guard.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-026-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `generate_matrix_c_table`
  * **Act**: Call `generate_matrix_c_table(mapping_data, req_references)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-026-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (req_list > 0 → annotated cell)
  * **Act**: Call `generate_matrix_c_table` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-026-A3** (error-path: EMPTY_MAPPING)
  * **Arrange**: Set up input that triggers error condition: Empty mapping data
  * **Act**: Call `generate_matrix_c_table` with error-triggering input
  * **Assert**: Raises `EMPTY_MAPPING`; no partial output produced

#### Test Case: UTP-026-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `rows.length` (1..200), `coverage_pct` (0..100).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-026-B1** (min-1: `rows.length` = 0)
  * **Arrange**: Configure input so `rows.length` evaluates to 0
  * **Act**: Call `generate_matrix_c_table` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `rows.length` below valid range
* **Unit Scenario: UTS-026-B2** (min: `rows.length` = 1)
  * **Arrange**: Configure input so `rows.length` evaluates to 1
  * **Act**: Call `generate_matrix_c_table` with minimum valid input
  * **Assert**: Accepted — returns valid output with `rows.length` = 1
* **Unit Scenario: UTS-026-B3** (mid: `rows.length` = 100)
  * **Arrange**: Configure input so `rows.length` evaluates to 100
  * **Act**: Call `generate_matrix_c_table` with nominal input
  * **Assert**: Accepted — returns valid output with `rows.length` = 100
* **Unit Scenario: UTS-026-B4** (max: `rows.length` = 200)
  * **Arrange**: Configure input so `rows.length` evaluates to 200
  * **Act**: Call `generate_matrix_c_table` with maximum valid input
  * **Assert**: Accepted — returns valid output with `rows.length` = 200
* **Unit Scenario: UTS-026-B5** (max+1: `rows.length` = 201)
  * **Arrange**: Configure input so `rows.length` evaluates to 201
  * **Act**: Call `generate_matrix_c_table` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `rows.length` exceeds valid range

---

### Module: MOD-027 (Generate Cross-Cutting Pseudo-Rows)

**Parent Architecture Modules**: ARCH-016
**Target Source File(s)**: `commands/trace.md`

#### Test Case: UTP-027-A (Branch paths through generate_cross_cutting_pseudo_rows)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `generate_cross_cutting_pseudo_rows`. Branches: is_cross_cutting → generate row, not cross-cutting → skip, no cross-cutting entries → empty return.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-027-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `generate_cross_cutting_pseudo_rows`
  * **Act**: Call `generate_cross_cutting_pseudo_rows(mapping_data)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-027-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (not cross-cutting → skip)
  * **Act**: Call `generate_cross_cutting_pseudo_rows` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries

#### Test Case: UTP-027-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `rows.length` (0..20).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-027-B1** (min-1: `rows.length` = -1)
  * **Arrange**: Configure input so `rows.length` evaluates to -1
  * **Act**: Call `generate_cross_cutting_pseudo_rows` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `rows.length` below valid range
* **Unit Scenario: UTS-027-B2** (min: `rows.length` = 0)
  * **Arrange**: Configure input so `rows.length` evaluates to 0
  * **Act**: Call `generate_cross_cutting_pseudo_rows` with minimum valid input
  * **Assert**: Accepted — returns valid output with `rows.length` = 0
* **Unit Scenario: UTS-027-B3** (mid: `rows.length` = 10)
  * **Arrange**: Configure input so `rows.length` evaluates to 10
  * **Act**: Call `generate_cross_cutting_pseudo_rows` with nominal input
  * **Assert**: Accepted — returns valid output with `rows.length` = 10
* **Unit Scenario: UTS-027-B4** (max: `rows.length` = 20)
  * **Arrange**: Configure input so `rows.length` evaluates to 20
  * **Act**: Call `generate_cross_cutting_pseudo_rows` with maximum valid input
  * **Assert**: Accepted — returns valid output with `rows.length` = 20
* **Unit Scenario: UTS-027-B5** (max+1: `rows.length` = 21)
  * **Arrange**: Configure input so `rows.length` evaluates to 21
  * **Act**: Call `generate_cross_cutting_pseudo_rows` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `rows.length` exceeds valid range

---

### Module: MOD-028 (Determine Assembly Level)

**Parent Architecture Modules**: ARCH-017
**Target Source File(s)**: `commands/trace.md`

#### Test Case: UTP-028-A (Branch paths through determine_assembly_level)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `determine_assembly_level`. Branches: has_architecture AND has_integration_test → A+B+C, ELSE has_system_test → A+B, ELSE has_acceptance → A, ELSE → NONE.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-028-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `determine_assembly_level`
  * **Act**: Call `determine_assembly_level(available_artifacts)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-028-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (ELSE has_system_test → A+B)
  * **Act**: Call `determine_assembly_level` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries

#### Test Case: UTP-028-B (Equivalence partitions for discrete types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition discrete non-scalar variables: `has_acceptance` (Boolean: true/false); `has_system_test` (Boolean: true/false); `has_architecture` (Boolean: true/false); `has_integration_test` (Boolean: true/false); `return_value` (Enum: A+B+C, A+B, A, NONE).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-028-B1** (valid partition: `has_acceptance` = true)
  * **Arrange**: Set `has_acceptance` to `true`
  * **Act**: Call `determine_assembly_level` with `has_acceptance` = true
  * **Assert**: True-path logic executes; output reflects `has_acceptance` = true behavior
* **Unit Scenario: UTS-028-B2** (valid partition: `has_acceptance` = false)
  * **Arrange**: Set `has_acceptance` to `false`
  * **Act**: Call `determine_assembly_level` with `has_acceptance` = false
  * **Assert**: False-path logic executes; output reflects `has_acceptance` = false behavior
* **Unit Scenario: UTS-028-B3** (valid partition: `has_system_test` = true)
  * **Arrange**: Set `has_system_test` to `true`
  * **Act**: Call `determine_assembly_level` with `has_system_test` = true
  * **Assert**: True-path logic executes; output reflects `has_system_test` = true behavior
* **Unit Scenario: UTS-028-B4** (valid partition: `has_system_test` = false)
  * **Arrange**: Set `has_system_test` to `false`
  * **Act**: Call `determine_assembly_level` with `has_system_test` = false
  * **Assert**: False-path logic executes; output reflects `has_system_test` = false behavior
* **Unit Scenario: UTS-028-B5** (valid partition: `has_architecture` = true)
  * **Arrange**: Set `has_architecture` to `true`
  * **Act**: Call `determine_assembly_level` with `has_architecture` = true
  * **Assert**: True-path logic executes; output reflects `has_architecture` = true behavior
* **Unit Scenario: UTS-028-B6** (valid partition: `has_architecture` = false)
  * **Arrange**: Set `has_architecture` to `false`
  * **Act**: Call `determine_assembly_level` with `has_architecture` = false
  * **Assert**: False-path logic executes; output reflects `has_architecture` = false behavior
* **Unit Scenario: UTS-028-B7** (valid partition: `has_integration_test` = true)
  * **Arrange**: Set `has_integration_test` to `true`
  * **Act**: Call `determine_assembly_level` with `has_integration_test` = true
  * **Assert**: True-path logic executes; output reflects `has_integration_test` = true behavior
* **Unit Scenario: UTS-028-B8** (valid partition: `has_integration_test` = false)
  * **Arrange**: Set `has_integration_test` to `false`
  * **Act**: Call `determine_assembly_level` with `has_integration_test` = false
  * **Assert**: False-path logic executes; output reflects `has_integration_test` = false behavior
* **Unit Scenario: UTS-028-B9** (valid partition: `return_value` = "A+B+C")
  * **Arrange**: Set `return_value` to `"A+B+C"`
  * **Act**: Call `determine_assembly_level` with `return_value` = "A+B+C"
  * **Assert**: Returns output specific to `return_value` = "A+B+C" partition
* **Unit Scenario: UTS-028-B10** (valid partition: `return_value` = "A+B")
  * **Arrange**: Set `return_value` to `"A+B"`
  * **Act**: Call `determine_assembly_level` with `return_value` = "A+B"
  * **Assert**: Returns output specific to `return_value` = "A+B" partition
* **Unit Scenario: UTS-028-B11** (valid partition: `return_value` = "A")
  * **Arrange**: Set `return_value` to `"A"`
  * **Act**: Call `determine_assembly_level` with `return_value` = "A"
  * **Assert**: Returns output specific to `return_value` = "A" partition
* **Unit Scenario: UTS-028-B12** (valid partition: `return_value` = "NONE")
  * **Arrange**: Set `return_value` to `"NONE"`
  * **Act**: Call `determine_assembly_level` with `return_value` = "NONE"
  * **Assert**: Returns output specific to `return_value` = "NONE" partition
* **Unit Scenario: UTS-028-B13** (invalid partition: `return_value` = null/unknown)
  * **Arrange**: Set `return_value` to `null` or an undefined value
  * **Act**: Call `determine_assembly_level` with invalid `return_value`
  * **Assert**: Raises validation error or returns default; invalid partition rejected

---

### Module: MOD-029 (Assemble Progressive Matrix)

**Parent Architecture Modules**: ARCH-017
**Target Source File(s)**: `commands/trace.md`

#### Test Case: UTP-029-A (Branch paths through assemble_progressive_matrix)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `assemble_progressive_matrix`. Branches: level NONE → no artifacts message, level includes A → append matrix_a, level includes B → append matrix_b, level includes C → append matrix_c.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-029-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `assemble_progressive_matrix`
  * **Act**: Call `assemble_progressive_matrix(level, matrix_a, matrix_b, matrix_c)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-029-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (level includes A → append matrix_a)
  * **Act**: Call `assemble_progressive_matrix` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries

#### Test Case: UTP-029-B (Equivalence partitions for discrete types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition discrete non-scalar variables: `level` (Enum: NONE, A, A+B, A+B+C).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-029-B1** (valid partition: `level` = "NONE")
  * **Arrange**: Set `level` to `"NONE"`
  * **Act**: Call `assemble_progressive_matrix` with `level` = "NONE"
  * **Assert**: Returns output specific to `level` = "NONE" partition
* **Unit Scenario: UTS-029-B2** (valid partition: `level` = "A")
  * **Arrange**: Set `level` to `"A"`
  * **Act**: Call `assemble_progressive_matrix` with `level` = "A"
  * **Assert**: Returns output specific to `level` = "A" partition
* **Unit Scenario: UTS-029-B3** (valid partition: `level` = "A+B")
  * **Arrange**: Set `level` to `"A+B"`
  * **Act**: Call `assemble_progressive_matrix` with `level` = "A+B"
  * **Assert**: Returns output specific to `level` = "A+B" partition
* **Unit Scenario: UTS-029-B4** (valid partition: `level` = "A+B+C")
  * **Arrange**: Set `level` to `"A+B+C"`
  * **Act**: Call `assemble_progressive_matrix` with `level` = "A+B+C"
  * **Assert**: Returns output specific to `level` = "A+B+C" partition
* **Unit Scenario: UTS-029-B5** (invalid partition: `level` = null/unknown)
  * **Arrange**: Set `level` to `null` or an undefined value
  * **Act**: Call `assemble_progressive_matrix` with invalid `level`
  * **Assert**: Raises validation error or returns default; invalid partition rejected

---

### Module: MOD-030 (Parse Matrix C Data — Bash)

**Parent Architecture Modules**: ARCH-018
**Target Source File(s)**: `scripts/bash/build-matrix.sh`

#### Test Case: UTP-030-A (Branch paths through parse_matrix_c_data_bash)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `parse_matrix_c_data_bash`. Branches: arch_design_path missing → exit 1, integration_test_path missing → exit 1, CROSS-CUTTING line → special mapping, normal ARCH→SYS mapping, ITP/ITS extraction, coverage calculation, total_arch 0 guard.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-018 Interface View | Stub: returns true/false | Isolate file system |
| read_lines | ARCH-018 Interface View | Stub: returns predefined line arrays | Provide controlled input |
| write_stdout | ARCH-018 Interface View | Spy: captures output strings | Verify output format |
| write_stderr | ARCH-018 Interface View | Spy: captures error strings | Verify error messages |

* **Unit Scenario: UTS-030-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `parse_matrix_c_data_bash`
  * **Act**: Call `parse_matrix_c_data_bash(arch_design_path, integration_test_path)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-030-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (integration_test_path missing → exit 1)
  * **Act**: Call `parse_matrix_c_data_bash` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-030-A3** (error-path: MALFORMED_INPUT exit 1)
  * **Arrange**: Set up input that triggers error condition: Input file not found
  * **Act**: Call `parse_matrix_c_data_bash` with error-triggering input
  * **Assert**: Raises `MALFORMED_INPUT exit 1`; no partial output produced

#### Test Case: UTP-030-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `coverage_pct` (0..100).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-018 Interface View | Stub: returns true/false | Isolate file system |
| read_lines | ARCH-018 Interface View | Stub: returns predefined line arrays | Provide controlled input |
| write_stdout | ARCH-018 Interface View | Spy: captures output strings | Verify output format |
| write_stderr | ARCH-018 Interface View | Spy: captures error strings | Verify error messages |

* **Unit Scenario: UTS-030-B1** (min-1: `coverage_pct` = -1)
  * **Arrange**: Configure input so `coverage_pct` evaluates to -1
  * **Act**: Call `parse_matrix_c_data_bash` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `coverage_pct` below valid range
* **Unit Scenario: UTS-030-B2** (min: `coverage_pct` = 0)
  * **Arrange**: Configure input so `coverage_pct` evaluates to 0
  * **Act**: Call `parse_matrix_c_data_bash` with minimum valid input
  * **Assert**: Accepted — returns valid output with `coverage_pct` = 0
* **Unit Scenario: UTS-030-B3** (mid: `coverage_pct` = 50)
  * **Arrange**: Configure input so `coverage_pct` evaluates to 50
  * **Act**: Call `parse_matrix_c_data_bash` with nominal input
  * **Assert**: Accepted — returns valid output with `coverage_pct` = 50
* **Unit Scenario: UTS-030-B4** (max: `coverage_pct` = 100)
  * **Arrange**: Configure input so `coverage_pct` evaluates to 100
  * **Act**: Call `parse_matrix_c_data_bash` with maximum valid input
  * **Assert**: Accepted — returns valid output with `coverage_pct` = 100
* **Unit Scenario: UTS-030-B5** (max+1: `coverage_pct` = 101)
  * **Arrange**: Configure input so `coverage_pct` evaluates to 101
  * **Act**: Call `parse_matrix_c_data_bash` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `coverage_pct` exceeds valid range

#### Test Case: UTP-030-C (Equivalence partitions for discrete types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition discrete non-scalar variables: `in_logical` (Boolean: true/false).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-018 Interface View | Stub: returns true/false | Isolate file system |
| read_lines | ARCH-018 Interface View | Stub: returns predefined line arrays | Provide controlled input |
| write_stdout | ARCH-018 Interface View | Spy: captures output strings | Verify output format |
| write_stderr | ARCH-018 Interface View | Spy: captures error strings | Verify error messages |

* **Unit Scenario: UTS-030-C1** (valid partition: `in_logical` = true)
  * **Arrange**: Set `in_logical` to `true`
  * **Act**: Call `parse_matrix_c_data_bash` with `in_logical` = true
  * **Assert**: True-path logic executes; output reflects `in_logical` = true behavior
* **Unit Scenario: UTS-030-C2** (valid partition: `in_logical` = false)
  * **Arrange**: Set `in_logical` to `false`
  * **Act**: Call `parse_matrix_c_data_bash` with `in_logical` = false
  * **Assert**: False-path logic executes; output reflects `in_logical` = false behavior

#### Test Case: UTP-030-D (Strict isolation of external dependencies)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verify `parse_matrix_c_data_bash` operates correctly with all external dependencies mocked: file_exists, read_lines, write_stdout, write_stderr.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-018 Interface View | Stub: returns true/false | Isolate file system |
| read_lines | ARCH-018 Interface View | Stub: returns predefined line arrays | Provide controlled input |
| write_stdout | ARCH-018 Interface View | Spy: captures output strings | Verify output format |
| write_stderr | ARCH-018 Interface View | Spy: captures error strings | Verify error messages |

* **Unit Scenario: UTS-030-D1** (all mocks return nominal values)
  * **Arrange**: Configure all mocks (file_exists, read_lines, write_stdout, write_stderr) to return valid nominal responses
  * **Act**: Call `parse_matrix_c_data_bash` with mocked dependencies
  * **Assert**: Returns expected output; no real external calls made; mock call counts verified
* **Unit Scenario: UTS-030-D2** (mock `file_exists` returns failure)
  * **Arrange**: Configure `file_exists` mock to return error/false; other mocks return nominal
  * **Act**: Call `parse_matrix_c_data_bash` with failing primary dependency
  * **Assert**: Error propagated correctly; no side effects from other mocked dependencies
* **Unit Scenario: UTS-030-D3** (verify zero real I/O calls)
  * **Arrange**: Configure all mocks with call-tracking spies
  * **Act**: Call `parse_matrix_c_data_bash` in fully mocked context
  * **Assert**: All external interactions routed through mocks; spy logs confirm zero real file/network/subprocess calls

---

### Module: MOD-031 (Parse Matrix C Data — PowerShell)

**Parent Architecture Modules**: ARCH-019
**Target Source File(s)**: `scripts/powershell/build-matrix.ps1`

#### Test Case: UTP-031-A (Branch paths through Parse-MatrixCData)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `Parse-MatrixCData`. Branches: ArchDesignPath missing → exit 1, IntegrationTestPath missing → exit 1, CROSS-CUTTING line → special mapping, normal ARCH→SYS mapping, ITP/ITS extraction, coverage calculation.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Test-Path | ARCH-019 Interface View | Stub: returns $true/$false | Isolate file system |
| Get-Content | ARCH-019 Interface View | Stub: returns predefined content | Provide controlled input |
| Write-Output | ARCH-019 Interface View | Spy: captures output strings | Verify output format |
| Write-Error | ARCH-019 Interface View | Spy: captures error strings | Verify error messages |

* **Unit Scenario: UTS-031-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `Parse-MatrixCData`
  * **Act**: Call `Parse-MatrixCData(ArchDesignPath, IntegrationTestPath)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-031-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (IntegrationTestPath missing → exit 1)
  * **Act**: Call `Parse-MatrixCData` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-031-A3** (error-path: MALFORMED_INPUT exit 1)
  * **Arrange**: Set up input that triggers error condition: Input file not found
  * **Act**: Call `Parse-MatrixCData` with error-triggering input
  * **Assert**: Raises `MALFORMED_INPUT exit 1`; no partial output produced

#### Test Case: UTP-031-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `CoveragePct` (0..100).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Test-Path | ARCH-019 Interface View | Stub: returns $true/$false | Isolate file system |
| Get-Content | ARCH-019 Interface View | Stub: returns predefined content | Provide controlled input |
| Write-Output | ARCH-019 Interface View | Spy: captures output strings | Verify output format |
| Write-Error | ARCH-019 Interface View | Spy: captures error strings | Verify error messages |

* **Unit Scenario: UTS-031-B1** (min-1: `CoveragePct` = -1)
  * **Arrange**: Configure input so `CoveragePct` evaluates to -1
  * **Act**: Call `Parse-MatrixCData` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `CoveragePct` below valid range
* **Unit Scenario: UTS-031-B2** (min: `CoveragePct` = 0)
  * **Arrange**: Configure input so `CoveragePct` evaluates to 0
  * **Act**: Call `Parse-MatrixCData` with minimum valid input
  * **Assert**: Accepted — returns valid output with `CoveragePct` = 0
* **Unit Scenario: UTS-031-B3** (mid: `CoveragePct` = 50)
  * **Arrange**: Configure input so `CoveragePct` evaluates to 50
  * **Act**: Call `Parse-MatrixCData` with nominal input
  * **Assert**: Accepted — returns valid output with `CoveragePct` = 50
* **Unit Scenario: UTS-031-B4** (max: `CoveragePct` = 100)
  * **Arrange**: Configure input so `CoveragePct` evaluates to 100
  * **Act**: Call `Parse-MatrixCData` with maximum valid input
  * **Assert**: Accepted — returns valid output with `CoveragePct` = 100
* **Unit Scenario: UTS-031-B5** (max+1: `CoveragePct` = 101)
  * **Arrange**: Configure input so `CoveragePct` evaluates to 101
  * **Act**: Call `Parse-MatrixCData` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `CoveragePct` exceeds valid range

#### Test Case: UTP-031-C (Equivalence partitions for discrete types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition discrete non-scalar variables: `InLogical` (Boolean: true/false).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Test-Path | ARCH-019 Interface View | Stub: returns $true/$false | Isolate file system |
| Get-Content | ARCH-019 Interface View | Stub: returns predefined content | Provide controlled input |
| Write-Output | ARCH-019 Interface View | Spy: captures output strings | Verify output format |
| Write-Error | ARCH-019 Interface View | Spy: captures error strings | Verify error messages |

* **Unit Scenario: UTS-031-C1** (valid partition: `InLogical` = true)
  * **Arrange**: Set `InLogical` to `true`
  * **Act**: Call `Parse-MatrixCData` with `InLogical` = true
  * **Assert**: True-path logic executes; output reflects `InLogical` = true behavior
* **Unit Scenario: UTS-031-C2** (valid partition: `InLogical` = false)
  * **Arrange**: Set `InLogical` to `false`
  * **Act**: Call `Parse-MatrixCData` with `InLogical` = false
  * **Assert**: False-path logic executes; output reflects `InLogical` = false behavior

#### Test Case: UTP-031-D (Strict isolation of external dependencies)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verify `Parse-MatrixCData` operates correctly with all external dependencies mocked: Test-Path, Get-Content, Write-Output, Write-Error.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Test-Path | ARCH-019 Interface View | Stub: returns $true/$false | Isolate file system |
| Get-Content | ARCH-019 Interface View | Stub: returns predefined content | Provide controlled input |
| Write-Output | ARCH-019 Interface View | Spy: captures output strings | Verify output format |
| Write-Error | ARCH-019 Interface View | Spy: captures error strings | Verify error messages |

* **Unit Scenario: UTS-031-D1** (all mocks return nominal values)
  * **Arrange**: Configure all mocks (Test-Path, Get-Content, Write-Output, Write-Error) to return valid nominal responses
  * **Act**: Call `Parse-MatrixCData` with mocked dependencies
  * **Assert**: Returns expected output; no real external calls made; mock call counts verified
* **Unit Scenario: UTS-031-D2** (mock `Test-Path` returns failure)
  * **Arrange**: Configure `Test-Path` mock to return error/false; other mocks return nominal
  * **Act**: Call `Parse-MatrixCData` with failing primary dependency
  * **Assert**: Error propagated correctly; no side effects from other mocked dependencies
* **Unit Scenario: UTS-031-D3** (verify zero real I/O calls)
  * **Arrange**: Configure all mocks with call-tracking spies
  * **Act**: Call `Parse-MatrixCData` in fully mocked context
  * **Assert**: All external interactions routed through mocks; spy logs confirm zero real file/network/subprocess calls

---

### Module: MOD-032 (Check System Design Prerequisite)

**Parent Architecture Modules**: ARCH-020
**Target Source File(s)**: `scripts/bash/setup-v-model.sh, scripts/powershell/setup-v-model.ps1`

#### Test Case: UTP-032-A (Branch paths through check_system_design_prerequisite)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `check_system_design_prerequisite`. Branches: flag false → return true immediately, file missing → PREREQUISITE_MISSING, file empty → PREREQUISITE_MISSING, file exists and non-empty → return true.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-020 Interface View | Stub: returns true/false | Isolate file system |
| file_size | ARCH-020 Interface View | Stub: returns predefined size | Control empty file detection |
| write_stderr | ARCH-020 Interface View | Spy: captures error strings | Verify error messages |

* **Unit Scenario: UTS-032-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `check_system_design_prerequisite`
  * **Act**: Call `check_system_design_prerequisite(vmodel_dir, require_system_design_flag)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-032-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (file missing → PREREQUISITE_MISSING)
  * **Act**: Call `check_system_design_prerequisite` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-032-A3** (error-path: PREREQUISITE_MISSING)
  * **Arrange**: Set up input that triggers error condition: system-design.md missing, flag set
  * **Act**: Call `check_system_design_prerequisite` with error-triggering input
  * **Assert**: Raises `PREREQUISITE_MISSING`; no partial output produced

#### Test Case: UTP-032-B (Equivalence partitions for discrete types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition discrete non-scalar variables: `require_system_design_flag` (Boolean: true/false).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-020 Interface View | Stub: returns true/false | Isolate file system |
| file_size | ARCH-020 Interface View | Stub: returns predefined size | Control empty file detection |
| write_stderr | ARCH-020 Interface View | Spy: captures error strings | Verify error messages |

* **Unit Scenario: UTS-032-B1** (valid partition: `require_system_design_flag` = true)
  * **Arrange**: Set `require_system_design_flag` to `true`
  * **Act**: Call `check_system_design_prerequisite` with `require_system_design_flag` = true
  * **Assert**: True-path logic executes; output reflects `require_system_design_flag` = true behavior
* **Unit Scenario: UTS-032-B2** (valid partition: `require_system_design_flag` = false)
  * **Arrange**: Set `require_system_design_flag` to `false`
  * **Act**: Call `check_system_design_prerequisite` with `require_system_design_flag` = false
  * **Assert**: False-path logic executes; output reflects `require_system_design_flag` = false behavior

#### Test Case: UTP-032-C (Strict isolation of external dependencies)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verify `check_system_design_prerequisite` operates correctly with all external dependencies mocked: file_exists, file_size, write_stderr.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-020 Interface View | Stub: returns true/false | Isolate file system |
| file_size | ARCH-020 Interface View | Stub: returns predefined size | Control empty file detection |
| write_stderr | ARCH-020 Interface View | Spy: captures error strings | Verify error messages |

* **Unit Scenario: UTS-032-C1** (all mocks return nominal values)
  * **Arrange**: Configure all mocks (file_exists, file_size, write_stderr) to return valid nominal responses
  * **Act**: Call `check_system_design_prerequisite` with mocked dependencies
  * **Assert**: Returns expected output; no real external calls made; mock call counts verified
* **Unit Scenario: UTS-032-C2** (mock `file_exists` returns failure)
  * **Arrange**: Configure `file_exists` mock to return error/false; other mocks return nominal
  * **Act**: Call `check_system_design_prerequisite` with failing primary dependency
  * **Assert**: Error propagated correctly; no side effects from other mocked dependencies
* **Unit Scenario: UTS-032-C3** (verify zero real I/O calls)
  * **Arrange**: Configure all mocks with call-tracking spies
  * **Act**: Call `check_system_design_prerequisite` in fully mocked context
  * **Assert**: All external interactions routed through mocks; spy logs confirm zero real file/network/subprocess calls

---

### Module: MOD-033 (Detect Extended Documents)

**Parent Architecture Modules**: ARCH-021
**Target Source File(s)**: `scripts/bash/setup-v-model.sh, scripts/powershell/setup-v-model.ps1`

#### Test Case: UTP-033-A (Branch paths through detect_extended_documents)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `detect_extended_documents`. Branches: iterate known_documents, file_exists true → append, file_exists false → skip, vmodel_dir nonexistent → empty return.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-021 Interface View | Stub: returns true/false per document | Isolate file system checks |

* **Unit Scenario: UTS-033-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `detect_extended_documents`
  * **Act**: Call `detect_extended_documents(vmodel_dir)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-033-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (file_exists true → append)
  * **Act**: Call `detect_extended_documents` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-033-A3** (loop-zero: empty input collection)
  * **Arrange**: Provide empty collection as input to `detect_extended_documents`
  * **Act**: Call `detect_extended_documents` with empty input
  * **Assert**: Returns empty result; loop body never executed

#### Test Case: UTP-033-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `available.length` (0..10).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-021 Interface View | Stub: returns true/false per document | Isolate file system checks |

* **Unit Scenario: UTS-033-B1** (min-1: `available.length` = -1)
  * **Arrange**: Configure input so `available.length` evaluates to -1
  * **Act**: Call `detect_extended_documents` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `available.length` below valid range
* **Unit Scenario: UTS-033-B2** (min: `available.length` = 0)
  * **Arrange**: Configure input so `available.length` evaluates to 0
  * **Act**: Call `detect_extended_documents` with minimum valid input
  * **Assert**: Accepted — returns valid output with `available.length` = 0
* **Unit Scenario: UTS-033-B3** (mid: `available.length` = 5)
  * **Arrange**: Configure input so `available.length` evaluates to 5
  * **Act**: Call `detect_extended_documents` with nominal input
  * **Assert**: Accepted — returns valid output with `available.length` = 5
* **Unit Scenario: UTS-033-B4** (max: `available.length` = 10)
  * **Arrange**: Configure input so `available.length` evaluates to 10
  * **Act**: Call `detect_extended_documents` with maximum valid input
  * **Assert**: Accepted — returns valid output with `available.length` = 10
* **Unit Scenario: UTS-033-B5** (max+1: `available.length` = 11)
  * **Arrange**: Configure input so `available.length` evaluates to 11
  * **Act**: Call `detect_extended_documents` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `available.length` exceeds valid range

#### Test Case: UTP-033-C (Strict isolation of external dependencies)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verify `detect_extended_documents` operates correctly with all external dependencies mocked: file_exists.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-021 Interface View | Stub: returns true/false per document | Isolate file system checks |

* **Unit Scenario: UTS-033-C1** (all mocks return nominal values)
  * **Arrange**: Configure all mocks (file_exists) to return valid nominal responses
  * **Act**: Call `detect_extended_documents` with mocked dependencies
  * **Assert**: Returns expected output; no real external calls made; mock call counts verified
* **Unit Scenario: UTS-033-C2** (mock `file_exists` returns failure)
  * **Arrange**: Configure `file_exists` mock to return error/false; other mocks return nominal
  * **Act**: Call `detect_extended_documents` with failing primary dependency
  * **Assert**: Error propagated correctly; no side effects from other mocked dependencies
* **Unit Scenario: UTS-033-C3** (verify zero real I/O calls)
  * **Arrange**: Configure all mocks with call-tracking spies
  * **Act**: Call `detect_extended_documents` in fully mocked context
  * **Assert**: All external interactions routed through mocks; spy logs confirm zero real file/network/subprocess calls

---

### Module: MOD-034 (Update Extension Manifest)

**Parent Architecture Modules**: ARCH-022
**Target Source File(s)**: `extension.yml`

#### Test Case: UTP-034-A (Branch paths through update_extension_manifest)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `update_extension_manifest`. Branches: file missing → FILE_NOT_FOUND, command NOT IN existing → append, command already IN → skip, hook NOT IN → append, version update.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-022 Interface View | Stub: returns true/false | Isolate file system |
| read_file | ARCH-022 Interface View | Stub: returns predefined YAML content | Provide controlled manifest data |
| write_file | ARCH-022 Interface View | Spy: captures written content | Verify output correctness |
| parse_yaml | ARCH-022 Interface View | Stub: returns predefined object | Isolate YAML parsing |

* **Unit Scenario: UTS-034-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `update_extension_manifest`
  * **Act**: Call `update_extension_manifest(extension_yml_path)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-034-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (command NOT IN existing → append)
  * **Act**: Call `update_extension_manifest` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-034-A3** (error-path: FILE_NOT_FOUND)
  * **Arrange**: Set up input that triggers error condition: extension.yml missing
  * **Act**: Call `update_extension_manifest` with error-triggering input
  * **Assert**: Raises `FILE_NOT_FOUND`; no partial output produced

#### Test Case: UTP-034-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `existing_commands.length` (5..10).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-022 Interface View | Stub: returns true/false | Isolate file system |
| read_file | ARCH-022 Interface View | Stub: returns predefined YAML content | Provide controlled manifest data |
| write_file | ARCH-022 Interface View | Spy: captures written content | Verify output correctness |
| parse_yaml | ARCH-022 Interface View | Stub: returns predefined object | Isolate YAML parsing |

* **Unit Scenario: UTS-034-B1** (min-1: `existing_commands.length` = 4)
  * **Arrange**: Configure input so `existing_commands.length` evaluates to 4
  * **Act**: Call `update_extension_manifest` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `existing_commands.length` below valid range
* **Unit Scenario: UTS-034-B2** (min: `existing_commands.length` = 5)
  * **Arrange**: Configure input so `existing_commands.length` evaluates to 5
  * **Act**: Call `update_extension_manifest` with minimum valid input
  * **Assert**: Accepted — returns valid output with `existing_commands.length` = 5
* **Unit Scenario: UTS-034-B3** (mid: `existing_commands.length` = 7)
  * **Arrange**: Configure input so `existing_commands.length` evaluates to 7
  * **Act**: Call `update_extension_manifest` with nominal input
  * **Assert**: Accepted — returns valid output with `existing_commands.length` = 7
* **Unit Scenario: UTS-034-B4** (max: `existing_commands.length` = 10)
  * **Arrange**: Configure input so `existing_commands.length` evaluates to 10
  * **Act**: Call `update_extension_manifest` with maximum valid input
  * **Assert**: Accepted — returns valid output with `existing_commands.length` = 10
* **Unit Scenario: UTS-034-B5** (max+1: `existing_commands.length` = 11)
  * **Arrange**: Configure input so `existing_commands.length` evaluates to 11
  * **Act**: Call `update_extension_manifest` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `existing_commands.length` exceeds valid range

#### Test Case: UTP-034-C (Strict isolation of external dependencies)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verify `update_extension_manifest` operates correctly with all external dependencies mocked: file_exists, read_file, write_file, parse_yaml.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-022 Interface View | Stub: returns true/false | Isolate file system |
| read_file | ARCH-022 Interface View | Stub: returns predefined YAML content | Provide controlled manifest data |
| write_file | ARCH-022 Interface View | Spy: captures written content | Verify output correctness |
| parse_yaml | ARCH-022 Interface View | Stub: returns predefined object | Isolate YAML parsing |

* **Unit Scenario: UTS-034-C1** (all mocks return nominal values)
  * **Arrange**: Configure all mocks (file_exists, read_file, write_file, parse_yaml) to return valid nominal responses
  * **Act**: Call `update_extension_manifest` with mocked dependencies
  * **Assert**: Returns expected output; no real external calls made; mock call counts verified
* **Unit Scenario: UTS-034-C2** (mock `file_exists` returns failure)
  * **Arrange**: Configure `file_exists` mock to return error/false; other mocks return nominal
  * **Act**: Call `update_extension_manifest` with failing primary dependency
  * **Assert**: Error propagated correctly; no side effects from other mocked dependencies
* **Unit Scenario: UTS-034-C3** (verify zero real I/O calls)
  * **Arrange**: Configure all mocks with call-tracking spies
  * **Act**: Call `update_extension_manifest` in fully mocked context
  * **Assert**: All external interactions routed through mocks; spy logs confirm zero real file/network/subprocess calls

---

### Module: MOD-035 (Update Catalog Entry)

**Parent Architecture Modules**: ARCH-022
**Target Source File(s)**: `catalog-entry.json`

#### Test Case: UTP-035-A (Branch paths through update_catalog_entry)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `update_catalog_entry`. Branches: file missing → FILE_NOT_FOUND, capabilities NULL → initialize, commands NULL → initialize, entry NOT IN → append, entry already IN → skip, version update.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-022 Interface View | Stub: returns true/false | Isolate file system |
| read_file | ARCH-022 Interface View | Stub: returns predefined JSON content | Provide controlled catalog data |
| write_file | ARCH-022 Interface View | Spy: captures written content | Verify output correctness |
| parse_json | ARCH-022 Interface View | Stub: returns predefined object | Isolate JSON parsing |

* **Unit Scenario: UTS-035-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `update_catalog_entry`
  * **Act**: Call `update_catalog_entry(catalog_entry_path)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-035-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (capabilities NULL → initialize)
  * **Act**: Call `update_catalog_entry` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-035-A3** (error-path: FILE_NOT_FOUND)
  * **Arrange**: Set up input that triggers error condition: catalog-entry.json missing
  * **Act**: Call `update_catalog_entry` with error-triggering input
  * **Assert**: Raises `FILE_NOT_FOUND`; no partial output produced

#### Test Case: UTP-035-B (Strict isolation of external dependencies)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verify `update_catalog_entry` operates correctly with all external dependencies mocked: file_exists, read_file, write_file, parse_json.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-022 Interface View | Stub: returns true/false | Isolate file system |
| read_file | ARCH-022 Interface View | Stub: returns predefined JSON content | Provide controlled catalog data |
| write_file | ARCH-022 Interface View | Spy: captures written content | Verify output correctness |
| parse_json | ARCH-022 Interface View | Stub: returns predefined object | Isolate JSON parsing |

* **Unit Scenario: UTS-035-B1** (all mocks return nominal values)
  * **Arrange**: Configure all mocks (file_exists, read_file, write_file, parse_json) to return valid nominal responses
  * **Act**: Call `update_catalog_entry` with mocked dependencies
  * **Assert**: Returns expected output; no real external calls made; mock call counts verified
* **Unit Scenario: UTS-035-B2** (mock `file_exists` returns failure)
  * **Arrange**: Configure `file_exists` mock to return error/false; other mocks return nominal
  * **Act**: Call `update_catalog_entry` with failing primary dependency
  * **Assert**: Error propagated correctly; no side effects from other mocked dependencies
* **Unit Scenario: UTS-035-B3** (verify zero real I/O calls)
  * **Arrange**: Configure all mocks with call-tracking spies
  * **Act**: Call `update_catalog_entry` in fully mocked context
  * **Assert**: All external interactions routed through mocks; spy logs confirm zero real file/network/subprocess calls

---

### Module: MOD-036 (Evaluate Architecture Output)

**Parent Architecture Modules**: ARCH-023
**Target Source File(s)**: `tests/evals/test_architecture_design_eval.py`

#### Test Case: UTP-036-A (Branch paths through evaluate_architecture_output)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `evaluate_architecture_output`. Branches: all_views_present → structural 1.0, missing views → partial score, arch_count 0 → coverage 0.0, non-empty parent fields ratio, completeness checks (mermaid/contracts/data_flow), overall_pass threshold comparison.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-036-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `evaluate_architecture_output`
  * **Act**: Call `evaluate_architecture_output(arch_design_content, quality_thresholds)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-036-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (missing views → partial score)
  * **Act**: Call `evaluate_architecture_output` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-036-A3** (error-path: STRUCTURAL_FAILURE)
  * **Arrange**: Set up input that triggers error condition: Mandatory views absent
  * **Act**: Call `evaluate_architecture_output` with error-triggering input
  * **Assert**: Raises `STRUCTURAL_FAILURE`; no partial output produced

#### Test Case: UTP-036-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `scores.structural` (0.0..1.0), `scores.coverage` (0.0..1.0), `scores.completeness` (0.0..1.0).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-036-B1** (min-1: `scores.structural` = -1.0)
  * **Arrange**: Configure input so `scores.structural` evaluates to -1.0
  * **Act**: Call `evaluate_architecture_output` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `scores.structural` below valid range
* **Unit Scenario: UTS-036-B2** (min: `scores.structural` = 0.0)
  * **Arrange**: Configure input so `scores.structural` evaluates to 0.0
  * **Act**: Call `evaluate_architecture_output` with minimum valid input
  * **Assert**: Accepted — returns valid output with `scores.structural` = 0.0
* **Unit Scenario: UTS-036-B3** (mid: `scores.structural` = 0.0)
  * **Arrange**: Configure input so `scores.structural` evaluates to 0.0
  * **Act**: Call `evaluate_architecture_output` with nominal input
  * **Assert**: Accepted — returns valid output with `scores.structural` = 0.0
* **Unit Scenario: UTS-036-B4** (max: `scores.structural` = 1.0)
  * **Arrange**: Configure input so `scores.structural` evaluates to 1.0
  * **Act**: Call `evaluate_architecture_output` with maximum valid input
  * **Assert**: Accepted — returns valid output with `scores.structural` = 1.0
* **Unit Scenario: UTS-036-B5** (max+1: `scores.structural` = 2.0)
  * **Arrange**: Configure input so `scores.structural` evaluates to 2.0
  * **Act**: Call `evaluate_architecture_output` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `scores.structural` exceeds valid range

#### Test Case: UTP-036-C (Equivalence partitions for discrete types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition discrete non-scalar variables: `overall_pass` (Boolean: true/false).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-036-C1** (valid partition: `overall_pass` = true)
  * **Arrange**: Set `overall_pass` to `true`
  * **Act**: Call `evaluate_architecture_output` with `overall_pass` = true
  * **Assert**: True-path logic executes; output reflects `overall_pass` = true behavior
* **Unit Scenario: UTS-036-C2** (valid partition: `overall_pass` = false)
  * **Arrange**: Set `overall_pass` to `false`
  * **Act**: Call `evaluate_architecture_output` with `overall_pass` = false
  * **Assert**: False-path logic executes; output reflects `overall_pass` = false behavior

---

### Module: MOD-037 (Verify Structural Compliance)

**Parent Architecture Modules**: ARCH-023
**Target Source File(s)**: `tests/evals/test_architecture_design_eval.py`

#### Test Case: UTP-037-A (Branch paths through verify_structural_compliance)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `verify_structural_compliance`. Branches: each of 4 mandatory views: pattern matches → present, not matches → missing, all present → all_views_present true, any missing → false.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-037-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `verify_structural_compliance`
  * **Act**: Call `verify_structural_compliance(arch_design_content)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-037-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (not matches → missing)
  * **Act**: Call `verify_structural_compliance` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries

#### Test Case: UTP-037-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `present_count` (0..4).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-037-B1** (min-1: `present_count` = -1)
  * **Arrange**: Configure input so `present_count` evaluates to -1
  * **Act**: Call `verify_structural_compliance` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `present_count` below valid range
* **Unit Scenario: UTS-037-B2** (min: `present_count` = 0)
  * **Arrange**: Configure input so `present_count` evaluates to 0
  * **Act**: Call `verify_structural_compliance` with minimum valid input
  * **Assert**: Accepted — returns valid output with `present_count` = 0
* **Unit Scenario: UTS-037-B3** (mid: `present_count` = 2)
  * **Arrange**: Configure input so `present_count` evaluates to 2
  * **Act**: Call `verify_structural_compliance` with nominal input
  * **Assert**: Accepted — returns valid output with `present_count` = 2
* **Unit Scenario: UTS-037-B4** (max: `present_count` = 4)
  * **Arrange**: Configure input so `present_count` evaluates to 4
  * **Act**: Call `verify_structural_compliance` with maximum valid input
  * **Assert**: Accepted — returns valid output with `present_count` = 4
* **Unit Scenario: UTS-037-B5** (max+1: `present_count` = 5)
  * **Arrange**: Configure input so `present_count` evaluates to 5
  * **Act**: Call `verify_structural_compliance` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `present_count` exceeds valid range

#### Test Case: UTP-037-C (Equivalence partitions for discrete types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition discrete non-scalar variables: `all_views_present` (Boolean: true/false).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-037-C1** (valid partition: `all_views_present` = true)
  * **Arrange**: Set `all_views_present` to `true`
  * **Act**: Call `verify_structural_compliance` with `all_views_present` = true
  * **Assert**: True-path logic executes; output reflects `all_views_present` = true behavior
* **Unit Scenario: UTS-037-C2** (valid partition: `all_views_present` = false)
  * **Arrange**: Set `all_views_present` to `false`
  * **Act**: Call `verify_structural_compliance` with `all_views_present` = false
  * **Assert**: False-path logic executes; output reflects `all_views_present` = false behavior

---

### Module: MOD-038 (Evaluate Integration Test Output)

**Parent Architecture Modules**: ARCH-024
**Target Source File(s)**: `tests/evals/test_integration_test_eval.py`

#### Test Case: UTP-038-A (Branch paths through evaluate_integration_test_output)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `evaluate_integration_test_output`. Branches: hierarchy_result.valid → structural 1.0, partial → reduced score, harness/mocking checks, 4 technique presence checks, BDD keywords check, overall_pass threshold comparison.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-038-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `evaluate_integration_test_output`
  * **Act**: Call `evaluate_integration_test_output(integration_test_content, quality_thresholds)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-038-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (partial → reduced score)
  * **Act**: Call `evaluate_integration_test_output` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-038-A3** (error-path: STRUCTURAL_FAILURE)
  * **Arrange**: Set up input that triggers error condition: ITP/ITS hierarchy malformed
  * **Act**: Call `evaluate_integration_test_output` with error-triggering input
  * **Assert**: Raises `STRUCTURAL_FAILURE`; no partial output produced

#### Test Case: UTP-038-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `scores.structural` (0.0..1.0), `scores.technique` (0.0..1.0), `technique_count` (0..4).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-038-B1** (min-1: `scores.structural` = -1.0)
  * **Arrange**: Configure input so `scores.structural` evaluates to -1.0
  * **Act**: Call `evaluate_integration_test_output` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `scores.structural` below valid range
* **Unit Scenario: UTS-038-B2** (min: `scores.structural` = 0.0)
  * **Arrange**: Configure input so `scores.structural` evaluates to 0.0
  * **Act**: Call `evaluate_integration_test_output` with minimum valid input
  * **Assert**: Accepted — returns valid output with `scores.structural` = 0.0
* **Unit Scenario: UTS-038-B3** (mid: `scores.structural` = 0.0)
  * **Arrange**: Configure input so `scores.structural` evaluates to 0.0
  * **Act**: Call `evaluate_integration_test_output` with nominal input
  * **Assert**: Accepted — returns valid output with `scores.structural` = 0.0
* **Unit Scenario: UTS-038-B4** (max: `scores.structural` = 1.0)
  * **Arrange**: Configure input so `scores.structural` evaluates to 1.0
  * **Act**: Call `evaluate_integration_test_output` with maximum valid input
  * **Assert**: Accepted — returns valid output with `scores.structural` = 1.0
* **Unit Scenario: UTS-038-B5** (max+1: `scores.structural` = 2.0)
  * **Arrange**: Configure input so `scores.structural` evaluates to 2.0
  * **Act**: Call `evaluate_integration_test_output` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `scores.structural` exceeds valid range

#### Test Case: UTP-038-C (Equivalence partitions for discrete types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition discrete non-scalar variables: `has_harness` (Boolean: true/false); `has_mocking` (Boolean: true/false).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-038-C1** (valid partition: `has_harness` = true)
  * **Arrange**: Set `has_harness` to `true`
  * **Act**: Call `evaluate_integration_test_output` with `has_harness` = true
  * **Assert**: True-path logic executes; output reflects `has_harness` = true behavior
* **Unit Scenario: UTS-038-C2** (valid partition: `has_harness` = false)
  * **Arrange**: Set `has_harness` to `false`
  * **Act**: Call `evaluate_integration_test_output` with `has_harness` = false
  * **Assert**: False-path logic executes; output reflects `has_harness` = false behavior
* **Unit Scenario: UTS-038-C3** (valid partition: `has_mocking` = true)
  * **Arrange**: Set `has_mocking` to `true`
  * **Act**: Call `evaluate_integration_test_output` with `has_mocking` = true
  * **Assert**: True-path logic executes; output reflects `has_mocking` = true behavior
* **Unit Scenario: UTS-038-C4** (valid partition: `has_mocking` = false)
  * **Arrange**: Set `has_mocking` to `false`
  * **Act**: Call `evaluate_integration_test_output` with `has_mocking` = false
  * **Assert**: False-path logic executes; output reflects `has_mocking` = false behavior

---

### Module: MOD-039 (Verify ITP/ITS Hierarchy)

**Parent Architecture Modules**: ARCH-024
**Target Source File(s)**: `tests/evals/test_integration_test_eval.py`

#### Test Case: UTP-039-A (Branch paths through verify_itp_its_hierarchy)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `verify_itp_its_hierarchy`. Branches: empty itp_ids → issue, empty its_ids → issue, orphaned ITS → issue, ITP without ITS → issue, missing technique assignment → issue, score clamped at 0.0.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-039-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `verify_itp_its_hierarchy`
  * **Act**: Call `verify_itp_its_hierarchy(integration_test_content)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-039-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (empty its_ids → issue)
  * **Act**: Call `verify_itp_its_hierarchy` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries

#### Test Case: UTP-039-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `itp_ids.length` (0..500), `its_ids.length` (0..1000), `score` (0.0..1.0).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-039-B1** (min-1: `itp_ids.length` = -1)
  * **Arrange**: Configure input so `itp_ids.length` evaluates to -1
  * **Act**: Call `verify_itp_its_hierarchy` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `itp_ids.length` below valid range
* **Unit Scenario: UTS-039-B2** (min: `itp_ids.length` = 0)
  * **Arrange**: Configure input so `itp_ids.length` evaluates to 0
  * **Act**: Call `verify_itp_its_hierarchy` with minimum valid input
  * **Assert**: Accepted — returns valid output with `itp_ids.length` = 0
* **Unit Scenario: UTS-039-B3** (mid: `itp_ids.length` = 250)
  * **Arrange**: Configure input so `itp_ids.length` evaluates to 250
  * **Act**: Call `verify_itp_its_hierarchy` with nominal input
  * **Assert**: Accepted — returns valid output with `itp_ids.length` = 250
* **Unit Scenario: UTS-039-B4** (max: `itp_ids.length` = 500)
  * **Arrange**: Configure input so `itp_ids.length` evaluates to 500
  * **Act**: Call `verify_itp_its_hierarchy` with maximum valid input
  * **Assert**: Accepted — returns valid output with `itp_ids.length` = 500
* **Unit Scenario: UTS-039-B5** (max+1: `itp_ids.length` = 501)
  * **Arrange**: Configure input so `itp_ids.length` evaluates to 501
  * **Act**: Call `verify_itp_its_hierarchy` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `itp_ids.length` exceeds valid range

---

### Module: MOD-040 (Validate Mermaid Blocks)

**Parent Architecture Modules**: ARCH-025
**Target Source File(s)**: `tests/evals/test_architecture_design_eval.py`

#### Test Case: UTP-040-A (Branch paths through validate_mermaid_blocks)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `validate_mermaid_blocks`. Branches: block not starting with sequenceDiagram → error, participant parsing, message line source/target validation, Note over → skip, alt/else/end → skip, unrecognized syntax → error, empty blocks array → empty results.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-040-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `validate_mermaid_blocks`
  * **Act**: Call `validate_mermaid_blocks(mermaid_blocks)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-040-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (participant parsing)
  * **Act**: Call `validate_mermaid_blocks` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-040-A3** (error-path: SYNTAX_FAILURE)
  * **Arrange**: Set up input that triggers error condition: Block with syntax errors
  * **Act**: Call `validate_mermaid_blocks` with error-triggering input
  * **Assert**: Raises `SYNTAX_FAILURE`; no partial output produced

#### Test Case: UTP-040-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `results.length` (1..20), `errors.length` (0..50), `participants.length` (0..30).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-040-B1** (min-1: `results.length` = 0)
  * **Arrange**: Configure input so `results.length` evaluates to 0
  * **Act**: Call `validate_mermaid_blocks` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `results.length` below valid range
* **Unit Scenario: UTS-040-B2** (min: `results.length` = 1)
  * **Arrange**: Configure input so `results.length` evaluates to 1
  * **Act**: Call `validate_mermaid_blocks` with minimum valid input
  * **Assert**: Accepted — returns valid output with `results.length` = 1
* **Unit Scenario: UTS-040-B3** (mid: `results.length` = 10)
  * **Arrange**: Configure input so `results.length` evaluates to 10
  * **Act**: Call `validate_mermaid_blocks` with nominal input
  * **Assert**: Accepted — returns valid output with `results.length` = 10
* **Unit Scenario: UTS-040-B4** (max: `results.length` = 20)
  * **Arrange**: Configure input so `results.length` evaluates to 20
  * **Act**: Call `validate_mermaid_blocks` with maximum valid input
  * **Assert**: Accepted — returns valid output with `results.length` = 20
* **Unit Scenario: UTS-040-B5** (max+1: `results.length` = 21)
  * **Arrange**: Configure input so `results.length` evaluates to 21
  * **Act**: Call `validate_mermaid_blocks` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `results.length` exceeds valid range

#### Test Case: UTP-040-C (Equivalence partitions for discrete types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition discrete non-scalar variables: `in_diagram` (Boolean: true/false).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-040-C1** (valid partition: `in_diagram` = true)
  * **Arrange**: Set `in_diagram` to `true`
  * **Act**: Call `validate_mermaid_blocks` with `in_diagram` = true
  * **Assert**: True-path logic executes; output reflects `in_diagram` = true behavior
* **Unit Scenario: UTS-040-C2** (valid partition: `in_diagram` = false)
  * **Arrange**: Set `in_diagram` to `false`
  * **Act**: Call `validate_mermaid_blocks` with `in_diagram` = false
  * **Assert**: False-path logic executes; output reflects `in_diagram` = false behavior

---

### Module: MOD-041 (Discover Domain Overlay)

**Parent Architecture Modules**: ARCH-026
**Target Source File(s)**: `commands/architecture-design.md, commands/integration-test.md`

#### Test Case: UTP-041-A (Branch paths through discover_domain_overlay)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `discover_domain_overlay`. Branches: config_path missing → return NULLs, YAML parse error → emit warning return NULLs, domain NULL/empty → return NULLs, cmd overlay exists → set path, tpl overlay exists → set path, overlay not found → NULL.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-026 Interface View | Stub: returns true/false per path | Isolate file system checks |
| read_file | ARCH-026 Interface View | Stub: returns predefined YAML content | Provide controlled config data |
| parse_yaml | ARCH-026 Interface View | Stub: returns predefined config object / raises error | Isolate YAML parsing |

* **Unit Scenario: UTS-041-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `discover_domain_overlay`
  * **Act**: Call `discover_domain_overlay(config_path, command_name, repo_root)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-041-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (YAML parse error → emit warning return NULLs)
  * **Act**: Call `discover_domain_overlay` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-041-A3** (error-path: CONFIG_PARSE_ERROR)
  * **Arrange**: Set up input that triggers error condition: Config file malformed YAML
  * **Act**: Call `discover_domain_overlay` with error-triggering input
  * **Assert**: Raises `CONFIG_PARSE_ERROR`; no partial output produced

#### Test Case: UTP-041-B (Strict isolation of external dependencies)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verify `discover_domain_overlay` operates correctly with all external dependencies mocked: file_exists, read_file, parse_yaml.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists | ARCH-026 Interface View | Stub: returns true/false per path | Isolate file system checks |
| read_file | ARCH-026 Interface View | Stub: returns predefined YAML content | Provide controlled config data |
| parse_yaml | ARCH-026 Interface View | Stub: returns predefined config object / raises error | Isolate YAML parsing |

* **Unit Scenario: UTS-041-B1** (all mocks return nominal values)
  * **Arrange**: Configure all mocks (file_exists, read_file, parse_yaml) to return valid nominal responses
  * **Act**: Call `discover_domain_overlay` with mocked dependencies
  * **Assert**: Returns expected output; no real external calls made; mock call counts verified
* **Unit Scenario: UTS-041-B2** (mock `file_exists` returns failure)
  * **Arrange**: Configure `file_exists` mock to return error/false; other mocks return nominal
  * **Act**: Call `discover_domain_overlay` with failing primary dependency
  * **Assert**: Error propagated correctly; no side effects from other mocked dependencies
* **Unit Scenario: UTS-041-B3** (verify zero real I/O calls)
  * **Arrange**: Configure all mocks with call-tracking spies
  * **Act**: Call `discover_domain_overlay` in fully mocked context
  * **Assert**: All external interactions routed through mocks; spy logs confirm zero real file/network/subprocess calls

---

### Module: MOD-042 (Identify Merge Points)

**Parent Architecture Modules**: ARCH-027
**Target Source File(s)**: `commands/architecture-design.md, commands/integration-test.md`

#### Test Case: UTP-042-A (Branch paths through identify_merge_points)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `identify_merge_points`. Branches: SAFETY-CRITICAL marker match → append safety_critical, DOMAIN OVERLAY marker match → append domain_overlay, no markers → empty return.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-042-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `identify_merge_points`
  * **Act**: Call `identify_merge_points(base_template_content)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-042-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (DOMAIN OVERLAY marker match → append domain_overlay)
  * **Act**: Call `identify_merge_points` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries

#### Test Case: UTP-042-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `merge_points.length` (0..20), `line_num` (0..5000).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-042-B1** (min-1: `merge_points.length` = -1)
  * **Arrange**: Configure input so `merge_points.length` evaluates to -1
  * **Act**: Call `identify_merge_points` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `merge_points.length` below valid range
* **Unit Scenario: UTS-042-B2** (min: `merge_points.length` = 0)
  * **Arrange**: Configure input so `merge_points.length` evaluates to 0
  * **Act**: Call `identify_merge_points` with minimum valid input
  * **Assert**: Accepted — returns valid output with `merge_points.length` = 0
* **Unit Scenario: UTS-042-B3** (mid: `merge_points.length` = 10)
  * **Arrange**: Configure input so `merge_points.length` evaluates to 10
  * **Act**: Call `identify_merge_points` with nominal input
  * **Assert**: Accepted — returns valid output with `merge_points.length` = 10
* **Unit Scenario: UTS-042-B4** (max: `merge_points.length` = 20)
  * **Arrange**: Configure input so `merge_points.length` evaluates to 20
  * **Act**: Call `identify_merge_points` with maximum valid input
  * **Assert**: Accepted — returns valid output with `merge_points.length` = 20
* **Unit Scenario: UTS-042-B5** (max+1: `merge_points.length` = 21)
  * **Arrange**: Configure input so `merge_points.length` evaluates to 21
  * **Act**: Call `identify_merge_points` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `merge_points.length` exceeds valid range

#### Test Case: UTP-042-C (Equivalence partitions for discrete types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition discrete non-scalar variables: `merge_point.type` (Enum: safety_critical, domain_overlay).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-042-C1** (valid partition: `merge_point.type` = "safety_critical")
  * **Arrange**: Set `merge_point.type` to `"safety_critical"`
  * **Act**: Call `identify_merge_points` with `merge_point.type` = "safety_critical"
  * **Assert**: Returns output specific to `merge_point.type` = "safety_critical" partition
* **Unit Scenario: UTS-042-C2** (valid partition: `merge_point.type` = "domain_overlay")
  * **Arrange**: Set `merge_point.type` to `"domain_overlay"`
  * **Act**: Call `identify_merge_points` with `merge_point.type` = "domain_overlay"
  * **Assert**: Returns output specific to `merge_point.type` = "domain_overlay" partition
* **Unit Scenario: UTS-042-C3** (invalid partition: `merge_point.type` = null/unknown)
  * **Arrange**: Set `merge_point.type` to `null` or an undefined value
  * **Act**: Call `identify_merge_points` with invalid `merge_point.type`
  * **Assert**: Raises validation error or returns default; invalid partition rejected

---

### Module: MOD-043 (Merge Overlay Content)

**Parent Architecture Modules**: ARCH-027
**Target Source File(s)**: `commands/architecture-design.md, commands/integration-test.md`

#### Test Case: UTP-043-A (Branch paths through merge_overlay_content)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `merge_overlay_content`. Branches: empty merge_points → return base unmodified, matching overlay section found → insert, no matching section → emit warning skip, uninserted overlay sections → emit warning.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-043-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `merge_overlay_content`
  * **Act**: Call `merge_overlay_content(base_template_content, overlay_content, merge_points)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-043-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (matching overlay section found → insert)
  * **Act**: Call `merge_overlay_content` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-043-A3** (error-path: MERGE_POINT_NOT_FOUND)
  * **Arrange**: Set up input that triggers error condition: No merge points in base
  * **Act**: Call `merge_overlay_content` with error-triggering input
  * **Assert**: Raises `MERGE_POINT_NOT_FOUND`; no partial output produced

#### Test Case: UTP-043-B (Boundary values for scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verify boundary behavior for scalar variables: `overlay_sections.length` (0..10), `result_lines.length` (0..10000).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-043-B1** (min-1: `overlay_sections.length` = -1)
  * **Arrange**: Configure input so `overlay_sections.length` evaluates to -1
  * **Act**: Call `merge_overlay_content` with boundary-violating input
  * **Assert**: Rejected — returns error or produces empty output; `overlay_sections.length` below valid range
* **Unit Scenario: UTS-043-B2** (min: `overlay_sections.length` = 0)
  * **Arrange**: Configure input so `overlay_sections.length` evaluates to 0
  * **Act**: Call `merge_overlay_content` with minimum valid input
  * **Assert**: Accepted — returns valid output with `overlay_sections.length` = 0
* **Unit Scenario: UTS-043-B3** (mid: `overlay_sections.length` = 5)
  * **Arrange**: Configure input so `overlay_sections.length` evaluates to 5
  * **Act**: Call `merge_overlay_content` with nominal input
  * **Assert**: Accepted — returns valid output with `overlay_sections.length` = 5
* **Unit Scenario: UTS-043-B4** (max: `overlay_sections.length` = 10)
  * **Arrange**: Configure input so `overlay_sections.length` evaluates to 10
  * **Act**: Call `merge_overlay_content` with maximum valid input
  * **Assert**: Accepted — returns valid output with `overlay_sections.length` = 10
* **Unit Scenario: UTS-043-B5** (max+1: `overlay_sections.length` = 11)
  * **Arrange**: Configure input so `overlay_sections.length` evaluates to 11
  * **Act**: Call `merge_overlay_content` with boundary-violating input
  * **Assert**: Rejected — returns error or truncates; `overlay_sections.length` exceeds valid range

---

### Module: MOD-044 (Get ID Pattern) [CROSS-CUTTING]

**Parent Architecture Modules**: ARCH-028
**Target Source File(s)**: `scripts/bash/validate-architecture-coverage.sh, scripts/bash/build-matrix.sh, scripts/powershell/validate-architecture-coverage.ps1, scripts/powershell/build-matrix.ps1`

#### Test Case: UTP-044-A (Branch paths through get_id_pattern)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every True/False branch and loop iteration in `get_id_pattern`. Branches: pattern_request IN patterns → return compiled regex, pattern_request NOT IN patterns → RAISE UNKNOWN_PATTERN.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-044-A1** (true-path: normal execution)
  * **Arrange**: Set up valid input that exercises the primary success path through `get_id_pattern`
  * **Act**: Call `get_id_pattern(pattern_request)`
  * **Assert**: Returns expected output; all internal accumulators populated correctly
* **Unit Scenario: UTS-044-A2** (false-path: skip/guard branches)
  * **Arrange**: Set up input that triggers the skip/guard condition (pattern_request NOT IN patterns → RAISE UNKNOWN_PATTERN)
  * **Act**: Call `get_id_pattern` with guard-triggering input
  * **Assert**: Skipped items are excluded; output reflects only valid entries
* **Unit Scenario: UTS-044-A3** (error-path: UNKNOWN_PATTERN)
  * **Arrange**: Set up input that triggers error condition: Unknown pattern name
  * **Act**: Call `get_id_pattern` with error-triggering input
  * **Assert**: Raises `UNKNOWN_PATTERN`; no partial output produced

#### Test Case: UTP-044-B (Equivalence partitions for discrete types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition discrete non-scalar variables: `pattern_request` (Enum: SYS, ARCH, ITP, ITS, REQ).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-044-B1** (valid partition: `pattern_request` = "SYS")
  * **Arrange**: Set `pattern_request` to `"SYS"`
  * **Act**: Call `get_id_pattern` with `pattern_request` = "SYS"
  * **Assert**: Returns output specific to `pattern_request` = "SYS" partition
* **Unit Scenario: UTS-044-B2** (valid partition: `pattern_request` = "ARCH")
  * **Arrange**: Set `pattern_request` to `"ARCH"`
  * **Act**: Call `get_id_pattern` with `pattern_request` = "ARCH"
  * **Assert**: Returns output specific to `pattern_request` = "ARCH" partition
* **Unit Scenario: UTS-044-B3** (valid partition: `pattern_request` = "ITP")
  * **Arrange**: Set `pattern_request` to `"ITP"`
  * **Act**: Call `get_id_pattern` with `pattern_request` = "ITP"
  * **Assert**: Returns output specific to `pattern_request` = "ITP" partition
* **Unit Scenario: UTS-044-B4** (valid partition: `pattern_request` = "ITS")
  * **Arrange**: Set `pattern_request` to `"ITS"`
  * **Act**: Call `get_id_pattern` with `pattern_request` = "ITS"
  * **Assert**: Returns output specific to `pattern_request` = "ITS" partition
* **Unit Scenario: UTS-044-B5** (valid partition: `pattern_request` = "REQ")
  * **Arrange**: Set `pattern_request` to `"REQ"`
  * **Act**: Call `get_id_pattern` with `pattern_request` = "REQ"
  * **Assert**: Returns output specific to `pattern_request` = "REQ" partition
* **Unit Scenario: UTS-044-B6** (invalid partition: `pattern_request` = null/unknown)
  * **Arrange**: Set `pattern_request` to `null` or an undefined value
  * **Act**: Call `get_id_pattern` with invalid `pattern_request`
  * **Assert**: Raises validation error or returns default; invalid partition rejected

---

## External Module Bypass

No `[EXTERNAL]` modules exist in this feature — all 44 modules are tested.

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Modules (MOD) | 44 (44 active, 0 deprecated) |
| Modules tested | 44 (excludes [EXTERNAL]) |
| Modules bypassed ([EXTERNAL]) | 0 |
| Total Test Cases (UTP) | 115 |
| Total Scenarios (UTS) | 424 |
| Modules with ≥1 UTP | 44 / 44 (100%) (active, non-[EXTERNAL] items only) |
| Test Cases with ≥1 UTS | 115 / 115 (100%) |
| **Overall Coverage (MOD→UTP)** | **100%** |

### Technique Distribution

| Technique | Test Cases | Percentage |
|-----------|-----------|------------|
| Statement & Branch Coverage | 44 | 38.3% |
| Boundary Value Analysis | 34 | 29.6% |
| Equivalence Partitioning | 25 | 21.7% |
| Strict Isolation | 12 | 10.4% |
| State Transition Testing | 0 | 0.0% |

## Uncovered Modules

None — full coverage achieved.
