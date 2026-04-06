# Acceptance Test Plan: Impact Analysis

**Feature Branch**: `005b-impact-analysis`
**Created**: 2026-04-14
**Status**: Approved
**Source**: `specs/005b-impact-analysis/v-model/requirements.md`

## Overview

This document defines the Acceptance Test Plan for the Impact Analysis feature. Every requirement in `requirements.md` has one or more Test Cases (ATP), and every Test Case has one or more executable User Scenarios (SCN) in BDD format (Given/When/Then). The plan covers the impact-analysis script's three traversal modes (downward, upward, full), JSON and markdown output, error handling, multi-ID input, cycle detection, and PowerShell parity.

## ID Schema

- **Test Case**: `ATP-{NNN}-{X}` — where NNN matches the parent REQ, X is a letter suffix (A, B, C...)
- **Scenario**: `SCN-{NNN}-{X}{#}` — nested under the parent ATP, with numeric suffix (1, 2, 3...)
- Example: `SCN-001-A1` → Scenario 1 of Test Case A validating REQ-001

## Acceptance Tests

### Requirement Validation: REQ-001 (Impact Analysis Script Existence)

#### Test Case: ATP-001-A (Script accepts IDs and directory and produces impact report)
**Linked Requirement:** REQ-001
**Description:** Verify the script accepts one or more changed V-Model IDs and a V-Model directory path and produces an impact report file.
**Validation Condition:** `impact-report.md` exists in the V-Model directory after script execution with exit code 0.
**Expected Result:** File `impact-report.md` is created containing at least one suspect artifact entry.

* **User Scenario: SCN-001-A1**
  * **Given** a V-Model directory containing `requirements.md` with `REQ-001` through `REQ-005` and `system-design.md` with `SYS-001` through `SYS-003` where `SYS-001` references `REQ-001`
  * **When** the user runs `impact-analysis.sh REQ-001 <dir>`
  * **Then** the script exits with code 0 and a file `impact-report.md` is created in the V-Model directory containing `SYS-001` as a suspect artifact

---

### Requirement Validation: REQ-002 (Downward Traversal — Default and Explicit)

#### Test Case: ATP-002-A (Default mode traces downward without flag)
**Linked Requirement:** REQ-002
**Description:** Verify that running without a direction flag defaults to downward traversal, producing only downstream artifacts.
**Validation Condition:** Impact report lists downstream SYS and ARCH IDs but no upstream REQ IDs (since the changed ID is itself a REQ).
**Expected Result:** Report shows `SYS-001` and `ARCH-001` as suspect downstream artifacts.

* **User Scenario: SCN-002-A1**
  * **Given** a V-Model directory with `requirements.md` containing `REQ-001`, `system-design.md` with `SYS-001` referencing `REQ-001`, and `architecture-design.md` with `ARCH-001` referencing `SYS-001`
  * **When** the user runs `impact-analysis.sh REQ-001 <dir>` (no direction flag)
  * **Then** the impact report lists `SYS-001` and `ARCH-001` as suspect downstream artifacts and does not list any upstream artifacts

#### Test Case: ATP-002-B (Explicit --downward flag produces identical output to default)
**Linked Requirement:** REQ-002
**Description:** Verify that `--downward` produces the same result as the default (no flag).
**Validation Condition:** Output with `--downward` is identical to output without a direction flag.
**Expected Result:** Both invocations produce the same impact report content.

* **User Scenario: SCN-002-B1**
  * **Given** the same V-Model directory as SCN-002-A1
  * **When** the user runs `impact-analysis.sh --downward REQ-001 <dir>`
  * **Then** the impact report content is identical to the output produced in SCN-002-A1

---

### Requirement Validation: REQ-003 (Upward Traversal)

#### Test Case: ATP-003-A (Upward mode traces to all upstream parent artifacts)
**Linked Requirement:** REQ-003
**Description:** Verify that `--upward` traces from a low-level ID to all upstream artifacts that it depends on.
**Validation Condition:** Impact report lists upstream ARCH, SYS, and REQ IDs.
**Expected Result:** `ARCH-001`, `SYS-001`, and `REQ-001` appear as suspect upstream artifacts.

