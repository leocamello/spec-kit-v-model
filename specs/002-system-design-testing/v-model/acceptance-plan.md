# Acceptance Test Plan: System Design ↔ System Testing

**Feature Branch**: `002-system-design-testing`
**Created**: 2026-02-20
**Status**: Approved
**Source**: `specs/002-system-design-testing/v-model/requirements.md`

## Overview

This document defines the Acceptance Test Plan for the System Design ↔ System Testing feature (v0.2.0). Every requirement in `requirements.md` has one or more Test Cases (ATP), and every Test Case has one or more executable User Scenarios (SCN) in BDD format (Given/When/Then).

## ID Schema

- **Test Case**: `ATP-{NNN}-{X}` — where NNN matches the parent REQ, X is a letter suffix (A, B, C...)
- **Scenario**: `SCN-{NNN}-{X}{#}` — nested under the parent ATP, with numeric suffix (1, 2, 3...)
- Example: `SCN-001-A1` → Scenario 1 of Test Case A validating REQ-001

## Acceptance Tests

### Requirement Validation: REQ-001 (System Design Command Existence)

#### Test Case: ATP-001-A (Happy Path — Command Produces system-design.md)

**Linked Requirement:** REQ-001
**Description:** Verify the `/speckit.v-model.system-design` command reads `requirements.md` and produces `system-design.md` as output.

* **User Scenario: SCN-001-A1**
  * **Given** a `requirements.md` file exists in `{FEATURE_DIR}/v-model/` containing at least one `REQ-NNN` entry
  * **When** the user invokes `/speckit.v-model.system-design`
  * **Then** a `system-design.md` file is created in `{FEATURE_DIR}/v-model/` `And` the file is non-empty `And` contains at least one `SYS-NNN` identifier

#### Test Case: ATP-001-B (Error — Missing requirements.md)

**Linked Requirement:** REQ-001
**Description:** Verify the command fails gracefully when `requirements.md` does not exist.

* **User Scenario: SCN-001-B1**
  * **Given** the `{FEATURE_DIR}/v-model/` directory exists `And` no `requirements.md` file is present
  * **When** the user invokes `/speckit.v-model.system-design`
  * **Then** the command outputs an error message containing "requirements.md" `And` no `system-design.md` file is created

---

### Requirement Validation: REQ-002 (SYS-NNN Identifier Assignment)

#### Test Case: ATP-002-A (Sequential SYS-NNN Format)

**Linked Requirement:** REQ-002
**Description:** Verify each system component is assigned a unique `SYS-NNN` identifier in sequential order.

* **User Scenario: SCN-002-A1**
  * **Given** a `requirements.md` exists with 5 requirements (REQ-001 through REQ-005)
  * **When** the user invokes `/speckit.v-model.system-design`
  * **Then** every component in `system-design.md` has an ID matching the regex `^SYS-\d{3}$` `And` the first component is `SYS-001` `And` IDs are sequentially numbered with no gaps

#### Test Case: ATP-002-B (Identifier Permanence on Re-run)

**Linked Requirement:** REQ-002
**Description:** Verify that re-running the command does not renumber existing SYS-NNN identifiers.

* **User Scenario: SCN-002-B1**
  * **Given** a `system-design.md` exists containing `SYS-001`, `SYS-002`, `SYS-003` `And` `requirements.md` has been updated with two additional requirements
  * **When** the user invokes `/speckit.v-model.system-design`
  * **Then** the original `SYS-001`, `SYS-002`, `SYS-003` retain their identifiers `And` new components are appended as `SYS-004` or higher

---

### Requirement Validation: REQ-003 (Decomposition View Content)

#### Test Case: ATP-003-A (Required Fields Present)

**Linked Requirement:** REQ-003
**Description:** Verify `system-design.md` includes a Decomposition View with component name, description, and parent REQ-NNN identifiers.

* **User Scenario: SCN-003-A1**
  * **Given** a `requirements.md` exists with REQ-001 and REQ-002
  * **When** the user invokes `/speckit.v-model.system-design`
  * **Then** the `system-design.md` contains a section titled "Decomposition View" `And` each component entry includes a name, description, and a "Parent Requirements" field listing one or more `REQ-NNN` identifiers

---

### Requirement Validation: REQ-004 (Dependency View Content)

#### Test Case: ATP-004-A (Inter-Component Relationships Documented)

**Linked Requirement:** REQ-004
**Description:** Verify `system-design.md` includes a Dependency View documenting relationships and failure propagation.

* **User Scenario: SCN-004-A1**
  * **Given** a `system-design.md` has been generated with 3 or more `SYS-NNN` components
  * **When** the user inspects the Dependency View section
  * **Then** the section documents at least one inter-component relationship between `SYS-NNN` identifiers `And` includes failure propagation path descriptions

---

### Requirement Validation: REQ-005 (Interface View Content)

#### Test Case: ATP-005-A (API Contracts and Protocols Documented)

**Linked Requirement:** REQ-005
**Description:** Verify `system-design.md` includes an Interface View with API contracts, data formats, and communication protocols.

* **User Scenario: SCN-005-A1**
  * **Given** a `system-design.md` has been generated with components that expose interfaces
  * **When** the user inspects the Interface View section
  * **Then** the section documents API contracts, data formats, and communication protocols for each component's inputs and outputs

---

### Requirement Validation: REQ-006 (Data Design View Content)

#### Test Case: ATP-006-A (Data Structures and Protection Documented)

**Linked Requirement:** REQ-006
**Description:** Verify `system-design.md` includes a Data Design View with data structures, storage, and protection measures.

* **User Scenario: SCN-006-A1**
  * **Given** a `system-design.md` has been generated for a feature with data handling requirements
  * **When** the user inspects the Data Design View section
  * **Then** the section documents data structures, storage mechanisms, and data protection measures (at rest and in transit)

---

### Requirement Validation: REQ-007 (Parent Requirements Traceability)

#### Test Case: ATP-007-A (Every SYS-NNN Traces to REQ-NNN)

**Linked Requirement:** REQ-007
**Description:** Verify each `SYS-NNN` component explicitly references at least one parent `REQ-NNN` in the Decomposition View.

* **User Scenario: SCN-007-A1**
  * **Given** a `system-design.md` has been generated with 5 components (`SYS-001` to `SYS-005`)
  * **When** the user inspects each component's "Parent Requirements" field
  * **Then** every `SYS-NNN` entry lists at least one valid `REQ-NNN` identifier that exists in `requirements.md`

#### Test Case: ATP-007-B (Orphaned Component Detection)

**Linked Requirement:** REQ-007
**Description:** Verify that no component exists without a parent requirement reference.

* **User Scenario: SCN-007-B1**
  * **Given** a `system-design.md` has been generated
  * **When** a regex scan extracts all `SYS-NNN` identifiers and their corresponding "Parent Requirements" fields
  * **Then** no `SYS-NNN` component has an empty or missing "Parent Requirements" field

---

### Requirement Validation: REQ-008 (Many-to-Many REQ↔SYS Relationships)

#### Test Case: ATP-008-A (Single REQ Maps to Multiple SYS)

**Linked Requirement:** REQ-008
**Description:** Verify a single requirement can be decomposed into multiple system components.

