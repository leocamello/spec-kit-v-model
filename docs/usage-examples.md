# Usage Examples

This guide walks through concrete usage scenarios for the V-Model Extension Pack, using examples from regulated industries where the V-Model is mandatory.

## Prerequisites

1. A project with Spec Kit installed and configured
2. The V-Model extension installed:
   ```bash
   specify extension add v-model
   ```
   Or for local development:
   ```bash
   specify extension add --dev /path/to/spec-kit-v-model
   ```

## Example 1: Medical Device — Patient Vital Signs Monitor (IEC 62304)

A medical device software team is building a **Patient Vital Signs Monitoring System** that reads heart rate, blood pressure, and oxygen saturation from bedside sensors, displays them on a dashboard, and triggers clinical alarms when values exceed safe thresholds. This software is classified as **IEC 62304 Class C** (could contribute to a hazardous situation resulting in death or serious injury).

### Step 1: Generate Feature Specification (Spec Kit Core)

```
/speckit.specify A patient vital signs monitoring system that continuously reads
heart rate (HR), blood pressure (BP), and blood oxygen saturation (SpO2) from
bedside sensors. The system displays real-time values on a clinical dashboard,
stores historical readings for trend analysis, and triggers audible and visual
alarms when any vital sign exceeds configurable clinical thresholds. The system
must comply with IEC 62304 Class C and IEC 60601-1-8 alarm standards.
```

This creates `specs/{feature}/spec.md` with the narrative feature specification.

### Step 2: Generate V-Model Requirements

```
/speckit.v-model.requirements
```

The command reads `spec.md` and generates `specs/{feature}/v-model/requirements.md` with formal, testable requirements:

```markdown
### Functional Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-001 | The system SHALL read heart rate values from the bedside sensor at a sampling rate of 1 Hz (±0.1 Hz) | P1 | Continuous monitoring requires consistent data acquisition — IEC 60601-1 | Test |
| REQ-002 | The system SHALL display the current heart rate value on the clinical dashboard within 1.0 second of sensor acquisition | P1 | Clinicians require real-time visibility to make treatment decisions | Test |
| REQ-003 | The system SHALL trigger an audible alarm within 2.0 seconds when heart rate exceeds the configurable upper threshold | P1 | Delayed alarms in critical care can result in patient harm — IEC 60601-1-8 | Test |
| REQ-004 | The system SHALL trigger an audible alarm within 2.0 seconds when heart rate drops below the configurable lower threshold | P1 | Bradycardia detection is safety-critical | Test |
| REQ-005 | The system SHALL store each vital sign reading with a UTC timestamp in persistent storage with a retention period of 72 hours minimum | P1 | Clinical trend analysis and regulatory audit trail | Test |
| REQ-006 | The system SHALL allow authorized clinical staff to configure alarm thresholds for each vital sign parameter | P1 | Threshold customization per patient condition | Demonstration |
| REQ-007 | The system SHALL display a visual "Sensor Disconnected" indicator within 3.0 seconds of losing communication with a bedside sensor | P1 | Clinicians must distinguish between a flat-line reading and a disconnected sensor — failure to do so is a known hazard | Test |

### Non-Functional Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-NF-001 | The system SHALL maintain 99.99% availability during a 24-hour operational period | P1 | Life-sustaining monitoring cannot have downtime | Analysis |
| REQ-NF-002 | The system SHALL process and display all three vital sign parameters with end-to-end latency not exceeding 1.5 seconds from sensor reading to dashboard update | P1 | Clinical decision-making requires current data | Test |

### Constraint Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-CN-001 | The system MUST comply with IEC 62304 software lifecycle requirements for Class C medical device software | P1 | Regulatory — required for device certification | Inspection |
| REQ-CN-002 | The system MUST implement alarm signals compliant with IEC 60601-1-8 priority categories (high, medium, low) | P1 | Regulatory — alarm standardization for patient safety | Inspection |
```

