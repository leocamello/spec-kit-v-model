# Integration Test Plan: Peer Review

**Feature Branch**: `feature/005c-peer-review`
**Created**: 2025-07-18
**Status**: Approved
**Source**: `specs/005c-peer-review/v-model/architecture-design.md`

## Overview

This document defines the Integration Test Plan for the Peer Review feature. Every architecture module in `architecture-design.md` has one or more Integration Test Cases (ITP), and every Test Case has one or more executable Integration Scenarios (ITS) in module-boundary BDD format (Given/When/Then). Integration tests verify the **seams and handshakes between modules** — they target the interfaces between the Artifact File Reader, Artifact Type Resolver, Review Criteria Registry, LLM Evaluation Coordinator, PRF ID Generator, Severity Classifier, Report Header Builder, Report Markdown Renderer, and the two CI Gate scripts. Language is module-boundary-oriented throughout; no user-journey or internal-logic phrases are used.

## ID Schema

- **Integration Test Case**: `ITP-{NNN}-{X}` — where NNN matches the parent ARCH, X is a letter suffix (A, B, C...)
- **Integration Test Scenario**: `ITS-{NNN}-{X}{#}` — nested under the parent ITP, with numeric suffix (1, 2, 3...)
- Example: `ITS-001-A1` → Scenario 1 of Test Case A verifying ARCH-001 integration

## ISO 29119-4 Integration Test Techniques

Each test case MUST identify its technique by name and anchor to a specific architecture view:

| Technique | Source View | What It Tests |
|-----------|------------|---------------|
| **Interface Contract Testing** | Interface View | Module API contracts, data format compliance, error responses |
| **Consumer-Driven Contract Testing (CDCT)** | Interface View | Data exchange contracts between producer and consumer module pairs |
| **Data Flow Testing** | Data Flow View | End-to-end data transformation chain validation |
| **Interface Fault Injection** | Interface View + Process View | Malformed payloads, timeouts, graceful failure |

> **Note on Concurrency & Race Condition Testing**: The Process View explicitly states the AI evaluation path is "sequential, single-threaded execution" and the CI scripts are "single-process execution." No concurrent access patterns exist in this architecture. Therefore, no Concurrency & Race Condition test cases are generated, per the rule: "Modules with concurrency interactions get Concurrency Testing."

## Integration Tests

### Module Verification: ARCH-001 (Artifact File Reader)

**Parent System Components**: SYS-001

#### Test Case: ITP-001-A (File reader output consumed by type resolver and LLM coordinator)

**Technique**: Consumer-Driven Contract Testing (CDCT)
**Target View**: Interface View — ARCH-001 → ARCH-002 and ARCH-001 → ARCH-004 interfaces
**Description**: Verify the raw file content string produced by ARCH-001 is correctly consumed by ARCH-002 (for type resolution) and ARCH-004 (for LLM evaluation prompt construction).

* **Integration Scenario: ITS-001-A1**
  * **Given** ARCH-001 (Artifact File Reader) has read a valid `requirements.md` file containing 12 `REQ-NNN` identifiers and returned the raw content as a non-empty string
  * **When** ARCH-002 (Artifact Type Resolver) receives the raw file content and file name from ARCH-001
  * **Then** ARCH-002 resolves the artifact type to `requirements`, the abbreviation to `REQ`, the governing standard to `INCOSE`, and the item count to 12

* **Integration Scenario: ITS-001-A2**
  * **Given** ARCH-001 (Artifact File Reader) has read a valid `architecture-design.md` file and returned the raw content string
  * **When** ARCH-004 (LLM Evaluation Coordinator) receives the raw artifact content from ARCH-001 alongside the criteria set from ARCH-003
  * **Then** ARCH-004 constructs an evaluation prompt that includes the full artifact content and invokes the LLM without truncation or corruption of the input

#### Test Case: ITP-001-B (File reader error propagation to consumers)

**Technique**: Interface Fault Injection
**Target View**: Interface View — ARCH-001 error contracts
**Description**: Verify that ARCH-001 error conditions (file not found, empty file) are correctly propagated to downstream consumers ARCH-002 and ARCH-004, preventing silent failures.

* **Integration Scenario: ITS-001-B1**
  * **Given** ARCH-001 (Artifact File Reader) receives a file path pointing to a non-existent file
  * **When** ARCH-001 raises a `FileNotFoundError` and ARCH-002 (Artifact Type Resolver) attempts to consume the output
  * **Then** the pipeline terminates with a descriptive error message and ARCH-002 does not attempt type resolution on undefined content

