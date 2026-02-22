# Acceptance Test Plan: Module Design ↔ Unit Testing

**Feature Branch**: `004-module-unit-testing`
**Created**: 2026-02-21
**Status**: Draft
**Source**: `specs/004-module-unit/v-model/requirements.md`

## Overview

This document defines the Acceptance Test Plan for the Module Design ↔ Unit Testing feature (v0.4.0). Every requirement in `requirements.md` has one or more Test Cases (ATP), and every Test Case has one or more executable User Scenarios (SCN) in BDD format (Given/When/Then).

## ID Schema

- **Test Case**: `ATP-{NNN}-{X}` — where NNN matches the parent REQ, X is a letter suffix (A, B, C...)
- **Scenario**: `SCN-{NNN}-{X}{#}` — nested under the parent ATP, with numeric suffix (1, 2, 3...)
- Example: `SCN-001-A1` → Scenario 1 of Test Case A validating REQ-001

## Acceptance Tests

### Requirement Validation: REQ-001 (Module Design Command Existence)

#### Test Case: ATP-001-A (Happy Path — Command Produces module-design.md)

**Linked Requirement:** REQ-001
**Description:** Verify the `/speckit.v-model.module-design` command reads `architecture-design.md` and produces `module-design.md` with MOD-NNN identifiers organized into four mandatory views.

* **User Scenario: SCN-001-A1**
  * **Given** an `architecture-design.md` file exists in `{FEATURE_DIR}/v-model/` containing at least one `ARCH-NNN` module
  * **When** the user invokes `/speckit.v-model.module-design`
  * **Then** a `module-design.md` file is created in `{FEATURE_DIR}/v-model/` `And` the file is non-empty `And` contains at least one `MOD-NNN` identifier `And` each MOD includes sections for Algorithmic/Logic View, State Machine View, Internal Data Structures, and Error Handling

#### Test Case: ATP-001-B (Error — Missing architecture-design.md)

**Linked Requirement:** REQ-001
**Description:** Verify the command fails gracefully when `architecture-design.md` does not exist.

* **User Scenario: SCN-001-B1**
  * **Given** the `{FEATURE_DIR}/v-model/` directory exists `And` no `architecture-design.md` file is present
  * **When** the user invokes `/speckit.v-model.module-design`
  * **Then** the command outputs an error message containing "architecture-design.md" `And` no `module-design.md` file is created

---

### Requirement Validation: REQ-002 (MOD-NNN Identifier Assignment)

#### Test Case: ATP-002-A (Sequential MOD-NNN Format)

**Linked Requirement:** REQ-002
**Description:** Verify each module is assigned a unique `MOD-NNN` identifier in 3-digit zero-padded sequential order.

* **User Scenario: SCN-002-A1**
  * **Given** an `architecture-design.md` exists with 5 architecture modules (`ARCH-001` through `ARCH-005`)
  * **When** the user invokes `/speckit.v-model.module-design`
  * **Then** every module in `module-design.md` has an ID matching the regex `^MOD-\d{3}$` `And` the first module is `MOD-001` `And` IDs are sequentially numbered

#### Test Case: ATP-002-B (Identifier Permanence on Re-run)

**Linked Requirement:** REQ-002
**Description:** Verify that re-running the command does not renumber existing MOD-NNN identifiers.

* **User Scenario: SCN-002-B1**
  * **Given** a `module-design.md` exists containing `MOD-001`, `MOD-002`, `MOD-003` `And` `architecture-design.md` has been updated with additional architecture modules
  * **When** the user invokes `/speckit.v-model.module-design`
  * **Then** the original `MOD-001`, `MOD-002`, `MOD-003` retain their identifiers `And` new modules are appended as `MOD-004` or higher

---

### Requirement Validation: REQ-003 (Algorithmic/Logic View with Fenced Pseudocode)

#### Test Case: ATP-003-A (Fenced Pseudocode Block Present)

**Linked Requirement:** REQ-003
**Description:** Verify each MOD-NNN includes an Algorithmic/Logic View with pseudocode enclosed in fenced ` ```pseudocode ``` ` blocks.

* **User Scenario: SCN-003-A1**
  * **Given** an `architecture-design.md` exists with 3 architecture modules
  * **When** the user inspects the generated `module-design.md`
  * **Then** every non-EXTERNAL `MOD-NNN` entry contains an Algorithmic/Logic View section `And` within that section there is at least one fenced code block tagged `pseudocode` `And` the pseudocode includes explicit branches, loops, or decision points

---

### Requirement Validation: REQ-004 (Target Source File(s) Property)

#### Test Case: ATP-004-A (Single Source File Mapping)

**Linked Requirement:** REQ-004
**Description:** Verify each MOD-NNN includes a Target Source File(s) property mapping to a physical file path.

* **User Scenario: SCN-004-A1**
  * **Given** an `architecture-design.md` exists with modules implemented in Python
  * **When** the user inspects the generated `module-design.md`
  * **Then** every `MOD-NNN` entry includes a "Target Source File(s)" property `And` each value contains a valid file path (e.g., `src/sensor/parser.py`)

#### Test Case: ATP-004-B (Comma-Separated Multi-File Mapping)

**Linked Requirement:** REQ-004
**Description:** Verify modules spanning multiple files (header/implementation pairs) use comma-separated paths.

* **User Scenario: SCN-004-B1**
  * **Given** an `architecture-design.md` exists with modules implemented in C/C++
  * **When** the user inspects the generated `module-design.md`
  * **Then** modules with header/implementation pairs have a "Target Source File(s)" value containing comma-separated paths (e.g., `src/sensor/parser.h, src/sensor/parser.cpp`)

---

### Requirement Validation: REQ-005 (State Machine View — Mermaid stateDiagram-v2)

#### Test Case: ATP-005-A (Stateful Module Has Mermaid Diagram)

**Linked Requirement:** REQ-005
**Description:** Verify stateful modules include a State Machine View using Mermaid `stateDiagram-v2` syntax.

* **User Scenario: SCN-005-A1**
  * **Given** an `architecture-design.md` exists with a module that maintains internal state (e.g., a connection pool manager)
  * **When** the user inspects the generated `module-design.md`
  * **Then** the stateful module's State Machine View contains a Mermaid `stateDiagram-v2` code block `And` the diagram includes states, transitions, events, and guard conditions

---

### Requirement Validation: REQ-006 (Stateless Bypass — Broad Regex Detection)

#### Test Case: ATP-006-A (Stateless Module Bypasses Mermaid Requirement)

**Linked Requirement:** REQ-006
**Description:** Verify stateless modules are marked with a bypass string detectable by the broad regex `(?i)N/?A.*Stateless`.

* **User Scenario: SCN-006-A1**
  * **Given** an `architecture-design.md` exists with a pure function module (no internal state)
  * **When** the user inspects the generated `module-design.md`
  * **Then** the stateless module's State Machine View contains text matching the regex `(?i)N/?A.*Stateless` (e.g., "N/A — Stateless" or "N/A - Stateless")

---

### Requirement Validation: REQ-007 (Internal Data Structures Section)

#### Test Case: ATP-007-A (Data Structures with Types, Sizes, Constraints)

**Linked Requirement:** REQ-007
**Description:** Verify each MOD-NNN includes an Internal Data Structures section with explicit types, sizes, and constraints.

