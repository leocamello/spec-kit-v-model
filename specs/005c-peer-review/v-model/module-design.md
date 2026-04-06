# Module Design: Peer Review

**Feature Branch**: `feature/005c-peer-review`
**Created**: 2025-07-18
**Status**: Approved
**Source**: `specs/005c-peer-review/v-model/architecture-design.md`

## Overview

This module design decomposes the 10 architecture modules of the Peer Review feature into 16 low-level module designs specifying the concrete functions, their signatures, input/output contracts, and internal algorithms. The AI evaluation path (ARCH-001 through ARCH-008) decomposes into individual functions within the peer-review command implementation: a file reader, a type resolver with artifact mapping lookup, a criteria registry loader, an LLM prompt builder and response parser, a PRF ID assigner, a severity classifier, a header formatter, and a markdown report assembler. The CI gate path (ARCH-009, ARCH-010) decomposes into self-contained Bash and PowerShell scripts, each with argument parsing, summary table parsing, exit code determination, and optional JSON output. Each module is documented with four mandatory views detailed enough that writing the actual source code is merely a translation exercise.

## ID Schema

- **Module Design**: `MOD-NNN` — sequential identifier for each module (3-digit zero-padded)
- **Parent Architecture Modules**: Comma-separated `ARCH-NNN` list per module (many-to-many, authoritative for traceability)
- **Target Source File(s)**: Comma-separated file paths mapping to the repository codebase
- Example: `MOD-003` with Parent Architecture Modules `ARCH-003` — module implements the criteria registry lookup
- Example: `MOD-012` with Parent Architecture Modules `ARCH-009` — module implements the Bash CI check script argument parser

## Module Designs

### Module: MOD-001 (read_artifact_file)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `commands/peer-review.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION read_artifact_file(artifact_path: string) -> string:
    // Step 1: Validate path is provided
    IF artifact_path IS NULL OR artifact_path IS EMPTY:
        RAISE FileNotFoundError("No artifact path specified")

    // Step 2: Check file exists on disk
    IF NOT file_exists(artifact_path):
        RAISE FileNotFoundError("Artifact file not found: " + artifact_path)

    // Step 3: Read raw content
    content = read_file(artifact_path)

    // Step 4: Validate non-empty
    IF length(content) == 0:
        RAISE EmptyFileError("Artifact file is empty: " + artifact_path)

    // Step 5: Return raw content
    RETURN content
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| artifact_path | string | Max 4096 chars (OS path limit) | From function argument | File system path to the V-Model artifact |
| content | string | No upper bound; typical V-Model artifacts < 100 KB | Empty string | Raw text content read from the artifact file |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Path is null or empty | FileNotFoundError | ARCH-001 FileNotFoundError | Propagate to caller; abort pipeline |
| File does not exist | FileNotFoundError | ARCH-001 FileNotFoundError | Propagate to caller; abort pipeline |
| File is zero bytes | EmptyFileError | ARCH-001 EmptyFileError | Propagate to caller; abort pipeline |

---

### Module: MOD-002 (resolve_artifact_type)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `commands/peer-review.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION resolve_artifact_type(file_name: string, file_content: string) -> ArtifactMetadata:
    // Step 1: Define the supported artifact type mapping
    SUPPORTED_TYPES = {
        "requirements.md":        { type: "requirements",        abbrev: "REQ",  standard: "INCOSE" },
        "system-design.md":       { type: "system-design",       abbrev: "SYS",  standard: "IEEE 1016" },
        "architecture-design.md": { type: "architecture-design", abbrev: "ARCH", standard: "IEEE 42010" },
        "system-test.md":         { type: "system-test",         abbrev: "STP",  standard: "ISO 29119" },
        "integration-test.md":    { type: "integration-test",    abbrev: "ITP",  standard: "ISO 29119-4" },
        "module-design.md":       { type: "module-design",       abbrev: "MOD",  standard: "DO-178C / ISO 26262" },
        "unit-test.md":           { type: "unit-test",           abbrev: "UTP",  standard: "ISO 29119-4" },
        "hazard-analysis.md":     { type: "hazard-analysis",     abbrev: "HAZ",  standard: "ISO 14971 / ISO 26262" },
        "acceptance-plan.md":     { type: "acceptance-plan",     abbrev: "ATP",  standard: "ISO 29119" }
    }

    // Step 2: Extract base file name from path
    base_name = extract_basename(file_name)

    // Step 3: Look up artifact type
    IF base_name NOT IN SUPPORTED_TYPES:
        RAISE UnsupportedArtifactTypeError("Unsupported artifact type: " + base_name)

    type_info = SUPPORTED_TYPES[base_name]

    // Step 4: Count artifact items by parsing content for primary ID patterns
    ID_PATTERNS = {
        "requirements":        regex("REQ-(NF-|IF-|CN-)?[0-9]{3}"),
        "system-design":       regex("SYS-[0-9]{3}"),
        "architecture-design": regex("ARCH-[0-9]{3}"),
        "system-test":         regex("STS-[0-9]{3}"),
        "integration-test":    regex("ITS-[0-9]{3}"),
        "module-design":       regex("MOD-[0-9]{3}"),
        "unit-test":           regex("UTS-[0-9]{3}"),
        "hazard-analysis":     regex("HAZ-[0-9]{3}"),
        "acceptance-plan":     regex("ATP-[0-9]{3}")
    }

    pattern = ID_PATTERNS[type_info.type]
    unique_ids = find_all_unique_matches(file_content, pattern)
    item_count = length(unique_ids)

    // Step 5: Build and return metadata
    RETURN ArtifactMetadata {
        artifactType:      type_info.type,
        abbreviation:      type_info.abbrev,
        governingStandard: type_info.standard,
        itemCount:         item_count,
        fileName:          base_name
    }
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| SUPPORTED_TYPES | Dict[string, object] | Exactly 9 entries | Hardcoded constant | Maps artifact file names to type metadata |
| ID_PATTERNS | Dict[string, regex] | Exactly 9 entries | Hardcoded constant | Maps artifact types to their primary ID regex patterns |
| base_name | string | Max 30 chars | Extracted from file_name | Base file name without directory path |
| type_info | object | 3 fields: type, abbrev, standard | Looked up from SUPPORTED_TYPES | Metadata for the matched artifact type |
| unique_ids | Set[string] | 0–999 elements | Empty set | Deduplicated set of artifact item IDs found in content |
| item_count | integer | 0–999 | 0 | Number of unique primary IDs found |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| File name not in supported types | UnsupportedArtifactTypeError | ARCH-002 UnsupportedArtifactTypeError | Propagate to caller; abort pipeline |
| Multiple artifacts provided | MultipleArtifactError | ARCH-002 MultipleArtifactError | Propagate to caller; abort pipeline |