* **Integration Scenario: ITS-001-B2**
  * **Given** ARCH-001 (Artifact File Reader) receives a path to an existing file that contains zero bytes
  * **When** ARCH-001 raises an `EmptyFileError`
  * **Then** the error propagates to the pipeline entry point and ARCH-004 (LLM Evaluation Coordinator) is never invoked

#### Test Case: ITP-001-C (File reader as entry point of the report generation data flow)

**Technique**: Data Flow Testing
**Target View**: Data Flow View — Stage 1 (Artifact to Peer Review Report chain)
**Description**: Verify that a file path string injected at ARCH-001 correctly transforms into raw file content at the first stage of the data flow chain.

* **Integration Scenario: ITS-001-C1**
  * **Given** a file path string pointing to a `system-test.md` artifact containing 8 `STP-NNN` identifiers
  * **When** ARCH-001 (Artifact File Reader) processes the path and produces raw content
  * **Then** the output format is a non-empty string preserving the original file encoding, and the content is passed unchanged to ARCH-002 and ARCH-004

---

### Module Verification: ARCH-002 (Artifact Type Resolver)

**Parent System Components**: SYS-001

#### Test Case: ITP-002-A (Type resolver metadata consumed by multiple downstream modules)

**Technique**: Consumer-Driven Contract Testing (CDCT)
**Target View**: Interface View — ARCH-002 → ARCH-003, ARCH-004, ARCH-005, ARCH-007 interfaces
**Description**: Verify that the artifact metadata produced by ARCH-002 (type, abbreviation, governing standard, item count) is correctly consumed by all four downstream modules.

* **Integration Scenario: ITS-002-A1**
  * **Given** ARCH-002 (Artifact Type Resolver) has resolved `hazard-analysis.md` to type `hazard-analysis`, abbreviation `HAZ`, governing standard `ISO 14971 / ISO 26262`, and item count 5
  * **When** ARCH-003 (Review Criteria Registry) receives the artifact type identifier `hazard-analysis`
  * **Then** ARCH-003 returns the hazard analysis criteria set containing ISO 14971 quality dimensions including severity classification and mitigation coverage rules

* **Integration Scenario: ITS-002-A2**
  * **Given** ARCH-002 (Artifact Type Resolver) has resolved `system-design.md` to abbreviation `SYS` and item count 6
  * **When** ARCH-005 (PRF ID Generator) receives the abbreviation `SYS` from ARCH-002 and ARCH-007 (Report Header Builder) receives the metadata (fileName: `system-design.md`, itemCount: 6, standard: `IEEE 1016`)
  * **Then** ARCH-005 generates PRF IDs in the pattern `PRF-SYS-NNN` and ARCH-007 produces a header markdown string containing all four metadata fields

#### Test Case: ITP-002-B (Type resolver rejects unsupported artifact types)

**Technique**: Interface Fault Injection
**Target View**: Interface View — ARCH-002 error contracts
**Description**: Verify that ARCH-002 raises an `UnsupportedArtifactTypeError` for file names not matching any of the 9 supported types, and that downstream modules do not receive invalid type data.

* **Integration Scenario: ITS-002-B1**
  * **Given** ARCH-001 (Artifact File Reader) has read a file named `changelog.md` and passed the content to ARCH-002
  * **When** ARCH-002 (Artifact Type Resolver) attempts to match the file name against the 9 supported artifact types
  * **Then** ARCH-002 raises `UnsupportedArtifactTypeError` with the file name in the error message, and ARCH-003, ARCH-004, ARCH-005, and ARCH-007 receive no output from ARCH-002

* **Integration Scenario: ITS-002-B2**
  * **Given** ARCH-001 (Artifact File Reader) has read a valid file but the invocation includes two artifact paths
  * **When** ARCH-002 (Artifact Type Resolver) detects multiple artifact inputs
  * **Then** ARCH-002 raises `MultipleArtifactError` and the pipeline terminates before any downstream module is invoked

---

### Module Verification: ARCH-003 (Review Criteria Registry)

**Parent System Components**: SYS-002

#### Test Case: ITP-003-A (Criteria set consumed by LLM evaluation coordinator)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-003 → ARCH-004 interface
**Description**: Verify that the criteria set produced by ARCH-003 for a given artifact type is a well-formed structured object consumed correctly by ARCH-004 to construct the LLM evaluation prompt.

