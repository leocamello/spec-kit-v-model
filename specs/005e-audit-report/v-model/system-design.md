# V-Model System Design: Release Audit Report

**Feature Branch**: `feature/005e-audit-report`
**Created**: 2026-04-05
**Status**: Approved
**Source**: `specs/005e-audit-report/v-model/requirements.md`

## Overview

This document decomposes the audit-report requirements into system-level components following IEEE 1016. The system is 100% deterministic (script-only, no AI) and assembles a monolithic audit report from V-Model artifacts.

## Decomposition View

| SYS ID | Name | Description | Parent Requirements | Type |
|--------|------|-------------|---------------------|------|
| SYS-001 | Artifact Discovery Engine | Enumerates V-Model artifacts and extracts Git metadata | REQ-001, REQ-002, REQ-003 | Module |
| SYS-002 | Matrix Extractor | Parses traceability-matrix.md into structured sections with coverage metrics | REQ-004, REQ-005 | Module |
| SYS-003 | Hazard Summary Extractor | Parses hazard-analysis.md FMEA table to extract HAZ-NNN entries | REQ-006 | Module |
| SYS-004 | Anomaly Detector | Identifies failed/skipped tests and cross-references with waivers | REQ-007, REQ-008, REQ-009, REQ-019 | Module |
| SYS-005 | Compliance Status Engine | Computes release status from anomaly disposition | REQ-010, REQ-015, REQ-016, REQ-017 | Module |
| SYS-006 | Report Assembler | Renders 7-section Markdown report from collected data | REQ-011, REQ-012, REQ-013, REQ-014, REQ-020 | Module |
| SYS-007 | JSON Serializer | Serializes audit data to JSON when --json flag is active | REQ-018 | Module |

## System Components

### SYS-001 — Artifact Discovery Engine

| Field | Value |
|-------|-------|
| **Traces To** | REQ-001, REQ-002, REQ-003 |
| **Description** | Discovers all V-Model artifact files in the given directory, extracts Git metadata (SHA, date) for each, and produces the Artifact Inventory table (Section 2). |

**Decomposition View**: Scans the V-Model directory for known filenames (requirements.md, acceptance-plan.md, etc.). For each found file, calls `git log -1 --format='%h %aI'` to get the abbreviated SHA and commit date.

**Interface**: Accepts a directory path. Returns an array of `{name, file, sha, date, status}` objects.

**Data Design**: Artifact record: `{artifact_name: string, file_path: string, git_sha: string(7), last_modified: date, status: "Present"}`.

### SYS-002 — Matrix Extractor

| Field | Value |
|-------|-------|
| **Traces To** | REQ-004, REQ-005 |
| **Description** | Reads traceability-matrix.md, identifies matrix sections (A, B, C, D, H), extracts table data, computes forward/backward coverage metrics, gap counts, and orphan counts. |

**Decomposition View**: Parses traceability-matrix.md line-by-line. Identifies `## Matrix X` headings to split into individual matrices. For each matrix, extracts header row and data rows. Counts design IDs with tests (forward), test IDs with parents (backward), gaps (design IDs without tests), and orphans (test IDs without parents).

**Interface**: Accepts the matrix file path. Returns `{matrices: [{id, headers, rows, coverage: {forward, backward, gaps, orphans}}]}`.

**Data Design**: Matrix row: `{columns: string[], status: string?, date: string?, commit: string?, coverage: string?}`. Coverage metrics: `{forward_pct: float, backward_pct: float, gap_count: int, orphan_count: int}`.

### SYS-003 — Hazard Summary Extractor

| Field | Value |
|-------|-------|
| **Traces To** | REQ-006 |
| **Description** | Parses hazard-analysis.md to extract all HAZ-NNN entries with their Failure Mode, Severity, Likelihood, Risk Level, Mitigation, and Residual Risk for the Hazard Management Summary (Section 5). |

**Decomposition View**: Reads hazard-analysis.md, finds the FMEA table, parses each row extracting HAZ ID and all columns. Produces a summary table and aggregate statistics (total hazards, max residual risk, all-mitigated flag).

**Interface**: Accepts the hazard-analysis.md file path (may be null if absent). Returns `{hazards: [{id, failure_mode, severity, likelihood, risk, mitigation, residual}], summary: {total, max_residual, all_mitigated}}` or null.

### SYS-004 — Anomaly Detector

