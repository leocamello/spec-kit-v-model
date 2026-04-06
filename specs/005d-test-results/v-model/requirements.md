# V-Model Requirements Specification: Test Results Ingestion

**Feature Branch**: `feature/005d-test-results`
**Created**: 2026-04-05
**Status**: Approved
**Source**: `specs/005d-test-results/spec.md`

## Overview

This document formalizes the requirements for adding a `/speckit.v-model.test-results` command to the V-Model Extension Pack. The command is a **100% deterministic script** (no AI) that ingests JUnit XML test results and optionally Cobertura XML code coverage data, then updates the existing `traceability-matrix.md` in-place. It matches test case names to V-Model scenario IDs (SCN, STS, ITS, UTS patterns), replaces `⬜ Untested` statuses with execution outcomes (`✅ Passed`, `❌ Failed`, `⏭️ Skipped`), and appends Date and Commit SHA columns. When Cobertura XML is provided, Matrix D gains an additional Coverage column linking actual code coverage metrics to MOD-NNN module designs. A Python helper script (`parse_test_results.py`) handles XML parsing using the standard library (`xml.etree.ElementTree`, zero external dependencies), outputting structured JSON that Bash and PowerShell wrapper scripts consume to perform the in-place matrix update. Exit codes signal CI outcomes: 0 = all matched tests passed, 1 = failures detected, 2 = no V-Model ID matches found.

## Requirements

