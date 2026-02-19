# Acceptance Test Plan

## Test Strategy

This acceptance test plan validates all requirements defined in the Requirements Specification
for the Continuous Blood Glucose Monitoring System. Each requirement has one or more test cases,
and each test case has one or more executable BDD scenarios. Testing encompasses functional
verification, clinical accuracy analysis, wireless interface validation, and data integrity
inspection per IEC 62304 and ISO 15197 compliance obligations.

## Requirement Validations

### Requirement Validation: REQ-001 (Real-Time Glucose Monitoring)

#### Test Case: ATP-001-A (Periodic Sampling Interval)
**Description:** Verify that the sensor samples and transmits glucose readings at least every 5 minutes under normal operating conditions.

* **User Scenario: SCN-001-A1**
  * **Given** the CBGMS sensor is inserted subcutaneously and the transmitter is paired with the companion app
  * **When** the system operates continuously for 60 minutes
  * **Then** the companion app receives at least 12 glucose readings with timestamps no more than 5 minutes apart

#### Test Case: ATP-001-B (Real-Time Display Update)
**Description:** Verify that each transmitted glucose reading is displayed on the companion app in real time.

* **User Scenario: SCN-001-B1**
  * **Given** the transmitter is actively paired and the companion app is in the foreground
  * **When** a new glucose reading is sampled by the sensor
  * **Then** the reading is displayed on the companion app within 10 seconds of transmission

#### Test Case: ATP-001-C (Sensor Disconnection Handling)
**Description:** Verify that the system handles sensor disconnection gracefully and notifies the user.

* **User Scenario: SCN-001-C1**
  * **Given** the CBGMS sensor has been transmitting readings normally
  * **When** the sensor is removed or loses contact with interstitial fluid
  * **Then** the companion app displays a "Sensor Disconnected" warning within 60 seconds and stops plotting new data points

### Requirement Validation: REQ-002 (Hypo/Hyperglycemia Alarm with Escalation)

#### Test Case: ATP-002-A (Threshold Breach Alarm Activation)
**Description:** Verify that audible and haptic alarms are triggered when glucose readings cross user-configured thresholds.

* **User Scenario: SCN-002-A1**
  * **Given** the user has configured a hypoglycemia threshold of 70 mg/dL
  * **When** the system detects a glucose reading of 65 mg/dL
  * **Then** the companion app triggers an audible alarm and a haptic vibration alert within 30 seconds

#### Test Case: ATP-002-B (Unacknowledged Alarm Escalation)
**Description:** Verify that an unacknowledged hypoglycemia alarm escalates to an emergency contact via SMS.

* **User Scenario: SCN-002-B1**
  * **Given** a hypoglycemia alarm has been triggered and the user has an emergency contact configured
  * **When** the alarm remains unacknowledged for 15 minutes
  * **Then** the system sends an SMS notification to the designated emergency contact containing the patient name and current glucose value

#### Test Case: ATP-002-C (Alarm with No Emergency Contact)
**Description:** Verify that the system handles alarm escalation gracefully when no emergency contact is configured.

* **User Scenario: SCN-002-C1**
  * **Given** a hypoglycemia alarm has been triggered and the user has NOT configured an emergency contact
  * **When** the alarm remains unacknowledged for 15 minutes
  * **Then** the companion app displays a persistent on-screen alert recommending the user configure an emergency contact and logs the missed escalation event

#### Test Case: ATP-002-D (Threshold Boundary Values)
**Description:** Verify correct alarm behavior at exact threshold boundaries.

* **User Scenario: SCN-002-D1**
  * **Given** the user has configured a hypoglycemia threshold of 70 mg/dL
  * **When** the system detects a glucose reading of exactly 70 mg/dL
  * **Then** no alarm is triggered because the threshold is not breached

* **User Scenario: SCN-002-D2**
  * **Given** the user has configured a hyperglycemia threshold of 250 mg/dL
  * **When** the system detects a glucose reading of 251 mg/dL
  * **Then** the companion app triggers an audible alarm and a haptic vibration alert within 30 seconds

### Requirement Validation: REQ-NF-001 (Clinical Measurement Accuracy)

#### Test Case: ATP-NF-001-A (ISO 15197 Accuracy Compliance)
**Description:** Verify that system measurements meet ISO 15197:2013 accuracy criteria against a YSI laboratory reference.

