# System Test Plan: Peer Review

**Feature Branch**: `feature/005c-peer-review`
**Created**: 2025-07-18
**Status**: Approved
**Source**: `specs/005c-peer-review/v-model/system-design.md`

## Overview

This document defines the System Test Plan for the Peer Review feature. Every system component in `system-design.md` has one or more Test Cases (STP), and every Test Case has one or more executable System Scenarios (STS) in technical BDD format (Given/When/Then). System tests verify architectural behavior, not user journeys. Language is technical and component-oriented.

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

### Component Verification: SYS-001 (Artifact Reader & Type Dispatcher)

**Parent Requirements**: REQ-001, REQ-029, REQ-CN-001, REQ-CN-003

#### Test Case: STP-001-A (External command invocation accepts a single artifact file and dispatches correctly)

**Technique**: Interface Contract Testing
**Target View**: Interface View (External Interfaces)
**Description**: Verify that the Peer Review command invocation accepts a single V-Model artifact file path, identifies its type, and triggers the review pipeline producing `peer-review-{artifact}.md`.

* **System Scenario: STS-001-A1**
  * **Given** a valid `requirements.md` artifact file exists in the V-Model directory
  * **When** the Artifact Reader receives the file path as input via command invocation
  * **Then** the Artifact Reader identifies the artifact type as `requirements`, reads the file content, and dispatches the content and type identifier to SYS-002

* **System Scenario: STS-001-A2**
  * **Given** an artifact file path pointing to a file that does not exist on the file system
  * **When** the Artifact Reader receives the non-existent file path as input
  * **Then** the Artifact Reader raises an error indicating the artifact file does not exist and no report file is generated

* **System Scenario: STS-001-A3**
  * **Given** two artifact file paths are provided as input in a single invocation
  * **When** the Artifact Reader processes the input
  * **Then** the Artifact Reader rejects the input with an error indicating exactly one artifact must be specified per invocation

#### Test Case: STP-001-B (Internal dispatch contract delivers artifact content and metadata to downstream components)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Internal Interfaces)
**Description**: Verify the Artifact Reader correctly dispatches artifact content and type to SYS-002 via the Artifact Dispatch interface, and delivers artifact metadata to SYS-004 via the Artifact Metadata interface.

* **System Scenario: STS-001-B1**
  * **Given** a valid `system-design.md` artifact containing 6 SYS component entries
  * **When** the Artifact Reader processes the file
  * **Then** the Artifact Dispatch interface delivers the full file content as a string, the artifact type identifier `system-design`, and the artifact item count `6` to SYS-002

* **System Scenario: STS-001-B2**
  * **Given** a valid `hazard-analysis.md` artifact containing 3 HAZ entries
  * **When** the Artifact Reader processes the file
  * **Then** the Artifact Metadata interface delivers the file name `hazard-analysis.md`, item count `3`, artifact type `hazard-analysis`, and governing standard `ISO 14971 / ISO 26262` to SYS-004

* **System Scenario: STS-001-B3**
  * **Given** a valid artifact file with empty content (zero bytes)
  * **When** the Artifact Reader attempts to dispatch via the Artifact Dispatch interface
  * **Then** the interface raises an error indicating the artifact content is empty

#### Test Case: STP-001-C (Artifact type identification for all 9 supported types)

**Technique**: Equivalence Partitioning
**Target View**: Data Design View
**Description**: Verify the Artifact Reader correctly identifies all 9 supported artifact types as distinct equivalence classes and rejects unsupported types.

* **System Scenario: STS-001-C1**
  * **Given** artifact files named `requirements.md`, `system-design.md`, `architecture-design.md`, `system-test.md`, `integration-test.md`, `module-design.md`, `unit-test.md`, `hazard-analysis.md`, and `acceptance-plan.md`
  * **When** the Artifact Reader processes each file individually
  * **Then** each file is identified as its corresponding artifact type: `requirements`, `system-design`, `architecture-design`, `system-test`, `integration-test`, `module-design`, `unit-test`, `hazard-analysis`, `acceptance-plan`

