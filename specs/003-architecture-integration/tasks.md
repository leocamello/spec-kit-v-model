# Tasks: Architecture Design ↔ Integration Testing

**Input**: Design documents from `specs/003-architecture-integration/`
**Prerequisites**: plan.md (required), spec.md (required), research.md (required)
**Status**: Pending

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US5)

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Extension manifest update and ID schema registration

- [ ] T001 Update extension.yml to version 0.3.0 with architecture-design and integration-test commands
- [ ] T002 [P] Update id_validator.py to add ARCH/ITP/ITS ID patterns (ID_PATTERNS, ID_STRICT_PATTERNS, extract/validate functions)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Templates and validators that ALL commands depend on

**⚠️ CRITICAL**: No command implementation can begin until this phase is complete

- [ ] T003 Create architecture design template in templates/architecture-design-template.md (four 42010/4+1 views: Logical, Process, Interface, Data Flow — RQ-2; CROSS-CUTTING support — RQ-1; optional safety-critical sections — RQ-4)
- [ ] T004 [P] Create integration test template in templates/integration-test-template.md (four-technique ITP/ITS structure — RQ-3; Test Harness & Mocking Strategy section; optional safety-critical sections — RQ-4)
- [ ] T005 [P] Create architecture-level validators in tests/validators/architecture_validators.py (ARCH-NNN format, 4 views present, SYS traceability, interface contract completeness, ITP/ITS format, technique naming)

**Checkpoint**: Foundation ready — command implementation can now begin

---

## Phase 3: User Story 1 — Generate 42010/4+1 Architecture Design (Priority: P1) 🎯 MVP

**Goal**: Decompose SYS components into ARCH modules with four mandatory views, cross-cutting support, and derived module flagging

**Independent Test**: Provide a valid `system-design.md` → verify output contains all four views, every SYS referenced by ≥1 ARCH, cross-cutting modules tagged, derived modules flagged

### Implementation for User Story 1

- [ ] T006 [US1] Create architecture-design command definition in commands/architecture-design.md (workflow: load system-design.md → decompose SYS into ARCH-NNN modules → populate 4 views → tag CROSS-CUTTING modules — RQ-1 → flag derived modules → call validate-architecture-coverage.sh for forward coverage)
- [ ] T007 [US1] Define Logical View generation rules in commands/architecture-design.md (ARCH-NNN identifiers, "Parent System Components" field for many-to-many SYS mapping — RQ-1, CROSS-CUTTING tag with rationale)
- [ ] T008 [US1] Define Process View generation rules in commands/architecture-design.md (Mermaid sequence diagrams for runtime interactions — RQ-2, concurrency model, synchronization points)
- [ ] T009 [US1] Define Interface View generation rules in commands/architecture-design.md (strict API contracts: inputs, outputs, exceptions per ARCH module — RQ-2; drives Interface Contract Testing)
- [ ] T010 [US1] Define Data Flow View generation rules in commands/architecture-design.md (data transformation chains with intermediate formats — RQ-2; feeds Data Flow Testing)
- [ ] T011 [US1] Define safety-critical section gating in commands/architecture-design.md (ASIL Decomposition + Defensive Programming + Temporal Constraints gated by v-model-config.yml — RQ-4)
- [ ] T012 [US1] Define derived module flagging and anti-pattern guard rules in commands/architecture-design.md ([DERIVED MODULE] markers — FR-007a; reject black-box descriptions without interface contracts)

**Checkpoint**: User Story 1 complete — architecture design generation is functional and independently testable

---

## Phase 4: User Story 2 — Generate ISO 29119-4 Integration Test Plan (Priority: P1)

**Goal**: Generate four-technique integration test plan (ITP + ITS) for every ARCH module using module-boundary-oriented BDD language

**Independent Test**: Provide a valid `architecture-design.md` → verify every ARCH has ≥1 ITP, every ITP has ≥1 ITS, techniques are named and view-anchored, boundary language enforced, `validate-architecture-coverage.sh` confirms 100% ARCH→ITP coverage

### Implementation for User Story 2

