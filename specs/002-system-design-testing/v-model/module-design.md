# Module Design: System Design ↔ System Testing

**Feature Branch**: `002-system-design-testing`
**Created**: 2026-02-20
**Status**: Draft
**Source**: `specs/002-system-design-testing/v-model/architecture-design.md`

## Overview

This module design decomposes the 17 architecture modules into 18 implementable low-level modules. The System Design Command (ARCH-001) maps 1:1 to a prompt-generation module (MOD-001). The System Design Template (ARCH-002) maps 1:1 to a template definition module (MOD-002). The System Test Command (ARCH-003) maps 1:1 to a prompt-generation module (MOD-003). The System Test Template (ARCH-004) maps 1:1 to a template definition module (MOD-004). The Bash validation script (ARCH-005 through ARCH-008) decomposes into 5 modules: a forward coverage validator (MOD-005), a backward coverage validator (MOD-006), an orphan detector (MOD-007), a CLI argument parser and orchestrator (MOD-008), and an output formatter (MOD-009). The PowerShell validation script (ARCH-009) maps 1:1 mirroring Bash logic (MOD-010). The Bash matrix builder (ARCH-010/ARCH-011) decomposes into an ID extractor (MOD-011) and a Matrix B table builder (MOD-012). The PowerShell matrix builder (ARCH-012) maps 1:1 (MOD-013). The trace command extension (ARCH-013), ID pattern registration (ARCH-014), extension manifest (ARCH-015), CI evaluation config (ARCH-016), and backward compatibility enforcement (ARCH-017) each map 1:1 to MOD-014 through MOD-018 respectively. All modules are stateless. Each module specification includes four mandatory views: Algorithmic/Logic (with pseudocode), State Machine (bypass for stateless modules), Internal Data Structures, and Error Handling & Return Codes. No safety-critical sections are included because no `v-model-config.yml` domain is configured.

## ID Schema

- **Module Design**: `MOD-NNN` — sequential identifier for each module (3-digit zero-padded)
- **Parent Architecture Modules**: Comma-separated `ARCH-NNN` list per module (many-to-many, authoritative for traceability)
- **Target Source File(s)**: Comma-separated file paths mapping to the repository codebase
- Example: `MOD-005` with Parent Architecture Modules `ARCH-005` — module implements the forward coverage validation function within the Bash validation script

## Module Designs

### Module: MOD-001 (System Design Command Prompt)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `commands/system-design.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION system_design_command(user_input: String) -> File:
    // Step 1: Run setup script and parse JSON
    setup_result = RUN("setup-v-model.sh --json --require-reqs")
    config = PARSE_JSON(setup_result)
    VMODEL_DIR = config.VMODEL_DIR
    REQUIREMENTS = config.REQUIREMENTS
    AVAILABLE_DOCS = config.AVAILABLE_DOCS

    // Step 2: Load template
    template = READ_FILE("templates/system-design-template.md")

    // Step 3: Load requirements and extract REQ IDs
    req_content = READ_FILE(REQUIREMENTS)
    req_ids = REGEX_EXTRACT_ALL(req_content, "REQ-[0-9]{3}")
    req_nf_ids = REGEX_EXTRACT_ALL(req_content, "REQ-(NF|CN|IF)-[0-9]{3}")
    all_req_ids = UNION(req_ids, req_nf_ids)
    req_entries = []
    FOR EACH row IN parse_markdown_table(req_content, "Requirements"):
        req_entries.APPEND({id: row.ID, description: row.Description, priority: row.Priority, type: classify_req_type(row.ID)})

    // Step 4: Check for domain overlay
    domain = NULL
    IF FILE_EXISTS("v-model-config.yml"):
        config_yaml = PARSE_YAML(READ_FILE("v-model-config.yml"))
        domain = config_yaml.domain OR NULL
    IF domain IS NOT NULL:
        overlay_path = "commands/overlays/" + domain + "/system-design.md"
        IF FILE_EXISTS(overlay_path):
            overlay_content = READ_FILE(overlay_path)

    // Step 5: Check for existing system-design.md (append mode)
    existing_sys_ids = []
    highest_sys_num = 0
    IF "system-design.md" IN AVAILABLE_DOCS:
        existing_content = READ_FILE(VMODEL_DIR + "/system-design.md")
        existing_sys_ids = REGEX_EXTRACT_ALL(existing_content, "SYS-[0-9]{3}")
        FOR EACH id IN existing_sys_ids:
            num = PARSE_INT(id[4:7])
            IF num > highest_sys_num:
                highest_sys_num = num

    // Step 6: Decompose requirements into SYS components
    next_sys_num = highest_sys_num + 1
    sys_components = []
    derived_requirements = []
    FOR EACH logical_group IN group_requirements_by_capability(req_entries):
        IF logical_group.requires_derived_capability:
            derived_requirements.APPEND("[DERIVED REQUIREMENT: " + logical_group.description + "]")
            CONTINUE
        sys_id = FORMAT("SYS-%03d", next_sys_num)
        next_sys_num = next_sys_num + 1
        component = {
            id: sys_id,
            name: logical_group.name,
            description: logical_group.description,
            parent_reqs: logical_group.req_ids,
            type: determine_component_type(logical_group)
        }
        sys_components.APPEND(component)

    // Step 7: Build four IEEE 1016 views
    decomposition_view = build_decomposition_table(sys_components)
    dependency_view = build_dependency_table(sys_components)
    interface_view = build_interface_contracts(sys_components)
    data_design_view = build_data_design(sys_components)

    // Step 8: Build coverage summary
    covered_reqs = SET()
    FOR EACH comp IN sys_components:
        FOR EACH req IN comp.parent_reqs:
            covered_reqs.ADD(req)
    coverage_pct = (SIZE(covered_reqs) * 100) / SIZE(all_req_ids)

    // Step 9: Assemble output using template structure
    output = render_template(template, {
        decomposition: decomposition_view,
        dependency: dependency_view,
        interface: interface_view,
        data_design: data_design_view,
        coverage: coverage_pct,
        derived: derived_requirements,
        overlay: overlay_content IF domain ELSE NULL
    })

    // Step 10: Write output
    WRITE_FILE(VMODEL_DIR + "/system-design.md", output)
    RETURN output
```

#### State Machine View

N/A — Stateless: single-execution prompt with no retained state between invocations.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| setup_result | String | Unbounded (typically <2 KB) | Set from script stdout | Raw JSON output from setup-v-model.sh |
| config | Dict[String, Any] | 15 keys max | Parsed from setup_result | Structured setup configuration |
| req_content | String | Unbounded (supports 200+ REQ IDs) | Read from requirements.md | Raw markdown content of requirements file |
| all_req_ids | Set[String] | Max ~500 IDs; each matches `REQ-[0-9]{3}` or `REQ-(NF\|CN\|IF)-[0-9]{3}` | Extracted via regex | Union of all requirement ID patterns |
| req_entries | List[Dict] | One entry per REQ; fields: id, description, priority, type | Parsed from markdown table rows | Structured requirement data for decomposition |
| domain | String or NULL | One of: "iso_26262", "do_178c", "iec_62304", or NULL | Read from v-model-config.yml | Domain overlay selector |
| overlay_content | String or NULL | Unbounded | Read from overlay file or NULL | Domain-specific safety-critical content |
| existing_sys_ids | List[String] | Each matches `SYS-[0-9]{3}` | Extracted from existing system-design.md | Existing SYS IDs to preserve in append mode |
| highest_sys_num | Integer | 0–999 | 0 (or max from existing IDs) | Tracks the highest SYS number for sequential assignment |
| sys_components | List[Dict] | One per component; fields: id, name, description, parent_reqs, type | Built during decomposition | Generated SYS component specifications |
| derived_requirements | List[String] | 0 or more flagged strings | Empty list | Capabilities not in requirements flagged as [DERIVED REQUIREMENT] |
| coverage_pct | Integer | 0–100 | Computed from covered_reqs / all_req_ids | Forward coverage percentage |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| requirements.md not found | Fatal error message: "requirements.md not found. Run `/speckit.v-model.requirements` first." | ARCH-001 Interface: Missing prerequisite exception | Abort — user must generate prerequisites first |
| Setup script returns non-zero exit code | Fatal error with script stderr | ARCH-001 Interface: File not found error | Abort — report setup failure to user |
| v-model-config.yml parse error | Warning, proceed without domain | ARCH-001 Interface: Optional domain input | Skip domain overlay, generate generic output |
| Domain overlay file not found (when domain configured) | Warning: "Domain overlay not found for {domain}" | ARCH-001 Interface: Optional domain overlay | Skip overlay, generate generic output |
| Zero REQ IDs extracted | Fatal error: "No requirement identifiers found in requirements.md" | ARCH-001 Interface: Input format constraint | Abort — malformed input |

---

### Module: MOD-002 (System Design Template Definition)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `templates/system-design-template.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION system_design_template() -> TemplateStructure:
    // The template is a static markdown file defining IEEE 1016 output structure.

    // Step 1: Define header section
    header = {
        title: "System Design: [FEATURE NAME]",
        fields: ["Feature Branch", "Created", "Status", "Source"]
    }

    // Step 2: Define Overview section
    overview = SECTION("Overview", placeholder: "[decomposition rationale]")

    // Step 3: Define ID Schema section
    id_schema = SECTION("ID Schema", content: [
        "SYS-NNN — sequential identifier",
        "Parent Requirements — comma-separated REQ-NNN list"
    ])

    // Step 4: Define Decomposition View table
    decomposition = TABLE(columns: [
        "SYS ID", "Name", "Description", "Parent Requirements", "Type"
    ])

    // Step 5: Define Dependency View
    dependency = TABLE(columns: [
        "Source", "Target", "Relationship", "Failure Impact"
    ])
    dependency_diagram = MERMAID_BLOCK("graph TD")

    // Step 6: Define Interface View (External + Internal)
    interface_external = TABLE(columns: [
        "Direction", "Name", "Type", "Format", "Constraints"
    ])
    interface_internal = TABLE(columns: [
        "Direction", "Name", "Type", "Format", "Constraints"
    ])

    // Step 7: Define Data Design View
    data_design = TABLE(columns: [
        "Entity", "Component", "Storage", "Protection", "Retention"
    ])

    // Step 8: Define Coverage Summary
    coverage = TABLE(columns: ["Metric", "Count"])

    // Step 9: Define Derived Requirements section
    derived = SECTION("Derived Requirements", placeholder: "[list or None]")

    // Step 10: Define Glossary
    glossary = TABLE(columns: ["Term", "Definition"])

    RETURN TemplateStructure(header, overview, id_schema, decomposition,
        dependency, interface_external, interface_internal, data_design,
        coverage, derived, glossary)
