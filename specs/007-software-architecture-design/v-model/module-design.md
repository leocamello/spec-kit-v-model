# Module Design: Software Architecture Design (Path B)

**Feature Branch**: `007-software-architecture-design`
**Created**: 2026-05-04
**Status**: Draft
**Source**: `specs/007-software-architecture-design/v-model/software-architecture-design.md`

## Overview

This module design decomposes 16 architecture elements (ARCH-001 through ARCH-016) into 13 low-level module specifications (MOD-001 through MOD-013). Each MOD represents a single function or tightly coupled file group detailed enough that coding is a direct translation exercise — no further design decisions are required.

Three ARCH elements (ARCH-008 Data Flow View Generator, ARCH-014 Setup Script Adapter, ARCH-016 Template) are structural/infrastructure concerns whose logic is embedded in the command pipeline and template file rather than discrete functions — they are not decomposed into separate MODs.

## ID Schema

- **Module Design**: `MOD-NNN` — sequential identifier for each module (3-digit zero-padded)
- **Parent Architecture Modules**: Comma-separated `ARCH-NNN` list per module (many-to-many, authoritative for traceability)
- **Target Source File(s)**: Comma-separated file paths mapping to the repository codebase
- Example: `MOD-004` with Parent Architecture Modules `ARCH-004` — decomposes requirements into ARCH elements

## Module Designs

### Module: MOD-001 (Parse Requirements Table)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `commands/software-architecture-design.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION parse_requirements(requirements_content: String, req_pattern: Regex) -> Array<Requirement>:
    reqs = []
    lines = requirements_content.split("\n")
    in_req_section = false

    FOR EACH line IN lines:
        IF line matches /^###\s+Functional Requirements/ OR line matches /^###\s+Non-Functional Requirements/:
            in_req_section = true
            CONTINUE
        IF in_req_section AND line matches /^##\s+/:
            BREAK
        IF in_req_section AND line matches table_row_pattern:
            cells = split_table_row(line)
            IF cells.length < 5:
                CONTINUE
            id_match = req_pattern.match(cells[0].trim())
            IF id_match IS NULL:
                CONTINUE
            req = {
                id: id_match.group(0),
                description: cells[1].trim(),
                priority: cells[2].trim(),
                rationale: cells[3].trim(),
                verification: cells[4].trim()
            }
            IF req.id IS empty:
                CONTINUE
            reqs.append(req)

    IF reqs.length == 0:
        RAISE EMPTY_INPUT("No REQ-NNN identifiers found in requirements.md")
    RETURN reqs
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| reqs | Array<Requirement> | 0..200 elements | Empty array | Accumulated requirement objects |
| in_req_section | Boolean | — | false | Section scope tracker |
| lines | Array<String> | Bounded by input file size | Split from input | Line-by-line input |
| cells | Array<String> | 3..10 per row | Split per row | Table cell values |
| req | Requirement | {id, description, priority, rationale, verification} | Per-row construction | Single parsed requirement |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Input contains zero REQ-NNN identifiers | EMPTY_INPUT | ARCH-001: "No REQ-NNN identifiers found in requirements.md" | Halt generation with error message |
| Malformed table row (< 5 columns) | — | — | Skip row silently, continue parsing |
| Empty id in row | — | — | Skip row silently, continue parsing |
| File not found on disk | FILE_NOT_FOUND | ARCH-001: "Requirements file not found at [path]" | Halt with error message |

---

### Module: MOD-002 (Load Domain from Config)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `commands/software-architecture-design.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION load_domain_config(repo_root: String) -> String | NULL:
    config_path = repo_root + "/v-model-config.yml"
    IF NOT file_exists(config_path):
        RETURN NULL
    config_yaml = read_file(config_path)
    config = parse_yaml(config_yaml)
    domain = config.domain OR NULL
    IF domain IS NULL OR domain.trim() == "":
        RETURN NULL
    RETURN domain
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| config_path | String | — | Constructed | Path to v-model-config.yml |
| config | Dict | — | Parsed from YAML | Configuration dictionary |
| domain | String \| NULL | "iso_26262" \| "do_178c" \| "iec_62304" \| NULL | Extracted domain value |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Recovery |
|----------------|----------------------|----------|
| Config file missing | — | Return NULL |
| Invalid YAML syntax | — | Return NULL |
| Domain field absent or empty | — | Return NULL |

---

