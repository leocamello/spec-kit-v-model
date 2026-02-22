# Unit Test Plan — Gaps Fixture

### Module: MOD-001 (Password Hasher)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `src/auth/hasher.py`

#### Test Case: UTP-001-A (Hash and Verify Round-Trip)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies that hashing a password and then verifying it covers both function paths.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-001-A1**
  * **Arrange**: Set `plain` to `"correcthorsebatterystaple"`
  * **Act**: Call `hash_password(plain)` then call `verify_password(plain, result)`
  * **Assert**: `verify_password` returns `True`

* **Unit Scenario: UTS-001-A2**
  * **Arrange**: Set `plain` to `"correcthorsebatterystaple"`; set `wrong` to `"incorrect"`
  * **Act**: Call `hash_password(plain)` then call `verify_password(wrong, result)`
  * **Assert**: `verify_password` returns `False`

---

### Module: MOD-099 (Orphan Module)

**Parent Architecture Modules**: ARCH-099
**Target Source File(s)**: `src/orphan.py`

#### Test Case: UTP-099-A (Orphan Uppercase Transform)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies the orphan module transforms input to uppercase.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-099-A1**
  * **Arrange**: Set `data` to `"hello"`
  * **Act**: Call `orphan_op(data)`
  * **Assert**: Returns `"HELLO"`

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Test Cases (UTP) | 2 |
| Total Scenarios (UTS) | 3 |
| Modules with Coverage | 1 |
| Modules without Coverage | 1 |
| **Forward Coverage (MOD→UTP)** | **50%** |
