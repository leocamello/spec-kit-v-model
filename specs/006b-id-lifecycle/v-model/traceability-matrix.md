# Traceability Matrix

**Generated**: 2026-04-18
**Source**: `specs/006b-id-lifecycle/v-model/`

## Matrix A — Validation (User View)

| Requirement ID | Requirement Description | Test Case ID (ATP) | Validation Condition | Scenario ID (SCN) | Status |
|----------------|------------------------|--------------------|----------------------|--------------------|--------|
| **REQ-001** | Each V-Model artifact ID SHALL support four lifecycle states: ACTIVE (default, no annotation), DEPRECATED (annotated), MODIFIED (content changed in-place, downstream notified), and SUSPECT (parent changed, review needed). | ATP-001-A | All Four States Representable | SCN-001-A1 | ⬜ Untested |
| | | ATP-001-B | ACTIVE State Has No Annotation | SCN-001-B1 | ⬜ Untested |
| **REQ-002** | The DEPRECATED state SHALL support a Supersession type with the syntax `[DEPRECATED — Superseded by {PREFIX}-NNN]`, indicating the capability continues under a new ID. | ATP-002-A | Valid Supersession Annotation | SCN-002-A1 | ⬜ Untested |
| | | ATP-002-B | Supersession With Missing Successor ID | SCN-002-B1 | ⬜ Untested |
| **REQ-003** | The DEPRECATED state SHALL support a Withdrawal type with the syntax `[DEPRECATED — Withdrawn: {reason}]`, indicating the capability is removed entirely with a mandatory justification. | ATP-003-A | Valid Withdrawal Annotation | SCN-003-A1 | ⬜ Untested |
| | | ATP-003-B | Withdrawal With Missing Reason | SCN-003-B1 | ⬜ Untested |
| **REQ-004** | When a parent ID transitions to DEPRECATED, all immediate downstream IDs that trace to it SHALL be marked `[SUSPECT — Parent {ID} deprecated]` by the next command invocation that processes those downstream artifacts. | ATP-004-A | Downstream Items Marked SUSPECT | SCN-004-A1 | ⬜ Untested |
| | | ATP-004-B | No Downstream Items Exist | SCN-004-B1 | ⬜ Untested |
| **REQ-005** | When a parent ID transitions to MODIFIED (content changed, ID preserved), all immediate downstream IDs that trace to it SHALL be marked `[SUSPECT — Parent {ID} modified]` by the next command invocation that processes those downstream artifacts. | ATP-005-A | Modified Parent Produces SUSPECT Children | SCN-005-A1 | ⬜ Untested |
| | | ATP-005-B | Modification With No Content Change | SCN-005-B1 | ⬜ Untested |
| **REQ-006** | Each SUSPECT item SHALL be resolved through exactly one of three actions: (a) re-parent to the superseding ID if the capability continues under a new ID, (b) deprecate if the capability is removed, or (c) confirm still valid if the item remains correct despite the parent change. | ATP-006-A | Re-parent Resolution | SCN-006-A1 | ⬜ Untested |
| | | ATP-006-B | Deprecate Resolution | SCN-006-B1 | ⬜ Untested |
| | | ATP-006-C | Confirm Still Valid Resolution | SCN-006-C1 | ⬜ Untested |
| **REQ-007** | IDs SHALL never be deleted from V-Model artifacts — lifecycle transitions SHALL preserve the ID in the artifact text with an inline annotation. | ATP-007-A | Deprecated IDs Remain In Artifact | SCN-007-A1 | ⬜ Untested |
| | | ATP-007-B | Resolved SUSPECT IDs Remain | SCN-007-B1 | ⬜ Untested |
| **REQ-008** | Each of the 9 ID-bearing generative commands (requirements, acceptance, system-design, system-test, architecture-design, integration-test, module-design, unit-test, hazard-analysis) SHALL include a standardized Lifecycle Rules section. | ATP-008-A | All 9 ID-Bearing Commands Include Section | SCN-008-A1 | ⬜ Untested |
| | | ATP-008-B | Peer-Review Excluded | SCN-008-B1 | ⬜ Untested |
| **REQ-009** | The Lifecycle Rules section SHALL be positioned between the existing "Load existing artifact" step and the "Generate new content" step in each command's execution flow. | ATP-009-A | Correct Position in Execution Flow | SCN-009-A1 | ⬜ Untested |
| **REQ-010** | Each lifecycle-aware command SHALL perform change detection by: (a) reading the parent artifact, (b) reading its own existing output, (c) comparing parent IDs against traced parent links in the existing output, and (d) classifying each parent ID as unchanged, modified, deprecated, or added. | ATP-010-A | Correctly Classifies Parent ID States | SCN-010-A1 | ⬜ Untested |
| | | ATP-010-B | No Changes Detected | SCN-010-B1 | ⬜ Untested |
| **REQ-011** | The change detection mechanism SHALL be performed by the LLM as part of the command's instruction flow — it SHALL NOT require a new external script for each command. | ATP-011-A | Detection Without Script Dependency | SCN-011-A1 | ⬜ Untested |
| **REQ-012** | The existing `diff-requirements.sh` script used by the acceptance command SHALL continue to serve as a deterministic accelerator alongside the LLM's comparison for the requirements→acceptance transition specifically. | ATP-012-A | Script Continues Working for Acceptance | SCN-012-A1 | ⬜ Untested |
| **REQ-013** | The `trace` command SHALL exclude DEPRECATED items from coverage metric denominators so that retiring requirements does not reduce coverage percentages. | ATP-013-A | Coverage Not Reduced by Deprecation | SCN-013-A1 | ⬜ Untested |
| | | ATP-013-B | Deprecated With Uncovered Active REQs | SCN-013-B1 | ⬜ Untested |
| **REQ-014** | The `trace` command SHALL report SUSPECT items in a dedicated summary section, listing each suspect item with its parent change reason. | ATP-014-A | Dedicated Suspect Summary Section | SCN-014-A1 | ⬜ Untested |
| **REQ-015** | The `trace` command SHALL report deprecated chains separately from active chains, showing the full deprecation lineage. | ATP-015-A | Deprecated Chain in Separate Section | SCN-015-A1 | ⬜ Untested |
| **REQ-016** | The `impact-analysis` command SHALL use formal lifecycle state syntax (`[DEPRECATED]`, `[MODIFIED]`, `[SUSPECT]`) in its output, replacing informal suspect reporting. | ATP-016-A | Formal Lifecycle Tags in Output | SCN-016-A1 | ⬜ Untested |
| **REQ-017** | The `diff-requirements.sh` script SHALL be extended to detect lifecycle transitions: new deprecations, new suspects, and resolved suspects, in addition to its existing content addition and removal detection. | ATP-017-A | Detects Lifecycle Transitions | SCN-017-A1 | ⬜ Untested |
| **REQ-018** | Lifecycle annotations SHALL be embedded as inline text within the Markdown artifact (e.g., appended to the ID's heading or table row), with no external state file or database. | ATP-018-A | Annotations Embedded in Text | SCN-018-A1 | ⬜ Untested |
| | | ATP-018-B | No External State Files Created | SCN-018-B1 | ⬜ Untested |
| **REQ-019** | The Lifecycle Rules section text SHALL be identical across all 9 commands, with only the ID prefix varying (e.g., REQ for requirements, SYS for system-design, ARCH for architecture-design). | ATP-019-A | Section Text Matches Across All 9 Commands | SCN-019-A1 | ⬜ Untested |
| **REQ-CN-001** | Suspect resolution SHALL NOT be automated — every suspect item SHALL require human review (or the next command invocation with human review) before being resolved. | ATP-CN-001-A | SUSPECT Items Require Human Review | SCN-CN-001-A1 | ⬜ Untested |
| **REQ-CN-002** | Multi-level suspect cascade SHALL require separate command invocations per V-Model level — there SHALL be no single-command "cascade through all levels" action. | ATP-CN-002-A | No Single-Command Multi-Level Cascade | SCN-CN-002-A1 | ⬜ Untested |
| **REQ-CN-003** | This feature SHALL NOT modify, add, or remove any commands — it SHALL only add content (lifecycle rules sections) to existing command files. | ATP-CN-003-A | Command Count Unchanged | SCN-CN-003-A1 | ⬜ Untested |
| **REQ-CN-004** | This feature SHALL NOT include domain overlay architecture, bridge commands, or version history within artifacts — those are separate features (006a, M1, and future scope respectively). | ATP-CN-004-A | Excluded Features Not Present | SCN-CN-004-A1 | ⬜ Untested |
| **REQ-NF-001** | During forward development (building a specification from scratch with no pre-existing IDs), the lifecycle model SHALL produce zero lifecycle annotations — commands SHALL work exactly as they do today (preserve and append). | ATP-NF-001-A | Fresh Build Produces No Annotations | SCN-NF-001-A1 | ⬜ Untested |
| **REQ-NF-002** | Git SHALL be the sole system of record for lifecycle transition history — no embedded changelogs or revision tables within artifacts. | ATP-NF-002-A | No Embedded Changelogs | SCN-NF-002-A1 | ⬜ Untested |

### Matrix A Coverage

| Metric | Value |
|--------|-------|
| **Total Requirements** | 25 |
| **Total Test Cases (ATP)** | 37 |
| **Total Scenarios (SCN)** | 37 |
| **REQ → ATP Coverage** | 25/25 (100%) |
| **ATP → SCN Coverage** | 37/37 (100%) |

## Matrix B — Verification (Architectural View)

| Requirement ID | System Component (SYS) | Component Name | Test Case ID (STP) | Technique | Scenario ID (STS) | Status |
|----------------|------------------------|----------------|--------------------|-----------|--------------------|--------|
| **REQ-001** | SYS-001 | Lifecycle State Model | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Lifecycle State Model | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Lifecycle State Model | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Lifecycle State Model | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Lifecycle State Model | STP-001-C | Interface Contract Testing | STS-001-C1 | ⬜ Untested |
| **REQ-002** | SYS-002 | Deprecation Annotation Engine | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Deprecation Annotation Engine | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Deprecation Annotation Engine | STP-002-B | Interface Contract Testing | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Deprecation Annotation Engine | STP-002-B | Interface Contract Testing | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Deprecation Annotation Engine | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Deprecation Annotation Engine | STP-002-C | Boundary Value Analysis | STS-002-C2 | ⬜ Untested |
| **REQ-003** | SYS-002 | Deprecation Annotation Engine | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Deprecation Annotation Engine | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Deprecation Annotation Engine | STP-002-B | Interface Contract Testing | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Deprecation Annotation Engine | STP-002-B | Interface Contract Testing | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Deprecation Annotation Engine | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Deprecation Annotation Engine | STP-002-C | Boundary Value Analysis | STS-002-C2 | ⬜ Untested |
| **REQ-004** | SYS-003 | Suspect Cascade Engine | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Suspect Cascade Engine | STP-003-B | Interface Contract Testing | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Suspect Cascade Engine | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| **REQ-005** | SYS-003 | Suspect Cascade Engine | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Suspect Cascade Engine | STP-003-B | Interface Contract Testing | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Suspect Cascade Engine | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| **REQ-006** | SYS-004 | Suspect Resolution Handler | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Suspect Resolution Handler | STP-004-B | Interface Contract Testing | STS-004-B1 | ⬜ Untested |
| | SYS-004 | Suspect Resolution Handler | STP-004-C | Interface Contract Testing | STS-004-C1 | ⬜ Untested |
| | SYS-004 | Suspect Resolution Handler | STP-004-D | Fault Injection | STS-004-D1 | ⬜ Untested |
| **REQ-007** | SYS-001 | Lifecycle State Model | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Lifecycle State Model | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Lifecycle State Model | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Lifecycle State Model | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Lifecycle State Model | STP-001-C | Interface Contract Testing | STS-001-C1 | ⬜ Untested |
| **REQ-008** | SYS-006 | Lifecycle Rules Section Injector | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Lifecycle Rules Section Injector | STP-006-B | Interface Contract Testing | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Lifecycle Rules Section Injector | STP-006-C | Boundary Value Analysis | STS-006-C1 | ⬜ Untested |
| | SYS-006 | Lifecycle Rules Section Injector | STP-006-D | Boundary Value Analysis | STS-006-D1 | ⬜ Untested |
| **REQ-009** | SYS-006 | Lifecycle Rules Section Injector | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Lifecycle Rules Section Injector | STP-006-B | Interface Contract Testing | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Lifecycle Rules Section Injector | STP-006-C | Boundary Value Analysis | STS-006-C1 | ⬜ Untested |
| | SYS-006 | Lifecycle Rules Section Injector | STP-006-D | Boundary Value Analysis | STS-006-D1 | ⬜ Untested |
| **REQ-010** | SYS-005 | Change Detection Engine | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Change Detection Engine | STP-005-B | Boundary Value Analysis | STS-005-B1 | ⬜ Untested |
| | SYS-005 | Change Detection Engine | STP-005-B | Boundary Value Analysis | STS-005-B2 | ⬜ Untested |
| | SYS-005 | Change Detection Engine | STP-005-C | Interface Contract Testing | STS-005-C1 | ⬜ Untested |
| **REQ-011** | SYS-005 | Change Detection Engine | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Change Detection Engine | STP-005-B | Boundary Value Analysis | STS-005-B1 | ⬜ Untested |
| | SYS-005 | Change Detection Engine | STP-005-B | Boundary Value Analysis | STS-005-B2 | ⬜ Untested |
| | SYS-005 | Change Detection Engine | STP-005-C | Interface Contract Testing | STS-005-C1 | ⬜ Untested |
| **REQ-012** | SYS-009 | Lifecycle-Aware Diff Engine | STP-009-A | Interface Contract Testing | STS-009-A1 | ⬜ Untested |
| | SYS-009 | Lifecycle-Aware Diff Engine | STP-009-B | Interface Contract Testing | STS-009-B1 | ⬜ Untested |
| | SYS-009 | Lifecycle-Aware Diff Engine | STP-009-C | Boundary Value Analysis | STS-009-C1 | ⬜ Untested |
| **REQ-013** | SYS-007 | Lifecycle-Aware Trace Reporter | STP-007-A | Interface Contract Testing | STS-007-A1 | ⬜ Untested |
| | SYS-007 | Lifecycle-Aware Trace Reporter | STP-007-B | Interface Contract Testing | STS-007-B1 | ⬜ Untested |
| | SYS-007 | Lifecycle-Aware Trace Reporter | STP-007-C | Interface Contract Testing | STS-007-C1 | ⬜ Untested |
| **REQ-014** | SYS-007 | Lifecycle-Aware Trace Reporter | STP-007-A | Interface Contract Testing | STS-007-A1 | ⬜ Untested |
| | SYS-007 | Lifecycle-Aware Trace Reporter | STP-007-B | Interface Contract Testing | STS-007-B1 | ⬜ Untested |
| | SYS-007 | Lifecycle-Aware Trace Reporter | STP-007-C | Interface Contract Testing | STS-007-C1 | ⬜ Untested |
| **REQ-015** | SYS-007 | Lifecycle-Aware Trace Reporter | STP-007-A | Interface Contract Testing | STS-007-A1 | ⬜ Untested |
| | SYS-007 | Lifecycle-Aware Trace Reporter | STP-007-B | Interface Contract Testing | STS-007-B1 | ⬜ Untested |
| | SYS-007 | Lifecycle-Aware Trace Reporter | STP-007-C | Interface Contract Testing | STS-007-C1 | ⬜ Untested |
| **REQ-016** | SYS-008 | Lifecycle-Aware Impact Analyzer | STP-008-A | Interface Contract Testing | STS-008-A1 | ⬜ Untested |
| | SYS-008 | Lifecycle-Aware Impact Analyzer | STP-008-A | Interface Contract Testing | STS-008-A2 | ⬜ Untested |
| **REQ-017** | SYS-009 | Lifecycle-Aware Diff Engine | STP-009-A | Interface Contract Testing | STS-009-A1 | ⬜ Untested |
| | SYS-009 | Lifecycle-Aware Diff Engine | STP-009-B | Interface Contract Testing | STS-009-B1 | ⬜ Untested |
| | SYS-009 | Lifecycle-Aware Diff Engine | STP-009-C | Boundary Value Analysis | STS-009-C1 | ⬜ Untested |
| **REQ-018** | SYS-001 | Lifecycle State Model | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Lifecycle State Model | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Lifecycle State Model | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Lifecycle State Model | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Lifecycle State Model | STP-001-C | Interface Contract Testing | STS-001-C1 | ⬜ Untested |
| **REQ-019** | SYS-006 | Lifecycle Rules Section Injector | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Lifecycle Rules Section Injector | STP-006-B | Interface Contract Testing | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Lifecycle Rules Section Injector | STP-006-C | Boundary Value Analysis | STS-006-C1 | ⬜ Untested |
| | SYS-006 | Lifecycle Rules Section Injector | STP-006-D | Boundary Value Analysis | STS-006-D1 | ⬜ Untested |
| **REQ-CN-001** | SYS-004 | Suspect Resolution Handler | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Suspect Resolution Handler | STP-004-B | Interface Contract Testing | STS-004-B1 | ⬜ Untested |
| | SYS-004 | Suspect Resolution Handler | STP-004-C | Interface Contract Testing | STS-004-C1 | ⬜ Untested |
| | SYS-004 | Suspect Resolution Handler | STP-004-D | Fault Injection | STS-004-D1 | ⬜ Untested |
| **REQ-CN-002** | SYS-003 | Suspect Cascade Engine | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Suspect Cascade Engine | STP-003-B | Interface Contract Testing | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Suspect Cascade Engine | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| **REQ-CN-003** | SYS-006 | Lifecycle Rules Section Injector | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Lifecycle Rules Section Injector | STP-006-B | Interface Contract Testing | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Lifecycle Rules Section Injector | STP-006-C | Boundary Value Analysis | STS-006-C1 | ⬜ Untested |
| | SYS-006 | Lifecycle Rules Section Injector | STP-006-D | Boundary Value Analysis | STS-006-D1 | ⬜ Untested |
| **REQ-CN-004** | SYS-001 | Lifecycle State Model | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Lifecycle State Model | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Lifecycle State Model | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Lifecycle State Model | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Lifecycle State Model | STP-001-C | Interface Contract Testing | STS-001-C1 | ⬜ Untested |
| **REQ-NF-001** | SYS-001 | Lifecycle State Model | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Lifecycle State Model | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Lifecycle State Model | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Lifecycle State Model | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Lifecycle State Model | STP-001-C | Interface Contract Testing | STS-001-C1 | ⬜ Untested |
| | SYS-005 | Change Detection Engine | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Change Detection Engine | STP-005-B | Boundary Value Analysis | STS-005-B1 | ⬜ Untested |
| | SYS-005 | Change Detection Engine | STP-005-B | Boundary Value Analysis | STS-005-B2 | ⬜ Untested |
| | SYS-005 | Change Detection Engine | STP-005-C | Interface Contract Testing | STS-005-C1 | ⬜ Untested |
| **REQ-NF-002** | SYS-001 | Lifecycle State Model | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Lifecycle State Model | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Lifecycle State Model | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Lifecycle State Model | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Lifecycle State Model | STP-001-C | Interface Contract Testing | STS-001-C1 | ⬜ Untested |

### Matrix B Coverage

| Metric | Value |
|--------|-------|
| **Total System Components (SYS)** | 9 |
| **Total System Test Cases (STP)** | 27 |
| **Total System Scenarios (STS)** | 34 |
| **REQ → SYS Coverage** | 25/25 (100%) |
| **SYS → STP Coverage** | 9/9 (100%) |

## Matrix C — Integration Verification (Module Boundary View)

| System Component (SYS) | Parent REQs | Architecture Module (ARCH) | Module Name | Test Case ID (ITP) | Technique | Scenario ID (ITS) | Status |
|------------------------|-------------|---------------------------|-------------|--------------------|-----------|--------------------|--------|
| SYS-001 (REQ-001, REQ-007, REQ-018, REQ-NF-001, REQ-NF-002, REQ-CN-004) | REQ-001, REQ-007, REQ-018, REQ-NF-001, REQ-NF-002, REQ-CN-004 | ARCH-001 | Annotation Syntax Parser | ITP-001-A | Interface Contract Testing | ITS-001-A1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-007, REQ-018, REQ-NF-001, REQ-NF-002, REQ-CN-004) | REQ-001, REQ-007, REQ-018, REQ-NF-001, REQ-NF-002, REQ-CN-004 | ARCH-001 | Annotation Syntax Parser | ITP-001-B | Interface Fault Injection | ITS-001-B1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-007, REQ-018, REQ-NF-001, REQ-NF-002, REQ-CN-004) | REQ-001, REQ-007, REQ-018, REQ-NF-001, REQ-NF-002, REQ-CN-004 | ARCH-002 | State Transition Validator | ITP-002-A | Interface Contract Testing | ITS-002-A1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-007, REQ-018, REQ-NF-001, REQ-NF-002, REQ-CN-004) | REQ-001, REQ-007, REQ-018, REQ-NF-001, REQ-NF-002, REQ-CN-004 | ARCH-002 | State Transition Validator | ITP-002-A | Interface Contract Testing | ITS-002-A2 | ⬜ Untested |
| SYS-002 (REQ-002, REQ-003) | REQ-002, REQ-003 | ARCH-003 | Supersession Annotation Handler | ITP-003-A | Interface Contract Testing | ITS-003-A1 | ⬜ Untested |
| SYS-002 (REQ-002, REQ-003) | REQ-002, REQ-003 | ARCH-003 | Supersession Annotation Handler | ITP-003-B | Interface Fault Injection | ITS-003-B1 | ⬜ Untested |
| SYS-002 (REQ-002, REQ-003) | REQ-002, REQ-003 | ARCH-004 | Withdrawal Annotation Handler | ITP-004-A | Interface Contract Testing | ITS-004-A1 | ⬜ Untested |
| SYS-002 (REQ-002, REQ-003) | REQ-002, REQ-003 | ARCH-004 | Withdrawal Annotation Handler | ITP-004-B | Interface Fault Injection | ITS-004-B1 | ⬜ Untested |
| SYS-003 (REQ-004, REQ-005, REQ-CN-002) | REQ-004, REQ-005, REQ-CN-002 | ARCH-005 | Parent-Child Link Resolver | ITP-005-A | Interface Contract Testing | ITS-005-A1 | ⬜ Untested |
| SYS-003 (REQ-004, REQ-005, REQ-CN-002) | REQ-004, REQ-005, REQ-CN-002 | ARCH-005 | Parent-Child Link Resolver | ITP-005-B | Interface Fault Injection | ITS-005-B1 | ⬜ Untested |
| SYS-003 (REQ-004, REQ-005, REQ-CN-002) | REQ-004, REQ-005, REQ-CN-002 | ARCH-006 | Suspect Annotation Writer | ITP-006-A | Interface Contract Testing | ITS-006-A1 | ⬜ Untested |
| SYS-003 (REQ-004, REQ-005, REQ-CN-002) | REQ-004, REQ-005, REQ-CN-002 | ARCH-006 | Suspect Annotation Writer | ITP-006-B | Data Flow Testing | ITS-006-B1 | ⬜ Untested |
| SYS-004 (REQ-006, REQ-CN-001) | REQ-006, REQ-CN-001 | ARCH-007 | Resolution Dispatcher | ITP-007-A | Interface Contract Testing | ITS-007-A1 | ⬜ Untested |
| SYS-004 (REQ-006, REQ-CN-001) | REQ-006, REQ-CN-001 | ARCH-007 | Resolution Dispatcher | ITP-007-B | Interface Fault Injection | ITS-007-B1 | ⬜ Untested |
| SYS-004 (REQ-006, REQ-CN-001) | REQ-006, REQ-CN-001 | ARCH-007 | Resolution Dispatcher | ITP-007-C | Data Flow Testing | ITS-007-C1 | ⬜ Untested |
| SYS-005 (REQ-010, REQ-011, REQ-NF-001) | REQ-010, REQ-011, REQ-NF-001 | ARCH-008 | Parent Artifact Comparator | ITP-008-A | Interface Contract Testing | ITS-008-A1 | ⬜ Untested |
| SYS-005 (REQ-010, REQ-011, REQ-NF-001) | REQ-010, REQ-011, REQ-NF-001 | ARCH-008 | Parent Artifact Comparator | ITP-008-B | Interface Fault Injection | ITS-008-B1 | ⬜ Untested |
| SYS-005 (REQ-010, REQ-011, REQ-NF-001) | REQ-010, REQ-011, REQ-NF-001 | ARCH-009 | ID Classification Emitter | ITP-009-A | Interface Contract Testing | ITS-009-A1 | ⬜ Untested |
| SYS-006 (REQ-008, REQ-009, REQ-019, REQ-CN-003) | REQ-008, REQ-009, REQ-019, REQ-CN-003 | ARCH-010 | Section Template Generator | ITP-010-A | Interface Contract Testing | ITS-010-A1 | ⬜ Untested |
| SYS-006 (REQ-008, REQ-009, REQ-019, REQ-CN-003) | REQ-008, REQ-009, REQ-019, REQ-CN-003 | ARCH-011 | Command File Inserter | ITP-011-A | Interface Contract Testing | ITS-011-A1 | ⬜ Untested |
| SYS-006 (REQ-008, REQ-009, REQ-019, REQ-CN-003) | REQ-008, REQ-009, REQ-019, REQ-CN-003 | ARCH-011 | Command File Inserter | ITP-011-B | Interface Fault Injection | ITS-011-B1 | ⬜ Untested |
| SYS-007 (REQ-013, REQ-014, REQ-015) | REQ-013, REQ-014, REQ-015 | ARCH-012 | Coverage Denominator Calculator | ITP-012-A | Interface Contract Testing | ITS-012-A1 | ⬜ Untested |
| SYS-007 (REQ-013, REQ-014, REQ-015) | REQ-013, REQ-014, REQ-015 | ARCH-013 | Suspect Summary Generator | ITP-013-A | Interface Contract Testing | ITS-013-A1 | ⬜ Untested |
| SYS-007 (REQ-013, REQ-014, REQ-015) | REQ-013, REQ-014, REQ-015 | ARCH-014 | Deprecated Chain Reporter | ITP-014-A | Interface Contract Testing | ITS-014-A1 | ⬜ Untested |
| SYS-007 (REQ-013, REQ-014, REQ-015) | REQ-013, REQ-014, REQ-015 | ARCH-014 | Deprecated Chain Reporter | ITP-014-B | Interface Fault Injection | ITS-014-B1 | ⬜ Untested |
| SYS-007 (REQ-013, REQ-014, REQ-015) | REQ-013, REQ-014, REQ-015 | ARCH-014 | Deprecated Chain Reporter | ITP-014-C | Data Flow Testing | ITS-014-C1 | ⬜ Untested |
| SYS-008 (REQ-016) | REQ-016 | ARCH-015 | Formal Tag Emitter | ITP-015-A | Interface Contract Testing | ITS-015-A1 | ⬜ Untested |
| SYS-009 (REQ-012, REQ-017) | REQ-012, REQ-017 | ARCH-016 | Lifecycle Transition Detector | ITP-016-A | Interface Contract Testing | ITS-016-A1 | ⬜ Untested |
| SYS-009 (REQ-012, REQ-017) | REQ-012, REQ-017 | ARCH-016 | Lifecycle Transition Detector | ITP-016-B | Interface Fault Injection | ITS-016-B1 | ⬜ Untested |
| SYS-009 (REQ-012, REQ-017) | REQ-012, REQ-017 | ARCH-017 | Extended JSON Formatter | ITP-017-A | Interface Contract Testing | ITS-017-A1 | ⬜ Untested |
| SYS-009 (REQ-012, REQ-017) | REQ-012, REQ-017 | ARCH-017 | Extended JSON Formatter | ITP-017-B | Data Flow Testing | ITS-017-B1 | ⬜ Untested |

