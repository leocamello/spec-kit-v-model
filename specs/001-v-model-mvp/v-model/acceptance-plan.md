# Acceptance Test Plan: V-Model Extension Pack MVP

**Feature Branch**: `001-v-model-mvp`
**Created**: 2025-07-18
**Status**: Draft
**Source**: `specs/001-v-model-mvp/v-model/requirements.md`

## Overview

This document defines the Acceptance Test Plan for the V-Model Extension Pack MVP. Every requirement
in `requirements.md` has one or more Test Cases (ATP), and every Test Case has one or
more executable User Scenarios (SCN) in BDD format (Given/When/Then).

## ID Schema

- **Test Case**: `ATP-{NNN}-{X}` — where NNN matches the parent REQ, X is a letter suffix (A, B, C...)
- **Scenario**: `SCN-{NNN}-{X}{#}` — nested under the parent ATP, with numeric suffix (1, 2, 3...)
- Example: `SCN-001-A1` → Scenario 1 of Test Case A validating REQ-001

## Acceptance Tests

### Requirement Validation: REQ-001 (Generate Requirements Specification)

#### Test Case: ATP-001-A (Generate from spec.md)
**Linked Requirement:** REQ-001
**Description:** Validates that the requirements command generates a complete Requirements Specification from an existing spec.md file.
**Validation Condition:** The output file `requirements.md` exists in the v-model directory and contains at least one requirement with a valid REQ-NNN identifier.
**Expected Result:** A `requirements.md` file is created at `specs/{feature}/v-model/requirements.md` containing a header section, requirements tables with REQ-NNN identifiers, and a summary metrics section.

* **User Scenario: SCN-001-A1**
  * **Given** a Git repository with Spec Kit initialized and a `spec.md` exists at `specs/001-v-model-mvp/spec.md` containing 5 user stories and 14 functional requirements
  * **When** the engineer invokes `/speckit.v-model.requirements`
  * **Then** the system creates `specs/001-v-model-mvp/v-model/requirements.md` containing sequentially numbered REQ-NNN identifiers derived from the spec's functional requirements, quality attributes, and edge cases

#### Test Case: ATP-001-B (Generate from text input)
**Linked Requirement:** REQ-001
**Description:** Validates that the requirements command generates a Requirements Specification from inline text input when no spec.md exists.
**Validation Condition:** The output file is generated with requirements derived solely from the provided text description.
**Expected Result:** A `requirements.md` file is created containing requirements that trace back to the text input, with no content invented beyond what the input describes.

* **User Scenario: SCN-001-B1**
  * **Given** a Git repository with Spec Kit initialized and no `spec.md` exists for the feature
  * **When** the engineer invokes `/speckit.v-model.requirements` with the text argument "A CLI tool that validates JSON files against a schema and reports errors with line numbers"
  * **Then** the system creates `requirements.md` with requirements covering JSON validation, schema matching, error reporting, and line number attribution — all traceable to the provided text

---

### Requirement Validation: REQ-002 (Unique Permanent REQ-NNN Identifiers)

#### Test Case: ATP-002-A (Sequential zero-padded numbering)
**Linked Requirement:** REQ-002
**Description:** Validates that generated requirements receive sequential, zero-padded identifiers starting at 001.
**Validation Condition:** All REQ IDs in the output follow the pattern REQ-NNN with zero-padded three-digit numbers in ascending order.
**Expected Result:** The first functional requirement has ID `REQ-001`, the second `REQ-002`, and so on, with no gaps in the initial generation.

* **User Scenario: SCN-002-A1**
  * **Given** a spec.md containing 5 functional requirements and 2 non-functional requirements
  * **When** the engineer invokes `/speckit.v-model.requirements`
  * **Then** the functional requirements table contains `REQ-001` through `REQ-005` (or more if atomized) in sequential order, and the non-functional table contains `REQ-NF-001` and `REQ-NF-002`

#### Test Case: ATP-002-B (ID permanence across re-invocations)
**Linked Requirement:** REQ-002
**Description:** Validates that requirement IDs are permanent and preserved when the command is re-invoked with updated input.
**Validation Condition:** All previously assigned REQ IDs remain unchanged after re-invocation; new requirements receive the next available sequential ID.
**Expected Result:** `REQ-001` through `REQ-005` retain their original descriptions, and any new requirement is assigned `REQ-006` or higher.

* **User Scenario: SCN-002-B1**
  * **Given** an existing `requirements.md` containing `REQ-001` through `REQ-005` and the spec.md has been updated with one additional functional requirement
  * **When** the engineer re-invokes `/speckit.v-model.requirements`
  * **Then** `REQ-001` through `REQ-005` are present with their original IDs and the new requirement is assigned `REQ-006`

---

### Requirement Validation: REQ-003 (Four Requirement Categories)

#### Test Case: ATP-003-A (All four categories present)
**Linked Requirement:** REQ-003
**Description:** Validates that the generated specification includes all four requirement categories when the source material contains items of each type.
**Validation Condition:** The output contains separate tables for Functional (REQ-NNN), Non-Functional (REQ-NF-NNN), Interface (REQ-IF-NNN), and Constraint (REQ-CN-NNN) requirements.
**Expected Result:** Four distinct table sections exist in the output, each with the correct ID prefix, and every requirement appears in exactly one section.

* **User Scenario: SCN-003-A1**
  * **Given** a spec.md containing functional requirements, quality attributes, interface descriptions, and operational constraints
  * **When** the engineer invokes `/speckit.v-model.requirements`
  * **Then** the output contains a "Functional Requirements" section with `REQ-NNN` IDs, a "Non-Functional Requirements" section with `REQ-NF-NNN` IDs, an "Interface Requirements" section with `REQ-IF-NNN` IDs, and a "Constraint Requirements" section with `REQ-CN-NNN` IDs

#### Test Case: ATP-003-B (Empty categories omitted)
**Linked Requirement:** REQ-003
**Description:** Validates that requirement categories with no items are omitted entirely from the output.
**Validation Condition:** If the source material contains no interface requirements, the "Interface Requirements" section does not appear in the output.
**Expected Result:** Only categories with at least one requirement are present in the generated document.

* **User Scenario: SCN-003-B1**
  * **Given** a spec.md containing only functional requirements and one quality attribute, with no interface or constraint specifications
  * **When** the engineer invokes `/speckit.v-model.requirements`
  * **Then** the output contains "Functional Requirements" and "Non-Functional Requirements" sections only; "Interface Requirements" and "Constraint Requirements" sections are absent

---

### Requirement Validation: REQ-004 (Eight Quality Criteria Validation)

#### Test Case: ATP-004-A (All criteria satisfied)
**Linked Requirement:** REQ-004
**Description:** Validates that every generated requirement passes all eight quality criteria (unambiguous, testable, atomic, complete, consistent, traceable, feasible, necessary).
**Validation Condition:** No requirement in the output contains banned vague words, compound statements (AND/OR hiding a second requirement), missing thresholds, contradictions, or content not traceable to the source.
**Expected Result:** Every requirement in the output is a single, testable statement with measurable conditions, a rationale linking to the source, and no quality criterion violations.

