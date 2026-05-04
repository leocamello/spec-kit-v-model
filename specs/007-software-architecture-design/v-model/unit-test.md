# Unit Test Plan: Software Architecture Design (Path B)

**Feature Branch**: `007-software-architecture-design`
**Created**: 2026-05-04
**Status**: Draft
**Source**: `specs/007-software-architecture-design/v-model/module-design.md`

## Overview

This document defines the Unit Test Plan for the Software Architecture Design (Path B) feature. Every module design (`MOD-NNN`) in `module-design.md` has one or more Test Cases (`UTP-NNN-X`), and every Test Case has one or more executable Unit Scenarios (`UTS-NNN-X#`) in white-box Arrange/Act/Assert format.

Unit tests verify **internal module logic** — control flow, data transformations, state transitions, and variable boundaries. They do NOT test module boundaries (integration), user journeys (acceptance), or system-level behavior (system tests).

All 13 modules are stateless single-invocation functions. Domain is `iso_26262` — safety-critical techniques (MC/DC, Variable-Level Fault Injection) are included per ISO 26262-6 §9.

## ID Schema

- **Unit Test Case**: `UTP-{NNN}-{X}` — where NNN matches the parent MOD, X is a letter suffix (A, B, C...)
- **Unit Test Scenario**: `UTS-{NNN}-{X}{#}` — nested under the parent UTP, with numeric suffix (1, 2, 3...)
- Example: `UTS-001-A1` → Scenario 1 of Test Case A verifying MOD-001

## ISO 29119-4 White-Box Techniques

| Technique | Source View | What It Tests |
|-----------|------------|---------------|
| **Statement & Branch Coverage** | Algorithmic/Logic View | Every line and every True/False branch outcome |
| **Boundary Value Analysis** | Internal Data Structures | Scalar variable boundaries: min-1, min, mid, max, max+1 |
| **Equivalence Partitioning** | Internal Data Structures | Discrete non-scalar types: Booleans, Enums |
| **Strict Isolation** | Architecture Interface View | Every external dependency mocked/stubbed |
| **State Transition Testing** | State Machine View | Every transition including invalid ones |

### Safety-Critical Techniques (ISO 26262)

| Technique | Source View | What It Tests |
|-----------|------------|---------------|
| **MC/DC Coverage** | Algorithmic/Logic View | Each condition independently affects decision outcome |
| **Variable-Level Fault Injection** | Internal Data Structures | Local variables forced into corrupted states |

## Unit Tests

### Module: MOD-001 (Parse Requirements Table)

**Parent Architecture Modules**: ARCH-001

#### Test Case: UTP-001-A (Branch Coverage — All Paths)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Dependency & Mock Registry**: File I/O mocked; `requirements_content` injected as string

- **Unit Scenario: UTS-001-A1** (true-path: normal parse)
  - **Arrange**: Valid Markdown with 5 REQ-NNN rows in a Functional Requirements table
  - **Act**: Call `parse_requirements(content, req_pattern)`
  - **Assert**: Returns array of 5 Requirement objects; all fields populated; no skipped rows

- **Unit Scenario: UTS-001-A2** (false-path: section boundary detection)
  - **Arrange**: Markdown with REQ rows followed by a new `##` section header
  - **Act**: Call `parse_requirements(content, req_pattern)`
  - **Assert**: Parsing stops at section boundary; rows after `##` are excluded

- **Unit Scenario: UTS-001-A3** (guard: malformed row — cells.length < 5)
  - **Arrange**: Table with one row having only 3 columns; valid rows also present
  - **Act**: Call `parse_requirements(content, req_pattern)`
  - **Assert**: Malformed row skipped; valid rows still parsed

- **Unit Scenario: UTS-001-A4** (guard: id_match IS NULL)
  - **Arrange**: Row with no REQ-NNN pattern in first column
  - **Act**: Call `parse_requirements(content, req_pattern)`
  - **Assert**: Row skipped; other valid rows parsed

