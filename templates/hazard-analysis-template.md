# Hazard Analysis (FMEA): [FEATURE NAME]

**Feature Branch**: `[###-feature-name]`
**Created**: [DATE]
**Status**: Draft
**Source**: `specs/[###-feature-name]/v-model/system-design.md`
**Standard**: General-Purpose FMEA (domain overlay may apply)

## Overview

This document presents the Failure Mode and Effects Analysis (FMEA) for [FEATURE NAME].
Every system component (`SYS-NNN`) from `system-design.md` is assessed for potential failure
modes across the operational states defined in the system design. Each hazard receives a
unique `HAZ-NNN` identifier and is linked to risk control measures (`REQ-NNN` / `SYS-NNN`),
enabling the traceability chain: Hazard → Mitigation → Requirement → Test Case (Matrix H).

## ID Schema

- **Hazard ID**: `HAZ-{NNN}` — 3-digit zero-padded, sequential (HAZ-001, HAZ-002, ...)
- **ID Lineage**: From `HAZ-001`, read the Mitigation column to find `REQ-NNN` / `SYS-NNN`.
  Consult `traceability-matrix.md` (Matrix H) for the full chain to verification test cases.

## Risk Matrix Definition

<!--
  Include the severity × likelihood risk matrix used for this analysis.
  Use the general-purpose matrix by default.
  If v-model-config.yml domain is set, use the domain-specific scale instead.
-->

### Severity Scale

<!--
  Use the general-purpose severity scale below as the default.
  If a domain overlay is loaded, use the overlay's severity scale instead.
-->

| Level | Definition |
|-------|-----------|
| Catastrophic | Death or permanent injury; complete system destruction |
| Critical | Severe injury or major system damage; immediate intervention required |
| Serious | Moderate injury or significant degradation; medical attention needed |
| Minor | Slight injury or minor degradation; first aid sufficient |
| Negligible | No injury; cosmetic or inconvenience-level impact |

### Likelihood Scale

| Level | Definition |
|-------|-----------|
| Frequent | Likely to occur often; continuously experienced |
| Probable | Will occur several times; expected to occur |
| Occasional | Likely to occur sometime; can reasonably be expected |
| Remote | Unlikely but possible; could occur in the life of the system |
| Improbable | So unlikely it can be assumed it will not occur |

### Risk Matrix (Severity × Likelihood)

| | Frequent | Probable | Occasional | Remote | Improbable |
|---|---|---|---|---|---|
| **Catastrophic** | Unacceptable | Unacceptable | Unacceptable | Undesirable | Undesirable |
| **Critical** | Unacceptable | Unacceptable | Undesirable | Undesirable | Tolerable |
| **Serious** | Unacceptable | Undesirable | Undesirable | Tolerable | Tolerable |
| **Minor** | Undesirable | Tolerable | Tolerable | Acceptable | Acceptable |
| **Negligible** | Tolerable | Acceptable | Acceptable | Acceptable | Acceptable |

## Operational States Reference

<!--
  List all operational states extracted from system-design.md.
  If no explicit states are defined, use a single implicit "NORMAL" state
  and note the warning.
-->

| State | Description | Source |
|-------|------------|--------|
| [STATE_1] | [Description from system-design.md] | system-design.md §[section] |
| [STATE_2] | [Description from system-design.md] | system-design.md §[section] |

<!-- If no explicit states: -->
<!-- | NORMAL | Implicit default state (no operational states defined in system-design.md) | Implicit | -->
<!-- ⚠️ No operational states defined in system-design.md — using implicit NORMAL state. -->

## Hazard Register (FMEA)

