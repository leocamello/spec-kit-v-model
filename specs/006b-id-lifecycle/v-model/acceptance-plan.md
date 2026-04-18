# Acceptance Test Plan: 006b — ID Lifecycle Model


**Feature Branch**: `feature/006b-id-lifecycle`
**Created**: 2026-04-18
**Status**: Draft
**Source**: `specs/006b-id-lifecycle/v-model/requirements.md`

## Overview

This document defines the Acceptance Test Plan for the ID Lifecycle Model feature. Every requirement in `requirements.md` has one or more Test Cases (ATP), and every Test Case has one or more executable User Scenarios (SCN) in BDD format (Given/When/Then).

## ID Schema

- **Test Case**: `ATP-{NNN}-{X}` — where NNN matches the parent REQ, X is a letter suffix (A, B, C...)
- **Scenario**: `SCN-{NNN}-{X}{#}` — nested under the parent ATP, with numeric suffix (1, 2, 3...)
- Example: `SCN-001-A1` → Scenario 1 of Test Case A validating REQ-001

## Acceptance Tests

### Requirement Validation: REQ-001 (Four Lifecycle States)

#### Test Case: ATP-001-A (All Four States Representable)
**Linked Requirement:** REQ-001
**Description:** Verify that an artifact ID can exist in each of the four lifecycle states: ACTIVE, DEPRECATED, MODIFIED, and SUSPECT.
**Validation Condition:** A single artifact contains IDs in all four states, each with correct annotation syntax.
**Expected Result:** The artifact parses without error and each ID is identifiable as its respective state by annotation presence or absence.

* **User Scenario: SCN-001-A1**
  * **Given** a V-Model artifact (e.g., requirements.md) with 4 IDs: REQ-001 (no annotation), REQ-002 with `[DEPRECATED — Withdrawn: obsolete]`, REQ-003 with content updated and downstream marked suspect, REQ-004 with `[SUSPECT — Parent REQ-002 deprecated]`
  * **When** a lifecycle-aware command processes this artifact
  * **Then** the command identifies REQ-001 as ACTIVE, REQ-002 as DEPRECATED, REQ-003 as MODIFIED, and REQ-004 as SUSPECT

#### Test Case: ATP-001-B (ACTIVE State Has No Annotation)
**Linked Requirement:** REQ-001
**Description:** Verify that the ACTIVE state is implicit — an ID without any lifecycle annotation is ACTIVE.
**Validation Condition:** An ID without `[DEPRECATED`, `[MODIFIED`, or `[SUSPECT` annotations is classified as ACTIVE.
**Expected Result:** IDs with no lifecycle annotations are treated as ACTIVE with no additional markup required.

* **User Scenario: SCN-001-B1**
  * **Given** a requirements.md containing `REQ-010` with a standard description and no lifecycle annotation
  * **When** the trace command processes this artifact
  * **Then** REQ-010 is included in active coverage metrics and is not listed in any lifecycle summary section

---

### Requirement Validation: REQ-002 (Supersession Deprecation Syntax)

#### Test Case: ATP-002-A (Valid Supersession Annotation)
**Linked Requirement:** REQ-002
**Description:** Verify that an ID can be deprecated via supersession using the defined syntax.
**Validation Condition:** The annotation `[DEPRECATED — Superseded by {PREFIX}-NNN]` is recognized as a valid deprecation with a target successor ID.
**Expected Result:** The deprecated ID is excluded from active counts, and the successor ID is extractable from the annotation.

* **User Scenario: SCN-002-A1**
  * **Given** a requirements.md where REQ-005 has the annotation `[DEPRECATED — Superseded by REQ-012]`
  * **When** the trace command processes this artifact
  * **Then** REQ-005 is reported as deprecated-by-supersession, REQ-012 is identified as the successor, and REQ-005 is excluded from the active requirement count

#### Test Case: ATP-002-B (Supersession With Missing Successor ID)
**Linked Requirement:** REQ-002
**Description:** Verify that a supersession annotation without a valid successor ID is flagged as malformed.
**Validation Condition:** The annotation `[DEPRECATED — Superseded by]` (missing target) is detected as an error.
**Expected Result:** The command reports a malformed annotation error identifying the missing successor ID.