* **User Scenario: SCN-NF-001-A1**
  * **Given** a set of 100 paired glucose measurements from the CBGMS sensor and a YSI 2300 STAT Plus laboratory analyzer across the 40–400 mg/dL range
  * **When** the paired differences are computed for each measurement
  * **Then** at least 95% of readings in the 75–400 mg/dL range fall within ±15% of the reference value, and at least 95% of readings below 75 mg/dL fall within ±15 mg/dL of the reference value

### Requirement Validation: REQ-IF-001 (Bluetooth Low Energy Connectivity)

#### Test Case: ATP-IF-001-A (BLE Pairing and Data Transfer)
**Description:** Verify that the transmitter and companion app establish a BLE 5.0 connection and transfer glucose data reliably.

* **User Scenario: SCN-IF-001-A1**
  * **Given** the transmitter is powered on and the companion app is launched with Bluetooth enabled
  * **When** the user initiates pairing via the app
  * **Then** a BLE 5.0 connection is established and glucose readings are received by the app without data loss

#### Test Case: ATP-IF-001-B (Auto-Reconnection After Interruption)
**Description:** Verify that the BLE connection auto-reconnects within 30 seconds after a disruption.

* **User Scenario: SCN-IF-001-B1**
  * **Given** the transmitter and companion app have an active BLE connection
  * **When** the Bluetooth connection is interrupted by moving the device out of range and then back within range
  * **Then** the connection is re-established automatically within 30 seconds and any buffered readings are synced

#### Test Case: ATP-IF-001-C (BLE Pairing Failure)
**Description:** Verify the system provides clear feedback when BLE pairing fails.

* **User Scenario: SCN-IF-001-C1**
  * **Given** the transmitter is powered on and the companion app is launched with Bluetooth disabled
  * **When** the user initiates pairing via the app
  * **Then** the app displays an error message "Bluetooth is disabled. Please enable Bluetooth to pair with your sensor" and does not attempt connection

### Requirement Validation: REQ-CN-001 (Data Retention and Export)

#### Test Case: ATP-CN-001-A (90-Day Data Retention)
**Description:** Verify that the system retains at least 90 days of glucose reading history.

* **User Scenario: SCN-CN-001-A1**
  * **Given** the system has been in continuous operation for more than 90 days
  * **When** the user navigates to the glucose history view in the companion app
  * **Then** glucose readings from 90 days ago are available and displayed correctly

#### Test Case: ATP-CN-001-B (Data Export Formats)
**Description:** Verify that glucose data can be exported in CSV and PDF formats.

* **User Scenario: SCN-CN-001-B1**
  * **Given** the companion app has at least 7 days of stored glucose data
  * **When** the user selects "Export Data" and chooses CSV format
  * **Then** a CSV file is generated containing timestamped glucose readings matching the stored data

#### Test Case: ATP-CN-001-C (Export with No Data)
**Description:** Verify the system handles data export gracefully when no data is available.

* **User Scenario: SCN-CN-001-C1**
  * **Given** the companion app has been freshly installed with no stored glucose data
  * **When** the user selects "Export Data" and chooses CSV format
  * **Then** the app displays a message "No glucose data available to export" and does not generate a file

## Coverage Summary

| Requirement | Test Cases | Scenarios | Status |
|-------------|-----------|-----------|--------|
| REQ-001 | 3 (ATP-001-A, ATP-001-B, ATP-001-C) | 3 (SCN-001-A1, SCN-001-B1, SCN-001-C1) | ⬜ Untested |
| REQ-002 | 4 (ATP-002-A, ATP-002-B, ATP-002-C, ATP-002-D) | 5 (SCN-002-A1, SCN-002-B1, SCN-002-C1, SCN-002-D1, SCN-002-D2) | ⬜ Untested |
| REQ-NF-001 | 1 (ATP-NF-001-A) | 1 (SCN-NF-001-A1) | ⬜ Untested |
| REQ-IF-001 | 3 (ATP-IF-001-A, ATP-IF-001-B, ATP-IF-001-C) | 3 (SCN-IF-001-A1, SCN-IF-001-B1, SCN-IF-001-C1) | ⬜ Untested |
| REQ-CN-001 | 3 (ATP-CN-001-A, ATP-CN-001-B, ATP-CN-001-C) | 3 (SCN-CN-001-A1, SCN-CN-001-B1, SCN-CN-001-C1) | ⬜ Untested |

**Coverage: 100%** — All 5 requirements have test cases and scenarios (including negative/error paths).