* **User Scenario: SCN-007-A1**
  * **Given** an `architecture-design.md` exists with modules that process sensor data
  * **When** the user inspects the generated `module-design.md`
  * **Then** every `MOD-NNN` entry includes an "Internal Data Structures" section `And` the section documents local variables, constants, or buffers with explicit types and size constraints (e.g., "uint8_t array, 256 bytes")

---

### Requirement Validation: REQ-008 (Error Handling & Return Codes Section)

#### Test Case: ATP-008-A (Error Handling Maps to Architecture Interface View)

**Linked Requirement:** REQ-008
**Description:** Verify each MOD-NNN includes an Error Handling section documenting how exceptions are caught and formatted to honor the Architecture Interface View contract.

* **User Scenario: SCN-008-A1**
  * **Given** an `architecture-design.md` exists with modules that have defined error contracts in the Interface View
  * **When** the user inspects the generated `module-design.md`
  * **Then** every `MOD-NNN` entry includes an "Error Handling & Return Codes" section `And` the section references the error codes defined in the parent architecture module's Interface View

---

### Requirement Validation: REQ-009 (Parent Architecture Modules Field)

#### Test Case: ATP-009-A (Explicit ARCH-NNN Traceability)

**Linked Requirement:** REQ-009
**Description:** Verify each MOD-NNN traces to one or more ARCH-NNN identifiers via a "Parent Architecture Modules" field.

* **User Scenario: SCN-009-A1**
  * **Given** an `architecture-design.md` exists with `ARCH-001` through `ARCH-005`
  * **When** the user inspects the generated `module-design.md`
  * **Then** every `MOD-NNN` entry includes a "Parent Architecture Modules" field `And` each field lists one or more valid `ARCH-NNN` identifiers that exist in `architecture-design.md`

---

### Requirement Validation: REQ-010 (Many-to-Many ARCH↔MOD Relationships)

#### Test Case: ATP-010-A (One ARCH Maps to Multiple MODs)

**Linked Requirement:** REQ-010
**Description:** Verify a single ARCH-NNN can spawn multiple MOD-NNN items.

* **User Scenario: SCN-010-A1**
  * **Given** an `architecture-design.md` exists with `ARCH-001` representing a complex subsystem with multiple internal functions
  * **When** the user invokes `/speckit.v-model.module-design`
  * **Then** `module-design.md` contains two or more `MOD-NNN` items each listing `ARCH-001` in their "Parent Architecture Modules" field

#### Test Case: ATP-010-B (One MOD Satisfies Multiple ARCHs)

**Linked Requirement:** REQ-010
**Description:** Verify a single MOD-NNN can trace to multiple ARCH-NNN parents.

* **User Scenario: SCN-010-B1**
  * **Given** an `architecture-design.md` exists where a shared utility function is needed by both `ARCH-002` and `ARCH-003`
  * **When** the user inspects the generated `module-design.md`
  * **Then** at least one `MOD-NNN` item lists both `ARCH-002` and `ARCH-003` in its "Parent Architecture Modules" field

---

### Requirement Validation: REQ-011 (CROSS-CUTTING Full Decomposition)

#### Test Case: ATP-011-A (Cross-Cutting Module Gets Complete Pseudocode)

**Linked Requirement:** REQ-011
**Description:** Verify `[CROSS-CUTTING]` architecture modules are fully decomposed into MOD-NNN items with complete pseudocode and the inherited tag.

* **User Scenario: SCN-011-A1**
  * **Given** an `architecture-design.md` exists with `ARCH-007` tagged `[CROSS-CUTTING]` (a diagnostic logger)
  * **When** the user invokes `/speckit.v-model.module-design`
  * **Then** `module-design.md` contains at least one `MOD-NNN` with `ARCH-007` as parent `And` the MOD is tagged `[CROSS-CUTTING]` `And` it includes a fenced `pseudocode` block with complete implementation logic

---

### Requirement Validation: REQ-012 (EXTERNAL Tag for Third-Party Wrappers)

#### Test Case: ATP-012-A (External Module Documents Wrapper Only)

**Linked Requirement:** REQ-012
**Description:** Verify third-party library wrappers are tagged `[EXTERNAL]` with wrapper-only documentation.

* **User Scenario: SCN-012-A1**
  * **Given** an `architecture-design.md` exists with `ARCH-009` wrapping a third-party PostgreSQL driver
  * **When** the user invokes `/speckit.v-model.module-design`
  * **Then** the resulting `MOD-NNN` is tagged `[EXTERNAL]` `And` documents only connection parameters, retry policy, and timeout configuration `And` does not contain deep algorithmic pseudocode of the driver internals

---

### Requirement Validation: REQ-013 (EXTERNAL Wrapper Logic Documentation)

#### Test Case: ATP-013-A (Wrapper with Meaningful Logic Gets Pseudocode)

**Linked Requirement:** REQ-013
**Description:** Verify that when an `[EXTERNAL]` module's wrapper contains meaningful logic, that logic is documented with pseudocode.

* **User Scenario: SCN-013-A1**
  * **Given** an `architecture-design.md` exists with `ARCH-009` wrapping a database driver `And` the wrapper implements a retry policy with exponential backoff
  * **When** the user inspects the generated `module-design.md`
  * **Then** the `[EXTERNAL]` module includes a fenced `pseudocode` block for the retry logic `And` the library's internal query engine algorithm is not documented

---

### Requirement Validation: REQ-014 (Safety-Critical Module Design Sections)

#### Test Case: ATP-014-A (Safety Sections Present When Configured)

**Linked Requirement:** REQ-014
**Description:** Verify safety-critical sections are included when the project is configured for a regulated domain.

* **User Scenario: SCN-014-A1**
  * **Given** a project configured for DO-178C Level A via `v-model-config.yml` `And` an `architecture-design.md` with 3 modules
  * **When** the user invokes `/speckit.v-model.module-design`
  * **Then** each `MOD-NNN` includes a "Complexity Constraints" section stating cyclomatic complexity ≤ 10 `And` a "Memory Management" section prohibiting dynamic allocation after init `And` a "Single Entry/Exit" section enforcing one return point per function

---

### Requirement Validation: REQ-015 (Derived Module Flagging)

#### Test Case: ATP-015-A (Untraceable Module Flagged as DERIVED)

**Linked Requirement:** REQ-015
**Description:** Verify that modules not traceable to any ARCH-NNN are flagged as `[DERIVED MODULE]`.

* **User Scenario: SCN-015-A1**
  * **Given** an `architecture-design.md` exists with `ARCH-001` and `ARCH-002` `And` during decomposition the AI identifies a helper function not present in either architecture module
  * **When** the user invokes `/speckit.v-model.module-design`
  * **Then** the helper function is flagged as `[DERIVED MODULE: description]` `And` no `MOD-NNN` identifier is assigned to it `And` a prompt is included to update `architecture-design.md`

---

### Requirement Validation: REQ-016 (No Vague Prose in Algorithmic View)

#### Test Case: ATP-016-A (Structural Validation of Pseudocode Blocks)

**Linked Requirement:** REQ-016
**Description:** Verify every non-EXTERNAL MOD-NNN contains a fenced `pseudocode` code block and that absence is flagged.

