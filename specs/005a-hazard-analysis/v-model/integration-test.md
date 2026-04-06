# Integration Test Plan: Hazard Analysis (FMEA)

**Feature Branch**: `005a-hazard-analysis`
**Created**: 2026-04-01
**Status**: Approved
**Source**: `specs/005a-hazard-analysis/v-model/architecture-design.md`

## Overview

This document defines the Integration Test Plan for the Hazard Analysis (FMEA) command. Every architecture module in `architecture-design.md` has one or more Test Cases (ITP), and every Test Case has one or more executable Integration Scenarios (ITS) in module-boundary BDD format (Given/When/Then). Integration tests verify **seams and handshakes between modules**, not internal logic or user journeys. The test strategy covers: Interface Contract Testing for module-to-module API compliance, Data Flow Testing for end-to-end data transformation chains, Interface Fault Injection for failure handling at module boundaries, and Concurrency & Race Condition Testing where sequential execution order matters.

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

### Module Verification: ARCH-001 (Hazard Analysis Command Definition)

**Parent System Components**: SYS-001

#### Test Case: ITP-001-A (Template Loading Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-001 → ARCH-002 interface
**Description**: Verifies that ARCH-001 (Command) correctly loads and applies the structure defined by ARCH-002 (Template) when producing hazard-analysis.md.

* **Integration Scenario: ITS-001-A1**
  * **Given** ARCH-002 (Hazard Analysis Template) defines sections Summary, Risk Matrix Definition, Operational States Reference, and Hazard Register with 10-column FMEA table
  * **When** ARCH-001 (Hazard Analysis Command) loads the template and generates output
  * **Then** the output `hazard-analysis.md` contains all four sections with the FMEA table matching the 10-column structure defined by ARCH-002

#### Test Case: ITP-001-B (Missing Prerequisite Fault)

**Technique**: Interface Fault Injection
**Target View**: Interface View — ARCH-001 input contract
**Description**: Verifies that ARCH-001 handles missing input files with the specified error message.

* **Integration Scenario: ITS-001-B1**
  * **Given** the V-Model directory contains `requirements.md` but `system-design.md` does not exist
  * **When** ARCH-001 (Hazard Analysis Command) attempts to read its mandatory inputs
  * **Then** ARCH-001 emits the error "hazard-analysis requires both requirements.md and system-design.md. Run /speckit.v-model.system-design first." and produces no output file

---

### Module Verification: ARCH-002 (Hazard Analysis Template)

**Parent System Components**: SYS-002

#### Test Case: ITP-002-A (Template Structural Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-002 output contract
**Description**: Verifies that ARCH-002 (Template) provides a structure that ARCH-001 (Command) can consume without modification.

* **Integration Scenario: ITS-002-A1**
  * **Given** ARCH-002 (Hazard Analysis Template) exists in the `templates/` directory
  * **When** ARCH-001 (Hazard Analysis Command) reads the template file
  * **Then** the template provides HTML comment markers and table headers that ARCH-001 can parse to determine section boundaries and FMEA column order

---

### Module Verification: ARCH-003 (Forward Coverage Validator)

**Parent System Components**: SYS-003

#### Test Case: ITP-003-A (Forward Validator → CLI Formatter Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-003 → ARCH-006 interface
**Description**: Verifies that ARCH-003 returns coverage results in the format expected by ARCH-006 (CLI Formatter).

* **Integration Scenario: ITS-003-A1**
  * **Given** ARCH-003 (Forward Coverage Validator) processes a `system-design.md` with 5 SYS components and a `hazard-analysis.md` covering only 3
  * **When** ARCH-003 returns its result to ARCH-006 (CLI Formatter)
  * **Then** ARCH-006 receives a data structure with `covered: ["SYS-001","SYS-002","SYS-003"]`, `uncovered: ["SYS-004","SYS-005"]`, and `pct: 60`

#### Test Case: ITP-003-B (Forward Validator Fault — Empty FMEA)

**Technique**: Interface Fault Injection
**Target View**: Interface View — ARCH-003 input contract
**Description**: Verifies that ARCH-003 handles a `hazard-analysis.md` with no valid HAZ entries gracefully.

* **Integration Scenario: ITS-003-B1**
  * **Given** ARCH-003 receives a `hazard-analysis.md` containing only section headers and no `HAZ-NNN` entries
  * **When** ARCH-003 attempts to extract Component column references
  * **Then** ARCH-003 returns `covered: []`, `uncovered: [all SYS IDs]`, and `pct: 0` without crashing

---

### Module Verification: ARCH-004 (Backward Coverage Validator)

**Parent System Components**: SYS-003

