# ARCH-015: Hook Registrar

<!-- v-model-enrichment: feature=007-bridge-commands -->
<!-- source: architecture-design.md §Interface View ARCH-015 -->

**Module Type**: One-time installer  
**Target Source File**: `src/v_model_extension/shared/hook_registrar.py` (MOD-020)  
**Invoked by**: Extension install step (once per repository)

---

## Interface Contract

| Direction | Name | Type | Format | Constraints |
|-----------|------|------|--------|-------------|
| Input | `extensions_yml_path` | path | `.specify/extensions.yml` | MUST exist; only registrations are written |
| Output | `WriteResult` | struct | `{added: int, skipped_existing: int}` | idempotent — re-runs do not duplicate entries |
| Exception | `IOError` | from ARCH-021 | text | propagated |

## Hook Points Registered

| Hook point | Command | Source requirement |
|------------|---------|-------------------|
| `after_specify` | `v-model.requirements` | REQ-IF-005 |
| `before_implement` | `v-model.trace` | REQ-IF-003 |
| `after_implement` | `v-model.trace` | REQ-IF-003 |
