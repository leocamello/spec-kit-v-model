# Hazard Analysis — DO-178C Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: do_178c`.
> It provides domain-specific safety-critical hazard analysis sections for the base `hazard-analysis` command.

## Preferred Severity Scale

Use this DAL failure condition classification **instead of** the base general-purpose severity scale:

| Failure Condition | DAL | Definition |
|-------------------|-----|-----------|
| Catastrophic | A | Prevents continued safe flight and landing |
| Hazardous | B | Large reduction in safety margins or physical distress |
| Major | C | Significant reduction in safety margins or workload increase |
| Minor | D | Slight reduction in safety margins or slight increase in workload |
| No Effect | E | No effect on operational capability or pilot workload |

Use "DAL" (Design Assurance Level) terminology throughout the hazard register. Each hazard entry's Severity column should use the failure condition category (e.g., "Catastrophic (DAL A)" not just "Catastrophic").

## Functional Hazard Assessment (ARP 4761)

The hazard analysis follows the Functional Hazard Assessment (FHA) methodology defined in ARP 4761:

- **System FHA**: Identifies failure conditions at the aircraft/system function level and classifies their severity
- **Subsystem FHA**: Refines system-level failure conditions into subsystem-level failure modes — aligns with progressive deepening at the architecture level

For each identified failure condition:
1. Document the **aircraft-level effect** (not just the software-level effect)
2. Classify severity per the failure condition categories above
3. Identify whether the failure is **detectable** by the flight crew
4. Document the **phase of flight** most affected (maps to operational states)

## Safety Assessment per DO-178C §5.1

DO-178C §5.1 requires that the safety assessment process:

- Identifies **all failure conditions** that could affect aircraft safety
- Classifies each failure condition by its effect on the aircraft and occupants
- For **DAL A (Catastrophic)** failure conditions: at least two independent mitigations are required — document both in the Mitigation column
- For **DAL B (Hazardous)** failure conditions: independence between detection and mitigation mechanisms should be demonstrated

## Independence Requirements

| DAL | Independence Requirement |
|-----|------------------------|
| A | Dual independent mitigations required; independent verification of each |
| B | Independence between detection and mitigation recommended |
| C | Standard mitigation sufficient |
| D–E | No specific independence requirements |

When generating hazard entries at DAL A, the Mitigation column must reference **at least two independent** `REQ-NNN` or `SYS-NNN` identifiers.
