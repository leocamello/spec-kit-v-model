# Requirements Specification

## Document Control

| Field | Value |
|-------|-------|
| Feature | Flight Warning Computer (FWC) |
| Version | 1.0 |
| Status | Approved |

## Requirements

### Functional Requirements

#### REQ-001: Overspeed Warning
**Description:** The FWC SHALL monitor indicated airspeed from the ADIRU and SHALL activate an audible "OVERSPEED, OVERSPEED" voice alert via the Audio Management Unit and illuminate the OVERSPEED visual annunciator within 500 ms when indicated airspeed exceeds VMO/MMO.
**Priority:** P1
**Rationale:** Overspeed exceedance can cause structural damage or loss of control. DO-178C DAL-A classification mandates timely warning generation; failure to alert is classified as a catastrophic failure condition under ARP4761A.
**Verification Method:** Test

#### REQ-002: Stall Warning
**Description:** The FWC SHALL monitor angle of attack from the ADIRU and SHALL activate the stick shaker actuator within 200 ms when the angle of attack exceeds the stall warning threshold (1.2 Vs equivalent AoA) and airspeed is valid.
**Priority:** P1
**Rationale:** Stall warning provides the flight crew with a critical tactile cue to prevent departure from controlled flight. Stick shaker activation is the primary stall prevention mechanism mandated by FAR 25.207 and CS 25.207.
**Verification Method:** Test

### Non-Functional Requirements

#### REQ-NF-001: Warning Latency
**Description:** The FWC SHALL generate all DAL-A warning outputs (overspeed, stall, altitude alert, GPWS, attitude limit) within 500 ms of the ADIRU input data indicating a threshold exceedance. Stall warning SHALL be generated within 200 ms.
**Priority:** P1
**Rationale:** Warning latency directly determines pilot response time. ARINC 429 input processing, threshold evaluation, and output activation must all complete within the specified budget to meet airworthiness certification requirements.
**Verification Method:** Test

#### Quality Characteristics Coverage (ISO/IEC 25010:2023)

| Quality Characteristic | Relevant Requirements | Notes |
|------------------------|----------------------|-------|
| Reliability | REQ-NF-001, REQ-001, REQ-002 | MC/DC structural coverage, DAL-A independence |
| Performance Efficiency | REQ-NF-001 | 500 ms end-to-end latency budget for all warnings |
| Safety | REQ-001, REQ-002 | DO-178C DAL-A; catastrophic failure condition classification |
| Maintainability | REQ-IF-001 | BITE interface provides fault isolation and maintenance reporting |

### Interface Requirements

#### REQ-IF-001: ARINC 429 Input Validation
**Description:** The FWC SHALL validate all ARINC 429 input labels from the ADIRU and radio altimeter for data freshness (label age ≤ 150 ms) and SHALL treat inputs with No Computed Data (NCD) flags as invalid, activating the appropriate sensor failure annunciator.
**Priority:** P1
**Rationale:** Use of stale or invalid sensor data in warning logic can cause either missed warnings (catastrophic) or spurious warnings (hazardous). DO-178C requires defensive input validation for all DAL-A warning functions.
**Verification Method:** Test

### Constraint Requirements

#### REQ-CN-001: DO-178C DAL-A Compliance
**Description:** The FWC software SHALL be developed in accordance with DO-178C for all warning generation software items, achieving Modified Condition/Decision Coverage (MC/DC) structural coverage, and an independently reviewed Software Quality Assurance Plan (SQAP).
**Priority:** P1
**Rationale:** FAR/CS 25.1301 and FAR/CS 25.1309 require that avionics software developed for catastrophic failure conditions meet DO-178C DAL-A. This constraint governs the entire software development lifecycle.
**Verification Method:** Inspection

## Summary

| Category | Count |
|----------|-------|
| Functional | 2 |
| Non-Functional | 1 |
| Interface | 1 |
| Constraint | 1 |
| **Total** | **5** |

## Governing Standards

| Standard | Scope | How Used |
|---|---|---|
| **IEEE 29148:2018** | Requirements engineering processes | Primary framework for requirement types, quality criteria, and traceability |
| **ISO/IEC 25010:2023** | Systems and software quality models | Quality characteristics taxonomy for non-functional requirements |
| **DO-178C** | Software Considerations in Airborne Systems and Equipment Certification | DAL-A software development and verification process requirements |
