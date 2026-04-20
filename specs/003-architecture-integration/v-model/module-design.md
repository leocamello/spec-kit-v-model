# Module Design: Architecture Design ↔ Integration Testing

**Feature Branch**: `003-architecture-integration`
**Created**: 2025-07-17
**Status**: Draft
**Source**: `specs/003-architecture-integration/v-model/architecture-design.md`

## Overview

This module design decomposes 28 architecture modules (ARCH-001 through ARCH-028) from the v0.3.0 architecture design into 44 low-level module specifications (MOD-001 through MOD-044). Each MOD represents a single function, class, script routine, or tightly coupled file group detailed enough that source code implementation is a direct translation exercise — no further design decisions are required.

The decomposition follows these granularity rules: Components are split into one MOD per major function (e.g., ARCH-001's three parsing responsibilities → MOD-001, MOD-002, MOD-003); Libraries receive one MOD per public API surface (e.g., ARCH-028's single get_id_pattern function → MOD-044); Utilities are typically 1:1 with ARCH (e.g., ARCH-018 → MOD-030). All modules are stateless single-invocation functions. No domain overlay is configured — safety-critical sections are omitted.

## ID Schema

- **Module Design**: `MOD-NNN` — sequential identifier for each module (3-digit zero-padded)
- **Parent Architecture Modules**: Comma-separated `ARCH-NNN` list per module (many-to-many, authoritative for traceability)
- **Target Source File(s)**: Comma-separated file paths mapping to the repository codebase
- Example: `MOD-012` with Parent Architecture Modules `ARCH-007` — module parses architecture logical view for integration test generation
- Example: `MOD-044 [CROSS-CUTTING]` — shared ID regex pattern library used by validation and matrix scripts

## Module Designs

### Module: MOD-001 (Parse Decomposition View)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `commands/architecture-design.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION parse_decomposition_view(system_design_content: String, sys_pattern: Regex) -> Array<SysComponent>:
    components = []
    lines = system_design_content.split("\n")
    in_decomposition_section = false

    FOR EACH line IN lines:
        IF line matches /^##\s+.*Decomposition/:
            in_decomposition_section = true
            CONTINUE
        IF in_decomposition_section AND line matches /^##\s+/:
            BREAK

        IF in_decomposition_section AND line matches table_row_pattern:
            cells = split_table_row(line)
            IF cells.length < 5:
                CONTINUE

            id_match = sys_pattern.match(cells[0].trim())
            IF id_match IS NULL:
                CONTINUE

            component = {
                id:          id_match.group(0),
                name:        cells[1].trim(),
                description: cells[2].trim(),
                parent_reqs: extract_all_matches(cells[3], /REQ-[A-Z0-9-]+/),
                type:        cells[4].trim()
            }

            IF component.id IS empty OR component.name IS empty:
                CONTINUE

            components.append(component)

    IF components.length == 0:
        RAISE EMPTY_INPUT("No system components found in system-design.md")

    RETURN components
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| components | Array<SysComponent> | 0..200 elements | Empty array | Accumulated SYS component objects |
| in_decomposition_section | Boolean | — | false | Section scope tracker |
| lines | Array<String> | Bounded by input file size | Split from input | Line-by-line input |
| cells | Array<String> | 3..10 per row | Split per row | Table cell values |
| component | SysComponent | {id, name, description, parent_reqs, type} | Per-row construction | Single parsed component |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Input contains zero SYS identifiers | EMPTY_INPUT | ARCH-001: "No system components found in system-design.md" | Halt generation with error message |
| Malformed table row (< 5 columns) | — | — | Skip row silently, continue parsing |
| Empty id or name in row | — | — | Skip row silently, continue parsing |

---

### Module: MOD-002 (Parse Dependency View)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `commands/architecture-design.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION parse_dependency_view(system_design_content: String, sys_pattern: Regex) -> Array<Dependency>:
    dependencies = []
    lines = system_design_content.split("\n")
    in_dependency_section = false

    FOR EACH line IN lines:
        IF line matches /^##\s+.*Dependency/:
            in_dependency_section = true
            CONTINUE
        IF in_dependency_section AND line matches /^##\s+/:
            BREAK

        IF in_dependency_section AND line matches table_row_pattern:
            cells = split_table_row(line)
            IF cells.length < 4:
                CONTINUE

            source_ids = sys_pattern.find_all(cells[0])
            target_ids = sys_pattern.find_all(cells[1])

            IF source_ids.length == 0 OR target_ids.length == 0:
                CONTINUE

            FOR EACH source IN source_ids:
                FOR EACH target IN target_ids:
                    dep = {
                        source:         source,
                        target:         target,
                        relationship:   cells[2].trim(),
                        failure_impact: cells[3].trim()
                    }
                    dependencies.append(dep)

    RETURN dependencies
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| dependencies | Array<Dependency> | 0..500 elements | Empty array | Parsed dependency relationships |
| in_dependency_section | Boolean | — | false | Section scope tracker |
| source_ids | Array<String> | 1..10 | Extracted per row | Source SYS identifiers |
| target_ids | Array<String> | 1..10 | Extracted per row | Target SYS identifiers |
| dep | Dependency | {source, target, relationship, failure_impact} | Per-pair construction | Single dependency object |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| No Dependency View section found | — | ARCH-001: dependencies may be empty | Return empty array |
| Row with missing source or target IDs | — | — | Skip row, continue parsing |

---

### Module: MOD-003 (Parse Interface View)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `commands/architecture-design.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION parse_interface_view(system_design_content: String, sys_pattern: Regex) -> Array<InterfaceSpec>:
    interfaces = []
    lines = system_design_content.split("\n")
    in_interface_section = false
    current_component = NULL

    FOR EACH line IN lines:
        IF line matches /^##\s+.*Interface/:
            in_interface_section = true
            CONTINUE
        IF in_interface_section AND line matches /^##\s+/ AND NOT line matches /Interface/:
            BREAK

        IF in_interface_section AND line matches /^###\s+(.+)/:
            subsection_title = match.group(1)
            component_ids = sys_pattern.find_all(subsection_title)
            IF component_ids.length > 0:
                current_component = component_ids[0]
            CONTINUE

        IF in_interface_section AND current_component IS NOT NULL AND line matches table_row_pattern:
            cells = split_table_row(line)
            IF cells.length < 6:
                CONTINUE

            iface = {
                component:     current_component,
                interface_name: cells[0].trim(),
                protocol:      cells[1].trim(),
                input:         cells[2].trim(),
                output:        cells[3].trim(),
                error_handling: cells[4].trim()
            }
            interfaces.append(iface)

    RETURN interfaces
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| interfaces | Array<InterfaceSpec> | 0..200 elements | Empty array | Parsed interface specifications |
| in_interface_section | Boolean | — | false | Section scope tracker |
| current_component | String or NULL | SYS-NNN format | NULL | Currently scoped SYS component |
| iface | InterfaceSpec | {component, interface_name, protocol, input, output, error_handling} | Per-row | Single interface object |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| No Interface View section found | — | ARCH-001: interfaces may be empty | Return empty array |
| Subsection with no SYS identifier | — | — | Set current_component to NULL, skip rows |

---

### Module: MOD-004 (Decompose SYS to ARCH)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `commands/architecture-design.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION decompose_sys_to_arch(
    sys_components: Array<SysComponent>,
    dependencies: Array<Dependency>,
    interfaces: Array<InterfaceSpec>
) -> DecompositionResult:

    IF sys_components.length == 0:
        RAISE TRANSLATOR_VIOLATION("No SYS components provided — cannot decompose")

    arch_modules = []
    cross_cutting_candidates = []

    FOR EACH sys IN sys_components:
        responsibility_groups = analyze_responsibilities(sys, dependencies, interfaces)

        FOR EACH group IN responsibility_groups:
            module = {
                name:        group.name,
                description: group.description,
                parent_sys:  [sys.id],
                type:        classify_type(group),
                tags:        []
            }

            IF group.spans_multiple_sys:
                FOR EACH other_sys IN group.additional_sys:
                    IF other_sys NOT IN module.parent_sys:
                        module.parent_sys.append(other_sys)

            arch_modules.append(module)

    FOR EACH candidate IN identify_shared_concerns(dependencies, interfaces):
        IF candidate.traceable_to_sys:
            existing = find_module_by_concern(arch_modules, candidate)
            IF existing IS NOT NULL:
                merge_concern(existing, candidate)
            ELSE:
                cross_cutting_candidates.append(candidate)
        ELSE:
            cross_cutting_candidates.append(candidate)

    RETURN {
        arch_modules:           arch_modules,
        cross_cutting_candidates: cross_cutting_candidates
    }
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| arch_modules | Array<ArchModule> | 0..100 elements | Empty array | Accumulated architecture modules |
| cross_cutting_candidates | Array<ArchModule> | 0..20 elements | Empty array | Modules not traceable to single SYS |
| responsibility_groups | Array<ResponsibilityGroup> | 1..10 per SYS | Analyzed per SYS | Grouped responsibilities for decomposition |
| module | ArchModule | {name, description, parent_sys[], type, tags[]} | Per-group | Single module definition |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Empty SYS component list | TRANSLATOR_VIOLATION | ARCH-002: "At least one component required" | Halt with error |
| Module not traceable to SYS and not cross-cutting | DERIVED_MODULE_HALT | ARCH-002: Flag as [DERIVED MODULE] | Add to derived list, do not assign ID |

---

### Module: MOD-005 (Assign ARCH Identifiers)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `commands/architecture-design.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION assign_arch_identifiers(
    arch_modules: Array<ArchModule>,
    cross_cutting_modules: Array<ArchModule>,
    existing_highest_id: Integer
) -> Array<ArchModule>:

    next_id = existing_highest_id + 1
    all_modules = []

    FOR EACH module IN arch_modules:
        module.id = format("ARCH-%03d", next_id)
        next_id = next_id + 1
        all_modules.append(module)

    FOR EACH module IN cross_cutting_modules:
        IF module.is_derived:
            module.id = NULL
            module.tags.append("[DERIVED MODULE: " + module.description + "]")
        ELSE:
            module.id = format("ARCH-%03d", next_id)
            module.tags.append("[CROSS-CUTTING]")
            next_id = next_id + 1
        all_modules.append(module)

    RETURN all_modules
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| next_id | Integer | 1..999 | existing_highest_id + 1 | Sequential ID counter |
| all_modules | Array<ArchModule> | 0..120 elements | Empty array | Merged module list with assigned IDs |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| next_id exceeds 999 | TRANSLATOR_VIOLATION | ARCH-002: ID overflow | Halt with error — feature too large for 3-digit IDs |
| Derived module detected | DERIVED_MODULE_HALT | ARCH-002: Flag, do not assign ID | Set id = NULL, append DERIVED tag |

---

### Module: MOD-006 (Classify and Tag Modules)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `commands/architecture-design.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION classify_and_tag_modules(
    modules: Array<ArchModule>,
    sys_components: Array<SysComponent>
) -> Array<ArchModule>:

    sys_type_map = {}
    FOR EACH sys IN sys_components:
        sys_type_map[sys.id] = sys.type

    FOR EACH module IN modules:
        IF module.tags contains "[CROSS-CUTTING]":
            module.type = infer_cross_cutting_type(module)
            CONTINUE

        IF module.parent_sys.length == 0:
            module.tags.append("[DERIVED MODULE: " + module.name + "]")
            CONTINUE

        parent_types = []
        FOR EACH sys_id IN module.parent_sys:
            IF sys_id IN sys_type_map:
                parent_types.append(sys_type_map[sys_id])

        IF module.type IS NULL OR module.type IS empty:
            module.type = derive_type_from_responsibilities(module, parent_types)

    derived_list = []
    FOR EACH module IN modules:
        IF module.tags contains_prefix "[DERIVED MODULE":
            derived_list.append(module)

    RETURN modules, derived_list

FUNCTION derive_type_from_responsibilities(module: ArchModule, parent_types: Array<String>) -> String:
    IF module.description contains "script" OR module.description contains "CLI":
        RETURN "Utility"
    IF module.description contains "template" OR module.description contains "library":
        RETURN "Library"
    IF module.description contains "endpoint" OR module.description contains "handler":
        RETURN "Service"
    RETURN "Component"
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| sys_type_map | Dict<String, String> | 0..50 entries | Built from sys_components | Maps SYS-NNN to its type |
| parent_types | Array<String> | 0..10 elements | Per-module | Types of parent SYS components |
| derived_list | Array<ArchModule> | 0..20 elements | Filtered from modules | Modules flagged as derived |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Module with empty parent_sys and no CROSS-CUTTING tag | DERIVED_MODULE_HALT | ARCH-002: Flag as derived | Append DERIVED MODULE tag |
| Unknown parent SYS ID in sys_type_map | — | — | Skip type inference for that parent, continue |

