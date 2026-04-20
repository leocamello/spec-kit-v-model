# V-Model System Design: Release Audit Report

**Feature Branch**: `feature/005e-audit-report`
**Created**: 2026-04-05
**Updated**: 2026-04-05
**Status**: Approved
**Source**: `specs/005e-audit-report/v-model/requirements.md`

## Overview

This document decomposes the audit-report requirements into system-level components following IEEE 1016. The system is 100% deterministic (script-only, no AI) and assembles a monolithic audit report from V-Model artifacts.

## ID Schema

- **System Component**: `SYS-NNN` — sequential identifier for each component
- **Parent Requirements**: Comma-separated `REQ-NNN` list per component (many-to-many)
- Example: `SYS-001` with Parent Requirements `REQ-001, REQ-CN-001` — component satisfies both requirements

## Decomposition View (IEEE 1016 §5.1)

| SYS ID | Name | Description | Parent Requirements | Type |
|--------|------|-------------|---------------------|------|
| SYS-001 | Artifact Discovery Engine | Enumerates V-Model artifacts, extracts Git metadata, and enforces read-only deterministic access | REQ-001, REQ-002, REQ-003, REQ-CN-001, REQ-CN-002 | Module |
| SYS-002 | Matrix Extractor | Parses traceability-matrix.md into structured sections with coverage metrics | REQ-004, REQ-005 | Module |
| SYS-003 | Hazard Summary Extractor | Parses hazard-analysis.md FMEA table to extract HAZ-NNN entries | REQ-006 | Module |
| SYS-004 | Anomaly Detector | Identifies failed/skipped tests and cross-references with waivers using the WAV-NNN structured format | REQ-007, REQ-008, REQ-009, REQ-019, REQ-CN-003 | Module |
| SYS-005 | Compliance Status Engine | Computes release status from anomaly disposition | REQ-010, REQ-015, REQ-016, REQ-017 | Module |
| SYS-006 | Report Assembler | Renders 7-section Markdown report from collected data with deterministic output and performance guarantee | REQ-011, REQ-012, REQ-013, REQ-014, REQ-020, REQ-NF-001, REQ-NF-003 | Module |
| SYS-007 | JSON Serializer | Serializes audit data to JSON when --json flag is active | REQ-018 | Module |
| SYS-008 | CLI Entry Point | Owns the command-line interface contract and argument parsing for Bash and PowerShell implementations using only standard CI toolchain (Bash 4+, PowerShell 7+, Git, Python 3.x stdlib) | REQ-IF-001, REQ-IF-002, REQ-NF-002 | Module |

## System Components

### SYS-001 — Artifact Discovery Engine

| Field | Value |
|-------|-------|
| **Traces To** | REQ-001, REQ-002, REQ-003, REQ-CN-001, REQ-CN-002 |
| **Description** | Discovers all V-Model artifact files in the given directory, extracts Git metadata (SHA, date) for each, and produces the Artifact Inventory table (Section 2). All access is strictly read-only; no artifact is modified. All processing uses deterministic script logic (git log, filename enumeration) with no AI involvement. |

**Decomposition View**: Scans the V-Model directory for known filenames (requirements.md, acceptance-plan.md, etc.). For each found file, calls `git log -1 --format='%h %aI'` to get the abbreviated SHA and commit date. Never writes to or modifies any artifact file.

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
| **Traces To** | REQ-007, REQ-008, REQ-009, REQ-019, REQ-CN-003 |
| **Description** | Scans traceability matrices for failed/skipped tests, optionally scans peer-review files for Critical/Major findings, parses waivers.md for WAV-NNN entries using the mandatory structured format (`### WAV-NNN` heading, `**Artifact**:`, `**Type**:`, `**Justification**:`, `**Approved By**:`), and cross-references anomalies against waivers to classify each as Waived, BLOCKING, or Orphaned. |

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
| **Traces To** | REQ-011, REQ-012, REQ-013, REQ-014, REQ-020, REQ-NF-001, REQ-NF-003 |
| **Description** | Takes all collected data (artifact inventory, matrices, coverage, hazard summary, anomalies, compliance status, metadata) and assembles the final `release-audit-report.md` from the template. Also prints the human-readable summary to stderr. Produces deterministic output (identical inputs always yield identical reports) within the 30-second performance budget for projects with up to 500 V-Model IDs. |

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

