# Integration Test Plan: Bridge Commands

**Feature Branch**: `feature/007-bridge-commands`
**Created**: 2026-04-26
**Last Rewritten**: 2026-05-01 (paradigm-drift correction — see `drift-diff-plan.md`)
**Status**: Draft
**Source**: `specs/007-bridge-commands/v-model/architecture-design.md`

## Overview

This document defines the Integration Test Plan for the bridge-commands
feature **in the Markdown+shell paradigm**. The feature delivers three
slash commands (`/speckit.v-model.plan`, `/speckit.v-model.tasks`,
`/speckit.v-model.implement`) implemented as Markdown prompt files with
YAML frontmatter, four supporting shell scripts (`run-v-model-gate.sh`,
`validate-implements-ids.sh`, `splice-managed-regions.sh`,
`validate-core-schema.sh`) with PowerShell mirrors, and three hook
entries in `extension.yml`. There is **no Python implementation** —
every previous ITP that asserted Python-interface contracts has been
either re-targeted at an observable boundary (command stdout/exit
code/output files, or shell-script CLI) or marked DEFERRED for
components dropped in the rework.

Integration tests verify **the observable boundaries between paradigm
participants**:

1. **Command invocation contracts** — fixture feature-dir → run slash
   command → assert output files, stdout summary, exit code. Tested
   end-to-end with **BATS** in `tests/system/bridge-commands/`.
2. **Shell-script CLI contracts** — fixture inputs → `run script.sh
   ARGS` → assert exit code, stdout, side effects. Tested with
   **BATS** in `tests/unit/bridge-commands/`.
3. **Hook-registration integration with spec-kit-core** (MOD-020,
   ARCH-015) — assert `extension.yml` parses against the
   `CommandRegistrar` schema and the three hook entries fire on the
   correct lifecycle events.

LLM prompt-section *content* (headings, required outputs, error
language) is asserted at the unit layer with DeepEval (see
`unit-test.md`). LLM behavioural conformance under realistic
prompt-execution is asserted at the system layer (see `system-test.md`).

The tests target only the four boundaries listed above; in-process
Python interface seams (the previous ARCH-019↔ARCH-001 reader-call,
ARCH-020 subprocess wrapper, ARCH-021 atomic writer) **no longer
exist**. ITPs that targeted those seams are preserved by ID with a
`[DEFERRED — component dropped in paradigm shift]` marker for
traceability.

## ID Schema

- **Integration Test Case**: `ITP-{NNN}-{LETTER}` where `NNN` matches the
  parent ARCH module and `LETTER` is a per-ARCH suffix (`A`, `B`, `C`,
  `D`, ...). Multiple ITPs per ARCH are permitted where a single ARCH
  needs to be exercised by independent technique groupings (e.g.,
  ITP-004-A, ITP-004-B, ITP-004-D for ARCH-004's nominal, fault-injection,
  and idempotency contracts respectively). ARCH-019, ARCH-020, ARCH-021
  are dropped — their ITPs are preserved as DEFERRED with the canonical
  `-A` suffix only.
- **Integration Test Scenario**: `ITS-{NNN}-{LETTER}{#}` — nested under
  the parent ITP, with technique-suffix letter and numeric suffix.
  - **A** = Happy-path / nominal contract
  - **B** = Fault injection / failure path
  - **C** = Data-flow / round-trip
  - **D** = Concurrency / race / re-run idempotency (where relevant)
- IDs are permanent — never renumbered or reassigned.

## ISO 29119-4 Integration Test Techniques (Markdown+shell paradigm)

| Technique | Applied To | What It Tests |
|-----------|-----------|---------------|
| **CLI Contract Testing** | Slash commands & shell scripts | Documented arguments, exit codes, stdout summary, output files |
| **Fixture-Driven Black-Box** | Slash commands | Fixture feature-dir → command run → assert produced artifacts |
| **Fault Injection** | Shell scripts & hook wiring | Malformed inputs, missing fixtures, broken `extension.yml` → expected non-zero exit + stderr text |
| **Idempotent Re-Run** | `splice-managed-regions.sh`, hook registration | Re-invocation produces no spurious diff (REQ-022, REQ-NF-005) |

## Test-Tree Layout (target)

```
tests/
├── system/bridge-commands/        # BATS e2e for slash-command invocations
│   ├── plan.bats                  # ITP-001, ITP-002, ITP-008(plan), ITP-013(plan), ITP-016(plan)
│   ├── tasks.bats                 # ITP-003, ITP-008(tasks), ITP-012, ITP-013(tasks), ITP-014, ITP-016(tasks)
│   └── implement.bats             # ITP-004, ITP-005, ITP-006, ITP-011, ITP-016(implement), ITP-018
├── unit/bridge-commands/          # BATS unit-integration for shell scripts
│   ├── run-v-model-gate.bats      # ITP-007
│   ├── validate-implements-ids.bats   # ITP-009
│   ├── splice-managed-regions.bats    # ITP-010
│   └── validate-core-schema.bats  # ITP-013 (script-level)
└── bats/                          # existing BATS suite — extension.yml hook registration
    └── extension-manifest.bats    # ITP-015
```

The `validate-implements-ids.sh` and `splice-managed-regions.sh` BATS
suites also cover their MOD-level unit cases (see `unit-test.md` UTP-013,
UTP-014); the same `.bats` files act as both unit and unit-integration
tests because the scripts are already small enough that per-flag and
per-mode coverage *is* the integration-coverage matrix.

---

## Integration Tests

### Module Verification: ARCH-001 (Plan Synthesis Orchestrator)

**Parent System Components**: SYS-001

#### Test Case: ITP-001-A (Nominal contract — requirements-only and full-upstream paths produce plan.md)

