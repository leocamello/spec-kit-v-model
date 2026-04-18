# Integration Test Plan: 006b — ID Lifecycle Model


**Feature Branch**: `feature/006b-id-lifecycle`
**Created**: 2026-04-18
**Status**: Draft
**Source**: `specs/006b-id-lifecycle/v-model/architecture-design.md`

## Overview

This document defines the Integration Test Plan for the ID Lifecycle Model feature. Every architecture module in `architecture-design.md` has one or more Test Cases (ITP), and every Test Case has one or more executable Integration Scenarios (ITS) in module-boundary BDD format (Given/When/Then). Integration tests verify **seams and handshakes between modules**, not internal logic or user journeys.

## ID Schema

- **Integration Test Case**: `ITP-{NNN}-{X}` — where NNN matches the parent ARCH, X is a letter suffix (A, B, C...)
- **Integration Test Scenario**: `ITS-{NNN}-{X}{#}` — nested under the parent ITP, with numeric suffix (1, 2, 3...)
- Example: `ITS-001-A1` → Scenario 1 of Test Case A verifying ARCH-001

## ISO 29119-4 Integration Test Techniques

| Technique | Source View | What It Tests |
|-----------|------------|---------------|
| **Interface Contract Testing (ICT)** | Interface View | Module API contracts, data format compliance, error responses |
| **Data Flow Testing (DFT)** | Data Flow View | End-to-end data transformation chain validation |
| **Interface Fault Injection (IFI)** | Interface View + Process View | Malformed payloads, missing data, graceful failure |

Note: Concurrency & Race Condition Testing is not applicable — all 4 interaction paths in the Process View execute sequentially within single command invocations.

## Integration Tests

### Module Verification: ARCH-001 (Annotation Syntax Parser)

**Parent System Components**: SYS-001

#### Test Case: ITP-001-A (Parser Output Contract With Consumers)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify that ARCH-001 produces correctly structured annotation objects consumable by ARCH-002, ARCH-012, ARCH-013, ARCH-014, ARCH-015, and ARCH-016.

* **Integration Scenario: ITS-001-A1**
  * **Given** ARCH-001 receives Markdown text containing IDs with DEPRECATED, SUSPECT, and no-annotation entries
  * **When** ARCH-012 (Coverage Denominator Calculator) consumes the annotations output from ARCH-001
  * **Then** ARCH-012 receives a list where each item has `{id, state}` and successfully excludes DEPRECATED items from its denominator count

#### Test Case: ITP-001-B (Malformed Annotation Propagation)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verify that when ARCH-001 encounters a malformed annotation, the MalformedAnnotation error is propagated to its consumers without crashing the pipeline.

* **Integration Scenario: ITS-001-B1**
  * **Given** ARCH-001 parses Markdown containing `[DEPRECATED — Superseded by]` (missing successor ID)
  * **When** ARCH-008 (Parent Artifact Comparator) consumes ARCH-001's output
  * **Then** ARCH-008 receives the MalformedAnnotation error `{id, raw_text, issue}` and reports the validation issue to the command output without halting the comparison for other IDs

---

### Module Verification: ARCH-002 (State Transition Validator)

**Parent System Components**: SYS-001

#### Test Case: ITP-002-A (Validation Result Contract With Resolution Dispatcher)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify that ARCH-002 provides a boolean valid/invalid result and error details that ARCH-007 (Resolution Dispatcher) correctly consumes.

* **Integration Scenario: ITS-002-A1**
  * **Given** ARCH-007 sends a transition request `{current_state: SUSPECT, target_state: ACTIVE}` to ARCH-002
  * **When** ARCH-002 validates the transition
  * **Then** ARCH-002 returns `{valid: true}` to ARCH-007 and ARCH-007 proceeds with the confirm-valid resolution

