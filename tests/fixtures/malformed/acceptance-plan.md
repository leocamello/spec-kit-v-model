# Acceptance Test Plan

## Requirement Validations

### Requirement Validation: REQ-001 (Valid ID, Malformed ATP)

#### Test Case: ATP001A (Missing Dashes)
**Description:** ATP ID is missing dashes.

* **User Scenario: SCN001A1**
  * **Given** a malformed scenario
  * **When** the validator runs
  * **Then** the ID is flagged

#### Test Case: ATP-001 (Missing Letter Suffix)
**Description:** ATP ID is missing the trailing letter suffix.

* **User Scenario: SCN-001-1 (Numeric Suffix Without Letter)**
  * **Given** a scenario with wrong suffix format
  * **When** the validator runs
  * **Then** the ID is flagged

#### Test Case: ATP-001-A (Valid ATP)
**Description:** This ATP has a valid format.

* **User Scenario: SCN-001-A (Missing Numeric Suffix)**
  * **Given** a scenario missing its numeric part
  * **When** the validator runs
  * **Then** the ID is flagged

* **User Scenario: SCN-001-A1 (Valid SCN)**
  * **Given** a properly formatted scenario
  * **When** the validator runs
  * **Then** the ID passes validation