**Test File**: `tests/system/bridge-commands/plan.bats`
**Technique**: Fixture-Driven Black-Box + CLI Contract Testing
**Requirements traced**: REQ-001, REQ-005, REQ-IF-001, REQ-NF-006

* **Integration Scenario: ITS-001-A1** (happy-path: requirements-only feature dir produces plan.md)
  * **Given** a temp feature directory containing only
    `specs/<feature>/v-model/requirements.md`
  * **When** the test invokes the command via the BATS harness:
    ```bash
    run invoke_command speckit.v-model.plan --feature-dir "$TEST_TEMP_DIR/specs/001-test"
    ```
  * **Then** `[ "$status" -eq 0 ]` and `assert_output --partial "--- v-model run summary ---"`
    and the file `specs/001-test/plan.md` exists and contains the required
    spec-kit-core v0.7.0 sections (`## Technical Context`, `## Constitution
    Check`, `## Phase 0: Outline & Research`, etc.)

* **Integration Scenario: ITS-001-A2** (frontmatter `scripts:` invokes `validate-core-schema.sh --plan`)
  * **Given** the same fixture
  * **When** the command runs
  * **Then** `assert_output --partial "validate-core-schema.sh --plan"` (the
    invocation is logged); the deeper assertion that the produced
    `plan.md` contains every section pinned by the script's heading list
    (HAZ-024 mitigation) is exercised by ITP-013 (ARCH-013) at the
    schema-validator boundary.

#### Test Case: ITP-001-B (Fault injection — missing requirements.md produces fail-closed exit)

**Test File**: `tests/system/bridge-commands/plan.bats`
**Technique**: Fixture-Driven Black-Box + CLI Contract Testing
**Requirements traced**: REQ-001, REQ-005, REQ-IF-001, REQ-NF-006

* **Integration Scenario: ITS-001-B1** (missing requirements.md → fail-closed, no partial outputs)
  * **Given** a temp feature directory with no `requirements.md`
  * **When** the command runs
  * **Then** `assert_failure` and `assert_output --partial "FATAL: requirements.md not found"`
    and `[ ! -f "$TEST_TEMP_DIR/specs/001-test/plan.md" ]` (REQ-022 — no partial writes)

---

### Module Verification: ARCH-002 (Canonical Artifact Emitter)

**Parent System Components**: SYS-001

#### Test Case: ITP-002-A (Selective emission contract — partial and full upstream)

**Test File**: `tests/system/bridge-commands/plan.bats`
**Technique**: Fixture-Driven Black-Box
**Requirements traced**: REQ-005, REQ-022

* **Integration Scenario: ITS-002-A1** (only `plan.md` emitted when only requirements.md is upstream)
  * **Given** a fixture with only `requirements.md`
  * **When** `run invoke_command speckit.v-model.plan ...`
  * **Then** `[ -f "$dir/plan.md" ]` and `[ ! -f "$dir/data-model.md" ]`
    and `[ ! -d "$dir/contracts" ]` (selective emission per nullable upstream)

* **Integration Scenario: ITS-002-A2** (full bundle emitted when full upstream is present)
  * **Given** a fixture with `requirements.md`, `system-design.md`,
    `architecture-design.md`, `module-design.md`
  * **When** the command runs
  * **Then** `[ -f "$dir/plan.md" ]`, `[ -f "$dir/data-model.md" ]`,
    `[ -d "$dir/contracts" ]`, `[ -f "$dir/quickstart.md" ]`,
    `[ -f "$dir/research.md" ]` — all five canonical artifacts produced

#### Test Case: ITP-002-B (Atomic emission — no partial files on early abort)

**Test File**: `tests/system/bridge-commands/plan.bats`
**Technique**: Fixture-Driven Black-Box
**Requirements traced**: REQ-005, REQ-022

* **Integration Scenario: ITS-002-B1** (atomic emission — no half-written files on early abort)
  * **Given** a fixture that triggers `validate-core-schema.sh --plan`
    failure mid-run (missing `## Technical Context`)
  * **When** the command runs and fails
  * **Then** `assert_failure` and no partial `plan.md` exists at
    the target path (mktemp/mv pattern prevents corruption — REQ-022)

---

### Module Verification: ARCH-003 (Tasks Synthesis Orchestrator)

**Parent System Components**: SYS-002

#### Test Case: ITP-003-A (Nominal contract — direct path and TDD ordering invariant)

**Test File**: `tests/system/bridge-commands/tasks.bats`
**Technique**: Fixture-Driven Black-Box + CLI Contract Testing
**Requirements traced**: REQ-002, REQ-005, REQ-IF-002

* **Integration Scenario: ITS-003-A1** (happy-path: V-Model artifacts present, plan.md absent → direct path)
  * **Given** a fixture with `requirements.md`, `system-design.md`,
    `architecture-design.md`, `acceptance.md`, `system-test.md`,
    `integration-test.md`, `module-design.md`, `unit-test.md`
    (no `plan.md`)
  * **When** `run invoke_command speckit.v-model.tasks ...`
  * **Then** `[ "$status" -eq 0 ]` and `[ -f "$dir/tasks.md" ]` and
    `assert_output --partial "tasks emitted"`

* **Integration Scenario: ITS-003-A2** (TDD ordering — every test task precedes its impl task)
  * **Given** the produced `tasks.md` from ITS-003-A1
  * **When** the test scans it with `grep -nE '^- \[ \]'`
  * **Then** for every `(test_task, impl_task)` pair traced to the same
    MOD-NNN, the test_task line number < impl_task line number (REQ-IF-002)

#### Test Case: ITP-003-B (Fault injection — schema validation failure produces non-zero exit)

