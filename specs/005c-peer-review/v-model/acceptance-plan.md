# Acceptance Test Plan: Peer Review

**Feature Branch**: `feature/005c-peer-review`
**Created**: 2025-07-18
**Status**: Approved
**Source**: `specs/005c-peer-review/v-model/requirements.md`

## Overview

This document defines the Acceptance Test Plan for the Peer Review feature. Every requirement in `requirements.md` has one or more Test Cases (ATP), and every Test Case has one or more executable User Scenarios (SCN) in BDD format (Given/When/Then). The plan covers the peer review command's AI-powered artifact evaluation, standards-based review criteria for each of the 9 supported artifact types, finding identification and severity classification, review report structure, the deterministic CI parser scripts (`peer-review-check.sh` / `peer-review-check.ps1`), exit code semantics, JSON output, and constraint enforcement (stateless, read-only, single-artifact).

## ID Schema

- **Test Case**: `ATP-{NNN}-{X}` — where NNN matches the parent REQ, X is a letter suffix (A, B, C...)
- **Scenario**: `SCN-{NNN}-{X}{#}` — nested under the parent ATP, with numeric suffix (1, 2, 3...)
- Example: `SCN-001-A1` → Scenario 1 of Test Case A validating REQ-001

## Acceptance Tests

### Requirement Validation: REQ-001 (Single Artifact Review and Output File)

#### Test Case: ATP-001-A (Command reads artifact and produces correctly named review file)
**Linked Requirement:** REQ-001
**Description:** Verify the command reads a single V-Model artifact file and produces a peer review report markdown file named `peer-review-{artifact}.md` in the V-Model directory.
**Validation Condition:** `peer-review-requirements.md` exists in the V-Model directory after command execution with correct file naming.
**Expected Result:** File `peer-review-requirements.md` is created in the V-Model directory containing at least the review header and findings sections.

* **User Scenario: SCN-001-A1**
  * **Given** a V-Model directory containing `requirements.md` with REQ-001 through REQ-005
  * **When** the user runs the peer review command targeting `requirements.md`
  * **Then** a file named `peer-review-requirements.md` is created in the V-Model directory
  * **And** the file contains valid markdown with a review header section and findings section

#### Test Case: ATP-001-B (Output file name matches artifact base name for different artifact types)
**Linked Requirement:** REQ-001
**Description:** Verify the output file naming convention uses the base name of the reviewed artifact for each supported artifact type.
**Validation Condition:** Output file name matches `peer-review-{base-name}.md` for each tested artifact type.
**Expected Result:** Reviewing `system-design.md` produces `peer-review-system-design.md`; reviewing `hazard-analysis.md` produces `peer-review-hazard-analysis.md`.

* **User Scenario: SCN-001-B1**
  * **Given** a V-Model directory containing `system-design.md` with SYS-001 through SYS-003
  * **When** the user runs the peer review command targeting `system-design.md`
  * **Then** a file named `peer-review-system-design.md` is created in the V-Model directory

* **User Scenario: SCN-001-B2**
  * **Given** a V-Model directory containing `hazard-analysis.md` with HAZ-001 through HAZ-002
  * **When** the user runs the peer review command targeting `hazard-analysis.md`
  * **Then** a file named `peer-review-hazard-analysis.md` is created in the V-Model directory

---

### Requirement Validation: REQ-002 (AI-Powered Evaluation)

#### Test Case: ATP-002-A (AI evaluates prose quality, structural completeness, standards compliance, and cross-reference integrity)
**Linked Requirement:** REQ-002
**Description:** Verify the command uses AI evaluation to assess all four dimensions: prose quality, structural completeness, standards compliance, and cross-reference integrity.
**Validation Condition:** The review report contains findings that address at least one of each evaluation dimension.
**Expected Result:** The generated review file contains findings covering prose quality issues (e.g., ambiguous language), structural issues (e.g., missing sections), standards violations (e.g., non-compliant format), and cross-reference problems (e.g., broken ID references).

* **User Scenario: SCN-002-A1**
  * **Given** a V-Model directory containing a `requirements.md` file with REQ-001 containing subjective language ("the system should be fast"), REQ-002 missing a priority field, REQ-003 referencing a non-existent SYS-999, and a missing Assumptions section
  * **When** the user runs the peer review command targeting `requirements.md`
  * **Then** the review report contains at least one finding addressing prose quality (subjective language in REQ-001)
  * **And** at least one finding addressing structural completeness (missing section)
  * **And** at least one finding addressing cross-reference integrity (broken reference to SYS-999)

#### Test Case: ATP-002-B (AI evaluation is not replaceable by deterministic scripting)
**Linked Requirement:** REQ-002
**Description:** Verify the review identifies quality issues that require natural language understanding and cannot be detected by simple pattern matching.
**Validation Condition:** Review contains a finding about a requirement that is syntactically valid but semantically untestable.
**Expected Result:** A requirement like "The system SHALL be user-friendly" generates a finding about testability despite having correct markdown structure and a priority field.

* **User Scenario: SCN-002-B1**
  * **Given** a V-Model directory containing `requirements.md` with REQ-001 stating "The system SHALL be user-friendly" with priority P1, rationale, and verification method all properly filled
  * **When** the user runs the peer review command targeting `requirements.md`
  * **Then** the review report contains a finding identifying REQ-001 as untestable due to subjective language ("user-friendly")

---

### Requirement Validation: REQ-003 (Requirements Review — INCOSE Attributes)

#### Test Case: ATP-003-A (Evaluates each requirement against all INCOSE quality attributes)
**Linked Requirement:** REQ-003
**Description:** Verify the command evaluates requirements.md against INCOSE quality attributes: atomic, testable, unambiguous, complete, free of subjective language, and priority assigned.
**Validation Condition:** Review findings reference specific INCOSE attributes for each quality violation found.
**Expected Result:** Findings cite the specific INCOSE attribute violated (e.g., "not atomic", "ambiguous quantifier", "missing priority").

* **User Scenario: SCN-003-A1**
  * **Given** a V-Model directory containing `requirements.md` with REQ-001 combining two behaviors ("The system SHALL log in the user AND send a welcome email"), REQ-002 using an ambiguous quantifier ("The system SHALL respond quickly"), and REQ-003 missing a priority assignment
  * **When** the user runs the peer review command targeting `requirements.md`
  * **Then** the review report contains a finding for REQ-001 citing the "atomic" attribute violation
  * **And** a finding for REQ-002 citing the "unambiguous" or "testable" attribute violation
  * **And** a finding for REQ-003 citing the "priority assigned" attribute violation

#### Test Case: ATP-003-B (Clean requirements generate no Critical or Major findings)
**Linked Requirement:** REQ-003
**Description:** Verify that well-formed requirements satisfying all INCOSE attributes produce no Critical or Major findings.
**Validation Condition:** Summary table shows zero Critical and zero Major findings.
**Expected Result:** Review report summary table displays Critical: 0, Major: 0.

* **User Scenario: SCN-003-B1**
  * **Given** a V-Model directory containing `requirements.md` where every requirement is atomic, testable, unambiguous, complete, free of subjective language, and has a priority assigned
  * **When** the user runs the peer review command targeting `requirements.md`
  * **Then** the review report summary table shows Critical: 0 and Major: 0

---

### Requirement Validation: REQ-004 (System Design Review — IEEE 1016)

#### Test Case: ATP-004-A (Evaluates system-design.md against IEEE 1016 criteria)
**Linked Requirement:** REQ-004
**Description:** Verify the command evaluates system-design.md for all 4 design views present, every SYS component tracing to at least one REQ, interface contracts complete, and derived requirements flagged.
**Validation Condition:** Review findings reference IEEE 1016 criteria for each violation found.
**Expected Result:** Findings cite specific IEEE 1016 violations (e.g., "missing context view", "SYS-003 has no REQ trace", "incomplete interface contract").

