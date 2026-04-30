# ARCH-013: Spec-Kit Schema Validator

<!-- v-model-enrichment: feature=007-bridge-commands -->
<!-- source: architecture-design.md §Interface View ARCH-013 -->

**Module Type**: Validator (fail-closed)  
**Target Source File**: `src/v_model_extension/shared/schema_validator.py` (MOD-017)  
**Invoked by**: ARCH-001 (after enrichment), ARCH-003 (after enrichment)

---

## Interface Contract

| Direction | Name | Type | Format | Constraints |
|-----------|------|------|--------|-------------|
| Input | `doc` | string | canonical Markdown | schema selected by call site (`validate_plan_schema` or `validate_tasks_schema`) |
| Output | `ValidationResult` | struct | `{valid: bool, errors: [{section, line, message}]}` | strict against the pinned spec-kit-core schema |
| Output | `pinned_version` | string | semver | reported in run summary |
| Exception | `SchemaValidationError` | raised | text + section + line | wraps `ValidationResult` when callers prefer exception-style flow; carries the same error list |

## Fail-Closed Contract

ARCH-013 MUST NEVER attempt to mutate, repair, or downgrade `doc`.
Callers MUST abort on any non-`valid` result and MUST NOT invoke
ARCH-002 / ARCH-021 to write a non-conformant artifact.

The reduced-enrichment fallback (ARCH-014) is a SEPARATE upstream-document
path and does NOT bypass ARCH-013 on the output side.
