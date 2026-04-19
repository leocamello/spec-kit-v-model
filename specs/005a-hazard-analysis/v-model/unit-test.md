# Unit Test Plan: Hazard Analysis (FMEA)

**Feature Branch**: `005a-hazard-analysis`
**Created**: 2026-04-01
**Status**: Approved
**Source**: `specs/005a-hazard-analysis/v-model/module-design.md`

## Overview

This document defines the Unit Test Plan for the Hazard Analysis (FMEA) command. Every module design (`MOD-NNN`) in `module-design.md` has one or more Test Cases (`UTP-NNN-X`), and every Test Case has one or more executable Unit Scenarios (`UTS-NNN-X#`) in white-box Arrange/Act/Assert format. Unit tests verify **internal module logic** — control flow, data transformations, and variable boundaries. All 18 modules are standard (no `[EXTERNAL]` bypasses).

## ID Schema

- **Unit Test Case**: `UTP-{NNN}-{X}` — where NNN matches the parent MOD, X is a letter suffix (A, B, C...)
- **Unit Test Scenario**: `UTS-{NNN}-{X}{#}` — nested under the parent UTP, with numeric suffix (1, 2, 3...)
- ID lineage: from `UTS-006-B1`, extract `UTP-006-B` → `MOD-006`. Consult "Parent Architecture Modules" in `module-design.md` for `ARCH-NNN` ancestor.

## ISO 29119-4 White-Box Techniques

| Technique | Source View | What It Tests |
|-----------|------------|---------------|
| **Statement & Branch Coverage** | Algorithmic/Logic View | Every line and every True/False branch outcome |
| **Boundary Value Analysis** | Internal Data Structures | Scalar variable boundaries: min-1, min, mid, max, max+1 |
| **Equivalence Partitioning** | Internal Data Structures | Discrete non-scalar types: Booleans, Enums |
| **Strict Isolation** | Architecture Interface View | Every external dependency mocked/stubbed |

## Unit Tests

### Module: MOD-001 (Input Validation and Prerequisites)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `commands/hazard-analysis.md`

#### Test Case: UTP-001-A (Prerequisite File Existence Branches)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies all branches of the validate_prerequisites function — requirements.md present/absent, system-design.md present/absent, optional files present/absent.

**Dependency & Mock Registry:**

None — module is self-contained (reads filesystem)

* **Unit Scenario: UTS-001-A1**
  * **Arrange**: Set `requirements_path` to a valid file, `system_design_path` to a valid file, `arch_design_path` to a valid file, `config_path` with `domain: iso_26262`
  * **Act**: Call `validate_prerequisites(vmodel_dir)`
  * **Assert**: Returns `ValidationResult` with all paths populated and `domain = "iso_26262"`

* **Unit Scenario: UTS-001-A2**
  * **Arrange**: Set `requirements_path` to non-existent path
  * **Act**: Call `validate_prerequisites(vmodel_dir)`
  * **Assert**: Returns Error with message containing "hazard-analysis requires both requirements.md and system-design.md"

* **Unit Scenario: UTS-001-A3**
  * **Arrange**: Set `requirements_path` valid, `system_design_path` to non-existent path
  * **Act**: Call `validate_prerequisites(vmodel_dir)`
  * **Assert**: Returns Error with same message as UTS-001-A2

#### Test Case: UTP-001-B (Domain Configuration Partitions)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Verifies the domain enum partitions: iso_26262, do_178c, iec_62304, NULL (no config).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-001-B1**
  * **Arrange**: Set `config_path` to file with `domain: do_178c`
  * **Act**: Call `validate_prerequisites(vmodel_dir)`
  * **Assert**: Returns `domain = "do_178c"`

* **Unit Scenario: UTS-001-B2**
  * **Arrange**: Set `config_path` to non-existent (no v-model-config.yml)
  * **Act**: Call `validate_prerequisites(vmodel_dir)`
  * **Assert**: Returns `domain = NULL`

---

### Module: MOD-002 (Operational State Extractor)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `commands/hazard-analysis.md`

#### Test Case: UTP-002-A (State Extraction Branches)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies the true/false branches: explicit states found vs empty states (implicit NORMAL fallback).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-002-A1**
  * **Arrange**: Set `system_design` content with operational states section listing IDLE, ACTIVE, ERROR
  * **Act**: Call `extract_operational_states(system_design)`
  * **Assert**: Returns `StateSet(states=["IDLE","ACTIVE","ERROR"], is_implicit=false)`

