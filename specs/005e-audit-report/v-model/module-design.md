# V-Model Module Design: Release Audit Report

**Feature Branch**: `feature/005e-audit-report`
**Created**: 2026-04-05
**Status**: Approved
**Source**: `specs/005e-audit-report/v-model/architecture-design.md`

## Overview

This document defines the detailed module designs (MOD-NNN) that implement each architecture module. Each MOD specifies function-level pseudocode, input/output contracts, and error handling. These are implemented 1:1 in both Bash and PowerShell.

## Module Designs

### Module: MOD-001 (parse_cli_args)

**Parent Architecture Modules**: ARCH-001

**Inputs**: `$@` (Bash) or `$PSBoundParameters` (PowerShell)

**Outputs**: Validated variables — `vmodel_dir`, `system_name`, `version`, `git_tag`, `regulatory_context`, `output_path`, `json_flag`

**Pseudocode**:
```
FUNCTION parse_cli_args(args):
    IF args[0] == "--help" OR no args:
        print usage, exit 0
    vmodel_dir = args[0]
    IF NOT directory_exists(vmodel_dir):
        error "Directory not found", exit 2
    PARSE named options: --system-name, --version, --git-tag, --regulatory-context, --output, --json
    SET defaults: output = "release-audit-report.md", json_flag = false
    RETURN config
```

**Error Handling**: Missing vmodel_dir → exit 2 with usage message. Unknown flags → warning on stderr.

### Module: MOD-002 (discover_artifacts)

**Parent Architecture Modules**: ARCH-002

**Inputs**: `vmodel_dir` path

**Outputs**: Array of `{name, file, sha, date, exists}` records

**Expected files** (ordered):
```
requirements.md, acceptance-plan.md, system-design.md, system-test.md,
architecture-design.md, integration-test.md, module-design.md, unit-test.md,
hazard-analysis.md, traceability-matrix.md, waivers.md
```

**Pseudocode**:
```
FUNCTION discover_artifacts(vmodel_dir):
    artifacts = []
    FOR EACH filename IN expected_files:
        path = vmodel_dir / filename
        IF file_exists(path):
            sha, date = git_log_1(path)  # git log -1 --format='%h|%aI' -- <path>
            artifacts.append({name: human_name(filename), file: filename, sha: sha, date: date, exists: true})
        ELSE:
            artifacts.append({name: human_name(filename), file: filename, sha: "—", date: "—", exists: false})
    RETURN artifacts
```

**Error Handling**: Non-git directory → sha/date set to "N/A". Required files (requirements.md, traceability-matrix.md) missing → warning.

### Module: MOD-003 (parse_matrix_file)

**Parent Architecture Modules**: ARCH-003

**Inputs**: File path to traceability-matrix.md

**Outputs**: Array of matrix objects `{id, title, header_row, data_rows[], coverage}`

**Pseudocode**:
```
FUNCTION parse_matrix_file(path):
    IF NOT file_exists(path):
        RETURN []
    lines = read_lines(path)
    matrices = []
    current_matrix = null
    FOR EACH line IN lines:
        IF line matches "## Matrix [A-Z]":
            IF current_matrix != null:
                compute_coverage(current_matrix)
                matrices.append(current_matrix)
            current_matrix = {id: extract_id(line), title: line, header: null, rows: []}
        ELSE IF current_matrix != null AND line starts with "|":
            IF line is separator (contains "---"):
                CONTINUE
            IF current_matrix.header == null:
                current_matrix.header = parse_columns(line)
            ELSE:
                current_matrix.rows.append(parse_columns(line))
    IF current_matrix != null:
        compute_coverage(current_matrix)
        matrices.append(current_matrix)
    RETURN matrices
```

### Module: MOD-004 (compute_coverage_metrics)

**Parent Architecture Modules**: ARCH-003

**Inputs**: Parsed matrix object

**Outputs**: `{forward_count, forward_total, backward_count, backward_total, gaps[], orphans[]}`

**Pseudocode**:
```
FUNCTION compute_coverage(matrix):
    source_ids = unique values from column 0  # e.g., REQ-NNN
    target_ids = unique values from last ID column  # e.g., SCN-NNN
    forward_count = count(source_ids with at least one target)
    backward_count = count(target_ids with at least one source)
    gaps = source_ids without targets
    orphans = target_ids without sources
    RETURN {forward: forward_count/total, backward: backward_count/total, gaps, orphans}
```

### Module: MOD-005 (parse_hazards)

**Parent Architecture Modules**: ARCH-004

**Inputs**: File path to hazard-analysis.md (nullable)

**Outputs**: Array of hazard records or null