#### Test Case: ITP-004-A (Backward Validator → CLI Formatter Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-004 → ARCH-006 interface
**Description**: Verifies that ARCH-004 returns broken reference details in the format expected by ARCH-006.

* **Integration Scenario: ITS-004-A1**
  * **Given** ARCH-004 (Backward Coverage Validator) processes a `hazard-analysis.md` where `HAZ-003` references `REQ-XYZ` which does not exist in `requirements.md`
  * **When** ARCH-004 returns its result to ARCH-006 (CLI Formatter)
  * **Then** ARCH-006 receives `broken: ["HAZ-003 references REQ-XYZ which does not exist"]` and `pct` reflecting the gap

#### Test Case: ITP-004-B (Backward Validator Fault — Missing requirements.md)

**Technique**: Interface Fault Injection
**Target View**: Interface View — ARCH-004 input contract
**Description**: Verifies that ARCH-004 reports inability to validate when `requirements.md` is missing (non-partial mode).

* **Integration Scenario: ITS-004-B1**
  * **Given** ARCH-004 is invoked in non-partial mode and `requirements.md` does not exist in the V-Model directory
  * **When** ARCH-004 attempts to read `requirements.md` for reference validation
  * **Then** ARCH-004 returns an error indicating `requirements.md` is missing, and ARCH-006 includes this in its exit code 1 report

---

### Module Verification: ARCH-005 (State Consistency Validator)

**Parent System Components**: SYS-003

#### Test Case: ITP-005-A (State Validator → CLI Formatter Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-005 → ARCH-006 interface
**Description**: Verifies that ARCH-005 returns state consistency results in the format expected by ARCH-006.

* **Integration Scenario: ITS-005-A1**
  * **Given** ARCH-005 (State Consistency Validator) processes a `hazard-analysis.md` with entries referencing state "MAINTENANCE" which is not defined in `system-design.md`
  * **When** ARCH-005 returns its result to ARCH-006 (CLI Formatter)
  * **Then** ARCH-006 receives `defined_states: ["IDLE","ACTIVE"]`, `undefined_states: ["MAINTENANCE"]`, and `consistent: false`

* **Integration Scenario: ITS-005-A2**
  * **Given** `system-design.md` defines no explicit operational states
  * **When** ARCH-005 extracts the valid state set from the design document
  * **Then** ARCH-005 uses the implicit set `["NORMAL"]` and accepts all hazard entries that reference "NORMAL"

---

### Module Verification: ARCH-006 (Validation CLI and Output Formatter)

**Parent System Components**: SYS-003

#### Test Case: ITP-006-A (CLI Orchestration of Three Validators)

**Technique**: Data Flow Testing
**Target View**: Data Flow View — Coverage Validation flow (stages 1–5)
**Description**: Verifies the end-to-end data flow from CLI argument parsing through all three validators to final output.

* **Integration Scenario: ITS-006-A1**
  * **Given** ARCH-006 (CLI Formatter) receives arguments `specs/005a-hazard-analysis/v-model --json`
  * **When** ARCH-006 orchestrates ARCH-003, ARCH-004, and ARCH-005 sequentially
  * **Then** the stdout output is valid JSON containing `has_gaps`, `forward_coverage`, `backward_coverage`, `state_consistency`, `forward_gaps`, `backward_gaps`, and `state_warnings` fields aggregated from all three validators

#### Test Case: ITP-006-B (Partial Mode — Backward Validator Skip)

**Technique**: Interface Fault Injection
**Target View**: Process View — Validation Pipeline interaction
**Description**: Verifies that `--partial` mode correctly skips the backward coverage check when requirements.md is absent.

* **Integration Scenario: ITS-006-B1**
  * **Given** ARCH-006 receives arguments `specs/005a-hazard-analysis/v-model --json --partial` and `requirements.md` does not exist
  * **When** ARCH-006 orchestrates the validation pipeline
  * **Then** ARCH-006 invokes ARCH-003 (Forward) and ARCH-005 (State) but skips ARCH-004 (Backward), and the JSON output contains `backward_coverage: "N/A"` with `has_gaps` reflecting only forward and state results

---

### Module Verification: ARCH-007 (PowerShell Coverage Validation)

**Parent System Components**: SYS-004

#### Test Case: ITP-007-A (Cross-Platform Parity at Module Boundary)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-007 vs ARCH-006 output parity
**Description**: Verifies that ARCH-007 (PowerShell) produces identical JSON output structure and exit codes as ARCH-006 (Bash) for the same inputs.