* **User Scenario: SCN-004-A1**
  * **Given** a V-Model directory containing `system-design.md` with only 2 of 4 design views populated, SYS-003 having no reference to any REQ, and an interface contract missing the error response specification
  * **When** the user runs the peer review command targeting `system-design.md`
  * **Then** the review report contains a finding about missing design views
  * **And** a finding about SYS-003 lacking REQ traceability
  * **And** a finding about the incomplete interface contract

#### Test Case: ATP-004-B (Detects derived requirements not flagged)
**Linked Requirement:** REQ-004
**Description:** Verify the command detects SYS components that introduce new behavior not traceable to any REQ and flags them as derived requirements.
**Validation Condition:** Review contains a finding about an unflagged derived requirement.
**Expected Result:** A finding identifies SYS-005 as a potential derived requirement that lacks explicit flagging.

* **User Scenario: SCN-004-B1**
  * **Given** a V-Model directory containing `system-design.md` with SYS-005 describing caching behavior that is not referenced by any requirement in `requirements.md` and is not marked as a derived requirement
  * **When** the user runs the peer review command targeting `system-design.md`
  * **Then** the review report contains a finding identifying SYS-005 as an unflagged derived requirement

---

### Requirement Validation: REQ-005 (Architecture Design Review — IEEE 42010 / Kruchten 4+1)

#### Test Case: ATP-005-A (Evaluates architecture-design.md against 4+1 views criteria)
**Linked Requirement:** REQ-005
**Description:** Verify the command evaluates architecture-design.md for 4+1 views populated, CROSS-CUTTING modules justified, and interface definitions complete.
**Validation Condition:** Review findings reference IEEE 42010 / Kruchten 4+1 criteria.
**Expected Result:** Findings cite specific violations (e.g., "physical view missing", "CROSS-CUTTING module lacks justification").

* **User Scenario: SCN-005-A1**
  * **Given** a V-Model directory containing `architecture-design.md` with the physical view section empty, a CROSS-CUTTING module "Logging" with no justification text, and an interface definition missing the data format specification
  * **When** the user runs the peer review command targeting `architecture-design.md`
  * **Then** the review report contains a finding about the unpopulated physical view
  * **And** a finding about the unjustified CROSS-CUTTING module
  * **And** a finding about the incomplete interface definition

#### Test Case: ATP-005-B (Complete architecture generates no Critical findings)
**Linked Requirement:** REQ-005
**Description:** Verify that a well-formed architecture design with all views populated generates no Critical findings.
**Validation Condition:** Summary table shows zero Critical findings.
**Expected Result:** Review report summary table displays Critical: 0.

* **User Scenario: SCN-005-B1**
  * **Given** a V-Model directory containing `architecture-design.md` with all 4+1 views populated, all CROSS-CUTTING modules justified, and all interface definitions complete
  * **When** the user runs the peer review command targeting `architecture-design.md`
  * **Then** the review report summary table shows Critical: 0

---

### Requirement Validation: REQ-006 (System Test Review — ISO 29119)

#### Test Case: ATP-006-A (Evaluates system-test.md against ISO 29119 criteria)
**Linked Requirement:** REQ-006
**Description:** Verify the command evaluates system-test.md for named techniques used correctly, no user-journey language present, and test scenario independence maintained.
**Validation Condition:** Review findings reference ISO 29119 criteria for each violation found.
**Expected Result:** Findings cite specific violations (e.g., "unnamed technique", "user-journey language detected", "dependent test scenarios").

* **User Scenario: SCN-006-A1**
  * **Given** a V-Model directory containing `system-test.md` with STP-001 using an unnamed test technique (no technique label), STP-002 containing user-journey language ("As a user, I want to..."), and STP-003 depending on the state left by STP-002
  * **When** the user runs the peer review command targeting `system-test.md`
  * **Then** the review report contains a finding about the unnamed technique in STP-001
  * **And** a finding about user-journey language in STP-002
  * **And** a finding about test scenario dependence between STP-003 and STP-002

#### Test Case: ATP-006-B (Properly structured system tests pass review)
**Linked Requirement:** REQ-006
**Description:** Verify that system test artifacts using named techniques with independent scenarios and no user-journey language produce no Critical or Major findings.
**Validation Condition:** Summary table shows zero Critical and zero Major findings.
**Expected Result:** Review report summary table displays Critical: 0, Major: 0.

* **User Scenario: SCN-006-B1**
  * **Given** a V-Model directory containing `system-test.md` where every test scenario names its ISO 29119 technique, contains no user-journey language, and is independent of all other scenarios
  * **When** the user runs the peer review command targeting `system-test.md`
  * **Then** the review report summary table shows Critical: 0 and Major: 0

---

### Requirement Validation: REQ-007 (Integration Test Review — ISO 29119-4)

#### Test Case: ATP-007-A (Evaluates integration-test.md against ISO 29119-4 criteria)
**Linked Requirement:** REQ-007
**Description:** Verify the command evaluates integration-test.md for CDCT technique present, fault injection scenarios included, and interface coverage complete.
**Validation Condition:** Review findings reference ISO 29119-4 criteria for each violation found.
**Expected Result:** Findings cite specific violations (e.g., "CDCT technique missing", "no fault injection scenarios", "interface not covered").

* **User Scenario: SCN-007-A1**
  * **Given** a V-Model directory containing `integration-test.md` with no Consumer-Driven Contract Testing (CDCT) technique section, no fault injection scenarios, and the `ARCH-003` interface having no corresponding integration test
  * **When** the user runs the peer review command targeting `integration-test.md`
  * **Then** the review report contains a finding about the missing CDCT technique
  * **And** a finding about the absence of fault injection scenarios
  * **And** a finding about the uncovered ARCH-003 interface

#### Test Case: ATP-007-B (Complete integration tests pass review)
**Linked Requirement:** REQ-007
**Description:** Verify that integration test artifacts with CDCT technique, fault injection, and complete interface coverage produce no Critical findings.
**Validation Condition:** Summary table shows zero Critical findings.
**Expected Result:** Review report summary table displays Critical: 0.

* **User Scenario: SCN-007-B1**
  * **Given** a V-Model directory containing `integration-test.md` with CDCT technique present, fault injection scenarios included for all interfaces, and every ARCH interface covered by at least one integration test
  * **When** the user runs the peer review command targeting `integration-test.md`
  * **Then** the review report summary table shows Critical: 0

---

### Requirement Validation: REQ-008 (Module Design Review — DO-178C / ISO 26262)

#### Test Case: ATP-008-A (Evaluates module-design.md against DO-178C / ISO 26262 criteria)
**Linked Requirement:** REQ-008
**Description:** Verify the command evaluates module-design.md for 4 mandatory views present, algorithm specifications complete, and error handling defined.
**Validation Condition:** Review findings reference DO-178C / ISO 26262 criteria for each violation found.
**Expected Result:** Findings cite specific violations (e.g., "behavioral view missing", "algorithm specification incomplete for MOD-002", "error handling undefined for MOD-003").

* **User Scenario: SCN-008-A1**
  * **Given** a V-Model directory containing `module-design.md` with only 2 of 4 mandatory views present, MOD-002 missing its algorithm specification, and MOD-003 having no error handling definition
  * **When** the user runs the peer review command targeting `module-design.md`
  * **Then** the review report contains a finding about the missing mandatory views
  * **And** a finding about MOD-002's incomplete algorithm specification
  * **And** a finding about MOD-003's undefined error handling

#### Test Case: ATP-008-B (Complete module design passes review)
**Linked Requirement:** REQ-008
**Description:** Verify that a module design with all 4 views, complete algorithm specs, and defined error handling produces no Critical findings.
**Validation Condition:** Summary table shows zero Critical findings.
**Expected Result:** Review report summary table displays Critical: 0.

* **User Scenario: SCN-008-B1**
  * **Given** a V-Model directory containing `module-design.md` with all 4 mandatory views present, every module having a complete algorithm specification, and every module having defined error handling
  * **When** the user runs the peer review command targeting `module-design.md`
  * **Then** the review report summary table shows Critical: 0

---

### Requirement Validation: REQ-009 (Unit Test Review — ISO 29119-4)

