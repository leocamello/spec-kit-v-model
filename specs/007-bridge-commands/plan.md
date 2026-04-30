# Implementation Plan: Bridge Commands (V-Model ↔ Spec-Kit Core)

<!-- v-model-enrichment: feature=007-bridge-commands -->

**Branch**: `feature/007-bridge-commands` | **Date**: 2026-04-30 | **Spec**: [specs/007-bridge-commands/spec.md](spec.md)  
**Input**: Feature specification from `specs/007-bridge-commands/spec.md`

## Summary

Add three bridge commands (`/speckit.v-model.plan`, `/speckit.v-model.tasks`,
`/speckit.v-model.implement`) that close the spec-to-code gap by consuming a
complete V-Model artifact set and emitting outputs byte-compatible with spec-kit
core canonical schemas. V-Model traceability metadata is layered as additive
enrichment (HTML comments, optional Markdown sections) that spec-kit core tools
harmlessly ignore. `v-model.implement` adds a deterministic pre-implementation
gate (reusing existing `build-matrix` / `validate-*-coverage` scripts), a
Hallucination Guard (regex+set-lookup, no LLM), and a Source Region Manager
for idempotent re-runs over hand-written code.

<!-- v-model-trace: REQ-001 → SYS-001 → MOD-001 | REQ-015 → SYS-003 → MOD-005 | REQ-023 → SYS-006 → MOD-013 -->

## Technical Context

**Language/Version**: Python 3.11 (per existing `src/` module convention; all 27 `MOD-NNN` Target Source Files are `.py` — Source: module-design.md §Module Map)  
**Primary Dependencies**: `pathlib`, `re`, `subprocess`, `yaml` (stdlib only for deterministic modules); existing BATS, Pester, pytest+DeepEval test stacks (Source: constitution.md §Testing Stack)  
**Storage**: Filesystem + Markdown (Git-tracked under `specs/<feature>/` and declared `MOD-NNN` Target Source Files; no databases — Source: system-design.md §Data Design View)  
**Testing**: BATS (Bash shell scripts), Pester (PowerShell scripts), pytest + DeepEval GEval metrics (structural eval + LLM eval) — per constitution.md §Testing Stack; 100% four-stack coverage required before merge (REQ-NF-001)  
**Target Platform**: CLI host process (Linux/macOS/Windows); spec-kit slash-command subprocess; no internal concurrency (Source: architecture-design.md §Overview — "single-threaded sequential per command invocation")  
**Project Type**: Single-project Python extension package under `src/v_model_extension/`  
**Performance Goals**: No quantified performance budget; bounded by I/O and LLM latency; idempotency ≥ 95% structural identity required (REQ-025, Source: system-design.md §Quality Attribute Coverage — Performance Efficiency)  
**Constraints**: (a) MUST NOT modify spec-kit core (REQ-CN-001); (b) MUST NOT introduce new gating wrapper scripts (REQ-CN-002); (c) MUST NOT introduce orchestrator/supervisor/sandbox/model-tiering (REQ-CN-003); (d) all enrichment as HTML comments only — MUST NOT shift Markdown heading levels (HAZ-011); (e) Hallucination Guard MUST be deterministic regex+set-lookup with NO LLM call (Source: system-design.md §SYS-006 Algorithm Specification)  
**Scale/Scope**: 44 requirements, 14 SYS components, 21 ARCH modules, 27 MOD functions across 18 target source files; 25 HAZs; 53 ATPs / 54 SCNs; 60 STSs; 74 ITSs (Source: system-design.md §Coverage Summary, hazard-analysis.md §Coverage Summary)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Pre-Design Evaluation (2026-04-30)

| Principle | Requirement | Status | Evidence |
|-----------|-------------|--------|----------|
| **I. V-Model Discipline** | Every REQ-NNN has a paired ATP-NNN; every ATP has ≥1 SCN; 100% bidirectional coverage. | ✅ PASS | `trace-matrix.md` Matrix A maps all 44 REQs → ATPs → SCNs. `v-model.implement` itself will generate tests before code (REQ-011 TDD ordering). |
| **II. Deterministic Verification** | Coverage computed by scripts, not AI self-assessment. | ✅ PASS | Pre-implementation gate reuses `build-matrix` + `validate-*-coverage` (REQ-017); Hallucination Guard is regex+set-lookup with zero LLM involvement (SYS-006 algorithm spec). |
| **III. Specification as Source of Truth** | All design derives from V-Model artifact set; implementation follows spec. | ✅ PASS | The 8 approved V-Model artifacts are the sole design input; plan.md is synthesized from them. Zero design decisions introduced without artifact citation. |
| **IV. Git as Quality Management System** | All artifacts plaintext Markdown in Git; no binary formats. | ✅ PASS | All 27 Target Source Files are `.py`; all spec artifacts are `.md`. Hook registrations go to `.specify/extensions.yml`. |
| **V. Human-in-the-Loop** | NEEDS CLARIFICATION items present; human must resolve before implementation begins. | ✅ PASS | See `research.md` — 0 unresolved NEEDS CLARIFICATION items (all resolved by V-Model artifact citations). |

