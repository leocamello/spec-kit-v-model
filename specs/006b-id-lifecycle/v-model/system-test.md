# System Test Plan: 006b — ID Lifecycle Model


**Feature Branch**: `feature/006b-id-lifecycle`
**Created**: 2026-04-18
**Status**: Draft
**Source**: `specs/006b-id-lifecycle/v-model/system-design.md`

## Overview

This document defines the System Test Plan for the ID Lifecycle Model feature. Every system component in `system-design.md` has one or more Test Cases (STP), and every Test Case has one or more executable System Scenarios (STS) in technical BDD format (Given/When/Then). System tests verify **architectural behavior**, not user journeys. Language is technical and component-oriented.

## ID Schema

- **System Test Case**: `STP-{NNN}-{X}` — where NNN matches the parent SYS, X is a letter suffix (A, B, C...)
- **System Test Scenario**: `STS-{NNN}-{X}{#}` — nested under the parent STP, with numeric suffix (1, 2, 3...)
- Example: `STS-001-A1` → Scenario 1 of Test Case A verifying SYS-001

## ISO 29119 Test Techniques

Each test case identifies its technique by name:
- **Interface Contract Testing (ICT)** — Verifies API contracts from the Interface View
- **Boundary Value Analysis (BVA)** — Tests data limits from the Data Design View
- **Fault Injection (FI)** — Tests failure propagation from the Dependency View

## System Tests

### Component Verification: SYS-001 (Lifecycle State Model)

**Parent Requirements**: REQ-001, REQ-007, REQ-018, REQ-NF-001, REQ-NF-002, REQ-CN-004

#### Test Case: STP-001-A (Four-State Recognition)

**Technique**: Interface Contract Testing
**Target View**: Interface View (State Query interface)
**Description**: Verify that the State Model correctly classifies IDs in all four lifecycle states from inline Markdown annotations.

* **System Scenario: STS-001-A1**
  * **Given** a Markdown artifact containing four IDs: one with no annotation, one with `[DEPRECATED — Superseded by REQ-012]`, one with `[SUSPECT — Parent REQ-003 deprecated]`, and one whose content was modified in-place
  * **When** the Lifecycle State Model parses the artifact text
  * **Then** it classifies the four IDs as ACTIVE, DEPRECATED, SUSPECT, and ACTIVE (modification is content-level, not annotation-level) respectively

* **System Scenario: STS-001-A2**
  * **Given** a Markdown artifact where all IDs have no lifecycle annotations
  * **When** the Lifecycle State Model parses the artifact text
  * **Then** all IDs are classified as ACTIVE and zero lifecycle annotations are reported

#### Test Case: STP-001-B (Annotation Persistence in Markdown)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View (Lifecycle Annotation entity)
**Description**: Verify that lifecycle annotations are embedded inline within the Markdown text and survive file read/write cycles without corruption.

* **System Scenario: STS-001-B1**
  * **Given** an artifact file containing `REQ-005` with the annotation `[DEPRECATED — Superseded by REQ-012]` written as inline text in a Markdown table row
  * **When** the file is read, parsed for IDs and annotations, and written back to disk
  * **Then** the annotation text `[DEPRECATED — Superseded by REQ-012]` is byte-identical before and after the round-trip

* **System Scenario: STS-001-B2**
  * **Given** an artifact file containing `REQ-007` with the annotation `[DEPRECATED — Withdrawn: regulatory change removed encryption-at-rest mandate per directive 2026/114/EU]` (annotation length: 91 characters)
  * **When** the Lifecycle State Model parses the annotation
  * **Then** the full reason string is extracted without truncation: "regulatory change removed encryption-at-rest mandate per directive 2026/114/EU"

#### Test Case: STP-001-C (No External State Files)

**Technique**: Interface Contract Testing
**Target View**: Data Design View (Lifecycle Annotation entity)
**Description**: Verify that the state model stores all lifecycle information inline in Markdown — no external .json, .db, or .state files are created.

