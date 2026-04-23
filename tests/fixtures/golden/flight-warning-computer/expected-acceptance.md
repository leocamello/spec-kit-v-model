# Acceptance Test Plan

## Test Strategy

This acceptance test plan validates all requirements defined in the Requirements Specification
for the Flight Warning Computer. Each requirement has one or more test cases, and each test
case has one or more executable BDD scenarios. Testing encompasses functional warning
activation verification, latency measurement, ARINC 429 input validation, and DO-178C
compliance inspection per FAR 25.207, CS 25.1309, and DO-178C DAL-A obligations.

## Requirement Validations

### Requirement Validation: REQ-001 (Overspeed Warning)

#### Test Case: ATP-001-A (Overspeed Audio Alert Activation)
**Description:** Verify that the FWC activates the "OVERSPEED, OVERSPEED" voice alert within 500 ms when airspeed exceeds VMO.

* **User Scenario: SCN-001-A1#**
  * **Given** the FWC is in normal monitoring mode with valid ADIRU data
  * **When** the ADIRU provides an indicated airspeed equal to VMO + 2 kt
  * **Then** the Audio Management Unit receives the OVERSPEED voice alert command within 500 ms
  * **And** the OVERSPEED visual annunciator is illuminated on the centralized warning panel

#### Test Case: ATP-001-B (Overspeed Warning Inhibit Below Minimum Speed)
**Description:** Verify that the overspeed warning is not activated below the minimum monitoring airspeed of 60 kt.

* **User Scenario: SCN-001-B1#**
  * **Given** the FWC is in ground mode with airspeed below 60 kt
  * **When** the ADIRU provides an indicated airspeed of 55 kt with VMO flag not applicable
  * **Then** no overspeed warning is generated and no audio alert is issued

#### Test Case: ATP-001-C (Overspeed Persistence)
**Description:** Verify that the overspeed warning remains active as long as the exceedance condition persists.

* **User Scenario: SCN-001-C1#**
  * **Given** an overspeed warning is active with airspeed at VMO + 5 kt
  * **When** airspeed remains above VMO continuously for 10 seconds
  * **Then** the voice alert repeats at 3-second intervals and the annunciator remains illuminated

### Requirement Validation: REQ-002 (Stall Warning)

#### Test Case: ATP-002-A (Stick Shaker Activation)
**Description:** Verify that the stick shaker is activated within 200 ms when AoA exceeds the stall warning threshold.

* **User Scenario: SCN-002-A1#**
  * **Given** the FWC is in flight phase with valid AoA data from the ADIRU
  * **When** the ADIRU provides an AoA reading of 1.2 Vs equivalent AoA + 0.5 degrees
  * **Then** the stick shaker actuator control signal is asserted within 200 ms

#### Test Case: ATP-002-B (Stall Warning with Invalid AoA)
**Description:** Verify that stall warning is inhibited when AoA data is flagged as NCD.

* **User Scenario: SCN-002-B1#**
  * **Given** the FWC is in flight phase with the left ADIRU AoA label flagged as No Computed Data
  * **When** the right ADIRU also provides NCD-flagged AoA data
  * **Then** stick shaker activation is inhibited and the AoA SENSOR FAIL annunciator is illuminated

#### Test Case: ATP-002-C (Stall Warning AoA Boundary)
**Description:** Verify correct stall warning behavior at the exact threshold boundary.

* **User Scenario: SCN-002-C1#**
  * **Given** the FWC is in flight phase with valid AoA data
  * **When** AoA is exactly at the stall warning threshold value (1.2 Vs equivalent)
  * **Then** stick shaker is not activated because the threshold has not been exceeded

* **User Scenario: SCN-002-C2#**
  * **Given** the FWC is in flight phase with valid AoA data
  * **When** AoA is 0.1 degrees above the stall warning threshold
  * **Then** the stick shaker is activated within 200 ms

### Requirement Validation: REQ-NF-001 (Warning Latency)

#### Test Case: ATP-NF-001-A (End-to-End Latency Measurement)
**Description:** Verify end-to-end latency from ADIRU input to warning output for all five warning functions.