* **User Scenario: SCN-002-B1**
  * **Given** a requirements.md where REQ-005 has the annotation `[DEPRECATED — Superseded by]` with no target ID
  * **When** a lifecycle-aware command processes this artifact
  * **Then** the command reports a validation error: "REQ-005 has supersession annotation without a target ID"

---

### Requirement Validation: REQ-003 (Withdrawal Deprecation Syntax)

#### Test Case: ATP-003-A (Valid Withdrawal Annotation)
**Linked Requirement:** REQ-003
**Description:** Verify that an ID can be deprecated via withdrawal using the defined syntax with a mandatory reason.
**Validation Condition:** The annotation `[DEPRECATED — Withdrawn: {reason}]` is recognized as valid withdrawal.
**Expected Result:** The deprecated ID is excluded from active counts and the withdrawal reason is extractable.

* **User Scenario: SCN-003-A1**
  * **Given** a requirements.md where REQ-007 has the annotation `[DEPRECATED — Withdrawn: regulatory change removed need for encryption at rest]`
  * **When** the trace command processes this artifact
  * **Then** REQ-007 is reported as deprecated-by-withdrawal with the reason "regulatory change removed need for encryption at rest"

#### Test Case: ATP-003-B (Withdrawal With Missing Reason)
**Linked Requirement:** REQ-003
**Description:** Verify that a withdrawal annotation without a reason is flagged as malformed.
**Validation Condition:** The annotation `[DEPRECATED — Withdrawn:]` (empty reason) is detected as an error.
**Expected Result:** The command reports a validation error identifying the missing withdrawal reason.

* **User Scenario: SCN-003-B1**
  * **Given** a requirements.md where REQ-007 has the annotation `[DEPRECATED — Withdrawn:]` with an empty reason
  * **When** a lifecycle-aware command processes this artifact
  * **Then** the command reports a validation error: "REQ-007 has withdrawal annotation without a reason"

---

### Requirement Validation: REQ-004 (DEPRECATED Triggers SUSPECT Cascade)

#### Test Case: ATP-004-A (Downstream Items Marked SUSPECT)
**Linked Requirement:** REQ-004
**Description:** Verify that deprecating a parent ID causes all immediate downstream IDs to be marked SUSPECT on the next command invocation.
**Validation Condition:** After deprecating a requirement, re-running the downstream command produces SUSPECT annotations on all traced children.
**Expected Result:** Each downstream ID that traced to the deprecated parent now bears `[SUSPECT — Parent {ID} deprecated]`.

* **User Scenario: SCN-004-A1**
  * **Given** a requirements.md with REQ-003 marked `[DEPRECATED — Withdrawn: scope reduced]` and an acceptance-plan.md containing ATP-003-A and ATP-003-B that trace to REQ-003
  * **When** the acceptance command is re-invoked
  * **Then** ATP-003-A and ATP-003-B each receive the annotation `[SUSPECT — Parent REQ-003 deprecated]`

#### Test Case: ATP-004-B (No Downstream Items Exist)
**Linked Requirement:** REQ-004
**Description:** Verify that deprecating an ID with no downstream traceable items produces no errors and no spurious SUSPECT annotations.
**Validation Condition:** The command completes without error and no new SUSPECT annotations appear.
**Expected Result:** The command reports the deprecation was processed with zero downstream items affected.

* **User Scenario: SCN-004-B1**
  * **Given** a requirements.md with REQ-019 marked `[DEPRECATED — Withdrawn: not needed]` and no ATPs in acceptance-plan.md that trace to REQ-019
  * **When** the acceptance command is re-invoked
  * **Then** the command completes with no new SUSPECT annotations and reports zero downstream items affected by the deprecation

---

### Requirement Validation: REQ-005 (MODIFIED Triggers SUSPECT Cascade)

#### Test Case: ATP-005-A (Modified Parent Produces SUSPECT Children)
**Linked Requirement:** REQ-005
**Description:** Verify that modifying a parent ID's content causes all immediate downstream IDs to be marked SUSPECT on the next command invocation.
**Validation Condition:** After modifying a requirement's description, re-running the downstream command marks its children SUSPECT.
**Expected Result:** Each downstream ID that traced to the modified parent now bears `[SUSPECT — Parent {ID} modified]`.