* **User Scenario: SCN-016-A1**
  * **Given** a generated `module-design.md` with 5 non-EXTERNAL modules
  * **When** a deterministic validator checks each `MOD-NNN` section for the presence of a fenced ` ```pseudocode ``` ` block
  * **Then** every non-EXTERNAL module passes the check `And` any module missing the fenced block is reported as a structural failure

---

### Requirement Validation: REQ-017 (Unit Test Command Existence)

#### Test Case: ATP-017-A (Happy Path — Command Produces unit-test.md)

**Linked Requirement:** REQ-017
**Description:** Verify the `/speckit.v-model.unit-test` command reads `module-design.md` and produces `unit-test.md`.

* **User Scenario: SCN-017-A1**
  * **Given** a `module-design.md` file exists in `{FEATURE_DIR}/v-model/` containing at least one `MOD-NNN` item
  * **When** the user invokes `/speckit.v-model.unit-test`
  * **Then** a `unit-test.md` file is created in `{FEATURE_DIR}/v-model/` `And` the file contains at least one `UTP-NNN-X` test case `And` at least one `UTS-NNN-X#` test scenario

#### Test Case: ATP-017-B (Error — Missing module-design.md)

**Linked Requirement:** REQ-017
**Description:** Verify the command fails gracefully when `module-design.md` does not exist.

* **User Scenario: SCN-017-B1**
  * **Given** the `{FEATURE_DIR}/v-model/` directory exists `And` no `module-design.md` file is present
  * **When** the user invokes `/speckit.v-model.unit-test`
  * **Then** the command outputs an error message containing "module-design.md" `And` no `unit-test.md` file is created

---

### Requirement Validation: REQ-018 (UTP-NNN-X Identifier Format)

#### Test Case: ATP-018-A (UTP ID Lineage Encoding)

**Linked Requirement:** REQ-018
**Description:** Verify unit test case identifiers follow the format `UTP-NNN-X` where NNN matches the parent MOD-NNN.

* **User Scenario: SCN-018-A1**
  * **Given** a `module-design.md` exists with `MOD-001` and `MOD-002`
  * **When** the user inspects the generated `unit-test.md`
  * **Then** test cases for `MOD-001` have IDs matching `UTP-001-[A-Z]` `And` test cases for `MOD-002` have IDs matching `UTP-002-[A-Z]`

---

### Requirement Validation: REQ-019 (UTS-NNN-X# Identifier Format)

#### Test Case: ATP-019-A (UTS ID Lineage Encoding)

**Linked Requirement:** REQ-019
**Description:** Verify unit test scenario identifiers follow the format `UTS-NNN-X#` where NNN-X matches the parent UTP.

* **User Scenario: SCN-019-A1**
  * **Given** a `unit-test.md` exists with `UTP-001-A`
  * **When** the user inspects the test scenarios under `UTP-001-A`
  * **Then** every scenario has an ID matching `UTS-001-A[0-9]+` (e.g., `UTS-001-A1`, `UTS-001-A2`)

---

### Requirement Validation: REQ-020 (White-Box Techniques Applied)

#### Test Case: ATP-020-A (Technique Named per Test Case)

**Linked Requirement:** REQ-020
**Description:** Verify each UTP-NNN-X applies one of the mandatory ISO 29119-4 white-box techniques.

* **User Scenario: SCN-020-A1**
  * **Given** a `module-design.md` exists with modules having various internal logic, data structures, and state machines
  * **When** the user inspects the generated `unit-test.md`
  * **Then** every `UTP-NNN-X` explicitly names one of: "Statement & Branch Coverage", "Boundary Value Analysis", "Equivalence Partitioning", "Strict Isolation", or "State Transition Testing"

#### Test Case: ATP-020-B (EP Applied to Non-Scalar Types Instead of BVA)

**Linked Requirement:** REQ-020
**Description:** Verify Equivalence Partitioning is used for discrete non-scalar types where BVA boundaries do not exist.

* **User Scenario: SCN-020-B1**
  * **Given** a `module-design.md` exists with a module accepting a Boolean parameter or an Enum type
  * **When** the user inspects the generated `unit-test.md`
  * **Then** the test case for that parameter uses "Equivalence Partitioning" `And` does not attempt to apply min/min-1/max/max+1 boundaries to the Boolean or Enum

---

### Requirement Validation: REQ-021 (Technique References Module View)

#### Test Case: ATP-021-A (Technique-View Pairing)

**Linked Requirement:** REQ-021
**Description:** Verify each test case explicitly references the specific module view that drives it.

* **User Scenario: SCN-021-A1**
  * **Given** a generated `unit-test.md` with test cases applying various techniques
  * **When** the user inspects a test case using "Statement & Branch Coverage"
  * **Then** the test case references "Algorithmic/Logic View" as its driving view `And` test cases using "BVA" reference "Internal Data Structures" `And` test cases using "State Transition Testing" reference "State Machine View"

---

### Requirement Validation: REQ-022 (Dependency & Mock Registry Table)

#### Test Case: ATP-022-A (Mock Registry Present per UTP)

**Linked Requirement:** REQ-022
**Description:** Verify every UTP-NNN-X includes a Dependency & Mock Registry table listing external dependencies and their mock strategy.

* **User Scenario: SCN-022-A1**
  * **Given** a `module-design.md` exists with modules that depend on a database and a message queue
  * **When** the user inspects the generated `unit-test.md`
  * **Then** every `UTP-NNN-X` includes a "Dependency & Mock Registry" table `And` each entry names the dependency and its mock/stub strategy (e.g., "Mock: DatabaseConnection → Returns static JSON")

---

### Requirement Validation: REQ-023 (Hardware Interfaces in Mock Registry)

#### Test Case: ATP-023-A (GPIO/I2C/SPI Listed as Dependencies)

**Linked Requirement:** REQ-023
**Description:** Verify the Dependency & Mock Registry includes hardware interfaces when present.

* **User Scenario: SCN-023-A1**
  * **Given** a `module-design.md` exists with an embedded module that reads from a GPIO pin and writes to an I2C bus
  * **When** the user inspects the generated `unit-test.md`
  * **Then** the Dependency & Mock Registry lists "GPIO pin" and "I2C bus" as dependencies with explicit mock/stub strategies

---

### Requirement Validation: REQ-024 (Self-Contained Module Mock Registry)

#### Test Case: ATP-024-A (No Dependencies — Registry Shows None)

**Linked Requirement:** REQ-024
**Description:** Verify modules with no external dependencies show "None — module is self-contained" in the Mock Registry.

* **User Scenario: SCN-024-A1**
  * **Given** a `module-design.md` exists with a pure computation module that has no external dependencies
  * **When** the user inspects the generated `unit-test.md`
  * **Then** the Dependency & Mock Registry for that module's test cases shows "None — module is self-contained" `And` the test scenarios proceed with direct invocation

---

### Requirement Validation: REQ-025 (Arrange/Act/Assert White-Box Language)

#### Test Case: ATP-025-A (Implementation-Oriented Language in UTS)

**Linked Requirement:** REQ-025
**Description:** Verify unit test scenarios use Arrange/Act/Assert structure with white-box, implementation-oriented language.

