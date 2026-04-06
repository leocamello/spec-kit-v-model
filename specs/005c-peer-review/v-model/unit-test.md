# Unit Test Plan: Peer Review

**Feature Branch**: `feature/005c-peer-review`
**Created**: 2025-07-18
**Status**: Approved
**Source**: `specs/005c-peer-review/v-model/module-design.md`

## Overview

This document defines the Unit Test Plan for the Peer Review feature. Every module design (`MOD-NNN`) in `module-design.md` has one or more Unit Test Cases (`UTP-NNN-X`), and every Test Case has one or more executable Unit Scenarios (`UTS-NNN-X#`) in white-box Arrange/Act/Assert format.

Unit tests verify **internal module logic** — control flow, data transformations, state transitions, and variable boundaries. They do NOT test module boundaries (integration), user journeys (acceptance), or system-level behavior (system tests).

## ID Schema

- **Unit Test Case**: `UTP-{NNN}-{X}` — where NNN matches the parent MOD, X is a letter suffix (A, B, C...)
- **Unit Test Scenario**: `UTS-{NNN}-{X}{#}` — nested under the parent UTP, with numeric suffix (1, 2, 3...)
- Example: `UTS-001-A1` → Scenario 1 of Test Case A verifying MOD-001
- ID lineage: from `UTS-001-A1`, a regex extracts `UTP-001-A` and `MOD-001`. To find the `ARCH-NNN` ancestor, consult the "Parent Architecture Modules" field in `module-design.md`.

## ISO 29119-4 White-Box Techniques

Each test case MUST identify its technique by name and anchor to a specific module design view:

| Technique | Source View | What It Tests |
|-----------|------------|---------------|
| **Statement & Branch Coverage** | Algorithmic/Logic View | Every line and every True/False branch outcome |
| **Boundary Value Analysis** | Internal Data Structures | Scalar variable boundaries: min-1, min, mid, max, max+1 |
| **Equivalence Partitioning** | Internal Data Structures | Discrete non-scalar types: Booleans, Enums |
| **Strict Isolation** | Architecture Interface View | Every external dependency mocked/stubbed |

## Unit Tests

### Module: MOD-001 (read_artifact_file)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `commands/peer-review.md`

#### Test Case: UTP-001-A (Control flow through path validation, file existence, and content checks)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises every branch in `read_artifact_file` — null/empty path, file-not-found, empty-file, and success path.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists() | ARCH-001 interface | Stub: returns configurable boolean | Isolate from real filesystem |
| read_file() | ARCH-001 interface | Stub: returns configurable string | Isolate from real filesystem |

* **Unit Scenario: UTS-001-A1** (null path — true branch step 1)
  * **Arrange**: Set `artifact_path = NULL`
  * **Act**: Call `read_artifact_file(artifact_path)`
  * **Assert**: Raises `FileNotFoundError` with message containing "No artifact path specified"

* **Unit Scenario: UTS-001-A2** (empty path — true branch step 1)
  * **Arrange**: Set `artifact_path = ""`
  * **Act**: Call `read_artifact_file(artifact_path)`
  * **Assert**: Raises `FileNotFoundError` with message containing "No artifact path specified"

* **Unit Scenario: UTS-001-A3** (file does not exist — true branch step 2)
  * **Arrange**: Set `artifact_path = "/nonexistent/path.md"`; stub `file_exists` to return `false`
  * **Act**: Call `read_artifact_file(artifact_path)`
  * **Assert**: Raises `FileNotFoundError` with message containing "Artifact file not found: /nonexistent/path.md"

* **Unit Scenario: UTS-001-A4** (empty file content — true branch step 4)
  * **Arrange**: Set `artifact_path = "/valid/path.md"`; stub `file_exists` to return `true`; stub `read_file` to return `""`
  * **Act**: Call `read_artifact_file(artifact_path)`
  * **Assert**: Raises `EmptyFileError` with message containing "Artifact file is empty"

* **Unit Scenario: UTS-001-A5** (valid file — false branches, success path)
  * **Arrange**: Set `artifact_path = "/valid/requirements.md"`; stub `file_exists` to return `true`; stub `read_file` to return `"# Requirements\n\nREQ-001 ..."`
  * **Act**: Call `read_artifact_file(artifact_path)`
  * **Assert**: Returns `"# Requirements\n\nREQ-001 ..."`; no exception raised

#### Test Case: UTP-001-B (Boundary values for artifact_path length and content length)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests `artifact_path` (max 4096 chars) and `content` length at their boundaries.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists() | ARCH-001 interface | Stub: returns `true` | Bypass filesystem for boundary tests |
| read_file() | ARCH-001 interface | Stub: returns configurable content | Control content length precisely |

* **Unit Scenario: UTS-001-B1** (min-1: path length 0)
  * **Arrange**: Set `artifact_path = ""` (length 0, below minimum of 1)
  * **Act**: Call `read_artifact_file(artifact_path)`
  * **Assert**: Raises `FileNotFoundError`; path rejected as empty

* **Unit Scenario: UTS-001-B2** (min: path length 1)
  * **Arrange**: Set `artifact_path = "a"` (length 1); stub `file_exists` returns `true`; stub `read_file` returns `"content"`
  * **Act**: Call `read_artifact_file(artifact_path)`
  * **Assert**: Returns `"content"`; single-char path accepted

* **Unit Scenario: UTS-001-B3** (mid: typical path length)
  * **Arrange**: Set `artifact_path = "/specs/005c-peer-review/v-model/requirements.md"` (49 chars); stub `file_exists` returns `true`; stub `read_file` returns `"# Requirements"`
  * **Act**: Call `read_artifact_file(artifact_path)`
  * **Assert**: Returns `"# Requirements"`

* **Unit Scenario: UTS-001-B4** (max: path length 4096)
  * **Arrange**: Set `artifact_path` to a 4096-character string; stub `file_exists` returns `true`; stub `read_file` returns `"data"`
  * **Act**: Call `read_artifact_file(artifact_path)`
  * **Assert**: Returns `"data"`; max-length path accepted

* **Unit Scenario: UTS-001-B5** (max+1: path length 4097)
  * **Arrange**: Set `artifact_path` to a 4097-character string
  * **Act**: Call `read_artifact_file(artifact_path)`
  * **Assert**: Raises OS-level path error or `FileNotFoundError`; path exceeding OS limit rejected

#### Test Case: UTP-001-C (Filesystem dependencies fully isolated)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies that `read_artifact_file` never touches the real filesystem; all I/O goes through stubbed `file_exists` and `read_file`.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists() | ARCH-001 interface | Spy: records call arguments | Verify correct path passed to filesystem check |
| read_file() | ARCH-001 interface | Spy: records call arguments, returns stub data | Verify file read invoked exactly once with correct path |

* **Unit Scenario: UTS-001-C1** (verify file_exists called with exact path)
  * **Arrange**: Set `artifact_path = "/v-model/requirements.md"`; configure `file_exists` spy returning `true`; configure `read_file` spy returning `"content"`
  * **Act**: Call `read_artifact_file(artifact_path)`
  * **Assert**: `file_exists` spy called exactly once with argument `"/v-model/requirements.md"`; `read_file` spy called exactly once with same path

* **Unit Scenario: UTS-001-C2** (verify read_file not called when file_exists returns false)
  * **Arrange**: Set `artifact_path = "/missing.md"`; configure `file_exists` spy returning `false`
  * **Act**: Call `read_artifact_file(artifact_path)` (expect exception)
  * **Assert**: `file_exists` spy called once; `read_file` spy never called; `FileNotFoundError` raised

---

### Module: MOD-002 (resolve_artifact_type)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `commands/peer-review.md`

#### Test Case: UTP-002-A (Branch coverage for type lookup and ID pattern matching)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises the supported-type lookup hit/miss and the ID counting loop with various match counts.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-002-A1** (unsupported file name — true branch step 3)
  * **Arrange**: Set `file_name = "changelog.md"`; set `file_content = "some text"`
  * **Act**: Call `resolve_artifact_type(file_name, file_content)`
  * **Assert**: Raises `UnsupportedArtifactTypeError` with message containing "Unsupported artifact type: changelog.md"

* **Unit Scenario: UTS-002-A2** (valid type with matching IDs — false branch, loop iterations)
  * **Arrange**: Set `file_name = "requirements.md"`; set `file_content = "REQ-001 first\nREQ-002 second\nREQ-001 duplicate"`
  * **Act**: Call `resolve_artifact_type(file_name, file_content)`
  * **Assert**: Returns `ArtifactMetadata` with `artifactType = "requirements"`, `abbreviation = "REQ"`, `governingStandard = "INCOSE"`, `itemCount = 2` (deduplicated), `fileName = "requirements.md"`

* **Unit Scenario: UTS-002-A3** (valid type with zero IDs — loop zero iterations)
  * **Arrange**: Set `file_name = "system-design.md"`; set `file_content = "No IDs here"`
  * **Act**: Call `resolve_artifact_type(file_name, file_content)`
  * **Assert**: Returns `ArtifactMetadata` with `itemCount = 0`

* **Unit Scenario: UTS-002-A4** (file name with directory prefix — extract_basename)
  * **Arrange**: Set `file_name = "/path/to/architecture-design.md"`; set `file_content = "ARCH-001 module"`
  * **Act**: Call `resolve_artifact_type(file_name, file_content)`
  * **Assert**: Returns `ArtifactMetadata` with `artifactType = "architecture-design"`, `abbreviation = "ARCH"`, `itemCount = 1`

#### Test Case: UTP-002-B (Equivalence partitions for all 9 supported artifact types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Verifies that each of the 9 entries in `SUPPORTED_TYPES` correctly maps to its type, abbreviation, and governing standard.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-002-B1** (partition: requirements.md)
  * **Arrange**: Set `file_name = "requirements.md"`; set `file_content = "REQ-001"`
  * **Act**: Call `resolve_artifact_type(file_name, file_content)`
  * **Assert**: `artifactType = "requirements"`, `abbreviation = "REQ"`, `governingStandard = "INCOSE"`

* **Unit Scenario: UTS-002-B2** (partition: system-design.md)
  * **Arrange**: Set `file_name = "system-design.md"`; set `file_content = "SYS-001"`
  * **Act**: Call `resolve_artifact_type(file_name, file_content)`
  * **Assert**: `artifactType = "system-design"`, `abbreviation = "SYS"`, `governingStandard = "IEEE 1016"`

