# System Test Plan: Module Design ↔ Unit Testing

**Feature Branch**: `004-module-unit-testing`
**Created**: 2026-02-21
**Status**: Draft
**Source**: `specs/004-module-unit/v-model/system-design.md`

## Overview

This document defines the System Test Plan for the Module Design ↔ Unit Testing feature (v0.4.0). Every system component in `system-design.md` has one or more Test Cases (STP), and every Test Case has one or more executable System Scenarios (STS) in technical BDD format (Given/When/Then).

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

### Component Verification: SYS-001 (Module Design Command)

**Parent Requirements**: REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-041, REQ-043, REQ-NF-002, REQ-IF-001, REQ-CN-001, REQ-CN-004

#### Test Case: STP-001-A (File I/O Contract and Four Mandatory Views)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that the module design command reads exclusively from `{FEATURE_DIR}/v-model/architecture-design.md` and produces `{FEATURE_DIR}/v-model/module-design.md` containing `MOD-NNN` identifiers with four mandatory views (Algorithmic/Logic with fenced pseudocode blocks, State Machine with Mermaid or stateless bypass, Internal Data Structures, Error Handling), Target Source File(s) property, Parent Architecture Modules field, many-to-many ARCH↔MOD traceability, `[CROSS-CUTTING]` full decomposition, `[EXTERNAL]` wrapper-only documentation, derived module flagging, and strict translator compliance.

* **System Scenario: STS-001-A1**
  * **Given** the module-design command receives `architecture-design.md` containing 8 `ARCH-NNN` modules with four architecture views
  * **When** the command executes generation
  * **Then** the command produces `module-design.md` containing `MOD-NNN` identifiers (3-digit zero-padded), each with an Algorithmic/Logic View containing a fenced ` ```pseudocode ``` ` block, a State Machine View (Mermaid `stateDiagram-v2` or broad-regex stateless bypass), an Internal Data Structures section with explicit types/sizes/constraints, and an Error Handling section mapped to Architecture Interface View contracts

* **System Scenario: STS-001-A2**
  * **Given** the module-design command receives `architecture-design.md` containing `ARCH-NNN` modules with many-to-many SYS↔ARCH relationships
  * **When** the command maps ARCH modules to MOD designs
  * **Then** each `MOD-NNN` includes a "Parent Architecture Modules" field listing one or more `ARCH-NNN` identifiers, and a "Target Source File(s)" property with comma-separated file paths for header/implementation pairs

* **System Scenario: STS-001-A3**
  * **Given** the module-design command receives `architecture-design.md` containing an `ARCH-NNN` module tagged `[CROSS-CUTTING]`
  * **When** the command decomposes the module
  * **Then** the resulting `MOD-NNN` inherits the `[CROSS-CUTTING]` tag and includes complete pseudocode in its Algorithmic/Logic View, not abbreviated documentation

* **System Scenario: STS-001-A4**
  * **Given** the module-design command receives `architecture-design.md` containing an `ARCH-NNN` module representing a third-party library (e.g., AWS S3 driver)
  * **When** the command decomposes the module
  * **Then** the resulting `MOD-NNN` is tagged `[EXTERNAL]` and documents only the wrapper/configuration interface, omitting deep algorithmic pseudocode for the library internals

* **System Scenario: STS-001-A5**
  * **Given** the module-design command identifies a technical module that is neither traceable to any `ARCH-NNN` nor qualifies as `[CROSS-CUTTING]`
  * **When** the command processes the module during generation
  * **Then** the command flags it as `[DERIVED MODULE: description]` rather than silently creating a `MOD-NNN` entry

* **System Scenario: STS-001-A6**
  * **Given** the module-design command generates a `MOD-NNN` whose Algorithmic/Logic View contains only descriptive prose without a fenced ` ```pseudocode ``` ` block
  * **When** the command evaluates structural compliance
  * **Then** the command rejects the output as a structural failure — the absence of a fenced pseudocode block is not accepted

* **System Scenario: STS-001-A7**
  * **Given** the module-design command generates a stateless utility function `MOD-NNN`
  * **When** the command populates the State Machine View
  * **Then** the State Machine View contains a broad-regex-matchable stateless bypass string (matching `(?i)N/?A.*Stateless`) instead of an empty section or Mermaid diagram

#### Test Case: STP-001-B (Safety-Critical Conditional Sections)

**Technique**: Equivalence Partitioning
**Target View**: Data Design View
**Description**: Verifies that safety-critical sections (Complexity Constraints, Memory Management, Single Entry/Exit) are conditionally included or excluded based on domain configuration.