* **System Scenario: STS-001-C2**
  * **Given** an artifact file named `README.md` which is not one of the 9 supported types
  * **When** the Artifact Reader processes the file
  * **Then** the Artifact Reader rejects the file with an error indicating unsupported artifact type

#### Test Case: STP-001-D (Boundary conditions for artifact file reading)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verify the Artifact Reader handles edge cases in artifact file content size and item count.

* **System Scenario: STS-001-D1**
  * **Given** a `requirements.md` artifact containing exactly 1 requirement (minimum item count)
  * **When** the Artifact Reader processes the file
  * **Then** the Artifact Reader reports an item count of 1 and dispatches the content successfully

* **System Scenario: STS-001-D2**
  * **Given** a `requirements.md` artifact containing 500 requirements (large item count)
  * **When** the Artifact Reader processes the file
  * **Then** the Artifact Reader reports an item count of 500 and dispatches the full content without truncation

#### Test Case: STP-001-E (Artifact Reader resilience when file system access fails)

**Technique**: Fault Injection
**Target View**: Dependency View
**Description**: Verify the Artifact Reader handles file system failures gracefully without crashing or producing partial output.

* **System Scenario: STS-001-E1**
  * **Given** a file path pointing to a file with restricted read permissions
  * **When** the Artifact Reader attempts to read the artifact
  * **Then** the Artifact Reader raises an error indicating the file cannot be read and no downstream components are invoked

* **System Scenario: STS-001-E2**
  * **Given** the Artifact Reader successfully reads a valid `requirements.md` file
  * **When** the original artifact file is verified after command completion
  * **Then** the original file content is unchanged (read-only operation confirmed)

---

### Component Verification: SYS-002 (AI Review Criteria Engine)

**Parent Requirements**: REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011

#### Test Case: STP-002-A (Internal interface contract for receiving artifact data and emitting raw findings)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Internal Interfaces)
**Description**: Verify the AI Review Criteria Engine correctly receives artifact content and type from SYS-001 via the Artifact Dispatch interface and outputs a list of raw findings to SYS-003 via the Raw Findings List interface.

* **System Scenario: STS-002-A1**
  * **Given** the Artifact Dispatch interface delivers artifact content as a string, artifact type `requirements`, and item count `10`
  * **When** the AI Review Criteria Engine processes the input
  * **Then** the engine produces a Raw Findings List where each finding contains: location (artifact item ID reference), description (string), recommendation (string), and artifact type abbreviation `REQ`

* **System Scenario: STS-002-A2**
  * **Given** the Artifact Dispatch interface delivers a well-formed `acceptance-plan.md` with zero quality issues
  * **When** the AI Review Criteria Engine evaluates the artifact
  * **Then** the Raw Findings List interface outputs an empty array

#### Test Case: STP-002-B (Artifact-type-specific evaluation rule sets applied correctly)

**Technique**: Equivalence Partitioning
**Target View**: Data Design View
**Description**: Verify the AI Review Criteria Engine applies the correct standards-based evaluation criteria for each of the 9 artifact types, treating each type as a distinct equivalence class.

* **System Scenario: STS-002-B1**
  * **Given** a `requirements.md` artifact containing a requirement with subjective language ("the system should be user-friendly") and no priority assigned
  * **When** the AI Review Criteria Engine evaluates using INCOSE quality attributes
  * **Then** the engine produces findings referencing the INCOSE criteria: "free of subjective language" violation and "priority assigned" violation

* **System Scenario: STS-002-B2**
  * **Given** a `system-design.md` artifact missing the Interface View section (only 3 of 4 required IEEE 1016 views present)
  * **When** the AI Review Criteria Engine evaluates using IEEE 1016 criteria
  * **Then** the engine produces a finding indicating the missing Interface View with reference to IEEE 1016 completeness

* **System Scenario: STS-002-B3**
  * **Given** a `system-test.md` artifact containing a scenario with the phrase "the user clicks the submit button"
  * **When** the AI Review Criteria Engine evaluates using ISO 29119 criteria
  * **Then** the engine produces a finding identifying the user-journey language violation in the test scenario

