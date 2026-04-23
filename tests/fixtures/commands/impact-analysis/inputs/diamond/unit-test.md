# Unit Test Plan — Diamond Fixture

### Module: MOD-001 (Header Decoder)

**Parent Architecture Modules**: ARCH-001

#### Test Case: UTP-001-A (Decode Success)
**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic / Logic View

* **Unit Scenario: UTS-001-A1**
  * **Arrange**: Prepare valid 16-byte telemetry packet.
  * **Act**: Call `decode(raw)`.
  * **Assert**: ParsedPacket contains expected fields.

---

### Module: MOD-002 (Field Validator)

**Parent Architecture Modules**: ARCH-002

#### Test Case: UTP-002-A (Schema Pass)
**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic / Logic View

* **Unit Scenario: UTS-002-A1**
  * **Arrange**: Create ParsedPacket with all required fields.
  * **Act**: Call `validate(packet, schema)`.
  * **Assert**: Returns ValidatedPacket with valid=True.

* **Unit Scenario: UTS-002-A2**
  * **Arrange**: Create ParsedPacket missing a required field.
  * **Act**: Call `validate(packet, schema)`.
  * **Assert**: Raises SchemaError.

---

### Module: MOD-003 (Disk Flusher)

**Parent Architecture Modules**: ARCH-003

#### Test Case: UTP-003-A (Flush to Disk)
**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic / Logic View

* **Unit Scenario: UTS-003-A1**
  * **Arrange**: Create batch of 10 ValidatedPackets.
  * **Act**: Call `flush(batch, "/tmp/test.bin")`.
  * **Assert**: File is written with serialized data.

---

### Module: MOD-004 (Metric Aggregator)

**Parent Architecture Modules**: ARCH-004

#### Test Case: UTP-004-A (Counter Increment)
**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic / Logic View

* **Unit Scenario: UTS-004-A1**
  * **Arrange**: Initialize empty counters.
  * **Act**: Call `record("packets_received", 1.0)` twice.
  * **Assert**: `counters["packets_received"]` equals 2.0.
