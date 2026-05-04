# Acceptance Test Plan: Software Architecture Design (Path B)

**Feature Branch**: `007-software-architecture-design`
**Created**: 2026-05-04
**Status**: Draft
**Source**: `specs/007-software-architecture-design/v-model/requirements.md`

## Overview

This document defines the Acceptance Test Plan for the Software Architecture Design (Path B) feature. Every requirement in `requirements.md` has one or more Test Cases (ATP), and every Test Case has one or more executable User Scenarios (SCN) in BDD format (Given/When/Then).

## ID Schema

- **Test Case**: `ATP-{NNN}-{X}` — where NNN matches the parent REQ, X is a letter suffix (A, B, C...)
- **Scenario**: `SCN-{NNN}-{X}{#}` — nested under the parent ATP, with numeric suffix (1, 2, 3...)
- Example: `SCN-001-A1` → Scenario 1 of Test Case A validating REQ-001

## Acceptance Tests

### Requirement Validation: REQ-001 (Command Existence)

#### Test Case: ATP-001-A (Happy Path — Command Produces software-architecture-design.md)

**Linked Requirement:** REQ-001
**Description:** Verify the `/speckit.v-model.software-architecture-design` command reads `requirements.md` and produces `software-architecture-design.md` without depending on `system-design.md`.

- **User Scenario: SCN-001-A1**
  - **Given** a `requirements.md` file exists in `{FEATURE_DIR}/v-model/` containing at least one `REQ-NNN` identifier
  - **When** the user invokes `/speckit.v-model.software-architecture-design`
  - **Then** a `software-architecture-design.md` file is created in `{FEATURE_DIR}/v-model/` And the file is non-empty And contains at least one `ARCH-NNN` identifier And no `system-design.md` was required

#### Test Case: ATP-001-B (Error — Missing requirements.md)

**Linked Requirement:** REQ-001, REQ-020
**Description:** Verify the command fails gracefully when `requirements.md` is missing.

- **User Scenario: SCN-001-B1**
  - **Given** the `{FEATURE_DIR}/v-model/` directory exists And no `requirements.md` file is present
  - **When** the user invokes `/speckit.v-model.software-architecture-design`
  - **Then** the command outputs an error message containing "requirements.md" And no `software-architecture-design.md` file is created

---

### Requirement Validation: REQ-002 (ARCH-NNN Identifier Assignment)

#### Test Case: ATP-002-A (Sequential ARCH-NNN Format)

**Linked Requirement:** REQ-002
**Description:** Verify each architecture element is assigned a unique `ARCH-NNN` identifier in 3-digit zero-padded sequential order.

- **User Scenario: SCN-002-A1**
  - **Given** a `requirements.md` exists with 10 functional requirements
  - **When** the user invokes `/speckit.v-model.software-architecture-design`
  - **Then** every element in `software-architecture-design.md` has an ID matching the regex `^ARCH-\d{3}$` And IDs are sequentially numbered starting from `ARCH-001`

#### Test Case: ATP-002-B (ID Permanence on Regeneration)

**Linked Requirement:** REQ-002, REQ-019
**Description:** Verify that regenerating does not renumber existing ARCH-NNN identifiers.

- **User Scenario: SCN-002-B1**
  - **Given** a `software-architecture-design.md` exists containing `ARCH-001` through `ARCH-010` And `requirements.md` has been updated with new requirements
  - **When** the user invokes `/speckit.v-model.software-architecture-design`
  - **Then** the original `ARCH-001` through `ARCH-010` retain their identifiers And new elements are appended as `ARCH-011` or higher

---

### Requirement Validation: REQ-003 (Logical View)

#### Test Case: ATP-003-A (Logical View Present and Complete)

**Linked Requirement:** REQ-003, REQ-021, REQ-023
**Description:** Verify `software-architecture-design.md` includes a Logical View with ARCH elements, parent REQ references, type classification, and business-logic vs cross-cutting distinction.

- **User Scenario: SCN-003-A1**
  - **Given** a `requirements.md` exists with REQ-001 through REQ-005
  - **When** the user inspects the generated `software-architecture-design.md`
  - **Then** the file contains a "Logical View" section And each `ARCH-NNN` entry includes Name, Description, Parent Requirements (comma-separated `REQ-NNN`), and Type And cross-cutting elements are visibly distinguished

---

### Requirement Validation: REQ-004 (Process View)

#### Test Case: ATP-004-A (Process View with Mermaid Diagrams)

**Linked Requirement:** REQ-004
**Description:** Verify the Process View contains Mermaid sequence diagrams documenting runtime interactions.

- **User Scenario: SCN-004-A1**
  - **Given** the architecture has been decomposed into ARCH elements
  - **When** the user inspects the Process View section
  - **Then** the section contains at least one syntactically valid Mermaid `sequenceDiagram` block And participants are labeled with `ARCH-NNN` identifiers And execution order and synchronization points are documented