* **Unit Scenario: UTS-002-B3** (partition: architecture-design.md)
  * **Arrange**: Set `file_name = "architecture-design.md"`; set `file_content = "ARCH-001"`
  * **Act**: Call `resolve_artifact_type(file_name, file_content)`
  * **Assert**: `artifactType = "architecture-design"`, `abbreviation = "ARCH"`, `governingStandard = "IEEE 42010"`

* **Unit Scenario: UTS-002-B4** (partition: system-test.md)
  * **Arrange**: Set `file_name = "system-test.md"`; set `file_content = "STS-001"`
  * **Act**: Call `resolve_artifact_type(file_name, file_content)`
  * **Assert**: `artifactType = "system-test"`, `abbreviation = "STP"`, `governingStandard = "ISO 29119"`

* **Unit Scenario: UTS-002-B5** (partition: integration-test.md)
  * **Arrange**: Set `file_name = "integration-test.md"`; set `file_content = "ITS-001"`
  * **Act**: Call `resolve_artifact_type(file_name, file_content)`
  * **Assert**: `artifactType = "integration-test"`, `abbreviation = "ITP"`, `governingStandard = "ISO 29119-4"`

* **Unit Scenario: UTS-002-B6** (partition: module-design.md)
  * **Arrange**: Set `file_name = "module-design.md"`; set `file_content = "MOD-001"`
  * **Act**: Call `resolve_artifact_type(file_name, file_content)`
  * **Assert**: `artifactType = "module-design"`, `abbreviation = "MOD"`, `governingStandard = "DO-178C / ISO 26262"`

* **Unit Scenario: UTS-002-B7** (partition: unit-test.md)
  * **Arrange**: Set `file_name = "unit-test.md"`; set `file_content = "UTS-001"`
  * **Act**: Call `resolve_artifact_type(file_name, file_content)`
  * **Assert**: `artifactType = "unit-test"`, `abbreviation = "UTP"`, `governingStandard = "ISO 29119-4"`

* **Unit Scenario: UTS-002-B8** (partition: hazard-analysis.md)
  * **Arrange**: Set `file_name = "hazard-analysis.md"`; set `file_content = "HAZ-001"`
  * **Act**: Call `resolve_artifact_type(file_name, file_content)`
  * **Assert**: `artifactType = "hazard-analysis"`, `abbreviation = "HAZ"`, `governingStandard = "ISO 14971 / ISO 26262"`

* **Unit Scenario: UTS-002-B9** (partition: acceptance-plan.md)
  * **Arrange**: Set `file_name = "acceptance-plan.md"`; set `file_content = "ATP-001"`
  * **Act**: Call `resolve_artifact_type(file_name, file_content)`
  * **Assert**: `artifactType = "acceptance-plan"`, `abbreviation = "ATP"`, `governingStandard = "ISO 29119"`

* **Unit Scenario: UTS-002-B10** (invalid partition: unsupported type)
  * **Arrange**: Set `file_name = "release-notes.md"`; set `file_content = "anything"`
  * **Act**: Call `resolve_artifact_type(file_name, file_content)`
  * **Assert**: Raises `UnsupportedArtifactTypeError`

#### Test Case: UTP-002-C (Boundary values for item_count derived from unique_ids set)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests `item_count` (0–999) and `unique_ids` set size at scalar boundaries.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-002-C1** (min-1 not applicable; min: 0 unique IDs)
  * **Arrange**: Set `file_name = "requirements.md"`; set `file_content = "No ID patterns present"`
  * **Act**: Call `resolve_artifact_type(file_name, file_content)`
  * **Assert**: `itemCount = 0`

* **Unit Scenario: UTS-002-C2** (min: 1 unique ID)
  * **Arrange**: Set `file_name = "requirements.md"`; set `file_content = "REQ-001 is the only requirement"`
  * **Act**: Call `resolve_artifact_type(file_name, file_content)`
  * **Assert**: `itemCount = 1`

* **Unit Scenario: UTS-002-C3** (mid: typical count)
  * **Arrange**: Set `file_name = "requirements.md"`; set `file_content` containing `REQ-001` through `REQ-050` (50 unique IDs)
  * **Act**: Call `resolve_artifact_type(file_name, file_content)`
  * **Assert**: `itemCount = 50`

* **Unit Scenario: UTS-002-C4** (deduplication: repeated IDs)
  * **Arrange**: Set `file_name = "requirements.md"`; set `file_content = "REQ-001 first mention\nREQ-001 second mention\nREQ-002"`
  * **Act**: Call `resolve_artifact_type(file_name, file_content)`
  * **Assert**: `itemCount = 2` (REQ-001 counted once)

---

### Module: MOD-003 (get_review_criteria)

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `commands/peer-review.md`

#### Test Case: UTP-003-A (Branch coverage for registry lookup hit and miss)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises the `IF artifact_type NOT IN CRITERIA_REGISTRY` branch for both true and false outcomes.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-003-A1** (known type — false branch, returns criteria)
  * **Arrange**: Set `artifact_type = "requirements"`
  * **Act**: Call `get_review_criteria(artifact_type)`
  * **Assert**: Returns `CriteriaSet` with `standard = "INCOSE"`, `dimensions` array length = 6, `rules` array length = 5

* **Unit Scenario: UTS-003-A2** (unknown type — true branch, raises error)
  * **Arrange**: Set `artifact_type = "release-notes"`
  * **Act**: Call `get_review_criteria(artifact_type)`
  * **Assert**: Raises `UnknownArtifactTypeError` with message containing "No criteria registered for type: release-notes"

#### Test Case: UTP-003-B (Equivalence partitions for all 9 registered artifact types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Verifies that each of the 9 entries in `CRITERIA_REGISTRY` returns a valid `CriteriaSet` with correct standard, non-empty dimensions, and non-empty rules.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-003-B1** (partition: requirements)
  * **Arrange**: Set `artifact_type = "requirements"`
  * **Act**: Call `get_review_criteria(artifact_type)`
  * **Assert**: `standard = "INCOSE"`; `dimensions` contains "atomic", "testable"; `rules` length = 5

* **Unit Scenario: UTS-003-B2** (partition: system-design)
  * **Arrange**: Set `artifact_type = "system-design"`
  * **Act**: Call `get_review_criteria(artifact_type)`
  * **Assert**: `standard = "IEEE 1016"`; `dimensions` contains "4 design views present"; `rules` length = 5

* **Unit Scenario: UTS-003-B3** (partition: architecture-design)
  * **Arrange**: Set `artifact_type = "architecture-design"`
  * **Act**: Call `get_review_criteria(artifact_type)`
  * **Assert**: `standard = "IEEE 42010"`; `dimensions` contains "4+1 views populated"; `rules` length = 5

* **Unit Scenario: UTS-003-B4** (partition: system-test)
  * **Arrange**: Set `artifact_type = "system-test"`
  * **Act**: Call `get_review_criteria(artifact_type)`
  * **Assert**: `standard = "ISO 29119"`; `dimensions` contains "named techniques correct"; `rules` length = 5

* **Unit Scenario: UTS-003-B5** (partition: integration-test)
  * **Arrange**: Set `artifact_type = "integration-test"`
  * **Act**: Call `get_review_criteria(artifact_type)`
  * **Assert**: `standard = "ISO 29119-4"`; `dimensions` contains "CDCT technique present"; `rules` length = 5

* **Unit Scenario: UTS-003-B6** (partition: module-design)
  * **Arrange**: Set `artifact_type = "module-design"`
  * **Act**: Call `get_review_criteria(artifact_type)`
  * **Assert**: `standard = "DO-178C / ISO 26262"`; `dimensions` contains "4 mandatory views present"; `rules` length = 5

* **Unit Scenario: UTS-003-B7** (partition: unit-test)
  * **Arrange**: Set `artifact_type = "unit-test"`
  * **Act**: Call `get_review_criteria(artifact_type)`
  * **Assert**: `standard = "ISO 29119-4"`; `dimensions` contains "5 techniques present"; `rules` length = 5

* **Unit Scenario: UTS-003-B8** (partition: hazard-analysis)
  * **Arrange**: Set `artifact_type = "hazard-analysis"`
  * **Act**: Call `get_review_criteria(artifact_type)`
  * **Assert**: `standard = "ISO 14971 / ISO 26262"`; `dimensions` contains "severity classifications present"; `rules` length = 5

* **Unit Scenario: UTS-003-B9** (partition: acceptance-plan)
  * **Arrange**: Set `artifact_type = "acceptance-plan"`
  * **Act**: Call `get_review_criteria(artifact_type)`
  * **Assert**: `standard = "ISO 29119"`; `dimensions` contains "BDD scenarios well-formed"; `rules` length = 5

* **Unit Scenario: UTS-003-B10** (invalid partition: empty string)
  * **Arrange**: Set `artifact_type = ""`
  * **Act**: Call `get_review_criteria(artifact_type)`
  * **Assert**: Raises `UnknownArtifactTypeError`

#### Test Case: UTP-003-C (Boundary values for artifact_type string input)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests the `artifact_type` string parameter at boundary lengths to verify lookup behavior with edge-case inputs.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-003-C1** (min-1: null input)
  * **Arrange**: Set `artifact_type = NULL`
  * **Act**: Call `get_review_criteria(artifact_type)`
  * **Assert**: Raises `UnknownArtifactTypeError` or equivalent null-handling error

* **Unit Scenario: UTS-003-C2** (min: shortest valid key — "unit-test", 9 chars)
  * **Arrange**: Set `artifact_type = "unit-test"`
  * **Act**: Call `get_review_criteria(artifact_type)`
  * **Assert**: Returns `CriteriaSet` with `standard = "ISO 29119-4"`

* **Unit Scenario: UTS-003-C3** (max: longest valid key — "architecture-design", 19 chars)
  * **Arrange**: Set `artifact_type = "architecture-design"`
  * **Act**: Call `get_review_criteria(artifact_type)`
  * **Assert**: Returns `CriteriaSet` with `standard = "IEEE 42010"`

