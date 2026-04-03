# Acceptance Test Plan — Linear Fixture

### Requirement: REQ-001

#### Test Case: ATP-001-A (Data Conversion Acceptance)
**Verification Method**: Test

* **Scenario: SCN-001-A1**
  * **Given** the system is running
  * **When** raw data is submitted
  * **Then** converted output is returned

### Requirement: REQ-002

#### Test Case: ATP-002-A (Logging Acceptance)
**Verification Method**: Test

* **Scenario: SCN-002-A1**
  * **Given** a conversion has completed
  * **When** the log is queried
  * **Then** the conversion entry is present
