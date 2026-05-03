# Hazard Analysis (FMEA): Bridge Commands

**Feature Branch**: `feature/007-bridge-commands`
**Created**: 2026-04-26
**Status**: Approved
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

Operational states are defined authoritatively in `system-design.md` §
"Operational States (IEEE 1016 §5.2 Behavioural View)". Each HAZ row's
**Operational State** column lists the states in which the failure mode
can arise. Mitigations apply in every listed state unless explicitly
qualified.

| State | Description | Source |
|-------|------------|--------|
| NORMAL | Default operating state for read-only / analysis / planning operations (spec ingestion, plan/task synthesis, gate evaluation, hook registration, configuration parsing). | system-design.md § Operational States |
| DRY-RUN | `v-model.implement --no-commit`: source generation runs end-to-end but the post-write commit barrier is suppressed. | system-design.md § Operational States |
| COMMITTING | `v-model.implement` (default): full write-and-commit barrier is active, including SYS-007 region-marker mutation and SYS-014 commit-message annotation. | system-design.md § Operational States |
| ERROR | Any command exit path with non-zero exit code; structured-summary emission MUST complete on this path. | system-design.md § Operational States |

## Hazard Register (FMEA)

| HAZ ID | Component | Failure Mode | Operational State | Effect | Severity | Likelihood | Risk Level | Mitigation | Residual Risk |
|--------|-----------|-------------|-------------------|--------|----------|-----------|------------|------------|---------------|
| HAZ-001 | SYS-001 | Function failure: `v-model.plan` aborts on an uncaught exception or resource exhaustion, without producing `plan.md` (excludes the graceful missing-optional-artifact case, which is handled by REQ-008 by design and is therefore not a hazard) | NORMAL | Developer cannot proceed to `/speckit.tasks`; manual workaround required | Minor | Remote | Acceptable | REQ-001, REQ-008, SYS-012 (structured summary surfaces failure mode) | Acceptable |
| HAZ-002 | SYS-001 | Value failure: emitted `plan.md` carries malformed V-Model enrichment that breaks spec-kit-core parsing | NORMAL | Downstream `speckit.tasks` fails or silently drops traceability metadata; round-trip property violated | Serious | Remote | Tolerable | REQ-007, REQ-NF-003, SYS-005 (additive-enrichment encoder), SYS-010 (compatibility layer) | Acceptable |
| HAZ-003 | SYS-001 | Interface failure: optional V-Model artifact missing without graceful degradation warning | NORMAL | Developer believes plan was complete when it was not; downstream artifacts under-specified | Serious | Remote | Tolerable | REQ-008, REQ-026, SYS-012 | Acceptable |
| HAZ-004 | SYS-002 | Function failure: `v-model.tasks` aborts without producing `tasks.md` | NORMAL | Developer cannot proceed to implementation phase | Minor | Remote | Acceptable | REQ-009, SYS-012 | Acceptable |
| HAZ-005 | SYS-002 | Value failure: emitted `tasks.md` violates TDD ordering or omits `[P]` parallel-execution markers | NORMAL | Tests are written after code; parallelisable work is serialised — silent regression in development discipline | Serious | Remote | Tolerable | REQ-010, REQ-013, REQ-NF-005 | Acceptable |
| HAZ-006 | SYS-003 | Function failure: `v-model.implement` aborts without producing source code | DRY-RUN, COMMITTING | Implementation phase blocked; no partial commit produced | Minor | Remote | Acceptable | REQ-015, SYS-012 | Acceptable |
| HAZ-007 | SYS-003 | Value failure: generated source contains hallucinated `// Implements <ID>` comments referencing non-existent V-Model identifiers | DRY-RUN, COMMITTING | Traceability chain corrupted; commit ships with phantom IDs that defeat audit | Serious | Occasional | Undesirable | REQ-023, REQ-NF-002, SYS-006 (Hallucination Guard pre-commit verification) | Acceptable |
| HAZ-008 | SYS-003 | Idempotency failure: re-run regenerates source code with <95% structural identity | COMMITTING | User-authored adjacent edits churn unnecessarily; review noise; potential merge conflicts | Serious | Remote | Tolerable | REQ-NF-005, SYS-007 (Source Region Manager) | Acceptable |
| HAZ-009 | SYS-004 | False-negative gate: reports `passed` when Matrix A/B/C/D/H is incomplete | NORMAL | Implementation Engine generates code without traceability prerequisites; defeats the entire V-Model invariant | Critical | Remote | Undesirable | REQ-016, REQ-017, REQ-NF-004, REQ-CN-002 (reuses deterministic `build-matrix` and `validate-*-coverage` scripts) | Tolerable |
| HAZ-010 | SYS-004 | False-positive gate: reports `failed` when matrices are complete | NORMAL | Developer is blocked despite valid prerequisites; investigation overhead | Minor | Remote | Acceptable | REQ-016 (reuses already-validated scripts; deterministic regex parsers) | Acceptable |
| HAZ-011 | SYS-005 | Value failure: enrichment HTML comments mutate canonical Markdown structure (e.g., shift heading levels) | NORMAL | spec-kit-core v0.7.0 emits parser warnings or rejects the document; REQ-NF-003 violated | Serious | Remote | Tolerable | REQ-007, REQ-NF-003, REQ-CN-001 (MUST NOT modify spec-kit core) | Acceptable |
| HAZ-012 | SYS-006 | False-negative: Hallucination Guard misses an invalid `// Implements <ID>` reference | COMMITTING | Commit ships with phantom IDs; structural-eval ID-validation evidence (REQ-NF-002) compromised | Critical | Remote | Undesirable | REQ-023, REQ-NF-002, SYS-006 algorithm spec (system-design.md § "SYS-006 Algorithm Specification") — deterministic regex + canonical-set lookup with no LLM call; SYS-003 / ARCH-017 (`commands/implement.md` §Quality Compliance prompt section gates on the four-stack harness) | Tolerable |
| HAZ-013 | SYS-006 | False-positive: Hallucination Guard rejects a valid ID present in V-Model artifacts | COMMITTING | Commit blocked despite valid traceability; manual override required | Minor | Remote | Acceptable | REQ-023, SYS-006 algorithm spec (system-design.md § "SYS-006 Algorithm Specification") — canonical ID set extracted directly from V-Model artifacts on every invocation | Acceptable |
| HAZ-014 | SYS-007 | Region-marker corruption: user-authored content between region markers is overwritten on re-run | COMMITTING | Silent loss of user code; the Hybrid user path (REQ-022) is broken | Critical | Remote | Undesirable | REQ-022, REQ-NF-005, SYS-003 fail-closed degradation to dry-run + diff report on conflict | Tolerable |
| HAZ-015 | SYS-008 | Configured domain not applied: e.g., DO-178C Level A run produces unit tests without MC/DC obligations | NORMAL | Regulatory-evidence path silently broken; downstream certification audit fails | Critical | Remote | Undesirable | REQ-024, SYS-003 fail-closed (non-zero exit when overlay configured but adapter fails) | Tolerable |
| HAZ-016 | SYS-009 | Hazard-driven tasks not emitted when `hazard-analysis.md` is present in the feature directory | NORMAL | `tasks.md` lacks mitigation-task priority and `HAZ-NNN` verification tasks; safety-critical regression | Critical | Remote | Undesirable | REQ-014, SYS-002 fail-closed when malformed `hazard-analysis.md` detected | Tolerable |
| HAZ-017 | SYS-010 | Schema drift not detected: emitted `plan.md` / `tasks.md` fails to parse against pinned spec-kit-core v0.7.0 schema | NORMAL | Round-trip property (REQ-029) silently violated; downstream `/speckit.tasks` or `/speckit.implement` errors | Serious | Remote | Tolerable | REQ-IF-001, REQ-IF-002, REQ-029, REQ-CN-001 | Acceptable |
| HAZ-018 | SYS-010 | Round-trip violation: `v-model.plan` output is not consumable by `speckit.tasks` (or symmetrically for tasks→implement) | NORMAL | Hybrid user path broken; user must regenerate from scratch | Critical | Remote | Undesirable | REQ-029, REQ-CN-001, SYS-005 (additive-enrichment guarantees core compatibility) | Tolerable |
| HAZ-019 | SYS-011 | Hook not registered: `before_implement` / `after_implement` / `after_specify` entries are absent from `.specify/extensions.yml` | NORMAL | Bridge commands remain manually invocable but are not wired into the automation graph; REQ-IF-003 / REQ-IF-005 partial failure | Minor | Remote | Acceptable | REQ-IF-003, REQ-IF-005, REQ-NF-006 (installation-time error surfaces the failure) | Acceptable |
| HAZ-020 | SYS-012 | Structured stdout summary not emitted on a failure path | ERROR | CI tooling and human reviewers lose machine-readable visibility into the partial result | Minor | Remote | Acceptable | REQ-027, REQ-IF-004 (best-effort emission required even on failure) | Acceptable |
| HAZ-021 | SYS-003 / ARCH-017 [SUSPECT — Parent SYS-013 deprecated 2026-05-01; retargeted to SYS-003 / ARCH-017 §Quality Compliance prompt section] | Coverage gate not enforced: merge proceeds with <100% four-stack (BATS / Pester / structural eval / LLM eval) coverage | NORMAL | Silent quality regression; merge violates the project-wide constraint | Serious | Remote | Tolerable | REQ-NF-001, REQ-CN-003, REQ-CN-004 | Acceptable |
| HAZ-022 | SYS-014 | Commit ID suffix not appended: commit message lacks the `— MOD-NNN, REQ-NNN` traceability tail | COMMITTING | git-history-based traceability degraded for that commit; audit tooling falls back to in-file `// Implements` comments | Minor | Occasional | Tolerable | REQ-021, SYS-012 (warning surfaced in run summary) | Tolerable |

