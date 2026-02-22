# Changelog

All notable changes to the V-Model Extension Pack are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] — 2026-02-22

### Added
- `module-design` command — DO-178C/ISO 26262-compliant low-level module designs with four mandatory views (Algorithmic/Logic, State Machine, Internal Data Structures, Error Handling & Return Codes)
- `unit-test` command — ISO 29119-4 white-box unit test plans with five named techniques (Statement & Branch Coverage, Boundary Value Analysis, Equivalence Partitioning, State Transition Testing, Strict Isolation) and Dependency & Mock Registries
- `validate-module-coverage.sh` / `validate-module-coverage.ps1` — Deterministic ARCH→MOD→UTP→UTS bidirectional coverage validation with EXTERNAL and CROSS-CUTTING module support
- Matrix D (Unit Verification) in traceability matrix — ARCH → MOD → UTP → UTS with parent ARCH annotations
- `--require-module-design`, `--require-unit-test` flags for setup-v-model (bash + PowerShell)
- Module design and unit test fixtures across all scenario directories (minimal, complex, gaps, empty, golden)
- Module-level validators (`validate_module_design()`, `validate_unit_test()` in template_validator.py; `module_validators.py`)
- MOD-NNN, UTP-NNN-X, UTS-NNN-X# ID patterns in id_validator.py
- EXTERNAL and DERIVED MODULE tags for third-party and emergent module designs
- Pester test suite: `Validate-Module-Coverage.Tests.ps1` (16 tests)
- Module design and unit test LLM-as-judge quality metrics (completeness, logic quality, data structure precision, coverage quality, technique appropriateness, isolation strictness)
- E2E evaluation tests for module-design and unit-test commands (4 tests each)
- `docs/id-schema-guide.md` — Comprehensive guide to the four-tier ID schema, intra-level vs inter-level linking, lifecycle, and end-to-end traceability examples

### Changed
- Extension version bumped from 0.3.0 to 0.4.0
- setup-v-model.sh/ps1 now detects module-design.md and unit-test.md in AVAILABLE_DOCS; 8 symmetric require flags
- build-matrix.sh/ps1 extended with Matrix D generation
- trace.md updated from triple-matrix to quadruple-matrix output (A + B + C + D)
- Test fixture directories expanded from 6 to 8 V-Model files each (+module-design.md, +unit-test.md)
- Renamed `validate-coverage` → `validate-requirement-coverage` across all scripts, tests, docs, and specs for consistent `validate-{design-level}-coverage` naming convention
- Documentation updated for v0.4.0: README (12-step workflow, 9 commands, 4-tier ID schema), CONTRIBUTING, SECURITY, compliance-guide, usage-examples, v-model-config, v-model-overview, product-vision
- Total commands: 7 → 9; BATS tests: 67 → 91; Pester tests: 67 → 91; Structural evals: 37 → 51; LLM-as-judge evals: 26 → 36; E2E evals: 24 → 32

### Fixed
- BATS test for validate-system-coverage partial mode now correctly expects exit 0 (script was updated in v0.2.0 but test was not)
- PowerShell `validate-system-coverage.ps1` now supports partial mode when `system-test.md` is absent (parity with bash script)
- PowerShell `validate-system-coverage.ps1` handles empty files via null-coalescing (`Get-Content -Raw` returns `$null` for 0-byte files)
- Minimal module-design fixture now includes typed function signatures and complete type definitions for all pseudocode references

## [0.3.0] — 2026-02-21

### Added
- `architecture-design` command — IEEE 42010/Kruchten 4+1 architecture decomposition with Logical, Process, Interface, and Data Flow views
- `integration-test` command — ISO 29119-4 integration testing with Interface Contract, Data Flow, Fault Injection, and Concurrency techniques
- `validate-architecture-coverage.sh` / `validate-architecture-coverage.ps1` — Deterministic ARCH→ITP→ITS bidirectional coverage validation with CROSS-CUTTING module support
- Matrix C (Integration Verification) in traceability matrix — SYS → ARCH → ITP → ITS with parent REQ annotations
- `--require-system-design`, `--require-system-test`, `--require-architecture-design`, `--require-integration-test` flags for setup-v-model (bash + PowerShell)
- Architecture and integration test fixtures across all scenario directories (minimal, complex, gaps, empty, golden)
- Architecture-level validators (`architecture_validators.py`) and structural/E2E evaluations
- ARCH-NNN, ITP-NNN-X, ITS-NNN-X# ID patterns in id_validator.py
- CROSS-CUTTING module tag for infrastructure/utility architecture modules
- Pester test suite: `Validate-Architecture-Coverage.Tests.ps1` (15 tests)
- Architecture and integration LLM-as-judge quality metrics