* **User Scenario: SCN-008-A1**
  * **Given** a `requirements.md` contains a cross-cutting requirement (e.g., a security requirement REQ-NF-001)
  * **When** the user invokes `/speckit.v-model.system-design`
  * **Then** two or more `SYS-NNN` components list the same `REQ-NNN` as a parent requirement

#### Test Case: ATP-008-B (Single SYS Satisfies Multiple REQs)

**Linked Requirement:** REQ-008
**Description:** Verify a single system component can trace to multiple parent requirements.

* **User Scenario: SCN-008-B1**
  * **Given** a `requirements.md` contains requirements with overlapping scope (e.g., REQ-001 and REQ-002 both relate to the same subsystem)
  * **When** the user invokes `/speckit.v-model.system-design`
  * **Then** at least one `SYS-NNN` component lists two or more `REQ-NNN` identifiers in its "Parent Requirements" field

---

### Requirement Validation: REQ-009 (Non-Functional Requirements as Cross-Cutting Attributes)

#### Test Case: ATP-009-A (Non-Functional REQs Not Omitted)

**Linked Requirement:** REQ-009
**Description:** Verify non-functional requirements (performance, security, reliability) are addressed in the design views.

* **User Scenario: SCN-009-A1**
  * **Given** a `requirements.md` contains both functional requirements (REQ-001) and non-functional requirements (REQ-NF-001 for performance)
  * **When** the user invokes `/speckit.v-model.system-design`
  * **Then** the non-functional requirement appears as a cross-cutting quality attribute with explicit design decisions in the relevant IEEE 1016 views `And` is not silently omitted

---

### Requirement Validation: REQ-010 (System Test Command Existence)

#### Test Case: ATP-010-A (Happy Path — Command Produces system-test.md)

**Linked Requirement:** REQ-010
**Description:** Verify the `/speckit.v-model.system-test` command reads `system-design.md` and produces `system-test.md`.

* **User Scenario: SCN-010-A1**
  * **Given** a `system-design.md` file exists in `{FEATURE_DIR}/v-model/` containing at least one `SYS-NNN` component
  * **When** the user invokes `/speckit.v-model.system-test`
  * **Then** a `system-test.md` file is created in `{FEATURE_DIR}/v-model/` `And` the file contains at least one `STP-NNN-X` test case

#### Test Case: ATP-010-B (Error — Missing system-design.md)

**Linked Requirement:** REQ-010
**Description:** Verify the command fails gracefully when `system-design.md` does not exist.

* **User Scenario: SCN-010-B1**
  * **Given** the `{FEATURE_DIR}/v-model/` directory exists `And` no `system-design.md` file is present
  * **When** the user invokes `/speckit.v-model.system-test`
  * **Then** the command outputs an error message containing "system-design.md" `And` no `system-test.md` file is created

---

### Requirement Validation: REQ-011 (STP-NNN-X Identifier Format)

#### Test Case: ATP-011-A (Test Case IDs Match Format)

**Linked Requirement:** REQ-011
**Description:** Verify all system test case identifiers follow the `STP-NNN-X` format where NNN matches the parent SYS-NNN.

* **User Scenario: SCN-011-A1**
  * **Given** a `system-test.md` has been generated from a `system-design.md` containing `SYS-001` and `SYS-002`
  * **When** a regex scan extracts all test case identifiers
  * **Then** every test case ID matches the pattern `^STP-\d{3}-[A-Z]$` `And` the NNN portion matches a valid `SYS-NNN` from `system-design.md`

---

### Requirement Validation: REQ-012 (STS-NNN-X# Scenario Identifier Format)

#### Test Case: ATP-012-A (Scenario IDs Match Format)

**Linked Requirement:** REQ-012
**Description:** Verify all system test scenario identifiers follow the `STS-NNN-X#` format.

* **User Scenario: SCN-012-A1**
  * **Given** a `system-test.md` has been generated containing test cases `STP-001-A` and `STP-001-B`
  * **When** a regex scan extracts all scenario identifiers
  * **Then** every scenario ID matches the pattern `^STS-\d{3}-[A-Z]\d+$` `And` the NNN-X portion matches a valid `STP-NNN-X` from the same file

---

### Requirement Validation: REQ-013 (IEEE 1016 Design View Reference in Test Cases)

#### Test Case: ATP-013-A (Each STP References a Design View)

**Linked Requirement:** REQ-013
**Description:** Verify each system test case explicitly references which IEEE 1016 design view it targets.

* **User Scenario: SCN-013-A1**
  * **Given** a `system-test.md` has been generated with test cases for multiple `SYS-NNN` components
  * **When** the user inspects each `STP-NNN-X` test case entry
  * **Then** every test case includes a field referencing one of: Decomposition View, Dependency View, Interface View, or Data Design View

---

### Requirement Validation: REQ-014 (ISO 29119 Test Technique Application)

#### Test Case: ATP-014-A (Named Technique Applied)

**Linked Requirement:** REQ-014
**Description:** Verify each system test case applies a named ISO 29119 test technique.

* **User Scenario: SCN-014-A1**
  * **Given** a `system-test.md` has been generated
  * **When** the user inspects each `STP-NNN-X` test case
  * **Then** every test case identifies a specific ISO 29119 technique: Interface Contract Testing, Boundary Value Analysis, Equivalence Partitioning, or Fault Injection / Negative Testing

---

### Requirement Validation: REQ-015 (External vs Internal Interface Distinction)

#### Test Case: ATP-015-A (Interface Contract Tests Distinguish External from Internal)

**Linked Requirement:** REQ-015
**Description:** Verify interface contract test cases explicitly distinguish between external system interfaces and internal component interfaces.

* **User Scenario: SCN-015-A1**
  * **Given** a `system-design.md` contains components with both external interfaces (user-facing API) and internal interfaces (inter-module communication)
  * **When** the user invokes `/speckit.v-model.system-test`
  * **Then** interface contract test cases are labeled as either "External Interface" or "Internal Interface" `And` external tests focus on protocol compliance `And` internal tests focus on contract adherence and failure propagation

---

### Requirement Validation: REQ-016 (Technical BDD Language in System Test Scenarios)

#### Test Case: ATP-016-A (Component-Oriented Language Used)

**Linked Requirement:** REQ-016
**Description:** Verify system test scenarios use technical, component-oriented Given/When/Then language distinct from user-centric acceptance scenarios.

* **User Scenario: SCN-016-A1**
  * **Given** a `system-test.md` has been generated with `STS-NNN-X#` scenarios
  * **When** the user inspects the Given/When/Then steps of each scenario
  * **Then** scenarios reference technical concepts (e.g., "database connection pool", "error code 503", "response time within 200ms") rather than user actions (e.g., "the user clicks", "the user sees")

#### Test Case: ATP-016-B (No User-Centric Language in STS Scenarios)

**Linked Requirement:** REQ-016
**Description:** Verify STS scenarios do not contain user-journey language reserved for SCN scenarios.

* **User Scenario: SCN-016-B1**
  * **Given** a `system-test.md` has been generated
  * **When** a text search scans all `STS-NNN-X#` scenario steps for user-centric phrases ("the user clicks", "the user sees", "the user navigates")
  * **Then** zero matches are found — all STS scenarios use component-oriented technical language