## Progressive Deepening (Architecture-Level)

Architecture-level failure modes that are not visible at the system boundary
are appended below per IEC 60812:2018 §6 progressive analysis. Three
cross-cutting architecture components (`ARCH-009`, `ARCH-011`, `ARCH-016`) mediate
interfaces between `SYS` components at the shell-script / LLM-prompt layer
and warrant dedicated entries.

| HAZ ID | Component | Failure Mode | Operational State | Effect | Severity | Likelihood | Risk Level | Mitigation | Residual Risk |
|--------|-----------|-------------|-------------------|--------|----------|-----------|------------|------------|---------------|
| HAZ-023 | SYS-006 / ARCH-009 | Interface mismatch: Hallucination Guard scanner is invoked on a stale snapshot of generated files (race with SYS-003 file writes) | COMMITTING | Newly-emitted hallucinated IDs slip through verification; commit ships uncertified | Critical | Remote | Undesirable | REQ-023, REQ-NF-002; scanner receives the list of generated file paths from the LLM via `validate-implements-ids.sh` invocation after generation | Tolerable |
| HAZ-024 | SYS-008 / ARCH-011 | Protocol failure: malformed `v-model-config.yml` parsed as an empty overlay rather than a hard error | NORMAL | Configured domain silently downgraded to base behaviour; regulatory obligations skipped without warning | Critical | Remote | Undesirable | REQ-024; `v-model-config.yml` parse failure causes the §Domain Overlay step in `commands/implement.md` to abort with non-zero exit | Tolerable |
| HAZ-025 | SYS-012 / ARCH-016 | Race condition: Structured Summary Reporter is interrupted by command exit before flushing stdout | ERROR | Truncated summary; CI parsers may misclassify the run | Minor | Remote | Acceptable | REQ-027, REQ-IF-004; the §Structured Summary section in each of `commands/{plan,tasks,implement}.md` instructs the LLM to flush a structured stdout summary on every exit path, including failure | Acceptable |