### Changed
- Extension version bumped from 0.2.0 to 0.3.0
- setup-v-model.sh/ps1 now detects architecture-design.md and integration-test.md in AVAILABLE_DOCS; 6 symmetric require flags
- build-matrix.sh/ps1 extended with Matrix C generation
- trace.md updated from dual-matrix to triple-matrix output (A + B + C)
- Test fixture directories consolidated to shared scenario pattern (minimal, complex, gaps, empty) with 6 V-Model files each
- All Pester test fixture paths updated for consolidated directory structure
- Documentation updated for v0.3.0: README (9-step workflow, 7 commands, 3-tier ID schema), CONTRIBUTING, SECURITY, product-vision, v-model-config
- Total commands: 5 → 7; BATS tests: 48 → 67; Pester tests: 48 → 67; Structural evals: 21 → 37; LLM-as-judge evals: 16 → 26

## [0.2.0] — 2026-02-20

### Added

- `/speckit.v-model.system-design` command — Decomposes requirements into IEEE 1016-compliant system components
  - Four mandatory design views: Decomposition, Dependency, Interface, Data Design
  - Many-to-many REQ↔SYS traceability with derived requirements support
  - SYS-NNN ID schema with parent requirement references
- `/speckit.v-model.system-test` command — Generates ISO 29119-compliant system test plans
  - Named testing techniques: Interface Contract Testing, Boundary Value Analysis, Fault Injection, Equivalence Partitioning, State Transition Testing
  - Technical BDD scenarios (no user-journey language) with STP-NNN-X / STS-NNN-X# IDs
  - Anti-pattern guard: rejects user-journey phrasing in system-level tests
- Extended `/speckit.v-model.trace` command — Dual-matrix traceability output
  - Matrix A: REQ → ATP → SCN (acceptance-level, existing)
  - Matrix B: REQ → SYS → STP → STS (system-level, new)
  - Combined coverage metrics across both matrices
- System-level golden examples for evaluation:
  - Medical device (CBGMS): IEC 62304 Class C, 5 SYS components, 10 STP test cases
  - Automotive ADAS (AEB): ISO 26262 ASIL-D, 5 SYS components, 11 STP test cases
- E2E evaluation harness (`tests/evals/harness.py`) — faithfully simulates spec-kit command invocation via LLM
- 16 E2E evaluation tests (4 per command: structural + quality for each domain)
- Structural evaluations in PR CI (26 deterministic tests, no API keys required)
- Templates for system design and system test output documents
- Helper scripts for system-level coverage validation (Bash + PowerShell)

### Changed

- Template validators now accept both template-style ("Overview") and golden-fixture-style ("Document Control", "Test Strategy") sections
- `validate-requirement-coverage` and `build-matrix` scripts extended for dual-matrix support
- Evals workflow updated with E2E job for command invocation testing

## [0.1.0] — 2026-02-19

### Added

- Extension scaffold with `extension.yml` manifest (schema v1.0)
- `/speckit.v-model.requirements` command — Generates V-Model Requirements Specification
  - IEEE 29148 / INCOSE 8-criteria quality validation (Unambiguous, Testable, Atomic, Complete, Consistent, Traceable, Feasible, Necessary)
  - Banned words table enforcing measurable, testable language
  - Four requirement categories: Functional (REQ-), Non-Functional (REQ-NF-), Interface (REQ-IF-), Constraint (REQ-CN-)
  - Strict translator constraint for `spec.md` → `REQ-NNN` extraction
- `/speckit.v-model.acceptance` command — Generates three-tier Acceptance Test Plan
  - Test Cases (ATP-NNN-X) with 4 quality criteria (Traceable, Independent, Repeatable, Clear Expected Result)
  - BDD Scenarios (SCN-NNN-X#) with 4 quality criteria (Declarative, Single Action, Strict Preconditions, Observable Outcomes)
  - Batched generation (5 requirements per batch) to prevent token bloat
  - Deterministic 100% coverage validation gate via helper script
  - Append-only incremental updates with git diff change detection
- `/speckit.v-model.trace` command — Builds regulatory-grade Bidirectional Traceability Matrix
  - 4 pillars: Strict Bidirectionality, Orphan & Gap Analysis, Versioning & Baselines, Granular Execution State
  - 3-section output: Coverage Audit, Exception Report, 3D Matrix
  - Deterministic script-based matrix generation (not AI-generated)
- Output templates for requirements, acceptance plan, and traceability matrix
- Helper scripts (Bash + PowerShell):
  - `setup-v-model` — Directory setup and prerequisite checking
  - `validate-requirement-coverage` — Deterministic REQ→ATP→SCN coverage validation
  - `build-matrix` — Deterministic traceability matrix builder
  - `diff-requirements` — Detects changed/added requirements for incremental updates
- Extension configuration template (`config-template.yml`)
- Documentation:
  - `v-model-overview.md` — V-Model methodology context
  - `usage-examples.md` — Medical device (IEC 62304) and automotive (ISO 26262) examples
  - `compliance-guide.md` — Artifact mapping to IEC 62304, ISO 26262, DO-178C, FDA 21 CFR Part 820, IEC 61508
- `after_tasks` hook to automatically run traceability matrix after task generation
- Self-documenting three-tier ID schema: `REQ-NNN` → `ATP-NNN-X` → `SCN-NNN-X#`
