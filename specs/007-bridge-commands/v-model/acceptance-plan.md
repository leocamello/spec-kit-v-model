# Acceptance Test Plan: Bridge Commands

**Feature Branch**: `feature/007-bridge-commands`
**Created**: 2026-04-26
**Status**: Draft
**Source**: `specs/007-bridge-commands/v-model/requirements.md`

## Overview

This document defines the Acceptance Test Plan for the three bridge commands (`v-model.plan`, `v-model.tasks`, `v-model.implement`) and their cross-cutting requirements. Every requirement in `requirements.md` (43 active REQs across Functional, Non-Functional, Interface, and Constraint categories) has at least one Test Case (ATP), and every Test Case has at least one BDD-style executable User Scenario (SCN).

## ID Schema

- **Test Case**: `ATP-{NNN}-{X}` — where NNN matches the parent REQ, X is a letter suffix (A, B, C…)
- **Non-Functional / Interface / Constraint test cases**: `ATP-NF-{NNN}-{X}`, `ATP-IF-{NNN}-{X}`, `ATP-CN-{NNN}-{X}`
- **Scenario**: `SCN-{NNN}-{X}{#}` — nested under the parent ATP, with numeric suffix (1, 2, 3…)
- Example: `SCN-001-A1` → Scenario 1 of Test Case A validating REQ-001

## Acceptance Tests

### Functional Requirements — `v-model.plan`

#### Requirement Validation: REQ-001 (Read all V-Model artifacts)

##### Test Case: ATP-001-A (Happy path — full artifact set)
**Description:** Verify that `v-model.plan` opens and reads every V-Model artifact present in the feature directory plus the project constitution.
**Validation Condition:** The structured stdout summary lists every expected artifact under "inputs read".
**Expected Result:** All 10 V-Model artifacts and the constitution appear in the inputs-read list; exit code is 0.

* **User Scenario: SCN-001-A1**
  * **Given** a feature directory containing all 10 V-Model artifacts and a project constitution at the repository root
  * **When** `/speckit.v-model.plan` is invoked against that feature
  * **Then** the structured stdout summary contains an `inputs_read` array enumerating exactly those 11 file paths

##### Test Case: ATP-001-B (Subset — only required artifacts present)
**Description:** Verify that artifacts present are read even when optional ones are absent.
**Validation Condition:** Every present artifact appears in `inputs_read`; absent artifacts are not invented.
**Expected Result:** `inputs_read` reflects the actual filesystem state; no phantom paths.

* **User Scenario: SCN-001-B1**
  * **Given** a feature directory containing only `requirements.md`, `acceptance-plan.md`, `system-design.md`, `architecture-design.md`, `module-design.md`, and `traceability-matrix.md` (no test plans, no hazard analysis)
  * **When** `/speckit.v-model.plan` is invoked
  * **Then** the structured stdout summary lists exactly those 6 files under `inputs_read` and lists `system-test.md`, `integration-test.md`, `unit-test.md`, `hazard-analysis.md` under `optional_artifacts_skipped`

#### Requirement Validation: REQ-002 (Produce spec-kit-conformant `plan.md`)

##### Test Case: ATP-002-A (Schema conformance against canonical template)
**Description:** Verify that the emitted `plan.md` contains every required section of spec-kit core's `plan-template.md` in the prescribed order.
**Validation Condition:** A schema-checker pass over the output reports zero missing required sections.
**Expected Result:** Schema-checker exits 0; round-trip test feeding the output into unmodified `speckit.tasks` succeeds.

* **User Scenario: SCN-002-A1**
  * **Given** a fixture feature with a complete V-Model artifact set
  * **When** `/speckit.v-model.plan` runs and the resulting `plan.md` is then passed to unmodified `speckit.tasks`
  * **Then** `speckit.tasks` exits with code 0 and produces a non-empty `tasks.md`

##### Test Case: ATP-002-B (Section ordering preserved)
**Description:** Verify ordering matches the canonical template, not just presence.
**Validation Condition:** The structural-eval ordering check reports zero out-of-order sections.
**Expected Result:** Ordering check passes.

* **User Scenario: SCN-002-B1**
  * **Given** the `plan.md` produced by SCN-002-A1
  * **When** the structural-eval ordering check runs against `templates/overlays/.../plan-template.md` headings
  * **Then** the ordering report shows zero out-of-order or missing required sections

#### Requirement Validation: REQ-003 (Emit `data-model.md` from system-design Data View)

##### Test Case: ATP-003-A (Data model extracted faithfully)
**Description:** Verify the emitted `data-model.md` contains the entities defined in the system-design Data View.
**Validation Condition:** Every entity heading present in the source's Data View appears in the output `data-model.md`.
**Expected Result:** 100% entity match; no invented entities.

* **User Scenario: SCN-003-A1**
  * **Given** a fixture `system-design.md` whose Data Design view declares exactly entities `Order`, `LineItem`, `Customer`
  * **When** `/speckit.v-model.plan` runs against the fixture feature
  * **Then** the emitted `data-model.md` contains exactly entity sections for `Order`, `LineItem`, `Customer` and no other entities

#### Requirement Validation: REQ-004 (Emit `contracts/` from architecture Interface View)

##### Test Case: ATP-004-A (Contracts directory populated from interfaces)
**Description:** Verify each interface in the architecture-design Interface View becomes a file under `contracts/`.
**Validation Condition:** File count under `contracts/` equals the interface count in the source.
**Expected Result:** One contract file per interface; file names match the interface names.