**Test File**: `tests/system/bridge-commands/tasks.bats`
**Technique**: Fixture-Driven Black-Box + CLI Contract Testing
**Requirements traced**: REQ-002, REQ-005, REQ-IF-002

* **Integration Scenario: ITS-003-B1** (`validate-core-schema.sh --tasks` failure → non-zero exit)
  * **Given** a fixture that produces a `tasks.md` missing the required
    `## Phase 3.x: Implementation` heading
  * **When** the command runs
  * **Then** `assert_failure` and `assert_output --partial "MISSING: ## Phase 3"`

---

### Module Verification: ARCH-004 (Implementation Orchestrator)

**Parent System Components**: SYS-003

#### Test Case: ITP-004-A (Nominal contract — gate passes, code emitted, commit annotated)

**Test File**: `tests/system/bridge-commands/implement.bats`
**Technique**: Fixture-Driven Black-Box + Fault Injection
**Requirements traced**: REQ-003, REQ-007, REQ-021, REQ-022, HAZ-009

* **Integration Scenario: ITS-004-A1** (gate passes → code emitted → commit annotated)
  * **Given** a fixture with full V-Model artifacts and a `tasks.md`
    whose every task traces to a real MOD-NNN
  * **When** `run invoke_command speckit.v-model.implement ...`
  * **Then** `[ "$status" -eq 0 ]`, `assert_output --partial "gate: PASS"`,
    the produced source files exist at the MOD-declared target paths, and
    the latest git commit message matches `assert_output --partial "— MOD-"` suffix

#### Test Case: ITP-004-B (Fault injection — gate failure produces fail-closed exit, no source emitted)

**Test File**: `tests/system/bridge-commands/implement.bats`
**Technique**: Fixture-Driven Black-Box + Fault Injection
**Requirements traced**: REQ-003, REQ-007, REQ-021, REQ-022, HAZ-009

* **Integration Scenario: ITS-004-B1** (gate fails → fail-closed, no source emitted)
  * **Given** a fixture whose `tasks.md` references an undeclared MOD-099 (test-data sentinel — see UTS-013-A2)
  * **When** the command runs
  * **Then** `assert_failure`, `assert_output --partial "gate: FAIL"`,
    `assert_output --partial "MOD-099"` (test-data sentinel — see UTS-013-A2), and **no** files were created
    under `src/` (REQ-022 fail-closed)

#### Test Case: ITP-004-D (Idempotency — re-run on identical fixture produces no diff)

**Test File**: `tests/system/bridge-commands/implement.bats`
**Technique**: Idempotent Re-Run
**Requirements traced**: REQ-003, REQ-007, REQ-021, REQ-022, HAZ-009

* **Integration Scenario: ITS-004-D1** (idempotent re-run on identical fixture produces no diff)
  * **Given** a fixture that has been run once successfully
  * **When** the command runs a second time with no changes
  * **Then** `assert_success` and `git diff --quiet` exits 0 (re-run
    preserves managed regions; REQ-NF-005)

---

### Module Verification: ARCH-005 (Code Generator)

**Parent System Components**: SYS-003

#### Test Case: ITP-005-A (Per-MOD emission and traceability comment contract)

**Test File**: `tests/system/bridge-commands/implement.bats`
**Technique**: Fixture-Driven Black-Box
**Requirements traced**: REQ-003, REQ-021

* **Integration Scenario: ITS-005-A1** (every MOD-NNN gets a source file at its declared target)
  * **Given** a fixture `module-design.md` declaring 3 MODs with target
    paths `src/foo/a.py`, `src/foo/b.py`, `src/foo/c.py`
  * **When** the command runs
  * **Then** all three files exist after the run, and each begins with a
    `# Implements MOD-NNN` traceability comment line (REQ-021)

* **Integration Scenario: ITS-005-A2** (traceability comment present on every generated file)
  * **Given** the result of ITS-005-A1
  * **When** `run bash scripts/bash/validate-implements-ids.sh src/foo/`
  * **Then** `assert_success` and `assert_output --partial "all IDs valid"`

---

### Module Verification: ARCH-006 (Test Generator)

**Parent System Components**: SYS-003

#### Test Case: ITP-006-A (Four-level test emission — one file per declared level)

**Test File**: `tests/system/bridge-commands/implement.bats`
**Technique**: Fixture-Driven Black-Box
**Requirements traced**: REQ-007, REQ-IF-003

* **Integration Scenario: ITS-006-A1** (one test file per declared level present after run)
  * **Given** a fixture with `unit-test.md`, `integration-test.md`,
    `system-test.md`, `acceptance.md`
  * **When** the command runs
  * **Then** test files exist under `tests/unit/`, `tests/integration/`,
    `tests/system/`, `tests/acceptance/` respectively (one per declared
    scenario set)

---

### Module Verification: ARCH-007 (Pre-Implementation Gate)

**Parent System Components**: SYS-004

#### Test Case: ITP-007-A (Nominal contract — all validators pass produces exit 0 + summary)

**Test File**: `tests/unit/bridge-commands/run-v-model-gate.bats`
**Technique**: CLI Contract Testing + Fault Injection
**Requirements traced**: REQ-006, REQ-009, HAZ-009

* **Integration Scenario: ITS-007-A1** (all six validators pass → exit 0 + summary)
  * **Given** the `tests/fixtures/minimal/` v-model artifact set (known to
    satisfy all five `validate-*-coverage.sh` scripts)
  * **When**
    ```bash
    run bash "$SCRIPTS_DIR/run-v-model-gate.sh" "$FIXTURES_DIR/minimal"
    ```
  * **Then** `[ "$status" -eq 0 ]` and `assert_output --partial "gate: PASS"`
    and `assert_output --partial "build-matrix.sh: ok"`

#### Test Case: ITP-007-B (Fault injection — any validator failure or missing argument produces non-zero exit)

