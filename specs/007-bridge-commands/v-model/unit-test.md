# Unit Test Plan: Bridge Commands (007)

**Feature Branch**: `feature/007-bridge-commands`
**Created**: 2026-04-26
**Last Rewritten**: 2026-05-01 (paradigm-drift correction — see `drift-diff-plan.md`)
**Status**: Draft
**Source**: `specs/007-bridge-commands/v-model/module-design.md`

## Overview

This document defines the Unit Test Plan for the bridge-commands feature
**in the Markdown+shell paradigm**. The feature delivers no Python
implementation; the 27 modules from `module-design.md` decompose into
three categories of testable unit:

1. **Shell-script units** — `run-v-model-gate.sh`,
   `validate-implements-ids.sh`, `splice-managed-regions.sh`,
   `validate-core-schema.sh` — tested with **BATS** in
   `tests/unit/bridge-commands/` (the same files that act as
   integration tests, with the unit cases below isolating per-function
   and per-flag behaviour).
2. **LLM prompt sections** — the 16 NEW-PROMPT-SECTION MODs decompose
   into discrete sections inside `commands/plan.md`, `commands/tasks.md`,
   `commands/implement.md` (e.g. §Execution Flow, §Output Artifacts,
   §Enrichment, §Code Generation, §Commit Annotation). These are tested
   with **DeepEval structural metrics** in `tests/evals/` that assert:
   required headings present, required preconditions stated, required
   output sections enumerated, error-path language present.
3. **`extension.yml` schema units** — MOD-020 (REUSE-CORE) is tested by
   asserting the manifest YAML parses against the spec-kit-core
   `CommandRegistrar` schema and contains the three required hook
   entries.

DROP'd modules (MOD-022, MOD-024, MOD-026, MOD-027 — see
`drift-diff-plan.md`) have UTP IDs preserved as `[NO UNIT TEST —
DEFERRED]` placeholders so the trace matrix continues to resolve.

## ID Schema

- **Unit Test Case**: `UTP-{NNN}` where `NNN` matches the parent MOD.
  One UTP per active MOD; deferred MODs retain their UTP ID as a
  placeholder.
- **Unit Test Scenario**: `UTS-{NNN}-{LETTER}{#}` — nested under the
  parent UTP, with a technique-suffix letter and numeric suffix.
- IDs are permanent — never renumbered or reassigned.

## Test Techniques (Markdown+shell paradigm)

| Technique | Applied To | What It Tests |
|-----------|-----------|---------------|
| **BATS Statement & Branch Coverage** | Shell scripts | Every `case`/`if`/`for` branch reached by at least one fixture |
| **BATS Equivalence Partitioning** | Shell-script flags & input classes | Each `--mode` flag value, each input file class (valid / missing-section / hallucinated-id) |
| **BATS Boundary Value Analysis** | Shell-script numeric inputs | 0/1/N marker counts, empty/single/many ID sets |
| **DeepEval Structural Metric** | Prompt sections in `commands/*.md` | Required headings present, required preconditions stated, required output enumerated, error-path language present |
| **YAML Schema Validation** | `extension.yml` | Manifest parses; three hook entries present and reference real command files |

## Unit Tests

---

## UTP-001 (Plan Synthesis Orchestrator — `commands/plan.md` §Execution Flow)

**Covers**: MOD-001 (NEW-PROMPT-SECTION)
**Parent Architecture Modules**: ARCH-001
**Target Artifact**: `commands/plan.md` §Execution Flow
**Test File**: `tests/evals/test_plan_command_eval.py::TestPlanExecutionFlow`
**Technique**: DeepEval Structural Metric
**Requirements traced**: REQ-001, REQ-IF-001

### UTS-001-A1 (§Execution Flow heading present)

* **Arrange**: load `commands/plan.md`
* **Act**: `StructuralPromptMetric(required_headings=["## Execution Flow"]).measure(tc)`
* **Assert**: metric score == 1.0; `"Missing heading"` not in `metric.reason`

### UTS-001-A2 (steps explicitly enumerated: read inputs → enrich → validate schema → emit → summarize)

* **Arrange**: same fixture
* **Act**: `StructuralPromptMetric(required_steps=["Read upstream artifacts", "Inject enrichment", "Run validate-core-schema.sh --plan", "Emit canonical artifacts", "Emit structured summary"]).measure(tc)`
* **Assert**: every required step substring is present in the §Execution Flow body

### UTS-001-A3 (error-path language: "If FATAL: do not emit any output file" present)

* **Arrange**: same
* **Act**: assert `"do not emit"` and `"fail-closed"` substrings present in §Execution Flow
* **Assert**: REQ-022 fail-closed contract is articulated in the prompt