## Likelihood Justification (PRF-HAZ-001)

Per ISO 14971 §5.4, every Severity/Likelihood pairing in the Hazard Register
must be justified, especially for hazards rated at Serious/Remote and
Serious/Occasional. Justifications below explain *why* each such failure mode
has the stated likelihood in practice. Likelihoods on Critical and Minor
hazards are not re-stated row-by-row here. **Critical** hazards' likelihoods
are conservatively bounded by the Risk Acceptability Matrix: any
Critical/Occasional or Critical/Probable pairing would be Intolerable
pre-mitigation and is therefore excluded by design from the register; only
Critical/Remote pairings appear, and their pre-mitigation likelihood is
justified inline by the **Failure Mode** and **Operational State** columns of
the Hazard Register table itself. **Minor** hazards do not require the same
rigour per ISO 14971 risk-acceptability principles.

| HAZ ID | Severity | Likelihood | Justification |
|--------|----------|-----------|---------------|
| **HAZ-002** | Serious | Remote | The additive-enrichment encoder (SYS-005) produces only HTML comments interleaved with canonical Markdown; spec-kit-core v0.7.0 parser is stable and production-tested on thousands of plans; failure would require *both* a defect in the encoder AND a parser regression. Estimated frequency: <0.1% over system lifetime. |
| **HAZ-003** | Serious | Remote | REQ-008 mandates a non-zero warning indicator in the structured summary on missing optional artifacts; the indicator is parsed deterministically by SYS-012. Failure would require a defect in the summary emitter that drops the warning silently — a single, narrow code path that is exercised by acceptance scenario SCN-008-A1. |
| **HAZ-005** | Serious | Remote | TDD ordering and `[P]` placement are produced by deterministic templating logic (SYS-002); the canonical `tasks-template.md` schema (REQ-IF-002) pins the placement convention. Failure would require a regression in the templating engine that escapes the schema-conformance test in `validate-system-coverage.sh`. |
| **HAZ-007** | Serious | Occasional | LLM-generated `// Implements <ID>` comments inherit the underlying model's hallucination base-rate, empirically observed in the 1–5% range per generated identifier — placing this failure mode in the Occasional band by construction. This rating is the design driver behind SYS-006 (Hallucination Guard): the guard exists precisely because the Occasional likelihood is too high to accept without a deterministic verification step. |
| **HAZ-008** | Serious | Remote | Source-region identity is anchored to deterministic markers managed by SYS-007; the structural-identity check is verified by ATP-008-A on every implementation re-run. Failure requires a defect in the marker-management logic AND a marker-collision case. |
| **HAZ-011** | Serious | Remote | The enrichment encoder writes only HTML comments at well-defined insertion anchors; mutating Markdown structure (e.g., shifting heading levels) would require a defect that bypasses the additive-only contract enforced by SYS-005's unit tests (UTP-005). REQ-CN-001 ("MUST NOT modify spec-kit core") is structurally enforced by the build-time check. |
| **HAZ-017** | Serious | Remote | Round-trip property (REQ-029) is verified end-to-end by SCN-IF-001-A1 and SCN-IF-002-A1 on every CI run; the pinned spec-kit-core v0.7.0 schema does not drift between releases by definition; failure requires a defect in the compatibility layer (SYS-010) that escapes structural eval. |
| **HAZ-021** | Serious | Remote | The four-stack coverage gate is realised by `commands/implement.md` §Quality Compliance (ARCH-017, parent SYS-003) plus deterministic CI workflow rules; bypassing it requires either a CI configuration regression or an admin override. Both pathways are auditable in CI logs and require explicit human action. |

