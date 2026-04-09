---
title: "Tutorial: Emergency Braking System (ISO 26262 ASIL-D)"
description: End-to-end V-Model walkthrough for an Autonomous Emergency Braking system, covering all four V-Model levels with ASIL-D safety annotations, impact analysis, and a complete audit evidence package under ISO 26262.
---

# Tutorial: Emergency Braking System (ISO 26262 ASIL-D)

## What You'll Learn

In this tutorial you will build a **complete ASIL-D evidence package** for an Autonomous Emergency Braking (AEB) system — the highest automotive safety integrity level. By the end you will have:

- Requirements through unit tests at all **4 V-Model levels** with full traceability
- **ASIL-D–specific** sections in every generated artifact
- A hazard register aligned to **ISO 26262 Part 3** HARA methodology
- An **impact analysis** showing the blast radius of a requirement change
- A passing audit report ready for functional safety assessment

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

You are developing software for a **passenger vehicle Autonomous Emergency Braking (AEB) system**. The system:

- Fuses data from forward-facing radar, camera, and LiDAR sensors
- Detects collision-imminent objects (pedestrians, vehicles, cyclists)
- Issues a driver warning (visual + audible) before braking
- Initiates full autonomous emergency braking when the driver does not respond
- Enters a fail-safe state when sensor data is degraded or unavailable
- Must meet braking performance targets (stopping distance, deceleration rate)

Because failure of the AEB function can lead to **death or serious injury**, it is classified as **ISO 26262 ASIL-D** — the highest Automotive Safety Integrity Level.

---

## Step 1 — Configure the V-Model Domain

=== "Bash"

    ```bash
    cat > v-model-config.yml << 'EOF'
    domain: iso_26262
    asil_level: D
    standards:
      - ISO 26262:2018 (all parts)
      - UN Regulation No. 152 (AEB)
    project:
      name: "AEB-500 Autonomous Emergency Braking"
      version: "1.0.0"
    EOF
    ```

=== "PowerShell"

    ```powershell
    @"
    domain: iso_26262
    asil_level: D
    standards:
      - ISO 26262:2018 (all parts)
      - UN Regulation No. 152 (AEB)
    project:
      name: "AEB-500 Autonomous Emergency Braking"
      version: "1.0.0"
    "@ | Set-Content v-model-config.yml
    ```

!!! tip "ASIL-D implications"

    Setting `asil_level: D` tells the extension to enforce the **strictest** requirements: 100% MC/DC coverage targets, mandatory redundancy analysis, fault-tree references in hazard analysis, and hardware–software interface (HSI) documentation. Lower ASIL levels (A–C) relax some of these constraints.

---

## Step 2 — Write the Feature Specification

```
/speckit.specify An autonomous emergency braking (AEB) system for a
passenger vehicle that fuses forward-facing radar (77 GHz), camera
(1080p @ 30fps), and LiDAR (32-channel) sensor data to detect
collision-imminent objects including pedestrians, vehicles, and cyclists.
The system issues a visual and audible driver warning at TTC ≤ 2.5 seconds,
and initiates full autonomous emergency braking at TTC ≤ 1.2 seconds if
the driver has not responded. The system must achieve a maximum braking
latency of 150 milliseconds from decision to brake actuation. The system
enters a defined fail-safe state (driver notified, braking disabled) when
sensor fusion confidence drops below the safety threshold. The system must
comply with ISO 26262 ASIL-D and UN Regulation No. 152.
```

This generates `specs/aeb-500/spec.md`.

---

## Step 3 — Level 1: Requirements → Acceptance Tests → Trace

### 3a. Generate Requirements

```
/speckit.v-model.requirements
```

