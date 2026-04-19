# System Design: V-Model Extension Pack MVP

**Feature Branch**: `001-v-model-mvp`
**Created**: 2026-04-18
**Status**: Draft
**Source**: `specs/001-v-model-mvp/v-model/requirements.md`

## Overview

The V-Model Extension Pack MVP is decomposed into twelve system components organized around three AI-powered slash commands and their supporting infrastructure. The architecture separates generative subsystems (SYS-001, SYS-002) from deterministic verification modules (SYS-003, SYS-004, SYS-005), cross-cutting concerns (SYS-007, SYS-009, SYS-011), and infrastructure services (SYS-006, SYS-008, SYS-010, SYS-012). This separation enforces the principle that no AI agent verifies its own output — deterministic scripts independently validate every generative artifact.

## ID Schema

- **System Component**: `SYS-NNN` — sequential identifier for each component
- **Parent Requirements**: Comma-separated `REQ-NNN` list per component (many-to-many)
- Example: `SYS-004` with Parent Requirements `REQ-008, REQ-011, REQ-020, REQ-021, REQ-NF-002` — component satisfies all five requirements

## Decomposition View (IEEE 1016 §5.1)

| SYS ID | Name | Description | Parent Requirements | Type |
|--------|------|-------------|---------------------|------|
| SYS-001 | Requirements Generation Engine | AI-powered command processor that transforms feature descriptions and spec.md into structured requirements documents. Handles requirement extraction, quality validation against eight criteria, vague term replacement with measurable language, unique ID assignment (REQ-NNN), four-category classification, and error reporting for empty input. | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-022, REQ-NF-004 | Subsystem |
| SYS-002 | Acceptance Test Plan Generator | AI-powered command processor that generates three-tier acceptance test plans from requirements.md. Produces ATP-NNN-X test cases and SCN-NNN-X# BDD scenarios with lineage-encoding IDs. Enforces 100% bidirectional REQ→ATP→SCN coverage. Validates completeness against IEEE 1012:2016 V&V principles including entry/exit criteria and validation vs. verification distinction. | REQ-006, REQ-007, REQ-008, REQ-019 | Subsystem |
| SYS-003 | Traceability Matrix Builder | Deterministic script (`build-matrix.sh`) that constructs bidirectional Requirements Traceability Matrices by parsing requirements.md and acceptance-plan.md using regex-based extraction. Computes coverage percentages, identifies gaps and orphans in an exception report, records baseline information (timestamps, source files), and flags non-compliant status when SUSPECT tags are detected. | REQ-009, REQ-010, REQ-011, REQ-025, REQ-NF-003 | Subsystem |
| SYS-004 | Coverage Validation Engine | Deterministic script (`validate-requirement-coverage.sh`) that verifies 100% bidirectional REQ→ATP and ATP→SCN coverage. Returns exit code 0 for full coverage and exit code 1 for gaps. Supports `--json` flag producing machine-readable output with `has_gaps`, `reqs_without_atp`, `atps_without_scn`, and coverage percentage fields. Guarantees identical outputs for identical inputs regardless of AI model version. | REQ-008, REQ-011, REQ-020, REQ-021, REQ-NF-002 | Module |
| SYS-005 | Change Detection Module | Deterministic script (`diff-requirements.sh`) that compares the working copy of requirements.md against the last Git-committed version using `git diff`. Identifies added, modified, and removed requirement IDs to enable incremental acceptance plan updates rather than full regeneration. | REQ-015 | Module |
| SYS-006 | V-Model Setup Service | Initialization script (`setup-v-model.sh` / `setup-v-model.ps1`) that resolves feature directories from branch names, validates prerequisites (Git repository, Spec Kit installation, V-Model extension registration), discovers available documents, and produces a structured JSON configuration object for all downstream commands. Supports `--require-reqs` and `--require-acceptance` flags for prerequisite enforcement. | REQ-IF-003, REQ-CN-001 | Service |
| SYS-007 | Domain Overlay Loader | The assembly protocol implementation that loads domain-specific guidance when a domain is configured in `v-model-config.yml`. Reads command overlays from `commands/overlays/{domain}/{command}.md` and template overlays from `templates/overlays/{domain}/{template}.md`. Degrades gracefully to base-only operation when no domain is configured or overlay files are absent. | REQ-017, REQ-018, REQ-NF-001 | Module |
| SYS-008 | Artifact Storage Manager | File output layer that writes all generated V-Model artifacts as plaintext Markdown to the Git-tracked `specs/{feature}/v-model/` directory. Enforces file naming conventions (`requirements.md`, `acceptance-plan.md`, `traceability-matrix.md`), directory structure, and English language constraint for all artifacts. | REQ-016, REQ-CN-002 | Module |
| SYS-009 | ID Lifecycle Manager | Cross-cutting component that enforces ID permanence and lifecycle state management across all V-Model artifacts. Supports state transitions (Active, `[DEPRECATED — Superseded by ...]`, `[DEPRECATED — Withdrawn: ...]`, `[MODIFIED]`, `[SUSPECT — Parent ... modified/deprecated]`). Ensures deprecated items remain in documents with original IDs, accepts gaps in numbering, and provides incremental ID assignment (next available sequential). | REQ-012, REQ-013, REQ-014, REQ-023 | Module |
| SYS-010 | Command Input Processor | Input handling layer for the requirements command that accepts multiple input modes: `spec.md` file (primary), inline user text arguments, or both (spec.md as primary with text as supplementary context). Resolves the primary source of truth and enforces output conformance to the structure defined in `templates/requirements-template.md`. | REQ-IF-001, REQ-IF-002 | Module |
| SYS-011 | Error Handling Framework | Cross-cutting error handling component that ensures descriptive error messages for empty input, missing prerequisites, malformed Markdown, and other failure conditions. Prevents corrupt output propagation through the V-Model chain by failing gracefully before writing artifacts. | REQ-022, REQ-024 | Utility |
| SYS-012 | AI Runtime Interface | Interface boundary to the AI assistant (GitHub Copilot or equivalent) that executes generative slash commands. Provides the runtime context (command prompts, tool access, file system I/O) for SYS-001 and SYS-002 command execution. Non-generative components (SYS-003, SYS-004, SYS-005) operate independently of this interface. | REQ-CN-003 | Service |