* **Unit Scenario: UTS-003-C4** (max+1: key longer than any valid entry)
  * **Arrange**: Set `artifact_type = "architecture-design-extended"`
  * **Act**: Call `get_review_criteria(artifact_type)`
  * **Assert**: Raises `UnknownArtifactTypeError`

---

### Module: MOD-004 (evaluate_artifact)

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `commands/peer-review.md`

#### Test Case: UTP-004-A (Branch coverage for LLM response validation and finding field checks)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises every branch in `evaluate_artifact` — null LLM response, missing location/description/recommendation fields, valid parse, and empty findings.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| invoke_llm() | ARCH-004 LLM interface | Mock: returns configurable response | Never call real LLM in unit test |
| parse_structured_output() | ARCH-004 internal parser | Mock: returns configurable items | Control parsed output structure |

* **Unit Scenario: UTS-004-A1** (null LLM response — true branch step 3)
  * **Arrange**: Set `artifact_content = "REQ-001 ..."`, `criteria_set = valid CriteriaSet`, `artifact_type = "requirements"`; mock `invoke_llm` to return `NULL`
  * **Act**: Call `evaluate_artifact(artifact_content, criteria_set, artifact_type)`
  * **Assert**: Raises `LLMEvaluationError` with message "LLM returned empty response"

* **Unit Scenario: UTS-004-A2** (empty LLM response — true branch step 3)
  * **Arrange**: Same as UTS-004-A1; mock `invoke_llm` to return `""`
  * **Act**: Call `evaluate_artifact(artifact_content, criteria_set, artifact_type)`
  * **Assert**: Raises `LLMEvaluationError` with message "LLM returned empty response"

* **Unit Scenario: UTS-004-A3** (finding missing location field — true branch step 4 loop)
  * **Arrange**: Mock `invoke_llm` returns valid text; mock `parse_structured_output` returns `[{location: NULL, description: "issue", recommendation: "fix"}]`
  * **Act**: Call `evaluate_artifact(artifact_content, criteria_set, artifact_type)`
  * **Assert**: Raises `LLMEvaluationError` with message "Finding missing location field"

* **Unit Scenario: UTS-004-A4** (finding missing description field)
  * **Arrange**: Mock `parse_structured_output` returns `[{location: "REQ-001", description: NULL, recommendation: "fix"}]`
  * **Act**: Call `evaluate_artifact(artifact_content, criteria_set, artifact_type)`
  * **Assert**: Raises `LLMEvaluationError` with message "Finding missing description field"

* **Unit Scenario: UTS-004-A5** (finding missing recommendation field)
  * **Arrange**: Mock `parse_structured_output` returns `[{location: "REQ-001", description: "issue", recommendation: ""}]`
  * **Act**: Call `evaluate_artifact(artifact_content, criteria_set, artifact_type)`
  * **Assert**: Raises `LLMEvaluationError` with message "Finding missing recommendation field"

* **Unit Scenario: UTS-004-A6** (valid findings — all false branches, loop N iterations)
  * **Arrange**: Mock `invoke_llm` returns structured text; mock `parse_structured_output` returns 2 complete items
  * **Act**: Call `evaluate_artifact(artifact_content, criteria_set, artifact_type)`
  * **Assert**: Returns array of 2 `RawFinding` objects; first has `location = "REQ-001"`, `description = "ambiguous"`, `recommendation = "add metric"`

* **Unit Scenario: UTS-004-A7** (zero findings — loop zero iterations)
  * **Arrange**: Mock `parse_structured_output` returns empty array `[]`
  * **Act**: Call `evaluate_artifact(artifact_content, criteria_set, artifact_type)`
  * **Assert**: Returns empty array `[]`; no error raised

#### Test Case: UTP-004-B (Boundary values for raw_findings array size)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests `raw_findings` count (0–999) at scalar boundaries.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| invoke_llm() | ARCH-004 LLM interface | Mock: returns configurable response | Isolate from LLM |
| parse_structured_output() | ARCH-004 internal parser | Mock: returns configurable item list | Control array size precisely |

* **Unit Scenario: UTS-004-B1** (min: 0 findings)
  * **Arrange**: Mock `parse_structured_output` returns `[]`
  * **Act**: Call `evaluate_artifact(content, criteria, type)`
  * **Assert**: Returns empty array; `length(raw_findings) == 0`

* **Unit Scenario: UTS-004-B2** (min+1: 1 finding)
  * **Arrange**: Mock `parse_structured_output` returns array with 1 complete item
  * **Act**: Call `evaluate_artifact(content, criteria, type)`
  * **Assert**: Returns array of length 1; single `RawFinding` has all 3 fields populated

* **Unit Scenario: UTS-004-B3** (mid: 50 findings)
  * **Arrange**: Mock `parse_structured_output` returns array of 50 complete items
  * **Act**: Call `evaluate_artifact(content, criteria, type)`
  * **Assert**: Returns array of length 50; all 50 `RawFinding` objects valid

* **Unit Scenario: UTS-004-B4** (max: 999 findings)
  * **Arrange**: Mock `parse_structured_output` returns array of 999 complete items
  * **Act**: Call `evaluate_artifact(content, criteria, type)`
  * **Assert**: Returns array of length 999; all fields populated

#### Test Case: UTP-004-C (LLM dependency fully isolated)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies that `evaluate_artifact` never makes real LLM calls and that `build_evaluation_prompt` correctly constructs the prompt from criteria and content.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| invoke_llm() | ARCH-004 LLM interface | Spy: records prompt argument, returns canned response | Verify prompt construction and LLM isolation |

* **Unit Scenario: UTS-004-C1** (verify prompt includes criteria dimensions and rules)
  * **Arrange**: Set `criteria_set = {standard: "INCOSE", dimensions: ["atomic", "testable"], rules: ["Each REQ must be atomic"]}`, `artifact_type = "requirements"`, `content = "REQ-001"`; configure `invoke_llm` spy returning valid findings
  * **Act**: Call `evaluate_artifact(content, criteria_set, artifact_type)`
  * **Assert**: `invoke_llm` spy captured prompt containing "INCOSE", "atomic", "testable", "Each REQ must be atomic", and "REQ-001"

* **Unit Scenario: UTS-004-C2** (verify invoke_llm called exactly once)
  * **Arrange**: Configure `invoke_llm` spy returning `[]`
  * **Act**: Call `evaluate_artifact(content, criteria_set, artifact_type)`
  * **Assert**: `invoke_llm` spy called exactly 1 time; no other external calls made

---

### Module: MOD-005 (assign_prf_ids)

**Parent Architecture Modules**: ARCH-005
**Target Source File(s)**: `commands/peer-review.md`

#### Test Case: UTP-005-A (Branch coverage for abbreviation validation and sequential ID assignment)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises invalid abbreviation branch, empty findings loop, and multi-finding loop with counter incrementing.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-005-A1** (invalid abbreviation — true branch step 1)
  * **Arrange**: Set `raw_findings = []`; set `abbreviation = "INVALID"`
  * **Act**: Call `assign_prf_ids(raw_findings, abbreviation)`
  * **Assert**: Raises `InvalidAbbreviationError` with message containing "Invalid abbreviation: INVALID"

* **Unit Scenario: UTS-005-A2** (empty findings — loop zero iterations)
  * **Arrange**: Set `raw_findings = []`; set `abbreviation = "REQ"`
  * **Act**: Call `assign_prf_ids(raw_findings, abbreviation)`
  * **Assert**: Returns empty array `[]`; `counter` never incremented

* **Unit Scenario: UTS-005-A3** (single finding — loop one iteration)
  * **Arrange**: Set `raw_findings = [{location: "REQ-001", description: "ambiguous", recommendation: "clarify"}]`; set `abbreviation = "REQ"`
  * **Act**: Call `assign_prf_ids(raw_findings, abbreviation)`
  * **Assert**: Returns `[{prfId: "PRF-REQ-001", location: "REQ-001", description: "ambiguous", recommendation: "clarify"}]`

* **Unit Scenario: UTS-005-A4** (multiple findings — loop N iterations, counter increments)
  * **Arrange**: Set `raw_findings` with 3 findings; set `abbreviation = "SYS"`
  * **Act**: Call `assign_prf_ids(raw_findings, abbreviation)`
  * **Assert**: Returns 3 `IdentifiedFinding` objects with `prfId` values `"PRF-SYS-001"`, `"PRF-SYS-002"`, `"PRF-SYS-003"` in order

#### Test Case: UTP-005-B (Equivalence partitions for all 9 valid abbreviations)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Verifies each member of `VALID_ABBREVIATIONS` is accepted and generates the correct PRF ID prefix.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-005-B1** (partition: REQ)
  * **Arrange**: Set `raw_findings` with 1 finding; set `abbreviation = "REQ"`
  * **Act**: Call `assign_prf_ids(raw_findings, abbreviation)`
  * **Assert**: First finding `prfId = "PRF-REQ-001"`

* **Unit Scenario: UTS-005-B2** (partition: ARCH)
  * **Arrange**: Set `raw_findings` with 1 finding; set `abbreviation = "ARCH"`
  * **Act**: Call `assign_prf_ids(raw_findings, abbreviation)`
  * **Assert**: First finding `prfId = "PRF-ARCH-001"`

* **Unit Scenario: UTS-005-B3** (partition: HAZ)
  * **Arrange**: Set `raw_findings` with 1 finding; set `abbreviation = "HAZ"`
  * **Act**: Call `assign_prf_ids(raw_findings, abbreviation)`
  * **Assert**: First finding `prfId = "PRF-HAZ-001"`

* **Unit Scenario: UTS-005-B4** (invalid partition: abbreviation not in set)
  * **Arrange**: Set `abbreviation = "XYZ"`
  * **Act**: Call `assign_prf_ids([], abbreviation)`
  * **Assert**: Raises `InvalidAbbreviationError`

#### Test Case: UTP-005-C (Boundary values for counter and findings count)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests `counter` (1–999) and `prf_id` zero-padding at boundary values.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-005-C1** (min: counter = 1, single finding)
  * **Arrange**: Set `raw_findings` with 1 finding; set `abbreviation = "REQ"`
  * **Act**: Call `assign_prf_ids(raw_findings, abbreviation)`
  * **Assert**: `prfId = "PRF-REQ-001"`; zero-padded to 3 digits

