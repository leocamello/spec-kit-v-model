# Unit Test Plan: System Design ↔ System Testing

**Feature Branch**: `002-system-design-testing`
**Created**: 2026-02-20
**Status**: Draft
**Source**: `specs/002-system-design-testing/v-model/module-design.md`

## Overview

This document defines the Unit Test Plan for the System Design ↔ System Testing feature. Every module design (`MOD-NNN`) in `module-design.md` has one or more Test Cases (`UTP-NNN-X`), and every Test Case has one or more executable Unit Scenarios (`UTS-NNN-X#`) in white-box Arrange/Act/Assert format.

Unit tests verify **internal module logic** — control flow, data transformations, state transitions, and variable boundaries. They do NOT test module boundaries (integration), user journeys (acceptance), or system-level behavior (system tests).

All 18 modules are stateless; State Transition Testing is therefore not applicable. No `v-model-config.yml` domain is configured, so safety-critical techniques (MC/DC Coverage, Variable-Level Fault Injection) are omitted.

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
| **State Transition Testing** | State Machine View | Every transition including invalid ones |

> **Note**: State Transition Testing yields zero test cases — all 18 modules are stateless (no Mermaid `stateDiagram-v2` in any State Machine View).

## Unit Tests

---

### Module: MOD-001 (System Design Command Prompt)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `commands/system-design.md`

#### Test Case: UTP-001-A (Statement & Branch Coverage of system_design_command)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises every branch in `system_design_command` pseudocode: domain overlay presence/absence, existing system-design.md check, requirement loop iterations, derived requirement flagging, and error branches.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| setup-v-model.sh | ARCH-001 Interface | Stub: returns static JSON string | Isolate from shell execution |
| File system (READ_FILE) | ARCH-001 Interface | Stub: returns predefined file content | Isolate from disk I/O |
| PARSE_YAML | ARCH-001 Interface | Stub: returns predefined dict | Isolate from YAML parser |
| WRITE_FILE | ARCH-001 Interface | Spy: captures written content | Verify output without disk write |

* **Unit Scenario: UTS-001-A1** (True path — domain IS NOT NULL and overlay file exists)
  * **Arrange**: Set `domain = "iso_26262"`, stub `FILE_EXISTS("commands/overlays/iso_26262/system-design.md")` to return `true`, stub `READ_FILE` for overlay to return `"overlay content"`
  * **Act**: Call `system_design_command("generate")`
  * **Assert**: `overlay_content` equals `"overlay content"`; output includes overlay data in rendered template

* **Unit Scenario: UTS-001-A2** (False path — domain IS NULL)
  * **Arrange**: Stub `FILE_EXISTS("v-model-config.yml")` to return `false`, so `domain = NULL`
  * **Act**: Call `system_design_command("generate")`
  * **Assert**: `domain` equals `NULL`; `overlay_content` is `NULL`; output renders without overlay

* **Unit Scenario: UTS-001-A3** (True path — existing system-design.md in AVAILABLE_DOCS)
  * **Arrange**: Set `AVAILABLE_DOCS = ["system-design.md"]`; stub existing content containing `SYS-001`, `SYS-002`, `SYS-005`
  * **Act**: Call `system_design_command("generate")`
  * **Assert**: `highest_sys_num` equals `5`; `next_sys_num` equals `6`; existing IDs preserved

* **Unit Scenario: UTS-001-A4** (False path — no existing system-design.md)
  * **Arrange**: Set `AVAILABLE_DOCS = []` (no system-design.md)
  * **Act**: Call `system_design_command("generate")`
  * **Assert**: `existing_sys_ids` equals `[]`; `highest_sys_num` equals `0`; `next_sys_num` equals `1`

* **Unit Scenario: UTS-001-A5** (Loop zero iterations — zero req_entries)
  * **Arrange**: Stub `req_content` to a markdown file with no table rows; `req_ids = []`
  * **Act**: Call `system_design_command("generate")`
  * **Assert**: Fatal error raised: `"No requirement identifiers found in requirements.md"`

* **Unit Scenario: UTS-001-A6** (Loop one iteration — single requirement group)
  * **Arrange**: Stub `req_entries` with one entry `{id: "REQ-001", description: "test", priority: "P1", type: "functional"}`
  * **Act**: Call `system_design_command("generate")`
  * **Assert**: `sys_components` has exactly 1 entry with `id = "SYS-001"`; `coverage_pct` equals `100`

* **Unit Scenario: UTS-001-A7** (Loop N iterations — multiple requirement groups with derived)
  * **Arrange**: Stub `req_entries` with 5 entries where logical_group at index 2 has `requires_derived_capability = true`
  * **Act**: Call `system_design_command("generate")`
  * **Assert**: `sys_components` has 4 entries (one skipped as derived); `derived_requirements` has 1 entry starting with `"[DERIVED REQUIREMENT:"`

* **Unit Scenario: UTS-001-A8** (Error branch — setup script returns non-zero exit code)
  * **Arrange**: Stub `RUN("setup-v-model.sh --json --require-reqs")` to return exit code 1 with stderr `"branch not found"`
  * **Act**: Call `system_design_command("generate")`
  * **Assert**: Fatal error raised with script stderr content

* **Unit Scenario: UTS-001-A9** (Error branch — v-model-config.yml parse error)
  * **Arrange**: Stub `FILE_EXISTS("v-model-config.yml")` to return `true`; stub `PARSE_YAML` to throw parse error
  * **Act**: Call `system_design_command("generate")`
  * **Assert**: Warning issued; `domain` falls back to `NULL`; execution continues without overlay

#### Test Case: UTP-001-B (Boundary Value Analysis of scalar variables)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests boundaries of `highest_sys_num` (0–999) and `coverage_pct` (0–100).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| setup-v-model.sh | ARCH-001 Interface | Stub: returns static JSON | Isolate from shell |
| File system (READ_FILE) | ARCH-001 Interface | Stub: returns crafted content | Control boundary inputs |
| WRITE_FILE | ARCH-001 Interface | Spy: captures output | Verify without disk |

* **Unit Scenario: UTS-001-B1** (highest_sys_num min-1: below 0)
  * **Arrange**: Stub existing system-design.md with malformed ID `SYS--01` (yields parsed num = -1)
  * **Act**: Call `system_design_command("generate")`
  * **Assert**: `highest_sys_num` remains `0` (negative values rejected by `PARSE_INT`); `next_sys_num` equals `1`

* **Unit Scenario: UTS-001-B2** (highest_sys_num min: 0)
  * **Arrange**: Set `AVAILABLE_DOCS = []` so no existing IDs; `highest_sys_num` initializes to `0`
  * **Act**: Call `system_design_command("generate")`
  * **Assert**: `highest_sys_num` equals `0`; first generated SYS ID is `SYS-001`

* **Unit Scenario: UTS-001-B3** (highest_sys_num mid: 500)
  * **Arrange**: Stub existing system-design.md containing `SYS-500`
  * **Act**: Call `system_design_command("generate")`
  * **Assert**: `highest_sys_num` equals `500`; `next_sys_num` equals `501`

* **Unit Scenario: UTS-001-B4** (highest_sys_num max: 999)
  * **Arrange**: Stub existing system-design.md containing `SYS-999`
  * **Act**: Call `system_design_command("generate")`
  * **Assert**: `highest_sys_num` equals `999`; `next_sys_num` equals `1000`

* **Unit Scenario: UTS-001-B5** (highest_sys_num max+1: 1000)
  * **Arrange**: Stub existing system-design.md containing `SYS-1000` (exceeds 3-digit format)
  * **Act**: Call `system_design_command("generate")`
  * **Assert**: Regex `SYS-[0-9]{3}` does not match `SYS-1000`; `highest_sys_num` remains `0`

* **Unit Scenario: UTS-001-B6** (coverage_pct min: 0)
  * **Arrange**: Set `all_req_ids = {"REQ-001", "REQ-002"}` and `covered_reqs = {}` (empty)
  * **Act**: Compute `coverage_pct = (SIZE(covered_reqs) * 100) / SIZE(all_req_ids)`
  * **Assert**: `coverage_pct` equals `0`

* **Unit Scenario: UTS-001-B7** (coverage_pct mid: 50)
  * **Arrange**: Set `all_req_ids = {"REQ-001", "REQ-002"}` and `covered_reqs = {"REQ-001"}`
  * **Act**: Compute `coverage_pct`
  * **Assert**: `coverage_pct` equals `50`

* **Unit Scenario: UTS-001-B8** (coverage_pct max: 100)
  * **Arrange**: Set `all_req_ids = {"REQ-001", "REQ-002"}` and `covered_reqs = {"REQ-001", "REQ-002"}`
  * **Act**: Compute `coverage_pct`
  * **Assert**: `coverage_pct` equals `100`

#### Test Case: UTP-001-C (Equivalence Partitioning of domain enum)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions the `domain` variable (String or NULL; valid values: `"iso_26262"`, `"do_178c"`, `"iec_62304"`, `NULL`).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system | ARCH-001 Interface | Stub: returns crafted v-model-config.yml content | Control domain value |
| PARSE_YAML | ARCH-001 Interface | Stub: returns dict with specified domain | Isolate YAML parsing |

* **Unit Scenario: UTS-001-C1** (valid partition: `"iso_26262"`)
  * **Arrange**: Stub v-model-config.yml with `domain: "iso_26262"`
  * **Act**: Call domain extraction logic
  * **Assert**: `domain` equals `"iso_26262"`; overlay path set to `"commands/overlays/iso_26262/system-design.md"`

* **Unit Scenario: UTS-001-C2** (valid partition: `"do_178c"`)
  * **Arrange**: Stub v-model-config.yml with `domain: "do_178c"`
  * **Act**: Call domain extraction logic
  * **Assert**: `domain` equals `"do_178c"`; overlay path set to `"commands/overlays/do_178c/system-design.md"`

* **Unit Scenario: UTS-001-C3** (valid partition: `"iec_62304"`)
  * **Arrange**: Stub v-model-config.yml with `domain: "iec_62304"`
  * **Act**: Call domain extraction logic
  * **Assert**: `domain` equals `"iec_62304"`

* **Unit Scenario: UTS-001-C4** (valid partition: `NULL` — no domain configured)
  * **Arrange**: Stub v-model-config.yml with `domain:` (empty) or no config file
  * **Act**: Call domain extraction logic
  * **Assert**: `domain` equals `NULL`; no overlay loaded

* **Unit Scenario: UTS-001-C5** (invalid partition: unrecognized domain string)
  * **Arrange**: Stub v-model-config.yml with `domain: "unknown_standard"`
  * **Act**: Call domain extraction logic
  * **Assert**: `domain` equals `"unknown_standard"`; overlay file lookup fails; warning issued; proceeds without overlay

#### Test Case: UTP-001-D (Strict Isolation of external dependencies)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies MOD-001 executes correctly with all external dependencies replaced by mocks/stubs: setup script, file system reads/writes, and YAML parser.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| setup-v-model.sh | ARCH-001 Interface | Stub: returns predefined JSON | No real shell execution |
| File system (READ_FILE) | ARCH-001 Interface | Stub: returns in-memory strings | No real disk reads |
| File system (WRITE_FILE) | ARCH-001 Interface | Spy: captures arguments | Verify output path and content |
| PARSE_YAML | ARCH-001 Interface | Stub: returns predefined dict | No real YAML parser |
| PARSE_JSON | ARCH-001 Interface | Stub: returns predefined dict | No real JSON parser |