---

### Requirement Validation: REQ-017 (Coverage Gate Invocation)

#### Test Case: ATP-017-A (Script Invoked and Result Included)

**Linked Requirement:** REQ-017
**Description:** Verify the system-test command invokes `validate-system-coverage.sh` after generation and includes the result.

* **User Scenario: SCN-017-A1**
  * **Given** a `system-design.md` exists with `SYS-001` and `SYS-002`
  * **When** the user invokes `/speckit.v-model.system-test`
  * **Then** the command output includes a coverage validation summary with pass/fail status `And` coverage percentages for both forward (REQ→SYS) and backward (SYS→STP) coverage

---

### Requirement Validation: REQ-018 (Forward Coverage Validation (REQ→SYS))

#### Test Case: ATP-018-A (Full Forward Coverage)

**Linked Requirement:** REQ-018
**Description:** Verify the script confirms every REQ-NNN has at least one corresponding SYS-NNN.

* **User Scenario: SCN-018-A1**
  * **Given** a `requirements.md` with REQ-001, REQ-002, REQ-003 `And` a `system-design.md` where every REQ is referenced by at least one SYS-NNN
  * **When** the user runs `validate-system-coverage.sh`
  * **Then** the script reports 100% forward coverage `And` exits with code 0

#### Test Case: ATP-018-B (Missing Forward Coverage Detected)

**Linked Requirement:** REQ-018
**Description:** Verify the script detects when a requirement has no corresponding system component.

* **User Scenario: SCN-018-B1**
  * **Given** a `requirements.md` with REQ-001, REQ-002, REQ-003 `And` a `system-design.md` where SYS components reference only REQ-001 and REQ-002
  * **When** the user runs `validate-system-coverage.sh`
  * **Then** the script reports REQ-003 has no system component mapping `And` exits with code 1

---

### Requirement Validation: REQ-019 (Backward Coverage Validation (SYS→STP))

#### Test Case: ATP-019-A (Full Backward Coverage)

**Linked Requirement:** REQ-019
**Description:** Verify the script confirms every SYS-NNN has at least one corresponding STP-NNN-X.

* **User Scenario: SCN-019-A1**
  * **Given** a `system-design.md` with SYS-001, SYS-002 `And` a `system-test.md` where every SYS has at least one STP test case
  * **When** the user runs `validate-system-coverage.sh`
  * **Then** the script reports 100% backward coverage `And` exits with code 0

#### Test Case: ATP-019-B (Missing Backward Coverage Detected)

**Linked Requirement:** REQ-019
**Description:** Verify the script detects when a system component has no corresponding test case.

* **User Scenario: SCN-019-B1**
  * **Given** a `system-design.md` with SYS-001, SYS-002, SYS-003 `And` a `system-test.md` with test cases for SYS-001 and SYS-002 only
  * **When** the user runs `validate-system-coverage.sh`
  * **Then** the script reports SYS-003 has no test case mapping `And` exits with code 1

---

### Requirement Validation: REQ-020 (Orphaned Identifier Detection)

#### Test Case: ATP-020-A (Orphaned SYS-NNN Without Parent REQ)

**Linked Requirement:** REQ-020
**Description:** Verify the script detects SYS-NNN components not referenced by any REQ-NNN.

* **User Scenario: SCN-020-A1**
  * **Given** a `system-design.md` with SYS-001 (parent: REQ-001) and SYS-002 (parent: REQ-999) `And` `requirements.md` does not contain REQ-999
  * **When** the user runs `validate-system-coverage.sh`
  * **Then** the script reports SYS-002 as an orphaned component `And` exits with code 1

#### Test Case: ATP-020-B (Orphaned STP-NNN-X Without Parent SYS)

**Linked Requirement:** REQ-020
**Description:** Verify the script detects STP-NNN-X test cases whose parent SYS-NNN does not exist.

* **User Scenario: SCN-020-B1**
  * **Given** a `system-test.md` with STP-001-A (parent: SYS-001) and STP-099-A (parent: SYS-099) `And` `system-design.md` does not contain SYS-099
  * **When** the user runs `validate-system-coverage.sh`
  * **Then** the script reports STP-099-A as an orphaned test case `And` exits with code 1

---

### Requirement Validation: REQ-021 (Exit Code Behavior)

#### Test Case: ATP-021-A (Exit 0 on Full Coverage)

**Linked Requirement:** REQ-021
**Description:** Verify the script exits with code 0 when all coverage checks pass.

* **User Scenario: SCN-021-A1**
  * **Given** all requirements have system components `And` all components have test cases `And` no orphaned identifiers exist
  * **When** the user runs `validate-system-coverage.sh`
  * **Then** the script exits with code 0

#### Test Case: ATP-021-B (Exit 1 on Any Gap)

**Linked Requirement:** REQ-021
**Description:** Verify the script exits with code 1 when any coverage gap or orphan is detected.

* **User Scenario: SCN-021-B1**
  * **Given** one requirement (REQ-003) has no corresponding system component
  * **When** the user runs `validate-system-coverage.sh`
  * **Then** the script exits with code 1 `And` the output identifies REQ-003 as the gap

---

### Requirement Validation: REQ-022 (Human-Readable Gap Reports)

#### Test Case: ATP-022-A (Specific Gap Identification by ID)

**Linked Requirement:** REQ-022
**Description:** Verify the script outputs gap reports listing each specific gap by ID.

* **User Scenario: SCN-022-A1**
  * **Given** a `requirements.md` with REQ-001 through REQ-005 `And` `system-design.md` missing coverage for REQ-003 and REQ-005
  * **When** the user runs `validate-system-coverage.sh`
  * **Then** the output contains lines identifying "REQ-003" and "REQ-005" as having no system component mapping `And` the output is human-readable (not raw JSON) suitable for CI log inspection

---

### Requirement Validation: REQ-023 (Machine-Parseable Lineage Encoding)

#### Test Case: ATP-023-A (Regex Extraction of Full Lineage)

**Linked Requirement:** REQ-023
**Description:** Verify that given any STS-NNN-X# identifier, a regex can extract the parent STP, grandparent SYS, and great-grandparent REQ.

* **User Scenario: SCN-023-A1**
  * **Given** a `system-test.md` containing the scenario identifier `STS-003-B2`
  * **When** a regex is applied to extract the lineage: `STS-(\d{3})-([A-Z])(\d+)`
  * **Then** the extracted values yield parent `STP-003-B`, grandparent `SYS-003`, and (via the system design) the great-grandparent `REQ-NNN` identifiers `And` no lookup table or external file is consulted

---

### Requirement Validation: REQ-024 (Matrix B (Verification) Generation)

#### Test Case: ATP-024-A (Matrix B Produced When System Artifacts Exist)

**Linked Requirement:** REQ-024
**Description:** Verify the trace command produces Matrix B (REQ → SYS → STP → STS) when `system-design.md` and `system-test.md` exist.

* **User Scenario: SCN-024-A1**
  * **Given** a feature directory contains `requirements.md`, `acceptance-plan.md`, `system-design.md`, and `system-test.md`
  * **When** the user invokes `/speckit.v-model.trace`
  * **Then** the generated `traceability-matrix.md` contains a table titled "Matrix B (Verification)" with columns for REQ, SYS, STP, and STS identifiers

