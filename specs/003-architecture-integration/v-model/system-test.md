# System Test Plan: Architecture Design ↔ Integration Testing

**Feature Branch**: `003-architecture-integration`
**Created**: 2026-02-21
**Status**: Draft
**Source**: `specs/003-architecture-integration/v-model/system-design.md`

## Overview

This document defines the System Test Plan for the Architecture Design ↔ Integration Testing feature (v0.3.0). Every system component in `system-design.md` has one or more Test Cases (STP), and every Test Case has one or more executable System Scenarios (STS) in technical BDD format (Given/When/Then).

System tests verify **architectural behavior**, not user journeys. Language must be technical and component-oriented. The feature under test comprises 2 new LLM agent commands, 2 templates, 1 trace command extension, 2 matrix builder script extensions (Bash + PowerShell), 2 validation scripts (Bash + PowerShell), setup script extensions, an extension manifest update, and a CI evaluation suite extension.

## ID Schema

- **System Test Case**: `STP-{NNN}-{X}` — where NNN matches the parent SYS, X is a letter suffix (A, B, C...)
- **System Test Scenario**: `STS-{NNN}-{X}{#}` — nested under the parent STP, with numeric suffix (1, 2, 3...)
- Example: `STS-001-A1` → Scenario 1 of Test Case A verifying SYS-001

## ISO 29119 Test Techniques

Each test case MUST identify its technique by name:
- **Interface Contract Testing** — Verifies API contracts from the Interface View
- **Boundary Value Analysis** — Tests data limits from the Data Design View
- **Equivalence Partitioning** — Tests representative data classes
- **Fault Injection** — Tests failure propagation from the Dependency View

## System Tests

### Component Verification: SYS-001 (Architecture Design Command)

**Parent Requirements**: REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-012, REQ-013, REQ-021, REQ-041, REQ-045, REQ-NF-002, REQ-IF-001, REQ-CN-001

#### Test Case: STP-001-A (File I/O Contract Compliance)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that the architecture design command reads exclusively from `{FEATURE_DIR}/v-model/system-design.md` and produces `{FEATURE_DIR}/v-model/architecture-design.md` containing `ARCH-NNN` identifiers with four mandatory 42010/4+1 views (Logical, Process, Interface, Data Flow), many-to-many SYS↔ARCH traceability, `[CROSS-CUTTING]` tagging, derived module flagging, and anti-pattern warnings for incomplete interface contracts.

* **System Scenario: STS-001-A1**
  * **Given** the architecture-design command receives `system-design.md` containing 12 `SYS-NNN` components in the Decomposition View
  * **When** the command executes generation
  * **Then** the command produces `architecture-design.md` containing `ARCH-NNN` identifiers (3-digit zero-padded), a Logical View with "Parent System Components" fields, a Process View with Mermaid sequence diagrams, an Interface View with inputs/outputs/exceptions per module, and a Data Flow View with transformation chains

* **System Scenario: STS-001-A2**
  * **Given** the architecture-design command receives `system-design.md` containing `SYS-NNN` components with many-to-many relationships
  * **When** the command maps SYS components to ARCH modules
  * **Then** each business-logic `ARCH-NNN` traces to one or more `SYS-NNN` via the "Parent System Components" field, and infrastructure modules are tagged `[CROSS-CUTTING]` with a rationale instead of a `SYS-NNN` reference

* **System Scenario: STS-001-A3**
  * **Given** the architecture-design command identifies a technical module that is neither traceable to any `SYS-NNN` nor qualifies as `[CROSS-CUTTING]`
  * **When** the command processes the module during generation
  * **Then** the command flags it as `[DERIVED MODULE: description]` rather than silently creating an `ARCH-NNN` entry

* **System Scenario: STS-001-A4**
  * **Given** the architecture-design command produces an `ARCH-NNN` module with missing inputs, outputs, or exceptions in the Interface View
  * **When** the command evaluates interface contract completeness
  * **Then** the command emits an anti-pattern warning identifying the module with the incomplete contract

#### Test Case: STP-001-B (Large-Scale Input Handling)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verifies that the architecture design command handles input files at and beyond the 50-SYS threshold without truncation, data loss, or degraded output quality in the generated `architecture-design.md`.

