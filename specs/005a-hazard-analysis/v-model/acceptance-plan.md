# Acceptance Test Plan: Hazard Analysis (FMEA)

**Feature Branch**: `005a-hazard-analysis`
**Created**: 2026-03-31
**Status**: Approved
**Source**: `specs/005a-hazard-analysis/v-model/requirements.md`

## Overview

This document defines the Acceptance Test Plan for the Hazard Analysis (FMEA) feature. Every requirement in `requirements.md` has one or more Test Cases (ATP), and every Test Case has one or more executable User Scenarios (SCN) in BDD format (Given/When/Then). The plan covers the hazard-analysis command, validation scripts, Matrix H traceability, progressive deepening, and extension registration.

## ID Schema

- **Test Case**: `ATP-{NNN}-{X}` — where NNN matches the parent REQ, X is a letter suffix (A, B, C...)
- **Scenario**: `SCN-{NNN}-{X}{#}` — nested under the parent ATP, with numeric suffix (1, 2, 3...)
- Example: `SCN-001-A1` → Scenario 1 of Test Case A validating REQ-001

## Acceptance Tests

### Requirement Validation: REQ-001 (Hazard Analysis Command Existence)

#### Test Case: ATP-001-A (Command produces hazard-analysis.md from valid inputs)
**Linked Requirement:** REQ-001
**Description:** Verify the command reads both mandatory inputs and produces the correct output file.
**Validation Condition:** `hazard-analysis.md` exists in the V-Model directory after command execution.
**Expected Result:** File `hazard-analysis.md` is created containing `HAZ-NNN` entries.

* **User Scenario: SCN-001-A1**
  * **Given** a project with `requirements.md` containing 10 `REQ-NNN` entries and `system-design.md` containing 5 `SYS-NNN` components
  * **When** the user runs `/speckit.v-model.hazard-analysis`
  * **Then** a file `hazard-analysis.md` is created in the V-Model directory containing at least one `HAZ-NNN` entry

---

### Requirement Validation: REQ-002 (Unique HAZ-NNN Identifiers)

#### Test Case: ATP-002-A (Sequential zero-padded HAZ IDs)
**Linked Requirement:** REQ-002
**Description:** Verify all hazard IDs follow the `HAZ-NNN` zero-padded sequential format.
**Validation Condition:** Every hazard ID matches `HAZ-[0-9]{3}` and IDs are sequential with no gaps.
**Expected Result:** IDs are `HAZ-001`, `HAZ-002`, ..., `HAZ-N` with no renumbering.

* **User Scenario: SCN-002-A1**
  * **Given** a generated `hazard-analysis.md` with 15 hazard entries
  * **When** extracting all `HAZ-NNN` IDs via regex `HAZ-[0-9]{3}`
  * **Then** the IDs are sequential from `HAZ-001` to `HAZ-015` with no gaps or duplicates

---

### Requirement Validation: REQ-003 (8 Mandatory Fields Per Hazard)

#### Test Case: ATP-003-A (All fields present in each entry)
**Linked Requirement:** REQ-003
**Description:** Verify every hazard entry includes all 8 mandatory fields.
**Validation Condition:** Each `HAZ-NNN` entry contains Failure Mode, Operational State, Effect, Severity, Likelihood, Risk Level, Mitigation (with IDs), and Residual Risk.
**Expected Result:** All 8 fields are present and non-empty in every hazard entry.

* **User Scenario: SCN-003-A1**
  * **Given** a generated `hazard-analysis.md` with 10 hazard entries
  * **When** parsing each entry for the 8 mandatory fields
  * **Then** every entry contains non-empty values for: Failure Mode, Operational State, Effect, Severity, Likelihood, Risk Level, Mitigation, and Residual Risk

#### Test Case: ATP-003-B (Mitigation field contains ID references)
**Linked Requirement:** REQ-003
**Description:** Verify the Mitigation field specifically contains `REQ-NNN` or `SYS-NNN` references.
**Validation Condition:** Mitigation field matches pattern containing at least one `REQ-[0-9]{3}` or `SYS-[0-9]{3}`.
**Expected Result:** Every hazard's mitigation references at least one traceable ID.

* **User Scenario: SCN-003-B1**
  * **Given** a generated `hazard-analysis.md`
  * **When** extracting the Mitigation field from each `HAZ-NNN` entry
  * **Then** every Mitigation field contains at least one `REQ-NNN` or `SYS-NNN` identifier

---

### Requirement Validation: REQ-004 (Operational State Analysis)

#### Test Case: ATP-004-A (Failure modes analyzed across defined states)
**Linked Requirement:** REQ-004
**Description:** Verify the command reads operational states from system-design.md and uses them in hazard entries.
**Validation Condition:** Operational states in hazard entries are a subset of states defined in system-design.md.
**Expected Result:** All operational states referenced in hazards exist in the system design.

* **User Scenario: SCN-004-A1**
  * **Given** a `system-design.md` defining operational states IDLE, ACTIVE, and ERROR
  * **When** `/speckit.v-model.hazard-analysis` generates the hazard register
  * **Then** every Operational State field in hazard entries is one of IDLE, ACTIVE, or ERROR

---

### Requirement Validation: REQ-005 (Separate Entries for Different State-Severity Combinations)

#### Test Case: ATP-005-A (Same failure mode appears with different severities per state)
**Linked Requirement:** REQ-005
**Description:** Verify that a failure mode with different severity across states produces separate HAZ entries.
**Validation Condition:** At least one failure mode appears in multiple entries with different Operational State and Severity values.
**Expected Result:** The hazard register contains multiple entries for the same failure mode on the same component with different severity per state.

* **User Scenario: SCN-005-A1**
  * **Given** a `system-design.md` with component `SYS-001` operating in states IDLE and ACTIVE
  * **When** the hazard analysis identifies a failure mode where severity differs between IDLE (Negligible) and ACTIVE (Critical)
  * **Then** two separate `HAZ-NNN` entries exist: one for IDLE with Severity: Negligible and one for ACTIVE with Severity: Critical, both referencing `SYS-001` and the same Failure Mode

