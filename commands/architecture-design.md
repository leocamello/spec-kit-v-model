---
description: Decompose system components into IEEE 42010/Kruchten 4+1 architecture modules with four mandatory views and many-to-many SYS↔ARCH traceability.
handoffs:
  - label: Generate Integration Tests
    agent: speckit.v-model.integration-test
    prompt: Generate the integration test plan for this architecture design
    send: true
  - label: Back to System Design
    agent: speckit.v-model.system-design
    prompt: Review or update the system design
scripts:
  sh: scripts/bash/setup-v-model.sh --json --require-reqs --require-system-design
  ps: scripts/powershell/setup-v-model.ps1 -Json -RequireReqs -RequireSystemDesign
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Decompose a V-Model System Design (`system-design.md`) into an IEEE 42010/Kruchten 4+1-compliant Architecture Description where **every system component maps to at least one architecture module** (`ARCH-NNN`). The output organizes modules into four mandatory views (Logical, Process, Interface, Data Flow) and supports:
- Many-to-many SYS↔ARCH relationships
- `[CROSS-CUTTING]` tag for infrastructure/utility modules
- `[DERIVED MODULE]` flagging for modules not traceable to SYS
- Mermaid sequence diagrams in the Process View

This document becomes the left side of V-Model Level 3, later paired with integration test cases.

## Execution Steps

### 1. Setup

Run `{SCRIPT}` from the repository root and parse the JSON output.

The script returns JSON with these keys:
- `VMODEL_DIR`: Path to `specs/{feature}/v-model/` directory
- `FEATURE_DIR`: Path to `specs/{feature}/` directory
- `BRANCH`: Current branch name
- `REQUIREMENTS`: Path to `requirements.md` (MUST exist — script uses `--require-reqs`)
- `SYSTEM_DESIGN`: Path to `system-design.md` (MUST exist — script uses `--require-system-design`)
- `AVAILABLE_DOCS`: Array of documents that currently exist

For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

### 2. Load Context

1. **Load the template**: Read `templates/architecture-design-template.md` from the extension directory to understand the required output structure.

2. **Load system design**: Read `system-design.md` from the `VMODEL_DIR` path. This is the **sole source of truth** for what the architecture must implement.
   - If `system-design.md` does NOT exist: ERROR — "System design not found. Run `/speckit.v-model.system-design` first."
   - Extract all `SYS-NNN` identifiers from the Decomposition View
   - Extract the Dependency View (feeds Process View concurrency model)
   - Extract the Interface View (feeds architecture Interface View contracts)
   - Note the total SYS count — every SYS must appear as a parent in at least one ARCH

3. **Load requirements**: Read `requirements.md` from the `REQUIREMENTS` path for supplementary domain context. This provides insight into the problem domain but does NOT override system design.

4. **Load v-model-config.yml** (if it exists at the repository root):
   - If `domain` is set to `iso_26262`, `do_178c`, or `iec_62304`: Enable safety-critical sections (ASIL Decomposition, Defensive Programming, Temporal Constraints)
   - If absent or `domain` is empty: Skip safety-critical sections entirely

5. **Load existing architecture design** (if `AVAILABLE_DOCS` contains `"architecture-design.md"`):
   - Read the existing `architecture-design.md` to preserve existing ARCH IDs and content
   - Identify the highest existing ARCH number to continue the sequence
   - New modules append after existing ones — **never renumber**

### 3. Decompose System Components into Architecture Modules

Follow the **strict translator constraint**: You are decomposing system components into architecture modules. You must NOT invent capabilities not present in `system-design.md`.

For each architecture module identified during decomposition:

1. **Assign a unique ID**: `ARCH-NNN` (e.g., ARCH-001, ARCH-002). Sequential numbering, never renumbered.

2. **Name the module**: Short, descriptive name (e.g., "HTTP Router", "Event Dispatcher", "Persistence Adapter").

3. **Describe the module**: What it does, its responsibility boundary. Must be specific enough to define an API contract — if a description is too vague to derive inputs/outputs/exceptions, emit a warning.

4. **Map parent system components**: List ALL `SYS-NNN` identifiers that this module implements as a comma-separated list. Many-to-many mapping is expected:
   - A single ARCH may implement multiple SYS (e.g., `ARCH-003` implements `SYS-001, SYS-005`)
   - A single SYS may be implemented by multiple ARCH modules (e.g., `SYS-001` is a parent of both `ARCH-001` and `ARCH-003`)