### Matrix C Coverage

| Metric | Value |
|--------|-------|
| **Total Architecture Modules (ARCH)** | 17 |
| **Total Cross-Cutting Modules** | 0 |
| **Total Integration Test Cases (ITP)** | 30 |
| **Total Integration Scenarios (ITS)** | 31 |
| **SYS → ARCH Coverage** | 9/9 (100%) |
| **ARCH → ITP Coverage** | 17/17 (100%) |

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
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | parse_annotations | UTP-001-A | Statement & Branch Coverage | UTS-001-A1 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | parse_annotations | UTP-001-A | Statement & Branch Coverage | UTS-001-A2 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | parse_annotations | UTP-001-A | Statement & Branch Coverage | UTS-001-A3 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | parse_annotations | UTP-001-A | Statement & Branch Coverage | UTS-001-A4 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | parse_annotations | UTP-001-A | Statement & Branch Coverage | UTS-001-A5 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | parse_annotations | UTP-001-A | Statement & Branch Coverage | UTS-001-A6 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | parse_annotations | UTP-001-A | Statement & Branch Coverage | UTS-001-A7 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | parse_annotations | UTP-001-B | Boundary Value Analysis | UTS-001-B1 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | parse_annotations | UTP-001-B | Boundary Value Analysis | UTS-001-B2 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | parse_annotations | UTP-001-B | Boundary Value Analysis | UTS-001-B3 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-002 | classify_state | UTP-002-A | Statement & Branch Coverage | UTS-002-A1 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-002 | classify_state | UTP-002-A | Statement & Branch Coverage | UTS-002-A2 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-002 | classify_state | UTP-002-A | Statement & Branch Coverage | UTS-002-A3 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-002 | classify_state | UTP-002-A | Statement & Branch Coverage | UTS-002-A4 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-002 | classify_state | UTP-002-B | Equivalence Partitioning | UTS-002-B1 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-002 | classify_state | UTP-002-B | Equivalence Partitioning | UTS-002-B2 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-002 | classify_state | UTP-002-B | Equivalence Partitioning | UTS-002-B3 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-003 | validate_transition | UTP-003-A | Statement & Branch Coverage | UTS-003-A1 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-003 | validate_transition | UTP-003-A | Statement & Branch Coverage | UTS-003-A2 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-003 | validate_transition | UTP-003-A | Statement & Branch Coverage | UTS-003-A3 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-003 | validate_transition | UTP-003-B | Equivalence Partitioning | UTS-003-B1 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-003 | validate_transition | UTP-003-B | Equivalence Partitioning | UTS-003-B2 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-003 | validate_transition | UTP-003-B | Equivalence Partitioning | UTS-003-B3 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-003 | validate_transition | UTP-003-B | Equivalence Partitioning | UTS-003-B4 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-004 | write_supersession | UTP-004-A | Statement & Branch Coverage | UTS-004-A1 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-004 | write_supersession | UTP-004-A | Statement & Branch Coverage | UTS-004-A2 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-004 | write_supersession | UTP-004-A | Statement & Branch Coverage | UTS-004-A3 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-005 | parse_supersession | UTP-005-A | Statement & Branch Coverage | UTS-005-A1 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-005 | parse_supersession | UTP-005-A | Statement & Branch Coverage | UTS-005-A2 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-006 | write_withdrawal | UTP-006-A | Statement & Branch Coverage | UTS-006-A1 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-006 | write_withdrawal | UTP-006-A | Statement & Branch Coverage | UTS-006-A2 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-006 | write_withdrawal | UTP-006-A | Statement & Branch Coverage | UTS-006-A3 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-007 | parse_withdrawal | UTP-007-A | Statement & Branch Coverage | UTS-007-A1 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-007 | parse_withdrawal | UTP-007-A | Statement & Branch Coverage | UTS-007-A2 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-008 | resolve_parent_links | UTP-008-A | Statement & Branch Coverage | UTS-008-A1 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-008 | resolve_parent_links | UTP-008-A | Statement & Branch Coverage | UTS-008-A2 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-008 | resolve_parent_links | UTP-008-A | Statement & Branch Coverage | UTS-008-A3 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-008 | resolve_parent_links | UTP-008-A | Statement & Branch Coverage | UTS-008-A4 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-009 | write_suspect_annotations | UTP-009-A | Statement & Branch Coverage | UTS-009-A1 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-009 | write_suspect_annotations | UTP-009-A | Statement & Branch Coverage | UTS-009-A2 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-009 | write_suspect_annotations | UTP-009-A | Statement & Branch Coverage | UTS-009-A3 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-009 | write_suspect_annotations | UTP-009-A | Statement & Branch Coverage | UTS-009-A4 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-009 | write_suspect_annotations | UTP-009-B | Equivalence Partitioning | UTS-009-B1 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-009 | write_suspect_annotations | UTP-009-B | Equivalence Partitioning | UTS-009-B2 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-010 | dispatch_resolution | UTP-010-A | Statement & Branch Coverage | UTS-010-A1 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-010 | dispatch_resolution | UTP-010-A | Statement & Branch Coverage | UTS-010-A2 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-010 | dispatch_resolution | UTP-010-A | Statement & Branch Coverage | UTS-010-A3 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-010 | dispatch_resolution | UTP-010-A | Statement & Branch Coverage | UTS-010-A4 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-010 | dispatch_resolution | UTP-010-A | Statement & Branch Coverage | UTS-010-A5 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-010 | dispatch_resolution | UTP-010-B | Equivalence Partitioning | UTS-010-B1 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-010 | dispatch_resolution | UTP-010-B | Equivalence Partitioning | UTS-010-B2 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-010 | dispatch_resolution | UTP-010-B | Equivalence Partitioning | UTS-010-B3 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-010 | dispatch_resolution | UTP-010-C | Strict Isolation | UTS-010-C1 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-010 | dispatch_resolution | UTP-010-C | Strict Isolation | UTS-010-C2 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-011 | enforce_human_instruction | UTP-011-A | Statement & Branch Coverage | UTS-011-A1 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-011 | enforce_human_instruction | UTP-011-A | Statement & Branch Coverage | UTS-011-A2 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-011 | enforce_human_instruction | UTP-011-A | Statement & Branch Coverage | UTS-011-A3 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-011 | enforce_human_instruction | UTP-011-A | Statement & Branch Coverage | UTS-011-A4 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-011 | enforce_human_instruction | UTP-011-A | Statement & Branch Coverage | UTS-011-A5 | ⬜ Untested |
| ARCH-008 (SYS-005) | SYS-005 | MOD-012 | compare_parent_artifacts | UTP-012-A | Statement & Branch Coverage | UTS-012-A1 | ⬜ Untested |
| ARCH-008 (SYS-005) | SYS-005 | MOD-012 | compare_parent_artifacts | UTP-012-A | Statement & Branch Coverage | UTS-012-A2 | ⬜ Untested |
| ARCH-008 (SYS-005) | SYS-005 | MOD-012 | compare_parent_artifacts | UTP-012-A | Statement & Branch Coverage | UTS-012-A3 | ⬜ Untested |
| ARCH-008 (SYS-005) | SYS-005 | MOD-012 | compare_parent_artifacts | UTP-012-B | Strict Isolation | UTS-012-B1 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-013 | classify_ids | UTP-013-A | Statement & Branch Coverage | UTS-013-A1 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-013 | classify_ids | UTP-013-A | Statement & Branch Coverage | UTS-013-A2 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-013 | classify_ids | UTP-013-A | Statement & Branch Coverage | UTS-013-A3 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-013 | classify_ids | UTP-013-B | Equivalence Partitioning | UTS-013-B1 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-013 | classify_ids | UTP-013-B | Equivalence Partitioning | UTS-013-B2 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-013 | classify_ids | UTP-013-B | Equivalence Partitioning | UTS-013-B3 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-013 | classify_ids | UTP-013-B | Equivalence Partitioning | UTS-013-B4 | ⬜ Untested |
| ARCH-010 (SYS-006) | SYS-006 | MOD-014 | generate_lifecycle_section | UTP-014-A | Statement & Branch Coverage | UTS-014-A1 | ⬜ Untested |
| ARCH-010 (SYS-006) | SYS-006 | MOD-014 | generate_lifecycle_section | UTP-014-A | Statement & Branch Coverage | UTS-014-A2 | ⬜ Untested |
| ARCH-010 (SYS-006) | SYS-006 | MOD-014 | generate_lifecycle_section | UTP-014-A | Statement & Branch Coverage | UTS-014-A3 | ⬜ Untested |
| ARCH-010 (SYS-006) | SYS-006 | MOD-014 | generate_lifecycle_section | UTP-014-B | Equivalence Partitioning | UTS-014-B1 | ⬜ Untested |
| ARCH-010 (SYS-006) | SYS-006 | MOD-014 | generate_lifecycle_section | UTP-014-B | Equivalence Partitioning | UTS-014-B2 | ⬜ Untested |
| ARCH-010 (SYS-006) | SYS-006 | MOD-014 | generate_lifecycle_section | UTP-014-B | Equivalence Partitioning | UTS-014-B3 | ⬜ Untested |
| ARCH-011 (SYS-006) | SYS-006 | MOD-015 | insert_section | UTP-015-A | Statement & Branch Coverage | UTS-015-A1 | ⬜ Untested |
| ARCH-011 (SYS-006) | SYS-006 | MOD-015 | insert_section | UTP-015-A | Statement & Branch Coverage | UTS-015-A2 | ⬜ Untested |
| ARCH-011 (SYS-006) | SYS-006 | MOD-015 | insert_section | UTP-015-A | Statement & Branch Coverage | UTS-015-A3 | ⬜ Untested |
| ARCH-012 (SYS-007) | SYS-007 | MOD-016 | compute_active_denominator | UTP-016-A | Statement & Branch Coverage | UTS-016-A1 | ⬜ Untested |
| ARCH-012 (SYS-007) | SYS-007 | MOD-016 | compute_active_denominator | UTP-016-A | Statement & Branch Coverage | UTS-016-A2 | ⬜ Untested |
| ARCH-012 (SYS-007) | SYS-007 | MOD-016 | compute_active_denominator | UTP-016-B | Boundary Value Analysis | UTS-016-B1 | ⬜ Untested |
| ARCH-012 (SYS-007) | SYS-007 | MOD-016 | compute_active_denominator | UTP-016-B | Boundary Value Analysis | UTS-016-B2 | ⬜ Untested |
| ARCH-012 (SYS-007) | SYS-007 | MOD-016 | compute_active_denominator | UTP-016-B | Boundary Value Analysis | UTS-016-B3 | ⬜ Untested |
| ARCH-013 (SYS-007) | SYS-007 | MOD-017 | generate_suspect_summary | UTP-017-A | Statement & Branch Coverage | UTS-017-A1 | ⬜ Untested |
| ARCH-013 (SYS-007) | SYS-007 | MOD-017 | generate_suspect_summary | UTP-017-A | Statement & Branch Coverage | UTS-017-A2 | ⬜ Untested |
| ARCH-013 (SYS-007) | SYS-007 | MOD-017 | generate_suspect_summary | UTP-017-A | Statement & Branch Coverage | UTS-017-A3 | ⬜ Untested |
| ARCH-014 (SYS-007) | SYS-007 | MOD-018 | build_deprecation_chains | UTP-018-A | Statement & Branch Coverage | UTS-018-A1 | ⬜ Untested |
| ARCH-014 (SYS-007) | SYS-007 | MOD-018 | build_deprecation_chains | UTP-018-A | Statement & Branch Coverage | UTS-018-A2 | ⬜ Untested |
| ARCH-014 (SYS-007) | SYS-007 | MOD-018 | build_deprecation_chains | UTP-018-A | Statement & Branch Coverage | UTS-018-A3 | ⬜ Untested |
| ARCH-014 (SYS-007) | SYS-007 | MOD-018 | build_deprecation_chains | UTP-018-A | Statement & Branch Coverage | UTS-018-A4 | ⬜ Untested |
| ARCH-015 (SYS-008) | SYS-008 | MOD-019 | emit_formal_tags | UTP-019-A | Statement & Branch Coverage | UTS-019-A1 | ⬜ Untested |
| ARCH-015 (SYS-008) | SYS-008 | MOD-019 | emit_formal_tags | UTP-019-A | Statement & Branch Coverage | UTS-019-A2 | ⬜ Untested |
| ARCH-015 (SYS-008) | SYS-008 | MOD-019 | emit_formal_tags | UTP-019-B | Equivalence Partitioning | UTS-019-B1 | ⬜ Untested |
| ARCH-015 (SYS-008) | SYS-008 | MOD-019 | emit_formal_tags | UTP-019-B | Equivalence Partitioning | UTS-019-B2 | ⬜ Untested |
| ARCH-015 (SYS-008) | SYS-008 | MOD-019 | emit_formal_tags | UTP-019-B | Equivalence Partitioning | UTS-019-B3 | ⬜ Untested |
| ARCH-015 (SYS-008) | SYS-008 | MOD-019 | emit_formal_tags | UTP-019-B | Equivalence Partitioning | UTS-019-B4 | ⬜ Untested |
| ARCH-016 (SYS-009) | SYS-009 | MOD-020 | detect_lifecycle_transitions | UTP-020-A | Statement & Branch Coverage | UTS-020-A1 | ⬜ Untested |
| ARCH-016 (SYS-009) | SYS-009 | MOD-020 | detect_lifecycle_transitions | UTP-020-A | Statement & Branch Coverage | UTS-020-A2 | ⬜ Untested |
| ARCH-016 (SYS-009) | SYS-009 | MOD-020 | detect_lifecycle_transitions | UTP-020-A | Statement & Branch Coverage | UTS-020-A3 | ⬜ Untested |
| ARCH-016 (SYS-009) | SYS-009 | MOD-020 | detect_lifecycle_transitions | UTP-020-A | Statement & Branch Coverage | UTS-020-A4 | ⬜ Untested |
| ARCH-016 (SYS-009) | SYS-009 | MOD-020 | detect_lifecycle_transitions | UTP-020-A | Statement & Branch Coverage | UTS-020-A5 | ⬜ Untested |
| ARCH-016 (SYS-009) | SYS-009 | MOD-020 | detect_lifecycle_transitions | UTP-020-B | Equivalence Partitioning | UTS-020-B1 | ⬜ Untested |
| ARCH-016 (SYS-009) | SYS-009 | MOD-020 | detect_lifecycle_transitions | UTP-020-B | Equivalence Partitioning | UTS-020-B2 | ⬜ Untested |
| ARCH-017 (SYS-009) | SYS-009 | MOD-021 | format_extended_json | UTP-021-A | Statement & Branch Coverage | UTS-021-A1 | ⬜ Untested |
| ARCH-017 (SYS-009) | SYS-009 | MOD-021 | format_extended_json | UTP-021-A | Statement & Branch Coverage | UTS-021-A2 | ⬜ Untested |
| ARCH-017 (SYS-009) | SYS-009 | MOD-021 | format_extended_json | UTP-021-A | Statement & Branch Coverage | UTS-021-A3 | ⬜ Untested |

### Matrix D Coverage

| Metric | Value |
|--------|-------|
| **Total Module Designs (MOD)** | 21 |
| **External Modules** | 0 |
| **Testable Modules** | 21 |
| **Total Unit Test Cases (UTP)** | 33 |
| **Total Unit Scenarios (UTS)** | 107 |
| **ARCH → MOD Coverage** | 17/17 (100%) |
| **MOD → UTP Coverage** | 21/21 (100%) |

## Audit Notes

- **Matrix generated by**: `build-matrix.sh` (deterministic regex parser)
- **Source documents**: `requirements.md`, `acceptance-plan.md`, `system-design.md`, `system-test.md`, `architecture-design.md`, `integration-test.md`, `module-design.md`, `unit-test.md`
- **Last validated**: 2026-04-18
