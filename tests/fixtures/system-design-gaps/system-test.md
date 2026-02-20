# System Test — Gaps Fixture

### Component Verification: SYS-001 (Auth Service)

#### Test Case: STP-001-A (User Authentication)

**Technique**: Interface Contract Testing

* **System Scenario: STS-001-A1**
  * **Given** the Auth Service receives valid credentials
  * **When** the authentication routine executes
  * **Then** the service returns a valid session token

### Component Verification: SYS-099 (Orphaned Component)

#### Test Case: STP-099-A (Orphaned Test)

**Technique**: Fault Injection

* **System Scenario: STS-099-A1**
  * **Given** the orphaned component is running
  * **When** a request is sent
  * **Then** it responds
