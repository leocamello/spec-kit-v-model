# Module Design: 006b — ID Lifecycle Model


**Feature Branch**: `feature/006b-id-lifecycle`
**Created**: 2026-04-18
**Status**: Draft
**Source**: `specs/006b-id-lifecycle/v-model/architecture-design.md`

## Overview

This document decomposes the 17 architecture modules from the ID Lifecycle Model into 21 implementable low-level module specifications. The decomposition follows three tiers: core annotation logic (MOD-001 through MOD-007), engine logic (MOD-008 through MOD-015), and reporting logic (MOD-016 through MOD-021). Each module has four mandatory views: Algorithmic/Logic (pseudocode), State Machine, Internal Data Structures, and Error Handling. All modules are stateless — the extension operates on Markdown artifact files with no runtime state across invocations.

## ID Schema

- **Module Design**: `MOD-NNN` — sequential identifier for each module (3-digit zero-padded)
- **Parent Architecture Modules**: Comma-separated `ARCH-NNN` list per module (many-to-many, authoritative for traceability)
- **Target Source File(s)**: Comma-separated file paths mapping to the repository codebase
- Example: `MOD-003` with Parent Architecture Modules `ARCH-002` — module implements state transition validation

## Module Designs

### Module: MOD-001 (parse_annotations)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `scripts/bash/parse-annotations.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION parse_annotations(artifact_text: String) -> List[Annotation]:
    annotations = []
    lines = artifact_text.split("\n")

    // Regex patterns for lifecycle annotations
    PATTERN_SUPERSESSION = /\[DEPRECATED\s*—\s*Superseded by\s+([A-Z]+-\d+)\]/
    PATTERN_WITHDRAWAL   = /\[DEPRECATED\s*—\s*Withdrawn:\s*(.+?)\]/
    PATTERN_SUSPECT_DEP  = /\[SUSPECT\s*—\s*Parent\s+([A-Z]+-\d+)\s+deprecated\]/
    PATTERN_SUSPECT_MOD  = /\[SUSPECT\s*—\s*Parent\s+([A-Z]+-\d+)\s+modified\]/
    PATTERN_ID           = /^[|*\s]*\*?\*?([A-Z]+-\d+)/

    FOR EACH line IN lines:
        id_match = PATTERN_ID.match(line)
        IF id_match IS NULL:
            CONTINUE

        id = id_match.group(1)

        IF PATTERN_SUPERSESSION.search(line):
            successor = PATTERN_SUPERSESSION.search(line).group(1)
            annotations.append({id: id, state: DEPRECATED, type: "supersession", target: successor})
        ELSE IF PATTERN_WITHDRAWAL.search(line):
            reason = PATTERN_WITHDRAWAL.search(line).group(1)
            annotations.append({id: id, state: DEPRECATED, type: "withdrawal", reason: reason})
        ELSE IF PATTERN_SUSPECT_DEP.search(line):
            parent = PATTERN_SUSPECT_DEP.search(line).group(1)
            annotations.append({id: id, state: SUSPECT, type: "deprecated", parent: parent})
        ELSE IF PATTERN_SUSPECT_MOD.search(line):
            parent = PATTERN_SUSPECT_MOD.search(line).group(1)
            annotations.append({id: id, state: SUSPECT, type: "modified", parent: parent})
        ELSE:
            annotations.append({id: id, state: ACTIVE})

    RETURN annotations
