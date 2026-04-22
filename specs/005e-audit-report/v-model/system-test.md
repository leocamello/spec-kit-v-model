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

### SYS-008 — CLI Entry Point

#### STP-008-A: Bash CLI argument parsing

| Field | Value |
|-------|-------|
| **Traces To** | SYS-008 |
| **Technique** | Interface Contract Testing |
| **Precondition** | Bash 4+ available; valid V-Model directory |

##### STS-008-A1: Positional vmodel-dir argument accepted
```
Given build-audit-report.sh invoked with a valid V-Model directory path as the first positional argument
When the script starts
Then the directory SHALL be used as the primary input with no error
```

##### STS-008-A2: All named arguments accepted
```
Given build-audit-report.sh invoked with --system-name "Sys" --version "1.0" --git-tag "v1.0" --regulatory-context "ISO 9001" --output "report.md" --json
When the script starts
Then all argument values SHALL be parsed and passed to internal components without error
```

##### STS-008-A3: Missing required argument exits 2 with usage
```
Given build-audit-report.sh invoked with no arguments
When the script starts
Then exit code SHALL be 2 and a usage message SHALL appear on stderr
```

#### STP-008-B: PowerShell CLI parameter parsing

| Field | Value |
|-------|-------|
| **Traces To** | SYS-008 |
| **Technique** | Interface Contract Testing |
| **Precondition** | PowerShell 7+ available; valid V-Model directory |

##### STS-008-B1: PowerShell parameters accepted with idiomatic naming
```
Given Build-Audit-Report.ps1 invoked with -VModelDir <path> -SystemName "Sys" -Version "1.0" -GitTag "v1.0" -RegulatoryContext "ISO 9001" -Output "report.md" -Json
When the script starts
Then all parameter values SHALL be parsed and produce equivalent behaviour to the Bash implementation
```

##### STS-008-B2: Standard toolchain only — no external dependencies
```
Given a clean CI runner with only Bash 4+, Git, and Python 3.x standard library
When build-audit-report.sh runs to completion
Then it SHALL succeed without installing any packages or invoking any tool outside the standard toolchain
```

---

## V&V Coverage Gate (IEEE 1012:2016 §5.5)

IEEE 1012:2016 §5.5 requires every system component to be exercised by at least one V&V activity. The table below maps every active SYS-NNN component to its covering STP-NNN test case(s), confirming 100% SYS→STP coverage.

### SYS→STP Coverage Table

| SYS | Component Name | V&V Method | Assigned STPs | Status |
|-----|----------------|-----------|---------------|--------|
| SYS-001 | Artifact Discovery Engine | Test | STP-001-A, STP-001-B | ✅ Covered |
| SYS-002 | Matrix Extractor | Test | STP-002-A, STP-002-B | ✅ Covered |
| SYS-003 | Hazard Summary Extractor | Test | STP-003-A | ✅ Covered |
| SYS-004 | Anomaly Detector | Test | STP-004-A, STP-004-B | ✅ Covered |
| SYS-005 | Compliance Status Engine | Test | STP-005-A | ✅ Covered |
| SYS-006 | Report Assembler | Test | STP-006-A | ✅ Covered |
| SYS-007 | JSON Serializer | Test | STP-007-A | ✅ Covered |
| SYS-008 | CLI Entry Point | Test + Inspection | STP-008-A, STP-008-B | ✅ Covered |

**V&V Gap Report**: No V&V gaps — all 8 active SYS-NNN components have at least one system-level test (STP-NNN-X). IEEE 1012:2016 §5.5 entry criterion satisfied.

### REQ→STP Requirement Coverage Table

The table below traces every active requirement from `requirements.md` to the system test(s) that exercise it, confirming bidirectional requirements coverage at system test level.

