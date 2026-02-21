# Integration Test Plan: [FEATURE NAME]

**Feature Branch**: `[###-feature-name]`
**Created**: [DATE]
**Status**: Draft
**Source**: `specs/[###-feature-name]/v-model/architecture-design.md`

## Overview

This document defines the Integration Test Plan for [FEATURE NAME]. Every architecture module
in `architecture-design.md` has one or more Test Cases (ITP), and every Test Case has one or
more executable Integration Scenarios (ITS) in module-boundary BDD format (Given/When/Then).

Integration tests verify **seams and handshakes between modules**, not internal logic or user
journeys. Language must be module-boundary-oriented.

## ID Schema

- **Integration Test Case**: `ITP-{NNN}-{X}` — where NNN matches the parent ARCH, X is a letter suffix (A, B, C...)
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

<!--
  For EACH architecture module in architecture-design.md, generate:
  1. One or more Test Cases (ITP-NNN-X) — the logical verification condition
  2. One or more Integration Scenarios (ITS-NNN-X#) — module-boundary BDD Given/When/Then

  RULES:
  - Every ARCH-NNN must have at least one ITP-NNN-X
  - Every ITP-NNN-X must have at least one ITS-NNN-X#
  - Each ITP must name its ISO 29119-4 technique
  - Each ITP must reference which architecture view it targets
  - ITS language must be module-boundary-oriented (NO user-journey or internal-logic phrases)
  - Cross-cutting [CROSS-CUTTING] modules must have at least one ITP
  - Do NOT renumber existing IDs when updating
  - Append new items; update modified items in-place by ID

  PROHIBITED phrases in ITS (belong in acceptance scenarios):
  - "the user clicks", "the user sees", "the user navigates"
  - "the user enters", "the user selects", "the user receives"

  PROHIBITED phrases in ITS (belong in unit tests):
  - "the function returns", "the method throws", "the class initializes"
  - "the variable contains", "the loop iterates"

  REQUIRED language style:
  - "Module [ARCH-NNN] sends [data] to Module [ARCH-NNN]"
  - "Module [ARCH-NNN] receives [malformed input] from Module [ARCH-NNN]"
  - "the handshake between [ARCH-NNN] and [ARCH-NNN] completes within [threshold]"
  - "Module [ARCH-NNN] rejects the payload and returns [error] to Module [ARCH-NNN]"
-->

### Module Verification: ARCH-001 ([Module Name])

**Parent System Components**: SYS-001, SYS-002

#### Test Case: ITP-001-A ([Verification Condition])

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: [What this test verifies about the module's boundary behavior]

* **Integration Scenario: ITS-001-A1**
  * **Given** [module state / boundary precondition]
  * **When** [module-to-module interaction / API call / message]
  * **Then** [expected boundary behavior / contract compliance]

* **Integration Scenario: ITS-001-A2**
  * **Given** [error precondition at module boundary]
  * **When** [invalid input crosses module boundary]
  * **Then** [expected error propagation / rejection behavior]

#### Test Case: ITP-001-B ([Verification Condition])

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: [What this test verifies about failure behavior at module boundary]

* **Integration Scenario: ITS-001-B1**
  * **Given** [dependency module is unavailable / returns malformed data]
  * **When** [source module attempts interaction]
  * **Then** [expected graceful degradation / isolation behavior]

---

### Module Verification: ARCH-002 ([Module Name])

**Parent System Components**: SYS-003

#### Test Case: ITP-002-A ([Verification Condition])

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: [What this test verifies about data transformation across boundaries]

* **Integration Scenario: ITS-002-A1**
  * **Given** [data enters the transformation chain at ARCH-NNN]
  * **When** [data passes through the module boundary to ARCH-NNN]
  * **Then** [output format matches expected intermediate/final format]

---

[Continue for all architecture modules...]

## Test Harness & Mocking Strategy

<!--
  For each test case, define what stubs/mocks are needed.
  This section helps auditors understand how external dependencies
  and unresolved module dependencies are handled during testing.
-->

| Test Case | External Dependency | Mock/Stub Strategy | Rationale |
|-----------|--------------------|--------------------|-----------|
| ITP-001-A | [Dependency] | [Mock type: stub/fake/spy] | [Why this approach] |
| ITP-001-B | [Dependency] | [Mock type] | [Why this approach] |

<!-- SAFETY-CRITICAL SECTION: Only include when v-model-config.yml domain is set -->

<!--
## SIL/HIL Compatibility (ISO 26262 + DO-178C)

| Test Case | SIL/HIL Target | Environment | Adaptation Notes |
|-----------|---------------|-------------|-----------------|
| ITP-NNN-X | SIL / HIL | [Environment name] | [How to adapt for target] |

## Resource Contention (ISO 26262 + DO-178C)

| Test Case | Shared Resource | Contention Scenario | Expected Behavior |
|-----------|----------------|--------------------|--------------------|
| ITP-NNN-X | [Memory / CPU / Bus / etc.] | [How contention occurs] | [Expected outcome] |
-->

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Architecture Modules (ARCH) | [N] |
| Total Test Cases (ITP) | [N] |
| Total Scenarios (ITS) | [N] |
| Modules with ≥1 ITP | [N] / [N] ([%]) |
| Test Cases with ≥1 ITS | [N] / [N] ([%]) |
| **Overall Coverage (ARCH→ITP)** | **[%]** |

### Technique Distribution

| Technique | Test Cases | Percentage |
|-----------|-----------|------------|
| Interface Contract Testing | [N] | [%] |
| Data Flow Testing | [N] | [%] |
| Interface Fault Injection | [N] | [%] |
| Concurrency & Race Condition Testing | [N] | [%] |

## Uncovered Modules

<!--
  Populated by validate-architecture-coverage.sh.
  If coverage is 100%, this section should read "None — full coverage achieved."
-->

[List of ARCH-NNN IDs without any ITP, or "None — full coverage achieved."]