### Module: MOD-003 (Load Domain Overlay)

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `commands/software-architecture-design.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION load_overlay(domain: String | NULL, repo_root: String) -> String | NULL:
    IF domain IS NULL:
        RETURN NULL
    overlay_path = repo_root + "/commands/overlays/" + domain + "/software-architecture-design.md"
    IF NOT file_exists(overlay_path):
        LOG WARNING("Overlay not found for domain: " + domain)
        RETURN NULL
    RETURN read_file(overlay_path)
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Description |
|------|------|-------------|
| overlay_path | String | Resolved path to overlay file |
| overlay_content | String \| NULL | Loaded overlay content or NULL |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Recovery |
|----------------|----------------------|----------|
| Overlay file missing | WARNING logged | Return NULL; pipeline continues |
| Domain is NULL | — | Return NULL (no-op) |

---

### Module: MOD-004 (Decompose Requirements to ARCH)

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `commands/software-architecture-design.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION decompose_to_arch(reqs: Array<Requirement>, arch_pattern: Regex,
                           existing_arch: Array<ArchElement> | NULL) -> Array<ArchElement>:
    arch_elements = []
    next_id = IF existing_arch NOT NULL THEN max(existing_arch.map(e => e.id_num)) + 1 ELSE 1

    FOR EACH req IN reqs:
        elements = identify_architecture_elements(req)
        FOR EACH element IN elements:
            arch = {
                id: format("ARCH-%03d", next_id),
                id_num: next_id,
                name: element.name,
                description: element.description,
                parentReqs: element.parent_req_ids,
                type: classify_type(element),
                tags: []
            }
            IF element.is_cross_cutting:
                arch.tags.append("[CROSS-CUTTING] — " + element.rationale)
            IF element.is_derived:
                arch.tags.append("[DERIVED MODULE: " + element.reason + "]")
            arch_elements.append(arch)
            next_id += 1

    RETURN arch_elements
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Description |
|------|------|-----------------|-------------|
| arch_elements | Array<ArchElement> | 1..100 elements | Output architecture elements |
| next_id | Integer | ≥ 1 | Next sequential ARCH-NNN number |
| elements | Array<ArchIdea> | Per-requirement ideas | Candidate architecture elements from requirement analysis |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Recovery |
|----------------|----------------------|----------|
| No architecture elements identified | — | Return empty array (upstream should have caught this) |
| Element without parent REQ | WARNING | Flag as [DERIVED MODULE]; still include in output |

---

### Module: MOD-005 (Generate Logical View Table)

**Parent Architecture Modules**: ARCH-005
**Target Source File(s)**: `commands/software-architecture-design.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION generate_logical_view(arch_elements: Array<ArchElement>) -> String:
    header = "| ARCH ID | Name | Description | Parent Requirements | Type |\n"
    header += "|---------|------|-------------|---------------------|------|\n"
    rows = ""

    FOR EACH arch IN arch_elements:
        IF "[CROSS-CUTTING]" IN arch.tags:
            parent_str = extract_cross_cutting_rationale(arch.tags)
        ELSE:
            parent_str = join(arch.parentReqs, ", ")
        row = format("| %s | %s | %s | %s | %s |\n",
                     arch.id, arch.name, arch.description, parent_str, arch.type)
        rows += row

    RETURN header + rows
```

#### State Machine View

N/A — Stateless pure function

---

### Module: MOD-006 (Generate Mermaid Sequence Diagram)

**Parent Architecture Modules**: ARCH-006
**Target Source File(s)**: `commands/software-architecture-design.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION generate_process_view(arch_elements: Array<ArchElement>,
                               interactions: Array<Interaction>) -> String:
    diagram = "```mermaid\nsequenceDiagram\n"

    FOR EACH participant IN extract_participants(interactions):
        diagram += format("    participant %s as %s\n", participant.id, participant.label)

    FOR EACH interaction IN interactions:
        IF interaction.type == "sync":
            diagram += format("    %s->>%s: %s\n", interaction.from, interaction.to, interaction.message)
            IF interaction.response NOT NULL:
                diagram += format("    %s-->>%s: %s\n", interaction.to, interaction.from, interaction.response)
        ELSE IF interaction.type == "note":
            diagram += format("    Note over %s: %s\n", interaction.scope, interaction.message)
        ELSE IF interaction.type == "alt":
            diagram += format("    alt %s\n", interaction.condition)
            FOR EACH branch IN interaction.branches:
                diagram += format("        %s->>%s: %s\n", branch.from, branch.to, branch.message)
            diagram += "    end\n"

    diagram += "```\n"
    RETURN diagram
```

#### State Machine View

N/A — Stateless pure function

---

### Module: MOD-007 (Validate Interface Contracts)

**Parent Architecture Modules**: ARCH-007
**Target Source File(s)**: `commands/software-architecture-design.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION validate_interface_contracts(arch_elements: Array<ArchElement>) -> Array<Warning>:
    warnings = []
    FOR EACH arch IN arch_elements:
        IF arch.interface IS NULL:
            warnings.append(WARNING("ARCH-" + arch.id + ": black-box — no interface contract"))
            CONTINUE
        IF arch.interface.input IS NULL AND arch.interface.output IS NULL:
            warnings.append(WARNING("ARCH-" + arch.id + ": incomplete contract — missing input/output"))
            CONTINUE
        IF arch.interface.error_handling IS NULL:
            warnings.append(WARNING("ARCH-" + arch.id + ": incomplete contract — missing error handling"))
    RETURN warnings
