# V-Model Requirements Specification: Hazard Analysis (FMEA)

**Feature Branch**: `005a-hazard-analysis`
**Created**: 2026-03-31
**Status**: Approved
**Source**: `specs/005a-hazard-analysis/spec.md`

## Overview

This document formalizes the requirements for adding a Hazard Analysis (FMEA) command to the V-Model Extension Pack. The command generates a structured hazard register with traceable `HAZ-NNN` IDs from existing `requirements.md` and `system-design.md` artifacts using systematic failure mode analysis. Hazards are analyzed across operational states defined in the system design, producing different severity classifications for the same failure mode depending on system context. Domain-specific severity scales (e.g., ASIL, DAL, Safety Class) are delivered via overlay files loaded when `v-model-config.yml` specifies a `domain` value; the base command uses a general-purpose severity scale. A deterministic validation script (`validate-hazard-coverage.sh` / `.ps1`) enforces bidirectional coverage (SYS→HAZ forward, HAZ→REQ/SYS backward) and operational state consistency. The `trace` command is extended with Matrix H (Hazard Traceability) proving the chain HAZ → Mitigation → Verification. Progressive deepening appends architecture-level failure modes when `architecture-design.md` exists, preserving all existing entries. All requirements are atomized from the feature specification using the strict translator constraint.

## Requirements

