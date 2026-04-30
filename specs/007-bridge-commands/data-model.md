# Data Model: Bridge Commands (V-Model ↔ Spec-Kit Core)

<!-- v-model-enrichment: feature=007-bridge-commands -->
<!-- source: system-design.md §Data Design View (IEEE 1016 §5.4) -->

**Branch**: `feature/007-bridge-commands` | **Date**: 2026-04-30  
**Extracted From**: `specs/007-bridge-commands/v-model/system-design.md` §Data Design View

---

## Overview

All data in the bridge-commands feature is project source stored in
Git-tracked plain-text files. There are no databases, message queues, or
remote services. The entities below correspond directly to the rows of the
Data Design View in `system-design.md`; no additional entities have been
introduced.

Storage mechanism for every entity: **filesystem + Git** (repository ACLs
provide access control; Git history provides the audit trail). No encryption
at rest or TLS in transit is required because no sensitive data flows through
bridge-command boundaries.

---

## Entities

---

### V-Model Artifact Set

**Owner / Written by**: Human V-cycle authors (upstream inputs)  
**Read by**: SYS-001 (Plan Synthesizer), SYS-002 (Tasks Synthesizer),
SYS-003 (Implementation Engine), SYS-006 (Hallucination Guard)  
**Storage**: File; Git-tracked under `specs/<feature>/v-model/`  
**Retention**: Permanent in Git history; lifecycle-tagged
(`[DEPRECATED]`, `[SUSPECT]`) per project rules — never deleted

**Members**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `requirements.md` | Markdown file | Yes (gate: fails v-model.plan if absent) | REQ-NNN table — 44 active requirements |
| `acceptance-plan.md` | Markdown file | Optional | ATP-NNN / SCN-NNN BDD scenarios |
| `system-design.md` | Markdown file | Optional | SYS-NNN decomposition + Data Design View |
| `system-test.md` | Markdown file | Optional | STP-NNN / STS-NNN test cases |
| `architecture-design.md` | Markdown file | Optional | ARCH-NNN modules + Interface View |
| `integration-test.md` | Markdown file | Optional | ITP-NNN / ITS-NNN integration tests |
| `module-design.md` | Markdown file | Optional | MOD-NNN modules + Target Source Files |
| `unit-test.md` | Markdown file | Optional | UTP-NNN / UTS-NNN unit test cases |
| `hazard-analysis.md` | Markdown file | Optional | HAZ-NNN FMEA register |
| `traceability-matrix.md` | Markdown file | Optional (required at v-model.implement gate) | Matrix A / B / C / D / H |

---

### Project Constitution

**Owner / Written by**: Project governance  
**Read by**: SYS-001 (Plan Synthesizer)  
**Storage**: File; Git-tracked at `.specify/memory/constitution.md`  
**Retention**: Permanent in Git history

**Members**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `file_path` | Path | Yes | Always `.specify/memory/constitution.md` |
| `content` | UTF-8 Markdown | Yes | Five principles + regulatory standards + workflow |

---

### Domain Overlay Configuration

**Owner / Written by**: Project maintainer  
**Read by**: SYS-008 (Domain Overlay Adapter, MOD-015)  
**Storage**: File; Git-tracked at `v-model-config.yml` (repository root)  
**Retention**: Permanent; absent file is a valid configuration meaning "no domain"

**Members**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `domain` | string | Optional | e.g., `do-178c`, `iso-26262` |
| `level` | string | Conditional | Required when `domain` set; e.g., `Level A` |
| `overlay_path` | Path | Optional | Override path to `_domain.yml` manifest |

---

### Canonical Spec-Kit-Core Outputs

**Owner / Written by**: SYS-001 (v-model.plan), SYS-002 (v-model.tasks)  
**Storage**: File; Git-tracked under `specs/<feature>/`  
**Retention**: Permanent in Git history; regenerable from V-Model inputs

**Members**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `plan.md` | Markdown file | Yes (when v-model.plan runs) | Conforms to spec-kit-core `plan-template.md` schema (REQ-IF-001) |
| `data-model.md` | Markdown file | Yes (when v-model.plan runs) | Extracted from system-design.md §Data Design View (REQ-003) |
| `contracts/` | Directory of Markdown files | Yes (when v-model.plan runs) | One file per ARCH-NNN interface from architecture-design.md §Interface View (REQ-004) |
| `quickstart.md` | Markdown file | Yes (when v-model.plan runs) | Extracted from top critical acceptance-plan.md BDD scenarios (REQ-005) |
| `research.md` | Markdown file | Yes (when v-model.plan runs) | Derivation flags + design decisions (REQ-006) |
| `tasks.md` | Markdown file | Yes (when v-model.tasks runs) | Conforms to spec-kit-core `tasks-template.md` schema (REQ-IF-002) |

---

### V-Model Enrichment Metadata

**Owner / Written by**: SYS-005 (Additive-Enrichment Encoder, MOD-011 / MOD-012)  
**Storage**: Inline within the Canonical Spec-Kit-Core Outputs above (HTML comments + optional sections)  
**Retention**: Inseparable from the host file's lifecycle

**Members**:

| Field | Type | Format | Description |
|-------|------|--------|-------------|
| Trace chains | HTML comment | `<!-- traces-to: MOD-NNN → ARCH-NNN → SYS-NNN → REQ-NNN -->` | Per-task/per-section traceability link (REQ-012) |
| Optional V-Model sections | Markdown section | `## V-Model Traceability` | Machine-readable; ignored by spec-kit core tools |
| Feature header | HTML comment | `<!-- v-model-enrichment: feature=NNN-name -->` | Identifies enriched artifacts for ARCH-014 detection |

