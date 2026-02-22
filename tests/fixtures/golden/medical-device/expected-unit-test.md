# Unit Test Plan — Continuous Blood Glucose Monitoring System (CBGMS)

## Test Strategy

This unit test plan verifies all module units defined in the Module Design Specification.
Each module has one or more unit test plans (UTP-NNN-X) with executable unit test scenarios (UTS-NNN-X#).
Test techniques are selected per ISO 29119-4 based on module complexity, statefulness, and IEC 62304 Class C risk profile.
All tests use white-box Arrange/Act/Assert format with strict isolation via dependency mocking.

## Unit Tests

### Module: MOD-001 (SPI Transfer Handler)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `src/hal/spi_driver.c`, `src/hal/spi_driver.h`

#### Test Case: UTP-001-A (Successful SPI Transfer)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies the normal SPI exchange path including chip-select toggling and frame parsing

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `spi_exchange()` | Hardware mock | Returns pre-configured 4-byte rx buffer |
| `gpio_set_low()` / `gpio_set_high()` | Spy | Records call order and pin arguments |

* **Unit Scenario: UTS-001-A1**
  * **Arrange** SPI config with clock_hz = 4000000, cs_pin = 5; mock `spi_exchange()` to return `[0x03, 0xE8, 0xAB, 0xCD]`
  * **Act** Call `spi_transfer(config, sensor_id=1)`
  * **Assert** Returned frame has sample = 0x03E8 (1000), crc = 0xABCD, sensor_id = 1; gpio_set_low called before spi_exchange; gpio_set_high called after

* **Unit Scenario: UTS-001-A2**
  * **Arrange** SPI config as above; mock `spi_exchange()` to return `[0x00, 0x00, 0x00, 0x00]`
  * **Act** Call `spi_transfer(config, sensor_id=0)`
  * **Assert** Returned frame has sample = 0x0000, crc = 0x0000, sensor_id = 0

#### Test Case: UTP-001-B (SPI Timeout Handling)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies hardware mock isolation for SPI timeout and chip-select de-assertion on failure

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `spi_exchange()` | Hardware mock | Returns timeout signal |
| `gpio_set_low()` / `gpio_set_high()` | Spy | Records calls |

* **Unit Scenario: UTS-001-B1**
  * **Arrange** Mock `spi_exchange()` to return timeout after 10 ms
  * **Act** Call `spi_transfer(config, sensor_id=1)`
  * **Assert** Returns Err(SPI_Timeout); gpio_set_high is called (chip-select de-asserted even on failure)

---

### Module: MOD-002 (CRC-16 Verifier)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `src/sensor/crc_verifier.c`

#### Test Case: UTP-002-A (Valid CRC Verification)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions CRC inputs into valid-match equivalence class

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-002-A1**
  * **Arrange** sample = 0x03E8, pre-computed valid CRC-16/CCITT = 0x29B1
  * **Act** Call `crc16_verify(0x03E8, 0x29B1)`
  * **Assert** Returns CRC_OK

* **Unit Scenario: UTS-002-A2**
  * **Arrange** sample = 0xFFFF, pre-computed valid CRC-16/CCITT for 0xFFFF
  * **Act** Call `crc16_verify(0xFFFF, expected_crc)`
  * **Assert** Returns CRC_OK

#### Test Case: UTP-002-B (Invalid CRC Detection)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions CRC inputs into invalid-mismatch equivalence class

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-002-B1**
  * **Arrange** sample = 0x03E8, corrupted CRC = 0x0000
  * **Act** Call `crc16_verify(0x03E8, 0x0000)`
  * **Assert** Returns CRC_MISMATCH

* **Unit Scenario: UTS-002-B2**
  * **Arrange** sample = 0x03E8, CRC off by one bit = 0x29B0
  * **Act** Call `crc16_verify(0x03E8, 0x29B0)`
  * **Assert** Returns CRC_MISMATCH

---

### Module: MOD-003 (Enzyme Kinetics Calculator)

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `src/calibration/enzyme_kinetics.c`

#### Test Case: UTP-003-A (Glucose Range Boundaries)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests glucose_mg_dl scalar boundaries at 40 mg/dL lower bound, 400 mg/dL upper bound, and out-of-range values

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `current_epoch_s()` | Stub | Returns value before curve expiry |

* **Unit Scenario: UTS-003-A1** (Lower bound — 40 mg/dL)
  * **Arrange** Calibration curve coefficients producing 40.0 mg/dL for nanoamps = 12.5; valid curve expiry
  * **Act** Call `enzyme_kinetics_convert(sample{nanoamps=12.5}, curve)`
  * **Assert** Result glucose_mg_dl = 40.0 ± 0.1

* **Unit Scenario: UTS-003-A2** (Upper bound — 400 mg/dL)
  * **Arrange** Calibration curve coefficients producing 400.0 mg/dL for nanoamps = 285.0; valid curve expiry
  * **Act** Call `enzyme_kinetics_convert(sample{nanoamps=285.0}, curve)`
  * **Assert** Result glucose_mg_dl = 400.0 ± 0.1

* **Unit Scenario: UTS-003-A3** (Below physiological range — 19 mg/dL)
  * **Arrange** Calibration curve coefficients producing 19.0 mg/dL for nanoamps = 4.0
  * **Act** Call `enzyme_kinetics_convert(sample{nanoamps=4.0}, curve)`
  * **Assert** Returns Err(OutOfPhysiologicalRange)

* **Unit Scenario: UTS-003-A4** (Above physiological range — 501 mg/dL)
  * **Arrange** Calibration curve coefficients producing 501.0 mg/dL for nanoamps = 360.0
  * **Act** Call `enzyme_kinetics_convert(sample{nanoamps=360.0}, curve)`
  * **Assert** Returns Err(OutOfPhysiologicalRange)

#### Test Case: UTP-003-B (Expired Calibration Curve)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions calibration curve into expired equivalence class

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `current_epoch_s()` | Stub | Returns value after curve expiry |

* **Unit Scenario: UTS-003-B1**
  * **Arrange** Curve with expiry_epoch_s = 1000; stub `current_epoch_s()` returning 1001
  * **Act** Call `enzyme_kinetics_convert(sample, curve)`
  * **Assert** Returns Err(CalibrationCurveExpired)

---

### Module: MOD-004 (Tolerance Checker)

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `src/calibration/tolerance.c`

#### Test Case: UTP-004-A (±15% Rule Above 75 mg/dL)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests tolerance boundaries using ±15% relative rule at and above the 75 mg/dL split point

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-004-A1** (At split point — reference = 75 mg/dL, value = 75.0)
  * **Arrange** raw.glucose_mg_dl = 75.0, reference_mg_dl = 75.0
  * **Act** Call `tolerance_check(raw, 75.0)`
  * **Assert** confidence = 1.0 (exact match, ±15% rule applies)

* **Unit Scenario: UTS-004-A2** (Just within ±15% — reference = 100 mg/dL, value = 115.0)
  * **Arrange** raw.glucose_mg_dl = 115.0, reference_mg_dl = 100.0
  * **Act** Call `tolerance_check(raw, 100.0)`
  * **Assert** confidence > 0.0 (within tolerance)

* **Unit Scenario: UTS-004-A3** (Outside ±15% — reference = 100 mg/dL, value = 116.0)
  * **Arrange** raw.glucose_mg_dl = 116.0, reference_mg_dl = 100.0
  * **Act** Call `tolerance_check(raw, 100.0)`
  * **Assert** confidence = 0.0 (out of tolerance)

#### Test Case: UTP-004-B (±15 mg/dL Rule Below 75 mg/dL)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests tolerance boundaries using ±15 mg/dL absolute rule below the 75 mg/dL split point

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-004-B1** (Just below split — reference = 74 mg/dL, value = 74.0)
  * **Arrange** raw.glucose_mg_dl = 74.0, reference_mg_dl = 74.0
  * **Act** Call `tolerance_check(raw, 74.0)`
  * **Assert** confidence = 1.0 (exact match, ±15 mg/dL rule applies)

* **Unit Scenario: UTS-004-B2** (At absolute tolerance edge — reference = 50 mg/dL, value = 65.0)
  * **Arrange** raw.glucose_mg_dl = 65.0, reference_mg_dl = 50.0
  * **Act** Call `tolerance_check(raw, 50.0)`
  * **Assert** confidence > 0.0 (within ±15 mg/dL)

* **Unit Scenario: UTS-004-B3** (Outside absolute tolerance — reference = 50 mg/dL, value = 66.0)
  * **Arrange** raw.glucose_mg_dl = 66.0, reference_mg_dl = 50.0
  * **Act** Call `tolerance_check(raw, 50.0)`
  * **Assert** confidence = 0.0 (out of tolerance)

---

### Module: MOD-005 (Hypo/Hyper Detector)

**Parent Architecture Modules**: ARCH-005
**Target Source File(s)**: `src/alert/threshold_eval.c`

#### Test Case: UTP-005-A (Hypoglycemia Detection)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests glucose_mg_dl boundary at hypo threshold (55.0 mg/dL)

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-005-A1** (Just below hypo threshold)
  * **Arrange** reading.glucose_mg_dl = 54.9, config.hypo_threshold = 55.0
  * **Act** Call `evaluate_threshold(reading, config)`
  * **Assert** Returns Some(BreachEvent { alert_type: ALERT_HYPO })

* **Unit Scenario: UTS-005-A2** (At hypo threshold — no breach)
  * **Arrange** reading.glucose_mg_dl = 55.0, config.hypo_threshold = 55.0
  * **Act** Call `evaluate_threshold(reading, config)`
  * **Assert** Returns None

#### Test Case: UTP-005-B (Hyperglycemia Detection)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests glucose_mg_dl boundary at hyper threshold (400.0 mg/dL)

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-005-B1** (Just above hyper threshold)
  * **Arrange** reading.glucose_mg_dl = 400.1, config.hyper_threshold = 400.0
  * **Act** Call `evaluate_threshold(reading, config)`
  * **Assert** Returns Some(BreachEvent { alert_type: ALERT_HYPER })

* **Unit Scenario: UTS-005-B2** (At hyper threshold — no breach)
  * **Arrange** reading.glucose_mg_dl = 400.0, config.hyper_threshold = 400.0
  * **Act** Call `evaluate_threshold(reading, config)`
  * **Assert** Returns None

---

### Module: MOD-006 (Alarm State Machine)

**Parent Architecture Modules**: ARCH-006
**Target Source File(s)**: `src/alert/alarm_fsm.c`

#### Test Case: UTP-006-A (Valid State Transitions)

**Technique**: State Transition Testing
**Target View**: State Machine View
**Description**: Exercises all valid alarm FSM transitions: Silent→Sounding, Sounding→Acknowledged, Sounding→Escalating, Escalating→Silent, Acknowledged→Silent

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `now_ms()` | Stub | Returns controlled timestamp values |

* **Unit Scenario: UTS-006-A1** (Silent → Sounding on BreachEvent)
  * **Arrange** ctx.state = ALARM_SILENT; breach event with glucose = 50.0
  * **Act** Call `alarm_fsm_step(ctx, BreachEvent{glucose=50.0})`
  * **Assert** ctx.state = ALARM_SOUNDING; returns ActivateAudibleAlarm(50.0)

* **Unit Scenario: UTS-006-A2** (Sounding → Acknowledged on AckReceived)
  * **Arrange** ctx.state = ALARM_SOUNDING
  * **Act** Call `alarm_fsm_step(ctx, AckReceived)`
  * **Assert** ctx.state = ALARM_ACKNOWLEDGED; returns SilenceAlarm

* **Unit Scenario: UTS-006-A3** (Sounding → Escalating on ack timeout)
  * **Arrange** ctx.state = ALARM_SOUNDING; stub `now_ms()` to simulate 15 min elapsed
  * **Act** Call `alarm_fsm_step(ctx, Tick)`
  * **Assert** ctx.state = ALARM_ESCALATING; returns DispatchSMS

* **Unit Scenario: UTS-006-A4** (Escalating → Silent on SMS success)
  * **Arrange** ctx.state = ALARM_ESCALATING
  * **Act** Call `alarm_fsm_step(ctx, SMSResult(ok))`
  * **Assert** ctx.state = ALARM_SILENT; returns NoAction

* **Unit Scenario: UTS-006-A5** (Acknowledged → Silent on ClearEvent)
  * **Arrange** ctx.state = ALARM_ACKNOWLEDGED
  * **Act** Call `alarm_fsm_step(ctx, ClearEvent)`
  * **Assert** ctx.state = ALARM_SILENT; returns NoAction

#### Test Case: UTP-006-B (Invalid Transitions and Escalation Retries)

**Technique**: State Transition Testing
**Target View**: State Machine View
**Description**: Exercises invalid alarm FSM transitions and escalation retry/exhaustion paths

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `now_ms()` | Stub | Returns controlled timestamp values |

* **Unit Scenario: UTS-006-B1** (Silent + AckReceived — ignored)
  * **Arrange** ctx.state = ALARM_SILENT
  * **Act** Call `alarm_fsm_step(ctx, AckReceived)`
  * **Assert** ctx.state remains ALARM_SILENT; returns NoAction

* **Unit Scenario: UTS-006-B2** (Escalating SMS retry up to 3 times)
  * **Arrange** ctx.state = ALARM_ESCALATING; ctx.escalation_retries = 2
  * **Act** Call `alarm_fsm_step(ctx, SMSResult(fail))`
  * **Assert** ctx.escalation_retries = 3; returns DispatchSMS (final retry)

* **Unit Scenario: UTS-006-B3** (Escalating SMS all retries exhausted)
  * **Arrange** ctx.state = ALARM_ESCALATING; ctx.escalation_retries = 3
  * **Act** Call `alarm_fsm_step(ctx, SMSResult(fail))`
  * **Assert** ctx.state = ALARM_SILENT; returns LogEscalationFailure

---

### Module: MOD-007 (BLE Link Controller)

**Parent Architecture Modules**: ARCH-007
**Target Source File(s)**: `src/ble/link_ctrl.c`

#### Test Case: UTP-007-A (Valid BLE State Transitions)

**Technique**: State Transition Testing
**Target View**: State Machine View
**Description**: Exercises all valid BLE FSM transitions: Disconnected→Pairing, Pairing→Connected, Connected→Reconnecting, Reconnecting→Connected

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| BLE hardware stack | Hardware mock | Simulates pairing/connection/link-loss events |

* **Unit Scenario: UTS-007-A1** (Disconnected → Pairing)
  * **Arrange** ctx.state = BLE_DISCONNECTED; peer_addr = [0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF]
  * **Act** Call `ble_link_step(ctx, PairRequest(peer_addr))`
  * **Assert** ctx.state = BLE_PAIRING; returns InitiateSecurePairing(peer_addr)

* **Unit Scenario: UTS-007-A2** (Pairing → Connected)
  * **Arrange** ctx.state = BLE_PAIRING
  * **Act** Call `ble_link_step(ctx, PairSuccess)`
  * **Assert** ctx.state = BLE_CONNECTED; ctx.reconnect_attempts = 0; returns EnableGATTNotifications

* **Unit Scenario: UTS-007-A3** (Connected → Reconnecting on LinkLoss)
  * **Arrange** ctx.state = BLE_CONNECTED
  * **Act** Call `ble_link_step(ctx, LinkLoss)`
  * **Assert** ctx.state = BLE_RECONNECTING; ctx.backoff_ms = 1000; returns ScheduleReconnect(1000)

* **Unit Scenario: UTS-007-A4** (Reconnecting → Connected on success)
  * **Arrange** ctx.state = BLE_RECONNECTING; ctx.reconnect_attempts = 3
  * **Act** Call `ble_link_step(ctx, ReconnectSuccess)`
  * **Assert** ctx.state = BLE_CONNECTED; returns ReplayBufferedPackets

#### Test Case: UTP-007-B (Reconnection Backoff and Abandonment)

**Technique**: State Transition Testing
**Target View**: State Machine View
**Description**: Exercises exponential backoff, cap, and abandonment transitions in the BLE reconnection state

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| BLE hardware stack | Hardware mock | Simulates reconnection failures |

* **Unit Scenario: UTS-007-B1** (Exponential backoff doubles)
  * **Arrange** ctx.state = BLE_RECONNECTING; ctx.backoff_ms = 1000; ctx.reconnect_attempts = 0
  * **Act** Call `ble_link_step(ctx, Tick)`
  * **Assert** ctx.backoff_ms = 2000; ctx.reconnect_attempts = 1; returns AttemptReconnect

* **Unit Scenario: UTS-007-B2** (Backoff caps at 30 seconds)
  * **Arrange** ctx.state = BLE_RECONNECTING; ctx.backoff_ms = 16000; ctx.reconnect_attempts = 4
  * **Act** Call `ble_link_step(ctx, Tick)`
  * **Assert** ctx.backoff_ms = 30000 (capped); ctx.reconnect_attempts = 5

* **Unit Scenario: UTS-007-B3** (Abandonment after 10 attempts)
  * **Arrange** ctx.state = BLE_RECONNECTING; ctx.reconnect_attempts = 10
  * **Act** Call `ble_link_step(ctx, Tick)`
  * **Assert** ctx.state = BLE_DISCONNECTED; returns ReportConnectionAbandoned

---

### Module: MOD-008 (CBOR Encoder)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `src/ble/cbor_encoder.c`

#### Test Case: UTP-008-A (Record Encoding)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions CBOR records into normal-glucose and alert equivalence classes

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-008-A1** (Normal glucose record)
  * **Arrange** record = { timestamp_ms: 1000000, glucose_mg_dl: 120.0, confidence: 0.95, alert_type: 0 }; seq = 42
  * **Act** Call `cbor_encode_record(record, 42)`
  * **Assert** Returned packet has valid CBOR map with 4 keys; sequence_no = 42; length < 256

* **Unit Scenario: UTS-008-A2** (Alert record)
  * **Arrange** record = { timestamp_ms: 2000000, glucose_mg_dl: 50.0, confidence: 0.80, alert_type: 1 }; seq = 43
  * **Act** Call `cbor_encode_record(record, 43)`
  * **Assert** CBOR payload contains alert_type = 1 (hypo); sequence_no = 43

#### Test Case: UTP-008-B (Payload Size Limit)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests CBOR payload length boundary at 256-byte maximum

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-008-B1** (Payload at maximum 256 bytes — success)
  * **Arrange** record with maximum-length valid fields
  * **Act** Call `cbor_encode_record(record, 0)`
  * **Assert** Returns Ok with packet.length ≤ 256

* **Unit Scenario: UTS-008-B2** (Payload exceeding 256 bytes — error)
  * **Arrange** Artificially crafted record that would produce > 256 bytes of CBOR
  * **Act** Call `cbor_encode_record(record, 0)`
  * **Assert** Returns Err(PayloadTooLarge)

---

### Module: MOD-009 (Flash FIFO Manager)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `src/storage/flash_fifo.c`

#### Test Case: UTP-009-A (Normal Write Operation)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies all branches in the write path including successful write and read-after-write verification failure

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `flash_program()` | Hardware mock | Simulates successful write |
| `flash_read()` | Hardware mock | Returns written data (read-after-write verify) |
| `flash_erase_sector()` | Hardware mock | Simulates successful sector erase |

* **Unit Scenario: UTS-009-A1** (Write to empty FIFO)
  * **Arrange** ctx = { state: FIFO_READY, head: 0, tail: 0, count: 0 }; mock flash_program and flash_read to succeed
  * **Act** Call `fifo_write(ctx, reading)`
  * **Assert** ctx.tail = 1; ctx.count = 1; ctx.state = FIFO_READY; flash_program called with addr = 0

* **Unit Scenario: UTS-009-A2** (Write with read-after-write verification failure)
  * **Arrange** ctx with count = 5; mock flash_read to return mismatched data
  * **Act** Call `fifo_write(ctx, reading)`
  * **Assert** Returns Err(FlashWriteVerifyFail)

#### Test Case: UTP-009-B (FIFO Eviction)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests FIFO count boundary at MAX_RECORDS and circular tail wrap

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `flash_program()` | Hardware mock | Simulates successful write |
| `flash_read()` | Hardware mock | Returns written data |
| `flash_erase_sector()` | Hardware mock | Records erase calls |

* **Unit Scenario: UTS-009-B1** (Eviction triggered at MAX_RECORDS)
  * **Arrange** ctx.count = MAX_RECORDS; ctx.head = 0; mock all flash ops to succeed
  * **Act** Call `fifo_write(ctx, reading)`
  * **Assert** flash_erase_sector called with address of record at head; ctx.head = 1; ctx.count = MAX_RECORDS (evict one, write one)

* **Unit Scenario: UTS-009-B2** (Circular wrap of tail index)
  * **Arrange** ctx.tail = MAX_RECORDS - 1; ctx.count = MAX_RECORDS - 1; mock all flash ops to succeed
  * **Act** Call `fifo_write(ctx, reading)`
  * **Assert** ctx.tail = 0 (wrapped); ctx.count = MAX_RECORDS

---

### Module: MOD-010 (Report Generator)

**Parent Architecture Modules**: ARCH-010
**Target Source File(s)**: `src/export/report_gen.c`

#### Test Case: UTP-010-A (CSV Export)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions report requests into valid-CSV and empty-range equivalence classes

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `fifo_read_range()` | Stub | Returns pre-configured reading list |

* **Unit Scenario: UTS-010-A1** (7-day CSV export)
  * **Arrange** Stub fifo_read_range to return 2016 readings (7 days × 24 h × 12/h); req.format = FORMAT_CSV
  * **Act** Call `generate_report(req, store)`
  * **Assert** Result contains CSV header + 2016 data rows; each row has ISO 8601 timestamp, glucose, confidence

* **Unit Scenario: UTS-010-A2** (Empty date range)
  * **Arrange** Stub fifo_read_range to return 0 readings
  * **Act** Call `generate_report(req, store)`
  * **Assert** Returns Err(NoDataInRange)

#### Test Case: UTP-010-B (PDF Export)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions report requests into valid-PDF equivalence class with spy verification

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `fifo_read_range()` | Stub | Returns pre-configured reading list |
| `pdf_create_header()` / `pdf_add_table()` / `pdf_finalize()` | Spy | Records call arguments |

* **Unit Scenario: UTS-010-B1** (Valid PDF generation)
  * **Arrange** Stub fifo_read_range to return 288 readings (1 day); req.format = FORMAT_PDF
  * **Act** Call `generate_report(req, store)`
  * **Assert** pdf_create_header called with correct date range; pdf_add_table called with 288 readings; result.format = FORMAT_PDF

---

### Module: MOD-011 (Event Logger) [CROSS-CUTTING]

**Parent Architecture Modules**: ARCH-011
**Target Source File(s)**: `src/diag/event_logger.c`

#### Test Case: UTP-011-A (Log Level Filtering)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions log entries by severity into above/below/at minimum-level equivalence classes

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `flash_write_async()` | Hardware mock | Records written entries |
| `atomic_load()` / `atomic_store()` | Stub | Simulates atomic offset operations |

* **Unit Scenario: UTS-011-A1** (Entry above minimum level — written)
  * **Arrange** configured_min_level = LOG_WARNING; entry.severity = LOG_ERROR; mock flash_write_async
  * **Act** Call `log_event(entry)`
  * **Assert** flash_write_async called once with serialized entry

* **Unit Scenario: UTS-011-A2** (Entry below minimum level — filtered)
  * **Arrange** configured_min_level = LOG_WARNING; entry.severity = LOG_DEBUG
  * **Act** Call `log_event(entry)`
  * **Assert** flash_write_async not called

* **Unit Scenario: UTS-011-A3** (Entry at minimum level — written)
  * **Arrange** configured_min_level = LOG_WARNING; entry.severity = LOG_WARNING; mock flash_write_async
  * **Act** Call `log_event(entry)`
  * **Assert** flash_write_async called once

#### Test Case: UTP-011-B (FIFO Wrap on Partition Full)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests write-pointer boundary at LOG_PARTITION_SIZE for wrap and exact-fit conditions

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `flash_write_async()` | Hardware mock | Records written entries |
| `atomic_load()` | Stub | Returns offset near partition end |
| `atomic_store()` | Spy | Records new offset value |

* **Unit Scenario: UTS-011-B1** (Write pointer wraps to zero)
  * **Arrange** atomic_load returns offset = LOG_PARTITION_SIZE - 10; entry serialized length = 32 bytes
  * **Act** Call `log_event(entry)`
  * **Assert** atomic_store called with offset = 32 (wrapped to start); flash_write_async writes at LOG_PARTITION_BASE + 0

* **Unit Scenario: UTS-011-B2** (Write pointer fits exactly)
  * **Arrange** atomic_load returns offset = LOG_PARTITION_SIZE - 32; entry serialized length = 32 bytes
  * **Act** Call `log_event(entry)`
  * **Assert** flash_write_async writes at LOG_PARTITION_BASE + (LOG_PARTITION_SIZE - 32); no wrap occurs

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Modules (MOD) | 11 |
| Modules tested | 11 (excludes [EXTERNAL]) |
| Modules bypassed ([EXTERNAL]) | 0 |
| Total Test Cases (UTP) | 22 |
| Total Scenarios (UTS) | 53 |
| Modules with ≥1 UTP | 11 / 11 (100%) |
| Test Cases with ≥1 UTS | 22 / 22 (100%) |
| **Overall Coverage (MOD→UTP)** | **100%** |

### Technique Distribution

| Technique | Test Cases | Percentage |
|-----------|-----------|------------|
| Statement & Branch Coverage | 2 | 9% |
| Boundary Value Analysis | 7 | 32% |
| Equivalence Partitioning | 7 | 32% |
| Strict Isolation | 1 | 5% |
| State Transition Testing | 5 | 23% |