* **Unit Scenario: UTS-001-D1** (Setup script isolation)
  * **Arrange**: Stub `RUN("setup-v-model.sh ...")` to return `'{"VMODEL_DIR":"/test/v-model","REQUIREMENTS":"/test/reqs.md","AVAILABLE_DOCS":[]}'`
  * **Act**: Call `system_design_command("generate")`
  * **Assert**: `config.VMODEL_DIR` equals `"/test/v-model"`; no real shell process spawned

* **Unit Scenario: UTS-001-D2** (File system read isolation)
  * **Arrange**: Stub `READ_FILE("templates/system-design-template.md")` to return `"# Template"`; stub `READ_FILE` for requirements to return `"| REQ-001 | desc |"`
  * **Act**: Call `system_design_command("generate")`
  * **Assert**: `template` equals `"# Template"`; `req_content` contains `"REQ-001"`; no real file reads

* **Unit Scenario: UTS-001-D3** (Write isolation)
  * **Arrange**: Configure all read stubs; configure `WRITE_FILE` spy
  * **Act**: Call `system_design_command("generate")`
  * **Assert**: `WRITE_FILE` spy called once with path ending in `/system-design.md`; content includes `"## Decomposition"`

---

### Module: MOD-002 (System Design Template Definition)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `templates/system-design-template.md`

#### Test Case: UTP-002-A (Statement & Branch Coverage of system_design_template)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies that `system_design_template()` constructs the complete `TemplateStructure` with all 10 sections: header, overview, id_schema, decomposition, dependency, interface_external, interface_internal, data_design, coverage, derived, glossary.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system (template file) | ARCH-002 Interface | Stub: return in-memory template content | Isolate from disk |

* **Unit Scenario: UTS-002-A1** (All sections constructed — nominal path)
  * **Arrange**: Initialize `system_design_template()` with no arguments (static function)
  * **Act**: Call `system_design_template()`
  * **Assert**: Returned `TemplateStructure` has `header.title` equal to `"System Design: [FEATURE NAME]"`; `header.fields` has 4 entries; `decomposition` table has 5 columns: `["SYS ID", "Name", "Description", "Parent Requirements", "Type"]`

* **Unit Scenario: UTS-002-A2** (Dependency table column validation)
  * **Arrange**: Initialize `system_design_template()`
  * **Act**: Call `system_design_template()` and inspect `dependency` section
  * **Assert**: `dependency` table has 4 columns: `["Source", "Target", "Relationship", "Failure Impact"]`; `dependency_diagram` type equals `"graph TD"`

* **Unit Scenario: UTS-002-A3** (Interface tables — external and internal)
  * **Arrange**: Initialize `system_design_template()`
  * **Act**: Call `system_design_template()` and inspect `interface_external` and `interface_internal`
  * **Assert**: Both tables have 5 columns: `["Direction", "Name", "Type", "Format", "Constraints"]`

#### Test Case: UTP-002-B (Strict Isolation of template file loading)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies MOD-002 template loading with file system dependency mocked.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system (template file) | ARCH-002 Interface | Stub: returns predefined string | No real disk read |

* **Unit Scenario: UTS-002-B1** (Template file loaded from stub)
  * **Arrange**: Stub `READ_FILE("templates/system-design-template.md")` to return `"# System Design: [FEATURE NAME]\n## Overview"`
  * **Act**: Load template
  * **Assert**: Template content matches stubbed string; no file system calls made

* **Unit Scenario: UTS-002-B2** (Template file not found — error path)
  * **Arrange**: Stub `READ_FILE` to throw file-not-found error
  * **Act**: Attempt to load template
  * **Assert**: Fatal error raised: template must exist in `templates/` directory

---

### Module: MOD-003 (System Test Command Prompt)

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `commands/system-test.md`

#### Test Case: UTP-003-A (Statement & Branch Coverage of system_test_command)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises every branch in `system_test_command`: SYS entry parsing loop, interface check conditional, domain overlay, existing test plan append, coverage gate invocation, and error branches.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| setup-v-model.sh | ARCH-003 Interface | Stub: returns static JSON | Isolate shell execution |
| File system (READ_FILE) | ARCH-003 Interface | Stub: returns crafted content | Isolate disk I/O |
| WRITE_FILE | ARCH-003 Interface | Spy: captures written content | Verify output |
| validate-system-coverage.sh | ARCH-003 Interface | Stub: returns predefined gate result | Isolate coverage gate |

* **Unit Scenario: UTS-003-A1** (True path — SYS entry has interface data)
  * **Arrange**: Stub `sys_entries` with one entry `{id: "SYS-001"}`; stub `interface_data["SYS-001"]` with contract data
  * **Act**: Call `system_test_command("generate")`
  * **Assert**: `test_cases` contains STP with `technique = "Interface Contract Testing"` and `view = "Interface"`

* **Unit Scenario: UTS-003-A2** (False path — SYS entry has no interface data)
  * **Arrange**: Stub `sys_entries` with `{id: "SYS-002"}`; `interface_data` does not contain `"SYS-002"`
  * **Act**: Call `system_test_command("generate")`
  * **Assert**: No Interface Contract STP generated for SYS-002; `letter` not incremented for interface

* **Unit Scenario: UTS-003-A3** (Loop zero — no sys_entries)
  * **Arrange**: Stub `sys_content` with no decomposition rows; `sys_entries = []`
  * **Act**: Call `system_test_command("generate")`
  * **Assert**: Fatal error: `"No system component identifiers found in system-design.md"`

* **Unit Scenario: UTS-003-A4** (Loop N — multiple SYS entries with dependency data)
  * **Arrange**: Stub 3 sys_entries with SYS-001, SYS-002, SYS-003; SYS-001 and SYS-003 have dependency_data
  * **Act**: Call `system_test_command("generate")`
  * **Assert**: Fault Injection STP generated for SYS-001 and SYS-003; SYS-002 has no Fault Injection STP

* **Unit Scenario: UTS-003-A5** (True path — existing system-test.md in AVAILABLE_DOCS)
  * **Arrange**: Set `AVAILABLE_DOCS = ["system-test.md"]`; stub existing content with `STP-001-A`, `STS-001-A1`
  * **Act**: Call `system_test_command("generate")`
  * **Assert**: `existing_stp_ids` contains `"STP-001-A"`; `existing_sts_ids` contains `"STS-001-A1"`

* **Unit Scenario: UTS-003-A6** (Error branch — coverage gate returns non-zero)
  * **Arrange**: Stub `RUN("validate-system-coverage.sh ...")` to return exit code 1 with gap report
  * **Act**: Call `system_test_command("generate")`
  * **Assert**: Warning appended to output: `"Coverage gate FAILED — gaps detected"`; file still written

#### Test Case: UTP-003-B (Boundary Value Analysis of STP/STS ID generation)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests boundaries of SYS entry count affecting `test_cases` and `test_scenarios` arrays.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system | ARCH-003 Interface | Stub: crafted content | Control input boundaries |
| validate-system-coverage.sh | ARCH-003 Interface | Stub: returns exit 0 | Isolate coverage gate |

* **Unit Scenario: UTS-003-B1** (min-1: negative scenario count — 0 sys_entries)
  * **Arrange**: Set `sys_entries = []`
  * **Act**: Attempt test case generation loop
  * **Assert**: `test_cases` array is empty; fatal error for zero SYS IDs

* **Unit Scenario: UTS-003-B2** (min: 1 sys_entry)
  * **Arrange**: Set `sys_entries = [{id: "SYS-001", name: "Component A", ...}]`
  * **Act**: Call test case generation
  * **Assert**: At least 1 STP generated; `test_cases` length >= 1

* **Unit Scenario: UTS-003-B3** (mid: 10 sys_entries)
  * **Arrange**: Set `sys_entries` with 10 entries (SYS-001 through SYS-010)
  * **Act**: Call test case generation
  * **Assert**: `test_cases` length >= 10 (one BVA STP per SYS minimum)

* **Unit Scenario: UTS-003-B4** (max: 200 sys_entries — documented max for sys_ids)
  * **Arrange**: Set `sys_entries` with 200 entries
  * **Act**: Call test case generation
  * **Assert**: All 200 SYS entries produce at least one STP; no array overflow

* **Unit Scenario: UTS-003-B5** (max+1: 201 sys_entries — beyond documented max)
  * **Arrange**: Set `sys_entries` with 201 entries
  * **Act**: Call test case generation
  * **Assert**: Processing completes (constraint is soft); all 201 entries generate STPs

#### Test Case: UTP-003-C (Equivalence Partitioning of domain variable)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions the `domain` variable (String or NULL) with same valid/invalid values as MOD-001.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system | ARCH-003 Interface | Stub: crafted v-model-config.yml | Control domain value |
| PARSE_YAML | ARCH-003 Interface | Stub: returns dict | Isolate YAML |

* **Unit Scenario: UTS-003-C1** (valid partition: `"iso_26262"`)
  * **Arrange**: Stub `domain = "iso_26262"`; overlay file exists
  * **Act**: Call domain overlay loading
  * **Assert**: `overlay_content` loaded from `"commands/overlays/iso_26262/system-test.md"`

* **Unit Scenario: UTS-003-C2** (valid partition: `NULL`)
  * **Arrange**: No config file exists
  * **Act**: Call domain overlay loading
  * **Assert**: `domain` equals `NULL`; no overlay loaded; generic output produced

* **Unit Scenario: UTS-003-C3** (invalid partition: empty string)
  * **Arrange**: Stub `domain = ""`
  * **Act**: Call domain extraction; `domain = config_yaml.domain OR NULL`
  * **Assert**: `domain` equals `NULL` (empty string treated as falsy); no overlay loaded

#### Test Case: UTP-003-D (Strict Isolation of external dependencies)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies MOD-003 executes with all external dependencies mocked.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| setup-v-model.sh | ARCH-003 Interface | Stub: returns JSON string | No shell execution |
| File system (READ_FILE) | ARCH-003 Interface | Stub: in-memory strings | No disk reads |
| File system (WRITE_FILE) | ARCH-003 Interface | Spy: captures args | No disk writes |
| validate-system-coverage.sh | ARCH-003 Interface | Stub: returns exit 0 | No real validation |

* **Unit Scenario: UTS-003-D1** (All dependencies mocked — nominal execution)
  * **Arrange**: Stub setup script JSON, stub system-design.md content with 2 SYS entries, stub template
  * **Act**: Call `system_test_command("generate")`
  * **Assert**: Output written via spy contains STP/STS IDs; zero real I/O operations

* **Unit Scenario: UTS-003-D2** (Coverage gate isolation)
  * **Arrange**: Stub `RUN("validate-system-coverage.sh ...")` to return `"✅ Full coverage"`
  * **Act**: Call `system_test_command("generate")`
  * **Assert**: Gate result appended to output; no real script executed

---

### Module: MOD-004 (System Test Template Definition)

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `templates/system-test-template.md`

#### Test Case: UTP-004-A (Statement & Branch Coverage of system_test_template)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Verifies `system_test_template()` constructs complete `TemplateStructure` with header, overview, id_schema, test_cases table, test_scenarios table, coverage_gate section, and glossary.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system (template file) | ARCH-004 Interface | Stub: in-memory content | Isolate from disk |

* **Unit Scenario: UTS-004-A1** (All sections constructed — nominal)
  * **Arrange**: Initialize `system_test_template()` with no arguments
  * **Act**: Call `system_test_template()`
  * **Assert**: `header.title` equals `"System Test Plan: [FEATURE NAME]"`; `test_cases` table has 6 columns: `["STP ID", "Name", "Parent SYS", "IEEE 1016 View", "ISO 29119 Technique", "Interface Type"]`

