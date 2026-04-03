# System Design — Diamond Fixture

## Decomposition View (IEEE 1016 §5.1)

Both SYS-001 and SYS-002 depend on REQ-001, creating a fan-out from REQ-001.
SYS-003 depends on REQ-002 and is isolated from the REQ-001 subgraph.

| SYS ID | Name | Description | Parent Requirements | Type |
|--------|------|-------------|---------------------|------|
| SYS-001 | Telemetry Receiver | Receives raw telemetry | REQ-001 | Module |
| SYS-002 | Telemetry Validator | Validates telemetry data | REQ-001, REQ-NF-001 | Module |
| SYS-003 | Cold Storage Writer | Writes data to archive | REQ-002 | Module |

## Dependency View (IEEE 1016 §5.2)

| Source | Target | Relationship | Failure Impact |
|--------|--------|-------------|----------------|
| SYS-002 | SYS-001 | Consumes | Validator cannot operate without Receiver |
| SYS-003 | SYS-002 | Consumes | Archive cannot write unvalidated data |
