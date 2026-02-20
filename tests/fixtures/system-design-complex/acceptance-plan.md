# Acceptance Test Plan

## Test Strategy

This acceptance test plan validates all requirements. It includes full coverage for most requirements,
plus intentional orphaned ATPs (ATP-999-A) to test orphan detection.

## Requirement Validations

### Requirement Validation: REQ-001 (User Registration)

#### Test Case: ATP-001-A (Successful Registration)
**Description:** Verify a new user can register with valid data.

* **User Scenario: SCN-001-A1**
  * **Given** the user is on the registration page
  * **When** the user enters a valid email, password, and display name
  * **And** clicks "Create Account"
  * **Then** the account is created and a confirmation email is sent

#### Test Case: ATP-001-B (Duplicate Email)
**Description:** Verify registration is rejected for an already-registered email.

* **User Scenario: SCN-001-B1**
  * **Given** a user with email "test@example.com" already exists
  * **When** a new user tries to register with "test@example.com"
  * **Then** the system displays "Email already registered"

### Requirement Validation: REQ-002 (User Login)

#### Test Case: ATP-002-A (Valid Login)
**Description:** Verify successful authentication with valid credentials.

* **User Scenario: SCN-002-A1**
  * **Given** a registered user exists
  * **When** the user enters valid email and password
  * **Then** a session token is issued and the user is redirected to the dashboard

#### Test Case: ATP-002-B (Invalid Login)
**Description:** Verify invalid credentials are rejected.

* **User Scenario: SCN-002-B1**
  * **Given** a registered user exists
  * **When** the user enters an incorrect password
  * **Then** the system displays "Invalid email or password"

### Requirement Validation: REQ-003 (Password Reset)

#### Test Case: ATP-003-A (Valid Reset Request)
**Description:** Verify password reset for registered email.

* **User Scenario: SCN-003-A1**
  * **Given** the user is on the forgot password page
  * **When** the user enters a registered email
  * **Then** a reset link email is dispatched

### Requirement Validation: REQ-004 (Profile Management)

#### Test Case: ATP-004-A (Update Display Name)
**Description:** Verify users can update their display name.

* **User Scenario: SCN-004-A1**
  * **Given** the user is logged in and on the profile page
  * **When** the user changes their display name and saves
  * **Then** the display name is updated successfully

### Requirement Validation: REQ-005 (Session Management)

#### Test Case: ATP-005-A (Session Timeout)
**Description:** Verify sessions expire after 30 minutes of inactivity.

* **User Scenario: SCN-005-A1**
  * **Given** a user is logged in
  * **When** 30 minutes pass without any activity
  * **Then** the session is invalidated and the user must re-authenticate

### Requirement Validation: REQ-006 (Audit Logging)

#### Test Case: ATP-006-A (Login Event Logged)
**Description:** Verify authentication events are logged.

* **User Scenario: SCN-006-A1**
  * **Given** the audit logging system is active
  * **When** a user attempts to log in (success or failure)
  * **Then** an audit record is created with timestamp, IP address, and result

### Requirement Validation: REQ-007 (Two-Factor Authentication)

#### Test Case: ATP-007-A (TOTP Setup)
**Description:** Verify users can enable TOTP-based 2FA.

* **User Scenario: SCN-007-A1**
  * **Given** the user is logged in and on the security settings page
  * **When** the user enables two-factor authentication
  * **Then** a QR code is displayed for TOTP app configuration

#### Test Case: ATP-007-B (TOTP Verification)
**Description:** Verify TOTP code is required after enabling 2FA.

* **User Scenario: SCN-007-B1**
  * **Given** a user has 2FA enabled
  * **When** the user logs in with valid email and password
  * **Then** the system prompts for a TOTP code before granting access

### Requirement Validation: REQ-008 (Account Deactivation)

#### Test Case: ATP-008-A (Self-Deactivation)
**Description:** Verify users can deactivate their own accounts.

* **User Scenario: SCN-008-A1**
  * **Given** the user is logged in and on the account settings page
  * **When** the user clicks "Deactivate Account" and confirms
  * **Then** the account is deactivated and the user is logged out

### Requirement Validation: REQ-NF-001 (Response Time)

#### Test Case: ATP-NF-001-A (API Response Time)
**Description:** Verify all API endpoints respond within 2 seconds.

* **User Scenario: SCN-NF-001-A1**
  * **Given** the system is under normal load (100 concurrent users)
  * **When** any API endpoint is called
  * **Then** the response is received within 2 seconds