**Pseudocode**:
```
FUNCTION parse_hazards(path):
    IF path == null OR NOT file_exists(path):
        RETURN null
    lines = read_lines(path)
    hazards = []
    in_table = false
    FOR EACH line IN lines:
        IF line matches "| HAZ-" at start of a column:
            in_table = true
            cols = parse_columns(line)
            hazards.append({id: cols[0], failure_mode: cols[1], severity: cols[2], ...})
        ELSE IF in_table AND NOT line starts with "|":
            in_table = false
    RETURN hazards
```

### Module: MOD-006 (scan_anomalies)

**Parent Architecture Modules**: ARCH-005

**Inputs**: Array of parsed matrices

**Outputs**: Array of `{artifact_id, type, matrix_id, detail}`

**Pseudocode**:
```
FUNCTION scan_anomalies(matrices):
    anomalies = []
    FOR EACH matrix IN matrices:
        status_col = find_column_index(matrix.header, "Status")
        id_col = find_last_id_column(matrix.header)  # SCN, STS, ITS, or UTS column
        FOR EACH row IN matrix.rows:
            status = row[status_col]
            IF status contains "❌ Failed":
                anomalies.append({artifact_id: row[id_col], type: "Failed Test", matrix: matrix.id})
            ELSE IF status contains "⏭️ Skipped":
                anomalies.append({artifact_id: row[id_col], type: "Skipped Test", matrix: matrix.id})
    RETURN anomalies
```

### Module: MOD-007 (parse_waivers)

**Parent Architecture Modules**: ARCH-006

**Inputs**: File path to waivers.md (nullable)

**Outputs**: Map `{artifact_id → {wav_id, type, justification, approved_by}}`

**Pseudocode**:
```
FUNCTION parse_waivers(path):
    IF path == null OR NOT file_exists(path):
        RETURN {}
    text = read_file(path)
    waiver_map = {}
    blocks = split_on_pattern(text, "### WAV-[0-9]{3}")
    FOR EACH block IN blocks:
        wav_id = extract "WAV-NNN" from heading
        artifact_id = extract "**Artifact**: <value>" from block
        type = extract "**Type**: <value>" from block
        justification = extract "**Justification**: <value>" from block
        approved_by = extract "**Approved By**: <value>" from block
        waiver_map[artifact_id] = {wav_id, type, justification, approved_by}
    RETURN waiver_map
```

### Module: MOD-008 (cross_reference_anomalies)

**Parent Architecture Modules**: ARCH-007

**Inputs**: Anomaly list, waiver map

**Outputs**: `{classified[], orphaned_waivers[], status, exit_code}`

**Pseudocode**:
```
FUNCTION cross_reference(anomalies, waiver_map):
    classified = []
    used_waiver_ids = set()
    blocking_count = 0
    FOR EACH anomaly IN anomalies:
        IF anomaly.artifact_id IN waiver_map:
            waiver = waiver_map[anomaly.artifact_id]
            classified.append({...anomaly, disposition: "Waived", waiver: waiver})
            used_waiver_ids.add(waiver.wav_id)
        ELSE:
            classified.append({...anomaly, disposition: "BLOCKING"})
            blocking_count += 1
    orphaned = [w FOR w IN waiver_map.values() IF w.wav_id NOT IN used_waiver_ids]
    IF blocking_count > 0:
        status = "❌ NOT READY — Unwaived anomalies detected"
        exit_code = 1
    ELSE IF len(anomalies) > 0:
        status = "✅ RELEASE CANDIDATE — All anomalies waived"
        exit_code = 0
    ELSE:
        status = "✅ RELEASE READY — No anomalies"
        exit_code = 0
    RETURN {classified, orphaned, status, exit_code}
```

### Module: MOD-009 (render_report)

**Parent Architecture Modules**: ARCH-008

**Inputs**: All computed data + metadata + output path

**Outputs**: Markdown file at output_path + summary on stderr

**Sections rendered** (in order):
1. Executive Summary — template-fill with metrics
2. Artifact Inventory — table from discover_artifacts output
3. Traceability Matrices — embed matrix tables from parse_matrix_file
4. Coverage Analysis — table from compute_coverage_metrics
5. Hazard Management Summary — table from parse_hazards
6. Known Anomalies — table from cross_reference (waived + blocking)
7. Signature Block — blank fields with git tag/SHA/date

### Module: MOD-010 (render_json)

**Parent Architecture Modules**: ARCH-009

**Inputs**: All computed data

**Outputs**: JSON string to stdout

**JSON structure**:
```json
{
  "metadata": {"system_name": "", "version": "", "git_tag": "", "date": "", "regulatory_context": ""},
  "compliance_status": "",
  "exit_code": 0,
  "artifact_inventory": [],
  "matrices": [],
  "coverage_analysis": [],
  "hazard_summary": [],
  "anomalies": {"classified": [], "orphaned_waivers": []},
  "summary": {"total_requirements": 0, "total_tests": 0, "passed": 0, "failed": 0, "skipped": 0, "total_hazards": 0}
}
```
