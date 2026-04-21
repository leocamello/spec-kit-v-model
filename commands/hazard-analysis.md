---
description: Generate a Hazard Analysis (FMEA) with operational state awareness, traceable HAZ-NNN IDs, and progressive deepening.
handoffs:
  - label: Run Hazard Coverage Validation
    agent: speckit.v-model.trace
    prompt: Build the full traceability matrix including Matrix H (Hazard Traceability)
    send: true
  - label: Back to System Design
    agent: speckit.v-model.system-design
    prompt: Review or update the system design
scripts:
  sh: scripts/bash/setup-v-model.sh --json --require-reqs --require-system-design
  ps: scripts/powershell/setup-v-model.ps1 -Json -RequireReqs -RequireSystemDesign
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Generate a **Hazard Analysis** (Failure Mode and Effects Analysis — FMEA) per **IEC 60812:2018** where **every system component** (`SYS-NNN`) from `system-design.md` is assessed for potential failure modes across operational states defined in the system design. The FMEA procedure follows IEC 60812:2018 §6: item definition → function analysis → failure mode identification → effect analysis → risk evaluation → mitigation. Each hazard receives a unique `HAZ-NNN` identifier and is linked back to risk control measures (`REQ-NNN` / `SYS-NNN`), creating a traceable chain: Hazard → Mitigation → Requirement/Component → Test Case.

Risk evaluation uses a severity × likelihood risk matrix aligned with **ISO 14971:2019 §5** (Risk estimation and evaluation) as the base best practice for systematic risk management. Domain overlays extend this with domain-specific severity scales and risk acceptability criteria.

The output follows the FMEA register format with operational state awareness: the same failure mode (e.g., sensor corruption) may appear as multiple `HAZ-NNN` entries with different severity classifications depending on whether the system is in IDLE, ACTIVE, or EMERGENCY state.

## Execution Steps

### 1. Setup

Run `{SCRIPT}` from the repository root and parse the JSON output.

The script returns JSON with these keys:
- `VMODEL_DIR`: Path to `specs/{feature}/v-model/` directory
- `FEATURE_DIR`: Path to `specs/{feature}/` directory
- `BRANCH`: Current branch name
- `REQUIREMENTS`: Path to `requirements.md` (MUST exist — script uses `--require-reqs`)
- `SYSTEM_DESIGN`: Path to `system-design.md` (MUST exist — script uses `--require-system-design`)
- `AVAILABLE_DOCS`: Array of documents that currently exist

If `system-design.md` does not exist, the setup script will fail. In that case, inform the user:
> "hazard-analysis requires both requirements.md and system-design.md. Run `/speckit.v-model.system-design` first."

For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

### 2. Load Context

1. **Load the template**: Read `templates/hazard-analysis-template.md` from the extension directory to understand the required output structure.

2. **Load system design**: Read `system-design.md` from the `SYSTEM_DESIGN` path.
   - Extract ALL `SYS-NNN` identifiers, names, and descriptions from the Decomposition View
   - Note the total SYS count — every `SYS-NNN` must have at least one `HAZ-NNN` entry in the output

3. **Extract operational states**: Scan `system-design.md` for operational states, modes, or phases.
   - Look for sections titled "Operational States", "Operating Modes", "System States", or similar
   - Look for state machines, mode diagrams, or enumerated state lists
   - If explicit states are found: use them (e.g., IDLE, STARTUP, ACTIVE, EMERGENCY, SHUTDOWN)
   - If NO explicit states are found: use a single implicit state `NORMAL` and emit a warning:
     > "⚠️ No operational states defined in system-design.md — using implicit NORMAL state. Consider adding operational states to your system design for more thorough hazard analysis."

4. **Load requirements**: Read `requirements.md` from the `REQUIREMENTS` path.
   - Extract `REQ-NNN` identifiers and descriptions for mitigation linking
   - Requirements serve as the source of risk control measures

5. **Load architecture design** (if `AVAILABLE_DOCS` contains `"architecture-design.md"`):
   - Read `architecture-design.md` for progressive deepening (Step 5)
   - Extract `ARCH-NNN` identifiers and interface contracts
   - Architecture-level failure modes supplement system-level analysis