## Residual Risk Justification (PRF-HAZ-002)

Per ISO 14971 §5.5, the Residual Risk Distribution at the Coverage Summary
must be supported by per-hazard reasoning explaining how each mitigation
chain reduces the initial risk to its residual classification. The table
below provides that reasoning for every HAZ entry (system-level + progressive
deepening). "Residual mechanism" describes the specific control that makes the
residual classification defensible.

| HAZ ID | Initial Risk | Residual Risk | Residual Mechanism |
|--------|--------------|---------------|--------------------|
| **HAZ-001** | Acceptable | Acceptable | SYS-012 surfaces the failure mode in structured stdout; no further reduction possible because the developer's manual workaround (re-run) fully resolves the harm. |
| **HAZ-002** | Tolerable | Acceptable | The deterministic encoder (SYS-005) plus compatibility layer (SYS-010) plus REQ-NF-003 schema-conformance test together exercise the failure path on every CI run; cumulative residual exposure < initial likelihood by ≈ one order of magnitude. |
| **HAZ-003** | Tolerable | Acceptable | REQ-008 + REQ-026 require the warning to be emitted AND surfaced in the run summary; both checkpoints are verified by SCN-008-A1 and SCN-026-A1. The combined controls cut residual likelihood to negligible. |
| **HAZ-004** | Acceptable | Acceptable | SYS-012 surfaces the abort; same logic as HAZ-001. |
| **HAZ-005** | Tolerable | Acceptable | REQ-NF-005 (idempotency / structural identity ≥ 95%) + REQ-013 ([P] placement convention) are enforced by deterministic schema check; failure is detectable by the round-trip CI test. |
| **HAZ-006** | Acceptable | Acceptable | SYS-012 surfaces the abort; partial-commit surface is bounded by REQ-015 (atomicity contract — implement either commits the full module set or nothing). |
| **HAZ-007** | Undesirable | Acceptable | SYS-006 (Hallucination Guard) is the primary control; its algorithm specification (system-design.md § "SYS-006 Algorithm Specification") makes the false-negative rate analytic, not empirical. Residual exposure is bounded to the regex parser's correctness, which is fully covered by UTP-006. |
| **HAZ-008** | Tolerable | Acceptable | SYS-007 region preservation + REQ-NF-005 structural identity ≥ 95% provide compounding controls; structural-identity is asserted by ATP-008-A on every re-run. |
| **HAZ-009** | Undesirable | Tolerable | The gate logic reuses already-CI-validated `build-matrix` and `validate-*-coverage` scripts (REQ-CN-002); the residual exposure is bounded to a defect in *new* gate-orchestration code, which is < 50 lines and 100% test-covered (REQ-NF-004). |
| **HAZ-010** | Acceptable | Acceptable | Same script-reuse logic as HAZ-009; deterministic regex parsers cannot produce a false-positive without a defect in the well-exercised regex itself. |
| **HAZ-011** | Tolerable | Acceptable | SYS-005 emits HTML comments only; structural-mutation is structurally impossible via the encoder API surface; the only residual path is a developer-injected raw write, which is out of scope. |
| **HAZ-012** | Undesirable | Tolerable | SYS-006 algorithm spec eliminates LLM-driven uncertainty; SYS-003 / ARCH-017 (§Quality Compliance prompt section) is a secondary defence at merge time. Two independent controls — residual likelihood requires both to fail simultaneously. |
| **HAZ-013** | Acceptable | Acceptable | The canonical ID set is rebuilt from V-Model artifacts on every invocation (per SYS-006 algorithm spec); a false-positive requires the V-Model artifact set itself to be malformed, which is detected upstream by the per-artifact validator scripts. |
| **HAZ-014** | Undesirable | Tolerable | REQ-022 + REQ-NF-005 + SYS-003 fail-closed degradation (dry-run + diff report on conflict) are three layered controls; the user always retains a recovery path (the diff report). |
| **HAZ-015** | Undesirable | Tolerable | REQ-024 + SYS-003 fail-closed (non-zero exit when overlay configured but adapter fails) ensures the silent-downgrade path is structurally impossible: either the overlay is applied or the run aborts. |
| **HAZ-016** | Undesirable | Tolerable | REQ-014 + SYS-002 fail-closed when malformed `hazard-analysis.md` is detected — same structural-impossibility argument as HAZ-015. |
| **HAZ-017** | Tolerable | Acceptable | REQ-029 round-trip is verified end-to-end on every CI run; spec-kit-core v0.7.0 schema is pinned (REQ-CN-001); failure requires *both* schema drift AND test-coverage regression. |
| **HAZ-018** | Undesirable | Tolerable | REQ-029 + REQ-CN-001 + SYS-005 additive-enrichment guarantees together make the failure mode structurally rare; recovery path (regenerate from scratch) is well-documented. |
| **HAZ-019** | Acceptable | Acceptable | REQ-NF-006 mandates installation-time error surfacing; the failure cannot remain silent because the installation script aborts. |
| **HAZ-020** | Acceptable | Acceptable | REQ-IF-004 requires best-effort emission on every exit path; verified by ITP-021-A scenarios on each failure-path matrix. |
| **HAZ-021** | Tolerable | Acceptable | CI workflow rules enforce the §Quality Compliance prompt section (SYS-003 / ARCH-017); an override leaves an audit trail; review process compensates. |
| **HAZ-022** | Tolerable | Tolerable | SYS-012 warning surfaces the omission in the run summary; in-file `// Implements` comments provide a fallback traceability source per REQ-021. The Likelihood here is "Occasional" because the commit-message-template logic is the most defect-prone code in v0.7.0; residual is held at Tolerable by the warning + fallback. |
| **HAZ-023** | Undesirable | Tolerable | ARCH-009 (`validate-implements-ids.sh`) receives the list of generated file paths from the LLM orchestration step (ARCH-004), ensuring the scan is always over the complete just-generated set; the sequential invocation order in ARCH-004 makes the race structurally impossible; ITS-009-A1/A2 (canonical-set extraction over post-generation snapshot) plus ITP-009-B fault-injection scenarios verify the ordering and the false-negative bound. |
| **HAZ-024** | Undesirable | Tolerable | `v-model-config.yml` parse failure causes the §Domain Overlay step in `commands/implement.md` (ARCH-011) to abort with non-zero exit, preventing silent downgrade; ITS-013-B1/B2 (schema-validator fault-injection) verify the abort behaviour at the validator boundary. |
| **HAZ-025** | Acceptable | Acceptable | The §Structured Summary section in each of `commands/{plan,tasks,implement}.md` (ARCH-016) instructs the LLM to emit the summary on every exit path, including failure; verified by STS-007-B2 scenarios. |

