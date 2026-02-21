# Integration Test — Gaps Fixture

### Module Integration: ARCH-001 → ARCH-002 (Verifier to Session Manager)

#### Test Case: ITP-001-A (Identity Handoff Contract)
**Technique**: Interface Contract Testing

* **Integration Scenario: ITS-001-A1**
  * **Given** ARCH-001 verifies credentials and produces a VerifiedIdentity
  * **When** ARCH-002 receives the VerifiedIdentity
  * **Then** ARCH-002 creates a SessionToken with valid expiry

### Module Integration: ARCH-099 (Orphaned Component)

#### Test Case: ITP-099-A (Orphaned Integration Test)
**Technique**: Interface Fault Injection

* **Integration Scenario: ITS-099-A1**
  * **Given** an orphaned component exists
  * **When** a request is sent
  * **Then** it responds