* **System Scenario: STS-001-C1**
  * **Given** a v-model directory containing artifacts with IDs in all four lifecycle states
  * **When** the directory contents are listed after a full lifecycle processing pass
  * **Then** the directory contains only the standard V-Model artifact files — no files with extensions .json, .db, .state, .yaml, or .xml have been created

---

### Component Verification: SYS-002 (Deprecation Annotation Engine)

**Parent Requirements**: REQ-002, REQ-003

#### Test Case: STP-002-A (Supersession Annotation Write and Parse)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Deprecation Request interface)
**Description**: Verify that the Deprecation Annotation Engine correctly writes and parses supersession annotations with the mandatory successor ID.

* **System Scenario: STS-002-A1**
  * **Given** a deprecation request with type "supersession" and successor_id "REQ-012"
  * **When** the Deprecation Annotation Engine writes the annotation for REQ-005
  * **Then** the output text contains `[DEPRECATED — Superseded by REQ-012]` with the em dash (U+2014) separator

* **System Scenario: STS-002-A2**
  * **Given** an artifact containing the text `[DEPRECATED — Superseded by SYS-004]` adjacent to SYS-001
  * **When** the Deprecation Annotation Engine parses this annotation
  * **Then** it returns: `{id: "SYS-001", type: "supersession", successor_id: "SYS-004"}`

#### Test Case: STP-002-B (Withdrawal Annotation Write and Parse)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Deprecation Request interface)
**Description**: Verify that the Deprecation Annotation Engine correctly writes and parses withdrawal annotations with a mandatory reason string.

* **System Scenario: STS-002-B1**
  * **Given** a deprecation request with type "withdrawal" and reason "scope reduced per stakeholder review"
  * **When** the Deprecation Annotation Engine writes the annotation for REQ-007
  * **Then** the output text contains `[DEPRECATED — Withdrawn: scope reduced per stakeholder review]`

* **System Scenario: STS-002-B2**
  * **Given** an artifact containing the text `[DEPRECATED — Withdrawn: obsolete after API v3 migration]` adjacent to ARCH-005
  * **When** the Deprecation Annotation Engine parses this annotation
  * **Then** it returns: `{id: "ARCH-005", type: "withdrawal", reason: "obsolete after API v3 migration"}`

#### Test Case: STP-002-C (Malformed Annotation Detection)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View (Deprecation Metadata entity)
**Description**: Verify that the engine detects and reports malformed deprecation annotations.

* **System Scenario: STS-002-C1**
  * **Given** an artifact containing `[DEPRECATED — Superseded by]` with no target ID after "by"
  * **When** the Deprecation Annotation Engine parses this annotation
  * **Then** it reports a validation error: malformed supersession annotation — missing successor ID

* **System Scenario: STS-002-C2**
  * **Given** an artifact containing `[DEPRECATED — Withdrawn:]` with an empty reason string
  * **When** the Deprecation Annotation Engine parses this annotation
  * **Then** it reports a validation error: malformed withdrawal annotation — missing reason

---

### Component Verification: SYS-003 (Suspect Cascade Engine)

**Parent Requirements**: REQ-004, REQ-005, REQ-CN-002

#### Test Case: STP-003-A (Cascade From Deprecated Parent)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Classification Result interface from SYS-005)
**Description**: Verify that when the Change Detection Engine classifies a parent ID as deprecated, the Suspect Cascade Engine marks all immediate downstream IDs as SUSPECT.

* **System Scenario: STS-003-A1**
  * **Given** the Change Detection Engine (SYS-005) classifies REQ-003 as "deprecated" and the downstream artifact contains ATP-003-A and ATP-003-B tracing to REQ-003
  * **When** the Suspect Cascade Engine processes the classification result
  * **Then** ATP-003-A receives `[SUSPECT — Parent REQ-003 deprecated]` and ATP-003-B receives `[SUSPECT — Parent REQ-003 deprecated]`