6. **Load existing hazard analysis** (if `AVAILABLE_DOCS` contains `"hazard-analysis.md"`):
   - Read the existing `hazard-analysis.md` to preserve existing HAZ IDs and content
   - Identify the highest existing HAZ number to continue the sequence
   - New hazard entries append after existing ones — **never renumber**
   - This enables progressive deepening across multiple invocations

### 2a. Domain Configuration

Load `v-model-config.yml` (if it exists at the repository root).

**If `domain` is set** (e.g., `iso_26262`, `do_178c`, `iec_62304`):
1. Read the command overlay: `commands/overlays/{domain}/hazard-analysis.md`
   - If it exists: note the domain-specific severity scale, risk classification methodology, and regulatory context for hazard assessment
   - If it does not exist: this domain does not extend this command — proceed with base only
2. Where the base command has a domain-variant section (marked with "If a domain overlay is loaded, prefer its content"), use the overlay's version instead of the base default

**If `domain` is empty or absent:**
- Proceed with the base command only
- Use the general-purpose severity scale (Section 4.5)
- Do NOT include any safety-critical or domain-specific severity classifications

### 3. Lifecycle Rules (When Evolving Existing Artifacts)

When an existing `hazard-analysis.md` is loaded (step 2.7), apply these rules
before generating new content:

1. **Never delete an ID** — mark as `[DEPRECATED]`
2. **Deprecation types:**
   - `[DEPRECATED — Superseded by HAZ-NNN]`: Replaced by a new hazard entry
   - `[DEPRECATED — Withdrawn: <reason>]`: Removed entirely with justification
3. **Suspect detection from parent SYS:** If a parent SYS (in `system-design.md`)
   is deprecated or modified, mark each HAZ that traces to it as
   `[SUSPECT — Parent SYS-NNN {deprecated|modified}]`.
4. **Suspect detection from mitigation REQ:** If a REQ referenced as a mitigation
   in a HAZ entry is deprecated, mark that HAZ as
   `[SUSPECT — Mitigation REQ-NNN deprecated]`.
5. **Suspect resolution:** For each suspect HAZ:
   - **Re-parent** to the superseding SYS/REQ (if the component/mitigation continues)
   - **Deprecate** (if the component is withdrawn and the hazard no longer applies)
   - **Confirm active** (if still valid despite the parent change — remove the SUSPECT tag)
6. **Modified hazards:** Update content in-place, preserve the original HAZ ID.

If no existing `hazard-analysis.md` is found, skip this step entirely — all
hazards are new.

### 4. Generate Hazard Register (FMEA)

For each `SYS-NNN` component in the system design, brainstorm potential failure modes and analyze each across operational states. This step implements the IEC 60812:2018 §6 FMEA procedure.

#### 4.0 IEC 60812:2018 FMEA Procedure Compliance

Per IEC 60812:2018 §6, the FMEA must be performed in this order for each `SYS-NNN`:

1. **Item Definition** (§6.1): Identify the component, its function, and its operational boundaries
2. **Failure Mode Identification** (§6.2): Enumerate all ways the component can fail to perform its function — see §4.1 below
3. **Effect Analysis** (§6.3): Determine the consequence of each failure mode at system level — see §4.2
4. **Failure Mode Detection** (§6.4): Identify how the failure is detected (automatic, operator, none)
5. **Risk Estimation** (§6.5 + ISO 14971:2019 §5): Assess severity and likelihood using the risk matrix — see §4.5 and §4.6
6. **Risk Mitigation** (§6.6): Identify control measures that reduce risk to an acceptable level — each mitigation MUST reference at least one `REQ-NNN` or `SYS-NNN`

Do NOT proceed to generate `HAZ-NNN` entries without completing steps 1–6 in order.

#### 4.1 Failure Mode Identification

For each component, consider:
- **Function failures**: What if this component does not perform its function?
- **Timing failures**: What if this component operates too early, too late, or intermittently?
- **Value failures**: What if this component produces incorrect output (too high, too low, wrong type)?
- **Interface failures**: What if this component's inputs are corrupted, missing, or out of range?

#### 4.2 Operational State Analysis

