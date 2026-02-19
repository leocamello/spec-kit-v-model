# Acceptance Test Plan

## Test Strategy

This acceptance test plan validates all requirements defined in the Requirements Specification
for the Automatic Emergency Braking System. Each requirement has one or more test cases,
and each test case has one or more executable BDD scenarios. Testing encompasses functional
verification on a closed-track proving ground, statistical analysis of fleet telemetry data,
interface protocol validation on a hardware-in-the-loop (HIL) bench, and design inspection
per ISO 26262 ASIL-D verification requirements.

## Requirement Validations

### Requirement Validation: REQ-001 (Forward Collision Detection via Sensor Fusion)

#### Test Case: ATP-001-A (Vehicle Detection Range and Classification)
**Description:** Verify that the fused sensor system detects and classifies vehicles at distances up to 200 meters in daylight and nighttime conditions.

* **User Scenario: SCN-001-A1**
  * **Given** the ego vehicle is traveling at 100 km/h on a closed test track with a stationary target vehicle (Euro NCAP soft target) positioned 200 meters ahead
  * **When** the AEB system processes fused radar and camera data
  * **Then** the system detects and classifies the target as a vehicle at a distance of at least 200 meters in both daylight and nighttime test runs

#### Test Case: ATP-001-B (Pedestrian Detection Range)
**Description:** Verify that the fused sensor system detects pedestrians at distances up to 80 meters.

* **User Scenario: SCN-001-B1**
  * **Given** the ego vehicle is traveling at 40 km/h in an urban test environment with a pedestrian dummy positioned 80 meters ahead crossing the vehicle's path
  * **When** the AEB system processes fused radar and camera data
  * **Then** the system detects and classifies the target as a pedestrian at a distance of at least 80 meters

### Requirement Validation: REQ-002 (Autonomous Emergency Braking Activation)

#### Test Case: ATP-002-A (Forward Collision Warning at TTC < 2.5s)
**Description:** Verify that a visual and audible forward collision warning is issued when TTC drops below 2.5 seconds.

* **User Scenario: SCN-002-A1**
  * **Given** the ego vehicle is approaching a stationary target vehicle at 60 km/h with no driver braking input
  * **When** the computed Time-to-Collision falls below 2.5 seconds
  * **Then** the system issues a visual warning on the instrument cluster and an audible alert through the vehicle speakers before autonomous braking is applied

#### Test Case: ATP-002-B (Autonomous Braking at TTC < 1.5s)
**Description:** Verify that maximum autonomous braking is applied when TTC drops below 1.5 seconds without driver intervention.

* **User Scenario: SCN-002-B1**
  * **Given** the ego vehicle is approaching a stationary target vehicle at 60 km/h and no driver braking or steering input is detected
  * **When** the computed Time-to-Collision falls below 1.5 seconds
  * **Then** the system applies maximum braking force autonomously and reduces vehicle speed to avoid or mitigate the collision

### Requirement Validation: REQ-NF-001 (False Positive Activation Rate)

#### Test Case: ATP-NF-001-A (Fleet False Positive Rate Analysis)
**Description:** Verify that the false positive autonomous braking rate is fewer than 1 event per 10,000 km across mixed driving conditions.

* **User Scenario: SCN-NF-001-A1**
  * **Given** telemetry data collected from a fleet of at least 50 test vehicles over a combined distance of at least 500,000 km in mixed urban and highway traffic conditions
  * **When** the total number of false positive autonomous braking activations is counted and divided by total fleet kilometers driven
  * **Then** the computed false positive rate is fewer than 1 event per 10,000 km

### Requirement Validation: REQ-IF-001 (Sensor Fusion Data Interface)

#### Test Case: ATP-IF-001-A (Radar CAN-FD Interface Validation)
**Description:** Verify that radar target lists are received via CAN-FD at a minimum update rate of 20 Hz.

* **User Scenario: SCN-IF-001-A1**
  * **Given** the AEB fusion ECU is connected to the 77 GHz radar module via a CAN-FD bus on a hardware-in-the-loop (HIL) bench
  * **When** the radar module transmits target list messages for 60 seconds
  * **Then** the fusion ECU receives valid radar target list frames at an average rate of at least 20 Hz with no bus-off errors or frame loss

#### Test Case: ATP-IF-001-B (Camera Ethernet Interface Validation)
**Description:** Verify that camera object classifications are received via Ethernet at a minimum update rate of 15 Hz.

* **User Scenario: SCN-IF-001-B1**
  * **Given** the AEB fusion ECU is connected to the stereo camera ECU via 100BASE-T1 automotive Ethernet on a HIL bench
  * **When** the camera ECU transmits object classification messages for 60 seconds
  * **Then** the fusion ECU receives valid classification frames at an average rate of at least 15 Hz with no packet loss

### Requirement Validation: REQ-CN-001 (Fail-Safe Graceful Degradation)

#### Test Case: ATP-CN-001-A (Sensor Fault Detection and AEB Disablement)
**Description:** Verify that the system disables AEB, displays a malfunction indicator, and logs a DTC when a sensor fault is detected.

* **User Scenario: SCN-CN-001-A1**
  * **Given** the AEB system is operating normally with both radar and camera sensors functional
  * **When** a simulated hardware fault is injected into the radar module (e.g., communication timeout)
  * **Then** the system disables the AEB function within 100 milliseconds, illuminates the malfunction indicator lamp (MIL) on the instrument cluster, and stores a diagnostic trouble code (DTC) in the ECU fault memory

#### Test Case: ATP-CN-001-B (Prevention of Braking on Faulted Sensor Data)
**Description:** Verify that the system does not apply autonomous braking when operating with a single faulted sensor.

* **User Scenario: SCN-CN-001-B1**
  * **Given** the camera subsystem has reported a fault and the AEB function is in degraded mode
  * **When** the radar-only data indicates a potential collision with TTC below 1.5 seconds
  * **Then** the system does NOT apply autonomous braking and the malfunction indicator remains illuminated

## Coverage Summary

| Requirement | Test Cases | Scenarios | Status |
|-------------|-----------|-----------|--------|
| REQ-001 | 2 (ATP-001-A, ATP-001-B) | 2 (SCN-001-A1, SCN-001-B1) | ⬜ Untested |
| REQ-002 | 2 (ATP-002-A, ATP-002-B) | 2 (SCN-002-A1, SCN-002-B1) | ⬜ Untested |
| REQ-NF-001 | 1 (ATP-NF-001-A) | 1 (SCN-NF-001-A1) | ⬜ Untested |
| REQ-IF-001 | 2 (ATP-IF-001-A, ATP-IF-001-B) | 2 (SCN-IF-001-A1, SCN-IF-001-B1) | ⬜ Untested |
| REQ-CN-001 | 2 (ATP-CN-001-A, ATP-CN-001-B) | 2 (SCN-CN-001-A1, SCN-CN-001-B1) | ⬜ Untested |

**Coverage: 100%** — All 5 requirements have test cases and scenarios.