---

### Module: MOD-003 (get_review_criteria)

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `commands/peer-review.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION get_review_criteria(artifact_type: string) -> CriteriaSet:
    // Step 1: Define the criteria registry
    CRITERIA_REGISTRY = {
        "requirements": {
            standard: "INCOSE",
            dimensions: ["atomic", "testable", "unambiguous", "complete",
                         "free of subjective language", "priority assigned"],
            rules: [
                "Each REQ must be atomic — single testable statement",
                "Each REQ must have a verification method",
                "No subjective terms (e.g., 'appropriate', 'sufficient')",
                "Quantitative thresholds where applicable",
                "Priority (P1/P2/P3) assigned to every requirement"
            ]
        },
        "system-design": {
            standard: "IEEE 1016",
            dimensions: ["4 design views present", "SYS→REQ traceability",
                         "interface contracts complete", "derived requirements flagged"],
            rules: [
                "Decomposition, Dependency, Interface, and Data Design views present",
                "Every SYS traces to at least one REQ",
                "Interface contracts define input, output, error handling",
                "Coverage summary with forward coverage percentage",
                "Derived requirements section present (even if empty)"
            ]
        },
        "architecture-design": {
            standard: "IEEE 42010",
            dimensions: ["4+1 views populated", "CROSS-CUTTING justified",
                         "interface definitions complete"],
            rules: [
                "Logical, Process, Dependency, Interface, and Data Flow views present",
                "Every ARCH traces to at least one SYS",
                "CROSS-CUTTING modules have justification",
                "Interface contracts define direction, type, format, constraints",
                "Coverage summary with forward coverage percentage"
            ]
        },
        "system-test": {
            standard: "ISO 29119",
            dimensions: ["named techniques correct", "no user-journey language",
                         "test scenario independence"],
            rules: [
                "Each test scenario uses a named test technique",
                "No user-story or journey language (Given/When/Then is acceptance, not system test)",
                "Test scenarios are independent — no ordering dependencies",
                "Expected results are specific and verifiable",
                "Every STS traces to at least one SYS"
            ]
        },
        "integration-test": {
            standard: "ISO 29119-4",
            dimensions: ["CDCT technique present", "fault injection scenarios",
                         "interface coverage complete"],
            rules: [
                "Consumer-Driven Contract Testing technique present",
                "Fault injection scenarios for interface failures",
                "Interface coverage: every internal interface tested",
                "Expected results include error propagation behavior",
                "Every ITS traces to at least one ARCH"
            ]
        },
        "module-design": {
            standard: "DO-178C / ISO 26262",
            dimensions: ["4 mandatory views present", "algorithm specs complete",
                         "error handling defined"],
            rules: [
                "Algorithmic/Logic, State Machine, Internal Data Structures, Error Handling views present",
                "Pseudocode blocks present for non-EXTERNAL modules",
                "Stateful modules have Mermaid stateDiagram-v2",
                "Every MOD traces to at least one ARCH",
                "Error handling maps to architecture interface contracts"
            ]
        },
        "unit-test": {
            standard: "ISO 29119-4",
            dimensions: ["5 techniques present", "mock registry complete",
                         "boundary values explicit"],
            rules: [
                "5 test techniques: EP, BVA, decision table, state transition, error guessing",
                "Mock/stub registry lists all external dependencies",
                "Boundary values explicitly derived from module data structures",
                "Every UTS traces to at least one MOD",
                "Test independence — no shared mutable state between tests"
            ]
        },
        "hazard-analysis": {
            standard: "ISO 14971 / ISO 26262",
            dimensions: ["severity classifications present", "every HAZ has mitigation",
                         "operational state coverage", "residual risk assessed"],
            rules: [
                "Every HAZ has severity classification",
                "Every HAZ has mitigation strategy defined",
                "Operational state coverage documented",
                "Residual risk assessed after mitigations",
                "Traceability to requirements for safety-relevant items"
            ]
        },
        "acceptance-plan": {
            standard: "ISO 29119",
            dimensions: ["BDD scenarios well-formed", "validation conditions measurable",
                         "parent REQ coverage verified"],
            rules: [
                "BDD scenarios follow Given/When/Then structure correctly",
                "Validation conditions are measurable and specific",
                "Every ATP traces to at least one REQ",
                "Acceptance criteria align with requirement verification methods",
                "Coverage summary with forward coverage percentage"
            ]
        }
    }

    // Step 2: Look up criteria for the given artifact type
    IF artifact_type NOT IN CRITERIA_REGISTRY:
        RAISE UnknownArtifactTypeError("No criteria registered for type: " + artifact_type)

    // Step 3: Return the criteria set
    RETURN CRITERIA_REGISTRY[artifact_type]
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| CRITERIA_REGISTRY | Dict[string, CriteriaSet] | Exactly 9 entries | Hardcoded constant | Maps artifact types to their review criteria sets |
| CriteriaSet | object | 3 fields: standard (string), dimensions (string[]), rules (string[]) | Constructed per entry | Structured criteria for one artifact type |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Artifact type not in registry | UnknownArtifactTypeError | ARCH-003 UnknownArtifactTypeError | Propagate to caller; abort pipeline |

---

### Module: MOD-004 (evaluate_artifact)

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `commands/peer-review.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION evaluate_artifact(artifact_content: string, criteria_set: CriteriaSet, artifact_type: string) -> RawFinding[]:
    // Step 1: Construct the evaluation prompt
    prompt = build_evaluation_prompt(artifact_content, criteria_set, artifact_type)

    // Step 2: Invoke LLM with the constructed prompt
    llm_response = invoke_llm(prompt)

    // Step 3: Validate LLM response is parseable
    IF llm_response IS NULL OR llm_response IS EMPTY:
        RAISE LLMEvaluationError("LLM returned empty response")

    // Step 4: Parse LLM response into discrete findings
    raw_findings = []
    parsed_items = parse_llm_response(llm_response)

    FOR EACH item IN parsed_items:
        // Validate all three required fields are present
        IF item.location IS NULL OR item.location IS EMPTY:
            RAISE LLMEvaluationError("Finding missing location field")
        IF item.description IS NULL OR item.description IS EMPTY:
            RAISE LLMEvaluationError("Finding missing description field")
        IF item.recommendation IS NULL OR item.recommendation IS EMPTY:
            RAISE LLMEvaluationError("Finding missing recommendation field")

        finding = RawFinding {
            location:       item.location,
            description:    item.description,
            recommendation: item.recommendation
        }
        raw_findings.append(finding)

    // Step 5: Return findings (may be empty if no issues detected)
    RETURN raw_findings

