# V-Model System Test Plan: Release Audit Report

**Feature Branch**: `feature/005e-audit-report`
**Created**: 2026-04-05
**Status**: Approved
**Source**: `specs/005e-audit-report/v-model/system-design.md`

## Overview

This document defines system-level test procedures (STP) and test steps (STS) for each system component, using ISO 29119-4 techniques.

## Test Procedures

### SYS-001 — Artifact Discovery Engine

#### STP-001-A: Full artifact discovery

| Field | Value |
|-------|-------|
| **Traces To** | SYS-001 |
| **Technique** | Equivalence Partitioning |
| **Precondition** | V-Model directory with varying artifact counts |

##### STS-001-A1: All 11 artifacts discovered
```
Given a directory with all 11 V-Model artifact files committed to Git
When artifact discovery runs
Then 11 artifacts SHALL be returned with valid SHA and date for each
```

##### STS-001-A2: Minimal set (2 artifacts) discovered
```
Given a directory with only requirements.md and traceability-matrix.md
When artifact discovery runs
Then exactly 2 artifacts SHALL be returned
```

##### STS-001-A3: Empty directory returns 0 artifacts
```
Given an empty V-Model directory
When artifact discovery runs
Then 0 artifacts SHALL be returned
```

#### STP-001-B: Git metadata extraction accuracy

| Field | Value |
|-------|-------|
| **Traces To** | SYS-001 |
| **Technique** | Boundary Value Analysis |
| **Precondition** | Git repository with known commits |

##### STS-001-B1: SHA is exactly 7 characters
```
Given a committed artifact file
When Git metadata is extracted
Then the SHA SHALL be exactly 7 alphanumeric characters
```

##### STS-001-B2: Date matches last commit date
```
Given a file last committed on 2026-03-15
When Git metadata is extracted
Then the date SHALL be 2026-03-15
```

### SYS-002 — Matrix Extractor

#### STP-002-A: Matrix section identification

| Field | Value |
|-------|-------|
| **Traces To** | SYS-002 |
| **Technique** | Equivalence Partitioning |
| **Precondition** | traceability-matrix.md with varying matrix counts |

##### STS-002-A1: All 5 matrices extracted (A, B, C, D, H)
```
Given a traceability-matrix.md with matrices A, B, C, D, and H
When the matrix extractor runs
Then 5 matrix sections SHALL be returned
```

##### STS-002-A2: Partial matrices (A and B only)
```
Given a traceability-matrix.md with only matrices A and B
When the matrix extractor runs
Then 2 matrix sections SHALL be returned
```

#### STP-002-B: Coverage metric computation

| Field | Value |
|-------|-------|
| **Traces To** | SYS-002 |
| **Technique** | Boundary Value Analysis |
| **Precondition** | Matrix with known coverage characteristics |

##### STS-002-B1: 100% forward and backward coverage
```
Given a matrix where every design ID has tests and every test has a parent
When coverage metrics are computed
Then forward_pct SHALL be 100.0 and backward_pct SHALL be 100.0
And gap_count SHALL be 0 and orphan_count SHALL be 0
```

##### STS-002-B2: Gap detection for uncovered design ID
```
Given a matrix where REQ-003 has no test coverage rows
When coverage metrics are computed
Then gap_count SHALL be >= 1
And forward_pct SHALL be < 100.0
```

##### STS-002-B3: Status column preservation
```
Given a matrix with ✅ Passed and ❌ Failed status values
When the matrix is extracted
Then status values SHALL be preserved in the output
```

### SYS-003 — Hazard Summary Extractor

#### STP-003-A: Hazard entry extraction

| Field | Value |
|-------|-------|
| **Traces To** | SYS-003 |
| **Technique** | Equivalence Partitioning |
| **Precondition** | hazard-analysis.md with varying HAZ counts |

##### STS-003-A1: All HAZ entries extracted
```
Given a hazard-analysis.md with 5 HAZ entries
When the hazard extractor runs
Then 5 hazard records SHALL be returned with all fields populated
```

##### STS-003-A2: Missing hazard-analysis.md returns null
```
Given a V-Model directory without hazard-analysis.md
When the hazard extractor runs
Then the result SHALL be null/empty
```

##### STS-003-A3: Aggregate stats computed
```
Given a hazard-analysis.md with 5 HAZ entries, all mitigated, max residual Low
When the hazard extractor computes summary
Then total SHALL be 5, all_mitigated SHALL be true, max_residual SHALL be "Low"
```

### SYS-004 — Anomaly Detector

#### STP-004-A: Anomaly identification from matrix

| Field | Value |
|-------|-------|
| **Traces To** | SYS-004 |
| **Technique** | State Transition Testing |
| **Precondition** | Matrix with various test statuses |