---

### Requirement Validation: REQ-006 (Mitigation Traceability)

#### Test Case: ATP-006-A (Every mitigation references valid IDs)
**Linked Requirement:** REQ-006
**Description:** Verify every hazard mitigation references at least one REQ or SYS ID.
**Validation Condition:** Backward coverage check passes — all referenced IDs exist in source documents.
**Expected Result:** `validate-hazard-coverage.sh` reports 100% backward coverage.

* **User Scenario: SCN-006-A1**
  * **Given** a generated `hazard-analysis.md` where every mitigation references `REQ-NNN` or `SYS-NNN` IDs that exist in `requirements.md` and `system-design.md`
  * **When** `validate-hazard-coverage.sh --json` runs
  * **Then** the output shows `"backward_coverage": "100%"` and `"backward_gaps": []`

---

### Requirement Validation: REQ-007 (Architecture-Level Failure Modes)

#### Test Case: ATP-007-A (ARCH-level hazards generated when architecture exists)
**Linked Requirement:** REQ-007
**Description:** Verify architecture-level failure modes are analyzed when architecture-design.md is present.
**Validation Condition:** Hazard entries include references to `ARCH-NNN` modules and interface-level failure modes.
**Expected Result:** At least one hazard entry references an `ARCH-NNN` module.

* **User Scenario: SCN-007-A1**
  * **Given** a project with `requirements.md`, `system-design.md`, and `architecture-design.md` containing `ARCH-001` (API Gateway) and `ARCH-002` (Data Store)
  * **When** `/speckit.v-model.hazard-analysis` runs
  * **Then** the hazard register includes at least one entry analyzing interface failure modes between `ARCH-001` and `ARCH-002`

#### Test Case: ATP-007-B (No ARCH hazards without architecture-design.md)
**Linked Requirement:** REQ-007
**Description:** Verify no architecture-level failure modes are generated when architecture-design.md is absent.
**Validation Condition:** No `ARCH-NNN` references appear in hazard entries.
**Expected Result:** All hazard entries reference only `SYS-NNN` components.

* **User Scenario: SCN-007-B1**
  * **Given** a project with `requirements.md` and `system-design.md` but no `architecture-design.md`
  * **When** `/speckit.v-model.hazard-analysis` runs
  * **Then** the hazard register contains only SYS-level failure modes with no `ARCH-NNN` references

---

### Requirement Validation: REQ-008 (Progressive Deepening Preserves Existing Entries)

#### Test Case: ATP-008-A (Existing entries unchanged, new entries appended)
**Linked Requirement:** REQ-008
**Description:** Verify progressive deepening appends new entries without modifying existing ones.
**Validation Condition:** First N entries are byte-identical before and after re-run; new entries start from HAZ-{N+1}.
**Expected Result:** All original entries preserved, new entries appended with correct sequential numbering.

* **User Scenario: SCN-008-A1**
  * **Given** an existing `hazard-analysis.md` with entries `HAZ-001` through `HAZ-020`
  * **When** the user adds `architecture-design.md` and re-runs `/speckit.v-model.hazard-analysis`
  * **Then** entries `HAZ-001` through `HAZ-020` remain unmodified and new entries start from `HAZ-021`

---

### Requirement Validation: REQ-009 (General-Purpose FMEA Without Domain Config)

#### Test Case: ATP-009-A (No domain overlay scales without config)
**Linked Requirement:** REQ-009
**Description:** Verify general-purpose FMEA is produced when no `domain` is set in `v-model-config.yml`.
**Validation Condition:** Output contains severity/likelihood ratings using the base general-purpose scale; no domain overlay is loaded.
**Expected Result:** Generic severity scale (e.g., Catastrophic/Critical/Major/Minor/Negligible) used without ASIL, SIL, or DAL annotations.

* **User Scenario: SCN-009-A1**
  * **Given** a project with `requirements.md` and `system-design.md` but no `v-model-config.yml` (or config with no `domain` field)
  * **When** `/speckit.v-model.hazard-analysis` runs
  * **Then** the hazard register uses the base general-purpose severity scale without domain-specific annotations

* **User Scenario: SCN-009-A2**
  * **Given** a project without `domain` configuration
  * **When** `/speckit.v-model.hazard-analysis` runs
  * **Then** operational state analysis is still performed (Operational State column is populated)

---

### Requirement Validation: REQ-010 (Strict Translator Constraint)

#### Test Case: ATP-010-A (No invented components or states)
**Linked Requirement:** REQ-010
**Description:** Verify the AI does not invent system capabilities, components, or operational states not in the source.
**Validation Condition:** All SYS-NNN, REQ-NNN, and operational states in hazard entries exist in the source artifacts.
**Expected Result:** No phantom IDs or undefined states appear in the hazard register.

* **User Scenario: SCN-010-A1**
  * **Given** a `system-design.md` with 5 components (`SYS-001` to `SYS-005`) and states IDLE and ACTIVE
  * **When** `/speckit.v-model.hazard-analysis` generates the hazard register
  * **Then** no hazard entry references a `SYS-NNN` with N > 005, no undefined operational states appear, and all `REQ-NNN` references exist in `requirements.md`

---

### Requirement Validation: REQ-011 (Error When system-design.md Missing)

#### Test Case: ATP-011-A (Clear error message when system-design.md absent)
**Linked Requirement:** REQ-011
**Description:** Verify the command fails with an actionable error when system-design.md is missing.
**Validation Condition:** Command exits with non-zero code and displays the specific error message.
**Expected Result:** Error message: "hazard-analysis requires both requirements.md and system-design.md. Run /speckit.v-model.system-design first."

* **User Scenario: SCN-011-A1**
  * **Given** a project with `requirements.md` but no `system-design.md` in the V-Model directory
  * **When** the user runs `/speckit.v-model.hazard-analysis`
  * **Then** the command fails with the error message "hazard-analysis requires both requirements.md and system-design.md. Run /speckit.v-model.system-design first."

---

