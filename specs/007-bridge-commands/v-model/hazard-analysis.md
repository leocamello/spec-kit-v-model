# Hazard Analysis (FMEA): Bridge Commands

**Feature Branch**: `feature/007-bridge-commands`
**Created**: 2026-04-26
**Status**: Draft
**Source**: `specs/007-bridge-commands/v-model/system-design.md`
**Standard**: General-Purpose FMEA per IEC 60812:2018 + ISO 14971:2019 §5 risk matrix (no domain overlay configured)

## Overview

This document presents the Failure Mode and Effects Analysis (FMEA) for the
Bridge Commands feature (`/speckit.v-model.plan`, `/speckit.v-model.tasks`,
`/speckit.v-model.implement`). Every system component (`SYS-NNN`) from
`system-design.md` is assessed for potential failure modes. Each hazard
receives a unique `HAZ-NNN` identifier and is linked to risk control measures
(`REQ-NNN` / `SYS-NNN`), enabling the traceability chain:
Hazard → Mitigation → Requirement → Test Case (Matrix H).

The system under analysis is a **developer-facing CLI tool**, not a
safety-of-life device. The general-purpose severity scale applies: the
worst credible outcome is a silent corruption of generated artifacts that a
downstream developer trusts (classified as `Serious`); compromise of a
regulatory-evidence path (e.g., DO-178C MC/DC obligations) is classified as
`Critical`. No `Catastrophic` outcomes apply at this layer.

## ID Schema

- **Hazard ID**: `HAZ-{NNN}` — 3-digit zero-padded, sequential (HAZ-001, HAZ-002, ...)
- **ID Lineage**: From `HAZ-NNN`, read the Mitigation column to find `REQ-NNN` / `SYS-NNN`.
  Consult `traceability-matrix.md` (Matrix H, populated on the next `v-model.trace` re-run) for the full chain to verification test cases.

## Risk Matrix Definition

### Severity Scale

| Level | Definition |
|-------|-----------|
| Catastrophic | Death or permanent injury; complete system destruction |
| Critical | Severe injury or major system damage; immediate intervention required |
| Serious | Moderate injury or significant degradation; medical attention needed |
| Minor | Slight injury or minor degradation; first aid sufficient |
| Negligible | No injury; cosmetic or inconvenience-level impact |

### Likelihood Scale

| Level | Definition |
|-------|-----------|
| Frequent | Likely to occur often; continuously experienced |
| Probable | Will occur several times; expected to occur |
| Occasional | Likely to occur sometime; can reasonably be expected |
| Remote | Unlikely but possible; could occur in the life of the system |
| Improbable | So unlikely it can be assumed it will not occur |

### Risk Matrix (Severity × Likelihood)

| | Frequent | Probable | Occasional | Remote | Improbable |
|---|---|---|---|---|---|
| **Catastrophic** | Unacceptable | Unacceptable | Unacceptable | Undesirable | Undesirable |
| **Critical** | Unacceptable | Unacceptable | Undesirable | Undesirable | Tolerable |
| **Serious** | Unacceptable | Undesirable | Undesirable | Tolerable | Tolerable |
| **Minor** | Undesirable | Tolerable | Tolerable | Acceptable | Acceptable |
| **Negligible** | Tolerable | Acceptable | Acceptable | Acceptable | Acceptable |

## Operational States Reference

⚠️ No operational states are defined in `system-design.md` — using implicit `NORMAL` state for all hazard entries. Consider adding operational states (e.g., DRY-RUN vs. COMMITTING for SYS-003) to your system design for more thorough hazard analysis in a future iteration.

| State | Description | Source |
|-------|------------|--------|
| NORMAL | Implicit default state (no operational states defined in system-design.md) | Implicit |

## Hazard Register (FMEA)

