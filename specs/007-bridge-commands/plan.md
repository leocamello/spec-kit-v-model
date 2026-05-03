# Implementation Plan: Bridge Commands (V-Model ↔ Spec-Kit Core)

**Branch**: `feature/007-bridge-commands` | **Date**: 2026-05-02 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/007-bridge-commands/spec.md`
**V-Model artifact set**: [`./v-model/`](./v-model/) (frozen at `618d706`)

> This `plan.md` is the Step A.1 output of the v0.7.0 finishing plan.
> It supersedes the reverted commit `9c23ea4`. The earlier plan
> assumed a Python implementation (~3,000 LOC, 50 source files); the
> reworked V-Model artifact set (post `drift-diff-plan.md`) and this
> plan describe the actual delivery shape: **3 Markdown command-prompt
> files + 4 small Bash scripts + PowerShell mirrors + 3 hook YAML
> entries + tests. Net new Python: 0 lines.**

---

## Summary

Add three bridge commands — `/speckit.v-model.plan`,
`/speckit.v-model.tasks`, `/speckit.v-model.implement` — that connect
the V-Model artifact set (`requirements.md`, `acceptance-plan.md`,
`system-design.md`, `system-test.md`, `architecture-design.md`,
`integration-test.md`, `module-design.md`, `unit-test.md`,
`hazard-analysis.md`, `traceability-matrix.md`) to the spec-kit core
canonical artifact set (`plan.md`, `data-model.md`, `contracts/`,
`quickstart.md`, `research.md`, `tasks.md`, source code, tests,
commits) (REQ-001 … REQ-029, REQ-NF-001 … REQ-NF-006, REQ-IF-001 …
REQ-IF-005, REQ-CN-001 … REQ-CN-004; SC-001 … SC-010).

The technical approach follows the project's existing 13 commands:
each bridge command is a **Markdown prompt file** under `commands/`
whose YAML frontmatter declares `description`, `handoffs`, and a
single `scripts:` entry pointing at one Bash script and its
PowerShell mirror. Deterministic verification is performed by
**four new POSIX shell scripts** (and PowerShell mirrors); the
**Pre-Implementation Gate** is a thin (~30-line) coordinator that
delegates entirely to the existing `scripts/bash/build-matrix.sh` +
five `validate-*-coverage.sh` scripts (REQ-017, REQ-CN-002; SYS-004;
ARCH-007; MOD-010). Hook registration is three declarative YAML
entries in `extension.yml` consumed by spec-kit core's
`CommandRegistrar` (REQ-IF-003, REQ-IF-005, REQ-NF-006; SYS-011;
ARCH-015; MOD-020). No new Python package, no in-process
orchestrator, and no change to spec-kit core (REQ-CN-001).

The cross-cutting safety nets are: (a) **Hallucination Guard** —
a `grep`+`awk` shell script that scans every `Implements <ID>`
comment in generated source and rejects any ID not present in the
V-Model artifacts (REQ-023, REQ-NF-002; SYS-006; ARCH-009; MOD-013,
MOD-025); (b) **Source Region Splicer** — an `awk` script that
preserves user-authored content between V-Model sentinel markers
across re-runs (REQ-022; SYS-007; ARCH-010; MOD-014); (c) **Schema
Validator** — a `grep` script that fails closed when a generated
`plan.md` or `tasks.md` deviates from the spec-kit-core v0.7.0
pinned schema (REQ-IF-001, REQ-IF-002, REQ-029; SYS-010; ARCH-013;
MOD-017, MOD-018); (d) **Structured Summary** — a prompt section
in every command that emits the existing `--- v-model run summary
---` grammar on every exit path including failures (REQ-027,
REQ-IF-004; SYS-012; ARCH-016; MOD-021; HAZ-020, HAZ-025).

## Technical Context

**Language/Version**: Bash (POSIX, target shell `bash 4+`),
PowerShell 7+, Markdown with YAML frontmatter for the
`commands/*.md` files. **Net-new Python: 0 lines** (per
`drift-diff-plan.md` Classification Counts: 0 GENUINELY-NEW-PYTHON).
Existing `pyproject.toml` is test-evaluation-only and is not
modified by this feature.
**Primary Dependencies**: spec-kit core ≥ 0.1.0 (provides
`CommandRegistrar`, `setup-plan.sh`, `check-prerequisites.sh`,
`common.sh`); existing project scripts in `scripts/bash/`
(`build-matrix.sh`, `validate-requirement-coverage.sh`,
`validate-system-coverage.sh`,
`validate-architecture-coverage.sh`,
`validate-module-coverage.sh`, `validate-hazard-coverage.sh`); BATS
(shell unit tests), Pester (PowerShell unit tests), pytest +
DeepEval with Google `gemini-2.5-flash` for structural and
LLM-as-judge evaluations (constitution §Testing Stack). No new
runtime libraries are added.
**Storage**: Plaintext Markdown + YAML files under Git, per
constitution Principle IV. Inputs are read from
`specs/<feature>/v-model/`, the project root `extension.yml`, and
optionally `v-model-config.yml`. Outputs are written to
`specs/<feature>/` (canonical core artifacts) and to the paths
declared by each `MOD-NNN` Target Source File (generated source +
tests). All writes use the inline 3-line `tmp=$(mktemp -p
"$(dirname "$f")"); … ; mv "$tmp" "$f"` atomic-rename pattern (the
sole concurrency safeguard delivered in v0.7.0; SYS-015; HAZ-014,
HAZ-023, HAZ-025) (system-design.md §Data Design View; ARCH-010
contract).
**Testing**: BATS for the four new shell scripts (~40 BATS cases —
covers MOD-010, MOD-013, MOD-014, MOD-017, MOD-018, MOD-025;
parents UTP-010-A, UTP-013-A, UTP-014-A, UTP-017-A, UTP-018-A, UTP-025-A);
Pester mirrors for the PowerShell scripts; LLM structural-eval
under `tests/evals/` for the prompt-section modules (covers
MOD-001, MOD-002, MOD-003, MOD-004, MOD-005, MOD-006, MOD-007,
MOD-008, MOD-009, MOD-011, MOD-012, MOD-015, MOD-016, MOD-019,
MOD-021, MOD-022, MOD-023). Integration tests follow the
`integration-test.md` ITP set; system tests follow the `system-test.md`
STP set; acceptance tests follow `acceptance-plan.md` (53 ATPs / 54
SCNs across REQ-001 … REQ-029 + REQ-NF/IF/CN). Four-stack 100%
coverage is gated by GitHub Actions before merge per constitution
Principle II and SC-008 / REQ-NF-001.
**Target Platform**: Linux + macOS dev shells (Bash 4+); Windows
PowerShell 7+ via the PowerShell mirrors. Identical behaviour
required across both shell families (REQ-CN-001 keeps spec-kit
core untouched, so platform support is whatever spec-kit core
itself supports).
**Project Type**: Single repository (CLI extension to spec-kit
core). No web/mobile partitioning. The bridge commands plug into
spec-kit core via `extension.yml`; spec-kit core itself is
unmodified (REQ-CN-001; HAZ-018; ARCH-015).
**Performance Goals**: No quantitative SLO is stated in
`requirements.md` or `system-design.md` (the bridge commands are
single-shot, single-shell, sequential per invocation;
`architecture-design.md` §Process View). Practical target: a
typical feature run completes in seconds for the gate phase
(determined by the existing `validate-*-coverage.sh` scripts) and
in the LLM-driven generation budget for the prompt sections;
exact latency is bounded by upstream LLM throughput, not by this
feature's code.
**Constraints**:
- MUST NOT modify spec-kit core (REQ-CN-001; HAZ-011, HAZ-018).
- MUST reuse the six existing deterministic scripts; MUST NOT
  introduce a new wrapper script in the gate (REQ-017,
  REQ-CN-002; ATP-017-A; SCN-017-A1).
- MUST emit zero hallucinated V-Model identifiers (REQ-023,
  REQ-NF-002; SC-002; HAZ-007, HAZ-012, HAZ-023; ARCH-009).
- MUST be idempotent across re-runs; SYS-007 region splicer
  preserves user-authored content outside `<!-- BEGIN MANAGED
  id="…" -->` / `<!-- END MANAGED id="…" -->` sentinels (REQ-022,
  REQ-NF-005; HAZ-008, HAZ-014; ARCH-010; MOD-014).
- MUST emit a structured stdout summary on every exit path
  including failures (REQ-027, REQ-IF-004; HAZ-020, HAZ-025;
  SYS-012; ARCH-016; MOD-021).
- MUST NOT introduce a new Python package; net new Python = 0
  lines (drift-diff-plan.md Executive Summary; SYS-013 deprecated;
  ARCH-019 / ARCH-020 / ARCH-021 dropped; MOD-024 / MOD-026 /
  MOD-027 dropped).
- Concurrent invocations against the same feature directory are
  out of scope for v0.7.0 (REQ-CN-003, REQ-CN-004; SYS-015 §Risk
  Note); the only safeguard is the inline `mktemp`+`mv` pattern.
**Scale/Scope**:
- 3 new `commands/*.md` files (`plan.md`, `tasks.md`,
  `implement.md`) — ~150–180 prompt lines each.
- 4 new `scripts/bash/*.sh` scripts (`run-v-model-gate.sh ~30`,
  `validate-implements-ids.sh ~80`, `splice-managed-regions.sh
  ~85`, `validate-core-schema.sh ~50`) plus 4 PowerShell mirrors.
- 3 new YAML hook entries appended to `extension.yml`.
- 0 new Python source files.
- Surface area: 27 active `MOD-NNN` modules (MOD-001 … MOD-027),
  21 `ARCH-NNN` components (3 of which — ARCH-019/020/021 — are
  deferred risk notes with no functional contract), 15 `SYS-NNN`
  components (SYS-013 deprecated stub retained for ID stability;
  SYS-015 active), 25 `HAZ-NNN` hazards. 44 `REQ` entries (29
  functional + 6 NF + 5 IF + 4 CN).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1
design.*

### Pre-Design Evaluation (before research.md, before contracts)

| # | Principle | Verification | Result |
|---|-----------|--------------|--------|
| I | V-Model Discipline (paired dev/test specs; three-tier `REQ → ATP → SCN`; bidirectional traceability; tests-before-code) | The feature is fully decomposed under the V-cycle: 44 REQs → 29 SYS/ARCH/MOD chains → 53 ATPs / 54 SCNs in `acceptance-plan.md`; UTP/ITP/STP plans paired against MOD/ARCH/SYS in `unit-test.md`, `integration-test.md`, `system-test.md`; trace-matrix populated. The implement command itself enforces the pre-implementation gate (SYS-004 / ARCH-007 / MOD-010) and the hallucination guard (SYS-006 / ARCH-009 / MOD-013) before generating any code (REQ-017, REQ-023, REQ-NF-002, REQ-NF-004; SC-002, SC-005). Tests in this plan precede implementation per Phase 1's test-ordering rule (D-006). | ✅ |
| II | Deterministic Verification (coverage / matrix / structural validation by scripts, never AI self-assessment; CI enforces) | The Pre-Implementation Gate (SYS-004; ARCH-007; MOD-010) is a thin shell wrapper that invokes the existing `build-matrix.sh` + 5 `validate-*-coverage.sh` scripts and aggregates exit codes; no AI self-assessment is introduced (REQ-017, REQ-CN-002; SCN-017-A1; HAZ-009, HAZ-010). The Hallucination Guard (SYS-006; ARCH-009; MOD-013, MOD-025) is `grep`+`awk` only (system-design.md §SYS-006 Algorithm Specification). The Schema Validator (SYS-010; ARCH-013; MOD-017, MOD-018) is `grep`. The structural-eval ID-validation check provides 100% pass-rate evidence (REQ-NF-002; SC-002). | ✅ |
| III | Specification as Source of Truth (downstream artifacts derive from spec; reference by ID; revalidate on change) | `plan.md` (this file), `research.md`, `data-model.md`, `quickstart.md`, and `contracts/*.md` derive entirely from the V-Model artifact set under `specs/007-bridge-commands/v-model/` (the user-facing spec is `spec.md`; the V-Model artifacts ARE the downstream design). Every section in this plan, in `research.md` and in the contracts cites the V-Model ID it derives from. The hallucination guard (Section 8 of the workflow) verifies no IDs are invented. | ✅ |
| IV | Git as QMS (plaintext Markdown + Git; descriptive commits; CI gates on quality) | All deliverables (plan, research, data-model, quickstart, contracts) are plaintext Markdown committed in a single atomic commit with the prescribed Co-authored-by trailer. The implementation deliverables are likewise plaintext (`commands/*.md`, `scripts/bash/*.sh`, `scripts/powershell/*.ps1`, YAML). Branch protection on `main` enforces CI gates (REQ-NF-001, REQ-CN-003; ARCH-017; MOD-022). | ✅ |
| V | Human-in-the-Loop (PR review; `[NEEDS CLARIFICATION]` marker on ambiguity; AI drafts, human decides) | This plan is generated by `/speckit.plan` as a draft; merge requires PR review per project policy. `NEEDS CLARIFICATION` count in this output: **0** (every Technical Context field is resolved by reading the V-Model artifacts; no field is invented). The only deviations from the work order are documented in `drift-diff-plan.md` §Addendum (SYS-013 deprecation deferred; ARCH-017 / MOD-022 reactivated as prompt sections; SYS-015 added) and are explicitly cited in this plan, leaving the human decision audit-trail intact. | ✅ |

**Pre-design gate: ✅ All five principles satisfied. Proceed to Phase 0.**

### Post-Design Re-Evaluation (after Phase 1 outputs)

| # | Principle | Verification | Result |
|---|-----------|--------------|--------|
| I | V-Model Discipline | `data-model.md` is sourced strictly from `system-design.md §Data Design View`; every entity carries the SYS-NNN it belongs to. `contracts/` contains one file per active `ARCH-NNN` (21 files including the 3 deferred-risk notes for ARCH-019/020/021 to preserve ID coverage); each contract cites its parent SYS and the MOD modules that realise it. `quickstart.md` is sourced from `acceptance-plan.md` SCN scenarios for the three top-priority user stories (P1: User Story 1 → SCN-015-A1, SCN-016-A1, SCN-016-B1; P2: User Story 2 → SCN-001-A1, SCN-002-A1; P2: User Story 3 → SCN-011-A1, SCN-014-B1). Test ordering (D-006 in `research.md`) is TDD-first per REQ-011; 0 source code is written by this PR. | ✅ |
| II | Deterministic Verification | Contracts for ARCH-007, ARCH-009, ARCH-010, ARCH-013 each pin their CLI invocation, exit-code semantics, and stdout schema. The hallucination-guard step at the end of this workflow (D-008) operates on the deterministic canonical-ID grep extracted from the V-Model artifacts (764 IDs at this run); no AI inspection of the generated documents was relied upon. | ✅ |
| III | Specification as Source of Truth | Each entity in `data-model.md`, each contract in `contracts/`, and each scenario in `quickstart.md` cites its V-Model source by ID. `research.md` decisions D-001 … D-NNN each cite at least one REQ/SYS/ARCH/MOD/HAZ ID. The post-design hallucination-guard run (Phase 1 closing step) confirmed 0 unmapped IDs in the generated outputs. | ✅ |
| IV | Git as QMS | The full Phase 0 + Phase 1 output (this plan + `research.md` + `data-model.md` + `quickstart.md` + `contracts/*.md` + the agent-context refresh) is staged for one atomic commit. No follow-up commits are planned to fix omissions; failures detected by the hallucination guard are fixed in place before commit. | ✅ |
| V | Human-in-the-Loop | `NEEDS CLARIFICATION` count after Phase 1: **0**. The post-rework deviations recorded in `drift-diff-plan.md` §Addendum are surfaced verbatim in `research.md` D-013 (SYS-013 deprecation deferred) and D-014 (ARCH-017 / MOD-022 reactivated), so the reviewer can make an informed accept/reject decision. | ✅ |

**Post-design gate: ✅ All five principles re-verified. No new
violations introduced by Phase 1 outputs. Complexity Tracking
section below remains empty.**

## Project Structure

### Documentation (this feature)

```text
specs/007-bridge-commands/
├── spec.md              # Feature specification (input; do not modify)
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output — design decisions D-001..D-NNN
├── data-model.md        # Phase 1 output — entities from system-design.md §Data Design View
├── quickstart.md        # Phase 1 output — derived from acceptance-plan.md SCN scenarios
├── contracts/           # Phase 1 output — one file per active ARCH-NNN
│   ├── ARCH-001-plan-synthesis-orchestrator.md
│   ├── ARCH-002-canonical-artifact-emitter.md
│   ├── ARCH-003-tasks-synthesis-orchestrator.md
│   ├── ARCH-004-implementation-orchestrator.md
│   ├── ARCH-005-code-generator.md
│   ├── ARCH-006-test-generator.md
│   ├── ARCH-007-pre-implementation-gate.md
│   ├── ARCH-008-additive-enrichment-encoder.md
│   ├── ARCH-009-hallucination-guard.md
│   ├── ARCH-010-source-region-splicer.md
│   ├── ARCH-011-domain-overlay-loader.md
│   ├── ARCH-012-hazard-task-emitter.md
│   ├── ARCH-013-schema-validator.md
│   ├── ARCH-014-reduced-enrichment-fallback.md
│   ├── ARCH-015-hook-registrar.md
│   ├── ARCH-016-structured-summary-reporter.md
│   ├── ARCH-017-quality-compliance-harness.md
│   ├── ARCH-018-commit-annotator.md
│   ├── ARCH-019-v-model-artifact-reader.md   # Deferred risk note
│   ├── ARCH-020-subprocess-runner.md         # Deferred risk note
│   └── ARCH-021-filesystem-writer.md         # Deferred risk note
├── v-model/             # Frozen V-Model artifact set (input; do not modify)
└── tasks.md             # Phase 2 output (/speckit.tasks — NOT created here)
```

### Source Code (repository root)

```text
# 3 new Markdown command-prompt files (LLM prompts; YAML frontmatter)
commands/
├── plan.md              # /speckit.v-model.plan         — wraps SYS-001/005/010/012; ARCH-001/002/008/013/014/016; MOD-001/002/011/021
├── tasks.md             # /speckit.v-model.tasks        — wraps SYS-002/005/009/010/012; ARCH-003/008/012/013/014/016; MOD-003/004/012/016/019/021
└── implement.md         # /speckit.v-model.implement    — wraps SYS-003/006/007/008/012/014; ARCH-004/005/006/009/010/011/016/017/018; MOD-005/006/007/008/009/013/015/021/022/023

# 4 new POSIX shell scripts + PowerShell mirrors (deterministic verification)
scripts/bash/
├── run-v-model-gate.sh           # ARCH-007 / MOD-010 — calls build-matrix.sh + 5 validate-*-coverage.sh
├── validate-implements-ids.sh    # ARCH-009 / MOD-013, MOD-025 — grep+awk hallucination guard
├── splice-managed-regions.sh     # ARCH-010 / MOD-014 — awk region splicer
└── validate-core-schema.sh       # ARCH-013 / MOD-017, MOD-018 — grep schema validator (--plan|--tasks)
scripts/powershell/
├── run-v-model-gate.ps1
├── validate-implements-ids.ps1
├── splice-managed-regions.ps1
└── validate-core-schema.ps1

# 3 hook YAML entries (REUSE-CORE; consumed by spec-kit core CommandRegistrar)
extension.yml             # append: hooks.after_specify → v-model.requirements
                          #         hooks.before_implement → v-model.trace
                          #         hooks.after_implement  → v-model.trace
                          # (existing after_tasks → v-model.trace entry preserved)

# Tests (TDD; written before any of the above per D-006)
tests/bats/                       # BATS unit tests for the 4 new shell scripts (UTP-010-A/013/014/017/018/025)
tests/pester/                     # Pester mirrors
tests/evals/                      # pytest + DeepEval structural + LLM-as-judge for the prompt-section modules
                                  # (UTP-001-A..009/011/012/015/016/019/021/023; ITP set; STP set; ATP/SCN set)

# Existing scripts REUSED unchanged (REQ-017, REQ-CN-002):
scripts/bash/build-matrix.sh
scripts/bash/validate-requirement-coverage.sh
scripts/bash/validate-system-coverage.sh
scripts/bash/validate-architecture-coverage.sh
scripts/bash/validate-module-coverage.sh
scripts/bash/validate-hazard-coverage.sh
```

**Structure Decision**: Single-repository CLI extension. The
project is a spec-kit extension (not a standalone web/mobile/api
application), so Options 2 and 3 of the template are not
applicable. The realisation paradigm is **Markdown + shell + YAML;
zero new Python files** (drift-diff-plan.md Executive Summary;
research.md D-001). The realisation map above corresponds 1:1 to
the Module Map in `module-design.md §Module Map (Summary Index)`,
covering all 27 active MOD entries (with MOD-024 / MOD-026 /
MOD-027 carried as deferred-risk notes per drift-diff-plan.md and
research.md D-002).

## Complexity Tracking

> Fill ONLY if Constitution Check has violations that must be
> justified.

*(empty — no Constitution Check violations were identified in
either the pre- or post-design evaluations; the project does not
introduce a new framework, project, or pattern that would require
justification beyond what is already captured by the V-Model
artifact set and `drift-diff-plan.md` §Addendum.)*
