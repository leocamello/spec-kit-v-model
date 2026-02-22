# Acceptance Test Plan: Architecture Design ↔ Integration Testing

**Feature Branch**: `003-architecture-integration`
**Created**: 2026-02-21
**Status**: Draft
**Source**: `specs/003-architecture-integration/v-model/requirements.md`

## Overview

This document defines the Acceptance Test Plan for the Architecture Design ↔ Integration Testing feature (v0.3.0). Every requirement in `requirements.md` has one or more Test Cases (ATP), and every Test Case has one or more executable User Scenarios (SCN) in BDD format (Given/When/Then).

## ID Schema

- **Test Case**: `ATP-{NNN}-{X}` — where NNN matches the parent REQ, X is a letter suffix (A, B, C...)
- **Scenario**: `SCN-{NNN}-{X}{#}` — nested under the parent ATP, with numeric suffix (1, 2, 3...)
- Example: `SCN-001-A1` → Scenario 1 of Test Case A validating REQ-001

## Acceptance Tests

### Requirement Validation: REQ-001 (Architecture Design Command Existence)

#### Test Case: ATP-001-A (Happy Path — Command Produces architecture-design.md)

**Linked Requirement:** REQ-001
**Description:** Verify the `/speckit.v-model.architecture-design` command reads `system-design.md` and produces `architecture-design.md`.

* **User Scenario: SCN-001-A1**
  * **Given** a `system-design.md` file exists in `{FEATURE_DIR}/v-model/` containing at least one `SYS-NNN` component
  * **When** the user invokes `/speckit.v-model.architecture-design`
  * **Then** an `architecture-design.md` file is created in `{FEATURE_DIR}/v-model/` `And` the file is non-empty `And` contains at least one `ARCH-NNN` identifier

#### Test Case: ATP-001-B (Error — Missing system-design.md)

**Linked Requirement:** REQ-001
**Description:** Verify the command fails gracefully when `system-design.md` does not exist.

* **User Scenario: SCN-001-B1**
  * **Given** the `{FEATURE_DIR}/v-model/` directory exists `And` no `system-design.md` file is present
  * **When** the user invokes `/speckit.v-model.architecture-design`
  * **Then** the command outputs an error message containing "system-design.md" `And` no `architecture-design.md` file is created

---

### Requirement Validation: REQ-002 (ARCH-NNN Identifier Assignment)

#### Test Case: ATP-002-A (Sequential ARCH-NNN Format)

**Linked Requirement:** REQ-002
**Description:** Verify each architecture module is assigned a unique `ARCH-NNN` identifier in 3-digit zero-padded sequential order.

* **User Scenario: SCN-002-A1**
  * **Given** a `system-design.md` exists with 5 system components (`SYS-001` through `SYS-005`)
  * **When** the user invokes `/speckit.v-model.architecture-design`
  * **Then** every module in `architecture-design.md` has an ID matching the regex `^ARCH-\d{3}$` `And` the first module is `ARCH-001` `And` IDs are sequentially numbered

#### Test Case: ATP-002-B (Identifier Permanence on Re-run)

**Linked Requirement:** REQ-002
**Description:** Verify that re-running the command does not renumber existing ARCH-NNN identifiers.

* **User Scenario: SCN-002-B1**
  * **Given** an `architecture-design.md` exists containing `ARCH-001`, `ARCH-002`, `ARCH-003` `And` `system-design.md` has been updated with additional system components
  * **When** the user invokes `/speckit.v-model.architecture-design`
  * **Then** the original `ARCH-001`, `ARCH-002`, `ARCH-003` retain their identifiers `And` new modules are appended as `ARCH-004` or higher

---

### Requirement Validation: REQ-003 (Logical View Content)

#### Test Case: ATP-003-A (Logical View Required Fields Present)

**Linked Requirement:** REQ-003
**Description:** Verify `architecture-design.md` includes a Logical View listing component breakdown with module name, description, and Parent System Components field.

* **User Scenario: SCN-003-A1**
  * **Given** a `system-design.md` exists with `SYS-001` and `SYS-002`
  * **When** the user inspects the generated `architecture-design.md`
  * **Then** the file contains a section titled "Logical View" `And` each `ARCH-NNN` entry includes a name, description, and a "Parent System Components" field listing one or more `SYS-NNN` identifiers

---

### Requirement Validation: REQ-004 (Process View Content)

#### Test Case: ATP-004-A (Process View with Mermaid Sequence Diagrams)

**Linked Requirement:** REQ-004
**Description:** Verify `architecture-design.md` includes a Process View documenting runtime interactions with Mermaid sequence diagrams.

* **User Scenario: SCN-004-A1**
  * **Given** an `architecture-design.md` has been generated with multiple interacting `ARCH-NNN` modules
  * **When** the user inspects the Process View section
  * **Then** the section documents runtime module interactions, concurrency, and thread management `And` contains at least one Mermaid `sequenceDiagram` block showing execution order and synchronization points

---

### Requirement Validation: REQ-005 (Interface View Content)

#### Test Case: ATP-005-A (Strict API Contracts Documented)

**Linked Requirement:** REQ-005
**Description:** Verify `architecture-design.md` includes an Interface View with inputs, outputs, and exceptions for every module.

* **User Scenario: SCN-005-A1**
  * **Given** an `architecture-design.md` has been generated with modules that expose interfaces
  * **When** the user inspects the Interface View section
  * **Then** each `ARCH-NNN` module has documented inputs (types, formats, ranges), outputs (types, guarantees), and exceptions (error codes, failure modes)

---

### Requirement Validation: REQ-006 (Data Flow View Content)

#### Test Case: ATP-006-A (Data Transformation Chains Documented)

**Linked Requirement:** REQ-006
**Description:** Verify `architecture-design.md` includes a Data Flow View tracing data through modules with intermediate formats.

* **User Scenario: SCN-006-A1**
  * **Given** an `architecture-design.md` has been generated for a feature with data processing requirements
  * **When** the user inspects the Data Flow View section
  * **Then** the section traces data movement through modules — input → transformation chain → output with intermediate formats documented

---

### Requirement Validation: REQ-007 (SYS-NNN Traceability for Business-Logic Modules)

#### Test Case: ATP-007-A (Every Business-Logic ARCH Traces to SYS)

**Linked Requirement:** REQ-007
**Description:** Verify each business-logic `ARCH-NNN` module references at least one parent `SYS-NNN` in the Logical View.

* **User Scenario: SCN-007-A1**
  * **Given** an `architecture-design.md` has been generated with 5 business-logic modules
  * **When** the user inspects each module's "Parent System Components" field
  * **Then** every business-logic `ARCH-NNN` entry lists at least one valid `SYS-NNN` identifier that exists in `system-design.md`

#### Test Case: ATP-007-B (Orphaned Business-Logic Module Detection)

**Linked Requirement:** REQ-007
**Description:** Verify that no business-logic module exists without a parent system component reference.

