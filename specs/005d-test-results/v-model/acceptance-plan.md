# Acceptance Test Plan: Test Results Ingestion

**Feature Branch**: `feature/005d-test-results`
**Created**: 2026-04-05
**Status**: Approved
**Source**: `specs/005d-test-results/v-model/requirements.md`

## Overview

This document defines the Acceptance Test Plan for the Test Results Ingestion feature. Every requirement in `requirements.md` has one or more Test Cases (ATP), and every Test Case has one or more executable User Scenarios (SCN) in BDD format (Given/When/Then). The plan covers JUnit XML parsing, V-Model scenario ID matching, in-place matrix status updates, Date and Commit column addition, Cobertura XML coverage ingestion, coverage-to-module mapping (convention and override), summary output, exit code semantics, JSON output, PowerShell parity, and constraint enforcement (deterministic, in-place, non-destructive).

## ID Schema

- **Test Case**: `ATP-{NNN}-{X}` — where NNN matches the parent REQ, X is a letter suffix (A, B, C...)
- **Scenario**: `SCN-{NNN}-{X}{#}` — nested under the parent ATP, with numeric suffix (1, 2, 3...)
- Example: `SCN-001-A1` → Scenario 1 of Test Case A validating REQ-001

## Acceptance Tests

### Requirement Validation: REQ-001 (JUnit XML Parsing)

#### Test Case: ATP-001-A (Parse single testsuite)
**Linked Requirement:** REQ-001
**Description:** Verify the command parses all `<testcase>` elements from a JUnit XML file containing a single `<testsuite>`.
**Validation Condition:** All testcase elements are extracted with correct name, time, and child element data.
**Expected Result:** A JUnit XML with 5 testcases produces 5 parsed results.

* **User Scenario: SCN-001-A1**
  * **Given** a JUnit XML file containing a single `<testsuite>` with 5 `<testcase>` elements
  * **When** the user runs the command with `--input test-results.xml`
  * **Then** the command processes all 5 test cases

#### Test Case: ATP-001-B (Parse multiple testsuites)
**Linked Requirement:** REQ-001
**Description:** Verify the command parses testcases across multiple `<testsuite>` elements within a single `<testsuites>` root.
**Validation Condition:** Testcases from all testsuites are aggregated.
**Expected Result:** A JUnit XML with 3 testsuites containing 2, 3, and 4 testcases respectively produces 9 parsed results.

* **User Scenario: SCN-001-B1**
  * **Given** a JUnit XML file with a `<testsuites>` root containing 3 `<testsuite>` elements with 2, 3, and 4 `<testcase>` elements respectively
  * **When** the user runs the command with `--input multi-suite.xml`
  * **Then** the command processes all 9 test cases from all 3 testsuites

---

### Requirement Validation: REQ-002 (V-Model ID Extraction)

#### Test Case: ATP-002-A (Extract SCN IDs from test names)
**Linked Requirement:** REQ-002
**Description:** Verify SCN-pattern IDs are extracted from testcase name attributes.
**Validation Condition:** SCN IDs are correctly matched and mapped to Matrix A rows.
**Expected Result:** A testcase named "SCN-001-A1 Given valid input" yields ID "SCN-001-A1".

* **User Scenario: SCN-002-A1**
  * **Given** a JUnit XML with a testcase named "SCN-001-A1 Given valid sensor data"
  * **When** the command parses the test results
  * **Then** the ID "SCN-001-A1" is extracted and mapped to Matrix A

* **User Scenario: SCN-002-A2**
  * **Given** a JUnit XML with a testcase named "test_SCN-005-B2_boundary_check"
  * **When** the command parses the test results
  * **Then** the ID "SCN-005-B2" is extracted regardless of its position in the test name

#### Test Case: ATP-002-B (Extract STS, ITS, UTS IDs)
**Linked Requirement:** REQ-002
**Description:** Verify STS, ITS, and UTS pattern IDs are extracted and mapped to the correct matrices.
**Validation Condition:** Each ID type maps to its correct matrix (STS→B, ITS→C, UTS→D).
**Expected Result:** STS-001-A1 maps to Matrix B, ITS-002-A1 maps to Matrix C, UTS-003-A1 maps to Matrix D.