* **Unit Scenario: UTS-005-C2** (mid: counter reaches 50)
  * **Arrange**: Set `raw_findings` with 50 findings; set `abbreviation = "REQ"`
  * **Act**: Call `assign_prf_ids(raw_findings, abbreviation)`
  * **Assert**: Last finding `prfId = "PRF-REQ-050"`

* **Unit Scenario: UTS-005-C3** (max: counter = 999)
  * **Arrange**: Set `raw_findings` with 999 findings; set `abbreviation = "REQ"`
  * **Act**: Call `assign_prf_ids(raw_findings, abbreviation)`
  * **Assert**: Last finding `prfId = "PRF-REQ-999"`; 3-digit padding maintained

* **Unit Scenario: UTS-005-C4** (padding verification: counter = 10)
  * **Arrange**: Set `raw_findings` with 10 findings; set `abbreviation = "SYS"`
  * **Act**: Call `assign_prf_ids(raw_findings, abbreviation)`
  * **Assert**: `prfId` values are `"PRF-SYS-001"` through `"PRF-SYS-010"`; all zero-padded to 3 digits

---

### Module: MOD-006 (classify_severity)

**Parent Architecture Modules**: ARCH-006
**Target Source File(s)**: `commands/peer-review.md`

#### Test Case: UTP-006-A (Branch coverage for severity determination and unclassifiable finding)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises the classification loop, the `severity IS NULL` error branch, and the valid classification success path.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| ai_classify() | ARCH-006 AI classification | Mock: returns configurable severity string | Never call real AI classifier in unit test |

* **Unit Scenario: UTS-006-A1** (valid classification — false branch, loop iteration)
  * **Arrange**: Set `identified_findings` with 1 finding `{prfId: "PRF-REQ-001", ...}`; mock `ai_classify` to return `"Major"`
  * **Act**: Call `classify_severity(identified_findings)`
  * **Assert**: Returns 1 `ClassifiedFinding` with `severity = "Major"`, `prfId = "PRF-REQ-001"`

* **Unit Scenario: UTS-006-A2** (unclassifiable finding — null severity, true branch)
  * **Arrange**: Set `identified_findings` with 1 finding; mock `ai_classify` to return `"Unknown"`
  * **Act**: Call `classify_severity(identified_findings)`
  * **Assert**: Raises `UnclassifiableFindingError` with message containing the finding's `prfId`

* **Unit Scenario: UTS-006-A3** (empty findings — loop zero iterations)
  * **Arrange**: Set `identified_findings = []`
  * **Act**: Call `classify_severity(identified_findings)`
  * **Assert**: Returns empty array `[]`; `ai_classify` never called

* **Unit Scenario: UTS-006-A4** (multiple findings — loop N iterations)
  * **Arrange**: Set `identified_findings` with 3 findings; mock `ai_classify` to return `"Critical"`, `"Minor"`, `"Observation"` sequentially
  * **Act**: Call `classify_severity(identified_findings)`
  * **Assert**: Returns 3 `ClassifiedFinding` objects with severities `"Critical"`, `"Minor"`, `"Observation"` in order

#### Test Case: UTP-006-B (Equivalence partitions for the 4 severity levels)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Verifies each valid severity value in the discrete set `{"Critical", "Major", "Minor", "Observation"}` and one invalid partition.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| ai_classify() | ARCH-006 AI classification | Mock: returns specific severity string | Control classification outcome per partition |

* **Unit Scenario: UTS-006-B1** (valid partition: Critical)
  * **Arrange**: Mock `ai_classify` returns `"Critical"`; set 1 finding
  * **Act**: Call `classify_severity(identified_findings)`
  * **Assert**: `classified_findings[0].severity = "Critical"`

* **Unit Scenario: UTS-006-B2** (valid partition: Major)
  * **Arrange**: Mock `ai_classify` returns `"Major"`
  * **Act**: Call `classify_severity(identified_findings)`
  * **Assert**: `classified_findings[0].severity = "Major"`

* **Unit Scenario: UTS-006-B3** (valid partition: Minor)
  * **Arrange**: Mock `ai_classify` returns `"Minor"`
  * **Act**: Call `classify_severity(identified_findings)`
  * **Assert**: `classified_findings[0].severity = "Minor"`

* **Unit Scenario: UTS-006-B4** (valid partition: Observation)
  * **Arrange**: Mock `ai_classify` returns `"Observation"`
  * **Act**: Call `classify_severity(identified_findings)`
  * **Assert**: `classified_findings[0].severity = "Observation"`

* **Unit Scenario: UTS-006-B5** (invalid partition: unrecognized severity)
  * **Arrange**: Mock `ai_classify` returns `"Warning"` (not in valid set)
  * **Act**: Call `classify_severity(identified_findings)`
  * **Assert**: `determine_severity` returns `NULL`; `UnclassifiableFindingError` raised

#### Test Case: UTP-006-C (AI classifier dependency fully isolated)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies `classify_severity` delegates to `ai_classify` without making real AI calls, and validates the call contract.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| ai_classify() | ARCH-006 AI classification | Spy: records description argument, returns canned severity | Verify description passed correctly to classifier |

* **Unit Scenario: UTS-006-C1** (verify ai_classify called once per finding with description)
  * **Arrange**: Set `identified_findings` with 2 findings having descriptions `"missing testability"` and `"formatting issue"`; configure `ai_classify` spy returning `"Major"` then `"Minor"`
  * **Act**: Call `classify_severity(identified_findings)`
  * **Assert**: `ai_classify` spy called twice; first call argument = `"missing testability"`; second = `"formatting issue"`

* **Unit Scenario: UTS-006-C2** (verify no AI call for empty findings)
  * **Arrange**: Set `identified_findings = []`; configure `ai_classify` spy
  * **Act**: Call `classify_severity(identified_findings)`
  * **Assert**: `ai_classify` spy call count = 0

---

### Module: MOD-007 (build_report_header)

**Parent Architecture Modules**: ARCH-007
**Target Source File(s)**: `commands/peer-review.md`

#### Test Case: UTP-007-A (Branch coverage for metadata validation and header construction)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises all three validation branches (null file name, negative item count, null standard) and the success path.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| now() / format_date() | System clock | Stub: returns fixed date `"2025-07-18"` | Deterministic date for assertions |

* **Unit Scenario: UTS-007-A1** (null artifact file name — true branch step 1)
  * **Arrange**: Set `artifact_file_name = NULL`, `item_count = 5`, `governing_standard = "INCOSE"`
  * **Act**: Call `build_report_header(artifact_file_name, item_count, governing_standard)`
  * **Assert**: Raises `MissingMetadataError` with message "Missing artifact file name"

* **Unit Scenario: UTS-007-A2** (empty artifact file name — true branch step 1)
  * **Arrange**: Set `artifact_file_name = ""`, `item_count = 5`, `governing_standard = "INCOSE"`
  * **Act**: Call `build_report_header(artifact_file_name, item_count, governing_standard)`
  * **Assert**: Raises `MissingMetadataError` with message "Missing artifact file name"

* **Unit Scenario: UTS-007-A3** (negative item count — true branch step 2)
  * **Arrange**: Set `artifact_file_name = "requirements.md"`, `item_count = -1`, `governing_standard = "INCOSE"`
  * **Act**: Call `build_report_header(artifact_file_name, item_count, governing_standard)`
  * **Assert**: Raises `MissingMetadataError` with message containing "Invalid item count: -1"

* **Unit Scenario: UTS-007-A4** (null governing standard — true branch step 3)
  * **Arrange**: Set `artifact_file_name = "requirements.md"`, `item_count = 5`, `governing_standard = NULL`
  * **Act**: Call `build_report_header(artifact_file_name, item_count, governing_standard)`
  * **Assert**: Raises `MissingMetadataError` with message "Missing governing standard"

* **Unit Scenario: UTS-007-A5** (all valid — false branches, success path)
  * **Arrange**: Set `artifact_file_name = "requirements.md"`, `item_count = 12`, `governing_standard = "INCOSE"`; stub `format_date` returns `"2025-07-18"`
  * **Act**: Call `build_report_header(artifact_file_name, item_count, governing_standard)`
  * **Assert**: Returns string containing `"# Peer Review: requirements"`, `"**Items Reviewed**: 12"`, `"**Governing Standard**: INCOSE"`, `"**Date**: 2025-07-18"`

#### Test Case: UTP-007-B (Boundary values for item_count)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests `item_count` (integer, valid range 0+) at scalar boundaries.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| now() / format_date() | System clock | Stub: returns fixed date | Deterministic assertions |

* **Unit Scenario: UTS-007-B1** (min-1: item_count = -1)
  * **Arrange**: Set `item_count = -1`, other params valid
  * **Act**: Call `build_report_header("requirements.md", -1, "INCOSE")`
  * **Assert**: Raises `MissingMetadataError`

* **Unit Scenario: UTS-007-B2** (min: item_count = 0)
  * **Arrange**: Set `item_count = 0`; stub date
  * **Act**: Call `build_report_header("requirements.md", 0, "INCOSE")`
  * **Assert**: Returns header containing `"**Items Reviewed**: 0"`

* **Unit Scenario: UTS-007-B3** (mid: item_count = 50)
  * **Arrange**: Set `item_count = 50`; stub date
  * **Act**: Call `build_report_header("requirements.md", 50, "INCOSE")`
  * **Assert**: Returns header containing `"**Items Reviewed**: 50"`

* **Unit Scenario: UTS-007-B4** (large: item_count = 999)
  * **Arrange**: Set `item_count = 999`; stub date
  * **Act**: Call `build_report_header("requirements.md", 999, "INCOSE")`
  * **Assert**: Returns header containing `"**Items Reviewed**: 999"`

#### Test Case: UTP-007-C (Date dependency fully isolated)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies that `build_report_header` obtains the generation date through the stubbed `now()`/`format_date()` functions and never accesses the system clock directly.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| now() / format_date() | System clock | Spy: returns `"2025-01-01"`, records call | Verify clock dependency is isolated |

* **Unit Scenario: UTS-007-C1** (verify date from stub appears in header)
  * **Arrange**: Stub `format_date(now(), "YYYY-MM-DD")` to return `"2025-01-01"`
  * **Act**: Call `build_report_header("requirements.md", 5, "INCOSE")`
  * **Assert**: Returned header contains `"**Date**: 2025-01-01"`; spy confirms `format_date` called once