* **User Scenario: SCN-025-A1**
  * **Given** a generated `unit-test.md` with test scenarios
  * **When** the user inspects any `UTS-NNN-X#` scenario
  * **Then** the scenario uses Arrange/Act/Assert format `And` references internal code paths, variables, or branches (e.g., "Arrange: Set buffer_size to 256", "Act: Call parse_sensor_data()", "Assert: Returns ERROR_OVERFLOW") `And` does not use Given/When/Then BDD format

---

### Requirement Validation: REQ-026 (EXTERNAL Modules Skipped for Unit Tests)

#### Test Case: ATP-026-A (No UTP Generated for EXTERNAL Modules)

**Linked Requirement:** REQ-026
**Description:** Verify the unit test command does not generate test cases for `[EXTERNAL]` modules.

* **User Scenario: SCN-026-A1**
  * **Given** a `module-design.md` exists with `MOD-005` tagged `[EXTERNAL]`
  * **When** the user invokes `/speckit.v-model.unit-test`
  * **Then** no `UTP-005-X` test case exists in `unit-test.md` `And` a note states "Module MOD-005 is [EXTERNAL] — wrapper behavior tested at integration level"

---

### Requirement Validation: REQ-027 (Safety-Critical Unit Test Techniques)

#### Test Case: ATP-027-A (MC/DC Truth Tables Generated)

**Linked Requirement:** REQ-027
**Description:** Verify MC/DC truth tables are generated for complex boolean logic when configured for a safety-critical domain.

* **User Scenario: SCN-027-A1**
  * **Given** a project configured for DO-178C Level A `And` a `module-design.md` with a module containing a complex decision `if (A and B or C)`
  * **When** the user invokes `/speckit.v-model.unit-test`
  * **Then** the test output includes an MC/DC truth table for the decision `And` the table proves each condition (A, B, C) can independently affect the outcome

#### Test Case: ATP-027-B (Variable-Level Fault Injection Scenarios)

**Linked Requirement:** REQ-027
**Description:** Verify variable-level fault injection scenarios are generated for safety-critical configurations.

* **User Scenario: SCN-027-B1**
  * **Given** a project configured for ISO 26262 ASIL-D `And` a `module-design.md` with modules that have internal error handling
  * **When** the user invokes `/speckit.v-model.unit-test`
  * **Then** the test output includes fault injection scenarios that force local variables into corrupted states `And` verify the internal error handling triggers correctly

---

### Requirement Validation: REQ-028 (Post-Generation Coverage Gate)

#### Test Case: ATP-028-A (Coverage Validation Runs After Generation)

**Linked Requirement:** REQ-028
**Description:** Verify the unit test command invokes `validate-module-coverage.sh` after generation and reports the result.

* **User Scenario: SCN-028-A1**
  * **Given** a `module-design.md` exists with 5 non-EXTERNAL modules
  * **When** the user invokes `/speckit.v-model.unit-test`
  * **Then** the command output includes a coverage validation result (pass/fail) `And` shows the coverage summary from `validate-module-coverage.sh`

---

### Requirement Validation: REQ-029 (No Higher-Level Test Scenarios)

#### Test Case: ATP-029-A (Unit Tests Target Internal Logic Only)

**Linked Requirement:** REQ-029
**Description:** Verify the unit test command generates only tests for internal module logic, not user journeys or integration boundaries.

* **User Scenario: SCN-029-A1**
  * **Given** a generated `unit-test.md`
  * **When** the user reviews all `UTS-NNN-X#` scenarios
  * **Then** no scenario describes user-journey behavior (e.g., "user logs in and navigates to dashboard") `And` no scenario tests module-to-module boundary handshakes `And` all scenarios target internal branches, variables, data transformations, or state transitions

---

### Requirement Validation: REQ-030 (State Transition Testing Covers Invalid Transitions)

#### Test Case: ATP-030-A (Invalid Transitions Tested)

**Linked Requirement:** REQ-030
**Description:** Verify State Transition Testing covers every defined transition including invalid ones that should be rejected.

* **User Scenario: SCN-030-A1**
  * **Given** a `module-design.md` with a stateful module defining states `[Idle, Active, Error]` with valid transitions `Idle→Active` and `Active→Error`
  * **When** the user inspects the State Transition Testing test cases in `unit-test.md`
  * **Then** test cases exist for every valid transition `And` test cases exist for invalid transitions (e.g., `Idle→Error`, `Error→Active`) that verify the module rejects them

---

### Requirement Validation: REQ-031 (ID Lineage Regex to MOD-NNN)

#### Test Case: ATP-031-A (Regex Extracts UTP and MOD from UTS ID)

**Linked Requirement:** REQ-031
**Description:** Verify a regex can extract the parent UTP-NNN-X and grandparent MOD-NNN from any UTS-NNN-X# identifier.

* **User Scenario: SCN-031-A1**
  * **Given** a `unit-test.md` containing `UTS-001-A1`, `UTS-001-A2`, and `UTS-003-B1`
  * **When** a regex is applied to `UTS-001-A1`
  * **Then** the regex extracts parent `UTP-001-A` and grandparent `MOD-001` without consulting any lookup table

---

### Requirement Validation: REQ-032 (ARCH Resolution Requires File Lookup)

#### Test Case: ATP-032-A (ARCH Ancestry Resolved via Parent Field)

**Linked Requirement:** REQ-032
**Description:** Verify ARCH-NNN ancestry is resolved by consulting the "Parent Architecture Modules" field in `module-design.md`.

* **User Scenario: SCN-032-A1**
  * **Given** a `module-design.md` where `MOD-001` lists "Parent Architecture Modules: ARCH-002, ARCH-005" `And` the many-to-many relationship prevents string-based ARCH extraction
  * **When** a script needs to find the ARCH ancestor of `MOD-001`
  * **Then** the script reads the "Parent Architecture Modules" field from `module-design.md` `And` returns `ARCH-002, ARCH-005`

---

### Requirement Validation: REQ-033 (Forward Coverage Validation — ARCH→MOD)

#### Test Case: ATP-033-A (All ARCH Modules Have MOD Mappings)

**Linked Requirement:** REQ-033
**Description:** Verify `validate-module-coverage.sh` detects 100% forward coverage when every ARCH-NNN has at least one MOD-NNN.

* **User Scenario: SCN-033-A1**
  * **Given** an `architecture-design.md` with `ARCH-001` through `ARCH-005` (including one `[CROSS-CUTTING]`) `And` a `module-design.md` with every ARCH covered by at least one MOD
  * **When** `validate-module-coverage.sh` runs
  * **Then** it exits with code 0 `And` reports 100% forward coverage

#### Test Case: ATP-033-B (Missing MOD Mapping Detected)

**Linked Requirement:** REQ-033
**Description:** Verify the script detects when an ARCH-NNN has no corresponding MOD-NNN.

* **User Scenario: SCN-033-B1**
  * **Given** an `architecture-design.md` with `ARCH-001` through `ARCH-005` `And` a `module-design.md` where `ARCH-003` has no corresponding MOD
  * **When** `validate-module-coverage.sh` runs
  * **Then** it exits with code 1 `And` reports "ARCH-003: no module design mapping found"

---

### Requirement Validation: REQ-034 (Backward Coverage Validation — MOD→UTP)

#### Test Case: ATP-034-A (All Non-EXTERNAL MODs Have UTP Mappings)