---

### Generated Source Code

**Owner / Written by**: SYS-003 (Implementation Engine, MOD-006 / MOD-007)  
**Storage**: File; Git-tracked under paths declared by each `MOD-NNN` Target Source File field  
**Retention**: Permanent in Git history; user-authored regions between V-Model markers preserved across re-runs (REQ-022)

**Members**:

| Field | Type | Description |
|-------|------|-------------|
| `target_path` | Path | Declared by `module-design.md` MOD-NNN Target Source File |
| `content` | UTF-8 source | Generated implementation with `// Implements <ID>` comments |
| `managed_regions` | List of `(start_marker, end_marker, content)` | Demarcated by ARCH-010 / MOD-014 |
| `user_regions` | List of `(start_offset, end_offset, bytes)` | Content outside managed regions; NEVER overwritten |

---

### Generated Tests (Four Levels)

**Owner / Written by**: SYS-003 (Implementation Engine, MOD-008 / MOD-009)  
**Storage**: File; Git-tracked under the project's existing test directories  
**Retention**: Permanent in Git history; regenerable

**Members**:

| Level | Test Plan Source | ID Schema | Target Directory |
|-------|-----------------|-----------|-----------------|
| Unit | `unit-test.md` (UTP/UTS) | `tests/unit/` | `tests/unit/test_bridge_commands/` |
| Integration | `integration-test.md` (ITP/ITS) | — | `tests/integration/` (existing) |
| System | `system-test.md` (STP/STS) | — | `tests/system/` (existing) |
| Acceptance | `acceptance-plan.md` (ATP/SCN) | — | `tests/evals/` (existing) |

---

### Pre-Implementation Gate Report

**Owner / Written by**: SYS-004 (Pre-Implementation Gate, MOD-010)  
**Storage**: Stdout stream (transient)  
**Retention**: Not retained; surfaced into CI logs and SYS-012 structured summary

**Members**:

| Field | Type | Description |
|-------|------|-------------|
| `passed` | boolean | `true` ⟺ every matrix (A, B, C, D, H) is 100% complete |
| `gap_report` | string | Verbatim stdout from `build-matrix.sh` + `validate-*-coverage.sh` scripts |
| `matrices` | struct | `{A, B, C, D, H: {pct: float, gaps: list[str]}}` |

---

### Hallucination Report

**Owner / Written by**: SYS-006 (Hallucination Guard, MOD-013)  
**Storage**: Stdout stream (transient); on hallucination, no commit occurs — this report is the only evidence  
**Retention**: Captured by CI tooling

**Members**:

| Field | Type | Description |
|-------|------|-------------|
| `valid` | boolean | `true` ⟺ zero hallucinated IDs found |
| `hallucinations` | list of `{file, line, id}` | Every `// Implements <PHANTOM-ID>` reference not in `vmodel_id_set` |

---

### Structured Stdout Summary

**Owner / Written by**: SYS-012 (Structured Summary Reporter, MOD-021)  
**Storage**: Stdout stream (transient); captured by CI  
**Retention**: Captured by CI per existing `v-model.test-results` / `v-model.audit-report` conventions

**Members**:

| Field | Type | Description |
|-------|------|-------------|
| `inputs_read` | list[Path] | Artifact paths read in this run |
| `outputs_produced` | list[Path] | Artifact paths written in this run |
| `artifacts_skipped` | list[string] | Optional artifact names absent from feature directory |
| `warnings` | list[string] | Non-fatal warnings (e.g., reduced-enrichment fallback active) |
| `fatal_errors` | list[string] | Errors that caused non-zero exit |

---

### Git Commit Annotations

**Owner / Written by**: SYS-014 (Commit Annotator, MOD-023)  
**Storage**: Git commit message metadata  
**Retention**: Permanent in Git history; signed if contributor signs commits

**Members**:

| Field | Type | Description |
|-------|------|-------------|
| `base_message` | string | `feat(<scope>): <subject>` |
| `id_suffix` | list[string] | Implementing V-Model identifiers (MOD-NNN, REQ-NNN) |
| `annotated_message` | string | `<base_message> — <id>, <id>, ...` |

---

### Hook Registrations

**Owner / Written by**: SYS-011 (Hook Registrar, MOD-020)  
**Storage**: `.specify/extensions.yml` (Git-tracked)  
**Retention**: Permanent in Git history

**Members**:

| Hook Point | Command Registered | Source Requirement |
|------------|-------------------|-------------------|
| `after_specify` | `v-model.requirements` | REQ-IF-005 |
| `before_implement` | `v-model.trace` | REQ-IF-003 |
| `after_implement` | `v-model.trace` | REQ-IF-003 |

---

## Entity Relationship Overview

```text
V-Model Artifact Set  ──── read by ────►  Artifact Reader (MOD-024 / MOD-025)
                                              │
                          ┌───────────────────┼───────────────────────┐
                          ▼                   ▼                       ▼
                     SYS-001              SYS-002                 SYS-003
                     v-model.plan         v-model.tasks           v-model.implement
                          │                   │                       │
                          ▼                   ▼                       ▼
                  Canonical Outputs      tasks.md              Generated Source Code
                  (plan.md, data-        (with enrichment)     + Generated Tests
                   model.md, etc.)            │                       │
                   (with enrichment)          │                  Hallucination Report
                          │                   │                  (SYS-006)
                          └─────── both ──────┴──── read by ─── v-model.implement
                                              │                  (fallback path)
                     Git Commit Annotations ◄─┘ (SYS-014 / SYS-003)
                     Hook Registrations      (SYS-011 / one-time install)
```
