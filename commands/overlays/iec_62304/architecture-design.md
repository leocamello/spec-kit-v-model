# Architecture Design — IEC 62304 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iec_62304`.
> It provides domain-specific safety-critical architecture sections for the base `architecture-design` command.

## Safety Class Allocation for Software Units

Document the allocation of IEC 62304 safety classes from parent system components (SYS) to child architecture modules (ARCH). The safety class of a software unit is determined by the highest-severity hazard it can contribute to (per IEC 62304 §4.3).

| Parent Component | Parent Safety Class | Child Module | Child Safety Class | Justification |
|------------------|--------------------|--------------|--------------------|---------------|
| SYS-NNN | Class [A/B/C] | ARCH-NNN | Class [A/B/C] | [Why this classification — hazard contribution analysis] |

**Safety Class Allocation Rules (IEC 62304 §4.3)**:
- A child module inherits the parent's safety class unless segregation is demonstrated
- Safety class reduction requires documented segregation per IEC 62304 §5.3.5:
  - Separate memory spaces, separate execution contexts
  - Verified interfaces between segregated components
- Mixed-class architectures must document the segregation mechanisms and their verification

**Rules**:
- Every architecture module must have a safety class assignment
- Class C modules require the most rigorous architecture documentation (IEC 62304 §5.3)
- Segregation boundaries become integration test targets

## Defensive Coding Requirements per Safety Class

Document defensive coding strategies based on safety class assignment. IEC 62304 §5.3 requires that the software architecture addresses error handling and defensive techniques at module boundaries.

| Module | Safety Class | Invalid Input | Detection Method | Recovery Action |
|--------|-------------|---------------|------------------|-----------------|
| ARCH-NNN | Class [A/B/C] | [What could go wrong] | [Input validation / Watchdog / Self-test] | [Error report / Safe state / Alert] |

**Required Techniques by Safety Class**:
- **Class C**: Comprehensive input validation, self-test routines, runtime monitoring, independent error detection
- **Class B**: Input validation, error reporting, defensive checks at module boundaries
- **Class A**: Basic error handling recommended

**Rules**:
- Class C modules: every module boundary must have documented defensive measures
- Class B modules: critical module boundaries must have defensive measures
- Error reporting must integrate with the device's risk control measures per ISO 14971
- Document how detected errors are communicated to the device's alarm/notification system

## IEC 62304 §5.3 Architecture Requirements

Additional architecture design requirements mandated by IEC 62304 §5.3 for safety-classified software.

| Requirement | Class C | Class B | Class A |
|-------------|---------|---------|---------|
| Software architecture documented (§5.3.1) | Required | Required | — |
| Software units identified (§5.3.2) | Required | Required | — |
| Software unit interfaces documented (§5.3.3) | Required | Required | — |
| Functional and performance requirements of units (§5.3.4) | Required | Recommended | — |
| Segregation of safety-critical units (§5.3.5) | Required if mixed-class | Required if mixed-class | — |
| Verify architecture supports requirements (§5.3.6) | Required | Required | — |

**Rules**:
- Class C: all IEC 62304 §5.3 requirements apply without exception
- Class B: most §5.3 requirements apply; documentation depth may be reduced with justification
- Class A: architecture documentation is recommended but not required
- Architecture verification (§5.3.6) must demonstrate that software requirements are implementable within the defined architecture
