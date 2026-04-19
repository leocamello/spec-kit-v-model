# System Test — ISO 26262 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iso_26262`.
> It provides domain-specific safety-critical test sections for the base `system-test` command.

## Structural Coverage (ISO 26262-6 §9.4.5)

Specify structural coverage targets per component based on ASIL rating. ISO 26262-6 §9.4.5 defines the required structural coverage metrics by ASIL level.

| Component | ASIL Rating | Coverage Target | Technique | Rationale |
|-----------|-------------|-----------------|-----------|-----------|
| SYS-NNN | ASIL D | MC/DC 100% | Modified Condition/Decision Coverage | ISO 26262-6 §9.4.5 — ASIL D requires MC/DC |
| SYS-NNN | ASIL C | Branch 100% + MC/DC recommended | Decision/Branch Coverage | ISO 26262-6 §9.4.5 — ASIL C requires branch coverage |
| SYS-NNN | ASIL B | Branch 100% | Decision/Branch Coverage | ISO 26262-6 §9.4.5 — ASIL B requires branch coverage |
| SYS-NNN | ASIL A | Statement 100% | Statement Coverage | ISO 26262-6 §9.4.5 — ASIL A requires statement coverage |

**ASIL-dependent Coverage Requirements**:
- **ASIL D**: MC/DC (Modified Condition/Decision Coverage) — each condition independently affects the decision
- **ASIL C**: Branch coverage mandatory; MC/DC highly recommended
- **ASIL B**: Branch coverage mandatory
- **ASIL A**: Statement coverage mandatory

**Rules**:
- Map coverage targets from the ASIL rating in the system design's FFI section
- Coverage shortfalls must be justified with rationale documented per ISO 26262-6 §9.4.5 Note 2
- Back-to-back testing may be used as a complement to structural coverage

## Resource Usage Testing (ISO 26262-6 §9.4.4)

Verify resource usage against safety budgets. ISO 26262-6 §9.4.4 requires testing of resource usage for safety-critical components.

| Component | ASIL Rating | Resource | Measurement | Threshold | Verification Method |
|-----------|-------------|----------|-------------|-----------|---------------------|
| SYS-NNN | ASIL [A–D] | WCET | [metric] | [max time] | [Static analysis / Instrumented measurement] |
| SYS-NNN | ASIL [A–D] | Max Stack Depth | [metric] | [max bytes] | [Static analysis / Runtime measurement] |
| SYS-NNN | ASIL [A–D] | Heap Usage | [metric] | [max bytes] | [Runtime measurement] |

**Rules**:
- WCET (Worst Case Execution Time) must be verified for all ASIL B–D components
- Stack depth analysis required for ASIL C–D components
- Heap usage limits required where dynamic allocation is permitted (discouraged for ASIL C–D)
- ASIL D components: recommend static WCET analysis + measurement confirmation
- Document measurement conditions (CPU load, interrupt frequency, temperature)

## Back-to-Back Testing (ISO 26262 Part 6 §6.9, Table 11)

Document back-to-back testing strategy for ASIL C and ASIL D components. ISO 26262 Part 6 §6.9 Table 11 recommends back-to-back testing as a verification method, comparing results from two independent implementations or from a model and its implementation.

| Component | ASIL Rating | Reference Implementation | Test Implementation | Comparison Method | Tolerance |
|-----------|-------------|-------------------------|--------------------|--------------------|-----------|
| SYS-NNN | ASIL [C/D] | [Model / Simulation / Independent impl.] | [Target code under test] | [Automated comparison / Manual review] | [Acceptable deviation bounds] |

**ASIL-dependent Requirements (per Table 11)**:
- **ASIL D**: Back-to-back testing highly recommended (++) — compare target implementation against an independent reference (model-based or dissimilar implementation)
- **ASIL C**: Back-to-back testing recommended (+) — compare against model or simulation where practical
- **ASIL A–B**: Back-to-back testing optional — may be used as supplementary evidence

**Rules**:
- Back-to-back test pairs must use independent implementations (model vs. code, or two dissimilar implementations)
- Define acceptable tolerance bounds for numerical comparisons (floating-point precision, timing jitter)
- Document the qualification of the reference implementation (model accuracy, version, validation status)
- Back-to-back discrepancies must be analyzed — each discrepancy is either a test issue, a model error, or a code defect
- Results complement structural coverage evidence — back-to-back testing does not replace MC/DC or branch coverage requirements
