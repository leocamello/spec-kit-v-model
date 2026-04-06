# Integration Test Plan: Test Results Ingestion

**Feature Branch**: `feature/005d-test-results`
**Created**: 2026-04-05
**Status**: Approved
**Source**: `specs/005d-test-results/v-model/architecture-design.md`

## Overview

This document defines the Integration Test Plan for the Test Results Ingestion feature. Every architecture module boundary crossing in `architecture-design.md` has one or more Integration Test Cases (ITP), and every Test Case has one or more executable Integration Scenarios (ITS). Integration tests verify that the data flowing between modules (Python helper → Bash/PowerShell wrapper, parser → matcher, coverage extractor → module mapper) is correct at each boundary.

## ID Schema

- **Integration Test Case**: `ITP-{NNN}-{X}` — where NNN matches the parent ARCH, X is a letter suffix (A, B, C...)
- **Integration Scenario**: `ITS-{NNN}-{X}{#}` — nested under the parent ITP, with numeric suffix (1, 2, 3...)
- Example: `ITS-001-A1` → Scenario 1 of Test Case A testing ARCH-001 boundary

## ISO 29119-4 Test Techniques

Each test case MUST identify its technique by name:
- **Consumer-Driven Contract Testing (CDCT)** — Verifies data contracts between producer and consumer modules
- **Interface Fault Injection** — Tests malformed or missing data at module boundaries
- **Data Flow Testing** — Verifies data transformations across module boundaries

## Integration Tests

### Boundary: ARCH-001 → ARCH-002 (JUnit Extractor → Result Classifier)

#### Test Case: ITP-001-A (Testcase records flow correctly from extractor to classifier)

**Technique**: Consumer-Driven Contract Testing (CDCT)
**Description**: Verify the classifier receives the expected record structure from the extractor: name (string), time (float), and child element indicators.

* **Integration Scenario: ITS-001-A1**
  * **Given** ARCH-001 parses a JUnit XML producing 3 testcase records with names, times, and child element data
  * **When** the records are passed to ARCH-002 for classification
  * **Then** ARCH-002 receives all 3 records and correctly classifies each based on child elements

* **Integration Scenario: ITS-001-A2**
  * **Given** ARCH-001 parses a JUnit XML producing 0 testcase records (empty testsuite)
  * **When** the empty list is passed to ARCH-002
  * **Then** ARCH-002 returns an empty classified result list without error

#### Test Case: ITP-001-B (Malformed testcase records at boundary)

**Technique**: Interface Fault Injection
**Description**: Verify the classifier handles unexpected record structures gracefully.

* **Integration Scenario: ITS-001-B1**
  * **Given** a JUnit XML where a `<testcase>` element has no `name` attribute
  * **When** ARCH-001 extracts and ARCH-002 classifies the record
  * **Then** the record is skipped or reported as malformed, not causing a crash

---

### Boundary: ARCH-002 → ARCH-005 (Result Classifier → ID Matcher)

#### Test Case: ITP-002-A (Classified results flow to ID matcher with status preserved)

**Technique**: Consumer-Driven Contract Testing (CDCT)
**Description**: Verify the ID matcher receives classified results with correct status labels.

* **Integration Scenario: ITS-002-A1**
  * **Given** ARCH-002 classifies 5 tests: 3 passed, 1 failed, 1 skipped
  * **When** the classified results are passed to ARCH-005
  * **Then** ARCH-005 receives all 5 results with correct statuses and extracts IDs from names

* **Integration Scenario: ITS-002-A2**
  * **Given** ARCH-002 deduplicates a retried test (SCN-001-A1 appears twice, last is passed)
  * **When** the deduplicated results are passed to ARCH-005
  * **Then** ARCH-005 receives exactly one entry for SCN-001-A1 with status "passed"

---

### Boundary: ARCH-003 → ARCH-004 (Coverage Extractor → Module Mapper)

#### Test Case: ITP-003-A (Per-file coverage data flows to module mapper)