* **User Scenario: SCN-003-A1**
  * **Given** a V-Model directory with `module-design.md` containing `MOD-001` referencing `ARCH-001`, `architecture-design.md` with `ARCH-001` referencing `SYS-001`, and `system-design.md` with `SYS-001` referencing `REQ-001`
  * **When** the user runs `impact-analysis.sh --upward MOD-001 <dir>`
  * **Then** the impact report lists `ARCH-001`, `SYS-001`, and `REQ-001` as suspect upstream artifacts

---

### Requirement Validation: REQ-004 (Full Traversal)

#### Test Case: ATP-004-A (Full mode combines both downward and upward traversal)
**Linked Requirement:** REQ-004
**Description:** Verify that `--full` traces both upstream and downstream from the changed ID.
**Validation Condition:** Impact report contains both upstream and downstream artifact sections.
**Expected Result:** Upstream REQ-001 and downstream ARCH-002, STP-002-A appear in the report.

* **User Scenario: SCN-004-A1**
  * **Given** a V-Model directory where `SYS-002` references `REQ-001` (upstream) and is referenced by `ARCH-002` and `STP-002-A` (downstream)
  * **When** the user runs `impact-analysis.sh --full SYS-002 <dir>`
  * **Then** the impact report shows `REQ-001` as an upstream suspect and `ARCH-002`, `STP-002-A` as downstream suspects

---

### Requirement Validation: REQ-005 (Downward V-Model Hierarchy Chain)

#### Test Case: ATP-005-A (Transitive downward traversal through all V-Model levels)
**Linked Requirement:** REQ-005
**Description:** Verify that downward traversal follows the complete V-Model dependency chain transitively: REQ → SYS → ARCH → MOD and corresponding test layers.
**Validation Condition:** All V-Model levels are represented in the suspect list.
**Expected Result:** SYS-001, ARCH-001, MOD-001, and all associated test IDs appear as suspects.

* **User Scenario: SCN-005-A1**
  * **Given** a complete V-Model directory with `REQ-001` → `SYS-001` → `ARCH-001` → `MOD-001` and acceptance test `ATP-001-A` referencing `REQ-001`, system test `STP-001-A` referencing `SYS-001`, integration test `ITP-001-A` referencing `ARCH-001`, and unit test `UTP-001-A` referencing `MOD-001`
  * **When** the user runs `impact-analysis.sh --downward REQ-001 <dir>`
  * **Then** the impact report includes suspect artifacts at every V-Model level: `SYS-001`, `ARCH-001`, `MOD-001`, `ATP-001-A`, `STP-001-A`, `ITP-001-A`, `UTP-001-A`

---

### Requirement Validation: REQ-006 (Upward V-Model Hierarchy Chain)

#### Test Case: ATP-006-A (Transitive upward traversal through all V-Model levels)
**Linked Requirement:** REQ-006
**Description:** Verify that upward traversal follows the reverse V-Model chain transitively from a unit-level ID to requirements.
**Validation Condition:** All upstream levels are represented in the suspect list.
**Expected Result:** MOD-001, ARCH-001, SYS-001, and REQ-001 appear as upstream suspects.

* **User Scenario: SCN-006-A1**
  * **Given** a complete V-Model directory where `unit-test.md` contains `UTS-001-A1` referencing `UTP-001-A` referencing `MOD-001`, and `MOD-001` references `ARCH-001`, `ARCH-001` references `SYS-001`, `SYS-001` references `REQ-001`
  * **When** the user runs `impact-analysis.sh --upward UTS-001-A1 <dir>`
  * **Then** the impact report includes upstream suspects: `UTP-001-A`, `MOD-001`, `ARCH-001`, `SYS-001`, `REQ-001`

---

### Requirement Validation: REQ-007 (ID Dependency Graph from Cross-References)

#### Test Case: ATP-007-A (Graph captures cross-references from all known ID prefixes)
**Linked Requirement:** REQ-007
**Description:** Verify the script scans all markdown files and builds the dependency graph from cross-references using all known ID prefixes.
**Validation Condition:** Both design IDs (SYS) and hazard IDs (HAZ) are captured in the graph.
**Expected Result:** SYS-001 and HAZ-001 appear as downstream suspects of REQ-001.