---

### Requirement Validation: REQ-025 (Matrix A (Validation) Separate from Matrix B)

#### Test Case: ATP-025-A (Two Distinct Tables)

**Linked Requirement:** REQ-025
**Description:** Verify Matrix A (REQ → ATP → SCN) is rendered as a separate table from Matrix B to prevent visual bloat.

* **User Scenario: SCN-025-A1**
  * **Given** a feature directory contains all V-Model artifacts (requirements, acceptance plan, system design, system test)
  * **When** the user invokes `/speckit.v-model.trace`
  * **Then** the generated `traceability-matrix.md` contains two distinct tables: "Matrix A (Validation)" with REQ/ATP/SCN columns `And` "Matrix B (Verification)" with REQ/SYS/STP/STS columns `And` the tables are not merged into a single wide table

---

### Requirement Validation: REQ-026 (Trace Command Backward Compatibility)

#### Test Case: ATP-026-A (Matrix A Only When System Artifacts Absent)

**Linked Requirement:** REQ-026
**Description:** Verify the trace command produces only Matrix A when `system-design.md` and `system-test.md` are absent.

* **User Scenario: SCN-026-A1**
  * **Given** a feature directory contains `requirements.md` and `acceptance-plan.md` but no `system-design.md` or `system-test.md`
  * **When** the user invokes `/speckit.v-model.trace`
  * **Then** the generated `traceability-matrix.md` contains only Matrix A (Validation) `And` no Matrix B section exists `And` the output is identical to v0.1.0 behavior

---

### Requirement Validation: REQ-027 (Coverage Percentages Match Script Output)

#### Test Case: ATP-027-A (Matrix Coverage Matches Deterministic Script)

**Linked Requirement:** REQ-027
**Description:** Verify each matrix includes a coverage percentage that matches the corresponding validation script output.

* **User Scenario: SCN-027-A1**
  * **Given** a complete set of V-Model artifacts exists `And` `validate-requirement-coverage.sh` reports 100% for Matrix A `And` `validate-system-coverage.sh` reports 95% for Matrix B
  * **When** the user invokes `/speckit.v-model.trace`
  * **Then** the Matrix A coverage percentage in `traceability-matrix.md` equals 100% `And` the Matrix B coverage percentage equals 95% `And` both match the script outputs exactly

---

### Requirement Validation: REQ-028 (build-matrix.sh Extended for Matrix B)

#### Test Case: ATP-028-A (Parses System Design and System Test Files)

**Linked Requirement:** REQ-028
**Description:** Verify `build-matrix.sh` can parse `system-design.md` and `system-test.md` to generate Matrix B data.

* **User Scenario: SCN-028-A1**
  * **Given** a `system-design.md` exists with SYS-001, SYS-002 `And` a `system-test.md` exists with STP-001-A, STP-002-A and their STS scenarios
  * **When** the user runs `build-matrix.sh` with the feature directory path
  * **Then** the script outputs Matrix B data with correct REQ → SYS → STP → STS linkage for each entry

---

### Requirement Validation: REQ-029 (build-matrix.ps1 Parity)

#### Test Case: ATP-029-A (Identical Matrix B Output)

**Linked Requirement:** REQ-029
**Description:** Verify `build-matrix.ps1` produces identical Matrix B output to `build-matrix.sh` for the same input.

* **User Scenario: SCN-029-A1**
  * **Given** identical `system-design.md` and `system-test.md` files exist `And` both `build-matrix.sh` (Bash) and `build-matrix.ps1` (PowerShell) are available
  * **When** the user runs both scripts against the same feature directory
  * **Then** the Matrix B output from both scripts is identical in structure, content, and coverage percentages

---

### Requirement Validation: REQ-030 (System Design Template Exists)

#### Test Case: ATP-030-A (Template Available in templates/ Directory)

**Linked Requirement:** REQ-030
**Description:** Verify the extension provides `system-design-template.md` in the `templates/` directory with IEEE 1016-compliant structure.

* **User Scenario: SCN-030-A1**
  * **Given** the extension is installed
  * **When** the user inspects `templates/system-design-template.md`
  * **Then** the file exists `And` contains section headers for Decomposition View, Dependency View, Interface View, and Data Design View `And` includes placeholder fields for SYS-NNN, component name, description, and parent REQ-NNN identifiers

---

### Requirement Validation: REQ-031 (System Test Template Exists)

#### Test Case: ATP-031-A (Template Available with Three-Tier Structure)

**Linked Requirement:** REQ-031
**Description:** Verify the extension provides `system-test-template.md` with ISO 29119-compliant three-tier STP/STS hierarchy.

* **User Scenario: SCN-031-A1**
  * **Given** the extension is installed
  * **When** the user inspects `templates/system-test-template.md`
  * **Then** the file exists `And` contains placeholder structure for `STP-NNN-X` test cases with linked `SYS-NNN`, design view reference, ISO 29119 technique, and nested `STS-NNN-X#` scenarios in Given/When/Then format

---

### Requirement Validation: REQ-032 (Strict Translator — System Design Command)

#### Test Case: ATP-032-A (No Invented Components)

**Linked Requirement:** REQ-032
**Description:** Verify the system design command does not add system components for capabilities not present in `requirements.md`.

* **User Scenario: SCN-032-A1**
  * **Given** a `requirements.md` contains exactly 3 requirements: REQ-001 (authentication), REQ-002 (logging), REQ-003 (API endpoint)
  * **When** the user invokes `/speckit.v-model.system-design`
  * **Then** the `system-design.md` contains components that trace only to REQ-001, REQ-002, and REQ-003 `And` no component references a capability (e.g., caching, analytics) not present in the requirements

#### Test Case: ATP-032-B (Hallucinated Component Absent)

**Linked Requirement:** REQ-032
**Description:** Verify no "nice-to-have" components are invented by the AI.

* **User Scenario: SCN-032-B1**
  * **Given** a `requirements.md` with no mention of caching, monitoring, or analytics
  * **When** the user invokes `/speckit.v-model.system-design` `And` inspects the Decomposition View
  * **Then** no component related to caching, monitoring, or analytics exists in the output

---

### Requirement Validation: REQ-033 (Strict Translator — System Test Command)

#### Test Case: ATP-033-A (No Invented Test Cases)

**Linked Requirement:** REQ-033
**Description:** Verify the system test command does not create test cases for components not present in `system-design.md`.

* **User Scenario: SCN-033-A1**
  * **Given** a `system-design.md` contains exactly 2 components: SYS-001 and SYS-002
  * **When** the user invokes `/speckit.v-model.system-test`
  * **Then** the `system-test.md` contains test cases only for SYS-001 and SYS-002 `And` no test case references a SYS-003 or any component not in the design

---

### Requirement Validation: REQ-034 (Derived Requirement Flagging)

#### Test Case: ATP-034-A (Flag Displayed Instead of Silent Addition)

**Linked Requirement:** REQ-034
**Description:** Verify the system design command flags derived requirements instead of silently adding SYS-NNN components.

* **User Scenario: SCN-034-A1**
  * **Given** a `requirements.md` that does not mention database connection pooling `And` the design process determines that connection pooling is technically necessary
  * **When** the user invokes `/speckit.v-model.system-design`
  * **Then** the output contains a `[DERIVED REQUIREMENT: database connection pooling needed for performance]` flag `And` no `SYS-NNN` component is created for connection pooling without the flag

