# Unit Test Plan: 006b — ID Lifecycle Model


**Feature Branch**: `feature/006b-id-lifecycle`
**Created**: 2026-04-18
**Status**: Draft
**Source**: `specs/006b-id-lifecycle/v-model/module-design.md`

## Overview

This document defines the Unit Test Plan for the ID Lifecycle Model feature. Every module design (`MOD-NNN`) in `module-design.md` has one or more Test Cases (`UTP-NNN-X`), and every Test Case has one or more executable Unit Scenarios (`UTS-NNN-X#`) in white-box Arrange/Act/Assert format. Unit tests verify **internal module logic** — control flow, data transformations, and variable boundaries. All 21 modules are stateless, so State Transition Testing is not applicable.

## ID Schema

- **Unit Test Case**: `UTP-{NNN}-{X}` — where NNN matches the parent MOD, X is a letter suffix (A, B, C...)
- **Unit Test Scenario**: `UTS-{NNN}-{X}{#}` — nested under the parent UTP, with numeric suffix (1, 2, 3...)
- Example: `UTS-001-A1` → Scenario 1 of Test Case A verifying MOD-001
- ID lineage: from `UTS-001-A1`, a regex extracts `UTP-001-A` and `MOD-001`. To find the `ARCH-NNN` ancestor, consult the "Parent Architecture Modules" field in `module-design.md`.

## ISO 29119-4 White-Box Techniques

| Technique | Source View | What It Tests |
|-----------|------------|---------------|
| **Statement & Branch Coverage (SBC)** | Algorithmic/Logic View | Every line and every True/False branch outcome |
| **Boundary Value Analysis (BVA)** | Internal Data Structures | Scalar variable boundaries: min-1, min, mid, max, max+1 |
| **Equivalence Partitioning (EP)** | Internal Data Structures | Discrete non-scalar types: Booleans, Enums |
| **Strict Isolation (SI)** | Architecture Interface View | Every external dependency mocked/stubbed |

Note: State Transition Testing is not applicable — all 21 modules are stateless.

## Unit Tests

### Module: MOD-001 (parse_annotations)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `scripts/bash/parse-annotations.sh`

#### Test Case: UTP-001-A (Branch Coverage for Annotation Pattern Matching)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise every branch in the pattern-matching cascade: supersession match, withdrawal match, suspect-deprecated match, suspect-modified match, active (no match), and line with no ID.

**Dependency & Mock Registry:**

None — module is self-contained (operates on string input only).

* **Unit Scenario: UTS-001-A1** (supersession branch)
  * **Arrange**: Set `artifact_text` = `"| REQ-005 | Description [DEPRECATED — Superseded by REQ-012] |"`
  * **Act**: Call `parse_annotations(artifact_text)`
  * **Assert**: Returns `[{id: "REQ-005", state: DEPRECATED, type: "supersession", target: "REQ-012"}]`

* **Unit Scenario: UTS-001-A2** (withdrawal branch)
  * **Arrange**: Set `artifact_text` = `"| REQ-007 | Description [DEPRECATED — Withdrawn: regulatory change] |"`
  * **Act**: Call `parse_annotations(artifact_text)`
  * **Assert**: Returns `[{id: "REQ-007", state: DEPRECATED, type: "withdrawal", reason: "regulatory change"}]`

* **Unit Scenario: UTS-001-A3** (suspect-deprecated branch)
  * **Arrange**: Set `artifact_text` = `"| ATP-003-A | Test [SUSPECT — Parent REQ-003 deprecated] |"`
  * **Act**: Call `parse_annotations(artifact_text)`
  * **Assert**: Returns `[{id: "ATP-003-A", state: SUSPECT, type: "deprecated", parent: "REQ-003"}]`

* **Unit Scenario: UTS-001-A4** (suspect-modified branch)
  * **Arrange**: Set `artifact_text` = `"| SYS-002 | Design [SUSPECT — Parent REQ-010 modified] |"`
  * **Act**: Call `parse_annotations(artifact_text)`
  * **Assert**: Returns `[{id: "SYS-002", state: SUSPECT, type: "modified", parent: "REQ-010"}]`

* **Unit Scenario: UTS-001-A5** (active — no annotation)
  * **Arrange**: Set `artifact_text` = `"| REQ-001 | A valid requirement |"`
  * **Act**: Call `parse_annotations(artifact_text)`
  * **Assert**: Returns `[{id: "REQ-001", state: ACTIVE}]`

* **Unit Scenario: UTS-001-A6** (line with no ID — skip branch)
  * **Arrange**: Set `artifact_text` = `"## Section Header\nSome description text"`
  * **Act**: Call `parse_annotations(artifact_text)`
  * **Assert**: Returns `[]` (empty list)

* **Unit Scenario: UTS-001-A7** (malformed annotation — partial match)
  * **Arrange**: Set `artifact_text` = `"| REQ-009 | Description [DEPRECATED — Superseded by] |"` (missing successor ID)
  * **Act**: Call `parse_annotations(artifact_text)`
  * **Assert**: Raises MalformedAnnotation `{id: "REQ-009", raw_text: "[DEPRECATED — Superseded by]", issue: "missing successor ID"}`

#### Test Case: UTP-001-B (Boundary Values for Artifact Size)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Test the `lines` list boundary — empty input, single line, and large multi-line artifact.

**Dependency & Mock Registry:**

None — module is self-contained.

* **Unit Scenario: UTS-001-B1** (min: empty input)
  * **Arrange**: Set `artifact_text` = `""`
  * **Act**: Call `parse_annotations(artifact_text)`
  * **Assert**: Returns `[]`; `lines` list has 1 element (empty string)

* **Unit Scenario: UTS-001-B2** (min+1: single line with ID)
  * **Arrange**: Set `artifact_text` = `"| REQ-001 | Single |"`
  * **Act**: Call `parse_annotations(artifact_text)`
  * **Assert**: Returns 1 annotation; loop iterates exactly once

* **Unit Scenario: UTS-001-B3** (mid: 10 lines, mixed annotations)
  * **Arrange**: Set `artifact_text` to 10 lines with 3 DEPRECATED, 2 SUSPECT, 3 ACTIVE, 2 non-ID lines
  * **Act**: Call `parse_annotations(artifact_text)`
  * **Assert**: Returns 8 annotations; `annotations.length` equals 8

---

### Module: MOD-002 (classify_state)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `scripts/bash/parse-annotations.sh`

#### Test Case: UTP-002-A (Branch Coverage for State Classification)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise the nested if/else cascade: DEPRECATED-supersession, DEPRECATED-withdrawal, DEPRECATED-unknown, SUSPECT-deprecated, SUSPECT-modified, and ACTIVE.