* **User Scenario: SCN-007-B1**
  * **Given** an `architecture-design.md` has been generated
  * **When** a regex scan extracts all business-logic `ARCH-NNN` identifiers and their "Parent System Components" fields
  * **Then** no business-logic `ARCH-NNN` module has an empty or missing "Parent System Components" field

---

### Requirement Validation: REQ-008 (Many-to-Many SYS↔ARCH Relationships)

#### Test Case: ATP-008-A (Single SYS Maps to Multiple ARCH)

**Linked Requirement:** REQ-008
**Description:** Verify a single system component can be decomposed into multiple architecture modules.

* **User Scenario: SCN-008-A1**
  * **Given** a `system-design.md` contains a complex system component `SYS-001` with multiple responsibilities
  * **When** the user invokes `/speckit.v-model.architecture-design`
  * **Then** two or more `ARCH-NNN` modules list `SYS-001` as a parent system component

#### Test Case: ATP-008-B (Single ARCH Satisfies Multiple SYS)

**Linked Requirement:** REQ-008
**Description:** Verify a single architecture module can trace to multiple parent system components.

* **User Scenario: SCN-008-B1**
  * **Given** a `system-design.md` contains system components with overlapping scope (e.g., `SYS-001` and `SYS-002` both relate to the same subsystem)
  * **When** the user invokes `/speckit.v-model.architecture-design`
  * **Then** at least one `ARCH-NNN` module lists two or more `SYS-NNN` identifiers in its "Parent System Components" field

---

### Requirement Validation: REQ-009 (Cross-Cutting Tag for Infrastructure Modules)

#### Test Case: ATP-009-A (Infrastructure Modules Use CROSS-CUTTING Tag)

**Linked Requirement:** REQ-009
**Description:** Verify infrastructure/utility modules trace to a `[CROSS-CUTTING]` tag instead of a `SYS-NNN` identifier.

* **User Scenario: SCN-009-A1**
  * **Given** an `architecture-design.md` has been generated from a system design that requires infrastructure modules (e.g., logging, secrets management)
  * **When** the user inspects the Logical View for infrastructure modules
  * **Then** each infrastructure `ARCH-NNN` module lists `[CROSS-CUTTING]` as its parent instead of a `SYS-NNN` identifier

---

### Requirement Validation: REQ-010 (Business vs Cross-Cutting Distinction)

#### Test Case: ATP-010-A (Clear Visual Distinction in Logical View)

**Linked Requirement:** REQ-010
**Description:** Verify the Logical View clearly distinguishes business-logic modules (with SYS parents) from cross-cutting modules (with CROSS-CUTTING tag and rationale).

* **User Scenario: SCN-010-A1**
  * **Given** an `architecture-design.md` has been generated containing both business-logic and cross-cutting modules
  * **When** the user inspects the Logical View
  * **Then** business-logic modules show explicit `SYS-NNN` parents `And` cross-cutting modules show the `[CROSS-CUTTING]` tag with a rationale explaining why the module is system-wide `And` the two categories are visually distinguishable

---

### Requirement Validation: REQ-011 (Cross-Cutting Module Coverage Validation)

#### Test Case: ATP-011-A (Cross-Cutting Modules Have Integration Tests)

**Linked Requirement:** REQ-011
**Description:** Verify each cross-cutting `ARCH-NNN` module has at least one `ITP-NNN-X` integration test case.

* **User Scenario: SCN-011-A1**
  * **Given** an `architecture-design.md` contains cross-cutting modules `ARCH-010` and `ARCH-011` `And` an `integration-test.md` has been generated
  * **When** the user verifies coverage for cross-cutting modules
  * **Then** each cross-cutting `ARCH-NNN` has at least one corresponding `ITP-NNN-X` test case in `integration-test.md`

#### Test Case: ATP-011-B (Coverage Validation Includes Cross-Cutting Modules)

**Linked Requirement:** REQ-011
**Description:** Verify the coverage validation script does not exclude cross-cutting modules from backward coverage checks.

* **User Scenario: SCN-011-B1**
  * **Given** an `architecture-design.md` contains a cross-cutting module `ARCH-010` `And` `integration-test.md` has no `ITP-010-X` test case
  * **When** the user runs `validate-architecture-coverage.sh`
  * **Then** the script reports a coverage gap for `ARCH-010` `And` exits with code 1

---

### Requirement Validation: REQ-012 (Derived Module Flagging)

#### Test Case: ATP-012-A (Derived Module Flagged with Warning)

**Linked Requirement:** REQ-012
**Description:** Verify the command flags modules that are neither traceable to SYS-NNN nor qualify as CROSS-CUTTING.

* **User Scenario: SCN-012-A1**
  * **Given** a `system-design.md` exists `And` the architecture design process identifies a technical module not traceable to any `SYS-NNN`
  * **When** the user invokes `/speckit.v-model.architecture-design`
  * **Then** the module is flagged as `[DERIVED MODULE: description]` in the output `And` the command prompts the user to update `system-design.md`

#### Test Case: ATP-012-B (Derived Module Not Silently Assigned ARCH-NNN)

**Linked Requirement:** REQ-012
**Description:** Verify derived modules are not silently created as regular ARCH-NNN entries.

* **User Scenario: SCN-012-B1**
  * **Given** a `system-design.md` exists with limited scope
  * **When** the architecture design process would require a module outside the system design scope
  * **Then** the module is NOT assigned a regular `ARCH-NNN` identifier without the `[DERIVED MODULE]` flag

---

### Requirement Validation: REQ-013 (Black Box Description Rejection)

#### Test Case: ATP-013-A (Incomplete Contracts Trigger Anti-Pattern Warning)

**Linked Requirement:** REQ-013
**Description:** Verify modules with incomplete interface contracts trigger an anti-pattern warning.

* **User Scenario: SCN-013-A1**
  * **Given** an `architecture-design.md` is being generated `And` a module has a vague description without specific inputs, outputs, or exceptions
  * **When** the architecture design command processes the module
  * **Then** the command emits an anti-pattern warning for the module indicating an incomplete interface contract

#### Test Case: ATP-013-B (Complete Contracts Pass Without Warning)

**Linked Requirement:** REQ-013
**Description:** Verify modules with complete interface contracts do not trigger warnings.

* **User Scenario: SCN-013-B1**
  * **Given** an `architecture-design.md` is being generated `And` every module has fully specified inputs, outputs, and exceptions in the Interface View
  * **When** the architecture design command processes the modules
  * **Then** no anti-pattern warnings are emitted for interface completeness

---

### Requirement Validation: REQ-014 (Integration Test Command Existence)

#### Test Case: ATP-014-A (Happy Path — Command Produces integration-test.md)

**Linked Requirement:** REQ-014
**Description:** Verify the `/speckit.v-model.integration-test` command reads `architecture-design.md` and produces `integration-test.md`.

* **User Scenario: SCN-014-A1**
  * **Given** an `architecture-design.md` file exists in `{FEATURE_DIR}/v-model/` containing at least one `ARCH-NNN` module
  * **When** the user invokes `/speckit.v-model.integration-test`
  * **Then** an `integration-test.md` file is created in `{FEATURE_DIR}/v-model/` `And` the file contains at least one `ITP-NNN-X` test case