* **System Scenario: STS-002-B4**
  * **Given** a `hazard-analysis.md` artifact where `HAZ-001` has severity classification "Catastrophic" but no mitigation defined
  * **When** the AI Review Criteria Engine evaluates using ISO 14971 / ISO 26262 criteria
  * **Then** the engine produces a finding identifying the missing mitigation for a catastrophic hazard

* **System Scenario: STS-002-B5**
  * **Given** an `integration-test.md` artifact with no CDCT (Consumer-Driven Contract Testing) technique present
  * **When** the AI Review Criteria Engine evaluates using ISO 29119-4 criteria
  * **Then** the engine produces a finding indicating the missing CDCT technique

#### Test Case: STP-002-C (Boundary conditions for finding generation)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verify the AI Review Criteria Engine handles boundary conditions in artifact size and finding density.

* **System Scenario: STS-002-C1**
  * **Given** a `requirements.md` artifact containing exactly 1 requirement that is fully compliant with INCOSE quality attributes
  * **When** the AI Review Criteria Engine evaluates the artifact
  * **Then** the engine produces zero findings (empty Raw Findings List)

* **System Scenario: STS-002-C2**
  * **Given** a `requirements.md` artifact containing 100 requirements where every requirement violates at least one INCOSE quality attribute
  * **When** the AI Review Criteria Engine evaluates the artifact
  * **Then** the engine produces at least 100 findings (one or more per requirement) with no findings dropped or truncated

#### Test Case: STP-002-D (AI Review Criteria Engine behavior when Artifact Reader input is degraded)

**Technique**: Fault Injection
**Target View**: Dependency View
**Description**: Verify the AI Review Criteria Engine handles failure conditions in the Artifact Dispatch interface from SYS-001, as specified in the Dependency View (SYS-002 → SYS-001: "cannot evaluate without input artifact data").

* **System Scenario: STS-002-D1**
  * **Given** the Artifact Dispatch interface delivers artifact content as an empty string with type `requirements`
  * **When** the AI Review Criteria Engine attempts to evaluate
  * **Then** the engine raises an error indicating empty artifact content and produces no findings

* **System Scenario: STS-002-D2**
  * **Given** the Artifact Dispatch interface delivers artifact content with an unrecognized type identifier `changelog`
  * **When** the AI Review Criteria Engine attempts to select the evaluation rule set
  * **Then** the engine raises an error indicating unrecognized artifact type and produces no findings

---

### Component Verification: SYS-003 (Finding Identifier & Severity Classifier)

**Parent Requirements**: REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-017, REQ-CN-002

#### Test Case: STP-003-A (Internal interface contract for receiving raw findings and emitting classified findings)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Internal Interfaces)
**Description**: Verify the Finding Identifier & Severity Classifier receives raw findings from SYS-002 via the Raw Findings List interface and outputs classified findings with PRF IDs and severity levels to SYS-004 via the Classified Findings List interface.

* **System Scenario: STS-003-A1**
  * **Given** the Raw Findings List interface delivers an array of 3 raw findings, each with location, description, recommendation, and artifact type abbreviation `REQ`
  * **When** the Finding Identifier & Severity Classifier processes the findings
  * **Then** the Classified Findings List interface outputs an array of 3 classified findings, each containing: PRF ID (pattern `PRF-REQ-001`, `PRF-REQ-002`, `PRF-REQ-003`), severity (one of Critical, Major, Minor, Observation), location, description, and recommendation

* **System Scenario: STS-003-A2**
  * **Given** the Raw Findings List interface delivers an empty array (zero findings)
  * **When** the Finding Identifier & Severity Classifier processes the input
  * **Then** the Classified Findings List interface outputs an empty array

#### Test Case: STP-003-B (Severity classification into four distinct equivalence classes)

**Technique**: Equivalence Partitioning
**Target View**: Data Design View
**Description**: Verify each finding is classified into exactly one of four severity levels — Critical, Major, Minor, Observation — with each level representing a distinct equivalence class based on the finding's characteristics.

