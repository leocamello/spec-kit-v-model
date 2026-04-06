# Unit Test Plan: Test Results Ingestion

**Feature Branch**: `feature/005d-test-results`
**Created**: 2026-04-05
**Status**: Approved
**Source**: `specs/005d-test-results/v-model/module-design.md`

## Overview

This document defines the Unit Test Plan for the Test Results Ingestion feature. Every module design in `module-design.md` has one or more Unit Test Cases (UTP), and every Test Case has one or more executable Unit Scenarios (UTS). Unit tests verify internal function behavior, edge cases, boundary values, and error handling at the module level.

## ID Schema

- **Unit Test Case**: `UTP-{NNN}-{X}` — where NNN matches the parent MOD, X is a letter suffix (A, B, C...)
- **Unit Test Scenario**: `UTS-{NNN}-{X}{#}` — nested under the parent UTP, with numeric suffix (1, 2, 3...)
- Example: `UTS-001-A1` → Scenario 1 of Test Case A testing MOD-001

## ISO 29119-4 Test Techniques

Each test case MUST identify its technique by name:
- **Statement & Branch Coverage** — Exercises all code paths through the function
- **Boundary Value Analysis** — Tests at and around data limits
- **Equivalence Partitioning** — Tests representative inputs from each class
- **Error Guessing** — Tests based on common failure modes
- **Decision Table Testing** — Tests combinatorial input conditions

## Unit Tests

### Module Tests: MOD-001 (JUnit Testcase Extractor)

#### Test Case: UTP-001-A (extract_testcases with single testsuite)

**Technique**: Statement & Branch Coverage
**Description**: Verify the function handles single `<testsuite>` root elements.

* **Unit Scenario: UTS-001-A1**
  * **Given** a JUnit XML string with `<testsuite>` as root containing 3 `<testcase>` elements
  * **When** `extract_testcases()` is called
  * **Then** a list of 3 raw testcase records is returned

* **Unit Scenario: UTS-001-A2**
  * **Given** a JUnit XML string with `<testsuites>` root containing 2 `<testsuite>` elements with 2 testcases each
  * **When** `extract_testcases()` is called
  * **Then** a list of 4 raw testcase records is returned

#### Test Case: UTP-001-B (parse_testcase_element child element detection)

**Technique**: Decision Table Testing
**Description**: Verify all combinations of child elements are correctly detected.

| Condition | has_failure | has_skipped | Expected Status |
|-----------|-------------|-------------|-----------------|
| No children | false | false | passed |
| `<failure>` only | true | false | failed |
| `<error>` only | true | false | failed |
| `<skipped>` only | false | true | skipped |
| `<failure>` + `<skipped>` | true | true | failed (priority) |

* **Unit Scenario: UTS-001-B1**
  * **Given** a `<testcase>` element with no child elements
  * **When** `parse_testcase_element()` is called
  * **Then** `has_failure` is false, `has_skipped` is false

* **Unit Scenario: UTS-001-B2**
  * **Given** a `<testcase>` element with a `<failure message="assert"/>` child
  * **When** `parse_testcase_element()` is called
  * **Then** `has_failure` is true, `message` is "assert"

* **Unit Scenario: UTS-001-B3**
  * **Given** a `<testcase>` element with an `<error message="NPE"/>` child
  * **When** `parse_testcase_element()` is called
  * **Then** `has_failure` is true, `message` is "NPE"

* **Unit Scenario: UTS-001-B4**
  * **Given** a `<testcase>` element with a `<skipped message="env"/>` child
  * **When** `parse_testcase_element()` is called
  * **Then** `has_skipped` is true, `message` is "env"

#### Test Case: UTP-001-C (Empty and malformed XML handling)

**Technique**: Error Guessing
**Description**: Verify graceful handling of edge cases.

* **Unit Scenario: UTS-001-C1**
  * **Given** a JUnit XML with an empty `<testsuite tests="0"/>` element
  * **When** `extract_testcases()` is called
  * **Then** an empty list is returned

