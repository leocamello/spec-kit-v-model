---
description: "TDD-ordered task list for feature/007-bridge-commands"
---

# Tasks: Bridge Commands (V-Model ↔ Spec-Kit Core)

<!-- v-model-enrichment: feature=007-bridge-commands -->

**Input**: V-Model artifacts from `specs/007-bridge-commands/v-model/`, Phase 2.1 outputs from `specs/007-bridge-commands/`
**Prerequisites**: All 8 V-Model artifacts approved; trace-matrix.md validated (Matrix A+B+C+D+H)
**Branch**: `feature/007-bridge-commands` | **Spec**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md)

**TDD Ordering (D-007 — NON-NEGOTIABLE)**: Write unit tests → Implement modules → Run unit tests → Write integration tests → Run integration tests → Write system tests → Run system tests → Write acceptance tests → Run acceptance tests

## Format: `[ID] [P?] [Tag] Description (Source: IDs)`

- **[P]**: Can run in parallel (different files, no shared state)
- **[US1]**: `v-model.implement` (P1) | **[US2]**: `v-model.plan` (P2) | **[US3]**: `v-model.tasks` (P2) | **[US4]**: Interop (P3)
- **[FOUND]**: Foundational/cross-cutting | **[POLISH]**: Polish phase
- Source IDs must be verifiable in `specs/007-bridge-commands/v-model/*.md`

---

## Phase 1: Setup

**Purpose**: Project initialization — create package structure, test infrastructure, and shared fixtures

- [ ] T001 Create project structure for `src/v_model_extension/` with 14 subdirectories (`commands/`, `emit/`, `tasks/`, `codegen/`, `testgen/`, `gate/`, `enrich/`, `guard/`, `overlay/`, `schema/`, `hooks/`, `report/`, `quality/`, `git/`, `io/`) and matching `__init__.py` files (Source: MOD-001..027, REQ-CN-001, ARCH-001..021)
- [ ] T002 Create test directory tree `tests/{unit,integration,system,acceptance}/test_bridge_commands/` and add `tests/fixtures/v_model_artifacts/` (Source: REQ-CN-001, ATP-NF-001)
- [ ] T003 Create `pyproject.toml` declaring runtime + dev deps (pytest, pytest-cov, mypy, ruff, jsonschema, pyyaml) and CLI entry points `v-model.plan`, `v-model.tasks`, `v-model.implement` (Source: SYS-001, SYS-002, SYS-003, REQ-IF-003)
- [ ] T004 Configure linting/typing baseline: `ruff.toml` and `mypy.ini` (strict for `src/v_model_extension/`) (Source: ATP-NF-001, REQ-CN-002)
- [ ] T005 Create shared pytest fixtures in `tests/conftest.py` (artifact loader fixture, tmp project fixture, ID-set fixture seeded from `specs/007-bridge-commands/v-model/*.md`) (Source: MOD-024, MOD-025, ARCH-019)
- [ ] T006 Add canonical V-Model artifact fixtures (valid + gap + phantom-ID variants) under `tests/fixtures/v_model_artifacts/` covering MOD-099/MOD-555/MOD-999 sentinel cases (Source: ATP-NF-002, UTS-013-A2)
- [ ] T007 Configure CI baseline workflow (lint + type-check + four-stack discovery) referencing the four-stack runner (Source: ATP-NF-001, ATP-IF-004)

---

## Phase 2: Foundational — Cross-Cutting Modules

**Purpose**: MOD-024..027 are foundational dependencies for ALL orchestrators; their write-test + implement + run-test cycle MUST complete before any user-story phase.

**⚠️ CRITICAL**: D-007 + Policy D mandates CC modules first. No US phase work until T016 checkpoint passes.

### 2a: Write Unit Tests for CC Modules

- [ ] T008 [P] [FOUND] Write unit tests UTP-024-A/B/C for MOD-024 `load_artifacts` in `tests/unit/test_bridge_commands/test_artifact_reader.py` (Source: UTP-024, MOD-024, ARCH-019)
- [ ] T009 [FOUND] Write unit tests UTP-025-A/B for MOD-025 `extract_id_set` in `tests/unit/test_bridge_commands/test_artifact_reader.py` (Source: UTP-025, MOD-025, ARCH-019)
- [ ] T010 [P] [FOUND] Write unit tests UTP-026-A/B/C for MOD-026 `run_subprocess` in `tests/unit/test_bridge_commands/test_subprocess_runner.py` (Source: UTP-026, MOD-026, ARCH-020)
- [ ] T011 [P] [FOUND] Write unit tests UTP-027-A/B/C for MOD-027 `atomic_write` in `tests/unit/test_bridge_commands/test_fs_writer.py` (Source: UTP-027, MOD-027, ARCH-021)

### 2b: Implement CC Modules

> ⚠️ Tests above MUST FAIL before implementing. Implement only after confirming test failures.

- [ ] T012 [P] [FOUND] Implement MOD-024 `load_artifacts` in `src/v_model_extension/io/artifact_reader.py` (Source: MOD-024, ARCH-019, REQ-001)
- [ ] T013 [FOUND] Implement MOD-025 `extract_id_set` in `src/v_model_extension/io/artifact_reader.py` (Source: MOD-025, ARCH-019, REQ-013)
- [ ] T014 [P] [FOUND] Implement MOD-026 `run_subprocess` in `src/v_model_extension/io/subprocess_runner.py` (Source: MOD-026, ARCH-020, REQ-NF-002)
- [ ] T015 [P] [FOUND] Implement MOD-027 `atomic_write` in `src/v_model_extension/io/fs_writer.py` (Source: MOD-027, ARCH-021, REQ-NF-005)

### 2c: Run CC Unit Tests

- [ ] T016 [FOUND] Run `pytest tests/unit/test_bridge_commands/test_artifact_reader.py tests/unit/test_bridge_commands/test_subprocess_runner.py tests/unit/test_bridge_commands/test_fs_writer.py -v` and confirm all CC unit tests pass (Source: UTP-024, UTP-025, UTP-026, UTP-027, ATP-NF-001)

**Checkpoint**: CC modules unit-tested and implemented → user-story phases may begin

---

## Phase 3: Write Unit Tests — All Non-CC Modules

**Purpose**: Per D-007, ALL unit tests MUST be written (and confirmed failing) before any module implementation in Phase 4 begins.

> ⚠️ Every task in this phase produces RED tests. Do NOT implement until Phase 4.

### 3a: User Story 1 — `v-model.implement` Modules

- [ ] T017 [P] [US1] Write unit tests UTP-005-A/B/C/D for MOD-005 `implement_orchestrator.run` in `tests/unit/test_bridge_commands/test_implement.py` (Source: UTP-005, MOD-005, ARCH-004, REQ-005)
- [ ] T018 [P] [US1] Write unit tests UTP-006-A/B for MOD-006 `generate_code` (dispatcher) in `tests/unit/test_bridge_commands/test_codegen.py` (Source: UTP-006, MOD-006, ARCH-005, REQ-006)
- [ ] T019 [US1] Write unit tests UTP-007-A/B for MOD-007 `render_module_source` in `tests/unit/test_bridge_commands/test_codegen.py` (Source: UTP-007, MOD-007, ARCH-005)
- [ ] T020 [P] [US1] Write unit tests UTP-008-A/B for MOD-008 `generate_tests` (dispatcher) in `tests/unit/test_bridge_commands/test_testgen.py` (Source: UTP-008, MOD-008, ARCH-006, REQ-007)
- [ ] T021 [US1] Write unit tests UTP-009-A/B for MOD-009 `render_test_file_for_level` in `tests/unit/test_bridge_commands/test_testgen.py` (Source: UTP-009, MOD-009, ARCH-006)
- [ ] T022 [P] [US1] Write unit tests UTP-010-A/B for MOD-010 `evaluate_gate` in `tests/unit/test_bridge_commands/test_gate.py` (Source: UTP-010, MOD-010, ARCH-007, REQ-009)
- [ ] T023 [US1] Add HAZ-010 verification test (gate refusal path) to `tests/unit/test_bridge_commands/test_gate.py` (Source: HAZ-010, MOD-010, ARCH-007)
- [ ] T024 [P] [US1] Write unit tests UTP-012-A/B for MOD-012 `embed_traceability_comments` in `tests/unit/test_bridge_commands/test_encoder.py` (Source: UTP-012, MOD-012, ARCH-008, REQ-014)
- [ ] T025 [P] [US1] Write unit tests UTP-013-A/B for MOD-013 `verify_ids` (Hallucination Guard) — including UTS-013-A2 phantom REQ-999 fixture — in `tests/unit/test_bridge_commands/test_guard.py` (Source: UTP-013, UTS-013, MOD-013, ARCH-009, REQ-013)
- [ ] T026 [US1] Add HAZ-007 verification test (guard blocks unknown ID) to `tests/unit/test_bridge_commands/test_guard.py` (Source: HAZ-007, MOD-013, ARCH-009)
- [ ] T027 [US1] Add HAZ-012 verification test (guard rejects malformed ID prefix) to `tests/unit/test_bridge_commands/test_guard.py` (Source: HAZ-012, MOD-013, ARCH-009)
- [ ] T028 [US1] Add HAZ-013 verification test (guard refuses partial ID set) to `tests/unit/test_bridge_commands/test_guard.py` (Source: HAZ-013, MOD-013, ARCH-009)
- [ ] T029 [P] [US1] Write unit tests UTP-014-A/B for MOD-014 `splice_managed_regions` in `tests/unit/test_bridge_commands/test_splicer.py` (Source: UTP-014, MOD-014, ARCH-010, REQ-010)
- [ ] T030 [P] [US1] Write unit tests UTP-023-A/B/C for MOD-023 `annotate_commit` in `tests/unit/test_bridge_commands/test_annotator.py` (Source: UTP-023, MOD-023, ARCH-018, REQ-022)