Notice how every requirement satisfies the IEEE 29148 criteria:
- **Unambiguous**: "within 2.0 seconds" instead of "quickly"
- **Testable**: Each has a concrete pass/fail condition
- **Atomic**: REQ-003 (upper threshold alarm) and REQ-004 (lower threshold alarm) are split, not combined
- **Traceable**: Each links to a regulatory clause or clinical rationale

### Step 3: Generate Acceptance Test Plan

```
/speckit.v-model.acceptance
```

The command reads `requirements.md` and generates `specs/{feature}/v-model/acceptance-plan.md`:

```markdown
### Requirement Validation: REQ-003 (Heart Rate Upper Threshold Alarm)

#### Test Case: ATP-003-A (Alarm Triggers at Exact Threshold Crossing)
**Linked Requirement:** REQ-003
**Description:** Verify the system triggers an audible alarm within 2.0 seconds
when heart rate exceeds the configured upper threshold.
**Validation Condition:** Audible alarm activates within 2.0 seconds of the
sensor reporting a heart rate value above the threshold.
**Expected Result:** Alarm sound begins within 2.0 seconds; alarm event is
logged with timestamp, vital sign type "HR", and triggering value.

* **User Scenario: SCN-003-A1**
  * **Given** the heart rate upper threshold is configured to 120 BPM
    for the monitored patient
  * **And** the system is receiving normal heart rate readings of 80 BPM
  * **When** the bedside sensor reports a heart rate of 121 BPM
  * **Then** the system activates an audible high-priority alarm
    within 2.0 seconds of the reading
  * **And** the dashboard displays the heart rate value in red
    with a flashing alarm indicator

#### Test Case: ATP-003-B (Alarm Does NOT Trigger at Threshold Boundary)
**Linked Requirement:** REQ-003
**Description:** Verify the alarm does not trigger when heart rate equals
but does not exceed the threshold (boundary condition).
**Validation Condition:** No alarm when HR equals threshold exactly.
**Expected Result:** No alarm is triggered; dashboard displays normal
heart rate indication.

* **User Scenario: SCN-003-B1**
  * **Given** the heart rate upper threshold is configured to 120 BPM
  * **When** the bedside sensor reports a heart rate of exactly 120 BPM
  * **Then** the system does NOT activate an audible alarm
  * **And** the dashboard displays the heart rate value in normal color

#### Test Case: ATP-003-C (Alarm Response Time Under Load)
**Linked Requirement:** REQ-003
**Description:** Verify alarm timing is maintained when the system is
monitoring all three vital signs simultaneously.
**Validation Condition:** Alarm activates within 2.0 seconds even under
full sensor load.
**Expected Result:** Alarm latency ≤ 2.0 seconds with all sensors active.

* **User Scenario: SCN-003-C1**
  * **Given** the system is simultaneously monitoring HR, BP, and SpO2
    from three active sensors
  * **And** the heart rate upper threshold is configured to 120 BPM
  * **When** the bedside sensor reports a heart rate of 150 BPM
  * **Then** the system activates the audible alarm within 2.0 seconds

### Requirement Validation: REQ-007 (Sensor Disconnection Detection)

#### Test Case: ATP-007-A (Disconnect Detection Within Time Limit)
**Linked Requirement:** REQ-007
**Description:** Verify the system detects sensor disconnection and displays
the indicator within 3.0 seconds.
**Validation Condition:** Visual "Sensor Disconnected" indicator appears
within 3.0 seconds of communication loss.
**Expected Result:** Dashboard shows "Sensor Disconnected" for the
affected vital sign within 3.0 seconds; other vital signs continue
displaying normally.

* **User Scenario: SCN-007-A1**
  * **Given** the heart rate sensor is actively transmitting readings
    at 1 Hz to the monitoring system
  * **When** the sensor communication link is physically interrupted
  * **Then** the dashboard displays a "Sensor Disconnected" indicator
    for the heart rate parameter within 3.0 seconds
  * **And** the SpO2 and BP readings continue displaying normally
  * **And** a "sensor_disconnected" event is logged with the
    disconnection timestamp

#### Test Case: ATP-007-B (Distinguish Disconnect from Flat-Line)
**Linked Requirement:** REQ-007
**Description:** Verify the system distinguishes between a disconnected
sensor and a genuine zero/flat-line reading (critical safety scenario).
**Validation Condition:** A sensor reporting HR=0 is displayed differently
from a disconnected sensor.
**Expected Result:** HR=0 triggers a clinical alarm; disconnected sensor
shows the "Sensor Disconnected" indicator (not a zero reading).

* **User Scenario: SCN-007-B1**
  * **Given** the heart rate sensor is actively transmitting readings
  * **When** the sensor reports a heart rate value of 0 BPM (asystole)
  * **Then** the system activates a high-priority clinical alarm
  * **And** the dashboard displays "0 BPM" (not "Sensor Disconnected")
```

