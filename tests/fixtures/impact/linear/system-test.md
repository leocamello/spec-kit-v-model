# System Test Plan — Linear Fixture

### System Component: SYS-001 (Converter)

#### Test Case: STP-001-A (Conversion Verification)
**Technique**: Functional Testing

* **System Scenario: STS-001-A1**
  * **Given** SYS-001 is initialized
  * **When** raw input is provided
  * **Then** correct converted output is returned

### System Component: SYS-002 (Audit Logger)

#### Test Case: STP-002-A (Logging Verification)
**Technique**: Functional Testing

* **System Scenario: STS-002-A1**
  * **Given** SYS-002 is active
  * **When** a conversion event occurs in SYS-001
  * **Then** the event is recorded in the audit log
