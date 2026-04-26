# Integration Test Plan: Bridge Commands

**Feature Branch**: `feature/007-bridge-commands`
**Created**: 2026-04-26
**Status**: Draft
**Source**: `specs/007-bridge-commands/v-model/architecture-design.md`

## Overview

This document defines the Integration Test Plan for the bridge-commands
feature. Every architecture module in `architecture-design.md` (21 ARCHs:
18 business + 3 cross-cutting) has at least one Test Case (ITP), and every
Test Case has at least one executable Integration Scenario (ITS) in
module-boundary BDD format.

Integration tests verify **the seams and handshakes between modules** —
the inter-module contracts in the Interface View, the transformation chains
in the Data Flow View, and the fault-propagation paths in the Process View.
They do not verify internal module logic (that is the unit-test layer) and
they do not verify user journeys (that is the acceptance-test layer).

The runtime model (single-threaded sequential per command invocation)
constrains the concurrency surface: the only races worth testing are
**filesystem-level** (atomic-write semantics in ARCH-021), **subprocess
output ordering** (ARCH-020), and **inter-process** races between two
concurrent command invocations against the same feature directory
(ARCH-004 boundary).

No domain overlay is loaded for this feature (`v-model-config.yml` absent
at the repository root); only base ISO/IEC/IEEE 29119-4:2021 techniques
are applied. No SIL/HIL compatibility table or resource-contention table
is required.

## ID Schema

- **Integration Test Case**: `ITP-{NNN}-{X}` where `NNN` matches the parent
  ARCH and `X` is a letter suffix:
  - **A** = Interface Contract Testing (one per ARCH — happy-path contract)
  - **B** = Interface Fault Injection (modules with declared exception contracts)
  - **C** = Data Flow Testing (chain-head modules)
  - **D** = Concurrency & Race Condition Testing (modules with race surfaces)
- **Integration Test Scenario**: `ITS-{NNN}-{X}{#}` — nested under the
  parent ITP, with numeric suffix.
- Example: `ITS-005-A1` → Scenario 1 of Test Case A verifying ARCH-005.
- IDs are permanent — never renumbered or reassigned.

## ISO 29119-4 Integration Test Techniques

| Technique | Source View | What It Tests |
|-----------|------------|---------------|
| **Interface Contract Testing** | Interface View | Per-ARCH input/output/exception contract compliance |
| **Data Flow Testing** | Data Flow View | End-to-end transformation correctness across module boundaries |
| **Interface Fault Injection** | Interface View + Process View | Malformed payloads, missing fields, declared exception propagation, fail-closed paths |
| **Concurrency & Race Condition Testing** | Process View | Filesystem-level atomicity, subprocess stream ordering, inter-process invocation races |

## Integration Tests

### Module Verification: ARCH-001 (Plan Synthesis Orchestrator)

**Parent System Components**: SYS-001

#### Test Case: ITP-001-A (Plan synthesis happy-path contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-001, when invoked with a feature
directory containing only `requirements.md`, drives the documented
sequence of calls (ARCH-019 → ARCH-008 → ARCH-013 → ARCH-002 → ARCH-016)
with the contract-defined inputs and outputs at each seam.

* **Integration Scenario: ITS-001-A1**
  * **Given** ARCH-019 (V-Model Artifact Reader) has returned an `ArtifactSet` with `requirements` populated and all other fields null
  * **When** ARCH-001 invokes ARCH-008 with `(canonical_plan, metadata)`
  * **Then** ARCH-008 receives a `canonical_doc` that already validates against the spec-kit-core `plan-template.md` schema (precondition required by ARCH-008's contract)
* **Integration Scenario: ITS-001-A2**
  * **Given** ARCH-008 has returned an `enriched_plan` document
  * **When** ARCH-001 hands the document to ARCH-013 for `validate_plan_schema`
  * **Then** ARCH-013 returns `{valid: true, errors: []}` and the run proceeds to ARCH-002 with no contract violation reported
* **Integration Scenario: ITS-001-A3**
  * **Given** ARCH-002 has emitted the canonical artifact set
  * **When** ARCH-001 invokes ARCH-016 with the assembled `run_result`
  * **Then** ARCH-016 emits a stdout summary containing the inputs-read list (`requirements.md`), the outputs-produced list (`plan.md` plus subset due to optional inputs absent), and zero fatal errors

#### Test Case: ITP-001-B (Plan synthesis exception propagation)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that exceptions raised at the ARCH-008 and
ARCH-013 boundaries propagate to ARCH-001's exit code per its contract,
and that ARCH-016 still emits a summary on the failure path.

* **Integration Scenario: ITS-001-B1**
  * **Given** ARCH-008 raises `EnrichmentError` when called by ARCH-001
  * **When** ARCH-001 catches the exception
  * **Then** ARCH-001 exits with code 1, ARCH-002 is never invoked, and ARCH-016 emits a summary with the `EnrichmentError` text in the `fatal_errors[]` field
* **Integration Scenario: ITS-001-B2**
  * **Given** ARCH-013 returns `{valid: false, errors: [{section, line, message}]}` to ARCH-001
  * **When** ARCH-001 inspects the validation result
  * **Then** ARCH-001 propagates `SchemaValidationError` (text + section), exits with code 1, and ARCH-002 is never invoked

---

### Module Verification: ARCH-002 (Canonical Artifact Emitter)

**Parent System Components**: SYS-001

#### Test Case: ITP-002-A (Selective emission per nullable field)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies ARCH-002's contract that absent fields in
`canonical_outputs` result in no file being emitted (handshake with
ARCH-001 about graceful degradation when optional inputs are missing).

* **Integration Scenario: ITS-002-A1**
  * **Given** ARCH-001 sends `canonical_outputs = {plan, contracts: [], quickstart: null, research: null, data_model: null}` to ARCH-002
  * **When** ARCH-002 dispatches to ARCH-021 (Filesystem Writer)
  * **Then** the `written paths` return list contains exactly one entry (`plan.md`) and no other artifact path is touched
* **Integration Scenario: ITS-002-A2**
  * **Given** ARCH-001 sends a fully populated `canonical_outputs` struct
  * **When** ARCH-002 dispatches to ARCH-021 once per non-null field
  * **Then** the returned `written paths` list contains 5 entries (`plan.md`, `data-model.md`, `contracts/<n>`, `quickstart.md`, `research.md`)

#### Test Case: ITP-002-B (Filesystem write failure propagation)

**Technique**: Interface Fault Injection
**Target View**: Interface View
**Description**: Verifies ARCH-002 propagates `IOError` from ARCH-021 to
its caller (ARCH-001) per the declared exception contract.

* **Integration Scenario: ITS-002-B1**
  * **Given** ARCH-021 raises `IOError` mid-emission (e.g., on the second of three files)
  * **When** ARCH-002 catches the exception
  * **Then** ARCH-002 propagates `IOError` to ARCH-001 unmodified, and the partial write left by ARCH-021's tmp-file (rename-not-yet-performed) does NOT appear in the returned `written paths` list

---

### Module Verification: ARCH-003 (Tasks Synthesis Orchestrator)

**Parent System Components**: SYS-002

#### Test Case: ITP-003-A (Tasks synthesis happy-path contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the documented call sequence (ARCH-019 →
ARCH-014 → ARCH-012 → ARCH-008 → ARCH-013 → ARCH-021) with the
contract-defined inputs at each seam.