```

#### State Machine View

N/A — Stateless pure function.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| annotations | List[Annotation] | Unbounded; grows with artifact size | Empty list `[]` | Accumulated parsed annotations |
| lines | List[String] | One entry per newline-delimited line | Split from input | Lines of the input artifact |
| PATTERN_SUPERSESSION | Regex | Compiled once | Constant | Matches `[DEPRECATED — Superseded by ...]` |
| PATTERN_WITHDRAWAL | Regex | Compiled once | Constant | Matches `[DEPRECATED — Withdrawn: ...]` |
| PATTERN_SUSPECT_DEP | Regex | Compiled once | Constant | Matches `[SUSPECT — Parent ... deprecated]` |
| PATTERN_SUSPECT_MOD | Regex | Compiled once | Constant | Matches `[SUSPECT — Parent ... modified]` |
| PATTERN_ID | Regex | Compiled once | Constant | Matches ID at start of table row or list item |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Annotation matches partial pattern but is syntactically invalid (e.g., `[DEPRECATED — Superseded by]` with no ID) | MalformedAnnotation `{id, raw_text, issue}` | ARCH-001 Interface View: MalformedAnnotation | Append error to warnings list; continue parsing remaining lines |
| Input text is empty | (none — returns empty list) | — | Return `[]` with no error |

---

### Module: MOD-002 (classify_state)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `scripts/bash/parse-annotations.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION classify_state(raw_annotation: String, id: String) -> Annotation:
    // Determine lifecycle state from raw annotation text
    IF raw_annotation CONTAINS "[DEPRECATED":
        IF raw_annotation CONTAINS "Superseded by":
            successor = extract_id_after("Superseded by", raw_annotation)
            IF successor IS EMPTY:
                RAISE MalformedAnnotation({id: id, raw_text: raw_annotation, issue: "missing successor ID"})
            RETURN {id: id, state: DEPRECATED, type: "supersession", target: successor}
        ELSE IF raw_annotation CONTAINS "Withdrawn:":
            reason = extract_text_after("Withdrawn:", raw_annotation)
            IF reason.trim() IS EMPTY:
                RAISE MalformedAnnotation({id: id, raw_text: raw_annotation, issue: "empty withdrawal reason"})
            RETURN {id: id, state: DEPRECATED, type: "withdrawal", reason: reason}
        ELSE:
            RAISE MalformedAnnotation({id: id, raw_text: raw_annotation, issue: "unrecognized DEPRECATED subtype"})
    ELSE IF raw_annotation CONTAINS "[SUSPECT":
        parent = extract_id_after("Parent", raw_annotation)
        IF raw_annotation CONTAINS "deprecated":
            RETURN {id: id, state: SUSPECT, type: "deprecated", parent: parent}
        ELSE IF raw_annotation CONTAINS "modified":
            RETURN {id: id, state: SUSPECT, type: "modified", parent: parent}
    ELSE:
        RETURN {id: id, state: ACTIVE}
```

#### State Machine View

N/A — Stateless pure function.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| successor | String | Must match `{PREFIX}-NNN` pattern | Extracted from annotation | Successor ID for supersession |
| reason | String | Non-empty after trim | Extracted from annotation | Withdrawal reason |
| parent | String | Must match `{PREFIX}-NNN` pattern | Extracted from annotation | Parent ID for suspect annotation |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Missing successor ID in supersession | MalformedAnnotation | ARCH-001: MalformedAnnotation | Re-thrown to caller |
| Empty withdrawal reason | MalformedAnnotation | ARCH-001: MalformedAnnotation | Re-thrown to caller |
| Unrecognized DEPRECATED subtype | MalformedAnnotation | ARCH-001: MalformedAnnotation | Re-thrown to caller |

---

### Module: MOD-003 (validate_transition)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `scripts/bash/validate-transition.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION validate_transition(current_state: Enum, target_state: Enum) -> ValidationResult:
    // Allowed transitions matrix
    ALLOWED = {
        ACTIVE:     [DEPRECATED, SUSPECT],
        SUSPECT:    [ACTIVE, DEPRECATED],
        DEPRECATED: []   // terminal state — no outbound transitions
    }

    IF target_state IN ALLOWED[current_state]:
        RETURN {valid: true}
    ELSE:
        RETURN {valid: false, error: InvalidTransition({
            from: current_state,
            to: target_state,
            reason: "transition from " + current_state + " to " + target_state + " is not permitted"
        })}
```

#### State Machine View

N/A — Stateless pure function. (The function validates transitions but does not itself maintain state.)

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| ALLOWED | Map[Enum → List[Enum]] | 3 keys, max 2 values per key | Constant | Allowed transition matrix |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Forbidden transition (e.g., DEPRECATED→ACTIVE) | InvalidTransition `{from, to, reason}` | ARCH-002: InvalidTransition | Returned in result; caller decides to block or report |

---

### Module: MOD-004 (write_supersession)

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `scripts/bash/annotation-handlers.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION write_supersession(id: String, successor_id: String) -> String:
    // Validate inputs
    IF successor_id IS EMPTY OR successor_id IS NULL:
        RAISE MissingSuccessor({id: id, issue: "successor_id is required"})

    IF NOT successor_id.matches(/^[A-Z]+-\d+$/):
        RAISE MissingSuccessor({id: id, issue: "successor_id must match {PREFIX}-NNN pattern"})

    // Build annotation using em dash (U+2014)
    annotation = "[DEPRECATED — Superseded by " + successor_id + "]"

    RETURN annotation
