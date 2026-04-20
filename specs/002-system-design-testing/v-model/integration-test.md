# Integration Test Plan: System Design ↔ System Testing

**Feature Branch**: `002-system-design-testing`
**Created**: 2026-02-20
**Status**: Draft
**Source**: `specs/002-system-design-testing/v-model/architecture-design.md`

## Overview

This document defines the Integration Test Plan for the System Design ↔ System Testing feature. Every architecture module in `architecture-design.md` has one or more Test Cases (ITP), and every Test Case has one or more executable Integration Scenarios (ITS) in module-boundary BDD format (Given/When/Then). Integration tests verify **seams and handshakes between modules**, not internal logic or user journeys. The test strategy covers: Interface Contract Testing for module-to-module API compliance, Data Flow Testing for end-to-end data transformation chains, Interface Fault Injection for failure handling at module boundaries, and Concurrency & Race Condition Testing where sequential execution order matters.

## ID Schema

- **Integration Test Case**: `ITP-{NNN}-{X}` — where NNN matches the parent ARCH, X is a letter suffix (A, B, C...)
- **Integration Test Scenario**: `ITS-{NNN}-{X}{#}` — nested under the parent ITP, with numeric suffix (1, 2, 3...)
- Example: `ITS-006-B1` → Scenario 1 of Test Case B verifying ARCH-006

## ISO 29119-4 Integration Test Techniques

| Technique | Source View | What It Tests |
|-----------|------------|---------------|
| **Interface Contract Testing** | Interface View | Module API contracts, data format compliance, error responses |
| **Data Flow Testing** | Data Flow View | End-to-end data transformation chain validation |
| **Interface Fault Injection** | Interface View + Process View | Malformed payloads, timeouts, graceful failure |
| **Concurrency & Race Condition Testing** | Process View | Execution order dependencies, sequential pipeline correctness |

## Integration Tests

### Module Verification: ARCH-001 (System Design Command Definition)

**Parent System Components**: SYS-001

#### Test Case: ITP-001-A (Template Loading Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-001 → ARCH-002 interface
**Description**: Verifies that ARCH-001 (System Design Command) correctly loads and applies the structure defined by ARCH-002 (System Design Template) when producing system-design.md.

* **Integration Scenario: ITS-001-A1**
  * **Given** ARCH-002 (System Design Template) defines sections Overview, ID Schema, Decomposition View, Dependency View, Interface View, Data Design View, Coverage Summary, Derived Requirements, and Glossary with IEEE 1016 table formats
  * **When** ARCH-001 (System Design Command) loads the template and generates output
  * **Then** the output `system-design.md` contains all nine sections with table structures matching the column order defined by ARCH-002

* **Integration Scenario: ITS-001-A2**
  * **Given** ARCH-001 (System Design Command) receives a `requirements.md` containing `REQ-001` through `REQ-005` with functional and non-functional requirement types
  * **When** ARCH-001 sends the extracted requirement list to the template structure provided by ARCH-002
  * **Then** the Decomposition View in the output contains `SYS-NNN` entries with Parent Requirements fields referencing the original `REQ-NNN` identifiers from the input

#### Test Case: ITP-001-B (Missing Prerequisite Fault)

**Technique**: Interface Fault Injection
**Target View**: Interface View — ARCH-001 input contract
**Description**: Verifies that ARCH-001 handles missing input files with the specified error message.

* **Integration Scenario: ITS-001-B1**
  * **Given** the V-Model directory does not contain `requirements.md`
  * **When** ARCH-001 (System Design Command) attempts to read its mandatory inputs
  * **Then** ARCH-001 emits the error "requirements.md not found. Run `/speckit.v-model.requirements` first." and produces no output file

* **Integration Scenario: ITS-001-B2**
  * **Given** ARCH-001 receives a `requirements.md` containing no valid `REQ-NNN` identifiers (empty table body)
  * **When** ARCH-001 attempts to extract requirement IDs for decomposition
  * **Then** ARCH-001 produces an output with an empty Decomposition View and flags zero forward coverage without crashing

---

### Module Verification: ARCH-002 (System Design Template)

**Parent System Components**: SYS-002

#### Test Case: ITP-002-A (Template Structural Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-002 output contract
**Description**: Verifies that ARCH-002 (System Design Template) provides a structure that ARCH-001 (System Design Command) can consume without modification.