* **User Scenario: SCN-002-B1**
  * **Given** a JUnit XML with testcases named "STS-001-A1 system threshold test", "ITS-002-A1 integration contract test", and "UTS-003-A1 unit boundary test"
  * **When** the command parses the test results
  * **Then** STS-001-A1 is mapped to Matrix B, ITS-002-A1 is mapped to Matrix C, and UTS-003-A1 is mapped to Matrix D

#### Test Case: ATP-002-C (No match for non-V-Model test names)
**Linked Requirement:** REQ-002
**Description:** Verify testcases without V-Model IDs are ignored.
**Validation Condition:** Testcases without matching ID patterns are not included in ingestion results.
**Expected Result:** A testcase named "test_login_flow" is skipped without error.

* **User Scenario: SCN-002-C1**
  * **Given** a JUnit XML containing 3 testcases, only 1 of which contains a V-Model ID
  * **When** the command parses the test results
  * **Then** only the 1 matching testcase is processed and the other 2 are reported as unmatched

---

### Requirement Validation: REQ-003 (Test Result Classification)

#### Test Case: ATP-003-A (Classify passed tests)
**Linked Requirement:** REQ-003
**Description:** Verify testcases with no failure/error/skipped child elements are classified as Passed.
**Validation Condition:** Status is `✅ Passed`.
**Expected Result:** A testcase with only a closing tag produces Passed status.

* **User Scenario: SCN-003-A1**
  * **Given** a JUnit XML with `<testcase name="SCN-001-A1 test"/>` (self-closing, no child elements)
  * **When** the command classifies the test result
  * **Then** SCN-001-A1 is classified as `✅ Passed`

#### Test Case: ATP-003-B (Classify failed tests)
**Linked Requirement:** REQ-003
**Description:** Verify testcases with `<failure>` or `<error>` child elements are classified as Failed.
**Validation Condition:** Status is `❌ Failed`.
**Expected Result:** A testcase with a `<failure>` child produces Failed status.

* **User Scenario: SCN-003-B1**
  * **Given** a JUnit XML with a testcase containing `<failure message="assertion error"/>`
  * **When** the command classifies the test result
  * **Then** the test is classified as `❌ Failed`

* **User Scenario: SCN-003-B2**
  * **Given** a JUnit XML with a testcase containing `<error message="runtime exception"/>`
  * **When** the command classifies the test result
  * **Then** the test is classified as `❌ Failed`

#### Test Case: ATP-003-C (Classify skipped tests)
**Linked Requirement:** REQ-003
**Description:** Verify testcases with `<skipped>` child elements are classified as Skipped.
**Validation Condition:** Status is `⏭️ Skipped`.
**Expected Result:** A testcase with a `<skipped>` child produces Skipped status.

* **User Scenario: SCN-003-C1**
  * **Given** a JUnit XML with a testcase containing `<skipped message="hardware not available"/>`
  * **When** the command classifies the test result
  * **Then** the test is classified as `⏭️ Skipped`

---

### Requirement Validation: REQ-004 (Matrix Path Resolution)

#### Test Case: ATP-004-A (Explicit --matrix argument)
**Linked Requirement:** REQ-004
**Description:** Verify the command uses the explicit `--matrix` path when provided.
**Validation Condition:** The specified matrix file is read and updated.
**Expected Result:** The file at the given path is modified.

* **User Scenario: SCN-004-A1**
  * **Given** a JUnit XML file and a traceability matrix at `/tmp/test-matrix.md`
  * **When** the user runs the command with `--matrix /tmp/test-matrix.md`
  * **Then** the file at `/tmp/test-matrix.md` is updated with test results

#### Test Case: ATP-004-B (Default matrix resolution via setup-v-model)
**Linked Requirement:** REQ-004
**Description:** Verify the command defaults to the matrix path from `setup-v-model.sh --json` when `--matrix` is omitted.
**Validation Condition:** The matrix in the current feature's v-model/ directory is updated.
**Expected Result:** Running from within a feature directory updates that feature's traceability-matrix.md.