```

#### State Machine View

N/A — Stateless pure function.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| annotation | String | Fixed format: `[DEPRECATED — Superseded by {ID}]` | Constructed | Output annotation text |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Empty or null successor_id | MissingSuccessor `{id, issue}` | ARCH-003: MissingSuccessor | Re-thrown to caller |
| Successor ID doesn't match prefix pattern | MissingSuccessor `{id, issue}` | ARCH-003: MissingSuccessor | Re-thrown to caller |

---

### Module: MOD-005 (parse_supersession)

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `scripts/bash/annotation-handlers.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION parse_supersession(annotation_text: String) -> SupersessionData:
    PATTERN = /\[DEPRECATED\s*—\s*Superseded by\s+([A-Z]+-\d+)\]/
    match = PATTERN.search(annotation_text)

    IF match IS NULL:
        RETURN NULL  // not a supersession annotation

    successor_id = match.group(1)
    RETURN {type: "supersession", target: successor_id}
```

#### State Machine View

N/A — Stateless pure function.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| PATTERN | Regex | Compiled once | Constant | Matches supersession annotation with em dash |
| successor_id | String | Must match `{PREFIX}-NNN` | Extracted from regex group 1 | The successor ID |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| No match found | Returns NULL | — | Caller checks for NULL before using result |

---

### Module: MOD-006 (write_withdrawal)

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `scripts/bash/annotation-handlers.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION write_withdrawal(id: String, reason: String) -> String:
    // Validate inputs
    IF reason IS EMPTY OR reason.trim() IS EMPTY:
        RAISE MissingReason({id: id, issue: "reason is required"})

    // Build annotation using em dash (U+2014)
    annotation = "[DEPRECATED — Withdrawn: " + reason.trim() + "]"

    RETURN annotation
```

#### State Machine View

N/A — Stateless pure function.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| annotation | String | Fixed format: `[DEPRECATED — Withdrawn: {reason}]` | Constructed | Output annotation text |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Empty or whitespace-only reason | MissingReason `{id, issue}` | ARCH-004: MissingReason | Re-thrown to caller |

---

### Module: MOD-007 (parse_withdrawal)

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `scripts/bash/annotation-handlers.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION parse_withdrawal(annotation_text: String) -> WithdrawalData:
    PATTERN = /\[DEPRECATED\s*—\s*Withdrawn:\s*(.+?)\]/
    match = PATTERN.search(annotation_text)

    IF match IS NULL:
        RETURN NULL  // not a withdrawal annotation

    reason = match.group(1).trim()
    RETURN {type: "withdrawal", reason: reason}
```

#### State Machine View

N/A — Stateless pure function.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| PATTERN | Regex | Compiled once | Constant | Matches withdrawal annotation with em dash |
| reason | String | Non-empty after trim | Extracted from regex group 1 | The withdrawal reason |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| No match found | Returns NULL | — | Caller checks for NULL before using result |

---

### Module: MOD-008 (resolve_parent_links)

**Parent Architecture Modules**: ARCH-005
**Target Source File(s)**: `scripts/bash/resolve-parent-links.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION resolve_parent_links(artifact_text: String, link_patterns: List[Regex]) -> Map[String, List[String]]:
    link_map = {}
    lines = artifact_text.split("\n")
    current_id = NULL

    FOR EACH line IN lines:
        // Detect downstream ID (e.g., ATP-003-A, SYS-001)
        id_match = /^[|*\s]*\*?\*?([A-Z]+-\d+(?:-[A-Z]\d?)?)/.match(line)
        IF id_match IS NOT NULL:
            current_id = id_match.group(1)
            IF current_id NOT IN link_map:
                link_map[current_id] = []

        // Scan for parent references using provided patterns
        IF current_id IS NOT NULL:
            FOR EACH pattern IN link_patterns:
                parent_matches = pattern.find_all(line)
                FOR EACH parent_id IN parent_matches:
                    IF parent_id NOT IN link_map[current_id]:
                        link_map[current_id].append(parent_id)

    IF link_map IS EMPTY:
        EMIT Warning NoLinksFound({artifact: "artifact", issue: "no parent links detected"})

    RETURN link_map