### 3b: User Story 2 — `v-model.plan` Modules

- [ ] T031 [P] [US2] Write unit tests UTP-001-A/B/C/D for MOD-001 `plan_orchestrator.run` in `tests/unit/test_bridge_commands/test_plan.py` (Source: UTP-001, MOD-001, ARCH-001, REQ-001)
- [ ] T032 [US2] Write unit tests UTP-002-A/B/C for MOD-002 `emit_canonical_outputs` in `tests/unit/test_bridge_commands/test_plan.py` (Source: UTP-002, MOD-002, ARCH-002, REQ-002)
- [ ] T033 [P] [US2] Write unit tests UTP-011-A/B for MOD-011 `embed_enrichment` in `tests/unit/test_bridge_commands/test_encoder.py` (Source: UTP-011, MOD-011, ARCH-008, REQ-014)
- [ ] T034 [US2] Add HAZ-011 verification test (enrichment block round-trip integrity) to `tests/unit/test_bridge_commands/test_encoder.py` (Source: HAZ-011, MOD-011, ARCH-008)
- [ ] T035 [P] [US2] Write unit tests UTP-017-A/B for MOD-017 `validate_plan_schema` in `tests/unit/test_bridge_commands/test_validator.py` (Source: UTP-017, MOD-017, ARCH-013, REQ-017)

### 3c: User Story 3 — `v-model.tasks` Modules

- [ ] T036 [P] [US3] Write unit tests UTP-003-A/B/C/D for MOD-003 `tasks_orchestrator.run` in `tests/unit/test_bridge_commands/test_tasks.py` (Source: UTP-003, MOD-003, ARCH-003, REQ-003)
- [ ] T037 [US3] Write unit tests UTP-004-A/B for MOD-004 `build_tdd_task_list` in `tests/unit/test_bridge_commands/test_tasks.py` (Source: UTP-004, MOD-004, ARCH-003, REQ-004)
- [ ] T038 [US3] Add HAZ-005 verification test (TDD ordering invariant) to `tests/unit/test_bridge_commands/test_tasks.py` (Source: HAZ-005, MOD-004, ARCH-003)
- [ ] T039 [P] [US3] Write unit tests UTP-016-A/B for MOD-016 `enrich_with_hazards` in `tests/unit/test_bridge_commands/test_hazards.py` (Source: UTP-016, MOD-016, ARCH-012, REQ-016)
- [ ] T040 [US3] Add HAZ-016 verification test (every HAZ produces a mitigation task) to `tests/unit/test_bridge_commands/test_hazards.py` (Source: HAZ-016, MOD-016, ARCH-012)
- [ ] T041 [P] [US3] Write unit tests UTP-018-A/B for MOD-018 `validate_tasks_schema` in `tests/unit/test_bridge_commands/test_validator.py` (Source: UTP-018, MOD-018, ARCH-013, REQ-018)

### 3d: User Story 4 / Shared Modules

- [ ] T042 [P] [US4] Write unit tests UTP-019-A/B for MOD-019 `detect_enrichment` in `tests/unit/test_bridge_commands/test_fallback.py` (Source: UTP-019, MOD-019, ARCH-014, REQ-019)
- [ ] T043 [P] [FOUND] Write unit tests UTP-015-A/B for MOD-015 `apply_overlay` in `tests/unit/test_bridge_commands/test_overlay.py` (Source: UTP-015, MOD-015, ARCH-011, REQ-015)
- [ ] T044 [FOUND] Add HAZ-024 verification test (overlay merges deterministically) to `tests/unit/test_bridge_commands/test_overlay.py` (Source: HAZ-024, MOD-015, ARCH-011)
- [ ] T045 [P] [FOUND] Write unit tests UTP-020-A/B for MOD-020 `register_hooks` in `tests/unit/test_bridge_commands/test_registrar.py` (Source: UTP-020, MOD-020, ARCH-015, REQ-020)
- [ ] T046 [P] [FOUND] Write unit tests UTP-021-A/B for MOD-021 `emit_summary` in `tests/unit/test_bridge_commands/test_summary.py` (Source: UTP-021, MOD-021, ARCH-016, REQ-021)
- [ ] T047 [FOUND] Add HAZ-020 verification test (summary contains all required fields incl. skipped artifacts) to `tests/unit/test_bridge_commands/test_summary.py` (Source: HAZ-020, MOD-021, ARCH-016)
- [ ] T048 [P] [FOUND] Write unit tests UTP-022-A/B for MOD-022 `compute_coverage_report` in `tests/unit/test_bridge_commands/test_harness.py` (Source: UTP-022, MOD-022, ARCH-017, REQ-NF-001)

---

## Phase 4: Implement Modules — All Non-CC (Dependency Order)

**Purpose**: Implement modules in leaf-first dependency order so each module's dependencies are ready

> ⚠️ Do NOT implement until Phase 3 unit tests are written AND confirmed failing.

### 4a: Layer 1 — Pure leaves

- [ ] T049 [P] [US2] Implement MOD-011 `embed_enrichment` in `src/v_model_extension/enrich/encoder.py` (Source: MOD-011, ARCH-008, REQ-014)
- [ ] T050 [US1] Implement MOD-012 `embed_traceability_comments` in `src/v_model_extension/enrich/encoder.py` (Source: MOD-012, ARCH-008, REQ-014)
- [ ] T051 [P] [US1] Implement MOD-014 `splice_managed_regions` in `src/v_model_extension/codegen/splicer.py` (Source: MOD-014, ARCH-010, REQ-010)
- [ ] T052 [P] [FOUND] Implement MOD-015 `apply_overlay` in `src/v_model_extension/overlay/loader.py` (Source: MOD-015, ARCH-011, REQ-015)
- [ ] T053 [P] [US3] Implement MOD-016 `enrich_with_hazards` in `src/v_model_extension/tasks/hazards.py` (Source: MOD-016, ARCH-012, REQ-016)
- [ ] T054 [P] [US2] Implement MOD-017 `validate_plan_schema` in `src/v_model_extension/schema/validator.py` (Source: MOD-017, ARCH-013, REQ-017)
- [ ] T055 [US3] Implement MOD-018 `validate_tasks_schema` in `src/v_model_extension/schema/validator.py` (Source: MOD-018, ARCH-013, REQ-018)
- [ ] T056 [P] [US4] Implement MOD-019 `detect_enrichment` in `src/v_model_extension/schema/fallback.py` (Source: MOD-019, ARCH-014, REQ-019)

### 4b: Layer 2 — Depends on CC

- [ ] T057 [P] [FOUND] Implement MOD-020 `register_hooks` in `src/v_model_extension/hooks/registrar.py` (depends MOD-026) (Source: MOD-020, ARCH-015, REQ-020)
- [ ] T058 [P] [FOUND] Implement MOD-021 `emit_summary` in `src/v_model_extension/report/summary.py` (depends MOD-027) (Source: MOD-021, ARCH-016, REQ-021)
- [ ] T059 [P] [FOUND] Implement MOD-022 `compute_coverage_report` in `src/v_model_extension/quality/harness.py` (depends MOD-026) (Source: MOD-022, ARCH-017, REQ-NF-001)
- [ ] T060 [P] [US1] Implement MOD-023 `annotate_commit` in `src/v_model_extension/git/annotator.py` (depends MOD-026) (Source: MOD-023, ARCH-018, REQ-022)

### 4c: Layer 3 — Depends on layers 0–2

