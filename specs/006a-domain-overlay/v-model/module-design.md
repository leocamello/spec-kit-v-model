# Module Design: Domain Overlay Architecture


**Feature Branch**: `feature/006a-domain-overlay`
**Created**: 2025-07-19
**Status**: Draft
**Source**: `specs/006a-domain-overlay/v-model/architecture-design.md`

## Overview

This module design decomposes the 18 architecture modules (ARCH-001 through ARCH-018) of the Domain Overlay Architecture feature into 30 implementable module specifications (MOD-001 through MOD-030). The decomposition follows the principle that each MOD maps to a single responsibility within its parent ARCH module: Component-type ARCH modules are split into one MOD per major function (e.g., ARCH-007 yields MOD-010 for section cleaning and MOD-011 for reference stripping), Library-type ARCH modules are split into one MOD per public API surface (ARCH-002 yields MOD-003 for schema validation and MOD-004 for cross-referencing), and Utility-type ARCH modules map 1:1 to a single MOD (ARCH-006 → MOD-009, ARCH-010 → MOD-016, ARCH-016 → MOD-026). All 30 MODs are stateless bash functions — no persistent state, no background processes, no daemon architecture. Every MOD receives its inputs as function parameters or file paths and produces outputs as files, exit codes, or structured stdout.

## ID Schema

- **Module**: `MOD-NNN` — sequential identifier, independent of ARCH numbering
- **Parent Architecture Module**: `ARCH-NNN` reference — sole authoritative traceability link
- **Target Source File**: Physical repository path under `scripts/bash/`
- **Numbering**: MOD-001 through MOD-030, assigned in logical group order (Overlay Infrastructure → Content Analysis & Cleaning → Content Population → Cross-Feature Lifecycle)
- Example: `MOD-009` (scan_domain_terms) with Parent `ARCH-006` — implements the scanning utility as a single function since ARCH-006 is a Utility-type module
- Example: `MOD-010` + `MOD-011` with Parent `ARCH-007` — decompose the Component-type MIXED Command Cleaner into section cleaning and reference stripping functions

## Module Designs

### Module: MOD-001 (create_overlay_directories)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `scripts/bash/overlay/create-overlay-dirs.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION create_overlay_directories(repo_root: string) -> integer:
    domain_ids = ["iso_26262", "do_178c", "iec_62304"]
    overlay_roots = ["commands/overlays", "templates/overlays"]

    // Step 1: Verify parent directories exist
    FOR EACH root IN overlay_roots:
        parent_path = "{repo_root}/{dirname(root)}"
        IF NOT directory_exists(parent_path):
            PRINT_ERROR "root_not_found: {parent_path} does not exist"
            RETURN 1

    // Step 2: Create directory structure (idempotent)
    created_dirs = []
    FOR EACH root IN overlay_roots:
        FOR EACH domain IN domain_ids:
            target = "{repo_root}/{root}/{domain}"
            mkdir -p target
            IF exit_code != 0:
                PRINT_ERROR "Failed to create: {target}"
                RETURN 1
            APPEND target TO created_dirs

    // Step 3: Output JSON result
    PRINT_JSON {"created_dirs": created_dirs, "count": length(created_dirs)}
    RETURN 0
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| domain_ids | List[string] | Exactly 3 entries | Hardcoded constant | The 3 supported domain identifiers |
| overlay_roots | List[string] | Exactly 2 entries | Hardcoded constant | Root paths for command and template overlays |
| created_dirs | List[string] | Max 6 (3×2) | Empty list | Accumulator for created directory paths |
| target | string | Max ~60 chars | Constructed per iteration | Full path for `mkdir -p` |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Parent directory missing | Exit 1 | root_not_found | Caller ensures repo structure |
| `mkdir -p` failure | Exit 1 | N/A (system) | Abort with message |
| Directory already exists | Exit 0 | dir_exists (idempotent) | Silent success |

---

### Module: MOD-002 (validate_overlay_structure)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `scripts/bash/overlay/create-overlay-dirs.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION validate_overlay_structure(repo_root: string) -> integer:
    domain_ids = ["iso_26262", "do_178c", "iec_62304"]
    overlay_roots = ["commands/overlays", "templates/overlays"]
    missing = []

    FOR EACH root IN overlay_roots:
        FOR EACH domain IN domain_ids:
            expected = "{repo_root}/{root}/{domain}"
            IF NOT directory_exists(expected):
                APPEND expected TO missing

    IF length(missing) > 0:
        PRINT_ERROR "Missing directories:"
        FOR EACH dir IN missing:
            PRINT_ERROR "  - {dir}"
        PRINT_JSON {"valid": false, "missing": missing}
        RETURN 1

    PRINT_JSON {"valid": true, "missing": []}
    RETURN 0
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| domain_ids | List[string] | Exactly 3 | Hardcoded constant | Expected domain subdirectory names |
| overlay_roots | List[string] | Exactly 2 | Hardcoded constant | Root directories to check |
| missing | List[string] | Max 6 | Empty list | Accumulator for missing directories |
| expected | string | Max ~60 chars | Constructed per iteration | Full path to check existence |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| One or more directories missing | Exit 1 | N/A (validation failure) | Run MOD-001 first |
| All directories present | Exit 0 | N/A (validation success) | Continue pipeline |

---

### Module: MOD-003 (validate_manifest_schema)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `scripts/bash/overlay/validate-manifest.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION validate_manifest_schema(manifest_path: string) -> integer:
    required_fields = ["name", "standards", "classification", "commands"]
    errors = []

    // Step 1: Parse YAML
    content = yq_read(manifest_path)
    IF content IS parse_error:
        PRINT_ERROR "yaml_parse_error: {manifest_path} is not valid YAML"
        RETURN 1

    // Step 2: Check required fields
    FOR EACH field IN required_fields:
        IF field NOT IN content:
            APPEND "Missing required field: {field}" TO errors
        ELSE:
            // Step 3: Validate types
            IF field == "name" AND type(content[field]) != string:
                APPEND "Field 'name' must be a string" TO errors
            IF field == "standards" AND type(content[field]) != list:
                APPEND "Field 'standards' must be a list" TO errors
            IF field == "classification" AND type(content[field]) != string:
                APPEND "Field 'classification' must be a string" TO errors
            IF field == "commands" AND type(content[field]) != list:
                APPEND "Field 'commands' must be a list" TO errors

    // Step 4: Output result
    valid = length(errors) == 0
    PRINT_JSON {"valid": valid, "errors": errors}
    IF NOT valid:
        RETURN 1
    RETURN 0
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| required_fields | List[string] | Exactly 4 | Hardcoded constant | Schema-required field names |
| errors | List[string] | Unbounded | Empty list | Validation error accumulator |
| content | Map[string, any] | Depends on YAML | Parsed from file | Manifest content as key-value map |
| valid | boolean | — | Computed | True only when errors is empty |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| YAML parse failure | Exit 1 | yaml_parse_error | Fix manifest syntax |
| Missing required field | Exit 1 (in errors list) | validation_result.errors | Add missing field |
| Wrong field type | Exit 1 (in errors list) | validation_result.errors | Fix field type |

---

### Module: MOD-004 (cross_reference_manifest_files)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `scripts/bash/overlay/validate-manifest.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION cross_reference_manifest_files(manifest_path: string, directory: string) -> integer:
    // Step 1: Read commands list from manifest
    commands_list = yq_read_field(manifest_path, ".commands[]")
    IF commands_list IS parse_error:
        PRINT_ERROR "yaml_parse_error: cannot read commands from {manifest_path}"
        RETURN 1

    // Step 2: List .md files in directory (excluding _domain.yml)
    dir_files = list_files(directory, pattern="*.md")

    // Step 3: Find orphan entries (in manifest, no file)
    orphans = []
    FOR EACH cmd IN commands_list:
        IF "{cmd}.md" NOT IN dir_files AND cmd NOT IN dir_files:
            APPEND cmd TO orphans

    // Step 4: Find unlisted files (file exists, not in manifest)
    unlisted = []
    FOR EACH file IN dir_files:
        base_name = strip_extension(file)
        IF base_name NOT IN commands_list AND file NOT IN commands_list:
            APPEND file TO unlisted

    PRINT_JSON {"orphan_entries": orphans, "unlisted_files": unlisted}
    RETURN 0
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| commands_list | List[string] | Variable | Parsed from YAML | Commands declared in manifest |
| dir_files | List[string] | Variable | From filesystem scan | Actual .md files in directory |
| orphans | List[string] | ≤ len(commands_list) | Empty list | Commands without matching files |
| unlisted | List[string] | ≤ len(dir_files) | Empty list | Files without manifest entries |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| YAML parse error | Exit 1 | yaml_parse_error | Fix manifest |
| Orphan entries found | Exit 0 (reported in JSON) | orphan_entries | Add missing files or remove entries |
| Unlisted files found | Exit 0 (reported in JSON) | unlisted_files | Add to manifest or remove files |

---

