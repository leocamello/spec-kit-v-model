# V-Model Acceptance Test Plan: Release Audit Report

**Feature Branch**: `feature/005e-audit-report`
**Created**: 2026-04-05
**Status**: Approved
**Source**: `specs/005e-audit-report/v-model/requirements.md`

## Overview

This document defines the acceptance test plan for the `/speckit.v-model.audit-report` command. Each requirement (REQ-NNN) is covered by one or more test cases (ATP-NNN-X), each with concrete BDD scenarios (SCN-NNN-X#) that validate the requirement.

## Test Cases

### REQ-001 — Artifact Discovery

#### ATP-001-A: Discovers all V-Model artifacts in directory

| Field | Value |
|-------|-------|
| **Traces To** | REQ-001 |
| **Precondition** | V-Model directory exists with all 11 artifact files |
| **Expected Result** | All artifacts appear in the inventory |

##### SCN-001-A1: Full artifact set discovered
```gherkin
Given a V-Model directory containing requirements.md, acceptance-plan.md, system-design.md, system-test.md, architecture-design.md, integration-test.md, module-design.md, unit-test.md, hazard-analysis.md, traceability-matrix.md, and waivers.md
When the audit-report command is run against this directory
Then all 11 artifacts SHALL appear in the artifact inventory section
```

##### SCN-001-A2: Partial artifact set discovered gracefully
```gherkin
Given a V-Model directory containing only requirements.md and traceability-matrix.md
When the audit-report command is run against this directory
Then only the 2 present artifacts SHALL appear in the inventory
And the report SHALL still be generated without error
```

### REQ-002 — Git Metadata Extraction

#### ATP-002-A: Extracts Git SHA and date for each artifact

| Field | Value |
|-------|-------|
| **Traces To** | REQ-002 |
| **Precondition** | V-Model directory is in a Git repository with committed artifacts |
| **Expected Result** | Each artifact row contains a 7-character SHA and YYYY-MM-DD date |

##### SCN-002-A1: Git SHA is 7-character abbreviated hash
```gherkin
Given a V-Model directory with committed artifacts
When the audit-report command generates the artifact inventory
Then each artifact row SHALL contain a 7-character Git SHA
```

##### SCN-002-A2: Date is ISO 8601 format
```gherkin
Given a V-Model directory with committed artifacts
When the audit-report command generates the artifact inventory
Then each artifact row SHALL contain a date in YYYY-MM-DD format
```

### REQ-003 — Artifact Inventory Table

#### ATP-003-A: Section 2 contains complete inventory table

| Field | Value |
|-------|-------|
| **Traces To** | REQ-003 |
| **Precondition** | V-Model directory with multiple artifacts |
| **Expected Result** | Section 2 contains a Markdown table with all required columns |

##### SCN-003-A1: Inventory table has all required columns
```gherkin
Given a V-Model directory with at least 3 artifacts
When the audit-report command generates the report
Then Section 2 SHALL contain a table with columns: Artifact, File, Git SHA, Last Modified, Status
```

### REQ-004 — Traceability Matrix Embedding

#### ATP-004-A: All matrices embedded in Section 3

| Field | Value |
|-------|-------|
| **Traces To** | REQ-004 |
| **Precondition** | traceability-matrix.md contains matrices A, B, C, D, and H |
| **Expected Result** | All 5 matrices appear in the report Section 3 |

##### SCN-004-A1: All present matrices embedded
```gherkin
Given a traceability-matrix.md with matrices A, B, C, D, and H
When the audit-report command generates the report
Then Section 3 SHALL contain all 5 matrix tables
And test execution status columns SHALL be preserved
```

##### SCN-004-A2: Partial matrices handled
```gherkin
Given a traceability-matrix.md with only matrices A and B
When the audit-report command generates the report
Then Section 3 SHALL contain only matrices A and B
```

### REQ-005 — Coverage Analysis

#### ATP-005-A: Coverage metrics computed per matrix

| Field | Value |
|-------|-------|
| **Traces To** | REQ-005 |
| **Precondition** | traceability-matrix.md with multiple matrices |
| **Expected Result** | Section 4 shows forward/backward coverage, gaps, and orphans per matrix |

##### SCN-005-A1: 100% coverage on clean project
```gherkin
Given a traceability-matrix.md with 100% coverage on all matrices
When the audit-report command generates the coverage analysis
Then all matrices SHALL show 100% forward and backward coverage
And gap count SHALL be 0 for all matrices
And orphan count SHALL be 0 for all matrices
```

##### SCN-005-A2: Gaps detected in incomplete project
```gherkin
Given a traceability-matrix.md where REQ-003 has no test coverage
When the audit-report command generates the coverage analysis
Then Matrix A SHALL show forward coverage < 100%
And gap count for Matrix A SHALL be > 0
```

### REQ-006 — Hazard Management Summary

#### ATP-006-A: Hazard summary extracted when present

| Field | Value |
|-------|-------|
| **Traces To** | REQ-006 |
| **Precondition** | hazard-analysis.md exists with HAZ-NNN entries |
| **Expected Result** | Section 5 contains hazard table with all required columns |

##### SCN-006-A1: All HAZ entries in summary
```gherkin
Given a hazard-analysis.md with 3 HAZ entries
When the audit-report command generates the report
Then Section 5 SHALL contain 3 rows in the hazard table
And each row SHALL include Severity, Mitigation, and Residual Risk
```

##### SCN-006-A2: No hazard section when hazard-analysis.md absent
```gherkin
Given a V-Model directory without hazard-analysis.md
When the audit-report command generates the report
Then Section 5 SHALL indicate no hazard analysis was performed
```

### REQ-007 — Anomaly Identification

#### ATP-007-A: Failed tests identified as anomalies

| Field | Value |
|-------|-------|
| **Traces To** | REQ-007 |
| **Precondition** | traceability-matrix.md with failed and skipped tests |
| **Expected Result** | All failed and skipped tests appear in the anomaly list |

##### SCN-007-A1: Failed test detected
```gherkin
Given a traceability-matrix.md where SCN-001-A2 has status ❌ Failed
When the audit-report command identifies anomalies
Then SCN-001-A2 SHALL appear in the anomaly list as type "Failed Test"
```

##### SCN-007-A2: Skipped test detected
```gherkin
Given a traceability-matrix.md where UTS-001-A1 has status ⏭️ Skipped
When the audit-report command identifies anomalies
Then UTS-001-A1 SHALL appear in the anomaly list as type "Skipped Test"
```

##### SCN-007-A3: Passed tests not listed as anomalies
```gherkin
Given a traceability-matrix.md where all tests have status ✅ Passed
When the audit-report command identifies anomalies
Then the anomaly list SHALL be empty
```

### REQ-008 — Waiver Parsing

#### ATP-008-A: WAV-NNN entries parsed from waivers.md

| Field | Value |
|-------|-------|
| **Traces To** | REQ-008 |
| **Precondition** | waivers.md exists with WAV-NNN entries |
| **Expected Result** | Each WAV entry is parsed with its artifact ID |

##### SCN-008-A1: Single waiver parsed
```gherkin
Given a waivers.md with WAV-001 covering artifact UTS-012-C2
When the audit-report command parses waivers
Then WAV-001 SHALL be associated with artifact ID UTS-012-C2
```

##### SCN-008-A2: Multiple waivers parsed
```gherkin
Given a waivers.md with WAV-001 and WAV-002 covering different artifacts
When the audit-report command parses waivers
Then both waivers SHALL be parsed with their respective artifact IDs
```

##### SCN-008-A3: No waivers.md present
```gherkin
Given a V-Model directory without waivers.md
When the audit-report command runs
Then waiver list SHALL be empty
And any anomalies SHALL be treated as unwaived
```

### REQ-009 — Anomaly-Waiver Cross-Referencing

#### ATP-009-A: Waived anomalies listed as Waived

| Field | Value |
|-------|-------|
| **Traces To** | REQ-009 |
| **Precondition** | Anomalies exist with matching waivers |
| **Expected Result** | Matched anomalies show "Waived" disposition |

##### SCN-009-A1: Waived anomaly listed as Waived
```gherkin
Given a skipped test UTS-012-C2 and a waiver WAV-001 covering UTS-012-C2
When the audit-report generates the Known Anomalies section
Then UTS-012-C2 SHALL be listed with disposition "Waived"
And the waiver reference WAV-001 SHALL appear in the row
```

##### SCN-009-A2: Unwaived anomaly listed as BLOCKING
```gherkin
Given a failed test SCN-001-A2 and no waiver covering SCN-001-A2
When the audit-report generates the Known Anomalies section
Then SCN-001-A2 SHALL be listed with disposition "BLOCKING"
```

### REQ-010 — Compliance Status Computation

#### ATP-010-A: RELEASE READY when zero anomalies

| Field | Value |
|-------|-------|
| **Traces To** | REQ-010 |
| **Precondition** | All tests passed, no anomalies |
| **Expected Result** | Status is ✅ RELEASE READY |

##### SCN-010-A1: RELEASE READY status
```gherkin
Given a V-Model directory where all tests have status ✅ Passed and no peer-review Critical/Major findings
When the audit-report command computes compliance status
Then the status SHALL be "✅ RELEASE READY"
```

#### ATP-010-B: RELEASE CANDIDATE when all anomalies waived

| Field | Value |
|-------|-------|
| **Traces To** | REQ-010 |
| **Precondition** | Anomalies exist but all are waived |
| **Expected Result** | Status is ✅ RELEASE CANDIDATE |

##### SCN-010-B1: RELEASE CANDIDATE status
```gherkin
Given 2 skipped tests each with a matching waiver in waivers.md
When the audit-report command computes compliance status
Then the status SHALL be "✅ RELEASE CANDIDATE"
```

#### ATP-010-C: NOT READY when unwaived anomalies exist

| Field | Value |
|-------|-------|
| **Traces To** | REQ-010 |
| **Precondition** | At least one anomaly has no matching waiver |
| **Expected Result** | Status is ❌ NOT READY |

##### SCN-010-C1: NOT READY status
```gherkin
Given 1 failed test with no matching waiver
When the audit-report command computes compliance status
Then the status SHALL be "❌ NOT READY"
```

### REQ-011 — Executive Summary

#### ATP-011-A: Section 1 contains all required fields

| Field | Value |
|-------|-------|
| **Traces To** | REQ-011 |
| **Precondition** | Complete V-Model directory with metadata arguments |
| **Expected Result** | Executive summary shows all computed metrics |

##### SCN-011-A1: Executive summary populated
```gherkin
Given a V-Model directory with --system-name "CBGMS" --version "2.1.0" --git-tag "v2.1.0"
When the audit-report command generates the report
Then Section 1 SHALL contain the system name, version, git tag, date, requirement count, test count, pass/fail/skip counts, and compliance status
```

### REQ-012 — Signature Block

#### ATP-012-A: Section 7 contains signature lines

| Field | Value |
|-------|-------|
| **Traces To** | REQ-012 |
| **Precondition** | Audit report generated |
| **Expected Result** | Signature block with blank lines and Git metadata |

##### SCN-012-A1: Signature block present
```gherkin
Given a generated audit report with --git-tag "v2.1.0"
When the report is examined
Then Section 7 SHALL contain rows for QA Manager and Lead Engineer with blank signature fields
And the Git tag and SHA SHALL be included
```

### REQ-013 — Metadata Arguments

#### ATP-013-A: Metadata arguments populate executive summary

| Field | Value |
|-------|-------|
| **Traces To** | REQ-013 |
| **Precondition** | Command invoked with all metadata arguments |
| **Expected Result** | All metadata appears in the report |

##### SCN-013-A1: System name in executive summary
```gherkin
Given the command is run with --system-name "TestSystem"
When the audit report is generated
Then the Executive Summary SHALL contain "TestSystem"
```

##### SCN-013-A2: Default values when arguments omitted
```gherkin
Given the command is run without --system-name, --version, or --git-tag
When the audit report is generated
Then the Executive Summary SHALL use placeholder values for missing metadata
```

### REQ-014 — Output Path

#### ATP-014-A: Custom output path

| Field | Value |
|-------|-------|
| **Traces To** | REQ-014 |
| **Precondition** | --output argument provided |
| **Expected Result** | Report written to specified path |

##### SCN-014-A1: Custom output path used
```gherkin
Given the command is run with --output /tmp/audit.md
When the audit report is generated
Then the report SHALL be written to /tmp/audit.md
```

##### SCN-014-A2: Default output path
```gherkin
Given the command is run without --output
When the audit report is generated
Then the report SHALL be written to release-audit-report.md in the V-Model directory
```

### REQ-015 — Exit Code 0

#### ATP-015-A: Exit 0 for RELEASE READY

| Field | Value |
|-------|-------|
| **Traces To** | REQ-015 |
| **Precondition** | Zero anomalies |
| **Expected Result** | Exit code 0 |

##### SCN-015-A1: Exit 0 on clean project
```gherkin
Given a V-Model directory with all tests passed and no anomalies
When the audit-report command runs
Then the exit code SHALL be 0
```

#### ATP-015-B: Exit 0 for RELEASE CANDIDATE

| Field | Value |
|-------|-------|
| **Traces To** | REQ-015 |
| **Precondition** | Anomalies exist but all waived |
| **Expected Result** | Exit code 0 |

##### SCN-015-B1: Exit 0 when all anomalies waived
```gherkin
Given a V-Model directory with 2 skipped tests and 2 matching waivers
When the audit-report command runs
Then the exit code SHALL be 0
```

### REQ-016 — Exit Code 1

#### ATP-016-A: Exit 1 for NOT READY

| Field | Value |
|-------|-------|
| **Traces To** | REQ-016 |
| **Precondition** | Unwaived anomalies detected |
| **Expected Result** | Exit code 1 |

##### SCN-016-A1: Exit 1 on unwaived failure
```gherkin
Given a V-Model directory with 1 failed test and no matching waiver
When the audit-report command runs
Then the exit code SHALL be 1
```

### REQ-017 — Exit Code 2

#### ATP-017-A: Exit 2 for missing required artifacts

| Field | Value |
|-------|-------|
| **Traces To** | REQ-017 |
| **Precondition** | Required artifacts missing |
| **Expected Result** | Exit code 2 |

##### SCN-017-A1: Exit 2 when requirements.md missing
```gherkin
Given a V-Model directory without requirements.md
When the audit-report command runs
Then the exit code SHALL be 2
```

##### SCN-017-A2: Exit 2 when traceability-matrix.md missing
```gherkin
Given a V-Model directory without traceability-matrix.md
When the audit-report command runs
Then the exit code SHALL be 2
```

### REQ-018 — JSON Output

#### ATP-018-A: JSON output structure

| Field | Value |
|-------|-------|
| **Traces To** | REQ-018 |
| **Precondition** | --json flag provided |
| **Expected Result** | Valid JSON with all required fields |

##### SCN-018-A1: JSON contains compliance_status
```gherkin
Given the command is run with --json
When the JSON output is parsed
Then it SHALL contain a "compliance_status" field
```

##### SCN-018-A2: JSON contains artifact inventory
```gherkin
Given the command is run with --json
When the JSON output is parsed
Then it SHALL contain an "artifacts" array with file, sha, and date for each artifact
```

##### SCN-018-A3: JSON contains anomalies with waiver status
```gherkin
Given a project with anomalies and waivers and the --json flag
When the JSON output is parsed
Then it SHALL contain an "anomalies" array with each anomaly's id, type, and waiver status
```

### REQ-019 — Orphaned Waivers

#### ATP-019-A: Orphaned waivers reported

| Field | Value |
|-------|-------|
| **Traces To** | REQ-019 |
| **Precondition** | Waiver exists for an artifact that is not an anomaly |
| **Expected Result** | Waiver listed as Orphaned |

##### SCN-019-A1: Orphaned waiver detected
```gherkin
Given a waivers.md with WAV-003 covering UTS-999-A1 which is not an anomaly
When the audit-report generates the Known Anomalies section
Then WAV-003 SHALL be reported as an "Orphaned" waiver
And the compliance status SHALL NOT be affected by the orphaned waiver
```

### REQ-020 — Human-Readable Summary

#### ATP-020-A: Summary printed to stderr

| Field | Value |
|-------|-------|
| **Traces To** | REQ-020 |
| **Precondition** | Command runs successfully |
| **Expected Result** | Summary shows key metrics |

##### SCN-020-A1: Summary contains compliance status
```gherkin
Given a V-Model directory with all tests passed
When the audit-report command runs
Then the stderr output SHALL contain the compliance status
And it SHALL show artifact count, test count, and pass/fail/skip breakdown
```

### REQ-NF-001 — Deterministic Output

#### ATP-NF-001-A: Identical output on repeated runs

| Field | Value |
|-------|-------|
| **Traces To** | REQ-NF-001 |
| **Precondition** | Same V-Model directory without changes |
| **Expected Result** | Two consecutive runs produce identical reports |

##### SCN-NF-001-A1: Deterministic output
```gherkin
Given a V-Model directory with no changes between runs
When the audit-report command is run twice
Then the two generated reports SHALL be byte-identical
```

### REQ-IF-001 — Bash CLI Syntax

#### ATP-IF-001-A: Bash accepts all arguments

| Field | Value |
|-------|-------|
| **Traces To** | REQ-IF-001 |
| **Precondition** | Bash script invoked with all arguments |
| **Expected Result** | All arguments parsed correctly |

##### SCN-IF-001-A1: --help exits 0
```gherkin
Given the Bash script is invoked with --help
When the script runs
Then it SHALL exit with code 0
And the output SHALL contain usage information
```

##### SCN-IF-001-A2: Missing vmodel-dir exits 2
```gherkin
Given the Bash script is invoked without a positional argument
When the script runs
Then it SHALL exit with code 2
```

### REQ-IF-002 — PowerShell CLI Syntax

#### ATP-IF-002-A: PowerShell accepts all parameters

| Field | Value |
|-------|-------|
| **Traces To** | REQ-IF-002 |
| **Precondition** | PowerShell script invoked with all parameters |
| **Expected Result** | All parameters parsed correctly |

##### SCN-IF-002-A1: -Help exits 0
```gherkin
Given the PowerShell script is invoked with -Help
When the script runs
Then it SHALL exit with code 0
And the output SHALL contain usage information
```

##### SCN-IF-002-A2: Missing -VModelDir exits 2
```gherkin
Given the PowerShell script is invoked without -VModelDir
When the script runs
Then it SHALL exit with code 2
```

### REQ-CN-001 — No AI

#### ATP-CN-001-A: Script contains no LLM calls

| Field | Value |
|-------|-------|
| **Traces To** | REQ-CN-001 |
| **Precondition** | Script source code |
| **Expected Result** | No AI/LLM invocations found |

##### SCN-CN-001-A1: No AI dependencies
```gherkin
Given the build-audit-report.sh script source
When inspected for AI/LLM calls
Then no LLM API calls, model invocations, or AI dependencies SHALL be found
```

### REQ-CN-003 — Waiver Format

#### ATP-CN-003-A: Waiver parsing validates format

| Field | Value |
|-------|-------|
| **Traces To** | REQ-CN-003 |
| **Precondition** | waivers.md with properly formatted entries |
| **Expected Result** | All required fields extracted |

##### SCN-CN-003-A1: Waiver fields extracted
```gherkin
Given a waivers.md with WAV-001 containing Artifact, Type, Justification, and Approved By fields
When the audit-report command parses waivers
Then all four fields SHALL be extracted for WAV-001
```

---

## V&V Distinction (IEEE 1012:2016)

Per `commands/acceptance.md` Step 6c, each ATP test case is classified as **Verification** (built right — conforms to spec) or **Validation** (right product — meets stakeholder need) per IEEE 1012:2016.

### Classification Table

| ATP ID | Requirement | V&V Classification | Rationale |
|--------|-------------|-------------------|-----------|
| ATP-001-A | REQ-001 Artifact Discovery | Verification | Confirms script behavior matches the specified list of discoverable files — a conformance check against the spec. |
| ATP-002-A | REQ-002 Git Metadata | Verification | Confirms 7-char SHA and ISO 8601 date format match the specification contract. |
| ATP-003-A | REQ-003 Artifact Inventory Table | Verification | Confirms Markdown table structure and required column names match the specification. |
| ATP-004-A | REQ-004 Matrix Embedding | Verification | Confirms all traceability matrices are embedded with execution status columns preserved. |
| ATP-005-A | REQ-005 Coverage Analysis | Verification | Confirms coverage metrics computation algorithm matches specification. |
| ATP-006-A | REQ-006 Hazard Summary | Verification | Confirms HAZ entries are extracted and rendered per specification. |
| ATP-007-A | REQ-007 Anomaly Identification | Verification | Confirms that ❌ Failed and ⏭️ Skipped statuses are detected as specified. |
| ATP-008-A | REQ-008 Waiver Parsing | Verification | Confirms WAV-NNN heading regex and **Artifact**: field extraction match specification. |
| ATP-009-A | REQ-009 Anomaly-Waiver Cross-Referencing | Verification + Validation | Verifies cross-referencing logic matches spec (Verification) AND validates that the resulting Waived/BLOCKING classification correctly represents an auditor's release decision model (Validation). |
| ATP-010-A | REQ-010 RELEASE READY | Verification + Validation | Verifies three-state compliance logic matches spec (Verification) AND validates that ✅ RELEASE READY satisfies an auditor's expectation of release readiness (Validation — the report serves its intended purpose). |
| ATP-010-B | REQ-010 RELEASE CANDIDATE | Verification + Validation | Same dual classification as ATP-010-A — RELEASE CANDIDATE is a Validation concern because it must satisfy auditor acceptance of all-waived deviations. |
| ATP-010-C | REQ-010 NOT READY | Verification + Validation | The ❌ NOT READY status is the strongest Validation test: it confirms the product correctly prevents accidental release — a direct stakeholder-safety concern. |
| ATP-011-A | REQ-011 Executive Summary | Validation | Verifies the executive summary contains the fields auditors need to determine release readiness at a glance — a stakeholder-utility test, not merely a format check. |
| ATP-012-A | REQ-012 Signature Block | Verification | Confirms signature block structure matches specification format. |
| ATP-013-A | REQ-013 Metadata Arguments | Verification | Confirms argument parsing behavior matches the CLI specification. |
| ATP-014-A | REQ-014 Output Path | Verification | Confirms file output path behavior matches specification. |
| ATP-015-A | REQ-015 Exit Code 0 (READY) | Verification | Confirms exit code 0 matches the specified RELEASE READY condition. |
| ATP-015-B | REQ-015 Exit Code 0 (CANDIDATE) | Verification | Confirms exit code 0 for RELEASE CANDIDATE path. |
| ATP-016-A | REQ-016 Exit Code 1 | Verification + Validation | Verifies exit code matches spec (Verification) AND validates that CI pipelines are correctly blocked from deploying (Validation — the core safety gate). |
| ATP-017-A | REQ-017 Exit Code 2 | Verification | Confirms configuration error detection matches specification. |
| ATP-018-A | REQ-018 JSON Output | Verification | Confirms JSON structure and field names match specification. |
| ATP-019-A | REQ-019 Orphaned Waivers | Verification | Confirms orphan detection logic matches specification. |
| ATP-020-A | REQ-020 Human-Readable Summary | Verification | Confirms stderr summary content and format match specification. |
| ATP-NF-001-A | REQ-NF-001 Deterministic Output | Verification | Confirms byte-identical output across repeated runs — a correctness property. |
| ATP-IF-001-A | REQ-IF-001 Bash CLI Syntax | Verification | Confirms Bash argument parsing contract matches specification. |
| ATP-IF-002-A | REQ-IF-002 PowerShell CLI Syntax | Verification | Confirms PowerShell parameter parsing contract matches specification. |
| ATP-CN-001-A | REQ-CN-001 No AI | Verification | Confirms absence of LLM/AI calls by source code inspection. |
| ATP-CN-003-A | REQ-CN-003 Waiver Format | Verification | Confirms waiver field extraction matches the structured format specification. |

### V&V Independence Recommendation

Per IEEE 1012:2016 §5.3, test cases that exercise compliance gating decisions should be executed by an **independent verifier** — a tester who did not author the script under test. The following ATP test cases carry the highest regulatory risk and SHOULD be executed independently:

| ATP ID | Rationale for Independence |
|--------|-----------------------------|
| ATP-009-A | Cross-referencing logic directly determines Waived/BLOCKING classification — the core audit gate |
| ATP-010-A, ATP-010-B, ATP-010-C | Compliance status computation is the primary go/no-go release signal |
| ATP-016-A | Exit code 1 blocking behavior prevents inadvertent releases in CI pipelines |

---

## Quality-in-Use Acceptance Criteria (ISO 25010:2023)

Per `commands/acceptance.md` Step 6d, the audit-report command is evaluated against ISO/IEC 25010:2023 Quality-in-Use characteristics, assessing fitness for purpose from the user's perspective in their actual context of use.

| Quality-in-Use Characteristic | ISO 25010 Ref | Acceptance Criterion | Measurement Method | Pass Condition |
|-------------------------------|--------------|---------------------|-------------------|----------------|
| **Effectiveness** — Can users achieve their goal completely and accurately? | §4.1.1 | An audit engineer can determine release readiness from the generated report within 5 minutes, without needing to open any source V-Model artifacts | User review task: provide a release audit report to an auditor unfamiliar with the project; measure time to reach a release decision | Auditor reaches a definitive decision (READY / NOT READY / CANDIDATE) in < 5 minutes with no additional file access |
| **Efficiency** — Resources expended relative to goal achievement | §4.1.2 | Command completes in under 30 seconds for a project with up to 500 V-Model IDs | Automated timing: `time build-audit-report.sh <vmodel-dir>` with a 500-ID test fixture | Wall-clock time < 30 seconds (per REQ-NF-003) |
| **Satisfaction** — Positive attitudes and comfort of use | §4.1.3 | Audit engineers report the report format is clear and usable for regulatory submission | Post-use survey: "Would you submit this report as part of a regulatory compliance package?" | ≥ 80% positive responses from a pilot group of ≥ 3 audit engineers |
| **Freedom from Risk** — Risk mitigation (economic, health, safety, environmental) | §4.1.4 | The ❌ NOT READY status with exit code 1 prevents accidental release of software with unresolved anomalies in CI pipelines | Integration test: CI pipeline configured with `audit-report` as a gate; confirm pipeline blocks on exit code 1 | CI pipeline terminates without deploying when exit code is 1 |
| **Context Coverage** — Completeness across intended contexts of use | §4.1.5 | The generated report is useful and complete for all 3 target regulatory contexts: ISO 26262 (automotive), DO-178C (aerospace), IEC 62304 (medical) | Create a test report for each regulatory context using `--regulatory-context`; assess completeness of content for each standard | Report contains all required evidence sections for each regulatory context; no section is empty or placeholder-only |