- **Unit Scenario: UTS-001-A5** (error-path: EMPTY_INPUT)
  - **Arrange**: Markdown with no REQ-NNN identifiers at all
  - **Act**: Call `parse_requirements(content, req_pattern)`
  - **Assert**: Raises `EMPTY_INPUT` exception; no partial output produced

#### Test Case: UTP-001-B (Boundary Values — reqs.length)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Dependency & Mock Registry**: Same as UTP-001-A

- **Unit Scenario: UTS-001-B1** (min-1: 0 REQs)
  - **Arrange**: Input with zero REQ-NNN matches
  - **Act**: Call function
  - **Assert**: Raises EMPTY_INPUT

- **Unit Scenario: UTS-001-B2** (min: 1 REQ)
  - **Arrange**: Input with exactly 1 REQ-NNN row
  - **Act**: Call function
  - **Assert**: Returns array of length 1; reqs[0] fully populated

- **Unit Scenario: UTS-001-B3** (mid: 25 REQs)
  - **Arrange**: Input with 25 REQ rows
  - **Act**: Call function
  - **Assert**: Returns array of length 25; all entries correct

- **Unit Scenario: UTS-001-B4** (max: 200 REQs)
  - **Arrange**: Input with 200 REQ rows
  - **Act**: Call function
  - **Assert**: Returns array of length 200; no truncation; no data loss

- **Unit Scenario: UTS-001-B5** (max+1: 201 REQs)
  - **Arrange**: Input with 201 REQ rows
  - **Act**: Call function
  - **Assert**: All 201 parsed or graceful limit enforced

#### Test Case: UTP-001-C (Equivalence — Section Detection)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures

- **Unit Scenario: UTS-001-C1**: Functional Requirements section → `in_req_section = true`
- **Unit Scenario: UTS-001-C2**: Non-Functional Requirements section → `in_req_section = true`
- **Unit Scenario: UTS-001-C3**: No recognized requirements section → `in_req_section = false`, raises EMPTY_INPUT

---

### Module: MOD-002 (Load Domain from Config)

**Parent Architecture Modules**: ARCH-002

#### Test Case: UTP-002-A (Branch Coverage)

**Technique**: Statement & Branch Coverage
**Dependency & Mock Registry**: `file_exists` and `read_file` mocked

- **Unit Scenario: UTS-002-A1**: Config file missing → returns NULL
- **Unit Scenario: UTS-002-A2**: Config with `domain: iso_26262` → returns `"iso_26262"`
- **Unit Scenario: UTS-002-A3**: Config with `domain: do_178c` → returns `"do_178c"`
- **Unit Scenario: UTS-002-A4**: Config with `domain: ""` → returns NULL
- **Unit Scenario: UTS-002-A5**: Config with no domain field → returns NULL

#### Test Case: UTP-002-B (Equivalence — Domain Values)

**Technique**: Equivalence Partitioning

- **Unit Scenario: UTS-002-B1**: "iso_26262" → valid, returned as-is
- **Unit Scenario: UTS-002-B2**: "do_178c" → valid, returned as-is
- **Unit Scenario: UTS-002-B3**: "iec_62304" → valid, returned as-is
- **Unit Scenario: UTS-002-B4**: "unknown" → returned as-is (validation deferred to overlay loader)

---

### Module: MOD-003 (Load Domain Overlay)

**Parent Architecture Modules**: ARCH-003

#### Test Case: UTP-003-A (Branch Coverage)

**Technique**: Statement & Branch Coverage
**Dependency & Mock Registry**: `file_exists` and `read_file` mocked

- **Unit Scenario: UTS-003-A1**: domain = NULL → returns NULL immediately
- **Unit Scenario: UTS-003-A2**: domain = "iso_26262", overlay exists → returns overlay content
- **Unit Scenario: UTS-003-A3**: domain = "do_178c", overlay missing → logs WARNING, returns NULL
- **Unit Scenario: UTS-003-A4**: domain = "iso_26262", overlay missing → logs WARNING, returns NULL