**Pre-Design Verdict**: ✅ ALL GATES PASS — proceed to Phase 0 / Phase 1.

### Post-Design Evaluation (2026-04-30)

| Principle | Status | Notes |
|-----------|--------|-------|
| **I. V-Model Discipline** | ✅ PASS | `data-model.md` derived from system-design.md §Data Design View; `contracts/` derived from architecture-design.md §Interface View. No new requirements introduced. |
| **II. Deterministic Verification** | ✅ PASS | SYS-006 Hallucination Guard algorithm specification is deterministic by construction (pure function, no LLM). Schema validators (MOD-017, MOD-018) are deterministic. |
| **III. Specification as Source of Truth** | ✅ PASS | Every section of this plan cites the originating V-Model artifact ID. |
| **IV. Git as Quality Management System** | ✅ PASS | No binary outputs. Atomic file-write (MOD-027) keeps filesystem consistent. |
| **V. Human-in-the-Loop** | ✅ PASS | All generated plan artifacts are drafts awaiting human PR review before implementation proceeds. |

**Post-Design Verdict**: ✅ ALL GATES PASS — proceed to task generation (`/speckit.v-model.tasks`).

## Project Structure

### Documentation (this feature)

```text
specs/007-bridge-commands/
├── plan.md              # This file (/speckit.v-model.plan output)
├── research.md          # Phase 0 output (all design decisions with V-Model citations)
├── data-model.md        # Phase 1 output (entities from system-design.md Data Design View)
├── quickstart.md        # Phase 1 output (three user paths from spec.md + acceptance-plan.md)
├── contracts/           # Phase 1 output (API contracts from architecture-design.md Interface View)
│   ├── ARCH-001-plan-synthesis-orchestrator.md
│   ├── ARCH-002-canonical-artifact-emitter.md
│   ├── ARCH-003-tasks-synthesis-orchestrator.md
│   ├── ARCH-004-implementation-orchestrator.md
│   ├── ARCH-005-code-generator.md
│   ├── ARCH-006-test-generator.md
│   ├── ARCH-007-pre-implementation-gate-coordinator.md
│   ├── ARCH-008-additive-enrichment-encoder.md
│   ├── ARCH-009-hallucination-guard.md
│   └── ... (one file per ARCH-NNN interface)
└── tasks.md             # Phase 2 output (/speckit.v-model.tasks — NOT created by /speckit.v-model.plan)
```

### Source Code (repository root)