**Linked Requirement:** REQ-034
**Description:** Verify `validate-module-coverage.sh` detects 100% backward coverage when every non-EXTERNAL MOD has at least one UTP.

* **User Scenario: SCN-034-A1**
  * **Given** a `module-design.md` with `MOD-001` through `MOD-005` (none tagged `[EXTERNAL]`) `And` a `unit-test.md` where every MOD has at least one UTP
  * **When** `validate-module-coverage.sh` runs
  * **Then** it exits with code 0 `And` reports 100% backward coverage

#### Test Case: ATP-034-B (Missing UTP Mapping Detected)

**Linked Requirement:** REQ-034
**Description:** Verify the script detects when a non-EXTERNAL MOD has no corresponding UTP.

* **User Scenario: SCN-034-B1**
  * **Given** a `module-design.md` with `MOD-001` through `MOD-005` (none tagged `[EXTERNAL]`) `And` a `unit-test.md` where `MOD-004` has no corresponding UTP
  * **When** `validate-module-coverage.sh` runs
  * **Then** it exits with code 1 `And` reports "MOD-004: no unit test case mapping found"

---

### Requirement Validation: REQ-035 (EXTERNAL Bypass in Backward Coverage)

#### Test Case: ATP-035-A (EXTERNAL Module Counted as Covered)

**Linked Requirement:** REQ-035
**Description:** Verify `[EXTERNAL]` modules are bypassed for UTP requirements and counted as "covered by integration tests."

* **User Scenario: SCN-035-A1**
  * **Given** a `module-design.md` with `MOD-007` tagged `[EXTERNAL]` `And` a `unit-test.md` with no `UTP-007-X`
  * **When** `validate-module-coverage.sh` runs
  * **Then** it exits with code 0 `And` the coverage summary counts `MOD-007` as "covered by integration tests" rather than flagging it as a gap

---

### Requirement Validation: REQ-036 (Partial Validation — No unit-test.md)

#### Test Case: ATP-036-A (Forward-Only Validation When unit-test.md Absent)

**Linked Requirement:** REQ-036
**Description:** Verify the script validates only ARCH→MOD when `unit-test.md` does not exist.

* **User Scenario: SCN-036-A1**
  * **Given** an `architecture-design.md` with `ARCH-001` through `ARCH-003` `And` a `module-design.md` covering all 3 ARCHs `And` no `unit-test.md` exists
  * **When** `validate-module-coverage.sh` runs with only two file arguments
  * **Then** it validates ARCH→MOD forward coverage only `And` exits with code 0 `And` does not report any MOD→UTP backward coverage errors

---

### Requirement Validation: REQ-037 (Orphan Detection)

#### Test Case: ATP-037-A (Orphaned MOD Detected)

**Linked Requirement:** REQ-037
**Description:** Verify the script detects MOD-NNN items whose parent ARCH-NNN does not exist.

* **User Scenario: SCN-037-A1**
  * **Given** a `module-design.md` containing `MOD-099` with "Parent Architecture Modules: ARCH-099" `And` `architecture-design.md` does not contain `ARCH-099`
  * **When** `validate-module-coverage.sh` runs
  * **Then** it exits with code 1 `And` reports "MOD-099: orphaned module — parent ARCH-099 not found in architecture-design.md"

#### Test Case: ATP-037-B (Orphaned UTP Detected)

**Linked Requirement:** REQ-037
**Description:** Verify the script detects UTP-NNN-X items whose parent MOD-NNN does not exist.

* **User Scenario: SCN-037-B1**
  * **Given** a `unit-test.md` containing `UTP-099-A` `And` `module-design.md` does not contain `MOD-099`
  * **When** `validate-module-coverage.sh` runs
  * **Then** it exits with code 1 `And` reports "UTP-099-A: orphaned test case — parent MOD-099 not found in module-design.md"

---

### Requirement Validation: REQ-038 (Exit Codes)

#### Test Case: ATP-038-A (Exit Code 0 on Full Coverage)

**Linked Requirement:** REQ-038
**Description:** Verify the script exits with code 0 when all coverage checks pass.

* **User Scenario: SCN-038-A1**
  * **Given** complete `architecture-design.md`, `module-design.md`, and `unit-test.md` with 100% bidirectional coverage and zero orphans
  * **When** `validate-module-coverage.sh` runs
  * **Then** it exits with code 0

#### Test Case: ATP-038-B (Exit Code 1 on Coverage Gap)

**Linked Requirement:** REQ-038
**Description:** Verify the script exits with code 1 when any gap or orphan is detected.

* **User Scenario: SCN-038-B1**
  * **Given** a `module-design.md` where `ARCH-002` has no MOD mapping
  * **When** `validate-module-coverage.sh` runs
  * **Then** it exits with code 1

---

### Requirement Validation: REQ-039 (Human-Readable Gap Reports)

#### Test Case: ATP-039-A (Specific IDs Listed in Gap Report)

**Linked Requirement:** REQ-039
**Description:** Verify gap reports list each specific gap or orphan by ID.

* **User Scenario: SCN-039-A1**
  * **Given** a `module-design.md` where `ARCH-003` and `ARCH-005` have no MOD mappings
  * **When** `validate-module-coverage.sh` runs
  * **Then** the output includes "ARCH-003: no module design mapping found" `And` "ARCH-005: no module design mapping found" `And` the output is human-readable and suitable for CI log inspection

---

### Requirement Validation: REQ-040 (JSON Output Mode)

#### Test Case: ATP-040-A (--json Flag Produces Machine-Readable Output)

**Linked Requirement:** REQ-040
**Description:** Verify the `--json` flag produces JSON output parseable by the unit test command.

* **User Scenario: SCN-040-A1**
  * **Given** valid `architecture-design.md`, `module-design.md`, and `unit-test.md`
  * **When** `validate-module-coverage.sh --json` runs
  * **Then** the output is valid JSON `And` includes keys for forward coverage, backward coverage, orphans, and overall status

---

### Requirement Validation: REQ-041 (Strict Translator — Module Design)

#### Test Case: ATP-041-A (No Invented Modules)

**Linked Requirement:** REQ-041
**Description:** Verify the module design command does not invent modules not present in `architecture-design.md`.

* **User Scenario: SCN-041-A1**
  * **Given** an `architecture-design.md` with exactly 3 architecture modules (`ARCH-001`, `ARCH-002`, `ARCH-003`)
  * **When** the user invokes `/speckit.v-model.module-design`
  * **Then** every `MOD-NNN` in `module-design.md` traces back to at least one of the 3 defined ARCH modules `And` no MOD claims a parent ARCH that does not exist in the input

---

### Requirement Validation: REQ-042 (Strict Translator — Unit Test)

#### Test Case: ATP-042-A (No Invented Test Cases)

**Linked Requirement:** REQ-042
**Description:** Verify the unit test command does not invent test cases for modules not in `module-design.md`.

* **User Scenario: SCN-042-A1**
  * **Given** a `module-design.md` with exactly `MOD-001` and `MOD-002`
  * **When** the user invokes `/speckit.v-model.unit-test`
  * **Then** every `UTP-NNN-X` in `unit-test.md` has a parent MOD that exists in `module-design.md` `And` no UTP references a non-existent MOD

---

### Requirement Validation: REQ-043 (Graceful Failure on Empty Input)