### Requirement Validation: REQ-012 (Implicit NORMAL State Fallback)

#### Test Case: ATP-012-A (Uses NORMAL state when none defined)
**Linked Requirement:** REQ-012
**Description:** Verify the command uses implicit NORMAL state when system-design.md has no explicit states.
**Validation Condition:** All hazard entries use "NORMAL" as Operational State and a validation warning is emitted.
**Expected Result:** Operational State column shows "NORMAL" for all entries; warning: "No operational states defined in system-design.md — using implicit NORMAL state."

* **User Scenario: SCN-012-A1**
  * **Given** a `system-design.md` with 5 components but no explicitly defined operational states
  * **When** `/speckit.v-model.hazard-analysis` runs
  * **Then** all hazard entries have Operational State "NORMAL" and the output includes the warning "No operational states defined in system-design.md — using implicit NORMAL state"

---

### Requirement Validation: REQ-013 (Every SYS Has At Least One HAZ)

#### Test Case: ATP-013-A (Full SYS coverage with realistic failure modes)
**Linked Requirement:** REQ-013
**Description:** Verify every SYS-NNN has at least one associated HAZ-NNN entry.
**Validation Condition:** `validate-hazard-coverage.sh` reports 100% forward coverage.
**Expected Result:** Forward coverage is 100% with no gaps.

* **User Scenario: SCN-013-A1**
  * **Given** a `system-design.md` with 8 system components (`SYS-001` to `SYS-008`)
  * **When** `/speckit.v-model.hazard-analysis` generates the hazard register
  * **Then** `validate-hazard-coverage.sh --json` reports `"forward_coverage": "100%"` and `"forward_gaps": []`

#### Test Case: ATP-013-B (Fallback for components with no plausible failure)
**Linked Requirement:** REQ-013
**Description:** Verify a "No identified failure mode" entry is generated when no realistic failure mode exists.
**Validation Condition:** A fallback entry exists with Severity: Negligible and a human-review flag.
**Expected Result:** Entry contains "No identified failure mode", Severity: Negligible, and a note flagging it for human review.

* **User Scenario: SCN-013-B1**
  * **Given** a `system-design.md` containing a trivially simple component (e.g., a static constants module)
  * **When** `/speckit.v-model.hazard-analysis` generates the hazard register
  * **Then** the component has at least one `HAZ-NNN` entry, even if it contains "No identified failure mode" with Severity: Negligible

---

### Requirement Validation: REQ-014 (No-Op Progressive Deepening)

#### Test Case: ATP-014-A (No new entries when no new hazards found)
**Linked Requirement:** REQ-014
**Description:** Verify progressive deepening adds nothing when no new architecture-level hazards are identified.
**Validation Condition:** File size and entry count are unchanged after re-run; a note is added.
**Expected Result:** Note: "No additional architecture-level hazards identified." No new HAZ-NNN entries appended.

* **User Scenario: SCN-014-A1**
  * **Given** an existing `hazard-analysis.md` with 15 entries and an `architecture-design.md` whose failure modes are already covered by SYS-level analysis
  * **When** the user re-runs `/speckit.v-model.hazard-analysis`
  * **Then** the hazard register still contains exactly 15 entries and includes the note "No additional architecture-level hazards identified"

---

### Requirement Validation: REQ-015 (Large Hazard Registers Without Batching)

#### Test Case: ATP-015-A (50+ hazards generated without batching)
**Linked Requirement:** REQ-015
**Description:** Verify the command handles large hazard registers without requiring batching.
**Validation Condition:** A project with many components produces 50+ hazards in a single generation pass.
**Expected Result:** All hazards generated correctly with valid IDs and complete fields.

* **User Scenario: SCN-015-A1**
  * **Given** a `system-design.md` with 15 components and 4 operational states
  * **When** `/speckit.v-model.hazard-analysis` runs
  * **Then** the hazard register contains 50+ entries with sequential `HAZ-NNN` IDs and all mandatory fields populated

---

### Requirement Validation: REQ-016 (First-Run Creates From HAZ-001)

#### Test Case: ATP-016-A (New file starts at HAZ-001)
**Linked Requirement:** REQ-016
**Description:** Verify first-run behavior creates hazard register starting from HAZ-001.
**Validation Condition:** No pre-existing `hazard-analysis.md`; output starts with `HAZ-001`.
**Expected Result:** First entry is `HAZ-001`, numbering is sequential.

* **User Scenario: SCN-016-A1**
  * **Given** a project with `requirements.md` and `system-design.md` but no existing `hazard-analysis.md`
  * **When** `/speckit.v-model.hazard-analysis` runs for the first time
  * **Then** the generated file starts with `HAZ-001` and entries are sequentially numbered

---

### Requirement Validation: REQ-017 (Template Existence and Structure)

#### Test Case: ATP-017-A (Template file exists with required sections)
**Linked Requirement:** REQ-017
**Description:** Verify `hazard-analysis-template.md` exists in `templates/` with all required sections.
**Validation Condition:** File exists and contains sections: Summary, Risk Matrix Definition, Hazard Register, Operational States Reference.
**Expected Result:** All four sections are present in the template.

* **User Scenario: SCN-017-A1**
  * **Given** the extension's `templates/` directory
  * **When** reading `hazard-analysis-template.md`
  * **Then** the file contains sections for Summary, Risk Matrix Definition, Hazard Register (FMEA table), and Operational States Reference

---

### Requirement Validation: REQ-018 (FMEA Table Columns)

#### Test Case: ATP-018-A (All required columns present in FMEA table)
**Linked Requirement:** REQ-018
**Description:** Verify the template's FMEA table includes all 10 required columns.
**Validation Condition:** Table header row contains all specified column names.
**Expected Result:** Columns: HAZ ID, Component, Failure Mode, Operational State, Effect, Severity, Likelihood, Risk Level, Mitigation, Residual Risk.

