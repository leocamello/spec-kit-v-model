# ISO 26262 — Trace Command Overlay

## Regulatory References

- **ISO 26262 Part 6, Clause 9**: Verification of software safety requirements through traceability to test cases. Requires bidirectional traceability between safety requirements and verification activities at each V-Model level.
- **ISO 26262 Part 8, Clause 6**: Configuration management — traceability of work products across the safety lifecycle. Requires that all safety-related work products are linked and that changes propagate through the traceability chain.

## Compliance Interpretation

When presenting traceability results:

- **ASIL coverage**: Report coverage per ASIL level (ASIL A through ASIL D). Higher ASIL levels require stricter coverage — ASIL D requirements with missing test coverage are flagged as critical gaps.
- **Safety requirements emphasis**: Safety requirements (`REQ-NF-*` tagged with ASIL) must be highlighted in the coverage audit. Any untested safety requirement is a compliance finding.
- **Bidirectional verification**: Both forward traceability (requirement → test) and backward traceability (test → requirement) must be validated. Orphan tests (tests not linked to any requirement) should be flagged.
- **Hazard traceability (Matrix H)**: Verify that every HAZ-NNN entry traces to at least one safety requirement and one mitigation verification test.