- [ ] T061 [P] [US2] Implement MOD-002 `emit_canonical_outputs` in `src/v_model_extension/emit/canonical.py` (depends MOD-027) (Source: MOD-002, ARCH-002, REQ-002)
- [ ] T062 [P] [US1] Implement MOD-007 `render_module_source` in `src/v_model_extension/codegen/renderer.py` (Source: MOD-007, ARCH-005)
- [ ] T063 [P] [US1] Implement MOD-009 `render_test_file_for_level` in `src/v_model_extension/testgen/renderer.py` (Source: MOD-009, ARCH-006)
- [ ] T064 [P] [US1] Implement MOD-010 `evaluate_gate` in `src/v_model_extension/gate/coordinator.py` (depends MOD-026) (Source: MOD-010, ARCH-007, REQ-009)
- [ ] T065 [P] [US1] Implement MOD-013 `verify_ids` (Hallucination Guard) in `src/v_model_extension/guard/hallucination.py` (depends MOD-025) (Source: MOD-013, ARCH-009, REQ-013)

### 4d: Layer 4 — Depends on layers 0–3

- [ ] T066 [P] [US1] Implement MOD-006 `generate_code` (dispatcher) in `src/v_model_extension/codegen/generator.py` (depends MOD-007, MOD-012, MOD-013, MOD-014) (Source: MOD-006, ARCH-005, REQ-006)
- [ ] T067 [P] [US1] Implement MOD-008 `generate_tests` (dispatcher) in `src/v_model_extension/testgen/generator.py` (depends MOD-009) (Source: MOD-008, ARCH-006, REQ-007)
- [ ] T068 [P] [US3] Implement MOD-004 `build_tdd_task_list` in `src/v_model_extension/tasks/sequencer.py` (depends MOD-024, MOD-016) (Source: MOD-004, ARCH-003, REQ-004)

### 4e: Layer 5 — Orchestrators

- [ ] T069 [P] [US2] Implement MOD-001 `plan_orchestrator.run` in `src/v_model_extension/commands/plan.py` (depends MOD-002, MOD-011, MOD-017, MOD-021, MOD-024) (Source: MOD-001, ARCH-001, REQ-001)
- [ ] T070 [P] [US3] Implement MOD-003 `tasks_orchestrator.run` in `src/v_model_extension/commands/tasks.py` (depends MOD-004, MOD-018, MOD-021, MOD-024) (Source: MOD-003, ARCH-003, REQ-003)
- [ ] T071 [P] [US1] Implement MOD-005 `implement_orchestrator.run` in `src/v_model_extension/commands/implement.py` (depends MOD-006, MOD-008, MOD-010, MOD-021, MOD-024) (Source: MOD-005, ARCH-004, REQ-005)

---

## Phase 5: Run All Unit Tests

- [ ] T072 Run `pytest tests/unit/test_bridge_commands/ -v --cov=src/v_model_extension --cov-report=term-missing` and confirm 27 MOD unit suites pass with green hazard verifications (Source: UTP-001..027, HAZ-005, HAZ-007, HAZ-010..013, HAZ-016, HAZ-020, HAZ-024, ATP-NF-001)

**Checkpoint**: All 27 MOD unit test suites GREEN → integration test phase may begin

---

## Phase 6: Write Integration Tests — By ARCH Seam

**Purpose**: Per D-007, integration tests written AFTER unit tests pass but BEFORE implementation is considered integration-complete

### 6a: CC/Foundational ARCH Seams (ARCH-019..021)

- [ ] T073 [P] [FOUND] Write integration scenario ITS-019-A1 in `tests/integration/test_bridge_commands/test_arch_019_artifact_reader.py` (Source: ITS-019, ARCH-019, MOD-024, MOD-025)
- [ ] T074 [FOUND] Write integration scenario ITS-019-A2 in `tests/integration/test_bridge_commands/test_arch_019_artifact_reader.py` (Source: ITS-019, ARCH-019, MOD-024)
- [ ] T075 [FOUND] Write integration scenario ITS-019-B1 in `tests/integration/test_bridge_commands/test_arch_019_artifact_reader.py` (Source: ITS-019, ARCH-019, MOD-025)
- [ ] T076 [FOUND] Write integration scenario ITS-019-C1 in `tests/integration/test_bridge_commands/test_arch_019_artifact_reader.py` (Source: ITS-019, ARCH-019)
- [ ] T077 [FOUND] Write integration scenario ITS-019-C2 in `tests/integration/test_bridge_commands/test_arch_019_artifact_reader.py` (Source: ITS-019, ARCH-019)
- [ ] T078 [FOUND] Write integration scenario ITS-019-C3 in `tests/integration/test_bridge_commands/test_arch_019_artifact_reader.py` (Source: ITS-019, ARCH-019)
- [ ] T079 [FOUND] Add HAZ-023 verification (artifact-read partial-failure handling) to `tests/integration/test_bridge_commands/test_arch_019_artifact_reader.py` (Source: HAZ-023, ARCH-019, MOD-024)
- [ ] T080 [P] [FOUND] Write integration scenario ITS-020-A1 in `tests/integration/test_bridge_commands/test_arch_020_subprocess_runner.py` (Source: ITS-020, ARCH-020, MOD-026)
- [ ] T081 [FOUND] Write integration scenario ITS-020-B1 in `tests/integration/test_bridge_commands/test_arch_020_subprocess_runner.py` (Source: ITS-020, ARCH-020)
- [ ] T082 [FOUND] Write integration scenario ITS-020-B2 in `tests/integration/test_bridge_commands/test_arch_020_subprocess_runner.py` (Source: ITS-020, ARCH-020)
- [ ] T083 [FOUND] Write integration scenario ITS-020-C1 in `tests/integration/test_bridge_commands/test_arch_020_subprocess_runner.py` (Source: ITS-020, ARCH-020)
- [ ] T084 [FOUND] Write integration scenario ITS-020-C2 in `tests/integration/test_bridge_commands/test_arch_020_subprocess_runner.py` (Source: ITS-020, ARCH-020)
- [ ] T085 [FOUND] Write integration scenario ITS-020-C3 in `tests/integration/test_bridge_commands/test_arch_020_subprocess_runner.py` (Source: ITS-020, ARCH-020)
- [ ] T086 [FOUND] Write integration scenario ITS-020-D1 in `tests/integration/test_bridge_commands/test_arch_020_subprocess_runner.py` (Source: ITS-020, ARCH-020)
- [ ] T087 [P] [FOUND] Write integration scenario ITS-021-A1 in `tests/integration/test_bridge_commands/test_arch_021_atomic_writer.py` (Source: ITS-021, ARCH-021, MOD-027)
- [ ] T088 [FOUND] Write integration scenario ITS-021-B1 in `tests/integration/test_bridge_commands/test_arch_021_atomic_writer.py` (Source: ITS-021, ARCH-021)
- [ ] T089 [FOUND] Write integration scenario ITS-021-B2 in `tests/integration/test_bridge_commands/test_arch_021_atomic_writer.py` (Source: ITS-021, ARCH-021)
- [ ] T090 [FOUND] Write integration scenario ITS-021-D1 in `tests/integration/test_bridge_commands/test_arch_021_atomic_writer.py` (Source: ITS-021, ARCH-021)
- [ ] T091 [FOUND] Write integration scenario ITS-021-D2 in `tests/integration/test_bridge_commands/test_arch_021_atomic_writer.py` (Source: ITS-021, ARCH-021)
- [ ] T092 [FOUND] Add HAZ-025 verification (atomic-write crash safety) to `tests/integration/test_bridge_commands/test_arch_021_atomic_writer.py` (Source: HAZ-025, ARCH-021, MOD-027)

### 6b: User Story 2 — `v-model.plan` ARCH Seams