### Functional Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-001 | The extension SHALL provide a `/speckit.v-model.hazard-analysis` command that reads `requirements.md` and `system-design.md` as mandatory inputs and produces `hazard-analysis.md` as output. | P1 | US1, FR-001: Hazard analysis is a mandatory prerequisite in every regulated industry (ISO 14971, IEC 62304). Both input files are required because hazards are component failures (SYS) mitigated by requirements (REQ). | Test |
| REQ-002 | The `/speckit.v-model.hazard-analysis` command SHALL assign each hazard a unique `HAZ-NNN` identifier (3-digit zero-padded, e.g., `HAZ-001`, `HAZ-012`), sequentially numbered and never renumbered once assigned. | P1 | US1, FR-002, FR-026: Traceable identifiers are required for deterministic coverage validation and Matrix H generation. | Inspection |
| REQ-003 | Each hazard entry SHALL include all 8 mandatory fields: Failure Mode, Operational State, Effect, Severity, Likelihood, Risk Level (severity × likelihood), Mitigation (with REQ/SYS ID references), and Residual Risk. | P1 | US1, FR-003, SC-002: Every field is required by ISO 14971 §5 for a complete risk analysis record. | Inspection |
| REQ-004 | The command SHALL read operational states/modes from `system-design.md` and analyze each failure mode across every relevant operational state defined for the affected component. | P1 | US1, FR-004: ISO 14971 and ISO 26262 require hazards to be contextualized by the system state. A failure during IDLE has different severity than the same failure during active operation. | Test |
| REQ-005 | When the same failure mode on the same component has different severity depending on the operational state, the command SHALL create separate `HAZ-NNN` entries for each state-severity combination. | P1 | US1 Scenario 2, FR-005, SC-003: A sensor failure during IDLE (Negligible) and during INFUSING (Catastrophic) must appear as distinct hazard entries to satisfy ISO 14971 operational context requirements. | Test |
| REQ-006 | Every hazard mitigation field SHALL reference at least one `REQ-NNN` or `SYS-NNN` identifier, creating a traceable link from risk to control measure. | P1 | US1 Scenario 3, FR-006: ISO 14971 §7.1 requires that every identified risk has a documented risk control measure traceable to implementation. | Test |
| REQ-007 | When `architecture-design.md` exists in the project, the command SHALL also analyze architecture-level failure modes including interface mismatches between `ARCH-NNN` modules, protocol failures, and data format incompatibilities. | P2 | US4, FR-007: Architecture-level failure modes (e.g., API contract mismatches between modules) are a distinct category of hazards not visible at the SYS level. | Test |
| REQ-008 | When a previous `hazard-analysis.md` exists, the command SHALL preserve all existing `HAZ-NNN` entries unmodified and append new entries with sequential numbering continuing from the last existing `HAZ-NNN` ID. | P2 | US4, FR-008, SC-007: Progressive deepening ensures the hazard register grows richer as design detail increases, without losing earlier analysis or breaking existing traceability links. | Test |
| REQ-009 | When no `domain` is set in `v-model-config.yml` (or no config file exists), the command SHALL produce a general-purpose FMEA using the base severity scale without loading any domain overlay. Operational state analysis SHALL still apply. | P1 | FR-009, Edge case 4: The hazard-analysis command must be usable for non-regulated projects that still benefit from risk analysis. | Test |
| REQ-010 | The command SHALL follow the strict translator constraint: when deriving hazards from `requirements.md` and `system-design.md`, the AI SHALL NOT invent system capabilities, components, or operational states not present in the source artifacts. | P1 | FR-010, Constitution P5: Prevents AI hallucination of system features not defined in the specification. | Test |
| REQ-011 | The command SHALL fail with a clear error message ("hazard-analysis requires both requirements.md and system-design.md. Run /speckit.v-model.system-design first.") when `system-design.md` does not exist in the V-Model directory. | P1 | Edge case 3: Missing prerequisites must produce actionable error messages, not malformed output. | Test |
| REQ-012 | When `system-design.md` defines no explicit operational states, the command SHALL use a single implicit state "NORMAL" and emit a validation warning ("No operational states defined in system-design.md — using implicit NORMAL state"). | P1 | Edge case 1: The command must not fail when operational states are undefined; it degrades gracefully. | Test |
| REQ-013 | Every `SYS-NNN` in `system-design.md` SHALL have at least one associated `HAZ-NNN` entry in the output. If the AI cannot identify a realistic failure mode for a component, it SHALL generate a "No identified failure mode" entry with Severity: Negligible and flag it for human review. | P1 | Edge case 2, US1 Independent Test (1): Forward coverage is a mandatory validation check; every component must be assessed for risk. | Test |
| REQ-014 | When progressive deepening detects no new architecture-level failure modes beyond what SYS-level analysis already covers, the command SHALL append nothing and add a note: "No additional architecture-level hazards identified." | P2 | Edge case 5: Progressive deepening must handle the no-new-hazards case gracefully without producing empty entries. | Test |
| REQ-015 | The command SHALL handle hazard registers of any size (50+ hazards) without requiring the batching mechanism used for acceptance scenarios, because hazard entries are shorter and more uniform. | P2 | Edge case 7: Large hazard registers must not artificially constrain generation. | Test |
| REQ-016 | When running for the first time without any existing `hazard-analysis.md`, the command SHALL create a new file starting from `HAZ-001`. | P1 | Edge case 8: First-run behavior is the default; progressive deepening only activates when an existing file is detected. | Test |
| REQ-017 | The extension SHALL provide a `hazard-analysis-template.md` in the `templates/` directory defining the output structure including: Summary, Risk Matrix Definition, Hazard Register (FMEA table with Operational State column), and Operational States Reference. | P1 | FR-011, FR-012: Templates enforce consistent output structure across all AI-generated artifacts. | Inspection |
| REQ-018 | The FMEA table in the template SHALL include columns: HAZ ID, Component (`SYS-NNN`), Failure Mode, Operational State, Effect, Severity, Likelihood, Risk Level, Mitigation (`REQ-NNN` / `SYS-NNN` refs), and Residual Risk. | P1 | FR-013: The column structure must match the 8 mandatory fields per hazard entry (REQ-003) plus the component identifier. | Inspection |
| REQ-019 | The extension SHALL provide a `validate-hazard-coverage.sh` Bash script that deterministically validates forward coverage: every `SYS-NNN` in `system-design.md` has at least one `HAZ-NNN` entry in `hazard-analysis.md`. | P1 | US2, FR-014: Deterministic verification (Constitution P2) requires script-based, not AI-based, coverage validation. | Test |
| REQ-020 | The `validate-hazard-coverage.sh` script SHALL validate backward coverage: every `HAZ-NNN` mitigation references at least one `REQ-NNN` or `SYS-NNN` identifier that exists in the corresponding source document (`requirements.md` or `system-design.md`). | P1 | US2, FR-015: Backward coverage ensures mitigations are traceable to real requirements or components, not phantom references. | Test |
| REQ-021 | The `validate-hazard-coverage.sh` script SHALL validate operational state consistency: every operational state referenced in a hazard entry exists in the set of states defined in `system-design.md` (or the implicit "NORMAL" state if none are defined). | P1 | US2, FR-016: Prevents hazard entries from referencing invented operational states not defined in the system design. | Test |
| REQ-022 | The `validate-hazard-coverage.sh` script SHALL support a `--json` flag for machine-readable output including fields: `has_gaps`, `forward_coverage`, `backward_coverage`, `state_consistency`, and lists of specific gaps for each check. | P1 | US2 Scenario 2, FR-017: Machine-readable output enables the trace command and CI pipelines to parse coverage results. | Test |
| REQ-023 | The `validate-hazard-coverage.sh` script SHALL support a `--partial` flag for validation when not all artifacts exist (e.g., validating only forward coverage when `requirements.md` is not yet available for backward checks). | P1 | FR-018: Enables CI to run after hazard generation before all dependent artifacts are complete. | Test |
| REQ-024 | The `validate-hazard-coverage.sh` script SHALL exit with code 0 when all applicable coverage checks pass and code 1 when any gap is detected. | P1 | US2, FR-019: Non-zero exit codes enable CI hard-fail enforcement (Constitution P2 quality gate). | Test |
| REQ-025 | The `validate-hazard-coverage.sh` script SHALL output human-readable gap reports listing each specific gap by ID (e.g., "SYS-003: no hazard analysis mapping found", "HAZ-007 references REQ-XYZ which does not exist") suitable for CI log inspection. | P1 | US2 Independent Test, FR-019: Developers must be able to identify and fix specific gaps from the CI output. | Test |
| REQ-026 | The extension SHALL provide a `Validate-HazardCoverage.ps1` PowerShell script that produces identical JSON output structure, field values, and exit codes as the Bash `validate-hazard-coverage.sh` script. | P3 | US5, FR-020: PowerShell parity ensures Windows/cross-platform support following the established convention. | Test |
| REQ-027 | The `build-matrix.sh` script SHALL be extended to parse `hazard-analysis.md` for `HAZ-NNN` identifiers and their mitigation references (`REQ-NNN` / `SYS-NNN`). | P1 | US3, FR-021: Matrix H requires the build-matrix script to understand hazard→mitigation relationships. | Test |
| REQ-028 | The `build-matrix.sh` script SHALL produce **Matrix H (Hazard Traceability)** showing: `HAZ-NNN` → Mitigation (`REQ-NNN` / `SYS-NNN`) → Verification (`ATP-NNN` / `STP-NNN`). | P1 | US3, FR-022: Matrix H proves the chain from each hazard through its mitigation to the test case that verifies the mitigation is implemented. | Test |
| REQ-029 | In Matrix H, gaps where a mitigation has no associated test coverage SHALL be highlighted with `⚠️ No test coverage` in the Verification column. | P1 | US3 Scenario 3, FR-023: Gaps in hazard-to-verification traceability must be visible for regulatory review. | Inspection |
| REQ-030 | The `build-matrix.ps1` script SHALL produce identical Matrix H output as the Bash `build-matrix.sh` script. | P3 | FR-024: PowerShell parity for the build-matrix extension follows the same convention as all other scripts. | Test |
| REQ-031 | The `/speckit.v-model.trace` command definition SHALL be updated to include Matrix H in its output when `hazard-analysis.md` exists in the project directory. | P1 | US3, FR-025: The trace command already supports progressive matrix building; Matrix H follows this pattern. | Inspection |
| REQ-032 | The `HAZ-NNN` identifier pattern SHALL match the regex `HAZ-[0-9]{3}` (3-digit zero-padded). | P1 | FR-026: Consistent ID patterns enable deterministic validation and id_validator.py recognition. | Inspection |
| REQ-033 | The `id_validator.py` SHALL be updated to recognize `HAZ-NNN` as a valid ID prefix alongside existing prefixes (REQ, ATP, SCN, SYS, STP, STS, ARCH, ITP, ITS, MOD, UTP, UTS). | P1 | FR-027: The Python validator must recognize all ID types used across the V-Model. | Test |
| REQ-034 | `HAZ-NNN` identifiers SHALL be sequential within a hazard register (no gaps in initial generation; gaps in numbering are acceptable after progressive deepening when entries are appended at a later stage). | P1 | FR-028: Sequential IDs ensure auditability; gaps are tolerated only as a result of the append-only progressive deepening mechanism. | Inspection |
| REQ-035 | The `extension.yml` SHALL register the new `speckit.v-model.hazard-analysis` command with its file path and description. | P1 | FR-029: All commands must be registered in the extension manifest for spec-kit discovery. | Inspection |
| REQ-036 | The `extension.yml` `defaults.id_prefixes` section SHALL include `hazards: "HAZ"`. | P1 | FR-030: The new ID prefix must be declared in the extension configuration. | Inspection |
| REQ-037 | The `extension.yml` SHALL update the `trace` command description to mention Matrix H alongside existing matrices A–D. | P1 | FR-031: The trace command documentation must reflect its expanded capability. | Inspection |
| REQ-038 | When `v-model-config.yml` specifies a `domain` value (e.g., `iso_26262`, `do_178c`, `iec_62304`), the command SHALL load the corresponding domain overlay from `commands/overlays/{domain}/hazard-analysis.md` and use the overlay's severity scale in preference to the base general-purpose scale. | P1 | FR-032, Assumption 5: Domain-specific severity scales are delivered via overlay files, enabling the base command to remain domain-agnostic while supporting regulated industries. | Test |
| REQ-039 | The command description and goal SHALL use generic FMEA framing (e.g., "Failure Mode and Effects Analysis") without referencing specific safety standards (ISO 14971, ISO 26262, DO-178C) in command text. Domain-specific framing SHALL be provided only by loaded overlays. | P1 | FR-033: Generic framing ensures the command is usable across all industries; domain specificity is an overlay concern. | Inspection |
| REQ-040 | An IEC 62304 domain overlay (`commands/overlays/iec_62304/hazard-analysis.md`) SHALL provide a Safety Class A/B/C severity scale with ISO 14971 integration guidance, resolving the previously missing severity table for that domain. | P1 | FR-034: IEC 62304 was the only supported domain without a severity table; the overlay completes domain parity. | Inspection |

