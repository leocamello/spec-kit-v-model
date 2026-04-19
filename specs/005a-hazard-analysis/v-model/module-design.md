# Module Design: Hazard Analysis (FMEA)

**Feature Branch**: `005a-hazard-analysis`
**Created**: 2026-04-01
**Status**: Approved
**Source**: `specs/005a-hazard-analysis/v-model/architecture-design.md`

## Overview

This module design decomposes the 13 architecture modules into 18 implementable low-level modules. The Hazard Analysis Command (ARCH-001) decomposes into 4 modules: input validation, operational state extraction, FMEA generation, and progressive deepening. The template (ARCH-002) and manifest (ARCH-013) each map 1:1 as configuration modules. The Bash validation script (ARCH-003 through ARCH-006) decomposes into 5 modules: three coverage checkers, a CLI parser, and an orchestrator. PowerShell parity scripts (ARCH-007, ARCH-010) each map 1:1 mirroring Bash logic. The matrix builder (ARCH-008/009) decomposes into 3 modules: extractor, resolver, and renderer. Each module has pseudocode detailed enough that implementation is a direct translation exercise.

## ID Schema

- **Module Design**: `MOD-NNN` — sequential identifier for each module (3-digit zero-padded)
- **Parent Architecture Modules**: Comma-separated `ARCH-NNN` list per module (many-to-many, authoritative for traceability)
- **Target Source File(s)**: Comma-separated file paths mapping to the repository codebase

## Module Designs

### Module: MOD-001 (Input Validation and Prerequisites)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `commands/hazard-analysis.md` (Step 1–2)

#### Algorithmic / Logic View

```pseudocode
FUNCTION validate_prerequisites(vmodel_dir: Path) -> ValidationResult:
    // Step 1: Check mandatory inputs
    requirements_path = vmodel_dir / "requirements.md"
    system_design_path = vmodel_dir / "system-design.md"

    IF NOT exists(requirements_path):
        RETURN Error("hazard-analysis requires both requirements.md and system-design.md. Run /speckit.v-model.system-design first.")
    IF NOT exists(system_design_path):
        RETURN Error("hazard-analysis requires both requirements.md and system-design.md. Run /speckit.v-model.system-design first.")

    // Step 2: Check optional inputs
    arch_design_path = vmodel_dir / "architecture-design.md"
    existing_hazard_path = vmodel_dir / "hazard-analysis.md"
    config_path = repo_root / "v-model-config.yml"

    has_architecture = exists(arch_design_path)
    has_existing_hazards = exists(existing_hazard_path)
    domain = NULL

    IF exists(config_path):
        config = parse_yaml(config_path)
        domain = config.get("domain", NULL)

    RETURN ValidationResult(
        requirements=requirements_path,
        system_design=system_design_path,
        architecture=arch_design_path IF has_architecture ELSE NULL,
        existing_hazards=existing_hazard_path IF has_existing_hazards ELSE NULL,
        domain=domain
    )
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Range | Constraints |
|------|------|-----------|-------------|
| requirements_path | Path | OS max path | Must exist |
| system_design_path | Path | OS max path | Must exist |
| arch_design_path | Path | OS max path | Optional |
| domain | String | Enum: iso_26262, do_178c, iec_62304, NULL | NULL when unconfigured |

#### Error Handling & Return Codes

| Error Condition | Handling | Maps to ARCH Contract |
|----------------|----------|----------------------|
| requirements.md missing | Return Error with specific message | ARCH-001 Exception: Missing prerequisite |
| system-design.md missing | Return Error with specific message | ARCH-001 Exception: Missing prerequisite |
| v-model-config.yml malformed | Treat domain as NULL, continue | Graceful degradation |

---

### Module: MOD-002 (Operational State Extractor)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `commands/hazard-analysis.md` (Step 2–3)

#### Algorithmic / Logic View

```pseudocode
FUNCTION extract_operational_states(system_design: String) -> StateSet:
    // Step 1: Search for operational states section or table
    states = []
    FOR EACH line IN system_design:
        IF line MATCHES regex for operational state definition:
            state_name = extract_state_name(line)
            states.append(state_name)

    // Step 2: Handle implicit NORMAL state
    IF states IS EMPTY:
        EMIT warning("No operational states defined in system-design.md — using implicit NORMAL state")
        states = ["NORMAL"]

    RETURN StateSet(states=states, is_implicit=(length(states) == 1 AND states[0] == "NORMAL"))
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Range | Constraints |
|------|------|-----------|-------------|
| states | Array of String | 1–50 | At least "NORMAL" if empty |
| is_implicit | Boolean | true/false | True only when no explicit states found |

