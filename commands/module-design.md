---
description: Decompose architecture modules into low-level module designs with four mandatory views and ARCH↔MOD traceability.
handoffs:
  - label: Generate Unit Tests
    agent: speckit.v-model.unit-test
    prompt: Generate the unit test plan for this module design
    send: true
  - label: Back to Architecture Design
    agent: speckit.v-model.architecture-design
    prompt: Review or update the architecture design
scripts:
  sh: scripts/bash/setup-v-model.sh --json --require-reqs --require-architecture-design
  ps: scripts/powershell/setup-v-model.ps1 -Json -RequireReqs -RequireArchitectureDesign
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Decompose a V-Model Architecture Design (`architecture-design.md`) into a Module Design where **every architecture module** (`ARCH-NNN`) maps to at least one low-level module specification (`MOD-NNN`). Each module is documented with four mandatory views detailed enough that writing the actual source code is merely a translation exercise — no further architectural or design decisions required.

CRITICAL DISTINCTION: Module Design is NOT architecture. It does NOT describe module boundaries, interfaces, or data flows between modules — those are documented in `architecture-design.md`. Module Design describes the **internal logic, state, data structures, and error handling** of each individual module.

## Execution Steps

### 1. Setup

Run `{SCRIPT}` from the repository root and parse the JSON output.

The script returns JSON with these keys:
- `VMODEL_DIR`: Path to `specs/{feature}/v-model/` directory
- `FEATURE_DIR`: Path to `specs/{feature}/` directory
- `BRANCH`: Current branch name
- `REQUIREMENTS`: Path to `requirements.md` (MUST exist — script uses `--require-reqs`)
- `ARCH_DESIGN`: Path to `architecture-design.md` (MUST exist — script uses `--require-architecture-design`)
- `AVAILABLE_DOCS`: Array of documents that currently exist

For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

### 2. Load Context

1. **Load the template**: Read `templates/module-design-template.md` from the extension directory to understand the required output structure.

2. **Load architecture design**: Read `architecture-design.md` from the `ARCH_DESIGN` path.
   - If `architecture-design.md` does NOT exist: ERROR — "Architecture design not found. Run `/speckit.v-model.architecture-design` first."
   - Extract ALL `ARCH-NNN` identifiers from the Logical View table
   - Extract the Interface View (feeds Error Handling & Return Codes view)
   - Extract the Data Flow View (feeds Algorithmic/Logic View data transformation context)
   - Note each module's type, parent SYS, and `[CROSS-CUTTING]` tags
   - Note the total ARCH count — every ARCH must have at least one MOD

3. **Load requirements**: Read `requirements.md` from the `REQUIREMENTS` path for supplementary domain context.

4. **Load v-model-config.yml** (if it exists at the repository root):
   - If `domain` is set to `iso_26262`, `do_178c`, or `iec_62304`: Enable safety-critical sections (Complexity Constraints, Memory Management, Single Entry/Exit)
   - If absent or `domain` is empty: Skip safety-critical sections entirely

5. **Load existing module design** (if `AVAILABLE_DOCS` contains `"module-design.md"`):
   - Read the existing `module-design.md` to preserve existing MOD-NNN IDs and content
   - Identify the highest existing MOD number to continue the sequence
   - New modules append after existing ones — **never renumber**

### 3. Lifecycle Rules (When Evolving Existing Artifacts)

When an existing `module-design.md` is loaded (step 2.5), apply these rules
before generating new content:

1. **Never delete an ID** — mark as `[DEPRECATED]`
2. **Deprecation types:**
   - `[DEPRECATED — Superseded by MOD-NNN]`: Replaced by a new module
   - `[DEPRECATED — Withdrawn: <reason>]`: Removed entirely with justification
3. **Suspect detection from parent ARCH:** If a parent ARCH (in
   `architecture-design.md`) is deprecated or modified, mark each MOD that traces
   to it as `[SUSPECT — Parent ARCH-NNN {deprecated|modified}]`.
4. **Suspect resolution:** For each suspect MOD:
   - **Re-parent** to the superseding ARCH (if module continues under a new ID)
   - **Deprecate** (if the architecture module is withdrawn — cascade to downstream UTP)
   - **Confirm active** (if still valid despite the parent change — remove the SUSPECT tag)
5. **Modified modules:** Update content in-place, preserve the original MOD ID.
   Downstream artifacts (UTP) tracing to this MOD become suspect.

