# System Test — DO-178C Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: do_178c`.
> It provides domain-specific safety-critical test sections for the base `system-test` command.

## Structural Coverage (DO-178C §6.4.4.2)

Specify structural coverage targets per component based on DAL assignment. DO-178C §6.4.4.2 defines the required structural coverage metrics by Design Assurance Level.

| Component | DAL | Coverage Target | Technique | Rationale |
|-----------|-----|-----------------|-----------|-----------|
| SYS-NNN | DAL A | MC/DC 100% | Modified Condition/Decision Coverage | DO-178C §6.4.4.2 Table A-7 — DAL A requires MC/DC |
| SYS-NNN | DAL B | Decision 100% + MC/DC | Decision Coverage + MC/DC | DO-178C §6.4.4.2 Table A-7 — DAL B requires decision + MC/DC |
| SYS-NNN | DAL C | Decision 100% | Decision Coverage | DO-178C §6.4.4.2 Table A-7 — DAL C requires decision coverage |
| SYS-NNN | DAL D | Statement 100% | Statement Coverage | DO-178C §6.4.4.2 Table A-7 — DAL D requires statement coverage |

**DAL-dependent Coverage Requirements (DO-178C Table A-7)**:
- **DAL A**: MC/DC — each condition independently shown to affect the decision outcome
- **DAL B**: Decision coverage + MC/DC
- **DAL C**: Decision coverage (every branch taken)
- **DAL D**: Statement coverage (every statement executed)
- **DAL E**: No structural coverage required

**Rules**:
- Coverage targets derive from the DAL assignment in the system design
- Coverage shortfalls require a Problem Report and DER/AR approval
- Dead code must be identified and either removed or justified
- Deactivated code requires coverage analysis per DO-178C §6.4.4.3

## Resource Usage Testing (DO-178C §6.3.4)

Verify resource usage against safety budgets. DO-178C §6.3.4 requires verification of resource usage for all DAL A–C software.

| Component | DAL | Resource | Measurement | Threshold | Verification Method |
|-----------|-----|----------|-------------|-----------|---------------------|
| SYS-NNN | DAL [A–E] | WCET | [metric] | [max time] | [Static analysis / Instrumented measurement] |
| SYS-NNN | DAL [A–E] | Max Stack Depth | [metric] | [max bytes] | [Static analysis] |
| SYS-NNN | DAL [A–E] | CPU Margin | [metric] | [min % free] | [Load testing] |

**Rules**:
- WCET (Worst Case Execution Time) verification required for all DAL A–C components
- Stack depth analysis required — no dynamic allocation for DAL A–B software
- CPU margin must demonstrate sufficient headroom (typically ≥ 20% for DAL A)
- Resource budgets must be traceable to timing requirements in the system design
- DAL A: both static analysis and measurement confirmation required
- DAL B–C: measurement confirmation sufficient with justified analysis

## Requirements-Based Testing and Table A-8 Verification (DO-178C §6.4, Table A-7/A-8)

In addition to structural coverage, DO-178C requires requirements-based testing. Table A-7 defines software verification objectives, and Table A-8 defines integration process verification objectives. Both apply to system-level testing.

| Objective Category | DAL A | DAL B | DAL C | DAL D |
|--------------------|-------|-------|-------|-------|
| Test cases based on requirements (Table A-7) | ✓ | ✓ | ✓ | ✓ |
| Test cases based on robustness (Table A-7) | ✓ | ✓ | ✓ | — |
| Test coverage of requirements (Table A-7) | ✓ | ✓ | ✓ | ✓ |
| Integration test results correct (Table A-8) | ✓ | ✓ | ✓ | ✓ |
| Integration test coverage of requirements (Table A-8) | ✓ | ✓ | ✓ | — |

**Rules**:
- Every system test must trace to at least one high-level requirement
- DAL A–B: both requirements-based and robustness test cases required
- Coverage shortfalls against Table A-7/A-8 objectives require Problem Reports
- Test results must be documented as verification evidence (DO-178C §11 data items)
