# Unit Test Plan — Linear Fixture

### Module: MOD-001 (Data Converter)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `src/converter.py`

#### Test Case: UTP-001-A (Conversion Logic)
**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic / Logic View
**Description**: Verify convert function produces correct output.

* **Unit Scenario: UTS-001-A1**
  * **Arrange**: Prepare valid raw input bytes.
  * **Act**: Call `convert(raw)`.
  * **Assert**: Return value is correct ConvertedData.

---

### Module: MOD-002 (Audit Writer)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `src/logger.py`

#### Test Case: UTP-002-A (Write Entry)
**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic / Logic View
**Description**: Verify write_entry appends correctly.

* **Unit Scenario: UTS-002-A1**
  * **Arrange**: Create mock event.
  * **Act**: Call `write_entry(event)`.
  * **Assert**: Entry is appended to file.