FUNCTION build_evaluation_prompt(content: string, criteria: CriteriaSet, type: string) -> string:
    prompt = "You are a peer reviewer evaluating a " + type + " artifact.\n"
    prompt += "Governing standard: " + criteria.standard + "\n\n"
    prompt += "Quality dimensions to evaluate:\n"
    FOR EACH dimension IN criteria.dimensions:
        prompt += "- " + dimension + "\n"
    prompt += "\nEvaluation rules:\n"
    FOR EACH rule IN criteria.rules:
        prompt += "- " + rule + "\n"
    prompt += "\nArtifact content:\n" + content + "\n\n"
    prompt += "For each quality issue found, provide:\n"
    prompt += "- location: the specific artifact item ID (e.g., REQ-001, SYS-003)\n"
    prompt += "- description: what the quality issue is\n"
    prompt += "- recommendation: how to fix it\n"
    prompt += "Return an empty list if no issues are found."
    RETURN prompt

FUNCTION parse_llm_response(response: string) -> ParsedItem[]:
    // Parse structured response from LLM into discrete items
    // Expected format: list of objects with location, description, recommendation
    items = parse_structured_output(response)
    RETURN items
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| prompt | string | No hard limit; typically 1–50 KB depending on artifact size | Built from template + content | Complete evaluation prompt sent to LLM |
| llm_response | string | No hard limit; depends on LLM output | Received from LLM invocation | Raw LLM response text |
| raw_findings | array[RawFinding] | 0–999 elements | Empty array | Parsed findings from LLM response |
| RawFinding | object | 3 fields: location (string), description (string), recommendation (string) | Constructed per finding | Single quality issue identified by the LLM |
| parsed_items | array[object] | 0–999 elements | Parsed from llm_response | Intermediate parsed items before validation |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| LLM returns null or empty response | LLMEvaluationError | ARCH-004 LLMEvaluationError | Propagate to caller; abort pipeline |
| Finding missing location field | LLMEvaluationError | ARCH-004 LLMEvaluationError | Propagate to caller; abort pipeline |
| Finding missing description field | LLMEvaluationError | ARCH-004 LLMEvaluationError | Propagate to caller; abort pipeline |
| Finding missing recommendation field | LLMEvaluationError | ARCH-004 LLMEvaluationError | Propagate to caller; abort pipeline |
| LLM response is unparseable | LLMEvaluationError | ARCH-004 LLMEvaluationError | Propagate to caller; abort pipeline |