* **Unit Scenario: UTS-004-A2** (Test scenarios table structure)
  * **Arrange**: Initialize `system_test_template()`
  * **Act**: Call `system_test_template()` and inspect `test_scenarios` table
  * **Assert**: `test_scenarios` table has 5 columns: `["STS ID", "Parent STP", "Given", "When", "Then"]`

* **Unit Scenario: UTS-004-A3** (Coverage gate section)
  * **Arrange**: Initialize `system_test_template()`
  * **Act**: Inspect `coverage_gate` section
  * **Assert**: `coverage_gate.placeholder` equals `"[validate-system-coverage.sh output]"`

#### Test Case: UTP-004-B (Strict Isolation of template file loading)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies MOD-004 template loads with file system mocked.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system (template file) | ARCH-004 Interface | Stub: returns predefined string | No real disk read |

* **Unit Scenario: UTS-004-B1** (Template loaded from stub)
  * **Arrange**: Stub template file to return ISO 29119 test plan structure
  * **Act**: Load template
  * **Assert**: Template content matches stub; no file system calls

* **Unit Scenario: UTS-004-B2** (Template file malformed — degraded path)
  * **Arrange**: Stub template file with missing section markers
  * **Act**: Load template
  * **Assert**: Parse error handled; degrades gracefully to minimal section headings

---

### Module: MOD-005 (Forward Coverage Check)

**Parent Architecture Modules**: ARCH-005
**Target Source File(s)**: `scripts/bash/validate-system-coverage.sh`

#### Test Case: UTP-005-A (Statement & Branch Coverage of check_forward_coverage)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises all branches in `check_forward_coverage`: Decomposition section detection, REQ ID extraction loop, regex matching for both `REQ-NNN` and `REQ-(NF|CN|IF)-NNN`, coverage computation, and edge cases.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system (READ_FILE) | ARCH-005 Interface | Stub: returns crafted file content | Isolate from disk |

* **Unit Scenario: UTS-005-A1** (True path — in_decomposition enters Decomposition section)
  * **Arrange**: Stub `sys_content` with `"## Decomposition View\n| SYS-001 | ... | REQ-001 |"`
  * **Act**: Call `check_forward_coverage(req_path, sys_path)`
  * **Assert**: `in_decomposition` set to `true`; `covered_reqs` contains `"REQ-001"`

* **Unit Scenario: UTS-005-A2** (False path — line starts with `## ` after Decomposition, exits loop)
  * **Arrange**: Stub `sys_content` with Decomposition section followed by `"## Dependency View"`
  * **Act**: Call `check_forward_coverage(req_path, sys_path)`
  * **Assert**: Parsing stops at `"## Dependency View"`; only Decomposition rows processed

* **Unit Scenario: UTS-005-A3** (Loop zero — no table rows in Decomposition)
  * **Arrange**: Stub `sys_content` with `"## Decomposition View\n## Dependency View"` (no rows between)
  * **Act**: Call `check_forward_coverage(req_path, sys_path)`
  * **Assert**: `covered_reqs` is empty; `uncovered` equals all `req_ids`; `pct` equals `0`

* **Unit Scenario: UTS-005-A4** (Loop one — single REQ matched)
  * **Arrange**: Stub requirements with `REQ-001`; Decomposition with `| SYS-001 | ... | REQ-001 |`
  * **Act**: Call `check_forward_coverage(req_path, sys_path)`
  * **Assert**: `covered_reqs` has 1 entry; `uncovered` is empty; `pct` equals `100`

* **Unit Scenario: UTS-005-A5** (NF-prefix REQ matching)
  * **Arrange**: Stub requirements with `REQ-NF-001, REQ-CN-002`; Decomposition references `REQ-NF-001`
  * **Act**: Call `check_forward_coverage(req_path, sys_path)`
  * **Assert**: `covered_reqs` contains `"REQ-NF-001"`; `"REQ-CN-002"` in `uncovered`

* **Unit Scenario: UTS-005-A6** (Error branch — empty req_ids)
  * **Arrange**: Stub `req_content` with no REQ patterns; `req_ids = []`
  * **Act**: Call `check_forward_coverage(req_path, sys_path)`
  * **Assert**: `pct` equals `0` (SIZE(req_ids) == 0 branch)

#### Test Case: UTP-005-B (Boundary Value Analysis of pct)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests boundaries of `pct` (Integer, 0–100).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system | ARCH-005 Interface | Stub: crafted content | Control coverage ratios |

* **Unit Scenario: UTS-005-B1** (pct min-1: negative — impossible via formula but test 0 reqs)
  * **Arrange**: Set `req_ids = []`; `covered_reqs = {}`
  * **Act**: Compute `pct`
  * **Assert**: `pct` equals `0` (division-by-zero guard: `SIZE(req_ids) == 0` yields `pct = 0`)

* **Unit Scenario: UTS-005-B2** (pct min: 0)
  * **Arrange**: Set `req_ids = ["REQ-001"]`; `covered_reqs = {}` (none covered)
  * **Act**: Compute `pct = (0 * 100) / 1`
  * **Assert**: `pct` equals `0`

* **Unit Scenario: UTS-005-B3** (pct mid: 50)
  * **Arrange**: Set `req_ids = ["REQ-001", "REQ-002"]`; `covered_reqs = {"REQ-001"}`
  * **Act**: Compute `pct = (1 * 100) / 2`
  * **Assert**: `pct` equals `50`

* **Unit Scenario: UTS-005-B4** (pct max: 100)
  * **Arrange**: Set `req_ids = ["REQ-001"]`; `covered_reqs = {"REQ-001"}`
  * **Act**: Compute `pct = (1 * 100) / 1`
  * **Assert**: `pct` equals `100`

* **Unit Scenario: UTS-005-B5** (pct max+1: impossible — formula caps at 100)
  * **Arrange**: Set `req_ids = ["REQ-001"]`; `covered_reqs = {"REQ-001", "REQ-002"}` (superset)
  * **Act**: Compute `pct`
  * **Assert**: `pct` cannot exceed `100`; result is `100` (covered capped at total)

#### Test Case: UTP-005-C (Equivalence Partitioning of in_decomposition flag)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions `in_decomposition` Boolean: `true` (inside section) vs `false` (outside section).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system | ARCH-005 Interface | Stub: crafted content | Control section positions |

* **Unit Scenario: UTS-005-C1** (valid partition: `in_decomposition = true`)
  * **Arrange**: Stub `sys_content` where current line is inside Decomposition section with table row `| SYS-001 | ... | REQ-001 |`
  * **Act**: Process line in parsing loop
  * **Assert**: `covered_reqs` updated with `"REQ-001"`; row processed as data

* **Unit Scenario: UTS-005-C2** (valid partition: `in_decomposition = false`)
  * **Arrange**: Stub `sys_content` where current line `| SYS-001 | ... | REQ-001 |` appears before `## Decomposition`
  * **Act**: Process line in parsing loop
  * **Assert**: Line ignored; `covered_reqs` remains empty

* **Unit Scenario: UTS-005-C3** (invalid partition: `in_decomposition = null/undefined`)
  * **Arrange**: Skip initialization of `in_decomposition` (simulate uninitialized state)
  * **Act**: Attempt to evaluate `in_decomposition AND line MATCHES table_row_pattern`
  * **Assert**: Uninitialized variable error or defaults to `false`; no rows processed

#### Test Case: UTP-005-D (Strict Isolation of file system)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies MOD-005 never reads real files.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system (requirements.md) | ARCH-005 Interface | Stub: in-memory string | No real file read |
| File system (system-design.md) | ARCH-005 Interface | Stub: in-memory string | No real file read |

* **Unit Scenario: UTS-005-D1** (Both files stubbed)
  * **Arrange**: Stub `READ_FILE(requirements_path)` to return `"| REQ-001 | desc |"`; stub `READ_FILE(system_design_path)` to return `"## Decomposition View\n| SYS-001 | ... | REQ-001 |"`
  * **Act**: Call `check_forward_coverage(req_path, sys_path)`
  * **Assert**: Returns `{covered: ["REQ-001"], uncovered: [], pct: 100}`; zero file system calls

* **Unit Scenario: UTS-005-D2** (File not found — requirements.md)
  * **Arrange**: Stub `READ_FILE(requirements_path)` to throw file-not-found error
  * **Act**: Call `check_forward_coverage(req_path, sys_path)`
  * **Assert**: File read error raised (exit 1)

---

### Module: MOD-006 (Backward Coverage Check)

**Parent Architecture Modules**: ARCH-006
**Target Source File(s)**: `scripts/bash/validate-system-coverage.sh`

#### Test Case: UTP-006-A (Statement & Branch Coverage of check_backward_coverage)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises all branches in `check_backward_coverage`: SYS ID extraction from Decomposition, STP ID extraction and parent SYS derivation, set-difference computation.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system (READ_FILE) | ARCH-006 Interface | Stub: crafted content | Isolate from disk |

* **Unit Scenario: UTS-006-A1** (True path — all SYS covered by STPs)
  * **Arrange**: Stub `sys_content` with `SYS-001, SYS-002`; stub `test_content` with `STP-001-A, STP-002-A`
  * **Act**: Call `check_backward_coverage(sys_path, test_path)`
  * **Assert**: `covered_sys` contains `SYS-001, SYS-002`; `uncovered` is empty; `pct` equals `100`

* **Unit Scenario: UTS-006-A2** (False path — SYS-002 has no STP)
  * **Arrange**: Stub `sys_content` with `SYS-001, SYS-002`; stub `test_content` with `STP-001-A` only
  * **Act**: Call `check_backward_coverage(sys_path, test_path)`
  * **Assert**: `uncovered` contains `"SYS-002"`; `pct` equals `50`

* **Unit Scenario: UTS-006-A3** (Loop zero — no SYS IDs in Decomposition)
  * **Arrange**: Stub `sys_content` with no Decomposition section
  * **Act**: Call `check_backward_coverage(sys_path, test_path)`
  * **Assert**: `sys_ids` is empty; `pct` equals `0`

* **Unit Scenario: UTS-006-A4** (STP parent derivation — extract SYS from STP ID)
  * **Arrange**: Stub `test_content` with `STP-003-B`
  * **Act**: Parse STP ID lineage: `parent_sys = "SYS-" + "003"`
  * **Assert**: `parent_sys` equals `"SYS-003"`; `covered_sys` contains `"SYS-003"`

* **Unit Scenario: UTS-006-A5** (Error branch — no STP IDs extracted)
  * **Arrange**: Stub `test_content` with no STP patterns
  * **Act**: Call `check_backward_coverage(sys_path, test_path)`
  * **Assert**: `covered_sys` is empty; `uncovered` equals all `sys_ids`; `pct` equals `0`

#### Test Case: UTP-006-B (Boundary Value Analysis of pct)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests boundaries of `pct` (Integer, 0–100).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system | ARCH-006 Interface | Stub: crafted content | Control coverage ratios |

* **Unit Scenario: UTS-006-B1** (pct min-1: 0 sys_ids → division guard)
  * **Arrange**: Set `sys_ids = []`
  * **Act**: Compute `pct`
  * **Assert**: `pct` equals `0` (guard: `SIZE(sys_ids) == 0`)

