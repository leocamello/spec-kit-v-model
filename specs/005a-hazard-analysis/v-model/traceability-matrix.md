# Traceability Matrix

**Generated**: 2026-03-31
**Source**: `specs/005a-hazard-analysis/v-model/`

## Matrix A — Validation (User View)

| Requirement ID | Requirement Description | Test Case ID (ATP) | Validation Condition | Scenario ID (SCN) | Status |
|----------------|------------------------|--------------------|----------------------|--------------------|--------|
| **REQ-001** | The extension SHALL provide a `/speckit.v-model.hazard-analysis` command that reads `requirements.md` and `system-design.md` as mandatory inputs and produces `hazard-analysis.md` as output. | ATP-001-A | Command produces hazard-analysis.md from valid inputs | SCN-001-A1 | ⬜ Untested |
| **REQ-002** | The `/speckit.v-model.hazard-analysis` command SHALL assign each hazard a unique `HAZ-NNN` identifier (3-digit zero-padded, e.g., `HAZ-001`, `HAZ-012`), sequentially numbered and never renumbered once assigned. | ATP-002-A | Sequential zero-padded HAZ IDs | SCN-002-A1 | ⬜ Untested |
| **REQ-003** | Each hazard entry SHALL include all 8 mandatory fields: Failure Mode, Operational State, Effect, Severity, Likelihood, Risk Level (severity × likelihood), Mitigation (with REQ/SYS ID references), and Residual Risk. | ATP-003-A | All fields present in each entry | SCN-003-A1 | ⬜ Untested |
| | | ATP-003-B | Mitigation field contains ID references | SCN-003-B1 | ⬜ Untested |
| **REQ-004** | The command SHALL read operational states/modes from `system-design.md` and analyze each failure mode across every relevant operational state defined for the affected component. | ATP-004-A | Failure modes analyzed across defined states | SCN-004-A1 | ⬜ Untested |
| **REQ-005** | When the same failure mode on the same component has different severity depending on the operational state, the command SHALL create separate `HAZ-NNN` entries for each state-severity combination. | ATP-005-A | Same failure mode appears with different severities per state | SCN-005-A1 | ⬜ Untested |
| **REQ-006** | Every hazard mitigation field SHALL reference at least one `REQ-NNN` or `SYS-NNN` identifier, creating a traceable link from risk to control measure. | ATP-006-A | Every mitigation references valid IDs | SCN-006-A1 | ⬜ Untested |
| **REQ-007** | When `architecture-design.md` exists in the project, the command SHALL also analyze architecture-level failure modes including interface mismatches between `ARCH-NNN` modules, protocol failures, and data format incompatibilities. | ATP-007-A | ARCH-level hazards generated when architecture exists | SCN-007-A1 | ⬜ Untested |
| | | ATP-007-B | No ARCH hazards without architecture-design.md | SCN-007-B1 | ⬜ Untested |
| **REQ-008** | When a previous `hazard-analysis.md` exists, the command SHALL preserve all existing `HAZ-NNN` entries unmodified and append new entries with sequential numbering continuing from the last existing `HAZ-NNN` ID. | ATP-008-A | Existing entries unchanged, new entries appended | SCN-008-A1 | ⬜ Untested |
| **REQ-009** | When no `domain` is set in `v-model-config.yml` (or no config file exists), the command SHALL produce a general-purpose FMEA using the base severity scale without loading any domain overlay. Operational state analysis SHALL still apply. | ATP-009-A | No domain overlay scales without config | SCN-009-A1 | ⬜ Untested |
| | | ATP-009-A | No domain overlay scales without config | SCN-009-A2 | ⬜ Untested |
| **REQ-010** | The command SHALL follow the strict translator constraint: when deriving hazards from `requirements.md` and `system-design.md`, the AI SHALL NOT invent system capabilities, components, or operational states not present in the source artifacts. | ATP-010-A | No invented components or states | SCN-010-A1 | ⬜ Untested |
| **REQ-011** | The command SHALL fail with a clear error message ("hazard-analysis requires both requirements.md and system-design.md. Run /speckit.v-model.system-design first.") when `system-design.md` does not exist in the V-Model directory. | ATP-011-A | Clear error message when system-design.md absent | SCN-011-A1 | ⬜ Untested |
| **REQ-012** | When `system-design.md` defines no explicit operational states, the command SHALL use a single implicit state "NORMAL" and emit a validation warning ("No operational states defined in system-design.md — using implicit NORMAL state"). | ATP-012-A | Uses NORMAL state when none defined | SCN-012-A1 | ⬜ Untested |
| **REQ-013** | Every `SYS-NNN` in `system-design.md` SHALL have at least one associated `HAZ-NNN` entry in the output. If the AI cannot identify a realistic failure mode for a component, it SHALL generate a "No identified failure mode" entry with Severity: Negligible and flag it for human review. | ATP-013-A | Full SYS coverage with realistic failure modes | SCN-013-A1 | ⬜ Untested |
| | | ATP-013-B | Fallback for components with no plausible failure | SCN-013-B1 | ⬜ Untested |
| **REQ-014** | When progressive deepening detects no new architecture-level failure modes beyond what SYS-level analysis already covers, the command SHALL append nothing and add a note: "No additional architecture-level hazards identified." | ATP-014-A | No new entries when no new hazards found | SCN-014-A1 | ⬜ Untested |
| **REQ-015** | The command SHALL handle hazard registers of any size (50+ hazards) without requiring the batching mechanism used for acceptance scenarios, because hazard entries are shorter and more uniform. | ATP-015-A | 50+ hazards generated without batching | SCN-015-A1 | ⬜ Untested |
| **REQ-016** | When running for the first time without any existing `hazard-analysis.md`, the command SHALL create a new file starting from `HAZ-001`. | ATP-016-A | New file starts at HAZ-001 | SCN-016-A1 | ⬜ Untested |
| **REQ-017** | The extension SHALL provide a `hazard-analysis-template.md` in the `templates/` directory defining the output structure including: Summary, Risk Matrix Definition, Hazard Register (FMEA table with Operational State column), and Operational States Reference. | ATP-017-A | Template file exists with required sections | SCN-017-A1 | ⬜ Untested |
| **REQ-018** | The FMEA table in the template SHALL include columns: HAZ ID, Component (`SYS-NNN`), Failure Mode, Operational State, Effect, Severity, Likelihood, Risk Level, Mitigation (`REQ-NNN` / `SYS-NNN` refs), and Residual Risk. | ATP-018-A | All required columns present in FMEA table | SCN-018-A1 | ⬜ Untested |
| **REQ-019** | The extension SHALL provide a `validate-hazard-coverage.sh` Bash script that deterministically validates forward coverage: every `SYS-NNN` in `system-design.md` has at least one `HAZ-NNN` entry in `hazard-analysis.md`. | ATP-019-A | All SYS covered — script exits 0 | SCN-019-A1 | ⬜ Untested |
| | | ATP-019-B | Missing SYS — script exits 1 | SCN-019-B1 | ⬜ Untested |
| **REQ-020** | The `validate-hazard-coverage.sh` script SHALL validate backward coverage: every `HAZ-NNN` mitigation references at least one `REQ-NNN` or `SYS-NNN` identifier that exists in the corresponding source document (`requirements.md` or `system-design.md`). | ATP-020-A | All mitigations reference valid IDs | SCN-020-A1 | ⬜ Untested |
| | | ATP-020-B | Mitigation references non-existent ID | SCN-020-B1 | ⬜ Untested |
| **REQ-021** | The `validate-hazard-coverage.sh` script SHALL validate operational state consistency: every operational state referenced in a hazard entry exists in the set of states defined in `system-design.md` (or the implicit "NORMAL" state if none are defined). | ATP-021-A | All states match system-design.md | SCN-021-A1 | ⬜ Untested |
| | | ATP-021-B | Unknown state detected | SCN-021-B1 | ⬜ Untested |
| **REQ-022** | The `validate-hazard-coverage.sh` script SHALL support a `--json` flag for machine-readable output including fields: `has_gaps`, `forward_coverage`, `backward_coverage`, `state_consistency`, and lists of specific gaps for each check. | ATP-022-A | --json produces valid JSON | SCN-022-A1 | ⬜ Untested |
| **REQ-023** | The `validate-hazard-coverage.sh` script SHALL support a `--partial` flag for validation when not all artifacts exist (e.g., validating only forward coverage when `requirements.md` is not yet available for backward checks). | ATP-023-A | --partial validates available checks only | SCN-023-A1 | ⬜ Untested |
| **REQ-024** | The `validate-hazard-coverage.sh` script SHALL exit with code 0 when all applicable coverage checks pass and code 1 when any gap is detected. | ATP-024-A | Exit 0 on full coverage | SCN-024-A1 | ⬜ Untested |
| | | ATP-024-B | Exit 1 on any gap | SCN-024-B1 | ⬜ Untested |
| **REQ-025** | The `validate-hazard-coverage.sh` script SHALL output human-readable gap reports listing each specific gap by ID (e.g., "SYS-003: no hazard analysis mapping found", "HAZ-007 references REQ-XYZ which does not exist") suitable for CI log inspection. | ATP-025-A | Gap reports list specific IDs | SCN-025-A1 | ⬜ Untested |
| **REQ-026** | The extension SHALL provide a `Validate-HazardCoverage.ps1` PowerShell script that produces identical JSON output structure, field values, and exit codes as the Bash `validate-hazard-coverage.sh` script. | ATP-026-A | PS1 produces identical output to Bash | SCN-026-A1 | ⬜ Untested |
| | | ATP-026-A | PS1 produces identical output to Bash | SCN-026-A2 | ⬜ Untested |
| **REQ-027** | The `build-matrix.sh` script SHALL be extended to parse `hazard-analysis.md` for `HAZ-NNN` identifiers and their mitigation references (`REQ-NNN` / `SYS-NNN`). | ATP-027-A | HAZ IDs and mitigation refs extracted | SCN-027-A1 | ⬜ Untested |
| **REQ-028** | The `build-matrix.sh` script SHALL produce **Matrix H (Hazard Traceability)** showing: `HAZ-NNN` → Mitigation (`REQ-NNN` / `SYS-NNN`) → Verification (`ATP-NNN` / `STP-NNN`). | ATP-028-A | Matrix H shows HAZ → Mitigation → Verification chain | SCN-028-A1 | ⬜ Untested |
| **REQ-029** | In Matrix H, gaps where a mitigation has no associated test coverage SHALL be highlighted with `⚠️ No test coverage` in the Verification column. | ATP-029-A | Untested mitigation shows warning | SCN-029-A1 | ⬜ Untested |
| **REQ-030** | The `build-matrix.ps1` script SHALL produce identical Matrix H output as the Bash `build-matrix.sh` script. | ATP-030-A | PS1 Matrix H matches Bash | SCN-030-A1 | ⬜ Untested |
| **REQ-031** | The `/speckit.v-model.trace` command definition SHALL be updated to include Matrix H in its output when `hazard-analysis.md` exists in the project directory. | ATP-031-A | Trace output includes Matrix H when hazard-analysis.md exists | SCN-031-A1 | ⬜ Untested |
| **REQ-032** | The `HAZ-NNN` identifier pattern SHALL match the regex `HAZ-[0-9]{3}` (3-digit zero-padded). | ATP-032-A | HAZ IDs match regex HAZ-[0-9]{3} | SCN-032-A1 | ⬜ Untested |
| **REQ-033** | The `id_validator.py` SHALL be updated to recognize `HAZ-NNN` as a valid ID prefix alongside existing prefixes (REQ, ATP, SCN, SYS, STP, STS, ARCH, ITP, ITS, MOD, UTP, UTS). | ATP-033-A | id_validator.py recognizes HAZ-NNN | SCN-033-A1 | ⬜ Untested |
| **REQ-034** | `HAZ-NNN` identifiers SHALL be sequential within a hazard register (no gaps in initial generation; gaps in numbering are acceptable after progressive deepening when entries are appended at a later stage). | ATP-034-A | IDs sequential in initial generation | SCN-034-A1 | ⬜ Untested |
| **REQ-035** | The `extension.yml` SHALL register the new `speckit.v-model.hazard-analysis` command with its file path and description. | ATP-035-A | Command registered in extension.yml | SCN-035-A1 | ⬜ Untested |
| **REQ-036** | The `extension.yml` `defaults.id_prefixes` section SHALL include `hazards: "HAZ"`. | ATP-036-A | defaults.id_prefixes includes hazards | SCN-036-A1 | ⬜ Untested |
| **REQ-037** | The `extension.yml` SHALL update the `trace` command description to mention Matrix H alongside existing matrices A–D. | ATP-037-A | Trace command description mentions Matrix H | SCN-037-A1 | ⬜ Untested |
| **REQ-038** | When `v-model-config.yml` specifies a `domain` value, the command SHALL load the corresponding domain overlay from `commands/overlays/{domain}/hazard-analysis.md` and use the overlay's severity scale in preference to the base general-purpose scale. | ATP-038-A | Overlay loaded when domain is set | SCN-038-A1 | ⬜ Untested |
| | | ATP-038-A | Overlay loaded when domain is set | SCN-038-A2 | ⬜ Untested |
| | | ATP-038-B | Graceful fallback when overlay missing | SCN-038-B1 | ⬜ Untested |
| **REQ-039** | The command description and goal SHALL use generic FMEA framing without referencing specific safety standards. Domain-specific framing SHALL be provided only by loaded overlays. | ATP-039-A | Command text uses generic framing | SCN-039-A1 | ⬜ Untested |
| | | ATP-039-A | Command text uses generic framing | SCN-039-A2 | ⬜ Untested |
| **REQ-040** | An IEC 62304 domain overlay SHALL provide a Safety Class A/B/C severity scale with ISO 14971 integration guidance. | ATP-040-A | IEC 62304 overlay provides Safety Class scale | SCN-040-A1 | ⬜ Untested |
| | | ATP-040-A | IEC 62304 overlay provides Safety Class scale | SCN-040-A2 | ⬜ Untested |
| **REQ-CN-001** | [DEPRECATED — Superseded by REQ-038] Domain-specific severity scales SHALL be activated only by the `safety_critical` configuration in `v-model-config.yml`. | ATP-CN-001-A | [DEPRECATED — Superseded by ATP-038-A] | SCN-CN-001-A1 | ⬜ Deprecated |
| | | ATP-CN-001-A | [DEPRECATED — Superseded by ATP-038-A] | SCN-CN-001-A2 | ⬜ Deprecated |
| **REQ-CN-002** | Matrix H SHALL be a new, separate traceability matrix using the letter "H" (mnemonic for Hazard), not merged into existing matrices A–D and not using the next alphabetical letter "E". | ATP-CN-002-A | Matrix uses letter H, not E | SCN-CN-002-A1 | ⬜ Untested |
| **REQ-CN-003** | The extension SHALL maintain backward compatibility: projects without `hazard-analysis.md` SHALL continue to produce the same v0.4.0 output (Matrices A–D only, no Matrix H, no warning or error). | ATP-CN-003-A | No Matrix H without hazard-analysis.md | SCN-CN-003-A1 | ⬜ Untested |
| **REQ-CN-004** | The `validate-hazard-coverage.sh` and `Validate-HazardCoverage.ps1` scripts SHALL produce identical JSON output and identical exit codes when given the same inputs. | ATP-CN-004-A | Bash and PS1 produce identical results | SCN-CN-004-A1 | ⬜ Untested |
| **REQ-IF-001** | The `validate-hazard-coverage.sh` script SHALL accept the path to the V-Model directory as its first positional argument and locate `hazard-analysis.md`, `system-design.md`, and `requirements.md` within that directory. | ATP-IF-001-A | Accepts V-Model directory as positional argument | SCN-IF-001-A1 | ⬜ Untested |
| **REQ-IF-002** | The `validate-hazard-coverage.sh --json` output SHALL conform to the JSON structure: `{"has_gaps": bool, "forward_coverage": "N%", "backward_coverage": "N%", "state_consistency": bool, "forward_gaps": [...], "backward_gaps": [...], "state_warnings": [...]}`. | ATP-IF-002-A | JSON matches defined schema | SCN-IF-002-A1 | ⬜ Untested |
| **REQ-IF-003** | The `hazard-analysis.md` output SHALL be a valid Markdown file parseable by the `build-matrix.sh` script's regex patterns for `HAZ-NNN` extraction and mitigation reference extraction. | ATP-IF-003-A | Build-matrix script regex extracts HAZ IDs | SCN-IF-003-A1 | ⬜ Untested |
| **REQ-NF-001** | The `validate-hazard-coverage.sh` script SHALL use regex-based parsing consistent with existing coverage validators (e.g., `validate-requirement-coverage.sh`, `validate-system-coverage.sh`), requiring no runtime database or external tooling beyond standard Bash utilities. | ATP-NF-001-A | Script uses regex, no external tools | SCN-NF-001-A1 | ⬜ Untested |
| **REQ-NF-002** | The hazard analysis output SHALL be deterministically reproducible: running the command with the same inputs and AI model SHALL produce structurally valid output (correct IDs, correct coverage, correct operational states) regardless of minor content variation in AI prose. | ATP-NF-002-A | Validation passes on every valid generation | SCN-NF-002-A1 | ⬜ Untested |
| **REQ-NF-003** | The `validate-hazard-coverage.sh` script SHALL complete validation within 5 seconds for hazard registers containing up to 100 entries. | ATP-NF-003-A | Script completes within 5 seconds for 100 entries | SCN-NF-003-A1 | ⬜ Untested |

