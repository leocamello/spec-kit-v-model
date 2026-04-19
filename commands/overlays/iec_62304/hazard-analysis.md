# Hazard Analysis — IEC 62304 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iec_62304`.
> It provides domain-specific safety-critical hazard analysis sections for the base `hazard-analysis` command.

## Preferred Severity Scale

Use this IEC 62304 software safety classification **instead of** the base general-purpose severity scale:

| Safety Class | Definition | Lifecycle Rigor |
|-------------|-----------|-----------------|
| Class C | Death or serious injury possible | Full lifecycle documentation and verification required |
| Class B | Non-serious injury possible | Verification and testing required; some documentation may be reduced |
| Class A | No injury or damage to health possible | Basic development process sufficient |

Use "Safety Class" terminology throughout the hazard register. Each hazard entry's Severity column should use the safety classification (e.g., "Class C" not "Catastrophic").

> **Note**: IEC 62304 software safety classification is derived from the risk management process (ISO 14971). The classification determines the rigor of the entire software development lifecycle — making hazard analysis a prerequisite for all downstream engineering decisions.

## ISO 14971 Integration (§7)

IEC 62304 requires that software safety classification be based on hazard analysis performed per ISO 14971. The integration points are:

1. **Hazard identification** (ISO 14971 §5.4): Identify hazards associated with the medical device, including those caused by software faults
2. **Risk estimation** (ISO 14971 §5.5): Estimate the probability of occurrence and severity of harm for each hazard
3. **Risk evaluation** (ISO 14971 §6): Compare estimated risk against acceptability criteria
4. **Risk control** (ISO 14971 §7): Implement risk control measures and verify their effectiveness

For each hazard entry, the Mitigation column should reference the risk control measure type per ISO 14971 §7.1:
- **Inherent safety by design**: Eliminating the hazard (preferred)
- **Protective measures**: Adding safeguards in the device or manufacturing process
- **Information for safety**: Providing warnings, instructions, or training

## Software Safety Classification Derivation

The software safety class is determined by the **highest severity hazard** that the software item can contribute to:

| If software can contribute to... | Then software safety class is... |
|----------------------------------|----------------------------------|
| A hazard resulting in death or serious injury | **Class C** |
| A hazard resulting in non-serious injury | **Class B** |
| No hazard, or hazard with no injury potential | **Class A** |

When generating the Coverage Summary, include a "Software Safety Classification" row that states the overall classification based on the highest-severity hazard in the register.

## Risk Control Measures (IEC 62304 §7)

For each hazard with Class B or Class C severity:
- The Mitigation column must reference specific software requirements (`REQ-NNN`) that implement the risk control measure
- Document whether the risk control measure is a **software safety requirement** (SSR) — requirements that directly control an identified risk
- Software safety requirements inherit the safety class of the hazard they mitigate