```

#### State Machine View

N/A — Stateless: static template file with no runtime behavior.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| header | MarkdownSection | 5 fields (title + 4 metadata) | Static content | Document metadata block |
| decomposition_table | MarkdownTable | 5 columns; rows unbounded | Column headers only | Decomposition View table with SYS ID, Name, Description, Parent Requirements, Type |
| dependency_table | MarkdownTable | 4 columns; rows unbounded | Column headers only | Dependency View table with Source, Target, Relationship, Failure Impact |
| interface_tables | MarkdownTable × 2 | 5 columns each; rows unbounded | Column headers only | External and Internal interface contract tables |
| data_design_table | MarkdownTable | 5 columns; rows unbounded | Column headers only | Data Design View table with Entity, Component, Storage, Protection, Retention |
| coverage_table | MarkdownTable | 2 columns; ~8 metric rows | Column headers only | Coverage Summary metrics |
| glossary_table | MarkdownTable | 2 columns; rows unbounded | Column headers only | Term definitions |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Template file not found | File read error | ARCH-002 Interface: Template must exist in `templates/` directory | Fatal — extension installation is incomplete |
| Template file malformed (missing section markers) | Parse error during template load | ARCH-002 Interface: Template structure output | Degrade gracefully — use minimal section headings |

---

### Module: MOD-003 (System Test Command Prompt)

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `commands/system-test.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION system_test_command(user_input: String) -> File:
    // Step 1: Run setup script and parse JSON
    setup_result = RUN("setup-v-model.sh --json --require-reqs --require-system-design")
    config = PARSE_JSON(setup_result)
    VMODEL_DIR = config.VMODEL_DIR
    SYSTEM_DESIGN = config.SYSTEM_DESIGN
    AVAILABLE_DOCS = config.AVAILABLE_DOCS

    // Step 2: Load template
    template = READ_FILE("templates/system-test-template.md")

    // Step 3: Load system-design.md and extract SYS components
    sys_content = READ_FILE(SYSTEM_DESIGN)
    sys_ids = REGEX_EXTRACT_ALL(sys_content, "SYS-[0-9]{3}")
    sys_entries = []
    FOR EACH row IN parse_decomposition_view(sys_content):
        sys_entries.APPEND({
            id: row.SYS_ID,
            name: row.Name,
            description: row.Description,
            parent_reqs: row.Parent_Requirements,
            type: row.Type
        })

    // Step 4: Extract IEEE 1016 views for each SYS
    dependency_data = parse_dependency_view(sys_content)
    interface_data = parse_interface_view(sys_content)
    data_design_data = parse_data_design_view(sys_content)

    // Step 5: Check for domain overlay
    domain = NULL
    IF FILE_EXISTS("v-model-config.yml"):
        config_yaml = PARSE_YAML(READ_FILE("v-model-config.yml"))
        domain = config_yaml.domain OR NULL
    IF domain IS NOT NULL:
        overlay_path = "commands/overlays/" + domain + "/system-test.md"
        IF FILE_EXISTS(overlay_path):
            overlay_content = READ_FILE(overlay_path)

    // Step 6: Check for existing system-test.md (append mode)
    existing_stp_ids = []
    existing_sts_ids = []
    IF "system-test.md" IN AVAILABLE_DOCS:
        existing_content = READ_FILE(VMODEL_DIR + "/system-test.md")
        existing_stp_ids = REGEX_EXTRACT_ALL(existing_content, "STP-[0-9]{3}-[A-Z]")
        existing_sts_ids = REGEX_EXTRACT_ALL(existing_content, "STS-[0-9]{3}-[A-Z][0-9]+")

    // Step 7: Generate STP test cases per SYS component
    test_cases = []
    FOR EACH sys_entry IN sys_entries:
        nnn = sys_entry.id[4:7]
        letter = 'A'

        // Interface Contract test case (from Interface View)
        IF sys_entry.id IN interface_data:
            stp_id = FORMAT("STP-%s-%c", nnn, letter)
            interface_type = determine_interface_type(interface_data[sys_entry.id])
            test_cases.APPEND({
                id: stp_id,
                name: sys_entry.name + " Interface Contract",
                parent_sys: sys_entry.id,
                view: "Interface",
                technique: "Interface Contract Testing",
                interface_type: interface_type
            })
            letter = NEXT_LETTER(letter)

        // Boundary Value / Equivalence Partitioning test case
        stp_id = FORMAT("STP-%s-%c", nnn, letter)
        test_cases.APPEND({
            id: stp_id,
            name: sys_entry.name + " Boundary Analysis",
            parent_sys: sys_entry.id,
            view: "Data Design",
            technique: "Boundary Value Analysis / Equivalence Partitioning",
            interface_type: "N/A"
        })
        letter = NEXT_LETTER(letter)

        // Fault Injection test case (from Dependency View)
        IF sys_entry.id IN dependency_data:
            stp_id = FORMAT("STP-%s-%c", nnn, letter)
            test_cases.APPEND({
                id: stp_id,
                name: sys_entry.name + " Fault Injection",
                parent_sys: sys_entry.id,
                view: "Dependency",
                technique: "Fault Injection / Negative Testing",
                interface_type: "N/A"
            })

    // Step 8: Generate STS scenarios per STP
    test_scenarios = []
    FOR EACH tc IN test_cases:
        scenario_num = 1
        sts_id = FORMAT("STS-%s-%c%d", tc.id[4:7], tc.id[8], scenario_num)
        test_scenarios.APPEND({
            id: sts_id,
            parent_stp: tc.id,
            given: generate_given(tc),
            when: generate_when(tc),
            then: generate_then(tc)
        })

    // Step 9: Assemble output using template
    output = render_template(template, {
        test_cases: test_cases,
        test_scenarios: test_scenarios,
        overlay: overlay_content IF domain ELSE NULL
    })

    // Step 10: Write output
    WRITE_FILE(VMODEL_DIR + "/system-test.md", output)

    // Step 11: Run coverage gate
    gate_result = RUN("validate-system-coverage.sh " + VMODEL_DIR)
    APPEND_TO_FILE(VMODEL_DIR + "/system-test.md", format_gate_result(gate_result))

    RETURN output
```

#### State Machine View

N/A — Stateless: single-execution prompt with no retained state between invocations.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| sys_content | String | Unbounded (typically <50 KB) | Read from system-design.md | Raw markdown content of system design |
| sys_ids | List[String] | Each matches `SYS-[0-9]{3}` | Extracted via regex | All system component identifiers |
| sys_entries | List[Dict] | One per SYS; fields: id, name, description, parent_reqs, type | Parsed from Decomposition View | Structured SYS component data |
| dependency_data | Dict[String, List[Dict]] | Keyed by SYS ID | Parsed from Dependency View | Inter-component relationships per SYS |
| interface_data | Dict[String, List[Dict]] | Keyed by SYS ID | Parsed from Interface View | API contracts per SYS component |
| data_design_data | Dict[String, List[Dict]] | Keyed by SYS ID | Parsed from Data Design View | Data structure details per SYS |
| domain | String or NULL | One of: "iso_26262", "do_178c", "iec_62304", or NULL | Read from v-model-config.yml | Domain overlay selector |
| test_cases | List[Dict] | One per STP; fields: id, name, parent_sys, view, technique, interface_type | Built during generation | Generated STP test case specifications |
| test_scenarios | List[Dict] | One per STS; fields: id, parent_stp, given, when, then | Built per test case | Generated STS BDD scenario specifications |
| gate_result | String | Process stdout; includes pass/fail verdict | Set from coverage validation script | Coverage gate validation result |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| system-design.md not found | Fatal error: "system-design.md not found. Run `/speckit.v-model.system-design` first." | ARCH-003 Interface: Missing prerequisite exception | Abort — user must generate prerequisites first |
| Zero SYS IDs extracted | Fatal error: "No system component identifiers found in system-design.md" | ARCH-003 Interface: Input format constraint | Abort — malformed input |
| Domain overlay file not found | Warning: "Domain overlay not found for {domain}" | ARCH-003 Interface: Optional domain overlay | Skip overlay, generate generic output |
| Coverage gate returns non-zero | Warning appended to output: "Coverage gate FAILED — gaps detected" | ARCH-003 Interface: Coverage gate result output | Report failure in output but do not abort |
| Interface View missing for a SYS | Skip Interface Contract test case for that SYS | ARCH-003 Interface: Design view extraction | Generate remaining test techniques |

---

### Module: MOD-004 (System Test Template Definition)

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `templates/system-test-template.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION system_test_template() -> TemplateStructure:
    // Static template defining ISO 29119-compliant test plan structure.

    // Step 1: Define header section
    header = {
        title: "System Test Plan: [FEATURE NAME]",
        fields: ["Feature Branch", "Created", "Status", "Source"]
    }

    // Step 2: Define Overview section
    overview = SECTION("Overview", placeholder: "[test plan rationale]")

    // Step 3: Define ID Schema section
    id_schema = SECTION("ID Schema", content: [
        "STP-NNN-X — test case ID (NNN = parent SYS, X = letter)",
        "STS-NNN-X# — test scenario ID (NNN-X = parent STP, # = number)"
    ])

    // Step 4: Define Test Cases table
    test_cases = TABLE(columns: [
        "STP ID", "Name", "Parent SYS", "IEEE 1016 View",
        "ISO 29119 Technique", "Interface Type"
    ])

    // Step 5: Define Test Scenarios table
    test_scenarios = TABLE(columns: [
        "STS ID", "Parent STP", "Given", "When", "Then"
    ])

    // Step 6: Define Coverage Gate Results section
    coverage_gate = SECTION("Coverage Gate Results",
        placeholder: "[validate-system-coverage.sh output]")

    // Step 7: Define Glossary
    glossary = TABLE(columns: ["Term", "Definition"])

    RETURN TemplateStructure(header, overview, id_schema,
        test_cases, test_scenarios, coverage_gate, glossary)