### Module: MOD-005 (collect_overlay_file_list)

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `scripts/bash/overlay/generate-manifest.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION collect_overlay_file_list(domain_dir: string) -> integer:
    // Step 1: Verify directory exists
    IF NOT directory_exists(domain_dir):
        PRINT_ERROR "Directory not found: {domain_dir}"
        RETURN 1

    // Step 2: List .md files, exclude _domain.yml
    files = []
    FOR EACH entry IN list_directory(domain_dir):
        IF entry ends_with ".md" AND entry != "_domain.yml":
            APPEND entry TO files

    // Step 3: Sort for deterministic output
    sort(files)

    IF length(files) == 0:
        PRINT_ERROR "No .md files found in {domain_dir}"
        RETURN 1

    PRINT_JSON {"files": files, "count": length(files)}
    RETURN 0
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| files | List[string] | ≥1 required | Empty list | Collected .md file names |
| entry | string | — | Per iteration | Current directory entry |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Directory not found | Exit 1 | N/A (precondition) | Run ARCH-001 first |
| No .md files | Exit 1 | overlay_files min 1 | Populate overlays first |

---

### Module: MOD-006 (generate_domain_manifest)

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `scripts/bash/overlay/generate-manifest.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION generate_domain_manifest(domain_id: string, domain_dir: string) -> integer:
    // Step 1: Look up domain metadata
    metadata = DOMAIN_METADATA[domain_id]
    IF metadata IS null:
        PRINT_ERROR "Unknown domain: {domain_id}"
        RETURN 1

    // Step 2: Collect overlay files via MOD-005
    file_list_json = collect_overlay_file_list(domain_dir)
    IF exit_code != 0:
        RETURN 1
    files = parse_json(file_list_json).files

    // Step 3: Build YAML content
    yaml_content = ""
    yaml_content += "name: \"{metadata.name}\"\n"
    yaml_content += "standards:\n"
    FOR EACH std IN metadata.standards:
        yaml_content += "  - \"{std}\"\n"
    yaml_content += "classification: \"{metadata.classification}\"\n"
    yaml_content += "commands:\n"
    FOR EACH file IN files:
        yaml_content += "  - \"{strip_extension(file)}\"\n"

    // Step 4: Write manifest file
    manifest_path = "{domain_dir}/_domain.yml"
    write_file(manifest_path, yaml_content)

    // Step 5: Validate via MOD-003
    validation_result = validate_manifest_schema(manifest_path)
    IF exit_code != 0:
        PRINT_ERROR "validation_failed: generated manifest did not pass schema validation"
        RETURN 1

    // Step 6: Cross-reference via MOD-004
    cross_reference_manifest_files(manifest_path, domain_dir)

    PRINT "Generated: {manifest_path}"
    RETURN 0
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| DOMAIN_METADATA | Map[string, Object] | Exactly 3 entries | Hardcoded constant | Maps domain_id to {name, standards, classification} |
| metadata | Object | 3 fields | Looked up by domain_id | Current domain's metadata |
| files | List[string] | ≥1 | From MOD-005 | Overlay file names for commands field |
| yaml_content | string | Variable | Empty string | Assembled YAML text |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Unknown domain_id | Exit 1 | N/A (precondition) | Use valid domain ID |
| No overlay files found | Exit 1 (from MOD-005) | overlay_files min 1 | Populate overlays first |
| Schema validation fails | Exit 1 | validation_failed | Fix generated content |

---

### Module: MOD-007 (inject_config_domain_field)

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `scripts/bash/overlay/inject-config-domain.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION inject_config_domain_field(config_template_path: string) -> integer:
    // Step 1: Verify file exists
    IF NOT file_exists(config_template_path):
        PRINT_ERROR "file_not_found: {config_template_path}"
        RETURN 1

    // Step 2: Check if domain field already exists
    content = read_file(config_template_path)
    IF content contains regex "^#?\s*domain:":
        PRINT "Domain field already present — skipping injection"
        RETURN 0

    // Step 3: Build the domain field block with documentation
    domain_block = "\n"
    domain_block += "# Domain configuration (optional)\n"
    domain_block += "# Supported values: iso_26262, do_178c, iec_62304\n"
    domain_block += "# When set, domain-specific overlay content is loaded by commands.\n"
    domain_block += "# When omitted or empty, commands operate in domain-agnostic mode.\n"
    domain_block += "# Only one domain may be active at a time (not a list).\n"
    domain_block += "# domain: iso_26262\n"

    // Step 4: Append to file
    append_to_file(config_template_path, domain_block)

    PRINT "Injected domain field into {config_template_path}"
    RETURN 0
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| content | string | Variable | Read from file | Current file content for duplicate check |
| domain_block | string | ~350 chars | Built in-function | The commented-out domain field with docs |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| File not found | Exit 1 | file_not_found | Ensure config-template.yml exists |
| Field already present | Exit 0 | N/A (idempotent) | Silent skip |

---

### Module: MOD-008 (resolve_domain_field)

**Parent Architecture Modules**: ARCH-005
**Target Source File(s)**: `scripts/bash/overlay/resolve-domain.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION resolve_domain_field(repo_root: string) -> integer:
    SUPPORTED_DOMAINS = ["iso_26262", "do_178c", "iec_62304"]
    config_path = "{repo_root}/v-model-config.yml"

    // Step 1: Check if config file exists
    IF NOT file_exists(config_path):
        PRINT_JSON {"domain_id": null, "overlay_paths": null, "reason": "config_not_found"}
        RETURN 0

    // Step 2: Read domain field
    domain_value = yq_read_field(config_path, ".domain")
    IF domain_value IS null OR domain_value IS empty_string:
        PRINT_JSON {"domain_id": null, "overlay_paths": null, "reason": "field_absent_or_empty"}
        RETURN 0

    // Step 3: Validate against supported list
    IF domain_value NOT IN SUPPORTED_DOMAINS:
        PRINT_JSON {"domain_id": null, "overlay_paths": null, "reason": "unsupported_value", "value": domain_value}
        RETURN 0

    // Step 4: Construct overlay paths
    cmd_overlay = "{repo_root}/commands/overlays/{domain_value}"
    tpl_overlay = "{repo_root}/templates/overlays/{domain_value}"

    PRINT_JSON {"domain_id": domain_value, "overlay_paths": {"commands": cmd_overlay, "templates": tpl_overlay}}
    RETURN 0
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| SUPPORTED_DOMAINS | List[string] | Exactly 3 | Hardcoded constant | Valid domain identifiers |
| domain_value | string or null | — | From YAML field | Raw value of domain field |
| cmd_overlay | string | ~50 chars | Constructed | Path to command overlay directory |
| tpl_overlay | string | ~50 chars | Constructed | Path to template overlay directory |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Config file missing | Exit 0, null result | No exception — graceful fallback | Domain-agnostic mode |
| Field absent or empty | Exit 0, null result | No exception — graceful fallback | Domain-agnostic mode |
| Unsupported value | Exit 0, null result | No exception — graceful fallback | Domain-agnostic mode |

---

### Module: MOD-009 (scan_domain_terms)