#### Error Handling & Return Codes

| Error Condition | Handling | Maps to ARCH Contract |
|----------------|----------|----------------------|
| No explicit states in system-design.md | Use implicit "NORMAL", emit warning | ARCH-001: Implicit state fallback |

---

### Module: MOD-003 (FMEA Generator)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `commands/hazard-analysis.md` (Step 3–4)

#### Algorithmic / Logic View

```pseudocode
FUNCTION generate_fmea(sys_components: Array, states: StateSet, requirements: Array, domain: String, start_id: Integer) -> HazardRegister:
    hazards = []
    current_id = start_id

    FOR EACH sys IN sys_components:
        failure_modes = identify_failure_modes(sys)

        IF failure_modes IS EMPTY:
            // Generate "No identified failure mode" entry
            hazards.append(HazardEntry(
                id=format("HAZ-%03d", current_id),
                component=sys.id,
                failure_mode="No identified failure mode",
                operational_state=states[0],
                effect="None identified",
                severity="Negligible",
                likelihood="Remote",
                risk_level="Negligible",
                mitigation=find_related_req(sys, requirements),
                residual_risk="Acceptable — flagged for human review"
            ))
            current_id += 1
            CONTINUE

        FOR EACH failure_mode IN failure_modes:
            relevant_states = get_relevant_states(sys, states, failure_mode)

            FOR EACH state IN relevant_states:
                severity = classify_severity(failure_mode, state, domain)
                likelihood = classify_likelihood(failure_mode, state)
                risk_level = compute_risk(severity, likelihood)
                mitigation = find_mitigation(failure_mode, sys, requirements)

                hazards.append(HazardEntry(
                    id=format("HAZ-%03d", current_id),
                    component=sys.id,
                    failure_mode=failure_mode.description,
                    operational_state=state,
                    effect=failure_mode.effect,
                    severity=severity,
                    likelihood=likelihood,
                    risk_level=risk_level,
                    mitigation=mitigation,
                    residual_risk=assess_residual(risk_level, mitigation)
                ))
                current_id += 1

    RETURN HazardRegister(entries=hazards)

FUNCTION classify_severity(failure_mode, state, domain) -> String:
    IF domain == "iso_26262":
        RETURN asil_severity(failure_mode, state)  // S0-S3
    ELSE IF domain == "do_178c":
        RETURN dac_severity(failure_mode, state)  // CAT-I through CAT-V
    ELSE:
        RETURN general_severity(failure_mode, state)  // Negligible-Catastrophic
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Range | Constraints |
|------|------|-----------|-------------|
| hazards | Array of HazardEntry | 1–999 | Sequential HAZ IDs, no gaps in initial generation |
| HazardEntry.id | String | "HAZ-001" to "HAZ-999" | Matches regex `HAZ-[0-9]{3}` |
| HazardEntry.severity | String | Domain-dependent enum | General: Negligible/Minor/Moderate/Critical/Catastrophic |
| HazardEntry.risk_level | String | Severity × Likelihood | Computed, not assigned directly |
| HazardEntry.mitigation | String | REQ-NNN or SYS-NNN references | At least one reference required |

#### Error Handling & Return Codes

| Error Condition | Handling | Maps to ARCH Contract |
|----------------|----------|----------------------|
| No failure mode for SYS component | Generate "No identified failure mode" entry flagged for human review | ARCH-001: Every SYS has at least one HAZ |
| Mitigation cannot link to REQ/SYS | Flag entry for human review with note | ARCH-001: Strict translator constraint |

---

### Module: MOD-004 (Progressive Deepening Controller)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `commands/hazard-analysis.md` (Step 2, 5)

#### Algorithmic / Logic View

```pseudocode
FUNCTION apply_progressive_deepening(existing_hazards: HazardRegister, architecture: String) -> DeepResult:
    IF architecture IS NULL:
        RETURN DeepResult(new_entries=[], note=NULL)

    // Find highest existing HAZ ID
    max_id = 0
    FOR EACH entry IN existing_hazards.entries:
        num = parse_int(entry.id[4:])  // Extract NNN from HAZ-NNN
        IF num > max_id:
            max_id = num

    // Identify architecture-level failure modes
    arch_modules = extract_arch_modules(architecture)
    arch_failures = []

    FOR EACH arch IN arch_modules:
        failures = identify_arch_failures(arch)
        // Include: interface mismatches, protocol failures, data format incompatibilities
        FOR EACH failure IN failures:
            IF NOT already_covered(failure, existing_hazards):
                arch_failures.append(failure)

    IF arch_failures IS EMPTY:
        RETURN DeepResult(new_entries=[], note="No additional architecture-level hazards identified.")

    // Generate new entries starting from max_id + 1
    new_entries = generate_fmea_for_arch(arch_failures, start_id=max_id + 1)

    RETURN DeepResult(new_entries=new_entries, note=NULL)

