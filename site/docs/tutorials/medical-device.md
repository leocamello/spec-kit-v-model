---
title: "Tutorial: Blood Glucose Monitor (IEC 62304 Class C)"
description: End-to-end V-Model walkthrough for a blood glucose monitoring system, covering all four V-Model levels, hazard analysis, peer review, test results, and audit reporting under IEC 62304 Class C.
---

# Tutorial: Blood Glucose Monitor (IEC 62304 Class C)

## What You'll Learn

In this tutorial you will build a **complete, audit-ready V-Model artifact set** for a blood glucose monitoring system — from initial requirements through unit tests, hazard analysis, and a final compliance audit report. By the end you will have:

- Formal requirements traced to acceptance tests (**Matrix A**)
- System design traced to system tests (**Matrix B**)
- Architecture design traced to integration tests (**Matrix C**)
- Module design traced to unit tests (**Matrix D**)
- A hazard register with mitigations (**Matrix H**)
- A peer-review record and passing audit report

Every artifact lives in Git and is deterministically verifiable.

---

## Prerequisites

!!! info "Before you begin"

    1. **Spec Kit** is installed and available on your `PATH` (`specify --version`).
    2. The **V-Model Extension Pack** is installed:
       ```bash
       specify extension add v-model
       ```
    3. You have basic familiarity with a terminal (Bash or PowerShell).
    4. A new or existing Spec Kit project is initialized (`specify init`).

---

## Scenario

You are building software for a **continuous blood glucose monitoring (CGM) system** used by patients with diabetes. The device:

- Reads interstitial glucose from a subcutaneous sensor
- Displays real-time glucose values on a companion mobile app
- Triggers hypo-/hyperglycemia alerts
- Logs readings for trend analysis and clinician review
- Communicates via Bluetooth Low Energy (BLE)
- Must operate on a single battery charge for ≥ 14 days

Because incorrect readings or missed alerts could result in **death or serious injury**, this software is classified as **IEC 62304 Class C** — the highest safety classification.

---

## Step 1 — Configure the V-Model Domain

Create (or update) the project-level configuration file so the extension generates artifacts aligned to IEC 62304.

=== "Bash"

    ```bash
    cat > v-model-config.yml << 'EOF'
    domain: iec_62304
    safety_class: C
    standards:
      - IEC 62304:2006/AMD1:2015
      - ISO 14971:2019
    project:
      name: "CGM-3000 Blood Glucose Monitor"
      version: "1.0.0"
    EOF
    ```

=== "PowerShell"

    ```powershell
    @"
    domain: iec_62304
    safety_class: C
    standards:
      - IEC 62304:2006/AMD1:2015
      - ISO 14971:2019
    project:
      name: "CGM-3000 Blood Glucose Monitor"
      version: "1.0.0"
    "@ | Set-Content v-model-config.yml
    ```

!!! tip "Domain matters"

    Setting `domain: iec_62304` tells the extension to include IEC 62304–specific sections (software safety classification, SOUP identification, anomaly management) in every generated artifact. If you use `domain: iso_26262` instead, you get ASIL-level annotations — see the [Automotive ADAS tutorial](automotive-adas.md).

---

## Step 2 — Write the Feature Specification

Use Spec Kit's core `specify` command to write a narrative feature spec.

```
/speckit.specify A continuous blood glucose monitoring system that reads
interstitial glucose levels from a subcutaneous electrochemical sensor every
5 minutes. The system transmits readings via Bluetooth Low Energy to a companion
mobile application, which displays the current glucose value, trend arrows,
and a historical graph. The system triggers configurable audible and haptic
alerts when glucose falls below a hypoglycemia threshold or exceeds a
hyperglycemia threshold. All readings are stored locally with UTC timestamps
for a minimum of 90 days, and can be exported for clinician review.
The device must operate on a single CR2032 battery for at least 14 days.
The software is classified IEC 62304 Class C.
```

This generates `specs/cgm-3000/spec.md` — the narrative specification that drives every downstream artifact.

---

## Step 3 — Level 1: Requirements → Acceptance Tests → Trace

