# Changelog

All notable changes to the V-Model Extension Pack are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.6.0] — 2026-04-25

### Added — Domain Overlay Architecture

- **Domain overlay system** — all 11 V-Model commands are now domain-agnostic; a `domain:` field in `config-template.yml` activates the correct domain overlay (automotive, medical, aerospace, general)
- **9 domain overlay manifests** — one per command (`requirements`, `acceptance`, `system-design`, `system-test`, `architecture-design`, `integration-test`, `module-design`, `unit-test`, `hazard-analysis`), each declaring domain-specific standards, terminology substitutions, and output conventions
- **`domain-overlay/` directory structure** — `automotive/`, `medical/`, `aerospace/`, `general/` with per-command YAML manifests; enables brownfield adoption without changing core command logic
- **Feature specs dogfooded** — `specs/006a-domain-overlay/` full V-Model cycle (33 REQs, 42 ATPs, 9 SYS, 18 ARCH, 30 MODs, 62 UTPs, 207 UTSs, 4-matrix traceability)

### Added — ID Lifecycle Model

- **Explicit state machine** for all V-Model IDs: `Proposed → Active → Deprecated → Removed` with mandatory `## Lifecycle History` section in every artifact
- **Lifecycle history templates** added to all 9 V-Model command output templates and all agent prompts — append-only history preserves regulatory audit trail
- **Feature spec dogfooded** — `specs/006b-id-lifecycle/` full V-Model cycle (25 REQs, 9 SYS, 17 ARCH, 21 MODs, 33 UTPs, 107 UTSs, 4-matrix traceability)

### Added — Standards Enrichment

- **Governing Standards sections** added to all 11 commands — each command now declares the standards it applies and maps them to specific execution steps (e.g., `### Step 3. Quality Criteria (IEEE 1012:2016 / ISO 25010:2023)`)
- **Standards applied per command**: IEEE 1012:2016 (V&V), ISO 25010:2023 (quality attributes), ISO 42030:2019 (architecture evaluation), ISO 12207:2017 (software lifecycle), INCOSE SE Handbook, IEEE 1016, IEEE 29148, ISO 29119-4, ISO 14971, DO-178C, ARP4761A
- **`docs/standards-reference.md`** reconciled — §1.2 (Commands) and §2.3 (Standards) now in full agreement; missing domain overlays (automotive, medical, aerospace) added
- **All 11 agent definition files** synced with enriched command content in `.github/agents/`
- **V&V Coverage Gate** added to system-test, integration-test, unit-test, and audit-report commands (IEEE 1012:2016 §7 completeness criteria)
- **Architecture Evaluation step** added to architecture-design command (ISO 42030:2019 / ISO 25010:2023 quality attributes)
- **Quality attribute cross-check** added to system-design command (ISO 25010:2023 — Reliability, Safety, Maintainability, Portability)

### Added — Aerospace (DO-178C) Support

- **Flight Warning Computer (FWC) golden fixture** — DO-178C DAL-A avionics benchmark: 10 artifact files covering a 5-function FWC system (overspeed, stall, altitude alerting, GPWS, attitude limit) with ARP4761A hazard analysis, 9 SYS components, 9 ARCH modules
- **11 new LLM-as-judge eval tests** for the FWC domain (BDD quality, architecture completeness, FMEA completeness, operational state coverage, traceability, requirements quality, system design, system test, integration quality, module completeness, unit test quality)
- **`docs/brownfield-evolution-guide.md`** — step-by-step guide for adopting V-Model on existing projects

### Added — Test Infrastructure

- **`tests/fixtures/commands/`** namespace — `audit-report/` and `test-results/` command fixtures now live under `commands/` alongside `input/` and `expected/` sub-directories for clean separation from scenario fixtures
- **Audit-report expected outputs** — `expected/clean.md`, `expected/waived.md`, `expected/blocking.md` golden outputs for deterministic output comparison
- **DO-178C/DAL-A LLM eval benchmark** — `tests/fixtures/golden/flight-warning-computer/` with 10 expected artifact files; 11 `@pytest.mark.eval` tests across all eval files
- **Traceability eval timeout fix** — `_strip_non_traceability_sections()` helper strips `## Governing Standards` and `## Coverage Summary` from acceptance plan before LLM-judge payload, reducing medical device combined payload from 13.5 KB to 12.2 KB (within `gemini-2.5-flash` latency budget)
- **Minimal interface contract fixture** enriched — explicit types (`uint8`, `uint32`, `float32`, `uint16`, `enum`) and `Protocol:` fields added to all 3 ARCH modules; fixes `test_minimal_interface_contract_quality`