## Dependency View (IEEE 1016 §5.2)

| Source | Target | Relationship | Failure Impact |
|--------|--------|-------------|----------------|
| SYS-001 | SYS-006 | Calls | Command fails to initialize; cannot resolve feature paths or validate prerequisites |
| SYS-001 | SYS-010 | Uses | No parsed input available; triggers error path (REQ-022) for empty input |
| SYS-001 | SYS-007 | Reads | No domain overlay loaded; degrades gracefully to base-only generation |
| SYS-001 | SYS-009 | Uses | Cannot apply lifecycle rules; risk of ID renumbering or deleted items on incremental updates |
| SYS-001 | SYS-012 | Requires | Command cannot execute; no AI runtime to process generative prompt |
| SYS-001 | SYS-008 | Writes | Generated requirements lost; output not persisted to Git-tracked directory |
| SYS-001 | SYS-011 | Uses | Silent failures instead of descriptive error messages |
| SYS-002 | SYS-001 | Reads output | Cannot generate acceptance plan without requirements.md as input |
| SYS-002 | SYS-006 | Calls | Command fails to initialize; `--require-reqs` validation unavailable |
| SYS-002 | SYS-007 | Reads | No domain overlay loaded; degrades gracefully to base-only generation |
| SYS-002 | SYS-009 | Uses | Cannot apply lifecycle rules to ATPs/SCNs during incremental updates |
| SYS-002 | SYS-012 | Requires | Command cannot execute; no AI runtime available |
| SYS-002 | SYS-008 | Writes | Generated acceptance plan lost; output not persisted |
| SYS-003 | SYS-001 | Reads output | Cannot build matrix without requirements.md; exits with error |
| SYS-003 | SYS-002 | Reads output | Cannot build Matrix A without acceptance-plan.md; exits with error |
| SYS-003 | SYS-006 | Calls | Cannot resolve V-Model directory path |
| SYS-003 | SYS-009 | Reads tags | Cannot detect SUSPECT tags; silent acceptance of non-compliant artifacts |
| SYS-003 | SYS-008 | Writes | Generated matrix lost; output not persisted |
| SYS-004 | SYS-001 | Reads output | Cannot validate coverage without requirements.md |
| SYS-004 | SYS-002 | Reads output | Cannot validate coverage without acceptance-plan.md |
| SYS-005 | SYS-001 | Reads output | Cannot diff without requirements.md in working copy and Git history |
| SYS-010 | SYS-006 | Reads | Cannot determine available input sources (spec.md, text arguments) |

### Dependency Diagram

