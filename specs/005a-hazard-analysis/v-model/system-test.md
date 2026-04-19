# System Test Plan: Hazard Analysis (FMEA)

**Feature Branch**: `005a-hazard-analysis`
**Created**: 2026-04-01
**Status**: Approved
**Source**: `specs/005a-hazard-analysis/v-model/system-design.md`

## Overview

This document defines the System Test Plan for the Hazard Analysis (FMEA) command. Every system component in `system-design.md` has one or more Test Cases (STP), and every Test Case has one or more executable System Scenarios (STS) in technical BDD format (Given/When/Then). System tests verify **architectural behavior**, not user journeys. Language is technical and component-oriented. The test strategy covers: Interface Contract Testing for all CLI and command interfaces, Boundary Value Analysis for data limits and edge conditions, Equivalence Partitioning for input categories, and Fault Injection for dependency failures and degradation paths.

## ID Schema

- **System Test Case**: `STP-{NNN}-{X}` — where NNN matches the parent SYS, X is a letter suffix (A, B, C...)
- **System Test Scenario**: `STS-{NNN}-{X}{#}` — nested under the parent STP, with numeric suffix (1, 2, 3...)
- Example: `STS-003-B1` → Scenario 1 of Test Case B verifying SYS-003

## ISO 29119 Test Techniques

Each test case identifies its technique by name:
- **Interface Contract Testing** — Verifies API contracts from the Interface View
- **Boundary Value Analysis** — Tests data limits from the Data Design View
- **Equivalence Partitioning** — Tests representative data classes
- **Fault Injection** — Tests failure propagation from the Dependency View

## System Tests

### Component Verification: SYS-001 (Hazard Analysis Command)

**Parent Requirements**: REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-032, REQ-034, REQ-038, REQ-039, REQ-040, REQ-NF-002, REQ-IF-003

#### Test Case: STP-001-A (FMEA Output Structure Conformance)

**Technique**: Interface Contract Testing
**Target View**: Interface View — External Interfaces (Copilot Chat Command)
**Description**: Verifies that the Hazard Analysis Command produces `hazard-analysis.md` conforming to the template structure with all mandatory sections and fields when given valid `requirements.md` and `system-design.md` inputs.

* **System Scenario: STS-001-A1**
  * **Given** a V-Model directory containing `requirements.md` with 10 `REQ-NNN` identifiers and `system-design.md` with 5 `SYS-NNN` components defining 3 operational states (IDLE, ACTIVE, ERROR)
  * **When** the Hazard Analysis Command processes the inputs
  * **Then** the command produces `hazard-analysis.md` containing: a Summary section, a Risk Matrix Definition section, an Operational States Reference section listing IDLE/ACTIVE/ERROR, and a Hazard Register FMEA table with columns HAZ ID, Component, Failure Mode, Operational State, Effect, Severity, Likelihood, Risk Level, Mitigation, and Residual Risk

* **System Scenario: STS-001-A2**
  * **Given** a V-Model directory containing `requirements.md` and `system-design.md`
  * **When** the Hazard Analysis Command generates hazard entries
  * **Then** every `HAZ-NNN` identifier matches the regex `HAZ-[0-9]{3}`, IDs are sequential starting from `HAZ-001`, and every entry contains all 8 mandatory fields with non-empty values

#### Test Case: STP-001-B (Operational State Analysis)

**Technique**: Equivalence Partitioning
**Target View**: Decomposition View — Operational State handling
**Description**: Verifies that the command partitions failure modes across operational states, creating separate hazard entries when severity differs by state.

* **System Scenario: STS-001-B1**
  * **Given** a `system-design.md` defining `SYS-001` with operational states IDLE and ACTIVE, where a sensor failure during IDLE has Negligible severity and during ACTIVE has Critical severity
  * **When** the Hazard Analysis Command analyzes `SYS-001`
  * **Then** the output contains at least two separate `HAZ-NNN` entries for the sensor failure: one with Operational State "IDLE" and Severity "Negligible", and one with Operational State "ACTIVE" and Severity "Critical"