For each identified failure mode, evaluate severity across EVERY relevant operational state:
- A failure mode may have DIFFERENT severity in DIFFERENT states
- When severity differs, create SEPARATE `HAZ-NNN` entries for each state-severity combination
- When severity is the SAME across all states, create a SINGLE entry with "ALL" as the operational state

Example: A temperature sensor failure on a medical infusion pump:
- `HAZ-001`: Sensor failure during IDLE → Severity: Negligible (pump is off)
- `HAZ-002`: Sensor failure during PRIMING → Severity: Minor (pump can be stopped manually)
- `HAZ-003`: Sensor failure during INFUSING → Severity: Catastrophic (incorrect dosage delivery)

#### 4.3 FMEA Entry Generation

For each hazard entry, populate ALL 8 mandatory fields:

1. **HAZ ID**: `HAZ-NNN` — sequential 3-digit zero-padded (HAZ-001, HAZ-002, ...)
2. **Component**: The `SYS-NNN` identifier of the affected system component
3. **Failure Mode**: Specific description of how the component fails
4. **Operational State**: The system state during which this failure occurs (or "ALL")
5. **Effect**: Consequence of the failure at system level (patient harm, data loss, etc.)
6. **Severity**: Classification per the domain scale (see Step 2.6) or general-purpose scale
7. **Likelihood**: Probability assessment (Frequent, Probable, Occasional, Remote, Improbable)
8. **Risk Level**: Severity × Likelihood from the risk matrix (see template)
9. **Mitigation**: Risk control measure — MUST reference at least one `REQ-NNN` or `SYS-NNN`
10. **Residual Risk**: Risk level after mitigation is applied

#### 4.4 Full SYS Coverage Rule

Every `SYS-NNN` in the system design MUST have at least one `HAZ-NNN` entry. If no realistic failure mode can be identified for a component:
- Generate a single entry with:
  - Failure Mode: "No identified failure mode"
  - Severity: Negligible
  - Risk Level: Acceptable
  - Add a note: `[HUMAN REVIEW REQUIRED: Confirm no failure modes exist for this component]`

#### 4.5 Severity Classification

**If a domain overlay is loaded** (Step 2a), use the severity scale defined in the overlay instead of the general-purpose scale below.

**General-Purpose (default — no domain configured):**

| Severity | Definition |
|----------|-----------|
| Catastrophic | Death or permanent injury; complete system destruction |
| Critical | Severe injury or major system damage; immediate intervention required |
| Serious | Moderate injury or significant degradation; medical attention needed |
| Minor | Slight injury or minor degradation; first aid sufficient |
| Negligible | No injury; cosmetic or inconvenience-level impact |

#### 4.6 Risk Matrix (ISO 14971:2019 §5)

Use the severity × likelihood risk matrix per ISO 14971:2019 §5 (Risk estimation). For domain-configured projects, the domain overlay replaces this general-purpose matrix with the domain-appropriate risk acceptability criteria:

| | Frequent | Probable | Occasional | Remote | Improbable |
|---|---|---|---|---|---|
| **Catastrophic** | Unacceptable | Unacceptable | Unacceptable | Undesirable | Undesirable |
| **Critical** | Unacceptable | Unacceptable | Undesirable | Undesirable | Tolerable |
| **Serious** | Unacceptable | Undesirable | Undesirable | Tolerable | Tolerable |
| **Minor** | Undesirable | Tolerable | Tolerable | Acceptable | Acceptable |
| **Negligible** | Tolerable | Acceptable | Acceptable | Acceptable | Acceptable |

### 5. Progressive Deepening (Architecture-Level)

**Only execute this step if `architecture-design.md` exists.**

After generating system-level hazards, analyze architecture-level failure modes:

1. Read `ARCH-NNN` modules and their interface contracts
2. Identify failure modes NOT visible at SYS level:
   - **Interface mismatches**: API contract violations between ARCH modules
   - **Protocol failures**: Handshake failures, timeout misconfigurations
   - **Data format incompatibilities**: Encoding mismatches, schema drift
   - **Race conditions**: Concurrent access to shared resources (if applicable)