??? example "Example output — `requirements.md` (excerpt)"

    ```markdown
    ### Functional Requirements

    | ID | Description | Priority | ASIL | Rationale | Verification Method |
    |----|-------------|----------|------|-----------|---------------------|
    | REQ-001 | The AEB SHALL initiate emergency braking within 150 ms of a brake decision when TTC ≤ 1.2 s for objects at distances ≤ 30 m and vehicle speeds ≥ 30 km/h | P1 | D | ISO 26262 ASIL-D — failure to brake is potentially fatal | Test |
    | REQ-002 | The AEB SHALL issue a visual and audible driver warning when TTC ≤ 2.5 s for detected collision-imminent objects | P1 | D | Driver warning enables manual intervention before autonomous braking | Test |
    | REQ-003 | The AEB SHALL fuse radar, camera, and LiDAR sensor data to classify objects as pedestrian, vehicle, or cyclist with a confidence ≥ 95% | P1 | D | Object classification accuracy is critical for appropriate braking response | Test |
    | REQ-004 | The AEB SHALL NOT initiate emergency braking for stationary objects detected at distances > 100 m (false positive prevention) | P1 | D | False braking on highways causes rear-end collisions — ASIL-D hazard | Test |
    | REQ-005 | The AEB SHALL enter a defined fail-safe state within 50 ms when sensor fusion confidence drops below the safety threshold | P1 | D | Degraded sensor data must not produce incorrect braking decisions | Test |

    ### Non-Functional Requirements

    | ID | Description | Priority | ASIL | Rationale | Verification Method |
    |----|-------------|----------|------|-----------|---------------------|
    | REQ-NF-001 | The AEB system SHALL achieve a maximum deceleration rate of 9.0 m/s² during emergency braking on dry road surfaces | P1 | D | UN Regulation No. 152 performance target | Test |
    | REQ-NF-002 | The AEB system SHALL have a diagnostic coverage of ≥ 99% for all safety-critical hardware faults (ISO 26262 Part 5) | P1 | D | ASIL-D hardware metric requirement | Analysis |

    ### Constraint Requirements

    | ID | Description | Priority | ASIL | Rationale | Verification Method |
    |----|-------------|----------|------|-----------|---------------------|
    | REQ-CN-001 | The AEB MUST achieve ASIL-D integrity per ISO 26262 Part 3 for the emergency braking function | P1 | D | Regulatory — highest automotive safety integrity level | Inspection |
    | REQ-CN-002 | The AEB MUST meet UN Regulation No. 152 Type Approval requirements for AEB performance | P1 | D | Regulatory — market access | Inspection |
    ```

!!! note "ASIL-D column"

    Notice the **ASIL** column present in every requirements table. When `domain: iso_26262` is configured, every requirement inherits the project ASIL level by default. Individual requirements can be decomposed to lower ASIL levels through ASIL decomposition (ISO 26262 Part 9).

### 3b. Generate Acceptance Test Plan

```
/speckit.v-model.acceptance
```

??? example "Example output — `acceptance-plan.md` (excerpt for REQ-001)"

    ```markdown
    ### Requirement Validation: REQ-001 (Emergency Braking Initiation)

    #### Test Case: ATP-001-A (Braking Initiation — Pedestrian at Close Range)
    **Linked Requirement:** REQ-001
    **ASIL:** D
    **Description:** Verify the AEB initiates braking within 150 ms for a pedestrian.

    * **User Scenario: SCN-001-A1**
      * **Given** the vehicle is traveling at 50 km/h on a dry road surface
      * **And** all three sensors (radar, camera, LiDAR) are operational
      * **When** a pedestrian is detected at 25 m in the vehicle's path with TTC = 1.0 s
      * **Then** the AEB initiates full emergency braking within 150 ms of brake decision
      * **And** the braking event is logged with timestamp, distance, speed, TTC, and object class

    #### Test Case: ATP-001-B (Braking Initiation — Vehicle at Threshold Distance)
    **Linked Requirement:** REQ-001

    * **User Scenario: SCN-001-B1**
      * **Given** the vehicle is traveling at 80 km/h
      * **When** a slower vehicle is detected at exactly 30 m with TTC = 1.1 s
      * **Then** the AEB initiates emergency braking within 150 ms

    #### Test Case: ATP-001-C (No Braking Above Distance Threshold)
    **Linked Requirement:** REQ-001, REQ-004

    * **User Scenario: SCN-001-C1**
      * **Given** the vehicle is traveling at 120 km/h on a highway
      * **When** a stationary object is detected at 110 m
      * **Then** the AEB does NOT initiate emergency braking
      * **And** no driver warning is issued for that object
    ```

### 3c. Build Traceability Matrix A

```
/speckit.v-model.trace
```

