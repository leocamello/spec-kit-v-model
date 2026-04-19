# Feature Specification: Hazard Analysis (FMEA)

**Feature Branch**: `005a-hazard-analysis`
**Created**: 2026-03-31
**Status**: Approved
**Input**: Add a Hazard Analysis command to the V-Model Extension Pack that generates an FMEA (Failure Mode and Effects Analysis) register with traceable `HAZ-NNN` IDs from existing requirements and system design artifacts. In safety-critical domains (medical devices, automotive, aerospace), you cannot just write requirements — you must prove you have analyzed what happens when the system fails. This command bridges the gap between requirements specification and risk management by generating a structured hazard register that links every identified hazard back to mitigating requirements (`REQ-NNN`) or system components (`SYS-NNN`). The command is AI-generated and script-validated, following the same paired-generation pattern as existing V-Model commands. A new traceability matrix (Matrix H — Hazard Traceability) extends the `trace` command to prove the chain: Hazard → Mitigation → Requirement → Test Case.

## Governing Standards

This feature is guided by the following international standards:

- **ISO 14971:2019 (Medical devices — Application of risk management)** — The primary standard for medical device risk management. Requires systematic identification of hazards, estimation of risk (severity × probability), risk evaluation against acceptability criteria, and implementation of risk control measures. Mandates that hazards be analyzed across all reasonably foreseeable operating conditions and use scenarios.
- **ISO 26262 Part 3 (Road vehicles — Concept phase) & Part 9 (ASIL-oriented and safety-oriented analyses)** — Defines the Hazard Analysis and Risk Assessment (HARA) methodology for automotive systems. Requires hazards to be classified by Severity (S0–S3), Exposure (E1–E4), and Controllability (C0–C3) to derive an ASIL rating (QM, A, B, C, D). Part 9 mandates FMEA as a recommended safety analysis method.
- **DO-178C / ARP 4761 (Aerospace — Safety Assessment Process)** — ARP 4761 defines the Functional Hazard Assessment (FHA) and FMEA for aerospace systems. Hazards are classified from No Safety Effect through Catastrophic. DO-178C Level A requires that all catastrophic failure conditions have at least two independent mitigations.
- **IEC 62304:2006+A1:2015 (Medical device software — Software life cycle processes)** — Requires software safety classification (Class A, B, C) based on the hazards identified in the risk management process (per ISO 14971). The classification determines the rigor of the software development lifecycle, making hazard analysis a prerequisite for all downstream engineering.
- **IEC 61508 (Functional safety of electrical/electronic/programmable electronic safety-related systems)** — The parent standard for functional safety from which ISO 26262 and IEC 62304 derive. Defines SIL (Safety Integrity Level) classification based on risk analysis.

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Generate FMEA from Requirements and System Design (Priority: P1)

A systems engineer working on an insulin pump has `requirements.md` (with `REQ-NNN` IDs) and `system-design.md` (with `SYS-NNN` components). She runs `/speckit.v-model.hazard-analysis` to produce a structured hazard register. For every system component, the AI brainstorms how it could fail (Failure Mode), what the consequence is (Effect), the severity of that consequence, the likelihood of occurrence, and generates a mitigation strategy. Each hazard gets a unique `HAZ-NNN` ID.

The critical innovation is **operational state awareness**: the AI does not brainstorm failures in a vacuum. It reads the system design's operating modes (e.g., IDLE, INFUSING, ALARMING, MAINTENANCE) and analyzes each failure mode across every relevant operational state. A sensor reading corruption during IDLE mode may have Negligible severity (the pump is not delivering), but the identical failure during INFUSING mode is Catastrophic (incorrect dosage delivery). The same component failure appears as multiple hazard entries with different severity classifications depending on the system state — exactly as ISO 14971 and ISO 26262 require.

Each hazard entry links its mitigation back to a specific requirement (`REQ-NNN`) or system component (`SYS-NNN`), creating a traceable chain from risk to control measure to verification.