* **System Scenario: STS-001-B2**
  * **Given** a `system-design.md` defining no explicit operational states for any component
  * **When** the Hazard Analysis Command processes the inputs
  * **Then** all hazard entries use Operational State "NORMAL" and the output includes a validation warning: "No operational states defined in system-design.md — using implicit NORMAL state"

#### Test Case: STP-001-C (Mitigation Traceability)

**Technique**: Interface Contract Testing
**Target View**: Interface View — Internal Interfaces (Shared Parsing Convention)
**Description**: Verifies that every hazard mitigation field references at least one valid `REQ-NNN` or `SYS-NNN` identifier, creating machine-parseable traceability links.

* **System Scenario: STS-001-C1**
  * **Given** a valid `requirements.md` and `system-design.md`
  * **When** the Hazard Analysis Command generates the hazard register
  * **Then** every `HAZ-NNN` entry's Mitigation column contains at least one `REQ-NNN` or `SYS-NNN` reference that exists in the corresponding source document

#### Test Case: STP-001-D (Progressive Deepening — Architecture Level)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View — FMEA Table Data (append-only)
**Description**: Verifies that re-running the command with `architecture-design.md` present preserves existing entries and appends new architecture-level failure modes.

* **System Scenario: STS-001-D1**
  * **Given** an existing `hazard-analysis.md` with entries `HAZ-001` through `HAZ-015` and a newly created `architecture-design.md` with `ARCH-NNN` modules
  * **When** the Hazard Analysis Command runs with progressive deepening
  * **Then** entries `HAZ-001` through `HAZ-015` remain unmodified and new architecture-level entries start from `HAZ-016` with sequential numbering

* **System Scenario: STS-001-D2**
  * **Given** an existing `hazard-analysis.md` with entries `HAZ-001` through `HAZ-015` and an `architecture-design.md` that introduces no new failure modes beyond what SYS-level analysis already covers
  * **When** the Hazard Analysis Command runs with progressive deepening
  * **Then** no new `HAZ-NNN` entries are appended and the output includes the note "No additional architecture-level hazards identified"

#### Test Case: STP-001-E (Missing Prerequisite Handling)

**Technique**: Fault Injection
**Target View**: Dependency View — SYS-001 → SYS-002 (template dependency)
**Description**: Verifies that the command fails gracefully when required input artifacts are missing.

* **System Scenario: STS-001-E1**
  * **Given** a V-Model directory containing `requirements.md` but no `system-design.md`
  * **When** the Hazard Analysis Command is invoked
  * **Then** the command emits the error message "hazard-analysis requires both requirements.md and system-design.md. Run /speckit.v-model.system-design first." and produces no output file

#### Test Case: STP-001-F (Forward Coverage Completeness)

**Technique**: Boundary Value Analysis
**Target View**: Decomposition View — SYS→HAZ mapping
**Description**: Verifies that every `SYS-NNN` component in the system design receives at least one hazard entry, including components where no realistic failure mode exists.

* **System Scenario: STS-001-F1**
  * **Given** a `system-design.md` with 9 `SYS-NNN` components, including `SYS-009` (Extension Manifest Update) for which no realistic failure mode exists
  * **When** the Hazard Analysis Command processes all components
  * **Then** every `SYS-NNN` from `SYS-001` through `SYS-009` appears in at least one `HAZ-NNN` entry's Component column, and `SYS-009` has a "No identified failure mode" entry with Severity "Negligible" flagged for human review

#### Test Case: STP-001-G (Domain Overlay Severity Scales)

**Technique**: Equivalence Partitioning
**Target View**: Decomposition View — Domain overlay loading behavior
**Description**: Verifies that domain-specific severity scales are loaded from overlays when `v-model-config.yml` specifies a `domain` value, and that general-purpose FMEA is produced when no domain is configured.