**Parent Architecture Modules**: ARCH-006
**Target Source File(s)**: `scripts/bash/refactor/scan-domain-terms.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION scan_domain_terms(file_path: string) -> integer:
    BANNED_TERMS = [
        "ASIL", "DAL", "SIL", "HIL", "MC/DC", "WCET",
        "MISRA", "CERT-C", "regulatory-grade",
        "Freedom from Interference", "ASIL Decomposition",
        "DO-178C", "ISO 26262", "ISO 14971",
        "IEC 62304", "FDA 21 CFR 820", "IEC 61508"
    ]

    // Step 1: Verify file exists
    IF NOT file_exists(file_path):
        PRINT_ERROR "file_not_found: {file_path}"
        RETURN 1

    // Step 2: Scan line by line
    matches = []
    line_number = 0
    FOR EACH line IN read_lines(file_path):
        line_number += 1
        FOR EACH term IN BANNED_TERMS:
            IF line contains term (case-sensitive):
                context = trim(line)
                IF length(context) > 120:
                    context = substring(context, 0, 120) + "..."
                APPEND {"term": term, "line_number": line_number, "context": context} TO matches

    // Step 3: Output result
    is_clean = length(matches) == 0
    PRINT_JSON {"scan_report": matches, "is_clean": is_clean, "total_matches": length(matches)}

    IF is_clean:
        RETURN 0
    ELSE:
        RETURN 0  // Non-zero only for system errors, not findings
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| BANNED_TERMS | List[string] | Exactly 17 entries | Hardcoded constant | Domain-specific terms to detect |
| matches | List[Object] | Unbounded | Empty list | Accumulator for {term, line_number, context} |
| line_number | integer | ≥1 | 0, incremented per line | Current line position in file |
| context | string | Max 123 chars (120 + "...") | Trimmed from line | Surrounding text for the match |
| is_clean | boolean | — | Computed | True only when matches is empty |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| File not found | Exit 1 | file_not_found | Provide valid path |
| Terms found | Exit 0 (findings in JSON) | scan_report list | Process findings |
| No terms found | Exit 0 | is_clean = true | File is clean |

---

### Module: MOD-010 (clean_mixed_command_sections)

**Parent Architecture Modules**: ARCH-007
**Target Source File(s)**: `scripts/bash/refactor/clean-mixed-commands.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION clean_mixed_command_sections(command_path: string, scan_report: List[Object]) -> Object:
    MIXED_COMMANDS = [
        "system-design.md", "system-test.md", "architecture-design.md",
        "integration-test.md", "module-design.md", "unit-test.md"
    ]

    // Step 1: Verify file is a MIXED command
    filename = basename(command_path)
    IF filename NOT IN MIXED_COMMANDS:
        PRINT_ERROR "Not a MIXED command: {filename}"
        RETURN {"error": "invalid_target"}

    // Step 2: Read file content
    lines = read_lines(command_path)
    original_line_count = length(lines)

    // Step 3: Identify domain-specific section blocks to remove
    // Pattern: sections gated by "If domain is set..." or containing safety-critical headers
    sections_to_remove = []
    in_domain_section = false
    section_start = -1
    section_depth = 0

    FOR i = 0 TO length(lines) - 1:
        line = lines[i]

        // Detect start of domain-specific section
        IF line matches regex "(?i)^#{2,4}\s+.*\d+\.\d+.*safety.critical|complexity.constraints|memory.management|single.entry":
            in_domain_section = true
            section_start = i
            section_depth = count_leading_hashes(line)
            CONTINUE

        // Detect ad-hoc conditional pattern
        IF line matches regex "(?i)^\*?\*?if.*domain.*set|only.*generate.*if.*domain":
            in_domain_section = true
            section_start = i
            section_depth = 0  // Block-level, ends at next blank line
            CONTINUE

        // Detect end of section
        IF in_domain_section:
            IF section_depth > 0 AND line matches regex "^#{1,{section_depth}}\s" AND NOT line matches regex "^#{section_depth+1,}":
                APPEND {start: section_start, end: i - 1} TO sections_to_remove
                in_domain_section = false
            ELSE IF section_depth == 0 AND line is_blank:
                APPEND {start: section_start, end: i} TO sections_to_remove
                in_domain_section = false

    // Handle section extending to end of file
    IF in_domain_section:
        APPEND {start: section_start, end: length(lines) - 1} TO sections_to_remove

    // Step 4: Remove sections in reverse order (to preserve line numbers)
    sort_descending(sections_to_remove, by: "start")
    lines_removed = 0
    FOR EACH section IN sections_to_remove:
        remove_lines(lines, section.start, section.end)
        lines_removed += (section.end - section.start + 1)

    // Step 5: Write cleaned content
    write_file(command_path, join(lines, "\n"))

    RETURN {"lines_removed": lines_removed, "sections_removed": length(sections_to_remove)}
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| MIXED_COMMANDS | List[string] | Exactly 6 | Hardcoded constant | Valid target filenames |
| lines | List[string] | Variable | Read from file | File content as line array |
| sections_to_remove | List[Object] | Variable | Empty list | {start, end} ranges to delete |
| in_domain_section | boolean | — | false | Tracks if parser is inside a domain section |
| section_start | integer | ≥0 | -1 | Start line of current domain section |
| section_depth | integer | 0–6 | 0 | Heading depth of current section (0 = block-level) |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Not a MIXED command | Return error object | N/A (precondition) | Provide valid MIXED command path |
| File read/write error | System exception | N/A (system) | Check permissions |

---

### Module: MOD-011 (strip_mixed_command_references)

**Parent Architecture Modules**: ARCH-007
**Target Source File(s)**: `scripts/bash/refactor/clean-mixed-commands.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION strip_mixed_command_references(command_path: string) -> Object:
    // Domain-specific standards to remove from visible text
    DOMAIN_STANDARDS = [
        "DO-178C", "ISO 26262", "IEC 62304", "ISO 14971",
        "FDA 21 CFR 820", "IEC 61508", "MISRA", "CERT-C"
    ]
    // Standards to retain (universally applicable)
    RETAINED_STANDARDS = [
        "IEEE 1016", "ISO 29119", "ISO 29119-4",
        "IEEE 42010", "INCOSE"
    ]

    lines = read_lines(command_path)
    replacements = 0

    FOR i = 0 TO length(lines) - 1:
        original_line = lines[i]

        // Remove domain-specific standard references from inline text
        FOR EACH std IN DOMAIN_STANDARDS:
            IF lines[i] contains std:
                // Remove standard and surrounding separators (", ", " / ", " and ")
                lines[i] = regex_replace(lines[i], ",?\s*{escaped(std)}\s*,?", "")
                lines[i] = regex_replace(lines[i], "\s*/\s*{escaped(std)}\s*", "")
                lines[i] = regex_replace(lines[i], "\s+and\s+{escaped(std)}", "")

        // Remove "regulatory-grade" qualifier
        lines[i] = regex_replace(lines[i], "(?i)regulatory-grade\s*", "")

        // Clean up any resulting double spaces or trailing commas
        lines[i] = regex_replace(lines[i], "\s{2,}", " ")
        lines[i] = regex_replace(lines[i], ",\s*$", "")
        lines[i] = regex_replace(lines[i], ",\s*\)", ")")

        IF lines[i] != original_line:
            replacements += 1

    write_file(command_path, join(lines, "\n"))
    RETURN {"replacements": replacements}
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| DOMAIN_STANDARDS | List[string] | 8 entries | Hardcoded constant | Standards to strip from text |
| RETAINED_STANDARDS | List[string] | 5 entries | Hardcoded constant | Standards to preserve (reference only) |
| lines | List[string] | Variable | Read from file | File content as line array |
| replacements | integer | ≥0 | 0 | Count of lines modified |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| File read/write error | System exception | N/A (system) | Check permissions |
| No replacements needed | Return {replacements: 0} | diff_summary | File was already clean |

---

### Module: MOD-012 (clean_hardcoded_command_content)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `scripts/bash/refactor/clean-hardcoded-commands.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION clean_hardcoded_command_content(command_path: string, scan_report: List[Object]) -> Object:
    HARDCODED_COMMANDS = ["trace.md", "hazard-analysis.md", "peer-review.md"]

    filename = basename(command_path)
    IF filename NOT IN HARDCODED_COMMANDS:
        PRINT_ERROR "Not a HARDCODED command: {filename}"
        RETURN {"error": "invalid_target"}

    lines = read_lines(command_path)
    lines_removed = 0
    lines_added = 0

    // Step 1: Remove unconditional regulatory references from goal/constraint sections
    FOR i = 0 TO length(lines) - 1:
        // Replace "regulatory-grade" with domain-agnostic language
        IF lines[i] contains "regulatory-grade":
            lines[i] = regex_replace(lines[i], "(?i)regulatory-grade", "specification-grade")
            lines_added += 1

        // Remove standalone domain standard citations in goal sections
        IF lines[i] matches regex "(?i)^.*comply with (DO-178C|ISO 26262|IEC 62304|ISO 14971)":
            lines[i] = regex_replace(lines[i], "(?i)\s*comply with (DO-178C|ISO 26262|IEC 62304|ISO 14971)[^.]*\.", "")
            IF trim(lines[i]) is_blank:
                mark_for_removal(i)
                lines_removed += 1

    // Step 2: Remove "Freedom from Interference" and "ASIL Decomposition" prose
    FOR i = 0 TO length(lines) - 1:
        FOR EACH phrase IN ["Freedom from Interference", "ASIL Decomposition"]:
            IF lines[i] contains phrase:
                lines[i] = regex_replace(lines[i], "(?i)[^.]*{escaped(phrase)}[^.]*\.\s*", "")
                IF trim(lines[i]) is_blank:
                    mark_for_removal(i)
                    lines_removed += 1

    // Step 3: Apply removals in reverse
    remove_marked_lines(lines)

    write_file(command_path, join(lines, "\n"))
    RETURN {"lines_removed": lines_removed, "lines_added": lines_added}
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| HARDCODED_COMMANDS | List[string] | Exactly 3 | Hardcoded constant | Valid target filenames |
| lines | List[string] | Variable | Read from file | File content as line array |
| lines_removed | integer | ≥0 | 0 | Counter for removed lines |
| lines_added | integer | ≥0 | 0 | Counter for replacement lines |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Not a HARDCODED command | Return error object | N/A (precondition) | Provide valid target |
| File read/write error | System exception | N/A (system) | Check permissions |

---