---

### Requirement Validation: REQ-035 (Safety-Critical System Design Sections (FFI + Restricted Complexity)) — [SUSPECT — Parent REQ-035 deprecated]

#### Test Case: ATP-035-A (Sections Generated When Regulated Domain Enabled) [DEPRECATED — Superseded by ATP-038-A]

**Linked Requirement:** REQ-035 [DEPRECATED — Superseded by REQ-038]
**Description:** ~~Verify FFI analysis and Restricted Complexity sections are generated when `v-model-config.yml` enables a regulated domain.~~ Superseded by ATP-038-A which tests overlay-based domain loading.
**Validation Condition:** ~~FFI and Restricted Complexity sections present when regulated domain is configured.~~
**Expected Result:** ~~Domain-specific design sections generated for each SYS-NNN component.~~

* **User Scenario: SCN-035-A1** [DEPRECATED — Superseded by SCN-038-A1]
  * ~~**Given** a `v-model-config.yml` exists with `domain: iso_26262` `And` a valid `requirements.md` exists~~
  * ~~**When** the user invokes `/speckit.v-model.system-design`~~
  * ~~**Then** the `system-design.md` contains a "Freedom from Interference (FFI)" analysis section `And` a "Restricted Complexity" assessment section for each `SYS-NNN` component~~

#### Test Case: ATP-035-B (Sections Absent When Domain Not Configured) [DEPRECATED — Superseded by ATP-038-B]

**Linked Requirement:** REQ-035 [DEPRECATED — Superseded by REQ-038]
**Description:** ~~Verify safety-critical sections are omitted when no regulated domain is configured.~~ Superseded by ATP-038-B which tests graceful fallback.
**Validation Condition:** ~~Safety-critical sections absent when no domain configured.~~
**Expected Result:** ~~No FFI or Restricted Complexity sections in output.~~

* **User Scenario: SCN-035-B1** [DEPRECATED — Superseded by SCN-038-B1]
  * ~~**Given** no `v-model-config.yml` exists in the project `Or` the config does not specify a regulated domain~~
  * ~~**When** the user invokes `/speckit.v-model.system-design`~~
  * ~~**Then** the `system-design.md` does not contain "Freedom from Interference" or "Restricted Complexity" sections~~

---

### Requirement Validation: REQ-036 (Safety-Critical System Test Sections (MC/DC + WCET)) — [SUSPECT — Parent REQ-036 deprecated]

#### Test Case: ATP-036-A (Sections Generated When Regulated Domain Enabled) [DEPRECATED — Superseded by ATP-039-A]

**Linked Requirement:** REQ-036 [DEPRECATED — Superseded by REQ-039]
**Description:** ~~Verify MC/DC test obligations and WCET verification scenarios are generated when `v-model-config.yml` enables a regulated domain.~~ Superseded by ATP-039-A which tests overlay-based domain loading.
**Validation Condition:** ~~MC/DC and WCET sections present when regulated domain is configured.~~
**Expected Result:** ~~Domain-specific test sections generated for applicable STP-NNN-X test cases.~~

* **User Scenario: SCN-036-A1** [DEPRECATED — Superseded by SCN-039-A1]
  * ~~**Given** a `v-model-config.yml` exists with `domain: do_178c` `And` a valid `system-design.md` exists~~
  * ~~**When** the user invokes `/speckit.v-model.system-test`~~
  * ~~**Then** the `system-test.md` contains "MC/DC Coverage" test obligations `And` "WCET Verification" scenarios for applicable `STP-NNN-X` test cases~~

#### Test Case: ATP-036-B (Sections Absent When Domain Not Configured) [DEPRECATED — Superseded by ATP-039-B]

**Linked Requirement:** REQ-036 [DEPRECATED — Superseded by REQ-039]
**Description:** ~~Verify safety-critical test sections are omitted when no regulated domain is configured.~~ Superseded by ATP-039-B which tests graceful fallback.
**Validation Condition:** ~~Safety-critical test sections absent when no domain configured.~~
**Expected Result:** ~~No MC/DC or WCET sections in output.~~

* **User Scenario: SCN-036-B1** [DEPRECATED — Superseded by SCN-039-B1]
  * ~~**Given** no `v-model-config.yml` exists in the project `Or` the config does not specify a regulated domain~~
  * ~~**When** the user invokes `/speckit.v-model.system-test`~~
  * ~~**Then** the `system-test.md` does not contain "MC/DC Coverage" or "WCET Verification" sections~~

---

### Requirement Validation: REQ-NF-001 (Regex-Based Parsing (No External Tooling))

#### Test Case: ATP-NF-001-A (Script Uses Only Bash Builtins and Standard Utilities)

**Linked Requirement:** REQ-NF-001
**Description:** Verify `validate-system-coverage.sh` uses regex-based parsing with no runtime database or external tooling beyond standard Bash utilities.

* **User Scenario: SCN-NF-001-A1**
  * **Given** the `validate-system-coverage.sh` script exists
  * **When** the user inspects the script source code for external dependencies (e.g., `python`, `node`, `jq`, database clients)
  * **Then** the script uses only Bash builtins, `grep`, `sed`, `awk`, and standard POSIX utilities `And` no external runtime dependencies are required

---

### Requirement Validation: REQ-NF-002 (Large Input Handling (200+ REQs))

#### Test Case: ATP-NF-002-A (No Truncation with 200 Requirements)

**Linked Requirement:** REQ-NF-002
**Description:** Verify the commands handle input files with 200+ REQ-NNN identifiers without truncation or data loss.

* **User Scenario: SCN-NF-002-A1**
  * **Given** a `requirements.md` exists with 200 requirements (REQ-001 through REQ-200)
  * **When** the user invokes `/speckit.v-model.system-design`
  * **Then** the `system-design.md` references all 200 requirements `And` no requirement is truncated or omitted from the output

---

### Requirement Validation: REQ-NF-003 (Gap Tolerance in SYS-NNN Numbering)

#### Test Case: ATP-NF-003-A (Gaps Accepted Without False Positives)

**Linked Requirement:** REQ-NF-003
**Description:** Verify the validation script accepts gaps in SYS-NNN numbering without reporting errors.

* **User Scenario: SCN-NF-003-A1**
  * **Given** a `system-design.md` contains SYS-001, SYS-003, SYS-005 (gaps at SYS-002 and SYS-004) `And` all three components have valid parent REQs and test cases
  * **When** the user runs `validate-system-coverage.sh`
  * **Then** the script reports 100% coverage `And` does not flag the gaps as errors `And` exits with code 0

---

### Requirement Validation: REQ-NF-004 (Backward Compatibility with v0.1.0 Artifacts)

#### Test Case: ATP-NF-004-A (Existing v0.1.0 Files Unchanged)

**Linked Requirement:** REQ-NF-004
**Description:** Verify v0.2.0 operations do not modify existing `requirements.md`, `acceptance-plan.md`, or `traceability-matrix.md` files.