```

#### State Machine View

N/A — Stateless pure function.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| link_map | Map[String → List[String]] | Grows with artifact size | Empty map `{}` | Maps downstream IDs to parent IDs |
| current_id | String or NULL | One ID at a time | NULL | The most recently encountered downstream ID |
| lines | List[String] | One per line | Split from input | Lines of the artifact |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| No parent links found in artifact | NoLinksFound warning `{artifact, issue}` | ARCH-005: NoLinksFound | Warning emitted; empty map returned — caller treats as first-time generation |

---

### Module: MOD-009 (write_suspect_annotations)

**Parent Architecture Modules**: ARCH-006
**Target Source File(s)**: `scripts/bash/write-suspect-annotations.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION write_suspect_annotations(artifact_text: String, suspect_items: List[SuspectItem]) -> String:
    IF suspect_items IS EMPTY:
        RETURN artifact_text  // no changes needed

    updated_text = artifact_text

    FOR EACH item IN suspect_items:
        // Locate the downstream ID in the artifact text
        id_pattern = Regex("(\\|\\s*\\*?\\*?" + escape(item.downstream_id) + ")")
        match = id_pattern.search(updated_text)

        IF match IS NULL:
            RAISE IDNotFound({downstream_id: item.downstream_id, issue: "ID not found in artifact"})

        // Build suspect annotation
        IF item.reason == "deprecated":
            annotation = " [SUSPECT — Parent " + item.parent_id + " deprecated]"
        ELSE IF item.reason == "modified":
            annotation = " [SUSPECT — Parent " + item.parent_id + " modified]"

        // Insert annotation after the ID on the same line
        insert_pos = match.end()
        updated_text = updated_text[:insert_pos] + annotation + updated_text[insert_pos:]

    RETURN updated_text
```

#### State Machine View

N/A — Stateless pure function.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| updated_text | String | Size of artifact + annotation overhead | Copy of input | Mutable working copy of artifact |
| id_pattern | Regex | Constructed per item | Built from downstream_id | Pattern to locate the target ID |
| annotation | String | Fixed format `[SUSPECT — Parent {ID} {reason}]` | Constructed | The annotation to insert |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Downstream ID not found in artifact | IDNotFound `{downstream_id, issue}` | ARCH-006: IDNotFound | Re-thrown to caller; no partial modification |

---

### Module: MOD-010 (dispatch_resolution)

**Parent Architecture Modules**: ARCH-007
**Target Source File(s)**: `scripts/bash/resolve-suspect.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION dispatch_resolution(resolution: Resolution, artifact_text: String) -> String:
    // Step 1: Enforce human instruction requirement
    IF resolution.human_instruction IS FALSE:
        RAISE AutoResolutionBlocked({id: resolution.id, issue: "automated resolution not permitted — human instruction required"})

    // Step 2: Validate state transition
    current_state = SUSPECT
    target_state = CASE resolution.action:
        "re-parent"     → ACTIVE
        "deprecate"     → DEPRECATED
        "confirm-valid" → ACTIVE

    validation = validate_transition(current_state, target_state)
    IF validation.valid IS FALSE:
        RAISE validation.error

    // Step 3: Route to handler
    CASE resolution.action:
        "re-parent":
            annotation = write_supersession(resolution.id, resolution.successor_id)
            updated_text = replace_suspect_with(artifact_text, resolution.id, annotation)
            updated_text = update_parent_link(updated_text, resolution.id, resolution.successor_id)
        "deprecate":
            annotation = write_withdrawal(resolution.id, resolution.reason)
            updated_text = replace_suspect_with(artifact_text, resolution.id, annotation)
        "confirm-valid":
            updated_text = remove_suspect_annotation(artifact_text, resolution.id)

    RETURN updated_text
```

#### State Machine View

N/A — Stateless pure function. (Routes actions but does not maintain state between invocations.)

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| current_state | Enum | Always SUSPECT (input items are suspect) | Constant | State of the ID being resolved |
| target_state | Enum | ACTIVE or DEPRECATED depending on action | Derived from action | Target state after resolution |
| validation | ValidationResult | `{valid: Boolean, error?: InvalidTransition}` | From validate_transition | Transition validation result |
| annotation | String | Annotation text for deprecation cases | From write_supersession or write_withdrawal | New annotation to replace SUSPECT |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| No human instruction provided | AutoResolutionBlocked `{id, issue}` | ARCH-007: AutoResolutionBlocked | Re-thrown; artifact unchanged |
| Invalid state transition | InvalidTransition `{from, to, reason}` | ARCH-002: InvalidTransition (via MOD-003) | Re-thrown; artifact unchanged |
| Missing successor for re-parent | MissingSuccessor `{id, issue}` | ARCH-003: MissingSuccessor (via MOD-004) | Re-thrown; artifact unchanged |
| Missing reason for deprecate | MissingReason `{id, issue}` | ARCH-004: MissingReason (via MOD-006) | Re-thrown; artifact unchanged |

---

### Module: MOD-011 (enforce_human_instruction)

**Parent Architecture Modules**: ARCH-007
**Target Source File(s)**: `scripts/bash/resolve-suspect.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION enforce_human_instruction(resolution: Resolution) -> Boolean:
    // Check that the resolution has an explicit human instruction flag
    // This flag is set when the command is invoked interactively
    // (not by another command or automated pipeline)

    IF resolution.human_instruction IS NULL OR resolution.human_instruction IS FALSE:
        RETURN FALSE

    // Additional check: the action must be one of the three allowed values
    IF resolution.action NOT IN ["re-parent", "deprecate", "confirm-valid"]:
        RETURN FALSE

    // Additional check: required fields per action
    IF resolution.action == "re-parent" AND resolution.successor_id IS EMPTY:
        RETURN FALSE
    IF resolution.action == "deprecate" AND resolution.reason IS EMPTY:
        RETURN FALSE

    RETURN TRUE