* **System Scenario: STS-001-B1**
  * **Given** the architecture-design command receives `system-design.md` containing exactly 50 `SYS-NNN` identifiers
  * **When** the command executes generation
  * **Then** the generated `architecture-design.md` contains at least one `ARCH-NNN` for each of the 50 `SYS-NNN` components, with no truncation of identifiers, views, or traceability fields

* **System Scenario: STS-001-B2**
  * **Given** the architecture-design command receives `system-design.md` containing 51 `SYS-NNN` identifiers
  * **When** the command executes generation
  * **Then** the generated `architecture-design.md` contains complete coverage for all 51 components with identical output quality to the 50-component case

#### Test Case: STP-001-C (Dependency Failure Graceful Degradation)

**Technique**: Fault Injection
**Target View**: Dependency View
**Description**: Verifies that the architecture design command degrades gracefully when its dependencies (SYS-004 template, SYS-009 setup) are unavailable or when input is empty.

* **System Scenario: STS-001-C1**
  * **Given** the architecture-design command is invoked and `architecture-design-template.md` (SYS-004) is not found in the `templates/` directory
  * **When** the command attempts template loading
  * **Then** the command reports an error to the user indicating the template file was not found and does not produce a malformed `architecture-design.md`

* **System Scenario: STS-001-C2**
  * **Given** the architecture-design command receives `system-design.md` that is empty (zero bytes)
  * **When** the command parses the input for `SYS-NNN` identifiers
  * **Then** the command fails gracefully with the message "No system components found in system-design.md — cannot generate architecture design" and does not produce output

* **System Scenario: STS-001-C3**
  * **Given** the architecture-design command receives `system-design.md` containing valid Markdown but zero `SYS-NNN` identifiers
  * **When** the command parses the input for `SYS-NNN` identifiers
  * **Then** the command fails gracefully with the message "No system components found in system-design.md — cannot generate architecture design" and does not produce output

* **System Scenario: STS-001-C4**
  * **Given** the setup script (SYS-009) returns a non-zero exit code because `system-design.md` is missing at the expected path
  * **When** the architecture-design command invokes setup with `--require-system-design`
  * **Then** the command does not proceed with generation and surfaces the setup error message

---

### Component Verification: SYS-002 (Integration Test Command)

**Parent Requirements**: REQ-014, REQ-015, REQ-016, REQ-017, REQ-018, REQ-019, REQ-020, REQ-011, REQ-022, REQ-023, REQ-042, REQ-049, REQ-NF-002, REQ-IF-002, REQ-CN-001

#### Test Case: STP-002-A (File I/O Contract Compliance)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that the integration test command reads exclusively from `{FEATURE_DIR}/v-model/architecture-design.md` and produces `{FEATURE_DIR}/v-model/integration-test.md` containing `ITP-NNN-X` test cases and `ITS-NNN-X#` test scenarios with four mandatory ISO 29119-4 techniques, view anchoring, BDD format, and an embedded coverage validation result.

* **System Scenario: STS-002-A1**
  * **Given** the integration-test command receives `architecture-design.md` containing `ARCH-NNN` modules with four architecture views
  * **When** the command executes generation
  * **Then** the command produces `integration-test.md` containing `ITP-NNN-X` identifiers where NNN matches the parent `ARCH-NNN` and X is a sequential uppercase letter, and `ITS-NNN-X#` identifiers where # is a sequential number nested under the parent ITP

* **System Scenario: STS-002-A2**
  * **Given** the integration-test command generates test cases from `architecture-design.md`
  * **When** the command assigns ISO 29119-4 techniques to each `ITP-NNN-X`
  * **Then** each test case explicitly names one of the four mandatory techniques (Interface Contract Testing, Data Flow Testing, Interface Fault Injection, Concurrency & Race Condition Testing) and references the specific architecture view that drives it

* **System Scenario: STS-002-A3**
  * **Given** the integration-test command generates test scenarios
  * **When** the command formats each `ITS-NNN-X#`
  * **Then** each scenario uses Given/When/Then BDD structure with technical, module-boundary-oriented language and does not contain user-journey phrases

* **System Scenario: STS-002-A4**
  * **Given** the integration-test command receives `architecture-design.md` containing `ARCH-NNN` modules tagged as `[CROSS-CUTTING]`
  * **When** the command generates test cases
  * **Then** each cross-cutting `ARCH-NNN` has at least one `ITP-NNN-X` integration test case

