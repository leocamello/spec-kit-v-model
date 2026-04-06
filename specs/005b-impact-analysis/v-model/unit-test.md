# Unit Test Plan: Impact Analysis

**Feature Branch**: `005b-impact-analysis`
**Created**: 2026-04-14
**Status**: Approved
**Source**: `specs/005b-impact-analysis/v-model/module-design.md`

## Overview

This document defines the Unit Test Plan for the Impact Analysis feature. Every module design in `module-design.md` has one or more Unit Test Cases (UTP), and every Test Case has one or more executable Unit Scenarios (UTS) in technical format. Unit tests verify individual function behavior in isolation, testing inputs, outputs, edge cases, and error handling at the function level.

## ID Schema

- **Unit Test Case**: `UTP-{NNN}-{X}` — where NNN matches the parent MOD, X is a letter suffix (A, B, C...)
- **Unit Test Scenario**: `UTS-{NNN}-{X}{#}` — nested under the parent UTP, with numeric suffix (1, 2, 3...)
- Example: `UTS-001-A1` → Scenario 1 of Test Case A verifying MOD-001

## ISO 29119-4 Unit Test Techniques

- **Input Domain Testing** — Tests function inputs across valid and invalid domains
- **Boundary Value Analysis** — Tests edge values at domain boundaries
- **Error Guessing** — Tests likely failure modes based on function complexity
- **Statement Coverage** — Ensures every code path is exercised
- **Branch Coverage** — Ensures every conditional branch is tested

## Unit Tests

### Module Verification: MOD-001 (scan_files)

#### Test Case: UTP-001-A (Returns all markdown files recursively)
**Technique**: Input Domain Testing
**Description**: Verify scan_files discovers all *.md files including those in subdirectories.

* **Unit Scenario: UTS-001-A1**
  * **Input**: Directory with `a.md`, `sub/b.md`, `sub/deep/c.md`
  * **Expected Output**: Sorted list of 3 absolute paths
  * **Assertion**: Output contains all 3 paths, sorted alphabetically

#### Test Case: UTP-001-B (Returns empty for directory with no markdown)
**Technique**: Boundary Value Analysis
**Description**: Verify scan_files returns empty string for directory with no *.md files.

* **Unit Scenario: UTS-001-B1**
  * **Input**: Directory containing only `readme.txt` and `data.json`
  * **Expected Output**: Empty string
  * **Assertion**: Output is empty, no error

---

### Module Verification: MOD-002 (build_graph)

#### Test Case: UTP-002-A (Builds correct adjacency lists from simple cross-references)
**Technique**: Input Domain Testing
**Description**: Verify build_graph populates REFERENCES and REFERENCED_BY arrays correctly.

* **Unit Scenario: UTS-002-A1**
  * **Input**: Single file with `SYS-001` section containing reference to `REQ-001`
  * **Expected Output**: `REFERENCES[SYS-001]` contains `REQ-001`; `REFERENCED_BY[REQ-001]` contains `SYS-001`

* **Unit Scenario: UTS-002-A2**
  * **Input**: File with `ARCH-001` section referencing both `SYS-001` and `SYS-002`
  * **Expected Output**: `REFERENCES[ARCH-001]` contains `SYS-001 SYS-002`

#### Test Case: UTP-002-B (Handles all 13 ID prefix patterns)
**Technique**: Statement Coverage
**Description**: Verify the regex extracts all known V-Model ID patterns.

* **Unit Scenario: UTS-002-B1**
  * **Input**: File containing one ID from each prefix (REQ-001, ATP-001-A, SCN-001-A1, SYS-001, STP-001-A, STS-001-A1, ARCH-001, ITP-001-A, ITS-001-A1, MOD-001, UTP-001-A, UTS-001-A1, HAZ-001)
  * **Expected Output**: All 13 IDs present as nodes in the graph

---

### Module Verification: MOD-003 (classify_id)

#### Test Case: UTP-003-A (Classifies all ID prefixes correctly)
**Technique**: Equivalence Partitioning
**Description**: Verify classify_id returns the correct level name for every ID prefix.

* **Unit Scenario: UTS-003-A1**
  * **Input/Output pairs**: `REQ-001` → `REQ`, `SYS-002` → `SYS`, `ARCH-001` → `ARCH`, `MOD-003` → `MOD`, `HAZ-005` → `HAZ`, `ATP-001-A` → `ATP`, `STP-002-B` → `STP`, `ITP-001-A` → `ITP`, `UTP-003-A` → `UTP`, `SCN-001-A1` → `SCN`, `STS-002-B1` → `STS`, `ITS-001-A1` → `ITS`, `UTS-003-A1` → `UTS`

---

### Module Verification: MOD-004 (traverse_downward)

#### Test Case: UTP-004-A (Traverses single-hop downstream dependency)
**Technique**: Input Domain Testing
**Description**: Verify traverse_downward finds direct downstream dependents.

