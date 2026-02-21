# System Test — Complex Fixture (Many-to-Many)

### Component Verification: SYS-001 (Data Ingestion Service)

#### Test Case: STP-001-A (MQTT Data Reception)

**Technique**: Interface Contract Testing

* **System Scenario: STS-001-A1**
  * **Given** the Data Ingestion Service is connected to an MQTT broker
  * **When** a valid sensor payload is published to the topic
  * **Then** the service acknowledges receipt within 50ms

#### Test Case: STP-001-B (Multi-Source Handling)

**Technique**: Boundary Value Analysis

* **System Scenario: STS-001-B1**
  * **Given** 100 concurrent sensor sources are publishing data
  * **When** the ingestion pipeline processes the stream
  * **Then** zero messages are dropped over a 60-second window

### Component Verification: SYS-002 (Data Validator)

#### Test Case: STP-002-A (Integrity Validation)

**Technique**: Equivalence Partitioning

* **System Scenario: STS-002-A1**
  * **Given** the Data Validator receives a payload with valid checksum
  * **When** the validation routine executes
  * **Then** the payload is marked as VALID and forwarded

### Component Verification: SYS-003 (Aggregation Engine)

#### Test Case: STP-003-A (Real-Time Aggregation)

**Technique**: Boundary Value Analysis

* **System Scenario: STS-003-A1**
  * **Given** the Aggregation Engine has a sliding window of 1000 events
  * **When** event number 1001 arrives
  * **Then** the oldest event is evicted and the aggregate is recomputed within 10ms

### Component Verification: SYS-004 (Storage Manager)

#### Test Case: STP-004-A (Encrypted Persistence)

**Technique**: Interface Contract Testing

* **System Scenario: STS-004-A1**
  * **Given** the Storage Manager receives a validated data record
  * **When** the write operation completes
  * **Then** the data is persisted with AES-256 encryption at rest

### Component Verification: SYS-005 (REST API Gateway)

#### Test Case: STP-005-A (Query Endpoint)

**Technique**: Interface Contract Testing

* **System Scenario: STS-005-A1**
  * **Given** the REST API Gateway is running and the database contains 500 records
  * **When** a GET request is sent to /api/data?limit=10
  * **Then** the gateway returns a 200 response with exactly 10 records in JSON format

### Component Verification: SYS-006 (Metrics Exporter)

#### Test Case: STP-006-A (Prometheus Endpoint)

**Technique**: Interface Contract Testing

* **System Scenario: STS-006-A1**
  * **Given** the Metrics Exporter is initialized with default counters
  * **When** a GET request is sent to /metrics
  * **Then** the exporter returns text/plain content in Prometheus exposition format
