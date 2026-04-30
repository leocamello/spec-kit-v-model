# ARCH-002: Canonical Artifact Emitter

<!-- v-model-enrichment: feature=007-bridge-commands -->
<!-- source: architecture-design.md §Interface View ARCH-002 -->

**Module Type**: Output writer  
**Target Source File**: `src/v_model_extension/plan/emitter.py` (MOD-002)  
**Invoked by**: ARCH-001

---

## Interface Contract

| Direction | Name | Type | Format | Constraints |
|-----------|------|------|--------|-------------|
| Input | `canonical_outputs` | struct | `{plan, data_model, contracts[], quickstart, research}` | each field optional; absent fields → file not emitted |
| Output | written paths | list[path] | absolute paths | one entry per file actually written |
| Exception | `IOError` | from ARCH-021 | text | propagated when atomic write fails |

## Downstream Modules Called

ARCH-021 (for every file written)

## Notes

Delegates all disk I/O to ARCH-021 (atomic write). Never writes partial files.