#### Test Case: ATP-043-A (Clear Error for Empty architecture-design.md)

**Linked Requirement:** REQ-043
**Description:** Verify the module design command fails gracefully when the input has zero ARCH-NNN identifiers.

* **User Scenario: SCN-043-A1**
  * **Given** an `architecture-design.md` exists but contains zero `ARCH-NNN` identifiers
  * **When** the user invokes `/speckit.v-model.module-design`
  * **Then** the command outputs "No architecture modules found in architecture-design.md — cannot generate module design" `And` no `module-design.md` is created

---

### Requirement Validation: REQ-044 (Setup Script — Require Flags)

#### Test Case: ATP-044-A (--require-module-design Flag Validates Existence)

**Linked Requirement:** REQ-044
**Description:** Verify the `--require-module-design` flag causes the setup script to fail when `module-design.md` does not exist.

* **User Scenario: SCN-044-A1**
  * **Given** the `{FEATURE_DIR}/v-model/` directory exists `And` no `module-design.md` is present
  * **When** `setup-v-model.sh --require-module-design` runs
  * **Then** the script exits with a non-zero code `And` outputs an error message indicating `module-design.md` is required

#### Test Case: ATP-044-B (--require-unit-test Flag Validates Existence)

**Linked Requirement:** REQ-044
**Description:** Verify the `--require-unit-test` flag causes the setup script to fail when `unit-test.md` does not exist.

* **User Scenario: SCN-044-B1**
  * **Given** the `{FEATURE_DIR}/v-model/` directory exists `And` no `unit-test.md` is present
  * **When** `setup-v-model.sh --require-unit-test` runs
  * **Then** the script exits with a non-zero code `And` outputs an error message indicating `unit-test.md` is required

---

### Requirement Validation: REQ-045 (Setup Script — AVAILABLE_DOCS Detection)

#### Test Case: ATP-045-A (module-design.md and unit-test.md in AVAILABLE_DOCS)

**Linked Requirement:** REQ-045
**Description:** Verify the setup scripts detect `module-design.md` and `unit-test.md` in the available documents list.

* **User Scenario: SCN-045-A1**
  * **Given** a `module-design.md` and `unit-test.md` exist in `{FEATURE_DIR}/v-model/`
  * **When** `setup-v-model.sh --json` runs
  * **Then** the JSON output's `AVAILABLE_DOCS` array includes `"module-design.md"` and `"unit-test.md"`

---

### Requirement Validation: REQ-046 (Matrix D Generation)

#### Test Case: ATP-046-A (Matrix D Produced When Module Artifacts Exist)

**Linked Requirement:** REQ-046
**Description:** Verify the trace command produces Matrix D when both `module-design.md` and `unit-test.md` exist.

* **User Scenario: SCN-046-A1**
  * **Given** a feature directory with all eight V-Model artifacts (requirements through unit-test)
  * **When** the user invokes `/speckit.v-model.trace`
  * **Then** the output includes "Matrix D (Implementation Verification)" `And` the matrix shows ARCH → MOD → UTP → UTS linkages

---

### Requirement Validation: REQ-047 (SYS-NNN Annotation in Matrix D)

#### Test Case: ATP-047-A (ARCH Cell Includes SYS Parenthetical)

**Linked Requirement:** REQ-047
**Description:** Verify each ARCH-NNN cell in Matrix D includes its parent SYS-NNN identifiers in parentheses.

* **User Scenario: SCN-047-A1**
  * **Given** an `architecture-design.md` where `ARCH-001` traces to `SYS-001` and `SYS-003`
  * **When** the user inspects Matrix D in the traceability output
  * **Then** the ARCH-001 cell displays `ARCH-001 (SYS-001, SYS-003)`

---

### Requirement Validation: REQ-048 (CROSS-CUTTING in Matrix D)

#### Test Case: ATP-048-A (Cross-Cutting Shows Tag Instead of SYS)

**Linked Requirement:** REQ-048
**Description:** Verify `[CROSS-CUTTING]` ARCH modules display `([CROSS-CUTTING])` in Matrix D instead of SYS annotation.

* **User Scenario: SCN-048-A1**
  * **Given** an `architecture-design.md` where `ARCH-007` is tagged `[CROSS-CUTTING]`
  * **When** the user inspects Matrix D in the traceability output
  * **Then** the ARCH-007 cell displays `ARCH-007 ([CROSS-CUTTING])` instead of a SYS-NNN parenthetical

---

### Requirement Validation: REQ-049 (EXTERNAL in Matrix D)

#### Test Case: ATP-049-A (External Module Shows N/A in UTP/UTS Columns)

**Linked Requirement:** REQ-049
**Description:** Verify `[EXTERNAL]` modules appear in Matrix D with "N/A — External" for UTP/UTS.

* **User Scenario: SCN-049-A1**
  * **Given** a `module-design.md` with `MOD-005` tagged `[EXTERNAL]`
  * **When** the user inspects Matrix D in the traceability output
  * **Then** `MOD-005` appears in the MOD column with an `[EXTERNAL]` annotation `And` the UTP and UTS columns show "N/A — External"

---

### Requirement Validation: REQ-050 (Separate Matrices with Independent Percentages)

#### Test Case: ATP-050-A (Four Distinct Matrix Tables)

**Linked Requirement:** REQ-050
**Description:** Verify matrices A, B, C, and D are rendered as separate tables with independent coverage percentages.

* **User Scenario: SCN-050-A1**
  * **Given** a feature directory with all V-Model artifacts
  * **When** the user invokes `/speckit.v-model.trace`
  * **Then** the output contains four separate Markdown tables labeled Matrix A, Matrix B, Matrix C, and Matrix D `And` each table has its own coverage percentage

---

### Requirement Validation: REQ-051 (Backward Compatibility — No Matrix D Without Module Artifacts)

#### Test Case: ATP-051-A (v0.3.0 Output Preserved When Module Artifacts Absent)

**Linked Requirement:** REQ-051
**Description:** Verify the trace command produces only Matrix A+B+C when module-level artifacts do not exist.

* **User Scenario: SCN-051-A1**
  * **Given** a feature directory with requirements through integration-test artifacts `And` no `module-design.md` or `unit-test.md` exist
  * **When** the user invokes `/speckit.v-model.trace`
  * **Then** the output contains Matrix A, Matrix B, and Matrix C only `And` no Matrix D is generated `And` no warning about missing module artifacts is shown

---

### Requirement Validation: REQ-052 (Progressive Matrix Generation)

#### Test Case: ATP-052-A (Matrices Build Progressively)

**Linked Requirement:** REQ-052
**Description:** Verify matrices are generated progressively based on available artifacts.

* **User Scenario: SCN-052-A1**
  * **Given** a feature directory with only requirements and acceptance-plan
  * **When** the user invokes `/speckit.v-model.trace`
  * **Then** only Matrix A is generated

* **User Scenario: SCN-052-A2**
  * **Given** a feature directory with artifacts through system-test
  * **When** the user invokes `/speckit.v-model.trace`
  * **Then** Matrix A and Matrix B are generated

* **User Scenario: SCN-052-A3**
  * **Given** a feature directory with artifacts through integration-test
  * **When** the user invokes `/speckit.v-model.trace`
  * **Then** Matrix A, B, and C are generated