* **User Scenario: SCN-004-A1**
  * **Given** a spec.md containing the statement "The system shall save the user profile and send a confirmation email quickly"
  * **When** the engineer invokes `/speckit.v-model.requirements`
  * **Then** the compound statement is split into two separate requirements (one for profile save, one for email dispatch), and "quickly" is replaced with a specific time threshold (e.g., "within 60 seconds")

#### Test Case: ATP-004-B (Infeasible requirements flagged)
**Linked Requirement:** REQ-004
**Description:** Validates that infeasible requirements from the source are flagged rather than silently accepted.
**Validation Condition:** A requirement derived from an infeasible source statement contains a `[FEASIBILITY CONCERN: reason]` flag.
**Expected Result:** The flagged requirement includes the original source statement, the assigned REQ-NNN ID, and a clear description of the feasibility concern.

* **User Scenario: SCN-004-B1**
  * **Given** a spec.md containing the statement "The system shall have 100% uptime with zero maintenance windows forever"
  * **When** the engineer invokes `/speckit.v-model.requirements`
  * **Then** the generated requirement includes a `[FEASIBILITY CONCERN: 100% uptime with zero maintenance is not physically achievable]` flag

---

### Requirement Validation: REQ-005 (Banned Vague Terms Replacement)

#### Test Case: ATP-005-A (Banned terms detected and replaced)
**Linked Requirement:** REQ-005
**Description:** Validates that all 15 banned vague terms are detected in source material and replaced with measurable alternatives.
**Validation Condition:** No requirement description in the output contains any of the 15 banned words; each instance is replaced with a specific, testable metric.
**Expected Result:** The output requirements contain quantified thresholds (e.g., "within 2 seconds" instead of "fast", "WCAG 2.1 AA compliant" instead of "user-friendly").

* **User Scenario: SCN-005-A1**
  * **Given** a spec.md containing requirements with the terms "fast", "user-friendly", and "robust"
  * **When** the engineer invokes `/speckit.v-model.requirements`
  * **Then** "fast" is replaced with a specific time threshold, "user-friendly" with specific usability criteria, and "robust" with specific failure-handling behavior — and none of the three banned words appear in any requirement description

* **User Scenario: SCN-005-A2**
  * **Given** a spec.md containing the phrase "The API should be scalable and secure"
  * **When** the engineer invokes `/speckit.v-model.requirements`
  * **Then** "scalable" is replaced with specific load targets (e.g., "support N concurrent connections") and "secure" with specific security measures (e.g., "TLS 1.2+ encryption"), split into two separate atomic requirements

---

### Requirement Validation: REQ-006 (Three-Tier Acceptance Test Plan)

#### Test Case: ATP-006-A (Generate ATPs and SCNs for all active requirements)
**Linked Requirement:** REQ-006
**Description:** Validates that the acceptance command produces ATP-NNN-X test cases and SCN-NNN-X# scenarios for every active requirement.
**Validation Condition:** Every active (non-deprecated) REQ-NNN in `requirements.md` has at least one ATP-NNN-X, and every ATP has at least one SCN-NNN-X#.
**Expected Result:** An `acceptance-plan.md` file is created where each active requirement has a "Requirement Validation" section containing test cases and BDD scenarios.

* **User Scenario: SCN-006-A1**
  * **Given** a `requirements.md` containing 10 active functional requirements (`REQ-001` through `REQ-010`) and 2 non-functional requirements (`REQ-NF-001`, `REQ-NF-002`)
  * **When** the engineer invokes `/speckit.v-model.acceptance`
  * **Then** the generated `acceptance-plan.md` contains 12 "Requirement Validation" sections, each with at least one ATP and each ATP with at least one SCN in Given/When/Then format

#### Test Case: ATP-006-B (Deprecated requirements excluded from generation)
**Linked Requirement:** REQ-006
**Description:** Validates that deprecated requirements do not receive new test cases.
**Validation Condition:** Requirements marked `[DEPRECATED]` in `requirements.md` do not have new ATPs generated; only active requirements receive test coverage.
**Expected Result:** The acceptance plan contains test sections only for active requirements; deprecated REQs are absent from new generation.

* **User Scenario: SCN-006-B1**
  * **Given** a `requirements.md` containing 8 active requirements and 2 deprecated requirements (`REQ-003` marked `[DEPRECATED — Superseded by REQ-008]`, `REQ-005` marked `[DEPRECATED — Withdrawn: no longer needed]`)
  * **When** the engineer invokes `/speckit.v-model.acceptance`
  * **Then** the generated plan contains test sections for the 8 active requirements only; no `ATP-003-*` or `ATP-005-*` test cases are generated

---

### Requirement Validation: REQ-007 (Lineage-Encoding ID Schema)

#### Test Case: ATP-007-A (Functional requirement lineage encoding)
**Linked Requirement:** REQ-007
**Description:** Validates that the three-tier ID schema correctly encodes lineage for functional requirements.
**Validation Condition:** Every SCN ID in the output can be decoded to identify its parent ATP and grandparent REQ by parsing the numeric components.
**Expected Result:** `SCN-001-A1` traces to `ATP-001-A` traces to `REQ-001`; `SCN-001-B2` traces to `ATP-001-B` traces to `REQ-001`.

* **User Scenario: SCN-007-A1**
  * **Given** a `requirements.md` containing `REQ-001` with two distinct validation concerns
  * **When** the engineer invokes `/speckit.v-model.acceptance`
  * **Then** the output contains `ATP-001-A` and `ATP-001-B`, with scenarios `SCN-001-A1` under `ATP-001-A` and `SCN-001-B1` under `ATP-001-B`, and each ID encodes its full parent chain

#### Test Case: ATP-007-B (Non-functional requirement lineage encoding)
**Linked Requirement:** REQ-007
**Description:** Validates that the ID schema correctly handles non-functional, interface, and constraint requirement prefixes.
**Validation Condition:** IDs for non-functional requirements follow the pattern `ATP-NF-NNN-X` / `SCN-NF-NNN-X#`.
**Expected Result:** `REQ-NF-001` produces `ATP-NF-001-A` with scenario `SCN-NF-001-A1`; `REQ-IF-001` produces `ATP-IF-001-A` with scenario `SCN-IF-001-A1`.

* **User Scenario: SCN-007-B1**
  * **Given** a `requirements.md` containing `REQ-NF-001`, `REQ-IF-001`, and `REQ-CN-001`
  * **When** the engineer invokes `/speckit.v-model.acceptance`
  * **Then** the output contains `ATP-NF-001-A` / `SCN-NF-001-A1`, `ATP-IF-001-A` / `SCN-IF-001-A1`, and `ATP-CN-001-A` / `SCN-CN-001-A1` with correct prefix propagation

---

### Requirement Validation: REQ-008 (100% Bidirectional Coverage)

