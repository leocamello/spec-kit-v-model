# Integration Test Plan: Module Design ↔ Unit Testing

**Feature Branch**: `004-module-unit-testing`
**Created**: 2026-02-21
**Status**: Draft
**Source**: `specs/004-module-unit/v-model/architecture-design.md`

## Overview

This document defines the Integration Test Plan for the V-Model Extension Pack v0.4.0 (Module Design ↔ Unit Testing). Every architecture module (`ARCH-NNN`) from the architecture design has one or more Integration Test Cases (`ITP-NNN-X`), and every test case has one or more executable Integration Test Scenarios (`ITS-NNN-X#`) in module-boundary BDD format (Given/When/Then). Integration tests verify the **seams and handshakes between modules** — they target the interfaces, data flows, and failure propagation across module boundaries. They do NOT test internal module logic (unit testing) or user journeys (acceptance testing).

The architecture comprises 17 modules: 8 Components, 2 Libraries, 7 Utilities, and 1 cross-cutting infrastructure module. Three primary data flow pipelines drive the integration strategy: Module Design Generation (ARCH-013 → ARCH-001 → ARCH-017 → ARCH-002 → ARCH-005 → ARCH-007), Unit Test Generation (ARCH-013 → ARCH-003 → ARCH-017 → ARCH-004 → ARCH-006 → ARCH-007 + ARCH-008), and Matrix D Trace Generation (ARCH-011 → ARCH-010 → ARCH-017). No safety-critical sections are generated (no `v-model-config.yml` domain configuration detected).

## ID Schema

- **Integration Test Case**: `ITP-{NNN}-{X}` — where NNN matches the parent ARCH, X is a letter suffix (A, B, C...)
- **Integration Test Scenario**: `ITS-{NNN}-{X}{#}` — nested under the parent ITP, with numeric suffix (1, 2, 3...)
- Example: `ITS-001-A1` → Scenario 1 of Test Case A verifying ARCH-001

## ISO 29119-4 Integration Test Techniques

Each test case identifies its technique by name and anchors to a specific architecture view:

| Technique | Source View | What It Tests |
|-----------|------------|---------------|
| **Interface Contract Testing** | Interface View | Module API contracts, data format compliance, error responses |
| **Data Flow Testing** | Data Flow View | End-to-end data transformation chain validation |
| **Interface Fault Injection** | Interface View + Process View | Malformed payloads, timeouts, graceful failure |
| **Concurrency & Race Condition Testing** | Process View | Simultaneous access, lock handling, queue ordering |

## Integration Tests

### Module Verification: ARCH-001 (Module Design Prompt Orchestrator)

**Parent System Components**: SYS-001

#### Test Case: ITP-001-A (Setup-to-Orchestrator JSON Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-001 correctly consumes the JSON output from ARCH-013 (Setup Flag Handler) and uses the `VMODEL_DIR`, `ARCH_DESIGN`, and `AVAILABLE_DOCS` fields to locate input files.

* **Integration Scenario: ITS-001-A1**
  * **Given** ARCH-013 has produced a JSON payload containing `VMODEL_DIR`, `ARCH_DESIGN`, and `AVAILABLE_DOCS` fields with valid file paths
  * **When** ARCH-001 parses the JSON payload from ARCH-013
  * **Then** ARCH-001 resolves `architecture-design.md` from the `ARCH_DESIGN` path and confirms ≥1 `ARCH-NNN` identifier is present in the file

* **Integration Scenario: ITS-001-A2**
  * **Given** ARCH-013 has produced a JSON payload where `AVAILABLE_DOCS` includes `"architecture-design.md"`
  * **When** ARCH-001 evaluates the available documents list from ARCH-013
  * **Then** ARCH-001 proceeds to the template loading step via ARCH-005 without emitting an error

#### Test Case: ITP-001-B (Orchestrator-to-Generator Delegation Pipeline)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies the end-to-end data flow from ARCH-001 parsing `architecture-design.md` through ARCH-017 tag routing and ARCH-002 four-view generation to the final `module-design.md` output.

* **Integration Scenario: ITS-001-B1**
  * **Given** ARCH-001 has parsed 3 ARCH-NNN modules from `architecture-design.md` (1 standard, 1 `[CROSS-CUTTING]`, 1 `[EXTERNAL]`)
  * **When** ARCH-001 delegates each module to ARCH-017 for tag classification and then to ARCH-002 for four-view generation
  * **Then** the data arriving at ARCH-002 contains the routing decision from ARCH-017 (`decompose_full` for the standard and cross-cutting modules, `wrapper_only` for the external module)

* **Integration Scenario: ITS-001-B2**
  * **Given** ARCH-002 has returned Markdown text for 3 MOD-NNN sections to ARCH-001
  * **When** ARCH-001 assembles the MOD-NNN sections with the template structure from ARCH-005 into `module-design.md`
  * **Then** the output file written by ARCH-001 contains all 3 MOD-NNN sections in sequential order with the template's header and coverage summary intact

#### Test Case: ITP-001-C (Orchestrator Error Propagation on Empty Input)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-001 handles gracefully when `architecture-design.md` exists but contains zero `ARCH-NNN` identifiers.

