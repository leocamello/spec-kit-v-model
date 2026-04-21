# Integration Test Plan: Architecture Design ↔ Integration Testing

**Feature Branch**: `003-architecture-integration`
**Created**: 2026-04-20
**Status**: Draft
**Source**: `specs/003-architecture-integration/v-model/architecture-design.md`

## Overview

This document defines the Integration Test Plan for the Architecture Design ↔ Integration Testing feature (v0.3.0). Every architecture module (`ARCH-001` through `ARCH-028`) in `architecture-design.md` has one or more Test Cases (ITP), and every Test Case has one or more executable Integration Scenarios (ITS) in module-boundary BDD format (Given/When/Then).

Integration tests verify **seams and handshakes between modules**, not internal logic or user journeys. All scenarios use module-boundary-oriented language referencing specific ARCH-NNN module pairs and their interface contracts.

Four mandatory ISO 29119-4 integration test techniques are applied: Interface Contract Testing, Data Flow Testing, Interface Fault Injection, and Concurrency & Race Condition Testing. Each test case is anchored to a specific architecture view from the design.

No domain overlay is configured — safety-critical sections are omitted.

## ID Schema

- **Integration Test Case**: `ITP-{NNN}-{X}` — where NNN matches the parent ARCH, X is a letter suffix (A, B, C, D)
- **Integration Test Scenario**: `ITS-{NNN}-{X}{#}` — nested under the parent ITP, with numeric suffix (1, 2, 3...)
- Example: `ITS-001-A1` → Scenario 1 of Test Case A verifying ARCH-001

## ISO 29119-4 Integration Test Techniques

Each test case MUST identify its technique by name and anchor to a specific architecture view:

| Technique | Source View | What It Tests |
|-----------|------------|---------------|
| **Interface Contract Testing** | Interface View | Module API contracts, data format compliance, error responses |
| **Data Flow Testing** | Data Flow View | End-to-end data transformation chain validation |
| **Interface Fault Injection** | Interface View + Process View | Malformed payloads, timeouts, graceful failure |
| **Concurrency & Race Condition Testing** | Process View | Simultaneous access, lock handling, queue ordering |

## Integration Tests

### Module Verification: ARCH-001 (SYS Component Extractor)

**Parent System Components**: SYS-001

#### Test Case: ITP-001-A (Contract Compliance — SYS Extraction Output)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-001 produces output conforming to its Interface View contract when receiving valid input from upstream, and that ARCH-002 can consume the output without transformation errors.

* **Integration Scenario: ITS-001-A1**
  * **Given** ARCH-001 (SYS Component Extractor) receives valid Markdown content containing a Decomposition View section with SYS-NNN table rows
  * **When** ARCH-001 sends the extracted `sys_components` array to ARCH-002 (Architecture Module Decomposer)
  * **Then** the output contains a non-empty array of `{id, name, description, parent_reqs, type}` objects matching the Interface View contract, and ARCH-002 accepts the payload without rejection

* **Integration Scenario: ITS-001-A2**
  * **Given** ARCH-001 receives Markdown content containing 50+ SYS identifiers in the Decomposition View
  * **When** ARCH-001 sends the extracted `sys_components` array to ARCH-002
  * **Then** the output array contains all 50+ components without truncation, and the `dependencies` and `interfaces` arrays are structurally valid per the Interface View contract

#### Test Case: ITP-001-B (Fault Injection — Empty Input Handling)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-001 handles malformed or empty input gracefully and returns the EMPTY_INPUT exception per its error contract, without propagating corruption to ARCH-002.

* **Integration Scenario: ITS-001-B1**
  * **Given** ARCH-001 (SYS Component Extractor) receives an empty Markdown string as `system_design_content`
  * **When** ARCH-001 attempts to extract SYS components and encounters zero SYS identifiers
  * **Then** ARCH-001 returns the EMPTY_INPUT exception with message "No system components found in system-design.md" and does not send any payload to ARCH-002

* **Integration Scenario: ITS-001-B2**
  * **Given** ARCH-001 receives Markdown content with no Decomposition View section
  * **When** ARCH-001 attempts to extract SYS components using patterns from ARCH-028 (ID Pattern Library)
  * **Then** ARCH-001 returns the EMPTY_INPUT exception and the `sys_components` array is not propagated downstream to ARCH-002

#### Test Case: ITP-001-C (Data Flow — System Design to Architecture Chain Stage 2)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies data transformation at Data Flow Chain "System Design to Architecture Design" Stage 2: Markdown input is correctly transformed into a structured SYS component list.

* **Integration Scenario: ITS-001-C1**
  * **Given** ARCH-028 (ID Pattern Library) has provided compiled SYS-NNN regex patterns to ARCH-001 at Data Flow Stage 1
  * **When** ARCH-001 transforms Markdown text (Decomposition View table, Dependency View table, Interface View tables) into structured data
  * **Then** the output format matches `[{id, name, description, parent_reqs, type}]` plus dependency and interface lists, conforming to Data Flow View Stage 2 output specification

---

### Module Verification: ARCH-002 (Architecture Module Decomposer)

**Parent System Components**: SYS-001

#### Test Case: ITP-002-A (Contract Compliance — Module Decomposition Output)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-002 receives SYS components from ARCH-001, produces ARCH module definitions per its contract, and that downstream view generators (ARCH-003 through ARCH-006) can consume the output.

* **Integration Scenario: ITS-002-A1**
  * **Given** ARCH-002 (Architecture Module Decomposer) receives a valid `sys_components` array from ARCH-001 (SYS Component Extractor) containing at least one component
  * **When** ARCH-002 sends the decomposed `arch_modules` array to ARCH-003 (Logical View Generator)
  * **Then** the output contains `{id, name, description, parent_sys[], type, tags[]}` objects with sequential ARCH-NNN IDs, and ARCH-003 accepts the payload without rejection

* **Integration Scenario: ITS-002-A2**
  * **Given** ARCH-002 receives SYS components that include cross-cutting concerns
  * **When** ARCH-002 sends the `cross_cutting_modules` subset to ARCH-003
  * **Then** each cross-cutting module has a `[CROSS-CUTTING]` tag with a non-empty rationale string, and ARCH-003 formats them correctly in the Logical View

#### Test Case: ITP-002-B (Fault Injection — Translator Violation)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-002 rejects decomposition attempts that would create capabilities not in system-design.md and halts on derived modules.

* **Integration Scenario: ITS-002-B1**
  * **Given** ARCH-002 receives a `sys_components` array from ARCH-001 that references capabilities not present in system-design.md
  * **When** ARCH-002 attempts to create a module that is neither SYS-traceable nor CROSS-CUTTING
  * **Then** ARCH-002 raises TRANSLATOR_VIOLATION error and does not send any `arch_modules` to ARCH-003 through ARCH-006

* **Integration Scenario: ITS-002-B2**
  * **Given** ARCH-002 identifies a technical module during decomposition that has no SYS parent and does not qualify as CROSS-CUTTING
  * **When** ARCH-002 encounters the derived module condition
  * **Then** ARCH-002 raises DERIVED_MODULE_HALT warning with the `[DERIVED MODULE: description]` flag and halts ID assignment for that module

#### Test Case: ITP-002-C (Data Flow — System Design to Architecture Chain Stage 3)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies data transformation at Data Flow Chain "System Design to Architecture Design" Stage 3: structured SYS components are correctly decomposed into ARCH module definitions.

* **Integration Scenario: ITS-002-C1**
  * **Given** ARCH-001 has produced structured SYS component list with dependency and interface data at Data Flow Stage 2
  * **When** ARCH-002 transforms the SYS components into ARCH module definitions and sends them to ARCH-003, ARCH-004, ARCH-005, and ARCH-006
  * **Then** the output format matches `[{id, name, description, parent_sys[], type, tags[]}]` with many-to-many SYS↔ARCH mappings preserved, conforming to Data Flow View Stage 3 output specification

---

### Module Verification: ARCH-003 (Logical View Generator)

**Parent System Components**: SYS-001

#### Test Case: ITP-003-A (Contract Compliance — Logical View Table Output)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-003 receives ARCH module definitions from ARCH-002 and template structure from ARCH-014, and produces a conformant Markdown Logical View table.

* **Integration Scenario: ITS-003-A1**
  * **Given** ARCH-003 (Logical View Generator) receives `arch_modules` from ARCH-002 (Architecture Module Decomposer) and `template_structure` from ARCH-014 (Architecture Template Structure)
  * **When** ARCH-003 generates the Logical View table
  * **Then** the output is a Markdown table with columns ARCH ID, Name, Description, Parent System Components, Type — and every SYS-NNN from the input appears in at least one row's Parent System Components column

#### Test Case: ITP-003-B (Fault Injection — Incomplete Coverage Detection)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-003 detects when SYS-NNN identifiers are missing from ARCH parent mappings and raises the INCOMPLETE_COVERAGE exception.

* **Integration Scenario: ITS-003-B1**
  * **Given** ARCH-003 receives `arch_modules` from ARCH-002 where SYS-005 has no corresponding ARCH parent in any module's `parent_sys` field
  * **When** ARCH-003 attempts to generate the Logical View table
  * **Then** ARCH-003 raises INCOMPLETE_COVERAGE error listing "SYS-005" as an uncovered system component, and the table generation halts