```

#### State Machine View

N/A — Stateless pure function.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| (none beyond function parameters) | — | — | — | Pure validation with no local state |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Returns FALSE | (boolean return) | ARCH-007: caller raises AutoResolutionBlocked | Caller interprets FALSE as blocked and raises the error |

---

### Module: MOD-012 (compare_parent_artifacts)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `scripts/bash/compare-parent-artifacts.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION compare_parent_artifacts(parent_text: String, existing_output: String, link_patterns: List[Regex]) -> ComparisonResult:
    // Step 1: Parse parent artifact for IDs and annotations
    parent_annotations = parse_annotations(parent_text)  // via MOD-001
    parent_id_set = {a.id: a FOR a IN parent_annotations}

    // Step 2: Resolve parent-child links from existing output
    IF existing_output IS EMPTY:
        link_map = {}  // first-time generation — no existing links
    ELSE:
        link_map = resolve_parent_links(existing_output, link_patterns)  // via MOD-008

    // Step 3: Compare parent IDs against traced links
    traced_parent_ids = FLATTEN(link_map.values()).to_set()
    comparison_pairs = []

    FOR EACH id, annotation IN parent_id_set:
        is_traced = id IN traced_parent_ids
        comparison_pairs.append({
            parent_id: id,
            state: annotation.state,
            is_traced: is_traced
        })

    // Step 4: Pass to classification emitter
    classifications = classify_ids(comparison_pairs, link_map)  // via MOD-013

    RETURN {comparison_pairs: comparison_pairs, classifications: classifications}
```

#### State Machine View

N/A — Stateless pure function.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| parent_annotations | List[Annotation] | One per ID in parent artifact | From parse_annotations | Parsed annotations from parent |
| parent_id_set | Map[String → Annotation] | One entry per unique ID | Built from parent_annotations | Quick lookup map for parent IDs |
| link_map | Map[String → List[String]] | One entry per downstream ID | From resolve_parent_links | Parent-child link mapping |
| traced_parent_ids | Set[String] | Unique parent IDs that are traced | Flattened from link_map values | Set of parent IDs referenced by downstream |
| comparison_pairs | List[ComparisonPair] | One per parent ID | Built during comparison | Comparison data for classification |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Parent artifact file is missing | ParentNotFound `{path, issue}` | ARCH-008: ParentNotFound | Re-thrown to command; no SUSPECT annotations written |
| Empty parent text (file exists but empty) | Returns empty classifications | — | Treated as no-op; no cascade |

---

### Module: MOD-013 (classify_ids)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `scripts/bash/classify-ids.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION classify_ids(comparison_pairs: List[ComparisonPair], link_map: Map) -> List[Classification]:
    classifications = []
    traced_parent_ids = FLATTEN(link_map.values()).to_set()

    FOR EACH pair IN comparison_pairs:
        IF pair.state == DEPRECATED:
            classifications.append({id: pair.parent_id, status: "deprecated"})
        ELSE IF pair.is_traced IS FALSE:
            // Parent ID exists but is not referenced by any downstream item
            classifications.append({id: pair.parent_id, status: "added"})
        ELSE:
            // Parent ID is traced — check if content was modified
            // Content comparison is performed by the LLM in the command context
            // Here we mark as "unchanged" (default) — the LLM overrides to "modified" if content differs
            classifications.append({id: pair.parent_id, status: "unchanged"})

    RETURN classifications