* **Integration Scenario: ITS-001-C1**
  * **Given** ARCH-013 has returned a valid JSON payload with `ARCH_DESIGN` pointing to a file that contains no `ARCH-NNN` identifiers
  * **When** ARCH-001 attempts to parse the ARCH-NNN list from the file provided by ARCH-013
  * **Then** ARCH-001 emits the error message "No architecture modules found in architecture-design.md — cannot generate module design" and produces no output file

* **Integration Scenario: ITS-001-C2**
  * **Given** ARCH-001 has generated `module-design.md` and delegates coverage validation to ARCH-007
  * **When** ARCH-007 returns exit code 1 with a gap report indicating `ARCH-003` has no MOD mapping
  * **Then** ARCH-001 includes the ARCH-007 gap report in its final status output and does NOT abort the generation process

---

### Module Verification: ARCH-002 (Module Four-View Generator)

**Parent System Components**: SYS-001, SYS-004

#### Test Case: ITP-002-A (Generator-to-Template Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-002 reads the template structure from ARCH-005 and produces MOD-NNN content conforming to the four mandatory section headers defined in the template.

* **Integration Scenario: ITS-002-A1**
  * **Given** ARCH-005 has provided a template structure defining section headers for Algorithmic/Logic View, State Machine View, Internal Data Structures, and Error Handling & Return Codes
  * **When** ARCH-002 generates content for a standard (non-external) module using the ARCH-005 template structure
  * **Then** the Markdown text returned by ARCH-002 to ARCH-001 contains all four section headers in the order defined by ARCH-005, including a fenced `pseudocode` block in the Algorithmic/Logic View

* **Integration Scenario: ITS-002-A2**
  * **Given** ARCH-005 has provided a template structure with the "Target Source File(s)" property field
  * **When** ARCH-002 generates content for a module mapped to a C/C++ header/implementation pair
  * **Then** the Target Source File(s) field in the Markdown text returned by ARCH-002 contains comma-separated paths (e.g., `src/parser.h, src/parser.cpp`)

#### Test Case: ITP-002-B (Generator Receives External Routing Decision)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies data transformation when ARCH-002 receives a `wrapper_only` routing decision from ARCH-017 via ARCH-001.

* **Integration Scenario: ITS-002-B1**
  * **Given** ARCH-017 has classified an ARCH-NNN module as `[EXTERNAL]` and returned `wrapper_only` to ARCH-001
  * **When** ARCH-001 forwards the module data with the `wrapper_only` routing decision to ARCH-002
  * **Then** ARCH-002 returns Markdown text containing the `[EXTERNAL]` tag, wrapper/configuration interface documentation, and NO fenced `pseudocode` block for the library internals

---

### Module Verification: ARCH-003 (Unit Test Prompt Orchestrator)

**Parent System Components**: SYS-002

#### Test Case: ITP-003-A (Setup-to-Orchestrator JSON Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-003 correctly consumes the JSON output from ARCH-013 using the `--require-unit-test` prerequisite flag path and locates `module-design.md`.

* **Integration Scenario: ITS-003-A1**
  * **Given** ARCH-013 has produced a JSON payload containing `VMODEL_DIR` and `AVAILABLE_DOCS` that includes `"module-design.md"`
  * **When** ARCH-003 parses the JSON payload from ARCH-013
  * **Then** ARCH-003 resolves `module-design.md` from the `VMODEL_DIR` path and confirms ≥1 `MOD-NNN` identifier is present in the file

#### Test Case: ITP-003-B (Orchestrator-to-Technique-Engine Delegation Pipeline)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies the end-to-end data flow from ARCH-003 parsing `module-design.md` through ARCH-017 tag routing and ARCH-004 technique selection to the final `unit-test.md` output.

* **Integration Scenario: ITS-003-B1**
  * **Given** ARCH-003 has parsed 3 MOD-NNN modules from `module-design.md` (1 standard, 1 `[CROSS-CUTTING]`, 1 `[EXTERNAL]`)
  * **When** ARCH-003 delegates each module to ARCH-017 for tag classification
  * **Then** ARCH-017 returns `skip_utp` for the `[EXTERNAL]` module and `generate` for the standard and `[CROSS-CUTTING]` modules, and ARCH-003 forwards only the 2 non-external modules to ARCH-004

* **Integration Scenario: ITS-003-B2**
  * **Given** ARCH-004 has returned UTP-NNN-X + UTS-NNN-X# Markdown text for 2 modules to ARCH-003
  * **When** ARCH-003 assembles the test content with the template structure from ARCH-006 into `unit-test.md`
  * **Then** the output file written by ARCH-003 contains exactly 2 module test sections (no UTP generated for the `[EXTERNAL]` module) and the `[EXTERNAL]` module is listed in the "External Module Bypass" section

#### Test Case: ITP-003-C (Coverage Gate Integration)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-003 correctly handles the combined output from ARCH-007 (forward) and ARCH-008 (backward) validators after generation.