---

### Module: MOD-007 (Generate Logical View Table)

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `commands/architecture-design.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION generate_logical_view_table(
    arch_modules: Array<ArchModule>,
    template_structure: String
) -> String:

    header = "| ARCH ID | Name | Description | Parent System Components | Type |\n"
    separator = "|---------|------|-------------|--------------------------|------|\n"
    rows = []

    sys_coverage = {}

    FOR EACH module IN arch_modules:
        IF module.tags contains "[CROSS-CUTTING]":
            parent_cell = module.tags.get_cross_cutting_rationale()
        ELSE:
            parent_cell = join(module.parent_sys, ", ")
            FOR EACH sys_id IN module.parent_sys:
                sys_coverage[sys_id] = true

        row = format("| %s | %s | %s | %s | %s |",
            module.id,
            module.name,
            module.description,
            parent_cell,
            module.type
        )
        rows.append(row)

    table = header + separator + join(rows, "\n")

    all_sys_ids = collect_all_sys_from_modules(arch_modules)
    uncovered = []
    FOR EACH sys_id IN all_sys_ids:
        IF sys_id NOT IN sys_coverage:
            uncovered.append(sys_id)

    IF uncovered.length > 0:
        RAISE INCOMPLETE_COVERAGE("Uncovered SYS: " + join(uncovered, ", "))

    RETURN table
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| rows | Array<String> | 1..100 elements | Empty array | Formatted Markdown table rows |
| sys_coverage | Dict<String, Boolean> | 0..50 entries | Empty dict | Tracks which SYS IDs appear as parents |
| uncovered | Array<String> | 0..50 elements | Filtered | SYS IDs not covered by any ARCH |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| SYS-NNN has no ARCH parent | INCOMPLETE_COVERAGE | ARCH-003: Error with uncovered SYS IDs | Raise error listing specific uncovered IDs |

---

### Module: MOD-008 (Generate Sequence Diagrams)

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `commands/architecture-design.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION generate_sequence_diagrams(
    arch_modules: Array<ArchModule>,
    dependencies: Array<Dependency>,
    template_structure: String
) -> Array<MermaidBlock>:

    interaction_paths = group_dependencies_into_paths(dependencies, arch_modules)
    diagrams = []

    FOR EACH path IN interaction_paths:
        mermaid = "sequenceDiagram\n"

        participants = collect_unique_participants(path)
        FOR EACH participant IN participants:
            arch = find_arch_by_sys(arch_modules, participant)
            IF arch IS NOT NULL:
                alias = format("A%s", arch.id.replace("ARCH-", ""))
                mermaid += format("    participant %s as %s %s\n", alias, arch.id, arch.name)

        FOR EACH interaction IN path.interactions:
            source_alias = get_alias(interaction.source)
            target_alias = get_alias(interaction.target)
            IF interaction.is_async:
                mermaid += format("    %s-->>%s: %s\n", source_alias, target_alias, interaction.message)
            ELSE:
                mermaid += format("    %s->>%s: %s\n", source_alias, target_alias, interaction.message)

            IF interaction.has_response:
                mermaid += format("    %s-->>%s: %s\n", target_alias, source_alias, interaction.response)

        validation_result = validate_mermaid_structure(mermaid)
        IF NOT validation_result.valid:
            RAISE INVALID_MERMAID(validation_result.errors)

        diagrams.append({content: mermaid, title: path.title})

    RETURN diagrams
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| interaction_paths | Array<InteractionPath> | 1..20 paths | Grouped from dependencies | Logical interaction sequences |
| diagrams | Array<MermaidBlock> | 1..20 blocks | Empty array | Generated Mermaid diagrams |
| mermaid | String | 100..5000 chars | "sequenceDiagram\n" | Mermaid markup being built |
| participants | Array<String> | 2..20 | Collected per path | Unique ARCH participant IDs |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Generated Mermaid fails structural validation | INVALID_MERMAID | ARCH-004: Syntax error description | Raise error with specifics; do not emit invalid Mermaid |
| No interaction paths derivable | — | — | Generate minimal single-phase diagram |

---

### Module: MOD-009 (Document Concurrency Model)

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `commands/architecture-design.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION document_concurrency_model(
    interaction_path: InteractionPath,
    arch_modules: Array<ArchModule>
) -> String:

    execution_model = "Sequential single-process execution"
    sync_points = "None required"

    has_parallel = false
    has_async = false

    FOR EACH interaction IN interaction_path.interactions:
        IF interaction.is_async:
            has_async = true
        IF interaction.is_parallel:
            has_parallel = true

    IF has_parallel:
        execution_model = "Parallel execution with synchronization barriers"
        sync_points = describe_sync_points(interaction_path)
    ELSE IF has_async:
        execution_model = "Asynchronous message-passing with callbacks"
        sync_points = describe_callback_points(interaction_path)

    description = format(
        "**Concurrency Model**: %s. %s\n\n**Synchronization Points**: %s",
        execution_model,
        interaction_path.context_description,
        sync_points
    )

    RETURN description
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| has_parallel | Boolean | — | false | Whether path contains parallel interactions |
| has_async | Boolean | — | false | Whether path contains async interactions |
| execution_model | String | 10..200 chars | "Sequential single-process execution" | Concurrency classification |
| sync_points | String | 10..500 chars | "None required" | Synchronization point description |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Empty interaction path | — | ARCH-004: concurrency_model is required | Return default sequential model description |

---

### Module: MOD-010 (Generate Contract Tables)

**Parent Architecture Modules**: ARCH-005
**Target Source File(s)**: `commands/architecture-design.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION generate_contract_tables(
    arch_modules: Array<ArchModule>,
    sys_interfaces: Array<InterfaceSpec>,
    template_structure: String
) -> Array<ContractTable>:

    tables = []

    FOR EACH module IN arch_modules:
        relevant_interfaces = filter_interfaces_for_module(sys_interfaces, module)
        inputs = []
        outputs = []
        exceptions = []

        FOR EACH iface IN relevant_interfaces:
            inputs.append({
                name: iface.input_name,
                type: iface.input_type,
                format: iface.input_format,
                constraints: iface.input_constraints
            })
            outputs.append({
                name: iface.output_name,
                type: iface.output_type,
                format: iface.output_format,
                constraints: iface.output_constraints
            })

        inputs = inputs + derive_inputs_from_description(module)
        outputs = outputs + derive_outputs_from_description(module)
        exceptions = derive_exceptions_from_description(module)

        IF inputs.length == 0 AND outputs.length == 0:
            EMIT BLACK_BOX_WARNING(module.id, "Insufficient data to derive contract")

        header = format("### %s: %s\n\n", module.id, module.name)
        table_header = "| Direction | Name | Type | Format | Constraints |\n"
        table_sep = "|-----------|------|------|--------|-------------|\n"
        rows = []

        FOR EACH inp IN inputs:
            rows.append(format("| Input | %s | %s | %s | %s |", inp.name, inp.type, inp.format, inp.constraints))
        FOR EACH out IN outputs:
            rows.append(format("| Output | %s | %s | %s | %s |", out.name, out.type, out.format, out.constraints))
        FOR EACH exc IN exceptions:
            rows.append(format("| Exception | %s | %s | %s | %s |", exc.name, exc.type, exc.format, exc.constraints))

        tables.append({module_id: module.id, content: header + table_header + table_sep + join(rows, "\n")})

    RETURN tables
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| tables | Array<ContractTable> | 1..100 | Empty array | Per-module contract tables |
| inputs | Array<ContractEntry> | 0..20 per module | Empty per module | Input contract entries |
| outputs | Array<ContractEntry> | 0..20 per module | Empty per module | Output contract entries |
| exceptions | Array<ContractEntry> | 0..10 per module | Empty per module | Exception contract entries |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Module with no derivable inputs/outputs | BLACK_BOX_WARNING | ARCH-005: Warning with ARCH-NNN ID | Emit warning, generate partial table |

---

### Module: MOD-011 (Generate Data Flow Tables)

**Parent Architecture Modules**: ARCH-006
**Target Source File(s)**: `commands/architecture-design.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION generate_data_flow_tables(
    arch_modules: Array<ArchModule>,
    dependencies: Array<Dependency>,
    template_structure: String
) -> Array<DataFlowTable>:

    flow_chains = trace_data_paths(dependencies, arch_modules)
    tables = []

    FOR EACH chain IN flow_chains:
        header = format("### Data Flow: %s\n\n", chain.title)
        table_header = "| Stage | Module | Input Format | Transformation | Output Format |\n"
        table_sep = "|-------|--------|-------------|----------------|---------------|\n"
        rows = []
        stage_num = 1

        FOR EACH step IN chain.steps:
            module_ref = find_arch_for_step(arch_modules, step)
            IF module_ref IS NULL:
                EMIT DISCONNECTED_MODULE(step.module_id)
                CONTINUE

            row = format("| %d | %s | %s | %s | %s |",
                stage_num,
                module_ref.id,
                step.input_format,
                step.transformation,
                step.output_format
            )
            rows.append(row)
            stage_num = stage_num + 1

        tables.append({title: chain.title, content: header + table_header + table_sep + join(rows, "\n")})

    RETURN tables
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| flow_chains | Array<DataFlowChain> | 1..20 chains | Traced from dependencies | Logical data flow paths |
| tables | Array<DataFlowTable> | 1..20 | Empty array | Generated tables |
| stage_num | Integer | 1..50 | 1 per chain | Sequential stage counter |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Module with no data flow connections | DISCONNECTED_MODULE | ARCH-006: Warning with ARCH-NNN ID | Skip step, emit warning |

---

### Module: MOD-012 (Parse Logical View)

**Parent Architecture Modules**: ARCH-007
**Target Source File(s)**: `commands/integration-test.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION parse_logical_view(arch_design_content: String, arch_pattern: Regex) -> Array<ArchModule>:
    modules = []
    lines = arch_design_content.split("\n")
    in_logical_section = false

    FOR EACH line IN lines:
        IF line matches /^##\s+Logical View/:
            in_logical_section = true
            CONTINUE
        IF in_logical_section AND line matches /^##\s+/ AND NOT line matches /Logical/:
            BREAK

        IF in_logical_section AND line matches table_row_pattern:
            cells = split_table_row(line)
            IF cells.length < 5:
                CONTINUE

            id_match = arch_pattern.match(cells[0].trim())
            IF id_match IS NULL:
                CONTINUE

            parent_sys_raw = cells[3].trim()
            IF parent_sys_raw matches /\[CROSS-CUTTING\]/:
                parent_sys = []
                is_cross_cutting = true
                rationale = extract_cross_cutting_rationale(parent_sys_raw)
            ELSE:
                parent_sys = find_all_matches(parent_sys_raw, /SYS-[0-9]{3}/)
                is_cross_cutting = false
                rationale = NULL

            module = {
                id:              id_match.group(0),
                name:            cells[1].trim(),
                description:     cells[2].trim(),
                parent_sys:      parent_sys,
                type:            cells[4].trim(),
                is_cross_cutting: is_cross_cutting,
                rationale:       rationale
            }
            modules.append(module)

    IF modules.length == 0:
        RAISE MISSING_VIEW("Logical View not found or contains no ARCH modules")

    RETURN modules
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| modules | Array<ArchModule> | 0..100 elements | Empty array | Parsed ARCH module definitions |
| in_logical_section | Boolean | — | false | Section scope tracker |
| is_cross_cutting | Boolean | — | Per-row | Whether module is cross-cutting |
| rationale | String or NULL | 0..500 chars | Per-row | Cross-cutting rationale text |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Logical View section absent or empty | MISSING_VIEW | ARCH-007: "Logical View" view name | Halt with error |
| Malformed table row | — | — | Skip row, continue |

---

### Module: MOD-013 (Parse Architecture Views)

