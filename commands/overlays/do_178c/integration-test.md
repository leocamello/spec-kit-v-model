# Integration Test — DO-178C Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: do_178c`.
> It provides domain-specific safety-critical integration test sections for the base `integration-test` command.

## SIL/HIL Compatibility (DO-178C §6.4)

Document which integration test scenarios can execute in Software-in-the-Loop (SIL) vs. Hardware-in-the-Loop (HIL) environments. DO-178C §6.4 defines software integration testing requirements, including the test environment fidelity needed at each DAL.

| Test ID | DAL | Environment | Hardware Dependencies | Stubbed Components | Adaptation Notes |
|---------|-----|-------------|----------------------|--------------------|--------------------|
| ITP-NNN-X | DAL [A–E] | SIL / HIL / Target | [Physical interfaces required] | [What is simulated] | [How to adapt for target] |

**DAL-dependent Test Environment Requirements**:
- **DAL A**: Target hardware testing required for final verification; HIL testing for integration; SIL for early development only
- **DAL B**: HIL testing required for hardware-interfacing modules; SIL acceptable for pure software modules
- **DAL C**: SIL testing acceptable with documented representativeness; HIL recommended for hardware interfaces
- **DAL D–E**: SIL testing sufficient

**Rules**:
- DAL A–B integration tests must document the representativeness of the test environment vs. target hardware
- Software/hardware integration testing (DO-178C §6.4.1) must be performed on target or equivalent hardware for DAL A–B
- Document all physical interfaces that are stubbed and justify why the stub is representative
- Test environment qualification per DO-330 (Software Tool Qualification) for tool confidence

## Resource Contention (DO-178C §6.3.3)

Prove that modules do not exhaust shared resources during interaction. DO-178C §6.3.3 addresses partitioning and resource management for safety-critical avionics software.

| Module Pair | DAL | Shared Resource | Contention Scenario | Expected Resolution |
|-------------|-----|-----------------|---------------------|---------------------|
| ARCH-NNN ↔ ARCH-NNN | DAL [A–E] | [Memory / CPU / Bus / ARINC 429 / etc.] | [How contention occurs] | [Partitioning / Health monitoring / Budget enforcement] |

**Partitioning Requirements**:
- Robust partitioning (ARINC 653) eliminates resource contention by design — document partition boundaries
- For non-partitioned architectures, demonstrate resource isolation through analysis and test
- Health monitoring must detect and report resource overruns

**Rules**:
- DAL A–B module pairs: must demonstrate robust partitioning or equivalent resource isolation
- DAL C module pairs: resource contention analysis required; mitigation documented
- Resource types to verify: CPU time partitions, memory partitions, I/O device access, communication bus bandwidth
- Inter-partition communication must use validated ports/channels (no direct memory sharing for DAL A–B)
- Document ARINC 653 health monitoring responses for resource budget violations
