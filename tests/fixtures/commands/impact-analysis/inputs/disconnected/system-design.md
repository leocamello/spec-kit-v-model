# System Design — Disconnected Fixture

## Decomposition View (IEEE 1016 §5.1)

Two completely independent system components with no dependencies between them.

| SYS ID | Name | Description | Parent Requirements | Type |
|--------|------|-------------|---------------------|------|
| SYS-001 | Encryption Service | Encrypts data at rest | REQ-001 | Module |
| SYS-002 | Report Generator | Generates compliance reports | REQ-002 | Module |

## Dependency View (IEEE 1016 §5.2)

| Source | Target | Relationship | Failure Impact |
|--------|--------|-------------|----------------|