```
══════════════════════════════════════════════
  TRACEABILITY MATRIX — COVERAGE AUDIT
══════════════════════════════════════════════

  MATRIX A: Requirements → Acceptance Testing
  ────────────────────────────────────────────
  Total Requirements:                  10
  Requirements with Test Coverage:     10 (100%)
  Total Test Cases (ATP):              22
  Total Executable Scenarios (SCN):    36

  MATRIX A STATUS: ✅ COMPLIANT
══════════════════════════════════════════════
```

---

## Step 4 — Level 2: System Design → System Tests

### 4a. Generate System Design

```
/speckit.v-model.system-design
```

??? example "Example output — `system-design.md` (excerpt)"

    ```markdown
    ### Decomposition View

    | ID | Component | Description | ASIL | IEEE 1016 View |
    |----|-----------|-------------|------|----------------|
    | SYS-001 | SensorFusionEngine | Fuses radar, camera, and LiDAR data using Extended Kalman Filter to produce tracked object list with confidence scores | D | Decomposition |
    | SYS-002 | CollisionPredictor | Computes time-to-collision (TTC) for each tracked object relative to the ego vehicle's projected path | D | Decomposition |
    | SYS-003 | BrakeDecisionController | Evaluates TTC thresholds and issues brake/warn commands with ASIL-D voting logic | D | Decomposition |
    | SYS-004 | DriverWarningModule | Activates visual (HUD icon) and audible (chime) warnings at TTC ≤ 2.5 s | B | Decomposition |
    | SYS-005 | BrakeActuatorInterface | Commands the electro-hydraulic brake system via CAN with 150 ms maximum latency | D | Decomposition |
    | SYS-006 | FailSafeManager | Monitors system health and transitions to fail-safe state within 50 ms of safety threshold violation | D | Decomposition |

    ### Interface View

    | ID | Interface | Contract | IEEE 1016 View |
    |----|-----------|----------|----------------|
    | SYS-007 | SensorFusionEngine → CollisionPredictor | Publishes TrackedObject(id, class, distance, velocity, confidence) at 30 Hz | Interface |
    | SYS-008 | CollisionPredictor → BrakeDecisionController | Emits CollisionWarning(object_id, TTC, severity) | Interface |
    | SYS-009 | BrakeDecisionController → BrakeActuatorInterface | Sends BrakeCommand(deceleration_mps2, timestamp) via CAN | Interface |

    ### ASIL Decomposition View

    | ID | Decomposition | Rationale |
    |----|---------------|-----------|
    | SYS-ASIL-001 | SYS-004 (DriverWarningModule) decomposed to ASIL-B | Warning is advisory; braking function retains ASIL-D | 
    ```

!!! info "ASIL Decomposition"

    Notice the **ASIL Decomposition View** — an ISO 26262–specific section that does not appear in IEC 62304 output. This documents where a component's ASIL level differs from the top-level requirement's ASIL, with rationale per ISO 26262 Part 9.

### 4b. Generate System Test Plan

```
/speckit.v-model.system-test
```

??? example "Example output — `system-test-plan.md` (excerpt)"

    ```markdown
    ### Design Element Validation: SYS-003 (BrakeDecisionController)

    #### Test Procedure: STP-003-A (Equivalence Partitioning — TTC Thresholds)
    **Linked Design Element:** SYS-003
    **ASIL:** D
    **ISO 29119-4 Technique:** Equivalence Partitioning

    * **Test Step: STS-003-A1**
      * **Given** BrakeDecisionController is active and vehicle speed = 60 km/h
      * **When** CollisionWarning(TTC=0.8s) is received for a pedestrian at 15 m
      * **Then** BrakeCommand(9.0 m/s²) is sent to BrakeActuatorInterface within 50 ms

    * **Test Step: STS-003-A2**
      * **Given** BrakeDecisionController is active and vehicle speed = 60 km/h
      * **When** CollisionWarning(TTC=2.0s) is received
      * **Then** DriverWarningCommand is sent (no BrakeCommand yet)

    #### Test Procedure: STP-003-B (Fault Injection — Sensor Degradation)
    **Linked Design Element:** SYS-003
    **ASIL:** D
    **ISO 29119-4 Technique:** Fault Injection

    * **Test Step: STS-003-B1**
      * **Given** SensorFusionEngine reports confidence = 0.3 (below safety threshold)
      * **When** BrakeDecisionController evaluates the confidence level
      * **Then** BrakeDecisionController commands FailSafeManager to enter fail-safe state
      * **And** no BrakeCommand is issued based on low-confidence data
    ```