* **User Scenario: SCN-004-A1**
  * **Given** a fixture `architecture-design.md` declaring exactly 3 interfaces named `OrderAPI`, `PaymentGateway`, `NotificationBus`
  * **When** `/speckit.v-model.plan` runs
  * **Then** `specs/<feature>/contracts/` contains exactly 3 files: `OrderAPI.md`, `PaymentGateway.md`, `NotificationBus.md`

#### Requirement Validation: REQ-005 (Emit `quickstart.md` from acceptance BDD scenarios)

##### Test Case: ATP-005-A (Top critical paths included)
**Description:** Verify the quickstart contains the highest-priority acceptance scenarios.
**Validation Condition:** Every P1 SCN from `acceptance-plan.md` (capped at the top 5 most critical) is present in the quickstart.
**Expected Result:** Quickstart contains the expected SCN IDs; lower-priority SCNs are not included.

* **User Scenario: SCN-005-A1**
  * **Given** a fixture `acceptance-plan.md` with 8 P1 SCNs and 4 P2 SCNs marked with priority annotations
  * **When** `/speckit.v-model.plan` runs
  * **Then** the emitted `quickstart.md` contains the top 5 P1 SCN IDs as worked examples and contains zero P2 SCN IDs

#### Requirement Validation: REQ-006 (Emit `research.md` capturing derivation flags)

##### Test Case: ATP-006-A (Derivation flags surfaced)
**Description:** Verify that any `[DERIVED REQUIREMENT]` or `[DERIVED MODULE]` flag in the source artifacts appears in the emitted `research.md` linked to its origin.
**Validation Condition:** Each flag in the source produces exactly one entry in `research.md` with a backlink to the source artifact.
**Expected Result:** Flag-to-entry mapping is 1:1; no flags lost; no entries invented.

* **User Scenario: SCN-006-A1**
  * **Given** a fixture in which `module-design.md` contains 2 `[DERIVED MODULE]` flags and `architecture-design.md` contains 1 `[DERIVED REQUIREMENT]` flag
  * **When** `/speckit.v-model.plan` runs
  * **Then** the emitted `research.md` contains exactly 3 derivation entries, each with a Markdown link back to the artifact and section that introduced the flag

#### Requirement Validation: REQ-007 (Additive enrichment ignored by spec-kit core)

##### Test Case: ATP-007-A (HTML comments do not break core parser)
**Description:** Verify that V-Model traceability metadata embedded as HTML comments does not produce parse errors or warnings in unmodified spec-kit core.
**Validation Condition:** Running unmodified `speckit.tasks` against the enriched `plan.md` produces no warnings on stderr.
**Expected Result:** stderr from `speckit.tasks` is empty; exit code 0.

* **User Scenario: SCN-007-A1**
  * **Given** a `plan.md` produced by `v-model.plan` containing at least one `<!-- v-model: traces-to REQ-001 -->` HTML comment per major section
  * **When** unmodified `speckit.tasks` runs against that `plan.md`
  * **Then** stderr from `speckit.tasks` is empty and the command exits with code 0

##### Test Case: ATP-007-B (Optional V-Model sections ignored by core)
**Description:** Verify that an optional `## V-Model Traceability` section in the output does not interfere with `speckit.tasks`.
**Validation Condition:** `speckit.tasks` succeeds and the resulting `tasks.md` contains no references to the optional section.
**Expected Result:** Tasks output is identical to a tasks output produced from the same plan with the optional section removed (modulo non-substantive whitespace).

* **User Scenario: SCN-007-B1**
  * **Given** two copies of an enriched `plan.md`, one with the optional `## V-Model Traceability` section and one without
  * **When** unmodified `speckit.tasks` runs against both copies
  * **Then** the structural-eval comparison of the two emitted `tasks.md` files reports ≥99% structural identity

#### Requirement Validation: REQ-008 (Graceful degradation on missing artifacts)

##### Test Case: ATP-008-A (Missing optional artifacts handled cleanly)
**Description:** Verify that absent artifacts are reported but do not abort the command.
**Validation Condition:** Exit code is 0; the structured summary includes a `warnings` array naming each missing artifact.
**Expected Result:** Command completes; warnings list matches the missing files; corresponding plan sections are omitted.

* **User Scenario: SCN-008-A1**
  * **Given** a feature directory missing `hazard-analysis.md` and `system-test.md`
  * **When** `/speckit.v-model.plan` runs
  * **Then** the command exits 0 and the structured summary's `warnings` array contains exactly two entries naming `hazard-analysis.md` and `system-test.md`

---

### Functional Requirements — `v-model.tasks`

#### Requirement Validation: REQ-009 (Read artifacts and `plan.md` regardless of producer)

##### Test Case: ATP-009-A (Consumes a `v-model.plan`-produced plan)
**Description:** Verify successful operation against an enriched plan.
**Validation Condition:** Inputs-read summary lists `plan.md`; tasks output references V-Model IDs from the plan's enrichment.
**Expected Result:** Exit 0; enriched tasks produced.

* **User Scenario: SCN-009-A1**
  * **Given** a feature whose `plan.md` was produced by `v-model.plan` and contains V-Model traceability comments
  * **When** `/speckit.v-model.tasks` is invoked
  * **Then** the command exits 0 and the inputs-read summary lists `plan.md` alongside the V-Model artifacts

