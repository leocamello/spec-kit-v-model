# ARCH-011: Domain Overlay Loader

<!-- v-model-enrichment: feature=007-bridge-commands -->
<!-- source: architecture-design.md §Interface View ARCH-011 -->

**Module Type**: Transform (optional)  
**Target Source File**: `src/v_model_extension/implement/overlay_loader.py` (MOD-015)  
**Invoked by**: ARCH-004 (Stage 3)

---

## Interface Contract

| Direction | Name | Type | Format | Constraints |
|-----------|------|------|--------|-------------|
| Input | `generation_plan` | struct | as for ARCH-005/006 | |
| Input | `domain_config` | struct \| null | parsed YAML from `v-model-config.yml` | `null` ⟹ identity transform; non-null ⟹ overlay-augmented plan |
| Output | `augmented_plan` | struct | superset of input | adds e.g. MC/DC obligations, ASIL markers |
| Exception | `OverlayParseError` | raised | text | propagated to ARCH-004 (fail-closed) |

## Notes

When `v-model-config.yml` is absent from the repository root, `domain_config`
is `null` and ARCH-011 returns the input plan unchanged (identity transform).
Absent config is a valid configuration state, not an error (REQ-CN-001).