```

#### State Machine View

N/A — Stateless pure function.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| classifications | List[Classification] | One per parent ID (exactly) | Empty list `[]` | Output classification list |
| traced_parent_ids | Set[String] | Unique IDs | Flattened from link_map | Set of parent IDs with downstream traces |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| ID matches multiple categories | AmbiguousClassification warning `{id, issue}` | ARCH-009: AmbiguousClassification | Warning logged; first match wins |

---

### Module: MOD-014 (generate_lifecycle_section)

**Parent Architecture Modules**: ARCH-010
**Target Source File(s)**: `scripts/bash/generate-lifecycle-section.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION generate_lifecycle_section(id_prefix: String) -> String:
    RECOGNIZED_PREFIXES = ["REQ", "ATP", "SYS", "STP", "ARCH", "ITP", "MOD", "UTP", "HAZ"]

    IF id_prefix NOT IN RECOGNIZED_PREFIXES:
        RAISE UnknownPrefix({prefix: id_prefix, issue: "not a recognized ID prefix"})

    section = "### Lifecycle Rules\n\n"

    // Subsection 1: Never-delete rule
    section += "#### 1. Never Delete\n\n"
    section += "Never remove a " + id_prefix + "-NNN row. "
    section += "If a " + id_prefix + " is no longer needed, deprecate it instead.\n\n"

    // Subsection 2: Deprecation types
    section += "#### 2. Deprecation Types\n\n"
    section += "- **Supersession**: `[DEPRECATED — Superseded by " + id_prefix + "-NNN]` — "
    section += "the item is replaced by a newer item.\n"
    section += "- **Withdrawal**: `[DEPRECATED — Withdrawn: {reason}]` — "
    section += "the item is removed without replacement.\n\n"

    // Subsection 3: Suspect detection
    section += "#### 3. Suspect Detection\n\n"
    section += "When regenerating this artifact, compare each parent ID against the existing output. "
    section += "If a parent ID has been deprecated or modified, mark affected " + id_prefix + " items "
    section += "with `[SUSPECT — Parent {ID} {reason}]`.\n\n"

    // Subsection 4: Suspect resolution
    section += "#### 4. Suspect Resolution\n\n"
    section += "Suspect items require human resolution: re-parent, deprecate, or confirm valid. "
    section += "Automated resolution is never permitted.\n\n"

    // Subsection 5: Modified-item handling
    section += "#### 5. Modified-Item Handling\n\n"
    section += "When a parent ID is classified as modified (content changed but not deprecated), "
    section += "mark downstream " + id_prefix + " items as SUSPECT for human review.\n"

    RETURN section
```

#### State Machine View

N/A — Stateless pure function.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| RECOGNIZED_PREFIXES | List[String] | 9 elements, constant | Constant | Valid ID prefixes |
| section | String | Variable length; grows by concatenation | Empty string `""` | Accumulated section text |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Unrecognized prefix | UnknownPrefix `{prefix, issue}` | ARCH-010: UnknownPrefix | Re-thrown to caller |

---

### Module: MOD-015 (insert_section)

**Parent Architecture Modules**: ARCH-011
**Target Source File(s)**: `scripts/bash/inject-lifecycle-rules.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION insert_section(command_file_path: String, section_text: String) -> Boolean:
    // Step 1: Read command file
    content = read_file(command_file_path)

    // Step 2: Check idempotency — section already present?
    IF content CONTAINS "### Lifecycle Rules":
        EMIT Warning SectionAlreadyExists({file: command_file_path, issue: "Lifecycle Rules section already present"})
        RETURN TRUE  // idempotent — no modification needed

    // Step 3: Locate insertion point
    // Pattern: find "Load existing" step heading, then insert before "Generate" step
    load_pattern = /###\s+\d+\.\s+Load existing/
    generate_pattern = /###\s+\d+\.\s+Generate/

    load_match = load_pattern.search(content)
    generate_match = generate_pattern.search(content)

    IF load_match IS NULL OR generate_match IS NULL:
        RAISE InsertionPointNotFound({
            file: command_file_path,
            issue: "cannot locate 'Load existing artifact' step"
        })

    // Step 4: Insert section text between the two steps
    insert_pos = generate_match.start()
    updated_content = content[:insert_pos] + section_text + "\n\n" + content[insert_pos:]

    // Step 5: Write modified file
    write_file(command_file_path, updated_content)

    RETURN TRUE
```

#### State Machine View

N/A — Stateless pure function.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| content | String | Size of command file (typically 5–15 KB) | Read from file | Command file content |
| load_pattern | Regex | Compiled once | Constant | Matches "Load existing" step heading |
| generate_pattern | Regex | Compiled once | Constant | Matches "Generate" step heading |
| insert_pos | Integer | ≥ 0 | From regex match start | Position to insert section text |
| updated_content | String | content.length + section_text.length | Constructed | Modified file content |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Section already exists | SectionAlreadyExists warning `{file, issue}` | ARCH-011: SectionAlreadyExists | Return TRUE — idempotent |
| Insertion point not found | InsertionPointNotFound `{file, issue}` | ARCH-011: InsertionPointNotFound | Re-thrown; file unchanged |

---

### Module: MOD-016 (compute_active_denominator)

**Parent Architecture Modules**: ARCH-012
**Target Source File(s)**: `scripts/bash/build-matrix.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION compute_active_denominator(all_ids: List[Annotation]) -> DenominatorResult:
    active_count = 0
    deprecated_count = 0

    FOR EACH annotation IN all_ids:
        IF annotation.state == DEPRECATED:
            deprecated_count += 1
        ELSE:
            // ACTIVE and SUSPECT both count toward the denominator
            active_count += 1

    RETURN {active_count: active_count, deprecated_count: deprecated_count}