---

### Module: MOD-005 (assign_prf_ids)

**Parent Architecture Modules**: ARCH-005
**Target Source File(s)**: `commands/peer-review.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION assign_prf_ids(raw_findings: RawFinding[], abbreviation: string) -> IdentifiedFinding[]:
    // Step 1: Validate abbreviation
    VALID_ABBREVIATIONS = {"REQ", "SYS", "ARCH", "STP", "ITP", "MOD", "UTP", "HAZ", "ATP"}

    IF abbreviation NOT IN VALID_ABBREVIATIONS:
        RAISE InvalidAbbreviationError("Invalid abbreviation: " + abbreviation)

    // Step 2: Assign sequential PRF IDs
    identified_findings = []
    counter = 1

    FOR EACH finding IN raw_findings:
        prf_id = "PRF-" + abbreviation + "-" + zero_pad(counter, 3)

        identified_finding = IdentifiedFinding {
            prfId:          prf_id,
            location:       finding.location,
            description:    finding.description,
            recommendation: finding.recommendation
        }
        identified_findings.append(identified_finding)
        counter = counter + 1

    // Step 3: Return identified findings (preserves order)
    RETURN identified_findings
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| VALID_ABBREVIATIONS | Set[string] | Exactly 9 elements | Hardcoded constant | Allowed artifact type abbreviations |
| counter | integer | 1–999 | 1 | Sequential counter for PRF ID assignment |
| prf_id | string | Pattern: `PRF-{ABBREV}-NNN`, max 15 chars | Constructed per finding | Unique identifier for a single finding |
| identified_findings | array[IdentifiedFinding] | 0–999 elements | Empty array | Findings with PRF IDs assigned |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Abbreviation not in valid set | InvalidAbbreviationError | ARCH-005 InvalidAbbreviationError | Propagate to caller; abort pipeline |

---

### Module: MOD-006 (classify_severity)

**Parent Architecture Modules**: ARCH-006
**Target Source File(s)**: `commands/peer-review.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION classify_severity(identified_findings: IdentifiedFinding[]) -> ClassifiedFinding[]:
    // Step 1: Define severity classification rules
    // The LLM evaluation (MOD-004) produces descriptions; classification is based on
    // the nature of the quality issue as described in the finding description.
    // This function applies the severity definitions from the architecture:
    //   Critical: fundamental quality violation blocking release
    //   Major: significant quality issue requiring resolution before approval
    //   Minor: style or completeness issue not affecting correctness
    //   Observation: informational suggestion for improvement

    classified_findings = []

    FOR EACH finding IN identified_findings:
        // Step 2: Determine severity based on finding characteristics
        severity = determine_severity(finding.description)

        IF severity IS NULL:
            RAISE UnclassifiableFindingError("Cannot classify finding: " + finding.prfId)

        classified_finding = ClassifiedFinding {
            prfId:          finding.prfId,
            severity:       severity,
            location:       finding.location,
            description:    finding.description,
            recommendation: finding.recommendation
        }
        classified_findings.append(classified_finding)

    RETURN classified_findings

FUNCTION determine_severity(description: string) -> string:
    // Classification logic applied by the AI agent based on severity definitions:
    // - Critical: untestable requirement, missing mandatory view, unmitigated catastrophic hazard
    // - Major: ambiguous quantifier, incomplete interface contract, missing test technique
    // - Minor: inconsistent formatting, missing rationale on low-risk item
    // - Observation: alternative decomposition strategy, additional test technique suggestion

    // The AI agent evaluates the description against these criteria and returns
    // exactly one of: "Critical", "Major", "Minor", "Observation"
    severity = ai_classify(description)

    IF severity NOT IN {"Critical", "Major", "Minor", "Observation"}:
        RETURN NULL

    RETURN severity
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| classified_findings | array[ClassifiedFinding] | 0–999 elements | Empty array | Findings with severity levels assigned |
| ClassifiedFinding | object | 5 fields: prfId, severity, location, description, recommendation | Constructed per finding | Complete classified finding record |
| severity | string | Exactly one of: "Critical", "Major", "Minor", "Observation" | Determined per finding | Severity level for a single finding |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Finding cannot be mapped to severity | UnclassifiableFindingError | ARCH-006 UnclassifiableFindingError | Propagate to caller; abort pipeline |

---

### Module: MOD-007 (build_report_header)