* **Unit Scenario: UTS-006-B2** (pct min: 0)
  * **Arrange**: Set `sys_ids = ["SYS-001"]`; `covered_sys = {}` (none covered)
  * **Act**: Compute `pct = (0 * 100) / 1`
  * **Assert**: `pct` equals `0`

* **Unit Scenario: UTS-006-B3** (pct mid: 50)
  * **Arrange**: Set `sys_ids = ["SYS-001", "SYS-002"]`; `covered_sys = {"SYS-001"}`
  * **Act**: Compute `pct = (1 * 100) / 2`
  * **Assert**: `pct` equals `50`

* **Unit Scenario: UTS-006-B4** (pct max: 100)
  * **Arrange**: Set `sys_ids = ["SYS-001"]`; `covered_sys = {"SYS-001"}`
  * **Act**: Compute `pct = (1 * 100) / 1`
  * **Assert**: `pct` equals `100`

* **Unit Scenario: UTS-006-B5** (pct max+1: impossible — capped at 100)
  * **Arrange**: Set `sys_ids = ["SYS-001"]`; `covered_sys = {"SYS-001", "SYS-002"}` (superset)
  * **Act**: Compute `pct`
  * **Assert**: `pct` equals `100` (covered cannot exceed total count)

#### Test Case: UTP-006-C (Equivalence Partitioning of in_decomposition flag)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions `in_decomposition` Boolean controlling section parser state.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system | ARCH-006 Interface | Stub: crafted content | Control section positioning |

* **Unit Scenario: UTS-006-C1** (valid partition: `in_decomposition = true`)
  * **Arrange**: Set parsing state inside `## Decomposition` section; line contains `SYS-001`
  * **Act**: Process line
  * **Assert**: `sys_ids` updated with `"SYS-001"`

* **Unit Scenario: UTS-006-C2** (valid partition: `in_decomposition = false`)
  * **Arrange**: Set parsing state before `## Decomposition`; line contains `SYS-001`
  * **Act**: Process line
  * **Assert**: `sys_ids` not updated; `"SYS-001"` not added

* **Unit Scenario: UTS-006-C3** (invalid partition: uninitialized)
  * **Arrange**: Skip `in_decomposition` initialization
  * **Act**: Attempt to evaluate conditional
  * **Assert**: Variable defaults to `false`; no rows processed

#### Test Case: UTP-006-D (Strict Isolation of file system)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies MOD-006 reads no real files.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system (system-design.md) | ARCH-006 Interface | Stub: in-memory string | No real file read |
| File system (system-test.md) | ARCH-006 Interface | Stub: in-memory string | No real file read |

* **Unit Scenario: UTS-006-D1** (Both files stubbed — full coverage path)
  * **Arrange**: Stub `sys_content` with Decomposition containing SYS-001; stub `test_content` with STP-001-A
  * **Act**: Call `check_backward_coverage(sys_path, test_path)`
  * **Assert**: `pct` equals `100`; zero file system calls

* **Unit Scenario: UTS-006-D2** (system-test.md not found)
  * **Arrange**: Stub `READ_FILE(system_test_path)` to skip (partial mode)
  * **Act**: Caller skips backward coverage entirely
  * **Assert**: Backward coverage not computed; no error raised

---

### Module: MOD-007 (Orphan Detection)

**Parent Architecture Modules**: ARCH-007
**Target Source File(s)**: `scripts/bash/validate-system-coverage.sh`

#### Test Case: UTP-007-A (Statement & Branch Coverage of detect_orphans)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises all branches: orphaned SYS detection (referencing non-existent REQ), orphaned STP detection (referencing non-existent SYS), system_test_path NULL bypass, and clean (no orphans) path.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system (READ_FILE) | ARCH-007 Interface | Stub: crafted content | Isolate from disk |

* **Unit Scenario: UTS-007-A1** (True path — orphaned SYS detected)
  * **Arrange**: Stub `valid_req_ids = {"REQ-001"}`; stub `sys_parent_map = {"SYS-001": ["REQ-001", "REQ-999"]}` (REQ-999 does not exist)
  * **Act**: Call `detect_orphans(req_path, sys_path, test_path)`
  * **Assert**: `orphaned_sys` contains `"SYS-001: references non-existent REQ-999"`

* **Unit Scenario: UTS-007-A2** (False path — no orphaned SYS)
  * **Arrange**: Stub `valid_req_ids = {"REQ-001", "REQ-002"}`; `sys_parent_map = {"SYS-001": ["REQ-001"]}`
  * **Act**: Call `detect_orphans(req_path, sys_path, test_path)`
  * **Assert**: `orphaned_sys` is empty

* **Unit Scenario: UTS-007-A3** (True path — orphaned STP detected)
  * **Arrange**: Stub `valid_sys_ids = {"SYS-001"}`; stub `test_content` with `STP-999-A` (parent SYS-999 not in valid_sys_ids)
  * **Act**: Call `detect_orphans(req_path, sys_path, test_path)`
  * **Assert**: `orphaned_stp` contains `"STP-999-A: parent SYS-999 not found in system-design.md"`

* **Unit Scenario: UTS-007-A4** (False path — system_test_path is NULL, skip STP orphan check)
  * **Arrange**: Set `system_test_path = NULL`
  * **Act**: Call `detect_orphans(req_path, sys_path, NULL)`
  * **Assert**: `orphaned_stp` is empty; STP detection block not entered

* **Unit Scenario: UTS-007-A5** (Clean path — no orphans of any kind)
  * **Arrange**: All REQ/SYS/STP IDs cross-reference correctly
  * **Act**: Call `detect_orphans(req_path, sys_path, test_path)`
  * **Assert**: `orphaned_sys` is empty; `orphaned_stp` is empty

* **Unit Scenario: UTS-007-A6** (Loop N — multiple orphaned SYS entries)
  * **Arrange**: 3 SYS entries each referencing different non-existent REQ IDs
  * **Act**: Call `detect_orphans(req_path, sys_path, test_path)`
  * **Assert**: `orphaned_sys` has 3 entries, one per orphaned SYS

#### Test Case: UTP-007-B (Strict Isolation of file system)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies MOD-007 reads no real files.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system (requirements.md) | ARCH-007 Interface | Stub: in-memory string | No real file |
| File system (system-design.md) | ARCH-007 Interface | Stub: in-memory string | No real file |
| File system (system-test.md) | ARCH-007 Interface | Stub: in-memory string or NULL | No real file |

* **Unit Scenario: UTS-007-B1** (All files stubbed)
  * **Arrange**: Stub all three file reads with in-memory content
  * **Act**: Call `detect_orphans(req_path, sys_path, test_path)`
  * **Assert**: Returns result without file system access

* **Unit Scenario: UTS-007-B2** (requirements.md not found)
  * **Arrange**: Stub `READ_FILE(requirements_path)` to throw file-not-found
  * **Act**: Call `detect_orphans(req_path, sys_path, test_path)`
  * **Assert**: File read error (exit 1)

---

### Module: MOD-008 (Validation CLI Argument Parser and Orchestrator)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `scripts/bash/validate-system-coverage.sh`

#### Test Case: UTP-008-A (Statement & Branch Coverage of main)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises all branches in `main()`: argument parsing (--json, --help, positional), missing vmodel_dir, required file checks, partial mode detection, orchestration of sub-functions, verdict aggregation, and exit code paths.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| check_forward_coverage (MOD-005) | ARCH-008 Interface | Stub: returns predefined CoverageResult | Isolate from sub-function |
| check_backward_coverage (MOD-006) | ARCH-008 Interface | Stub: returns predefined CoverageResult | Isolate from sub-function |
| detect_orphans (MOD-007) | ARCH-008 Interface | Stub: returns predefined OrphanResult | Isolate from sub-function |
| format_human_report / format_json_report (MOD-009) | ARCH-008 Interface | Stub: returns predefined string | Isolate from formatter |
| File system (FILE_EXISTS) | ARCH-008 Interface | Stub: returns true/false | Control file presence |

* **Unit Scenario: UTS-008-A1** (Argument parsing — `--json` flag)
  * **Arrange**: Set `args = ["--json", "/path/to/vmodel"]`
  * **Act**: Call `main(args)`
  * **Assert**: `json_mode` equals `true`; `vmodel_dir` equals `"/path/to/vmodel"`

* **Unit Scenario: UTS-008-A2** (Argument parsing — `--help` flag)
  * **Arrange**: Set `args = ["--help"]`
  * **Act**: Call `main(args)`
  * **Assert**: Usage message printed; returns exit code `0`

* **Unit Scenario: UTS-008-A3** (Error branch — missing vmodel_dir)
  * **Arrange**: Set `args = ["--json"]` (no positional arg)
  * **Act**: Call `main(args)`
  * **Assert**: `vmodel_dir` equals `NULL`; stderr: `"ERROR: vmodel-dir argument required"`; exit code `1`

* **Unit Scenario: UTS-008-A4** (Error branch — requirements.md not found)
  * **Arrange**: Set `args = ["/path/to/vmodel"]`; stub `FILE_EXISTS(requirements_path)` to return `false`
  * **Act**: Call `main(args)`
  * **Assert**: stderr: `"ERROR: requirements.md not found in /path/to/vmodel"`; exit code `1`

* **Unit Scenario: UTS-008-A5** (True path — partial_mode when system-test.md absent)
  * **Arrange**: Stub `FILE_EXISTS(system_test_path)` to return `false`
  * **Act**: Call `main(args)`
  * **Assert**: `partial_mode` equals `true`; `bwd_result` equals `NULL`; backward coverage skipped

* **Unit Scenario: UTS-008-A6** (False path — full mode when all files exist)
  * **Arrange**: Stub all `FILE_EXISTS` to return `true`; stub sub-functions
  * **Act**: Call `main(args)`
  * **Assert**: `partial_mode` equals `false`; both `fwd_result` and `bwd_result` populated

* **Unit Scenario: UTS-008-A7** (Verdict — has_gaps = true when forward coverage has uncovered)
  * **Arrange**: Stub `fwd_result = {uncovered: ["REQ-003"], pct: 80}`
  * **Act**: Call `main(args)` and aggregate results
  * **Assert**: `has_gaps` equals `true`; exit code `1`

* **Unit Scenario: UTS-008-A8** (Verdict — has_gaps = false when all clean)
  * **Arrange**: Stub all sub-functions returning empty gaps
  * **Act**: Call `main(args)` and aggregate results
  * **Assert**: `has_gaps` equals `false`; exit code `0`

#### Test Case: UTP-008-B (Equivalence Partitioning of Boolean flags)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions `json_mode` (Boolean), `partial_mode` (Boolean), and `has_gaps` (Boolean).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Sub-functions (MOD-005–009) | ARCH-008 Interface | Stub: predefined results | Isolate orchestrator |
| File system | ARCH-008 Interface | Stub: controlled presence | Control partial mode |

* **Unit Scenario: UTS-008-B1** (json_mode = true)
  * **Arrange**: Set `args = ["--json", "/path"]`; stub sub-functions
  * **Act**: Call `main(args)`
  * **Assert**: Output is JSON-formatted (starts with `{`); `format_json_report` invoked

* **Unit Scenario: UTS-008-B2** (json_mode = false)
  * **Arrange**: Set `args = ["/path"]` (no --json flag)
  * **Act**: Call `main(args)`
  * **Assert**: Output is human-readable (starts with `"==="`); `format_human_report` invoked