Notice the quality criteria in action:
- **Independent**: Each test case owns its preconditions (no shared state)
- **Repeatable**: Specific values (120 BPM, 121 BPM) ensure deterministic results
- **Declarative**: Scenarios describe behavior ("the system activates an alarm"), not UI mechanics ("click the alarm button")
- **Observable**: Every `Then` is a concrete, verifiable outcome

### Step 4: Generate System Design

```
/speckit.v-model.system-design
```

The command reads `requirements.md` and generates `specs/{feature}/v-model/system-design.md` with design elements aligned to IEEE 1016:2009 views:

```markdown
### Decomposition View

| ID | Component | Description | IEEE 1016 View |
|----|-----------|-------------|----------------|
| SYS-001 | SensorAcquisitionService | Reads HR, BP, SpO2 values from bedside sensors at 1 Hz sampling rate | Decomposition |
| SYS-002 | AlarmEngine | Evaluates vital signs against configurable thresholds and triggers audible/visual alarms within 2.0s | Decomposition |
| SYS-003 | ClinicalDashboard | Displays real-time vital signs, alarm states, and sensor status indicators | Decomposition |

### Interface View

| ID | Interface | Contract | IEEE 1016 View |
|----|-----------|----------|----------------|
| SYS-004 | SensorAcquisitionService → AlarmEngine | Publishes VitalSignReading(type, value, timestamp) at 1 Hz per sensor | Interface |
| SYS-005 | AlarmEngine → ClinicalDashboard | Emits AlarmEvent(severity, vitalSignType, triggeringValue, timestamp) | Interface |
```

### Step 5: Generate System Test Plan

```
/speckit.v-model.system-test
```

The command reads `system-design.md` and generates `specs/{feature}/v-model/system-test-plan.md` with test procedures mapped to ISO 29119-4 techniques:

```markdown
### Design Element Validation: SYS-002 (AlarmEngine)

#### Test Procedure: STP-002-A (Boundary Value Analysis — Threshold Crossing)
**Linked Design Element:** SYS-002
**ISO 29119-4 Technique:** Boundary Value Analysis
**Description:** Verify alarm engine behavior at exact threshold boundaries.

* **Test Step: STS-002-A1**
  * **Given** the AlarmEngine is initialized with HR upper threshold = 120 BPM
  * **When** a VitalSignReading(HR, 119, T) is received
  * **Then** no AlarmEvent is emitted

* **Test Step: STS-002-A2**
  * **Given** the AlarmEngine is initialized with HR upper threshold = 120 BPM
  * **When** a VitalSignReading(HR, 121, T) is received
  * **Then** an AlarmEvent(HIGH, HR, 121, T) is emitted within 2.0 seconds

#### Test Procedure: STP-002-B (Fault Injection — Sensor Failure)
**Linked Design Element:** SYS-002
**ISO 29119-4 Technique:** Fault Injection
**Description:** Verify alarm engine handles sensor communication failure gracefully.

* **Test Step: STS-002-B1**
  * **Given** the AlarmEngine is receiving normal VitalSignReadings
  * **When** the SensorAcquisitionService stops publishing for 3.0 seconds
  * **Then** the AlarmEngine emits a SensorDisconnected event (not a clinical alarm)
```

### Step 6: Generate Architecture Design

```
/speckit.v-model.architecture-design
```

