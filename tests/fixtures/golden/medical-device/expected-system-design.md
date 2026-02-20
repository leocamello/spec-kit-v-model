# System Design — Continuous Blood Glucose Monitoring System (CBGMS)

## ID Schema

System components use the `SYS-NNN` identifier format (sequential, never renumbered).
Each component traces to one or more parent requirements via the "Parent Requirements" column.

## Decomposition View (IEEE 1016 §5.1)

| SYS ID | Name | Description | Parent Requirements | Type |
|--------|------|-------------|---------------------|------|
| SYS-001 | Glucose Sensor Interface | Acquires raw glucose readings from the electrochemical sensor at 5-minute intervals via SPI bus | REQ-001 | Hardware Abstraction |
| SYS-002 | Signal Processing Engine | Applies enzyme-kinetics calibration curve to convert raw nanoamp readings to mg/dL values; enforces ±15% / ±15 mg/dL accuracy bounds | REQ-001, REQ-NF-001 | Module |
| SYS-003 | Alert Manager | Evaluates calibrated glucose values against configurable thresholds (55–400 mg/dL); triggers audible alarms and dispatches SMS escalation to emergency contacts within 30 seconds of threshold breach | REQ-002 | Service |
| SYS-004 | BLE Communication Module | Manages Bluetooth Low Energy 5.0 pairing, GATT profile advertisement, encrypted data transfer to companion mobile app, and 30-second auto-reconnection on link loss | REQ-IF-001 | Service |
| SYS-005 | Data Storage Manager | Persists timestamped glucose readings for 90-day rolling retention; provides CSV and PDF export via companion app API | REQ-CN-001 | Service |

## Dependency View (IEEE 1016 §5.2)

| Source | Target | Relationship | Failure Impact |
|--------|--------|-------------|----------------|
| SYS-001 | SYS-002 | SYS-001 provides raw sensor readings to SYS-002 for calibration | Loss of SYS-001 halts all glucose monitoring; SYS-002 enters safe-state with last-known value and alarm |
| SYS-002 | SYS-003 | SYS-002 publishes calibrated mg/dL values to SYS-003 for threshold evaluation | Loss of SYS-002 triggers SYS-003 stale-data alarm after 10-minute timeout |
| SYS-002 | SYS-005 | SYS-002 streams calibrated readings to SYS-005 for persistence | Loss of SYS-005 does not affect real-time monitoring; readings are buffered and replayed on recovery |
| SYS-003 | SYS-004 | SYS-003 dispatches alert payloads to SYS-004 for BLE transmission to companion app | Loss of SYS-004 triggers SYS-003 fallback to on-device audible alarm only |
| SYS-005 | SYS-004 | SYS-005 transfers export files to SYS-004 for BLE delivery | Loss of SYS-004 queues export until BLE link is restored |

## Interface View (IEEE 1016 §5.3)

### External Interfaces

| Interface | Protocol | Direction | Data Format | Error Handling |
|-----------|----------|-----------|-------------|----------------|
| Electrochemical Sensor | SPI (4 MHz) | Inbound | 16-bit ADC sample (nanoamps) | CRC-16 validation; discard and retry on checksum failure |
| Companion Mobile App | BLE 5.0 GATT | Bidirectional | CBOR-encoded glucose record (timestamp, mg/dL, trend) | 30-second exponential-backoff reconnection; 3 retry limit per session |
| SMS Gateway | HTTPS REST | Outbound | JSON payload (alert type, glucose value, patient ID) | Retry with 10-second interval; maximum 3 attempts; log failure to audit trail |

### Internal Interfaces

| Producer | Consumer | Contract | Latency Budget |
|----------|----------|----------|----------------|
| SYS-001 | SYS-002 | `RawReading { timestamp_ms: u64, nanoamps: f32, sensor_id: u8 }` | ≤ 50 ms |
| SYS-002 | SYS-003 | `CalibratedReading { timestamp_ms: u64, mg_dl: f32, confidence: f32 }` | ≤ 100 ms |
| SYS-002 | SYS-005 | `CalibratedReading { timestamp_ms: u64, mg_dl: f32, confidence: f32 }` | ≤ 500 ms (buffered) |
| SYS-003 | SYS-004 | `AlertPayload { alert_type: enum, glucose_value: f32, contacts: Vec<String> }` | ≤ 200 ms |

## Data Design View (IEEE 1016 §5.4)

| Entity | Storage | Retention | Protection at Rest | Protection in Transit |
|--------|---------|-----------|--------------------|-----------------------|
| Glucose Reading | On-device flash (NOR, 8 MB) | 90 days rolling; FIFO eviction | AES-128-CTR with device-unique key | BLE 5.0 LE Secure Connections (AES-CCM) |
| Alert Event Log | On-device flash (reserved 512 KB partition) | 90 days rolling | AES-128-CTR | BLE 5.0 LE Secure Connections |
| Patient Profile | Companion app local storage | Until account deletion | OS-level keychain / keystore | TLS 1.3 (app-to-cloud sync) |
| Export Archive | Generated on demand (CSV/PDF) | Transient; deleted after BLE transfer confirmed | Not stored at rest | BLE 5.0 LE Secure Connections |

## Coverage Summary

| Metric | Value |
|--------|-------|
| Total SYS Components | 5 |
| Requirements Covered | 5 / 5 (100%) |
| Uncovered Requirements | — |

## Derived Requirements

| ID | Description | Source Component | Rationale |
|----|-------------|-----------------|-----------|
| REQ-DR-001 | The system SHALL buffer calibrated readings in a 64-record ring buffer when BLE link is unavailable | SYS-004, SYS-005 | Architectural constraint: BLE link loss must not cause data loss; discovered during dependency analysis |
| REQ-DR-002 | The system SHALL enter a safe-state displaying last-known glucose value and audible alarm when SYS-001 fails to deliver a reading within 10 minutes | SYS-001, SYS-002 | Safety constraint: sensor failure must not silently halt monitoring |