#### Test Case: STP-003-B (Cascade From Modified Parent)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Classification Result interface from SYS-005)
**Description**: Verify that when the Change Detection Engine classifies a parent ID as modified, the Suspect Cascade Engine marks immediate downstream IDs as SUSPECT.

* **System Scenario: STS-003-B1**
  * **Given** the Change Detection Engine (SYS-005) classifies REQ-002 as "modified" and the downstream artifact contains SYS-001 tracing to REQ-002
  * **When** the Suspect Cascade Engine processes the classification result
  * **Then** SYS-001 receives `[SUSPECT — Parent REQ-002 modified]`

#### Test Case: STP-003-C (Single-Level Cascade Only)

**Technique**: Fault Injection
**Target View**: Dependency View (SYS-003 → SYS-005)
**Description**: Verify that the cascade operates on exactly one V-Model level per invocation — deprecating a REQ does not cascade through to SYS, ARCH, or deeper levels in a single pass.

* **System Scenario: STS-003-C1**
  * **Given** REQ-003 is deprecated in requirements.md, and ATP-003-A in acceptance-plan.md traces to REQ-003, and SYS-002 in system-design.md traces to REQ-003
  * **When** the acceptance command invokes the Suspect Cascade Engine
  * **Then** ATP-003-A is marked SUSPECT, but SYS-002 in system-design.md remains unchanged — the system-design command must be invoked separately

---

### Component Verification: SYS-004 (Suspect Resolution Handler)

**Parent Requirements**: REQ-006, REQ-CN-001

#### Test Case: STP-004-A (Re-parent Resolution)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Deprecation Request interface via SYS-002)
**Description**: Verify that re-parenting a SUSPECT item updates its parent trace to the successor ID and removes the SUSPECT annotation.

* **System Scenario: STS-004-A1**
  * **Given** ATP-003-A is marked `[SUSPECT — Parent REQ-003 deprecated]` and REQ-003 was superseded by REQ-012
  * **When** the Suspect Resolution Handler processes a re-parent instruction for ATP-003-A → REQ-012
  * **Then** ATP-003-A's linked requirement changes to REQ-012, the SUSPECT annotation is removed, and the ATP ID "ATP-003-A" is preserved unchanged

#### Test Case: STP-004-B (Deprecate Resolution)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Deprecation Request interface via SYS-002)
**Description**: Verify that deprecating a SUSPECT item replaces the SUSPECT annotation with a DEPRECATED annotation.

* **System Scenario: STS-004-B1**
  * **Given** SYS-003 is marked `[SUSPECT — Parent REQ-007 deprecated]` and REQ-007 was withdrawn
  * **When** the Suspect Resolution Handler processes a deprecate instruction for SYS-003 with reason "parent capability withdrawn"
  * **Then** SYS-003 receives `[DEPRECATED — Withdrawn: parent capability withdrawn]` and the SUSPECT annotation is removed

#### Test Case: STP-004-C (Confirm-Valid Resolution)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Suspect Resolution Handler internal contract)
**Description**: Verify that confirming a SUSPECT item as still valid removes the SUSPECT annotation without changing the item's content or parent trace.

* **System Scenario: STS-004-C1**
  * **Given** SYS-004 is marked `[SUSPECT — Parent REQ-010 modified]` and after review the design is confirmed correct
  * **When** the Suspect Resolution Handler processes a confirm-valid instruction for SYS-004
  * **Then** the SUSPECT annotation is removed from SYS-004 and its content, ID, and parent requirement trace remain byte-identical to their pre-suspect state

#### Test Case: STP-004-D (No Automated Resolution)

**Technique**: Fault Injection
**Target View**: Dependency View (SYS-004 → SYS-001)
**Description**: Verify that SUSPECT items are never automatically resolved — they persist until a human provides explicit resolution instructions.

