# System Test — Automatic Emergency Braking System (AEB)

## Test Strategy

This system test plan verifies all system components defined in the System Design Specification.
Each component has one or more test cases (STP-NNN-X) with executable system scenarios (STS-NNN-X#).
Test techniques are selected per ISO 29119-4 based on component type, risk profile, and ASIL-D integrity level.

## Component Verifications

### Component Verification: SYS-001 (Radar Processing Unit)

#### Test Case: STP-001-A (Vehicle Detection at Maximum Range)

**Technique**: Boundary Value Analysis

* **System Scenario: STS-001-A1**
  * **Given** the Radar Processing Unit is receiving 77 GHz FMCW returns at 20 Hz
  * **When** a vehicle target with RCS ≥ 10 dBsm is positioned at 200 m range
  * **Then** the Radar Processing Unit reports a valid track with range error ≤ ±1 m and velocity error ≤ ±0.5 m/s

* **System Scenario: STS-001-A2**
  * **Given** the Radar Processing Unit is receiving 77 GHz FMCW returns at 20 Hz
  * **When** a vehicle target is positioned at 201 m range
  * **Then** the Radar Processing Unit does not report a track for that target

#### Test Case: STP-001-B (CAN-FD Message Integrity)

**Technique**: Fault Injection

* **System Scenario: STS-001-B1**
  * **Given** the Radar Processing Unit is receiving CAN-FD frames from the radar sensor
  * **When** a frame with invalid CRC-32 is injected on the CAN-FD bus
  * **Then** the Radar Processing Unit discards the corrupted frame
  * **And** requests retransmission within 5 ms

### Component Verification: SYS-002 (Camera Processing Unit)

#### Test Case: STP-002-A (Pedestrian Detection at Maximum Range)

**Technique**: Boundary Value Analysis

* **System Scenario: STS-002-A1**
  * **Given** the Camera Processing Unit is processing stereo frames at 15 Hz
  * **When** a pedestrian is positioned at 80 m in clear visibility conditions
  * **Then** the Camera Processing Unit classifies the object as "Pedestrian" with confidence ≥ 0.90

* **System Scenario: STS-002-A2**
  * **Given** the Camera Processing Unit is processing stereo frames at 15 Hz
  * **When** a pedestrian is positioned at 81 m in clear visibility conditions
  * **Then** the Camera Processing Unit does not produce a detection for that target

#### Test Case: STP-002-B (Object Classification Accuracy)

**Technique**: Equivalence Partitioning

* **System Scenario: STS-002-B1**
  * **Given** the Camera Processing Unit is processing stereo frames at 15 Hz
  * **When** a vehicle, a pedestrian, and a cyclist are simultaneously present at 50 m range
  * **Then** each object is classified into the correct category (Vehicle, Pedestrian, Cyclist) with confidence ≥ 0.85

### Component Verification: SYS-003 (Sensor Fusion Engine)

#### Test Case: STP-003-A (TTC Computation Accuracy)

**Technique**: Boundary Value Analysis

* **System Scenario: STS-003-A1**
  * **Given** the Sensor Fusion Engine receives a fused vehicle track at 100 m range closing at 40 m/s (144 km/h relative)
  * **When** the TTC is computed for the current frame
  * **Then** the reported TTC is 2.5 ± 0.05 seconds

* **System Scenario: STS-003-A2**
  * **Given** the Sensor Fusion Engine receives a fused vehicle track at 60 m range closing at 40 m/s
  * **When** the TTC is computed for the current frame
  * **Then** the reported TTC is 1.5 ± 0.05 seconds

#### Test Case: STP-003-B (False Positive Suppression)

**Technique**: Equivalence Partitioning

* **System Scenario: STS-003-B1**
  * **Given** the Sensor Fusion Engine processes 10,000 km of recorded highway driving data
  * **When** all frames are evaluated for collision threats
  * **Then** the false positive braking activation count is less than 1 event

### Component Verification: SYS-004 (Braking Controller)

#### Test Case: STP-004-A (Forward Collision Warning Activation)

**Technique**: Boundary Value Analysis

* **System Scenario: STS-004-A1**
  * **Given** the Braking Controller receives a fused threat with TTC = 2.49 seconds
  * **When** the threat evaluation cycle executes
  * **Then** the Braking Controller issues a forward collision warning to the instrument cluster within 10 ms

* **System Scenario: STS-004-A2**
  * **Given** the Braking Controller receives a fused threat with TTC = 2.50 seconds
  * **When** the threat evaluation cycle executes
  * **Then** the Braking Controller does not issue a warning

#### Test Case: STP-004-B (Autonomous Braking Activation)

**Technique**: Boundary Value Analysis

* **System Scenario: STS-004-B1**
  * **Given** the Braking Controller receives a fused threat with TTC = 1.49 seconds
  * **When** the threat evaluation cycle executes
  * **Then** the Braking Controller commands autonomous full braking (deceleration target = 10 m/s²) via CAN-FD within 10 ms

#### Test Case: STP-004-C (Dual-Channel CAN Redundancy)

**Technique**: Fault Injection

* **System Scenario: STS-004-C1**
  * **Given** the Braking Controller is commanding autonomous braking on the primary CAN-FD bus
  * **When** the primary CAN-FD bus is disconnected (simulated wire break)
  * **Then** the Braking Controller switches to the secondary CAN-FD bus within 10 ms
  * **And** the braking command is maintained without interruption

### Component Verification: SYS-005 (Fault Manager)

#### Test Case: STP-005-A (Single-Sensor Degradation)

**Technique**: Fault Injection

* **System Scenario: STS-005-A1**
  * **Given** the Fault Manager is monitoring all subsystem heartbeats
  * **When** the Camera Processing Unit (SYS-002) heartbeat is absent for 100 ms
  * **Then** the Fault Manager transitions the system to radar-only degraded mode
  * **And** logs DTC code 0xC002 (Camera Subsystem Failure) to non-volatile memory

* **System Scenario: STS-005-A2**
  * **Given** the Fault Manager is monitoring all subsystem heartbeats
  * **When** the Radar Processing Unit (SYS-001) heartbeat is absent for 100 ms
  * **Then** the Fault Manager transitions the system to camera-only degraded mode
  * **And** logs DTC code 0xC001 (Radar Subsystem Failure) to non-volatile memory

#### Test Case: STP-005-B (Dual-Sensor Failure Safe-State)

**Technique**: Fault Injection

* **System Scenario: STS-005-B1**
  * **Given** the system is operating in single-sensor degraded mode (radar-only)
  * **When** the remaining sensor (SYS-001) heartbeat is also absent for 100 ms
  * **Then** the Fault Manager commands SYS-004 to apply maximum braking (safe-state)
  * **And** logs DTC code 0xC003 (Dual Sensor Failure — Emergency Stop) to non-volatile memory

## Coverage Summary

| SYS Component | Test Cases | Scenarios | Techniques Used |
|---------------|-----------|-----------|-----------------|
| SYS-001 | STP-001-A, STP-001-B | 3 | Boundary Value Analysis, Fault Injection |
| SYS-002 | STP-002-A, STP-002-B | 3 | Boundary Value Analysis, Equivalence Partitioning |
| SYS-003 | STP-003-A, STP-003-B | 3 | Boundary Value Analysis, Equivalence Partitioning |
| SYS-004 | STP-004-A, STP-004-B, STP-004-C | 4 | Boundary Value Analysis, Fault Injection |
| SYS-005 | STP-005-A, STP-005-B | 3 | Fault Injection |

**Coverage: 100%** — All 5 system components have test cases and scenarios.
