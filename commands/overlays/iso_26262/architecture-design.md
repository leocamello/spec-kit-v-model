# Architecture Design — ISO 26262 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iso_26262`.
> It provides domain-specific safety-critical architecture sections for the base `architecture-design` command.

## ASIL Decomposition (ISO 26262-9 §5)

Document the allocation of ASIL ratings from parent system components (SYS) to child architecture modules (ARCH). ISO 26262-9 §5 defines rules for ASIL decomposition — splitting a higher ASIL into lower ASILs across redundant elements.

| Parent Component | Parent ASIL | Child Module | Child ASIL | Independence Argument |
|------------------|-------------|--------------|------------|------------------------|
| SYS-NNN | ASIL [A–D] | ARCH-NNN | ASIL [A–D / QM] | [How independence is guaranteed] |

**ASIL Decomposition Rules (ISO 26262-9 §5)**:
- ASIL D may decompose to: ASIL C(D) + ASIL A(D), or ASIL B(D) + ASIL B(D), or ASIL D(D) + QM(D)
- ASIL C may decompose to: ASIL B(C) + ASIL A(C), or ASIL C(C) + QM(C)
- ASIL B may decompose to: ASIL A(B) + ASIL A(B), or ASIL B(B) + QM(B)
- The letter in parentheses denotes the initial ASIL before decomposition
- Decomposition requires **proven independence** between the child elements

**Independence Arguments**:
- Spatial independence: separate memory regions, MPU/MMU enforcement
- Temporal independence: separate time slots, independent watchdogs
- Communication independence: authenticated message channels, end-to-end CRC
- Design independence: different design teams, different algorithms, different tool chains

## Defensive Programming (ISO 26262-6 §7.4.2)

Document how each architecture module protects against invalid inputs from other modules. ISO 26262-6 §7.4.2 requires defensive programming techniques for ASIL-rated software.

| Module | ASIL Rating | Invalid Input | Detection Method | Recovery Action |
|--------|-------------|---------------|------------------|-----------------|
| ARCH-NNN | ASIL [A–D] | [What could go wrong at module boundary] | [Range check / CRC / Assertion / Plausibility] | [Safe state / Fallback / Error report] |

**Required Defensive Techniques by ASIL**:
- **ASIL D**: Range checks, plausibility checks, redundant computation, assertion monitoring, diverse programming
- **ASIL C**: Range checks, plausibility checks, assertion monitoring
- **ASIL B**: Range checks, plausibility checks
- **ASIL A**: Range checks recommended

**Rules**:
- Every ASIL B–D module must have at least one defensive mechanism documented
- Document both the detection method and the recovery action (safe state transition)
- Cross-reference with the FFI analysis from the system design overlay

## Temporal & Execution Constraints

Document timing budgets and execution order constraints for safety-critical modules. ISO 26262-6 §7.4.4 requires that temporal behavior be specified and verified for ASIL-rated components.

| Module | ASIL Rating | Constraint Type | Value | Enforcement Mechanism |
|--------|-------------|-----------------|-------|------------------------|
| ARCH-NNN | ASIL [A–D] | WCET | [max time, e.g., 10ms] | [Watchdog timer / OS scheduling] |
| ARCH-NNN | ASIL [A–D] | Execution Order | [before/after ARCH-NNN] | [Scheduler / Barrier / Sequence monitor] |
| ARCH-NNN | ASIL [A–D] | Deadline | [max end-to-end, e.g., 50ms] | [Deadline monitoring] |

**Rules**:
- ASIL C–D modules: mandatory WCET specification and enforcement mechanism
- ASIL B modules: WCET specification recommended
- Execution order dependencies must be documented for all safety-relevant chains
- Deadlock prevention strategy required for any ASIL-rated modules sharing resources
- Watchdog timers required for ASIL D modules; recommended for ASIL C