* **System Scenario: STS-001-B1**
  * **Given** `v-model-config.yml` has `domain` set to `do_178c` `And` the module-design command receives `architecture-design.md`
  * **When** the command generates `module-design.md`
  * **Then** each `MOD-NNN` includes Complexity Constraints (cyclomatic complexity ≤ 10), Memory Management (no dynamic allocation post-init), and Single Entry/Exit (one return point) sections

* **System Scenario: STS-001-B2**
  * **Given** `v-model-config.yml` is absent or has no `domain` field `And` the module-design command receives `architecture-design.md`
  * **When** the command generates `module-design.md`
  * **Then** no safety-critical sections (Complexity Constraints, Memory Management, Single Entry/Exit) appear in the output

#### Test Case: STP-001-C (Large-Scale Input Handling)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verifies that the module design command handles input files at and beyond the 50-ARCH threshold without truncation, data loss, or degraded output quality.

* **System Scenario: STS-001-C1**
  * **Given** the module-design command receives `architecture-design.md` containing exactly 50 `ARCH-NNN` identifiers
  * **When** the command executes generation
  * **Then** the generated `module-design.md` contains at least one `MOD-NNN` for each of the 50 `ARCH-NNN` modules, with no truncation of identifiers, views, or traceability fields

* **System Scenario: STS-001-C2**
  * **Given** the module-design command receives `architecture-design.md` containing 51 `ARCH-NNN` identifiers
  * **When** the command executes generation
  * **Then** the generated `module-design.md` contains complete coverage for all 51 modules with identical output quality to the 50-module case

#### Test Case: STP-001-D (Dependency Failure Graceful Degradation)

**Technique**: Fault Injection
**Target View**: Dependency View
**Description**: Verifies that the module design command degrades gracefully when its dependencies (SYS-004 template, SYS-009 setup) are unavailable or when input is empty.

* **System Scenario: STS-001-D1**
  * **Given** the module-design command is invoked and `module-design-template.md` (SYS-004) is not found in the `templates/` directory
  * **When** the command attempts template loading
  * **Then** the command reports an error to the user indicating the template file was not found and does not produce a malformed `module-design.md`

* **System Scenario: STS-001-D2**
  * **Given** the module-design command receives `architecture-design.md` that is empty (zero bytes)
  * **When** the command parses the input for `ARCH-NNN` identifiers
  * **Then** the command fails gracefully with the message "No architecture modules found in architecture-design.md — cannot generate module design" and does not produce output

* **System Scenario: STS-001-D3**
  * **Given** the module-design command receives `architecture-design.md` containing valid Markdown but zero `ARCH-NNN` identifiers
  * **When** the command parses the input for `ARCH-NNN` identifiers
  * **Then** the command fails gracefully with the message "No architecture modules found in architecture-design.md — cannot generate module design" and does not produce output

* **System Scenario: STS-001-D4**
  * **Given** the setup script (SYS-009) returns a non-zero exit code because `architecture-design.md` is missing at the expected path
  * **When** the module-design command invokes setup with `--require-module-design`
  * **Then** the command does not proceed with generation and surfaces the setup error message

---

### Component Verification: SYS-002 (Unit Test Command)

**Parent Requirements**: REQ-017, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-028, REQ-029, REQ-030, REQ-031, REQ-032, REQ-042, REQ-NF-002, REQ-IF-002, REQ-CN-001, REQ-CN-004

#### Test Case: STP-002-A (File I/O Contract and White-Box Techniques)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that the unit test command reads exclusively from `{FEATURE_DIR}/v-model/module-design.md` and produces `{FEATURE_DIR}/v-model/unit-test.md` containing `UTP-NNN-X` test cases and `UTS-NNN-X#` test scenarios with ISO 29119-4 white-box techniques, Dependency & Mock Registry per test case, Arrange/Act/Assert format, `[EXTERNAL]` module bypass, and an embedded coverage validation result.

* **System Scenario: STS-002-A1**
  * **Given** the unit-test command receives `module-design.md` containing `MOD-NNN` modules with four mandatory views
  * **When** the command executes generation
  * **Then** the command produces `unit-test.md` containing `UTP-NNN-X` identifiers where NNN matches the parent `MOD-NNN` and X is a sequential uppercase letter, and `UTS-NNN-X#` identifiers where # is a sequential number nested under the parent UTP