```text
src/v_model_extension/
├── commands/
│   ├── plan.py           # MOD-001: plan_orchestrator.run          (ARCH-001)
│   ├── tasks.py          # MOD-003: tasks_orchestrator.run         (ARCH-003)
│   └── implement.py      # MOD-005: implement_orchestrator.run     (ARCH-004)
├── emit/
│   └── canonical.py      # MOD-002: emit_canonical_outputs         (ARCH-002)
├── tasks/
│   ├── sequencer.py      # MOD-004: build_tdd_task_list            (ARCH-003)
│   └── hazards.py        # MOD-016: enrich_with_hazards            (ARCH-012)
├── codegen/
│   ├── generator.py      # MOD-006: generate_code (dispatcher)     (ARCH-005)
│   ├── renderer.py       # MOD-007: render_module_source           (ARCH-005)
│   └── splicer.py        # MOD-014: splice_managed_regions         (ARCH-010)
├── testgen/
│   ├── generator.py      # MOD-008: generate_tests (dispatcher)    (ARCH-006)
│   └── renderer.py       # MOD-009: render_test_file_for_level     (ARCH-006)
├── gate/
│   └── coordinator.py    # MOD-010: evaluate_gate                  (ARCH-007)
├── enrich/
│   └── encoder.py        # MOD-011: embed_enrichment               (ARCH-008)
│                         # MOD-012: embed_traceability_comments    (ARCH-008)
├── guard/
│   └── hallucination.py  # MOD-013: verify_ids                     (ARCH-009)
├── overlay/
│   └── loader.py         # MOD-015: apply_overlay                  (ARCH-011)
├── schema/
│   ├── validator.py      # MOD-017: validate_plan_schema           (ARCH-013)
│                         # MOD-018: validate_tasks_schema          (ARCH-013)
│   └── fallback.py       # MOD-019: detect_enrichment              (ARCH-014)
├── hooks/
│   └── registrar.py      # MOD-020: register_hooks                 (ARCH-015)
├── report/
│   └── summary.py        # MOD-021: emit_summary                   (ARCH-016)
├── quality/
│   └── harness.py        # MOD-022: compute_coverage_report        (ARCH-017)
├── git/
│   └── annotator.py      # MOD-023: annotate_commit                (ARCH-018)
└── io/
    ├── artifact_reader.py # MOD-024: load_artifacts                (ARCH-019 [CC])
    │                      # MOD-025: extract_id_set               (ARCH-019 [CC])
    ├── subprocess_runner.py # MOD-026: run_subprocess              (ARCH-020 [CC])
    └── fs_writer.py       # MOD-027: atomic_write                  (ARCH-021 [CC])

tests/
├── bats/                  # BATS shell-script unit tests (per constitution.md)
├── pester/                # Pester PowerShell tests (per constitution.md)
├── evals/                 # pytest + DeepEval structural + LLM eval tests
│   └── test_bridge_commands_eval.py
└── unit/                  # pytest unit tests (mocked, per UTP-NNN-C patterns)
    └── test_bridge_commands/
        ├── test_plan.py        # UTP-001-*
        ├── test_tasks.py       # UTP-003-*, UTP-004-*
        ├── test_implement.py   # UTP-005-*
        ├── test_codegen.py     # UTP-006-*, UTP-007-*
        ├── test_testgen.py     # UTP-008-*, UTP-009-*
        ├── test_gate.py        # UTP-010-*
        ├── test_encoder.py     # UTP-011-*, UTP-012-*
        ├── test_guard.py       # UTP-013-*  (incl. UTS-013-A2 phantom REQ-999 fixture)
        ├── test_splicer.py     # UTP-014-*
        ├── test_overlay.py     # UTP-015-*
        ├── test_hazards.py     # UTP-016-*
        ├── test_validator.py   # UTP-017-*, UTP-018-*
        ├── test_fallback.py    # UTP-019-*
        ├── test_registrar.py   # UTP-020-*
        ├── test_summary.py     # UTP-021-*
        ├── test_harness.py     # UTP-022-*
        ├── test_annotator.py   # UTP-023-*
        ├── test_artifact_reader.py # UTP-024-*, UTP-025-*
        ├── test_subprocess_runner.py # UTP-026-*
        └── test_fs_writer.py   # UTP-027-*
```

**Structure Decision**: Single Python extension package under `src/v_model_extension/` (Option 1 pattern). Package layout mirrors the 9-subdirectory decomposition from module-design.md §Module Map, where each subdirectory corresponds to one architecture seam (commands, emit, tasks, codegen, testgen, gate, enrich, guard, overlay, schema, hooks, report, quality, git, io). This directly satisfies REQ-CN-001 (no modification to spec-kit core) and REQ-CN-002 (no new wrapper scripts).

## Complexity Tracking

> No Constitution Check violations to justify.

All five principles pass pre- and post-design. The design complexity (14 SYS
components, 21 ARCH modules, 27 MODs) is mandated by the approved V-Model
artifacts and reflects the scope of three interoperable commands with a
shared cross-cutting infrastructure layer. No unnecessary patterns are
introduced.

## V-Model Traceability

<!-- traces-to: REQ-001 → SYS-001 → ARCH-001 → MOD-001 (v-model.plan orchestrator) -->
<!-- traces-to: REQ-015 → SYS-003 → ARCH-004 → MOD-005 (v-model.implement orchestrator) -->
<!-- traces-to: REQ-023 → SYS-006 → ARCH-009 → MOD-013 (Hallucination Guard) -->
<!-- traces-to: REQ-016 → SYS-004 → ARCH-007 → MOD-010 (Pre-Implementation Gate) -->
<!-- traces-to: REQ-029 → SYS-010 → ARCH-013 → MOD-017 + MOD-018 (Schema Validator) -->