### 3a. Generate Requirements

```
/speckit.v-model.requirements
```

The extension reads your `spec.md` and produces `specs/cgm-3000/v-model/requirements.md` containing formal, testable requirements:

??? example "Example output — `requirements.md` (excerpt)"

    ```markdown
    ### Functional Requirements

    | ID | Description | Priority | Rationale | Verification Method |
    |----|-------------|----------|-----------|---------------------|
    | REQ-001 | The system SHALL sample interstitial glucose from the subcutaneous sensor every 5 minutes (±15 seconds) | P1 | Continuous monitoring requires predictable sampling — IEC 62304 §5.2 | Test |
    | REQ-002 | The system SHALL display the current glucose value on the companion app within 10 seconds of sensor acquisition | P1 | Patient needs timely awareness of glucose level | Test |
    | REQ-003 | The system SHALL trigger an audible and haptic alert within 30 seconds when glucose falls below the configurable hypoglycemia threshold (default 70 mg/dL) | P1 | Missed hypoglycemia alert can result in loss of consciousness — ISO 14971 | Test |
    | REQ-004 | The system SHALL trigger an audible and haptic alert within 30 seconds when glucose exceeds the configurable hyperglycemia threshold (default 250 mg/dL) | P1 | Prolonged hyperglycemia leads to diabetic ketoacidosis — ISO 14971 | Test |
    | REQ-005 | The system SHALL store each glucose reading with a UTC timestamp in persistent local storage with a retention period of 90 days minimum | P1 | Clinician review and regulatory audit trail | Test |
    | REQ-006 | The system SHALL transmit readings to the companion app via Bluetooth Low Energy (BLE 5.0+) | P1 | Wireless connectivity is a core product feature | Test |

    ### Non-Functional Requirements

    | ID | Description | Priority | Rationale | Verification Method |
    |----|-------------|----------|-----------|---------------------|
    | REQ-NF-001 | The device SHALL operate on a single CR2032 battery for a minimum of 14 days under normal sampling conditions (288 readings/day) | P1 | Patient convenience and safety — battery failure disables monitoring | Test |

    ### Constraint Requirements

    | ID | Description | Priority | Rationale | Verification Method |
    |----|-------------|----------|-----------|---------------------|
    | REQ-CN-001 | The software MUST comply with IEC 62304 lifecycle requirements for Class C medical device software | P1 | Regulatory — required for device certification | Inspection |
    ```

!!! note "Quality check"

    Every requirement is **unambiguous** ("within 30 seconds", not "quickly"), **testable** (concrete pass/fail), **atomic** (hypo and hyper alerts are separate REQs), and **traceable** (links to IEC 62304 or ISO 14971 clauses).

### 3b. Generate Acceptance Test Plan

```
/speckit.v-model.acceptance
```

This reads `requirements.md` and produces `acceptance-plan.md` with BDD-style test cases for every requirement:

??? example "Example output — `acceptance-plan.md` (excerpt for REQ-003)"

    ```markdown
    ### Requirement Validation: REQ-003 (Hypoglycemia Alert)

    #### Test Case: ATP-003-A (Alert Triggers Below Threshold)
    **Linked Requirement:** REQ-003
    **Description:** Verify the system triggers an audible and haptic alert within
    30 seconds when glucose falls below the hypoglycemia threshold.

    * **User Scenario: SCN-003-A1**
      * **Given** the hypoglycemia threshold is configured to 70 mg/dL
      * **And** the system is receiving normal glucose readings of 100 mg/dL
      * **When** the sensor reports a glucose value of 65 mg/dL
      * **Then** the system activates an audible alert within 30 seconds
      * **And** the system activates a haptic alert within 30 seconds
      * **And** the companion app displays the value in red with a warning icon

    #### Test Case: ATP-003-B (No Alert at Boundary)
    **Linked Requirement:** REQ-003
    **Description:** Verify the alert does NOT trigger when glucose equals
    the threshold exactly.

    * **User Scenario: SCN-003-B1**
      * **Given** the hypoglycemia threshold is configured to 70 mg/dL
      * **When** the sensor reports a glucose value of exactly 70 mg/dL
      * **Then** the system does NOT activate an alert
      * **And** the companion app displays the value in normal color
    ```