* **User Scenario: SCN-005-A1**
  * **Given** a requirements.md where REQ-002's description has been updated (content changed, ID preserved) and a system-design.md containing SYS-001 that traces to REQ-002
  * **When** the system-design command is re-invoked
  * **Then** SYS-001 receives the annotation `[SUSPECT — Parent REQ-002 modified]`

#### Test Case: ATP-005-B (Modification With No Content Change)
**Linked Requirement:** REQ-005
**Description:** Verify that if a parent ID's content is unchanged between invocations, no SUSPECT annotations are generated.
**Validation Condition:** Re-running a downstream command on an unchanged parent produces no new lifecycle annotations.
**Expected Result:** All existing downstream IDs remain annotation-free (or retain their current annotations unchanged).

* **User Scenario: SCN-005-B1**
  * **Given** a requirements.md where REQ-002 is unchanged since the last acceptance command run and an acceptance-plan.md with ATP-002-A tracing to REQ-002
  * **When** the acceptance command is re-invoked
  * **Then** ATP-002-A retains its existing content with no new SUSPECT annotation

---

### Requirement Validation: REQ-006 (Three SUSPECT Resolution Paths)

#### Test Case: ATP-006-A (Re-parent Resolution)
**Linked Requirement:** REQ-006
**Description:** Verify that a SUSPECT item can be resolved by re-parenting it to a superseding ID.
**Validation Condition:** After re-parenting, the item's parent trace updates to the new ID and the SUSPECT annotation is removed.
**Expected Result:** The item traces to the new parent ID and has no SUSPECT annotation.

* **User Scenario: SCN-006-A1**
  * **Given** an acceptance-plan.md where ATP-003-A is marked `[SUSPECT — Parent REQ-003 deprecated]` and REQ-003 was superseded by REQ-012
  * **When** the user re-invokes the acceptance command and instructs it to re-parent ATP-003-A to REQ-012
  * **Then** ATP-003-A's linked requirement changes to REQ-012, the SUSPECT annotation is removed, and the ATP ID is preserved

#### Test Case: ATP-006-B (Deprecate Resolution)
**Linked Requirement:** REQ-006
**Description:** Verify that a SUSPECT item can be resolved by deprecating it.
**Validation Condition:** After deprecation, the item bears a DEPRECATED annotation and the SUSPECT annotation is removed.
**Expected Result:** The item shows `[DEPRECATED — Withdrawn: parent capability removed]` with no remaining SUSPECT annotation.

* **User Scenario: SCN-006-B1**
  * **Given** an acceptance-plan.md where ATP-007-A is marked `[SUSPECT — Parent REQ-007 deprecated]` and REQ-007 was withdrawn
  * **When** the user re-invokes the acceptance command and instructs it to deprecate ATP-007-A
  * **Then** ATP-007-A receives `[DEPRECATED — Withdrawn: parent REQ-007 withdrawn]` and the SUSPECT annotation is removed

#### Test Case: ATP-006-C (Confirm Still Valid Resolution)
**Linked Requirement:** REQ-006
**Description:** Verify that a SUSPECT item can be resolved by confirming it is still valid despite the parent change.
**Validation Condition:** After confirmation, the SUSPECT annotation is removed and the item's content is preserved unchanged.
**Expected Result:** The item has no SUSPECT annotation and its content, ID, and parent trace remain unchanged.

* **User Scenario: SCN-006-C1**
  * **Given** a system-design.md where SYS-004 is marked `[SUSPECT — Parent REQ-010 modified]` and after review the SYS-004 design is still correct
  * **When** the user re-invokes the system-design command and confirms SYS-004 is still valid
  * **Then** SYS-004's SUSPECT annotation is removed and its content remains unchanged

---

### Requirement Validation: REQ-007 (IDs Never Deleted)

#### Test Case: ATP-007-A (Deprecated IDs Remain In Artifact)
**Linked Requirement:** REQ-007
**Description:** Verify that deprecated IDs are preserved in the artifact text with their annotation, not removed.
**Validation Condition:** After a lifecycle transition, the original ID and its content remain visible in the artifact.
**Expected Result:** The deprecated ID appears in the artifact with its deprecation annotation; searching for the ID returns a match.

* **User Scenario: SCN-007-A1**
  * **Given** a requirements.md where REQ-005 has been deprecated via `[DEPRECATED — Superseded by REQ-012]`
  * **When** a user searches the artifact for "REQ-005"
  * **Then** REQ-005 is found in the artifact with its original description and the deprecation annotation