### Non-Functional Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-NF-001 | The `validate-hazard-coverage.sh` script SHALL use regex-based parsing consistent with existing coverage validators (e.g., `validate-requirement-coverage.sh`, `validate-system-coverage.sh`), requiring no runtime database or external tooling beyond standard Bash utilities. | P1 | Assumption 3: Deterministic validation must be self-contained and portable, matching the architecture of existing validators. | Inspection |
| REQ-NF-002 | The hazard analysis output SHALL be deterministically reproducible: running the command with the same inputs and AI model SHALL produce structurally valid output (correct IDs, correct coverage, correct operational states) regardless of minor content variation in AI prose. | P1 | Constitution P2: Deterministic script validation must pass on every valid generation, even if AI prose varies between runs. | Analysis |
| REQ-NF-003 | The `validate-hazard-coverage.sh` script SHALL complete validation within 5 seconds for hazard registers containing up to 100 entries. | P2 | Assumption 8: No batching needed; scripts must be fast enough for interactive CI feedback. | Test |

### Interface Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-IF-001 | The `validate-hazard-coverage.sh` script SHALL accept the path to the V-Model directory as its first positional argument and locate `hazard-analysis.md`, `system-design.md`, and `requirements.md` within that directory. | P1 | Consistent with `validate-requirement-coverage.sh` and `validate-system-coverage.sh` argument conventions. | Test |
| REQ-IF-002 | The `validate-hazard-coverage.sh --json` output SHALL conform to the JSON structure: `{"has_gaps": bool, "forward_coverage": "N%", "backward_coverage": "N%", "state_consistency": bool, "forward_gaps": [...], "backward_gaps": [...], "state_warnings": [...]}`. | P1 | FR-017, US2 Scenario 2: Machine-readable output must have a defined schema for downstream consumers (trace command, CI). | Test |
| REQ-IF-003 | The `hazard-analysis.md` output SHALL be a valid Markdown file parseable by the `build-matrix.sh` script's regex patterns for `HAZ-NNN` extraction and mitigation reference extraction. | P1 | FR-021: The hazard register must be machine-parseable for Matrix H generation. | Test |