##### Test Case: ATP-009-B (Consumes a `speckit.plan`-produced plan)
**Description:** Verify successful operation against a pure spec-kit-core plan with no enrichment.
**Validation Condition:** Inputs-read summary lists `plan.md`; tasks output is produced; no fatal error on missing enrichment.
**Expected Result:** Exit 0; tasks produced with reduced enrichment as per REQ-028.

* **User Scenario: SCN-009-B1**
  * **Given** a feature whose `plan.md` was produced by unmodified `speckit.plan` and contains zero V-Model HTML comments
  * **When** `/speckit.v-model.tasks` is invoked
  * **Then** the command exits 0 and the structured summary notes "upstream plan is plain spec-kit core" under warnings

#### Requirement Validation: REQ-010 (Produce spec-kit-conformant `tasks.md`)

##### Test Case: ATP-010-A (Schema conformance and round-trip)
**Description:** Verify the output conforms to spec-kit core's `tasks-template.md` and is consumable by `speckit.implement`.
**Validation Condition:** Schema-check passes; `speckit.implement` exit code is 0 against the output.
**Expected Result:** Round-trip succeeds end-to-end.

* **User Scenario: SCN-010-A1**
  * **Given** a `tasks.md` produced by `v-model.tasks` for a feature with complete V-Model artifacts
  * **When** unmodified `speckit.implement` is invoked against that `tasks.md`
  * **Then** `speckit.implement` exits with code 0 and emits at least one source file

#### Requirement Validation: REQ-011 (TDD ordering of emitted tasks)

##### Test Case: ATP-011-A (Order matches the prescribed sequence)
**Description:** Verify the task order is: write unit tests → implement modules → run unit tests → write integration tests → run integration tests → write system tests → run system tests → write acceptance tests.
**Validation Condition:** A structural-eval check inspecting task headings reports the expected sequence with no out-of-order tasks.
**Expected Result:** Sequence-check passes.

* **User Scenario: SCN-011-A1**
  * **Given** a fixture feature with at least one MOD, one ITS, one STS, and one SCN defined
  * **When** `/speckit.v-model.tasks` runs
  * **Then** the structural-eval order check reports each emitted task's stage in the expected sequence: write-unit-tests, implement, run-unit-tests, write-integration-tests, run-integration-tests, write-system-tests, run-system-tests, write-acceptance-tests

#### Requirement Validation: REQ-012 (Embed traceability metadata as HTML comments)

##### Test Case: ATP-012-A (Every task carries a trace-to comment)
**Description:** Verify the trace metadata exists for every task and its IDs are well-formed.
**Validation Condition:** Every task in `tasks.md` is preceded or followed by exactly one `<!-- traces-to: ... -->` comment whose IDs all exist in the source artifacts.
**Expected Result:** 100% task-to-comment match; zero unknown IDs.

* **User Scenario: SCN-012-A1**
  * **Given** a `tasks.md` produced by `v-model.tasks` for a fixture with N tasks
  * **When** the structural-eval traceability check runs over the file
  * **Then** the check reports exactly N traces-to comments, each with at least one MOD-NNN, ARCH-NNN, SYS-NNN, or REQ-NNN identifier present in the upstream V-Model artifacts

#### Requirement Validation: REQ-013 (Mark independent modules with `[P]`)

##### Test Case: ATP-013-A (Independent modules get the parallel marker)
**Description:** Verify that modules with no inter-dependency in the architecture are marked `[P]`.
**Validation Condition:** Tasks corresponding to modules in independent architecture branches carry `[P]`; dependent modules do not.
**Expected Result:** Marker placement matches the architecture-design dependency graph.

* **User Scenario: SCN-013-A1**
  * **Given** a fixture `architecture-design.md` declaring modules MOD-001 and MOD-002 with no edge between them and MOD-003 depending on MOD-001
  * **When** `/speckit.v-model.tasks` runs
  * **Then** the implement-MOD-001 and implement-MOD-002 tasks both carry `[P]` markers and the implement-MOD-003 task does not

#### Requirement Validation: REQ-014 (Hazard-driven prioritisation and verification tasks)

##### Test Case: ATP-014-A (Mitigation tasks flagged higher priority)
**Description:** Verify tasks tied to hazard mitigations are emitted with elevated priority.
**Validation Condition:** Tasks linked to a `HAZ-NNN` carry the higher-priority marker per spec-kit canonical schema.
**Expected Result:** Priority annotation present; HAZ-NNN appears in the trace comment.

* **User Scenario: SCN-014-A1**
  * **Given** a fixture `hazard-analysis.md` containing one Catastrophic-severity HAZ-001 with a mitigation linked to MOD-002
  * **When** `/speckit.v-model.tasks` runs
  * **Then** the task implementing MOD-002 carries the higher-priority marker and its `<!-- traces-to: -->` comment includes `HAZ-001`

##### Test Case: ATP-014-B (Dedicated verification tasks emitted per HAZ)
**Description:** Verify a verification task is emitted for each hazard.
**Validation Condition:** For every `HAZ-NNN` present, exactly one verification task references it.
**Expected Result:** 1:1 mapping HAZ→verification-task.

