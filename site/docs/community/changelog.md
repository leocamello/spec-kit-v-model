---
title: Changelog
description: Complete version history of the V-Model Extension Pack for Spec Kit — all notable changes, new commands, and improvements documented per release.
---

# Changelog

All notable changes to the V-Model Extension Pack are documented here. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## v0.6.0 — Foundation Hardening — 2026-04-23

### Changed — Domain Overlay Architecture

- Decoupled all domain-specific safety content from 14 base commands into `commands/overlays/{iso_26262,do_178c,iec_62304}/` directories
- Base commands now contain only best-practice standards (IEEE, ISO/IEC); safety-specific content (ASIL tables, DAL classifications, etc.) loaded at runtime via `domain:` in `v-model-config.yml`
- Added `domain:` field to `config-template.yml` (values: empty, `iso_26262`, `do_178c`, `iec_62304`)
- Added assembly protocol: domain loading step at the top of each command's System Prompt
- Created 36 overlay files (12 commands × 3 domains) with `_domain.yml` manifests

### Changed — ID Lifecycle Model

- Extended formal ID lifecycle model to all 8 generative commands (previously only `acceptance` had partial support)
- Added `[DEPRECATED — Superseded by {ID}]` and `[DEPRECATED — Withdrawn: <reason>]` syntax to all commands
- Added suspect cascade: downstream items automatically marked `[SUSPECT — Parent {ID} deprecated]` when parent is deprecated
- Each command now includes a "Lifecycle Rules" section governing evolution behavior

### Changed — Standards Enrichment

- Enriched all 11 base commands with explicit `## Governing Standards` sections
- Integrated ISO/IEC 25010:2023 quality characteristics into requirements (NFR section) and system-design output
- Integrated IEEE 1012:2016 V&V gates into acceptance, system-test, integration-test, and unit-test output
- Integrated ISO/IEC 42030:2019 architecture evaluation into architecture-design output
- Total standards referenced: 26 (17 best-practice + 9 safety-specific, up from 17)

### Changed — Dogfooding

- Evolved V-Model artifact chains for features 002–005e through ID lifecycle model
- Created complete V-Model chain for feature 006 (foundation infrastructure)
- All 89 structural evals updated to validate new standards sections; 364 BATS tests still pass

### Stats

| Metric | Before (v0.5.0) | After (v0.6.0) |
|--------|-------:|------:|
| Commands | 14 | 14 |
| Domain overlays | 0 | 36 |
| Standards referenced | 17 | 26 |
| Structural evals | 89 | 89 |
| BATS tests | 364 | 364 |
| Standards sections in artifacts | 0 | 11 commands × 2+ sections |

---

## v0.5.0 — 2026-04-06

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

- `validate-level.sh` / `Validate-Level.ps1` — Dispatch wrapper that invokes the correct validator for any V-Model level with `--json` and `--partial` flag support
- Agent definitions (`.github/agents/`) for all 14 commands — previously only 3 existed
- Sample CI workflow template (`examples/github-actions/v-model-validation.yml`)
- 56 V-Model specification documents promoted from Draft to Approved

### Added — Test Infrastructure

- Hazard analysis fixtures: minimal (5 HAZ), complex (12 HAZ), gaps, golden/automotive-adas (15 HAZ), golden/medical-device (12 HAZ)
- Impact analysis fixtures: linear, diamond, disconnected — with 17 golden JSON outputs
- Peer review fixtures: clean, critical-major, minor-only, mixed-severity, observations-only
- Test results fixtures: 8 JUnit XML scenarios, 2 Cobertura XML, 3 matrix fixtures, 10 golden JSON outputs
- Audit report fixtures: clean, waived, blocking, orphaned-waiver, missing-required — with golden outputs
- Python structural validators: `hazard_validators.py`, `impact_validators.py`
- DeepEval metric wrappers: `StructuralHazardAnalysisMetric`, `StructuralImpactAnalysisMetric`

### Changed

- `build-matrix.sh` / `build-matrix.ps1` extended with Matrix H generation block
- `trace` command updated for five-matrix output (A + B + C + D + H)
- `classify_id()` in both Bash and PowerShell now maps ALL compound prefixes
- `extension.yml` updated with all 5 new commands (14 total)
- Documentation updated across README, compliance-guide, id-schema-guide, usage-examples, product-vision, v-model-overview, and CONTRIBUTING

### Stats

| Metric | Before | After |
|--------|-------:|------:|
| Commands | 9 | 14 |
| Bash scripts | 7 | 13 |
| PowerShell scripts | 7 | 13 |
| BATS tests | 91 | 364 |
| Pester tests | 91 | 347 |
| Structural evals | 51 | 89 |
| LLM evals | 36 | 42 |
| Agent definitions | 3 | 14 |

---

## v0.4.0 — 2026-02-22

### Added

