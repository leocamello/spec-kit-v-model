# Traceability Matrix

**Generated**: 2026-04-04
**Source**: `/home/lhnascimento/Projects/spec-kit/leocamello/spec-kit-v-model/specs/005c-peer-review/v-model/`

## Matrix A — Validation (User View)

| Requirement ID | Requirement Description | Test Case ID (ATP) | Validation Condition | Scenario ID (SCN) | Status |
|----------------|------------------------|--------------------|----------------------|--------------------|--------|
| **REQ-001** | The command SHALL read a single V-Model artifact file specified by the user and produce a peer review report as a markdown file named `peer-review-{artifact}.md` in the V-Model directory, where `{artifact}` matches the base name of the reviewed file (e.g., `peer-review-requirements.md` for `requirements.md`). | ATP-001-A | Command reads artifact and produces correctly named review file | SCN-001-A1 | ⬜ Untested |
| | | ATP-001-B | Output file name matches artifact base name for different artifact types | SCN-001-B1 | ⬜ Untested |
| | | ATP-001-B | Output file name matches artifact base name for different artifact types | SCN-001-B2 | ⬜ Untested |
| **REQ-002** | The command SHALL use AI (LLM) evaluation to assess prose quality, structural completeness, standards compliance, and cross-reference integrity of the input artifact. | ATP-002-A | AI evaluates prose quality, structural completeness, standards compliance, and cross-reference integrity | SCN-002-A1 | ⬜ Untested |
| | | ATP-002-B | AI evaluation is not replaceable by deterministic scripting | SCN-002-B1 | ⬜ Untested |
| **REQ-003** | When reviewing `requirements.md`, the command SHALL evaluate each requirement against INCOSE quality attributes: atomic, testable, unambiguous, complete, free of subjective language, and priority assigned. | ATP-003-A | Evaluates each requirement against all INCOSE quality attributes | SCN-003-A1 | ⬜ Untested |
| | | ATP-003-B | Clean requirements generate no Critical or Major findings | SCN-003-B1 | ⬜ Untested |
| **REQ-004** | When reviewing `system-design.md`, the command SHALL evaluate against IEEE 1016 criteria: all 4 design views present, every SYS component traces to at least one REQ, interface contracts complete, and derived requirements flagged. | ATP-004-A | Evaluates system-design.md against IEEE 1016 criteria | SCN-004-A1 | ⬜ Untested |
| | | ATP-004-B | Detects derived requirements not flagged | SCN-004-B1 | ⬜ Untested |
| **REQ-005** | When reviewing `architecture-design.md`, the command SHALL evaluate against IEEE 42010 / Kruchten 4+1 criteria: 4+1 views populated, CROSS-CUTTING modules justified, and interface definitions complete. | ATP-005-A | Evaluates architecture-design.md against 4+1 views criteria | SCN-005-A1 | ⬜ Untested |
| | | ATP-005-B | Complete architecture generates no Critical findings | SCN-005-B1 | ⬜ Untested |
| **REQ-006** | When reviewing `system-test.md`, the command SHALL evaluate against ISO 29119 criteria: named techniques used correctly, no user-journey language present, and test scenario independence maintained. | ATP-006-A | Evaluates system-test.md against ISO 29119 criteria | SCN-006-A1 | ⬜ Untested |
| | | ATP-006-B | Properly structured system tests pass review | SCN-006-B1 | ⬜ Untested |
| **REQ-007** | When reviewing `integration-test.md`, the command SHALL evaluate against ISO 29119-4 criteria: CDCT technique present, fault injection scenarios included, and interface coverage complete. | ATP-007-A | Evaluates integration-test.md against ISO 29119-4 criteria | SCN-007-A1 | ⬜ Untested |
| | | ATP-007-B | Complete integration tests pass review | SCN-007-B1 | ⬜ Untested |
| **REQ-008** | When reviewing `module-design.md`, the command SHALL evaluate against DO-178C / ISO 26262 criteria: 4 mandatory views present, algorithm specifications complete, and error handling defined. | ATP-008-A | Evaluates module-design.md against DO-178C / ISO 26262 criteria | SCN-008-A1 | ⬜ Untested |
| | | ATP-008-B | Complete module design passes review | SCN-008-B1 | ⬜ Untested |
| **REQ-009** | When reviewing `unit-test.md`, the command SHALL evaluate against ISO 29119-4 criteria: 5 techniques present, mock registry complete, and boundary values explicit. | ATP-009-A | Evaluates unit-test.md against ISO 29119-4 criteria | SCN-009-A1 | ⬜ Untested |
| | | ATP-009-B | Complete unit tests pass review | SCN-009-B1 | ⬜ Untested |
| **REQ-010** | When reviewing `hazard-analysis.md`, the command SHALL evaluate against ISO 14971 / ISO 26262 criteria: severity classifications present for each hazard, every HAZ has a mitigation defined, operational state coverage present, and residual risk assessed. | ATP-010-A | Evaluates hazard-analysis.md against ISO 14971 / ISO 26262 criteria | SCN-010-A1 | ⬜ Untested |
| | | ATP-010-B | Complete hazard analysis passes review | SCN-010-B1 | ⬜ Untested |
| **REQ-011** | When reviewing `acceptance-plan.md`, the command SHALL evaluate against ISO 29119 criteria: BDD scenarios well-formed, validation conditions measurable, and coverage of parent REQs verified. | ATP-011-A | Evaluates acceptance-plan.md against ISO 29119 criteria | SCN-011-A1 | ⬜ Untested |
| | | ATP-011-B | Well-formed acceptance plan passes review | SCN-011-B1 | ⬜ Untested |
| **REQ-012** | Each finding in the review report SHALL be assigned a unique identifier using the pattern `PRF-{ARTIFACT}-NNN`, where `{ARTIFACT}` is an uppercase abbreviation derived from the artifact type (e.g., REQ for requirements, SYS for system-design, ARCH for architecture-design, HAZ for hazard-analysis) and `NNN` is a zero-padded sequential number starting at 001. | ATP-012-A | Findings use correct PRF ID pattern with proper artifact abbreviation | SCN-012-A1 | ⬜ Untested |
| | | ATP-012-A | Findings use correct PRF ID pattern with proper artifact abbreviation | SCN-012-A2 | ⬜ Untested |
| | | ATP-012-B | Sequential numbering restarts at 001 per invocation | SCN-012-B1 | ⬜ Untested |
| **REQ-013** | Each finding SHALL be classified with exactly one severity level from the set: Critical, Major, Minor, Observation. | ATP-013-A | Each finding has exactly one severity from the defined set | SCN-013-A1 | ⬜ Untested |
| | | ATP-013-B | No finding has an unlisted or missing severity | SCN-013-B1 | ⬜ Untested |
| **REQ-014** | A finding SHALL be classified as Critical when it identifies a fundamental quality violation that blocks release, such as an untestable requirement, a missing mandatory view, or an unmitigated catastrophic hazard. | ATP-014-A | Untestable requirement generates Critical finding | SCN-014-A1 | ⬜ Untested |
| | | ATP-014-B | Missing mandatory view in design generates Critical finding | SCN-014-B1 | ⬜ Untested |
| **REQ-015** | A finding SHALL be classified as Major when it identifies a quality issue that should be resolved before approval, such as an ambiguous quantifier, an incomplete interface contract, or a missing test technique. | ATP-015-A | Ambiguous quantifier generates Major finding | SCN-015-A1 | ⬜ Untested |
| | | ATP-015-B | Missing test technique generates Major finding | SCN-015-B1 | ⬜ Untested |
| **REQ-016** | A finding SHALL be classified as Minor when it identifies a style or completeness issue that does not affect correctness, such as inconsistent formatting or a missing rationale on a low-risk item. | ATP-016-A | Inconsistent formatting generates Minor finding | SCN-016-A1 | ⬜ Untested |
| | | ATP-016-B | Missing rationale on low-risk item generates Minor finding | SCN-016-B1 | ⬜ Untested |
| **REQ-017** | A finding SHALL be classified as Observation when it identifies an informational suggestion for improvement that is not a defect, such as an alternative decomposition strategy or an additional test technique that could add value. | ATP-017-A | Improvement suggestion generates Observation finding | SCN-017-A1 | ⬜ Untested |
| | | ATP-017-B | Observations do not block CI gate | SCN-017-B1 | ⬜ Untested |
| **REQ-018** | The review report header section SHALL include: the reviewer identification, the generation date, the artifact file name, the count of items in the reviewed artifact, and the governing standard for the artifact type. | ATP-018-A | Header contains all required fields | SCN-018-A1 | ⬜ Untested |
| | | ATP-018-B | Item count matches actual artifact items | SCN-018-B1 | ⬜ Untested |
| **REQ-019** | The review report SHALL include a summary table that displays finding counts for each severity level (Critical, Major, Minor, Observation). | ATP-019-A | Summary table displays counts for all four severity levels | SCN-019-A1 | ⬜ Untested |
| | | ATP-019-B | Summary table counts match actual findings in the report | SCN-019-B1 | ⬜ Untested |
| **REQ-020** | Each finding subsection in the review report SHALL include the following fields: PRF ID, Severity, Location (referencing the specific artifact item ID), Description, and Recommendation. | ATP-020-A | Each finding contains all five required fields | SCN-020-A1 | ⬜ Untested |
| | | ATP-020-B | Location field references a specific artifact item ID | SCN-020-B1 | ⬜ Untested |
| **REQ-021** | The command SHALL regenerate the entire `peer-review-{artifact}.md` file on each invocation, replacing any previously generated review for the same artifact. | ATP-021-A | Re-running replaces the previous review file entirely | SCN-021-A1 | ⬜ Untested |
| | | ATP-021-B | Resolved findings disappear after fix and re-run | SCN-021-B1 | ⬜ Untested |
| **REQ-022** | The extension SHALL provide a `peer-review-check.sh` Bash script that reads a `peer-review-{artifact}.md` file and returns an exit code based on the severities of findings present in the file. | ATP-022-A | Script exists and processes a review file | SCN-022-A1 | ⬜ Untested |
| | | ATP-022-B | Script handles missing or invalid review file | SCN-022-B1 | ⬜ Untested |
| **REQ-023** | The `peer-review-check.sh` script SHALL return exit code 0 when the review file contains zero findings or contains only Observation-level findings. | ATP-023-A | Zero findings review returns exit code 0 | SCN-023-A1 | ⬜ Untested |
| | | ATP-023-B | Observations-only review returns exit code 0 | SCN-023-B1 | ⬜ Untested |
| **REQ-024** | The `peer-review-check.sh` script SHALL return exit code 1 when the review file contains at least one Critical finding or at least one Major finding. | ATP-024-A | Critical finding returns exit code 1 | SCN-024-A1 | ⬜ Untested |
| | | ATP-024-B | Major finding without Critical also returns exit code 1 | SCN-024-B1 | ⬜ Untested |
| **REQ-025** | The `peer-review-check.sh` script SHALL return exit code 2 when the review file contains at least one Minor finding and contains zero Critical findings and zero Major findings. | ATP-025-A | Minor-only review returns exit code 2 | SCN-025-A1 | ⬜ Untested |
| | | ATP-025-B | Minor with Observation but no Critical/Major returns exit code 2 | SCN-025-B1 | ⬜ Untested |
| **REQ-026** | The `peer-review-check.sh` script SHALL determine finding severities by parsing the summary table or individual finding headers in the peer review markdown file. | ATP-026-A | Script parses summary table for severity counts | SCN-026-A1 | ⬜ Untested |
| | | ATP-026-B | Script parses individual finding headers as fallback | SCN-026-B1 | ⬜ Untested |
| **REQ-027** | The `peer-review-check.sh` script SHALL support a `--json` flag that outputs finding counts by severity level as structured JSON to stdout. | ATP-027-A | --json outputs valid JSON with severity counts to stdout | SCN-027-A1 | ⬜ Untested |
| | | ATP-027-B | --json output is parseable by standard JSON tools | SCN-027-B1 | ⬜ Untested |
| **REQ-028** | The extension SHALL provide a `peer-review-check.ps1` PowerShell script that accepts the same input and produces identical exit code semantics and `--json` output structure as the `peer-review-check.sh` Bash script. | ATP-028-A | peer-review-check.ps1 produces same exit codes as Bash script | SCN-028-A1 | ⬜ Untested |
| | | ATP-028-B | --json output structure is identical between scripts | SCN-028-B1 | ⬜ Untested |
| **REQ-029** | The command SHALL accept any one of the 9 supported artifact types (requirements.md, system-design.md, architecture-design.md, system-test.md, integration-test.md, module-design.md, unit-test.md, hazard-analysis.md, acceptance-plan.md) for review without requiring any other V-Model artifacts to be present. | ATP-029-A | Command accepts each of the 9 supported artifact types | SCN-029-A1 | ⬜ Untested |
| | | ATP-029-A | Command accepts each of the 9 supported artifact types | SCN-029-A2 | ⬜ Untested |
| | | ATP-029-A | Command accepts each of the 9 supported artifact types | SCN-029-A3 | ⬜ Untested |
| | | ATP-029-B | Command operates without other V-Model artifacts present | SCN-029-B1 | ⬜ Untested |
| **REQ-CN-001** | The command SHALL NOT modify the original artifact being reviewed — it is a read-only analysis tool that only produces a new review report file. | ATP-CN-001-A | Original artifact is unchanged after review | SCN-CN-001-A1 | ⬜ Untested |
| | | ATP-CN-001-B | No other V-Model artifacts are modified | SCN-CN-001-B1 | ⬜ Untested |
| **REQ-CN-002** | PRF-{ARTIFACT}-NNN finding IDs SHALL NOT participate in the V-Model traceability chain and SHALL NOT be referenced by trace matrices or coverage metrics. | ATP-CN-002-A | PRF IDs do not appear in trace matrices | SCN-CN-002-A1 | ⬜ Untested |
| | | ATP-CN-002-B | Coverage metrics exclude PRF IDs | SCN-CN-002-B1 | ⬜ Untested |
| **REQ-CN-003** | Each invocation of the command SHALL review exactly one artifact; the command SHALL NOT accept multiple artifact files in a single invocation. | ATP-CN-003-A | Command rejects multiple artifact files in a single invocation | SCN-CN-003-A1 | ⬜ Untested |
| | | ATP-CN-003-B | Single artifact invocation succeeds normally | SCN-CN-003-B1 | ⬜ Untested |
| **REQ-CN-004** | The command SHALL NOT maintain a database or persistent store of past findings; git history SHALL serve as the audit trail of what was found and when it was resolved. | ATP-CN-004-A | No database or persistent store files created by the command | SCN-CN-004-A1 | ⬜ Untested |
| | | ATP-CN-004-B | Git history serves as audit trail | SCN-CN-004-B1 | ⬜ Untested |
| **REQ-IF-001** | The `peer-review-check.sh` script SHALL accept the following CLI syntax: `peer-review-check.sh [--json] <peer-review-file>`. | ATP-IF-001-A | Correct CLI syntax accepted | SCN-IF-001-A1 | ⬜ Untested |
| | | ATP-IF-001-A | Correct CLI syntax accepted | SCN-IF-001-A2 | ⬜ Untested |
| | | ATP-IF-001-B | Invalid arguments produce error message | SCN-IF-001-B1 | ⬜ Untested |
| **REQ-IF-002** | The `peer-review-check.ps1` script SHALL accept equivalent PowerShell parameters: `Peer-Review-Check.ps1 [-Json] -ReviewFile <path>`. | ATP-IF-002-A | Correct PowerShell parameters accepted | SCN-IF-002-A1 | ⬜ Untested |
| | | ATP-IF-002-A | Correct PowerShell parameters accepted | SCN-IF-002-A2 | ⬜ Untested |
| | | ATP-IF-002-B | Missing required parameter produces error | SCN-IF-002-B1 | ⬜ Untested |
| **REQ-NF-001** | The command SHALL operate statelessly: the review report SHALL contain no persistent status fields (e.g., no "Status: Open/Closed" on individual findings); the presence of a finding in the report indicates a current problem, and its absence after re-run indicates resolution. | ATP-NF-001-A | Report contains no persistent status fields on findings | SCN-NF-001-A1 | ⬜ Untested |
| | | ATP-NF-001-B | Finding absence after re-run indicates resolution | SCN-NF-001-B1 | ⬜ Untested |
| **REQ-NF-002** | The `peer-review-check.sh` and `peer-review-check.ps1` scripts SHALL be deterministic: given the same `peer-review-{artifact}.md` input file, they SHALL always produce the same exit code and the same `--json` output. | ATP-NF-002-A | Same input produces same exit code on repeated runs | SCN-NF-002-A1 | ⬜ Untested |
| | | ATP-NF-002-B | Same input produces same JSON output on repeated runs | SCN-NF-002-B1 | ⬜ Untested |

