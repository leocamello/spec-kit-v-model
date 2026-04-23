# Integration Test — Flight Warning Computer (FWC)

## Test Strategy

This integration test plan verifies the interfaces and data flows between architecture modules
defined in the Architecture Design Specification for the Flight Warning Computer. Each test case
(ITP-NNN-X) targets a specific module boundary with executable integration scenarios (ITS-NNN-X#).
Test techniques follow DO-178C Table A-6 integration test objectives and ISO 29119-4 to exercise
interface contracts, data flow correctness, fault tolerance, and inter-module timing.

## Module Boundary Verifications

### Boundary: ARCH-001 → ARCH-002 (ARINC 429 Bus Driver → Label Age Monitor)

#### Test Case: ITP-001-A (Fresh Label Forwarding)

**Technique**: Interface Contract Testing

* **Integration Scenario: ITS-001-A1#**
  * **Given** the ARINC 429 Bus Driver (ARCH-001) receives a valid airspeed word at t=0
  * **When** the Label Age Monitor (ARCH-002) processes the word at t=5 ms
  * **Then** the AgedWord has age_ms = 5 and is forwarded to ARCH-003 without error
  * **And** the inter-module latency is ≤ 1 ms

#### Test Case: ITP-001-B (Stale Label Detection at Boundary)

**Technique**: Boundary Value Analysis

* **Integration Scenario: ITS-001-B1#**
  * **Given** the ARINC 429 Bus Driver (ARCH-001) received an AoA label at t=0
  * **When** the Label Age Monitor processes the label at t=151 ms (1 ms past the 150 ms limit)
  * **Then** a StaleDataError is raised; no AgedWord is forwarded to ARCH-003
  * **And** the channel-stale interrupt is delivered to ARCH-009 BITE Manager within 2 ms

### Boundary: ARCH-002 → ARCH-003 (Label Age Monitor → NCD Flag Checker)

#### Test Case: ITP-002-A (Normal Operation SSM Pass-Through)

**Technique**: Interface Contract Testing

* **Integration Scenario: ITS-002-A1#**
  * **Given** the Label Age Monitor (ARCH-002) emits an AgedWord with SSM = Normal Operation
  * **When** the NCD Flag Checker (ARCH-003) processes the word
  * **Then** a ValidatedFrame is emitted to ARCH-004 with value decoded from the BNR data field

#### Test Case: ITP-002-B (NCD Flag Rejection and Annunciator Activation)

**Technique**: Interface Fault Injection

* **Integration Scenario: ITS-002-B1#**
  * **Given** the NCD Flag Checker (ARCH-003) receives an AgedWord with SSM = No Computed Data
  * **When** the checker processes the NCD-flagged word
  * **Then** a SensorInvalidEvent is sent to ARCH-009 BITE Manager
  * **And** a SensorFailCommand is sent to ARCH-007 Annunciator Controller to illuminate the appropriate SENSOR FAIL annunciator

### Boundary: ARCH-003 → ARCH-004 (NCD Flag Checker → Warning Threshold Evaluator)

#### Test Case: ITP-003-A (Overspeed Threshold Evaluation at Module Boundary)

**Technique**: Boundary Value Analysis

* **Integration Scenario: ITS-003-A1#**
  * **Given** ARCH-003 emits a ValidatedFrame for airspeed label 206 with value = VMO − 1 kt
  * **When** ARCH-004 Warning Threshold Evaluator processes the frame
  * **Then** no WarningEvent for OVERSPEED is emitted; the OVERSPEED state remains Inactive

* **Integration Scenario: ITS-003-A2#**
  * **Given** ARCH-003 emits a ValidatedFrame for airspeed label 206 with value = VMO + 1 kt
  * **When** ARCH-004 Warning Threshold Evaluator processes the frame
  * **Then** a WarningEvent { function: OVERSPEED, priority: 1, state: Active } is emitted to ARCH-005

### Boundary: ARCH-004 → ARCH-005 (Warning Threshold Evaluator → Priority Arbiter)

#### Test Case: ITP-004-A (Single Warning Dispatch)

**Technique**: Interface Contract Testing

* **Integration Scenario: ITS-004-A1#**
  * **Given** ARCH-004 emits a single WarningEvent { function: STALL, priority: 2, state: Active }
  * **When** ARCH-005 Priority Arbiter receives the event
  * **Then** a WarningCommand { function: STALL, priority: 2, state: Active } is dispatched to ARCH-006 and ARCH-007 within 1 ms

#### Test Case: ITP-004-B (Concurrent Warning Priority Arbitration)

**Technique**: Decision Table Testing

* **Integration Scenario: ITS-004-B1#**
  * **Given** ARCH-004 emits OVERSPEED (priority 1) and ATTITUDE LIMIT (priority 5) events in the same processing cycle
  * **When** ARCH-005 Priority Arbiter processes both events
  * **Then** OVERSPEED WarningCommand is dispatched first; ATTITUDE LIMIT WarningCommand is dispatched second
  * **And** total dispatch latency for both commands is ≤ 2 ms

### Boundary: ARCH-005 → ARCH-008 (Priority Arbiter → Stick Shaker Driver)

#### Test Case: ITP-005-A (Stick Shaker Activation and Feedback Monitoring)

**Technique**: Interface Contract Testing

* **Integration Scenario: ITS-005-A1#**
  * **Given** ARCH-005 dispatches a StallCommand { state: Active } to ARCH-008
  * **When** ARCH-008 Stick Shaker Driver asserts the 28 VDC output line
  * **Then** the actuator feedback line rises within 50 ms confirming actuator engagement
  * **And** ARCH-009 BITE Manager receives no stuck-on fault notification

#### Test Case: ITP-005-B (Stuck-Off Fault Detection)

**Technique**: Fault Injection

* **Integration Scenario: ITS-005-B1#**
  * **Given** a STALL WARNING is active and ARCH-008 attempts to drive the stick shaker
  * **When** the actuator feedback line does not rise within 100 ms (stuck-off fault)
  * **Then** ARCH-009 BITE Manager logs a STICK SHAKER STUCK-OFF fault
  * **And** ARCH-007 Annunciator Controller illuminates the STICK SHAKER FAIL annunciator

## Coverage Summary

| Boundary | Test Cases | Scenarios | DO-178C Techniques |
|----------|-----------|-----------|-------------------|
| ARCH-001 → ARCH-002 | 2 (ITP-001-A, ITP-001-B) | 2 (ITS-001-A1#, ITS-001-B1#) | IFT, BVA |
| ARCH-002 → ARCH-003 | 2 (ITP-002-A, ITP-002-B) | 2 (ITS-002-A1#, ITS-002-B1#) | IFT, FI |
| ARCH-003 → ARCH-004 | 1 (ITP-003-A) | 2 (ITS-003-A1#, ITS-003-A2#) | BVA |
| ARCH-004 → ARCH-005 | 2 (ITP-004-A, ITP-004-B) | 2 (ITS-004-A1#, ITS-004-B1#) | IFT, DTT |
| ARCH-005 → ARCH-008 | 2 (ITP-005-A, ITP-005-B) | 2 (ITS-005-A1#, ITS-005-B1#) | IFT, FI |

**Interface Coverage: 100%** — All critical ARCH-NNN boundaries verified with positive, boundary, and fault-injection tests.

## V&V Coverage Gate (IEEE 1012:2016)

| V&V Activity | Objective | Evidence Artifact |
|-------------|-----------|------------------|
| Integration Test Execution | Verify ARCH-NNN module boundaries against interface contracts | This document + test results |
| DO-178C Table A-6 | Software integration testing confirms correct inter-module data flow | ITP records with pass/fail verdict |
| Latency Verification | All inter-module latencies within budget (≤ 2 ms per boundary) | ITS timing measurement logs |
| Entry Criteria | Integration test bench calibrated; all unit tests passed with MC/DC | Unit test completion certificate |
| Exit Criteria | All ITP test cases executed; 0 open DAL-A interface defects | Integration test completion report |

## Governing Standards

| Standard | Full Name | Role in this Document |
|----------|-----------|----------------------|
| **DO-178C** | Software Considerations in Airborne Systems and Equipment Certification | DAL-A integration test objectives (Table A-6); independence requirements |
| **IEEE 1012:2016** | System, Software, and Hardware V&V | V&V Coverage Gate: entry/exit criteria for integration test phase |
| **ISO/IEC/IEEE 29119-4:2021** | Software and Systems Engineering — Test Design Techniques | BVA, Decision Table, Fault Injection, Interface Contract Testing methods |