The command reads `system-design.md` and generates `specs/{feature}/v-model/architecture-design.md` with architecture elements aligned to IEEE 42010/Kruchten 4+1 views:

```markdown
### Logical View

| ID | Module | Description | IEEE 42010 View |
|----|--------|-------------|-----------------|
| ARCH-001 | SensorProtocolAdapter | Abstracts vendor-specific sensor protocols into a unified VitalSignReading interface | Logical |
| ARCH-002 | ThresholdEvaluator | Stateless evaluation engine — compares incoming readings against configurable thresholds | Logical |
| ARCH-003 | AlarmDispatcher | Routes alarm events to audible, visual, and logging subsystems based on severity | Logical |

### Interface View

| ID | Interface | Contract | IEEE 42010 View |
|----|-----------|----------|-----------------|
| ARCH-004 | SensorProtocolAdapter → ThresholdEvaluator | Publishes VitalSignReading(type, value, timestamp) via in-process event bus | Interface |
| ARCH-005 | ThresholdEvaluator → AlarmDispatcher | Emits AlarmTrigger(severity, vitalSignType, value, threshold, timestamp) | Interface |

### Data Flow View

| ID | Flow | Description | IEEE 42010 View |
|----|------|-------------|-----------------|
| ARCH-006 | Sensor → Adapter → Evaluator → Dispatcher | End-to-end vital sign processing pipeline with <2.0s latency budget | Data Flow |

### Cross-Cutting Modules

| ID | Module | Description | Tag |
|----|--------|-------------|-----|
| ARCH-007 | AuditLogger | Structured logging for all alarm events and sensor state changes | CROSS-CUTTING |
```

### Step 7: Generate Integration Test Plan

```
/speckit.v-model.integration-test
```

The command reads `architecture-design.md` and generates `specs/{feature}/v-model/integration-test.md` with test procedures mapped to ISO 29119-4 integration techniques:

```markdown
### Architecture Element Validation: ARCH-004 (SensorProtocolAdapter → ThresholdEvaluator Interface)

#### Test Procedure: ITP-004-A (Interface Contract Testing — Event Schema)
**Linked Architecture Element:** ARCH-004
**ISO 29119-4 Technique:** Interface Contract Testing
**Description:** Verify the SensorProtocolAdapter publishes events conforming to the VitalSignReading contract.

* **Test Step: ITS-004-A1**
  * **Given** the SensorProtocolAdapter is connected to a mock HR sensor
  * **When** the sensor publishes a reading of 80 BPM
  * **Then** a VitalSignReading(HR, 80, T) event is published to the event bus with all required fields

#### Test Procedure: ITP-004-B (Data Flow Testing — End-to-End Pipeline)
**Linked Architecture Element:** ARCH-004
**ISO 29119-4 Technique:** Data Flow Testing
**Description:** Verify data flows correctly from adapter through evaluator without transformation loss.

* **Test Step: ITS-004-B1**
  * **Given** the ThresholdEvaluator is subscribed to the event bus
  * **When** the SensorProtocolAdapter publishes VitalSignReading(HR, 121, T)
  * **Then** the ThresholdEvaluator receives the event with value=121 and type=HR intact

#### Test Procedure: ITP-004-C (Interface Fault Injection — Adapter Failure)
**Linked Architecture Element:** ARCH-004
**ISO 29119-4 Technique:** Interface Fault Injection
**Description:** Verify the system handles adapter-to-evaluator communication failure gracefully.

* **Test Step: ITS-004-C1**
  * **Given** the SensorProtocolAdapter is publishing readings normally
  * **When** the event bus connection is interrupted for 3.0 seconds
  * **Then** the ThresholdEvaluator emits a SensorTimeout event (not a false alarm)
```

### Step 8: Build the Traceability Matrix (Progressive)

```
/speckit.v-model.trace
```

Run after acceptance for Matrix A, after system-test for A+B, after integration-test for A+B+C, and after unit-test for A+B+C+D.

