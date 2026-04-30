# ARCH-012: Hazard Task Emitter

<!-- v-model-enrichment: feature=007-bridge-commands -->
<!-- source: architecture-design.md §Interface View ARCH-012 -->

**Module Type**: Pure transform  
**Target Source File**: `src/v_model_extension/tasks/hazard_emitter.py` (MOD-016)  
**Invoked by**: ARCH-003 (Stage 4)

---

## Interface Contract

| Direction | Name | Type | Format | Constraints |
|-----------|------|------|--------|-------------|
| Input | `tasks` | list[Task] | TDD-ordered task list | |
| Input | `hazard_analysis` | parsed `hazard-analysis.md` | struct | absent ⟹ identity transform (early return) |
| Output | `enriched_tasks` | list[Task] | augmented | adds verification tasks per `HAZ-NNN`; raises priority on mitigation tasks |
| Exception | `MalformedHazardAnalysis` | raised | text + line | when the input fails parse |

## Key Acceptance Scenarios

- SCN-014-A1: mitigation task for HAZ-001 carries elevated priority marker + `HAZ-001` in `traces-to`
- SCN-014-B1: one verification task per HAZ emitted with title `"Verify mitigation for HAZ-NNN"`