* **User Scenario: SCN-014-B1**
  * **Given** the same fixture as SCN-014-A1
  * **When** `/speckit.v-model.tasks` runs
  * **Then** `tasks.md` contains exactly one task whose title begins with "Verify mitigation for HAZ-001" and whose trace-to comment includes `HAZ-001`

---

### Functional Requirements — `v-model.implement`

#### Requirement Validation: REQ-015 (Self-sufficient direct path)

##### Test Case: ATP-015-A (Run without `plan.md` or `tasks.md`)
**Description:** Verify the command can produce code from V-Model artifacts alone.
**Validation Condition:** `plan.md` and `tasks.md` absent; command exits 0; source files emitted.
**Expected Result:** At least one source file is created with traceability comments.

* **User Scenario: SCN-015-A1**
  * **Given** a feature directory containing complete V-Model artifacts and a complete traceability matrix, but with no `plan.md` and no `tasks.md`
  * **When** `/speckit.v-model.implement` is invoked
  * **Then** the command exits 0 and at least one source file appears at the path declared by a MOD-NNN Target Source File field

#### Requirement Validation: REQ-016 (Refuse on incomplete matrix; non-zero exit; gap report)

##### Test Case: ATP-016-A (Refusal on Matrix A gap)
**Description:** Verify behavior when one matrix row is missing required IDs.
**Validation Condition:** Exit code non-zero; stdout gap report names Matrix A and the offending row(s).
**Expected Result:** No source files written; precise gap report emitted.

* **User Scenario: SCN-016-A1**
  * **Given** a fixture feature whose Matrix A contains one row with an empty SCN field
  * **When** `/speckit.v-model.implement` is invoked
  * **Then** the command exits with a non-zero code, the stdout gap report names `Matrix A` and the affected REQ ID, and zero source files are created

##### Test Case: ATP-016-B (Refusal on Matrix H gap)
**Description:** Verify behavior when hazard-analysis matrix is incomplete.
**Validation Condition:** Same as 016-A but for Matrix H.
**Expected Result:** Same as 016-A.

* **User Scenario: SCN-016-B1**
  * **Given** a fixture feature with a hazard whose mitigation field in Matrix H is empty
  * **When** `/speckit.v-model.implement` is invoked
  * **Then** the command exits non-zero, the gap report names `Matrix H` and the HAZ-NNN, and zero source files are created

#### Requirement Validation: REQ-017 (Reuse existing deterministic gate scripts)

##### Test Case: ATP-017-A (No new wrapper script invoked)
**Description:** Verify that the gate is composed of the existing scripts and no others.
**Validation Condition:** A process-trace inspection records calls to `build-matrix` and the five `validate-*-coverage` scripts; no other wrapper script is invoked.
**Expected Result:** Process trace matches the expected script set exactly.

* **User Scenario: SCN-017-A1**
  * **Given** an instrumented run of `/speckit.v-model.implement` against a complete fixture
  * **When** the gate phase executes
  * **Then** the recorded process trace contains invocations of exactly `build-matrix`, `validate-requirement-coverage`, `validate-system-coverage`, `validate-architecture-coverage`, `validate-integration-coverage`, and `validate-module-coverage`, and no other wrapper script

#### Requirement Validation: REQ-018 (Honour Target Source File mapping)

##### Test Case: ATP-018-A (Code lands at declared paths)
**Description:** Verify that generated code is written to the file paths declared by MOD-NNN Target Source File fields.
**Validation Condition:** For every MOD-NNN, the declared target file exists after the run and contains a `// Implements MOD-NNN` comment.
**Expected Result:** 100% of MOD-NNN entries map to a real file containing their implements-comment.

* **User Scenario: SCN-018-A1**
  * **Given** a fixture `module-design.md` containing MOD-001 with Target Source File `src/order/processor.py` and MOD-002 with Target Source File `src/order/notifier.py`
  * **When** `/speckit.v-model.implement` runs
  * **Then** `src/order/processor.py` exists containing the comment `# Implements MOD-001` and `src/order/notifier.py` exists containing the comment `# Implements MOD-002`

#### Requirement Validation: REQ-019 (Embedded `// Implements <ID>` comments)

##### Test Case: ATP-019-A (Every public symbol carries an Implements comment)
**Description:** Verify all public functions, classes, or modules carry the trace comment in the language-appropriate syntax.
**Validation Condition:** Structural-eval AST scan reports every public symbol annotated with `Implements`.
**Expected Result:** 100% public-symbol coverage.

* **User Scenario: SCN-019-A1**
  * **Given** a Python source file produced by `v-model.implement` containing 3 public functions and 1 public class
  * **When** the structural-eval AST scan runs over the file
  * **Then** the scan reports exactly 4 `# Implements MOD-NNN (traces to REQ-NNN)` comments, one per public symbol

#### Requirement Validation: REQ-020 (Generate tests at all four levels)

##### Test Case: ATP-020-A (UTS, ITS, STS, SCN all produced)
**Description:** Verify the generator emits tests at every level matching the corresponding plans.
**Validation Condition:** Output contains at least one file per level: `tests/unit/...`, `tests/integration/...`, `tests/system/...`, `tests/acceptance/...`.
**Expected Result:** All four directories non-empty.

* **User Scenario: SCN-020-A1**
  * **Given** a fixture feature whose UTP/UTS, ITP/ITS, STP/STS, ATP/SCN plans each declare at least one test
  * **When** `/speckit.v-model.implement` runs
  * **Then** at least one test file appears under each of `tests/unit/`, `tests/integration/`, `tests/system/`, `tests/acceptance/`