* **User Scenario: SCN-018-A1**
  * **Given** a generated `hazard-analysis.md`
  * **When** parsing the FMEA table header
  * **Then** the header row contains all 10 columns: HAZ ID, Component (SYS-NNN), Failure Mode, Operational State, Effect, Severity, Likelihood, Risk Level, Mitigation (REQ/SYS refs), Residual Risk

---

### Requirement Validation: REQ-019 (Forward Coverage Validation)

#### Test Case: ATP-019-A (All SYS covered — script exits 0)
**Linked Requirement:** REQ-019
**Description:** Verify forward coverage validation passes when all SYS-NNN have hazards.
**Validation Condition:** Script exits with code 0 when every SYS-NNN maps to at least one HAZ-NNN.
**Expected Result:** Exit code 0, `"forward_coverage": "100%"`.

* **User Scenario: SCN-019-A1**
  * **Given** a `system-design.md` with 5 components and a `hazard-analysis.md` with at least one hazard per component
  * **When** `validate-hazard-coverage.sh` runs
  * **Then** the script exits with code 0

#### Test Case: ATP-019-B (Missing SYS — script exits 1)
**Linked Requirement:** REQ-019
**Description:** Verify forward coverage validation fails when a SYS-NNN has no hazard.
**Validation Condition:** Script exits with code 1 and reports the specific uncovered SYS-NNN.
**Expected Result:** Exit code 1, gap report lists the uncovered component.

* **User Scenario: SCN-019-B1**
  * **Given** a `system-design.md` with 8 components and a `hazard-analysis.md` covering only 7 of them (missing `SYS-004`)
  * **When** `validate-hazard-coverage.sh` runs
  * **Then** the script exits with code 1 and the output includes "SYS-004: no hazard analysis mapping found"

---

### Requirement Validation: REQ-020 (Backward Coverage Validation)

#### Test Case: ATP-020-A (All mitigations reference valid IDs)
**Linked Requirement:** REQ-020
**Description:** Verify backward coverage passes when all mitigation references are valid.
**Validation Condition:** Script reports 100% backward coverage with no gaps.
**Expected Result:** `"backward_coverage": "100%"`, `"backward_gaps": []`.

* **User Scenario: SCN-020-A1**
  * **Given** a `hazard-analysis.md` where every mitigation references `REQ-NNN` or `SYS-NNN` IDs that exist in the source documents
  * **When** `validate-hazard-coverage.sh --json` runs
  * **Then** the output contains `"backward_coverage": "100%"` and `"backward_gaps": []`

#### Test Case: ATP-020-B (Mitigation references non-existent ID)
**Linked Requirement:** REQ-020
**Description:** Verify backward coverage fails when a mitigation references a phantom ID.
**Validation Condition:** Script exits 1 and lists the invalid reference.
**Expected Result:** Gap report: "HAZ-007 references REQ-XYZ which does not exist."

* **User Scenario: SCN-020-B1**
  * **Given** a `hazard-analysis.md` where `HAZ-007`'s mitigation references `REQ-XYZ` which does not exist in `requirements.md`
  * **When** `validate-hazard-coverage.sh` runs
  * **Then** the script exits with code 1 and reports `HAZ-007` as a backward coverage gap referencing a non-existent ID

---

### Requirement Validation: REQ-021 (Operational State Consistency)

#### Test Case: ATP-021-A (All states match system-design.md)
**Linked Requirement:** REQ-021
**Description:** Verify operational state consistency passes when all states are defined.
**Validation Condition:** `"state_consistency": true` in JSON output.
**Expected Result:** No state warnings emitted.

* **User Scenario: SCN-021-A1**
  * **Given** a `system-design.md` defining states IDLE, ACTIVE, ERROR and a `hazard-analysis.md` using only those states
  * **When** `validate-hazard-coverage.sh --json` runs
  * **Then** the output contains `"state_consistency": true` and `"state_warnings": []`

#### Test Case: ATP-021-B (Unknown state detected)
**Linked Requirement:** REQ-021
**Description:** Verify the script detects hazard entries referencing undefined operational states.
**Validation Condition:** Warning emitted for each unknown state.
**Expected Result:** `"state_warnings": ["Unknown operational state: CRUISE"]`.

* **User Scenario: SCN-021-B1**
  * **Given** a `system-design.md` defining states IDLE, ACTIVE, ERROR and a `hazard-analysis.md` with one entry referencing "CRUISE"
  * **When** `validate-hazard-coverage.sh --json` runs
  * **Then** the output contains `"state_warnings"` listing "Unknown operational state: CRUISE"

---

### Requirement Validation: REQ-022 (JSON Output Flag)

#### Test Case: ATP-022-A (--json produces valid JSON)
**Linked Requirement:** REQ-022
**Description:** Verify the `--json` flag produces machine-readable JSON with all required fields.
**Validation Condition:** Output is valid JSON containing has_gaps, forward_coverage, backward_coverage, state_consistency, and gap lists.
**Expected Result:** JSON output parseable by `jq` with all specified fields present.

* **User Scenario: SCN-022-A1**
  * **Given** a valid hazard register and coverage artifacts
  * **When** `validate-hazard-coverage.sh --json` runs
  * **Then** the output is valid JSON containing keys: `has_gaps`, `forward_coverage`, `backward_coverage`, `state_consistency`, `forward_gaps`, `backward_gaps`, `state_warnings`

---

### Requirement Validation: REQ-023 (Partial Validation Flag)

#### Test Case: ATP-023-A (--partial validates available checks only)
**Linked Requirement:** REQ-023
**Description:** Verify the `--partial` flag validates only the checks possible with available artifacts.
**Validation Condition:** Script runs without error when only some artifacts exist.
**Expected Result:** Exit code 0 if available checks pass; skipped checks noted in output.

* **User Scenario: SCN-023-A1**
  * **Given** a `system-design.md` and `hazard-analysis.md` but no `requirements.md`
  * **When** `validate-hazard-coverage.sh --partial --json` runs
  * **Then** forward coverage is validated, backward coverage check is skipped with a note, and the script exits with code 0 if forward coverage passes

---

### Requirement Validation: REQ-024 (Exit Codes)