| Field | Value |
|-------|-------|
| **Traces To** | REQ-007, REQ-008, REQ-009, REQ-019 |
| **Description** | Scans traceability matrices for failed/skipped tests, optionally scans peer-review files for Critical/Major findings, parses waivers.md for WAV-NNN entries, and cross-references anomalies against waivers to classify each as Waived, BLOCKING, or Orphaned. |

**Decomposition View**:
1. Scan matrix rows for `❌ Failed` and `⏭️ Skipped` status values → anomaly list
2. Optionally scan `peer-review-*.md` files for `### PRF-` findings with Critical/Major severity → append to anomaly list
3. Parse `waivers.md` for `### WAV-NNN` headings → extract `**Artifact**:` field → waiver map
4. Cross-reference: for each anomaly, check if waiver map contains its ID → Waived or BLOCKING
5. Identify orphaned waivers: waiver IDs not matching any anomaly

**Interface**: Accepts matrix data, peer-review file paths, waivers.md path. Returns `{anomalies: [{id, type, matrix, disposition, waiver_ref}], orphaned_waivers: [{wav_id, artifact_id}]}`.

### SYS-005 — Compliance Status Engine

| Field | Value |
|-------|-------|
| **Traces To** | REQ-010, REQ-015, REQ-016, REQ-017 |
| **Description** | Computes the final compliance status from the anomaly classification and determines the exit code. |

**Decomposition View**:
- If required artifacts missing → `exit 2`, status N/A
- If zero anomalies → `✅ RELEASE READY`, exit 0
- If all anomalies have waivers → `✅ RELEASE CANDIDATE`, exit 0
- If any BLOCKING anomalies → `❌ NOT READY`, exit 1

**Interface**: Accepts anomaly list and artifact discovery results. Returns `{status: string, exit_code: int, blocking_count: int, waived_count: int}`.

### SYS-006 — Report Assembler

| Field | Value |
|-------|-------|
| **Traces To** | REQ-011, REQ-012, REQ-013, REQ-014, REQ-020 |
| **Description** | Takes all collected data (artifact inventory, matrices, coverage, hazard summary, anomalies, compliance status, metadata) and assembles the final `release-audit-report.md` from the template. Also prints the human-readable summary to stderr. |

**Decomposition View**: Reads the template. For each section placeholder, substitutes computed data:
1. Executive Summary — fill system name, version, tag, date, context, computed metrics, compliance status
2. Artifact Inventory — render artifact table
3. Traceability Matrices — embed extracted matrices
4. Coverage Analysis — render coverage metrics table
5. Hazard Management Summary — render hazard table (or "N/A" message)
6. Known Anomalies — render anomaly table with disposition column
7. Signature Block — fill tag, SHA, date, blank signature lines

**Interface**: Accepts all computed data + metadata arguments + output path. Writes the report file. Prints summary to stderr.

### SYS-007 — JSON Serializer

| Field | Value |
|-------|-------|
| **Traces To** | REQ-018 |
| **Description** | When --json flag is provided, serializes all collected data into a structured JSON object and outputs it to stdout. |

**Decomposition View**: Collects all data structures from SYS-001 through SYS-005 into a single JSON object with keys: `compliance_status`, `artifacts`, `matrices`, `coverage`, `hazards`, `anomalies`, `orphaned_waivers`, `metadata`.

**Interface**: Accepts all computed data. Returns JSON string to stdout.

## Dependency View

```
SYS-001 (Artifact Discovery) ──┐
SYS-002 (Matrix Extractor) ────┤
SYS-003 (Hazard Extractor) ────┼──→ SYS-004 (Anomaly Detector) ──→ SYS-005 (Compliance Status)
                                │                                           │
                                └──→ SYS-006 (Report Assembler) ←──────────┘
                                     SYS-007 (JSON Serializer) ←───────────┘
```

## Interface View

| From | To | Interface |
|------|----|-----------|
| CLI | SYS-001 | V-Model directory path |
| CLI | SYS-006 | Metadata arguments (--system-name, --version, --git-tag, --regulatory-context, --output) |
| CLI | SYS-007 | --json flag |
| SYS-001 | SYS-006 | Artifact inventory array |
| SYS-002 | SYS-004 | Matrix data with status columns |
| SYS-002 | SYS-006 | Coverage metrics per matrix |
| SYS-003 | SYS-006 | Hazard summary data |
| SYS-004 | SYS-005 | Anomaly list with waiver cross-reference |
| SYS-005 | SYS-006 | Compliance status + exit code |
| All | SYS-007 | Complete data structures for JSON serialization |