* **Unit Scenario: UTS-008-B3** (partial_mode = true)
  * **Arrange**: Stub `FILE_EXISTS(system_test_path)` to return `false`
  * **Act**: Call `main(args)`
  * **Assert**: `bwd_result` is `NULL`; orphan STP detection skipped

* **Unit Scenario: UTS-008-B4** (partial_mode = false)
  * **Arrange**: Stub `FILE_EXISTS(system_test_path)` to return `true`
  * **Act**: Call `main(args)`
  * **Assert**: `bwd_result` is populated; orphan STP detection executed

* **Unit Scenario: UTS-008-B5** (has_gaps = true)
  * **Arrange**: Stub fwd_result with `uncovered = ["REQ-001"]`
  * **Act**: Evaluate `has_gaps` aggregation
  * **Assert**: `has_gaps` equals `true`; exit code `1`

* **Unit Scenario: UTS-008-B6** (has_gaps = false)
  * **Arrange**: All sub-function results return empty gaps
  * **Act**: Evaluate `has_gaps` aggregation
  * **Assert**: `has_gaps` equals `false`; exit code `0`

#### Test Case: UTP-008-C (Strict Isolation of sub-functions and file system)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies MOD-008 orchestrates sub-functions without calling real implementations.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| check_forward_coverage (MOD-005) | ARCH-008 Interface | Stub: returns `{covered: ["REQ-001"], uncovered: [], pct: 100}` | No real coverage check |
| check_backward_coverage (MOD-006) | ARCH-008 Interface | Stub: returns `{covered: ["SYS-001"], uncovered: [], pct: 100}` | No real coverage check |
| detect_orphans (MOD-007) | ARCH-008 Interface | Stub: returns `{orphaned_sys: [], orphaned_stp: []}` | No real orphan detection |
| format_human_report (MOD-009) | ARCH-008 Interface | Stub: returns `"✅ Full coverage"` | No real formatting |
| File system (FILE_EXISTS) | ARCH-008 Interface | Stub: returns true | No real file check |

* **Unit Scenario: UTS-008-C1** (All sub-functions stubbed — nominal path)
  * **Arrange**: Configure all stubs as listed above
  * **Act**: Call `main(["/path/to/vmodel"])`
  * **Assert**: Exit code `0`; output contains `"✅ Full coverage"`; no real sub-function invoked

* **Unit Scenario: UTS-008-C2** (Sub-function failure isolation)
  * **Arrange**: Stub `check_forward_coverage` to return `{uncovered: ["REQ-003"], pct: 66}`
  * **Act**: Call `main(["/path/to/vmodel"])`
  * **Assert**: `has_gaps` equals `true`; exit code `1`; failure localized to forward coverage

---

### Module: MOD-009 (Validation Output Formatter)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `scripts/bash/validate-system-coverage.sh`

#### Test Case: UTP-009-A (Statement & Branch Coverage of format_human_report and format_json_report)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises all branches in both formatter functions: partial mode display, uncovered REQ display, uncovered SYS display, orphaned SYS/STP display, clean path, and JSON serialization.

**Dependency & Mock Registry:**

None — module is self-contained (pure functions taking structured parameters, returning strings).

* **Unit Scenario: UTS-009-A1** (Human report — partial mode, no gaps)
  * **Arrange**: Set `fwd = {pct: 100, uncovered: []}`, `bwd = NULL`, `orphans = {orphaned_sys: [], orphaned_stp: []}`, `partial = true`, `has_gaps = false`
  * **Act**: Call `format_human_report(fwd, bwd, orphans, partial, has_gaps)`
  * **Assert**: Output contains `"Forward coverage (REQ→SYS): 100%"`; contains `"SKIPPED (system-test.md not found)"`; contains `"Mode: PARTIAL VALIDATION"`; contains `"✅ Full system-level coverage (forward only — partial mode)"`

* **Unit Scenario: UTS-009-A2** (Human report — full mode with uncovered REQs)
  * **Arrange**: Set `fwd = {pct: 80, uncovered: ["REQ-003"]}`, `bwd = {pct: 100, uncovered: []}`, `orphans = {orphaned_sys: [], orphaned_stp: []}`, `partial = false`, `has_gaps = true`
  * **Act**: Call `format_human_report(fwd, bwd, orphans, partial, has_gaps)`
  * **Assert**: Output contains `"❌ Requirements WITHOUT system component mapping:"`; contains `"REQ-003: no system component mapping found"`

* **Unit Scenario: UTS-009-A3** (Human report — uncovered SYS components)
  * **Arrange**: Set `bwd = {pct: 50, uncovered: ["SYS-002"]}`, `has_gaps = true`
  * **Act**: Call `format_human_report(fwd, bwd, orphans, false, true)`
  * **Assert**: Output contains `"❌ System components WITHOUT test coverage:"`; contains `"SYS-002: no test case found"`

* **Unit Scenario: UTS-009-A4** (Human report — orphaned SYS)
  * **Arrange**: Set `orphans = {orphaned_sys: ["SYS-005: references non-existent REQ-999"], orphaned_stp: []}`
  * **Act**: Call `format_human_report(fwd, bwd, orphans, false, true)`
  * **Assert**: Output contains `"⚠️  Orphaned system components:"`; contains `"SYS-005: references non-existent REQ-999"`

* **Unit Scenario: UTS-009-A5** (Human report — orphaned STP)
  * **Arrange**: Set `orphans = {orphaned_sys: [], orphaned_stp: ["STP-999-A: parent SYS-999 not found"]}`
  * **Act**: Call `format_human_report(fwd, bwd, orphans, false, true)`
  * **Assert**: Output contains `"⚠️  Orphaned test cases:"`

* **Unit Scenario: UTS-009-A6** (Human report — full mode, no gaps)
  * **Arrange**: All results clean; `has_gaps = false`, `partial = false`
  * **Act**: Call `format_human_report(fwd, bwd, orphans, false, false)`
  * **Assert**: Output contains `"✅ Full system-level coverage"`; does NOT contain `"partial mode"`

* **Unit Scenario: UTS-009-A7** (JSON report — full mode with gaps)
  * **Arrange**: Set `fwd = {pct: 80, uncovered: ["REQ-003"]}`, `bwd = {pct: 100, uncovered: []}`, `partial = false`, `has_gaps = true`
  * **Act**: Call `format_json_report(fwd, bwd, orphans, partial, has_gaps)`
  * **Assert**: Output is valid JSON; `forward_coverage_pct` equals `80`; `uncovered_reqs` contains `"REQ-003"`; `has_gaps` equals `true`

* **Unit Scenario: UTS-009-A8** (JSON report — partial mode)
  * **Arrange**: Set `bwd = NULL`, `partial = true`
  * **Act**: Call `format_json_report(fwd, NULL, orphans, true, false)`
  * **Assert**: `backward_coverage_pct` equals `0`; `uncovered_sys` is `[]`; `partial_mode` equals `true`

---

### Module: MOD-010 (PowerShell Coverage Validation)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `scripts/powershell/validate-system-coverage.ps1`

#### Test Case: UTP-010-A (Statement & Branch Coverage of Validate-SystemCoverage)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises all branches in `Validate-SystemCoverage`: file validation, forward/backward coverage, orphan detection, partial mode, and output formatting.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system (GET_CONTENT) | ARCH-009 Interface | Stub: returns crafted strings | Isolate from disk |
| File system (TEST_PATH) | ARCH-009 Interface | Stub: returns true/false | Control file presence |

* **Unit Scenario: UTS-010-A1** (True path — all files exist, full validation)
  * **Arrange**: Stub `TEST_PATH` for all three files to return `$true`; stub content with matching IDs
  * **Act**: Call `Validate-SystemCoverage -VModelDir "/test"`
  * **Assert**: `PartialMode` equals `$false`; both forward and backward coverage computed

* **Unit Scenario: UTS-010-A2** (False path — system-test.md absent, partial mode)
  * **Arrange**: Stub `TEST_PATH(SystemTestPath)` to return `$false`
  * **Act**: Call `Validate-SystemCoverage -VModelDir "/test"`
  * **Assert**: `PartialMode` equals `$true`; backward coverage skipped

* **Unit Scenario: UTS-010-A3** (Error branch — requirements.md not found)
  * **Arrange**: Stub `TEST_PATH(RequirementsPath)` to return `$false`
  * **Act**: Call `Validate-SystemCoverage -VModelDir "/test"`
  * **Assert**: `Write-Error` called with `"ERROR: requirements.md not found"`; exit code `1`

* **Unit Scenario: UTS-010-A4** (Orphan detection — STP referencing non-existent SYS)
  * **Arrange**: Stub `SysIds = @("SYS-001")`; stub `StpIds = @("STP-001-A", "STP-999-B")`
  * **Act**: Execute orphan detection loop
  * **Assert**: `OrphanedStp` contains `"STP-999-B: parent SYS-999 not found"`

* **Unit Scenario: UTS-010-A5** (Verdict — HasGaps aggregation, all pass)
  * **Arrange**: All arrays empty (no gaps)
  * **Act**: Evaluate `HasGaps` expression
  * **Assert**: `HasGaps` equals `$false`; exit code `0`

#### Test Case: UTP-010-B (Boundary Value Analysis of FwdPct and BwdPct)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests boundaries of `FwdPct` and `BwdPct` (Int32, 0–100).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system | ARCH-009 Interface | Stub: crafted content | Control coverage ratios |

* **Unit Scenario: UTS-010-B1** (FwdPct min: 0 — no reqs covered)
  * **Arrange**: `AllReqIds = @("REQ-001")`; `CoveredReqs` empty
  * **Act**: Compute `FwdPct = (0 * 100) / 1`
  * **Assert**: `FwdPct` equals `0`

* **Unit Scenario: UTS-010-B2** (FwdPct mid: 50)
  * **Arrange**: `AllReqIds = @("REQ-001", "REQ-002")`; `CoveredReqs` contains `"REQ-001"` only
  * **Act**: Compute `FwdPct`
  * **Assert**: `FwdPct` equals `50`

* **Unit Scenario: UTS-010-B3** (FwdPct max: 100)
  * **Arrange**: `AllReqIds = @("REQ-001")`; `CoveredReqs` contains `"REQ-001"`
  * **Act**: Compute `FwdPct`
  * **Assert**: `FwdPct` equals `100`

* **Unit Scenario: UTS-010-B4** (BwdPct min: 0 — no SYS covered)
  * **Arrange**: `SysIds = @("SYS-001")`; `CoveredSys` empty
  * **Act**: Compute `BwdPct`
  * **Assert**: `BwdPct` equals `0`

* **Unit Scenario: UTS-010-B5** (BwdPct max: 100)
  * **Arrange**: `SysIds = @("SYS-001")`; `CoveredSys` contains `"SYS-001"`
  * **Act**: Compute `BwdPct`
  * **Assert**: `BwdPct` equals `100`

#### Test Case: UTP-010-C (Equivalence Partitioning of PartialMode and HasGaps)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions `PartialMode` (Boolean) and `HasGaps` (Boolean).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system (TEST_PATH) | ARCH-009 Interface | Stub: controlled returns | Control Boolean values |

* **Unit Scenario: UTS-010-C1** (PartialMode = $true)
  * **Arrange**: Stub `TEST_PATH(SystemTestPath)` to return `$false`
  * **Act**: Evaluate `PartialMode = NOT TEST_PATH(SystemTestPath)`
  * **Assert**: `PartialMode` equals `$true`; backward coverage block skipped