* **Integration Scenario: ITS-003-C1**
  * **Given** ARCH-003 has generated `unit-test.md` and invokes both ARCH-007 and ARCH-008 for full validation
  * **When** ARCH-008 returns exit code 1 with a backward coverage gap ("MOD-005: no unit test case found")
  * **Then** ARCH-003 includes the ARCH-008 gap report in its final status output, does NOT abort, and the `unit-test.md` file remains on disk

---

### Module Verification: ARCH-004 (White-Box Technique Engine)

**Parent System Components**: SYS-002, SYS-005

#### Test Case: ITP-004-A (Technique Engine Input Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-004 receives the four MOD views from ARCH-003 in the expected format and returns UTP/UTS Markdown text conforming to the ARCH-006 template structure.

* **Integration Scenario: ITS-004-A1**
  * **Given** ARCH-003 has forwarded a MOD-NNN module's four views (Algorithmic/Logic, State Machine, Internal Data Structures, Error Handling) to ARCH-004
  * **When** ARCH-004 processes the module views and selects appropriate ISO 29119-4 techniques
  * **Then** ARCH-004 returns UTP-NNN-X Markdown text with an explicit technique name, view anchor, and a Dependency & Mock Registry table conforming to the ARCH-006 template format

* **Integration Scenario: ITS-004-A2**
  * **Given** ARCH-003 has forwarded a MOD-NNN module whose Internal Data Structures contain only Boolean and Enum types
  * **When** ARCH-004 evaluates the data types for technique selection
  * **Then** ARCH-004 applies Equivalence Partitioning (not Boundary Value Analysis) and the returned UTP Markdown text names "Equivalence Partitioning" as the technique

#### Test Case: ITP-004-B (Technique Engine Template Consumption)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies that data flows correctly from ARCH-006 template structure through ARCH-004 to produce correctly formatted UTS scenarios.

* **Integration Scenario: ITS-004-B1**
  * **Given** ARCH-006 has provided a template structure requiring Arrange/Act/Assert format for UTS-NNN-X# scenarios
  * **When** ARCH-004 generates UTS scenarios for a stateful module with Mermaid state transitions
  * **Then** the UTS Markdown text returned by ARCH-004 uses Arrange/Act/Assert format (not BDD Given/When/Then) and each scenario references a specific state transition from the State Machine View

---

### Module Verification: ARCH-005 (Module Design Template)

**Parent System Components**: SYS-004

#### Test Case: ITP-005-A (Template Read Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-005 provides the expected template content when read by ARCH-001, and that a missing template triggers the correct error.

* **Integration Scenario: ITS-005-A1**
  * **Given** the file `templates/module-design-template.md` exists in the repository
  * **When** ARCH-001 issues a read request to ARCH-005
  * **Then** ARCH-005 returns Markdown text containing section headers for the four mandatory views, the Target Source File(s) property field, and the Parent Architecture Modules field

* **Integration Scenario: ITS-005-A2**
  * **Given** the file `templates/module-design-template.md` does NOT exist in the repository
  * **When** ARCH-001 issues a read request to ARCH-005
  * **Then** ARCH-001 receives a "template not found" error from the file system and halts generation with a diagnostic message

---

### Module Verification: ARCH-006 (Unit Test Template)

**Parent System Components**: SYS-005

#### Test Case: ITP-006-A (Template Read Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-006 provides the expected template content when read by ARCH-003, including the Dependency & Mock Registry table structure and hardware interface guidance.

* **Integration Scenario: ITS-006-A1**
  * **Given** the file `templates/unit-test-template.md` exists in the repository
  * **When** ARCH-003 issues a read request to ARCH-006
  * **Then** ARCH-006 returns Markdown text containing the three-tier MOD→UTP→UTS hierarchy, technique naming placeholders, Dependency & Mock Registry table definition (including hardware interface guidance), and conditional safety-critical placeholders

* **Integration Scenario: ITS-006-A2**
  * **Given** the file `templates/unit-test-template.md` does NOT exist in the repository
  * **When** ARCH-003 issues a read request to ARCH-006
  * **Then** ARCH-003 receives a "template not found" error from the file system and halts generation with a diagnostic message

---

### Module Verification: ARCH-007 (Forward Coverage Parser)

**Parent System Components**: SYS-003

#### Test Case: ITP-007-A (Parser Output Contract with Orchestrators)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-007 produces the expected stdout output format (human-readable or JSON) consumed by ARCH-001 and ARCH-003 orchestrators.

* **Integration Scenario: ITS-007-A1**
  * **Given** ARCH-001 has generated `module-design.md` with MOD-NNN entries covering all ARCH-NNN modules
  * **When** ARCH-001 invokes ARCH-007 with `--json` flag, passing `architecture-design.md` and `module-design.md` as arguments
  * **Then** ARCH-007 returns exit code 0 and a JSON object containing `"has_gaps": false` and `"arch_to_mod_coverage_pct": 100`

* **Integration Scenario: ITS-007-A2**
  * **Given** ARCH-001 has generated `module-design.md` where ARCH-003 has no corresponding MOD-NNN entry
  * **When** ARCH-001 invokes ARCH-007 with `--json` flag
  * **Then** ARCH-007 returns exit code 1 and a JSON object containing `"has_gaps": true` and `"arch_without_mod"` array including `"ARCH-003"`