* **Integration Scenario: ITS-003-A1**
  * **Given** ARCH-002 (Artifact Type Resolver) has resolved artifact type to `integration-test` and sent the type identifier to ARCH-003
  * **When** ARCH-003 (Review Criteria Registry) looks up criteria for `integration-test` and passes the result to ARCH-004 (LLM Evaluation Coordinator)
  * **Then** ARCH-004 receives a criteria set object containing quality dimensions (CDCT technique presence, fault injection coverage, interface completeness), evaluation rules, and standard references to ISO 29119-4

* **Integration Scenario: ITS-003-A2**
  * **Given** ARCH-003 (Review Criteria Registry) returns the `requirements` criteria set containing INCOSE quality attributes (atomic, testable, unambiguous, complete, free of subjective language, priority assigned)
  * **When** ARCH-004 (LLM Evaluation Coordinator) constructs the evaluation prompt using the criteria set
  * **Then** the prompt includes all 6 INCOSE quality dimensions as evaluation criteria and the raw artifact content from ARCH-001

#### Test Case: ITP-003-B (Criteria registry handles unknown artifact type)

**Technique**: Interface Fault Injection
**Target View**: Interface View — ARCH-003 error contracts
**Description**: Verify that ARCH-003 raises `UnknownArtifactTypeError` when receiving an artifact type identifier not in its registry, preventing ARCH-004 from evaluating without criteria.

* **Integration Scenario: ITS-003-B1**
  * **Given** a malformed artifact type identifier `unknown-type` is sent to ARCH-003 (Review Criteria Registry)
  * **When** ARCH-003 attempts to look up criteria for the unrecognized type
  * **Then** ARCH-003 raises `UnknownArtifactTypeError` and ARCH-004 (LLM Evaluation Coordinator) is not invoked

---

### Module Verification: ARCH-004 (LLM Evaluation Coordinator)

**Parent System Components**: SYS-002

#### Test Case: ITP-004-A (Raw findings consumed by PRF ID generator)

**Technique**: Consumer-Driven Contract Testing (CDCT)
**Target View**: Interface View — ARCH-004 → ARCH-005 interface
**Description**: Verify that the raw findings array produced by ARCH-004 conforms to the contract expected by ARCH-005, with each finding containing location, description, and recommendation fields.

* **Integration Scenario: ITS-004-A1**
  * **Given** ARCH-004 (LLM Evaluation Coordinator) has evaluated a `requirements.md` artifact and produced 3 raw findings, each with `location` (e.g., `REQ-005`), `description`, and `recommendation` fields
  * **When** ARCH-005 (PRF ID Generator) receives the raw findings array
  * **Then** ARCH-005 assigns sequential PRF IDs `PRF-REQ-001`, `PRF-REQ-002`, `PRF-REQ-003` and passes all three fields through to the identified findings output

* **Integration Scenario: ITS-004-A2**
  * **Given** ARCH-004 (LLM Evaluation Coordinator) evaluates a clean artifact and produces an empty raw findings array
  * **When** ARCH-005 (PRF ID Generator) receives the empty array
  * **Then** ARCH-005 produces an empty identified findings array and ARCH-006 (Severity Classifier) receives no findings to classify

#### Test Case: ITP-004-B (LLM failure propagation across module boundaries)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View — ARCH-004 error contracts
**Description**: Verify that when the LLM call fails or returns an unparseable response, ARCH-004 raises `LLMEvaluationError` and downstream modules (ARCH-005, ARCH-006, ARCH-008) are not invoked with corrupt data.

* **Integration Scenario: ITS-004-B1**
  * **Given** ARCH-004 (LLM Evaluation Coordinator) has received valid artifact content from ARCH-001 and criteria from ARCH-003
  * **When** the LLM call fails with a timeout or network error and ARCH-004 raises `LLMEvaluationError`
  * **Then** ARCH-005 (PRF ID Generator) receives no findings, ARCH-006 (Severity Classifier) is not invoked, and the pipeline terminates with an error message describing the LLM failure

* **Integration Scenario: ITS-004-B2**
  * **Given** ARCH-004 (LLM Evaluation Coordinator) receives an LLM response that cannot be parsed into the expected `{location, description, recommendation}` format
  * **When** ARCH-004 attempts to parse the malformed response
  * **Then** ARCH-004 raises `LLMEvaluationError` with failure details and no partial findings are passed to ARCH-005

#### Test Case: ITP-004-C (Content and criteria flow through evaluation stage)