### 3c. Build Traceability Matrix A

```
/speckit.v-model.trace
```

The trace command validates **forward traceability** (every REQ has at least one ATP/SCN) and **backward traceability** (no orphaned tests):

```
══════════════════════════════════════════════
  TRACEABILITY MATRIX — COVERAGE AUDIT
══════════════════════════════════════════════

  MATRIX A: Requirements → Acceptance Testing
  ────────────────────────────────────────────
  Total Requirements:                   9
  Requirements with Test Coverage:      9 (100%)
  Total Test Cases (ATP):              18
  Test Cases with Scenarios:           18 (100%)
  Total Executable Scenarios (SCN):    28

  FORWARD TRACEABILITY (REQ → ATP → SCN)
  Untested Requirements:               0  ✅ Pass

  BACKWARD TRACEABILITY (SCN → ATP → REQ)
  Orphaned Test Cases:                 0  ✅ Pass

  MATRIX A STATUS: ✅ COMPLIANT
══════════════════════════════════════════════
```

!!! success "Checkpoint"

    At this point every requirement has a corresponding acceptance test. An auditor can verify that nothing was missed.

---

## Step 4 — Level 2: System Design → System Tests

### 4a. Generate System Design

```
/speckit.v-model.system-design
```

The extension decomposes the requirements into system-level components following **IEEE 1016:2009** views:

??? example "Example output — `system-design.md` (excerpt)"

    ```markdown
    ### Decomposition View

    | ID | Component | Description | IEEE 1016 View |
    |----|-----------|-------------|----------------|
    | SYS-001 | GlucoseSensorDriver | Interfaces with the electrochemical sensor, reads raw analog values, applies calibration, and emits glucose readings every 5 minutes | Decomposition |
    | SYS-002 | AlertEngine | Evaluates glucose readings against configurable hypo/hyper thresholds and triggers audible and haptic alerts within 30 seconds | Decomposition |
    | SYS-003 | BLETransmitter | Manages Bluetooth Low Energy connection lifecycle and transmits glucose readings to the companion app | Decomposition |
    | SYS-004 | DataStore | Persists glucose readings with UTC timestamps for 90-day retention | Decomposition |
    | SYS-005 | CompanionAppUI | Displays real-time glucose, trend arrows, historical graph, and alert states | Decomposition |

    ### Interface View

    | ID | Interface | Contract | IEEE 1016 View |
    |----|-----------|----------|----------------|
    | SYS-006 | GlucoseSensorDriver → AlertEngine | Publishes GlucoseReading(value_mg_dL, timestamp) every 5 min | Interface |
    | SYS-007 | GlucoseSensorDriver → BLETransmitter | Passes GlucoseReading for wireless transmission | Interface |
    | SYS-008 | GlucoseSensorDriver → DataStore | Writes GlucoseReading for persistent storage | Interface |
    ```

### 4b. Generate System Test Plan

```
/speckit.v-model.system-test
```

Generates test procedures mapped to **ISO 29119-4** techniques for each system design element:

??? example "Example output — `system-test-plan.md` (excerpt for SYS-002)"

    ```markdown
    ### Design Element Validation: SYS-002 (AlertEngine)

    #### Test Procedure: STP-002-A (Boundary Value Analysis — Threshold Crossing)
    **Linked Design Element:** SYS-002
    **ISO 29119-4 Technique:** Boundary Value Analysis

    * **Test Step: STS-002-A1**
      * **Given** AlertEngine is initialized with hypo threshold = 70 mg/dL
      * **When** a GlucoseReading(69, T) is received
      * **Then** an AlertEvent(HYPO, 69, T) is emitted within 30 seconds

    * **Test Step: STS-002-A2**
      * **Given** AlertEngine is initialized with hypo threshold = 70 mg/dL
      * **When** a GlucoseReading(70, T) is received
      * **Then** no AlertEvent is emitted

    #### Test Procedure: STP-002-B (Fault Injection — Sensor Failure)
    **Linked Design Element:** SYS-002
    **ISO 29119-4 Technique:** Fault Injection

    * **Test Step: STS-002-B1**
      * **Given** AlertEngine is receiving normal GlucoseReadings
      * **When** GlucoseSensorDriver stops publishing for 10 minutes
      * **Then** AlertEngine emits a SensorTimeout event (not a hypo alert)
    ```

