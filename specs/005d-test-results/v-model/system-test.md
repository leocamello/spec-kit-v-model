# System Test Plan: Test Results Ingestion

**Feature Branch**: `feature/005d-test-results`
**Created**: 2026-04-05
**Status**: Approved
**Source**: `specs/005d-test-results/v-model/system-design.md`

## Overview

This document defines the System Test Plan for the Test Results Ingestion feature. Every system component in `system-design.md` has one or more Test Cases (STP), and every Test Case has one or more executable System Scenarios (STS) in technical BDD format (Given/When/Then). System tests verify architectural behavior, not user journeys. Language is technical and component-oriented.

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

### Component Verification: SYS-001 (JUnit XML Parser)

**Parent Requirements**: REQ-001, REQ-003, REQ-015, REQ-NF-001, REQ-NF-002

#### Test Case: STP-001-A (Parse single testsuite with multiple testcases)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Python Helper Invocation)
**Description**: Verify the JUnit XML Parser correctly extracts all `<testcase>` elements from a single `<testsuite>` and outputs a structured list of test results.

* **System Scenario: STS-001-A1**
  * **Given** a JUnit XML file with a single `<testsuite>` containing 5 `<testcase>` elements with varying statuses
  * **When** the JUnit XML Parser processes the file
  * **Then** the parser outputs a list of 5 test results, each with name, status, and duration fields

* **System Scenario: STS-001-A2**
  * **Given** a JUnit XML file with an empty `<testsuite>` (tests="0")
  * **When** the JUnit XML Parser processes the file
  * **Then** the parser outputs an empty list of test results

#### Test Case: STP-001-B (Parse multiple testsuites within testsuites root)

**Technique**: Equivalence Partitioning
**Target View**: Interface View (Python Helper Invocation)
**Description**: Verify the parser aggregates testcases across multiple `<testsuite>` elements under a `<testsuites>` root.

* **System Scenario: STS-001-B1**
  * **Given** a JUnit XML file with a `<testsuites>` root containing 3 `<testsuite>` elements with 2, 3, and 4 testcases respectively
  * **When** the JUnit XML Parser processes the file
  * **Then** the parser outputs 9 aggregated test results preserving the order from each testsuite

#### Test Case: STP-001-C (Classify testcase statuses from child elements)

**Technique**: Equivalence Partitioning
**Target View**: Data Design View
**Description**: Verify the parser correctly classifies each testcase as Passed, Failed, or Skipped based on child element presence.

* **System Scenario: STS-001-C1**
  * **Given** a `<testcase>` with no child elements (self-closing tag)
  * **When** the parser classifies the testcase
  * **Then** the status is "passed"

* **System Scenario: STS-001-C2**
  * **Given** a `<testcase>` with a `<failure message="assertion failed"/>` child
  * **When** the parser classifies the testcase
  * **Then** the status is "failed" and the message is "assertion failed"

* **System Scenario: STS-001-C3**
  * **Given** a `<testcase>` with an `<error message="runtime exception"/>` child
  * **When** the parser classifies the testcase
  * **Then** the status is "failed" and the message is "runtime exception"

* **System Scenario: STS-001-C4**
  * **Given** a `<testcase>` with a `<skipped message="not applicable"/>` child
  * **When** the parser classifies the testcase
  * **Then** the status is "skipped" and the message is "not applicable"

#### Test Case: STP-001-D (Duplicate test case IDs use last occurrence)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verify that when the same test name appears multiple times (retries), the last occurrence is the definitive result.

* **System Scenario: STS-001-D1**
  * **Given** a JUnit XML with two `<testcase>` elements both named "SCN-001-A1 test" — first with `<failure>`, second without
  * **When** the parser processes the file
  * **Then** the output contains one entry for SCN-001-A1 with status "passed" (last wins)

* **System Scenario: STS-001-D2**
  * **Given** a JUnit XML with three occurrences of "UTS-002-A1 test" — passed, failed, skipped in order
  * **When** the parser processes the file
  * **Then** the output contains one entry for UTS-002-A1 with status "skipped" (last wins)

---

### Component Verification: SYS-002 (Cobertura XML Coverage Parser)

**Parent Requirements**: REQ-008, REQ-009, REQ-018, REQ-019, REQ-020, REQ-NF-001, REQ-NF-002