```

#### State Machine View

N/A — Stateless: static template file with no runtime behavior.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| header | MarkdownSection | 5 fields (title + 4 metadata) | Static content | Document metadata block |
| test_cases_table | MarkdownTable | 6 columns; rows unbounded | Column headers only | STP test case table with ID, Name, Parent SYS, View, Technique, Interface Type |
| test_scenarios_table | MarkdownTable | 5 columns; rows unbounded | Column headers only | STS scenario table with ID, Parent STP, Given, When, Then BDD columns |
| coverage_gate_section | MarkdownSection | Placeholder for script output | Static placeholder | Section for coverage validation results |
| glossary_table | MarkdownTable | 2 columns; rows unbounded | Column headers only | Term definitions |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Template file not found | File read error | ARCH-004 Interface: Template must exist in `templates/` directory | Fatal — extension installation is incomplete |
| Template file malformed | Parse error during template load | ARCH-004 Interface: Template structure output | Degrade gracefully — use minimal section headings |

---

### Module: MOD-005 (Forward Coverage Check)

**Parent Architecture Modules**: ARCH-005
**Target Source File(s)**: `scripts/bash/validate-system-coverage.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION check_forward_coverage(requirements_path: String, system_design_path: String) -> CoverageResult:
    // Extract all REQ IDs from requirements.md
    req_content = READ_FILE(requirements_path)
    req_ids = []
    FOR EACH line IN req_content:
        matches = REGEX_FIND_ALL(line, "REQ-[0-9]{3}")
        nf_matches = REGEX_FIND_ALL(line, "REQ-(NF|CN|IF)-[0-9]{3}")
        req_ids = UNION(req_ids, matches, nf_matches)
    req_ids = UNIQUE(req_ids)

    // Extract Parent Requirements references from system-design.md Decomposition View
    sys_content = READ_FILE(system_design_path)
    covered_reqs = SET()
    in_decomposition = false
    FOR EACH line IN sys_content:
        IF line MATCHES "^## Decomposition":
            in_decomposition = true
            CONTINUE
        IF in_decomposition AND line MATCHES "^## ":
            BREAK
        IF in_decomposition AND line MATCHES table_row_pattern:
            parent_reqs_cell = EXTRACT_COLUMN(line, "Parent Requirements")
            refs = REGEX_FIND_ALL(parent_reqs_cell, "REQ-[0-9]{3}")
            nf_refs = REGEX_FIND_ALL(parent_reqs_cell, "REQ-(NF|CN|IF)-[0-9]{3}")
            covered_reqs = UNION(covered_reqs, refs, nf_refs)

    // Compute uncovered
    uncovered = []
    FOR EACH req IN req_ids:
        IF req NOT IN covered_reqs:
            uncovered.APPEND(req)

    // Calculate percentage
    IF SIZE(req_ids) > 0:
        pct = (SIZE(req_ids) - SIZE(uncovered)) * 100 / SIZE(req_ids)
    ELSE:
        pct = 0

    RETURN {covered: LIST(covered_reqs), uncovered: uncovered, pct: pct}
```

#### State Machine View

N/A — Stateless pure function: takes file paths, returns coverage result.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| req_ids | Array[String] | Each matches `REQ-[0-9]{3}` or `REQ-(NF\|CN\|IF)-[0-9]{3}`; max ~500 | Extracted via regex from requirements.md | Unique set of all requirement identifiers |
| covered_reqs | Associative Array (Set) | Keys are REQ ID strings | Empty; populated during Decomposition View parsing | Set of REQ IDs referenced in system-design.md Parent Requirements column |
| uncovered | Array[String] | Subset of req_ids | Computed as set difference | REQ IDs with no SYS component mapping |
| pct | Integer | 0–100 | Computed from array sizes | Forward coverage percentage (integer division) |
| in_decomposition | Boolean | true/false | false | Section parser state: true while inside Decomposition View table |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| requirements.md not found | File read error (exit 1) | ARCH-005 Interface: File not found error | Caller (ARCH-008) reports error and exits |
| system-design.md not found | File read error (exit 1) | ARCH-005 Interface: File not found error | Caller (ARCH-008) reports error and exits |
| No REQ IDs extracted | Return {covered: [], uncovered: [], pct: 0} | ARCH-005 Interface: Empty result | Return zero coverage — let caller decide severity |
| Decomposition View section not found | Return {covered: [], uncovered: req_ids, pct: 0} | ARCH-005 Interface: Parsing assumption | Return zero covered — all REQs uncovered |

---

### Module: MOD-006 (Backward Coverage Check)

**Parent Architecture Modules**: ARCH-006
**Target Source File(s)**: `scripts/bash/validate-system-coverage.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION check_backward_coverage(system_design_path: String, system_test_path: String) -> CoverageResult:
    // Extract SYS IDs from system-design.md Decomposition View
    sys_content = READ_FILE(system_design_path)
    sys_ids = []
    in_decomposition = false
    FOR EACH line IN sys_content:
        IF line MATCHES "^## Decomposition":
            in_decomposition = true
            CONTINUE
        IF in_decomposition AND line MATCHES "^## ":
            BREAK
        IF in_decomposition AND line MATCHES table_row_pattern:
            match = REGEX_FIND(line, "SYS-[0-9]{3}")
            IF match:
                sys_ids.APPEND(match)

    // Extract STP parent SYS references from system-test.md
    test_content = READ_FILE(system_test_path)
    covered_sys = SET()
    stp_ids = REGEX_FIND_ALL(test_content, "STP-[0-9]{3}-[A-Z]")
    FOR EACH stp IN stp_ids:
        parent_sys = "SYS-" + stp[4:7]
        covered_sys.ADD(parent_sys)

    // Compute uncovered
    uncovered = []
    FOR EACH sys IN sys_ids:
        IF sys NOT IN covered_sys:
            uncovered.APPEND(sys)

    // Calculate percentage
    IF SIZE(sys_ids) > 0:
        pct = (SIZE(sys_ids) - SIZE(uncovered)) * 100 / SIZE(sys_ids)
    ELSE:
        pct = 0

    RETURN {covered: LIST(covered_sys), uncovered: uncovered, pct: pct}
```

#### State Machine View

N/A — Stateless pure function: takes file paths, returns coverage result.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| sys_ids | Array[String] | Each matches `SYS-[0-9]{3}`; max ~200 | Extracted from Decomposition View | All system component identifiers in system-design.md |
| stp_ids | Array[String] | Each matches `STP-[0-9]{3}-[A-Z]` | Extracted via regex from system-test.md | All test case identifiers |
| covered_sys | Associative Array (Set) | Keys are SYS ID strings | Empty; populated from STP ID lineage | Set of SYS IDs that have at least one STP test case |
| uncovered | Array[String] | Subset of sys_ids | Computed as set difference | SYS IDs with no STP test coverage |
| pct | Integer | 0–100 | Computed from array sizes | Backward coverage percentage (integer division) |
| in_decomposition | Boolean | true/false | false | Section parser state: true while inside Decomposition View table |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| system-test.md not found | Skipped entirely in partial mode | ARCH-006 Interface: Skipped when system-test.md absent | Caller (ARCH-008) handles partial mode |
| system-design.md not found | File read error (exit 1) | ARCH-006 Interface: File not found error | Caller (ARCH-008) reports error and exits |
| No SYS IDs extracted | Return {covered: [], uncovered: [], pct: 0} | ARCH-006 Interface: Empty result | Return zero coverage |
| No STP IDs extracted | Return {covered: [], uncovered: sys_ids, pct: 0} | ARCH-006 Interface: No test coverage | All SYS IDs reported as uncovered |

---

### Module: MOD-007 (Orphan Detection)

**Parent Architecture Modules**: ARCH-007
**Target Source File(s)**: `scripts/bash/validate-system-coverage.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION detect_orphans(requirements_path: String, system_design_path: String, system_test_path: String OR NULL) -> OrphanResult:
    // Step 1: Extract valid REQ IDs from requirements.md
    req_content = READ_FILE(requirements_path)
    valid_req_ids = SET()
    FOR EACH line IN req_content:
        matches = REGEX_FIND_ALL(line, "REQ-[0-9]{3}")
        nf_matches = REGEX_FIND_ALL(line, "REQ-(NF|CN|IF)-[0-9]{3}")
        valid_req_ids = UNION(valid_req_ids, matches, nf_matches)

    // Step 2: Extract SYS IDs and their parent REQ references from system-design.md
    sys_content = READ_FILE(system_design_path)
    sys_parent_map = {}
    valid_sys_ids = SET()
    in_decomposition = false
    FOR EACH line IN sys_content:
        IF line MATCHES "^## Decomposition":
            in_decomposition = true
            CONTINUE
        IF in_decomposition AND line MATCHES "^## ":
            BREAK
        IF in_decomposition AND line MATCHES table_row_pattern:
            sys_id = REGEX_FIND(line, "SYS-[0-9]{3}")
            IF sys_id:
                valid_sys_ids.ADD(sys_id)
                parent_reqs_cell = EXTRACT_COLUMN(line, "Parent Requirements")
                parent_reqs = REGEX_FIND_ALL(parent_reqs_cell, "REQ-[0-9]{3}")
                nf_parent_reqs = REGEX_FIND_ALL(parent_reqs_cell, "REQ-(NF|CN|IF)-[0-9]{3}")
                sys_parent_map[sys_id] = UNION(parent_reqs, nf_parent_reqs)

    // Step 3: Detect orphaned SYS (referencing non-existent REQ)
    orphaned_sys = []
    FOR EACH sys_id, parent_reqs IN sys_parent_map:
        FOR EACH req IN parent_reqs:
            IF req NOT IN valid_req_ids:
                orphaned_sys.APPEND(sys_id + ": references non-existent " + req)
                BREAK

    // Step 4: Detect orphaned STP (referencing non-existent SYS)
    orphaned_stp = []
    IF system_test_path IS NOT NULL:
        test_content = READ_FILE(system_test_path)
        stp_ids = REGEX_FIND_ALL(test_content, "STP-[0-9]{3}-[A-Z]")
        FOR EACH stp IN stp_ids:
            parent_sys = "SYS-" + stp[4:7]
            IF parent_sys NOT IN valid_sys_ids:
                orphaned_stp.APPEND(stp + ": parent " + parent_sys + " not found in system-design.md")

    RETURN {orphaned_sys: orphaned_sys, orphaned_stp: orphaned_stp}