### 4c. Build Traceability Matrix A + B

```
/speckit.v-model.trace
```

```
  MATRIX B: System Design → System Testing
  ────────────────────────────────────────────
  Total Design Elements:               8
  Design Elements with Test Coverage:  8  (100%)
  Total Test Procedures (STP):        14
  Total Executable Steps (STS):       26

  MATRIX B STATUS: ✅ COMPLIANT
```

---

## Step 5 — Level 3: Architecture Design → Integration Tests

### 5a. Generate Architecture Design

```
/speckit.v-model.architecture-design
```

Produces architecture elements following **IEEE 42010 / Kruchten 4+1** views:

??? example "Example output — `architecture-design.md` (excerpt)"

    ```markdown
    ### Logical View

    | ID | Module | Description | IEEE 42010 View |
    |----|--------|-------------|-----------------|
    | ARCH-001 | SensorCalibrationEngine | Applies factory calibration curves and temperature compensation to raw sensor ADC values | Logical |
    | ARCH-002 | ThresholdEvaluator | Stateless comparator — evaluates glucose values against configurable thresholds | Logical |
    | ARCH-003 | AlertDispatcher | Routes alert events to audible (piezo buzzer), haptic (vibration motor), and BLE notification subsystems | Logical |
    | ARCH-004 | BLEStackAdapter | Abstracts platform BLE stack into a connection/disconnect/transmit interface | Logical |

    ### Data Flow View

    | ID | Flow | Description | IEEE 42010 View |
    |----|------|-------------|-----------------|
    | ARCH-005 | Sensor → Calibration → Evaluator → Dispatcher | End-to-end glucose processing pipeline with < 30s alert latency budget | Data Flow |

    ### Cross-Cutting Modules

    | ID | Module | Description | Tag |
    |----|--------|-------------|-----|
    | ARCH-006 | AuditLogger | Structured logging for all alert events, sensor faults, and calibration changes | CROSS-CUTTING |
    | ARCH-007 | PowerManager | Battery voltage monitoring and low-power sleep scheduling | CROSS-CUTTING |
    ```

### 5b. Generate Integration Test Plan

```
/speckit.v-model.integration-test
```

??? example "Example output — `integration-test.md` (excerpt)"

    ```markdown
    ### Architecture Element Validation: ARCH-001 → ARCH-002 Interface

    #### Test Procedure: ITP-001-A (Interface Contract Testing)
    **Linked Architecture Element:** ARCH-001 → ARCH-002
    **ISO 29119-4 Technique:** Interface Contract Testing

    * **Test Step: ITS-001-A1**
      * **Given** SensorCalibrationEngine outputs a calibrated GlucoseReading
      * **When** the reading is published to ThresholdEvaluator
      * **Then** ThresholdEvaluator receives the reading with value and timestamp intact

    #### Test Procedure: ITP-001-B (Data Flow Testing — End-to-End Pipeline)
    **Linked Architecture Element:** ARCH-005
    **ISO 29119-4 Technique:** Data Flow Testing

    * **Test Step: ITS-001-B1**
      * **Given** a raw ADC value of 2048 (corresponding to 85 mg/dL after calibration)
      * **When** the value flows through Calibration → Evaluator → Dispatcher
      * **Then** no alert is emitted (85 mg/dL is within normal range)
      * **And** the reading reaches DataStore with value = 85 mg/dL
    ```

### 5c. Build Traceability Matrix A + B + C

```
/speckit.v-model.trace
```

```
  MATRIX C: Architecture → Integration Testing
  ────────────────────────────────────────────
  Total Architecture Elements:         7
  Elements with Test Coverage:         7  (100%)
  Total Test Procedures (ITP):        12
  Total Executable Steps (ITS):       22
  CROSS-CUTTING Modules:              2

  MATRIX C STATUS: ✅ COMPLIANT
```