FUNCTION merge_hazards(existing: HazardRegister, deep_result: DeepResult) -> HazardRegister:
    // Append-only: existing entries are NEVER modified
    merged = existing.entries + deep_result.new_entries
    RETURN HazardRegister(entries=merged)
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Range | Constraints |
|------|------|-----------|-------------|
| max_id | Integer | 0–999 | 0 when no existing hazards |
| arch_failures | Array | 0–100 | Only architecture-level failures not in existing register |

#### Error Handling & Return Codes

| Error Condition | Handling | Maps to ARCH Contract |
|----------------|----------|----------------------|
| No new arch-level hazards | Return empty list with note | ARCH-001: Progressive deepening graceful handling |
| Existing HAZ entries | Preserve unmodified, never renumber | ARCH-001: Append-only constraint |

---

### Module: MOD-005 (Template Structure Definition)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `templates/hazard-analysis-template.md`

#### Algorithmic / Logic View

```pseudocode
TEMPLATE hazard_analysis_template:
    SECTION "Summary":
        placeholder = "[Brief summary of hazard analysis scope and findings]"

    SECTION "Risk Matrix Definition":
        severity_axis = ["Negligible", "Minor", "Moderate", "Critical", "Catastrophic"]
        likelihood_axis = ["Remote", "Unlikely", "Possible", "Likely", "Frequent"]
        grid = severity × likelihood -> risk_level

    SECTION "Operational States Reference":
        TABLE columns = [State, Description, Source Component]

    SECTION "Hazard Register":
        TABLE columns = [HAZ ID, Component (SYS-NNN), Failure Mode,
                         Operational State, Effect, Severity, Likelihood,
                         Risk Level, Mitigation (REQ/SYS refs), Residual Risk]

    CONDITIONAL SECTION "Domain-Specific Severity Scales":
        IF domain configured:
            Load severity scale from domain overlay
            (e.g., ASIL for iso_26262, Safety Class for iec_62304, DAL for do_178c)
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Range | Constraints |
|------|------|-----------|-------------|
| FMEA columns | Array of String | 10 columns | Fixed schema per REQ-018 |
| severity_axis | Array of String | 5 levels | Domain-specific when configured |
| likelihood_axis | Array of String | 5 levels | Standard scale |

#### Error Handling & Return Codes

| Error Condition | Handling | Maps to ARCH Contract |
|----------------|----------|----------------------|
| Template file not found | ARCH-001 fails with file-not-found error | ARCH-002 Exception: Template not found |

---

### Module: MOD-006 (Forward Coverage Check)

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `scripts/bash/validate-hazard-coverage.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION check_forward_coverage(system_design_path: Path, hazard_analysis_path: Path) -> ForwardResult:
    // Extract all SYS-NNN from system-design.md
    sys_ids = grep_unique(system_design_path, regex="SYS-[0-9]{3}")

    // Extract Component column values from hazard-analysis.md FMEA table
    haz_components = grep_unique(hazard_analysis_path, regex="SYS-[0-9]{3}")
    // Note: HAZ entries reference SYS-NNN in the Component column

    // Compute coverage
    covered = intersection(sys_ids, haz_components)
    uncovered = difference(sys_ids, haz_components)
    pct = (length(covered) / length(sys_ids)) * 100

    RETURN ForwardResult(covered=covered, uncovered=uncovered, pct=pct)
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Range | Constraints |
|------|------|-----------|-------------|
| sys_ids | Array of String | 1–100 | Unique, sorted |
| haz_components | Array of String | 0–100 | Extracted from FMEA Component column |