#### Test Case: ATP-009-A (Evaluates unit-test.md against ISO 29119-4 criteria)
**Linked Requirement:** REQ-009
**Description:** Verify the command evaluates unit-test.md for 5 techniques present, mock registry complete, and boundary values explicit.
**Validation Condition:** Review findings reference ISO 29119-4 criteria for each violation found.
**Expected Result:** Findings cite specific violations (e.g., "only 3 of 5 techniques present", "mock registry incomplete", "boundary values not explicit for UTP-002").

* **User Scenario: SCN-009-A1**
  * **Given** a V-Model directory containing `unit-test.md` with only 3 of 5 required testing techniques documented, a mock registry missing the entry for the database adapter, and UTP-002 having no explicit boundary values
  * **When** the user runs the peer review command targeting `unit-test.md`
  * **Then** the review report contains a finding about the missing testing techniques
  * **And** a finding about the incomplete mock registry
  * **And** a finding about missing boundary values for UTP-002

#### Test Case: ATP-009-B (Complete unit tests pass review)
**Linked Requirement:** REQ-009
**Description:** Verify that unit test artifacts with all 5 techniques, complete mock registry, and explicit boundary values produce no Critical findings.
**Validation Condition:** Summary table shows zero Critical findings.
**Expected Result:** Review report summary table displays Critical: 0.

* **User Scenario: SCN-009-B1**
  * **Given** a V-Model directory containing `unit-test.md` with all 5 required techniques present, a complete mock registry, and explicit boundary values for all test procedures
  * **When** the user runs the peer review command targeting `unit-test.md`
  * **Then** the review report summary table shows Critical: 0

---

### Requirement Validation: REQ-010 (Hazard Analysis Review — ISO 14971 / ISO 26262)

#### Test Case: ATP-010-A (Evaluates hazard-analysis.md against ISO 14971 / ISO 26262 criteria)
**Linked Requirement:** REQ-010
**Description:** Verify the command evaluates hazard-analysis.md for severity classifications present for each hazard, every HAZ having a mitigation defined, operational state coverage present, and residual risk assessed.
**Validation Condition:** Review findings reference ISO 14971 / ISO 26262 criteria for each violation found.
**Expected Result:** Findings cite specific violations (e.g., "HAZ-002 missing severity classification", "HAZ-003 has no mitigation", "operational state coverage absent", "residual risk not assessed for HAZ-004").

* **User Scenario: SCN-010-A1**
  * **Given** a V-Model directory containing `hazard-analysis.md` with HAZ-002 missing its severity classification, HAZ-003 having no mitigation defined, no operational state coverage section, and HAZ-004 having no residual risk assessment
  * **When** the user runs the peer review command targeting `hazard-analysis.md`
  * **Then** the review report contains a finding about HAZ-002's missing severity classification
  * **And** a finding about HAZ-003's missing mitigation
  * **And** a finding about the absent operational state coverage
  * **And** a finding about HAZ-004's missing residual risk assessment

#### Test Case: ATP-010-B (Complete hazard analysis passes review)
**Linked Requirement:** REQ-010
**Description:** Verify that a hazard analysis with all severity classifications, mitigations, operational state coverage, and residual risk assessments produces no Critical findings.
**Validation Condition:** Summary table shows zero Critical findings.
**Expected Result:** Review report summary table displays Critical: 0.

* **User Scenario: SCN-010-B1**
  * **Given** a V-Model directory containing `hazard-analysis.md` where every HAZ has a severity classification, every HAZ has a defined mitigation, operational state coverage is present, and residual risk is assessed for all hazards
  * **When** the user runs the peer review command targeting `hazard-analysis.md`
  * **Then** the review report summary table shows Critical: 0

---

### Requirement Validation: REQ-011 (Acceptance Plan Review — ISO 29119)

#### Test Case: ATP-011-A (Evaluates acceptance-plan.md against ISO 29119 criteria)
**Linked Requirement:** REQ-011
**Description:** Verify the command evaluates acceptance-plan.md for BDD scenarios well-formed, validation conditions measurable, and coverage of parent REQs verified.
**Validation Condition:** Review findings reference ISO 29119 criteria for each violation found.
**Expected Result:** Findings cite specific violations (e.g., "SCN-003-A1 missing Given step", "ATP-002-A has unmeasurable validation condition", "REQ-004 has no ATP coverage").

* **User Scenario: SCN-011-A1**
  * **Given** a V-Model directory containing `acceptance-plan.md` with SCN-003-A1 missing a Given step, ATP-002-A having the validation condition "works correctly" (not measurable), and REQ-004 having no corresponding ATP
  * **When** the user runs the peer review command targeting `acceptance-plan.md`
  * **Then** the review report contains a finding about the malformed BDD scenario SCN-003-A1
  * **And** a finding about the unmeasurable validation condition in ATP-002-A
  * **And** a finding about the missing ATP coverage for REQ-004

#### Test Case: ATP-011-B (Well-formed acceptance plan passes review)
**Linked Requirement:** REQ-011
**Description:** Verify that an acceptance plan with well-formed BDD scenarios, measurable validation conditions, and 100% REQ coverage produces no Critical findings.
**Validation Condition:** Summary table shows zero Critical findings.
**Expected Result:** Review report summary table displays Critical: 0.

* **User Scenario: SCN-011-B1**
  * **Given** a V-Model directory containing `acceptance-plan.md` where every SCN has well-formed Given/When/Then steps, every ATP has a measurable validation condition, and every REQ has at least one ATP
  * **When** the user runs the peer review command targeting `acceptance-plan.md`
  * **Then** the review report summary table shows Critical: 0

---

### Requirement Validation: REQ-012 (PRF-{ARTIFACT}-NNN Finding ID Format)

#### Test Case: ATP-012-A (Findings use correct PRF ID pattern with proper artifact abbreviation)
**Linked Requirement:** REQ-012
**Description:** Verify each finding in the review report has a unique identifier using the pattern `PRF-{ARTIFACT}-NNN` with the correct artifact abbreviation and zero-padded sequential numbering starting at 001.
**Validation Condition:** All finding IDs in the report match the regex `PRF-[A-Z]+-[0-9]{3}` and use the correct abbreviation for the artifact type.
**Expected Result:** A requirements review produces findings with IDs like `PRF-REQ-001`, `PRF-REQ-002`; a system design review produces `PRF-SYS-001`, `PRF-SYS-002`.

* **User Scenario: SCN-012-A1**
  * **Given** a V-Model directory containing `requirements.md` with 3 requirements, each having at least one quality issue
  * **When** the user runs the peer review command targeting `requirements.md`
  * **Then** the review report contains findings with IDs `PRF-REQ-001`, `PRF-REQ-002`, and `PRF-REQ-003` (sequentially numbered, zero-padded)

* **User Scenario: SCN-012-A2**
  * **Given** a V-Model directory containing `system-design.md` with 2 quality issues
  * **When** the user runs the peer review command targeting `system-design.md`
  * **Then** the review report contains findings with IDs `PRF-SYS-001` and `PRF-SYS-002`

#### Test Case: ATP-012-B (Sequential numbering restarts at 001 per invocation)
**Linked Requirement:** REQ-012
**Description:** Verify that finding IDs start at 001 on each invocation and increment sequentially with no gaps.
**Validation Condition:** First finding is always NNN=001 and each subsequent finding increments by 1.
**Expected Result:** A review with 5 findings produces IDs PRF-REQ-001 through PRF-REQ-005 with no gaps.

* **User Scenario: SCN-012-B1**
  * **Given** a V-Model directory containing `requirements.md` with 5 quality issues
  * **When** the user runs the peer review command targeting `requirements.md`
  * **Then** the review report contains findings numbered PRF-REQ-001, PRF-REQ-002, PRF-REQ-003, PRF-REQ-004, PRF-REQ-005 with no gaps in the sequence

---

### Requirement Validation: REQ-013 (Severity Classification Set)