#### Test Case: ATP-014-B (Error — Missing architecture-design.md)

**Linked Requirement:** REQ-014
**Description:** Verify the command fails gracefully when `architecture-design.md` does not exist.

* **User Scenario: SCN-014-B1**
  * **Given** the `{FEATURE_DIR}/v-model/` directory exists `And` no `architecture-design.md` file is present
  * **When** the user invokes `/speckit.v-model.integration-test`
  * **Then** the command outputs an error message containing "architecture-design.md" `And` no `integration-test.md` file is created

---

### Requirement Validation: REQ-015 (ITP-NNN-X Identifier Format)

#### Test Case: ATP-015-A (Test Case IDs Match Format)

**Linked Requirement:** REQ-015
**Description:** Verify all integration test case identifiers follow the `ITP-NNN-X` format where NNN matches the parent ARCH-NNN.

* **User Scenario: SCN-015-A1**
  * **Given** an `integration-test.md` has been generated from an `architecture-design.md` containing `ARCH-001` and `ARCH-002`
  * **When** a regex scan extracts all test case identifiers
  * **Then** every test case ID matches the pattern `^ITP-\d{3}-[A-Z]$` `And` the NNN portion matches a valid `ARCH-NNN` from `architecture-design.md`

---

### Requirement Validation: REQ-016 (ITS-NNN-X# Scenario Identifier Format)

#### Test Case: ATP-016-A (Scenario IDs Match Format)

**Linked Requirement:** REQ-016
**Description:** Verify all integration test scenario identifiers follow the `ITS-NNN-X#` format.

* **User Scenario: SCN-016-A1**
  * **Given** an `integration-test.md` has been generated containing test cases `ITP-001-A` and `ITP-001-B`
  * **When** a regex scan extracts all scenario identifiers
  * **Then** every scenario ID matches the pattern `^ITS-\d{3}-[A-Z]\d+$` `And` the NNN-X portion matches a valid `ITP-NNN-X` from the same file

---

### Requirement Validation: REQ-017 (ISO 29119-4 Technique Application)

#### Test Case: ATP-017-A (Each Test Case Applies One of Four Techniques)

**Linked Requirement:** REQ-017
**Description:** Verify each `ITP-NNN-X` applies one of: Interface Contract Testing, Data Flow Testing, Interface Fault Injection, or Concurrency & Race Condition Testing.

* **User Scenario: SCN-017-A1**
  * **Given** an `integration-test.md` has been generated with test cases for multiple `ARCH-NNN` modules
  * **When** the user inspects each `ITP-NNN-X` test case entry
  * **Then** every test case explicitly names one of the four mandatory ISO 29119-4 techniques `And` no test case uses a technique outside this set

---

### Requirement Validation: REQ-018 (Technique and View Reference)

#### Test Case: ATP-018-A (Each Test Case Names Technique and Architecture View)

**Linked Requirement:** REQ-018
**Description:** Verify each `ITP-NNN-X` explicitly names its technique and references the specific architecture view that drives it.

* **User Scenario: SCN-018-A1**
  * **Given** an `integration-test.md` has been generated
  * **When** the user inspects each `ITP-NNN-X` entry
  * **Then** every test case includes a named technique field `And` a reference to one of: Interface View, Data Flow View, or Process View

---

### Requirement Validation: REQ-019 (BDD Module-Boundary Language)

#### Test Case: ATP-019-A (Scenarios Use Technical Module-Boundary Language)

**Linked Requirement:** REQ-019
**Description:** Verify integration test scenarios use Given/When/Then BDD structure with technical, module-boundary-oriented language.

* **User Scenario: SCN-019-A1**
  * **Given** an `integration-test.md` has been generated
  * **When** the user inspects the `ITS-NNN-X#` scenarios
  * **Then** each scenario uses Given/When/Then format `And` references module names, payloads, error codes, and interface boundaries rather than user actions or UI elements

#### Test Case: ATP-019-B (Scenarios Do Not Use User-Centric Language)

**Linked Requirement:** REQ-019
**Description:** Verify integration test scenarios avoid user-journey or acceptance-level language.

* **User Scenario: SCN-019-B1**
  * **Given** an `integration-test.md` has been generated
  * **When** the user inspects all `ITS-NNN-X#` scenarios for user-centric language (e.g., "the user clicks", "the user sees")
  * **Then** no scenario contains user-centric or UI-oriented language `And` all language is module-boundary-oriented

---

### Requirement Validation: REQ-020 (No Internal Logic or User-Journey Tests)

#### Test Case: ATP-020-A (Only Boundary Tests Generated)

**Linked Requirement:** REQ-020
**Description:** Verify the integration test command generates only module-boundary tests, not internal logic or user-journey tests.

* **User Scenario: SCN-020-A1**
  * **Given** an `integration-test.md` has been generated
  * **When** the user inspects all test cases and scenarios
  * **Then** every test verifies a boundary or handshake between modules `And` no test verifies internal module logic or end-to-end user journeys

---

### Requirement Validation: REQ-021 (Safety-Critical Architecture Sections)

#### Test Case: ATP-021-A (Safety Sections Present When Configured)

**Linked Requirement:** REQ-021
**Description:** Verify the architecture design includes ASIL Decomposition, Defensive Programming, and Temporal & Execution Constraints when a safety-critical domain is configured.

* **User Scenario: SCN-021-A1**
  * **Given** a `v-model-config.yml` exists with `domain: iso_26262` `And` a `system-design.md` exists with `SYS-NNN` components
  * **When** the user invokes `/speckit.v-model.architecture-design`
  * **Then** the `architecture-design.md` contains an "ASIL Decomposition" section with safety integrity allocation per module `And` a "Defensive Programming" section `And` a "Temporal & Execution Constraints" section

#### Test Case: ATP-021-B (Safety Sections Absent When Not Configured)

**Linked Requirement:** REQ-021
**Description:** Verify safety-critical architecture sections are omitted when no regulated domain is configured.

* **User Scenario: SCN-021-B1**
  * **Given** no `v-model-config.yml` exists `Or` the file does not contain a `domain` field
  * **When** the user invokes `/speckit.v-model.architecture-design`
  * **Then** the `architecture-design.md` does not contain ASIL Decomposition, Defensive Programming, or Temporal & Execution Constraints sections

---

### Requirement Validation: REQ-022 (Safety-Critical Integration Test Sections)

#### Test Case: ATP-022-A (Safety Test Sections Present When Configured)

**Linked Requirement:** REQ-022
**Description:** Verify the integration test includes SIL/HIL Compatibility and Resource Contention sections when a safety-critical domain is configured.

* **User Scenario: SCN-022-A1**
  * **Given** a `v-model-config.yml` exists with `domain: do_178c` `And` an `architecture-design.md` exists
  * **When** the user invokes `/speckit.v-model.integration-test`
  * **Then** the `integration-test.md` contains a "SIL/HIL Compatibility" section with scenarios executable in loop environments `And` a "Resource Contention" section

#### Test Case: ATP-022-B (Safety Test Sections Absent When Not Configured)