#### Error Handling & Return Codes

| Error Condition | Handling | Maps to ARCH Contract |
|----------------|----------|----------------------|
| No SYS-NNN in system-design.md | Return pct=0, uncovered=[] | ARCH-003: Empty input handled |
| No HAZ entries found | Return pct=0, uncovered=[all SYS] | ARCH-003: Zero coverage reported |

---

### Module: MOD-007 (Backward Coverage Check)

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `scripts/bash/validate-hazard-coverage.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION check_backward_coverage(hazard_path: Path, requirements_path: Path, system_design_path: Path) -> BackwardResult:
    // Extract all valid REQ and SYS IDs from source documents
    valid_req_ids = grep_unique(requirements_path, regex="REQ-([A-Z]+-)?[0-9]{3}")
    valid_sys_ids = grep_unique(system_design_path, regex="SYS-[0-9]{3}")
    valid_ids = union(valid_req_ids, valid_sys_ids)

    // Extract mitigation references from FMEA table
    broken_refs = []
    total_refs = 0
    valid_count = 0

    FOR EACH haz_line IN parse_fmea_table(hazard_path):
        haz_id = extract_haz_id(haz_line)
        mitigation_refs = extract_refs(haz_line.mitigation_column)
        total_refs += length(mitigation_refs)

        IF mitigation_refs IS EMPTY:
            broken_refs.append(format("%s has no mitigation references", haz_id))
            CONTINUE

        FOR EACH ref IN mitigation_refs:
            IF ref NOT IN valid_ids:
                broken_refs.append(format("%s references %s which does not exist", haz_id, ref))
            ELSE:
                valid_count += 1

    pct = (valid_count / total_refs) * 100 IF total_refs > 0 ELSE 0

    RETURN BackwardResult(valid=valid_count, broken=broken_refs, pct=pct)
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Range | Constraints |
|------|------|-----------|-------------|
| valid_ids | Set of String | 1–200 | Union of REQ + SYS IDs |
| broken_refs | Array of String | 0–100 | Human-readable gap descriptions |

#### Error Handling & Return Codes

| Error Condition | Handling | Maps to ARCH Contract |
|----------------|----------|----------------------|
| requirements.md missing (non-partial) | Return error | ARCH-004 Exception: File not found |
| HAZ entry with no mitigation refs | Add to broken_refs | ARCH-004: Every HAZ needs mitigation |

---

### Module: MOD-008 (State Consistency Check)

**Parent Architecture Modules**: ARCH-005
**Target Source File(s)**: `scripts/bash/validate-hazard-coverage.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION check_state_consistency(hazard_path: Path, system_design_path: Path) -> StateResult:
    // Extract defined states from system-design.md
    defined_states = extract_operational_states(system_design_path)

    IF defined_states IS EMPTY:
        defined_states = ["NORMAL"]

    // Extract states referenced in hazard entries
    haz_states = []
    FOR EACH haz_line IN parse_fmea_table(hazard_path):
        state = extract_operational_state(haz_line)
        IF state NOT IN haz_states:
            haz_states.append(state)

    // Check consistency
    undefined = difference(haz_states, defined_states)
    consistent = (length(undefined) == 0)

    RETURN StateResult(defined_states=defined_states, undefined_states=undefined, consistent=consistent)
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Range | Constraints |
|------|------|-----------|-------------|
| defined_states | Array of String | 1–20 | At least "NORMAL" |
| undefined | Array of String | 0–20 | States in hazards but not in design |