* **System Scenario: STS-002-A5**
  * **Given** the integration-test command completes generation of `integration-test.md`
  * **When** the command invokes `validate-architecture-coverage.sh` (SYS-003) with the three file paths
  * **Then** the coverage gate result (pass/fail with coverage summary) is included in the `integration-test.md` output

#### Test Case: STP-002-B (Large-Scale Input Handling)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verifies that the integration test command handles architecture-design.md files generated from 50+ SYS identifiers without truncation, data loss, or degraded output quality.

* **System Scenario: STS-002-B1**
  * **Given** the integration-test command receives `architecture-design.md` generated from 50 `SYS-NNN` identifiers containing proportionally scaled `ARCH-NNN` modules
  * **When** the command executes generation
  * **Then** the generated `integration-test.md` contains at least one `ITP-NNN-X` for each `ARCH-NNN` with no truncation of test cases, scenarios, or traceability fields

#### Test Case: STP-002-C (Dependency Failure Handling)

**Technique**: Fault Injection
**Target View**: Dependency View
**Description**: Verifies that the integration test command handles failures in its dependencies (SYS-005 template, SYS-003 coverage gate, SYS-009 setup) without producing corrupt output.

* **System Scenario: STS-002-C1**
  * **Given** the integration-test command is invoked and `integration-test-template.md` (SYS-005) is not found in the `templates/` directory
  * **When** the command attempts template loading
  * **Then** the command reports an error to the user indicating the template file was not found and does not produce a malformed `integration-test.md`

* **System Scenario: STS-002-C2**
  * **Given** the integration-test command invokes `validate-architecture-coverage.sh` (SYS-003) and the script exits with code 1 indicating coverage gaps
  * **When** the command processes the validation result
  * **Then** the command includes the gap report in its output, flags incomplete coverage, and does not abort — the validation result is reported as part of `integration-test.md`

* **System Scenario: STS-002-C3**
  * **Given** the setup script (SYS-009) returns a non-zero exit code because prerequisites are missing
  * **When** the integration-test command invokes setup
  * **Then** the command does not proceed with generation and surfaces the setup error message

---

### Component Verification: SYS-003 (Architecture Coverage Validation Script — Bash)

**Parent Requirements**: REQ-024, REQ-025, REQ-026, REQ-027, REQ-028, REQ-029, REQ-030, REQ-011, REQ-046, REQ-048, REQ-NF-001, REQ-NF-003, REQ-IF-003, REQ-IF-004

#### Test Case: STP-003-A (CLI Contract Compliance)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that `validate-architecture-coverage.sh` accepts three positional file path arguments, supports `--json` output mode, outputs human-readable gap reports to stdout, and exits with code 0 on pass / code 1 on failure.

* **System Scenario: STS-003-A1**
  * **Given** `validate-architecture-coverage.sh` receives three file paths: `system-design.md` (containing 5 SYS identifiers), `architecture-design.md` (containing ARCH modules covering all 5 SYS), and `integration-test.md` (containing ITP cases covering all ARCH modules)
  * **When** the script executes forward and backward coverage validation
  * **Then** the script outputs a coverage summary with 100% forward and backward percentages and exits with code 0

* **System Scenario: STS-003-A2**
  * **Given** `validate-architecture-coverage.sh` receives three file paths where `architecture-design.md` is missing an `ARCH-NNN` mapping for `SYS-003`
  * **When** the script executes forward coverage validation
  * **Then** the script outputs a human-readable gap report containing "SYS-003: no architecture module mapping found" and exits with code 1

* **System Scenario: STS-003-A3**
  * **Given** `validate-architecture-coverage.sh` receives three file paths and the `--json` flag
  * **When** the script executes all coverage checks
  * **Then** the script outputs a JSON-structured report with forward/backward coverage percentages, gap lists, orphan lists, and a pass/fail verdict field

* **System Scenario: STS-003-A4**
  * **Given** `validate-architecture-coverage.sh` receives three file paths where `integration-test.md` contains an `ITP-005-A` whose parent `ARCH-005` does not exist in `architecture-design.md`
  * **When** the script executes orphan detection
  * **Then** the script reports the orphaned `ITP-005-A` by ID in the gap report and exits with code 1