**Linked Requirement:** REQ-022
**Description:** Verify safety-critical integration test sections are omitted when no regulated domain is configured.

* **User Scenario: SCN-022-B1**
  * **Given** no `v-model-config.yml` exists `Or` the file does not contain a `domain` field
  * **When** the user invokes `/speckit.v-model.integration-test`
  * **Then** the `integration-test.md` does not contain SIL/HIL Compatibility or Resource Contention sections

---

### Requirement Validation: REQ-023 (Coverage Gate Invocation)

#### Test Case: ATP-023-A (Validation Invoked and Result Included)

**Linked Requirement:** REQ-023
**Description:** Verify the integration test command invokes `validate-architecture-coverage.sh` and includes the result in output.

* **User Scenario: SCN-023-A1**
  * **Given** `architecture-design.md` and `system-design.md` exist `And` the integration test command has generated `integration-test.md`
  * **When** the integration test command completes post-generation validation
  * **Then** `validate-architecture-coverage.sh` is invoked `And` the pass/fail result with coverage summary is included in the command output

#### Test Case: ATP-023-B (Coverage Failure Reported)

**Linked Requirement:** REQ-023
**Description:** Verify coverage failures from the validation script are reported to the user.

* **User Scenario: SCN-023-B1**
  * **Given** the generated `integration-test.md` is missing test cases for one or more `ARCH-NNN` modules
  * **When** the integration test command runs the post-generation coverage gate
  * **Then** the coverage failure is reported with specific gap details `And` the user is informed of the incomplete coverage

---

### Requirement Validation: REQ-024 (Forward Coverage Validation — SYS→ARCH)

#### Test Case: ATP-024-A (All SYS Have ARCH Mappings)

**Linked Requirement:** REQ-024
**Description:** Verify the script validates that every `SYS-NNN` in `system-design.md` has at least one corresponding `ARCH-NNN`.

* **User Scenario: SCN-024-A1**
  * **Given** a `system-design.md` contains `SYS-001`, `SYS-002`, `SYS-003` `And` `architecture-design.md` maps all three to `ARCH-NNN` modules
  * **When** the user runs `validate-architecture-coverage.sh`
  * **Then** forward coverage is reported as 100% `And` no SYS→ARCH gaps are listed

#### Test Case: ATP-024-B (Missing SYS→ARCH Gap Detected)

**Linked Requirement:** REQ-024
**Description:** Verify the script detects when a `SYS-NNN` has no corresponding `ARCH-NNN`.

* **User Scenario: SCN-024-B1**
  * **Given** a `system-design.md` contains `SYS-001`, `SYS-002`, `SYS-003` `And` `architecture-design.md` only maps `SYS-001` and `SYS-002`
  * **When** the user runs `validate-architecture-coverage.sh`
  * **Then** the script reports "SYS-003: no architecture module mapping found" `And` exits with code 1

---

### Requirement Validation: REQ-025 (Backward Coverage Validation — ARCH→ITP)

#### Test Case: ATP-025-A (All ARCH Have ITP Mappings)

**Linked Requirement:** REQ-025
**Description:** Verify the script validates that every `ARCH-NNN` has at least one corresponding `ITP-NNN-X`.

* **User Scenario: SCN-025-A1**
  * **Given** an `architecture-design.md` contains `ARCH-001`, `ARCH-002` `And` `integration-test.md` has `ITP-001-A` and `ITP-002-A`
  * **When** the user runs `validate-architecture-coverage.sh`
  * **Then** backward coverage is reported as 100% `And` no ARCH→ITP gaps are listed

#### Test Case: ATP-025-B (Missing ARCH→ITP Gap Detected)

**Linked Requirement:** REQ-025
**Description:** Verify the script detects when an `ARCH-NNN` has no corresponding `ITP-NNN-X`.

* **User Scenario: SCN-025-B1**
  * **Given** an `architecture-design.md` contains `ARCH-001`, `ARCH-002`, `ARCH-003` `And` `integration-test.md` only has tests for `ARCH-001` and `ARCH-002`
  * **When** the user runs `validate-architecture-coverage.sh`
  * **Then** the script reports "ARCH-003: no integration test case found" `And` exits with code 1

---

### Requirement Validation: REQ-026 (Orphaned Identifier Detection)

#### Test Case: ATP-026-A (Orphaned ARCH Detected)

**Linked Requirement:** REQ-026
**Description:** Verify the script detects `ARCH-NNN` modules not referenced by any `SYS-NNN` or `[CROSS-CUTTING]` tag.

* **User Scenario: SCN-026-A1**
  * **Given** an `architecture-design.md` contains `ARCH-005` with no "Parent System Components" field and no `[CROSS-CUTTING]` tag
  * **When** the user runs `validate-architecture-coverage.sh`
  * **Then** the script reports `ARCH-005` as an orphaned identifier `And` exits with code 1

#### Test Case: ATP-026-B (Orphaned ITP Detected)

**Linked Requirement:** REQ-026
**Description:** Verify the script detects `ITP-NNN-X` test cases whose parent `ARCH-NNN` does not exist in `architecture-design.md`.

* **User Scenario: SCN-026-B1**
  * **Given** an `integration-test.md` contains `ITP-099-A` `And` `architecture-design.md` does not contain `ARCH-099`
  * **When** the user runs `validate-architecture-coverage.sh`
  * **Then** the script reports `ITP-099-A` as orphaned (parent `ARCH-099` not found) `And` exits with code 1

---

### Requirement Validation: REQ-027 (Exit Codes)

#### Test Case: ATP-027-A (Exit Code 0 on Full Coverage)

**Linked Requirement:** REQ-027
**Description:** Verify the script exits with code 0 when all coverage checks pass.

* **User Scenario: SCN-027-A1**
  * **Given** all `SYS-NNN` have corresponding `ARCH-NNN` modules `And` all `ARCH-NNN` have corresponding `ITP-NNN-X` test cases `And` no orphaned identifiers exist
  * **When** the user runs `validate-architecture-coverage.sh`
  * **Then** the script exits with code 0

#### Test Case: ATP-027-B (Exit Code 1 on Any Gap or Orphan)

**Linked Requirement:** REQ-027
**Description:** Verify the script exits with code 1 when any coverage gap or orphan is detected.

* **User Scenario: SCN-027-B1**
  * **Given** at least one coverage gap or orphaned identifier exists in the artifact set
  * **When** the user runs `validate-architecture-coverage.sh`
  * **Then** the script exits with code 1

---

### Requirement Validation: REQ-028 (Human-Readable Gap Reports)

#### Test Case: ATP-028-A (Gap Report Lists Specific IDs)

**Linked Requirement:** REQ-028
**Description:** Verify the script outputs human-readable reports listing each gap or orphan by specific ID.

* **User Scenario: SCN-028-A1**
  * **Given** `SYS-003` has no architecture module mapping `And` `ARCH-005` has no integration test case
  * **When** the user runs `validate-architecture-coverage.sh`
  * **Then** the output contains "SYS-003: no architecture module mapping found" `And` "ARCH-005: no integration test case found" `And` the output is suitable for CI log inspection