### 4c. Build Traceability Matrix A + B

```
/speckit.v-model.trace
```

```
  MATRIX B: System Design → System Testing
  ────────────────────────────────────────────
  Total Design Elements:               9
  Design Elements with Test Coverage:  9  (100%)
  Total Test Procedures (STP):        18
  Total Executable Steps (STS):       34

  MATRIX B STATUS: ✅ COMPLIANT
```

---

## Step 5 — Level 3: Architecture Design → Integration Tests

### 5a. Generate Architecture Design

```
/speckit.v-model.architecture-design
```

??? example "Example output — `architecture-design.md` (excerpt)"

    ```markdown
    ### Logical View

    | ID | Module | Description | ASIL | IEEE 42010 View |
    |----|--------|-------------|------|-----------------|
    | ARCH-001 | RadarTracker | Processes 77 GHz radar returns into range-doppler tracks | D | Logical |
    | ARCH-002 | CameraDetector | Runs CNN-based object detection on 1080p camera frames | D | Logical |
    | ARCH-003 | LiDARPointCloudProcessor | Clusters and classifies 32-channel LiDAR point clouds | D | Logical |
    | ARCH-004 | FusionKalmanFilter | Extended Kalman Filter fusing radar, camera, and LiDAR tracks into unified object list | D | Logical |
    | ARCH-005 | TTCCalculator | Computes time-to-collision using constant-velocity and constant-acceleration models | D | Logical |
    | ARCH-006 | BrakeArbiter | Dual-channel voting logic for brake commands (ASIL-D redundancy) | D | Logical |

    ### Process View

    | ID | Process | Description | IEEE 42010 View |
    |----|---------|-------------|-----------------|
    | ARCH-007 | SensorFusionPipeline | 30 Hz pipeline: Radar → Camera → LiDAR → Fusion → TTC → Decision | Process |

    ### Deployment View

    | ID | Node | Description | IEEE 42010 View |
    |----|------|-------------|-----------------|
    | ARCH-008 | ADAS-ECU (Arm Cortex-R52) | Safety-certified dual-core lockstep processor | Deployment |

    ### Cross-Cutting Modules

    | ID | Module | Description | Tag |
    |----|--------|-------------|-----|
    | ARCH-009 | SafetyMonitor | Runtime diagnostic checks: watchdog, memory ECC, CPU lockstep comparison | CROSS-CUTTING |
    | ARCH-010 | DiagnosticLogger | DTC recording and UDS diagnostic interface | CROSS-CUTTING |
    ```

!!! info "ASIL-D–specific elements"

    The architecture for ASIL-D includes elements you won't see in lower ASIL levels:

    - **BrakeArbiter** (ARCH-006): Dual-channel voting logic — ASIL-D requires redundancy for braking decisions.
    - **Deployment View** (ARCH-008): Hardware target is explicitly documented because ASIL-D requires HSI (Hardware-Software Interface) analysis.
    - **SafetyMonitor** (ARCH-009): Runtime diagnostics for lockstep CPU comparison and memory ECC — mandatory for ASIL-D diagnostic coverage.

### 5b. Generate Integration Test Plan

```
/speckit.v-model.integration-test
```

??? example "Example output — `integration-test.md` (excerpt)"

    ```markdown
    ### Architecture Element Validation: ARCH-004 → ARCH-005 Interface

    #### Test Procedure: ITP-004-A (Interface Contract — Fused Object List)
    **Linked Architecture Element:** ARCH-004 → ARCH-005
    **ASIL:** D
    **ISO 29119-4 Technique:** Interface Contract Testing

    * **Test Step: ITS-004-A1**
      * **Given** FusionKalmanFilter outputs TrackedObject(id=42, class=PEDESTRIAN, dist=25m, vel=1.2m/s, conf=0.97)
      * **When** TTCCalculator receives the TrackedObject
      * **Then** TTCCalculator computes TTC = 20.8 s using constant-velocity model
      * **And** the object is passed to BrakeArbiter with TTC attached

    #### Test Procedure: ITP-006-A (Redundancy Testing — Dual-Channel Vote)
    **Linked Architecture Element:** ARCH-006
    **ASIL:** D
    **ISO 29119-4 Technique:** Fault Injection

    * **Test Step: ITS-006-A1**
      * **Given** BrakeArbiter Channel A computes BrakeCommand(9.0 m/s²)
      * **And** BrakeArbiter Channel B computes BrakeCommand(9.0 m/s²)
      * **When** both channels agree
      * **Then** BrakeCommand(9.0 m/s²) is forwarded to BrakeActuatorInterface

    * **Test Step: ITS-006-A2**
      * **Given** BrakeArbiter Channel A computes BrakeCommand(9.0 m/s²)
      * **And** BrakeArbiter Channel B computes BrakeCommand(0.0 m/s²) (disagree)
      * **When** channels disagree
      * **Then** FailSafeManager is activated
      * **And** no BrakeCommand is forwarded (fail-safe)
    ```