* **System Scenario: STS-002-A2**
  * **Given** the unit-test command generates test cases from `module-design.md`
  * **When** the command assigns ISO 29119-4 white-box techniques to each `UTP-NNN-X`
  * **Then** each test case explicitly names one of the mandatory techniques (Statement & Branch Coverage, Boundary Value Analysis, Equivalence Partitioning, Strict Isolation, State Transition Testing) and references the specific module design view that drives it

* **System Scenario: STS-002-A3**
  * **Given** the unit-test command generates test scenarios
  * **When** the command formats each `UTS-NNN-X#`
  * **Then** each scenario uses Arrange/Act/Assert structure with white-box, implementation-oriented language distinct from BDD Given/When/Then

* **System Scenario: STS-002-A4**
  * **Given** the unit-test command receives `module-design.md` containing a `MOD-NNN` with external dependencies listed in the Architecture Interface View
  * **When** the command generates test cases for that module
  * **Then** each `UTP-NNN-X` includes a "Dependency & Mock Registry" table explicitly listing all external dependencies with their mock/stub strategy

* **System Scenario: STS-002-A5**
  * **Given** the unit-test command receives `module-design.md` containing a `MOD-NNN` that interfaces with hardware (GPIO, memory-mapped registers)
  * **When** the command generates the Dependency & Mock Registry
  * **Then** the registry explicitly includes the hardware interfaces as dependencies requiring mocking/stubbing

* **System Scenario: STS-002-A6**
  * **Given** the unit-test command receives `module-design.md` containing a self-contained `MOD-NNN` with no external dependencies
  * **When** the command generates test cases for that module
  * **Then** the Dependency & Mock Registry contains "None — module is self-contained"

* **System Scenario: STS-002-A7**
  * **Given** the unit-test command receives `module-design.md` containing a `MOD-NNN` tagged `[EXTERNAL]`
  * **When** the command processes the module
  * **Then** the command skips unit test generation for that module with a note "Module MOD-NNN is [EXTERNAL] — wrapper behavior tested at integration level"

* **System Scenario: STS-002-A8**
  * **Given** the unit-test command completes generation of `unit-test.md`
  * **When** the command invokes `validate-module-coverage.sh` (SYS-003) with the three file paths
  * **Then** the coverage gate result (pass/fail with coverage summary) is included in the `unit-test.md` output

* **System Scenario: STS-002-A9**
  * **Given** the unit-test command generates test scenarios for a `MOD-NNN` with Internal Data Structures specifying integer ranges (e.g., 1-100)
  * **When** the command applies Boundary Value Analysis
  * **Then** the test scenarios target 0, 1, 50, 100, and 101 (min-1, min, mid, max, max+1) for scalar types

* **System Scenario: STS-002-A10**
  * **Given** the unit-test command generates test scenarios for a `MOD-NNN` with Internal Data Structures specifying Boolean or Enum types
  * **When** the command applies test technique selection
  * **Then** the command applies Equivalence Partitioning (not BVA) since boundaries do not logically exist for non-scalar types

#### Test Case: STP-002-B (Safety-Critical MC/DC and Fault Injection)

**Technique**: Equivalence Partitioning
**Target View**: Data Design View
**Description**: Verifies that safety-critical unit test sections (MC/DC truth tables, variable-level fault injection) are conditionally included based on domain configuration.

* **System Scenario: STS-002-B1**
  * **Given** `v-model-config.yml` has `domain` set to `do_178c` `And` the unit-test command receives `module-design.md` containing a `MOD-NNN` with a complex boolean decision (e.g., `if (A and B or C)`)
  * **When** the command generates unit test cases
  * **Then** the output includes an explicit MC/DC truth table proving each individual condition (A, B, C) can independently affect the decision outcome

* **System Scenario: STS-002-B2**
  * **Given** `v-model-config.yml` has `domain` set to `iso_26262` `And` the unit-test command receives `module-design.md`
  * **When** the command generates unit test cases
  * **Then** the output includes variable-level fault injection scenarios forcing local variables into corrupted states to test internal error handling

* **System Scenario: STS-002-B3**
  * **Given** `v-model-config.yml` is absent or has no `domain` field
  * **When** the unit-test command generates test cases
  * **Then** no MC/DC truth tables or variable-level fault injection scenarios appear in the output

#### Test Case: STP-002-C (Large-Scale Input Handling)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verifies that the unit test command handles module-design.md files generated from 50+ ARCH identifiers without truncation or degraded output quality.