* **Integration Scenario: ITS-002-A2**
  * **Given** ARCH-007 sends a transition request `{current_state: DEPRECATED, target_state: ACTIVE}` to ARCH-002
  * **When** ARCH-002 validates the transition
  * **Then** ARCH-002 returns `{valid: false}` with InvalidTransition error `{from: DEPRECATED, to: ACTIVE, reason: "deprecated IDs cannot revert to active"}` and ARCH-007 rejects the resolution

---

### Module Verification: ARCH-003 (Supersession Annotation Handler)

**Parent System Components**: SYS-002

#### Test Case: ITP-003-A (Supersession Write/Parse Roundtrip With ARCH-001)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify that annotations written by ARCH-003 are correctly parsed by ARCH-001 in a roundtrip.

* **Integration Scenario: ITS-003-A1**
  * **Given** ARCH-003 writes the annotation `[DEPRECATED — Superseded by REQ-012]` for REQ-005 into a Markdown artifact
  * **When** ARCH-001 parses the modified artifact
  * **Then** ARCH-001 returns `{id: "REQ-005", state: DEPRECATED, type: "supersession", target: "REQ-012"}` matching the original write parameters

#### Test Case: ITP-003-B (Missing Successor Rejection at Boundary)

**Technique**: Interface Fault Injection
**Target View**: Interface View
**Description**: Verify that when ARCH-007 sends a supersession request with no successor ID, ARCH-003 rejects it with MissingSuccessor and ARCH-007 propagates the error.

* **Integration Scenario: ITS-003-B1**
  * **Given** ARCH-007 (Resolution Dispatcher) routes a re-parent instruction to ARCH-003 with `{id: "REQ-005", successor_id: ""}` (empty)
  * **When** ARCH-003 attempts to write the supersession annotation
  * **Then** ARCH-003 raises MissingSuccessor `{id: "REQ-005", issue: "successor_id is required"}` and ARCH-007 reports the error to the command output without modifying the artifact

---

### Module Verification: ARCH-004 (Withdrawal Annotation Handler)

**Parent System Components**: SYS-002

#### Test Case: ITP-004-A (Withdrawal Write/Parse Roundtrip With ARCH-001)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify that withdrawal annotations written by ARCH-004 are correctly parsed by ARCH-001.

* **Integration Scenario: ITS-004-A1**
  * **Given** ARCH-004 writes the annotation `[DEPRECATED — Withdrawn: regulatory change]` for REQ-007 into a Markdown artifact
  * **When** ARCH-001 parses the modified artifact
  * **Then** ARCH-001 returns `{id: "REQ-007", state: DEPRECATED, type: "withdrawal", reason: "regulatory change"}`

#### Test Case: ITP-004-B (Missing Reason Rejection at Boundary)

**Technique**: Interface Fault Injection
**Target View**: Interface View
**Description**: Verify that when ARCH-007 sends a deprecation request with no reason, ARCH-004 rejects it.

* **Integration Scenario: ITS-004-B1**
  * **Given** ARCH-007 routes a deprecate instruction to ARCH-004 with `{id: "SYS-003", reason: ""}` (empty)
  * **When** ARCH-004 attempts to write the withdrawal annotation
  * **Then** ARCH-004 raises MissingReason `{id: "SYS-003", issue: "reason is required"}` and ARCH-007 reports the error without modifying the artifact

---

### Module Verification: ARCH-005 (Parent-Child Link Resolver)

**Parent System Components**: SYS-003

#### Test Case: ITP-005-A (Link Map Output Consumed By ARCH-008)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify that the link map produced by ARCH-005 is correctly consumed by ARCH-008 (Parent Artifact Comparator) for change detection.

* **Integration Scenario: ITS-005-A1**
  * **Given** ARCH-005 resolves parent links from an acceptance-plan.md containing ATP-003-A linked to REQ-003 and ATP-010-B linked to REQ-010
  * **When** ARCH-008 consumes the link map `{ATP-003-A: ["REQ-003"], ATP-010-B: ["REQ-010"]}`
  * **Then** ARCH-008 uses the map to compare REQ-003 and REQ-010 against their current states in requirements.md

#### Test Case: ITP-005-B (No Links Found Warning)