#### Test Case: ITP-003-C (Data Flow — System Design to Architecture Chain Stage 4)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies data transformation at Data Flow Chain "System Design to Architecture Design" Stage 4: ARCH module definitions are formatted into a Markdown Logical View table.

* **Integration Scenario: ITS-003-C1**
  * **Given** ARCH-002 has produced ARCH module definitions at Data Flow Stage 3 and ARCH-014 has provided the Logical View template format
  * **When** ARCH-003 transforms module definitions into Markdown table rows
  * **Then** the output format is a Markdown table with Parent System Components as comma-separated SYS-NNN lists, conforming to Data Flow View Stage 4 output specification

---

### Module Verification: ARCH-004 (Process View Generator)

**Parent System Components**: SYS-001

#### Test Case: ITP-004-A (Contract Compliance — Mermaid Sequence Diagram Output)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-004 receives module definitions and dependencies from ARCH-002, template format from ARCH-014, and produces syntactically valid Mermaid sequenceDiagram blocks.

* **Integration Scenario: ITS-004-A1**
  * **Given** ARCH-004 (Process View Generator) receives `arch_modules` and `dependencies` from ARCH-002 and `template_structure` from ARCH-014 (Architecture Template Structure)
  * **When** ARCH-004 generates Mermaid sequence diagrams
  * **Then** the output contains syntactically valid `sequenceDiagram` code blocks using ARCH-NNN as participant identifiers, with a concurrency model description per interaction path

#### Test Case: ITP-004-B (Fault Injection — Invalid Mermaid Detection)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-004 detects structurally invalid Mermaid output and raises the INVALID_MERMAID exception before propagating malformed diagrams.

* **Integration Scenario: ITS-004-B1**
  * **Given** ARCH-004 receives `dependencies` data from ARCH-002 containing circular reference paths
  * **When** ARCH-004 attempts to generate a sequenceDiagram that would produce invalid Mermaid syntax
  * **Then** ARCH-004 raises INVALID_MERMAID error with a syntax error description and does not output the malformed diagram block

#### Test Case: ITP-004-C (Data Flow — System Design to Architecture Chain Stage 5)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies data transformation at Data Flow Chain "System Design to Architecture Design" Stage 5: ARCH module definitions and dependency data are transformed into Mermaid code blocks.

* **Integration Scenario: ITS-004-C1**
  * **Given** ARCH-002 has produced ARCH module definitions with dependency data at Data Flow Stage 3 and ARCH-014 has provided the Process View template format
  * **When** ARCH-004 transforms module definitions and dependencies into Mermaid sequenceDiagram blocks
  * **Then** the output format contains valid Mermaid participant declarations and message syntax, conforming to Data Flow View Stage 5 output specification

---

### Module Verification: ARCH-005 (Interface View Generator)

**Parent System Components**: SYS-001

#### Test Case: ITP-005-A (Contract Compliance — API Contract Table Output)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-005 receives module definitions and system interface specs from ARCH-002/ARCH-001, template format from ARCH-014, and produces per-module contract tables without black-box descriptions.

* **Integration Scenario: ITS-005-A1**
  * **Given** ARCH-005 (Interface View Generator) receives `arch_modules` from ARCH-002, `sys_interfaces` from ARCH-001, and `template_structure` from ARCH-014
  * **When** ARCH-005 generates per-module contract tables
  * **Then** each ARCH-NNN module has a Markdown table with Direction, Name, Type, Format, and Constraints columns — no module is left without a contract table

#### Test Case: ITP-005-B (Fault Injection — Black Box Warning)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-005 raises BLACK_BOX_WARNING when a module description is too vague to derive inputs, outputs, and exceptions.

* **Integration Scenario: ITS-005-B1**
  * **Given** ARCH-005 receives an `arch_modules` entry from ARCH-002 with a description that contains no actionable input/output specification
  * **When** ARCH-005 attempts to derive a contract table for the vague module
  * **Then** ARCH-005 raises BLACK_BOX_WARNING identifying the ARCH-NNN ID and the missing contract details, and the contract table is flagged as incomplete

#### Test Case: ITP-005-C (Data Flow — System Design to Architecture Chain Stage 6)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies data transformation at Data Flow Chain "System Design to Architecture Design" Stage 6: module definitions and system interface specs are transformed into per-module contract tables.

* **Integration Scenario: ITS-005-C1**
  * **Given** ARCH-002 has produced ARCH module definitions at Data Flow Stage 3 and ARCH-001 has provided system interface specifications
  * **When** ARCH-005 transforms module definitions and interface specs into per-module Markdown contract tables
  * **Then** the output format includes Direction, Name, Type, Format, Constraints columns per ARCH module, conforming to Data Flow View Stage 6 output specification

---

### Module Verification: ARCH-006 (Data Flow View Generator)

**Parent System Components**: SYS-001

#### Test Case: ITP-006-A (Contract Compliance — Data Transformation Chain Output)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-006 receives module definitions and dependencies from ARCH-002, template format from ARCH-014, and produces data transformation chain tables showing intermediate formats.

* **Integration Scenario: ITS-006-A1**
  * **Given** ARCH-006 (Data Flow View Generator) receives `arch_modules` and `dependencies` from ARCH-002 and `template_structure` from ARCH-014
  * **When** ARCH-006 generates data flow tables
  * **Then** the output contains Markdown tables with Stage, Module (ARCH-NNN reference), Input Format, Transformation, and Output Format columns showing intermediate data formats at each stage

#### Test Case: ITP-006-B (Fault Injection — Disconnected Module Warning)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-006 raises DISCONNECTED_MODULE warning when a module has no data flow connections.

* **Integration Scenario: ITS-006-B1**
  * **Given** ARCH-006 receives `arch_modules` from ARCH-002 where ARCH-NNN has no incoming or outgoing data flow connections in the dependency data
  * **When** ARCH-006 attempts to trace data through the disconnected module
  * **Then** ARCH-006 raises DISCONNECTED_MODULE warning identifying the ARCH-NNN ID, and the module is excluded from transformation chain tables

#### Test Case: ITP-006-C (Data Flow — System Design to Architecture Chain Stage 7)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies data transformation at Data Flow Chain "System Design to Architecture Design" Stage 7: module definitions and dependency paths are traced into data flow tables.

* **Integration Scenario: ITS-006-C1**
  * **Given** ARCH-002 has produced ARCH module definitions with dependency paths at Data Flow Stage 3 and ARCH-014 has provided the Data Flow View template format
  * **When** ARCH-006 transforms dependency paths into data flow tables with stage-by-stage transformation descriptions
  * **Then** the output format shows input→transformation→output at each stage with intermediate formats, conforming to Data Flow View Stage 7 output specification

---

### Module Verification: ARCH-007 (Architecture Design Parser)

**Parent System Components**: SYS-002

#### Test Case: ITP-007-A (Contract Compliance — Architecture View Extraction)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-007 parses architecture-design.md using patterns from ARCH-028 and sends structured ARCH module data with all four view structures to ARCH-008.

* **Integration Scenario: ITS-007-A1**
  * **Given** ARCH-007 (Architecture Design Parser) receives Markdown content of architecture-design.md containing all four mandatory views and compiled regex patterns from ARCH-028 (ID Pattern Library)
  * **When** ARCH-007 sends the parsed `arch_modules`, `process_view`, `interface_view`, and `data_flow_view` to ARCH-008 (Integration Test Case Generator)
  * **Then** the output preserves many-to-many SYS↔ARCH mappings and CROSS-CUTTING tags, and ARCH-008 accepts the structured data without rejection

#### Test Case: ITP-007-B (Fault Injection — Missing Mandatory View)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-007 raises MISSING_VIEW when a mandatory architecture view is absent from the input.

* **Integration Scenario: ITS-007-B1**
  * **Given** ARCH-007 receives architecture-design.md content that is missing the Interface View section
  * **When** ARCH-007 attempts to parse all four mandatory views
  * **Then** ARCH-007 raises MISSING_VIEW error identifying "Interface View" as the absent view, and does not send incomplete data to ARCH-008

#### Test Case: ITP-007-C (Data Flow — Architecture to Integration Chain Stage 2)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies data transformation at Data Flow Chain "Architecture Design to Integration Tests" Stage 2: Markdown architecture design is parsed into structured module list with view data.

* **Integration Scenario: ITS-007-C1**
  * **Given** ARCH-028 has provided compiled ARCH-NNN regex patterns at Data Flow Stage 1
  * **When** ARCH-007 transforms Markdown content (Logical View table, Process View Mermaid blocks, Interface View contract tables, Data Flow View tables) into structured data
  * **Then** the output format matches `[{id, name, parent_sys, type, process_interactions, interface_contracts, data_flows}]`, conforming to Data Flow View Stage 2 output specification

---

### Module Verification: ARCH-008 (Integration Test Case Generator)

**Parent System Components**: SYS-002

#### Test Case: ITP-008-A (Contract Compliance — Test Case Generation with Technique Assignment)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-008 receives ARCH modules and view data from ARCH-007, template from ARCH-015, and produces ITP-NNN-X test cases with correct technique-to-view anchoring.

* **Integration Scenario: ITS-008-A1**
  * **Given** ARCH-008 (Integration Test Case Generator) receives structured ARCH module data from ARCH-007 (Architecture Design Parser) and test case template from ARCH-015 (Integration Test Template Structure)
  * **When** ARCH-008 sends generated `test_cases` array to ARCH-009 (Integration Test Scenario Generator)
  * **Then** each test case has format `{id: ITP-NNN-X, parent_arch, technique, anchored_view, description}` where NNN matches the parent ARCH number, and every ARCH-NNN (including CROSS-CUTTING) has at least one test case

