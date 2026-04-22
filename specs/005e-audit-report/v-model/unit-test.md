# V-Model Unit Test Plan: Release Audit Report

**Feature Branch**: `feature/005e-audit-report`
**Created**: 2026-04-05
**Status**: Approved
**Source**: `specs/005e-audit-report/v-model/module-design.md`

## Overview

This document defines unit test procedures (UTP) and test steps (UTS) for each module design. Tests verify function-level correctness, edge cases, and error handling.

## Test Procedures

### MOD-001 — parse_cli_args

#### UTP-001-A: Valid argument parsing

| Field | Value |
|-------|-------|
| **Traces To** | MOD-001 |
| **Technique** | Equivalence Partitioning |

##### UTS-001-A1: Minimal invocation (directory only)
```
Given args = ["./v-model-dir"]
When parse_cli_args is invoked
Then vmodel_dir SHALL be "./v-model-dir" and all other fields SHALL have defaults
```

##### UTS-001-A2: Full invocation with all options
```
Given args = ["./dir", "--system-name", "CBGMS", "--version", "2.1.0", "--git-tag", "v2.1.0", "--regulatory-context", "IEC 62304", "--output", "report.md", "--json"]
When parse_cli_args is invoked
Then all fields SHALL be set to the provided values and json_flag SHALL be true
```

#### UTP-001-B: Error handling

| Field | Value |
|-------|-------|
| **Traces To** | MOD-001 |
| **Technique** | Boundary Value Analysis |

##### UTS-001-B1: No arguments → help + exit 2
```
Given no arguments
When parse_cli_args is invoked
Then SHALL print usage to stderr and exit with code 2
```

##### UTS-001-B2: --help flag → usage + exit 0
```
Given args = ["--help"]
When parse_cli_args is invoked
Then SHALL print usage to stdout and exit with code 0
```

##### UTS-001-B3: Non-existent directory → exit 2
```
Given args = ["/nonexistent/path"]
When parse_cli_args is invoked
Then SHALL print error message and exit with code 2
```

### MOD-002 — discover_artifacts

#### UTP-002-A: Artifact enumeration

| Field | Value |
|-------|-------|
| **Traces To** | MOD-002 |
| **Technique** | Equivalence Partitioning |

##### UTS-002-A1: All expected files present
```
Given a directory with all 11 expected V-Model files
When discover_artifacts is invoked
Then SHALL return 11 records, all with exists=true, sha and date populated
```

##### UTS-002-A2: Partial files present
```
Given a directory with only requirements.md and traceability-matrix.md
When discover_artifacts is invoked
Then SHALL return 11 records, 2 with exists=true, 9 with exists=false and sha="—"
```

##### UTS-002-A3: Empty directory
```
Given an empty directory
When discover_artifacts is invoked
Then SHALL return 11 records, all with exists=false
```

#### UTP-002-B: Git metadata extraction

| Field | Value |
|-------|-------|
| **Traces To** | MOD-002 |
| **Technique** | Interface Testing |

##### UTS-002-B1: Git SHA is 7 characters
```
Given a file tracked by Git
When discover_artifacts extracts metadata
Then sha SHALL be exactly 7 characters (abbreviated commit hash)
```

##### UTS-002-B2: Date in ISO 8601 format
```
Given a file tracked by Git
When discover_artifacts extracts metadata
Then date SHALL match ISO 8601 format (YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS)
```

### MOD-003 — parse_matrix_file

#### UTP-003-A: Matrix section parsing

| Field | Value |
|-------|-------|
| **Traces To** | MOD-003 |
| **Technique** | Equivalence Partitioning |

##### UTS-003-A1: Single matrix section
```
Given a file with one "## Matrix A" section and 5 data rows
When parse_matrix_file is invoked
Then SHALL return 1 matrix object with 5 rows
```

##### UTS-003-A2: Multiple matrix sections (A through D + H)
```
Given a file with 5 matrix sections
When parse_matrix_file is invoked
Then SHALL return 5 matrix objects, each with correct headers and rows
```

##### UTS-003-A3: Separator rows skipped
```
Given a matrix table with |---|---|---| separator
When parse_matrix_file is invoked
Then the separator row SHALL NOT appear in data_rows
```