**Parent Architecture Modules**: ARCH-007
**Target Source File(s)**: `commands/peer-review.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION build_report_header(artifact_file_name: string, item_count: integer, governing_standard: string) -> string:
    // Step 1: Validate required metadata
    IF artifact_file_name IS NULL OR artifact_file_name IS EMPTY:
        RAISE MissingMetadataError("Missing artifact file name")
    IF item_count < 0:
        RAISE MissingMetadataError("Invalid item count: " + item_count)
    IF governing_standard IS NULL OR governing_standard IS EMPTY:
        RAISE MissingMetadataError("Missing governing standard")

    // Step 2: Derive artifact base name (without .md extension) for report title
    artifact_base = remove_extension(artifact_file_name)

    // Step 3: Get current date
    generation_date = format_date(now(), "YYYY-MM-DD")

    // Step 4: Build header markdown
    header = "# Peer Review: " + artifact_base + "\n\n"
    header += "**Reviewer**: AI Peer Reviewer\n"
    header += "**Date**: " + generation_date + "\n"
    header += "**Artifact**: " + artifact_file_name + "\n"
    header += "**Items Reviewed**: " + to_string(item_count) + "\n"
    header += "**Governing Standard**: " + governing_standard + "\n"

    RETURN header
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| artifact_base | string | Max 30 chars | Derived from artifact_file_name | Artifact file name without .md extension |
| generation_date | string | Exactly 10 chars (YYYY-MM-DD) | Current date at invocation | ISO 8601 date for the report header |
| header | string | Typically 200–400 chars | Built incrementally | Formatted markdown header section |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Missing artifact file name | MissingMetadataError | ARCH-007 MissingMetadataError | Propagate to caller; abort pipeline |
| Invalid item count (negative) | MissingMetadataError | ARCH-007 MissingMetadataError | Propagate to caller; abort pipeline |
| Missing governing standard | MissingMetadataError | ARCH-007 MissingMetadataError | Propagate to caller; abort pipeline |

---

### Module: MOD-008 (render_summary_table)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `commands/peer-review.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION render_summary_table(classified_findings: ClassifiedFinding[]) -> string:
    // Step 1: Count findings by severity
    counts = {
        "Critical":    0,
        "Major":       0,
        "Minor":       0,
        "Observation": 0
    }

    FOR EACH finding IN classified_findings:
        counts[finding.severity] = counts[finding.severity] + 1

    // Step 2: Build summary table markdown
    table = "## Summary\n\n"
    table += "| Severity | Count |\n"
    table += "|----------|-------|\n"
    table += "| Critical | " + to_string(counts["Critical"]) + " |\n"
    table += "| Major | " + to_string(counts["Major"]) + " |\n"
    table += "| Minor | " + to_string(counts["Minor"]) + " |\n"
    table += "| Observation | " + to_string(counts["Observation"]) + " |\n"

    RETURN table
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| counts | Dict[string, integer] | Exactly 4 entries | All values initialized to 0 | Severity level counters |
| table | string | Typically 200–300 chars | Built incrementally | Markdown summary table |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| No error conditions — empty input produces a table with all zero counts | N/A | ARCH-008 interface | Returns valid table with zero counts |

---

### Module: MOD-009 (render_finding_subsections)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `commands/peer-review.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION render_finding_subsections(classified_findings: ClassifiedFinding[]) -> string:
    // Step 1: Handle empty findings
    IF length(classified_findings) == 0:
        RETURN "## Findings\n\nNo findings.\n"

    // Step 2: Build finding subsections
    output = "## Findings\n\n"

    FOR EACH finding IN classified_findings:
        output += "### " + finding.prfId + "\n\n"
        output += "**Severity**: " + finding.severity + "\n"
        output += "**Location**: " + finding.location + "\n"
        output += "**Description**: " + finding.description + "\n"
        output += "**Recommendation**: " + finding.recommendation + "\n\n"
        output += "---\n\n"

    RETURN output
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| output | string | Variable; depends on number of findings | "## Findings\n\n" | Accumulated markdown for all finding subsections |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| No error conditions — empty input produces "No findings." section | N/A | ARCH-008 interface | Returns valid markdown with no findings message |

---

### Module: MOD-010 (write_review_report)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `commands/peer-review.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION write_review_report(header: string, summary_table: string, finding_sections: string, output_path: string) -> string:
    // Step 1: Assemble the complete report
    report = header + "\n"
    report += summary_table + "\n"
    report += finding_sections

    // Step 2: Validate output path
    IF output_path IS NULL OR output_path IS EMPTY:
        RAISE FileWriteError("No output path specified")

    // Step 3: Write file (create or overwrite)
    write_file(output_path, report)

    // Step 4: Return the path to the written file
    RETURN output_path
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| report | string | Variable; typically 1–50 KB | Assembled from header + summary + findings | Complete peer review report content |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Output path is null or empty | FileWriteError | ARCH-008 FileWriteError | Propagate to caller; abort pipeline |
| File cannot be written (permissions, disk full) | FileWriteError | ARCH-008 FileWriteError | Propagate to caller; abort pipeline |

---

### Module: MOD-011 (orchestrate_peer_review)