---

## UTP-002 (`emit_canonical_outputs` — `commands/plan.md` §Output Artifacts)

**Covers**: MOD-002 (NEW-PROMPT-SECTION)
**Parent Architecture Modules**: ARCH-002
**Target Artifact**: `commands/plan.md` §Output Artifacts
**Test File**: `tests/evals/test_plan_command_eval.py::TestPlanOutputArtifacts`
**Technique**: DeepEval Structural Metric

### UTS-002-A1 (§Output Artifacts enumerates all 5 canonical outputs)

* **Arrange**: load `commands/plan.md`
* **Act**: assert presence of `plan.md`, `data-model.md`, `contracts/`,
  `quickstart.md`, `research.md` in the §Output Artifacts section
* **Assert**: structural metric returns 1.0

### UTS-002-A2 (selective-emission rule stated for nullable upstream)

* **Act**: assert `"only emit"` and `"if upstream"` substrings present
* **Assert**: prompt instructs the LLM to skip optional artifacts when their upstream is absent

### UTS-002-A3 (atomic-write instruction: write to temp then rename)

* **Act**: assert `"mktemp"` or `"temp file then rename"` substring present
* **Assert**: REQ-022 atomicity articulated

---

## UTP-003 (Tasks Synthesis Orchestrator — `commands/tasks.md` §Execution Flow)

**Covers**: MOD-003 (NEW-PROMPT-SECTION)
**Parent Architecture Modules**: ARCH-003
**Target Artifact**: `commands/tasks.md` §Execution Flow
**Test File**: `tests/evals/test_tasks_command_eval.py::TestTasksExecutionFlow`
**Technique**: DeepEval Structural Metric

### UTS-003-A1 (§Execution Flow heading present and ordered correctly)

* **Arrange**: load `commands/tasks.md`
* **Act**: assert §Execution Flow contains the steps "detect hybrid path",
  "load V-Model artifacts", "build TDD task list", "enrich with hazards",
  "validate schema", "emit", "summarize" in that order
* **Assert**: structural metric returns 1.0

### UTS-003-A2 (TDD-ordering rule explicit)

* **Act**: assert `"test task before implementation task"` and `"same MOD"` substrings present
* **Assert**: REQ-IF-002 ordering contract is captured

---

## UTP-004 (`build_tdd_task_list` — `commands/tasks.md` §TDD Ordering)

**Covers**: MOD-004 (NEW-PROMPT-SECTION)
**Parent Architecture Modules**: ARCH-003
**Target Artifact**: `commands/tasks.md` §TDD Ordering
**Test File**: `tests/evals/test_tasks_command_eval.py::TestTDDOrdering`
**Technique**: DeepEval Structural Metric

### UTS-004-A1 (5-bullet ordering algorithm enumerated)

* **Arrange**: load §TDD Ordering
* **Act**: assert at least 5 bullet points and presence of substrings
  `"unit test"`, `"integration test"`, `"system test"`, `"acceptance test"`, `"implementation"`
* **Assert**: each level appears in the prescribed order

### UTS-004-A2 (parallel-task `[P]` marker rule documented)

* **Act**: assert `"[P]"` and `"independent"` substrings present
* **Assert**: parallelism semantics explained

---

## UTP-005 (Implementation Orchestrator — `commands/implement.md` §Execution Flow)

**Covers**: MOD-005 (NEW-PROMPT-SECTION)
**Parent Architecture Modules**: ARCH-004
**Target Artifact**: `commands/implement.md` §Execution Flow
**Test File**: `tests/evals/test_implement_command_eval.py::TestImplementExecutionFlow`
**Technique**: DeepEval Structural Metric

### UTS-005-A1 (gate-first ordering enforced)

* **Arrange**: load §Execution Flow
* **Act**: assert `"run-v-model-gate.sh"` invocation appears before any
  `"generate code"` or `"emit source"` instruction
* **Assert**: gate-before-emit contract present (HAZ-009)

### UTS-005-A2 (gate-fail → abort-without-write contract)

* **Act**: assert `"if gate: FAIL"` and (`"do not emit"` or `"abort"`) substrings present
* **Assert**: REQ-022 fail-closed reaffirmed at orchestrator level

---

## UTP-006 (`generate_code` dispatcher — `commands/implement.md` §Code Generation)

**Covers**: MOD-006 (NEW-PROMPT-SECTION)
**Parent Architecture Modules**: ARCH-005
**Target Artifact**: `commands/implement.md` §Code Generation
**Test File**: `tests/evals/test_implement_command_eval.py::TestCodeGeneration`
**Technique**: DeepEval Structural Metric