### Matrix A Coverage

| Metric | Value |
|--------|-------|
| **Total Requirements** | 50 (1 deprecated) |
| **Total Test Cases (ATP)** | 58 (1 deprecated) |
| **Total Scenarios (SCN)** | 64 (2 deprecated) |
| **REQ → ATP Coverage** | 50/50 (100%) |
| **ATP → SCN Coverage** | 58/58 (100%) |

## Matrix B — Verification (Architectural View)

| Requirement ID | System Component (SYS) | Component Name | Test Case ID (STP) | Technique | Scenario ID (STS) | Status |
|----------------|------------------------|----------------|--------------------|-----------|--------------------|--------|
| **REQ-001** | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-C | Interface Contract Testing | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-E | Fault Injection | STS-001-E1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-F | Boundary Value Analysis | STS-001-F1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-H | Interface Contract Testing | STS-001-H1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-I | Boundary Value Analysis | STS-001-I1 | ⬜ Untested |
| **REQ-002** | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-C | Interface Contract Testing | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-E | Fault Injection | STS-001-E1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-F | Boundary Value Analysis | STS-001-F1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-H | Interface Contract Testing | STS-001-H1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-I | Boundary Value Analysis | STS-001-I1 | ⬜ Untested |
| **REQ-003** | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-C | Interface Contract Testing | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-E | Fault Injection | STS-001-E1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-F | Boundary Value Analysis | STS-001-F1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-H | Interface Contract Testing | STS-001-H1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-I | Boundary Value Analysis | STS-001-I1 | ⬜ Untested |
| **REQ-004** | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-C | Interface Contract Testing | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-E | Fault Injection | STS-001-E1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-F | Boundary Value Analysis | STS-001-F1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-H | Interface Contract Testing | STS-001-H1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-I | Boundary Value Analysis | STS-001-I1 | ⬜ Untested |
| **REQ-005** | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-C | Interface Contract Testing | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-E | Fault Injection | STS-001-E1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-F | Boundary Value Analysis | STS-001-F1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-H | Interface Contract Testing | STS-001-H1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-I | Boundary Value Analysis | STS-001-I1 | ⬜ Untested |
| **REQ-006** | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-C | Interface Contract Testing | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-E | Fault Injection | STS-001-E1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-F | Boundary Value Analysis | STS-001-F1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-H | Interface Contract Testing | STS-001-H1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-I | Boundary Value Analysis | STS-001-I1 | ⬜ Untested |
| **REQ-007** | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-C | Interface Contract Testing | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-E | Fault Injection | STS-001-E1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-F | Boundary Value Analysis | STS-001-F1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-H | Interface Contract Testing | STS-001-H1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-I | Boundary Value Analysis | STS-001-I1 | ⬜ Untested |
| **REQ-008** | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-C | Interface Contract Testing | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-E | Fault Injection | STS-001-E1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-F | Boundary Value Analysis | STS-001-F1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-H | Interface Contract Testing | STS-001-H1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-I | Boundary Value Analysis | STS-001-I1 | ⬜ Untested |
| **REQ-009** | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-C | Interface Contract Testing | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-E | Fault Injection | STS-001-E1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-F | Boundary Value Analysis | STS-001-F1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-H | Interface Contract Testing | STS-001-H1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-I | Boundary Value Analysis | STS-001-I1 | ⬜ Untested |
| **REQ-010** | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-C | Interface Contract Testing | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-E | Fault Injection | STS-001-E1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-F | Boundary Value Analysis | STS-001-F1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-H | Interface Contract Testing | STS-001-H1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-I | Boundary Value Analysis | STS-001-I1 | ⬜ Untested |
| **REQ-011** | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-C | Interface Contract Testing | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-E | Fault Injection | STS-001-E1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-F | Boundary Value Analysis | STS-001-F1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-H | Interface Contract Testing | STS-001-H1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-I | Boundary Value Analysis | STS-001-I1 | ⬜ Untested |
| **REQ-012** | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-C | Interface Contract Testing | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-E | Fault Injection | STS-001-E1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-F | Boundary Value Analysis | STS-001-F1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-H | Interface Contract Testing | STS-001-H1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-I | Boundary Value Analysis | STS-001-I1 | ⬜ Untested |
| **REQ-013** | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-C | Interface Contract Testing | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-E | Fault Injection | STS-001-E1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-F | Boundary Value Analysis | STS-001-F1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-H | Interface Contract Testing | STS-001-H1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-I | Boundary Value Analysis | STS-001-I1 | ⬜ Untested |
| **REQ-014** | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-C | Interface Contract Testing | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-E | Fault Injection | STS-001-E1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-F | Boundary Value Analysis | STS-001-F1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-H | Interface Contract Testing | STS-001-H1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-I | Boundary Value Analysis | STS-001-I1 | ⬜ Untested |
| **REQ-015** | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-C | Interface Contract Testing | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-E | Fault Injection | STS-001-E1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-F | Boundary Value Analysis | STS-001-F1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-H | Interface Contract Testing | STS-001-H1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-I | Boundary Value Analysis | STS-001-I1 | ⬜ Untested |
| **REQ-016** | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-C | Interface Contract Testing | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-E | Fault Injection | STS-001-E1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-F | Boundary Value Analysis | STS-001-F1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-H | Interface Contract Testing | STS-001-H1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-I | Boundary Value Analysis | STS-001-I1 | ⬜ Untested |
| **REQ-017** | SYS-002 | Hazard Analysis Template | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| **REQ-018** | SYS-002 | Hazard Analysis Template | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| **REQ-019** | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-B | Interface Contract Testing | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-B | Interface Contract Testing | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-C | Boundary Value Analysis | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-C | Boundary Value Analysis | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-D | Interface Contract Testing | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-E | Fault Injection | STS-003-E1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-E | Fault Injection | STS-003-E2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-F | Boundary Value Analysis | STS-003-F1 | ⬜ Untested |
| **REQ-020** | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-B | Interface Contract Testing | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-B | Interface Contract Testing | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-C | Boundary Value Analysis | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-C | Boundary Value Analysis | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-D | Interface Contract Testing | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-E | Fault Injection | STS-003-E1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-E | Fault Injection | STS-003-E2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-F | Boundary Value Analysis | STS-003-F1 | ⬜ Untested |
| **REQ-021** | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-B | Interface Contract Testing | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-B | Interface Contract Testing | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-C | Boundary Value Analysis | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-C | Boundary Value Analysis | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-D | Interface Contract Testing | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-E | Fault Injection | STS-003-E1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-E | Fault Injection | STS-003-E2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-F | Boundary Value Analysis | STS-003-F1 | ⬜ Untested |
| **REQ-022** | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-B | Interface Contract Testing | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-B | Interface Contract Testing | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-C | Boundary Value Analysis | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-C | Boundary Value Analysis | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-D | Interface Contract Testing | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-E | Fault Injection | STS-003-E1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-E | Fault Injection | STS-003-E2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-F | Boundary Value Analysis | STS-003-F1 | ⬜ Untested |
| **REQ-023** | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-B | Interface Contract Testing | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-B | Interface Contract Testing | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-C | Boundary Value Analysis | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-C | Boundary Value Analysis | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-D | Interface Contract Testing | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-E | Fault Injection | STS-003-E1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-E | Fault Injection | STS-003-E2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-F | Boundary Value Analysis | STS-003-F1 | ⬜ Untested |
| **REQ-024** | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-B | Interface Contract Testing | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-B | Interface Contract Testing | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-C | Boundary Value Analysis | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-C | Boundary Value Analysis | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-D | Interface Contract Testing | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-E | Fault Injection | STS-003-E1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-E | Fault Injection | STS-003-E2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-F | Boundary Value Analysis | STS-003-F1 | ⬜ Untested |
| **REQ-025** | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-B | Interface Contract Testing | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-B | Interface Contract Testing | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-C | Boundary Value Analysis | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-C | Boundary Value Analysis | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-D | Interface Contract Testing | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-E | Fault Injection | STS-003-E1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-E | Fault Injection | STS-003-E2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-F | Boundary Value Analysis | STS-003-F1 | ⬜ Untested |
| **REQ-026** | SYS-004 | Hazard Coverage Validation Script (PowerShell) | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Hazard Coverage Validation Script (PowerShell) | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| **REQ-027** | SYS-005 | Matrix Builder Script Extension (Bash) | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Matrix Builder Script Extension (Bash) | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Matrix Builder Script Extension (Bash) | STP-005-B | Fault Injection | STS-005-B1 | ⬜ Untested |
| **REQ-028** | SYS-005 | Matrix Builder Script Extension (Bash) | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Matrix Builder Script Extension (Bash) | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Matrix Builder Script Extension (Bash) | STP-005-B | Fault Injection | STS-005-B1 | ⬜ Untested |
| **REQ-029** | SYS-005 | Matrix Builder Script Extension (Bash) | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Matrix Builder Script Extension (Bash) | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Matrix Builder Script Extension (Bash) | STP-005-B | Fault Injection | STS-005-B1 | ⬜ Untested |
| **REQ-030** | SYS-006 | Matrix Builder Script Extension (PowerShell) | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| **REQ-031** | SYS-007 | Trace Command Extension | STP-007-A | Interface Contract Testing | STS-007-A1 | ⬜ Untested |
| | SYS-007 | Trace Command Extension | STP-007-A | Interface Contract Testing | STS-007-A2 | ⬜ Untested |
| **REQ-032** | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-C | Interface Contract Testing | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-E | Fault Injection | STS-001-E1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-F | Boundary Value Analysis | STS-001-F1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-H | Interface Contract Testing | STS-001-H1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-I | Boundary Value Analysis | STS-001-I1 | ⬜ Untested |
| | SYS-008 | ID Validator Extension | STP-008-A | Interface Contract Testing | STS-008-A1 | ⬜ Untested |
| | SYS-008 | ID Validator Extension | STP-008-A | Interface Contract Testing | STS-008-A2 | ⬜ Untested |
| **REQ-033** | SYS-008 | ID Validator Extension | STP-008-A | Interface Contract Testing | STS-008-A1 | ⬜ Untested |
| | SYS-008 | ID Validator Extension | STP-008-A | Interface Contract Testing | STS-008-A2 | ⬜ Untested |
| **REQ-034** | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-C | Interface Contract Testing | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-E | Fault Injection | STS-001-E1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-F | Boundary Value Analysis | STS-001-F1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-H | Interface Contract Testing | STS-001-H1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-I | Boundary Value Analysis | STS-001-I1 | ⬜ Untested |
| **REQ-035** | SYS-009 | Extension Manifest Update | STP-009-A | Interface Contract Testing | STS-009-A1 | ⬜ Untested |
| **REQ-036** | SYS-009 | Extension Manifest Update | STP-009-A | Interface Contract Testing | STS-009-A1 | ⬜ Untested |
| **REQ-037** | SYS-009 | Extension Manifest Update | STP-009-A | Interface Contract Testing | STS-009-A1 | ⬜ Untested |
| **REQ-038** | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G2 | ⬜ Untested |
| **REQ-039** | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| **REQ-040** | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| **REQ-CN-001** | [DEPRECATED — Superseded by REQ-038] | — | — | — | — | ⬜ Deprecated |
| **REQ-CN-002** | SYS-005 | Matrix Builder Script Extension (Bash) | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Matrix Builder Script Extension (Bash) | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Matrix Builder Script Extension (Bash) | STP-005-B | Fault Injection | STS-005-B1 | ⬜ Untested |
| | SYS-007 | Trace Command Extension | STP-007-A | Interface Contract Testing | STS-007-A1 | ⬜ Untested |
| | SYS-007 | Trace Command Extension | STP-007-A | Interface Contract Testing | STS-007-A2 | ⬜ Untested |
| **REQ-CN-003** | SYS-005 | Matrix Builder Script Extension (Bash) | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Matrix Builder Script Extension (Bash) | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Matrix Builder Script Extension (Bash) | STP-005-B | Fault Injection | STS-005-B1 | ⬜ Untested |
| | SYS-007 | Trace Command Extension | STP-007-A | Interface Contract Testing | STS-007-A1 | ⬜ Untested |
| | SYS-007 | Trace Command Extension | STP-007-A | Interface Contract Testing | STS-007-A2 | ⬜ Untested |
| **REQ-CN-004** | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-B | Interface Contract Testing | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-B | Interface Contract Testing | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-C | Boundary Value Analysis | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-C | Boundary Value Analysis | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-D | Interface Contract Testing | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-E | Fault Injection | STS-003-E1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-E | Fault Injection | STS-003-E2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-F | Boundary Value Analysis | STS-003-F1 | ⬜ Untested |
| | SYS-004 | Hazard Coverage Validation Script (PowerShell) | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Hazard Coverage Validation Script (PowerShell) | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| **REQ-IF-001** | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-B | Interface Contract Testing | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-B | Interface Contract Testing | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-C | Boundary Value Analysis | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-C | Boundary Value Analysis | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-D | Interface Contract Testing | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-E | Fault Injection | STS-003-E1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-E | Fault Injection | STS-003-E2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-F | Boundary Value Analysis | STS-003-F1 | ⬜ Untested |
| **REQ-IF-002** | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-B | Interface Contract Testing | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-B | Interface Contract Testing | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-C | Boundary Value Analysis | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-C | Boundary Value Analysis | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-D | Interface Contract Testing | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-E | Fault Injection | STS-003-E1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-E | Fault Injection | STS-003-E2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-F | Boundary Value Analysis | STS-003-F1 | ⬜ Untested |
| **REQ-IF-003** | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-C | Interface Contract Testing | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-E | Fault Injection | STS-001-E1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-F | Boundary Value Analysis | STS-001-F1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-H | Interface Contract Testing | STS-001-H1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-I | Boundary Value Analysis | STS-001-I1 | ⬜ Untested |
| **REQ-NF-001** | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-B | Interface Contract Testing | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-B | Interface Contract Testing | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-C | Boundary Value Analysis | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-C | Boundary Value Analysis | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-D | Interface Contract Testing | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-E | Fault Injection | STS-003-E1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-E | Fault Injection | STS-003-E2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-F | Boundary Value Analysis | STS-003-F1 | ⬜ Untested |
| **REQ-NF-002** | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-C | Interface Contract Testing | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-D | Boundary Value Analysis | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-E | Fault Injection | STS-001-E1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-F | Boundary Value Analysis | STS-001-F1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-G | Equivalence Partitioning | STS-001-G2 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-H | Interface Contract Testing | STS-001-H1 | ⬜ Untested |
| | SYS-001 | Hazard Analysis Command | STP-001-I | Boundary Value Analysis | STS-001-I1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-B | Interface Contract Testing | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-B | Interface Contract Testing | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-C | Boundary Value Analysis | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-C | Boundary Value Analysis | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-D | Interface Contract Testing | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-E | Fault Injection | STS-003-E1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-E | Fault Injection | STS-003-E2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-F | Boundary Value Analysis | STS-003-F1 | ⬜ Untested |
| **REQ-NF-003** | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-B | Interface Contract Testing | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-B | Interface Contract Testing | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-C | Boundary Value Analysis | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-C | Boundary Value Analysis | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-D | Interface Contract Testing | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-E | Fault Injection | STS-003-E1 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-E | Fault Injection | STS-003-E2 | ⬜ Untested |
| | SYS-003 | Hazard Coverage Validation Script (Bash) | STP-003-F | Boundary Value Analysis | STS-003-F1 | ⬜ Untested |

