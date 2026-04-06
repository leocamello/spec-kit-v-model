# Module Design: Impact Analysis

**Feature Branch**: `005b-impact-analysis`
**Created**: 2026-04-14
**Status**: Approved
**Source**: `specs/005b-impact-analysis/v-model/architecture-design.md`

## Overview

This module design decomposes the 10 architecture modules into 15 low-level module designs specifying the concrete functions, their signatures, input/output contracts, and internal algorithms. Each module maps to one or more Bash functions within `impact-analysis.sh` or their PowerShell equivalents. The design follows the DO-178C/ISO 26262 low-level design standard: every function has explicit preconditions, postconditions, algorithm description, and error handling.

## ID Schema

- **Module Design**: `MOD-NNN` — sequential identifier for each module
- **Parent Architecture Modules**: Comma-separated `ARCH-NNN` list per module (many-to-many)
- Example: `MOD-001` with Parent Architecture Modules `ARCH-001` — module implements the file scanning function

## Module Designs

### Module: MOD-001 (scan_files)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `scripts/bash/impact-analysis.sh`

Bash function that accepts a directory path and returns a newline-separated list of markdown file paths. Uses `find "$dir" -name '*.md' -type f` to recursively discover files. Sorts output for deterministic ordering. Precondition: directory exists. Postcondition: list of absolute paths to *.md files. Returns empty string if no files found.

---

### Module: MOD-002 (build_graph)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `scripts/bash/impact-analysis.sh`

Bash function that accepts a newline-separated file list and populates two global associative arrays: `REFERENCES[id]` and `REFERENCED_BY[id]`. For each file, uses awk to: (a) identify the "owner" ID of each section/row (the first V-Model ID on a line that starts a section header or table row), (b) collect all other V-Model IDs on subsequent lines until the next section, (c) record edges in both directions. ID extraction regex: `(REQ|ATP|SCN|SYS|STP|STS|ARCH|ITP|ITS|MOD|UTP|UTS|HAZ)(-[A-Z]+)?-[0-9]{3}(-[A-Z][0-9]?)?`. Precondition: `REFERENCES` and `REFERENCED_BY` arrays are declared. Postcondition: arrays populated with all cross-references.

---

### Module: MOD-003 (classify_id)

**Parent Architecture Modules**: ARCH-002, ARCH-003, ARCH-004
**Target Source File(s)**: `scripts/bash/impact-analysis.sh`

Bash function that accepts a V-Model ID string and returns its V-Model level name (e.g., "REQ", "SYS", "ARCH", "MOD", "HAZ", "ATP", "STP", "ITP", "UTP", "SCN", "STS", "ITS", "UTS"). Uses prefix extraction with parameter expansion `${id%%-*}`. Used by traversal and formatting functions to organize suspects by level.

---

### Module: MOD-004 (traverse_downward)

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `scripts/bash/impact-analysis.sh`

Bash function that accepts a space-separated list of changed IDs and the populated graph arrays. Implements BFS using a queue (Bash array) and a visited-set (associative array). For each ID in the queue, looks up `REFERENCED_BY[id]` to find all IDs that reference it, adds unvisited ones to the queue and suspect set. Detects cycles when an ID already in the visited set is encountered, emitting a warning to stderr. Organizes suspects into `SUSPECTS_DOWN[level]` associative array and computes `BLAST_DOWN[level]` counts. Returns the suspect set and a bottom-up re-validation order.

---

### Module: MOD-005 (traverse_upward)

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `scripts/bash/impact-analysis.sh`

Bash function that accepts a space-separated list of changed IDs and the populated graph arrays. Implements BFS using a queue and visited-set. For each ID in the queue, looks up `REFERENCES[id]` to find all IDs that this artifact references, adds unvisited ones to the queue and suspect set. Same cycle detection as MOD-004. Organizes suspects into `SUSPECTS_UP[level]` and computes `BLAST_UP[level]` counts. Returns a top-down re-validation order.

---

### Module: MOD-006 (traverse_full)

**Parent Architecture Modules**: ARCH-005
**Target Source File(s)**: `scripts/bash/impact-analysis.sh`

Bash function that invokes `traverse_downward()` (MOD-004) and `traverse_upward()` (MOD-005) from the same changed IDs. Merges results into combined arrays with upstream/downstream separation. Deduplicates IDs appearing in both directions. Sets direction to "full" in the result metadata.

---

### Module: MOD-007 (build_revalidation_order)

**Parent Architecture Modules**: ARCH-003, ARCH-004
**Target Source File(s)**: `scripts/bash/impact-analysis.sh`

Bash function that accepts a suspect set organized by level and a direction ("downward" or "upward"). For downward: orders levels bottom-up (UTS, UTP, MOD, ITS, ITP, ARCH, STS, STP, SYS, HAZ, SCN, ATP, REQ). For upward: orders levels top-down (REQ, ATP, SCN, HAZ, SYS, STP, STS, ARCH, ITP, ITS, MOD, UTP, UTS). Within each level, sorts IDs alphabetically. Returns an ordered array of IDs.

---

### Module: MOD-008 (format_markdown)

**Parent Architecture Modules**: ARCH-006
**Target Source File(s)**: `scripts/bash/impact-analysis.sh`

Bash function that accepts traversal results (suspects, blast radius, re-validation order, changed IDs, direction) and writes a markdown report. Sections: (1) header with timestamp and direction, (2) Changed IDs table, (3) Suspect Artifacts organized by V-Model level, (4) Blast Radius statistics table, (5) Re-validation Order list. For full mode, creates separate "Upstream Suspects" and "Downstream Suspects" subsections. Writes to the specified output path or `impact-report.md` in the V-Model directory.