#### Test Case: ITP-008-B (Fault Injection — No Technique Match Warning)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-008 raises NO_TECHNIQUE_MATCH when a module's view data is insufficient to assign a technique.

* **Integration Scenario: ITS-008-B1**
  * **Given** ARCH-008 receives an ARCH module from ARCH-007 whose view data contains no interface contracts, no data flow entries, and no process interactions
  * **When** ARCH-008 attempts to assign an ISO 29119-4 technique to the module
  * **Then** ARCH-008 raises NO_TECHNIQUE_MATCH warning identifying the ARCH-NNN ID and includes the warning in its output to ARCH-009

#### Test Case: ITP-008-C (Data Flow — Architecture to Integration Chain Stage 3)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies data transformation at Data Flow Chain "Architecture Design to Integration Tests" Stage 3: structured ARCH modules are mapped to ITP test case definitions with techniques.

* **Integration Scenario: ITS-008-C1**
  * **Given** ARCH-007 has produced structured ARCH module list with view data at Data Flow Stage 2
  * **When** ARCH-008 transforms ARCH modules into ITP-NNN-X test case definitions, mapping Interface View to Contract Testing + Fault Injection, Data Flow View to Data Flow Testing, and Process View to Concurrency Testing
  * **Then** the output format matches `[{id, parent_arch, technique, anchored_view, description}]`, conforming to Data Flow View Stage 3 output specification

---

### Module Verification: ARCH-009 (Integration Test Scenario Generator)

**Parent System Components**: SYS-002

#### Test Case: ITP-009-A (Contract Compliance — BDD Scenario Generation)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-009 receives test cases from ARCH-008, template from ARCH-015, and produces ITS-NNN-X# scenarios in Given/When/Then format with module-boundary language.

* **Integration Scenario: ITS-009-A1**
  * **Given** ARCH-009 (Integration Test Scenario Generator) receives `test_cases` from ARCH-008 (Integration Test Case Generator) and `template_structure` from ARCH-015
  * **When** ARCH-009 generates BDD test scenarios
  * **Then** each scenario has format `{id: ITS-NNN-X#, parent_itp, given, when, then}` using module-boundary language only, with zero user-journey or internal-logic phrases

#### Test Case: ITP-009-B (Fault Injection — Scope Violation Detection)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-009 detects when a generated scenario tests internal logic or user journeys instead of module boundaries.

* **Integration Scenario: ITS-009-B1**
  * **Given** ARCH-009 receives test case definitions from ARCH-008 that would produce scenarios containing user-centric language
  * **When** ARCH-009 applies the scope violation check during scenario generation
  * **Then** ARCH-009 raises SCOPE_VIOLATION warning identifying the ITS-NNN-X# ID with the prohibited phrase, and the scenario is flagged for revision

#### Test Case: ITP-009-C (Data Flow — Architecture to Integration Chain Stage 4)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies data transformation at Data Flow Chain "Architecture Design to Integration Tests" Stage 4: ITP test case definitions are transformed into BDD scenarios.

* **Integration Scenario: ITS-009-C1**
  * **Given** ARCH-008 has produced ITP-NNN-X test case definitions at Data Flow Stage 3
  * **When** ARCH-009 transforms test case definitions into ITS-NNN-X# BDD scenarios with Given (boundary precondition), When (interaction trigger), Then (expected boundary behavior)
  * **Then** the output format matches `[{id, parent_itp, given, when, then}]` with module-boundary language, conforming to Data Flow View Stage 4 output specification

#### Test Case: ITP-009-D (Concurrency — Coverage Gate Blocking Call)

**Technique**: Concurrency & Race Condition Testing
**Target View**: Process View
**Description**: Verifies that the coverage gate invocation is a blocking synchronous call — ARCH-009 waits for ARCH-010, ARCH-011, and ARCH-013 to complete before including results in output.

* **Integration Scenario: ITS-009-D1**
  * **Given** ARCH-009 has completed scenario generation and initiates the coverage gate by invoking ARCH-010 (Forward Coverage Validator) and ARCH-011 (Backward Coverage Validator)
  * **When** the coverage gate subprocess is executing and has not yet returned its exit code
  * **Then** ARCH-009 blocks and does not produce final output until ARCH-013 (Coverage Report Formatter) returns the formatted report with pass/fail verdict

---

### Module Verification: ARCH-010 (Forward Coverage Validator)

**Parent System Components**: SYS-003, SYS-010

#### Test Case: ITP-010-A (Contract Compliance — Forward SYS-to-ARCH Validation)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-010 receives file paths, extracts SYS-NNN and ARCH-NNN IDs, and produces forward coverage data conforming to its output contract.

* **Integration Scenario: ITS-010-A1**
  * **Given** ARCH-010 (Forward Coverage Validator) receives valid file paths to system-design.md and architecture-design.md
  * **When** ARCH-010 sends the forward coverage result to ARCH-013 (Coverage Report Formatter)
  * **Then** the output contains `{sys_ids[], covered_sys[], uncovered_sys[], coverage_pct}` with deduplicated, sorted arrays and coverage percentage between 0 and 100

#### Test Case: ITP-010-B (Fault Injection — File Not Found)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-010 raises FILE_NOT_FOUND when an input file does not exist and returns exit code 1.

* **Integration Scenario: ITS-010-B1**
  * **Given** ARCH-010 receives a `system_design_path` pointing to a non-existent file
  * **When** ARCH-010 attempts to read the file for SYS-NNN extraction
  * **Then** ARCH-010 raises FILE_NOT_FOUND error with the file path and returns exit code 1 to the calling process, and does not send partial data to ARCH-013

#### Test Case: ITP-010-C (Data Flow — Coverage Validation Chain Stage 2)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies data transformation at Data Flow Chain "Coverage Validation" Stage 2: Markdown files are transformed into forward coverage data.

* **Integration Scenario: ITS-010-C1**
  * **Given** ARCH-028 has provided compiled SYS-NNN and ARCH-NNN regex patterns at Data Flow Stage 1
  * **When** ARCH-010 transforms system-design.md (Decomposition View section) and architecture-design.md (Logical View section) by regex extraction and cross-referencing via Parent System Components column
  * **Then** the output format matches `{sys_ids[], covered_sys[], uncovered_sys[], coverage_pct}`, conforming to Data Flow View Stage 2 output specification

#### Test Case: ITP-010-D (Concurrency — Synchronous Validation Pass Execution)

**Technique**: Concurrency & Race Condition Testing
**Target View**: Process View
**Description**: Verifies that ARCH-010 executes as Pass 1 in the coverage validation sequence and completes before ARCH-011 (Pass 2) begins processing, ensuring no shared state corruption.

* **Integration Scenario: ITS-010-D1**
  * **Given** the CLI invocation has loaded ID regex patterns from ARCH-028 and initiates the coverage validation sequence
  * **When** ARCH-010 (Pass 1 - Forward Coverage) executes and ARCH-011 (Pass 2 - Backward Coverage) is queued
  * **Then** ARCH-010 completes and returns its forward result to the CLI before ARCH-011 begins reading architecture-design.md, ensuring sequential pass ordering per the Process View

---

### Module Verification: ARCH-011 (Backward Coverage Validator)

**Parent System Components**: SYS-003, SYS-010

#### Test Case: ITP-011-A (Contract Compliance — Backward ARCH-to-ITP Validation)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-011 receives file paths, extracts ARCH-NNN and ITP-NNN-X IDs via lineage encoding, and produces backward coverage data conforming to its output contract.

* **Integration Scenario: ITS-011-A1**
  * **Given** ARCH-011 (Backward Coverage Validator) receives valid file paths to architecture-design.md and integration-test.md
  * **When** ARCH-011 sends the backward coverage result to ARCH-013 (Coverage Report Formatter)
  * **Then** the output contains `{arch_ids[], covered_arch[], uncovered_arch[], coverage_pct}` with deduplicated, sorted arrays and ID lineage substring matching correctly maps ITP-NNN-X to ARCH-NNN

#### Test Case: ITP-011-B (Fault Injection — Partial Mode When Integration Test Missing)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-011 enters partial mode when integration-test.md is absent and reports PARTIAL_MODE info without failing.

* **Integration Scenario: ITS-011-B1**
  * **Given** ARCH-011 receives a valid `arch_design_path` but `integration_test_path` points to a non-existent file
  * **When** ARCH-011 detects the missing integration-test.md
  * **Then** ARCH-011 enters partial mode with `coverage_pct` = 0, `uncovered_arch` is empty, and reports PARTIAL_MODE info "integration-test.md not found" to ARCH-013 without triggering a failure exit code

#### Test Case: ITP-011-C (Data Flow — Coverage Validation Chain Stage 3)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies data transformation at Data Flow Chain "Coverage Validation" Stage 3: Markdown files are transformed into backward coverage data via ID lineage matching.

* **Integration Scenario: ITS-011-C1**
  * **Given** ARCH-010 has completed forward coverage validation at Data Flow Stage 2
  * **When** ARCH-011 transforms architecture-design.md (Logical View) and integration-test.md (ITP identifiers) by regex extraction and ID lineage substring matching
  * **Then** the output format matches `{arch_ids[], covered_arch[], uncovered_arch[], coverage_pct}`, conforming to Data Flow View Stage 3 output specification

