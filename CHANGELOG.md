# Changelog

All notable changes to the V-Model Extension Pack are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] — test-results (005d)

### Added
- `test-results` command — 100% deterministic (no AI) JUnit XML + Cobertura XML ingestor that updates the traceability matrix in-place, flipping `⬜ Untested` to `✅ Passed` / `❌ Failed` / `⏭️ Skipped` with Date, Commit SHA, and optional Coverage columns
  - JUnit XML parsing: extracts V-Model IDs (SCN/STS/ITS/UTS) from test case names via regex, handles retries (last occurrence wins), multi-suite support
  - Cobertura XML parsing: maps code coverage to modules via `coverage-map.yml` or convention-based matching from `module-design.md`, adds `{stmt}% stmt / {branch}% branch` column to Matrix D with `⚠` threshold warnings
  - In-place matrix update: modifies existing `traceability-matrix.md`, preserves unmatched rows and non-table content, adds Date + Commit columns on first run
  - Re-run safe: subsequent runs overwrite previous status/date/commit values
  - Exit codes: 0 = all passed, 1 = failures detected, 2 = no V-Model ID matches
  - `--json` flag for CI integration (structured JSON with per-matrix counts, coverage data, matrix path)
- `parse_test_results.py` — stdlib-only Python helper (xml.etree.ElementTree, json, re, sys, argparse) with 5 modules: extract_testcases, classify_results, extract_coverage, map_coverage_to_modules, match_ids
- `ingest-test-results.sh` / `Ingest-Test-Results.ps1` — Bash and PowerShell wrappers (1:1 parity) that call the Python helper, update the matrix, and print summary
- 23 test fixtures: 8 JUnit XML scenarios (all-pass, mixed, all-fail, all-skipped, no-matches, with-retries, multi-suite, extra-ids), 2 Cobertura XML (full/partial), 3 matrix fixtures, 10 golden JSON outputs
- 61 BATS tests (`ingest-test-results.bats`): Python helper golden validation, exit codes, ID matching, retry dedup, summary counts, coverage mapping, wrapper help/args/exit/matrix/re-run/summary/JSON/coverage
- 61 Pester tests (`Ingest-Test-Results.Tests.ps1`): 1:1 parity with BATS
- Dogfooded V-Model artifacts for test-results feature (`specs/005d-test-results/`): 30 REQs, 44 ATPs, 50 SCNs, 7 SYS, 31 STPs, 45 STSs, 9 ARCH, 13 ITPs, 21 ITSs, 9 MODs, 27 UTPs, 53 UTSs, full traceability matrices

### Changed
- `extension.yml`: registered `speckit.v-model.test-results` command (13th command)
- Documentation updated: README (13 commands, test-results in workflow + Features + Command Reference + Scripts table + testing counts), CHANGELOG
- Total commands: 12 → 13; BATS tests: 208 → 269; Pester tests: 191 → 252

## [Unreleased] — peer-review (005c)

### Added
- `peer-review` command — AI-powered stateless linter for any V-Model artifact, evaluating against standards-based criteria (INCOSE for requirements, IEEE 1016/42010 for design, ISO 29119/29119-4 for tests, ISO 14971 for hazard analysis, DO-178C for module design) and producing `PRF-{ARTIFACT}-NNN` findings with severity classifications (Critical, Major, Minor, Observation)
  - 9 supported artifact types with type-specific review criteria
  - Stateless linting model: no `Status` field — findings regenerated from scratch each run, like ESLint
  - Advisory-only: PRF IDs do not participate in traceability chain or affect coverage metrics
  - CI-hookable via companion parser scripts
- `peer-review-template.md` — Output format template with header, summary table, and per-finding structure
- `peer-review-check.sh` / `Peer-Review-Check.ps1` — Deterministic CI parser scripts that read AI-generated peer-review reports and return exit codes: 0 (clean), 1 (Critical/Major — blocks PR), 2 (Minor — warning)
  - `--json` / `-Json` flag for structured output (severity counts, PRF heading cross-validation, summary match check)
  - `--help` / `-Help` flag for usage information
- 5 peer-review test fixture scenarios: clean (0 findings), critical-major (exit 1), minor-only (exit 2), mixed-severity (all 4 levels), observations-only (exit 0), each with `.md` report and `.json` golden output
- 38 BATS tests (`peer-review-check.bats`): all fixture scenarios, severity counting, PRF cross-validation, metadata extraction, error handling, JSON structure
- 38 Pester tests (`Peer-Review-Check.Tests.ps1`): 1:1 parity with BATS
- Dogfooded V-Model artifacts for peer-review feature (`specs/005c-peer-review/`): 37 REQs, 74 ATPs, 6 SYS, 25 STPs, 10 ARCH, 25 ITPs, 16 MODs, 48 UTPs, full traceability matrices

### Changed
- `extension.yml`: registered `speckit.v-model.peer-review` command (12th command), added `peer_review_findings: "PRF"` to `defaults.id_prefixes`
- Documentation updated: README (12 commands, peer-review in workflow + Features + Command Reference + Scripts table + directory tree), CHANGELOG
- Total commands: 11 → 12; BATS tests: 170 → 208; Pester tests: 153 → 191

## [Unreleased] — impact-analysis (005b)