#### Test Case: ATP-007-B (Resolved SUSPECT IDs Remain)
**Linked Requirement:** REQ-007
**Description:** Verify that resolving a SUSPECT item (even via deprecation) preserves the ID in the artifact.
**Validation Condition:** After SUSPECT resolution, the ID is still present — only the annotation changes.
**Expected Result:** The ID remains in the artifact regardless of its lifecycle state.

* **User Scenario: SCN-007-B1**
  * **Given** an acceptance-plan.md where ATP-003-A was SUSPECT and has been resolved by deprecation
  * **When** a user searches the artifact for "ATP-003-A"
  * **Then** ATP-003-A is found in the artifact with a DEPRECATED annotation

---

### Requirement Validation: REQ-008 (9 Commands Get Lifecycle Rules Section)

#### Test Case: ATP-008-A (All 9 ID-Bearing Commands Include Section)
**Linked Requirement:** REQ-008
**Description:** Verify that each of the 9 ID-bearing generative commands contains a Lifecycle Rules section.
**Validation Condition:** Each command file contains a "Lifecycle Rules" heading with the 5 lifecycle rules.
**Expected Result:** All 9 command files (requirements, acceptance, system-design, system-test, architecture-design, integration-test, module-design, unit-test, hazard-analysis) contain the Lifecycle Rules section.

* **User Scenario: SCN-008-A1**
  * **Given** the 9 command files: requirements.md, acceptance.md, system-design.md, system-test.md, architecture-design.md, integration-test.md, module-design.md, unit-test.md, and hazard-analysis.md
  * **When** each file is inspected for the presence of a "Lifecycle Rules" section
  * **Then** all 9 files contain a section headed "Lifecycle Rules" with subsections for: never-delete rule, deprecation types, suspect detection, suspect resolution, and modified-item handling

#### Test Case: ATP-008-B (Peer-Review Excluded)
**Linked Requirement:** REQ-008
**Description:** Verify that the stateless peer-review command does not receive a Lifecycle Rules section.
**Validation Condition:** The peer-review.md command file contains no "Lifecycle Rules" section.
**Expected Result:** peer-review.md has no Lifecycle Rules section since it regenerates output each run and bears no persistent IDs.

* **User Scenario: SCN-008-B1**
  * **Given** the peer-review.md command file
  * **When** the file is inspected for a "Lifecycle Rules" section
  * **Then** no such section exists in peer-review.md

---

### Requirement Validation: REQ-009 (Lifecycle Rules Section Position)

#### Test Case: ATP-009-A (Correct Position in Execution Flow)
**Linked Requirement:** REQ-009
**Description:** Verify that the Lifecycle Rules section appears between the "Load existing artifact" step and the "Generate new content" step in each command.
**Validation Condition:** In each command's execution flow, the Lifecycle Rules section heading appears after the load step and before the generation step.
**Expected Result:** The section ordering in all 9 commands is: ...Load existing artifact → Lifecycle Rules → Generate new content...

* **User Scenario: SCN-009-A1**
  * **Given** the acceptance.md command file with its execution flow steps
  * **When** the step ordering is examined
  * **Then** the "Lifecycle Rules" section appears after "Load existing acceptance plan" (step 2.3) and before "Generate Test Cases and Scenarios" (step 4)

---

### Requirement Validation: REQ-010 (Change Detection Mechanism)

#### Test Case: ATP-010-A (Correctly Classifies Parent ID States)
**Linked Requirement:** REQ-010
**Description:** Verify that the change detection mechanism correctly classifies parent IDs into unchanged, modified, deprecated, and added categories.
**Validation Condition:** Given a known set of parent changes, the command's classification matches expected categories.
**Expected Result:** Each parent ID is classified into exactly one of the four categories: unchanged, modified, deprecated, or added.

* **User Scenario: SCN-010-A1**
  * **Given** a requirements.md with 5 REQs where REQ-001 is unchanged, REQ-002's description was modified, REQ-003 is deprecated, REQ-004 is unchanged, and REQ-005 is newly added, and an existing acceptance-plan.md with ATPs for REQ-001 through REQ-004
  * **When** the acceptance command is invoked
  * **Then** the command classifies REQ-001 as unchanged, REQ-002 as modified, REQ-003 as deprecated, REQ-004 as unchanged, and REQ-005 as added

