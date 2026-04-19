# Architecture Design — DO-178C Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: do_178c`.
> It provides domain-specific safety-critical architecture sections for the base `architecture-design` command.

## DAL Allocation

Document the allocation of Design Assurance Levels from parent system components (SYS) to child architecture modules (ARCH). DAL allocation must demonstrate independence arguments per DO-178C §6.3.3f.

| Parent Component | Parent DAL | Child Module | Child DAL | Independence Argument |
|------------------|-----------|--------------|-----------|------------------------|
| SYS-NNN | DAL [A–E] | ARCH-NNN | DAL [A–E] | [How independence is demonstrated] |

**DAL Allocation Rules**:
- The child module inherits the parent's DAL unless robust partitioning is demonstrated
- DAL reduction (e.g., parent DAL A → child DAL C) requires:
  - Robust partitioning (spatial and temporal isolation per ARINC 653 or equivalent)
  - Independent verification of the partitioning mechanism at the original DAL
- Mixed-DAL architectures must demonstrate that lower-DAL modules cannot adversely affect higher-DAL modules

**Independence Arguments for DAL Reduction**:
- Robust spatial partitioning: ARINC 653 compliant RTOS, hardware MMU enforcement
- Robust temporal partitioning: fixed time windows, health monitoring, no frame overrun
- Information flow isolation: controlled inter-partition communication, validated message formats
- Separate verification evidence for each partition boundary

## Defensive Programming (DO-178C §6.3.3)

Document how each architecture module protects against anomalous conditions. DO-178C §6.3.3 requires that software architecture accounts for error handling and anomalous behavior.

| Module | DAL | Invalid Input | Detection Method | Recovery Action |
|--------|-----|---------------|------------------|-----------------|
| ARCH-NNN | DAL [A–E] | [Anomalous input condition] | [Runtime assertion / Watchdog / Comparator] | [Error handling per §6.3.3e] |

**Required Defensive Techniques by DAL**:
- **DAL A**: Comprehensive error handling, independent monitoring, dissimilar redundancy for Catastrophic failure conditions
- **DAL B**: Error handling with independence between detection and recovery paths
- **DAL C**: Standard error handling and input validation
- **DAL D**: Basic error handling
- **DAL E**: No specific requirements

**Rules**:
- DAL A–B modules: robust error handling is a verification objective (DO-178C Table A-4 objective 5)
- Document the relationship between error handling and the failure conditions from the safety assessment
- All detected errors must be reported to the health monitoring subsystem

## Temporal Constraints (DO-178C §6.3.4)

Document timing budgets, execution order, and scheduling constraints. DO-178C §6.3.4 addresses the verification of software integration — temporal constraints are critical for real-time avionics systems.

| Module | DAL | Constraint Type | Value | Enforcement Mechanism |
|--------|-----|-----------------|-------|------------------------|
| ARCH-NNN | DAL [A–E] | WCET | [max time, e.g., 10ms] | [RTOS scheduling / Partition budget] |
| ARCH-NNN | DAL [A–E] | Frame Budget | [% of partition window] | [Health monitor / Frame overrun detection] |
| ARCH-NNN | DAL [A–E] | Execution Order | [before/after ARCH-NNN] | [Schedule table / Precedence constraint] |

**Rules**:
- DAL A–B modules: WCET must be verified through both static analysis and measurement (DO-178C §6.4.3)
- DAL C modules: WCET measurement sufficient with documented test conditions
- Frame overrun detection mandatory for all partitioned architectures
- Execution order dependencies must align with the data flow and process views
- Document worst-case interrupt latency for interrupt-driven modules

## Architecture Verification Objectives (DO-178C Table A-5)

Verify that the architecture design satisfies the applicable objectives from DO-178C Table A-5 based on the DAL assignment. Table A-5 defines verification objectives for the outputs of the software design process.

| Objective | DAL A | DAL B | DAL C | DAL D |
|-----------|-------|-------|-------|-------|
| Low-level requirements comply with high-level requirements | ✓ | ✓ | ✓ | ✓ |
| Low-level requirements are accurate and consistent | ✓ | ✓ | ✓ | ✓ |
| Low-level requirements are compatible with target computer | ✓ | ✓ | ✓ | — |
| Low-level requirements are verifiable | ✓ | ✓ | ✓ | ✓ |
| Low-level requirements conform to standards | ✓ | ✓ | ✓ | — |
| Low-level requirements are traceable to high-level requirements | ✓ | ✓ | ✓ | ✓ |
| Algorithms are accurate | ✓ | ✓ | — | — |
| Software architecture is compatible with high-level requirements | ✓ | ✓ | ✓ | ✓ |
| Software architecture is consistent | ✓ | ✓ | ✓ | — |
| Software architecture is compatible with target computer | ✓ | ✓ | ✓ | — |
| Software architecture is verifiable | ✓ | ✓ | ✓ | — |
| Software partitioning integrity is confirmed | ✓ | ✓ | ✓ | — |

**Rules**:
- DAL A–B: all Table A-5 objectives must be satisfied with independence (reviewer ≠ developer)
- DAL C: most objectives apply; independence recommended but not mandatory
- DAL D: reduced set of objectives applies
- Each module in the architecture must be traceable to verification evidence demonstrating these objectives

## Data and Control Coupling at Architecture Level (DO-178C §5.2.2)

Document the data and control coupling between architecture modules. DO-178C §5.2.2 requires coupling analysis to verify that the architecture correctly implements the intended data flow and control flow.

| Module Pair | DAL | Coupling Type | Shared Resource | Protection | Verified |
|-------------|-----|---------------|-----------------|------------|----------|
| ARCH-NNN ↔ ARCH-NNN | DAL [A–E] | Data / Control | [Shared variable, message, signal] | [Partition / Validated port / None] | ✅ / ❌ |

**Rules**:
- DAL A–B: all coupling must be through defined interfaces; no uncontrolled shared data
- DAL C: coupling through defined interfaces recommended; deviations documented
- Coupling analysis must be consistent with the partitioning analysis (§5.2.2) and FFI demonstration
- Unintended coupling paths must be identified as potential common-mode failure sources