* **System Scenario: STS-003-B1**
  * **Given** a raw finding describing an untestable requirement (fundamental quality violation blocking release)
  * **When** the Severity Classifier assigns a severity level
  * **Then** the finding is classified as `Critical`

* **System Scenario: STS-003-B2**
  * **Given** a raw finding describing an ambiguous quantifier in a requirement (significant quality issue requiring resolution before approval)
  * **When** the Severity Classifier assigns a severity level
  * **Then** the finding is classified as `Major`

* **System Scenario: STS-003-B3**
  * **Given** a raw finding describing inconsistent formatting in a table (style issue not affecting correctness)
  * **When** the Severity Classifier assigns a severity level
  * **Then** the finding is classified as `Minor`

* **System Scenario: STS-003-B4**
  * **Given** a raw finding suggesting an alternative decomposition strategy (informational suggestion, not a defect)
  * **When** the Severity Classifier assigns a severity level
  * **Then** the finding is classified as `Observation`

#### Test Case: STP-003-C (PRF ID generation with correct pattern and sequential numbering)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verify PRF ID generation follows the pattern `PRF-{ARTIFACT}-NNN` with zero-padded sequential numbering starting at 001, and handles boundary conditions in numbering.

* **System Scenario: STS-003-C1**
  * **Given** a single raw finding with artifact type abbreviation `SYS`
  * **When** the Finding Identifier assigns the PRF ID
  * **Then** the assigned ID is `PRF-SYS-001` (zero-padded, starting at 001)

* **System Scenario: STS-003-C2**
  * **Given** 999 raw findings with artifact type abbreviation `REQ`
  * **When** the Finding Identifier assigns sequential PRF IDs
  * **Then** IDs range from `PRF-REQ-001` to `PRF-REQ-999` with no gaps and no duplicates

* **System Scenario: STS-003-C3**
  * **Given** raw findings from a `system-design.md` review
  * **When** the Finding Identifier generates PRF IDs
  * **Then** all IDs use the `SYS` abbreviation: `PRF-SYS-001`, `PRF-SYS-002`, etc.

* **System Scenario: STS-003-C4**
  * **Given** raw findings from an `architecture-design.md` review
  * **When** the Finding Identifier generates PRF IDs
  * **Then** all IDs use the `ARCH` abbreviation: `PRF-ARCH-001`, `PRF-ARCH-002`, etc.

#### Test Case: STP-003-D (Classifier behavior when AI Review Criteria Engine output is degraded)

**Technique**: Fault Injection
**Target View**: Dependency View
**Description**: Verify the Finding Identifier & Severity Classifier handles failure conditions from SYS-002, as specified in the Dependency View (SYS-003 → SYS-002: "cannot assign IDs or severities without evaluation results").

* **System Scenario: STS-003-D1**
  * **Given** the Raw Findings List interface delivers a finding with a missing location field
  * **When** the Finding Identifier & Severity Classifier attempts to process the malformed finding
  * **Then** the classifier raises an error or skips the malformed finding with a warning, and remaining valid findings are processed normally

* **System Scenario: STS-003-D2**
  * **Given** the connection to SYS-002 fails and no Raw Findings List is delivered
  * **When** the Finding Identifier & Severity Classifier is invoked
  * **Then** the classifier raises an error indicating evaluation results are unavailable and no classified findings are produced

---

### Component Verification: SYS-004 (Review Report Formatter)

**Parent Requirements**: REQ-001, REQ-018, REQ-019, REQ-020, REQ-021, REQ-NF-001, REQ-CN-004

#### Test Case: STP-004-A (Internal interface contract for generating the review report file)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Internal Interfaces)
**Description**: Verify the Review Report Formatter receives classified findings from SYS-003 and artifact metadata from SYS-001, and produces a correctly structured `peer-review-{artifact}.md` file.