```text
                    ┌──────────────┐
                    │  SYS-012     │
                    │  AI Runtime  │
                    └──────┬───────┘
                           │ requires
                    ┌──────┴───────┐
           ┌────── │  SYS-001     │ ──────┐
           │       │  Requirements│        │
           │       │  Gen Engine  │        │
           │       └──┬────┬──┬──┘        │
           │          │    │  │            │
    reads  │   uses   │    │  │ reads      │ writes
   output  │          │    │  │ output     │
           ▼          │    │  ▼            ▼
    ┌──────────┐      │    │  ┌────────┐  ┌────────┐
    │ SYS-002  │◄─────┘    │  │SYS-005 │  │SYS-008 │
    │ Acceptance│           │  │ Change │  │Artifact│
    │ Test Gen │           │  │ Detect │  │Storage │
    └──┬───┬───┘           │  └────────┘  └────────┘
       │   │               │                   ▲
       │   │  reads output │                   │
       ▼   ▼               ▼                   │
  ┌────────┐  ┌────────┐  ┌────────┐          │
  │SYS-003 │  │SYS-004 │  │SYS-010 │          │
  │ Matrix │  │Coverage│  │ Input  │          │
  │Builder │  │ Valid  │  │Process │          │
  └────┬───┘  └────────┘  └────┬───┘          │
       │                       │               │
       │       ┌───────────────┘               │
       │       │                               │
       ▼       ▼                               │
  ┌────────┐  ┌────────┐  ┌────────┐  ┌───────┴┐
  │SYS-009 │  │SYS-006 │  │SYS-007 │  │SYS-011 │
  │Lifecycle│  │ Setup  │  │Overlay │  │ Error  │
  │Manager │  │Service │  │Loader  │  │Handler │
  └────────┘  └────────┘  └────────┘  └────────┘
     cross-       infra       infra      cross-
     cutting                             cutting

  Legend:
    ─── data/control flow (direction of arrow)
    SYS-006, SYS-007, SYS-009, SYS-011 are infrastructure/cross-cutting
    used by multiple components (arrows omitted for clarity)
```

## Interface View (IEEE 1016 §5.3)

### External Interfaces

| Component | Interface Name | Protocol | Input | Output | Error Handling |
|-----------|---------------|----------|-------|--------|----------------|
| SYS-001 | `/speckit.v-model.requirements` | AI slash command (CLI) | Feature description text and/or `spec.md` file path | `requirements.md` (Markdown) at `{VMODEL_DIR}/requirements.md` | Descriptive error for empty input (REQ-022); prerequisite errors via SYS-006 |
| SYS-002 | `/speckit.v-model.acceptance` | AI slash command (CLI) | `requirements.md` file path (from SYS-006 JSON) | `acceptance-plan.md` (Markdown) at `{VMODEL_DIR}/acceptance-plan.md` | Prerequisite error if requirements.md missing (`--require-reqs`) |
| SYS-003 | `build-matrix.sh {VMODEL_DIR}` | Shell script (CLI) | V-Model directory path; `--output` flag for file path | `traceability-matrix.md` (Markdown) or stdout | Exit code 1 with descriptive message for missing input files |
| SYS-004 | `validate-requirement-coverage.sh` | Shell script (CLI) | V-Model directory path; optional `--json` flag | Exit code 0 (full coverage) or 1 (gaps); optional JSON with `has_gaps`, `reqs_without_atp`, `atps_without_scn`, coverage percentages | Exit code 1 with gap report for coverage failures; descriptive error for malformed input |
| SYS-005 | `diff-requirements.sh` | Shell script (CLI) | V-Model directory path | JSON change report: `added`, `modified`, `removed` requirement ID arrays | Descriptive error if no Git history or requirements.md missing |
| SYS-006 | `setup-v-model.sh --json` | Shell script (CLI) | Optional flags: `--require-reqs`, `--require-acceptance` | JSON object: `VMODEL_DIR`, `FEATURE_DIR`, `BRANCH`, `SPEC`, `REQUIREMENTS`, `AVAILABLE_DOCS` | Exit code 1 with descriptive message for missing prerequisites |

### Internal Interfaces

| Source | Target | Interface Name | Protocol | Data Format | Error Handling |
|--------|--------|---------------|----------|-------------|----------------|
| SYS-006 | SYS-001, SYS-002, SYS-003 | Setup Configuration | JSON stdout | `{"VMODEL_DIR": "...", "FEATURE_DIR": "...", "BRANCH": "...", "REQUIREMENTS": "...", "AVAILABLE_DOCS": [...]}` | Non-zero exit code halts consumer command |
| SYS-007 | SYS-001, SYS-002 | Domain Overlay Content | File I/O (Markdown) | Overlay markdown read from `commands/overlays/{domain}/{command}.md` and `templates/overlays/{domain}/{template}.md` | File not found → graceful degradation to base-only |
| SYS-009 | SYS-001, SYS-002, SYS-003 | Lifecycle State Tags | Inline Markdown markers | `[DEPRECATED — Superseded by ...]`, `[DEPRECATED — Withdrawn: ...]`, `[MODIFIED]`, `[SUSPECT — Parent ... modified/deprecated]` | Missing tags treated as Active state |
| SYS-010 | SYS-001 | Parsed Input | File I/O + text | `spec.md` content (primary), user text arguments (supplementary), or both | Empty input → descriptive error via SYS-011 |
| SYS-011 | All components | Error Reporting | stderr / exception | Descriptive error message string with context (component, operation, cause) | N/A (SYS-011 is the error handler) |