### Module: MOD-013 (parameterize_hardcoded_tables)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `scripts/bash/refactor/clean-hardcoded-commands.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION parameterize_hardcoded_tables(command_path: string) -> Object:
    lines = read_lines(command_path)
    tables_modified = 0

    // Step 1: Find severity/classification tables
    // Pattern: Markdown table rows containing ASIL-A/B/C/D, DAL-A through DAL-E, SIL-1 through SIL-4
    i = 0
    WHILE i < length(lines):
        line = lines[i]

        // Detect table header with domain-specific column
        IF line matches regex "\|.*(?:ASIL|DAL|SIL|Safety Class|Criticality Level).*\|":
            // Replace domain-specific column header with generic
            lines[i] = regex_replace(lines[i], "(?i)ASIL\s*(Level)?", "Severity Level")
            lines[i] = regex_replace(lines[i], "(?i)DAL\s*(Level)?", "Severity Level")
            lines[i] = regex_replace(lines[i], "(?i)SIL\s*(Level)?", "Severity Level")

            // Process subsequent table rows
            j = i + 1
            // Skip separator row
            IF j < length(lines) AND lines[j] matches regex "^\|[\s\-:|]+\|$":
                j += 1

            WHILE j < length(lines) AND lines[j] starts_with "|":
                // Replace specific ASIL/DAL/SIL values with generic severity
                lines[j] = regex_replace(lines[j], "(?i)ASIL[\s-]*[A-D]", "Level [domain-specific]")
                lines[j] = regex_replace(lines[j], "(?i)DAL[\s-]*[A-E]", "Level [domain-specific]")
                lines[j] = regex_replace(lines[j], "(?i)SIL[\s-]*[1-4]", "Level [domain-specific]")
                j += 1

            tables_modified += 1
            i = j
            CONTINUE

        i += 1

    // Step 2: Parameterize governing standard mapping
    FOR i = 0 TO length(lines) - 1:
        IF lines[i] matches regex "(?i)governing standard.*:":
            // Replace specific standard names with domain-agnostic reference
            lines[i] = regex_replace(lines[i], "DO-178C|ISO 26262|IEC 62304", "[per domain configuration]")

    write_file(command_path, join(lines, "\n"))
    RETURN {"tables_modified": tables_modified}
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| lines | List[string] | Variable | Read from file | File content as line array |
| tables_modified | integer | ≥0 | 0 | Count of tables parameterized |
| i, j | integer | ≥0 | Loop counters | Line position trackers |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| No tables found | Return {tables_modified: 0} | diff_summary | File had no severity tables |
| File read/write error | System exception | N/A (system) | Check permissions |

---

### Module: MOD-014 (compose_loading_instruction_block)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `scripts/bash/refactor/inject-loading-instruction.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION compose_loading_instruction_block(command_name: string) -> string:
    // Build the standardized domain loading instruction text
    block = ""
    block += "### Domain Overlay Loading\n\n"
    block += "1. Read `v-model-config.yml` at the repository root.\n"
    block += "2. Check the `domain` field.\n"
    block += "3. If `domain` is set to a supported value (`iso_26262`, `do_178c`, `iec_62304`):\n"
    block += "   - Read `commands/overlays/{domain}/{command_name}.md`\n"
    block += "   - Append the overlay content after the base command content.\n"
    block += "   - The overlay may add domain-specific sections, techniques, or constraints.\n"
    block += "4. If `domain` is absent, empty, or unsupported: proceed with base content only.\n"

    RETURN block
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| command_name | string | Non-empty | Function parameter | Name used in overlay path (e.g., "system-design") |
| block | string | ~450 chars | Empty string | Assembled instruction text |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Empty command_name | Return empty string | N/A (precondition) | Caller provides non-empty name |

---

### Module: MOD-015 (inject_loading_instruction)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `scripts/bash/refactor/inject-loading-instruction.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION inject_loading_instruction(command_path: string) -> integer:
    command_name = strip_extension(basename(command_path))

    // Step 1: Read file
    content = read_file(command_path)

    // Step 2: Check for existing instruction block
    IF content contains "### Domain Overlay Loading":
        PRINT "duplicate_injection: instruction block already present in {command_path} — skipping"
        RETURN 0

    // Step 3: Check for and remove ad-hoc conditional patterns
    ad_hoc_patterns = [
        "(?i)if\s+domain\s+is\s+set",
        "(?i)if\s+.*v-model-config.*domain",
        "(?i)when\s+domain\s+is\s+configured"
    ]
    ad_hoc_count = 0
    lines = split(content, "\n")
    FOR i = length(lines) - 1 DOWNTO 0:
        FOR EACH pattern IN ad_hoc_patterns:
            IF lines[i] matches regex pattern:
                remove_line(lines, i)
                ad_hoc_count += 1
                BREAK

    // Step 4: Find injection point (after "## Execution Steps" or before "## Operating Constraints")
    injection_index = -1
    FOR i = 0 TO length(lines) - 1:
        IF lines[i] matches regex "^## Operating Constraints":
            injection_index = i
            BREAK

    IF injection_index == -1:
        injection_index = length(lines)  // Append at end

    // Step 5: Compose and inject instruction block
    instruction = compose_loading_instruction_block(command_name)
    insert_lines(lines, injection_index, split(instruction, "\n"))

    // Step 6: Write back
    write_file(command_path, join(lines, "\n"))

    PRINT_JSON {"injected": true, "ad_hoc_patterns_found": ad_hoc_count}
    RETURN 0
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| ad_hoc_patterns | List[string] | 3 regex patterns | Hardcoded constant | Patterns to detect and remove |
| ad_hoc_count | integer | ≥0 | 0 | Number of ad-hoc patterns removed |
| injection_index | integer | ≥0 | -1 | Line position for injection |
| instruction | string | ~450 chars | From MOD-014 | The instruction block text |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Block already present | Exit 0 | duplicate_injection (skip) | Idempotent |
| No injection point found | Exit 0 (append at end) | N/A | Instruction appended at EOF |
| File read/write error | Exit 1 | N/A (system) | Check permissions |

---

### Module: MOD-016 (parse_gate_boundaries)

**Parent Architecture Modules**: ARCH-010
**Target Source File(s)**: `scripts/bash/refactor/parse-template-gates.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION parse_gate_boundaries(template_path: string) -> integer:
    GATE_PATTERNS = [
        "<!-- SAFETY-CRITICAL SECTION -->",
        "<!-- DOMAIN-SPECIFIC SCALES -->",
        "<!-- SAFETY-CRITICAL TECHNIQUES -->",
        "<!-- END SAFETY-CRITICAL SECTION -->",
        "<!-- END DOMAIN-SPECIFIC SCALES -->",
        "<!-- END SAFETY-CRITICAL TECHNIQUES -->"
    ]
    OPEN_PATTERNS = {
        "<!-- SAFETY-CRITICAL SECTION -->": "SAFETY-CRITICAL",
        "<!-- DOMAIN-SPECIFIC SCALES -->": "DOMAIN-SCALES",
        "<!-- SAFETY-CRITICAL TECHNIQUES -->": "SAFETY-TECHNIQUES"
    }
    CLOSE_MAP = {
        "SAFETY-CRITICAL": "<!-- END SAFETY-CRITICAL SECTION -->",
        "DOMAIN-SCALES": "<!-- END DOMAIN-SPECIFIC SCALES -->",
        "SAFETY-TECHNIQUES": "<!-- END SAFETY-CRITICAL TECHNIQUES -->"
    }

    IF NOT file_exists(template_path):
        PRINT_ERROR "file_not_found: {template_path}"
        RETURN 1

    lines = read_lines(template_path)
    gate_blocks = []
    open_stack = []  // Stack for nested gates

    FOR i = 0 TO length(lines) - 1:
        trimmed = trim(lines[i])

        // Check for opening gate
        IF trimmed IN OPEN_PATTERNS:
            gate_type = OPEN_PATTERNS[trimmed]
            PUSH {gate_type: gate_type, start_line: i + 1} ONTO open_stack

        // Check for closing gate
        FOR EACH gate_type, close_pattern IN CLOSE_MAP:
            IF trimmed == close_pattern:
                IF open_stack is_empty OR top(open_stack).gate_type != gate_type:
                    PRINT_ERROR "malformed_gate: closing {close_pattern} at line {i+1} without matching open"
                    RETURN 1
                opened = POP open_stack
                content = join(lines[opened.start_line .. i - 1], "\n")
                APPEND {
                    "start_line": opened.start_line,
                    "end_line": i + 1,
                    "gate_type": gate_type,
                    "content": content
                } TO gate_blocks

    // Check for unclosed gates
    IF open_stack is NOT empty:
        unclosed = top(open_stack)
        PRINT_ERROR "malformed_gate: unclosed {unclosed.gate_type} starting at line {unclosed.start_line}"
        RETURN 1

    gate_types_found = unique([block.gate_type FOR EACH block IN gate_blocks])
    PRINT_JSON {"gate_blocks": gate_blocks, "gate_types_found": gate_types_found}
    RETURN 0
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| OPEN_PATTERNS | Map[string, string] | 3 entries | Hardcoded constant | Maps opening comment to gate type |
| CLOSE_MAP | Map[string, string] | 3 entries | Hardcoded constant | Maps gate type to closing comment |
| gate_blocks | List[Object] | Variable | Empty list | Collected {start, end, type, content} |
| open_stack | List[Object] | Max depth ~3 | Empty list | Stack for nested gate tracking |
| gate_types_found | List[string] | ≤3 | Computed | Distinct gate types in output |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| File not found | Exit 1 | file_not_found | Provide valid path |
| Unmatched closing gate | Exit 1 | malformed_gate | Fix template gate comments |
| Unclosed opening gate | Exit 1 | malformed_gate | Add missing close comment |
| No gates found | Exit 0 | gate_blocks = [] | File has no gated content |

---

### Module: MOD-017 (extract_gated_content)

**Parent Architecture Modules**: ARCH-011
**Target Source File(s)**: `scripts/bash/refactor/extract-template-content.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION extract_gated_content(template_path: string, gate_blocks: List[Object], target_domains: List[string], overlay_base: string) -> integer:
    // Step 1: Validate inputs
    IF length(gate_blocks) == 0:
        PRINT_ERROR "No gate blocks to extract"
        RETURN 1

    template_name = strip_extension(basename(template_path))
    overlay_files_created = []

    // Step 2: For each domain, write extracted content
    FOR EACH domain IN target_domains:
        target_dir = "{overlay_base}/templates/overlays/{domain}"
        IF NOT directory_exists(target_dir):
            PRINT_ERROR "target_dir_missing: {target_dir} — run ARCH-001 first"
            RETURN 1

        // Concatenate all gate block contents for this template
        overlay_content = "# {template_name} — {domain} overlay\n\n"
        FOR EACH block IN gate_blocks:
            overlay_content += "## {block.gate_type}\n\n"
            overlay_content += block.content + "\n\n"

        // Write overlay file
        overlay_path = "{target_dir}/{template_name}-overlay.md"
        write_file(overlay_path, overlay_content)
        APPEND overlay_path TO overlay_files_created

    PRINT_JSON {"overlay_files": overlay_files_created, "count": length(overlay_files_created)}
    RETURN 0
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| template_name | string | — | Derived from path | Base name without extension |
| overlay_files_created | List[string] | ≤ len(target_domains) | Empty list | Paths of created overlay files |
| overlay_content | string | Variable | Header line | Assembled overlay Markdown |
| target_dir | string | ~60 chars | Constructed per domain | Target overlay directory path |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| No gate blocks | Exit 1 | N/A (precondition) | Run MOD-016 first |
| Target directory missing | Exit 1 | target_dir_missing | Run ARCH-001 first |
| Write failure | Exit 1 | N/A (system) | Check permissions |

