# Unit Test Plan: [FEATURE NAME]

**Feature Branch**: `[###-feature-name]`
**Created**: [DATE]
**Status**: Draft
**Source**: `specs/[###-feature-name]/v-model/module-design.md`

## Overview

This document defines the Unit Test Plan for [FEATURE NAME]. Every module design (`MOD-NNN`)
in `module-design.md` has one or more Test Cases (`UTP-NNN-X`), and every Test Case has one or
more executable Unit Scenarios (`UTS-NNN-X#`) in white-box Arrange/Act/Assert format.

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

<!-- SAFETY-CRITICAL TECHNIQUES: Include only when v-model-config.yml domain is set -->

<!--
| **MC/DC Coverage** | Algorithmic/Logic View | Each condition independently affects decision outcome |
| **Variable-Level Fault Injection** | Internal Data Structures | Local variables forced into corrupted states |
-->

## Unit Tests

<!--
  For EACH module in module-design.md, generate:
  1. One or more Test Cases (UTP-NNN-X) — the logical verification condition
  2. One or more Unit Scenarios (UTS-NNN-X#) — white-box Arrange/Act/Assert

  RULES:
  - Every non-[EXTERNAL] MOD-NNN must have at least one UTP-NNN-X
  - Every UTP-NNN-X must have at least one UTS-NNN-X#
  - Each UTP must name its ISO 29119-4 technique
  - Each UTP must reference which module view it targets
  - Each UTP must include a Dependency & Mock Registry
  - UTS language must be white-box Arrange/Act/Assert (NO user-journey, boundary, or system phrases)
  - [CROSS-CUTTING] modules require full test coverage
  - [EXTERNAL] modules are skipped entirely
  - Do NOT renumber existing IDs when updating
  - Append new items; update modified items in-place by ID

  PROHIBITED phrases in UTS (belong in acceptance scenarios):
  - "the user clicks", "the user sees", "the user navigates"
  - "the user enters", "the user selects", "the user receives"

  PROHIBITED phrases in UTS (belong in integration test scenarios):
  - "Module ARCH-NNN sends/receives", "the handshake between"
  - "the interface between modules", "crosses module boundary"

  PROHIBITED phrases in UTS (belong in system test scenarios):
  - "the system responds", "the system processes", "end-to-end"

  REQUIRED language style (white-box, implementation-oriented):
  - "Arrange: Set `variable_name` to [value]"
  - "Act: Call `function_name(args)`"
  - "Assert: Returns [exact value]; `internal_var` equals [expected state]"
-->

### Module: MOD-001 ([Module Name])

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `src/path/to/module.py`

#### Test Case: UTP-001-A ([Verification Condition])

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: [What internal logic paths this test case verifies]

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| [External dep name] | [ARCH Interface View] | [Mock: returns static data] | [Why this mock approach] |
| [HW interface, if any] | [GPIO/Register/Bus] | [HW abstraction mock] | [Embedded isolation] |

<!-- If no dependencies: "None — module is self-contained" -->

* **Unit Scenario: UTS-001-A1**
  * **Arrange**: [Set internal variables/state to specific values]
  * **Act**: [Call specific function/method with exact arguments]
  * **Assert**: [Exact return value, variable states, error codes]

* **Unit Scenario: UTS-001-A2**
  * **Arrange**: [Set internal variables for false-branch execution]
  * **Act**: [Call same function with branch-triggering arguments]
  * **Assert**: [Expected false-branch outcome with specific values]

#### Test Case: UTP-001-B ([Verification Condition])

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: [Which scalar variables are boundary-tested and their valid ranges]

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| [Same isolation table — repeated per UTP] | | | |

* **Unit Scenario: UTS-001-B1** (min-1)
  * **Arrange**: [Set variable to one below minimum valid value]
  * **Act**: [Call function with boundary-violating input]
  * **Assert**: [Expected rejection — error code, exception, or validation failure]

* **Unit Scenario: UTS-001-B2** (min)
  * **Arrange**: [Set variable to minimum valid value]
  * **Act**: [Call function]
  * **Assert**: [Expected acceptance — valid output]

* **Unit Scenario: UTS-001-B3** (mid)
  * **Arrange**: [Set variable to typical middle value]
  * **Act**: [Call function]
  * **Assert**: [Expected nominal output]

* **Unit Scenario: UTS-001-B4** (max)
  * **Arrange**: [Set variable to maximum valid value]
  * **Act**: [Call function]
  * **Assert**: [Expected acceptance — valid output]

* **Unit Scenario: UTS-001-B5** (max+1)
  * **Arrange**: [Set variable to one above maximum valid value]
  * **Act**: [Call function with boundary-violating input]
  * **Assert**: [Expected rejection]

---

### Module: MOD-002 ([Stateful Module Name])

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `src/path/to/stateful_module.py`

#### Test Case: UTP-002-A ([State Transition Condition])

**Technique**: State Transition Testing
**Target View**: State Machine View
**Description**: [Which state transitions are exercised, including invalid ones]

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| [Dependencies for stateful module] | | | |

* **Unit Scenario: UTS-002-A1** (valid transition)
  * **Arrange**: [Initialize state machine in `[InitialState]`]
  * **Act**: [Send `[event]` to trigger transition]
  * **Assert**: [State changes to `[TargetState]`; entry action executes]

* **Unit Scenario: UTS-002-A2** (invalid transition)
  * **Arrange**: [Initialize state machine in `[State]`]
  * **Act**: [Send `[invalid_event]` that has no transition from current state]
  * **Assert**: [State remains `[State]`; `InvalidTransitionError` raised or event ignored]

---

### Module: MOD-003 ([Self-Contained Module Name])

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `src/path/to/standalone.py`

#### Test Case: UTP-003-A ([Verification Condition])

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: [Which discrete non-scalar types (Booleans, Enums) are partitioned]

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-003-A1** (valid partition: True)
  * **Arrange**: [Set boolean flag to `True`]
  * **Act**: [Call function]
  * **Assert**: [Expected True-path behavior with specific variable states]

* **Unit Scenario: UTS-003-A2** (valid partition: False)
  * **Arrange**: [Set boolean flag to `False`]
  * **Act**: [Call function]
  * **Assert**: [Expected False-path behavior with specific variable states]

* **Unit Scenario: UTS-003-A3** (invalid partition)
  * **Arrange**: [Set flag to null/undefined]
  * **Act**: [Call function]
  * **Assert**: [Validation error; function rejects invalid input]

---

### External Module Bypass: MOD-NNN ([External Library Wrapper])

> Module MOD-NNN is [EXTERNAL] — wrapper behavior tested at integration level.

---

[Continue for all modules in module-design.md...]

<!-- SAFETY-CRITICAL SECTION: Include only when v-model-config.yml domain is set -->

<!--
## MC/DC Coverage (DO-178C Level A)

For each complex boolean decision in the Algorithmic/Logic View:

### MOD-NNN: [Decision Expression]

Decision: `if (A and B or C)`

| Test | A | B | C | Decision | Independence Proof |
|------|---|---|---|----------|--------------------|
| 1 | T | T | F | T | A flips: row 1 vs row 3 |
| 2 | T | F | F | F | B flips: row 1 vs row 2 |
| 3 | F | T | F | F | A flips: row 1 vs row 3 |
| 4 | T | F | T | T | C flips: row 2 vs row 4 |

* **Unit Scenario: UTS-NNN-X1**: Arrange: A=T, B=T, C=F / Act: evaluate / Assert: Decision=T
* **Unit Scenario: UTS-NNN-X2**: Arrange: A=T, B=F, C=F / Act: evaluate / Assert: Decision=F

## Variable-Level Fault Injection (ISO 26262)

| Variable | Module | Corruption | Expected Detection |
|----------|--------|------------|-------------------|
| `var_name` | MOD-NNN | Force to NULL | [Internal error handler triggers] |
| `var_name` | MOD-NNN | Force to MAX_INT | [Overflow check catches value] |
| `var_name` | MOD-NNN | Force to -1 (unsigned) | [Type check rejects value] |
-->

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Modules (MOD) | [N] |
| Modules tested | [N] (excludes [EXTERNAL]) |
| Modules bypassed ([EXTERNAL]) | [N] |
| Total Test Cases (UTP) | [N] |
| Total Scenarios (UTS) | [N] |
| Modules with ≥1 UTP | [N] / [N] ([%]) |
| Test Cases with ≥1 UTS | [N] / [N] ([%]) |
| **Overall Coverage (MOD→UTP)** | **[%]** |

### Technique Distribution

| Technique | Test Cases | Percentage |
|-----------|-----------|------------|
| Statement & Branch Coverage | [N] | [%] |
| Boundary Value Analysis | [N] | [%] |
| Equivalence Partitioning | [N] | [%] |
| Strict Isolation | [N] | [%] |
| State Transition Testing | [N] | [%] |

<!-- Safety-critical only:
| MC/DC Coverage | [N] | [%] |
| Variable-Level Fault Injection | [N] | [%] |
-->

## Uncovered Modules

<!--
  Populated by validate-module-coverage.sh.
  If coverage is 100%, this section should read "None — full coverage achieved."
  [EXTERNAL] modules are NOT listed as uncovered — they are intentionally bypassed.
-->

[List of MOD-NNN IDs without any UTP, or "None — full coverage achieved."]