* **System Scenario: STS-001-G1**
  * **Given** a `v-model-config.yml` with `domain: iso_26262` and an overlay file at `commands/overlays/iso_26262/hazard-analysis.md`
  * **When** the Hazard Analysis Command generates the hazard register
  * **Then** the severity classifications use the ASIL scale (S0–S3, QM–D) from the iso_26262 overlay

* **System Scenario: STS-001-G2**
  * **Given** no `v-model-config.yml` file exists in the repository root
  * **When** the Hazard Analysis Command generates the hazard register
  * **Then** the severity classifications use the base general-purpose scale (Negligible, Minor, Moderate, Critical, Catastrophic) without loading any domain overlay, and operational state analysis is still applied

#### Test Case: STP-001-H (Strict Translator Constraint)

**Technique**: Interface Contract Testing
**Target View**: Decomposition View — Translation fidelity
**Description**: Verifies that the command does not invent components, capabilities, or operational states not present in the source artifacts.

* **System Scenario: STS-001-H1**
  * **Given** a `system-design.md` defining exactly 3 operational states (IDLE, ACTIVE, ERROR) and 5 components (`SYS-001` through `SYS-005`)
  * **When** the Hazard Analysis Command generates the hazard register
  * **Then** every Operational State value in the output is one of IDLE, ACTIVE, or ERROR, and every Component column value references only `SYS-001` through `SYS-005`

#### Test Case: STP-001-I (Large Hazard Register)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View — FMEA Table Data capacity
**Description**: Verifies that the command handles 50+ hazard entries without batching or truncation.

* **System Scenario: STS-001-I1**
  * **Given** a `system-design.md` with 20 `SYS-NNN` components, each with 3 operational states
  * **When** the Hazard Analysis Command generates the hazard register
  * **Then** the output contains 50+ `HAZ-NNN` entries, all sequentially numbered, all with complete 8-field entries, and no truncation markers or batch boundaries

---

### Component Verification: SYS-002 (Hazard Analysis Template)

**Parent Requirements**: REQ-017, REQ-018

#### Test Case: STP-002-A (Template Structural Completeness)

**Technique**: Interface Contract Testing
**Target View**: Interface View — Internal Interfaces (Template Loading)
**Description**: Verifies that the template defines all mandatory sections and FMEA table columns required by the command.

* **System Scenario: STS-002-A1**
  * **Given** the `hazard-analysis-template.md` file in the `templates/` directory
  * **When** the template structure is inspected
  * **Then** the template contains sections for Summary, Risk Matrix Definition, Operational States Reference, and Hazard Register, and the FMEA table includes columns: HAZ ID, Component (`SYS-NNN`), Failure Mode, Operational State, Effect, Severity, Likelihood, Risk Level, Mitigation (`REQ-NNN` / `SYS-NNN` refs), and Residual Risk

---

### Component Verification: SYS-003 (Hazard Coverage Validation Script — Bash)

**Parent Requirements**: REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-NF-001, REQ-NF-002, REQ-NF-003, REQ-IF-001, REQ-IF-002, REQ-CN-004

#### Test Case: STP-003-A (Forward Coverage Validation)

**Technique**: Interface Contract Testing
**Target View**: Interface View — External Interfaces (CLI Invocation Bash)
**Description**: Verifies that the script detects when `SYS-NNN` components lack associated `HAZ-NNN` entries.

* **System Scenario: STS-003-A1**
  * **Given** a `system-design.md` with `SYS-001` through `SYS-005` and a `hazard-analysis.md` with entries covering only `SYS-001` through `SYS-003`
  * **When** `validate-hazard-coverage.sh` is executed with the V-Model directory path
  * **Then** the script exits with code 1 and the human-readable output lists "SYS-004: no hazard analysis mapping found" and "SYS-005: no hazard analysis mapping found"