* **User Scenario: SCN-NF-004-A1**
  * **Given** a feature directory contains v0.1.0 artifacts: `requirements.md` (checksum A), `acceptance-plan.md` (checksum B), `traceability-matrix.md` (checksum C)
  * **When** the user runs all v0.2.0 commands (`/speckit.v-model.system-design`, `/speckit.v-model.system-test`)
  * **Then** the checksums of `requirements.md`, `acceptance-plan.md`, and `traceability-matrix.md` remain identical to their pre-operation values (A, B, C)

---

### Requirement Validation: REQ-NF-005 (Internal QA Gate — CI Evaluation Suite)

#### Test Case: ATP-NF-005-A (Evaluation Suite Validates Command Output Quality)

**Linked Requirement:** REQ-NF-005
**Description:** (Internal QA gate — not user-facing) Verify the CI evaluation suite validates that new command outputs meet quality thresholds.

* **User Scenario: SCN-NF-005-A1**
  * **Given** the `evals.yml` CI workflow is configured `And` golden example outputs exist for `/speckit.v-model.system-design` and `/speckit.v-model.system-test`
  * **When** the evaluation suite runs via `pytest tests/evals/ -m eval`
  * **Then** the system design quality score meets or exceeds the threshold established for v0.1.0 artifacts `And` the system test quality score meets or exceeds the same threshold `And` all structural compliance checks pass

---

### Requirement Validation: REQ-IF-001 (System Design Command File I/O Paths)

#### Test Case: ATP-IF-001-A (Reads from requirements.md, Writes to system-design.md)

**Linked Requirement:** REQ-IF-001
**Description:** Verify the system design command reads exclusively from the correct input path and writes to the correct output path.

* **User Scenario: SCN-IF-001-A1**
  * **Given** a feature directory `specs/002-system-design-testing/` exists with `v-model/requirements.md`
  * **When** the user invokes `/speckit.v-model.system-design`
  * **Then** the command reads from `{FEATURE_DIR}/v-model/requirements.md` `And` writes output to `{FEATURE_DIR}/v-model/system-design.md` `And` no other files in the feature directory are created or modified

---

### Requirement Validation: REQ-IF-002 (System Test Command File I/O Paths)

#### Test Case: ATP-IF-002-A (Reads from system-design.md, Writes to system-test.md)

**Linked Requirement:** REQ-IF-002
**Description:** Verify the system test command reads exclusively from the correct input path and writes to the correct output path.

* **User Scenario: SCN-IF-002-A1**
  * **Given** a feature directory exists with `v-model/system-design.md`
  * **When** the user invokes `/speckit.v-model.system-test`
  * **Then** the command reads from `{FEATURE_DIR}/v-model/system-design.md` `And` writes output to `{FEATURE_DIR}/v-model/system-test.md` `And` no other files in the feature directory are created or modified

---

### Requirement Validation: REQ-IF-003 (Validation Script Argument Convention)

#### Test Case: ATP-IF-003-A (Accepts Three File Paths as Arguments)

**Linked Requirement:** REQ-IF-003
**Description:** Verify `validate-system-coverage.sh` accepts three file paths: requirements.md, system-design.md, system-test.md.

* **User Scenario: SCN-IF-003-A1**
  * **Given** the three V-Model files exist at known paths
  * **When** the user runs `validate-system-coverage.sh /path/to/requirements.md /path/to/system-design.md /path/to/system-test.md`
  * **Then** the script executes successfully `And` validates coverage using the provided file paths

---

### Requirement Validation: REQ-IF-004 (Validation Script Output Format)

#### Test Case: ATP-IF-004-A (Consistent Format with validate-requirement-coverage.sh)

**Linked Requirement:** REQ-IF-004
**Description:** Verify `validate-system-coverage.sh` output matches the format of `validate-requirement-coverage.sh` (section headers, gap lists, pass/fail verdict).

* **User Scenario: SCN-IF-004-A1**
  * **Given** a set of V-Model artifacts with known coverage gaps exists
  * **When** the user runs `validate-system-coverage.sh`
  * **Then** the output contains section headers (e.g., "Forward Coverage", "Backward Coverage"), gap lists with specific IDs, a pass/fail verdict, and coverage percentages `And` the format is consistent with `validate-requirement-coverage.sh` output

---

### Requirement Validation: REQ-CN-001 (Safety-Critical Sections Omitted by Default) — [SUSPECT — Parent REQ-CN-001 deprecated]

#### Test Case: ATP-CN-001-A (No Safety Sections Without Config) [DEPRECATED — Superseded by ATP-042-A]

**Linked Requirement:** REQ-CN-001 [DEPRECATED — Superseded by REQ-042]
**Description:** ~~Verify safety-critical sections (FFI, Restricted Complexity, MC/DC, WCET) are omitted when no regulated domain is configured.~~ Superseded by ATP-042-A which tests general-purpose output without overlays.
**Validation Condition:** ~~Safety-critical sections absent when no domain configured.~~
**Expected Result:** ~~No FFI, Restricted Complexity, MC/DC, or WCET sections in output.~~

* **User Scenario: SCN-CN-001-A1** [DEPRECATED — Superseded by SCN-042-A1]
  * ~~**Given** no `v-model-config.yml` exists `Or` the file does not contain a `domain` field~~
  * ~~**When** the user invokes `/speckit.v-model.system-design` and `/speckit.v-model.system-test`~~
  * ~~**Then** neither `system-design.md` nor `system-test.md` contains sections for FFI, Restricted Complexity, MC/DC, or WCET~~

#### Test Case: ATP-CN-001-B (Sections Present Only When Explicitly Enabled) [DEPRECATED — Superseded by ATP-042-B]

**Linked Requirement:** REQ-CN-001 [DEPRECATED — Superseded by REQ-042]
**Description:** ~~Verify sections appear only when a specific regulated domain is configured.~~ Superseded by ATP-042-B which tests overlay-gated section presence.
**Validation Condition:** ~~Sections present only when domain explicitly configured.~~
**Expected Result:** ~~Domain-specific sections populated with component-specific analysis.~~

* **User Scenario: SCN-CN-001-B1** [DEPRECATED — Superseded by SCN-042-B1]
  * ~~**Given** a `v-model-config.yml` exists with `domain: iso_26262`~~
  * ~~**When** the user invokes `/speckit.v-model.system-design`~~
  * ~~**Then** the `system-design.md` contains FFI and Restricted Complexity sections `And` these sections are populated with component-specific analysis~~

---

### Requirement Validation: REQ-CN-002 (Extension Version and Command Count)

#### Test Case: ATP-CN-002-A (Version Bumped to 0.2.0 with Correct Command Count)

**Linked Requirement:** REQ-CN-002
**Description:** Verify `extension.yml` is bumped to v0.2.0 with exactly 5 commands and 1 hook registered.

* **User Scenario: SCN-CN-002-A1**
  * **Given** all v0.2.0 implementation is complete
  * **When** the user inspects `extension.yml`
  * **Then** the version field reads `0.2.0` `And` exactly 5 commands are registered (3 existing: requirements, acceptance, trace + 2 new: system-design, system-test) `And` 1 hook is registered

---

### Requirement Validation: REQ-CN-003 (PowerShell Script Parity)

#### Test Case: ATP-CN-003-A (Identical Behavior and Output)