#### Error Handling & Return Codes

| Error Condition | Handling | Maps to ARCH Contract |
|----------------|----------|----------------------|
| No states in system-design.md | Use implicit "NORMAL" | ARCH-005: Implicit state fallback |

---

### Module: MOD-009 (CLI Argument Parser)

**Parent Architecture Modules**: ARCH-006
**Target Source File(s)**: `scripts/bash/validate-hazard-coverage.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION parse_cli_args(args: Array) -> CLIConfig:
    json_mode = false
    partial_mode = false
    vmodel_dir = NULL

    FOR EACH arg IN args:
        IF arg == "--json":
            json_mode = true
        ELSE IF arg == "--partial":
            partial_mode = true
        ELSE IF vmodel_dir IS NULL:
            vmodel_dir = arg

    IF vmodel_dir IS NULL:
        print_usage_and_exit(1)

    // Resolve file paths
    hazard_path = vmodel_dir / "hazard-analysis.md"
    system_design_path = vmodel_dir / "system-design.md"
    requirements_path = vmodel_dir / "requirements.md"

    IF NOT exists(hazard_path):
        error_exit("hazard-analysis.md not found in " + vmodel_dir)
    IF NOT exists(system_design_path):
        error_exit("system-design.md not found in " + vmodel_dir)

    RETURN CLIConfig(json_mode, partial_mode, vmodel_dir, hazard_path, system_design_path, requirements_path)
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Range | Constraints |
|------|------|-----------|-------------|
| json_mode | Boolean | true/false | Default false |
| partial_mode | Boolean | true/false | Default false |
| vmodel_dir | Path | OS max path | Required first positional arg |

#### Error Handling & Return Codes

| Error Condition | Handling | Maps to ARCH Contract |
|----------------|----------|----------------------|
| No vmodel_dir argument | Print usage, exit 1 | ARCH-006: CLI interface |
| hazard-analysis.md not found | Print error, exit 1 | ARCH-006: File resolution |

---

### Module: MOD-010 (Validation Orchestrator and Output Formatter)

**Parent Architecture Modules**: ARCH-006
**Target Source File(s)**: `scripts/bash/validate-hazard-coverage.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION main():
    config = parse_cli_args(ARGV)

    // Run forward coverage
    forward = check_forward_coverage(config.system_design_path, config.hazard_path)

    // Run backward coverage (skip in partial mode if requirements missing)
    backward = NULL
    IF NOT config.partial_mode OR exists(config.requirements_path):
        backward = check_backward_coverage(config.hazard_path, config.requirements_path, config.system_design_path)
    ELSE IF NOT config.partial_mode AND NOT exists(config.requirements_path):
        error_exit("requirements.md not found — use --partial for partial validation")

    // Run state consistency
    state = check_state_consistency(config.hazard_path, config.system_design_path)

    // Determine overall result
    has_gaps = (length(forward.uncovered) > 0)
                OR (backward IS NOT NULL AND length(backward.broken) > 0)
                OR (NOT state.consistent)

    // Format output
    IF config.json_mode:
        output_json(has_gaps, forward, backward, state)
    ELSE:
        output_human_readable(has_gaps, forward, backward, state)

    // Set exit code
    IF has_gaps:
        EXIT 1
    ELSE:
        EXIT 0

FUNCTION output_json(has_gaps, forward, backward, state):
    json = {
        "has_gaps": has_gaps,
        "forward_coverage": format("%d%%", forward.pct),
        "backward_coverage": format("%d%%", backward.pct) IF backward ELSE "N/A",
        "state_consistency": state.consistent,
        "forward_gaps": forward.uncovered,
        "backward_gaps": backward.broken IF backward ELSE [],
        "state_warnings": state.undefined_states
    }
    PRINT json_encode(json)
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Range | Constraints |
|------|------|-----------|-------------|
| has_gaps | Boolean | true/false | Aggregated from all validators |
| forward | ForwardResult | See MOD-006 | Always computed |
| backward | BackwardResult or NULL | See MOD-007 | NULL in partial mode without requirements |
| state | StateResult | See MOD-008 | Always computed |