#### Test Case: ITP-007-B (Malformed Input File Handling)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-007 handles malformed or empty input files without crashing.

* **Integration Scenario: ITS-007-B1**
  * **Given** `architecture-design.md` contains valid ARCH-NNN identifiers but `module-design.md` is an empty file (0 bytes)
  * **When** ARCH-001 invokes ARCH-007 with both file paths
  * **Then** ARCH-007 returns exit code 1 with a gap report listing every ARCH-NNN as uncovered, without producing a stack trace or crash

* **Integration Scenario: ITS-007-B2**
  * **Given** `module-design.md` contains MOD-NNN entries with "Parent Architecture Modules" fields referencing ARCH-NNN identifiers not present in `architecture-design.md`
  * **When** ARCH-001 invokes ARCH-007 with both file paths
  * **Then** ARCH-007 reports the orphaned MOD-NNN entries in its output and returns exit code 1

---

### Module Verification: ARCH-008 (Backward Coverage Parser)

**Parent System Components**: SYS-003

#### Test Case: ITP-008-A (Combined Forward+Backward Output Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-008 produces backward coverage results that combine correctly with ARCH-007 forward results into a unified validation report.

* **Integration Scenario: ITS-008-A1**
  * **Given** ARCH-007 has completed forward validation with exit code 0 (all ARCH covered by MOD)
  * **When** ARCH-008 executes backward validation and finds all non-`[EXTERNAL]` MOD-NNN modules have at least one UTP-NNN-X in `unit-test.md`
  * **Then** the combined stdout from ARCH-007 + ARCH-008 reports `"has_gaps": false` with both forward and backward coverage at 100%

* **Integration Scenario: ITS-008-A2**
  * **Given** ARCH-007 has completed forward validation with exit code 0
  * **When** ARCH-008 detects a UTP-NNN-X whose parent MOD-NNN does not exist in `module-design.md`
  * **Then** ARCH-008 reports the orphaned UTP identifier in the `"orphaned_utps"` JSON array and returns exit code 1

#### Test Case: ITP-008-B (Partial Validation Mode at Module Boundary)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-008 gracefully skips backward coverage checks when `unit-test.md` is absent (partial validation mode).

* **Integration Scenario: ITS-008-B1**
  * **Given** ARCH-001 has generated `module-design.md` but `unit-test.md` does not exist in the `VMODEL_DIR`
  * **When** ARCH-001 invokes `validate-module-coverage.sh` which internally delegates to ARCH-007 and ARCH-008
  * **Then** ARCH-008 is entirely skipped, ARCH-007 runs forward-only validation, and the combined script returns exit code 0 with `"partial_mode": true` in JSON output

---

### Module Verification: ARCH-009 (Module Coverage Validator — PowerShell)

**Parent System Components**: SYS-010

#### Test Case: ITP-009-A (Cross-Platform Output Parity)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-009 (PowerShell) produces identical output format and exit codes as the combined ARCH-007 + ARCH-008 (Bash) given the same input files.

* **Integration Scenario: ITS-009-A1**
  * **Given** a test fixture containing `architecture-design.md`, `module-design.md`, and `unit-test.md` with known coverage gaps
  * **When** ARCH-009 (PowerShell) and ARCH-007+ARCH-008 (Bash) are invoked with the same three file paths and `--json`/`-Json` flag respectively
  * **Then** both produce JSON output with identical `has_gaps`, `arch_to_mod_coverage_pct`, `mod_to_utp_coverage_pct`, and orphan arrays, and both return exit code 1

* **Integration Scenario: ITS-009-A2**
  * **Given** a test fixture containing only `architecture-design.md` and `module-design.md` (no `unit-test.md`) to trigger partial mode
  * **When** ARCH-009 (PowerShell) and ARCH-007+ARCH-008 (Bash) are invoked with the two file paths
  * **Then** both produce JSON output with `"partial_mode": true`, identical forward coverage percentages, and both return exit code 0

---

### Module Verification: ARCH-010 (Matrix D Data Extractor — Bash)

**Parent System Components**: SYS-007

#### Test Case: ITP-010-A (Extractor-to-Renderer Structured Data Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-010 produces structured stdout data in the format expected by ARCH-011 (Matrix D Table Renderer).

* **Integration Scenario: ITS-010-A1**
  * **Given** ARCH-010 has parsed `architecture-design.md`, `module-design.md`, and `unit-test.md` containing valid ARCH→MOD→UTP→UTS mappings
  * **When** ARCH-011 reads the structured data from ARCH-010's stdout
  * **Then** ARCH-011 can extract ARCH-NNN identifiers with parenthetical SYS-NNN annotations, MOD-NNN identifiers, and nested UTP/UTS chains without parsing errors

* **Integration Scenario: ITS-010-A2**
  * **Given** ARCH-010 has parsed files where ARCH-005 is a `[CROSS-CUTTING]` module
  * **When** ARCH-010 outputs the structured data for ARCH-005
  * **Then** the structured data contains `([CROSS-CUTTING])` in place of the SYS-NNN parenthetical annotation, and ARCH-011 renders this correctly in the Matrix D table

