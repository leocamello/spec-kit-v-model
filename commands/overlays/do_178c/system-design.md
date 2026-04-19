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