**Why this priority**: Hazard analysis is a mandatory prerequisite in every regulated industry. ISO 14971 requires it before design can proceed. IEC 62304 software classification depends on it. Without this command, the V-Model Extension Pack covers structure but not safety — leaving the most expensive part of compliance (risk management) entirely manual.

**Independent Test**: Can be fully tested by running the command on any existing `requirements.md` + `system-design.md` and verifying: (1) every `SYS-NNN` has at least one associated hazard, (2) every hazard has a Failure Mode, Operational State, Effect, Severity, Likelihood, Risk Level, Mitigation, and Residual Risk, (3) every mitigation references at least one `REQ-NNN` or `SYS-NNN`, (4) hazards appear across multiple operational states with different severities, (5) `validate-hazard-coverage.sh` confirms bidirectional coverage.

**Acceptance Scenarios**:

1. **Given** a `requirements.md` with 15 requirements and a `system-design.md` with 8 system components defining 3 operational states (IDLE, ACTIVE, ERROR), **When** the user runs `/speckit.v-model.hazard-analysis`, **Then** the system produces `hazard-analysis.md` with `HAZ-NNN` entries where each system component has at least one hazard analyzed across the relevant operational states, with severity varying by state.
2. **Given** a system component `SYS-003` (Sensor Interface) operating in states IDLE and INFUSING, **When** the hazard analysis identifies "sensor data corruption" as a failure mode, **Then** two separate hazard entries are created: one for IDLE (Severity: Negligible) and one for INFUSING (Severity: Catastrophic), because the same failure has radically different consequences depending on system state.
3. **Given** a hazard `HAZ-007` with mitigation "Input validation with range checking", **When** the hazard register is generated, **Then** `HAZ-007`'s Mitigation field references specific IDs (e.g., "Mitigated by REQ-012, SYS-003") creating a traceable link from risk to control measure.
4. **Given** the hazard analysis has been generated, **When** the user runs `validate-hazard-coverage.sh`, **Then** the script confirms: (a) every `SYS-NNN` from `system-design.md` has at least one `HAZ-NNN` entry, (b) every `HAZ-NNN` mitigation references at least one `REQ-NNN` or `SYS-NNN`, and (c) the operational states referenced in hazards match those defined in `system-design.md`.
5. **Given** an `architecture-design.md` also exists in the project, **When** the user re-runs `/speckit.v-model.hazard-analysis`, **Then** the command **appends** new architecture-level failure modes (e.g., interface failures between `ARCH-NNN` modules) without modifying or removing any existing `HAZ-NNN` entries — implementing progressive deepening.

---

### User Story 2 — Validate Hazard-to-Requirement Coverage (Priority: P1)

After generating the hazard register, the engineer runs `validate-hazard-coverage.sh` (or `.ps1`) to verify bidirectional coverage. The script performs three checks:

1. **Forward coverage (SYS → HAZ)**: Every system component (`SYS-NNN`) in `system-design.md` has at least one associated hazard in `hazard-analysis.md`.
2. **Backward coverage (HAZ → REQ/SYS)**: Every hazard mitigation references at least one existing `REQ-NNN` or `SYS-NNN`.
3. **Operational state validation**: The operational states referenced in hazard entries match those defined in `system-design.md` (no invented states, no missing states).

The script follows the same conventions as existing coverage validators: `--json` for machine-readable output, `--partial` for partial validation when not all artifacts exist yet, deterministic execution with no AI calls.

**Why this priority**: Coverage validation is the enforcement mechanism. Without it, the hazard analysis is just documentation — with it, gaps are caught deterministically before they reach an auditor.

**Independent Test**: (1) Create a hazard register with one `SYS-NNN` missing → script exits non-zero and reports the gap. (2) Create a hazard with a mitigation referencing a non-existent `REQ-999` → script exits non-zero. (3) Create a hazard referencing operational state "FLYING" when `system-design.md` only defines IDLE/ACTIVE → script reports the mismatch.