#### Test Case: ATP-013-A (Each finding has exactly one severity from the defined set)
**Linked Requirement:** REQ-013
**Description:** Verify every finding in the review report is classified with exactly one severity level from: Critical, Major, Minor, Observation.
**Validation Condition:** Every finding's severity field matches one of the four allowed values exactly.
**Expected Result:** All findings in the report have a severity of exactly "Critical", "Major", "Minor", or "Observation".

* **User Scenario: SCN-013-A1**
  * **Given** a V-Model directory containing `requirements.md` with quality issues of varying severity
  * **When** the user runs the peer review command targeting `requirements.md`
  * **Then** every finding in the review report has a severity field set to exactly one value from the set {Critical, Major, Minor, Observation}

#### Test Case: ATP-013-B (No finding has an unlisted or missing severity)
**Linked Requirement:** REQ-013
**Description:** Verify that no finding uses a severity value outside the defined set and no finding omits the severity field.
**Validation Condition:** Parsing all finding sections yields zero findings with non-standard or empty severity.
**Expected Result:** Zero findings with severity values like "High", "Low", "Warning", "Error", or empty severity fields.

* **User Scenario: SCN-013-B1**
  * **Given** a V-Model directory containing `requirements.md` with multiple quality issues
  * **When** the user runs the peer review command targeting `requirements.md`
  * **Then** parsing every finding section in the review confirms that no finding has a severity value outside {Critical, Major, Minor, Observation} and no finding has an empty severity field

---

### Requirement Validation: REQ-014 (Critical Severity Definition)

#### Test Case: ATP-014-A (Untestable requirement generates Critical finding)
**Linked Requirement:** REQ-014
**Description:** Verify that a fundamental quality violation such as an untestable requirement is classified as Critical.
**Validation Condition:** The finding referencing the untestable requirement has severity "Critical".
**Expected Result:** Finding for the untestable requirement is classified as Critical.

* **User Scenario: SCN-014-A1**
  * **Given** a V-Model directory containing `requirements.md` with REQ-001 stating "The system SHALL be intuitive" (untestable, subjective)
  * **When** the user runs the peer review command targeting `requirements.md`
  * **Then** the review report contains a finding referencing REQ-001 with severity "Critical"

#### Test Case: ATP-014-B (Missing mandatory view in design generates Critical finding)
**Linked Requirement:** REQ-014
**Description:** Verify that a missing mandatory view in a design artifact is classified as Critical because it blocks release.
**Validation Condition:** The finding referencing the missing view has severity "Critical".
**Expected Result:** Finding for the missing mandatory view is classified as Critical.

* **User Scenario: SCN-014-B1**
  * **Given** a V-Model directory containing `system-design.md` with only 1 of 4 mandatory design views present
  * **When** the user runs the peer review command targeting `system-design.md`
  * **Then** the review report contains a finding about missing mandatory design views with severity "Critical"

---

### Requirement Validation: REQ-015 (Major Severity Definition)

#### Test Case: ATP-015-A (Ambiguous quantifier generates Major finding)
**Linked Requirement:** REQ-015
**Description:** Verify that a quality issue like an ambiguous quantifier is classified as Major because it should be resolved before approval.
**Validation Condition:** The finding referencing the ambiguous quantifier has severity "Major".
**Expected Result:** Finding for the ambiguous quantifier is classified as Major.

* **User Scenario: SCN-015-A1**
  * **Given** a V-Model directory containing `requirements.md` with REQ-001 stating "The system SHALL respond in a reasonable time" (ambiguous quantifier "reasonable")
  * **When** the user runs the peer review command targeting `requirements.md`
  * **Then** the review report contains a finding referencing REQ-001 with severity "Major"

#### Test Case: ATP-015-B (Missing test technique generates Major finding)
**Linked Requirement:** REQ-015
**Description:** Verify that a missing test technique in a test artifact is classified as Major.
**Validation Condition:** The finding about the missing technique has severity "Major".
**Expected Result:** Finding for the missing test technique is classified as Major.

* **User Scenario: SCN-015-B1**
  * **Given** a V-Model directory containing `unit-test.md` with only 3 of 5 required ISO 29119-4 techniques present
  * **When** the user runs the peer review command targeting `unit-test.md`
  * **Then** the review report contains a finding about the missing test techniques with severity "Major"

---

### Requirement Validation: REQ-016 (Minor Severity Definition)

#### Test Case: ATP-016-A (Inconsistent formatting generates Minor finding)
**Linked Requirement:** REQ-016
**Description:** Verify that a style issue like inconsistent formatting is classified as Minor because it does not affect correctness.
**Validation Condition:** The finding about formatting inconsistency has severity "Minor".
**Expected Result:** Finding for the inconsistent formatting is classified as Minor.

* **User Scenario: SCN-016-A1**
  * **Given** a V-Model directory containing `requirements.md` where REQ-001 through REQ-003 use "SHALL" but REQ-004 uses "shall" (inconsistent capitalization)
  * **When** the user runs the peer review command targeting `requirements.md`
  * **Then** the review report contains a finding about inconsistent formatting with severity "Minor"

#### Test Case: ATP-016-B (Missing rationale on low-risk item generates Minor finding)
**Linked Requirement:** REQ-016
**Description:** Verify that a missing rationale on a low-risk item is classified as Minor.
**Validation Condition:** The finding about the missing rationale has severity "Minor".
**Expected Result:** Finding for the missing rationale on a low-risk item is classified as Minor.

* **User Scenario: SCN-016-B1**
  * **Given** a V-Model directory containing `requirements.md` with REQ-005 (P3 priority) having an empty rationale field
  * **When** the user runs the peer review command targeting `requirements.md`
  * **Then** the review report contains a finding about the missing rationale for REQ-005 with severity "Minor"

---

### Requirement Validation: REQ-017 (Observation Severity Definition)

#### Test Case: ATP-017-A (Improvement suggestion generates Observation finding)
**Linked Requirement:** REQ-017
**Description:** Verify that an informational suggestion that is not a defect is classified as Observation.
**Validation Condition:** The finding with an improvement suggestion has severity "Observation".
**Expected Result:** Finding for the suggestion is classified as Observation.

* **User Scenario: SCN-017-A1**
  * **Given** a V-Model directory containing `requirements.md` with all requirements meeting INCOSE quality attributes, but an alternative decomposition could improve modularity
  * **When** the user runs the peer review command targeting `requirements.md`
  * **Then** any finding suggesting an alternative decomposition strategy has severity "Observation"

#### Test Case: ATP-017-B (Observations do not block CI gate)
**Linked Requirement:** REQ-017
**Description:** Verify that Observation-level findings do not constitute defects and are treated equivalently to zero findings for CI exit code purposes.
**Validation Condition:** A review file containing only Observation findings produces exit code 0 from the check script.
**Expected Result:** `peer-review-check.sh` returns exit code 0.

* **User Scenario: SCN-017-B1**
  * **Given** a `peer-review-requirements.md` file containing exactly 2 findings, both with severity "Observation"
  * **When** the user runs `peer-review-check.sh peer-review-requirements.md`
  * **Then** the script exits with code 0

---

### Requirement Validation: REQ-018 (Report Header Section)

#### Test Case: ATP-018-A (Header contains all required fields)
**Linked Requirement:** REQ-018
**Description:** Verify the review report header includes reviewer identification, generation date, artifact file name, count of items in the artifact, and governing standard.
**Validation Condition:** All 5 header fields are present and non-empty in the report.
**Expected Result:** Header contains: Reviewer (e.g., "AI Peer Reviewer"), Date (ISO 8601 format), Artifact ("requirements.md"), Item Count (e.g., "15 requirements"), Governing Standard (e.g., "INCOSE Guide for Writing Requirements").

* **User Scenario: SCN-018-A1**
  * **Given** a V-Model directory containing `requirements.md` with 15 requirements
  * **When** the user runs the peer review command targeting `requirements.md`
  * **Then** the review report header contains a Reviewer field, a Date field in ISO 8601 format, Artifact field showing "requirements.md", Item Count showing "15", and Governing Standard referencing INCOSE