#### Test Case: ATP-024-A (Exit 0 on full coverage)
**Linked Requirement:** REQ-024
**Description:** Verify exit code 0 when all checks pass.
**Validation Condition:** Script returns exactly exit code 0.
**Expected Result:** Exit code is 0.

* **User Scenario: SCN-024-A1**
  * **Given** a complete hazard register with 100% forward coverage, 100% backward coverage, and consistent operational states
  * **When** `validate-hazard-coverage.sh` runs
  * **Then** the script exits with code 0

#### Test Case: ATP-024-B (Exit 1 on any gap)
**Linked Requirement:** REQ-024
**Description:** Verify exit code 1 when any gap is detected.
**Validation Condition:** Script returns exactly exit code 1.
**Expected Result:** Exit code is 1.

* **User Scenario: SCN-024-B1**
  * **Given** a hazard register with one uncovered `SYS-NNN` component
  * **When** `validate-hazard-coverage.sh` runs
  * **Then** the script exits with code 1

---

### Requirement Validation: REQ-025 (Human-Readable Gap Reports)

#### Test Case: ATP-025-A (Gap reports list specific IDs)
**Linked Requirement:** REQ-025
**Description:** Verify gap reports list each specific gap by ID for CI log inspection.
**Validation Condition:** Output contains specific gap descriptions with IDs.
**Expected Result:** Gap report includes messages like "SYS-003: no hazard analysis mapping found."

* **User Scenario: SCN-025-A1**
  * **Given** a hazard register missing coverage for `SYS-003` and with `HAZ-007` referencing non-existent `REQ-XYZ`
  * **When** `validate-hazard-coverage.sh` runs (without `--json`)
  * **Then** the human-readable output includes "SYS-003: no hazard analysis mapping found" and "HAZ-007 references REQ-XYZ which does not exist"

---

### Requirement Validation: REQ-026 (PowerShell Validation Script)

#### Test Case: ATP-026-A (PS1 produces identical output to Bash)
**Linked Requirement:** REQ-026
**Description:** Verify PowerShell script produces identical JSON structure and exit codes as Bash.
**Validation Condition:** JSON output and exit codes are identical for the same input.
**Expected Result:** Both scripts produce structurally identical JSON and the same exit code.

* **User Scenario: SCN-026-A1**
  * **Given** a complete hazard register as input to both scripts
  * **When** `validate-hazard-coverage.sh --json` and `Validate-HazardCoverage.ps1 -Json` both run on the same input
  * **Then** both produce JSON with identical field names, field values, and the same exit code

* **User Scenario: SCN-026-A2**
  * **Given** a hazard register with a forward coverage gap
  * **When** both scripts run on the same input
  * **Then** both exit with code 1 and both report the same gap ID

---

### Requirement Validation: REQ-027 (Build-Matrix Parses HAZ-NNN)

#### Test Case: ATP-027-A (HAZ IDs and mitigation refs extracted)
**Linked Requirement:** REQ-027
**Description:** Verify build-matrix.sh parses HAZ-NNN IDs and their mitigation references from hazard-analysis.md.
**Validation Condition:** Matrix H output includes all HAZ-NNN entries with correct mitigation links.
**Expected Result:** Every HAZ-NNN in hazard-analysis.md appears in Matrix H with its mitigation references.

* **User Scenario: SCN-027-A1**
  * **Given** a `hazard-analysis.md` with 10 hazard entries and mitigations referencing various `REQ-NNN` and `SYS-NNN` IDs
  * **When** the `build-matrix.sh` script processes the hazard register
  * **Then** all 10 `HAZ-NNN` entries appear in Matrix H with their correct mitigation references

---

### Requirement Validation: REQ-028 (Matrix H Structure)

#### Test Case: ATP-028-A (Matrix H shows HAZ → Mitigation → Verification chain)
**Linked Requirement:** REQ-028
**Description:** Verify Matrix H shows the complete chain from hazard to verification.
**Validation Condition:** Each row shows HAZ-NNN → REQ/SYS → ATP/STP.
**Expected Result:** Matrix H rows contain hazard, mitigation, and verification columns.

* **User Scenario: SCN-028-A1**
  * **Given** `HAZ-003` mitigated by `REQ-012` and `REQ-012` has `ATP-012-A` as its acceptance test
  * **When** the trace command builds Matrix H
  * **Then** Matrix H contains a row showing `HAZ-003` → `REQ-012` → `ATP-012-A`

---

### Requirement Validation: REQ-029 (Gap Highlighting in Matrix H)

#### Test Case: ATP-029-A (Untested mitigation shows warning)
**Linked Requirement:** REQ-029
**Description:** Verify Matrix H highlights mitigations without test coverage.
**Validation Condition:** Verification column shows `⚠️ No test coverage` for untested mitigations.
**Expected Result:** Gap marker visible in the Verification column.

* **User Scenario: SCN-029-A1**
  * **Given** `HAZ-007` mitigated by `SYS-005` but no test case covers `SYS-005`
  * **When** the trace command builds Matrix H
  * **Then** the Verification column for `HAZ-007` shows `⚠️ No test coverage`

---

### Requirement Validation: REQ-030 (PowerShell Build-Matrix Parity)

#### Test Case: ATP-030-A (PS1 Matrix H matches Bash)
**Linked Requirement:** REQ-030
**Description:** Verify build-matrix.ps1 produces identical Matrix H output as build-matrix.sh.
**Validation Condition:** Matrix H content is structurally identical from both scripts.
**Expected Result:** Same hazard entries, mitigation links, and verification chains in both outputs.

* **User Scenario: SCN-030-A1**
  * **Given** the same set of V-Model artifacts as input
  * **When** `build-matrix.sh` and `build-matrix.ps1` both generate Matrix H
  * **Then** both Matrix H outputs contain the same rows, columns, and values

---

### Requirement Validation: REQ-031 (Trace Command Includes Matrix H)