### Changed

- Extension version bumped from 0.5.0 to 0.6.0
- All 11 commands genericized — domain-specific terminology (ISO 26262 ASIL, IEC 62304 Class, DO-178C DAL) replaced with overlay-injected terminology controlled by the `domain:` config field
- `extension.yml` command descriptions rewritten to be domain-agnostic
- `specs/002` through `specs/005e` evolved with Standards Enrichment content (lifecycle history, governing standards, V&V coverage gates, quality attribute cross-checks)
- `specs/001-v-model-mvp` fully dogfooded — all 9 V-Model artifacts generated for the MVP spec
- `.gitignore` updated with `.env` and `.env.local` to prevent accidental credential commits

### Stats

- Commands: 14 (unchanged)
- Domain overlays: 0 → 9
- BATS tests: 364 (unchanged)
- Pester tests: 347 (unchanged)
- Structural evals: 89 (unchanged)
- LLM-as-judge evals: 42 → 53 (+11 DO-178C/DAL-A aerospace golden benchmark)
- Dogfooded feature specs: 5 → 7 (+006a domain overlay, +006b ID lifecycle)

## [0.5.0] — 2026-04-06

### Added — New Commands

- **`hazard-analysis`** — ISO 14971/26262 Failure Mode and Effects Analysis (FMEA) with `HAZ-NNN` hazard identifiers, operational state awareness, severity × likelihood risk matrix, mitigation traceability to REQ/SYS IDs, and progressive deepening (append-only at architecture level)
  - `hazard-analysis-template.md` — FMEA table template with 10 columns
  - `validate-hazard-coverage.sh` / `validate-hazard-coverage.ps1` — Three-dimensional deterministic validator: forward (SYS→HAZ), backward (HAZ→REQ/SYS), and operational state consistency checks with `--partial` and `--json` flags
  - Matrix H (Hazard Traceability) in traceability matrix — HAZ → Mitigation → Verification linkage
  - HAZ-NNN ID pattern in `id_validator.py`
- **`impact-analysis`** — Deterministic change impact analysis that builds a dependency graph from all V-Model markdown artifacts and traverses it to identify suspect artifacts affected by a change
  - `--downward` (default), `--upward`, and `--full` bidirectional traversal modes
  - `--json` flag for CI integration (structured JSON with blast radius, suspect artifacts by level, re-validation order)
  - Multi-ID support, <2s for 500+ IDs across 10+ artifact files
  - `impact-analysis.sh` / `impact-analysis.ps1` — Bash and PowerShell scripts with awk-based graph parser and BFS traversal
- **`peer-review`** — AI-powered stateless linter for any V-Model artifact, evaluating against standards-based criteria (INCOSE, IEEE 1016/42010, ISO 29119, ISO 14971, DO-178C) and producing `PRF-{ARTIFACT}-NNN` findings with severity classifications (Critical, Major, Minor, Observation)
  - Stateless linting model: findings regenerated from scratch each run, like ESLint
  - `peer-review-check.sh` / `Peer-Review-Check.ps1` — CI parser scripts with exit codes: 0 (clean), 1 (Critical/Major — blocks PR), 2 (Minor — warning)
- **`test-results`** — 100% deterministic JUnit XML + Cobertura XML ingestor that updates the traceability matrix in-place, flipping `⬜ Untested` to `✅ Passed` / `❌ Failed` / `⏭️ Skipped` with Date, Commit SHA, and optional Coverage columns
  - `parse_test_results.py` — stdlib-only Python helper (xml.etree.ElementTree) with 5 modules
  - `ingest-test-results.sh` / `Ingest-Test-Results.ps1` — Bash and PowerShell wrappers (1:1 parity)
  - Coverage mapping via `coverage-map.yml` or convention-based matching from `module-design.md`
