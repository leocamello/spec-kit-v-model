# System Test — Flight Warning Computer (FWC)

## Test Strategy

This system test plan verifies all system components defined in the System Design Specification
for the Flight Warning Computer. Each component has one or more test cases (STP-NNN-X) with
executable system scenarios (STS-NNN-X#). Test techniques are selected per DO-178C Table A-7
and ISO 29119-4 based on component type, DAL-A risk classification, and safety criticality.

## Component Verifications

### Component Verification: SYS-001 (Air Data Interface)

#### Test Case: STP-001-A (ARINC 429 Label Freshness Check)

**Technique**: Boundary Value Analysis

* **System Scenario: STS-001-A1#**
  * **Given** the Air Data Interface is receiving ADIRU data with label refresh interval of 10 ms
  * **When** the refresh interval increases to exactly 150 ms (freshness limit)
  * **Then** the input is still accepted as valid; no stale-data flag is set

* **System Scenario: STS-001-A2#**
  * **Given** the Air Data Interface is receiving ADIRU data normally
  * **When** the ADIRU stops transmitting airspeed label 206 for 151 ms
  * **Then** the airspeed input is flagged as stale; the ADIRU FAIL annunciator is activated via SYS-003

#### Test Case: STP-001-B (NCD Flag Rejection)

**Technique**: Fault Injection

* **System Scenario: STS-001-B1#**
  * **Given** the Air Data Interface is receiving valid ADIRU data with all SSM fields set to Normal Operation
  * **When** the SSM field of the AoA label transitions to No Computed Data
  * **Then** the AoA input is marked invalid; stall warning logic in SYS-002 is inhibited; AoA INVALID annunciator illuminated

### Component Verification: SYS-002 (Warning Logic Engine)

#### Test Case: STP-002-A (Overspeed Threshold Evaluation)

**Technique**: Boundary Value Analysis

* **System Scenario: STS-002-A1#**
  * **Given** the Warning Logic Engine is receiving valid airspeed data with VMO set to 340 kt
  * **When** the validated airspeed equals 340 kt (boundary — not exceeded)
  * **Then** no overspeed warning command is issued to SYS-003

* **System Scenario: STS-002-A2#**
  * **Given** the Warning Logic Engine is receiving valid airspeed data with VMO set to 340 kt
  * **When** the validated airspeed equals 341 kt (VMO + 1 kt)
  * **Then** an OVERSPEED warning command is dispatched to SYS-003 within 5 ms

#### Test Case: STP-002-B (Stall Warning Threshold Evaluation)

**Technique**: Boundary Value Analysis

* **System Scenario: STS-002-B1#**
  * **Given** the Warning Logic Engine is receiving valid AoA data with stall warning threshold at 14.0 degrees
  * **When** the validated AoA equals 14.0 degrees (threshold — not exceeded)
  * **Then** no stall warning command is issued to SYS-003

* **System Scenario: STS-002-B2#**
  * **Given** the Warning Logic Engine is receiving valid AoA data with stall warning threshold at 14.0 degrees
  * **When** the validated AoA equals 14.1 degrees (threshold exceeded by 0.1 degree)
  * **Then** a STALL WARNING command is dispatched to SYS-003 within 5 ms

#### Test Case: STP-002-C (Warning Priority Arbitration)

**Technique**: Decision Table Testing

* **System Scenario: STS-002-C1#**
  * **Given** the Warning Logic Engine receives simultaneous overspeed and stall warning conditions
  * **When** both threshold exceedances are active at the same ARINC 429 processing cycle
  * **Then** the OVERSPEED warning command is issued with priority 1 and STALL warning with priority 2; both are dispatched to SYS-003

### Component Verification: SYS-003 (Output Control)

#### Test Case: STP-003-A (End-to-End Output Latency)

**Technique**: Timing Analysis

* **System Scenario: STS-003-A1#**
  * **Given** the Output Control is receiving a STALL WARNING command from SYS-002
  * **When** the command is received at the SYS-003 input queue
  * **Then** the stick shaker actuator control signal transitions HIGH within 10 ms of receipt
  * **And** the total latency from ADIRU injection to stick shaker activation is ≤ 200 ms

#### Test Case: STP-003-B (AMU Alert Priority Encoding)

**Technique**: Interface Contract Testing

* **System Scenario: STS-003-B1#**
  * **Given** the Output Control has an active OVERSPEED warning command at priority 1
  * **When** a lower-priority ATTITUDE LIMIT warning command is also active
  * **Then** the ARINC 429 AMU output transmits the OVERSPEED alert code; ATTITUDE LIMIT is queued for sequential transmission

#### Test Case: STP-003-C (Fail-Safe Output on Power Loss)

**Technique**: Fault Injection

* **System Scenario: STS-003-C1#**
  * **Given** the Output Control is in MONITORING state with no active warnings
  * **When** the 28 VDC supply to the stick shaker output driver is interrupted
  * **Then** the BITE current monitor detects open circuit within 20 ms and activates the STICK SHAKER FAIL annunciator

## Coverage Summary

| Component | Test Cases | Scenarios | DO-178C Techniques |
|-----------|-----------|-----------|-------------------|
| SYS-001 | 2 (STP-001-A, STP-001-B) | 3 (STS-001-A1#, STS-001-A2#, STS-001-B1#) | BVA, Fault Injection |
| SYS-002 | 3 (STP-002-A, STP-002-B, STP-002-C) | 5 (STS-002-A1#, STS-002-A2#, STS-002-B1#, STS-002-B2#, STS-002-C1#) | BVA, Decision Table |
| SYS-003 | 3 (STP-003-A, STP-003-B, STP-003-C) | 3 (STS-003-A1#, STS-003-B1#, STS-003-C1#) | Timing Analysis, IFT, FI |

**SYS Coverage: 100%** — All 3 system components verified with positive, boundary, and fault-injection tests.

## V&V Coverage Gate (IEEE 1012:2016)

| V&V Activity | Objective | Evidence Artifact |
|-------------|-----------|------------------|
| System Test Execution | Verify all SYS-NNN components against requirements | This document + test results |
| DO-178C Table A-7 | System testing confirms DAL-A software requirements satisfaction | STP records with pass/fail verdict |
| Timing Verification | End-to-end latency ≤ 500 ms (200 ms for stall) | STS-003-A1# timing measurement log |
| Entry Criteria | System test configuration controlled; requirements baselined | CM records reference |
| Exit Criteria | All STP test cases executed; 0 open safety-critical defects | Test completion report |

## Governing Standards

| Standard | Full Name | Role in this Document |
|----------|-----------|----------------------|
| **DO-178C** | Software Considerations in Airborne Systems and Equipment Certification | DAL-A system test objectives (Table A-7); MC/DC coverage requirements |
| **IEEE 1012:2016** | System, Software, and Hardware V&V | V&V Coverage Gate: entry/exit criteria, independence requirements for DAL-A |
| **ISO/IEC/IEEE 29119-4:2021** | Software and Systems Engineering — Test Design Techniques | BVA, Decision Table, Fault Injection test design methods |
