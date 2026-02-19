# Requirements Specification

## Document Control

| Field | Value |
|-------|-------|
| Feature | Automatic Emergency Braking System |
| Version | 1.0 |
| Status | Approved |

## Requirements

### Functional Requirements

#### REQ-001: Forward Collision Detection via Sensor Fusion
**Description:** The system SHALL continuously fuse data from the 77 GHz long-range radar and the forward-facing stereo camera to detect and classify vehicles at distances up to 200 meters and pedestrians at distances up to 80 meters in both daylight and nighttime conditions.
**Priority:** P1
**Rationale:** Accurate, redundant object detection is the foundational perception capability required for collision avoidance. Multi-sensor fusion provides robustness against individual sensor limitations (e.g., camera degradation in low light, radar ambiguity in classifying pedestrians). ISO 26262 ASIL-D mandates redundant sensing for safety-critical functions.
**Verification Method:** Test

#### REQ-002: Autonomous Emergency Braking Activation
**Description:** The system SHALL apply maximum autonomous braking force when the computed Time-to-Collision (TTC) with a detected obstacle falls below 1.5 seconds and no driver braking or evasive maneuver has been detected, and SHALL issue a forward collision warning (visual and audible) when TTC falls below 2.5 seconds.
**Priority:** P1
**Rationale:** Autonomous braking is the primary safety intervention that prevents or mitigates frontal collisions. The tiered response (warning at TTC < 2.5 s, braking at TTC < 1.5 s) gives the driver opportunity to respond before the system intervenes. Activation thresholds are derived from Euro NCAP AEB test protocols and ISO 26262 functional safety requirements for ASIL-D.
**Verification Method:** Test

### Non-Functional Requirements

#### REQ-NF-001: False Positive Activation Rate
**Description:** The system SHALL maintain a false positive autonomous braking activation rate of fewer than 1 event per 10,000 km of driving under mixed urban and highway traffic conditions.
**Priority:** P1
**Rationale:** Excessive false activations erode driver trust, may cause rear-end collisions from unexpected deceleration, and constitute a safety hazard. This threshold aligns with industry benchmarks for production AEB systems and is required for ISO 26262 ASIL-D hazard analysis acceptance criteria.
**Verification Method:** Analysis

### Interface Requirements

#### REQ-IF-001: Sensor Fusion Data Interface
**Description:** The system SHALL receive radar target lists from the 77 GHz radar module via a dedicated CAN-FD bus at a minimum update rate of 20 Hz, and SHALL receive camera object classifications from the stereo camera ECU via Ethernet (100BASE-T1) at a minimum update rate of 15 Hz.
**Priority:** P1
**Rationale:** Well-defined, high-bandwidth interfaces between perception sensors and the fusion ECU are essential for real-time object detection. CAN-FD and automotive Ethernet are standard in-vehicle communication protocols. Minimum update rates ensure the fusion algorithm receives sufficiently fresh data for accurate TTC computation. ISO 26262 Part 6 requires specified communication interfaces for ASIL-D software elements.
**Verification Method:** Test

### Constraint Requirements

#### REQ-CN-001: Fail-Safe Graceful Degradation
**Description:** The system MUST disable the AEB function, display a malfunction indicator on the instrument cluster, and store a diagnostic trouble code (DTC) if the radar or camera subsystem reports a fault or degraded performance, and MUST NOT apply autonomous braking based on data from a single faulted sensor.
**Priority:** P1
**Rationale:** ISO 26262 Part 4 requires that ASIL-D systems transition to a safe state upon detection of a dangerous failure. Autonomous braking based on unreliable sensor data could cause unintended vehicle deceleration, creating a hazard. The fail-safe strategy ensures the system does not act on compromised data and that the driver is informed of reduced functionality.
**Verification Method:** Inspection

## Summary

| Category | Count |
|----------|-------|
| Functional | 2 |
| Non-Functional | 1 |
| Interface | 1 |
| Constraint | 1 |
| **Total** | **5** |