**Technique**: Data Flow Testing
**Target View**: Data Flow View — Stage 4 (Artifact to Peer Review Report chain)
**Description**: Verify the data transformation at ARCH-004: raw content (string) combined with criteria set (object) produces raw findings array with the correct structure.

* **Integration Scenario: ITS-004-C1**
  * **Given** ARCH-001 has produced raw content for an `architecture-design.md` artifact and ARCH-003 has returned the IEEE 42010 criteria set with dimensions (4+1 views populated, CROSS-CUTTING justified, interface definitions complete)
  * **When** ARCH-004 (LLM Evaluation Coordinator) combines the content and criteria to construct the evaluation prompt and processes the LLM response
  * **Then** the output is an array of raw findings where each element has exactly three string fields (`location`, `description`, `recommendation`) and the total count matches the number of quality issues identified by the LLM

---

### Module Verification: ARCH-005 (PRF ID Generator)

**Parent System Components**: SYS-003

#### Test Case: ITP-005-A (Identified findings consumed by severity classifier)

**Technique**: Consumer-Driven Contract Testing (CDCT)
**Target View**: Interface View — ARCH-005 → ARCH-006 interface
**Description**: Verify that the identified findings array produced by ARCH-005 (with PRF IDs assigned) conforms to the contract expected by ARCH-006.

* **Integration Scenario: ITS-005-A1**
  * **Given** ARCH-004 (LLM Evaluation Coordinator) has produced 4 raw findings for a `module-design.md` artifact and ARCH-002 has provided abbreviation `MOD`
  * **When** ARCH-005 (PRF ID Generator) assigns IDs `PRF-MOD-001` through `PRF-MOD-004` and passes the identified findings to ARCH-006 (Severity Classifier)
  * **Then** ARCH-006 receives all 4 findings, each containing `prfId`, `location`, `description`, and `recommendation`, with PRF IDs in sequential zero-padded format

* **Integration Scenario: ITS-005-A2**
  * **Given** ARCH-005 (PRF ID Generator) has received raw findings for an `acceptance-plan.md` artifact with abbreviation `ATP`
  * **When** ARCH-005 assigns PRF IDs starting at `PRF-ATP-001`
  * **Then** the identified findings array preserves the original `location`, `description`, and `recommendation` from each raw finding without modification, and ARCH-006 can process each finding independently

#### Test Case: ITP-005-B (PRF ID generator rejects invalid abbreviation)

**Technique**: Interface Fault Injection
**Target View**: Interface View — ARCH-005 error contracts
**Description**: Verify that ARCH-005 raises `InvalidAbbreviationError` when receiving an abbreviation not in the allowed set, preventing malformed PRF IDs from reaching ARCH-006.

* **Integration Scenario: ITS-005-B1**
  * **Given** ARCH-005 (PRF ID Generator) receives raw findings from ARCH-004 and an abbreviation `INVALID` that is not in the allowed set (REQ, SYS, ARCH, STP, ITP, MOD, UTP, HAZ, ATP)
  * **When** ARCH-005 attempts to construct PRF IDs using the invalid abbreviation
  * **Then** ARCH-005 raises `InvalidAbbreviationError` and no identified findings are passed to ARCH-006 (Severity Classifier)

---

### Module Verification: ARCH-006 (Severity Classifier)

**Parent System Components**: SYS-003

#### Test Case: ITP-006-A (Classified findings consumed by report markdown renderer)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-006 → ARCH-008 interface
**Description**: Verify that the classified findings array produced by ARCH-006 conforms to the contract expected by ARCH-008, with each finding containing PRF ID, severity, location, description, and recommendation.

* **Integration Scenario: ITS-006-A1**
  * **Given** ARCH-005 (PRF ID Generator) has produced identified findings `[{prfId: "PRF-REQ-001", location: "REQ-003", description: "Ambiguous quantifier", recommendation: "Replace with measurable threshold"}]`
  * **When** ARCH-006 (Severity Classifier) classifies the finding as `Major` and passes the result to ARCH-008 (Report Markdown Renderer)
  * **Then** ARCH-008 receives a classified findings array where each element contains exactly 5 fields: `prfId`, `severity` (one of Critical/Major/Minor/Observation), `location`, `description`, and `recommendation`

* **Integration Scenario: ITS-006-A2**
  * **Given** ARCH-006 (Severity Classifier) receives 5 identified findings and classifies them as 1 Critical, 2 Major, 1 Minor, and 1 Observation
  * **When** ARCH-008 (Report Markdown Renderer) receives the classified findings array
  * **Then** ARCH-008 generates a summary table with counts `{Critical: 1, Major: 2, Minor: 1, Observation: 1}` and 5 individual finding subsections preserving the severity assignments from ARCH-006