#### Test Case: ATP-010-B (No Changes Detected)
**Linked Requirement:** REQ-010
**Description:** Verify that when no parent IDs have changed, the detection mechanism reports zero changes and takes no lifecycle actions.
**Validation Condition:** All parent IDs are classified as "unchanged" and no SUSPECT annotations are added.
**Expected Result:** The command reports "0 changes detected" and the downstream artifact is unchanged.

* **User Scenario: SCN-010-B1**
  * **Given** a requirements.md that is identical to the version used to generate the existing acceptance-plan.md
  * **When** the acceptance command is re-invoked
  * **Then** the command reports zero parent changes and the acceptance-plan.md content is unchanged

---

### Requirement Validation: REQ-011 (LLM-Based Detection, No External Script)

#### Test Case: ATP-011-A (Detection Without Script Dependency)
**Linked Requirement:** REQ-011
**Description:** Verify that lifecycle change detection is performed by the LLM within the command flow, not by requiring a new external script for each command.
**Validation Condition:** Commands other than acceptance perform change detection without invoking any script beyond setup-v-model.sh.
**Expected Result:** The system-design, system-test, architecture-design, integration-test, module-design, unit-test, and hazard-analysis commands perform lifecycle detection as part of their instruction flow with no additional script invocation.

* **User Scenario: SCN-011-A1**
  * **Given** a system-design.md with SYS-001 tracing to REQ-001, and REQ-001 has been modified in requirements.md
  * **When** the system-design command is re-invoked
  * **Then** the command detects REQ-001 as modified and marks SYS-001 as SUSPECT without invoking any external detection script beyond setup-v-model.sh

---

### Requirement Validation: REQ-012 (diff-requirements.sh Preserved)

#### Test Case: ATP-012-A (Script Continues Working for Acceptance)
**Linked Requirement:** REQ-012
**Description:** Verify that the existing diff-requirements.sh script continues to function as a deterministic accelerator for the requirements→acceptance transition.
**Validation Condition:** The acceptance command invokes diff-requirements.sh and its output is consumed alongside the LLM comparison.
**Expected Result:** The acceptance command still runs diff-requirements.sh and uses its JSON output to detect added, modified, and removed requirements.

* **User Scenario: SCN-012-A1**
  * **Given** a requirements.md with changes (1 added REQ, 1 modified REQ) and an existing acceptance-plan.md
  * **When** the acceptance command is invoked
  * **Then** diff-requirements.sh is executed and returns JSON identifying the added and modified REQs, and the acceptance command uses this output in its generation flow

---

### Requirement Validation: REQ-013 (Trace Excludes Deprecated From Denominators)

#### Test Case: ATP-013-A (Coverage Not Reduced by Deprecation)
**Linked Requirement:** REQ-013
**Description:** Verify that deprecated items are excluded from coverage metric denominators so retiring IDs does not reduce coverage percentages.
**Validation Condition:** Deprecating a fully-covered requirement does not change the coverage percentage.
**Expected Result:** Coverage remains at the same percentage (or increases) after deprecation; the deprecated item is not counted in the denominator.

* **User Scenario: SCN-013-A1**
  * **Given** a requirements.md with 10 REQs (all covered by ATPs, 100% coverage) and REQ-005 is then marked `[DEPRECATED — Withdrawn: no longer needed]`
  * **When** the trace command generates a traceability matrix
  * **Then** the coverage metric reports 9/9 (100%) active requirements covered, with REQ-005 listed in a separate "Deprecated" section outside the coverage denominator

#### Test Case: ATP-013-B (Deprecated With Uncovered Active REQs)
**Linked Requirement:** REQ-013
**Description:** Verify that coverage percentage accurately reflects only active items when both deprecated and uncovered items exist.
**Validation Condition:** The denominator includes only non-deprecated items.
**Expected Result:** Coverage equals covered-active / total-active, not covered / total.

* **User Scenario: SCN-013-B1**
  * **Given** a requirements.md with 10 REQs, 8 covered by ATPs, 1 deprecated (REQ-005), and 1 uncovered active (REQ-009)
  * **When** the trace command generates a traceability matrix
  * **Then** the coverage metric reports 8/9 (88.9%) with REQ-005 excluded from the denominator and REQ-009 flagged as uncovered