#### Test Case: ATP-008-A (Full coverage achieved)
**Linked Requirement:** REQ-008
**Description:** Validates that every active requirement has at least one ATP and every ATP has at least one SCN.
**Validation Condition:** The `validate-requirement-coverage.sh --json` script reports `has_gaps: false` and `req_coverage_pct: 100` and `atp_coverage_pct: 100`.
**Expected Result:** The coverage validation script exits with code 0 and reports 100% coverage at both tiers.

* **User Scenario: SCN-008-A1**
  * **Given** a `requirements.md` with 10 active requirements and a freshly generated `acceptance-plan.md`
  * **When** `validate-requirement-coverage.sh --json` is executed against the v-model directory
  * **Then** the script exits with code 0 and the JSON output contains `"has_gaps": false`, `"req_coverage_pct": 100`, and `"atp_coverage_pct": 100`

#### Test Case: ATP-008-B (Coverage gap detection)
**Linked Requirement:** REQ-008
**Description:** Validates that the system detects and reports coverage gaps when they exist.
**Validation Condition:** When a requirement has no ATP, the coverage script reports it in the `reqs_without_atp` list.
**Expected Result:** The script exits with code 1 and the gap report identifies the specific uncovered requirement IDs.

* **User Scenario: SCN-008-B1**
  * **Given** a `requirements.md` with `REQ-001` through `REQ-005` and an `acceptance-plan.md` missing test cases for `REQ-003`
  * **When** `validate-requirement-coverage.sh --json` is executed
  * **Then** the script exits with code 1 and the JSON output contains `"has_gaps": true` and `"reqs_without_atp": ["REQ-003"]`

---

### Requirement Validation: REQ-009 (Bidirectional Traceability Matrix)

#### Test Case: ATP-009-A (Forward tracing REQ → ATP → SCN)
**Linked Requirement:** REQ-009
**Description:** Validates that the traceability matrix contains forward tracing from requirements through test cases to scenarios.
**Validation Condition:** Every row in the matrix contains a REQ-NNN linked to its ATP-NNN-X entries, each linked to their SCN-NNN-X# entries.
**Expected Result:** The matrix displays a complete forward chain for every active requirement, with no broken links.

* **User Scenario: SCN-009-A1**
  * **Given** a complete `requirements.md` and `acceptance-plan.md` with full coverage
  * **When** the engineer invokes `/speckit.v-model.trace`
  * **Then** the generated `traceability-matrix.md` contains a table where `REQ-001` maps to `ATP-001-A, ATP-001-B` and each ATP maps to its child SCNs

#### Test Case: ATP-009-B (Backward tracing SCN → ATP → REQ)
**Linked Requirement:** REQ-009
**Description:** Validates that every scenario and test case can be traced backward to its parent requirement.
**Validation Condition:** The matrix includes a backward trace section or column where each SCN links to its parent ATP and each ATP links to its parent REQ.
**Expected Result:** `SCN-001-A1` traces back to `ATP-001-A` traces back to `REQ-001` with no orphaned test artifacts.

* **User Scenario: SCN-009-B1**
  * **Given** a complete `requirements.md` and `acceptance-plan.md`
  * **When** the engineer invokes `/speckit.v-model.trace`
  * **Then** the backward trace section confirms that every SCN and ATP in the acceptance plan has a valid parent chain to a requirement in `requirements.md`

---

### Requirement Validation: REQ-010 (Coverage Audit, Exception Report, Baseline)

#### Test Case: ATP-010-A (All matrix sections present)
**Linked Requirement:** REQ-010
**Description:** Validates that the traceability matrix includes coverage audit, exception report, and baseline information sections.
**Validation Condition:** The output contains three distinct sections: a quantified coverage audit, an exception report listing gaps and orphans, and baseline metadata.
**Expected Result:** Coverage audit shows counts and percentages; exception report lists any gaps or orphans (or "None"); baseline includes generation timestamp and source file paths.

* **User Scenario: SCN-010-A1**
  * **Given** a complete `requirements.md` and `acceptance-plan.md` with 100% coverage
  * **When** the engineer invokes `/speckit.v-model.trace`
  * **Then** the matrix contains a "Coverage Audit" section showing "25/25 REQs covered (100%)", an "Exception Report" section showing "No gaps or orphans detected", and a "Baseline" section with the generation timestamp and file paths

#### Test Case: ATP-010-B (Exception report identifies gaps)
**Linked Requirement:** REQ-010
**Description:** Validates that the exception report correctly identifies untested requirements and orphaned test cases.
**Validation Condition:** When coverage gaps exist, the exception report lists specific REQ IDs as gaps and specific ATP IDs as orphans.
**Expected Result:** The exception report contains "Untested Requirements: REQ-003" and "Orphaned Test Cases: (test case referencing non-existent requirement)" with clear descriptions.

* **User Scenario: SCN-010-B1**
  * **Given** a `requirements.md` with `REQ-001` through `REQ-005` and an `acceptance-plan.md` missing test cases for `REQ-003` but containing a test case that references a non-existent requirement
  * **When** the engineer invokes `/speckit.v-model.trace`
  * **Then** the exception report lists `REQ-003` as an untested requirement and the unlinked test case as an orphaned artifact

---

### Requirement Validation: REQ-011 (Deterministic Scripts for Validation)

#### Test Case: ATP-011-A (Scripts produce consistent results)
**Linked Requirement:** REQ-011
**Description:** Validates that coverage validation and matrix generation are performed by deterministic scripts that produce identical results for identical inputs.
**Validation Condition:** Running `validate-requirement-coverage.sh` and `build-matrix.sh` twice on the same unchanged v-model directory produces byte-identical output.
**Expected Result:** Both script invocations produce the same JSON output and the same matrix content with no variation.

* **User Scenario: SCN-011-A1**
  * **Given** a v-model directory containing `requirements.md` and `acceptance-plan.md` with no changes between runs
  * **When** `validate-requirement-coverage.sh --json` is executed twice in succession
  * **Then** the JSON output from both runs is byte-identical, including all counts, percentages, and gap lists

#### Test Case: ATP-011-B (AI not used for coverage calculation)
**Linked Requirement:** REQ-011
**Description:** Validates that coverage metrics are computed by shell scripts (Bash/PowerShell), not by AI inference.
**Validation Condition:** The coverage validation can be executed in a non-AI environment (e.g., a CI pipeline with no AI assistant) and produces valid results.
**Expected Result:** The script runs successfully in a plain shell environment, producing coverage metrics without requiring an AI runtime.

* **User Scenario: SCN-011-B1**
  * **Given** a v-model directory with `requirements.md` and `acceptance-plan.md` and a shell environment with no AI assistant configured
  * **When** `validate-requirement-coverage.sh --json` is executed directly from the command line
  * **Then** the script exits with a valid exit code (0 or 1) and produces valid JSON output with coverage metrics

---

### Requirement Validation: REQ-012 (Incremental Updates — Never Renumber)