* **Unit Scenario: UTS-010-C2** (PartialMode = $false)
  * **Arrange**: Stub `TEST_PATH(SystemTestPath)` to return `$true`
  * **Act**: Evaluate `PartialMode`
  * **Assert**: `PartialMode` equals `$false`; backward coverage executed

* **Unit Scenario: UTS-010-C3** (HasGaps = $true)
  * **Arrange**: Set `UncoveredReqs.Count = 1`
  * **Act**: Evaluate `HasGaps` expression
  * **Assert**: `HasGaps` equals `$true`

* **Unit Scenario: UTS-010-C4** (HasGaps = $false)
  * **Arrange**: All gap arrays empty
  * **Act**: Evaluate `HasGaps` expression
  * **Assert**: `HasGaps` equals `$false`

#### Test Case: UTP-010-D (Strict Isolation of file system)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies MOD-010 reads no real files.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system (GET_CONTENT) | ARCH-009 Interface | Stub: in-memory strings | No real file read |
| File system (TEST_PATH) | ARCH-009 Interface | Stub: returns $true | No real path check |

* **Unit Scenario: UTS-010-D1** (All file operations stubbed)
  * **Arrange**: Stub `GET_CONTENT` for requirements, system-design, system-test with crafted content; stub `TEST_PATH` to return `$true` for all paths
  * **Act**: Call `Validate-SystemCoverage -VModelDir "/test"`
  * **Assert**: Returns result; zero real file system calls

* **Unit Scenario: UTS-010-D2** (Format output isolation)
  * **Arrange**: Stub all inputs; set `-Json` switch
  * **Act**: Call `Validate-SystemCoverage -VModelDir "/test" -Json`
  * **Assert**: Output is JSON format; no `WRITE_OUTPUT` to real stdout in test

---

### Module: MOD-011 (SYS/STP/STS ID Extraction)

**Parent Architecture Modules**: ARCH-010
**Target Source File(s)**: `scripts/bash/build-matrix.sh`

#### Test Case: UTP-011-A (Statement & Branch Coverage of extract_sys_stp_sts_ids)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises all branches: Decomposition section parsing, SYS ID + parent REQ extraction, STP/STS regex extraction, section boundary detection, and NULL/empty inputs.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system (READ_FILE) | ARCH-010 Interface | Stub: crafted content | Isolate from disk |

* **Unit Scenario: UTS-011-A1** (Nominal — SYS, STP, STS all present)
  * **Arrange**: Stub `sys_content` with Decomposition containing `SYS-001` referencing `REQ-001`; stub `test_content` with `STP-001-A` and `STS-001-A1`
  * **Act**: Call `extract_sys_stp_sts_ids(sys_path, test_path)`
  * **Assert**: `sys_entries` has 1 entry `{sys_id: "SYS-001", parent_reqs: ["REQ-001"]}`; `stp_entries` has 1 entry; `sts_entries` has 1 entry

* **Unit Scenario: UTS-011-A2** (SYS ID is NULL — regex finds no match in table row)
  * **Arrange**: Stub Decomposition row with `| Component A | desc | REQ-001 |` (no SYS-NNN pattern)
  * **Act**: Process row in extraction loop
  * **Assert**: Row skipped (CONTINUE); `sys_entries` not updated

* **Unit Scenario: UTS-011-A3** (NF-prefix REQ in parent_reqs_cell)
  * **Arrange**: Stub Decomposition row `| SYS-002 | ... | REQ-NF-001, REQ-CN-002 |`
  * **Act**: Call extraction
  * **Assert**: `sys_entries` entry for SYS-002 has `parent_reqs = ["REQ-NF-001", "REQ-CN-002"]`

* **Unit Scenario: UTS-011-A4** (Loop zero — no Decomposition rows)
  * **Arrange**: Stub `sys_content` with `## Decomposition View\n## Dependency View` (no rows)
  * **Act**: Call extraction
  * **Assert**: `sys_entries` is empty

* **Unit Scenario: UTS-011-A5** (Duplicate STP IDs — UNIQUE filtering)
  * **Arrange**: Stub `test_content` with `STP-001-A` appearing 3 times
  * **Act**: Call extraction
  * **Assert**: `stp_entries` has exactly 1 entry for `STP-001-A` (deduplicated)

#### Test Case: UTP-011-B (Equivalence Partitioning of in_decomposition flag)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions `in_decomposition` Boolean controlling Decomposition section parsing.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system | ARCH-010 Interface | Stub: crafted content | Control section positions |

* **Unit Scenario: UTS-011-B1** (valid partition: `in_decomposition = true`)
  * **Arrange**: Parser state inside Decomposition section; row contains `SYS-001`
  * **Act**: Process row
  * **Assert**: `sys_entries` updated with SYS-001 entry

* **Unit Scenario: UTS-011-B2** (valid partition: `in_decomposition = false`)
  * **Arrange**: Parser state before Decomposition section; row contains `SYS-001`
  * **Act**: Process row
  * **Assert**: Row ignored; `sys_entries` unchanged

* **Unit Scenario: UTS-011-B3** (invalid partition: uninitialized)
  * **Arrange**: Skip `in_decomposition` initialization
  * **Act**: Attempt conditional evaluation
  * **Assert**: Defaults to `false`; no rows processed

#### Test Case: UTP-011-C (Strict Isolation of file system)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies MOD-011 reads no real files.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system (system-design.md) | ARCH-010 Interface | Stub: in-memory string | No real file read |
| File system (system-test.md) | ARCH-010 Interface | Stub: in-memory string | No real file read |

* **Unit Scenario: UTS-011-C1** (Both files stubbed)
  * **Arrange**: Stub both files with crafted content
  * **Act**: Call `extract_sys_stp_sts_ids(sys_path, test_path)`
  * **Assert**: Returns structured entries; zero file system calls

* **Unit Scenario: UTS-011-C2** (system-test.md not found)
  * **Arrange**: Stub `READ_FILE(system_test_path)` to throw error
  * **Act**: Call extraction
  * **Assert**: Returns empty `stp_entries` and `sts_entries`

---

### Module: MOD-012 (Matrix B Table Construction)

**Parent Architecture Modules**: ARCH-011
**Target Source File(s)**: `scripts/bash/build-matrix.sh`

#### Test Case: UTP-012-A (Statement & Branch Coverage of build_matrix_b)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises all branches: lookup map construction, SYS with/without STP coverage, STP with/without STS scenarios, coverage percentage computation, and Markdown table formatting.

**Dependency & Mock Registry:**

None — module is self-contained (pure function taking structured data arrays as parameters).

* **Unit Scenario: UTS-012-A1** (Nominal — all SYS have STP and STS)
  * **Arrange**: Set `sys_entries = [{sys_id: "SYS-001", parent_reqs: ["REQ-001"]}]`; `stp_entries = [{stp_id: "STP-001-A", parent_sys: "SYS-001"}]`; `sts_entries = [{sts_id: "STS-001-A1", parent_stp: "STP-001-A"}]`
  * **Act**: Call `build_matrix_b(sys_entries, stp_entries, sts_entries)`
  * **Assert**: `rows` contains `{req: "REQ-001", sys: "SYS-001", stp: "STP-001-A", sts: "STS-001-A1"}`; `coverage_pct` equals `100`

* **Unit Scenario: UTS-012-A2** (True path — SYS with zero STP coverage)
  * **Arrange**: Set `sys_entries = [{sys_id: "SYS-002", parent_reqs: ["REQ-002"]}]`; `stp_entries = []`
  * **Act**: Call `build_matrix_b(sys_entries, stp_entries, sts_entries)`
  * **Assert**: `rows` contains `{stp: "⚠️ No test coverage", sts: "—"}`; `covered_sys` equals `0`

* **Unit Scenario: UTS-012-A3** (STP with zero STS scenarios)
  * **Arrange**: STP-001-A exists but `sts_entries = []`
  * **Act**: Call `build_matrix_b(sys_entries, stp_entries, sts_entries)`
  * **Assert**: `sts` column contains `"—"` for that row

* **Unit Scenario: UTS-012-A4** (Loop zero — empty sys_entries)
  * **Arrange**: Set `sys_entries = []`
  * **Act**: Call `build_matrix_b([], [], [])`
  * **Assert**: `rows` is empty; `coverage_pct` equals `0`; table has only headers

* **Unit Scenario: UTS-012-A5** (Loop N — many-to-many REQ→SYS→STP→STS)
  * **Arrange**: SYS-001 with parent_reqs `["REQ-001", "REQ-002"]`; STP-001-A and STP-001-B; STS-001-A1, STS-001-B1
  * **Act**: Call `build_matrix_b(sys_entries, stp_entries, sts_entries)`
  * **Assert**: `rows` has 4 entries (2 REQs × 2 STPs × 1 STS each); sorted by STP then STS

* **Unit Scenario: UTS-012-A6** (Markdown table format)
  * **Arrange**: Single row data
  * **Act**: Call `build_matrix_b` and inspect `output`
  * **Assert**: Output starts with `"| REQ | SYS | STP | STS |"` header; ends with `"Coverage: 100%"`

#### Test Case: UTP-012-B (Boundary Value Analysis of coverage_pct)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests boundaries of `coverage_pct` (Integer, 0–100).

**Dependency & Mock Registry:**

None — module is self-contained.

* **Unit Scenario: UTS-012-B1** (coverage_pct min-1: empty input → division guard)
  * **Arrange**: Set `sys_entries = []`; `total_sys = 0`
  * **Act**: Compute `coverage_pct`
  * **Assert**: `coverage_pct` equals `0` (guard: `total_sys == 0`)

* **Unit Scenario: UTS-012-B2** (coverage_pct min: 0)
  * **Arrange**: Set `sys_entries` with 1 entry; `stp_entries = []` (no coverage)
  * **Act**: Compute `coverage_pct = (0 * 100) / 1`
  * **Assert**: `coverage_pct` equals `0`

* **Unit Scenario: UTS-012-B3** (coverage_pct mid: 50)
  * **Arrange**: 2 sys_entries; 1 has STP coverage, 1 does not
  * **Act**: Compute `coverage_pct = (1 * 100) / 2`
  * **Assert**: `coverage_pct` equals `50`

* **Unit Scenario: UTS-012-B4** (coverage_pct max: 100)
  * **Arrange**: 1 sys_entry with STP coverage
  * **Act**: Compute `coverage_pct = (1 * 100) / 1`
  * **Assert**: `coverage_pct` equals `100`

* **Unit Scenario: UTS-012-B5** (coverage_pct max+1: impossible — capped at 100)
  * **Arrange**: `covered_sys` cannot exceed `total_sys` by construction
  * **Act**: Verify formula invariant
  * **Assert**: `coverage_pct` never exceeds `100`

---

### Module: MOD-013 (PowerShell Matrix B Builder)

**Parent Architecture Modules**: ARCH-012
**Target Source File(s)**: `scripts/powershell/build-matrix.ps1`

#### Test Case: UTP-013-A (Statement & Branch Coverage of Build-MatrixB)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises all branches mirroring MOD-011 + MOD-012 logic in PowerShell: SYS/STP/STS extraction, lookup table construction, gap annotation, and output formatting.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system (GET_CONTENT) | ARCH-012 Interface | Stub: crafted strings | Isolate from disk |

* **Unit Scenario: UTS-013-A1** (Nominal — full chain resolution)
  * **Arrange**: Stub `SysContent` with Decomposition containing SYS-001 → REQ-001; stub `TestContent` with STP-001-A, STS-001-A1
  * **Act**: Call `Build-MatrixB -SystemDesignPath $sysPath -SystemTestPath $testPath`
  * **Assert**: `Rows` contains complete chain `{Req: "REQ-001", Sys: "SYS-001", Stp: "STP-001-A", Sts: "STS-001-A1"}`