#### Test Case: ITP-006-B (Findings transformation from identified to classified)

**Technique**: Data Flow Testing
**Target View**: Data Flow View — Stage 6 (Artifact to Peer Review Report chain)
**Description**: Verify the data transformation at ARCH-006: identified findings array (with PRF IDs) is enriched with exactly one severity level per finding.

* **Integration Scenario: ITS-006-B1**
  * **Given** ARCH-005 has produced identified findings for a `unit-test.md` artifact with PRF IDs `PRF-UTP-001` through `PRF-UTP-003`
  * **When** the data flows from ARCH-005 through ARCH-006 (Severity Classifier)
  * **Then** the output array contains exactly 3 classified findings, each with the original `prfId`, `location`, `description`, `recommendation` unchanged, and a new `severity` field set to exactly one of: Critical, Major, Minor, or Observation

#### Test Case: ITP-006-C (Unclassifiable finding error propagation)

**Technique**: Interface Fault Injection
**Target View**: Interface View — ARCH-006 error contracts
**Description**: Verify that when ARCH-006 cannot map a finding to any severity level, it raises `UnclassifiableFindingError` and does not pass partially classified data to ARCH-008.

* **Integration Scenario: ITS-006-C1**
  * **Given** ARCH-005 (PRF ID Generator) has produced an identified finding with a description that does not match any severity classification criteria
  * **When** ARCH-006 (Severity Classifier) attempts to classify the finding
  * **Then** ARCH-006 raises `UnclassifiableFindingError` with the finding details included, and ARCH-008 (Report Markdown Renderer) does not receive a partial classified findings array

---

### Module Verification: ARCH-007 (Report Header Builder)

**Parent System Components**: SYS-004

#### Test Case: ITP-007-A (Header markdown consumed by report renderer)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-007 → ARCH-008 interface
**Description**: Verify that the header markdown string produced by ARCH-007 is a well-formed section consumed by ARCH-008 to construct the report.

* **Integration Scenario: ITS-007-A1**
  * **Given** ARCH-002 (Artifact Type Resolver) has provided metadata: fileName `requirements.md`, itemCount 15, governingStandard `INCOSE`
  * **When** ARCH-007 (Report Header Builder) constructs the header and passes the markdown string to ARCH-008 (Report Markdown Renderer)
  * **Then** ARCH-008 receives a header string containing the reviewer identification `AI Peer Reviewer`, a generation date, artifact file name `requirements.md`, item count `15`, and governing standard `INCOSE`

* **Integration Scenario: ITS-007-A2**
  * **Given** ARCH-002 (Artifact Type Resolver) has provided metadata for `hazard-analysis.md` with itemCount 3 and governingStandard `ISO 14971 / ISO 26262`
  * **When** ARCH-007 (Report Header Builder) constructs the header and passes it to ARCH-008
  * **Then** ARCH-008 receives a formatted markdown string that begins with the report title and includes all five required header fields in the documented order

#### Test Case: ITP-007-B (Missing metadata propagation from type resolver)

**Technique**: Interface Fault Injection
**Target View**: Interface View — ARCH-007 error contracts
**Description**: Verify that when ARCH-002 provides incomplete metadata (missing fields), ARCH-007 raises `MissingMetadataError` and does not produce a partial header for ARCH-008.

* **Integration Scenario: ITS-007-B1**
  * **Given** ARCH-002 (Artifact Type Resolver) provides metadata with `governingStandard` field absent (null or missing)
  * **When** ARCH-007 (Report Header Builder) attempts to construct the header
  * **Then** ARCH-007 raises `MissingMetadataError` listing `governingStandard` as the missing field, and ARCH-008 (Report Markdown Renderer) does not receive a header section

* **Integration Scenario: ITS-007-B2**
  * **Given** ARCH-002 (Artifact Type Resolver) provides metadata with `itemCount` set to a negative value
  * **When** ARCH-007 (Report Header Builder) validates the input metadata
  * **Then** ARCH-007 raises `MissingMetadataError` and the pipeline does not produce a report with invalid metadata in the header

---

### Module Verification: ARCH-008 (Report Markdown Renderer)

**Parent System Components**: SYS-004

#### Test Case: ITP-008-A (End-to-end report assembly from header and classified findings)