**Acceptance Scenarios**:

1. **Given** a `system-design.md` with 8 components and a `hazard-analysis.md` covering only 7 of them, **When** `validate-hazard-coverage.sh` runs, **Then** it exits with code 1 and reports the uncovered `SYS-NNN` as a gap.
2. **Given** a complete hazard register with all mitigations referencing valid `REQ-NNN` / `SYS-NNN` IDs, **When** `validate-hazard-coverage.sh --json` runs, **Then** it exits with code 0 and outputs `{"has_gaps": false, "forward_coverage": "100%", "backward_coverage": "100%"}`.
3. **Given** a hazard entry referencing operational state "CRUISE" but `system-design.md` defines only IDLE, ACTIVE, and ERROR, **When** the script runs, **Then** it reports "Unknown operational state: CRUISE" as a validation warning.

---

### User Story 3 — Extend Traceability Matrix with Matrix H (Priority: P1)

The existing `trace` command builds Matrices A–D (REQ→ATP, SYS→STP, ARCH→ITP, MOD→UTP). This story extends it with **Matrix H (Hazard Traceability)**: a matrix proving the chain from each Hazard to its Mitigation (REQ/SYS), and from there to the test case that verifies the mitigation is implemented.

The build-matrix script is updated to:
1. Parse `hazard-analysis.md` for `HAZ-NNN` IDs and their mitigation links
2. Cross-reference mitigations against the existing REQ→ATP and SYS→STP chains
3. Produce Matrix H showing: `HAZ-NNN` → Mitigation (`REQ-NNN` / `SYS-NNN`) → Verification (`ATP-NNN` / `STP-NNN`)

**Why this priority**: A hazard register without traceability to verification is incomplete for regulatory purposes. ISO 14971 §7.4 requires verification that each risk control measure has been implemented and tested.

**Independent Test**: (1) Run `trace` on a project with `hazard-analysis.md` → output includes Matrix H section, (2) every `HAZ-NNN` row shows mitigation and verification columns, (3) gaps where a mitigation has no test coverage are highlighted.

**Acceptance Scenarios**:

1. **Given** a project with all V-Model artifacts including `hazard-analysis.md`, **When** the user runs `/speckit.v-model.trace`, **Then** the traceability matrix includes a new "Matrix H — Hazard Traceability" section alongside the existing Matrices A–D.
2. **Given** `HAZ-003` is mitigated by `REQ-012` and `REQ-012` has `ATP-012-A` as its acceptance test, **When** Matrix H is built, **Then** the row shows: `HAZ-003 → REQ-012 → ATP-012-A`.
3. **Given** `HAZ-007` is mitigated by `SYS-005` but no test case covers `SYS-005`, **When** Matrix H is built, **Then** the verification column shows `⚠️ No test coverage` highlighting the gap.

---

### User Story 4 — Progressive Deepening After Architecture Design (Priority: P2)

After the initial hazard analysis (based on requirements + system design), the engineer completes `architecture-design.md`. She re-runs `/speckit.v-model.hazard-analysis` to trigger progressive deepening. The command:

1. Reads the existing `hazard-analysis.md` to preserve all current `HAZ-NNN` entries
2. Reads `architecture-design.md` for new architecture modules (`ARCH-NNN`)
3. Identifies new failure modes at the architecture level (e.g., interface mismatches between modules, protocol failures, data format incompatibilities)
4. **Appends** new `HAZ-NNN` entries (numbering continues from the last existing ID) without modifying or removing any existing entries

This ensures the hazard register grows richer as design detail increases, without losing earlier analysis.

**Why this priority**: P2 because the initial hazard analysis (P1) must work first. Progressive deepening is an enhancement that adds architectural-level risk analysis — valuable but not blocking for the first release.

