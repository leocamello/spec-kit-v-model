# Requirements — ISO 26262 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iso_26262`.
> It provides domain-specific safety-critical requirements sections for the base `requirements` command.

## ASIL Allocation (Part 6 §6.4)

When generating requirements, apply Automotive Safety Integrity Level (ASIL) allocation:

- Every safety requirement must include an ASIL tag: `[ASIL A]`, `[ASIL B]`, `[ASIL C]`, or `[ASIL D]`.
- ASIL is inherited from the hazard analysis — if HAZ-NNN is classified as ASIL D, all requirements mitigating that hazard inherit ASIL D unless ASIL decomposition is applied.
- **ASIL decomposition** (Part 9 §5): A requirement at ASIL D may be decomposed into two independent requirements at lower ASIL levels (e.g., ASIL B(D) + ASIL B(D)), provided sufficient independence is demonstrated. Flag decomposed requirements with the decomposition notation.

## Derived Safety Requirements

- Requirements not directly traceable to a system-level safety requirement must be flagged as `[DERIVED]`.
- Derived safety requirements require additional justification — document WHY the requirement exists and what safety concern it addresses.
- Derived requirements must be reviewed by the safety engineer at the human gate.

## Safety Mechanisms

- For each safety requirement, identify the **safety mechanism** type:
  - **Detection**: Mechanism detects a fault (e.g., watchdog timer, CRC check)
  - **Prevention**: Mechanism prevents a fault from occurring (e.g., input validation, range checking)
  - **Mitigation**: Mechanism reduces the impact of a fault (e.g., graceful degradation, safe state transition)
- Tag safety mechanism requirements with the mechanism type: `[MECHANISM: Detection]`, `[MECHANISM: Prevention]`, or `[MECHANISM: Mitigation]`.

## Quality Characteristics (ISO 26262 Supplement)

In addition to the base ISO 25010 quality characteristics, automotive requirements should emphasize:

- **Functional Safety**: Absence of unreasonable risk due to hazards caused by malfunctioning behavior (ISO 26262 Part 1 §1.1)
- **Temporal constraints**: Real-time response requirements with specific timing bounds (e.g., "fault detection within 100ms")
- **Diagnostic coverage**: Requirements for monitoring and diagnostic capabilities