### 5c. Build Traceability Matrix A + B + C

```
/speckit.v-model.trace
```

```
  MATRIX C: Architecture → Integration Testing
  ────────────────────────────────────────────
  Total Architecture Elements:        10
  Elements with Test Coverage:        10 (100%)
  Total Test Procedures (ITP):        18
  Total Executable Steps (ITS):       32
  CROSS-CUTTING Modules:              2

  MATRIX C STATUS: ✅ COMPLIANT
```

---

## Step 6 — Level 4: Module Design → Unit Tests

### 6a. Generate Module Design

```
/speckit.v-model.module-design
```

??? example "Example output — `module-design.md` (excerpt for MOD-003)"

    ```markdown
    ### Module: MOD-003 (TTCCalculatorCore)

    **Source File:** `src/ttc_calculator_core.c`
    **Parent Architecture Element:** ARCH-005
    **ASIL:** D
    **MC/DC Coverage Target:** 100%

    #### Algorithmic / Logic View

    ```pseudocode
    FUNCTION compute_ttc(object: TrackedObject, ego_speed: float) -> TTCResult:
        relative_velocity = ego_speed - object.velocity
        IF relative_velocity <= 0.0 THEN
            RETURN TTCResult(TTC_INFINITY, model=CONSTANT_VELOCITY)
        END IF
        ttc_cv = object.distance / relative_velocity
        IF object.acceleration != 0.0 THEN
            discriminant = relative_velocity² + 2 * object.acceleration * object.distance
            IF discriminant < 0.0 THEN
                RETURN TTCResult(TTC_INFINITY, model=CONSTANT_ACCELERATION)
            END IF
            ttc_ca = (relative_velocity - sqrt(discriminant)) / object.acceleration
            RETURN TTCResult(min(ttc_cv, ttc_ca), model=CONSTANT_ACCELERATION)
        END IF
        RETURN TTCResult(ttc_cv, model=CONSTANT_VELOCITY)
    END FUNCTION
    ```

    #### Internal Data Structures

    | Name | Type | Size | Constraint |
    |------|------|------|------------|
    | TTC_INFINITY | const float | 4 bytes | 999.0 (sentinel — no collision) |
    | TrackedObject | struct | 24 bytes | id, class, distance, velocity, acceleration, confidence |
    | TTCResult | struct | 8 bytes | ttc_seconds: float, model: enum |

    #### Error Handling & Return Codes

    | Error Condition | Return | Upstream Contract |
    |----------------|--------|-------------------|
    | Relative velocity ≤ 0 | TTCResult(TTC_INFINITY) | ARCH-005: object is moving away — no collision risk |
    | Negative discriminant | TTCResult(TTC_INFINITY) | ARCH-005: acceleration model shows no collision — use CV model |
    ```

### 6b. Generate Unit Test Plan

```
/speckit.v-model.unit-test
```