**Independent Test**: (1) Generate hazard analysis with 20 entries (HAZ-001 to HAZ-020), (2) add `architecture-design.md`, (3) re-run → new entries start at HAZ-021+, (4) verify HAZ-001 through HAZ-020 are unchanged, (5) new entries reference `ARCH-NNN` modules.

**Acceptance Scenarios**:

1. **Given** an existing `hazard-analysis.md` with HAZ-001 through HAZ-020, **When** the user adds `architecture-design.md` and re-runs the command, **Then** new hazard entries are appended starting from HAZ-021, and all original entries (HAZ-001–HAZ-020) remain unmodified.
2. **Given** `architecture-design.md` defines interface contracts between `ARCH-001` (API Gateway) and `ARCH-002` (Data Store), **When** progressive deepening runs, **Then** new hazard entries include interface-level failure modes (e.g., "Protocol version mismatch between ARCH-001 and ARCH-002").
3. **Given** progressive deepening has appended architecture-level hazards, **When** `validate-hazard-coverage.sh` runs, **Then** it validates both the original SYS-level and new ARCH-level coverage without errors.

---

### User Story 5 — PowerShell Parity (Priority: P3)

All scripts delivered in this feature (`validate-hazard-coverage.sh`, build-matrix extensions) must have PowerShell (`.ps1`) equivalents that produce identical JSON output and identical exit codes. The PowerShell scripts follow the same conventions as existing validators: parameter naming (`-Json`, `-Partial`), output format, and error handling.

**Why this priority**: P3 because the feature's core value (hazard generation and validation) is delivered by the Bash scripts. PowerShell parity ensures Windows/cross-platform support but is not required for initial dogfooding or CI validation.

**Independent Test**: Run both `validate-hazard-coverage.sh --json` and `Validate-HazardCoverage.ps1 -Json` on the same fixture and verify identical JSON output (modulo whitespace).

**Acceptance Scenarios**:

1. **Given** a complete hazard register, **When** `Validate-HazardCoverage.ps1 -Json` runs, **Then** it produces the same JSON structure and field values as `validate-hazard-coverage.sh --json`.
2. **Given** a hazard register with a gap (uncovered `SYS-NNN`), **When** both scripts run, **Then** both exit with code 1 and both report the same gap.

---

## Edge Cases

1. **What happens when `system-design.md` defines no operational states?** — The hazard analysis uses a single implicit state "NORMAL" and notes that operational states were not explicitly defined. A validation warning is emitted but the command does not fail.
2. **What happens when a system component has no plausible failure modes?** — Every `SYS-NNN` must have at least one hazard. If the AI cannot identify a realistic failure mode, it generates a "No identified failure mode" entry with Severity: Negligible and flags it for human review.
3. **What happens when `requirements.md` exists but `system-design.md` does not?** — The command fails with an error: "hazard-analysis requires both requirements.md and system-design.md. Run /speckit.v-model.system-design first."
4. **What happens when the safety-critical domain is not configured?** — The command generates a general-purpose FMEA without domain-specific severity scales (no ASIL, no SIL, no DO-178C levels). Operational state analysis still applies.
5. **What happens when progressive deepening is run but `architecture-design.md` has no new failure modes beyond what SYS-level already covers?** — The command detects no new architecture-level hazards and appends nothing. A note is added: "No additional architecture-level hazards identified."
6. **What happens when a `HAZ-NNN` mitigation references a `REQ-NNN` that does not exist in `requirements.md`?** — `validate-hazard-coverage.sh` reports a backward coverage gap: "HAZ-007 references REQ-999 which does not exist."
7. **What happens when the hazard register is very large (50+ hazards)?** — The template and validation scripts handle any count. No batching is required for hazard generation (unlike acceptance scenarios) because hazard entries are shorter and more uniform.
8. **What happens when the user runs the command for the first time without any existing `hazard-analysis.md`?** — The command creates a new file starting from HAZ-001. This is the default behavior (progressive deepening only activates when an existing file is detected).