* **Integration Scenario: ITS-007-A1**
  * **Given** a V-Model directory with known coverage gaps processed by both ARCH-006 (Bash CLI `--json`) and ARCH-007 (PowerShell `-Json`)
  * **When** both modules produce their JSON output
  * **Then** the JSON structures are field-identical: same `has_gaps`, `forward_coverage`, `backward_coverage`, `state_consistency` values and same exit codes

---

### Module Verification: ARCH-008 (HAZ ID Extractor)

**Parent System Components**: SYS-005

#### Test Case: ITP-008-A (Extractor → Matrix Builder Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-008 → ARCH-009 interface
**Description**: Verifies that ARCH-008 extracts HAZ IDs and mitigations in the format expected by ARCH-009.

* **Integration Scenario: ITS-008-A1**
  * **Given** ARCH-008 (HAZ ID Extractor) processes a `hazard-analysis.md` with `HAZ-001` mitigated by `REQ-001, SYS-002` and `HAZ-002` mitigated by `REQ-003`
  * **When** ARCH-008 passes its extracted data to ARCH-009 (Matrix H Builder)
  * **Then** ARCH-009 receives `[{haz_id: "HAZ-001", mitigations: ["REQ-001","SYS-002"]}, {haz_id: "HAZ-002", mitigations: ["REQ-003"]}]`

#### Test Case: ITP-008-B (Extractor Fault — Malformed FMEA Table)

**Technique**: Interface Fault Injection
**Target View**: Interface View — ARCH-008 input contract
**Description**: Verifies that ARCH-008 handles a malformed `hazard-analysis.md` without crashing.

* **Integration Scenario: ITS-008-B1**
  * **Given** ARCH-008 receives a `hazard-analysis.md` with a corrupted FMEA table where the Mitigation column is missing
  * **When** ARCH-008 attempts regex extraction
  * **Then** ARCH-008 returns an empty array `[]` and ARCH-009 produces no Matrix H rows

---

### Module Verification: ARCH-009 (Matrix H Table Builder)

**Parent System Components**: SYS-005

#### Test Case: ITP-009-A (Matrix H Verification Chain Resolution)

**Technique**: Data Flow Testing
**Target View**: Data Flow View — Matrix H Construction flow (stages 1–3)
**Description**: Verifies the end-to-end data flow from HAZ entries through mitigation resolution to Matrix H table rows.

* **Integration Scenario: ITS-009-A1**
  * **Given** ARCH-009 (Matrix H Builder) receives HAZ entries from ARCH-008 with `HAZ-001` mitigated by `REQ-001`, and `acceptance-plan.md` contains `ATP-001-A` covering `REQ-001`
  * **When** ARCH-009 resolves the verification chain
  * **Then** the Matrix H output row shows `HAZ-001 | REQ-001 | ATP-001-A`

* **Integration Scenario: ITS-009-A2**
  * **Given** ARCH-009 receives HAZ entries with `HAZ-005` mitigated by `SYS-003` and no test case directly covers `SYS-003`
  * **When** ARCH-009 resolves the verification chain
  * **Then** the Matrix H output row shows `HAZ-005 | SYS-003 | ⚠️ No test coverage`

#### Test Case: ITP-009-B (Backward Compatibility — No Hazard File)

**Technique**: Interface Fault Injection
**Target View**: Interface View — ARCH-009 input contract
**Description**: Verifies that ARCH-009 produces no output when hazard-analysis.md is absent.

* **Integration Scenario: ITS-009-B1**
  * **Given** the V-Model directory contains all v0.4.0 artifacts but no `hazard-analysis.md`
  * **When** ARCH-008 (Extractor) finds no file and passes an empty signal to ARCH-009
  * **Then** ARCH-009 produces no Matrix H output and no error or warning

---

### Module Verification: ARCH-010 (PowerShell Matrix H Builder)

**Parent System Components**: SYS-006

#### Test Case: ITP-010-A (Matrix H Cross-Platform Parity)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-010 vs ARCH-008/009 output parity
**Description**: Verifies that ARCH-010 (PowerShell) produces identical Matrix H rows as ARCH-008/009 (Bash) for the same inputs.

* **Integration Scenario: ITS-010-A1**
  * **Given** a `hazard-analysis.md` processed by both ARCH-008/009 (Bash) and ARCH-010 (PowerShell)
  * **When** both produce Matrix H output
  * **Then** the Matrix H rows are identical including gap annotations `⚠️ No test coverage`

---

### Module Verification: ARCH-011 (Trace Command Matrix H Integration)

**Parent System Components**: SYS-007

#### Test Case: ITP-011-A (Trace → Matrix Builder Pipeline)

**Technique**: Data Flow Testing
**Target View**: Data Flow View — Matrix H integration into trace output
**Description**: Verifies that ARCH-011 (Trace Extension) correctly calls ARCH-008/009 and includes Matrix H in the composite output.