* **System Scenario: STS-002-C1**
  * **Given** the unit-test command receives `module-design.md` generated from 50 `ARCH-NNN` identifiers containing proportionally scaled `MOD-NNN` modules
  * **When** the command executes generation
  * **Then** the generated `unit-test.md` contains at least one `UTP-NNN-X` for each non-EXTERNAL `MOD-NNN` with no truncation of test cases, scenarios, or mock registries

#### Test Case: STP-002-D (Dependency Failure Handling)

**Technique**: Fault Injection
**Target View**: Dependency View
**Description**: Verifies that the unit test command handles failures in its dependencies (SYS-005 template, SYS-003 coverage gate, SYS-009 setup) without producing corrupt output.

* **System Scenario: STS-002-D1**
  * **Given** the unit-test command is invoked and `unit-test-template.md` (SYS-005) is not found in the `templates/` directory
  * **When** the command attempts template loading
  * **Then** the command reports an error to the user indicating the template file was not found and does not produce a malformed `unit-test.md`

* **System Scenario: STS-002-D2**
  * **Given** the unit-test command invokes `validate-module-coverage.sh` (SYS-003) and the script exits with code 1 indicating coverage gaps
  * **When** the command processes the validation result
  * **Then** the command includes the gap report in its output, flags incomplete coverage, and does not abort — the validation result is reported as part of `unit-test.md`

* **System Scenario: STS-002-D3**
  * **Given** the setup script (SYS-009) returns a non-zero exit code because prerequisites are missing
  * **When** the unit-test command invokes setup
  * **Then** the command does not proceed with generation and surfaces the setup error message

---

### Component Verification: SYS-003 (Module Coverage Validation Script — Bash)

**Parent Requirements**: REQ-033, REQ-034, REQ-035, REQ-036, REQ-037, REQ-038, REQ-039, REQ-040, REQ-006, REQ-031, REQ-032, REQ-NF-001, REQ-NF-003, REQ-IF-003, REQ-IF-004, REQ-CN-004

#### Test Case: STP-003-A (CLI Contract Compliance)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that `validate-module-coverage.sh` accepts three positional file path arguments, supports `--json` output mode, outputs human-readable gap reports to stdout, and exits with code 0 on pass / code 1 on failure.

* **System Scenario: STS-003-A1**
  * **Given** `validate-module-coverage.sh` receives three file paths: `architecture-design.md` (containing 5 ARCH identifiers), `module-design.md` (containing MOD modules covering all 5 ARCH), and `unit-test.md` (containing UTP cases covering all non-EXTERNAL MOD modules)
  * **When** the script executes forward and backward coverage validation
  * **Then** the script outputs a coverage summary with 100% forward and backward percentages and exits with code 0

* **System Scenario: STS-003-A2**
  * **Given** `validate-module-coverage.sh` receives three file paths where `module-design.md` is missing a `MOD-NNN` mapping for `ARCH-003`
  * **When** the script executes forward coverage validation
  * **Then** the script outputs a human-readable gap report containing "ARCH-003: no module design mapping found" and exits with code 1

* **System Scenario: STS-003-A3**
  * **Given** `validate-module-coverage.sh` receives three file paths and the `--json` flag
  * **When** the script executes all coverage checks
  * **Then** the script outputs a JSON-structured report with forward/backward coverage percentages, gap lists, orphan lists, and a pass/fail verdict field

* **System Scenario: STS-003-A4**
  * **Given** `validate-module-coverage.sh` receives three file paths where `unit-test.md` contains a `UTP-005-A` whose parent `MOD-005` does not exist in `module-design.md`
  * **When** the script executes orphan detection
  * **Then** the script identifies `UTP-005-A` as an orphaned test case and reports it in the output

#### Test Case: STP-003-B (EXTERNAL Bypass and CROSS-CUTTING Inclusion)

**Technique**: Equivalence Partitioning
**Target View**: Data Design View
**Description**: Verifies that `[EXTERNAL]` modules are correctly bypassed for backward test coverage and `[CROSS-CUTTING]` modules are required to have test coverage.

* **System Scenario: STS-003-B1**
  * **Given** `validate-module-coverage.sh` receives files where `module-design.md` contains `MOD-003` tagged `[EXTERNAL]` and `unit-test.md` has no `UTP-003-X` entries
  * **When** the script executes backward coverage validation
  * **Then** the script counts `MOD-003` as "covered by integration tests" and does NOT flag it as a gap — exit code 0 if all other modules are covered

* **System Scenario: STS-003-B2**
  * **Given** `validate-module-coverage.sh` receives files where `architecture-design.md` contains `ARCH-002` tagged `[CROSS-CUTTING]` and `module-design.md` contains a corresponding `MOD-NNN`
  * **When** the script executes forward coverage validation
  * **Then** the script requires `ARCH-002` to have at least one `MOD-NNN` mapping — `[CROSS-CUTTING]` modules are NOT exempted from forward coverage