* **Unit Scenario: UTS-004-A1**
  * **Input**: Graph with `REFERENCED_BY[REQ-001]="SYS-001"`, changed ID: `REQ-001`
  * **Expected Output**: `SUSPECTS_DOWN[SYS]` contains `SYS-001`, blast radius total = 1

#### Test Case: UTP-004-B (Traverses multi-hop transitive dependencies)
**Technique**: Input Domain Testing
**Description**: Verify traverse_downward follows transitive chains.

* **Unit Scenario: UTS-004-B1**
  * **Input**: Graph with `REQ-001` → `SYS-001` → `ARCH-001` → `MOD-001`, changed ID: `REQ-001`
  * **Expected Output**: Suspects include `SYS-001`, `ARCH-001`, `MOD-001`

#### Test Case: UTP-004-C (Handles cycles without infinite loop)
**Technique**: Error Guessing
**Description**: Verify cycle detection terminates traversal.

* **Unit Scenario: UTS-004-C1**
  * **Input**: Graph with `SYS-001` → `ARCH-001` → `SYS-001` (cycle), changed ID: `SYS-001`
  * **Expected Output**: Traversal completes, `ARCH-001` in suspects, cycle warning on stderr

#### Test Case: UTP-004-D (Returns empty set for isolated ID)
**Technique**: Boundary Value Analysis
**Description**: Verify traverse_downward returns empty when ID has no downstream references.

* **Unit Scenario: UTS-004-D1**
  * **Input**: Graph where `UTS-001-A1` exists but nothing references it in `REFERENCED_BY`
  * **Expected Output**: Empty suspect set, blast radius total = 0

---

### Module Verification: MOD-005 (traverse_upward)

#### Test Case: UTP-005-A (Traverses upstream references)
**Technique**: Input Domain Testing
**Description**: Verify traverse_upward follows references edges upward.

* **Unit Scenario: UTS-005-A1**
  * **Input**: Graph with `REFERENCES[MOD-001]="ARCH-001"`, `REFERENCES[ARCH-001]="SYS-001"`, changed ID: `MOD-001`
  * **Expected Output**: Suspects include `ARCH-001` and `SYS-001`

---

### Module Verification: MOD-006 (traverse_full)

#### Test Case: UTP-006-A (Combines downward and upward results)
**Technique**: Input Domain Testing
**Description**: Verify traverse_full produces both upstream and downstream results.

* **Unit Scenario: UTS-006-A1**
  * **Input**: Graph where `SYS-002` has upstream `REQ-001` and downstream `ARCH-002`, changed ID: `SYS-002`
  * **Expected Output**: Upstream contains `REQ-001`, downstream contains `ARCH-002`, both sets non-empty

---

### Module Verification: MOD-007 (build_revalidation_order)

#### Test Case: UTP-007-A (Bottom-up order for downward direction)
**Technique**: Input Domain Testing
**Description**: Verify bottom-up ordering for downward traversal.

* **Unit Scenario: UTS-007-A1**
  * **Input**: Suspects at levels `[REQ, SYS, ARCH, MOD]`, direction: `downward`
  * **Expected Output**: Order is `MOD-* → ARCH-* → SYS-* → REQ-*`

#### Test Case: UTP-007-B (Top-down order for upward direction)
**Technique**: Input Domain Testing
**Description**: Verify top-down ordering for upward traversal.

* **Unit Scenario: UTS-007-B1**
  * **Input**: Suspects at levels `[MOD, ARCH, SYS, REQ]`, direction: `upward`
  * **Expected Output**: Order is `REQ-* → SYS-* → ARCH-* → MOD-*`

---

### Module Verification: MOD-008 (format_markdown)

#### Test Case: UTP-008-A (Produces all required markdown sections)
**Technique**: Statement Coverage
**Description**: Verify markdown output includes all four required sections.

* **Unit Scenario: UTS-008-A1**
  * **Input**: Results with changed IDs, suspects, blast radius, re-validation order
  * **Expected Output**: File contains headings: "Changed IDs", "Suspect Artifacts", "Blast Radius", "Re-validation Order"

#### Test Case: UTP-008-B (Full mode produces upstream/downstream subsections)
**Technique**: Branch Coverage
**Description**: Verify full mode creates separate subsections.

* **Unit Scenario: UTS-008-B1**
  * **Input**: Full traversal results with upstream and downstream suspects
  * **Expected Output**: File contains "Upstream" and "Downstream" subsections

---

### Module Verification: MOD-009 (format_json)

#### Test Case: UTP-009-A (Produces valid JSON with all schema fields)
**Technique**: Input Domain Testing
**Description**: Verify JSON output is parseable and contains required fields.

* **Unit Scenario: UTS-009-A1**
  * **Input**: Results for downward traversal of `REQ-001` with suspects `{SYS: [SYS-001]}`
  * **Expected Output**: Valid JSON with `changed_ids`, `direction`, `suspect_artifacts`, `blast_radius`, `revalidation_order`