* **User Scenario: SCN-NF-001-A1#**
  * **Given** the FWC test bench is equipped with calibrated ARINC 429 signal injection and output timing measurement
  * **When** an overspeed threshold exceedance is injected on the ADIRU ARINC 429 bus
  * **Then** the Audio Management Unit receives the alert command within 500 ms measured from injection timestamp

### Requirement Validation: REQ-IF-001 (ARINC 429 Input Validation)

#### Test Case: ATP-IF-001-A (Stale Data Detection)
**Description:** Verify that the FWC detects and rejects ARINC 429 labels older than 150 ms.

* **User Scenario: SCN-IF-001-A1#**
  * **Given** the FWC is receiving valid ADIRU data with correct label refresh rate
  * **When** the ADIRU stops transmitting airspeed labels for 200 ms
  * **Then** the FWC flags the airspeed input as stale, inhibits overspeed logic, and illuminates the ADIRU FAIL annunciator

#### Test Case: ATP-IF-001-B (NCD Flag Handling)
**Description:** Verify that No Computed Data flags cause warning inhibit and sensor failure indication.

* **User Scenario: SCN-IF-001-B1#**
  * **Given** the FWC is receiving ADIRU data with all NCD flags clear
  * **When** the altitude label NCD flag is set on the primary ADIRU channel
  * **Then** altitude alerting and GPWS functions that depend on barometric altitude are inhibited and the BARO ALT INVALID annunciator is illuminated

### Requirement Validation: REQ-CN-001 (DO-178C DAL-A Compliance)

#### Test Case: ATP-CN-001-A (SQAP Review Inspection)
**Description:** Verify that a Software Quality Assurance Plan covering all DAL-A software items is reviewed and approved.

* **User Scenario: SCN-CN-001-A1#**
  * **Given** the FWC Software Quality Assurance Plan document set is submitted for DER review
  * **When** the SQAP is inspected against DO-178C Table A-8 objectives
  * **Then** all 26 applicable DAL-A SQAP objectives are addressed with compliant evidence artifacts

#### Test Case: ATP-CN-001-B (MC/DC Coverage Evidence)
**Description:** Verify that MC/DC structural coverage is achieved for all DAL-A warning generation modules.

* **User Scenario: SCN-CN-001-B1#**
  * **Given** the warning logic software items are compiled with DO-178C-compliant coverage instrumentation
  * **When** the full DAL-A unit test suite and system integration tests are executed
  * **Then** the coverage analysis report shows 100% MC/DC coverage for all warning generation decision points

## Coverage Summary

| Requirement | Test Cases | Scenarios | Status |
|-------------|-----------|-----------|--------|
| REQ-001 | 3 (ATP-001-A, ATP-001-B, ATP-001-C) | 3 (SCN-001-A1#, SCN-001-B1#, SCN-001-C1#) | ⬜ Untested |
| REQ-002 | 3 (ATP-002-A, ATP-002-B, ATP-002-C) | 4 (SCN-002-A1#, SCN-002-B1#, SCN-002-C1#, SCN-002-C2#) | ⬜ Untested |
| REQ-NF-001 | 1 (ATP-NF-001-A) | 1 (SCN-NF-001-A1#) | ⬜ Untested |
| REQ-IF-001 | 2 (ATP-IF-001-A, ATP-IF-001-B) | 2 (SCN-IF-001-A1#, SCN-IF-001-B1#) | ⬜ Untested |
| REQ-CN-001 | 2 (ATP-CN-001-A, ATP-CN-001-B) | 2 (SCN-CN-001-A1#, SCN-CN-001-B1#) | ⬜ Untested |

**Coverage: 100%** — All 5 requirements have test cases and scenarios (including negative/error paths).

## Governing Standards

| Standard | Scope | How Used |
|---|---|---|
| **IEEE 1012:2016** | System, software, and hardware V&V | Primary V&V framework: entry/exit criteria, validation vs. verification distinction, V&V traceability |
| **DO-178C** | Software Considerations in Airborne Systems and Equipment Certification | DAL-A acceptance objectives; MC/DC coverage evidence requirements |
| **ISO/IEC/IEEE 29119-4:2021** | Test design techniques | BDD scenario structure, test case design patterns |