**Parent Architecture Modules**: ARCH-007
**Target Source File(s)**: `commands/integration-test.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION parse_architecture_views(arch_design_content: String) -> ViewData:
    process_view = parse_process_view_section(arch_design_content)
    interface_view = parse_interface_view_section(arch_design_content)
    data_flow_view = parse_data_flow_view_section(arch_design_content)

    missing_views = []
    IF process_view IS NULL:
        missing_views.append("Process View")
    IF interface_view IS NULL:
        missing_views.append("Interface View")
    IF data_flow_view IS NULL:
        missing_views.append("Data Flow View")

    IF missing_views.length > 0:
        RAISE MISSING_VIEW(join(missing_views, ", "))

    RETURN {
        process_view:   process_view,
        interface_view:  interface_view,
        data_flow_view:  data_flow_view
    }

FUNCTION parse_process_view_section(content: String) -> ProcessView:
    lines = content.split("\n")
    in_process = false
    mermaid_blocks = []
    current_block = NULL

    FOR EACH line IN lines:
        IF line matches /^##\s+Process View/:
            in_process = true
            CONTINUE
        IF in_process AND line matches /^##\s+/ AND NOT line matches /Process/:
            BREAK
        IF in_process AND line matches /```mermaid/:
            current_block = ""
            CONTINUE
        IF current_block IS NOT NULL AND line matches /```/:
            mermaid_blocks.append(current_block)
            current_block = NULL
            CONTINUE
        IF current_block IS NOT NULL:
            current_block += line + "\n"

    IF mermaid_blocks.length == 0:
        RETURN NULL

    RETURN {diagrams: mermaid_blocks}

FUNCTION parse_interface_view_section(content: String) -> InterfaceView:
    lines = content.split("\n")
    in_interface = false
    contracts = {}
    current_arch = NULL

    FOR EACH line IN lines:
        IF line matches /^##\s+Interface View/:
            in_interface = true
            CONTINUE
        IF in_interface AND line matches /^##\s+/ AND NOT line matches /Interface/:
            BREAK
        IF in_interface AND line matches /^###\s+(ARCH-[0-9]{3})/:
            current_arch = match.group(1)
            contracts[current_arch] = []
            CONTINUE
        IF in_interface AND current_arch IS NOT NULL AND line matches table_row_pattern:
            cells = split_table_row(line)
            IF cells.length >= 5:
                contracts[current_arch].append({
                    direction:   cells[0].trim(),
                    name:        cells[1].trim(),
                    type:        cells[2].trim(),
                    format:      cells[3].trim(),
                    constraints: cells[4].trim()
                })

    IF contracts IS empty:
        RETURN NULL

    RETURN {contracts: contracts}

FUNCTION parse_data_flow_view_section(content: String) -> DataFlowView:
    lines = content.split("\n")
    in_data_flow = false
    chains = []
    current_chain = NULL

    FOR EACH line IN lines:
        IF line matches /^##\s+Data Flow View/:
            in_data_flow = true
            CONTINUE
        IF in_data_flow AND line matches /^##\s+/ AND NOT line matches /Data Flow/:
            BREAK
        IF in_data_flow AND line matches /^###\s+Data Flow:\s+(.+)/:
            current_chain = {title: match.group(1), stages: []}
            chains.append(current_chain)
            CONTINUE
        IF in_data_flow AND current_chain IS NOT NULL AND line matches table_row_pattern:
            cells = split_table_row(line)
            IF cells.length >= 5:
                current_chain.stages.append({
                    stage:          cells[0].trim(),
                    module:         cells[1].trim(),
                    input_format:   cells[2].trim(),
                    transformation: cells[3].trim(),
                    output_format:  cells[4].trim()
                })

    IF chains.length == 0:
        RETURN NULL

    RETURN {chains: chains}
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| process_view | ProcessView or NULL | {diagrams: Array<String>} | Parsed from section | Mermaid sequence diagrams |
| interface_view | InterfaceView or NULL | {contracts: Dict<String, Array>} | Parsed from section | Per-ARCH contract tables |
| data_flow_view | DataFlowView or NULL | {chains: Array<Chain>} | Parsed from section | Data flow transformation chains |
| mermaid_blocks | Array<String> | 0..20 | Empty array | Extracted Mermaid code blocks |
| contracts | Dict<String, Array<ContractRow>> | 0..50 entries | Empty dict | Per-ARCH contract rows |
| chains | Array<DataFlowChain> | 0..10 | Empty array | Named data flow chains |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| One or more mandatory views missing | MISSING_VIEW | ARCH-007: View names listed | Halt with error listing missing views |
| Empty Mermaid block | — | — | Skip block, continue parsing |

---

### Module: MOD-014 (Generate ITP Cases)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `commands/integration-test.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION generate_itp_cases(
    arch_modules: Array<ArchModule>,
    view_data: ViewData,
    template_structure: String
) -> Array<TestCase>:

    test_cases = []

    FOR EACH module IN arch_modules:
        arch_num = extract_number(module.id)
        letter_index = 0

        interface_contracts = view_data.interface_view.contracts[module.id]
        IF interface_contracts IS NOT NULL AND interface_contracts.length > 0:
            case_id = format("ITP-%03d-%s", arch_num, chr(65 + letter_index))
            test_cases.append({
                id:            case_id,
                parent_arch:   module.id,
                technique:     "Interface Contract Testing",
                anchored_view: "Interface View",
                description:   format("Verify %s accepts valid inputs and produces contracted outputs", module.name)
            })
            letter_index = letter_index + 1

        data_flows = find_data_flows_for_module(view_data.data_flow_view, module.id)
        IF data_flows.length > 0:
            case_id = format("ITP-%03d-%s", arch_num, chr(65 + letter_index))
            test_cases.append({
                id:            case_id,
                parent_arch:   module.id,
                technique:     "Data Flow Testing",
                anchored_view: "Data Flow View",
                description:   format("Verify data transformations through %s match documented chain", module.name)
            })
            letter_index = letter_index + 1

        error_contracts = filter_exceptions(interface_contracts)
        IF error_contracts.length > 0:
            case_id = format("ITP-%03d-%s", arch_num, chr(65 + letter_index))
            test_cases.append({
                id:            case_id,
                parent_arch:   module.id,
                technique:     "Interface Fault Injection",
                anchored_view: "Interface View",
                description:   format("Inject invalid inputs into %s and verify error handling contracts", module.name)
            })
            letter_index = letter_index + 1

        process_interactions = find_process_interactions(view_data.process_view, module.id)
        IF process_interactions.length > 0:
            case_id = format("ITP-%03d-%s", arch_num, chr(65 + letter_index))
            test_cases.append({
                id:            case_id,
                parent_arch:   module.id,
                technique:     "Concurrency & Race Condition Testing",
                anchored_view: "Process View",
                description:   format("Verify %s execution ordering and synchronization", module.name)
            })
            letter_index = letter_index + 1

        IF letter_index == 0:
            EMIT NO_TECHNIQUE_MATCH(module.id)

    RETURN test_cases
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| test_cases | Array<TestCase> | 1..200 | Empty array | Generated ITP test case definitions |
| arch_num | Integer | 1..999 | Extracted from ARCH ID | Numeric portion of ARCH-NNN |
| letter_index | Integer | 0..25 | 0 per module | Sequential letter counter (A=0, B=1, ...) |
| interface_contracts | Array<ContractRow> or NULL | 0..20 | From view_data | Interface View contracts for module |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Module with no matching technique | NO_TECHNIQUE_MATCH | ARCH-008: Warning with ARCH-NNN ID | Emit warning, no test case generated for this technique |

---

### Module: MOD-015 (Assign ISO Techniques)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `commands/integration-test.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION assign_iso_techniques(
    test_case: TestCase,
    view_data: ViewData
) -> TestCase:

    technique_map = {
        "Interface Contract Testing":            "Interface View",
        "Data Flow Testing":                     "Data Flow View",
        "Interface Fault Injection":             "Interface View",
        "Concurrency & Race Condition Testing":  "Process View"
    }

    IF test_case.technique NOT IN technique_map:
        RAISE NO_TECHNIQUE_MATCH(test_case.parent_arch)

    expected_view = technique_map[test_case.technique]
    IF test_case.anchored_view != expected_view:
        test_case.anchored_view = expected_view

    view_content = get_view_content(view_data, expected_view, test_case.parent_arch)
    IF view_content IS NULL OR view_content IS empty:
        EMIT NO_TECHNIQUE_MATCH(test_case.parent_arch)
        test_case.coverage_warning = "Anchored view has insufficient data"

    RETURN test_case
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| technique_map | Dict<String, String> | 4 entries (fixed) | Constant | Maps technique name to required architecture view |
| expected_view | String | One of 4 view names | From map lookup | The view that should anchor this technique |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Unknown technique name | NO_TECHNIQUE_MATCH | ARCH-008: Warning | Raise error for unknown technique |
| View data insufficient for technique | NO_TECHNIQUE_MATCH | ARCH-008: Warning | Add coverage_warning to test case |

---

### Module: MOD-016 (Generate BDD Scenarios)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `commands/integration-test.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION generate_bdd_scenarios(
    test_cases: Array<TestCase>,
    template_structure: String
) -> Array<TestScenario>:

    scenarios = []

    FOR EACH case IN test_cases:
        case_num = extract_itp_number(case.id)
        case_letter = extract_itp_letter(case.id)
        scenario_index = 1

        scenario_definitions = derive_scenarios_for_technique(case)

        FOR EACH definition IN scenario_definitions:
            scenario_id = format("ITS-%03d-%s%d", case_num, case_letter, scenario_index)

            IF definition.tests_internal_logic:
                EMIT SCOPE_VIOLATION(scenario_id)
                CONTINUE

            IF definition.tests_user_journey:
                EMIT SCOPE_VIOLATION(scenario_id)
                CONTINUE

            scenario = {
                id:         scenario_id,
                parent_itp: case.id,
                given:      definition.given,
                when:       definition.when,
                then:       definition.then
            }
            scenarios.append(scenario)
            scenario_index = scenario_index + 1

    RETURN scenarios

FUNCTION derive_scenarios_for_technique(case: TestCase) -> Array<ScenarioDefinition>:
    definitions = []

    IF case.technique == "Interface Contract Testing":
        definitions.append({
            given: format("Given %s is initialized with valid configuration", case.parent_arch),
            when:  "When a valid input payload conforming to the Interface View contract is sent",
            then:  "Then the module produces output matching the contracted type and format",
            tests_internal_logic: false,
            tests_user_journey: false
        })
        definitions.append({
            given: format("Given %s is initialized with valid configuration", case.parent_arch),
            when:  "When an input violating a documented constraint is sent",
            then:  "Then the module returns the contracted error code without side effects",
            tests_internal_logic: false,
            tests_user_journey: false
        })

    ELSE IF case.technique == "Data Flow Testing":
        definitions.append({
            given: format("Given the upstream module provides output in the documented format"),
            when:  format("When %s receives the upstream output as input", case.parent_arch),
            then:  "Then the transformation produces output matching the documented output format",
            tests_internal_logic: false,
            tests_user_journey: false
        })

    ELSE IF case.technique == "Interface Fault Injection":
        definitions.append({
            given: format("Given %s is operational", case.parent_arch),
            when:  "When a malformed input is injected at the module boundary",
            then:  "Then the module rejects the input with the contracted exception and does not propagate corruption",
            tests_internal_logic: false,
            tests_user_journey: false
        })

    ELSE IF case.technique == "Concurrency & Race Condition Testing":
        definitions.append({
            given: "Given multiple modules are executing in the documented sequence",
            when:  format("When %s is invoked according to the Process View execution order", case.parent_arch),
            then:  "Then execution completes without deadlock and synchronization points are respected",
            tests_internal_logic: false,
            tests_user_journey: false
        })

    RETURN definitions
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| scenarios | Array<TestScenario> | 1..500 | Empty array | Generated ITS BDD scenarios |
| scenario_index | Integer | 1..99 | 1 per ITP case | Sequential scenario counter per case |
| definitions | Array<ScenarioDefinition> | 1..5 per technique | Derived from technique | Scenario definitions per technique type |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Scenario tests internal logic | SCOPE_VIOLATION | ARCH-009: ITS-NNN-X# ID | Skip scenario, emit warning |
| Scenario tests user journey | SCOPE_VIOLATION | ARCH-009: ITS-NNN-X# ID | Skip scenario, emit warning |

---