#### UTP-003-B: Edge cases

| Field | Value |
|-------|-------|
| **Traces To** | MOD-003 |
| **Technique** | Boundary Value Analysis |

##### UTS-003-B1: File not found → empty array
```
Given a non-existent file path
When parse_matrix_file is invoked
Then SHALL return an empty array
```

##### UTS-003-B2: Empty file → empty array
```
Given an empty file
When parse_matrix_file is invoked
Then SHALL return an empty array
```

### MOD-004 — compute_coverage_metrics

#### UTP-004-A: Coverage computation

| Field | Value |
|-------|-------|
| **Traces To** | MOD-004 |
| **Technique** | Equivalence Partitioning |

##### UTS-004-A1: 100% forward and backward coverage
```
Given a matrix where every source ID maps to at least one target and vice versa
When compute_coverage is invoked
Then forward and backward coverage SHALL both be 100%
And gaps and orphans SHALL be empty
```

##### UTS-004-A2: Gap detected (source without target)
```
Given a matrix where REQ-003 has no test scenario mapped
When compute_coverage is invoked
Then gaps SHALL contain REQ-003
And forward coverage SHALL be less than 100%
```

##### UTS-004-A3: Orphan detected (target without source)
```
Given a matrix where SCN-099-A1 has no parent requirement
When compute_coverage is invoked
Then orphans SHALL contain SCN-099-A1
```

### MOD-005 — parse_hazards

#### UTP-005-A: Hazard extraction

| Field | Value |
|-------|-------|
| **Traces To** | MOD-005 |
| **Technique** | Equivalence Partitioning |

##### UTS-005-A1: FMEA table with 3 hazards
```
Given a hazard-analysis.md with 3 HAZ-NNN rows
When parse_hazards is invoked
Then SHALL return 3 hazard records with correct fields
```

##### UTS-005-A2: No hazard file → null
```
Given null path
When parse_hazards is invoked
Then SHALL return null
```

### MOD-006 — scan_anomalies

#### UTP-006-A: Anomaly detection

| Field | Value |
|-------|-------|
| **Traces To** | MOD-006 |
| **Technique** | Equivalence Partitioning |

##### UTS-006-A1: Failed test detected
```
Given a matrix row with status "❌ Failed"
When scan_anomalies is invoked
Then anomalies SHALL contain one entry with type "Failed Test"
```

##### UTS-006-A2: Skipped test detected
```
Given a matrix row with status "⏭️ Skipped"
When scan_anomalies is invoked
Then anomalies SHALL contain one entry with type "Skipped Test"
```

##### UTS-006-A3: Passed tests ignored
```
Given 10 matrix rows all with status "✅ Passed"
When scan_anomalies is invoked
Then anomalies SHALL be empty
```

##### UTS-006-A4: Mixed statuses across multiple matrices
```
Given Matrix A with 1 failed and Matrix D with 1 skipped
When scan_anomalies is invoked
Then anomalies SHALL contain 2 entries referencing the correct matrices
```

### MOD-007 — parse_waivers

#### UTP-007-A: Waiver parsing

| Field | Value |
|-------|-------|
| **Traces To** | MOD-007 |
| **Technique** | Equivalence Partitioning |

##### UTS-007-A1: Two valid waivers
```
Given a waivers.md with ### WAV-001 and ### WAV-002
When parse_waivers is invoked
Then waiver_map SHALL contain 2 entries keyed by artifact ID
```

##### UTS-007-A2: No waivers file → empty map
```
Given null path
When parse_waivers is invoked
Then SHALL return empty map
```

##### UTS-007-A3: Waiver fields correctly extracted
```
Given a waiver with **Artifact**: SCN-012-C2 and **Approved By**: Jane Smith
When parse_waivers is invoked
Then the entry for SCN-012-C2 SHALL have approved_by = "Jane Smith"
```

### MOD-008 — cross_reference_anomalies

#### UTP-008-A: Classification logic

| Field | Value |
|-------|-------|
| **Traces To** | MOD-008 |
| **Technique** | Decision Table |