#### Test Case: STP-002-A (Parse Cobertura XML per-file coverage data)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Python Helper Invocation)
**Description**: Verify the Cobertura parser extracts filename, line-rate, and branch-rate from `<class>` elements.

* **System Scenario: STS-002-A1**
  * **Given** a Cobertura XML with 3 `<class>` elements each with distinct filename, line-rate, and branch-rate
  * **When** the Cobertura parser processes the file
  * **Then** the output contains per-file coverage for all 3 files with correct percentages

#### Test Case: STP-002-B (Convention-based coverage-to-module mapping from module-design.md)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Internal: Coverage Data)
**Description**: Verify the parser maps Cobertura file coverage to MOD-NNN by parsing file path references in module-design.md.

* **System Scenario: STS-002-B1**
  * **Given** a `module-design.md` where MOD-001 section references `src/reader.py` and MOD-002 references `src/writer.py`
  * **And** a Cobertura XML with coverage for `src/reader.py` (line-rate=0.98, branch-rate=0.94) and `src/writer.py` (line-rate=1.0, branch-rate=1.0)
  * **When** the coverage parser maps files to modules using convention
  * **Then** MOD-001 shows 98.0% stmt / 94.0% branch and MOD-002 shows 100.0% stmt / 100.0% branch

#### Test Case: STP-002-C (Override mapping via coverage-map.yml takes precedence)

**Technique**: Equivalence Partitioning
**Target View**: Data Design View (coverage-map.yml)
**Description**: Verify `coverage-map.yml` mappings override convention-based mappings.

* **System Scenario: STS-002-C1**
  * **Given** a `module-design.md` mapping MOD-001 to `src/old.py`
  * **And** a `coverage-map.yml` mapping MOD-001 to `["src/new.py"]`
  * **And** a Cobertura XML with coverage for both files
  * **When** the coverage parser maps files to modules
  * **Then** MOD-001 uses coverage from `src/new.py` (override wins)

#### Test Case: STP-002-D (Multi-file module aggregation)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verify coverage is aggregated as weighted averages when a module maps to multiple files.

* **System Scenario: STS-002-D1**
  * **Given** a `coverage-map.yml` mapping MOD-001 to `["src/a.py", "src/b.py"]`
  * **And** a Cobertura XML with `src/a.py` at 100 lines, line-rate=1.0 and `src/b.py` at 100 lines, line-rate=0.8
  * **When** the coverage parser aggregates coverage for MOD-001
  * **Then** MOD-001 shows the weighted average coverage across both files

#### Test Case: STP-002-E (Coverage threshold warning)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verify modules below the configured coverage_threshold are flagged with ⚠.

* **System Scenario: STS-002-E1**
  * **Given** an `extension.yml` with `coverage_threshold: 100`
  * **And** a module with 87.5% stmt / 82.3% branch coverage
  * **When** the coverage parser evaluates the module
  * **Then** the module is flagged with `below_threshold: true`

* **System Scenario: STS-002-E2**
  * **Given** an `extension.yml` with `coverage_threshold: 80`
  * **And** a module with 95.0% stmt / 90.0% branch coverage
  * **When** the coverage parser evaluates the module
  * **Then** the module is NOT flagged (`below_threshold: false`)

#### Test Case: STP-002-F (Coverage column format)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Internal: Coverage Data)
**Description**: Verify coverage percentages use the defined format with one decimal place.

* **System Scenario: STS-002-F1**
  * **Given** a Cobertura XML with line-rate=0.9823 and branch-rate=0.9411 for a module's file
  * **When** the coverage parser formats the output
  * **Then** the output value is "98.2% stmt / 94.1% branch"

---

### Component Verification: SYS-003 (V-Model ID Matcher)

**Parent Requirements**: REQ-002, REQ-013, REQ-016, REQ-017, REQ-NF-001

#### Test Case: STP-003-A (Match SCN/STS/ITS/UTS patterns and classify to matrices)

**Technique**: Equivalence Partitioning
**Target View**: Data Design View
**Description**: Verify the ID matcher extracts IDs from all 4 families and maps to correct matrices.

* **System Scenario: STS-003-A1**
  * **Given** test names "SCN-001-A1 test", "STS-002-B1 test", "ITS-003-A1 test", "UTS-004-A1 test"
  * **When** the ID matcher processes the test names
  * **Then** SCN-001-A1 maps to Matrix A, STS-002-B1 maps to Matrix B, ITS-003-A1 maps to Matrix C, UTS-004-A1 maps to Matrix D