* **System Scenario: STS-004-A1**
  * **Given** the Classified Findings List contains 2 findings (`PRF-REQ-001` Critical, `PRF-REQ-002` Minor) and artifact metadata specifies file name `requirements.md`, item count `10`, type `requirements`, governing standard `INCOSE`
  * **When** the Review Report Formatter generates the output
  * **Then** the formatter produces a file named `peer-review-requirements.md` containing: a header section with reviewer identification, generation date, file name `requirements.md`, item count `10`, and governing standard `INCOSE`; a summary table with Critical: 1, Major: 0, Minor: 1, Observation: 0; and 2 finding subsections each with PRF ID, Severity, Location, Description, and Recommendation

* **System Scenario: STS-004-A2**
  * **Given** the Classified Findings List is empty (zero findings) and artifact metadata is valid
  * **When** the Review Report Formatter generates the output
  * **Then** the formatter produces a file with a header section, a summary table showing all severity counts as 0, and no finding subsections

* **System Scenario: STS-004-A3**
  * **Given** a `peer-review-requirements.md` file already exists in the V-Model directory from a previous invocation
  * **When** the Review Report Formatter generates the output for a new review of `requirements.md`
  * **Then** the existing file is completely replaced with the new report content (full regeneration)

#### Test Case: STP-004-B (Report generation with findings at each severity boundary)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verify the Review Report Formatter correctly handles the boundary conditions of 0, 1, and many findings per severity level.

* **System Scenario: STS-004-B1**
  * **Given** a Classified Findings List with exactly 1 finding at each severity level (1 Critical, 1 Major, 1 Minor, 1 Observation)
  * **When** the Review Report Formatter generates the summary table
  * **Then** the summary table displays Critical: 1, Major: 1, Minor: 1, Observation: 1 with a total of 4 findings

* **System Scenario: STS-004-B2**
  * **Given** a Classified Findings List with 50 Critical findings and 0 findings at all other severity levels
  * **When** the Review Report Formatter generates the report
  * **Then** the report contains 50 finding subsections, all with severity `Critical`, and the summary table shows Critical: 50, Major: 0, Minor: 0, Observation: 0

#### Test Case: STP-004-C (Report artifact naming for different artifact types)

**Technique**: Equivalence Partitioning
**Target View**: Data Design View
**Description**: Verify the Review Report Formatter produces correctly named output files for each of the 9 supported artifact types.

* **System Scenario: STS-004-C1**
  * **Given** artifact metadata with file name `system-design.md` and type `system-design`
  * **When** the Review Report Formatter generates the output file
  * **Then** the output file is named `peer-review-system-design.md`

* **System Scenario: STS-004-C2**
  * **Given** artifact metadata with file name `hazard-analysis.md` and type `hazard-analysis`
  * **When** the Review Report Formatter generates the output file
  * **Then** the output file is named `peer-review-hazard-analysis.md`

* **System Scenario: STS-004-C3**
  * **Given** artifact metadata with file name `acceptance-plan.md` and type `acceptance-plan`
  * **When** the Review Report Formatter generates the output file
  * **Then** the output file is named `peer-review-acceptance-plan.md`

#### Test Case: STP-004-D (Formatter behavior when upstream components fail)

**Technique**: Fault Injection
**Target View**: Dependency View
**Description**: Verify the Review Report Formatter handles failures from SYS-003 and SYS-001 as specified in the Dependency View (SYS-004 → SYS-003: "cannot generate the report without structured finding data"; SYS-004 → SYS-001: "requires artifact metadata for the report header section").

* **System Scenario: STS-004-D1**
  * **Given** the Classified Findings List interface from SYS-003 is unavailable (no findings data delivered)
  * **When** the Review Report Formatter attempts to generate the report
  * **Then** the formatter raises an error indicating classified findings are unavailable and no report file is produced

* **System Scenario: STS-004-D2**
  * **Given** the Artifact Metadata interface from SYS-001 delivers incomplete metadata (missing governing standard)
  * **When** the Review Report Formatter attempts to generate the report header
  * **Then** the formatter raises an error indicating metadata extraction failed and no report file is produced

---

