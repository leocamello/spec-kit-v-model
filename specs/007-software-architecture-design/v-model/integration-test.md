# Integration Test Plan: Software Architecture Design (Path B)

**Feature Branch**: `007-software-architecture-design`
**Created**: 2026-05-04
**Status**: Draft
**Source**: `specs/007-software-architecture-design/v-model/software-architecture-design.md`

## Overview

This document defines the Integration Test Plan for the Software Architecture Design (Path B) feature. Every architecture element (`ARCH-001` through `ARCH-016`) in `software-architecture-design.md` has one or more Test Cases (ITP), and every Test Case has one or more executable Integration Scenarios (ITS) in module-boundary BDD format (Given/When/Then).

Integration tests verify **seams and handshakes between architecture elements**, not internal logic or user journeys. All scenarios use module-boundary-oriented language referencing specific ARCH-NNN element pairs and their interface contracts from the Interface View (now split into External and Internal tables per IEEE 1016 §5.3).

Four mandatory ISO 29119-4 integration test techniques are applied: Interface Contract Testing (driven by Interface View — both External and Internal tables), Data Flow Testing (driven by Data Flow View + Data Design supplement per IEEE 1016 §5.4), Interface Fault Injection (driven by Interface View error contracts + Process View timing), and Concurrency & Race Condition Testing (driven by Process View concurrency model).

Architecture Evaluation (ISO 42030 + ISO 25010) gap detection is also verified at integration level: `[QUALITY GAP]` and `[ARCH CONCERN]` flags must propagate from evaluation to downstream consumers.

Domain is configured as `iso_26262`. Safety-critical integration test sections (SIL/HIL Compatibility, Resource Contention) are included per the domain overlay.

## ID Schema

- **Integration Test Case**: `ITP-{NNN}-{X}` — where NNN matches the parent ARCH, X is a letter suffix (A, B, C...)
- **Integration Test Scenario**: `ITS-{NNN}-{X}{#}` — nested under the parent ITP, with numeric suffix (1, 2, 3...)
- Example: `ITS-001-A1` → Scenario 1 of Test Case A verifying ARCH-001
- Source: `software-architecture-design.md` (Path B — combined artifact; no SYS layer)

## ISO 29119-4 Integration Test Techniques

| Technique | Source View | What It Tests |
|-----------|------------|---------------|
| **Interface Contract Testing** | Interface View | Element-to-element API contracts, data format compliance, error responses |
| **Data Flow Testing** | Data Flow View | End-to-end data transformation chain validation across the pipeline |
| **Interface Fault Injection** | Interface View + Process View | Malformed payloads, timeouts, graceful failure at element boundaries |
| **Concurrency & Race Condition Testing** | Process View | Pipeline ordering guarantees, sequential dependency validation |

## Test Harness & Mocking Strategy

For each test case below, the following stubs/mocks are assumed:

| Stubbed Dependency | Mock Strategy | Rationale |
|--------------------|---------------|-----------|
| File System (requirements.md, v-model-config.yml) | In-memory file system with injected content | Enables deterministic input control without real disk I/O |
| Overlay files (commands/overlays/{domain}/*.md) | In-memory template content per domain | Allows testing all three domain paths without actual overlay files on disk |
| ARCH-015 (ID Pattern Library) | Real regex patterns (stateless, no side effects) | ID extraction is deterministic; mocking would reduce test fidelity |
| Output file write (software-architecture-design.md) | Captured output buffer; write verified by content assertion | Avoids polluting the real v-model directory during test runs |
| Data Design entities (in-memory arrays) | Real in-memory data structures | Data entities are transient pipeline objects; no persistent mock needed |

## Integration Tests

### Module Verification: ARCH-001 (Requirements Parser)

#### Test Case: ITP-001-A (Contract Compliance — REQ Parsing Output)

**Technique**: Interface Contract Testing
**Target View**: Interface View (ARCH-001 contract)
**Description**: Verifies that ARCH-001 produces structured REQ data conforming to its Interface View contract when receiving valid requirements.md content, and that ARCH-004 (Element Decomposer) can consume the output without transformation errors.

- **Integration Scenario: ITS-001-A1**
  - **Given** ARCH-001 (Requirements Parser) receives valid Markdown content containing a Functional Requirements table with REQ-001 through REQ-010 entries
  - **When** ARCH-001 sends the extracted `requirements` array to ARCH-004 (Architecture Element Decomposer)
  - **Then** the output contains a non-empty array of `{id, description, priority, rationale, verification}` objects matching the Interface View contract, and ARCH-004 accepts the payload and begins decomposition without rejection

- **Integration Scenario: ITS-001-A2**
  - **Given** ARCH-001 receives Markdown content containing 50+ REQ-NNN identifiers across functional and non-functional requirement tables
  - **When** ARCH-001 sends the extracted `requirements` array to ARCH-004
  - **Then** the output array contains all 50+ requirements without truncation, each with structured fields matching the Interface View contract, and ARCH-004 processes all entries

#### Test Case: ITP-001-B (Fault Injection — Empty/Missing Input)

**Technique**: Interface Fault Injection
**Target View**: Interface View (ARCH-001 error contract) + Process View
**Description**: Verifies that ARCH-001 handles missing, empty, or invalid input gracefully and returns error objects per its error contract, without propagating corruption to ARCH-004.

- **Integration Scenario: ITS-001-B1**
  - **Given** ARCH-001 (Requirements Parser) receives an empty Markdown string as `requirements_content`
  - **When** ARCH-001 attempts to extract REQ identifiers using patterns from ARCH-015 (ID Pattern Library)
  - **Then** ARCH-001 returns an error object with message "No REQ-NNN identifiers found in requirements.md" and does NOT send any payload to ARCH-004

- **Integration Scenario: ITS-001-B2**
  - **Given** ARCH-001 receives a file path that does not exist on disk
  - **When** ARCH-001 attempts to read the file
  - **Then** ARCH-001 returns an error object with message "Requirements file not found at [path]" and does NOT propagate any data to ARCH-004

#### Test Case: ITP-001-C (Data Flow — Pipeline Stage 1→3)

**Technique**: Data Flow Testing
**Target View**: Data Flow View (Stage 1: Input Validation)
**Description**: Verifies the data transformation from raw Markdown (Stage 1) through to structured REQ objects consumed by the decomposer (Stage 3).

- **Integration Scenario: ITS-001-C1**
  - **Given** ARCH-015 (ID Pattern Library) provides compiled REQ-NNN regex patterns to ARCH-001 at Data Flow Stage 1
  - **When** ARCH-001 parses a requirements.md containing REQ-001 (P1), REQ-002 (P1), REQ-003 (P1), REQ-008 (P1), REQ-019 (P2) with mixed priorities
  - **Then** the output at Data Flow Stage 1 contains all five REQ objects with correct priority values (P1/P2), and the data is correctly transformed into the format ARCH-004 expects at Stage 3

---

### Module Verification: ARCH-002 (Domain Config Loader)

#### Test Case: ITP-002-A (Contract Compliance — Domain Value Extraction)

**Technique**: Interface Contract Testing
**Target View**: Interface View (ARCH-002 contract)
**Description**: Verifies that ARCH-002 correctly extracts the domain value from v-model-config.yml and returns the expected DomainContext to ARCH-003 (Overlay Loader) and ARCH-009 (SWE.2 Generator).

- **Integration Scenario: ITS-002-A1**
  - **Given** `v-model-config.yml` contains `domain: iso_26262`
  - **When** ARCH-002 reads the config and sends the domain value to ARCH-003 (Overlay Loader)
  - **Then** ARCH-002 returns `"iso_26262"` to ARCH-003, which then loads the iso_26262 overlay, and ARCH-009 subsequently generates SWE.2 sections

- **Integration Scenario: ITS-002-A2**
  - **Given** `v-model-config.yml` is absent from the repository root
  - **When** ARCH-002 attempts to read the config
  - **Then** ARCH-002 returns `null` to the pipeline, ARCH-003 returns null (no overlay loaded), and ARCH-009 is skipped entirely

- **Integration Scenario: ITS-002-A3**
  - **Given** `v-model-config.yml` contains `domain: do_178c`
  - **When** ARCH-002 sends `"do_178c"` to ARCH-003
  - **Then** ARCH-003 loads the do_178c stub overlay, and ARCH-009 is NOT invoked (SWE.2 is iso_26262-only)

---

### Module Verification: ARCH-003 (Overlay Loader)

#### Test Case: ITP-003-A (Contract Compliance — Overlay Resolution)

**Technique**: Interface Contract Testing
**Target View**: Interface View (ARCH-003 contract)
**Description**: Verifies that ARCH-003 correctly resolves and loads domain overlay files, and that the loaded content is consumable by downstream generators.

- **Integration Scenario: ITS-003-A1**
  - **Given** ARCH-002 has returned domain `"iso_26262"` and the overlay file exists at `commands/overlays/iso_26262/software-architecture-design.md`
  - **When** ARCH-003 resolves the overlay path and loads the file
  - **Then** ARCH-003 returns the overlay content as a non-empty string, and ARCH-009 (SWE.2 Generator) can consume it to generate BP1–BP9 sections

- **Integration Scenario: ITS-003-A2**
  - **Given** ARCH-002 has returned domain `"do_178c"` but no overlay file exists at `commands/overlays/do_178c/software-architecture-design.md`
  - **When** ARCH-003 attempts to load the overlay
  - **Then** ARCH-003 logs a warning "Overlay not found for domain: do_178c" and returns NULL; the pipeline continues without error

- **Integration Scenario: ITS-003-A3**
  - **Given** ARCH-002 has returned `null` (no domain configured)
  - **When** ARCH-003 checks the domain value
  - **Then** ARCH-003 returns NULL immediately (no-op); no file I/O is attempted

---

### Module Verification: ARCH-004 (Architecture Element Decomposer)

#### Test Case: ITP-004-A (Contract Compliance — ARCH Decomposition Output)

**Technique**: Interface Contract Testing
**Target View**: Interface View (ARCH-004 contract)
**Description**: Verifies that ARCH-004 produces ARCH element definitions conforming to its Interface View contract and that downstream view generators (ARCH-005 through ARCH-008) can consume the output.

- **Integration Scenario: ITS-004-A1**
  - **Given** ARCH-004 receives structured REQ data for 28 requirements (REQ-001 through REQ-NF-004) from ARCH-001
  - **When** ARCH-004 decomposes requirements and sends the `arch_elements` array to ARCH-005 (Logical View Generator)
  - **Then** the output contains 16 ARCH-NNN element definitions, each with `{id, name, description, parentReqs, type, tags}` structure, and ARCH-005 successfully renders the Logical View table

- **Integration Scenario: ITS-004-A2**
  - **Given** ARCH-004 receives a requirement (REQ-021) that maps to multiple architecture concerns
  - **When** ARCH-004 sends the decomposition to ARCH-005
  - **Then** the ARCH element for REQ-021 correctly lists multiple parent REQ-NNN identifiers (many-to-many mapping), and the traceability generator (ARCH-010) does not double-count

#### Test Case: ITP-004-B (Strict Translator — No Invented Elements)

**Technique**: Interface Fault Injection
**Target View**: Interface View (ARCH-004 error contract)
**Description**: Verifies that ARCH-004 enforces the strict translator constraint and flags derived items instead of silently creating ARCH elements for unexpressed capabilities.

- **Integration Scenario: ITS-004-B1**
  - **Given** ARCH-004 identifies a necessary technical element that has no corresponding REQ-NNN in the parsed requirements
  - **When** ARCH-004 attempts to create an ARCH element for this capability
  - **Then** ARCH-004 emits a `[DERIVED MODULE: reason]` flag in the output rather than silently assigning an ARCH-NNN, and the flag is visible to downstream generators

- **Integration Scenario: ITS-004-B2**
  - **Given** ARCH-004 detects an architecture-implied capability with no requirement trace
  - **When** ARCH-004 processes the gap
  - **Then** ARCH-004 emits a `[DERIVED REQUIREMENT: reason]` flag, and ARCH-010 (Traceability Generator) includes the derived item in its summary for human review

---

### Module Verification: ARCH-005/006/007/008 (Four View Generators)

#### Test Case: ITP-005-A (Contract Compliance — IEEE 42010 Views Populated)

**Technique**: Interface Contract Testing
**Target View**: Interface View (ARCH-005 through ARCH-008 contracts)
**Description**: Verifies that all four view generators produce non-empty, non-placeholder output that ARCH-013 (Output Assembler) can consume.

- **Integration Scenario: ITS-005-A1**
  - **Given** ARCH-004 has produced 16 ARCH element definitions
  - **When** ARCH-005 (Logical View) sends its output to ARCH-013 (Output Assembler)
  - **Then** the Logical View table contains 16 rows with ARCH ID, Name, Description, Parent Requirements, and Type columns — all non-empty — and ARCH-013 accepts the content

- **Integration Scenario: ITS-005-A2**
  - **Given** ARCH-004 has produced ARCH element definitions including interaction paths
  - **When** ARCH-006 (Process View) sends its Mermaid diagram to ARCH-013
  - **Then** the Process View contains at least one syntactically valid `sequenceDiagram` block with ARCH-NNN participants, and ARCH-013 renders the diagram without errors

- **Integration Scenario: ITS-005-A3**
  - **Given** ARCH-004 has produced ARCH element definitions
  - **When** ARCH-007 (Interface View) sends its contract table to ARCH-013
  - **Then** every ARCH-NNN has a row with Interface Name, Direction, Protocol, Input, Output, and Error Handling columns — no black-box (empty contract) entries

- **Integration Scenario: ITS-005-A4**
  - **Given** ARCH-004 has produced ARCH element definitions with data flow paths
  - **When** ARCH-008 (Data Flow View) sends its transformation chain table to ARCH-013
  - **Then** the Data Flow View shows a complete 10-stage pipeline from Input Validation to Final Assembly with no broken chains

#### Test Case: ITP-005-B (Data Flow — Full Pipeline Stages 4→10)

**Technique**: Data Flow Testing
**Target View**: Data Flow View (Stages 4–10)
**Description**: End-to-end data transformation chain verification from decomposition through final assembly.

- **Integration Scenario: ITS-005-B1**
  - **Given** Data Flow Stage 3 has produced ARCH element definitions
  - **When** the pipeline progresses through Stages 4 (Logical View), 5 (Process View), 6 (Interface View), 7 (Data Flow View), 8 (SWE.2), 9 (Traceability), to Stage 10 (Assembly)
  - **Then** the output at Stage 10 is a complete `software-architecture-design.md` with all sections populated, and the data format at each intermediate stage matches the documented transformation

---

### Module Verification: ARCH-009 (SWE.2 Section Generator)

#### Test Case: ITP-009-A (Domain Gate — iso_26262 Only)

**Technique**: Interface Contract Testing
**Target View**: Interface View (ARCH-009 contract — domain-gated)
**Description**: Verifies that ARCH-009 generates SWE.2 BP1–BP9 sections only when the domain is `iso_26262`, and is skipped for all other domain configurations.

- **Integration Scenario: ITS-009-A1**
  - **Given** ARCH-002 has returned domain `"iso_26262"` and ARCH-003 has loaded the SWE.2 overlay
  - **When** ARCH-009 generates SWE.2 sections and sends output to ARCH-013 (Output Assembler)
  - **Then** the output contains nine BP subsections (BP1 through BP9) with populated content, and ARCH-013 includes them in the final document

- **Integration Scenario: ITS-009-A2**
  - **Given** ARCH-002 has returned `null` (no domain configured)
  - **When** the pipeline reaches the SWE.2 generation stage
  - **Then** ARCH-009 is NOT invoked (skipped), and ARCH-013 assembles the final document without SWE.2 sections

- **Integration Scenario: ITS-009-A3**
  - **Given** ARCH-002 has returned `"do_178c"` and ARCH-003 has loaded the do_178c stub overlay
  - **When** the pipeline checks domain eligibility
  - **Then** ARCH-009 is NOT invoked (domain is not iso_26262), and ARCH-013 assembles the document with IEEE 42010 views only

---

### Module Verification: ARCH-010 (Traceability Summary Generator)

#### Test Case: ITP-010-A (Contract Compliance — Coverage Output)

**Technique**: Interface Contract Testing
**Target View**: Interface View (ARCH-010 contract)
**Description**: Verifies that ARCH-010 correctly computes REQ→ARCH coverage metrics and produces output consumable by ARCH-013.

- **Integration Scenario: ITS-010-A1**
  - **Given** ARCH-004 has produced 16 ARCH elements with parent REQ mappings, and ARCH-001 provided 28 requirements (REQ-001 through REQ-NF-004)
  - **When** ARCH-010 computes coverage and sends the report to ARCH-013 (Output Assembler)
  - **Then** the report contains `total_requirements: 28`, `total_arch_elements: 16`, `covered_requirements: 28`, `coverage_percentage: 100.00`, and `uncovered: []`; ARCH-013 renders it in the Traceability Summary section

- **Integration Scenario: ITS-010-A2**
  - **Given** One REQ-NNN has zero ARCH parents (uncovered gap)
  - **When** ARCH-010 computes coverage
  - **Then** `coverage_percentage < 100%` and the `uncovered` list includes the orphaned REQ ID; ARCH-013 renders the gap in the summary for human review

- **Integration Scenario: ITS-010-A3**
  - **Given** REQ-001 is a parent of both ARCH-001 and ARCH-002 (many-to-many)
  - **When** ARCH-010 computes covered_reqs using a Set
  - **Then** REQ-001 is counted only once (no double-counting), and `covered_requirements` reflects unique coverage

---

### Module Verification: ARCH-011 (Coexistence Detector)

#### Test Case: ITP-011-A (Coexistence — Warning Without Blocking)

**Technique**: Interface Fault Injection
**Target View**: Interface View (ARCH-011 contract) + Process View
**Description**: Verifies that ARCH-011 detects existing Path A artifacts and emits a warning without blocking generation.

- **Integration Scenario: ITS-011-A1**
  - **Given** `architecture-design.md` (Path A artifact) exists in the v-model directory
  - **When** ARCH-011 checks for coexistence before generation begins
  - **Then** ARCH-011 emits a warning message "WARNING: architecture-design.md found — both artifacts will coexist" and returns an OK signal allowing ARCH-013 to proceed with generating `software-architecture-design.md`

- **Integration Scenario: ITS-011-A2**
  - **Given** No `architecture-design.md` exists in the v-model directory
  - **When** ARCH-011 checks for coexistence
  - **Then** ARCH-011 returns `null` (no warning) and the pipeline proceeds silently

---

### Module Verification: ARCH-012 (Lifecycle Manager)

#### Test Case: ITP-012-A (Lifecycle — ID Preservation)

**Technique**: Interface Contract Testing
**Target View**: Interface View (ARCH-012 contract)
**Description**: Verifies that ARCH-012 preserves existing ARCH-NNN IDs and applies correct lifecycle annotations.

- **Integration Scenario: ITS-012-A1**
  - **Given** An existing `software-architecture-design.md` contains ARCH-001 through ARCH-010, and a new generation run produces ARCH-001 through ARCH-016
  - **When** ARCH-012 applies lifecycle rules and sends annotated definitions to ARCH-004
  - **Then** ARCH-001 through ARCH-010 retain their original IDs (not renumbered), and any removed elements are annotated as `[DEPRECATED — Withdrawn: reason]` rather than deleted

- **Integration Scenario: ITS-012-A2**
  - **Given** An existing `software-architecture-design.md` contains ARCH-005 with an outdated description
  - **When** ARCH-012 detects that ARCH-005 has been superseded by a new element
  - **Then** ARCH-005 is annotated as `[DEPRECATED — Superseded by ARCH-017]` and preserved in the output

---

### Module Verification: ARCH-013 (Output Assembler)

#### Test Case: ITP-013-A (Contract Compliance — Final Assembly)

**Technique**: Interface Contract Testing
**Target View**: Interface View (ARCH-013 contract)
**Description**: Verifies that ARCH-013 correctly assembles all sections into a valid `software-architecture-design.md` file.

- **Integration Scenario: ITS-013-A1**
  - **Given** All generators (ARCH-005 through ARCH-010) have produced their sections
  - **When** ARCH-013 assembles the final document using ARCH-016 (Template) structure
  - **Then** The output file contains: header metadata, Overview, ID Schema, four IEEE 42010 views, SWE.2 sections (since domain is iso_26262), and Traceability Summary — in that order

- **Integration Scenario: ITS-013-A2**
  - **Given** ARCH-009 was skipped (domain is not iso_26262)
  - **When** ARCH-013 assembles the final document
  - **Then** The SWE.2 section placeholder from ARCH-016 is replaced with a note "SWE.2 sections omitted — not an ISO 26262 project" rather than left as empty boilerplate

---

### Module Verification: ARCH-015 (ID Pattern Library — Cross-Cutting)

#### Test Case: ITP-015-A (Concurrency — Shared Regex Access)

**Technique**: Concurrency & Race Condition Testing
**Target View**: Process View
**Description**: Verifies that multiple pipeline stages accessing ARCH-015 (ID Pattern Library) concurrently do not cause race conditions or pattern corruption. Although the pipeline is single-threaded, this validates that the regex library is stateless and reentrant.

- **Integration Scenario: ITS-015-A1**
  - **Given** ARCH-001 (Requirements Parser), ARCH-004 (Element Decomposer), and ARCH-010 (Traceability Generator) all request REQ-NNN regex patterns from ARCH-015
  - **When** All three elements access ARCH-015 within the same pipeline execution
  - **Then** Each element receives identical, correct regex pattern objects with no corruption, and pattern matching results are deterministic across all three consumers

#### Test Case: ITP-015-B (Contract Compliance — Pattern Accuracy)

**Technique**: Interface Contract Testing
**Target View**: Interface View (ARCH-015 contract)
**Description**: Verifies that ARCH-015 regex patterns correctly extract V-Model identifiers from Markdown text.

- **Integration Scenario: ITS-015-B1**
  - **Given** Markdown text containing `REQ-001`, `REQ-NF-001`, `REQ-CN-001`, and `ARCH-001`, `ARCH-016`
  - **When** ARCH-015 applies REQ and ARCH regex patterns
  - **Then** The REQ pattern matches all three REQ variants, and the ARCH pattern matches both ARCH variants with correct zero-padded numbers

- **Integration Scenario: ITS-015-B2**
  - **Given** Markdown text containing `SYS-001` and `ITP-001-A` (identifiers from other V-levels)
  - **When** ARCH-015 applies REQ and ARCH regex patterns
  - **Then** Neither `SYS-001` nor `ITP-001-A` is matched (no false positives from adjacent V-levels)

---

### Module Verification: ARCH-014 (Setup Script Adapter)

#### Test Case: ITP-014-A (Contract Compliance — setup-v-model.sh Integration)

**Technique**: Interface Contract Testing
**Target View**: Interface View (ARCH-014 contract)
**Description**: Verifies that ARCH-014 correctly extends setup-v-model.sh with `--require-reqs` flag and AVAILABLE_DOCS detection.

- **Integration Scenario: ITS-014-A1**
  - **Given** `requirements.md` exists in the v-model directory
  - **When** ARCH-014 runs setup-v-model.sh with `--require-reqs --json`
  - **Then** The JSON output contains `REQUIREMENTS` path, `AVAILABLE_DOCS` includes `software-architecture-design.md`, and exit code is 0

- **Integration Scenario: ITS-014-A2**
  - **Given** `requirements.md` does NOT exist in the v-model directory
  - **When** ARCH-014 runs setup-v-model.sh with `--require-reqs`
  - **Then** The script exits with non-zero code and emits error "Requirements file not found — cannot generate software architecture design"

---

### Module Verification: ARCH-016 (Software Architecture Design Template)

#### Test Case: ITP-016-A (Contract Compliance — Template Structure)

**Technique**: Interface Contract Testing
**Target View**: Interface View (ARCH-016 contract)
**Description**: Verifies that the template provides the correct output structure and that ARCH-013 (Output Assembler) can correctly populate all placeholders.

- **Integration Scenario: ITS-016-A1**
  - **Given** ARCH-013 loads the template from `templates/software-architecture-design-template.md`
  - **When** ARCH-013 replaces all section placeholders with generated content from ARCH-005 through ARCH-010
  - **Then** the assembled output has sections in the correct order: Overview, ID Schema, Architecture Design (four IEEE 42010 views), SWE.2 Process Guidance, Traceability Summary, Derived Requirements and Modules, Glossary; no unreplaced `{{...}}` placeholders remain

- **Integration Scenario: ITS-016-A2**
  - **Given** domain is not `iso_26262` (ARCH-009 returned NULL for SWE.2)
  - **When** ARCH-013 assembles output with the template
  - **Then** the SWE.2 section placeholder is replaced with the omission note "SWE.2 sections omitted — not an ISO 26262 project"; no empty SWE.2 heading appears

- **Integration Scenario: ITS-016-A3**
  - **Given** The template contains a `{{DERIVED_ITEMS}}` placeholder and ARCH-004 flagged one `[DERIVED MODULE]`
  - **When** ARCH-013 replaces the placeholder
  - **Then** the derived module flag text appears in the Derived Requirements and Modules section; not left as empty "None" when derived items exist

---

### Module Verification: Architecture Evaluation Integration

#### Test Case: ITP-017-A (Evaluation Gap Propagation)

**Technique**: Interface Fault Injection
**Target View**: Architecture Evaluation (ISO 42030 + ISO 25010)
**Description**: Verifies that `[QUALITY GAP]` and `[ARCH CONCERN]` flags generated during architecture evaluation propagate correctly to the output document and are visible to downstream consumers.

- **Integration Scenario: ITS-017-A1**
  - **Given** The architecture evaluation identifies a quality gap (e.g., Security characteristic not addressed by any ARCH element)
  - **When** ARCH-013 assembles the output with the evaluation sections generated from ARCH-005..ARCH-010
  - **Then** the Architecture Evaluation section in `software-architecture-design.md` contains a `[QUALITY GAP: ISO 25010 §X.X — <characteristic> not explicitly addressed]` flag And the flag is visible in the final output

- **Integration Scenario: ITS-017-A2**
  - **Given** All quality characteristics from the cross-check table are addressed by ARCH elements
  - **When** the Architecture Evaluation is generated
  - **Then** the Quality Attribute Cross-Check table shows all rows as ✅ Addressed And no `[QUALITY GAP]` flags appear

- **Integration Scenario: ITS-017-A3**
  - **Given** A sensitivity point is documented (e.g., ARCH-004 strict translator)
  - **When** the evaluation output is assembled
  - **Then** the Sensitivity and Trade-off Points section documents the sensitivity with affected quality characteristic And the trade-off with improved/degraded characteristics and mitigation

---

## ISO 26262 Domain-Specific Integration Tests

### SIL/HIL Compatibility

The following scenarios verify that the integration test harness can execute in Software-in-the-Loop (SIL) and Hardware-in-the-Loop (HIL) environments per ISO 26262-6 requirements.

| Scenario ID | SIL/HIL Environment | Verification |
|-------------|---------------------|--------------|
| ITS-SIL-001 | SIL — All file I/O mocked; in-memory pipeline | All 16 ARCH elements execute in a pure software environment with no hardware dependencies. ARCH-001, ARCH-002, ARCH-003 use injected file content instead of real disk reads. ARCH-013 writes to an output buffer instead of disk. |
| ITS-SIL-002 | HIL — Real file system with actual v-model directory | ARCH-001 reads a real `requirements.md` fixture. ARCH-002 reads a real `v-model-config.yml`. ARCH-013 writes to actual disk. The complete pipeline validates end-to-end in a realistic environment. |

### Resource Contention

The following scenarios verify that the pipeline does not exhaust shared resources during integration-level execution.

| Scenario ID | Resource | Verification |
|-------------|----------|--------------|
| ITS-RC-001 | Memory — 50+ REQ-NNN input | ARCH-001 parses 50+ requirements. ARCH-004 decomposes into ARCH elements. Peak memory usage remains < 512 MB across the full pipeline. |
| ITS-RC-002 | File Handles — Concurrent readers | ARCH-001 (read requirements), ARCH-002 (read config), ARCH-003 (read overlay), and ARCH-016 (read template) all open file handles within the same pipeline execution. All handles are closed; no file descriptor leaks. |
| ITS-RC-003 | CPU — 10,000-word input | Pipeline completes within 30 seconds wall-clock time (SC-001). No single ARCH element dominates CPU usage. |
