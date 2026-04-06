# V-Model Requirements Specification: Peer Review

**Feature Branch**: `feature/005c-peer-review`
**Created**: 2025-07-18
**Status**: Approved
**Source**: `specs/005c-peer-review/spec.md`

## Overview

This document formalizes the requirements for adding a `/speckit.v-model.peer-review` command to the V-Model Extension Pack. The command acts as an AI-powered, stateless linter for any V-Model artifact. It reads a single artifact, evaluates it against standards-based review criteria specific to that artifact type, and produces a structured review report with findings identified by `PRF-{ARTIFACT}-NNN` IDs. Findings are classified by severity (Critical, Major, Minor, Observation) and are advisory-only — they do not participate in the V-Model traceability chain. A companion deterministic CI parser script (`peer-review-check.sh` / `peer-review-check.ps1`) reads the generated review and returns exit codes (0 = clean or observations only, 1 = Critical or Major findings detected, 2 = Minor findings only) to enable CI gating. The review file is regenerated on each invocation; `git diff` shows what changed between reviews. All requirements are atomized from the feature specification using the strict translator constraint.

## Requirements

### Functional Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-001 | The command SHALL read a single V-Model artifact file specified by the user and produce a peer review report as a markdown file named `peer-review-{artifact}.md` in the V-Model directory, where `{artifact}` matches the base name of the reviewed file (e.g., `peer-review-requirements.md` for `requirements.md`). | P1 | Core capability: the command must accept one artifact and produce a corresponding review file. | Test |
| REQ-002 | The command SHALL use AI (LLM) evaluation to assess prose quality, structural completeness, standards compliance, and cross-reference integrity of the input artifact. | P1 | The review requires natural language understanding to evaluate whether a requirement is testable or a severity classification is justified — this cannot be done by a deterministic script. | Test |
| REQ-003 | When reviewing `requirements.md`, the command SHALL evaluate each requirement against INCOSE quality attributes: atomic, testable, unambiguous, complete, free of subjective language, and priority assigned. | P1 | User Story 1 (P1): a systems engineer reviews requirements before design to catch quality issues early. | Test |
| REQ-004 | When reviewing `system-design.md`, the command SHALL evaluate against IEEE 1016 criteria: all 4 design views present, every SYS component traces to at least one REQ, interface contracts complete, and derived requirements flagged. | P1 | User Story 3 (P1): an architect reviews system design for IEEE 1016 compliance after initial design. | Test |
| REQ-005 | When reviewing `architecture-design.md`, the command SHALL evaluate against IEEE 42010 / Kruchten 4+1 criteria: 4+1 views populated, CROSS-CUTTING modules justified, and interface definitions complete. | P1 | Architecture design must be reviewed against the governing standard to catch structural gaps before downstream work. | Test |
| REQ-006 | When reviewing `system-test.md`, the command SHALL evaluate against ISO 29119 criteria: named techniques used correctly, no user-journey language present, and test scenario independence maintained. | P1 | System test artifacts must comply with ISO 29119 to ensure technique-based testing. | Test |
| REQ-007 | When reviewing `integration-test.md`, the command SHALL evaluate against ISO 29119-4 criteria: CDCT technique present, fault injection scenarios included, and interface coverage complete. | P1 | Integration test artifacts must comply with ISO 29119-4 for interface-level testing techniques. | Test |
| REQ-008 | When reviewing `module-design.md`, the command SHALL evaluate against DO-178C / ISO 26262 criteria: 4 mandatory views present, algorithm specifications complete, and error handling defined. | P1 | Module design artifacts in safety-critical systems must comply with DO-178C / ISO 26262 standards. | Test |
| REQ-009 | When reviewing `unit-test.md`, the command SHALL evaluate against ISO 29119-4 criteria: 5 techniques present, mock registry complete, and boundary values explicit. | P1 | Unit test artifacts must comply with ISO 29119-4 for method-level testing completeness. | Test |
| REQ-010 | When reviewing `hazard-analysis.md`, the command SHALL evaluate against ISO 14971 / ISO 26262 criteria: severity classifications present for each hazard, every HAZ has a mitigation defined, operational state coverage present, and residual risk assessed. | P2 | User Story 4 (P2): a safety engineer reviews hazard analysis for ISO 14971 compliance. | Test |
| REQ-011 | When reviewing `acceptance-plan.md`, the command SHALL evaluate against ISO 29119 criteria: BDD scenarios well-formed, validation conditions measurable, and coverage of parent REQs verified. | P1 | Acceptance plan artifacts must comply with ISO 29119 to ensure validation completeness. | Test |
| REQ-012 | Each finding in the review report SHALL be assigned a unique identifier using the pattern `PRF-{ARTIFACT}-NNN`, where `{ARTIFACT}` is an uppercase abbreviation derived from the artifact type (e.g., REQ for requirements, SYS for system-design, ARCH for architecture-design, HAZ for hazard-analysis) and `NNN` is a zero-padded sequential number starting at 001. | P1 | Unique finding IDs enable precise reference in discussions, commit messages, and code review comments. | Test |
| REQ-013 | Each finding SHALL be classified with exactly one severity level from the set: Critical, Major, Minor, Observation. | P1 | Severity classification drives the CI exit code logic and helps engineers prioritize remediation. | Test |
| REQ-014 | A finding SHALL be classified as Critical when it identifies a fundamental quality violation that blocks release, such as an untestable requirement, a missing mandatory view, or an unmitigated catastrophic hazard. | P1 | Critical findings must block PR merge via the CI gate (exit code 1) to prevent releasing fundamentally flawed artifacts. | Test |
| REQ-015 | A finding SHALL be classified as Major when it identifies a quality issue that should be resolved before approval, such as an ambiguous quantifier, an incomplete interface contract, or a missing test technique. | P1 | Major findings should block PR merge via the CI gate (exit code 1) to ensure quality issues are addressed before approval. | Test |
| REQ-016 | A finding SHALL be classified as Minor when it identifies a style or completeness issue that does not affect correctness, such as inconsistent formatting or a missing rationale on a low-risk item. | P1 | Minor findings generate a CI warning (exit code 2) but do not block merge, allowing teams to proceed with non-critical improvements deferred. | Test |
| REQ-017 | A finding SHALL be classified as Observation when it identifies an informational suggestion for improvement that is not a defect, such as an alternative decomposition strategy or an additional test technique that could add value. | P2 | Observations provide value without triggering CI warnings; they are treated the same as zero findings for exit code purposes. | Test |
| REQ-018 | The review report header section SHALL include: the reviewer identification, the generation date, the artifact file name, the count of items in the reviewed artifact, and the governing standard for the artifact type. | P1 | The header provides context for the review: what was reviewed, when, and against which standard. | Test |
| REQ-019 | The review report SHALL include a summary table that displays finding counts for each severity level (Critical, Major, Minor, Observation). | P1 | The summary table enables the CI parser script to determine exit codes by parsing severity counts. | Test |
| REQ-020 | Each finding subsection in the review report SHALL include the following fields: PRF ID, Severity, Location (referencing the specific artifact item ID), Description, and Recommendation. | P1 | Structured finding fields ensure each issue is actionable: engineers know what to fix, where, and how. | Test |
| REQ-021 | The command SHALL regenerate the entire `peer-review-{artifact}.md` file on each invocation, replacing any previously generated review for the same artifact. | P2 | User Story 5 (P2): idempotent re-run after fix — resolved findings disappear, and `git diff` shows the delta. | Test |
| REQ-022 | The extension SHALL provide a `peer-review-check.sh` Bash script that reads a `peer-review-{artifact}.md` file and returns an exit code based on the severities of findings present in the file. | P1 | User Story 2 (P1): CI gate for pull requests requires a deterministic script that returns exit codes for automation. | Test |
| REQ-023 | The `peer-review-check.sh` script SHALL return exit code 0 when the review file contains zero findings or contains only Observation-level findings. | P1 | Exit code 0 signals a clean review, allowing the PR to merge without intervention. | Test |
| REQ-024 | The `peer-review-check.sh` script SHALL return exit code 1 when the review file contains at least one Critical finding or at least one Major finding. | P1 | Exit code 1 blocks PR merge, enforcing that fundamental and significant quality issues are resolved before approval. | Test |
| REQ-025 | The `peer-review-check.sh` script SHALL return exit code 2 when the review file contains at least one Minor finding and contains zero Critical findings and zero Major findings. | P1 | Exit code 2 provides a warning signal for minor issues without blocking the merge. | Test |
| REQ-026 | The `peer-review-check.sh` script SHALL determine finding severities by parsing the summary table or individual finding headers in the peer review markdown file. | P1 | The parsing mechanism must be defined to ensure the check script reliably extracts severity data from the review report. | Test |
| REQ-027 | The `peer-review-check.sh` script SHALL support a `--json` flag that outputs finding counts by severity level as structured JSON to stdout. | P1 | Machine-readable JSON output enables downstream CI tools and dashboards to consume finding data programmatically. | Test |
| REQ-028 | The extension SHALL provide a `peer-review-check.ps1` PowerShell script that accepts the same input and produces identical exit code semantics and `--json` output structure as the `peer-review-check.sh` Bash script. | P2 | PowerShell parity ensures cross-platform support following the established convention for script pairs. | Test |
| REQ-029 | The command SHALL accept any one of the 9 supported artifact types (requirements.md, system-design.md, architecture-design.md, system-test.md, integration-test.md, module-design.md, unit-test.md, hazard-analysis.md, acceptance-plan.md) for review without requiring any other V-Model artifacts to be present. | P1 | Cross-cutting capability: engineers can review any artifact at any point in the V-Model lifecycle with no ordering dependency. | Test |