**Technique**: Interface Fault Injection
**Target View**: Interface View
**Description**: Verify that when ARCH-005 finds no parent links (first-time generation), the NoLinksFound warning is handled gracefully by ARCH-008.

* **Integration Scenario: ITS-005-B1**
  * **Given** ARCH-005 receives an empty downstream artifact (first-time generation, no existing output)
  * **When** ARCH-005 returns NoLinksFound warning `{artifact: "acceptance-plan.md", issue: "no parent links detected"}` to ARCH-008
  * **Then** ARCH-008 treats all parent IDs as "added" and proceeds with standard generation — no SUSPECT annotations are produced

---

### Module Verification: ARCH-006 (Suspect Annotation Writer)

**Parent System Components**: SYS-003

#### Test Case: ITP-006-A (Suspect Items From ARCH-009 Classification)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify that ARCH-006 correctly consumes the classification output from ARCH-009 and writes SUSPECT annotations inline.

* **Integration Scenario: ITS-006-A1**
  * **Given** ARCH-009 emits classifications `[{id: "REQ-003", status: "deprecated"}, {id: "REQ-010", status: "modified"}]` and ARCH-005 resolved links `{ATP-003-A: ["REQ-003"], ATP-010-B: ["REQ-010"]}`
  * **When** ARCH-006 processes the suspect items list `[{downstream_id: "ATP-003-A", parent_id: "REQ-003", reason: "deprecated"}, {downstream_id: "ATP-010-B", parent_id: "REQ-010", reason: "modified"}]`
  * **Then** the updated artifact text contains `[SUSPECT — Parent REQ-003 deprecated]` adjacent to ATP-003-A and `[SUSPECT — Parent REQ-010 modified]` adjacent to ATP-010-B, with all other content preserved

#### Test Case: ITP-006-B (End-to-End Detection and Cascade Chain)

**Technique**: Data Flow Testing
**Target View**: Data Flow View (Flow 1: Lifecycle Detection and Cascade)
**Description**: Verify the complete data flow from ARCH-001 parsing through ARCH-005 resolution, ARCH-008 comparison, ARCH-009 classification, to ARCH-006 suspect writing.

* **Integration Scenario: ITS-006-B1**
  * **Given** a requirements.md where REQ-003 has been marked `[DEPRECATED — Withdrawn: scope reduced]` and an existing acceptance-plan.md where ATP-003-A traces to REQ-003
  * **When** the detection and cascade chain executes: ARCH-001 parses annotations → ARCH-005 resolves links → ARCH-008 compares → ARCH-009 classifies REQ-003 as "deprecated" → ARCH-006 marks downstream
  * **Then** the final output from ARCH-006 contains ATP-003-A with `[SUSPECT — Parent REQ-003 deprecated]` and data format is correct at each stage boundary

---

### Module Verification: ARCH-007 (Resolution Dispatcher)

**Parent System Components**: SYS-004

#### Test Case: ITP-007-A (Routing to ARCH-003 for Re-parent)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify that ARCH-007 correctly routes a re-parent instruction to ARCH-003 (Supersession Handler).

* **Integration Scenario: ITS-007-A1**
  * **Given** ARCH-007 receives resolution `{id: "ATP-003-A", action: "re-parent", successor_id: "REQ-012"}`
  * **When** ARCH-007 routes to ARCH-002 for transition validation (SUSPECT→ACTIVE) then to ARCH-003 for supersession annotation
  * **Then** ARCH-003 writes the updated parent link and ARCH-007 returns the artifact with ATP-003-A's SUSPECT annotation removed and parent changed to REQ-012

#### Test Case: ITP-007-B (Auto-Resolution Blocked)

**Technique**: Interface Fault Injection
**Target View**: Interface View
**Description**: Verify that ARCH-007 blocks automated resolution attempts.