**Dependency & Mock Registry:**

None — module is self-contained.

* **Unit Scenario: UTS-002-A1** (DEPRECATED supersession path)
  * **Arrange**: Set `raw_annotation` = `"[DEPRECATED — Superseded by REQ-012]"`, `id` = `"REQ-005"`
  * **Act**: Call `classify_state(raw_annotation, id)`
  * **Assert**: Returns `{id: "REQ-005", state: DEPRECATED, type: "supersession", target: "REQ-012"}`

* **Unit Scenario: UTS-002-A2** (DEPRECATED withdrawal path)
  * **Arrange**: Set `raw_annotation` = `"[DEPRECATED — Withdrawn: scope reduced]"`, `id` = `"REQ-007"`
  * **Act**: Call `classify_state(raw_annotation, id)`
  * **Assert**: Returns `{id: "REQ-007", state: DEPRECATED, type: "withdrawal", reason: "scope reduced"}`

* **Unit Scenario: UTS-002-A3** (DEPRECATED unknown subtype — error path)
  * **Arrange**: Set `raw_annotation` = `"[DEPRECATED — Unknown reason]"`, `id` = `"REQ-009"`
  * **Act**: Call `classify_state(raw_annotation, id)`
  * **Assert**: Raises MalformedAnnotation `{id: "REQ-009", issue: "unrecognized DEPRECATED subtype"}`

* **Unit Scenario: UTS-002-A4** (ACTIVE — no annotation)
  * **Arrange**: Set `raw_annotation` = `""`, `id` = `"REQ-001"`
  * **Act**: Call `classify_state(raw_annotation, id)`
  * **Assert**: Returns `{id: "REQ-001", state: ACTIVE}`

#### Test Case: UTP-002-B (Equivalence Partitioning for State Enum)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition the `state` output across all valid enum values and one invalid partition.

**Dependency & Mock Registry:**

None — module is self-contained.

* **Unit Scenario: UTS-002-B1** (partition: DEPRECATED)
  * **Arrange**: Set `raw_annotation` containing `[DEPRECATED`
  * **Act**: Call `classify_state(raw_annotation, "REQ-005")`
  * **Assert**: Returned `state` equals `DEPRECATED`

* **Unit Scenario: UTS-002-B2** (partition: SUSPECT)
  * **Arrange**: Set `raw_annotation` containing `[SUSPECT`
  * **Act**: Call `classify_state(raw_annotation, "ATP-003")`
  * **Assert**: Returned `state` equals `SUSPECT`

* **Unit Scenario: UTS-002-B3** (partition: ACTIVE)
  * **Arrange**: Set `raw_annotation` = `""` (no annotation markers)
  * **Act**: Call `classify_state(raw_annotation, "REQ-001")`
  * **Assert**: Returned `state` equals `ACTIVE`

---

### Module: MOD-003 (validate_transition)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `scripts/bash/validate-transition.sh`

#### Test Case: UTP-003-A (Branch Coverage for Transition Validation)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise the ALLOWED matrix lookup for valid and invalid transitions.

**Dependency & Mock Registry:**

None — module is self-contained.

* **Unit Scenario: UTS-003-A1** (valid: ACTIVE→DEPRECATED)
  * **Arrange**: Set `current_state` = `ACTIVE`, `target_state` = `DEPRECATED`
  * **Act**: Call `validate_transition(current_state, target_state)`
  * **Assert**: Returns `{valid: true}`

* **Unit Scenario: UTS-003-A2** (valid: SUSPECT→ACTIVE)
  * **Arrange**: Set `current_state` = `SUSPECT`, `target_state` = `ACTIVE`
  * **Act**: Call `validate_transition(current_state, target_state)`
  * **Assert**: Returns `{valid: true}`

* **Unit Scenario: UTS-003-A3** (invalid: DEPRECATED→ACTIVE)
  * **Arrange**: Set `current_state` = `DEPRECATED`, `target_state` = `ACTIVE`
  * **Act**: Call `validate_transition(current_state, target_state)`
  * **Assert**: Returns `{valid: false, error: InvalidTransition({from: DEPRECATED, to: ACTIVE})}`

#### Test Case: UTP-003-B (Equivalence Partitioning for State Pairs)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition all 9 state pairs (3×3 matrix) into valid and invalid classes.

**Dependency & Mock Registry:**

None — module is self-contained.

* **Unit Scenario: UTS-003-B1** (valid pair: ACTIVE→SUSPECT)
  * **Arrange**: Set `current_state` = `ACTIVE`, `target_state` = `SUSPECT`
  * **Act**: Call `validate_transition(ACTIVE, SUSPECT)`
  * **Assert**: Returns `{valid: true}`

* **Unit Scenario: UTS-003-B2** (valid pair: SUSPECT→DEPRECATED)
  * **Arrange**: Set `current_state` = `SUSPECT`, `target_state` = `DEPRECATED`
  * **Act**: Call `validate_transition(SUSPECT, DEPRECATED)`
  * **Assert**: Returns `{valid: true}`

* **Unit Scenario: UTS-003-B3** (invalid pair: DEPRECATED→SUSPECT)
  * **Arrange**: Set `current_state` = `DEPRECATED`, `target_state` = `SUSPECT`
  * **Act**: Call `validate_transition(DEPRECATED, SUSPECT)`
  * **Assert**: Returns `{valid: false}` with reason "transition from DEPRECATED to SUSPECT is not permitted"

* **Unit Scenario: UTS-003-B4** (self-transition: ACTIVE→ACTIVE)
  * **Arrange**: Set `current_state` = `ACTIVE`, `target_state` = `ACTIVE`
  * **Act**: Call `validate_transition(ACTIVE, ACTIVE)`
  * **Assert**: Returns `{valid: false}` — self-transitions not in ALLOWED matrix

---

### Module: MOD-004 (write_supersession)

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `scripts/bash/annotation-handlers.sh`

#### Test Case: UTP-004-A (Branch Coverage for Supersession Write)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise the validation branches (empty successor, invalid pattern, valid write).

**Dependency & Mock Registry:**

None — module is self-contained.

* **Unit Scenario: UTS-004-A1** (valid write)
  * **Arrange**: Set `id` = `"REQ-005"`, `successor_id` = `"REQ-012"`
  * **Act**: Call `write_supersession(id, successor_id)`
  * **Assert**: Returns `"[DEPRECATED — Superseded by REQ-012]"` with em dash U+2014

* **Unit Scenario: UTS-004-A2** (empty successor — error branch)
  * **Arrange**: Set `id` = `"REQ-005"`, `successor_id` = `""`
  * **Act**: Call `write_supersession(id, successor_id)`
  * **Assert**: Raises MissingSuccessor `{id: "REQ-005", issue: "successor_id is required"}`

