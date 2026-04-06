# V-Model Integration Test Plan: Release Audit Report

**Feature Branch**: `feature/005e-audit-report`
**Created**: 2026-04-05
**Status**: Approved
**Source**: `specs/005e-audit-report/v-model/architecture-design.md`

## Overview

This document defines integration test procedures (ITP) and test steps (ITS) for architecture module interactions, using ISO 29119-4 integration techniques.

## Test Procedures

### ARCH-001 ↔ ARCH-002 — CLI Parser feeds File Discovery

#### ITP-001-A: Parsed arguments flow to artifact discovery

| Field | Value |
|-------|-------|
| **Traces To** | ARCH-001, ARCH-002 |
| **Technique** | Interface Contract Testing |
| **Precondition** | Valid V-Model directory provided as argument |

##### ITS-001-A1: Valid vmodel-dir passed to discovery module
```
Given ARCH-001 parses "--system-name CBGMS ./v-model-dir"
When the validated vmodel_dir is passed to ARCH-002
Then ARCH-002 SHALL receive "./v-model-dir" and discover artifacts
```

##### ITS-001-A2: Invalid vmodel-dir rejected before discovery
```
Given ARCH-001 receives a non-existent directory path
When ARCH-001 validates the argument
Then ARCH-002 SHALL NOT be invoked and script exits with code 2
```

### ARCH-002 ↔ ARCH-003 — File Discovery feeds Matrix Parser

#### ITP-002-A: Discovery finds matrix file for parser

| Field | Value |
|-------|-------|
| **Traces To** | ARCH-002, ARCH-003 |
| **Technique** | Interface Contract Testing |
| **Precondition** | V-Model directory with traceability-matrix.md |

##### ITS-002-A1: Matrix parser receives discovered file path
```
Given ARCH-002 discovers traceability-matrix.md
When the path is passed to ARCH-003
Then ARCH-003 SHALL successfully parse all matrix sections
```

##### ITS-002-A2: Missing matrix file handled gracefully
```
Given ARCH-002 does not find traceability-matrix.md
When ARCH-003 is invoked with null path
Then ARCH-003 SHALL return empty matrix data without error
```

### ARCH-003 ↔ ARCH-005 — Matrix Parser feeds Anomaly Scanner

#### ITP-003-A: Parsed matrix data flows to anomaly scanner

| Field | Value |
|-------|-------|
| **Traces To** | ARCH-003, ARCH-005 |
| **Technique** | Data Flow Testing |
| **Precondition** | Matrix with mixed test statuses |

##### ITS-003-A1: Anomaly scanner receives all matrix rows
```
Given ARCH-003 extracts 50 matrix rows with mixed statuses
When passed to ARCH-005
Then ARCH-005 SHALL scan all 50 rows for anomalies
```

##### ITS-003-A2: Status values preserved across interface
```
Given ARCH-003 extracts a row with ❌ Failed status
When passed to ARCH-005
Then ARCH-005 SHALL correctly identify it as a Failed anomaly
```

### ARCH-005 ↔ ARCH-007 — Anomaly Scanner feeds Cross-Reference

#### ITP-005-A: Anomaly list joined with waiver map

| Field | Value |
|-------|-------|
| **Traces To** | ARCH-005, ARCH-007 |
| **Technique** | Interface Contract Testing |
| **Precondition** | Anomalies and waivers both present |

##### ITS-005-A1: Waived anomalies correctly classified
```
Given ARCH-005 produces anomaly SCN-001-A2 and ARCH-006 produces waiver WAV-001 for SCN-001-A2
When ARCH-007 cross-references them
Then SCN-001-A2 SHALL have disposition "Waived"
```

##### ITS-005-A2: Unwaived anomalies correctly classified
```
Given ARCH-005 produces anomaly UTS-001-A1 with no matching waiver
When ARCH-007 cross-references
Then UTS-001-A1 SHALL have disposition "BLOCKING"
```

### ARCH-006 ↔ ARCH-007 — Waiver Parser feeds Cross-Reference

#### ITP-006-A: Waiver map integrity through cross-reference

| Field | Value |
|-------|-------|
| **Traces To** | ARCH-006, ARCH-007 |
| **Technique** | Data Flow Testing |
| **Precondition** | Waivers with and without matching anomalies |

##### ITS-006-A1: Orphaned waiver detected in cross-reference
```
Given ARCH-006 produces waiver WAV-003 for UTS-999-A1 which is not in the anomaly list
When ARCH-007 cross-references
Then WAV-003 SHALL appear in orphaned_waivers list
```

### ARCH-007 ↔ ARCH-008 — Cross-Reference feeds Report Renderer

#### ITP-007-A: Compliance status flows to report

| Field | Value |
|-------|-------|
| **Traces To** | ARCH-007, ARCH-008 |
| **Technique** | Interface Contract Testing |
| **Precondition** | Cross-reference complete with status |

##### ITS-007-A1: RELEASE READY status in executive summary
```
Given ARCH-007 computes status ✅ RELEASE READY
When ARCH-008 renders the report
Then Section 1 SHALL contain "RELEASE READY"
```

##### ITS-007-A2: NOT READY status with blocking anomalies in Section 6
```
Given ARCH-007 identifies 2 BLOCKING anomalies
When ARCH-008 renders the report
Then Section 6 SHALL list 2 anomalies with disposition "BLOCKING"
And Section 1 SHALL contain "NOT READY"
```

### ARCH-007 ↔ ARCH-009 — Cross-Reference feeds JSON Output

#### ITP-009-A: JSON output includes cross-reference results

| Field | Value |
|-------|-------|
| **Traces To** | ARCH-007, ARCH-009 |
| **Technique** | Interface Contract Testing |
| **Precondition** | --json flag active, cross-reference complete |

##### ITS-009-A1: JSON contains classified anomalies
```
Given ARCH-007 produces 3 classified anomalies (2 Waived, 1 BLOCKING)
When ARCH-009 serializes to JSON
Then the anomalies array SHALL contain 3 entries with correct dispositions
```

### ARCH-004 ↔ ARCH-008 — Hazard Parser feeds Report Renderer

#### ITP-004-A: Hazard summary embedded in report

| Field | Value |
|-------|-------|
| **Traces To** | ARCH-004, ARCH-008 |
| **Technique** | Data Flow Testing |
| **Precondition** | hazard-analysis.md present with HAZ entries |

##### ITS-004-A1: Hazard table rendered in Section 5
```
Given ARCH-004 extracts 5 HAZ entries
When ARCH-008 renders Section 5
Then the hazard table SHALL contain 5 rows with all fields
```

##### ITS-004-A2: No hazard section when no hazard data
```
Given ARCH-004 returns null (no hazard-analysis.md)
When ARCH-008 renders Section 5
Then Section 5 SHALL indicate no hazard analysis was performed
```

### End-to-End Pipeline — All Modules

#### ITP-008-A: Full pipeline from CLI to report output

| Field | Value |
|-------|-------|
| **Traces To** | ARCH-001 through ARCH-009 |
| **Technique** | Interface Contract Testing |
| **Precondition** | Complete V-Model directory |

##### ITS-008-A1: Clean project produces RELEASE READY report
```
Given a complete V-Model directory with all tests passed, no anomalies
When the full pipeline runs
Then a release-audit-report.md SHALL be generated with ✅ RELEASE READY
And the exit code SHALL be 0
```

##### ITS-008-A2: Blocking project produces NOT READY report
```
Given a V-Model directory with 1 failed test and no waivers
When the full pipeline runs
Then a release-audit-report.md SHALL be generated with ❌ NOT READY
And the exit code SHALL be 1
```