#### Test Case: STP-003-B (ID embedded at various positions in test name)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verify the regex extracts V-Model IDs regardless of their position in the test name.

* **System Scenario: STS-003-B1**
  * **Given** test names "SCN-001-A1 prefix test", "test SCN-001-A2 middle", "suffix test SCN-001-A3"
  * **When** the ID matcher extracts IDs
  * **Then** all three IDs (SCN-001-A1, SCN-001-A2, SCN-001-A3) are successfully extracted

#### Test Case: STP-003-C (Unmatched tests reported)

**Technique**: Equivalence Partitioning
**Target View**: Interface View (Internal: ID Match Results)
**Description**: Verify test cases without V-Model IDs are reported as unmatched.

* **System Scenario: STS-003-C1**
  * **Given** test names "test_login_flow", "test_database_connection" (no V-Model IDs)
  * **When** the ID matcher processes the test names
  * **Then** both tests are listed in the `unmatched_tests` output array

#### Test Case: STP-003-D (Matrix IDs not in JUnit XML remain untouched)

**Technique**: Fault Injection
**Target View**: Dependency View (SYS-003→SYS-004)
**Description**: Verify IDs present in the matrix but absent from JUnit XML are not affected.

* **System Scenario: STS-003-D1**
  * **Given** a matrix with SCN-001-A1, SCN-001-A2, SCN-002-A1
  * **And** a JUnit XML with only SCN-001-A1
  * **When** the ID matcher produces its result
  * **Then** only SCN-001-A1 appears in `test_results`; SCN-001-A2 and SCN-002-A1 are not present (preserved as untested by SYS-004)

#### Test Case: STP-003-E (Extra IDs in JUnit XML not in matrix)

**Technique**: Fault Injection
**Target View**: Dependency View (SYS-003→SYS-004)
**Description**: Verify IDs in JUnit XML that don't exist in the matrix are reported but don't cause errors.

* **System Scenario: STS-003-E1**
  * **Given** a JUnit XML with SCN-001-A1 and SCN-999-Z9
  * **And** a matrix containing only SCN-001-A1
  * **When** the ID matcher cross-references against the matrix
  * **Then** SCN-001-A1 is in `test_results` and SCN-999-Z9 is in `unmatched_ids`

---

### Component Verification: SYS-004 (In-Place Matrix Updater)

**Parent Requirements**: REQ-004, REQ-005, REQ-006, REQ-007, REQ-CN-001, REQ-CN-003, REQ-CN-004

#### Test Case: STP-004-A (Status column replacement)

**Technique**: Interface Contract Testing
**Target View**: Interface View (SYS-003→SYS-004)
**Description**: Verify the updater replaces `⬜ Untested` with the correct status value for matched rows.

* **System Scenario: STS-004-A1**
  * **Given** a matrix row `| REQ-001 | SYS-001 | STP-001-A | STS-001-A1 | ⬜ Untested |`
  * **And** test result `STS-001-A1 = passed`
  * **When** the matrix updater processes the row
  * **Then** the row becomes `| REQ-001 | SYS-001 | STP-001-A | STS-001-A1 | ✅ Passed | <date> | <commit> |`

* **System Scenario: STS-004-A2**
  * **Given** a matrix row with `⬜ Untested` and test result `STS-002-B1 = failed`
  * **When** the matrix updater processes the row
  * **Then** the Status column shows `❌ Failed`

* **System Scenario: STS-004-A3**
  * **Given** a matrix row with `⬜ Untested` and test result `UTS-004-A1 = skipped`
  * **When** the matrix updater processes the row
  * **Then** the Status column shows `⏭️ Skipped`

#### Test Case: STP-004-B (Date and Commit columns added to header and data rows)

**Technique**: Interface Contract Testing
**Target View**: Data Design View (Traceability Matrix)
**Description**: Verify the updater adds Date and Commit columns to the header row and populates them in data rows.

* **System Scenario: STS-004-B1**
  * **Given** a matrix table with header `| ... | Status |` and separator `| ... | ------ |`
  * **When** the matrix updater processes the table with date "2026-04-05" and commit "abc1234"
  * **Then** the header becomes `| ... | Status | Date | Commit |` and the separator gains two additional `------` columns