**Test File**: `tests/unit/bridge-commands/run-v-model-gate.bats`
**Technique**: CLI Contract Testing + Fault Injection
**Requirements traced**: REQ-006, REQ-009, HAZ-009

* **Integration Scenario: ITS-007-B1** (any validator fails → exit non-zero + named failure)
  * **Given** the `tests/fixtures/gaps/` fixture (known module-coverage gap)
  * **When** `run bash "$SCRIPTS_DIR/run-v-model-gate.sh" "$FIXTURES_DIR/gaps"`
  * **Then** `assert_failure` and `assert_output --partial "validate-module-coverage.sh: FAIL"`
    and `assert_output --partial "gate: FAIL"`

* **Integration Scenario: ITS-007-B2** (missing argument → usage + exit 1)
  * **Given** no argument
  * **When** `run bash "$SCRIPTS_DIR/run-v-model-gate.sh"`
  * **Then** `assert_failure` and `assert_output --partial "Usage:"`

---

### Module Verification: ARCH-008 (Additive Enrichment Encoder)

**Parent System Components**: SYS-005

#### Test Case: ITP-008-A (HTML-comment enrichment block injected and schema-preserved round-trip)

**Test File**: `tests/system/bridge-commands/plan.bats` and `tasks.bats`
**Technique**: Fixture-Driven Black-Box + Idempotent Re-Run
**Requirements traced**: REQ-005, REQ-IF-001, REQ-IF-002

* **Integration Scenario: ITS-008-A1** (HTML-comment enrichment block injected after document title)
  * **Given** the `plan.md` produced by ITP-001-A1
  * **When** the test inspects the file with `grep -nE '<!-- vmodel:traces'`
  * **Then** the HTML comment block exists immediately after the `# `
    document-title line and contains `<!-- traces-to:` lines for every
    MOD/ARCH/SYS/REQ ID referenced

* **Integration Scenario: ITS-008-A2** (enriched output still validates against pinned spec-kit-core schema)
  * **Given** the enriched `plan.md`
  * **When** `run bash "$SCRIPTS_DIR/validate-core-schema.sh" --plan "$dir/plan.md"`
  * **Then** `assert_success` (enrichment is purely additive — HAZ-006 mitigation)

---

### Module Verification: ARCH-009 (Hallucination Guard)

**Parent System Components**: SYS-006

#### Test Case: ITP-009-A (Nominal contract — all referenced IDs resolve produces exit 0)

**Test File**: `tests/unit/bridge-commands/validate-implements-ids.bats`
**Technique**: CLI Contract Testing + Fault Injection
**Requirements traced**: REQ-008, HAZ-012, HAZ-023

* **Integration Scenario: ITS-009-A1** (all referenced IDs resolve in V-Model artifacts → exit 0)
  * **Given** a generated source file containing `# Implements MOD-001`
    and a V-Model fixture where `MOD-001` is declared in `module-design.md`
  * **When**
    ```bash
    run bash "$SCRIPTS_DIR/validate-implements-ids.sh" \
        --vmodel-dir "$FIXTURES_DIR/minimal" "$TEST_TEMP_DIR/src/"
    ```
  * **Then** `[ "$status" -eq 0 ]` and `assert_output --partial "all IDs valid"`

#### Test Case: ITP-009-B (Fault injection — hallucinated or cross-style IDs produce exit non-zero)

**Test File**: `tests/unit/bridge-commands/validate-implements-ids.bats`
**Technique**: CLI Contract Testing + Fault Injection
**Requirements traced**: REQ-008, HAZ-012, HAZ-023

* **Integration Scenario: ITS-009-B1** (hallucinated ID `MOD-999` → exit non-zero + named ID) (test-data sentinel — see UTS-013-A2)
  * **Given** a generated file containing `# Implements MOD-999` (test-data sentinel — see UTS-013-A2)
  * **When** the script runs against the same V-Model fixture
  * **Then** `assert_failure` and `assert_output --partial "HALLUCINATED: MOD-999"` (test-data sentinel — see UTS-013-A2)

* **Integration Scenario: ITS-009-B2** (mixed comment styles — Python `#`, JS `//`, both detected)
  * **Given** two files: `a.py` with `# Implements REQ-001` and `b.js`
    with `// Implements MOD-099` (test-data sentinel — see UTS-013-A2)
  * **When** the script runs
  * **Then** `assert_failure`, `assert_output --partial "HALLUCINATED: MOD-099"` (test-data sentinel — see UTS-013-A2),
    and REQ-001 is reported as valid (regex covers both comment markers)

---

### Module Verification: ARCH-010 (Source Region Splicer)

**Parent System Components**: SYS-007

#### Test Case: ITP-010-A (Nominal splice contract — target-absent wrap and target-present in-place update)

**Test File**: `tests/unit/bridge-commands/splice-managed-regions.bats`
**Technique**: CLI Contract Testing + Idempotent Re-Run + Fault Injection
**Requirements traced**: REQ-013, REQ-NF-005, HAZ-013

* **Integration Scenario: ITS-010-A1** (target file absent → wrap content with markers)
  * **Given** `target=/tmp/$$/foo.py` does not exist (created in
    `$TEST_TEMP_DIR`, not `/tmp` per harness)
  * **When**
    ```bash
    run bash "$SCRIPTS_DIR/splice-managed-regions.sh" \
        "$TEST_TEMP_DIR/foo.py" "print('hello')" python
    ```
  * **Then** `[ "$status" -eq 0 ]` and `cat "$TEST_TEMP_DIR/foo.py"` contains
    `# VMODEL-MANAGED-BEGIN` and `# VMODEL-MANAGED-END` wrapping `print('hello')`