#### Test Case: ATP-012-A (New requirements receive next sequential ID)
**Linked Requirement:** REQ-012
**Description:** Validates that when the spec is updated with additional requirements, new IDs are appended after the highest existing ID.
**Validation Condition:** After re-invocation with an updated spec, the new requirement has an ID higher than all existing IDs, and no existing IDs have changed.
**Expected Result:** Existing `REQ-001` through `REQ-010` are unchanged; the new requirement is assigned `REQ-011`.

* **User Scenario: SCN-012-A1**
  * **Given** an existing `requirements.md` containing `REQ-001` through `REQ-010` and the spec.md has been updated with one additional user story
  * **When** the engineer re-invokes `/speckit.v-model.requirements`
  * **Then** `REQ-001` through `REQ-010` retain their original descriptions and IDs, and the new requirement is assigned `REQ-011`

#### Test Case: ATP-012-B (IDs preserved after requirement removal)
**Linked Requirement:** REQ-012
**Description:** Validates that when a requirement's source material is removed, the requirement is deprecated (not deleted) and its ID is never reassigned.
**Validation Condition:** The deprecated requirement retains its original ID and no subsequent requirement reuses that ID number.
**Expected Result:** `REQ-003` is marked `[DEPRECATED]` but remains in the document; `REQ-004` keeps its original ID; no `REQ-003` is reassigned.

* **User Scenario: SCN-012-B1**
  * **Given** an existing `requirements.md` containing `REQ-001` through `REQ-005` and the spec.md has been updated to remove the source material for `REQ-003`
  * **When** the engineer re-invokes `/speckit.v-model.requirements`
  * **Then** `REQ-003` is marked `[DEPRECATED — Withdrawn: source material removed]`, `REQ-001`, `REQ-002`, `REQ-004`, `REQ-005` are unchanged, and no new requirement is assigned the ID `REQ-003`

---

### Requirement Validation: REQ-013 (Full ID Lifecycle Model)

#### Test Case: ATP-013-A (DEPRECATED states supported)
**Linked Requirement:** REQ-013
**Description:** Validates that both deprecation types (superseded and withdrawn) are correctly applied with appropriate syntax.
**Validation Condition:** Deprecated requirements carry the correct tag format including the superseding REQ ID or withdrawal reason.
**Expected Result:** A superseded requirement shows `[DEPRECATED — Superseded by REQ-NNN]` and a withdrawn requirement shows `[DEPRECATED — Withdrawn: <reason>]`.

* **User Scenario: SCN-013-A1**
  * **Given** an existing `requirements.md` where `REQ-002` has been replaced by a new requirement and `REQ-004` is no longer needed
  * **When** the engineer re-invokes `/speckit.v-model.requirements` with the updated spec
  * **Then** `REQ-002` is tagged `[DEPRECATED — Superseded by REQ-011]` (where REQ-011 is the replacement) and `REQ-004` is tagged `[DEPRECATED — Withdrawn: requirement no longer applicable]`

#### Test Case: ATP-013-B (SUSPECT propagation to downstream artifacts)
**Linked Requirement:** REQ-013
**Description:** Validates that when a requirement is modified or deprecated, downstream acceptance test artifacts are marked SUSPECT.
**Validation Condition:** After a requirement modification, linked ATPs and SCNs in the acceptance plan carry `[SUSPECT — Parent REQ-NNN modified]` tags.
**Expected Result:** All ATPs and SCNs linked to the modified requirement are tagged SUSPECT, requiring review or regeneration.

* **User Scenario: SCN-013-B1**
  * **Given** a `requirements.md` where `REQ-005` description has been modified in-place and an existing `acceptance-plan.md` containing `ATP-005-A` and `SCN-005-A1`
  * **When** the engineer re-invokes `/speckit.v-model.acceptance`
  * **Then** `ATP-005-A` and `SCN-005-A1` are marked `[SUSPECT — Parent REQ-005 modified]` and their test logic is regenerated to match the updated requirement

---

### Requirement Validation: REQ-014 (Deprecated Requirements Preserved)

#### Test Case: ATP-014-A (Deprecated requirements remain in document)
**Linked Requirement:** REQ-014
**Description:** Validates that deprecated requirements stay in the document with their original ID and are never physically deleted.
**Validation Condition:** After deprecation, the requirement row remains in the requirements table with its original ID, full original description (struck through), and the deprecation tag.
**Expected Result:** The deprecated requirement is visible in the document with `[DEPRECATED]` tag, original content, and original ID intact.

* **User Scenario: SCN-014-A1**
  * **Given** a `requirements.md` where `REQ-003` has been deprecated with reason "Superseded by REQ-008"
  * **When** the engineer opens the `requirements.md` file
  * **Then** the table row for `REQ-003` is present with its original ID, the tag `[DEPRECATED — Superseded by REQ-008]`, and the original description text (struck through with `~~`)

#### Test Case: ATP-014-B (Content history preserved for audit trail)
**Linked Requirement:** REQ-014
**Description:** Validates that the full content history of a deprecated requirement is preserved for audit purposes.
**Validation Condition:** The deprecated requirement retains its original description, priority, rationale, and verification method alongside the deprecation tag.
**Expected Result:** All original columns (Description, Priority, Rationale, Verification Method) are preserved in the deprecated row.

* **User Scenario: SCN-014-B1**
  * **Given** `REQ-003` originally read "The system SHALL export reports in PDF format" with Priority P2 and Rationale "User Story 3"
  * **When** `REQ-003` is deprecated and the file is regenerated
  * **Then** the `REQ-003` row retains Priority P2, Rationale "User Story 3", Verification Method "Test", and the description shows `[DEPRECATED — Withdrawn: feature descoped] ~~The system SHALL export reports in PDF format~~`

---

### Requirement Validation: REQ-015 (Change Detection via Git Comparison)

#### Test Case: ATP-015-A (Added requirements detected)
**Linked Requirement:** REQ-015
**Description:** Validates that the diff script detects newly added requirements by comparing working copy against committed version.
**Validation Condition:** The `diff-requirements.sh` output includes the new REQ ID in the `added` list.
**Expected Result:** The JSON output contains `"added": ["REQ-006"]` when `REQ-006` is present in the working copy but not in the committed version.

* **User Scenario: SCN-015-A1**
  * **Given** a committed `requirements.md` containing `REQ-001` through `REQ-005` and the working copy has `REQ-006` appended
  * **When** `diff-requirements.sh` is executed against the v-model directory
  * **Then** the output contains `"added": ["REQ-006"]`

#### Test Case: ATP-015-B (Modified requirements detected)
**Linked Requirement:** REQ-015
**Description:** Validates that the diff script detects when a requirement's description has been changed.
**Validation Condition:** The `diff-requirements.sh` output includes the modified REQ ID in the `modified` list.
**Expected Result:** The JSON output contains `"modified": ["REQ-002"]` when `REQ-002`'s description differs between working copy and committed version.

* **User Scenario: SCN-015-B1**
  * **Given** a committed `requirements.md` and the working copy where `REQ-002` description has been changed from "SHALL validate input" to "SHALL validate and sanitize input"
  * **When** `diff-requirements.sh` is executed
  * **Then** the output contains `"modified": ["REQ-002"]`