---

### Requirement Validation: REQ-029 (JSON Output Mode)

#### Test Case: ATP-029-A (--json Flag Produces Valid JSON)

**Linked Requirement:** REQ-029
**Description:** Verify the script supports `--json` output mode for programmatic consumption.

* **User Scenario: SCN-029-A1**
  * **Given** the three V-Model artifact files exist at known paths
  * **When** the user runs `validate-architecture-coverage.sh --json system-design.md architecture-design.md integration-test.md`
  * **Then** the script outputs valid JSON `And` the JSON contains forward coverage, backward coverage, and orphan check results

---

### Requirement Validation: REQ-030 (ID Lineage Encoding Consistency)

#### Test Case: ATP-030-A (Regex Extracts Parent ITP from ITS)

**Linked Requirement:** REQ-030
**Description:** Verify a regex can extract the parent `ITP-NNN-X` and grandparent `ARCH-NNN` from any `ITS-NNN-X#` identifier.

* **User Scenario: SCN-030-A1**
  * **Given** an `integration-test.md` contains scenario `ITS-003-B2`
  * **When** a regex parses the identifier
  * **Then** the parent `ITP-003-B` and grandparent `ARCH-003` are extractable without consulting any lookup table

#### Test Case: ATP-030-B (SYS Resolution via File Lookup)

**Linked Requirement:** REQ-030
**Description:** Verify the script resolves SYS-NNN ancestors by consulting the "Parent System Components" field due to many-to-many relationships.

* **User Scenario: SCN-030-B1**
  * **Given** `ARCH-003` traces to both `SYS-001` and `SYS-002` in the "Parent System Components" field
  * **When** the validation script resolves the SYS ancestor(s) for `ITS-003-B2`
  * **Then** the script consults `architecture-design.md` to resolve `ARCH-003` → `SYS-001, SYS-002` `And` does not attempt pure string-based SYS extraction

---

### Requirement Validation: REQ-031 (Matrix C Generation)

#### Test Case: ATP-031-A (Matrix C Produced with Correct Columns)

**Linked Requirement:** REQ-031
**Description:** Verify the trace command produces Matrix C (SYS → ARCH → ITP → ITS) when architecture-level artifacts exist.

* **User Scenario: SCN-031-A1**
  * **Given** `architecture-design.md` and `integration-test.md` exist in the feature directory
  * **When** the user invokes `/speckit.v-model.trace`
  * **Then** the output includes "Matrix C (Integration Verification)" with columns for SYS, ARCH, ITP, and ITS

#### Test Case: ATP-031-B (Cross-Cutting Modules in Matrix C)

**Linked Requirement:** REQ-031
**Description:** Verify cross-cutting `ARCH-NNN` modules appear in Matrix C with `N/A (Cross-Cutting)` in the SYS column.

* **User Scenario: SCN-031-B1**
  * **Given** `architecture-design.md` contains a cross-cutting module `ARCH-010` tagged `[CROSS-CUTTING]`
  * **When** the user invokes `/speckit.v-model.trace`
  * **Then** Matrix C includes a row for `ARCH-010` `And` the SYS column displays `N/A (Cross-Cutting)`

---

### Requirement Validation: REQ-032 (REQ References in Matrix C SYS Cells)

#### Test Case: ATP-032-A (SYS Cells Include Parent REQ Identifiers)

**Linked Requirement:** REQ-032
**Description:** Verify each SYS-NNN cell in Matrix C includes a comma-separated list of parent REQ-NNN identifiers in parentheses.

* **User Scenario: SCN-032-A1**
  * **Given** `SYS-001` traces to `REQ-001` and `REQ-003` in `system-design.md`
  * **When** the user inspects Matrix C in the trace output
  * **Then** the SYS column for `SYS-001` displays `SYS-001 (REQ-001, REQ-003)`

---

### Requirement Validation: REQ-033 (Separate Matrix Tables)

#### Test Case: ATP-033-A (Three Separate Tables with Independent Percentages)

**Linked Requirement:** REQ-033
**Description:** Verify Matrix A, Matrix B, and Matrix C are presented as separate tables with independent coverage percentages.

* **User Scenario: SCN-033-A1**
  * **Given** all V-Model artifacts exist (acceptance through integration test)
  * **When** the user inspects the trace output
  * **Then** Matrix A (Validation), Matrix B (Verification), and Matrix C (Integration Verification) are rendered as separate Markdown tables `And` each has its own independently calculated coverage percentage

---

### Requirement Validation: REQ-034 (Trace Command Backward Compatibility)

#### Test Case: ATP-034-A (v0.2.0 Output When Architecture Artifacts Absent)

**Linked Requirement:** REQ-034
**Description:** Verify the trace command produces the same v0.2.0 output when architecture-level artifacts are absent.

* **User Scenario: SCN-034-A1**
  * **Given** a feature directory contains v0.2.0 artifacts (`requirements.md`, `acceptance-plan.md`, `system-design.md`, `system-test.md`) `And` no `architecture-design.md` or `integration-test.md` exists
  * **When** the user invokes `/speckit.v-model.trace`
  * **Then** the output contains Matrix A and Matrix B only `And` no Matrix C is present `And` no warning about missing architecture artifacts is displayed

---

### Requirement Validation: REQ-035 (Progressive Matrix Building)

#### Test Case: ATP-035-A (Matrices Build Progressively by V-Level)

**Linked Requirement:** REQ-035
**Description:** Verify matrices are built progressively: A alone, then A+B, then A+B+C.

* **User Scenario: SCN-035-A1**
  * **Given** a feature directory contains only `requirements.md` and `acceptance-plan.md`
  * **When** the user invokes `/speckit.v-model.trace`
  * **Then** only Matrix A is produced `And` after `system-design.md` and `system-test.md` are added, A+B are produced `And` after `architecture-design.md` and `integration-test.md` are added, A+B+C are produced

---

### Requirement Validation: REQ-036 (Coverage Percentage Matches Script Output)

#### Test Case: ATP-036-A (Matrix Percentages Match Validation Script)

**Linked Requirement:** REQ-036
**Description:** Verify each matrix's coverage percentage matches the output of the corresponding deterministic validation script.

* **User Scenario: SCN-036-A1**
  * **Given** all V-Model artifacts exist `And` `validate-architecture-coverage.sh` reports 95% forward coverage and 100% backward coverage
  * **When** the user inspects Matrix C coverage percentage in the trace output
  * **Then** the coverage percentages in Matrix C match the script's reported values exactly

---

### Requirement Validation: REQ-037 (build-matrix.sh Extension)

#### Test Case: ATP-037-A (Script Parses Architecture and Integration Artifacts)

**Linked Requirement:** REQ-037
**Description:** Verify `build-matrix.sh` is extended to parse `architecture-design.md` and `integration-test.md` for Matrix C data.

* **User Scenario: SCN-037-A1**
  * **Given** `architecture-design.md` and `integration-test.md` exist with valid `ARCH-NNN` and `ITP-NNN-X` identifiers
  * **When** the user runs `build-matrix.sh`
  * **Then** the script parses both files `And` generates Matrix C data with correct SYS → ARCH → ITP → ITS mappings

