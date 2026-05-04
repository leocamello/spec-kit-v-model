# Software Architecture Design — IEC 62304 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iec_62304`.
> It provides domain-specific safety-critical architecture sections for the base `software-architecture-design` command.

## Safety Class Allocation

Document the allocation of IEC 62304 safety classes for architecture elements derived from `requirements.md`. The safety class is determined by the highest-severity hazard the element can contribute to (per IEC 62304 §4.3).

> **Note**: This section is a placeholder for future IEC 62304-specific software architecture design guidance. The base IEEE 42010 views (Logical, Process, Interface, Data Flow) are always generated regardless of domain. ASPICE SWE.2 sections are **not** included for IEC 62304 — SWE.2 is specific to ISO 26262.

| Architecture Element | Safety Class | Justification |
|----------------------|-------------|---------------|
| ARCH-NNN | Class [A / B / C] | [Hazard contribution analysis] |

### Safety Class Allocation Rules

- Architecture elements inherit the safety class of the highest-risk requirement they implement
- Safety class reduction requires documented segregation per IEC 62304 §5.3.5
- Class C elements require the most rigorous architecture documentation (§5.3)

## Defensive Coding Requirements per Safety Class

Document defensive coding strategies at architecture element boundaries based on safety class.

| Element | Safety Class | Invalid Input Condition | Detection Method | Recovery Action |
|---------|-------------|------------------------|------------------|-----------------|
| ARCH-NNN | Class [A/B/C] | [Boundary failure mode] | [Check mechanism] | [Safe state transition] |

### Requirements by Safety Class

- **Class C**: Full defensive programming — range checks, plausibility checks, assertion monitoring, redundant computation
- **Class B**: Range checks, plausibility checks
- **Class A**: Basic error handling

## Future Extensions

This overlay is a stub. Future IEC 62304-specific software architecture design guidance may include:

- **Software Unit Verification Strategy**: IEC 62304 §5.5 verification planning per safety class
- **Risk Control Measures**: Architecture-level risk controls per IEC 62304 §5.3.4
- **Integration Testing Requirements**: IEC 62304 §5.6 integration strategy from architecture
- **Change Management**: Architecture impact analysis for software changes per IEC 62304 §5.8