* **Unit Scenario: UTS-002-A2**
  * **Arrange**: Set `system_design` content with no operational states section
  * **Act**: Call `extract_operational_states(system_design)`
  * **Assert**: Returns `StateSet(states=["NORMAL"], is_implicit=true)` and emits warning "No operational states defined in system-design.md — using implicit NORMAL state"

---

### Module: MOD-003 (FMEA Generator)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `commands/hazard-analysis.md`

#### Test Case: UTP-003-A (Hazard Entry Generation Control Flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies all branches: failure modes found/empty, state-severity splitting, domain severity classification, "No identified failure mode" fallback.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-003-A1**
  * **Arrange**: Set `sys_components` to `[{id: "SYS-001"}]`, `states` to `["IDLE","ACTIVE"]`, sensor failure mode identified with IDLE=Negligible and ACTIVE=Critical, `start_id = 1`
  * **Act**: Call `generate_fmea(sys_components, states, requirements, NULL, 1)`
  * **Assert**: Returns 2 entries: `HAZ-001` (SYS-001, IDLE, Negligible) and `HAZ-002` (SYS-001, ACTIVE, Critical)

* **Unit Scenario: UTS-003-A2**
  * **Arrange**: Set `sys_components` to `[{id: "SYS-009"}]` with no identifiable failure modes
  * **Act**: Call `generate_fmea(sys_components, states, requirements, NULL, 1)`
  * **Assert**: Returns 1 entry: `HAZ-001` with failure_mode="No identified failure mode", severity="Negligible", flagged for human review

* **Unit Scenario: UTS-003-A3**
  * **Arrange**: Set `domain = "iso_26262"`, load overlay from `commands/overlays/iso_26262/hazard-analysis.md`, single component with single failure mode
  * **Act**: Call `classify_severity(failure_mode, state, "iso_26262")`
  * **Assert**: Returns severity from the domain overlay scale (e.g., ASIL rating) instead of the base general-purpose label

#### Test Case: UTP-003-B (HAZ ID Sequential Numbering)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verifies HAZ ID boundaries: start_id=1 (min), start_id=999 (max valid), multiple entries maintain sequential order.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-003-B1**
  * **Arrange**: Set `start_id = 1`, 3 failure modes across 1 component
  * **Act**: Call `generate_fmea(...)` 
  * **Assert**: Returns entries with IDs `HAZ-001`, `HAZ-002`, `HAZ-003` — sequential, zero-padded

* **Unit Scenario: UTS-003-B2**
  * **Arrange**: Set `start_id = 998`, 2 failure modes
  * **Act**: Call `generate_fmea(...)`
  * **Assert**: Returns entries with IDs `HAZ-998`, `HAZ-999` — boundary of 3-digit format

---

### Module: MOD-004 (Progressive Deepening Controller)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `commands/hazard-analysis.md`

#### Test Case: UTP-004-A (Deepening Control Flow Branches)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies branches: architecture=NULL (no deepening), no new hazards found, new hazards appended.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-004-A1**
  * **Arrange**: Set `architecture = NULL`
  * **Act**: Call `apply_progressive_deepening(existing_hazards, NULL)`
  * **Assert**: Returns `DeepResult(new_entries=[], note=NULL)` — no deepening attempted

* **Unit Scenario: UTS-004-A2**
  * **Arrange**: Set `existing_hazards` with HAZ-001 through HAZ-015, `architecture` with modules that produce no new failures
  * **Act**: Call `apply_progressive_deepening(existing_hazards, architecture)`
  * **Assert**: Returns `DeepResult(new_entries=[], note="No additional architecture-level hazards identified.")`

* **Unit Scenario: UTS-004-A3**
  * **Arrange**: Set `existing_hazards` with HAZ-001 through HAZ-015, `architecture` with 2 new failure modes
  * **Act**: Call `apply_progressive_deepening(existing_hazards, architecture)`
  * **Assert**: Returns `DeepResult` with 2 new entries starting from `HAZ-016`; original 15 entries unmodified in `merge_hazards()` output

---

### Module: MOD-005 (Template Structure Definition)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `templates/hazard-analysis-template.md`

#### Test Case: UTP-005-A (Template Section Completeness)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies that the template defines all 4 mandatory sections and the FMEA table has exactly 10 columns.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-005-A1**
  * **Arrange**: Read `hazard-analysis-template.md` content
  * **Act**: Parse section headers and FMEA table column headers
  * **Assert**: Contains sections "Summary", "Risk Matrix Definition", "Operational States Reference", "Hazard Register"; FMEA table has columns HAZ ID, Component, Failure Mode, Operational State, Effect, Severity, Likelihood, Risk Level, Mitigation, Residual Risk

---