* **User Scenario: SCN-007-A1**
  * **Given** a V-Model directory with `system-design.md` containing `SYS-001` referencing `REQ-001` and `hazard-analysis.md` containing `HAZ-001` with mitigation referencing `REQ-001`
  * **When** the user runs `impact-analysis.sh --json --downward REQ-001 <dir>`
  * **Then** the JSON output includes `SYS-001` under the `SYS` level and `HAZ-001` under the `HAZ` level in `suspect_artifacts`

* **User Scenario: SCN-007-A2**
  * **Given** a V-Model directory with `system-design.md` containing `SYS-001` that references `REQ-001` and `REQ-002` in its description, and `SYS-002` that references only `REQ-002`
  * **When** the user runs `impact-analysis.sh --json --downward REQ-002 <dir>`
  * **Then** the JSON output includes both `SYS-001` and `SYS-002` under the `SYS` level in `suspect_artifacts`

---

### Requirement Validation: REQ-008 (Multiple Changed IDs)

#### Test Case: ATP-008-A (Multiple IDs processed in single invocation)
**Linked Requirement:** REQ-008
**Description:** Verify the script accepts and processes multiple changed IDs, producing the union of their blast radii.
**Validation Condition:** Impact report covers suspect artifacts from all specified IDs.
**Expected Result:** Suspect artifacts from both REQ-001 and REQ-002 are included.

* **User Scenario: SCN-008-A1**
  * **Given** a V-Model directory where `SYS-001` references `REQ-001` only, and `SYS-002` references `REQ-002` only (no overlap)
  * **When** the user runs `impact-analysis.sh --downward REQ-001 REQ-002 <dir>`
  * **Then** the impact report lists both `SYS-001` and `SYS-002` as suspect artifacts

#### Test Case: ATP-008-B (Overlapping suspect sets are deduplicated)
**Linked Requirement:** REQ-008
**Description:** Verify that when multiple changed IDs share downstream artifacts, duplicates are removed.
**Validation Condition:** Shared suspect artifact appears exactly once.
**Expected Result:** `SYS-001` appears only once in the suspect list.

* **User Scenario: SCN-008-B1**
  * **Given** a V-Model directory where `SYS-001` references both `REQ-001` and `REQ-002`
  * **When** the user runs `impact-analysis.sh --downward REQ-001 REQ-002 <dir>`
  * **Then** `SYS-001` appears exactly once in the suspect artifact list (no duplicates)

---

### Requirement Validation: REQ-009 (Impact Report Required Sections)

#### Test Case: ATP-009-A (Report contains all four required sections)
**Linked Requirement:** REQ-009
**Description:** Verify the markdown impact report contains changed IDs, suspect artifact list, blast radius statistics, and re-validation order.
**Validation Condition:** All four sections are present in the generated file.
**Expected Result:** `impact-report.md` contains headings for "Changed IDs", "Suspect Artifacts", "Blast Radius", and "Re-validation Order".

* **User Scenario: SCN-009-A1**
  * **Given** a V-Model directory with `requirements.md`, `system-design.md`, and `architecture-design.md` forming a 3-level dependency chain from `REQ-001`
  * **When** the user runs `impact-analysis.sh REQ-001 <dir>`
  * **Then** the generated `impact-report.md` contains section headings matching "Changed IDs", "Suspect Artifacts", "Blast Radius", and "Re-validation Order"

---

### Requirement Validation: REQ-010 (Custom Output Path)

#### Test Case: ATP-010-A (--output flag writes report to specified path)
**Linked Requirement:** REQ-010
**Description:** Verify the `--output` flag directs the report to a custom file path instead of the default location.
**Validation Condition:** Report exists at the specified path; no report exists at the default path.
**Expected Result:** Custom path contains the impact report.

* **User Scenario: SCN-010-A1**
  * **Given** a V-Model directory with valid artifacts and a target path `/tmp/custom-impact-report.md`
  * **When** the user runs `impact-analysis.sh --output /tmp/custom-impact-report.md REQ-001 <dir>`
  * **Then** `/tmp/custom-impact-report.md` exists and contains the impact report
  * **And** no `impact-report.md` file is created in the V-Model directory

---

### Requirement Validation: REQ-011 (JSON Output to Stdout)

#### Test Case: ATP-011-A (--json produces valid JSON to stdout)
**Linked Requirement:** REQ-011
**Description:** Verify the `--json` flag outputs machine-readable JSON to stdout and does not create a markdown file.
**Validation Condition:** Stdout contains valid JSON; no `impact-report.md` is created.
**Expected Result:** JSON is parseable by `jq` and contains suspect artifact data.