---

### Module: MOD-018 (clean_base_template)

**Parent Architecture Modules**: ARCH-011
**Target Source File(s)**: `scripts/bash/refactor/extract-template-content.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION clean_base_template(template_path: string, gate_blocks: List[Object]) -> integer:
    lines = read_lines(template_path)

    // Step 1: Build set of line ranges to remove (gate boundaries + content)
    ranges_to_remove = []
    FOR EACH block IN gate_blocks:
        // start_line and end_line are 1-indexed from MOD-016
        // Include the opening and closing comment lines themselves
        start = block.start_line - 1  // Convert to 0-indexed, -1 for opening comment
        end = block.end_line          // end_line is the closing comment (1-indexed)
        IF start < 0:
            start = 0
        APPEND {start: start, end: end} TO ranges_to_remove

    // Step 2: Merge overlapping ranges
    sort_ascending(ranges_to_remove, by: "start")
    merged = []
    FOR EACH range IN ranges_to_remove:
        IF merged is_empty OR range.start > last(merged).end + 1:
            APPEND range TO merged
        ELSE:
            last(merged).end = max(last(merged).end, range.end)

    // Step 3: Remove ranges in reverse order
    lines_removed = 0
    FOR i = length(merged) - 1 DOWNTO 0:
        range = merged[i]
        count = range.end - range.start + 1
        remove_lines(lines, range.start, range.end)
        lines_removed += count

    // Step 4: Verify zero gate patterns remain
    cleaned_content = join(lines, "\n")
    remaining_gates = count_occurrences(cleaned_content, "<!-- SAFETY-CRITICAL")
    remaining_gates += count_occurrences(cleaned_content, "<!-- DOMAIN-SPECIFIC")
    remaining_gates += count_occurrences(cleaned_content, "<!-- END SAFETY-CRITICAL")
    remaining_gates += count_occurrences(cleaned_content, "<!-- END DOMAIN-SPECIFIC")

    IF remaining_gates > 0:
        PRINT_ERROR "Cleaning incomplete: {remaining_gates} gate patterns remain"
        RETURN 1

    // Step 5: Write cleaned template
    write_file(template_path, cleaned_content)

    PRINT_JSON {"lines_removed": lines_removed, "remaining_gates": 0}
    RETURN 0
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| lines | List[string] | Variable | Read from file | Template content as line array |
| ranges_to_remove | List[Object] | ≤ len(gate_blocks) | Empty list | {start, end} line ranges |
| merged | List[Object] | ≤ len(ranges_to_remove) | Empty list | Non-overlapping merged ranges |
| lines_removed | integer | ≥0 | 0 | Total lines removed |
| remaining_gates | integer | Must be 0 | Computed | Verification count |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Gate patterns remain after cleaning | Exit 1 | N/A (incomplete cleaning) | Debug gate boundary parsing |
| File read/write error | Exit 1 | N/A (system) | Check permissions |

---

### Module: MOD-019 (populate_iso26262_command_overlays)

**Parent Architecture Modules**: ARCH-012
**Target Source File(s)**: `scripts/bash/populate/populate-iso26262.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION populate_iso26262_command_overlays(extracted_content: Map[string, string], repo_root: string) -> integer:
    target_dir = "{repo_root}/commands/overlays/iso_26262"
    REQUIRED_COMMANDS = [
        "system-design", "system-test", "architecture-design",
        "integration-test", "module-design", "unit-test",
        "trace", "hazard-analysis", "peer-review"
    ]

    IF NOT directory_exists(target_dir):
        PRINT_ERROR "target_dir_missing: {target_dir}"
        RETURN 1

    files_created = []
    FOR EACH cmd IN REQUIRED_COMMANDS:
        overlay_path = "{target_dir}/{cmd}.md"

        // Build overlay content with preference-based indirection
        content = "# {cmd} — ISO 26262 Domain Overlay\n\n"
        content += "## Applicable Standards\n\n"
        content += "- ISO 26262:2018 (Road vehicles — Functional safety)\n\n"
        content += "## Classification System\n\n"
        content += "Use ASIL (Automotive Safety Integrity Level) A through D.\n\n"

        // Append extracted domain-specific content if available
        IF cmd IN extracted_content AND extracted_content[cmd] is NOT empty:
            content += "## Domain-Specific Extensions\n\n"
            content += extracted_content[cmd] + "\n"
        ELSE:
            content += "## Domain-Specific Extensions\n\n"
            content += "<!-- Placeholder: populate with ISO 26262-specific content for {cmd} -->\n"

        write_file(overlay_path, content)
        APPEND overlay_path TO files_created

    // Verify minimum count
    IF length(files_created) < 9:
        PRINT_ERROR "content_missing: expected ≥9 overlays, created {length(files_created)}"
        RETURN 1

    PRINT_JSON {"overlay_files": files_created, "file_count": length(files_created)}
    RETURN 0
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| REQUIRED_COMMANDS | List[string] | Exactly 9 | Hardcoded constant | Commands needing ISO 26262 overlays |
| target_dir | string | ~50 chars | Constructed | Path to iso_26262 overlay directory |
| files_created | List[string] | ≥9 expected | Empty list | Paths of created overlay files |
| content | string | Variable | Header lines | Assembled overlay Markdown |
| extracted_content | Map[string, string] | Variable | Function parameter | Content extracted by ARCH-007/008 |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Target directory missing | Exit 1 | N/A (precondition) | Run ARCH-001 first |
| Fewer than 9 overlays | Exit 1 | content_missing | Check extracted content |
| Missing extracted content for a command | Placeholder written | N/A (graceful) | Populate later |

---

### Module: MOD-020 (populate_iso26262_template_overlays)

**Parent Architecture Modules**: ARCH-012
**Target Source File(s)**: `scripts/bash/populate/populate-iso26262.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION populate_iso26262_template_overlays(extracted_content: Map[string, string], repo_root: string) -> integer:
    target_dir = "{repo_root}/templates/overlays/iso_26262"

    IF NOT directory_exists(target_dir):
        PRINT_ERROR "target_dir_missing: {target_dir}"
        RETURN 1

    files_created = []

    // Process each extracted template overlay
    FOR EACH template_name, content IN extracted_content:
        IF content is NOT empty:
            overlay_path = "{target_dir}/{template_name}-overlay.md"
            overlay_content = "# {template_name} — ISO 26262 Template Overlay\n\n"
            overlay_content += content + "\n"
            write_file(overlay_path, overlay_content)
            APPEND overlay_path TO files_created

    PRINT_JSON {"overlay_files": files_created, "file_count": length(files_created)}
    RETURN 0
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| target_dir | string | ~50 chars | Constructed | Path to iso_26262 template overlay dir |
| files_created | List[string] | Variable | Empty list | Paths of created overlay files |
| extracted_content | Map[string, string] | Variable | Function parameter | Content from ARCH-011 extraction |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Target directory missing | Exit 1 | target_dir_missing | Run ARCH-001 first |
| No extracted content | Exit 0 (empty list) | file_count = 0 | Verify ARCH-011 extraction |

---

### Module: MOD-021 (populate_do178c_command_overlays)

**Parent Architecture Modules**: ARCH-013
**Target Source File(s)**: `scripts/bash/populate/populate-do178c.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION populate_do178c_command_overlays(extracted_content: Map[string, string], repo_root: string) -> integer:
    target_dir = "{repo_root}/commands/overlays/do_178c"
    REQUIRED_COMMANDS = [
        "architecture-design", "module-design", "unit-test",
        "trace", "hazard-analysis", "peer-review"
    ]

    IF NOT directory_exists(target_dir):
        PRINT_ERROR "target_dir_missing: {target_dir}"
        RETURN 1

    files_created = []
    FOR EACH cmd IN REQUIRED_COMMANDS:
        overlay_path = "{target_dir}/{cmd}.md"
        content = "# {cmd} — DO-178C Domain Overlay\n\n"
        content += "## Applicable Standards\n\n"
        content += "- DO-178C (Software Considerations in Airborne Systems and Equipment Certification)\n\n"
        content += "## Classification System\n\n"
        content += "Use DAL (Design Assurance Level) A through E.\n\n"

        IF cmd IN extracted_content AND extracted_content[cmd] is NOT empty:
            content += "## Domain-Specific Extensions\n\n"
            content += extracted_content[cmd] + "\n"
        ELSE:
            content += "## Domain-Specific Extensions\n\n"
            content += "<!-- Placeholder: populate with DO-178C-specific content for {cmd} -->\n"

        write_file(overlay_path, content)
        APPEND overlay_path TO files_created

    IF length(files_created) < 6:
        PRINT_ERROR "content_missing: expected ≥6 overlays, created {length(files_created)}"
        RETURN 1

    PRINT_JSON {"overlay_files": files_created, "file_count": length(files_created)}
    RETURN 0
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| REQUIRED_COMMANDS | List[string] | Exactly 6 | Hardcoded constant | Commands needing DO-178C overlays |
| target_dir | string | ~50 chars | Constructed | Path to do_178c overlay directory |
| files_created | List[string] | ≥6 expected | Empty list | Paths of created overlay files |
| content | string | Variable | Header lines | Assembled overlay Markdown |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Target directory missing | Exit 1 | N/A (precondition) | Run ARCH-001 first |
| Fewer than 6 overlays | Exit 1 | content_missing | Check extracted content |

