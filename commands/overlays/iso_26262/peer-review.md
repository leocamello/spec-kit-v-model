# Peer Review — ISO 26262 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iso_26262`.
> It provides domain-specific governing standards overrides and additional review criteria for the base `peer-review` command.

## Governing Standards Override (ISO 26262)

When this overlay is active, the following artifact types use ISO 26262-specific governing standards instead of the base generic standards:

| Artifact File | Abbreviation | Governing Standard (ISO 26262) |
|--------------|-------------|-------------------------------|
| `requirements.md` | REQ | ISO 26262-6 §6.4 (Software Requirements Specification) |
| `acceptance-plan.md` | ATP | ISO 26262-6 §9.4 (Software Testing Strategy) |
| `system-design.md` | SYS | ISO 26262-6 §6.5 (Software Architectural Design) |
| `system-test.md` | STP | ISO 26262-6 §9.4 Table 11 (Software Testing) |
| `architecture-design.md` | ARCH | ISO 26262-6 §6.5 + ISO 26262-9 §5 (ASIL Decomposition) |
| `integration-test.md` | ITP | ISO 26262-6 §6.8 (Software Integration and Integration Testing) |
| `module-design.md` | MOD | ISO 26262-6 §6.7 + §8.4.5 (Software Unit Design and Implementation) |
| `unit-test.md` | UTP | ISO 26262-6 §9.4.4 Table 11 (Software Unit Testing) |
| `hazard-analysis.md` | HAZ | ISO 26262-3 §7 (HARA — Hazard Analysis and Risk Assessment) |

## ASIL Consistency Checks

When reviewing any artifact under ISO 26262, apply these additional checks:

### ASIL Allocation Consistency

For `requirements.md`, `system-design.md`, `architecture-design.md`, `module-design.md`:
- **ASIL Traceability**: Does each ASIL-rated item trace to a parent item with equal or higher ASIL?
- **ASIL Decomposition**: If ASIL decomposition is used (e.g., ASIL D → ASIL B + ASIL B), is it documented in the architecture design with the required independence rationale per ISO 26262-9 §5?
- **QM Items**: Are Quality Management (QM) items clearly distinguished from ASIL-rated items? Are QM items never allowed to compromise ASIL-rated items (FFI — Freedom from Interference)?
- **Derived Requirements**: Are derived safety requirements (not traceable to a parent requirement) explicitly justified in the HARA or safety concept?

### Safety Mechanism Coverage

For `hazard-analysis.md` (HARA):
- **ASIL Severity/Exposure/Controllability**: Are S, E, C parameters justified per ISO 26262-3 §7.4? Is the ASIL determination reproducible from the S×E×C matrix?
- **Mitigation Completeness**: Does every Catastrophic (S3) or Serious (S2) hazard have a safety goal (SG-NNN) and at least one safety requirement mitigating it?
- **Operational States**: Are all relevant operational states (power-up, normal operation, degraded, shutdown) analyzed?
- **Residual Risk**: Is residual risk assessed after mitigation and documented as acceptable?

### Review Rigor by ASIL (ISO 26262-6 Table 1)

Apply the following review rigor based on the ASIL rating of the artifact's primary items:

| ASIL | Review Type | Minimum Reviewers | Independence Required? |
|------|-------------|------------------|------------------------|
| ASIL D | Formal Inspection (Fagan or equivalent) | 3+ | Yes — reviewer must not be the author |
| ASIL C | Structured Walkthrough | 2+ | Recommended |
| ASIL B | Technical Review | 2+ | Optional |
| ASIL A | Informal Review / Desk Check | 1+ | Optional |

**Rules**:
- Flag if a critical (ASIL C–D) artifact was reviewed with insufficient rigor for its ASIL level
- Document the review record: reviewer names, date, review type, finding disposition
- For ASIL D: review report must be traceable in the Safety Case