* **User Scenario: SCN-052-A4**
  * **Given** a feature directory with all artifacts through unit-test
  * **When** the user invokes `/speckit.v-model.trace`
  * **Then** Matrix A, B, C, and D are generated

---

### Requirement Validation: REQ-053 (Coverage Percentages Match Scripts)

#### Test Case: ATP-053-A (Matrix Percentages Match Validation Scripts)

**Linked Requirement:** REQ-053
**Description:** Verify each matrix's coverage percentage matches the output of the corresponding validation script.

* **User Scenario: SCN-053-A1**
  * **Given** `validate-module-coverage.sh` reports 100% forward and backward coverage
  * **When** the user inspects Matrix D's coverage percentage
  * **Then** Matrix D shows 100% coverage matching the script output

---

### Requirement Validation: REQ-054 (build-matrix.sh Three-File Parsing)

#### Test Case: ATP-054-A (Matrix D Requires Three Input Files)

**Linked Requirement:** REQ-054
**Description:** Verify `build-matrix.sh` parses `module-design.md`, `unit-test.md`, AND `architecture-design.md` for Matrix D.

* **User Scenario: SCN-054-A1**
  * **Given** `module-design.md`, `unit-test.md`, and `architecture-design.md` exist with valid content
  * **When** `build-matrix.sh` generates Matrix D
  * **Then** the matrix correctly displays SYS-NNN annotations next to ARCH-NNN (resolved from `architecture-design.md`) `And` MOD-NNN items (from `module-design.md`) `And` UTP/UTS items (from `unit-test.md`)

---

### Requirement Validation: REQ-055 (Partial Matrix D — No unit-test.md)

#### Test Case: ATP-055-A (MOD Column Present, UTP/UTS Empty)

**Linked Requirement:** REQ-055
**Description:** Verify Matrix D shows MOD column but empty UTP/UTS when `unit-test.md` does not exist.

* **User Scenario: SCN-055-A1**
  * **Given** `module-design.md` exists `And` `unit-test.md` does not exist
  * **When** the user invokes `/speckit.v-model.trace`
  * **Then** Matrix D includes the MOD column with valid entries `And` the UTP and UTS columns show "Unit test plan not yet generated"

---

### Requirement Validation: REQ-056 (Module Design Template)

#### Test Case: ATP-056-A (Template Exists with Required Structure)

**Linked Requirement:** REQ-056
**Description:** Verify `module-design-template.md` exists in `templates/` with the four mandatory views, Target Source File(s), and `[EXTERNAL]` section.

* **User Scenario: SCN-056-A1**
  * **Given** the extension is installed
  * **When** the user inspects `templates/module-design-template.md`
  * **Then** the template contains sections for Algorithmic/Logic View, State Machine View, Internal Data Structures, Error Handling `And` includes a "Target Source File(s)" field `And` includes a section for `[EXTERNAL]` module handling

---

### Requirement Validation: REQ-057 (Unit Test Template)

#### Test Case: ATP-057-A (Template Exists with Required Structure)

**Linked Requirement:** REQ-057
**Description:** Verify `unit-test-template.md` exists in `templates/` with the three-tier UTP/UTS hierarchy and Dependency & Mock Registry.

* **User Scenario: SCN-057-A1**
  * **Given** the extension is installed
  * **When** the user inspects `templates/unit-test-template.md`
  * **Then** the template contains sections for UTP-NNN-X test cases and UTS-NNN-X# scenarios `And` includes a "Dependency & Mock Registry" table per test case

---

### Requirement Validation: REQ-NF-001 (Regex-Based Parsing)

#### Test Case: ATP-NF-001-A (No External Tooling Required)

**Linked Requirement:** REQ-NF-001
**Description:** Verify `validate-module-coverage.sh` uses only regex-based parsing with standard Bash utilities.

* **User Scenario: SCN-NF-001-A1**
  * **Given** a minimal Bash ≥ 4.0 environment with no additional tools installed (no Python, no Node.js)
  * **When** `validate-module-coverage.sh` runs against valid fixture files
  * **Then** the script completes successfully without errors `And` produces correct coverage results using only `grep`, `sed`, `awk`, and Bash builtins

---

### Requirement Validation: REQ-NF-002 (Large Input Handling)

#### Test Case: ATP-NF-002-A (50+ ARCH Modules Processed)

**Linked Requirement:** REQ-NF-002
**Description:** Verify the commands handle input files with 50 or more ARCH-NNN identifiers without truncation.

* **User Scenario: SCN-NF-002-A1**
  * **Given** an `architecture-design.md` with 50 architecture modules (`ARCH-001` through `ARCH-050`)
  * **When** the user invokes `/speckit.v-model.module-design`
  * **Then** `module-design.md` contains MOD items covering all 50 ARCH modules `And` no data is truncated or lost

---

### Requirement Validation: REQ-NF-003 (Numbering Gap Tolerance)

#### Test Case: ATP-NF-003-A (Gaps in MOD Numbering Accepted)

**Linked Requirement:** REQ-NF-003
**Description:** Verify the validation script accepts gaps in MOD-NNN numbering without false positives.

* **User Scenario: SCN-NF-003-A1**
  * **Given** a `module-design.md` containing `MOD-001`, `MOD-003`, `MOD-005` (gaps at MOD-002 and MOD-004)
  * **When** `validate-module-coverage.sh` runs
  * **Then** it does not report MOD-002 or MOD-004 as missing `And` validates only the modules actually present against their ARCH parents

---

### Requirement Validation: REQ-NF-004 (Backward Compatibility)

#### Test Case: ATP-NF-004-A (Existing v0.3.0 Artifacts Unchanged)

**Linked Requirement:** REQ-NF-004
**Description:** Verify no v0.4.0 operation modifies existing v0.3.0 artifacts.

* **User Scenario: SCN-NF-004-A1**
  * **Given** existing `architecture-design.md`, `integration-test.md`, `system-design.md`, `system-test.md`, `requirements.md`, and `acceptance-plan.md` files with known checksums
  * **When** the user invokes `/speckit.v-model.module-design` and `/speckit.v-model.unit-test`
  * **Then** all pre-existing files retain their original checksums `And` no content has been modified

---

### Requirement Validation: REQ-NF-005 (CI Evaluation Suite Quality Gates)

#### Test Case: ATP-NF-005-A (Structural Quality Thresholds Met)

**Linked Requirement:** REQ-NF-005
**Description:** Verify the CI evaluation suite validates command output quality thresholds.

* **User Scenario: SCN-NF-005-A1**
  * **Given** generated `module-design.md` and `unit-test.md` from the CI evaluation suite
  * **When** the structural evaluation checks run
  * **Then** all checks pass: fenced `pseudocode` block presence for every non-EXTERNAL MOD, technique coverage for every UTP, Dependency & Mock Registry presence for every UTP, `[EXTERNAL]` bypass correctness, and State Machine View validity

---

### Requirement Validation: REQ-IF-001 (Module Design I/O Paths)

#### Test Case: ATP-IF-001-A (Reads from architecture-design.md, Writes to module-design.md)

**Linked Requirement:** REQ-IF-001
**Description:** Verify the module design command reads from and writes to the correct file paths.