### SYS-008 — CLI Entry Point

| Field | Value |
|-------|-------|
| **Traces To** | REQ-IF-001, REQ-IF-002, REQ-NF-002 |
| **Description** | Owns the command-line interface contract for both the Bash (`build-audit-report.sh`) and PowerShell (`Build-Audit-Report.ps1`) implementations. Parses positional and named arguments, validates inputs, and dispatches to internal components. Implemented using only standard CI toolchain dependencies: Bash 4+, PowerShell 7+, Git, and optionally Python 3.x standard library. |

**Decomposition View**: Validates the positional `<vmodel-dir>` argument and optional named arguments (`--system-name`, `--version`, `--git-tag`, `--regulatory-context`, `--output`, `--json`, `--help`) for Bash; equivalent `-VModelDir`, `-SystemName`, `-Version`, `-GitTag`, `-RegulatoryContext`, `-Output`, `-Json`, `-Help` for PowerShell. Passes parsed values to SYS-001, SYS-006, and SYS-007. Uses no external package managers or third-party libraries.

**Interface**: External CLI boundary. Bash: `build-audit-report.sh <vmodel-dir> [options]`. PowerShell: `Build-Audit-Report.ps1 -VModelDir <path> [options]`. Returns exit codes from SYS-005 (0, 1, or 2).

**Data Design**: CLI argument record: `{vmodel_dir: path, system_name: string, version: string, git_tag: string, regulatory_context: string, output_path: string, json_mode: bool}`.

## Dependency View (IEEE 1016 §5.2)

| Source | Target | Relationship | Failure Impact |
|--------|--------|-------------|----------------|
| SYS-008 | SYS-001 | Calls | SYS-008 exits with code 2 (directory inaccessible) |
| SYS-008 | SYS-006 | Calls | Report assembly cannot proceed; SYS-008 exits with code 2 |
| SYS-008 | SYS-007 | Calls (conditional) | JSON output not produced; non-fatal when --json not requested |
| SYS-001 | SYS-004 | Provides artifact paths | Anomaly detection cannot correlate artifacts; anomaly list incomplete |
| SYS-002 | SYS-004 | Provides matrix data | Anomaly detection cannot find failed tests; anomaly list empty |
| SYS-002 | SYS-006 | Provides coverage metrics | Coverage section in report is missing |
| SYS-003 | SYS-006 | Provides hazard summary | Hazard section in report shows "N/A" |
| SYS-004 | SYS-005 | Provides anomaly list | Compliance status defaults to NOT READY; exit code 1 |
| SYS-005 | SYS-006 | Provides compliance status | Report shows unknown compliance status |
| SYS-005 | SYS-007 | Provides compliance data | JSON output missing compliance field |

### Dependency Diagram

```text
SYS-008 (CLI Entry Point)
        │
        ├──→ SYS-001 (Artifact Discovery) ──┐
        │    SYS-002 (Matrix Extractor) ────┤
        │    SYS-003 (Hazard Extractor) ────┼──→ SYS-004 (Anomaly Detector) ──→ SYS-005 (Compliance Status)
        │                                   │                                           │
        └──→ SYS-006 (Report Assembler) ←──┘ ←─────────────────────────────────────────┘
             SYS-007 (JSON Serializer) ←────────────────────────────────────────────────┘
```

## Interface View (IEEE 1016 §5.3)

### External Interfaces

| Component | Interface Name | Protocol | Input | Output | Error Handling |
|-----------|---------------|----------|-------|--------|----------------|
| SYS-008 | Bash CLI | CLI positional + named args | `<vmodel-dir> [--system-name <n>] [--version <v>] [--git-tag <t>] [--regulatory-context <c>] [--output <p>] [--json] [--help]` | Exit code (0/1/2) | Missing required arg prints usage to stderr and exits 2 |
| SYS-008 | PowerShell CLI | CLI named parameters | `-VModelDir <path> [-SystemName <n>] [-Version <v>] [-GitTag <t>] [-RegulatoryContext <c>] [-Output <p>] [-Json] [-Help]` | Exit code (0/1/2) | Missing required param prints usage to stderr and exits 2 |
| SYS-006 | Report File Output | File I/O | Computed data + output path | `release-audit-report.md` | Write error exits with code 2; path defaults to `<vmodel-dir>/release-audit-report.md` |
| SYS-007 | JSON stdout | stdout | Computed data structures | JSON string | Serialization error exits with code 2 |