* **Unit Scenario: UTS-007-C2** (verify remove_extension applied to file name)
  * **Arrange**: Set `artifact_file_name = "architecture-design.md"`; stub date
  * **Act**: Call `build_report_header("architecture-design.md", 3, "IEEE 42010")`
  * **Assert**: Header title is `"# Peer Review: architecture-design"` (`.md` removed)

---

### Module: MOD-008 (render_summary_table)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `commands/peer-review.md`

#### Test Case: UTP-008-A (Branch coverage for counting loop and table construction)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises the severity counting loop with various finding distributions and the table string construction.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-008-A1** (empty findings — loop zero iterations)
  * **Arrange**: Set `classified_findings = []`
  * **Act**: Call `render_summary_table(classified_findings)`
  * **Assert**: Returns table with `"| Critical | 0 |"`, `"| Major | 0 |"`, `"| Minor | 0 |"`, `"| Observation | 0 |"`

* **Unit Scenario: UTS-008-A2** (single finding — loop one iteration)
  * **Arrange**: Set `classified_findings = [{severity: "Critical", ...}]`
  * **Act**: Call `render_summary_table(classified_findings)`
  * **Assert**: Returns table with `"| Critical | 1 |"`, others `"| ... | 0 |"`

* **Unit Scenario: UTS-008-A3** (multiple findings — loop N iterations, mixed severities)
  * **Arrange**: Set `classified_findings` with 2 Critical, 1 Major, 3 Minor, 1 Observation
  * **Act**: Call `render_summary_table(classified_findings)`
  * **Assert**: Returns table with `"| Critical | 2 |"`, `"| Major | 1 |"`, `"| Minor | 3 |"`, `"| Observation | 1 |"`

#### Test Case: UTP-008-B (Boundary values for severity count integers)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests `counts` dictionary values (integers ≥ 0) at scalar boundaries.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-008-B1** (min: all counts = 0)
  * **Arrange**: Set `classified_findings = []`
  * **Act**: Call `render_summary_table(classified_findings)`
  * **Assert**: All 4 severity rows show `"| ... | 0 |"`

* **Unit Scenario: UTS-008-B2** (min+1: one severity has count = 1)
  * **Arrange**: Set `classified_findings` with 1 Minor finding
  * **Act**: Call `render_summary_table(classified_findings)`
  * **Assert**: `"| Minor | 1 |"`; Critical, Major, Observation show 0

* **Unit Scenario: UTS-008-B3** (large: 100 findings of one severity)
  * **Arrange**: Set `classified_findings` with 100 Observation findings
  * **Act**: Call `render_summary_table(classified_findings)`
  * **Assert**: `"| Observation | 100 |"`; others show 0

#### Test Case: UTP-008-C (Equivalence partitions for severity field values)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Verifies that each of the 4 discrete severity values increments the correct counter independently.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-008-C1** (partition: only Critical findings)
  * **Arrange**: Set `classified_findings` with 3 findings all having `severity = "Critical"`
  * **Act**: Call `render_summary_table(classified_findings)`
  * **Assert**: `counts["Critical"] = 3`; `counts["Major"] = 0`; `counts["Minor"] = 0`; `counts["Observation"] = 0`

* **Unit Scenario: UTS-008-C2** (partition: only Major findings)
  * **Arrange**: Set `classified_findings` with 2 findings all having `severity = "Major"`
  * **Act**: Call `render_summary_table(classified_findings)`
  * **Assert**: `counts["Major"] = 2`; others = 0

* **Unit Scenario: UTS-008-C3** (partition: only Minor findings)
  * **Arrange**: Set `classified_findings` with 1 finding having `severity = "Minor"`
  * **Act**: Call `render_summary_table(classified_findings)`
  * **Assert**: `counts["Minor"] = 1`; others = 0

* **Unit Scenario: UTS-008-C4** (partition: only Observation findings)
  * **Arrange**: Set `classified_findings` with 4 findings all having `severity = "Observation"`
  * **Act**: Call `render_summary_table(classified_findings)`
  * **Assert**: `counts["Observation"] = 4`; others = 0

---

### Module: MOD-009 (render_finding_subsections)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `commands/peer-review.md`

#### Test Case: UTP-009-A (Branch coverage for empty findings guard and rendering loop)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises the empty-findings early return and the FOR EACH loop for non-empty findings.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-009-A1** (empty findings — true branch step 1)
  * **Arrange**: Set `classified_findings = []`
  * **Act**: Call `render_finding_subsections(classified_findings)`
  * **Assert**: Returns `"## Findings\n\nNo findings.\n"`

* **Unit Scenario: UTS-009-A2** (single finding — false branch, loop one iteration)
  * **Arrange**: Set `classified_findings = [{prfId: "PRF-REQ-001", severity: "Major", location: "REQ-001", description: "ambiguous term", recommendation: "replace with metric"}]`
  * **Act**: Call `render_finding_subsections(classified_findings)`
  * **Assert**: Returns string containing `"### PRF-REQ-001"`, `"**Severity**: Major"`, `"**Location**: REQ-001"`, `"**Description**: ambiguous term"`, `"**Recommendation**: replace with metric"`

* **Unit Scenario: UTS-009-A3** (multiple findings — loop N iterations)
  * **Arrange**: Set `classified_findings` with 3 findings having prfIds `"PRF-REQ-001"`, `"PRF-REQ-002"`, `"PRF-REQ-003"`
  * **Act**: Call `render_finding_subsections(classified_findings)`
  * **Assert**: Output contains 3 `### PRF-REQ-` headings; sections separated by `---`; order matches input order

#### Test Case: UTP-009-B (Boundary values for classified_findings array length)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests the output at finding count boundaries (0, 1, typical, large).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-009-B1** (min: 0 findings)
  * **Arrange**: Set `classified_findings = []`
  * **Act**: Call `render_finding_subsections(classified_findings)`
  * **Assert**: Output equals the "No findings." template; no `###` subsection headings present

* **Unit Scenario: UTS-009-B2** (min+1: 1 finding)
  * **Arrange**: Set `classified_findings` with 1 complete finding
  * **Act**: Call `render_finding_subsections(classified_findings)`
  * **Assert**: Output contains exactly 1 `### PRF-` heading; all 4 metadata fields rendered

* **Unit Scenario: UTS-009-B3** (large: 50 findings)
  * **Arrange**: Set `classified_findings` with 50 findings numbered `PRF-REQ-001` through `PRF-REQ-050`
  * **Act**: Call `render_finding_subsections(classified_findings)`
  * **Assert**: Output contains 50 `### PRF-` headings; each separated by `---`

#### Test Case: UTP-009-C (Equivalence partitions for severity values in rendered output)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Verifies that each discrete severity value is rendered correctly in the finding subsection output.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-009-C1** (partition: Critical severity rendering)
  * **Arrange**: Set 1 finding with `severity = "Critical"`
  * **Act**: Call `render_finding_subsections(classified_findings)`
  * **Assert**: Output contains `"**Severity**: Critical"`

* **Unit Scenario: UTS-009-C2** (partition: Observation severity rendering)
  * **Arrange**: Set 1 finding with `severity = "Observation"`
  * **Act**: Call `render_finding_subsections(classified_findings)`
  * **Assert**: Output contains `"**Severity**: Observation"`

---

### Module: MOD-010 (write_review_report)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `commands/peer-review.md`

#### Test Case: UTP-010-A (Branch coverage for output path validation and report assembly)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises the null/empty output path error branch and the successful report assembly path.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| write_file() | ARCH-008 filesystem interface | Stub: records written content, returns success | Never write to real filesystem in unit test |

* **Unit Scenario: UTS-010-A1** (null output path — true branch step 2)
  * **Arrange**: Set `header = "# Header"`, `summary_table = "## Summary"`, `finding_sections = "## Findings"`, `output_path = NULL`
  * **Act**: Call `write_review_report(header, summary_table, finding_sections, output_path)`
  * **Assert**: Raises `FileWriteError` with message "No output path specified"

* **Unit Scenario: UTS-010-A2** (empty output path — true branch step 2)
  * **Arrange**: Set `output_path = ""`; other params valid
  * **Act**: Call `write_review_report(header, summary_table, finding_sections, output_path)`
  * **Assert**: Raises `FileWriteError` with message "No output path specified"

* **Unit Scenario: UTS-010-A3** (valid path — false branch, success)
  * **Arrange**: Set `header = "# Peer Review: requirements"`, `summary_table = "## Summary\n| ... |"`, `finding_sections = "## Findings\n..."`, `output_path = "/output/report.md"`; stub `write_file` succeeds
  * **Act**: Call `write_review_report(header, summary_table, finding_sections, output_path)`
  * **Assert**: Returns `"/output/report.md"`; `write_file` stub received concatenated `report = header + "\n" + summary_table + "\n" + finding_sections`

#### Test Case: UTP-010-B (Filesystem write dependency fully isolated)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies `write_review_report` delegates to `write_file` with exact arguments and never touches the real filesystem.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| write_file() | ARCH-008 filesystem interface | Spy: records path and content arguments | Verify file write contract |

* **Unit Scenario: UTS-010-B1** (verify write_file called with correct path and content)
  * **Arrange**: Set `output_path = "/v-model/peer-review-requirements.md"`; set header, summary, findings sections; configure `write_file` spy
  * **Act**: Call `write_review_report(header, summary_table, finding_sections, output_path)`
  * **Assert**: `write_file` spy called once with path `"/v-model/peer-review-requirements.md"` and content = assembled report string

* **Unit Scenario: UTS-010-B2** (verify FileWriteError on write failure)
  * **Arrange**: Set valid params; configure `write_file` spy to raise permission error
  * **Act**: Call `write_review_report(header, summary_table, finding_sections, output_path)`
  * **Assert**: Raises `FileWriteError`; spy confirms `write_file` was attempted

#### Test Case: UTP-010-C (Boundary values for assembled report size)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests report assembly with minimal and large input sections to verify string concatenation at size boundaries.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| write_file() | ARCH-008 filesystem interface | Stub: accepts any content | Isolate filesystem |

