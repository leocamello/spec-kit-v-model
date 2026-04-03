# Hazard Analysis (FMEA): Minimal Fixture

**Feature Branch**: `minimal-fixture`
**Created**: 2026-01-15
**Status**: Draft
**Source**: `tests/fixtures/minimal/system-design.md`
**Standard**: General-Purpose FMEA

## Overview

This document presents the Failure Mode and Effects Analysis (FMEA) for the Minimal Fixture
sensor monitoring system. Every system component (`SYS-NNN`) from `system-design.md` is
assessed for potential failure modes. Each hazard receives a unique `HAZ-NNN` identifier and
is linked to risk control measures, enabling the traceability chain: Hazard → Mitigation →
Requirement → Test Case (Matrix H).

## ID Schema

- **Hazard ID**: `HAZ-{NNN}` — 3-digit zero-padded, sequential (HAZ-001, HAZ-002, ...)
- **ID Lineage**: From `HAZ-001`, read the Mitigation column to find `REQ-NNN` / `SYS-NNN`.

## Risk Matrix Definition

### Severity Scale

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

| State | Description | Source |
|-------|------------|--------|
| NORMAL | Implicit default state (no operational states defined in system-design.md) | Implicit |

⚠️ No operational states defined in system-design.md — using implicit NORMAL state.

## Hazard Register (FMEA)

| HAZ ID | Component | Failure Mode | Operational State | Effect | Severity | Likelihood | Risk Level | Mitigation | Residual Risk |
|--------|-----------|-------------|-------------------|--------|----------|-----------|------------|------------|---------------|
| HAZ-001 | SYS-001 | Data Processor returns corrupted sensor readings | NORMAL | Alert Engine generates false alerts from invalid data; Display Renderer shows incorrect status | Serious | Occasional | Undesirable | REQ-001 (sensor data processing validation) | Tolerable with input validation |
| HAZ-002 | SYS-001 | Data Processor becomes unresponsive | NORMAL | Alert Engine cannot generate alerts; Display Renderer shows stale status | Critical | Remote | Undesirable | SYS-002 (Alert Engine detects upstream timeout) | Tolerable with heartbeat monitoring |
| HAZ-003 | SYS-002 | Alert Engine fails to detect threshold breach | NORMAL | Critical condition goes unnotified; operator unaware of hazardous state | Critical | Remote | Undesirable | REQ-002 (alert generation with redundant threshold check) | Tolerable with redundant check |
| HAZ-004 | SYS-002 | Alert Engine generates spurious alerts | NORMAL | Operator alert fatigue; genuine alerts ignored | Minor | Occasional | Tolerable | REQ-002 (alert suppression for below-threshold values) | Acceptable with suppression logic |
| HAZ-005 | SYS-003 | Display Renderer fails to update status | NORMAL | Operator sees stale information; delayed awareness of system state changes | Minor | Remote | Acceptable | REQ-003 (status display with staleness indicator) | Acceptable with staleness warning |

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total System Components (SYS) | 3 |
| Components with ≥1 HAZ | 3 / 3 (100%) |
| Total Hazards (HAZ) | 5 |
| System-level hazards | 5 |
| Architecture-level hazards | 0 (no architecture-design.md) |

### Severity Distribution

| Severity | Count | Percentage |
|----------|-------|------------|
| Catastrophic | 0 | 0% |
| Critical | 2 | 40% |
| Serious | 1 | 20% |
| Minor | 2 | 40% |
| Negligible | 0 | 0% |

### Risk Level Distribution

| Risk Level | Count | Percentage |
|------------|-------|------------|
| Unacceptable | 0 | 0% |
| Undesirable | 3 | 60% |
| Tolerable | 1 | 20% |
| Acceptable | 1 | 20% |

### Operational State Distribution

| State | Hazard Count |
|-------|-------------|
| NORMAL | 5 |

## Uncovered Components

None — full coverage achieved.