* **System Scenario: STS-003-B3**
  * **Given** `validate-module-coverage.sh` receives files where `module-design.md` contains a module tagged `[COTS]` instead of `[EXTERNAL]`
  * **When** the script processes the tag
  * **Then** the script does NOT recognize `[COTS]` as a valid bypass tag — only `[EXTERNAL]` is processed

#### Test Case: STP-003-C (Partial Validation Mode)

**Technique**: Equivalence Partitioning
**Target View**: Interface View
**Description**: Verifies that when `unit-test.md` is absent, the script validates forward coverage (ARCH→MOD) only and gracefully skips backward coverage checks (MOD→UTP).

* **System Scenario: STS-003-C1**
  * **Given** `validate-module-coverage.sh` receives two file paths: `architecture-design.md` and `module-design.md` `And` the third argument (`unit-test.md`) path does not exist
  * **When** the script attempts validation
  * **Then** the script validates forward coverage (ARCH→MOD) only, skips backward coverage (MOD→UTP), and exits with code 0 if forward coverage is complete

* **System Scenario: STS-003-C2**
  * **Given** `validate-module-coverage.sh` is in partial validation mode `And` `module-design.md` is missing coverage for `ARCH-003`
  * **When** the script executes forward coverage validation
  * **Then** the script reports the forward gap for `ARCH-003` and exits with code 1, even though backward checks are skipped

#### Test Case: STP-003-D (Numbering Gap Tolerance and ARCH Resolution)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verifies that the script accepts gaps in MOD numbering and resolves ARCH ancestry from the "Parent Architecture Modules" field rather than from the ID string.

* **System Scenario: STS-003-D1**
  * **Given** `validate-module-coverage.sh` receives `module-design.md` containing MOD-001, MOD-003, MOD-007 (skipping MOD-002, MOD-004, MOD-005, MOD-006)
  * **When** the script parses module identifiers
  * **Then** the script accepts the gaps in numbering without reporting false-positive errors

* **System Scenario: STS-003-D2**
  * **Given** `validate-module-coverage.sh` receives files where `MOD-001` has "Parent Architecture Modules: ARCH-002, ARCH-005" in `module-design.md`
  * **When** the script resolves which ARCH identifiers are covered by `MOD-001`
  * **Then** the script reads the "Parent Architecture Modules" field to mark both `ARCH-002` and `ARCH-005` as covered — not relying on the MOD-001 ID string for ARCH resolution

---

### Component Verification: SYS-004 (Module Design Template)

**Parent Requirements**: REQ-056, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-014

#### Test Case: STP-004-A (Template Structure Compliance)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that `module-design-template.md` contains the required section structure and field definitions for all four mandatory views, Target Source File(s) property, `[EXTERNAL]` section, and conditional safety-critical placeholders.

* **System Scenario: STS-004-A1**
  * **Given** `module-design-template.md` exists in the `templates/` directory
  * **When** the template content is parsed for section headers
  * **Then** the template contains section structures for Algorithmic/Logic View (with fenced pseudocode block guidance), State Machine View (with Mermaid `stateDiagram-v2` and stateless bypass guidance), Internal Data Structures (with type/size/constraint fields), and Error Handling & Return Codes (with Architecture Interface View contract mapping)

* **System Scenario: STS-004-A2**
  * **Given** `module-design-template.md` contains field definitions
  * **When** the template content is inspected for property fields
  * **Then** the template includes a "Target Source File(s)" property field supporting comma-separated paths and a "Parent Architecture Modules" field for ARCH-NNN traceability

* **System Scenario: STS-004-A3**
  * **Given** `module-design-template.md` includes safety-critical sections
  * **When** the template content is inspected for conditional placeholders
  * **Then** the safety-critical sections (Complexity Constraints, Memory Management, Single Entry/Exit) are marked as conditional with guidance on when they should be included (domain configured) or omitted

---

### Component Verification: SYS-005 (Unit Test Template)

**Parent Requirements**: REQ-057, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-027

#### Test Case: STP-005-A (Template Structure Compliance)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that `unit-test-template.md` contains the required section structure for the three-tier MOD→UTP→UTS hierarchy, technique naming, Dependency & Mock Registry, Arrange/Act/Assert format, and conditional safety-critical placeholders.

