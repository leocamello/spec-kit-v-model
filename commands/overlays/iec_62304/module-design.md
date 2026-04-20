# Module Design — IEC 62304 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iec_62304`.
> It provides domain-specific safety-critical module design sections for the base `module-design` command.
> Content in this overlay replaces the generic "Safety-Critical Sections" in the base command when this domain is active.

## Software Safety Class Constraints (IEC 62304 §5.4)

For each `MOD-NNN`, document the safety class constraints required by IEC 62304 §5.4 ("Software Detailed Design"):

| Module | Safety Class | Coding Standard | Complexity Limit | Documentation Requirements |
|--------|-------------|-----------------|------------------|-----------------------------|
| MOD-NNN | Class [A/B/C] | [Project Standard / IEC 61508-3 / Annex B] | ≤ [no limit / 15 / 10] per function | [Standard / Enhanced / Full] |

**Safety-Class-dependent Design Requirements** (IEC 62304 §5.4):
- **Class C**: Full detailed design documentation required (IEC 62304 §5.4.1): algorithms, data structures, error handling, and interfaces must be completely specified; coding guidelines required; complexity limited to ≤10 per function recommended; independent review (IEC 62304 §5.5.3) required before implementation
- **Class B**: Detailed design documentation required for safety-relevant modules; coding guidelines recommended; complexity ≤15 per function recommended
- **Class A**: Design documentation appropriate to the risk; no specific complexity or coding standard mandate

**Rules**:
- Class C modules: All four mandatory views (Algorithmic/Logic, State Machine, Internal Data Structures, Error Handling) MUST be present and complete
- Document the rationale for safety class assignment per ISO 14971 risk analysis results
- For Class C modules, the detailed design must be reviewed before implementation commences (IEC 62304 §5.5.2)

## Memory Management (IEC 62304 §5.5.2 + Risk Control)

For each `MOD-NNN`, document memory management constraints consistent with IEC 62304 §5.5 ("Software Unit Implementation") and ISO 14971 risk control measures:

| Module | Safety Class | Dynamic Allocation | Memory Isolation Required | Risk Control Measure |
|--------|-------------|-------------------|--------------------------|----------------------|
| MOD-NNN | Class [A/B/C] | Permitted / Restricted / Forbidden | Yes / No | [HAZ-NNN mitigation or N/A] |

**Safety-Class-dependent Memory Rules**:
- **Class C**: Dynamic memory allocation after initialization strongly discouraged; if used, must be justified in the risk analysis (ISO 14971) with residual risk acceptable; memory isolation between Class C components and lower-classified components recommended
- **Class B**: Dynamic allocation permitted with documented bounds; ensure no memory corruption can compromise Class C components
- **Class A**: Standard software engineering practices; no specific memory management mandate

**Additional Rules**:
- Unbounded loops MUST be documented with justification; for Class C, worst-case iteration counts should be established
- If a MOD-NNN implements a risk control measure (traces to HAZ-NNN), document that memory faults cannot compromise the mitigation
- IEC 62304 §5.5.2: the implementation must comply with the detailed design; deviations must be documented and reviewed

## Verification Strategy (IEC 62304 §5.5.3 — Unit Verification)

For each `MOD-NNN`, document the planned unit verification approach per IEC 62304 §5.5.3 to ensure the detailed design to code transition is verifiable:

| Module | Safety Class | Verification Method | Independent Review Required? | Code Review Checklist |
|--------|-------------|--------------------|-----------------------------|----------------------|
| MOD-NNN | Class [A/B/C] | Testing / Formal analysis / Code review | Class C: Yes / Class A–B: Recommended | [Checklist ID or N/A] |

**Rules**:
- **Class C**: Independent review of software unit implementation required (IEC 62304 §5.5.3(c)); use of static analysis tools documented
- **Class B**: Code review required; static analysis tools recommended
- **Class A**: Code review recommended
- Document which verification activities are planned in the unit-test.md (formal test plan) vs. informal walkthrough

## Additional Review Criteria (peer-review overlays only)

### Module Design — IEC 62304 Extensions

When reviewing `module-design.md` under IEC 62304:
- **Safety Class Traceability**: Does each MOD-NNN's safety class match the parent ARCH-NNN classification from the software architecture?
- **Class C Completeness**: For Class C modules, are all four mandatory views fully populated?
- **Risk Control Implementation**: If the module implements a risk control measure (HAZ-NNN), is this documented in the design?
- **Memory Safety**: For Class C modules, is dynamic allocation restricted/justified? Is memory isolation documented?
- **Verification Coverage**: Is the planned verification method (test, formal analysis, review) documented per safety class?
- **Independent Review**: For Class C, is an independent review planned before implementation?
