# System Design — ISO 26262 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iso_26262`.
> It provides domain-specific safety-critical design sections for the base `system-design` command.

## Freedom from Interference (ISO 26262-6 §7.4.8)

Document how components of different ASIL ratings are isolated from each other. Freedom from Interference (FFI) ensures that a lower-integrity component cannot corrupt a higher-integrity component.

| Component | ASIL Rating | Isolation Mechanism | Verification Method |
|-----------|-------------|---------------------|---------------------|
| SYS-NNN | ASIL [A–D] | [Memory partition / Time-slice / Communication protection] | [How verified: analysis, review, test] |

**Rules**:
- Every component with an ASIL rating must appear in this table
- Document isolation for each pair of components with different ASIL levels
- Cover all three interference categories:
  - **Spatial**: Memory partitioning, MPU/MMU configuration
  - **Temporal**: Time-slicing, watchdog timers, execution budgets
  - **Communication**: Message authentication, CRC protection, sequence counters
- Reference the ASIL allocation from the system design's Decomposition View

## Restricted Complexity (ISO 26262-6 §7.4.9)

Flag any components with complexity metrics that exceed safety thresholds. ISO 26262-6 §7.4.9 requires that software components at ASIL B–D demonstrate restricted complexity.

| Component | ASIL Rating | Complexity Metric | Value | Threshold | Status |
|-----------|-------------|-------------------|-------|-----------|--------|
| SYS-NNN | ASIL [A–D] | [Cyclomatic complexity / Nesting depth / Coupling / etc.] | [N] | [Max] | ✅ / ❌ |

**Rules**:
- ASIL D components: cyclomatic complexity ≤ 15, nesting depth ≤ 4
- ASIL C components: cyclomatic complexity ≤ 20, nesting depth ≤ 5
- ASIL B components: cyclomatic complexity ≤ 25, nesting depth ≤ 6
- ASIL A components: recommended limits, not mandatory
- Components exceeding thresholds must document justification or refactoring plan

## Safety Mechanisms Allocation (ISO 26262 Part 6 §6.5)

Document the allocation of safety mechanisms to system components. ISO 26262 Part 6 §6.5 requires that safety mechanisms are defined for each safety-relevant component to detect, prevent, or mitigate faults.

| Component | ASIL Rating | Safety Mechanism | Mechanism Type | Fault Addressed | Diagnostic Coverage |
|-----------|-------------|------------------|---------------|-----------------|---------------------|
| SYS-NNN | ASIL [A–D] | [Mechanism name] | Detection / Prevention / Mitigation | [What fault is handled] | [Low / Medium / High per Part 5 Table D.5] |

**Safety Mechanism Types**:
- **Detection**: Identifies a fault condition at runtime (e.g., watchdog timer, CRC check, voter logic, plausibility check)
- **Prevention**: Prevents a fault from occurring or propagating (e.g., input range validation, write protection, redundancy)
- **Mitigation**: Reduces the consequence of a fault (e.g., graceful degradation, safe state transition, limp-home mode)

**Rules**:
- Every ASIL B–D component must have at least one assigned safety mechanism
- ASIL D components: high diagnostic coverage required — multiple independent detection mechanisms recommended
- ASIL C components: medium-to-high diagnostic coverage — detection mechanisms required for single-point faults
- ASIL B components: basic detection mechanisms required
- Each safety mechanism must specify the fault reaction time (time from fault detection to safe state)
- Safety mechanisms become verification targets in system test and integration test
- Document the independence between the safety mechanism and the component it monitors