**Technique**: Data Flow Testing
**Target View**: Data Flow View — Stage 8 (Artifact to Peer Review Report chain)
**Description**: Verify the final data transformation: header markdown from ARCH-007 combined with classified findings from ARCH-006 produces a well-formed `peer-review-{artifact}.md` file.

* **Integration Scenario: ITS-008-A1**
  * **Given** ARCH-007 (Report Header Builder) has produced a header markdown string for `requirements.md` and ARCH-006 (Severity Classifier) has produced 2 classified findings: `{prfId: "PRF-REQ-001", severity: "Critical", location: "REQ-005", description: "Untestable requirement", recommendation: "Add measurable criteria"}` and `{prfId: "PRF-REQ-002", severity: "Minor", location: "REQ-012", description: "Inconsistent formatting", recommendation: "Align with template"}`
  * **When** ARCH-008 (Report Markdown Renderer) assembles the complete document
  * **Then** the output file `peer-review-requirements.md` contains the header section, a summary table with `{Critical: 1, Major: 0, Minor: 1, Observation: 0}`, and 2 finding subsections each containing PRF ID, Severity, Location, Description, and Recommendation fields in the documented order

* **Integration Scenario: ITS-008-A2**
  * **Given** ARCH-007 has produced a header for `architecture-design.md` and ARCH-006 has produced an empty classified findings array (clean review)
  * **When** ARCH-008 (Report Markdown Renderer) assembles the document
  * **Then** the output file `peer-review-architecture-design.md` contains the header section, a summary table with all severity counts at 0, and no finding subsections

#### Test Case: ITP-008-B (Report file consumed by CI gate scripts)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-008 → ARCH-009 and ARCH-008 → ARCH-010 interfaces
**Description**: Verify that the `peer-review-{artifact}.md` file written by ARCH-008 conforms to the parseable markdown structure expected by both ARCH-009 and ARCH-010.

* **Integration Scenario: ITS-008-B1**
  * **Given** ARCH-008 (Report Markdown Renderer) has written `peer-review-requirements.md` with a summary table containing `{Critical: 0, Major: 0, Minor: 2, Observation: 1}`
  * **When** ARCH-009 (Bash Review Parser & Gate) reads and parses the file
  * **Then** ARCH-009 extracts severity counts `{critical: 0, major: 0, minor: 2, observation: 1}` and returns exit code 2 (Minor findings only, no Critical or Major)

* **Integration Scenario: ITS-008-B2**
  * **Given** ARCH-008 (Report Markdown Renderer) has written `peer-review-system-design.md` with a summary table containing `{Critical: 1, Major: 0, Minor: 0, Observation: 0}`
  * **When** ARCH-010 (PowerShell Review Parser & Gate) reads and parses the file
  * **Then** ARCH-010 extracts severity counts `{critical: 1, major: 0, minor: 0, observation: 0}` and returns exit code 1 (Critical finding present)

#### Test Case: ITP-008-C (Report renderer handles file write failure)

**Technique**: Interface Fault Injection
**Target View**: Interface View — ARCH-008 error contracts
**Description**: Verify that ARCH-008 raises `FileWriteError` when the output path is not writable, and that no partial file is left on disk for ARCH-009/ARCH-010 to parse.

* **Integration Scenario: ITS-008-C1**
  * **Given** ARCH-007 has produced a valid header and ARCH-006 has produced classified findings
  * **When** ARCH-008 (Report Markdown Renderer) attempts to write to a read-only directory path
  * **Then** ARCH-008 raises `FileWriteError` with the path and OS error details, and no `peer-review-{artifact}.md` file is created at the output path

---

### Module Verification: ARCH-009 (Bash Review Parser & Gate)

**Parent System Components**: SYS-005

#### Test Case: ITP-009-A (Bash parser correctly maps severity counts to exit codes)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-009 exit code contract
**Description**: Verify that ARCH-009 correctly parses the review file produced by ARCH-008 and returns the correct exit code based on severity counts.

* **Integration Scenario: ITS-009-A1**
  * **Given** ARCH-008 (Report Markdown Renderer) has produced a `peer-review-requirements.md` file containing a summary table with `{Critical: 0, Major: 0, Minor: 0, Observation: 3}`
  * **When** ARCH-009 (Bash Review Parser & Gate) is invoked with `peer-review-check.sh peer-review-requirements.md`
  * **Then** ARCH-009 returns exit code 0 (clean: only Observations present)

* **Integration Scenario: ITS-009-A2**
  * **Given** ARCH-008 has produced a review file with `{Critical: 0, Major: 1, Minor: 2, Observation: 0}`
  * **When** ARCH-009 is invoked with `peer-review-check.sh peer-review-system-design.md`
  * **Then** ARCH-009 returns exit code 1 (Major finding present)

