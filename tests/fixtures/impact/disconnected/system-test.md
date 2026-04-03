# System Test Plan — Disconnected Fixture

### System Component: SYS-001 (Encryption Service)

#### Test Case: STP-001-A (Encryption Test)
**Technique**: Functional Testing

* **System Scenario: STS-001-A1**
  * **Given** SYS-001 is initialized with a valid key
  * **When** plaintext data is submitted
  * **Then** ciphertext is stored correctly

### System Component: SYS-002 (Report Generator)

#### Test Case: STP-002-A (Report Generation Test)
**Technique**: Functional Testing

* **System Scenario: STS-002-A1**
  * **Given** SYS-002 has access to the data store
  * **When** a report is requested
  * **Then** a correctly formatted PDF is generated