---

### Requirement Validation: REQ-038 (build-matrix.ps1 Extension)

#### Test Case: ATP-038-A (PowerShell Script Generates Matrix C)

**Linked Requirement:** REQ-038
**Description:** Verify `build-matrix.ps1` is extended with identical Matrix C generation logic.

* **User Scenario: SCN-038-A1**
  * **Given** `architecture-design.md` and `integration-test.md` exist `And` both `build-matrix.sh` and `build-matrix.ps1` are available
  * **When** the user runs both scripts against the same artifact set
  * **Then** both scripts produce identical Matrix C output

---

### Requirement Validation: REQ-039 (Architecture Design Template)

#### Test Case: ATP-039-A (Template Exists with ISO 42010 Structure)

**Linked Requirement:** REQ-039
**Description:** Verify `architecture-design-template.md` exists in `templates/` with four mandatory views conforming to ISO/IEC/IEEE 42010.

* **User Scenario: SCN-039-A1**
  * **Given** the extension has been installed
  * **When** the user inspects `templates/architecture-design-template.md`
  * **Then** the template exists `And` defines sections for Logical View, Process View, Interface View, and Data Flow View `And` each section includes placeholder structure for the required fields

---

### Requirement Validation: REQ-040 (Integration Test Template)

#### Test Case: ATP-040-A (Template Exists with ISO 29119-4 Structure)

**Linked Requirement:** REQ-040
**Description:** Verify `integration-test-template.md` exists in `templates/` with the three-tier ITP/ITS hierarchy conforming to ISO 29119-4.

* **User Scenario: SCN-040-A1**
  * **Given** the extension has been installed
  * **When** the user inspects `templates/integration-test-template.md`
  * **Then** the template exists `And` defines the three-tier structure (ARCH → ITP → ITS) `And` includes placeholders for the four mandatory ISO 29119-4 techniques

---

### Requirement Validation: REQ-049 (Test Harness & Mocking Strategy Section)

#### Test Case: ATP-049-A (Template Includes Test Harness Section)

**Linked Requirement:** REQ-049
**Description:** Verify `integration-test-template.md` includes a "Test Harness & Mocking Strategy" section for each `ITP-NNN-X`.

* **User Scenario: SCN-049-A1**
  * **Given** the extension has been installed
  * **When** the user inspects `templates/integration-test-template.md`
  * **Then** the template includes a "Test Harness & Mocking Strategy" section `And` the section defines where each `ITP-NNN-X` declares which external interfaces, hardware dependencies, or unresolved module dependencies are stubbed or mocked

---

### Requirement Validation: REQ-041 (Architecture Design Strict Translator Constraint)

#### Test Case: ATP-041-A (No Invented Modules Beyond System Design)

**Linked Requirement:** REQ-041
**Description:** Verify the architecture design command does not invent modules for capabilities not present in `system-design.md`.

* **User Scenario: SCN-041-A1**
  * **Given** a `system-design.md` exists with exactly 3 system components (`SYS-001`, `SYS-002`, `SYS-003`) covering a well-defined scope
  * **When** the user invokes `/speckit.v-model.architecture-design`
  * **Then** every business-logic `ARCH-NNN` module traces to one or more of `SYS-001`, `SYS-002`, `SYS-003` `And` no module addresses capabilities absent from the system design

#### Test Case: ATP-041-B (All ARCH Modules Traceable to System Design)

**Linked Requirement:** REQ-041
**Description:** Verify all generated modules trace back to system design content (SYS-NNN or CROSS-CUTTING).

* **User Scenario: SCN-041-B1**
  * **Given** the `architecture-design.md` has been generated
  * **When** the user verifies each `ARCH-NNN` module's parent references
  * **Then** every `ARCH-NNN` traces to either a `SYS-NNN` from `system-design.md` or is tagged `[CROSS-CUTTING]` `And` no module exists without a traceable origin

---

### Requirement Validation: REQ-042 (Integration Test Strict Translator Constraint)

#### Test Case: ATP-042-A (No Invented Test Cases Beyond Architecture Design)

**Linked Requirement:** REQ-042
**Description:** Verify the integration test command does not invent test cases for modules or interfaces not present in `architecture-design.md`.

* **User Scenario: SCN-042-A1**
  * **Given** an `architecture-design.md` exists with exactly 4 modules (`ARCH-001` through `ARCH-004`)
  * **When** the user invokes `/speckit.v-model.integration-test`
  * **Then** every `ITP-NNN-X` test case references a valid `ARCH-NNN` from `architecture-design.md` `And` no test case addresses modules or interfaces absent from the architecture design

#### Test Case: ATP-042-B (All ITP Test Cases Traceable to Architecture Design)

**Linked Requirement:** REQ-042
**Description:** Verify all generated test cases trace back to architecture design content.

* **User Scenario: SCN-042-B1**
  * **Given** the `integration-test.md` has been generated
  * **When** a regex scan extracts all `ITP-NNN-X` identifiers and their parent `ARCH-NNN` references
  * **Then** every `ITP-NNN-X` references a valid `ARCH-NNN` that exists in `architecture-design.md`

---

### Requirement Validation: REQ-043 (--require-system-design Flag)

#### Test Case: ATP-043-A (Flag Validates system-design.md Exists)

**Linked Requirement:** REQ-043
**Description:** Verify the `--require-system-design` flag verifies `system-design.md` exists before proceeding.

* **User Scenario: SCN-043-A1**
  * **Given** a `system-design.md` exists in the expected location `And` `setup-v-model.sh` is invoked with `--require-system-design`
  * **When** the setup script runs
  * **Then** the script proceeds successfully past the system-design check

#### Test Case: ATP-043-B (Flag Fails When system-design.md Missing)

**Linked Requirement:** REQ-043
**Description:** Verify the flag causes the setup script to fail when `system-design.md` is missing.

* **User Scenario: SCN-043-B1**
  * **Given** no `system-design.md` exists in the expected location `And` `setup-v-model.sh` is invoked with `--require-system-design`
  * **When** the setup script runs
  * **Then** the script exits with an error message indicating `system-design.md` is required but not found

---

### Requirement Validation: REQ-044 (AVAILABLE_DOCS Detection)

#### Test Case: ATP-044-A (Both Architecture Files Detected)

**Linked Requirement:** REQ-044
**Description:** Verify `setup-v-model.sh` and `setup-v-model.ps1` detect `architecture-design.md` and `integration-test.md` in `AVAILABLE_DOCS`.

* **User Scenario: SCN-044-A1**
  * **Given** both `architecture-design.md` and `integration-test.md` exist in the feature directory
  * **When** the user runs `setup-v-model.sh`
  * **Then** the `AVAILABLE_DOCS` list includes both `architecture-design.md` and `integration-test.md`

#### Test Case: ATP-044-B (Partial Detection — Only Architecture Design Exists)

**Linked Requirement:** REQ-044
**Description:** Verify partial detection when only one architecture-level artifact exists.