* **System Scenario: STS-004-D1**
  * **Given** ARCH-005 is marked `[SUSPECT — Parent SYS-002 deprecated]` and no human resolution instruction has been provided
  * **When** any command processes the artifact containing ARCH-005 (e.g., integration-test command)
  * **Then** ARCH-005 retains its SUSPECT annotation — the command does not auto-resolve or auto-confirm it

---

### Component Verification: SYS-005 (Change Detection Engine)

**Parent Requirements**: REQ-010, REQ-011, REQ-NF-001

#### Test Case: STP-005-A (Four-Category Classification)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Classification Result interface)
**Description**: Verify that the Change Detection Engine correctly classifies parent IDs into exactly one of four categories: unchanged, modified, deprecated, added.

* **System Scenario: STS-005-A1**
  * **Given** a parent artifact (requirements.md) with 5 REQs: REQ-001 unchanged, REQ-002 description modified, REQ-003 marked DEPRECATED, REQ-004 unchanged, REQ-005 newly added; and an existing downstream artifact with entries tracing to REQ-001 through REQ-004
  * **When** the Change Detection Engine compares the parent artifact against the downstream artifact's traced parent links
  * **Then** it returns: `[{id: "REQ-001", status: "unchanged"}, {id: "REQ-002", status: "modified"}, {id: "REQ-003", status: "deprecated"}, {id: "REQ-004", status: "unchanged"}, {id: "REQ-005", status: "added"}]`

#### Test Case: STP-005-B (Zero-Change Detection in Forward Development)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View (Classification Result entity)
**Description**: Verify that during forward development (no pre-existing downstream artifact), the engine detects zero changes and produces an empty classification result.

* **System Scenario: STS-005-B1**
  * **Given** a parent artifact with 10 REQs and no existing downstream artifact (first-time generation)
  * **When** the Change Detection Engine attempts comparison
  * **Then** it returns all 10 IDs classified as "added" with zero "modified", "deprecated", or "unchanged" entries — resulting in standard generation with zero lifecycle annotations

* **System Scenario: STS-005-B2**
  * **Given** a parent artifact identical to the version used to generate the existing downstream artifact
  * **When** the Change Detection Engine compares parent against downstream
  * **Then** it returns all IDs classified as "unchanged" with zero "modified", "deprecated", or "added" entries

#### Test Case: STP-005-C (LLM-Based Detection Without External Script)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Change Detection internal contract)
**Description**: Verify that the detection is performed within the LLM command flow for non-acceptance commands, without invoking any external detection script.

* **System Scenario: STS-005-C1**
  * **Given** the system-design command is invoked with a modified requirements.md (REQ-002 content changed)
  * **When** the Change Detection Engine performs the 4-step comparison
  * **Then** the classification is produced within the command's instruction flow — no external script beyond setup-v-model.sh is invoked, and REQ-002 is classified as "modified"

---

### Component Verification: SYS-006 (Lifecycle Rules Section Injector)

**Parent Requirements**: REQ-008, REQ-009, REQ-019, REQ-CN-003

#### Test Case: STP-006-A (Section Insertion Into All 9 Commands)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Command File Writer external interface)
**Description**: Verify that the injector adds a Lifecycle Rules section to each of the 9 ID-bearing generative commands.

* **System Scenario: STS-006-A1**
  * **Given** the 9 command files: requirements.md, acceptance.md, system-design.md, system-test.md, architecture-design.md, integration-test.md, module-design.md, unit-test.md, hazard-analysis.md in the commands directory
  * **When** the Lifecycle Rules Section Injector processes all 9 files
  * **Then** each file contains a new section headed "Lifecycle Rules" with 5 subsections: never-delete rule, deprecation types (supersession and withdrawal), suspect detection, suspect resolution, and modified-item handling

#### Test Case: STP-006-B (Correct Section Positioning)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Command File Writer external interface)
**Description**: Verify that the Lifecycle Rules section is positioned between "Load existing artifact" and "Generate new content" in each command's execution flow.