- [ ] T093 [P] [US2] Write integration scenario ITS-001-A1 in `tests/integration/test_bridge_commands/test_arch_001_plan_orchestrator.py` (Source: ITS-001, ARCH-001, MOD-001)
- [ ] T094 [US2] Write integration scenario ITS-001-A2 in `tests/integration/test_bridge_commands/test_arch_001_plan_orchestrator.py` (Source: ITS-001, ARCH-001)
- [ ] T095 [US2] Write integration scenario ITS-001-A3 in `tests/integration/test_bridge_commands/test_arch_001_plan_orchestrator.py` (Source: ITS-001, ARCH-001)
- [ ] T096 [US2] Write integration scenario ITS-001-B1 in `tests/integration/test_bridge_commands/test_arch_001_plan_orchestrator.py` (Source: ITS-001, ARCH-001)
- [ ] T097 [US2] Write integration scenario ITS-001-B2 in `tests/integration/test_bridge_commands/test_arch_001_plan_orchestrator.py` (Source: ITS-001, ARCH-001)
- [ ] T098 [P] [US2] Write integration scenario ITS-002-A1 in `tests/integration/test_bridge_commands/test_arch_002_canonical_emitter.py` (Source: ITS-002, ARCH-002, MOD-002)
- [ ] T099 [US2] Write integration scenario ITS-002-A2 in `tests/integration/test_bridge_commands/test_arch_002_canonical_emitter.py` (Source: ITS-002, ARCH-002)
- [ ] T100 [US2] Write integration scenario ITS-002-B1 in `tests/integration/test_bridge_commands/test_arch_002_canonical_emitter.py` (Source: ITS-002, ARCH-002)
- [ ] T101 [P] [US2] Write integration scenario ITS-008-A1 in `tests/integration/test_bridge_commands/test_arch_008_enrichment_encoder.py` (Source: ITS-008, ARCH-008, MOD-011)
- [ ] T102 [US2] Write integration scenario ITS-008-A2 in `tests/integration/test_bridge_commands/test_arch_008_enrichment_encoder.py` (Source: ITS-008, ARCH-008)
- [ ] T103 [US2] Write integration scenario ITS-008-B1 in `tests/integration/test_bridge_commands/test_arch_008_enrichment_encoder.py` (Source: ITS-008, ARCH-008)
- [ ] T104 [US2] Add HAZ-002 verification (enrichment block survives upstream re-emission) to `tests/integration/test_bridge_commands/test_arch_008_enrichment_encoder.py` (Source: HAZ-002, ARCH-008, MOD-011)
- [ ] T105 [P] [US2] Write integration scenario ITS-013-A1 in `tests/integration/test_bridge_commands/test_arch_013_schema_validator.py` (Source: ITS-013, ARCH-013, MOD-017)
- [ ] T106 [US2] Write integration scenario ITS-013-A2 in `tests/integration/test_bridge_commands/test_arch_013_schema_validator.py` (Source: ITS-013, ARCH-013)
- [ ] T107 [US2] Add HAZ-017 verification (schema-version skew detected) to `tests/integration/test_bridge_commands/test_arch_013_schema_validator.py` (Source: HAZ-017, ARCH-013, MOD-017)

### 6c: User Story 3 — `v-model.tasks` ARCH Seams

- [ ] T108 [P] [US3] Write integration scenario ITS-003-A1 in `tests/integration/test_bridge_commands/test_arch_003_tasks_orchestrator.py` (Source: ITS-003, ARCH-003, MOD-003)
- [ ] T109 [US3] Write integration scenario ITS-003-A2 in `tests/integration/test_bridge_commands/test_arch_003_tasks_orchestrator.py` (Source: ITS-003, ARCH-003)
- [ ] T110 [US3] Write integration scenario ITS-003-B1 in `tests/integration/test_bridge_commands/test_arch_003_tasks_orchestrator.py` (Source: ITS-003, ARCH-003)
- [ ] T111 [US3] Write integration scenario ITS-003-B2 in `tests/integration/test_bridge_commands/test_arch_003_tasks_orchestrator.py` (Source: ITS-003, ARCH-003)
- [ ] T112 [US3] Write integration scenario ITS-003-C1 in `tests/integration/test_bridge_commands/test_arch_003_tasks_orchestrator.py` (Source: ITS-003, ARCH-003)
- [ ] T113 [US3] Write integration scenario ITS-003-C2 in `tests/integration/test_bridge_commands/test_arch_003_tasks_orchestrator.py` (Source: ITS-003, ARCH-003)
- [ ] T114 [P] [US3] Write integration scenario ITS-012-A1 in `tests/integration/test_bridge_commands/test_arch_012_hazard_injector.py` (Source: ITS-012, ARCH-012, MOD-016)
- [ ] T115 [US3] Write integration scenario ITS-012-A2 in `tests/integration/test_bridge_commands/test_arch_012_hazard_injector.py` (Source: ITS-012, ARCH-012)
- [ ] T116 [US3] Write integration scenario ITS-012-B1 in `tests/integration/test_bridge_commands/test_arch_012_hazard_injector.py` (Source: ITS-012, ARCH-012)

### 6d: User Story 1 — `v-model.implement` ARCH Seams

- [ ] T117 [P] [US1] Write integration scenario ITS-004-A1 in `tests/integration/test_bridge_commands/test_arch_004_implementation_orchestrator.py` (Source: ITS-004, ARCH-004, MOD-005)
- [ ] T118 [US1] Write integration scenario ITS-004-A2 in `tests/integration/test_bridge_commands/test_arch_004_implementation_orchestrator.py` (Source: ITS-004, ARCH-004)
- [ ] T119 [US1] Write integration scenario ITS-004-B1 in `tests/integration/test_bridge_commands/test_arch_004_implementation_orchestrator.py` (Source: ITS-004, ARCH-004)
- [ ] T120 [US1] Write integration scenario ITS-004-B2 in `tests/integration/test_bridge_commands/test_arch_004_implementation_orchestrator.py` (Source: ITS-004, ARCH-004)
- [ ] T121 [US1] Write integration scenario ITS-004-B3 in `tests/integration/test_bridge_commands/test_arch_004_implementation_orchestrator.py` (Source: ITS-004, ARCH-004)
- [ ] T122 [US1] Write integration scenario ITS-004-D1 in `tests/integration/test_bridge_commands/test_arch_004_implementation_orchestrator.py` (Source: ITS-004, ARCH-004)
- [ ] T123 [US1] Write integration scenario ITS-004-D2 in `tests/integration/test_bridge_commands/test_arch_004_implementation_orchestrator.py` (Source: ITS-004, ARCH-004)
- [ ] T124 [P] [US1] Write integration scenario ITS-005-A1 in `tests/integration/test_bridge_commands/test_arch_005_code_generator.py` (Source: ITS-005, ARCH-005, MOD-006)
- [ ] T125 [US1] Write integration scenario ITS-005-A2 in `tests/integration/test_bridge_commands/test_arch_005_code_generator.py` (Source: ITS-005, ARCH-005)
- [ ] T126 [US1] Write integration scenario ITS-005-B1 in `tests/integration/test_bridge_commands/test_arch_005_code_generator.py` (Source: ITS-005, ARCH-005)
- [ ] T127 [US1] Write integration scenario ITS-005-C1 in `tests/integration/test_bridge_commands/test_arch_005_code_generator.py` (Source: ITS-005, ARCH-005)
- [ ] T128 [US1] Write integration scenario ITS-005-C2 in `tests/integration/test_bridge_commands/test_arch_005_code_generator.py` (Source: ITS-005, ARCH-005)
- [ ] T129 [P] [US1] Write integration scenario ITS-006-A1 in `tests/integration/test_bridge_commands/test_arch_006_test_generator.py` (Source: ITS-006, ARCH-006, MOD-008)
- [ ] T130 [US1] Write integration scenario ITS-006-A2 in `tests/integration/test_bridge_commands/test_arch_006_test_generator.py` (Source: ITS-006, ARCH-006)
- [ ] T131 [P] [US1] Write integration scenario ITS-007-A1 in `tests/integration/test_bridge_commands/test_arch_007_pre_implementation_gate.py` (Source: ITS-007, ARCH-007, MOD-010)
- [ ] T132 [US1] Write integration scenario ITS-007-A2 in `tests/integration/test_bridge_commands/test_arch_007_pre_implementation_gate.py` (Source: ITS-007, ARCH-007)
- [ ] T133 [US1] Write integration scenario ITS-007-B1 in `tests/integration/test_bridge_commands/test_arch_007_pre_implementation_gate.py` (Source: ITS-007, ARCH-007)
- [ ] T134 [US1] Add HAZ-009 verification (gate refuses incomplete trace matrix) to `tests/integration/test_bridge_commands/test_arch_007_pre_implementation_gate.py` (Source: HAZ-009, ARCH-007, MOD-010)
- [ ] T135 [P] [US1] Write integration scenario ITS-009-A1 in `tests/integration/test_bridge_commands/test_arch_009_hallucination_guard.py` (Source: ITS-009, ARCH-009, MOD-013)
- [ ] T136 [US1] Write integration scenario ITS-009-A2 in `tests/integration/test_bridge_commands/test_arch_009_hallucination_guard.py` (Source: ITS-009, ARCH-009)
- [ ] T137 [P] [US1] Write integration scenario ITS-010-A1 in `tests/integration/test_bridge_commands/test_arch_010_source_region_manager.py` (Source: ITS-010, ARCH-010, MOD-014)
- [ ] T138 [US1] Write integration scenario ITS-010-B1 in `tests/integration/test_bridge_commands/test_arch_010_source_region_manager.py` (Source: ITS-010, ARCH-010)
- [ ] T139 [US1] Add HAZ-014 verification (managed-region splice preserves hand edits) to `tests/integration/test_bridge_commands/test_arch_010_source_region_manager.py` (Source: HAZ-014, ARCH-010, MOD-014)
- [ ] T140 [P] [US1] Write integration scenario ITS-018-A1 in `tests/integration/test_bridge_commands/test_arch_018_commit_annotator.py` (Source: ITS-018, ARCH-018, MOD-023)
- [ ] T141 [US1] Write integration scenario ITS-018-A2 in `tests/integration/test_bridge_commands/test_arch_018_commit_annotator.py` (Source: ITS-018, ARCH-018)
- [ ] T142 [US1] Add HAZ-022 verification (commit annotation contains all V-Model IDs touched) to `tests/integration/test_bridge_commands/test_arch_018_commit_annotator.py` (Source: HAZ-022, ARCH-018, MOD-023)