* **Integration Scenario: ITS-002-A1**
  * **Given** ARCH-002 (System Design Template) exists in the `templates/` directory
  * **When** ARCH-001 (System Design Command) reads the template file
  * **Then** the template provides HTML comment markers and table headers for Decomposition View (SYS ID, Name, Description, Parent Requirements, Type), Dependency View (Source, Target, Relationship, Failure Impact), Interface View, and Data Design View that ARCH-001 can parse to determine section boundaries and column order

* **Integration Scenario: ITS-002-A2**
  * **Given** ARCH-002 defines the Coverage Summary section structure with metric rows
  * **When** ARCH-001 populates the template with generated SYS-NNN components
  * **Then** the Coverage Summary section in the output includes Total Components, Forward Coverage, and Derived Requirements counts matching the actual content

---

### Module Verification: ARCH-003 (System Test Command Definition)

**Parent System Components**: SYS-003

#### Test Case: ITP-003-A (Template Loading and Design Loading Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-003 → ARCH-004 interface and ARCH-003 input contract
**Description**: Verifies that ARCH-003 (System Test Command) correctly loads the template from ARCH-004 and consumes the design from ARCH-001's output to generate system-test.md.

* **Integration Scenario: ITS-003-A1**
  * **Given** ARCH-004 (System Test Template) defines sections for Test Cases with STP ID, Name, Parent SYS, IEEE 1016 View, ISO 29119 Technique columns and Test Scenarios with STS ID, Parent STP, Given/When/Then BDD steps
  * **When** ARCH-003 (System Test Command) loads the template structure from ARCH-004 and a `system-design.md` containing `SYS-001` through `SYS-005` with four IEEE 1016 views
  * **Then** ARCH-003 produces `system-test.md` with `STP-NNN-X` test cases anchored to design views and `STS-NNN-X#` scenarios in BDD format, conforming to the template structure defined by ARCH-004

* **Integration Scenario: ITS-003-A2**
  * **Given** ARCH-003 receives a `system-design.md` with Interface View contracts defining external and internal interfaces for `SYS-003`
  * **When** ARCH-003 generates test cases for `SYS-003`
  * **Then** ARCH-003 produces separate `STP-003-X` entries for external interface testing and internal interface testing, each naming the ISO 29119 technique

#### Test Case: ITP-003-B (Coverage Gate Integration)

**Technique**: Data Flow Testing
**Target View**: Data Flow View — System Test Generation flow (stage 4)
**Description**: Verifies the data flow from ARCH-003 (System Test Command) invoking ARCH-008 (CLI Formatter) as a post-generation coverage gate and appending results.

* **Integration Scenario: ITS-003-B1**
  * **Given** ARCH-003 has generated `system-test.md` with test cases covering only 3 of 5 SYS components from `system-design.md`
  * **When** ARCH-003 invokes ARCH-008 (Validation CLI) with `requirements.md`, `system-design.md`, and `system-test.md` as arguments
  * **Then** ARCH-008 returns a coverage report with `pct < 100` and exit code 1, and ARCH-003 appends the coverage gate results to `system-test.md` indicating backward coverage gaps

* **Integration Scenario: ITS-003-B2**
  * **Given** ARCH-003 has generated `system-test.md` with full coverage of all SYS components
  * **When** ARCH-003 invokes ARCH-008 with all three file paths
  * **Then** ARCH-008 returns exit code 0 with 100% forward and backward coverage, and ARCH-003 appends a passing coverage gate result to `system-test.md`

---

### Module Verification: ARCH-004 (System Test Template)

**Parent System Components**: SYS-004

#### Test Case: ITP-004-A (Template Structural Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-004 output contract
**Description**: Verifies that ARCH-004 (System Test Template) provides a structure that ARCH-003 (System Test Command) can consume without modification.

* **Integration Scenario: ITS-004-A1**
  * **Given** ARCH-004 (System Test Template) exists in the `templates/` directory
  * **When** ARCH-003 (System Test Command) reads the template file
  * **Then** the template provides HTML comment markers and table headers for Test Cases (STP ID, Name, Parent SYS, IEEE 1016 View, ISO 29119 Technique, Interface Type) and Test Scenarios (STS ID, Parent STP, Given/When/Then BDD steps) that ARCH-003 can parse to determine section boundaries

* **Integration Scenario: ITS-004-A2**
  * **Given** ARCH-004 defines the Coverage Gate Results section structure
  * **When** ARCH-003 populates the template after invoking the validation pipeline via ARCH-008
  * **Then** the Coverage Gate Results section includes the validation script output with pass/fail verdict and coverage percentages matching the format defined by ARCH-004