**Parent Architecture Modules**: ARCH-001, ARCH-002, ARCH-003, ARCH-004, ARCH-005, ARCH-006, ARCH-007, ARCH-008
**Target Source File(s)**: `commands/peer-review.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION orchestrate_peer_review(artifact_path: string, vmodel_dir: string) -> string:
    // Step 1: Read the artifact file (ARCH-001)
    content = read_artifact_file(artifact_path)

    // Step 2: Resolve artifact type and metadata (ARCH-002)
    file_name = extract_basename(artifact_path)
    metadata = resolve_artifact_type(file_name, content)

    // Step 3: Get review criteria for the artifact type (ARCH-003)
    criteria = get_review_criteria(metadata.artifactType)

    // Step 4: Evaluate artifact using LLM (ARCH-004)
    raw_findings = evaluate_artifact(content, criteria, metadata.artifactType)

    // Step 5: Assign PRF IDs to findings (ARCH-005)
    identified_findings = assign_prf_ids(raw_findings, metadata.abbreviation)

    // Step 6: Classify findings by severity (ARCH-006)
    classified_findings = classify_severity(identified_findings)

    // Step 7: Build report header (ARCH-007)
    header = build_report_header(metadata.fileName, metadata.itemCount, metadata.governingStandard)

    // Step 8: Render report sections (ARCH-008)
    summary_table = render_summary_table(classified_findings)
    finding_sections = render_finding_subsections(classified_findings)

    // Step 9: Write the complete report
    output_path = join_path(vmodel_dir, "peer-review-" + remove_extension(metadata.fileName) + ".md")
    result_path = write_review_report(header, summary_table, finding_sections, output_path)

    RETURN result_path
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| content | string | No upper bound; typical artifacts < 100 KB | From read_artifact_file | Raw artifact file content |
| metadata | ArtifactMetadata | 5 fields | From resolve_artifact_type | Artifact type, abbreviation, standard, item count, file name |
| criteria | CriteriaSet | 3 fields | From get_review_criteria | Quality dimensions, rules, standard references |
| raw_findings | array[RawFinding] | 0–999 elements | From evaluate_artifact | Unidentified findings from LLM |
| identified_findings | array[IdentifiedFinding] | 0–999 elements | From assign_prf_ids | Findings with PRF IDs |
| classified_findings | array[ClassifiedFinding] | 0–999 elements | From classify_severity | Findings with severity levels |
| header | string | 200–400 chars | From build_report_header | Markdown header section |
| summary_table | string | 200–300 chars | From render_summary_table | Markdown summary table |
| finding_sections | string | Variable | From render_finding_subsections | Markdown finding subsections |
| output_path | string | Max 4096 chars | Constructed from vmodel_dir + artifact name | File path for the output report |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Any error from MOD-001 through MOD-010 | Propagated exception | Respective ARCH contracts | All errors propagate upward; pipeline aborts on first error |

---

### Module: MOD-012 (parse_check_args — Bash)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `scripts/bash/peer-review-check.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION parse_check_args(args: string[]) -> CheckConfig:
    json_mode = false
    review_file = NULL

    // Step 1: Iterate through arguments
    index = 0
    WHILE index < length(args):
        arg = args[index]

        IF arg == "--json":
            json_mode = true
        ELSE IF arg starts with "--":
            print_to_stderr("Unknown option: " + arg)
            print_usage()
            EXIT 1
        ELSE:
            IF review_file IS NOT NULL:
                print_to_stderr("Error: Multiple review files specified")
                print_usage()
                EXIT 1
            review_file = arg

        index = index + 1

    // Step 2: Validate required arguments
    IF review_file IS NULL:
        print_to_stderr("Error: No review file specified")
        print_usage()
        EXIT 1

    IF NOT file_exists(review_file):
        print_to_stderr("Error: Review file not found: " + review_file)
        EXIT 1

    // Step 3: Return configuration
    RETURN CheckConfig {
        jsonMode:   json_mode,
        reviewFile: review_file
    }

FUNCTION print_usage():
    print_to_stderr("Usage: peer-review-check.sh [--json] <peer-review-file>")
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| json_mode | boolean | true or false | false | Whether --json flag was provided |
| review_file | string | Max 4096 chars (path limit) | NULL | Path to the peer review markdown file |
| index | integer | 0 to length(args) | 0 | Current argument index |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Unknown option flag | Exit code 1 + stderr message | ARCH-009 ParseError | Script exits immediately |
| Multiple review files specified | Exit code 1 + stderr message | ARCH-009 ParseError | Script exits immediately |
| No review file specified | Exit code 1 + stderr message | ARCH-009 ParseError | Script exits immediately |
| Review file not found | Exit code 1 + stderr message | ARCH-009 FileNotFoundError | Script exits immediately |

---

### Module: MOD-013 (parse_severity_counts — Bash)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `scripts/bash/peer-review-check.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION parse_severity_counts(review_file: string) -> SeverityCounts:
    // Step 1: Read the review file content
    content = read_file(review_file)

    // Step 2: Initialize severity counters
    counts = {
        critical:    0,
        major:       0,
        minor:       0,
        observation: 0
    }

    // Step 3: Parse the summary table for severity counts
    // Expected format: "| Critical | N |" or "| Major | N |" etc.
    // Use grep/awk to extract counts from the summary table rows
    FOR EACH line IN content.lines:
        IF line matches regex("^\|\s*Critical\s*\|\s*([0-9]+)\s*\|"):
            counts.critical = parse_int(match_group(1))
        ELSE IF line matches regex("^\|\s*Major\s*\|\s*([0-9]+)\s*\|"):
            counts.major = parse_int(match_group(1))
        ELSE IF line matches regex("^\|\s*Minor\s*\|\s*([0-9]+)\s*\|"):
            counts.minor = parse_int(match_group(1))
        ELSE IF line matches regex("^\|\s*Observation\s*\|\s*([0-9]+)\s*\|"):
            counts.observation = parse_int(match_group(1))

    // Step 4: Validate that at least one severity row was found
    // (to detect unparseable files)
    total_parsed = counts.critical + counts.major + counts.minor + counts.observation
    has_summary_table = any_severity_row_matched

    IF NOT has_summary_table:
        // Fallback: count individual finding headers
        // Expected format: "**Severity**: Critical" etc.
        FOR EACH line IN content.lines:
            IF line matches regex("\*\*Severity\*\*:\s*Critical"):
                counts.critical = counts.critical + 1
            ELSE IF line matches regex("\*\*Severity\*\*:\s*Major"):
                counts.major = counts.major + 1
            ELSE IF line matches regex("\*\*Severity\*\*:\s*Minor"):
                counts.minor = counts.minor + 1
            ELSE IF line matches regex("\*\*Severity\*\*:\s*Observation"):
                counts.observation = counts.observation + 1

    RETURN counts
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| content | string | No hard limit; typical review files < 50 KB | Read from review_file | Raw markdown content of the peer review report |
| counts | SeverityCounts | 4 fields, each integer ≥ 0 | All fields initialized to 0 | Severity count accumulator |
| has_summary_table | boolean | true or false | false | Whether a summary table row was successfully parsed |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Review file cannot be read | Exit code 1 + stderr message | ARCH-009 FileNotFoundError | Script exits immediately |
| No summary table and no finding headers found | Counts remain all zero; treated as clean review | ARCH-009 exit code 0 | Returns zero counts (exit code 0) |