**Linked Requirement:** REQ-CN-003
**Description:** Verify `validate-system-coverage.ps1` produces identical behavior, output format, and exit codes as the Bash script.

* **User Scenario: SCN-CN-003-A1**
  * **Given** identical test fixture files exist `And` both `validate-system-coverage.sh` and `validate-system-coverage.ps1` are available
  * **When** the user runs both scripts against the same fixture data
  * **Then** both scripts produce identical output text, identical coverage percentages, and identical exit codes (0 for pass, 1 for fail)

---

### Requirement Validation: REQ-037 (Partial Validation — v0.2.1 patch)

#### Test Case: ATP-037-A (Forward-Only Validation When system-test.md Absent)

**Linked Requirement:** REQ-037
**Description:** Verify the script validates forward coverage (REQ→SYS) only when `system-test.md` is absent and exits with code 0 if forward coverage is complete.

* **User Scenario: SCN-037-A1**
  * **Given** a feature directory contains `requirements.md` with REQ-001 through REQ-005 `And` `system-design.md` with SYS-001 through SYS-005 covering all REQs `And` `system-test.md` does NOT exist
  * **When** the user runs `validate-system-coverage.sh`
  * **Then** the script exits with code 0 `And` the output indicates "Partial mode" `And` forward coverage is reported as 100% `And` SYS→STP→STS checks are skipped

#### Test Case: ATP-037-B (Partial Mode Reports Forward Gaps)

**Linked Requirement:** REQ-037
**Description:** Verify the script detects forward coverage gaps even in partial mode.

* **User Scenario: SCN-037-B1**
  * **Given** a feature directory contains `requirements.md` with REQ-001 through REQ-005 `And` `system-design.md` covering only REQ-001 through REQ-003 `And` `system-test.md` does NOT exist
  * **When** the user runs `validate-system-coverage.sh`
  * **Then** the script exits with code 1 `And` the output identifies REQ-004 and REQ-005 as having no system component mapping `And` backward coverage checks are still skipped

---

### Requirement Validation: REQ-038 (Domain Overlay Loading for System Design)

#### Test Case: ATP-038-A (Overlay loaded when domain is set)
**Linked Requirement:** REQ-038
**Description:** Verify the command loads the domain overlay and uses its safety-critical design sections when `v-model-config.yml` specifies a `domain` value.
**Validation Condition:** Domain overlay file is read and domain-specific design sections appear in the output.
**Expected Result:** Domain-specific design sections (e.g., FFI for iso_26262) are used instead of the base general-purpose sections.

* **User Scenario: SCN-038-A1**
  * **Given** a project with `v-model-config.yml` containing `domain: iso_26262` and an overlay at `commands/overlays/iso_26262/system-design.md`
  * **When** `/speckit.v-model.system-design` runs
  * **Then** the `system-design.md` contains FFI, Restricted Complexity, and Safety Integrity Allocation sections from the overlay

* **User Scenario: SCN-038-A2**
  * **Given** a project with `v-model-config.yml` containing `domain: do_178c` and an overlay at `commands/overlays/do_178c/system-design.md`
  * **When** `/speckit.v-model.system-design` runs
  * **Then** the `system-design.md` contains DAL-specific design assurance sections from the overlay

#### Test Case: ATP-038-B (Graceful fallback when overlay missing)
**Linked Requirement:** REQ-038
**Description:** Verify the command falls back to base general-purpose design when a domain is set but no overlay file exists for that domain.
**Validation Condition:** Command does not error; base general-purpose design sections are used.
**Expected Result:** System design produced with generic IEEE 1016 sections and no error.

* **User Scenario: SCN-038-B1**
  * **Given** a project with `v-model-config.yml` containing `domain: custom_domain` but no overlay at `commands/overlays/custom_domain/system-design.md`
  * **When** `/speckit.v-model.system-design` runs
  * **Then** the command proceeds with the base general-purpose design sections without error

---

### Requirement Validation: REQ-039 (Domain Overlay Loading for System Test)

#### Test Case: ATP-039-A (Overlay loaded when domain is set)
**Linked Requirement:** REQ-039
**Description:** Verify the command loads the domain overlay and uses its safety-critical test sections when `v-model-config.yml` specifies a `domain` value.
**Validation Condition:** Domain overlay file is read and domain-specific test sections appear in the output.
**Expected Result:** Domain-specific test sections (e.g., MC/DC, WCET for do_178c) are used instead of the base general-purpose sections.

* **User Scenario: SCN-039-A1**
  * **Given** a project with `v-model-config.yml` containing `domain: do_178c` and an overlay at `commands/overlays/do_178c/system-test.md`
  * **When** `/speckit.v-model.system-test` runs
  * **Then** the `system-test.md` contains MC/DC Coverage, WCET Verification, and Resource Usage test sections from the overlay

* **User Scenario: SCN-039-A2**
  * **Given** a project with `v-model-config.yml` containing `domain: iso_26262` and an overlay at `commands/overlays/iso_26262/system-test.md`
  * **When** `/speckit.v-model.system-test` runs
  * **Then** the `system-test.md` contains ASIL-specific test coverage sections from the overlay

#### Test Case: ATP-039-B (Graceful fallback when overlay missing)
**Linked Requirement:** REQ-039
**Description:** Verify the command falls back to base general-purpose test design when a domain is set but no overlay file exists for that domain.
**Validation Condition:** Command does not error; base general-purpose test sections are used.
**Expected Result:** System test produced with generic ISO 29119 sections and no error.

* **User Scenario: SCN-039-B1**
  * **Given** a project with `v-model-config.yml` containing `domain: custom_domain` but no overlay at `commands/overlays/custom_domain/system-test.md`
  * **When** `/speckit.v-model.system-test` runs
  * **Then** the command proceeds with the base general-purpose test sections without error

---

### Requirement Validation: REQ-040 (Generic System Design Framing)

#### Test Case: ATP-040-A (Command text uses generic framing)
**Linked Requirement:** REQ-040
**Description:** Verify `/speckit.v-model.system-design` description and goal use generic framing (e.g., "IEEE 1016 system design") without referencing safety standards in base text.
**Validation Condition:** The command file `commands/system-design.md` description and goal do not contain domain-specific safety standard references.
**Expected Result:** Description and goal reference "IEEE 1016" or equivalent generic system design terminology.

* **User Scenario: SCN-040-A1**
  * **Given** the command file `commands/system-design.md`
  * **When** inspecting the `description` field and Goal section
  * **Then** neither contain the strings "ISO 26262", "DO-178C", "IEC 62304", or "IEC 61508"

* **User Scenario: SCN-040-A2**
  * **Given** the iso_26262 overlay at `commands/overlays/iso_26262/system-design.md`
  * **When** inspecting the overlay content
  * **Then** the overlay contains domain-specific references to FFI methodology and restricted complexity per ISO 26262

#### Test Case: ATP-040-B (Domain-specific guidance only from overlays)
**Linked Requirement:** REQ-040
**Description:** Verify domain-specific design guidance is provided only by loaded overlays, not by the base command.
**Validation Condition:** Running without a domain produces no safety-standard references in output.
**Expected Result:** Output contains only generic IEEE 1016-based design sections.

