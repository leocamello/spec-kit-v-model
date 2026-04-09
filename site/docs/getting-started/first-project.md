---
title: Your First V-Model Project
description: A hands-on tutorial that walks you through creating requirements, acceptance tests, and a traceability matrix using the V-Model Extension Pack for Spec Kit.
---

# Your First V-Model Project

In this tutorial you'll use **Level 1** of the V-Model — **Requirements ↔ Acceptance Testing** — to generate audit-ready specifications with full traceability. By the end, you'll have:

- A set of traceable requirements (`REQ-NNN`)
- A paired acceptance test plan (`ATP-NNN-X` test cases + `SCN-NNN-X#` BDD scenarios)
- A bidirectional traceability matrix (Matrix A)

**Time:** ~15 minutes

## Step 1: Create a New Project

Start by creating a fresh Spec Kit project:

=== "Bash"

    ```bash
    mkdir my-project && cd my-project
    specify init --here
    ```

=== "PowerShell"

    ```powershell
    mkdir my-project; cd my-project
    specify init --here
    ```

This creates the `.specify/` directory structure that Spec Kit and its extensions use.

## Step 2: Install the V-Model Extension

If you haven't installed the extension yet, do so now:

```bash
specify extension add v-model \
  --from https://github.com/leocamello/spec-kit-v-model/archive/refs/tags/v0.5.0.zip
```

!!! tip "Already installed?"

    If you followed the [Installation Guide](installation.md), you can skip this step. Run `specify extension list` to confirm.

## Step 3: Write Your Spec

Every V-Model project starts with a plain-language specification. Create a `spec.md` describing what you want to build:

```markdown title="spec.md"
# Temperature Monitoring System

Build a temperature monitoring system that alerts when temperature
exceeds a configurable threshold.

The system should:
- Read temperature from one or more sensors
- Allow users to configure alert thresholds per sensor
- Trigger visual and audible alerts when a threshold is exceeded
- Log all temperature readings with timestamps
- Provide a dashboard showing current readings and alert history
```

This is your **input** — the V-Model Extension Pack will transform it into structured, traceable engineering artifacts.

## Step 4: Generate Requirements

Run the requirements command to produce traceable `REQ-NNN` items:

```
/speckit.v-model.requirements
```

### What You'll Get

The command produces a `requirements.md` file containing a table of structured requirements:

| ID | Category | Requirement | Rationale | Verification Method |
|---|---|---|---|---|
| REQ-001 | Functional | The system shall read temperature values from connected sensors at a configurable polling interval. | Continuous monitoring requires periodic data acquisition. | Test |
| REQ-002 | Functional | The system shall allow users to configure alert thresholds per sensor. | Different sensors may monitor environments with different acceptable ranges. | Test |
| REQ-003 | Functional | The system shall trigger visual and audible alerts when a sensor reading exceeds its configured threshold. | Timely alerts are critical for preventing damage or safety incidents. | Test |
| ... | ... | ... | ... | ... |

!!! info "What makes these requirements special?"

    Each requirement has:

    - A **unique traceable ID** (`REQ-NNN`) that persists across all downstream artifacts
    - A **category** (Functional, Non-Functional, Interface, Constraint)
    - A **rationale** explaining *why* the requirement exists
    - A **verification method** (Test, Inspection, Analysis, or Demonstration)

## Step 5: Generate Acceptance Tests

Now generate the paired acceptance test plan:

```
/speckit.v-model.acceptance
```

### What You'll Get

The command produces an `acceptance.md` file with **two tiers** of test artifacts:

**Test Cases** (`ATP-NNN-X`) — logical test conditions for each requirement:

| Test Case ID | Requirement | Description |
|---|---|---|
| ATP-001-A | REQ-001 | Verify the system reads temperature from a connected sensor at the default polling interval. |
| ATP-001-B | REQ-001 | Verify the polling interval is configurable and changes take effect immediately. |
| ATP-002-A | REQ-002 | Verify a user can set a threshold for a specific sensor. |
| ... | ... | ... |

**BDD Scenarios** (`SCN-NNN-X#`) — executable Given/When/Then scenarios for each test case:

```gherkin
# SCN-001-A1: Normal temperature reading at default interval
Given a temperature sensor is connected
  And the polling interval is set to the default value
When the polling interval elapses
Then the system reads the current temperature from the sensor
  And the reading is stored with a timestamp
```

The file ends with a **Coverage Validation Gate**:

!!! success "100% Requirement Coverage"

    Every `REQ-NNN` has at least one `ATP-NNN-X` test case, and every test case has at least one `SCN-NNN-X#` scenario. No gaps.

## Step 6: Build the Traceability Matrix

Finally, generate the bidirectional traceability matrix:

```
/speckit.v-model.trace
```

### What You'll Get

The command produces **Matrix A** — a complete mapping between requirements and acceptance tests:

| Requirement | Test Cases | Scenarios | Status |
|---|---|---|---|
| REQ-001 | ATP-001-A, ATP-001-B | SCN-001-A1, SCN-001-B1 | ⬜ Untested |
| REQ-002 | ATP-002-A | SCN-002-A1, SCN-002-A2 | ⬜ Untested |
| REQ-003 | ATP-003-A, ATP-003-B | SCN-003-A1, SCN-003-B1 | ⬜ Untested |
| ... | ... | ... | ... |

!!! info "Bidirectional traceability"

    Matrix A enforces two guarantees:

    - **Forward (no gaps):** Every requirement → has test cases → has scenarios
    - **Backward (no orphans):** Every scenario → traces to a test case → traces to a requirement

    Reading any ID tells you the full lineage. `SCN-001-A1` means: scenario 1 for test case A of requirement 001. No lookup table needed.

## 🎉 Congratulations!

!!! success "You did it!"

    You've just created **audit-ready requirements** with **full test coverage** and **bidirectional traceability** — in under 15 minutes.

    What you generated would typically take days of manual work and cross-referencing. Every ID is self-documenting, every requirement is covered, and the traceability matrix proves it.

## What's Next?

You've completed **Level 1** of the V-Model (Requirements ↔ Acceptance Testing). The V-Model has three more levels that decompose your design further:

| Level | Left Side (Design) | Right Side (Testing) | Command Pair |
|---|---|---|---|
| **1** ✅ | Requirements | Acceptance Testing | `requirements` + `acceptance` |
| **2** | System Design | System Testing | `system-design` + `system-test` |
| **3** | Architecture Design | Integration Testing | `architecture-design` + `integration-test` |
| **4** | Module Design | Unit Testing | `module-design` + `unit-test` |

Explore the deeper levels:

- **[Guides](../guide/concepts.md)** — Detailed walkthroughs for each V-Model level
- **[Reference](../reference/commands.md)** — Complete command reference and configuration options

!!! tip "Safety-critical project?"

    If you're working under ISO 26262, DO-178C, or IEC 62304, configure your [regulatory domain](installation.md#domain-configuration) to unlock additional safety-critical sections at every level. Also explore the [`/speckit.v-model.hazard-analysis`](../reference/commands.md) command for FMEA/risk analysis.