### Component Verification: SYS-005 (Bash CI Check Script)

**Parent Requirements**: REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-002, REQ-IF-001

#### Test Case: STP-005-A (External CLI interface contract for peer-review-check.sh)

**Technique**: Interface Contract Testing
**Target View**: Interface View (External Interfaces)
**Description**: Verify the Bash CI Check Script accepts the CLI syntax `peer-review-check.sh [--json] <peer-review-file>`, processes the review file, and returns the correct exit code and optional JSON output.

* **System Scenario: STS-005-A1**
  * **Given** a `peer-review-requirements.md` file with a summary table showing Critical: 0, Major: 0, Minor: 0, Observation: 2
  * **When** the script is invoked as `peer-review-check.sh peer-review-requirements.md`
  * **Then** the script returns exit code 0

* **System Scenario: STS-005-A2**
  * **Given** a `peer-review-requirements.md` file with a summary table showing Critical: 1, Major: 0, Minor: 0, Observation: 0
  * **When** the script is invoked as `peer-review-check.sh peer-review-requirements.md`
  * **Then** the script returns exit code 1

* **System Scenario: STS-005-A3**
  * **Given** a `peer-review-requirements.md` file with a summary table showing Critical: 0, Major: 0, Minor: 3, Observation: 1
  * **When** the script is invoked as `peer-review-check.sh peer-review-requirements.md`
  * **Then** the script returns exit code 2

* **System Scenario: STS-005-A4**
  * **Given** a `peer-review-requirements.md` file with findings at multiple severity levels
  * **When** the script is invoked as `peer-review-check.sh --json peer-review-requirements.md`
  * **Then** the script outputs structured JSON to stdout containing finding counts by severity level (Critical, Major, Minor, Observation) and returns the appropriate exit code

#### Test Case: STP-005-B (Exit code equivalence classes based on finding severity combinations)

**Technique**: Equivalence Partitioning
**Target View**: Data Design View
**Description**: Verify the three exit code equivalence classes are correctly determined: class 0 (clean/observations only), class 1 (Critical or Major present), class 2 (Minor only, no Critical/Major).

* **System Scenario: STS-005-B1**
  * **Given** a review file containing zero findings (empty summary table)
  * **When** the script determines the exit code
  * **Then** the exit code is 0 (equivalence class: clean)

* **System Scenario: STS-005-B2**
  * **Given** a review file containing only Observation-level findings (Critical: 0, Major: 0, Minor: 0, Observation: 5)
  * **When** the script determines the exit code
  * **Then** the exit code is 0 (equivalence class: observations only)

* **System Scenario: STS-005-B3**
  * **Given** a review file containing at least one Major finding and zero Critical findings (Critical: 0, Major: 2, Minor: 1, Observation: 0)
  * **When** the script determines the exit code
  * **Then** the exit code is 1 (equivalence class: Major present)

* **System Scenario: STS-005-B4**
  * **Given** a review file containing both Critical and Major findings (Critical: 1, Major: 3, Minor: 2, Observation: 1)
  * **When** the script determines the exit code
  * **Then** the exit code is 1 (equivalence class: Critical present)

* **System Scenario: STS-005-B5**
  * **Given** a review file containing Minor findings only (Critical: 0, Major: 0, Minor: 4, Observation: 0)
  * **When** the script determines the exit code
  * **Then** the exit code is 2 (equivalence class: Minor only)

#### Test Case: STP-005-C (Boundary conditions in severity count parsing)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verify the script correctly parses severity counts at boundary values, including zero counts, single counts, and large counts.

* **System Scenario: STS-005-C1**
  * **Given** a review file with summary table showing exactly Critical: 1, Major: 0, Minor: 0, Observation: 0 (minimum Critical count to trigger exit code 1)
  * **When** the script parses the summary table
  * **Then** the script returns exit code 1

* **System Scenario: STS-005-C2**
  * **Given** a review file with summary table showing Critical: 0, Major: 0, Minor: 1, Observation: 0 (minimum Minor count to trigger exit code 2)
  * **When** the script parses the summary table
  * **Then** the script returns exit code 2