#### Test Case: ATP-018-B (Item count matches actual artifact items)
**Linked Requirement:** REQ-018
**Description:** Verify the item count in the header accurately reflects the number of items in the reviewed artifact.
**Validation Condition:** The header item count equals the actual count of items parsed from the artifact.
**Expected Result:** A `requirements.md` with 8 REQ items shows Item Count: 8 in the header.

* **User Scenario: SCN-018-B1**
  * **Given** a V-Model directory containing `requirements.md` with exactly 8 requirements (REQ-001 through REQ-008)
  * **When** the user runs the peer review command targeting `requirements.md`
  * **Then** the review report header shows an Item Count of 8

---

### Requirement Validation: REQ-019 (Summary Table with Severity Counts)

#### Test Case: ATP-019-A (Summary table displays counts for all four severity levels)
**Linked Requirement:** REQ-019
**Description:** Verify the review report includes a summary table showing finding counts for Critical, Major, Minor, and Observation severities.
**Validation Condition:** Summary table contains all four severity rows with numeric counts.
**Expected Result:** Summary table displays rows for Critical, Major, Minor, and Observation with integer counts (including 0).

* **User Scenario: SCN-019-A1**
  * **Given** a V-Model directory containing `requirements.md` with issues spanning multiple severity levels
  * **When** the user runs the peer review command targeting `requirements.md`
  * **Then** the review report contains a summary table with rows for Critical, Major, Minor, and Observation, each with a numeric count

#### Test Case: ATP-019-B (Summary table counts match actual findings in the report)
**Linked Requirement:** REQ-019
**Description:** Verify the counts in the summary table are consistent with the actual number of findings listed in the report body.
**Validation Condition:** Counting findings by severity in the report body matches the summary table values.
**Expected Result:** If the summary shows Critical: 1, Major: 2, Minor: 3, Observation: 1, then exactly 1 Critical, 2 Major, 3 Minor, and 1 Observation finding exist in the report body.

* **User Scenario: SCN-019-B1**
  * **Given** a V-Model directory containing `requirements.md` with known quality issues
  * **When** the user runs the peer review command targeting `requirements.md`
  * **Then** counting the individual findings by severity in the report body produces the same numbers as displayed in the summary table

---

### Requirement Validation: REQ-020 (Finding Subsection Fields)

#### Test Case: ATP-020-A (Each finding contains all five required fields)
**Linked Requirement:** REQ-020
**Description:** Verify every finding subsection includes PRF ID, Severity, Location (artifact item ID), Description, and Recommendation.
**Validation Condition:** Every finding in the report has all 5 fields present and non-empty.
**Expected Result:** Each finding contains: PRF ID (e.g., PRF-REQ-001), Severity (e.g., Major), Location (e.g., REQ-003), Description (prose text), and Recommendation (actionable text).

* **User Scenario: SCN-020-A1**
  * **Given** a V-Model directory containing `requirements.md` with at least 3 quality issues
  * **When** the user runs the peer review command targeting `requirements.md`
  * **Then** every finding in the review report contains a PRF ID field, a Severity field, a Location field referencing a specific REQ ID, a Description field, and a Recommendation field, all non-empty

#### Test Case: ATP-020-B (Location field references a specific artifact item ID)
**Linked Requirement:** REQ-020
**Description:** Verify the Location field in each finding references the specific artifact item ID where the issue was found, not a generic section or page reference.
**Validation Condition:** Location fields match existing artifact item IDs (e.g., REQ-003, SYS-002).
**Expected Result:** Finding locations reference specific IDs like REQ-003, not generic references like "Requirements section".

* **User Scenario: SCN-020-B1**
  * **Given** a V-Model directory containing `requirements.md` with REQ-003 having ambiguous language and REQ-007 missing a priority
  * **When** the user runs the peer review command targeting `requirements.md`
  * **Then** the finding about ambiguous language has Location field "REQ-003"
  * **And** the finding about missing priority has Location field "REQ-007"

---

### Requirement Validation: REQ-021 (Idempotent Regeneration)

#### Test Case: ATP-021-A (Re-running replaces the previous review file entirely)
**Linked Requirement:** REQ-021
**Description:** Verify the command regenerates the entire review file on each invocation, replacing any previously generated review for the same artifact.
**Validation Condition:** The review file content after re-run is a complete replacement, not an append.
**Expected Result:** Running the command twice on the same artifact produces a file with the same structure and finding count (assuming no artifact changes), not a doubled file.

* **User Scenario: SCN-021-A1**
  * **Given** a V-Model directory containing `requirements.md` and an existing `peer-review-requirements.md` from a previous invocation
  * **When** the user runs the peer review command targeting `requirements.md` again
  * **Then** the `peer-review-requirements.md` file is completely replaced (not appended to)
  * **And** the file contains exactly one review header section and one summary table

#### Test Case: ATP-021-B (Resolved findings disappear after fix and re-run)
**Linked Requirement:** REQ-021
**Description:** Verify that fixing an issue in the artifact and re-running the review causes the corresponding finding to disappear.
**Validation Condition:** The finding for the previously fixed issue is absent in the new review.
**Expected Result:** After fixing REQ-001's ambiguous language and re-running, no finding references REQ-001 for ambiguity; `git diff` shows the finding removed.

* **User Scenario: SCN-021-B1**
  * **Given** a V-Model directory containing `requirements.md` with REQ-001 having ambiguous language, and an existing `peer-review-requirements.md` containing a finding for REQ-001
  * **When** the user fixes REQ-001 to remove the ambiguous language and re-runs the peer review command
  * **Then** the regenerated `peer-review-requirements.md` does not contain a finding about ambiguous language in REQ-001

---

### Requirement Validation: REQ-022 (peer-review-check.sh Script Existence)

#### Test Case: ATP-022-A (Script exists and processes a review file)
**Linked Requirement:** REQ-022
**Description:** Verify the `peer-review-check.sh` Bash script exists and can read a `peer-review-{artifact}.md` file to return an exit code based on finding severities.
**Validation Condition:** Script file exists, is executable, and returns a valid exit code (0, 1, or 2) when given a valid review file.
**Expected Result:** `peer-review-check.sh` processes the review file and exits with code 0, 1, or 2.

* **User Scenario: SCN-022-A1**
  * **Given** a valid `peer-review-requirements.md` file containing findings of various severities
  * **When** the user runs `peer-review-check.sh peer-review-requirements.md`
  * **Then** the script exits with one of the valid exit codes: 0, 1, or 2

#### Test Case: ATP-022-B (Script handles missing or invalid review file)
**Linked Requirement:** REQ-022
**Description:** Verify the script produces a meaningful error when the specified review file does not exist or is not a valid peer review markdown.
**Validation Condition:** Script exits with a non-zero code and outputs an error message to stderr.
**Expected Result:** Script exits with a non-zero code and prints an error message indicating the file was not found or is invalid.

* **User Scenario: SCN-022-B1**
  * **Given** no `peer-review-requirements.md` file exists at the specified path
  * **When** the user runs `peer-review-check.sh nonexistent-file.md`
  * **Then** the script exits with a non-zero exit code and outputs an error message to stderr indicating the file was not found

---

### Requirement Validation: REQ-023 (Exit Code 0 — Clean or Observations Only)

#### Test Case: ATP-023-A (Zero findings review returns exit code 0)
**Linked Requirement:** REQ-023
**Description:** Verify the check script returns exit code 0 when the review file contains zero findings.
**Validation Condition:** Exit code is 0.
**Expected Result:** `peer-review-check.sh` exits with code 0.

* **User Scenario: SCN-023-A1**
  * **Given** a `peer-review-requirements.md` file with a summary table showing Critical: 0, Major: 0, Minor: 0, Observation: 0
  * **When** the user runs `peer-review-check.sh peer-review-requirements.md`
  * **Then** the script exits with code 0

#### Test Case: ATP-023-B (Observations-only review returns exit code 0)
**Linked Requirement:** REQ-023
**Description:** Verify the check script returns exit code 0 when the review file contains only Observation-level findings and no Critical, Major, or Minor findings.
**Validation Condition:** Exit code is 0 despite findings being present.
**Expected Result:** `peer-review-check.sh` exits with code 0.