## Requirements

### Hazard Analysis Command

- **FR-001**: The command SHALL read `requirements.md` and `system-design.md` as mandatory inputs
- **FR-002**: The command SHALL generate `hazard-analysis.md` with unique `HAZ-NNN` IDs (zero-padded, three digits)
- **FR-003**: Each hazard entry SHALL include: Failure Mode, Operational State, Effect, Severity, Likelihood, Risk Level (severity × likelihood), Mitigation, and Residual Risk
- **FR-004**: The command SHALL read operational states/modes from `system-design.md` and analyze failure modes across each relevant state
- **FR-005**: The same failure mode on the same component SHALL appear as separate `HAZ-NNN` entries when severity differs by operational state
- **FR-006**: Every mitigation SHALL reference at least one `REQ-NNN` or `SYS-NNN` ID
- **FR-007**: When `architecture-design.md` exists, the command SHALL also analyze architecture-level failure modes (interface mismatches, protocol failures, data format issues)
- **FR-008**: When a previous `hazard-analysis.md` exists, the command SHALL append new entries (numbering continues from last existing HAZ-NNN) without modifying existing entries
- **FR-009**: When no safety-critical domain is configured, the command SHALL produce a general-purpose FMEA without domain-specific severity scales
- **FR-010**: The command SHALL follow the strict translator constraint — translating requirements/design into hazards without inventing new system capabilities

### Hazard Analysis Template

- **FR-011**: A `hazard-analysis-template.md` SHALL define the output structure including the FMEA table format with Operational State column
- **FR-012**: The template SHALL include sections for: Summary, Risk Matrix Definition, Hazard Register (FMEA table), and Operational States Reference
- **FR-013**: The FMEA table SHALL have columns: HAZ ID, Component (SYS-NNN), Failure Mode, Operational State, Effect, Severity, Likelihood, Risk Level, Mitigation (REQ/SYS refs), Residual Risk

### Validation Scripts

- **FR-014**: `validate-hazard-coverage.sh` SHALL verify forward coverage: every `SYS-NNN` in `system-design.md` has at least one `HAZ-NNN`
- **FR-015**: `validate-hazard-coverage.sh` SHALL verify backward coverage: every `HAZ-NNN` mitigation references at least one valid `REQ-NNN` or `SYS-NNN`
- **FR-016**: `validate-hazard-coverage.sh` SHALL verify operational state consistency: states referenced in hazards exist in `system-design.md`
- **FR-017**: The script SHALL support `--json` flag for machine-readable output
- **FR-018**: The script SHALL support `--partial` flag for validation when not all artifacts exist
- **FR-019**: The script SHALL exit with code 0 on success, code 1 on coverage gaps
- **FR-020**: `Validate-HazardCoverage.ps1` SHALL produce identical output and exit codes as the Bash equivalent

### Traceability (Matrix H)

- **FR-021**: The `build-matrix.sh` script SHALL be extended to parse `hazard-analysis.md` for `HAZ-NNN` IDs
- **FR-022**: Matrix H SHALL show: HAZ-NNN → Mitigation (REQ-NNN / SYS-NNN) → Verification (ATP-NNN / STP-NNN)
- **FR-023**: Gaps where a mitigation has no test coverage SHALL be highlighted with `⚠️ No test coverage`
- **FR-024**: `build-matrix.ps1` SHALL produce identical Matrix H output as the Bash equivalent
- **FR-025**: The `trace` command definition SHALL be updated to include Matrix H in its output

### ID Schema

- **FR-026**: `HAZ-NNN` SHALL follow the pattern `HAZ-[0-9]{3}` (zero-padded, three digits)
- **FR-027**: The `id_validator.py` SHALL be updated to recognize `HAZ-NNN` as a valid ID prefix
- **FR-028**: `HAZ-NNN` IDs SHALL be sequential within a hazard register (no gaps in initial generation; gaps allowed after progressive deepening if entries are appended)