#### Test Case: ATP-031-A (Trace output includes Matrix H when hazard-analysis.md exists)
**Linked Requirement:** REQ-031
**Description:** Verify the trace command definition is updated to include Matrix H.
**Validation Condition:** Running `/speckit.v-model.trace` with hazard-analysis.md present produces Matrix H.
**Expected Result:** Traceability matrix output includes a "Matrix H — Hazard Traceability" section.

* **User Scenario: SCN-031-A1**
  * **Given** a project with all V-Model artifacts including `hazard-analysis.md`
  * **When** the user runs `/speckit.v-model.trace`
  * **Then** the traceability matrix includes a "Matrix H — Hazard Traceability" section alongside Matrices A–D

---

### Requirement Validation: REQ-032 (HAZ-NNN Regex Pattern)

#### Test Case: ATP-032-A (HAZ IDs match regex HAZ-[0-9]{3})
**Linked Requirement:** REQ-032
**Description:** Verify all HAZ IDs match the defined regex pattern.
**Validation Condition:** Every ID extracted by `HAZ-[0-9]{3}` is a valid 3-digit zero-padded identifier.
**Expected Result:** All IDs match (e.g., `HAZ-001`, `HAZ-042`, not `HAZ-1` or `HAZ-0001`).

* **User Scenario: SCN-032-A1**
  * **Given** a generated `hazard-analysis.md`
  * **When** extracting all identifiers matching `HAZ-[0-9]{3}`
  * **Then** every hazard entry's ID matches the pattern and no malformed IDs exist

---

### Requirement Validation: REQ-033 (ID Validator Updated)

#### Test Case: ATP-033-A (id_validator.py recognizes HAZ-NNN)
**Linked Requirement:** REQ-033
**Description:** Verify the Python ID validator accepts HAZ-NNN as valid.
**Validation Condition:** `id_validator.py` returns valid for `HAZ-001`, `HAZ-999`, etc.
**Expected Result:** HAZ-NNN IDs pass validation alongside existing ID types.

* **User Scenario: SCN-033-A1**
  * **Given** the updated `id_validator.py` containing the HAZ prefix pattern
  * **When** validating `HAZ-001`, `HAZ-042`, and `HAZ-999`
  * **Then** all three are recognized as valid ID patterns

---

### Requirement Validation: REQ-034 (Sequential HAZ IDs)

#### Test Case: ATP-034-A (IDs sequential in initial generation)
**Linked Requirement:** REQ-034
**Description:** Verify HAZ IDs are sequential with no gaps in initial generation.
**Validation Condition:** IDs form an unbroken sequence from HAZ-001 to HAZ-N.
**Expected Result:** No gaps in initial numbering.

* **User Scenario: SCN-034-A1**
  * **Given** a first-time hazard generation producing 20 entries
  * **When** extracting all HAZ-NNN IDs and sorting numerically
  * **Then** the sequence is `HAZ-001` through `HAZ-020` with no gaps

---

### Requirement Validation: REQ-035 (Extension Registration)

#### Test Case: ATP-035-A (Command registered in extension.yml)
**Linked Requirement:** REQ-035
**Description:** Verify speckit.v-model.hazard-analysis is registered in extension.yml.
**Validation Condition:** `extension.yml` contains a command entry with name, file path, and description.
**Expected Result:** The `provides.commands` section includes the hazard-analysis command.

* **User Scenario: SCN-035-A1**
  * **Given** the `extension.yml` file
  * **When** parsing the `provides.commands` section
  * **Then** an entry exists with `name: "speckit.v-model.hazard-analysis"`, a `file` pointing to `commands/hazard-analysis.md`, and a non-empty `description`

---

### Requirement Validation: REQ-036 (HAZ in ID Prefixes)

#### Test Case: ATP-036-A (defaults.id_prefixes includes hazards)
**Linked Requirement:** REQ-036
**Description:** Verify extension.yml defaults include the HAZ prefix.
**Validation Condition:** `defaults.id_prefixes.hazards` equals `"HAZ"`.
**Expected Result:** The `id_prefixes` section contains `hazards: "HAZ"`.

* **User Scenario: SCN-036-A1**
  * **Given** the `extension.yml` file
  * **When** parsing the `defaults.id_prefixes` section
  * **Then** the key `hazards` exists with value `"HAZ"`

---

### Requirement Validation: REQ-037 (Trace Description Update)

#### Test Case: ATP-037-A (Trace command description mentions Matrix H)
**Linked Requirement:** REQ-037
**Description:** Verify the trace command description in extension.yml mentions Matrix H.
**Validation Condition:** The trace command's description string includes "Matrix H" or "Hazard".
**Expected Result:** Description updated to mention Matrix H alongside A–D.

* **User Scenario: SCN-037-A1**
  * **Given** the `extension.yml` file
  * **When** reading the `speckit.v-model.trace` command description
  * **Then** the description mentions Matrix H or hazard traceability

---

### Requirement Validation: REQ-NF-001 (Regex-Based Parsing)

#### Test Case: ATP-NF-001-A (Script uses regex, no external tools)
**Linked Requirement:** REQ-NF-001
**Description:** Verify the validation script uses only regex-based parsing with standard Bash utilities.
**Validation Condition:** Script source contains only grep/sed/awk calls; no database or external tool invocations.
**Expected Result:** Script is self-contained and portable.

* **User Scenario: SCN-NF-001-A1**
  * **Given** the `validate-hazard-coverage.sh` source code
  * **When** inspecting the script for external dependencies
  * **Then** the script uses only standard Bash utilities (grep, sed, awk, etc.) with no runtime database or external tooling dependencies

---

### Requirement Validation: REQ-NF-002 (Deterministic Structural Reproducibility)

#### Test Case: ATP-NF-002-A (Validation passes on every valid generation)
**Linked Requirement:** REQ-NF-002
**Description:** Verify that structurally valid output is produced on every run, even if AI prose varies.
**Validation Condition:** `validate-hazard-coverage.sh` exits 0 on multiple independent generations from the same inputs.
**Expected Result:** All generations pass structural validation.

