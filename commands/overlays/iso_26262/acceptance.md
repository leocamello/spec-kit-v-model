# Acceptance — ISO 26262 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iso_26262`.
> It provides domain-specific safety-critical acceptance testing sections for the base `acceptance` command.

## ASIL-Dependent Verification Methods (Part 6 §6.9, Table 11)

ISO 26262 Part 6 Table 11 specifies verification methods by ASIL level. When generating acceptance tests, apply the appropriate rigor:

| Method | ASIL A | ASIL B | ASIL C | ASIL D |
|---|---|---|---|---|
| Requirements-based testing | ++ | ++ | ++ | ++ |
| Interface testing | + | + | ++ | ++ |
| Fault injection testing | + | + | + | ++ |
| Resource usage evaluation | + | + | + | ++ |
| Back-to-back testing | — | + | + | ++ |

Legend: `++` = highly recommended, `+` = recommended, `—` = optional

- **ASIL D requirements** must have fault injection scenarios in addition to functional test cases.
- **ASIL C/D requirements** should include back-to-back testing scenarios where practical (comparing results from two independent implementations or models).
- Tag test cases with the ASIL level of their parent requirement: e.g., `ATP-001-A [ASIL D]`.

## Safety Mechanism Verification

For requirements tagged with safety mechanisms, generate specific verification scenarios:

- **Detection mechanisms**: Scenarios must verify both correct detection AND correct response to detection (e.g., watchdog triggers → system enters safe state within specified time).
- **Prevention mechanisms**: Scenarios must include attempts to violate the prevented condition (negative testing).
- **Mitigation mechanisms**: Scenarios must verify the degraded mode of operation is safe and meets minimum functionality requirements.

## Temporal Requirements Testing

Automotive systems frequently have hard real-time constraints. For requirements with timing specifications:

- Generate scenarios that verify both the functional outcome AND the timing constraint.
- Include worst-case execution time (WCET) considerations where the requirement specifies timing bounds.
- Scenarios should specify the measurement method for timing validation.