---

### Module: MOD-022 (populate_do178c_template_overlays)

**Parent Architecture Modules**: ARCH-013
**Target Source File(s)**: `scripts/bash/populate/populate-do178c.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION populate_do178c_template_overlays(extracted_content: Map[string, string], repo_root: string) -> integer:
    target_dir = "{repo_root}/templates/overlays/do_178c"

    IF NOT directory_exists(target_dir):
        PRINT_ERROR "target_dir_missing: {target_dir}"
        RETURN 1

    files_created = []
    FOR EACH template_name, content IN extracted_content:
        IF content is NOT empty:
            overlay_path = "{target_dir}/{template_name}-overlay.md"
            overlay_content = "# {template_name} — DO-178C Template Overlay\n\n"
            overlay_content += content + "\n"
            write_file(overlay_path, overlay_content)
            APPEND overlay_path TO files_created

    PRINT_JSON {"overlay_files": files_created, "file_count": length(files_created)}
    RETURN 0
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| target_dir | string | ~50 chars | Constructed | Path to do_178c template overlay dir |
| files_created | List[string] | Variable | Empty list | Paths of created overlay files |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Target directory missing | Exit 1 | target_dir_missing | Run ARCH-001 first |
| No extracted content | Exit 0 (empty list) | file_count = 0 | Verify ARCH-011 extraction |

---

### Module: MOD-023 (populate_iec62304_command_overlays)

**Parent Architecture Modules**: ARCH-014
**Target Source File(s)**: `scripts/bash/populate/populate-iec62304.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION populate_iec62304_command_overlays(extracted_content: Map[string, string], repo_root: string) -> integer:
    target_dir = "{repo_root}/commands/overlays/iec_62304"
    REQUIRED_COMMANDS = ["hazard-analysis", "trace", "peer-review"]

    IF NOT directory_exists(target_dir):
        PRINT_ERROR "target_dir_missing: {target_dir}"
        RETURN 1

    files_created = []
    FOR EACH cmd IN REQUIRED_COMMANDS:
        overlay_path = "{target_dir}/{cmd}.md"
        content = "# {cmd} — IEC 62304 Domain Overlay\n\n"
        content += "## Applicable Standards\n\n"
        content += "- IEC 62304:2006+A1:2015 (Medical device software — Software life cycle processes)\n\n"
        content += "## Classification System\n\n"
        content += "Use Safety Class A, B, or C.\n\n"

        IF cmd IN extracted_content AND extracted_content[cmd] is NOT empty:
            content += "## Domain-Specific Extensions\n\n"
            content += extracted_content[cmd] + "\n"
        ELSE:
            content += "## Domain-Specific Extensions\n\n"
            content += "<!-- Placeholder: populate with IEC 62304-specific content for {cmd} -->\n"

        write_file(overlay_path, content)
        APPEND overlay_path TO files_created

    IF length(files_created) < 3:
        PRINT_ERROR "content_missing: expected ≥3 overlays, created {length(files_created)}"
        RETURN 1

    PRINT_JSON {"overlay_files": files_created, "file_count": length(files_created)}
    RETURN 0
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| REQUIRED_COMMANDS | List[string] | Exactly 3 | Hardcoded constant | Commands needing IEC 62304 overlays |
| target_dir | string | ~50 chars | Constructed | Path to iec_62304 overlay directory |
| files_created | List[string] | ≥3 expected | Empty list | Paths of created overlay files |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Target directory missing | Exit 1 | N/A (precondition) | Run ARCH-001 first |
| Fewer than 3 overlays | Exit 1 | content_missing | Check extracted content |

---

### Module: MOD-024 (populate_iec62304_template_overlays)

**Parent Architecture Modules**: ARCH-014
**Target Source File(s)**: `scripts/bash/populate/populate-iec62304.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION populate_iec62304_template_overlays(extracted_content: Map[string, string], repo_root: string) -> integer:
    target_dir = "{repo_root}/templates/overlays/iec_62304"

    IF NOT directory_exists(target_dir):
        PRINT_ERROR "target_dir_missing: {target_dir}"
        RETURN 1

    files_created = []
    FOR EACH template_name, content IN extracted_content:
        IF content is NOT empty:
            overlay_path = "{target_dir}/{template_name}-overlay.md"
            overlay_content = "# {template_name} — IEC 62304 Template Overlay\n\n"
            overlay_content += content + "\n"
            write_file(overlay_path, overlay_content)
            APPEND overlay_path TO files_created

    PRINT_JSON {"overlay_files": files_created, "file_count": length(files_created)}
    RETURN 0
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| target_dir | string | ~50 chars | Constructed | Path to iec_62304 template overlay dir |
| files_created | List[string] | Variable | Empty list | Paths of created overlay files |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Target directory missing | Exit 1 | target_dir_missing | Run ARCH-001 first |
| No extracted content | Exit 0 (empty list) | file_count = 0 | Verify ARCH-011 extraction |

---

### Module: MOD-025 (rewrite_extension_descriptions)

**Parent Architecture Modules**: ARCH-015
**Target Source File(s)**: `scripts/bash/metadata/rewrite-extension-desc.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION rewrite_extension_descriptions(extension_path: string, repo_root: string) -> integer:
    // Domain-specific terms to remove from descriptions
    DESCRIPTION_CLEANUP = [
        "DO-178C", "ISO 26262", "IEC 62304", "ISO 14971",
        "FDA 21 CFR 820", "IEC 61508", "MISRA", "CERT-C",
        "regulatory-grade", "safety-compliant"
    ]

    // Step 1: Read extension.yml
    IF NOT file_exists(extension_path):
        PRINT_ERROR "file_not_found: {extension_path}"
        RETURN 1

    content = read_file(extension_path)

    // Step 2: Verify safety-critical tag exists (preserve it)
    IF content NOT contains "safety-critical":
        PRINT_ERROR "tag_removed: safety-critical tag not found — aborting to prevent loss"
        RETURN 1

    // Step 3: Find and rewrite each command description
    lines = split(content, "\n")
    descriptions_changed = 0
    i = 0

    WHILE i < length(lines):
        // Detect description field (indented under a command entry)
        IF lines[i] matches regex "^\s+description:\s+":
            original = lines[i]
            desc_text = extract_after(lines[i], "description:")
            modified = false

            FOR EACH term IN DESCRIPTION_CLEANUP:
                IF desc_text contains term:
                    // Remove term and surrounding punctuation
                    desc_text = regex_replace(desc_text, ",?\s*{escaped(term)}[^,.)]*", "")
                    modified = true

            // Clean up resulting artifacts
            IF modified:
                desc_text = regex_replace(desc_text, "\s{2,}", " ")
                desc_text = regex_replace(desc_text, "^\s*,\s*", "")
                desc_text = trim(desc_text)
                lines[i] = regex_replace(lines[i], "description:\s+.*", "description: {desc_text}")
                descriptions_changed += 1

        i += 1

    // Step 4: Final safety-critical tag check
    new_content = join(lines, "\n")
    IF new_content NOT contains "safety-critical":
        PRINT_ERROR "tag_removed: rewriting inadvertently removed safety-critical tag"
        RETURN 1

    // Step 5: Write updated file
    write_file(extension_path, new_content)

    PRINT_JSON {"descriptions_changed": descriptions_changed, "expected": 9}
    IF descriptions_changed < 9:
        PRINT "Warning: only {descriptions_changed}/9 descriptions modified"
    RETURN 0
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| DESCRIPTION_CLEANUP | List[string] | 10 entries | Hardcoded constant | Terms to strip from descriptions |
| lines | List[string] | Variable | Split from file | Extension YAML as line array |
| descriptions_changed | integer | Expected 9 | 0 | Counter for modified descriptions |
| desc_text | string | Variable | Extracted from line | Current description text being processed |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| File not found | Exit 1 | file_not_found | Provide valid path |
| Safety-critical tag missing (pre) | Exit 1 | tag_removed | Restore tag before running |
| Safety-critical tag lost (post) | Exit 1 | tag_removed | Bug in cleanup regex |
| Fewer than 9 descriptions changed | Exit 0 (warning) | descriptions_changed | Some already clean |

