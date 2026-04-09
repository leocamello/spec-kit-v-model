---
title: "Level 1: Requirements ↔ Acceptance Testing"
description: Define traceable requirements and generate paired acceptance test plans with 100% coverage — the outermost level of the V-Model.
---

# Level 1: Requirements ↔ Acceptance Testing

The outermost level of the V-Model pairs **Requirements Analysis** (left side) with **Acceptance Testing** (right side). This level answers the most fundamental question: *does the system do what the user asked for?*

---

## When to Use This Level

!!! tip "Start here"

    Level 1 is the **minimum viable V-Model**. Even if you don't go deeper into system design or module-level specs, requirements + acceptance testing gives you traceable, testable specifications from day one.

Use this level when you need to:

- Define **what** the system must do (requirements)
- Prove **that it does it** (acceptance tests)
- Demonstrate coverage to an auditor or reviewer

---

## Commands

### `/speckit.v-model.requirements`

Transforms a feature description or existing `spec.md` into a structured Requirements Specification with unique, traceable `REQ-NNN` IDs.

```bash
# From the Spec Kit CLI
/speckit.v-model.requirements
```

**What it produces:**

- A `requirements.md` file in `specs/{feature}/v-model/`
- Every requirement gets a unique ID: `REQ-NNN`
- Requirements are validated against **8 quality criteria** from IEEE 29148 and INCOSE
- Priority levels: P1 (Critical), P2 (Important), P3 (Nice-to-have)

**Requirement categories:**

| Category | ID Format | Example |
|---|---|---|
| Functional | `REQ-NNN` | `REQ-001` |
| Non-Functional | `REQ-NF-NNN` | `REQ-NF-001` |
| Interface | `REQ-IF-NNN` | `REQ-IF-001` |
| Constraint | `REQ-CN-NNN` | `REQ-CN-001` |

### `/speckit.v-model.acceptance`

Generates a three-tier Acceptance Test Plan that pairs every requirement with test cases and BDD scenarios.

```bash
/speckit.v-model.acceptance
```

**What it produces:**

- An `acceptance-plan.md` file in `specs/{feature}/v-model/`
- **Test Cases** (`ATP-NNN-X`) — logical validation conditions for each requirement
- **Scenarios** (`SCN-NNN-X#`) — executable BDD Given/When/Then paths
- 100% coverage enforced: every `REQ` has at least one `ATP`, every `ATP` has at least one `SCN`

!!! note "Incremental updates"

    If `acceptance-plan.md` already exists, the command detects added, modified, and removed requirements using `diff-requirements.sh`. Only affected test cases are regenerated — unchanged requirements keep their existing ATPs and SCNs.

---

## ID Schema

Level 1 uses a three-tier ID hierarchy:

| Tier | ID Format | Example | Meaning |
|---|---|---|---|
| Requirement | `REQ-NNN` | `REQ-001` | A discrete, testable requirement |
| Test Case | `ATP-NNN-X` | `ATP-001-A` | A logical test condition for REQ-001 |
| Scenario | `SCN-NNN-X#` | `SCN-001-A1` | An executable BDD scenario for ATP-001-A |

Reading `SCN-001-A1` tells you: this scenario validates test case `ATP-001-A`, which tests requirement `REQ-001`. No lookup table needed.

### Quick Example: Temperature Monitoring

```markdown
## REQ-001: Temperature Alert Threshold

The system SHALL trigger a high-temperature alert when sensor readings
exceed 38.5°C for more than 30 consecutive seconds.

### ATP-001-A: Normal-to-Alert Transition
Verify the system transitions from normal to alert state.

#### SCN-001-A1: Sustained High Temperature
Given the sensor reads 39.0°C
When 30 seconds have elapsed
Then a high-temperature alert is triggered

#### SCN-001-A2: Brief Spike (No Alert)
Given the sensor reads 39.0°C
When only 15 seconds have elapsed
Then no alert is triggered

### ATP-001-B: Alert Persistence
Verify the alert persists until temperature returns to normal.

#### SCN-001-B1: Temperature Returns Below Threshold
Given a high-temperature alert is active
When the sensor reads 37.0°C for 10 seconds
Then the alert is cleared
```

---

## Validator

### `validate-requirement-coverage.sh`

Deterministic coverage validation that parses `requirements.md` and `acceptance-plan.md` to verify 100% bi-directional coverage.

=== "Bash"

    ```bash
    scripts/bash/validate-requirement-coverage.sh specs/<feature>/v-model
    ```

=== "PowerShell"

    ```powershell
    scripts/powershell/validate-requirement-coverage.ps1 specs/<feature>/v-model
    ```

**Checks performed:**

| Check | Direction | What It Validates |
|---|---|---|
| Forward coverage | REQ → ATP | Every requirement has at least one test case |
| Backward coverage | ATP → REQ | Every test case traces to an existing requirement (no orphans) |
| Scenario coverage | ATP → SCN | Every test case has at least one executable scenario |

**Exit codes:**

| Code | Meaning |
|---|---|
| `0` | Full coverage — all checks pass |
| `1` | Gaps found — missing test cases, orphaned IDs, or uncovered requirements |

!!! example "JSON output for CI"

    ```bash
    scripts/bash/validate-requirement-coverage.sh --json specs/<feature>/v-model
    ```

---

## Matrix A: Requirement Traceability

Matrix A is the first traceability matrix in the V-Model chain. It proves:

- **Forward**: Every `REQ-NNN` → at least one `ATP-NNN-X` → at least one `SCN-NNN-X#` (no gaps)
- **Backward**: Every `SCN` → traces to an `ATP` → traces to a `REQ` (no orphans)

!!! question "The Auditor's Question"

    > "Show me that every requirement has been tested."

    Matrix A answers this by providing a deterministic, script-verified mapping from requirements to test cases to executable scenarios.

---

## Related Pages

- [V-Model Concepts](concepts.md) — Understanding the V-Model and ID schema
- [Level 2: System Design ↔ System Testing](system-design-testing.md) — The next level down
- [Hazard Analysis](hazard-analysis.md) — Cross-cutting safety analysis
- [CI Integration](ci-integration.md) — Running validators in your pipeline