* **Integration Scenario: ITS-011-A1**
  * **Given** ARCH-011 (Trace Command Extension) detects `hazard-analysis.md` in the V-Model directory
  * **When** ARCH-011 invokes ARCH-008 (HAZ Extractor) and ARCH-009 (Matrix H Builder) as part of the build-matrix pipeline
  * **Then** the trace output includes Matrix H as a separate table after Matrices A–D with independent coverage percentage

* **Integration Scenario: ITS-011-A2**
  * **Given** ARCH-011 detects that `hazard-analysis.md` does NOT exist in the V-Model directory
  * **When** ARCH-011 checks the AVAILABLE_DOCS list
  * **Then** ARCH-011 skips the Matrix H section entirely with no warning and produces identical output to v0.4.0

---

### Module Verification: ARCH-012 (HAZ ID Pattern Registration)

**Parent System Components**: SYS-008

#### Test Case: ITP-012-A (ID Validator Integration with HAZ Pattern)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-012 input/output contract
**Description**: Verifies that ARCH-012 extends the ID validator to accept HAZ-NNN alongside all existing prefixes.

* **Integration Scenario: ITS-012-A1**
  * **Given** ARCH-012 (HAZ Pattern Registration) has been applied to `id_validator.py`
  * **When** the validator processes a document containing `HAZ-001`, `REQ-001`, `SYS-001`, `ARCH-001`
  * **Then** all four identifiers are recognized as valid V-Model IDs with their respective prefixes

---

### Module Verification: ARCH-013 (Extension Manifest Entries)

**Parent System Components**: SYS-009

#### Test Case: ITP-013-A (Manifest Discovery of Hazard Analysis Command)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-013 output contract
**Description**: Verifies that spec-kit can discover and load the hazard-analysis command from the manifest.

* **Integration Scenario: ITS-013-A1**
  * **Given** ARCH-013 (Extension Manifest) registers `speckit.v-model.hazard-analysis` with file path `commands/hazard-analysis.md`
  * **When** the spec-kit extension loader parses `extension.yml`
  * **Then** the loader discovers the hazard-analysis command, resolves its file path, and the `defaults.id_prefixes` section includes `hazards: "HAZ"`

---

## Test Harness & Mocking Strategy

| Test Case | External Dependency | Mock/Stub Strategy | Rationale |
|-----------|--------------------|--------------------|-----------|
| ITP-001-A | GitHub Copilot AI runtime | Fixture-based output comparison — pre-generated `hazard-analysis.md` compared against template structure | AI output varies; structural compliance is verified deterministically |
| ITP-001-B | V-Model directory filesystem | Controlled test directory with selective file presence/absence | Prerequisite checking must work against real filesystem paths |
| ITP-003-A, ITP-004-A, ITP-005-A | Source artifacts (system-design.md, requirements.md) | Minimal fixture files with known ID sets | Deterministic coverage results require controlled inputs |
| ITP-006-A, ITP-006-B | All three validators | Integration test with fixture files — no mocking of validators | Validates the real orchestration pipeline, not stubbed behavior |
| ITP-007-A | Bash script output | Bash output captured as golden reference for PowerShell comparison | Cross-platform parity requires identical outputs from identical inputs |
| ITP-008-A, ITP-009-A | Acceptance-plan.md, system-test.md | Minimal fixtures with known ATP/STP IDs for verification chain resolution | Matrix H verification chain must resolve against real artifact structures |
| ITP-011-A | Build-matrix pipeline | Full pipeline execution with fixture V-Model directory | Integration with trace command requires real matrix builder invocation |

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Architecture Modules (ARCH) | 13 |
| Total Test Cases (ITP) | 19 |
| Total Scenarios (ITS) | 22 |
| Modules with ≥1 ITP | 13 / 13 (100%) |
| Test Cases with ≥1 ITS | 18 / 18 (100%) |
| **Overall Coverage (ARCH→ITP)** | **100%** |

### Technique Distribution

| Technique | Test Cases | Percentage |
|-----------|-----------|------------|
| Interface Contract Testing | 10 | 56% |
| Data Flow Testing | 3 | 17% |
| Interface Fault Injection | 5 | 28% |
| Concurrency & Race Condition Testing | 0 | 0% |

> Note: No concurrency tests are generated because the architecture uses sequential execution within single Bash/PowerShell processes. The validation pipeline (ARCH-006) executes validators in order, and the matrix builder pipeline (ARCH-011) executes extraction then building sequentially. There are no concurrent access patterns to test.

## Uncovered Modules

None — full coverage achieved.