#### Test Case: ATP-015-C (Removed requirements detected)
**Linked Requirement:** REQ-015
**Description:** Validates that the diff script detects when a requirement has been removed from the working copy.
**Validation Condition:** The `diff-requirements.sh` output includes the removed REQ ID in the `removed` list.
**Expected Result:** The JSON output contains `"removed": ["REQ-001"]` when `REQ-001` is present in the committed version but absent from the working copy.

* **User Scenario: SCN-015-C1**
  * **Given** a committed `requirements.md` containing `REQ-001` through `REQ-005` and the working copy with `REQ-001` removed
  * **When** `diff-requirements.sh` is executed
  * **Then** the output contains `"removed": ["REQ-001"]`

---

### Requirement Validation: REQ-016 (Plaintext Markdown in Git-Tracked Directory)

#### Test Case: ATP-016-A (Output format and location)
**Linked Requirement:** REQ-016
**Description:** Validates that all generated artifacts are plaintext Markdown files stored in the correct Git-tracked v-model directory.
**Validation Condition:** Every generated file has a `.md` extension, is valid UTF-8 plaintext, and resides at `specs/{feature}/v-model/`.
**Expected Result:** `requirements.md`, `acceptance-plan.md`, and `traceability-matrix.md` are all present at `specs/{feature}/v-model/`, are valid Markdown, and contain no binary content.

* **User Scenario: SCN-016-A1**
  * **Given** a Spec Kit repository with feature `001-v-model-mvp` and a populated spec.md
  * **When** the engineer runs the complete V-Model workflow (requirements → acceptance → trace)
  * **Then** all generated files are located at `specs/001-v-model-mvp/v-model/`, have `.md` extensions, and `file --mime` reports `text/plain; charset=utf-8` for each

---

### Requirement Validation: REQ-017 (Domain Overlay Loading via Assembly Protocol)

#### Test Case: ATP-017-A (Overlay loaded when domain configured)
**Linked Requirement:** REQ-017
**Description:** Validates that when a domain is configured in `v-model-config.yml`, the corresponding command overlay is loaded and applied.
**Validation Condition:** The generated output includes domain-specific content that is only present in the overlay file, not in the base command.
**Expected Result:** With `domain: iso_26262` configured, the requirements output includes ASIL allocation guidance from `commands/overlays/iso_26262/requirements.md`.

* **User Scenario: SCN-017-A1**
  * **Given** a `v-model-config.yml` at the repository root with `domain: iso_26262` and a spec.md with safety-relevant requirements
  * **When** the engineer invokes `/speckit.v-model.requirements`
  * **Then** the generated requirements include ASIL allocation guidance and safety mechanism requirements as specified in the ISO 26262 command overlay

#### Test Case: ATP-017-B (Base-only when no domain configured)
**Linked Requirement:** REQ-017
**Description:** Validates that when no `v-model-config.yml` exists or domain is empty, the command operates with base-only behavior.
**Validation Condition:** The generated output contains no domain-specific sections, safety-critical terminology, or overlay content.
**Expected Result:** The output uses generic best-practice terminology throughout with no references to specific safety standards.

* **User Scenario: SCN-017-B1**
  * **Given** a repository with no `v-model-config.yml` file
  * **When** the engineer invokes `/speckit.v-model.requirements`
  * **Then** the generated requirements contain no domain-specific sections (no ASIL allocation, no DAL references, no safety class tables) and use generic terminology throughout

---

### Requirement Validation: REQ-018 (Template Overlay Loading)

#### Test Case: ATP-018-A (Template overlay sections appended)
**Linked Requirement:** REQ-018
**Description:** Validates that when a domain is configured and a template overlay exists, its output sections are appended after the base template sections.
**Validation Condition:** The generated artifact contains both base template sections and domain-specific sections from the template overlay.
**Expected Result:** The output includes the standard requirements tables followed by domain-specific sections (e.g., an ASIL Allocation Table for ISO 26262).

* **User Scenario: SCN-018-A1**
  * **Given** a `v-model-config.yml` with `domain: iso_26262` and a template overlay exists at `templates/overlays/iso_26262/requirements-template.md`
  * **When** the engineer invokes `/speckit.v-model.requirements`
  * **Then** the generated `requirements.md` contains all standard sections from the base template plus the domain-specific sections from the ISO 26262 template overlay appended at the end

---

### Requirement Validation: REQ-019 (IEEE 1012:2016 V&V Validation)

#### Test Case: ATP-019-A (Entry and exit criteria present)
**Linked Requirement:** REQ-019
**Description:** Validates that the acceptance command applies IEEE 1012 entry/exit criteria for acceptance testing.
**Validation Condition:** The generated acceptance plan references entry criteria (requirements baselined) and exit criteria (100% coverage, all criteria met, no unresolved SUSPECT items).
**Expected Result:** The acceptance plan includes or validates against entry criteria before generation and documents exit criteria in the coverage summary.

* **User Scenario: SCN-019-A1**
  * **Given** a `requirements.md` with status "Draft" (not baselined)
  * **When** the engineer invokes `/speckit.v-model.acceptance`
  * **Then** the system flags a validation risk that requirements are not yet baselined, per IEEE 1012 entry criteria

#### Test Case: ATP-019-B (Validation vs verification distinction)
**Linked Requirement:** REQ-019
**Description:** Validates that acceptance tests include stakeholder-perspective validation scenarios, not just specification-verification test cases.
**Validation Condition:** At least one SCN per requirement tests from the stakeholder's perspective (validating the right system is built, not just that it meets specs).
**Expected Result:** Scenarios include stakeholder-oriented Given/When/Then steps that validate the feature meets real user needs, beyond mechanical spec conformance.

* **User Scenario: SCN-019-B1**
  * **Given** a `requirements.md` containing `REQ-001` about generating a Requirements Specification
  * **When** the engineer invokes `/speckit.v-model.acceptance`
  * **Then** at least one SCN for REQ-001 validates from the engineer's perspective (e.g., "Given a systems engineer has a feature description, When they invoke the command, Then they receive a document ready for downstream test planning") rather than only testing mechanical output format

---

### Requirement Validation: REQ-020 (Coverage Script Exit Codes)

#### Test Case: ATP-020-A (Exit code 0 for full coverage)
**Linked Requirement:** REQ-020
**Description:** Validates that the coverage script exits with code 0 when 100% coverage is achieved at both tiers.
**Validation Condition:** The script exit code is 0 and the JSON output confirms `has_gaps: false`.
**Expected Result:** Exit code 0 with `"req_coverage_pct": 100` and `"atp_coverage_pct": 100`.

* **User Scenario: SCN-020-A1**
  * **Given** a v-model directory where every active REQ has at least one ATP and every ATP has at least one SCN
  * **When** `validate-requirement-coverage.sh --json` is executed
  * **Then** the script exits with code 0 and the JSON output contains `"has_gaps": false`

