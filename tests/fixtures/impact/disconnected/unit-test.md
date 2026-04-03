# Unit Test Plan — Disconnected Fixture

### Module: MOD-001 (AES Encryptor)

**Parent Architecture Modules**: ARCH-001

#### Test Case: UTP-001-A (Encrypt Round-Trip)
**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic / Logic View

* **Unit Scenario: UTS-001-A1**
  * **Arrange**: Generate 32-byte key and plaintext.
  * **Act**: Call `encrypt(plaintext, key)`.
  * **Assert**: Output is non-empty ciphertext, different from plaintext.

---

### Module: MOD-002 (Report Builder)

**Parent Architecture Modules**: ARCH-002

#### Test Case: UTP-002-A (Report Build)
**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic / Logic View

* **Unit Scenario: UTS-002-A1**
  * **Arrange**: Prepare report data and template path.
  * **Act**: Call `build_report(data, template)`.
  * **Assert**: Non-empty PDF bytes returned.