* **System Scenario: STS-004-B2**
  * **Given** a matrix that already has Date and Commit columns from a previous ingestion
  * **When** the matrix updater runs again with new date and commit
  * **Then** the existing Date and Commit columns are updated (not duplicated)

#### Test Case: STP-004-C (Coverage column added to Matrix D only)

**Technique**: Equivalence Partitioning
**Target View**: Data Design View
**Description**: Verify the Coverage column is added only to Matrix D when coverage data is provided.

* **System Scenario: STS-004-C1**
  * **Given** a matrix with sections A, B, C, D and coverage data for MOD-001
  * **When** the matrix updater adds coverage columns
  * **Then** only Matrix D gains a Coverage column; Matrices A, B, C do not

#### Test Case: STP-004-D (Content preservation — non-table content unmodified)

**Technique**: Fault Injection
**Target View**: Data Design View
**Description**: Verify all content outside table data rows is preserved.

* **System Scenario: STS-004-D1**
  * **Given** a matrix with a custom "Notes" section between Matrix B and Matrix C
  * **When** the matrix updater processes the matrix
  * **Then** the "Notes" section is byte-identical before and after

* **System Scenario: STS-004-D2**
  * **Given** a matrix with coverage summary sections at the end of each matrix table
  * **When** the matrix updater processes the matrix
  * **Then** the coverage summary sections are preserved exactly

#### Test Case: STP-004-E (Re-run overwrites previous statuses)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verify a second ingestion overwrites a previously ingested status.

* **System Scenario: STS-004-E1**
  * **Given** a matrix where STS-001-A1 was previously ingested as `❌ Failed | 2026-04-01 | aaa1111`
  * **And** a new ingestion with STS-001-A1 = passed, date 2026-04-05, commit bbb2222
  * **When** the matrix updater processes the re-run
  * **Then** STS-001-A1 shows `✅ Passed | 2026-04-05 | bbb2222`

#### Test Case: STP-004-F (Explicit --matrix path resolution)

**Technique**: Interface Contract Testing
**Target View**: Interface View (External: Bash Wrapper)
**Description**: Verify the matrix file is resolved from the `--matrix` argument or defaulted via setup-v-model.sh.

* **System Scenario: STS-004-F1**
  * **Given** a `--matrix /custom/path/matrix.md` argument
  * **When** the wrapper resolves the matrix path
  * **Then** the file at `/custom/path/matrix.md` is used

* **System Scenario: STS-004-F2**
  * **Given** no `--matrix` argument and a feature directory with `v-model/traceability-matrix.md`
  * **When** the wrapper resolves the matrix path via `setup-v-model.sh --json`
  * **Then** the default matrix path is used

---

### Component Verification: SYS-005 (Summary Reporter)

**Parent Requirements**: REQ-010, REQ-014

#### Test Case: STP-005-A (Human-readable summary output)

**Technique**: Interface Contract Testing
**Target View**: Interface View (External: stdout)
**Description**: Verify the summary shows per-matrix counts and overall totals.

* **System Scenario: STS-005-A1**
  * **Given** test results matching IDs in Matrices A, B, C, D
  * **When** the summary reporter generates output
  * **Then** stdout shows per-matrix lines with passed/failed/skipped counts and overall totals

#### Test Case: STP-005-B (JSON output with --json flag)

**Technique**: Interface Contract Testing
**Target View**: Interface View (External: stdout)
**Description**: Verify `--json` produces valid JSON with all required fields.

* **System Scenario: STS-005-B1**
  * **Given** test results and coverage data
  * **When** the summary reporter generates JSON output
  * **Then** stdout contains valid JSON with `test_results`, `summary`, and `coverage` fields

* **System Scenario: STS-005-B2**
  * **Given** test results without coverage data
  * **When** the summary reporter generates JSON output
  * **Then** stdout contains valid JSON with `test_results` and `summary` fields but no `coverage` field

---

### Component Verification: SYS-006 (Bash CI Wrapper Script)

**Parent Requirements**: REQ-011, REQ-012, REQ-013, REQ-IF-001, REQ-NF-001, REQ-NF-003

#### Test Case: STP-006-A (Exit code 0 — all passed)

**Technique**: Equivalence Partitioning
**Target View**: Interface View (External: Bash Wrapper)
**Description**: Verify exit code 0 when all matched tests pass.