```

#### State Machine View

N/A — Stateless pure function: takes file paths, returns orphan detection result.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| valid_req_ids | Associative Array (Set) | Keys are REQ ID strings; max ~500 | Extracted from requirements.md | Set of all valid requirement identifiers |
| valid_sys_ids | Associative Array (Set) | Keys are SYS ID strings; max ~200 | Extracted from Decomposition View | Set of all valid system component identifiers |
| sys_parent_map | Associative Array | Key: SYS ID (String), Value: Array[String] of REQ IDs | Parsed from Decomposition View Parent Requirements column | Maps each SYS to its declared parent REQ IDs |
| orphaned_sys | Array[String] | Each entry is a human-readable explanation | Empty; populated during cross-reference | SYS IDs referencing non-existent REQ parents |
| orphaned_stp | Array[String] | Each entry is a human-readable explanation | Empty; populated when system-test.md exists | STP IDs referencing non-existent SYS parents |
| stp_ids | Array[String] | Each matches `STP-[0-9]{3}-[A-Z]` | Extracted from system-test.md (if present) | All test case identifiers for orphan checking |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| requirements.md not found | File read error (exit 1) | ARCH-007 Interface: Source of valid REQ IDs | Caller (ARCH-008) reports error and exits |
| system-design.md not found | File read error (exit 1) | ARCH-007 Interface: SYS components and parent references | Caller (ARCH-008) reports error and exits |
| system-test.md absent | STP orphan detection skipped | ARCH-007 Interface: Optional STP input | Return {orphaned_sys: [...], orphaned_stp: []} |
| No orphans found | Return {orphaned_sys: [], orphaned_stp: []} | ARCH-007 Interface: No orphans exception (clean result) | Normal operation — empty arrays |

---

### Module: MOD-008 (Validation CLI Argument Parser and Orchestrator)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `scripts/bash/validate-system-coverage.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION main(args: Array[String]) -> ExitCode:
    // Step 1: Parse CLI arguments
    json_mode = false
    vmodel_dir = NULL
    FOR EACH arg IN args:
        IF arg == "--json":
            json_mode = true
        ELSE IF arg == "--help" OR arg == "-h":
            PRINT("Usage: validate-system-coverage.sh [--json] <vmodel-dir>")
            RETURN 0
        ELSE:
            vmodel_dir = arg

    IF vmodel_dir IS NULL:
        PRINT_STDERR("ERROR: vmodel-dir argument required")
        RETURN 1

    // Step 2: Resolve file paths
    requirements_path = vmodel_dir + "/requirements.md"
    system_design_path = vmodel_dir + "/system-design.md"
    system_test_path = vmodel_dir + "/system-test.md"

    // Step 3: Validate required files exist
    IF NOT FILE_EXISTS(requirements_path):
        PRINT_STDERR("ERROR: requirements.md not found in " + vmodel_dir)
        RETURN 1
    IF NOT FILE_EXISTS(system_design_path):
        PRINT_STDERR("ERROR: system-design.md not found in " + vmodel_dir)
        RETURN 1

    // Step 4: Determine validation mode
    partial_mode = NOT FILE_EXISTS(system_test_path)

    // Step 5: Run forward coverage (always)
    fwd_result = check_forward_coverage(requirements_path, system_design_path)

    // Step 6: Run backward coverage (skip if partial)
    bwd_result = NULL
    IF NOT partial_mode:
        bwd_result = check_backward_coverage(system_design_path, system_test_path)

    // Step 7: Run orphan detection
    orphan_result = detect_orphans(requirements_path, system_design_path,
        system_test_path IF NOT partial_mode ELSE NULL)

    // Step 8: Aggregate results and determine verdict
    has_gaps = false
    IF SIZE(fwd_result.uncovered) > 0:
        has_gaps = true
    IF bwd_result IS NOT NULL AND SIZE(bwd_result.uncovered) > 0:
        has_gaps = true
    IF SIZE(orphan_result.orphaned_sys) > 0 OR SIZE(orphan_result.orphaned_stp) > 0:
        has_gaps = true

    // Step 9: Delegate to output formatter (MOD-009)
    IF json_mode:
        output = format_json_report(fwd_result, bwd_result, orphan_result, partial_mode, has_gaps)
    ELSE:
        output = format_human_report(fwd_result, bwd_result, orphan_result, partial_mode, has_gaps)
    PRINT(output)

    // Step 10: Set exit code
    IF has_gaps:
        RETURN 1
    ELSE:
        RETURN 0
```

#### State Machine View

N/A — Stateless: CLI entry point processes arguments and orchestrates validators in a single invocation.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| json_mode | Boolean | true/false | false | Output format flag: JSON when true, human-readable when false |
| vmodel_dir | String or NULL | Filesystem path | NULL; set from positional arg | Path to the V-Model directory containing artifacts |
| partial_mode | Boolean | true/false | Determined by system-test.md existence | true when system-test.md is absent |
| fwd_result | CoverageResult | {covered: [], uncovered: [], pct: int} | Set from check_forward_coverage() | Forward coverage validation result |
| bwd_result | CoverageResult or NULL | {covered: [], uncovered: [], pct: int} or NULL | Set from check_backward_coverage() or NULL in partial mode | Backward coverage validation result |
| orphan_result | OrphanResult | {orphaned_sys: [], orphaned_stp: []} | Set from detect_orphans() | Orphan detection result |
| has_gaps | Boolean | true/false | false; set to true if any validator finds gaps | Composite verdict for exit code |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| No vmodel-dir argument | Exit code 1, stderr: "ERROR: vmodel-dir argument required" | ARCH-008 Interface: CLI positional args required | User must provide argument |
| requirements.md not found | Exit code 1, stderr: "ERROR: requirements.md not found" | ARCH-008 Interface: First two args required | User must ensure file exists |
| system-design.md not found | Exit code 1, stderr: "ERROR: system-design.md not found" | ARCH-008 Interface: First two args required | User must ensure file exists |
| system-test.md not found | Partial mode activated — not an error | ARCH-008 Interface: Third arg optional | Bypass backward coverage and STP orphan checks |
| Any coverage gap detected | Exit code 1 with detailed gap report | ARCH-008 Interface: Exit code 0=pass, 1=gap | Report gaps for CI enforcement |
| All checks pass | Exit code 0 with success message | ARCH-008 Interface: Exit code 0=pass | Normal success |

---

### Module: MOD-009 (Validation Output Formatter)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `scripts/bash/validate-system-coverage.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION format_human_report(fwd: CoverageResult, bwd: CoverageResult OR NULL, orphans: OrphanResult, partial: Boolean, has_gaps: Boolean) -> String:
    report = "=== System-Level Coverage Validation ===\n\n"
    report += "Forward coverage (REQ→SYS): " + fwd.pct + "%\n"
    IF partial:
        report += "Backward coverage (SYS→STP): SKIPPED (system-test.md not found)\n"
        report += "Mode: PARTIAL VALIDATION\n"
    ELSE:
        report += "Backward coverage (SYS→STP): " + bwd.pct + "%\n"

    IF SIZE(fwd.uncovered) > 0:
        report += "\n❌ Requirements WITHOUT system component mapping:\n"
        FOR EACH req IN fwd.uncovered:
            report += "   - " + req + ": no system component mapping found\n"

    IF bwd IS NOT NULL AND SIZE(bwd.uncovered) > 0:
        report += "\n❌ System components WITHOUT test coverage:\n"
        FOR EACH sys IN bwd.uncovered:
            report += "   - " + sys + ": no test case found\n"

    IF SIZE(orphans.orphaned_sys) > 0:
        report += "\n⚠️  Orphaned system components:\n"
        FOR EACH msg IN orphans.orphaned_sys:
            report += "   - " + msg + "\n"

    IF SIZE(orphans.orphaned_stp) > 0:
        report += "\n⚠️  Orphaned test cases:\n"
        FOR EACH msg IN orphans.orphaned_stp:
            report += "   - " + msg + "\n"

    IF NOT has_gaps:
        report += "\n✅ Full system-level coverage"
        IF partial:
            report += " (forward only — partial mode)"
        report += "\n"

    RETURN report