* **Integration Scenario: ITS-007-B1**
  * **Given** a suspect item SYS-003 with `[SUSPECT — Parent REQ-007 deprecated]` and no explicit human resolution instruction has been provided
  * **When** ARCH-007 receives an automated resolution attempt (no human instruction flag)
  * **Then** ARCH-007 raises AutoResolutionBlocked `{id: "SYS-003", issue: "automated resolution not permitted — human instruction required"}` and the artifact remains unchanged

#### Test Case: ITP-007-C (Resolution Chain End-to-End)

**Technique**: Data Flow Testing
**Target View**: Data Flow View (Flow 2: Suspect Resolution)
**Description**: Verify the complete resolution chain from ARCH-007 dispatch through ARCH-002 validation to ARCH-004 withdrawal annotation.

* **Integration Scenario: ITS-007-C1**
  * **Given** ARCH-007 receives `{id: "SYS-003", action: "deprecate", reason: "parent capability withdrawn"}`
  * **When** the resolution chain executes: ARCH-007 dispatches → ARCH-002 validates SUSPECT→DEPRECATED → ARCH-004 writes withdrawal annotation
  * **Then** the artifact contains SYS-003 with `[DEPRECATED — Withdrawn: parent capability withdrawn]` and the SUSPECT annotation is removed, with data format correct at each handoff

---

### Module Verification: ARCH-008 (Parent Artifact Comparator)

**Parent System Components**: SYS-005

#### Test Case: ITP-008-A (Comparison Output to ARCH-009)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify that ARCH-008 produces comparison data in the format ARCH-009 expects.

* **Integration Scenario: ITS-008-A1**
  * **Given** ARCH-008 reads a parent artifact with 5 REQs and receives a link map from ARCH-005 with 4 traced links (REQ-001 through REQ-004)
  * **When** ARCH-008 completes the 4-step comparison and passes results to ARCH-009
  * **Then** ARCH-009 receives parent_ids with content hashes and traced_parent_links in the expected format, enabling classification of each ID

#### Test Case: ITP-008-B (Parent Artifact Not Found)

**Technique**: Interface Fault Injection
**Target View**: Interface View
**Description**: Verify that when the parent artifact file is missing, ARCH-008 raises ParentNotFound and the command invocation reports a clear error.

* **Integration Scenario: ITS-008-B1**
  * **Given** the parent artifact path points to a non-existent file (e.g., requirements.md deleted)
  * **When** ARCH-008 attempts to read the parent artifact
  * **Then** ARCH-008 raises ParentNotFound `{path: "specs/006b/v-model/requirements.md", issue: "parent artifact does not exist"}` and the command reports the error without writing any SUSPECT annotations

---

### Module Verification: ARCH-009 (ID Classification Emitter)

**Parent System Components**: SYS-005

#### Test Case: ITP-009-A (Classification List Consumed by ARCH-006)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify that ARCH-009's classification output is correctly consumed by ARCH-006 (Suspect Annotation Writer).

* **Integration Scenario: ITS-009-A1**
  * **Given** ARCH-009 produces `[{id: "REQ-002", status: "modified"}, {id: "REQ-005", status: "added"}]`
  * **When** ARCH-006 consumes the classification list to determine suspect targets
  * **Then** ARCH-006 processes only the "modified" entry (REQ-002) for suspect marking and treats the "added" entry (REQ-005) as new content for generation — the interface contract `{id: String, status: Enum}` is satisfied

---

### Module Verification: ARCH-010 (Section Template Generator)

**Parent System Components**: SYS-006

#### Test Case: ITP-010-A (Template Output Consumed by ARCH-011)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify that ARCH-010 produces section text that ARCH-011 (Command File Inserter) can correctly insert.

* **Integration Scenario: ITS-010-A1**
  * **Given** ARCH-010 receives id_prefix "REQ" and generates the Lifecycle Rules section text with 5 subsections
  * **When** ARCH-011 receives the section_text output from ARCH-010
  * **Then** ARCH-011 successfully identifies the section as valid Markdown content with non-empty text and proceeds with insertion

---

### Module Verification: ARCH-011 (Command File Inserter)

