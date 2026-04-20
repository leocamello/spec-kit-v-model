# System Design — IEC 62304 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iec_62304`.
> It provides domain-specific safety-critical design sections for the base `system-design` command.

## Safety Class Allocation (IEC 62304 §4.3)

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
- Class C components require the most rigorous design constraints (IEC 62304 §5.3)
- Mixed-class systems must document segregation between classes

## Software Item Identification (IEC 62304 §5.3.1–§5.3.2)

Identify all software items in the system architecture. IEC 62304 §5.3.1 requires documenting the software architecture, and §5.3.2 requires identifying all software items (units) with their relationships.

| Software Item | Parent Component | Safety Class | Description | Interfaces |
|---------------|-----------------|-------------|-------------|------------|
| SI-NNN | SYS-NNN | Class [A/B/C] | [What this item does] | [Which other items it interfaces with] |

**Rules**:
- Every software item must be identified and documented per §5.3.2
- Class B and C software items require documented interfaces (§5.3.3)
- The decomposition must be sufficient to identify all safety-critical items
- Software items inherit their parent's safety class unless segregation is demonstrated (§5.3.5)

## Risk Control Measures in Design (IEC 62304 §5.3 + ISO 14971)

Document how the system design implements risk control measures identified in the hazard analysis. IEC 62304 §5.3 requires that the software architecture incorporates risk control measures from the ISO 14971 risk management process.

| Risk Control Measure | Hazard Ref | Component(s) | Implementation Strategy | Verification Approach |
|---------------------|-----------|--------------|------------------------|----------------------|
| [Description] | HAZ-NNN | SYS-NNN | [How the design addresses the hazard] | [How effectiveness will be verified] |

**Rules**:
- Every risk control measure from the hazard analysis must be traceable to at least one design element
- Class C risk controls require independent verification (§5.3.6)
- Document the relationship between risk control measures and safety class assignments
- Risk control failures must trigger appropriate error handling (safe state or alarm)

## Interface Documentation (IEC 62304 §5.3.3)

Document the interfaces between software items and between software and external systems. IEC 62304 §5.3.3 requires functional and performance documentation of interfaces for Class B and C software.

| Interface | From | To | Type | Data Exchanged | Safety Class | Constraints |
|-----------|------|-----|------|---------------|-------------|-------------|
| IF-NNN | SYS-NNN / SI-NNN | SYS-NNN / SI-NNN | [API / Protocol / HW] | [Description] | Class [A/B/C] | [Timing, size, error handling] |

**Rules**:
- Class C interfaces: complete specification of data types, ranges, timing, and error handling required
- Class B interfaces: functional specification with error handling documented
- Class A interfaces: documentation recommended but not required
- External interfaces (to hardware, SOUP, or other systems) must specify assumptions about the external component's behavior
- Interface constraints become integration test targets (§5.6)
