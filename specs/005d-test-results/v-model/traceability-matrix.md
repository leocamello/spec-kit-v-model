# Traceability Matrix

**Generated**: 2026-04-05
**Source**: `v-model/`

## Matrix A — Validation (User View)

| Requirement ID | Requirement Description | Test Case ID (ATP) | Validation Condition | Scenario ID (SCN) | Status |
|----------------|------------------------|--------------------|----------------------|--------------------|--------|
| **REQ-001** | The command SHALL accept a JUnit XML file via the `--input` argument and parse all `<testcase>` elements from all `<testsuite>` elements within the file. | ATP-001-A | Parse single testsuite | SCN-001-A1 | ⬜ Untested |
| | | ATP-001-A | Parse single testsuite | SCN-001-A2 | ⬜ Untested |
| | | ATP-001-B | Parse multiple testsuites | SCN-001-B1 | ⬜ Untested |
| **REQ-002** | For each parsed `<testcase>`, the command SHALL extract the V-Model scenario ID by matching the test case `name` attribute against the patterns: `SCN-[A-Z]*-?[0-9]{3}-[A-Z][0-9]+`, `STS-[A-Z]*-?[0-9]{3}-[A-Z][0-9]+`, `ITS-[A-Z]*-?[0-9]{3}-[A-Z][0-9]+`, and `UTS-[A-Z]*-?[0-9]{3}-[A-Z][0-9]+`. | ATP-002-A | Extract SCN IDs from test names | SCN-002-A1 | ⬜ Untested |
| | | ATP-002-A | Extract SCN IDs from test names | SCN-002-A2 | ⬜ Untested |
| | | ATP-002-B | Extract STS, ITS, UTS IDs | SCN-002-B1 | ⬜ Untested |
| | | ATP-002-C | No match for non-V-Model test names | SCN-002-C1 | ⬜ Untested |
| **REQ-003** | For each matched test case, the command SHALL classify the test result as: `✅ Passed` when the `<testcase>` element contains no child `<failure>`, `<error>`, or `<skipped>` elements; `❌ Failed` when a `<failure>` or `<error>` child element is present; `⏭️ Skipped` when a `<skipped>` child element is present. | ATP-003-A | Classify passed tests | SCN-003-A1 | ⬜ Untested |
| | | ATP-003-B | Classify failed tests | SCN-003-B1 | ⬜ Untested |
| | | ATP-003-B | Classify failed tests | SCN-003-B2 | ⬜ Untested |
| | | ATP-003-C | Classify skipped tests | SCN-003-C1 | ⬜ Untested |
| **REQ-004** | The command SHALL accept the path to a `traceability-matrix.md` file via the `--matrix` argument. If `--matrix` is not provided, the command SHALL default to the `traceability-matrix.md` file in the current feature's `v-model/` directory as returned by `setup-v-model.sh --json`. | ATP-004-A | Explicit --matrix argument | SCN-004-A1 | ⬜ Untested |
| | | ATP-004-B | Default matrix resolution via setup-v-model | SCN-004-B1 | ⬜ Untested |
| **REQ-005** | The command SHALL update the matrix in-place: for each matched scenario ID, the Status column value SHALL be replaced from `⬜ Untested` to the classified status (`✅ Passed`, `❌ Failed`, or `⏭️ Skipped`). | ATP-005-A | Replace Untested with Passed | SCN-005-A1 | ⬜ Untested |
| | | ATP-005-B | Replace Untested with Failed | SCN-005-B1 | ⬜ Untested |
| | | ATP-005-B | Replace Untested with Failed | SCN-005-B2 | ⬜ Untested |
| | | ATP-005-C | Replace Untested with Skipped | SCN-005-C1 | ⬜ Untested |
| **REQ-006** | After ingestion, the command SHALL add a Date column to each matrix table containing the ISO 8601 date (YYYY-MM-DD) of the ingestion run. | ATP-006-A | Date column added after ingestion | SCN-006-A1 | ⬜ Untested |
| **REQ-007** | After ingestion, the command SHALL add a Commit column to each matrix table containing the abbreviated Git commit SHA (7 characters) of the commit under test. The commit SHA SHALL be determined automatically from the current `HEAD` or accepted via a `--commit-sha` argument. | ATP-007-A | Commit column from current HEAD | SCN-007-A1 | ⬜ Untested |
| | | ATP-007-B | Commit column from --commit-sha argument | SCN-007-B1 | ⬜ Untested |
| **REQ-008** | When the `--coverage` argument is provided with a Cobertura XML file path, the command SHALL parse the coverage data and add a Coverage column to Matrix D rows, displaying statement and branch coverage percentages for the corresponding module. | ATP-008-A | Coverage column added to Matrix D | SCN-008-A1 | ⬜ Untested |
| | | ATP-008-B | No Coverage column without --coverage | SCN-008-B1 | ⬜ Untested |
| **REQ-009** | The command SHALL map Cobertura XML coverage data to MOD-NNN module IDs using two strategies: (a) **convention** — parse `module-design.md` for source file path references associated with each MOD-NNN, then match against Cobertura `<class filename="...">` attributes; (b) **override** — when a `coverage-map.yml` file exists, use its explicit `MOD-NNN → file paths` mapping, which takes precedence over convention-based matching. | ATP-009-A | Convention-based mapping from module-design.md | SCN-009-A1 | ⬜ Untested |
| | | ATP-009-B | Override mapping via coverage-map.yml | SCN-009-B1 | ⬜ Untested |
| | | ATP-009-C | Multi-file module coverage aggregation | SCN-009-C1 | ⬜ Untested |
| **REQ-010** | The command SHALL print a summary table to stdout showing: matched test count per matrix (A, B, C, D), pass/fail/skip counts per matrix, total matched vs. total matrix scenarios, and (when coverage is provided) per-module and overall coverage percentages. | ATP-010-A | Summary with per-matrix counts | SCN-010-A1 | ⬜ Untested |
| | | ATP-010-B | Summary with coverage data | SCN-010-B1 | ⬜ Untested |
| **REQ-011** | The command SHALL return exit code 0 when all matched test cases have status `✅ Passed`. | ATP-011-A | All tests passed | SCN-011-A1 | ⬜ Untested |
| **REQ-012** | The command SHALL return exit code 1 when at least one matched test case has status `❌ Failed`. | ATP-012-A | At least one failure | SCN-012-A1 | ⬜ Untested |
| **REQ-013** | The command SHALL return exit code 2 when zero V-Model scenario IDs are matched in the JUnit XML file. | ATP-013-A | No V-Model IDs matched | SCN-013-A1 | ⬜ Untested |
| **REQ-014** | The command SHALL support a `--json` flag that outputs the ingestion results as structured JSON to stdout, including: per-ID status mappings, per-matrix summary counts, and (when applicable) per-module coverage data. | ATP-014-A | JSON output with --json flag | SCN-014-A1 | ⬜ Untested |
| | | ATP-014-A | JSON output with --json flag | SCN-014-A2 | ⬜ Untested |
| **REQ-015** | When a test case ID appears multiple times in the JUnit XML (e.g., from retries or parameterized runs), the command SHALL use the last occurrence as the definitive result. | ATP-015-A | Last occurrence wins for duplicate IDs | SCN-015-A1 | ⬜ Untested |
| **REQ-016** | The command SHALL NOT modify any rows in the matrix whose scenario ID does not appear in the JUnit XML input — their `⬜ Untested` status SHALL be preserved. | ATP-016-A | Unexercised scenarios remain Untested | SCN-016-A1 | ⬜ Untested |
| **REQ-017** | When a scenario ID appears in the JUnit XML but does not exist in the matrix, the command SHALL report it as an unmatched ID in the summary output and skip it without error. | ATP-017-A | Unmatched IDs reported and skipped | SCN-017-A1 | ⬜ Untested |
| **REQ-018** | The coverage-map.yml file SHALL use the following structure: a top-level `mappings` key containing an array of objects, each with `mod_id` (string, e.g., `MOD-001`) and `files` (array of strings, e.g., `["src/reader.py", "src/reader_utils.py"]`). | ATP-018-A | Valid coverage-map.yml parsed correctly | SCN-018-A1 | ⬜ Untested |
| **REQ-019** | The Coverage column value in Matrix D SHALL display the format `{stmt}% stmt / {branch}% branch`, where `{stmt}` and `{branch}` are numeric coverage percentages rounded to one decimal place. | ATP-019-A | Coverage column format | SCN-019-A1 | ⬜ Untested |
| **REQ-020** | When the `--coverage` argument is provided and a module's actual coverage falls below the `coverage_threshold` configured in `extension.yml`, the command SHALL flag that module's Coverage column with a warning indicator (`⚠`). | ATP-020-A | Below-threshold modules flagged | SCN-020-A1 | ⬜ Untested |
| **REQ-CN-001** | The command SHALL NOT regenerate the traceability matrix — it SHALL only modify existing rows by updating the Status column and adding Date, Commit, and (optionally) Coverage columns. | ATP-CN-001-A | Matrix structure preserved | SCN-CN-001-A1 | ⬜ Untested |
| **REQ-CN-002** | The command SHALL NOT require any AI or LLM — all processing SHALL be performed by deterministic parsing and string matching logic. | ATP-CN-002-A | All processing is deterministic | SCN-CN-002-A1 | ⬜ Untested |
| **REQ-CN-003** | The command SHALL preserve all existing content in the matrix file that is outside the status columns — including headers, coverage summary sections, and manual annotations. | ATP-CN-003-A | Manual annotations preserved | SCN-CN-003-A1 | ⬜ Untested |
| **REQ-CN-004** | The command SHALL support re-running on the same matrix — subsequent ingestions SHALL update previously ingested statuses (e.g., a `❌ Failed` can become `✅ Passed` on a re-run), overwriting the Date and Commit columns with the latest values. | ATP-CN-004-A | Re-run updates previous status | SCN-CN-004-A1 | ⬜ Untested |
| **REQ-IF-001** | The Bash wrapper script SHALL accept the following CLI syntax: `ingest-test-results.sh --input <junit.xml> [--coverage <cobertura.xml>] [--matrix <matrix.md>] [--coverage-map <map.yml>] [--commit-sha <sha>] [--json] [--help]`. | ATP-IF-001-A | All CLI arguments accepted | SCN-IF-001-A1 | ⬜ Untested |
| | | ATP-IF-001-B | --help flag | SCN-IF-001-B1 | ⬜ Untested |
| **REQ-IF-002** | The PowerShell wrapper script SHALL accept equivalent PowerShell parameters: `Ingest-Test-Results.ps1 -Input <path> [-Coverage <path>] [-Matrix <path>] [-CoverageMap <path>] [-CommitSha <sha>] [-Json] [-Help]`. | ATP-IF-002-A | PowerShell parameters accepted | SCN-IF-002-A1 | ⬜ Untested |
| **REQ-IF-003** | The Python helper script SHALL accept the following CLI syntax: `parse_test_results.py --junit <junit.xml> [--cobertura <cobertura.xml>] [--coverage-map <map.yml>]` and SHALL output structured JSON to stdout. | ATP-IF-003-A | Python helper outputs valid JSON | SCN-IF-003-A1 | ⬜ Untested |
| **REQ-NF-001** | The command SHALL be 100% deterministic: given the same JUnit XML input, Cobertura XML input (if provided), matrix file, and commit SHA, it SHALL always produce the same updated matrix and the same summary output. | ATP-NF-001-A | Identical input produces identical output | SCN-NF-001-A1 | ⬜ Untested |
| **REQ-NF-002** | The Python helper script SHALL use only Python standard library modules (`xml.etree.ElementTree`, `json`, `re`, `sys`, `argparse`) with zero external dependencies. | ATP-NF-002-A | Python helper uses only stdlib | SCN-NF-002-A1 | ⬜ Untested |
| **REQ-NF-003** | The command SHALL handle JUnit XML files containing up to 10,000 test cases without exceeding 30 seconds of execution time on a standard CI runner. | ATP-NF-003-A | Large JUnit XML processing time | SCN-NF-003-A1 | ⬜ Untested |

