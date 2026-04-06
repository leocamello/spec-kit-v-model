# System Test Plan: Impact Analysis

**Feature Branch**: `005b-impact-analysis`
**Created**: 2026-04-14
**Status**: Approved
**Source**: `specs/005b-impact-analysis/v-model/system-design.md`

## Overview

This document defines the System Test Plan for the Impact Analysis feature. Every system component in `system-design.md` has one or more Test Cases (STP), and every Test Case has one or more executable System Scenarios (STS) in technical BDD format (Given/When/Then). System tests verify architectural behavior, not user journeys. Language is technical and component-oriented.

## ID Schema

- **System Test Case**: `STP-{NNN}-{X}` — where NNN matches the parent SYS, X is a letter suffix (A, B, C...)
- **System Test Scenario**: `STS-{NNN}-{X}{#}` — nested under the parent STP, with numeric suffix (1, 2, 3...)
- Example: `STS-001-A1` → Scenario 1 of Test Case A verifying SYS-001

## ISO 29119 Test Techniques

Each test case MUST identify its technique by name:
- **Interface Contract Testing** — Verifies API contracts from the Interface View
- **Boundary Value Analysis** — Tests data limits from the Data Design View
- **Equivalence Partitioning** — Tests representative data classes
- **Fault Injection** — Tests failure propagation from the Dependency View

## System Tests

### Component Verification: SYS-001 (ID Dependency Graph Builder)

**Parent Requirements**: REQ-001, REQ-007, REQ-015, REQ-017, REQ-019, REQ-NF-001, REQ-NF-002, REQ-NF-003, REQ-CN-003

#### Test Case: STP-001-A (Graph correctly captures all ID cross-references from markdown files)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify the graph builder scans all markdown files and creates correct adjacency lists for each ID.

* **System Scenario: STS-001-A1**
  * **Given** a V-Model directory containing `requirements.md` with `REQ-001` and `system-design.md` with `SYS-001` referencing `REQ-001` in its parent requirements column
  * **When** the graph builder scans the directory
  * **Then** the adjacency list for `SYS-001` contains `REQ-001` in its "references" set and the adjacency list for `REQ-001` contains `SYS-001` in its "referenced-by" set

* **System Scenario: STS-001-A2**
  * **Given** a V-Model directory containing `hazard-analysis.md` with `HAZ-001` referencing `SYS-001` and `REQ-001` in its mitigation column
  * **When** the graph builder scans the directory
  * **Then** the adjacency list for `HAZ-001` contains both `SYS-001` and `REQ-001` in its "references" set

#### Test Case: STP-001-B (Graph builder handles all 13 known ID prefixes)

**Technique**: Equivalence Partitioning
**Target View**: Data Design View
**Description**: Verify the regex patterns capture all V-Model ID prefixes: REQ, ATP, SCN, SYS, STP, STS, ARCH, ITP, ITS, MOD, UTP, UTS, HAZ.

* **System Scenario: STS-001-B1**
  * **Given** a markdown file containing one ID from each of the 13 prefixes (REQ-001, ATP-001-A, SCN-001-A1, SYS-001, STP-001-A, STS-001-A1, ARCH-001, ITP-001-A, ITS-001-A1, MOD-001, UTP-001-A, UTS-001-A1, HAZ-001)
  * **When** the graph builder extracts IDs from this file
  * **Then** all 13 IDs are present in the dependency graph as nodes

#### Test Case: STP-001-C (Graph builder handles missing optional files gracefully)

**Technique**: Fault Injection
**Target View**: Dependency View
**Description**: Verify the graph builder produces a partial graph when optional files (architecture-design.md, module-design.md, etc.) are absent.

* **System Scenario: STS-001-C1**
  * **Given** a V-Model directory containing only `requirements.md` and `system-design.md` (no architecture, module, or test plan files)
  * **When** the graph builder scans the directory
  * **Then** the graph contains only REQ and SYS nodes with no error or warning about missing files

#### Test Case: STP-001-D (Graph builder scans nested subdirectories)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verify the graph builder discovers markdown files in nested subdirectories.

