# Requirements — DO-178C Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: do_178c`.
> It provides domain-specific safety-critical requirements sections for the base `requirements` command.

## DAL Traceability (§5.2.1, Table A-4)

When generating requirements, apply Design Assurance Level (DAL) traceability:

- Every requirement must be traceable to a system-level requirement allocated to software.
- DAL is inherited from the system safety assessment — requirements inherit the DAL of the function they implement.
- DAL levels: **DAL A** (Catastrophic), **DAL B** (Hazardous), **DAL C** (Major), **DAL D** (Minor), **DAL E** (No Effect).
- Higher DAL levels require more rigorous requirements — DAL A requires formal methods or equivalent rigor per Table A-4.

## Derived Requirements (§5.2.1)

- Requirements that do not trace directly to system requirements must be flagged as `[DERIVED]`.
- Derived requirements are a **certification concern** — they must be communicated to the system safety assessment process.
- Each derived requirement must include justification: what design decision introduced it and why it is necessary.
- The certification liaison must be notified of all derived requirements (DO-178C §10.2.1).

## Requirement Accuracy and Consistency (Table A-4 Objectives)

DO-178C Table A-4 defines verification objectives for high-level requirements:

| Objective | DAL A | DAL B | DAL C | DAL D |
|---|---|---|---|---|
| High-level requirements comply with system requirements | ✓ | ✓ | ✓ | ✓ |
| High-level requirements are accurate and consistent | ✓ | ✓ | ✓ | ✓ |
| High-level requirements are compatible with target computer | ✓ | ✓ | ✓ | — |
| High-level requirements are verifiable | ✓ | ✓ | ✓ | ✓ |
| High-level requirements conform to standards | ✓ | ✓ | ✓ | — |
| High-level requirements are traceable to system requirements | ✓ | ✓ | ✓ | ✓ |
| Algorithms are accurate | ✓ | ✓ | — | — |

Apply these objectives during requirements validation (Step 6) based on the applicable DAL.

## Partitioning Requirements

- If the system uses software partitioning (ARINC 653 or equivalent), each partition boundary must be captured as an interface requirement (`REQ-IF-NNN`).
- Partition requirements must specify both the protection mechanism and the expected behavior under partition violation.

## Bidirectional Traceability (§6.3.4)

DO-178C §6.3.4 mandates bidirectional traceability for DAL A–C software. When generating requirements, ensure the traceability chain supports both directions:

- **Forward traceability**: Each requirement must be traceable to at least one verification activity (test case, analysis, or review).
- **Backward traceability**: Each verification activity must trace back to at least one requirement — orphan tests are a certification concern.
- Requirements flagged as `[DERIVED]` must additionally trace to the design decision that introduced them.
- Bidirectional traceability data is reviewed as part of the verification process (Table A-9 objectives).