??? example "Example output — `unit-test.md` (excerpt for MOD-003)"

    ```markdown
    ### Module Under Test: MOD-003 (TTCCalculatorCore)

    **MC/DC Coverage Target:** 100%

    #### Test Procedure: UTP-003-A (MC/DC Coverage — compute_ttc)
    **Linked Module:** MOD-003
    **ASIL:** D
    **Technique:** Modified Condition/Decision Coverage (MC/DC)

    * **Unit Scenario: UTS-003-A1** (relative velocity > 0, no acceleration)
      * **Arrange:** object = {distance: 30m, velocity: 10m/s, acceleration: 0.0}, ego_speed = 25m/s
      * **Act:** Call compute_ttc(object, ego_speed)
      * **Assert:** Returns TTCResult(2.0, CONSTANT_VELOCITY)

    * **Unit Scenario: UTS-003-A2** (relative velocity ≤ 0 — object moving away)
      * **Arrange:** object = {distance: 30m, velocity: 30m/s, acceleration: 0.0}, ego_speed = 25m/s
      * **Act:** Call compute_ttc(object, ego_speed)
      * **Assert:** Returns TTCResult(TTC_INFINITY, CONSTANT_VELOCITY)

    * **Unit Scenario: UTS-003-A3** (acceleration model — positive discriminant)
      * **Arrange:** object = {distance: 30m, velocity: 10m/s, acceleration: -2.0}, ego_speed = 25m/s
      * **Act:** Call compute_ttc(object, ego_speed)
      * **Assert:** Returns TTCResult matching constant-acceleration model

    * **Unit Scenario: UTS-003-A4** (acceleration model — negative discriminant)
      * **Arrange:** object = {distance: 100m, velocity: 10m/s, acceleration: 5.0}, ego_speed = 12m/s
      * **Act:** Call compute_ttc(object, ego_speed)
      * **Assert:** Returns TTCResult(TTC_INFINITY, CONSTANT_ACCELERATION)

    #### Test Procedure: UTP-003-B (Boundary Value Analysis)
    **Linked Module:** MOD-003
    **Technique:** Boundary Value Analysis

    * **Unit Scenario: UTS-003-B1** (distance = 0 — object at vehicle position)
      * **Arrange:** object = {distance: 0.0, velocity: 0.0, acceleration: 0.0}, ego_speed = 50m/s
      * **Act:** Call compute_ttc(object, ego_speed)
      * **Assert:** Returns TTCResult(0.0, CONSTANT_VELOCITY) — immediate collision
    ```

!!! warning "MC/DC is mandatory for ASIL-D"

    Notice the **MC/DC Coverage Target: 100%** annotation. ISO 26262 Part 6 Table 9 requires Modified Condition/Decision Coverage for ASIL-D unit testing. For ASIL-A/B, branch coverage may suffice. The extension automatically sets the appropriate coverage target based on your `asil_level` configuration.

### 6c. Build Full Traceability Matrix A + B + C + D

```
/speckit.v-model.trace
```

```
  MATRIX D: Module Design → Unit Testing
  ────────────────────────────────────────────
  Total Module Designs:                8
  Modules with Test Coverage:          8  (100%)
  Total Test Procedures (UTP):        16
  Total Executable Scenarios (UTS):   38
  MC/DC Target:                       100%

  MATRIX D STATUS: ✅ COMPLIANT

  OVERALL STATUS: ✅ COMPLIANT (all matrices)
```

---

## Step 7 — Hazard Analysis

```
/speckit.v-model.hazard-analysis
```

For ISO 26262, the hazard analysis follows the **Hazard Analysis and Risk Assessment (HARA)** methodology from Part 3, including severity, exposure, and controllability ratings:

??? example "Example output — `hazard-analysis.md` (excerpt)"

    ```markdown
    ### Hazard Analysis and Risk Assessment (HARA)

    | ID | Hazard | Operational Situation | Severity | Exposure | Controllability | ASIL | Mitigation | Linked REQ | Residual Risk |
    |----|--------|----------------------|----------|----------|-----------------|------|------------|-----------|---------------|
    | HAZ-001 | AEB fails to brake for pedestrian in path | Urban driving, 50 km/h, pedestrian crossing | S3 | E4 | C3 | D | Dual-channel BrakeArbiter voting; watchdog monitoring of sensor pipeline; independent FailSafeManager | REQ-001 | Acceptable |
    | HAZ-002 | AEB brakes for false positive (ghost object) on highway | Highway driving, 120 km/h, no actual obstacle | S3 | E4 | C2 | D | Sensor fusion confidence threshold; require 3-sensor agreement; 2-consecutive-frame confirmation | REQ-004 | Acceptable |
    | HAZ-003 | Sensor fusion produces incorrect object classification | All driving conditions | S3 | E3 | C3 | D | CNN model validated against Euro NCAP dataset; runtime plausibility checks across sensor modalities | REQ-003 | Acceptable |
    | HAZ-004 | Brake actuation delay exceeds 150 ms | Emergency scenario, high TTC urgency | S3 | E4 | C3 | D | Direct CAN path to brake ECU; no intermediate processing; hardware watchdog on CAN bus latency | REQ-001 | Acceptable |
    | HAZ-005 | System does not enter fail-safe when sensors are degraded | Rain, fog, sensor occlusion | S3 | E3 | C2 | C | FailSafeManager monitors fusion confidence at 30 Hz; independent hardware sensor health monitor | REQ-005 | Acceptable |

    ### Fault Tree References

    | HAZ ID | Fault Tree | Top Event |
    |--------|-----------|-----------|
    | HAZ-001 | FT-001 | AEB fails to initiate braking |
    | HAZ-002 | FT-002 | AEB initiates unintended braking |
    ```