**Parent System Components**: SYS-006

#### Test Case: ITP-011-A (Section Insertion Into Command File)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify that ARCH-011 correctly inserts the section text from ARCH-010 at the expected position in a command file.

* **Integration Scenario: ITS-011-A1**
  * **Given** ARCH-011 receives a command file path (acceptance.md) and section text from ARCH-010 with prefix "ATP"
  * **When** ARCH-011 locates the insertion point between "Load existing acceptance plan" and "Generate Test Cases"
  * **Then** the modified command file contains the Lifecycle Rules section at the correct position and all original content before and after the insertion point is preserved

#### Test Case: ITP-011-B (Insertion Point Not Found)

**Technique**: Interface Fault Injection
**Target View**: Interface View
**Description**: Verify that ARCH-011 raises InsertionPointNotFound when the command file lacks the expected step structure.

* **Integration Scenario: ITS-011-B1**
  * **Given** ARCH-011 receives a command file that does not contain a "Load existing artifact" step (e.g., a malformed or legacy command file)
  * **When** ARCH-011 attempts to locate the insertion point
  * **Then** ARCH-011 raises InsertionPointNotFound `{file: "commands/legacy.md", issue: "cannot locate 'Load existing artifact' step"}` and the original file is not modified

---

### Module Verification: ARCH-012 (Coverage Denominator Calculator)

**Parent System Components**: SYS-007

#### Test Case: ITP-012-A (Active Count From ARCH-001 Annotations)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify that ARCH-012 correctly consumes ARCH-001's annotation output to compute active-item counts.

* **Integration Scenario: ITS-012-A1**
  * **Given** ARCH-001 parses a requirements.md with 10 IDs: 8 ACTIVE, 1 DEPRECATED, 1 SUSPECT
  * **When** ARCH-012 consumes the annotations list from ARCH-001
  * **Then** ARCH-012 returns `{active_count: 9, deprecated_count: 1}` — SUSPECT items are included in the denominator (they are still active, just flagged for review), DEPRECATED are excluded

---

### Module Verification: ARCH-013 (Suspect Summary Generator)

**Parent System Components**: SYS-007

#### Test Case: ITP-013-A (Suspect Summary From ARCH-001 Annotations)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify that ARCH-013 correctly filters SUSPECT annotations from ARCH-001's output and generates the summary section.

* **Integration Scenario: ITS-013-A1**
  * **Given** ARCH-001 returns annotations from all artifacts including 2 SUSPECT items: `{id: "ATP-003-A", state: SUSPECT, reason: "Parent REQ-003 deprecated"}` and `{id: "SYS-002", state: SUSPECT, reason: "Parent REQ-010 modified"}`
  * **When** ARCH-013 generates the suspect summary section
  * **Then** the output is a Markdown section listing both items with their IDs, artifact locations, and parent change reasons

---

### Module Verification: ARCH-014 (Deprecated Chain Reporter)

**Parent System Components**: SYS-007

#### Test Case: ITP-014-A (Deprecated Chains From ARCH-001 and ARCH-003)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify that ARCH-014 correctly combines DEPRECATED annotations from ARCH-001 with supersession lineage from ARCH-003 to build chain reports.

* **Integration Scenario: ITS-014-A1**
  * **Given** ARCH-001 returns `{id: "REQ-005", state: DEPRECATED, type: "supersession", target: "REQ-012"}` and ARCH-003 confirms the supersession link
  * **When** ARCH-014 builds the deprecated chain report
  * **Then** the output shows the chain `REQ-005 → REQ-012 (supersession)` in a separate "Deprecated Chains" section

#### Test Case: ITP-014-B (Broken Chain Warning)

**Technique**: Interface Fault Injection
**Target View**: Interface View
**Description**: Verify that when a supersession target ID does not exist in the artifact, ARCH-014 emits a BrokenChain warning.