#### Test Case: ITP-010-B (Three-File Parsing Chain)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies the data transformation chain where ARCH-010 consumes three Markdown files and produces structured ARCH→MOD→UTP→UTS data with annotations.

* **Integration Scenario: ITS-010-B1**
  * **Given** `architecture-design.md` contains ARCH-001 with parent SYS-001, `module-design.md` contains MOD-001 with "Parent Architecture Modules: ARCH-001", and `unit-test.md` contains UTP-001-A with UTS-001-A1
  * **When** ARCH-010 parses all three files in sequence
  * **Then** ARCH-010 outputs the chain `ARCH-001 (SYS-001) → MOD-001 → UTP-001-A → UTS-001-A1` in its structured data format

* **Integration Scenario: ITS-010-B2**
  * **Given** `module-design.md` contains MOD-003 tagged as `[EXTERNAL]` with no corresponding UTP in `unit-test.md`
  * **When** ARCH-010 processes the `[EXTERNAL]` module
  * **Then** ARCH-010 outputs `[EXTERNAL]` annotation for MOD-003 with "N/A — External" in the UTP/UTS columns, and the coverage percentage computation excludes MOD-003 from the denominator

#### Test Case: ITP-010-C (Missing File Fault Handling)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-010 returns a meaningful error when a required input file is missing.

* **Integration Scenario: ITS-010-C1**
  * **Given** `architecture-design.md` and `module-design.md` exist but `unit-test.md` does not
  * **When** ARCH-010 is invoked with all three file path arguments
  * **Then** ARCH-010 produces partial Matrix D data (MOD column populated, UTP/UTS columns display "Unit test plan not yet generated") without crashing

---

### Module Verification: ARCH-011 (Matrix D Table Renderer)

**Parent System Components**: SYS-006

#### Test Case: ITP-011-A (Renderer Consumes Extractor Data)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-011 correctly consumes structured data from ARCH-010 (Bash) or ARCH-012 (PowerShell) and renders a valid Markdown Matrix D table.

* **Integration Scenario: ITS-011-A1**
  * **Given** ARCH-010 has produced structured data containing 5 ARCH→MOD→UTP→UTS chains with coverage percentages
  * **When** ARCH-011 consumes the ARCH-010 stdout and renders Matrix D
  * **Then** ARCH-011 produces a Markdown table with columns ARCH (SYS), MOD, UTP, UTS and the coverage percentages match those independently computed by ARCH-010

* **Integration Scenario: ITS-011-A2**
  * **Given** ARCH-012 (PowerShell) has produced structured data identical in format to ARCH-010 output
  * **When** ARCH-011 consumes the ARCH-012 stdout
  * **Then** ARCH-011 renders an identical Markdown Matrix D table as when consuming ARCH-010 output, confirming cross-platform extractor parity at the renderer boundary

#### Test Case: ITP-011-B (Progressive Matrix Building)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies that ARCH-011 progressively builds matrices based on available artifacts (A → A+B → A+B+C → A+B+C+D).

* **Integration Scenario: ITS-011-B1**
  * **Given** `AVAILABLE_DOCS` from ARCH-013 contains only v0.3.0 artifacts (no `module-design.md`, no `unit-test.md`)
  * **When** ARCH-011 evaluates the available document list
  * **Then** ARCH-011 renders Matrices A, B, and C only, producing output backward-compatible with v0.3.0 — no Matrix D section, no warning emitted

* **Integration Scenario: ITS-011-B2**
  * **Given** `AVAILABLE_DOCS` from ARCH-013 contains all v0.4.0 artifacts including `module-design.md` and `unit-test.md`
  * **When** ARCH-011 invokes ARCH-010 to extract Matrix D data and renders the complete traceability matrix
  * **Then** the output file `traceability-matrix.md` contains four separate tables (Matrix A, B, C, D) each with independent coverage percentages

---

### Module Verification: ARCH-012 (Matrix D Data Extractor — PowerShell)

**Parent System Components**: SYS-008

#### Test Case: ITP-012-A (Cross-Platform Extractor Output Parity)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-012 (PowerShell) produces stdout data identical in structure and content to ARCH-010 (Bash) for the same input files.

* **Integration Scenario: ITS-012-A1**
  * **Given** a test fixture containing `architecture-design.md`, `module-design.md`, and `unit-test.md` with `[CROSS-CUTTING]`, `[EXTERNAL]`, and standard modules
  * **When** ARCH-012 (PowerShell) and ARCH-010 (Bash) are invoked with the same three file paths
  * **Then** both produce structured data with identical ARCH→MOD→UTP→UTS chains, identical `([CROSS-CUTTING])` and `[EXTERNAL]` annotations, and identical coverage percentages

---

### Module Verification: ARCH-013 (Setup Module-Level Flag Handler)

**Parent System Components**: SYS-009

#### Test Case: ITP-013-A (Flag-to-Orchestrator JSON Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-013 produces a JSON payload with the new `--require-module-design` and `--require-unit-test` flags that ARCH-001 and ARCH-003 consume correctly.