### Matrix A Coverage

| Metric | Value |
|--------|-------|
| **Total Requirements** | 37 |
| **Total Test Cases (ATP)** | 74 |
| **Total Scenarios (SCN)** | 80 |
| **REQ → ATP Coverage** | 37/37 (100%) |
| **ATP → SCN Coverage** | 74/74 (100%) |

## Matrix B — Verification (Architectural View)

| Requirement ID | System Component (SYS) | Component Name | Test Case ID (STP) | Technique | Scenario ID (STS) | Status |
|----------------|------------------------|----------------|--------------------|-----------|--------------------|--------|
| **REQ-001** | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-B | Interface Contract Testing | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-B | Interface Contract Testing | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-B | Interface Contract Testing | STS-001-B3 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-C | Equivalence Partitioning | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-C | Equivalence Partitioning | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-E | Fault Injection | STS-001-E1 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-E | Fault Injection | STS-001-E2 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-A | Interface Contract Testing | STS-004-A3 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-B | Boundary Value Analysis | STS-004-B1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-B | Boundary Value Analysis | STS-004-B2 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-C | Equivalence Partitioning | STS-004-C1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-C | Equivalence Partitioning | STS-004-C2 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-C | Equivalence Partitioning | STS-004-C3 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-D | Fault Injection | STS-004-D1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-D | Fault Injection | STS-004-D2 | ⬜ Untested |
| **REQ-002** | SYS-002 | AI Review Criteria Engine | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B4 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B5 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-C | Boundary Value Analysis | STS-002-C2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| **REQ-003** | SYS-002 | AI Review Criteria Engine | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B4 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B5 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-C | Boundary Value Analysis | STS-002-C2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| **REQ-004** | SYS-002 | AI Review Criteria Engine | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B4 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B5 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-C | Boundary Value Analysis | STS-002-C2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| **REQ-005** | SYS-002 | AI Review Criteria Engine | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B4 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B5 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-C | Boundary Value Analysis | STS-002-C2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| **REQ-006** | SYS-002 | AI Review Criteria Engine | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B4 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B5 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-C | Boundary Value Analysis | STS-002-C2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| **REQ-007** | SYS-002 | AI Review Criteria Engine | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B4 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B5 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-C | Boundary Value Analysis | STS-002-C2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| **REQ-008** | SYS-002 | AI Review Criteria Engine | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B4 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B5 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-C | Boundary Value Analysis | STS-002-C2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| **REQ-009** | SYS-002 | AI Review Criteria Engine | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B4 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B5 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-C | Boundary Value Analysis | STS-002-C2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| **REQ-010** | SYS-002 | AI Review Criteria Engine | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B4 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B5 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-C | Boundary Value Analysis | STS-002-C2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| **REQ-011** | SYS-002 | AI Review Criteria Engine | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B4 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-B | Equivalence Partitioning | STS-002-B5 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-C | Boundary Value Analysis | STS-002-C2 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | AI Review Criteria Engine | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| **REQ-012** | SYS-003 | Finding Identifier & Severity Classifier | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B4 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C3 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C4 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-D | Fault Injection | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-D | Fault Injection | STS-003-D2 | ⬜ Untested |
| **REQ-013** | SYS-003 | Finding Identifier & Severity Classifier | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B4 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C3 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C4 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-D | Fault Injection | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-D | Fault Injection | STS-003-D2 | ⬜ Untested |
| **REQ-014** | SYS-003 | Finding Identifier & Severity Classifier | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B4 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C3 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C4 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-D | Fault Injection | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-D | Fault Injection | STS-003-D2 | ⬜ Untested |
| **REQ-015** | SYS-003 | Finding Identifier & Severity Classifier | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B4 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C3 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C4 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-D | Fault Injection | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-D | Fault Injection | STS-003-D2 | ⬜ Untested |
| **REQ-016** | SYS-003 | Finding Identifier & Severity Classifier | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B4 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C3 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C4 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-D | Fault Injection | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-D | Fault Injection | STS-003-D2 | ⬜ Untested |
| **REQ-017** | SYS-003 | Finding Identifier & Severity Classifier | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B4 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C3 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C4 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-D | Fault Injection | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-D | Fault Injection | STS-003-D2 | ⬜ Untested |
| **REQ-018** | SYS-004 | Review Report Formatter | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-A | Interface Contract Testing | STS-004-A3 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-B | Boundary Value Analysis | STS-004-B1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-B | Boundary Value Analysis | STS-004-B2 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-C | Equivalence Partitioning | STS-004-C1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-C | Equivalence Partitioning | STS-004-C2 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-C | Equivalence Partitioning | STS-004-C3 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-D | Fault Injection | STS-004-D1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-D | Fault Injection | STS-004-D2 | ⬜ Untested |
| **REQ-019** | SYS-004 | Review Report Formatter | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-A | Interface Contract Testing | STS-004-A3 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-B | Boundary Value Analysis | STS-004-B1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-B | Boundary Value Analysis | STS-004-B2 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-C | Equivalence Partitioning | STS-004-C1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-C | Equivalence Partitioning | STS-004-C2 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-C | Equivalence Partitioning | STS-004-C3 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-D | Fault Injection | STS-004-D1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-D | Fault Injection | STS-004-D2 | ⬜ Untested |
| **REQ-020** | SYS-004 | Review Report Formatter | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-A | Interface Contract Testing | STS-004-A3 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-B | Boundary Value Analysis | STS-004-B1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-B | Boundary Value Analysis | STS-004-B2 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-C | Equivalence Partitioning | STS-004-C1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-C | Equivalence Partitioning | STS-004-C2 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-C | Equivalence Partitioning | STS-004-C3 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-D | Fault Injection | STS-004-D1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-D | Fault Injection | STS-004-D2 | ⬜ Untested |
| **REQ-021** | SYS-004 | Review Report Formatter | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-A | Interface Contract Testing | STS-004-A3 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-B | Boundary Value Analysis | STS-004-B1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-B | Boundary Value Analysis | STS-004-B2 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-C | Equivalence Partitioning | STS-004-C1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-C | Equivalence Partitioning | STS-004-C2 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-C | Equivalence Partitioning | STS-004-C3 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-D | Fault Injection | STS-004-D1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-D | Fault Injection | STS-004-D2 | ⬜ Untested |
| **REQ-022** | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A3 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A4 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B3 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B4 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B5 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-C | Boundary Value Analysis | STS-005-C1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-C | Boundary Value Analysis | STS-005-C2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-C | Boundary Value Analysis | STS-005-C3 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-D | Fault Injection | STS-005-D1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-D | Fault Injection | STS-005-D2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-D | Fault Injection | STS-005-D3 | ⬜ Untested |
| **REQ-023** | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A3 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A4 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B3 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B4 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B5 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-C | Boundary Value Analysis | STS-005-C1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-C | Boundary Value Analysis | STS-005-C2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-C | Boundary Value Analysis | STS-005-C3 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-D | Fault Injection | STS-005-D1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-D | Fault Injection | STS-005-D2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-D | Fault Injection | STS-005-D3 | ⬜ Untested |
| **REQ-024** | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A3 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A4 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B3 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B4 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B5 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-C | Boundary Value Analysis | STS-005-C1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-C | Boundary Value Analysis | STS-005-C2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-C | Boundary Value Analysis | STS-005-C3 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-D | Fault Injection | STS-005-D1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-D | Fault Injection | STS-005-D2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-D | Fault Injection | STS-005-D3 | ⬜ Untested |
| **REQ-025** | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A3 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A4 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B3 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B4 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B5 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-C | Boundary Value Analysis | STS-005-C1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-C | Boundary Value Analysis | STS-005-C2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-C | Boundary Value Analysis | STS-005-C3 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-D | Fault Injection | STS-005-D1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-D | Fault Injection | STS-005-D2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-D | Fault Injection | STS-005-D3 | ⬜ Untested |
| **REQ-026** | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A3 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A4 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B3 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B4 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B5 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-C | Boundary Value Analysis | STS-005-C1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-C | Boundary Value Analysis | STS-005-C2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-C | Boundary Value Analysis | STS-005-C3 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-D | Fault Injection | STS-005-D1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-D | Fault Injection | STS-005-D2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-D | Fault Injection | STS-005-D3 | ⬜ Untested |
| **REQ-027** | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A3 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A4 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B3 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B4 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B5 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-C | Boundary Value Analysis | STS-005-C1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-C | Boundary Value Analysis | STS-005-C2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-C | Boundary Value Analysis | STS-005-C3 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-D | Fault Injection | STS-005-D1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-D | Fault Injection | STS-005-D2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-D | Fault Injection | STS-005-D3 | ⬜ Untested |
| **REQ-028** | SYS-006 | PowerShell CI Check Script | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-A | Interface Contract Testing | STS-006-A3 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-B | Equivalence Partitioning | STS-006-B2 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-B | Equivalence Partitioning | STS-006-B3 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-C | Boundary Value Analysis | STS-006-C1 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-C | Boundary Value Analysis | STS-006-C2 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-D | Fault Injection | STS-006-D1 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-D | Fault Injection | STS-006-D2 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-D | Fault Injection | STS-006-D3 | ⬜ Untested |
| **REQ-029** | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-B | Interface Contract Testing | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-B | Interface Contract Testing | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-B | Interface Contract Testing | STS-001-B3 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-C | Equivalence Partitioning | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-C | Equivalence Partitioning | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-E | Fault Injection | STS-001-E1 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-E | Fault Injection | STS-001-E2 | ⬜ Untested |
| **REQ-CN-001** | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-B | Interface Contract Testing | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-B | Interface Contract Testing | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-B | Interface Contract Testing | STS-001-B3 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-C | Equivalence Partitioning | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-C | Equivalence Partitioning | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-E | Fault Injection | STS-001-E1 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-E | Fault Injection | STS-001-E2 | ⬜ Untested |
| **REQ-CN-002** | SYS-003 | Finding Identifier & Severity Classifier | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-B | Equivalence Partitioning | STS-003-B4 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C3 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-C | Boundary Value Analysis | STS-003-C4 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-D | Fault Injection | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Finding Identifier & Severity Classifier | STP-003-D | Fault Injection | STS-003-D2 | ⬜ Untested |
| **REQ-CN-003** | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-B | Interface Contract Testing | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-B | Interface Contract Testing | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-B | Interface Contract Testing | STS-001-B3 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-C | Equivalence Partitioning | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-C | Equivalence Partitioning | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-E | Fault Injection | STS-001-E1 | ⬜ Untested |
| | SYS-001 | Artifact Reader & Type Dispatcher | STP-001-E | Fault Injection | STS-001-E2 | ⬜ Untested |
| **REQ-CN-004** | SYS-004 | Review Report Formatter | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-A | Interface Contract Testing | STS-004-A3 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-B | Boundary Value Analysis | STS-004-B1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-B | Boundary Value Analysis | STS-004-B2 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-C | Equivalence Partitioning | STS-004-C1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-C | Equivalence Partitioning | STS-004-C2 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-C | Equivalence Partitioning | STS-004-C3 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-D | Fault Injection | STS-004-D1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-D | Fault Injection | STS-004-D2 | ⬜ Untested |
| **REQ-IF-001** | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A3 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A4 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B3 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B4 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B5 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-C | Boundary Value Analysis | STS-005-C1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-C | Boundary Value Analysis | STS-005-C2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-C | Boundary Value Analysis | STS-005-C3 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-D | Fault Injection | STS-005-D1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-D | Fault Injection | STS-005-D2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-D | Fault Injection | STS-005-D3 | ⬜ Untested |
| **REQ-IF-002** | SYS-006 | PowerShell CI Check Script | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-A | Interface Contract Testing | STS-006-A3 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-B | Equivalence Partitioning | STS-006-B2 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-B | Equivalence Partitioning | STS-006-B3 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-C | Boundary Value Analysis | STS-006-C1 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-C | Boundary Value Analysis | STS-006-C2 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-D | Fault Injection | STS-006-D1 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-D | Fault Injection | STS-006-D2 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-D | Fault Injection | STS-006-D3 | ⬜ Untested |
| **REQ-NF-001** | SYS-004 | Review Report Formatter | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-A | Interface Contract Testing | STS-004-A3 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-B | Boundary Value Analysis | STS-004-B1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-B | Boundary Value Analysis | STS-004-B2 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-C | Equivalence Partitioning | STS-004-C1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-C | Equivalence Partitioning | STS-004-C2 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-C | Equivalence Partitioning | STS-004-C3 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-D | Fault Injection | STS-004-D1 | ⬜ Untested |
| | SYS-004 | Review Report Formatter | STP-004-D | Fault Injection | STS-004-D2 | ⬜ Untested |
| **REQ-NF-002** | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A3 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-A | Interface Contract Testing | STS-005-A4 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B3 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B4 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-B | Equivalence Partitioning | STS-005-B5 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-C | Boundary Value Analysis | STS-005-C1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-C | Boundary Value Analysis | STS-005-C2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-C | Boundary Value Analysis | STS-005-C3 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-D | Fault Injection | STS-005-D1 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-D | Fault Injection | STS-005-D2 | ⬜ Untested |
| | SYS-005 | Bash CI Check Script | STP-005-D | Fault Injection | STS-005-D3 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-A | Interface Contract Testing | STS-006-A3 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-B | Equivalence Partitioning | STS-006-B2 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-B | Equivalence Partitioning | STS-006-B3 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-C | Boundary Value Analysis | STS-006-C1 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-C | Boundary Value Analysis | STS-006-C2 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-D | Fault Injection | STS-006-D1 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-D | Fault Injection | STS-006-D2 | ⬜ Untested |
| | SYS-006 | PowerShell CI Check Script | STP-006-D | Fault Injection | STS-006-D3 | ⬜ Untested |