* **Integration Scenario: ITS-014-B1**
  * **Given** ARCH-001 returns `{id: "REQ-005", state: DEPRECATED, type: "supersession", target: "REQ-099"}` but REQ-099 does not exist in any artifact
  * **When** ARCH-014 attempts to build the chain
  * **Then** ARCH-014 emits BrokenChain warning `{id: "REQ-005", successor: "REQ-099", issue: "successor not found in artifact"}` and includes the chain entry with a warning flag in the output

#### Test Case: ITP-014-C (Trace Report Assembly Chain)

**Technique**: Data Flow Testing
**Target View**: Data Flow View (Flow 3: Trace Report Assembly)
**Description**: Verify the complete trace report data flow from ARCH-001 parsing through ARCH-012 denominator calculation, ARCH-013 suspect summary, and ARCH-014 deprecated chains.

* **Integration Scenario: ITS-014-C1**
  * **Given** artifacts containing 10 REQs (1 DEPRECATED, 1 SUSPECT, 8 ACTIVE) and their downstream artifacts
  * **When** the trace report chain executes: ARCH-001 parses all artifacts → ARCH-012 computes active count (9) → ARCH-013 generates suspect summary (1 item) → ARCH-014 generates deprecated chains (1 chain)
  * **Then** the assembled traceability matrix shows coverage denominator of 9, a Suspect Items section with 1 entry, and a Deprecated Chains section with 1 entry — data format is correct at each module boundary

---

### Module Verification: ARCH-015 (Formal Tag Emitter)

**Parent System Components**: SYS-008

#### Test Case: ITP-015-A (Tag Emission From ARCH-001 State Data)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify that ARCH-015 correctly transforms lifecycle states from ARCH-001 into formal tags in impact-analysis output.

* **Integration Scenario: ITS-015-A1**
  * **Given** ARCH-001 returns annotations for 3 items: `{id: "REQ-003", state: DEPRECATED}`, `{id: "REQ-010", state: SUSPECT}`, `{id: "REQ-001", state: ACTIVE}`
  * **When** ARCH-015 processes the items for impact-analysis output
  * **Then** ARCH-015 emits REQ-003 with `[DEPRECATED]`, REQ-010 with `[SUSPECT]`, and REQ-001 with no tag — matching the formal tag contract

---

### Module Verification: ARCH-016 (Lifecycle Transition Detector)

**Parent System Components**: SYS-009

#### Test Case: ITP-016-A (Transition Detection Between ARCH-001 Outputs)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify that ARCH-016 correctly compares current vs. baseline annotation sets from ARCH-001 to detect lifecycle transitions.

* **Integration Scenario: ITS-016-A1**
  * **Given** ARCH-001 returns current annotations: `[{id: "REQ-005", state: DEPRECATED}, {id: "REQ-010", state: ACTIVE}]` and baseline annotations: `[{id: "REQ-005", state: ACTIVE}, {id: "REQ-010", state: SUSPECT}]`
  * **When** ARCH-016 compares the two sets
  * **Then** ARCH-016 returns `{deprecated: ["REQ-005"], new_suspects: [], resolved_suspects: ["REQ-010"]}`

#### Test Case: ITP-016-B (Baseline Parse Error)

**Technique**: Interface Fault Injection
**Target View**: Interface View
**Description**: Verify that when the baseline from acceptance-plan.md cannot be parsed, ARCH-016 raises BaselineParseError.

* **Integration Scenario: ITS-016-B1**
  * **Given** the acceptance-plan.md file exists but contains no parseable baseline snapshot (e.g., corrupted or empty)
  * **When** ARCH-016 attempts to extract baseline annotations via ARCH-001
  * **Then** ARCH-016 raises BaselineParseError `{issue: "cannot extract baseline from acceptance-plan.md"}` and the diff script exits with a clear error message

---

### Module Verification: ARCH-017 (Extended JSON Formatter)

**Parent System Components**: SYS-009

#### Test Case: ITP-017-A (JSON Output Contract With Shell Consumer)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify that ARCH-017 produces valid JSON with all 6 arrays consumed by the acceptance command.