* **Integration Scenario: ITS-013-A1**
  * **Given** `module-design.md` exists in the feature's `v-model/` directory
  * **When** ARCH-013 is invoked with `--require-module-design` flag
  * **Then** ARCH-013 returns exit code 0 and a JSON payload where `AVAILABLE_DOCS` includes `"module-design.md"`

* **Integration Scenario: ITS-013-A2**
  * **Given** `module-design.md` and `unit-test.md` both exist in the feature's `v-model/` directory
  * **When** ARCH-013 is invoked with both `--require-module-design` and `--require-unit-test` flags
  * **Then** ARCH-013 returns exit code 0 and a JSON payload where `AVAILABLE_DOCS` includes both `"module-design.md"` and `"unit-test.md"`

#### Test Case: ITP-013-B (Missing Prerequisite Fault Injection)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-013 returns a meaningful non-zero exit code and error message when a required prerequisite file is missing.

* **Integration Scenario: ITS-013-B1**
  * **Given** `module-design.md` does NOT exist in the feature's `v-model/` directory
  * **When** ARCH-013 is invoked with `--require-module-design` flag
  * **Then** ARCH-013 returns non-zero exit code and stderr message "module-design.md is required but not found in {path}", and ARCH-001 does not proceed past the setup step

* **Integration Scenario: ITS-013-B2**
  * **Given** ARCH-013 is invoked WITHOUT the new `--require-module-design` or `--require-unit-test` flags (v0.3.0 invocation pattern)
  * **When** ARCH-013 processes the existing v0.3.0 flags only
  * **Then** ARCH-013 returns exit code 0 with a JSON payload identical in structure to v0.3.0 output — `AVAILABLE_DOCS` detection still includes `module-design.md` and `unit-test.md` if they happen to exist, but no prerequisite enforcement occurs

---

### Module Verification: ARCH-014 (Extension Manifest v0.4.0 Registrar)

**Parent System Components**: SYS-011

#### Test Case: ITP-014-A (Manifest-to-Command Registration Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that the updated `extension.yml` (ARCH-014) correctly registers the new commands so that ARCH-001 and ARCH-003 orchestrators are discoverable by the spec-kit extension runtime.

* **Integration Scenario: ITS-014-A1**
  * **Given** ARCH-014 has updated `extension.yml` to version `0.4.0` with 9 commands listed
  * **When** the spec-kit extension runtime parses `extension.yml` for available commands
  * **Then** the runtime discovers `module-design` and `unit-test` as valid commands alongside the 7 existing v0.3.0 commands, and the `id_prefixes` list includes `MOD`, `UTP`, and `UTS`

* **Integration Scenario: ITS-014-A2**
  * **Given** ARCH-014 has updated `extension.yml` with the `id_prefixes` list including `MOD`, `UTP`, `UTS`
  * **When** ARCH-015 (Structural Evaluation Engine) or ARCH-007 (Forward Parser) attempts to validate artifacts containing `MOD-NNN`, `UTP-NNN-X`, `UTS-NNN-X#` identifiers
  * **Then** the identifiers are recognized as valid by scripts that reference the `id_prefixes` in `extension.yml`

---

### Module Verification: ARCH-015 (Structural Evaluation Engine)

**Parent System Components**: SYS-012

#### Test Case: ITP-015-A (Evaluation Input Contract from CI Pipeline)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-015 correctly consumes `module-design.md` and `unit-test.md` fixtures as input from the CI pipeline and produces pass/fail assertion results per module identifier.

* **Integration Scenario: ITS-015-A1**
  * **Given** the CI pipeline has generated `module-design.md` and `unit-test.md` test fixtures via ARCH-001 and ARCH-003 respectively
  * **When** ARCH-015 receives both fixtures and runs structural assertions
  * **Then** ARCH-015 produces a per-MOD-NNN and per-UTP-NNN-X pass/fail report on stdout with specific failure messages (e.g., "MOD-003: missing fenced pseudocode block")

* **Integration Scenario: ITS-015-A2**
  * **Given** the CI pipeline has generated a `module-design.md` fixture where a non-`[EXTERNAL]` MOD lacks a fenced `pseudocode` block
  * **When** ARCH-015 runs the pseudocode block presence assertion
  * **Then** ARCH-015 reports a structural failure for that specific MOD-NNN identifier and returns a non-zero exit code to the CI pipeline

#### Test Case: ITP-015-B (Structural-to-Semantic Evaluation Handoff)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies the data flow from ARCH-015 structural evaluation to ARCH-016 semantic evaluation within the CI pipeline.

* **Integration Scenario: ITS-015-B1**
  * **Given** ARCH-015 has completed structural validation with all assertions passing (exit code 0)
  * **When** the CI pipeline proceeds to invoke ARCH-016 with the same `module-design.md` fixture
  * **Then** ARCH-016 receives a structurally valid fixture (guaranteed fenced pseudocode blocks exist) and can evaluate semantic quality without encountering missing-section errors

---

### Module Verification: ARCH-016 (Semantic Quality Evaluator)

**Parent System Components**: SYS-012

