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

### ARCH-010 — CLI Dispatch Orchestrator (Entry Point)

#### ITP-010-A: CLI entry point orchestrates full pipeline and propagates exit code

| Field | Value |
|-------|-------|
| **Traces To** | ARCH-010 |
| **Technique** | Interface Contract Testing |
| **Precondition** | Valid V-Model directory; standard CI toolchain (Bash 4+, Git, Python 3.x) available |

##### ITS-010-A1: Entry point invokes pipeline and returns exit code 0
```
Given ARCH-010 is invoked with a valid vmodel-dir and complete, passing V-Model artifacts
When the full orchestration pipeline completes without errors
Then ARCH-010 SHALL exit with code 0 (RELEASE READY or RELEASE CANDIDATE)
```

##### ITS-010-A2: Entry point propagates exit code 1 from compliance status
```
Given ARCH-010 is invoked with a V-Model directory containing BLOCKING anomalies
When ARCH-007 returns exit code 1 via compliance status
Then ARCH-010 SHALL propagate exit code 1 to the caller
```

##### ITS-010-A3: Entry point exits code 2 on missing required argument
```
Given ARCH-010 is invoked with no arguments
When ARCH-001 argument validation fails
Then ARCH-010 SHALL print usage to stderr and exit with code 2 without invoking downstream modules
```

---

## V&V Coverage Gate (IEEE 1012:2016 §5.6)

IEEE 1012:2016 §5.6 requires every architecture module interface to be exercised by at least one V&V activity. The table below maps every active ARCH-NNN module to its covering ITP-NNN-X test case(s), confirming 100% ARCH→ITP coverage at integration test level.

### ARCH→ITP Coverage Table

| ARCH Module | Module Name | V&V Activities (ITP) | Status |
|-------------|-------------|----------------------|--------|
| ARCH-001 | CLI Argument Parser | ITP-001-A | ✅ Covered |
| ARCH-002 | File Discovery Module | ITP-001-A, ITP-002-A | ✅ Covered |
| ARCH-003 | Matrix Parser Module | ITP-002-A, ITP-003-A | ✅ Covered |
| ARCH-004 | Hazard Parser Module | ITP-004-A | ✅ Covered |
| ARCH-005 | Anomaly Scanner Module | ITP-003-A, ITP-005-A | ✅ Covered |
| ARCH-006 | Waiver Parser Module | ITP-006-A | ✅ Covered |
| ARCH-007 | Cross-Reference Engine | ITP-005-A, ITP-006-A, ITP-007-A, ITP-009-A | ✅ Covered |
| ARCH-008 | Report Renderer Module | ITP-004-A, ITP-007-A, ITP-008-A | ✅ Covered |
| ARCH-009 | JSON Output Module | ITP-009-A | ✅ Covered |
| ARCH-010 | CLI Dispatch Orchestrator | ITP-008-A, ITP-010-A | ✅ Covered |

**V&V Gap Summary**: No gaps — all 10 active ARCH-NNN modules have at least one integration-level V&V activity (ITP-NNN-X). IEEE 1012:2016 §5.6 entry criterion satisfied.

### Entry Criteria (IEEE 1012:2016 §5.6.1)

| Criterion | Status |
|-----------|--------|
| `architecture-design.md` is current and peer-reviewed | ✅ Met |
| Every `ARCH-NNN` module has at least one `ITP-NNN-X` test case (100% forward coverage) | ✅ Met — 10/10 (100%) |
| All `ITP-NNN-X` test cases have at least one `ITS-NNN-X#` executable scenario | ✅ Met — all ITPs have at least one ITS |
| V&V gap list is empty (all integration boundaries covered) | ✅ Met — 0 gaps |

**Verdict**: ✅ PASS — IEEE 1012:2016 §5.6 V&V completeness requirements satisfied at integration test level.