3. For each new architecture-level failure:
   - Create a new `HAZ-NNN` entry continuing the sequence
   - Reference the `ARCH-NNN` module in the Component field (alongside the parent `SYS-NNN`)
   - Apply the same operational state analysis as system-level hazards
4. If NO new architecture-level hazards are identified:
   - Append nothing
   - Add a note at the end of the hazard register: "No additional architecture-level hazards identified."
5. **CRITICAL**: Never modify existing `HAZ-NNN` entries — append only

### 6. Write Output

Write the complete hazard analysis to `{VMODEL_DIR}/hazard-analysis.md` using the template structure. Include:

1. **Header section**: Feature name, branch, date, source references
2. **Overview**: Brief description of the hazard analysis scope and methodology
3. **Risk Matrix Definition**: The severity × likelihood matrix (from Step 3.6)
4. **Operational States Reference**: Table of states extracted from system-design.md
5. **Hazard Register (FMEA Table)**: All HAZ entries with 10 columns
6. **Progressive Deepening Notes**: Architecture-level additions (if applicable)
7. **Coverage Summary**: SYS coverage stats, hazard count by severity, state distribution

### 7. Report Completion

Display a summary:
- Total hazards generated (HAZ count)
- SYS coverage: X/Y components analyzed (must be 100%)
- Operational states used (list)
- Severity distribution (count per severity level)
- Risk level distribution (count per risk level)
- Domain-specific scales applied (if any)
- Progressive deepening: architecture-level hazards added (count, or "N/A")
- Path to the generated file
- Next step: Recommend running `validate-hazard-coverage.sh` to validate coverage, then `/speckit.v-model.trace` to build Matrix H

## Governing Standards

This command is governed by the following standards for hazard analysis:

| Standard | Full Name | Role in this Command |
|----------|-----------|----------------------|
| **IEC 60812:2018** | Analysis Techniques for System Reliability — Failure Modes and Effects Analysis (FMEA) | Primary FMEA standard: defines the FMEA procedure (§6), failure mode identification criteria, effect analysis methodology, detection assessment, and documentation requirements (§7). Governs the step-by-step procedure in Step 4.0 and the FMEA register format. |
| **ISO 14971:2019** | Medical Devices — Application of Risk Management to Medical Devices | Risk estimation and evaluation: defines the severity × likelihood risk matrix framework (§5), risk acceptability criteria, and residual risk documentation. Used as base best-practice for the general-purpose risk matrix in §4.6. Domain overlays extend with domain-specific acceptability criteria. |

> **Domain extensions:** If a domain overlay is loaded (Step 2a), the severity scale, risk acceptability criteria, and regulatory risk classification framework are replaced by the domain-specific standard (e.g., ISO 26262-3 §7 HARA with ASIL assignment, DO-178C §2.3 FHA with DAL determination, IEC 62304 §4.3 Software Safety Classification). The IEC 60812:2018 FMEA procedure and ISO 14971 risk estimation principles remain applicable as the structural foundation.

## Operating Constraints

### Strict Translation Rules

When deriving hazards from `requirements.md` and `system-design.md`:
- **DO NOT** invent system capabilities, components, or operational states not present in the source artifacts
- **DO NOT** add components beyond what `system-design.md` defines
- **DO NOT** reference operational states not defined in `system-design.md` (or the implicit NORMAL)
- **DO** assess every `SYS-NNN` for failure modes
- **DO** link every mitigation to an existing `REQ-NNN` or `SYS-NNN`
- **DO** generate separate HAZ entries when severity varies by operational state
- **DO** flag components with no identifiable failure mode for human review

### ID Rules

- IDs are **permanent** — once assigned, never renumbered or reassigned
- Sequential numbering: HAZ-001, HAZ-002, HAZ-003...
- 3-digit zero-padded, matching regex `HAZ-[0-9]{3}`
- When updating existing registers, preserve all existing IDs and append new ones
- Gaps in numbering are acceptable after progressive deepening

### Output Rules

- The FMEA table MUST have exactly 10 columns per the template
- Every mitigation MUST reference at least one `REQ-NNN` or `SYS-NNN`
- The risk matrix MUST be included in the output (not just referenced)
- Operational states reference MUST list all states used in the FMEA table
- Handle 50+ hazards without batching — hazard entries are short and uniform
