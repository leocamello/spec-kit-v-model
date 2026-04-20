# Hazard Analysis — ISO 26262 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iso_26262`.
> It provides domain-specific safety-critical hazard analysis sections for the base `hazard-analysis` command.

## Preferred Severity Scale

Use this ASIL classification **instead of** the base general-purpose severity scale:

| Severity | ASIL Rating | Definition |
|----------|-------------|-----------|
| S3 | ASIL D | Life-threatening (survival uncertain) |
| S3 | ASIL C | Life-threatening (survival probable) |
| S2 | ASIL B | Severe injuries |
| S1 | ASIL A | Light injuries |
| S0 | QM | No injuries |

Use "ASIL Level" terminology throughout the hazard register. Each hazard entry's Severity column should use the ASIL rating (e.g., "ASIL D" not "Catastrophic").

## HARA Methodology (Part 3 §7)

The Hazard Analysis and Risk Assessment (HARA) per ISO 26262 Part 3 §7 classifies hazards using three independent parameters:

- **Severity (S0–S3)**: Estimated potential harm to persons (see table above)
- **Exposure (E1–E4)**: Probability that the operational situation occurs (E1 = Incredible, E4 = High probability)
- **Controllability (C0–C3)**: Ability of the driver/user to control the situation (C0 = Controllable, C3 = Difficult or uncontrollable)

The ASIL is derived from the combination: S × E × C → ASIL (QM, A, B, C, D).

When generating hazard entries, document the S/E/C rationale in the Effect column to justify the ASIL assignment.

## FMEA/FTA Analysis Methods (Part 9 §7)

ISO 26262 Part 9 §7 recommends these safety analysis methods:

- **FMEA (Failure Mode and Effects Analysis)**: Bottom-up analysis from component failure to system effect — the primary method for this command
- **FTA (Fault Tree Analysis)**: Top-down analysis from undesired event to root causes — complements FMEA for complex failure chains
- **FMEDA (Failure Modes, Effects and Diagnostic Analysis)**: Extension of FMEA including diagnostic coverage — for hardware/software interaction hazards

When progressive deepening adds architecture-level hazards, consider whether fault tree analysis would reveal failure chains not visible from FMEA alone.

## Risk Matrix Adaptation

When using the ASIL classification, the Risk Matrix (severity × likelihood) maps to ASIL levels rather than the generic Unacceptable/Undesirable/Tolerable/Acceptable scale. The ASIL level itself determines the required rigor of mitigation verification.

| ASIL Level | Mitigation Verification Rigor |
|------------|------------------------------|
| ASIL D | Full formal verification required; independent verification mandatory |
| ASIL C | Comprehensive testing required; independent review recommended |
| ASIL B | Systematic testing required |
| ASIL A | Standard testing sufficient |
| QM | Quality management processes only |
