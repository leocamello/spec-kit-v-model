# System Test — Continuous Blood Glucose Monitoring System (CBGMS)

## Test Strategy

This system test plan verifies all system components defined in the System Design Specification.
Each component has one or more test cases (STP-NNN-X) with executable system scenarios (STS-NNN-X#).
Test techniques are selected per ISO 29119-4 based on component type and risk profile.

## Component Verifications

### Component Verification: SYS-001 (Glucose Sensor Interface)

#### Test Case: STP-001-A (5-Minute Sampling Interval)

**Technique**: Boundary Value Analysis

* **System Scenario: STS-001-A1**
  * **Given** the Glucose Sensor Interface is initialized with a 5-minute sampling period
  * **When** the SPI bus delivers 12 consecutive raw ADC readings
  * **Then** the inter-reading interval is 300 ± 1 seconds for all 12 samples

#### Test Case: STP-001-B (SPI CRC Validation)

**Technique**: Fault Injection

* **System Scenario: STS-001-B1**
  * **Given** the Glucose Sensor Interface is receiving raw ADC readings via SPI
  * **When** a reading with an invalid CRC-16 checksum is injected
  * **Then** the Glucose Sensor Interface discards the corrupted reading and retries within 50 ms
  * **And** the retry count is incremented in the diagnostic log

### Component Verification: SYS-002 (Signal Processing Engine)

#### Test Case: STP-002-A (Calibration Accuracy — Normal Range)

**Technique**: Boundary Value Analysis

* **System Scenario: STS-002-A1**
  * **Given** the Signal Processing Engine is loaded with the factory calibration curve
  * **When** a raw reading corresponding to 75 mg/dL is processed
  * **Then** the calibrated output is within ±15% of the YSI reference value (63.75–86.25 mg/dL)

* **System Scenario: STS-002-A2**
  * **Given** the Signal Processing Engine is loaded with the factory calibration curve
  * **When** a raw reading corresponding to 400 mg/dL is processed
  * **Then** the calibrated output is within ±15% of the YSI reference value (340–460 mg/dL)

#### Test Case: STP-002-B (Calibration Accuracy — Low Range)

**Technique**: Equivalence Partitioning

* **System Scenario: STS-002-B1**
  * **Given** the Signal Processing Engine is loaded with the factory calibration curve
  * **When** a raw reading corresponding to 50 mg/dL is processed
  * **Then** the calibrated output is within ±15 mg/dL of the YSI reference value (35–65 mg/dL)

### Component Verification: SYS-003 (Alert Manager)

#### Test Case: STP-003-A (Hypoglycemia Threshold Breach)

**Technique**: Boundary Value Analysis

* **System Scenario: STS-003-A1**
  * **Given** the Alert Manager threshold is configured to 55 mg/dL for hypoglycemia
  * **When** the calibrated glucose value drops to 54 mg/dL
  * **Then** the Alert Manager activates the audible alarm within 1 second
  * **And** dispatches an SMS alert payload to the configured emergency contact

* **System Scenario: STS-003-A2**
  * **Given** the Alert Manager threshold is configured to 55 mg/dL for hypoglycemia
  * **When** the calibrated glucose value is exactly 55 mg/dL
  * **Then** the Alert Manager does not trigger an alarm

#### Test Case: STP-003-B (SMS Escalation Failure)

**Technique**: Fault Injection

* **System Scenario: STS-003-B1**
  * **Given** the SMS Gateway returns HTTP 503 for all requests
  * **When** the Alert Manager attempts SMS escalation after a threshold breach
  * **Then** the Alert Manager retries 3 times at 10-second intervals
  * **And** logs each failure to the audit trail with timestamp and HTTP status code
  * **And** the on-device audible alarm remains active regardless of SMS delivery status

### Component Verification: SYS-004 (BLE Communication Module)

#### Test Case: STP-004-A (BLE Pairing and Data Transfer)

**Technique**: Interface Contract Testing

* **System Scenario: STS-004-A1**
  * **Given** the BLE Communication Module is advertising its GATT profile
  * **When** the companion mobile app initiates a BLE 5.0 LE Secure Connection
  * **Then** the pairing completes within 5 seconds
  * **And** CBOR-encoded glucose records are transmitted at the configured interval

#### Test Case: STP-004-B (Auto-Reconnection on Link Loss)

**Technique**: Fault Injection

* **System Scenario: STS-004-B1**
  * **Given** the BLE Communication Module has an active connection to the companion app
  * **When** the BLE link is forcibly terminated (simulated RF interference)
  * **Then** the BLE Communication Module initiates reconnection within 30 seconds using exponential backoff
  * **And** buffered readings accumulated during the outage are replayed after reconnection

### Component Verification: SYS-005 (Data Storage Manager)

#### Test Case: STP-005-A (90-Day Rolling Retention)

**Technique**: Boundary Value Analysis

* **System Scenario: STS-005-A1**
  * **Given** the Data Storage Manager flash is filled with 90 days of glucose readings (25,920 records at 5-minute intervals)
  * **When** a new reading arrives on day 91
  * **Then** the oldest reading (day 1, first sample) is evicted via FIFO
  * **And** the new reading is persisted successfully

#### Test Case: STP-005-B (CSV Export)

**Technique**: Interface Contract Testing

* **System Scenario: STS-005-B1**
  * **Given** the Data Storage Manager contains 7 days of glucose readings
  * **When** the companion app requests a CSV export for the 7-day range
  * **Then** the exported CSV contains a header row and exactly 2,016 data rows (7 × 24 × 12 readings per hour)
  * **And** each row contains timestamp (ISO 8601), glucose value (mg/dL), and confidence score

## Coverage Summary

| SYS Component | Test Cases | Scenarios | Techniques Used |
|---------------|-----------|-----------|-----------------|
| SYS-001 | STP-001-A, STP-001-B | 2 | Boundary Value Analysis, Fault Injection |
| SYS-002 | STP-002-A, STP-002-B | 3 | Boundary Value Analysis, Equivalence Partitioning |
| SYS-003 | STP-003-A, STP-003-B | 3 | Boundary Value Analysis, Fault Injection |
| SYS-004 | STP-004-A, STP-004-B | 2 | Interface Contract Testing, Fault Injection |
| SYS-005 | STP-005-A, STP-005-B | 2 | Boundary Value Analysis, Interface Contract Testing |

**Coverage: 100%** — All 5 system components have test cases and scenarios.