* **User Scenario: SCN-004-B1**
  * **Given** a JUnit XML file and the current directory is a feature directory with `v-model/traceability-matrix.md`
  * **When** the user runs the command with `--input results.xml` (no `--matrix`)
  * **Then** the `v-model/traceability-matrix.md` in the current feature directory is updated

---

### Requirement Validation: REQ-005 (In-Place Status Update)

#### Test Case: ATP-005-A (Replace Untested with Passed)
**Linked Requirement:** REQ-005
**Description:** Verify `⬜ Untested` is replaced with `✅ Passed` for matched passing tests.
**Validation Condition:** The specific matrix row is updated while other rows remain unchanged.
**Expected Result:** Row with SCN-001-A1 changes from `⬜ Untested` to `✅ Passed`.

* **User Scenario: SCN-005-A1**
  * **Given** a matrix with SCN-001-A1 status `⬜ Untested` and SCN-001-A2 status `⬜ Untested`
  * **And** a JUnit XML with SCN-001-A1 passed (no child elements)
  * **When** the command ingests the test results
  * **Then** SCN-001-A1 status is `✅ Passed` and SCN-001-A2 status remains `⬜ Untested`

#### Test Case: ATP-005-B (Replace Untested with Failed)
**Linked Requirement:** REQ-005
**Description:** Verify `⬜ Untested` is replaced with `❌ Failed` for matched failing tests.
**Validation Condition:** The matrix row shows Failed status.
**Expected Result:** Row with STS-002-B1 changes to `❌ Failed`.

* **User Scenario: SCN-005-B1**
  * **Given** a matrix with STS-002-B1 status `⬜ Untested`
  * **And** a JUnit XML with STS-002-B1 containing a `<failure>` element
  * **When** the command ingests the test results
  * **Then** STS-002-B1 status is `❌ Failed`

#### Test Case: ATP-005-C (Replace Untested with Skipped)
**Linked Requirement:** REQ-005
**Description:** Verify `⬜ Untested` is replaced with `⏭️ Skipped` for matched skipped tests.
**Validation Condition:** The matrix row shows Skipped status.
**Expected Result:** Row with UTS-004-A1 changes to `⏭️ Skipped`.

* **User Scenario: SCN-005-C1**
  * **Given** a matrix with UTS-004-A1 status `⬜ Untested`
  * **And** a JUnit XML with UTS-004-A1 containing a `<skipped>` element
  * **When** the command ingests the test results
  * **Then** UTS-004-A1 status is `⏭️ Skipped`

---

### Requirement Validation: REQ-006 (Date Column Addition)

#### Test Case: ATP-006-A (Date column added after ingestion)
**Linked Requirement:** REQ-006
**Description:** Verify a Date column is added to each matrix table after ingestion.
**Validation Condition:** The header row contains "Date" and data rows contain ISO 8601 dates.
**Expected Result:** Each updated matrix table has a Date column with the current date.

* **User Scenario: SCN-006-A1**
  * **Given** a matrix with no Date column and a JUnit XML with matching test IDs
  * **When** the command ingests the test results on 2026-04-05
  * **Then** the matrix tables gain a "Date" column and matched rows show "2026-04-05"

---

### Requirement Validation: REQ-007 (Commit Column Addition)

#### Test Case: ATP-007-A (Commit column from current HEAD)
**Linked Requirement:** REQ-007
**Description:** Verify the Commit column is populated from the current Git HEAD.
**Validation Condition:** The Commit column contains a 7-character abbreviated SHA.
**Expected Result:** Rows show a valid 7-character hex commit SHA.

* **User Scenario: SCN-007-A1**
  * **Given** a matrix with no Commit column, a JUnit XML with matching IDs, and the current Git HEAD is `abc1234def5678`
  * **When** the command ingests the test results without `--commit-sha`
  * **Then** the matrix tables gain a "Commit" column and matched rows show "abc1234"

#### Test Case: ATP-007-B (Commit column from --commit-sha argument)
**Linked Requirement:** REQ-007
**Description:** Verify the `--commit-sha` argument overrides automatic HEAD detection.
**Validation Condition:** The Commit column contains the provided SHA.
**Expected Result:** Rows show the explicitly provided SHA.