---

### Module Verification: ARCH-005 (Forward Coverage Validator)

**Parent System Components**: SYS-005

#### Test Case: ITP-005-A (Forward Validator → CLI Formatter Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-005 → ARCH-008 interface
**Description**: Verifies that ARCH-005 returns forward coverage results in the format expected by ARCH-008 (CLI Formatter).

* **Integration Scenario: ITS-005-A1**
  * **Given** ARCH-005 (Forward Coverage Validator) processes a `requirements.md` with `REQ-001` through `REQ-005` and a `system-design.md` where the Decomposition View Parent Requirements column covers only `REQ-001`, `REQ-002`, and `REQ-003`
  * **When** ARCH-005 returns its result to ARCH-008 (CLI Formatter)
  * **Then** ARCH-008 receives a data structure with `covered: ["REQ-001","REQ-002","REQ-003"]`, `uncovered: ["REQ-004","REQ-005"]`, and `pct: 60`

* **Integration Scenario: ITS-005-A2**
  * **Given** ARCH-005 processes a `requirements.md` containing both functional IDs (`REQ-001`) and non-functional IDs (`REQ-NF-001`, `REQ-CN-001`, `REQ-IF-001`) and a `system-design.md` covering all of them
  * **When** ARCH-005 extracts IDs using regex patterns `REQ-[0-9]{3}` and `REQ-(NF|CN|IF)-[0-9]{3}`
  * **Then** ARCH-005 returns `pct: 100` with all requirement ID formats included in the `covered` array

#### Test Case: ITP-005-B (Forward Validator Fault — Empty Design)

**Technique**: Interface Fault Injection
**Target View**: Interface View — ARCH-005 input contract
**Description**: Verifies that ARCH-005 handles a `system-design.md` with no valid SYS entries gracefully.

* **Integration Scenario: ITS-005-B1**
  * **Given** ARCH-005 receives a `system-design.md` containing only section headers and no `SYS-NNN` entries in the Decomposition View
  * **When** ARCH-005 attempts to extract Parent Requirements column references
  * **Then** ARCH-005 returns `covered: []`, `uncovered: [all REQ IDs]`, and `pct: 0` to ARCH-008 without crashing

* **Integration Scenario: ITS-005-B2**
  * **Given** ARCH-005 receives a `system-design.md` where a `SYS-001` entry references `REQ-999` which does not exist in `requirements.md`
  * **When** ARCH-005 computes the forward coverage set difference
  * **Then** ARCH-005 counts `REQ-999` as a reference but does not include non-existent requirement IDs in the `covered` array, and reports accurate coverage for the actual requirement set

---

### Module Verification: ARCH-006 (Backward Coverage Validator)

**Parent System Components**: SYS-005

#### Test Case: ITP-006-A (Backward Validator → CLI Formatter Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-006 → ARCH-008 interface
**Description**: Verifies that ARCH-006 returns backward coverage results in the format expected by ARCH-008 (CLI Formatter).

* **Integration Scenario: ITS-006-A1**
  * **Given** ARCH-006 (Backward Coverage Validator) processes a `system-design.md` with `SYS-001` through `SYS-005` and a `system-test.md` containing `STP-001-A`, `STP-002-A`, and `STP-003-A` (covering only SYS-001, SYS-002, SYS-003)
  * **When** ARCH-006 returns its result to ARCH-008 (CLI Formatter)
  * **Then** ARCH-008 receives a data structure with `covered: ["SYS-001","SYS-002","SYS-003"]`, `uncovered: ["SYS-004","SYS-005"]`, and `pct: 60`

* **Integration Scenario: ITS-006-A2**
  * **Given** ARCH-006 processes a `system-test.md` with `STP-001-A` and `STP-001-B` (multiple test cases for the same `SYS-001`)
  * **When** ARCH-006 computes the backward coverage set
  * **Then** ARCH-006 counts `SYS-001` once in the `covered` array regardless of how many STP entries reference it

#### Test Case: ITP-006-B (Backward Validator Fault — Missing Test File)

**Technique**: Interface Fault Injection
**Target View**: Interface View — ARCH-006 input contract
**Description**: Verifies that ARCH-006 is correctly skipped when `system-test.md` is absent (partial validation mode).