| HAZ ID | Component | Failure Mode | Operational State | Effect | Severity | Likelihood | Risk Level | Mitigation | Residual Risk |
|--------|-----------|-------------|-------------------|--------|----------|-----------|------------|------------|---------------|
| HAZ-001 | SYS-001 | Function failure: `v-model.plan` aborts without producing `plan.md` | NORMAL | Developer cannot proceed to `/speckit.tasks`; manual workaround required | Minor | Remote | Acceptable | REQ-001, REQ-008, SYS-012 (structured summary surfaces failure mode) | Acceptable |
| HAZ-002 | SYS-001 | Value failure: emitted `plan.md` carries malformed V-Model enrichment that breaks spec-kit-core parsing | NORMAL | Downstream `speckit.tasks` fails or silently drops traceability metadata; round-trip property violated | Serious | Remote | Tolerable | REQ-007, REQ-NF-003, SYS-005 (additive-enrichment encoder), SYS-010 (compatibility layer) | Acceptable |
| HAZ-003 | SYS-001 | Interface failure: optional V-Model artifact missing without graceful degradation warning | NORMAL | Developer believes plan was complete when it was not; downstream artifacts under-specified | Serious | Remote | Tolerable | REQ-008, REQ-026, SYS-012 | Acceptable |
| HAZ-004 | SYS-002 | Function failure: `v-model.tasks` aborts without producing `tasks.md` | NORMAL | Developer cannot proceed to implementation phase | Minor | Remote | Acceptable | REQ-009, SYS-012 | Acceptable |
| HAZ-005 | SYS-002 | Value failure: emitted `tasks.md` violates TDD ordering or omits `[P]` parallel-execution markers | NORMAL | Tests are written after code; parallelisable work is serialised — silent regression in development discipline | Serious | Remote | Tolerable | REQ-010, REQ-013, REQ-NF-005 | Acceptable |
| HAZ-006 | SYS-003 | Function failure: `v-model.implement` aborts without producing source code | NORMAL | Implementation phase blocked; no partial commit produced | Minor | Remote | Acceptable | REQ-015, SYS-012 | Acceptable |
| HAZ-007 | SYS-003 | Value failure: generated source contains hallucinated `// Implements <ID>` comments referencing non-existent V-Model identifiers | NORMAL | Traceability chain corrupted; commit ships with phantom IDs that defeat audit | Serious | Occasional | Undesirable | REQ-023, REQ-NF-002, SYS-006 (Hallucination Guard pre-commit verification) | Acceptable |
| HAZ-008 | SYS-003 | Idempotency failure: re-run regenerates source code with <95% structural identity | NORMAL | User-authored adjacent edits churn unnecessarily; review noise; potential merge conflicts | Serious | Remote | Tolerable | REQ-NF-005, SYS-007 (Source Region Manager) | Acceptable |
| HAZ-009 | SYS-004 | False-negative gate: reports `passed` when Matrix A/B/C/D/H is incomplete | NORMAL | Implementation Engine generates code without traceability prerequisites; defeats the entire V-Model invariant | Critical | Remote | Undesirable | REQ-016, REQ-017, REQ-NF-004, REQ-CN-002 (reuses deterministic `build-matrix` and `validate-*-coverage` scripts) | Tolerable |
| HAZ-010 | SYS-004 | False-positive gate: reports `failed` when matrices are complete | NORMAL | Developer is blocked despite valid prerequisites; investigation overhead | Minor | Remote | Acceptable | REQ-016 (reuses already-validated scripts; deterministic regex parsers) | Acceptable |
| HAZ-011 | SYS-005 | Value failure: enrichment HTML comments mutate canonical Markdown structure (e.g., shift heading levels) | NORMAL | spec-kit-core v0.7.0 emits parser warnings or rejects the document; REQ-NF-003 violated | Serious | Remote | Tolerable | REQ-007, REQ-NF-003, REQ-CN-001 (MUST NOT modify spec-kit core) | Acceptable |
| HAZ-012 | SYS-006 | False-negative: Hallucination Guard misses an invalid `// Implements <ID>` reference | NORMAL | Commit ships with phantom IDs; structural-eval ID-validation evidence (REQ-NF-002) compromised | Critical | Remote | Undesirable | REQ-023, REQ-NF-002, SYS-013 (compliance harness blocks merge on eval failure) | Tolerable |
| HAZ-013 | SYS-006 | False-positive: Hallucination Guard rejects a valid ID present in V-Model artifacts | NORMAL | Commit blocked despite valid traceability; manual override required | Minor | Remote | Acceptable | REQ-023 (canonical ID set extracted directly from V-Model artifacts) | Acceptable |
| HAZ-014 | SYS-007 | Region-marker corruption: user-authored content between region markers is overwritten on re-run | NORMAL | Silent loss of user code; the Hybrid user path (REQ-022) is broken | Critical | Remote | Undesirable | REQ-022, REQ-NF-005, SYS-003 fail-closed degradation to dry-run + diff report on conflict | Tolerable |
| HAZ-015 | SYS-008 | Configured domain not applied: e.g., DO-178C Level A run produces unit tests without MC/DC obligations | NORMAL | Regulatory-evidence path silently broken; downstream certification audit fails | Critical | Remote | Undesirable | REQ-024, SYS-003 fail-closed (non-zero exit when overlay configured but adapter fails) | Tolerable |
| HAZ-016 | SYS-009 | Hazard-driven tasks not emitted when `hazard-analysis.md` is present in the feature directory | NORMAL | `tasks.md` lacks mitigation-task priority and `HAZ-NNN` verification tasks; safety-critical regression | Critical | Remote | Undesirable | REQ-014, SYS-002 fail-closed when malformed `hazard-analysis.md` detected | Tolerable |
| HAZ-017 | SYS-010 | Schema drift not detected: emitted `plan.md` / `tasks.md` fails to parse against pinned spec-kit-core v0.7.0 schema | NORMAL | Round-trip property (REQ-029) silently violated; downstream `/speckit.tasks` or `/speckit.implement` errors | Serious | Remote | Tolerable | REQ-IF-001, REQ-IF-002, REQ-029, REQ-CN-001 | Acceptable |
| HAZ-018 | SYS-010 | Round-trip violation: `v-model.plan` output is not consumable by `speckit.tasks` (or symmetrically for tasks→implement) | NORMAL | Hybrid user path broken; user must regenerate from scratch | Critical | Remote | Undesirable | REQ-029, REQ-CN-001, SYS-005 (additive-enrichment guarantees core compatibility) | Tolerable |
| HAZ-019 | SYS-011 | Hook not registered: `before_implement` / `after_implement` / `after_specify` entries are absent from `.specify/extensions.yml` | NORMAL | Bridge commands remain manually invocable but are not wired into the automation graph; REQ-IF-003 partial failure | Minor | Remote | Acceptable | REQ-IF-003, REQ-NF-006 (installation-time error surfaces the failure) | Acceptable |
| HAZ-020 | SYS-012 | Structured stdout summary not emitted on a failure path | NORMAL | CI tooling and human reviewers lose machine-readable visibility into the partial result | Minor | Remote | Acceptable | REQ-027, REQ-IF-004 (best-effort emission required even on failure) | Acceptable |
| HAZ-021 | SYS-013 | Coverage gate not enforced: merge proceeds with <100% four-stack (BATS / Pester / structural eval / LLM eval) coverage | NORMAL | Silent quality regression; merge violates the project-wide constraint | Serious | Remote | Tolerable | REQ-NF-001, REQ-CN-003, REQ-CN-004 | Acceptable |
| HAZ-022 | SYS-014 | Commit ID suffix not appended: commit message lacks the `— MOD-NNN, REQ-NNN` traceability tail | NORMAL | git-history-based traceability degraded for that commit; audit tooling falls back to in-file `// Implements` comments | Minor | Occasional | Tolerable | REQ-021, SYS-012 (warning surfaced in run summary) | Tolerable |