* **Unit Scenario: UTS-004-A3** (invalid pattern — error branch)
  * **Arrange**: Set `id` = `"REQ-005"`, `successor_id` = `"not-an-id"`
  * **Act**: Call `write_supersession(id, successor_id)`
  * **Assert**: Raises MissingSuccessor `{id: "REQ-005", issue: "successor_id must match {PREFIX}-NNN pattern"}`

---

### Module: MOD-005 (parse_supersession)

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `scripts/bash/annotation-handlers.sh`

#### Test Case: UTP-005-A (Branch Coverage for Supersession Parse)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise match and no-match branches.

**Dependency & Mock Registry:**

None — module is self-contained.

* **Unit Scenario: UTS-005-A1** (match found)
  * **Arrange**: Set `annotation_text` = `"[DEPRECATED — Superseded by REQ-012]"`
  * **Act**: Call `parse_supersession(annotation_text)`
  * **Assert**: Returns `{type: "supersession", target: "REQ-012"}`

* **Unit Scenario: UTS-005-A2** (no match — different annotation type)
  * **Arrange**: Set `annotation_text` = `"[DEPRECATED — Withdrawn: reason]"`
  * **Act**: Call `parse_supersession(annotation_text)`
  * **Assert**: Returns `NULL`

---

### Module: MOD-006 (write_withdrawal)

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `scripts/bash/annotation-handlers.sh`

#### Test Case: UTP-006-A (Branch Coverage for Withdrawal Write)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise valid write, empty reason, and whitespace-only reason branches.

**Dependency & Mock Registry:**

None — module is self-contained.

* **Unit Scenario: UTS-006-A1** (valid write)
  * **Arrange**: Set `id` = `"REQ-007"`, `reason` = `"regulatory change"`
  * **Act**: Call `write_withdrawal(id, reason)`
  * **Assert**: Returns `"[DEPRECATED — Withdrawn: regulatory change]"` with em dash U+2014

* **Unit Scenario: UTS-006-A2** (empty reason — error branch)
  * **Arrange**: Set `id` = `"REQ-007"`, `reason` = `""`
  * **Act**: Call `write_withdrawal(id, reason)`
  * **Assert**: Raises MissingReason `{id: "REQ-007", issue: "reason is required"}`

* **Unit Scenario: UTS-006-A3** (whitespace-only reason — error branch)
  * **Arrange**: Set `id` = `"SYS-003"`, `reason` = `"   "` (three spaces)
  * **Act**: Call `write_withdrawal(id, reason)`
  * **Assert**: Raises MissingReason `{id: "SYS-003", issue: "reason is required"}`

---

### Module: MOD-007 (parse_withdrawal)

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `scripts/bash/annotation-handlers.sh`

#### Test Case: UTP-007-A (Branch Coverage for Withdrawal Parse)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise match and no-match branches.

**Dependency & Mock Registry:**

None — module is self-contained.

* **Unit Scenario: UTS-007-A1** (match found)
  * **Arrange**: Set `annotation_text` = `"[DEPRECATED — Withdrawn: scope reduced]"`
  * **Act**: Call `parse_withdrawal(annotation_text)`
  * **Assert**: Returns `{type: "withdrawal", reason: "scope reduced"}`

* **Unit Scenario: UTS-007-A2** (no match)
  * **Arrange**: Set `annotation_text` = `"[SUSPECT — Parent REQ-003 deprecated]"`
  * **Act**: Call `parse_withdrawal(annotation_text)`
  * **Assert**: Returns `NULL`

---

### Module: MOD-008 (resolve_parent_links)

**Parent Architecture Modules**: ARCH-005
**Target Source File(s)**: `scripts/bash/resolve-parent-links.sh`

#### Test Case: UTP-008-A (Branch Coverage for Link Resolution)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise branches: ID found with links, ID found without links, no IDs found, multiple link patterns.

**Dependency & Mock Registry:**

None — module is self-contained (operates on string input only).

* **Unit Scenario: UTS-008-A1** (links found — normal path)
  * **Arrange**: Set `artifact_text` = `"| ATP-003-A | Linked Requirement: REQ-003 |"`, `link_patterns` = `[/Linked Requirement: (REQ-\d+)/]`
  * **Act**: Call `resolve_parent_links(artifact_text, link_patterns)`
  * **Assert**: Returns `{"ATP-003-A": ["REQ-003"]}`; `link_map` has 1 entry

* **Unit Scenario: UTS-008-A2** (no links found — warning path)
  * **Arrange**: Set `artifact_text` = `""` (empty), `link_patterns` = `[/Linked Requirement: (REQ-\d+)/]`
  * **Act**: Call `resolve_parent_links(artifact_text, link_patterns)`
  * **Assert**: Returns `{}`; emits NoLinksFound warning

* **Unit Scenario: UTS-008-A3** (multiple parents per downstream ID)
  * **Arrange**: Set `artifact_text` = `"| SYS-001 | Parent Requirements: REQ-001, REQ-005 |"`, `link_patterns` = `[/(REQ-\d+)/g]`
  * **Act**: Call `resolve_parent_links(artifact_text, link_patterns)`
  * **Assert**: Returns `{"SYS-001": ["REQ-001", "REQ-005"]}`

* **Unit Scenario: UTS-008-A4** (duplicate parent — deduplication branch)
  * **Arrange**: Set `artifact_text` with REQ-001 mentioned twice on the same line for SYS-001
  * **Act**: Call `resolve_parent_links(artifact_text, link_patterns)`
  * **Assert**: `link_map["SYS-001"]` contains `"REQ-001"` exactly once

---

### Module: MOD-009 (write_suspect_annotations)

**Parent Architecture Modules**: ARCH-006
**Target Source File(s)**: `scripts/bash/write-suspect-annotations.sh`

#### Test Case: UTP-009-A (Branch Coverage for Suspect Writing)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise branches: empty items list, found ID, ID not found, deprecated vs modified reason.

**Dependency & Mock Registry:**

None — module is self-contained (operates on string input only).

* **Unit Scenario: UTS-009-A1** (empty items — early return)
  * **Arrange**: Set `artifact_text` = `"| ATP-003-A | Test |"`, `suspect_items` = `[]`
  * **Act**: Call `write_suspect_annotations(artifact_text, suspect_items)`
  * **Assert**: Returns original `artifact_text` unchanged

