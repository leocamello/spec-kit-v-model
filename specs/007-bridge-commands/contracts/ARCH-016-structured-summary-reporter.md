# ARCH-016: Structured Summary Reporter

<!-- v-model-enrichment: feature=007-bridge-commands -->
<!-- source: architecture-design.md §Interface View ARCH-016 -->

**Module Type**: Output reporter  
**Target Source File**: `src/v_model_extension/shared/summary_reporter.py` (MOD-021)  
**Invoked by**: ARCH-001, ARCH-003, ARCH-004 (always, even on failure)

---

## Interface Contract

| Direction | Name | Type | Format | Constraints |
|-----------|------|------|--------|-------------|
| Input | `run_result` | struct | `{inputs_read[], outputs_produced[], artifacts_skipped[], warnings[], fatal_errors[]}` | |
| Output | stdout text | text | `v-model.test-results` / `v-model.audit-report` summary grammar | always emitted, even on failure |

## Notes

ARCH-016 is always invoked — including on fatal-error exits — so that CI
tooling always has structured output to capture. The `fatal_errors` list
distinguishes a failure run from a success run.