### UTS-006-A1 (per-MOD iteration rule documented)

* **Arrange**: load §Code Generation
* **Act**: assert `"for each MOD"` substring present
* **Assert**: dispatcher behaviour articulated

### UTS-006-A2 (language-aware emission rule documented)

* **Act**: assert `"Implementation Language"` field is named as the dispatch key
* **Assert**: language-specific output rule present

---

## UTP-007 (`render_module_source` — `commands/implement.md` §Traceability Comments)

**Covers**: MOD-007 (NEW-PROMPT-SECTION)
**Parent Architecture Modules**: ARCH-005
**Target Artifact**: `commands/implement.md` §Traceability Comments
**Test File**: `tests/evals/test_implement_command_eval.py::TestTraceabilityComments`
**Technique**: DeepEval Structural Metric

### UTS-007-A1 (Implements-comment mandate stated)

* **Arrange**: load §Traceability Comments
* **Act**: assert `"# Implements MOD-NNN"` (or `"// Implements MOD-NNN"`) substring present
* **Assert**: REQ-021 traceability-comment requirement captured in prompt

### UTS-007-A2 (validate-implements-ids.sh post-emission step named)

* **Act**: assert `"validate-implements-ids.sh"` substring present
* **Assert**: hallucination-guard handoff documented

---

## UTP-008 (`generate_tests` dispatcher — `commands/implement.md` §Test Generation)

**Covers**: MOD-008 (NEW-PROMPT-SECTION)
**Parent Architecture Modules**: ARCH-006
**Target Artifact**: `commands/implement.md` §Test Generation
**Test File**: `tests/evals/test_implement_command_eval.py::TestTestGeneration`
**Technique**: DeepEval Structural Metric

### UTS-008-A1 (four-level enumeration present)

* **Arrange**: load §Test Generation
* **Act**: assert `"unit"`, `"integration"`, `"system"`, `"acceptance"` all named
* **Assert**: four-level dispatcher rule documented (REQ-IF-003)

---

## UTP-009 (`render_test_file_for_level` — `commands/implement.md` §Test Levels)

**Covers**: MOD-009 (NEW-PROMPT-SECTION)
**Parent Architecture Modules**: ARCH-006
**Target Artifact**: `commands/implement.md` §Test Levels
**Test File**: `tests/evals/test_implement_command_eval.py::TestTestLevels`
**Technique**: DeepEval Structural Metric

### UTS-009-A1 (per-level target directory documented)

* **Arrange**: load §Test Levels
* **Act**: assert each of `tests/unit/`, `tests/integration/`,
  `tests/system/`, `tests/acceptance/` named as the target directory
  for the matching level
* **Assert**: structural metric returns 1.0

---

## UTP-010 (`evaluate_gate` — `scripts/bash/run-v-model-gate.sh`)

**Covers**: MOD-010 (NEW-SHELL)
**Parent Architecture Modules**: ARCH-007
**Target Source File(s)**: `scripts/bash/run-v-model-gate.sh` (+ PowerShell mirror `scripts/powershell/run-v-model-gate.ps1`)
**Test File**: `tests/unit/bridge-commands/run-v-model-gate.bats`
**Technique**: BATS Statement & Branch Coverage + Equivalence Partitioning

### UTS-010-A1 (statement coverage: every validator invocation reached on happy path)

* **Arrange**: minimal fixture (full coverage)
* **Act**:
  ```bash
  run bash "$SCRIPTS_DIR/run-v-model-gate.sh" "$FIXTURES_DIR/minimal"
  ```
* **Assert**: `[ "$status" -eq 0 ]` and `assert_output --partial "build-matrix.sh: ok"`
  and `assert_output --partial "validate-requirement-coverage.sh: ok"`
  and `assert_output --partial "validate-system-coverage.sh: ok"`
  and `assert_output --partial "validate-architecture-coverage.sh: ok"`
  and `assert_output --partial "validate-module-coverage.sh: ok"`
  and `assert_output --partial "validate-hazard-coverage.sh: ok"`

### UTS-010-A2 (branch coverage: short-circuit-on-fail behaviour)

