# Hazard Analysis (FMEA): Automatic Emergency Braking System (AEB)

**Feature Branch**: `automotive-adas`
**Created**: 2026-01-15
**Status**: Draft
**Source**: `tests/fixtures/golden/automotive-adas/expected-system-design.md`
**Standard**: ISO 26262 (Automotive HARA)

## Overview

This document presents the Failure Mode and Effects Analysis (FMEA) for the Automatic
Emergency Braking (AEB) system. Every system component (`SYS-NNN`) from `system-design.md`
is assessed for potential failure modes across the vehicle's operational states. Each hazard
receives a unique `HAZ-NNN` identifier and is linked to risk control measures (`REQ-NNN` /
`SYS-NNN`), enabling the traceability chain: Hazard → Mitigation → Requirement → Test Case
(Matrix H).

## ID Schema

- **Hazard ID**: `HAZ-{NNN}` — 3-digit zero-padded, sequential (HAZ-001, HAZ-002, ...)
- **ID Lineage**: From `HAZ-001`, read the Mitigation column to find `REQ-NNN` / `SYS-NNN`.

## Risk Matrix Definition

### Severity Scale

| Level | Definition |
|-------|-----------|
| Catastrophic | Death or permanent injury; complete vehicle loss of control |
| Critical | Severe injury or major vehicle damage; immediate intervention required |
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

| State | Description | Source |
|-------|------------|--------|
| PARKED | Vehicle stationary with engine off or in park | system-design.md (operating range: 0 km/h) |
| LOW_SPEED | Vehicle moving at 5–30 km/h (urban crawl, parking lots) | system-design.md (operating range: 5–200 km/h) |
| URBAN | Vehicle moving at 30–60 km/h (city driving, intersections) | system-design.md (urban pedestrian scenarios) |
| HIGHWAY | Vehicle moving at 60–200 km/h (highway, high-speed roads) | system-design.md (operating range: 5–200 km/h) |
| SENSOR_DEGRADED | One or more sensors reporting fault; system in fallback mode | system-design.md (graceful degradation) |

## Hazard Register (FMEA)