```

#### State Machine View

N/A — Stateless pure function.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| active_count | Integer | ≥ 0 | 0 | Count of non-DEPRECATED IDs |
| deprecated_count | Integer | ≥ 0 | 0 | Count of DEPRECATED IDs |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| (none) | — | ARCH-012: no failure modes | Pure computation — always succeeds |

---

### Module: MOD-017 (generate_suspect_summary)

**Parent Architecture Modules**: ARCH-013
**Target Source File(s)**: `scripts/bash/build-matrix.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION generate_suspect_summary(all_annotations: List[Annotation]) -> String:
    suspects = FILTER all_annotations WHERE state == SUSPECT

    IF suspects IS EMPTY:
        RETURN ""  // no suspect items — omit section

    section = "## Suspect Items\n\n"
    section += "| ID | Artifact | Parent | Reason |\n"
    section += "|----|----------|--------|--------|\n"

    FOR EACH suspect IN suspects:
        artifact = determine_artifact_location(suspect.id)
        section += "| " + suspect.id + " | " + artifact + " | " + suspect.parent + " | " + suspect.type + " |\n"

    RETURN section
```

#### State Machine View

N/A — Stateless pure function.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| suspects | List[Annotation] | Subset of all_annotations where state == SUSPECT | Filtered | SUSPECT annotations only |
| section | String | Variable length | Empty string or header | Output Markdown section |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| (none) | — | ARCH-013: no failure modes | Pure report generation — always succeeds |

---

### Module: MOD-018 (build_deprecation_chains)

**Parent Architecture Modules**: ARCH-014
**Target Source File(s)**: `scripts/bash/build-matrix.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION build_deprecation_chains(deprecated_annotations: List[Annotation], all_ids: Set[String]) -> String:
    IF deprecated_annotations IS EMPTY:
        RETURN ""  // no deprecated items — omit section

    section = "## Deprecated Chains\n\n"
    section += "| Deprecated ID | Type | Successor / Reason | Chain Valid |\n"
    section += "|--------------|------|-------------------|-------------|\n"

    FOR EACH dep IN deprecated_annotations:
        IF dep.type == "supersession":
            chain_valid = dep.target IN all_ids
            IF NOT chain_valid:
                EMIT Warning BrokenChain({id: dep.id, successor: dep.target, issue: "successor not found in artifact"})
            section += "| " + dep.id + " | Supersession | → " + dep.target + " | "
            section += (IF chain_valid THEN "✓" ELSE "⚠ Broken") + " |\n"
        ELSE IF dep.type == "withdrawal":
            section += "| " + dep.id + " | Withdrawal | " + dep.reason + " | — |\n"

    RETURN section
```

#### State Machine View

N/A — Stateless pure function.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| deprecated_annotations | List[Annotation] | Subset where state == DEPRECATED | Input parameter | DEPRECATED annotations to process |
| all_ids | Set[String] | All known IDs across artifacts | Input parameter | For chain validation (successor exists?) |
| section | String | Variable length | Header or empty | Output Markdown section |
| chain_valid | Boolean | Per-entry | Computed | Whether successor ID exists |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Supersession target not found | BrokenChain warning `{id, successor, issue}` | ARCH-014: BrokenChain | Warning emitted; entry marked with ⚠ in output |

---

### Module: MOD-019 (emit_formal_tags)

**Parent Architecture Modules**: ARCH-015
**Target Source File(s)**: `commands/impact-analysis.md`

#### Algorithmic / Logic View

```pseudocode
FUNCTION emit_formal_tags(impact_items: List[ImpactItem]) -> List[TaggedItem]:
    tagged = []

    FOR EACH item IN impact_items:
        CASE item.state:
            DEPRECATED:
                tagged.append({...item, tag: "[DEPRECATED]"})
            SUSPECT:
                tagged.append({...item, tag: "[SUSPECT]"})
            MODIFIED:
                tagged.append({...item, tag: "[MODIFIED]"})
            ACTIVE:
                tagged.append({...item, tag: ""})  // no tag for active items

    RETURN tagged