#### Requirement Validation: REQ-021 (Commit messages include V-Model IDs)

##### Test Case: ATP-021-A (Commit subject contains the ID list suffix)
**Description:** Verify commit messages produced by the run end with a comma-separated suffix of V-Model IDs preceded by an em-dash.
**Validation Condition:** Inspecting `git log --format=%s -n N` shows every newly created commit subject matches the regex `.+ — (MOD|REQ|HAZ|SYS|ARCH)-[A-Z0-9-]+(, (MOD|REQ|HAZ|SYS|ARCH)-[A-Z0-9-]+)*$`.
**Expected Result:** All new commit subjects match the regex.

* **User Scenario: SCN-021-A1**
  * **Given** a clean working tree and a complete fixture
  * **When** `/speckit.v-model.implement` runs and produces N commits
  * **Then** every new commit subject ends with the V-Model ID suffix as defined above

#### Requirement Validation: REQ-022 (Preserve hand-written code outside managed regions)

##### Test Case: ATP-022-A (Code outside managed region untouched)
**Description:** Verify hand-written content outside any V-Model edit zone is preserved byte-for-byte across re-runs.
**Validation Condition:** A pre/post diff of the unmanaged region is empty.
**Expected Result:** Diff returns no lines.

* **User Scenario: SCN-022-A1**
  * **Given** an existing source file containing a hand-written helper function outside any `// region: v-model-managed` block
  * **When** `/speckit.v-model.implement` re-runs against an updated V-Model spec
  * **Then** `git diff` of the file shows no changes outside `// region: v-model-managed` blocks

##### Test Case: ATP-022-B (User customisations between managed regions preserved)
**Description:** Verify that custom code interleaved between managed regions survives re-runs.
**Validation Condition:** Lines lying between two managed regions remain identical pre and post run.
**Expected Result:** Diff of inter-region lines is empty.

* **User Scenario: SCN-022-B1**
  * **Given** a source file containing two `// region: v-model-managed` blocks with a hand-written helper between them
  * **When** `/speckit.v-model.implement` re-runs
  * **Then** the inter-region helper function is preserved byte-for-byte

#### Requirement Validation: REQ-023 (Self-verify against hallucinated IDs; no commit on failure)

##### Test Case: ATP-023-A (Hallucinated ID detected; no commit)
**Description:** Verify the pre-commit self-check detects an invented ID and aborts.
**Validation Condition:** When code is artificially mutated to insert `// Implements MOD-999` (an ID that does not exist in the source), the command exits non-zero and `git status` shows no new commit.
**Expected Result:** Non-zero exit; no commit; clear error message naming the offending ID.

* **User Scenario: SCN-023-A1**
  * **Given** a controlled run where the post-generation hook injects `// Implements MOD-999` into a generated file before the self-check runs
  * **When** the self-check stage executes
  * **Then** the command exits non-zero, `git log -1` shows the previous HEAD unchanged, and stderr contains the substring `MOD-999 not found in V-Model artifacts`

#### Requirement Validation: REQ-024 (Honour configured domain overlay)

##### Test Case: ATP-024-A (DO-178C Level A overlay enforces MC/DC tests)
**Description:** Verify that, when `v-model-config.yml` declares DO-178C Level A, generated unit tests target MC/DC coverage as required by the overlay.
**Validation Condition:** Generated unit tests for boolean-decision logic include MC/DC test cases per the overlay's `unit-test.md` instructions.
**Expected Result:** MC/DC test cases present and structurally distinguishable from branch coverage tests.

* **User Scenario: SCN-024-A1**
  * **Given** a feature configured with `domain: do_178c` and `dal: A`, and a MOD-NNN whose body contains a compound boolean condition `(a && b) || c`
  * **When** `/speckit.v-model.implement` runs
  * **Then** the generated unit-test file for that MOD contains at least the MC/DC-required test cases for the three independent conditions

##### Test Case: ATP-024-B (Configured-but-unloadable overlay fails closed without partial application)
**Description:** Verify that when a domain overlay is *configured* (i.e., `v-model-config.yml` exists and declares a `domain:` value) but the overlay cannot be loaded — file unreadable, schema invalid, declared `domain:` value not registered, or required overlay-specific resources missing — `/speckit.v-model.implement` aborts with a non-zero exit code, emits an explicit error identifying the overlay-load failure, and writes no source or test files. Verifies SYS-008 / SYS-003 fail-closed behaviour at the user-acceptance boundary, mitigating HAZ-015 (Critical: configured domain not applied → silent regulatory regression). Pre-loaded by `impact-analysis/critical-hazard-verification-profile.md`; raised by peer-review finding PRF-ATP-001.
**Validation Condition:** Process exits non-zero, stderr/structured-summary names the overlay-load failure category (parse/registration/resource), and the working tree is byte-identical to its pre-invocation state.
**Expected Result:** Non-zero exit, no partial generation, error message attributable to the overlay-load failure, working tree unmodified.

* **User Scenario: SCN-024-B1**
  * **Given** a feature with `v-model-config.yml` present and declaring `domain: do_178c, dal: A`, but the overlay's required schema file (e.g., the MC/DC obligation pack) is absent or syntactically invalid
  * **When** `/speckit.v-model.implement` runs
  * **Then** the process exits non-zero, the structured stdout summary reports `overlay-load-failure` (not `domain: none`), no source or test files are written, and the working tree remains byte-identical to its pre-invocation state
