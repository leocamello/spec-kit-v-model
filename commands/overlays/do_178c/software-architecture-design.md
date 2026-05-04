# Software Architecture Design — DO-178C Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: do_178c`.
> It provides domain-specific safety-critical architecture sections for the base `software-architecture-design` command.

## DAL Allocation

Document the allocation of Design Assurance Levels (DAL) for architecture elements derived from `requirements.md`. DAL allocation must demonstrate independence arguments per DO-178C §6.3.3f.

> **Note**: This section is a placeholder for future DO-178C-specific software architecture design guidance. The base IEEE 42010 views (Logical, Process, Interface, Data Flow) are always generated regardless of domain. ASPICE SWE.2 sections are **not** included for DO-178C — SWE.2 is specific to ISO 26262.

| Architecture Element | DAL | Justification |
|----------------------|-----|---------------|
| ARCH-NNN | DAL [A–E] | [Contribution to safety-critical function] |

### DAL Allocation Rules

- Architecture elements inherit the DAL of the highest-level requirement they satisfy
- DAL reduction requires robust partitioning demonstrated per DO-178C §6.3.3f
- Mixed-DAL architectures must document independence arguments

## Temporal & Execution Constraints

Document execution order, watchdog timers, and deadlock prevention for safety-critical architecture elements.

| Element | Constraint Type | Value | Enforcement |
|---------|----------------|-------|-------------|
| ARCH-NNN | [Execution order / Deadline / Watchdog] | [Specification] | [Mechanism] |

## Future Extensions

This overlay is a stub. Future DO-178C-specific software architecture design guidance may include:

- **Partitioning Analysis**: ARINC 653 or equivalent robust partitioning verification
- **Control Flow Integrity**: DO-178C §6.3.3a requirements for deterministic execution paths
- **Data Coupling Analysis**: Compliance with DO-178C Table A-4 objective 6
- **Architecture Verification**: DO-178C §6.3.4 traceability from architecture to high-level requirements