### Matrix A Coverage

| Metric | Value |
|--------|-------|
| **Total Requirements** | 30 |
| **Total Test Cases (ATP)** | 44 |
| **Total Scenarios (SCN)** | 50 |
| **REQ → ATP Coverage** | 30/30 (100%) |
| **ATP → SCN Coverage** | 44/44 (100%) |

## Matrix B — Verification (Architectural View)

| Requirement ID | System Component (SYS) | Component Name | Test Case ID (STP) | Technique | Scenario ID (STS) | Status |
|----------------|------------------------|----------------|--------------------|-----------|--------------------|--------|
| **REQ-001** | SYS-001 | JUnit XML Parser | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C2 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C3 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C4 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| **REQ-002** | SYS-003 | V-Model ID Matcher | STP-003-A | Equivalence Partitioning | STS-003-A1 | ⬜ Untested |
| | SYS-003 | V-Model ID Matcher | STP-003-B | Boundary Value Analysis | STS-003-B1 | ⬜ Untested |
| | SYS-003 | V-Model ID Matcher | STP-003-C | Equivalence Partitioning | STS-003-C1 | ⬜ Untested |
| | SYS-003 | V-Model ID Matcher | STP-003-D | Fault Injection | STS-003-D1 | ⬜ Untested |
| | SYS-003 | V-Model ID Matcher | STP-003-E | Fault Injection | STS-003-E1 | ⬜ Untested |
| **REQ-003** | SYS-001 | JUnit XML Parser | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C2 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C3 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C4 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| **REQ-004** | SYS-004 | In-Place Matrix Updater | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-A | Interface Contract Testing | STS-004-A3 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-B | Interface Contract Testing | STS-004-B1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-B | Interface Contract Testing | STS-004-B2 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-C | Equivalence Partitioning | STS-004-C1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-D | Fault Injection | STS-004-D1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-D | Fault Injection | STS-004-D2 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-E | Boundary Value Analysis | STS-004-E1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-F | Interface Contract Testing | STS-004-F1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-F | Interface Contract Testing | STS-004-F2 | ⬜ Untested |
| **REQ-005** | SYS-004 | In-Place Matrix Updater | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-A | Interface Contract Testing | STS-004-A3 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-B | Interface Contract Testing | STS-004-B1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-B | Interface Contract Testing | STS-004-B2 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-C | Equivalence Partitioning | STS-004-C1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-D | Fault Injection | STS-004-D1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-D | Fault Injection | STS-004-D2 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-E | Boundary Value Analysis | STS-004-E1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-F | Interface Contract Testing | STS-004-F1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-F | Interface Contract Testing | STS-004-F2 | ⬜ Untested |
| **REQ-006** | SYS-004 | In-Place Matrix Updater | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-A | Interface Contract Testing | STS-004-A3 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-B | Interface Contract Testing | STS-004-B1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-B | Interface Contract Testing | STS-004-B2 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-C | Equivalence Partitioning | STS-004-C1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-D | Fault Injection | STS-004-D1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-D | Fault Injection | STS-004-D2 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-E | Boundary Value Analysis | STS-004-E1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-F | Interface Contract Testing | STS-004-F1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-F | Interface Contract Testing | STS-004-F2 | ⬜ Untested |
| **REQ-007** | SYS-004 | In-Place Matrix Updater | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-A | Interface Contract Testing | STS-004-A3 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-B | Interface Contract Testing | STS-004-B1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-B | Interface Contract Testing | STS-004-B2 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-C | Equivalence Partitioning | STS-004-C1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-D | Fault Injection | STS-004-D1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-D | Fault Injection | STS-004-D2 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-E | Boundary Value Analysis | STS-004-E1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-F | Interface Contract Testing | STS-004-F1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-F | Interface Contract Testing | STS-004-F2 | ⬜ Untested |
| **REQ-008** | SYS-002 | Cobertura XML Coverage Parser | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-B | Interface Contract Testing | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-C | Equivalence Partitioning | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-D | Boundary Value Analysis | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-E | Boundary Value Analysis | STS-002-E1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-E | Boundary Value Analysis | STS-002-E2 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-F | Interface Contract Testing | STS-002-F1 | ⬜ Untested |
| **REQ-009** | SYS-002 | Cobertura XML Coverage Parser | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-B | Interface Contract Testing | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-C | Equivalence Partitioning | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-D | Boundary Value Analysis | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-E | Boundary Value Analysis | STS-002-E1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-E | Boundary Value Analysis | STS-002-E2 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-F | Interface Contract Testing | STS-002-F1 | ⬜ Untested |
| **REQ-010** | SYS-005 | Summary Reporter | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Summary Reporter | STP-005-B | Interface Contract Testing | STS-005-B1 | ⬜ Untested |
| | SYS-005 | Summary Reporter | STP-005-B | Interface Contract Testing | STS-005-B2 | ⬜ Untested |
| **REQ-011** | SYS-006 | Bash CI Wrapper Script | STP-006-A | Equivalence Partitioning | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-C | Fault Injection | STS-006-C1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-D | Boundary Value Analysis | STS-006-D1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-D | Boundary Value Analysis | STS-006-D2 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-E | Interface Contract Testing | STS-006-E1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-F | Equivalence Partitioning | STS-006-F1 | ⬜ Untested |
| **REQ-012** | SYS-006 | Bash CI Wrapper Script | STP-006-A | Equivalence Partitioning | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-C | Fault Injection | STS-006-C1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-D | Boundary Value Analysis | STS-006-D1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-D | Boundary Value Analysis | STS-006-D2 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-E | Interface Contract Testing | STS-006-E1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-F | Equivalence Partitioning | STS-006-F1 | ⬜ Untested |
| **REQ-013** | SYS-003 | V-Model ID Matcher | STP-003-A | Equivalence Partitioning | STS-003-A1 | ⬜ Untested |
| | SYS-003 | V-Model ID Matcher | STP-003-B | Boundary Value Analysis | STS-003-B1 | ⬜ Untested |
| | SYS-003 | V-Model ID Matcher | STP-003-C | Equivalence Partitioning | STS-003-C1 | ⬜ Untested |
| | SYS-003 | V-Model ID Matcher | STP-003-D | Fault Injection | STS-003-D1 | ⬜ Untested |
| | SYS-003 | V-Model ID Matcher | STP-003-E | Fault Injection | STS-003-E1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-A | Equivalence Partitioning | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-C | Fault Injection | STS-006-C1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-D | Boundary Value Analysis | STS-006-D1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-D | Boundary Value Analysis | STS-006-D2 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-E | Interface Contract Testing | STS-006-E1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-F | Equivalence Partitioning | STS-006-F1 | ⬜ Untested |
| **REQ-014** | SYS-005 | Summary Reporter | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Summary Reporter | STP-005-B | Interface Contract Testing | STS-005-B1 | ⬜ Untested |
| | SYS-005 | Summary Reporter | STP-005-B | Interface Contract Testing | STS-005-B2 | ⬜ Untested |
| **REQ-015** | SYS-001 | JUnit XML Parser | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C2 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C3 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C4 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| **REQ-016** | SYS-003 | V-Model ID Matcher | STP-003-A | Equivalence Partitioning | STS-003-A1 | ⬜ Untested |
| | SYS-003 | V-Model ID Matcher | STP-003-B | Boundary Value Analysis | STS-003-B1 | ⬜ Untested |
| | SYS-003 | V-Model ID Matcher | STP-003-C | Equivalence Partitioning | STS-003-C1 | ⬜ Untested |
| | SYS-003 | V-Model ID Matcher | STP-003-D | Fault Injection | STS-003-D1 | ⬜ Untested |
| | SYS-003 | V-Model ID Matcher | STP-003-E | Fault Injection | STS-003-E1 | ⬜ Untested |
| **REQ-017** | SYS-003 | V-Model ID Matcher | STP-003-A | Equivalence Partitioning | STS-003-A1 | ⬜ Untested |
| | SYS-003 | V-Model ID Matcher | STP-003-B | Boundary Value Analysis | STS-003-B1 | ⬜ Untested |
| | SYS-003 | V-Model ID Matcher | STP-003-C | Equivalence Partitioning | STS-003-C1 | ⬜ Untested |
| | SYS-003 | V-Model ID Matcher | STP-003-D | Fault Injection | STS-003-D1 | ⬜ Untested |
| | SYS-003 | V-Model ID Matcher | STP-003-E | Fault Injection | STS-003-E1 | ⬜ Untested |
| **REQ-018** | SYS-002 | Cobertura XML Coverage Parser | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-B | Interface Contract Testing | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-C | Equivalence Partitioning | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-D | Boundary Value Analysis | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-E | Boundary Value Analysis | STS-002-E1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-E | Boundary Value Analysis | STS-002-E2 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-F | Interface Contract Testing | STS-002-F1 | ⬜ Untested |
| **REQ-019** | SYS-002 | Cobertura XML Coverage Parser | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-B | Interface Contract Testing | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-C | Equivalence Partitioning | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-D | Boundary Value Analysis | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-E | Boundary Value Analysis | STS-002-E1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-E | Boundary Value Analysis | STS-002-E2 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-F | Interface Contract Testing | STS-002-F1 | ⬜ Untested |
| **REQ-020** | SYS-002 | Cobertura XML Coverage Parser | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-B | Interface Contract Testing | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-C | Equivalence Partitioning | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-D | Boundary Value Analysis | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-E | Boundary Value Analysis | STS-002-E1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-E | Boundary Value Analysis | STS-002-E2 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-F | Interface Contract Testing | STS-002-F1 | ⬜ Untested |
| **REQ-CN-001** | SYS-004 | In-Place Matrix Updater | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-A | Interface Contract Testing | STS-004-A3 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-B | Interface Contract Testing | STS-004-B1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-B | Interface Contract Testing | STS-004-B2 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-C | Equivalence Partitioning | STS-004-C1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-D | Fault Injection | STS-004-D1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-D | Fault Injection | STS-004-D2 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-E | Boundary Value Analysis | STS-004-E1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-F | Interface Contract Testing | STS-004-F1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-F | Interface Contract Testing | STS-004-F2 | ⬜ Untested |
| **REQ-CN-002** | SYS-001 | JUnit XML Parser | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C2 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C3 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C4 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| **REQ-CN-003** | SYS-004 | In-Place Matrix Updater | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-A | Interface Contract Testing | STS-004-A3 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-B | Interface Contract Testing | STS-004-B1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-B | Interface Contract Testing | STS-004-B2 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-C | Equivalence Partitioning | STS-004-C1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-D | Fault Injection | STS-004-D1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-D | Fault Injection | STS-004-D2 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-E | Boundary Value Analysis | STS-004-E1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-F | Interface Contract Testing | STS-004-F1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-F | Interface Contract Testing | STS-004-F2 | ⬜ Untested |
| **REQ-CN-004** | SYS-004 | In-Place Matrix Updater | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-A | Interface Contract Testing | STS-004-A3 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-B | Interface Contract Testing | STS-004-B1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-B | Interface Contract Testing | STS-004-B2 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-C | Equivalence Partitioning | STS-004-C1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-D | Fault Injection | STS-004-D1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-D | Fault Injection | STS-004-D2 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-E | Boundary Value Analysis | STS-004-E1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-F | Interface Contract Testing | STS-004-F1 | ⬜ Untested |
| | SYS-004 | In-Place Matrix Updater | STP-004-F | Interface Contract Testing | STS-004-F2 | ⬜ Untested |
| **REQ-IF-001** | SYS-006 | Bash CI Wrapper Script | STP-006-A | Equivalence Partitioning | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-C | Fault Injection | STS-006-C1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-D | Boundary Value Analysis | STS-006-D1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-D | Boundary Value Analysis | STS-006-D2 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-E | Interface Contract Testing | STS-006-E1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-F | Equivalence Partitioning | STS-006-F1 | ⬜ Untested |
| **REQ-IF-002** | SYS-007 | PowerShell CI Wrapper Script | STP-007-A | Interface Contract Testing | STS-007-A1 | ⬜ Untested |
| | SYS-007 | PowerShell CI Wrapper Script | STP-007-A | Interface Contract Testing | STS-007-A2 | ⬜ Untested |
| | SYS-007 | PowerShell CI Wrapper Script | STP-007-B | Interface Contract Testing | STS-007-B1 | ⬜ Untested |
| **REQ-IF-003** | SYS-001 | JUnit XML Parser | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C2 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C3 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C4 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| **REQ-NF-001** | SYS-001 | JUnit XML Parser | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C2 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C3 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C4 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-B | Interface Contract Testing | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-C | Equivalence Partitioning | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-D | Boundary Value Analysis | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-E | Boundary Value Analysis | STS-002-E1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-E | Boundary Value Analysis | STS-002-E2 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-F | Interface Contract Testing | STS-002-F1 | ⬜ Untested |
| | SYS-003 | V-Model ID Matcher | STP-003-A | Equivalence Partitioning | STS-003-A1 | ⬜ Untested |
| | SYS-003 | V-Model ID Matcher | STP-003-B | Boundary Value Analysis | STS-003-B1 | ⬜ Untested |
| | SYS-003 | V-Model ID Matcher | STP-003-C | Equivalence Partitioning | STS-003-C1 | ⬜ Untested |
| | SYS-003 | V-Model ID Matcher | STP-003-D | Fault Injection | STS-003-D1 | ⬜ Untested |
| | SYS-003 | V-Model ID Matcher | STP-003-E | Fault Injection | STS-003-E1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-A | Equivalence Partitioning | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-C | Fault Injection | STS-006-C1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-D | Boundary Value Analysis | STS-006-D1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-D | Boundary Value Analysis | STS-006-D2 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-E | Interface Contract Testing | STS-006-E1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-F | Equivalence Partitioning | STS-006-F1 | ⬜ Untested |
| | SYS-007 | PowerShell CI Wrapper Script | STP-007-A | Interface Contract Testing | STS-007-A1 | ⬜ Untested |
| | SYS-007 | PowerShell CI Wrapper Script | STP-007-A | Interface Contract Testing | STS-007-A2 | ⬜ Untested |
| | SYS-007 | PowerShell CI Wrapper Script | STP-007-B | Interface Contract Testing | STS-007-B1 | ⬜ Untested |
| **REQ-NF-002** | SYS-001 | JUnit XML Parser | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C2 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C3 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-C | Equivalence Partitioning | STS-001-C4 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | JUnit XML Parser | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-B | Interface Contract Testing | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-C | Equivalence Partitioning | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-D | Boundary Value Analysis | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-E | Boundary Value Analysis | STS-002-E1 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-E | Boundary Value Analysis | STS-002-E2 | ⬜ Untested |
| | SYS-002 | Cobertura XML Coverage Parser | STP-002-F | Interface Contract Testing | STS-002-F1 | ⬜ Untested |
| **REQ-NF-003** | SYS-006 | Bash CI Wrapper Script | STP-006-A | Equivalence Partitioning | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-C | Fault Injection | STS-006-C1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-D | Boundary Value Analysis | STS-006-D1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-D | Boundary Value Analysis | STS-006-D2 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-E | Interface Contract Testing | STS-006-E1 | ⬜ Untested |
| | SYS-006 | Bash CI Wrapper Script | STP-006-F | Equivalence Partitioning | STS-006-F1 | ⬜ Untested |