---

### Requirement Validation: REQ-014 (Trace Reports SUSPECT Items)

#### Test Case: ATP-014-A (Dedicated Suspect Summary Section)
**Linked Requirement:** REQ-014
**Description:** Verify that the trace command includes a dedicated section listing all SUSPECT items with their parent change reasons.
**Validation Condition:** The traceability matrix output contains a "Suspect Items" section with each suspect item and its annotation.
**Expected Result:** The suspect summary lists each SUSPECT item, its ID, and the parent change that caused the suspect state (e.g., "Parent REQ-003 deprecated").

* **User Scenario: SCN-014-A1**
  * **Given** an acceptance-plan.md with ATP-003-A marked `[SUSPECT — Parent REQ-003 deprecated]` and ATP-010-B marked `[SUSPECT — Parent REQ-010 modified]`
  * **When** the trace command generates a traceability matrix
  * **Then** the output contains a "Suspect Items" section listing ATP-003-A with reason "Parent REQ-003 deprecated" and ATP-010-B with reason "Parent REQ-010 modified"

---

### Requirement Validation: REQ-015 (Trace Reports Deprecated Chains Separately)

#### Test Case: ATP-015-A (Deprecated Chain in Separate Section)
**Linked Requirement:** REQ-015
**Description:** Verify that the trace command reports deprecated chains (parent + all downstream deprecated items) in a section separate from active chains.
**Validation Condition:** Deprecated items and their lineage appear in a "Deprecated Chains" section, not in the main coverage matrices.
**Expected Result:** The traceability matrix has a distinct section showing deprecated IDs and their full deprecation lineage (successor or withdrawal reason).

* **User Scenario: SCN-015-A1**
  * **Given** a requirements.md with REQ-005 `[DEPRECATED — Superseded by REQ-012]` and an acceptance-plan.md with ATP-005-A `[DEPRECATED — Withdrawn: parent REQ-005 deprecated]`
  * **When** the trace command generates a traceability matrix
  * **Then** the output contains a "Deprecated Chains" section showing REQ-005 → REQ-012 (supersession) and ATP-005-A (withdrawn), separate from the active coverage matrices

---

### Requirement Validation: REQ-016 (Impact-Analysis Formal Syntax)

#### Test Case: ATP-016-A (Formal Lifecycle Tags in Output)
**Linked Requirement:** REQ-016
**Description:** Verify that the impact-analysis command uses formal lifecycle state syntax (`[DEPRECATED]`, `[MODIFIED]`, `[SUSPECT]`) in its output.
**Validation Condition:** The impact-analysis output contains formal tags rather than informal prose when reporting lifecycle states.
**Expected Result:** Each affected item in the impact-analysis output is annotated with its formal lifecycle tag.

* **User Scenario: SCN-016-A1**
  * **Given** a V-Model artifact set where REQ-003 is deprecated and SYS-002 is marked suspect
  * **When** the impact-analysis command is invoked
  * **Then** the output shows REQ-003 with `[DEPRECATED]` and SYS-002 with `[SUSPECT]` using the formal tag syntax, not informal descriptions like "may need review"

---

### Requirement Validation: REQ-017 (diff-requirements.sh Extended)

#### Test Case: ATP-017-A (Detects Lifecycle Transitions)
**Linked Requirement:** REQ-017
**Description:** Verify that the extended diff-requirements.sh script detects new deprecations, new suspects, and resolved suspects in addition to content changes.
**Validation Condition:** The script's JSON output includes fields for lifecycle transitions alongside existing added/modified/removed fields.
**Expected Result:** The JSON output contains `deprecated`, `new_suspects`, and `resolved_suspects` arrays alongside existing `added`, `modified`, and `removed` arrays.

* **User Scenario: SCN-017-A1**
  * **Given** a requirements.md with REQ-005 newly marked `[DEPRECATED — Withdrawn: obsolete]` and REQ-010 previously SUSPECT now confirmed valid (annotation removed), compared to the version embedded in acceptance-plan.md
  * **When** diff-requirements.sh is executed against the v-model directory
  * **Then** the JSON output includes REQ-005 in the `deprecated` array and REQ-010 in the `resolved_suspects` array