#### Test Case: ITP-016-A (Semantic Evaluator Output Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-016 consumes the `module-design.md` fixture and produces quality assessment results that integrate with the CI pipeline's pass/fail reporting.

* **Integration Scenario: ITS-016-A1**
  * **Given** ARCH-016 has received a `module-design.md` fixture where all pseudocode blocks contain explicit branches, loops, and implementation-level detail
  * **When** ARCH-016 evaluates the semantic quality of each MOD-NNN pseudocode section
  * **Then** ARCH-016 returns a pass result with a quality score above the configured threshold, and the CI pipeline marks the evaluation as successful

* **Integration Scenario: ITS-016-A2**
  * **Given** ARCH-016 has received a `module-design.md` fixture where MOD-007 contains vague prose ("process appropriately") instead of concrete pseudocode
  * **When** ARCH-016 evaluates MOD-007's pseudocode section
  * **Then** ARCH-016 reports "MOD-007: pseudocode lacks implementation-level specificity" with a quality score below the threshold, and the CI pipeline marks the evaluation as failed

---

### Module Verification: ARCH-017 (Tag Routing Logic) `[CROSS-CUTTING]`

**Parent System Components**: [CROSS-CUTTING] — Infrastructure routing logic shared by ARCH-001, ARCH-003, ARCH-007, ARCH-008, ARCH-009, ARCH-010, ARCH-011, ARCH-012

#### Test Case: ITP-017-A (Routing Decision Contract Across Consumers)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies that ARCH-017 returns the correct routing decision for each tag value when consumed by its multiple consumer modules (commands, validators, matrix builders).

* **Integration Scenario: ITS-017-A1**
  * **Given** ARCH-001 (Module Design Orchestrator) passes the tag string `[EXTERNAL]` to ARCH-017
  * **When** ARCH-017 classifies the tag in the module-design command context
  * **Then** ARCH-017 returns `wrapper_only` to ARCH-001, and ARCH-001 forwards this decision to ARCH-002 which generates wrapper-only documentation

* **Integration Scenario: ITS-017-A2**
  * **Given** ARCH-007 (Forward Coverage Parser) passes the tag string `[CROSS-CUTTING]` to ARCH-017
  * **When** ARCH-017 classifies the tag in the validation context
  * **Then** ARCH-017 does NOT return `bypass_validation`, and ARCH-007 requires the `[CROSS-CUTTING]` module to have full forward MOD coverage

* **Integration Scenario: ITS-017-A3**
  * **Given** ARCH-010 (Matrix D Extractor) passes the tag string `[CROSS-CUTTING]` to ARCH-017
  * **When** ARCH-017 classifies the tag in the matrix builder context
  * **Then** ARCH-017 returns the annotation `([CROSS-CUTTING])` instead of a SYS-NNN parenthetical, and ARCH-010 includes this annotation in its structured output

#### Test Case: ITP-017-B (Tag Propagation Through Full Pipeline)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies that tag routing decisions from ARCH-017 propagate correctly through the entire Module Design Generation and Unit Test Generation data flows.

* **Integration Scenario: ITS-017-B1**
  * **Given** `architecture-design.md` contains ARCH-005 tagged `[EXTERNAL]`
  * **When** the Module Design Generation pipeline flows from ARCH-013 → ARCH-001 → ARCH-017 → ARCH-002 → ARCH-007
  * **Then** ARCH-017 returns `wrapper_only` at stage 3, ARCH-002 produces wrapper-only documentation at stage 4, and ARCH-007 validates forward coverage treating the `[EXTERNAL]` module as fully covered at stage 6

* **Integration Scenario: ITS-017-B2**
  * **Given** `module-design.md` contains MOD-003 tagged `[EXTERNAL]` (inherited from its parent ARCH)
  * **When** the Unit Test Generation pipeline flows from ARCH-013 → ARCH-003 → ARCH-017 → ARCH-004 → ARCH-008
  * **Then** ARCH-017 returns `skip_utp` at stage 3, ARCH-004 is never invoked for MOD-003 at stage 4, and ARCH-008 excludes MOD-003 from backward coverage calculation at stage 6

#### Test Case: ITP-017-C (Unrecognized Tag Fault Injection)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-017 handles unrecognized tag strings (e.g., `[COTS]`) without crashing and routes them to the correct default behavior.

* **Integration Scenario: ITS-017-C1**
  * **Given** ARCH-001 passes the tag string `[COTS]` (not in the canonical vocabulary) to ARCH-017
  * **When** ARCH-017 evaluates the unrecognized tag
  * **Then** ARCH-017 treats the module as a standard module (`decompose_full`), and ARCH-001 delegates it to ARCH-002 for full four-view generation — the `[COTS]` tag is NOT treated as a bypass

* **Integration Scenario: ITS-017-C2**
  * **Given** ARCH-008 encounters a MOD-NNN tagged `[COTS]` during backward coverage validation
  * **When** ARCH-008 queries ARCH-017 for the tag routing decision
  * **Then** ARCH-017 does NOT return `bypass_validation` (only `[EXTERNAL]` triggers bypass), and ARCH-008 requires the `[COTS]`-tagged module to have UTP coverage — flagging it as a gap if missing

