# System Test Plan: Bridge Commands

**Feature Branch**: `feature/007-bridge-commands`
**Created**: 2026-04-26
**Status**: Draft
**Source**: `specs/007-bridge-commands/v-model/system-design.md`

## Overview

This document defines the System Test Plan for the bridge-commands feature.
Every system component in `system-design.md` (SYS-001 … SYS-014) has one or
more Test Cases (STP), and every Test Case has one or more executable System
Scenarios (STS) in technical BDD format (Given/When/Then).

Test cases target the IEEE 1016 design view most relevant to the component
under test, applying the matching ISO 29119 technique. Subsystems exposed at
the CLI boundary (SYS-001/002/003) are exercised with both Interface Contract
Testing (against the spec-kit-core canonical schemas) and Fault Injection
(against their cross-cutting dependencies). Cross-cutting services and
modules are tested against the contract they expose to the subsystems they
serve. The Pre-Implementation Gate (SYS-004) and Hallucination Guard (SYS-006)
are explicitly fault-injected to verify their fail-closed property.

System tests verify **architectural behavior**, not user journeys. Language is
technical and component-oriented throughout.

No domain overlay is loaded for this feature (`v-model-config.yml` is absent at
the repository root); no structural-coverage targets (e.g., MC/DC) or
resource-usage thresholds (e.g., WCET) apply to this test plan.

## ID Schema

- **System Test Case**: `STP-{NNN}-{X}` — NNN matches the parent SYS, X is a letter suffix (A, B, C…)
- **System Test Scenario**: `STS-{NNN}-{X}{#}` — nested under the parent STP, with numeric suffix (1, 2, 3…)
- Example: `STS-001-A1` → Scenario 1 of Test Case A verifying SYS-001

## ISO 29119 Test Techniques

- **Interface Contract Testing** — Verifies API contracts from the Interface View (external CLI commands and internal in-process functions)
- **Boundary Value Analysis** — Tests data limits and presence/absence boundaries from the Data Design View
- **Equivalence Partitioning** — Tests representative classes (e.g., gate states, valid/mixed/all-hallucinated ID sets, configured-domain variants)
- **Fault Injection** — Tests failure propagation paths from the Dependency View

## System Tests

### Component Verification: SYS-001 (Plan Synthesizer)

**Parent Requirements**: REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-026, REQ-027, REQ-NF-005, REQ-IF-001

#### Test Case: STP-001-A (CLI command produces all canonical outputs from a complete V-Model artifact set)

**Technique**: Interface Contract Testing
**Target View**: Interface View (External — `/speckit.v-model.plan` CLI)
**Description**: Verifies that, given a feature directory containing every V-Model artifact, the Plan Synthesizer emits every canonical spec-kit-core output in the prescribed locations and that each output conforms to the spec-kit-core canonical schema.

* **System Scenario: STS-001-A1**
  * **Given** a feature directory `specs/<feature>/v-model/` containing `requirements.md`, `acceptance-plan.md`, `system-design.md`, `system-test.md`, `architecture-design.md`, `integration-test.md`, `module-design.md`, `unit-test.md`, `hazard-analysis.md`, `traceability-matrix.md`, and a present `.specify/memory/constitution.md`
  * **When** the `/speckit.v-model.plan` command is invoked against that feature
  * **Then** the command exits 0 and writes `plan.md`, `data-model.md`, `contracts/`, `quickstart.md`, and `research.md` under `specs/<feature>/`, with `plan.md` validating against spec-kit-core's canonical `plan-template.md` schema (all required sections present and in the prescribed order)

* **System Scenario: STS-001-A2**
  * **Given** the same complete feature directory and a `system-design.md` whose Data Design View declares 3 entities and an `architecture-design.md` whose Interface View declares 4 contracts
  * **When** `/speckit.v-model.plan` is invoked
  * **Then** the emitted `data-model.md` enumerates the same 3 entities and the emitted `contracts/` directory contains exactly 4 files

#### Test Case: STP-001-B (Graceful degradation when optional V-Model artifacts are absent)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View (presence/absence of optional artifact entities)
**Description**: Exercises the absence boundary for each optional V-Model input; verifies the corresponding output sections are omitted, the run completes successfully, and the structured summary names every missing artifact.

* **System Scenario: STS-001-B1**
  * **Given** a feature directory containing `requirements.md` and `acceptance-plan.md` but missing `architecture-design.md`, `module-design.md`, and `hazard-analysis.md`
  * **When** `/speckit.v-model.plan` is invoked
  * **Then** the command exits 0 with a non-zero warning indicator in its summary, omits the `contracts/` directory, and lists `architecture-design.md`, `module-design.md`, and `hazard-analysis.md` in the "Skipped Artifacts" section of the structured stdout summary

* **System Scenario: STS-001-B2**
  * **Given** a feature directory containing every required artifact except `acceptance-plan.md`
  * **When** `/speckit.v-model.plan` is invoked
  * **Then** the command exits 0 with warning, omits `quickstart.md` from the output set, and names `acceptance-plan.md` in the skipped list