### 6e: User Story 4 / Shared ARCH Seams

- [ ] T143 [P] [FOUND] Write integration scenario ITS-011-A1 in `tests/integration/test_bridge_commands/test_arch_011_overlay_loader.py` (Source: ITS-011, ARCH-011, MOD-015)
- [ ] T144 [FOUND] Write integration scenario ITS-011-B1 in `tests/integration/test_bridge_commands/test_arch_011_overlay_loader.py` (Source: ITS-011, ARCH-011)
- [ ] T145 [P] [US4] Write integration scenario ITS-014-A1 in `tests/integration/test_bridge_commands/test_arch_014_fallback_detector.py` (Source: ITS-014, ARCH-014, MOD-019)
- [ ] T146 [US4] Write integration scenario ITS-014-A2 in `tests/integration/test_bridge_commands/test_arch_014_fallback_detector.py` (Source: ITS-014, ARCH-014)
- [ ] T147 [P] [FOUND] Write integration scenario ITS-015-A1 in `tests/integration/test_bridge_commands/test_arch_015_hook_registrar.py` (Source: ITS-015, ARCH-015, MOD-020)
- [ ] T148 [FOUND] Write integration scenario ITS-015-A2 in `tests/integration/test_bridge_commands/test_arch_015_hook_registrar.py` (Source: ITS-015, ARCH-015)
- [ ] T149 [FOUND] Write integration scenario ITS-015-B1 in `tests/integration/test_bridge_commands/test_arch_015_hook_registrar.py` (Source: ITS-015, ARCH-015)
- [ ] T150 [FOUND] Add HAZ-019 verification (hook registration is idempotent across re-runs) to `tests/integration/test_bridge_commands/test_arch_015_hook_registrar.py` (Source: HAZ-019, ARCH-015, MOD-020)
- [ ] T151 [P] [FOUND] Write integration scenario ITS-016-A1 in `tests/integration/test_bridge_commands/test_arch_016_summary_reporter.py` (Source: ITS-016, ARCH-016, MOD-021)
- [ ] T152 [FOUND] Write integration scenario ITS-016-A2 in `tests/integration/test_bridge_commands/test_arch_016_summary_reporter.py` (Source: ITS-016, ARCH-016)
- [ ] T153 [P] [FOUND] Write integration scenario ITS-017-A1 in `tests/integration/test_bridge_commands/test_arch_017_compliance_harness.py` (Source: ITS-017, ARCH-017, MOD-022)
- [ ] T154 [FOUND] Write integration scenario ITS-017-A2 in `tests/integration/test_bridge_commands/test_arch_017_compliance_harness.py` (Source: ITS-017, ARCH-017)

---

## Phase 7: Run Integration Tests

- [ ] T155 Run `pytest tests/integration/test_bridge_commands/ -v` and confirm all 74 ITS scenarios + 8 HAZ verifications pass (Source: ITS-001..021, HAZ-002, HAZ-009, HAZ-014, HAZ-017, HAZ-019, HAZ-022, HAZ-023, HAZ-025)

**Checkpoint**: All 74 ITS scenarios GREEN → system test phase may begin

---

## Phase 8: Write System Tests — By SYS Component

### 8a: SYS-001 Plan Synthesizer (US2)

- [ ] T156 [P] [US2] Write system scenario STS-001-A1 in `tests/system/test_bridge_commands/test_sys_001_plan_synthesizer.py` (Source: STS-001, SYS-001)
- [ ] T157 [US2] Write system scenario STS-001-A2 in `tests/system/test_bridge_commands/test_sys_001_plan_synthesizer.py` (Source: STS-001, SYS-001)
- [ ] T158 [US2] Write system scenario STS-001-B1 in `tests/system/test_bridge_commands/test_sys_001_plan_synthesizer.py` (Source: STS-001, SYS-001)
- [ ] T159 [US2] Write system scenario STS-001-B2 in `tests/system/test_bridge_commands/test_sys_001_plan_synthesizer.py` (Source: STS-001, SYS-001)
- [ ] T160 [US2] Write system scenario STS-001-C1 in `tests/system/test_bridge_commands/test_sys_001_plan_synthesizer.py` (Source: STS-001, SYS-001)
- [ ] T161 [US2] Write system scenario STS-001-C2 in `tests/system/test_bridge_commands/test_sys_001_plan_synthesizer.py` (Source: STS-001, SYS-001)
- [ ] T162 [US2] Add HAZ-003 verification (plan emission failure surfaces as actionable error) to `tests/system/test_bridge_commands/test_sys_001_plan_synthesizer.py` (Source: HAZ-003, SYS-001)

### 8b: SYS-002 Tasks Synthesizer (US3)

- [ ] T163 [P] [US3] Write system scenario STS-002-A1 in `tests/system/test_bridge_commands/test_sys_002_tasks_synthesizer.py` (Source: STS-002, SYS-002)
- [ ] T164 [US3] Write system scenario STS-002-A2 in `tests/system/test_bridge_commands/test_sys_002_tasks_synthesizer.py` (Source: STS-002, SYS-002)
- [ ] T165 [US3] Write system scenario STS-002-B1 in `tests/system/test_bridge_commands/test_sys_002_tasks_synthesizer.py` (Source: STS-002, SYS-002)
- [ ] T166 [US3] Write system scenario STS-002-B2 in `tests/system/test_bridge_commands/test_sys_002_tasks_synthesizer.py` (Source: STS-002, SYS-002)
- [ ] T167 [US3] Write system scenario STS-002-C1 in `tests/system/test_bridge_commands/test_sys_002_tasks_synthesizer.py` (Source: STS-002, SYS-002)
- [ ] T168 [US3] Write system scenario STS-002-C2 in `tests/system/test_bridge_commands/test_sys_002_tasks_synthesizer.py` (Source: STS-002, SYS-002)

### 8c: SYS-003 Implementation Engine (US1)

- [ ] T169 [P] [US1] Write system scenario STS-003-A1 in `tests/system/test_bridge_commands/test_sys_003_implementation_engine.py` (Source: STS-003, SYS-003)
- [ ] T170 [US1] Write system scenario STS-003-A2 in `tests/system/test_bridge_commands/test_sys_003_implementation_engine.py` (Source: STS-003, SYS-003)
- [ ] T171 [US1] Write system scenario STS-003-B1 in `tests/system/test_bridge_commands/test_sys_003_implementation_engine.py` (Source: STS-003, SYS-003)
- [ ] T172 [US1] Write system scenario STS-003-B2 in `tests/system/test_bridge_commands/test_sys_003_implementation_engine.py` (Source: STS-003, SYS-003)
- [ ] T173 [US1] Write system scenario STS-003-B3 in `tests/system/test_bridge_commands/test_sys_003_implementation_engine.py` (Source: STS-003, SYS-003)
- [ ] T174 [US1] Write system scenario STS-003-C1 in `tests/system/test_bridge_commands/test_sys_003_implementation_engine.py` (Source: STS-003, SYS-003)
- [ ] T175 [US1] Write system scenario STS-003-C2 in `tests/system/test_bridge_commands/test_sys_003_implementation_engine.py` (Source: STS-003, SYS-003)
- [ ] T176 [US1] Write system scenario STS-003-C3 in `tests/system/test_bridge_commands/test_sys_003_implementation_engine.py` (Source: STS-003, SYS-003)
- [ ] T177 [US1] Write system scenario STS-003-C4 in `tests/system/test_bridge_commands/test_sys_003_implementation_engine.py` (Source: STS-003, SYS-003)

### 8d: SYS-004 Pre-Implementation Gate (US1)

