# Unit Test Plan — Minimal Fixture

### Module: MOD-001 (I2C Read Handler)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `src/sensor/i2c_reader.py`

#### Test Case: UTP-001-A (Statement & Branch Coverage)
**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic / Logic View
**Description**: Exercise both success and timeout branches of `read_sensor`.

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Justification |
|------------|---------------|---------------|
| i2c_read | Stub returning fixed bytes or timeout | Isolate hardware I/O |

* **Unit Scenario: UTS-001-A1**
  * **Arrange**: Set `bus_addr=0x48`, `register=0x00`; stub `i2c_read` to return `[0x09, 0xC4]`.
  * **Act**: Call `read_sensor(bus_addr, register)`.
  * **Assert**: Return value equals `SensorReading(25.0, *, "°C")`.

* **Unit Scenario: UTS-001-A2**
  * **Arrange**: Set `bus_addr=0x48`, `register=0x00`; stub `i2c_read` to raise timeout.
  * **Act**: Call `read_sensor(bus_addr, register)`.
  * **Assert**: Raises `I2CTimeoutError`.

#### Test Case: UTP-001-B (Boundary Value Analysis)
**Technique**: Boundary Value Analysis
**Target View**: Algorithmic / Logic View
**Description**: Verify boundary conditions for the valid reading range [−40, 125].

**Dependency & Mock Registry:**

| Dependency | Mock Strategy | Justification |
|------------|---------------|---------------|
| i2c_read | Stub returning boundary-encoded bytes | Isolate hardware I/O |

* **Unit Scenario: UTS-001-B1**
  * **Arrange**: Stub `i2c_read` to return bytes encoding `−40.01` (min − 1).
  * **Act**: Call `read_sensor(0x48, 0x00)`.
  * **Assert**: Raises `InvalidReadingError`.

* **Unit Scenario: UTS-001-B2**
  * **Arrange**: Stub `i2c_read` to return bytes encoding `−40.00` (min).
  * **Act**: Call `read_sensor(0x48, 0x00)`.
  * **Assert**: Return value equals `SensorReading(−40.00, *, "°C")`.

* **Unit Scenario: UTS-001-B3**
  * **Arrange**: Stub `i2c_read` to return bytes encoding `125.01` (max + 1).
  * **Act**: Call `read_sensor(0x48, 0x00)`.
  * **Assert**: Raises `InvalidReadingError`.

---

### Module: MOD-002 (Threshold Checker)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `src/alert/threshold.py`

#### Test Case: UTP-002-A (State Transition Testing)
**Technique**: State Transition Testing
**Target View**: State Machine View
**Description**: Verify valid and invalid state transitions of the threshold evaluator.

**Dependency & Mock Registry:** None — module is self-contained.

* **Unit Scenario: UTS-002-A1**
  * **Arrange**: Set state to `Idle`; set `config.warn=80.0`, `config.clear=70.0`.
  * **Act**: Call `evaluate(SensorReading(85.0), config)`.
  * **Assert**: State transitions to `Alerting`; return value is `AlertEvent(WARN, *)`.

* **Unit Scenario: UTS-002-A2**
  * **Arrange**: Set state to `Idle`; set `config.warn=80.0`.
  * **Act**: Call `evaluate(SensorReading(50.0), config)`.
  * **Assert**: State remains `Idle`; return value is `None`.

#### Test Case: UTP-002-B (Statement & Branch Coverage)
**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic / Logic View
**Description**: Cover Alerting→Cooldown and Cooldown→Idle branches.

**Dependency & Mock Registry:** None — module is self-contained.

* **Unit Scenario: UTS-002-B1**
  * **Arrange**: Set state to `Alerting`; set `config.clear=70.0`.
  * **Act**: Call `evaluate(SensorReading(65.0), config)`.
  * **Assert**: State transitions to `Cooldown`.

* **Unit Scenario: UTS-002-B2**
  * **Arrange**: Set state to `Cooldown`; expire the cooldown timer.
  * **Act**: Call `evaluate(SensorReading(65.0), config)`.
  * **Assert**: State transitions to `Idle`.

---

### Module: MOD-003 (Frame Renderer)

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `src/display/renderer.py`

#### Test Case: UTP-003-A (Statement & Branch Coverage)
**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic / Logic View
**Description**: Exercise render paths with and without an active alert.

**Dependency & Mock Registry:** None — module is self-contained.

* **Unit Scenario: UTS-003-A1**
  * **Arrange**: Set `alert_event=AlertEvent(WARN, "High temp")`; set `status.timestamp="2024-01-01T00:00:00Z"`.
  * **Act**: Call `render_frame(alert_event, status)`.
  * **Assert**: Returned frame contains alert banner bytes at expected offset.

* **Unit Scenario: UTS-003-A2**
  * **Arrange**: Set `alert_event=None`; set `status.timestamp="2024-01-01T00:00:00Z"`.
  * **Act**: Call `render_frame(alert_event, status)`.
  * **Assert**: Returned frame contains header only; no alert banner present.

---

### Module: MOD-004 (Log Writer) [CROSS-CUTTING]

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `src/logging/writer.py`

#### Test Case: UTP-004-A (Equivalence Partitioning)
**Technique**: Equivalence Partitioning
**Target View**: Algorithmic / Logic View
**Description**: Partition log calls into valid and invalid level classes.

**Dependency & Mock Registry:** None — module is self-contained.

* **Unit Scenario: UTS-004-A1**
  * **Arrange**: Set `level="INFO"`, `message="startup"`, `source="SensorDriver"`.
  * **Act**: Call `write_log(level, message, source)`.
  * **Assert**: Return value is `OK`; sink contains one `LogEntry` with matching fields.

* **Unit Scenario: UTS-004-A2**
  * **Arrange**: Set `level="TRACE"`, `message="detail"`, `source="SensorDriver"`.
  * **Act**: Call `write_log(level, message, source)`.
  * **Assert**: Raises `InvalidLogLevel`.

---

## Coverage Summary

| Metric | Value |
|--------|-------|
| Total UTPs | 6 |
| Total UTSs | 13 |
| MODs covered | 4 / 4 |
| Cross-cutting MODs tested | 1 |

## Technique Distribution

| Technique | UTPs | UTSs |
|-----------|------|------|
| Statement & Branch Coverage | 3 | 6 |
| Boundary Value Analysis | 1 | 3 |
| State Transition Testing | 1 | 2 |
| Equivalence Partitioning | 1 | 2 |
