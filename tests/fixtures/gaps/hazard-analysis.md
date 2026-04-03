# Hazard Analysis (FMEA): Gaps Fixture

**Feature Branch**: `gaps-fixture`
**Created**: 2026-01-15
**Status**: Draft
**Source**: `tests/fixtures/gaps/system-design.md`
**Standard**: General-Purpose FMEA

## Overview

This document presents the Failure Mode and Effects Analysis (FMEA) for the Gaps Fixture
access control system. This fixture intentionally contains traceability gaps for testing
the validate-hazard-coverage script.

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
| NORMAL | Standard operational state | Implicit |
| LOCKDOWN | Emergency lockdown mode with restricted access | Implicit |

## Hazard Register (FMEA)

<!-- GAP 1 (Forward): Access Control has NO hazard entries — forward coverage gap -->
<!-- GAP 2 (Backward): HAZ-002 references REQ-099 which does not exist in requirements.md -->
<!-- GAP 3 (State): HAZ-003 references EMERGENCY state not defined in Operational States -->

| HAZ ID | Component | Failure Mode | Operational State | Effect | Severity | Likelihood | Risk Level | Mitigation | Residual Risk |
|--------|-----------|-------------|-------------------|--------|----------|-----------|------------|------------|---------------|
| HAZ-001 | SYS-001 | Auth Service fails to authenticate valid user | NORMAL | Legitimate users locked out of system | Serious | Remote | Tolerable | REQ-001 (user authentication with retry logic) | Acceptable with retry mechanism |
| HAZ-002 | SYS-001 | Auth Service accepts invalid credentials | LOCKDOWN | Unauthorized access during security event; data breach potential | Catastrophic | Remote | Undesirable | REQ-099 (credential validation) | Tolerable with multi-factor auth |
| HAZ-003 | SYS-001 | Auth Service response time exceeds SLA | EMERGENCY | Authentication queue builds up; cascading timeout failures | Critical | Occasional | Undesirable | REQ-001 (authentication performance) | Tolerable with request throttling |

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total System Components (SYS) | 2 |
| Components with ≥1 HAZ | 1 / 2 (50%) |
| Total Hazards (HAZ) | 3 |
| System-level hazards | 3 |
| Architecture-level hazards | 0 |

### Severity Distribution

| Severity | Count | Percentage |
|----------|-------|------------|
| Catastrophic | 1 | 33% |
| Critical | 1 | 33% |
| Serious | 1 | 33% |
| Minor | 0 | 0% |
| Negligible | 0 | 0% |

### Risk Level Distribution

| Risk Level | Count | Percentage |
|------------|-------|------------|
| Unacceptable | 0 | 0% |
| Undesirable | 2 | 67% |
| Tolerable | 1 | 33% |
| Acceptable | 0 | 0% |

### Operational State Distribution

| State | Hazard Count |
|-------|-------------|
| NORMAL | 1 |
| LOCKDOWN | 1 |
| EMERGENCY | 1 |

## Uncovered Components

- Access Control component (second system component): No hazard analysis mapping found
