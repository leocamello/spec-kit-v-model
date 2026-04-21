# Impact Analysis — IEC 62304 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iec_62304`.
> It provides domain-specific software maintenance and change management sections for the base `impact-analysis` command.

## Change Management by Safety Class (IEC 62304 §8)

IEC 62304 §8 requires that changes to medical device software are managed through a controlled change process. When running impact analysis in an IEC 62304 project, the impact report must classify each change by safety class and determine the required change management rigor:

| Changed ID | Safety Class | Change Type | Risk Control Affected (HAZ-NNN)? | Change Management Required |
|-----------|-------------|-------------|----------------------------------|---------------------------|
| REQ-NNN | Class [A/B/C] | [New / Modified / Deprecated] | Yes — HAZ-NNN / No | [See table below] |
| MOD-NNN | Class [A/B/C] | [New / Modified / Deprecated] | Yes — HAZ-NNN / No | [See table below] |

**Change Management Requirements by Safety Class** (IEC 62304 §8.2):

| Safety Class | Change Request Required? | Impact Analysis Required? | Re-verification Scope | Regulatory Notification? |
|-------------|-------------------------|--------------------------|----------------------|--------------------------|
| Class C | Yes — formal change request | Yes — full impact assessment | Re-verify all affected Class C lifecycle activities | Potentially (substantial change per MDR/FDA guidance) |
| Class B | Yes — change request | Yes — targeted impact assessment | Re-verify affected activities; regression testing | If risk control affected |
| Class A | Recommended — change log entry | Recommended | Confirm system tests still pass | If risk control affected |

**Rules**:
- Any change to a software item that implements a risk control measure (tracing to HAZ-NNN) triggers the Class C change management process regardless of the item's assigned safety class
- Class C changes that modify the device's safety characteristics must be assessed against EU MDR Article 120 / FDA 21 CFR Part 820 to determine if regulatory re-submission is required — flag this in the impact report
- Deprecating a software item that traces to HAZ-NNN must be accompanied by identification of the replacement risk control

## Software Maintenance Classification (IEC 62304 §6)

IEC 62304 §6 defines three types of software maintenance events, each with different impact analysis obligations:

| Maintenance Type | IEC 62304 §6 Ref | Description | Example Changed ID | Impact Analysis Obligation |
|-----------------|-----------------|-------------|-------------------|---------------------------|
| Corrective maintenance | §6.2 | Fix a problem discovered post-release | MOD-NNN, REQ-NNN | Full impact analysis required; update problem resolution record |
| Adaptive maintenance | §6.3 | Adapt software to new environment or hardware | SYS-NNN, ARCH-NNN | Impact analysis + re-validation of integration tests (ITP-NNN) |
| Perfective maintenance | §6.4 | Improve performance or maintainability without changing function | MOD-NNN | Targeted impact analysis; confirm no functional change in unit tests |

**Rules**:
- Classify each changed ID into one of the three maintenance types before proceeding with the impact analysis
- Corrective maintenance for a Class C item requires a formal problem report linked to the change (cross-reference with the problem resolution process)
- Adaptive maintenance that changes hardware interfaces must trigger re-evaluation of all integration test artifacts (ITP-NNN) that verify those interfaces

## Re-validation Table by Safety Class (IEC 62304 §8.2.4)

For each suspect artifact identified by the base command, determine re-validation obligations by safety class:

| Suspect Artifact | Safety Class | Re-validation Required | Activities |
|-----------------|-------------|----------------------|------------|
| SYS-NNN | Class C | Full re-verification per §5.3 | Architecture review, interface verification, risk control traceability check |
| MOD-NNN | Class C | Unit re-verification per §5.5 | Code review, unit tests re-run, coverage documented |
| MOD-NNN | Class B | Unit re-verification per §5.5 | Unit tests re-run, coverage documented; independent review recommended |
| MOD-NNN | Class A | Confirmation | Confirm system tests (STP-NNN) still pass |
| REQ-NNN | Class C | Requirements re-review per §5.2 | Requirements review, risk analysis update if scope changes |

- After re-validation is complete, remove the `[SUSPECT]` tag and add `[ACTIVE — Re-validated: CR-NNN]` to the artifact
- Record re-validation evidence in the risk management file for any item that traces to HAZ-NNN