---

## Step 6 — Level 4: Module Design → Unit Tests

### 6a. Generate Module Design

```
/speckit.v-model.module-design
```

Produces detailed module designs with pseudocode, state machines, data structures, and error handling:

??? example "Example output — `module-design.md` (excerpt for MOD-001)"

    ```markdown
    ### Module: MOD-001 (CalibrationCurveApplicator)

    **Source File:** `src/calibration_curve_applicator.c`
    **Parent Architecture Element:** ARCH-001

    #### Algorithmic / Logic View

    ```pseudocode
    FUNCTION apply_calibration(raw_adc: uint16, curve: CalibrationCurve) -> GlucoseReading:
        IF raw_adc < ADC_MIN OR raw_adc > ADC_MAX THEN
            RETURN Error("ADC value out of range")
        END IF
        voltage_mv = (raw_adc / ADC_RESOLUTION) * VREF_MV
        glucose_mg_dL = (voltage_mv - curve.offset) * curve.slope
        IF glucose_mg_dL < 20.0 OR glucose_mg_dL > 500.0 THEN
            RETURN Error("Glucose value out of physiological range")
        END IF
        RETURN GlucoseReading(glucose_mg_dL, current_utc_timestamp())
    END FUNCTION
    ```

    #### Internal Data Structures

    | Name | Type | Size | Constraint |
    |------|------|------|------------|
    | ADC_MIN | const uint16 | 2 bytes | 0 |
    | ADC_MAX | const uint16 | 2 bytes | 4095 (12-bit ADC) |
    | VREF_MV | const float | 4 bytes | 3300.0 |
    | CalibrationCurve | struct | 8 bytes | slope: float, offset: float |

    #### Error Handling & Return Codes

    | Error Condition | Return | Upstream Contract |
    |----------------|--------|-------------------|
    | ADC out of range | Error("ADC value out of range") | ARCH-001: caller retries next sample |
    | Physiological range violation | Error("Glucose value out of physiological range") | ARCH-001: logged, reading discarded |
    ```

### 6b. Generate Unit Test Plan

```
/speckit.v-model.unit-test
```

??? example "Example output — `unit-test.md` (excerpt for MOD-001)"

    ```markdown
    ### Module Under Test: MOD-001 (CalibrationCurveApplicator)

    #### Test Procedure: UTP-001-A (Statement & Branch Coverage)
    **Linked Module:** MOD-001
    **Technique:** Statement & Branch Coverage

    * **Unit Scenario: UTS-001-A1**
      * **Arrange:** raw_adc = 2048, curve = {slope: 0.05, offset: 10.0}
      * **Act:** Call apply_calibration(raw_adc, curve)
      * **Assert:** Returns GlucoseReading(72.4, timestamp)

    * **Unit Scenario: UTS-001-A2**
      * **Arrange:** raw_adc = 5000 (above ADC_MAX)
      * **Act:** Call apply_calibration(raw_adc, curve)
      * **Assert:** Returns Error("ADC value out of range")

    #### Test Procedure: UTP-001-B (Boundary Value Analysis)
    **Linked Module:** MOD-001
    **Technique:** Boundary Value Analysis

    * **Unit Scenario: UTS-001-B1**
      * **Arrange:** raw_adc = 0 (ADC_MIN boundary)
      * **Act:** Call apply_calibration(raw_adc, curve)
      * **Assert:** Returns GlucoseReading or Error depending on calibration curve

    * **Unit Scenario: UTS-001-B2**
      * **Arrange:** raw_adc producing glucose = 501.0 mg/dL (above physiological max)
      * **Act:** Call apply_calibration(raw_adc, curve)
      * **Assert:** Returns Error("Glucose value out of physiological range")
    ```

### 6c. Build Full Traceability Matrix A + B + C + D

```
/speckit.v-model.trace
```

