# ARCH-001: Plan Synthesis Orchestrator

<!-- v-model-enrichment: feature=007-bridge-commands -->
<!-- source: architecture-design.md §Interface View ARCH-001 -->

**Module Type**: CLI entry point  
**Target Source File**: `src/v_model_extension/plan/orchestrator.py` (MOD-001)  
**Invoked by**: spec-kit CLI host as a one-shot subprocess

---

## Interface Contract

| Direction | Name | Type | Format | Constraints |
|-----------|------|------|--------|-------------|
| Input | `feature_dir` | path | absolute filesystem path | MUST contain `requirements.md`; other artifacts optional |
| Input | `arguments` | string | UTF-8 | optional CLI `$ARGUMENTS` |
| Output | exit code | int | `0 \| 1` | 0 on success (incl. graceful-degradation warnings); 1 on schema-bridge failure |
| Output | stdout summary | text | ARCH-016 format | always emitted |
| Output | side-effects | files | written to `feature_dir/` | `plan.md`, `data-model.md`, `contracts/`, `quickstart.md`, `research.md` (subset when optional inputs absent) |
| Exception | `EnrichmentError` | propagated | text + stack | when ARCH-008 raises |
| Exception | `SchemaValidationError` | propagated | text + section + line | when ARCH-013 returns `{valid: false}` |

## Downstream Modules Called

ARCH-019 → ARCH-008 → ARCH-013 → ARCH-002 (→ ARCH-021)  
Also calls ARCH-016 for structured summary.

## Key Acceptance Scenarios

- SCN-001-A1: full artifact read → `inputs_read` lists 11 paths; exit 0
- SCN-002-A1: emitted `plan.md` round-trips through unmodified `speckit.tasks`
- SCN-008-A1: missing optional artifacts produce warnings, not failure