**Technique**: Consumer-Driven Contract Testing (CDCT)
**Description**: Verify the module mapper receives correct per-file coverage tuples from the extractor.

* **Integration Scenario: ITS-003-A1**
  * **Given** ARCH-003 extracts coverage for 3 files: `src/a.py` (line-rate=0.95, branch-rate=0.90), `src/b.py` (1.0, 1.0), `src/c.py` (0.80, 0.75)
  * **When** the coverage data is passed to ARCH-004
  * **Then** ARCH-004 receives coverage for all 3 files with correct percentages

* **Integration Scenario: ITS-003-A2**
  * **Given** ARCH-003 extracts an empty coverage report (no `<class>` elements)
  * **When** the empty data is passed to ARCH-004
  * **Then** ARCH-004 produces no module coverage mappings without error

#### Test Case: ITP-003-B (Module mapper aggregation across multiple files)

**Technique**: Data Flow Testing
**Description**: Verify the module mapper correctly aggregates coverage when a module maps to multiple files.

* **Integration Scenario: ITS-003-B1**
  * **Given** ARCH-003 provides coverage for `src/a.py` (200 lines, line-rate=1.0) and `src/b.py` (100 lines, line-rate=0.5)
  * **And** ARCH-004 maps MOD-001 to both files via `coverage-map.yml`
  * **When** ARCH-004 aggregates the coverage
  * **Then** MOD-001 shows a weighted average reflecting the line counts

---

### Boundary: Python Helper → Bash Wrapper (ARCH-005 JSON → ARCH-006/007/008)

#### Test Case: ITP-005-A (Python JSON output consumed by Bash wrapper)

**Technique**: Consumer-Driven Contract Testing (CDCT)
**Description**: Verify the Bash wrapper correctly parses the JSON output from the Python helper.

* **Integration Scenario: ITS-005-A1**
  * **Given** `parse_test_results.py` outputs JSON with `test_results` (5 entries), `summary` (counts), and `coverage` (2 modules)
  * **When** `ingest-test-results.sh` captures and parses the JSON
  * **Then** the wrapper correctly reads all 5 test results, the summary counts, and the 2 module coverage entries

* **Integration Scenario: ITS-005-A2**
  * **Given** `parse_test_results.py` outputs JSON with `test_results` but no `coverage` field (no `--cobertura`)
  * **When** `ingest-test-results.sh` captures and parses the JSON
  * **Then** the wrapper handles the absent `coverage` field without error and skips coverage column updates

#### Test Case: ITP-005-B (Python error propagation to Bash wrapper)

**Technique**: Interface Fault Injection
**Description**: Verify Python non-zero exit codes are detected by the wrapper.

* **Integration Scenario: ITS-005-B1**
  * **Given** `parse_test_results.py` is invoked with a non-existent JUnit XML file
  * **When** the Python script exits with non-zero
  * **Then** `ingest-test-results.sh` detects the failure and exits with an error message

---

### Boundary: ARCH-006 → Matrix File (Matrix Row Updater → traceability-matrix.md)

#### Test Case: ITP-006-A (Matrix update produces valid markdown table structure)

**Technique**: Data Flow Testing
**Description**: Verify the matrix file remains valid markdown after in-place updates.

* **Integration Scenario: ITS-006-A1**
  * **Given** a well-formed `traceability-matrix.md` with 4 matrix sections
  * **When** ARCH-006 updates 10 rows with statuses, dates, and commits
  * **Then** the resulting file is valid markdown with consistent column counts across all header, separator, and data rows

* **Integration Scenario: ITS-006-A2**
  * **Given** a matrix with existing Date and Commit columns from a previous ingestion
  * **When** ARCH-006 runs a second ingestion
  * **Then** the columns are updated in place, not duplicated, and the table structure remains valid

#### Test Case: ITP-006-B (Coverage column added only to Matrix D section)

**Technique**: Data Flow Testing
**Description**: Verify the Coverage column modification is scoped to Matrix D.

