# Hazard Analysis (FMEA): Continuous Blood Glucose Monitoring System (CBGMS)

**Feature Branch**: `medical-device`
**Created**: 2026-01-15
**Status**: Draft
**Source**: `tests/fixtures/golden/medical-device/expected-system-design.md`
**Standard**: ISO 14971 (Medical Risk Management)

## Overview

This document presents the Failure Mode and Effects Analysis (FMEA) for the Continuous Blood
Glucose Monitoring System. Every system component (`SYS-NNN`) from `system-design.md` is
assessed for potential failure modes across the device's operational states. Each hazard
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
| Catastrophic | Death or permanent injury; patient death from undetected hypoglycemia |
| Critical | Severe injury; hypoglycemic seizure or diabetic ketoacidosis requiring hospitalization |
| Serious | Moderate injury; prolonged hypo/hyperglycemia requiring medical attention |
| Minor | Slight injury or discomfort; delayed awareness of glucose trend |
| Negligible | No injury; inconvenience or cosmetic issue only |

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
| MONITORING | Normal continuous glucose monitoring; sensor active, BLE connected | system-design.md (core monitoring function) |
| SENSOR_WARMUP | Initial calibration period after sensor insertion (typically 1–2 hours) | system-design.md (sensor interface startup) |
| BLE_DISCONNECTED | Bluetooth link lost; transmitter buffering locally; no companion app display | system-design.md (BLE auto-reconnect within 30 s) |
| LOW_BATTERY | Transmitter battery below threshold; reduced sampling or imminent shutdown | system-design.md (transmitter power management) |

## Hazard Register (FMEA)

| HAZ ID | Component | Failure Mode | Operational State | Effect | Severity | Likelihood | Risk Level | Mitigation | Residual Risk |
|--------|-----------|-------------|-------------------|--------|----------|-----------|------------|------------|---------------|
| HAZ-001 | SYS-001 | Glucose Sensor Interface returns no reading (sensor fault) | MONITORING | No glucose data for alert evaluation; patient unaware of dangerous glucose level | Catastrophic | Remote | Undesirable | REQ-001 (5-min sampling with fault detection), SYS-003 (stale-data alarm after 10 min) | Tolerable with stale-data alarm |
| HAZ-002 | SYS-001 | Glucose Sensor Interface returns no reading | SENSOR_WARMUP | Expected behavior during warmup; no clinical impact if warmup period is communicated | Negligible | Frequent | Tolerable | REQ-001 (warmup period notification to user) | Acceptable with user notification |
| HAZ-003 | SYS-002 | Signal Processing Engine outputs inaccurate calibrated value | MONITORING | Patient receives incorrect glucose reading; insulin dosing error possible | Catastrophic | Remote | Undesirable | REQ-NF-001 (±15% / ±15 mg/dL accuracy), SYS-002 (calibration curve validation) | Tolerable with redundant calibration check |
| HAZ-004 | SYS-002 | Signal Processing Engine outputs inaccurate calibrated value | LOW_BATTERY | Degraded signal quality from reduced sampling compounds calibration error | Critical | Remote | Undesirable | REQ-NF-001 (accuracy bounds), SYS-001 (low-battery sampling reduction notice) | Tolerable with reduced-confidence indicator |
| HAZ-005 | SYS-003 | Alert Manager fails to trigger hypoglycemia alarm | MONITORING | Patient not warned of dangerously low glucose; risk of seizure or loss of consciousness | Catastrophic | Improbable | Undesirable | REQ-002 (audible and haptic alarms with escalation to emergency contact) | Tolerable with SMS escalation backup |
| HAZ-006 | SYS-003 | Alert Manager fails to trigger hypoglycemia alarm | BLE_DISCONNECTED | Alarm cannot reach companion app; on-device alarm is only notification channel | Critical | Occasional | Undesirable | REQ-002 (on-device audible alarm independent of BLE), SYS-004 (BLE reconnect within 30 s) | Tolerable with on-device alarm |
| HAZ-007 | SYS-003 | Alert Manager triggers false alarm (spurious hypoglycemia alert) | MONITORING | Patient takes unnecessary corrective action (glucose intake); hyperglycemia risk | Serious | Remote | Tolerable | REQ-002 (configurable thresholds 55–400 mg/dL), SYS-002 (signal validation) | Acceptable with trend confirmation |
| HAZ-008 | SYS-004 | BLE Communication Module loses connection | MONITORING | Glucose readings not delivered to companion app; delayed visibility for patient | Serious | Occasional | Undesirable | REQ-IF-001 (30-second auto-reconnect), SYS-005 (local buffering on transmitter) | Tolerable with local buffer and reconnect |
| HAZ-009 | SYS-004 | BLE Communication Module loses connection | LOW_BATTERY | Connection loss more likely with degraded power; extended data gap on companion app | Critical | Occasional | Undesirable | REQ-IF-001 (auto-reconnect), SYS-003 (on-device alarm fallback) | Tolerable with on-device alarm |
| HAZ-010 | SYS-005 | Data Storage Manager loses glucose history | MONITORING | 90-day history unavailable for clinical review; treatment decisions lack longitudinal data | Serious | Remote | Tolerable | REQ-CN-001 (90-day rolling retention with backup), SYS-004 (cloud sync via companion app) | Acceptable with cloud backup |
| HAZ-011 | SYS-005 | Data Storage Manager corrupts exported CSV/PDF | MONITORING | Clinician receives incorrect data in export file; potential for wrong treatment decision | Critical | Improbable | Tolerable | REQ-CN-001 (CSV/PDF export with checksum validation) | Acceptable with export validation |
| HAZ-012 | SYS-005 | Data Storage Manager loses glucose history | BLE_DISCONNECTED | Local buffer on transmitter is the only copy; if transmitter also fails, data is lost permanently | Serious | Remote | Tolerable | SYS-005 (dual storage: transmitter + companion app), REQ-CN-001 (90-day retention) | Acceptable with dual storage |

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total System Components (SYS) | 5 |
| Components with ≥1 HAZ | 5 / 5 (100%) |
| Total Hazards (HAZ) | 12 |
| System-level hazards | 12 |
| Architecture-level hazards | 0 (no architecture-design.md analyzed) |

### Severity Distribution

| Severity | Count | Percentage |
|----------|-------|------------|
| Catastrophic | 3 | 25% |
| Critical | 4 | 33% |
| Serious | 4 | 33% |
| Minor | 0 | 0% |
| Negligible | 1 | 8% |

### Risk Level Distribution

| Risk Level | Count | Percentage |
|------------|-------|------------|
| Unacceptable | 0 | 0% |
| Undesirable | 7 | 58% |
| Tolerable | 5 | 42% |
| Acceptable | 0 | 0% |

### Operational State Distribution

| State | Hazard Count |
|-------|-------------|
| MONITORING | 7 |
| BLE_DISCONNECTED | 2 |
| LOW_BATTERY | 2 |
| SENSOR_WARMUP | 1 |

## Uncovered Components

None — full coverage achieved.

## Governing Standards

| Standard | Full Name | Role in this Document |
|----------|-----------|----------------------|
| **ISO 14971:2019** | Application of risk management to medical devices | Primary risk management framework: hazard identification, risk estimation, risk evaluation, risk control |
| **IEC 62304:2006/AMD1:2015** | Medical device software — Software life cycle processes | Software safety classification and risk management integration |