5. **Classify type**: Component | Service | Library | Utility | Adapter

#### Cross-Cutting Rules

- Infrastructure/utility modules (Logger, Thread Pool, Config Manager, etc.) use `[CROSS-CUTTING]` tag with rationale instead of SYS parent
- Every `[CROSS-CUTTING]` module MUST still have interface contracts in the Interface View
- Cross-cutting modules are NOT derived — they are legitimate architecture components

#### Derived Module Rules

- If a module is neither traceable to a `SYS-NNN` nor qualifies as `[CROSS-CUTTING]`, flag it as `[DERIVED MODULE: description of the needed capability and why it is architecturally necessary]`
- Do NOT assign an `ARCH-NNN` to derived modules — halt and flag
- List all derived modules in the "Derived Modules" section of the output
- The human must resolve each one before proceeding to integration test generation:
  1. Add the capability to `system-design.md` (creating a new SYS-NNN)
  2. Reject it as unnecessary
  3. Tag as `[CROSS-CUTTING]`

#### Anti-Pattern Guard

- Reject "black box" descriptions: every `ARCH-NNN` MUST have an explicit interface contract (inputs, outputs, exceptions) in the Interface View
- If a module description is too vague to derive contracts, emit a warning and refine

### 4. Build the Four Architecture Views

#### 4.1 Logical View — Component Breakdown (IEEE 42010 / Kruchten 4+1)

The primary view. Fill the Logical View table from the template with all ARCH modules:

| ARCH ID | Name | Description | Parent System Components | Type |
|---------|------|-------------|--------------------------|------|

**Rules**:
- Every `SYS-NNN` from `system-design.md` must appear in at least one row's "Parent System Components" column
- Use comma-separated `SYS-NNN` list for many-to-many (e.g., `SYS-001, SYS-004`)
- Cross-cutting modules appear in the same table with `[CROSS-CUTTING]` tag and rationale
- No ARCH module may have an empty Parent System Components field (unless `[CROSS-CUTTING]`)

#### 4.2 Process View — Dynamic Behavior (Kruchten 4+1)

Document runtime module interactions using Mermaid sequence diagrams:

1. For each critical interaction path, generate a `sequenceDiagram` with ARCH-NNN as participants
2. Document concurrency model (thread pool, event loop, actor model, etc.)
3. Show synchronization points, thread/task boundaries, mutex strategies
4. Document execution order constraints and timing dependencies

**Rules**:
- Use Mermaid `sequenceDiagram` syntax — diagrams MUST be syntactically valid
- Reference `ARCH-NNN` IDs as participants
- Feed from the system design's Dependency View for inter-component relationships
- This view directly feeds **concurrency testing** in the integration test phase

#### 4.3 Interface View — Strict API Contracts (Kruchten 4+1)

For **every** ARCH-NNN module, define explicit interface contracts:

| Direction | Name | Type | Format | Constraints |
|-----------|------|------|--------|-------------|
| Input | [param] | [type] | [format] | [range/required] |
| Output | [return] | [type] | [format] | [guarantees] |
| Exception | [error] | [code] | [format] | [when thrown] |

**Rules**:
- No "black box" modules — every ARCH module MUST have a contract table
- Distinguish between synchronous and asynchronous interfaces
- Error contracts directly drive **Interface Fault Injection** testing
- Input/output contracts directly drive **Interface Contract Testing**
- Cross-cutting modules MUST also have contracts defined here

#### 4.4 Data Flow View — Data Transformation Chains (Kruchten 4+1)

Trace data through architecture modules:

| Stage | Module | Input Format | Transformation | Output Format |
|-------|--------|-------------|----------------|---------------|

**Rules**:
- Show intermediate data formats at each stage
- Reference `ARCH-NNN` IDs in the chain
- Each flow traces input → transformation → output with intermediate formats
- Data flows directly drive **Data Flow Testing** in the integration test phase

### 5. Safety-Critical Sections (Conditional)

**Only generate these sections if `v-model-config.yml` has `domain` set.**

#### ASIL Decomposition (ISO 26262-9 §5)

| Parent Component | Parent ASIL | Child Module | Child ASIL | Independence Argument |
|-----------------|-------------|-------------|------------|----------------------|