* **User Scenario: SCN-023-B1**
  * **Given** a `peer-review-requirements.md` file with a summary table showing Critical: 0, Major: 0, Minor: 0, Observation: 3
  * **When** the user runs `peer-review-check.sh peer-review-requirements.md`
  * **Then** the script exits with code 0

---

### Requirement Validation: REQ-024 (Exit Code 1 — Critical or Major Findings)

#### Test Case: ATP-024-A (Critical finding returns exit code 1)
**Linked Requirement:** REQ-024
**Description:** Verify the check script returns exit code 1 when the review file contains at least one Critical finding.
**Validation Condition:** Exit code is 1.
**Expected Result:** `peer-review-check.sh` exits with code 1.

* **User Scenario: SCN-024-A1**
  * **Given** a `peer-review-requirements.md` file with a summary table showing Critical: 1, Major: 0, Minor: 2, Observation: 1
  * **When** the user runs `peer-review-check.sh peer-review-requirements.md`
  * **Then** the script exits with code 1

#### Test Case: ATP-024-B (Major finding without Critical also returns exit code 1)
**Linked Requirement:** REQ-024
**Description:** Verify the check script returns exit code 1 when the review file contains at least one Major finding even with zero Critical findings.
**Validation Condition:** Exit code is 1.
**Expected Result:** `peer-review-check.sh` exits with code 1.

* **User Scenario: SCN-024-B1**
  * **Given** a `peer-review-requirements.md` file with a summary table showing Critical: 0, Major: 2, Minor: 1, Observation: 0
  * **When** the user runs `peer-review-check.sh peer-review-requirements.md`
  * **Then** the script exits with code 1

---

### Requirement Validation: REQ-025 (Exit Code 2 — Minor Only)

#### Test Case: ATP-025-A (Minor-only review returns exit code 2)
**Linked Requirement:** REQ-025
**Description:** Verify the check script returns exit code 2 when the review file contains at least one Minor finding with zero Critical and zero Major findings.
**Validation Condition:** Exit code is 2.
**Expected Result:** `peer-review-check.sh` exits with code 2.

* **User Scenario: SCN-025-A1**
  * **Given** a `peer-review-requirements.md` file with a summary table showing Critical: 0, Major: 0, Minor: 3, Observation: 1
  * **When** the user runs `peer-review-check.sh peer-review-requirements.md`
  * **Then** the script exits with code 2

#### Test Case: ATP-025-B (Minor with Observation but no Critical/Major returns exit code 2)
**Linked Requirement:** REQ-025
**Description:** Verify exit code 2 when Minor findings coexist with Observations but no Critical or Major findings are present.
**Validation Condition:** Exit code is 2.
**Expected Result:** `peer-review-check.sh` exits with code 2.

* **User Scenario: SCN-025-B1**
  * **Given** a `peer-review-requirements.md` file with a summary table showing Critical: 0, Major: 0, Minor: 1, Observation: 5
  * **When** the user runs `peer-review-check.sh peer-review-requirements.md`
  * **Then** the script exits with code 2

---

### Requirement Validation: REQ-026 (Parsing Mechanism)

#### Test Case: ATP-026-A (Script parses summary table for severity counts)
**Linked Requirement:** REQ-026
**Description:** Verify the check script determines finding severities by parsing the summary table in the peer review markdown file.
**Validation Condition:** Exit code matches the severity distribution in the summary table.
**Expected Result:** A review file with summary table showing Critical: 0, Major: 0, Minor: 2 produces exit code 2; changing the summary to Critical: 1 produces exit code 1.

* **User Scenario: SCN-026-A1**
  * **Given** a `peer-review-requirements.md` file with a properly formatted summary table showing Critical: 0, Major: 0, Minor: 2, Observation: 0
  * **When** the user runs `peer-review-check.sh peer-review-requirements.md`
  * **Then** the script exits with code 2 (matching the Minor-only summary)

#### Test Case: ATP-026-B (Script parses individual finding headers as fallback)
**Linked Requirement:** REQ-026
**Description:** Verify the check script can parse individual finding headers to determine severities when the summary table or finding headers contain severity information.
**Validation Condition:** The script correctly identifies severities from individual finding sections.
**Expected Result:** Script correctly identifies a Critical finding from the finding section header and returns exit code 1.

* **User Scenario: SCN-026-B1**
  * **Given** a `peer-review-requirements.md` file with individual finding sections containing severity labels (e.g., "**Severity:** Critical" in PRF-REQ-001)
  * **When** the user runs `peer-review-check.sh peer-review-requirements.md`
  * **Then** the script exits with code 1 reflecting the Critical severity found in the finding section

---

### Requirement Validation: REQ-027 (--json Flag)

#### Test Case: ATP-027-A (--json outputs valid JSON with severity counts to stdout)
**Linked Requirement:** REQ-027
**Description:** Verify the `--json` flag causes the check script to output finding counts by severity as structured JSON to stdout.
**Validation Condition:** stdout contains valid JSON with keys for each severity level and integer values.
**Expected Result:** JSON output like `{"critical": 1, "major": 2, "minor": 3, "observation": 0}` is written to stdout.

* **User Scenario: SCN-027-A1**
  * **Given** a `peer-review-requirements.md` file with Critical: 1, Major: 2, Minor: 3, Observation: 0
  * **When** the user runs `peer-review-check.sh --json peer-review-requirements.md`
  * **Then** stdout contains valid JSON with "critical": 1, "major": 2, "minor": 3, "observation": 0

#### Test Case: ATP-027-B (--json output is parseable by standard JSON tools)
**Linked Requirement:** REQ-027
**Description:** Verify the JSON output can be parsed by standard tools (e.g., jq) without errors.
**Validation Condition:** Piping stdout through `jq .` succeeds with exit code 0.
**Expected Result:** `peer-review-check.sh --json <file> | jq .` exits with code 0 and produces formatted JSON.

* **User Scenario: SCN-027-B1**
  * **Given** a valid `peer-review-requirements.md` file
  * **When** the user runs `peer-review-check.sh --json peer-review-requirements.md | jq .`
  * **Then** jq exits with code 0 and outputs the formatted JSON to stdout

---

### Requirement Validation: REQ-028 (PowerShell Script Parity)

#### Test Case: ATP-028-A (peer-review-check.ps1 produces same exit codes as Bash script)
**Linked Requirement:** REQ-028
**Description:** Verify the PowerShell script accepts the same input and produces identical exit code semantics as the Bash script.
**Validation Condition:** Both scripts produce the same exit code for the same review file.
**Expected Result:** Given a review file with Critical: 1, both `peer-review-check.sh` and `peer-review-check.ps1` return exit code 1.

* **User Scenario: SCN-028-A1**
  * **Given** a `peer-review-requirements.md` file with a summary table showing Critical: 1, Major: 0, Minor: 0, Observation: 0
  * **When** running both `peer-review-check.sh peer-review-requirements.md` and `Peer-Review-Check.ps1 -ReviewFile peer-review-requirements.md`
  * **Then** both scripts exit with code 1

#### Test Case: ATP-028-B (--json output structure is identical between scripts)
**Linked Requirement:** REQ-028
**Description:** Verify the JSON output from the PowerShell script has the same structure and values as the Bash script for the same input.
**Validation Condition:** JSON outputs are structurally and value-identical.
**Expected Result:** Both scripts produce the same JSON keys and values.

* **User Scenario: SCN-028-B1**
  * **Given** a `peer-review-requirements.md` file with Critical: 0, Major: 1, Minor: 2, Observation: 1
  * **When** running both `peer-review-check.sh --json peer-review-requirements.md` and `Peer-Review-Check.ps1 -Json -ReviewFile peer-review-requirements.md`
  * **Then** both outputs contain identical JSON keys and values: "critical": 0, "major": 1, "minor": 2, "observation": 1

---

### Requirement Validation: REQ-029 (All 9 Artifact Types Accepted)