* **User Scenario: SCN-024-B2**
  * **Given** a feature with `v-model-config.yml` present declaring `domain: <unregistered_domain_name>` (a value SYS-008 does not recognise)
  * **When** `/speckit.v-model.implement` runs
  * **Then** the process exits non-zero, the error attributes the failure to the unregistered domain (NOT silently downgrading to base behaviour), and no source or test files are written

#### Requirement Validation: REQ-025 (Idempotency — ≥95% structural identity on re-run)

##### Test Case: ATP-025-A (Re-run produces structurally equivalent output)
**Description:** Verify that running the command twice on identical inputs produces output that the structural-eval comparison rates ≥95% identical.
**Validation Condition:** Structural-eval `compare` command reports score ≥0.95.
**Expected Result:** Score ≥0.95 on first re-run.

* **User Scenario: SCN-025-A1**
  * **Given** a complete fixture and a clean working tree
  * **When** `/speckit.v-model.implement` runs twice in succession against the same inputs
  * **Then** the structural-eval comparison of the two output trees reports a structural identity score ≥0.95

---

### Functional Requirements — Cross-cutting

#### Requirement Validation: REQ-026 (CLI invocation names)

##### Test Case: ATP-026-A (All three names registered)
**Description:** Verify the CLI exposes all three command names.
**Validation Condition:** `speckit --list-commands` output contains each of `speckit.v-model.plan`, `speckit.v-model.tasks`, `speckit.v-model.implement`.
**Expected Result:** All three names appear.

* **User Scenario: SCN-026-A1**
  * **Given** a built spec-kit-v-model installation
  * **When** `speckit --list-commands` is invoked
  * **Then** stdout contains the three lines `speckit.v-model.plan`, `speckit.v-model.tasks`, `speckit.v-model.implement`

#### Requirement Validation: REQ-027 (Structured stdout summary)

##### Test Case: ATP-027-A (Summary contains required fields)
**Description:** Verify the summary lists inputs read, outputs produced, optional artifacts skipped, and warnings.
**Validation Condition:** JSON parse of the summary block returns an object containing keys `inputs_read`, `outputs_produced`, `optional_artifacts_skipped`, `warnings`.
**Expected Result:** All four keys present; values are arrays.

* **User Scenario: SCN-027-A1**
  * **Given** any successful run of any of the three bridge commands
  * **When** the structured summary block is parsed as JSON
  * **Then** the parsed object contains all four required keys with array-typed values

#### Requirement Validation: REQ-028 (Reduced enrichment when upstream lacks V-Model metadata)

##### Test Case: ATP-028-A (Pure spec-kit core upstream → reduced enrichment, no failure)
**Description:** Verify graceful operation when upstream artifacts contain no V-Model HTML comments.
**Validation Condition:** Command exits 0; output contains the spec-kit-core-required content but omits V-Model-specific enrichment that would have been derived from the missing metadata.
**Expected Result:** Exit 0; structured summary `warnings` mentions "reduced enrichment".

* **User Scenario: SCN-028-A1**
  * **Given** a `plan.md` produced by `speckit.plan` (no V-Model enrichment)
  * **When** `/speckit.v-model.tasks` runs against that feature
  * **Then** the command exits 0 and the structured summary `warnings` array contains an entry whose text starts with `reduced enrichment:`

#### Requirement Validation: REQ-029 (Round-trip with unmodified spec-kit core)

##### Test Case: ATP-029-A (`v-model.plan` → `speckit.tasks`)
**Description:** Verify the plan-side round trip.
**Validation Condition:** `speckit.tasks` exits 0 against every plan in the round-trip fixture set.
**Expected Result:** 100% pass rate across fixtures.

* **User Scenario: SCN-029-A1**
  * **Given** a fixture set of N features with `plan.md` produced by `v-model.plan`
  * **When** unmodified `speckit.tasks` runs against each `plan.md`
  * **Then** every invocation exits 0

##### Test Case: ATP-029-B (`v-model.tasks` → `speckit.implement`)
**Description:** Verify the tasks-side round trip.
**Validation Condition:** `speckit.implement` exits 0 against every tasks file in the fixture set.
**Expected Result:** 100% pass rate.

* **User Scenario: SCN-029-B1**
  * **Given** a fixture set of N features with `tasks.md` produced by `v-model.tasks`
  * **When** unmodified `speckit.implement` runs against each `tasks.md`
  * **Then** every invocation exits 0

---

### Non-Functional Requirements

#### Requirement Validation: REQ-NF-001 (Four-stack test coverage at merge time)

##### Test Case: ATP-NF-001-A (BATS, Pester, structural, LLM evals all present and green)
**Description:** Verify the test suite spans all four stacks and CI is green pre-merge.
**Validation Condition:** GitHub Actions check runs for the feature branch include each stack and report success.
**Expected Result:** Four green checks: bats, pester, structural-evals, llm-evals.

* **User Scenario: SCN-NF-001-A1**
  * **Given** the `feature/007-bridge-commands` branch with all bridge-command code merged into the branch
  * **When** the GitHub Actions CI completes for the latest commit
  * **Then** the check-runs list contains `bats`, `pester`, `structural-evals`, and `llm-evals`, all reporting `success`

