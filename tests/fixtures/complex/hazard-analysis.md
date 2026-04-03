# Hazard Analysis (FMEA): Complex Fixture

**Feature Branch**: `complex-fixture`
**Created**: 2026-01-15
**Status**: Draft
**Source**: `tests/fixtures/complex/system-design.md`
**Standard**: General-Purpose FMEA

## Overview

This document presents the Failure Mode and Effects Analysis (FMEA) for the Complex Fixture
data platform. Every system component (`SYS-NNN`) from `system-design.md` is assessed for
potential failure modes across defined operational states. Each hazard receives a unique
`HAZ-NNN` identifier and is linked to risk control measures.

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
| NORMAL | Standard operation with all data sources connected | Implicit |
| DEGRADED | One or more data sources unavailable; system operates on partial data | Implicit |
| MAINTENANCE | System undergoing planned maintenance; reduced functionality | Implicit |

## Hazard Register (FMEA)

| HAZ ID | Component | Failure Mode | Operational State | Effect | Severity | Likelihood | Risk Level | Mitigation | Residual Risk |
|--------|-----------|-------------|-------------------|--------|----------|-----------|------------|------------|---------------|
| HAZ-001 | SYS-001 | Data Ingestion Service drops incoming MQTT messages | NORMAL | Sensor readings lost; downstream aggregations incomplete | Serious | Occasional | Undesirable | REQ-001 (reliable ingestion), REQ-IF-001 (MQTT QoS) | Tolerable with QoS 1 acknowledgement |
| HAZ-002 | SYS-001 | Data Ingestion Service drops incoming MQTT messages | DEGRADED | Already partial data; additional loss compounds data gaps | Critical | Probable | Unacceptable | REQ-001 (reliable ingestion), SYS-004 (buffered storage) | Undesirable with buffered replay |
| HAZ-003 | SYS-002 | Data Validator accepts corrupted data | NORMAL | Invalid data propagates to aggregation and storage; incorrect analytics | Serious | Remote | Tolerable | REQ-002 (data integrity validation) | Acceptable with schema validation |
| HAZ-004 | SYS-002 | Data Validator rejects valid data (false negative) | NORMAL | Valid sensor readings discarded; data loss without corruption | Minor | Remote | Acceptable | REQ-002 (configurable validation thresholds) | Acceptable with threshold tuning |
| HAZ-005 | SYS-003 | Aggregation Engine computes incorrect aggregation | NORMAL | Downstream consumers receive incorrect analytics; wrong business decisions | Serious | Occasional | Undesirable | REQ-003 (real-time aggregation with checksums) | Tolerable with cross-validation |
| HAZ-006 | SYS-003 | Aggregation Engine exceeds latency threshold | NORMAL | Stale aggregations served; real-time dashboards show outdated data | Minor | Probable | Tolerable | REQ-NF-001 (10K events/second throughput) | Acceptable with backpressure |
| HAZ-007 | SYS-004 | Storage Manager loses data during write | NORMAL | Persisted dataset incomplete; historical queries return partial results | Critical | Remote | Undesirable | REQ-004 (durable persistence), REQ-NF-002 (AES-256 encryption) | Tolerable with write-ahead log |
| HAZ-008 | SYS-004 | Storage Manager encryption key compromised | MAINTENANCE | All stored data exposed; regulatory compliance violation | Catastrophic | Improbable | Undesirable | REQ-NF-002 (AES-256 at rest), REQ-CN-001 (open-source audit) | Tolerable with key rotation |
| HAZ-009 | SYS-005 | REST API Gateway returns incorrect query results | NORMAL | External consumers receive wrong data; trust in system degraded | Serious | Remote | Tolerable | REQ-005 (query API with result validation) | Acceptable with response checksums |
| HAZ-010 | SYS-005 | REST API Gateway becomes unresponsive | DEGRADED | External consumers cannot query data; operational blind spot | Critical | Occasional | Undesirable | REQ-005 (API availability), SYS-006 (health metrics) | Tolerable with circuit breaker |
| HAZ-011 | SYS-006 | Metrics Exporter reports stale metrics | NORMAL | Monitoring dashboards show incorrect system health; delayed incident response | Minor | Occasional | Tolerable | REQ-IF-002 (Prometheus endpoint freshness) | Acceptable with staleness indicator |
| HAZ-012 | SYS-006 | Metrics Exporter exposes sensitive data in metrics | MAINTENANCE | Internal system details leaked via Prometheus scrape | Minor | Improbable | Acceptable | REQ-IF-002 (metric filtering), REQ-CN-001 (security audit) | Acceptable with metric allow-list |

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total System Components (SYS) | 6 |
| Components with ≥1 HAZ | 6 / 6 (100%) |
| Total Hazards (HAZ) | 12 |
| System-level hazards | 12 |
| Architecture-level hazards | 0 (no progressive deepening) |

### Severity Distribution

| Severity | Count | Percentage |
|----------|-------|------------|
| Catastrophic | 1 | 8% |
| Critical | 3 | 25% |
| Serious | 4 | 33% |
| Minor | 4 | 33% |
| Negligible | 0 | 0% |

### Risk Level Distribution

| Risk Level | Count | Percentage |
|------------|-------|------------|
| Unacceptable | 1 | 8% |
| Undesirable | 4 | 33% |
| Tolerable | 4 | 33% |
| Acceptable | 3 | 25% |

### Operational State Distribution

| State | Hazard Count |
|-------|-------------|
| NORMAL | 9 |
| DEGRADED | 2 |
| MAINTENANCE | 1 |

## Uncovered Components

None — full coverage achieved.