* **Unit Scenario: UTS-010-C1** (min: all sections are minimal strings)
  * **Arrange**: Set `header = "H"`, `summary_table = "S"`, `finding_sections = "F"`, `output_path = "/out.md"`; stub `write_file`
  * **Act**: Call `write_review_report(header, summary_table, finding_sections, output_path)`
  * **Assert**: Returns `"/out.md"`; assembled `report = "H\nS\nF"`

* **Unit Scenario: UTS-010-C2** (large: sections totaling ~50 KB)
  * **Arrange**: Set `header` to 400-char string, `summary_table` to 300-char string, `finding_sections` to 49300-char string; stub `write_file`
  * **Act**: Call `write_review_report(header, summary_table, finding_sections, output_path)`
  * **Assert**: Returns output path; `write_file` received report of ~50000 chars

---

### Module: MOD-011 (orchestrate_peer_review)

**Parent Architecture Modules**: ARCH-001, ARCH-002, ARCH-003, ARCH-004, ARCH-005, ARCH-006, ARCH-007, ARCH-008
**Target Source File(s)**: `commands/peer-review.md`

#### Test Case: UTP-011-A (Branch coverage for sequential pipeline orchestration)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises the end-to-end orchestration pipeline from file reading through report writing, verifying each step is called in sequence.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| read_artifact_file() | MOD-001 | Mock: returns canned content | Isolate from filesystem |
| resolve_artifact_type() | MOD-002 | Mock: returns canned ArtifactMetadata | Isolate type resolution |
| get_review_criteria() | MOD-003 | Mock: returns canned CriteriaSet | Isolate criteria lookup |
| evaluate_artifact() | MOD-004 | Mock: returns canned RawFinding[] | Isolate from LLM |
| assign_prf_ids() | MOD-005 | Mock: returns canned IdentifiedFinding[] | Isolate ID assignment |
| classify_severity() | MOD-006 | Mock: returns canned ClassifiedFinding[] | Isolate severity classification |
| build_report_header() | MOD-007 | Mock: returns canned header string | Isolate header building |
| render_summary_table() | MOD-008 | Mock: returns canned table string | Isolate table rendering |
| render_finding_subsections() | MOD-009 | Mock: returns canned sections string | Isolate finding rendering |
| write_review_report() | MOD-010 | Mock: returns canned output path | Isolate filesystem write |
| extract_basename() | Utility | Mock: returns file name | Isolate path parsing |
| join_path() | Utility | Mock: returns constructed path | Isolate path construction |

* **Unit Scenario: UTS-011-A1** (full pipeline success with findings)
  * **Arrange**: Set `artifact_path = "/v-model/requirements.md"`, `vmodel_dir = "/v-model/"`; mock all 10 sub-functions returning valid intermediate results; mock `write_review_report` returns `"/v-model/peer-review-requirements.md"`
  * **Act**: Call `orchestrate_peer_review(artifact_path, vmodel_dir)`
  * **Assert**: Returns `"/v-model/peer-review-requirements.md"`; all sub-functions called in sequence

* **Unit Scenario: UTS-011-A2** (pipeline success with zero findings)
  * **Arrange**: Same as UTS-011-A1 but mock `evaluate_artifact` returns `[]`; mock `assign_prf_ids` returns `[]`; mock `classify_severity` returns `[]`
  * **Act**: Call `orchestrate_peer_review(artifact_path, vmodel_dir)`
  * **Assert**: Returns valid output path; `render_finding_subsections` called with empty array

#### Test Case: UTP-011-B (All sub-function dependencies fully isolated)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies that `orchestrate_peer_review` delegates to each sub-function correctly and that data flows through the pipeline in the documented order.

**Dependency & Mock Registry:**

(Same as UTP-011-A — all 10 sub-functions mocked)

* **Unit Scenario: UTS-011-B1** (verify call order and data flow)
  * **Arrange**: Configure spies on all sub-functions returning valid data; set `artifact_path = "/v-model/system-design.md"`, `vmodel_dir = "/v-model/"`
  * **Act**: Call `orchestrate_peer_review(artifact_path, vmodel_dir)`
  * **Assert**: Call order verified: `read_artifact_file` → `resolve_artifact_type` → `get_review_criteria` → `evaluate_artifact` → `assign_prf_ids` → `classify_severity` → `build_report_header` → `render_summary_table` → `render_finding_subsections` → `write_review_report`

* **Unit Scenario: UTS-011-B2** (verify early abort on sub-function error)
  * **Arrange**: Mock `read_artifact_file` to raise `FileNotFoundError`; all other mocks configured
  * **Act**: Call `orchestrate_peer_review("/missing.md", "/v-model/")`
  * **Assert**: `FileNotFoundError` propagated; `resolve_artifact_type` and subsequent functions never called

#### Test Case: UTP-011-C (Boundary values for pipeline data sizes)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests the pipeline with minimal and maximal intermediate data sizes.

**Dependency & Mock Registry:**

(Same as UTP-011-A — all sub-functions mocked)

* **Unit Scenario: UTS-011-C1** (minimal: zero findings through pipeline)
  * **Arrange**: Mock `evaluate_artifact` returns `[]`; remaining mocks return minimal data
  * **Act**: Call `orchestrate_peer_review(artifact_path, vmodel_dir)`
  * **Assert**: Pipeline completes; output path returned; `assign_prf_ids` received empty array

* **Unit Scenario: UTS-011-C2** (large: 999 findings through pipeline)
  * **Arrange**: Mock `evaluate_artifact` returns 999 findings; subsequent mocks handle 999 items
  * **Act**: Call `orchestrate_peer_review(artifact_path, vmodel_dir)`
  * **Assert**: Pipeline completes; `classify_severity` receives 999 identified findings; output path returned

---

### Module: MOD-012 (parse_check_args — Bash)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `scripts/bash/peer-review-check.sh`

#### Test Case: UTP-012-A (Branch coverage for argument parsing branches)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises every branch: `--json` flag, unknown option, multiple review files, no review file, file not found, and valid parse.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists() | ARCH-009 filesystem check | Stub: returns configurable boolean | Isolate from real filesystem |

* **Unit Scenario: UTS-012-A1** (--json flag recognized — true branch for --json)
  * **Arrange**: Set `args = ["--json", "/path/review.md"]`; stub `file_exists` returns `true`
  * **Act**: Call `parse_check_args(args)`
  * **Assert**: Returns `CheckConfig` with `jsonMode = true`, `reviewFile = "/path/review.md"`

* **Unit Scenario: UTS-012-A2** (unknown option — true branch for starts-with --)
  * **Arrange**: Set `args = ["--verbose", "/path/review.md"]`
  * **Act**: Call `parse_check_args(args)`
  * **Assert**: Prints "Unknown option: --verbose" to stderr; exits with code 1

* **Unit Scenario: UTS-012-A3** (multiple review files — true branch for review_file IS NOT NULL)
  * **Arrange**: Set `args = ["file1.md", "file2.md"]`
  * **Act**: Call `parse_check_args(args)`
  * **Assert**: Prints "Error: Multiple review files specified" to stderr; exits with code 1

* **Unit Scenario: UTS-012-A4** (no review file — true branch for review_file IS NULL)
  * **Arrange**: Set `args = ["--json"]`
  * **Act**: Call `parse_check_args(args)`
  * **Assert**: Prints "Error: No review file specified" to stderr; exits with code 1

* **Unit Scenario: UTS-012-A5** (review file not found — true branch for NOT file_exists)
  * **Arrange**: Set `args = ["/nonexistent.md"]`; stub `file_exists` returns `false`
  * **Act**: Call `parse_check_args(args)`
  * **Assert**: Prints "Error: Review file not found: /nonexistent.md" to stderr; exits with code 1

* **Unit Scenario: UTS-012-A6** (valid args without --json — all false branches)
  * **Arrange**: Set `args = ["/valid/review.md"]`; stub `file_exists` returns `true`
  * **Act**: Call `parse_check_args(args)`
  * **Assert**: Returns `CheckConfig` with `jsonMode = false`, `reviewFile = "/valid/review.md"`

#### Test Case: UTP-012-B (Equivalence partitions for json_mode boolean and argument types)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Verifies the discrete boolean `json_mode` partitions and valid/invalid argument type partitions.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists() | ARCH-009 filesystem check | Stub: returns `true` | Bypass file existence check |

* **Unit Scenario: UTS-012-B1** (partition: json_mode = true)
  * **Arrange**: Set `args = ["--json", "review.md"]`; stub `file_exists` returns `true`
  * **Act**: Call `parse_check_args(args)`
  * **Assert**: `json_mode = true`

* **Unit Scenario: UTS-012-B2** (partition: json_mode = false)
  * **Arrange**: Set `args = ["review.md"]`; stub `file_exists` returns `true`
  * **Act**: Call `parse_check_args(args)`
  * **Assert**: `json_mode = false`

* **Unit Scenario: UTS-012-B3** (partition: positional argument as review file)
  * **Arrange**: Set `args = ["peer-review-requirements.md"]`; stub `file_exists` returns `true`
  * **Act**: Call `parse_check_args(args)`
  * **Assert**: `reviewFile = "peer-review-requirements.md"`

#### Test Case: UTP-012-C (Filesystem dependency fully isolated)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies that `parse_check_args` delegates file existence checking to the stubbed `file_exists` function.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| file_exists() | ARCH-009 filesystem check | Spy: records path argument | Verify correct path checked |

* **Unit Scenario: UTS-012-C1** (verify file_exists called with review file path)
  * **Arrange**: Set `args = ["/path/to/review.md"]`; configure `file_exists` spy returning `true`
  * **Act**: Call `parse_check_args(args)`
  * **Assert**: `file_exists` spy called once with argument `"/path/to/review.md"`

* **Unit Scenario: UTS-012-C2** (verify file_exists not called when args invalid)
  * **Arrange**: Set `args = []` (no arguments)
  * **Act**: Call `parse_check_args(args)`
  * **Assert**: `file_exists` never called; exits with code 1 before file check

---

### Module: MOD-013 (parse_severity_counts — Bash)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `scripts/bash/peer-review-check.sh`