* **System Scenario: STS-001-D1**
  * **Given** a V-Model directory where `system-design.md` is located at `<dir>/sub/system-design.md` containing `SYS-001` referencing `REQ-001`
  * **When** the graph builder scans the top-level directory
  * **Then** `SYS-001` and its reference to `REQ-001` are captured in the graph

---

### Component Verification: SYS-002 (Graph Traversal Engine)

**Parent Requirements**: REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-013, REQ-016, REQ-023, REQ-024

#### Test Case: STP-002-A (Downward traversal follows V-Model hierarchy transitively)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify downward traversal starts from a changed ID and transitively follows "references" edges through all V-Model levels.

* **System Scenario: STS-002-A1**
  * **Given** a dependency graph where `REQ-001` → `SYS-001` → `ARCH-001` → `MOD-001` (each node's "referenced-by" set links to the next)
  * **When** the traversal engine runs in `--downward` mode from `REQ-001`
  * **Then** the suspect set contains `SYS-001`, `ARCH-001`, and `MOD-001` at their respective V-Model levels

#### Test Case: STP-002-B (Upward traversal follows reverse V-Model hierarchy transitively)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify upward traversal starts from a changed ID and transitively follows "referenced-by" edges back to requirements.

* **System Scenario: STS-002-B1**
  * **Given** a dependency graph where `MOD-001` references `ARCH-001`, `ARCH-001` references `SYS-001`, `SYS-001` references `REQ-001`
  * **When** the traversal engine runs in `--upward` mode from `MOD-001`
  * **Then** the suspect set contains `ARCH-001`, `SYS-001`, and `REQ-001`

#### Test Case: STP-002-C (Full traversal combines both directions with clear separation)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify `--full` mode produces both upstream and downstream suspect sets with clear separation.

* **System Scenario: STS-002-C1**
  * **Given** a dependency graph where `SYS-002` is referenced-by `REQ-001` (upstream) and references `ARCH-002` (downstream)
  * **When** the traversal engine runs in `--full` mode from `SYS-002`
  * **Then** the result contains an upstream set with `REQ-001` and a downstream set with `ARCH-002` as separate data structures

#### Test Case: STP-002-D (Cycle detection prevents infinite traversal)

**Technique**: Fault Injection
**Target View**: Dependency View
**Description**: Verify the visited-set mechanism detects circular references and completes traversal without infinite looping.

* **System Scenario: STS-002-D1**
  * **Given** a dependency graph where `SYS-001` references `ARCH-001` and `ARCH-001` references `SYS-001` (bidirectional cycle)
  * **When** the traversal engine runs in `--downward` mode from `SYS-001`
  * **Then** the traversal completes within bounded time, `ARCH-001` is in the suspect set, and a cycle warning is emitted to stderr

#### Test Case: STP-002-E (Multiple changed IDs produce union of blast radii)

**Technique**: Equivalence Partitioning
**Target View**: Data Design View
**Description**: Verify that multiple changed IDs produce the deduplicated union of their individual blast radii.

* **System Scenario: STS-002-E1**
  * **Given** a dependency graph where `REQ-001` → `SYS-001` and `REQ-002` → `SYS-002` (disjoint subgraphs)
  * **When** the traversal engine runs in `--downward` mode from `[REQ-001, REQ-002]`
  * **Then** the suspect set contains both `SYS-001` and `SYS-002`

* **System Scenario: STS-002-E2**
  * **Given** a dependency graph where both `REQ-001` and `REQ-002` reference `SYS-001` (overlapping)
  * **When** the traversal engine runs in `--downward` mode from `[REQ-001, REQ-002]`
  * **Then** `SYS-001` appears exactly once in the suspect set (deduplicated)

#### Test Case: STP-002-F (Warning emitted for unknown IDs, processing continues)

**Technique**: Fault Injection
**Target View**: Interface View
**Description**: Verify that IDs not found in the graph produce a warning but do not abort processing of valid IDs.

* **System Scenario: STS-002-F1**
  * **Given** a dependency graph containing `REQ-001` but not `REQ-999`
  * **When** the traversal engine processes changed IDs `[REQ-001, REQ-999]`
  * **Then** a warning for `REQ-999` is emitted to stderr and the suspect set for `REQ-001` is computed normally

#### Test Case: STP-002-G (Re-validation order is bottom-up for downward, top-down for upward)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify the re-validation order follows the correct sequence based on traversal direction.

* **System Scenario: STS-002-G1**
  * **Given** a suspect set containing IDs at REQ, SYS, ARCH, and MOD levels from downward traversal
  * **When** the traversal engine generates the re-validation order
  * **Then** MOD-level IDs appear first, followed by ARCH, then SYS, then REQ (bottom-up)

* **System Scenario: STS-002-G2**
  * **Given** a suspect set containing IDs at MOD, ARCH, SYS, and REQ levels from upward traversal
  * **When** the traversal engine generates the re-validation order
  * **Then** REQ-level IDs appear first, followed by SYS, then ARCH, then MOD (top-down)

---

### Component Verification: SYS-003 (Impact Report Formatter)

**Parent Requirements**: REQ-009, REQ-010, REQ-011, REQ-012, REQ-023, REQ-NF-002

#### Test Case: STP-003-A (Markdown report contains all four required sections)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify the markdown formatter produces a report with Changed IDs, Suspect Artifacts, Blast Radius, and Re-validation Order sections.

* **System Scenario: STS-003-A1**
  * **Given** traversal results with `changed_ids: [REQ-001]`, suspects at SYS and ARCH levels, and blast radius totals
  * **When** the formatter produces markdown output to `impact-report.md`
  * **Then** the file contains section headings matching "Changed IDs", "Suspect Artifacts", "Blast Radius", and "Re-validation Order"

#### Test Case: STP-003-B (JSON output conforms to defined schema)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify JSON output contains all required fields with correct types.

* **System Scenario: STS-003-B1**
  * **Given** traversal results with `changed_ids: [REQ-001]`, direction `downward`, suspects at SYS level, blast radius `{total: 1, by_level: {SYS: 1}}`
  * **When** the formatter produces JSON output
  * **Then** the JSON contains `changed_ids` (array), `direction` (string), `suspect_artifacts` (object), `blast_radius` (object with `total` number and `by_level` object), and `revalidation_order` (array)

#### Test Case: STP-003-C (Custom output path via --output flag)

**Technique**: Boundary Value Analysis
**Target View**: Interface View
**Description**: Verify the `--output` flag writes to the specified path and does not create the default file.

* **System Scenario: STS-003-C1**
  * **Given** traversal results and an output path of `/tmp/custom-report.md`
  * **When** the formatter writes with `--output /tmp/custom-report.md`
  * **Then** `/tmp/custom-report.md` exists with the report content and no `impact-report.md` is created in the V-Model directory

#### Test Case: STP-003-D (Deterministic reproducibility)

**Technique**: Equivalence Partitioning
**Target View**: Data Design View
**Description**: Verify the formatter produces byte-identical output on consecutive runs with the same input data.

* **System Scenario: STS-003-D1**
  * **Given** identical traversal results provided on two consecutive invocations
  * **When** the formatter produces JSON output twice
  * **Then** both JSON outputs are byte-identical

---

### Component Verification: SYS-004 (CLI Argument Parser)

**Parent Requirements**: REQ-001, REQ-008, REQ-014, REQ-018, REQ-025, REQ-IF-001, REQ-CN-001

#### Test Case: STP-004-A (Direction flags are mutually exclusive)

**Technique**: Boundary Value Analysis
**Target View**: Interface View
**Description**: Verify the parser rejects simultaneous use of `--downward`, `--upward`, and `--full`.

* **System Scenario: STS-004-A1**
  * **Given** command-line arguments `--downward --upward REQ-001 <dir>`
  * **When** the CLI parser processes the arguments
  * **Then** the parser exits with code 1 and emits an error message about mutually exclusive flags

#### Test Case: STP-004-B (Default direction is downward when no flag specified)

**Technique**: Equivalence Partitioning
**Target View**: Interface View
**Description**: Verify the parser defaults to downward traversal when no direction flag is provided.

* **System Scenario: STS-004-B1**
  * **Given** command-line arguments `REQ-001 <dir>` (no direction flag)
  * **When** the CLI parser processes the arguments
  * **Then** the direction is set to `downward`

#### Test Case: STP-004-C (Error when no V-Model artifacts found)

**Technique**: Fault Injection
**Target View**: Interface View
**Description**: Verify the parser detects empty directories and produces an actionable error.

* **System Scenario: STS-004-C1**
  * **Given** command-line arguments `REQ-001 /tmp/empty-dir` where `/tmp/empty-dir` contains no markdown files
  * **When** the CLI parser validates the directory
  * **Then** the parser exits with code 1 and stderr contains "No V-Model artifacts found in /tmp/empty-dir"

#### Test Case: STP-004-D (Last positional argument is V-Model directory)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify the parser correctly identifies the last positional argument as the V-Model directory path.

* **System Scenario: STS-004-D1**
  * **Given** command-line arguments `--downward REQ-001 REQ-002 /path/to/vmodel`
  * **When** the CLI parser processes the arguments
  * **Then** the V-Model directory is `/path/to/vmodel` and the changed IDs are `[REQ-001, REQ-002]`

#### Test Case: STP-004-E (Multiple changed IDs parsed correctly)

**Technique**: Boundary Value Analysis
**Target View**: Interface View
**Description**: Verify the parser accepts multiple IDs between the flags and the directory path.

* **System Scenario: STS-004-E1**
  * **Given** command-line arguments `--downward REQ-001 SYS-002 ARCH-003 /path/to/vmodel`
  * **When** the CLI parser processes the arguments
  * **Then** the changed IDs are `[REQ-001, SYS-002, ARCH-003]` and the V-Model directory is `/path/to/vmodel`

---

### Component Verification: SYS-005 (PowerShell Impact Analysis Script)

**Parent Requirements**: REQ-020, REQ-CN-002, REQ-IF-002

#### Test Case: STP-005-A (PowerShell JSON output matches Bash JSON output)

**Technique**: Equivalence Partitioning
**Target View**: Interface View
**Description**: Verify the PowerShell script produces identical JSON output structure and values as the Bash script for the same inputs.

* **System Scenario: STS-005-A1**
  * **Given** a V-Model directory with `REQ-001` → `SYS-001` → `ARCH-001` processed by both Bash and PowerShell scripts
  * **When** both scripts run with `--json --downward REQ-001 <dir>` (Bash) and `-Json -Downward -Ids REQ-001 -VModelDir <dir>` (PowerShell)
  * **Then** both JSON outputs have identical `changed_ids`, `direction`, `suspect_artifacts`, `blast_radius`, and `revalidation_order` values

#### Test Case: STP-005-B (PowerShell parameter syntax accepted)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify the PowerShell script accepts idiomatic PowerShell parameter names.

* **System Scenario: STS-005-B1**
  * **Given** PowerShell parameters `-Upward -Json -Output /tmp/report.json -Ids MOD-001 -VModelDir <dir>`
  * **When** the PowerShell script processes the parameters
  * **Then** the script produces valid JSON output with `"direction": "upward"` and `"changed_ids": ["MOD-001"]`

---

### Component Verification: SYS-006 (Extension Manifest Update)

**Parent Requirements**: REQ-021, REQ-022, REQ-CN-001, REQ-CN-003

#### Test Case: STP-006-A (Command registered in extension.yml with correct metadata)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify the extension manifest contains a correctly formatted entry for the impact-analysis command.

* **System Scenario: STS-006-A1**
  * **Given** the `extension.yml` file in the project root
  * **When** parsing the YAML for command entries under `provides.commands`
  * **Then** an entry exists with `name: "speckit.v-model.impact-analysis"`, a valid `file` path, and a `description` containing "deterministic" or "script"

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total System Components | 6 |
| Total System Test Cases (STP) | 20 |
| Total System Scenarios (STS) | 24 |
| SYS → STP Coverage | 100% |
| STP → STS Coverage | 100% |

**Validation Status**: ✅ Full Coverage
**Generated**: 2026-04-14
**Validated by**: `validate-system-coverage.sh` (deterministic)
