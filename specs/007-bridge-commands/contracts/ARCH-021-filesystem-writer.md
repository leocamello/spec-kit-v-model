# ARCH-021 [CROSS-CUTTING]: Filesystem Writer

<!-- v-model-enrichment: feature=007-bridge-commands -->
<!-- source: architecture-design.md §Interface View ARCH-021 -->

**Module Type**: Cross-cutting atomic writer  
**Target Source File**: `src/v_model_extension/shared/fs_writer.py` (MOD-027)  
**Invoked by**: ARCH-002, ARCH-015; indirectly via ARCH-005, ARCH-006 (results passed through ARCH-004 → ARCH-021)

---

## Interface Contract

| Direction | Name | Type | Format | Constraints |
|-----------|------|------|--------|-------------|
| Input | `path` | path | absolute path | |
| Input | `content` | bytes | UTF-8 (typical) | |
| Output | (side-effect) | file at `path` | atomic | write-to-tmp + rename; failed writes leave the existing file untouched |
| Exception | `IOError` | raised | text + errno | propagated |

## Atomicity Guarantee

ARCH-021 uses write-to-temp + rename semantics. A failed write never
partially overwrites an existing file. Callers may assume that either the
full new content is on disk or the original file is unchanged.
