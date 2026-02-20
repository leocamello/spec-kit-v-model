# Tasks: System Design ↔ System Testing

**Input**: Design documents from `specs/002-system-design-testing/`
**Prerequisites**: plan.md (required), spec.md (required), research.md (required)
**Status**: Pending

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US5)

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Extension manifest update and configuration schema

- [ ] T001 Update extension.yml to version 0.2.0 with system-design and system-test commands in extension.yml
- [ ] T002 [P] Create v-model-config.yml schema documentation in docs/v-model-config.md (domain field, safety-critical gating — RQ-4)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Templates and validators that ALL commands depend on

**⚠️ CRITICAL**: No command implementation can begin until this phase is complete

- [ ] T003 Create system design template in templates/system-design-template.md (four IEEE 1016 views: Decomposition, Dependency, Interface, Data Design — RQ-2; optional safety-critical sections — RQ-4)
- [ ] T004 [P] Create system test template in templates/system-test-template.md (three-tier STP/STS structure with ISO 29119 technique fields — RQ-3; optional safety-critical sections — RQ-4)
- [ ] T005 [P] Create system-level ID validators in tests/validators/system_validators.py (SYS-NNN, STP-NNN-X, STS-NNN-X# format validation, parent reference parsing)

**Checkpoint**: Foundation ready — command implementation can now begin

---

## Phase 3: User Story 1 — Generate IEEE 1016-Compliant System Design (Priority: P1) 🎯 MVP

**Goal**: Decompose requirements into IEEE 1016-structured system components with many-to-many traceability and derived requirement flagging

**Independent Test**: Provide a valid `requirements.md` → verify output contains all four design views, every REQ referenced by ≥1 SYS, derived requirements flagged not silently added

### Implementation for User Story 1

- [ ] T006 [US1] Create system-design command definition in commands/system-design.md (workflow: load requirements.md → decompose into SYS-NNN components → populate 4 IEEE 1016 views → flag derived requirements → call validate-system-coverage.sh for forward coverage)
- [ ] T007 [US1] Define Decomposition View generation rules in commands/system-design.md (SYS-NNN identifiers, comma-separated "Parent Requirements" field for many-to-many REQ mapping — RQ-1, subsystem grouping)
- [ ] T008 [US1] Define Dependency View generation rules in commands/system-design.md (inter-component relationships, failure propagation paths — feeds Fault Injection testing in US2)
- [ ] T009 [US1] Define Interface View generation rules in commands/system-design.md (API contracts, explicit external vs internal interface distinction — RQ-3, data formats, protocols)
- [ ] T010 [US1] Define Data Design View generation rules in commands/system-design.md (data structures, storage mechanisms, data-at-rest and data-in-transit protection — feeds Boundary Value testing in US2)
- [ ] T011 [US1] Define safety-critical section gating in commands/system-design.md (FFI analysis + Restricted Complexity assessment gated by v-model-config.yml domain field — RQ-4)
- [ ] T012 [US1] Define derived requirement flagging rules in commands/system-design.md ([DERIVED REQUIREMENT: description] markers instead of silent SYS-NNN creation — RQ-5; human must resolve before proceeding)

**Checkpoint**: User Story 1 complete — system design generation is functional and independently testable

---

## Phase 4: User Story 2 — Generate ISO 29119-Compliant System Test Plan (Priority: P1)

**Goal**: Generate three-tier system test plan (STP + STS) for every system component using named ISO 29119 techniques with technical BDD language

**Independent Test**: Provide a valid `system-design.md` → verify every SYS has ≥1 STP, every STP has ≥1 STS, test techniques are named, technical language enforced, `validate-system-coverage.sh` confirms 100% SYS→STP coverage

### Implementation for User Story 2

- [ ] T013 [US2] Create system-test command definition in commands/system-test.md (workflow: load system-design.md → generate STP-NNN-X per SYS component → generate STS-NNN-X# BDD scenarios → run validate-system-coverage.sh → enforce 100% coverage gate)
- [ ] T014 [US2] Define Interface Contract Testing rules in commands/system-test.md (external vs internal interface distinction, protocol compliance, contract adherence, failure propagation — RQ-3)
- [ ] T015 [US2] Define Boundary Value Analysis rules in commands/system-test.md (data limits and ranges from Data Design View, edge values, equivalence partitioning — RQ-3)
- [ ] T016 [US2] Define Fault Injection / Negative Testing rules in commands/system-test.md (failure propagation paths from Dependency View, graceful degradation, isolation verification — RQ-3)
- [ ] T017 [US2] Define technical BDD language constraints in commands/system-test.md (prohibit user-journey phrases in STS scenarios, mandate component-oriented language — RQ-8)
- [ ] T018 [US2] Define safety-critical test section gating in commands/system-test.md (MC/DC coverage targets + WCET/stack/heap verification gated by v-model-config.yml domain — RQ-4)

**Checkpoint**: User Story 2 complete — system test plan generation is functional with auditor-grade technique traceability

---

## Phase 5: User Story 3 — Validate System-Level Bidirectional Coverage (Priority: P1)

**Goal**: Deterministic coverage validation script with forward (REQ→SYS), backward (SYS→STP), and orphan detection

**Independent Test**: Run script against fixture directories with known coverage states → assert correct exit codes (0 = pass, 1 = fail) and gap/orphan reports

### Implementation for User Story 3

- [ ] T019 [US3] Create validate-system-coverage.sh in scripts/bash/validate-system-coverage.sh (associative array three-pass: parse → cross-reference → report; --json flag; exit codes 0/1; handle many-to-many REQ↔SYS — RQ-7)
- [ ] T020 [US3] Create minimal test fixture in tests/fixtures/system-design-minimal/ (3 REQs, 3 SYS, 3 STP, 3 STS — 100% bidirectional coverage)
- [ ] T021 [P] [US3] Create complex test fixture in tests/fixtures/system-design-complex/ (10+ REQs, many-to-many REQ↔SYS, cross-cutting NFR components)
- [ ] T022 [P] [US3] Create gaps test fixture in tests/fixtures/system-design-gaps/ (REQ with no SYS mapping, SYS with no STP — coverage gaps)
- [ ] T023 [P] [US3] Create empty test fixture in tests/fixtures/system-design-empty/ (headers only, zero components — edge case)
- [ ] T024 [US3] Create BATS test suite in tests/bats/validate-system-coverage.bats (fixture-driven tests: minimal=pass, complex=pass, gaps=fail, empty=fail, circular dependency detection)

**Checkpoint**: User Story 3 complete — deterministic coverage validation works across all fixture types with CI-ready tests

---

## Phase 6: User Story 4 — Extended Traceability Matrix with System Layer (Priority: P2)

**Goal**: Extend trace command with dual-matrix output (Matrix A Validation + Matrix B Verification) maintaining backward compatibility

**Independent Test**: Run updated trace on a feature directory with all four artifacts → verify Matrix A (REQ→ATP→SCN) and Matrix B (REQ→SYS→STP→STS) with independent coverage percentages; run on v0.1.0-only directory → verify only Matrix A generated (no errors)

### Implementation for User Story 4

- [ ] T025 [US4] Update traceability-matrix-template.md with Matrix A (Validation) and Matrix B (Verification) sections in templates/traceability-matrix-template.md (RQ-6)
- [ ] T026 [US4] Extend build-matrix.sh to parse system-design.md and system-test.md for Matrix B data in scripts/bash/build-matrix.sh (backward compatible: skip Matrix B when system artifacts absent)
- [ ] T027 [US4] Update trace command in commands/trace.md (dual-matrix output, independent coverage percentages per matrix, backward compatibility with v0.1.0 directories — RQ-6)
- [ ] T028 [P] [US4] Extend BATS tests for build-matrix.sh with Matrix B scenarios in tests/bats/build-matrix.bats

**Checkpoint**: User Story 4 complete — traceability matrix supports both V-levels with full audit trail

---

## Phase 7: User Story 5 — PowerShell Parity for System Coverage Validation (Priority: P3)

**Goal**: Cross-platform parity — PowerShell scripts produce identical output, exit codes, and pass same fixtures as Bash equivalents

**Independent Test**: Run both Bash and PowerShell scripts on same fixtures → verify identical output and exit codes

### Implementation for User Story 5

- [ ] T029 [US5] Create validate-system-coverage.ps1 in scripts/powershell/validate-system-coverage.ps1 (port of validate-system-coverage.sh — identical output format, identical exit codes)
- [ ] T030 [P] [US5] Extend build-matrix.ps1 for Matrix B in scripts/powershell/build-matrix.ps1 (port of build-matrix.sh Matrix B changes)
- [ ] T031 [US5] Create Pester test suite in tests/pester/validate-system-coverage.tests.ps1 (same fixture scenarios as BATS suite)

**Checkpoint**: User Story 5 complete — Windows teams have full coverage validation parity

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Documentation, quality assurance, and CI integration

- [ ] T032 [P] Update docs/v-model-overview.md with System Design ↔ System Testing level description and IEEE 1016 / ISO 29119 references
- [ ] T033 [P] Update docs/compliance-guide.md with IEEE 1016:2009 design views and ISO 29119-4 test technique references
- [ ] T034 [P] Update docs/usage-examples.md with system-design and system-test command examples and sample output
- [ ] T035 [P] Create DeepEval eval for system design quality in tests/evals/test_system_design_eval.py (internal QA gate — IEEE 1016 view completeness, SYS-NNN format, parent REQ coverage)
- [ ] T036 [P] Create DeepEval eval for system test quality in tests/evals/test_system_test_eval.py (internal QA gate — ISO 29119 technique naming, technical BDD language, STP/STS format)
- [ ] T037 Update .github/workflows/ci.yml to include validate-system-coverage.bats and Pester system tests
- [ ] T038 Update .github/workflows/evals.yml to include system-level eval tests (test_system_design_eval.py, test_system_test_eval.py)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion — BLOCKS all commands
- **US1 System Design (Phase 3)**: Depends on Foundational (templates + validators)
- **US2 System Test (Phase 4)**: Depends on Foundational; benefits from US1 but independently testable with fixture inputs
- **US3 Coverage Validation (Phase 5)**: Independent of commands — depends only on Foundational (validators) and fixture creation
- **US4 Extended Trace (Phase 6)**: Depends on US3 script existing (build-matrix.sh extension needs validate-system-coverage.sh patterns)
- **US5 PowerShell Parity (Phase 7)**: Depends on US3 (port of Bash scripts) and US4 (port of build-matrix.sh changes)
- **Polish (Phase 8)**: Can start after US1 + US2; CI tasks depend on US3 + US5

### User Story Dependencies

- **US1 (System Design)**: Independent — only needs templates
- **US2 (System Test)**: Independent — uses system-design.md as input, testable with fixtures
- **US3 (Coverage Validation)**: Independent — creates scripts, testable with fixtures
- **US4 (Extended Trace)**: Depends on US3 script patterns
- **US5 (PowerShell Parity)**: Depends on US3 + US4 Bash scripts being finalized

### Parallel Opportunities

- All Phase 1 tasks can run in parallel
- All Phase 2 tasks marked [P] can run in parallel (templates are independent)
- US1, US2, US3 can proceed in parallel after Phase 2 (different command/script files)
- All test fixtures (T020–T023) can be created in parallel
- All documentation updates (T032–T034) can be created in parallel
- All eval tests (T035–T036) can be created in parallel

---

## Parallel Example: User Story 3

```bash
# Launch all fixtures in parallel:
Task: "Create minimal fixture in tests/fixtures/system-design-minimal/"
Task: "Create complex fixture in tests/fixtures/system-design-complex/"
Task: "Create gaps fixture in tests/fixtures/system-design-gaps/"
Task: "Create empty fixture in tests/fixtures/system-design-empty/"

# Then create BATS suite (depends on fixtures):
Task: "Create BATS test suite in tests/bats/validate-system-coverage.bats"
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 2 + 3)

1. Complete Phase 1: Setup (extension manifest update)
2. Complete Phase 2: Foundational (templates + validators)
3. Complete Phase 3: User Story 1 (system-design command)
4. Complete Phase 4: User Story 2 (system-test command)
5. Complete Phase 5: User Story 3 (coverage validation script + fixtures + BATS)
6. **STOP and VALIDATE**: Dogfood on Feature 001 — generate system-design.md + system-test.md from existing requirements.md → run validate-system-coverage.sh → confirm 100% coverage
7. This delivers the core V-Model Level 2 promise: paired system design and system test with deterministic verification

### Full Delivery

8. Complete Phase 6: User Story 4 (extended traceability matrix)
9. Complete Phase 7: User Story 5 (PowerShell parity)
10. Complete Phase 8: Polish (docs, evals, CI)
11. **FINAL VALIDATION**: Run full dogfood cycle on Feature 001 with all commands → generate complete traceability matrix → verify Matrix A + Matrix B

### Incremental Delivery

- After Phase 5 (MVP): v0.2.0-beta — system design + system test + coverage validation
- After Phase 6: v0.2.0-rc — extended traceability matrix
- After Phase 8: v0.2.0 — full release with docs, evals, CI, PowerShell parity

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Total tasks: 38 (2 setup + 3 foundational + 7 US1 + 6 US2 + 6 US3 + 4 US4 + 3 US5 + 7 polish)
- Parallel opportunities: 18 of 38 tasks (47%) could run in parallel
- All RQ references map to decisions in research.md
- DeepEval tests (T035–T036) are internal QA gates, not user-facing