```

---

### Module: MOD-008 (Generate SWE.2 Sections)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `commands/software-architecture-design.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION generate_swe2_sections(domain: String | NULL, arch_elements: Array<ArchElement>,
                                reqs: Array<Requirement>, overlay_content: String | NULL) -> String | NULL:
    IF domain != "iso_26262":
        RETURN NULL

    sections = "## ASPICE SWE.2 Process Guidance\n\n"
    sections += "> **Note**: This section is included because `v-model-config.yml` specifies `domain: iso_26262`.\n\n"
    sections += "### SWE.2.BP1 — Develop Software Architectural Design\n"
    sections += generate_bp1_overview(arch_elements) + "\n\n"
    sections += "### SWE.2.BP2 — Allocate Software Requirements\n"
    sections += generate_bp2_allocation_table(reqs, arch_elements) + "\n\n"
    sections += "### SWE.2.BP3 — Define Interfaces of Software Elements\n"
    sections += generate_bp3_interface_summary(arch_elements) + "\n\n"
    sections += "### SWE.2.BP4 — Describe Dynamic Behavior\n"
    sections += generate_bp4_behavior_summary(arch_elements) + "\n\n"
    sections += "### SWE.2.BP5 — Define Resource Consumption Objectives\n"
    sections += generate_bp5_resource_table() + "\n\n"
    sections += "### SWE.2.BP6 — Evaluate Alternative Software Architectures\n"
    sections += generate_bp6_alternatives() + "\n\n"
    sections += "### SWE.2.BP7 — Establish Bidirectional Traceability\n"
    sections += generate_bp7_traceability(reqs, arch_elements) + "\n\n"
    sections += "### SWE.2.BP8 — Ensure Consistency\n"
    sections += generate_bp8_consistency() + "\n\n"
    sections += "### SWE.2.BP9 — Communicate Agreed Software Architectural Design\n"
    sections += generate_bp9_communication() + "\n\n"
    RETURN sections
```

#### State Machine View

N/A — Stateless; domain-gated skip when domain != "iso_26262"

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Recovery |
|----------------|----------------------|----------|
| domain != "iso_26262" | — | Return NULL (skip entire section) |
| arch_elements empty | — | Return NULL with warning logged |

---

### Module: MOD-009 (Compute Traceability Coverage)

**Parent Architecture Modules**: ARCH-010
**Target Source File(s)**: `commands/software-architecture-design.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION compute_coverage(reqs: Array<Requirement>, arch_elements: Array<ArchElement>) -> CoverageReport:
    total_reqs = reqs.length
    covered_reqs = new Set()

    FOR EACH arch IN arch_elements:
        FOR EACH parent_req IN arch.parentReqs:
            covered_reqs.add(parent_req)

    uncovered = reqs.filter(r => NOT covered_reqs.has(r.id))
    coverage_pct = total_reqs > 0 ? (covered_reqs.size / total_reqs) * 100 : 0

    RETURN {
        total_requirements: total_reqs,
        total_arch_elements: arch_elements.length,
        covered_requirements: covered_reqs.size,
        uncovered_requirements: uncovered.length,
        coverage_percentage: round(coverage_pct, 2),
        uncovered: uncovered.map(r => r.id)
    }
```

#### State Machine View

N/A — Stateless pure function

---

### Module: MOD-010 (Detect Path A Coexistence)

**Parent Architecture Modules**: ARCH-011
**Target Source File(s)**: `commands/software-architecture-design.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION detect_coexistence(vmodel_dir: String) -> String | NULL:
    path_a_artifact = vmodel_dir + "/architecture-design.md"
    IF file_exists(path_a_artifact):
        RETURN "WARNING: architecture-design.md (Path A artifact) found — both artifacts will coexist. " +
               "integration-test prefers software-architecture-design.md when both exist."
    RETURN NULL
```

#### State Machine View

N/A — Stateless pure function

#### Error Handling & Return Codes

| Error Condition | Recovery |
|----------------|----------|
| Path A artifact not found | Return NULL — no warning needed |
| vmodel_dir inaccessible | Log error; return NULL (non-blocking) |

---

### Module: MOD-011 (Apply Lifecycle Rules)

**Parent Architecture Modules**: ARCH-012
**Target Source File(s)**: `commands/software-architecture-design.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION apply_lifecycle(new_elements: Array<ArchElement>,
                         existing_elements: Array<ArchElement> | NULL) -> Array<ArchElement>:
    IF existing_elements IS NULL OR existing_elements.length == 0:
        RETURN new_elements

    result = []
    existing_ids = new Set(existing_elements.map(e => e.id))
    new_ids = new Set(new_elements.map(e => e.id))

    FOR EACH existing IN existing_elements:
        IF new_ids.has(existing.id):
            result.append(existing)
        ELSE:
            existing.tags.append("[DEPRECATED — Withdrawn: removed in regeneration]")
            result.append(existing)

    FOR EACH new_elem IN new_elements:
        IF NOT existing_ids.has(new_elem.id):
            result.append(new_elem)

    RETURN result