#### Test Case: UTP-013-A (Branch coverage for summary table parsing and fallback to finding headers)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises the primary regex matching path, the fallback path when no summary table exists, and the all-zero case.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| read_file() | ARCH-009 filesystem | Stub: returns configurable content string | Isolate from real filesystem |

* **Unit Scenario: UTS-013-A1** (summary table present — primary regex matches)
  * **Arrange**: Stub `read_file` returns content with `"| Critical | 2 |"`, `"| Major | 1 |"`, `"| Minor | 3 |"`, `"| Observation | 0 |"`
  * **Act**: Call `parse_severity_counts(review_file)`
  * **Assert**: Returns `counts = {critical: 2, major: 1, minor: 3, observation: 0}`; `has_summary_table = true`

* **Unit Scenario: UTS-013-A2** (no summary table — fallback to finding headers)
  * **Arrange**: Stub `read_file` returns content with no table rows but with `"**Severity**: Critical"` (×1) and `"**Severity**: Minor"` (×2)
  * **Act**: Call `parse_severity_counts(review_file)`
  * **Assert**: Returns `counts = {critical: 1, major: 0, minor: 2, observation: 0}`

* **Unit Scenario: UTS-013-A3** (no summary table and no finding headers — all zeros)
  * **Arrange**: Stub `read_file` returns content `"# Peer Review\n\nSome unrelated text"`
  * **Act**: Call `parse_severity_counts(review_file)`
  * **Assert**: Returns `counts = {critical: 0, major: 0, minor: 0, observation: 0}`

* **Unit Scenario: UTS-013-A4** (partial summary table — only some rows match)
  * **Arrange**: Stub `read_file` returns content with `"| Critical | 5 |"` and `"| Major | 3 |"` but no Minor or Observation rows
  * **Act**: Call `parse_severity_counts(review_file)`
  * **Assert**: `counts.critical = 5`, `counts.major = 3`, `counts.minor = 0`, `counts.observation = 0`

#### Test Case: UTP-013-B (Boundary values for parsed severity count integers)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests severity count parsing at integer boundaries (0, 1, typical, large).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| read_file() | ARCH-009 filesystem | Stub: returns configurable content | Control count values precisely |

* **Unit Scenario: UTS-013-B1** (min: all counts = 0)
  * **Arrange**: Stub `read_file` returns summary table with all zero counts
  * **Act**: Call `parse_severity_counts(review_file)`
  * **Assert**: All 4 counts = 0

* **Unit Scenario: UTS-013-B2** (min+1: single count = 1)
  * **Arrange**: Stub `read_file` returns `"| Critical | 1 |"` with others = 0
  * **Act**: Call `parse_severity_counts(review_file)`
  * **Assert**: `critical = 1`; others = 0

* **Unit Scenario: UTS-013-B3** (mid: typical counts)
  * **Arrange**: Stub `read_file` returns `"| Critical | 3 |"`, `"| Major | 7 |"`, `"| Minor | 12 |"`, `"| Observation | 5 |"`
  * **Act**: Call `parse_severity_counts(review_file)`
  * **Assert**: `critical = 3`, `major = 7`, `minor = 12`, `observation = 5`

* **Unit Scenario: UTS-013-B4** (large: count = 999)
  * **Arrange**: Stub `read_file` returns `"| Minor | 999 |"`
  * **Act**: Call `parse_severity_counts(review_file)`
  * **Assert**: `minor = 999`

#### Test Case: UTP-013-C (Filesystem read dependency fully isolated)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies `parse_severity_counts` obtains content through the stubbed `read_file` function.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| read_file() | ARCH-009 filesystem | Spy: records file path argument | Verify file read isolation |

* **Unit Scenario: UTS-013-C1** (verify read_file called with review_file path)
  * **Arrange**: Set `review_file = "/v-model/peer-review-requirements.md"`; configure `read_file` spy returning valid content
  * **Act**: Call `parse_severity_counts(review_file)`
  * **Assert**: `read_file` spy called once with `"/v-model/peer-review-requirements.md"`

---

### Module: MOD-014 (determine_exit_code — Bash)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `scripts/bash/peer-review-check.sh`

#### Test Case: UTP-014-A (Branch coverage for exit code determination and JSON output)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises all three exit code branches (critical/major → 1, minor-only → 2, clean → 0) and the JSON output conditional.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-014-A1** (critical > 0 — exit code 1)
  * **Arrange**: Set `counts = {critical: 1, major: 0, minor: 0, observation: 0}`; set `json_mode = false`
  * **Act**: Call `determine_exit_code(counts, json_mode)`
  * **Assert**: Returns exit code `1`

* **Unit Scenario: UTS-014-A2** (major > 0 — exit code 1)
  * **Arrange**: Set `counts = {critical: 0, major: 2, minor: 0, observation: 0}`; set `json_mode = false`
  * **Act**: Call `determine_exit_code(counts, json_mode)`
  * **Assert**: Returns exit code `1`

* **Unit Scenario: UTS-014-A3** (minor > 0, no critical/major — exit code 2)
  * **Arrange**: Set `counts = {critical: 0, major: 0, minor: 3, observation: 1}`; set `json_mode = false`
  * **Act**: Call `determine_exit_code(counts, json_mode)`
  * **Assert**: Returns exit code `2`

* **Unit Scenario: UTS-014-A4** (observations only — exit code 0)
  * **Arrange**: Set `counts = {critical: 0, major: 0, minor: 0, observation: 5}`; set `json_mode = false`
  * **Act**: Call `determine_exit_code(counts, json_mode)`
  * **Assert**: Returns exit code `0`

* **Unit Scenario: UTS-014-A5** (all zeros — exit code 0)
  * **Arrange**: Set `counts = {critical: 0, major: 0, minor: 0, observation: 0}`; set `json_mode = false`
  * **Act**: Call `determine_exit_code(counts, json_mode)`
  * **Assert**: Returns exit code `0`

* **Unit Scenario: UTS-014-A6** (json_mode true — JSON output to stdout before exit)
  * **Arrange**: Set `counts = {critical: 1, major: 0, minor: 2, observation: 0}`; set `json_mode = true`
  * **Act**: Call `determine_exit_code(counts, json_mode)`
  * **Assert**: Stdout contains `'{"critical": 1, "major": 0, "minor": 2, "observation": 0}'`; returns exit code `1`

#### Test Case: UTP-014-B (Equivalence partitions for json_mode and exit code values)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Verifies discrete boolean `json_mode` partitions and the 3 discrete exit code values.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-014-B1** (partition: json_mode = true)
  * **Arrange**: Set `json_mode = true`; `counts` with all zeros
  * **Act**: Call `determine_exit_code(counts, json_mode)`
  * **Assert**: JSON printed to stdout; `"critical": 0` present

* **Unit Scenario: UTS-014-B2** (partition: json_mode = false)
  * **Arrange**: Set `json_mode = false`; `counts` with all zeros
  * **Act**: Call `determine_exit_code(counts, json_mode)`
  * **Assert**: No stdout output; returns exit code `0`

* **Unit Scenario: UTS-014-B3** (partition: exit code 0 — clean)
  * **Arrange**: Set `counts = {critical: 0, major: 0, minor: 0, observation: 2}`
  * **Act**: Call `determine_exit_code(counts, false)`
  * **Assert**: Returns `0`

* **Unit Scenario: UTS-014-B4** (partition: exit code 1 — critical/major)
  * **Arrange**: Set `counts = {critical: 1, major: 1, minor: 0, observation: 0}`
  * **Act**: Call `determine_exit_code(counts, false)`
  * **Assert**: Returns `1`

* **Unit Scenario: UTS-014-B5** (partition: exit code 2 — minor only)
  * **Arrange**: Set `counts = {critical: 0, major: 0, minor: 1, observation: 0}`
  * **Act**: Call `determine_exit_code(counts, false)`
  * **Assert**: Returns `2`

#### Test Case: UTP-014-C (Boundary values for severity counts at exit code thresholds)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests counts at the boundaries that determine exit code transitions (0→1 for critical/major, 0→1 for minor).

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-014-C1** (critical boundary: 0 → exit 0; 1 → exit 1)
  * **Arrange**: Set `counts = {critical: 0, major: 0, minor: 0, observation: 0}`
  * **Act**: Call `determine_exit_code(counts, false)`
  * **Assert**: Returns `0`

* **Unit Scenario: UTS-014-C2** (critical boundary: 1 triggers exit 1)
  * **Arrange**: Set `counts = {critical: 1, major: 0, minor: 0, observation: 0}`
  * **Act**: Call `determine_exit_code(counts, false)`
  * **Assert**: Returns `1`

* **Unit Scenario: UTS-014-C3** (major boundary: 0 → clean; 1 → exit 1)
  * **Arrange**: Set `counts = {critical: 0, major: 1, minor: 0, observation: 0}`
  * **Act**: Call `determine_exit_code(counts, false)`
  * **Assert**: Returns `1`

* **Unit Scenario: UTS-014-C4** (minor boundary: 0 → exit 0; 1 → exit 2)
  * **Arrange**: Set `counts = {critical: 0, major: 0, minor: 1, observation: 0}`
  * **Act**: Call `determine_exit_code(counts, false)`
  * **Assert**: Returns `2`

* **Unit Scenario: UTS-014-C5** (priority: critical+minor both present → exit 1 takes precedence)
  * **Arrange**: Set `counts = {critical: 1, major: 0, minor: 5, observation: 0}`
  * **Act**: Call `determine_exit_code(counts, false)`
  * **Assert**: Returns `1` (critical/major check evaluated first)

---

### Module: MOD-015 (main — Bash CI Check)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `scripts/bash/peer-review-check.sh`

#### Test Case: UTP-015-A (Branch coverage for main orchestration pipeline)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises the sequential orchestration: `parse_check_args` → `parse_severity_counts` → `determine_exit_code`, verifying the pipeline completes and exits with the correct code.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| parse_check_args() | MOD-012 | Mock: returns canned CheckConfig | Isolate argument parsing |
| parse_severity_counts() | MOD-013 | Mock: returns canned SeverityCounts | Isolate file parsing |
| determine_exit_code() | MOD-014 | Mock: returns canned exit code | Isolate exit code logic |