---

### Module: MOD-026 (map_commands_to_features)

**Parent Architecture Modules**: ARCH-016
**Target Source File(s)**: `scripts/bash/lifecycle/map-parent-features.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION map_commands_to_features(command_names: List[string]) -> integer:
    // Fixed mapping: command name → parent feature ID
    COMMAND_FEATURE_MAP = {
        "system-design":      "002",
        "system-test":        "002",
        "architecture-design": "003",
        "integration-test":   "003",
        "module-design":      "004",
        "unit-test":          "004",
        "trace":              "001",
        "hazard-analysis":    "005a",
        "peer-review":        "005c"
    }

    mapping_table = []
    FOR EACH cmd IN command_names:
        IF cmd NOT IN COMMAND_FEATURE_MAP:
            PRINT_ERROR "unmapped_command: {cmd} not in fixed mapping"
            RETURN 1

        feature_id = COMMAND_FEATURE_MAP[cmd]

        // Construct artifact paths for the parent feature
        feature_dir = find_spec_dir_by_feature_id(feature_id)
        artifact_paths = []
        IF directory_exists("{feature_dir}/v-model"):
            FOR EACH file IN list_directory("{feature_dir}/v-model"):
                IF file ends_with ".md":
                    APPEND "{feature_dir}/v-model/{file}" TO artifact_paths

        APPEND {
            "command": cmd,
            "feature_id": feature_id,
            "artifact_paths": artifact_paths
        } TO mapping_table

    PRINT_JSON {"mapping_table": mapping_table}
    RETURN 0

FUNCTION find_spec_dir_by_feature_id(feature_id: string) -> string:
    // Scan specs/ directory for matching feature directory
    FOR EACH dir IN list_directory("specs/"):
        IF dir starts_with "{feature_id}-":
            RETURN "specs/{dir}"
    RETURN "specs/{feature_id}"  // Fallback
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| COMMAND_FEATURE_MAP | Map[string, string] | Exactly 9 entries | Hardcoded constant | Fixed command-to-feature mapping |
| mapping_table | List[Object] | 9 entries expected | Empty list | Assembled mapping result |
| artifact_paths | List[string] | Variable | Empty per command | V-Model artifacts in parent feature |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Unmapped command | Exit 1 | unmapped_command | Should never occur with valid input |
| Feature directory not found | Fallback path used | N/A (graceful) | Directory may not yet exist |

---

### Module: MOD-027 (locate_artifact_ids)

**Parent Architecture Modules**: ARCH-017
**Target Source File(s)**: `scripts/bash/lifecycle/annotate-modified.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION locate_artifact_ids(artifact_path: string, id_pattern: string) -> List[Object]:
    // id_pattern examples: "REQ-", "SYS-", "ARCH-", "STP-", "ATP-"

    IF NOT file_exists(artifact_path):
        RETURN []

    lines = read_lines(artifact_path)
    located_ids = []

    FOR i = 0 TO length(lines) - 1:
        line = lines[i]
        // Find all IDs matching the pattern in this line
        matches = regex_find_all(line, "{id_pattern}\\d{3}(-[A-Z])?")
        FOR EACH match IN matches:
            // Skip IDs that are already annotated
            IF line NOT contains "[MODIFIED" AND line NOT contains "[DEPRECATED":
                APPEND {
                    "id": match,
                    "line_number": i + 1,
                    "artifact_path": artifact_path,
                    "line_content": trim(line)
                } TO located_ids

    RETURN located_ids
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| lines | List[string] | Variable | Read from file | Artifact content as line array |
| located_ids | List[Object] | Variable | Empty list | Found ID locations with metadata |
| matches | List[string] | Variable per line | From regex | IDs found on current line |
| id_pattern | string | Non-empty | Function parameter | Regex prefix to match (e.g., "REQ-") |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| File not found | Return empty list | N/A (graceful) | File may not exist yet |
| No IDs found | Return empty list | N/A | File may have no matching IDs |

---

### Module: MOD-028 (write_modified_annotations)

**Parent Architecture Modules**: ARCH-017
**Target Source File(s)**: `scripts/bash/lifecycle/annotate-modified.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION write_modified_annotations(mapping_table: List[Object], contamination_type: string) -> integer:
    // Check Feature 006b lifecycle model availability
    lifecycle_available = check_006b_availability()
    IF NOT lifecycle_available:
        PRINT_ERROR "lifecycle_unavailable: Feature 006b lifecycle model required for cross-feature evolution"
        RETURN 1

    ANNOTATION_TEMPLATES = {
        "MIXED": "[MODIFIED — Domain-specific content extracted to overlay per Feature 006a]",
        "HARDCODED": "[MODIFIED — Unconditional domain-specific content removed from base and relocated to overlay per Feature 006a]"
    }

    IF contamination_type NOT IN ANNOTATION_TEMPLATES:
        PRINT_ERROR "Invalid contamination type: {contamination_type}"
        RETURN 1

    annotation = ANNOTATION_TEMPLATES[contamination_type]
    annotations_written = 0
    annotated_files = []

    FOR EACH entry IN mapping_table:
        FOR EACH artifact_path IN entry.artifact_paths:
            // Determine which ID patterns to look for based on artifact type
            id_patterns = determine_id_patterns(artifact_path)

            FOR EACH pattern IN id_patterns:
                located = locate_artifact_ids(artifact_path, pattern)

                IF length(located) > 0:
                    lines = read_lines(artifact_path)
                    FOR EACH loc IN located:
                        line_idx = loc.line_number - 1
                        // Append annotation after the ID on the same line
                        IF lines[line_idx] NOT contains "[MODIFIED":
                            lines[line_idx] = lines[line_idx] + " " + annotation
                            annotations_written += 1

                    write_file(artifact_path, join(lines, "\n"))
                    IF artifact_path NOT IN annotated_files:
                        APPEND artifact_path TO annotated_files

    PRINT_JSON {"annotated_files": annotated_files, "annotations_written": annotations_written}
    RETURN 0

FUNCTION determine_id_patterns(artifact_path: string) -> List[string]:
    filename = basename(artifact_path)
    IF filename == "requirements.md": RETURN ["REQ-"]
    IF filename == "system-design.md": RETURN ["SYS-"]
    IF filename == "architecture-design.md": RETURN ["ARCH-"]
    IF filename == "module-design.md": RETURN ["MOD-"]
    IF filename contains "test": RETURN ["STP-", "ATP-", "ITP-", "UTP-"]
    RETURN ["REQ-", "SYS-", "ARCH-", "MOD-"]  // Fallback: search all

FUNCTION check_006b_availability() -> boolean:
    RETURN file_exists("specs/006b-id-lifecycle/v-model/requirements.md")
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| ANNOTATION_TEMPLATES | Map[string, string] | 2 entries | Hardcoded constant | MIXED and HARDCODED annotation text |
| annotation | string | ~80 chars | Looked up by type | Selected annotation template |
| annotations_written | integer | ≥0 | 0 | Total annotations applied |
| annotated_files | List[string] | Variable | Empty list | Files that were modified |
| mapping_table | List[Object] | From ARCH-016 | Function parameter | Command-to-feature mapping |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| 006b lifecycle unavailable | Exit 1 | lifecycle_unavailable | Complete Feature 006b first |
| Invalid contamination type | Exit 1 | N/A (precondition) | Use "MIXED" or "HARDCODED" |
| No IDs found to annotate | Exit 0 | annotations_written = 0 | Artifacts may already be annotated |

---

### Module: MOD-029 (traverse_and_mark_suspects)

**Parent Architecture Modules**: ARCH-018
**Target Source File(s)**: `scripts/bash/lifecycle/cascade-suspects.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION traverse_and_mark_suspects(modified_ids: List[Object]) -> integer:
    // modified_ids: [{id, artifact_path, annotation}] from ARCH-017

    // Step 1: Build traceability map from V-Model artifacts
    // The chain: REQ → SYS → ARCH → MOD (design chain)
    // Paired:    REQ → ATP, SYS → STP, ARCH → ITP, MOD → UTP (test chain)
    TRACE_CHAIN = {
        "REQ": ["SYS", "ATP"],
        "SYS": ["ARCH", "STP"],
        "ARCH": ["MOD", "ITP"],
        "MOD": ["UTP"]
    }

    suspect_items = []
    visited = {}  // Prevent infinite loops

    // Step 2: For each MODIFIED ID, cascade downstream
    FOR EACH mod_entry IN modified_ids:
        id = mod_entry.id
        prefix = extract_prefix(id)  // "REQ", "SYS", "ARCH", "MOD"

        IF prefix NOT IN TRACE_CHAIN:
            CONTINUE  // Test IDs don't cascade further

        downstream_types = TRACE_CHAIN[prefix]
        FOR EACH ds_type IN downstream_types:
            // Find artifacts containing references to the modified ID
            ds_artifacts = find_artifacts_referencing(id, ds_type)

            FOR EACH ds_artifact IN ds_artifacts:
                ds_lines = read_lines(ds_artifact.path)
                FOR EACH line_idx IN ds_artifact.matching_lines:
                    ds_id = extract_id_from_line(ds_lines[line_idx], ds_type)
                    key = "{ds_id}@{ds_artifact.path}"

                    IF key IN visited:
                        CONTINUE
                    visited[key] = true

                    // Mark as SUSPECT
                    suspect_annotation = "[SUSPECT — Parent {id} modified]"
                    IF ds_lines[line_idx] NOT contains "[SUSPECT":
                        ds_lines[line_idx] = ds_lines[line_idx] + " " + suspect_annotation

                    APPEND {
                        "id": ds_id,
                        "artifact_path": ds_artifact.path,
                        "parent_id": id,
                        "annotation": suspect_annotation
                    } TO suspect_items

                write_file(ds_artifact.path, join(ds_lines, "\n"))

                // Recursively cascade from newly marked suspects
                traverse_and_mark_suspects([last(suspect_items)])

    total = length(suspect_items)
    PRINT_JSON {"suspect_items": suspect_items, "total": total}
    RETURN 0