- Document parent SYS ASIL → child ARCH ASIL allocation
- Cover independence arguments for ASIL decomposition

#### Defensive Programming (ISO 26262-6 §7.4.2 / DO-178C §6.3.3)

| Module | Invalid Input | Detection Method | Recovery Action |
|--------|--------------|-----------------|-----------------|

- Document how invalid inputs from one module are caught by another
- Cover input validation, range checks, and assertion strategies

#### Temporal & Execution Constraints (DO-178C §6.3.4)

| Module | Constraint Type | Value | Enforcement Mechanism |
|--------|----------------|-------|----------------------|

- Watchdog timers, execution order dependencies, deadlock prevention
- Maximum execution time per module, scheduling constraints

### 6. Coverage Gate

Run `validate-architecture-coverage.sh` (or reference its logic) for forward coverage:

- Every `SYS-NNN` has at least one `ARCH-NNN`
- No orphaned ARCH without SYS parent or `[CROSS-CUTTING]` tag
- Flag any gaps as errors — do not proceed with incomplete coverage

Note: backward coverage (ARCH→ITP) will be validated after integration test generation.

### 7. Write Output

Write the complete architecture design document to `{VMODEL_DIR}/architecture-design.md` using the template structure. Include:

1. **Header section**: Feature name, branch, date, source reference
2. **Overview**: Brief description of the architecture decomposition rationale
3. **ID Schema**: Document the ARCH-NNN → SYS-NNN relationship encoding
4. **Logical View**: All ARCH modules with parent SYS mappings
5. **Process View**: Mermaid sequence diagrams for critical interactions
6. **Interface View**: Strict API contracts for every ARCH module
7. **Data Flow View**: Data transformation chains through modules
8. **Safety-Critical Sections**: ASIL, Defensive Programming, Temporal Constraints (if domain configured)
9. **Coverage Summary**: Module count, forward coverage percentage
10. **Derived Modules**: List of flagged items requiring human resolution

### 8. Report Completion

Display a summary:
- Total architecture modules generated (by type: Component/Service/Library/Utility/Adapter)
- Cross-cutting module count (with rationale summary)
- Forward coverage: X/Y SYS components covered (must be 100% or flagged)
- Interface contracts defined: N/N ARCH modules (must be 100%)
- Mermaid diagrams generated (count)
- Derived modules flagged (count and brief descriptions)
- Safety-critical sections included (yes/no, which domain)
- Path to the generated file
- Next step: Recommend running `/speckit.v-model.integration-test` to generate the paired test plan

## Operating Constraints

### Strict Translation Rules

When decomposing from `system-design.md`:
- **DO NOT** invent capabilities, modules, or components not traceable to a SYS-NNN or justified as `[CROSS-CUTTING]`
- **DO NOT** add architecture modules based on "common sense" or "best practices" without traceability
- **DO** flag genuinely necessary but undocumented capabilities as `[DERIVED MODULE]`
- **DO** ensure every SYS-NNN appears as a parent in at least one ARCH-NNN
- **DO** document all interface contracts explicitly in the Interface View
- **DO** generate syntactically valid Mermaid diagrams in the Process View

### ID Rules

- IDs are **permanent** — once assigned, they are never renumbered or reassigned
- Sequential numbering: ARCH-001, ARCH-002, ARCH-003...
- When updating existing designs, preserve all existing IDs and append new ones
- Gaps in numbering are acceptable (e.g., if ARCH-003 is removed, ARCH-004 stays ARCH-004)

### View Completeness Rules

- All four architecture views (Logical, Process, Interface, Data Flow) are **mandatory**
- Every ARCH module must appear in the Logical View
- Every ARCH module that interacts with another must appear in the Process View
- Every ARCH module MUST appear in the Interface View (no exceptions — no black boxes)
- Every ARCH module that transforms data must appear in the Data Flow View

### Many-to-Many Mapping Rules

- A single SYS may be decomposed across multiple ARCH modules
- A single ARCH may implement multiple SYS components
- The Logical View's "Parent System Components" column is the **single source of truth** for this mapping
- The `validate-architecture-coverage.sh` script parses this column to compute coverage

### Scale Handling

- Handle 50+ SYS inputs without truncation or summarization
- Every SYS must be addressed individually — do not batch or skip
- Graceful failure: empty `system-design.md` → error message, not crash