---

### Requirement Validation: REQ-018 (Inline Markdown Annotations)

#### Test Case: ATP-018-A (Annotations Embedded in Text)
**Linked Requirement:** REQ-018
**Description:** Verify that lifecycle annotations are embedded as inline text within the Markdown artifact.
**Validation Condition:** Lifecycle state information appears within the artifact's Markdown text, adjacent to or part of the ID's entry.
**Expected Result:** The annotation `[DEPRECATED — ...]` or `[SUSPECT — ...]` appears in the same line or section as the ID, parseable from the Markdown source.

* **User Scenario: SCN-018-A1**
  * **Given** a requirements.md where REQ-005 has been deprecated
  * **When** the artifact file is read as plain text
  * **Then** the text `[DEPRECATED — Superseded by REQ-012]` appears inline within the REQ-005 table row or heading

#### Test Case: ATP-018-B (No External State Files Created)
**Linked Requirement:** REQ-018
**Description:** Verify that no external state file or database is created to track lifecycle states.
**Validation Condition:** After lifecycle transitions, the v-model directory contains only the standard artifact files — no .json, .db, .state, or similar files.
**Expected Result:** The v-model directory listing shows only the 9 standard artifact files (plus spec.md in the parent), with no additional state files.

* **User Scenario: SCN-018-B1**
  * **Given** a V-Model artifact set that has undergone multiple lifecycle transitions (deprecations, modifications, suspect cascades)
  * **When** the v-model directory contents are listed
  * **Then** the directory contains only the standard V-Model artifact files with no additional state-tracking files

---

### Requirement Validation: REQ-019 (Identical Lifecycle Rules Across Commands)

#### Test Case: ATP-019-A (Section Text Matches Across All 9 Commands)
**Linked Requirement:** REQ-019
**Description:** Verify that the Lifecycle Rules section text is identical across all 9 commands, with only the ID prefix varying.
**Validation Condition:** After normalizing ID prefixes (replacing REQ/SYS/ARCH/etc. with a placeholder), the section text is byte-identical across all 9 commands.
**Expected Result:** All 9 Lifecycle Rules sections produce identical text after prefix normalization.

* **User Scenario: SCN-019-A1**
  * **Given** the 9 command files with their Lifecycle Rules sections
  * **When** the Lifecycle Rules section is extracted from each file and ID prefixes (REQ, ATP, SYS, STP, ARCH, ITP, MOD, UTP, HAZ) are replaced with a placeholder `{PREFIX}`
  * **Then** all 9 normalized sections are byte-identical

---

### Requirement Validation: REQ-NF-001 (Forward Development Zero Annotations)

#### Test Case: ATP-NF-001-A (Fresh Build Produces No Annotations)
**Linked Requirement:** REQ-NF-001
**Description:** Verify that generating a full V-Model artifact set from scratch (no pre-existing IDs) produces zero lifecycle annotations in any artifact.
**Validation Condition:** No `[DEPRECATED`, `[MODIFIED`, or `[SUSPECT` strings appear in any generated artifact.
**Expected Result:** All artifacts contain only active IDs with standard content — no lifecycle annotations present.

* **User Scenario: SCN-NF-001-A1**
  * **Given** a new feature branch with only spec.md and an empty v-model directory
  * **When** all 9 V-Model commands are executed in sequence (requirements → acceptance → system-design → system-test → architecture-design → integration-test → module-design → unit-test → trace)
  * **Then** none of the 9 generated artifacts contain any string matching `[DEPRECATED`, `[MODIFIED`, or `[SUSPECT`

---

### Requirement Validation: REQ-NF-002 (Git-Only Lifecycle History)

#### Test Case: ATP-NF-002-A (No Embedded Changelogs)
**Linked Requirement:** REQ-NF-002
**Description:** Verify that lifecycle transition history is available only through git log, with no embedded changelogs or revision tables within artifacts.
**Validation Condition:** After multiple lifecycle transitions, no artifact contains a changelog, revision history, or "modified on" table.
**Expected Result:** Artifacts contain only current-state annotations; `git log --follow` on the artifact file shows the transition history.

