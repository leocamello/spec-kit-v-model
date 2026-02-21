# System Design — Minimal Fixture

## Decomposition View (IEEE 1016 §5.1)

| SYS ID | Name | Description | Parent Requirements | Type |
|--------|------|-------------|---------------------|------|
| SYS-001 | Data Processor | Processes sensor data | REQ-001 | Module |
| SYS-002 | Alert Engine | Generates alerts | REQ-002 | Module |
| SYS-003 | Display Renderer | Renders status display | REQ-003 | Module |

## Dependency View (IEEE 1016 §5.2)

| Source | Target | Relationship | Failure Impact |
|--------|--------|-------------|----------------|
| SYS-002 | SYS-001 | Subscribes | Alert Engine cannot generate alerts if Data Processor is unavailable |
| SYS-003 | SYS-001 | Reads | Display Renderer shows stale status if Data Processor fails |
| SYS-003 | SYS-002 | Reads | Display Renderer cannot show active alerts if Alert Engine fails |

## Interface View (IEEE 1016 §5.3)

### External Interfaces

| Component | Interface Name | Protocol | Input | Output | Error Handling |
|-----------|---------------|----------|-------|--------|----------------|
| SYS-001 | Sensor Input | Serial I/O | Raw sensor bytes | Parsed sensor readings (JSON) | Returns error code on malformed input |
| SYS-003 | Status Display | HTTP | GET /status | HTML status page | 503 when upstream unavailable |

### Internal Interfaces

| Source | Target | Interface Name | Protocol | Data Format | Error Handling |
|--------|--------|---------------|----------|-------------|----------------|
| SYS-001 | SYS-002 | Sensor Event Bus | Message Queue | `{ "sensorId": string, "value": float, "ts": ISO-8601 }` | Dead-letter queue on delivery failure |
| SYS-001 | SYS-003 | Status Feed | Message Queue | `{ "sensorId": string, "status": string, "ts": ISO-8601 }` | Last-known-good value cached |

## Data Design View (IEEE 1016 §5.4)

| Entity | Component | Storage | Format | Protection in Transit | Retention |
|--------|-----------|---------|--------|-----------------------|-----------|
| Sensor Readings | SYS-001 | In-memory buffer | JSON (`{ "sensorId": string, "value": float, "ts": ISO-8601 }`) | N/A (internal) | Rolling 60-second window |
| Alert Records | SYS-002 | In-memory list | JSON (`{ "alertId": string, "sensorId": string, "severity": string, "ts": ISO-8601 }`) | N/A (internal) | Until acknowledged |
| Display State | SYS-003 | In-memory cache | JSON snapshot of current sensor and alert status | N/A (internal) | Current value only |

## Derived Requirements

| ID | Description | Source | Annotation |
|----|-------------|--------|------------|
| SYS-DR-001 | Inter-component messages SHALL use JSON with ISO-8601 timestamps | Architectural decision: common message format across SYS-001, SYS-002, SYS-003 | [DERIVED REQUIREMENT] |
| SYS-DR-002 | SYS-001 SHALL poll sensors at a minimum interval of 1 second | Architectural decision: real-time alert generation requires bounded data freshness | [DERIVED REQUIREMENT] |
| SYS-DR-003 | Internal communication between components SHALL use a message queue protocol | Architectural decision: asynchronous decoupling via Sensor Event Bus and Status Feed (Interface View §5.3) | [DERIVED REQUIREMENT] |
| SYS-DR-004 | Sensor readings SHALL be retained in a rolling 60-second in-memory buffer | Architectural decision: bounded memory usage while supporting alert evaluation window (Data Design View §5.4) | [DERIVED REQUIREMENT] |
| SYS-DR-005 | Failed message delivery SHALL use a dead-letter queue for deferred reprocessing | Architectural decision: graceful degradation on inter-component communication failure (Interface View §5.3) | [DERIVED REQUIREMENT] |