### Extension Registration

- **FR-029**: `extension.yml` SHALL register the new `speckit.v-model.hazard-analysis` command
- **FR-030**: `extension.yml` defaults SHALL include `hazards: "HAZ"` in `id_prefixes`
- **FR-031**: `extension.yml` SHALL update the `trace` command description to mention Matrix H

### Domain Overlay Support

- **FR-032**: The command SHALL load a domain overlay from `commands/overlays/{domain}/hazard-analysis.md` when `v-model-config.yml` specifies a `domain` value, and use the overlay's severity scale in preference to the base general-purpose scale
- **FR-033**: The command description and goal SHALL use generic FMEA framing without referencing specific safety standards (ISO 14971, ISO 26262) — domain-specific framing is provided only by loaded overlays
- **FR-034**: An IEC 62304 domain overlay SHALL provide a Safety Class A/B/C severity scale with ISO 14971 integration guidance, resolving the previously missing severity table for that domain

### Key Entities

| Entity | ID Pattern | Source |
|--------|-----------|--------|
| Hazard | `HAZ-NNN` | Generated by hazard-analysis command |
| System Component | `SYS-NNN` | From system-design.md (input) |
| Requirement | `REQ-NNN` | From requirements.md (input) |
| Acceptance Test | `ATP-NNN` | From acceptance-plan.md (for Matrix H verification) |
| System Test | `STP-NNN` | From system-test.md (for Matrix H verification) |

## Success Criteria

- **SC-001**: Running `/speckit.v-model.hazard-analysis` on a project with `requirements.md` and `system-design.md` produces a valid `hazard-analysis.md` with `HAZ-NNN` IDs covering every `SYS-NNN` component.
- **SC-002**: Every hazard entry includes all 8 mandatory fields: Failure Mode, Operational State, Effect, Severity, Likelihood, Risk Level, Mitigation (with ID references), Residual Risk.
- **SC-003**: Operational state analysis produces different severity ratings for the same failure mode in different states (at least one demonstrable case).
- **SC-004**: `validate-hazard-coverage.sh --json` exits 0 with `has_gaps: false` on a complete hazard register.
- **SC-005**: `validate-hazard-coverage.sh` exits 1 and reports specific gaps when coverage is incomplete.
- **SC-006**: The `trace` command produces Matrix H showing HAZ → Mitigation → Verification for every hazard.
- **SC-007**: Progressive deepening preserves all existing `HAZ-NNN` entries and appends new ones with sequential numbering.
- **SC-008**: PowerShell scripts produce identical JSON output and exit codes as Bash equivalents.
- **SC-009**: All new IDs (`HAZ-NNN`) are recognized by the updated `id_validator.py`.

## Assumptions

1. The command builds on `requirements.md` and `system-design.md` as mandatory inputs — both must exist before hazard analysis can run.
2. Operational states are defined in the System Design document. If not explicitly defined, a single implicit "NORMAL" state is used.
3. The hazard analysis is AI-generated but script-validated — the AI produces the FMEA content, and deterministic scripts enforce coverage and consistency.
4. Progressive deepening (architecture-level) is additive only — it never modifies or removes existing entries.
5. Domain-specific severity scales (ASIL, SIL, DO-178C levels) are delivered via domain overlay files loaded from `commands/overlays/{domain}/hazard-analysis.md` when `v-model-config.yml` specifies a domain. The base command uses preference-based indirection: "if overlay loaded, use overlay scale; otherwise use general-purpose scale."
6. Matrix H is a new, separate matrix (not merged into existing matrices A–D) using the mnemonic "H" for Hazard.
7. The `trace` command already supports progressive matrix building (only including matrices for which artifacts exist) — Matrix H follows this same pattern.
8. FMEA generation does not require batching (unlike acceptance scenarios with 5-scenario batches) because hazard entries are shorter and more uniform.