### Matrix B Coverage

| Metric | Value |
|--------|-------|
| **Total System Components (SYS)** | 7 |
| **Total System Test Cases (STP)** | 31 |
| **Total System Scenarios (STS)** | 45 |
| **REQ → SYS Coverage** | 30/30 (100%) |
| **SYS → STP Coverage** | 7/7 (100%) |

## Matrix C — Integration Verification (Module Boundary View)

| System Component (SYS) | Parent REQs | Architecture Module (ARCH) | Module Name | Test Case ID (ITP) | Technique | Scenario ID (ITS) | Status |
|------------------------|-------------|---------------------------|-------------|--------------------|-----------|--------------------|--------|
| SYS-001 (REQ-001, REQ-003, REQ-015, REQ-NF-001, REQ-NF-002, REQ-IF-003, REQ-CN-002) | REQ-001, REQ-003, REQ-015, REQ-NF-001, REQ-NF-002, REQ-IF-003, REQ-CN-002 | ARCH-001 | JUnit Testcase Extractor | ITP-001-A | Consumer-Driven Contract Testing (CDCT) | ITS-001-A1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-003, REQ-015, REQ-NF-001, REQ-NF-002, REQ-IF-003, REQ-CN-002) | REQ-001, REQ-003, REQ-015, REQ-NF-001, REQ-NF-002, REQ-IF-003, REQ-CN-002 | ARCH-001 | JUnit Testcase Extractor | ITP-001-A | Consumer-Driven Contract Testing (CDCT) | ITS-001-A2 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-003, REQ-015, REQ-NF-001, REQ-NF-002, REQ-IF-003, REQ-CN-002) | REQ-001, REQ-003, REQ-015, REQ-NF-001, REQ-NF-002, REQ-IF-003, REQ-CN-002 | ARCH-001 | JUnit Testcase Extractor | ITP-001-B | Interface Fault Injection | ITS-001-B1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-003, REQ-015, REQ-NF-001, REQ-NF-002, REQ-IF-003, REQ-CN-002) | REQ-001, REQ-003, REQ-015, REQ-NF-001, REQ-NF-002, REQ-IF-003, REQ-CN-002 | ARCH-002 | Test Result Classifier | ITP-002-A | Consumer-Driven Contract Testing (CDCT) | ITS-002-A1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-003, REQ-015, REQ-NF-001, REQ-NF-002, REQ-IF-003, REQ-CN-002) | REQ-001, REQ-003, REQ-015, REQ-NF-001, REQ-NF-002, REQ-IF-003, REQ-CN-002 | ARCH-002 | Test Result Classifier | ITP-002-A | Consumer-Driven Contract Testing (CDCT) | ITS-002-A2 | ⬜ Untested |
| SYS-002 (REQ-008, REQ-009, REQ-018, REQ-019, REQ-020, REQ-NF-001, REQ-NF-002) | REQ-008, REQ-009, REQ-018, REQ-019, REQ-020, REQ-NF-001, REQ-NF-002 | ARCH-003 | Cobertura Coverage Extractor | ITP-003-A | Consumer-Driven Contract Testing (CDCT) | ITS-003-A1 | ⬜ Untested |
| SYS-002 (REQ-008, REQ-009, REQ-018, REQ-019, REQ-020, REQ-NF-001, REQ-NF-002) | REQ-008, REQ-009, REQ-018, REQ-019, REQ-020, REQ-NF-001, REQ-NF-002 | ARCH-003 | Cobertura Coverage Extractor | ITP-003-A | Consumer-Driven Contract Testing (CDCT) | ITS-003-A2 | ⬜ Untested |
| SYS-002 (REQ-008, REQ-009, REQ-018, REQ-019, REQ-020, REQ-NF-001, REQ-NF-002) | REQ-008, REQ-009, REQ-018, REQ-019, REQ-020, REQ-NF-001, REQ-NF-002 | ARCH-003 | Cobertura Coverage Extractor | ITP-003-B | Data Flow Testing | ITS-003-B1 | ⬜ Untested |
| SYS-002 (REQ-008, REQ-009, REQ-018, REQ-019, REQ-020, REQ-NF-001, REQ-NF-002) | REQ-008, REQ-009, REQ-018, REQ-019, REQ-020, REQ-NF-001, REQ-NF-002 | ARCH-004 | Coverage Module Mapper | ITP-004-A | Data Flow Testing | ITS-004-A1 | ⬜ Untested |
| SYS-002 (REQ-008, REQ-009, REQ-018, REQ-019, REQ-020, REQ-NF-001, REQ-NF-002) | REQ-008, REQ-009, REQ-018, REQ-019, REQ-020, REQ-NF-001, REQ-NF-002 | ARCH-004 | Coverage Module Mapper | ITP-004-A | Data Flow Testing | ITS-004-A2 | ⬜ Untested |
| SYS-003 (REQ-002, REQ-013, REQ-016, REQ-017, REQ-NF-001) | REQ-002, REQ-013, REQ-016, REQ-017, REQ-NF-001 | ARCH-005 | V-Model ID Regex Matcher | ITP-005-A | Consumer-Driven Contract Testing (CDCT) | ITS-005-A1 | ⬜ Untested |
| SYS-003 (REQ-002, REQ-013, REQ-016, REQ-017, REQ-NF-001) | REQ-002, REQ-013, REQ-016, REQ-017, REQ-NF-001 | ARCH-005 | V-Model ID Regex Matcher | ITP-005-A | Consumer-Driven Contract Testing (CDCT) | ITS-005-A2 | ⬜ Untested |
| SYS-003 (REQ-002, REQ-013, REQ-016, REQ-017, REQ-NF-001) | REQ-002, REQ-013, REQ-016, REQ-017, REQ-NF-001 | ARCH-005 | V-Model ID Regex Matcher | ITP-005-B | Interface Fault Injection | ITS-005-B1 | ⬜ Untested |
| SYS-004 (REQ-004, REQ-005, REQ-006, REQ-007, REQ-CN-001, REQ-CN-003, REQ-CN-004) | REQ-004, REQ-005, REQ-006, REQ-007, REQ-CN-001, REQ-CN-003, REQ-CN-004 | ARCH-006 | Matrix Row Updater | ITP-006-A | Data Flow Testing | ITS-006-A1 | ⬜ Untested |
| SYS-004 (REQ-004, REQ-005, REQ-006, REQ-007, REQ-CN-001, REQ-CN-003, REQ-CN-004) | REQ-004, REQ-005, REQ-006, REQ-007, REQ-CN-001, REQ-CN-003, REQ-CN-004 | ARCH-006 | Matrix Row Updater | ITP-006-A | Data Flow Testing | ITS-006-A2 | ⬜ Untested |
| SYS-004 (REQ-004, REQ-005, REQ-006, REQ-007, REQ-CN-001, REQ-CN-003, REQ-CN-004) | REQ-004, REQ-005, REQ-006, REQ-007, REQ-CN-001, REQ-CN-003, REQ-CN-004 | ARCH-006 | Matrix Row Updater | ITP-006-B | Data Flow Testing | ITS-006-B1 | ⬜ Untested |
| SYS-005 (REQ-010, REQ-014) | REQ-010, REQ-014 | ARCH-007 | Ingestion Summary Formatter | ITP-007-A | Data Flow Testing | ITS-007-A1 | ⬜ Untested |
| SYS-005 (REQ-010, REQ-014) | REQ-010, REQ-014 | ARCH-007 | Ingestion Summary Formatter | ITP-007-A | Data Flow Testing | ITS-007-A2 | ⬜ Untested |
| SYS-006 (REQ-011, REQ-012, REQ-013, REQ-IF-001, REQ-NF-001, REQ-NF-003) | REQ-011, REQ-012, REQ-013, REQ-IF-001, REQ-NF-001, REQ-NF-003 | ARCH-008 | Bash Ingestion Orchestrator | ITP-008-A | Consumer-Driven Contract Testing (CDCT) | ITS-008-A1 | ⬜ Untested |
| SYS-006 (REQ-011, REQ-012, REQ-013, REQ-IF-001, REQ-NF-001, REQ-NF-003) | REQ-011, REQ-012, REQ-013, REQ-IF-001, REQ-NF-001, REQ-NF-003 | ARCH-008 | Bash Ingestion Orchestrator | ITP-008-A | Consumer-Driven Contract Testing (CDCT) | ITS-008-A2 | ⬜ Untested |
| SYS-007 (REQ-IF-002, REQ-NF-001) | REQ-IF-002, REQ-NF-001 | ARCH-009 | PowerShell Ingestion Orchestrator | ITP-009-A | Consumer-Driven Contract Testing (CDCT) | ITS-009-A1 | ⬜ Untested |

