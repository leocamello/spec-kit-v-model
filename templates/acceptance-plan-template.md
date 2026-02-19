# Acceptance Test Plan: [FEATURE NAME]

**Feature Branch**: `[###-feature-name]`
**Created**: [DATE]
**Status**: Draft
**Source**: `specs/[###-feature-name]/v-model/requirements.md`

## Overview

This document defines the Acceptance Test Plan for [FEATURE NAME]. Every requirement
in `requirements.md` has one or more Test Cases (ATP), and every Test Case has one or
more executable User Scenarios (SCN) in BDD format (Given/When/Then).

## ID Schema

- **Test Case**: `ATP-{NNN}-{X}` — where NNN matches the parent REQ, X is a letter suffix (A, B, C...)
- **Scenario**: `SCN-{NNN}-{X}{#}` — nested under the parent ATP, with numeric suffix (1, 2, 3...)
- Example: `SCN-001-A1` → Scenario 1 of Test Case A validating REQ-001

## Acceptance Tests

<!--
  For EACH requirement in requirements.md, generate:
  1. One or more Test Cases (ATP-NNN-X) — the logical validation condition
  2. One or more User Scenarios (SCN-NNN-X#) — BDD Given/When/Then executable steps

  RULES:
  - Every REQ-NNN must have at least one ATP-NNN-X
  - Every ATP-NNN-X must have at least one SCN-NNN-X#
  - Do NOT renumber existing IDs when updating
  - Do NOT alter existing ATPs/SCNs unless their parent REQ was modified
  - Append new items; update modified items in-place by ID
-->

### Requirement Validation: REQ-001 ([Brief Title])

#### Test Case: ATP-001-A ([Condition Name])

**Description:** [What this test validates]

* **User Scenario: SCN-001-A1**
  * **Given** [initial state/precondition]
  * **When** [action performed]
  * **Then** [expected outcome]

#### Test Case: ATP-001-B ([Condition Name])

**Description:** [What this test validates — e.g., error/edge case for REQ-001]

* **User Scenario: SCN-001-B1**
  * **Given** [initial state/precondition]
  * **When** [action performed]
  * **Then** [expected outcome]

---

### Requirement Validation: REQ-002 ([Brief Title])

#### Test Case: ATP-002-A ([Condition Name])

**Description:** [What this test validates]

* **User Scenario: SCN-002-A1**
  * **Given** [initial state/precondition]
  * **When** [action performed]
  * **Then** [expected outcome]

---

[Continue for all requirements...]

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Requirements (REQ) | [N] |
| Total Test Cases (ATP) | [N] |
| Total Scenarios (SCN) | [N] |
| Requirements with ≥1 ATP | [N] / [N] ([%]) |
| Test Cases with ≥1 SCN | [N] / [N] ([%]) |
| **Overall Coverage** | **[%]** |

## Uncovered Requirements

<!--
  This section is populated by the validation gate script.
  If coverage is 100%, this section should read "None — full coverage achieved."
-->

[List of REQ-NNN IDs without any ATP, or "None — full coverage achieved."]