* **User Scenario: SCN-011-A1**
  * **Given** a V-Model directory with `REQ-001` → `SYS-001`
  * **When** the user runs `impact-analysis.sh --json REQ-001 <dir>` and pipes stdout to `jq .`
  * **Then** `jq` parses the output without errors and the JSON contains a `suspect_artifacts` field
  * **And** no `impact-report.md` file is created in the V-Model directory

---

### Requirement Validation: REQ-012 (JSON Schema Conformance)

#### Test Case: ATP-012-A (JSON output contains all required schema fields)
**Linked Requirement:** REQ-012
**Description:** Verify the JSON output contains `changed_ids`, `direction`, `suspect_artifacts`, `blast_radius`, and `revalidation_order` with correct types.
**Validation Condition:** All five top-level fields are present with expected types.
**Expected Result:** JSON matches the defined schema.

* **User Scenario: SCN-012-A1**
  * **Given** a V-Model directory with `REQ-001` → `SYS-001` → `ARCH-001`
  * **When** the user runs `impact-analysis.sh --json --downward REQ-001 <dir>`
  * **Then** the JSON output contains `"changed_ids": ["REQ-001"]` (array of strings)
  * **And** `"direction": "downward"` (string)
  * **And** `"suspect_artifacts"` is an object with V-Model level keys containing arrays of ID strings
  * **And** `"blast_radius"` is an object with `"total"` (number) and `"by_level"` (object of level→count)
  * **And** `"revalidation_order"` is an array of ID strings

---

### Requirement Validation: REQ-013 (Unknown ID Warning)

#### Test Case: ATP-013-A (Warning emitted for nonexistent ID, processing continues)
**Linked Requirement:** REQ-013
**Description:** Verify the script emits a warning for IDs not found in any artifact and continues processing valid IDs.
**Validation Condition:** Warning on stderr, exit code 0, valid output for remaining IDs.
**Expected Result:** Warning message names the unknown ID; other IDs are processed normally.

* **User Scenario: SCN-013-A1**
  * **Given** a V-Model directory with valid artifacts containing `REQ-001` but no `REQ-999`
  * **When** the user runs `impact-analysis.sh REQ-999 <dir>`
  * **Then** stderr contains the text "ID REQ-999 not found in any V-Model artifact"
  * **And** the script exits with code 0

* **User Scenario: SCN-013-A2**
  * **Given** a V-Model directory where `REQ-001` → `SYS-001` exists but `REQ-999` does not
  * **When** the user runs `impact-analysis.sh REQ-001 REQ-999 <dir>`
  * **Then** stderr contains a warning for `REQ-999`
  * **And** the impact report lists `SYS-001` as a suspect artifact for `REQ-001`

---

### Requirement Validation: REQ-014 (No Artifacts Error)

#### Test Case: ATP-014-A (Error when directory has no V-Model markdown files)
**Linked Requirement:** REQ-014
**Description:** Verify the script fails with exit code 1 and an actionable error when no artifacts exist.
**Validation Condition:** Exit code is 1; stderr contains the directory path in the error message.
**Expected Result:** Error message "No V-Model artifacts found in <dir>" is printed.

* **User Scenario: SCN-014-A1**
  * **Given** an empty directory at `/tmp/empty-vmodel-dir` containing no markdown files
  * **When** the user runs `impact-analysis.sh REQ-001 /tmp/empty-vmodel-dir`
  * **Then** stderr contains "No V-Model artifacts found in /tmp/empty-vmodel-dir"
  * **And** the script exits with code 1

---

### Requirement Validation: REQ-015 (Missing Optional Artifacts)

#### Test Case: ATP-015-A (Traversal stops gracefully when optional files are missing)
**Linked Requirement:** REQ-015
**Description:** Verify the script handles missing optional artifacts (e.g., `architecture-design.md`) without errors, only reporting what is available.
**Validation Condition:** Script exits 0; report covers existing levels only.
**Expected Result:** SYS-level suspects are reported; no ARCH-level suspects and no error about missing files.

