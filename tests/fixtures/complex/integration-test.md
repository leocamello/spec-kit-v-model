# Integration Test — Complex Fixture (Many-to-Many)

### Module Integration: ARCH-001 → ARCH-002 (MQTT to Validator)

#### Test Case: ITP-001-A (Raw Message Contract)
**Technique**: Interface Contract Testing

* **Integration Scenario: ITS-001-A1**
  * **Given** ARCH-001 produces a RawMessage with payload and checksum
  * **When** ARCH-002 receives the RawMessage
  * **Then** ARCH-002 accepts the message and produces a ValidatedReading

#### Test Case: ITP-001-B (Malformed Payload Injection)
**Technique**: Interface Fault Injection

* **Integration Scenario: ITS-001-B1**
  * **Given** ARCH-001 produces a RawMessage with corrupted payload
  * **When** ARCH-002 receives the malformed message
  * **Then** ARCH-002 raises ChecksumMismatchError without crashing

### Module Integration: ARCH-002 → ARCH-003 (Validator to Aggregator)

#### Test Case: ITP-002-A (Validated Reading Flow)
**Technique**: Data Flow Testing

* **Integration Scenario: ITS-002-A1**
  * **Given** ARCH-002 produces ValidatedReadings at 100 readings per second
  * **When** the readings flow into ARCH-003 aggregation window
  * **Then** ARCH-003 produces correct AggregatedBatch with min/max/avg

### Module Integration: ARCH-003 → ARCH-004 (Aggregator to Storage)

#### Test Case: ITP-003-A (Batch Storage Contract)
**Technique**: Interface Contract Testing

* **Integration Scenario: ITS-003-A1**
  * **Given** ARCH-003 produces an AggregatedBatch
  * **When** ARCH-004 receives the batch
  * **Then** ARCH-004 writes the batch and returns a WriteReceipt

### Module Integration: ARCH-004 → ARCH-007 (Storage to Encryption)

#### Test Case: ITP-004-A (Encryption Data Flow)
**Technique**: Data Flow Testing

* **Integration Scenario: ITS-004-A1**
  * **Given** ARCH-004 sends a DataBlock to ARCH-007
  * **When** ARCH-007 encrypts the block
  * **Then** the ciphertext is AES-256 encrypted and the IV is stored

### Module Integration: ARCH-004 ↔ ARCH-005 (Storage ↔ Query Engine)

#### Test Case: ITP-005-A (Query Contract)
**Technique**: Interface Contract Testing

* **Integration Scenario: ITS-005-A1**
  * **Given** ARCH-004 has stored aggregated data
  * **When** ARCH-005 sends a QueryRequest with time range filter
  * **Then** ARCH-004 returns a ResultSet matching the filter

### Module Integration: ARCH-001 ↔ ARCH-002 (Concurrent Ingestion)

#### Test Case: ITP-006-A (Concurrent Message Processing)
**Technique**: Concurrency & Race Condition Testing

* **Integration Scenario: ITS-006-A1**
  * **Given** ARCH-001 receives messages from 10 concurrent MQTT topics
  * **When** all messages are forwarded to ARCH-002 simultaneously
  * **Then** ARCH-002 processes all messages without data corruption or deadlock

### Module Integration: ARCH-008 ← All Modules (Cross-Cutting Logger)

#### Test Case: ITP-007-A (Logger Integration)
**Technique**: Interface Contract Testing

* **Integration Scenario: ITS-007-A1**
  * **Given** ARCH-002 encounters a ChecksumMismatchError
  * **When** ARCH-002 sends a LogEntry to ARCH-008
  * **Then** ARCH-008 produces a structured JSON log line with correct level and context

### Module Integration: ARCH-004 → ARCH-007 (Encryption Fault)

#### Test Case: ITP-008-A (Key Not Found Injection)
**Technique**: Interface Fault Injection

* **Integration Scenario: ITS-008-A1**
  * **Given** ARCH-004 sends a DataBlock with an invalid key_id
  * **When** ARCH-007 attempts to encrypt
  * **Then** ARCH-007 raises KeyNotFoundError and ARCH-004 handles the error gracefully