### Module: MOD-017 (Invoke Coverage Gate)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `commands/integration-test.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION invoke_coverage_gate(
    vmodel_dir: String,
    json_mode: Boolean
) -> CoverageGateResult:

    script_path = resolve_validation_script(vmodel_dir)

    IF script_path IS NULL:
        RETURN {pass: false, summary: "Validation script not found"}

    IF json_mode:
        command = script_path + " --json " + vmodel_dir
    ELSE:
        command = script_path + " " + vmodel_dir

    exit_code, stdout, stderr = execute_subprocess(command)

    IF exit_code == 0:
        RETURN {
            pass:    true,
            summary: parse_coverage_summary(stdout, json_mode)
        }
    ELSE IF exit_code == 1:
        RETURN {
            pass:    false,
            summary: parse_coverage_summary(stdout, json_mode)
        }
    ELSE:
        RETURN {
            pass:    false,
            summary: format("Validation script failed with exit code %d: %s", exit_code, stderr)
        }

FUNCTION resolve_validation_script(vmodel_dir: String) -> String or NULL:
    bash_path = find_script("validate-architecture-coverage.sh")
    IF bash_path IS NOT NULL AND file_exists(bash_path):
        RETURN bash_path
    ps_path = find_script("validate-architecture-coverage.ps1")
    IF ps_path IS NOT NULL AND file_exists(ps_path):
        RETURN ps_path
    RETURN NULL
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| script_path | String or NULL | File system path | Resolved from script directory | Path to validation script |
| exit_code | Integer | 0..255 | From subprocess | Script exit code |
| stdout | String | 0..10000 chars | From subprocess | Script standard output |
| stderr | String | 0..5000 chars | From subprocess | Script standard error |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Validation script not found | — | ARCH-009: coverage_gate_result.pass = false | Return failure result with descriptive summary |
| Script exits with code > 1 | — | ARCH-009: Unexpected failure | Return failure result with stderr content |
| Script exits with code 1 | — | ARCH-009: Gaps found | Return failure result with parsed gap summary |

---

### Module: MOD-018 (Validate Forward Coverage)

**Parent Architecture Modules**: ARCH-010
**Target Source File(s)**: `scripts/bash/validate-architecture-coverage.sh, scripts/powershell/validate-architecture-coverage.ps1`

#### Algorithmic / Logic View

```pseudocode
FUNCTION validate_forward_coverage(
    system_design_path: String,
    arch_design_path: String,
    sys_pattern: Regex,
    arch_pattern: Regex
) -> ForwardCoverageResult:

    IF NOT file_exists(system_design_path):
        RAISE FILE_NOT_FOUND(system_design_path)
    IF NOT file_exists(arch_design_path):
        RAISE FILE_NOT_FOUND(arch_design_path)

    sys_ids = []
    in_decomposition = false
    FOR EACH line IN read_lines(system_design_path):
        IF line matches /^##\s+.*Decomposition/:
            in_decomposition = true
            CONTINUE
        IF in_decomposition AND line matches /^##\s+/:
            BREAK
        IF in_decomposition:
            matches = sys_pattern.find_all(line)
            FOR EACH m IN matches:
                IF m NOT IN sys_ids:
                    sys_ids.append(m)

    arch_parent_map = {}
    in_logical = false
    FOR EACH line IN read_lines(arch_design_path):
        IF line matches /^##\s+Logical/:
            in_logical = true
            CONTINUE
        IF in_logical AND line matches /^##\s+/:
            BREAK
        IF in_logical AND line matches table_row_pattern:
            cells = split_table_row(line)
            IF cells.length >= 4:
                arch_id_match = arch_pattern.match(cells[0].trim())
                IF arch_id_match IS NOT NULL:
                    parent_cell = cells[3].trim()
                    IF parent_cell matches /\[CROSS-CUTTING\]/:
                        CONTINUE
                    parent_sys = sys_pattern.find_all(parent_cell)
                    FOR EACH sys IN parent_sys:
                        IF sys NOT IN arch_parent_map:
                            arch_parent_map[sys] = []
                        arch_parent_map[sys].append(arch_id_match.group(0))

    sys_ids = sort_unique(sys_ids)
    covered_sys = []
    uncovered_sys = []

    FOR EACH sys_id IN sys_ids:
        IF sys_id IN arch_parent_map AND arch_parent_map[sys_id].length > 0:
            covered_sys.append(sys_id)
        ELSE:
            uncovered_sys.append(sys_id)

    IF sys_ids.length > 0:
        coverage_pct = (covered_sys.length * 100) / sys_ids.length
    ELSE:
        coverage_pct = 0

    RETURN {
        sys_ids:       sys_ids,
        covered_sys:   covered_sys,
        uncovered_sys: uncovered_sys,
        coverage_pct:  coverage_pct
    }
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| sys_ids | Array<String> | 0..50 | Empty, deduplicated | Unique SYS-NNN identifiers from Decomposition View |
| arch_parent_map | Dict<String, Array<String>> | 0..50 entries | Empty dict | Maps SYS-NNN to list of covering ARCH-NNN IDs |
| covered_sys | Array<String> | 0..50 | Filtered | SYS IDs with at least one ARCH parent |
| uncovered_sys | Array<String> | 0..50 | Filtered | SYS IDs without ARCH parent |
| coverage_pct | Integer | 0..100 | Computed | Forward coverage percentage |
| in_decomposition | Boolean | — | false | Section scope tracker for system-design.md |
| in_logical | Boolean | — | false | Section scope tracker for architecture-design.md |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| system-design.md not found | FILE_NOT_FOUND | ARCH-010: File path, exit code 1 | Halt with error message |
| architecture-design.md not found | FILE_NOT_FOUND | ARCH-010: File path, exit code 1 | Halt with error message |

---

### Module: MOD-019 (Validate Backward Coverage)

**Parent Architecture Modules**: ARCH-011
**Target Source File(s)**: `scripts/bash/validate-architecture-coverage.sh, scripts/powershell/validate-architecture-coverage.ps1`

#### Algorithmic / Logic View

```pseudocode
FUNCTION validate_backward_coverage(
    arch_design_path: String,
    integration_test_path: String,
    arch_pattern: Regex,
    itp_pattern: Regex
) -> BackwardCoverageResult:

    IF NOT file_exists(arch_design_path):
        RAISE FILE_NOT_FOUND(arch_design_path)

    partial_mode = false
    IF NOT file_exists(integration_test_path):
        partial_mode = true

    arch_ids = []
    in_logical = false
    FOR EACH line IN read_lines(arch_design_path):
        IF line matches /^##\s+Logical/:
            in_logical = true
            CONTINUE
        IF in_logical AND line matches /^##\s+/:
            BREAK
        IF in_logical:
            matches = arch_pattern.find_all(line)
            FOR EACH m IN matches:
                IF m NOT IN arch_ids:
                    arch_ids.append(m)

    arch_ids = sort_unique(arch_ids)

    IF partial_mode:
        RETURN {
            arch_ids:      arch_ids,
            covered_arch:  [],
            uncovered_arch: [],
            coverage_pct:  0,
            partial_mode:  true
        }

    itp_ids = []
    FOR EACH line IN read_lines(integration_test_path):
        matches = itp_pattern.find_all(line)
        FOR EACH m IN matches:
            IF m NOT IN itp_ids:
                itp_ids.append(m)

    covered_arch = []
    uncovered_arch = []

    FOR EACH arch_id IN arch_ids:
        arch_num = extract_number(arch_id)
        has_itp = false
        FOR EACH itp IN itp_ids:
            itp_num = extract_itp_arch_number(itp)
            IF arch_num == itp_num:
                has_itp = true
                BREAK
        IF has_itp:
            covered_arch.append(arch_id)
        ELSE:
            uncovered_arch.append(arch_id)

    IF arch_ids.length > 0:
        coverage_pct = (covered_arch.length * 100) / arch_ids.length
    ELSE:
        coverage_pct = 0

    RETURN {
        arch_ids:       arch_ids,
        covered_arch:   covered_arch,
        uncovered_arch: uncovered_arch,
        coverage_pct:   coverage_pct,
        partial_mode:   false
    }
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| arch_ids | Array<String> | 0..100 | Extracted and deduplicated | Unique ARCH-NNN identifiers |
| itp_ids | Array<String> | 0..500 | Extracted from integration-test.md | Unique ITP-NNN-X identifiers |
| covered_arch | Array<String> | 0..100 | Filtered | ARCH IDs with at least one ITP match |
| uncovered_arch | Array<String> | 0..100 | Filtered | ARCH IDs without ITP match |
| partial_mode | Boolean | — | false unless file missing | Whether integration-test.md is absent |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| architecture-design.md not found | FILE_NOT_FOUND | ARCH-011: File path | Halt with error |
| integration-test.md not found | PARTIAL_MODE | ARCH-011: "integration-test.md not found" | Return partial result with zero coverage |

---

### Module: MOD-020 (Detect Orphaned Identifiers)

**Parent Architecture Modules**: ARCH-012
**Target Source File(s)**: `scripts/bash/validate-architecture-coverage.sh, scripts/powershell/validate-architecture-coverage.ps1`

#### Algorithmic / Logic View

```pseudocode
FUNCTION detect_orphaned_identifiers(
    sys_ids: Array<String>,
    arch_data: Object,
    itp_ids: Array<String>,
    arch_pattern: Regex
) -> OrphanResult:

    orphaned_arch = []

    FOR EACH arch IN arch_data.modules:
        IF arch.is_cross_cutting:
            CONTINUE

        FOR EACH parent_sys IN arch.parent_sys:
            IF parent_sys NOT IN sys_ids:
                orphaned_arch.append({
                    arch_id:     arch.id,
                    unknown_sys: parent_sys
                })
                BREAK

    orphaned_itps = []

    IF itp_ids.length > 0:
        known_arch_ids = [m.id FOR m IN arch_data.modules]

        FOR EACH itp IN itp_ids:
            itp_arch_num = extract_itp_arch_number(itp)
            parent_arch_id = format("ARCH-%03d", itp_arch_num)
            IF parent_arch_id NOT IN known_arch_ids:
                orphaned_itps.append(itp)

    RETURN {
        orphaned_arch: orphaned_arch,
        orphaned_itps: orphaned_itps
    }
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| orphaned_arch | Array<{arch_id, unknown_sys}> | 0..50 | Empty array | ARCH entries referencing non-existent SYS |
| orphaned_itps | Array<String> | 0..200 | Empty array | ITP entries whose parent ARCH does not exist |
| known_arch_ids | Array<String> | 0..100 | From arch_data | All valid ARCH identifiers |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| — | — | ARCH-012: Module completes without exception | All anomalies returned as data |

---

### Module: MOD-021 (Detect Circular Dependencies)

**Parent Architecture Modules**: ARCH-012
**Target Source File(s)**: `scripts/bash/validate-architecture-coverage.sh, scripts/powershell/validate-architecture-coverage.ps1`

#### Algorithmic / Logic View

```pseudocode
FUNCTION detect_circular_dependencies(
    process_view_content: String,
    arch_pattern: Regex
) -> Array<CircularChain>:

    adjacency = {}

    FOR EACH line IN process_view_content.split("\n"):
        IF line matches /(ARCH-[0-9]{3}).*->>(ARCH-[0-9]{3})/:
            source = match.group(1)
            target = match.group(2)

            IF source NOT IN adjacency:
                adjacency[source] = []
            adjacency[source].append(target)

        ELSE IF line matches /([A-Z][0-9]+).*->>([A-Z][0-9]+)/:
            source_alias = match.group(1)
            target_alias = match.group(2)
            source_arch = resolve_alias(source_alias)
            target_arch = resolve_alias(target_alias)
            IF source_arch IS NOT NULL AND target_arch IS NOT NULL:
                IF source_arch NOT IN adjacency:
                    adjacency[source_arch] = []
                adjacency[source_arch].append(target_arch)

    circular_chains = []
    visited = {}
    rec_stack = {}

    FUNCTION dfs(node: String, path: Array<String>):
        visited[node] = true
        rec_stack[node] = true
        path.append(node)

        FOR EACH neighbor IN adjacency.get(node, []):
            IF neighbor NOT IN visited:
                dfs(neighbor, path)
            ELSE IF neighbor IN rec_stack:
                cycle_start = path.index(neighbor)
                cycle = path[cycle_start..] + [neighbor]
                circular_chains.append(cycle)

        rec_stack.remove(node)
        path.pop()

    FOR EACH node IN adjacency.keys():
        IF node NOT IN visited:
            dfs(node, [])

    RETURN circular_chains
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| adjacency | Dict<String, Array<String>> | 0..100 entries | Empty dict | Directed graph of ARCH→ARCH edges |
| circular_chains | Array<Array<String>> | 0..20 | Empty array | Detected circular dependency chains |
| visited | Dict<String, Boolean> | 0..100 | Empty dict | DFS visited tracker |
| rec_stack | Dict<String, Boolean> | 0..100 | Empty dict | DFS recursion stack for cycle detection |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| — | — | ARCH-012: Cycles returned as data | Empty array when no cycles found |

