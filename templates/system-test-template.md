# System Test Plan: [FEATURE NAME]

**Feature Branch**: `[###-feature-name]`
**Created**: [DATE]
**Status**: Draft
**Source**: `specs/[###-feature-name]/v-model/system-design.md`

## Overview

This document defines the System Test Plan for [FEATURE NAME]. Every system component
in `system-design.md` has one or more Test Cases (STP), and every Test Case has one or
more executable System Scenarios (STS) in technical BDD format (Given/When/Then).

System tests verify **architectural behavior**, not user journeys. Language must be
technical and component-oriented.

## ID Schema

- **System Test Case**: `STP-{NNN}-{X}` — where NNN matches the parent SYS, X is a letter suffix (A, B, C...)
- **System Test Scenario**: `STS-{NNN}-{X}{#}` — nested under the parent STP, with numeric suffix (1, 2, 3...)
- Example: `STS-001-A1` → Scenario 1 of Test Case A verifying SYS-001

## ISO 29119 Test Techniques

Each test case MUST identify its technique by name:
- **Interface Contract Testing** — Verifies API contracts from the Interface View
- **Boundary Value Analysis** — Tests data limits from the Data Design View
- **Equivalence Partitioning** — Tests representative data classes
- **Fault Injection** — Tests failure propagation from the Dependency View

## System Tests

<!--
  For EACH system component in system-design.md, generate:
  1. One or more Test Cases (STP-NNN-X) — the logical verification condition
  2. One or more System Scenarios (STS-NNN-X#) — technical BDD Given/When/Then

  RULES:
  - Every SYS-NNN must have at least one STP-NNN-X
  - Every STP-NNN-X must have at least one STS-NNN-X#
  - Each STP must name its ISO 29119 technique
  - Each STP must reference the IEEE 1016 design view it targets
  - STS language must be technical/component-oriented (NO user-journey phrases)
  - Prohibited phrases in STS: "the user clicks", "the user sees", "the user navigates"
  - Do NOT renumber existing IDs when updating
  - Append new items; update modified items in-place by ID
-->

### Component Verification: SYS-001 ([Component Name])

**Parent Requirements**: REQ-001, REQ-002

#### Test Case: STP-001-A ([Verification Condition])

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: [What this test verifies about the component's behavior]

* **System Scenario: STS-001-A1**
  * **Given** [component state / system precondition]
  * **When** [component action / API call / event]
  * **Then** [expected component behavior / output / state change]

* **System Scenario: STS-001-A2**
  * **Given** [error precondition]
  * **When** [invalid input / failure condition]
  * **Then** [expected error handling / degradation behavior]

#### Test Case: STP-001-B ([Verification Condition])

**Technique**: Fault Injection
**Target View**: Dependency View
**Description**: [What this test verifies about failure behavior]

* **System Scenario: STS-001-B1**
  * **Given** [dependency failure precondition]
  * **When** [component attempts operation]
  * **Then** [expected isolation / fallback behavior]

---

### Component Verification: SYS-002 ([Component Name])

**Parent Requirements**: REQ-003

#### Test Case: STP-002-A ([Verification Condition])

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: [What this test verifies about data handling]

* **System Scenario: STS-002-A1**
  * **Given** [data at boundary condition]
  * **When** [component processes the data]
  * **Then** [expected behavior at boundary]

---

[Continue for all system components...]

<!-- SAFETY-CRITICAL SECTION: Only include when v-model-config.yml domain is set -->

<!--
## Structural Coverage (DO-178C §6.4.4.2 / ISO 26262-6 §9.4.5)

| Component | Coverage Target | Technique | Rationale |
|-----------|----------------|-----------|-----------|
| SYS-NNN | MC/DC 100% | Modified Condition/Decision Coverage | [ASIL/DAL level] |

## Resource Usage Testing (DO-178C §6.3.4 / ISO 26262-6 §9.4.4)

| Component | Resource | Measurement | Threshold | Verification Method |
|-----------|----------|-------------|-----------|---------------------|
| SYS-NNN | WCET | [metric] | [max] | [How measured] |
| SYS-NNN | Max Stack Depth | [metric] | [max] | [How measured] |
| SYS-NNN | Heap Usage | [metric] | [max] | [How measured] |
-->

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total System Components (SYS) | [N] |
| Total Test Cases (STP) | [N] |
| Total Scenarios (STS) | [N] |
| Components with ≥1 STP | [N] / [N] ([%]) |
| Test Cases with ≥1 STS | [N] / [N] ([%]) |
| **Overall Coverage (SYS→STP)** | **[%]** |

## Uncovered Components

<!--
  Populated by validate-system-coverage.sh.
  If coverage is 100%, this section should read "None — full coverage achieved."
-->

[List of SYS-NNN IDs without any STP, or "None — full coverage achieved."]