<!--
  For EACH system component (SYS-NNN) in system-design.md:
  1. Identify failure modes (function, timing, value, interface failures)
  2. Evaluate severity across EVERY relevant operational state
  3. Create SEPARATE HAZ-NNN entries when severity differs by state
  4. Link every mitigation to at least one REQ-NNN or SYS-NNN

  RULES:
  - Every SYS-NNN must have at least one HAZ-NNN entry
  - Each HAZ entry has exactly 10 fields (columns below)
  - Mitigations MUST reference existing REQ-NNN or SYS-NNN identifiers
  - IDs are sequential, zero-padded, never renumbered
  - If no realistic failure mode exists: use "No identified failure mode" with
    Severity: Negligible and flag [HUMAN REVIEW REQUIRED]
  - When updating (progressive deepening): append only, never modify existing entries

  LIFECYCLE TAGS (inline in Failure Mode or Component column when evolving):
  - [DEPRECATED — Superseded by HAZ-NNN]: Hazard superseded (parent SYS replaced)
  - [DEPRECATED — Withdrawn: <reason>]: Hazard removed (parent SYS withdrawn)
  - [SUSPECT — Parent SYS-NNN {deprecated|modified}]: Parent system component changed;
    re-evaluate hazard severity, mitigations, and residual risk.
  - Mitigations referencing [DEPRECATED] REQ-NNN must be updated to reference
    the superseding requirement or flagged as unmitigated.
  - Deprecated HAZs stay in the table; they are never deleted.
  - Coverage checks (SYS→HAZ) exclude deprecated SYS items.
-->

| HAZ ID | Component | Failure Mode | Operational State | Effect | Severity | Likelihood | Risk Level | Mitigation | Residual Risk |
|--------|-----------|-------------|-------------------|--------|----------|-----------|------------|------------|---------------|
| HAZ-001 | SYS-001 | [Failure description] | [STATE] | [System-level effect] | [Severity] | [Likelihood] | [Risk Level] | [REQ-NNN / SYS-NNN refs] | [Residual risk after mitigation] |
| HAZ-002 | SYS-001 | [Same failure, different state] | [STATE_2] | [Different effect at this state] | [Different severity] | [Likelihood] | [Risk Level] | [REQ-NNN / SYS-NNN refs] | [Residual risk] |

<!--
  Continue for ALL SYS-NNN components...

  Example of "no failure mode" entry:
  | HAZ-NNN | SYS-009 | No identified failure mode | ALL | N/A | Negligible | Improbable | Acceptable | N/A | Acceptable |
  [HUMAN REVIEW REQUIRED: Confirm no failure modes exist for SYS-009]
-->

## Progressive Deepening (Architecture-Level)

<!--
  Only include this section if architecture-design.md exists.
  Architecture-level hazards are APPENDED to the register above.
  They capture failure modes not visible at the SYS level:
  - Interface mismatches between ARCH modules
  - Protocol failures (handshake, timeout)
  - Data format incompatibilities
  - Race conditions (if applicable)

  If no new architecture-level hazards are found, state:
  "No additional architecture-level hazards identified."
-->

[Architecture-level hazard entries appended to the FMEA table above, or note that none were identified.]

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total System Components (SYS) | [N] ([N] active, [N] deprecated) |
| Components with ≥1 HAZ | [N] / [N] ([%]) (active items only) |
| Total Hazards (HAZ) | [N] |
| System-level hazards | [N] |
| Architecture-level hazards | [N] (progressive deepening) |

### Severity Distribution

| Severity | Count | Percentage |
|----------|-------|------------|
| Catastrophic | [N] | [%] |
| Critical | [N] | [%] |
| Serious | [N] | [%] |
| Minor | [N] | [%] |
| Negligible | [N] | [%] |

### Risk Level Distribution

| Risk Level | Count | Percentage |
|------------|-------|------------|
| Unacceptable | [N] | [%] |
| Undesirable | [N] | [%] |
| Tolerable | [N] | [%] |
| Acceptable | [N] | [%] |

### Operational State Distribution

| State | Hazard Count |
|-------|-------------|
| [STATE_1] | [N] |
| [STATE_2] | [N] |
| ALL | [N] |

## Uncovered Components

<!--
  Populated by validate-hazard-coverage.sh.
  If coverage is 100%, state "None — full coverage achieved."
-->

[List of SYS-NNN IDs without any HAZ, or "None — full coverage achieved."]