##### UTS-008-A1: 0 anomalies → RELEASE READY, exit 0
```
Given 0 anomalies and any waiver map
When cross_reference is invoked
Then status SHALL be "✅ RELEASE READY" and exit_code SHALL be 0
```

##### UTS-008-A2: All anomalies waived → RELEASE CANDIDATE, exit 0
```
Given 2 anomalies both with matching waivers
When cross_reference is invoked
Then status SHALL be "✅ RELEASE CANDIDATE" and exit_code SHALL be 0
```

##### UTS-008-A3: Some anomalies unwaived → NOT READY, exit 1
```
Given 3 anomalies, only 1 with matching waiver
When cross_reference is invoked
Then status SHALL be "❌ NOT READY" and exit_code SHALL be 1
And 2 entries SHALL have disposition "BLOCKING"
```

##### UTS-008-A4: Orphaned waiver detected
```
Given 1 anomaly (waived) and 1 additional waiver with no matching anomaly
When cross_reference is invoked
Then orphaned_waivers SHALL contain the unused waiver
```

### MOD-009 — render_report

#### UTP-009-A: Section rendering

| Field | Value |
|-------|-------|
| **Traces To** | MOD-009 |
| **Technique** | Equivalence Partitioning |

##### UTS-009-A1: Executive summary contains metrics
```
Given total_requirements=47, total_tests=189, passed=187, failed=0, skipped=2
When render_report generates Section 1
Then the executive summary SHALL contain "47" requirements and "189" tests
```

##### UTS-009-A2: Artifact inventory table complete
```
Given 8 discovered artifacts with SHAs and dates
When render_report generates Section 2
Then the table SHALL contain 8 rows with git SHA and date columns
```

##### UTS-009-A3: Signature block has blank fields
```
When render_report generates Section 7
Then the table SHALL contain QA Manager and Lead Engineer rows with blank Signature fields
```

### MOD-010 — render_json

#### UTP-010-A: JSON output structure

| Field | Value |
|-------|-------|
| **Traces To** | MOD-010 |
| **Technique** | Interface Testing |

##### UTS-010-A1: JSON contains all top-level keys
```
When render_json is invoked with complete data
Then the JSON SHALL contain keys: metadata, compliance_status, exit_code, artifact_inventory, matrices, coverage_analysis, hazard_summary, anomalies, summary
```

##### UTS-010-A2: JSON is valid (parseable)
```
When render_json outputs to stdout
Then the output SHALL be valid JSON (parseable by json.loads / ConvertFrom-Json)
```

### MOD-011 — dispatch_pipeline

**Parent Architecture Modules**: ARCH-010
**Target Source File(s)**: `scripts/bash/build-audit-report.sh`, `scripts/powershell/Build-Audit-Report.ps1`

#### UTP-011-A: Pipeline orchestration — statement and branch coverage

| Field | Value |
|-------|-------|
| **Traces To** | MOD-011 |
| **Technique** | Statement & Branch Coverage |
| **Target View** | Algorithmic/Logic View |

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|--------------------|-----------|
| parse_cli_args | MOD-001 / ARCH-001 | Stub — returns configurable config struct | Isolate orchestrator from argument-parsing logic |
| discover_artifacts | MOD-002 / ARCH-002 | Stub — returns fixed artifact array | Isolate orchestrator from file-system discovery |
| parse_matrix_file | MOD-003 / ARCH-003 | Stub — returns fixed matrix array | Isolate orchestrator from markdown parsing |
| compute_coverage_metrics | MOD-004 / ARCH-003 | Stub — returns fixed coverage object | Isolate orchestrator from coverage computation |
| parse_hazards | MOD-005 / ARCH-004 | Stub — returns null | Isolate orchestrator from hazard parsing |
| scan_anomalies | MOD-006 / ARCH-005 | Stub — returns fixed anomaly list | Isolate orchestrator from anomaly scanning |
| parse_waivers | MOD-007 / ARCH-006 | Stub — returns fixed waiver map | Isolate orchestrator from waiver parsing |
| cross_reference | MOD-008 / ARCH-007 | Stub — returns configurable result with exit_code | Control exit_code to drive step-10 assertion |
| render_report | MOD-009 / ARCH-008 | Spy — records call arguments | Verify report renderer is invoked with assembled data |
| render_json | MOD-010 / ARCH-009 | Spy — records invocation | Verify JSON renderer is conditionally invoked |