* **System Scenario: STS-003-A5**
  * **Given** `validate-architecture-coverage.sh` receives three file paths where `architecture-design.md` contains `ARCH-007` not referenced as a parent in any `SYS-NNN` or `[CROSS-CUTTING]` tag
  * **When** the script executes orphan detection
  * **Then** the script reports the orphaned `ARCH-007` by ID in the gap report and exits with code 1

#### Test Case: STP-003-B (Data Boundary Handling)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verifies that the validation script handles gaps in ARCH numbering without false positives, supports partial execution when `integration-test.md` is absent, and validates ID lineage consistency.

* **System Scenario: STS-003-B1**
  * **Given** `validate-architecture-coverage.sh` receives `architecture-design.md` containing `ARCH-001`, `ARCH-003`, `ARCH-005` (gaps at ARCH-002 and ARCH-004) with all SYS components covered
  * **When** the script executes forward coverage validation
  * **Then** the script does not report false-positive errors for the missing ARCH-002 and ARCH-004 and exits with code 0 if all SYS identifiers have at least one ARCH mapping

* **System Scenario: STS-003-B2**
  * **Given** `validate-architecture-coverage.sh` receives two file paths (`system-design.md` and `architecture-design.md`) with `integration-test.md` omitted or not found
  * **When** the script executes in partial mode
  * **Then** the script validates only forward coverage (SYS → ARCH), bypasses backward coverage and orphan checks for integration artifacts, and exits with code 0 if forward coverage is complete

* **System Scenario: STS-003-B3**
  * **Given** `validate-architecture-coverage.sh` receives valid files and an `ITS-003-B2` identifier in `integration-test.md`
  * **When** the script extracts ID lineage via regex
  * **Then** the script correctly determines `ITP-003-B` as the parent and `ARCH-003` as the grandparent without consulting a lookup table, and resolves `SYS-NNN` ancestor(s) by consulting the "Parent System Components" field in `architecture-design.md`

#### Test Case: STP-003-C (Circular Dependency Detection)

**Technique**: Fault Injection
**Target View**: Dependency View
**Description**: Verifies that the validation script detects and reports circular dependencies in the Process View without entering an infinite loop.

* **System Scenario: STS-003-C1**
  * **Given** `validate-architecture-coverage.sh` receives `architecture-design.md` containing a circular dependency chain in the Process View (e.g., ARCH-001 → ARCH-002 → ARCH-003 → ARCH-001)
  * **When** the script executes circular dependency detection
  * **Then** the script reports the circular dependency by listing the involved ARCH identifiers and exits with code 1 without hanging

---

### Component Verification: SYS-004 (Architecture Design Template)

**Parent Requirements**: REQ-039, REQ-003, REQ-004, REQ-005, REQ-006, REQ-009, REQ-010, REQ-021

#### Test Case: STP-004-A (Template Structure Compliance)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that `architecture-design-template.md` contains the required section structure and field definitions for all four mandatory 42010/4+1 views that SYS-001 loads during generation.

* **System Scenario: STS-004-A1**
  * **Given** the `architecture-design-template.md` file exists in the `templates/` directory
  * **When** the template is parsed for section headers
  * **Then** the template contains sections for Logical View (with ARCH-NNN, name, description, Parent System Components, and `[CROSS-CUTTING]` tag fields), Process View (with Mermaid sequence diagram placeholders), Interface View (with inputs, outputs, exceptions per module), and Data Flow View (with data transformation chain structure)

* **System Scenario: STS-004-A2**
  * **Given** the `architecture-design-template.md` file exists in the `templates/` directory
  * **When** the template is parsed for conditional sections
  * **Then** the template contains conditional safety-critical section placeholders for ASIL Decomposition, Defensive Programming, and Temporal & Execution Constraints

#### Test Case: STP-004-B (Template Field Completeness)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verifies that the template defines all required fields and placeholders necessary for ISO/IEC/IEEE 42010-compliant output, including the distinction between business-logic and cross-cutting modules.

* **System Scenario: STS-004-B1**
  * **Given** the `architecture-design-template.md` file is read as a Markdown document
  * **When** the Logical View section is inspected
  * **Then** the section contains field definitions that distinguish business-logic modules (with explicit SYS parents) from cross-cutting modules (with `[CROSS-CUTTING]` tag and rationale field)

---