* **User Scenario: SCN-007-B1**
  * **Given** a JUnit XML with matching IDs
  * **When** the user runs the command with `--commit-sha deadbeef1234567`
  * **Then** the Commit column shows "deadbee" (first 7 characters)

---

### Requirement Validation: REQ-008 (Cobertura Coverage Column)

#### Test Case: ATP-008-A (Coverage column added to Matrix D)
**Linked Requirement:** REQ-008
**Description:** Verify a Coverage column is added to Matrix D when `--coverage` is provided.
**Validation Condition:** Matrix D rows display statement and branch coverage percentages.
**Expected Result:** Matrix D rows for matched modules show coverage values.

* **User Scenario: SCN-008-A1**
  * **Given** a Matrix D with UTS-001-A1 linked to MOD-001
  * **And** a Cobertura XML with `src/reader.py` having 98.2% line-rate and 94.1% branch-rate
  * **And** MOD-001 maps to `src/reader.py` via module-design.md
  * **When** the command ingests with `--coverage cobertura.xml`
  * **Then** the Matrix D row for MOD-001 shows "98.2% stmt / 94.1% branch" in the Coverage column

#### Test Case: ATP-008-B (No Coverage column without --coverage)
**Linked Requirement:** REQ-008
**Description:** Verify the Coverage column is NOT added when `--coverage` is omitted.
**Validation Condition:** Matrix D has no Coverage column.
**Expected Result:** Matrix D retains its original column structure.

* **User Scenario: SCN-008-B1**
  * **Given** a Matrix D with standard columns
  * **When** the command ingests test results without `--coverage`
  * **Then** Matrix D does not gain a Coverage column

---

### Requirement Validation: REQ-009 (Coverage-to-Module Mapping)

#### Test Case: ATP-009-A (Convention-based mapping from module-design.md)
**Linked Requirement:** REQ-009
**Description:** Verify the command maps Cobertura file coverage to MOD-NNN using file path references in module-design.md.
**Validation Condition:** Coverage is correctly attributed to the module that references the source file.
**Expected Result:** MOD-001 references `src/reader.py` in module-design.md; Cobertura coverage for `src/reader.py` appears in MOD-001 row.

* **User Scenario: SCN-009-A1**
  * **Given** a module-design.md where MOD-001 references `src/reader.py` and MOD-002 references `src/writer.py`
  * **And** a Cobertura XML with coverage for both `src/reader.py` and `src/writer.py`
  * **When** the command ingests with `--coverage cobertura.xml`
  * **Then** MOD-001 shows `src/reader.py` coverage and MOD-002 shows `src/writer.py` coverage

#### Test Case: ATP-009-B (Override mapping via coverage-map.yml)
**Linked Requirement:** REQ-009
**Description:** Verify `coverage-map.yml` takes precedence over convention-based mapping.
**Validation Condition:** When both strategies would produce different results, the override wins.
**Expected Result:** MOD-001 maps to the file specified in `coverage-map.yml`, not module-design.md.

* **User Scenario: SCN-009-B1**
  * **Given** a module-design.md where MOD-001 references `src/old_reader.py`
  * **And** a `coverage-map.yml` mapping MOD-001 to `["src/new_reader.py"]`
  * **And** a Cobertura XML with coverage for both files
  * **When** the command ingests with `--coverage cobertura.xml --coverage-map map.yml`
  * **Then** MOD-001 shows coverage from `src/new_reader.py` (override wins)

#### Test Case: ATP-009-C (Multi-file module coverage aggregation)
**Linked Requirement:** REQ-009
**Description:** Verify that when a module maps to multiple files, coverage is aggregated.
**Validation Condition:** Coverage values are weighted averages across all mapped files.
**Expected Result:** MOD-001 mapped to 2 files shows the weighted aggregate coverage.

* **User Scenario: SCN-009-C1**
  * **Given** a `coverage-map.yml` mapping MOD-001 to `["src/reader.py", "src/reader_utils.py"]`
  * **And** a Cobertura XML with `src/reader.py` at 100% line-rate and `src/reader_utils.py` at 80% line-rate
  * **When** the command ingests with `--coverage cobertura.xml --coverage-map map.yml`
  * **Then** MOD-001 shows an aggregated coverage value reflecting both files