* **Unit Scenario: UTS-015-A1** (clean pipeline — exit code 0)
  * **Arrange**: Mock `parse_check_args` returns `{jsonMode: false, reviewFile: "review.md"}`; mock `parse_severity_counts` returns all-zero counts; mock `determine_exit_code` returns `0`
  * **Act**: Call `main(["review.md"])`
  * **Assert**: Process exits with code `0`

* **Unit Scenario: UTS-015-A2** (pipeline with critical findings — exit code 1)
  * **Arrange**: Mock `parse_check_args` returns `{jsonMode: false, reviewFile: "review.md"}`; mock `parse_severity_counts` returns `{critical: 1, ...}`; mock `determine_exit_code` returns `1`
  * **Act**: Call `main(["review.md"])`
  * **Assert**: Process exits with code `1`

* **Unit Scenario: UTS-015-A3** (parse_check_args error propagation)
  * **Arrange**: Mock `parse_check_args` to exit with code 1 (e.g., missing args)
  * **Act**: Call `main([])`
  * **Assert**: Process exits with code `1`; `parse_severity_counts` never called

#### Test Case: UTP-015-B (All sub-function dependencies fully isolated)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies `main` delegates to its three sub-functions and passes data correctly between them.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| parse_check_args() | MOD-012 | Spy: records args, returns config | Verify delegation |
| parse_severity_counts() | MOD-013 | Spy: records reviewFile, returns counts | Verify file path passed |
| determine_exit_code() | MOD-014 | Spy: records counts and jsonMode, returns code | Verify data flow |

* **Unit Scenario: UTS-015-B1** (verify data flow: reviewFile from config passed to parse_severity_counts)
  * **Arrange**: Configure spies; mock `parse_check_args` returns `{jsonMode: true, reviewFile: "/path/review.md"}`
  * **Act**: Call `main(["--json", "/path/review.md"])`
  * **Assert**: `parse_severity_counts` spy received `"/path/review.md"`; `determine_exit_code` spy received the counts and `json_mode = true`

#### Test Case: UTP-015-C (Equivalence partitions for json_mode propagation through pipeline)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Verifies that `json_mode` boolean propagates correctly from args through to exit code determination.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| parse_check_args() | MOD-012 | Mock: returns config with json_mode set | Control boolean partition |
| parse_severity_counts() | MOD-013 | Mock: returns fixed counts | Stable intermediate data |
| determine_exit_code() | MOD-014 | Spy: records json_mode argument | Verify propagation |

* **Unit Scenario: UTS-015-C1** (partition: json_mode = true passed to determine_exit_code)
  * **Arrange**: Mock `parse_check_args` returns `{jsonMode: true, ...}`; configure `determine_exit_code` spy
  * **Act**: Call `main(["--json", "review.md"])`
  * **Assert**: `determine_exit_code` spy received `json_mode = true`

* **Unit Scenario: UTS-015-C2** (partition: json_mode = false passed to determine_exit_code)
  * **Arrange**: Mock `parse_check_args` returns `{jsonMode: false, ...}`; configure `determine_exit_code` spy
  * **Act**: Call `main(["review.md"])`
  * **Assert**: `determine_exit_code` spy received `json_mode = false`

---

### Module: MOD-016 (Invoke-PeerReviewCheck — PowerShell)

**Parent Architecture Modules**: ARCH-010
**Target Source File(s)**: `scripts/powershell/peer-review-check.ps1`

#### Test Case: UTP-016-A (Branch coverage for parameter validation, parsing, fallback, and exit code determination)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises all branches in the combined PowerShell function: null/empty ReviewFile, file not found, summary table regex matches, fallback to finding headers, JSON output conditional, and all three exit code paths.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Test-Path() | PowerShell filesystem | Stub: returns configurable boolean | Isolate from real filesystem |
| Get-Content() | PowerShell filesystem | Stub: returns configurable content string | Isolate from real filesystem |

* **Unit Scenario: UTS-016-A1** (null ReviewFile — true branch step 1)
  * **Arrange**: Set `ReviewFile = NULL`; set `Json = false`
  * **Act**: Call `Invoke-PeerReviewCheck -ReviewFile $null`
  * **Assert**: Write-Error output contains "No review file specified"; exits with code 1

* **Unit Scenario: UTS-016-A2** (file not found — true branch step 1)
  * **Arrange**: Set `ReviewFile = "/missing.md"`; stub `Test-Path` returns `false`
  * **Act**: Call `Invoke-PeerReviewCheck -ReviewFile "/missing.md"`
  * **Assert**: Write-Error contains "Review file not found"; exits with code 1

* **Unit Scenario: UTS-016-A3** (summary table parsed — primary regex success)
  * **Arrange**: Set `ReviewFile = "review.md"`; stub `Test-Path` returns `true`; stub `Get-Content` returns content with `"| Critical | 2 |"`, `"| Major | 0 |"`, `"| Minor | 1 |"`, `"| Observation | 3 |"`; set `Json = false`
  * **Act**: Call `Invoke-PeerReviewCheck -ReviewFile "review.md"`
  * **Assert**: Exits with code `1` (critical > 0)

* **Unit Scenario: UTS-016-A4** (fallback to finding headers — no summary table)
  * **Arrange**: Stub `Get-Content` returns content with no table rows but 2× `"**Severity**: Minor"`; set `Json = false`
  * **Act**: Call `Invoke-PeerReviewCheck -ReviewFile "review.md"`
  * **Assert**: `counts.minor = 2`; exits with code `2`

* **Unit Scenario: UTS-016-A5** (clean review — exit code 0)
  * **Arrange**: Stub `Get-Content` returns content with all-zero summary table; set `Json = false`
  * **Act**: Call `Invoke-PeerReviewCheck -ReviewFile "review.md"`
  * **Assert**: Exits with code `0`

* **Unit Scenario: UTS-016-A6** (JSON output — true branch step 6)
  * **Arrange**: Stub `Get-Content` returns content with `"| Critical | 1 |"` etc.; set `Json = true`
  * **Act**: Call `Invoke-PeerReviewCheck -ReviewFile "review.md" -Json`
  * **Assert**: Stdout contains valid JSON with `"critical":1`; exits with code `1`

#### Test Case: UTP-016-B (Equivalence partitions for Json switch and severity values)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Verifies the discrete boolean `-Json` switch and the four severity value partitions parsed from content.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Test-Path() | PowerShell filesystem | Stub: returns `true` | Bypass file check |
| Get-Content() | PowerShell filesystem | Stub: returns configurable content | Control parsed values |

* **Unit Scenario: UTS-016-B1** (partition: Json = true)
  * **Arrange**: Set `Json = true`; stub content with all-zero summary
  * **Act**: Call `Invoke-PeerReviewCheck -ReviewFile "r.md" -Json`
  * **Assert**: JSON output printed to stdout; format `{"critical":0,...}`

* **Unit Scenario: UTS-016-B2** (partition: Json = false)
  * **Arrange**: Set `Json = false`; stub content with all-zero summary
  * **Act**: Call `Invoke-PeerReviewCheck -ReviewFile "r.md"`
  * **Assert**: No JSON output; exits with code `0`

* **Unit Scenario: UTS-016-B3** (partition: Critical severity parsed from summary table)
  * **Arrange**: Stub content with `"| Critical | 4 |"`, others = 0
  * **Act**: Call `Invoke-PeerReviewCheck -ReviewFile "r.md" -Json`
  * **Assert**: JSON contains `"critical":4`

* **Unit Scenario: UTS-016-B4** (partition: Observation severity parsed from finding headers)
  * **Arrange**: Stub content with no summary table but 3× `"**Severity**: Observation"`
  * **Act**: Call `Invoke-PeerReviewCheck -ReviewFile "r.md" -Json`
  * **Assert**: JSON contains `"observation":3`

#### Test Case: UTP-016-C (Boundary values for severity count parsing)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests parsed count values at integer boundaries to verify regex extraction and integer conversion.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Test-Path() | PowerShell filesystem | Stub: returns `true` | Bypass file check |
| Get-Content() | PowerShell filesystem | Stub: returns configurable content | Control count values |

* **Unit Scenario: UTS-016-C1** (min: all counts = 0)
  * **Arrange**: Stub content with summary table all zeros
  * **Act**: Call `Invoke-PeerReviewCheck -ReviewFile "r.md" -Json`
  * **Assert**: JSON `"critical":0,"major":0,"minor":0,"observation":0`; exit code `0`

* **Unit Scenario: UTS-016-C2** (min+1: single count = 1)
  * **Arrange**: Stub content with `"| Minor | 1 |"`, others 0
  * **Act**: Call `Invoke-PeerReviewCheck -ReviewFile "r.md" -Json`
  * **Assert**: JSON `"minor":1`; exit code `2`

* **Unit Scenario: UTS-016-C3** (mid: typical counts)
  * **Arrange**: Stub content with `"| Critical | 3 |"`, `"| Major | 5 |"`, `"| Minor | 8 |"`, `"| Observation | 12 |"`
  * **Act**: Call `Invoke-PeerReviewCheck -ReviewFile "r.md" -Json`
  * **Assert**: JSON `"critical":3,"major":5,"minor":8,"observation":12`; exit code `1`

* **Unit Scenario: UTS-016-C4** (large: count = 999)
  * **Arrange**: Stub content with `"| Observation | 999 |"`, others 0
  * **Act**: Call `Invoke-PeerReviewCheck -ReviewFile "r.md" -Json`
  * **Assert**: JSON `"observation":999`; exit code `0`

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Modules (MOD) | 16 |
| Modules tested | 16 (excludes [EXTERNAL]) |
| Modules bypassed ([EXTERNAL]) | 0 |
| Total Test Cases (UTP) | 48 |
| Total Scenarios (UTS) | 180 |
| Modules with ≥1 UTP | 16 / 16 (100%) |
| Test Cases with ≥1 UTS | 48 / 48 (100%) |
| **Overall Coverage (MOD→UTP)** | **100%** |

### Technique Distribution

| Technique | Test Cases | Percentage |
|-----------|-----------|------------|
| Statement & Branch Coverage | 16 | 33.3% |
| Boundary Value Analysis | 13 | 27.1% |
| Equivalence Partitioning | 10 | 20.8% |
| Strict Isolation | 9 | 18.8% |
| State Transition Testing | 0 | 0.0% |

## Uncovered Modules

None — full coverage achieved.