#### Error Handling & Return Codes

| Error Condition | Handling | Maps to ARCH Contract |
|----------------|----------|----------------------|
| Any gap detected | Exit code 1 | ARCH-006: Exit codes |
| All checks pass | Exit code 0 | ARCH-006: Exit codes |
| requirements.md missing (non-partial) | Exit code 1 with error message | ARCH-006: --partial requirement |

---

### Module: MOD-011 (PowerShell Validation Engine)

**Parent Architecture Modules**: ARCH-007
**Target Source File(s)**: `scripts/powershell/Validate-HazardCoverage.ps1`

#### Algorithmic / Logic View

```pseudocode
// Mirrors the combined logic of MOD-006 through MOD-010 in PowerShell syntax.
// Key differences: uses -match operator for regex, [PSCustomObject] for results,
// ConvertTo-Json for JSON output, exit for process exit code.

FUNCTION Invoke-HazardCoverageValidation(VModelDir: String, Json: Switch, Partial: Switch):
    // Same algorithm as MOD-009 (parse args) + MOD-010 (orchestrate)
    // Calls internal functions mirroring MOD-006, MOD-007, MOD-008
    // Produces identical JSON schema and exit codes
    // See MOD-006 through MOD-010 for detailed pseudocode
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Range | Constraints |
|------|------|-----------|-------------|
| Same as MOD-006 through MOD-010 | PowerShell equivalents | Same ranges | Must produce identical output |

#### Error Handling & Return Codes

| Error Condition | Handling | Maps to ARCH Contract |
|----------------|----------|----------------------|
| Same as MOD-010 | Identical exit codes | ARCH-007: Cross-platform parity |

---

### Module: MOD-012 (HAZ Regex Parser)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `scripts/bash/build-matrix.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION extract_haz_entries(hazard_analysis_path: Path) -> Array:
    entries = []

    IF NOT exists(hazard_analysis_path):
        RETURN entries  // Empty — no Matrix H

    content = read_file(hazard_analysis_path)

    FOR EACH line IN content:
        // Match FMEA table rows: | HAZ-NNN | SYS-NNN | ... | REQ/SYS refs | ... |
        IF line MATCHES regex "^\|.*HAZ-[0-9]{3}.*\|":
            haz_id = extract_first_match(line, "HAZ-[0-9]{3}")
            mitigations = extract_all_matches(line, "(REQ-([A-Z]+-)?[0-9]{3}|SYS-[0-9]{3})")

            // Filter: only take refs from the Mitigation column (column 9 of 10)
            mitigation_refs = extract_column(line, column_index=9)
            refs = extract_all_matches(mitigation_refs, "(REQ-([A-Z]+-)?[0-9]{3}|SYS-[0-9]{3})")

            entries.append({haz_id: haz_id, mitigations: refs})

    RETURN entries
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Range | Constraints |
|------|------|-----------|-------------|
| entries | Array of {haz_id, mitigations[]} | 0–999 | Empty when no hazard file |
| haz_id | String | "HAZ-001" to "HAZ-999" | Matches `HAZ-[0-9]{3}` |
| mitigations | Array of String | 1–10 per entry | REQ-NNN or SYS-NNN patterns |

#### Error Handling & Return Codes

| Error Condition | Handling | Maps to ARCH Contract |
|----------------|----------|----------------------|
| hazard-analysis.md not found | Return empty array | ARCH-008: No HAZ entries = no Matrix H |
| Line matches HAZ but no mitigations | Include entry with empty mitigations array | ARCH-008: Parsing fallback |

---