#### Requirement Validation: REQ-NF-002 (Zero hallucinated IDs)

##### Test Case: ATP-NF-002-A (Structural eval reports zero hallucinated IDs across all fixtures)
**Description:** Verify the ID-validation check passes on every fixture.
**Validation Condition:** Structural-eval ID check reports `hallucinated_ids: 0` across the entire fixture set.
**Expected Result:** Zero across all fixtures.

* **User Scenario: SCN-NF-002-A1**
  * **Given** the fixture set used by `tests/structural-evals/`
  * **When** the ID-validation check runs over the outputs of `v-model.implement` for every fixture
  * **Then** the aggregated report shows `hallucinated_ids: 0`

#### Requirement Validation: REQ-NF-003 (Spec-kit core parses without warnings)

##### Test Case: ATP-NF-003-A (Pinned spec-kit core release ingests bridge outputs cleanly)
**Description:** Verify zero warnings on stderr when pinned core consumes bridge outputs.
**Validation Condition:** stderr from each `speckit.*` invocation in the round-trip set is empty.
**Expected Result:** Empty stderr in 100% of invocations.

* **User Scenario: SCN-NF-003-A1**
  * **Given** the spec-kit core release pinned at v0.7.0 release time, installed at a known path
  * **When** every fixture's bridge outputs are passed through the corresponding `speckit.*` consumer
  * **Then** stderr is empty for every invocation

#### Requirement Validation: REQ-NF-004 (Always refuse on incomplete matrix; produce gap report)

##### Test Case: ATP-NF-004-A (Refusal verified across N gap fixtures)
**Description:** Verify the refusal behaviour holds across a range of incompleteness fixtures (Matrix A, B, C, D, H gaps).
**Validation Condition:** `v-model.implement` exits non-zero and produces a gap report for every fixture.
**Expected Result:** 5 of 5 fixtures fail closed with the expected gap report.

* **User Scenario: SCN-NF-004-A1**
  * **Given** five incompleteness fixtures, one per matrix (A, B, C, D, H)
  * **When** `/speckit.v-model.implement` runs against each fixture
  * **Then** every run exits with a non-zero code and the gap report names the corresponding matrix

#### Requirement Validation: REQ-NF-005 (Graceful completion when optional artifacts missing)

##### Test Case: ATP-NF-005-A (All three commands complete with skipped-artifact summary)
**Description:** Verify that all three commands handle absent optional artifacts uniformly.
**Validation Condition:** Each command exits 0 and lists each missing artifact in its summary.
**Expected Result:** Three commands × one fixture missing two optional artifacts = three runs with matching summaries.

* **User Scenario: SCN-NF-005-A1**
  * **Given** a fixture missing `hazard-analysis.md` and `system-test.md`
  * **When** `/speckit.v-model.plan`, `/speckit.v-model.tasks`, and `/speckit.v-model.implement` are each invoked in turn
  * **Then** each command exits 0 and its `optional_artifacts_skipped` array contains entries for `hazard-analysis.md` and `system-test.md`

#### Requirement Validation: REQ-NF-006 (Hook infrastructure unchanged)

##### Test Case: ATP-NF-006-A (Diff of hook infrastructure code is empty)
**Description:** Verify the feature changes only `extensions.yml` registrations and not the hook engine code.
**Validation Condition:** `git diff main..feature/007-bridge-commands -- <hook-engine-files>` returns no changes.
**Expected Result:** Empty diff for hook engine paths.

* **User Scenario: SCN-NF-006-A1**
  * **Given** the merge candidate of `feature/007-bridge-commands`
  * **When** `git diff main..feature/007-bridge-commands -- '.specify/scripts/**/hooks*'` is executed
  * **Then** the diff is empty

---

### Interface Requirements

#### Requirement Validation: REQ-IF-001 (Exact `plan-template.md` schema conformance)

##### Test Case: ATP-IF-001-A (Section presence and order match canonical)
**Description:** Verify exact conformance to `plan-template.md` at v0.7.0 release time.
**Validation Condition:** Schema-checker pass with the v0.7.0-pinned template returns zero diffs.
**Expected Result:** Zero diffs.

* **User Scenario: SCN-IF-001-A1**
  * **Given** the pinned spec-kit-core `plan-template.md`
  * **When** the schema-checker compares the section list of a `v-model.plan`-emitted `plan.md` to the template's required sections
  * **Then** the report shows zero missing sections and zero out-of-order sections

#### Requirement Validation: REQ-IF-002 (Exact `tasks-template.md` schema conformance, including `[P]`)

##### Test Case: ATP-IF-002-A (Schema and parallel marker convention honoured)
**Description:** Verify schema conformance and that `[P]` is used per the canonical convention.
**Validation Condition:** Schema check passes; `[P]` markers conform to spec-kit core's expected position.
**Expected Result:** Both checks pass.

* **User Scenario: SCN-IF-002-A1**
  * **Given** a `tasks.md` produced by `v-model.tasks`
  * **When** the schema-checker validates against the pinned `tasks-template.md` and the `[P]` placement check runs
  * **Then** both checks report pass

#### Requirement Validation: REQ-IF-003 (Hooks registered for `v-model.implement` and `v-model.requirements`)