* **Unit Scenario: UTS-011-A1** — happy path: all 10 steps execute, exit code 0 propagated
  * **Arrange**: Stub `parse_cli_args` to return `{vmodel_dir: "./v-model", json_flag: false, exit_code: 0}`; stub `discover_artifacts` to return 11 artifact records; stub `parse_matrix_file` to return 2 matrix objects; stub `compute_coverage_metrics` to return `{forward_count: 10, forward_total: 10, gaps: [], orphans: []}`; stub `parse_hazards` to return `null`; stub `scan_anomalies` to return `[]`; stub `parse_waivers` to return `{}`; stub `cross_reference` to return `{classified: [], orphaned: [], status: "✅ RELEASE READY", exit_code: 0}`; spy `render_report` and `render_json`
  * **Act**: Call `dispatch_pipeline(["./v-model"])`
  * **Assert**: `render_report` spy records exactly 1 invocation; `render_json` spy records 0 invocations (branch B false-path: `json_flag=false`); `dispatch_pipeline` exits with code 0 (propagated from `cross_reference` stub's `result.exit_code`)

* **Unit Scenario: UTS-011-A2** — `parse_cli_args` returns exit_code 2: pipeline aborts at step-1 branch
  * **Arrange**: Stub `parse_cli_args` to return `{exit_code: 2}`; spy `discover_artifacts`, `parse_matrix_file`, `compute_coverage_metrics`, `parse_hazards`, `scan_anomalies`, `parse_waivers`, `cross_reference`, `render_report`, `render_json`
  * **Act**: Call `dispatch_pipeline(["/nonexistent/path"])`
  * **Assert**: `dispatch_pipeline` exits with code 2; all step-2 through step-10 spies record 0 invocations (branch A true-path exits immediately after step 1)

* **Unit Scenario: UTS-011-A3** — `json_flag=true` branch: `render_json` IS invoked after `render_report`
  * **Arrange**: Stub `parse_cli_args` to return `{vmodel_dir: "./v-model", json_flag: true, exit_code: 0}`; stub all intermediate sub-modules (steps 2–7) with nominal return values; stub `cross_reference` to return `{exit_code: 0, status: "✅ RELEASE READY", classified: [], orphaned: []}`; spy `render_report` and `render_json`
  * **Act**: Call `dispatch_pipeline(["./v-model", "--json"])`
  * **Assert**: `render_report` spy records exactly 1 invocation (step 8 still executes); `render_json` spy records exactly 1 invocation (branch B true-path entered); `render_report` is invoked before `render_json` (step 8 precedes step 9); `dispatch_pipeline` exits with code 0

* **Unit Scenario: UTS-011-A4** — `json_flag=false` branch: `render_json` is NOT invoked
  * **Arrange**: Stub `parse_cli_args` to return `{vmodel_dir: "./v-model", json_flag: false, exit_code: 0}`; stub all intermediate sub-modules (steps 2–7) with nominal return values; stub `cross_reference` to return `{exit_code: 0, classified: [], orphaned: []}`; spy `render_json`
  * **Act**: Call `dispatch_pipeline(["./v-model"])`
  * **Assert**: `render_json` spy records 0 invocations (branch B false-path skips step 9); `dispatch_pipeline` exits with code 0

* **Unit Scenario: UTS-011-A5** — `cross_reference` returns exit_code 1: dispatch propagates exit 1
  * **Arrange**: Stub `parse_cli_args` to return `{vmodel_dir: "./v-model", json_flag: false, exit_code: 0}`; stub all intermediate sub-modules (steps 2–7) with nominal return values; stub `cross_reference` to return `{classified: [{disposition: "BLOCKING"}], status: "❌ NOT READY — Unwaived anomalies detected", exit_code: 1}`; spy `render_report`
  * **Act**: Call `dispatch_pipeline(["./v-model"])`
  * **Assert**: `render_report` spy records exactly 1 invocation and receives result with `exit_code=1` in arguments (step 8 still executes); `dispatch_pipeline` exits with code 1 (step 10 propagates `result.exit_code`)

#### UTP-011-B: Pipeline sub-module invocation — strict isolation of all dependencies

| Field | Value |
|-------|-------|
| **Traces To** | MOD-011 |
| **Technique** | Strict Isolation |
| **Target View** | Architecture Interface View |

**Dependency & Mock Registry:**

Same registry as UTP-011-A — all 10 sub-module functions are stubbed or spied.

* **Unit Scenario: UTS-011-B1** — `discover_artifacts` called with `vmodel_dir` from config
  * **Arrange**: Stub `parse_cli_args` to return `{vmodel_dir: "/spec/v-model", json_flag: false, exit_code: 0}`; spy `discover_artifacts` to capture invocation arguments and return 11 artifact records; stub all remaining sub-modules with nominal return values
  * **Act**: Call `dispatch_pipeline(["/spec/v-model"])`
  * **Assert**: `discover_artifacts` spy records exactly 1 invocation; captured argument equals `"/spec/v-model"` (`config.vmodel_dir` passed verbatim in step 2)

* **Unit Scenario: UTS-011-B2** — `parse_matrix_file` called with `vmodel_dir + "/traceability-matrix.md"`
  * **Arrange**: Stub `parse_cli_args` to return `{vmodel_dir: "/spec/v-model", json_flag: false, exit_code: 0}`; spy `parse_matrix_file` to capture invocation arguments and return `[]`; stub all remaining sub-modules with nominal return values
  * **Act**: Call `dispatch_pipeline(["/spec/v-model"])`
  * **Assert**: `parse_matrix_file` spy records exactly 1 invocation; captured argument equals `"/spec/v-model/traceability-matrix.md"` (path constructed by concatenation in step 3)

* **Unit Scenario: UTS-011-B3** — `parse_hazards` called with `vmodel_dir + "/hazard-analysis.md"`
  * **Arrange**: Stub `parse_cli_args` to return `{vmodel_dir: "/spec/v-model", json_flag: false, exit_code: 0}`; spy `parse_hazards` to capture invocation arguments and return `null`; stub all remaining sub-modules with nominal return values
  * **Act**: Call `dispatch_pipeline(["/spec/v-model"])`
  * **Assert**: `parse_hazards` spy records exactly 1 invocation; captured argument equals `"/spec/v-model/hazard-analysis.md"` (path constructed in step 4)

* **Unit Scenario: UTS-011-B4** — `parse_waivers` called with `vmodel_dir + "/waivers.md"`
  * **Arrange**: Stub `parse_cli_args` to return `{vmodel_dir: "/spec/v-model", json_flag: false, exit_code: 0}`; spy `parse_waivers` to capture invocation arguments and return `{}`; stub all remaining sub-modules with nominal return values
  * **Act**: Call `dispatch_pipeline(["/spec/v-model"])`
  * **Assert**: `parse_waivers` spy records exactly 1 invocation; captured argument equals `"/spec/v-model/waivers.md"` (path constructed in step 6)

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Modules (MOD) | 11 (11 active, 0 deprecated) |
| Modules tested | 11 (excludes [EXTERNAL]) |
| Modules bypassed ([EXTERNAL]) | 0 |
| Total Test Cases (UTP) | 15 |
| Total Scenarios (UTS) | 45 |
| Modules with ≥1 UTP | 11 / 11 (100%) (active, non-[EXTERNAL] items only) |
| Test Cases with ≥1 UTS | 15 / 15 (100%) |
| **Overall Coverage (MOD→UTP)** | **100%** |

### Technique Distribution

| Technique | Test Cases | Percentage |
|-----------|-----------|------------|
| Statement & Branch Coverage | 1 | 7% |
| Boundary Value Analysis | 2 | 13% |
| Equivalence Partitioning | 8 | 53% |
| Strict Isolation | 1 | 7% |
| State Transition Testing | 0 | 0% |
| Interface Testing (legacy) | 2 | 13% |
| Decision Table (legacy) | 1 | 7% |

## Uncovered Modules

None — full coverage achieved.

---

## V&V Coverage Gate (IEEE 1012:2016 §5.7)

IEEE 1012:2016 §5.7 requires every software module to be exercised by at least one V&V activity at unit test level. The table below maps every active MOD-NNN module to its covering UTP-NNN-X test case(s) and confirms that white-box (statement/branch) coverage is specified for the pipeline orchestration module.

### MOD→UTP Coverage Table

| MOD Module | Module Name | White-Box Coverage | V&V Activities (UTP) | Status |
|------------|-------------|-------------------|----------------------|--------|
| MOD-001 | parse_cli_args | Equivalence Partitioning + Boundary Value Analysis | UTP-001-A, UTP-001-B | ✅ Covered |
| MOD-002 | discover_artifacts | Equivalence Partitioning + Interface Testing | UTP-002-A, UTP-002-B | ✅ Covered |
| MOD-003 | parse_matrix_file | Equivalence Partitioning + Boundary Value Analysis | UTP-003-A, UTP-003-B | ✅ Covered |
| MOD-004 | compute_coverage_metrics | Equivalence Partitioning | UTP-004-A | ✅ Covered |
| MOD-005 | parse_hazards | Equivalence Partitioning | UTP-005-A | ✅ Covered |
| MOD-006 | scan_anomalies | Equivalence Partitioning | UTP-006-A | ✅ Covered |
| MOD-007 | parse_waivers | Equivalence Partitioning | UTP-007-A | ✅ Covered |
| MOD-008 | cross_reference_anomalies | Decision Table | UTP-008-A | ✅ Covered |
| MOD-009 | render_report | Equivalence Partitioning | UTP-009-A | ✅ Covered |
| MOD-010 | render_json | Interface Testing | UTP-010-A | ✅ Covered |
| MOD-011 | dispatch_pipeline | Statement & Branch Coverage + Strict Isolation | UTP-011-A, UTP-011-B | ✅ Covered |

**V&V Gap Summary**: No gaps — all 11 active MOD-NNN modules have at least one unit-level V&V activity (UTP-NNN-X). IEEE 1012:2016 §5.7 entry criterion satisfied.

### White-Box Coverage Confirmation

MOD-011 (`dispatch_pipeline`) is the only module requiring explicit statement and branch coverage, as it is the top-level orchestrator whose branching logic (argument validation exit, `json_flag` branch, exit code propagation) directly determines system behavior. Coverage is confirmed by:

| Branch | UTP Scenario | Coverage Status |
|--------|-------------|-----------------|
| parse_cli_args returns exit_code 2 → immediate abort (branch A true-path) | UTS-011-A2 | ✅ Covered |
| parse_cli_args returns exit_code 0 → full pipeline executes (branch A false-path) | UTS-011-A1 | ✅ Covered |
| json_flag=true → render_json invoked (branch B true-path) | UTS-011-A3 | ✅ Covered |
| json_flag=false → render_json NOT invoked (branch B false-path) | UTS-011-A4 | ✅ Covered |
| cross_reference returns exit_code 1 → dispatch propagates exit 1 (step-10 path) | UTS-011-A5 | ✅ Covered |

All other modules (MOD-001 through MOD-010) use Equivalence Partitioning, Boundary Value Analysis, Interface Testing, or Decision Table techniques to achieve functional coverage appropriate for their algorithmic complexity. No additional statement/branch analysis is required for these modules as their logic is single-path or directly enumerated by the decision table.

### Entry Criteria (IEEE 1012:2016 §5.7.1)

| Criterion | Status |
|-----------|--------|
| `module-design.md` is current with ISO 12207:2017 §8.4.4 preamble | ✅ Met |
| Every `MOD-NNN` module has at least one `UTP-NNN-X` test case (100% MOD→UTP coverage) | ✅ Met — 11/11 (100%) |
| All `UTP-NNN-X` test cases have at least one `UTS-NNN-X#` executable scenario | ✅ Met — 15/15 (100%) |
| White-box coverage specified for pipeline orchestration module (MOD-011) | ✅ Met — 5 branches covered by UTP-011-A scenarios |
| V&V gap list is empty | ✅ Met — 0 gaps |

**Verdict**: ✅ PASS — IEEE 1012:2016 §5.7 V&V completeness requirements satisfied at unit test level.