---

### Requirement Validation: REQ-005 (Interface View)

#### Test Case: ATP-005-A (Interface View Contracts Complete)

**Linked Requirement:** REQ-005
**Description:** Verify every ARCH element has a documented interface contract in the Interface View.

- **User Scenario: SCN-005-A1**
  - **Given** `software-architecture-design.md` has been generated with N ARCH elements
  - **When** the user inspects the Interface View table
  - **Then** every `ARCH-NNN` has a row with Interface Name, Direction, Protocol, Input, Output, and Error Handling columns And no row has empty contract fields (no black-box descriptions)

---

### Requirement Validation: REQ-006 (Data Flow View)

#### Test Case: ATP-006-A (Data Flow View Complete Chain)

**Linked Requirement:** REQ-006
**Description:** Verify the Data Flow View traces the complete transformation pipeline.

- **User Scenario: SCN-006-A1**
  - **Given** `software-architecture-design.md` has been generated
  - **When** the user inspects the Data Flow View table
  - **Then** the table shows a complete transformation chain from input (requirements.md) to output (final document) And each stage documents input format, transformation, and output format And no chain is broken (missing intermediate stages)

---

### Requirement Validation: REQ-007 (Strict REQ→ARCH Traceability)

#### Test Case: ATP-007-A (No SYS References in Path B)

**Linked Requirement:** REQ-007
**Description:** Verify Path B ARCH elements trace strictly to `REQ-NNN` and never reference `SYS-NNN`.

- **User Scenario: SCN-007-A1**
  - **Given** a `system-design.md` exists alongside `requirements.md` (both Path A and Path B inputs present)
  - **When** the user invokes `/speckit.v-model.software-architecture-design`
  - **Then** the generated `ARCH-NNN` elements reference only `REQ-NNN` identifiers in their parent requirements And no `SYS-NNN` identifiers appear as parents

---

### Requirement Validation: REQ-008 (Domain Overlay — iso_26262)

#### Test Case: ATP-008-A (SWE.2 Sections Generated for iso_26262)

**Linked Requirement:** REQ-008, REQ-011
**Description:** Verify SWE.2 BP1–BP9 sections are included when domain is `iso_26262`.

- **User Scenario: SCN-008-A1**
  - **Given** `v-model-config.yml` contains `domain: iso_26262` And `commands/overlays/iso_26262/software-architecture-design.md` exists
  - **When** the user invokes `/speckit.v-model.software-architecture-design`
  - **Then** the output contains an "ASPICE SWE.2 Process Guidance" section And all nine BP subsections (BP1–BP9) are populated with non-placeholder content

#### Test Case: ATP-008-B (SWE.2 Sections Omitted for Non-iso_26262)

**Linked Requirement:** REQ-008, REQ-009, REQ-010
**Description:** Verify SWE.2 sections are absent when domain is not `iso_26262`.

- **User Scenario: SCN-008-B1**
  - **Given** `v-model-config.yml` contains `domain: do_178c`
  - **When** the user invokes `/speckit.v-model.software-architecture-design`
  - **Then** the output does NOT contain SWE.2 sections And only IEEE 42010 views are present

- **User Scenario: SCN-008-B2**
  - **Given** `v-model-config.yml` is absent or `domain` is empty
  - **When** the user invokes `/speckit.v-model.software-architecture-design`
  - **Then** the output does NOT contain SWE.2 sections And no domain-specific regulatory references appear

---

### Requirement Validation: REQ-012 (Path A Coexistence Warning)

#### Test Case: ATP-012-A (Warning When architecture-design.md Exists)

**Linked Requirement:** REQ-012
**Description:** Verify a warning is emitted when Path A artifact exists, but generation proceeds.

- **User Scenario: SCN-012-A1**
  - **Given** `architecture-design.md` (Path A) already exists in the v-model directory
  - **When** the user invokes `/speckit.v-model.software-architecture-design`
  - **Then** the command emits a warning message about coexistence And `software-architecture-design.md` is still generated And both artifacts exist in the directory

---

### Requirement Validation: REQ-013 (Strict Translator Constraint)

#### Test Case: ATP-013-A (No Invented ARCH Elements)

**Linked Requirement:** REQ-013
**Description:** Verify the command does not invent architecture elements beyond what requirements specify.

- **User Scenario: SCN-013-A1**
  - **Given** a `requirements.md` with 5 explicit functional requirements
  - **When** the user invokes `/speckit.v-model.software-architecture-design`
  - **Then** every `ARCH-NNN` in the output traces to at least one `REQ-NNN` from the input And no ARCH element exists without a parent requirement

---