### Module: MOD-013 (Verification Chain Resolver)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `scripts/bash/build-matrix.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION resolve_verification_chain(haz_entries: Array, vmodel_dir: Path) -> Array:
    // Load test artifacts for verification resolution
    acceptance_path = vmodel_dir / "acceptance-plan.md"
    system_test_path = vmodel_dir / "system-test.md"

    // Build REQ→ATP and SYS→STP lookup maps
    req_to_atp = {}
    IF exists(acceptance_path):
        FOR EACH atp IN extract_atps(acceptance_path):
            FOR EACH req IN atp.parent_reqs:
                req_to_atp[req] = append(req_to_atp.get(req, []), atp.id)

    sys_to_stp = {}
    IF exists(system_test_path):
        FOR EACH stp IN extract_stps(system_test_path):
            sys_to_stp[stp.parent_sys] = append(sys_to_stp.get(stp.parent_sys, []), stp.id)

    // Resolve each HAZ entry
    rows = []
    FOR EACH entry IN haz_entries:
        FOR EACH mitigation IN entry.mitigations:
            verification = "⚠️ No test coverage"
            IF mitigation STARTS_WITH "REQ" AND mitigation IN req_to_atp:
                verification = join(req_to_atp[mitigation], ", ")
            ELSE IF mitigation STARTS_WITH "SYS" AND mitigation IN sys_to_stp:
                verification = join(sys_to_stp[mitigation], ", ")
            rows.append({haz_id: entry.haz_id, mitigation: mitigation, verification: verification})

    RETURN rows
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Range | Constraints |
|------|------|-----------|-------------|
| req_to_atp | Map String→Array | 0–200 entries | REQ-NNN → [ATP-NNN-X, ...] |
| sys_to_stp | Map String→Array | 0–100 entries | SYS-NNN → [STP-NNN-X, ...] |
| rows | Array of {haz_id, mitigation, verification} | 0–999 | One row per HAZ×mitigation pair |

#### Error Handling & Return Codes

| Error Condition | Handling | Maps to ARCH Contract |
|----------------|----------|----------------------|
| No acceptance-plan.md | req_to_atp stays empty, all REQ mitigations get "⚠️ No test coverage" | ARCH-009: Gap annotation |
| No system-test.md | sys_to_stp stays empty, all SYS mitigations get "⚠️ No test coverage" | ARCH-009: Gap annotation |

---

### Module: MOD-014 (Matrix H Renderer)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `scripts/bash/build-matrix.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION render_matrix_h(resolved_rows: Array) -> String:
    IF resolved_rows IS EMPTY:
        RETURN ""  // No Matrix H output

    output = "## Matrix H — Hazard Traceability\n\n"
    output += "| HAZ ID | Mitigation | Verification |\n"
    output += "|--------|------------|-------------|\n"

    FOR EACH row IN resolved_rows:
        output += format("| %s | %s | %s |\n", row.haz_id, row.mitigation, row.verification)

    // Coverage summary
    total = length(resolved_rows)
    covered = count(resolved_rows WHERE verification != "⚠️ No test coverage")
    pct = (covered / total) * 100 IF total > 0 ELSE 0
    output += format("\n**Coverage**: %d / %d (%d%%)\n", covered, total, pct)

    RETURN output
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Range | Constraints |
|------|------|-----------|-------------|
| output | String | 0–50KB | Markdown table format |
| pct | Integer | 0–100 | Percentage of rows with test coverage |

#### Error Handling & Return Codes

| Error Condition | Handling | Maps to ARCH Contract |
|----------------|----------|----------------------|
| Empty resolved_rows | Return empty string | ARCH-009: No Matrix H when no data |

---

### Module: MOD-015 (PowerShell Matrix H Engine)

**Parent Architecture Modules**: ARCH-010
**Target Source File(s)**: `scripts/powershell/build-matrix.ps1`

#### Algorithmic / Logic View