### Matrix B Coverage

| Metric | Value |
|--------|-------|
| **Total System Components (SYS)** | 9 |
| **Total System Test Cases (STP)** | 23 |
| **Total System Scenarios (STS)** | 35 |
| **REQ → SYS Coverage** | 49/49 active (100%) + 1 deprecated (REQ-CN-001) |
| **SYS → STP Coverage** | 9/9 (100%) |

## Matrix C — Integration Verification (Module Boundary View)

| System Component (SYS) | Parent REQs | Architecture Module (ARCH) | Module Name | Test Case ID (ITP) | Technique | Scenario ID (ITS) | Status |
|------------------------|-------------|---------------------------|-------------|--------------------|-----------|--------------------|--------|
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-032, REQ-034, REQ-038, REQ-039, REQ-040, REQ-NF-002, REQ-IF-003) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-032, REQ-034, REQ-038, REQ-039, REQ-040, REQ-NF-002, REQ-IF-003 | ARCH-001 | Hazard Analysis Command Definition | ITP-001-A | Interface Contract Testing | ITS-001-A1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-032, REQ-034, REQ-038, REQ-039, REQ-040, REQ-NF-002, REQ-IF-003) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-032, REQ-034, REQ-038, REQ-039, REQ-040, REQ-NF-002, REQ-IF-003 | ARCH-001 | Hazard Analysis Command Definition | ITP-001-B | Interface Fault Injection | ITS-001-B1 | ⬜ Untested |
| SYS-002 (REQ-017, REQ-018) | REQ-017, REQ-018 | ARCH-002 | Hazard Analysis Template | ITP-002-A | Interface Contract Testing | ITS-002-A1 | ⬜ Untested |
| SYS-003 (REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-NF-001, REQ-NF-002, REQ-NF-003, REQ-IF-001, REQ-IF-002, REQ-CN-004) | REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-NF-001, REQ-NF-002, REQ-NF-003, REQ-IF-001, REQ-IF-002, REQ-CN-004 | ARCH-003 | Forward Coverage Validator | ITP-003-A | Interface Contract Testing | ITS-003-A1 | ⬜ Untested |
| SYS-003 (REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-NF-001, REQ-NF-002, REQ-NF-003, REQ-IF-001, REQ-IF-002, REQ-CN-004) | REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-NF-001, REQ-NF-002, REQ-NF-003, REQ-IF-001, REQ-IF-002, REQ-CN-004 | ARCH-003 | Forward Coverage Validator | ITP-003-B | Interface Fault Injection | ITS-003-B1 | ⬜ Untested |
| SYS-003 (REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-NF-001, REQ-NF-002, REQ-NF-003, REQ-IF-001, REQ-IF-002, REQ-CN-004) | REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-NF-001, REQ-NF-002, REQ-NF-003, REQ-IF-001, REQ-IF-002, REQ-CN-004 | ARCH-004 | Backward Coverage Validator | ITP-004-A | Interface Contract Testing | ITS-004-A1 | ⬜ Untested |
| SYS-003 (REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-NF-001, REQ-NF-002, REQ-NF-003, REQ-IF-001, REQ-IF-002, REQ-CN-004) | REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-NF-001, REQ-NF-002, REQ-NF-003, REQ-IF-001, REQ-IF-002, REQ-CN-004 | ARCH-004 | Backward Coverage Validator | ITP-004-B | Interface Fault Injection | ITS-004-B1 | ⬜ Untested |
| SYS-003 (REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-NF-001, REQ-NF-002, REQ-NF-003, REQ-IF-001, REQ-IF-002, REQ-CN-004) | REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-NF-001, REQ-NF-002, REQ-NF-003, REQ-IF-001, REQ-IF-002, REQ-CN-004 | ARCH-005 | State Consistency Validator | ITP-005-A | Interface Contract Testing | ITS-005-A1 | ⬜ Untested |
| SYS-003 (REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-NF-001, REQ-NF-002, REQ-NF-003, REQ-IF-001, REQ-IF-002, REQ-CN-004) | REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-NF-001, REQ-NF-002, REQ-NF-003, REQ-IF-001, REQ-IF-002, REQ-CN-004 | ARCH-005 | State Consistency Validator | ITP-005-A | Interface Contract Testing | ITS-005-A2 | ⬜ Untested |
| SYS-003 (REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-NF-001, REQ-NF-002, REQ-NF-003, REQ-IF-001, REQ-IF-002, REQ-CN-004) | REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-NF-001, REQ-NF-002, REQ-NF-003, REQ-IF-001, REQ-IF-002, REQ-CN-004 | ARCH-006 | Validation CLI and Output Formatter | ITP-006-A | Data Flow Testing | ITS-006-A1 | ⬜ Untested |
| SYS-003 (REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-NF-001, REQ-NF-002, REQ-NF-003, REQ-IF-001, REQ-IF-002, REQ-CN-004) | REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-NF-001, REQ-NF-002, REQ-NF-003, REQ-IF-001, REQ-IF-002, REQ-CN-004 | ARCH-006 | Validation CLI and Output Formatter | ITP-006-B | Interface Fault Injection | ITS-006-B1 | ⬜ Untested |
| SYS-004 (REQ-026, REQ-CN-004) | REQ-026, REQ-CN-004 | ARCH-007 | PowerShell Coverage Validation | ITP-007-A | Interface Contract Testing | ITS-007-A1 | ⬜ Untested |
| SYS-005 (REQ-027, REQ-028, REQ-029, REQ-CN-002, REQ-CN-003) | REQ-027, REQ-028, REQ-029, REQ-CN-002, REQ-CN-003 | ARCH-008 | HAZ ID Extractor | ITP-008-A | Interface Contract Testing | ITS-008-A1 | ⬜ Untested |
| SYS-005 (REQ-027, REQ-028, REQ-029, REQ-CN-002, REQ-CN-003) | REQ-027, REQ-028, REQ-029, REQ-CN-002, REQ-CN-003 | ARCH-008 | HAZ ID Extractor | ITP-008-B | Interface Fault Injection | ITS-008-B1 | ⬜ Untested |
| SYS-005 (REQ-027, REQ-028, REQ-029, REQ-CN-002, REQ-CN-003) | REQ-027, REQ-028, REQ-029, REQ-CN-002, REQ-CN-003 | ARCH-009 | Matrix H Table Builder | ITP-009-A | Data Flow Testing | ITS-009-A1 | ⬜ Untested |
| SYS-005 (REQ-027, REQ-028, REQ-029, REQ-CN-002, REQ-CN-003) | REQ-027, REQ-028, REQ-029, REQ-CN-002, REQ-CN-003 | ARCH-009 | Matrix H Table Builder | ITP-009-A | Data Flow Testing | ITS-009-A2 | ⬜ Untested |
| SYS-005 (REQ-027, REQ-028, REQ-029, REQ-CN-002, REQ-CN-003) | REQ-027, REQ-028, REQ-029, REQ-CN-002, REQ-CN-003 | ARCH-009 | Matrix H Table Builder | ITP-009-B | Interface Fault Injection | ITS-009-B1 | ⬜ Untested |
| SYS-006 (REQ-030) | REQ-030 | ARCH-010 | PowerShell Matrix H Builder | ITP-010-A | Interface Contract Testing | ITS-010-A1 | ⬜ Untested |
| SYS-007 (REQ-031, REQ-CN-002, REQ-CN-003) | REQ-031, REQ-CN-002, REQ-CN-003 | ARCH-011 | Trace Command Matrix H Integration | ITP-011-A | Data Flow Testing | ITS-011-A1 | ⬜ Untested |
| SYS-007 (REQ-031, REQ-CN-002, REQ-CN-003) | REQ-031, REQ-CN-002, REQ-CN-003 | ARCH-011 | Trace Command Matrix H Integration | ITP-011-A | Data Flow Testing | ITS-011-A2 | ⬜ Untested |
| SYS-008 (REQ-032, REQ-033) | REQ-032, REQ-033 | ARCH-012 | HAZ ID Pattern Registration | ITP-012-A | Interface Contract Testing | ITS-012-A1 | ⬜ Untested |
| SYS-009 (REQ-035, REQ-036, REQ-037) | REQ-035, REQ-036, REQ-037 | ARCH-013 | Extension Manifest Entries | ITP-013-A | Interface Contract Testing | ITS-013-A1 | ⬜ Untested |

