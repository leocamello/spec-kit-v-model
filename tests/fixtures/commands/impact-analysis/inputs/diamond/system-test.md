# System Test Plan — Diamond Fixture

### System Component: SYS-001 (Telemetry Receiver)

#### Test Case: STP-001-A (Reception Test)
**Technique**: Functional Testing

* **System Scenario: STS-001-A1**
  * **Given** SYS-001 is listening on the telemetry port
  * **When** a valid telemetry packet arrives
  * **Then** the packet is received and queued

### System Component: SYS-002 (Telemetry Validator)

#### Test Case: STP-002-A (Validation Test)
**Technique**: Functional Testing

* **System Scenario: STS-002-A1**
  * **Given** SYS-002 receives a telemetry packet from SYS-001
  * **When** the packet schema is checked
  * **Then** valid packets are forwarded, invalid packets are rejected

### System Component: SYS-003 (Cold Storage Writer)

#### Test Case: STP-003-A (Archive Test)
**Technique**: Functional Testing

* **System Scenario: STS-003-A1**
  * **Given** SYS-003 receives validated data from SYS-002
  * **When** the archive threshold is reached
  * **Then** the batch is written to cold storage