---

## Test Harness & Mocking Strategy

| Test Case | External Dependency | Mock/Stub Strategy | Rationale |
|-----------|--------------------|--------------------|-----------|
| ITP-001-A | File system (`architecture-design.md`) | Fixture file in test directory | Provides controlled ARCH-NNN content for deterministic parsing |
| ITP-001-B | ARCH-017 routing logic | In-process function stub returning known routing decisions | Isolates pipeline testing from tag classification internals |
| ITP-001-C | File system (empty `architecture-design.md`) | Empty fixture file (0 ARCH-NNN) | Tests orchestrator error path without affecting real artifacts |
| ITP-002-A | ARCH-005 template file | Fixture template in test directory | Controls template structure independently of repository state |
| ITP-002-B | ARCH-017 routing decision | Pre-set `wrapper_only` string | Tests generator behavior for specific routing outcomes |
| ITP-003-A | File system (`module-design.md`) | Fixture file in test directory | Provides controlled MOD-NNN content |
| ITP-003-B | ARCH-017 routing logic | In-process function stub | Isolates pipeline from tag routing |
| ITP-003-C | ARCH-007 + ARCH-008 exit codes | Process stub returning controlled exit codes and JSON | Tests orchestrator response to validator signals |
| ITP-004-A | ARCH-006 template structure | Fixture template | Controls AAA format expectations |
| ITP-004-B | ARCH-006 template structure | Fixture template | Controls UTS format expectations |
| ITP-005-A | File system (`templates/` directory) | Fixture directory with/without template file | Tests template presence/absence contract |
| ITP-006-A | File system (`templates/` directory) | Fixture directory with/without template file | Tests template presence/absence contract |
| ITP-007-A | File system (two Markdown files) | Fixture files with known ARCH/MOD distributions | Deterministic coverage percentages |
| ITP-007-B | File system (malformed files) | Empty file and orphaned-reference fixtures | Tests parser resilience |
| ITP-008-A | File system (three Markdown files) | Fixture files with known coverage + orphans | Tests combined validation |
| ITP-008-B | File system (missing `unit-test.md`) | Fixture directory without unit-test.md | Tests partial mode boundary |
| ITP-009-A | File system (three Markdown files) | Same fixtures as ARCH-007/008 tests | Cross-platform parity verification |
| ITP-010-A | File system (three Markdown files) | Fixture files with tags | Tests structured data contract |
| ITP-010-B | File system (three Markdown files) | Fixture files with known chains | Verifies transformation chain |
| ITP-010-C | File system (missing `unit-test.md`) | Fixture directory without unit-test.md | Tests partial Matrix D behavior |
| ITP-011-A | ARCH-010/012 stdout | Captured stdout from extractor test runs | Tests renderer consumption contract |
| ITP-011-B | ARCH-013 `AVAILABLE_DOCS` | Controlled JSON with varied doc lists | Tests progressive matrix building |
| ITP-012-A | File system (three Markdown files) | Same fixtures as ARCH-010 tests | Cross-platform parity verification |
| ITP-013-A | File system (v-model directory) | Fixture directory with controlled file presence | Tests flag validation JSON |
| ITP-013-B | File system (missing files) | Fixture directory without prerequisite files | Tests error reporting contract |
| ITP-014-A | `extension.yml` file | Fixture YAML with controlled content | Tests command registration parsing |
| ITP-015-A | CI pipeline + fixtures | Fixture Markdown files with known defects | Tests assertion pass/fail contract |
| ITP-015-B | ARCH-016 availability | Sequential CI job dependency | Tests structural→semantic handoff |
| ITP-016-A | LLM-as-judge API | Fixture with known-quality pseudocode | Tests quality threshold contract |
| ITP-017-A | Consumer modules (ARCH-001, 007, 010) | In-process function call with tag string | Tests routing decision per consumer context |
| ITP-017-B | Full pipeline (6 modules) | End-to-end fixture with tagged modules | Tests propagation through pipeline stages |
| ITP-017-C | Consumer modules | Tag string `[COTS]` input | Tests unrecognized tag default behavior |

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Architecture Modules (ARCH) | 17 |
| Total Test Cases (ITP) | 32 |
| Total Scenarios (ITS) | 57 |
| Modules with ≥1 ITP | 17 / 17 (100%) |
| Test Cases with ≥1 ITS | 32 / 32 (100%) |
| **Overall Coverage (ARCH→ITP)** | **100%** |

### Technique Distribution

| Technique | Test Cases | Percentage |
|-----------|-----------|------------|
| Interface Contract Testing | 17 | 53% |
| Data Flow Testing | 8 | 25% |
| Interface Fault Injection | 7 | 22% |
| Concurrency & Race Condition Testing | 0 | 0% |

> **Note**: Concurrency & Race Condition Testing is not applicable for this feature. The Process View confirms all three pipelines (Module Design, Unit Test, Matrix D) operate sequentially in a single-threaded LLM agent prompt execution model. No concurrent module interactions exist.

## Uncovered Modules

None — full coverage achieved.