* **Unit Scenario: UTS-001-C2**
  * **Given** a file path that does not exist
  * **When** `extract_testcases()` is called
  * **Then** a `FileNotFoundError` is raised

---

### Module Tests: MOD-002 (Test Result Classifier)

#### Test Case: UTP-002-A (Classification logic)

**Technique**: Equivalence Partitioning
**Description**: Verify each status classification path.

* **Unit Scenario: UTS-002-A1**
  * **Given** a raw testcase with `has_failure=false`, `has_skipped=false`
  * **When** `classify_results()` processes it
  * **Then** the classified status is "passed"

* **Unit Scenario: UTS-002-A2**
  * **Given** a raw testcase with `has_failure=true`
  * **When** `classify_results()` processes it
  * **Then** the classified status is "failed"

* **Unit Scenario: UTS-002-A3**
  * **Given** a raw testcase with `has_skipped=true`, `has_failure=false`
  * **When** `classify_results()` processes it
  * **Then** the classified status is "skipped"

#### Test Case: UTP-002-B (Deduplication — last occurrence wins)

**Technique**: Boundary Value Analysis
**Description**: Verify duplicate test names are deduplicated using last-wins strategy.

* **Unit Scenario: UTS-002-B1**
  * **Given** two raw testcases with identical name "SCN-001-A1 test" — first failed, second passed
  * **When** `classify_results()` processes them
  * **Then** one result is returned with status "passed"

* **Unit Scenario: UTS-002-B2**
  * **Given** three raw testcases with identical name — passed, failed, skipped in order
  * **When** `classify_results()` processes them
  * **Then** one result is returned with status "skipped" (last wins)

---

### Module Tests: MOD-003 (Cobertura Coverage Extractor)

#### Test Case: UTP-003-A (Per-file coverage extraction)

**Technique**: Statement & Branch Coverage
**Description**: Verify correct extraction of line-rate and branch-rate per file.

* **Unit Scenario: UTS-003-A1**
  * **Given** a Cobertura XML with one `<class filename="src/reader.py" line-rate="0.95" branch-rate="0.88"/>`
  * **When** `extract_coverage()` is called
  * **Then** the output maps `src/reader.py` to `{line_rate: 0.95, branch_rate: 0.88}`

* **Unit Scenario: UTS-003-A2**
  * **Given** a Cobertura XML with 3 classes across 2 packages
  * **When** `extract_coverage()` is called
  * **Then** all 3 files are present in the output with correct coverage values

#### Test Case: UTP-003-B (Edge cases in Cobertura XML)

**Technique**: Error Guessing
**Description**: Verify handling of missing attributes and empty reports.

* **Unit Scenario: UTS-003-B1**
  * **Given** a Cobertura XML where a `<class>` element has no `branch-rate` attribute
  * **When** `extract_coverage()` is called
  * **Then** the `branch_rate` defaults to 0.0

* **Unit Scenario: UTS-003-B2**
  * **Given** a Cobertura XML with no `<class>` elements
  * **When** `extract_coverage()` is called
  * **Then** an empty dict is returned

---

### Module Tests: MOD-004 (Coverage Module Mapper)

#### Test Case: UTP-004-A (Convention-based mapping from module-design.md)

**Technique**: Statement & Branch Coverage
**Description**: Verify extraction of MOD→file mappings from module-design.md content.

* **Unit Scenario: UTS-004-A1**
  * **Given** a module-design.md where MOD-001 section contains `scripts/python/parse_test_results.py`
  * **When** `extract_mod_file_refs()` parses the file
  * **Then** MOD-001 maps to `['scripts/python/parse_test_results.py']`

#### Test Case: UTP-004-B (Override via coverage-map.yml)

**Technique**: Equivalence Partitioning
**Description**: Verify coverage-map.yml parsing and precedence.