* **Integration Scenario: ITS-010-A2** (target file present with single managed region → splice in place)
  * **Given** an existing file with content
    `outside1\n# VMODEL-MANAGED-BEGIN\nold\n# VMODEL-MANAGED-END\noutside2`
  * **When** the script is invoked with new content `new`
  * **Then** `assert_success` and the file now contains
    `outside1`, the markers, `new`, and `outside2` — `outside1`/`outside2`
    preserved verbatim

#### Test Case: ITP-010-B (Fault injection — unbalanced and overlapping markers produce non-zero exit)

**Test File**: `tests/unit/bridge-commands/splice-managed-regions.bats`
**Technique**: CLI Contract Testing + Idempotent Re-Run + Fault Injection
**Requirements traced**: REQ-013, REQ-NF-005, HAZ-013

* **Integration Scenario: ITS-010-B1** (unbalanced markers → exit non-zero)
  * **Given** a target file containing `# VMODEL-MANAGED-BEGIN` but no
    matching `# VMODEL-MANAGED-END`
  * **When** the script runs
  * **Then** `assert_failure` and `assert_output --partial "unbalanced markers"`

* **Integration Scenario: ITS-010-B2** (overlapping/nested markers → exit non-zero)
  * **Given** a file with two `BEGIN` lines before any `END`
  * **When** the script runs
  * **Then** `assert_failure` and `assert_output --partial "overlapping markers"`

#### Test Case: ITP-010-D (Idempotency — identical re-run produces identical output file)

**Test File**: `tests/unit/bridge-commands/splice-managed-regions.bats`
**Technique**: CLI Contract Testing + Idempotent Re-Run + Fault Injection
**Requirements traced**: REQ-013, REQ-NF-005, HAZ-013

* **Integration Scenario: ITS-010-D1** (idempotent: running twice with same input produces identical file)
  * **Given** the result of ITS-010-A2
  * **When** the script is invoked a second time with the same content
  * **Then** `assert_success` and `diff first second` produces no output

---

### Module Verification: ARCH-011 (Domain Overlay Loader)

**Parent System Components**: SYS-008

#### Test Case: ITP-011-A (Nominal contract — no overlay produces identity transform)

**Test File**: `tests/system/bridge-commands/implement.bats`
**Technique**: Fixture-Driven Black-Box + Fault Injection
**Requirements traced**: REQ-014, HAZ-024

* **Integration Scenario: ITS-011-A1** (no overlay file → identity transform)
  * **Given** a fixture with no `v-model-config.yml` at the repo root
  * **When** the implement command runs
  * **Then** `assert_success` and the produced source uses the default
    generation rules (no domain-specific suffix in summary)

#### Test Case: ITP-011-B (Fault injection — malformed v-model-config.yml produces fail-closed exit)

**Test File**: `tests/system/bridge-commands/implement.bats`
**Technique**: Fixture-Driven Black-Box + Fault Injection
**Requirements traced**: REQ-014, HAZ-024

* **Integration Scenario: ITS-011-B1** (malformed `v-model-config.yml` → fail-closed)
  * **Given** a `v-model-config.yml` containing tab-indented keys
    (per `tests/fixtures/v-model-config/malformed/tab-indent.yml`)
  * **When** the command runs
  * **Then** `assert_failure` and `assert_output --partial "v-model-config.yml: parse error"`

---

### Module Verification: ARCH-012 (Hazard Task Emitter)

**Parent System Components**: SYS-009

#### Test Case: ITP-012-A (HAZ verification tasks emitted when hazard-analysis.md present; absent path silent)

**Test File**: `tests/system/bridge-commands/tasks.bats`
**Technique**: Fixture-Driven Black-Box
**Requirements traced**: REQ-IF-004, HAZ-014

* **Integration Scenario: ITS-012-A1** (hazard-analysis.md present → HAZ verification tasks emitted)
  * **Given** a fixture containing `hazard-analysis.md` with HAZ-001..HAZ-003
  * **When** the tasks command runs
  * **Then** `grep -E 'HAZ-00[123]' "$dir/tasks.md"` matches at least 3 lines
    (one verification task per hazard) and the lines appear above implementation
    tasks for the same MOD

* **Integration Scenario: ITS-012-A2** (hazard-analysis.md absent → no HAZ tasks, no error)
  * **Given** a fixture with no `hazard-analysis.md`
  * **When** the tasks command runs
  * **Then** `assert_success` and `grep -c 'HAZ-' "$dir/tasks.md"` returns 0

---

### Module Verification: ARCH-013 (Schema Validator)

**Parent System Components**: SYS-010

#### Test Case: ITP-013-A (Nominal contract — valid plan.md and tasks.md produce exit 0)

**Test File**: `tests/unit/bridge-commands/validate-core-schema.bats`
**Technique**: CLI Contract Testing + Fault Injection
**Requirements traced**: REQ-015, REQ-NF-001, HAZ-024

* **Integration Scenario: ITS-013-A1** (`--plan` mode, all required sections present → exit 0)
  * **Given** a fixture `plan.md` containing every required section per
    spec-kit-core v0.7.0
  * **When**
    ```bash
    run bash "$SCRIPTS_DIR/validate-core-schema.sh" --plan "$FIXTURES_DIR/plan-valid.md"
    ```
  * **Then** `[ "$status" -eq 0 ]` and `assert_output --partial "schema: ok (spec-kit-core v0.7.0)"`

* **Integration Scenario: ITS-013-A2** (`--tasks` mode, all required sections present → exit 0)
  * **Given** a fixture `tasks.md` containing the spec-kit-core required tasks-schema sections
  * **When** the script runs in `--tasks` mode
  * **Then** `assert_success` and `assert_output --partial "schema: ok"`

