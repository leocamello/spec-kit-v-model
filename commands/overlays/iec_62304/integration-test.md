# Integration Test — IEC 62304 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iec_62304`.
> It provides domain-specific safety-critical integration test sections for the base `integration-test` command.

## SIL/HIL Testing by Safety Class

Document which integration test scenarios require specific test environments based on the safety class of the modules under test. IEC 62304 §5.6 defines integration testing requirements that vary by safety classification.

| Test ID | Safety Class | Environment | Hardware Dependencies | Stubbed Components | Adaptation Notes |
|---------|-------------|-------------|----------------------|--------------------|--------------------|
| ITP-NNN-X | Class [A/B/C] | SIL / HIL / Target Device | [Physical interfaces required] | [What is simulated] | [How to adapt for target] |

**Safety-Class-dependent Test Environment Requirements**:
- **Class C**: Target device testing required for final verification; HIL testing for integration of hardware-interfacing modules; SIL for early software-only integration
- **Class B**: SIL testing acceptable for software-only modules; HIL or target device recommended for hardware-interfacing modules
- **Class A**: SIL testing sufficient; no specific environment requirements

**Rules**:
- Class C integration tests involving hardware interfaces must be verified on target device or representative HIL
- Document the representativeness of test environments vs. the intended use environment (IEC 62304 §5.6.3)
- For medical devices, consider IEC 60601-1 testing requirements for hardware-software interaction
- Test environment must support the device's intended operating conditions

## IEC 62304 §5.6 Integration Requirements

Additional integration verification activities mandated by IEC 62304 §5.6 for safety-classified software.

| Module Pair | Safety Class | Shared Resource | Integration Concern | Verification Method |
|-------------|-------------|-----------------|---------------------|---------------------|
| ARCH-NNN ↔ ARCH-NNN | Class [A/B/C] | [Memory / CPU / Device I/O / etc.] | [Resource contention / Data integrity / Timing] | [Test / Analysis / Review] |

**Integration Testing Requirements by Safety Class (IEC 62304 §5.6)**:
- **Class C**: Integration testing required (§5.6.5); verify that software units combined correctly implement the software architecture; document all integration anomalies
- **Class B**: Integration testing required (§5.6.5); focus on interfaces between software units
- **Class A**: Integration testing recommended but not required

**Resource Contention Verification**:
- For Class C software: prove that modules sharing resources (memory, CPU, I/O) do not interfere with each other's safety functions
- Document shared resource access patterns and conflict resolution mechanisms
- Verify that real-time constraints are met under worst-case resource contention
- Integration with hardware components must consider IEC 60601-1 essential performance requirements

**Rules**:
- Class C: all integration anomalies must be evaluated for impact on safety per IEC 62304 §9
- Class B: integration anomalies at critical boundaries must be evaluated
- Document regression testing strategy for integration after changes (IEC 62304 §6.2.4)
