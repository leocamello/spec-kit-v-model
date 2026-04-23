# Hazard Analysis (FMEA): Flight Warning Computer (FWC)

**Feature Branch**: `flight-warning-computer`
**Created**: 2026-01-15
**Status**: Draft
**Source**: `tests/fixtures/golden/flight-warning-computer/expected-system-design.md`
**Standard**: DO-178C / ARP4761A (Aerospace Risk Management)

## Overview

This document presents the Failure Mode and Effects Analysis (FMEA) for the Flight Warning
Computer. Every system component (`SYS-NNN`) from `system-design.md` is assessed for potential
failure modes across the FWC's operational states. Each hazard receives a unique `HAZ-NNN`
identifier and is linked to risk control measures (`REQ-NNN` / `SYS-NNN`), enabling the
traceability chain: Hazard → Mitigation → Requirement → Test Case (Matrix H).

## ID Schema

- **Hazard ID**: `HAZ-{NNN}` — 3-digit zero-padded, sequential (HAZ-001, HAZ-002, ...)
- **ID Lineage**: From `HAZ-001`, read the Mitigation column to find `REQ-NNN` / `SYS-NNN`.

## Risk Matrix Definition

### Severity Scale (ARP4761A §4.4.1)

| Level | Definition |
|-------|-----------|
| Catastrophic | Loss of aircraft or multiple fatalities |
| Hazardous | Large reduction in safety margins; serious crew injuries; fatal to small number of occupants |
| Major | Significant reduction in safety margins; physical distress to crew; flight crew unable to rely on some systems |
| Minor | Slight reduction in safety margins; some inconvenience to crew |
| No Safety Effect | No effect on operational capability or crew workload |

### Likelihood Scale (per flight hour)

| Level | Definition |
|-------|-----------|
| Frequent | Likely to occur regularly: > 10⁻³ per flight hour |
| Probable | Will occur several times in life of aircraft: 10⁻⁵ to 10⁻³ per flight hour |
| Remote | Unlikely but possible: 10⁻⁷ to 10⁻⁵ per flight hour |
| Extremely Remote | Very unlikely: 10⁻⁹ to 10⁻⁷ per flight hour |
| Extremely Improbable | So unlikely it can be assumed it will not occur: < 10⁻⁹ per flight hour |

### Risk Matrix (Severity × Likelihood — ARP4761A §4.4)

| | Frequent | Probable | Remote | Extremely Remote | Extremely Improbable |
|---|---|---|---|---|---|
| **Catastrophic** | Unacceptable | Unacceptable | Unacceptable | Undesirable | Acceptable |
| **Hazardous** | Unacceptable | Unacceptable | Undesirable | Acceptable | Acceptable |
| **Major** | Unacceptable | Undesirable | Acceptable | Acceptable | Acceptable |
| **Minor** | Undesirable | Acceptable | Acceptable | Acceptable | Acceptable |
| **No Safety Effect** | Acceptable | Acceptable | Acceptable | Acceptable | Acceptable |

## Operational States Reference

| State | Description | Source |
|-------|------------|--------|
| MONITORING | Normal inflight warning monitoring; all five warning functions active | system-design.md (SYS-002 active) |
| POWER_ON_SELF_TEST | BITE self-test; all outputs inhibited | system-design.md (BITE sequence) |
| DEGRADED | One or more sensor inputs invalid; affected functions inhibited | system-design.md (NCD handling) |
| MAINTENANCE | Ground maintenance mode; outputs inhibited | system-design.md (BITE log access) |

## Hazard Register (FMEA)

