# Peer Review — IEC 62304 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iec_62304`.
> It provides domain-specific governing standards overrides and additional review criteria for the base `peer-review` command.

## Governing Standards Override (IEC 62304)

When this overlay is active, the following artifact types use IEC 62304-specific governing standards instead of the base generic standards:

| Artifact File | Abbreviation | Governing Standard (IEC 62304) |
|--------------|-------------|-------------------------------|
| `requirements.md` | REQ | IEC 62304 §5.2 (Software Requirements) |
| `acceptance-plan.md` | ATP | IEC 62304 §5.7 (Software System Testing) |
| `system-design.md` | SYS | IEC 62304 §5.3 (Software Architectural Design) |
| `system-test.md` | STP | IEC 62304 §5.7 (System Testing per Safety Class) |
| `architecture-design.md` | ARCH | IEC 62304 §5.3 (Software Architecture) |
| `integration-test.md` | ITP | IEC 62304 §5.6 (Software Integration and Integration Testing) |
| `module-design.md` | MOD | IEC 62304 §5.4 + §5.5 (Detailed Design and Unit Implementation) |
| `unit-test.md` | UTP | IEC 62304 §5.5 (Software Unit Verification) |
| `hazard-analysis.md` | HAZ | ISO 14971 §4–5 (Hazard Identification and Risk Estimation) + IEC 62304 §4.3 |

## Safety Class Consistency Checks

When reviewing any artifact under IEC 62304, apply these additional checks:

### Safety Class Assignment and Traceability

For `requirements.md`, `system-design.md`, `architecture-design.md`, `module-design.md`:
- **Safety Class Traceability**: Does the software item safety class assignment trace to the ISO 14971 risk analysis and IEC 62304 §4.3 classification procedure?
- **Class Propagation**: Are software items correctly classified? (IEC 62304 §4.3: if any part contributes to a hazard, the classification must reflect the highest risk)
- **Risk Control Traceability**: For Class B–C items, are risk control measures from the ISO 14971 risk management file traceable to requirements and design elements?
- **Legacy Software (SOUP)**: Are all third-party and open-source components (SOUP — Software of Unknown Provenance) identified per IEC 62304 §8.1? Is each SOUP item's suitability documented?

### Independent Review by Safety Class (IEC 62304 §5.5.3)

Apply the following review rigor based on the safety class of the artifact's primary items:

| Safety Class | Review Type | Independence Required? | IEC 62304 Reference |
|-------------|-------------|----------------------|---------------------|
| Class C | Formal Technical Review — Independent | Yes — reviewer must not be the software developer | §5.5.3(c) |
| Class B | Technical Review | Recommended | §5.5.3 |
| Class A | Informal Review / Self-review | Not required | §5.5.3 |

**Rules**:
- Flag if a Class C artifact review did not maintain reviewer independence per IEC 62304 §5.5.3(c)
- The review record must be part of the Software Development Plan (SDP) documented evidence
- For audits (IEC 62304 §8): review evidence must be available to demonstrate process compliance

### Hazard Analysis Coverage (for hazard-analysis.md)

When reviewing `hazard-analysis.md` under IEC 62304:
- **ISO 14971 Alignment**: Does the hazard analysis follow ISO 14971 §4 (intended use, hazard identification) and §5 (risk estimation)?
- **Safety Class Impact**: Does each hazard correctly inform the software safety class determination per IEC 62304 §4.3?
- **Risk Control Implementation**: For all unacceptable risks (ISO 14971 §6.1), are risk control measures implemented in software requirements and traceable to `requirements.md`?
- **Residual Risk**: Is the overall residual risk acceptable per ISO 14971 §7 (risk/benefit analysis)?
- **Class C Completeness**: For software classified as Class C, are all relevant failure modes (including software errors) analyzed in the hazard analysis?
