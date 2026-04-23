# Unit Test Plan — Flight Warning Computer (FWC)

## Test Strategy

This unit test plan verifies all module units defined in the Module Design Specification
for the Flight Warning Computer. Each module has one or more unit test plans (UTP-NNN-X)
with executable unit test scenarios (UTS-NNN-X#). Test techniques are selected per DO-178C
Table A-5 and ISO 29119-4 based on module complexity, statefulness, and DAL-A risk profile.
All tests use white-box Arrange/Act/Assert format with strict isolation via hardware and
inter-module dependency mocking. MC/DC coverage is required for all DAL-A modules.

## Unit Tests

### Module: MOD-001 (ARINC 429 Word Receiver)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `src/hal/arinc429_drv.c`, `src/hal/arinc429_drv.h`

#### Test Case: UTP-001-A (Successful Word Reception and Ring Buffer Write)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies the normal ISR execution path — word received, bit-reversed, timestamped, written to ring buffer.

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `read_hardware_fifo()` | Hardware register mock | Returns pre-configured 32-bit ARINC 429 word on first call, FIFO_EMPTY on second |
| `hardware_fifo_not_empty()` | Stub | Returns true once, then false |
| `get_system_time_ms()` | Deterministic stub | Always returns 1000 ms |
| `ring_buf_write()` | Spy | Records all calls; returns RB_OK |
| `CLEAR hardware_interrupt()` | Spy | Records call |

* **Unit Scenario: UTS-001-A1#**
  * **Arrange**: Configure mock FIFO with word 0x1A001064 (label 0x64 bit-reversed = label 100 decimal; SSM=01 Normal Op; data=0x1A0)
  * **Act**: Invoke `arinc429_rx_isr(channel=0)`
  * **Assert**: `ring_buf_write` was called once with `RawWord{ label=100, sdi=0, data=0x1A0, ssm=1, rx_time_ms=1000 }`
  * **Assert**: Hardware interrupt cleared exactly once

#### Test Case: UTP-001-B (FIFO Overflow Fault Reporting)

**Technique**: Fault Injection — Branch Coverage (overflow path)
**Target View**: State Machine View
**Description**: Verifies that FIFO overflow is detected, reported to BITE, and FIFO is reset.

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `read_hardware_fifo()` | Hardware mock | Returns OVF_ERROR on first call |
| `hardware_fifo_not_empty()` | Stub | Returns true once |
| `bite_report_fault()` | Spy | Records fault code |
| `reset_hardware_fifo()` | Spy | Records call |

* **Unit Scenario: UTS-001-B1#**
  * **Arrange**: Configure mock hardware FIFO to return overflow error
  * **Act**: Invoke `arinc429_rx_isr(channel=0)`
  * **Assert**: `bite_report_fault` called with `FAULT_FIFO_OVF, channel=0`
  * **Assert**: `reset_hardware_fifo` called for channel 0

#### Test Case: UTP-001-C (Ring Buffer Full — Oldest Word Discarded)

**Technique**: Boundary Value Analysis — Ring buffer full condition
**Target View**: Algorithmic/Logic View
**Description**: Verifies that when the ring buffer is full, the oldest word is discarded and the new word is written.

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `ring_buf_write()` | Real implementation with pre-filled buffer | Buffer already contains 64 entries |
| `read_hardware_fifo()` | Mock | Returns new word |
| `hardware_fifo_not_empty()` | Stub | Returns true once, then false |

* **Unit Scenario: UTS-001-C1#**
  * **Arrange**: Pre-fill ring buffer to RING_BUF_DEPTH (64 entries); oldest entry has rx_time_ms = 500
  * **Act**: Invoke `arinc429_rx_isr(channel=0)` with new word at rx_time_ms = 1000
  * **Assert**: Ring buffer still contains 64 entries
  * **Assert**: Oldest entry (rx_time_ms=500) is no longer present; new entry (rx_time_ms=1000) is present

---

### Module: MOD-002 (Label Age Checker)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `src/input/label_age.c`

#### Test Case: UTP-002-A (Fresh Label — Within Age Limit)

**Technique**: Statement & Branch Coverage — Normal path
**Target View**: Algorithmic/Logic View
**Description**: Verifies that a label received within MAX_LABEL_AGE_MS is returned as FRESH.

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| None | — | Pure function; no external dependencies |

* **Unit Scenario: UTS-002-A1#**
  * **Arrange**: Word with `rx_time_ms = 1000`; `current_time_ms = 1100` (age = 100 ms < 150 ms limit)
  * **Act**: Call `check_label_age(word, current_time_ms=1100, max_age_ms=150)`
  * **Assert**: Returns `AgeResult{ status: AGE_FRESH, age_ms: 100 }`

#### Test Case: UTP-002-B (Stale Label — Exactly At Boundary)

**Technique**: Boundary Value Analysis — Age limit boundary
**Target View**: Algorithmic/Logic View
**Description**: Verifies age = max_age_ms is still FRESH, age = max_age_ms + 1 is STALE.

* **Unit Scenario: UTS-002-B1#**
  * **Arrange**: Word with `rx_time_ms = 1000`; `current_time_ms = 1150` (age = 150 ms = limit)
  * **Act**: Call `check_label_age(word, current_time_ms=1150, max_age_ms=150)`
  * **Assert**: Returns `AgeResult{ status: AGE_FRESH, age_ms: 150 }` — boundary is inclusive

* **Unit Scenario: UTS-002-B2#**
  * **Arrange**: Word with `rx_time_ms = 1000`; `current_time_ms = 1151` (age = 151 ms > limit)
  * **Act**: Call `check_label_age(word, current_time_ms=1151, max_age_ms=150)`
  * **Assert**: Returns `AgeResult{ status: AGE_STALE, age_ms: 151 }`

#### Test Case: UTP-002-C (Timestamp Counter Wrap — Saturating Arithmetic)

**Technique**: Branch Coverage — Counter wrap defensive path
**Target View**: Algorithmic/Logic View
**Description**: Verifies that timestamp counter wrap is handled with saturation (returns STALE, not a negative age).

* **Unit Scenario: UTS-002-C1#**
  * **Arrange**: Word with `rx_time_ms = 1000`; `current_time_ms = 500` (wrap: current < rx_time)
  * **Act**: Call `check_label_age(word, current_time_ms=500, max_age_ms=150)`
  * **Assert**: Returns `AgeResult{ status: AGE_STALE, age_ms: SATURATE_U16_MAX }` — saturated to max

---

### Module: MOD-003 (SSM Decoder)

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `src/input/ssm_decoder.c`

#### Test Case: UTP-003-A (Normal Operation SSM — Valid Decode)

**Technique**: Statement & Branch Coverage — Normal Op path (SSM = 0b01)
**Target View**: Algorithmic/Logic View
**Description**: Verifies that SSM = Normal Operation produces a valid decoded float value.

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `LABEL_SCALE_TABLE[]` | ROM stub | Returns 0.25 kt/LSB for label 206 (airspeed) |
| `aircraft_is_on_ground()` | Not called on this path | N/A |

* **Unit Scenario: UTS-003-A1#**
  * **Arrange**: AgedWord `{ label=206, sdi=0, data=0x0540, ssm=0b01, age_ms=50 }` (data=1344 → 1344×0.25=336 kt)
  * **Act**: Call `decode_ssm(word)`
  * **Assert**: Returns `SsmDecodeResult{ status: SSM_VALID, value ≈ 336.0f }`

#### Test Case: UTP-003-B (NCD Flag — Returns NCD Status)

**Technique**: Branch Coverage — NCD path (SSM = 0b11)
**Target View**: Algorithmic/Logic View
**Description**: Verifies that SSM = NCD returns NCD status and NaN value.

* **Unit Scenario: UTS-003-B1#**
  * **Arrange**: AgedWord `{ label=206, sdi=0, data=0x0540, ssm=0b11 }` (NCD flag set)
  * **Act**: Call `decode_ssm(word)`
  * **Assert**: Returns `SsmDecodeResult{ status: SSM_NCD, value: NaN }`

#### Test Case: UTP-003-C (Failure Warning — Returns Sensor Fault)

**Technique**: Branch Coverage — Failure Warning path (SSM = 0b00)
**Target View**: Algorithmic/Logic View
**Description**: Verifies that SSM = Failure Warning returns SENSOR_FAULT.

* **Unit Scenario: UTS-003-C1#**
  * **Arrange**: AgedWord `{ label=206, sdi=0, data=0x0540, ssm=0b00 }` (Failure Warning)
  * **Act**: Call `decode_ssm(word)`
  * **Assert**: Returns `SsmDecodeResult{ status: SSM_SENSOR_FAULT, value: NaN }`

#### Test Case: UTP-003-D (Unknown SSM — Fail-Safe Default)

**Technique**: Branch Coverage — Defensive default case (MC/DC required for DO-178C)
**Target View**: Algorithmic/Logic View
**Description**: Verifies that any SSM value not in {0b00, 0b01, 0b10, 0b11} triggers the fail-safe default.

* **Unit Scenario: UTS-003-D1#**
  * **Arrange**: AgedWord with `ssm = 0b100` (out-of-range value injected via test)
  * **Act**: Call `decode_ssm(word)`
  * **Assert**: Returns `SsmDecodeResult{ status: SSM_SENSOR_FAULT, value: NaN }` — fail-safe default

---

### Module: MOD-004 (Warning Threshold Comparator)

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `src/logic/threshold_eval.c`

#### Test Case: UTP-004-A (Threshold Not Exceeded — No Warning)

**Technique**: Statement & Branch Coverage — Below threshold path
**Target View**: Algorithmic/Logic View
**Description**: Verifies that a value below the activation threshold produces no ACTIVE warning event.

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `THRESHOLD_CONFIG[]` | ROM stub | OVERSPEED threshold=340.0 kt, hysteresis=2.0 kt, priority=1 |
| `current_warning_state[]` | Pre-initialized | All INACTIVE |

* **Unit Scenario: UTS-004-A1#**
  * **Arrange**: ValidatedFrame with `function=OVERSPEED, value=339.0f`; current state = INACTIVE
  * **Act**: Call `evaluate_threshold(OVERSPEED, 339.0f, config)`
  * **Assert**: Returns `WarningEvent{ function: OVERSPEED, state: INACTIVE }` — no activation

#### Test Case: UTP-004-B (Threshold Exceeded — Warning Activated)

**Technique**: Boundary Value Analysis — Above threshold (MC/DC: both directions of > comparison)
**Target View**: Algorithmic/Logic View
**Description**: Verifies that a value above the threshold activates the warning.

* **Unit Scenario: UTS-004-B1#**
  * **Arrange**: ValidatedFrame with `function=OVERSPEED, value=341.0f` (VMO 340 + 1 kt); state = INACTIVE
  * **Act**: Call `evaluate_threshold(OVERSPEED, 341.0f, config)`
  * **Assert**: Returns `WarningEvent{ function: OVERSPEED, state: ACTIVE, value: 341.0f }`
  * **Assert**: `current_warning_state[OVERSPEED]` transitions to ACTIVE

#### Test Case: UTP-004-C (Hysteresis — Warning Clears Below Lower Band)

**Technique**: Boundary Value Analysis — Hysteresis deactivation
**Target View**: Algorithmic/Logic View
**Description**: Verifies that an active warning is only cleared when value drops below lower_threshold = activation - hysteresis.

* **Unit Scenario: UTS-004-C1#**
  * **Arrange**: `function=OVERSPEED, value=339.0f` (below activation=340 but above lower=338); state = ACTIVE
  * **Act**: Call `evaluate_threshold(OVERSPEED, 339.0f, config)` with state pre-set to ACTIVE
  * **Assert**: Returns `WarningEvent{ function: OVERSPEED, state: ACTIVE }` — hysteresis holds warning active

* **Unit Scenario: UTS-004-C2#**
  * **Arrange**: `function=OVERSPEED, value=337.0f` (below lower=338); state = ACTIVE
  * **Act**: Call `evaluate_threshold(OVERSPEED, 337.0f, config)` with state pre-set to ACTIVE
  * **Assert**: Returns `WarningEvent{ function: OVERSPEED, state: INACTIVE }` — warning clears

#### Test Case: UTP-004-D (NaN Input — Warning Inhibited)

**Technique**: Fault Injection — Invalid floating-point input
**Target View**: Algorithmic/Logic View
**Description**: Verifies that NaN input inhibits the warning function (fail-safe behavior).

* **Unit Scenario: UTS-004-D1#**
  * **Arrange**: `function=OVERSPEED, value=NaN`; current state = INACTIVE
  * **Act**: Call `evaluate_threshold(OVERSPEED, NaN, config)`
  * **Assert**: Returns `WarningEvent{ function: OVERSPEED, state: INHIBITED }` — NaN inhibits

---

### Module: MOD-005 (Warning State Machine)

**Parent Architecture Modules**: ARCH-005
**Target Source File(s)**: `src/logic/warning_fsm.c`

#### Test Case: UTP-005-A (Single Warning Dispatch — Priority Correct)

**Technique**: Statement & Branch Coverage — Single active warning
**Target View**: State Machine View
**Description**: Verifies state transitions from QUIESCENT to WARNING_ACTIVE and correct command dispatch.

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `send_to_audio_driver()` | Spy | Records all calls |
| `send_to_annunciator()` | Spy | Records all calls |
| `send_to_stick_shaker()` | Spy | Records all calls |
| Initial `active_set[]` | Pre-initialized | All false |

* **Unit Scenario: UTS-005-A1#**
  * **Arrange**: One WarningEvent `{ function: STALL, state: ACTIVE, priority: 2 }`
  * **Act**: Call `arbitrate_warnings([stall_event])` then `dispatch_commands(result)`
  * **Assert**: State transitions to `FSM_WARNING_ACTIVE`
  * **Assert**: `send_to_audio_driver` called with `WarningCommand{ STALL, ACTIVE, priority=2 }`
  * **Assert**: `send_to_annunciator` called with STALL annunciator
  * **Assert**: `send_to_stick_shaker` called with `StallCommand{ state: ACTIVE }`

#### Test Case: UTP-005-B (Priority Arbitration — Two Concurrent Warnings)

**Technique**: Decision Table Testing — Multiple active warnings
**Target View**: Algorithmic/Logic View
**Description**: Verifies that simultaneous OVERSPEED (priority 1) and ATTITUDE LIMIT (priority 5) produce correctly ordered dispatch.

* **Unit Scenario: UTS-005-B1#**
  * **Arrange**: Two events: OVERSPEED `{ priority=1, state: ACTIVE }` and ATTITUDE `{ priority=5, state: ACTIVE }`
  * **Act**: Call `arbitrate_warnings([overspeed_event, attitude_event])` then `dispatch_commands(result)`
  * **Assert**: Dispatch sequence: first call = OVERSPEED (priority 1), second call = ATTITUDE (priority 5)
  * **Assert**: `send_to_stick_shaker` NOT called (OVERSPEED and ATTITUDE do not activate stick shaker)

#### Test Case: UTP-005-C (Warning Clears — State Returns to QUIESCENT)

**Technique**: Branch Coverage — Warning deactivation
**Target View**: State Machine View
**Description**: Verifies that when all warnings become INACTIVE, state returns to QUIESCENT.

* **Unit Scenario: UTS-005-C1#**
  * **Arrange**: Pre-set state = WARNING_ACTIVE with one active STALL warning; then provide STALL INACTIVE event
  * **Act**: Call `arbitrate_warnings([stall_inactive_event])` then `dispatch_commands(result)`
  * **Assert**: State transitions to `FSM_QUIESCENT`
  * **Assert**: `send_to_audio_driver` called with `WarningCommand{ STALL, INACTIVE }` to clear the alert

---

### Module: MOD-006 (Audio Alert Driver)

**Parent Architecture Modules**: ARCH-006
**Target Source File(s)**: `src/output/audio_alert_drv.c`

#### Test Case: UTP-006-A (Successful Alert Transmission on First Attempt)

**Technique**: Statement & Branch Coverage — Normal AMU ACK path
**Target View**: Algorithmic/Logic View
**Description**: Verifies that a WarningCommand is encoded and transmitted successfully when the AMU acknowledges within the timeout period.

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `arinc429_tx_word()` | Spy | Records transmitted words; returns TX_OK |
| `wait_for_amu_ack()` | Stub | Returns ACK_RECEIVED immediately (simulates fast ACK) |
| `bite_report_fault()` | Spy | Must NOT be called on success path |

* **Unit Scenario: UTS-006-A1#**
  * **Arrange**: WarningCommand `{ function: OVERSPEED, state: ACTIVE, priority: 1 }`
  * **Act**: Call `audio_send_alert(cmd)`
  * **Assert**: `arinc429_tx_word` called once with correctly encoded ARINC 429 word (SSM=Normal Op, label=OVERSPEED_LABEL)
  * **Assert**: Returns `AudioSendResult{ status: AUDIO_SEND_OK }`
  * **Assert**: `bite_report_fault` NOT called

#### Test Case: UTP-006-B (AMU No-Acknowledgement — All Retries Exhausted)

**Technique**: Fault Injection — Retry path exhaustion
**Target View**: Algorithmic/Logic View
**Description**: Verifies that MAX_RETRIES (3) transmissions are attempted and BITE fault is reported when AMU never acknowledges.

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `arinc429_tx_word()` | Spy | Records call count; returns TX_OK each time |
| `wait_for_amu_ack()` | Stub | Always returns ACK_TIMEOUT (simulates unresponsive AMU) |
| `bite_report_fault()` | Spy | Records fault code and function ID |

* **Unit Scenario: UTS-006-B1#**
  * **Arrange**: WarningCommand `{ function: STALL, state: ACTIVE, priority: 2 }`; AMU configured to always timeout
  * **Act**: Call `audio_send_alert(cmd)`
  * **Assert**: `arinc429_tx_word` called exactly MAX_RETRIES (3) times
  * **Assert**: `bite_report_fault` called with `FAULT_AMU_NO_ACK, function=STALL`
  * **Assert**: Returns `AudioSendResult{ status: AUDIO_SEND_FAILED }`

#### Test Case: UTP-006-C (Alert Clear — Zero Data Field)

**Technique**: Branch Coverage — INACTIVE state encoding
**Target View**: Algorithmic/Logic View
**Description**: Verifies that an INACTIVE WarningCommand encodes data field as 0x00 (alert clear).

* **Unit Scenario: UTS-006-C1#**
  * **Arrange**: WarningCommand `{ function: OVERSPEED, state: INACTIVE, priority: 1 }`
  * **Act**: Call `audio_send_alert(cmd)`
  * **Assert**: ARINC 429 word data field is 0x00 (alert clear encoding)
  * **Assert**: `arinc429_tx_word` called with correctly encoded clear word

---

### Module: MOD-007 (Annunciator Controller)

**Parent Architecture Modules**: ARCH-007
**Target Source File(s)**: `src/output/annunciator_ctrl.c`

#### Test Case: UTP-007-A (Annunciator Illumination — ACTIVE Command)

**Technique**: Statement & Branch Coverage — Drive ON path
**Target View**: Algorithmic/Logic View
**Description**: Verifies that an ACTIVE WarningCommand drives the GPIO LOW (fail-on logic) and verifies current sense > MIN_CURRENT_MA.

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `gpio_write()` | Spy | Records pin and level |
| `bite_read_current_sense()` | Stub | Returns 30 mA (above MIN_CURRENT_MA=20 mA) |
| `bite_report_fault()` | Spy | Must NOT be called on success path |

* **Unit Scenario: UTS-007-A1#**
  * **Arrange**: WarningCommand `{ annunciator_id: OVERSPEED_ANNUNC, state: ACTIVE }`
  * **Act**: Call `annunciator_drive(cmd)`
  * **Assert**: `gpio_write` called with `(OVERSPEED_ANNUNC_PIN, LOGIC_LOW)`
  * **Assert**: `bite_report_fault` NOT called
  * **Assert**: Returns `AnnunciatorResult{ status: ANNUNC_DRIVE_OK }`

#### Test Case: UTP-007-B (Open-Circuit Fault Detection)

**Technique**: Fault Injection — Current sense below threshold
**Target View**: Algorithmic/Logic View
**Description**: Verifies that a current sense reading below MIN_CURRENT_MA on an ACTIVE annunciator triggers a BITE fault.

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `gpio_write()` | Spy | Records calls normally |
| `bite_read_current_sense()` | Stub | Returns 5 mA (below MIN_CURRENT_MA=20 mA; simulates open circuit) |
| `bite_report_fault()` | Spy | Records fault code and annunciator ID |

* **Unit Scenario: UTS-007-B1#**
  * **Arrange**: WarningCommand `{ annunciator_id: STALL_ANNUNC, state: ACTIVE }`; current sense returns 5 mA
  * **Act**: Call `annunciator_drive(cmd)`
  * **Assert**: `bite_report_fault` called with `FAULT_ANNUNC_OPEN_CIRCUIT, annunciator_id=STALL_ANNUNC`
  * **Assert**: Returns `AnnunciatorResult{ status: ANNUNC_OPEN_CIRCUIT }`

#### Test Case: UTP-007-C (Annunciator Extinguish — INACTIVE Command)

**Technique**: Branch Coverage — Drive OFF path
**Target View**: Algorithmic/Logic View
**Description**: Verifies that an INACTIVE WarningCommand drives the GPIO HIGH (annunciator off) and does NOT check current sense (no current expected when off).

* **Unit Scenario: UTS-007-C1#**
  * **Arrange**: WarningCommand `{ annunciator_id: OVERSPEED_ANNUNC, state: INACTIVE }`
  * **Act**: Call `annunciator_drive(cmd)`
  * **Assert**: `gpio_write` called with `(OVERSPEED_ANNUNC_PIN, LOGIC_HIGH)`
  * **Assert**: Returns `AnnunciatorResult{ status: ANNUNC_DRIVE_OK }`

---

### Module: MOD-008 (Stick Shaker Driver)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `src/output/stick_shaker_drv.c`

#### Test Case: UTP-008-A (Stick Shaker Activation — Feedback Confirms Engagement)

**Technique**: Statement & Branch Coverage — Normal activation path
**Target View**: Algorithmic/Logic View
**Description**: Verifies normal stick shaker activation with positive feedback confirmation.

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `gpio_write()` | Spy | Records control pin level |
| `delay_ms()` | Stub | Immediate return (no real delay in unit test) |
| `gpio_read()` | Stub | Returns LOGIC_HIGH (feedback pin = actuator engaged) |
| `bite_report_fault()` | Spy | Must NOT be called on success path |

* **Unit Scenario: UTS-008-A1#**
  * **Arrange**: StallCommand `{ state: ACTIVE }`; feedback returns LOGIC_HIGH after drive
  * **Act**: Call `stick_shaker_drive(cmd)`
  * **Assert**: `gpio_write` called with `(STICK_SHAKER_CTRL_PIN, LOGIC_HIGH)`
  * **Assert**: `bite_report_fault` NOT called
  * **Assert**: Returns `StickShakerResult{ status: SHAKER_DRIVE_OK }`

#### Test Case: UTP-008-B (Stuck-Off Fault Detection)

**Technique**: Fault Injection — Actuator fails to engage
**Target View**: Algorithmic/Logic View
**Description**: Verifies that when the feedback line does not rise after an ACTIVE command, a stuck-off fault is reported.

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `gpio_write()` | Spy | Records calls |
| `delay_ms()` | Stub | Immediate return |
| `gpio_read()` | Stub | Returns LOGIC_LOW (actuator did NOT engage despite ACTIVE command) |
| `bite_report_fault()` | Spy | Records fault code |

* **Unit Scenario: UTS-008-B1#**
  * **Arrange**: StallCommand `{ state: ACTIVE }`; feedback returns LOGIC_LOW (stuck-off)
  * **Act**: Call `stick_shaker_drive(cmd)`
  * **Assert**: `bite_report_fault` called with `FAULT_STICK_SHAKER_STUCK_OFF`
  * **Assert**: Returns `StickShakerResult{ status: SHAKER_STUCK_OFF }`

#### Test Case: UTP-008-C (Stuck-On Fault Detection)

**Technique**: Fault Injection — Actuator fails to disengage
**Target View**: Algorithmic/Logic View
**Description**: Verifies that when feedback indicates actuator is still energized after an INACTIVE command, a stuck-on fault is reported.

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Behavior |
|------------|---------------|----------|
| `gpio_write()` | Spy | Records calls |
| `delay_ms()` | Stub | Immediate return |
| `gpio_read()` | Stub | Returns LOGIC_HIGH (actuator still engaged despite INACTIVE command) |
| `bite_report_fault()` | Spy | Records fault code |

* **Unit Scenario: UTS-008-C1#**
  * **Arrange**: StallCommand `{ state: INACTIVE }`; feedback returns LOGIC_HIGH (stuck-on)
  * **Act**: Call `stick_shaker_drive(cmd)`
  * **Assert**: `bite_report_fault` called with `FAULT_STICK_SHAKER_STUCK_ON`
  * **Assert**: Returns `StickShakerResult{ status: SHAKER_STUCK_ON }`

## Coverage Summary

| Module | Test Cases | Scenarios | DO-178C Coverage |
|--------|-----------|-----------|-----------------|
| MOD-001 | 3 (UTP-001-A, UTP-001-B, UTP-001-C) | 3 (UTS-001-A1#, UTS-001-B1#, UTS-001-C1#) | Statement, Branch, MC/DC |
| MOD-002 | 3 (UTP-002-A, UTP-002-B, UTP-002-C) | 4 (UTS-002-A1#, UTS-002-B1#, UTS-002-B2#, UTS-002-C1#) | Statement, Branch, BVA, MC/DC |
| MOD-003 | 4 (UTP-003-A, UTP-003-B, UTP-003-C, UTP-003-D) | 4 (UTS-003-A1#, UTS-003-B1#, UTS-003-C1#, UTS-003-D1#) | All SSM branches, MC/DC |
| MOD-004 | 4 (UTP-004-A, UTP-004-B, UTP-004-C, UTP-004-D) | 5 (UTS-004-A1#, UTS-004-B1#, UTS-004-C1#, UTS-004-C2#, UTS-004-D1#) | BVA, Hysteresis, NaN FI, MC/DC |
| MOD-005 | 3 (UTP-005-A, UTP-005-B, UTP-005-C) | 3 (UTS-005-A1#, UTS-005-B1#, UTS-005-C1#) | DTT, MC/DC |
| MOD-006 | 3 (UTP-006-A, UTP-006-B, UTP-006-C) | 3 (UTS-006-A1#, UTS-006-B1#, UTS-006-C1#) | Statement, Branch, Fault Injection, MC/DC |
| MOD-007 | 3 (UTP-007-A, UTP-007-B, UTP-007-C) | 3 (UTS-007-A1#, UTS-007-B1#, UTS-007-C1#) | Branch, Fault Injection, MC/DC |
| MOD-008 | 3 (UTP-008-A, UTP-008-B, UTP-008-C) | 3 (UTS-008-A1#, UTS-008-B1#, UTS-008-C1#) | Statement, Branch, Fault Injection, MC/DC |

**Unit Test Coverage: 100%** — All 8 MOD modules have test cases including positive, boundary, fault-injection, and state-transition tests.

## Governing Standards

| Standard | Full Name | Role in this Document |
|----------|-----------|----------------------|
| **DO-178C** | Software Considerations in Airborne Systems and Equipment Certification | DAL-A unit test objectives (Table A-5); MC/DC structural coverage requirement |
| **IEEE 1012:2016** | System, Software, and Hardware V&V | Unit test independence; entry/exit criteria; traceability to module design |
| **ISO/IEC/IEEE 29119-4:2021** | Software and Systems Engineering — Test Design Techniques | BVA, Decision Table, Fault Injection, Arrange/Act/Assert format |