**Section 1 — Coverage Audit:**
```
══════════════════════════════════════════════
  TRACEABILITY MATRIX — COVERAGE AUDIT
══════════════════════════════════════════════

  MATRIX A: Requirements → Acceptance Testing
  ────────────────────────────────────────────
  Total Requirements:                  11
  Requirements with Test Coverage:     11 (100%)
  Total Test Cases (ATP):              22
  Test Cases with Scenarios:           22 (100%)
  Total Executable Scenarios (SCN):    34

  FORWARD TRACEABILITY (REQ → ATP → SCN)
  Untested Requirements:               0  ✅ Pass
  ATPs Without Scenarios:              0  ✅ Pass

  BACKWARD TRACEABILITY (SCN → ATP → REQ)
  Orphaned Test Cases:                 0  ✅ Pass
  Orphaned Scenarios:                  0  ✅ Pass

  MATRIX A STATUS: ✅ COMPLIANT

  MATRIX B: System Design → System Testing
  ────────────────────────────────────────────
  Total Design Elements:               8
  Design Elements with Test Coverage:  8  (100%)
  Total Test Procedures (STP):         14
  Test Procedures with Steps:          14 (100%)
  Total Executable Steps (STS):        28

  FORWARD TRACEABILITY (SYS → STP → STS)
  Untested Design Elements:            0  ✅ Pass
  STPs Without Steps:                  0  ✅ Pass

  BACKWARD TRACEABILITY (STS → STP → SYS)
  Orphaned Test Procedures:            0  ✅ Pass
  Orphaned Steps:                      0  ✅ Pass

  MATRIX B STATUS: ✅ COMPLIANT

  MATRIX C: Architecture → Integration Testing
  ────────────────────────────────────────────
  Total Architecture Elements:         7
  Elements with Test Coverage:         7  (100%)
  Total Test Procedures (ITP):         12
  Test Procedures with Steps:          12 (100%)
  Total Executable Steps (ITS):        20
  CROSS-CUTTING Modules:              1

  FORWARD TRACEABILITY (SYS → ARCH → ITP → ITS)
  Untested Architecture Elements:      0  ✅ Pass
  ITPs Without Steps:                  0  ✅ Pass

  BACKWARD TRACEABILITY (ITS → ITP → ARCH → SYS)
  Orphaned Test Procedures:            0  ✅ Pass
  Orphaned Steps:                      0  ✅ Pass

  MATRIX C STATUS: ✅ COMPLIANT

  MATRIX D: Module Design → Unit Testing
  ────────────────────────────────────────────
  Total Module Designs:              7
  Modules with Test Coverage:        7  (100%)
  Total Test Procedures (UTP):       14
  Test Procedures with Scenarios:    14 (100%)
  Total Executable Scenarios (UTS):  28
  EXTERNAL Modules:                  1

  FORWARD TRACEABILITY (ARCH → MOD → UTP → UTS)
  Untested Module Designs:           0  ✅ Pass
  UTPs Without Scenarios:            0  ✅ Pass

  BACKWARD TRACEABILITY (UTS → UTP → MOD → ARCH)
  Orphaned Test Procedures:          0  ✅ Pass
  Orphaned Scenarios:                0  ✅ Pass

  MATRIX D STATUS: ✅ COMPLIANT

  OVERALL STATUS: ✅ COMPLIANT (all four matrices)
══════════════════════════════════════════════
```

**Section 3 — Matrix excerpt:**

| REQ ID | Requirement Intent | Test Case ID | Validation Condition | Scenario ID | Status |
|---|---|---|---|---|---|
| REQ-003 | HR alarm within 2.0s of upper threshold | ATP-003-A | Alarm at threshold crossing | SCN-003-A1 | ⬜ Pending |
| | | ATP-003-B | No alarm at exact boundary | SCN-003-B1 | ⬜ Pending |
| | | ATP-003-C | Alarm timing under load | SCN-003-C1 | ⬜ Pending |
| REQ-007 | Sensor disconnect indicator within 3.0s | ATP-007-A | Detect within time limit | SCN-007-A1 | ⬜ Pending |
| | | ATP-007-B | Distinguish disconnect from flat-line | SCN-007-B1 | ⬜ Pending |