```
  MATRIX D: Module Design → Unit Testing
  ────────────────────────────────────────────
  Total Module Designs:                7
  Modules with Test Coverage:          7  (100%)
  Total Test Procedures (UTP):        14
  Total Executable Scenarios (UTS):   28

  MATRIX D STATUS: ✅ COMPLIANT

  OVERALL STATUS: ✅ COMPLIANT (all matrices)
```

!!! success "All four V-Model levels are fully traced"

    Every requirement (REQ) traces down through system design (SYS), architecture (ARCH), and module design (MOD) — and each has a corresponding test artifact at every level.

---

## Step 7 — Hazard Analysis

```
/speckit.v-model.hazard-analysis
```

The extension reads all V-Model artifacts and generates a **hazard register** aligned to **ISO 14971** (risk management for medical devices):

??? example "Example output — `hazard-analysis.md` (excerpt)"

    ```markdown
    ### Hazard Register

    | ID | Hazard | Cause | Severity | Probability | Risk Level | Mitigation | Linked REQ | Residual Risk |
    |----|--------|-------|----------|-------------|------------|------------|-----------|---------------|
    | HAZ-001 | Patient receives no hypoglycemia alert while glucose is critically low | AlertEngine fails to evaluate threshold | Catastrophic | Remote | High | Watchdog timer restarts AlertEngine within 10s; redundant threshold check in CompanionAppUI | REQ-003 | Acceptable |
    | HAZ-002 | False hyperglycemia alert causes patient to administer unnecessary insulin | SensorCalibrationEngine applies incorrect calibration curve | Catastrophic | Remote | High | Dual-path calibration verification; alert requires 2 consecutive readings above threshold | REQ-004 | Acceptable |
    | HAZ-003 | Battery dies silently, patient unaware monitoring has stopped | PowerManager fails to trigger low-battery warning | Critical | Occasional | High | Hardware-level voltage comparator triggers independent low-battery LED; BLE notification sent at 10% remaining | REQ-NF-001 | Acceptable |
    | HAZ-004 | Sensor disconnection not detected, stale glucose value displayed as current | GlucoseSensorDriver does not detect communication loss | Critical | Occasional | Medium | Timeout watchdog marks reading as stale after 2 missed samples; UI shows "No Signal" indicator | REQ-006 | Acceptable |
    ```

!!! warning "IEC 62304 Class C requirement"

    For Class C software, **every** identified hazard must have a documented mitigation strategy, and the residual risk must be evaluated and accepted. The hazard register is a mandatory audit artifact.

---

## Step 8 — Peer Review

```
/speckit.v-model.peer-review
```

Run peer review on key artifacts to simulate a formal review process. The extension checks:

- **Completeness** — are all required sections present?
- **Consistency** — do IDs match across traceability chains?
- **Quality** — do requirements meet IEEE 29148 criteria (unambiguous, testable, atomic)?

```
══════════════════════════════════════════════
  PEER REVIEW — SUMMARY
══════════════════════════════════════════════
  Artifacts reviewed:           12
  Findings (Critical):          0   ✅
  Findings (Major):             0   ✅
  Findings (Minor):             2   ⚠️
    • REQ-NF-001: Consider adding units to "14 days" (e.g., "336 hours")
    • ARCH-007: PowerManager description could reference specific IEC 62304 clause
  REVIEW STATUS: APPROVED WITH MINOR FINDINGS
══════════════════════════════════════════════
```

---

## Step 9 — Ingest Test Results

After your team runs the actual tests (unit, integration, system, acceptance), feed the JUnit XML results back into the trace:

=== "Bash"

    ```bash
    /speckit.v-model.test-results --junit-xml ./test-output/results.xml
    ```

=== "PowerShell"

    ```powershell
    /speckit.v-model.test-results --junit-xml .\test-output\results.xml
    ```

The command:

1. **Parses** the JUnit XML file (compatible with pytest, JUnit, xUnit, and most CI runners)
2. **Maps** each `<testcase>` to a traceability ID (UTS, ITS, STS, or SCN)
3. **Updates** the traceability matrix with pass/fail status