---

### Requirement Validation: REQ-010 (Summary Output)

#### Test Case: ATP-010-A (Summary with per-matrix counts)
**Linked Requirement:** REQ-010
**Description:** Verify the command prints a summary showing pass/fail/skip per matrix.
**Validation Condition:** Summary includes totals for Matrix A, B, C, D individually and overall.
**Expected Result:** Summary shows "Matrix A: 12 passed, 0 failed, 0 skipped" format.

* **User Scenario: SCN-010-A1**
  * **Given** a JUnit XML with 20 testcases matching IDs across all 4 matrices
  * **When** the command ingests the test results
  * **Then** the summary output shows per-matrix counts (passed, failed, skipped) and overall totals

#### Test Case: ATP-010-B (Summary with coverage data)
**Linked Requirement:** REQ-010
**Description:** Verify the summary includes coverage percentages when `--coverage` is provided.
**Validation Condition:** Summary includes per-module and overall coverage data.
**Expected Result:** Summary shows per-module coverage and overall aggregates.

* **User Scenario: SCN-010-B1**
  * **Given** a JUnit XML with matching IDs and a Cobertura XML with coverage data
  * **When** the command ingests with `--coverage cobertura.xml`
  * **Then** the summary includes a "Coverage" section with per-module and overall percentages

---

### Requirement Validation: REQ-011 (Exit Code 0 — All Passed)

#### Test Case: ATP-011-A (All tests passed)
**Linked Requirement:** REQ-011
**Description:** Verify exit code 0 when all matched tests pass.
**Validation Condition:** Exit code is 0.
**Expected Result:** Command exits with code 0.

* **User Scenario: SCN-011-A1**
  * **Given** a JUnit XML where all testcases with V-Model IDs pass (no failures or skips)
  * **When** the command ingests the test results
  * **Then** the exit code is 0

---

### Requirement Validation: REQ-012 (Exit Code 1 — Failures)

#### Test Case: ATP-012-A (At least one failure)
**Linked Requirement:** REQ-012
**Description:** Verify exit code 1 when any matched test fails.
**Validation Condition:** Exit code is 1.
**Expected Result:** Command exits with code 1.

* **User Scenario: SCN-012-A1**
  * **Given** a JUnit XML where 4 tests pass and 1 test with a V-Model ID has a `<failure>` element
  * **When** the command ingests the test results
  * **Then** the exit code is 1

---

### Requirement Validation: REQ-013 (Exit Code 2 — No Matches)

#### Test Case: ATP-013-A (No V-Model IDs matched)
**Linked Requirement:** REQ-013
**Description:** Verify exit code 2 when no testcases contain V-Model IDs.
**Validation Condition:** Exit code is 2.
**Expected Result:** Command exits with code 2.

* **User Scenario: SCN-013-A1**
  * **Given** a JUnit XML where no testcase names contain V-Model IDs
  * **When** the command ingests the test results
  * **Then** the exit code is 2

---

### Requirement Validation: REQ-014 (JSON Output)

#### Test Case: ATP-014-A (JSON output with --json flag)
**Linked Requirement:** REQ-014
**Description:** Verify `--json` produces structured JSON with status mappings, summaries, and coverage.
**Validation Condition:** Output is valid JSON with all required fields.
**Expected Result:** JSON contains test_results, summary, and (when applicable) coverage sections.

* **User Scenario: SCN-014-A1**
  * **Given** a JUnit XML with 5 matching testcases
  * **When** the user runs the command with `--json`
  * **Then** stdout contains valid JSON with `test_results` (array of ID→status mappings) and `summary` (pass/fail/skip counts)

* **User Scenario: SCN-014-A2**
  * **Given** a JUnit XML and a Cobertura XML
  * **When** the user runs the command with `--json --coverage cobertura.xml`
  * **Then** stdout contains valid JSON with `test_results`, `summary`, and `coverage` sections

---

### Requirement Validation: REQ-015 (Duplicate ID Handling)