FUNCTION format_json_report(fwd: CoverageResult, bwd: CoverageResult OR NULL, orphans: OrphanResult, partial: Boolean, has_gaps: Boolean) -> String:
    json = {
        forward_coverage_pct: fwd.pct,
        backward_coverage_pct: IF bwd IS NOT NULL THEN bwd.pct ELSE 0,
        uncovered_reqs: fwd.uncovered,
        uncovered_sys: IF bwd IS NOT NULL THEN bwd.uncovered ELSE [],
        orphaned_sys: orphans.orphaned_sys,
        orphaned_stp: orphans.orphaned_stp,
        partial_mode: partial,
        has_gaps: has_gaps
    }
    RETURN JSON_SERIALIZE(json)
```

#### State Machine View

N/A — Stateless pure function: takes validation results, returns formatted string.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| report | String | Unbounded; multi-line | Empty string, built incrementally | Human-readable coverage report |
| json | Dict | 8 fields | Built from function parameters | JSON-serializable coverage result |
| fwd | CoverageResult | {covered: [], uncovered: [], pct: int} | Passed as function parameter | Forward coverage data |
| bwd | CoverageResult or NULL | {covered: [], uncovered: [], pct: int} or NULL | Passed as function parameter | Backward coverage data (NULL in partial mode) |
| orphans | OrphanResult | {orphaned_sys: [], orphaned_stp: []} | Passed as function parameter | Orphan detection data |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| NULL bwd result (partial mode) | Skip backward coverage section in output | ARCH-008 Interface: Human-readable report | Report "SKIPPED" for backward coverage |
| Empty uncovered arrays | Skip gap section in output | ARCH-008 Interface: Human-readable report | Omit section — clean output |
| JSON serialization error | Return malformed JSON string | ARCH-008 Interface: JSON format output | Unlikely — all values are primitives or string arrays |

---

### Module: MOD-010 (PowerShell Coverage Validation)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `scripts/powershell/validate-system-coverage.ps1`

#### Algorithmic / Logic View

```pseudocode
FUNCTION Validate-SystemCoverage(VModelDir: String, Json: Switch) -> ExitCode:
    // Mirrors MOD-005 + MOD-006 + MOD-007 + MOD-008 + MOD-009 combined behavior in PowerShell

    // Step 1: Resolve file paths
    RequirementsPath = JOIN_PATH(VModelDir, "requirements.md")
    SystemDesignPath = JOIN_PATH(VModelDir, "system-design.md")
    SystemTestPath = JOIN_PATH(VModelDir, "system-test.md")

    // Step 2: Validate required files
    IF NOT TEST_PATH(RequirementsPath):
        WRITE_ERROR("ERROR: requirements.md not found in " + VModelDir)
        EXIT 1
    IF NOT TEST_PATH(SystemDesignPath):
        WRITE_ERROR("ERROR: system-design.md not found in " + VModelDir)
        EXIT 1

    PartialMode = NOT TEST_PATH(SystemTestPath)

    // Step 3: Forward coverage (REQ→SYS)
    ReqContent = GET_CONTENT(RequirementsPath, -Raw)
    ReqIds = [regex]::Matches(ReqContent, "REQ-[0-9]{3}") |
        ForEach { $_.Value } | Sort-Object -Unique
    NfReqIds = [regex]::Matches(ReqContent, "REQ-(NF|CN|IF)-[0-9]{3}") |
        ForEach { $_.Value } | Sort-Object -Unique
    AllReqIds = (ReqIds + NfReqIds) | Sort-Object -Unique

    SysContent = GET_CONTENT(SystemDesignPath, -Raw)
    CoveredReqs = HashSet[String]()
    DecompSection = EXTRACT_SECTION(SysContent, "## Decomposition")
    FOR EACH Row IN PARSE_TABLE_ROWS(DecompSection):
        ParentReqsCell = Row["Parent Requirements"]
        Refs = [regex]::Matches(ParentReqsCell, "REQ-[0-9]{3}|REQ-(NF|CN|IF)-[0-9]{3}")
        FOR EACH Ref IN Refs:
            CoveredReqs.Add(Ref.Value)

    UncoveredReqs = AllReqIds | Where { -not CoveredReqs.Contains($_) }
    FwdPct = IF AllReqIds.Count > 0: ((AllReqIds.Count - UncoveredReqs.Count) * 100 / AllReqIds.Count) ELSE: 0

    // Step 4: Backward coverage (SYS→STP) — skip if partial
    UncoveredSys = @()
    BwdPct = 0
    SysIds = [regex]::Matches(DecompSection, "SYS-[0-9]{3}") | ForEach { $_.Value } | Sort-Object -Unique
    IF NOT PartialMode:
        TestContent = GET_CONTENT(SystemTestPath, -Raw)
        StpIds = [regex]::Matches(TestContent, "STP-[0-9]{3}-[A-Z]") | ForEach { $_.Value }
        CoveredSys = HashSet[String]()
        FOR EACH Stp IN StpIds:
            ParentSys = "SYS-" + Stp.Substring(4, 3)
            CoveredSys.Add(ParentSys)
        UncoveredSys = SysIds | Where { -not CoveredSys.Contains($_) }
        BwdPct = IF SysIds.Count > 0: ((SysIds.Count - UncoveredSys.Count) * 100 / SysIds.Count) ELSE: 0

    // Step 5: Orphan detection
    OrphanedSys = @()
    OrphanedStp = @()
    FOR EACH SysId IN SysIds:
        ParentReqs = EXTRACT_PARENT_REQS(DecompSection, SysId)
        FOR EACH Req IN ParentReqs:
            IF Req -notin AllReqIds:
                OrphanedSys += "$SysId`: references non-existent $Req"
                BREAK

    IF NOT PartialMode:
        FOR EACH Stp IN StpIds:
            ParentSys = "SYS-" + Stp.Substring(4, 3)
            IF ParentSys -notin SysIds:
                OrphanedStp += "$Stp`: parent $ParentSys not found in system-design.md"

    // Step 6: Determine verdict
    HasGaps = (UncoveredReqs.Count -gt 0) -or (UncoveredSys.Count -gt 0) -or
              (OrphanedSys.Count -gt 0) -or (OrphanedStp.Count -gt 0)

    // Step 7: Output (identical format to MOD-008/MOD-009)
    IF Json:
        FORMAT_JSON(FwdPct, BwdPct, UncoveredReqs, UncoveredSys, OrphanedSys, OrphanedStp, PartialMode, HasGaps)
    ELSE:
        FORMAT_HUMAN(FwdPct, BwdPct, UncoveredReqs, UncoveredSys, OrphanedSys, OrphanedStp, PartialMode, HasGaps)

    IF HasGaps: EXIT 1 ELSE: EXIT 0
```

#### State Machine View

N/A — Stateless: mirrors Bash validation script behavior in a single invocation.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| AllReqIds | String[] | Max ~500; unique REQ ID strings | Extracted via PowerShell regex | Union of all requirement ID patterns |
| CoveredReqs | HashSet[String] | REQ ID strings | Empty; populated from Decomposition View | REQ IDs referenced by system components |
| SysIds | String[] | Max ~200; matches `SYS-[0-9]{3}` | Extracted from Decomposition View | All system component identifiers |
| StpIds | String[] | Matches `STP-[0-9]{3}-[A-Z]` | Extracted from system-test.md | All test case identifiers |
| CoveredSys | HashSet[String] | SYS ID strings | Empty; populated from STP lineage | SYS IDs with test coverage |
| UncoveredReqs | String[] | Subset of AllReqIds | Computed as set difference | REQ IDs without SYS mapping |
| UncoveredSys | String[] | Subset of SysIds | Computed as set difference | SYS IDs without STP mapping |
| OrphanedSys | String[] | Human-readable messages | Computed from cross-reference | SYS referencing non-existent REQ |
| OrphanedStp | String[] | Human-readable messages | Computed from cross-reference | STP referencing non-existent SYS |
| PartialMode | Boolean | $true/$false | Determined by system-test.md existence | Controls backward coverage bypass |
| HasGaps | Boolean | $true/$false | Computed from all result arrays | Composite verdict for exit code |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| requirements.md not found | Exit code 1, Write-Error | ARCH-009 Interface: Identical to ARCH-008 | User must provide file |
| system-design.md not found | Exit code 1, Write-Error | ARCH-009 Interface: Identical to ARCH-008 | User must provide file |
| system-test.md not found | Partial mode — not an error | ARCH-009 Interface: Identical to ARCH-008 | Bypass backward coverage |
| Coverage gap detected | Exit code 1 | ARCH-009 Interface: Identical exit codes to ARCH-008 | Report gaps |
| All checks pass | Exit code 0 | ARCH-009 Interface: Identical exit codes to ARCH-008 | Success |

---

### Module: MOD-011 (SYS/STP/STS ID Extraction)

**Parent Architecture Modules**: ARCH-010
**Target Source File(s)**: `scripts/bash/build-matrix.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION extract_sys_stp_sts_ids(system_design_path: String, system_test_path: String) -> ExtractResult:
    // Step 1: Extract SYS entries with parent REQ references from system-design.md
    sys_content = READ_FILE(system_design_path)
    sys_entries = []
    in_decomposition = false
    FOR EACH line IN sys_content:
        IF line MATCHES "^## Decomposition":
            in_decomposition = true
            CONTINUE
        IF in_decomposition AND line MATCHES "^## ":
            BREAK
        IF in_decomposition AND line MATCHES table_row_pattern:
            sys_id = REGEX_FIND(line, "SYS-[0-9]{3}")
            IF sys_id IS NULL:
                CONTINUE
            parent_reqs_cell = EXTRACT_COLUMN(line, "Parent Requirements")
            parent_reqs = REGEX_FIND_ALL(parent_reqs_cell, "REQ-[0-9]{3}")
            nf_reqs = REGEX_FIND_ALL(parent_reqs_cell, "REQ-(NF|CN|IF)-[0-9]{3}")
            sys_entries.APPEND({sys_id: sys_id, parent_reqs: UNION(parent_reqs, nf_reqs)})

    // Step 2: Extract STP entries from system-test.md
    test_content = READ_FILE(system_test_path)
    stp_entries = []
    stp_ids = REGEX_FIND_ALL(test_content, "STP-[0-9]{3}-[A-Z]")
    FOR EACH stp IN UNIQUE(stp_ids):
        parent_sys = "SYS-" + stp[4:7]
        stp_entries.APPEND({stp_id: stp, parent_sys: parent_sys})

    // Step 3: Extract STS entries from system-test.md
    sts_entries = []
    sts_ids = REGEX_FIND_ALL(test_content, "STS-[0-9]{3}-[A-Z][0-9]+")
    FOR EACH sts IN UNIQUE(sts_ids):
        parent_stp = sts[0:9]
        sts_entries.APPEND({sts_id: sts, parent_stp: parent_stp})

    RETURN {sys_entries: sys_entries, stp_entries: stp_entries, sts_entries: sts_entries}
