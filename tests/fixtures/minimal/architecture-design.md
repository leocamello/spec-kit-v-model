# Architecture Design — Minimal Fixture

## Logical View (Component Breakdown)

| ARCH ID | Name | Description | Parent System Components |
|---------|------|-------------|--------------------------|
| ARCH-001 | Sensor Driver | Reads raw sensor data via I2C | SYS-001 |
| ARCH-002 | Alert Evaluator | Evaluates thresholds and triggers alerts | SYS-002 |
| ARCH-003 | Display Controller | Renders status to LCD panel | SYS-003 |
| ARCH-004 | Logger [CROSS-CUTTING] | Structured logging for all modules | SYS-001, SYS-002, SYS-003 |

## Process View (Dynamic Behavior)

```mermaid
sequenceDiagram
    participant SD as ARCH-001 (Sensor Driver)
    participant AE as ARCH-002 (Alert Evaluator)
    participant DC as ARCH-003 (Display Controller)
    SD->>AE: raw_reading(value, timestamp)
    AE->>DC: status_update(level, message)
```

## Interface View (API Contracts)

### ARCH-001: Sensor Driver
- **Protocol:** I2C (400 kHz fast mode)
- **Inputs:** `uint8 i2c_address` (0x00–0x7F), `uint32 polling_interval_ms` (100–60000)
- **Outputs:** `SensorReading { value: float32, timestamp: ISO8601, unit: string }`
- **Exceptions:** `I2CTimeoutError`, `InvalidReadingError`

### ARCH-002: Alert Evaluator
- **Protocol:** In-process function call
- **Inputs:** `SensorReading`, `ThresholdConfig { low: float32, high: float32, unit: string }`
- **Outputs:** `AlertEvent { level: enum(INFO|WARN|CRITICAL), message: string }`
- **Exceptions:** `ThresholdConfigError`

### ARCH-003: Display Controller
- **Protocol:** SPI (10 MHz), 16-bit RGB565 framebuffer
- **Inputs:** `AlertEvent`, `StatusData { label: string, value: string }`
- **Outputs:** `FrameResult { width: uint16, height: uint16, format: enum(RGB565), rendered: bool }`
- **Exceptions:** `DisplayHardwareError`

### ARCH-004: Logger [CROSS-CUTTING]
- **Inputs:** Log level, message, source module identifier
- **Outputs:** `LogEntry { timestamp: ISO8601, level: enum(DEBUG|INFO|WARN|ERROR), source: string, message: string }`
- **Exceptions:** `LogWriteError`

## Data Flow View

```
I2C Bus → ARCH-001 (Sensor Driver) → SensorReading → ARCH-002 (Alert Evaluator) → AlertEvent → ARCH-003 (Display Controller) → LCD Panel
```