### Requirement Validation: REQ-014/015 (Derived Items)

#### Test Case: ATP-014-A (Derived Module Flagged)

**Linked Requirement:** REQ-014, REQ-015
**Description:** Verify that necessary but untraceable elements are flagged as derived rather than silently created.

- **User Scenario: SCN-014-A1**
  - **Given** the architecture requires a technical element (e.g., logging) that has no corresponding `REQ-NNN`
  - **When** the command identifies this gap during decomposition
  - **Then** the element is flagged as `[DERIVED MODULE: reason]` And the flag is visible in the output And no `ARCH-NNN` is silently assigned

---

### Requirement Validation: REQ-016 (Traceability Summary)

#### Test Case: ATP-016-A (Coverage Metrics Present)

**Linked Requirement:** REQ-016
**Description:** Verify the output includes traceability summary with REQ→ARCH mapping and coverage metrics.

- **User Scenario: SCN-016-A1**
  - **Given** `software-architecture-design.md` has been generated
  - **When** the user inspects the Traceability Summary section
  - **Then** the section contains a REQ→ARCH mapping table And coverage metrics include total requirements, total ARCH elements, and forward coverage percentage

---

### Requirement Validation: REQ-019 (Lifecycle Preservation)

#### Test Case: ATP-019-A (Deprecated Modules Preserved)

**Linked Requirement:** REQ-019
**Description:** Verify deprecated modules are preserved with annotations, not deleted.

- **User Scenario: SCN-019-A1**
  - **Given** a regeneration removes an ARCH element that existed in the previous version
  - **When** the user invokes `/speckit.v-model.software-architecture-design`
  - **Then** the removed element appears as `[DEPRECATED — Withdrawn: reason]` And is NOT deleted from the output

---

### Requirement Validation: REQ-022 (Cross-Cutting Tagging)

#### Test Case: ATP-022-A (Cross-Cutting Elements Tagged with Rationale)

**Linked Requirement:** REQ-022
**Description:** Verify infrastructure/utility elements are tagged as `[CROSS-CUTTING]` with rationale.

- **User Scenario: SCN-022-A1**
  - **Given** the architecture includes a shared utility (e.g., ID Pattern Library) serving multiple elements
  - **When** the user inspects the Logical View
  - **Then** the utility element's Parent Requirements column shows `[CROSS-CUTTING] — rationale` And the element still has at least one `REQ-NNN` parent

---

### Non-Functional Requirements

#### Test Case: ATP-NF-001-A (Performance < 30s)

**Linked Requirement:** REQ-NF-001
**Description:** Verify the command completes within the performance target.

- **User Scenario: SCN-NF-001-A1**
  - **Given** a `requirements.md` with up to 10,000 words
  - **When** the user invokes `/speckit.v-model.software-architecture-design`
  - **Then** the command completes in under 30 seconds wall-clock time

#### Test Case: ATP-NF-002-A (All Four Views Populated)

**Linked Requirement:** REQ-NF-002
**Description:** Verify all four IEEE 42010 views are populated with non-placeholder content.

- **User Scenario: SCN-NF-002-A1**
  - **Given** `software-architecture-design.md` has been generated
  - **When** the user inspects each view section
  - **Then** the Logical View table has ≥1 populated row And the Process View has ≥1 sequence diagram And the Interface View table has ≥1 populated row And the Data Flow View table has ≥1 populated row

#### Test Case: ATP-NF-003-A (50+ Requirements Without Truncation)

**Linked Requirement:** REQ-NF-003
**Description:** Verify the command handles large requirement sets without data loss.

- **User Scenario: SCN-NF-003-A1**
  - **Given** a `requirements.md` containing 50+ `REQ-NNN` identifiers
  - **When** the user invokes `/speckit.v-model.software-architecture-design`
  - **Then** all 50+ requirements are represented in the REQ→ARCH mapping And no requirements are truncated or lost

#### Test Case: ATP-NF-004-A (SWE.2 Score ≥ 90% for iso_26262)

**Linked Requirement:** REQ-NF-004
**Description:** Verify SWE.2 compliance score meets the 90% threshold when domain is iso_26262.

- **User Scenario: SCN-NF-004-A1**
  - **Given** `domain: iso_26262` is configured And `software-architecture-design.md` has been generated
  - **When** the output is evaluated against SWE.2 BP1–BP9 criteria
  - **Then** the compliance score is ≥ 90% (at least 8 of 9 base practices fully addressed)

### Acceptance Coverage

| Metric | Value |
|--------|-------|
| **Total Requirements** | 28 |
| **Total Test Cases (ATP)** | 20 |
| **Total Scenarios (SCN)** | 22 |
| **REQ → ATP Coverage** | 28/28 (100%) |
| **ATP → SCN Coverage** | 20/20 (100%) |