| REQ | Verification Method | Via SYS | Covering STPs | Status |
|-----|---------------------|---------|---------------|--------|
| REQ-001 | Test | SYS-001 | STP-001-A | ✅ Covered |
| REQ-002 | Test | SYS-001 | STP-001-B | ✅ Covered |
| REQ-003 | Test | SYS-001 | STP-001-A | ✅ Covered |
| REQ-004 | Test | SYS-002 | STP-002-A | ✅ Covered |
| REQ-005 | Test | SYS-002 | STP-002-B | ✅ Covered |
| REQ-006 | Test | SYS-003 | STP-003-A | ✅ Covered |
| REQ-007 | Test | SYS-004 | STP-004-A | ✅ Covered |
| REQ-008 | Test | SYS-004 | STP-004-A, STP-004-B | ✅ Covered |
| REQ-009 | Test | SYS-004 | STP-004-B | ✅ Covered |
| REQ-010 | Test | SYS-005 | STP-005-A | ✅ Covered |
| REQ-011 | Test | SYS-006 | STP-006-A | ✅ Covered |
| REQ-012 | Test | SYS-006 | STP-006-A | ✅ Covered |
| REQ-013 | Test | SYS-008 | STP-008-A | ✅ Covered |
| REQ-014 | Test | SYS-008 | STP-008-A | ✅ Covered |
| REQ-015 | Test | SYS-005 | STP-005-A | ✅ Covered |
| REQ-016 | Test | SYS-005 | STP-005-A | ✅ Covered |
| REQ-017 | Test | SYS-005 | STP-005-A | ✅ Covered |
| REQ-018 | Test | SYS-007 | STP-007-A | ✅ Covered |
| REQ-019 | Test | SYS-004 | STP-004-B | ✅ Covered |
| REQ-020 | Test | SYS-006 | STP-006-A | ✅ Covered |
| REQ-NF-001 | Test | — | No dedicated STP at system test level | ⚠️ Gap — covered at acceptance level by ATP-NF-001-A (SCN-NF-001-A1 tests determinism via byte-identical runs) |
| REQ-NF-002 | Inspection | SYS-008 | STP-008-B (STS-008-B2) | ✅ Covered — standard toolchain enforcement inspected |
| REQ-NF-003 | Test | — | No dedicated STP at system test level | ⚠️ Gap — 30-second performance bound not exercised by any current STP; recommend adding STP-009-A performance test |
| REQ-IF-001 | Test | SYS-008 | STP-008-A | ✅ Covered |
| REQ-IF-002 | Test | SYS-008 | STP-008-B | ✅ Covered |
| REQ-CN-001 | Inspection | SYS-008 | STP-008-B (STS-008-B2) | ✅ Covered — no-external-dependency check implies no AI invocations |
| REQ-CN-002 | Inspection | — | No dedicated STP | ⚠️ Gap — read-only behaviour (no artifact modification) is an Inspection-method requirement; recommend adding an inspection check confirming no artifact files are modified during a test run |
| REQ-CN-003 | Inspection | SYS-004 | STP-004-B | ✅ Covered — waiver format parsing exercised by cross-referencing tests |

### V&V Gap Summary

| Gap # | Requirement | Gap Description | Recommended Action |
|-------|-------------|----------------|-------------------|
| 1 | REQ-NF-001 | Deterministic output is not verified at system test level (only at acceptance test level by ATP-NF-001-A) | Add `STP-NF-001-A` to this document: run command twice with same inputs, diff outputs with `diff --brief` |
| 2 | REQ-NF-003 | 30-second performance bound is not exercised at system test level | Add `STP-NF-003-A` to this document: time the command against a 500-ID test fixture; assert wall-clock < 30s |
| 3 | REQ-CN-002 | Read-only behaviour (no artifact modification) lacks a dedicated STP or inspection step | Add an inspection scenario to `STP-008-A` verifying that no V-Model artifacts are modified after a run (compare mtimes before/after) |

### Entry Criteria Check (IEEE 1012:2016 §5.5.1)

| Criterion | Result |
|-----------|--------|
| `system-design.md` is current and peer-reviewed | ✅ Satisfied |
| Every active `SYS-NNN` has at least one `STP-NNN-X` (100% SYS→STP coverage) | ✅ 8 / 8 (100%) |
| All `STP-NNN-X` have at least one `STS-NNN-X#` executable scenario | ✅ All STPs have at least one STS |
| V&V gaps documented and risk-accepted | ✅ 3 gaps documented above; none block certification — all are testability improvements, not safety risks |