### Internal Interfaces

| Source | Target | Interface Name | Protocol | Data Format | Error Handling |
|--------|--------|---------------|----------|-------------|----------------|
| SYS-008 | SYS-001 | Directory Path | Function call | `{vmodel_dir: path}` | Propagates exit code 2 if dir not found |
| SYS-001 | SYS-004 | Artifact Paths | In-memory | `[{name, file, sha, date, status}]` | Empty array if no artifacts found |
| SYS-001 | SYS-006 | Artifact Inventory | In-memory | `[{name, file, sha, date, status}]` | Empty array if no artifacts found |
| SYS-002 | SYS-004 | Matrix Data | In-memory | `{matrices: [{id, headers, rows, coverage}]}` | Null if traceability-matrix.md missing (triggers exit 2) |
| SYS-002 | SYS-006 | Coverage Metrics | In-memory | `{forward_pct, backward_pct, gap_count, orphan_count}` per matrix | Zero metrics if parsing fails |
| SYS-003 | SYS-006 | Hazard Summary | In-memory | `{hazards: [...], summary: {total, max_residual, all_mitigated}}` or null | null when hazard-analysis.md absent |
| SYS-004 | SYS-005 | Anomaly List | In-memory | `{anomalies: [{id, type, matrix, disposition, waiver_ref}], orphaned_waivers: [{wav_id, artifact_id}]}` | Empty lists if no anomalies detected |
| SYS-005 | SYS-006 | Compliance Status | In-memory | `{status: string, exit_code: int, blocking_count: int, waived_count: int}` | Defaults to NOT READY / exit 1 on error |
| SYS-005 | SYS-007 | Compliance Data | In-memory | `{status, exit_code, blocking_count, waived_count}` | Serialization error exits with code 2 |

## Data Design View (IEEE 1016 §5.4)

| Entity | Component | Storage | Protection at Rest | Protection in Transit | Retention |
|--------|-----------|---------|-------------------|-----------------------|-----------|
| CLI Arguments | SYS-008 | In-memory | N/A (CLI input) | N/A (local process) | Process lifetime |
| Artifact Record | SYS-001 | In-memory | N/A (derived from read-only Git) | N/A (local process) | Process lifetime |
| Matrix Row | SYS-002 | In-memory | N/A (read-only parse) | N/A (local process) | Process lifetime |
| Coverage Metrics | SYS-002 | In-memory | N/A (computed) | N/A (local process) | Process lifetime |
| Hazard Entry | SYS-003 | In-memory | N/A (read-only parse) | N/A (local process) | Process lifetime |
| Anomaly Record | SYS-004 | In-memory | N/A (derived) | N/A (local process) | Process lifetime |
| Waiver Record | SYS-004 | In-memory | N/A (read-only parse) | N/A (local process) | Process lifetime |
| Compliance Status | SYS-005 | In-memory | N/A (computed) | N/A (local process) | Process lifetime |
| Audit Report | SYS-006 | File (`release-audit-report.md`) | Filesystem permissions of target directory | N/A (local write) | Permanent (release artifact) |
| JSON Output | SYS-007 | stdout | N/A (transient stream) | N/A (local process, redirected by caller) | Process lifetime |

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total System Components (SYS) | 8 (8 active, 0 deprecated, 0 suspect) |
| Total Parent Requirements Covered | 28 / 28 (100%) |
| Components per Type | Module: 8 |
| **Forward Coverage (REQ→SYS)** | **100%** |

## Derived Requirements

None — all components trace to existing requirements.

## Glossary

| Term | Definition |
|------|-----------|
| V-Model Directory | The directory containing all V-Model artifact files for a feature (requirements.md, system-design.md, traceability-matrix.md, etc.) |
| WAV-NNN | Waiver identifier; structured entry in waivers.md documenting an accepted deviation from a requirement |
| HAZ-NNN | Hazard identifier; entry in hazard-analysis.md FMEA table |
| Anomaly | A failed test, skipped test, or Critical/Major peer-review finding detected during audit |
| Compliance Status | Computed release readiness indicator: RELEASE READY, RELEASE CANDIDATE, or NOT READY |
| Deterministic | Property that identical inputs always produce identical outputs with no randomness or AI involvement |