* **User Scenario: SCN-NF-002-A1**
  * **Given** a requirements.md that has undergone 3 lifecycle transitions (REQ-003 deprecated, REQ-005 modified, REQ-008 deprecated) across 3 separate commits
  * **When** the artifact is inspected for revision tracking content
  * **Then** the artifact contains no "Revision History", "Changelog", or date-stamped modification entries — only the current lifecycle annotations

---

### Requirement Validation: REQ-CN-001 (No Automated Suspect Resolution)

#### Test Case: ATP-CN-001-A (SUSPECT Items Require Human Review)
**Linked Requirement:** REQ-CN-001
**Description:** Verify that SUSPECT items are never automatically resolved — each requires explicit human decision via command invocation.
**Validation Condition:** After a suspect cascade, SUSPECT annotations persist across command invocations until a human explicitly resolves them.
**Expected Result:** SUSPECT annotations remain on items until the user invokes the downstream command with an explicit resolution instruction.

* **User Scenario: SCN-CN-001-A1**
  * **Given** a system-design.md with SYS-003 marked `[SUSPECT — Parent REQ-003 deprecated]`
  * **When** the system-test command is invoked (a different downstream command, not targeting SYS-003's resolution)
  * **Then** SYS-003 retains its SUSPECT annotation unchanged — the system-test command does not resolve it

---

### Requirement Validation: REQ-CN-002 (Per-Level Cascade)

#### Test Case: ATP-CN-002-A (No Single-Command Multi-Level Cascade)
**Linked Requirement:** REQ-CN-002
**Description:** Verify that suspect cascade requires separate command invocations per V-Model level — there is no single command that cascades through all levels at once.
**Validation Condition:** Deprecating a REQ and running only the acceptance command does not cascade SUSPECT to system-design or lower levels.
**Expected Result:** Only the immediate downstream level (acceptance) receives SUSPECT annotations; deeper levels remain unchanged until their respective commands are invoked.

* **User Scenario: SCN-CN-002-A1**
  * **Given** a requirements.md with REQ-003 deprecated, and existing acceptance-plan.md, system-design.md, and architecture-design.md
  * **When** only the acceptance command is re-invoked
  * **Then** ATP-003-A in acceptance-plan.md is marked SUSPECT, but SYS items in system-design.md and ARCH items in architecture-design.md remain unchanged

---

### Requirement Validation: REQ-CN-003 (No New Commands)

#### Test Case: ATP-CN-003-A (Command Count Unchanged)
**Linked Requirement:** REQ-CN-003
**Description:** Verify that the feature only adds content to existing command files and does not create new command files.
**Validation Condition:** The number of files in the commands directory is unchanged after the feature is implemented.
**Expected Result:** The commands directory contains exactly the same set of command files as before the feature, with no additions or removals.

* **User Scenario: SCN-CN-003-A1**
  * **Given** the commands directory with its current set of 14 command files
  * **When** the 006b feature implementation is complete
  * **Then** the commands directory contains exactly 14 files — the same set as before, with only content additions (Lifecycle Rules sections) to 9 of them

---

### Requirement Validation: REQ-CN-004 (Scope Exclusions)

#### Test Case: ATP-CN-004-A (Excluded Features Not Present)
**Linked Requirement:** REQ-CN-004
**Description:** Verify that the feature does not include domain overlay architecture, bridge commands, or version history within artifacts.
**Validation Condition:** None of the implemented changes reference or implement domain overlays, bridge commands, or in-artifact version history tables.
**Expected Result:** Searching for domain overlay hooks, bridge command invocations, or version history tables across all modified files returns zero matches.

* **User Scenario: SCN-CN-004-A1**
  * **Given** the complete set of files modified by the 006b feature
  * **When** the files are searched for strings: "domain-overlay", "bridge-command", "Revision History", "Version History"
  * **Then** zero matches are found — none of these excluded features are present

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Requirements (REQ) | 25 (25 active, 0 deprecated) |
| Total Test Cases (ATP) | 37 (37 active, 0 deprecated, 0 suspect) |
| Total Scenarios (SCN) | 37 |
| Active Requirements with ≥1 ATP | 25 / 25 (100%) |
| Test Cases with ≥1 SCN | 37 / 37 (100%) |
| **Overall Coverage** | **100%** (active items only) |

## Uncovered Requirements

None — full coverage achieved.

**Validation Status**: ✅ Full Coverage
**Generated**: 2026-04-18