* **Integration Scenario: ITS-013-A3** (`--plan` mode applied to the upstream `plan.md` produced by ITP-001 — moved from ITS-001-A2 per peer-review pass-7)
  * **Given** the `plan.md` artifact produced by an end-to-end run of
    `speckit.v-model.plan` (the same fixture used by ITP-001-A1)
  * **When**
    ```bash
    run bash "$SCRIPTS_DIR/validate-core-schema.sh" --plan "$dir/plan.md"
    ```
  * **Then** `[ "$status" -eq 0 ]` and the produced `plan.md` contains
    every section pinned by the script's heading list (HAZ-024
    mitigation)

#### Test Case: ITP-013-B (Fault injection — missing section and unknown mode produce exit non-zero)

**Test File**: `tests/unit/bridge-commands/validate-core-schema.bats`
**Technique**: CLI Contract Testing + Fault Injection
**Requirements traced**: REQ-015, REQ-NF-001, HAZ-024

* **Integration Scenario: ITS-013-B1** (`--plan` mode, missing `## Technical Context` → exit non-zero + named gap)
  * **Given** a `plan.md` lacking the `## Technical Context` heading
  * **When** the script runs in `--plan` mode
  * **Then** `assert_failure` and `assert_output --partial "MISSING: ## Technical Context"`

* **Integration Scenario: ITS-013-B2** (unknown mode flag → usage + exit 1)
  * **Given** the flag `--bogus`
  * **When** the script runs
  * **Then** `assert_failure` and `assert_output --partial "Usage:"`

---

### Module Verification: ARCH-014 (Reduced-Enrichment Fallback)

**Parent System Components**: SYS-002

#### Test Case: ITP-014-A (Hybrid path detection — enriched plan.md vs. direct V-Model fallback)

**Test File**: `tests/system/bridge-commands/tasks.bats`
**Technique**: Fixture-Driven Black-Box
**Requirements traced**: REQ-IF-005, REQ-NF-003

* **Integration Scenario: ITS-014-A1** (`plan.md` present and contains `<!-- vmodel:traces` → use plan as enrichment source)
  * **Given** a fixture with both V-Model artifacts and a previously
    enriched `plan.md`
  * **When** the tasks command runs
  * **Then** `assert_output --partial "enrichment source: plan.md"`

* **Integration Scenario: ITS-014-A2** (`plan.md` absent → fall back to direct V-Model traceability)
  * **Given** a fixture with V-Model artifacts but no `plan.md`
  * **When** the tasks command runs
  * **Then** `assert_output --partial "enrichment source: v-model artifacts"`
    and the produced `tasks.md` still contains `<!-- traces-to: ... -->` comments

---

### Module Verification: ARCH-015 (Hook Registrar)

**Parent System Components**: SYS-011

#### Test Case: ITP-015-A (Schema validation contract — extension.yml parses and contains three required hooks)

**Test File**: `tests/bats/extension-manifest.bats`
**Technique**: CLI Contract Testing + Idempotent Re-Run
**Requirements traced**: REQ-IF-005, REQ-NF-005

* **Integration Scenario: ITS-015-A1** (extension.yml parses against the CommandRegistrar schema)
  * **Given** the repo-root `extension.yml`
  * **When**
    ```bash
    run python3 -c "import yaml; yaml.safe_load(open('extension.yml'))"
    ```
  * **Then** `[ "$status" -eq 0 ]` (deterministic YAML parse — no Python
    module under test, only the manifest file)

* **Integration Scenario: ITS-015-A2** (three required hook entries present in `extension.yml`)
  * **Given** `extension.yml`
  * **When**
    ```bash
    run grep -E '^[[:space:]]+(after_specify|before_implement|after_implement):' extension.yml
    ```
  * **Then** `assert_success` and `[ "$(echo "$output" | wc -l)" -eq 3 ]`

* **Integration Scenario: ITS-015-A3** (each hook entry references a real `commands/*.md` file)
  * **Given** the entries from ITS-015-A2
  * **When** the test extracts the referenced command name and checks
    `commands/<name>.md` exists
  * **Then** all three command files are present (`commands/plan.md`,
    `commands/tasks.md`, `commands/implement.md`)

#### Test Case: ITP-015-D (Idempotency — re-running CommandRegistrar produces identical hook state)

**Test File**: `tests/bats/extension-manifest.bats`
**Technique**: CLI Contract Testing + Idempotent Re-Run
**Requirements traced**: REQ-IF-005, REQ-NF-005

* **Integration Scenario: ITS-015-D1** (idempotent install — re-running CommandRegistrar produces identical state)
  * **Given** a clean `~/.specify/extensions/v-model/` install
  * **When** the install script is invoked twice in succession (real Spec
    Kit Core `CommandRegistrar` from `src/specify_cli/extensions.py`)
  * **Then** `assert_success` both times and `diff` of the two resulting
    `extensions.yml` registry files produces no output (REQ-NF-005)

---

### Module Verification: ARCH-016 (Structured Summary Reporter)

**Parent System Components**: SYS-012

#### Test Case: ITP-016-A (Always-emit contract — summary on stdout for both success and failure paths)

**Test File**: `tests/system/bridge-commands/{plan,tasks,implement}.bats`
**Technique**: CLI Contract Testing + Fault Injection
**Requirements traced**: REQ-019, HAZ-025

* **Integration Scenario: ITS-016-A1** (success path — summary on stdout for all three commands)
  * **Given** a happy-path fixture for each of plan / tasks / implement
  * **When** each command runs
  * **Then** for each: `assert_success` and `assert_output --partial "--- v-model run summary ---"`
    and the block contains `inputs_read:`, `outputs_produced:`, `warnings:`, `fatal_errors: []`