* **User Scenario: SCN-015-A1**
  * **Given** a V-Model directory with `requirements.md` and `system-design.md` (where `SYS-001` references `REQ-001`) but no `architecture-design.md`, `module-design.md`, or test plan files
  * **When** the user runs `impact-analysis.sh --downward REQ-001 <dir>`
  * **Then** the impact report lists `SYS-001` as a suspect artifact
  * **And** no `ARCH-NNN` or `MOD-NNN` IDs appear in the suspect list
  * **And** the script exits with code 0

---

### Requirement Validation: REQ-016 (Re-validation Order)

#### Test Case: ATP-016-A (Bottom-up order for downward traversal)
**Linked Requirement:** REQ-016
**Description:** Verify that downward traversal suggests re-validation starting from the lowest-level (most granular) artifacts first.
**Validation Condition:** In the re-validation order, unit-level IDs precede integration-level, which precede system-level.
**Expected Result:** UTS/UTP appear before ITS/ITP, which appear before STS/STP.

* **User Scenario: SCN-016-A1**
  * **Given** a complete V-Model directory with `REQ-001` → `SYS-001` → `ARCH-001` → `MOD-001` and tests at each level
  * **When** the user runs `impact-analysis.sh --downward REQ-001 <dir>`
  * **Then** in the "Re-validation Order" section, unit-level artifact IDs appear before integration-level IDs, which appear before system-level IDs

#### Test Case: ATP-016-B (Top-down order for upward traversal)
**Linked Requirement:** REQ-016
**Description:** Verify that upward traversal suggests re-validation starting from the highest-level (most abstract) artifacts first.
**Validation Condition:** In the re-validation order, REQ-level IDs precede SYS-level, which precede ARCH-level.
**Expected Result:** REQ IDs appear before SYS IDs in the re-validation order.

* **User Scenario: SCN-016-B1**
  * **Given** a complete V-Model directory with `MOD-001` → `ARCH-001` → `SYS-001` → `REQ-001`
  * **When** the user runs `impact-analysis.sh --upward MOD-001 <dir>`
  * **Then** in the "Re-validation Order" section, `REQ-001` appears before `SYS-001`, which appears before `ARCH-001`

---

### Requirement Validation: REQ-017 (Read-Only Operation)

#### Test Case: ATP-017-A (No existing artifacts modified during analysis)
**Linked Requirement:** REQ-017
**Description:** Verify the script does not modify any existing V-Model artifact files — it only reads them and writes the impact report.
**Validation Condition:** SHA-256 checksums of all input markdown files are identical before and after execution.
**Expected Result:** All input files remain byte-for-byte unchanged.

* **User Scenario: SCN-017-A1**
  * **Given** a V-Model directory with `requirements.md`, `system-design.md`, and `architecture-design.md` whose SHA-256 checksums are recorded before execution
  * **When** the user runs `impact-analysis.sh REQ-001 <dir>`
  * **Then** the SHA-256 checksums of `requirements.md`, `system-design.md`, and `architecture-design.md` are identical to the recorded values

---

### Requirement Validation: REQ-018 (Performance)

#### Test Case: ATP-018-A (Analysis completes within 10 seconds for standard project)
**Linked Requirement:** REQ-018
**Description:** Verify the script completes within 10 seconds for a project with up to 20 artifact files and 500 IDs.
**Validation Condition:** Total wall-clock execution time is less than 10 seconds.
**Expected Result:** Script finishes and produces output within the time limit.

* **User Scenario: SCN-018-A1**
  * **Given** a V-Model directory with 20 markdown files containing approximately 500 total V-Model IDs across all prefix types
  * **When** the user measures execution time of `impact-analysis.sh --downward REQ-001 <dir>` using the `time` command
  * **Then** the real (wall-clock) time is less than 10 seconds

---

### Requirement Validation: REQ-019 (Standard Bash Utilities Only)

#### Test Case: ATP-019-A (Script uses only standard POSIX/Bash utilities)
**Linked Requirement:** REQ-019
**Description:** Verify the script does not depend on any non-standard external tools (no Python, no jq, no Node.js, etc.).
**Validation Condition:** Source code inspection shows only standard utilities (bash, awk, grep, sed, sort, uniq, cat, echo, printf, test, find, etc.).
**Expected Result:** No non-standard tool invocations found in the script.

