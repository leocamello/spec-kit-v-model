# Trace — IEC 62304 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iec_62304`.
> It provides domain-specific safety-critical traceability sections for the base `trace` command.

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

## Safety Class–Dependent Traceability Depth

| Safety Class | Traceability Chain | Verification Coverage | Risk Control Traceability | Independent Review |
|-------------|-------------------|----------------------|--------------------------|-------------------|
| Class C | SYS → REQ → ARCH → MOD → Code → Test (all levels) | 100% of requirements | Mandatory — every risk control to verification | Required |
| Class B | SYS → REQ → ARCH → Test | 100% of requirements | Mandatory — risk controls to verification | Recommended |
| Class A | SYS → REQ (minimal) | Recommended | Not required | Not required |

**Rules**:
- Class C: complete bidirectional traceability required — every requirement must trace to design, implementation, and verification
- Class B: forward traceability required; backward traceability recommended
- Class A: basic traceability recommended but not mandatory
- Risk control measures (from ISO 14971) must trace from hazard → requirement → verification for Class B and C
- SOUP components must trace to evaluation evidence (§7.1.3 anomaly list review)

## Traceability Gap Analysis

When the trace command identifies gaps, classify them by regulatory impact:

| Gap Type | Class C Impact | Class B Impact | Class A Impact |
|----------|---------------|----------------|----------------|
| Requirement → no test | **Blocks submission** | Must resolve | Informational |
| Risk control → no verification | **Blocks submission** | **Blocks submission** | N/A |
| Test → no requirement (orphan) | Regulatory concern | Documentation cleanup | Informational |
| Deprecated REQ → no successor | **Blocks submission** | Must resolve | Informational |
| SOUP REQ → no evaluation | **Blocks submission** | Must resolve | N/A |
| Hazard → no risk control REQ | **Blocks submission** | **Blocks submission** | N/A |

**Regulatory Submission Notes**:
- FDA reviewers expect a complete requirements traceability matrix (RTM) as part of the 510(k) or PMA submission
- EU MDR Technical Documentation requires traceability evidence per Annex II §4
- Any gap flagged as "Blocks submission" must be resolved before the regulatory filing