* **User Scenario: SCN-IF-001-A1**
  * **Given** `{FEATURE_DIR}/v-model/architecture-design.md` exists with valid content
  * **When** the user invokes `/speckit.v-model.module-design`
  * **Then** the command reads exclusively from `{FEATURE_DIR}/v-model/architecture-design.md` `And` writes exclusively to `{FEATURE_DIR}/v-model/module-design.md`

---

### Requirement Validation: REQ-IF-002 (Unit Test I/O Paths)

#### Test Case: ATP-IF-002-A (Reads from module-design.md, Writes to unit-test.md)

**Linked Requirement:** REQ-IF-002
**Description:** Verify the unit test command reads from and writes to the correct file paths.

* **User Scenario: SCN-IF-002-A1**
  * **Given** `{FEATURE_DIR}/v-model/module-design.md` exists with valid content
  * **When** the user invokes `/speckit.v-model.unit-test`
  * **Then** the command reads exclusively from `{FEATURE_DIR}/v-model/module-design.md` `And` writes exclusively to `{FEATURE_DIR}/v-model/unit-test.md`

---

### Requirement Validation: REQ-IF-003 (Validation Script Arguments)

#### Test Case: ATP-IF-003-A (Three File Paths Accepted)

**Linked Requirement:** REQ-IF-003
**Description:** Verify `validate-module-coverage.sh` accepts three file paths as arguments.

* **User Scenario: SCN-IF-003-A1**
  * **Given** valid `architecture-design.md`, `module-design.md`, and `unit-test.md` files exist
  * **When** `validate-module-coverage.sh architecture-design.md module-design.md unit-test.md` runs
  * **Then** the script processes all three files and produces a complete coverage report

#### Test Case: ATP-IF-003-B (Partial Mode — Two Arguments)

**Linked Requirement:** REQ-IF-003
**Description:** Verify the script operates in partial validation mode when `unit-test.md` is omitted.

* **User Scenario: SCN-IF-003-B1**
  * **Given** valid `architecture-design.md` and `module-design.md` files exist
  * **When** `validate-module-coverage.sh architecture-design.md module-design.md` runs (two arguments only)
  * **Then** the script validates ARCH→MOD forward coverage only `And` does not attempt MOD→UTP backward checks

---

### Requirement Validation: REQ-IF-004 (Validation Output Format)

#### Test Case: ATP-IF-004-A (Consistent Output Format)

**Linked Requirement:** REQ-IF-004
**Description:** Verify the validation script output format matches `validate-architecture-coverage.sh` conventions.

* **User Scenario: SCN-IF-004-A1**
  * **Given** valid fixture files
  * **When** `validate-module-coverage.sh` runs
  * **Then** the output includes section headers, gap lists (if any), a pass/fail verdict, and coverage percentages `And` the format matches the structure of `validate-architecture-coverage.sh` output

---

### Requirement Validation: REQ-CN-001 (Safety-Critical Sections Conditional)

#### Test Case: ATP-CN-001-A (Safety Sections Omitted by Default)

**Linked Requirement:** REQ-CN-001
**Description:** Verify safety-critical sections are omitted when no regulated domain is configured.

* **User Scenario: SCN-CN-001-A1**
  * **Given** a project without a `v-model-config.yml` file (or with no regulated domain enabled)
  * **When** the user invokes `/speckit.v-model.module-design` and `/speckit.v-model.unit-test`
  * **Then** the module design output does not include "Complexity Constraints", "Memory Management", or "Single Entry/Exit" sections `And` the unit test output does not include MC/DC truth tables or variable-level fault injection scenarios

#### Test Case: ATP-CN-001-B (Safety Sections Included When Configured)

**Linked Requirement:** REQ-CN-001
**Description:** Verify safety-critical sections appear when a regulated domain is explicitly enabled.

* **User Scenario: SCN-CN-001-B1**
  * **Given** a `v-model-config.yml` exists with `domain: DO-178C` explicitly enabled
  * **When** the user invokes `/speckit.v-model.module-design` and `/speckit.v-model.unit-test`
  * **Then** the module design output includes "Complexity Constraints", "Memory Management", and "Single Entry/Exit" sections `And` the unit test output includes MC/DC and fault injection techniques

---

### Requirement Validation: REQ-CN-002 (Extension Version and Command Count)

#### Test Case: ATP-CN-002-A (extension.yml Updated Correctly)

**Linked Requirement:** REQ-CN-002
**Description:** Verify `extension.yml` is bumped to `0.4.0` with exactly 9 commands and 1 hook.

* **User Scenario: SCN-CN-002-A1**
  * **Given** the extension development is complete
  * **When** the user inspects `extension.yml`
  * **Then** the version field reads `0.4.0` `And` exactly 9 commands are registered (7 existing + module-design + unit-test) `And` exactly 1 hook is registered

---

### Requirement Validation: REQ-CN-003 (PowerShell Parity)

#### Test Case: ATP-CN-003-A (Identical Behavior and Output)

**Linked Requirement:** REQ-CN-003
**Description:** Verify `validate-module-coverage.ps1` produces identical behavior, output format, exit codes, `[EXTERNAL]` bypass logic, and partial validation support as the Bash script.

* **User Scenario: SCN-CN-003-A1**
  * **Given** identical test fixture files exist `And` both `validate-module-coverage.sh` and `validate-module-coverage.ps1` are available
  * **When** the user runs both scripts against the same fixture data
  * **Then** both scripts produce identical output text, identical coverage percentages, and identical exit codes (0 for pass, 1 for fail)

---

### Requirement Validation: REQ-CN-004 (Single Canonical EXTERNAL Tag)

#### Test Case: ATP-CN-004-A (Only EXTERNAL Tag Recognized)

**Linked Requirement:** REQ-CN-004
**Description:** Verify `[EXTERNAL]` is the only tag recognized for third-party bypass logic.

* **User Scenario: SCN-CN-004-A1**
  * **Given** a `module-design.md` with `MOD-010` tagged `[COTS]` (incorrect tag) instead of `[EXTERNAL]`
  * **When** `validate-module-coverage.sh` runs
  * **Then** the script does NOT bypass `MOD-010` for UTP requirements `And` it reports a missing UTP gap for `MOD-010` `And` exits with code 1

---

### Requirement Validation: REQ-CN-005 (PowerShell Matrix D Parity)

#### Test Case: ATP-CN-005-A (build-matrix.ps1 Matrix D Logic)

**Linked Requirement:** REQ-CN-005
**Description:** Verify `build-matrix.ps1` produces identical Matrix D output as `build-matrix.sh`.

* **User Scenario: SCN-CN-005-A1**
  * **Given** identical `architecture-design.md`, `module-design.md`, and `unit-test.md` files
  * **When** both `build-matrix.sh` and `build-matrix.ps1` generate Matrix D
  * **Then** both scripts produce identical Matrix D output with matching SYS annotations, MOD mappings, UTP/UTS linkages, and coverage percentages

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Requirements | 71 |
| Total Test Cases (ATP) | 85 |
| Total Scenarios (SCN) | 88 |
| REQ → ATP Coverage | 100% |
| ATP → SCN Coverage | 100% |

**Validation Status**: ✅ Full Coverage
**Generated**: 2026-02-21
**Validated by**: `validate-requirement-coverage.sh` (deterministic)

## Uncovered Requirements

None — full coverage achieved.
