# ARCH-017: Quality Compliance Harness

<!-- v-model-enrichment: feature=007-bridge-commands -->
<!-- source: architecture-design.md §Interface View ARCH-017 -->

**Module Type**: CI quality gate  
**Target Source File**: `src/v_model_extension/shared/compliance_harness.py` (MOD-022)  
**Invoked by**: CI pipeline merge gate

---

## Interface Contract

| Direction | Name | Type | Format | Constraints |
|-----------|------|------|--------|-------------|
| Input | `feature_dir` | path | absolute path | |
| Output | `CoverageReport` | struct | `{bats: pct, pester: pct, structural_eval: pct, llm_eval: pct, merge_gate: "allow"\|"block"}` | `merge_gate == "allow"` ⟺ every harness reports 100% |
| Output | `AuditReport` | struct | `{deferred_capability_violations: [], dogfood_discipline_ok: bool}` | for REQ-CN-003 / REQ-CN-004 audit |
| Exception | `SubprocessFailure` | from ARCH-020 | text + harness name + exit code | propagated to caller; `merge_gate` left undefined when raised — caller MUST treat as `merge_gate: "block"` |