- **`module-design`** command — DO-178C/ISO 26262-compliant low-level module designs with four mandatory views (Algorithmic/Logic, State Machine, Internal Data Structures, Error Handling & Return Codes)
- **`unit-test`** command — ISO 29119-4 white-box unit test plans with five named techniques and Dependency & Mock Registries
- `validate-module-coverage.sh` / `validate-module-coverage.ps1` — Deterministic ARCH→MOD→UTP→UTS bidirectional coverage validation with EXTERNAL and CROSS-CUTTING module support
- Matrix D (Unit Verification) in traceability matrix
- Module design and unit test fixtures across all scenario directories
- Module-level validators and structural/E2E evaluations
- MOD-NNN, UTP-NNN-X, UTS-NNN-X# ID patterns
- `docs/id-schema-guide.md` — Comprehensive guide to the four-tier ID schema

### Changed

- Extension version bumped from 0.3.0 to 0.4.0
- `setup-v-model` now detects `module-design.md` and `unit-test.md`; 8 symmetric require flags
- `build-matrix` extended with Matrix D generation
- `trace` command updated from triple-matrix to quadruple-matrix output (A + B + C + D)
- Renamed `validate-coverage` → `validate-requirement-coverage` for consistent naming

### Fixed

- BATS test for `validate-system-coverage` partial mode now correctly expects exit 0
- PowerShell `validate-system-coverage.ps1` now supports partial mode when `system-test.md` is absent
- PowerShell `validate-system-coverage.ps1` handles empty files via null-coalescing
- Minimal module-design fixture now includes typed function signatures

### Stats

Commands: 7 → 9 · BATS: 67 → 91 · Pester: 67 → 91 · Structural evals: 37 → 51 · LLM evals: 26 → 36

---

## v0.3.0 — 2026-02-21

### Added

- **`architecture-design`** command — IEEE 42010/Kruchten 4+1 architecture decomposition with Logical, Process, Interface, and Data Flow views
- **`integration-test`** command — ISO 29119-4 integration testing with Interface Contract, Data Flow, Fault Injection, and Concurrency techniques
- `validate-architecture-coverage.sh` / `validate-architecture-coverage.ps1` — Deterministic ARCH→ITP→ITS bidirectional coverage validation with CROSS-CUTTING module support
- Matrix C (Integration Verification) in traceability matrix
- Architecture and integration test fixtures across all scenario directories
- Architecture-level validators and structural/E2E evaluations
- ARCH-NNN, ITP-NNN-X, ITS-NNN-X# ID patterns
- CROSS-CUTTING module tag for infrastructure/utility architecture modules

### Changed

- Extension version bumped from 0.2.0 to 0.3.0
- `build-matrix` extended with Matrix C generation
- `trace` command updated from dual-matrix to triple-matrix output (A + B + C)
- Test fixture directories consolidated to shared scenario pattern

### Stats

Commands: 5 → 7 · BATS: 48 → 67 · Pester: 48 → 67 · Structural evals: 21 → 37 · LLM evals: 16 → 26

---

## v0.2.0 — 2026-02-20

### Added

- **`system-design`** command — IEEE 1016-compliant system component decomposition with four mandatory design views (Decomposition, Dependency, Interface, Data Design)
- **`system-test`** command — ISO 29119-compliant system test plans with named testing techniques and technical BDD scenarios
- Extended `trace` command — Dual-matrix traceability output (Matrix A + Matrix B)
- System-level golden examples for medical device (CBGMS) and automotive ADAS (AEB)
- E2E evaluation harness (`tests/evals/harness.py`)
- Templates and helper scripts for system design and system test
- Structural evaluations in PR CI (26 deterministic tests)

### Changed

- Template validators now accept both template-style and golden-fixture-style sections
- `validate-requirement-coverage` and `build-matrix` scripts extended for dual-matrix support
- Evals workflow updated with E2E job

---

## v0.1.0 — 2026-02-19

### Added

- Extension scaffold with `extension.yml` manifest (schema v1.0)
- **`requirements`** command — IEEE 29148 / INCOSE 8-criteria quality validation with four requirement categories (Functional, Non-Functional, Interface, Constraint)
- **`acceptance`** command — Three-tier Acceptance Test Plan with test cases (`ATP-NNN-X`), BDD scenarios (`SCN-NNN-X#`), deterministic coverage validation, and append-only incremental updates
- **`trace`** command — Regulatory-grade Bidirectional Traceability Matrix with 4 pillars (Strict Bidirectionality, Orphan & Gap Analysis, Versioning & Baselines, Granular Execution State)
- Output templates for requirements, acceptance plan, and traceability matrix
- Helper scripts (Bash + PowerShell): `setup-v-model`, `validate-requirement-coverage`, `build-matrix`, `diff-requirements`
- Extension configuration template (`config-template.yml`)
- Documentation: `v-model-overview.md`, `usage-examples.md`, `compliance-guide.md`
- `after_tasks` hook for automatic traceability matrix generation
- Self-documenting three-tier ID schema: `REQ-NNN` → `ATP-NNN-X` → `SCN-NNN-X#`

---

!!! info "See also"

    - [Roadmap](roadmap.md) — What's coming next
    - [Contributing Guide](contributing.md) — How to get involved