### Functional Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-001 | The command SHALL accept a JUnit XML file via the `--input` argument and parse all `<testcase>` elements from all `<testsuite>` elements within the file. | P1 | JUnit XML is the universal test result format — pytest, Maven, Gradle, .NET, Go, Jest, and Mocha all emit it. Parsing all testsuites ensures compatibility with multi-suite reports. | Test |
| REQ-002 | For each parsed `<testcase>`, the command SHALL extract the V-Model scenario ID by matching the test case `name` attribute against the patterns: `SCN-[A-Z]*-?[0-9]{3}-[A-Z][0-9]+`, `STS-[A-Z]*-?[0-9]{3}-[A-Z][0-9]+`, `ITS-[A-Z]*-?[0-9]{3}-[A-Z][0-9]+`, and `UTS-[A-Z]*-?[0-9]{3}-[A-Z][0-9]+`. | P1 | V-Model scenario IDs embedded in test names are the key that links CI execution to the traceability matrix. The regex patterns match the established ID schema. | Test |
| REQ-003 | For each matched test case, the command SHALL classify the test result as: `✅ Passed` when the `<testcase>` element contains no child `<failure>`, `<error>`, or `<skipped>` elements; `❌ Failed` when a `<failure>` or `<error>` child element is present; `⏭️ Skipped` when a `<skipped>` child element is present. | P1 | These three statuses cover all possible JUnit XML outcomes and map directly to the matrix status values. | Test |
| REQ-004 | The command SHALL accept the path to a `traceability-matrix.md` file via the `--matrix` argument. If `--matrix` is not provided, the command SHALL default to the `traceability-matrix.md` file in the current feature's `v-model/` directory as returned by `setup-v-model.sh --json`. | P1 | Explicit `--matrix` allows CI pipelines to target specific matrix files; the default supports interactive use from within a feature directory. | Test |
| REQ-005 | The command SHALL update the matrix in-place: for each matched scenario ID, the Status column value SHALL be replaced from `⬜ Untested` to the classified status (`✅ Passed`, `❌ Failed`, or `⏭️ Skipped`). | P1 | In-place update preserves any manual annotations in the matrix and maintains it as the single source of truth. | Test |
| REQ-006 | After ingestion, the command SHALL add a Date column to each matrix table containing the ISO 8601 date (YYYY-MM-DD) of the ingestion run. | P1 | Auditors require timestamped evidence of when tests were executed for release certification. | Test |
| REQ-007 | After ingestion, the command SHALL add a Commit column to each matrix table containing the abbreviated Git commit SHA (7 characters) of the commit under test. The commit SHA SHALL be determined automatically from the current `HEAD` or accepted via a `--commit-sha` argument. | P1 | The commit SHA links test execution evidence to a specific code revision, completing the audit trail from requirement to executed code. | Test |
| REQ-008 | When the `--coverage` argument is provided with a Cobertura XML file path, the command SHALL parse the coverage data and add a Coverage column to Matrix D rows, displaying statement and branch coverage percentages for the corresponding module. | P2 | In safety-critical domains (DO-178C, ISO 26262), auditors require structural code coverage evidence, not just test pass/fail status. | Test |
| REQ-009 | The command SHALL map Cobertura XML coverage data to MOD-NNN module IDs using two strategies: (a) **convention** — parse `module-design.md` for source file path references associated with each MOD-NNN, then match against Cobertura `<class filename="...">` attributes; (b) **override** — when a `coverage-map.yml` file exists, use its explicit `MOD-NNN → file paths` mapping, which takes precedence over convention-based matching. | P2 | Convention-based mapping minimizes setup effort; the override file enables precise control when file path heuristics are insufficient. | Test |
| REQ-010 | The command SHALL print a summary table to stdout showing: matched test count per matrix (A, B, C, D), pass/fail/skip counts per matrix, total matched vs. total matrix scenarios, and (when coverage is provided) per-module and overall coverage percentages. | P1 | The summary provides immediate feedback to engineers on the ingestion result without requiring them to open the matrix file. | Test |
| REQ-011 | The command SHALL return exit code 0 when all matched test cases have status `✅ Passed`. | P1 | Exit code 0 signals a clean CI run, allowing the pipeline to proceed. | Test |
| REQ-012 | The command SHALL return exit code 1 when at least one matched test case has status `❌ Failed`. | P1 | Exit code 1 blocks the pipeline, ensuring failures are addressed before release. | Test |
| REQ-013 | The command SHALL return exit code 2 when zero V-Model scenario IDs are matched in the JUnit XML file. | P1 | Exit code 2 signals likely misconfiguration — test names do not contain V-Model IDs, so the ingestion cannot proceed meaningfully. | Test |
| REQ-014 | The command SHALL support a `--json` flag that outputs the ingestion results as structured JSON to stdout, including: per-ID status mappings, per-matrix summary counts, and (when applicable) per-module coverage data. | P1 | Machine-readable JSON output enables downstream CI tools, dashboards, and the future audit-report command to consume ingestion data programmatically. | Test |
| REQ-015 | When a test case ID appears multiple times in the JUnit XML (e.g., from retries or parameterized runs), the command SHALL use the last occurrence as the definitive result. | P2 | CI systems may retry failed tests; the final attempt represents the definitive outcome for audit purposes. | Test |
| REQ-016 | The command SHALL NOT modify any rows in the matrix whose scenario ID does not appear in the JUnit XML input — their `⬜ Untested` status SHALL be preserved. | P1 | Partial ingestion must be safe: running a unit test suite should not affect acceptance test matrix entries that were not exercised. | Test |
| REQ-017 | When a scenario ID appears in the JUnit XML but does not exist in the matrix, the command SHALL report it as an unmatched ID in the summary output and skip it without error. | P2 | Robustness: extra test cases in JUnit XML that are not part of the V-Model matrix should not cause failures. | Test |
| REQ-018 | The coverage-map.yml file SHALL use the following structure: a top-level `mappings` key containing an array of objects, each with `mod_id` (string, e.g., `MOD-001`) and `files` (array of strings, e.g., `["src/reader.py", "src/reader_utils.py"]`). | P2 | A defined schema ensures the mapping file is parseable and consistent across projects. | Inspection |
| REQ-019 | The Coverage column value in Matrix D SHALL display the format `{stmt}% stmt / {branch}% branch`, where `{stmt}` and `{branch}` are numeric coverage percentages rounded to one decimal place. | P2 | Consistent formatting enables both human readability and machine parsing of coverage data. | Test |
| REQ-020 | When the `--coverage` argument is provided and a module's actual coverage falls below the `coverage_threshold` configured in `extension.yml`, the command SHALL flag that module's Coverage column with a warning indicator (`⚠`). | P2 | Coverage threshold enforcement surfaces compliance gaps at the point of ingestion rather than deferring to audit time. | Test |

