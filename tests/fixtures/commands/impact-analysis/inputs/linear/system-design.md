# System Design — Linear Fixture

## Decomposition View (IEEE 1016 §5.1)

| SYS ID | Name | Description | Parent Requirements | Type |
|--------|------|-------------|---------------------|------|
| SYS-001 | Converter | Performs data conversion | REQ-001 | Module |
| SYS-002 | Audit Logger | Logs conversion events | REQ-002 | Module |

## Dependency View (IEEE 1016 §5.2)

| Source | Target | Relationship | Failure Impact |
|--------|--------|-------------|----------------|
| SYS-002 | SYS-001 | Subscribes | Logger cannot record if Converter unavailable |