```

#### State Machine View

N/A — Stateless pure function.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| tagged | List[TaggedItem] | Same length as input | Empty list `[]` | Items with formal tags appended |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| (none) | — | ARCH-015: no failure modes | Pure transformation — always succeeds |

---

### Module: MOD-020 (detect_lifecycle_transitions)

**Parent Architecture Modules**: ARCH-016
**Target Source File(s)**: `scripts/bash/diff-requirements.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION detect_lifecycle_transitions(current_annotations: List[Annotation], baseline_annotations: List[Annotation]) -> TransitionResult:
    // Build lookup maps
    current_map  = {a.id: a.state FOR a IN current_annotations}
    baseline_map = {a.id: a.state FOR a IN baseline_annotations}

    deprecated       = []
    new_suspects     = []
    resolved_suspects = []

    // Detect transitions by comparing current vs. baseline
    FOR EACH id IN UNION(current_map.keys(), baseline_map.keys()):
        current_state  = current_map.get(id, NULL)
        baseline_state = baseline_map.get(id, NULL)

        IF current_state IS NULL:
            CONTINUE  // ID removed — handled by existing diff logic

        IF baseline_state IS NULL:
            CONTINUE  // new ID — handled by existing diff logic

        // Detect new deprecations
        IF current_state == DEPRECATED AND baseline_state != DEPRECATED:
            deprecated.append(id)

        // Detect new suspects
        IF current_state == SUSPECT AND baseline_state != SUSPECT:
            new_suspects.append(id)

        // Detect resolved suspects
        IF current_state != SUSPECT AND baseline_state == SUSPECT:
            resolved_suspects.append(id)

    RETURN {deprecated: deprecated, new_suspects: new_suspects, resolved_suspects: resolved_suspects}
```

#### State Machine View

N/A — Stateless pure function.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| current_map | Map[String → Enum] | One entry per current ID | Built from current_annotations | Current state lookup |
| baseline_map | Map[String → Enum] | One entry per baseline ID | Built from baseline_annotations | Baseline state lookup |
| deprecated | List[String] | IDs that became DEPRECATED | Empty list `[]` | Newly deprecated IDs |
| new_suspects | List[String] | IDs that became SUSPECT | Empty list `[]` | Newly suspect IDs |
| resolved_suspects | List[String] | IDs that lost SUSPECT | Empty list `[]` | Resolved suspect IDs |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| Baseline is empty or unparseable | BaselineParseError `{issue}` | ARCH-016: BaselineParseError | Re-thrown to caller; diff script exits with error |

---

### Module: MOD-021 (format_extended_json)

**Parent Architecture Modules**: ARCH-017
**Target Source File(s)**: `scripts/bash/diff-requirements.sh`

#### Algorithmic / Logic View

```pseudocode
FUNCTION format_extended_json(content_changes: ContentChanges, lifecycle_transitions: TransitionResult) -> String:
    json_obj = {
        "added":              content_changes.added,
        "modified":           content_changes.modified,
        "removed":            content_changes.removed,
        "deprecated":         lifecycle_transitions.deprecated,
        "new_suspects":       lifecycle_transitions.new_suspects,
        "resolved_suspects":  lifecycle_transitions.resolved_suspects
    }

    // Ensure backward compatibility: first 3 fields are always present
    IF "added" NOT IN json_obj:
        json_obj["added"] = []
    IF "modified" NOT IN json_obj:
        json_obj["modified"] = []
    IF "removed" NOT IN json_obj:
        json_obj["removed"] = []

    RETURN JSON.stringify(json_obj)
```

#### State Machine View

N/A — Stateless pure function.

#### Internal Data Structures

| Name | Type | Size/Constraints | Initialization | Description |
|------|------|-----------------|----------------|-------------|
| json_obj | Object | 6 keys, each mapping to a List[String] | Constructed | Combined output object |

#### Error Handling & Return Codes

| Error Condition | Error Code / Exception | Architecture Contract | Recovery |
|----------------|----------------------|----------------------|----------|
| (none) | — | ARCH-017: no failure modes | Pure formatting — always succeeds |

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Module Designs (MOD) | 21 (21 active, 0 deprecated, 0 suspect) |
| External Modules (`[EXTERNAL]`) | 0 |
| Cross-Cutting Modules (`[CROSS-CUTTING]`) | 0 |
| Stateful Modules | 0 |
| Stateless Modules | 21 |
| Total Parent Architecture Modules Covered | 17 / 17 (100%) (active items only) |
| Modules with Pseudocode | 21 / 21 (100%) |
| **Forward Coverage (ARCH→MOD)** | **100%** (active items only) |

## Derived Modules

None — all modules trace to existing architecture modules.