#### Test Case: STP-001-C (Failure of cross-cutting dependencies aborts the run before partial output is committed)

**Technique**: Fault Injection
**Target View**: Dependency View (SYS-001 → SYS-005, SYS-001 → SYS-010)
**Description**: Verifies the fail-closed behavior of the Plan Synthesizer when its enrichment encoder or compatibility-layer dependencies fail.

* **System Scenario: STS-001-C1**
  * **Given** SYS-005 (Additive-Enrichment Encoder) is stubbed to raise on every `embed_enrichment` invocation
  * **When** `/speckit.v-model.plan` is invoked against a complete feature directory
  * **Then** the Plan Synthesizer exits non-zero, no `plan.md` is written to disk, and the structured summary contains an "Outputs Produced: 0" line and an enrichment-failure error message

* **System Scenario: STS-001-C2**
  * **Given** SYS-010 (Compatibility Layer) is stubbed to return `{valid: false, errors: ["missing required section"]}` on every `validate_plan_schema` call
  * **When** `/speckit.v-model.plan` is invoked
  * **Then** the command exits non-zero, no canonical output files are committed to disk, and the error message references the violated schema section

---

### Component Verification: SYS-002 (Tasks Synthesizer)

**Parent Requirements**: REQ-009, REQ-010, REQ-011, REQ-013, REQ-014, REQ-026, REQ-027, REQ-NF-005, REQ-IF-002

#### Test Case: STP-002-A (CLI command produces a schema-conformant tasks.md from any plan.md source)

**Technique**: Interface Contract Testing
**Target View**: Interface View (External — `/speckit.v-model.tasks` CLI)
**Description**: Verifies the round-trip-capable path: the Tasks Synthesizer accepts both V-Model-enriched and pure spec-kit-core `plan.md` inputs and produces a `tasks.md` validating against the canonical `tasks-template.md` schema.

* **System Scenario: STS-002-A1**
  * **Given** a feature directory containing a `plan.md` produced by `/speckit.v-model.plan` and a complete V-Model artifact set
  * **When** `/speckit.v-model.tasks` is invoked
  * **Then** the command exits 0, writes `tasks.md`, and the file passes spec-kit-core's `tasks-template.md` schema validation

* **System Scenario: STS-002-A2**
  * **Given** a feature directory containing a `plan.md` produced by `/speckit.plan` (no V-Model enrichment) and a complete V-Model artifact set
  * **When** `/speckit.v-model.tasks` is invoked
  * **Then** the command exits 0 and writes a schema-conformant `tasks.md` whose tasks still carry `<!-- traces-to: ... -->` comments populated from the V-Model artifacts

#### Test Case: STP-002-B (TDD ordering and `[P]` parallel marker correctness across module sets)

**Technique**: Equivalence Partitioning
**Target View**: Data Design View (tasks.md task-list entity)
**Description**: Tests representative module-set classes to verify TDD task ordering and correct `[P]` marker emission.

* **System Scenario: STS-002-B1**
  * **Given** a `module-design.md` declaring 3 modules (M1, M2, M3) under the same architecture, with no inter-module dependencies between M1, M2, and M3
  * **When** `/speckit.v-model.tasks` is invoked
  * **Then** the emitted `tasks.md` orders unit-test tasks before implementation tasks before integration-test tasks before system-test tasks before acceptance-test tasks (TDD sequence per REQ-011), and the implementation tasks for M1, M2, M3 each carry the `[P]` marker