* **User Scenario: SCN-044-B1**
  * **Given** `architecture-design.md` exists but `integration-test.md` does not
  * **When** the user runs `setup-v-model.sh`
  * **Then** `AVAILABLE_DOCS` includes `architecture-design.md` `And` does not include `integration-test.md`

---

### Requirement Validation: REQ-045 (Empty system-design.md Handling)

#### Test Case: ATP-045-A (Clear Error on Empty Input)

**Linked Requirement:** REQ-045
**Description:** Verify the command fails gracefully with a specific error when `system-design.md` contains zero `SYS-NNN` identifiers.

* **User Scenario: SCN-045-A1**
  * **Given** a `system-design.md` exists but is empty or contains no `SYS-NNN` identifiers
  * **When** the user invokes `/speckit.v-model.architecture-design`
  * **Then** the command outputs "No system components found in system-design.md — cannot generate architecture design" `And` no `architecture-design.md` is created

---

### Requirement Validation: REQ-046 (Circular Dependency Detection)

#### Test Case: ATP-046-A (Circular Dependency Reported)

**Linked Requirement:** REQ-046
**Description:** Verify the script detects and reports circular dependencies between `ARCH-NNN` modules.

* **User Scenario: SCN-046-A1**
  * **Given** an `architecture-design.md` contains modules with a circular dependency chain (e.g., `ARCH-001` → `ARCH-002` → `ARCH-003` → `ARCH-001`) in the Process View
  * **When** the user runs `validate-architecture-coverage.sh`
  * **Then** the script reports a circular dependency involving the specific `ARCH-NNN` identifiers

#### Test Case: ATP-046-B (Script Does Not Hang on Circular Dependencies)

**Linked Requirement:** REQ-046
**Description:** Verify the script terminates normally when circular dependencies are present.

* **User Scenario: SCN-046-B1**
  * **Given** an `architecture-design.md` contains a circular dependency chain
  * **When** the user runs `validate-architecture-coverage.sh`
  * **Then** the script completes execution within a reasonable time `And` does not hang or enter an infinite loop

---

### Requirement Validation: REQ-047 (Partial Matrix C — Missing integration-test.md)

#### Test Case: ATP-047-A (ARCH Column Filled, ITP/ITS Empty with Note)

**Linked Requirement:** REQ-047
**Description:** Verify Matrix C includes ARCH column data but leaves ITP/ITS empty with a note when `integration-test.md` is absent.

* **User Scenario: SCN-047-A1**
  * **Given** `architecture-design.md` exists with `ARCH-NNN` modules `And` no `integration-test.md` exists
  * **When** the user invokes `/speckit.v-model.trace`
  * **Then** Matrix C includes the ARCH column populated with `ARCH-NNN` values `And` the ITP and ITS columns are empty with a note "Integration test plan not yet generated"

---

### Requirement Validation: REQ-048 (Partial Validation Execution)

#### Test Case: ATP-048-A (Forward-Only Validation When integration-test.md Absent)

**Linked Requirement:** REQ-048
**Description:** Verify the script validates only forward coverage (SYS→ARCH) when `integration-test.md` is omitted.

* **User Scenario: SCN-048-A1**
  * **Given** `system-design.md` and `architecture-design.md` exist `And` `integration-test.md` does not exist
  * **When** the user runs `validate-architecture-coverage.sh`
  * **Then** the script validates forward coverage (SYS → ARCH) only `And` bypasses backward coverage and orphan checks for integration artifacts `And` exits with code 0 if forward coverage is complete

#### Test Case: ATP-048-B (Full Validation When All Files Present)

**Linked Requirement:** REQ-048
**Description:** Verify the script runs full validation (forward, backward, orphan) when all files are present.

* **User Scenario: SCN-048-B1**
  * **Given** `system-design.md`, `architecture-design.md`, and `integration-test.md` all exist
  * **When** the user runs `validate-architecture-coverage.sh`
  * **Then** the script validates forward coverage (SYS → ARCH), backward coverage (ARCH → ITP), and orphan checks `And` reports results for all three checks

---

### Requirement Validation: REQ-NF-001 (Regex-Based Parsing — No External Tooling)

#### Test Case: ATP-NF-001-A (Script Uses Only Bash Builtins and Standard Utilities)

**Linked Requirement:** REQ-NF-001
**Description:** Verify `validate-architecture-coverage.sh` uses regex-based parsing consistent with `validate-system-coverage.sh`, with no external tooling.

* **User Scenario: SCN-NF-001-A1**
  * **Given** the `validate-architecture-coverage.sh` script exists
  * **When** the user inspects the script source code for external dependencies (e.g., `python`, `node`, `jq`, database clients)
  * **Then** the script uses only Bash builtins, `grep`, `sed`, `awk`, and standard POSIX utilities `And` no external runtime dependencies or databases are required

---

### Requirement Validation: REQ-NF-002 (Large Input Handling — 50+ SYS Identifiers)

#### Test Case: ATP-NF-002-A (No Truncation with 50 SYS Identifiers)

**Linked Requirement:** REQ-NF-002
**Description:** Verify the commands handle input files with 50+ `SYS-NNN` identifiers without truncation or degraded output quality.

* **User Scenario: SCN-NF-002-A1**
  * **Given** a `system-design.md` exists with 50 system components (`SYS-001` through `SYS-050`)
  * **When** the user invokes `/speckit.v-model.architecture-design`
  * **Then** the `architecture-design.md` addresses all 50 system components `And` no component is truncated or omitted `And` output quality is not degraded

---

### Requirement Validation: REQ-NF-003 (Gap Tolerance in ARCH-NNN Numbering)

#### Test Case: ATP-NF-003-A (Gaps Accepted Without False Positives)

**Linked Requirement:** REQ-NF-003
**Description:** Verify the validation script accepts gaps in ARCH-NNN numbering without reporting errors.

* **User Scenario: SCN-NF-003-A1**
  * **Given** an `architecture-design.md` contains `ARCH-001`, `ARCH-003`, `ARCH-005` (gaps at `ARCH-002` and `ARCH-004`) `And` all three modules have valid parent SYS references and integration test cases
  * **When** the user runs `validate-architecture-coverage.sh`
  * **Then** the script reports 100% coverage `And` does not flag the gaps as errors `And` exits with code 0

---

### Requirement Validation: REQ-NF-004 (Backward Compatibility with v0.2.0 Artifacts)

#### Test Case: ATP-NF-004-A (Existing v0.2.0 Files Unchanged)

**Linked Requirement:** REQ-NF-004
**Description:** Verify v0.3.0 operations do not modify existing `system-design.md`, `system-test.md`, `requirements.md`, `acceptance-plan.md`, or `traceability-matrix.md`.

* **User Scenario: SCN-NF-004-A1**
  * **Given** a feature directory contains v0.2.0 artifacts: `system-design.md` (checksum A), `system-test.md` (checksum B), `requirements.md` (checksum C), `acceptance-plan.md` (checksum D), `traceability-matrix.md` (checksum E)
  * **When** the user runs all v0.3.0 commands (`/speckit.v-model.architecture-design`, `/speckit.v-model.integration-test`)
  * **Then** the checksums of all five pre-existing files remain identical to their pre-operation values