---

### Module: MOD-022 (Format Coverage Report)

**Parent Architecture Modules**: ARCH-013
**Target Source File(s)**: `scripts/bash/validate-architecture-coverage.sh, scripts/powershell/validate-architecture-coverage.ps1`

#### Algorithmic / Logic View

```pseudocode
FUNCTION format_coverage_report(
    forward_result: ForwardCoverageResult,
    backward_result: BackwardCoverageResult,
    orphan_result: OrphanResult,
    json_mode: Boolean
) -> String:

    IF json_mode:
        json_obj = {
            forward_coverage: {
                total_sys:     forward_result.sys_ids.length,
                covered:       forward_result.covered_sys.length,
                uncovered:     forward_result.uncovered_sys,
                coverage_pct:  forward_result.coverage_pct
            },
            backward_coverage: {
                total_arch:    backward_result.arch_ids.length,
                covered:       backward_result.covered_arch.length,
                uncovered:     backward_result.uncovered_arch,
                coverage_pct:  backward_result.coverage_pct,
                partial_mode:  backward_result.partial_mode
            },
            orphans: {
                orphaned_arch: orphan_result.orphaned_arch,
                orphaned_itps: orphan_result.orphaned_itps,
                circular_deps: orphan_result.circular_deps
            }
        }
        RETURN json_serialize(json_obj)

    report = "=== Architecture Coverage Validation ===\n\n"
    report += format("Forward (SYS→ARCH): %d/%d (%d%%)\n",
        forward_result.covered_sys.length, forward_result.sys_ids.length, forward_result.coverage_pct)

    IF backward_result.partial_mode:
        report += "Backward (ARCH→ITP): SKIPPED (integration-test.md not found)\n"
    ELSE:
        report += format("Backward (ARCH→ITP): %d/%d (%d%%)\n",
            backward_result.covered_arch.length, backward_result.arch_ids.length, backward_result.coverage_pct)

    IF forward_result.uncovered_sys.length > 0:
        report += "\n❌ Uncovered SYS:\n"
        FOR EACH sys IN forward_result.uncovered_sys:
            report += format("   - %s: no architecture module mapping found\n", sys)

    IF backward_result.uncovered_arch.length > 0:
        report += "\n❌ Uncovered ARCH:\n"
        FOR EACH arch IN backward_result.uncovered_arch:
            report += format("   - %s: no integration test case found\n", arch)

    IF orphan_result.orphaned_arch.length > 0:
        report += "\n⚠️  Orphaned ARCH:\n"
        FOR EACH entry IN orphan_result.orphaned_arch:
            report += format("   - %s references unknown %s\n", entry.arch_id, entry.unknown_sys)

    IF orphan_result.orphaned_itps.length > 0:
        report += "\n⚠️  Orphaned ITP:\n"
        FOR EACH itp IN orphan_result.orphaned_itps:
            report += format("   - %s: parent ARCH does not exist\n", itp)

    RETURN report
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| json_obj | Object | Nested structure | Built from results | JSON output object |
| report | String | 100..10000 chars | Empty string | Human-readable report being built |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| — | — | ARCH-013: Formatter always produces output | No exceptions; all inputs processed |

---

### Module: MOD-023 (Compute Coverage Verdict)

**Parent Architecture Modules**: ARCH-013
**Target Source File(s)**: `scripts/bash/validate-architecture-coverage.sh, scripts/powershell/validate-architecture-coverage.ps1`

#### Algorithmic / Logic View

```pseudocode
FUNCTION compute_coverage_verdict(
    forward_result: ForwardCoverageResult,
    backward_result: BackwardCoverageResult,
    orphan_result: OrphanResult
) -> Integer:

    has_gaps = false

    IF forward_result.uncovered_sys.length > 0:
        has_gaps = true

    IF NOT backward_result.partial_mode:
        IF backward_result.uncovered_arch.length > 0:
            has_gaps = true

    IF orphan_result.orphaned_arch.length > 0:
        has_gaps = true

    IF orphan_result.orphaned_itps.length > 0:
        has_gaps = true

    IF orphan_result.circular_deps.length > 0:
        has_gaps = true

    IF has_gaps:
        RETURN 1
    ELSE:
        RETURN 0
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| has_gaps | Boolean | — | false | Aggregated gap detection flag |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Any coverage gap or orphan detected | Exit code 1 | ARCH-013: exit_code = 1 | Return 1 to signal CI failure |
| All checks pass | Exit code 0 | ARCH-013: exit_code = 0 | Return 0 to signal success |

---

### Module: MOD-024 (Load Architecture Template)

**Parent Architecture Modules**: ARCH-014
**Target Source File(s)**: `templates/architecture-design-template.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION load_architecture_template(template_dir: String) -> String:
    template_path = template_dir + "/architecture-design-template.md"

    IF NOT file_exists(template_path):
        RAISE TEMPLATE_NOT_FOUND(template_path)

    content = read_file(template_path)

    IF content.trim().length == 0:
        RAISE TEMPLATE_NOT_FOUND(template_path + " (file is empty)")

    sections = {
        logical_view:  false,
        process_view:  false,
        interface_view: false,
        data_flow_view: false
    }

    FOR EACH line IN content.split("\n"):
        IF line matches /Logical View/:
            sections.logical_view = true
        IF line matches /Process View/:
            sections.process_view = true
        IF line matches /Interface View/:
            sections.interface_view = true
        IF line matches /Data Flow View/:
            sections.data_flow_view = true

    FOR EACH section_name, found IN sections:
        IF NOT found:
            RAISE TEMPLATE_NOT_FOUND(format("Template missing mandatory section: %s", section_name))

    RETURN content
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| template_path | String | File system path | Constructed from template_dir | Full path to template file |
| content | String | 1..50000 chars | Read from file | Raw template Markdown content |
| sections | Dict<String, Boolean> | 4 entries (fixed) | All false | Tracks presence of mandatory view sections |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Template file missing | TEMPLATE_NOT_FOUND | ARCH-014: File path | Halt with error — template required for generation |
| Template empty | TEMPLATE_NOT_FOUND | ARCH-014: File path + "(file is empty)" | Halt with error |
| Mandatory section missing | TEMPLATE_NOT_FOUND | ARCH-014: Section name | Halt with error — template is malformed |

---

### Module: MOD-025 (Load Integration Test Template)

**Parent Architecture Modules**: ARCH-015
**Target Source File(s)**: `templates/integration-test-template.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION load_integration_test_template(template_dir: String) -> String:
    template_path = template_dir + "/integration-test-template.md"

    IF NOT file_exists(template_path):
        RAISE TEMPLATE_NOT_FOUND(template_path)

    content = read_file(template_path)

    IF content.trim().length == 0:
        RAISE TEMPLATE_NOT_FOUND(template_path + " (file is empty)")

    required_elements = {
        itp_hierarchy: false,
        its_format:    false,
        bdd_structure: false,
        test_harness:  false
    }

    FOR EACH line IN content.split("\n"):
        IF line matches /ITP-NNN-X/ OR line matches /Test Case/:
            required_elements.itp_hierarchy = true
        IF line matches /ITS-NNN-X/ OR line matches /Test Scenario/:
            required_elements.its_format = true
        IF line matches /Given.*When.*Then/ OR line matches /BDD/:
            required_elements.bdd_structure = true
        IF line matches /Test Harness/ OR line matches /Mocking Strategy/:
            required_elements.test_harness = true

    FOR EACH element_name, found IN required_elements:
        IF NOT found:
            RAISE TEMPLATE_NOT_FOUND(format("Template missing required element: %s", element_name))

    RETURN content
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| template_path | String | File system path | Constructed from template_dir | Full path to template file |
| content | String | 1..50000 chars | Read from file | Raw template Markdown content |
| required_elements | Dict<String, Boolean> | 4 entries (fixed) | All false | Tracks presence of required template elements |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Template file missing | TEMPLATE_NOT_FOUND | ARCH-015: File path | Halt with error |
| Template empty | TEMPLATE_NOT_FOUND | ARCH-015: File path + "(file is empty)" | Halt with error |
| Required element missing | TEMPLATE_NOT_FOUND | ARCH-015: Element name | Halt with error |

---

### Module: MOD-026 (Generate Matrix C Table)

**Parent Architecture Modules**: ARCH-016
**Target Source File(s)**: `commands/trace.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION generate_matrix_c_table(
    mapping_data: Object,
    req_references: Object
) -> MatrixCResult:

    IF mapping_data.entries.length == 0:
        RAISE EMPTY_MAPPING("No SYS→ARCH→ITP→ITS mapping data available")

    header = "| SYS (REQ) | ARCH | ITP | ITS |\n"
    separator = "|-----------|------|-----|-----|\n"
    rows = []

    grouped_by_sys = group_entries_by_sys(mapping_data.entries)

    FOR EACH sys_id, entries IN grouped_by_sys:
        req_list = req_references.get(sys_id, [])
        IF req_list.length > 0:
            sys_cell = format("%s (%s)", sys_id, join(req_list, ", "))
        ELSE:
            sys_cell = sys_id

        FOR EACH entry IN entries:
            itp_cell = join(entry.itp_ids, ", ")
            its_cell = join(entry.its_ids, ", ")
            row = format("| %s | %s | %s | %s |", sys_cell, entry.arch_id, itp_cell, its_cell)
            rows.append(row)
            sys_cell = ""

    cross_cutting_rows = generate_cross_cutting_pseudo_rows(mapping_data)
    rows = rows + cross_cutting_rows

    table = header + separator + join(rows, "\n")

    total_arch = count_unique_arch(mapping_data)
    covered_arch = count_arch_with_itp(mapping_data)
    IF total_arch > 0:
        coverage_pct = (covered_arch * 100) / total_arch
    ELSE:
        coverage_pct = 0

    RETURN {table: table, coverage_pct: coverage_pct}
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| rows | Array<String> | 1..200 | Empty array | Formatted Markdown table rows |
| grouped_by_sys | Dict<String, Array<MappingEntry>> | 0..50 | Grouped from entries | Entries grouped by SYS-NNN |
| sys_cell | String | 5..200 chars | Formatted with REQ refs | SYS column value with REQ annotations |
| coverage_pct | Integer | 0..100 | Computed | Independently calculated coverage percentage |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Empty mapping data | EMPTY_MAPPING | ARCH-016: Error | Halt with error — no data to build matrix |

---

### Module: MOD-027 (Generate Cross-Cutting Pseudo-Rows)

**Parent Architecture Modules**: ARCH-016
**Target Source File(s)**: `commands/trace.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION generate_cross_cutting_pseudo_rows(mapping_data: Object) -> Array<String>:
    rows = []

    FOR EACH entry IN mapping_data.entries:
        IF entry.is_cross_cutting:
            itp_cell = join(entry.itp_ids, ", ")
            its_cell = join(entry.its_ids, ", ")
            row = format("| N/A (Cross-Cutting) | %s | %s | %s |",
                entry.arch_id, itp_cell, its_cell)
            rows.append(row)

    RETURN rows
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| rows | Array<String> | 0..20 | Empty array | Cross-cutting pseudo-row strings |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| No cross-cutting entries | — | — | Return empty array |

---

### Module: MOD-028 (Determine Assembly Level)