### Component Verification: SYS-005 (Integration Test Template)

**Parent Requirements**: REQ-040, REQ-049, REQ-015, REQ-016, REQ-017, REQ-018, REQ-019, REQ-022

#### Test Case: STP-005-A (Template Structure Compliance)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that `integration-test-template.md` contains the required three-tier ITP/ITS hierarchy, technique naming, view anchoring, BDD format definitions, and test harness strategy section that SYS-002 loads during generation.

* **System Scenario: STS-005-A1**
  * **Given** the `integration-test-template.md` file exists in the `templates/` directory
  * **When** the template is parsed for section headers and field definitions
  * **Then** the template contains the three-tier hierarchy structure (ARCH → ITP-NNN-X → ITS-NNN-X#), technique naming fields, architecture view anchoring fields, Given/When/Then BDD scenario format with module-boundary language, and a "Test Harness & Mocking Strategy" section defining stubs/mocks for external interfaces and unresolved dependencies

* **System Scenario: STS-005-A2**
  * **Given** the `integration-test-template.md` file exists in the `templates/` directory
  * **When** the template is parsed for conditional sections
  * **Then** the template contains conditional safety-critical section placeholders for SIL/HIL Compatibility and Resource Contention

#### Test Case: STP-005-B (Template Technique Coverage)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verifies that the template includes structural support for all four mandatory ISO 29119-4 techniques.

* **System Scenario: STS-005-B1**
  * **Given** the `integration-test-template.md` file is read as a Markdown document
  * **When** the technique definition sections are inspected
  * **Then** the template references or provides structural support for Interface Contract Testing, Data Flow Testing, Interface Fault Injection, and Concurrency & Race Condition Testing

---

### Component Verification: SYS-006 (Trace Command Extension)

**Parent Requirements**: REQ-031, REQ-032, REQ-033, REQ-034, REQ-035, REQ-036, REQ-047, REQ-NF-004

#### Test Case: STP-006-A (Matrix C Generation Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that the trace command extension produces Matrix C (SYS → ARCH → ITP → ITS) with REQ references, cross-cutting pseudo-rows, and independent coverage percentages when all architecture-level artifacts exist.

* **System Scenario: STS-006-A1**
  * **Given** the trace command receives `architecture-design.md` and `integration-test.md` in addition to existing v0.2.0 artifacts in `{FEATURE_DIR}/v-model/`
  * **When** the trace command generates the traceability matrix
  * **Then** the output contains Matrix A (REQ → ATP → SCN), Matrix B (REQ → SYS → STP → STS), and Matrix C (SYS → ARCH → ITP → ITS) as three separate Markdown tables, each with independently calculated coverage percentages

* **System Scenario: STS-006-A2**
  * **Given** the trace command generates Matrix C and `architecture-design.md` contains both business-logic `ARCH-NNN` modules and `[CROSS-CUTTING]` modules
  * **When** the command populates the Matrix C rows
  * **Then** each `SYS-NNN` cell includes comma-separated parent `REQ-NNN` identifiers in parentheses, and cross-cutting ARCH modules appear as pseudo-rows with `N/A (Cross-Cutting)` in the SYS column

#### Test Case: STP-006-B (Progressive Matrix Generation)

**Technique**: Equivalence Partitioning
**Target View**: Data Design View
**Description**: Verifies that the trace command builds matrices progressively based on which artifacts are available, representing three equivalence classes of artifact availability.

* **System Scenario: STS-006-B1**
  * **Given** the trace command receives only `requirements.md` and `acceptance-plan.md` in `{FEATURE_DIR}/v-model/`
  * **When** the trace command generates the traceability matrix
  * **Then** the output contains only Matrix A (REQ → ATP → SCN) with no Matrix B or Matrix C

* **System Scenario: STS-006-B2**
  * **Given** the trace command receives v0.2.0 artifacts (`requirements.md`, `acceptance-plan.md`, `system-design.md`, `system-test.md`) but no `architecture-design.md` or `integration-test.md`
  * **When** the trace command generates the traceability matrix
  * **Then** the output contains Matrix A and Matrix B only, with no Matrix C and no warning about missing architecture artifacts

* **System Scenario: STS-006-B3**
  * **Given** the trace command receives all v0.2.0 artifacts plus `architecture-design.md` and `integration-test.md`
  * **When** the trace command generates the traceability matrix
  * **Then** the output contains Matrix A, Matrix B, and Matrix C with all three coverage percentages independently calculated

#### Test Case: STP-006-C (Dependency Failure and Backward Compatibility)

**Technique**: Fault Injection
**Target View**: Dependency View
**Description**: Verifies backward compatibility when architecture-level artifacts or matrix builder scripts are absent, and partial Matrix C generation when only architecture-design.md exists.

* **System Scenario: STS-006-C1**
  * **Given** the trace command is invoked on a repository with only v0.2.0 artifacts (no `architecture-design.md`, no `integration-test.md`)
  * **When** the trace command generates the traceability matrix
  * **Then** the command produces identical output to v0.2.0 (Matrix A + Matrix B only) with no errors, warnings, or behavioral changes

* **System Scenario: STS-006-C2**
  * **Given** the trace command receives `architecture-design.md` but `integration-test.md` does not exist
  * **When** the trace command generates Matrix C
  * **Then** Matrix C includes the ARCH column populated from `architecture-design.md`, with ITP and ITS columns empty and a note "Integration test plan not yet generated."

* **System Scenario: STS-006-C3**
  * **Given** the trace command invokes `build-matrix.sh` (SYS-007) and the script returns a non-zero exit code due to malformed input files
  * **When** the trace command processes the Matrix C generation failure
  * **Then** the trace command reports the Matrix C generation failure without crashing and still produces Matrix A and Matrix B

---

### Component Verification: SYS-007 (Matrix Builder Script Extension — Bash)

**Parent Requirements**: REQ-037, REQ-036

#### Test Case: STP-007-A (Matrix C Data Output Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that the `build-matrix.sh` extension parses `architecture-design.md` and `integration-test.md` and outputs structured Matrix C data (SYS → ARCH → ITP → ITS mappings) to stdout via shell exec.

* **System Scenario: STS-007-A1**
  * **Given** `build-matrix.sh` receives `architecture-design.md` containing 10 `ARCH-NNN` modules and `integration-test.md` containing corresponding `ITP-NNN-X` test cases
  * **When** the script executes Matrix C data generation
  * **Then** the script outputs structured text to stdout containing SYS → ARCH → ITP → ITS mappings with independently calculated coverage percentages and exits with code 0

* **System Scenario: STS-007-A2**
  * **Given** `build-matrix.sh` receives `architecture-design.md` that is malformed (missing Logical View section headers)
  * **When** the script attempts to parse the file
  * **Then** the script returns a non-zero exit code and reports the parse failure to stderr

#### Test Case: STP-007-B (Coverage Percentage Accuracy)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verifies that the matrix builder calculates coverage percentages that match the validation script output.

* **System Scenario: STS-007-B1**
  * **Given** `build-matrix.sh` receives files where 8 out of 10 ARCH modules have at least one ITP test case
  * **When** the script calculates backward coverage
  * **Then** the script outputs a backward coverage percentage of 80% matching the value that `validate-architecture-coverage.sh` (SYS-003) would produce for the same input files

---

### Component Verification: SYS-008 (Matrix Builder Script Extension — PowerShell)

**Parent Requirements**: REQ-038

#### Test Case: STP-008-A (Cross-Platform Parity with Bash)

**Technique**: Equivalence Partitioning
**Target View**: Data Design View
**Description**: Verifies that `build-matrix.ps1` produces identical Matrix C output to `build-matrix.sh` (SYS-007) for the same input files, ensuring cross-platform parity for enterprise Windows teams.

* **System Scenario: STS-008-A1**
  * **Given** `build-matrix.ps1` receives the same `architecture-design.md` and `integration-test.md` files used for STS-007-A1
  * **When** the script executes Matrix C data generation
  * **Then** the script outputs structured text to stdout with identical SYS → ARCH → ITP → ITS mappings and identical coverage percentages as `build-matrix.sh`

#### Test Case: STP-008-B (Output Divergence Detection)

**Technique**: Fault Injection
**Target View**: Dependency View
**Description**: Verifies that behavioral divergence between the PowerShell and Bash matrix builders is detectable by comparing outputs for the same input.

* **System Scenario: STS-008-B1**
  * **Given** `build-matrix.ps1` and `build-matrix.sh` both receive `architecture-design.md` containing `[CROSS-CUTTING]` modules and modules with many-to-many SYS relationships
  * **When** both scripts execute Matrix C data generation
  * **Then** the structured text outputs are byte-comparable after line-ending normalization, producing identical mappings and coverage percentages

---

### Component Verification: SYS-009 (Setup Script Extensions)

**Parent Requirements**: REQ-043, REQ-044, REQ-NF-004

#### Test Case: STP-009-A (Extended CLI Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that `setup-v-model.sh` and `setup-v-model.ps1` support the `--require-system-design` flag and detect `architecture-design.md` and `integration-test.md` in `AVAILABLE_DOCS`.

* **System Scenario: STS-009-A1**
  * **Given** `setup-v-model.sh` is invoked with `--require-system-design` and `system-design.md` exists at the expected `{FEATURE_DIR}/v-model/` path
  * **When** the setup script validates prerequisites
  * **Then** the script returns exit code 0 and outputs a JSON object containing `VMODEL_DIR`, `FEATURE_DIR`, `BRANCH`, and `AVAILABLE_DOCS` keys

* **System Scenario: STS-009-A2**
  * **Given** `setup-v-model.sh` is invoked with `--require-system-design` and `system-design.md` does not exist at the expected path
  * **When** the setup script validates prerequisites
  * **Then** the script returns a non-zero exit code with an error message indicating `system-design.md` is missing

* **System Scenario: STS-009-A3**
  * **Given** `setup-v-model.sh` is invoked and `architecture-design.md` and `integration-test.md` both exist in `{FEATURE_DIR}/v-model/`
  * **When** the setup script detects available documents
  * **Then** the `AVAILABLE_DOCS` field in the JSON output includes both `architecture-design.md` and `integration-test.md`

#### Test Case: STP-009-B (Backward Compatibility)

**Technique**: Fault Injection
**Target View**: Dependency View
**Description**: Verifies that existing v0.2.0 invocations of the setup scripts produce unchanged behavior after the v0.3.0 extensions.

* **System Scenario: STS-009-B1**
  * **Given** `setup-v-model.sh` is invoked without the `--require-system-design` flag and without any architecture-level artifacts present
  * **When** the setup script executes with v0.2.0-style arguments
  * **Then** the script produces identical output and exit code behavior as v0.2.0, with no errors or warnings related to missing architecture-level artifacts

* **System Scenario: STS-009-B2**
  * **Given** `setup-v-model.ps1` is invoked without the `-RequireSystemDesign` parameter and without architecture-level artifacts
  * **When** the setup script executes with v0.2.0-style arguments
  * **Then** the script produces identical output and exit code behavior as v0.2.0

---

### Component Verification: SYS-010 (Architecture Coverage Validation Script — PowerShell)

**Parent Requirements**: REQ-CN-003, REQ-IF-003, REQ-IF-004

#### Test Case: STP-010-A (CLI Contract Compliance — PowerShell)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that `validate-architecture-coverage.ps1` accepts the same three positional file path arguments and `-Json` flag as the Bash version (SYS-003), with identical output format and exit code behavior.

* **System Scenario: STS-010-A1**
  * **Given** `validate-architecture-coverage.ps1` receives three file paths: `system-design.md` (containing 5 SYS identifiers), `architecture-design.md` (full ARCH coverage), and `integration-test.md` (full ITP coverage)
  * **When** the script executes forward and backward coverage validation
  * **Then** the script outputs a coverage summary in the same format as SYS-003 and exits with code 0

* **System Scenario: STS-010-A2**
  * **Given** `validate-architecture-coverage.ps1` receives three file paths where a coverage gap exists and the `-Json` flag
  * **When** the script executes all coverage checks
  * **Then** the script outputs a JSON-structured report with identical schema to the `--json` output of `validate-architecture-coverage.sh` (SYS-003) and exits with code 1

#### Test Case: STP-010-B (Cross-Platform Parity with Bash)

**Technique**: Fault Injection
**Target View**: Dependency View
**Description**: Verifies that the PowerShell validation script (SYS-010) produces identical results to the Bash validation script (SYS-003) for the same test fixture suite, ensuring no behavioral divergence.

* **System Scenario: STS-010-B1**
  * **Given** `validate-architecture-coverage.ps1` and `validate-architecture-coverage.sh` both receive the same fixture files containing full coverage, coverage gaps, orphaned identifiers, and gaps in ARCH numbering
  * **When** both scripts execute all validation checks
  * **Then** both scripts produce identical pass/fail verdicts, identical gap report content (after line-ending normalization), and identical exit codes for each fixture

* **System Scenario: STS-010-B2**
  * **Given** `validate-architecture-coverage.ps1` receives files with a circular dependency in the Process View
  * **When** the script executes circular dependency detection
  * **Then** the script detects the circular dependency, reports the involved ARCH identifiers, and exits with code 1 without hanging — matching the behavior of SYS-003

---

### Component Verification: SYS-011 (Extension Manifest Update)

**Parent Requirements**: REQ-CN-002

#### Test Case: STP-011-A (Manifest Version and Registration)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verifies that `extension.yml` and `catalog-entry.json` contain version `0.3.0` and register exactly 7 commands (5 existing + 2 new: `architecture-design`, `integration-test`) and 1 hook.

* **System Scenario: STS-011-A1**
  * **Given** `extension.yml` is read from the repository root
  * **When** the version field is inspected
  * **Then** the version value is exactly `0.3.0`

* **System Scenario: STS-011-A2**
  * **Given** `extension.yml` is read from the repository root
  * **When** the registered commands list is inspected
  * **Then** the manifest registers exactly 7 commands including `architecture-design` and `integration-test` as the 2 new entries, and exactly 1 hook

* **System Scenario: STS-011-A3**
  * **Given** `catalog-entry.json` is read from the repository
  * **When** the version field is inspected
  * **Then** the version value is exactly `0.3.0`

---

### Component Verification: SYS-012 (CI Evaluation Suite Extension)

**Parent Requirements**: REQ-NF-005

#### Test Case: STP-012-A (Output Regression Detection)

**Technique**: Fault Injection
**Target View**: Dependency View
**Description**: Verifies that the CI evaluation suite detects quality regressions in `/speckit.v-model.architecture-design` and `/speckit.v-model.integration-test` command outputs when SYS-001 or SYS-002 output format changes.

* **System Scenario: STS-012-A1**
  * **Given** the CI evaluation suite receives `architecture-design.md` output from SYS-001 that meets v0.2.0 quality thresholds (correct ARCH-NNN identifiers, complete four-view structure, valid traceability)
  * **When** the evaluation suite executes its validation assertions
  * **Then** the suite reports a pass verdict with all quality checks satisfied

* **System Scenario: STS-012-A2**
  * **Given** the CI evaluation suite receives `architecture-design.md` output from SYS-001 that is missing the Interface View section
  * **When** the evaluation suite executes its validation assertions
  * **Then** the suite reports a failure verdict identifying the missing Interface View as a structural regression

* **System Scenario: STS-012-A3**
  * **Given** the CI evaluation suite receives `integration-test.md` output from SYS-002 that meets v0.2.0 quality thresholds
  * **When** the evaluation suite executes its validation assertions
  * **Then** the suite reports a pass verdict with all quality checks satisfied

#### Test Case: STP-012-B (Mermaid Syntax Validation)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verifies that the CI evaluation suite validates the syntactic correctness of generated Mermaid diagrams in the Process View and treats broken Mermaid syntax as a structural failure.

* **System Scenario: STS-012-B1**
  * **Given** the CI evaluation suite receives `architecture-design.md` containing a Process View with syntactically valid Mermaid sequence diagrams
  * **When** the evaluation suite executes Mermaid syntax validation
  * **Then** the suite reports no Mermaid-related failures

* **System Scenario: STS-012-B2**
  * **Given** the CI evaluation suite receives `architecture-design.md` containing a Process View with a broken Mermaid diagram (e.g., unclosed `sequenceDiagram` block, invalid arrow syntax)
  * **When** the evaluation suite executes Mermaid syntax validation
  * **Then** the suite treats the broken Mermaid syntax as a structural failure and reports the specific diagram location

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total System Components (SYS) | 12 |
| Total Test Cases (STP) | 27 |
| Total Scenarios (STS) | 64 |
| Components with ≥1 STP | 12 / 12 (100%) |
| Test Cases with ≥1 STS | 27 / 27 (100%) |
| **Overall Coverage (SYS→STP)** | **100%** |

## Uncovered Components

None — full coverage achieved.