* **System Scenario: STS-003-A2**
  * **Given** a `system-design.md` with `SYS-001` through `SYS-005` and a `hazard-analysis.md` with entries covering all 5 components
  * **When** `validate-hazard-coverage.sh` is executed with the V-Model directory path
  * **Then** the script exits with code 0 and the output confirms 100% forward coverage

#### Test Case: STP-003-B (Backward Coverage Validation)

**Technique**: Interface Contract Testing
**Target View**: Interface View — External Interfaces (CLI Invocation Bash)
**Description**: Verifies that the script detects mitigation references to non-existent `REQ-NNN` or `SYS-NNN` identifiers.

* **System Scenario: STS-003-B1**
  * **Given** a `hazard-analysis.md` where `HAZ-007` mitigation references `REQ-XYZ` which does not exist in `requirements.md`
  * **When** `validate-hazard-coverage.sh` is executed
  * **Then** the script exits with code 1 and the output includes "HAZ-007 references REQ-XYZ which does not exist"

* **System Scenario: STS-003-B2**
  * **Given** a `hazard-analysis.md` where all mitigation references map to existing `REQ-NNN` or `SYS-NNN` identifiers
  * **When** `validate-hazard-coverage.sh` is executed
  * **Then** the script reports 100% backward coverage with no backward gaps

#### Test Case: STP-003-C (Operational State Consistency Validation)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View — Coverage Validation Results
**Description**: Verifies that the script detects hazard entries referencing operational states not defined in the system design.

* **System Scenario: STS-003-C1**
  * **Given** a `system-design.md` defining states IDLE and ACTIVE, and a `hazard-analysis.md` with an entry referencing operational state "MAINTENANCE" which is not in the design
  * **When** `validate-hazard-coverage.sh` is executed
  * **Then** the script exits with code 1 and the output includes a state consistency warning identifying the undefined state "MAINTENANCE"

* **System Scenario: STS-003-C2**
  * **Given** a `system-design.md` defining no explicit operational states and a `hazard-analysis.md` with all entries using state "NORMAL"
  * **When** `validate-hazard-coverage.sh` is executed
  * **Then** the script treats "NORMAL" as the implicit valid state and reports state consistency as passing

#### Test Case: STP-003-D (JSON Output Mode)

**Technique**: Interface Contract Testing
**Target View**: Interface View — External Interfaces (CLI Invocation Bash)
**Description**: Verifies that the `--json` flag produces machine-readable output conforming to the defined schema.

* **System Scenario: STS-003-D1**
  * **Given** a V-Model directory with complete hazard artifacts and some coverage gaps
  * **When** `validate-hazard-coverage.sh --json` is executed
  * **Then** the stdout output is valid JSON containing fields: `has_gaps` (boolean), `forward_coverage` (string percentage), `backward_coverage` (string percentage), `state_consistency` (boolean), `forward_gaps` (array), `backward_gaps` (array), `state_warnings` (array)

#### Test Case: STP-003-E (Partial Validation Mode)

**Technique**: Fault Injection
**Target View**: Dependency View — Script artifact dependencies
**Description**: Verifies that the `--partial` flag enables validation when not all artifacts exist.

* **System Scenario: STS-003-E1**
  * **Given** a V-Model directory containing `hazard-analysis.md` and `system-design.md` but no `requirements.md`
  * **When** `validate-hazard-coverage.sh --partial` is executed
  * **Then** the script validates forward coverage (SYS→HAZ) and operational state consistency, skips backward coverage checks, and exits with code 0 if forward and state checks pass

* **System Scenario: STS-003-E2**
  * **Given** the same directory as STS-003-E1
  * **When** `validate-hazard-coverage.sh` is executed WITHOUT the `--partial` flag
  * **Then** the script exits with code 1 reporting that `requirements.md` is missing and backward coverage cannot be validated

#### Test Case: STP-003-F (Performance)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View — Coverage Validation Results capacity
**Description**: Verifies that validation completes within performance thresholds for large hazard registers.

