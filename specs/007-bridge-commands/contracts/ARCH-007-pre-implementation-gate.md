# ARCH-007: Pre-Implementation Gate Coordinator

<!-- v-model-enrichment: feature=007-bridge-commands -->
<!-- source: architecture-design.md §Interface View ARCH-007 -->

**Module Type**: Safety gate (read-only)  
**Target Source File**: `src/v_model_extension/implement/gate.py` (MOD-010)  
**Invoked by**: ARCH-004 (Stage 2)

---

## Interface Contract

| Direction | Name | Type | Format | Constraints |
|-----------|------|------|--------|-------------|
| Input | `feature_dir` | path | absolute path | |
| Output | `GateResult` | struct | `{passed: bool, gap_report: str, matrices: {A,B,C,D,H: {pct: float, gaps: [...]}}}` | `passed == true` ⟺ every matrix is 100% complete |
| Side-effect | (none) | — | — | strictly read-only against the feature directory |
| Exception | `SubprocessFailure` | from ARCH-020 | text + exit code | propagated as `{passed: false}` (fail-closed) |

## Determinism Contract

ARCH-007 composes the existing deterministic gate scripts:
`build-matrix.sh`, `validate-requirement-coverage`,
`validate-system-coverage`, `validate-architecture-coverage`,
`validate-integration-coverage`, `validate-module-coverage`.

No new wrapper scripts are introduced (REQ-017 / REQ-CN-002).

## Key Acceptance Scenario

- SCN-017-A1: process trace records only the existing scripts; no others