## Progressive Deepening (Architecture-Level)

Architecture-level failure modes that are not visible at the system boundary
are appended below per IEC 60812:2018 §6 progressive analysis. Three
cross-cutting architecture modules (`ARCH-019`, `ARCH-020`, `ARCH-021`) carry
no requirement-traceable capability of their own but mediate interfaces
between `SYS` components, so they warrant dedicated entries.

| HAZ ID | Component | Failure Mode | Operational State | Effect | Severity | Likelihood | Risk Level | Mitigation | Residual Risk |
|--------|-----------|-------------|-------------------|--------|----------|-----------|------------|------------|---------------|
| HAZ-023 | SYS-006 / ARCH-019 | Interface mismatch: Hallucination Guard scanner is invoked on a stale snapshot of generated files (race with SYS-003 file writes) | NORMAL | Newly-emitted hallucinated IDs slip through verification; commit ships uncertified | Critical | Remote | Undesirable | REQ-023, REQ-NF-002, ARCH-019 contract: scanner consumes file paths emitted by SYS-003 only after fsync barrier | Tolerable |
| HAZ-024 | SYS-008 / ARCH-020 | Protocol failure: malformed `v-model-config.yml` parsed as an empty overlay rather than a hard error | NORMAL | Configured domain silently downgraded to base behaviour; regulatory obligations skipped without warning | Critical | Remote | Undesirable | REQ-024, ARCH-020 contract: schema validation MUST raise on parse failure; SYS-003 fail-closed when domain configured but adapter throws | Tolerable |
| HAZ-025 | SYS-012 / ARCH-021 | Race condition: Structured Summary Reporter is interrupted by command exit before flushing stdout | NORMAL | Truncated summary; CI parsers may misclassify the run | Minor | Remote | Acceptable | REQ-027, REQ-IF-004, ARCH-021 contract: emit summary on every exit path (success, failure, signal) before process termination | Acceptable |

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total System Components (SYS) | 14 (14 active, 0 deprecated) |
| Components with ≥1 HAZ | 14 / 14 (100%) (active items only) |
| Total Hazards (HAZ) | 25 |
| System-level hazards | 22 |
| Architecture-level hazards | 3 (progressive deepening) |

### Severity Distribution

| Severity | Count | Percentage |
|----------|-------|------------|
| Catastrophic | 0 | 0% |
| Critical | 8 | 32% |
| Serious | 8 | 32% |
| Minor | 9 | 36% |
| Negligible | 0 | 0% |

### Risk Level Distribution

| Risk Level | Count | Percentage |
|------------|-------|------------|
| Unacceptable | 0 | 0% |
| Undesirable | 9 | 36% |
| Tolerable | 8 | 32% |
| Acceptable | 8 | 32% |

### Residual Risk Distribution (after mitigation applied)

| Residual Risk | Count | Percentage |
|---------------|-------|------------|
| Unacceptable | 0 | 0% |
| Undesirable | 0 | 0% |
| Tolerable | 9 | 36% |
| Acceptable | 16 | 64% |

### Operational State Distribution

| State | Hazard Count |
|-------|-------------|
| NORMAL | 25 |
| ALL | 0 |

## Uncovered Components

None — full coverage achieved. Every `SYS-NNN` (SYS-001 through SYS-014) has at least one `HAZ-NNN` entry.