---

### Module Verification: ARCH-012 (Orphan and Circular Dependency Detector)

**Parent System Components**: SYS-003, SYS-010

#### Test Case: ITP-012-A (Contract Compliance — Orphan and Cycle Detection Output)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-012 receives SYS IDs from ARCH-010, ARCH data from the architecture design, and ITP IDs from ARCH-011, and produces orphan/circular dependency results per its contract.

* **Integration Scenario: ITS-012-A1**
  * **Given** ARCH-012 (Orphan and Circular Dependency Detector) receives `sys_ids` from ARCH-010, `arch_data` with parent mappings and cross-cutting flags, and `itp_ids` from ARCH-011
  * **When** ARCH-012 sends its detection results to ARCH-013 (Coverage Report Formatter)
  * **Then** the output contains `{orphaned_arch[], orphaned_itps[], circular_deps[]}` where CROSS-CUTTING modules are excluded from orphan detection, and ARCH-012 completes without exception

* **Integration Scenario: ITS-012-A2**
  * **Given** ARCH-012 receives `arch_data` where ARCH-NNN references a non-existent SYS-NNN and ARCH-NNN is not tagged CROSS-CUTTING
  * **When** ARCH-012 performs orphan detection
  * **Then** the `orphaned_arch` array contains the ARCH-NNN entry with the unknown SYS reference, and the result is sent to ARCH-013

#### Test Case: ITP-012-B (Fault Injection — Partial Mode Handling)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-012 operates correctly in partial mode when ITP IDs are empty (integration-test.md absent).

* **Integration Scenario: ITS-012-B1**
  * **Given** ARCH-012 receives an empty `itp_ids` array due to partial mode from ARCH-011
  * **When** ARCH-012 attempts ITP orphan detection with no ITP identifiers
  * **Then** the `orphaned_itps` array is empty and ARCH-012 completes successfully without false positives, sending valid results to ARCH-013

#### Test Case: ITP-012-C (Data Flow — Coverage Validation Chain Stage 4)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies data transformation at Data Flow Chain "Coverage Validation" Stage 4: SYS ID list, ARCH parent mappings, and ITP IDs are cross-referenced to detect orphans and cycles.

* **Integration Scenario: ITS-012-C1**
  * **Given** ARCH-010 has provided SYS IDs and ARCH-011 has provided ITP IDs at Data Flow Stages 2-3
  * **When** ARCH-012 cross-references ARCH parents against known SYS IDs (excluding CROSS-CUTTING), cross-references ITP parents against known ARCH IDs, and scans the Process View for circular references
  * **Then** the output format matches `{orphaned_arch[], orphaned_itps[], circular_deps[]}`, conforming to Data Flow View Stage 4 output specification

---

### Module Verification: ARCH-013 (Coverage Report Formatter)

**Parent System Components**: SYS-003, SYS-010

#### Test Case: ITP-013-A (Contract Compliance — Report Formatting Output)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-013 receives results from ARCH-010, ARCH-011, and ARCH-012, and produces a human-readable or JSON-formatted coverage report with correct pass/fail verdict.

* **Integration Scenario: ITS-013-A1**
  * **Given** ARCH-013 (Coverage Report Formatter) receives `forward_result` from ARCH-010, `backward_result` from ARCH-011, and `orphan_result` from ARCH-012 with `json_mode` = false
  * **When** ARCH-013 formats the report
  * **Then** the output is a human-readable gap report listing each gap/orphan by specific ID, with computed coverage percentages and exit code 0 when all checks pass

* **Integration Scenario: ITS-013-A2**
  * **Given** ARCH-013 receives results where `forward_result` has `uncovered_sys` containing SYS-003
  * **When** ARCH-013 formats the report with `json_mode` = true
  * **Then** the output is a JSON object listing "SYS-003: no architecture module mapping found" and exit code 1

#### Test Case: ITP-013-B (Fault Injection — Graceful Handling of All Inputs)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-013 always produces output regardless of input completeness and correctly determines exit code.

* **Integration Scenario: ITS-013-B1**
  * **Given** ARCH-013 receives a `backward_result` in partial mode (coverage_pct = 0, empty uncovered list) from ARCH-011
  * **When** ARCH-013 formats the combined report
  * **Then** ARCH-013 produces output noting partial backward coverage without treating it as a failure, and exit code reflects only the non-partial checks

#### Test Case: ITP-013-C (Data Flow — Coverage Validation Chain Stage 5)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies data transformation at Data Flow Chain "Coverage Validation" Stage 5: forward, backward, and orphan results are aggregated into a formatted report.

* **Integration Scenario: ITS-013-C1**
  * **Given** ARCH-010, ARCH-011, and ARCH-012 have produced their respective results at Data Flow Stages 2-4
  * **When** ARCH-013 aggregates all results, computes coverage percentages, and determines the pass/fail verdict
  * **Then** the output is a formatted report string with exit code (0 or 1), conforming to Data Flow View Stage 5 output specification

#### Test Case: ITP-013-D (Concurrency — Sequential Report Assembly)

**Technique**: Concurrency & Race Condition Testing
**Target View**: Process View
**Description**: Verifies that ARCH-013 receives results from all three validation passes in correct sequential order and the formatted report reflects the complete validation state.

* **Integration Scenario: ITS-013-D1**
  * **Given** the coverage validation sequence has completed Pass 1 (ARCH-010), Pass 2 (ARCH-011), and Pass 3 (ARCH-012) sequentially
  * **When** ARCH-013 receives all three results and assembles the report
  * **Then** the exit code (0 or 1) is the synchronization signal to the calling process, and the report reflects the complete state of all validation passes without partial or stale data

---

### Module Verification: ARCH-014 (Architecture Template Structure)

**Parent System Components**: SYS-004

#### Test Case: ITP-014-A (Contract Compliance — Template Content Delivery)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-014 receives a file read request and returns the architecture design template content with all four mandatory view sections to ARCH-003, ARCH-004, ARCH-005, and ARCH-006.

* **Integration Scenario: ITS-014-A1**
  * **Given** ARCH-003 (Logical View Generator) sends a file read request for `templates/architecture-design-template.md` to ARCH-014 (Architecture Template Structure)
  * **When** ARCH-014 returns the `template_content` to ARCH-003
  * **Then** the content contains Markdown section headers for Logical View, Process View, Interface View, and Data Flow View with HTML comment field definitions and placeholder tables

#### Test Case: ITP-014-B (Fault Injection — Template Not Found)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-014 raises TEMPLATE_NOT_FOUND when the template file is missing from the extension distribution.

* **Integration Scenario: ITS-014-B1**
  * **Given** ARCH-003 sends a file read request to ARCH-014 but the template file does not exist at the expected path in the extension distribution
  * **When** ARCH-014 attempts to read the template file
  * **Then** ARCH-014 raises TEMPLATE_NOT_FOUND error with the file path, and ARCH-003 does not proceed with Logical View generation

---

### Module Verification: ARCH-015 (Integration Test Template Structure)

**Parent System Components**: SYS-005

#### Test Case: ITP-015-A (Contract Compliance — Test Template Content Delivery)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-015 receives a file read request and returns the integration test template content with the three-tier ITP/ITS hierarchy to ARCH-008 and ARCH-009.