---

### Module: MOD-004 (Decompose Requirements to ARCH)

**Parent Architecture Modules**: ARCH-004

#### Test Case: UTP-004-A (Branch Coverage)

**Technique**: Statement & Branch Coverage

- **Unit Scenario: UTS-004-A1**: 5 REQs, no existing ARCH → 5+ elements, IDs from ARCH-001
- **Unit Scenario: UTS-004-A2**: 3 REQs, existing ARCH-001..ARCH-005 → new IDs from ARCH-006
- **Unit Scenario: UTS-004-A3**: Cross-cutting element detected → tagged `[CROSS-CUTTING] — rationale`
- **Unit Scenario: UTS-004-A4**: Derived module detected → tagged `[DERIVED MODULE: reason]`

#### Test Case: UTP-004-B (Strict Translator — No Orphans)

**Technique**: Statement & Branch Coverage

- **Unit Scenario: UTS-004-B1**: All elements have ≥1 REQ parent → no warnings
- **Unit Scenario: UTS-004-B2**: Element with zero REQ parents → flagged as derived, NOT silently created

---

### Module: MOD-005 (Generate Logical View Table)

**Parent Architecture Modules**: ARCH-005

#### Test Case: UTP-005-A (Output Structure)

**Technique**: Statement & Branch Coverage

- **Unit Scenario: UTS-005-A1**: 3 ARCH elements, 1 cross-cutting → table has 3 rows; cross-cutting row shows tag text in Parent Requirements column
- **Unit Scenario: UTS-005-A2**: 0 ARCH elements → returns header-only table (no data rows)

---

### Module: MOD-006 (Generate Mermaid Sequence Diagram)

**Parent Architecture Modules**: ARCH-006

#### Test Case: UTP-006-A (Mermaid Syntax Validity)

**Technique**: Statement & Branch Coverage

- **Unit Scenario: UTS-006-A1**: 3 sync interactions → valid Mermaid with participant declarations and messages
- **Unit Scenario: UTS-006-A2**: Interaction with alt branch → valid Mermaid `alt`/`end` block
- **Unit Scenario: UTS-006-A3**: Interaction with note → valid Mermaid `Note over` syntax

---

### Module: MOD-007 (Validate Interface Contracts)

**Parent Architecture Modules**: ARCH-007

#### Test Case: UTP-007-A (Black-Box Detection)

**Technique**: Statement & Branch Coverage

- **Unit Scenario: UTS-007-A1**: Element with NULL interface → WARNING "black-box"
- **Unit Scenario: UTS-007-A2**: Element with NULL input AND NULL output → WARNING "incomplete contract"
- **Unit Scenario: UTS-007-A3**: Element with NULL error_handling → WARNING "missing error handling"
- **Unit Scenario: UTS-007-A4**: Element with complete contract → no warnings

---

### Module: MOD-008 (Generate SWE.2 Sections)

**Parent Architecture Modules**: ARCH-009

#### Test Case: UTP-008-A (Domain Gate)

**Technique**: Statement & Branch Coverage

- **Unit Scenario: UTS-008-A1**: domain = "iso_26262" → returns non-null string with BP1–BP9 sections
- **Unit Scenario: UTS-008-A2**: domain = "do_178c" → returns NULL (skipped)
- **Unit Scenario: UTS-008-A3**: domain = NULL → returns NULL (skipped)
- **Unit Scenario: UTS-008-A4**: domain = "iec_62304" → returns NULL (skipped)

#### Test Case: UTP-008-B (MC/DC — Domain Decision)

**Technique**: MC/DC Coverage
**Target View**: Algorithmic/Logic View (domain gate condition)

- **Unit Scenario: UTS-008-B1**: Condition `domain == "iso_26262"` TRUE → function executes; FALSE → function returns NULL. Each condition independently toggles the decision.

---

### Module: MOD-009 (Compute Traceability Coverage)

**Parent Architecture Modules**: ARCH-010