### Non-Functional Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-NF-001 | The command SHALL operate statelessly: the review report SHALL contain no persistent status fields (e.g., no "Status: Open/Closed" on individual findings); the presence of a finding in the report indicates a current problem, and its absence after re-run indicates resolution. | P1 | Stateless linting model: the review operates like ESLint, not like Jira — findings are transient, resolved by fixing and re-running. | Inspection |
| REQ-NF-002 | The `peer-review-check.sh` and `peer-review-check.ps1` scripts SHALL be deterministic: given the same `peer-review-{artifact}.md` input file, they SHALL always produce the same exit code and the same `--json` output. | P1 | The CI parser scripts must produce reproducible results for reliable CI gating. | Test |

### Interface Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-IF-001 | The `peer-review-check.sh` script SHALL accept the following CLI syntax: `peer-review-check.sh [--json] <peer-review-file>`. | P1 | Consistent CLI interface with clear positional argument and optional flag. | Test |
| REQ-IF-002 | The `peer-review-check.ps1` script SHALL accept equivalent PowerShell parameters: `Peer-Review-Check.ps1 [-Json] -ReviewFile <path>`. | P2 | PowerShell parity with idiomatic parameter naming conventions. | Test |

### Constraint Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-CN-001 | The command SHALL NOT modify the original artifact being reviewed — it is a read-only analysis tool that only produces a new review report file. | P1 | The spec explicitly excludes automated fixing; the command identifies issues but never alters the source artifact. | Inspection |
| REQ-CN-002 | PRF-{ARTIFACT}-NNN finding IDs SHALL NOT participate in the V-Model traceability chain and SHALL NOT be referenced by trace matrices or coverage metrics. | P1 | PRF IDs are advisory-only and transient; trace IDs (REQ, SYS, ATP, etc.) are permanent — mixing them would corrupt the traceability model. | Inspection |
| REQ-CN-003 | Each invocation of the command SHALL review exactly one artifact; the command SHALL NOT accept multiple artifact files in a single invocation. | P1 | The spec explicitly states cross-artifact review is not in scope; reviewing multiple artifacts requires multiple invocations. | Test |
| REQ-CN-004 | The command SHALL NOT maintain a database or persistent store of past findings; git history SHALL serve as the audit trail of what was found and when it was resolved. | P1 | Historical tracking is explicitly out of scope; the stateless model relies on version control for audit history. | Inspection |