* **Integration Scenario: ITS-006-B1**
  * **Given** ARCH-008 (CLI Formatter) is invoked in partial mode with `system-test.md` absent
  * **When** ARCH-008 determines that the third argument is not provided
  * **Then** ARCH-008 skips invocation of ARCH-006 (Backward Validator) entirely and produces a report containing only forward coverage results from ARCH-005

* **Integration Scenario: ITS-006-B2**
  * **Given** ARCH-006 receives a `system-test.md` containing only section headers and no valid `STP-NNN-X` entries
  * **When** ARCH-006 attempts regex extraction of STP IDs
  * **Then** ARCH-006 returns `covered: []`, `uncovered: [all SYS IDs]`, and `pct: 0` to ARCH-008 without crashing

---

### Module Verification: ARCH-007 (Orphan Detector)

**Parent System Components**: SYS-005

#### Test Case: ITP-007-A (Orphan Detector → CLI Formatter Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-007 → ARCH-008 interface
**Description**: Verifies that ARCH-007 returns orphan detection results in the format expected by ARCH-008 (CLI Formatter).

* **Integration Scenario: ITS-007-A1**
  * **Given** ARCH-007 (Orphan Detector) processes a `system-design.md` where `SYS-004` has no Parent Requirements reference in the Decomposition View and a `system-test.md` where `STP-099-A` references a non-existent `SYS-099`
  * **When** ARCH-007 returns its result to ARCH-008 (CLI Formatter)
  * **Then** ARCH-008 receives `{orphaned_sys: ["SYS-004: no requirement parent"], orphaned_stp: ["STP-099-A: parent SYS-099 does not exist"]}`

* **Integration Scenario: ITS-007-A2**
  * **Given** ARCH-007 processes artifacts where all `SYS-NNN` entries have valid REQ parents and all `STP-NNN-X` entries reference existing `SYS-NNN` components
  * **When** ARCH-007 completes its cross-reference analysis
  * **Then** ARCH-007 returns `{orphaned_sys: [], orphaned_stp: []}` to ARCH-008 indicating a clean traceability chain

* **Integration Scenario: ITS-007-A3**
  * **Given** ARCH-008 invokes ARCH-007 in partial mode with `system-test.md` absent
  * **When** ARCH-007 performs orphan detection for SYS components only
  * **Then** ARCH-007 returns `{orphaned_sys: [...], orphaned_stp: []}` skipping STP orphan detection entirely

---

### Module Verification: ARCH-008 (Validation CLI and Output Formatter)

**Parent System Components**: SYS-005

#### Test Case: ITP-008-A (CLI Orchestration Data Flow)

**Technique**: Data Flow Testing
**Target View**: Data Flow View — Coverage Validation flow (stages 1–5)
**Description**: Verifies the end-to-end data flow from CLI argument parsing through all three validators to final output.

* **Integration Scenario: ITS-008-A1**
  * **Given** ARCH-008 (CLI Formatter) receives three positional arguments: paths to `requirements.md` (5 REQs), `system-design.md` (5 SYS components), and `system-test.md` (3 STP test cases)
  * **When** ARCH-008 orchestrates ARCH-005 (Forward Validator), ARCH-006 (Backward Validator), and ARCH-007 (Orphan Detector) sequentially
  * **Then** the stdout output contains section headers for forward coverage, backward coverage, and orphan detection, with per-ID gap messages for uncovered items, and the exit code is 1 due to backward coverage gaps

* **Integration Scenario: ITS-008-A2**
  * **Given** ARCH-008 receives three file paths where all coverage checks pass (100% forward, 100% backward, zero orphans)
  * **When** ARCH-008 orchestrates all three validators and aggregates results
  * **Then** the stdout output shows pass verdicts for all three checks with coverage percentages, and the exit code is 0

#### Test Case: ITP-008-B (Partial Mode Fault Injection)

**Technique**: Interface Fault Injection
**Target View**: Process View — Validation Pipeline interaction
**Description**: Verifies that partial mode (third argument absent) correctly bypasses backward coverage and STP orphan detection.

* **Integration Scenario: ITS-008-B1**
  * **Given** ARCH-008 receives only two positional arguments: `requirements.md` and `system-design.md` (third argument absent)
  * **When** ARCH-008 determines partial validation mode and orchestrates the pipeline
  * **Then** ARCH-008 invokes ARCH-005 (Forward Validator) and ARCH-007 (Orphan Detector for SYS only) but skips ARCH-006 (Backward Validator), and the output clearly indicates "partial validation mode"