- [ ] T013 [US2] Create integration-test command definition in commands/integration-test.md (workflow: load architecture-design.md → generate ITP-NNN-X per ARCH module → generate ITS-NNN-X# BDD scenarios → run validate-architecture-coverage.sh → enforce 100% coverage gate)
- [ ] T014 [US2] Define Interface Contract Testing rules in commands/integration-test.md (verify ARCH modules honor Interface View contracts, framework-agnostic — RQ-3)
- [ ] T015 [US2] Define Data Flow Testing rules in commands/integration-test.md (end-to-end data transformation chain validation from Data Flow View — RQ-3)
- [ ] T016 [US2] Define Interface Fault Injection rules in commands/integration-test.md (malformed payloads, timeouts, graceful failure — Interface View errors + Process View timing — RQ-3)
- [ ] T017 [US2] Define Concurrency & Race Condition Testing rules in commands/integration-test.md (simultaneous access, mutex strategies, queue ordering — Process View concurrency — RQ-3)
- [ ] T018 [US2] Define module-boundary BDD language constraints and Test Harness & Mocking Strategy section in commands/integration-test.md (prohibit user-journey AND internal-logic phrases in ITS scenarios)
- [ ] T019 [US2] Define safety-critical test section gating in commands/integration-test.md (SIL/HIL Compatibility + Resource Contention gated by v-model-config.yml — RQ-4)

**Checkpoint**: User Story 2 complete — integration test plan generation is functional with auditor-grade technique traceability

---

## Phase 5: User Story 3 — Validate Architecture-Level Bidirectional Coverage (Priority: P1)

**Goal**: Deterministic coverage validation script with forward (SYS→ARCH), backward (ARCH→ITP→ITS), partial execution, cross-cutting handling, and orphan detection

**Independent Test**: Run script against fixture directories with known coverage states → assert correct exit codes (0 = pass, 1 = fail) and gap/orphan reports

### Implementation for User Story 3

- [ ] T020 [US3] Create validate-architecture-coverage.sh in scripts/bash/ (3 positional file args, --json flag, partial execution when integration-test.md absent — RQ-5, cross-cutting module handling, exit codes 0/1)
- [ ] T021 [US3] Create minimal test fixture in tests/fixtures/architecture-minimal/ (3 SYS, 5 ARCH, 5 ITP, 5 ITS — 100% bidirectional coverage, 1 cross-cutting module)
- [ ] T022 [P] [US3] Create complex test fixture in tests/fixtures/architecture-complex/ (10+ SYS, many-to-many SYS↔ARCH, multiple cross-cutting modules, all 4 techniques)
- [ ] T023 [P] [US3] Create gaps test fixture in tests/fixtures/architecture-gaps/ (ARCH with no ITP, SYS with no ARCH mapping — coverage gaps)
- [ ] T024 [P] [US3] Create empty test fixture in tests/fixtures/architecture-empty/ (headers only, zero ARCH modules — edge case)
- [ ] T025 [US3] Create BATS test suite in tests/bats/validate-architecture-coverage.bats (fixture-driven tests: minimal=pass, complex=pass, gaps=fail, empty=fail, partial execution)

**Checkpoint**: User Story 3 complete — deterministic coverage validation works across all fixture types with CI-ready tests

---

## Phase 6: User Story 4 — Extended Traceability Matrix with Architecture Layer (Priority: P2)

**Goal**: Extend trace command with triple-matrix output (Matrix A + B + C) maintaining backward compatibility

**Independent Test**: Run updated trace on a feature directory with all six artifacts → verify Matrix A, B, and C with independent coverage percentages; run on v0.2.0-only directory → verify A + B only; run on v0.1.0-only directory → verify A only

### Implementation for User Story 4

- [ ] T026 [US4] Update traceability-matrix-template.md with Matrix C (Integration Verification) section in templates/ (RQ-6, parent REQ annotations in SYS column, CROSS-CUTTING pseudo-rows)
- [ ] T027 [US4] Extend build-matrix.sh to parse architecture-design.md and integration-test.md for Matrix C data in scripts/bash/ (section-scoped Logical View parsing — RQ-7, backward compatible)
- [ ] T028 [US4] Update trace command in commands/trace.md (triple-matrix output, independent coverage percentages, progressive A → A+B → A+B+C — RQ-6)
- [ ] T029 [P] [US4] Extend build-matrix.ps1 for Matrix C in scripts/powershell/ (port of Bash Matrix C changes)

**Checkpoint**: User Story 4 complete — traceability matrix supports all three V-levels with full audit trail

---

## Phase 7: User Story 5 — PowerShell Parity and Setup Script Extensions (Priority: P3)

**Goal**: Cross-platform parity + setup script support for --require-system-design flag and architecture-level doc detection

### Implementation for User Story 5

- [ ] T030 [US5] Update setup-v-model.sh to add --require-system-design flag and detect architecture-design.md/integration-test.md in AVAILABLE_DOCS
- [ ] T031 [P] [US5] Update setup-v-model.ps1 with identical changes
- [ ] T032 [US5] Create validate-architecture-coverage.ps1 in scripts/powershell/ (port of validate-architecture-coverage.sh — identical output, exit codes)
- [ ] T033 [US5] Create Pester test suite in tests/pester/validate-architecture-coverage.tests.ps1 (same fixture scenarios as BATS suite)

**Checkpoint**: User Story 5 complete — Windows teams have full architecture-level validation parity

---

## Phase 8: Golden Examples & Evaluation Suite

**Purpose**: Reference outputs and automated quality gates

- [ ] T034 [P] Create expected-architecture-design.md for medical-device golden fixture (IEC 62304 Class C)
- [ ] T035 [P] Create expected-integration-test.md for medical-device golden fixture
- [ ] T036 [P] Create expected-architecture-design.md for automotive-adas golden fixture (ISO 26262 ASIL-D)
- [ ] T037 [P] Create expected-integration-test.md for automotive-adas golden fixture
- [ ] T038 Create architecture_validators.py in tests/validators/ (validate_architecture_design: 4 views, SYS trace, interface contracts, Mermaid syntax — RQ-8; validate_integration_test: ITP/ITS IDs, 4 techniques, ARCH coverage)
- [ ] T039 [P] Update template_validator.py with architecture + integration section validators
- [ ] T040 Create test_architecture_design_eval.py in tests/evals/ (structural: ID format, view completeness, Mermaid validation; quality: LLM-as-judge for view coherence)
- [ ] T041 [P] Create test_integration_test_eval.py in tests/evals/ (structural: ITP/ITS format, technique naming; quality: LLM-as-judge for boundary-language compliance)
- [ ] T042 Create test_e2e_architecture_design.py in tests/evals/ (4 E2E tests: medical happy path, automotive with safety sections, large-scale 50+ SYS, error handling)
- [ ] T043 [P] Create test_e2e_integration_test.py in tests/evals/ (4 E2E tests: medical, automotive, cross-cutting modules, partial input)
- [ ] T044 Update harness.py with COMMAND_TEMPLATES and COMMAND_AVAILABLE_DOCS for architecture-design and integration-test
- [ ] T045 [P] Update conftest.py with architecture/integration fixture loaders

**Checkpoint**: Evaluation suite complete — automated quality gates for architecture-level commands

---

## Phase 9: Documentation & Polish

**Purpose**: User-facing documentation and README updates

- [ ] T046 [P] Update docs/v-model-overview.md with Architecture ↔ Integration Testing level description
- [ ] T047 [P] Update docs/compliance-guide.md with IEEE 42010, ISO 29119-4, ASIL decomposition mappings
- [ ] T048 [P] Update docs/usage-examples.md with architecture-design and integration-test command examples
- [ ] T049 Update README.md (proactive workflow 7→11 steps, command table 5→7, version badge 0.3.0)

---

## Phase 10: Release

**Purpose**: Version bump, changelog, catalog update

- [ ] T050 Add [0.3.0] section to CHANGELOG.md
- [ ] T051 [P] Update catalog-entry.json (version 0.3.0, commands: 7)
- [ ] T052 Tag v0.3.0, create GitHub Release

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion — BLOCKS all commands
- **US1 Architecture Design (Phase 3)**: Depends on Foundational (templates + validators)
- **US2 Integration Test (Phase 4)**: Depends on Foundational; benefits from US1 but independently testable with fixture inputs
- **US3 Coverage Validation (Phase 5)**: Independent of commands — depends only on Foundational (validators) and fixture creation
- **US4 Extended Trace (Phase 6)**: Depends on US3 script existing (build-matrix.sh extension needs validate-architecture-coverage.sh patterns)
- **US5 PowerShell + Setup (Phase 7)**: Depends on US3 (port of Bash scripts) and US4 (port of build-matrix.sh changes)
- **Golden + Evals (Phase 8)**: Can start after US1 + US2; validators depend on Foundational
- **Documentation (Phase 9)**: Can start after US1 + US2; README depends on all commands being final
- **Release (Phase 10)**: Depends on all previous phases

### Parallel Opportunities

- All Phase 2 tasks marked [P] can run in parallel (templates are independent)
- US1, US2, US3 can proceed in parallel after Phase 2 (different command/script files)
- All test fixtures (T021–T024) can be created in parallel
- All golden examples (T034–T037) can be created in parallel
- All documentation updates (T046–T048) can be created in parallel
- All eval tests (T040–T043) can be created in parallel

---

## Implementation Strategy

### MVP First (User Stories 1 + 2 + 3)

1. Complete Phase 1: Setup (extension manifest + ID validators)
2. Complete Phase 2: Foundational (templates + architecture validators)
3. Complete Phase 3: User Story 1 (architecture-design command)
4. Complete Phase 4: User Story 2 (integration-test command)
5. Complete Phase 5: User Story 3 (coverage validation script + fixtures + BATS)
6. **STOP and VALIDATE**: Dogfood on Feature 003 v-model artifacts — generate architecture-design.md + integration-test.md from existing system-design.md → run validate-architecture-coverage.sh → confirm 100% coverage

### Full Delivery

7. Complete Phase 6: User Story 4 (extended traceability matrix)
8. Complete Phase 7: User Story 5 (PowerShell parity + setup extensions)
9. Complete Phase 8: Golden examples + evaluation suite
10. Complete Phase 9: Documentation
11. Complete Phase 10: Release
12. **FINAL VALIDATION**: Run full dogfood cycle on Feature 003 → generate complete traceability matrix (A + B + C)

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Total tasks: 52 (2 setup + 3 foundational + 7 US1 + 7 US2 + 6 US3 + 4 US4 + 4 US5 + 12 golden/evals + 4 docs + 3 release)
- Parallel opportunities: 24 of 52 tasks (46%) could run in parallel
- All RQ references map to decisions in research.md
- DeepEval tests are internal QA gates, not user-facing