* **Integration Scenario: ITS-016-A2** (failure path — summary still emitted on non-zero exit)
  * **Given** a failing fixture (e.g. ITP-001 ITS-001-B1)
  * **When** the command runs and fails
  * **Then** `assert_failure` and `assert_output --partial "--- v-model run summary ---"`
    and `fatal_errors:` is non-empty

---

### Module Verification: ARCH-017 (Quality Compliance Harness)

**Parent System Components**: SYS-003

#### Test Case: ITP-017-A (Merge-gate blocks on harness <100% and audit failures)

**Test File**: `tests/system/bridge-commands/implement.bats`
**Technique**: Fixture-Driven Black-Box (mocked harness invocations)
**Requirements traced**: REQ-NF-002

* **Integration Scenario: ITS-017-A1** (any harness <100% ⇒ merge-gate `block` and non-zero exit)
  * **Given** a feature directory whose mocked four-stack harness (BATS,
    Pester, structural eval, LLM eval) shim returns a coverage report
    with one stack at 99%
  * **When** `commands/implement.md` runs to its §Quality Compliance step
    via the implement.bats harness
  * **Then** `assert_failure` and `assert_output --partial "merge-gate: block"`
    and the structured summary `quality_compliance:` block records the
    failing stack name with its <100% figure

* **Integration Scenario: ITS-017-A2** (scope-guardrail / dogfood-discipline audit failure ⇒ exit 1)
  * **Given** a feature directory whose mocked harnesses all report 100%
    but whose scope-guardrail audit detects an orchestrator/sandbox
    addition outside the declared module set
  * **When** `commands/implement.md` runs to its §Quality Compliance step
  * **Then** `assert_failure` with exit code 1 and
    `assert_output --partial "scope-guardrail: fail"` and the structured
    summary records the offending path

---

### Module Verification: ARCH-018 (Commit Annotator)

**Parent System Components**: SYS-014

#### Test Case: ITP-018-A (ID-suffixed commit message and no-op skip contract)

**Test File**: `tests/system/bridge-commands/implement.bats`
**Technique**: Fixture-Driven Black-Box
**Requirements traced**: REQ-021

* **Integration Scenario: ITS-018-A1** (commit message ends with `— <ID>, <ID>` suffix referencing implemented MODs)
  * **Given** a successful implement run that emitted source for MOD-001
    and MOD-002
  * **When** the test inspects `git log -1 --format=%s`
  * **Then** `assert_output --partial "— MOD-001, MOD-002"` (em-dash + space + comma-separated ID list)

* **Integration Scenario: ITS-018-A2** (no implementation commits when nothing was emitted)
  * **Given** a no-op re-run with `git diff --quiet` already true
  * **When** the implement command runs
  * **Then** `assert_output --partial "no source changes — commit skipped"`
    and `git log -1 --format=%s` is unchanged from the previous commit

---

### Module Verification: ARCH-019 (V-Model Artifact Reader (Deferred))

#### ITP-019 [DEFERRED — component dropped in paradigm shift]

**Original target**: ARCH-019 (V-Model Artifact Reader, Python parser)
**Status**: DROP per `drift-diff-plan.md`. In the Markdown+shell
paradigm the LLM reads Markdown artifacts natively; `check-prerequisites.sh`
in Spec Kit Core handles `FEATURE_DIR` / `AVAILABLE_DOCS` discovery.
Parser-drift risk (REQ-NF-003) is structurally eliminated by having no
parser. ID retained for traceability; no scenarios authored.

---

### Module Verification: ARCH-020 (Subprocess Runner (Deferred))

#### ITP-020 [DEFERRED — component dropped in paradigm shift]

**Original target**: ARCH-020 (Subprocess Runner, Python wrapper)
**Status**: DROP per `drift-diff-plan.md`. Shell scripts invoke other
shell scripts via `bash script.sh` natively; the allowlist (REQ-CN-002)
is self-evident in the set of scripts checked into `scripts/bash/`.
Stdout/stderr/exit-code capture is BATS' built-in `run` semantics.
ID retained for traceability; no scenarios authored.

---

### Module Verification: ARCH-021 (Filesystem Writer (Deferred))

#### ITP-021 [DEFERRED — component dropped in paradigm shift]

**Original target**: ARCH-021 (Filesystem Writer, Python atomic-write module)
**Status**: DROP per `drift-diff-plan.md`. Atomic write in shell is the
3-line pattern `tmp=$(mktemp -p "$(dirname "$f")"); ...; mv "$tmp" "$f"`,
used inline in the four new shell scripts. No dedicated module exists
to integration-test. The OS-level atomicity contract is exercised
indirectly by ITS-002-B1 and ITS-010-A1. ID retained for traceability;
no scenarios authored.

---

## Test Harness Notes

