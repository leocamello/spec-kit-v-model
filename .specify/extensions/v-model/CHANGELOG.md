# Changelog

All notable changes to the V-Model Extension Pack are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