- [ ] T178 [P] [US1] Write system scenario STS-004-A1 in `tests/system/test_bridge_commands/test_sys_004_pre_implementation_gate.py` (Source: STS-004, SYS-004)
- [ ] T179 [US1] Write system scenario STS-004-A2 in `tests/system/test_bridge_commands/test_sys_004_pre_implementation_gate.py` (Source: STS-004, SYS-004)
- [ ] T180 [US1] Write system scenario STS-004-B1 in `tests/system/test_bridge_commands/test_sys_004_pre_implementation_gate.py` (Source: STS-004, SYS-004)
- [ ] T181 [US1] Write system scenario STS-004-B2 in `tests/system/test_bridge_commands/test_sys_004_pre_implementation_gate.py` (Source: STS-004, SYS-004)
- [ ] T182 [US1] Write system scenario STS-004-B3 in `tests/system/test_bridge_commands/test_sys_004_pre_implementation_gate.py` (Source: STS-004, SYS-004)

### 8e: SYS-005 Additive Enrichment Encoder (US2/US3)

- [ ] T183 [P] [US2] Write system scenario STS-005-A1 in `tests/system/test_bridge_commands/test_sys_005_enrichment_encoder.py` (Source: STS-005, SYS-005)
- [ ] T184 [US2] Write system scenario STS-005-A2 in `tests/system/test_bridge_commands/test_sys_005_enrichment_encoder.py` (Source: STS-005, SYS-005)
- [ ] T185 [US2] Write system scenario STS-005-B1 in `tests/system/test_bridge_commands/test_sys_005_enrichment_encoder.py` (Source: STS-005, SYS-005)
- [ ] T186 [US2] Write system scenario STS-005-B2 in `tests/system/test_bridge_commands/test_sys_005_enrichment_encoder.py` (Source: STS-005, SYS-005)

### 8f: SYS-006 Hallucination Guard (US1)

- [ ] T187 [P] [US1] Write system scenario STS-006-A1 in `tests/system/test_bridge_commands/test_sys_006_hallucination_guard.py` (Source: STS-006, SYS-006)
- [ ] T188 [US1] Write system scenario STS-006-A2 in `tests/system/test_bridge_commands/test_sys_006_hallucination_guard.py` (Source: STS-006, SYS-006)
- [ ] T189 [US1] Write system scenario STS-006-B1 in `tests/system/test_bridge_commands/test_sys_006_hallucination_guard.py` (Source: STS-006, SYS-006)
- [ ] T190 [US1] Write system scenario STS-006-B2 in `tests/system/test_bridge_commands/test_sys_006_hallucination_guard.py` (Source: STS-006, SYS-006)
- [ ] T191 [US1] Write system scenario STS-006-B3 in `tests/system/test_bridge_commands/test_sys_006_hallucination_guard.py` (Source: STS-006, SYS-006)

### 8g: SYS-007 Source Region Manager (US1)

- [ ] T192 [P] [US1] Write system scenario STS-007-A1 in `tests/system/test_bridge_commands/test_sys_007_source_region_manager.py` (Source: STS-007, SYS-007)
- [ ] T193 [US1] Write system scenario STS-007-A2 in `tests/system/test_bridge_commands/test_sys_007_source_region_manager.py` (Source: STS-007, SYS-007)
- [ ] T194 [US1] Write system scenario STS-007-A3 in `tests/system/test_bridge_commands/test_sys_007_source_region_manager.py` (Source: STS-007, SYS-007)
- [ ] T195 [US1] Write system scenario STS-007-B1 in `tests/system/test_bridge_commands/test_sys_007_source_region_manager.py` (Source: STS-007, SYS-007)
- [ ] T196 [US1] Write system scenario STS-007-B2 in `tests/system/test_bridge_commands/test_sys_007_source_region_manager.py` (Source: STS-007, SYS-007)
- [ ] T197 [US1] Add HAZ-008 verification (managed-region marker tampering surfaces as error) to `tests/system/test_bridge_commands/test_sys_007_source_region_manager.py` (Source: HAZ-008, SYS-007)

### 8h: SYS-008 Domain Overlay Handler (FOUND)

- [ ] T198 [P] [FOUND] Write system scenario STS-008-A1 in `tests/system/test_bridge_commands/test_sys_008_domain_overlay.py` (Source: STS-008, SYS-008)
- [ ] T199 [FOUND] Write system scenario STS-008-A2 in `tests/system/test_bridge_commands/test_sys_008_domain_overlay.py` (Source: STS-008, SYS-008)
- [ ] T200 [FOUND] Write system scenario STS-008-B1 in `tests/system/test_bridge_commands/test_sys_008_domain_overlay.py` (Source: STS-008, SYS-008)
- [ ] T201 [FOUND] Add HAZ-015 verification (overlay collisions detected and refused) to `tests/system/test_bridge_commands/test_sys_008_domain_overlay.py` (Source: HAZ-015, SYS-008)

### 8i: SYS-009 Hazard Enrichment Injector (US3)

- [ ] T202 [P] [US3] Write system scenario STS-009-A1 in `tests/system/test_bridge_commands/test_sys_009_hazard_injector.py` (Source: STS-009, SYS-009)

### 8j: SYS-010 Schema Compatibility Layer (US2/US3/US4)

- [ ] T203 [P] [US4] Write system scenario STS-010-A1 in `tests/system/test_bridge_commands/test_sys_010_schema_compatibility.py` (Source: STS-010, SYS-010)
- [ ] T204 [US4] Write system scenario STS-010-A2 in `tests/system/test_bridge_commands/test_sys_010_schema_compatibility.py` (Source: STS-010, SYS-010)
- [ ] T205 [US4] Write system scenario STS-010-A3 in `tests/system/test_bridge_commands/test_sys_010_schema_compatibility.py` (Source: STS-010, SYS-010)
- [ ] T206 [US4] Write system scenario STS-010-B1 in `tests/system/test_bridge_commands/test_sys_010_schema_compatibility.py` (Source: STS-010, SYS-010)
- [ ] T207 [US4] Write system scenario STS-010-B2 in `tests/system/test_bridge_commands/test_sys_010_schema_compatibility.py` (Source: STS-010, SYS-010)
- [ ] T208 [US4] Write system scenario STS-010-C1 in `tests/system/test_bridge_commands/test_sys_010_schema_compatibility.py` (Source: STS-010, SYS-010)

### 8k: SYS-011 Hook Integration Connector (FOUND)

- [ ] T209 [P] [FOUND] Write system scenario STS-011-A1 in `tests/system/test_bridge_commands/test_sys_011_hook_connector.py` (Source: STS-011, SYS-011)
- [ ] T210 [FOUND] Write system scenario STS-011-A2 in `tests/system/test_bridge_commands/test_sys_011_hook_connector.py` (Source: STS-011, SYS-011)

### 8l: SYS-012 Run Summary Reporter (FOUND)

- [ ] T211 [P] [FOUND] Write system scenario STS-012-A1 in `tests/system/test_bridge_commands/test_sys_012_summary_reporter.py` (Source: STS-012, SYS-012)
- [ ] T212 [FOUND] Write system scenario STS-012-A2 in `tests/system/test_bridge_commands/test_sys_012_summary_reporter.py` (Source: STS-012, SYS-012)

### 8m: SYS-013 Quality & Process Compliance Harness (FOUND)

- [ ] T213 [P] [FOUND] Write system scenario STS-013-A1 in `tests/system/test_bridge_commands/test_sys_013_compliance_harness.py` (Source: STS-013, SYS-013)
- [ ] T214 [FOUND] Write system scenario STS-013-A2 in `tests/system/test_bridge_commands/test_sys_013_compliance_harness.py` (Source: STS-013, SYS-013)
- [ ] T215 [FOUND] Write system scenario STS-013-B1 in `tests/system/test_bridge_commands/test_sys_013_compliance_harness.py` (Source: STS-013, SYS-013)
- [ ] T216 [FOUND] Write system scenario STS-013-B2 in `tests/system/test_bridge_commands/test_sys_013_compliance_harness.py` (Source: STS-013, SYS-013)

### 8n: SYS-014 Commit Tracer (US1)

- [ ] T217 [P] [US1] Write system scenario STS-014-A1 in `tests/system/test_bridge_commands/test_sys_014_commit_tracer.py` (Source: STS-014, SYS-014)
- [ ] T218 [US1] Write system scenario STS-014-A2 in `tests/system/test_bridge_commands/test_sys_014_commit_tracer.py` (Source: STS-014, SYS-014)

---

## Phase 9: Run System Tests

- [ ] T219 Run `pytest tests/system/test_bridge_commands/ -v` and confirm all 60 STS scenarios + 3 HAZ verifications pass (Source: STS-001..014, HAZ-003, HAZ-008, HAZ-015)

**Checkpoint**: All 60 STS scenarios GREEN → acceptance test phase may begin

---