* **System Scenario: STS-005-C3**
  * **Given** a review file with summary table showing Critical: 0, Major: 0, Minor: 0, Observation: 0 (all counts zero)
  * **When** the script parses the summary table
  * **Then** the script returns exit code 0

#### Test Case: STP-005-D (Script behavior when review file is missing or malformed)

**Technique**: Fault Injection
**Target View**: Dependency View
**Description**: Verify the Bash CI Check Script handles failure conditions from SYS-004, as specified in the Dependency View (SYS-005 → SYS-004: "cannot determine exit codes without a generated review file").

* **System Scenario: STS-005-D1**
  * **Given** a file path pointing to a non-existent `peer-review-requirements.md`
  * **When** the script is invoked as `peer-review-check.sh peer-review-missing.md`
  * **Then** the script returns exit code 1 and emits an error message to stderr describing the missing file

* **System Scenario: STS-005-D2**
  * **Given** a file that is not a valid peer review markdown (e.g., a plain text file with no summary table or severity headers)
  * **When** the script is invoked with the unparseable file
  * **Then** the script returns exit code 1 and emits an error message to stderr indicating the file format is unparseable

* **System Scenario: STS-005-D3**
  * **Given** the same valid `peer-review-requirements.md` file provided on two consecutive invocations
  * **When** the script runs twice with identical input
  * **Then** both invocations produce the same exit code and identical `--json` output (deterministic behavior confirmed)

---

### Component Verification: SYS-006 (PowerShell CI Check Script)

**Parent Requirements**: REQ-028, REQ-IF-002, REQ-NF-002

#### Test Case: STP-006-A (External PowerShell parameter interface contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View (External Interfaces)
**Description**: Verify the PowerShell CI Check Script accepts idiomatic PowerShell parameters `Peer-Review-Check.ps1 [-Json] -ReviewFile <path>` and produces the same exit code semantics as SYS-005.

* **System Scenario: STS-006-A1**
  * **Given** a `peer-review-requirements.md` file with summary table showing Critical: 0, Major: 0, Minor: 0, Observation: 3
  * **When** the script is invoked as `Peer-Review-Check.ps1 -ReviewFile peer-review-requirements.md`
  * **Then** the script returns exit code 0

* **System Scenario: STS-006-A2**
  * **Given** a `peer-review-system-design.md` file with summary table showing Critical: 2, Major: 1, Minor: 0, Observation: 0
  * **When** the script is invoked as `Peer-Review-Check.ps1 -Json -ReviewFile peer-review-system-design.md`
  * **Then** the script returns exit code 1 and outputs structured JSON to stdout with finding counts by severity level

* **System Scenario: STS-006-A3**
  * **Given** a `peer-review-module-design.md` file with summary table showing Critical: 0, Major: 0, Minor: 2, Observation: 1
  * **When** the script is invoked as `Peer-Review-Check.ps1 -ReviewFile peer-review-module-design.md`
  * **Then** the script returns exit code 2

#### Test Case: STP-006-B (Behavioral parity with Bash CI Check Script across all exit code classes)

**Technique**: Equivalence Partitioning
**Target View**: Data Design View
**Description**: Verify the PowerShell script produces identical exit codes and JSON output as the Bash script for the same input files across all equivalence classes, as specified in the Dependency View (SYS-006 mirrors SYS-005).

* **System Scenario: STS-006-B1**
  * **Given** a `peer-review-requirements.md` file with Critical: 0, Major: 0, Minor: 0, Observation: 0 processed by both Bash and PowerShell scripts
  * **When** both scripts run with the `--json` / `-Json` flag on the same file
  * **Then** both scripts return exit code 0 and produce identical JSON output structure and values

* **System Scenario: STS-006-B2**
  * **Given** a `peer-review-requirements.md` file with Critical: 1, Major: 2, Minor: 3, Observation: 4 processed by both scripts
  * **When** both scripts run with the `--json` / `-Json` flag on the same file
  * **Then** both scripts return exit code 1 and produce identical JSON severity counts