### Module: MOD-006 (Forward Coverage Check)

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `scripts/bash/validate-hazard-coverage.sh`

#### Test Case: UTP-006-A (Set Operation Branches)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies the intersection/difference logic for SYS→HAZ coverage.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-006-A1**
  * **Arrange**: Set `sys_ids = ["SYS-001","SYS-002","SYS-003"]`, `haz_components = ["SYS-001","SYS-003"]`
  * **Act**: Call `check_forward_coverage(system_design_path, hazard_path)`
  * **Assert**: Returns `covered=["SYS-001","SYS-003"]`, `uncovered=["SYS-002"]`, `pct=66`

* **Unit Scenario: UTS-006-A2**
  * **Arrange**: Set `sys_ids = ["SYS-001"]`, `haz_components = ["SYS-001"]`
  * **Act**: Call `check_forward_coverage(system_design_path, hazard_path)`
  * **Assert**: Returns `covered=["SYS-001"]`, `uncovered=[]`, `pct=100`

#### Test Case: UTP-006-B (Edge: Zero Coverage)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Verifies boundary case where haz_components is empty (0% coverage).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-006-B1**
  * **Arrange**: Set `sys_ids = ["SYS-001","SYS-002"]`, `haz_components = []` (empty FMEA)
  * **Act**: Call `check_forward_coverage(system_design_path, hazard_path)`
  * **Assert**: Returns `covered=[]`, `uncovered=["SYS-001","SYS-002"]`, `pct=0`

---

### Module: MOD-007 (Backward Coverage Check)

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `scripts/bash/validate-hazard-coverage.sh`

#### Test Case: UTP-007-A (Reference Validation Branches)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies branches: valid ref found, broken ref detected, HAZ with no mitigation refs.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-007-A1**
  * **Arrange**: Set `valid_ids = {"REQ-001","SYS-001"}`, HAZ-001 mitigation references `REQ-001`
  * **Act**: Call `check_backward_coverage(hazard_path, requirements_path, system_design_path)`
  * **Assert**: Returns `broken=[]`, `pct=100`

* **Unit Scenario: UTS-007-A2**
  * **Arrange**: Set `valid_ids = {"REQ-001"}`, HAZ-003 mitigation references `REQ-XYZ`
  * **Act**: Call `check_backward_coverage(...)`
  * **Assert**: Returns `broken=["HAZ-003 references REQ-XYZ which does not exist"]`, pct reflecting the gap

---

### Module: MOD-008 (State Consistency Check)

**Parent Architecture Modules**: ARCH-005
**Target Source File(s)**: `scripts/bash/validate-hazard-coverage.sh`

#### Test Case: UTP-008-A (State Set Comparison Branches)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies branches: all states valid, undefined state found, implicit NORMAL fallback.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-008-A1**
  * **Arrange**: Set `defined_states = ["IDLE","ACTIVE"]`, hazard states all in {"IDLE","ACTIVE"}
  * **Act**: Call `check_state_consistency(hazard_path, system_design_path)`
  * **Assert**: Returns `consistent=true`, `undefined_states=[]`

* **Unit Scenario: UTS-008-A2**
  * **Arrange**: Set `defined_states = ["IDLE","ACTIVE"]`, one hazard references "MAINTENANCE"
  * **Act**: Call `check_state_consistency(hazard_path, system_design_path)`
  * **Assert**: Returns `consistent=false`, `undefined_states=["MAINTENANCE"]`

---

### Module: MOD-009 (CLI Argument Parser)

**Parent Architecture Modules**: ARCH-006
**Target Source File(s)**: `scripts/bash/validate-hazard-coverage.sh`

#### Test Case: UTP-009-A (Flag Parsing Branches)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies flag parsing: --json, --partial, positional dir, missing dir.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-009-A1**
  * **Arrange**: Set `args = ["specs/005a/v-model", "--json", "--partial"]`
  * **Act**: Call `parse_cli_args(args)`
  * **Assert**: Returns `CLIConfig(json_mode=true, partial_mode=true, vmodel_dir="specs/005a/v-model")`

* **Unit Scenario: UTS-009-A2**
  * **Arrange**: Set `args = []` (no arguments)
  * **Act**: Call `parse_cli_args(args)`
  * **Assert**: Prints usage and exits with code 1

---

### Module: MOD-010 (Validation Orchestrator and Output Formatter)

**Parent Architecture Modules**: ARCH-006
**Target Source File(s)**: `scripts/bash/validate-hazard-coverage.sh`