If no existing `module-design.md` is found, skip this step entirely — all
modules are new.

### 4. Decompose Architecture Modules into Module Designs

For each `ARCH-NNN` module in the Logical View, create one or more `MOD-NNN` module specifications.

#### 4.0 ISO/IEC/IEEE 12207:2017 Detailed Design Requirements

Per ISO/IEC/IEEE 12207:2017 §8.4.4 (Software Detailed Design process), every `MOD-NNN` module specification MUST satisfy these four requirements:

1. **Requirement Allocation** (§8.4.4.1): The module explicitly traces to one or more `ARCH-NNN` and `REQ-NNN` IDs — every function or class exists because a requirement demands it
2. **Algorithm Specification** (§8.4.4.2): The algorithmic logic is specified with sufficient detail (pseudocode or equivalent) that a developer can implement it without design interpretation — see §5.1 Algorithmic / Logic View
3. **Interface Definition** (§8.4.4.3): All inputs, outputs, pre/post-conditions, and inter-module dependencies are formally documented — see §5.2 Interface / Contract View
4. **Design Verification Readiness** (§8.4.4.4): The module design is verifiable — each `MOD-NNN` must have corresponding unit test cases (`UTP-NNN`) generated by `/speckit.v-model.unit-test`

These four requirements apply to all module types except `[EXTERNAL]` modules (wrapper interface documentation only).

#### 4.1 Decomposition Strategy

Each `MOD-NNN` represents a single function, class, script, or tightly coupled file group that will become actual source code. The decomposition granularity follows these rules:

| ARCH Type | Decomposition Rule | Example |
|-----------|-------------------|---------|
| Component | One MOD per major function/class in the module | ARCH-001 (Parser) → MOD-001 (parse_input), MOD-002 (validate_schema) |
| Service | One MOD per endpoint or handler | ARCH-003 (API Service) → MOD-005 (handle_create), MOD-006 (handle_delete) |
| Library | One MOD per public API surface | ARCH-005 (Template Lib) → MOD-008 (load_template), MOD-009 (render_template) |
| Utility | Often 1:1 with ARCH | ARCH-007 (Config Loader) → MOD-010 (load_config) |

#### 4.2 Tag Routing

- **Standard modules**: Full four-view decomposition with pseudocode
- **`[CROSS-CUTTING]` modules**: Full four-view decomposition — inherits the `[CROSS-CUTTING]` tag. Infrastructure code requires the same rigor as business logic.
- **`[EXTERNAL]` modules**: Document only the wrapper/configuration interface. Omit deep algorithmic pseudocode of the third-party library internals. Tag the resulting MOD as `[EXTERNAL]`. If the wrapper itself contains meaningful logic (retry policy, circuit breaker, connection pooling), that wrapper logic MUST be documented with pseudocode.
- **Untraceable modules**: If the decomposition produces a function/class not traceable to any `ARCH-NNN`, flag it as `[DERIVED MODULE: description]` rather than silently creating a `MOD-NNN`. The user must update `architecture-design.md` first.

#### 4.3 Traceability

- Every `MOD-NNN` MUST include a "Parent Architecture Modules" field listing one or more `ARCH-NNN` identifiers
- Many-to-many relationships are supported: one ARCH may produce multiple MODs, one MOD may serve multiple ARCHs
- The "Parent Architecture Modules" field is the authoritative source for traceability — ID string parsing alone cannot determine the ARCH parent due to many-to-many relationships

### 5. Build the Four Module Design Views

For each `MOD-NNN`, generate the four mandatory views:

#### 5.1 Algorithmic / Logic View

The core of the module design. This view must be so detailed that a developer can translate it directly into source code.

**Requirements:**
- Step-by-step pseudocode enclosed in fenced Markdown code blocks tagged `pseudocode` (i.e., ` ```pseudocode ``` `)
- Every branch (`if/else`), loop (`for/while`), and decision point must be explicit
- No vague prose like "process the data appropriately" — every transformation must be concrete
- Reference specific data types, variable names, and return values
- For `[EXTERNAL]` modules: document wrapper configuration logic only (e.g., retry policy, connection setup), not the library's internal algorithm

**Anti-Pattern Guard:**
- ❌ "The module processes input and produces output" (vague)
- ❌ "Handle errors appropriately" (undefined)
- ✅ `if input.length > MAX_BUFFER_SIZE: return ERROR_OVERFLOW` (concrete)
- ✅ `for each field in schema.required_fields: if field not in input: errors.append(MissingFieldError(field))` (explicit)