* **User Scenario: SCN-019-A1**
  * **Given** the `impact-analysis.sh` script source file
  * **When** scanning the script for all command invocations using static analysis
  * **Then** only standard Bash/POSIX utilities are invoked: bash, awk, grep, sed, sort, uniq, cat, echo, printf, test, find, dirname, basename, mktemp, and built-in Bash constructs

---

### Requirement Validation: REQ-020 (PowerShell Parity)

#### Test Case: ATP-020-A (PowerShell produces identical JSON output structure)
**Linked Requirement:** REQ-020
**Description:** Verify the PowerShell script produces identical JSON output to the Bash script for the same inputs.
**Validation Condition:** JSON outputs from both scripts have identical `changed_ids`, `suspect_artifacts`, `blast_radius`, and `revalidation_order` values.
**Expected Result:** Cross-platform results are identical.

* **User Scenario: SCN-020-A1**
  * **Given** a V-Model directory with `REQ-001` → `SYS-001` → `ARCH-001`
  * **When** the user runs `impact-analysis.sh --json --downward REQ-001 <dir>` (Bash) and `Impact-Analysis.ps1 -Json -Downward -Ids REQ-001 -VModelDir <dir>` (PowerShell)
  * **Then** both JSON outputs have identical values for `changed_ids`, `direction`, `suspect_artifacts`, `blast_radius`, and `revalidation_order`

---

### Requirement Validation: REQ-021 (Extension Manifest Registration)

#### Test Case: ATP-021-A (Command registered in extension.yml)
**Linked Requirement:** REQ-021
**Description:** Verify the impact-analysis command is registered in the extension manifest with a name and file path.
**Validation Condition:** `extension.yml` contains a command entry for `speckit.v-model.impact-analysis`.
**Expected Result:** Command entry exists with `name`, `file`, and `description` fields.

* **User Scenario: SCN-021-A1**
  * **Given** the `extension.yml` file in the project root
  * **When** parsing the YAML for command entries under `provides.commands`
  * **Then** an entry exists with `name: "speckit.v-model.impact-analysis"` and a valid `file` path

---

### Requirement Validation: REQ-022 (Deterministic Script Indicator in Description)

#### Test Case: ATP-022-A (Description indicates deterministic script-based command)
**Linked Requirement:** REQ-022
**Description:** Verify the extension.yml command description communicates that impact-analysis produces deterministic output.
**Validation Condition:** Command description contains "deterministic" or "script".
**Expected Result:** Users understand this is not an AI-generated artifact.

* **User Scenario: SCN-022-A1**
  * **Given** the `extension.yml` command entry for `speckit.v-model.impact-analysis`
  * **When** reading the `description` field
  * **Then** the description contains the word "deterministic" or "script"

---

### Requirement Validation: REQ-023 (Full Mode Upward/Downward Separation)

#### Test Case: ATP-023-A (Full traversal clearly separates upstream and downstream sections)
**Linked Requirement:** REQ-023
**Description:** Verify that `--full` mode output has distinct sections for upstream and downstream artifacts.
**Validation Condition:** Report contains separate labeled sections; JSON has separate keys.
**Expected Result:** A reader can unambiguously identify which artifacts are upstream vs downstream.

* **User Scenario: SCN-023-A1**
  * **Given** a V-Model directory where `SYS-002` references `REQ-001` (upstream) and is referenced by `ARCH-002` (downstream)
  * **When** the user runs `impact-analysis.sh --full SYS-002 <dir>`
  * **Then** the markdown impact report has a section containing "Upstream" or "Upward" with `REQ-001`
  * **And** a separate section containing "Downstream" or "Downward" with `ARCH-002`

* **User Scenario: SCN-023-A2**
  * **Given** the same V-Model directory as SCN-023-A1
  * **When** the user runs `impact-analysis.sh --json --full SYS-002 <dir>`
  * **Then** the JSON `suspect_artifacts` object distinguishes upstream from downstream artifacts (e.g., separate `upstream` and `downstream` keys or annotations)

---

### Requirement Validation: REQ-024 (Circular Reference Handling)

#### Test Case: ATP-024-A (Cycle detection prevents infinite loop)
**Linked Requirement:** REQ-024
**Description:** Verify the script detects circular references, emits a warning, and completes traversal without hanging.
**Validation Condition:** Script completes within 10 seconds; warning emitted; all reachable artifacts reported.
**Expected Result:** Both nodes in the cycle appear in suspects; no infinite loop.