* **Integration Scenario: ITS-008-B2**
  * **Given** ARCH-008 receives two arguments where forward coverage is 100% and no SYS orphans exist
  * **When** ARCH-008 completes partial validation
  * **Then** ARCH-008 returns exit code 0 despite ARCH-006 (Backward Validator) not being invoked, confirming that partial mode pass criteria exclude backward coverage

---

### Module Verification: ARCH-009 (PowerShell Coverage Validation)

**Parent System Components**: SYS-006

#### Test Case: ITP-009-A (PowerShell Parity Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-009 vs ARCH-008 output parity
**Description**: Verifies that ARCH-009 (PowerShell) produces identical output structure and exit codes as ARCH-008 (Bash) for the same inputs.

* **Integration Scenario: ITS-009-A1**
  * **Given** a V-Model directory with known coverage gaps (2 of 5 REQs uncovered, 1 orphaned SYS) processed by both ARCH-008 (Bash CLI) and ARCH-009 (PowerShell)
  * **When** both modules produce their human-readable reports
  * **Then** the output structures are field-identical: same per-ID gap messages, same coverage percentages, same section headers, and same exit codes

* **Integration Scenario: ITS-009-A2**
  * **Given** a V-Model directory processed in partial mode (no `system-test.md`) by both ARCH-008 and ARCH-009
  * **When** both modules execute partial validation
  * **Then** both produce identical partial mode output: forward coverage results only, same "partial validation mode" indicator, and same exit code

---

### Module Verification: ARCH-010 (SYS/STP/STS ID Extractor)

**Parent System Components**: SYS-007

#### Test Case: ITP-010-A (ID Extractor → Matrix Builder Data Flow)

**Technique**: Data Flow Testing
**Target View**: Data Flow View — Matrix B Construction flow (stage 1)
**Description**: Verifies the data flow from ARCH-010 (ID Extractor) extracting IDs and passing structured data to ARCH-011 (Matrix B Builder).

* **Integration Scenario: ITS-010-A1**
  * **Given** ARCH-010 (SYS/STP/STS ID Extractor) processes a `system-design.md` with `SYS-001` (parent `REQ-001, REQ-002`) and `SYS-002` (parent `REQ-003`) in the Decomposition View, and a `system-test.md` with `STP-001-A`, `STS-001-A1`, `STP-002-A`, `STS-002-A1`
  * **When** ARCH-010 passes its extracted data to ARCH-011 (Matrix B Builder)
  * **Then** ARCH-011 receives `[{sys_id: "SYS-001", parent_reqs: ["REQ-001","REQ-002"]}, {sys_id: "SYS-002", parent_reqs: ["REQ-003"]}]`, `[{stp_id: "STP-001-A", parent_sys: "SYS-001"}, {stp_id: "STP-002-A", parent_sys: "SYS-002"}]`, and `[{sts_id: "STS-001-A1", parent_stp: "STP-001-A"}, {sts_id: "STS-002-A1", parent_stp: "STP-002-A"}]`

* **Integration Scenario: ITS-010-A2**
  * **Given** ARCH-010 processes a `system-test.md` containing no valid `STP-NNN-X` or `STS-NNN-X#` identifiers
  * **When** ARCH-010 passes empty arrays to ARCH-011
  * **Then** ARCH-011 receives `stp_entries: []` and `sts_entries: []` and produces Matrix B rows with `⚠️ No test coverage` for every SYS entry

---

### Module Verification: ARCH-011 (Matrix B Table Builder)

**Parent System Components**: SYS-007

#### Test Case: ITP-011-A (Matrix B Builder → Trace Data Flow)

**Technique**: Data Flow Testing
**Target View**: Data Flow View — Matrix B Construction flow (stages 2–3)
**Description**: Verifies the end-to-end data flow from ID arrays through chain resolution to Matrix B table rows.

* **Integration Scenario: ITS-011-A1**
  * **Given** ARCH-011 (Matrix B Builder) receives ID arrays from ARCH-010 with `SYS-001` (parent `REQ-001`) linked to `STP-001-A` linked to `STS-001-A1`
  * **When** ARCH-011 resolves the full verification chain REQ → SYS → STP → STS
  * **Then** the Matrix B output row shows `REQ-001 | SYS-001 | STP-001-A | STS-001-A1` with coverage percentage reflecting the resolved chains