* **System Scenario: STS-003-F1**
  * **Given** a `hazard-analysis.md` with 100 `HAZ-NNN` entries and corresponding `system-design.md` and `requirements.md`
  * **When** `validate-hazard-coverage.sh` is executed
  * **Then** the script completes within 5 seconds

---

### Component Verification: SYS-004 (Hazard Coverage Validation Script — PowerShell)

**Parent Requirements**: REQ-026, REQ-CN-004

#### Test Case: STP-004-A (Cross-Platform Parity)

**Technique**: Interface Contract Testing
**Target View**: Interface View — External Interfaces (CLI Invocation PowerShell)
**Description**: Verifies that the PowerShell script produces identical JSON output structure, field values, and exit codes as the Bash script for the same inputs.

* **System Scenario: STS-004-A1**
  * **Given** a V-Model directory with known coverage gaps processed by both `validate-hazard-coverage.sh --json` and `Validate-HazardCoverage.ps1 -Json`
  * **When** both scripts are executed with identical inputs
  * **Then** both produce JSON output with identical `has_gaps`, `forward_coverage`, `backward_coverage`, `state_consistency` values and identical exit codes

* **System Scenario: STS-004-A2**
  * **Given** a V-Model directory with 100% coverage processed by both scripts
  * **When** both scripts are executed
  * **Then** both exit with code 0 and produce identical JSON structures with `has_gaps: false`

---

### Component Verification: SYS-005 (Matrix Builder Script Extension — Bash)

**Parent Requirements**: REQ-027, REQ-028, REQ-029, REQ-CN-002, REQ-CN-003

#### Test Case: STP-005-A (Matrix H Generation)

**Technique**: Interface Contract Testing
**Target View**: Interface View — Internal Interfaces (Matrix H Data Generation)
**Description**: Verifies that the matrix builder parses `hazard-analysis.md` and produces Matrix H with HAZ→Mitigation→Verification traceability.

* **System Scenario: STS-005-A1**
  * **Given** a `hazard-analysis.md` with `HAZ-001` mitigated by `REQ-001`, and an `acceptance-plan.md` with `ATP-001-A` covering `REQ-001`
  * **When** `build-matrix.sh` processes the V-Model directory
  * **Then** Matrix H output contains a row: `HAZ-001` → Mitigation `REQ-001` → Verification `ATP-001-A`

* **System Scenario: STS-005-A2**
  * **Given** a `hazard-analysis.md` with `HAZ-005` mitigated by `SYS-003`, and no test case directly covers `SYS-003`
  * **When** `build-matrix.sh` processes the V-Model directory
  * **Then** Matrix H output contains a row: `HAZ-005` → Mitigation `SYS-003` → Verification `⚠️ No test coverage`

#### Test Case: STP-005-B (Backward Compatibility)

**Technique**: Fault Injection
**Target View**: Dependency View — Matrix builder with absent artifacts
**Description**: Verifies that projects without `hazard-analysis.md` produce the same v0.4.0 output.

* **System Scenario: STS-005-B1**
  * **Given** a V-Model directory containing all v0.4.0 artifacts (requirements through unit-test) but no `hazard-analysis.md`
  * **When** `build-matrix.sh` processes the V-Model directory
  * **Then** the output contains Matrices A through D with no Matrix H section, no warning, and no error

---

### Component Verification: SYS-006 (Matrix Builder Script Extension — PowerShell)

**Parent Requirements**: REQ-030

#### Test Case: STP-006-A (Matrix H Cross-Platform Parity)

**Technique**: Interface Contract Testing
**Target View**: Interface View — Internal Interfaces (Matrix H Data Generation)
**Description**: Verifies that the PowerShell matrix builder produces identical Matrix H output as the Bash version.