---

### Requirement Validation: REQ-NF-005 (Internal QA Gate — CI Evaluation Suite)

#### Test Case: ATP-NF-005-A (Evaluation Suite Validates Output Quality and Mermaid Syntax)

**Linked Requirement:** REQ-NF-005
**Description:** (Internal QA gate — not user-facing) Verify the CI evaluation suite validates command output quality and Mermaid diagram syntax.

* **User Scenario: SCN-NF-005-A1**
  * **Given** the `evals.yml` CI workflow is configured `And` golden example outputs exist for `/speckit.v-model.architecture-design` and `/speckit.v-model.integration-test`
  * **When** the evaluation suite runs via `pytest tests/evals/ -m eval`
  * **Then** the architecture design quality score meets or exceeds v0.2.0 thresholds `And` the integration test quality score meets or exceeds the same thresholds `And` Mermaid diagrams in the Process View pass syntactic validity checks

---

### Requirement Validation: REQ-IF-001 (Architecture Design Command File I/O Paths)

#### Test Case: ATP-IF-001-A (Reads from system-design.md, Writes to architecture-design.md)

**Linked Requirement:** REQ-IF-001
**Description:** Verify the architecture design command reads exclusively from the correct input path and writes to the correct output path.

* **User Scenario: SCN-IF-001-A1**
  * **Given** a feature directory `specs/003-architecture-integration/` exists with `v-model/system-design.md`
  * **When** the user invokes `/speckit.v-model.architecture-design`
  * **Then** the command reads from `{FEATURE_DIR}/v-model/system-design.md` `And` writes output to `{FEATURE_DIR}/v-model/architecture-design.md` `And` no other files in the feature directory are created or modified

---

### Requirement Validation: REQ-IF-002 (Integration Test Command File I/O Paths)

#### Test Case: ATP-IF-002-A (Reads from architecture-design.md, Writes to integration-test.md)

**Linked Requirement:** REQ-IF-002
**Description:** Verify the integration test command reads exclusively from the correct input path and writes to the correct output path.

* **User Scenario: SCN-IF-002-A1**
  * **Given** a feature directory exists with `v-model/architecture-design.md`
  * **When** the user invokes `/speckit.v-model.integration-test`
  * **Then** the command reads from `{FEATURE_DIR}/v-model/architecture-design.md` `And` writes output to `{FEATURE_DIR}/v-model/integration-test.md` `And` no other files in the feature directory are created or modified

---

### Requirement Validation: REQ-IF-003 (Validation Script Argument Convention)

#### Test Case: ATP-IF-003-A (Accepts Three File Paths as Arguments)

**Linked Requirement:** REQ-IF-003
**Description:** Verify `validate-architecture-coverage.sh` accepts three file paths: system-design.md, architecture-design.md, integration-test.md.

* **User Scenario: SCN-IF-003-A1**
  * **Given** the three V-Model files exist at known paths
  * **When** the user runs `validate-architecture-coverage.sh /path/to/system-design.md /path/to/architecture-design.md /path/to/integration-test.md`
  * **Then** the script executes successfully `And` validates coverage using the provided file paths in that order

---

### Requirement Validation: REQ-IF-004 (Validation Script Output Format)

#### Test Case: ATP-IF-004-A (Consistent Format with validate-system-coverage.sh)

**Linked Requirement:** REQ-IF-004
**Description:** Verify `validate-architecture-coverage.sh` output matches the format of `validate-system-coverage.sh`.

* **User Scenario: SCN-IF-004-A1**
  * **Given** a set of V-Model artifacts with known coverage gaps exists
  * **When** the user runs `validate-architecture-coverage.sh`
  * **Then** the output contains section headers (e.g., "Forward Coverage", "Backward Coverage"), gap lists with specific IDs, a pass/fail verdict, and coverage percentages `And` the format is consistent with `validate-system-coverage.sh` output

---

### Requirement Validation: REQ-CN-001 (Safety-Critical Sections Omitted by Default)

#### Test Case: ATP-CN-001-A (No Safety Sections Without Config)

**Linked Requirement:** REQ-CN-001
**Description:** Verify safety-critical sections are omitted when no regulated domain is configured.

* **User Scenario: SCN-CN-001-A1**
  * **Given** no `v-model-config.yml` exists `Or` the file does not contain a `domain` field
  * **When** the user invokes `/speckit.v-model.architecture-design` and `/speckit.v-model.integration-test`
  * **Then** neither `architecture-design.md` nor `integration-test.md` contains sections for ASIL Decomposition, Defensive Programming, Temporal & Execution Constraints, SIL/HIL Compatibility, or Resource Contention

#### Test Case: ATP-CN-001-B (Sections Present Only When Explicitly Enabled)

**Linked Requirement:** REQ-CN-001
**Description:** Verify sections appear only when a specific regulated domain is configured.

* **User Scenario: SCN-CN-001-B1**
  * **Given** a `v-model-config.yml` exists with `domain: iso_26262`
  * **When** the user invokes `/speckit.v-model.architecture-design`
  * **Then** the `architecture-design.md` contains ASIL Decomposition, Defensive Programming, and Temporal & Execution Constraints sections `And` these sections are populated with module-specific analysis

---

### Requirement Validation: REQ-CN-002 (Extension Version and Command Count)

#### Test Case: ATP-CN-002-A (Version Bumped to 0.3.0 with Correct Command Count)

**Linked Requirement:** REQ-CN-002
**Description:** Verify `extension.yml` is bumped to v0.3.0 with exactly 7 commands and 1 hook registered.

* **User Scenario: SCN-CN-002-A1**
  * **Given** all v0.3.0 implementation is complete
  * **When** the user inspects `extension.yml`
  * **Then** the version field reads `0.3.0` `And` exactly 7 commands are registered (5 existing + 2 new: architecture-design, integration-test) `And` 1 hook is registered

---

### Requirement Validation: REQ-CN-003 (PowerShell Script Parity)

#### Test Case: ATP-CN-003-A (Identical Behavior and Output)

**Linked Requirement:** REQ-CN-003
**Description:** Verify `validate-architecture-coverage.ps1` produces identical behavior, output format, and exit codes as the Bash script.

* **User Scenario: SCN-CN-003-A1**
  * **Given** identical test fixture files exist `And` both `validate-architecture-coverage.sh` and `validate-architecture-coverage.ps1` are available
  * **When** the user runs both scripts against the same fixture data
  * **Then** both scripts produce identical output text, identical coverage percentages, and identical exit codes (0 for pass, 1 for fail)

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Requirements | 61 |
| Total Test Cases (ATP) | 86 |
| Total Scenarios (SCN) | 86 |
| REQ → ATP Coverage | 100% |
| ATP → SCN Coverage | 100% |

**Validation Status**: ✅ Full Coverage
**Generated**: 2026-02-21
**Validated by**: `validate-requirement-coverage.sh` (deterministic)

## Uncovered Requirements

None — full coverage achieved.