* **Integration Scenario: ITS-011-A2**
  * **Given** ARCH-011 receives ID arrays where `SYS-003` has no associated `STP-NNN-X` entry
  * **When** ARCH-011 resolves the verification chain for `SYS-003`
  * **Then** the Matrix B output row shows `REQ-003 | SYS-003 | ⚠️ No test coverage | —` and the coverage percentage reflects the gap

#### Test Case: ITP-011-B (Backward Compatibility Fault)

**Technique**: Interface Fault Injection
**Target View**: Interface View — ARCH-011 input contract
**Description**: Verifies that ARCH-011 produces no Matrix B output when source artifacts are absent, maintaining v0.1.0 backward compatibility.

* **Integration Scenario: ITS-011-B1**
  * **Given** the V-Model directory contains only v0.1.0 artifacts (`requirements.md`, `acceptance-plan.md`) but no `system-design.md` or `system-test.md`
  * **When** ARCH-010 (ID Extractor) finds no source files and passes an empty signal to ARCH-011
  * **Then** ARCH-011 produces no Matrix B output and no error or warning, preserving v0.1.0 trace output identity

* **Integration Scenario: ITS-011-B2**
  * **Given** ARCH-011 receives `sys_entries` from ARCH-010 but `stp_entries` and `sts_entries` are empty (design exists, tests do not)
  * **When** ARCH-011 attempts chain resolution
  * **Then** ARCH-011 produces Matrix B rows with `⚠️ No test coverage` for every SYS entry and reports 0% coverage without crashing

---

### Module Verification: ARCH-012 (PowerShell Matrix B Builder)

**Parent System Components**: SYS-008

#### Test Case: ITP-012-A (PowerShell Matrix Parity)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-012 vs ARCH-010/011 output parity
**Description**: Verifies that ARCH-012 (PowerShell) produces identical Matrix B rows as ARCH-010/011 (Bash) for the same inputs.

* **Integration Scenario: ITS-012-A1**
  * **Given** a `system-design.md` and `system-test.md` with known IDs processed by both ARCH-010/011 (Bash) and ARCH-012 (PowerShell)
  * **When** both produce Matrix B output
  * **Then** the Matrix B rows are identical including gap annotations `⚠️ No test coverage`, chain resolution order, and coverage percentages

* **Integration Scenario: ITS-012-A2**
  * **Given** a `system-design.md` with 3 SYS components and a `system-test.md` covering only 1 of them, processed by both ARCH-010/011 and ARCH-012
  * **When** both produce Matrix B output with gap highlighting
  * **Then** both produce identical gap annotations for `SYS-002` and `SYS-003` and identical coverage percentage of 33%

---

### Module Verification: ARCH-013 (Trace Command Matrix B Integration)

**Parent System Components**: SYS-009

#### Test Case: ITP-013-A (Trace Integration with Matrix B)

**Technique**: Data Flow Testing
**Target View**: Data Flow View — Matrix B integration into trace output
**Description**: Verifies that ARCH-013 (Trace Extension) correctly invokes the matrix builder pipeline and includes Matrix B in composite trace output.

* **Integration Scenario: ITS-013-A1**
  * **Given** ARCH-013 (Trace Command Extension) detects `system-design.md` and `system-test.md` in the AVAILABLE_DOCS list from the setup script
  * **When** ARCH-013 invokes ARCH-010 (ID Extractor) and ARCH-011 (Matrix B Builder) as part of the build-matrix pipeline
  * **Then** the trace output includes Matrix B as a separate table after Matrix A with independent coverage percentage and chain `REQ → SYS → STP → STS`

* **Integration Scenario: ITS-013-A2**
  * **Given** ARCH-013 detects that `system-design.md` and `system-test.md` do NOT exist in the AVAILABLE_DOCS list
  * **When** ARCH-013 checks the available document set
  * **Then** ARCH-013 skips the Matrix B section entirely with no warning and produces identical output to v0.1.0 (Matrix A only)

* **Integration Scenario: ITS-013-A3**
  * **Given** ARCH-013 detects that `system-design.md` exists but `system-test.md` does NOT exist in the AVAILABLE_DOCS list
  * **When** ARCH-013 checks both file presence conditions
  * **Then** ARCH-013 skips the Matrix B section (both files required) and produces output with Matrix A only

---

### Module Verification: ARCH-014 (SYS/STP/STS ID Pattern Registration)

**Parent System Components**: SYS-010

#### Test Case: ITP-014-A (ID Pattern Registration Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-014 input/output contract
**Description**: Verifies that ARCH-014 extends the ID validator to accept SYS, STP, and STS patterns alongside all existing prefixes.

