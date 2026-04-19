# System Design — IEC 62304 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iec_62304`.
> It provides domain-specific safety-critical design sections for the base `system-design` command.

## Safety Class Allocation

Assign an IEC 62304 software safety class (A, B, or C) to each system component based on the hazard analysis. The safety class determines the required rigor of the software development lifecycle for that component.

| Component | Safety Class | Justification | Highest Contributing Hazard |
|-----------|-------------|---------------|-----------------------------|
| SYS-NNN | Class [A/B/C] | [Why this classification] | [HAZ-NNN reference or "No hazard contribution"] |

**Safety Class Definitions**:
- **Class C**: Software that can contribute to a hazardous situation resulting in death or serious injury — full lifecycle documentation and verification required
- **Class B**: Software that can contribute to a hazardous situation resulting in non-serious injury — verification and testing required
- **Class A**: Software that cannot contribute to a hazardous situation — basic development process sufficient

**Rules**:
- Every component must have a safety class assignment
- Safety class is inherited from the highest-severity hazard the component can contribute to (per ISO 14971 risk analysis)
- Class C components require the most rigorous design constraints (IEC 62304 §5.4)
- Mixed-class systems must document segregation between classes

## Software Unit Verification Requirements by Safety Class

Document the verification requirements for each component based on its assigned safety class per IEC 62304 §5.5.

| Component | Safety Class | Design Verification | Code Review | Testing Required |
|-----------|-------------|--------------------|--------------|--------------------|
| SYS-NNN | Class C | Formal review required | Mandatory with checklist | Comprehensive unit + integration testing |
| SYS-NNN | Class B | Review required | Recommended | Testing required |
| SYS-NNN | Class A | Optional | Optional | Optional |

**Rules**:
- Class C: All IEC 62304 §5.5 requirements apply — formal verification of design, mandatory code review, comprehensive testing
- Class B: Verification and testing required; some documentation may be reduced per IEC 62304 §5.5
- Class A: Minimal requirements; basic process documentation sufficient
- Document any risk control measures from ISO 14971 that influence verification scope