* **Unit Scenario: UTS-009-A2** (deprecated reason — write path)
  * **Arrange**: Set `artifact_text` = `"| ATP-003-A | Test case |"`, `suspect_items` = `[{downstream_id: "ATP-003-A", parent_id: "REQ-003", reason: "deprecated"}]`
  * **Act**: Call `write_suspect_annotations(artifact_text, suspect_items)`
  * **Assert**: Returns text containing `"ATP-003-A [SUSPECT — Parent REQ-003 deprecated]"`

* **Unit Scenario: UTS-009-A3** (modified reason — write path)
  * **Arrange**: Set `artifact_text` = `"| SYS-002 | Component |"`, `suspect_items` = `[{downstream_id: "SYS-002", parent_id: "REQ-010", reason: "modified"}]`
  * **Act**: Call `write_suspect_annotations(artifact_text, suspect_items)`
  * **Assert**: Returns text containing `"SYS-002 [SUSPECT — Parent REQ-010 modified]"`

* **Unit Scenario: UTS-009-A4** (ID not found — error path)
  * **Arrange**: Set `artifact_text` = `"| ATP-001 | Test |"`, `suspect_items` = `[{downstream_id: "ATP-099", parent_id: "REQ-003", reason: "deprecated"}]`
  * **Act**: Call `write_suspect_annotations(artifact_text, suspect_items)`
  * **Assert**: Raises IDNotFound `{downstream_id: "ATP-099", issue: "ID not found in artifact"}`

#### Test Case: UTP-009-B (Equivalence Partitioning for Reason Enum)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition the `reason` field across valid values and invalid partition.

**Dependency & Mock Registry:**

None — module is self-contained.

* **Unit Scenario: UTS-009-B1** (partition: "deprecated")
  * **Arrange**: Set `suspect_items` with `reason` = `"deprecated"`
  * **Act**: Call `write_suspect_annotations` with one item
  * **Assert**: Annotation text contains `"deprecated"` keyword

* **Unit Scenario: UTS-009-B2** (partition: "modified")
  * **Arrange**: Set `suspect_items` with `reason` = `"modified"`
  * **Act**: Call `write_suspect_annotations` with one item
  * **Assert**: Annotation text contains `"modified"` keyword

---

### Module: MOD-010 (dispatch_resolution)

**Parent Architecture Modules**: ARCH-007
**Target Source File(s)**: `scripts/bash/resolve-suspect.sh`

#### Test Case: UTP-010-A (Branch Coverage for Resolution Dispatching)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise all 4 branches: auto-blocked, re-parent, deprecate, confirm-valid.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| validate_transition (MOD-003) | ARCH-002 Interface | Stub: returns `{valid: true}` for valid, `{valid: false}` for invalid | Isolate dispatch logic from validation logic |
| write_supersession (MOD-004) | ARCH-003 Interface | Stub: returns `"[DEPRECATED — Superseded by REQ-012]"` | Isolate from annotation construction |
| write_withdrawal (MOD-006) | ARCH-004 Interface | Stub: returns `"[DEPRECATED — Withdrawn: reason]"` | Isolate from annotation construction |

* **Unit Scenario: UTS-010-A1** (auto-resolution blocked — first guard)
  * **Arrange**: Set `resolution` = `{id: "SYS-003", action: "confirm-valid", human_instruction: false}`
  * **Act**: Call `dispatch_resolution(resolution, artifact_text)`
  * **Assert**: Raises AutoResolutionBlocked `{id: "SYS-003"}`; no dependency stubs invoked

* **Unit Scenario: UTS-010-A2** (re-parent — happy path)
  * **Arrange**: Set `resolution` = `{id: "ATP-003-A", action: "re-parent", successor_id: "REQ-012", human_instruction: true}`, stub `validate_transition` returns `{valid: true}`, stub `write_supersession` returns annotation
  * **Act**: Call `dispatch_resolution(resolution, artifact_text)`
  * **Assert**: Returns artifact with SUSPECT annotation removed and parent link updated to REQ-012

* **Unit Scenario: UTS-010-A3** (deprecate — happy path)
  * **Arrange**: Set `resolution` = `{id: "SYS-003", action: "deprecate", reason: "parent withdrawn", human_instruction: true}`, stub returns valid
  * **Act**: Call `dispatch_resolution(resolution, artifact_text)`
  * **Assert**: Returns artifact with SUSPECT replaced by DEPRECATED annotation

* **Unit Scenario: UTS-010-A4** (confirm-valid — happy path)
  * **Arrange**: Set `resolution` = `{id: "SYS-002", action: "confirm-valid", human_instruction: true}`, stub returns valid
  * **Act**: Call `dispatch_resolution(resolution, artifact_text)`
  * **Assert**: Returns artifact with SUSPECT annotation removed; content unchanged

* **Unit Scenario: UTS-010-A5** (invalid transition — validation failure)
  * **Arrange**: Set `resolution` = `{id: "REQ-005", action: "re-parent", successor_id: "REQ-012", human_instruction: true}`, stub `validate_transition` returns `{valid: false, error: InvalidTransition}`
  * **Act**: Call `dispatch_resolution(resolution, artifact_text)`
  * **Assert**: Raises InvalidTransition; artifact unchanged

#### Test Case: UTP-010-B (Equivalence Partitioning for Action Enum)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition the `action` field across 3 valid values and invalid partition.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| (same as UTP-010-A) | | | |

* **Unit Scenario: UTS-010-B1** (partition: "re-parent")
  * **Arrange**: Set `resolution.action` = `"re-parent"` with valid successor
  * **Act**: Call `dispatch_resolution(resolution, artifact_text)`
  * **Assert**: Code path enters the re-parent case branch

* **Unit Scenario: UTS-010-B2** (partition: "deprecate")
  * **Arrange**: Set `resolution.action` = `"deprecate"` with valid reason
  * **Act**: Call `dispatch_resolution(resolution, artifact_text)`
  * **Assert**: Code path enters the deprecate case branch

* **Unit Scenario: UTS-010-B3** (partition: "confirm-valid")
  * **Arrange**: Set `resolution.action` = `"confirm-valid"`
  * **Act**: Call `dispatch_resolution(resolution, artifact_text)`
  * **Assert**: Code path enters the confirm-valid case branch

#### Test Case: UTP-010-C (Strict Isolation of External Dependencies)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verify that dispatch_resolution never calls real implementations of its 3 dependencies.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| validate_transition (MOD-003) | ARCH-002 | Spy: records call arguments | Verify correct state pair passed |
| write_supersession (MOD-004) | ARCH-003 | Spy: records call arguments | Verify correct id and successor passed |
| write_withdrawal (MOD-006) | ARCH-004 | Spy: records call arguments | Verify correct id and reason passed |

