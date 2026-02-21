# Acceptance Test Plan

## Test Strategy

This acceptance test plan validates all requirements defined in the Requirements Specification.
Each requirement has one or more test cases, and each test case has one or more executable BDD scenarios.
NOTE: This fixture includes an orphaned test case (ATP-999-A) to test orphan detection.

## Requirement Validations

### Requirement Validation: REQ-001 (Sensor Data Ingestion)

#### Test Case: ATP-001-A (Multi-Source Ingestion)
**Description:** Verify sensor data ingestion from multiple sources.

* **User Scenario: SCN-001-A1**
  * **Given** multiple sensor sources are configured
  * **When** data arrives from each source
  * **Then** the system ingests all data streams

### Requirement Validation: REQ-002 (Data Integrity Validation)

#### Test Case: ATP-002-A (Integrity Check)
**Description:** Verify sensor data integrity validation.

* **User Scenario: SCN-002-A1**
  * **Given** sensor data with checksums is received
  * **When** the validation routine executes
  * **Then** corrupted data is rejected and valid data is accepted

### Requirement Validation: REQ-003 (Real-Time Aggregation)

#### Test Case: ATP-003-A (Aggregation Accuracy)
**Description:** Verify real-time aggregation computation.

* **User Scenario: SCN-003-A1**
  * **Given** a stream of sensor readings
  * **When** the aggregation window closes
  * **Then** the system produces correct min/max/avg values

### Requirement Validation: REQ-004 (Data Persistence)

#### Test Case: ATP-004-A (Storage Write)
**Description:** Verify data persistence to storage.

* **User Scenario: SCN-004-A1**
  * **Given** validated sensor data is available
  * **When** the persistence routine executes
  * **Then** data is written to durable storage

### Requirement Validation: REQ-005 (REST API)

#### Test Case: ATP-005-A (Query Endpoint)
**Description:** Verify REST API query functionality.

* **User Scenario: SCN-005-A1**
  * **Given** persisted sensor data exists
  * **When** a GET request is made to the query endpoint
  * **Then** the API returns the requested data in JSON format

### Requirement Validation: REQ-NF-001 (Throughput)

#### Test Case: ATP-NF-001-A (Event Throughput)
**Description:** Verify 10000 events per second throughput.

* **User Scenario: SCN-NF-001-A1**
  * **Given** the system is under load
  * **When** 10000 events per second are submitted
  * **Then** all events are processed without loss

### Requirement Validation: REQ-NF-002 (Encryption)

#### Test Case: ATP-NF-002-A (AES-256 Encryption)
**Description:** Verify data at rest encryption.

* **User Scenario: SCN-NF-002-A1**
  * **Given** data has been persisted to storage
  * **When** the raw storage is inspected
  * **Then** data is encrypted with AES-256

### Requirement Validation: REQ-IF-001 (MQTT Interface)

#### Test Case: ATP-IF-001-A (MQTT Data Reception)
**Description:** Verify MQTT protocol data acceptance.

* **User Scenario: SCN-IF-001-A1**
  * **Given** an MQTT broker is running
  * **When** sensor data is published to the configured topic
  * **Then** the system receives and processes the data

### Requirement Validation: REQ-IF-002 (Prometheus Metrics)

#### Test Case: ATP-IF-002-A (Metrics Endpoint)
**Description:** Verify Prometheus metrics endpoint.

* **User Scenario: SCN-IF-002-A1**
  * **Given** the system is running
  * **When** a GET request is made to /metrics
  * **Then** Prometheus-formatted metrics are returned

### Requirement Validation: REQ-CN-001 (Open Source)

#### Test Case: ATP-CN-001-A (License Compliance)
**Description:** Verify open-source license compliance.

* **User Scenario: SCN-CN-001-A1**
  * **Given** the system dependency manifest
  * **When** all dependencies are audited
  * **Then** all libraries use OSI-approved open-source licenses

## Orphaned Test (No Matching Requirement)

### Requirement Validation: REQ-999 (Nonexistent)

#### Test Case: ATP-999-A (Orphaned Test Case)
**Description:** This test case has no matching requirement — used to verify orphan detection.

* **User Scenario: SCN-999-A1**
  * **Given** this test is orphaned
  * **When** coverage analysis runs
  * **Then** this ATP should be flagged as orphaned

## Coverage Summary

| Requirement | Test Cases | Scenarios | Status |
|-------------|-----------|-----------|--------|
| REQ-001 | 1 | 1 | ⬜ Untested |
| REQ-002 | 1 | 1 | ⬜ Untested |
| REQ-003 | 1 | 1 | ⬜ Untested |
| REQ-004 | 1 | 1 | ⬜ Untested |
| REQ-005 | 1 | 1 | ⬜ Untested |
| REQ-NF-001 | 1 | 1 | ⬜ Untested |
| REQ-NF-002 | 1 | 1 | ⬜ Untested |
| REQ-IF-001 | 1 | 1 | ⬜ Untested |
| REQ-IF-002 | 1 | 1 | ⬜ Untested |
| REQ-CN-001 | 1 | 1 | ⬜ Untested |

**Coverage: 100%** — All requirements have test cases. ATP-999-A is orphaned (no matching requirement).