## Data Design View (IEEE 1016 §5.4)

| Entity | Component | Storage | Protection at Rest | Protection in Transit | Retention |
|--------|-----------|---------|-------------------|-----------------------|-----------|
| Requirements Document (`requirements.md`) | SYS-001 (produces), SYS-002/003/004/005 (consumes) | File (Markdown) in `specs/{feature}/v-model/` | Git version control; file system permissions | N/A (local filesystem) | Permanent — version-controlled; deprecated items preserved, never deleted |
| Acceptance Test Plan (`acceptance-plan.md`) | SYS-002 (produces), SYS-003/004 (consumes) | File (Markdown) in `specs/{feature}/v-model/` | Git version control; file system permissions | N/A (local filesystem) | Permanent — version-controlled; deprecated ATPs/SCNs preserved |
| Traceability Matrix (`traceability-matrix.md`) | SYS-003 (produces) | File (Markdown) in `specs/{feature}/v-model/` | Git version control; file system permissions | N/A (local filesystem) | Regenerated on demand; previous versions retained in Git history |
| Coverage Report | SYS-004 (produces) | stdout or JSON to stdout | None (ephemeral) | N/A (local process) | Ephemeral — consumed by CI/CD pipeline; not persisted as artifact |
| Change Report | SYS-005 (produces) | stdout (JSON) | None (ephemeral) | N/A (local process) | Ephemeral — consumed by SYS-002 for incremental updates |
| Setup Configuration | SYS-006 (produces) | stdout (JSON) | None (ephemeral) | N/A (local process) | Ephemeral — produced per command invocation |
| Domain Configuration (`v-model-config.yml`) | SYS-007 (reads) | File (YAML) at repository root | Git version control | N/A (local filesystem) | Permanent — user-managed configuration |
| Domain Overlay Files | SYS-007 (reads) | Files (Markdown) in `commands/overlays/{domain}/` and `templates/overlays/{domain}/` | Git version control | N/A (local filesystem) | Permanent — extension-managed content |
| Feature Specification (`spec.md`) | SYS-010 (reads) | File (Markdown) in `specs/{feature}/` | Git version control | N/A (local filesystem) | Permanent — version-controlled |

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total System Components (SYS) | 12 (12 active, 0 deprecated, 0 suspect) |
| Total Parent Requirements Covered | 35 / 35 (100%) (active items only) |
| Components per Type | Subsystem: 3 \| Module: 6 \| Service: 2 \| Library: 0 \| Utility: 1 |
| **Forward Coverage (REQ→SYS)** | **100%** |

## Derived Requirements

None — all components trace to existing requirements.

## Glossary

| Term | Definition |
|------|-----------|
| IEEE 1016 | IEEE Standard for Information Technology — Software Design Descriptions. Defines mandatory design views for software architecture documentation. |
| Decomposition View | IEEE 1016 §5.1 — Shows the system's constituent components and their hierarchical relationships. |
| Dependency View | IEEE 1016 §5.2 — Shows inter-component dependencies and failure propagation paths. |
| Interface View | IEEE 1016 §5.3 — Documents API contracts, protocols, data formats, and error handling for all component interfaces. |
| Data Design View | IEEE 1016 §5.4 — Documents data entities, their owning components, storage mechanisms, and protection measures. |
| Generative Component | A system component (SYS-001, SYS-002) that uses AI to produce artifacts — requires SYS-012 (AI Runtime Interface) for execution. |
| Deterministic Component | A system component (SYS-003, SYS-004, SYS-005) that uses regex-based parsing and script logic — produces identical outputs for identical inputs without AI involvement. |
| Assembly Protocol | The standardized domain overlay loading sequence: read v-model-config.yml → load command overlay → load template overlay → prefer overlay content where marked → degrade to base-only if absent. |
| Strict Translator Constraint | The rule that generative components decompose only capabilities found in requirements.md — they must not invent, infer, or add features not traceable to a REQ-NNN. |