```

#### State Machine View

N/A — Stateless pure function: parses files and returns structured ID data.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| sys_entries | Array[Dict] | Each dict: {sys_id: String, parent_reqs: Array[String]}; max ~200 | Parsed from Decomposition View | SYS components with parent REQ references |
| stp_entries | Array[Dict] | Each dict: {stp_id: String, parent_sys: String}; max ~600 | Derived from STP ID lineage | STP test cases with parent SYS derived from ID |
| sts_entries | Array[Dict] | Each dict: {sts_id: String, parent_stp: String}; max ~2000 | Derived from STS ID lineage | STS scenarios with parent STP derived from ID |
| in_decomposition | Boolean | true/false | false | Section parser state for Decomposition View |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| system-design.md not found | File read error | ARCH-010 Interface: Warning — empty arrays | Return empty sys_entries |
| system-test.md not found | File read error | ARCH-010 Interface: Warning — empty arrays | Return empty stp_entries and sts_entries |
| No IDs found in either file | Return all empty arrays | ARCH-010 Interface: Warning — empty arrays | Caller handles empty data gracefully |
| Malformed STP ID (cannot extract parent SYS) | Skip entry | ARCH-010 Interface: Regex pattern constraint | Log warning, continue with remaining entries |

---

### Module: MOD-012 (Matrix B Table Construction)

**Parent Architecture Modules**: ARCH-011
**Target Source File(s)**: `scripts/bash/build-matrix.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION build_matrix_b(sys_entries: Array, stp_entries: Array, sts_entries: Array) -> MatrixBOutput:
    // Step 1: Build lookup maps for efficient resolution
    sys_to_reqs = {}
    FOR EACH entry IN sys_entries:
        sys_to_reqs[entry.sys_id] = entry.parent_reqs

    stp_to_sys = {}
    FOR EACH entry IN stp_entries:
        stp_to_sys[entry.stp_id] = entry.parent_sys

    sts_to_stp = {}
    FOR EACH entry IN sts_entries:
        sts_to_stp[entry.sts_id] = entry.parent_stp

    // Step 2: Group STP by parent SYS
    sys_to_stps = {}
    FOR EACH stp, parent_sys IN stp_to_sys:
        IF parent_sys NOT IN sys_to_stps:
            sys_to_stps[parent_sys] = []
        sys_to_stps[parent_sys].APPEND(stp)

    // Step 3: Group STS by parent STP
    stp_to_stss = {}
    FOR EACH sts, parent_stp IN sts_to_stp:
        IF parent_stp NOT IN stp_to_stss:
            stp_to_stss[parent_stp] = []
        stp_to_stss[parent_stp].APPEND(sts)

    // Step 4: Build resolved chain rows
    rows = []
    total_sys = SIZE(sys_entries)
    covered_sys = 0
    FOR EACH sys_entry IN sys_entries:
        sys_id = sys_entry.sys_id
        parent_reqs = sys_entry.parent_reqs
        stps = sys_to_stps[sys_id] IF sys_id IN sys_to_stps ELSE []

        IF SIZE(stps) == 0:
            FOR EACH req IN parent_reqs:
                rows.APPEND({req: req, sys: sys_id, stp: "⚠️ No test coverage", sts: "—"})
        ELSE:
            covered_sys = covered_sys + 1
            FOR EACH stp IN SORTED(stps):
                stss = stp_to_stss[stp] IF stp IN stp_to_stss ELSE ["—"]
                FOR EACH sts IN SORTED(stss):
                    FOR EACH req IN parent_reqs:
                        rows.APPEND({req: req, sys: sys_id, stp: stp, sts: sts})

    // Step 5: Calculate coverage percentage
    IF total_sys > 0:
        coverage_pct = covered_sys * 100 / total_sys
    ELSE:
        coverage_pct = 0

    // Step 6: Format as Markdown table
    output = "| REQ | SYS | STP | STS |\n"
    output += "|-----|-----|-----|-----|\n"
    FOR EACH row IN rows:
        output += "| " + row.req + " | " + row.sys + " | " + row.stp + " | " + row.sts + " |\n"
    output += "\nCoverage: " + coverage_pct + "%\n"

    RETURN {table: output, coverage_pct: coverage_pct}
```

#### State Machine View

N/A — Stateless pure function: takes structured data, returns formatted table.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| sys_to_reqs | Associative Array | Key: SYS ID, Value: Array of REQ IDs | Built from sys_entries | Lookup: SYS → parent REQs |
| stp_to_sys | Associative Array | Key: STP ID, Value: SYS ID | Built from stp_entries | Lookup: STP → parent SYS |
| sts_to_stp | Associative Array | Key: STS ID, Value: STP ID | Built from sts_entries | Lookup: STS → parent STP |
| sys_to_stps | Associative Array | Key: SYS ID, Value: Array of STP IDs | Built by grouping stp_to_sys | Lookup: SYS → child STPs |
| stp_to_stss | Associative Array | Key: STP ID, Value: Array of STS IDs | Built by grouping sts_to_stp | Lookup: STP → child STSs |
| rows | Array[Dict] | Each dict: {req, sys, stp, sts}; unbounded | Built during chain resolution | Resolved REQ→SYS→STP→STS chain rows |
| coverage_pct | Integer | 0–100 | Computed from covered_sys / total_sys | Matrix B verification coverage percentage |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Empty sys_entries input | Return empty table with 0% coverage | ARCH-011 Interface: Must contain at least one entry | Produce empty Matrix B |
| SYS with no STP coverage | Insert "⚠️ No test coverage" in STP column | ARCH-011 Interface: Gap annotations | Highlight gap in table output |
| STP with no STS scenarios | Insert "—" in STS column | ARCH-011 Interface: Chain resolution | Show incomplete chain |
| Coverage percentage mismatch with validation script | Not handled at this level | ARCH-011 Interface: Must match validate-system-coverage.sh | Verified by integration test |

---

### Module: MOD-013 (PowerShell Matrix B Builder)

**Parent Architecture Modules**: ARCH-012
**Target Source File(s)**: `scripts/powershell/build-matrix.ps1`

#### Algorithmic / Logic View

```pseudocode
FUNCTION Build-MatrixB(SystemDesignPath: String, SystemTestPath: String) -> MatrixBOutput:
    // Mirrors MOD-011 + MOD-012 combined behavior in PowerShell

    // Step 1: Extract SYS entries from system-design.md
    SysContent = GET_CONTENT(SystemDesignPath, -Raw)
    DecompSection = EXTRACT_SECTION(SysContent, "## Decomposition")
    SysEntries = @()
    FOR EACH Row IN PARSE_TABLE_ROWS(DecompSection):
        SysId = [regex]::Match(Row, "SYS-[0-9]{3}").Value
        IF SysId:
            ParentReqs = [regex]::Matches(Row["Parent Requirements"], "REQ-[0-9]{3}|REQ-(NF|CN|IF)-[0-9]{3}") |
                ForEach { $_.Value }
            SysEntries += @{SysId = SysId; ParentReqs = ParentReqs}

    // Step 2: Extract STP and STS entries from system-test.md
    TestContent = GET_CONTENT(SystemTestPath, -Raw)
    StpIds = [regex]::Matches(TestContent, "STP-[0-9]{3}-[A-Z]") |
        ForEach { $_.Value } | Sort-Object -Unique
    StsIds = [regex]::Matches(TestContent, "STS-[0-9]{3}-[A-Z][0-9]+") |
        ForEach { $_.Value } | Sort-Object -Unique

    // Step 3: Build lookup tables and Matrix B rows
    SysToStps = @{}
    FOR EACH Stp IN StpIds:
        ParentSys = "SYS-" + Stp.Substring(4, 3)
        IF -not SysToStps.ContainsKey(ParentSys):
            SysToStps[ParentSys] = @()
        SysToStps[ParentSys] += Stp

    StpToStss = @{}
    FOR EACH Sts IN StsIds:
        ParentStp = Sts.Substring(0, 9)
        IF -not StpToStss.ContainsKey(ParentStp):
            StpToStss[ParentStp] = @()
        StpToStss[ParentStp] += Sts

    // Step 4: Build Matrix B rows (identical logic to MOD-012)
    Rows = @()
    CoveredSys = 0
    FOR EACH SysEntry IN SysEntries:
        Stps = SysToStps[SysEntry.SysId]
        IF Stps.Count -eq 0:
            FOR EACH Req IN SysEntry.ParentReqs:
                Rows += @{Req = Req; Sys = SysEntry.SysId; Stp = "⚠️ No test coverage"; Sts = "—"}
        ELSE:
            CoveredSys++
            FOR EACH Stp IN (Stps | Sort-Object):
                Stss = StpToStss[Stp]
                IF Stss.Count -eq 0: Stss = @("—")
                FOR EACH Sts IN (Stss | Sort-Object):
                    FOR EACH Req IN SysEntry.ParentReqs:
                        Rows += @{Req = Req; Sys = SysEntry.SysId; Stp = Stp; Sts = Sts}

    // Step 5: Calculate coverage and format output
    CoveragePct = IF SysEntries.Count > 0: (CoveredSys * 100 / SysEntries.Count) ELSE: 0
    WRITE_OUTPUT(FORMAT_TABLE(Rows, CoveragePct))

    RETURN @{Table = Rows; CoveragePct = CoveragePct}
