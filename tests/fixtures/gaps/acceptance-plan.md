# Acceptance Test Plan

## Test Strategy

This acceptance test plan validates requirements from the Requirements Specification.
NOTE: This fixture intentionally has a coverage gap — REQ-NF-001 has no test cases.

## Requirement Validations

### Requirement Validation: REQ-001 (User Login)

#### Test Case: ATP-001-A (Valid Credentials)
**Description:** Verify that a user with valid credentials can successfully log in.

* **User Scenario: SCN-001-A1**
  * **Given** the user is on the login page
  * **When** the user enters a valid email and password
  * **And** clicks the "Login" button
  * **Then** the system redirects to the dashboard

### Requirement Validation: REQ-002 (Password Reset)

#### Test Case: ATP-002-A (Valid Email Reset)
**Description:** Verify that a user with a registered email can request a password reset.

* **User Scenario: SCN-002-A1**
  * **Given** the user is on the "Forgot Password" page
  * **When** the user enters a valid, registered email address
  * **And** clicks the "Send Link" button
  * **Then** the system displays a "Check your email" success message

## Coverage Summary

| Requirement | Test Cases | Scenarios | Status |
|-------------|-----------|-----------|--------|
| REQ-001 | 1 (ATP-001-A) | 1 (SCN-001-A1) | ⬜ Untested |
| REQ-002 | 1 (ATP-002-A) | 1 (SCN-002-A1) | ⬜ Untested |
| REQ-NF-001 | **0** | **0** | ❌ No Test Cases |

**Coverage: 67%** — 1 requirement (REQ-NF-001) has no test cases.