### Matrix C Coverage

| Metric | Value |
|--------|-------|
| **Total Architecture Modules (ARCH)** | 9 |
| **Total Cross-Cutting Modules** | 0 |
| **Total Integration Test Cases (ITP)** | 13 |
| **Total Integration Scenarios (ITS)** | 21 |
| **SYS → ARCH Coverage** | 7/7 (100%) |
| **ARCH → ITP Coverage** | 9/9 (100%) |

### Uncovered Requirements (REQ without ATP)

None — full coverage.

### Orphaned Test Cases (ATP without valid REQ)

None — all tests trace to requirements.

### Uncovered Requirements — System Level (REQ without SYS)

None — full coverage.

### Orphaned System Test Cases (STP without valid SYS)

None — all system tests trace to components.

### Uncovered System Components — Architecture Level (SYS without ARCH)

None — full coverage.

### Orphaned Integration Test Cases (ITP without valid ARCH)

None — all integration tests trace to modules.

## Matrix D — Implementation Verification (Module View)

| Architecture Module (ARCH) | Parent System | Module Design (MOD) | Module Name | Test Case ID (UTP) | Technique | Scenario ID (UTS) | Status |
|---------------------------|---------------|---------------------|-------------|--------------------|-----------|--------------------|--------|
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | JUnit Testcase Extractor | UTP-001-A | Statement & Branch Coverage | UTS-001-A1 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | JUnit Testcase Extractor | UTP-001-A | Statement & Branch Coverage | UTS-001-A2 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | JUnit Testcase Extractor | UTP-001-B | Decision Table Testing | UTS-001-B1 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | JUnit Testcase Extractor | UTP-001-B | Decision Table Testing | UTS-001-B2 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | JUnit Testcase Extractor | UTP-001-B | Decision Table Testing | UTS-001-B3 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | JUnit Testcase Extractor | UTP-001-B | Decision Table Testing | UTS-001-B4 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | JUnit Testcase Extractor | UTP-001-C | Error Guessing | UTS-001-C1 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | JUnit Testcase Extractor | UTP-001-C | Error Guessing | UTS-001-C2 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | Test Result Classifier | UTP-002-A | Equivalence Partitioning | UTS-002-A1 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | Test Result Classifier | UTP-002-A | Equivalence Partitioning | UTS-002-A2 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | Test Result Classifier | UTP-002-A | Equivalence Partitioning | UTS-002-A3 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | Test Result Classifier | UTP-002-B | Boundary Value Analysis | UTS-002-B1 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | Test Result Classifier | UTP-002-B | Boundary Value Analysis | UTS-002-B2 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | Cobertura Coverage Extractor | UTP-003-A | Statement & Branch Coverage | UTS-003-A1 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | Cobertura Coverage Extractor | UTP-003-A | Statement & Branch Coverage | UTS-003-A2 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | Cobertura Coverage Extractor | UTP-003-B | Error Guessing | UTS-003-B1 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | Cobertura Coverage Extractor | UTP-003-B | Error Guessing | UTS-003-B2 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-004 | Coverage Module Mapper | UTP-004-A | Statement & Branch Coverage | UTS-004-A1 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-004 | Coverage Module Mapper | UTP-004-B | Equivalence Partitioning | UTS-004-B1 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-004 | Coverage Module Mapper | UTP-004-C | Boundary Value Analysis | UTS-004-C1 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-004 | Coverage Module Mapper | UTP-004-C | Boundary Value Analysis | UTS-004-C2 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-004 | Coverage Module Mapper | UTP-004-D | Boundary Value Analysis | UTS-004-D1 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-004 | Coverage Module Mapper | UTP-004-D | Boundary Value Analysis | UTS-004-D2 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-004 | Coverage Module Mapper | UTP-004-E | Equivalence Partitioning | UTS-004-E1 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-005 | V-Model ID Regex Matcher | UTP-005-A | Equivalence Partitioning | UTS-005-A1 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-005 | V-Model ID Regex Matcher | UTP-005-A | Equivalence Partitioning | UTS-005-A2 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-005 | V-Model ID Regex Matcher | UTP-005-A | Equivalence Partitioning | UTS-005-A3 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-005 | V-Model ID Regex Matcher | UTP-005-A | Equivalence Partitioning | UTS-005-A4 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-005 | V-Model ID Regex Matcher | UTP-005-B | Boundary Value Analysis | UTS-005-B1 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-005 | V-Model ID Regex Matcher | UTP-005-B | Boundary Value Analysis | UTS-005-B2 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-005 | V-Model ID Regex Matcher | UTP-005-C | Error Guessing | UTS-005-C1 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-005 | V-Model ID Regex Matcher | UTP-005-C | Error Guessing | UTS-005-C2 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-005 | V-Model ID Regex Matcher | UTP-005-D | Statement & Branch Coverage | UTS-005-D1 | ⬜ Untested |
| ARCH-006 (SYS-004) | SYS-004 | MOD-006 | Matrix Row Updater | UTP-006-A | Statement & Branch Coverage | UTS-006-A1 | ⬜ Untested |
| ARCH-006 (SYS-004) | SYS-004 | MOD-006 | Matrix Row Updater | UTP-006-A | Statement & Branch Coverage | UTS-006-A2 | ⬜ Untested |
| ARCH-006 (SYS-004) | SYS-004 | MOD-006 | Matrix Row Updater | UTP-006-A | Statement & Branch Coverage | UTS-006-A3 | ⬜ Untested |
| ARCH-006 (SYS-004) | SYS-004 | MOD-006 | Matrix Row Updater | UTP-006-B | Boundary Value Analysis | UTS-006-B1 | ⬜ Untested |
| ARCH-006 (SYS-004) | SYS-004 | MOD-006 | Matrix Row Updater | UTP-006-B | Boundary Value Analysis | UTS-006-B2 | ⬜ Untested |
| ARCH-006 (SYS-004) | SYS-004 | MOD-006 | Matrix Row Updater | UTP-006-C | Equivalence Partitioning | UTS-006-C1 | ⬜ Untested |
| ARCH-006 (SYS-004) | SYS-004 | MOD-006 | Matrix Row Updater | UTP-006-C | Equivalence Partitioning | UTS-006-C2 | ⬜ Untested |
| ARCH-006 (SYS-004) | SYS-004 | MOD-006 | Matrix Row Updater | UTP-006-D | Error Guessing | UTS-006-D1 | ⬜ Untested |
| ARCH-007 (SYS-005) | SYS-005 | MOD-007 | Ingestion Summary Formatter | UTP-007-A | Statement & Branch Coverage | UTS-007-A1 | ⬜ Untested |
| ARCH-007 (SYS-005) | SYS-005 | MOD-007 | Ingestion Summary Formatter | UTP-007-B | Equivalence Partitioning | UTS-007-B1 | ⬜ Untested |
| ARCH-007 (SYS-005) | SYS-005 | MOD-007 | Ingestion Summary Formatter | UTP-007-B | Equivalence Partitioning | UTS-007-B2 | ⬜ Untested |
| ARCH-008 (SYS-006) | SYS-006 | MOD-008 | Bash Ingestion Orchestrator | UTP-008-A | Decision Table Testing | UTS-008-A1 | ⬜ Untested |
| ARCH-008 (SYS-006) | SYS-006 | MOD-008 | Bash Ingestion Orchestrator | UTP-008-A | Decision Table Testing | UTS-008-A2 | ⬜ Untested |
| ARCH-008 (SYS-006) | SYS-006 | MOD-008 | Bash Ingestion Orchestrator | UTP-008-B | Equivalence Partitioning | UTS-008-B1 | ⬜ Untested |
| ARCH-008 (SYS-006) | SYS-006 | MOD-008 | Bash Ingestion Orchestrator | UTP-008-B | Equivalence Partitioning | UTS-008-B2 | ⬜ Untested |
| ARCH-008 (SYS-006) | SYS-006 | MOD-008 | Bash Ingestion Orchestrator | UTP-008-B | Equivalence Partitioning | UTS-008-B3 | ⬜ Untested |
| ARCH-008 (SYS-006) | SYS-006 | MOD-008 | Bash Ingestion Orchestrator | UTP-008-C | Statement & Branch Coverage | UTS-008-C1 | ⬜ Untested |
| ARCH-009 (SYS-007) | SYS-007 | MOD-009 | PowerShell Ingestion Orchestrator | UTP-009-A | Equivalence Partitioning | UTS-009-A1 | ⬜ Untested |
| ARCH-009 (SYS-007) | SYS-007 | MOD-009 | PowerShell Ingestion Orchestrator | UTP-009-A | Equivalence Partitioning | UTS-009-A2 | ⬜ Untested |
| ARCH-009 (SYS-007) | SYS-007 | MOD-009 | PowerShell Ingestion Orchestrator | UTP-009-B | Equivalence Partitioning | UTS-009-B1 | ⬜ Untested |

### Matrix D Coverage

| Metric | Value |
|--------|-------|
| **Total Module Designs (MOD)** | 9 |
| **External Modules** | 0 |
| **Testable Modules** | 9 |
| **Total Unit Test Cases (UTP)** | 27 |
| **Total Unit Scenarios (UTS)** | 53 |
| **ARCH → MOD Coverage** | 9/9 (100%) |
| **MOD → UTP Coverage** | 9/9 (100%) |

## Audit Notes

- **Matrix generated by**: `build-matrix.sh` (deterministic regex parser)
- **Source documents**: `requirements.md`, `acceptance-plan.md`, `system-design.md`, `system-test.md`, `architecture-design.md`, `integration-test.md`, `module-design.md`, `unit-test.md`
- **Last validated**: 2026-04-05
