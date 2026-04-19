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