### Non-Functional Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-NF-001 | The command SHALL be 100% deterministic: given the same JUnit XML input, Cobertura XML input (if provided), matrix file, and commit SHA, it SHALL always produce the same updated matrix and the same summary output. | P1 | Deterministic behavior is required for reproducible CI pipelines and reliable audit evidence. | Test |
| REQ-NF-002 | The Python helper script SHALL use only Python standard library modules (`xml.etree.ElementTree`, `json`, `re`, `sys`, `argparse`) with zero external dependencies. | P1 | Zero-dependency Python ensures the script runs on any CI environment with Python 3.x installed, without requiring `pip install`. | Inspection |
| REQ-NF-003 | The command SHALL handle JUnit XML files containing up to 10,000 test cases without exceeding 30 seconds of execution time on a standard CI runner. | P3 | Performance requirement ensures the script does not become a CI bottleneck for large test suites. | Test |

### Interface Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-IF-001 | The Bash wrapper script SHALL accept the following CLI syntax: `ingest-test-results.sh --input <junit.xml> [--coverage <cobertura.xml>] [--matrix <matrix.md>] [--coverage-map <map.yml>] [--commit-sha <sha>] [--json] [--help]`. | P1 | Consistent CLI interface with named arguments for all inputs. | Test |
| REQ-IF-002 | The PowerShell wrapper script SHALL accept equivalent PowerShell parameters: `Ingest-Test-Results.ps1 -Input <path> [-Coverage <path>] [-Matrix <path>] [-CoverageMap <path>] [-CommitSha <sha>] [-Json] [-Help]`. | P2 | PowerShell parity with idiomatic parameter naming conventions. | Test |
| REQ-IF-003 | The Python helper script SHALL accept the following CLI syntax: `parse_test_results.py --junit <junit.xml> [--cobertura <cobertura.xml>] [--coverage-map <map.yml>]` and SHALL output structured JSON to stdout. | P1 | The Python helper is the XML parsing engine; its JSON output is consumed by the Bash and PowerShell wrapper scripts. | Test |

### Constraint Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-CN-001 | The command SHALL NOT regenerate the traceability matrix — it SHALL only modify existing rows by updating the Status column and adding Date, Commit, and (optionally) Coverage columns. | P1 | The matrix is generated by `build-matrix.sh`; the test-results command is an overlay, not a replacement. | Inspection |
| REQ-CN-002 | The command SHALL NOT require any AI or LLM — all processing SHALL be performed by deterministic parsing and string matching logic. | P1 | The feature specification explicitly states this is "100% script, no AI" — the logic is fully deterministic. | Inspection |
| REQ-CN-003 | The command SHALL preserve all existing content in the matrix file that is outside the status columns — including headers, coverage summary sections, and manual annotations. | P1 | Engineers may add manual notes to the matrix; the ingestion must not destroy them. | Test |
| REQ-CN-004 | The command SHALL support re-running on the same matrix — subsequent ingestions SHALL update previously ingested statuses (e.g., a `❌ Failed` can become `✅ Passed` on a re-run), overwriting the Date and Commit columns with the latest values. | P1 | CI pipelines run repeatedly; the matrix must reflect the latest execution, not accumulate stale results. | Test |

## Assumptions

- Test case names in JUnit XML files contain V-Model scenario IDs as substrings (e.g., `SCN-001-A1 Given valid sensor data`). The scenario ID appears as a prefix or embedded token in the test name.
- The `traceability-matrix.md` file follows the structure generated by `build-matrix.sh`, with a Status column as the last column in each matrix table.
- Python 3.x is available on all CI runners where the command will be executed.
- The Cobertura XML format follows the standard schema with `<package>`, `<class>`, and coverage attributes (`line-rate`, `branch-rate`).
- The `module-design.md` file references source file paths in a parseable manner (e.g., in code blocks or explicit path references per MOD-NNN section).
- The `extension.yml` `coverage_threshold` value applies uniformly to all modules unless overridden by `coverage-map.yml`.

## Dependencies

- `build-matrix.sh` — generates the traceability matrix that this command modifies
- `setup-v-model.sh` — provides V-Model directory paths for default `--matrix` resolution
- `extension.yml` — provides `coverage_threshold` configuration
- Python 3.x standard library — `xml.etree.ElementTree`, `json`, `re`, `sys`, `argparse`
