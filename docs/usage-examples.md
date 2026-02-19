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

### Step 4: Build the Traceability Matrix

```
/speckit.v-model.trace
```

**Section 1 — Coverage Audit:**
```
══════════════════════════════════════════════
  TRACEABILITY MATRIX — COVERAGE AUDIT
══════════════════════════════════════════════
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

  OVERALL STATUS: ✅ COMPLIANT
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

### Step 5: Continue with Spec Kit Core

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
/speckit.v-model.trace        → Traceability matrix (regulatory audit artifact)
/speckit.plan                 → Technical implementation plan
/speckit.tasks                → Task breakdown
/speckit.implement            → Code generation
```