* **Unit Scenario: UTS-004-B1**
  * **Given** a coverage-map.yml with `mappings: [{mod_id: "MOD-001", files: ["src/a.py", "src/b.py"]}]`
  * **When** `parse_coverage_map()` parses the file
  * **Then** MOD-001 maps to `['src/a.py', 'src/b.py']`

#### Test Case: UTP-004-C (Weighted average aggregation)

**Technique**: Boundary Value Analysis
**Description**: Verify weighted average computation for multi-file modules.

* **Unit Scenario: UTS-004-C1**
  * **Given** MOD-001 maps to `src/a.py` (100 lines, line-rate=1.0) and `src/b.py` (100 lines, line-rate=0.5)
  * **When** `map_coverage_to_modules()` aggregates
  * **Then** MOD-001 stmt is 75.0% (weighted average: (100×1.0 + 100×0.5) / 200)

* **Unit Scenario: UTS-004-C2**
  * **Given** MOD-002 maps to a single file with 0 lines in the Cobertura report
  * **When** `map_coverage_to_modules()` aggregates
  * **Then** MOD-002 shows 0.0% coverage (not a division-by-zero error)

#### Test Case: UTP-004-D (Threshold comparison)

**Technique**: Boundary Value Analysis
**Description**: Verify the threshold flag is set correctly at boundary values.

* **Unit Scenario: UTS-004-D1**
  * **Given** a coverage_threshold of 100 and a module with 100.0% stmt and 100.0% branch
  * **When** threshold is checked
  * **Then** `below_threshold` is false

* **Unit Scenario: UTS-004-D2**
  * **Given** a coverage_threshold of 100 and a module with 99.9% stmt and 100.0% branch
  * **When** threshold is checked
  * **Then** `below_threshold` is true (stmt < threshold)

#### Test Case: UTP-004-E (Coverage format output)

**Technique**: Equivalence Partitioning
**Description**: Verify the formatted coverage string uses one decimal place.

* **Unit Scenario: UTS-004-E1**
  * **Given** a module with stmt=98.23% and branch=94.11%
  * **When** the formatted value is produced
  * **Then** the output is "98.2% stmt / 94.1% branch"

---

### Module Tests: MOD-005 (V-Model ID Regex Matcher)

#### Test Case: UTP-005-A (Pattern matching for all 4 ID families)

**Technique**: Equivalence Partitioning
**Description**: Verify each regex pattern matches its target family.

* **Unit Scenario: UTS-005-A1**
  * **Given** a test name "SCN-001-A1 Given valid input"
  * **When** `match_ids()` processes it
  * **Then** ID "SCN-001-A1" is extracted, matrix = "A"

* **Unit Scenario: UTS-005-A2**
  * **Given** a test name "STS-002-B1 system threshold check"
  * **When** `match_ids()` processes it
  * **Then** ID "STS-002-B1" is extracted, matrix = "B"

* **Unit Scenario: UTS-005-A3**
  * **Given** a test name "ITS-003-A1 integration contract"
  * **When** `match_ids()` processes it
  * **Then** ID "ITS-003-A1" is extracted, matrix = "C"

* **Unit Scenario: UTS-005-A4**
  * **Given** a test name "UTS-004-A1 boundary value at zero"
  * **When** `match_ids()` processes it
  * **Then** ID "UTS-004-A1" is extracted, matrix = "D"

#### Test Case: UTP-005-B (ID at various positions in test name)

**Technique**: Boundary Value Analysis
**Description**: Verify regex extraction regardless of ID position.

* **Unit Scenario: UTS-005-B1**
  * **Given** a test name "test_SCN-005-B2_boundary"
  * **When** `match_ids()` processes it
  * **Then** ID "SCN-005-B2" is extracted from the middle of the name

* **Unit Scenario: UTS-005-B2**
  * **Given** a test name "suffix test SCN-001-A3"
  * **When** `match_ids()` processes it
  * **Then** ID "SCN-001-A3" is extracted from the end of the name

#### Test Case: UTP-005-C (Unmatched test names)