| Test File | Helper | Notes |
|-----------|--------|-------|
| `tests/system/bridge-commands/*.bats` | `tests/bats/test_helper.bash` (existing) | `setup_temp_dir`, `init_git_repo`, `copy_fixture` already provided. New helper `invoke_command()` wraps `commands/<name>.md` execution in a way that records stdout, exit code, and emitted files. |
| `tests/unit/bridge-commands/*.bats` | `tests/bats/test_helper.bash` | Standard `run script.sh ARGS` + `assert_success` / `assert_failure` / `assert_output --partial` from `bats-assert`. |
| `tests/bats/extension-manifest.bats` | `tests/bats/test_helper.bash` | Uses `python3 -c 'import yaml; ...'` to parse `extension.yml` (yaml is the only test-time Python dependency — already in `pyproject.toml`'s test extras). |

The `tests/fixtures/` tree already contains `minimal/`, `complex/`,
`gaps/`, `empty/` v-model fixture sets used by the existing
`validate-*-coverage.bats` suites — bridge-command tests reuse these.
New fixtures needed:

- `tests/fixtures/bridge-commands/plan-only-requirements/` (ITP-001-A1)
- `tests/fixtures/bridge-commands/plan-full-bundle/` (ITP-002-A2)
- `tests/fixtures/bridge-commands/tasks-direct-path/` (ITP-003-A1)
- `tests/fixtures/bridge-commands/implement-happy/` (ITP-004-A1)
- `tests/fixtures/bridge-commands/implement-gate-fail/` (ITP-004-B1)
- `tests/fixtures/bridge-commands/v-model-config/malformed/` (ITP-011-B1)
- `tests/fixtures/bridge-commands/spec-kit-core-v0.7.0/{plan-valid,plan-missing-context,tasks-valid,tasks-missing-impl}.md` (ITP-013)

---

## V&V Coverage (IEEE 1012:2016)

### Architecture-Module → ITP Mapping

| ARCH | Classification | Test File | ITP | Status |
|------|---------------|-----------|-----|--------|
| ARCH-001 | NEW-PROMPT-SECTION | `tests/system/bridge-commands/plan.bats` | ITP-001 | active |
| ARCH-002 | NEW-PROMPT-SECTION | `tests/system/bridge-commands/plan.bats` | ITP-002 | active |
| ARCH-003 | NEW-PROMPT-SECTION | `tests/system/bridge-commands/tasks.bats` | ITP-003 | active |
| ARCH-004 | NEW-PROMPT-SECTION | `tests/system/bridge-commands/implement.bats` | ITP-004 | active |
| ARCH-005 | NEW-PROMPT-SECTION | `tests/system/bridge-commands/implement.bats` | ITP-005 | active |
| ARCH-006 | NEW-PROMPT-SECTION | `tests/system/bridge-commands/implement.bats` | ITP-006 | active |
| ARCH-007 | NEW-SHELL | `tests/unit/bridge-commands/run-v-model-gate.bats` | ITP-007 | active |
| ARCH-008 | NEW-PROMPT-SECTION | `tests/system/bridge-commands/{plan,tasks}.bats` | ITP-008 | active |
| ARCH-009 | NEW-SHELL | `tests/unit/bridge-commands/validate-implements-ids.bats` | ITP-009 | active |
| ARCH-010 | NEW-SHELL | `tests/unit/bridge-commands/splice-managed-regions.bats` | ITP-010 | active |
| ARCH-011 | NEW-PROMPT-SECTION | `tests/system/bridge-commands/implement.bats` | ITP-011 | active |
| ARCH-012 | NEW-PROMPT-SECTION | `tests/system/bridge-commands/tasks.bats` | ITP-012 | active |
| ARCH-013 | NEW-SHELL | `tests/unit/bridge-commands/validate-core-schema.bats` | ITP-013 | active |
| ARCH-014 | NEW-PROMPT-SECTION | `tests/system/bridge-commands/tasks.bats` | ITP-014 | active |
| ARCH-015 | REUSE-CORE | `tests/bats/extension-manifest.bats` | ITP-015 | active |
| ARCH-016 | NEW-PROMPT-SECTION | all three e2e bats files | ITP-016 | active |
| ARCH-017 | NEW-PROMPT-SECTION | `tests/system/bridge-commands/implement.bats` | ITP-017 | active |
| ARCH-018 | NEW-PROMPT-SECTION | `tests/system/bridge-commands/implement.bats` | ITP-018 | active |
| ARCH-019 | DROP | — | ITP-019 | DEFERRED |
| ARCH-020 | DROP | — | ITP-020 | DEFERRED |
| ARCH-021 | DROP | — | ITP-021 | DEFERRED |

### Entry Criteria Check (IEEE 1012:2016 §5.6.1)

- ✅ `architecture-design.md` is current (rewritten on 2026-05-01 per `drift-diff-plan.md`)
- ✅ Every active `ARCH-NNN` module has at least one `ITP-NNN-X` test case (18/18 = 100% forward coverage)
- ✅ All active `ITP-NNN-X` test cases have at least one `ITS-NNN-X#` executable scenario
- ✅ DROP'd ARCHs (019, 020, 021) have DEFERRED placeholders preserving traceability IDs
- ✅ Every test scenario uses observable boundaries (stdout / exit code / file system / `extension.yml` content)

**Gap list:** *None* — all active architecture modules are covered.

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Architecture Modules (ARCH) | 21 (18 active, 3 DROP) |
| Active ITPs | 30 |
| DEFERRED ITPs (placeholder, no scenarios) | 3 (ITP-019, ITP-020, ITP-021) |
| Total executable Scenarios (ITS) | 49 |
| Active ARCHs with ≥1 ITP | 18 / 18 (100%) |
| Active ITPs with ≥1 ITS | 30 / 30 (100%) |
| **Forward Coverage (active ARCH→ITP)** | **100%** |

### Technique Distribution

| Technique (primary axis) | Test Cases | Percentage |
|--------------------------|-----------|------------|
| Fixture-Driven Black-Box (pure or combined with Fault Injection / CLI Contract / Idempotent Re-Run) | 17 | 56.7% |
| CLI Contract Testing (combined with Fault Injection and/or Idempotent Re-Run) | 12 | 40.0% |
| Idempotent Re-Run (pure, ITP-004-D) | 1 | 3.3% |

(Fault Injection and Idempotent Re-Run are not primary axes — they are
combined with the two primary techniques above as scenario-level
suffixes (`B` = fault injection, `D` = idempotency); the row counts
above attribute each test case to its dominant axis.)

## Uncovered Modules

None — all 18 active architecture modules covered. The 3 DROP'd modules
(ARCH-019, ARCH-020, ARCH-021) have DEFERRED placeholders per
the paradigm-shift contract; they do not exist at runtime and therefore
have no observable boundary to test.