---

### Module: MOD-009 (format_json)

**Parent Architecture Modules**: ARCH-007
**Target Source File(s)**: `scripts/bash/impact-analysis.sh`

Bash function that accepts traversal results and constructs JSON output using printf. Schema: `{"changed_ids": [...], "direction": "...", "suspect_artifacts": {...}, "blast_radius": {"total": N, "by_level": {...}}, "revalidation_order": [...]}`. For full mode, `suspect_artifacts` contains `"upstream"` and `"downstream"` sub-objects. Writes to stdout. No external JSON tools (no jq).

---

### Module: MOD-010 (parse_args)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `scripts/bash/impact-analysis.sh`

Bash function that processes `$@` arguments. Iterates through args: `--downward`, `--upward`, `--full` set direction (mutually exclusive — second flag triggers error). `--json` sets JSON mode. `--output` consumes the next arg as output path. Remaining positional args are split: last one is V-Model directory, all others are changed IDs. Validates: at least one ID provided, directory exists, directory contains *.md files. Exports: `DIRECTION`, `JSON_MODE`, `OUTPUT_PATH`, `CHANGED_IDS[]`, `VMODEL_DIR`. Exits 1 with usage on error.

---

### Module: MOD-011 (main)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `scripts/bash/impact-analysis.sh`

Bash function (or top-level script body) that orchestrates the pipeline: (1) calls `parse_args()` (MOD-010), (2) calls `scan_files()` (MOD-001) on `VMODEL_DIR`, (3) calls `build_graph()` (MOD-002) on file list, (4) validates graph is non-empty, (5) calls the appropriate traversal function based on `DIRECTION`, (6) calls `format_markdown()` or `format_json()` based on `JSON_MODE`. Sets exit code 0 on success, 1 on error.

---

### Module: MOD-012 (warn_unknown_id)

**Parent Architecture Modules**: ARCH-003, ARCH-004
**Target Source File(s)**: `scripts/bash/impact-analysis.sh`

Bash function that checks each changed ID against the graph. If an ID is not present in either `REFERENCES` or `REFERENCED_BY`, emits a warning to stderr: "Warning: ID <id> not found in any V-Model artifact". Returns the list of valid (found) IDs for traversal.

---

### Module: MOD-013 (Invoke-ImpactAnalysis)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `scripts/powershell/impact-analysis.ps1`

PowerShell function serving as the entry point for `impact-analysis.ps1`. Mirrors MOD-010 + MOD-011: parses parameters (`-Downward`, `-Upward`, `-Full`, `-Json`, `-Output`, `-Ids`, `-VModelDir`), scans files with `Get-ChildItem -Recurse -Filter *.md`, builds graph with PowerShell hashtables, traverses with queue-based BFS, and formats output. Produces identical JSON and markdown to the Bash implementation.

---

### Module: MOD-014 (Build-DependencyGraph)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `scripts/powershell/impact-analysis.ps1`

PowerShell function mirroring MOD-002 and MOD-003. Reads each markdown file, extracts V-Model IDs with `Select-String`, and populates `$References` and `$ReferencedBy` hashtables. Uses the same regex pattern as the Bash version for ID extraction.

---

### Module: MOD-015 (Format-ImpactReport)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `scripts/powershell/impact-analysis.ps1`

PowerShell function mirroring MOD-008 and MOD-009. Accepts traversal results and direction, produces either markdown or JSON output. For JSON, uses `ConvertTo-Json` for well-formed output. For markdown, uses string interpolation.

---

### Module: MOD-016 (Manifest Configuration)

**Parent Architecture Modules**: ARCH-010
**Target Source File(s)**: `extension.yml`

YAML configuration entry to add to `extension.yml` registering the `speckit.v-model.impact-analysis` command. Entry specifies the command name, file path to the command definition, and a description indicating deterministic script-based analysis. No template file reference needed (script-only command).

## Function Signatures

### Bash Functions (impact-analysis.sh)

```bash
scan_files(dir) → file_list (newline-separated paths)
build_graph(file_list) → populates REFERENCES[], REFERENCED_BY[]
classify_id(id) → level_name (string)
traverse_downward(changed_ids) → populates SUSPECTS_DOWN[], BLAST_DOWN[]
traverse_upward(changed_ids) → populates SUSPECTS_UP[], BLAST_UP[]
traverse_full(changed_ids) → populates both DOWN and UP arrays
build_revalidation_order(suspects, direction) → ordered_ids (array)
format_markdown(results, output_path) → writes file
format_json(results) → writes to stdout
parse_args(args) → sets DIRECTION, JSON_MODE, OUTPUT_PATH, CHANGED_IDS[], VMODEL_DIR
main() → orchestrates pipeline, sets exit code
warn_unknown_id(changed_ids) → valid_ids (array), warnings to stderr
```

### PowerShell Functions (impact-analysis.ps1)

```powershell
Invoke-ImpactAnalysis [-Downward|-Upward|-Full] [-Json] [-Output <path>] -Ids <string[]> -VModelDir <string>
Build-DependencyGraph -Files <FileInfo[]> → [hashtable] $References, [hashtable] $ReferencedBy
Format-ImpactReport -Results <hashtable> -Direction <string> [-Json] [-Output <path>]
```

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Module Designs (MOD) | 16 |
| Total Parent Architecture Modules Covered | 10 / 10 (100%) |
| Components per Type | Function: 16 |
| **Forward Coverage (ARCH→MOD)** | **100%** |

## Derived Requirements

None — all modules trace to existing architecture modules.