### Matrix C Coverage

| Metric | Value |
|--------|-------|
| **Total Architecture Modules (ARCH)** | 13 |
| **Total Cross-Cutting Modules** | 0 |
| **Total Integration Test Cases (ITP)** | 19 |
| **Total Integration Scenarios (ITS)** | 22 |
| **SYS → ARCH Coverage** | 9/9 (100%) |
| **ARCH → ITP Coverage** | 13/13 (100%) |

### Uncovered Requirements (REQ without ATP)

None — full coverage.

### Orphaned Test Cases (ATP without valid REQ)

None — all tests trace to requirements.

### Uncovered Requirements — System Level (REQ without SYS)

None — full coverage.

### Orphaned System Test Cases (STP without valid SYS)

None — all system tests trace to components.

### Uncovered System Components — Architecture Level (SYS without ARCH)

None — full coverage.

### Orphaned Integration Test Cases (ITP without valid ARCH)

None — all integration tests trace to modules.

## Matrix D — Implementation Verification (Module View)

| Architecture Module (ARCH) | Parent System | Module Design (MOD) | Module Name | Test Case ID (UTP) | Technique | Scenario ID (UTS) | Status |
|---------------------------|---------------|---------------------|-------------|--------------------|-----------|--------------------|--------|
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | Input Validation and Prerequisites | UTP-001-A | Statement & Branch Coverage | UTS-001-A1 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | Input Validation and Prerequisites | UTP-001-A | Statement & Branch Coverage | UTS-001-A2 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | Input Validation and Prerequisites | UTP-001-A | Statement & Branch Coverage | UTS-001-A3 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | Input Validation and Prerequisites | UTP-001-B | Equivalence Partitioning | UTS-001-B1 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | Input Validation and Prerequisites | UTP-001-B | Equivalence Partitioning | UTS-001-B2 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-002 | Operational State Extractor | UTP-002-A | Statement & Branch Coverage | UTS-002-A1 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-002 | Operational State Extractor | UTP-002-A | Statement & Branch Coverage | UTS-002-A2 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-003 | FMEA Generator | UTP-003-A | Statement & Branch Coverage | UTS-003-A1 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-003 | FMEA Generator | UTP-003-A | Statement & Branch Coverage | UTS-003-A2 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-003 | FMEA Generator | UTP-003-A | Statement & Branch Coverage | UTS-003-A3 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-003 | FMEA Generator | UTP-003-B | Boundary Value Analysis | UTS-003-B1 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-003 | FMEA Generator | UTP-003-B | Boundary Value Analysis | UTS-003-B2 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-004 | Progressive Deepening Controller | UTP-004-A | Statement & Branch Coverage | UTS-004-A1 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-004 | Progressive Deepening Controller | UTP-004-A | Statement & Branch Coverage | UTS-004-A2 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-004 | Progressive Deepening Controller | UTP-004-A | Statement & Branch Coverage | UTS-004-A3 | ⬜ Untested |
| ARCH-002 (SYS-002) | SYS-002 | MOD-005 | Template Structure Definition | UTP-005-A | Statement & Branch Coverage | UTS-005-A1 | ⬜ Untested |
| ARCH-003 (SYS-003) | SYS-003 | MOD-006 | Forward Coverage Check | UTP-006-A | Statement & Branch Coverage | UTS-006-A1 | ⬜ Untested |
| ARCH-003 (SYS-003) | SYS-003 | MOD-006 | Forward Coverage Check | UTP-006-A | Statement & Branch Coverage | UTS-006-A2 | ⬜ Untested |
| ARCH-003 (SYS-003) | SYS-003 | MOD-006 | Forward Coverage Check | UTP-006-B | Boundary Value Analysis | UTS-006-B1 | ⬜ Untested |
| ARCH-004 (SYS-003) | SYS-003 | MOD-007 | Backward Coverage Check | UTP-007-A | Statement & Branch Coverage | UTS-007-A1 | ⬜ Untested |
| ARCH-004 (SYS-003) | SYS-003 | MOD-007 | Backward Coverage Check | UTP-007-A | Statement & Branch Coverage | UTS-007-A2 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-008 | State Consistency Check | UTP-008-A | Statement & Branch Coverage | UTS-008-A1 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-008 | State Consistency Check | UTP-008-A | Statement & Branch Coverage | UTS-008-A2 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-009 | CLI Argument Parser | UTP-009-A | Statement & Branch Coverage | UTS-009-A1 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-009 | CLI Argument Parser | UTP-009-A | Statement & Branch Coverage | UTS-009-A2 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-010 | Validation Orchestrator and Output Formatter | UTP-010-A | Statement & Branch Coverage | UTS-010-A1 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-010 | Validation Orchestrator and Output Formatter | UTP-010-A | Statement & Branch Coverage | UTS-010-A2 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-010 | Validation Orchestrator and Output Formatter | UTP-010-A | Statement & Branch Coverage | UTS-010-A3 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-011 | PowerShell Validation Engine | UTP-011-A | Statement & Branch Coverage | UTS-011-A1 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-011 | PowerShell Validation Engine | UTP-011-A | Statement & Branch Coverage | UTS-011-A2 | ⬜ Untested |
| ARCH-008 (SYS-005) | SYS-005 | MOD-012 | HAZ Regex Parser | UTP-012-A | Statement & Branch Coverage | UTS-012-A1 | ⬜ Untested |
| ARCH-008 (SYS-005) | SYS-005 | MOD-012 | HAZ Regex Parser | UTP-012-A | Statement & Branch Coverage | UTS-012-A2 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-013 | Verification Chain Resolver | UTP-013-A | Statement & Branch Coverage | UTS-013-A1 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-013 | Verification Chain Resolver | UTP-013-A | Statement & Branch Coverage | UTS-013-A2 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-014 | Matrix H Renderer | UTP-014-A | Statement & Branch Coverage | UTS-014-A1 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-014 | Matrix H Renderer | UTP-014-A | Statement & Branch Coverage | UTS-014-A2 | ⬜ Untested |
| ARCH-010 (SYS-006) | SYS-006 | MOD-015 | PowerShell Matrix H Engine | UTP-015-A | Statement & Branch Coverage | UTS-015-A1 | ⬜ Untested |
| ARCH-011 (SYS-007) | SYS-007 | MOD-016 | Matrix H Section Injector | UTP-016-A | Statement & Branch Coverage | UTS-016-A1 | ⬜ Untested |
| ARCH-011 (SYS-007) | SYS-007 | MOD-016 | Matrix H Section Injector | UTP-016-A | Statement & Branch Coverage | UTS-016-A2 | ⬜ Untested |
| ARCH-012 (SYS-008) | SYS-008 | MOD-017 | HAZ Prefix Registration | UTP-017-A | Equivalence Partitioning | UTS-017-A1 | ⬜ Untested |
| ARCH-012 (SYS-008) | SYS-008 | MOD-017 | HAZ Prefix Registration | UTP-017-A | Equivalence Partitioning | UTS-017-A2 | ⬜ Untested |
| ARCH-012 (SYS-008) | SYS-008 | MOD-017 | HAZ Prefix Registration | UTP-017-A | Equivalence Partitioning | UTS-017-A3 | ⬜ Untested |
| ARCH-013 (SYS-009) | SYS-009 | MOD-018 | Manifest Configuration | UTP-018-A | Statement & Branch Coverage | UTS-018-A1 | ⬜ Untested |

### Matrix D Coverage

| Metric | Value |
|--------|-------|
| **Total Module Designs (MOD)** | 18 |
| **External Modules** | 0 |
| **Testable Modules** | 18 |
| **Total Unit Test Cases (UTP)** | 21 |
| **Total Unit Scenarios (UTS)** | 43 |
| **ARCH → MOD Coverage** | 13/13 (100%) |
| **MOD → UTP Coverage** | 18/18 (100%) |

## Audit Notes

- **Matrix generated by**: `build-matrix.sh` (deterministic regex parser)
- **Source documents**: `requirements.md`, `acceptance-plan.md`, `system-design.md`, `system-test.md`, `architecture-design.md`, `integration-test.md`, `module-design.md`, `unit-test.md`
- **Last validated**: 2026-04-19 (partial — Matrix A updated for overlay evolution)
