# ARCH-018: Commit Annotator

<!-- v-model-enrichment: feature=007-bridge-commands -->
<!-- source: architecture-design.md §Interface View ARCH-018 -->

**Module Type**: Git integrator  
**Target Source File**: `src/v_model_extension/shared/commit_annotator.py` (MOD-023)  
**Invoked by**: ARCH-004 (Stage 8)

---

## Interface Contract

| Direction | Name | Type | Format | Constraints |
|-----------|------|------|--------|-------------|
| Input | `message` | string | UTF-8 | base commit message |
| Input | `ids` | list[string] | V-Model identifiers | empty list permitted (produces warning, no suffix) |
| Output | `annotated_message` | string | UTF-8 | `<message> — <id>, <id>, ...` (suffix omitted when `ids == []`) |
| Side-effect | `git commit` | invocation via ARCH-020 | — | exits non-zero only if Git itself fails; annotation failure is a warning, not a hard error |

## Format

```
feat(<scope>): <subject> — MOD-NNN, REQ-NNN, ...
```