**Parent Architecture Modules**: ARCH-017
**Target Source File(s)**: `commands/trace.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION determine_assembly_level(available_artifacts: Array<String>) -> String:
    has_acceptance = "acceptance-plan.md" IN available_artifacts
    has_system_test = "system-test.md" IN available_artifacts
    has_architecture = "architecture-design.md" IN available_artifacts
    has_integration_test = "integration-test.md" IN available_artifacts

    IF has_architecture AND has_integration_test:
        RETURN "A+B+C"
    ELSE IF has_system_test:
        RETURN "A+B"
    ELSE IF has_acceptance:
        RETURN "A"
    ELSE:
        RETURN "NONE"
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| has_acceptance | Boolean | — | Checked from artifacts | Whether acceptance-plan.md exists |
| has_system_test | Boolean | — | Checked from artifacts | Whether system-test.md exists |
| has_architecture | Boolean | — | Checked from artifacts | Whether architecture-design.md exists |
| has_integration_test | Boolean | — | Checked from artifacts | Whether integration-test.md exists |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| No recognized artifacts | — | ARCH-017: NO_ARTIFACTS warning | Return "NONE" level |

---

### Module: MOD-029 (Assemble Progressive Matrix)

**Parent Architecture Modules**: ARCH-017
**Target Source File(s)**: `commands/trace.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION assemble_progressive_matrix(
    level: String,
    matrix_a: String,
    matrix_b: String,
    matrix_c: String
) -> String:

    output = "# Traceability Matrix\n\n"

    IF level == "NONE":
        RETURN output + "No V-Model artifacts available for matrix generation.\n"

    IF level == "A" OR level == "A+B" OR level == "A+B+C":
        output += "## Matrix A — Validation (REQ → ATP → ATS)\n\n"
        output += matrix_a + "\n\n"

    IF level == "A+B" OR level == "A+B+C":
        output += "## Matrix B — Verification (SYS → STP → STS)\n\n"
        output += matrix_b + "\n\n"

    IF level == "A+B+C":
        output += "## Matrix C — Integration Verification (SYS → ARCH → ITP → ITS)\n\n"
        output += matrix_c + "\n\n"

    RETURN output
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| output | String | 50..50000 chars | Header initialized | Assembled Markdown content |
| level | String | One of: "NONE", "A", "A+B", "A+B+C" | From determine_assembly_level | Current assembly level |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Level is NONE | — | ARCH-017: NO_ARTIFACTS warning | Return header with informational message |

---

### Module: MOD-030 (Parse Matrix C Data — Bash)

**Parent Architecture Modules**: ARCH-018
**Target Source File(s)**: `scripts/bash/build-matrix.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION parse_matrix_c_data_bash(
    arch_design_path: String,
    integration_test_path: String
) -> void:

    IF NOT file_exists(arch_design_path):
        write_stderr(format("ERROR: %s not found", arch_design_path))
        exit(1)
    IF NOT file_exists(integration_test_path):
        write_stderr(format("ERROR: %s not found", integration_test_path))
        exit(1)

    sys_pattern = "SYS-[0-9]{3}"
    arch_pattern = "ARCH-[0-9]{3}"
    itp_pattern = "ITP-[0-9]{3}-[A-Z]"
    its_pattern = "ITS-[0-9]{3}-[A-Z][0-9]+"

    // Parse ARCH→SYS mapping from Logical View
    arch_to_sys = {}
    in_logical = false
    FOR EACH line IN read_lines(arch_design_path):
        IF line matches /^##\s+Logical/:
            in_logical = true
            CONTINUE
        IF in_logical AND line matches /^##\s+/:
            BREAK
        IF in_logical AND line matches table_row_pattern:
            arch_ids_found = grep_extract(line, arch_pattern)
            sys_ids_found = grep_extract(line, sys_pattern)
            IF arch_ids_found.length > 0:
                arch_id = arch_ids_found[0]
                IF line matches /\[CROSS-CUTTING\]/:
                    arch_to_sys[arch_id] = ["CROSS-CUTTING"]
                ELSE:
                    arch_to_sys[arch_id] = sys_ids_found

    // Parse ITP→ARCH and ITS→ITP mappings
    itp_ids = grep_extract_all(integration_test_path, itp_pattern)
    its_ids = grep_extract_all(integration_test_path, its_pattern)

    arch_to_itp = {}
    FOR EACH itp IN itp_ids:
        arch_num = extract_substring(itp, 4, 7)
        arch_key = "ARCH-" + arch_num
        IF arch_key NOT IN arch_to_itp:
            arch_to_itp[arch_key] = []
        arch_to_itp[arch_key].append(itp)

    itp_to_its = {}
    FOR EACH its IN its_ids:
        itp_key = "ITP-" + extract_substring(its, 4, 9)
        IF itp_key NOT IN itp_to_its:
            itp_to_its[itp_key] = []
        itp_to_its[itp_key].append(its)

    // Output structured mapping data
    total_arch = arch_to_sys.keys().length
    covered = 0
    FOR EACH arch_id IN arch_to_sys.keys():
        sys_list = join(arch_to_sys[arch_id], ",")
        itp_list = join(arch_to_itp.get(arch_id, []), ",")
        its_all = []
        FOR EACH itp IN arch_to_itp.get(arch_id, []):
            its_all = its_all + itp_to_its.get(itp, [])
        its_list = join(its_all, ",")

        write_stdout(format("%s|%s|%s|%s", sys_list, arch_id, itp_list, its_list))

        IF arch_to_itp.get(arch_id, []).length > 0:
            covered = covered + 1

    IF total_arch > 0:
        coverage_pct = (covered * 100) / total_arch
    ELSE:
        coverage_pct = 0

    write_stdout(format("COVERAGE:%d", coverage_pct))
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| arch_to_sys | Dict<String, Array<String>> | 0..100 entries | Empty | Maps ARCH-NNN to parent SYS list |
| arch_to_itp | Dict<String, Array<String>> | 0..100 entries | Empty | Maps ARCH-NNN to ITP list |
| itp_to_its | Dict<String, Array<String>> | 0..500 entries | Empty | Maps ITP-NNN-X to ITS list |
| coverage_pct | Integer | 0..100 | Computed | Independently calculated coverage |
| in_logical | Boolean | — | false | Section scope tracker |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Input file not found | MALFORMED_INPUT (exit 1) | ARCH-018: Error message to stderr | Exit with non-zero code |
| Malformed table row | — | — | Skip row, continue |

---

### Module: MOD-031 (Parse Matrix C Data — PowerShell)

**Parent Architecture Modules**: ARCH-019
**Target Source File(s)**: `scripts/powershell/build-matrix.ps1`

#### Algorithmic / Logic View

```pseudocode
FUNCTION Parse-MatrixCData(
    ArchDesignPath: String,
    IntegrationTestPath: String
) -> void:

    IF NOT (Test-Path ArchDesignPath):
        Write-Error "ERROR: $ArchDesignPath not found"
        exit 1
    IF NOT (Test-Path IntegrationTestPath):
        Write-Error "ERROR: $IntegrationTestPath not found"
        exit 1

    SysPattern = [regex]"SYS-[0-9]{3}"
    ArchPattern = [regex]"ARCH-[0-9]{3}"
    ItpPattern = [regex]"ITP-[0-9]{3}-[A-Z]"
    ItsPattern = [regex]"ITS-[0-9]{3}-[A-Z][0-9]+"

    // Parse ARCH→SYS mapping from Logical View
    ArchToSys = @{}
    InLogical = $false
    FOR EACH Line IN (Get-Content ArchDesignPath):
        IF Line -match "^##\s+Logical":
            InLogical = $true
            CONTINUE
        IF InLogical AND Line -match "^##\s+":
            BREAK
        IF InLogical AND Line -match "\|":
            ArchIds = [regex]::Matches(Line, ArchPattern) | Select Value
            IF ArchIds.Count -gt 0:
                ArchId = ArchIds[0].Value
                IF Line -match "\[CROSS-CUTTING\]":
                    ArchToSys[ArchId] = @("CROSS-CUTTING")
                ELSE:
                    SysIds = [regex]::Matches(Line, SysPattern) | Select Value
                    ArchToSys[ArchId] = SysIds

    // Parse ITP and ITS identifiers
    IntContent = Get-Content IntegrationTestPath -Raw
    ItpIds = [regex]::Matches(IntContent, ItpPattern) | Select -Unique Value
    ItsIds = [regex]::Matches(IntContent, ItsPattern) | Select -Unique Value

    // Build ARCH→ITP and ITP→ITS mappings (identical logic to Bash)
    ArchToItp = @{}
    FOR EACH Itp IN ItpIds:
        ArchNum = Itp.Value.Substring(4, 3)
        ArchKey = "ARCH-" + ArchNum
        IF ArchKey -notin ArchToItp.Keys:
            ArchToItp[ArchKey] = @()
        ArchToItp[ArchKey] += Itp.Value

    ItpToIts = @{}
    FOR EACH Its IN ItsIds:
        ItpKey = "ITP-" + Its.Value.Substring(4, 5)
        IF ItpKey -notin ItpToIts.Keys:
            ItpToIts[ItpKey] = @()
        ItpToIts[ItpKey] += Its.Value

    // Output structured mapping data (identical format to Bash)
    TotalArch = ArchToSys.Count
    Covered = 0
    FOR EACH ArchId IN ArchToSys.Keys:
        SysList = ArchToSys[ArchId] -join ","
        ItpList = (ArchToItp[ArchId] ?? @()) -join ","
        ItsAll = @()
        FOR EACH Itp IN (ArchToItp[ArchId] ?? @()):
            ItsAll += (ItpToIts[Itp] ?? @())
        ItsList = ItsAll -join ","
        Write-Output "$SysList|$ArchId|$ItpList|$ItsList"
        IF (ArchToItp[ArchId] ?? @()).Count -gt 0:
            Covered++

    IF TotalArch -gt 0:
        CoveragePct = [int]($Covered * 100 / $TotalArch)
    ELSE:
        CoveragePct = 0
    Write-Output "COVERAGE:$CoveragePct"
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| ArchToSys | Hashtable<String, String[]> | 0..100 entries | Empty hashtable | Maps ARCH-NNN to parent SYS list |
| ArchToItp | Hashtable<String, String[]> | 0..100 entries | Empty hashtable | Maps ARCH-NNN to ITP list |
| ItpToIts | Hashtable<String, String[]> | 0..500 entries | Empty hashtable | Maps ITP-NNN-X to ITS list |
| CoveragePct | Integer | 0..100 | Computed | Independently calculated coverage |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Input file not found | MALFORMED_INPUT (exit 1) | ARCH-019: Error message to stderr | Exit with non-zero code |
| Malformed table row | — | — | Skip row, continue |

---

### Module: MOD-032 (Check System Design Prerequisite)

**Parent Architecture Modules**: ARCH-020
**Target Source File(s)**: `scripts/bash/setup-v-model.sh, scripts/powershell/setup-v-model.ps1`

#### Algorithmic / Logic View

```pseudocode
FUNCTION check_system_design_prerequisite(
    vmodel_dir: String,
    require_system_design_flag: Boolean
) -> Boolean:

    IF NOT require_system_design_flag:
        RETURN true

    system_design_path = vmodel_dir + "/system-design.md"

    IF NOT file_exists(system_design_path):
        write_stderr(format("ERROR: system-design.md not found in %s", vmodel_dir))
        RAISE PREREQUISITE_MISSING(system_design_path)

    IF file_size(system_design_path) == 0:
        write_stderr(format("ERROR: system-design.md is empty in %s", vmodel_dir))
        RAISE PREREQUISITE_MISSING(system_design_path)

    RETURN true
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| system_design_path | String | File system path | Constructed from vmodel_dir | Full path to system-design.md |
| require_system_design_flag | Boolean | — | From CLI arguments | Whether --require-system-design was specified |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| system-design.md missing and flag set | PREREQUISITE_MISSING | ARCH-020: Non-zero exit code | Halt setup with error message |
| system-design.md empty and flag set | PREREQUISITE_MISSING | ARCH-020: Non-zero exit code | Halt setup with error message |
| Flag not set | — | ARCH-020: validation_result = true | Skip check, return true |

---

### Module: MOD-033 (Detect Extended Documents)

**Parent Architecture Modules**: ARCH-021
**Target Source File(s)**: `scripts/bash/setup-v-model.sh, scripts/powershell/setup-v-model.ps1`

#### Algorithmic / Logic View

```pseudocode
FUNCTION detect_extended_documents(vmodel_dir: String) -> Array<String>:
    known_documents = [
        "spec.md",
        "requirements.md",
        "acceptance-plan.md",
        "traceability-matrix.md",
        "system-design.md",
        "system-test.md",
        "architecture-design.md",
        "integration-test.md",
        "module-design.md",
        "unit-test.md"
    ]

    available = []

    FOR EACH doc_name IN known_documents:
        doc_path = vmodel_dir + "/" + doc_name
        IF file_exists(doc_path):
            available.append(doc_name)

    RETURN available
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| known_documents | Array<String> | 10 entries (fixed) | Constant list | All recognized V-Model document filenames |
| available | Array<String> | 0..10 | Empty array | Documents detected as existing in vmodel_dir |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| vmodel_dir does not exist | — | ARCH-021: Missing docs omitted from array | Return empty array |
| No documents found | — | ARCH-021: Empty array | Return empty array (valid state) |

---

### Module: MOD-034 (Update Extension Manifest)