| HAZ ID | Component | Failure Mode | Operational State | Effect | Severity | Likelihood | Risk Level | Mitigation | Residual Risk |
|--------|-----------|-------------|-------------------|--------|----------|-----------|------------|------------|---------------|
| HAZ-001 | SYS-001 | Air Data Interface fails to receive ADIRU airspeed data (bus timeout) | MONITORING | Overspeed warning function disabled; crew not alerted to VMO/MMO exceedance | Catastrophic | Extremely Remote | Acceptable | REQ-IF-001 (150 ms freshness check with ADIRU FAIL annunciator), REQ-DR-002 (watchdog detects SYS-001 failure) | Acceptable with ADIRU FAIL annunciation |
| HAZ-002 | SYS-001 | Air Data Interface passes stale AoA data as valid (age check bypassed) | MONITORING | Stall warning based on outdated AoA; missed stall warning possible | Catastrophic | Extremely Remote | Acceptable | REQ-IF-001 (label age check ≤ 150 ms enforced in ARCH-002), REQ-CN-001 (MC/DC coverage of age comparison) | Acceptable with independent age check verification |
| HAZ-003 | SYS-002 | Warning Logic Engine evaluates incorrect threshold (memory corruption) | MONITORING | Wrong warning activation threshold; missed or spurious stall/overspeed warning | Catastrophic | Extremely Remote | Acceptable | REQ-DR-002 (watchdog), REQ-CN-001 (DO-178C DAL-A; thresholds in OTP ROM with read-back verification) | Acceptable with OTP ROM verification |
| HAZ-004 | SYS-002 | Warning Logic Engine fails to detect AoA exceedance (logic fault) | MONITORING | Stall warning not generated; risk of aerodynamic stall with no crew warning | Catastrophic | Extremely Remote | Acceptable | REQ-002 (independent dual evaluator for STALL in ARCH-004), REQ-CN-001 (MC/DC coverage mandatory) | Acceptable with independent second evaluator |
| HAZ-005 | SYS-002 | Warning Logic Engine generates spurious OVERSPEED warning (false activation) | MONITORING | Crew distracted by false alarm; possible inappropriate pilot response (speed reduction on approach) | Major | Remote | Acceptable | REQ-001 (hysteresis band on threshold in ARCH-004 prevents chatter), REQ-IF-001 (NCD check prevents invalid data use) | Acceptable with hysteresis |
| HAZ-006 | SYS-003 | Output Control fails to drive stick shaker on valid stall warning command | MONITORING | Stall warning not communicated to crew via tactile cue; risk of stall | Catastrophic | Extremely Remote | Acceptable | REQ-002 (ARCH-008 actuator feedback monitoring via BITE; STICK SHAKER FAIL annunciator activated) | Acceptable with BITE monitoring |
| HAZ-007 | SYS-003 | Output Control drives stick shaker spuriously (stuck-on) | MONITORING | Inappropriate tactile cue; crew distraction; physical discomfort during normal flight | Major | Remote | Acceptable | REQ-DR-001 (BITE current monitor detects stuck-on within 20 ms; ARCH-009 activates STICK SHAKER FAIL) | Acceptable with rapid BITE detection |
| HAZ-008 | SYS-001 | Air Data Interface fails during Power-On Self-Test (POST) | POWER_ON_SELF_TEST | FWC enters service in degraded state with undetected sensor fault | Hazardous | Remote | Acceptable | REQ-DR-001 (POST required to complete within 5 s; ARCH-009 BITE sets FWC FAIL if POST fails) | Acceptable with POST go/no-go gate |
| HAZ-009 | SYS-003 | Output Control loses 28 VDC supply to annunciator outputs | MONITORING | Visual warning annunciators extinguished; crew has no visual warning indication | Hazardous | Remote | Acceptable | REQ-001, REQ-002 (audio warnings via AMU remain active; ARCH-009 BITE detects open-circuit in annunciator line) | Acceptable with audio backup |

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total System Components (SYS) | 3 |
| Components with ≥1 HAZ | 3 / 3 (100%) |
| Total Hazards (HAZ) | 9 |
| System-level hazards | 9 |
| Architecture-level hazards | 0 (no architecture-design.md analyzed) |

### Severity Distribution

| Severity | Count | Percentage |
|----------|-------|------------|
| Catastrophic | 4 | 44% |
| Hazardous | 2 | 22% |
| Major | 2 | 22% |
| Minor | 0 | 0% |
| No Safety Effect | 1 | 11% |

### Risk Level Distribution

| Risk Level | Count | Percentage |
|------------|-------|------------|
| Unacceptable | 0 | 0% |
| Undesirable | 0 | 0% |
| Acceptable | 9 | 100% |

## Uncovered Components

None — full coverage achieved.

## Governing Standards

| Standard | Full Name | Role in this Document |
|----------|-----------|----------------------|
| **DO-178C** | Software Considerations in Airborne Systems and Equipment Certification | Software DAL-A risk classification; MC/DC coverage requirements as risk controls |
| **ARP4761A:2023** | Guidelines and Methods for Conducting the Safety Assessment Process on Civil Airborne Systems | Primary risk management framework: FHA, FMEA, FTA methodology; severity and likelihood definitions |