#### Test Case: UTP-010-A (Orchestration Control Flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies the main() orchestration: all checks pass (exit 0), any gap (exit 1), partial mode skip, JSON vs human-readable output.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| MOD-006 (forward) | Internal function | Direct call — no mock | Testing real orchestration |
| MOD-007 (backward) | Internal function | Direct call — no mock | Testing real orchestration |
| MOD-008 (state) | Internal function | Direct call — no mock | Testing real orchestration |

* **Unit Scenario: UTS-010-A1**
  * **Arrange**: Set all validators to return clean results (no gaps), `json_mode=true`
  * **Act**: Call `main()`
  * **Assert**: Stdout is valid JSON with `has_gaps=false`, exit code 0

* **Unit Scenario: UTS-010-A2**
  * **Arrange**: Set forward validator to return 1 uncovered SYS, `json_mode=true`
  * **Act**: Call `main()`
  * **Assert**: Stdout JSON has `has_gaps=true`, `forward_gaps=["SYS-002"]`, exit code 1

* **Unit Scenario: UTS-010-A3**
  * **Arrange**: Set `partial_mode=true`, requirements.md absent
  * **Act**: Call `main()`
  * **Assert**: Backward check is skipped, JSON `backward_coverage="N/A"`, exit code based only on forward + state

---

### Module: MOD-011 (PowerShell Validation Engine)

**Parent Architecture Modules**: ARCH-007
**Target Source File(s)**: `scripts/powershell/Validate-HazardCoverage.ps1`

#### Test Case: UTP-011-A (PowerShell Parity Control Flow)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies that the PowerShell implementation exercises the same branches as MOD-009/MOD-010 and produces identical output.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-011-A1**
  * **Arrange**: Set identical inputs as UTS-010-A1 (all clean)
  * **Act**: Call `Invoke-HazardCoverageValidation -Json`
  * **Assert**: JSON output field-identical to Bash output, exit code 0

* **Unit Scenario: UTS-011-A2**
  * **Arrange**: Set identical inputs as UTS-010-A2 (forward gap)
  * **Act**: Call `Invoke-HazardCoverageValidation -Json`
  * **Assert**: JSON output field-identical to Bash output, exit code 1

---

### Module: MOD-012 (HAZ Regex Parser)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `scripts/bash/build-matrix.sh`

#### Test Case: UTP-012-A (Regex Extraction Branches)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies branches: file exists with valid entries, file has no HAZ entries, file doesn't exist.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-012-A1**
  * **Arrange**: Set `hazard_analysis_path` to file with FMEA table: `| HAZ-001 | SYS-001 | ... | REQ-001, SYS-002 | ... |`
  * **Act**: Call `extract_haz_entries(hazard_analysis_path)`
  * **Assert**: Returns `[{haz_id: "HAZ-001", mitigations: ["REQ-001","SYS-002"]}]`

* **Unit Scenario: UTS-012-A2**
  * **Arrange**: Set `hazard_analysis_path` to non-existent file
  * **Act**: Call `extract_haz_entries(hazard_analysis_path)`
  * **Assert**: Returns empty array `[]`

---

### Module: MOD-013 (Verification Chain Resolver)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `scripts/bash/build-matrix.sh`

#### Test Case: UTP-013-A (Chain Resolution Branches)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies branches: REQ mitigation with ATP match, SYS mitigation with STP match, no match (gap annotation).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-013-A1**
  * **Arrange**: Set `haz_entries = [{haz_id:"HAZ-001", mitigations:["REQ-001"]}]`, `req_to_atp = {"REQ-001": ["ATP-001-A"]}`
  * **Act**: Call `resolve_verification_chain(haz_entries, vmodel_dir)`
  * **Assert**: Returns `[{haz_id:"HAZ-001", mitigation:"REQ-001", verification:"ATP-001-A"}]`

* **Unit Scenario: UTS-013-A2**
  * **Arrange**: Set `haz_entries = [{haz_id:"HAZ-005", mitigations:["SYS-003"]}]`, `sys_to_stp = {}` (no match)
  * **Act**: Call `resolve_verification_chain(haz_entries, vmodel_dir)`
  * **Assert**: Returns `[{haz_id:"HAZ-005", mitigation:"SYS-003", verification:"⚠️ No test coverage"}]`

---

### Module: MOD-014 (Matrix H Renderer)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `scripts/bash/build-matrix.sh`

#### Test Case: UTP-014-A (Rendering Branches)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies branches: non-empty rows (render table), empty rows (return empty string).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-014-A1**
  * **Arrange**: Set `resolved_rows = [{haz_id:"HAZ-001", mitigation:"REQ-001", verification:"ATP-001-A"}]`
  * **Act**: Call `render_matrix_h(resolved_rows)`
  * **Assert**: Returns Markdown string containing "## Matrix H", table header, row `| HAZ-001 | REQ-001 | ATP-001-A |`, and coverage "1 / 1 (100%)"