* **Integration Scenario: ITS-017-A1**
  * **Given** ARCH-017 receives content_changes `{added: ["REQ-015"], modified: ["REQ-002"], removed: []}` and lifecycle_transitions `{deprecated: ["REQ-005"], new_suspects: [], resolved_suspects: ["REQ-010"]}` from ARCH-016
  * **When** ARCH-017 formats the combined output
  * **Then** the JSON string `{"added":["REQ-015"],"modified":["REQ-002"],"removed":[],"deprecated":["REQ-005"],"new_suspects":[],"resolved_suspects":["REQ-010"]}` is valid JSON and contains all 6 arrays

#### Test Case: ITP-017-B (Extended Diff Execution Chain)

**Technique**: Data Flow Testing
**Target View**: Data Flow View (Flow 4: Extended Diff Execution)
**Description**: Verify the complete diff data flow from ARCH-001 parsing through ARCH-016 transition detection to ARCH-017 JSON formatting.

* **Integration Scenario: ITS-017-B1**
  * **Given** a requirements.md with REQ-005 newly deprecated and REQ-010 previously SUSPECT now resolved, compared to the baseline in acceptance-plan.md
  * **When** the diff chain executes: ARCH-001 parses current annotations → ARCH-001 parses baseline annotations → ARCH-016 detects transitions → ARCH-017 formats JSON
  * **Then** the final JSON output contains `deprecated: ["REQ-005"]` and `resolved_suspects: ["REQ-010"]` with correct data format at each module handoff

---

## Test Harness & Mocking Strategy

| Test Case | Module Under Test | Dependency | Mock/Stub Strategy | Rationale |
|-----------|-------------------|------------|-------------------|-----------|
| ITP-001-A | ARCH-001 | Markdown artifact files | File stub — provide controlled Markdown text with known annotations | Isolate parser from filesystem; ensure deterministic input |
| ITP-001-B | ARCH-001 → ARCH-008 | Artifact files | File stub with malformed annotations | Test error propagation across module boundary |
| ITP-005-B | ARCH-005 → ARCH-008 | Downstream artifact | Empty file stub | Simulate first-time generation scenario |
| ITP-006-B | ARCH-001 through ARCH-006 | All artifacts | File stubs with known content | End-to-end data flow validation requires controlled data at each stage |
| ITP-007-B | ARCH-007 | Human instruction | No mock — absence of human instruction is the test condition | Verify the safety constraint directly |
| ITP-008-B | ARCH-008 | Parent artifact file | Non-existent file path | Simulate deleted or missing artifact |
| ITP-011-A | ARCH-011 | Command files | Writable file copies | Avoid modifying actual command files during test; use temporary copies |
| ITP-014-C | ARCH-001 through ARCH-014 | All artifacts | File stubs with mixed lifecycle states | End-to-end trace chain requires artifacts at known states |
| ITP-016-B | ARCH-016 | acceptance-plan.md | Corrupted file stub | Simulate unparseable baseline |

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Architecture Modules (ARCH) | 17 (17 active, 0 deprecated) |
| Total Test Cases (ITP) | 30 (30 active, 0 deprecated, 0 suspect) |
| Total Scenarios (ITS) | 31 |
| Modules with ≥1 ITP | 17 / 17 (100%) (active items only) |
| Test Cases with ≥1 ITS | 30 / 30 (100%) |
| **Overall Coverage (ARCH→ITP)** | **100%** (active items only) |

### Technique Distribution

| Technique | Test Cases | Percentage |
|-----------|-----------|------------|
| Interface Contract Testing (ICT) | 17 | 57% |
| Interface Fault Injection (IFI) | 9 | 30% |
| Data Flow Testing (DFT) | 4 | 13% |
| Concurrency & Race Condition Testing (CRT) | 0 | 0% (not applicable — sequential execution) |

## Uncovered Modules

None — full coverage achieved.

**Generated**: 2026-04-18
**Language Compliance**: Zero user-journey phrases and zero internal-logic phrases — all module-boundary oriented.