### Requirement Validation: REQ-NF-002 (Availability)

#### Test Case: ATP-NF-002-A (Monthly Uptime)
**Description:** Verify 99.9% monthly uptime.

* **User Scenario: SCN-NF-002-A1**
  * **Given** the system is in production
  * **When** uptime is measured over a calendar month
  * **Then** the availability is at least 99.9%

### Requirement Validation: REQ-NF-003 (Data Encryption)

#### Test Case: ATP-NF-003-A (At-Rest Encryption)
**Description:** Verify data at rest is encrypted with AES-256.

* **User Scenario: SCN-NF-003-A1**
  * **Given** data is stored in the database
  * **When** the raw storage is inspected
  * **Then** the data is encrypted using AES-256

### Requirement Validation: REQ-NF-004 (Scalability)

#### Test Case: ATP-NF-004-A (Concurrent User Load)
**Description:** Verify system supports 10,000 concurrent users.

* **User Scenario: SCN-NF-004-A1**
  * **Given** the system is deployed in production configuration
  * **When** 10,000 users are concurrently active
  * **Then** response times remain within acceptable thresholds

### Requirement Validation: REQ-IF-001 (REST API)

#### Test Case: ATP-IF-001-A (OpenAPI Conformance)
**Description:** Verify the API conforms to OpenAPI 3.0.

* **User Scenario: SCN-IF-001-A1**
  * **Given** the API specification is exported
  * **When** validated against the OpenAPI 3.0 schema
  * **Then** the specification passes validation

### Requirement Validation: REQ-IF-002 (OAuth2 Provider)

#### Test Case: ATP-IF-002-A (Authorization Code Flow)
**Description:** Verify OAuth2 authorization code flow works.

* **User Scenario: SCN-IF-002-A1**
  * **Given** a registered OAuth2 client application
  * **When** the client initiates the authorization code flow
  * **Then** an authorization code is issued and can be exchanged for tokens

### Requirement Validation: REQ-CN-001 (Technology Stack)

#### Test Case: ATP-CN-001-A (Python Version)
**Description:** Verify the system runs on Python 3.11+.

* **User Scenario: SCN-CN-001-A1**
  * **Given** the system is deployed
  * **When** the Python runtime version is checked
  * **Then** the version is 3.11 or higher

### Requirement Validation: REQ-CN-002 (GDPR Compliance)

#### Test Case: ATP-CN-002-A (Data Residency)
**Description:** Verify EU user data stays in EU data centers.

* **User Scenario: SCN-CN-002-A1**
  * **Given** a user registers from an EU country
  * **When** their data is stored
  * **Then** the data resides in an EU data center

## Orphaned Test Cases (Intentional — for testing orphan detection)

### Test Case: ATP-999-A (Orphaned Test)
**Description:** This test case has no matching requirement. It should be detected as an orphan.

* **User Scenario: SCN-999-A1**
  * **Given** this is an orphaned test case
  * **When** the traceability matrix is built
  * **Then** this ATP is flagged as having no parent REQ

## Coverage Summary

| Requirement | Test Cases | Scenarios | Status |
|-------------|-----------|-----------|--------|
| REQ-001 | 2 | 2 | ⬜ Untested |
| REQ-002 | 2 | 2 | ⬜ Untested |
| REQ-003 | 1 | 1 | ⬜ Untested |
| REQ-004 | 1 | 1 | ⬜ Untested |
| REQ-005 | 1 | 1 | ⬜ Untested |
| REQ-006 | 1 | 1 | ⬜ Untested |
| REQ-007 | 2 | 2 | ⬜ Untested |
| REQ-008 | 1 | 1 | ⬜ Untested |
| REQ-NF-001 | 1 | 1 | ⬜ Untested |
| REQ-NF-002 | 1 | 1 | ⬜ Untested |
| REQ-NF-003 | 1 | 1 | ⬜ Untested |
| REQ-NF-004 | 1 | 1 | ⬜ Untested |
| REQ-IF-001 | 1 | 1 | ⬜ Untested |
| REQ-IF-002 | 1 | 1 | ⬜ Untested |
| REQ-CN-001 | 1 | 1 | ⬜ Untested |
| REQ-CN-002 | 1 | 1 | ⬜ Untested |

**Orphaned ATPs: ATP-999-A** (no matching requirement)

**Coverage: 100%** — All 16 requirements have test cases and scenarios.