FUNCTION extract_prefix(id: string) -> string:
    // "REQ-001" → "REQ", "SYS-002" → "SYS"
    RETURN substring_before(id, "-")

FUNCTION find_artifacts_referencing(parent_id: string, target_type: string) -> List[Object]:
    // Search V-Model artifacts for references to parent_id in target_type context
    artifact_map = {
        "SYS": "system-design.md",
        "ARCH": "architecture-design.md",
        "MOD": "module-design.md",
        "ATP": "acceptance-plan.md",
        "STP": "system-test.md",
        "ITP": "integration-test.md",
        "UTP": "unit-test.md"
    }
    target_file = artifact_map[target_type]
    results = grep_file(target_file, parent_id)
    RETURN results
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| TRACE_CHAIN | Map[string, List[string]] | 4 entries | Hardcoded constant | Design+test cascade relationships |
| suspect_items | List[Object] | Variable | Empty list | Accumulated SUSPECT markings |
| visited | Map[string, boolean] | Variable | Empty map | Cycle prevention tracker |
| modified_ids | List[Object] | From ARCH-017 | Function parameter | IDs that were marked MODIFIED |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Traceability gap (no downstream) | Reported in output | traceability_gap | May indicate incomplete specs |
| Cycle detected | Skipped via visited map | N/A | Normal for cross-references |
| Artifact file not found | Skipped | N/A (graceful) | File may not exist yet |

---

### Module: MOD-030 (resolve_extractive_suspects)

**Parent Architecture Modules**: ARCH-018
**Target Source File(s)**: `scripts/bash/lifecycle/cascade-suspects.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION resolve_extractive_suspects(suspect_items: List[Object]) -> integer:
    // For extractive-only changes (content moved, functional intent unchanged),
    // suspects can be resolved as "confirmed still valid" without content changes.

    total = length(suspect_items)
    resolved = 0
    requiring_update = 0

    FOR EACH item IN suspect_items:
        // Determine if the parent modification was extractive-only
        parent_annotation = get_annotation_for_id(item.parent_id)

        IF parent_annotation contains "extracted to overlay" OR parent_annotation contains "relocated to overlay":
            // Extractive-only: functional intent unchanged
            // Resolve by updating the SUSPECT annotation
            lines = read_lines(item.artifact_path)
            FOR i = 0 TO length(lines) - 1:
                IF lines[i] contains item.id AND lines[i] contains "[SUSPECT":
                    // Replace SUSPECT with resolution
                    lines[i] = regex_replace(
                        lines[i],
                        "\\[SUSPECT — Parent .* modified\\]",
                        "[SUSPECT — RESOLVED: extractive-only change, confirmed still valid per Feature 006a]"
                    )
                    resolved += 1
                    BREAK

            write_file(item.artifact_path, join(lines, "\n"))
        ELSE:
            // Non-extractive: requires manual content review
            requiring_update += 1

    PRINT_JSON {
        "resolution_summary": {
            "total": total,
            "resolved": resolved,
            "requiring_update": requiring_update
        }
    }
    RETURN 0

FUNCTION get_annotation_for_id(id: string) -> string:
    // Search for the MODIFIED annotation on the given ID across all V-Model artifacts
    FOR EACH artifact IN list_all_vmodel_artifacts():
        content = read_file(artifact)
        match = regex_find(content, "{id}.*\\[MODIFIED — ([^\\]]+)\\]")
        IF match:
            RETURN match
    RETURN ""
```

#### State Machine View

N/A — Stateless

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| suspect_items | List[Object] | From MOD-029 | Function parameter | Items marked SUSPECT |
| total | integer | ≥0 | len(suspect_items) | Total suspects to process |
| resolved | integer | ≥0 | 0 | Suspects resolved as extractive-only |
| requiring_update | integer | ≥0 | 0 | Suspects needing manual review |
| parent_annotation | string | Variable | From search | The MODIFIED annotation text |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Annotation not found for parent | requiring_update++ | N/A (conservative) | Manual review needed |
| File read/write error | Exit 1 | N/A (system) | Check permissions |
| resolved + requiring_update ≠ total | Bug indicator | resolution_summary invariant | Debug resolution logic |

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Module Designs (MOD) | 30 (30 active, 0 deprecated, 0 suspect) |
| External Modules (`[EXTERNAL]`) | 0 |
| Cross-Cutting Modules (`[CROSS-CUTTING]`) | 0 |
| Stateful Modules | 0 |
| Stateless Modules | 30 |
| Total Parent Architecture Modules Covered | 18 / 18 (100%) (active items only) |
| Modules with Pseudocode | 30 / 30 (100%) |
| **Forward Coverage (ARCH→MOD)** | **100%** (active items only) |

### Architecture Module Coverage Matrix

| ARCH ID | Covered by MOD |
|---------|---------------|
| ARCH-001 | MOD-001, MOD-002 |
| ARCH-002 | MOD-003, MOD-004 |
| ARCH-003 | MOD-005, MOD-006 |
| ARCH-004 | MOD-007 |
| ARCH-005 | MOD-008 |
| ARCH-006 | MOD-009 |
| ARCH-007 | MOD-010, MOD-011 |
| ARCH-008 | MOD-012, MOD-013 |
| ARCH-009 | MOD-014, MOD-015 |
| ARCH-010 | MOD-016 |
| ARCH-011 | MOD-017, MOD-018 |
| ARCH-012 | MOD-019, MOD-020 |
| ARCH-013 | MOD-021, MOD-022 |
| ARCH-014 | MOD-023, MOD-024 |
| ARCH-015 | MOD-025 |
| ARCH-016 | MOD-026 |
| ARCH-017 | MOD-027, MOD-028 |
| ARCH-018 | MOD-029, MOD-030 |

### Target Source File Summary

| Script Path | MODs | ARCH |
|-------------|------|------|
| `scripts/bash/overlay/create-overlay-dirs.sh` | MOD-001, MOD-002 | ARCH-001 |
| `scripts/bash/overlay/validate-manifest.sh` | MOD-003, MOD-004 | ARCH-002 |
| `scripts/bash/overlay/generate-manifest.sh` | MOD-005, MOD-006 | ARCH-003 |
| `scripts/bash/overlay/inject-config-domain.sh` | MOD-007 | ARCH-004 |
| `scripts/bash/overlay/resolve-domain.sh` | MOD-008 | ARCH-005 |
| `scripts/bash/refactor/scan-domain-terms.sh` | MOD-009 | ARCH-006 |
| `scripts/bash/refactor/clean-mixed-commands.sh` | MOD-010, MOD-011 | ARCH-007 |
| `scripts/bash/refactor/clean-hardcoded-commands.sh` | MOD-012, MOD-013 | ARCH-008 |
| `scripts/bash/refactor/inject-loading-instruction.sh` | MOD-014, MOD-015 | ARCH-009 |
| `scripts/bash/refactor/parse-template-gates.sh` | MOD-016 | ARCH-010 |
| `scripts/bash/refactor/extract-template-content.sh` | MOD-017, MOD-018 | ARCH-011 |
| `scripts/bash/populate/populate-iso26262.sh` | MOD-019, MOD-020 | ARCH-012 |
| `scripts/bash/populate/populate-do178c.sh` | MOD-021, MOD-022 | ARCH-013 |
| `scripts/bash/populate/populate-iec62304.sh` | MOD-023, MOD-024 | ARCH-014 |
| `scripts/bash/metadata/rewrite-extension-desc.sh` | MOD-025 | ARCH-015 |
| `scripts/bash/lifecycle/map-parent-features.sh` | MOD-026 | ARCH-016 |
| `scripts/bash/lifecycle/annotate-modified.sh` | MOD-027, MOD-028 | ARCH-017 |
| `scripts/bash/lifecycle/cascade-suspects.sh` | MOD-029, MOD-030 | ARCH-018 |

## Derived Modules

None — all modules trace to existing architecture modules.