* **Arrange**: a fixture that fails `validate-module-coverage.sh`
* **Act**: `run bash "$SCRIPTS_DIR/run-v-model-gate.sh" "$FIXTURES_DIR/gaps"`
* **Assert**: `assert_failure` and `assert_output --partial "gate: FAIL"`
  and (per the script's documented order) the failing validator is named

### UTS-010-B1 (gate result partition: PASS)

* **Arrange**: minimal fixture
* **Act**: `run bash "$SCRIPTS_DIR/run-v-model-gate.sh" "$FIXTURES_DIR/minimal"`
* **Assert**: `assert_output --partial "gate: PASS"`

### UTS-010-B2 (gate result partition: FAIL)

* **Arrange**: gaps fixture
* **Act**: same script call against `gaps`
* **Assert**: `assert_output --partial "gate: FAIL"` and `[ "$status" -ne 0 ]`

### UTS-010-B3 (usage: missing argument → exit 1 + Usage line)

* **Arrange**: no arg
* **Act**: `run bash "$SCRIPTS_DIR/run-v-model-gate.sh"`
* **Assert**: `assert_failure` and `assert_output --partial "Usage:"`

---

## UTP-011 (`embed_enrichment` — `commands/plan.md` §Enrichment)

**Covers**: MOD-011 (NEW-PROMPT-SECTION)
**Parent Architecture Modules**: ARCH-008
**Target Artifact**: `commands/plan.md` §Enrichment
**Test File**: `tests/evals/test_plan_command_eval.py::TestEnrichment`
**Technique**: DeepEval Structural Metric

### UTS-011-A1 (HTML-comment block format documented)

* **Arrange**: load §Enrichment
* **Act**: assert `"<!-- vmodel:traces"` and `"-->"` substrings present
* **Assert**: enrichment marker syntax captured

### UTS-011-A2 (placement rule: immediately after document title)

* **Act**: assert `"after the document title"` (or equivalent) substring present
* **Assert**: REQ-005 placement rule articulated

---

## UTP-012 (`embed_traceability_comments` — `commands/tasks.md` §Traceability Comments)

**Covers**: MOD-012 (NEW-PROMPT-SECTION)
**Parent Architecture Modules**: ARCH-008
**Target Artifact**: `commands/tasks.md` §Traceability Comments
**Test File**: `tests/evals/test_tasks_command_eval.py::TestTraceabilityComments`
**Technique**: DeepEval Structural Metric

### UTS-012-A1 (per-task `<!-- traces-to: ... -->` comment mandated)

* **Arrange**: load §Traceability Comments
* **Act**: assert `"<!-- traces-to:"` substring and the chain
  `"MOD"`, `"ARCH"`, `"SYS"`, `"REQ"` all named in the example
* **Assert**: full upward chain documented

---

## UTP-013 (`verify_ids` — `scripts/bash/validate-implements-ids.sh`)

**Covers**: MOD-013 (NEW-SHELL)
**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `scripts/bash/validate-implements-ids.sh` (+ `scripts/powershell/validate-implements-ids.ps1`)
**Test File**: `tests/unit/bridge-commands/validate-implements-ids.bats`
**Technique**: BATS Statement & Branch Coverage + Equivalence Partitioning

### UTS-013-A1 (true-branch: all referenced IDs valid → exit 0)

* **Arrange**: a temp source file containing `# Implements REQ-001` and
  a V-Model fixture where REQ-001 is declared
* **Act**:
  ```bash
  run bash "$SCRIPTS_DIR/validate-implements-ids.sh" \
      --vmodel-dir "$FIXTURES_DIR/minimal" "$TEST_TEMP_DIR/src/"
  ```
* **Assert**: `[ "$status" -eq 0 ]` and `assert_output --partial "all IDs valid"`

### UTS-013-A2 (false-branch: hallucinated IDs → exit 1 + named IDs)

> **SENTINEL FIXTURE — DO NOT REMOVE OR RENAME `MOD-099`, `MOD-555`,
> `MOD-999`, `REQ-999`.** These are the canonical hallucination-guard
> negative-test fixtures referenced from HAZ-012 and from the original
> Python-paradigm UTS-013-A2 / UTS-013-B2; preserving them across the
> paradigm shift maintains test-history continuity and ensures the new
> shell-script regex covers the same ID-shape boundary classes the
> Python regex covered.

* **Arrange**: a temp source file containing four hallucinated IDs:
  ```
  # Implements MOD-099
  # Implements MOD-555
  # Implements MOD-999
  # Implements REQ-999
  ```
  None of these IDs is declared in the V-Model fixture under
  `$FIXTURES_DIR/minimal`.
* **Act**:
  ```bash
  run bash "$SCRIPTS_DIR/validate-implements-ids.sh" \
      --vmodel-dir "$FIXTURES_DIR/minimal" "$TEST_TEMP_DIR/src/"
  ```
* **Assert**:
  - `[ "$status" -ne 0 ]`
  - `assert_output --partial "HALLUCINATED: MOD-099"`
  - `assert_output --partial "HALLUCINATED: MOD-555"`
  - `assert_output --partial "HALLUCINATED: MOD-999"`
  - `assert_output --partial "HALLUCINATED: REQ-999"`

### UTS-013-A3 (loop-zero branch: source dir empty → exit 0)

* **Arrange**: empty `$TEST_TEMP_DIR/src/` directory
* **Act**: same script call
* **Assert**: `[ "$status" -eq 0 ]` (no IDs to verify == valid)

### UTS-013-B1 (equivalence partition: well-formed-known ID accepted)

* **Arrange**: source containing `// Implements MOD-001` (JS comment marker, valid ID)
* **Act**: script call
* **Assert**: `assert_success` (regex covers both `#` and `//` prefixes)

### UTS-013-B2 (equivalence partition: well-formed-unknown ID rejected — sentinel)

* **Arrange**: source containing `# Implements MOD-555` (well-formed but unknown — same MOD-555 sentinel as UTS-013-A2)
* **Act**: script call
* **Assert**: `assert_failure` and `assert_output --partial "HALLUCINATED: MOD-555"`

### UTS-013-B3 (equivalence partition: malformed ID ignored, not flagged)

* **Arrange**: source containing `# Implements FOO-bar`
  (does not match canonical `[A-Z]+-[A-Z0-9-]+` pattern with the right prefixes)
* **Act**: script call
* **Assert**: `assert_success` (the regex's prefix allowlist `(REQ|SYS|ARCH|MOD|HAZ|ATP|ITP|UTP|STP|UTS|ITS|STS|SCN|PRF|WAV)` filters it out)

---

## UTP-014 (`splice_managed_regions` — `scripts/bash/splice-managed-regions.sh`)

**Covers**: MOD-014 (NEW-SHELL)
**Parent Architecture Modules**: ARCH-010
**Target Source File(s)**: `scripts/bash/splice-managed-regions.sh` (+ `scripts/powershell/splice-managed-regions.ps1`)
**Test File**: `tests/unit/bridge-commands/splice-managed-regions.bats`
**Technique**: BATS Statement & Branch Coverage + Boundary Value Analysis

### UTS-014-A1 (true-branch: target absent → wrap with markers)

* **Arrange**: target path does not exist (under `$TEST_TEMP_DIR`)
* **Act**:
  ```bash
  run bash "$SCRIPTS_DIR/splice-managed-regions.sh" \
      "$TEST_TEMP_DIR/foo.py" "print('hello')" python
  ```
* **Assert**: `assert_success` and the target now exists and
  `grep -q "VMODEL-MANAGED-BEGIN" "$TEST_TEMP_DIR/foo.py"`

### UTS-014-A2 (true-branch: target with single managed region → in-place splice)

* **Arrange**: target containing `outside1\n# VMODEL-MANAGED-BEGIN\nold\n# VMODEL-MANAGED-END\noutside2`
* **Act**: invoke with new content `new`
* **Assert**: `assert_success`, region replaced with `new`, `outside1`/`outside2` preserved verbatim

### UTS-014-A3 (false-branch: unbalanced markers → `unbalanced markers` error)

* **Arrange**: target containing `# VMODEL-MANAGED-BEGIN` only (no END)
* **Act**: invoke
* **Assert**: `assert_failure` and `assert_output --partial "unbalanced markers"`

### UTS-014-B1 (boundary: 0 markers → wrap-mode behaviour, not error)

* **Arrange**: existing target with no markers at all
* **Act**: invoke with new content
* **Assert**: `assert_success` and the target file is overwritten as
  `# VMODEL-MANAGED-BEGIN\n<new>\n# VMODEL-MANAGED-END` (per
  `commands/implement.md` rule: missing markers ⇒ wrap)

### UTS-014-B2 (boundary: exactly 1 region — happy path)

* Same as UTS-014-A2

### UTS-014-B3 (boundary: 2 regions in same file — rejected per single-region contract)

* **Arrange**: target with two non-overlapping `BEGIN/END` pairs
* **Act**: invoke
* **Assert**: `assert_failure` and `assert_output --partial "multiple managed regions"`
  (the script's contract is single-region per file; multi-region requires named markers — out of scope for MVP)

---

## UTP-015 (`apply_overlay` — `commands/implement.md` §Domain Overlay)

**Covers**: MOD-015 (NEW-PROMPT-SECTION)
**Parent Architecture Modules**: ARCH-011
**Target Artifact**: `commands/implement.md` §Domain Overlay
**Test File**: `tests/evals/test_implement_command_eval.py::TestDomainOverlay`
**Technique**: DeepEval Structural Metric

### UTS-015-A1 (overlay-file lookup rule documented)

* **Arrange**: load §Domain Overlay
* **Act**: assert `"v-model-config.yml"` substring present and
  `"if present"` (conditional load) substring present
* **Assert**: structural metric returns 1.0

### UTS-015-A2 (parse-fail → fail-closed instruction)

* **Act**: assert `"parse error"` and `"abort"` substrings present in §Domain Overlay
* **Assert**: HAZ-024 mitigation captured at the prompt level

---

## UTP-016 (`enrich_with_hazards` — `commands/tasks.md` §Hazard Enrichment)

**Covers**: MOD-016 (NEW-PROMPT-SECTION)
**Parent Architecture Modules**: ARCH-012
**Target Artifact**: `commands/tasks.md` §Hazard Enrichment
**Test File**: `tests/evals/test_tasks_command_eval.py::TestHazardEnrichment`
**Technique**: DeepEval Structural Metric

### UTS-016-A1 (`hazard-analysis.md` precondition stated)

* **Arrange**: load §Hazard Enrichment
* **Act**: assert `"hazard-analysis.md"` and `"if present"` substrings present
* **Assert**: precondition documented

### UTS-016-A2 (HAZ-NNN verification-task emission rule documented)

* **Act**: assert `"HAZ-"` and (`"verification task"` or `"emit task"`) substrings present
* **Assert**: REQ-IF-004 hazard-task contract articulated

### UTS-016-A3 (priority-raise rule for mitigation tasks)

* **Act**: assert `"raise"` (or `"escalate"`) and `"priority"` substrings present
* **Assert**: priority-elevation rule documented

---

## UTP-017 (`validate_plan_schema` — `scripts/bash/validate-core-schema.sh --plan`)

**Covers**: MOD-017 (NEW-SHELL — merged with MOD-018 into single script)
**Parent Architecture Modules**: ARCH-013
**Target Source File(s)**: `scripts/bash/validate-core-schema.sh` (+ `scripts/powershell/validate-core-schema.ps1`)
**Test File**: `tests/unit/bridge-commands/validate-core-schema.bats`
**Technique**: BATS Statement & Branch Coverage + Equivalence Partitioning

### UTS-017-A1 (true-branch: all required plan sections present → exit 0)

* **Arrange**: fixture `tests/fixtures/bridge-commands/spec-kit-core-v0.7.0/plan-valid.md`
* **Act**:
  ```bash
  run bash "$SCRIPTS_DIR/validate-core-schema.sh" --plan "$FIXTURES_DIR/spec-kit-core-v0.7.0/plan-valid.md"
  ```
* **Assert**: `[ "$status" -eq 0 ]` and `assert_output --partial "schema: ok (spec-kit-core v0.7.0)"`

### UTS-017-A2 (false-branch: missing `## Technical Context` → exit non-zero + named gap)

* **Arrange**: fixture missing the section
* **Act**: same script in `--plan` mode
* **Assert**: `assert_failure` and `assert_output --partial "MISSING: ## Technical Context"`

### UTS-017-B1 (partition: pinned-version reporting)

* **Arrange**: any valid plan fixture
* **Act**: script with `--plan`
* **Assert**: `assert_output --partial "spec-kit-core v0.7.0"` (the pinned version is named)

---

## UTP-018 (`validate_tasks_schema` — `scripts/bash/validate-core-schema.sh --tasks`)

**Covers**: MOD-018 (NEW-SHELL — merged into the same script as MOD-017)
**Parent Architecture Modules**: ARCH-013
**Target Source File(s)**: `scripts/bash/validate-core-schema.sh`
**Test File**: `tests/unit/bridge-commands/validate-core-schema.bats`
**Technique**: BATS Statement & Branch Coverage + Equivalence Partitioning

### UTS-018-A1 (true-branch: all required tasks sections present → exit 0)

* **Arrange**: `tasks-valid.md` fixture
* **Act**: `run bash "$SCRIPTS_DIR/validate-core-schema.sh" --tasks "$FIXTURES_DIR/spec-kit-core-v0.7.0/tasks-valid.md"`
* **Assert**: `[ "$status" -eq 0 ]` and `assert_output --partial "schema: ok"`

### UTS-018-A2 (false-branch: missing `## Phase 3.x: Implementation` → exit non-zero)

* **Arrange**: `tasks-missing-impl.md` fixture
* **Act**: same in `--tasks` mode
* **Assert**: `assert_failure` and `assert_output --partial "MISSING: ## Phase 3"`

### UTS-018-B1 (partition: unknown mode flag)

* **Arrange**: `--bogus` flag
* **Act**: script call
* **Assert**: `assert_failure` and `assert_output --partial "Usage:"`

---

## UTP-019 (`detect_enrichment` — `commands/tasks.md` §Hybrid Path Detection)

**Covers**: MOD-019 (NEW-PROMPT-SECTION)
**Parent Architecture Modules**: ARCH-014
**Target Artifact**: `commands/tasks.md` §Hybrid Path Detection
**Test File**: `tests/evals/test_tasks_command_eval.py::TestHybridPathDetection`
**Technique**: DeepEval Structural Metric

### UTS-019-A1 (detection rule: grep for `<!-- vmodel:traces` in `plan.md`)

* **Arrange**: load §Hybrid Path Detection
* **Act**: assert `"<!-- vmodel:traces"` and `"plan.md"` substrings present
* **Assert**: detection token named

### UTS-019-A2 (fallback rule: when missing, populate from V-Model artifacts directly)

* **Act**: assert `"fall back"` (or `"populate from"`) and `"V-Model artifacts"` substrings present
* **Assert**: REQ-IF-005 hybrid-path contract captured

---

## UTP-020 (`register_hooks` — `extension.yml` hook entries)

**Covers**: MOD-020 (REUSE-CORE — handled by `src/specify_cli/extensions.py::CommandRegistrar`)
**Parent Architecture Modules**: ARCH-015
**Target Artifact**: `extension.yml` (3 hook entries)
**Test File**: `tests/bats/extension-manifest.bats`
**Technique**: YAML Schema Validation

### UTS-020-A1 (extension.yml parses as valid YAML)

* **Arrange**: repo-root `extension.yml`
* **Act**:
  ```bash
  run python3 -c "import yaml; yaml.safe_load(open('extension.yml'))"
  ```
* **Assert**: `[ "$status" -eq 0 ]`

### UTS-020-A2 (three required hook entries present)

* **Act**:
  ```bash
  run grep -cE '^[[:space:]]+(after_specify|before_implement|after_implement):' extension.yml
  ```
* **Assert**: `[ "$output" = "3" ]`

### UTS-020-A3 (each hook entry references an existing command file)

* **Act**: parse each `command:` value under hooks and check that
  `commands/<basename>.md` exists for each
* **Assert**: all three referenced command files (`plan.md`, `tasks.md`, `implement.md`) are present

---

## UTP-021 (`emit_summary` — §Structured Summary in all three `commands/*.md`)

**Covers**: MOD-021 (NEW-PROMPT-SECTION)
**Parent Architecture Modules**: ARCH-016
**Target Artifact**: `commands/{plan,tasks,implement}.md` §Structured Summary
**Test File**: `tests/evals/test_summary_section_eval.py::TestStructuredSummary`
**Technique**: DeepEval Structural Metric (one assertion per command file)

### UTS-021-A1 (all three command files contain §Structured Summary)

* **Arrange**: load each of the three command files
* **Act**: assert `"## Structured Summary"` heading present in each
* **Assert**: structural metric returns 1.0 for all three

### UTS-021-A2 (required summary fields enumerated)

* **Act**: in each command file's §Structured Summary, assert presence
  of `inputs_read`, `outputs_produced`, `warnings`, `fatal_errors`
* **Assert**: every required field named

### UTS-021-A3 (always-emit-on-failure rule documented)

* **Act**: assert `"emit on every exit path"` (or `"even on failure"`) substring present
* **Assert**: HAZ-025 mitigation articulated

---

## UTP-022 [NO UNIT TEST — DEFERRED]

**Original target**: MOD-022 (`compute_coverage_report` Python module)
**Status**: DROP per `drift-diff-plan.md`. The four-stack quality
harness is a CI-process concern (GitHub Actions branch protection over
the existing `tests/bats/`, `tests/pester/`, `tests/evals/` suites) —
not a runtime module. ID retained for traceability; no scenarios authored.

---

## UTP-023 (`annotate_commit` — `commands/implement.md` §Commit Annotation)

**Covers**: MOD-023 (NEW-PROMPT-SECTION)
**Parent Architecture Modules**: ARCH-018
**Target Artifact**: `commands/implement.md` §Commit Annotation
**Test File**: `tests/evals/test_implement_command_eval.py::TestCommitAnnotation`
**Technique**: DeepEval Structural Metric

### UTS-023-A1 (em-dash + ID-list suffix format documented)

* **Arrange**: load §Commit Annotation
* **Act**: assert `"— "` (em-dash + space) and `"MOD-"` substrings present in the example
* **Assert**: REQ-021 commit-suffix format documented

### UTS-023-A2 (no-op skip rule documented)

* **Act**: assert `"no source changes"` and `"skip"` substrings present
* **Assert**: idempotent re-run skip rule documented

---

## UTP-024 [NO UNIT TEST — DEFERRED]

**Original target**: MOD-024 (`load_artifacts` Python parser)
**Status**: DROP per `drift-diff-plan.md`. In the Markdown+shell
paradigm the LLM reads Markdown natively; `check-prerequisites.sh` in
Spec Kit Core handles `FEATURE_DIR` / `AVAILABLE_DOCS` discovery.
Parser-drift risk (REQ-NF-003) is structurally eliminated by having no
parser. ID retained for traceability; no scenarios authored.

---

## UTP-025 (`extract_id_set` — inline in `validate-implements-ids.sh`)

**Covers**: MOD-025 (NEW-SHELL — merged into `validate-implements-ids.sh`, no separate file)
**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `scripts/bash/validate-implements-ids.sh` (ID-extraction grep block, ~15 lines)
**Test File**: `tests/unit/bridge-commands/validate-implements-ids.bats`
**Technique**: BATS Statement & Branch Coverage + Equivalence Partitioning

### UTS-025-A1 (extracts canonical ID prefixes from V-Model artifacts)

* **Arrange**: a V-Model fixture containing `REQ-001`, `SYS-001`,
  `ARCH-001`, `MOD-001`, `HAZ-001`, `ATP-001`, `ITP-001`, `UTP-001` declarations
* **Act**: run the script with `--list-ids` (or via the dedicated
  `--vmodel-dir` mode that prints the extracted set on `--debug`)
* **Assert**: every prefix appears in the output (one ID per line, sorted, deduplicated)

### UTS-025-A2 (does not extract IDs from non-V-Model paths)

* **Arrange**: V-Model fixture under `$FIXTURES_DIR/minimal/v-model/`
  plus a sibling unrelated file containing `REQ-999`
* **Act**: same script call
* **Assert**: `REQ-999` is **not** in the extracted set (the grep is
  scoped to `specs/<feature>/v-model/*.md`)

### UTS-025-B1 (partition: empty V-Model dir → empty extracted set)

* **Arrange**: empty fixture
* **Act**: extraction
* **Assert**: extracted set is empty; `assert_success`

---

## UTP-026 [NO UNIT TEST — DEFERRED]

**Original target**: MOD-026 (`run_subprocess` Python wrapper)
**Status**: DROP per `drift-diff-plan.md`. Shell scripts invoke other
shell scripts via `bash script.sh` natively; the allowlist (REQ-CN-002)
is self-evident in the set of scripts checked into `scripts/bash/`.
BATS' built-in `run` semantics replace stdout/stderr/exit-code capture.
ID retained for traceability; no scenarios authored.

---

## UTP-027 [NO UNIT TEST — DEFERRED]

**Original target**: MOD-027 (`atomic_write` Python module)
**Status**: DROP per `drift-diff-plan.md`. Atomic write in shell is the
3-line pattern `tmp=$(mktemp -p "$(dirname "$f")"); printf '%s' "$content" > "$tmp"; mv "$tmp" "$f"`,
used inline in the four new shell scripts. No dedicated module exists
to unit-test. The OS-level rename atomicity contract is exercised
indirectly by ITS-002-B1 and ITS-010-A1. ID retained for traceability;
no scenarios authored.

---

## External Module Bypass

None. The 4 deferred MODs (MOD-022, MOD-024, MOD-026, MOD-027) are
**dropped**, not bypassed: they no longer exist as runtime modules in
the Markdown+shell paradigm. There are no in-process external Python
dependencies to mock.

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Modules (MOD) | 27 (23 active, 4 DROP) |
| Active MODs tested | 23 |
| MODs deferred ([NO UNIT TEST — DEFERRED]) | 4 (MOD-022, MOD-024, MOD-026, MOD-027) |
| Active UTPs | 23 |
| Total executable Scenarios (UTS) | 56 |
| Active MODs with ≥1 UTP | 23 / 23 (100%) |
| Active UTPs with ≥1 UTS | 23 / 23 (100%) |
| **Forward Coverage (active MOD→UTP)** | **100%** |

### Technique Distribution

| Technique | Test Cases | Percentage |
|-----------|-----------|------------|
| DeepEval Structural Metric (prompt sections) | 16 | 69.6% |
| BATS Statement & Branch + Equivalence/Boundary (shell scripts) | 6 | 26.1% |
| YAML Schema Validation (`extension.yml`) | 1 | 4.3% |

## Uncovered Modules

None — all 23 active modules covered. The 4 DROP'd modules (MOD-022,
MOD-024, MOD-026, MOD-027) have DEFERRED placeholders per the
paradigm-shift contract; they do not exist at runtime and therefore
have no unit-testable surface.