* **Unit Scenario: UTS-010-C1** (re-parent isolation)
  * **Arrange**: Set spy on `validate_transition` and `write_supersession`; resolution = re-parent
  * **Act**: Call `dispatch_resolution(resolution, artifact_text)`
  * **Assert**: `validate_transition` spy called with `(SUSPECT, ACTIVE)`; `write_supersession` spy called with `("ATP-003-A", "REQ-012")`

* **Unit Scenario: UTS-010-C2** (deprecate isolation)
  * **Arrange**: Set spy on `validate_transition` and `write_withdrawal`; resolution = deprecate
  * **Act**: Call `dispatch_resolution(resolution, artifact_text)`
  * **Assert**: `validate_transition` spy called with `(SUSPECT, DEPRECATED)`; `write_withdrawal` spy called with `("SYS-003", "parent withdrawn")`

---

### Module: MOD-011 (enforce_human_instruction)

**Parent Architecture Modules**: ARCH-007
**Target Source File(s)**: `scripts/bash/resolve-suspect.sh`

#### Test Case: UTP-011-A (Branch Coverage for Human Instruction Validation)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise all validation branches: null flag, false flag, invalid action, missing required fields, valid instruction.

**Dependency & Mock Registry:**

None — module is self-contained.

* **Unit Scenario: UTS-011-A1** (null flag — false branch)
  * **Arrange**: Set `resolution.human_instruction` = `NULL`
  * **Act**: Call `enforce_human_instruction(resolution)`
  * **Assert**: Returns `FALSE`

* **Unit Scenario: UTS-011-A2** (false flag — false branch)
  * **Arrange**: Set `resolution.human_instruction` = `FALSE`
  * **Act**: Call `enforce_human_instruction(resolution)`
  * **Assert**: Returns `FALSE`

* **Unit Scenario: UTS-011-A3** (invalid action — false branch)
  * **Arrange**: Set `resolution.human_instruction` = `TRUE`, `resolution.action` = `"auto-fix"`
  * **Act**: Call `enforce_human_instruction(resolution)`
  * **Assert**: Returns `FALSE`

* **Unit Scenario: UTS-011-A4** (missing successor for re-parent — false branch)
  * **Arrange**: Set `resolution` = `{human_instruction: TRUE, action: "re-parent", successor_id: ""}`
  * **Act**: Call `enforce_human_instruction(resolution)`
  * **Assert**: Returns `FALSE`

* **Unit Scenario: UTS-011-A5** (valid instruction — true branch)
  * **Arrange**: Set `resolution` = `{human_instruction: TRUE, action: "confirm-valid"}`
  * **Act**: Call `enforce_human_instruction(resolution)`
  * **Assert**: Returns `TRUE`

---

### Module: MOD-012 (compare_parent_artifacts)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `scripts/bash/compare-parent-artifacts.sh`

#### Test Case: UTP-012-A (Branch Coverage for Parent Comparison)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise branches: empty existing output (first-time), normal comparison with traced IDs, parent ID not traced.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| parse_annotations (MOD-001) | ARCH-001 Interface | Stub: returns predefined annotation list | Isolate comparison logic |
| resolve_parent_links (MOD-008) | ARCH-005 Interface | Stub: returns predefined link map | Isolate link resolution |
| classify_ids (MOD-013) | ARCH-009 Interface | Stub: returns predefined classifications | Isolate classification logic |

* **Unit Scenario: UTS-012-A1** (first-time generation — empty output branch)
  * **Arrange**: Set `parent_text` with 3 REQs, `existing_output` = `""`, stubs configured
  * **Act**: Call `compare_parent_artifacts(parent_text, existing_output, link_patterns)`
  * **Assert**: `link_map` is `{}`; all 3 parent IDs have `is_traced: false`; `classify_ids` called with 3 pairs

* **Unit Scenario: UTS-012-A2** (normal comparison — mixed traced/untraced)
  * **Arrange**: Set `parent_text` with 5 REQs, `existing_output` with links to 4 of them, stubs configured
  * **Act**: Call `compare_parent_artifacts(parent_text, existing_output, link_patterns)`
  * **Assert**: 4 pairs have `is_traced: true`, 1 has `is_traced: false`

* **Unit Scenario: UTS-012-A3** (parent artifact empty)
  * **Arrange**: Set `parent_text` = `""`, `existing_output` with links
  * **Act**: Call `compare_parent_artifacts(parent_text, existing_output, link_patterns)`
  * **Assert**: `parent_id_set` is empty; returns empty classifications

#### Test Case: UTP-012-B (Strict Isolation of Dependencies)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verify that compare_parent_artifacts delegates to its 3 dependencies correctly.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| parse_annotations (MOD-001) | ARCH-001 | Spy | Verify parent_text passed correctly |
| resolve_parent_links (MOD-008) | ARCH-005 | Spy | Verify existing_output passed correctly |
| classify_ids (MOD-013) | ARCH-009 | Spy | Verify comparison_pairs passed correctly |

* **Unit Scenario: UTS-012-B1** (delegation verification)
  * **Arrange**: Set spies on all 3 dependencies; provide valid inputs
  * **Act**: Call `compare_parent_artifacts(parent_text, existing_output, link_patterns)`
  * **Assert**: `parse_annotations` spy called once with `parent_text`; `resolve_parent_links` spy called once with `existing_output`; `classify_ids` spy called once with computed pairs

---

### Module: MOD-013 (classify_ids)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `scripts/bash/classify-ids.sh`

#### Test Case: UTP-013-A (Branch Coverage for ID Classification)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise the 3 classification branches: deprecated, added (untraced), unchanged (traced).

**Dependency & Mock Registry:**

None — module is self-contained.

* **Unit Scenario: UTS-013-A1** (deprecated path)
  * **Arrange**: Set `comparison_pairs` = `[{parent_id: "REQ-005", state: DEPRECATED, is_traced: true}]`
  * **Act**: Call `classify_ids(comparison_pairs, link_map)`
  * **Assert**: Returns `[{id: "REQ-005", status: "deprecated"}]`

* **Unit Scenario: UTS-013-A2** (added path — untraced)
  * **Arrange**: Set `comparison_pairs` = `[{parent_id: "REQ-015", state: ACTIVE, is_traced: false}]`
  * **Act**: Call `classify_ids(comparison_pairs, link_map)`
  * **Assert**: Returns `[{id: "REQ-015", status: "added"}]`

* **Unit Scenario: UTS-013-A3** (unchanged path — traced and active)
  * **Arrange**: Set `comparison_pairs` = `[{parent_id: "REQ-001", state: ACTIVE, is_traced: true}]`
  * **Act**: Call `classify_ids(comparison_pairs, link_map)`
  * **Assert**: Returns `[{id: "REQ-001", status: "unchanged"}]`

