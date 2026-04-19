# Trace — ISO 26262 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iso_26262`.
> It provides domain-specific safety-critical traceability sections for the base `trace` command.

## Regulatory References

- **ISO 26262 Part 6, Clause 9**: Verification of software safety requirements through traceability to test cases. Requires bidirectional traceability between safety requirements and verification activities at each V-Model level.
- **ISO 26262 Part 8, Clause 6**: Configuration management — traceability of work products across the safety lifecycle. Requires that all safety-related work products are linked and that changes propagate through the traceability chain.

## Compliance Interpretation

When presenting traceability results:

- **ASIL coverage**: Report coverage per ASIL level (ASIL A through ASIL D). Higher ASIL levels require stricter coverage — ASIL D requirements with missing test coverage are flagged as critical gaps.
- **Safety requirements emphasis**: Safety requirements (`REQ-NF-*` tagged with ASIL) must be highlighted in the coverage audit. Any untested safety requirement is a compliance finding.
- **Bidirectional verification**: Both forward traceability (requirement → test) and backward traceability (test → requirement) must be validated. Orphan tests (tests not linked to any requirement) should be flagged.
- **Hazard traceability (Matrix H)**: Verify that every HAZ-NNN entry traces to at least one safety requirement and one mitigation verification test.

## ASIL-Dependent Traceability Depth

| ASIL Level | Traceability Chain | Coverage Required | Independence |
|------------|-------------------|-------------------|--------------|
| ASIL D | Full bidirectional: SYS → REQ → ARCH → MOD → Code → Test | 100% of safety requirements | Independent review of traceability |
| ASIL C | Full bidirectional: SYS → REQ → ARCH → MOD → Test | 100% of safety requirements | Review recommended |
| ASIL B | Forward traceability required; backward recommended | 100% of safety requirements | Self-review acceptable |
| ASIL A | Forward traceability required | 100% of safety requirements | Self-review acceptable |

**Rules**:
- ASIL D: every safety requirement must trace through all V-Model levels to implementation and verification — any gap is a compliance finding
- ASIL C–D: traceability data must be independently reviewed per Part 6 Clause 9
- All ASIL levels: deprecated requirements must trace to their superseding requirement; orphan deprecations are flagged
- Safety mechanisms from the system design must trace to verification evidence in system test and integration test

## Traceability Gap Analysis

When the trace command identifies gaps, classify them by severity:

| Gap Type | Severity | ASIL D Impact | ASIL A–C Impact |
|----------|----------|---------------|-----------------|
| Safety requirement → no test | **Critical** | Blocks release | Must be resolved before verification gate |
| Test → no requirement (orphan test) | **Warning** | Certification concern | Documentation cleanup |
| Deprecated REQ → no successor | **Critical** | Blocks release | Blocks release |
| Hazard → no safety requirement | **Critical** | Blocks release | Blocks release |
| Design element → no requirement | **Warning** | Derived requirement review needed | Documentation cleanup |