!!! info "ISO 26262 HARA columns"

    The HARA table uses ISO 26262 Part 3 terminology:

    - **Severity** (S0–S3): S3 = life-threatening / fatal
    - **Exposure** (E0–E4): E4 = high probability in operational scenarios
    - **Controllability** (C0–C3): C3 = difficult or impossible to control
    - **ASIL**: Derived from S × E × C using the ISO 26262 Part 3 matrix
    - **Fault Tree References**: ASIL-D requires formal fault tree analysis — these link to separate FTA documents

---

## Step 8 — Impact Analysis: Simulating a Requirement Change

Now let's simulate a real-world scenario: the braking threshold TTC is changed from **1.2 seconds to 1.0 seconds** based on updated Euro NCAP test protocols.

### 8a. Identify the Blast Radius

=== "Bash"

    ```bash
    /speckit.v-model.impact-analysis --downward REQ-001
    ```

=== "PowerShell"

    ```powershell
    /speckit.v-model.impact-analysis --downward REQ-001
    ```

```
══════════════════════════════════════════════
  IMPACT ANALYSIS — DOWNSTREAM OF REQ-001
══════════════════════════════════════════════

  Changed Artifact: REQ-001

  Suspect Artifacts (Downstream):
  ────────────────────────────────────────────
  ATP  │ ATP-001-A, ATP-001-B, ATP-001-C
  SYS  │ SYS-003, SYS-005
  STP  │ STP-003-A, STP-003-B
  HAZ  │ HAZ-001, HAZ-004
  ARCH │ ARCH-005, ARCH-006
  ITP  │ ITP-004-A, ITP-006-A
  MOD  │ MOD-003
  UTP  │ UTP-003-A, UTP-003-B

  Blast Radius:
  ────────────────────────────────────────────
  | Level     | Count |
  |-----------|-------|
  | ATP       | 3     |
  | SYS       | 2     |
  | STP       | 2     |
  | HAZ       | 2     |
  | ARCH      | 2     |
  | ITP       | 2     |
  | MOD       | 1     |
  | UTP       | 2     |
  | **Total** | **16**|
══════════════════════════════════════════════
```

### 8b. Update and Re-validate

1. **Modify REQ-001** — change TTC threshold from 1.2s to 1.0s
2. **Regenerate affected artifacts**: `acceptance`, `system-test`, `integration-test`, `unit-test`
3. **Re-run trace** to confirm no broken links
4. **Re-run hazard-analysis** to verify mitigations still hold

```
/speckit.v-model.acceptance
/speckit.v-model.trace
```

!!! tip "Focused change management"

    For a detailed walkthrough of the impact analysis workflow — including upward traces, full blast radius, and CI integration — see the dedicated [Impact Analysis tutorial](impact-and-change.md).

---

## Step 9 — Peer Review and Audit Report

### 9a. Peer Review

```
/speckit.v-model.peer-review
```

```
══════════════════════════════════════════════
  PEER REVIEW — SUMMARY
══════════════════════════════════════════════
  Artifacts reviewed:           16
  Findings (Critical):          0   ✅
  Findings (Major):             0   ✅
  Findings (Minor):             1   ⚠️
    • ARCH-006: BrakeArbiter voting logic should reference specific ISO 26262 Part 6 clause for redundancy
  REVIEW STATUS: APPROVED WITH MINOR FINDINGS
══════════════════════════════════════════════
```

### 9b. Audit Report

```
/speckit.v-model.audit-report
```