* **Integration Scenario: ITS-015-A1**
  * **Given** ARCH-008 (Integration Test Case Generator) sends a file read request for `templates/integration-test-template.md` to ARCH-015 (Integration Test Template Structure)
  * **When** ARCH-015 returns the `template_content` to ARCH-008
  * **Then** the content contains the three-tier ITP/ITS hierarchy (ARCH→ITP-NNN-X→ITS-NNN-X#), technique naming fields, Given/When/Then BDD format placeholders, and a Test Harness & Mocking Strategy section

#### Test Case: ITP-015-B (Fault Injection — Template Not Found)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-015 raises TEMPLATE_NOT_FOUND when the template file is missing from the extension distribution.

* **Integration Scenario: ITS-015-B1**
  * **Given** ARCH-008 sends a file read request to ARCH-015 but the template file does not exist at the expected path
  * **When** ARCH-015 attempts to read the template file
  * **Then** ARCH-015 raises TEMPLATE_NOT_FOUND error with the file path, and ARCH-008 does not proceed with test case generation

---

### Module Verification: ARCH-016 (Matrix C Table Generator)

**Parent System Components**: SYS-006

#### Test Case: ITP-016-A (Contract Compliance — Matrix C Table Output)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-016 receives structured mapping data from ARCH-018 and REQ references, and produces a Matrix C Markdown table with SYS→ARCH→ITP→ITS columns.

* **Integration Scenario: ITS-016-A1**
  * **Given** ARCH-016 (Matrix C Table Generator) receives `mapping_data` from ARCH-018 (Matrix C Data Parser) and `req_references` per SYS from system-design.md
  * **When** ARCH-016 generates the Matrix C Markdown table
  * **Then** the output contains columns SYS (annotated with parent REQ-NNN in parentheses), ARCH, ITP, ITS — with cross-cutting modules as pseudo-rows where SYS column displays "N/A (Cross-Cutting)"

* **Integration Scenario: ITS-016-A2**
  * **Given** ARCH-016 receives mapping data from ARCH-018 and computes coverage percentage
  * **When** ARCH-016 generates the coverage percentage
  * **Then** the independently calculated coverage percentage matches the validation script output from ARCH-013

#### Test Case: ITP-016-B (Fault Injection — Empty Mapping Data)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-016 raises EMPTY_MAPPING when mapping data contains no entries.

* **Integration Scenario: ITS-016-B1**
  * **Given** ARCH-016 receives `mapping_data` from ARCH-018 that contains zero SYS→ARCH→ITP→ITS entries
  * **When** ARCH-016 attempts to generate the Matrix C table
  * **Then** ARCH-016 raises EMPTY_MAPPING error and does not produce a malformed table to ARCH-017

#### Test Case: ITP-016-C (Data Flow — Matrix C Building Chain Stage 3)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies data transformation at Data Flow Chain "Matrix C Building" Stage 3: structured mapping data is transformed into a Matrix C Markdown table.

* **Integration Scenario: ITS-016-C1**
  * **Given** ARCH-018 has produced structured mapping data with coverage percentage at Data Flow Stage 2
  * **When** ARCH-016 transforms mapping data and REQ parent references into Matrix C Markdown table with cross-cutting pseudo-rows
  * **Then** the output format is a Markdown table with SYS (REQ refs), ARCH, ITP, ITS columns and independently calculated coverage percentage, conforming to Data Flow View Stage 3 output specification

---

### Module Verification: ARCH-017 (Progressive Matrix Assembler)

**Parent System Components**: SYS-006

#### Test Case: ITP-017-A (Contract Compliance — Progressive Matrix Assembly)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-017 receives available artifact list from ARCH-021 and matrix tables, and assembles the correct progressive combination (A, A+B, or A+B+C).

* **Integration Scenario: ITS-017-A1**
  * **Given** ARCH-017 (Progressive Matrix Assembler) receives `available_artifacts` from ARCH-021 indicating architecture-level artifacts exist, and `matrix_c` from ARCH-016 (Matrix C Table Generator)
  * **When** ARCH-017 assembles the complete traceability matrix
  * **Then** the output contains Matrix A + Matrix B + Matrix C as separate tables with independent coverage percentages per matrix

* **Integration Scenario: ITS-017-A2**
  * **Given** ARCH-017 receives `available_artifacts` from ARCH-021 that do NOT include architecture-level artifacts
  * **When** ARCH-017 assembles the traceability matrix
  * **Then** the output contains only Matrix A + Matrix B (v0.2.0 compatible output) with no Matrix C and no warning, maintaining backward compatibility

#### Test Case: ITP-017-B (Fault Injection — No Artifacts Available)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-017 raises NO_ARTIFACTS when no v-model artifacts exist to build matrices from.

* **Integration Scenario: ITS-017-B1**
  * **Given** ARCH-017 receives an empty `available_artifacts` list from ARCH-021
  * **When** ARCH-017 attempts to assemble the traceability matrix
  * **Then** ARCH-017 raises NO_ARTIFACTS warning and produces an empty or minimal output without crashing

#### Test Case: ITP-017-C (Data Flow — Matrix C Building Chain Stage 4)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies data transformation at Data Flow Chain "Matrix C Building" Stage 4: individual matrix tables are assembled into complete traceability-matrix.md content.

* **Integration Scenario: ITS-017-C1**
  * **Given** ARCH-016 has produced the Matrix C Markdown table at Data Flow Stage 3 and Matrix A and Matrix B tables are available
  * **When** ARCH-017 selects the A+B+C assembly based on available artifacts from ARCH-021
  * **Then** the output is complete traceability-matrix.md content with separate tables and independent coverage percentages, conforming to Data Flow View Stage 4 output specification

#### Test Case: ITP-017-D (Concurrency — Blocking Shell Execution to Matrix Builder)

**Technique**: Concurrency & Race Condition Testing
**Target View**: Process View
**Description**: Verifies that ARCH-017 waits for ARCH-018 shell execution to complete before assembling the final matrix output.

* **Integration Scenario: ITS-017-D1**
  * **Given** ARCH-017 initiates a synchronous shell execution call to ARCH-018 (Matrix C Data Parser) for SYS→ARCH→ITP→ITS data extraction
  * **When** the shell execution of ARCH-018 is in progress
  * **Then** ARCH-017 blocks until ARCH-018 completes and returns its stdout data, and the assembled matrix reflects the complete extraction result without partial data

---

### Module Verification: ARCH-018 (Matrix C Data Parser — Bash)

**Parent System Components**: SYS-007

#### Test Case: ITP-018-A (Contract Compliance — Structured Mapping Data Output)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-018 parses architecture-design.md and integration-test.md and produces structured SYS→ARCH→ITP→ITS mapping data on stdout for ARCH-016.

* **Integration Scenario: ITS-018-A1**
  * **Given** ARCH-018 (Matrix C Data Parser — Bash) receives file paths to architecture-design.md and integration-test.md as positional arguments
  * **When** ARCH-018 sends structured mapping data to stdout for consumption by ARCH-016 (Matrix C Table Generator)
  * **Then** the output contains per-line SYS→ARCH→ITP→ITS entries with an independently calculated coverage percentage line, using regex patterns consistent with ARCH-028

#### Test Case: ITP-018-B (Fault Injection — Malformed Input Files)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-018 raises MALFORMED_INPUT when input files are missing or malformed.

* **Integration Scenario: ITS-018-B1**
  * **Given** ARCH-018 receives a file path to an architecture-design.md that contains no Logical View section
  * **When** ARCH-018 attempts to parse the malformed file
  * **Then** ARCH-018 writes an error message to stderr and exits with non-zero exit code, and does not send partial mapping data to stdout

#### Test Case: ITP-018-C (Data Flow — Matrix C Building Chain Stage 2)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies data transformation at Data Flow Chain "Matrix C Building" Stage 2: Markdown files are parsed into structured mapping data.

* **Integration Scenario: ITS-018-C1**
  * **Given** ARCH-028 has provided compiled ID regex patterns at Data Flow Stage 1
  * **When** ARCH-018 extracts and cross-references SYS→ARCH from Logical View and ARCH→ITP→ITS from lineage encoding in integration-test.md
  * **Then** the output format is structured per-line mapping entries with coverage percentage, conforming to Data Flow View Stage 2 output specification

#### Test Case: ITP-018-D (Concurrency — Synchronous Shell Execution Target)

**Technique**: Concurrency & Race Condition Testing
**Target View**: Process View
**Description**: Verifies that ARCH-018 executes as a synchronous shell subprocess called by ARCH-017 and returns its complete output before ARCH-017 proceeds.

* **Integration Scenario: ITS-018-D1**
  * **Given** ARCH-017 (Progressive Matrix Assembler) invokes ARCH-018 as a synchronous shell subprocess
  * **When** ARCH-018 completes parsing and writes all output to stdout
  * **Then** ARCH-018 exits with code 0 (success) or non-zero (failure), and ARCH-017 reads the complete stdout before proceeding with matrix assembly

---

### Module Verification: ARCH-019 (Matrix C Data Parser — PowerShell)

**Parent System Components**: SYS-008

#### Test Case: ITP-019-A (Contract Compliance — Cross-Platform Parity with ARCH-018)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-019 produces identical structured output format to ARCH-018 for cross-platform parity, ensuring ARCH-016 can consume output from either parser interchangeably.

* **Integration Scenario: ITS-019-A1**
  * **Given** ARCH-019 (Matrix C Data Parser — PowerShell) receives the same architecture-design.md and integration-test.md file paths as ARCH-018
  * **When** ARCH-019 sends structured mapping data to stdout for consumption by ARCH-016 (Matrix C Table Generator)
  * **Then** the output format is identical to ARCH-018 output: per-line SYS→ARCH→ITP→ITS entries with coverage percentage, and ARCH-016 produces the same Matrix C table from either parser's output

#### Test Case: ITP-019-B (Fault Injection — Malformed Input Files)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-019 raises MALFORMED_INPUT identically to ARCH-018 when input files are missing or malformed.

* **Integration Scenario: ITS-019-B1**
  * **Given** ARCH-019 receives a file path to a missing integration-test.md
  * **When** ARCH-019 attempts to parse the non-existent file
  * **Then** ARCH-019 writes an error message to stderr and exits with non-zero exit code, matching the error behavior of ARCH-018 for the same input condition

#### Test Case: ITP-019-C (Data Flow — Matrix C Building Chain Stage 2 — PowerShell Path)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies that ARCH-019 performs the same data transformation as ARCH-018 at Data Flow Chain "Matrix C Building" Stage 2, ensuring cross-platform data flow parity.

* **Integration Scenario: ITS-019-C1**
  * **Given** ARCH-028 has provided compiled ID regex patterns and ARCH-019 receives the same input files as ARCH-018
  * **When** ARCH-019 extracts and cross-references SYS→ARCH→ITP→ITS mappings
  * **Then** the output format and content are identical to ARCH-018 output for the same inputs, conforming to Data Flow View Stage 2 output specification

---

### Module Verification: ARCH-020 (System Design Prerequisite Check)

**Parent System Components**: SYS-009

#### Test Case: ITP-020-A (Contract Compliance — Prerequisite Validation Output)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-020 checks for system-design.md existence and returns the validation result in the setup script JSON output consumed by ARCH-001 and ARCH-007.

* **Integration Scenario: ITS-020-A1**
  * **Given** ARCH-020 (System Design Prerequisite Check) receives a `vmodel_dir` path with `--require-system-design` flag set, and system-design.md exists in the directory
  * **When** ARCH-020 sends its validation result as part of the setup script JSON output
  * **Then** the output contains `validation_result: true` and the calling process (architecture design or integration test command) proceeds to the extraction phase

#### Test Case: ITP-020-B (Fault Injection — Prerequisite Missing)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-020 raises PREREQUISITE_MISSING when the required system-design.md does not exist.

* **Integration Scenario: ITS-020-B1**
  * **Given** ARCH-020 receives a `vmodel_dir` path with `--require-system-design` flag set, but system-design.md does not exist in the directory
  * **When** ARCH-020 checks for the prerequisite file
  * **Then** ARCH-020 raises PREREQUISITE_MISSING error "system-design.md not found in {vmodel_dir}" and returns non-zero exit code, halting the calling command before ARCH-001 or ARCH-007 execute

#### Test Case: ITP-020-D (Concurrency — Synchronous Subprocess Setup Call)

**Technique**: Concurrency & Race Condition Testing
**Target View**: Process View
**Description**: Verifies that ARCH-020 executes as a synchronous subprocess call during the setup phase and returns its JSON result before the extraction phase begins.

* **Integration Scenario: ITS-020-D1**
  * **Given** the architecture design command initiates the setup phase by invoking ARCH-020 and ARCH-021 as synchronous subprocess calls
  * **When** ARCH-020 completes its prerequisite check and returns JSON output
  * **Then** the setup phase completes before the extraction phase (ARCH-001) begins, and the JSON output is fully parsed before downstream modules consume it

---

### Module Verification: ARCH-021 (Extended Document Detection)

**Parent System Components**: SYS-009

#### Test Case: ITP-021-A (Contract Compliance — Document Detection Output)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-021 detects available v-model documents including architecture-design.md and integration-test.md, and returns them in the JSON output consumed by ARCH-017.

* **Integration Scenario: ITS-021-A1**
  * **Given** ARCH-021 (Extended Document Detection) scans a `vmodel_dir` containing spec.md, requirements.md, system-design.md, and architecture-design.md
  * **When** ARCH-021 sends the `available_docs` array as part of the setup script JSON output
  * **Then** the output is a JSON array containing ["spec.md", "requirements.md", "system-design.md", "architecture-design.md"] and ARCH-017 (Progressive Matrix Assembler) can determine the correct matrix assembly level

* **Integration Scenario: ITS-021-A2**
  * **Given** ARCH-021 scans a `vmodel_dir` that is missing integration-test.md
  * **When** ARCH-021 produces the `available_docs` array
  * **Then** "integration-test.md" is absent from the array and ARCH-017 correctly selects A+B assembly (no Matrix C)

#### Test Case: ITP-021-B (Fault Injection — Backward Compatibility with v0.2.0)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-021 preserves backward compatibility — existing v0.2.0 document types are detected alongside new architecture-level documents.

* **Integration Scenario: ITS-021-B1**
  * **Given** ARCH-021 scans a `vmodel_dir` created by v0.2.0 containing only spec.md, requirements.md, and acceptance-plan.md
  * **When** ARCH-021 produces the `available_docs` array
  * **Then** the array contains the three v0.2.0 documents and does not include architecture-design.md or integration-test.md, and the calling process operates identically to v0.2.0 behavior

#### Test Case: ITP-021-D (Concurrency — Synchronous Subprocess Setup Call)

**Technique**: Concurrency & Race Condition Testing
**Target View**: Process View
**Description**: Verifies that ARCH-021 executes as a synchronous subprocess during the setup phase and its document detection result is available before downstream modules need it.

* **Integration Scenario: ITS-021-D1**
  * **Given** the setup phase invokes ARCH-020 and ARCH-021 as synchronous subprocess calls
  * **When** ARCH-021 completes document detection and returns the available_docs JSON array
  * **Then** the JSON output is fully available before ARCH-017 (Progressive Matrix Assembler) or any command logic queries the available documents list

---

### Module Verification: ARCH-022 (Manifest Version and Command Registry)

**Parent System Components**: SYS-011

#### Test Case: ITP-022-A (Contract Compliance — Version and Command Registration)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-022 updates extension.yml and catalog-entry.json with correct version and command registrations, maintaining consistency between both manifests.

* **Integration Scenario: ITS-022-A1**
  * **Given** ARCH-022 (Manifest Version and Command Registry) receives the `extension_yml_path` and `catalog_entry_path` file paths
  * **When** ARCH-022 updates both manifest files
  * **Then** extension.yml contains version `0.3.0` with 7 commands (5 existing + architecture-design + integration-test) and 1 hook, and catalog-entry.json has matching version and capability metadata

#### Test Case: ITP-022-B (Fault Injection — Manifest File Not Found)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-022 raises FILE_NOT_FOUND when manifest files are missing.

* **Integration Scenario: ITS-022-B1**
  * **Given** ARCH-022 receives an `extension_yml_path` pointing to a non-existent file
  * **When** ARCH-022 attempts to read the manifest file
  * **Then** ARCH-022 raises FILE_NOT_FOUND error with the file path and does not modify catalog-entry.json, preserving the existing registration state

---

### Module Verification: ARCH-023 (Architecture Command Evaluator)

**Parent System Components**: SYS-012

#### Test Case: ITP-023-A (Contract Compliance — Quality Evaluation Output)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-023 receives generated architecture-design.md content and quality thresholds, and produces an evaluation result with structural, coverage, and completeness scores.

* **Integration Scenario: ITS-023-A1**
  * **Given** ARCH-023 (Architecture Command Evaluator) receives architecture-design.md content containing all four mandatory views and quality thresholds from the v0.2.0 baseline
  * **When** ARCH-023 evaluates the content
  * **Then** the output contains `{pass: true, scores: {structural, coverage, completeness}, details}` and all scores meet or exceed the baseline thresholds

#### Test Case: ITP-023-B (Fault Injection — Structural Failure on Missing View)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-023 raises STRUCTURAL_FAILURE when mandatory views are absent from the evaluated output.

* **Integration Scenario: ITS-023-B1**
  * **Given** ARCH-023 receives architecture-design.md content missing the Process View section
  * **When** ARCH-023 evaluates the structural compliance
  * **Then** ARCH-023 raises STRUCTURAL_FAILURE identifying "Process View" as the missing section, and the evaluation result has `pass: false`

---

### Module Verification: ARCH-024 (Integration Test Command Evaluator)

**Parent System Components**: SYS-012

#### Test Case: ITP-024-A (Contract Compliance — Integration Test Quality Evaluation)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-024 receives generated integration-test.md content and quality thresholds, and produces an evaluation result with structural, coverage, technique, and BDD scores.

* **Integration Scenario: ITS-024-A1**
  * **Given** ARCH-024 (Integration Test Command Evaluator) receives integration-test.md content with complete ITP/ITS hierarchy and quality thresholds from the v0.2.0 baseline
  * **When** ARCH-024 evaluates the content
  * **Then** the output contains `{pass: true, scores: {structural, coverage, technique, bdd}, details}` and all scores meet or exceed the baseline thresholds

#### Test Case: ITP-024-B (Fault Injection — Structural Failure on Malformed Hierarchy)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-024 raises STRUCTURAL_FAILURE when the ITP/ITS hierarchy is malformed.

* **Integration Scenario: ITS-024-B1**
  * **Given** ARCH-024 receives integration-test.md content where ITP-003-A has no ITS scenarios nested under it
  * **When** ARCH-024 evaluates the structural compliance
  * **Then** ARCH-024 raises STRUCTURAL_FAILURE identifying "ITP-003-A: no ITS scenarios" as the malformed element, and the evaluation result has `pass: false`

---

### Module Verification: ARCH-025 (Mermaid Syntax Validator)

**Parent System Components**: SYS-012

#### Test Case: ITP-025-A (Contract Compliance — Mermaid Validation Results)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-025 receives extracted Mermaid code blocks and produces per-block validation results indicating syntactic correctness.

* **Integration Scenario: ITS-025-A1**
  * **Given** ARCH-025 (Mermaid Syntax Validator) receives extracted Mermaid `sequenceDiagram` code blocks from the Process View of architecture-design.md
  * **When** ARCH-025 validates each block
  * **Then** the output contains per-block `{valid: true, errors: []}` results for syntactically correct blocks, and all blocks must pass for overall success

#### Test Case: ITP-025-B (Fault Injection — Syntax Failure Detection)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-025 raises SYNTAX_FAILURE when a Mermaid block contains structural errors.

* **Integration Scenario: ITS-025-B1**
  * **Given** ARCH-025 receives a Mermaid code block with a malformed participant declaration (e.g., missing "as" alias clause)
  * **When** ARCH-025 validates the block
  * **Then** ARCH-025 raises SYNTAX_FAILURE with the block index and error description "invalid participant declaration", and the overall validation result is `{valid: false}`

---

### Module Verification: ARCH-026 (Overlay Discovery Mechanism)

**Parent System Components**: SYS-013

#### Test Case: ITP-026-A (Contract Compliance — Overlay Path Resolution)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-026 reads v-model-config.yml, resolves overlay file paths based on domain configuration, and returns correct paths or null to the calling command.

* **Integration Scenario: ITS-026-A1**
  * **Given** ARCH-026 (Overlay Discovery Mechanism) reads a `v-model-config.yml` with `domain: iso_26262` and receives `command_name: "architecture-design"`
  * **When** ARCH-026 resolves the overlay paths
  * **Then** ARCH-026 returns `command_overlay_path: "commands/overlays/iso_26262/architecture-design.md"` if the file exists, or null with a warning if it does not

* **Integration Scenario: ITS-026-A2**
  * **Given** ARCH-026 reads a missing or absent `v-model-config.yml`
  * **When** ARCH-026 attempts to resolve overlay paths
  * **Then** ARCH-026 returns null for both `command_overlay_path` and `template_overlay_path`, and the calling command proceeds with base-only output

#### Test Case: ITP-026-B (Fault Injection — Malformed Config YAML)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-026 raises CONFIG_PARSE_ERROR when v-model-config.yml exists but contains malformed YAML.

* **Integration Scenario: ITS-026-B1**
  * **Given** ARCH-026 reads a `v-model-config.yml` file containing invalid YAML syntax (e.g., unbalanced quotes)
  * **When** ARCH-026 attempts to parse the configuration
  * **Then** ARCH-026 raises CONFIG_PARSE_ERROR warning with the parse error description, and the calling command falls back to base-only behavior without crashing

#### Test Case: ITP-026-D (Concurrency — Synchronous Overlay Loading During Setup)

**Technique**: Concurrency & Race Condition Testing
**Target View**: Process View
**Description**: Verifies that ARCH-026 completes overlay discovery synchronously during the setup phase before the generation phase begins.

* **Integration Scenario: ITS-026-D1**
  * **Given** the architecture design command initiates the setup phase which includes ARCH-020 (Prerequisite Check), ARCH-021 (Document Detection), and ARCH-026 (Overlay Discovery)
  * **When** ARCH-026 reads v-model-config.yml and resolves overlay paths
  * **Then** overlay discovery completes before the extraction phase (ARCH-001) begins, and the overlay resolution result is available to ARCH-027 without race conditions

---

### Module Verification: ARCH-027 (Overlay Assembly Protocol)

**Parent System Components**: SYS-013

#### Test Case: ITP-027-A (Contract Compliance — Overlay Merging at Merge Points)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-027 receives base template content and overlay content, identifies merge points (conditional safety-critical placeholders), and inserts overlay sections correctly.

* **Integration Scenario: ITS-027-A1**
  * **Given** ARCH-027 (Overlay Assembly Protocol) receives `base_template_content` from ARCH-014 (Architecture Template Structure) containing conditional safety-critical section placeholders, and `overlay_content` from a domain overlay file
  * **When** ARCH-027 merges the overlay into the base template
  * **Then** the `assembled_content` contains the overlay's safety-critical sections inserted at the merge points, and the base template's non-overlay sections are unmodified

#### Test Case: ITP-027-B (Fault Injection — Merge Point Not Found)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-027 raises MERGE_POINT_NOT_FOUND when the base template lacks expected placeholder sections.

* **Integration Scenario: ITS-027-B1**
  * **Given** ARCH-027 receives `base_template_content` from ARCH-014 that lacks the expected "SAFETY-CRITICAL SECTION" placeholder and `overlay_content` that targets this merge point
  * **When** ARCH-027 attempts to merge the overlay section
  * **Then** ARCH-027 raises MERGE_POINT_NOT_FOUND warning identifying the overlay section name, skips the unmatched section, and the remaining assembly continues without corruption

---

### Module Verification: ARCH-028 (ID Pattern Library) [CROSS-CUTTING]

**Parent System Components**: [CROSS-CUTTING] — Shared regex patterns used by SYS-003, SYS-006, SYS-007, SYS-008, SYS-010, and SYS-012

#### Test Case: ITP-028-A (Contract Compliance — Pattern Delivery to Multiple Consumers)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-028 returns correct compiled regex patterns to all consumer modules (ARCH-001, ARCH-007, ARCH-010, ARCH-011, ARCH-018, ARCH-019) and that patterns are POSIX ERE compatible.

* **Integration Scenario: ITS-028-A1**
  * **Given** ARCH-001 (SYS Component Extractor) sends a pattern request for "SYS" to ARCH-028 (ID Pattern Library)
  * **When** ARCH-028 returns the compiled pattern
  * **Then** the returned pattern is `SYS-[0-9]{3}` in POSIX ERE format, and ARCH-001 uses it to extract SYS-NNN identifiers from system-design.md

* **Integration Scenario: ITS-028-A2**
  * **Given** ARCH-007 (Architecture Design Parser) sends pattern requests for "ARCH", "ITP", and "ITS" to ARCH-028
  * **When** ARCH-028 returns the compiled patterns
  * **Then** the returned patterns are `ARCH-[0-9]{3}`, `ITP-[0-9]{3}-[A-Z]`, and `ITS-[0-9]{3}-[A-Z][0-9]+` respectively, and ARCH-007 uses them to parse architecture-design.md views

#### Test Case: ITP-028-B (Fault Injection — Unknown Pattern Request)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-028 raises UNKNOWN_PATTERN when an unsupported pattern type is requested.

* **Integration Scenario: ITS-028-B1**
  * **Given** a consumer module sends a pattern request for "INVALID_TYPE" to ARCH-028
  * **When** ARCH-028 attempts to resolve the pattern
  * **Then** ARCH-028 raises UNKNOWN_PATTERN error identifying "INVALID_TYPE" as the unsupported pattern name, and the consumer module handles the error without crashing

#### Test Case: ITP-028-C (Data Flow — Shared Pattern Delivery Across All Chains)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies that ARCH-028 serves as Stage 1 in all four data flow chains, providing consistent compiled regex patterns to each chain's initial consumer module.

* **Integration Scenario: ITS-028-C1**
  * **Given** ARCH-028 is invoked at Data Flow Stage 1 of the "System Design to Architecture Design" chain by ARCH-001 and at Stage 1 of the "Coverage Validation" chain by ARCH-010
  * **When** ARCH-028 returns compiled SYS-NNN patterns to both consumers
  * **Then** both consumers receive identical pattern objects, ensuring deterministic ID extraction across chains conforming to Data Flow View Stage 1 specification

#### Test Case: ITP-028-D (Concurrency — Shared Resource Access by Multiple Consumers)

**Technique**: Concurrency & Race Condition Testing
**Target View**: Process View
**Description**: Verifies that ARCH-028's shared patterns are accessed by multiple consumer modules across different execution flows without corruption or stale data.

* **Integration Scenario: ITS-028-D1**
  * **Given** ARCH-028 (ID Pattern Library) provides patterns to ARCH-001 during the architecture design generation flow and to ARCH-007 during the integration test generation flow
  * **When** both execution flows access ARCH-028's compiled regex patterns
  * **Then** each consumer receives the correct pattern set without interference, and the pattern library state is consistent across all access points

---

## Test Harness & Mocking Strategy

| Test Case | External Dependency | Mock/Stub Strategy | Rationale |
|-----------|--------------------|--------------------|-----------|
| ITP-001-A, ITP-001-B, ITP-001-C | File system (system-design.md) | Stub: in-memory Markdown string | Isolate ARCH-001 from file I/O; control input content precisely |
| ITP-002-A, ITP-002-B, ITP-002-C | ARCH-001 output | Stub: pre-built SYS component array | Test ARCH-002 boundary without real ARCH-001 execution |
| ITP-003-A, ITP-003-B, ITP-003-C | ARCH-002 output, ARCH-014 template | Stub: pre-built ARCH module array + fixture template file | Isolate view generation from decomposition logic |
| ITP-004-A, ITP-004-B, ITP-004-C | ARCH-002 output, ARCH-014 template | Stub: pre-built module/dependency arrays + fixture template | Verify Mermaid generation in isolation |
| ITP-005-A, ITP-005-B, ITP-005-C | ARCH-002 output, ARCH-001 interfaces, ARCH-014 template | Stub: pre-built module/interface arrays + fixture template | Test contract table generation without upstream chain |
| ITP-006-A, ITP-006-B, ITP-006-C | ARCH-002 output, ARCH-014 template | Stub: pre-built module/dependency arrays + fixture template | Isolate data flow table generation |
| ITP-007-A, ITP-007-B, ITP-007-C | File system (architecture-design.md), ARCH-028 patterns | Stub: in-memory Markdown string + real ARCH-028 patterns | Test parser with controlled input; use real patterns for accuracy |
| ITP-008-A, ITP-008-B, ITP-008-C | ARCH-007 output, ARCH-015 template | Stub: pre-built module/view data + fixture template | Isolate test case generation from parsing |
| ITP-009-A, ITP-009-B, ITP-009-C, ITP-009-D | ARCH-008 output, ARCH-015 template, coverage gate (ARCH-010/011/013) | Stub: pre-built test cases + fixture template; Mock: coverage gate subprocess | Test scenario generation without running validation scripts |
| ITP-010-A, ITP-010-B, ITP-010-C, ITP-010-D | File system (system-design.md, architecture-design.md) | Stub: fixture Markdown files in test directory | Control file content for deterministic validation testing |
| ITP-011-A, ITP-011-B, ITP-011-C | File system (architecture-design.md, integration-test.md) | Stub: fixture Markdown files; partial mode tested with missing file | Test backward validation with controlled inputs |
| ITP-012-A, ITP-012-B, ITP-012-C | ARCH-010 SYS IDs, ARCH-011 ITP IDs | Stub: pre-built ID arrays with known orphans/cycles | Isolate orphan detection from file parsing |
| ITP-013-A, ITP-013-B, ITP-013-C, ITP-013-D | ARCH-010/011/012 results | Stub: pre-built result objects | Test report formatting in isolation |
| ITP-014-A, ITP-014-B | File system (template file) | Stub: fixture template file or missing file | Control template availability |
| ITP-015-A, ITP-015-B | File system (template file) | Stub: fixture template file or missing file | Control template availability |
| ITP-016-A, ITP-016-B, ITP-016-C | ARCH-018 mapping data, REQ references | Stub: pre-built mapping data + REQ reference objects | Isolate table generation from file parsing |
| ITP-017-A, ITP-017-B, ITP-017-C, ITP-017-D | ARCH-021 artifacts list, ARCH-016 matrix, shell subprocess | Stub: artifact arrays + matrix strings; Mock: shell subprocess | Test progressive assembly logic without shell execution |
| ITP-018-A, ITP-018-B, ITP-018-C, ITP-018-D | File system (architecture-design.md, integration-test.md) | Stub: fixture Markdown files in test directory | Control file content for deterministic parsing |
| ITP-019-A, ITP-019-B, ITP-019-C | File system (architecture-design.md, integration-test.md) | Stub: fixture Markdown files | Mirror ARCH-018 test setup for cross-platform parity verification |
| ITP-020-A, ITP-020-B, ITP-020-D | File system (vmodel_dir), subprocess | Stub: test directory with/without system-design.md | Control prerequisite file presence |
| ITP-021-A, ITP-021-B, ITP-021-D | File system (vmodel_dir) | Stub: test directory with controlled document set | Control which documents are present for detection |
| ITP-022-A, ITP-022-B | File system (extension.yml, catalog-entry.json) | Stub: fixture manifest files | Test version/command updates without modifying real manifests |
| ITP-023-A, ITP-023-B | Generated architecture-design.md content | Stub: pre-built Markdown content string | Test evaluation without running generation command |
| ITP-024-A, ITP-024-B | Generated integration-test.md content | Stub: pre-built Markdown content string | Test evaluation without running generation command |
| ITP-025-A, ITP-025-B | Mermaid code blocks | Stub: pre-built Mermaid code block strings | Test validation without extracting from real documents |
| ITP-026-A, ITP-026-B, ITP-026-D | File system (v-model-config.yml, overlay files) | Stub: fixture config YAML + overlay files | Control domain configuration for overlay path resolution |
| ITP-027-A, ITP-027-B | ARCH-014/015 base template, overlay content | Stub: fixture template + overlay strings | Test merge logic without real file I/O |
| ITP-028-A, ITP-028-B, ITP-028-C, ITP-028-D | None (self-contained library) | Real: use actual ARCH-028 patterns | ID Pattern Library is a pure function; no external dependencies to mock |

---

## V&V Coverage Gate (IEEE 1012:2016)

IEEE 1012:2016 §5.6 requires every architecture module interface to be exercised by at least one V&V activity. The coverage gate validates that all 28 ARCH-NNN components have at least one `ITP-NNN-X` test case at integration test level.

### Script Execution

```
bash scripts/bash/validate-architecture-coverage.sh specs/003-architecture-integration/v-model
```

```
=== Architecture-Level Coverage Validation ===

Totals: 13 SYS | 28 ARCH (1 cross-cutting) | 83 ITPs | 94 ITSs
SYS → ARCH coverage: 13/13 (100%)
ARCH → ITP coverage: 28/28 (100%)
ITP → ITS coverage: 83/83 (100%)

ℹ️  Cross-cutting modules (no SYS parent required):
   - ARCH-028 [CROSS-CUTTING]

✅ Full architecture-level coverage — all system components decomposed, all modules tested.
```

**Exit code**: 0 (PASS — no gaps)

### ARCH→ITP Coverage Table

| ARCH Module | Module Name | V&V Activities (ITP) | Status |
|-------------|-------------|----------------------|--------|
| ARCH-001 | SYS Component Extractor | ITP-001-A, ITP-001-B, ITP-001-C | ✅ Covered |
| ARCH-002 | Architecture Module Decomposer | ITP-002-A, ITP-002-B, ITP-002-C | ✅ Covered |
| ARCH-003 | Logical View Generator | ITP-003-A, ITP-003-B, ITP-003-C | ✅ Covered |
| ARCH-004 | Process View Generator | ITP-004-A, ITP-004-B, ITP-004-C | ✅ Covered |
| ARCH-005 | Interface View Generator | ITP-005-A, ITP-005-B, ITP-005-C | ✅ Covered |
| ARCH-006 | Data Flow View Generator | ITP-006-A, ITP-006-B, ITP-006-C | ✅ Covered |
| ARCH-007 | Architecture Design Parser | ITP-007-A, ITP-007-B, ITP-007-C | ✅ Covered |
| ARCH-008 | Integration Test Case Generator | ITP-008-A, ITP-008-B, ITP-008-C | ✅ Covered |
| ARCH-009 | Integration Test Scenario Generator | ITP-009-A, ITP-009-B, ITP-009-C, ITP-009-D | ✅ Covered |
| ARCH-010 | Forward Coverage Validator | ITP-010-A, ITP-010-B, ITP-010-C, ITP-010-D | ✅ Covered |
| ARCH-011 | Backward Coverage Validator | ITP-011-A, ITP-011-B, ITP-011-C | ✅ Covered |
| ARCH-012 | Orphan and Circular Dependency Detector | ITP-012-A, ITP-012-B, ITP-012-C | ✅ Covered |
| ARCH-013 | Coverage Report Formatter | ITP-013-A, ITP-013-B, ITP-013-C, ITP-013-D | ✅ Covered |
| ARCH-014 | Architecture Template Structure | ITP-014-A, ITP-014-B | ✅ Covered |
| ARCH-015 | Integration Test Template Structure | ITP-015-A, ITP-015-B | ✅ Covered |
| ARCH-016 | Matrix C Table Generator | ITP-016-A, ITP-016-B, ITP-016-C | ✅ Covered |
| ARCH-017 | Progressive Matrix Assembler | ITP-017-A, ITP-017-B, ITP-017-C, ITP-017-D | ✅ Covered |
| ARCH-018 | Matrix C Data Parser (Bash) | ITP-018-A, ITP-018-B, ITP-018-C, ITP-018-D | ✅ Covered |
| ARCH-019 | Matrix C Data Parser (PowerShell) | ITP-019-A, ITP-019-B, ITP-019-C | ✅ Covered |
| ARCH-020 | System Design Prerequisite Check | ITP-020-A, ITP-020-B, ITP-020-D | ✅ Covered |
| ARCH-021 | Extended Document Detection | ITP-021-A, ITP-021-B, ITP-021-D | ✅ Covered |
| ARCH-022 | Manifest Version and Command Registry | ITP-022-A, ITP-022-B | ✅ Covered |
| ARCH-023 | Architecture Command Evaluator | ITP-023-A, ITP-023-B | ✅ Covered |
| ARCH-024 | Integration Test Command Evaluator | ITP-024-A, ITP-024-B | ✅ Covered |
| ARCH-025 | Mermaid Syntax Validator | ITP-025-A, ITP-025-B | ✅ Covered |
| ARCH-026 | Overlay Discovery Mechanism | ITP-026-A, ITP-026-B, ITP-026-D | ✅ Covered |
| ARCH-027 | Overlay Assembly Protocol | ITP-027-A, ITP-027-B | ✅ Covered |
| ARCH-028 | ID Pattern Library [CROSS-CUTTING] | ITP-028-A, ITP-028-B, ITP-028-C, ITP-028-D | ✅ Covered |

**V&V Gap Summary**: No gaps — all 28 ARCH-NNN components have at least one integration-level V&V activity.

### Entry Criteria (IEEE 1012:2016 §5.6.1)

| Criterion | Status |
|-----------|--------|
| `architecture-design.md` is current and peer-reviewed | ✅ Met |
| Every `ARCH-NNN` module has at least one `ITP-NNN-X` test case (100% forward coverage) | ✅ Met — 28/28 (100%) |
| All `ITP-NNN-X` test cases have at least one `ITS-NNN-X#` executable scenario | ✅ Met — 83/83 (100%) |
| V&V gap list is empty (all integration boundaries covered) | ✅ Met — 0 gaps |

**Verdict**: ✅ PASS — IEEE 1012:2016 §5.6 V&V completeness requirements satisfied at integration test level.

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Architecture Modules (ARCH) | 28 (28 active, 0 deprecated) |
| Total Test Cases (ITP) | 83 |
| Total Scenarios (ITS) | 94 |
| Modules with ≥1 ITP | 28 / 28 (100%) (active items only) |
| Test Cases with ≥1 ITS | 83 / 83 (100%) |
| **Overall Coverage (ARCH→ITP)** | **100%** |

### Technique Distribution

| Technique | Test Cases | Percentage |
|-----------|-----------|------------|
| Interface Contract Testing | 28 | 33.7% |
| Interface Fault Injection | 28 | 33.7% |
| Data Flow Testing | 18 | 21.7% |
| Concurrency & Race Condition Testing | 9 | 10.8% |

## Uncovered Modules

None — full coverage achieved.
