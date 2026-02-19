# Acceptance Test Plan

## Test Strategy

This acceptance test plan validates all requirements defined in the Requirements Specification.
Each requirement has one or more test cases, and each test case has one or more executable BDD scenarios.

## Requirement Validations

### Requirement Validation: REQ-001 (User Login)

#### Test Case: ATP-001-A (Valid Credentials)
**Description:** Verify that a user with valid credentials can successfully log in.

* **User Scenario: SCN-001-A1**
  * **Given** the user is on the login page
  * **When** the user enters a valid email and password
  * **And** clicks the "Login" button
  * **Then** the system redirects to the dashboard
  * **And** a session token is issued

#### Test Case: ATP-001-B (Invalid Credentials)
**Description:** Verify that invalid credentials are rejected with an appropriate error.

* **User Scenario: SCN-001-B1**
  * **Given** the user is on the login page
  * **When** the user enters an invalid password
  * **And** clicks the "Login" button
  * **Then** the system displays "Invalid email or password"
  * **And** no session token is issued

### Requirement Validation: REQ-002 (Password Reset)

#### Test Case: ATP-002-A (Valid Email Reset)
**Description:** Verify that a user with a registered email can request a password reset.

* **User Scenario: SCN-002-A1**
  * **Given** the user is on the "Forgot Password" page
  * **When** the user enters a valid, registered email address
  * **And** clicks the "Send Link" button
  * **Then** the system displays a "Check your email" success message
  * **And** a password reset email is dispatched

#### Test Case: ATP-002-B (Unregistered Email)
**Description:** Verify the system handles reset requests for unregistered emails safely.

* **User Scenario: SCN-002-B1**
  * **Given** the user is on the "Forgot Password" page
  * **When** the user enters an unregistered email address
  * **And** clicks the "Send Link" button
  * **Then** the system displays a generic "If this email is registered, a link has been sent" message

### Requirement Validation: REQ-NF-001 (Response Time)

#### Test Case: ATP-NF-001-A (Normal Load Response Time)
**Description:** Verify all API endpoints respond within 2 seconds under normal load.

* **User Scenario: SCN-NF-001-A1**
  * **Given** the system is running under normal load (100 concurrent users)
  * **When** any API endpoint is called
  * **Then** the response is received within 2 seconds

## Coverage Summary

| Requirement | Test Cases | Scenarios | Status |
|-------------|-----------|-----------|--------|
| REQ-001 | 2 (ATP-001-A, ATP-001-B) | 2 (SCN-001-A1, SCN-001-B1) | ⬜ Untested |
| REQ-002 | 2 (ATP-002-A, ATP-002-B) | 2 (SCN-002-A1, SCN-002-B1) | ⬜ Untested |
| REQ-NF-001 | 1 (ATP-NF-001-A) | 1 (SCN-NF-001-A1) | ⬜ Untested |

**Coverage: 100%** — All 3 requirements have test cases and scenarios.