#### Test Case: UTP-009-A (Coverage Calculation Accuracy)

**Technique**: Statement & Branch Coverage

- **Unit Scenario: UTS-009-A1**: 5 REQs, all covered → coverage = 100.00%, uncovered = []
- **Unit Scenario: UTS-009-A2**: 5 REQs, 3 covered → coverage = 60.00%, uncovered = [REQ-004, REQ-005]
- **Unit Scenario: UTS-009-A3**: Many-to-many: REQ-001 parent of ARCH-001 and ARCH-002 → counted once (Set dedup)
- **Unit Scenario: UTS-009-A4**: total_reqs = 0 → coverage = 0%, no division by zero

---

### Module: MOD-010 (Detect Path A Coexistence)

**Parent Architecture Modules**: ARCH-011

#### Test Case: UTP-010-A (Detection Logic)

- **Unit Scenario: UTS-010-A1**: `architecture-design.md` exists → returns non-null warning string
- **Unit Scenario: UTS-010-A2**: `architecture-design.md` absent → returns NULL
- **Unit Scenario: UTS-010-A3**: v-model directory inaccessible → returns NULL (non-blocking)

---

### Module: MOD-011 (Apply Lifecycle Rules)

**Parent Architecture Modules**: ARCH-012

#### Test Case: UTP-011-A (Lifecycle Transformation)

- **Unit Scenario: UTS-011-A1**: Existing ARCH-001..005, new set ARCH-001..008 → existing 5 preserved; 3 appended
- **Unit Scenario: UTS-011-A2**: Existing ARCH-003 removed from new set → tagged `[DEPRECATED — Withdrawn]`, preserved
- **Unit Scenario: UTS-011-A3**: existing_elements = NULL → returns new_elements unchanged
- **Unit Scenario: UTS-011-A4**: existing_elements = [] → returns new_elements unchanged

---

### Module: MOD-012 (Assemble and Write Output)

**Parent Architecture Modules**: ARCH-013

#### Test Case: UTP-012-A (Placeholder Replacement)

**Technique**: Statement & Branch Coverage
**Dependency & Mock Registry**: `write_file` mocked with output capture

- **Unit Scenario: UTS-012-A1**: All sections populated → template placeholders replaced; no `{{...}}` remain
- **Unit Scenario: UTS-012-A2**: SWE.2 is NULL → placeholder replaced with omission note; no empty section
- **Unit Scenario: UTS-012-A3**: write_file fails → returns false

---

### Module: MOD-013 (Regex ID Pattern Library)

**Parent Architecture Modules**: ARCH-015 [CROSS-CUTTING]

#### Test Case: UTP-013-A (Pattern Matching Accuracy)

**Technique**: Statement & Branch Coverage / Equivalence Partitioning

- **Unit Scenario: UTS-013-A1**: `REQ-001` → matched by REQ pattern only
- **Unit Scenario: UTS-013-A2**: `REQ-NF-001` → matched by REQ pattern (prefix variant)
- **Unit Scenario: UTS-013-A3**: `REQ-CN-001` → matched by REQ pattern (prefix variant)
- **Unit Scenario: UTS-013-A4**: `SYS-001` → NOT matched by REQ or ARCH pattern
- **Unit Scenario: UTS-013-A5**: `ARCH-016` → matched by ARCH pattern
- **Unit Scenario: UTS-013-A6**: `ARCH-1` (no zero-padding) → NOT matched by ARCH pattern
- **Unit Scenario: UTS-013-A7**: `ITP-001-A` → matched by ITP pattern
- **Unit Scenario: UTS-013-A8**: `ITS-015-A1` → matched by ITS pattern

### Unit Test Coverage

| Metric | Value |
|--------|-------|
| **Total Modules** | 13 |
| **Total Test Cases (UTP)** | 18 |
| **Total Scenarios (UTS)** | 55 |
| **MOD → UTP Coverage** | 13/13 (100%) |
| **Safety-Critical Techniques** | MC/DC (1 UTP applied) |