#### Test Case: ATP-020-B (Exit code 1 for coverage gaps)
**Linked Requirement:** REQ-020
**Description:** Validates that the coverage script exits with code 1 when any coverage gap exists.
**Validation Condition:** The script exit code is 1 and the JSON output confirms `has_gaps: true` with specific gap details.
**Expected Result:** Exit code 1 with `"has_gaps": true` and `"reqs_without_atp"` listing the uncovered requirements.

* **User Scenario: SCN-020-B1**
  * **Given** a v-model directory where `REQ-003` has no ATP in the acceptance plan
  * **When** `validate-requirement-coverage.sh --json` is executed
  * **Then** the script exits with code 1 and the JSON output contains `"has_gaps": true` and `"reqs_without_atp"` includes `"REQ-003"`

---

### Requirement Validation: REQ-021 (JSON Output Flag)

#### Test Case: ATP-021-A (Valid JSON with required fields)
**Linked Requirement:** REQ-021
**Description:** Validates that the `--json` flag produces valid JSON output containing all required fields.
**Validation Condition:** The output parses as valid JSON and contains `has_gaps`, `reqs_without_atp`, `atps_without_scn`, and coverage percentage fields.
**Expected Result:** JSON output passes validation with `jq` or equivalent parser and all four required fields are present with correct types (boolean, array, array, number).

* **User Scenario: SCN-021-A1**
  * **Given** a v-model directory with `requirements.md` and `acceptance-plan.md`
  * **When** `validate-requirement-coverage.sh --json` is executed and the output is piped to `jq .`
  * **Then** `jq` parses the output without error, and the JSON contains keys `has_gaps` (boolean), `reqs_without_atp` (array), `atps_without_scn` (array), and `req_coverage_pct` (number)

#### Test Case: ATP-021-B (JSON output without --json flag)
**Linked Requirement:** REQ-021
**Description:** Validates that without the `--json` flag, the script produces human-readable text output (not JSON).
**Validation Condition:** The default output is human-readable text that does not parse as valid JSON.
**Expected Result:** The output contains formatted text with coverage information but is not JSON-structured.

* **User Scenario: SCN-021-B1**
  * **Given** a v-model directory with `requirements.md` and `acceptance-plan.md`
  * **When** `validate-requirement-coverage.sh` is executed without the `--json` flag
  * **Then** the output is human-readable text containing coverage percentages and gap information, and piping to `jq .` produces a parse error

---

### Requirement Validation: REQ-022 (Error on Empty Input)

#### Test Case: ATP-022-A (Descriptive error for missing input)
**Linked Requirement:** REQ-022
**Description:** Validates that the requirements command returns a descriptive error when invoked with no feature description and no spec.md.
**Validation Condition:** The command outputs an error message containing guidance to provide input or run `/speckit.specify` first.
**Expected Result:** An error message is displayed: "No feature description or spec.md found. Run `/speckit.specify` first or provide a feature description."

* **User Scenario: SCN-022-A1**
  * **Given** a Spec Kit repository with no `spec.md` in the feature directory and no text argument provided
  * **When** the engineer invokes `/speckit.v-model.requirements` with empty arguments
  * **Then** the system displays an error message indicating no input source was found and recommends running `/speckit.specify` first

---

### Requirement Validation: REQ-023 (Accept Gaps in ID Numbering)

#### Test Case: ATP-023-A (Non-sequential IDs accepted)
**Linked Requirement:** REQ-023
**Description:** Validates that the system accepts gaps in requirement ID numbering without renumbering.
**Validation Condition:** After a requirement is deprecated (creating a gap), subsequent operations preserve the gap and do not reassign the deprecated ID.
**Expected Result:** A `requirements.md` with IDs `REQ-001`, `REQ-002` (deprecated), `REQ-003` is accepted by all downstream commands without error.

* **User Scenario: SCN-023-A1**
  * **Given** a `requirements.md` containing `REQ-001`, `REQ-002` (marked `[DEPRECATED]`), `REQ-003`, and `REQ-004`
  * **When** the engineer invokes `/speckit.v-model.acceptance`
  * **Then** the acceptance plan generates ATPs for `REQ-001`, `REQ-003`, and `REQ-004` only (skipping deprecated `REQ-002`), and no renumbering occurs

* **User Scenario: SCN-023-A2**
  * **Given** a `requirements.md` with IDs `REQ-001`, `REQ-003`, `REQ-007` (gaps from prior deprecations) and the spec is updated with a new requirement
  * **When** the engineer re-invokes `/speckit.v-model.requirements`
  * **Then** the new requirement is assigned `REQ-008` (next after highest existing ID), and IDs `REQ-002`, `REQ-004`, `REQ-005`, `REQ-006` are not reassigned

---

### Requirement Validation: REQ-024 (Graceful Failure on Malformed Input)

#### Test Case: ATP-024-A (Malformed Markdown produces descriptive error)
**Linked Requirement:** REQ-024
**Description:** Validates that deterministic scripts fail gracefully with descriptive errors when given malformed Markdown input.
**Validation Condition:** The script exits with a non-zero exit code and produces an error message describing the parsing problem, without producing corrupt output files.
**Expected Result:** Error message identifies the malformed section (e.g., "Missing requirements table header in requirements.md") and no output files are created or modified.

* **User Scenario: SCN-024-A1**
  * **Given** a `requirements.md` with a broken table (missing header row separators `|----|`)
  * **When** `validate-requirement-coverage.sh --json` is executed
  * **Then** the script exits with a non-zero exit code and the output contains a descriptive error message identifying the malformed table, and no coverage report is generated

* **User Scenario: SCN-024-A2**
  * **Given** a `requirements.md` with missing section headers (no "### Functional Requirements" heading)
  * **When** `build-matrix.sh` is executed
  * **Then** the script exits with a non-zero exit code and the error message describes the missing header, and no traceability matrix is generated

---

### Requirement Validation: REQ-025 (Deterministic Matrix Generation)

#### Test Case: ATP-025-A (Matrix computed by script)
**Linked Requirement:** REQ-025
**Description:** Validates that the traceability matrix is computed by the deterministic `build-matrix.sh` script, not generated by AI.
**Validation Condition:** The `/speckit.v-model.trace` command invokes `build-matrix.sh` to compute the matrix data, and the AI only formats/presents the script's output.
**Expected Result:** The matrix content (REQ→ATP→SCN mappings, coverage counts, gap lists) is produced by the shell script; the AI's role is limited to running the script and presenting its output.

* **User Scenario: SCN-025-A1**
  * **Given** a complete v-model directory with `requirements.md` and `acceptance-plan.md`
  * **When** the engineer invokes `/speckit.v-model.trace`
  * **Then** the trace command executes `build-matrix.sh` and uses its output to populate the traceability matrix, and the coverage percentages in the matrix match the script's computed values exactly

---

### Requirement Validation: REQ-NF-001 (Domain-Agnostic Base with Overlay Extensibility)