---

### Module: MOD-014 (determine_exit_code — Bash)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `scripts/bash/peer-review-check.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION determine_exit_code(counts: SeverityCounts, json_mode: boolean) -> integer:
    // Step 1: If JSON mode, output JSON to stdout
    IF json_mode:
        json_output = '{"critical": ' + to_string(counts.critical)
        json_output += ', "major": ' + to_string(counts.major)
        json_output += ', "minor": ' + to_string(counts.minor)
        json_output += ', "observation": ' + to_string(counts.observation) + '}'
        print_to_stdout(json_output)

    // Step 2: Determine exit code based on severity rules
    IF counts.critical > 0 OR counts.major > 0:
        RETURN 1
    ELSE IF counts.minor > 0:
        RETURN 2
    ELSE:
        RETURN 0
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| json_output | string | Typically 60–100 chars | Built from counts | JSON string with severity counts |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| No error conditions — function always succeeds given valid counts | N/A | ARCH-009 exit code semantics | Returns exit code 0, 1, or 2 |

---

### Module: MOD-015 (main — Bash CI Check)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `scripts/bash/peer-review-check.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION main(args: string[]):
    // Step 1: Parse command-line arguments
    config = parse_check_args(args)

    // Step 2: Parse severity counts from review file
    counts = parse_severity_counts(config.reviewFile)

    // Step 3: Determine and return exit code
    exit_code = determine_exit_code(counts, config.jsonMode)
    EXIT exit_code
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| config | CheckConfig | 2 fields: jsonMode (boolean), reviewFile (string) | From parse_check_args | Parsed CLI configuration |
| counts | SeverityCounts | 4 integer fields | From parse_severity_counts | Parsed severity counts |
| exit_code | integer | 0, 1, or 2 | From determine_exit_code | Process exit code |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Any error from MOD-012 or MOD-013 | Exit code 1 + stderr | ARCH-009 interface | Script exits with code 1 on any parse or file error |

---

### Module: MOD-016 (Invoke-PeerReviewCheck — PowerShell)

**Parent Architecture Modules**: ARCH-010
**Target Source File(s)**: `scripts/powershell/peer-review-check.ps1`

#### Algorithmic / Logic View

```pseudocode
FUNCTION Invoke-PeerReviewCheck(ReviewFile: string, Json: boolean) -> void:
    // Step 1: Validate parameters
    IF ReviewFile IS NULL OR ReviewFile IS EMPTY:
        Write-Error "Error: No review file specified"
        Write-Output "Usage: Peer-Review-Check.ps1 [-Json] -ReviewFile <path>"
        EXIT 1

    IF NOT Test-Path(ReviewFile):
        Write-Error "Error: Review file not found: $ReviewFile"
        EXIT 1

    // Step 2: Read review file content
    content = Get-Content -Path ReviewFile -Raw

    // Step 3: Initialize severity counters
    counts = @{
        critical    = 0
        major       = 0
        minor       = 0
        observation = 0
    }

    // Step 4: Parse summary table for severity counts
    // Match rows like "| Critical | N |"
    critical_match = [regex]::Match(content, "(?m)^\|\s*Critical\s*\|\s*(\d+)\s*\|")
    IF critical_match.Success:
        counts.critical = [int]critical_match.Groups[1].Value

    major_match = [regex]::Match(content, "(?m)^\|\s*Major\s*\|\s*(\d+)\s*\|")
    IF major_match.Success:
        counts.major = [int]major_match.Groups[1].Value

    minor_match = [regex]::Match(content, "(?m)^\|\s*Minor\s*\|\s*(\d+)\s*\|")
    IF minor_match.Success:
        counts.minor = [int]minor_match.Groups[1].Value

    observation_match = [regex]::Match(content, "(?m)^\|\s*Observation\s*\|\s*(\d+)\s*\|")
    IF observation_match.Success:
        counts.observation = [int]observation_match.Groups[1].Value

    // Step 5: Fallback — count individual finding headers if no summary table
    IF NOT (critical_match.Success OR major_match.Success OR minor_match.Success OR observation_match.Success):
        severity_lines = Select-String -InputObject content -Pattern "\*\*Severity\*\*:\s*(Critical|Major|Minor|Observation)" -AllMatches
        FOR EACH match IN severity_lines.Matches:
            severity_value = match.Groups[1].Value
            IF severity_value == "Critical": counts.critical += 1
            ELSE IF severity_value == "Major": counts.major += 1
            ELSE IF severity_value == "Minor": counts.minor += 1
            ELSE IF severity_value == "Observation": counts.observation += 1

    // Step 6: Output JSON if requested
    IF Json:
        json_output = @{
            critical    = counts.critical
            major       = counts.major
            minor       = counts.minor
            observation = counts.observation
        } | ConvertTo-Json -Compress
        Write-Output json_output

    // Step 7: Determine exit code
    IF counts.critical > 0 OR counts.major > 0:
        EXIT 1
    ELSE IF counts.minor > 0:
        EXIT 2
    ELSE:
        EXIT 0
```