#### 5.2 State Machine View

For modules that maintain state across invocations:

**Stateful modules:**
- Use Mermaid `stateDiagram-v2` syntax
- Document every state, transition, event, and guard condition
- Include entry/exit actions for each state
- Show error/recovery states

**Stateless modules:**
- Write a bypass string detectable by the broad regex `(?i)N/?A.*Stateless`
- Example: `N/A — Stateless` or `N/A: Stateless pure function`
- Validators use this regex rather than exact string matching to tolerate minor LLM punctuation variance

#### 5.3 Internal Data Structures

Document every local variable, constant, buffer, and object class used by the module:

- **Type**: Explicit language-level type (e.g., `uint8_t`, `string`, `Dict[str, List[int]]`)
- **Size/Constraints**: Exact sizes where applicable (e.g., "buffer is exactly 256 bytes", "array max length 1024")
- **Initialization**: Default values and initialization strategy
- **Lifecycle**: When created, when destroyed, scope boundaries

This view feeds Boundary Value Analysis in unit testing — every constraint here becomes a test boundary.

#### 5.4 Error Handling & Return Codes

Document how the module catches and processes errors internally:

- Map each internal error to the contract defined in the Architecture Interface View
- Specify exact error codes, exception types, or return values
- Document error propagation: which errors are caught vs. re-thrown
- Document recovery behavior: retry, fallback, graceful degradation

### 6. Safety-Critical Sections (Conditional)

**Only generate these sections if `v-model-config.yml` has `domain` set.**

#### 6.1 Complexity Constraints (MISRA C/C++ / CERT-C)

For each `MOD-NNN`:
- **Cyclomatic Complexity Limit**: Maximum allowed (e.g., ≤ 10 per function)
- **MISRA/CERT-C Rule Annotations**: Specific rules applicable to the module
- **Coding Standard Deviations**: Any justified deviations with rationale

#### 6.2 Memory Management (Safety-Critical Best Practice)

For each `MOD-NNN`:
- **Dynamic Allocation**: Forbidden after initialization (document init-time allocations)
- **Unbounded Loops**: Forbidden — all loops must have provable termination
- **Stack Usage**: Maximum stack depth estimate

#### 6.3 Single Entry/Exit (Safety-Critical Best Practice)

For each `MOD-NNN`:
- **Entry Points**: Exactly one per function
- **Exit Points**: Exactly one `return` per function for deterministic execution paths
- **Guard Clauses**: Document how early-return patterns are restructured to single-exit

### 7. Coverage Gate

After generating all `MOD-NNN` modules, verify coverage:

1. **Forward coverage (ARCH→MOD)**: Every `ARCH-NNN` (including `[CROSS-CUTTING]`) has at least one `MOD-NNN`
2. **No orphaned MODs**: Every `MOD-NNN` traces to at least one valid `ARCH-NNN` via the "Parent Architecture Modules" field
3. **`[EXTERNAL]` completeness**: Every `[EXTERNAL]` MOD documents at minimum the wrapper interface
4. **Pseudocode presence**: Every non-`[EXTERNAL]` MOD contains a fenced ` ```pseudocode ``` ` block

If any check fails, flag the specific gaps in the output but do NOT abort generation.

5. **ISO/IEC/IEEE 12207:2017 §8.4.4 Compliance**: For each `MOD-NNN`, confirm the four detailed design requirements from Step 4.0 are satisfied:
   - Requirement allocation traceable (ARCH and REQ parents documented)
   - Algorithm specified (pseudocode block present, or `[EXTERNAL]` tag with wrapper doc)
   - Interface defined (Contract View completed with inputs, outputs, pre/post-conditions)
   - Design verifiable (paired UTP exists or will be generated by `/speckit.v-model.unit-test`)

### 8. Write Output

Write the complete module design to `{VMODEL_DIR}/module-design.md` using the template structure. Include:

1. **Header section**: Feature name, branch, date, source reference
2. **Overview**: Brief description of the decomposition rationale
3. **ID Schema**: Document the MOD-NNN → ARCH-NNN relationship encoding
4. **Module Designs**: All MOD specifications with four views, organized sequentially — each MOD lists its parent ARCH modules and Target Source File(s)
5. **Safety-Critical Sections**: Complexity, Memory, Single Entry/Exit (if domain configured)
6. **Coverage Summary**: Module count, ARCH coverage, view completeness
7. **Derived Modules**: List of `[DERIVED MODULE: ...]` flags (should be empty)