## Progressive Deepening Cross-References (PRF-HAZ-003)

Per IEC 60812:2018 §6 (Progressive Analysis), each architecture-level
hazard refines a system-level counterpart. The mapping below makes the
implicit relationship explicit:

| Architecture-Level HAZ | Refines System-Level HAZ(s) | Relationship |
|------------------------|------------------------------|--------------|
| HAZ-023 (SYS-006 / ARCH-009 race) | HAZ-007 (hallucinated // Implements) + HAZ-012 (false-negative detection) | HAZ-023 is the architecture-level mechanism by which the false-negative outcome of HAZ-012 can be triggered (stale snapshot). The race-condition refinement closes the residual gap that HAZ-012 leaves open. |
| HAZ-024 (SYS-008 / ARCH-011 protocol failure) | HAZ-015 (Configured domain not applied) | HAZ-024 is the specific architecture-level failure mode (malformed YAML parsed as empty overlay) that produces the system-level outcome of HAZ-015 (silent regulatory downgrade). |
| HAZ-025 (SYS-012 / ARCH-016 truncated summary) | HAZ-020 (Summary not emitted on failure path) | HAZ-025 is the architecture-level realisation of HAZ-020 in the specific case of signal-driven exit; HAZ-020 covers the broader silent-omission case. |

## Coverage Summary

> **PRF-HAZ-004 note (SYS-008 unsupported-domain case):** SYS-008 failure
> modes are covered by HAZ-015 (system-level: configured domain not applied)
> and HAZ-024 (architecture-level: malformed `v-model-config.yml` parsed as
> empty overlay). The narrower case where `v-model-config.yml` is well-formed
> but configured for a domain that SYS-003 does not yet support (e.g., a
> custom domain) is not modelled as a separate HAZ because SYS-003's
> fail-closed policy (REQ-024) makes silent regulatory degradation
> structurally impossible: either the requested overlay is applied or the
> run aborts non-zero. Residual risk for the unsupported-domain case is
> therefore Acceptable by construction; no dedicated HAZ entry is required.

| Metric | Count |
|--------|-------|
| Total System Components (SYS) | 15 (14 active, 1 deprecated — SYS-013) |
| Components with ≥1 HAZ | 14 / 14 (100%) (active items only; SYS-013 deprecated, HAZ-021 retargeted to SYS-003 / ARCH-017) |
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

Counts reflect each state in which a HAZ can arise; HAZ-006 and HAZ-007
are tagged with two states (DRY-RUN and COMMITTING), so the column
totals to 27, exceeding the 25 distinct HAZ count.

| State | Hazard Count |
|-------|-------------|
| NORMAL | 15 |
| DRY-RUN | 2 |
| COMMITTING | 8 |
| ERROR | 2 |

## Uncovered Components

None — full coverage achieved. Every active `SYS-NNN` (SYS-001 through SYS-012, SYS-014, SYS-015) has at least one `HAZ-NNN` entry. SYS-013 is deprecated; HAZ-021 retains its ID but is retargeted to its replacement (SYS-003 §Quality Compliance / ARCH-017).