### Constraint Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-CN-001 | [DEPRECATED — Superseded by REQ-038] Domain-specific severity scales (ASIL for ISO 26262, SIL for IEC 61508, failure condition for DO-178C) SHALL be activated only by the `safety_critical` configuration in `v-model-config.yml`, not by the hazard-analysis command itself. | P1 | Assumption 5: Domain configuration is a project-level setting, not a per-command flag. | Inspection |
| REQ-CN-002 | Matrix H SHALL be a new, separate traceability matrix using the letter "H" (mnemonic for Hazard), not merged into existing matrices A–D and not using the next alphabetical letter "E". | P1 | Design decision: Matrix H was chosen for instant recognizability over alphabetical sequence. | Inspection |
| REQ-CN-003 | The extension SHALL maintain backward compatibility: projects without `hazard-analysis.md` SHALL continue to produce the same v0.4.0 output (Matrices A–D only, no Matrix H, no warning or error). | P1 | Assumption 7: Existing users must not be affected by the new hazard-analysis capability. | Test |
| REQ-CN-004 | The `validate-hazard-coverage.sh` and `Validate-HazardCoverage.ps1` scripts SHALL produce identical JSON output and identical exit codes when given the same inputs. | P3 | US5, FR-020: Cross-platform parity is a constitutional requirement (Constitution P7). | Test |