```
  TEST RESULTS INGESTION
  ────────────────────────────────────────────
  JUnit XML file:              ./test-output/results.xml
  Total test cases parsed:     92
  Mapped to traceability IDs:  92 (100%)
  Passed:                      91
  Failed:                      1  ❌ UTS-001-A2
  Skipped:                     0

  ⚠️  1 failure detected — re-run trace to see impact on compliance status.
```

---

## Step 10 — Audit Report

```
/speckit.v-model.audit-report
```

The final compliance gate — generates a summary report that an IEC 62304 auditor can review:

```
══════════════════════════════════════════════
  AUDIT REPORT — CGM-3000 Blood Glucose Monitor
  IEC 62304 Class C | ISO 14971
══════════════════════════════════════════════

  Domain:                      iec_62304
  Safety Class:                C
  Standards:                   IEC 62304:2006/AMD1:2015, ISO 14971:2019

  TRACEABILITY
  ────────────────────────────────────────────
  Matrix A (REQ → ATP):        ✅ COMPLIANT
  Matrix B (SYS → STP):        ✅ COMPLIANT
  Matrix C (ARCH → ITP):       ✅ COMPLIANT
  Matrix D (MOD → UTP):        ✅ COMPLIANT
  Matrix H (HAZ → Mitigation): ✅ COMPLIANT

  HAZARD ANALYSIS
  ────────────────────────────────────────────
  Hazards identified:          4
  Hazards mitigated:           4 (100%)
  Residual risk accepted:      4 (100%)

  PEER REVIEW
  ────────────────────────────────────────────
  Status:                      APPROVED WITH MINOR FINDINGS
  Critical findings:           0
  Open findings:               2 (minor)

  TEST EXECUTION
  ────────────────────────────────────────────
  Total tests:                 92
  Passed:                      91
  Failed:                      1  ❌
  Coverage:                    98.9%

  OVERALL AUDIT STATUS: ⚠️ CONDITIONAL PASS
  Reason: 1 unit test failure (UTS-001-A2) must be resolved
══════════════════════════════════════════════
```

!!! danger "Gating"

    The audit report acts as a **compliance gate**. A status of `❌ FAIL` or `⚠️ CONDITIONAL PASS` blocks release until all findings are resolved. Fix the failing test, re-run `test-results`, then re-run `audit-report`.

---

## What You've Created

Here is a summary of every artifact generated in this tutorial and its role in the audit trail:

| Artifact File | Key IDs | Purpose |
|---|---|---|
| `spec.md` | — | Narrative feature specification |
| `requirements.md` | REQ-001 … REQ-CN-001 | Formal requirements (IEEE 29148) |
| `acceptance-plan.md` | ATP-001 … SCN-003-B1 | Acceptance test cases and scenarios |
| `system-design.md` | SYS-001 … SYS-008 | System component decomposition (IEEE 1016) |
| `system-test-plan.md` | STP-001 … STS-002-B1 | System test procedures (ISO 29119-4) |
| `architecture-design.md` | ARCH-001 … ARCH-007 | Architecture modules (IEEE 42010) |
| `integration-test.md` | ITP-001 … ITS-001-B1 | Integration test procedures (ISO 29119-4) |
| `module-design.md` | MOD-001 … MOD-007 | Module designs with pseudocode |
| `unit-test.md` | UTP-001 … UTS-001-B2 | Unit test procedures (white-box) |
| `hazard-analysis.md` | HAZ-001 … HAZ-004 | Hazard register (ISO 14971) |
| `trace.md` | Matrix A, B, C, D, H | Full traceability matrix |
| `audit-report.md` | — | Compliance gate report |

All artifacts are stored in `specs/cgm-3000/v-model/` inside your Git repository — versioned, diffable, and audit-ready.

---

## Next Steps

- **Try a different domain**: Walk through the [Automotive ADAS tutorial (ISO 26262)](automotive-adas.md) to see how ASIL-D changes the generated artifacts.
- **Handle changes**: Learn how to manage requirement changes with the [Impact Analysis tutorial](impact-and-change.md).
- **Go deeper**: Read the [Installation guide](../getting-started/installation.md) for advanced configuration options.