##### Test Case: ATP-IF-003-A (`extensions.yml` registers required hooks)
**Description:** Verify the required hook entries exist in `.specify/extensions.yml`.
**Validation Condition:** Parsing `.specify/extensions.yml` reveals: an `after_specify` hook calling `v-model.requirements`; a `before_implement` hook calling `v-model.trace`; an `after_implement` hook calling `v-model.trace`.
**Expected Result:** All three entries present.

* **User Scenario: SCN-IF-003-A1**
  * **Given** the `.specify/extensions.yml` file at HEAD of `feature/007-bridge-commands`
  * **When** the YAML is parsed
  * **Then** the parsed hook table contains entries `after_specify → v-model.requirements`, `before_implement → v-model.trace`, and `after_implement → v-model.trace`

#### Requirement Validation: REQ-IF-004 (Summary format matches existing commands)

##### Test Case: ATP-IF-004-A (Summary parser shared with `test-results` and `audit-report` succeeds)
**Description:** Verify the existing summary parser handles bridge-command outputs.
**Validation Condition:** The parser used by `v-model.test-results` and `v-model.audit-report` returns a populated structured object when given any bridge-command summary.
**Expected Result:** Parser exits 0 and emits non-empty parsed object for each bridge command.

* **User Scenario: SCN-IF-004-A1**
  * **Given** the structured stdout summaries produced by `v-model.plan`, `v-model.tasks`, and `v-model.implement` on a fixture run
  * **When** the existing summary-parsing tool is invoked on each summary
  * **Then** the parser exits 0 and produces a non-empty parsed object for each summary

---

### Constraint Requirements

#### Requirement Validation: REQ-CN-001 (No modifications to spec-kit core)

##### Test Case: ATP-CN-001-A (Pinned spec-kit core unchanged at merge time)
**Description:** Verify the project does not vendor or modify spec-kit core.
**Validation Condition:** No file under any path matching `spec-kit-core/` exists in the repository at the merge candidate; CI bridge-compat tests run against an unmodified pinned core release.
**Expected Result:** No vendored copy; CI bridge-compat tests green.

* **User Scenario: SCN-CN-001-A1**
  * **Given** the repository at the merge candidate of `feature/007-bridge-commands`
  * **When** a recursive search for paths matching `spec-kit-core/` or `vendor/spec-kit/` is executed and the bridge-compat CI job runs
  * **Then** the search returns zero matches and the bridge-compat job reports `success`

#### Requirement Validation: REQ-CN-002 (No new wrapper script duplicating gate logic)

##### Test Case: ATP-CN-002-A (No new wrapper script under `scripts/`)
**Description:** Verify no new wrapper script duplicates the gate.
**Validation Condition:** `git diff main..feature/007-bridge-commands -- scripts/` introduces no file whose role overlaps with the existing gate scripts.
**Expected Result:** Code review and an automated check confirm no duplication.

* **User Scenario: SCN-CN-002-A1**
  * **Given** the merge candidate of `feature/007-bridge-commands`
  * **When** the lint check `no-duplicate-gate-wrapper` runs over `scripts/`
  * **Then** the check reports zero new wrapper scripts that invoke `build-matrix` or `validate-*-coverage` outside of `v-model.implement`

#### Requirement Validation: REQ-CN-003 (No orchestrator/sandbox/model-tier scope creep)

##### Test Case: ATP-CN-003-A (Diff contains none of the deferred capabilities)
**Description:** Verify none of the deferred capabilities appear in the diff.
**Validation Condition:** `git diff main..feature/007-bridge-commands` contains no new files or significant additions matching any of: orchestrator, supervisor, model_tier, padded_room, correlation_log, workflow.yaml, workflow.yml.
**Expected Result:** Lint check passes.

* **User Scenario: SCN-CN-003-A1**
  * **Given** the merge candidate of `feature/007-bridge-commands`
  * **When** the lint check `no-deferred-capabilities` scans the diff for the seven banned terms above
  * **Then** the check reports zero matches

#### Requirement Validation: REQ-CN-004 (Dogfood discipline — V-Model artifacts before code)

##### Test Case: ATP-CN-004-A (V-Model artifacts present before any bridge-command code)
**Description:** Verify the git history shows V-Model artifacts committed before any bridge-command implementation file.
**Validation Condition:** For every file added under `src/.../bridge_*` (or equivalent location), the commit that adds it has an ancestor commit that already added the corresponding V-Model artifact under `specs/007-bridge-commands/v-model/`.
**Expected Result:** Audit script reports no out-of-order pairs.

* **User Scenario: SCN-CN-004-A1**
  * **Given** the full commit history of `feature/007-bridge-commands` at merge time
  * **When** the audit script `assert-vmodel-precedes-code` runs
  * **Then** it reports zero violations and exits 0

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Requirements (REQ) | 43 (43 active, 0 deprecated) |
| Total Test Cases (ATP) | 51 (51 active, 0 deprecated, 0 suspect) |
| Total Scenarios (SCN) | 51 |
| Active Requirements with ≥1 ATP | 43 / 43 (100%) |
| Test Cases with ≥1 SCN | 51 / 51 (100%) |
| **Overall Coverage** | **100%** (active items only) |

**Validation Status**: ✅ Full Coverage (pending deterministic validation by `validate-requirement-coverage.sh`)
**Generated**: 2026-04-26
**Validated by**: `validate-requirement-coverage.sh` (deterministic) — to run post-write

## Uncovered Requirements

None — full coverage achieved.