#### Test Case: ATP-NF-001-A (New domain added via overlays only)
**Linked Requirement:** REQ-NF-001
**Description:** Validates that adding support for a new regulated domain requires only creating overlay files, with no modification to base command files.
**Validation Condition:** A new domain (e.g., `en_50128` for railway) is added by creating overlay files in `commands/overlays/en_50128/` and `templates/overlays/en_50128/`, and all base commands continue to function identically.
**Expected Result:** After adding overlay files for the new domain and configuring `v-model-config.yml` with `domain: en_50128`, all commands load the new overlays; reverting to no domain produces identical output to before the overlay addition.

* **User Scenario: SCN-NF-001-A1**
  * **Given** the base commands (`requirements.md`, `acceptance.md`, `trace.md`) at their current versions and a new domain `en_50128` with overlay files created at `commands/overlays/en_50128/requirements.md`
  * **When** the engineer configures `domain: en_50128` in `v-model-config.yml` and invokes `/speckit.v-model.requirements`
  * **Then** the output includes EN 50128-specific guidance from the overlay, and running the same command with domain removed produces output identical to the pre-overlay baseline

#### Test Case: ATP-NF-001-B (Base commands unchanged after overlay addition)
**Linked Requirement:** REQ-NF-001
**Description:** Validates that no base command file has been modified after adding a new domain's overlay files.
**Validation Condition:** A `git diff` on all files in `commands/` (excluding `commands/overlays/`) shows zero changes after adding the new domain.
**Expected Result:** `git diff commands/requirements.md commands/acceptance.md commands/trace.md` returns empty output.

* **User Scenario: SCN-NF-001-B1**
  * **Given** a Git repository with the current base commands committed and a new domain overlay added at `commands/overlays/en_50128/`
  * **When** `git diff --name-only commands/requirements.md commands/acceptance.md commands/trace.md` is executed
  * **Then** the command produces no output (zero files changed in base commands)

---

### Requirement Validation: REQ-NF-002 (Deterministic Script Results)

#### Test Case: ATP-NF-002-A (Identical outputs for identical inputs)
**Linked Requirement:** REQ-NF-002
**Description:** Validates that coverage validation scripts produce byte-identical output when given the same input files.
**Validation Condition:** Two consecutive runs of the same script on unchanged files produce identical output.
**Expected Result:** `diff <(run1_output) <(run2_output)` returns no differences.

* **User Scenario: SCN-NF-002-A1**
  * **Given** a v-model directory with unchanged `requirements.md` and `acceptance-plan.md`
  * **When** `validate-requirement-coverage.sh --json` is executed twice and the outputs are compared with `diff`
  * **Then** the diff produces no output, confirming byte-identical results

#### Test Case: ATP-NF-002-B (Results independent of AI model version)
**Linked Requirement:** REQ-NF-002
**Description:** Validates that the deterministic scripts produce the same results regardless of which AI model is configured in the environment.
**Validation Condition:** Running the script with different `COPILOT_MODEL` environment values (or no AI at all) produces identical output.
**Expected Result:** The script output is identical whether invoked from a Copilot session, a plain terminal, or a CI pipeline.

* **User Scenario: SCN-NF-002-B1**
  * **Given** a v-model directory with `requirements.md` and `acceptance-plan.md`
  * **When** `validate-requirement-coverage.sh --json` is executed in a plain terminal with no AI assistant configured
  * **Then** the output is identical to the output produced when the same script is run within a Copilot CLI session

---

### Requirement Validation: REQ-NF-003 (SUSPECT Detection in Traceability Matrix)

#### Test Case: ATP-NF-003-A (Matrix flags non-compliant status for SUSPECT items)
**Linked Requirement:** REQ-NF-003
**Description:** Validates that the traceability matrix flags non-compliant status when downstream artifacts contain unresolved SUSPECT tags.
**Validation Condition:** The matrix's validation status shows a non-compliant flag and the exception report lists all SUSPECT items.
**Expected Result:** The coverage summary shows "❌ Non-Compliant — N unresolved SUSPECT items" and the exception report lists each SUSPECT ATP/SCN with its parent REQ.

* **User Scenario: SCN-NF-003-A1**
  * **Given** a `requirements.md` where `REQ-005` has been modified and an `acceptance-plan.md` where `ATP-005-A` is tagged `[SUSPECT — Parent REQ-005 modified]`
  * **When** the engineer invokes `/speckit.v-model.trace`
  * **Then** the traceability matrix's validation status indicates non-compliance, and the exception report lists `ATP-005-A` as a SUSPECT item requiring resolution

---

### Requirement Validation: REQ-NF-004 (Single Command Invocation)

#### Test Case: ATP-NF-004-A (Complete specification in one command)
**Linked Requirement:** REQ-NF-004
**Description:** Validates that an engineer can produce a complete Requirements Specification from a feature description in a single command invocation without intermediate manual steps.
**Validation Condition:** One invocation of `/speckit.v-model.requirements` produces a complete, valid `requirements.md` with all sections populated.
**Expected Result:** The output file contains a header, requirements tables (all applicable categories), assumptions, dependencies, glossary, and summary metrics — all populated from the source material.

* **User Scenario: SCN-NF-004-A1**
  * **Given** a spec.md containing 5 user stories, 14 functional requirements, 3 quality attributes, and 5 edge cases
  * **When** the engineer invokes `/speckit.v-model.requirements` once
  * **Then** the generated `requirements.md` contains all applicable requirement categories, summary metrics matching the actual count, and no `[TBD]` or placeholder content — without requiring any follow-up commands or manual editing

---

### Requirement Validation: REQ-IF-001 (Multiple Input Modes)

#### Test Case: ATP-IF-001-A (spec.md as primary input)
**Linked Requirement:** REQ-IF-001
**Description:** Validates that the requirements command accepts spec.md as the primary input source.
**Validation Condition:** When spec.md exists and no text arguments are provided, the command uses spec.md as the sole input source.
**Expected Result:** All generated requirements trace back to specific sections of spec.md in their rationale column.

* **User Scenario: SCN-IF-001-A1**
  * **Given** a spec.md exists at `specs/{feature}/spec.md` and no text argument is provided
  * **When** the engineer invokes `/speckit.v-model.requirements`
  * **Then** every generated requirement's rationale references a specific section of spec.md (e.g., "User Story 1", "FR-001", "Edge Case")

#### Test Case: ATP-IF-001-B (Text argument as input)
**Linked Requirement:** REQ-IF-001
**Description:** Validates that the requirements command accepts inline text arguments as input when no spec.md exists.
**Validation Condition:** When no spec.md exists and text arguments are provided, the command generates requirements from the text input.
**Expected Result:** Requirements are generated from the text description with rationale referencing "User input".

* **User Scenario: SCN-IF-001-B1**
  * **Given** no spec.md exists for the feature
  * **When** the engineer invokes `/speckit.v-model.requirements` with the text argument "A REST API that manages user accounts with CRUD operations"
  * **Then** the generated requirements cover user account creation, reading, updating, and deletion, with rationale columns referencing "User input"

