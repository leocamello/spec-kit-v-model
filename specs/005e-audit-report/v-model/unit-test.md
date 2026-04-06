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