#### State Machine View

N/A — Stateless pure function

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| ReviewFile | string | Max 4096 chars (path limit) | From -ReviewFile parameter | Path to the peer review markdown file |
| Json | boolean (switch) | true or false | false (default) | Whether -Json switch was provided |
| content | string | No hard limit; typical < 50 KB | Read from ReviewFile via Get-Content | Raw markdown content of the peer review report |
| counts | hashtable | 4 keys: critical, major, minor, observation (integers ≥ 0) | All values initialized to 0 | Severity count accumulator |
| json_output | string | Typically 60–100 chars | Built from counts via ConvertTo-Json | JSON string with severity counts |
| critical_match | Match | Regex match result | From [regex]::Match | Result of parsing Critical count from summary table |
| major_match | Match | Regex match result | From [regex]::Match | Result of parsing Major count from summary table |
| minor_match | Match | Regex match result | From [regex]::Match | Result of parsing Minor count from summary table |
| observation_match | Match | Regex match result | From [regex]::Match | Result of parsing Observation count from summary table |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| ReviewFile is null or empty | Exit code 1 + Write-Error | ARCH-010 FileNotFoundError | Script exits immediately |
| Review file not found | Exit code 1 + Write-Error | ARCH-010 FileNotFoundError | Script exits immediately |
| Review file unparseable (no summary or finding headers) | Counts remain all zero; treated as clean | ARCH-010 exit code 0 | Returns zero counts (exit code 0) |

---

## Function Signatures

### Command Functions (peer-review.md)

```pseudocode
read_artifact_file(artifact_path: string) -> string
resolve_artifact_type(file_name: string, file_content: string) -> ArtifactMetadata
get_review_criteria(artifact_type: string) -> CriteriaSet
evaluate_artifact(artifact_content: string, criteria_set: CriteriaSet, artifact_type: string) -> RawFinding[]
assign_prf_ids(raw_findings: RawFinding[], abbreviation: string) -> IdentifiedFinding[]
classify_severity(identified_findings: IdentifiedFinding[]) -> ClassifiedFinding[]
build_report_header(artifact_file_name: string, item_count: integer, governing_standard: string) -> string
render_summary_table(classified_findings: ClassifiedFinding[]) -> string
render_finding_subsections(classified_findings: ClassifiedFinding[]) -> string
write_review_report(header: string, summary_table: string, finding_sections: string, output_path: string) -> string
orchestrate_peer_review(artifact_path: string, vmodel_dir: string) -> string
```

### Bash Functions (peer-review-check.sh)

```bash
parse_check_args(args) → sets JSON_MODE, REVIEW_FILE
parse_severity_counts(review_file) → sets CRITICAL, MAJOR, MINOR, OBSERVATION
determine_exit_code(counts, json_mode) → exit code (0, 1, or 2)
main() → orchestrates parse_check_args, parse_severity_counts, determine_exit_code
```

### PowerShell Functions (peer-review-check.ps1)

```powershell
Invoke-PeerReviewCheck [-Json] -ReviewFile <path> → exit code (0, 1, or 2); optional JSON to stdout
```

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Module Designs (MOD) | 16 |
| External Modules (`[EXTERNAL]`) | 0 |
| Cross-Cutting Modules (`[CROSS-CUTTING]`) | 0 |
| Stateful Modules | 0 |
| Stateless Modules | 16 |
| Total Parent Architecture Modules Covered | 10 / 10 (100%) |
| Modules with Pseudocode | 16 / 16 (100%) |
| **Forward Coverage (ARCH→MOD)** | **100%** |

### Forward Coverage Detail

| ARCH ID | Covered By |
|---------|-----------|
| ARCH-001 | MOD-001, MOD-011 |
| ARCH-002 | MOD-002, MOD-011 |
| ARCH-003 | MOD-003, MOD-011 |
| ARCH-004 | MOD-004, MOD-011 |
| ARCH-005 | MOD-005, MOD-011 |
| ARCH-006 | MOD-006, MOD-011 |
| ARCH-007 | MOD-007, MOD-011 |
| ARCH-008 | MOD-008, MOD-009, MOD-010, MOD-011 |
| ARCH-009 | MOD-012, MOD-013, MOD-014, MOD-015 |
| ARCH-010 | MOD-016 |

## Derived Modules

None — all modules trace to existing architecture modules.