## Phase 10: Write Acceptance Tests — By User Story

### 10a: User Story 2 — `v-model.plan` (P2)

- [ ] T220 [P] [US2] Write acceptance test ATP-001-A in `tests/acceptance/test_bridge_commands/test_v_model_plan.py` (Source: ATP-001, SCN-001, REQ-001)
- [ ] T221 [US2] Write acceptance test ATP-001-B in `tests/acceptance/test_bridge_commands/test_v_model_plan.py` (Source: ATP-001, SCN-001, REQ-001)
- [ ] T222 [US2] Write acceptance test ATP-002-A in `tests/acceptance/test_bridge_commands/test_v_model_plan.py` (Source: ATP-002, SCN-002, REQ-002)
- [ ] T223 [US2] Write acceptance test ATP-002-B in `tests/acceptance/test_bridge_commands/test_v_model_plan.py` (Source: ATP-002, SCN-002, REQ-002)
- [ ] T224 [US2] Write acceptance test ATP-003-A in `tests/acceptance/test_bridge_commands/test_v_model_plan.py` (Source: ATP-003, SCN-003, REQ-003)
- [ ] T225 [US2] Write acceptance test ATP-004-A in `tests/acceptance/test_bridge_commands/test_v_model_plan.py` (Source: ATP-004, SCN-004, REQ-004)
- [ ] T226 [US2] Write acceptance test ATP-005-A in `tests/acceptance/test_bridge_commands/test_v_model_plan.py` (Source: ATP-005, SCN-005, REQ-005)
- [ ] T227 [US2] Write acceptance test ATP-006-A in `tests/acceptance/test_bridge_commands/test_v_model_plan.py` (Source: ATP-006, SCN-006, REQ-006)
- [ ] T228 [US2] Write acceptance test ATP-007-A in `tests/acceptance/test_bridge_commands/test_v_model_plan.py` (Source: ATP-007, SCN-007, REQ-007)
- [ ] T229 [US2] Write acceptance test ATP-007-B in `tests/acceptance/test_bridge_commands/test_v_model_plan.py` (Source: ATP-007, SCN-007, REQ-007)
- [ ] T230 [US2] Write acceptance test ATP-008-A in `tests/acceptance/test_bridge_commands/test_v_model_plan.py` (Source: ATP-008, SCN-008, REQ-008)
- [ ] T231 [US2] Add HAZ-001 verification (missing optional artifact does not abort plan synth) to `tests/acceptance/test_bridge_commands/test_v_model_plan.py` (Source: HAZ-001, ATP-008, SCN-008)

### 10b: User Story 3 — `v-model.tasks` (P2)

- [ ] T232 [P] [US3] Write acceptance test ATP-009-A in `tests/acceptance/test_bridge_commands/test_v_model_tasks.py` (Source: ATP-009, SCN-009, REQ-009)
- [ ] T233 [US3] Write acceptance test ATP-009-B in `tests/acceptance/test_bridge_commands/test_v_model_tasks.py` (Source: ATP-009, SCN-009, REQ-009)
- [ ] T234 [US3] Write acceptance test ATP-010-A in `tests/acceptance/test_bridge_commands/test_v_model_tasks.py` (Source: ATP-010, SCN-010, REQ-010)
- [ ] T235 [US3] Write acceptance test ATP-011-A in `tests/acceptance/test_bridge_commands/test_v_model_tasks.py` (Source: ATP-011, SCN-011, REQ-011)
- [ ] T236 [US3] Write acceptance test ATP-012-A in `tests/acceptance/test_bridge_commands/test_v_model_tasks.py` (Source: ATP-012, SCN-012, REQ-012)
- [ ] T237 [US3] Write acceptance test ATP-013-A in `tests/acceptance/test_bridge_commands/test_v_model_tasks.py` (Source: ATP-013, SCN-013, REQ-013)
- [ ] T238 [US3] Write acceptance test ATP-014-A in `tests/acceptance/test_bridge_commands/test_v_model_tasks.py` (Source: ATP-014, SCN-014, REQ-014)
- [ ] T239 [US3] Write acceptance test ATP-014-B in `tests/acceptance/test_bridge_commands/test_v_model_tasks.py` (Source: ATP-014, SCN-014, REQ-014)

### 10c: User Story 1 — `v-model.implement` (P1)

- [ ] T240 [P] [US1] Write acceptance test ATP-015-A in `tests/acceptance/test_bridge_commands/test_v_model_implement.py` (Source: ATP-015, SCN-015, REQ-015)
- [ ] T241 [US1] Add HAZ-004 verification (implement runs without plan.md/tasks.md present) to `tests/acceptance/test_bridge_commands/test_v_model_implement.py` (Source: HAZ-004, ATP-015, SCN-015)
- [ ] T242 [US1] Write acceptance test ATP-016-A in `tests/acceptance/test_bridge_commands/test_v_model_implement.py` (Source: ATP-016, SCN-016, REQ-016)
- [ ] T243 [US1] Write acceptance test ATP-016-B in `tests/acceptance/test_bridge_commands/test_v_model_implement.py` (Source: ATP-016, SCN-016, REQ-016)
- [ ] T244 [US1] Add HAZ-006 verification (Implements comments cover every emitted source file) to `tests/acceptance/test_bridge_commands/test_v_model_implement.py` (Source: HAZ-006, ATP-016, SCN-016)
- [ ] T245 [US1] Write acceptance test ATP-017-A in `tests/acceptance/test_bridge_commands/test_v_model_implement.py` (Source: ATP-017, SCN-017, REQ-017)
- [ ] T246 [US1] Write acceptance test ATP-018-A in `tests/acceptance/test_bridge_commands/test_v_model_implement.py` (Source: ATP-018, SCN-018, REQ-018)
- [ ] T247 [US1] Write acceptance test ATP-019-A in `tests/acceptance/test_bridge_commands/test_v_model_implement.py` (Source: ATP-019, SCN-019, REQ-019)
- [ ] T248 [US1] Write acceptance test ATP-020-A in `tests/acceptance/test_bridge_commands/test_v_model_implement.py` (Source: ATP-020, SCN-020, REQ-020)
- [ ] T249 [US1] Write acceptance test ATP-021-A in `tests/acceptance/test_bridge_commands/test_v_model_implement.py` (Source: ATP-021, SCN-021, REQ-021)
- [ ] T250 [US1] Write acceptance test ATP-022-A in `tests/acceptance/test_bridge_commands/test_v_model_implement.py` (Source: ATP-022, SCN-022, REQ-022)
- [ ] T251 [US1] Write acceptance test ATP-022-B in `tests/acceptance/test_bridge_commands/test_v_model_implement.py` (Source: ATP-022, SCN-022, REQ-022)
- [ ] T252 [US1] Write acceptance test ATP-023-A in `tests/acceptance/test_bridge_commands/test_v_model_implement.py` (Source: ATP-023, SCN-023, REQ-023)
- [ ] T253 [US1] Write acceptance test ATP-024-A in `tests/acceptance/test_bridge_commands/test_v_model_implement.py` (Source: ATP-024, SCN-024, REQ-024)
- [ ] T254 [US1] Write acceptance test ATP-024-B in `tests/acceptance/test_bridge_commands/test_v_model_implement.py` (Source: ATP-024, SCN-024, REQ-024)
- [ ] T255 [US1] Write acceptance test ATP-025-A in `tests/acceptance/test_bridge_commands/test_v_model_implement.py` (Source: ATP-025, SCN-025, REQ-025)
- [ ] T256 [US1] Write acceptance test ATP-026-A (all three command names registered) in `tests/acceptance/test_bridge_commands/test_v_model_implement.py` (Source: ATP-026, SCN-026, REQ-026, REQ-IF-003)

### 10d: User Story 4 — Interop (P3)

- [ ] T257 [P] [US4] Write acceptance test ATP-027-A in `tests/acceptance/test_bridge_commands/test_interop.py` (Source: ATP-027, SCN-027, REQ-027)
- [ ] T258 [US4] Write acceptance test ATP-028-A in `tests/acceptance/test_bridge_commands/test_interop.py` (Source: ATP-028, SCN-028, REQ-028)
- [ ] T259 [US4] Write acceptance test ATP-029-A in `tests/acceptance/test_bridge_commands/test_interop.py` (Source: ATP-029, SCN-029, REQ-029)
- [ ] T260 [US4] Write acceptance test ATP-029-B in `tests/acceptance/test_bridge_commands/test_interop.py` (Source: ATP-029, SCN-029, REQ-029)
- [ ] T261 [US4] Add HAZ-018 verification (round-trip preserves enrichment in both directions) to `tests/acceptance/test_bridge_commands/test_interop.py` (Source: HAZ-018, ATP-029, SCN-029)

