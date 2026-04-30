# ARCH-010: Source Region Splicer

<!-- v-model-enrichment: feature=007-bridge-commands -->
<!-- source: architecture-design.md §Interface View ARCH-010 -->

**Module Type**: Pure transform  
**Target Source File**: `src/v_model_extension/implement/region_manager.py` (MOD-014)  
**Invoked by**: ARCH-004 (Stage 5)

---

## Interface Contract

| Direction | Name | Type | Format | Constraints |
|-----------|------|------|--------|-------------|
| Input | `target_path` | path | absolute path; may not exist | |
| Input | `generated_content` | string | UTF-8 | belongs inside one V-Model-managed region |
| Output | `final_content` | string | UTF-8 | preserves all bytes outside V-Model-managed regions |
| Exception | `RegionConflict` | raised | diff report | when existing markers overlap |

## User-Content Preservation

All bytes outside V-Model-managed regions are preserved verbatim across
re-runs (REQ-022). This is the primary mechanism enabling iterative
code generation without clobbering user edits.