### Matrix B Coverage

| Metric | Value |
|--------|-------|
| **Total System Components (SYS)** | 6 |
| **Total System Test Cases (STP)** | 25 |
| **Total System Scenarios (STS)** | 71 |
| **REQ → SYS Coverage** | 37/37 (100%) |
| **SYS → STP Coverage** | 6/6 (100%) |

## Matrix C — Integration Verification (Module Boundary View)

| System Component (SYS) | Parent REQs | Architecture Module (ARCH) | Module Name | Test Case ID (ITP) | Technique | Scenario ID (ITS) | Status |
|------------------------|-------------|---------------------------|-------------|--------------------|-----------|--------------------|--------|
| SYS-001 (REQ-001, REQ-029, REQ-CN-001, REQ-CN-003) | REQ-001, REQ-029, REQ-CN-001, REQ-CN-003 | ARCH-001 | Artifact File Reader | ITP-001-A | Consumer-Driven Contract Testing (CDCT) | ITS-001-A1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-029, REQ-CN-001, REQ-CN-003) | REQ-001, REQ-029, REQ-CN-001, REQ-CN-003 | ARCH-001 | Artifact File Reader | ITP-001-A | Consumer-Driven Contract Testing (CDCT) | ITS-001-A2 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-029, REQ-CN-001, REQ-CN-003) | REQ-001, REQ-029, REQ-CN-001, REQ-CN-003 | ARCH-001 | Artifact File Reader | ITP-001-B | Interface Fault Injection | ITS-001-B1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-029, REQ-CN-001, REQ-CN-003) | REQ-001, REQ-029, REQ-CN-001, REQ-CN-003 | ARCH-001 | Artifact File Reader | ITP-001-B | Interface Fault Injection | ITS-001-B2 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-029, REQ-CN-001, REQ-CN-003) | REQ-001, REQ-029, REQ-CN-001, REQ-CN-003 | ARCH-001 | Artifact File Reader | ITP-001-C | Data Flow Testing | ITS-001-C1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-029, REQ-CN-001, REQ-CN-003) | REQ-001, REQ-029, REQ-CN-001, REQ-CN-003 | ARCH-002 | Artifact Type Resolver | ITP-002-A | Consumer-Driven Contract Testing (CDCT) | ITS-002-A1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-029, REQ-CN-001, REQ-CN-003) | REQ-001, REQ-029, REQ-CN-001, REQ-CN-003 | ARCH-002 | Artifact Type Resolver | ITP-002-A | Consumer-Driven Contract Testing (CDCT) | ITS-002-A2 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-029, REQ-CN-001, REQ-CN-003) | REQ-001, REQ-029, REQ-CN-001, REQ-CN-003 | ARCH-002 | Artifact Type Resolver | ITP-002-B | Interface Fault Injection | ITS-002-B1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-029, REQ-CN-001, REQ-CN-003) | REQ-001, REQ-029, REQ-CN-001, REQ-CN-003 | ARCH-002 | Artifact Type Resolver | ITP-002-B | Interface Fault Injection | ITS-002-B2 | ⬜ Untested |
| SYS-002 (REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011) | REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011 | ARCH-003 | Review Criteria Registry | ITP-003-A | Interface Contract Testing | ITS-003-A1 | ⬜ Untested |
| SYS-002 (REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011) | REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011 | ARCH-003 | Review Criteria Registry | ITP-003-A | Interface Contract Testing | ITS-003-A2 | ⬜ Untested |
| SYS-002 (REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011) | REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011 | ARCH-003 | Review Criteria Registry | ITP-003-B | Interface Fault Injection | ITS-003-B1 | ⬜ Untested |
| SYS-002 (REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011) | REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011 | ARCH-004 | LLM Evaluation Coordinator | ITP-004-A | Consumer-Driven Contract Testing (CDCT) | ITS-004-A1 | ⬜ Untested |
| SYS-002 (REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011) | REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011 | ARCH-004 | LLM Evaluation Coordinator | ITP-004-A | Consumer-Driven Contract Testing (CDCT) | ITS-004-A2 | ⬜ Untested |
| SYS-002 (REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011) | REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011 | ARCH-004 | LLM Evaluation Coordinator | ITP-004-B | Interface Fault Injection | ITS-004-B1 | ⬜ Untested |
| SYS-002 (REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011) | REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011 | ARCH-004 | LLM Evaluation Coordinator | ITP-004-B | Interface Fault Injection | ITS-004-B2 | ⬜ Untested |
| SYS-002 (REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011) | REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011 | ARCH-004 | LLM Evaluation Coordinator | ITP-004-C | Data Flow Testing | ITS-004-C1 | ⬜ Untested |
| SYS-003 (REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-017, REQ-CN-002) | REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-017, REQ-CN-002 | ARCH-005 | PRF ID Generator | ITP-005-A | Consumer-Driven Contract Testing (CDCT) | ITS-005-A1 | ⬜ Untested |
| SYS-003 (REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-017, REQ-CN-002) | REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-017, REQ-CN-002 | ARCH-005 | PRF ID Generator | ITP-005-A | Consumer-Driven Contract Testing (CDCT) | ITS-005-A2 | ⬜ Untested |
| SYS-003 (REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-017, REQ-CN-002) | REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-017, REQ-CN-002 | ARCH-005 | PRF ID Generator | ITP-005-B | Interface Fault Injection | ITS-005-B1 | ⬜ Untested |
| SYS-003 (REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-017, REQ-CN-002) | REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-017, REQ-CN-002 | ARCH-006 | Severity Classifier | ITP-006-A | Interface Contract Testing | ITS-006-A1 | ⬜ Untested |
| SYS-003 (REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-017, REQ-CN-002) | REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-017, REQ-CN-002 | ARCH-006 | Severity Classifier | ITP-006-A | Interface Contract Testing | ITS-006-A2 | ⬜ Untested |
| SYS-003 (REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-017, REQ-CN-002) | REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-017, REQ-CN-002 | ARCH-006 | Severity Classifier | ITP-006-B | Data Flow Testing | ITS-006-B1 | ⬜ Untested |
| SYS-003 (REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-017, REQ-CN-002) | REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-017, REQ-CN-002 | ARCH-006 | Severity Classifier | ITP-006-C | Interface Fault Injection | ITS-006-C1 | ⬜ Untested |
| SYS-004 (REQ-001, REQ-018, REQ-019, REQ-020, REQ-021, REQ-NF-001, REQ-CN-004) | REQ-001, REQ-018, REQ-019, REQ-020, REQ-021, REQ-NF-001, REQ-CN-004 | ARCH-007 | Report Header Builder | ITP-007-A | Interface Contract Testing | ITS-007-A1 | ⬜ Untested |
| SYS-004 (REQ-001, REQ-018, REQ-019, REQ-020, REQ-021, REQ-NF-001, REQ-CN-004) | REQ-001, REQ-018, REQ-019, REQ-020, REQ-021, REQ-NF-001, REQ-CN-004 | ARCH-007 | Report Header Builder | ITP-007-A | Interface Contract Testing | ITS-007-A2 | ⬜ Untested |
| SYS-004 (REQ-001, REQ-018, REQ-019, REQ-020, REQ-021, REQ-NF-001, REQ-CN-004) | REQ-001, REQ-018, REQ-019, REQ-020, REQ-021, REQ-NF-001, REQ-CN-004 | ARCH-007 | Report Header Builder | ITP-007-B | Interface Fault Injection | ITS-007-B1 | ⬜ Untested |
| SYS-004 (REQ-001, REQ-018, REQ-019, REQ-020, REQ-021, REQ-NF-001, REQ-CN-004) | REQ-001, REQ-018, REQ-019, REQ-020, REQ-021, REQ-NF-001, REQ-CN-004 | ARCH-007 | Report Header Builder | ITP-007-B | Interface Fault Injection | ITS-007-B2 | ⬜ Untested |
| SYS-004 (REQ-001, REQ-018, REQ-019, REQ-020, REQ-021, REQ-NF-001, REQ-CN-004) | REQ-001, REQ-018, REQ-019, REQ-020, REQ-021, REQ-NF-001, REQ-CN-004 | ARCH-008 | Report Markdown Renderer | ITP-008-A | Data Flow Testing | ITS-008-A1 | ⬜ Untested |
| SYS-004 (REQ-001, REQ-018, REQ-019, REQ-020, REQ-021, REQ-NF-001, REQ-CN-004) | REQ-001, REQ-018, REQ-019, REQ-020, REQ-021, REQ-NF-001, REQ-CN-004 | ARCH-008 | Report Markdown Renderer | ITP-008-A | Data Flow Testing | ITS-008-A2 | ⬜ Untested |
| SYS-004 (REQ-001, REQ-018, REQ-019, REQ-020, REQ-021, REQ-NF-001, REQ-CN-004) | REQ-001, REQ-018, REQ-019, REQ-020, REQ-021, REQ-NF-001, REQ-CN-004 | ARCH-008 | Report Markdown Renderer | ITP-008-B | Interface Contract Testing | ITS-008-B1 | ⬜ Untested |
| SYS-004 (REQ-001, REQ-018, REQ-019, REQ-020, REQ-021, REQ-NF-001, REQ-CN-004) | REQ-001, REQ-018, REQ-019, REQ-020, REQ-021, REQ-NF-001, REQ-CN-004 | ARCH-008 | Report Markdown Renderer | ITP-008-B | Interface Contract Testing | ITS-008-B2 | ⬜ Untested |
| SYS-004 (REQ-001, REQ-018, REQ-019, REQ-020, REQ-021, REQ-NF-001, REQ-CN-004) | REQ-001, REQ-018, REQ-019, REQ-020, REQ-021, REQ-NF-001, REQ-CN-004 | ARCH-008 | Report Markdown Renderer | ITP-008-C | Interface Fault Injection | ITS-008-C1 | ⬜ Untested |
| SYS-005 (REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-002, REQ-IF-001) | REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-002, REQ-IF-001 | ARCH-009 | Bash Review Parser & Gate | ITP-009-A | Interface Contract Testing | ITS-009-A1 | ⬜ Untested |
| SYS-005 (REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-002, REQ-IF-001) | REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-002, REQ-IF-001 | ARCH-009 | Bash Review Parser & Gate | ITP-009-A | Interface Contract Testing | ITS-009-A2 | ⬜ Untested |
| SYS-005 (REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-002, REQ-IF-001) | REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-002, REQ-IF-001 | ARCH-009 | Bash Review Parser & Gate | ITP-009-A | Interface Contract Testing | ITS-009-A3 | ⬜ Untested |
| SYS-005 (REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-002, REQ-IF-001) | REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-002, REQ-IF-001 | ARCH-009 | Bash Review Parser & Gate | ITP-009-B | Consumer-Driven Contract Testing (CDCT) | ITS-009-B1 | ⬜ Untested |
| SYS-005 (REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-002, REQ-IF-001) | REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-002, REQ-IF-001 | ARCH-009 | Bash Review Parser & Gate | ITP-009-C | Interface Fault Injection | ITS-009-C1 | ⬜ Untested |
| SYS-005 (REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-002, REQ-IF-001) | REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-002, REQ-IF-001 | ARCH-009 | Bash Review Parser & Gate | ITP-009-C | Interface Fault Injection | ITS-009-C2 | ⬜ Untested |
| SYS-006 (REQ-028, REQ-IF-002, REQ-NF-002) | REQ-028, REQ-IF-002, REQ-NF-002 | ARCH-010 | PowerShell Review Parser & Gate | ITP-010-A | Interface Contract Testing | ITS-010-A1 | ⬜ Untested |
| SYS-006 (REQ-028, REQ-IF-002, REQ-NF-002) | REQ-028, REQ-IF-002, REQ-NF-002 | ARCH-010 | PowerShell Review Parser & Gate | ITP-010-A | Interface Contract Testing | ITS-010-A2 | ⬜ Untested |
| SYS-006 (REQ-028, REQ-IF-002, REQ-NF-002) | REQ-028, REQ-IF-002, REQ-NF-002 | ARCH-010 | PowerShell Review Parser & Gate | ITP-010-B | Interface Fault Injection | ITS-010-B1 | ⬜ Untested |
| SYS-006 (REQ-028, REQ-IF-002, REQ-NF-002) | REQ-028, REQ-IF-002, REQ-NF-002 | ARCH-010 | PowerShell Review Parser & Gate | ITP-010-B | Interface Fault Injection | ITS-010-B2 | ⬜ Untested |