```

#### State Machine View

N/A — Stateless: mirrors Bash matrix builder behavior in a single invocation.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| SysEntries | Hashtable[] | Each: {SysId: String, ParentReqs: String[]} | Parsed from Decomposition View | SYS components with parent REQs |
| StpIds | String[] | Unique; matches `STP-[0-9]{3}-[A-Z]` | Extracted via regex | All test case IDs |
| StsIds | String[] | Unique; matches `STS-[0-9]{3}-[A-Z][0-9]+` | Extracted via regex | All test scenario IDs |
| SysToStps | Hashtable | Key: SYS ID, Value: String[] of STP IDs | Grouped from StpIds by lineage | Lookup: SYS → child STPs |
| StpToStss | Hashtable | Key: STP ID, Value: String[] of STS IDs | Grouped from StsIds by lineage | Lookup: STP → child STSs |
| Rows | Hashtable[] | Each: {Req, Sys, Stp, Sts} | Built during chain resolution | Matrix B rows |
| CoveragePct | Int32 | 0–100 | Computed | Verification coverage percentage |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| system-design.md not found | Terminating error | ARCH-012 Interface: Identical parsing to ARCH-010 | Caller handles file absence |
| system-test.md not found | Terminating error | ARCH-012 Interface: Identical parsing to ARCH-010 | Caller handles file absence |
| Empty input files | Return empty table with 0% | ARCH-012 Interface: Must produce identical output to ARCH-011 | Produce empty Matrix B |
| Gap in chain | Insert "⚠️ No test coverage" | ARCH-012 Interface: Must produce identical rows | Highlight gap |

---

### Module: MOD-014 (Trace Command Matrix B Integration)

**Parent Architecture Modules**: ARCH-013
**Target Source File(s)**: `commands/trace.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION trace_command_matrix_b(available_docs: Array[String], vmodel_dir: String) -> TraceOutput:
    // Step 1: Generate Matrix A (existing v0.1.0 behavior — unchanged)
    matrix_a = generate_matrix_a(vmodel_dir)

    // Step 2: Check if system-level artifacts exist
    has_system_design = "system-design.md" IN available_docs
    has_system_test = "system-test.md" IN available_docs

    // Step 3: Conditionally generate Matrix B
    matrix_b = NULL
    IF has_system_design AND has_system_test:
        IF PLATFORM == "Windows":
            matrix_b_output = RUN("powershell build-matrix.ps1 --matrix-b " + vmodel_dir)
        ELSE:
            matrix_b_output = RUN("bash build-matrix.sh --matrix-b " + vmodel_dir)
        matrix_b = PARSE_MATRIX_OUTPUT(matrix_b_output)

    // Step 4: Assemble traceability matrix output
    output = "# Traceability Matrix\n\n"
    output += "## Matrix A — Validation (REQ → ATP → SCN)\n\n"
    output += matrix_a
    output += "\n\n"

    IF matrix_b IS NOT NULL:
        output += "## Matrix B — Verification (REQ → SYS → STP → STS)\n\n"
        output += matrix_b

    RETURN output
```

#### State Machine View

N/A — Stateless: single-execution prompt assembling traceability matrices.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| available_docs | Array[String] | From setup script JSON output | Parsed from config | List of existing V-Model documents |
| has_system_design | Boolean | true/false | Checked against available_docs | Whether system-design.md exists |
| has_system_test | Boolean | true/false | Checked against available_docs | Whether system-test.md exists |
| matrix_a | String | Markdown table; unbounded | Generated from existing v0.1.0 logic | Matrix A: REQ → ATP → SCN |
| matrix_b | String or NULL | Markdown table or NULL | Generated from build-matrix script or NULL | Matrix B: REQ → SYS → STP → STS |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| system-design.md absent | Matrix B not generated (no warning) | ARCH-013 Interface: Skip Matrix B when files absent | Output Matrix A only — v0.1.0 backward compatible |
| system-test.md absent | Matrix B not generated (no warning) | ARCH-013 Interface: Skip Matrix B when files absent | Output Matrix A only — v0.1.0 backward compatible |
| Matrix builder script failure | Warning in output: "Matrix B generation failed" | ARCH-013 Interface: Matrix B data piped from builder | Output Matrix A, note Matrix B failure |
| Both files exist and builder succeeds | Matrix A + Matrix B in output | ARCH-013 Interface: Separate tables for A and B | Normal operation |

---

### Module: MOD-015 (SYS/STP/STS ID Pattern Registration)

**Parent Architecture Modules**: ARCH-014
**Target Source File(s)**: `evals/validators/id_validator.py`

#### Algorithmic / Logic View

```pseudocode
FUNCTION register_system_level_patterns(existing_patterns: Dict) -> Dict:
    // Step 1: Define new ID validation patterns
    SYS_PATTERN = COMPILE_REGEX("^SYS-[0-9]{3}$")
    STP_PATTERN = COMPILE_REGEX("^STP-[0-9]{3}-[A-Z]$")
    STS_PATTERN = COMPILE_REGEX("^STS-[0-9]{3}-[A-Z][0-9]+$")

    // Step 2: Add to existing prefix list (preserving REQ, ATP, SCN from v0.1.0)
    updated_patterns = COPY(existing_patterns)
    updated_patterns["SYS"] = SYS_PATTERN
    updated_patterns["STP"] = STP_PATTERN
    updated_patterns["STS"] = STS_PATTERN

    RETURN updated_patterns

FUNCTION extract_lineage(sts_id: String) -> LineageResult:
    // Step 1: Validate input is a valid STS ID
    IF NOT REGEX_MATCH(sts_id, "^STS-[0-9]{3}-[A-Z][0-9]+$"):
        RETURN Error("Invalid STS ID format: " + sts_id)

    // Step 2: Extract parent STP from STS ID
    nnn = sts_id[4:7]
    letter = sts_id[8]
    parent_stp = "STP-" + nnn + "-" + letter

    // Step 3: Extract parent SYS from STP
    parent_sys = "SYS-" + nnn

    // Step 4: Parent REQ cannot be extracted from ID alone
    parent_req = NULL

    RETURN {parent_stp: parent_stp, parent_sys: parent_sys, parent_req: parent_req}
```

#### State Machine View

N/A — Stateless: pure functions for pattern registration and lineage extraction.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| SYS_PATTERN | Compiled Regex | Pattern: `^SYS-[0-9]{3}$` | Compiled at registration time | Validates SYS component identifiers |
| STP_PATTERN | Compiled Regex | Pattern: `^STP-[0-9]{3}-[A-Z]$` | Compiled at registration time | Validates STP test case identifiers |
| STS_PATTERN | Compiled Regex | Pattern: `^STS-[0-9]{3}-[A-Z][0-9]+$` | Compiled at registration time | Validates STS test scenario identifiers |
| existing_patterns | Dict[String, Regex] | Contains REQ, ATP, SCN patterns from v0.1.0 | Loaded from existing validator | Existing ID validation patterns to extend |
| updated_patterns | Dict[String, Regex] | existing_patterns + 3 new entries | Copy of existing + SYS/STP/STS | Complete pattern registry |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Invalid STS ID format in extract_lineage | Return Error with message | ARCH-014 Interface: Validation result Boolean | Caller handles invalid input |
| Duplicate pattern prefix (SYS/STP/STS already registered) | Overwrite existing pattern | ARCH-014 Interface: Added to existing prefix list | Idempotent registration |
| Parent REQ extraction requested but requires lookup | Return NULL for parent_req field | ARCH-014 Interface: Lineage extraction data structure | Caller must consult system-design.md for REQ mapping |

---

### Module: MOD-016 (Extension Manifest Entries)

**Parent Architecture Modules**: ARCH-015
**Target Source File(s)**: `extension.yml`

#### Algorithmic / Logic View

```pseudocode
FUNCTION update_extension_manifest(manifest: YAML) -> YAML:
    // Step 1: Bump version
    manifest.extension.version = "0.2.0"

    // Step 2: Register system-design command
    system_design_cmd = {
        name: "speckit.v-model.system-design",
        file: "commands/system-design.md",
        description: "Generate an IEEE 1016-compliant System Design Description with SYS-NNN components and four mandatory design views"
    }

    // Step 3: Register system-test command
    system_test_cmd = {
        name: "speckit.v-model.system-test",
        file: "commands/system-test.md",
        description: "Generate an ISO 29119-compliant System Test Plan with STP/STS test hierarchy and coverage gate"
    }

    // Step 4: Append new commands to existing commands list
    manifest.provides.commands.APPEND(system_design_cmd)
    manifest.provides.commands.APPEND(system_test_cmd)

    // Step 5: Update trace command description
    FOR EACH cmd IN manifest.provides.commands:
        IF cmd.name == "speckit.v-model.trace":
            cmd.description = cmd.description + " Includes Matrix B (Verification: REQ → SYS → STP → STS) when system-level artifacts exist."

    // Step 6: Validate command count
    total_commands = SIZE(manifest.provides.commands)
    ASSERT total_commands == 5, "Expected 5 commands (3 v0.1.0 + 2 new), got " + total_commands

    // Step 7: Validate hook count
    total_hooks = SIZE(manifest.provides.hooks)
    ASSERT total_hooks == 1, "Expected 1 hook, got " + total_hooks

    RETURN manifest
