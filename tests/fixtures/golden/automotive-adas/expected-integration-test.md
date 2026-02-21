# Integration Test — Automatic Emergency Braking System (AEB)

## Test Strategy

This integration test plan verifies the interfaces and data flows between architecture modules defined in the Architecture Design Specification.
Each test case (ITP-NNN-X) targets a specific module boundary with executable integration scenarios (ITS-NNN-X#).
Test techniques are selected per ISO 29119-4 based on ASIL-D integrity level, interface criticality, and real-time constraints.

## Module Boundary Verifications

### Boundary: ARCH-001 → ARCH-002 (Radar Signal Processor → Radar Track Extractor)

#### Test Case: ITP-001-A (Radar Detection-to-Track Pipeline)

**Technique**: Data Flow Testing

* **Integration Scenario: ITS-001-A1**
  * **Given** the Radar Signal Processor (ARCH-001) produces a CFARDetection with a vehicle target at 150 m range closing at 30 m/s
  * **When** the detection is delivered to the Radar Track Extractor (ARCH-002)
  * **Then** ARCH-002 initiates a new RadarTrack with range_m = 150 ± 1 m and velocity_ms = 30 ± 0.5 m/s
  * **And** the inter-module latency is ≤ 5 ms (2 ms + 3 ms budget)

#### Test Case: ITP-001-B (Corrupted CAN-FD Frame Handling)

**Technique**: Interface Fault Injection

* **Integration Scenario: ITS-001-B1**
  * **Given** the Radar Signal Processor (ARCH-001) receives a CAN-FD frame with invalid CRC-32 from the radar sensor
  * **When** ARCH-001 raises a RadarHWFault exception
  * **Then** ARCH-002 does not receive any CFARDetection for that frame
  * **And** the Heartbeat Monitor (ARCH-009) is notified of the fault event
  * **And** the Watchdog Timer (ARCH-011) is not triggered (single frame loss is tolerated)

### Boundary: ARCH-003 → ARCH-004 (Frame Decoder → Object Classifier)

#### Test Case: ITP-002-A (Stereo Frame to Classification Pipeline)

**Technique**: Data Flow Testing

* **Integration Scenario: ITS-002-A1**
  * **Given** the Frame Decoder (ARCH-003) produces a DecodedFramePair containing a pedestrian at 50 m range
  * **When** the frame pair is delivered to the Object Classifier (ARCH-004)
  * **Then** ARCH-004 produces a CameraDetection with class = Pedestrian, depth_m = 50 ± 2 m, and confidence ≥ 0.90
  * **And** the inter-module latency is ≤ 10 ms (5 ms + 5 ms budget)

#### Test Case: ITP-002-B (Frame Synchronization Failure)

**Technique**: Interface Fault Injection

* **Integration Scenario: ITS-002-B1**
  * **Given** the Frame Decoder (ARCH-003) detects a timestamp delta > 80 ms between left and right stereo frames
  * **When** ARCH-003 raises a FrameSyncError
  * **Then** the Object Classifier (ARCH-004) does not receive a DecodedFramePair for that cycle
  * **And** ARCH-003 flags the stale frame to the Extended Kalman Filter (ARCH-005) via the Heartbeat Monitor (ARCH-009)

### Boundary: ARCH-002 + ARCH-004 → ARCH-005 → ARCH-006 (Sensor Inputs → Fusion → TTC)

#### Test Case: ITP-003-A (Dual-Sensor Fusion Accuracy)

**Technique**: Interface Contract Testing

* **Integration Scenario: ITS-003-A1**
  * **Given** the Radar Track Extractor (ARCH-002) reports a vehicle at 100 m closing at 40 m/s and the Object Classifier (ARCH-004) reports the same vehicle at 100 m with class = Vehicle and confidence = 0.95
  * **When** both inputs are fused by the Extended Kalman Filter (ARCH-005) and evaluated by the TTC Calculator (ARCH-006)
  * **Then** the ThreatAssessment has ttc_s = 2.5 ± 0.05 seconds and class = Vehicle
  * **And** the total fusion-to-TTC latency is ≤ 8 ms (5 ms + 3 ms budget)

#### Test Case: ITP-003-B (EKF Divergence Recovery)

**Technique**: Interface Fault Injection

* **Integration Scenario: ITS-003-B1**
  * **Given** the Extended Kalman Filter (ARCH-005) covariance matrix exceeds the divergence threshold due to inconsistent radar and camera inputs
  * **When** ARCH-005 raises a FusionDivergence exception
  * **Then** the EKF state is reset and ARCH-005 falls back to single-sensor mode (radar-only or camera-only)
  * **And** the TTC Calculator (ARCH-006) continues to receive FusedObject outputs within one frame period (50 ms)
  * **And** the Degradation Controller (ARCH-010) is notified of the mode change

### Boundary: ARCH-006 → ARCH-007 → ARCH-008 (TTC → Threat Evaluation → Brake Actuation)

#### Test Case: ITP-004-A (Emergency Braking Command Chain)

**Technique**: Data Flow Testing

* **Integration Scenario: ITS-004-A1**
  * **Given** the TTC Calculator (ARCH-006) emits a ThreatAssessment with ttc_s = 1.49 seconds for a vehicle target
  * **When** the assessment is evaluated by the Threat Evaluator (ARCH-007)
  * **Then** ARCH-007 issues a BrakeCommand with decel_target_ms2 = 10.0 and priority = Emergency to the CAN Brake Commander (ARCH-008)
  * **And** ARCH-008 transmits the command on the primary CAN-FD bus within 2 ms
  * **And** the end-to-end latency from ARCH-006 output to CAN-FD transmission is ≤ 4 ms

#### Test Case: ITP-004-B (CAN Bus Failover Under Braking)

**Technique**: Interface Fault Injection

* **Integration Scenario: ITS-004-B1**
  * **Given** the CAN Brake Commander (ARCH-008) is transmitting an emergency braking command on the primary CAN-FD bus
  * **When** the primary CAN-FD bus is disconnected (simulated wire break)
  * **Then** ARCH-008 switches to the secondary CAN-FD bus within 10 ms
  * **And** the brake command is retransmitted without deceleration interruption
  * **And** the Degradation Controller (ARCH-010) logs DTC code 0xB001 (Primary CAN Bus Failure)

### Boundary: ARCH-009 → ARCH-010 (Heartbeat Monitor → Degradation Controller)

#### Test Case: ITP-005-A (Single-Sensor Failure Degradation)

**Technique**: Interface Contract Testing

* **Integration Scenario: ITS-005-A1**
  * **Given** the Heartbeat Monitor (ARCH-009) detects that the Camera Processing pipeline (ARCH-003, ARCH-004) heartbeat is absent for > 100 ms
  * **When** ARCH-009 sends a HealthReport with state = Failed and component_id = ARCH-004 to the Degradation Controller (ARCH-010)
  * **Then** ARCH-010 transitions the system to Radar-Only mode
  * **And** logs DTC code 0xC002 (Camera Subsystem Failure) to non-volatile memory
  * **And** the mode transition completes within 50 ms of the heartbeat timeout

#### Test Case: ITP-005-B (Cascading Dual-Sensor Failure)

**Technique**: Concurrency & Race Condition Testing

* **Integration Scenario: ITS-005-B1**
  * **Given** the system is operating in Radar-Only degraded mode following a camera failure
  * **When** the Heartbeat Monitor (ARCH-009) simultaneously detects that the Radar Processing pipeline (ARCH-001, ARCH-002) heartbeat is also absent for > 100 ms
  * **Then** the Degradation Controller (ARCH-010) transitions the system to Safe-State mode
  * **And** the Threat Evaluator (ARCH-007) issues an emergency BrakeCommand with maximum deceleration (10 m/s²)
  * **And** logs DTC code 0xC003 (Dual Sensor Failure — Emergency Stop)
  * **And** the total time from second sensor failure detection to brake actuation is ≤ 50 ms

### Cross-Cutting: ARCH-011 (Watchdog Timer)

#### Test Case: ITP-006-A (Watchdog Timeout Enforcement)

**Technique**: Concurrency & Race Condition Testing

* **Integration Scenario: ITS-006-A1**
  * **Given** the sensor-to-actuator critical path (ARCH-001 through ARCH-008) is executing normally and kicking the Watchdog Timer (ARCH-011) every cycle
  * **When** the pipeline execution stalls (simulated CPU overload causing > 100 ms execution time)
  * **Then** the Watchdog Timer triggers a WatchdogExpiry event
  * **And** the Degradation Controller (ARCH-010) immediately enters Safe-State mode with maximum braking
  * **And** a DTC code 0xW001 (Watchdog Timeout — Pipeline Stall) is logged to non-volatile memory

#### Test Case: ITP-006-B (Watchdog Independence from Software Faults)

**Technique**: Interface Fault Injection

* **Integration Scenario: ITS-006-B1**
  * **Given** the Watchdog Timer (ARCH-011) is running on an independent hardware clock source
  * **When** a software fault causes the Heartbeat Monitor (ARCH-009) and the Degradation Controller (ARCH-010) to become unresponsive
  * **Then** the Watchdog Timer independently triggers the safe-state via hardware signal to the brake-by-wire ECU within 100 ms
  * **And** the brake actuator engages hydraulic backup braking regardless of software state

## Coverage Summary

| ARCH Boundary | Test Cases | Scenarios | Techniques Used |
|---------------|-----------|-----------|-----------------|
| ARCH-001 → ARCH-002 | ITP-001-A, ITP-001-B | 2 | Data Flow Testing, Interface Fault Injection |
| ARCH-003 → ARCH-004 | ITP-002-A, ITP-002-B | 2 | Data Flow Testing, Interface Fault Injection |
| ARCH-002 + ARCH-004 → ARCH-005 → ARCH-006 | ITP-003-A, ITP-003-B | 2 | Interface Contract Testing, Interface Fault Injection |
| ARCH-006 → ARCH-007 → ARCH-008 | ITP-004-A, ITP-004-B | 2 | Data Flow Testing, Interface Fault Injection |
| ARCH-009 → ARCH-010 | ITP-005-A, ITP-005-B | 2 | Interface Contract Testing, Concurrency & Race Condition Testing |
| ARCH-011 (Cross-Cutting) | ITP-006-A, ITP-006-B | 2 | Concurrency & Race Condition Testing, Interface Fault Injection |

**Techniques**: Interface Contract Testing, Data Flow Testing, Interface Fault Injection, Concurrency & Race Condition Testing
**Coverage: 100%** — All 11 architecture module boundaries have integration test cases. All test scenarios are SIL/HIL compatible.