```
══════════════════════════════════════════════
  AUDIT REPORT — AEB-500 Autonomous Emergency Braking
  ISO 26262 ASIL-D | UN Regulation No. 152
══════════════════════════════════════════════

  Domain:                      iso_26262
  ASIL Level:                  D
  Standards:                   ISO 26262:2018, UN Reg. No. 152

  TRACEABILITY
  ────────────────────────────────────────────
  Matrix A (REQ → ATP):        ✅ COMPLIANT
  Matrix B (SYS → STP):        ✅ COMPLIANT
  Matrix C (ARCH → ITP):       ✅ COMPLIANT
  Matrix D (MOD → UTP):        ✅ COMPLIANT
  Matrix H (HAZ → Mitigation): ✅ COMPLIANT

  ASIL-D SPECIFIC CHECKS
  ────────────────────────────────────────────
  MC/DC coverage target set:   ✅ 100%
  Redundancy documented:       ✅ BrakeArbiter (ARCH-006)
  Fault tree references:       ✅ FT-001, FT-002
  HSI documented:              ✅ ARCH-008 (ADAS-ECU)
  Diagnostic coverage:         ✅ ≥ 99% (REQ-NF-002)

  HAZARD ANALYSIS
  ────────────────────────────────────────────
  Hazards identified:          5
  Hazards mitigated:           5 (100%)
  Residual risk accepted:      5 (100%)

  PEER REVIEW
  ────────────────────────────────────────────
  Status:                      APPROVED WITH MINOR FINDINGS
  Critical findings:           0

  OVERALL AUDIT STATUS: ✅ PASS
══════════════════════════════════════════════
```

---

## ASIL-D–Specific Considerations

When working at ASIL-D, the V-Model Extension Pack generates additional content compared to lower ASIL levels or IEC 62304:

| Feature | ASIL-D | ASIL-A/B | IEC 62304 Class C |
|---|---|---|---|
| **ASIL column** in requirements | ✅ Per-requirement | ✅ Per-requirement | ❌ Not applicable |
| **ASIL Decomposition View** in system design | ✅ Mandatory | Optional | ❌ Not applicable |
| **MC/DC coverage target** in unit tests | ✅ 100% | Branch coverage | Statement coverage |
| **Fault Tree References** in hazard analysis | ✅ Mandatory | Optional | ❌ Not applicable |
| **Deployment View** in architecture | ✅ HSI required | Optional | Optional |
| **Redundancy testing** in integration tests | ✅ Dual-channel voting | Single-channel | Single-channel |
| **Diagnostic coverage** metric | ✅ ≥ 99% | ≥ 90% | ❌ Not applicable |

---

## What You've Created

A complete ASIL-D evidence package stored in `specs/aeb-500/v-model/`:

| Artifact | Key IDs | ASIL-D Specifics |
|---|---|---|
| `requirements.md` | REQ-001 … REQ-CN-002 | ASIL column on every requirement |
| `acceptance-plan.md` | ATP-001 … SCN-001-C1 | ASIL-D tagged test cases |
| `system-design.md` | SYS-001 … SYS-009 | ASIL Decomposition View |
| `system-test-plan.md` | STP-001 … STS-003-B1 | Fault injection procedures |
| `architecture-design.md` | ARCH-001 … ARCH-010 | Deployment View, redundancy modules |
| `integration-test.md` | ITP-001 … ITS-006-A2 | Dual-channel redundancy testing |
| `module-design.md` | MOD-001 … MOD-008 | MC/DC coverage targets |
| `unit-test.md` | UTP-001 … UTS-003-B1 | MC/DC technique annotations |
| `hazard-analysis.md` | HAZ-001 … HAZ-005 | HARA with S/E/C ratings, fault tree refs |
| `trace.md` | Matrix A, B, C, D, H | ASIL-D specific compliance checks |
| `audit-report.md` | — | ASIL-D gates (MC/DC, redundancy, HSI, FTA) |

---

## Next Steps

- **Try a medical device**: Walk through the [Blood Glucose Monitor tutorial (IEC 62304)](medical-device.md) to see how a different regulatory domain changes the artifacts.
- **Master change management**: Learn the full impact analysis workflow in the [Impact Analysis tutorial](impact-and-change.md).
- **Go deeper**: Read the [Installation guide](../getting-started/installation.md) for advanced configuration options.