```

#### State Machine View

N/A — Stateless: YAML manifest is a static configuration file with no runtime state.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| manifest | YAML structure | Schema version 1.0 | Loaded from extension.yml | Complete extension manifest |
| manifest.extension.version | String | Semantic version format "X.Y.Z" | "0.1.0" → updated to "0.2.0" | Extension version field |
| manifest.provides.commands | Array[Dict] | Exactly 5 entries after update | 3 existing entries | Registered command definitions |
| system_design_cmd | Dict | 3 fields: name, file, description | Static definition | New system-design command registration |
| system_test_cmd | Dict | 3 fields: name, file, description | Static definition | New system-test command registration |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| extension.yml not found | Fatal: manifest file missing | ARCH-015 Interface: Manifest load from YAML | Extension installation is incomplete |
| Command count != 5 after update | Assertion failure | ARCH-015 Interface: Exactly 5 commands + 1 hook | Review manifest — duplicate or missing entries |
| Hook count != 1 after update | Assertion failure | ARCH-015 Interface: Exactly 5 commands + 1 hook | Review manifest — hooks modified unexpectedly |
| Duplicate command name registered | Warning: overwrite previous entry | ARCH-015 Interface: Command registration | Idempotent — latest registration wins |

---

### Module: MOD-017 (CI Evaluation System Design Suite)

**Parent Architecture Modules**: ARCH-016
**Target Source File(s)**: `.github/workflows/evals.yml`

#### Algorithmic / Logic View

```pseudocode
FUNCTION extend_ci_evaluation_suite(evals_workflow: YAML) -> YAML:
    // Step 1: Define system-design evaluation case
    system_design_eval = {
        name: "eval-system-design",
        fixture_input: "evals/fixtures/002-system-design/requirements.md",
        command: "speckit.v-model.system-design",
        expected_output_path: "system-design.md",
        quality_checks: [
            {check: "contains_sys_ids", pattern: "SYS-[0-9]{3}", min_count: 1},
            {check: "has_decomposition_view", pattern: "## Decomposition View"},
            {check: "has_dependency_view", pattern: "## Dependency View"},
            {check: "has_interface_view", pattern: "## Interface View"},
            {check: "has_data_design_view", pattern: "## Data Design View"},
            {check: "has_coverage_summary", pattern: "## Coverage Summary"},
            {check: "forward_coverage", script: "validate-system-coverage.sh", exit_code: 0}
        ]
    }

    // Step 2: Define system-test evaluation case
    system_test_eval = {
        name: "eval-system-test",
        fixture_input: "evals/fixtures/002-system-test/system-design.md",
        command: "speckit.v-model.system-test",
        expected_output_path: "system-test.md",
        quality_checks: [
            {check: "contains_stp_ids", pattern: "STP-[0-9]{3}-[A-Z]", min_count: 1},
            {check: "contains_sts_ids", pattern: "STS-[0-9]{3}-[A-Z][0-9]+", min_count: 1},
            {check: "has_test_cases_section", pattern: "## Test Cases"},
            {check: "has_test_scenarios_section", pattern: "## Test Scenarios"},
            {check: "has_bdd_format", pattern: "Given.*When.*Then"},
            {check: "coverage_gate_pass", script: "validate-system-coverage.sh", exit_code: 0}
        ]
    }

    // Step 3: Append evaluation cases to workflow
    evals_workflow.jobs.evaluate.strategy.matrix.eval_case.APPEND(system_design_eval)
    evals_workflow.jobs.evaluate.strategy.matrix.eval_case.APPEND(system_test_eval)

    RETURN evals_workflow
```

#### State Machine View

N/A — Stateless: CI workflow configuration is a static YAML definition.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| system_design_eval | Dict | 4 fields: name, fixture_input, command, quality_checks | Static definition | Evaluation case for system-design command quality |
| system_test_eval | Dict | 4 fields: name, fixture_input, command, quality_checks | Static definition | Evaluation case for system-test command quality |
| quality_checks | Array[Dict] | 6–7 checks per eval case | Static definitions | Individual quality gate assertions |
| evals_workflow | YAML structure | GitHub Actions workflow format | Loaded from evals.yml | Complete CI workflow configuration |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Evaluation fixture files missing | CI job failure (non-zero exit) | ARCH-016 Interface: Evaluation test fixtures required | Add missing fixtures to evals/fixtures/ |
| Quality check fails (pattern not found) | CI job failure with assertion message | ARCH-016 Interface: Non-zero exit code on regression | Fix command prompt to restore quality |
| Coverage gate fails | CI job failure with validation output | ARCH-016 Interface: Quality thresholds must match v0.1.0 | Fix command to achieve coverage |
| Workflow syntax error | GitHub Actions parse error | ARCH-016 Interface: YAML configuration format | Fix YAML syntax |

---

### Module: MOD-018 (Backward Compatibility Guards)

**Parent Architecture Modules**: ARCH-017
**Target Source File(s)**: `tests/backward-compatibility.test.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION enforce_backward_compatibility() -> CompatibilityResult:
    // This is a cross-cutting design constraint enforced across all v0.2.0 modules.
    // Implementation is embedded in each module's behavior, not a standalone function.
    // This pseudocode documents the verification logic used by regression tests.

    // Step 1: Capture v0.1.0 artifact baseline
    v010_artifacts = [
        "requirements.md",
        "acceptance-plan.md",
        "traceability-matrix.md"
    ]
    baseline_checksums = {}
    FOR EACH artifact IN v010_artifacts:
        IF FILE_EXISTS(artifact):
            baseline_checksums[artifact] = SHA256(READ_FILE(artifact))

    // Step 2: Execute v0.2.0 operations
    RUN("speckit.v-model.system-design")
    RUN("speckit.v-model.system-test")
    RUN("validate-system-coverage.sh")

    // Step 3: Verify v0.1.0 artifacts are unchanged
    violations = []
    FOR EACH artifact IN v010_artifacts:
        IF FILE_EXISTS(artifact):
            current_checksum = SHA256(READ_FILE(artifact))
            IF current_checksum != baseline_checksums[artifact]:
                violations.APPEND(artifact + ": modified by v0.2.0 operation")

    // Step 4: Verify domain-agnostic base commands
    FOR EACH cmd_file IN ["commands/system-design.md", "commands/system-test.md"]:
        content = READ_FILE(cmd_file)
        safety_refs = REGEX_FIND_ALL(content, "ISO 26262|DO-178C|IEC 62304")
        IF has_safety_refs_in_goal_section(content, safety_refs):
            violations.APPEND(cmd_file + ": contains safety standard references in base command")

    // Step 5: Return verdict
    IF SIZE(violations) == 0:
        RETURN {pass: true, violations: []}
    ELSE:
        RETURN {pass: false, violations: violations}
```

#### State Machine View

N/A — Stateless: cross-cutting constraint verified by regression tests, not a runtime state machine.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| v010_artifacts | Array[String] | Exactly 3 file names | Static list | v0.1.0 artifact file names to protect |
| baseline_checksums | Dict[String, String] | Key: filename, Value: SHA-256 hex string (64 chars) | Computed before v0.2.0 operations | Baseline checksums for byte-identical comparison |
| violations | Array[String] | 0 or more human-readable messages | Empty; populated during verification | List of backward compatibility violations |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| v0.1.0 artifact modified | Test failure with diff output | ARCH-017 Interface: Compatibility violation exception | Revert change — v0.1.0 artifacts are immutable |
| v0.1.0 artifact missing | Skip checksum comparison for that artifact | ARCH-017 Interface: v0.1.0 baseline artifacts input | Acceptable — artifact may not exist in all projects |
| Base command contains safety standard reference | Test failure | ARCH-017 Interface: Domain-agnostic base form | Move reference to domain overlay |
| New domain added requiring base command modification | Architectural violation | ARCH-017 Interface: Overlay-only extensibility | Refactor into overlay file |

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Module Designs (MOD) | 18 (18 active, 0 deprecated, 0 suspect) |
| External Modules (`[EXTERNAL]`) | 0 |
| Cross-Cutting Modules (`[CROSS-CUTTING]`) | 0 |
| Stateful Modules | 0 |
| Stateless Modules | 18 |
| Total Parent Architecture Modules Covered | 17 / 17 (100%) |
| Modules with Pseudocode | 18 / 18 (100%) |
| **Forward Coverage (ARCH→MOD)** | **100%** |

## Derived Modules

None — all modules trace to existing architecture modules.