* **Unit Scenario: UTS-014-A2**
  * **Arrange**: Set `resolved_rows = []`
  * **Act**: Call `render_matrix_h(resolved_rows)`
  * **Assert**: Returns empty string `""`

---

### Module: MOD-015 (PowerShell Matrix H Engine)

**Parent Architecture Modules**: ARCH-010
**Target Source File(s)**: `scripts/powershell/build-matrix.ps1`

#### Test Case: UTP-015-A (PowerShell Matrix H Parity)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies identical output to MOD-012/013/014 for the same inputs.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-015-A1**
  * **Arrange**: Set identical inputs as UTS-014-A1
  * **Act**: Call PowerShell equivalent
  * **Assert**: Markdown output identical to Bash version

---

### Module: MOD-016 (Matrix H Section Injector)

**Parent Architecture Modules**: ARCH-011
**Target Source File(s)**: `commands/trace.md`

#### Test Case: UTP-016-A (Conditional Injection Branches)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies branches: hazard-analysis.md in available_docs (inject Matrix H), not in available_docs (return unchanged output).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| build-matrix.sh | Shell exec | Stub: returns pre-built Matrix H string | Isolate injection logic from matrix building |

* **Unit Scenario: UTS-016-A1**
  * **Arrange**: Set `available_docs = ["spec.md","requirements.md","hazard-analysis.md"]`, stub build-matrix returns Matrix H data
  * **Act**: Call `inject_matrix_h(available_docs, trace_output, vmodel_dir)`
  * **Assert**: Returns `trace_output` + separator + Matrix H data

* **Unit Scenario: UTS-016-A2**
  * **Arrange**: Set `available_docs = ["spec.md","requirements.md"]` (no hazard-analysis.md)
  * **Act**: Call `inject_matrix_h(available_docs, trace_output, vmodel_dir)`
  * **Assert**: Returns `trace_output` unchanged — no Matrix H, no warning

---

### Module: MOD-017 (HAZ Prefix Registration)

**Parent Architecture Modules**: ARCH-012
**Target Source File(s)**: `evals/validators/id_validator.py`

#### Test Case: UTP-017-A (HAZ Pattern Matching)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Verifies valid and invalid HAZ ID partitions.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-017-A1**
  * **Arrange**: Set `id_string = "HAZ-001"`
  * **Act**: Call `validate_id(id_string)`
  * **Assert**: Returns `True`

* **Unit Scenario: UTS-017-A2**
  * **Arrange**: Set `id_string = "HAZ-1"` (missing zero-padding)
  * **Act**: Call `validate_id(id_string)`
  * **Assert**: Returns `False`

* **Unit Scenario: UTS-017-A3**
  * **Arrange**: Set `id_string = "HAZ-0001"` (4 digits, not 3)
  * **Act**: Call `validate_id(id_string)`
  * **Assert**: Returns `False`

---

### Module: MOD-018 (Manifest Configuration)

**Parent Architecture Modules**: ARCH-013
**Target Source File(s)**: `extension.yml`

#### Test Case: UTP-018-A (YAML Entry Validation)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies that the manifest entries are valid YAML with required fields.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-018-A1**
  * **Arrange**: Read `extension.yml` after MOD-018 entries are applied
  * **Act**: Parse YAML and extract command registration for `speckit.v-model.hazard-analysis`
  * **Assert**: Command entry has `file: "commands/hazard-analysis.md"` and non-empty description; `defaults.id_prefixes` contains `hazards: "HAZ"`

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Modules (MOD) | 18 |
| Modules tested | 18 |
| Modules bypassed ([EXTERNAL]) | 0 |
| Total Test Cases (UTP) | 21 |
| Total Scenarios (UTS) | 43 |
| Modules with ≥1 UTP | 18 / 18 (100%) |
| Test Cases with ≥1 UTS | 21 / 21 (100%) |
| **Overall Coverage (MOD→UTP)** | **100%** |

### Technique Distribution

| Technique | Test Cases | Percentage |
|-----------|-----------|------------|
| Statement & Branch Coverage | 17 | 77% |
| Boundary Value Analysis | 2 | 9% |
| Equivalence Partitioning | 2 | 9% |
| Strict Isolation | 1 | 5% |
| State Transition Testing | 0 | 0% |

> Note: No State Transition Testing because all 18 modules are stateless (all State Machine Views are "N/A — Stateless"). No `[EXTERNAL]` bypasses.

## Uncovered Modules

None — full coverage achieved.