* **System Scenario: STS-006-B1**
  * **Given** the acceptance.md command file with existing steps: Setup → Load Context → Detect Incremental Changes → Generate Test Cases
  * **When** the injector inserts the Lifecycle Rules section
  * **Then** the section appears after "Load existing acceptance plan" (step 2.3/3) and before "Generate Test Cases and Scenarios" (step 4)

#### Test Case: STP-006-C (Cross-Command Section Consistency)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View (Lifecycle Rules section as data)
**Description**: Verify that the Lifecycle Rules section text is identical across all 9 commands after normalizing the ID prefix.

* **System Scenario: STS-006-C1**
  * **Given** the 9 command files with their injected Lifecycle Rules sections
  * **When** the section text is extracted from each file and all ID prefixes (REQ, ATP, SYS, STP, ARCH, ITP, MOD, UTP, HAZ) are replaced with the placeholder `{PREFIX}`
  * **Then** all 9 normalized section texts are byte-identical

#### Test Case: STP-006-D (No New Command Files Created)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View (Command file inventory)
**Description**: Verify that the injector modifies existing command files without creating new ones.

* **System Scenario: STS-006-D1**
  * **Given** a commands directory with exactly 14 files before the feature is applied
  * **When** the Lifecycle Rules Section Injector completes processing
  * **Then** the commands directory still contains exactly 14 files — no files added or removed

---

### Component Verification: SYS-007 (Lifecycle-Aware Trace Reporter)

**Parent Requirements**: REQ-013, REQ-014, REQ-015

#### Test Case: STP-007-A (Deprecated Exclusion From Coverage Denominators)

**Technique**: Interface Contract Testing
**Target View**: Interface View (State Query interface from SYS-001)
**Description**: Verify that deprecated items are excluded from coverage metric denominators so retiring IDs does not reduce coverage percentages.

* **System Scenario: STS-007-A1**
  * **Given** a requirements.md with 10 REQs where REQ-005 is marked `[DEPRECATED — Withdrawn: no longer needed]` and the remaining 9 REQs are all covered by ATPs in acceptance-plan.md
  * **When** the Trace Reporter computes the coverage metrics for the validation matrix (REQ→ATP)
  * **Then** the denominator is 9 (not 10), the numerator is 9, and coverage reports 9/9 (100%)

#### Test Case: STP-007-B (Suspect Items Summary Section)

**Technique**: Interface Contract Testing
**Target View**: Interface View (State Query interface from SYS-001)
**Description**: Verify that the trace output contains a dedicated "Suspect Items" section listing each SUSPECT item with its parent change reason.

* **System Scenario: STS-007-B1**
  * **Given** an acceptance-plan.md with ATP-003-A marked `[SUSPECT — Parent REQ-003 deprecated]` and ATP-010-B marked `[SUSPECT — Parent REQ-010 modified]`
  * **When** the Trace Reporter generates the traceability matrix
  * **Then** the output contains a "Suspect Items" section with two entries: ATP-003-A (reason: "Parent REQ-003 deprecated") and ATP-010-B (reason: "Parent REQ-010 modified")

#### Test Case: STP-007-C (Deprecated Chains Reported Separately)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Deprecation Chain Query interface from SYS-002)
**Description**: Verify that deprecated chains are reported in a section separate from active coverage matrices.

* **System Scenario: STS-007-C1**
  * **Given** REQ-005 is `[DEPRECATED — Superseded by REQ-012]` and ATP-005-A is `[DEPRECATED — Withdrawn: parent deprecated]`
  * **When** the Trace Reporter generates the traceability matrix
  * **Then** the output contains a "Deprecated Chains" section showing REQ-005 → REQ-012 (supersession) and ATP-005-A (withdrawn), and neither appears in the active coverage matrix rows

---

### Component Verification: SYS-008 (Lifecycle-Aware Impact Analyzer)

**Parent Requirements**: REQ-016

#### Test Case: STP-008-A (Formal Lifecycle Tag Emission)

