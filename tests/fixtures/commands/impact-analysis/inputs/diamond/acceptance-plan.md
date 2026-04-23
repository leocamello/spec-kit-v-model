# Acceptance Test Plan — Diamond Fixture

### Requirement: REQ-001

#### Test Case: ATP-001-A (Telemetry Ingestion)
**Verification Method**: Test

* **Scenario: SCN-001-A1**
  * **Given** a telemetry stream is active
  * **When** data arrives
  * **Then** the system ingests it successfully

### Requirement: REQ-002

#### Test Case: ATP-002-A (Data Archival)
**Verification Method**: Test

* **Scenario: SCN-002-A1**
  * **Given** telemetry data has been ingested
  * **When** the archive window expires
  * **Then** data is written to cold storage

### Requirement: REQ-NF-001

#### Test Case: ATP-003-A (Response Time)
**Verification Method**: Test

* **Scenario: SCN-003-A1**
  * **Given** the system is under normal load
  * **When** a telemetry packet arrives
  * **Then** processing completes within 100 ms