#### Test Case: UTP-009-B (JSON special characters in IDs are escaped)
**Technique**: Error Guessing
**Description**: Verify JSON output handles any special characters correctly.

* **Unit Scenario: UTS-009-B1**
  * **Input**: ID with standard pattern `REQ-NF-001`
  * **Expected Output**: JSON string correctly represents the hyphenated ID without escaping issues

---

### Module Verification: MOD-010 (parse_args)

#### Test Case: UTP-010-A (Parses all valid flag combinations)
**Technique**: Input Domain Testing
**Description**: Verify all valid argument combinations are parsed correctly.

* **Unit Scenario: UTS-010-A1**
  * **Input**: `--downward --json --output /tmp/out.md REQ-001 /dir`
  * **Expected Output**: `DIRECTION=downward`, `JSON_MODE=true`, `OUTPUT_PATH=/tmp/out.md`, `CHANGED_IDS=(REQ-001)`, `VMODEL_DIR=/dir`

#### Test Case: UTP-010-B (Rejects mutually exclusive direction flags)
**Technique**: Error Guessing
**Description**: Verify error on conflicting flags.

* **Unit Scenario: UTS-010-B1**
  * **Input**: `--downward --upward REQ-001 /dir`
  * **Expected Output**: Exit code 1, error message about mutually exclusive flags

#### Test Case: UTP-010-C (Defaults to downward when no direction specified)
**Technique**: Boundary Value Analysis
**Description**: Verify default direction.

* **Unit Scenario: UTS-010-C1**
  * **Input**: `REQ-001 /dir`
  * **Expected Output**: `DIRECTION=downward`

---

### Module Verification: MOD-011 (main)

#### Test Case: UTP-011-A (End-to-end pipeline produces correct output)
**Technique**: Statement Coverage
**Description**: Verify main orchestrates the full pipeline from args to output.

* **Unit Scenario: UTS-011-A1**
  * **Input**: Valid V-Model directory with `REQ-001` → `SYS-001`, args: `REQ-001 <dir>`
  * **Expected Output**: `impact-report.md` created with `SYS-001` as suspect, exit code 0

---

### Module Verification: MOD-012 (warn_unknown_id)

#### Test Case: UTP-012-A (Warning for unknown ID, valid IDs returned)
**Technique**: Input Domain Testing
**Description**: Verify unknown IDs produce warnings and valid IDs are passed through.

* **Unit Scenario: UTS-012-A1**
  * **Input**: Changed IDs `[REQ-001, REQ-999]`, graph contains `REQ-001` but not `REQ-999`
  * **Expected Output**: Warning on stderr for `REQ-999`, returned list contains only `REQ-001`

---

### Module Verification: MOD-013 (Invoke-ImpactAnalysis PS)

#### Test Case: UTP-013-A (PowerShell entry point produces identical output to Bash)
**Technique**: Equivalence Partitioning
**Description**: Verify PowerShell main function mirrors Bash main behavior.

* **Unit Scenario: UTS-013-A1**
  * **Input**: `-Json -Downward -Ids REQ-001 -VModelDir <dir>` with same V-Model data
  * **Expected Output**: JSON identical to Bash `--json --downward REQ-001 <dir>`

---

### Module Verification: MOD-014 (Build-DependencyGraph PS)

#### Test Case: UTP-014-A (PowerShell graph matches Bash graph)
**Technique**: Equivalence Partitioning
**Description**: Verify PowerShell graph construction produces same adjacency data.

* **Unit Scenario: UTS-014-A1**
  * **Input**: Same markdown files as Bash tests
  * **Expected Output**: `$References` and `$ReferencedBy` hashtables contain identical mappings to Bash arrays

---

### Module Verification: MOD-015 (Format-ImpactReport PS)

#### Test Case: UTP-015-A (PowerShell JSON output matches Bash JSON output)
**Technique**: Equivalence Partitioning
**Description**: Verify PowerShell format function produces identical JSON.

* **Unit Scenario: UTS-015-A1**
  * **Input**: Same traversal results as Bash format_json tests
  * **Expected Output**: JSON with identical structure and values

---

### Module Verification: MOD-016 (Manifest Configuration)

#### Test Case: UTP-016-A (Manifest entry contains required fields)
**Technique**: Input Domain Testing
**Description**: Verify the extension.yml entry for impact-analysis has all required fields.

* **Unit Scenario: UTS-016-A1**
  * **Input**: `extension.yml` file with `speckit.v-model.impact-analysis` entry
  * **Expected Output**: Entry contains `name`, `file`, and `description` fields; description indicates deterministic script-based command

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Module Designs | 16 |
| Total Unit Test Cases (UTP) | 25 |
| Total Unit Scenarios (UTS) | 27 |
| MOD → UTP Coverage | 100% |
| UTP → UTS Coverage | 100% |

**Validation Status**: ✅ Full Coverage
**Generated**: 2026-04-14
**Validated by**: `validate-module-coverage.sh` (deterministic)