* **Integration Scenario: ITS-009-A3**
  * **Given** ARCH-008 has produced a review file with `{Critical: 0, Major: 0, Minor: 0, Observation: 0}` (zero findings)
  * **When** ARCH-009 is invoked with `peer-review-check.sh peer-review-unit-test.md`
  * **Then** ARCH-009 returns exit code 0 (clean: no findings)

#### Test Case: ITP-009-B (Bash parser JSON output contract)

**Technique**: Consumer-Driven Contract Testing (CDCT)
**Target View**: Interface View — ARCH-009 `--json` output interface
**Description**: Verify that ARCH-009 with the `--json` flag produces structured JSON output conforming to the documented schema, consumable by CI pipeline tools.

* **Integration Scenario: ITS-009-B1**
  * **Given** ARCH-008 has produced a review file with `{Critical: 2, Major: 1, Minor: 3, Observation: 0}`
  * **When** ARCH-009 is invoked with `peer-review-check.sh --json peer-review-requirements.md`
  * **Then** ARCH-009 writes `{"critical": 2, "major": 1, "minor": 3, "observation": 0}` to stdout as valid JSON and returns exit code 1

#### Test Case: ITP-009-C (Bash parser handles missing or malformed review file)

**Technique**: Interface Fault Injection
**Target View**: Interface View — ARCH-009 error contracts
**Description**: Verify that ARCH-009 returns exit code 1 with a stderr message when the review file does not exist or has an unexpected format.

* **Integration Scenario: ITS-009-C1**
  * **Given** no `peer-review-requirements.md` file exists at the specified path
  * **When** ARCH-009 (Bash Review Parser & Gate) is invoked with `peer-review-check.sh peer-review-requirements.md`
  * **Then** ARCH-009 returns exit code 1 and writes a `FileNotFoundError` message to stderr

* **Integration Scenario: ITS-009-C2**
  * **Given** a file exists at the specified path but contains no recognizable summary table or finding headers
  * **When** ARCH-009 (Bash Review Parser & Gate) attempts to parse the malformed file
  * **Then** ARCH-009 returns exit code 1 and writes a `ParseError` message to stderr describing the unexpected format

---

### Module Verification: ARCH-010 (PowerShell Review Parser & Gate)

**Parent System Components**: SYS-006

#### Test Case: ITP-010-A (PowerShell parser produces identical results to Bash parser)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-010 parity with ARCH-009
**Description**: Verify end-to-end behavioral parity between the PowerShell and Bash CI gate implementations for the same review file input.

* **Integration Scenario: ITS-010-A1**
  * **Given** ARCH-008 (Report Markdown Renderer) has produced a `peer-review-architecture-design.md` file with `{Critical: 0, Major: 2, Minor: 1, Observation: 0}`
  * **When** ARCH-009 (Bash) is invoked with `peer-review-check.sh --json peer-review-architecture-design.md` and ARCH-010 (PowerShell) is invoked with `Peer-Review-Check.ps1 -Json -ReviewFile peer-review-architecture-design.md` against the same file
  * **Then** both produce identical JSON output `{"critical": 0, "major": 2, "minor": 1, "observation": 0}` and both return exit code 1

* **Integration Scenario: ITS-010-A2**
  * **Given** ARCH-008 has produced a clean review file with `{Critical: 0, Major: 0, Minor: 0, Observation: 5}`
  * **When** both ARCH-009 and ARCH-010 process the same file
  * **Then** both return exit code 0 (clean: only Observations) and with `--json` / `-Json` both output `{"critical": 0, "major": 0, "minor": 0, "observation": 5}`

#### Test Case: ITP-010-B (PowerShell parser handles missing or malformed review file)

**Technique**: Interface Fault Injection
**Target View**: Interface View — ARCH-010 error contracts
**Description**: Verify that ARCH-010 mirrors ARCH-009 error behavior: exit code 1 with error output when the review file is missing or unparseable.

* **Integration Scenario: ITS-010-B1**
  * **Given** no review file exists at the path specified in `-ReviewFile`
  * **When** ARCH-010 (PowerShell Review Parser & Gate) is invoked with `Peer-Review-Check.ps1 -ReviewFile nonexistent-review.md`
  * **Then** ARCH-010 returns exit code 1 and writes a file-not-found error to PowerShell error output