* **User Scenario: SCN-NF-002-A1**
  * **Given** a fixed set of `requirements.md` and `system-design.md` inputs
  * **When** `/speckit.v-model.hazard-analysis` is run 3 times independently
  * **Then** `validate-hazard-coverage.sh` exits 0 on all 3 generated outputs

---

### Requirement Validation: REQ-NF-003 (Validation Performance)

#### Test Case: ATP-NF-003-A (Script completes within 5 seconds for 100 entries)
**Linked Requirement:** REQ-NF-003
**Description:** Verify the script completes validation within the performance target.
**Validation Condition:** Wall-clock time < 5 seconds for a 100-entry hazard register.
**Expected Result:** Script exits within 5 seconds.

* **User Scenario: SCN-NF-003-A1**
  * **Given** a `hazard-analysis.md` with 100 hazard entries and corresponding `system-design.md` and `requirements.md`
  * **When** `validate-hazard-coverage.sh` runs
  * **Then** the script completes within 5 seconds of wall-clock time

---

### Requirement Validation: REQ-IF-001 (Script Argument Convention)

#### Test Case: ATP-IF-001-A (Accepts V-Model directory as positional argument)
**Linked Requirement:** REQ-IF-001
**Description:** Verify the script accepts the V-Model directory path as its first positional argument.
**Validation Condition:** Script finds hazard-analysis.md, system-design.md, and requirements.md relative to the given directory.
**Expected Result:** Script locates all required files within the specified directory.

* **User Scenario: SCN-IF-001-A1**
  * **Given** a V-Model directory at `specs/005a-hazard-analysis/v-model/` containing the required files
  * **When** `validate-hazard-coverage.sh specs/005a-hazard-analysis/v-model/` runs
  * **Then** the script locates `hazard-analysis.md`, `system-design.md`, and `requirements.md` within that directory

---

### Requirement Validation: REQ-IF-002 (JSON Output Schema)

#### Test Case: ATP-IF-002-A (JSON matches defined schema)
**Linked Requirement:** REQ-IF-002
**Description:** Verify the JSON output matches the specified schema.
**Validation Condition:** Output contains all specified fields with correct types.
**Expected Result:** JSON contains: has_gaps (bool), forward_coverage (string), backward_coverage (string), state_consistency (bool), forward_gaps (array), backward_gaps (array), state_warnings (array).

* **User Scenario: SCN-IF-002-A1**
  * **Given** a complete hazard register with no gaps
  * **When** `validate-hazard-coverage.sh --json` runs
  * **Then** the output is `{"has_gaps": false, "forward_coverage": "100%", "backward_coverage": "100%", "state_consistency": true, "forward_gaps": [], "backward_gaps": [], "state_warnings": []}`

---

### Requirement Validation: REQ-IF-003 (Machine-Parseable Markdown)

#### Test Case: ATP-IF-003-A (Build-matrix script regex extracts HAZ IDs)
**Linked Requirement:** REQ-IF-003
**Description:** Verify the hazard-analysis.md format is parseable by build-matrix.sh regex patterns.
**Validation Condition:** Regex extraction of HAZ-NNN IDs and mitigation references succeeds.
**Expected Result:** All HAZ-NNN and their mitigation links are extracted correctly.

* **User Scenario: SCN-IF-003-A1**
  * **Given** a generated `hazard-analysis.md` following the template structure
  * **When** the `build-matrix.sh` script applies its regex patterns
  * **Then** all `HAZ-NNN` IDs and their mitigation `REQ-NNN`/`SYS-NNN` references are correctly extracted

---

### Requirement Validation: REQ-CN-001 (Domain Config Gating) — [SUSPECT — Parent REQ-CN-001 deprecated]

#### Test Case: ATP-CN-001-A [DEPRECATED — Superseded by ATP-038-A]
**Linked Requirement:** REQ-CN-001 [DEPRECATED — Superseded by REQ-038]
**Description:** ~~Verify domain-specific severity scales require v-model-config.yml configuration.~~ Superseded by ATP-038-A which tests overlay-based domain loading.
**Validation Condition:** ~~ASIL/SIL/DO-178C scales appear only when safety_critical config is present.~~
**Expected Result:** ~~Without config: generic severity. With config: domain-specific scales.~~

* **User Scenario: SCN-CN-001-A1** [DEPRECATED — Superseded by SCN-038-A1]
  * ~~**Given** a project without `v-model-config.yml`~~
  * ~~**When** `/speckit.v-model.hazard-analysis` runs~~
  * ~~**Then** the hazard register uses a generic severity scale (Catastrophic/Critical/Major/Minor/Negligible) without ASIL or SIL annotations~~

* **User Scenario: SCN-CN-001-A2** [DEPRECATED — Superseded by SCN-038-A2]
  * ~~**Given** a project with `v-model-config.yml` containing `safety_critical: { domain: "iso-26262" }`~~
  * ~~**When** `/speckit.v-model.hazard-analysis` runs~~
  * ~~**Then** the hazard register includes ASIL ratings (ASIL-QM through ASIL-D) in the severity classification~~

---

### Requirement Validation: REQ-CN-002 (Matrix H Naming)

#### Test Case: ATP-CN-002-A (Matrix uses letter H, not E)
**Linked Requirement:** REQ-CN-002
**Description:** Verify Matrix H is a separate matrix using the letter "H" (Hazard mnemonic).
**Validation Condition:** Traceability matrix section header uses "Matrix H" not "Matrix E".
**Expected Result:** Section title: "Matrix H — Hazard Traceability".

* **User Scenario: SCN-CN-002-A1**
  * **Given** a project with hazard-analysis.md
  * **When** `/speckit.v-model.trace` generates the traceability matrix
  * **Then** the new matrix section is titled "Matrix H — Hazard Traceability" (not "Matrix E")

---

### Requirement Validation: REQ-CN-003 (Backward Compatibility)

#### Test Case: ATP-CN-003-A (No Matrix H without hazard-analysis.md)
**Linked Requirement:** REQ-CN-003
**Description:** Verify existing projects without hazard analysis are unaffected.
**Validation Condition:** Trace output is identical to v0.4.0 (Matrices A–D only) when no hazard-analysis.md exists.
**Expected Result:** No Matrix H, no warning, no error — identical v0.4.0 output.

