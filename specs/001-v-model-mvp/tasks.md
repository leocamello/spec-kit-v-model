# Tasks: V-Model Extension Pack MVP

**Input**: Design documents from `specs/001-v-model-mvp/`
**Prerequisites**: plan.md (required), spec.md (required), research.md
**Status**: Implemented (retroactive documentation — all tasks complete)

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US5)

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization, extension manifest, and shared configuration

- [x] T001 Create extension manifest in extension.yml (id, name, version, commands, hooks, scripts)
- [x] T002 [P] Create README.md with project overview, installation, and usage
- [x] T003 [P] Create CHANGELOG.md, CODE_OF_CONDUCT.md, CONTRIBUTING.md, SECURITY.md
- [x] T004 [P] Create .editorconfig and .gitignore for consistent formatting
- [x] T005 [P] Create LICENSE file (MIT)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared scripts and templates that ALL commands depend on

**⚠️ CRITICAL**: No command implementation can begin until this phase is complete

- [x] T006 Create V-Model directory setup script in scripts/bash/setup-v-model.sh (--json, --require-reqs, --require-acceptance flags)
- [x] T007 [P] Create PowerShell equivalent in scripts/powershell/setup-v-model.ps1
- [x] T008 [P] Create requirements template in templates/requirements-template.md (four-category tabular structure with ID, Description, Priority, Rationale, Verification Method)
- [x] T009 [P] Create acceptance plan template in templates/acceptance-plan-template.md (three-tier ID schema documentation, per-requirement test case blocks, coverage summary)
- [x] T010 [P] Create traceability matrix template in templates/traceability-matrix-template.md (bidirectional table, coverage metrics, gap analysis, audit notes)

**Checkpoint**: Foundation ready — command implementation can now begin

---

## Phase 3: User Story 1 — Generate Traceable Requirements (Priority: P1) 🎯 MVP

**Goal**: Transform feature descriptions into structured Requirements Specifications with unique REQ-NNN identifiers across four categories

**Independent Test**: Provide a sample feature description → verify output contains correctly formatted REQ-NNN identifiers, no banned vague words, all eight quality criteria documented

### Implementation for User Story 1

- [x] T011 [US1] Create requirements command definition in commands/requirements.md (workflow: load spec.md → extract concepts → generate REQ-NNN per category → validate 8 quality criteria → write requirements.md)
- [x] T012 [US1] Define eight quality criteria enforcement rules in commands/requirements.md (unambiguous, testable, atomic, complete, consistent, traceable, feasible, necessary)
- [x] T013 [US1] Define banned-words list in commands/requirements.md (fast, user-friendly, robust, scalable, efficient, etc. → require measurable replacements)
- [x] T014 [US1] Define incremental update rules in commands/requirements.md (preserve existing IDs, sequential numbering for new REQs, never renumber)

**Checkpoint**: User Story 1 complete — requirements generation is functional and independently testable

---

## Phase 4: User Story 2 — Generate Acceptance Test Plan (Priority: P1)

**Goal**: Produce a three-tier Acceptance Test Plan (ATP + SCN) with 100% bidirectional coverage for every requirement

**Independent Test**: Provide a valid requirements.md → verify output contains ATP-NNN-X and SCN-NNN-X# for every REQ, run validate-requirement-coverage.sh → exit code 0

### Implementation for User Story 2

