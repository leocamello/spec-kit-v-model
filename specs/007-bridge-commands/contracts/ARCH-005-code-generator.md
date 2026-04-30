# ARCH-005: Code Generator

<!-- v-model-enrichment: feature=007-bridge-commands -->
<!-- source: architecture-design.md §Interface View ARCH-005 -->

**Module Type**: Pure transform  
**Target Source File**: `src/v_model_extension/implement/generator.py` (MOD-006)  
**Invoked by**: ARCH-004 (Stage 4)

---

## Interface Contract

| Direction | Name | Type | Format | Constraints |
|-----------|------|------|--------|-------------|
| Input | `generation_plan` | struct | `{modules[], language_per_module, target_paths}` | every entry has a `MOD-NNN` and a Target Source File |
| Output | `file_set` | list[(path, content)] | absolute paths + UTF-8 content | every emitted file contains ≥1 `// Implements <ID>` (language-appropriate) comment |
| Exception | `RegionConflict` | from ARCH-010 | propagated | aborts before any file is written |
| Exception | `IOError` | from ARCH-021 | text + path | raised by ARCH-021 in Stage 7 (after ARCH-009 returns `valid: true`) when atomic-write of an emitted source file fails; ARCH-005 itself never writes to disk |

## Notes

ARCH-005 is a **pure transform**. It returns `(path, content)` tuples to
ARCH-004; it does not write to disk. Disk writes are performed by ARCH-021
after ARCH-009 verification has passed.