#### 8.1 Target Source File(s) Property

Every `MOD-NNN` MUST include a "Target Source File(s)" property:
- Maps the module to one or more physical file paths in the repository
- Comma-separated for languages with header/implementation pairs (e.g., `src/parser.h, src/parser.cpp`)
- This bridges specification and codebase — `/speckit.implement` uses this to know where to write code
- Example: `Target Source File(s): src/sensor/parser.py`
- Example: `Target Source File(s): src/sensor/parser.h, src/sensor/parser.cpp`

### 9. Report Completion

Display a summary:
- Total modules (MOD) generated
- Coverage: X/Y ARCH modules covered (must be 100% or flagged)
- View completeness: N modules with all 4 views, M modules with pseudocode bypass (`[EXTERNAL]`)
- Stateful vs. stateless module count
- Safety-critical sections included (yes/no, which domain)
- `[DERIVED MODULE]` flags (should be 0)
- Path to the generated file
- Next step: Recommend running `/speckit.v-model.unit-test` to generate paired white-box unit tests

## Governing Standards

This command is governed by the following standards for module design:

| Standard | Full Name | Role in this Command |
|----------|-----------|----------------------|
| **IEEE 1016:2009** | IEEE Standard for Information Technology — Software Design Descriptions | Detailed design structure: algorithm specification, interface definition, data structure descriptions, and design verification requirements at module level |
| **ISO/IEC/IEEE 12207:2017** | Systems and Software Engineering — Software Life Cycle Processes | Lifecycle process governance (Clause 8.4 — Software Detailed Design): requirement allocation to modules, algorithm specification completeness, interface definition discipline, and design verification activities. Provides the general-purpose detailed design process independent of any safety domain. |

> **Domain extensions:** If a domain overlay is loaded (Step 2a), domain-specific module design constraints (e.g., MISRA C/C++ per ISO 26262-6 §8.4.5, CERT-C per DO-178C §5.2.3, IEC 62304 §5.4 safety class constraints) are applied alongside these best-practice standards.

## Operating Constraints

### Strict Translation Rules

When generating from `architecture-design.md`:
- **DO NOT** invent modules for capabilities not described in the architecture design
- **DO NOT** decompose the internal algorithms of third-party libraries tagged `[EXTERNAL]`
- **DO NOT** write vague prose in place of pseudocode (structural validators will reject it)
- **DO** generate at least one MOD per ARCH module
- **DO** include all four mandatory views for every non-external MOD
- **DO** include the "Parent Architecture Modules" field for traceability
- **DO** include the "Target Source File(s)" property for code mapping

### ID Rules

- IDs are **permanent** — once assigned, they are never renumbered or reassigned
- MOD numbering is sequential and independent of ARCH numbering (MOD-001, MOD-002, ...)
- ID lineage: from a `MOD-NNN` ID alone, you can identify the module but NOT its parent ARCH. The "Parent Architecture Modules" field is required for ARCH resolution due to many-to-many relationships.
- When updating existing module designs, preserve all existing IDs and append new ones
- Gaps in numbering are acceptable

### View Completeness Rules

- Every non-`[EXTERNAL]` MOD MUST have a fenced ` ```pseudocode ``` ` block in the Algorithmic/Logic View
- Every stateful MOD MUST have a Mermaid `stateDiagram-v2` diagram in the State Machine View
- Every stateless MOD MUST have a bypass string matchable by `(?i)N/?A.*Stateless`
- Every MOD MUST have an Internal Data Structures section (even if minimal)
- Every MOD MUST have an Error Handling section mapping to Architecture Interface View contracts

### Many-to-Many Mapping Rules

- One ARCH may decompose into multiple MODs (common for complex components)
- One MOD may serve multiple ARCHs (common for shared utilities)
- The "Parent Architecture Modules" field is the sole authoritative source for this mapping
- Coverage validation uses this field, not ID string parsing

### Scale Handling

- For features with >20 ARCH modules: group MODs by parent ARCH in the output for readability
- For features with >50 MODs: include a summary table at the top mapping MOD→ARCH→Source File
- Target Source File(s) should use repository-relative paths (not absolute paths)