* **Unit Scenario: UTS-013-A2** (Gap — SYS with no STP)
  * **Arrange**: Stub SYS-002 in Decomposition; no matching STP
  * **Act**: Call `Build-MatrixB`
  * **Assert**: Row for SYS-002 has `Stp = "⚠️ No test coverage"`, `Sts = "—"`

* **Unit Scenario: UTS-013-A3** (STP with no STS)
  * **Arrange**: STP-001-A exists; `StsIds` has no match
  * **Act**: Call `Build-MatrixB`
  * **Assert**: `Stss` defaults to `@("—")`

* **Unit Scenario: UTS-013-A4** (Empty input files)
  * **Arrange**: Both files contain no matching IDs
  * **Act**: Call `Build-MatrixB`
  * **Assert**: `Rows` is empty; `CoveragePct` equals `0`

#### Test Case: UTP-013-B (Boundary Value Analysis of CoveragePct)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests boundaries of `CoveragePct` (Int32, 0–100).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system | ARCH-012 Interface | Stub: crafted content | Control coverage |

* **Unit Scenario: UTS-013-B1** (CoveragePct min: 0)
  * **Arrange**: `SysEntries.Count = 1`; `CoveredSys = 0`
  * **Act**: Compute `CoveragePct = (0 * 100) / 1`
  * **Assert**: `CoveragePct` equals `0`

* **Unit Scenario: UTS-013-B2** (CoveragePct mid: 50)
  * **Arrange**: `SysEntries.Count = 2`; `CoveredSys = 1`
  * **Act**: Compute `CoveragePct`
  * **Assert**: `CoveragePct` equals `50`

* **Unit Scenario: UTS-013-B3** (CoveragePct max: 100)
  * **Arrange**: `SysEntries.Count = 1`; `CoveredSys = 1`
  * **Act**: Compute `CoveragePct`
  * **Assert**: `CoveragePct` equals `100`

* **Unit Scenario: UTS-013-B4** (CoveragePct guard: 0 entries)
  * **Arrange**: `SysEntries.Count = 0`
  * **Act**: Compute `CoveragePct`
  * **Assert**: `CoveragePct` equals `0` (guard prevents division by zero)

* **Unit Scenario: UTS-013-B5** (CoveragePct max+1: impossible)
  * **Arrange**: `CoveredSys` cannot exceed `SysEntries.Count`
  * **Act**: Verify formula invariant
  * **Assert**: `CoveragePct` never exceeds `100`

#### Test Case: UTP-013-C (Strict Isolation of file system)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies MOD-013 reads no real files.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system (GET_CONTENT) | ARCH-012 Interface | Stub: in-memory strings | No real file read |

* **Unit Scenario: UTS-013-C1** (All files stubbed)
  * **Arrange**: Stub `GET_CONTENT` for system-design and system-test with crafted content
  * **Act**: Call `Build-MatrixB`
  * **Assert**: Returns result; no real file reads

* **Unit Scenario: UTS-013-C2** (File not found — system-design.md)
  * **Arrange**: Stub `GET_CONTENT(SystemDesignPath)` to throw terminating error
  * **Act**: Call `Build-MatrixB`
  * **Assert**: Terminating error propagated to caller

---

### Module: MOD-014 (Trace Command Matrix B Integration)

**Parent Architecture Modules**: ARCH-013
**Target Source File(s)**: `commands/trace.md`

#### Test Case: UTP-014-A (Statement & Branch Coverage of trace_command_matrix_b)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises all branches: both files present (generate Matrix B), one or both files absent (skip Matrix B), platform conditional (Bash vs PowerShell), and builder script failure.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| generate_matrix_a | ARCH-013 Interface | Stub: returns predefined Matrix A string | Isolate existing logic |
| RUN (build-matrix.sh/ps1) | ARCH-013 Interface | Stub: returns predefined output | Isolate script execution |
| PARSE_MATRIX_OUTPUT | ARCH-013 Interface | Stub: returns parsed table | Isolate parser |

* **Unit Scenario: UTS-014-A1** (True path — both files exist, Matrix B generated)
  * **Arrange**: Set `available_docs = ["system-design.md", "system-test.md"]`; `has_system_design = true`; `has_system_test = true`; stub builder to return `"| REQ | SYS | STP | STS |"`
  * **Act**: Call `trace_command_matrix_b(available_docs, vmodel_dir)`
  * **Assert**: Output contains `"## Matrix B — Verification (REQ → SYS → STP → STS)"`; `matrix_b` is not NULL

* **Unit Scenario: UTS-014-A2** (False path — system-design.md absent)
  * **Arrange**: Set `available_docs = ["system-test.md"]` (no system-design.md); `has_system_design = false`
  * **Act**: Call `trace_command_matrix_b(available_docs, vmodel_dir)`
  * **Assert**: `matrix_b` equals `NULL`; output contains only Matrix A

* **Unit Scenario: UTS-014-A3** (False path — system-test.md absent)
  * **Arrange**: Set `available_docs = ["system-design.md"]` (no system-test.md); `has_system_test = false`
  * **Act**: Call `trace_command_matrix_b(available_docs, vmodel_dir)`
  * **Assert**: `matrix_b` equals `NULL`; output contains only Matrix A

* **Unit Scenario: UTS-014-A4** (Error branch — builder script failure)
  * **Arrange**: Set both files present; stub `RUN("bash build-matrix.sh ...")` to return non-zero exit
  * **Act**: Call `trace_command_matrix_b(available_docs, vmodel_dir)`
  * **Assert**: Warning: `"Matrix B generation failed"`; output contains Matrix A only

* **Unit Scenario: UTS-014-A5** (Both files absent — v0.1.0 backward compatible)
  * **Arrange**: Set `available_docs = []`
  * **Act**: Call `trace_command_matrix_b(available_docs, vmodel_dir)`
  * **Assert**: Output contains Matrix A only; identical to v0.1.0 behavior

#### Test Case: UTP-014-B (Equivalence Partitioning of has_system_design and has_system_test)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions `has_system_design` (Boolean) and `has_system_test` (Boolean).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| generate_matrix_a | ARCH-013 Interface | Stub: returns string | Isolate |
| RUN | ARCH-013 Interface | Stub: returns output | Isolate |

* **Unit Scenario: UTS-014-B1** (has_system_design = true, has_system_test = true)
  * **Arrange**: Both entries in `available_docs`
  * **Act**: Evaluate conditionals
  * **Assert**: Matrix B generation block entered

* **Unit Scenario: UTS-014-B2** (has_system_design = true, has_system_test = false)
  * **Arrange**: Only system-design.md in `available_docs`
  * **Act**: Evaluate `has_system_design AND has_system_test`
  * **Assert**: Condition is `false`; Matrix B skipped

* **Unit Scenario: UTS-014-B3** (has_system_design = false, has_system_test = true)
  * **Arrange**: Only system-test.md in `available_docs`
  * **Act**: Evaluate conditionals
  * **Assert**: Condition is `false`; Matrix B skipped

* **Unit Scenario: UTS-014-B4** (has_system_design = false, has_system_test = false)
  * **Arrange**: Neither in `available_docs`
  * **Act**: Evaluate conditionals
  * **Assert**: Condition is `false`; Matrix B skipped; output identical to v0.1.0

#### Test Case: UTP-014-C (Strict Isolation of external dependencies)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies MOD-014 never calls real build-matrix scripts or generate_matrix_a.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| generate_matrix_a | ARCH-013 Interface | Stub: returns `"## Matrix A\n| REQ | ATP | SCN |"` | No real matrix generation |
| RUN (build-matrix.sh) | ARCH-013 Interface | Stub: returns `"| REQ-001 | SYS-001 | STP-001-A | STS-001-A1 |"` | No real script |
| PARSE_MATRIX_OUTPUT | ARCH-013 Interface | Stub: returns parsed string | No real parser |

* **Unit Scenario: UTS-014-C1** (All dependencies stubbed — nominal)
  * **Arrange**: Configure all stubs; set both files present
  * **Act**: Call `trace_command_matrix_b(available_docs, vmodel_dir)`
  * **Assert**: Output contains both Matrix A and Matrix B sections; no real scripts executed

* **Unit Scenario: UTS-014-C2** (Platform detection stub)
  * **Arrange**: Stub `PLATFORM` to return `"Linux"` (non-Windows)
  * **Act**: Call `trace_command_matrix_b(available_docs, vmodel_dir)`
  * **Assert**: Bash build-matrix.sh stub invoked (not PowerShell)

---

### Module: MOD-015 (SYS/STP/STS ID Pattern Registration)

**Parent Architecture Modules**: ARCH-014
**Target Source File(s)**: `evals/validators/id_validator.py`

#### Test Case: UTP-015-A (Statement & Branch Coverage of register_system_level_patterns and extract_lineage)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises all branches in both functions: pattern registration (adding SYS/STP/STS to existing dict), lineage extraction (valid STS ID parsing, invalid ID rejection), and idempotent re-registration.

**Dependency & Mock Registry:**

None — module is self-contained (pure functions operating on in-memory data structures).

* **Unit Scenario: UTS-015-A1** (Pattern registration — nominal)
  * **Arrange**: Set `existing_patterns = {"REQ": COMPILE_REGEX("^REQ-[0-9]{3}$"), "ATP": ..., "SCN": ...}`
  * **Act**: Call `register_system_level_patterns(existing_patterns)`
  * **Assert**: `updated_patterns` contains 6 keys: REQ, ATP, SCN, SYS, STP, STS; SYS_PATTERN matches `"SYS-001"`; STP_PATTERN matches `"STP-001-A"`; STS_PATTERN matches `"STS-001-A1"`

* **Unit Scenario: UTS-015-A2** (Idempotent re-registration)
  * **Arrange**: Set `existing_patterns` already containing SYS, STP, STS keys
  * **Act**: Call `register_system_level_patterns(existing_patterns)`
  * **Assert**: Patterns overwritten; `updated_patterns` still has 6 keys; no duplicates

* **Unit Scenario: UTS-015-A3** (Lineage extraction — valid STS ID)
  * **Arrange**: Set `sts_id = "STS-003-B2"`
  * **Act**: Call `extract_lineage("STS-003-B2")`
  * **Assert**: `parent_stp` equals `"STP-003-B"`; `parent_sys` equals `"SYS-003"`; `parent_req` equals `NULL`

* **Unit Scenario: UTS-015-A4** (Lineage extraction — invalid STS ID format)
  * **Arrange**: Set `sts_id = "STS-ABC-Z"` (letters instead of digits)
  * **Act**: Call `extract_lineage("STS-ABC-Z")`
  * **Assert**: Returns Error: `"Invalid STS ID format: STS-ABC-Z"`

* **Unit Scenario: UTS-015-A5** (Lineage extraction — completely malformed ID)
  * **Arrange**: Set `sts_id = "INVALID"`
  * **Act**: Call `extract_lineage("INVALID")`
  * **Assert**: Regex `^STS-[0-9]{3}-[A-Z][0-9]+$` does not match; returns Error

* **Unit Scenario: UTS-015-A6** (Pattern validation — SYS pattern boundary)
  * **Arrange**: Test pattern `SYS_PATTERN` against valid `"SYS-001"` and invalid `"SYS-1234"`
  * **Act**: Apply `REGEX_MATCH` for both inputs
  * **Assert**: `"SYS-001"` matches; `"SYS-1234"` does not match (only 3 digits allowed)