* **User Scenario: SCN-CN-003-A1**
  * **Given** a project with all V-Model artifacts except `hazard-analysis.md`
  * **When** `/speckit.v-model.trace` runs
  * **Then** the output contains only Matrices A–D with no mention of Matrix H and no warning

---

### Requirement Validation: REQ-CN-004 (Cross-Platform Script Parity)

#### Test Case: ATP-CN-004-A (Bash and PS1 produce identical results)
**Linked Requirement:** REQ-CN-004
**Description:** Verify cross-platform parity between Bash and PowerShell scripts.
**Validation Condition:** Identical JSON output and exit codes from both scripts on the same input.
**Expected Result:** Field-by-field JSON comparison shows identical values.

* **User Scenario: SCN-CN-004-A1**
  * **Given** the same hazard register fixtures
  * **When** both `validate-hazard-coverage.sh --json` and `Validate-HazardCoverage.ps1 -Json` run
  * **Then** both produce JSON with identical `has_gaps`, `forward_coverage`, `backward_coverage`, `state_consistency`, gap lists, and the same exit code

---

### Requirement Validation: REQ-038 (Domain Overlay Loading)

#### Test Case: ATP-038-A (Overlay loaded when domain is set)
**Linked Requirement:** REQ-038
**Description:** Verify the command loads the domain overlay and uses its severity scale when `v-model-config.yml` specifies a `domain` value.
**Validation Condition:** Domain overlay file is read and its severity scale appears in the hazard register output.
**Expected Result:** Domain-specific severity scale (e.g., ASIL for iso_26262) is used instead of the base general-purpose scale.

* **User Scenario: SCN-038-A1**
  * **Given** a project with `v-model-config.yml` containing `domain: iso_26262` and an overlay file at `commands/overlays/iso_26262/hazard-analysis.md`
  * **When** `/speckit.v-model.hazard-analysis` runs
  * **Then** the hazard register uses the ASIL severity scale (S0–S3, QM–D) from the overlay instead of the base general-purpose scale

* **User Scenario: SCN-038-A2**
  * **Given** a project with `v-model-config.yml` containing `domain: do_178c` and an overlay file at `commands/overlays/do_178c/hazard-analysis.md`
  * **When** `/speckit.v-model.hazard-analysis` runs
  * **Then** the hazard register uses DAL failure condition classification (A–E) from the overlay

#### Test Case: ATP-038-B (Graceful fallback when overlay missing)
**Linked Requirement:** REQ-038
**Description:** Verify the command falls back to base severity scale when a domain is set but no overlay file exists for that domain.
**Validation Condition:** Command does not error; base general-purpose scale is used.
**Expected Result:** Hazard register produced with generic severity scale and no error.

* **User Scenario: SCN-038-B1**
  * **Given** a project with `v-model-config.yml` containing `domain: custom_domain` but no overlay at `commands/overlays/custom_domain/hazard-analysis.md`
  * **When** `/speckit.v-model.hazard-analysis` runs
  * **Then** the command proceeds with the base general-purpose severity scale without error

---

### Requirement Validation: REQ-039 (Generic FMEA Framing)

#### Test Case: ATP-039-A (Command text uses generic framing)
**Linked Requirement:** REQ-039
**Description:** Verify the command description and goal use generic FMEA framing without referencing specific safety standards.
**Validation Condition:** The command file `commands/hazard-analysis.md` description and goal do not contain "ISO 14971", "ISO 26262", or "DO-178C".
**Expected Result:** Description and goal reference "Failure Mode and Effects Analysis" or equivalent generic terminology.

* **User Scenario: SCN-039-A1**
  * **Given** the command file `commands/hazard-analysis.md`
  * **When** inspecting the `description` field and Goal section
  * **Then** neither contain the strings "ISO 14971", "ISO 26262", or "DO-178C"

* **User Scenario: SCN-039-A2**
  * **Given** the iso_26262 overlay at `commands/overlays/iso_26262/hazard-analysis.md`
  * **When** inspecting the overlay content
  * **Then** the overlay contains domain-specific references to HARA methodology and ASIL ratings per ISO 26262 Part 3

---

### Requirement Validation: REQ-040 (IEC 62304 Domain Overlay)

#### Test Case: ATP-040-A (IEC 62304 overlay provides Safety Class scale)
**Linked Requirement:** REQ-040
**Description:** Verify the IEC 62304 overlay exists and provides a Safety Class A/B/C severity scale with ISO 14971 integration guidance.
**Validation Condition:** Overlay file exists at `commands/overlays/iec_62304/hazard-analysis.md` with the expected content.
**Expected Result:** Overlay contains Safety Class A, B, C definitions and references ISO 14971 integration.

* **User Scenario: SCN-040-A1**
  * **Given** the overlay file `commands/overlays/iec_62304/hazard-analysis.md`
  * **When** inspecting its contents
  * **Then** the file defines Safety Class A (no injury possible), Safety Class B (non-serious injury possible), and Safety Class C (death or serious injury possible)

* **User Scenario: SCN-040-A2**
  * **Given** the overlay file `commands/overlays/iec_62304/hazard-analysis.md`
  * **When** inspecting its ISO 14971 integration section
  * **Then** the file references ISO 14971 §5.4–§7 for hazard identification and risk estimation methodology

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Requirements (REQ) | 50 (1 deprecated) |
| Total Test Cases (ATP) | 58 (1 deprecated) |
| Total Scenarios (SCN) | 64 (2 deprecated) |
| REQ → ATP Coverage | 100% |
| ATP → SCN Coverage | 100% |

**Validation Status**: ✅ Full Coverage (deprecated items excluded from active counts)
**Generated**: 2026-03-31
**Last Evolved**: 2026-04-19
**Validated by**: `/speckit.v-model.acceptance` command execution (pending `validate-requirement-coverage.sh` confirmation)