* **System Scenario: STS-006-B3**
  * **Given** a `peer-review-requirements.md` file with Critical: 0, Major: 0, Minor: 5, Observation: 2 processed by both scripts
  * **When** both scripts run on the same file
  * **Then** both scripts return exit code 2

#### Test Case: STP-006-C (PowerShell script boundary conditions in parsing)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verify the PowerShell script handles boundary conditions in severity count parsing, including minimum values that trigger each exit code.

* **System Scenario: STS-006-C1**
  * **Given** a review file with summary table showing exactly Major: 1 and all other severities at 0 (minimum Major count to trigger exit code 1)
  * **When** the PowerShell script parses the review file
  * **Then** the script returns exit code 1

* **System Scenario: STS-006-C2**
  * **Given** a review file with summary table showing exactly Minor: 1 and Critical: 0, Major: 0, Observation: 0 (minimum Minor count to trigger exit code 2)
  * **When** the PowerShell script parses the review file
  * **Then** the script returns exit code 2

#### Test Case: STP-006-D (PowerShell script behavior when review file is missing or malformed)

**Technique**: Fault Injection
**Target View**: Dependency View
**Description**: Verify the PowerShell CI Check Script handles failure conditions from SYS-004, as specified in the Dependency View (SYS-006 → SYS-004: "cannot determine exit codes without a generated review file").

* **System Scenario: STS-006-D1**
  * **Given** a file path pointing to a non-existent review file
  * **When** the PowerShell script is invoked as `Peer-Review-Check.ps1 -ReviewFile peer-review-missing.md`
  * **Then** the script returns exit code 1 and emits an error message via PowerShell error output indicating the file was not found

* **System Scenario: STS-006-D2**
  * **Given** a malformed markdown file with no recognizable summary table or severity headers
  * **When** the PowerShell script attempts to parse the file
  * **Then** the script returns exit code 1 and emits an error indicating the file format is unexpected

* **System Scenario: STS-006-D3**
  * **Given** the same valid review file provided on two consecutive invocations of the PowerShell script
  * **When** the script runs twice with identical input
  * **Then** both invocations produce the same exit code and identical `-Json` output (deterministic behavior confirmed)

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total System Components (SYS) | 6 |
| Total Test Cases (STP) | 25 |
| Total Scenarios (STS) | 71 |
| Components with ≥1 STP | 6 / 6 (100%) |
| Test Cases with ≥1 STS | 25 / 25 (100%) |
| **Overall Coverage (SYS→STP)** | **100%** |

### Technique Distribution

| Technique | STP Count |
|-----------|-----------|
| Interface Contract Testing | 7 |
| Equivalence Partitioning | 6 |
| Boundary Value Analysis | 6 |
| Fault Injection | 6 |

### Per-Component Coverage

| SYS | Component Name | STP Count | STS Count | Techniques Used |
|-----|----------------|-----------|-----------|-----------------|
| SYS-001 | Artifact Reader & Type Dispatcher | 5 | 12 | Interface Contract Testing, Equivalence Partitioning, Boundary Value Analysis, Fault Injection |
| SYS-002 | AI Review Criteria Engine | 4 | 11 | Interface Contract Testing, Equivalence Partitioning, Boundary Value Analysis, Fault Injection |
| SYS-003 | Finding Identifier & Severity Classifier | 4 | 12 | Interface Contract Testing, Equivalence Partitioning, Boundary Value Analysis, Fault Injection |
| SYS-004 | Review Report Formatter | 4 | 10 | Interface Contract Testing, Equivalence Partitioning, Boundary Value Analysis, Fault Injection |
| SYS-005 | Bash CI Check Script | 4 | 15 | Interface Contract Testing, Equivalence Partitioning, Boundary Value Analysis, Fault Injection |
| SYS-006 | PowerShell CI Check Script | 4 | 11 | Interface Contract Testing, Equivalence Partitioning, Boundary Value Analysis, Fault Injection |

## Uncovered Components

None — full coverage achieved.