* **Integration Scenario: ITS-003-A1**
  * **Given** ARCH-019 has returned an `ArtifactSet` containing `requirements`, `module_design`, and `hazard_analysis`
  * **When** ARCH-003 invokes ARCH-014 with the upstream `plan.md`
  * **Then** ARCH-003 receives an `EnrichmentReport` and uses its `enriched` flag to decide between V-Model-direct and Hybrid trace population (no further branch is taken outside this report)
* **Integration Scenario: ITS-003-A2**
  * **Given** ARCH-013 returns `{valid: true}` for the assembled `tasks.md`
  * **When** ARCH-003 dispatches to ARCH-021 for atomic write
  * **Then** ARCH-021 receives the enriched canonical Markdown unchanged from ARCH-008's output (byte-for-byte)

#### Test Case: ITP-003-B (Hazard enrichment failure propagation)

**Technique**: Interface Fault Injection
**Target View**: Interface View
**Description**: Verifies ARCH-003 propagates `HazardEnrichmentError`
from ARCH-012 only when `hazard-analysis.md` is present (the early-return
identity-transform path must NOT raise).

* **Integration Scenario: ITS-003-B1**
  * **Given** ARCH-019 returns an `ArtifactSet` with `hazard_analysis: null`
  * **When** ARCH-003 invokes ARCH-012 with the empty hazard analysis
  * **Then** ARCH-012 returns the input `tasks` list unchanged, NO exception is raised, and the run proceeds to ARCH-008
* **Integration Scenario: ITS-003-B2**
  * **Given** ARCH-019 returns an `ArtifactSet` with a malformed `hazard_analysis`
  * **When** ARCH-003 invokes ARCH-012
  * **Then** ARCH-012 raises `MalformedHazardAnalysis`, ARCH-003 propagates it as `HazardEnrichmentError`, exits with code 1, and ARCH-013 is never invoked

#### Test Case: ITP-003-C (Requirements → tasks.md data flow)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies the Data Flow View's `Requirements → tasks.md`
chain (Stage 1 ARCH-019 → Stage 7 ARCH-021) with the format invariant at
each stage.

* **Integration Scenario: ITS-003-C1**
  * **Given** a `requirements.md` is injected at Stage 1 of the chain
  * **When** the data flows through ARCH-019, ARCH-014, ARCH-003, ARCH-012, ARCH-008, ARCH-013, and finally ARCH-021
  * **Then** the format at each transition matches the Data Flow View row (`ArtifactSet` after Stage 1, `EnrichmentReport` after Stage 2, `list[Task]` after Stage 3, `list[Task]` enriched after Stage 4, canonical Markdown + HTML comments after Stage 5, `ValidationResult` after Stage 6, `tasks.md` on disk after Stage 7)
* **Integration Scenario: ITS-003-C2**
  * **Given** a malformed Markdown table is injected into `requirements.md` at Stage 1
  * **When** ARCH-019 attempts to parse it
  * **Then** ARCH-019 raises `MalformedArtifact` and the chain terminates at Stage 1; no downstream stage receives any data

---

### Module Verification: ARCH-004 (Implementation Orchestrator)

**Parent System Components**: SYS-003

#### Test Case: ITP-004-A (Implementation pipeline happy-path contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View + Process View
**Description**: Verifies the strict ordering invariant of the
implementation pipeline (gate before generation, generation before
verification, verification before commit).

* **Integration Scenario: ITS-004-A1**
  * **Given** ARCH-007 returns `GateResult{passed: true, matrices: {A:100, B:100, C:100, D:100, H:100}}`
  * **When** ARCH-004 proceeds with the pipeline
  * **Then** ARCH-005 is invoked exactly once, ARCH-006 is invoked exactly once, ARCH-009 is invoked exactly once on the union of generated files, and ARCH-018 is invoked exactly once after ARCH-009 returns `{valid: true}`
* **Integration Scenario: ITS-004-A2**
  * **Given** all downstream modules return their happy-path contracts
  * **When** ARCH-004 completes
  * **Then** the exit code is 0 and the side-effect set is exactly: source files written through ARCH-021 + a single annotated commit in Git history

#### Test Case: ITP-004-B (Fail-closed transitions on safety-net failure)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies all three fail-closed transitions
(`GateFailure`, `HallucinationDetected`, `RegionConflict`) terminate the
pipeline before the next downstream call, with no partial commit.

* **Integration Scenario: ITS-004-B1**
  * **Given** ARCH-007 returns `GateResult{passed: false}` to ARCH-004
  * **When** ARCH-004 inspects the result
  * **Then** ARCH-005 is NEVER invoked, exit code is 1, and ARCH-018 is never invoked (no commit produced)
* **Integration Scenario: ITS-004-B2**
  * **Given** ARCH-009 returns `VerifyResult{valid: false, hallucinations: [(file, line, id)]}` to ARCH-004
  * **When** ARCH-004 inspects the result
  * **Then** ARCH-018 is NEVER invoked, exit code is 1, and the source files written by ARCH-005/ARCH-006 remain on disk (verification is pre-commit, not pre-write — atomicity is filesystem-level via ARCH-021, not pipeline-level)
