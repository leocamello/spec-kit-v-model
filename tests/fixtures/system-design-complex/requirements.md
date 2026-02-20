# Requirements — Complex Fixture (Many-to-Many)

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-001 | The system SHALL ingest sensor data from multiple sources | P1 | Core | Test |
| REQ-002 | The system SHALL validate sensor data integrity | P1 | Reliability | Test |
| REQ-003 | The system SHALL compute real-time aggregations | P1 | Analytics | Test |
| REQ-004 | The system SHALL persist data to storage | P1 | Durability | Test |
| REQ-005 | The system SHALL expose a REST API for queries | P1 | Integration | Test |
| REQ-NF-001 | The system SHALL process 10000 events per second | P1 | Performance | Test |
| REQ-NF-002 | The system SHALL encrypt data at rest using AES-256 | P1 | Security | Inspection |
| REQ-IF-001 | The system SHALL accept data via MQTT protocol | P1 | Interface | Test |
| REQ-IF-002 | The system SHALL expose metrics via Prometheus endpoint | P2 | Monitoring | Test |
| REQ-CN-001 | The system SHALL use only open-source libraries | P2 | Licensing | Inspection |