#### Test Case: ATP-015-A (Last occurrence wins for duplicate IDs)
**Linked Requirement:** REQ-015
**Description:** Verify that when the same scenario ID appears multiple times, the last occurrence is used.
**Validation Condition:** The status reflects the final testcase entry for that ID.
**Expected Result:** If SCN-001-A1 appears twice (first failed, then passed), the status is Passed.

* **User Scenario: SCN-015-A1**
  * **Given** a JUnit XML with two testcases named "SCN-001-A1 attempt 1" (with `<failure>`) and "SCN-001-A1 attempt 2" (passed)
  * **When** the command ingests the test results
  * **Then** SCN-001-A1 is classified as `✅ Passed` (last occurrence wins)

---

### Requirement Validation: REQ-016 (Unmatched Rows Preserved)

#### Test Case: ATP-016-A (Unexercised scenarios remain Untested)
**Linked Requirement:** REQ-016
**Description:** Verify matrix rows whose IDs are not in the JUnit XML retain `⬜ Untested`.
**Validation Condition:** Untested rows are not modified.
**Expected Result:** Only matched rows change status; all others remain `⬜ Untested`.

* **User Scenario: SCN-016-A1**
  * **Given** a matrix with SCN-001-A1, SCN-001-A2, SCN-002-A1 all `⬜ Untested`
  * **And** a JUnit XML containing only SCN-001-A1
  * **When** the command ingests the test results
  * **Then** SCN-001-A1 shows the new status and SCN-001-A2 and SCN-002-A1 remain `⬜ Untested`

---

### Requirement Validation: REQ-017 (Extra IDs in JUnit XML)

#### Test Case: ATP-017-A (Unmatched IDs reported and skipped)
**Linked Requirement:** REQ-017
**Description:** Verify IDs in JUnit XML that don't exist in the matrix are reported but don't cause errors.
**Validation Condition:** Summary reports unmatched IDs; exit code is not affected.
**Expected Result:** Summary shows "2 unmatched IDs" but ingestion completes normally.

* **User Scenario: SCN-017-A1**
  * **Given** a JUnit XML with SCN-001-A1 (exists in matrix) and SCN-999-Z9 (does not exist in matrix)
  * **When** the command ingests the test results
  * **Then** SCN-001-A1 is processed normally and the summary reports SCN-999-Z9 as an unmatched ID

---

### Requirement Validation: REQ-018 (coverage-map.yml Schema)

#### Test Case: ATP-018-A (Valid coverage-map.yml parsed correctly)
**Linked Requirement:** REQ-018
**Description:** Verify the command parses a well-formed coverage-map.yml with the defined schema.
**Validation Condition:** Module-to-file mappings are correctly extracted.
**Expected Result:** MOD-001 maps to the files listed in the YAML.

* **User Scenario: SCN-018-A1**
  * **Given** a `coverage-map.yml` with `mappings: [{mod_id: "MOD-001", files: ["src/reader.py"]}]`
  * **When** the command parses the coverage map
  * **Then** MOD-001 is associated with `src/reader.py` for coverage aggregation

---

### Requirement Validation: REQ-019 (Coverage Format)

#### Test Case: ATP-019-A (Coverage column format)
**Linked Requirement:** REQ-019
**Description:** Verify the Coverage column displays the correct format with one decimal place.
**Validation Condition:** Format is `{stmt}% stmt / {branch}% branch`.
**Expected Result:** Coverage of 98.23% stmt and 94.11% branch displays as "98.2% stmt / 94.1% branch".

* **User Scenario: SCN-019-A1**
  * **Given** a Cobertura XML reporting 0.9823 line-rate and 0.9411 branch-rate for a module's file
  * **When** the command ingests with `--coverage`
  * **Then** the Coverage column shows "98.2% stmt / 94.1% branch"

---

### Requirement Validation: REQ-020 (Coverage Threshold Warning)

#### Test Case: ATP-020-A (Below-threshold modules flagged)
**Linked Requirement:** REQ-020
**Description:** Verify modules below the configured coverage threshold are flagged with ⚠.
**Validation Condition:** Coverage column includes `⚠` indicator.
**Expected Result:** A module at 87.5% with threshold at 100% shows "87.5% stmt / 82.3% branch ⚠".