* **Integration Scenario: ITS-004-B3**
  * **Given** ARCH-005 raises `RegionConflict` (propagated from ARCH-010)
  * **When** ARCH-004 catches the exception
  * **Then** ARCH-006 is NEVER invoked, ARCH-009 is NEVER invoked, exit code is 1, and no file is written through ARCH-021 (RegionConflict aborts before any file is written, per ARCH-005's contract)

#### Test Case: ITP-004-D (Two concurrent invocations on same feature dir)

**Technique**: Concurrency & Race Condition Testing
**Target View**: Process View
**Description**: Verifies inter-process race resolution when two
`/speckit.v-model.implement` invocations run against the same feature
directory. The single synchronization primitive (filesystem-level atomic
write via ARCH-021) MUST resolve the race deterministically.

* **Integration Scenario: ITS-004-D1**
  * **Given** two ARCH-004 invocations (process P1, process P2) start within milliseconds of each other against the same `feature_dir`
  * **When** both processes reach the ARCH-021 atomic-write step for the same target source file
  * **Then** both writes complete (one rename strictly precedes the other), the final file content equals exactly one of the two written contents (no byte-level interleaving), and both processes exit with code 0 (no in-process locking is attempted — race resolution is rename-atomicity-only)
* **Integration Scenario: ITS-004-D2**
  * **Given** P1 has commit-annotated and P2 is mid-pipeline
  * **When** P2's ARCH-018 invokes `git commit` while a P1 commit is already in progress
  * **Then** Git's own index lock serializes the commits (Git layer enforces ordering, not ARCH-004) and both commits appear in history with their respective ID suffixes from ARCH-018

---

### Module Verification: ARCH-005 (Code Generator)

**Parent System Components**: SYS-003

#### Test Case: ITP-005-A (Code emission with traceability comment contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies every file in the returned `file_set` contains
at least one `// Implements <ID>` comment in the language-appropriate
syntax, as required by ARCH-005's output contract.

* **Integration Scenario: ITS-005-A1**
  * **Given** a `generation_plan` with three modules targeting paths `*.py`, `*.ts`, and `*.sh`
  * **When** ARCH-005 returns its `file_set` to ARCH-004
  * **Then** the `.py` file contains `# Implements <ID>`, the `.ts` file contains `// Implements <ID>`, and the `.sh` file contains `# Implements <ID>` — language-appropriate per the contract
* **Integration Scenario: ITS-005-A2**
  * **Given** the `generation_plan` declares a target source file with NO existing user content
  * **When** ARCH-005 invokes ARCH-010 (Source Region Splicer) with `target_path` pointing to a non-existent file
  * **Then** ARCH-010 returns the generated content as the `final_content` (creating the file from a single managed region) and ARCH-005 includes the resulting `(path, final_content)` tuple in its returned `file_set`

#### Test Case: ITP-005-B (Region conflict abort before any write)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies the documented contract that a `RegionConflict`
from ARCH-010 aborts ARCH-005 before any file is written through ARCH-021.

* **Integration Scenario: ITS-005-B1**
  * **Given** the second of three target files has overlapping V-Model-managed-region markers
  * **When** ARCH-010 raises `RegionConflict` for that file
  * **Then** ARCH-005 propagates the exception, ARCH-021 is NEVER invoked for ANY of the three files (including the first one that would have spliced cleanly), and the `file_set` is never returned to ARCH-004

#### Test Case: ITP-005-C (Module-design → source code data flow)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies the Data Flow View's `module-design.md MOD
entries → source code files` chain (Stage 1 ARCH-019 → Stage 8 ARCH-018).

* **Integration Scenario: ITS-005-C1**
  * **Given** a `module-design.md` with three MOD entries each declaring a Target Source File
  * **When** the data flows through ARCH-019, ARCH-007, ARCH-011, ARCH-005, ARCH-010, ARCH-009, ARCH-021, and ARCH-018
  * **Then** the format at each transition matches the Data Flow View row (`list[ModuleSpec]` after Stage 1, `GateResult` after Stage 2 with `passed: true`, augmented `list[ModuleSpec]` after Stage 3 — identical to input when `domain_config: null`, `list[(path, content)]` after Stage 4, `list[(path, final_content)]` after Stage 5, `VerifyResult` after Stage 6 with `valid: true`, three files on disk after Stage 7, one annotated commit in Git history after Stage 8)
* **Integration Scenario: ITS-005-C2**
  * **Given** ARCH-007 returns `GateResult{passed: false}` at Stage 2
  * **When** the chain attempts to continue
  * **Then** Stages 3–8 NEVER execute (gate is fail-closed) and the `module-design.md` MOD entries are never converted to source code

---

### Module Verification: ARCH-006 (Test Generator)

**Parent System Components**: SYS-003

#### Test Case: ITP-006-A (Four-level test emission contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the returned `test_set` covers all four V-Model
levels (unit / integration / system / acceptance) per the contract, with
each test file traceable to its source plan artifact.

* **Integration Scenario: ITS-006-A1**
  * **Given** ARCH-019 has loaded an `ArtifactSet` containing all four test plans (unit, integration, system, acceptance)
  * **When** ARCH-006 returns its `test_set` to ARCH-004
  * **Then** the `test_set` contains at least one entry per level, and each entry's `path` lies inside the project's existing test directory for that level
* **Integration Scenario: ITS-006-A2**
  * **Given** the `ArtifactSet` is missing `unit-test.md` (graceful-degradation case)
  * **When** ARCH-006 generates tests
  * **Then** the `test_set` contains entries for the three present levels (integration, system, acceptance) and the unit level is silently skipped (degradation reported by ARCH-016 in the run summary, not by ARCH-006 itself)

---

### Module Verification: ARCH-007 (Pre-Implementation Gate Coordinator)

**Parent System Components**: SYS-004

#### Test Case: ITP-007-A (Aggregate gate result contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the documented contract that
`passed == true` ⟺ every per-matrix `pct == 100`.

* **Integration Scenario: ITS-007-A1**
  * **Given** ARCH-020 returns exit code 0 + JSON `{coverage_pct: 100}` for each of `build-matrix.sh`, `validate-requirements-coverage.sh`, `validate-acceptance-coverage.sh`, `validate-system-coverage.sh`, `validate-architecture-coverage.sh`, `validate-integration-coverage.sh`, `validate-module-coverage.sh`, `validate-unit-coverage.sh`
  * **When** ARCH-007 aggregates the results
  * **Then** `GateResult.passed == true`, every matrix in `GateResult.matrices` shows `pct: 100`, and `gap_report` is empty
* **Integration Scenario: ITS-007-A2**
  * **Given** ARCH-020 returns JSON `{coverage_pct: 95, gaps: ["REQ-007"]}` for `validate-requirements-coverage.sh`
  * **When** ARCH-007 aggregates
  * **Then** `GateResult.passed == false`, `GateResult.matrices.A.pct == 95`, and `gap_report` contains the gap text

#### Test Case: ITP-007-B (Subprocess failure → fail-closed)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies the fail-closed semantics that a
`SubprocessFailure` from ARCH-020 is converted to `{passed: false}`
(NOT propagated as an exception to ARCH-004).

* **Integration Scenario: ITS-007-B1**
  * **Given** ARCH-020 raises `SubprocessFailure` (e.g., script not found)
  * **When** ARCH-007 catches the exception
  * **Then** ARCH-007 returns `GateResult{passed: false}` with the failure text in `gap_report` and does NOT raise — fail-closed semantics defer the abort decision to ARCH-004

---

### Module Verification: ARCH-008 (Additive Enrichment Encoder)

**Parent System Components**: SYS-005

#### Test Case: ITP-008-A (Round-trip schema preservation contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the contract invariant that a document
validating against the spec-kit-core schema before enrichment also
validates after enrichment (HTML comments + optional sections must be
schema-transparent).

* **Integration Scenario: ITS-008-A1**
  * **Given** a `canonical_doc` that ARCH-013 reports `{valid: true}` for
  * **When** ARCH-008 returns the `enriched_doc` to ARCH-001
  * **Then** ARCH-001's subsequent call to ARCH-013 with the enriched document also returns `{valid: true}` — proving the round-trip property holds at the integration boundary
* **Integration Scenario: ITS-008-A2**
  * **Given** an empty `metadata` struct (`{trace_chains: [], optional_sections: {}}`)
  * **When** ARCH-008 returns the `enriched_doc`
  * **Then** the `enriched_doc` is byte-equal to the input `canonical_doc` (identity transform) — enrichment is strictly additive and never mandatory

#### Test Case: ITP-008-B (Non-conformant input rejection)

**Technique**: Interface Fault Injection
**Target View**: Interface View
**Description**: Verifies ARCH-008 raises `EnrichmentError` rather than
silently propagating a non-conformant input downstream.

* **Integration Scenario: ITS-008-B1**
  * **Given** a `canonical_doc` that ARCH-013 reports `{valid: false}` for
  * **When** ARCH-008 is invoked with the same document
  * **Then** ARCH-008 raises `EnrichmentError` (per its declared contract precondition) and returns no document — preventing schema-invalid enriched output from ever reaching ARCH-013 or ARCH-021

---

### Module Verification: ARCH-009 (Hallucination Guard)

**Parent System Components**: SYS-006

#### Test Case: ITP-009-A (ID-set verification contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the contract `valid ⟺ len(hallucinations) == 0`
across all language-appropriate comment syntaxes.

* **Integration Scenario: ITS-009-A1**
  * **Given** a `generated_files` set containing `# Implements REQ-001`, `// Implements REQ-002`, and `<!-- Implements REQ-003 -->` and a `vmodel_id_set` containing `{REQ-001, REQ-002, REQ-003, REQ-004}`
  * **When** ARCH-009 is invoked by ARCH-004
  * **Then** ARCH-009 returns `VerifyResult{valid: true, hallucinations: []}` — every cited ID is found in the set despite the three comment syntaxes
* **Integration Scenario: ITS-009-A2**
  * **Given** a `generated_files` set citing `REQ-999` (not present in `vmodel_id_set`)
  * **When** ARCH-009 is invoked
  * **Then** ARCH-009 returns `VerifyResult{valid: false, hallucinations: [{file, line, id: "REQ-999"}]}` and the contract invariant `valid ⟺ len(hallucinations) == 0` holds

---

### Module Verification: ARCH-010 (Source Region Splicer)

**Parent System Components**: SYS-007

#### Test Case: ITP-010-A (Region-preserving splice contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies ARCH-010's contract that all bytes outside
V-Model-managed regions are preserved byte-for-byte.

* **Integration Scenario: ITS-010-A1**
  * **Given** a `target_path` that already exists with user content above and below a V-Model-managed region
  * **When** ARCH-005 invokes ARCH-010 with new `generated_content` for the managed region
  * **Then** the returned `final_content` has the user content above and below preserved byte-for-byte and only the managed region content replaced

#### Test Case: ITP-010-B (Overlapping marker abort)

**Technique**: Interface Fault Injection
**Target View**: Interface View
**Description**: Verifies ARCH-010 raises `RegionConflict` (with a diff
report) when overlapping markers are present, rather than silently
producing corrupt output.

* **Integration Scenario: ITS-010-B1**
  * **Given** a `target_path` with two overlapping `<!-- VMODEL-MANAGED -->` markers (e.g., open-open-close-close instead of open-close-open-close)
  * **When** ARCH-005 invokes ARCH-010
  * **Then** ARCH-010 raises `RegionConflict` containing a diff report identifying the overlapping line ranges, no content is written to `final_content`, and ARCH-005's contract obligation to abort before any file is written holds

---

### Module Verification: ARCH-011 (Domain Overlay Loader)

**Parent System Components**: SYS-008

#### Test Case: ITP-011-A (Identity transform when no overlay)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies ARCH-011's contract that `domain_config: null`
produces an `augmented_plan` byte-equal to the input `generation_plan`.

* **Integration Scenario: ITS-011-A1**
  * **Given** ARCH-004 invokes ARCH-011 with `domain_config: null` (representing the absence of `v-model-config.yml`)
  * **When** ARCH-011 returns the `augmented_plan`
  * **Then** the `augmented_plan` is byte-equal to the input `generation_plan` and ARCH-005/ARCH-006 receive no overlay-derived obligations

#### Test Case: ITP-011-B (Malformed overlay propagation)

**Technique**: Interface Fault Injection
**Target View**: Interface View
**Description**: Verifies the fail-closed contract that
`OverlayParseError` is propagated to ARCH-004.

* **Integration Scenario: ITS-011-B1**
  * **Given** a `v-model-config.yml` with malformed YAML (e.g., unclosed mapping)
  * **When** ARCH-011 attempts to parse it
  * **Then** ARCH-011 raises `OverlayParseError`, ARCH-004 propagates the exception as a fail-closed exit (code 1), and ARCH-005/ARCH-006 are NEVER invoked

---

### Module Verification: ARCH-012 (Hazard Task Emitter)

**Parent System Components**: SYS-009

#### Test Case: ITP-012-A (HAZ-NNN verification task emission contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that every `HAZ-NNN` in the input
`hazard_analysis` produces at least one verification task in
`enriched_tasks` naming the HAZ.

* **Integration Scenario: ITS-012-A1**
  * **Given** a parsed `hazard_analysis` containing `HAZ-001` and `HAZ-002` and a `tasks` list of length N
  * **When** ARCH-012 returns `enriched_tasks` to ARCH-003
  * **Then** the returned list has length ≥ N+2 (at least one verification task per HAZ) and each new task's text contains the literal string `HAZ-001` or `HAZ-002` respectively
* **Integration Scenario: ITS-012-A2**
  * **Given** a parsed `hazard_analysis` mapping `HAZ-001` to mitigation `REQ-007`
  * **When** ARCH-012 returns `enriched_tasks`
  * **Then** any task implementing `REQ-007` has its priority field raised relative to the input (mitigation-task priority elevation, per the module description)

#### Test Case: ITP-012-B (Malformed hazard analysis propagation)

**Technique**: Interface Fault Injection
**Target View**: Interface View
**Description**: Verifies ARCH-012 raises `MalformedHazardAnalysis`
(rather than degrading silently) when the hazard input fails parse.

* **Integration Scenario: ITS-012-B1**
  * **Given** a `hazard_analysis` input with a non-table line where a HAZ table row is expected
  * **When** ARCH-012 attempts to enrich
  * **Then** ARCH-012 raises `MalformedHazardAnalysis` with the offending line number and ARCH-003 propagates as `HazardEnrichmentError`

---

### Module Verification: ARCH-013 (Spec-Kit Schema Validator)

**Parent System Components**: SYS-010

#### Test Case: ITP-013-A (Strict-validation contract + pinned version reporting)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the strict-validation contract and that
`pinned_version` is always reported on the validation result.

* **Integration Scenario: ITS-013-A1**
  * **Given** a `plan.md` matching the canonical `plan-template.md` schema for spec-kit-core v0.7.0
  * **When** ARCH-001 invokes `validate_plan_schema(doc)` on ARCH-013
  * **Then** the returned `ValidationResult` has `valid: true`, `errors: []`, and the run summary (via ARCH-016) includes `pinned_version: "v0.7.0"`
* **Integration Scenario: ITS-013-A2**
  * **Given** a `tasks.md` with a missing required section
  * **When** ARCH-003 invokes `validate_tasks_schema(doc)` on ARCH-013
  * **Then** the returned `ValidationResult` has `valid: false` and `errors[]` contains an entry naming the missing section, the line offset, and a remediation message

---

### Module Verification: ARCH-014 (Reduced-Enrichment Fallback)

**Parent System Components**: SYS-010

#### Test Case: ITP-014-A (Hybrid-path enrichment detection contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the contract that an upstream `plan.md`
produced by `speckit.plan` (no V-Model enrichment) yields
`{enriched: false}`, while an upstream `plan.md` produced by
`speckit.v-model.plan` yields `{enriched: true}`.

* **Integration Scenario: ITS-014-A1**
  * **Given** an upstream `plan.md` with NO `<!-- vmodel: ... -->` HTML comments
  * **When** ARCH-003 invokes `detect_enrichment(plan.md)` on ARCH-014
  * **Then** ARCH-014 returns `EnrichmentReport{enriched: false, missing_metadata_keys: [<list of expected keys>]}` and ARCH-003 takes the V-Model-direct trace-population branch
* **Integration Scenario: ITS-014-A2**
  * **Given** an upstream `plan.md` with the full V-Model HTML-comment metadata block
  * **When** ARCH-003 invokes `detect_enrichment(plan.md)` on ARCH-014
  * **Then** ARCH-014 returns `EnrichmentReport{enriched: true, missing_metadata_keys: []}` and ARCH-003 takes the enrichment-already-present branch (no re-population from V-Model artifacts)

---

### Module Verification: ARCH-015 (Hook Registrar)

**Parent System Components**: SYS-011

#### Test Case: ITP-015-A (Idempotent hook registration contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the documented idempotency contract:
re-registering an existing hook does NOT duplicate the entry in
`.specify/extensions.yml`.

* **Integration Scenario: ITS-015-A1**
  * **Given** an `extensions.yml` already containing the `before_implement: v-model.trace` registration
  * **When** ARCH-015 is invoked to register the same hook again
  * **Then** `WriteResult{added: 0, skipped_existing: 1}` is returned and the YAML file is byte-equal to its prior contents (apart from any whitespace-preserving tmp-file rename via ARCH-021)
* **Integration Scenario: ITS-015-A2**
  * **Given** an `extensions.yml` missing the `after_specify: v-model.requirements` registration
  * **When** ARCH-015 is invoked to add it
  * **Then** `WriteResult{added: 1, skipped_existing: 0}` is returned and the resulting YAML contains exactly one new line under the `after_specify` key — the surrounding hook infrastructure is untouched

#### Test Case: ITP-015-B (IO failure propagation)

**Technique**: Interface Fault Injection
**Target View**: Interface View
**Description**: Verifies `IOError` from ARCH-021 propagates to ARCH-015's caller per the declared contract.

* **Integration Scenario: ITS-015-B1**
  * **Given** ARCH-021 raises `IOError` on the rename step
  * **When** ARCH-015 catches the exception
  * **Then** ARCH-015 propagates `IOError` to its caller and `extensions.yml` remains byte-equal to its prior contents (atomicity guarantee from ARCH-021)

---

### Module Verification: ARCH-016 (Structured Summary Reporter)

**Parent System Components**: SYS-012

#### Test Case: ITP-016-A (Always-emit contract on success and failure)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the contract that the stdout summary is emitted
on every exit path (success and failure), per the existing
`v-model.test-results` / `v-model.audit-report` summary grammar.

* **Integration Scenario: ITS-016-A1**
  * **Given** ARCH-001 invokes ARCH-016 with a `run_result` whose `fatal_errors[]` is empty
  * **When** ARCH-016 emits the stdout summary
  * **Then** the summary contains the four mandatory sections (`inputs_read`, `outputs_produced`, `artifacts_skipped`, `warnings`) and no `fatal_errors` section
* **Integration Scenario: ITS-016-A2**
  * **Given** ARCH-001 invokes ARCH-016 with a `run_result` containing a non-empty `fatal_errors[]` field after an `EnrichmentError`
  * **When** ARCH-016 emits the stdout summary
  * **Then** the summary contains the `fatal_errors` section with the error text and the surrounding sections still appear (ARCH-016 must not be skipped on the failure path)

---

### Module Verification: ARCH-017 (Quality Compliance Harness)

**Parent System Components**: SYS-013

#### Test Case: ITP-017-A (Four-stack 100%-gate contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the merge-gate contract:
`merge_gate == "allow"` ⟺ every harness reports 100%.

* **Integration Scenario: ITS-017-A1**
  * **Given** ARCH-020 returns 100% for all four harnesses (BATS, Pester, structural eval, LLM eval)
  * **When** ARCH-017 aggregates
  * **Then** `CoverageReport{merge_gate: "allow"}` is returned
* **Integration Scenario: ITS-017-A2**
  * **Given** ARCH-020 returns 99% for the structural eval harness and 100% for the other three
  * **When** ARCH-017 aggregates
  * **Then** `CoverageReport{merge_gate: "block"}` is returned and `structural_eval: 99` is reported in the result struct

---

### Module Verification: ARCH-018 (Commit Annotator)

**Parent System Components**: SYS-014

#### Test Case: ITP-018-A (ID-suffix annotation contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the annotation contract — the suffix is added
when `ids` is non-empty and omitted when `ids` is empty.

* **Integration Scenario: ITS-018-A1**
  * **Given** ARCH-004 invokes ARCH-018 with `message = "feat(007): add bridge commands"` and `ids = ["REQ-001", "REQ-002"]`
  * **When** ARCH-018 returns the `annotated_message`
  * **Then** the annotated message equals `"feat(007): add bridge commands — REQ-001, REQ-002"`
* **Integration Scenario: ITS-018-A2**
  * **Given** ARCH-004 invokes ARCH-018 with `ids = []`
  * **When** ARCH-018 returns the `annotated_message`
  * **Then** the annotated message is byte-equal to the input `message` (suffix omitted) and a warning entry appears in the call's structured logs (no exception raised — best-effort contract)

---

### Module Verification: ARCH-019 [CROSS-CUTTING] (V-Model Artifact Reader)

**Parent System Components**: [CROSS-CUTTING] — consumed by ARCH-001, ARCH-003, ARCH-004, ARCH-007, ARCH-009, ARCH-014

#### Test Case: ITP-019-A (Stable in-memory representation across consumers)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that the same `feature_dir` invocation returns
a structurally identical `ArtifactSet` regardless of caller — the
no-per-command-drift invariant central to REQ-NF-003.

* **Integration Scenario: ITS-019-A1**
  * **Given** a `feature_dir` containing `requirements.md`, `module-design.md`, and `hazard-analysis.md`
  * **When** ARCH-001 and ARCH-004 both invoke `load_artifacts(feature_dir)` on ARCH-019 in the same process
  * **Then** the two returned `ArtifactSet` structs are field-for-field equal (no caller-specific projection or filtering is applied at the boundary)
* **Integration Scenario: ITS-019-A2**
  * **Given** the same `feature_dir`
  * **When** ARCH-009 invokes ARCH-019 to obtain the `vmodel_id_set`
  * **Then** the returned set is exactly the union of every REQ/ATP/SCN/SYS/STP/STS/ARCH/ITP/ITS/MOD/UTP/UTS/HAZ ID present in the artifact set (per the contract) and contains zero duplicates

#### Test Case: ITP-019-B (Malformed artifact propagation)

**Technique**: Interface Fault Injection
**Target View**: Interface View
**Description**: Verifies `MalformedArtifact` propagation as fatal,
preventing partial `ArtifactSet` from reaching downstream callers.

* **Integration Scenario: ITS-019-B1**
  * **Given** a `feature_dir` whose `requirements.md` has a malformed REQ table header
  * **When** ARCH-001 invokes `load_artifacts(feature_dir)` on ARCH-019
  * **Then** ARCH-019 raises `MalformedArtifact{path, reason}` and ARCH-001 receives no `ArtifactSet` at all (no partial struct with nullable failures — the contract is fatal)

#### Test Case: ITP-019-C (Concurrent and write-then-immediately-read race contract)

**Technique**: Concurrency & Race Condition Testing
**Target View**: Process View / Interface View
**Description**: Verifies that ARCH-019 returns a coherent `ArtifactSet`
when invoked concurrently by multiple callers and when invoked
*immediately after* a sibling component (ARCH-005 / ARCH-006 / ARCH-021)
has written to the same `feature_dir`, with no torn reads, partial-file
observations, or interleaved content from in-flight writes. Mitigates
HAZ-023 (Critical: race condition in bridge state where ARCH-019 reads
artifacts mid-write by ARCH-005/006/021, producing a partial
`ArtifactSet` that propagates downstream as silent corruption).
Pre-loaded by `impact-analysis/critical-hazard-verification-profile.md`;
raised by peer-review finding PRF-ITP-001.

* **Integration Scenario: ITS-019-C1**
  * **Given** a `feature_dir` containing a complete V-Model artifact set, and N=8 worker threads (or processes) each prepared to invoke `load_artifacts(feature_dir)` simultaneously
  * **When** all N workers invoke ARCH-019 concurrently against the same `feature_dir` (synchronised by a shared barrier so the calls overlap maximally)
  * **Then** every worker receives an `ArtifactSet` that is field-for-field equal to every other worker's result, no worker observes a `MalformedArtifact` exception attributable to read interleaving, and the `vmodel_id_set` derived from any worker's result is identical to the set derived from a single-threaded baseline call
* **Integration Scenario: ITS-019-C2**
  * **Given** a `feature_dir` and a paired writer (ARCH-021 atomic-write primitive) that is producing or updating an artifact file (e.g., `traceability-matrix.md`) on a tight loop
  * **When** ARCH-019 invokes `load_artifacts(feature_dir)` while the writer is in flight (the read is initiated *between* the writer's tmp-write and rename steps and *between* successive write cycles)
  * **Then** ARCH-019 either (a) observes the pre-write state in full, or (b) observes the post-write state in full — never a torn intermediate state — for every read attempt across ≥100 iterations; any read that would otherwise observe a partial file MUST raise `MalformedArtifact` rather than silently return a half-parsed struct
* **Integration Scenario: ITS-019-C3**
  * **Given** a `feature_dir` where two different sibling writers are simultaneously updating two *different* artifact files (e.g., ARCH-005 writing a target source file and ARCH-021 writing the structured summary)
  * **When** ARCH-019 invokes `load_artifacts(feature_dir)` while both writers are in flight
  * **Then** the returned `ArtifactSet` reflects a consistent ordering — for each file, either the pre- or post-write state, never an interleaving of the two — and the contract holds even when the two writers operate on artifacts that are mutually referenced (cross-file ID dependencies)

---

### Module Verification: ARCH-020 [CROSS-CUTTING] (Subprocess Runner)

**Parent System Components**: [CROSS-CUTTING] — consumed by ARCH-007, ARCH-017, ARCH-018

#### Test Case: ITP-020-A (Stdout/stderr/exit-code capture contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the `RunResult` contract: every invocation
returns `{exit_code, stdout, stderr}` with UTF-8-decoded streams.

* **Integration Scenario: ITS-020-A1**
  * **Given** a script that writes one line to stdout, one line to stderr, and exits 0
  * **When** ARCH-007 invokes ARCH-020 with the script path
  * **Then** the returned `RunResult` has `exit_code: 0`, `stdout` containing exactly the stdout line, `stderr` containing exactly the stderr line, and the two streams are NOT interleaved in either field

#### Test Case: ITP-020-B (Subprocess failure exception contract)

**Technique**: Interface Fault Injection
**Target View**: Interface View
**Description**: Verifies `SubprocessFailure` is raised when the
subprocess cannot be invoked at all (script-not-found, permission-denied),
distinct from a non-zero exit code (which is a normal `RunResult`).

* **Integration Scenario: ITS-020-B1**
  * **Given** a `command` whose first element points to a non-existent script
  * **When** ARCH-007 invokes ARCH-020
  * **Then** ARCH-020 raises `SubprocessFailure` with the text and exit code (e.g., `127`) — the caller sees an exception, not a `RunResult{exit_code: 127}`
* **Integration Scenario: ITS-020-B2**
  * **Given** a script that writes binary data to stdout
  * **When** ARCH-020 attempts to decode the output
  * **Then** ARCH-020 raises `SubprocessFailure` (binary output rejected per contract) — preventing non-UTF-8 bytes from reaching ARCH-007's JSON parser

#### Test Case: ITP-020-C (Malformed YAML / corrupted-config fault propagation)

**Technique**: Interface Fault Injection
**Target View**: Interface View
**Description**: Verifies that when a subprocess invoked by ARCH-020 emits
malformed YAML (or other structured-config payload) on stdout — or when
an upstream config file consumed by such a subprocess is itself
malformed — the failure is surfaced to the caller as a typed parse
error (`MalformedConfigPayload` / `OverlayParseError`) rather than
silently coerced into an empty / default config struct. Mitigates
HAZ-024 (Critical: malformed `v-model-config.yml` parsed as empty
overlay → SYS-008 silently downgrades to base behaviour, defeating the
configured domain). Pre-loaded by
`impact-analysis/critical-hazard-verification-profile.md`; raised by
peer-review finding PRF-ITP-002.

* **Integration Scenario: ITS-020-C1**
  * **Given** a script that emits malformed YAML on stdout (e.g., unbalanced braces, mixed indentation, a mapping key with no value, or a duplicated top-level key per YAML 1.2 §5.4)
  * **When** ARCH-007 / ARCH-011 invokes ARCH-020 expecting a structured payload
  * **Then** the malformed-YAML failure is surfaced to the caller as a typed parse exception (e.g., `MalformedConfigPayload{exit_code, snippet, parser_error}`) — NOT silently converted to `{}` (empty config) and NOT silently substituted by a default — and the caller can attribute the run abort to a parse failure rather than a missing config
* **Integration Scenario: ITS-020-C2**
  * **Given** a `v-model-config.yml` file on disk that is syntactically malformed (e.g., a tab character where YAML requires spaces, or a stray non-printable byte at the file head)
  * **When** ARCH-011 (Domain Overlay Loader) reads the file directly (not via subprocess) and attempts to parse it
  * **Then** ARCH-011 raises `OverlayParseError` carrying the parser diagnostic and line number, ARCH-004 propagates the exception fail-closed, the structured stdout summary names the parse failure (NOT `domain: none`), and SYS-008 does NOT silently downgrade to base behaviour (HAZ-024 mitigation gate)
* **Integration Scenario: ITS-020-C3**
  * **Given** a `v-model-config.yml` whose top-level YAML parses successfully but whose `domain:` value is the empty string, `null`, or omitted while the file is otherwise well-formed
  * **When** ARCH-011 reads the file
  * **Then** ARCH-011 distinguishes "file-absent" (legitimate no-overlay path) from "file-present-but-domain-unset" (configuration error) — the latter raises `OverlayParseError` so SYS-003 fails closed rather than silently degrading to base behaviour

#### Test Case: ITP-020-D (Stream interleaving under heavy output)

**Technique**: Concurrency & Race Condition Testing
**Target View**: Process View
**Description**: Verifies stdout/stderr are correctly separated even when
the child process emits to both streams interleaved at OS level — the
single-threaded sequential consumer in ARCH-020 must not corrupt either
stream.

* **Integration Scenario: ITS-020-D1**
  * **Given** a child script that emits ~64KB of alternating stdout/stderr lines as fast as possible
  * **When** ARCH-020 captures the streams
  * **Then** the returned `stdout` contains all stdout lines in order, `stderr` contains all stderr lines in order, no line is split or duplicated, and no stderr line appears in `stdout` (or vice versa)

---

### Module Verification: ARCH-021 [CROSS-CUTTING] (Filesystem Writer)

**Parent System Components**: [CROSS-CUTTING] — consumed by ARCH-002, ARCH-005, ARCH-006, ARCH-010, ARCH-015

#### Test Case: ITP-021-A (Atomic write contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the write-to-tmp + rename atomic-write contract.

* **Integration Scenario: ITS-021-A1**
  * **Given** an existing file at `path` with content C0 and a new `content` C1
  * **When** ARCH-002 invokes ARCH-021 with `(path, C1)`
  * **Then** at every observable filesystem state during the call, the file at `path` contains either C0 or C1 — never a partial or interleaved state — and after the call returns, the file contains C1
* **Integration Scenario: ITS-021-A2**
  * **Given** an existing file at `path` and a target directory the process can write to
  * **When** ARCH-021 begins the write
  * **Then** a tmp file is created in the target directory (NOT in `/tmp`, which would prevent atomic rename across filesystems) and the rename completes within the same syscall

#### Test Case: ITP-021-B (IOError propagation when tmp-write fails)

**Technique**: Interface Fault Injection
**Target View**: Interface View
**Description**: Verifies `IOError` is raised AND the existing file is
left untouched when the tmp-file write fails (e.g., disk full).

* **Integration Scenario: ITS-021-B1**
  * **Given** a target directory with insufficient free space for the tmp file
  * **When** ARCH-005 invokes ARCH-021 with the new content
  * **Then** ARCH-021 raises `IOError{text, errno}`, the existing file at `path` is byte-equal to its prior contents, and no tmp file remains on disk after the call (cleanup contract)

#### Test Case: ITP-021-D (Atomicity under simulated interruption)

**Technique**: Concurrency & Race Condition Testing
**Target View**: Process View
**Description**: Verifies atomicity is preserved when the writer is
interrupted between tmp-write and rename — the rename is the
linearization point.

* **Integration Scenario: ITS-021-D1**
  * **Given** a process invoking ARCH-021 to write content C1 to a `path` containing C0
  * **When** the process is killed (SIGKILL) AFTER the tmp-file is fully written but BEFORE the rename syscall completes
  * **Then** an external observer reading `path` sees content C0 (the rename never happened) and the orphan tmp file is still on disk (cleanup is the responsibility of the next ARCH-021 invocation, not of the killed process)
* **Integration Scenario: ITS-021-D2**
  * **Given** a process invoking ARCH-021 to write C1 to `path`
  * **When** the process is killed AFTER the rename syscall completes but BEFORE control returns to the caller
  * **Then** an external observer reading `path` sees content C1 (the rename committed) — proving the rename is the linearization point and the contract holds even on interruption

---

## Test Harness & Mocking Strategy

| Test Case | External Dependency | Mock/Stub Strategy | Rationale |
|-----------|---------------------|--------------------|-----------|
| ITP-001-A, ITP-001-B | ARCH-008, ARCH-013, ARCH-002, ARCH-016 | In-process **spy** that records call args + returns canned responses | Verifying ARCH-001's orchestration calls — need to assert the call sequence and arguments, not the downstream module behavior |
| ITP-002-A, ITP-002-B | ARCH-021 | **Stub** returning `ok` for ITP-002-A; **fake** filesystem for ITP-002-B (e.g., `pyfakefs`/`memfs`) raising `IOError` mid-emission | Real filesystem in ITP-002-A is fine; ITP-002-B needs deterministic fault-injection |
| ITP-003-A, ITP-003-B, ITP-003-C | ARCH-019, ARCH-014, ARCH-012, ARCH-008, ARCH-013, ARCH-021 | Spies for sequence verification (ITP-003-A); ARCH-012 stub returning identity for ITP-003-B1 and raising for ITP-003-B2; real modules end-to-end for ITP-003-C with seeded fixtures | Data Flow test (ITP-003-C) must use real implementations to be a true integration test |
| ITP-004-A, ITP-004-B, ITP-004-D | ARCH-007, ARCH-005, ARCH-006, ARCH-009, ARCH-018, ARCH-021 | Spies + stubs for ITP-004-A/B; real ARCH-021 (with real tmp filesystem) for ITP-004-D race tests | Concurrency tests need real atomic-write semantics |
| ITP-005-A, ITP-005-B, ITP-005-C | ARCH-010, ARCH-021 | Real ARCH-010; ARCH-021 stub for ITP-005-A; real ARCH-021 for ITP-005-C end-to-end | Splice behavior is non-trivial — must be tested with real ARCH-010 |
| ITP-006-A | ARCH-019, ARCH-021 | ARCH-019 fixture-loaded `ArtifactSet`; real ARCH-021 with tmp test directory | Test files written to a tmp dir, read back to verify level coverage |
| ITP-007-A, ITP-007-B | ARCH-020 | **Stub** ARCH-020 returning canned `RunResult` JSON per scenario | Avoids running the real `validate-*-coverage.sh` scripts in this layer (those are tested at unit level) |
| ITP-008-A, ITP-008-B | ARCH-013 | Real ARCH-013 with the pinned schema | Round-trip property must be tested against the real validator, not a stub |
| ITP-009-A | ARCH-019 | Stub returning a canned `vmodel_id_set` | Isolates ARCH-009's verification logic from artifact-loading concerns |
| ITP-010-A, ITP-010-B | None (pure module) | None | ARCH-010 is a pure transform on strings + tmp file — no dependencies to stub |
| ITP-011-A, ITP-011-B | YAML parser | Real parser (no stub) — fault injection via fixture YAML files | Parser fault injection is what we are testing |
| ITP-012-A, ITP-012-B | None (pure module) | None | ARCH-012 is a pure transform on parsed structs |
| ITP-013-A | spec-kit-core schema fixtures | Versioned fixture files committed under `tests/fixtures/spec-kit-core/v0.7.0/` | Ensures pinned-version testing is reproducible |
| ITP-014-A | None (pure detection) | None | ARCH-014 reads markers in input doc — no dependencies |
| ITP-015-A, ITP-015-B | ARCH-021 | Real ARCH-021 with a tmp `extensions.yml`; fault-injection fake for ITP-015-B | Idempotency must be verified against real YAML round-tripping |
| ITP-016-A | None (stdout sink) | Capture stdout in test harness | Asserts on exact summary text |
| ITP-017-A | ARCH-020 | Stub returning canned per-harness coverage JSON | Avoids running the actual four test stacks in this layer |
| ITP-018-A | ARCH-020 (for git invocation) | Spy on `git commit` invocation | Asserts annotated message text without producing real commits in test repo |
| ITP-019-A, ITP-019-B | Real filesystem | Fixture `feature_dir` trees committed under `tests/fixtures/feature-dirs/` | Real Markdown parsing must be exercised |
| ITP-019-C | Real OS threads/processes + real filesystem | `threading.Barrier` (or `multiprocessing.Barrier`) coordinates N concurrent readers (ITS-019-C1); a sibling thread/process drives a real ARCH-021 atomic-writer in a tight loop against the reader (ITS-019-C2); a coordinated dual-writer harness invokes two real ARCH-021 writes against two distinct files in lock-step (ITS-019-C3) | A mocked filesystem cannot verify the read-during-rename invariant — real OS rename semantics are required (HAZ-023 mitigation) |
| ITP-020-A, ITP-020-B, ITP-020-D | Real subprocess | Helper scripts shipped in `tests/scripts/` | Subprocess capture semantics must be tested end-to-end |
| ITP-020-C | Mixed: real subprocess for ITS-020-C1; direct file read for ITS-020-C2/C3 | (i) Malformed-YAML stdout helper script in `tests/scripts/` for ITS-020-C1 (subprocess path through ARCH-020); (ii) malformed-YAML fixtures under `tests/fixtures/v-model-config/malformed/` (e.g., `tab-indent.yml`, `unclosed-mapping.yml`, `non-printable-byte.yml`) consumed directly by ARCH-011 for ITS-020-C2; (iii) `domain-empty.yml` fixture for ITS-020-C3 | ITS-020-C2/C3 straddle the ARCH-020 / ARCH-011 boundary — the subprocess machinery of ARCH-020 is NOT on the call path; tests target ARCH-011's direct file read (HAZ-024 mitigation) |
| ITP-021-A, ITP-021-B, ITP-021-D | Real filesystem (tmp) | Real OS rename + signal-controlled child process for ITP-021-D | Atomicity contract is OS-level — cannot be mocked |

---

## V&V Coverage (IEEE 1012:2016)

### Architecture Module–to–V&V Activity Mapping

Per IEEE 1012:2016 §5.6, every architecture module interface MUST be
exercised by at least one V&V activity at the integration test layer.

| ARCH | Module | ITPs Covering | Inter-module Interfaces Exercised |
|------|--------|---------------|----------------------------------|
| ARCH-001 | Plan Synthesis Orchestrator | ITP-001-A, ITP-001-B | → ARCH-008, → ARCH-013, → ARCH-002, → ARCH-016, ← ARCH-019 |
| ARCH-002 | Canonical Artifact Emitter | ITP-002-A, ITP-002-B | → ARCH-021, ← ARCH-001 |
| ARCH-003 | Tasks Synthesis Orchestrator | ITP-003-A, ITP-003-B, ITP-003-C | → ARCH-014, → ARCH-012, → ARCH-008, → ARCH-013, → ARCH-021, ← ARCH-019 |
| ARCH-004 | Implementation Orchestrator | ITP-004-A, ITP-004-B, ITP-004-D | → ARCH-007, → ARCH-011, → ARCH-005, → ARCH-006, → ARCH-009, → ARCH-018 |
| ARCH-005 | Code Generator | ITP-005-A, ITP-005-B, ITP-005-C | → ARCH-010, → ARCH-021, ← ARCH-004 |
| ARCH-006 | Test Generator | ITP-006-A | → ARCH-021, ← ARCH-004, ← ARCH-019 |
| ARCH-007 | Pre-Implementation Gate Coordinator | ITP-007-A, ITP-007-B | → ARCH-020, ← ARCH-004 |
| ARCH-008 | Additive Enrichment Encoder | ITP-008-A, ITP-008-B | ← ARCH-001, ← ARCH-003, → (none — pure transform) |
| ARCH-009 | Hallucination Guard | ITP-009-A | ← ARCH-004, ← ARCH-019 |
| ARCH-010 | Source Region Splicer | ITP-010-A, ITP-010-B | ← ARCH-005 |
| ARCH-011 | Domain Overlay Loader | ITP-011-A, ITP-011-B | ← ARCH-004 |
| ARCH-012 | Hazard Task Emitter | ITP-012-A, ITP-012-B | ← ARCH-003 |
| ARCH-013 | Spec-Kit Schema Validator | ITP-013-A | ← ARCH-001, ← ARCH-003 |
| ARCH-014 | Reduced-Enrichment Fallback | ITP-014-A | ← ARCH-003 |
| ARCH-015 | Hook Registrar | ITP-015-A, ITP-015-B | → ARCH-021 |
| ARCH-016 | Structured Summary Reporter | ITP-016-A | ← ARCH-001, ← ARCH-003, ← ARCH-004 |
| ARCH-017 | Quality Compliance Harness | ITP-017-A | → ARCH-020 |
| ARCH-018 | Commit Annotator | ITP-018-A | → ARCH-020 (git), ← ARCH-004 |
| ARCH-019 | V-Model Artifact Reader [CC] | ITP-019-A, ITP-019-B | → (consumed by 6 modules — covered by ITS-019-A1) |
| ARCH-020 | Subprocess Runner [CC] | ITP-020-A, ITP-020-B, ITP-020-D | → (consumed by 3 modules — exercised in ITP-007-A and ITP-017-A) |
| ARCH-021 | Filesystem Writer [CC] | ITP-021-A, ITP-021-B, ITP-021-D | → (consumed by 5 modules — exercised in ITP-002, ITP-005, ITP-015) |

### Entry Criteria Check (IEEE 1012:2016 §5.6.1)

- ✅ `architecture-design.md` is current (committed `0414411`)
- ✅ Every `ARCH-NNN` module has at least one `ITP-NNN-X` test case (21/21 = 100% forward coverage)
- ✅ All `ITP-NNN-X` test cases have at least one `ITS-NNN-X#` executable scenario
- ✅ V&V gap list is empty — all integration boundaries covered
- ⚠️ Architecture design peer-review pending (`m1-007-peer-review` in Phase 1a) — this entry criterion will be satisfied before merge to `main`

**Gap list:** *None.*

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Architecture Modules (ARCH) | 21 (21 active, 0 deprecated) |
| Total Test Cases (ITP) | 42 |
| Total Scenarios (ITS) | 74 |
| Modules with ≥1 ITP | 21 / 21 (100%) (active items only) |
| Test Cases with ≥1 ITS | 42 / 42 (100%) |
| **Overall Coverage (ARCH→ITP)** | **100%** |

### Technique Distribution

| Technique | Test Cases | Percentage |
|-----------|-----------|------------|
| Interface Contract Testing | 21 | 50.0% |
| Interface Fault Injection | 15 | 35.7% |
| Data Flow Testing | 2 | 4.8% |
| Concurrency & Race Condition Testing | 4 | 9.5% |

## Uncovered Modules

None — full coverage achieved.