## Assumptions

- Both `requirements.md` and `system-design.md` must exist before the hazard-analysis command can run — the command will not generate hazards from `spec.md` alone.
- Operational states are expected to be defined in `system-design.md`. If not present, the implicit "NORMAL" state is used with a validation warning.
- The hazard analysis is AI-generated but script-validated — the AI produces the FMEA content, and deterministic scripts enforce coverage and consistency.
- Progressive deepening (architecture-level) is additive only — it never modifies or removes existing `HAZ-NNN` entries.
- Domain-specific severity scales (ASIL, SIL, DO-178C levels) are delivered via domain overlay files loaded from `commands/overlays/{domain}/hazard-analysis.md` when `v-model-config.yml` specifies a `domain` value. The base command uses preference-based indirection: "if overlay loaded, use overlay scale; otherwise use general-purpose scale."
- Matrix H is a new, separate matrix (not merged into A–D) using the mnemonic "H" for Hazard.
- The `trace` command already supports progressive matrix building (only including matrices for which artifacts exist) — Matrix H follows this same pattern.
- FMEA generation does not require the batching mechanism used for acceptance scenarios, because hazard entries are shorter and more uniform.

## Dependencies

- **`requirements.md`**: Must exist with `REQ-NNN` identifiers (generated by `/speckit.v-model.requirements`)
- **`system-design.md`**: Must exist with `SYS-NNN` components and operational state definitions (generated by `/speckit.v-model.system-design`)
- **`architecture-design.md`** *(optional)*: When present, enables architecture-level progressive deepening with `ARCH-NNN` failure modes
- **`acceptance-plan.md`** *(optional)*: When present, enables Matrix H to show verification chain (HAZ → REQ → ATP)
- **`system-test.md`** *(optional)*: When present, enables Matrix H to show verification chain (HAZ → SYS → STP)
- **`v-model-config.yml`** *(optional)*: When present with a `domain` value, activates domain-specific severity scales via overlay loading from `commands/overlays/{domain}/hazard-analysis.md`

## Glossary

| Term | Definition |
|------|-----------|
| FMEA | Failure Mode and Effects Analysis — systematic technique for identifying potential failure modes, their causes, effects, and mitigations |
| HARA | Hazard Analysis and Risk Assessment — ISO 26262 methodology for automotive hazard classification |
| Operational State | A defined mode of system operation (e.g., IDLE, ACTIVE, ERROR) that affects the severity of failure consequences |
| Risk Level | Product of Severity × Likelihood, determining the overall risk classification of a hazard |
| Residual Risk | The remaining risk after mitigation measures are applied |
| Progressive Deepening | The process of re-running hazard analysis after additional design artifacts exist, appending new failure modes without modifying existing entries |
| Matrix H | Hazard Traceability Matrix — proves the chain from each hazard through its mitigation to the test that verifies implementation |
| Forward Coverage | Validation that every source ID (SYS-NNN) maps to at least one target ID (HAZ-NNN) |
| Backward Coverage | Validation that every target ID's references (REQ/SYS in mitigation) exist in the source documents |

---

**Total Requirements**: 50 (1 deprecated)
**By Priority**: P1: 42 | P2: 5 | P3: 3
**By Verification Method**: Test: 33 | Inspection: 16 | Analysis: 1 | Demonstration: 0