#### Test Case: UTP-013-B (Equivalence Partitioning for Status Enum)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition the output `status` field across all 4 valid enum values.

**Dependency & Mock Registry:**

None — module is self-contained.

* **Unit Scenario: UTS-013-B1** (partition: "unchanged")
  * **Arrange**: Set pair with state=ACTIVE, is_traced=true
  * **Act**: Call `classify_ids`
  * **Assert**: Status equals `"unchanged"`

* **Unit Scenario: UTS-013-B2** (partition: "modified")
  * **Arrange**: Set pair with state=ACTIVE, is_traced=true (LLM override to "modified")
  * **Act**: Call `classify_ids` (in LLM-overridden context)
  * **Assert**: Status equals `"modified"`

* **Unit Scenario: UTS-013-B3** (partition: "deprecated")
  * **Arrange**: Set pair with state=DEPRECATED
  * **Act**: Call `classify_ids`
  * **Assert**: Status equals `"deprecated"`

* **Unit Scenario: UTS-013-B4** (partition: "added")
  * **Arrange**: Set pair with state=ACTIVE, is_traced=false
  * **Act**: Call `classify_ids`
  * **Assert**: Status equals `"added"`

---

### Module: MOD-014 (generate_lifecycle_section)

**Parent Architecture Modules**: ARCH-010
**Target Source File(s)**: `scripts/bash/generate-lifecycle-section.sh`

#### Test Case: UTP-014-A (Branch Coverage for Section Generation)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise the valid-prefix path and invalid-prefix error path.

**Dependency & Mock Registry:**

None — module is self-contained.

* **Unit Scenario: UTS-014-A1** (valid prefix — REQ)
  * **Arrange**: Set `id_prefix` = `"REQ"`
  * **Act**: Call `generate_lifecycle_section(id_prefix)`
  * **Assert**: Returns string containing "### Lifecycle Rules", 5 subsection headings, and `"REQ-NNN"` in never-delete text

* **Unit Scenario: UTS-014-A2** (valid prefix — UTP)
  * **Arrange**: Set `id_prefix` = `"UTP"`
  * **Act**: Call `generate_lifecycle_section(id_prefix)`
  * **Assert**: Returns string with `"UTP-NNN"` substituted in all 5 subsections

* **Unit Scenario: UTS-014-A3** (invalid prefix — error branch)
  * **Arrange**: Set `id_prefix` = `"INVALID"`
  * **Act**: Call `generate_lifecycle_section(id_prefix)`
  * **Assert**: Raises UnknownPrefix `{prefix: "INVALID", issue: "not a recognized ID prefix"}`

#### Test Case: UTP-014-B (Equivalence Partitioning for Prefix Enum)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition the `id_prefix` input across all 9 recognized values and invalid partition.

**Dependency & Mock Registry:**

None — module is self-contained.

* **Unit Scenario: UTS-014-B1** (partition: "REQ")
  * **Arrange**: Set `id_prefix` = `"REQ"`
  * **Act**: Call `generate_lifecycle_section("REQ")`
  * **Assert**: Section `section` variable contains "REQ-NNN"

* **Unit Scenario: UTS-014-B2** (partition: "HAZ")
  * **Arrange**: Set `id_prefix` = `"HAZ"`
  * **Act**: Call `generate_lifecycle_section("HAZ")`
  * **Assert**: Section `section` variable contains "HAZ-NNN"

* **Unit Scenario: UTS-014-B3** (invalid partition: empty string)
  * **Arrange**: Set `id_prefix` = `""`
  * **Act**: Call `generate_lifecycle_section("")`
  * **Assert**: Raises UnknownPrefix

---

### Module: MOD-015 (insert_section)

**Parent Architecture Modules**: ARCH-011
**Target Source File(s)**: `scripts/bash/inject-lifecycle-rules.sh`

#### Test Case: UTP-015-A (Branch Coverage for Section Insertion)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise branches: successful insertion, section already exists (idempotent), insertion point not found.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system (read_file/write_file) | OS | Stub: in-memory file content | Avoid modifying actual command files |

* **Unit Scenario: UTS-015-A1** (successful insertion)
  * **Arrange**: Set `content` = `"### 3. Load existing\n...\n### 4. Generate\n..."`, `section_text` = `"### Lifecycle Rules\n..."`
  * **Act**: Call `insert_section(command_file_path, section_text)`
  * **Assert**: Returns `TRUE`; `updated_content` contains Lifecycle Rules between step 3 and step 4

* **Unit Scenario: UTS-015-A2** (idempotent — section already exists)
  * **Arrange**: Set `content` containing `"### Lifecycle Rules"` already
  * **Act**: Call `insert_section(command_file_path, section_text)`
  * **Assert**: Returns `TRUE`; emits SectionAlreadyExists warning; file content unchanged

* **Unit Scenario: UTS-015-A3** (insertion point not found)
  * **Arrange**: Set `content` = `"## Some other structure"` (no "Load existing" step)
  * **Act**: Call `insert_section(command_file_path, section_text)`
  * **Assert**: Raises InsertionPointNotFound `{file: command_file_path}`; file unchanged

---

### Module: MOD-016 (compute_active_denominator)

**Parent Architecture Modules**: ARCH-012
**Target Source File(s)**: `scripts/bash/build-matrix.sh`

#### Test Case: UTP-016-A (Branch Coverage for Denominator Computation)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise the DEPRECATED vs non-DEPRECATED branch in the counting loop.

**Dependency & Mock Registry:**

None — module is self-contained.

* **Unit Scenario: UTS-016-A1** (mixed states)
  * **Arrange**: Set `all_ids` = `[{state: ACTIVE}, {state: DEPRECATED}, {state: SUSPECT}, {state: ACTIVE}]`
  * **Act**: Call `compute_active_denominator(all_ids)`
  * **Assert**: Returns `{active_count: 3, deprecated_count: 1}`

* **Unit Scenario: UTS-016-A2** (all deprecated)
  * **Arrange**: Set `all_ids` = `[{state: DEPRECATED}, {state: DEPRECATED}]`
  * **Act**: Call `compute_active_denominator(all_ids)`
  * **Assert**: Returns `{active_count: 0, deprecated_count: 2}`

#### Test Case: UTP-016-B (Boundary Values for ID List Size)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Test the `all_ids` list boundary — empty list, single element, typical list.

**Dependency & Mock Registry:**

None — module is self-contained.

* **Unit Scenario: UTS-016-B1** (min: empty list)
  * **Arrange**: Set `all_ids` = `[]`
  * **Act**: Call `compute_active_denominator(all_ids)`
  * **Assert**: Returns `{active_count: 0, deprecated_count: 0}`