* **User Scenario: SCN-024-A1**
  * **Given** a V-Model directory where `system-design.md` contains `SYS-001` referencing `ARCH-001` and `architecture-design.md` contains `ARCH-001` referencing `SYS-001` (circular reference)
  * **When** the user runs `impact-analysis.sh --downward SYS-001 <dir>`
  * **Then** the script completes within 10 seconds without hanging
  * **And** `ARCH-001` appears in the suspect artifact list
  * **And** stderr contains a warning about a circular reference

---

### Requirement Validation: REQ-025 (Directory as Last Positional Argument)

#### Test Case: ATP-025-A (V-Model directory correctly parsed as last positional argument)
**Linked Requirement:** REQ-025
**Description:** Verify the V-Model directory path is correctly identified as the last positional argument, consistent with other scripts.
**Validation Condition:** Script correctly processes when directory is the final argument.
**Expected Result:** Script identifies the directory and produces valid output.

* **User Scenario: SCN-025-A1**
  * **Given** a valid V-Model directory at `/tmp/test-vmodel` with `requirements.md` and `system-design.md`
  * **When** the user runs `impact-analysis.sh --downward REQ-001 /tmp/test-vmodel`
  * **Then** the script correctly identifies `/tmp/test-vmodel` as the V-Model directory and produces an impact report

---

### Requirement Validation: REQ-NF-001 (Regex-Based Parsing Consistency)

#### Test Case: ATP-NF-001-A (Consistent regex patterns with existing scripts)
**Linked Requirement:** REQ-NF-001
**Description:** Verify the script uses regex patterns consistent with `build-matrix.sh` and `validate-*-coverage.sh` for ID extraction.
**Validation Condition:** Impact-analysis extracts the same set of IDs as existing scripts from the same files.
**Expected Result:** ID sets are identical.

* **User Scenario: SCN-NF-001-A1**
  * **Given** a V-Model directory with known ID references verified by `build-matrix.sh`
  * **When** comparing IDs extracted by `impact-analysis.sh` (via `--json` output) with IDs found by `build-matrix.sh`
  * **Then** both tools identify the same set of V-Model IDs for the same artifact files

---

### Requirement Validation: REQ-NF-002 (Deterministic Reproducibility)

#### Test Case: ATP-NF-002-A (Identical output on repeated runs)
**Linked Requirement:** REQ-NF-002
**Description:** Verify the script produces byte-identical output when run twice with the same inputs.
**Validation Condition:** Two consecutive JSON outputs are identical.
**Expected Result:** Output is perfectly deterministic.

* **User Scenario: SCN-NF-002-A1**
  * **Given** a V-Model directory with valid artifacts
  * **When** the user runs `impact-analysis.sh --json REQ-001 <dir>` twice consecutively
  * **Then** both JSON outputs are byte-identical

---

### Requirement Validation: REQ-NF-003 (Nested Subdirectory Scanning)

#### Test Case: ATP-NF-003-A (Markdown files in subdirectories are included in the graph)
**Linked Requirement:** REQ-NF-003
**Description:** Verify the script scans markdown files in nested subdirectories when building the dependency graph.
**Validation Condition:** IDs from files in subdirectories are included in traversal results.
**Expected Result:** Suspect artifacts from nested files are reported.

* **User Scenario: SCN-NF-003-A1**
  * **Given** a V-Model directory where `system-design.md` is located at `<dir>/design/system-design.md` (nested subdirectory) and contains `SYS-001` referencing `REQ-001`
  * **When** the user runs `impact-analysis.sh --downward REQ-001 <dir>`
  * **Then** `SYS-001` from the nested file appears in the suspect artifact list

---

### Requirement Validation: REQ-IF-001 (Bash CLI Syntax)

#### Test Case: ATP-IF-001-A (All CLI flags and arguments accepted)
**Linked Requirement:** REQ-IF-001
**Description:** Verify the full CLI syntax is accepted: direction flags, --json, --output, IDs, and directory.
**Validation Condition:** Script parses all flags correctly and produces expected output.
**Expected Result:** All flag combinations work as documented.