### 10e: Non-Functional Acceptance

- [ ] T262 [P] [FOUND] Write acceptance test ATP-NF-001-A (four-stack all green) in `tests/acceptance/test_bridge_commands/test_nonfunctional.py` (Source: ATP-NF-001, SCN-NF-001, REQ-NF-001)
- [ ] T263 [FOUND] Add HAZ-021 verification (four-stack runner reports per-stack pass/fail) to `tests/acceptance/test_bridge_commands/test_nonfunctional.py` (Source: HAZ-021, ATP-NF-001, SCN-NF-001)
- [ ] T264 [FOUND] Write acceptance test ATP-NF-002-A (zero hallucinated IDs across fixtures) in `tests/acceptance/test_bridge_commands/test_nonfunctional.py` (Source: ATP-NF-002, SCN-NF-002, REQ-NF-002)
- [ ] T265 [FOUND] Write acceptance test ATP-NF-003-A (pinned spec-kit core) in `tests/acceptance/test_bridge_commands/test_nonfunctional.py` (Source: ATP-NF-003, SCN-NF-003, REQ-NF-003)
- [ ] T266 [FOUND] Write acceptance test ATP-NF-004-A (refusal across gap fixtures) in `tests/acceptance/test_bridge_commands/test_nonfunctional.py` (Source: ATP-NF-004, SCN-NF-004, REQ-NF-004)
- [ ] T267 [FOUND] Write acceptance test ATP-NF-005-A (skipped-artifact summary) in `tests/acceptance/test_bridge_commands/test_nonfunctional.py` (Source: ATP-NF-005, SCN-NF-005, REQ-NF-005)
- [ ] T268 [FOUND] Write acceptance test ATP-NF-006-A (hook infra diff is empty) in `tests/acceptance/test_bridge_commands/test_nonfunctional.py` (Source: ATP-NF-006, SCN-NF-006, REQ-NF-006)

### 10f: Interface Acceptance

- [ ] T269 [P] [FOUND] Write acceptance test ATP-IF-001-A (plan.md section presence) in `tests/acceptance/test_bridge_commands/test_interfaces.py` (Source: ATP-IF-001, SCN-IF-001, REQ-IF-001)
- [ ] T270 [FOUND] Write acceptance test ATP-IF-002-A (tasks.md parallel marker convention) in `tests/acceptance/test_bridge_commands/test_interfaces.py` (Source: ATP-IF-002, SCN-IF-002, REQ-IF-002)
- [ ] T271 [FOUND] Write acceptance test ATP-IF-003-A (extensions.yml before/after_implement) in `tests/acceptance/test_bridge_commands/test_interfaces.py` (Source: ATP-IF-003, SCN-IF-003, REQ-IF-003)
- [ ] T272 [FOUND] Write acceptance test ATP-IF-004-A (summary parser shared) in `tests/acceptance/test_bridge_commands/test_interfaces.py` (Source: ATP-IF-004, SCN-IF-004, REQ-IF-004)
- [ ] T273 [FOUND] Write acceptance test ATP-IF-005-A (extensions.yml after_specify) in `tests/acceptance/test_bridge_commands/test_interfaces.py` (Source: ATP-IF-005, SCN-IF-005, REQ-IF-005)

### 10g: Constraint Acceptance

- [ ] T274 [P] [FOUND] Write acceptance test ATP-CN-001-A (spec-kit core unchanged) in `tests/acceptance/test_bridge_commands/test_constraints.py` (Source: ATP-CN-001, SCN-CN-001, REQ-CN-001)
- [ ] T275 [FOUND] Write acceptance test ATP-CN-002-A (no new wrapper script) in `tests/acceptance/test_bridge_commands/test_constraints.py` (Source: ATP-CN-002, SCN-CN-002, REQ-CN-002)
- [ ] T276 [FOUND] Write acceptance test ATP-CN-003-A (no deferred capabilities) in `tests/acceptance/test_bridge_commands/test_constraints.py` (Source: ATP-CN-003, SCN-CN-003, REQ-CN-003)
- [ ] T277 [FOUND] Write acceptance test ATP-CN-004-A (V-Model artifacts before code) in `tests/acceptance/test_bridge_commands/test_constraints.py` (Source: ATP-CN-004, SCN-CN-004, REQ-CN-004)

---

## Phase 11: Run Acceptance Tests

- [ ] T278 Run `pytest tests/acceptance/test_bridge_commands/ -v` and confirm all 53 ATP test cases + 5 HAZ verifications pass (Source: ATP-001..029, ATP-NF-001..006, ATP-IF-001..005, ATP-CN-001..004, HAZ-001, HAZ-004, HAZ-006, HAZ-018, HAZ-021)

**Checkpoint**: All 53 ATP test cases GREEN → hook wiring and polish

---

## Phase 12: Hook Wiring

**Purpose**: Wire bridge commands into automation graph via `.specify/extensions.yml` (REQ-IF-003, REQ-IF-005, D-011)

- [ ] T279 [FOUND] Wire `before_implement` hook in `.specify/extensions.yml` to invoke MOD-010 `evaluate_gate` (Source: ATP-IF-003, REQ-IF-003, MOD-010, MOD-020, ARCH-007, ARCH-015)
- [ ] T280 [FOUND] Wire `after_implement` hook in `.specify/extensions.yml` to invoke MOD-022 coverage report + MOD-023 commit annotator (Source: ATP-IF-003, REQ-IF-003, MOD-022, MOD-023, MOD-020, ARCH-015, ARCH-017, ARCH-018)
- [ ] T281 [FOUND] Wire `after_specify` hook in `.specify/extensions.yml` to invoke MOD-019 fallback detector + MOD-021 summary emitter (Source: ATP-IF-005, REQ-IF-005, MOD-019, MOD-021, MOD-020, ARCH-014, ARCH-015, ARCH-016)

---

## Phase 13: Polish

- [ ] T282 [POLISH] Add DeepEval evaluator suite for bridge command outputs in `tests/eval/test_bridge_commands_deepeval.py` (Source: ATP-NF-001, REQ-NF-001)
- [ ] T283 [POLISH] Add BATS smoke tests for CLI surface in `tests/smoke/bats/bridge_commands.bats` (Source: ATP-IF-003, REQ-IF-003)
- [ ] T284 [POLISH] Add Pester smoke tests for Windows CLI surface in `tests/smoke/pester/BridgeCommands.Tests.ps1` (Source: ATP-IF-003, REQ-IF-003)
- [ ] T285 [POLISH] Run full four-stack compliance harness via MOD-022 and confirm coverage matrix (A+B+C+D+H) is green (Source: ATP-NF-001, ATP-CN-004, MOD-022, ARCH-017)

---

## Dependencies

- **Phase 1 (Setup)** → unblocks all later phases.
- **Phase 2 (CC modules)** → must complete before Phase 3+ (CC modules are leaf dependencies for every orchestrator).
- **Phase 3 (write unit tests)** → must complete (and tests must be RED) before Phase 4 (implementation).
- **Phase 4 (implement)** dependency chain: Layer 1 (T049–T056) → Layer 2 (T057–T060) → Layer 3 (T061–T065) → Layer 4 (T066–T068) → Layer 5 (T069–T071).
- **Phase 5** gates Phase 6.
- **Phase 6 → Phase 7 → Phase 8 → Phase 9 → Phase 10 → Phase 11** strict TDD escalator per D-007.
- **Phase 12 (hook wiring)** depends on Phase 11 GREEN (commands must be implementation-complete before being registered).
- **Phase 13 (polish)** runs last.

## Parallel Execution

- Tasks marked `[P]` modify distinct files and may run concurrently within a phase.
- Within Phase 4, all tasks within a single layer (e.g. Layer 1: T049–T056) may run in parallel; layers themselves are sequential.
- Within Phases 6/8/10, tasks targeting **different test files** are parallelizable; tasks within the same file are sequential.
- HAZ verification tasks intentionally share files with the preceding suite and are NOT marked `[P]`.

## Implementation Strategy

- **MVP** = Phase 1 + Phase 2 (CC) + Phase 3a (US1 unit tests) + Phase 4 layers 1–5 (implementation) + the US1 slices of Phases 6/8/10 (`v-model.implement` end-to-end). This delivers the P1 user story with full TDD compliance.
- **Iteration 2** adds US2 (`v-model.plan`) slices.
- **Iteration 3** adds US3 (`v-model.tasks`) slices.
- **Iteration 4** adds US4 (interop) and remaining FOUND/NF/IF/CN coverage.
- Hook wiring (Phase 12) and polish (Phase 13) run after each user story is GREEN end-to-end (or once at the end for the strict-waterfall variant).