* **Unit Scenario: UTS-016-B2** (min+1: single ACTIVE item)
  * **Arrange**: Set `all_ids` = `[{state: ACTIVE}]`
  * **Act**: Call `compute_active_denominator(all_ids)`
  * **Assert**: Returns `{active_count: 1, deprecated_count: 0}`

* **Unit Scenario: UTS-016-B3** (mid: 10 items)
  * **Arrange**: Set `all_ids` to 10 items (7 ACTIVE, 2 DEPRECATED, 1 SUSPECT)
  * **Act**: Call `compute_active_denominator(all_ids)`
  * **Assert**: Returns `{active_count: 8, deprecated_count: 2}`

---

### Module: MOD-017 (generate_suspect_summary)

**Parent Architecture Modules**: ARCH-013
**Target Source File(s)**: `scripts/bash/build-matrix.sh`

#### Test Case: UTP-017-A (Branch Coverage for Suspect Summary)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise empty suspects (early return) and populated suspects (table generation) branches.

**Dependency & Mock Registry:**

None — module is self-contained.

* **Unit Scenario: UTS-017-A1** (empty suspects — early return)
  * **Arrange**: Set `all_annotations` = `[{id: "REQ-001", state: ACTIVE}]` (no SUSPECT items)
  * **Act**: Call `generate_suspect_summary(all_annotations)`
  * **Assert**: Returns `""` (empty string)

* **Unit Scenario: UTS-017-A2** (suspects present — table generation)
  * **Arrange**: Set `all_annotations` including `{id: "ATP-003-A", state: SUSPECT, parent: "REQ-003", type: "deprecated"}`
  * **Act**: Call `generate_suspect_summary(all_annotations)`
  * **Assert**: Returns string starting with `"## Suspect Items"` and containing `"ATP-003-A"` in a table row

* **Unit Scenario: UTS-017-A3** (multiple suspects — loop iteration)
  * **Arrange**: Set `all_annotations` with 3 SUSPECT items among 7 total annotations
  * **Act**: Call `generate_suspect_summary(all_annotations)`
  * **Assert**: Table contains exactly 3 data rows (plus header and separator)

---

### Module: MOD-018 (build_deprecation_chains)

**Parent Architecture Modules**: ARCH-014
**Target Source File(s)**: `scripts/bash/build-matrix.sh`

#### Test Case: UTP-018-A (Branch Coverage for Chain Building)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise branches: empty list, supersession with valid chain, supersession with broken chain, withdrawal.

**Dependency & Mock Registry:**

None — module is self-contained.

* **Unit Scenario: UTS-018-A1** (empty deprecated — early return)
  * **Arrange**: Set `deprecated_annotations` = `[]`
  * **Act**: Call `build_deprecation_chains(deprecated_annotations, all_ids)`
  * **Assert**: Returns `""` (empty string)

* **Unit Scenario: UTS-018-A2** (supersession — valid chain)
  * **Arrange**: Set `deprecated_annotations` = `[{id: "REQ-005", type: "supersession", target: "REQ-012"}]`, `all_ids` = `{"REQ-012", ...}`
  * **Act**: Call `build_deprecation_chains(deprecated_annotations, all_ids)`
  * **Assert**: Table row contains `"→ REQ-012"` and `"✓"`; `chain_valid` = `true`

* **Unit Scenario: UTS-018-A3** (supersession — broken chain)
  * **Arrange**: Set `deprecated_annotations` = `[{id: "REQ-005", type: "supersession", target: "REQ-099"}]`, `all_ids` does NOT contain `"REQ-099"`
  * **Act**: Call `build_deprecation_chains(deprecated_annotations, all_ids)`
  * **Assert**: Table row contains `"⚠ Broken"`; BrokenChain warning emitted

* **Unit Scenario: UTS-018-A4** (withdrawal — no chain validation)
  * **Arrange**: Set `deprecated_annotations` = `[{id: "REQ-007", type: "withdrawal", reason: "scope reduced"}]`
  * **Act**: Call `build_deprecation_chains(deprecated_annotations, all_ids)`
  * **Assert**: Table row contains `"scope reduced"` and `"—"`

---

### Module: MOD-019 (emit_formal_tags)

**Parent Architecture Modules**: ARCH-015
**Target Source File(s)**: `commands/impact-analysis.md`

#### Test Case: UTP-019-A (Branch Coverage for Tag Emission)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise all 4 case branches: DEPRECATED, SUSPECT, MODIFIED, ACTIVE.

**Dependency & Mock Registry:**

None — module is self-contained.

* **Unit Scenario: UTS-019-A1** (DEPRECATED branch)
  * **Arrange**: Set `impact_items` = `[{id: "REQ-003", state: DEPRECATED}]`
  * **Act**: Call `emit_formal_tags(impact_items)`
  * **Assert**: Returns `[{id: "REQ-003", tag: "[DEPRECATED]"}]`

* **Unit Scenario: UTS-019-A2** (ACTIVE branch — no tag)
  * **Arrange**: Set `impact_items` = `[{id: "REQ-001", state: ACTIVE}]`
  * **Act**: Call `emit_formal_tags(impact_items)`
  * **Assert**: Returns `[{id: "REQ-001", tag: ""}]`

#### Test Case: UTP-019-B (Equivalence Partitioning for State Enum)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition the `state` input across all 4 valid values.

**Dependency & Mock Registry:**

None — module is self-contained.

* **Unit Scenario: UTS-019-B1** (partition: DEPRECATED)
  * **Arrange**: Set `item.state` = `DEPRECATED`
  * **Act**: Call `emit_formal_tags([item])`
  * **Assert**: `tag` equals `"[DEPRECATED]"`

* **Unit Scenario: UTS-019-B2** (partition: SUSPECT)
  * **Arrange**: Set `item.state` = `SUSPECT`
  * **Act**: Call `emit_formal_tags([item])`
  * **Assert**: `tag` equals `"[SUSPECT]"`

* **Unit Scenario: UTS-019-B3** (partition: MODIFIED)
  * **Arrange**: Set `item.state` = `MODIFIED`
  * **Act**: Call `emit_formal_tags([item])`
  * **Assert**: `tag` equals `"[MODIFIED]"`

* **Unit Scenario: UTS-019-B4** (partition: ACTIVE)
  * **Arrange**: Set `item.state` = `ACTIVE`
  * **Act**: Call `emit_formal_tags([item])`
  * **Assert**: `tag` equals `""` (empty string)

---

### Module: MOD-020 (detect_lifecycle_transitions)

**Parent Architecture Modules**: ARCH-016
**Target Source File(s)**: `scripts/bash/diff-requirements.sh`

