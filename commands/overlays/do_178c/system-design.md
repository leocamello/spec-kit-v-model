# System Design — DO-178C Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: do_178c`.
> It provides domain-specific safety-critical design sections for the base `system-design` command.

## Freedom from Interference

Document how components of different DAL (Design Assurance Level) ratings are isolated. Partitioning ensures that a lower-assurance component cannot adversely affect a higher-assurance component.

| Component | DAL | Partitioning Method | Verification Method |
|-----------|-----|---------------------|---------------------|
| SYS-NNN | DAL [A–E] | [Robust partitioning / Functional isolation / etc.] | [Analysis, test, review per DO-178C §6.3.3f] |

**Rules**:
- Every component with a DAL assignment must appear in this table
- DAL A and B components require robust partitioning (ARINC 653 or equivalent)
- Document both spatial and temporal partitioning mechanisms
- For mixed-DAL systems, demonstrate that lower-DAL components cannot interfere with higher-DAL components
- Reference DO-178C §6.3.3f for partitioning verification guidance

## Restricted Complexity

Flag components with structural complexity that may impede verification at the assigned DAL. High complexity increases the risk of undetected errors during structural coverage analysis (DO-178C §6.4.4.2).

| Component | DAL | Complexity Metric | Value | Threshold | Status |
|-----------|-----|-------------------|-------|-----------|--------|
| SYS-NNN | DAL [A–E] | [Cyclomatic complexity / Coupling / etc.] | [N] | [Max] | ✅ / ❌ |

**Rules**:
- DAL A components: cyclomatic complexity ≤ 15 (MC/DC coverage required per DO-178C §6.4.4.2)
- DAL B components: cyclomatic complexity ≤ 20 (decision coverage required)
- DAL C components: cyclomatic complexity ≤ 30 (statement coverage required)
- Components exceeding thresholds must document justification or refactoring plan
- High-complexity components increase structural coverage testing burden

## Partitioning and Derived Design Requirements (DO-178C §5.2.2)

Document how the system design addresses partitioning requirements and identifies derived requirements that arise from design decisions. DO-178C §5.2.2 requires that the software design process captures partitioning boundaries and any requirements not directly traceable to system requirements.

| Component | DAL | Partition Boundary | Protection Mechanism | Derived Requirements |
|-----------|-----|--------------------|---------------------|---------------------|
| SYS-NNN | DAL [A–E] | [Partition boundary description] | [ARINC 653 / MMU / Temporal isolation] | [Any new requirements arising from design] |

**Rules**:
- Every partition boundary must be documented with its protection mechanism
- Derived requirements from design decisions must be flagged `[DERIVED]` and communicated to the system safety assessment process
- DAL A–B: robust partitioning (ARINC 653 or equivalent) required for mixed-DAL components
- DAL C: partitioning analysis required; physical isolation recommended but not mandatory

## Data and Control Coupling Analysis (DO-178C §5.2.2)

Analyze data coupling (shared data between components) and control coupling (execution dependencies between components). DO-178C §5.2.2 requires that coupling between software components is documented and verified.

| Component Pair | DAL | Coupling Type | Shared Resource | Direction | Verification Method |
|----------------|-----|---------------|-----------------|-----------|---------------------|
| SYS-NNN ↔ SYS-NNN | DAL [A–E] | Data / Control | [What is shared] | [Uni / Bi] | [Analysis, test, review] |

**Rules**:
- DAL A: all data and control coupling must be verified through analysis and test
- DAL B: coupling analysis required; critical couplings must be tested
- DAL C: coupling documented; verification proportional to safety impact
- Unintended coupling (e.g., global variables, shared memory without partition protection) must be identified and eliminated or justified
- Coupling analysis feeds into integration test planning (§5.4)