* **Integration Scenario: ITS-014-A1**
  * **Given** ARCH-014 (SYS/STP/STS ID Pattern Registration) has been applied to `id_validator.py`
  * **When** the validator processes a document containing `SYS-001`, `STP-001-A`, `STS-001-A1`, `REQ-001`, `ATP-001-A`, `SCN-001-A1`
  * **Then** all six identifiers are recognized as valid V-Model IDs with their respective prefixes and patterns

* **Integration Scenario: ITS-014-A2**
  * **Given** ARCH-014 registers regex patterns `SYS-[0-9]{3}`, `STP-[0-9]{3}-[A-Z]`, and `STS-[0-9]{3}-[A-Z][0-9]+`
  * **When** the validator receives the identifier `STS-005-B3`
  * **Then** the lineage extraction interface returns `{parent_stp: "STP-005-B", parent_sys: "SYS-005", parent_req: "REQ-005"}` derived via regex without consulting any lookup table

---

### Module Verification: ARCH-015 (Extension Manifest Entries)

**Parent System Components**: SYS-011

#### Test Case: ITP-015-A (Manifest Entries Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-015 output contract
**Description**: Verifies that spec-kit can discover and load the system-design and system-test commands from the manifest.

* **Integration Scenario: ITS-015-A1**
  * **Given** ARCH-015 (Extension Manifest) registers `speckit.v-model.system-design` with file path `commands/system-design.md` and `speckit.v-model.system-test` with file path `commands/system-test.md`
  * **When** the spec-kit extension loader parses `extension.yml`
  * **Then** the loader discovers both commands, resolves their file paths, and the manifest contains exactly 5 commands (3 existing from v0.1.0 + 2 new) and version `0.2.0`

* **Integration Scenario: ITS-015-A2**
  * **Given** ARCH-015 updates the `trace` command description to mention Matrix B alongside Matrix A
  * **When** the extension loader reads the `trace` command entry from `extension.yml`
  * **Then** the description string references both Matrix A (Validation) and Matrix B (Verification) traceability

---

### Module Verification: ARCH-016 (CI Evaluation Suite Extension)

**Parent System Components**: SYS-012

#### Test Case: ITP-016-A (CI Evaluation Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-016 input/output contract
**Description**: Verifies that ARCH-016 extends the CI evaluation suite with quality evaluation cases for system-design and system-test command outputs.

* **Integration Scenario: ITS-016-A1**
  * **Given** ARCH-016 (CI Evaluation Extension) registers evaluation cases in `evals.yml` for `/speckit.v-model.system-design` and `/speckit.v-model.system-test` with quality thresholds matching or exceeding v0.1.0 levels
  * **When** the CI workflow executes the evaluation suite against test fixture inputs (`requirements.md`, `system-design.md`)
  * **Then** the evaluation runner discovers the new evaluation cases, executes them, and reports pass/fail results with non-zero exit code on quality regression

* **Integration Scenario: ITS-016-A2**
  * **Given** ARCH-016 defines evaluation fixtures for both system-design and system-test commands
  * **When** the evaluation suite processes a system-design output that fails to include all four IEEE 1016 views
  * **Then** the evaluation case reports failure with a quality score below the configured threshold and the CI workflow returns a non-zero exit code

---

### Module Verification: ARCH-017 (Backward Compatibility Enforcement)

**Parent System Components**: SYS-013

#### Test Case: ITP-017-A (Backward Compatibility Enforcement)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-017 input/output contract
**Description**: Verifies that v0.2.0 operations do not modify existing v0.1.0 artifacts.

* **Integration Scenario: ITS-017-A1**
  * **Given** ARCH-017 (Backward Compatibility) has a byte-identical snapshot of v0.1.0 artifacts (`requirements.md`, `acceptance-plan.md`, `traceability-matrix.md`) taken before any v0.2.0 operation
  * **When** ARCH-001 (System Design Command), ARCH-003 (System Test Command), and ARCH-013 (Trace Extension) execute their full workflows
  * **Then** the v0.1.0 artifacts remain byte-identical to their pre-operation snapshot, confirming no v0.2.0 module modified them

* **Integration Scenario: ITS-017-A2**
  * **Given** ARCH-017 monitors the v0.1.0 artifact set before and after running the trace command via ARCH-013
  * **When** ARCH-013 generates a traceability matrix with Matrix A + Matrix B
  * **Then** the existing v0.1.0 `traceability-matrix.md` content is not modified — the updated trace output is written as a new version, and the original acceptance-level matrix remains intact