## Assumptions

- The AI model (LLM) executing the peer review command has knowledge of the referenced standards (INCOSE, IEEE 1016, IEEE 42010, ISO 29119, ISO 29119-4, DO-178C, ISO 26262, ISO 14971) sufficient to evaluate artifact compliance.
- V-Model artifacts follow the established ID patterns (e.g., `REQ-[0-9]{3}`, `SYS-[0-9]{3}`, `HAZ-[0-9]{3}`) and file naming conventions of the spec-kit V-Model Extension Pack.
- The `peer-review-{artifact}.md` output file uses a consistent, parseable markdown structure (headers, tables, severity labels) that the deterministic check scripts can reliably parse.
- The `{ARTIFACT}` abbreviation in `PRF-{ARTIFACT}-NNN` follows a known mapping (e.g., REQ for requirements.md, SYS for system-design.md, ARCH for architecture-design.md, STP for system-test.md, ITP for integration-test.md, MOD for module-design.md, UTP for unit-test.md, HAZ for hazard-analysis.md, ATP for acceptance-plan.md).
- The peer review command is invoked within a spec-kit project that has a valid V-Model directory structure with at least one artifact file present.

## Dependencies

- **Existing V-Model artifact**: At least one artifact file (e.g., `requirements.md`, `system-design.md`) must exist in the V-Model directory to serve as input for the review.
- **AI model (LLM)**: An AI model with natural language understanding capabilities must be available at command execution time to perform the standards-based evaluation.
- **Standard Bash utilities**: The `peer-review-check.sh` script depends on standard Bash utilities (grep, awk, sed) for parsing the review markdown file.
- **PowerShell runtime**: The `peer-review-check.ps1` script depends on PowerShell 5.1+ or PowerShell Core 7+ for cross-platform execution.