```pseudocode
// Mirrors the combined logic of MOD-012 through MOD-014 in PowerShell.
// Uses -match for regex, [PSCustomObject] for row data,
// identical Markdown table output format.
// See MOD-012, MOD-013, MOD-014 for detailed pseudocode.
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Range | Constraints |
|------|------|-----------|-------------|
| Same as MOD-012 through MOD-014 | PowerShell equivalents | Same ranges | Must produce identical Markdown output |

#### Error Handling & Return Codes

| Error Condition | Handling | Maps to ARCH Contract |
|----------------|----------|----------------------|
| Same as MOD-014 | Identical output | ARCH-010: Cross-platform parity |

---

### Module: MOD-016 (Matrix H Section Injector)

**Parent Architecture Modules**: ARCH-011
**Target Source File(s)**: `commands/trace.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION inject_matrix_h(available_docs: Array, trace_output: String, vmodel_dir: Path) -> String:
    IF "hazard-analysis.md" NOT IN available_docs:
        RETURN trace_output  // No change — backward compatible

    // Call build-matrix to generate Matrix H
    matrix_h_data = execute("build-matrix.sh --matrix-h " + vmodel_dir)

    IF matrix_h_data IS EMPTY:
        RETURN trace_output  // Hazard file exists but no valid HAZ entries

    // Append Matrix H after existing matrices (A, B, C, D)
    RETURN trace_output + "\n---\n\n" + matrix_h_data
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Range | Constraints |
|------|------|-----------|-------------|
| available_docs | Array of String | 1–10 | From setup script JSON |
| matrix_h_data | String | 0–50KB | Markdown from build-matrix |

#### Error Handling & Return Codes

| Error Condition | Handling | Maps to ARCH Contract |
|----------------|----------|----------------------|
| hazard-analysis.md absent | Skip Matrix H silently | ARCH-011: Backward compatibility |
| build-matrix fails | Skip Matrix H, no error | ARCH-011: Graceful degradation |

---

### Module: MOD-017 (HAZ Prefix Registration)

**Parent Architecture Modules**: ARCH-012
**Target Source File(s)**: `evals/validators/id_validator.py`

#### Algorithmic / Logic View

```pseudocode
// Add HAZ to the VALID_PREFIXES dictionary in id_validator.py
VALID_PREFIXES = {
    // ... existing prefixes ...
    "REQ": r"REQ-([A-Z]+-)?[0-9]{3}",
    "SYS": r"SYS-[0-9]{3}",
    // ... other existing prefixes ...
    "HAZ": r"HAZ-[0-9]{3}",  // NEW: Hazard Analysis ID
}

FUNCTION validate_id(id_string: String) -> Boolean:
    FOR EACH prefix, pattern IN VALID_PREFIXES:
        IF id_string MATCHES pattern:
            RETURN True
    RETURN False
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Range | Constraints |
|------|------|-----------|-------------|
| VALID_PREFIXES | Dict String→Regex | 13 entries (12 existing + HAZ) | HAZ-[0-9]{3} pattern |

#### Error Handling & Return Codes

| Error Condition | Handling | Maps to ARCH Contract |
|----------------|----------|----------------------|
| Unrecognized ID prefix | Return False | ARCH-012: Validation result |

---

### Module: MOD-018 (Manifest Configuration)

**Parent Architecture Modules**: ARCH-013
**Target Source File(s)**: `extension.yml`

#### Algorithmic / Logic View

```pseudocode
// YAML configuration entries to add to extension.yml

// 1. Command registration
commands:
    speckit.v-model.hazard-analysis:
        description: "Generate FMEA-based hazard analysis with operational states, traceable mitigations, and domain overlay support"
        file: "commands/hazard-analysis.md"

// 2. ID prefix registration
defaults:
    id_prefixes:
        hazards: "HAZ"  // NEW

// 3. Trace command description update
commands:
    speckit.v-model.trace:
        description: "... Matrices A–D + Matrix H (Hazard Traceability) ..."  // Updated
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Range | Constraints |
|------|------|-----------|-------------|
| command entry | YAML map | 3 fields | name, description, file |
| id_prefix entry | YAML map | 1 field | hazards: "HAZ" |

#### Error Handling & Return Codes

| Error Condition | Handling | Maps to ARCH Contract |
|----------------|----------|----------------------|
| Malformed YAML | spec-kit loader rejects extension | ARCH-013: Valid YAML required |

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Module Designs (MOD) | 18 |
| Total Parent Architecture Modules Covered | 13 / 13 (100%) |
| Modules per Type | Standard: 16 \| [EXTERNAL]: 0 \| [CROSS-CUTTING]: 0 |
| Modules with Pseudocode | 18 / 18 (100%) |
| **Forward Coverage (ARCH→MOD)** | **100%** |

## Derived Modules

None — all modules trace to existing architecture components.