| HAZ ID | Component | Failure Mode | Operational State | Effect | Severity | Likelihood | Risk Level | Mitigation | Residual Risk |
|--------|-----------|-------------|-------------------|--------|----------|-----------|------------|------------|---------------|
| HAZ-001 | SYS-001 | Radar Processing Unit returns no detections (sensor blind) | HIGHWAY | Approaching vehicle undetected; no braking activation at high speed; rear-end collision | Catastrophic | Remote | Undesirable | REQ-001 (sensor fusion with camera fallback), SYS-005 (fault detection and degradation) | Tolerable with camera-only detection to 80 m |
| HAZ-002 | SYS-001 | Radar Processing Unit returns no detections (sensor blind) | LOW_SPEED | Approaching vehicle undetected at low speed; minor collision | Minor | Remote | Acceptable | REQ-001 (sensor fusion with camera fallback), SYS-005 (fault detection) | Acceptable with camera-only mode |
| HAZ-003 | SYS-001 | Radar Processing Unit reports ghost objects (false positives) | HIGHWAY | Unnecessary autonomous braking at highway speed; following vehicle may collide | Catastrophic | Improbable | Undesirable | REQ-NF-001 (false positive rate < 1 per 10K km), SYS-003 (fusion filtering) | Tolerable with fusion cross-validation |
| HAZ-004 | SYS-002 | Camera Processing Unit fails in low light | URBAN | Pedestrians undetected at night in urban crossing; AEB does not activate | Catastrophic | Occasional | Unacceptable | REQ-001 (daylight and nighttime detection), SYS-003 (radar backup for night scenarios) | Undesirable — radar provides partial coverage |
| HAZ-005 | SYS-002 | Camera Processing Unit misclassifies object | HIGHWAY | Overhead sign classified as vehicle; unnecessary braking on highway | Critical | Remote | Undesirable | REQ-NF-001 (false positive rate), SYS-003 (radar range/velocity cross-check) | Tolerable with multi-sensor validation |
| HAZ-006 | SYS-002 | Camera Processing Unit fails in low light | LOW_SPEED | Pedestrians undetected at low speed; collision at walking speed | Serious | Occasional | Undesirable | REQ-001 (nighttime detection), SYS-003 (radar backup) | Tolerable with radar detection |
| HAZ-007 | SYS-003 | Sensor Fusion Engine incorrect TTC computation | HIGHWAY | Braking activated too late or not at all; high-speed collision | Catastrophic | Remote | Undesirable | REQ-002 (TTC < 1.5 s threshold), SYS-005 (fusion health monitoring) | Tolerable with watchdog timer |
| HAZ-008 | SYS-003 | Sensor Fusion Engine incorrect TTC computation | URBAN | Braking activated too late; moderate-speed collision with pedestrian | Critical | Remote | Undesirable | REQ-002 (TTC threshold and warning at 2.5 s) | Tolerable with early warning |
| HAZ-009 | SYS-003 | Sensor Fusion Engine excessive false positive rate | HIGHWAY | Repeated unnecessary braking; driver disables system or following vehicle collision | Critical | Improbable | Tolerable | REQ-NF-001 (< 1 false activation per 10K km) | Acceptable with statistical filtering |
| HAZ-010 | SYS-004 | Braking Controller fails to apply brakes | HIGHWAY | Autonomous braking commanded but not executed; high-speed collision | Catastrophic | Improbable | Undesirable | REQ-002 (autonomous braking activation), SYS-005 (brake system health monitoring) | Tolerable with hydraulic backup |
| HAZ-011 | SYS-004 | Braking Controller applies unintended braking | HIGHWAY | Unexpected deceleration on highway; following vehicle may collide | Catastrophic | Improbable | Undesirable | REQ-002 (TTC-gated activation), REQ-NF-001 (false positive control) | Tolerable with driver override |
| HAZ-012 | SYS-004 | Braking Controller applies unintended braking | PARKED | Vehicle lurches while parked; minor property damage | Minor | Improbable | Acceptable | SYS-005 (operating speed gate: no AEB below 5 km/h) | Acceptable with speed gate |
| HAZ-013 | SYS-005 | Fault Manager fails to detect sensor degradation | HIGHWAY | System operates on faulty sensor data at highway speed; incorrect braking decisions | Catastrophic | Improbable | Undesirable | REQ-CN-001 (fail-safe with DTC logging), SYS-005 (watchdog timer on all subsystems) | Tolerable with hardware watchdog |
| HAZ-014 | SYS-005 | Fault Manager triggers false degradation | URBAN | AEB unnecessarily disabled in urban driving; reduced pedestrian protection | Serious | Remote | Tolerable | REQ-CN-001 (graceful degradation), REQ-IF-001 (MIL indicator to driver) | Acceptable with driver notification |
| HAZ-015 | SYS-005 | Fault Manager fails to detect sensor degradation | SENSOR_DEGRADED | Already degraded system does not further restrict; compounding failure | Critical | Improbable | Tolerable | REQ-CN-001 (multi-level degradation), SYS-005 (independent watchdog per subsystem) | Acceptable with independent monitors |

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total System Components (SYS) | 5 |
| Components with ≥1 HAZ | 5 / 5 (100%) |
| Total Hazards (HAZ) | 15 |
| System-level hazards | 15 |
| Architecture-level hazards | 0 (no architecture-design.md analyzed) |

### Severity Distribution

| Severity | Count | Percentage |
|----------|-------|------------|
| Catastrophic | 6 | 40% |
| Critical | 4 | 27% |
| Serious | 2 | 13% |
| Minor | 2 | 13% |
| Negligible | 0 | 0% |

### Risk Level Distribution

| Risk Level | Count | Percentage |
|------------|-------|------------|
| Unacceptable | 1 | 7% |
| Undesirable | 8 | 53% |
| Tolerable | 3 | 20% |
| Acceptable | 3 | 20% |

### Operational State Distribution

| State | Hazard Count |
|-------|-------------|
| HIGHWAY | 8 |
| URBAN | 3 |
| LOW_SPEED | 2 |
| PARKED | 1 |
| SENSOR_DEGRADED | 1 |

## Uncovered Components

None — full coverage achieved.

## Governing Standards

| Standard | Full Name | Role in this Document |
|----------|-----------|----------------------|
| **ISO 26262-3:2018** | Road vehicles — Functional safety — Part 3: Concept phase | HARA: hazard identification, ASIL assignment, safety goals |
| **IEC 60812:2018** | Failure modes and effects analysis (FMEA) | Systematic FMEA methodology: failure mode identification, severity classification, detectability rating |