* **System Scenario: STS-006-A1**
  * **Given** a JUnit XML where all V-Model ID testcases pass
  * **When** `ingest-test-results.sh --input results.xml` completes
  * **Then** the exit code is 0

#### Test Case: STP-006-B (Exit code 1 — failures detected)

**Technique**: Equivalence Partitioning
**Target View**: Interface View (External: Bash Wrapper)
**Description**: Verify exit code 1 when any matched test fails.

* **System Scenario: STS-006-B1**
  * **Given** a JUnit XML with 1 failed and 4 passed V-Model ID testcases
  * **When** `ingest-test-results.sh --input results.xml` completes
  * **Then** the exit code is 1

#### Test Case: STP-006-C (Exit code 2 — no matches)

**Technique**: Fault Injection
**Target View**: Interface View (External: Bash Wrapper)
**Description**: Verify exit code 2 when no V-Model IDs found.

* **System Scenario: STS-006-C1**
  * **Given** a JUnit XML where no testcase names contain V-Model IDs
  * **When** `ingest-test-results.sh --input results.xml` completes
  * **Then** the exit code is 2

#### Test Case: STP-006-D (CLI argument validation)

**Technique**: Boundary Value Analysis
**Target View**: Interface View (External: Bash Wrapper)
**Description**: Verify all CLI arguments are accepted and invalid arguments rejected.

* **System Scenario: STS-006-D1**
  * **Given** the full argument set `--input f.xml --coverage c.xml --matrix m.md --coverage-map map.yml --commit-sha abc1234 --json`
  * **When** the wrapper parses arguments
  * **Then** all arguments are accepted without errors

* **System Scenario: STS-006-D2**
  * **Given** the command is run without `--input`
  * **When** the wrapper parses arguments
  * **Then** an error message is displayed and the script exits with non-zero

#### Test Case: STP-006-E (--help flag)

**Technique**: Interface Contract Testing
**Target View**: Interface View (External: Bash Wrapper)
**Description**: Verify `--help` displays usage and exits 0.

* **System Scenario: STS-006-E1**
  * **Given** the `ingest-test-results.sh` script
  * **When** the user runs `ingest-test-results.sh --help`
  * **Then** usage information is printed and exit code is 0

#### Test Case: STP-006-F (--commit-sha override)

**Technique**: Equivalence Partitioning
**Target View**: Interface View (External: Bash Wrapper)
**Description**: Verify `--commit-sha` overrides automatic HEAD detection.

* **System Scenario: STS-006-F1**
  * **Given** a JUnit XML with matching IDs
  * **When** `ingest-test-results.sh --input f.xml --commit-sha deadbeef1234567`
  * **Then** the Commit column shows "deadbee" (first 7 characters)

---

### Component Verification: SYS-007 (PowerShell CI Wrapper Script)

**Parent Requirements**: REQ-IF-002, REQ-NF-001

#### Test Case: STP-007-A (PowerShell parameter parity)

**Technique**: Interface Contract Testing
**Target View**: Interface View (External: PowerShell Wrapper)
**Description**: Verify the PowerShell wrapper accepts all parameters and produces identical behavior.

* **System Scenario: STS-007-A1**
  * **Given** the full parameter set `-Input f.xml -Coverage c.xml -Matrix m.md -CoverageMap map.yml -CommitSha abc1234 -Json`
  * **When** the PowerShell wrapper parses parameters
  * **Then** all parameters are accepted without errors

* **System Scenario: STS-007-A2**
  * **Given** identical JUnit XML and matrix input
  * **When** both `ingest-test-results.sh` and `Ingest-Test-Results.ps1` process the same input
  * **Then** the resulting matrix files are byte-identical and exit codes match

#### Test Case: STP-007-B (PowerShell --help/-Help parity)

**Technique**: Interface Contract Testing
**Target View**: Interface View (External: PowerShell Wrapper)
**Description**: Verify `-Help` displays usage and exits 0.

* **System Scenario: STS-007-B1**
  * **Given** the `Ingest-Test-Results.ps1` script
  * **When** the user runs `Ingest-Test-Results.ps1 -Help`
  * **Then** usage information is printed and exit code is 0

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total System Components (SYS) | 7 |
| Total Test Cases (STP) | 24 |
| Total Scenarios (STS) | 41 |
| SYS → STP Coverage | 7/7 (100%) |
| STP → STS Coverage | 24/24 (100%) |