* **System Scenario: STS-002-B2**
  * **Given** a `module-design.md` declaring 2 modules where M2 depends on M1 (per the architecture's Dependency View)
  * **When** `/speckit.v-model.tasks` is invoked
  * **Then** the implementation tasks for M1 and M2 do NOT both carry `[P]` (the dependent pair is serialized)

#### Test Case: STP-002-C (Hazard-aware enrichment activates when hazard-analysis.md is present)

**Technique**: Fault Injection
**Target View**: Dependency View (SYS-002 → SYS-009)
**Description**: Verifies that hazard analysis presence raises mitigation priority and triggers HAZ-NNN verification tasks; verifies fault-mode behavior when SYS-009 fails.

* **System Scenario: STS-002-C1**
  * **Given** a `hazard-analysis.md` declaring HAZ-001 and HAZ-002, each with at least one mitigation
  * **When** `/speckit.v-model.tasks` is invoked
  * **Then** the emitted `tasks.md` contains at least one verification task referencing `HAZ-001` and at least one referencing `HAZ-002`, and the tasks implementing the mitigations carry an elevated priority marker relative to non-hazard tasks

* **System Scenario: STS-002-C2**
  * **Given** a `hazard-analysis.md` is present in the feature directory and SYS-009 is stubbed to raise during `enrich_with_hazards`
  * **When** `/speckit.v-model.tasks` is invoked
  * **Then** the command exits non-zero, no `tasks.md` is committed, and the structured summary names the hazard-enrichment failure

---

### Component Verification: SYS-003 (Implementation Engine)

**Parent Requirements**: REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005

#### Test Case: STP-003-A (CLI command generates code at MOD Target Source File paths with traceability comments)

**Technique**: Interface Contract Testing
**Target View**: Interface View (External — `/speckit.v-model.implement` CLI)
**Description**: Verifies that the Implementation Engine reads V-Model artifacts directly (without a `plan.md` or `tasks.md`), writes generated code to the paths declared by each `MOD-NNN` Target Source File, and emits `// Implements <ID>` traceability comments and tests at all four levels.

* **System Scenario: STS-003-A1**
  * **Given** a feature directory containing a complete V-Model artifact set and a `module-design.md` declaring `MOD-001` with Target Source File `src/foo/bar.py`, and no `plan.md` / `tasks.md` files in the feature directory
  * **When** `/speckit.v-model.implement` is invoked
  * **Then** the command exits 0, writes `src/foo/bar.py`, the file contains a comment of the form `# Implements MOD-001 (traces to ARCH-NNN, SYS-NNN, REQ-NNN)`, and unit / integration / system / acceptance test files are written under the project's existing test directories

* **System Scenario: STS-003-A2**
  * **Given** the same feature directory after a successful first run of STS-003-A1
  * **When** `/speckit.v-model.implement` is invoked a second time on the unchanged inputs
  * **Then** the command exits 0 and the diff between the first and second runs has ≥95% structural identity per the project's structural eval comparison (REQ-025 idempotency)

#### Test Case: STP-003-B (Domain overlay augments generated code and tests when configured)

**Technique**: Equivalence Partitioning
**Target View**: Data Design View (`v-model-config.yml` configuration entity)
**Description**: Tests representative configuration classes — no overlay, DO-178C, ISO 26262 — and verifies the augmentation contract.

* **System Scenario: STS-003-B1**
  * **Given** `v-model-config.yml` is absent at the repository root
  * **When** `/speckit.v-model.implement` is invoked against a feature with a complete V-Model artifact set
  * **Then** the command exits 0 and the generated unit-test file contains no MC/DC-coverage assertion comments and no ASIL-driven test-depth markers

* **System Scenario: STS-003-B2**
  * **Given** `v-model-config.yml` declares `domain: do_178c, level: A`
  * **When** `/speckit.v-model.implement` is invoked
  * **Then** the generated unit-test files for every module carry an MC/DC-coverage obligation comment and the structured summary lists `MC/DC: required` for each module

* **System Scenario: STS-003-B3**
  * **Given** `v-model-config.yml` declares `domain: iso_26262, asil: D`
  * **When** `/speckit.v-model.implement` is invoked
  * **Then** the generated test set for every module includes an ASIL-D-depth marker and the structured summary lists `ASIL: D` for each module

#### Test Case: STP-003-C (Cross-cutting safety-net dependencies fail closed)

**Technique**: Fault Injection
**Target View**: Dependency View (SYS-003 → SYS-004 / SYS-006 / SYS-007 / SYS-008)
**Description**: Verifies the Implementation Engine refuses to commit any output when any of its safety-net dependencies fail.

* **System Scenario: STS-003-C1**
  * **Given** SYS-004 (Pre-Implementation Gate) returns `{passed: false, gap_report: "Matrix B incomplete: SYS-007 has no STP"}`
  * **When** `/speckit.v-model.implement` is invoked
  * **Then** the command exits non-zero, no source files are written or modified, no commits are produced, and the gap report is appended verbatim to stdout

* **System Scenario: STS-003-C2**
  * **Given** SYS-006 (Hallucination Guard) detects a `// Implements MOD-999` comment that does not exist in the V-Model artifact set
  * **When** the Implementation Engine reaches the pre-commit verification step
  * **Then** the command exits non-zero, no commit is created, and the structured summary names the hallucinated identifier and the file/line where it appeared

* **System Scenario: STS-003-C3**
  * **Given** SYS-007 (Source Region Manager) detects overlapping V-Model-managed region markers in an existing target source file
  * **When** the Implementation Engine attempts to splice generated content
  * **Then** the command exits non-zero, the target file is left unchanged on disk, and a diff report is written to stdout describing the conflict

* **System Scenario: STS-003-C4**
  * **Given** `v-model-config.yml` declares a configured domain and SYS-008 (Domain Overlay Adapter) raises during `apply_overlay`
  * **When** `/speckit.v-model.implement` is invoked
  * **Then** the command exits non-zero before any code is generated

---

### Component Verification: SYS-004 (Pre-Implementation Gate)

**Parent Requirements**: REQ-016, REQ-017, REQ-NF-004, REQ-CN-002

#### Test Case: STP-004-A (Gate invokes the existing deterministic scripts and propagates their results)

**Technique**: Interface Contract Testing
**Target View**: Interface View (External — subprocess invocation of existing scripts)
**Description**: Verifies the Gate composes the existing `build-matrix` and five `validate-*-coverage` scripts without introducing any new wrapper script, and propagates their result to SYS-003.

* **System Scenario: STS-004-A1**
  * **Given** a feature directory whose V-Model artifacts produce 100% coverage on every matrix
  * **When** SYS-003 calls `evaluate_gate(feature_dir)` on SYS-004
  * **Then** SYS-004 invokes `build-matrix.sh`, `validate-requirement-coverage.sh`, `validate-system-coverage.sh`, `validate-architecture-coverage.sh`, `validate-integration-coverage.sh`, and `validate-module-coverage.sh` (each as a subprocess), and returns `{passed: true, gap_report: ""}`

* **System Scenario: STS-004-A2**
  * **Given** the project source tree under audit
  * **When** the auditor inspects the bridge-command implementation
  * **Then** no script under `scripts/bash/` or `scripts/powershell/` named `*gate*` or `*pre-implement*` exists, confirming REQ-CN-002 (no new wrapper script)

#### Test Case: STP-004-B (Gate fails closed across the full equivalence partition of incomplete matrix states)

**Technique**: Equivalence Partitioning
**Target View**: Data Design View (matrix completeness states: A/B/C/D/H)
**Description**: Tests one representative from each gate-state class — single-matrix gap, multi-matrix gap, all-matrices-incomplete — to verify the fail-closed property holds uniformly.

* **System Scenario: STS-004-B1**
  * **Given** Matrix A is 100% complete but Matrix B is missing coverage for SYS-005, SYS-006, and SYS-007
  * **When** `evaluate_gate(feature_dir)` is invoked
  * **Then** SYS-004 returns `{passed: false, gap_report: "Matrix B incomplete: SYS-005, SYS-006, SYS-007 lack STP coverage"}`

* **System Scenario: STS-004-B2**
  * **Given** Matrix A and Matrix B are 100% complete but Matrices C, D, and H are absent (no architecture/module/hazard artifacts present)
  * **When** `evaluate_gate(feature_dir)` is invoked
  * **Then** SYS-004 returns `{passed: false}` and the gap report names every missing matrix

* **System Scenario: STS-004-B3**
  * **Given** every matrix is incomplete
  * **When** `evaluate_gate(feature_dir)` is invoked
  * **Then** SYS-004 returns `{passed: false}` (fail-closed) — never `{passed: true}` under any incomplete-matrix condition (REQ-NF-004)

---

### Component Verification: SYS-005 (Additive-Enrichment Encoder)

**Parent Requirements**: REQ-007, REQ-012, REQ-NF-003, REQ-IF-001, REQ-IF-002

#### Test Case: STP-005-A (Enriched outputs parse without warning by unmodified spec-kit-core)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Internal — `embed_enrichment`, `embed_traceability_comments`)
**Description**: Verifies that every output enriched by SYS-005 is consumable by an unmodified spec-kit-core release pinned at v0.7.0 with zero error, warning, or unrecognised-token diagnostic.

* **System Scenario: STS-005-A1**
  * **Given** a canonical `plan.md` produced by SYS-001 and enriched by SYS-005 with HTML-comment traceability metadata for each section
  * **When** the unmodified spec-kit-core `speckit.tasks` command (pinned at v0.7.0) is invoked against the enriched `plan.md`
  * **Then** `speckit.tasks` exits 0 and emits no diagnostic message containing the strings "warning", "error", or "unrecognised"

* **System Scenario: STS-005-A2**
  * **Given** a canonical `tasks.md` produced by SYS-002 with `<!-- traces-to: MOD-001 → ARCH-001 → SYS-001 → REQ-001 -->` comments per task
  * **When** the unmodified spec-kit-core `speckit.implement` command (pinned at v0.7.0) is invoked against the enriched `tasks.md`
  * **Then** `speckit.implement` parses the file successfully and exits 0 from the parse phase

#### Test Case: STP-005-B (Enrichment payload size boundaries do not break the canonical schema)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View (V-Model enrichment metadata entity)
**Description**: Tests payload boundaries — empty metadata, single trace per artifact, and a high-volume metadata set — to verify schema integrity is preserved.

* **System Scenario: STS-005-B1**
  * **Given** SYS-005 is invoked with an empty V-Model metadata object on a canonical `plan.md`
  * **When** `embed_enrichment(plan_doc, {})` returns
  * **Then** the returned document is byte-identical to the input `plan.md`

* **System Scenario: STS-005-B2**
  * **Given** SYS-005 is invoked with a metadata object containing 500 trace entries on a canonical `tasks.md`
  * **When** `embed_traceability_comments(tasks_doc, traces_500)` returns
  * **Then** the returned document still validates against `tasks-template.md` schema and contains exactly 500 `<!-- traces-to: ... -->` comments

---

### Component Verification: SYS-006 (Hallucination Guard)

**Parent Requirements**: REQ-023, REQ-NF-002

#### Test Case: STP-006-A (Verify-IDs contract returns valid/invalid result correctly)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Internal — `verify_ids`)
**Description**: Verifies the contract surface of the Hallucination Guard.

* **System Scenario: STS-006-A1**
  * **Given** a generated source file containing `# Implements MOD-001 (traces to REQ-001)` and a V-Model ID set containing `{MOD-001, REQ-001}`
  * **When** `verify_ids(generated_files, vmodel_id_set)` is invoked
  * **Then** the function returns `{valid: true, hallucinations: []}`

* **System Scenario: STS-006-A2**
  * **Given** a generated source file containing `# Implements MOD-999` and a V-Model ID set that does not contain `MOD-999`
  * **When** `verify_ids(...)` is invoked
  * **Then** the function returns `{valid: false, hallucinations: [{file: ..., line: ..., id: "MOD-999"}]}`

#### Test Case: STP-006-B (Hallucination Guard fails closed on any non-empty hallucination set)

**Technique**: Equivalence Partitioning
**Target View**: Data Design View (generated `// Implements <ID>` comment set)
**Description**: Tests three equivalence classes — all-valid, mixed, all-hallucinated — to verify the guard fails closed in the latter two.

* **System Scenario: STS-006-B1**
  * **Given** SYS-003 has generated 20 source files all containing only valid `// Implements <ID>` comments
  * **When** SYS-003 invokes the pre-commit verification step
  * **Then** SYS-006 returns `{valid: true}` and SYS-003 proceeds to commit

* **System Scenario: STS-006-B2**
  * **Given** SYS-003 has generated 20 source files of which 1 contains a hallucinated `// Implements MOD-999`
  * **When** SYS-003 invokes the pre-commit verification step
  * **Then** SYS-006 returns `{valid: false}`, SYS-003 exits non-zero, and no commit is produced

* **System Scenario: STS-006-B3**
  * **Given** SYS-003 has generated 20 source files all containing only hallucinated identifiers
  * **When** SYS-003 invokes the pre-commit verification step
  * **Then** SYS-006 returns `{valid: false, hallucinations: [...]}` enumerating all 20 hallucinations and SYS-003 exits non-zero

---

### Component Verification: SYS-007 (Source Region Manager)

**Parent Requirements**: REQ-022

#### Test Case: STP-007-A (User content between V-Model-managed regions is preserved across re-runs)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View (generated source file with N V-Model-managed regions)
**Description**: Exercises N=0, N=1, and N=many region boundaries to verify content outside V-Model regions is preserved.

* **System Scenario: STS-007-A1**
  * **Given** an existing target source file containing zero V-Model-managed region markers and 50 lines of user-authored content
  * **When** SYS-007 splices generated content into the file
  * **Then** the resulting file contains the 50 original user lines unchanged plus the newly-added V-Model-managed region (REQ-022)

* **System Scenario: STS-007-A2**
  * **Given** an existing target source file containing one V-Model-managed region surrounded by 30 lines of user-authored content above and 30 lines below
  * **When** SYS-007 re-runs the splice with newly-generated content for the same region
  * **Then** the V-Model-managed region content is replaced verbatim with the new generated content and the 60 lines of user content are preserved byte-identically

* **System Scenario: STS-007-A3**
  * **Given** an existing target source file containing three V-Model-managed regions separated by user content
  * **When** SYS-007 re-runs the splice with new content for all three regions
  * **Then** each V-Model-managed region is updated independently and all user content between them is preserved byte-identically

#### Test Case: STP-007-B (Overlapping region markers abort the run with a diff report)

**Technique**: Fault Injection
**Target View**: Dependency View (SYS-003 → SYS-007 conflict propagation)
**Description**: Verifies the conflict-detection path aborts cleanly without mutating the file.

* **System Scenario: STS-007-B1**
  * **Given** an existing target source file in which two V-Model-managed region markers overlap (the second region opens before the first closes)
  * **When** SYS-007 is invoked to splice new content
  * **Then** SYS-007 returns a conflict result, the file on disk remains byte-identical to its pre-call state, and a diff report describing the overlap is written to stdout

* **System Scenario: STS-007-B2**
  * **Given** an existing target source file in which a single V-Model-managed region marker is corrupted — the begin marker (e.g., `// region-v-model-begin: MOD-007`) is present but the matching end marker (e.g., `// region-v-model-end: MOD-007`) is missing or malformed (truncated suffix, mismatched MOD-id, or one of the two delimiter sigils altered) — and the user has authored content **between** the marker and the next plausible end-of-region anchor
  * **When** SYS-003 invokes SYS-007 to re-splice generated content for that MOD
  * **Then** SYS-007 detects the marker corruption, aborts before any write, returns a `RegionConflict` (or equivalent fault result) that names the corrupted marker and its line number, the file on disk remains byte-identical to its pre-call state (no truncation, no overwrite of user-authored content between the corrupted markers), and the structured stdout summary attributes the failure to region-marker corruption (NOT to a generic write failure). Mitigates HAZ-014 (Critical: user-authored region overwritten on re-run because corrupted markers cause SYS-007 to misidentify the managed-region boundary). Pre-loaded by `impact-analysis/critical-hazard-verification-profile.md`; raised by peer-review finding PRF-STP-001.

---

### Component Verification: SYS-008 (Domain Overlay Adapter)

**Parent Requirements**: REQ-024

#### Test Case: STP-008-A (Adapter applies the configured overlay or proceeds without one)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Internal — `apply_overlay`)
**Description**: Verifies the contract: configuration absent → identity transform; configuration present → overlay-augmented generation plan.

* **System Scenario: STS-008-A1**
  * **Given** `v-model-config.yml` is absent at the repository root
  * **When** SYS-003 calls `apply_overlay(plan, None)` on SYS-008
  * **Then** SYS-008 returns the input plan unchanged (identity transform)

* **System Scenario: STS-008-A2**
  * **Given** `v-model-config.yml` declares `domain: do_178c, level: A`
  * **When** SYS-003 calls `apply_overlay(plan, parsed_config)`
  * **Then** the returned plan contains an MC/DC-coverage obligation entry for every module declared in the input plan

#### Test Case: STP-008-B (Malformed configuration fails closed without partial application)

**Technique**: Fault Injection
**Target View**: Dependency View (SYS-003 → SYS-008)
**Description**: Verifies that an unreadable or invalid configuration causes SYS-003 to abort.

* **System Scenario: STS-008-B1**
  * **Given** `v-model-config.yml` exists but contains malformed YAML (e.g., a tab character in indentation)
  * **When** SYS-003 invokes SYS-008 during initialization
  * **Then** SYS-008 raises a parse error, SYS-003 exits non-zero before any code is generated, and no source files or commits are produced

---

### Component Verification: SYS-009 (Hazard-Driven Task Emitter)

**Parent Requirements**: REQ-014

#### Test Case: STP-009-A (Hazards are propagated as raised priority and dedicated verification tasks)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Internal — `enrich_with_hazards`)
**Description**: Verifies the hazard-enrichment contract.

* **System Scenario: STS-009-A1**
  * **Given** a parsed `hazard-analysis.md` declaring HAZ-001 with mitigation linked to MOD-003 and HAZ-002 with mitigation linked to MOD-004
  * **When** SYS-002 calls `enrich_with_hazards(tasks, hazard_analysis)` on SYS-009 with a task list that includes implementation tasks for MOD-003 and MOD-004
  * **Then** the returned task list contains a verification task referencing `HAZ-001` and a verification task referencing `HAZ-002`, and the implementation tasks for MOD-003 and MOD-004 carry an elevated priority marker (REQ-014)

---

### Component Verification: SYS-010 (Spec-Kit Core Compatibility Layer)

**Parent Requirements**: REQ-028, REQ-029, REQ-IF-001, REQ-IF-002, REQ-CN-001

#### Test Case: STP-010-A (Schema validators enforce strict canonical conformance)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Internal — `validate_plan_schema`, `validate_tasks_schema`)
**Description**: Verifies the schema validators reject any deviation from the canonical schemas pinned at spec-kit-core v0.7.0 release time.

* **System Scenario: STS-010-A1**
  * **Given** a `plan.md` with all spec-kit-core-canonical sections present and in the prescribed order
  * **When** `validate_plan_schema(plan_doc)` is invoked
  * **Then** the function returns `{valid: true, errors: []}`

* **System Scenario: STS-010-A2**
  * **Given** a `tasks.md` missing the required "Tasks" section header
  * **When** `validate_tasks_schema(tasks_doc)` is invoked
  * **Then** the function returns `{valid: false, errors: [...]}` with at least one error explicitly naming the missing "Tasks" section

* **System Scenario: STS-010-A3**
  * **Given** the project source tree under audit
  * **When** the auditor inspects the bridge-command implementation
  * **Then** no source code under SYS-010 modifies any file under the upstream spec-kit-core repository (REQ-CN-001)

#### Test Case: STP-010-B (Round-trip property holds across the full pair set)

**Technique**: Equivalence Partitioning
**Target View**: Data Design View (canonical plan.md / tasks.md entity classes)
**Description**: Tests both round-trip directions across a representative fixture matrix.

* **System Scenario: STS-010-B1**
  * **Given** a `plan.md` produced by `/speckit.v-model.plan` from each of the project's golden test fixtures
  * **When** unmodified `speckit.tasks` (pinned at v0.7.0) is invoked against each `plan.md`
  * **Then** `speckit.tasks` exits 0 and emits a parseable `tasks.md` for 100% of fixtures

* **System Scenario: STS-010-B2**
  * **Given** a `tasks.md` produced by `/speckit.v-model.tasks` from each of the project's golden test fixtures
  * **When** unmodified `speckit.implement` (pinned at v0.7.0) is invoked against each `tasks.md`
  * **Then** `speckit.implement` parses the file and exits 0 from the parse phase for 100% of fixtures

#### Test Case: STP-010-C (Reduced-enrichment fallback enables Hybrid path)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View (V-Model enrichment metadata presence boundary)
**Description**: Exercises the absence boundary on V-Model enrichment in upstream artifacts.

* **System Scenario: STS-010-C1**
  * **Given** a `plan.md` produced by `/speckit.plan` (zero V-Model enrichment metadata)
  * **When** `/speckit.v-model.tasks` is invoked against the feature
  * **Then** the command exits 0, emits a `tasks.md` whose tasks carry traceability comments populated from the V-Model artifacts (not the plan), and the structured summary lists "Reduced enrichment: input plan.md lacked V-Model metadata" as an informational entry

---

### Component Verification: SYS-011 (Hook Registrar)

**Parent Requirements**: REQ-IF-003, REQ-NF-006

#### Test Case: STP-011-A (Hook entries are registered without modifying the existing hook infrastructure)

**Technique**: Interface Contract Testing
**Target View**: Interface View (External — `.specify/extensions.yml`)
**Description**: Verifies that hook registrations are correct and that the hook infrastructure itself is untouched.

* **System Scenario: STS-011-A1**
  * **Given** a clean repository with the existing hook infrastructure in place at `.specify/extensions.yml`
  * **When** SYS-011 runs as part of feature installation
  * **Then** `.specify/extensions.yml` contains entries registering `before_implement` and `after_implement` to invoke `v-model.trace`, and `after_specify` to invoke `v-model.requirements`

* **System Scenario: STS-011-A2**
  * **Given** the project source tree under audit
  * **When** the auditor compares the hook-infrastructure source files against the v0.6.0 baseline
  * **Then** no file implementing the hook infrastructure (as opposed to hook registrations themselves) has been modified by this feature (REQ-NF-006)

---

### Component Verification: SYS-012 (Structured Summary Reporter)

**Parent Requirements**: REQ-027, REQ-IF-004

#### Test Case: STP-012-A (Summary is parseable by the existing v-model.test-results / audit-report tooling)

**Technique**: Interface Contract Testing
**Target View**: Interface View (External — stdout summary stream)
**Description**: Verifies the summary follows the established conventions and can be consumed by existing parsing tooling.

* **System Scenario: STS-012-A1**
  * **Given** SYS-001 has just completed a run that read 8 inputs, produced 5 outputs, skipped 2 optional artifacts, and encountered 1 warning
  * **When** SYS-012 emits the structured summary to stdout
  * **Then** the existing `v-model.test-results` summary parser (with no modifications) consumes the stdout stream and reports `inputs_read=8, outputs_produced=5, artifacts_skipped=2, warnings=1`

* **System Scenario: STS-012-A2**
  * **Given** SYS-003 has just completed a failed run (gate failure) with 0 outputs produced and 1 fatal error
  * **When** SYS-012 emits the structured summary to stdout
  * **Then** the existing `v-model.audit-report` summary parser consumes the stream and reports `outputs_produced=0, fatal_errors=1`

---

### Component Verification: SYS-013 (Quality & Process Compliance Harness)

**Parent Requirements**: REQ-NF-001, REQ-CN-003, REQ-CN-004

#### Test Case: STP-013-A (Four-stack coverage is computed and merge is blocked below 100%)

**Technique**: Interface Contract Testing
**Target View**: Interface View (External — test-harness invocation)
**Description**: Verifies the harness invokes BATS, Pester, structural eval, and LLM eval and gates merge on 100% coverage.

* **System Scenario: STS-013-A1**
  * **Given** the bridge-commands implementation under test with 100% test coverage across BATS, Pester, structural eval, and LLM eval suites
  * **When** SYS-013 computes the four-stack coverage report
  * **Then** the report indicates `bats=100%, pester=100%, structural_eval=100%, llm_eval=100%` and the merge gate returns "allow"

* **System Scenario: STS-013-A2**
  * **Given** the bridge-commands implementation under test with BATS coverage at 95% (below threshold)
  * **When** SYS-013 computes the four-stack coverage report
  * **Then** the merge gate returns "block" and the report names BATS as the failing harness

#### Test Case: STP-013-B (Scope guardrails reject deferred-capability additions)

**Technique**: Equivalence Partitioning
**Target View**: Data Design View (deferred-capability declaration classes)
**Description**: Tests representative classes of deferred capabilities to verify the guardrails reject all of them.

* **System Scenario: STS-013-B1**
  * **Given** the bridge-commands source tree under audit
  * **When** the auditor scans for new orchestrator/supervisor agent declarations, model-tiering changes, sandbox-execution isolation, correlation-log infrastructure, or workflow-YAML single-command V-cycle orchestrators introduced under v0.7.0
  * **Then** zero such declarations are found (REQ-CN-003)

* **System Scenario: STS-013-B2**
  * **Given** the project Git history at the moment v0.7.0 is tagged
  * **When** the auditor verifies that V-Model artifacts under `specs/007-bridge-commands/v-model/` were committed before any bridge-command implementation code
  * **Then** the commit chronology confirms dogfood discipline (REQ-CN-004): every V-Model artifact commit precedes the first commit modifying executable command source for the bridge commands

---

### Component Verification: SYS-014 (Commit Annotator)

**Parent Requirements**: REQ-021

#### Test Case: STP-014-A (Commit messages carry the comma-separated V-Model identifier suffix)

**Technique**: Interface Contract Testing
**Target View**: Interface View (External — `git commit -m` invocation)
**Description**: Verifies the commit-message annotation contract.

* **System Scenario: STS-014-A1**
  * **Given** SYS-003 has produced a change implementing `MOD-001` and `REQ-001` and is about to commit with the base message `feat(plan): synthesize plan.md`
  * **When** SYS-014 invokes `annotate_commit("feat(plan): synthesize plan.md", ["MOD-001", "REQ-001"])`
  * **Then** the resulting commit message is `feat(plan): synthesize plan.md — MOD-001, REQ-001`

* **System Scenario: STS-014-A2**
  * **Given** SYS-003 has produced a change with no associated V-Model identifiers (defensive case)
  * **When** SYS-014 is invoked with an empty identifier list
  * **Then** SYS-014 returns the base message unchanged and emits a warning to the structured summary; the commit still proceeds

---

## V&V Coverage (IEEE 1012:2016)

Every active `REQ-NNN` is exercised by at least one V&V activity at the system
test layer. Coverage is achieved transitively: each REQ is the parent of one
or more SYS components, and each SYS component is the subject of at least one
STP. Below is the per-REQ-category mapping that confirms IEEE 1012:2016 §5.5.

| REQ Category | Verification Method | V&V Activity at System Test Layer |
|--------------|---------------------|------------------------------------|
| Functional REQs (REQ-001 … REQ-029) | Test (27 of 29) / Inspection (REQ-021) / — | STP coverage on the parent SYS component(s); REQ-021 is exercised by STP-014-A and audited by inspection |
| Non-Functional REQs (REQ-NF-001 … REQ-NF-006) | Analysis (REQ-NF-001) / Test (4) / Inspection (REQ-NF-006) | REQ-NF-001 covered by STP-013-A (analysis activity codified as test); REQ-NF-002 by STP-006-A/B; REQ-NF-003 by STP-005-A; REQ-NF-004 by STP-004-B; REQ-NF-005 by STP-001-B; REQ-NF-006 by STP-011-A and audit |
| Interface REQs (REQ-IF-001 … REQ-IF-004) | Test (3) / Inspection (REQ-IF-004) | REQ-IF-001 by STP-001-A + STP-005-A; REQ-IF-002 by STP-002-A + STP-005-A; REQ-IF-003 by STP-011-A; REQ-IF-004 by STP-012-A |
| Constraint REQs (REQ-CN-001 … REQ-CN-004) | Inspection (all 4) | REQ-CN-001 by STP-010-A (audit step STS-010-A3); REQ-CN-002 by STP-004-A (audit step STS-004-A2); REQ-CN-003 by STP-013-B; REQ-CN-004 by STP-013-B |

**V&V gap list**: empty. No `[V&V GAP]` flags raised.

**Entry-criteria check (IEEE 1012:2016 §5.5.1):**
- ✅ `system-design.md` is current (committed at f07c241)
- ✅ Every `SYS-NNN` has at least one `STP-NNN-X` (14/14 = 100% forward coverage)
- ✅ Every `STP-NNN-X` has at least one `STS-NNN-X#`
- ✅ V&V gap list is empty

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total System Components (SYS) | 14 (14 active, 0 deprecated) |
| Total Test Cases (STP) | 28 |
| Total Scenarios (STS) | 59 |
| Components with ≥1 STP | 14 / 14 (100%) (active items only) |
| Test Cases with ≥1 STS | 28 / 28 (100%) |
| **Overall Coverage (SYS→STP)** | **100%** |

**Technique distribution:**
- Interface Contract Testing: 13 STPs (STP-001-A, 002-A, 003-A, 004-A, 005-A, 006-A, 008-A, 009-A, 010-A, 011-A, 012-A, 013-A, 014-A)
- Boundary Value Analysis: 4 STPs (STP-001-B, 005-B, 007-A, 010-C)
- Equivalence Partitioning: 6 STPs (STP-002-B, 003-B, 004-B, 006-B, 010-B, 013-B)
- Fault Injection: 5 STPs (STP-001-C, 002-C, 003-C, 007-B, 008-B)

**Language compliance:** Zero user-journey phrases ("user clicks", "user sees", "user navigates", "user enters", "user selects", "user receives", "dashboard shows", "form displays") appear in any STS scenario in this document. All scenarios use component-, API-, and data-oriented language.

## Uncovered Components

None — full coverage achieved.