* **User Scenario: SCN-020-A1**
  * **Given** an `extension.yml` with `coverage_threshold: 100`
  * **And** a Cobertura XML with a module at 87.5% stmt / 82.3% branch
  * **When** the command ingests with `--coverage`
  * **Then** the Coverage column for that module includes `⚠`

---

### Requirement Validation: REQ-NF-001 (Determinism)

#### Test Case: ATP-NF-001-A (Identical input produces identical output)
**Linked Requirement:** REQ-NF-001
**Description:** Verify the command is deterministic: same inputs yield same outputs.
**Validation Condition:** Two runs with identical inputs produce byte-identical matrix files and summary output.
**Expected Result:** `diff` between the two output files shows no differences.

* **User Scenario: SCN-NF-001-A1**
  * **Given** identical JUnit XML, matrix file, and commit SHA
  * **When** the command is run twice
  * **Then** both output matrix files and summary text are identical

---

### Requirement Validation: REQ-NF-002 (Zero Dependencies)

#### Test Case: ATP-NF-002-A (Python helper uses only stdlib)
**Linked Requirement:** REQ-NF-002
**Description:** Verify the Python helper has no external imports.
**Validation Condition:** All imports are from the Python standard library.
**Expected Result:** `grep import parse_test_results.py` shows only stdlib modules.

* **User Scenario: SCN-NF-002-A1**
  * **Given** the `parse_test_results.py` script
  * **When** the imports are inspected
  * **Then** only `xml.etree.ElementTree`, `json`, `re`, `sys`, `argparse`, and `os` are imported

---

### Requirement Validation: REQ-IF-001 (Bash CLI Interface)

#### Test Case: ATP-IF-001-A (All CLI arguments accepted)
**Linked Requirement:** REQ-IF-001
**Description:** Verify the bash wrapper accepts all documented arguments.
**Validation Condition:** Command runs with all arguments without errors.
**Expected Result:** `ingest-test-results.sh --input f.xml --coverage c.xml --matrix m.md --coverage-map map.yml --commit-sha abc1234 --json` runs successfully.

* **User Scenario: SCN-IF-001-A1**
  * **Given** valid input files for all arguments
  * **When** the user runs `ingest-test-results.sh --input f.xml --coverage c.xml --matrix m.md --coverage-map map.yml --commit-sha abc1234 --json`
  * **Then** the command executes without argument parsing errors

#### Test Case: ATP-IF-001-B (--help flag)
**Linked Requirement:** REQ-IF-001
**Description:** Verify `--help` displays usage information.
**Validation Condition:** Help text includes argument descriptions and exits with code 0.
**Expected Result:** Usage text is printed to stdout.

* **User Scenario: SCN-IF-001-B1**
  * **Given** the `ingest-test-results.sh` script
  * **When** the user runs `ingest-test-results.sh --help`
  * **Then** usage information is printed and the exit code is 0

---

### Requirement Validation: REQ-IF-002 (PowerShell CLI Interface)

#### Test Case: ATP-IF-002-A (PowerShell parameters accepted)
**Linked Requirement:** REQ-IF-002
**Description:** Verify the PowerShell wrapper accepts all documented parameters.
**Validation Condition:** Script runs with all parameters without errors.
**Expected Result:** `Ingest-Test-Results.ps1 -Input f.xml -Coverage c.xml -Matrix m.md -CoverageMap map.yml -CommitSha abc1234 -Json` runs successfully.

* **User Scenario: SCN-IF-002-A1**
  * **Given** valid input files for all parameters
  * **When** the user runs the PowerShell script with all parameters
  * **Then** the script executes without parameter binding errors

---

### Requirement Validation: REQ-IF-003 (Python Helper Interface)

#### Test Case: ATP-IF-003-A (Python helper outputs valid JSON)
**Linked Requirement:** REQ-IF-003
**Description:** Verify the Python helper outputs structured JSON to stdout.
**Validation Condition:** Output is valid JSON parseable by both bash (jq) and PowerShell (ConvertFrom-Json).
**Expected Result:** `python parse_test_results.py --junit f.xml | python -m json.tool` succeeds.

