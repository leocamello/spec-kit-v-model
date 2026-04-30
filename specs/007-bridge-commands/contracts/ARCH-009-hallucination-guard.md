# ARCH-009: Hallucination Guard

<!-- v-model-enrichment: feature=007-bridge-commands -->
<!-- source: architecture-design.md §Interface View ARCH-009 -->
<!-- source: system-design.md §SYS-006 Algorithm Specification -->

**Module Type**: Pure function (safety-critical)  
**Target Source File**: `src/v_model_extension/guard/hallucination.py` (MOD-013)  
**Invoked by**: ARCH-004 (Stage 6)

---

## Interface Contract

| Direction | Name | Type | Format | Constraints |
|-----------|------|------|--------|-------------|
| Input | `generated_files` | list[(path, content)] | UTF-8 | parsed for `// Implements <ID>` (and language-equivalent) comments |
| Input | `vmodel_id_set` | set[string] | canonical IDs from ARCH-019 | the authoritative ID universe; constructed per the SYS-006 algorithm |
| Output | `VerifyResult` | struct | `{valid: bool, hallucinations: [{file, line, id}]}` | `valid` ⟺ `len(hallucinations) == 0`; `hallucinations[*].file` is absolute path; `line` is 1-indexed; `id` is the verbatim claimed identifier |
| Determinism | (intrinsic) | — | — | pure function; no I/O, no LLM call, no clock, no randomness; same inputs ⟹ same outputs |

## SYS-006 Algorithm

```
regex: (?i)\bImplements\s+([A-Z]+(?:-[A-Z]+)?-[0-9]+(?:[A-Z][0-9]?)?)
vmodel_id_set: union of ALL IDs from ALL V-Model artifact files
               (including [DEPRECATED] and [SUSPECT] entries)
for each (path, content) in generated_files:
    for each regex match in content:
        claimed_id = match.group(1).upper()
        if claimed_id not in vmodel_id_set:
            record hallucination(path, line, claimed_id)
time complexity: O(N·L) where N = files, L = lines per file
```

## Fail-Closed Contract

If `VerifyResult.valid == false`, ARCH-004 MUST abort before Stage 7.
No source files are written. No git commit is produced.
