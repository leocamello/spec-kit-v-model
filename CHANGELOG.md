# Changelog

All notable changes to the V-Model Extension Pack are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
- `validate-coverage` and `build-matrix` scripts extended for dual-matrix support
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
  - `validate-coverage` — Deterministic REQ→ATP→SCN coverage validation
  - `build-matrix` — Deterministic traceability matrix builder
  - `diff-requirements` — Detects changed/added requirements for incremental updates
- Extension configuration template (`config-template.yml`)
- Documentation:
  - `v-model-overview.md` — V-Model methodology context
  - `usage-examples.md` — Medical device (IEC 62304) and automotive (ISO 26262) examples
  - `compliance-guide.md` — Artifact mapping to IEC 62304, ISO 26262, DO-178C, FDA 21 CFR Part 820, IEC 61508
- `after_tasks` hook to automatically run traceability matrix after task generation
- Self-documenting three-tier ID schema: `REQ-NNN` → `ATP-NNN-X` → `SCN-NNN-X#`