```

#### State Machine View

N/A — Stateless pure function

#### Error Handling & Return Codes

| Error Condition | Recovery |
|----------------|----------|
| existing_elements is NULL or empty | Return new_elements unchanged |
| ID collision (existing and new share same ID) | Preserve existing; do not overwrite |

---

### Module: MOD-012 (Assemble and Write Output)

**Parent Architecture Modules**: ARCH-013
**Target Source File(s)**: `commands/software-architecture-design.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION assemble_output(vmodel_dir: String, sections: SectionMap,
                         swe2_sections: String | NULL, template: String,
                         feature_branch: String) -> Boolean:

    output = template
    output = replace_placeholder(output, "{{FEATURE_NAME}}", feature_branch)
    output = replace_placeholder(output, "{{DATE}}", today())
    output = replace_placeholder(output, "{{LOGICAL_VIEW}}", sections.logical)
    output = replace_placeholder(output, "{{PROCESS_VIEW}}", sections.process)
    output = replace_placeholder(output, "{{INTERFACE_VIEW}}", sections.interface)
    output = replace_placeholder(output, "{{DATA_FLOW_VIEW}}", sections.dataflow)
    output = replace_placeholder(output, "{{SWE2_SECTIONS}}",
                                 swe2_sections OR "SWE.2 sections omitted — not an ISO 26262 project")
    output = replace_placeholder(output, "{{TRACEABILITY}}", sections.traceability)

    output_path = vmodel_dir + "/software-architecture-design.md"
    RETURN write_file(output_path, output)
```

#### State Machine View

N/A — Stateless; single write operation

---

### Module: MOD-013 (Regex ID Pattern Library)

**Parent Architecture Modules**: ARCH-015 [CROSS-CUTTING]
**Target Source File(s)**: `scripts/bash/validate-software-architecture-coverage.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION get_id_patterns() -> IdPatterns:
    RETURN {
        REQ: compile_regex("REQ-[A-Z]{0,5}-[0-9]{3}"),
        ARCH: compile_regex("ARCH-[0-9]{3}"),
        ITP: compile_regex("ITP-[0-9]{3}-[A-Z]"),
        ITS: compile_regex("ITS-[0-9]{3}-[A-Z][0-9]+")
    }
```

#### State Machine View

N/A — Stateless utility; compiled regex objects are immutable

---

## Module Summary

| MOD ID | Module Name | Parent ARCH | Target Source File |
|--------|------------|-------------|-------------------|
| MOD-001 | Parse Requirements Table | ARCH-001 | `commands/software-architecture-design.md` |
| MOD-002 | Load Domain from Config | ARCH-002 | `commands/software-architecture-design.md` |
| MOD-003 | Load Domain Overlay | ARCH-003 | `commands/software-architecture-design.md` |
| MOD-004 | Decompose Requirements to ARCH | ARCH-004 | `commands/software-architecture-design.md` |
| MOD-005 | Generate Logical View Table | ARCH-005 | `commands/software-architecture-design.md` |
| MOD-006 | Generate Mermaid Sequence Diagram | ARCH-006 | `commands/software-architecture-design.md` |
| MOD-007 | Validate Interface Contracts | ARCH-007 | `commands/software-architecture-design.md` |
| MOD-008 | Generate SWE.2 Sections | ARCH-009 | `commands/software-architecture-design.md` |
| MOD-009 | Compute Traceability Coverage | ARCH-010 | `commands/software-architecture-design.md` |
| MOD-010 | Detect Path A Coexistence | ARCH-011 | `commands/software-architecture-design.md` |
| MOD-011 | Apply Lifecycle Rules | ARCH-012 | `commands/software-architecture-design.md` |
| MOD-012 | Assemble and Write Output | ARCH-013 | `commands/software-architecture-design.md` |
| MOD-013 | Regex ID Pattern Library | ARCH-015 [CROSS-CUTTING] | `scripts/bash/validate-software-architecture-coverage.sh` |

> **Note**: ARCH-008 (Data Flow View Generator), ARCH-014 (Setup Script Adapter), and ARCH-016 (Template) are structural/infrastructure elements implemented as template adaptations or script logic — not decomposed into discrete MODs. Coverage: 13 MODs covering 13 of 16 ARCH elements.