* **User Scenario: SCN-IF-003-A1**
  * **Given** a valid JUnit XML file
  * **When** the user runs `parse_test_results.py --junit test-results.xml`
  * **Then** stdout contains valid JSON with `test_results` and `summary` fields

---

### Requirement Validation: REQ-CN-001 (No Matrix Regeneration)

#### Test Case: ATP-CN-001-A (Matrix structure preserved)
**Linked Requirement:** REQ-CN-001
**Description:** Verify the command modifies only status-related columns without regenerating the matrix.
**Validation Condition:** All non-status content is byte-identical before and after ingestion.
**Expected Result:** The matrix header, coverage summary, and non-matched rows are unchanged.

* **User Scenario: SCN-CN-001-A1**
  * **Given** a matrix with custom annotations in comment lines
  * **When** the command ingests test results
  * **Then** all comment lines and non-table content are preserved exactly

---

### Requirement Validation: REQ-CN-003 (Content Preservation)

#### Test Case: ATP-CN-003-A (Manual annotations preserved)
**Linked Requirement:** REQ-CN-003
**Description:** Verify non-table content in the matrix file is preserved.
**Validation Condition:** Text outside markdown tables is unchanged.
**Expected Result:** Headers, summaries, and notes remain intact.

* **User Scenario: SCN-CN-003-A1**
  * **Given** a matrix with a custom "Notes" section below a matrix table
  * **When** the command ingests test results
  * **Then** the "Notes" section is preserved exactly

---

### Requirement Validation: REQ-CN-004 (Re-run Overwrites)

#### Test Case: ATP-CN-004-A (Re-run updates previous status)
**Linked Requirement:** REQ-CN-004
**Description:** Verify a second ingestion overwrites previous status, date, and commit values.
**Validation Condition:** The matrix reflects only the latest ingestion.
**Expected Result:** A previously Failed test that now passes shows Passed with the new date and commit.

* **User Scenario: SCN-CN-004-A1**
  * **Given** a matrix where SCN-001-A1 was previously ingested as `❌ Failed` with date 2026-04-01 and commit aaa1111
  * **And** a new JUnit XML where SCN-001-A1 passes
  * **When** the command ingests the new test results on 2026-04-05 at commit bbb2222
  * **Then** SCN-001-A1 shows `✅ Passed`, date 2026-04-05, and commit bbb2222

---

### Requirement Validation: REQ-CN-002 (No AI Dependency)

#### Test Case: ATP-CN-002-A (All processing is deterministic)
**Linked Requirement:** REQ-CN-002
**Description:** Verify the command uses no AI or LLM — all processing is deterministic parsing and string matching.
**Validation Condition:** Identical inputs always produce identical outputs with no external AI service calls.
**Expected Result:** Running the command offline (no network) succeeds with identical results to online execution.

* **User Scenario: SCN-CN-002-A1**
  * **Given** identical JUnit XML, matrix, and commit SHA inputs
  * **When** the command is run twice in succession
  * **Then** both runs produce byte-identical matrix output and summary text

---

### Requirement Validation: REQ-NF-003 (Performance)

#### Test Case: ATP-NF-003-A (Large JUnit XML processing time)
**Linked Requirement:** REQ-NF-003
**Description:** Verify the command handles a JUnit XML with up to 10,000 test cases within 30 seconds.
**Validation Condition:** Processing completes in under 30 seconds.
**Expected Result:** A 10,000-testcase JUnit XML is ingested within the time limit.

* **User Scenario: SCN-NF-003-A1**
  * **Given** a JUnit XML file containing 10,000 `<testcase>` elements with V-Model IDs
  * **When** the command ingests the test results
  * **Then** processing completes in under 30 seconds

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Requirements | 27 (20 functional + 3 non-functional + 3 interface + 4 constraint) |
| Total Test Cases (ATP) | 35 |
| Total Scenarios (SCN) | 40 |
| REQ → ATP Coverage | 27/27 (100%) |
| ATP → SCN Coverage | 35/35 (100%) |
