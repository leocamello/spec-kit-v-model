# ARCH-004: Implementation Orchestrator

<!-- v-model-enrichment: feature=007-bridge-commands -->
<!-- source: architecture-design.md §Interface View ARCH-004 -->

**Module Type**: CLI entry point  
**Target Source File**: `src/v_model_extension/implement/orchestrator.py` (MOD-005)  
**Invoked by**: spec-kit CLI host as a one-shot subprocess

---

## Interface Contract

| Direction | Name | Type | Format | Constraints |
|-----------|------|------|--------|-------------|
| Input | `feature_dir` | path | absolute filesystem path | MUST contain `requirements.md`, `module-design.md`, all four V-Model test plans |
| Input | `arguments` | string | UTF-8 | optional CLI `$ARGUMENTS` |
| Output | exit code | int | `0 \| 1` | 1 if any of: gate fails, hallucination detected, region conflict, overlay failure |
| Output | side-effects | files + commits | written to MOD-NNN Target Source Files + git commits | atomically all-or-nothing per run |
| Exception | `GateFailure` | propagated | gap report | when ARCH-007 returns `{passed: false}` |
| Exception | `HallucinationDetected` | propagated | list of `(file, line, id)` | when ARCH-009 returns `{valid: false}` |
| Exception | `RegionConflict` | propagated | diff report | when ARCH-010 detects overlapping markers |
| Exception | `IOError` | propagated | text + path | from ARCH-021 atomic write at Stage 7; aborts the run during the write phase, after ARCH-009 verification has already passed |

## Data Flow (Source Code Path)

Stage 1: ARCH-019 (parse artifacts)  
Stage 2: ARCH-007 (pre-implementation gate — must be `passed: true` to proceed)  
Stage 3: ARCH-011 (domain overlay loader)  
Stage 4: ARCH-005 (code generator)  
Stage 5: ARCH-010 (source region splicer)  
Stage 6: ARCH-009 (hallucination guard — must be `valid: true` to proceed)  
Stage 7: ARCH-021 (atomic write of source files)  
Stage 8: ARCH-018 (annotated git commit)

## Abort Conditions

| Condition | Effect |
|-----------|--------|
| ARCH-007 returns `passed: false` | Abort before Stage 3; no files written |
| ARCH-009 returns `valid: false` | Abort before Stage 7; no files written; no commit |
| ARCH-021 raises `IOError` at Stage 7 | Abort; no commit; partial files left in tmp namespace per ARCH-021 atomic semantics |

## Key Acceptance Scenarios

- SCN-015-A1: direct path — no plan.md / tasks.md; source files emitted
- SCN-016-A1: gate refuses on Matrix A gap; exit non-zero; zero files written
- SCN-017-A1: gate uses only existing deterministic scripts
- SCN-018-A1: generated code lands at MOD-NNN Target Source File paths
- SCN-020-A1: hallucination guard blocks phantom IDs