#### Test Case: UTP-020-A (Branch Coverage for Transition Detection)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise branches: new deprecation, new suspect, resolved suspect, removed ID (skip), new ID (skip).

**Dependency & Mock Registry:**

None — module is self-contained.

* **Unit Scenario: UTS-020-A1** (new deprecation detected)
  * **Arrange**: Set `current_annotations` = `[{id: "REQ-005", state: DEPRECATED}]`, `baseline_annotations` = `[{id: "REQ-005", state: ACTIVE}]`
  * **Act**: Call `detect_lifecycle_transitions(current_annotations, baseline_annotations)`
  * **Assert**: Returns `{deprecated: ["REQ-005"], new_suspects: [], resolved_suspects: []}`

* **Unit Scenario: UTS-020-A2** (new suspect detected)
  * **Arrange**: Set `current_annotations` = `[{id: "REQ-010", state: SUSPECT}]`, `baseline_annotations` = `[{id: "REQ-010", state: ACTIVE}]`
  * **Act**: Call `detect_lifecycle_transitions(current_annotations, baseline_annotations)`
  * **Assert**: Returns `{deprecated: [], new_suspects: ["REQ-010"], resolved_suspects: []}`

* **Unit Scenario: UTS-020-A3** (resolved suspect detected)
  * **Arrange**: Set `current_annotations` = `[{id: "REQ-010", state: ACTIVE}]`, `baseline_annotations` = `[{id: "REQ-010", state: SUSPECT}]`
  * **Act**: Call `detect_lifecycle_transitions(current_annotations, baseline_annotations)`
  * **Assert**: Returns `{deprecated: [], new_suspects: [], resolved_suspects: ["REQ-010"]}`

* **Unit Scenario: UTS-020-A4** (removed ID — skip)
  * **Arrange**: Set `current_annotations` = `[]`, `baseline_annotations` = `[{id: "REQ-015", state: ACTIVE}]`
  * **Act**: Call `detect_lifecycle_transitions(current_annotations, baseline_annotations)`
  * **Assert**: Returns `{deprecated: [], new_suspects: [], resolved_suspects: []}` — removed IDs handled by existing diff

* **Unit Scenario: UTS-020-A5** (new ID — skip)
  * **Arrange**: Set `current_annotations` = `[{id: "REQ-020", state: ACTIVE}]`, `baseline_annotations` = `[]`
  * **Act**: Call `detect_lifecycle_transitions(current_annotations, baseline_annotations)`
  * **Assert**: Returns `{deprecated: [], new_suspects: [], resolved_suspects: []}` — new IDs handled by existing diff

#### Test Case: UTP-020-B (Equivalence Partitioning for Transition Types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partition the detected transitions across 3 output arrays.

**Dependency & Mock Registry:**

None — module is self-contained.

* **Unit Scenario: UTS-020-B1** (all three transition types present)
  * **Arrange**: Set current with REQ-005=DEPRECATED, REQ-010=SUSPECT, REQ-002=ACTIVE; baseline with REQ-005=ACTIVE, REQ-010=ACTIVE, REQ-002=SUSPECT
  * **Act**: Call `detect_lifecycle_transitions(current, baseline)`
  * **Assert**: `deprecated` = `["REQ-005"]`, `new_suspects` = `["REQ-010"]`, `resolved_suspects` = `["REQ-002"]`

* **Unit Scenario: UTS-020-B2** (no transitions — all unchanged)
  * **Arrange**: Set current = baseline = `[{id: "REQ-001", state: ACTIVE}]`
  * **Act**: Call `detect_lifecycle_transitions(current, baseline)`
  * **Assert**: All 3 arrays empty

---

### Module: MOD-021 (format_extended_json)

**Parent Architecture Modules**: ARCH-017
**Target Source File(s)**: `scripts/bash/diff-requirements.sh`

#### Test Case: UTP-021-A (Branch Coverage for JSON Formatting)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercise the main construction path and the backward-compatibility guard branches.

**Dependency & Mock Registry:**

None — module is self-contained.

* **Unit Scenario: UTS-021-A1** (all fields populated)
  * **Arrange**: Set `content_changes` = `{added: ["REQ-015"], modified: ["REQ-002"], removed: []}`, `lifecycle_transitions` = `{deprecated: ["REQ-005"], new_suspects: [], resolved_suspects: ["REQ-010"]}`
  * **Act**: Call `format_extended_json(content_changes, lifecycle_transitions)`
  * **Assert**: Returns valid JSON string with 6 keys; `JSON.parse()` succeeds; `added` = `["REQ-015"]`, `deprecated` = `["REQ-005"]`

* **Unit Scenario: UTS-021-A2** (empty arrays — backward compatibility)
  * **Arrange**: Set `content_changes` = `{added: [], modified: [], removed: []}`, `lifecycle_transitions` = `{deprecated: [], new_suspects: [], resolved_suspects: []}`
  * **Act**: Call `format_extended_json(content_changes, lifecycle_transitions)`
  * **Assert**: Returns valid JSON with all 6 keys present (not omitted); each value is `[]`

* **Unit Scenario: UTS-021-A3** (missing added field — guard branch)
  * **Arrange**: Set `content_changes` without `added` key
  * **Act**: Call `format_extended_json(content_changes, lifecycle_transitions)`
  * **Assert**: Output JSON contains `"added": []` (default injected); backward compatibility preserved

---

## External Module Bypass

None — all 21 modules are non-external.

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Modules (MOD) | 21 |
| Modules tested | 21 |
| Modules bypassed (`[EXTERNAL]`) | 0 |
| Total Test Cases (UTP) | 33 (33 active, 0 deprecated, 0 suspect) |
| Total Scenarios (UTS) | 107 |
| Modules with ≥1 UTP | 21 / 21 (100%) (active items only) |
| Test Cases with ≥1 UTS | 33 / 33 (100%) |
| **Overall Coverage (MOD→UTP)** | **100%** (active items only) |

### Technique Distribution

| Technique | Test Cases | Percentage |
|-----------|-----------|------------|
| Statement & Branch Coverage | 21 | 64% |
| Equivalence Partitioning | 8 | 24% |
| Boundary Value Analysis | 2 | 6% |
| Strict Isolation | 2 | 6% |
| State Transition Testing | 0 | 0% (all modules stateless) |
| MC/DC Coverage | 0 | 0% (no safety-critical domain configured) |

## Uncovered Modules

None — full coverage achieved.

**Generated**: 2026-04-18
**Language Compliance**: Zero user-journey phrases, zero integration phrases, zero system-level phrases — all white-box Arrange/Act/Assert.