### Matrix C Coverage

| Metric | Value |
|--------|-------|
| **Total Architecture Modules (ARCH)** | 10 |
| **Total Cross-Cutting Modules** | 0 |
| **Total Integration Test Cases (ITP)** | 25 |
| **Total Integration Scenarios (ITS)** | 43 |
| **SYS → ARCH Coverage** | 6/6 (100%) |
| **ARCH → ITP Coverage** | 10/10 (100%) |

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
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | read_artifact_file | UTP-001-A | Statement & Branch Coverage | UTS-001-A1 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | read_artifact_file | UTP-001-A | Statement & Branch Coverage | UTS-001-A2 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | read_artifact_file | UTP-001-A | Statement & Branch Coverage | UTS-001-A3 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | read_artifact_file | UTP-001-A | Statement & Branch Coverage | UTS-001-A4 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | read_artifact_file | UTP-001-A | Statement & Branch Coverage | UTS-001-A5 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | read_artifact_file | UTP-001-B | Boundary Value Analysis | UTS-001-B1 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | read_artifact_file | UTP-001-B | Boundary Value Analysis | UTS-001-B2 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | read_artifact_file | UTP-001-B | Boundary Value Analysis | UTS-001-B3 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | read_artifact_file | UTP-001-B | Boundary Value Analysis | UTS-001-B4 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | read_artifact_file | UTP-001-B | Boundary Value Analysis | UTS-001-B5 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | read_artifact_file | UTP-001-C | Strict Isolation | UTS-001-C1 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | read_artifact_file | UTP-001-C | Strict Isolation | UTS-001-C2 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-011 | orchestrate_peer_review | UTP-011-A | Statement & Branch Coverage | UTS-011-A1 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-011 | orchestrate_peer_review | UTP-011-A | Statement & Branch Coverage | UTS-011-A2 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-011 | orchestrate_peer_review | UTP-011-B | Strict Isolation | UTS-011-B1 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-011 | orchestrate_peer_review | UTP-011-B | Strict Isolation | UTS-011-B2 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-011 | orchestrate_peer_review | UTP-011-C | Boundary Value Analysis | UTS-011-C1 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-011 | orchestrate_peer_review | UTP-011-C | Boundary Value Analysis | UTS-011-C2 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | resolve_artifact_type | UTP-002-A | Statement & Branch Coverage | UTS-002-A1 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | resolve_artifact_type | UTP-002-A | Statement & Branch Coverage | UTS-002-A2 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | resolve_artifact_type | UTP-002-A | Statement & Branch Coverage | UTS-002-A3 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | resolve_artifact_type | UTP-002-A | Statement & Branch Coverage | UTS-002-A4 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | resolve_artifact_type | UTP-002-B | Equivalence Partitioning | UTS-002-B1 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | resolve_artifact_type | UTP-002-B | Equivalence Partitioning | UTS-002-B10 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | resolve_artifact_type | UTP-002-B | Equivalence Partitioning | UTS-002-B2 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | resolve_artifact_type | UTP-002-B | Equivalence Partitioning | UTS-002-B3 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | resolve_artifact_type | UTP-002-B | Equivalence Partitioning | UTS-002-B4 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | resolve_artifact_type | UTP-002-B | Equivalence Partitioning | UTS-002-B5 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | resolve_artifact_type | UTP-002-B | Equivalence Partitioning | UTS-002-B6 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | resolve_artifact_type | UTP-002-B | Equivalence Partitioning | UTS-002-B7 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | resolve_artifact_type | UTP-002-B | Equivalence Partitioning | UTS-002-B8 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | resolve_artifact_type | UTP-002-B | Equivalence Partitioning | UTS-002-B9 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | resolve_artifact_type | UTP-002-C | Boundary Value Analysis | UTS-002-C1 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | resolve_artifact_type | UTP-002-C | Boundary Value Analysis | UTS-002-C2 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | resolve_artifact_type | UTP-002-C | Boundary Value Analysis | UTS-002-C3 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | resolve_artifact_type | UTP-002-C | Boundary Value Analysis | UTS-002-C4 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-011 | orchestrate_peer_review | UTP-011-A | Statement & Branch Coverage | UTS-011-A1 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-011 | orchestrate_peer_review | UTP-011-A | Statement & Branch Coverage | UTS-011-A2 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-011 | orchestrate_peer_review | UTP-011-B | Strict Isolation | UTS-011-B1 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-011 | orchestrate_peer_review | UTP-011-B | Strict Isolation | UTS-011-B2 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-011 | orchestrate_peer_review | UTP-011-C | Boundary Value Analysis | UTS-011-C1 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-011 | orchestrate_peer_review | UTP-011-C | Boundary Value Analysis | UTS-011-C2 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | get_review_criteria | UTP-003-A | Statement & Branch Coverage | UTS-003-A1 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | get_review_criteria | UTP-003-A | Statement & Branch Coverage | UTS-003-A2 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | get_review_criteria | UTP-003-B | Equivalence Partitioning | UTS-003-B1 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | get_review_criteria | UTP-003-B | Equivalence Partitioning | UTS-003-B10 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | get_review_criteria | UTP-003-B | Equivalence Partitioning | UTS-003-B2 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | get_review_criteria | UTP-003-B | Equivalence Partitioning | UTS-003-B3 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | get_review_criteria | UTP-003-B | Equivalence Partitioning | UTS-003-B4 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | get_review_criteria | UTP-003-B | Equivalence Partitioning | UTS-003-B5 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | get_review_criteria | UTP-003-B | Equivalence Partitioning | UTS-003-B6 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | get_review_criteria | UTP-003-B | Equivalence Partitioning | UTS-003-B7 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | get_review_criteria | UTP-003-B | Equivalence Partitioning | UTS-003-B8 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | get_review_criteria | UTP-003-B | Equivalence Partitioning | UTS-003-B9 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | get_review_criteria | UTP-003-C | Boundary Value Analysis | UTS-003-C1 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | get_review_criteria | UTP-003-C | Boundary Value Analysis | UTS-003-C2 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | get_review_criteria | UTP-003-C | Boundary Value Analysis | UTS-003-C3 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | get_review_criteria | UTP-003-C | Boundary Value Analysis | UTS-003-C4 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-011 | orchestrate_peer_review | UTP-011-A | Statement & Branch Coverage | UTS-011-A1 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-011 | orchestrate_peer_review | UTP-011-A | Statement & Branch Coverage | UTS-011-A2 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-011 | orchestrate_peer_review | UTP-011-B | Strict Isolation | UTS-011-B1 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-011 | orchestrate_peer_review | UTP-011-B | Strict Isolation | UTS-011-B2 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-011 | orchestrate_peer_review | UTP-011-C | Boundary Value Analysis | UTS-011-C1 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-011 | orchestrate_peer_review | UTP-011-C | Boundary Value Analysis | UTS-011-C2 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-004 | evaluate_artifact | UTP-004-A | Statement & Branch Coverage | UTS-004-A1 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-004 | evaluate_artifact | UTP-004-A | Statement & Branch Coverage | UTS-004-A2 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-004 | evaluate_artifact | UTP-004-A | Statement & Branch Coverage | UTS-004-A3 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-004 | evaluate_artifact | UTP-004-A | Statement & Branch Coverage | UTS-004-A4 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-004 | evaluate_artifact | UTP-004-A | Statement & Branch Coverage | UTS-004-A5 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-004 | evaluate_artifact | UTP-004-A | Statement & Branch Coverage | UTS-004-A6 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-004 | evaluate_artifact | UTP-004-A | Statement & Branch Coverage | UTS-004-A7 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-004 | evaluate_artifact | UTP-004-B | Boundary Value Analysis | UTS-004-B1 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-004 | evaluate_artifact | UTP-004-B | Boundary Value Analysis | UTS-004-B2 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-004 | evaluate_artifact | UTP-004-B | Boundary Value Analysis | UTS-004-B3 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-004 | evaluate_artifact | UTP-004-B | Boundary Value Analysis | UTS-004-B4 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-004 | evaluate_artifact | UTP-004-C | Strict Isolation | UTS-004-C1 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-004 | evaluate_artifact | UTP-004-C | Strict Isolation | UTS-004-C2 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-011 | orchestrate_peer_review | UTP-011-A | Statement & Branch Coverage | UTS-011-A1 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-011 | orchestrate_peer_review | UTP-011-A | Statement & Branch Coverage | UTS-011-A2 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-011 | orchestrate_peer_review | UTP-011-B | Strict Isolation | UTS-011-B1 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-011 | orchestrate_peer_review | UTP-011-B | Strict Isolation | UTS-011-B2 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-011 | orchestrate_peer_review | UTP-011-C | Boundary Value Analysis | UTS-011-C1 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-011 | orchestrate_peer_review | UTP-011-C | Boundary Value Analysis | UTS-011-C2 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-005 | assign_prf_ids | UTP-005-A | Statement & Branch Coverage | UTS-005-A1 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-005 | assign_prf_ids | UTP-005-A | Statement & Branch Coverage | UTS-005-A2 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-005 | assign_prf_ids | UTP-005-A | Statement & Branch Coverage | UTS-005-A3 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-005 | assign_prf_ids | UTP-005-A | Statement & Branch Coverage | UTS-005-A4 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-005 | assign_prf_ids | UTP-005-B | Equivalence Partitioning | UTS-005-B1 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-005 | assign_prf_ids | UTP-005-B | Equivalence Partitioning | UTS-005-B2 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-005 | assign_prf_ids | UTP-005-B | Equivalence Partitioning | UTS-005-B3 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-005 | assign_prf_ids | UTP-005-B | Equivalence Partitioning | UTS-005-B4 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-005 | assign_prf_ids | UTP-005-C | Boundary Value Analysis | UTS-005-C1 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-005 | assign_prf_ids | UTP-005-C | Boundary Value Analysis | UTS-005-C2 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-005 | assign_prf_ids | UTP-005-C | Boundary Value Analysis | UTS-005-C3 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-005 | assign_prf_ids | UTP-005-C | Boundary Value Analysis | UTS-005-C4 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-011 | orchestrate_peer_review | UTP-011-A | Statement & Branch Coverage | UTS-011-A1 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-011 | orchestrate_peer_review | UTP-011-A | Statement & Branch Coverage | UTS-011-A2 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-011 | orchestrate_peer_review | UTP-011-B | Strict Isolation | UTS-011-B1 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-011 | orchestrate_peer_review | UTP-011-B | Strict Isolation | UTS-011-B2 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-011 | orchestrate_peer_review | UTP-011-C | Boundary Value Analysis | UTS-011-C1 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-011 | orchestrate_peer_review | UTP-011-C | Boundary Value Analysis | UTS-011-C2 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-006 | classify_severity | UTP-006-A | Statement & Branch Coverage | UTS-006-A1 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-006 | classify_severity | UTP-006-A | Statement & Branch Coverage | UTS-006-A2 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-006 | classify_severity | UTP-006-A | Statement & Branch Coverage | UTS-006-A3 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-006 | classify_severity | UTP-006-A | Statement & Branch Coverage | UTS-006-A4 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-006 | classify_severity | UTP-006-B | Equivalence Partitioning | UTS-006-B1 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-006 | classify_severity | UTP-006-B | Equivalence Partitioning | UTS-006-B2 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-006 | classify_severity | UTP-006-B | Equivalence Partitioning | UTS-006-B3 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-006 | classify_severity | UTP-006-B | Equivalence Partitioning | UTS-006-B4 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-006 | classify_severity | UTP-006-B | Equivalence Partitioning | UTS-006-B5 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-006 | classify_severity | UTP-006-C | Strict Isolation | UTS-006-C1 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-006 | classify_severity | UTP-006-C | Strict Isolation | UTS-006-C2 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-011 | orchestrate_peer_review | UTP-011-A | Statement & Branch Coverage | UTS-011-A1 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-011 | orchestrate_peer_review | UTP-011-A | Statement & Branch Coverage | UTS-011-A2 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-011 | orchestrate_peer_review | UTP-011-B | Strict Isolation | UTS-011-B1 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-011 | orchestrate_peer_review | UTP-011-B | Strict Isolation | UTS-011-B2 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-011 | orchestrate_peer_review | UTP-011-C | Boundary Value Analysis | UTS-011-C1 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-011 | orchestrate_peer_review | UTP-011-C | Boundary Value Analysis | UTS-011-C2 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-007 | build_report_header | UTP-007-A | Statement & Branch Coverage | UTS-007-A1 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-007 | build_report_header | UTP-007-A | Statement & Branch Coverage | UTS-007-A2 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-007 | build_report_header | UTP-007-A | Statement & Branch Coverage | UTS-007-A3 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-007 | build_report_header | UTP-007-A | Statement & Branch Coverage | UTS-007-A4 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-007 | build_report_header | UTP-007-A | Statement & Branch Coverage | UTS-007-A5 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-007 | build_report_header | UTP-007-B | Boundary Value Analysis | UTS-007-B1 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-007 | build_report_header | UTP-007-B | Boundary Value Analysis | UTS-007-B2 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-007 | build_report_header | UTP-007-B | Boundary Value Analysis | UTS-007-B3 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-007 | build_report_header | UTP-007-B | Boundary Value Analysis | UTS-007-B4 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-007 | build_report_header | UTP-007-C | Strict Isolation | UTS-007-C1 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-007 | build_report_header | UTP-007-C | Strict Isolation | UTS-007-C2 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-011 | orchestrate_peer_review | UTP-011-A | Statement & Branch Coverage | UTS-011-A1 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-011 | orchestrate_peer_review | UTP-011-A | Statement & Branch Coverage | UTS-011-A2 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-011 | orchestrate_peer_review | UTP-011-B | Strict Isolation | UTS-011-B1 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-011 | orchestrate_peer_review | UTP-011-B | Strict Isolation | UTS-011-B2 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-011 | orchestrate_peer_review | UTP-011-C | Boundary Value Analysis | UTS-011-C1 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-011 | orchestrate_peer_review | UTP-011-C | Boundary Value Analysis | UTS-011-C2 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-008 | render_summary_table | UTP-008-A | Statement & Branch Coverage | UTS-008-A1 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-008 | render_summary_table | UTP-008-A | Statement & Branch Coverage | UTS-008-A2 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-008 | render_summary_table | UTP-008-A | Statement & Branch Coverage | UTS-008-A3 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-008 | render_summary_table | UTP-008-B | Boundary Value Analysis | UTS-008-B1 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-008 | render_summary_table | UTP-008-B | Boundary Value Analysis | UTS-008-B2 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-008 | render_summary_table | UTP-008-B | Boundary Value Analysis | UTS-008-B3 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-008 | render_summary_table | UTP-008-C | Equivalence Partitioning | UTS-008-C1 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-008 | render_summary_table | UTP-008-C | Equivalence Partitioning | UTS-008-C2 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-008 | render_summary_table | UTP-008-C | Equivalence Partitioning | UTS-008-C3 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-008 | render_summary_table | UTP-008-C | Equivalence Partitioning | UTS-008-C4 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-009 | render_finding_subsections | UTP-009-A | Statement & Branch Coverage | UTS-009-A1 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-009 | render_finding_subsections | UTP-009-A | Statement & Branch Coverage | UTS-009-A2 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-009 | render_finding_subsections | UTP-009-A | Statement & Branch Coverage | UTS-009-A3 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-009 | render_finding_subsections | UTP-009-B | Boundary Value Analysis | UTS-009-B1 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-009 | render_finding_subsections | UTP-009-B | Boundary Value Analysis | UTS-009-B2 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-009 | render_finding_subsections | UTP-009-B | Boundary Value Analysis | UTS-009-B3 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-009 | render_finding_subsections | UTP-009-C | Equivalence Partitioning | UTS-009-C1 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-009 | render_finding_subsections | UTP-009-C | Equivalence Partitioning | UTS-009-C2 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-010 | write_review_report | UTP-010-A | Statement & Branch Coverage | UTS-010-A1 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-010 | write_review_report | UTP-010-A | Statement & Branch Coverage | UTS-010-A2 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-010 | write_review_report | UTP-010-A | Statement & Branch Coverage | UTS-010-A3 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-010 | write_review_report | UTP-010-B | Strict Isolation | UTS-010-B1 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-010 | write_review_report | UTP-010-B | Strict Isolation | UTS-010-B2 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-010 | write_review_report | UTP-010-C | Boundary Value Analysis | UTS-010-C1 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-010 | write_review_report | UTP-010-C | Boundary Value Analysis | UTS-010-C2 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-011 | orchestrate_peer_review | UTP-011-A | Statement & Branch Coverage | UTS-011-A1 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-011 | orchestrate_peer_review | UTP-011-A | Statement & Branch Coverage | UTS-011-A2 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-011 | orchestrate_peer_review | UTP-011-B | Strict Isolation | UTS-011-B1 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-011 | orchestrate_peer_review | UTP-011-B | Strict Isolation | UTS-011-B2 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-011 | orchestrate_peer_review | UTP-011-C | Boundary Value Analysis | UTS-011-C1 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-011 | orchestrate_peer_review | UTP-011-C | Boundary Value Analysis | UTS-011-C2 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-012 | parse_check_args — Bash | UTP-012-A | Statement & Branch Coverage | UTS-012-A1 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-012 | parse_check_args — Bash | UTP-012-A | Statement & Branch Coverage | UTS-012-A2 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-012 | parse_check_args — Bash | UTP-012-A | Statement & Branch Coverage | UTS-012-A3 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-012 | parse_check_args — Bash | UTP-012-A | Statement & Branch Coverage | UTS-012-A4 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-012 | parse_check_args — Bash | UTP-012-A | Statement & Branch Coverage | UTS-012-A5 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-012 | parse_check_args — Bash | UTP-012-A | Statement & Branch Coverage | UTS-012-A6 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-012 | parse_check_args — Bash | UTP-012-B | Equivalence Partitioning | UTS-012-B1 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-012 | parse_check_args — Bash | UTP-012-B | Equivalence Partitioning | UTS-012-B2 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-012 | parse_check_args — Bash | UTP-012-B | Equivalence Partitioning | UTS-012-B3 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-012 | parse_check_args — Bash | UTP-012-C | Strict Isolation | UTS-012-C1 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-012 | parse_check_args — Bash | UTP-012-C | Strict Isolation | UTS-012-C2 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-013 | parse_severity_counts — Bash | UTP-013-A | Statement & Branch Coverage | UTS-013-A1 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-013 | parse_severity_counts — Bash | UTP-013-A | Statement & Branch Coverage | UTS-013-A2 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-013 | parse_severity_counts — Bash | UTP-013-A | Statement & Branch Coverage | UTS-013-A3 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-013 | parse_severity_counts — Bash | UTP-013-A | Statement & Branch Coverage | UTS-013-A4 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-013 | parse_severity_counts — Bash | UTP-013-B | Boundary Value Analysis | UTS-013-B1 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-013 | parse_severity_counts — Bash | UTP-013-B | Boundary Value Analysis | UTS-013-B2 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-013 | parse_severity_counts — Bash | UTP-013-B | Boundary Value Analysis | UTS-013-B3 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-013 | parse_severity_counts — Bash | UTP-013-B | Boundary Value Analysis | UTS-013-B4 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-013 | parse_severity_counts — Bash | UTP-013-C | Strict Isolation | UTS-013-C1 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-014 | determine_exit_code — Bash | UTP-014-A | Statement & Branch Coverage | UTS-014-A1 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-014 | determine_exit_code — Bash | UTP-014-A | Statement & Branch Coverage | UTS-014-A2 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-014 | determine_exit_code — Bash | UTP-014-A | Statement & Branch Coverage | UTS-014-A3 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-014 | determine_exit_code — Bash | UTP-014-A | Statement & Branch Coverage | UTS-014-A4 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-014 | determine_exit_code — Bash | UTP-014-A | Statement & Branch Coverage | UTS-014-A5 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-014 | determine_exit_code — Bash | UTP-014-A | Statement & Branch Coverage | UTS-014-A6 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-014 | determine_exit_code — Bash | UTP-014-B | Equivalence Partitioning | UTS-014-B1 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-014 | determine_exit_code — Bash | UTP-014-B | Equivalence Partitioning | UTS-014-B2 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-014 | determine_exit_code — Bash | UTP-014-B | Equivalence Partitioning | UTS-014-B3 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-014 | determine_exit_code — Bash | UTP-014-B | Equivalence Partitioning | UTS-014-B4 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-014 | determine_exit_code — Bash | UTP-014-B | Equivalence Partitioning | UTS-014-B5 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-014 | determine_exit_code — Bash | UTP-014-C | Boundary Value Analysis | UTS-014-C1 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-014 | determine_exit_code — Bash | UTP-014-C | Boundary Value Analysis | UTS-014-C2 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-014 | determine_exit_code — Bash | UTP-014-C | Boundary Value Analysis | UTS-014-C3 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-014 | determine_exit_code — Bash | UTP-014-C | Boundary Value Analysis | UTS-014-C4 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-014 | determine_exit_code — Bash | UTP-014-C | Boundary Value Analysis | UTS-014-C5 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-015 | main — Bash CI Check | UTP-015-A | Statement & Branch Coverage | UTS-015-A1 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-015 | main — Bash CI Check | UTP-015-A | Statement & Branch Coverage | UTS-015-A2 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-015 | main — Bash CI Check | UTP-015-A | Statement & Branch Coverage | UTS-015-A3 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-015 | main — Bash CI Check | UTP-015-B | Strict Isolation | UTS-015-B1 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-015 | main — Bash CI Check | UTP-015-C | Equivalence Partitioning | UTS-015-C1 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-015 | main — Bash CI Check | UTP-015-C | Equivalence Partitioning | UTS-015-C2 | ⬜ Untested |
| ARCH-010 (SYS-006) | SYS-006 | MOD-016 | Invoke-PeerReviewCheck — PowerShell | UTP-016-A | Statement & Branch Coverage | UTS-016-A1 | ⬜ Untested |
| ARCH-010 (SYS-006) | SYS-006 | MOD-016 | Invoke-PeerReviewCheck — PowerShell | UTP-016-A | Statement & Branch Coverage | UTS-016-A2 | ⬜ Untested |
| ARCH-010 (SYS-006) | SYS-006 | MOD-016 | Invoke-PeerReviewCheck — PowerShell | UTP-016-A | Statement & Branch Coverage | UTS-016-A3 | ⬜ Untested |
| ARCH-010 (SYS-006) | SYS-006 | MOD-016 | Invoke-PeerReviewCheck — PowerShell | UTP-016-A | Statement & Branch Coverage | UTS-016-A4 | ⬜ Untested |
| ARCH-010 (SYS-006) | SYS-006 | MOD-016 | Invoke-PeerReviewCheck — PowerShell | UTP-016-A | Statement & Branch Coverage | UTS-016-A5 | ⬜ Untested |
| ARCH-010 (SYS-006) | SYS-006 | MOD-016 | Invoke-PeerReviewCheck — PowerShell | UTP-016-A | Statement & Branch Coverage | UTS-016-A6 | ⬜ Untested |
| ARCH-010 (SYS-006) | SYS-006 | MOD-016 | Invoke-PeerReviewCheck — PowerShell | UTP-016-B | Equivalence Partitioning | UTS-016-B1 | ⬜ Untested |
| ARCH-010 (SYS-006) | SYS-006 | MOD-016 | Invoke-PeerReviewCheck — PowerShell | UTP-016-B | Equivalence Partitioning | UTS-016-B2 | ⬜ Untested |
| ARCH-010 (SYS-006) | SYS-006 | MOD-016 | Invoke-PeerReviewCheck — PowerShell | UTP-016-B | Equivalence Partitioning | UTS-016-B3 | ⬜ Untested |
| ARCH-010 (SYS-006) | SYS-006 | MOD-016 | Invoke-PeerReviewCheck — PowerShell | UTP-016-B | Equivalence Partitioning | UTS-016-B4 | ⬜ Untested |
| ARCH-010 (SYS-006) | SYS-006 | MOD-016 | Invoke-PeerReviewCheck — PowerShell | UTP-016-C | Boundary Value Analysis | UTS-016-C1 | ⬜ Untested |
| ARCH-010 (SYS-006) | SYS-006 | MOD-016 | Invoke-PeerReviewCheck — PowerShell | UTP-016-C | Boundary Value Analysis | UTS-016-C2 | ⬜ Untested |
| ARCH-010 (SYS-006) | SYS-006 | MOD-016 | Invoke-PeerReviewCheck — PowerShell | UTP-016-C | Boundary Value Analysis | UTS-016-C3 | ⬜ Untested |
| ARCH-010 (SYS-006) | SYS-006 | MOD-016 | Invoke-PeerReviewCheck — PowerShell | UTP-016-C | Boundary Value Analysis | UTS-016-C4 | ⬜ Untested |

### Matrix D Coverage

| Metric | Value |
|--------|-------|
| **Total Module Designs (MOD)** | 16 |
| **External Modules** | 0 |
| **Testable Modules** | 16 |
| **Total Unit Test Cases (UTP)** | 48 |
| **Total Unit Scenarios (UTS)** | 180 |
| **ARCH → MOD Coverage** | 10/10 (100%) |
| **MOD → UTP Coverage** | 16/16 (100%) |

## Audit Notes

- **Matrix generated by**: `build-matrix.sh` (deterministic regex parser)
- **Source documents**: `requirements.md`, `acceptance-plan.md`, `system-design.md`, `system-test.md`, `architecture-design.md`, `integration-test.md`, `module-design.md`, `unit-test.md`
- **Last validated**: 2026-04-04
