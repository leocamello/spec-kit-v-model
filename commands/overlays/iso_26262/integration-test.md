# Integration Test — ISO 26262 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iso_26262`.
> It provides domain-specific safety-critical integration test sections for the base `integration-test` command.

## SIL/HIL Compatibility (ISO 26262 Part 6 §6.8)

Document which integration test scenarios can execute in Software-in-the-Loop (SIL) vs. Hardware-in-the-Loop (HIL) environments. ISO 26262 Part 6 §6.8 defines requirements for software integration and integration testing in safety-critical verification.

| Test ID | ASIL Rating | Environment | Hardware Dependencies | Stubbed Components | Adaptation Notes |
|---------|-------------|-------------|----------------------|--------------------|--------------------|
| ITP-NNN-X | ASIL [A–D] | SIL / HIL | [Physical interfaces required] | [What is simulated] | [How to adapt for target] |

**ASIL-dependent Test Environment Requirements**:
- **ASIL D**: HIL testing mandatory for all hardware-interfacing modules; SIL testing for pure software modules with justified back-to-back comparison
- **ASIL C**: HIL testing recommended for hardware-interfacing modules; SIL testing acceptable with coverage justification
- **ASIL B**: SIL testing acceptable; HIL testing recommended for critical interfaces
- **ASIL A**: SIL testing sufficient

**Rules**:
- Every ASIL C–D integration test must document its SIL/HIL target environment
- Document all physical interfaces that are stubbed in SIL mode
- Back-to-back testing (SIL vs. HIL) recommended for ASIL D to demonstrate SIL fidelity
- Test environment qualification per ISO 26262-8 §11 for tool confidence

## Resource Contention (ISO 26262-6 §7.4.11)

Prove that modules do not exhaust shared resources during interaction. ISO 26262-6 §7.4.11 addresses resource usage verification for safety-critical components.

| Module Pair | ASIL Rating | Shared Resource | Contention Scenario | Expected Resolution |
|-------------|-------------|-----------------|---------------------|---------------------|
| ARCH-NNN ↔ ARCH-NNN | ASIL [A–D] | [Memory / CPU / Bus / Interrupt / etc.] | [How contention occurs between modules] | [Priority inheritance / Partitioning / Budget enforcement] |

**Rules**:
- Document all shared resources between ASIL-rated module pairs
- Resource types to verify: shared memory, CPU time, bus bandwidth, interrupt lines, I/O channels, stack space
- ASIL D module pairs: must demonstrate no unbounded priority inversion and no resource starvation
- ASIL C module pairs: contention analysis required; enforcement mechanism must be documented
- ASIL B module pairs: contention scenarios documented; resolution mechanism identified
- Reference the FFI (Freedom from Interference) analysis from the system design overlay for resource isolation boundaries