### Added
- `impact-analysis` command — Deterministic change impact analysis that builds a dependency graph from all V-Model markdown artifacts and traverses it to identify suspect artifacts affected by a change
  - `--downward` mode: trace from requirements to tests/modules (default)
  - `--upward` mode: trace from modules/tests back to requirements
  - `--full` mode: bidirectional traversal combining both directions
  - `--json` flag for CI integration (structured JSON output with blast radius, suspect artifacts by level, re-validation order)
  - Multi-ID support: analyze impact of multiple changed IDs in a single run
  - Performance: <2s for 500+ IDs across 10+ artifact files
- `impact-analysis.sh` / `impact-analysis.ps1` — Bash and PowerShell scripts with awk-based graph parser, BFS traversal, and V-Model level classification
- `commands/impact-analysis.md` — Command definition with usage examples, exit codes, and quality criteria
- Impact-specific test fixtures: `linear/` (simple chain), `diamond/` (fan-out/fan-in), `disconnected/` (isolated subgraphs)
- 17 golden JSON output files across 6 fixture sets × 3 traversal modes
- Python structural validator (`impact_validators.py`): 8 validation functions (JSON structure, direction, changed IDs, suspect artifacts, blast radius consistency, revalidation order, no self-reference)
- `StructuralImpactAnalysisMetric` DeepEval metric wrapper
- 30 evaluation tests: 17 structural, 8 golden comparison, 5 graph property tests
- 32 BATS tests (`impact-analysis.bats`): all fixtures, all modes, golden comparison, error handling, structural validation, performance
- 14 Pester tests (`Impact-Analysis.Tests.ps1`): PowerShell parity
- Dogfooded V-Model artifacts for impact-analysis feature (`specs/005b-impact-analysis/`)

### Changed
- `classify_id()` in both Bash and PowerShell now maps ALL compound prefixes (e.g., `SYS-DR`, `REQ-DR`) to their base V-Model level, not just `REQ-NF/IF/CN` and `ATP-NF/IF/CN`
- Documentation updated: README (11 commands, impact-analysis in workflow + Features + Command Reference), compliance-guide (new Change Impact Analysis section, moved from Future to implemented), id-schema-guide (SYS-DR compound prefix, impact-analysis in Incremental Updates), usage-examples (expanded Example 3 with impact-first workflow), product-vision (marked as shipped), v-model-overview (impact-analysis reference), CONTRIBUTING (test counts + fixtures)
- Total commands: 10 → 11; BATS tests: 117 → 153; Pester tests: 111 → 129; Structural evals: 60 → 89; LLM-as-judge evals: 42 (unchanged)

## [Unreleased] — hazard-analysis (005a)

### Added
- `hazard-analysis` command — ISO 14971/26262 Failure Mode and Effects Analysis (FMEA) with `HAZ-NNN` hazard identifiers, operational state awareness, severity × likelihood risk matrix, mitigation traceability to REQ/SYS IDs, and progressive deepening (append-only at architecture level)
- `hazard-analysis-template.md` — FMEA table template with 10 columns (HAZ ID, Component, Failure Mode, Operational State, Effect, Severity, Likelihood, Risk Level, Mitigation, Residual Risk)
- `validate-hazard-coverage.sh` / `validate-hazard-coverage.ps1` — Three-dimensional deterministic validator: forward (SYS→HAZ), backward (HAZ→REQ/SYS), and operational state consistency checks with `--partial` and `--json` flags
- Matrix H (Hazard Traceability) in traceability matrix — HAZ → Mitigation → Verification linkage
- HAZ-NNN ID pattern in `id_validator.py`
- Hazard analysis fixtures: minimal (5 HAZ), complex (12 HAZ, 3 states), gaps (3 HAZ, intentional coverage gaps), golden/automotive-adas (15 HAZ, ISO 26262, 5 states), golden/medical-device (12 HAZ, ISO 14971, 4 states)
- Python structural validator (`hazard_validators.py`): FMEA row parsing, HAZ ID validation, severity/likelihood/risk scale checks, SYS coverage, mitigation reference validation
- `StructuralHazardAnalysisMetric` DeepEval metric wrapper
- 3 LLM-as-judge GEval metrics: FMEA completeness, severity assessment quality, operational state coverage
- 9 structural + 6 LLM-as-judge evaluation tests
- 26 BATS tests (`validate-hazard-coverage.bats`)
- 20 Pester tests (`Validate-Hazard-Coverage.Tests.ps1`)
- Dogfooded V-Model artifacts for hazard-analysis feature (`specs/005a-hazard-analysis/`)

### Changed
- `build-matrix.sh` / `build-matrix.ps1` extended with Matrix H generation block (auto-detected when hazard-analysis.md exists)
- `trace.md` updated for five-matrix output (A + B + C + D + H)
- Complex and golden system-design fixtures updated with Operational States sections
- Documentation updated: README (10 commands, 13-step workflow, Matrix H), id-schema-guide (13 ID types), compliance-guide (Section 8: Hazard Analysis, Matrix H), v-model-overview (Hazard Analysis section), usage-examples, product-vision, CONTRIBUTING
- Total commands: 9 → 10; BATS tests: 91 → 117; Pester tests: 91 → 111; Structural evals: 51 → 60; LLM-as-judge evals: 36 → 42

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