#### Test Case: ATP-029-A (Command accepts each of the 9 supported artifact types)
**Linked Requirement:** REQ-029
**Description:** Verify the command accepts any one of the 9 supported artifact types for review: requirements.md, system-design.md, architecture-design.md, system-test.md, integration-test.md, module-design.md, unit-test.md, hazard-analysis.md, acceptance-plan.md.
**Validation Condition:** Command successfully produces a review file for each artifact type.
**Expected Result:** Each artifact type produces a corresponding `peer-review-{artifact}.md` file with valid review content.

* **User Scenario: SCN-029-A1**
  * **Given** a V-Model directory containing `requirements.md` with at least one requirement
  * **When** the user runs the peer review command targeting `requirements.md`
  * **Then** the command completes successfully and produces `peer-review-requirements.md`

* **User Scenario: SCN-029-A2**
  * **Given** a V-Model directory containing `architecture-design.md` with at least one ARCH component
  * **When** the user runs the peer review command targeting `architecture-design.md`
  * **Then** the command completes successfully and produces `peer-review-architecture-design.md`

* **User Scenario: SCN-029-A3**
  * **Given** a V-Model directory containing `acceptance-plan.md` with at least one ATP
  * **When** the user runs the peer review command targeting `acceptance-plan.md`
  * **Then** the command completes successfully and produces `peer-review-acceptance-plan.md`

#### Test Case: ATP-029-B (Command operates without other V-Model artifacts present)
**Linked Requirement:** REQ-029
**Description:** Verify the command can review an artifact without requiring any other V-Model artifacts to be present in the directory.
**Validation Condition:** Command succeeds when only the target artifact exists in the V-Model directory.
**Expected Result:** Reviewing `requirements.md` succeeds even when no `system-design.md`, `acceptance-plan.md`, or other artifacts exist.

* **User Scenario: SCN-029-B1**
  * **Given** a V-Model directory containing only `requirements.md` and no other V-Model artifacts
  * **When** the user runs the peer review command targeting `requirements.md`
  * **Then** the command completes successfully and produces `peer-review-requirements.md` without errors about missing artifacts

---

### Requirement Validation: REQ-NF-001 (Stateless Operation)

#### Test Case: ATP-NF-001-A (Report contains no persistent status fields on findings)
**Linked Requirement:** REQ-NF-001
**Description:** Verify the review report contains no persistent status fields such as "Status: Open/Closed" on individual findings; the presence of a finding indicates a current problem.
**Validation Condition:** No finding section contains a "Status" field or equivalent persistence marker.
**Expected Result:** Parsing every finding section yields zero instances of fields like "Status:", "State:", "Resolution:", or "Open/Closed".

* **User Scenario: SCN-NF-001-A1**
  * **Given** a V-Model directory containing `requirements.md` with multiple quality issues
  * **When** the user runs the peer review command targeting `requirements.md`
  * **Then** no finding in the review report contains a "Status", "State", or "Resolution" field

#### Test Case: ATP-NF-001-B (Finding absence after re-run indicates resolution)
**Linked Requirement:** REQ-NF-001
**Description:** Verify the stateless model works correctly: fixing an issue and re-running causes the finding to disappear, confirming resolution through absence rather than status change.
**Validation Condition:** A finding present in run 1 is absent in run 2 after fixing the underlying issue.
**Expected Result:** After fixing REQ-003's ambiguity, re-running produces a review where PRF-REQ-NNN for that issue no longer exists.

* **User Scenario: SCN-NF-001-B1**
  * **Given** a `peer-review-requirements.md` containing finding PRF-REQ-002 about REQ-003's ambiguous language
  * **When** the user fixes REQ-003 to remove ambiguity and re-runs the peer review command targeting `requirements.md`
  * **Then** the regenerated review file does not contain any finding about ambiguous language in REQ-003

---

### Requirement Validation: REQ-NF-002 (Deterministic Check Scripts)

#### Test Case: ATP-NF-002-A (Same input produces same exit code on repeated runs)
**Linked Requirement:** REQ-NF-002
**Description:** Verify that running the check script multiple times on the same unchanged review file always produces the same exit code.
**Validation Condition:** Exit code is identical across 3 consecutive runs.
**Expected Result:** Running `peer-review-check.sh` 3 times on the same file produces the same exit code each time.

* **User Scenario: SCN-NF-002-A1**
  * **Given** a `peer-review-requirements.md` file with Critical: 0, Major: 1, Minor: 0, Observation: 0
  * **When** the user runs `peer-review-check.sh peer-review-requirements.md` three consecutive times without modifying the file
  * **Then** all three executions return exit code 1

#### Test Case: ATP-NF-002-B (Same input produces same JSON output on repeated runs)
**Linked Requirement:** REQ-NF-002
**Description:** Verify that running the check script with `--json` multiple times on the same unchanged review file always produces byte-identical JSON output.
**Validation Condition:** JSON output is identical across 3 consecutive runs.
**Expected Result:** All three `--json` outputs are byte-identical.

* **User Scenario: SCN-NF-002-B1**
  * **Given** a `peer-review-requirements.md` file with known severity counts
  * **When** the user runs `peer-review-check.sh --json peer-review-requirements.md` three consecutive times without modifying the file
  * **Then** all three JSON outputs are byte-identical

---

### Requirement Validation: REQ-IF-001 (Bash CLI Syntax)

#### Test Case: ATP-IF-001-A (Correct CLI syntax accepted)
**Linked Requirement:** REQ-IF-001
**Description:** Verify the script accepts the defined CLI syntax: `peer-review-check.sh [--json] <peer-review-file>`.
**Validation Condition:** Script processes the file and returns a valid exit code.
**Expected Result:** `peer-review-check.sh peer-review-requirements.md` succeeds; `peer-review-check.sh --json peer-review-requirements.md` succeeds.

* **User Scenario: SCN-IF-001-A1**
  * **Given** a valid `peer-review-requirements.md` file
  * **When** the user runs `peer-review-check.sh peer-review-requirements.md`
  * **Then** the script exits with a valid exit code (0, 1, or 2) and produces no syntax error

* **User Scenario: SCN-IF-001-A2**
  * **Given** a valid `peer-review-requirements.md` file
  * **When** the user runs `peer-review-check.sh --json peer-review-requirements.md`
  * **Then** the script exits with a valid exit code and outputs valid JSON to stdout

#### Test Case: ATP-IF-001-B (Invalid arguments produce error message)
**Linked Requirement:** REQ-IF-001
**Description:** Verify the script produces a meaningful error when called with no arguments or invalid flags.
**Validation Condition:** Script exits with non-zero code and outputs a usage message to stderr.
**Expected Result:** Running `peer-review-check.sh` with no arguments prints usage information and exits with a non-zero code.

* **User Scenario: SCN-IF-001-B1**
  * **Given** no arguments provided
  * **When** the user runs `peer-review-check.sh` with no arguments
  * **Then** the script exits with a non-zero exit code and outputs a usage message to stderr

---

### Requirement Validation: REQ-IF-002 (PowerShell CLI Syntax)

#### Test Case: ATP-IF-002-A (Correct PowerShell parameters accepted)
**Linked Requirement:** REQ-IF-002
**Description:** Verify the PowerShell script accepts the defined parameter syntax: `Peer-Review-Check.ps1 [-Json] -ReviewFile <path>`.
**Validation Condition:** Script processes the file and returns a valid exit code.
**Expected Result:** `Peer-Review-Check.ps1 -ReviewFile peer-review-requirements.md` succeeds; `Peer-Review-Check.ps1 -Json -ReviewFile peer-review-requirements.md` succeeds.

* **User Scenario: SCN-IF-002-A1**
  * **Given** a valid `peer-review-requirements.md` file
  * **When** the user runs `Peer-Review-Check.ps1 -ReviewFile peer-review-requirements.md`
  * **Then** the script exits with a valid exit code (0, 1, or 2) and produces no parameter error