##### STS-004-A1: Failed test detected as anomaly
```
Given a matrix row with status ❌ Failed for SCN-001-A2
When the anomaly detector scans the matrix
Then SCN-001-A2 SHALL appear as an anomaly with type "Failed Test"
```

##### STS-004-A2: Skipped test detected as anomaly
```
Given a matrix row with status ⏭️ Skipped for UTS-001-A1
When the anomaly detector scans the matrix
Then UTS-001-A1 SHALL appear as an anomaly with type "Skipped Test"
```

##### STS-004-A3: Passed and Untested not anomalies
```
Given a matrix with only ✅ Passed and ⬜ Untested statuses
When the anomaly detector scans the matrix
Then the anomaly list SHALL be empty
```

#### STP-004-B: Waiver cross-referencing

| Field | Value |
|-------|-------|
| **Traces To** | SYS-004 |
| **Technique** | Interface Contract Testing |
| **Precondition** | Anomalies and waivers present |

##### STS-004-B1: Waived anomaly matched
```
Given anomaly UTS-012-C2 and waiver WAV-001 with Artifact: UTS-012-C2
When cross-referencing runs
Then UTS-012-C2 SHALL have disposition "Waived" with reference WAV-001
```

##### STS-004-B2: Unwaived anomaly marked BLOCKING
```
Given anomaly SCN-001-A2 with no matching waiver
When cross-referencing runs
Then SCN-001-A2 SHALL have disposition "BLOCKING"
```

##### STS-004-B3: Orphaned waiver detected
```
Given waiver WAV-003 for UTS-999-A1 which has no corresponding anomaly
When cross-referencing runs
Then WAV-003 SHALL be listed as an orphaned waiver
```

### SYS-005 — Compliance Status Engine

#### STP-005-A: Status computation

| Field | Value |
|-------|-------|
| **Traces To** | SYS-005 |
| **Technique** | State Transition Testing |
| **Precondition** | Various anomaly configurations |

##### STS-005-A1: RELEASE READY when 0 anomalies
```
Given an empty anomaly list
When compliance status is computed
Then status SHALL be "✅ RELEASE READY" and exit_code SHALL be 0
```

##### STS-005-A2: RELEASE CANDIDATE when all waived
```
Given 2 anomalies both with disposition "Waived"
When compliance status is computed
Then status SHALL be "✅ RELEASE CANDIDATE" and exit_code SHALL be 0
```

##### STS-005-A3: NOT READY when any BLOCKING
```
Given 3 anomalies where 1 has disposition "BLOCKING"
When compliance status is computed
Then status SHALL be "❌ NOT READY" and exit_code SHALL be 1
```

##### STS-005-A4: Exit 2 for missing required artifacts
```
Given artifact discovery found no requirements.md
When compliance status is computed
Then exit_code SHALL be 2
```

### SYS-006 — Report Assembler

#### STP-006-A: Report section assembly

| Field | Value |
|-------|-------|
| **Traces To** | SYS-006 |
| **Technique** | Equivalence Partitioning |
| **Precondition** | All data collected from previous components |

##### STS-006-A1: All 7 sections present
```
Given complete data from all system components
When the report is assembled
Then the output SHALL contain sections 1 through 7
```

##### STS-006-A2: Executive summary contains metrics
```
Given computed metrics (47 REQs, 189 tests, 187 passed, 0 failed, 2 skipped)
When Section 1 is assembled
Then it SHALL contain all metric values
```

##### STS-006-A3: Report written to specified output path
```
Given --output /tmp/report.md
When the report assembler runs
Then the file /tmp/report.md SHALL exist with the full report
```

##### STS-006-A4: Summary printed to stderr
```
Given a completed report assembly
When the command finishes
Then a human-readable summary SHALL appear on stderr
```

### SYS-007 — JSON Serializer

#### STP-007-A: JSON output structure

| Field | Value |
|-------|-------|
| **Traces To** | SYS-007 |
| **Technique** | Interface Contract Testing |
| **Precondition** | --json flag provided |

##### STS-007-A1: Valid JSON output
```
Given the --json flag and complete audit data
When JSON serialization runs
Then the output SHALL be valid JSON parseable by any JSON parser
```

##### STS-007-A2: All top-level keys present
```
Given the --json flag
When JSON output is examined
Then it SHALL contain: compliance_status, artifacts, matrices, coverage, anomalies, metadata
```

##### STS-007-A3: Anomalies include waiver status in JSON
```
Given anomalies with mixed waiver status and --json flag
When JSON output is examined
Then each anomaly SHALL have id, type, and disposition fields
```
