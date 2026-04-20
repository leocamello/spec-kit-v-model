# Peer Review — DO-178C Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: do_178c`.
> It provides domain-specific governing standards overrides and additional review criteria for the base `peer-review` command.

## Governing Standards Override (DO-178C)

When this overlay is active, the following artifact types use DO-178C-specific governing standards instead of the base generic standards:

| Artifact File | Abbreviation | Governing Standard (DO-178C) |
|--------------|-------------|------------------------------|
| `requirements.md` | REQ | DO-178C §5.2 (System Requirements Allocated to Software) |
| `acceptance-plan.md` | ATP | DO-178C §6.4 (Software Testing) |
| `system-design.md` | SYS | DO-178C §5.2 (High-Level Requirements) |
| `system-test.md` | STP | DO-178C §6.4 Table A-7 (Normal Range Test Cases) |
| `architecture-design.md` | ARCH | DO-178C §5.2 (Software Architecture) |
| `integration-test.md` | ITP | DO-178C §5.4 Table A-8 (Integration Test Cases) |
| `module-design.md` | MOD | DO-178C §5.3 (Software Design, Low-Level Requirements) |
| `unit-test.md` | UTP | DO-178C §6.4.4 Table A-7 (Structural Coverage — MC/DC for DAL A) |
| `hazard-analysis.md` | HAZ | DO-178C §2.3 (FHA — Functional Hazard Assessment) via ARP 4761 |

## DAL Consistency Checks

When reviewing any artifact under DO-178C, apply these additional checks:

### DAL Assignment Consistency

For `requirements.md`, `system-design.md`, `architecture-design.md`, `module-design.md`:
- **DAL Traceability**: Does the software DAL assignment trace to the system-level FHA (ARP 4761) and PSAC?
- **DAL Independence**: If DAL dissimilarity (partitioning) is used to reduce DAL, is the independence argument documented per DO-178C §2.4.2 and PSAC?
- **Derived Requirements**: Are software-derived requirements (not traceable to system requirements) documented and justified in the PSAC or SDP?
- **Partitioning**: For mixed-DAL software (multiple components at different DALs), are partition boundaries documented and verified to prevent lower-DAL code from compromising higher-DAL code? (DO-178C §2.4.2b)

### Verification Rigor by DAL (DO-178C §6.3)

Apply the following review rigor based on the DAL assignment of the artifact being reviewed:

| DAL | Review Type | Independence Required? | Verification Objective |
|-----|-------------|----------------------|------------------------|
| DAL A | Formal Inspection — Independent Review (DO-178C §6.3.3) | Yes — reviewer independent of author | High-level + Low-level Req review, Structural coverage MC/DC |
| DAL B | Structured Review — Independent Review recommended | Recommended | High-level + Low-level Req review, Structural coverage DC |
| DAL C | Technical Review | Optional | High-level Req review, Structural coverage SC |
| DAL D | Informal Review | Not required | Requirements review |
| DAL E | Not applicable | — | — |

**Rules**:
- Flag if a DAL A artifact review did not maintain reviewer independence from the author
- DO-178C §6.3.1: software requirements are reviewed for accuracy, completeness, verifiability, consistency, and traceability to system requirements
- For certification artifacts: the review record must be traceable to the Software Accomplishment Summary (SAS)

### FHA Coverage (for hazard-analysis.md)

When reviewing `hazard-analysis.md` under DO-178C:
- **FHA Alignment**: Does the hazard analysis align with the system-level FHA (ARP 4761) and PSSA?
- **Failure Condition Classification**: Are failure condition categories (Catastrophic, Hazardous, Major, Minor, No Safety Effect) consistent with ARP 4761 §5?
- **DAL Determination**: Does the software DAL determination follow logically from the system failure condition category?
- **Mitigation Completeness**: Are all Catastrophic and Hazardous failure conditions mitigated by safety requirements in `requirements.md`?