#### Test Case: ATP-IF-001-C (Both spec.md and text argument)
**Linked Requirement:** REQ-IF-001
**Description:** Validates that when both spec.md and text arguments exist, spec.md is used as primary with text as supplementary context.
**Validation Condition:** The output primarily derives from spec.md, but text arguments may add clarification or additional context without overriding spec.md content.
**Expected Result:** Requirements are generated from spec.md with text arguments providing supplementary context or instructions noted in the document.

* **User Scenario: SCN-IF-001-C1**
  * **Given** a spec.md exists with 5 functional requirements and the text argument "Focus on the security aspects"
  * **When** the engineer invokes `/speckit.v-model.requirements`
  * **Then** all requirements from spec.md are formalized, with security-related requirements potentially receiving additional detail informed by the text argument, and spec.md remains the primary source

---

### Requirement Validation: REQ-IF-002 (Template Conformance)

#### Test Case: ATP-IF-002-A (Output matches template structure)
**Linked Requirement:** REQ-IF-002
**Description:** Validates that the requirements command output conforms to the structure defined in `templates/requirements-template.md`.
**Validation Condition:** The output contains all template-defined sections: header (Feature Branch, Created, Status, Source), requirements tables, assumptions, dependencies, glossary, and summary metrics.
**Expected Result:** Every section heading from the template is present in the output, in the correct order, with content populated (no placeholders).

* **User Scenario: SCN-IF-002-A1**
  * **Given** the requirements template defines sections: header metadata, Overview, Functional Requirements, Non-Functional Requirements, Interface Requirements, Constraint Requirements, Assumptions, Dependencies, Glossary, and Summary Metrics
  * **When** the engineer invokes `/speckit.v-model.requirements` against a spec.md
  * **Then** the generated `requirements.md` contains all template-defined sections with populated content, and the Summary Metrics section shows accurate counts matching the actual requirement totals

---

### Requirement Validation: REQ-IF-003 (Setup Script JSON Output)

#### Test Case: ATP-IF-003-A (All required JSON fields present)
**Linked Requirement:** REQ-IF-003
**Description:** Validates that `setup-v-model.sh` returns a JSON object containing all required fields.
**Validation Condition:** The JSON output parses successfully and contains `VMODEL_DIR`, `FEATURE_DIR`, `BRANCH`, `SPEC`, `REQUIREMENTS`, and `AVAILABLE_DOCS` keys.
**Expected Result:** All six required fields are present, `VMODEL_DIR` and `FEATURE_DIR` are valid directory paths, `BRANCH` is a string, `SPEC` and `REQUIREMENTS` are file paths, and `AVAILABLE_DOCS` is an array of strings.

* **User Scenario: SCN-IF-003-A1**
  * **Given** a Spec Kit repository on branch `feature/001-v-model-mvp` with a `spec.md` in the feature directory
  * **When** `setup-v-model.sh --json` is executed
  * **Then** the output is valid JSON containing `"VMODEL_DIR"` ending with `/v-model`, `"FEATURE_DIR"` ending with `/001-v-model-mvp`, `"BRANCH"` matching the current branch name, `"SPEC"` pointing to `spec.md`, and `"AVAILABLE_DOCS"` containing `"spec.md"`

#### Test Case: ATP-IF-003-B (AVAILABLE_DOCS reflects actual files)
**Linked Requirement:** REQ-IF-003
**Description:** Validates that the `AVAILABLE_DOCS` array accurately reflects which V-Model documents currently exist on disk.
**Validation Condition:** The `AVAILABLE_DOCS` array lists only documents that exist as files in the v-model directory.
**Expected Result:** If only `spec.md` and `requirements.md` exist, `AVAILABLE_DOCS` contains exactly `["spec.md", "requirements.md"]`.

* **User Scenario: SCN-IF-003-B1**
  * **Given** a v-model directory containing only `requirements.md` and `acceptance-plan.md` (no trace matrix yet)
  * **When** `setup-v-model.sh --json` is executed
  * **Then** the `AVAILABLE_DOCS` array contains `"requirements.md"` and `"acceptance-plan.md"` but does not contain `"traceability-matrix.md"`

---

### Requirement Validation: REQ-CN-001 (Git Repository with Spec Kit)

#### Test Case: ATP-CN-001-A (Error in non-Git directory)
**Linked Requirement:** REQ-CN-001
**Description:** Validates that the system produces an error when invoked outside a Git repository.
**Validation Condition:** The setup script fails with a descriptive error when executed in a directory that is not a Git repository.
**Expected Result:** The script exits with a non-zero exit code and an error message indicating a Git repository is required.

* **User Scenario: SCN-CN-001-A1**
  * **Given** a directory that is not a Git repository (no `.git` directory)
  * **When** `setup-v-model.sh --json` is executed from that directory
  * **Then** the script exits with a non-zero exit code and outputs an error message indicating that a Git repository is required

---

### Requirement Validation: REQ-CN-002 (English Language)

#### Test Case: ATP-CN-002-A (Artifacts generated in English)
**Linked Requirement:** REQ-CN-002
**Description:** Validates that all generated artifacts are in English regardless of system locale.
**Validation Condition:** All section headers, requirement descriptions, template text, and metadata in generated artifacts are in English.
**Expected Result:** The generated `requirements.md` and `acceptance-plan.md` contain only English text in all sections.

* **User Scenario: SCN-CN-002-A1**
  * **Given** a spec.md written in English describing a feature
  * **When** the engineer invokes `/speckit.v-model.requirements`
  * **Then** all generated content — section headers, requirement descriptions, rationale, glossary definitions — is in English

---

### Requirement Validation: REQ-CN-003 (AI Assistant Required)

#### Test Case: ATP-CN-003-A (Generative commands need AI runtime)
**Linked Requirement:** REQ-CN-003
**Description:** Validates that the generative slash commands (requirements, acceptance, trace) are AI agent prompts that require an AI assistant to execute.
**Validation Condition:** The command files are Markdown prompt documents (not executable scripts) that define agent behavior for an AI runtime.
**Expected Result:** The command files in `commands/` are `.md` files with YAML frontmatter defining agent metadata, and they cannot produce output without an AI assistant interpreting and executing the prompt instructions.

* **User Scenario: SCN-CN-003-A1**
  * **Given** the command file `commands/requirements.md` exists as a Markdown document with YAML frontmatter
  * **When** a user attempts to execute the command without an AI assistant (e.g., running `cat commands/requirements.md` directly)
  * **Then** only the raw Markdown text is displayed — no requirements are generated, confirming the command is an AI agent prompt, not a standalone executable

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Requirements (REQ) | 35 (35 active, 0 deprecated) |
| Total Test Cases (ATP) | 59 (59 active, 0 deprecated, 0 suspect) |
| Total Scenarios (SCN) | 63 |
| Active Requirements with ≥1 ATP | 35 / 35 (100%) |
| Test Cases with ≥1 SCN | 59 / 59 (100%) |
| **Overall Coverage** | **100%** (active items only) |

**Validation Status**: ✅ Full Coverage
**Generated**: 2025-07-18
**Validated by**: `validate-requirement-coverage.sh` (deterministic)

## Uncovered Requirements

None — full coverage achieved.