**Parent Architecture Modules**: ARCH-022
**Target Source File(s)**: `extension.yml`

#### Algorithmic / Logic View

```pseudocode
FUNCTION update_extension_manifest(extension_yml_path: String) -> void:

    IF NOT file_exists(extension_yml_path):
        RAISE FILE_NOT_FOUND(extension_yml_path)

    content = read_file(extension_yml_path)
    yaml = parse_yaml(content)

    yaml.version = "0.3.0"

    existing_commands = yaml.commands OR []
    required_commands = [
        "speckit.v-model.requirements",
        "speckit.v-model.acceptance",
        "speckit.v-model.system-design",
        "speckit.v-model.system-test",
        "speckit.v-model.trace",
        "speckit.v-model.architecture-design",
        "speckit.v-model.integration-test"
    ]

    FOR EACH cmd IN required_commands:
        IF cmd NOT IN existing_commands.names():
            existing_commands.append({name: cmd})

    yaml.commands = existing_commands

    required_hooks = ["speckit.v-model.validate"]
    FOR EACH hook IN required_hooks:
        IF hook NOT IN yaml.hooks.names():
            yaml.hooks.append({name: hook})

    write_file(extension_yml_path, serialize_yaml(yaml))
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| yaml | Object | YAML document structure | Parsed from file | Extension manifest YAML content |
| existing_commands | Array<Object> | 5..10 | From yaml.commands | Registered command list |
| required_commands | Array<String> | 7 entries (fixed) | Constant | Commands that must be registered |
| required_hooks | Array<String> | 1 entry (fixed) | Constant | Hooks that must be registered |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| extension.yml missing | FILE_NOT_FOUND | ARCH-022: File path | Halt with error |
| YAML parse failure | — | — | Halt with parse error details |

---

### Module: MOD-035 (Update Catalog Entry)

**Parent Architecture Modules**: ARCH-022
**Target Source File(s)**: `catalog-entry.json`

#### Algorithmic / Logic View

```pseudocode
FUNCTION update_catalog_entry(catalog_entry_path: String) -> void:

    IF NOT file_exists(catalog_entry_path):
        RAISE FILE_NOT_FOUND(catalog_entry_path)

    content = read_file(catalog_entry_path)
    json = parse_json(content)

    json.version = "0.3.0"

    IF json.capabilities IS NULL:
        json.capabilities = {}

    json.capabilities.architecture_design = true
    json.capabilities.integration_test = true
    json.capabilities.matrix_c = true

    IF json.commands IS NULL:
        json.commands = []

    required_entries = [
        {name: "architecture-design", description: "Generate architecture design from system design"},
        {name: "integration-test", description: "Generate integration tests from architecture design"}
    ]

    FOR EACH entry IN required_entries:
        IF entry.name NOT IN json.commands.map(c -> c.name):
            json.commands.append(entry)

    write_file(catalog_entry_path, json_serialize_pretty(json))
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| json | Object | JSON document structure | Parsed from file | Catalog entry JSON content |
| required_entries | Array<Object> | 2 entries (fixed) | Constant | New command entries to register |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| catalog-entry.json missing | FILE_NOT_FOUND | ARCH-022: File path | Halt with error |
| JSON parse failure | — | — | Halt with parse error details |

---

### Module: MOD-036 (Evaluate Architecture Output)

**Parent Architecture Modules**: ARCH-023
**Target Source File(s)**: `tests/evals/test_architecture_design_eval.py`

#### Algorithmic / Logic View