- **`audit-report`** — 100% deterministic release audit report builder that produces a point-in-time `release-audit-report.md` for regulatory submission
  - Artifact inventory, traceability matrix embedding, coverage analysis, hazard management summary
  - Anomaly detection with waiver cross-referencing via `waivers.md` (WAV-NNN entries)
  - Compliance gating: ✅ RELEASE READY / ⚠️ RELEASE CANDIDATE / ❌ NOT READY
  - `build-audit-report.sh` / `Build-Audit-Report.ps1` — Bash and PowerShell scripts (1:1 parity)

### Added — Release Enhancements

- `validate-level.sh` / `Validate-Level.ps1` — Dispatch wrapper that invokes the correct validator for any V-Model level (acceptance → requirement-coverage, system-test → system-coverage, integration-test → architecture-coverage, unit-test → module-coverage, hazard-analysis → hazard-coverage) with `--json` and `--partial` flag support
- Agent definitions (`.github/agents/`) for all 14 commands — previously only 3 existed (requirements, acceptance, trace); now all commands have full agent prompts
- Sample CI workflow template (`examples/github-actions/v-model-validation.yml`) — configurable GitHub Actions workflow with conditional validators, GITHUB_STEP_SUMMARY, peer review check, and audit report generation
- 56 V-Model specification documents promoted from Draft to Approved across specs/002–005e

### Added — Test Infrastructure

- Hazard analysis fixtures: minimal (5 HAZ), complex (12 HAZ), gaps, golden/automotive-adas (15 HAZ, ISO 26262), golden/medical-device (12 HAZ, ISO 14971)
- Impact analysis fixtures: linear, diamond, disconnected — with 17 golden JSON outputs
- Peer review fixtures: clean, critical-major, minor-only, mixed-severity, observations-only
- Test results fixtures: 8 JUnit XML scenarios, 2 Cobertura XML, 3 matrix fixtures, 10 golden JSON outputs
- Audit report fixtures: clean, waived, blocking, orphaned-waiver, missing-required — with golden `.md` + `.json` outputs
- Validate-level fixtures reusing existing minimal/gaps directories
- Python structural validators: `hazard_validators.py`, `impact_validators.py`
- DeepEval metric wrappers: `StructuralHazardAnalysisMetric`, `StructuralImpactAnalysisMetric`

### Added — Dogfooded V-Model Artifacts

- `specs/005a-hazard-analysis/` — full V-Model cycle for hazard-analysis command
- `specs/005b-impact-analysis/` — full V-Model cycle for impact-analysis command
- `specs/005c-peer-review/` — full V-Model cycle for peer-review command (37 REQs, 74 ATPs)
- `specs/005d-test-results/` — full V-Model cycle for test-results command (30 REQs, 53 UTSs)
- `specs/005e-audit-report/` — full V-Model cycle for audit-report command

### Changed

- `build-matrix.sh` / `build-matrix.ps1` extended with Matrix H generation block (auto-detected when hazard-analysis.md exists)
- `trace` command updated for five-matrix output (A + B + C + D + H)
- `classify_id()` in both Bash and PowerShell now maps ALL compound prefixes (e.g., `SYS-DR`, `REQ-DR`) to their base V-Model level
- `extension.yml` updated with all 5 new commands (14 total) and `peer_review_findings: "PRF"` ID prefix
- Documentation updated: README, compliance-guide, id-schema-guide, usage-examples, product-vision, v-model-overview, CONTRIBUTING

### Stats

- Commands: 9 → 14
- Bash scripts: 7 → 13 (+ validate-hazard-coverage, validate-level, impact-analysis, peer-review-check, ingest-test-results, build-audit-report)
- PowerShell scripts: 7 → 13 (+ Validate-Hazard-Coverage, Validate-Level, Impact-Analysis, Peer-Review-Check, Ingest-Test-Results, Build-Audit-Report)
- BATS tests: 91 → 364
- Pester tests: 91 → 347
- Structural evals: 51 → 89
- LLM-as-judge evals: 36 → 42
- Agent definitions: 3 → 14

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