* **Integration Scenario: ITS-010-B2**
  * **Given** a file exists at the `-ReviewFile` path but contains no parseable summary table
  * **When** ARCH-010 (PowerShell Review Parser & Gate) attempts to parse the malformed file
  * **Then** ARCH-010 returns exit code 1 and writes a parse error to PowerShell error output, mirroring ARCH-009 behavior

---

## Test Harness & Mocking Strategy

| Test Case | External Dependency | Mock/Stub Strategy | Rationale |
|-----------|--------------------|--------------------|-----------|
| ITP-001-A, ITP-001-B, ITP-001-C | File system | Stub: In-memory file system with pre-loaded artifact content | Isolates file I/O from integration logic; enables controlled error injection (missing files, empty files) |
| ITP-002-A, ITP-002-B | ARCH-001 output | Stub: Pre-built raw content string and file name | Type resolver tests need controlled input; avoids coupling to actual file reading |
| ITP-003-A, ITP-003-B | ARCH-002 output | Stub: Fixed artifact type identifier | Criteria registry tests need deterministic type input; avoids coupling to type resolution logic |
| ITP-004-A, ITP-004-B, ITP-004-C | LLM service | Mock: Configurable LLM response returning pre-defined findings or errors | LLM is non-deterministic and external; mock ensures reproducible test scenarios for finding generation and failure paths |
| ITP-005-A, ITP-005-B | ARCH-004 output | Stub: Pre-built raw findings array | PRF ID generator tests need fixed findings input; avoids coupling to LLM evaluation |
| ITP-006-A, ITP-006-B, ITP-006-C | ARCH-005 output | Stub: Pre-built identified findings with PRF IDs | Severity classifier tests need deterministic input; classification rules are the focus |
| ITP-007-A, ITP-007-B | ARCH-002 metadata | Stub: Fixed metadata object (fileName, itemCount, standard) | Header builder tests need controlled metadata; avoids coupling to type resolution |
| ITP-008-A, ITP-008-B, ITP-008-C | File system (write) | Stub: In-memory file system or temp directory for write verification | Enables verification of file content without disk side effects; supports write-failure injection |
| ITP-009-A, ITP-009-B, ITP-009-C | ARCH-008 output file | Fixture: Pre-generated `peer-review-{artifact}.md` files with known severity distributions | Bash parser tests need deterministic review files; fixtures cover all exit code paths (0, 1, 2) |
| ITP-010-A, ITP-010-B | ARCH-008 output file | Fixture: Same pre-generated review files as ARCH-009 tests | PowerShell parity tests must use identical inputs to verify identical outputs |

### Mock Behavior Driven by Interface Contracts

All mock and stub behaviors are derived directly from the Interface View contracts in `architecture-design.md`:
- **LLM Mock** returns findings in the exact `{location, description, recommendation}` format defined in ARCH-004's output contract
- **File system stubs** produce content matching the `fileContent` output format of ARCH-001 (non-empty string, original encoding)
- **Metadata stubs** provide objects matching ARCH-002's output contract (artifactType enum, abbreviation string, governingStandard string, itemCount integer)
- **Review file fixtures** follow the markdown structure defined by ARCH-008's output contract (header, summary table, finding subsections)

### Test Data Management

- **Fixture files**: Pre-generated review files for each exit code path stored in a `test/fixtures/` directory
- **Inline data**: Small artifact samples (3–5 IDs) embedded directly in test scenarios for readability
- **Factory functions**: Programmatic generation of raw findings, identified findings, and classified findings arrays for parameterized tests

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Architecture Modules (ARCH) | 10 |
| Total Test Cases (ITP) | 25 |
| Total Scenarios (ITS) | 43 |
| Modules with ≥1 ITP | 10 / 10 (100%) |
| Test Cases with ≥1 ITS | 25 / 25 (100%) |
| **Overall Coverage (ARCH→ITP)** | **100%** |

### Technique Distribution

| Technique | Test Cases | Percentage |
|-----------|-----------|------------|
| Interface Fault Injection | 10 | 40.0% |
| Interface Contract Testing | 6 | 24.0% |
| Consumer-Driven Contract Testing (CDCT) | 5 | 20.0% |
| Data Flow Testing | 4 | 16.0% |
| Concurrency & Race Condition Testing | 0 | 0% |

> **Concurrency justification**: The Process View documents sequential, single-threaded execution for the AI path and single-process execution for CI scripts. No concurrent access patterns exist; therefore no Concurrency & Race Condition test cases are applicable.

## Uncovered Modules

None — full coverage achieved.