## Glossary

| Term | Definition |
|------|-----------|
| PRF ID | Peer Review Finding identifier in the format `PRF-{ARTIFACT}-NNN`, used to label individual findings in the review report; advisory-only and not part of the traceability chain |
| Stateless Linting | A review model where findings are derived solely from the current state of the artifact on each run, with no persistent tracking of finding status across invocations |
| Severity Level | Classification of a finding's impact: Critical (blocks release), Major (fix before approval), Minor (does not affect correctness), or Observation (informational suggestion) |
| Governing Standard | The industry standard (e.g., INCOSE, IEEE 1016, ISO 14971) that defines the review criteria for a specific artifact type |
| Artifact Type | One of the 9 V-Model document types that can be peer-reviewed: requirements, system-design, architecture-design, system-test, integration-test, module-design, unit-test, hazard-analysis, acceptance-plan |
| CI Gate | A continuous integration checkpoint that uses exit codes from the check script (0, 1, or 2) to allow or block pull request merges |
| Finding | A single quality issue or observation identified during peer review, consisting of a PRF ID, severity, location, description, and recommendation |
| Advisory-Only | A designation indicating that PRF finding IDs exist solely for discussion and remediation tracking and do not participate in V-Model traceability or coverage metrics |
| Blast Radius (Review) | Not applicable to peer review — peer review operates on a single artifact per invocation with no transitive analysis |

---

**Total Requirements**: 37
**By Priority**: P1: 32 | P2: 5 | P3: 0
**By Verification Method**: Test: 33 | Inspection: 4 | Analysis: 0 | Demonstration: 0