**Technique**: Error Guessing
**Description**: Verify tests without V-Model IDs are correctly classified as unmatched.

* **Unit Scenario: UTS-005-C1**
  * **Given** a test name "test_login_flow" with no V-Model ID pattern
  * **When** `match_ids()` processes it
  * **Then** the test name appears in `unmatched_tests`

* **Unit Scenario: UTS-005-C2**
  * **Given** a test name "REQ-001 requirement check" (REQ is not a scenario ID pattern)
  * **When** `match_ids()` processes it
  * **Then** the test name appears in `unmatched_tests` (REQ is not SCN/STS/ITS/UTS)

#### Test Case: UTP-005-D (Summary computation)

**Technique**: Statement & Branch Coverage
**Description**: Verify per-matrix and overall summary counts.

* **Unit Scenario: UTS-005-D1**
  * **Given** 3 matched results: SCN-001-A1 passed (A), STS-001-A1 failed (B), UTS-001-A1 passed (D)
  * **When** `compute_summary()` is called
  * **Then** summary shows Matrix A: 1 passed, Matrix B: 1 failed, Matrix D: 1 passed, overall: 2 passed, 1 failed

---

### Module Tests: MOD-006 (Matrix Row Updater)

#### Test Case: UTP-006-A (Status replacement in matrix row)

**Technique**: Statement & Branch Coverage
**Description**: Verify status column replacement works for all status values.

* **Unit Scenario: UTS-006-A1**
  * **Given** a matrix row `| REQ-001 | SYS-001 | STP-001-A | STS-001-A1 | ⬜ Untested |`
  * **When** the updater replaces status for STS-001-A1 with "passed"
  * **Then** the row contains `| ✅ Passed |` in the status position

* **Unit Scenario: UTS-006-A2**
  * **Given** a matrix row with `⬜ Untested`
  * **When** the updater replaces with "failed"
  * **Then** the row contains `| ❌ Failed |`

* **Unit Scenario: UTS-006-A3**
  * **Given** a matrix row with `⬜ Untested`
  * **When** the updater replaces with "skipped"
  * **Then** the row contains `| ⏭️ Skipped |`

#### Test Case: UTP-006-B (Date and Commit column addition)

**Technique**: Boundary Value Analysis
**Description**: Verify columns are added to header, separator, and data rows.

* **Unit Scenario: UTS-006-B1**
  * **Given** a header row `| ... | Status |` and separator `| ... | ------ |`
  * **When** columns are added with date "2026-04-05" and commit "abc1234"
  * **Then** the header is `| ... | Status | Date | Commit |` and separator gains two `------` entries

* **Unit Scenario: UTS-006-B2**
  * **Given** a data row already has Date and Commit columns from a previous run
  * **When** the updater runs again
  * **Then** the values are replaced, not duplicated

#### Test Case: UTP-006-C (Coverage column for Matrix D only)

**Technique**: Equivalence Partitioning
**Description**: Verify Coverage column is scoped to Matrix D.

* **Unit Scenario: UTS-006-C1**
  * **Given** a Matrix D data row with MOD-001 and coverage data "98.2% stmt / 94.1% branch"
  * **When** the updater adds the coverage column
  * **Then** the row gains `| 98.2% stmt / 94.1% branch |` at the end

* **Unit Scenario: UTS-006-C2**
  * **Given** a Matrix A data row
  * **When** coverage data is available
  * **Then** the Matrix A row does NOT gain a Coverage column

#### Test Case: UTP-006-D (Non-table content preservation)

**Technique**: Error Guessing
**Description**: Verify non-table content passes through unchanged.

* **Unit Scenario: UTS-006-D1**
  * **Given** a matrix file with `<!-- Custom note -->` between Matrix B and Matrix C
  * **When** the updater processes the file
  * **Then** the comment line is preserved exactly

---

### Module Tests: MOD-007 (Ingestion Summary Formatter)

#### Test Case: UTP-007-A (Human-readable summary format)