* **User Scenario: SCN-IF-001-A1**
  * **Given** a valid V-Model directory with `MOD-001` → `ARCH-001`
  * **When** the user runs `impact-analysis.sh --upward --json --output /tmp/report.json MOD-001 <dir>`
  * **Then** the script correctly interprets: upward traversal, JSON format, output to `/tmp/report.json`, changed ID is `MOD-001`
  * **And** `/tmp/report.json` contains valid JSON with `"direction": "upward"` and `"changed_ids": ["MOD-001"]`

---

### Requirement Validation: REQ-IF-002 (PowerShell CLI Syntax)

#### Test Case: ATP-IF-002-A (PowerShell parameter syntax accepted)
**Linked Requirement:** REQ-IF-002
**Description:** Verify all PowerShell parameters are accepted and correctly interpreted.
**Validation Condition:** Script parses all parameters and produces expected output.
**Expected Result:** All parameter combinations work.

* **User Scenario: SCN-IF-002-A1**
  * **Given** a valid V-Model directory with `MOD-001` → `ARCH-001`
  * **When** the user runs `Impact-Analysis.ps1 -Upward -Json -Output /tmp/report.json -Ids MOD-001 -VModelDir <dir>`
  * **Then** the script correctly interprets the parameters and produces valid JSON with `"direction": "upward"` and `"changed_ids": ["MOD-001"]`

---

### Requirement Validation: REQ-CN-001 (No New ID Prefixes)

#### Test Case: ATP-CN-001-A (Impact report uses only existing ID prefixes)
**Linked Requirement:** REQ-CN-001
**Description:** Verify the impact-analysis command does not introduce any new ID prefix patterns.
**Validation Condition:** All IDs in the impact report match existing V-Model prefixes.
**Expected Result:** Only REQ, ATP, SCN, SYS, STP, STS, ARCH, ITP, ITS, MOD, UTP, UTS, HAZ prefixes appear.

* **User Scenario: SCN-CN-001-A1**
  * **Given** an impact report generated by `impact-analysis.sh` from a complete V-Model directory
  * **When** extracting all ID patterns matching `[A-Z]{2,4}-[0-9]{3}` from the report
  * **Then** every extracted ID prefix is one of: REQ, ATP, SCN, SYS, STP, STS, ARCH, ITP, ITS, MOD, UTP, UTS, HAZ

---

### Requirement Validation: REQ-CN-002 (Cross-Platform Parity)

#### Test Case: ATP-CN-002-A (Bash and PowerShell produce identical JSON results)
**Linked Requirement:** REQ-CN-002
**Description:** Verify cross-platform parity between Bash and PowerShell implementations.
**Validation Condition:** JSON outputs are structurally and value-identical.
**Expected Result:** Same suspect artifacts, same blast radius, same re-validation order.

* **User Scenario: SCN-CN-002-A1**
  * **Given** a V-Model directory with `REQ-001` → `SYS-001` → `ARCH-001`
  * **When** running both `impact-analysis.sh --json REQ-001 <dir>` and `Impact-Analysis.ps1 -Json -Ids REQ-001 -VModelDir <dir>`
  * **Then** both outputs have identical `suspect_artifacts` keys and values
  * **And** both outputs have identical `blast_radius` values

---

### Requirement Validation: REQ-CN-003 (No New Prerequisites)

#### Test Case: ATP-CN-003-A (Works with existing V-Model projects without additional files)
**Linked Requirement:** REQ-CN-003
**Description:** Verify the script works with any existing V-Model project without requiring new configuration or prerequisite files.
**Validation Condition:** Script succeeds with a v0.4.0 project (no hazard-analysis.md, no waivers.md).
**Expected Result:** No errors about missing files.

* **User Scenario: SCN-CN-003-A1**
  * **Given** a V-Model directory from a v0.4.0 project containing only `requirements.md`, `system-design.md`, `acceptance-plan.md`, and `system-test.md`
  * **When** the user runs `impact-analysis.sh REQ-001 <dir>`
  * **Then** the script completes successfully with exit code 0
  * **And** the impact report lists suspect artifacts based on the available files

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Requirements | 33 |
| Total Test Cases (ATP) | 36 |
| Total Scenarios (SCN) | 40 |
| REQ → ATP Coverage | 100% |
| ATP → SCN Coverage | 100% |

**Validation Status**: ✅ Full Coverage
**Generated**: 2026-04-14
**Validated by**: `validate-requirement-coverage.sh` (deterministic)
