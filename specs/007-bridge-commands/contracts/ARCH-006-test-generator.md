# ARCH-006: Test Generator

<!-- v-model-enrichment: feature=007-bridge-commands -->
<!-- source: architecture-design.md §Interface View ARCH-006 -->

**Module Type**: Pure transform  
**Target Source File**: `src/v_model_extension/implement/test_generator.py` (MOD-008 / MOD-009)  
**Invoked by**: ARCH-004 (Stage 4, parallel to ARCH-005)

---

## Interface Contract

| Direction | Name | Type | Format | Constraints |
|-----------|------|------|--------|-------------|
| Input | `generation_plan` | struct | as ARCH-005, also requires test-plan artifacts | `unit-test.md`, `integration-test.md`, `system-test.md`, `acceptance-plan.md` |
| Output | `test_set` | list[(path, content)] | absolute paths + UTF-8 content | covers unit / integration / system / acceptance levels |
| Exception | `MalformedTestPlan` | raised | text + artifact path + line | when an input test-plan artifact cannot be parsed or omits a mandatory field; propagated to ARCH-004 fail-closed |
| Exception | `IOError` | from ARCH-021 | text + path | raised by ARCH-021 in Stage 7; ARCH-006 itself never writes to disk |

## Notes

Like ARCH-005, ARCH-006 is a **pure transform**. It returns `(path, content)`
tuples; disk writes are performed by ARCH-021 after ARCH-009 verification.