* **Integration Scenario: ITS-006-B1**
  * **Given** a matrix file with Matrices A, B, C, D
  * **When** ARCH-006 adds Coverage column data from ARCH-004
  * **Then** only the Matrix D header, separator, and data rows gain the Coverage column; A, B, C are unmodified

---

### Boundary: ARCH-008 → ARCH-009 (Bash → PowerShell Parity)

#### Test Case: ITP-008-A (Cross-platform parity verification)

**Technique**: Consumer-Driven Contract Testing (CDCT)
**Description**: Verify Bash and PowerShell wrappers produce identical matrix output and exit codes.

* **Integration Scenario: ITS-008-A1**
  * **Given** identical JUnit XML, matrix file, and commit SHA inputs
  * **When** both `ingest-test-results.sh` and `Ingest-Test-Results.ps1` process the same input
  * **Then** the resulting matrix files are byte-identical and exit codes match

* **Integration Scenario: ITS-008-A2**
  * **Given** identical JUnit XML with failures
  * **When** both wrappers process the input with `--json` / `-Json`
  * **Then** the JSON output structures are semantically identical

---

### Boundary: ARCH-004 → ARCH-006 (Coverage Module Mapper → Matrix Row Updater)

#### Test Case: ITP-004-A (Module coverage data flows to matrix updater)

**Technique**: Data Flow Testing
**Description**: Verify the module mapper's per-module coverage output is correctly consumed by the matrix row updater to populate Coverage columns in Matrix D.

* **Integration Scenario: ITS-004-A1**
  * **Given** ARCH-004 produces coverage for MOD-001 (98.2% stmt / 94.1% branch) and MOD-002 (100.0% stmt / 100.0% branch)
  * **When** ARCH-006 updates Matrix D with the coverage data
  * **Then** MOD-001 and MOD-002 rows in Matrix D show the correct coverage values in the Coverage column

* **Integration Scenario: ITS-004-A2**
  * **Given** ARCH-004 flags MOD-003 as `below_threshold: true`
  * **When** ARCH-006 updates the Matrix D row for MOD-003
  * **Then** the Coverage column includes the `⚠` indicator

---

### Boundary: ARCH-007 → stdout (Summary Formatter → Console Output)

#### Test Case: ITP-007-A (Summary output consistency with matrix state)

**Technique**: Data Flow Testing
**Description**: Verify the summary formatter's counts match the actual matrix updates performed by ARCH-006.

* **Integration Scenario: ITS-007-A1**
  * **Given** ARCH-006 updated 10 rows (8 passed, 1 failed, 1 skipped) across matrices A, B, C, D
  * **When** ARCH-007 produces the summary output
  * **Then** the summary counts match: 8 passed, 1 failed, 1 skipped, with correct per-matrix breakdown

* **Integration Scenario: ITS-007-A2**
  * **Given** ARCH-006 updated Matrix D rows with coverage and ARCH-004 produced per-module data
  * **When** ARCH-007 produces the summary in JSON mode
  * **Then** the JSON contains `coverage` field matching the per-module data from ARCH-004

---

### Boundary: ARCH-009 → Matrix File (PowerShell → traceability-matrix.md)

#### Test Case: ITP-009-A (PowerShell matrix update correctness)

**Technique**: Consumer-Driven Contract Testing (CDCT)
**Description**: Verify the PowerShell wrapper correctly updates the matrix file via its own ARCH-006 implementation.

* **Integration Scenario: ITS-009-A1**
  * **Given** a JUnit XML with 5 matching tests (3 passed, 1 failed, 1 skipped)
  * **When** `Ingest-Test-Results.ps1` processes the input
  * **Then** the matrix file shows correct statuses for all 5 rows with Date and Commit columns

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Architecture Modules (ARCH) | 9 |
| Total Test Cases (ITP) | 14 |
| Total Scenarios (ITS) | 23 |
| ARCH → ITP Coverage | 9/9 (100%) |
| ITP → ITS Coverage | 14/14 (100%) |
