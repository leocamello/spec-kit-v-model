# IEC 62304 — Trace Command Overlay

## Regulatory References

- **IEC 62304 Clause 5.7**: Software verification — requires traceability of software requirements to verification activities. Each software requirement must be verified through appropriate test activities at the correct level.
- **IEC 62304 Clause 8**: Software configuration management — requires traceability of all software items and their relationships throughout the lifecycle.
- **FDA 21 CFR Part 820 §820.30(i)**: Design validation — "Design validation shall ensure that devices conform to defined user needs and intended uses." This requires end-to-end traceability from user needs through design outputs to validation results.

## Compliance Interpretation

When presenting traceability results:

- **Safety class rigor**: Report coverage by IEC 62304 Safety Class (A, B, C). Class C software requires the most rigorous traceability — every requirement must trace to a verification activity.
- **Risk control traceability**: Requirements that implement risk control measures (from ISO 14971 risk analysis) must have explicit traceability to verification activities that confirm the control measure is effective.
- **SOUP traceability**: If the system uses Software of Unknown Provenance (SOUP), verify that SOUP-related requirements trace to appropriate verification activities (anomaly lists, performance requirements per §5.3.3).
- **Regulatory submission**: The traceability matrix is a required submission artifact for FDA 510(k) and PMA submissions. Flag any gaps as regulatory submission risks.