* **User Scenario: SCN-IF-002-A2**
  * **Given** a valid `peer-review-requirements.md` file
  * **When** the user runs `Peer-Review-Check.ps1 -Json -ReviewFile peer-review-requirements.md`
  * **Then** the script exits with a valid exit code and outputs valid JSON to stdout

#### Test Case: ATP-IF-002-B (Missing required parameter produces error)
**Linked Requirement:** REQ-IF-002
**Description:** Verify the PowerShell script produces a meaningful error when the required `-ReviewFile` parameter is missing.
**Validation Condition:** Script exits with a non-zero code and outputs a parameter error.
**Expected Result:** Running `Peer-Review-Check.ps1` without `-ReviewFile` produces a parameter binding error.

* **User Scenario: SCN-IF-002-B1**
  * **Given** no `-ReviewFile` parameter provided
  * **When** the user runs `Peer-Review-Check.ps1` without the `-ReviewFile` parameter
  * **Then** the script exits with a non-zero exit code and outputs an error message about the missing required parameter

---

### Requirement Validation: REQ-CN-001 (Read-Only — No Artifact Modification)

#### Test Case: ATP-CN-001-A (Original artifact is unchanged after review)
**Linked Requirement:** REQ-CN-001
**Description:** Verify the command does not modify the original artifact being reviewed — it only produces a new review report file.
**Validation Condition:** File content and checksum of the original artifact are identical before and after command execution.
**Expected Result:** `requirements.md` has the same SHA-256 checksum before and after the peer review command runs.

* **User Scenario: SCN-CN-001-A1**
  * **Given** a V-Model directory containing `requirements.md` with a known SHA-256 checksum
  * **When** the user runs the peer review command targeting `requirements.md`
  * **Then** the SHA-256 checksum of `requirements.md` after the command is identical to the checksum before the command
  * **And** a new `peer-review-requirements.md` file exists in the directory

#### Test Case: ATP-CN-001-B (No other V-Model artifacts are modified)
**Linked Requirement:** REQ-CN-001
**Description:** Verify the command does not modify any other files in the V-Model directory besides creating the review report.
**Validation Condition:** Only the `peer-review-{artifact}.md` file is created or modified; all other files remain unchanged.
**Expected Result:** After running the peer review on `requirements.md`, only `peer-review-requirements.md` is created; `system-design.md`, `acceptance-plan.md`, and all other files retain their original checksums.

* **User Scenario: SCN-CN-001-B1**
  * **Given** a V-Model directory containing `requirements.md`, `system-design.md`, and `acceptance-plan.md` with known checksums
  * **When** the user runs the peer review command targeting `requirements.md`
  * **Then** `system-design.md` and `acceptance-plan.md` retain their original checksums
  * **And** only `peer-review-requirements.md` is created as a new file

---

### Requirement Validation: REQ-CN-002 (PRF IDs Not in Traceability Chain)

#### Test Case: ATP-CN-002-A (PRF IDs do not appear in trace matrices)
**Linked Requirement:** REQ-CN-002
**Description:** Verify that PRF finding IDs are not referenced by V-Model trace matrices or coverage metrics; they are advisory-only.
**Validation Condition:** Trace matrix file (if generated) contains zero references to PRF-prefixed IDs.
**Expected Result:** The traceability matrix references only REQ, SYS, ARCH, ATP, STP, ITP, MOD, UTP, SCN IDs and never PRF IDs.

* **User Scenario: SCN-CN-002-A1**
  * **Given** a V-Model directory containing a `peer-review-requirements.md` with findings PRF-REQ-001 through PRF-REQ-005 and a `trace-matrix.md`
  * **When** the user examines the trace matrix for PRF-prefixed IDs
  * **Then** the trace matrix contains zero references to any PRF-prefixed ID

#### Test Case: ATP-CN-002-B (Coverage metrics exclude PRF IDs)
**Linked Requirement:** REQ-CN-002
**Description:** Verify that coverage validation scripts do not count PRF IDs as part of the V-Model coverage chain.
**Validation Condition:** Running coverage validation does not include PRF IDs in coverage calculations.
**Expected Result:** Coverage metrics report only REQ→ATP, ATP→SCN, and similar V-Model chain metrics; PRF IDs are absent from coverage counts.

* **User Scenario: SCN-CN-002-B1**
  * **Given** a V-Model directory with `requirements.md`, `acceptance-plan.md`, and `peer-review-requirements.md` containing PRF findings
  * **When** the user runs the coverage validation script
  * **Then** the coverage output references only REQ, ATP, and SCN IDs and does not include any PRF IDs in the coverage calculation

---

### Requirement Validation: REQ-CN-003 (Single Artifact Per Invocation)

#### Test Case: ATP-CN-003-A (Command rejects multiple artifact files in a single invocation)
**Linked Requirement:** REQ-CN-003
**Description:** Verify the command accepts exactly one artifact per invocation and rejects attempts to review multiple artifacts simultaneously.
**Validation Condition:** Command produces an error when given more than one artifact file.
**Expected Result:** Providing two artifact file names produces an error message and no review file is generated.

* **User Scenario: SCN-CN-003-A1**
  * **Given** a V-Model directory containing `requirements.md` and `system-design.md`
  * **When** the user attempts to run the peer review command targeting both `requirements.md` and `system-design.md` in a single invocation
  * **Then** the command produces an error indicating that only one artifact may be reviewed per invocation
  * **And** no review file is generated

#### Test Case: ATP-CN-003-B (Single artifact invocation succeeds normally)
**Linked Requirement:** REQ-CN-003
**Description:** Verify the command succeeds when given exactly one artifact, confirming the constraint is about rejecting multiple inputs, not about single-input handling.
**Validation Condition:** Command succeeds with one artifact file.
**Expected Result:** Providing a single artifact file produces a successful review.

* **User Scenario: SCN-CN-003-B1**
  * **Given** a V-Model directory containing `requirements.md` and `system-design.md`
  * **When** the user runs the peer review command targeting only `requirements.md`
  * **Then** the command completes successfully and produces `peer-review-requirements.md`

---

### Requirement Validation: REQ-CN-004 (No Persistent Finding Store)

#### Test Case: ATP-CN-004-A (No database or persistent store files created by the command)
**Linked Requirement:** REQ-CN-004
**Description:** Verify the command does not create or maintain a database or any persistent store of past findings; the only output is the review markdown file.
**Validation Condition:** After command execution, no new database files, JSON stores, SQLite files, or similar persistence artifacts exist in the project directory.
**Expected Result:** Only `peer-review-{artifact}.md` is created; no `.db`, `.sqlite`, `.json` data stores, or hidden state files appear.

* **User Scenario: SCN-CN-004-A1**
  * **Given** a V-Model directory containing `requirements.md` and a known list of all existing files
  * **When** the user runs the peer review command targeting `requirements.md`
  * **Then** the only new file created is `peer-review-requirements.md`
  * **And** no `.db`, `.sqlite`, `.json` data store, or hidden state files are created in the project directory or V-Model directory

#### Test Case: ATP-CN-004-B (Git history serves as audit trail)
**Linked Requirement:** REQ-CN-004
**Description:** Verify that changes between review invocations are visible through standard `git diff`, confirming that git history serves as the audit trail for findings.
**Validation Condition:** `git diff` shows changes between two successive review files.
**Expected Result:** After committing a review, fixing an issue, and re-running, `git diff` shows the finding removed.

* **User Scenario: SCN-CN-004-B1**
  * **Given** a `peer-review-requirements.md` committed to git with finding PRF-REQ-001 about REQ-003
  * **When** the user fixes REQ-003, re-runs the peer review command, and runs `git diff peer-review-requirements.md`
  * **Then** `git diff` shows the removal of the PRF-REQ-001 finding section, providing an audit trail of the resolution

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Requirements | 37 |
| Total Test Cases (ATP) | 74 |
| Total Scenarios (SCN) | 80 |
| REQ → ATP Coverage | 100% |
| ATP → SCN Coverage | 100% |

**Validation Status**: ✅ Full Coverage
**Generated**: 2025-07-18
**Validated by**: `validate-requirement-coverage.sh` (deterministic)