- [x] T015 [US2] Create deterministic coverage validation script in scripts/bash/validate-requirement-coverage.sh (regex extraction of REQ/ATP/SCN IDs, cross-reference, gap/orphan detection, --json output, exit code 0/1)
- [x] T016 [P] [US2] Create PowerShell equivalent in scripts/powershell/validate-requirement-coverage.ps1
- [x] T017 [US2] Create requirement change detection script in scripts/bash/diff-requirements.sh (git show comparison, added/modified/removed classification, --json output)
- [x] T018 [P] [US2] Create PowerShell equivalent in scripts/powershell/diff-requirements.ps1
- [x] T019 [US2] Create acceptance command definition in commands/acceptance.md (workflow: load requirements.md → generate ATP-NNN-X test cases → generate SCN-NNN-X# BDD scenarios → run validate-requirement-coverage.sh → enforce 100% coverage gate)
- [x] T020 [US2] Define test case quality criteria in commands/acceptance.md (traceable, independent, repeatable, clear expected result)
- [x] T021 [US2] Define BDD scenario quality criteria in commands/acceptance.md (declarative, single-action, strict preconditions, observable outcomes)
- [x] T022 [US2] Define incremental update rules in commands/acceptance.md (added REQs → new ATPs/SCNs, modified → regenerate in-place, removed → flag [DEPRECATED], batching in groups of 5)

**Checkpoint**: User Story 2 complete — acceptance test plan generation is functional with deterministic coverage validation

---

## Phase 5: User Story 3 — Build Traceability Matrix (Priority: P2)

**Goal**: Produce a regulatory-grade, bidirectional Requirements Traceability Matrix with coverage metrics and exception reporting

**Independent Test**: Provide a valid requirements.md + acceptance-plan.md pair → verify output matrix has all REQs with forward/backward links, coverage percentages, and exception report

### Implementation for User Story 3

- [x] T023 [US3] Create deterministic matrix builder script in scripts/bash/build-matrix.sh (regex parsing of requirements.md + acceptance-plan.md, forward/backward cross-reference, coverage metrics, gap/orphan reporting, --output flag)
- [x] T024 [P] [US3] Create PowerShell equivalent in scripts/powershell/build-matrix.ps1
- [x] T025 [US3] Create trace command definition in commands/trace.md (workflow: require both inputs via --require-reqs --require-acceptance → run build-matrix.sh → format into template → add baseline info with timestamps and git commit hash)
- [x] T026 [US3] Define four regulatory pillars in commands/trace.md (strict bidirectionality, orphan/gap analysis, versioning/baselines, granular execution state with ⬜✅❌🚫⏸️)

**Checkpoint**: User Story 3 complete — traceability matrix generation is functional and audit-ready

---

## Phase 6: User Story 4 — Validate Coverage Deterministically (Priority: P2)

**Goal**: Provide a standalone CI-ready coverage validation tool that exits with meaningful codes

**Independent Test**: Run validate-requirement-coverage.sh against fixture directories with known states → assert correct exit codes and gap reports

*Note: The core script was implemented in Phase 4 (T015). This phase covers CI integration and fixture validation.*

### Implementation for User Story 4

- [x] T027 [US4] Create minimal test fixture in tests/fixtures/minimal/ (3 REQs, 3 ATPs, 3 SCNs — full coverage)
- [x] T028 [P] [US4] Create gaps test fixture in tests/fixtures/gaps/ (REQs missing ATPs — coverage gaps)
- [x] T029 [P] [US4] Create complex test fixture in tests/fixtures/complex/ (10+ REQs across all categories)
- [x] T030 [P] [US4] Create empty test fixture in tests/fixtures/empty/ (headers only, no requirement entries)
- [x] T031 [P] [US4] Create malformed test fixture in tests/fixtures/malformed/ (broken Markdown structure)
- [x] T032 [US4] Create BATS test suite for validate-requirement-coverage in tests/bats/validate-requirement-coverage.bats
- [x] T033 [P] [US4] Create BATS test suite for build-matrix in tests/bats/build-matrix.bats
- [x] T034 [P] [US4] Create BATS test suite for setup-v-model in tests/bats/setup-v-model.bats
- [x] T035 [P] [US4] Create BATS test suite for diff-requirements in tests/bats/diff-requirements.bats
- [x] T036 [US4] Create Pester test suites for all PowerShell scripts in tests/pester/

**Checkpoint**: User Story 4 complete — deterministic validation works across all fixture types with CI-ready test suites

---

## Phase 7: User Story 5 — Detect Requirement Changes (Priority: P3)

**Goal**: Provide incremental change detection so acceptance regeneration only affects changed requirements

**Independent Test**: Commit a requirements.md, modify it, run diff-requirements.sh → verify added/modified/removed lists are correct

*Note: The core script was implemented in Phase 4 (T017). This phase covers edge case handling.*

### Implementation for User Story 5

- [x] T037 [US5] Handle edge case in diff-requirements.sh: no git history (fall back to "all changed")
- [x] T038 [US5] Handle edge case in diff-requirements.sh: requirements.md does not exist (error with descriptive message)
- [x] T039 [US5] Verify BATS tests for diff-requirements cover all edge cases in tests/bats/diff-requirements.bats

**Checkpoint**: User Story 5 complete — change detection handles all edge cases

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Documentation, quality assurance, and CI integration

- [x] T040 [P] Create V-Model methodology overview in docs/v-model-overview.md
- [x] T041 [P] Create regulatory compliance guide in docs/compliance-guide.md
- [x] T042 [P] Create command usage examples in docs/usage-examples.md
- [x] T043 [P] Create strategic product vision in docs/product-vision.md
- [x] T044 Create Python structural validators in tests/validators/ (requirement format, BDD structure, traceability completeness)
- [x] T045 [P] Create DeepEval GEval metrics in tests/evals/metrics/ (requirements_quality, bdd_quality, traceability)
- [x] T046 [P] Create golden examples in tests/fixtures/golden/ (medical-device, automotive-adas)
- [x] T047 Create CI workflow for structural tests in .github/workflows/ci.yml (BATS + Pester + Python validators)
- [x] T048 Create CI workflow for LLM evals in .github/workflows/evals.yml (DeepEval + Google Gemini, manual trigger)
- [x] T049 Create pyproject.toml and requirements-dev.txt for Python test dependencies

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion — BLOCKS all commands
- **US1 Requirements (Phase 3)**: Depends on Foundational (templates + setup script)
- **US2 Acceptance (Phase 4)**: Depends on Foundational; benefits from US1 but independently testable
- **US3 Trace (Phase 5)**: Depends on Foundational; benefits from US1 + US2 but independently testable
- **US4 Validation (Phase 6)**: Depends on US2 (validate-requirement-coverage.sh created there)
- **US5 Change Detection (Phase 7)**: Depends on US2 (diff-requirements.sh created there)
- **Polish (Phase 8)**: Can start after Foundational; some tasks parallel with user stories

### User Story Dependencies

- **US1 (Requirements)**: Independent — only needs templates and setup script
- **US2 (Acceptance)**: Independent — creates its own scripts; uses requirements.md as input
- **US3 (Trace)**: Independent — creates its own script; uses both input files
- **US4 (Validation)**: Depends on US2 scripts being implemented
- **US5 (Change Detection)**: Depends on US2 scripts being implemented

### Parallel Opportunities

- All Phase 1 tasks marked [P] can run in parallel
- All Phase 2 tasks marked [P] can run in parallel (templates are independent)
- US1, US2, US3 can proceed in parallel (different command files and scripts)
- All test fixtures (T027–T031) can be created in parallel
- All BATS suites (T032–T035) can be created in parallel
- All documentation (T040–T043) can be created in parallel
- All eval artifacts (T045–T046) can be created in parallel

---

## Implementation Strategy

### MVP First (User Stories 1 + 2)

1. Complete Phase 1: Setup (extension manifest, README)
2. Complete Phase 2: Foundational (setup script, templates)
3. Complete Phase 3: User Story 1 (requirements command)
4. Complete Phase 4: User Story 2 (acceptance command + coverage validation)
5. **STOP and VALIDATE**: Generate requirements + acceptance plan for a sample feature → run validate-requirement-coverage.sh → confirm 100% coverage
6. This delivers the core V-Model promise: paired dev-spec and test-spec

### Full Delivery

7. Complete Phase 5: User Story 3 (trace command)
8. Complete Phases 6–7: Validation edge cases and change detection
9. Complete Phase 8: Documentation, quality assurance, CI

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- All tasks are marked [x] (complete) — this is a retroactive task list
- Total tasks: 49 (5 setup + 5 foundational + 4 US1 + 8 US2 + 4 US3 + 10 US4 + 3 US5 + 10 polish)
- Parallel opportunities: 31 of 49 tasks (63%) could run in parallel