**Technique**: Interface Contract Testing
**Target View**: Interface View (State Lookup interface from SYS-001)
**Description**: Verify that the impact-analysis output uses formal lifecycle state tags (`[DEPRECATED]`, `[MODIFIED]`, `[SUSPECT]`) rather than informal prose.

* **System Scenario: STS-008-A1**
  * **Given** a V-Model artifact set where REQ-003 is deprecated, REQ-010 is modified, and SYS-002 is marked suspect
  * **When** the Lifecycle-Aware Impact Analyzer processes the artifacts
  * **Then** the output shows REQ-003 with `[DEPRECATED]`, REQ-010 with `[MODIFIED]`, and SYS-002 with `[SUSPECT]` — no informal phrases like "may need review" or "possibly affected"

* **System Scenario: STS-008-A2**
  * **Given** a V-Model artifact set with zero lifecycle annotations (forward development)
  * **When** the Lifecycle-Aware Impact Analyzer processes the artifacts
  * **Then** the output contains zero formal lifecycle tags — all items are reported as active without any tag

---

### Component Verification: SYS-009 (Lifecycle-Aware Diff Engine)

**Parent Requirements**: REQ-012, REQ-017

#### Test Case: STP-009-A (Extended JSON Output With Lifecycle Fields)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Diff CLI external interface)
**Description**: Verify that the extended diff-requirements.sh script includes lifecycle transition fields in its JSON output alongside existing content-change fields.

* **System Scenario: STS-009-A1**
  * **Given** a requirements.md where REQ-005 is newly marked `[DEPRECATED — Withdrawn: obsolete]`, REQ-010 had its SUSPECT annotation resolved (removed), and REQ-015 is newly added, compared to the baseline in acceptance-plan.md
  * **When** diff-requirements.sh is invoked against the v-model directory
  * **Then** the JSON output contains: `added: ["REQ-015"]`, `deprecated: ["REQ-005"]`, `resolved_suspects: ["REQ-010"]` alongside standard content fields

#### Test Case: STP-009-B (Backward Compatibility With Existing Fields)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Diff CLI external interface)
**Description**: Verify that the existing `added`, `modified`, `removed` fields continue to function correctly alongside the new lifecycle fields.

* **System Scenario: STS-009-B1**
  * **Given** a requirements.md where REQ-002's description was changed (content modification) and REQ-015 was added, with no lifecycle transitions
  * **When** diff-requirements.sh is invoked against the v-model directory
  * **Then** the JSON output contains: `added: ["REQ-015"]`, `modified: ["REQ-002"]`, `removed: []`, `deprecated: []`, `new_suspects: []`, `resolved_suspects: []`

#### Test Case: STP-009-C (No Transitions Edge Case)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View (Diff Report entity)
**Description**: Verify that when no changes or lifecycle transitions have occurred, the diff script returns empty arrays for all fields.

* **System Scenario: STS-009-C1**
  * **Given** a requirements.md that is byte-identical to the version embedded in the current acceptance-plan.md
  * **When** diff-requirements.sh is invoked against the v-model directory
  * **Then** the JSON output contains all empty arrays: `added: [], modified: [], removed: [], deprecated: [], new_suspects: [], resolved_suspects: []`

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total System Components (SYS) | 9 (9 active, 0 deprecated) |
| Total Test Cases (STP) | 27 (27 active, 0 deprecated, 0 suspect) |
| Total Scenarios (STS) | 34 |
| Components with ≥1 STP | 9 / 9 (100%) (active items only) |
| Test Cases with ≥1 STS | 27 / 27 (100%) |
| **Overall Coverage (SYS→STP)** | **100%** (active items only) |

**Technique Distribution**: Interface Contract Testing: 19 | Boundary Value Analysis: 6 | Fault Injection: 2 | Total: 27

## Uncovered Components

None — full coverage achieved.

**Generated**: 2026-04-18
**Language Compliance**: Zero user-journey phrases — all scenarios use component-oriented technical language.
