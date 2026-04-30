# ARCH-003: Tasks Synthesis Orchestrator

<!-- v-model-enrichment: feature=007-bridge-commands -->
<!-- source: architecture-design.md §Interface View ARCH-003 -->

**Module Type**: CLI entry point  
**Target Source File**: `src/v_model_extension/tasks/orchestrator.py` (MOD-003)  
**Invoked by**: spec-kit CLI host as a one-shot subprocess

---

## Interface Contract

| Direction | Name | Type | Format | Constraints |
|-----------|------|------|--------|-------------|
| Input | `feature_dir` | path | absolute filesystem path | MUST contain `requirements.md`; `plan.md` optional |
| Input | `arguments` | string | UTF-8 | optional CLI `$ARGUMENTS` |
| Output | exit code | int | `0 \| 1` | 0 on success; 1 on schema or hazard-enrichment failure |
| Output | side-effect | file | `feature_dir/tasks.md` | always emitted on exit 0 |
| Exception | `HazardEnrichmentError` | propagated | text | when ARCH-012 raises and `hazard-analysis.md` is present |
| Exception | `SchemaValidationError` | propagated | text + section + line | when ARCH-013 returns `{valid: false}` |
| Exception | `UpstreamParseError` | propagated | text + path + line | when ARCH-014 cannot parse the upstream document for enrichment markers; fail-closed per ARCH-014 contract |

## Data Flow (Tasks Path)

Stage 1: ARCH-019 (parse artifacts)  
Stage 2: ARCH-014 (detect enrichment in upstream `plan.md`)  
Stage 3: ARCH-003 (build TDD-ordered task list)  
Stage 4: ARCH-012 (hazard task elevation)  
Stage 5: ARCH-008 (inject `traces-to` comments)  
Stage 6: ARCH-013 (schema validation)  
Stage 7: ARCH-021 (atomic write of `tasks.md`)

## Key Acceptance Scenarios

- SCN-009-A1: consumes `v-model.plan`-produced plan; exit 0
- SCN-009-B1: consumes plain `speckit.plan`-produced plan; reduced-enrichment warning
- SCN-011-A1: TDD task ordering verified
- SCN-013-A1: `[P]` markers placed on independent modules
- SCN-014-A1: hazard mitigation tasks elevated in priority