---

## Test Harness & Mocking Strategy

| Test Case | External Dependency | Mock/Stub Strategy | Rationale |
|-----------|--------------------|--------------------|-----------|
| ITP-001-A | GitHub Copilot AI runtime | Fixture-based output comparison — pre-generated `system-design.md` compared against template structure | AI output varies; structural compliance is verified deterministically |
| ITP-001-B | V-Model directory filesystem | Controlled test directory with selective file presence/absence | Prerequisite checking must work against real filesystem paths |
| ITP-002-A | Template filesystem | Real template file in `templates/` directory | Template structure is static and deterministic |
| ITP-003-A, ITP-003-B | Source artifacts (system-design.md) + AI runtime | Fixture-based `system-design.md` with known SYS IDs; pre-generated `system-test.md` for coverage gate testing | Deterministic coverage results require controlled inputs |
| ITP-004-A | Template filesystem | Real template file in `templates/` directory | Template structure is static and deterministic |
| ITP-005-A, ITP-005-B | Source artifacts (requirements.md, system-design.md) | Minimal fixture files with known REQ and SYS ID sets | Deterministic forward coverage results require controlled inputs |
| ITP-006-A, ITP-006-B | Source artifacts (system-design.md, system-test.md) | Minimal fixture files with known SYS and STP ID sets | Deterministic backward coverage results require controlled inputs |
| ITP-007-A | Source artifacts (all three files) | Fixture files with intentional orphans (SYS with no REQ parent, STP with non-existent SYS parent) | Orphan detection requires known traceability gaps |
| ITP-008-A, ITP-008-B | All three validators (ARCH-005, ARCH-006, ARCH-007) | Integration test with fixture files — no mocking of validators | Validates the real orchestration pipeline, not stubbed behavior |
| ITP-009-A | Bash script output | Bash output captured as golden reference for PowerShell comparison | Cross-platform parity requires identical outputs from identical inputs |
| ITP-010-A | Source artifacts (system-design.md, system-test.md) | Minimal fixtures with known SYS/STP/STS IDs for extraction validation | ID extraction must match exact regex patterns |
| ITP-011-A, ITP-011-B | ID extractor output (ARCH-010) | Full pipeline execution with fixture V-Model directory | Matrix B chain resolution requires real extractor invocation |
| ITP-012-A | Bash script output | Bash output captured as golden reference for PowerShell comparison | Cross-platform parity requires identical outputs from identical inputs |
| ITP-013-A | Build-matrix pipeline + trace command | Full pipeline execution with fixture V-Model directory | Integration with trace command requires real matrix builder invocation |
| ITP-014-A | ID validator Python module | Real `id_validator.py` with ARCH-014 patches applied | Pattern registration must extend the real validator |
| ITP-015-A | Extension manifest YAML | Real `extension.yml` with ARCH-015 entries applied | Manifest discovery must parse the real YAML file |
| ITP-016-A | CI workflow (evals.yml) | Fixture inputs for evaluation cases; real evaluation runner | CI evaluation must execute against real quality thresholds |
| ITP-017-A | V0.1.0 artifact snapshots | Byte-identical snapshots taken before v0.2.0 operations | Compatibility verification requires real file comparison |

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Architecture Modules (ARCH) | 17 |
| Total Test Cases (ITP) | 23 |
| Total Scenarios (ITS) | 48 |
| Modules with ≥1 ITP | 17 / 17 (100%) |
| Test Cases with ≥1 ITS | 23 / 23 (100%) |
| **Overall Coverage (ARCH→ITP)** | **100%** |

### Technique Distribution

| Technique | Test Cases | Percentage |
|-----------|-----------|------------|
| Interface Contract Testing | 13 | 57% |
| Data Flow Testing | 5 | 22% |
| Interface Fault Injection | 5 | 22% |
| Concurrency & Race Condition Testing | 0 | 0% |

> Note: No concurrency tests are generated because the architecture uses sequential execution within single Bash/PowerShell processes. The validation pipeline (ARCH-008) executes validators in order, and the matrix builder pipeline (ARCH-013) executes extraction then building sequentially. All Process View interactions are explicitly documented as "Sequential — single-threaded execution" with no concurrent access patterns to test.

## Uncovered Modules

None — full coverage achieved.
