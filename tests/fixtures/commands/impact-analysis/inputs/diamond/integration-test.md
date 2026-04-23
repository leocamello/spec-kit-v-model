# Integration Test — Diamond Fixture

### Module Integration: ARCH-001 → ARCH-002 (Parser to Validator)

#### Test Case: ITP-001-A (Packet Handoff Contract)
**Technique**: Interface Contract Testing

* **Integration Scenario: ITS-001-A1**
  * **Given** ARCH-001 produces a ParsedPacket
  * **When** ARCH-002 receives the packet
  * **Then** ARCH-002 validates without error

### Module Integration: ARCH-002 → ARCH-003 (Validator to Writer)

#### Test Case: ITP-002-A (Batch Delivery Contract)
**Technique**: Interface Contract Testing

* **Integration Scenario: ITS-002-A1**
  * **Given** ARCH-002 produces a batch of ValidatedPackets
  * **When** ARCH-003 receives the batch
  * **Then** ARCH-003 writes to disk successfully

### Module Integration: ARCH-001 → ARCH-004 (Parser to Metrics)

#### Test Case: ITP-003-A (Metrics Collection)
**Technique**: Interface Contract Testing

* **Integration Scenario: ITS-003-A1**
  * **Given** ARCH-001 emits a metric event
  * **When** ARCH-004 receives the event
  * **Then** ARCH-004 increments the packets_received counter