* **System Scenario: STS-005-A1**
  * **Given** `unit-test-template.md` exists in the `templates/` directory
  * **When** the template content is parsed for section headers
  * **Then** the template contains the three-tier hierarchy structure (MOD→UTP-NNN-X→UTS-NNN-X#), technique naming per test case, view anchoring guidance, and Arrange/Act/Assert scenario format with white-box implementation-oriented language guidance

* **System Scenario: STS-005-A2**
  * **Given** `unit-test-template.md` contains test case field definitions
  * **When** the template content is inspected for the Dependency & Mock Registry table
  * **Then** the template includes a Dependency & Mock Registry table per test case with explicit hardware interface guidance (GPIO, memory-mapped registers) and "None — module is self-contained" notation for dependency-free modules

* **System Scenario: STS-005-A3**
  * **Given** `unit-test-template.md` includes safety-critical sections
  * **When** the template content is inspected for conditional placeholders
  * **Then** the safety-critical sections (MC/DC truth tables, Variable-Level Fault Injection) are marked as conditional with guidance on when they should be included or omitted

---

### Component Verification: SYS-006 (Trace Command Extension)

**Parent Requirements**: REQ-046, REQ-047, REQ-048, REQ-049, REQ-050, REQ-051, REQ-052, REQ-053, REQ-055, REQ-NF-004

#### Test Case: STP-006-A (Matrix D Generation and Annotations)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that the trace command extension produces Matrix D (ARCH → MOD → UTP → UTS) with correct SYS annotations, `[CROSS-CUTTING]` display, and `[EXTERNAL]` handling.

* **System Scenario: STS-006-A1**
  * **Given** a feature directory contains all V-model artifacts including `module-design.md` and `unit-test.md`
  * **When** the trace command extension generates Matrix D
  * **Then** the output contains a Matrix D table with columns ARCH, MOD, UTP, UTS, and each `ARCH-NNN` cell includes parent `SYS-NNN` references in parentheses resolved from `architecture-design.md`

* **System Scenario: STS-006-A2**
  * **Given** `architecture-design.md` contains an `ARCH-NNN` tagged `[CROSS-CUTTING]`
  * **When** the trace command extension generates Matrix D
  * **Then** the `ARCH-NNN` cell displays `([CROSS-CUTTING])` instead of a `SYS-NNN` annotation

* **System Scenario: STS-006-A3**
  * **Given** `module-design.md` contains a `MOD-NNN` tagged `[EXTERNAL]`
  * **When** the trace command extension generates Matrix D
  * **Then** the `MOD-NNN` row shows the `[EXTERNAL]` annotation with "N/A — External" in the UTP and UTS columns

* **System Scenario: STS-006-A4**
  * **Given** a feature directory contains all V-model artifacts
  * **When** the trace command extension generates all matrices
  * **Then** Matrix D coverage percentages match the output of `validate-module-coverage.sh` run independently against the same files

#### Test Case: STP-006-B (Progressive Matrix Building and Backward Compatibility)

**Technique**: Equivalence Partitioning
**Target View**: Interface View
**Description**: Verifies that matrices are built progressively and backward compatibility is maintained when module-level artifacts are absent.

* **System Scenario: STS-006-B1**
  * **Given** a feature directory contains `requirements.md`, `acceptance-plan.md`, `system-design.md`, `system-test.md`, `architecture-design.md`, and `integration-test.md` `And` `module-design.md` and `unit-test.md` do NOT exist
  * **When** the trace command extension generates matrices
  * **Then** the output contains Matrix A, Matrix B, and Matrix C only — identical to v0.3.0 output with no Matrix D and no warning

* **System Scenario: STS-006-B2**
  * **Given** a feature directory contains all artifacts including `module-design.md` but NOT `unit-test.md`
  * **When** the trace command extension generates matrices
  * **Then** the output includes a partial Matrix D with MOD column populated and UTP/UTS columns showing "Unit test plan not yet generated"

* **System Scenario: STS-006-B3**
  * **Given** a feature directory contains all V-model artifacts including `module-design.md` and `unit-test.md`
  * **When** the trace command extension generates matrices
  * **Then** the output contains Matrix A, Matrix B, Matrix C, and Matrix D as four separate tables with independent coverage percentages

---

### Component Verification: SYS-007 (Matrix Builder Script Extension — Bash)

**Parent Requirements**: REQ-054, REQ-053

#### Test Case: STP-007-A (Three-File Parsing Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that `build-matrix.sh` parses `module-design.md`, `unit-test.md`, AND `architecture-design.md` for Matrix D data generation, including ARCH→SYS lineage resolution.

* **System Scenario: STS-007-A1**
  * **Given** `build-matrix.sh` receives paths to `architecture-design.md` (containing ARCH→SYS mappings), `module-design.md` (containing MOD→ARCH mappings), and `unit-test.md` (containing UTP→MOD mappings)
  * **When** the script executes Matrix D data generation
  * **Then** the script outputs structured matrix data with ARCH→MOD→UTP→UTS mappings including parenthetical SYS-NNN annotations resolved from `architecture-design.md`

* **System Scenario: STS-007-A2**
  * **Given** `build-matrix.sh` computes Matrix D coverage percentages
  * **When** the coverage percentages are compared with `validate-module-coverage.sh` output for the same files
  * **Then** the coverage percentages match exactly

#### Test Case: STP-007-B (Missing Input File Handling)

**Technique**: Fault Injection
**Target View**: Dependency View
**Description**: Verifies that the matrix builder script handles missing or malformed input files without producing corrupt output.

* **System Scenario: STS-007-B1**
  * **Given** `build-matrix.sh` receives paths where `architecture-design.md` does not exist
  * **When** the script attempts Matrix D generation
  * **Then** the script returns a non-zero exit code and reports the missing file

---

### Component Verification: SYS-008 (Matrix Builder Script Extension — PowerShell)

**Parent Requirements**: REQ-CN-005

#### Test Case: STP-008-A (Cross-Platform Parity with Bash)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that `build-matrix.ps1` produces identical Matrix D output to `build-matrix.sh` given the same input files.

* **System Scenario: STS-008-A1**
  * **Given** identical input files exist `And` both `build-matrix.sh` and `build-matrix.ps1` are available
  * **When** both scripts execute Matrix D data generation against the same files
  * **Then** both scripts produce identical structured matrix data, identical SYS-NNN annotations, and identical coverage percentages

---

### Component Verification: SYS-009 (Setup Script Extensions)

**Parent Requirements**: REQ-044, REQ-045, REQ-NF-004

#### Test Case: STP-009-A (New Flags and Document Detection)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that `setup-v-model.sh` and `setup-v-model.ps1` support `--require-module-design` and `--require-unit-test` flags and detect `module-design.md` and `unit-test.md` in `AVAILABLE_DOCS`.

* **System Scenario: STS-009-A1**
  * **Given** the setup script receives the `--require-module-design` flag `And` `module-design.md` exists in the feature's `v-model/` directory
  * **When** the script executes prerequisite verification
  * **Then** the script exits with code 0 and includes `module-design.md` in the `AVAILABLE_DOCS` JSON array

* **System Scenario: STS-009-A2**
  * **Given** the setup script receives the `--require-module-design` flag `And` `module-design.md` does NOT exist
  * **When** the script executes prerequisite verification
  * **Then** the script exits with a non-zero exit code and reports that `module-design.md` is required but not found

* **System Scenario: STS-009-A3**
  * **Given** the setup script receives the `--require-unit-test` flag `And` `unit-test.md` exists in the feature's `v-model/` directory
  * **When** the script executes prerequisite verification
  * **Then** the script exits with code 0 and includes `unit-test.md` in the `AVAILABLE_DOCS` JSON array

#### Test Case: STP-009-B (Backward Compatibility)

**Technique**: Equivalence Partitioning
**Target View**: Interface View
**Description**: Verifies that existing v0.3.0 setup invocations produce unchanged behavior — the new flags do not affect output when not specified.

* **System Scenario: STS-009-B1**
  * **Given** the setup script is invoked with existing v0.3.0 flags only (e.g., `--json --require-reqs --require-system-design`)
  * **When** the script executes
  * **Then** the JSON output contains the same keys and values as v0.3.0 — no new required fields, no changed exit behavior

* **System Scenario: STS-009-B2**
  * **Given** the setup script is invoked without any `--require-module-design` or `--require-unit-test` flags `And` `module-design.md` exists in the feature directory
  * **When** the script detects available documents
  * **Then** `module-design.md` appears in the `AVAILABLE_DOCS` array for informational purposes, but its absence does NOT cause a failure

---

### Component Verification: SYS-010 (Module Coverage Validation Script — PowerShell)

**Parent Requirements**: REQ-CN-003, REQ-IF-003, REQ-IF-004

#### Test Case: STP-010-A (Cross-Platform Parity with Bash)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that `validate-module-coverage.ps1` produces identical behavior, output format, exit codes, partial validation support, and `[EXTERNAL]` bypass logic as `validate-module-coverage.sh`.

* **System Scenario: STS-010-A1**
  * **Given** identical test fixture files exist `And` both `validate-module-coverage.sh` and `validate-module-coverage.ps1` are available
  * **When** both scripts are run against the same fixture data in full validation mode
  * **Then** both scripts produce identical output text, identical coverage percentages, and identical exit codes (0 for pass, 1 for fail)

* **System Scenario: STS-010-A2**
  * **Given** identical test fixture files exist with `unit-test.md` absent `And` both scripts are available
  * **When** both scripts are run against the same fixture data in partial validation mode
  * **Then** both scripts validate forward coverage only, skip backward checks, and produce identical partial-mode output with identical exit codes

---

### Component Verification: SYS-011 (Extension Manifest Update)

**Parent Requirements**: REQ-CN-002

#### Test Case: STP-011-A (Version and Command Registration)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that `extension.yml` is bumped to version `0.4.0`, registers exactly 9 commands and 1 hook, and adds `MOD`, `UTP`, `UTS` to recognized `id_prefixes`.

* **System Scenario: STS-011-A1**
  * **Given** `extension.yml` has been updated for v0.4.0
  * **When** the manifest is parsed for version, command count, and id_prefixes
  * **Then** the version field reads `0.4.0`, exactly 9 commands (7 existing + `module-design` + `unit-test`) and 1 hook are registered, and `id_prefixes` includes `MOD`, `UTP`, `UTS` in addition to existing prefixes

---

### Component Verification: SYS-012 (CI Evaluation Suite Extension)

**Parent Requirements**: REQ-NF-005

#### Test Case: STP-012-A (Structural Evaluation Coverage)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that the CI evaluation suite validates structural correctness of module-design and unit-test command outputs, including fenced pseudocode blocks, technique naming, Dependency & Mock Registry, `[EXTERNAL]` bypass, State Machine View, Target Source File(s), and Parent Architecture Modules field.

* **System Scenario: STS-012-A1**
  * **Given** the CI evaluation suite receives `module-design.md` with every non-EXTERNAL `MOD-NNN` containing a fenced ` ```pseudocode ``` ` block
  * **When** the evaluation suite executes structural validation
  * **Then** the suite reports no pseudocode-related failures

* **System Scenario: STS-012-A2**
  * **Given** the CI evaluation suite receives `module-design.md` where `MOD-003` is missing its fenced pseudocode block but is NOT tagged `[EXTERNAL]`
  * **When** the evaluation suite executes structural validation
  * **Then** the suite reports a structural failure for `MOD-003` identifying the missing pseudocode block

* **System Scenario: STS-012-A3**
  * **Given** the CI evaluation suite receives `unit-test.md` containing `UTP-NNN-X` entries
  * **When** the evaluation suite validates technique naming and Dependency & Mock Registry presence
  * **Then** every `UTP-NNN-X` has an explicit technique name and a Dependency & Mock Registry table — any missing items are flagged as failures

* **System Scenario: STS-012-A4**
  * **Given** the CI evaluation suite receives `module-design.md` containing a stateful module with a Mermaid `stateDiagram-v2` diagram and a stateless module with a bypass string
  * **When** the evaluation suite validates State Machine View correctness
  * **Then** the suite accepts both formats: Mermaid diagrams for stateful modules and broad-regex stateless bypass strings for stateless modules

#### Test Case: STP-012-B (LLM-as-Judge Quality Evaluation)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verifies that the LLM-as-judge evaluations assess pseudocode concreteness and semantic quality, detecting vague or hallucinated content.

* **System Scenario: STS-012-B1**
  * **Given** the CI evaluation suite receives `module-design.md` with concrete, implementable pseudocode (explicit branches, loops, decisions)
  * **When** the LLM-as-judge evaluation assesses pseudocode quality
  * **Then** the evaluation passes the quality threshold

* **System Scenario: STS-012-B2**
  * **Given** the CI evaluation suite receives `module-design.md` with vague pseudocode (e.g., "process the data appropriately" without explicit logic)
  * **When** the LLM-as-judge evaluation assesses pseudocode quality
  * **Then** the evaluation fails the quality threshold and reports the specific module with insufficient concreteness

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total System Components (SYS) | 12 |
| Total Test Cases (STP) | 25 |
| Total Scenarios (STS) | 74 |
| Components with ≥1 STP | 12 / 12 (100%) |
| Test Cases with ≥1 STS | 25 / 25 (100%) |
| **Overall Coverage (SYS→STP)** | **100%** |

## Uncovered Components

None — full coverage achieved.