This matrix is the audit artifact that IEC 62304 auditors will review to verify software verification completeness.

### Step 9: Generate Module Design

```
/speckit.v-model.module-design
```

The command reads `architecture-design.md` and generates `specs/{feature}/v-model/module-design.md` with detailed module designs aligned to DO-178C low-level requirements:

```markdown
### Module: MOD-001 (SensorProtocolParser)

**Source File:** `src/sensor_protocol_parser.py`
**Parent Architecture Elements:** ARCH-001

#### Algorithmic / Logic View

```pseudocode
FUNCTION parse_vital_reading(raw_bytes: ByteArray) -> VitalSignReading:
    IF length(raw_bytes) < HEADER_SIZE THEN
        RETURN Error("Insufficient data: expected >= 8 bytes")
    END IF
    sensor_type = extract_enum(raw_bytes[0:2], VITAL_SIGN_TYPES)
    value = extract_float32(raw_bytes[2:6])
    timestamp = extract_utc_millis(raw_bytes[6:14])
    IF value < VALID_RANGE[sensor_type].min OR value > VALID_RANGE[sensor_type].max THEN
        RETURN Error("Value out of range for " + sensor_type)
    END IF
    RETURN VitalSignReading(sensor_type, value, timestamp)
END FUNCTION
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size | Constraint |
|------|------|------|------------|
| HEADER_SIZE | const int | 4 bytes | Fixed at 8 |
| VITAL_SIGN_TYPES | enum | 3 values | {HR, BP, SpO2} |
| VALID_RANGE | dict | 3 entries | HR: 0-300, BP: 0-400, SpO2: 0-100 |

#### Error Handling & Return Codes

| Error Condition | Return | Upstream Contract |
|----------------|--------|-------------------|
| Insufficient bytes | Error("Insufficient data") | ARCH-001 Interface View: caller retries |
| Out-of-range value | Error("Value out of range") | ARCH-001 Interface View: logged and discarded |
```

### Step 10: Generate Unit Test Plan

```
/speckit.v-model.unit-test
```

The command reads `module-design.md` and generates `specs/{feature}/v-model/unit-test.md` with white-box unit test procedures:

```markdown
### Module Under Test: MOD-001 (SensorProtocolParser)

#### Test Procedure: UTP-001-A (Statement & Branch Coverage — parse_vital_reading)
**Linked Module:** MOD-001
**Technique:** Statement & Branch Coverage
**Description:** Exercise every line and branch of the parse_vital_reading function.

**Dependency & Mock Registry:** None — module is self-contained.

* **Unit Scenario: UTS-001-A1**
  * **Arrange:** Construct valid raw_bytes for HR sensor: [0x00, 0x01, ...] (14 bytes, value=80.0)
  * **Act:** Call parse_vital_reading(raw_bytes)
  * **Assert:** Returns VitalSignReading(HR, 80.0, expected_timestamp)

* **Unit Scenario: UTS-001-A2**
  * **Arrange:** Construct raw_bytes with only 4 bytes (below HEADER_SIZE)
  * **Act:** Call parse_vital_reading(raw_bytes)
  * **Assert:** Returns Error("Insufficient data: expected >= 8 bytes")

#### Test Procedure: UTP-001-B (Boundary Value Analysis — Value Ranges)
**Linked Module:** MOD-001
**Technique:** Boundary Value Analysis
**Description:** Test parse_vital_reading at exact boundary values.

**Dependency & Mock Registry:** None — module is self-contained.

* **Unit Scenario: UTS-001-B1**
  * **Arrange:** Construct raw_bytes for HR with value = 0 (minimum valid)
  * **Act:** Call parse_vital_reading(raw_bytes)
  * **Assert:** Returns VitalSignReading(HR, 0, timestamp) — accepted

* **Unit Scenario: UTS-001-B2**
  * **Arrange:** Construct raw_bytes for HR with value = 301 (above maximum)
  * **Act:** Call parse_vital_reading(raw_bytes)
  * **Assert:** Returns Error("Value out of range for HR")