**Technique**: Statement & Branch Coverage
**Description**: Verify the summary output format matches the specification.

* **Unit Scenario: UTS-007-A1**
  * **Given** test results with 12 passed in Matrix A, 15 passed + 1 failed in Matrix B
  * **When** the summary is formatted in human-readable mode
  * **Then** stdout includes lines "Matrix A (Acceptance): 12 passed, 0 failed, 0 skipped" and "Matrix B (System): 15 passed, 1 failed, 0 skipped"

#### Test Case: UTP-007-B (JSON summary format)

**Technique**: Equivalence Partitioning
**Description**: Verify JSON output contains all required fields.

* **Unit Scenario: UTS-007-B1**
  * **Given** test results and coverage data
  * **When** the summary is formatted in JSON mode
  * **Then** valid JSON is produced with `test_results`, `summary`, and `coverage` keys

* **Unit Scenario: UTS-007-B2**
  * **Given** test results without coverage data
  * **When** the summary is formatted in JSON mode
  * **Then** valid JSON is produced with `test_results` and `summary` keys, no `coverage` key

---

### Module Tests: MOD-008 (Bash Ingestion Orchestrator)

#### Test Case: UTP-008-A (Argument parsing)

**Technique**: Decision Table Testing
**Description**: Verify all argument combinations are parsed correctly.

* **Unit Scenario: UTS-008-A1**
  * **Given** arguments `--input test.xml --json`
  * **When** the orchestrator parses arguments
  * **Then** input_file is "test.xml", json_mode is true, other args are defaults

* **Unit Scenario: UTS-008-A2**
  * **Given** no arguments
  * **When** the orchestrator parses arguments
  * **Then** an error is raised about missing `--input`

#### Test Case: UTP-008-B (Exit code determination)

**Technique**: Equivalence Partitioning
**Description**: Verify correct exit codes for each scenario.

* **Unit Scenario: UTS-008-B1**
  * **Given** Python output with 5 passed, 0 failed
  * **When** the orchestrator determines exit code
  * **Then** exit code is 0

* **Unit Scenario: UTS-008-B2**
  * **Given** Python output with 4 passed, 1 failed
  * **When** the orchestrator determines exit code
  * **Then** exit code is 1

* **Unit Scenario: UTS-008-B3**
  * **Given** Python output with 0 total matches
  * **When** the orchestrator determines exit code
  * **Then** exit code is 2

#### Test Case: UTP-008-C (--help output)

**Technique**: Statement & Branch Coverage
**Description**: Verify help text is displayed and exit code is 0.

* **Unit Scenario: UTS-008-C1**
  * **Given** the argument `--help`
  * **When** the orchestrator runs
  * **Then** usage text is printed and exit code is 0

---

### Module Tests: MOD-009 (PowerShell Ingestion Orchestrator)

#### Test Case: UTP-009-A (Parameter parity with Bash)

**Technique**: Equivalence Partitioning
**Description**: Verify PowerShell parameters match Bash arguments.

* **Unit Scenario: UTS-009-A1**
  * **Given** parameters `-Input test.xml -Json`
  * **When** the PowerShell orchestrator parses parameters
  * **Then** InputFile is "test.xml", JsonMode is true

* **Unit Scenario: UTS-009-A2**
  * **Given** no parameters
  * **When** the PowerShell orchestrator runs
  * **Then** an error about missing `-Input` is raised

#### Test Case: UTP-009-B (PowerShell exit code parity)

**Technique**: Equivalence Partitioning
**Description**: Verify exit codes match Bash behavior.

* **Unit Scenario: UTS-009-B1**
  * **Given** identical test inputs to both Bash and PowerShell scripts
  * **When** both scripts process the input
  * **Then** the exit codes are identical

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Module Designs (MOD) | 9 |
| Total Test Cases (UTP) | 25 |
| Total Scenarios (UTS) | 49 |
| MOD → UTP Coverage | 9/9 (100%) |
| UTP → UTS Coverage | 25/25 (100%) |