---

### Module: MOD-016 (Extension Manifest Entries)

**Parent Architecture Modules**: ARCH-015
**Target Source File(s)**: `extension.yml`

#### Test Case: UTP-016-A (Statement & Branch Coverage of update_extension_manifest)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises all branches: version bump, command registration, trace command description update, and assertion checks.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system (extension.yml) | ARCH-015 Interface | Stub: returns predefined YAML structure | Isolate from disk |

* **Unit Scenario: UTS-016-A1** (Version bump)
  * **Arrange**: Set `manifest.extension.version = "0.1.0"`
  * **Act**: Call `update_extension_manifest(manifest)`
  * **Assert**: `manifest.extension.version` equals `"0.2.0"`

* **Unit Scenario: UTS-016-A2** (System-design command registration)
  * **Arrange**: Set `manifest.provides.commands` with 3 existing entries
  * **Act**: Call `update_extension_manifest(manifest)`
  * **Assert**: `manifest.provides.commands` has 5 entries; entry at index 3 has `name = "speckit.v-model.system-design"` and `file = "commands/system-design.md"`

* **Unit Scenario: UTS-016-A3** (Trace command description update)
  * **Arrange**: Existing trace command with description `"Build traceability matrix"`
  * **Act**: Call `update_extension_manifest(manifest)` and iterate commands
  * **Assert**: Trace command description includes `"Includes Matrix B (Verification: REQ → SYS → STP → STS)"`

* **Unit Scenario: UTS-016-A4** (Assertion failure — command count != 5)
  * **Arrange**: Set `manifest.provides.commands` with 4 existing entries (one more than expected baseline)
  * **Act**: Call `update_extension_manifest(manifest)` — results in 6 commands after append
  * **Assert**: Assertion fails: `"Expected 5 commands (3 v0.1.0 + 2 new), got 6"`

* **Unit Scenario: UTS-016-A5** (Assertion failure — hook count != 1)
  * **Arrange**: Set `manifest.provides.hooks = []` (0 hooks)
  * **Act**: Call `update_extension_manifest(manifest)`
  * **Assert**: Assertion fails: `"Expected 1 hook, got 0"`

#### Test Case: UTP-016-B (Strict Isolation of file system)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies MOD-016 reads no real extension.yml from disk.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system (extension.yml) | ARCH-015 Interface | Stub: in-memory YAML structure | No real file read/write |

* **Unit Scenario: UTS-016-B1** (Manifest loaded from stub)
  * **Arrange**: Stub `manifest` with `{extension: {version: "0.1.0"}, provides: {commands: [...3 entries], hooks: [...1 entry]}}`
  * **Act**: Call `update_extension_manifest(manifest)`
  * **Assert**: Returns updated manifest; no file system operations

* **Unit Scenario: UTS-016-B2** (Manifest file not found)
  * **Arrange**: Stub file system to throw file-not-found for extension.yml
  * **Act**: Attempt to load manifest
  * **Assert**: Fatal error: `"manifest file missing"`

---

### Module: MOD-017 (CI Evaluation System Design Suite)

**Parent Architecture Modules**: ARCH-016
**Target Source File(s)**: `.github/workflows/evals.yml`

#### Test Case: UTP-017-A (Statement & Branch Coverage of extend_ci_evaluation_suite)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises all branches: system-design eval case definition with 7 quality checks, system-test eval case definition with 6 quality checks, and appending both to workflow matrix.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| CI workflow (evals.yml) | ARCH-016 Interface | Stub: in-memory YAML structure | Isolate from disk |

* **Unit Scenario: UTS-017-A1** (System-design eval case construction)
  * **Arrange**: Set `evals_workflow` with existing matrix containing v0.1.0 eval cases
  * **Act**: Call `extend_ci_evaluation_suite(evals_workflow)`
  * **Assert**: `system_design_eval.name` equals `"eval-system-design"`; `quality_checks` has 7 entries; first check `pattern` equals `"SYS-[0-9]{3}"`

* **Unit Scenario: UTS-017-A2** (System-test eval case construction)
  * **Arrange**: Same workflow input
  * **Act**: Call `extend_ci_evaluation_suite(evals_workflow)`
  * **Assert**: `system_test_eval.name` equals `"eval-system-test"`; `quality_checks` has 6 entries; contains BDD format check `"Given.*When.*Then"`

* **Unit Scenario: UTS-017-A3** (Appending to workflow matrix)
  * **Arrange**: `evals_workflow.jobs.evaluate.strategy.matrix.eval_case` has 2 existing entries
  * **Act**: Call `extend_ci_evaluation_suite(evals_workflow)`
  * **Assert**: `eval_case` array has 4 entries total (2 existing + 2 new)

* **Unit Scenario: UTS-017-A4** (Coverage gate quality check)
  * **Arrange**: Inspect `system_design_eval.quality_checks[6]`
  * **Act**: Validate check definition
  * **Assert**: `check` equals `"forward_coverage"`; `script` equals `"validate-system-coverage.sh"`; `exit_code` equals `0`

#### Test Case: UTP-017-B (Strict Isolation of CI workflow)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies MOD-017 modifies an in-memory workflow, not real CI files.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| CI workflow (evals.yml) | ARCH-016 Interface | Stub: in-memory YAML | No real file modification |
| CI fixture files | ARCH-016 Interface | Stub: file existence assumed | No real fixture access |

* **Unit Scenario: UTS-017-B1** (Workflow modified in-memory)
  * **Arrange**: Stub `evals_workflow` as in-memory YAML structure
  * **Act**: Call `extend_ci_evaluation_suite(evals_workflow)`
  * **Assert**: Returns modified YAML; no file writes to `.github/workflows/`

* **Unit Scenario: UTS-017-B2** (Fixture file missing — CI failure mode)
  * **Arrange**: Quality check references `"evals/fixtures/002-system-design/requirements.md"` which does not exist
  * **Act**: Evaluate quality check at CI runtime
  * **Assert**: CI job reports non-zero exit; fixture absence detected

---

### Module: MOD-018 (Backward Compatibility Guards)

**Parent Architecture Modules**: ARCH-017
**Target Source File(s)**: `tests/backward-compatibility.test.sh`

#### Test Case: UTP-018-A (Statement & Branch Coverage of enforce_backward_compatibility)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises all branches: baseline checksum capture, v0.2.0 operation execution, artifact integrity comparison, domain-agnostic command verification, and violation detection.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system (READ_FILE) | ARCH-017 Interface | Stub: returns predefined content | Isolate from disk |
| File system (FILE_EXISTS) | ARCH-017 Interface | Stub: returns true/false | Control artifact presence |
| SHA256 | ARCH-017 Interface | Stub: returns predefined hash strings | Isolate hash computation |
| RUN (speckit commands) | ARCH-017 Interface | Stub: no-op | Isolate from real command execution |

* **Unit Scenario: UTS-018-A1** (Nominal — all v0.1.0 artifacts unchanged)
  * **Arrange**: Stub `baseline_checksums = {"requirements.md": "abc123", "acceptance-plan.md": "def456", "traceability-matrix.md": "ghi789"}`; stub post-operation checksums to match
  * **Act**: Call `enforce_backward_compatibility()`
  * **Assert**: `violations` is empty; `pass` equals `true`

* **Unit Scenario: UTS-018-A2** (Violation — v0.1.0 artifact modified)
  * **Arrange**: Stub `baseline_checksums["requirements.md"] = "abc123"`; stub post-operation `SHA256` for requirements.md to return `"xyz999"` (different)
  * **Act**: Call `enforce_backward_compatibility()`
  * **Assert**: `violations` contains `"requirements.md: modified by v0.2.0 operation"`; `pass` equals `false`

* **Unit Scenario: UTS-018-A3** (True path — v0.1.0 artifact missing, skip checksum)
  * **Arrange**: Stub `FILE_EXISTS("traceability-matrix.md")` to return `false`
  * **Act**: Call `enforce_backward_compatibility()` Step 1 and Step 3
  * **Assert**: `baseline_checksums` does not contain `"traceability-matrix.md"`; comparison skipped for that artifact

* **Unit Scenario: UTS-018-A4** (Violation — safety standard reference in base command)
  * **Arrange**: Stub `READ_FILE("commands/system-design.md")` with content containing `"ISO 26262"` in the goal section
  * **Act**: Call `enforce_backward_compatibility()` Step 4
  * **Assert**: `violations` contains `"commands/system-design.md: contains safety standard references in base command"`

* **Unit Scenario: UTS-018-A5** (Clean — no safety references in base commands)
  * **Arrange**: Stub both command files with generic IEEE/ISO framing only
  * **Act**: Call `enforce_backward_compatibility()` Step 4
  * **Assert**: No domain-related violations added

* **Unit Scenario: UTS-018-A6** (Loop N — multiple violations)
  * **Arrange**: Stub requirements.md and acceptance-plan.md with modified checksums; stub system-design.md with safety reference
  * **Act**: Call `enforce_backward_compatibility()`
  * **Assert**: `violations` has 3 entries; `pass` equals `false`

#### Test Case: UTP-018-B (Strict Isolation of file system and hash functions)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies MOD-018 reads no real files and computes no real SHA-256 hashes.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| File system (READ_FILE) | ARCH-017 Interface | Stub: in-memory strings | No real file read |
| File system (FILE_EXISTS) | ARCH-017 Interface | Stub: returns true | No real path check |
| SHA256 | ARCH-017 Interface | Stub: returns fixed hash | No real hash computation |
| RUN (speckit commands) | ARCH-017 Interface | Stub: no-op | No real command execution |

* **Unit Scenario: UTS-018-B1** (All dependencies stubbed — nominal)
  * **Arrange**: Stub all file reads, existence checks, SHA256, and command runs
  * **Act**: Call `enforce_backward_compatibility()`
  * **Assert**: Returns `{pass: true, violations: []}`; zero real I/O operations

* **Unit Scenario: UTS-018-B2** (SHA256 isolation verified)
  * **Arrange**: Stub `SHA256` to return `"aaa"` for all files both before and after operations
  * **Act**: Call `enforce_backward_compatibility()`
  * **Assert**: All checksums match; `pass` equals `true`; no real crypto operations

---

## External Module Bypass

> No modules are tagged `[EXTERNAL]` — all 18 modules require unit test coverage.

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Modules (MOD) | 18 (18 active, 0 deprecated) |
| Modules tested | 18 (excludes [EXTERNAL]: 0) |
| Modules bypassed ([EXTERNAL]) | 0 |
| Total Test Cases (UTP) | 48 |
| Total Scenarios (UTS) | 200 |
| Modules with ≥1 UTP | 18 / 18 (100%) (active, non-[EXTERNAL] items only) |
| Test Cases with ≥1 UTS | 48 / 48 (100%) |
| **Overall Coverage (MOD→UTP)** | **100%** |

### Technique Distribution

| Technique | Test Cases | Percentage |
|-----------|-----------|------------|
| Statement & Branch Coverage | 18 | 37.5% |
| Boundary Value Analysis | 7 | 14.6% |
| Equivalence Partitioning | 8 | 16.7% |
| Strict Isolation | 15 | 31.2% |
| State Transition Testing | 0 | 0.0% |

> **State Transition Testing**: 0 test cases — all 18 modules are stateless (State Machine View is N/A for all modules).

## Uncovered Modules

None — full coverage achieved.