* **System Scenario: STS-006-A1**
  * **Given** a V-Model directory with `hazard-analysis.md` processed by both `build-matrix.sh` and `build-matrix.ps1`
  * **When** both scripts are executed with identical inputs
  * **Then** both produce identical Matrix H rows with the same HAZ→Mitigation→Verification mappings

---

### Component Verification: SYS-007 (Trace Command Extension)

**Parent Requirements**: REQ-031, REQ-CN-002, REQ-CN-003

#### Test Case: STP-007-A (Matrix H Inclusion in Trace Output)

**Technique**: Interface Contract Testing
**Target View**: Dependency View — SYS-007 → SYS-005/SYS-006 calls
**Description**: Verifies that the trace command includes Matrix H when `hazard-analysis.md` exists and follows the progressive matrix building pattern.

* **System Scenario: STS-007-A1**
  * **Given** a V-Model directory containing `requirements.md`, `acceptance-plan.md`, `system-design.md`, `system-test.md`, and `hazard-analysis.md`
  * **When** the `/speckit.v-model.trace` command is invoked
  * **Then** the traceability matrix output includes Matrix A (Acceptance), Matrix B (System Verification), and Matrix H (Hazard Traceability) as separate tables with independent coverage percentages

* **System Scenario: STS-007-A2**
  * **Given** a V-Model directory containing all v0.4.0 artifacts but no `hazard-analysis.md`
  * **When** the `/speckit.v-model.trace` command is invoked
  * **Then** the traceability matrix output includes Matrices A through D only, with no Matrix H section, no warning about missing hazard analysis, and no change from v0.4.0 behavior

---

### Component Verification: SYS-008 (ID Validator Extension)

**Parent Requirements**: REQ-032, REQ-033

#### Test Case: STP-008-A (HAZ-NNN ID Recognition)

**Technique**: Interface Contract Testing
**Target View**: Dependency View — SYS-008 → SYS-001 reads
**Description**: Verifies that `id_validator.py` accepts `HAZ-NNN` as a valid ID pattern alongside all existing V-Model ID prefixes.

* **System Scenario: STS-008-A1**
  * **Given** a `hazard-analysis.md` containing identifiers `HAZ-001`, `HAZ-012`, `HAZ-100`
  * **When** `id_validator.py` processes the file
  * **Then** all three identifiers are recognized as valid IDs with prefix "HAZ" and 3-digit numeric suffixes

* **System Scenario: STS-008-A2**
  * **Given** a document containing malformed identifiers `HAZ-1`, `HAZ-0001`, `HAZ-ABC`
  * **When** `id_validator.py` processes the file
  * **Then** none of the three are recognized as valid `HAZ-NNN` identifiers

---

### Component Verification: SYS-009 (Extension Manifest Update)

**Parent Requirements**: REQ-035, REQ-036, REQ-037

#### Test Case: STP-009-A (Manifest Registration Completeness)

**Technique**: Interface Contract Testing
**Target View**: Decomposition View — Manifest structure
**Description**: Verifies that `extension.yml` correctly registers the new command, ID prefix, and updated trace description.

* **System Scenario: STS-009-A1**
  * **Given** the `extension.yml` manifest file
  * **When** the manifest is parsed for command registrations
  * **Then** the manifest contains an entry for `speckit.v-model.hazard-analysis` with a valid file path and description, the `defaults.id_prefixes` section includes `hazards: "HAZ"`, and the trace command description mentions Matrix H

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total System Components (SYS) | 9 |
| Total Test Cases (STP) | 23 |
| Total Scenarios (STS) | 35 |
| Components with ≥1 STP | 9 / 9 (100%) |
| Test Cases with ≥1 STS | 23 / 23 (100%) |
| **Overall Coverage (SYS→STP)** | **100%** |

### Technique Distribution

| Technique | Test Cases |
|-----------|-----------|
| Interface Contract Testing | 14 |
| Boundary Value Analysis | 4 |
| Equivalence Partitioning | 2 |
| Fault Injection | 3 |

## Uncovered Components

None — full coverage achieved.
