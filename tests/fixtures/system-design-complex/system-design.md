# System Design — Complex Fixture (Many-to-Many)

## Decomposition View (IEEE 1016 §5.1)

| SYS ID | Name | Description | Parent Requirements | Type |
|--------|------|-------------|---------------------|------|
| SYS-001 | Data Ingestion Service | Receives sensor data from multiple sources | REQ-001, REQ-IF-001 | Service |
| SYS-002 | Data Validator | Validates integrity of incoming data | REQ-002 | Module |
| SYS-003 | Aggregation Engine | Computes real-time aggregations | REQ-003, REQ-NF-001 | Module |
| SYS-004 | Storage Manager | Persists data with encryption | REQ-004, REQ-NF-002, REQ-CN-001 | Service |
| SYS-005 | REST API Gateway | Exposes query API | REQ-005 | Service |
| SYS-006 | Metrics Exporter | Exposes Prometheus metrics | REQ-IF-002 | Utility |