```pseudocode
FUNCTION evaluate_architecture_output(
    arch_design_content: String,
    quality_thresholds: Object
) -> EvaluationResult:

    scores = {
        structural:   0.0,
        coverage:     0.0,
        completeness: 0.0
    }
    details = []

    // Structural score: check mandatory views
    structural_result = verify_structural_compliance(arch_design_content)
    IF structural_result.all_views_present:
        scores.structural = 1.0
    ELSE:
        scores.structural = structural_result.present_count / 4.0
        FOR EACH missing IN structural_result.missing_views:
            details.append(format("STRUCTURAL_FAILURE: Missing %s", missing))

    // Coverage score: check ARCH→SYS traceability
    arch_count = count_pattern(arch_design_content, /ARCH-[0-9]{3}/)
    parent_fields = count_pattern(arch_design_content, /Parent System Components/)
    IF arch_count > 0:
        fields_with_content = count_non_empty_parent_fields(arch_design_content)
        scores.coverage = fields_with_content / arch_count
    ELSE:
        scores.coverage = 0.0
        details.append("No ARCH modules found")

    // Completeness score: check view content quality
    has_mermaid = arch_design_content contains "sequenceDiagram"
    has_contracts = arch_design_content contains "| Direction |"
    has_data_flow = arch_design_content contains "| Stage |"

    completeness_checks = [has_mermaid, has_contracts, has_data_flow]
    scores.completeness = sum(completeness_checks) / completeness_checks.length

    overall_pass = (
        scores.structural >= quality_thresholds.structural AND
        scores.coverage >= quality_thresholds.coverage AND
        scores.completeness >= quality_thresholds.completeness
    )

    RETURN {
        pass:    overall_pass,
        scores:  scores,
        details: details
    }
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| scores | Object | {structural, coverage, completeness} each 0.0..1.0 | All 0.0 | Quality scores per category |
| details | Array<String> | 0..50 | Empty array | Detailed failure messages |
| completeness_checks | Array<Boolean> | 3 entries | Evaluated | Per-check completeness results |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Mandatory views absent | STRUCTURAL_FAILURE | ARCH-023: Missing view name | Record in details, reduce structural score |
| No ARCH modules found | — | ARCH-023: coverage = 0 | Record in details, continue evaluation |

---

### Module: MOD-037 (Verify Structural Compliance)

**Parent Architecture Modules**: ARCH-023
**Target Source File(s)**: `tests/evals/test_architecture_design_eval.py`

#### Algorithmic / Logic View

```pseudocode
FUNCTION verify_structural_compliance(arch_design_content: String) -> StructuralResult:
    mandatory_views = [
        {name: "Logical View",    pattern: /##\s+Logical View/},
        {name: "Process View",    pattern: /##\s+Process View/},
        {name: "Interface View",  pattern: /##\s+Interface View/},
        {name: "Data Flow View",  pattern: /##\s+Data Flow View/}
    ]

    present_views = []
    missing_views = []

    FOR EACH view IN mandatory_views:
        IF arch_design_content matches view.pattern:
            present_views.append(view.name)
        ELSE:
            missing_views.append(view.name)

    RETURN {
        all_views_present: missing_views.length == 0,
        present_count:     present_views.length,
        present_views:     present_views,
        missing_views:     missing_views
    }
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| mandatory_views | Array<{name, pattern}> | 4 entries (fixed) | Constant | Required IEEE 42010 view definitions |
| present_views | Array<String> | 0..4 | Empty array | Views found in content |
| missing_views | Array<String> | 0..4 | Empty array | Views not found in content |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| One or more views missing | — | ARCH-023: STRUCTURAL_FAILURE | Return result with missing_views populated |

---

### Module: MOD-038 (Evaluate Integration Test Output)

**Parent Architecture Modules**: ARCH-024
**Target Source File(s)**: `tests/evals/test_integration_test_eval.py`

#### Algorithmic / Logic View

```pseudocode
FUNCTION evaluate_integration_test_output(
    integration_test_content: String,
    quality_thresholds: Object
) -> EvaluationResult:

    scores = {
        structural: 0.0,
        coverage:   0.0,
        technique:  0.0,
        bdd:        0.0
    }
    details = []

    // Structural: ITP/ITS hierarchy present
    hierarchy_result = verify_itp_its_hierarchy(integration_test_content)
    IF hierarchy_result.valid:
        scores.structural = 1.0
    ELSE:
        scores.structural = hierarchy_result.score
        FOR EACH issue IN hierarchy_result.issues:
            details.append(format("STRUCTURAL_FAILURE: %s", issue))

    // Coverage: check test harness definitions
    has_harness = integration_test_content matches /Test Harness/i
    has_mocking = integration_test_content matches /Mock(ing)?\s+Strategy/i
    scores.coverage = (bool_to_int(has_harness) + bool_to_int(has_mocking)) / 2.0

    // Technique: all four ISO 29119-4 techniques assigned
    techniques_found = {
        interface_contract: integration_test_content matches /Interface Contract Testing/,
        data_flow:          integration_test_content matches /Data Flow Testing/,
        fault_injection:    integration_test_content matches /Interface Fault Injection/,
        concurrency:        integration_test_content matches /Concurrency.*Race Condition Testing/
    }
    technique_count = count_true(techniques_found)
    scores.technique = technique_count / 4.0

    // BDD: Given/When/Then format
    given_count = count_pattern(integration_test_content, /Given\s/)
    when_count = count_pattern(integration_test_content, /When\s/)
    then_count = count_pattern(integration_test_content, /Then\s/)
    IF given_count > 0 AND when_count > 0 AND then_count > 0:
        scores.bdd = 1.0
    ELSE:
        scores.bdd = 0.0
        details.append("BDD format incomplete — missing Given/When/Then")

    overall_pass = (
        scores.structural >= quality_thresholds.structural AND
        scores.coverage >= quality_thresholds.coverage AND
        scores.technique >= quality_thresholds.technique AND
        scores.bdd >= quality_thresholds.bdd
    )

    RETURN {pass: overall_pass, scores: scores, details: details}
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| scores | Object | {structural, coverage, technique, bdd} each 0.0..1.0 | All 0.0 | Quality scores per category |
| details | Array<String> | 0..50 | Empty array | Detailed failure messages |
| techniques_found | Dict<String, Boolean> | 4 entries (fixed) | Checked | Presence of each ISO 29119-4 technique |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| ITP/ITS hierarchy malformed | STRUCTURAL_FAILURE | ARCH-024: Missing section | Record in details, reduce structural score |
| Missing BDD keywords | — | ARCH-024: bdd score = 0 | Record in details, continue evaluation |

---

### Module: MOD-039 (Verify ITP/ITS Hierarchy)

**Parent Architecture Modules**: ARCH-024
**Target Source File(s)**: `tests/evals/test_integration_test_eval.py`

#### Algorithmic / Logic View

```pseudocode
FUNCTION verify_itp_its_hierarchy(integration_test_content: String) -> HierarchyResult:
    itp_pattern = /ITP-[0-9]{3}-[A-Z]/
    its_pattern = /ITS-[0-9]{3}-[A-Z][0-9]+/

    itp_ids = find_all_unique(integration_test_content, itp_pattern)
    its_ids = find_all_unique(integration_test_content, its_pattern)

    issues = []

    IF itp_ids.length == 0:
        issues.append("No ITP identifiers found")

    IF its_ids.length == 0:
        issues.append("No ITS identifiers found")

    // Verify each ITS traces to a valid ITP
    orphaned_its = []
    FOR EACH its IN its_ids:
        its_prefix = extract_its_itp_prefix(its)
        parent_itp = "ITP-" + its_prefix
        IF parent_itp NOT IN itp_ids:
            orphaned_its.append(its)

    IF orphaned_its.length > 0:
        issues.append(format("Orphaned ITS (no parent ITP): %s", join(orphaned_its, ", ")))

    // Verify each ITP has at least one ITS
    itps_without_its = []
    FOR EACH itp IN itp_ids:
        itp_suffix = extract_itp_suffix(itp)
        has_its = false
        FOR EACH its IN its_ids:
            IF its starts_with "ITS-" + itp_suffix:
                has_its = true
                BREAK
        IF NOT has_its:
            itps_without_its.append(itp)

    IF itps_without_its.length > 0:
        issues.append(format("ITP without scenarios: %s", join(itps_without_its, ", ")))

    // Check technique assignment
    FOR EACH itp IN itp_ids:
        itp_section = extract_section_for_itp(integration_test_content, itp)
        IF itp_section IS NOT NULL:
            has_technique = itp_section matches /Technique:\s*\S+/
            IF NOT has_technique:
                issues.append(format("%s missing technique assignment", itp))

    score = 1.0 - (issues.length * 0.1)
    IF score < 0.0:
        score = 0.0

    RETURN {
        valid:  issues.length == 0,
        score:  score,
        issues: issues
    }
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| itp_ids | Array<String> | 0..500 | Extracted and deduplicated | Unique ITP identifiers found |
| its_ids | Array<String> | 0..1000 | Extracted and deduplicated | Unique ITS identifiers found |
| orphaned_its | Array<String> | 0..200 | Filtered | ITS entries with no matching ITP parent |
| itps_without_its | Array<String> | 0..200 | Filtered | ITP entries with no child ITS scenarios |
| issues | Array<String> | 0..100 | Empty array | Validation issues found |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| No ITP identifiers | — | ARCH-024: STRUCTURAL_FAILURE | Add to issues, reduce score |
| Orphaned ITS entries | — | ARCH-024: Hierarchy element issue | Add to issues list |

---

### Module: MOD-040 (Validate Mermaid Blocks)

**Parent Architecture Modules**: ARCH-025
**Target Source File(s)**: `tests/evals/test_architecture_design_eval.py`

#### Algorithmic / Logic View

```pseudocode
FUNCTION validate_mermaid_blocks(mermaid_blocks: Array<String>) -> Array<ValidationResult>:
    results = []

    FOR EACH block_index, block IN enumerate(mermaid_blocks):
        errors = []

        IF NOT block.trim() starts_with "sequenceDiagram":
            errors.append("Block does not start with 'sequenceDiagram'")

        lines = block.split("\n")
        participants = []
        in_diagram = false

        FOR EACH line IN lines:
            trimmed = line.trim()
            IF trimmed == "sequenceDiagram":
                in_diagram = true
                CONTINUE

            IF NOT in_diagram:
                CONTINUE

            IF trimmed starts_with "participant ":
                parts = trimmed.split(" as ")
                IF parts.length < 1:
                    errors.append(format("Malformed participant: %s", trimmed))
                ELSE:
                    alias = parts[0].replace("participant ", "").trim()
                    participants.append(alias)

            ELSE IF trimmed matches /\S+->>-?\S+:/:
                // Message line: verify source and target exist
                message_parts = parse_message_line(trimmed)
                IF message_parts.source NOT IN participants:
                    errors.append(format("Unknown source participant: %s", message_parts.source))
                IF message_parts.target NOT IN participants:
                    errors.append(format("Unknown target participant: %s", message_parts.target))

            ELSE IF trimmed starts_with "Note over":
                CONTINUE

            ELSE IF trimmed starts_with "alt " OR trimmed == "else" OR trimmed == "end":
                CONTINUE

            ELSE IF trimmed.length > 0 AND NOT trimmed starts_with "//":
                errors.append(format("Unrecognized Mermaid syntax: %s", trimmed))

        results.append({
            block_index: block_index,
            valid:       errors.length == 0,
            errors:      errors
        })

    RETURN results
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| results | Array<ValidationResult> | 1..20 | Empty array | Per-block validation results |
| errors | Array<String> | 0..50 per block | Empty per block | Syntax errors in current block |
| participants | Array<String> | 0..30 per block | Empty per block | Declared participant aliases |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Block with syntax errors | SYNTAX_FAILURE | ARCH-025: Block index + error description | Record errors, mark block invalid |
| No mermaid blocks provided | — | ARCH-025: At least one block expected | Return empty results array |

---

### Module: MOD-041 (Discover Domain Overlay)

**Parent Architecture Modules**: ARCH-026
**Target Source File(s)**: `commands/architecture-design.md, commands/integration-test.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION discover_domain_overlay(
    config_path: String,
    command_name: String,
    repo_root: String
) -> OverlayPaths:

    command_overlay_path = NULL
    template_overlay_path = NULL

    IF NOT file_exists(config_path):
        RETURN {command_overlay_path: NULL, template_overlay_path: NULL}

    config_content = read_file(config_path)

    TRY:
        config = parse_yaml(config_content)
    CATCH yaml_error:
        EMIT CONFIG_PARSE_ERROR(yaml_error.message)
        RETURN {command_overlay_path: NULL, template_overlay_path: NULL}

    domain = config.get("domain", NULL)
    IF domain IS NULL OR domain.trim() IS empty:
        RETURN {command_overlay_path: NULL, template_overlay_path: NULL}

    cmd_path = format("%s/commands/overlays/%s/%s.md", repo_root, domain, command_name)
    IF file_exists(cmd_path):
        command_overlay_path = cmd_path

    tpl_name = command_name + "-template"
    tpl_path = format("%s/templates/overlays/%s/%s.md", repo_root, domain, tpl_name)
    IF file_exists(tpl_path):
        template_overlay_path = tpl_path

    RETURN {
        command_overlay_path:  command_overlay_path,
        template_overlay_path: template_overlay_path
    }
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| config | Object | YAML document | Parsed from config_path | v-model-config.yml content |
| domain | String or NULL | 0..50 chars | From config.domain | Configured domain value |
| cmd_path | String | File system path | Constructed | Path to command overlay file |
| tpl_path | String | File system path | Constructed | Path to template overlay file |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Config file missing | — | ARCH-026: Return nulls | No domain configured |
| Config file malformed YAML | CONFIG_PARSE_ERROR | ARCH-026: Parse error description | Emit warning, return nulls |
| Overlay file not found | — | ARCH-026: null with warning logged | Return null for that path |

---

### Module: MOD-042 (Identify Merge Points)

**Parent Architecture Modules**: ARCH-027
**Target Source File(s)**: `commands/architecture-design.md, commands/integration-test.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION identify_merge_points(base_template_content: String) -> Array<MergePoint>:
    merge_points = []
    lines = base_template_content.split("\n")

    FOR EACH line_num, line IN enumerate(lines):
        IF line matches /<!--\s*SAFETY-CRITICAL\s+SECTION.*-->/:
            merge_points.append({
                line_number: line_num,
                marker:      line.trim(),
                type:        "safety_critical"
            })
        ELSE IF line matches /<!--\s*DOMAIN\s+OVERLAY.*-->/:
            merge_points.append({
                line_number: line_num,
                marker:      line.trim(),
                type:        "domain_overlay"
            })

    RETURN merge_points
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| merge_points | Array<MergePoint> | 0..20 | Empty array | Located merge point markers |
| line_num | Integer | 0..5000 | Per line | Current line number in template |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| No merge points found | — | ARCH-027: Warning logged | Return empty array — no overlay sections inserted |

---

### Module: MOD-043 (Merge Overlay Content)

**Parent Architecture Modules**: ARCH-027
**Target Source File(s)**: `commands/architecture-design.md, commands/integration-test.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION merge_overlay_content(
    base_template_content: String,
    overlay_content: String,
    merge_points: Array<MergePoint>
) -> String:

    IF merge_points.length == 0:
        EMIT MERGE_POINT_NOT_FOUND("No merge points in base template")
        RETURN base_template_content

    overlay_sections = parse_overlay_sections(overlay_content)
    base_lines = base_template_content.split("\n")
    result_lines = []
    inserted_sections = {}

    FOR EACH line_index, line IN enumerate(base_lines):
        merge_point = find_merge_point(merge_points, line_index)

        IF merge_point IS NOT NULL:
            matching_section = find_matching_overlay_section(overlay_sections, merge_point.type)
            IF matching_section IS NOT NULL:
                result_lines.append(line)
                result_lines.append("")
                FOR EACH overlay_line IN matching_section.content.split("\n"):
                    result_lines.append(overlay_line)
                result_lines.append("")
                inserted_sections[merge_point.type] = true
            ELSE:
                EMIT MERGE_POINT_NOT_FOUND(format("No overlay section for merge point type: %s", merge_point.type))
                result_lines.append(line)
        ELSE:
            result_lines.append(line)

    FOR EACH section IN overlay_sections:
        IF section.type NOT IN inserted_sections:
            EMIT MERGE_POINT_NOT_FOUND(format("Overlay section '%s' has no matching merge point", section.type))

    RETURN join(result_lines, "\n")

FUNCTION parse_overlay_sections(overlay_content: String) -> Array<OverlaySection>:
    sections = []
    current_section = NULL

    FOR EACH line IN overlay_content.split("\n"):
        IF line matches /^##\s+(.+)/:
            IF current_section IS NOT NULL:
                sections.append(current_section)
            current_section = {
                type:    classify_section_type(match.group(1)),
                title:   match.group(1),
                content: ""
            }
        ELSE IF current_section IS NOT NULL:
            current_section.content += line + "\n"

    IF current_section IS NOT NULL:
        sections.append(current_section)

    RETURN sections
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| overlay_sections | Array<OverlaySection> | 0..10 | Parsed from overlay | Parsed overlay content sections |
| result_lines | Array<String> | 0..10000 | Empty array | Assembled output lines |
| inserted_sections | Dict<String, Boolean> | 0..10 | Empty dict | Tracks which sections were inserted |
| current_section | OverlaySection or NULL | {type, title, content} | NULL | Section being built during parsing |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| No merge points in base | MERGE_POINT_NOT_FOUND | ARCH-027: Warning | Return base unmodified |
| Overlay section without matching merge point | MERGE_POINT_NOT_FOUND | ARCH-027: Overlay section name | Emit warning, skip section |

---

### Module: MOD-044 (Get ID Pattern) [CROSS-CUTTING]

**Parent Architecture Modules**: ARCH-028
**Target Source File(s)**: `scripts/bash/validate-architecture-coverage.sh, scripts/bash/build-matrix.sh, scripts/powershell/validate-architecture-coverage.ps1, scripts/powershell/build-matrix.ps1`

#### Algorithmic / Logic View

```pseudocode
FUNCTION get_id_pattern(pattern_request: String) -> Regex:
    patterns = {
        "SYS":  compile_regex("SYS-[0-9]{3}"),
        "ARCH": compile_regex("ARCH-[0-9]{3}"),
        "ITP":  compile_regex("ITP-[0-9]{3}-[A-Z]"),
        "ITS":  compile_regex("ITS-[0-9]{3}-[A-Z][0-9]+"),
        "REQ":  compile_regex("REQ-[A-Z0-9-]+")
    }

    IF pattern_request NOT IN patterns:
        RAISE UNKNOWN_PATTERN(pattern_request)

    RETURN patterns[pattern_request]
```

In Bash implementation:

```pseudocode
// Bash: patterns defined as shell variables
SYS_PATTERN="SYS-[0-9]{3}"
ARCH_PATTERN="ARCH-[0-9]{3}"
ITP_PATTERN="ITP-[0-9]{3}-[A-Z]"
ITS_PATTERN="ITS-[0-9]{3}-[A-Z][0-9]+"
REQ_PATTERN="REQ-[A-Z0-9-]+"

// Usage: grep -oE "$SYS_PATTERN" file.md
```

In PowerShell implementation:

```pseudocode
// PowerShell: patterns defined as script-scope regex objects
$SysPattern  = [regex]"SYS-[0-9]{3}"
$ArchPattern = [regex]"ARCH-[0-9]{3}"
$ItpPattern  = [regex]"ITP-[0-9]{3}-[A-Z]"
$ItsPattern  = [regex]"ITS-[0-9]{3}-[A-Z][0-9]+"
$ReqPattern  = [regex]"REQ-[A-Z0-9-]+"

// Usage: [regex]::Matches($content, $ArchPattern)
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| patterns | Dict<String, Regex> | 5 entries (fixed) | Compiled at load time | Maps pattern name to compiled POSIX ERE regex |
| SYS_PATTERN | String (Bash) / Regex (PowerShell) | 13 chars | Constant | Matches SYS-NNN identifiers |
| ARCH_PATTERN | String (Bash) / Regex (PowerShell) | 14 chars | Constant | Matches ARCH-NNN identifiers |
| ITP_PATTERN | String (Bash) / Regex (PowerShell) | 19 chars | Constant | Matches ITP-NNN-X identifiers |
| ITS_PATTERN | String (Bash) / Regex (PowerShell) | 23 chars | Constant | Matches ITS-NNN-X# identifiers |
| REQ_PATTERN | String (Bash) / Regex (PowerShell) | 15 chars | Constant | Matches REQ-XXX identifiers |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Unknown pattern name requested | UNKNOWN_PATTERN | ARCH-028: Pattern name | Raise error — caller passed unsupported pattern type |

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Module Designs (MOD) | 44 (44 active, 0 deprecated, 0 suspect) |
| External Modules (`[EXTERNAL]`) | 0 |
| Cross-Cutting Modules (`[CROSS-CUTTING]`) | 1 (MOD-044) |
| Stateful Modules | 0 |
| Stateless Modules | 44 |
| Total Parent Architecture Modules Covered | 28 / 28 (100%) |
| Modules with Pseudocode | 44 / 44 (100%) |
| **Forward Coverage (ARCH→MOD)** | **100%** |

## Derived Modules

None — all modules trace to existing architecture modules.