```

### Step 11: Continue with Spec Kit Core

```
/speckit.plan
/speckit.tasks
/speckit.implement
```

## Example 2: Automotive — ADAS Emergency Braking (ISO 26262)

For an Advanced Driver Assistance System (ADAS) with autonomous emergency braking, the same workflow applies but with automotive safety constraints:

```
/speckit.v-model.requirements
```

Example requirements:
```markdown
| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-001 | The ADAS SHALL initiate emergency braking within 150 milliseconds of detecting a collision-imminent object at distances ≤ 30 meters at vehicle speeds ≥ 30 km/h | P1 | ISO 26262 ASIL-D — failure to brake is life-threatening | Test |
| REQ-002 | The ADAS SHALL NOT initiate emergency braking for stationary objects detected at distances > 100 meters (false positive prevention) | P1 | False braking on highways causes rear-end collisions | Test |
| REQ-CN-001 | The ADAS MUST achieve ASIL-D integrity level per ISO 26262 Part 3 for the emergency braking function | P1 | Regulatory — highest automotive safety integrity level | Inspection |
```

The acceptance command then generates test cases with automotive-specific scenarios:

```markdown
#### Test Case: ATP-001-A (Braking Initiation Time — Pedestrian)
* **User Scenario: SCN-001-A1**
  * **Given** the vehicle is traveling at 50 km/h on a dry road surface
  * **And** the forward-facing sensor suite is fully operational
  * **When** a pedestrian is detected at 25 meters in the vehicle's path
  * **Then** the ADAS initiates full emergency braking within 150 milliseconds
  * **And** the braking event is logged with timestamp, distance, speed, and object classification
```

## Example 3: Handling Requirement Changes

When requirements change after the acceptance plan exists:

```
# Modify REQ-003: Change alarm threshold from 2.0 seconds to 1.5 seconds
# (based on updated clinical risk assessment)

/speckit.v-model.acceptance
```

The command:
1. Detects REQ-003 was modified (via `diff-requirements.sh`)
2. Regenerates ONLY `ATP-003-*` and `SCN-003-*` sections
3. Leaves all other ATPs/SCNs untouched
4. Runs coverage validation to confirm no gaps

Then re-run trace to update the matrix:
```
/speckit.v-model.trace
```

## Example 4: Handling Coverage Gaps

If you add requirements without regenerating acceptance tests:

```
/speckit.v-model.trace
```

Output:
```
⚠️  EXCEPTION REPORT
────────────────────
GAPS (Forward Traceability Failures):
  • REQ-008: "The system SHALL archive vital sign data older than 72 hours
    to cold storage" — NO TEST CASE FOUND

OVERALL STATUS: ❌ NON-COMPLIANT
```

Fix by running:
```
/speckit.v-model.acceptance
```

This generates the missing ATPs/SCNs for REQ-008, then re-run trace to verify compliance.

## Workflow Summary

```
/speckit.specify              → Feature specification (narrative)
/speckit.v-model.requirements → Formal requirements (REQ-NNN, IEEE 29148 quality)
/speckit.v-model.acceptance   → Test cases + scenarios (ATP/SCN, BDD format)
/speckit.v-model.system-design       → System design elements (SYS-NNN, IEEE 1016 views)
/speckit.v-model.system-test        → Test procedures + steps (STP/STS, ISO 29119-4 techniques)
/speckit.v-model.architecture-design→ Architecture elements (ARCH-NNN, IEEE 42010/4+1 views)
/speckit.v-model.integration-test   → Integration test procedures + steps (ITP/ITS, ISO 29119-4 techniques)
/speckit.v-model.module-design      → Module designs (MOD-NNN, pseudocode + 4 views)
/speckit.v-model.unit-test          → Unit test procedures + scenarios (UTP/UTS, white-box techniques)
/speckit.v-model.trace              → Quadruple traceability matrix (Matrix A + B + C + D audit artifact)
/speckit.plan                 → Technical implementation plan
/speckit.tasks                → Task breakdown
/speckit.implement            → Code generation
```
