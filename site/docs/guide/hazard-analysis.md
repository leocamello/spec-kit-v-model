---
title: Hazard Analysis (FMEA)
description: Generate ISO 14971/26262-compliant hazard analysis with operational state awareness, severity matrices, and mitigation traceability across the V-Model.
---

# Hazard Analysis (FMEA)

Hazard analysis is a **cross-cutting concern** — it operates alongside the V-Model hierarchy rather than within a single tier. In regulated industries (medical devices, automotive, aerospace), identifying and mitigating hazards is legally mandated before a product can ship.

---

## Standards Context

### ISO 14971 — Medical Risk Management

Requires systematic identification of hazards, estimation of associated risks, evaluation of risk acceptability, and control of risks.

### ISO 26262 Part 9 — Automotive HARA

Requires Hazard Analysis and Risk Assessment (HARA) at the concept and system levels.

!!! warning "Operational State Awareness"

    Both standards require hazards to be contextualized by **operational state** — the same failure mode may have dramatically different severity depending on the system's current mode of operation (IDLE, ACTIVE, EMERGENCY, etc.).

---

## Command

### `/speckit.v-model.hazard-analysis`

Generates an ISO 14971/ISO 26262-compliant Hazard Analysis (FMEA register) where every system component is assessed for failure modes across all operational states.

```bash
/speckit.v-model.hazard-analysis
```

**What it produces:**

- A `hazard-analysis.md` file in `specs/{feature}/v-model/`
- Every hazard gets a unique `HAZ-NNN` ID
- FMEA register with columns: Component, Failure Mode, Operational State, Effect, Severity, Likelihood, RPN, Mitigation
- Each mitigation references a `REQ-NNN` or `SYS-NNN` for traceability

**Domain-specific severity scales:**

| Domain Config | Severity Classification |
|---|---|
| `iso_26262` | ASIL A through ASIL D + QM |
| `do_178c` | Catastrophic, Hazardous, Major, Minor, No Effect |
| `iec_62304` | Class A, B, C |
| Default (no config) | Catastrophic, Critical, Serious, Minor, Negligible |

!!! note "Prerequisites"

    Requires both `requirements.md` and `system-design.md`. Run [`/speckit.v-model.requirements`](requirements-acceptance.md) and [`/speckit.v-model.system-design`](system-design-testing.md) first.

---

## ID Schema

| Tier | ID Format | Example | Meaning |
|---|---|---|---|
| Hazard | `HAZ-NNN` | `HAZ-001` | A discrete hazard entry in the FMEA register |

The `HAZ-NNN` prefix is unique: it does **not** participate in the intra-level parent/child encoding used by design↔test pairs. Instead, each HAZ entry:

- Links to `SYS-NNN` components via the FMEA **Component** column
- References `REQ-NNN` or `SYS-NNN` IDs in the **Mitigation** column

This creates a cross-cutting trace: **Hazard → Mitigation → Requirement/Component → Test Case**.

### Severity × Likelihood Matrix

Each hazard is assessed using a risk priority number (RPN) derived from:

| Factor | Scale | Description |
|---|---|---|
| **Severity** | 1–5 | How bad is the effect if the hazard occurs? |
| **Likelihood** | 1–5 | How likely is the hazard to occur? |
| **RPN** | Severity × Likelihood | Risk Priority Number — higher = more critical |

---

## Progressive Deepening

Hazard analysis supports **progressive deepening** — you can re-run the command after creating architecture design to add `ARCH`-level hazards:

1. **First run** (after system design): Identifies system-level failure modes for all `SYS-NNN` components
2. **Second run** (after architecture design): Supplements with architecture-level failure modes from `ARCH-NNN` modules — interface failures, concurrency hazards, data flow corruption

!!! example "Progressive deepening"

    ```bash
    # First run: system-level hazards
    /speckit.v-model.hazard-analysis

    # After creating architecture design
    /speckit.v-model.architecture-design

    # Second run: adds ARCH-level hazards
    /speckit.v-model.hazard-analysis
    ```

    Existing `HAZ-NNN` entries are preserved — new architecture-level hazards are appended with the next sequential ID.

---

## Validator

### `validate-hazard-coverage.sh`

Validates hazard coverage across three independent dimensions.

=== "Bash"

    ```bash
    scripts/bash/validate-hazard-coverage.sh specs/<feature>/v-model
    ```

=== "PowerShell"

    ```powershell
    scripts/powershell/validate-hazard-coverage.ps1 specs/<feature>/v-model
    ```

**Three validation dimensions:**

| Dimension | What It Checks |
|---|---|
| **Forward coverage** | Every `SYS-NNN` component has at least one `HAZ-NNN` hazard analyzed (no unanalyzed components) |
| **Backward coverage** | Every `HAZ-NNN` mitigation references a valid `REQ-NNN` or `SYS-NNN` that traces to verification tests |
| **State consistency** | Every operational state mentioned in hazard entries exists in `system-design.md` |

**Options:**

| Flag | Description |
|---|---|
| `--json` | Output in JSON format for CI consumption |
| `--partial` | Skip backward checks if `requirements.md` is absent |

**Exit codes:** `0` = all checks pass, `1` = gaps found.

---

## Matrix H: Hazard Traceability

Matrix H links hazards to their mitigation verification:

- **Forward**: Every `SYS-NNN` component → at least one `HAZ-NNN` hazard analyzed (no unanalyzed components)
- **Backward**: Every `HAZ-NNN` mitigation → references a valid `REQ-NNN` or `SYS-NNN` → traces to verification tests
- **State consistency**: Every operational state mentioned in hazard entries → exists in `system-design.md`

!!! question "The Auditor's Question"

    > "Show me that every system component has been analyzed for hazards, and that every identified hazard has a verified mitigation."

    Matrix H answers this with a deterministic, script-verified chain from components through hazards to mitigations to tests.

---

## Related Pages

- [V-Model Concepts](concepts.md) — Where hazard analysis fits in the V-Model
- [Level 2: System Design ↔ System Testing](system-design-testing.md) — System components that feed hazard analysis
- [Level 3: Architecture ↔ Integration](architecture-integration.md) — Architecture modules for progressive deepening
- [Impact Analysis](impact-analysis.md) — How changes to hazards cascade through the V-Model
- [Audit Report](audit-report.md) — Hazard coverage in the release audit
