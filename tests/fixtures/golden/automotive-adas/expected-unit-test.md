# Unit Test Plan — Automatic Emergency Braking System (AEB)

## Test Strategy

This unit test plan verifies all module units defined in the Module Design Specification.
Each module has one or more unit test plans (UTP-NNN-X) with executable unit test scenarios (UTS-NNN-X#).
Test techniques are selected per ISO 29119-4 based on module complexity, statefulness, and ISO 26262 ASIL-D integrity level.
All tests use white-box Arrange/Act/Assert format with strict isolation via dependency mocking.

## Unit Tests

### Module: MOD-001 (FFT Processor)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `src/radar/fft_processor.c`, `src/radar/fft_processor.h`

#### Test Case: UTP-001-A (Range-Doppler FFT Computation)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies all branches in the range-Doppler FFT pipeline including target detection and noise-only paths

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| Radar ADC DMA | Hardware mock | Returns pre-recorded I/Q sample arrays |

* **Unit Scenario: UTS-001-A1** (Single target at 100 m, 30 m/s)
  * **Arrange** I/Q samples synthesized for a target at range = 100 m, velocity = 30 m/s; inject via ADC mock
  * **Act** Call `fft_process(frame)`
  * **Assert** cfar_detection_t contains peak in range_bins at bin corresponding to 100 m ± 1 m; doppler_bins at 30 m/s ± 0.5 m/s

* **Unit Scenario: UTS-001-A2** (No target — noise only)
  * **Arrange** I/Q samples containing Gaussian noise below CFAR threshold
  * **Act** Call `fft_process(frame)`
  * **Assert** cfar_detection_t has empty range_bins and doppler_bins (no detections above noise floor)

#### Test Case: UTP-001-B (CFAR Threshold Sensitivity)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests target power boundary at CFAR_ALPHA threshold for detection/no-detection boundary

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| Radar ADC DMA | Hardware mock | Returns pre-recorded I/Q sample arrays |

* **Unit Scenario: UTS-001-B1** (Target power exactly at CFAR threshold)
  * **Arrange** I/Q samples with target power = noise_floor × CFAR_ALPHA (exactly at threshold)
  * **Act** Call `fft_process(frame)`
  * **Assert** Target is not detected (threshold is exclusive)

* **Unit Scenario: UTS-001-B2** (Target power just above CFAR threshold)
  * **Arrange** I/Q samples with target power = noise_floor × CFAR_ALPHA + epsilon
  * **Act** Call `fft_process(frame)`
  * **Assert** Target is detected with correct range and Doppler values

---

### Module: MOD-002 (Track Manager)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `src/radar/track_mgr.c`

#### Test Case: UTP-002-A (Track Lifecycle State Transitions)

**Technique**: State Transition Testing
**Target View**: State Machine View
**Description**: Exercises all valid track lifecycle transitions: NoTrack→Tentative, Tentative→Confirmed, Confirmed→Lost, Lost→NoTrack

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-002-A1** (NoTrack → Tentative on new detection)
  * **Arrange** ctx with empty tracks; detection at range = 80 m
  * **Act** Call `track_update(ctx, [detection])`
  * **Assert** New track created with state = TRACK_TENTATIVE, range_m = 80.0, hit_count = 1

* **Unit Scenario: UTS-002-A2** (Tentative → Confirmed after 3 consecutive hits)
  * **Arrange** ctx with one tentative track, hit_count = 2; matching detection
  * **Act** Call `track_update(ctx, [detection])`
  * **Assert** Track state = TRACK_CONFIRMED; hit_count = 3

* **Unit Scenario: UTS-002-A3** (Confirmed → Lost after 3 consecutive misses)
  * **Arrange** ctx with one confirmed track, miss_count = 2; no matching detection
  * **Act** Call `track_update(ctx, [])`
  * **Assert** Track state = TRACK_LOST; miss_count = 3

* **Unit Scenario: UTS-002-A4** (Lost → NoTrack — auto-deletion)
  * **Arrange** ctx with one lost track
  * **Act** Call `track_update(ctx, [])`
  * **Assert** Track state = TRACK_NOTRACK; active_count decremented

#### Test Case: UTP-002-B (Track Capacity Limits)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests active_count boundary at 64-track maximum capacity

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-002-B1** (Maximum tracks — 64 concurrent)
  * **Arrange** ctx with active_count = 63; one new unmatched detection
  * **Act** Call `track_update(ctx, [detection])`
  * **Assert** active_count = 64; new tentative track created

* **Unit Scenario: UTS-002-B2** (Overflow — 65th detection ignored)
  * **Arrange** ctx with active_count = 64; one new unmatched detection
  * **Act** Call `track_update(ctx, [detection])`
  * **Assert** active_count remains 64; no new track created

---

### Module: MOD-003 (H265 Decoder)

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `src/camera/h265_decoder.c`

#### Test Case: UTP-003-A (Successful Frame Decode)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions stereo frame pairs into valid-sync and sync-failure equivalence classes

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| Camera DMA | Hardware mock | Returns pre-recorded NAL unit byte arrays |

* **Unit Scenario: UTS-003-A1** (Valid stereo pair within sync tolerance)
  * **Arrange** Left NAL with timestamp = 1000000 us, right NAL with timestamp = 1000050 us (delta = 50 us < 80 ms)
  * **Act** Call `h265_decode_pair(left_nal, right_nal, imu)`
  * **Assert** Returns Ok with pair.timestamp_us = 1000025; left and right buffers populated

* **Unit Scenario: UTS-003-A2** (Frame sync failure — delta > 80 ms)
  * **Arrange** Left NAL with timestamp = 1000000 us, right NAL with timestamp = 1090000 us (delta = 90 ms)
  * **Act** Call `h265_decode_pair(left_nal, right_nal, imu)`
  * **Assert** Returns Err(FrameSyncError)

#### Test Case: UTP-003-B (Decode Error Handling)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions NAL unit inputs into corrupted-header equivalence class

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| Camera DMA | Hardware mock | Returns corrupted NAL data |

* **Unit Scenario: UTS-003-B1** (Corrupted left NAL unit)
  * **Arrange** Left NAL with invalid header bytes; valid right NAL
  * **Act** Call `h265_decode_pair(left_nal, right_nal, imu)`
  * **Assert** Returns Err(DecodeTimeout)

---

### Module: MOD-004 (CNN Inference Engine)

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `src/camera/cnn_inference.c`

#### Test Case: UTP-004-A (Object Classification Accuracy)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions CNN detections into vehicle and pedestrian object-class equivalence classes

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| CNN model weights | Stub | Pre-loaded test model returning deterministic outputs |

* **Unit Scenario: UTS-004-A1** (Vehicle at 50 m — classified correctly)
  * **Arrange** Decoded frame pair with synthetic vehicle image at 50 m; stub model to return class = Vehicle, confidence = 0.95
  * **Act** Call `cnn_infer(pair, model)`
  * **Assert** Result contains one detection: class = CLASS_VEHICLE, depth_m = 50 ± 2 m, confidence = 0.95

* **Unit Scenario: UTS-004-A2** (Pedestrian at 80 m — at max depth boundary)
  * **Arrange** Decoded frame pair with synthetic pedestrian at 80 m; stub model to return class = Pedestrian, confidence = 0.90
  * **Act** Call `cnn_infer(pair, model)`
  * **Assert** Result contains one detection: class = CLASS_PEDESTRIAN, depth_m = 80 ± 2 m

#### Test Case: UTP-004-B (Confidence Floor and Depth Filtering)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests confidence scalar boundary at CONFIDENCE_FLOOR (0.50) and depth boundary at MAX_DEPTH_M (80 m)

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| CNN model weights | Stub | Pre-loaded test model returning deterministic outputs |

* **Unit Scenario: UTS-004-B1** (Confidence below floor — filtered)
  * **Arrange** Stub model to return detection with confidence = 0.49 (below CONFIDENCE_FLOOR = 0.50)
  * **Act** Call `cnn_infer(pair, model)`
  * **Assert** Result is empty (detection filtered out)

* **Unit Scenario: UTS-004-B2** (Depth beyond 80 m — filtered)
  * **Arrange** Stub model to return detection with confidence = 0.90, depth_m = 81.0
  * **Act** Call `cnn_infer(pair, model)`
  * **Assert** Result is empty (detection beyond MAX_DEPTH_M)

* **Unit Scenario: UTS-004-B3** (Confidence at floor — accepted)
  * **Arrange** Stub model to return detection with confidence = 0.50, depth_m = 40.0
  * **Act** Call `cnn_infer(pair, model)`
  * **Assert** Result contains one detection with confidence = 0.50

---

### Module: MOD-005 (EKF Core)

**Parent Architecture Modules**: ARCH-005
**Target Source File(s)**: `src/fusion/ekf_core.c`

#### Test Case: UTP-005-A (Predict/Update Cycle)

**Technique**: State Transition Testing
**Target View**: State Machine View
**Description**: Exercises EKF phase transitions: predict-only, predict+update, and NaN-triggered reset

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `now_us()` | Stub | Returns controlled timestamps |

* **Unit Scenario: UTS-005-A1** (Predict-only — no measurement)
  * **Arrange** ctx at EKF_UPDATE phase; state_vector = [100, 0, -40, 0, 0, 0]; dt = 0.05 s
  * **Act** Call `ekf_step(ctx, 0.05, None)`
  * **Assert** ctx.phase = EKF_PREDICT; state_vector[0] ≈ 98.0 (position updated by velocity × dt)

* **Unit Scenario: UTS-005-A2** (Predict + Update with measurement)
  * **Arrange** ctx with predicted state; measurement z = [97.5, 0.5] (range, azimuth)
  * **Act** Call `ekf_step(ctx, 0.05, Some(z))`
  * **Assert** ctx.phase = EKF_UPDATE; state_vector[0] converges toward 97.5; covariance reduced

* **Unit Scenario: UTS-005-A3** (NaN detection triggers reset)
  * **Arrange** ctx with covariance containing NaN in diagonal
  * **Act** Call `ekf_step(ctx, 0.05, None)`
  * **Assert** Returns Err(FusionDivergence); ctx is reset to initial values

#### Test Case: UTP-005-B (Divergence Guard)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests covariance diagonal boundary at COV_DIVERGENCE_THRESHOLD

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `now_us()` | Stub | Returns controlled timestamps |

* **Unit Scenario: UTS-005-B1** (Covariance at divergence threshold — passes)
  * **Arrange** ctx.covariance max diagonal = COV_DIVERGENCE_THRESHOLD - 1.0
  * **Act** Call `ekf_step(ctx, 0.05, None)`
  * **Assert** Returns Ok; no reset triggered

* **Unit Scenario: UTS-005-B2** (Covariance exceeds divergence threshold — resets)
  * **Arrange** ctx.covariance max diagonal = COV_DIVERGENCE_THRESHOLD + 1.0
  * **Act** Call `ekf_step(ctx, 0.05, None)`
  * **Assert** Returns Err(FusionDivergence); ctx is reset

---

### Module: MOD-006 (TTC Estimator)

**Parent Architecture Modules**: ARCH-006
**Target Source File(s)**: `src/fusion/ttc_calc.c`

#### Test Case: UTP-006-A (TTC Threshold Boundaries)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests TTC scalar boundaries at 1.5 s braking threshold, 2.5 s warning threshold, and TTC_MAX_S (10.0 s)

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-006-A1** (TTC = 1.5 s — at braking threshold)
  * **Arrange** Fused object at range = 60 m, closing velocity = 40 m/s (TTC = 60/40 = 1.5 s)
  * **Act** Call `ttc_compute(obj)`
  * **Assert** Returns Some with ttc_s = 1.5 ± 0.01

* **Unit Scenario: UTS-006-A2** (TTC = 2.5 s — at warning threshold)
  * **Arrange** Fused object at range = 100 m, closing velocity = 40 m/s (TTC = 100/40 = 2.5 s)
  * **Act** Call `ttc_compute(obj)`
  * **Assert** Returns Some with ttc_s = 2.5 ± 0.01

* **Unit Scenario: UTS-006-A3** (TTC = 10.1 s — beyond max, filtered)
  * **Arrange** Fused object at range = 404 m, closing velocity = 40 m/s (TTC = 10.1 s)
  * **Act** Call `ttc_compute(obj)`
  * **Assert** Returns None (beyond TTC_MAX_S)

#### Test Case: UTP-006-B (Receding Object and Zero Velocity)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions closing velocity into receding and stationary equivalence classes

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-006-B1** (Object receding — closing velocity negative)
  * **Arrange** Fused object with closing_vel = -10 m/s (moving away)
  * **Act** Call `ttc_compute(obj)`
  * **Assert** Returns None (no threat from receding object)

* **Unit Scenario: UTS-006-B2** (Object stationary — closing velocity = 0)
  * **Arrange** Fused object with closing_vel = 0 m/s
  * **Act** Call `ttc_compute(obj)`
  * **Assert** Returns None (no collision if not closing)

---

### Module: MOD-007 (Collision Decision Logic)

**Parent Architecture Modules**: ARCH-007
**Target Source File(s)**: `src/brake/collision_logic.c`

#### Test Case: UTP-007-A (Braking vs Warning Decision)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies all decision branches: emergency braking (TTC < 1.5 s), warning (1.5 s ≤ TTC < 2.5 s), and no-action (TTC ≥ 2.5 s)

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-007-A1** (TTC < 1.5 s — emergency braking)
  * **Arrange** threat.ttc_s = 1.49
  * **Act** Call `evaluate_threat(threat)`
  * **Assert** Returns Some(BrakeCommand { decel = 10.0, activation = true, priority = EMERGENCY })

* **Unit Scenario: UTS-007-A2** (1.5 s ≤ TTC < 2.5 s — warning only)
  * **Arrange** threat.ttc_s = 2.0
  * **Act** Call `evaluate_threat(threat)`
  * **Assert** Returns Some(BrakeCommand { decel = 0.0, activation = false, priority = WARNING })

* **Unit Scenario: UTS-007-A3** (TTC ≥ 2.5 s — no action)
  * **Arrange** threat.ttc_s = 2.5
  * **Act** Call `evaluate_threat(threat)`
  * **Assert** Returns None

#### Test Case: UTP-007-B (Boundary Precision at Thresholds)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests TTC scalar boundaries at exact threshold values 1.5 s and 2.49 s

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-007-B1** (TTC = 1.5 s exactly — warning, not braking)
  * **Arrange** threat.ttc_s = 1.5
  * **Act** Call `evaluate_threat(threat)`
  * **Assert** Returns Some with priority = WARNING (1.5 is not < 1.5)

* **Unit Scenario: UTS-007-B2** (TTC = 2.49 s — warning issued)
  * **Arrange** threat.ttc_s = 2.49
  * **Act** Call `evaluate_threat(threat)`
  * **Assert** Returns Some with priority = WARNING

---

### Module: MOD-008 (CAN-FD Transmitter)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `src/brake/canfd_tx.c`

#### Test Case: UTP-008-A (Normal Transmission)

**Technique**: State Transition Testing
**Target View**: State Machine View
**Description**: Exercises CAN-FD FSM transitions: Idle→Transmitting→Idle on success, and echo mismatch error path

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `can_transmit()` | Hardware mock | Returns Ok on primary bus |
| `can_read_echo()` | Hardware mock | Returns matching echo frame |

* **Unit Scenario: UTS-008-A1** (Idle → Transmitting → Idle on success)
  * **Arrange** ctx.state = CANFD_IDLE; ctx.active_bus = 0; mock can_transmit returns Ok; mock can_read_echo returns matching frame
  * **Act** Call `canfd_send(ctx, brake_cmd{decel=10.0, emergency})`
  * **Assert** ctx.state = CANFD_IDLE; can_transmit called with CAN_PRIMARY_BUS_ADDR (0x100)

* **Unit Scenario: UTS-008-A2** (Bitwise mismatch on echo — error)
  * **Arrange** ctx.state = CANFD_IDLE; mock can_transmit returns Ok; mock can_read_echo returns mismatched payload
  * **Act** Call `canfd_send(ctx, brake_cmd)`
  * **Assert** Returns Err(BitwiseMismatch)

#### Test Case: UTP-008-B (Bus Failover)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies hardware mock isolation for dual-bus failover including primary→secondary switch and dual failure

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `can_transmit()` | Hardware mock | Fails on primary, succeeds on secondary |
| `can_read_echo()` | Hardware mock | Returns matching echo on secondary bus |

* **Unit Scenario: UTS-008-B1** (Primary bus failure → FailoverSwitch → Idle)
  * **Arrange** ctx.active_bus = 0; mock can_transmit to fail on bus 0, succeed on bus 1; mock can_read_echo to return match on bus 1
  * **Act** Call `canfd_send(ctx, brake_cmd)`
  * **Assert** ctx.state = CANFD_IDLE; ctx.active_bus = 1; second can_transmit called with CAN_SECONDARY_BUS_ADDR (0x200)

* **Unit Scenario: UTS-008-B2** (Dual bus failure — both buses fail)
  * **Arrange** ctx.active_bus = 0; mock can_transmit to fail on both buses
  * **Act** Call `canfd_send(ctx, brake_cmd)`
  * **Assert** Returns Err(DualBusFailure); ctx.state = CANFD_FAILOVER_SWITCH

---

### Module: MOD-009 (Module Health Checker)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `src/safety/health_check.c`

#### Test Case: UTP-009-A (Heartbeat Detection)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions component heartbeats into healthy and missed equivalence classes

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-009-A1** (All components healthy)
  * **Arrange** All last_heartbeat_us within HEARTBEAT_INTERVAL_MS; current_us = 200000
  * **Act** Call `check_health(ctx, 200000)`
  * **Assert** All reports have state = HEALTH_OK; all failure_counts = 0

* **Unit Scenario: UTS-009-A2** (Single component missed heartbeat — degraded)
  * **Arrange** Component 3 last_heartbeat_us = 0 (elapsed = 200 ms > 100 ms); failure_count[3] = 0
  * **Act** Call `check_health(ctx, 200000)`
  * **Assert** Component 3 report state = HEALTH_DEGRADED; failure_count[3] = 1

#### Test Case: UTP-009-B (Triple-Redundant Failure Counting)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests failure_count boundary at triple-redundant threshold (3 consecutive misses)

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-009-B1** (Third consecutive miss — HEALTH_FAILED)
  * **Arrange** Component 5 failure_count = 2; last_heartbeat_us stale
  * **Act** Call `check_health(ctx, current_us)`
  * **Assert** Component 5 report state = HEALTH_FAILED; failure_count = 3

* **Unit Scenario: UTS-009-B2** (Recovery resets failure counter)
  * **Arrange** Component 5 failure_count = 2; last_heartbeat_us = current_us - 50000 (50 ms, within threshold)
  * **Act** Call `check_health(ctx, current_us)`
  * **Assert** Component 5 report state = HEALTH_OK; failure_count = 0

---

### Module: MOD-010 (Mode Controller)

**Parent Architecture Modules**: ARCH-010
**Target Source File(s)**: `src/safety/mode_ctrl.c`

#### Test Case: UTP-010-A (Valid Degradation Transitions)

**Technique**: State Transition Testing
**Target View**: State Machine View
**Description**: Exercises all valid mode transitions: Normal→RadarOnly, Normal→CameraOnly, RadarOnly→SafeState, CameraOnly→SafeState

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| NV memory writer | Stub | Records DTC log entries |

* **Unit Scenario: UTS-010-A1** (Normal → RadarOnly on camera failure)
  * **Arrange** ctx.mode = MODE_NORMAL; report = { component_id: CAMERA, state: HEALTH_FAILED }
  * **Act** Call `mode_transition(ctx, report)`
  * **Assert** ctx.mode = MODE_RADAR_ONLY; DTC 0xC002 logged; returns SwitchToRadarOnly

* **Unit Scenario: UTS-010-A2** (Normal → CameraOnly on radar failure)
  * **Arrange** ctx.mode = MODE_NORMAL; report = { component_id: RADAR, state: HEALTH_FAILED }
  * **Act** Call `mode_transition(ctx, report)`
  * **Assert** ctx.mode = MODE_CAMERA_ONLY; DTC 0xC001 logged; returns SwitchToCameraOnly

* **Unit Scenario: UTS-010-A3** (RadarOnly → SafeState on radar failure)
  * **Arrange** ctx.mode = MODE_RADAR_ONLY; report = { component_id: RADAR, state: HEALTH_FAILED }
  * **Act** Call `mode_transition(ctx, report)`
  * **Assert** ctx.mode = MODE_SAFE_STATE; DTC 0xC003 logged; returns EngageMaxBraking

* **Unit Scenario: UTS-010-A4** (CameraOnly → SafeState on camera failure)
  * **Arrange** ctx.mode = MODE_CAMERA_ONLY; report = { component_id: CAMERA, state: HEALTH_FAILED }
  * **Act** Call `mode_transition(ctx, report)`
  * **Assert** ctx.mode = MODE_SAFE_STATE; DTC 0xC003 logged; returns EngageMaxBraking

#### Test Case: UTP-010-B (No-Op Transitions)

**Technique**: State Transition Testing
**Target View**: State Machine View
**Description**: Exercises no-op transitions: healthy report in Normal mode and terminal SafeState

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| NV memory writer | Stub | Verifies no DTC written |

* **Unit Scenario: UTS-010-B1** (Normal + healthy report — no transition)
  * **Arrange** ctx.mode = MODE_NORMAL; report = { component_id: RADAR, state: HEALTH_OK }
  * **Act** Call `mode_transition(ctx, report)`
  * **Assert** ctx.mode remains MODE_NORMAL; returns NoAction; no DTC logged

* **Unit Scenario: UTS-010-B2** (SafeState is terminal — no transition out)
  * **Arrange** ctx.mode = MODE_SAFE_STATE; report = { component_id: RADAR, state: HEALTH_OK }
  * **Act** Call `mode_transition(ctx, report)`
  * **Assert** ctx.mode remains MODE_SAFE_STATE; returns NoAction

---

### Module: MOD-011 (Watchdog Kicker) [CROSS-CUTTING]

**Parent Architecture Modules**: ARCH-011
**Target Source File(s)**: `src/safety/wdt_kicker.c`

#### Test Case: UTP-011-A (Watchdog Kick Signal)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions watchdog kick calls into single-kick and consecutive-kick equivalence classes

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `volatile_write()` | Hardware mock (GPIO) | Records register address and value written |

* **Unit Scenario: UTS-011-A1** (Normal kick — magic word written)
  * **Arrange** Mock volatile_write to record arguments
  * **Act** Call `wdt_kick(1000000)`
  * **Assert** volatile_write called with address = 0x40001000, value = 0x5A5A5A5A

* **Unit Scenario: UTS-011-A2** (Consecutive kicks — each writes magic word)
  * **Arrange** Mock volatile_write with call counter
  * **Act** Call `wdt_kick(1000000)` then `wdt_kick(1050000)`
  * **Assert** volatile_write called exactly 2 times; both with correct address and pattern

#### Test Case: UTP-011-B (Deadline Check Logic)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests elapsed-time boundary at WDT_TIMEOUT_MS (100 ms) for kick/no-kick decision

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `volatile_write()` | Hardware mock (GPIO) | Records register writes |

* **Unit Scenario: UTS-011-B1** (Pipeline within deadline — kick issued)
  * **Arrange** pipeline_start_us = 1000000; current_us = 1099000 (elapsed = 99 ms < 100 ms)
  * **Act** Call `wdt_check_deadline(1000000, 1099000)`
  * **Assert** Returns true; volatile_write called (kick issued)

* **Unit Scenario: UTS-011-B2** (Pipeline at deadline — no kick)
  * **Arrange** pipeline_start_us = 1000000; current_us = 1100000 (elapsed = 100 ms = WDT_TIMEOUT_MS)
  * **Act** Call `wdt_check_deadline(1000000, 1100000)`
  * **Assert** Returns false; volatile_write not called (deadline exceeded)

* **Unit Scenario: UTS-011-B3** (Pipeline just past deadline — no kick)
  * **Arrange** pipeline_start_us = 1000000; current_us = 1100001 (elapsed = 100.001 ms)
  * **Act** Call `wdt_check_deadline(1000000, 1100001)`
  * **Assert** Returns false; volatile_write not called

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Modules (MOD) | 11 |
| Modules tested | 11 (excludes [EXTERNAL]) |
| Modules bypassed ([EXTERNAL]) | 0 |
| Total Test Cases (UTP) | 22 |
| Total Scenarios (UTS) | 52 |
| Modules with ≥1 UTP | 11 / 11 (100%) |
| Test Cases with ≥1 UTS | 22 / 22 (100%) |
| **Overall Coverage (MOD→UTP)** | **100%** |

### Technique Distribution

| Technique | Test Cases | Percentage |
|-----------|-----------|------------|
| Statement & Branch Coverage | 2 | 9% |
| Boundary Value Analysis | 7 | 32% |
| Equivalence Partitioning | 6 | 27% |
| Strict Isolation | 1 | 5% |
| State Transition Testing | 6 | 27% |