* **User Scenario: SCN-040-B1**
  * **Given** a project without `v-model-config.yml`
  * **When** `/speckit.v-model.system-design` runs
  * **Then** the `system-design.md` does not contain "FFI", "ASIL", "DAL", "Restricted Complexity", or other domain-specific terminology

---

### Requirement Validation: REQ-041 (Generic System Test Framing)

#### Test Case: ATP-041-A (Command text uses generic framing)
**Linked Requirement:** REQ-041
**Description:** Verify `/speckit.v-model.system-test` description and goal use generic testing framing (e.g., "ISO 29119 system test design") without referencing safety standards in base text.
**Validation Condition:** The command file `commands/system-test.md` description and goal do not contain domain-specific safety standard references.
**Expected Result:** Description and goal reference "ISO 29119" or equivalent generic testing terminology.

* **User Scenario: SCN-041-A1**
  * **Given** the command file `commands/system-test.md`
  * **When** inspecting the `description` field and Goal section
  * **Then** neither contain the strings "ISO 26262", "DO-178C", "IEC 62304", or "IEC 61508"

* **User Scenario: SCN-041-A2**
  * **Given** the do_178c overlay at `commands/overlays/do_178c/system-test.md`
  * **When** inspecting the overlay content
  * **Then** the overlay contains domain-specific references to MC/DC coverage and WCET verification per DO-178C

#### Test Case: ATP-041-B (Domain-specific guidance only from overlays)
**Linked Requirement:** REQ-041
**Description:** Verify domain-specific test guidance is provided only by loaded overlays, not by the base command.
**Validation Condition:** Running without a domain produces no safety-standard references in test output.
**Expected Result:** Output contains only generic ISO 29119-based test sections.

* **User Scenario: SCN-041-B1**
  * **Given** a project without `v-model-config.yml`
  * **When** `/speckit.v-model.system-test` runs
  * **Then** the `system-test.md` does not contain "MC/DC", "WCET", "ASIL", "DAL", or other domain-specific terminology

---

### Requirement Validation: REQ-042 (General-Purpose Output Without Domain)

#### Test Case: ATP-042-A (No overlays loaded when domain absent)
**Linked Requirement:** REQ-042
**Description:** Verify that when no domain is set (or no config exists), system-design and system-test commands produce general-purpose output without loading overlays. Safety-critical sections omitted entirely.
**Validation Condition:** No overlay files are loaded and no safety-critical sections appear in output.
**Expected Result:** Both commands produce general-purpose output with no domain-specific sections.

* **User Scenario: SCN-042-A1**
  * **Given** no `v-model-config.yml` exists in the project
  * **When** the user invokes `/speckit.v-model.system-design` and `/speckit.v-model.system-test`
  * **Then** neither `system-design.md` nor `system-test.md` contains sections for FFI, Restricted Complexity, MC/DC, WCET, or Safety Integrity Allocation

#### Test Case: ATP-042-B (Config exists but domain field absent)
**Linked Requirement:** REQ-042
**Description:** Verify general-purpose output when config exists but has no `domain` field.
**Validation Condition:** Commands run successfully and produce output identical to no-config scenario.
**Expected Result:** General-purpose output with no overlay-sourced sections.

* **User Scenario: SCN-042-B1**
  * **Given** a `v-model-config.yml` exists but does not contain a `domain` field
  * **When** the user invokes `/speckit.v-model.system-design`
  * **Then** the `system-design.md` contains only generic IEEE 1016-based design sections with no safety-critical content

---

### Requirement Validation: REQ-043 (Assembly Protocol Support for All Generative Commands)

#### Test Case: ATP-043-A (All generative commands support overlay loading)
**Linked Requirement:** REQ-043
**Description:** Verify all generative commands in this feature support domain overlay loading via the assembly protocol.
**Validation Condition:** Each generative command checks for domain config and loads corresponding overlay when present.
**Expected Result:** Both `/speckit.v-model.system-design` and `/speckit.v-model.system-test` load domain overlays via assembly protocol.

* **User Scenario: SCN-043-A1**
  * **Given** a project with `v-model-config.yml` containing `domain: iso_26262` and overlays at `commands/overlays/iso_26262/system-design.md` and `commands/overlays/iso_26262/system-test.md`
  * **When** `/speckit.v-model.system-design` and `/speckit.v-model.system-test` both run
  * **Then** both commands load and apply their respective domain overlays via the assembly protocol

#### Test Case: ATP-043-B (Assembly protocol graceful when overlay directory missing)
**Linked Requirement:** REQ-043
**Description:** Verify the assembly protocol handles missing overlay directories gracefully.
**Validation Condition:** Commands do not error when overlay directory does not exist for the specified domain.
**Expected Result:** Commands fall back to base behavior without error.

* **User Scenario: SCN-043-B1**
  * **Given** a project with `v-model-config.yml` containing `domain: unknown_domain` and no `commands/overlays/unknown_domain/` directory
  * **When** any generative command runs
  * **Then** the command produces base general-purpose output without error or warning about missing overlay

---

### Requirement Validation: REQ-NF-006 (Domain-Agnostic Base Form)

#### Test Case: ATP-NF-006-A (New domain requires only overlay files)
**Linked Requirement:** REQ-NF-006
**Description:** Verify that adding a new regulated domain requires only adding overlay files with no modification to base commands or templates.
**Validation Condition:** A new domain overlay is added and commands produce domain-specific output without any base command changes.
**Expected Result:** New domain overlay files are sufficient; no base command or template edits needed.

* **User Scenario: SCN-NF-006-A1**
  * **Given** a new domain `iec_61508` with overlay files added at `commands/overlays/iec_61508/system-design.md` and `commands/overlays/iec_61508/system-test.md` and no changes to base command files
  * **When** `v-model-config.yml` is set to `domain: iec_61508` and `/speckit.v-model.system-design` runs
  * **Then** the `system-design.md` contains IEC 61508 SIL-specific design sections from the new overlay

#### Test Case: ATP-NF-006-B (Base commands unchanged after adding domain)
**Linked Requirement:** REQ-NF-006
**Description:** Verify base command files remain unmodified after adding a new domain overlay.
**Validation Condition:** File checksums of base commands are identical before and after adding the overlay.
**Expected Result:** No changes to `commands/system-design.md` or `commands/system-test.md`.

* **User Scenario: SCN-NF-006-B1**
  * **Given** checksums recorded for `commands/system-design.md` and `commands/system-test.md` before adding a new domain overlay
  * **When** overlay files for `iec_61508` are added to `commands/overlays/iec_61508/`
  * **Then** checksums of `commands/system-design.md` and `commands/system-test.md` remain identical to the recorded values

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Requirements (REQ) | 56 (3 deprecated) |
| Total Test Cases (ATP) | 78 (6 deprecated) |
| Total Scenarios (SCN) | 82 (6 deprecated) |
| Requirements with ≥1 ATP | 56 / 56 (100%) |
| Test Cases with ≥1 SCN | 78 / 78 (100%) |
| **Overall Coverage** | **100%** |

## Uncovered Requirements

None — full coverage achieved.

---

**Validation Status**: ✅ Full Coverage (deprecated items excluded from active counts)
**Generated**: 2026-02-20
**Last Evolved**: 2026-04-19
**Validated by**: `validate-requirement-coverage.sh` (deterministic)
