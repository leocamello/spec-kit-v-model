# Integration Test — Continuous Blood Glucose Monitoring System (CBGMS)

## Test Strategy

This integration test plan verifies the interfaces and data flows between architecture modules defined in the Architecture Design Specification.
Each test case (ITP-NNN-X) targets a specific module boundary with executable integration scenarios (ITS-NNN-X#).
Test techniques are selected per ISO 29119-4 to exercise interface contracts, data flow correctness, fault tolerance, and concurrency behavior.

## Module Boundary Verifications

### Boundary: ARCH-001 → ARCH-002 (SPI Bus Driver → ADC Sample Validator)

#### Test Case: ITP-001-A (Valid ADC Frame Delivery)

**Technique**: Interface Contract Testing

* **Integration Scenario: ITS-001-A1**
  * **Given** the SPI Bus Driver (ARCH-001) produces a RawADCFrame with a valid CRC-16 checksum
  * **When** the frame is delivered to the ADC Sample Validator (ARCH-002)
  * **Then** the ADC Sample Validator emits a ValidatedSample with the correct nanoamp value and timestamp
  * **And** the inter-module latency is ≤ 10 ms

#### Test Case: ITP-001-B (Corrupted ADC Frame Retry)

**Technique**: Interface Fault Injection

* **Integration Scenario: ITS-001-B1**
  * **Given** the SPI Bus Driver (ARCH-001) produces a RawADCFrame with an invalid CRC-16 checksum
  * **When** the frame is delivered to the ADC Sample Validator (ARCH-002)
  * **Then** the ADC Sample Validator discards the frame, issues a RetryRequest to ARCH-001, and logs a CRCFailureEvent to the Diagnostic Logger (ARCH-011)
  * **And** the retry occurs within 50 ms

* **Integration Scenario: ITS-001-B2**
  * **Given** the SPI Bus Driver (ARCH-001) produces three consecutive frames with invalid CRC-16 checksums
  * **When** all three frames are delivered to the ADC Sample Validator (ARCH-002)
  * **Then** the ADC Sample Validator raises a CRCFailure exception after the third retry
  * **And** the Diagnostic Logger (ARCH-011) contains exactly three CRCFailureEvent entries

### Boundary: ARCH-002 → ARCH-003 → ARCH-004 (Sample Validation → Calibration → Bounds Check)

#### Test Case: ITP-002-A (End-to-End Calibration Pipeline)

**Technique**: Data Flow Testing

* **Integration Scenario: ITS-002-A1**
  * **Given** the ADC Sample Validator (ARCH-002) emits a ValidatedSample of 150.0 nanoamps
  * **When** the sample flows through the Calibration Curve Engine (ARCH-003) and the Accuracy Bounds Checker (ARCH-004)
  * **Then** the output CalibratedReading has mg_dl within ±15% of the expected reference value
  * **And** the confidence score is ≥ 0.85
  * **And** the total pipeline latency (ARCH-002 output to ARCH-004 output) is ≤ 50 ms

#### Test Case: ITP-002-B (Expired Calibration Curve)

**Technique**: Interface Fault Injection

* **Integration Scenario: ITS-002-B1**
  * **Given** the Calibration Curve Engine (ARCH-003) is loaded with an expired calibration curve (curve_version older than 14 days)
  * **When** a ValidatedSample is delivered from ARCH-002
  * **Then** ARCH-003 raises a CalibrationCurveExpired exception
  * **And** the Accuracy Bounds Checker (ARCH-004) does not receive any output
  * **And** the Diagnostic Logger (ARCH-011) records the expiration event

### Boundary: ARCH-004 → ARCH-005 → ARCH-006 (Bounds Check → Threshold Evaluation → Alarm Dispatch)

#### Test Case: ITP-003-A (Hypoglycemia Alert Chain)

**Technique**: Data Flow Testing

* **Integration Scenario: ITS-003-A1**
  * **Given** the Accuracy Bounds Checker (ARCH-004) emits a CalibratedReading with mg_dl = 54.0
  * **When** the reading is evaluated by the Threshold Evaluator (ARCH-005) with hypo threshold = 55 mg/dL
  * **Then** the Threshold Evaluator emits a BreachEvent of type Hypo to the Alarm Dispatcher (ARCH-006)
  * **And** ARCH-006 activates the audible alarm within 1 second
  * **And** the end-to-end latency from ARCH-004 output to ARCH-006 alarm activation is ≤ 200 ms

#### Test Case: ITP-003-B (Alert Dispatch to BLE Transmission)

**Technique**: Interface Contract Testing

* **Integration Scenario: ITS-003-B1**
  * **Given** the Alarm Dispatcher (ARCH-006) emits an AlertPayload with alert_type = Hypo and glucose_value = 52.0
  * **When** the payload is delivered to the GATT Data Serializer (ARCH-008)
  * **Then** ARCH-008 produces a valid CBOR-encoded EncryptedPacket with correct sequence numbering
  * **And** the packet is queued for transmission by the BLE Connection Manager (ARCH-007)

### Boundary: ARCH-004 → ARCH-009 → ARCH-010 (Bounds Check → Flash Storage → Export)

#### Test Case: ITP-004-A (Storage Write and Retrieval)

**Technique**: Data Flow Testing

* **Integration Scenario: ITS-004-A1**
  * **Given** the Accuracy Bounds Checker (ARCH-004) emits 100 consecutive CalibratedReading records
  * **When** the readings are persisted by the Flash Storage Controller (ARCH-009)
  * **Then** a subsequent ReadingSlice request from the Export Formatter (ARCH-010) returns all 100 records with matching timestamps and mg_dl values
  * **And** each record passes read-after-write CRC verification

#### Test Case: ITP-004-B (Flash Write Failure Under Storage Pressure)

**Technique**: Interface Fault Injection

* **Integration Scenario: ITS-004-B1**
  * **Given** the Flash Storage Controller (ARCH-009) NOR flash is filled to 99.9% capacity
  * **When** the Accuracy Bounds Checker (ARCH-004) emits a new CalibratedReading
  * **Then** ARCH-009 performs FIFO eviction of the oldest record before writing the new record
  * **And** the write completes within the 500 ms buffered latency budget
  * **And** no FlashWriteError is raised to the calling module

### Boundary: ARCH-007 ↔ ARCH-008 (BLE Connection Manager ↔ GATT Data Serializer)

#### Test Case: ITP-005-A (BLE Link Loss and Buffer Replay)

**Technique**: Interface Fault Injection

* **Integration Scenario: ITS-005-A1**
  * **Given** the BLE Connection Manager (ARCH-007) has an active connection and 10 EncryptedPackets are queued by the GATT Data Serializer (ARCH-008)
  * **When** the BLE link is forcibly terminated
  * **Then** ARCH-008 buffers subsequent packets in the 64-record ring buffer
  * **And** upon reconnection by ARCH-007 (within 30 seconds), all buffered packets are replayed in sequence order

#### Test Case: ITP-005-B (Concurrent BLE Transmission and Alarm Dispatch)

**Technique**: Concurrency & Race Condition Testing

* **Integration Scenario: ITS-005-B1**
  * **Given** the GATT Data Serializer (ARCH-008) is transmitting a bulk glucose data export via ARCH-007
  * **When** the Alarm Dispatcher (ARCH-006) simultaneously submits a high-priority AlertPayload to ARCH-008
  * **Then** the AlertPayload is prioritized and transmitted before the remaining export packets
  * **And** no data corruption occurs in either the alert or export data streams

### Cross-Cutting: ARCH-011 (Diagnostic Logger)

#### Test Case: ITP-006-A (Concurrent Multi-Module Logging)

**Technique**: Concurrency & Race Condition Testing

* **Integration Scenario: ITS-006-A1**
  * **Given** the ADC Sample Validator (ARCH-002), the Alarm Dispatcher (ARCH-006), and the BLE Connection Manager (ARCH-007) emit diagnostic events simultaneously
  * **When** all three DiagnosticEntry records are written to the Diagnostic Logger (ARCH-011) within the same 5 ms window
  * **Then** all three entries are persisted without data loss or interleaving
  * **And** each entry has a monotonically increasing timestamp
  * **And** the Diagnostic Logger does not block any calling module (async write completes within 5 ms)

## Coverage Summary

| ARCH Boundary | Test Cases | Scenarios | Techniques Used |
|---------------|-----------|-----------|-----------------|
| ARCH-001 → ARCH-002 | ITP-001-A, ITP-001-B | 3 | Interface Contract Testing, Interface Fault Injection |
| ARCH-002 → ARCH-003 → ARCH-004 | ITP-002-A, ITP-002-B | 2 | Data Flow Testing, Interface Fault Injection |
| ARCH-004 → ARCH-005 → ARCH-006 | ITP-003-A, ITP-003-B | 2 | Data Flow Testing, Interface Contract Testing |
| ARCH-004 → ARCH-009 → ARCH-010 | ITP-004-A, ITP-004-B | 2 | Data Flow Testing, Interface Fault Injection |
| ARCH-007 ↔ ARCH-008 | ITP-005-A, ITP-005-B | 2 | Interface Fault Injection, Concurrency & Race Condition Testing |
| ARCH-011 (Cross-Cutting) | ITP-006-A | 1 | Concurrency & Race Condition Testing |

**Techniques**: Interface Contract Testing, Data Flow Testing, Interface Fault Injection, Concurrency & Race Condition Testing
**Coverage: 100%** — All 11 architecture module boundaries have integration test cases.
