---
description: Generate a comprehensive software architecture design from requirements alone, synthesizing IEEE 1016 design entities within IEEE 42010 views. Replaces system-design + architecture-design (Path B).
handoffs:
  - label: Generate Integration Tests
    agent: speckit.v-model.integration-test
    prompt: Generate the integration test plan for this software architecture design
    send: true
  - label: Back to Requirements
    agent: speckit.v-model.requirements
    prompt: Review or update requirements
scripts:
  sh: scripts/bash/setup-v-model.sh --json --require-reqs
  ps: scripts/powershell/setup-v-model.ps1 -Json -RequireReqs
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Generate a comprehensive software architecture design derived from `requirements.md` alone, synthesizing **IEEE 1016:2009** (Software Design Description — design entity model) within **IEEE 42010:2011** (Architecture Description — viewpoint framework). This single artifact replaces the two-step Path A chain (`system-design` → `architecture-design`).

The output must support:
- `REQ-NNN` → `ARCH-NNN` traceability (no intermediate `SYS-NNN` layer)
- four architecture views synthesizing IEEE 1016 design entities within IEEE 42010 viewpoints:
  - **Logical View** ← IEEE 1016 Decomposition (§5.1) + Dependency (§5.2) within IEEE 42010 Logical View table
  - **Process View** ← IEEE 42010 / Kruchten 4+1 (no IEEE 1016 counterpart — synthesis differentiator)
  - **Interface View** ← IEEE 1016 Interface Identification (§5.3) + IEEE 42010 protocol bindings, with external/internal distinction
  - **Data Flow View** ← IEEE 1016 Data Design (§5.4) + IEEE 42010 pipeline semantics
- ASPICE SWE.2 process guidance (only when `domain: iso_26262` in `v-model-config.yml`)
- ISO/IEC 42030:2019 architecture evaluation + ISO/IEC 25010:2023 quality attribute cross-check
- explicit handling of derived requirements, derived modules, and cross-cutting elements

## Execution Steps

### 1. Setup

Run `{SCRIPT}` from the repository root and parse the JSON output.

The script returns JSON with these keys:
- `VMODEL_DIR`: Path to `specs/{feature}/v-model/` directory
- `FEATURE_DIR`: Path to `specs/{feature}/` directory
- `BRANCH`: Current branch name
- `REQUIREMENTS`: Path to `requirements.md` (MUST exist — script uses `--require-reqs`)
- `AVAILABLE_DOCS`: Array of documents that currently exist

For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

### 2. Load Context

1. **Load the template**: Read `templates/software-architecture-design-template.md` from the extension directory to understand the required output structure.

2. **Load requirements**: Read `requirements.md` from the `REQUIREMENTS` path. This is the **sole source of truth** for what the system must do.
   - Extract all `REQ-NNN` identifiers (all categories: functional, non-functional, interface, constraint)
   - Note the total count — every REQ must appear as a parent in at least one ARCH element

3. **Load spec.md** (if `AVAILABLE_DOCS` contains `"spec.md"`): Read for supplementary context (user stories, acceptance scenarios, edge cases). This provides architectural insight but does NOT override requirements.

4. **Load domain config**: Read `v-model-config.yml` if it exists at the repository root. Note the `domain` value.

5. **Check Path A coexistence**: If `AVAILABLE_DOCS` contains `"architecture-design.md"`, note that both Path A and Path B artifacts will coexist. Emit a warning but proceed. `integration-test` already prefers `software-architecture-design.md`.

### 3. Domain Configuration

Load `v-model-config.yml` if it exists at the repository root.

**If `domain` is set** (e.g., `iso_26262`, `do_178c`, `iec_62304`):
1. Read the command overlay: `commands/overlays/{domain}/software-architecture-design.md`
   - If it exists: note the domain-specific design sections (e.g., SWE.2 BP1–BP9 for `iso_26262`, DAL allocation for `do_178c`, safety class allocation for `iec_62304`)
   - If it does not exist: this domain does not extend this command — proceed with base only
2. Where the base command references "domain overlay sections", use the overlay's guidance in preference

**If `domain` is empty or absent:**
- Produce clean, industry-neutral output
- Do NOT include any domain-specific regulatory references
- SWE.2 sections are NOT generated

### 4. Lifecycle Rules (When Evolving Existing Artifacts)

When an existing `software-architecture-design.md` is loaded, apply these rules before generating new content:

1. **Never delete an ID** — mark as `[DEPRECATED]`
2. **Deprecation types:**
   - `[DEPRECATED — Superseded by ARCH-NNN]`: Replaced by a new element
   - `[DEPRECATED — Withdrawn: <reason>]`: Removed entirely with justification
3. **Suspect detection from parent REQ:** If a parent REQ (in `requirements.md`) is deprecated or modified, mark each ARCH that traces to it as `[SUSPECT — Parent REQ-NNN {deprecated|modified}]`.
4. **Suspect resolution:** For each suspect ARCH:
   - **Re-parent** to the superseding REQ (if capability continues under a new requirement)
   - **Deprecate** (if the requirement is withdrawn — cascade to downstream MOD, ITP)
   - **Confirm active** (if still valid despite the parent change — remove the SUSPECT tag)
5. **Modified elements:** Update content in-place, preserve the original ARCH ID. Downstream artifacts (MOD, ITP) tracing to this ARCH become suspect.

If no existing `software-architecture-design.md` is found, skip this step — all elements are new.

### 5. Decompose Requirements into Architecture Elements

Follow the **strict translator constraint**: You are decomposing requirements into architecture elements. You must NOT invent capabilities not present in `requirements.md`.

#### 5.1 Decomposition by Requirement Category

- **Functional requirements** (`REQ-NNN`): Each maps to one or more dedicated architecture elements. Group related capabilities into cohesive components.
- **Non-functional requirements** (`REQ-NF-NNN`): Map to cross-cutting elements (e.g., logging, caching, error handling) or as additional parents on existing elements that implement the quality attribute.
- **Interface requirements** (`REQ-IF-NNN`): Map to elements that own the interface contract. These will have detailed entries in the Interface View.
- **Constraint requirements** (`REQ-CN-NNN`): Map to the same elements as their related functional requirements. Constraints modify behavior, not add new elements.

#### 5.2 Architecture Element Assignment

For each architecture element identified:

1. **Assign a unique ID**: `ARCH-NNN` (e.g., ARCH-001, ARCH-002). Sequential numbering, 3-digit zero-padded, never renumbered.

2. **Name the element**: Short, descriptive name (e.g., "Requirements Parser", "Event Dispatcher", "Output Assembler").

3. **Describe the element (IEEE 1016 purpose + function)**: What it does, its responsibility boundary. Must be specific enough to define an API contract — if a description is too vague to derive inputs/outputs/exceptions, refine until concrete.

4. **Map parent requirements (IEEE 1016 dependencies)**: List ALL `REQ-NNN` identifiers that this element satisfies. Many-to-many mapping is expected:
   - A single ARCH may satisfy multiple REQs (e.g., `ARCH-003` satisfies `REQ-001, REQ-005, REQ-NF-002`)
   - A single REQ may be satisfied by multiple ARCH elements (e.g., `REQ-001` is a parent of both `ARCH-001` and `ARCH-003`)

5. **Classify type**: Component | Service | Library | Utility | Adapter | Cross-Cutting.

#### 5.3 Cross-Cutting Rules (per IEEE 42010)

- Infrastructure/utility elements (Logger, Thread Pool, Config Manager, ID Pattern Library, etc.) use `[CROSS-CUTTING]` tag with rationale explaining why the element is system-wide
- Every `[CROSS-CUTTING]` element MUST still have interface contracts in the Interface View and at least one parent `REQ-NNN`
- Cross-cutting elements are NOT derived — they are legitimate architecture components

#### 5.4 Derived Module Rules

- If an element is neither traceable to a `REQ-NNN` nor qualifies as `[CROSS-CUTTING]`, flag it as `[DERIVED MODULE: description of the needed capability and why it is architecturally necessary]`
- Do NOT silently assign an `ARCH-NNN` to derived modules — halt and flag
- List all derived modules in the "Derived Requirements and Modules" section of the output

#### 5.5 Derived Requirement Rules (per IEEE 1016 §4.3)

- If a capability is implied by the architecture but has no corresponding `REQ-NNN`, flag it as `[DERIVED REQUIREMENT: description of the capability and why it is architecturally necessary]`
- The human must resolve each derived item before proceeding to integration test generation

#### 5.6 Anti-Pattern Guard (per IEEE 42010)

- Reject "black box" descriptions: every `ARCH-NNN` MUST have an explicit interface contract (inputs, outputs, exceptions) in the Interface View
- If an element description is too vague to derive contracts, emit a warning and refine until concrete

### 6. Build the Four Synthesized Architecture Views

#### 6.1 Logical View (IEEE 1016 Decomposition §5.1 + Dependency §5.2 within IEEE 42010)

The primary view. Fill the Logical View table with all ARCH elements:

| ARCH ID | Name | Description (Purpose) | Parent Requirements (Dependencies) | Type |
|---------|------|----------------------|-----------------------------------|------|

**Rules**:
- Every `REQ-NNN` from `requirements.md` must appear in at least one row's "Parent Requirements" column
- Use comma-separated `REQ-NNN` list for many-to-many relationships
- Cross-cutting elements appear with `[CROSS-CUTTING] — rationale` in the Parent Requirements column
- No ARCH element may have an empty Parent Requirements field (unless `[CROSS-CUTTING]`)
- The Description column serves as the IEEE 1016 "purpose" and "function" attributes

#### 6.2 Process View (IEEE 42010 / Kruchten 4+1 — no IEEE 1016 counterpart)

Document runtime interactions using Mermaid sequence diagrams:

1. For each critical interaction path, generate a `sequenceDiagram` with ARCH-NNN as participants
2. Document concurrency model (pipeline, event loop, actor model, etc.)
3. Show synchronization points, decision branches, and execution order constraints
4. Include domain branching logic (e.g., SWE.2 generation gated by domain)

**Rules**:
- Use Mermaid `sequenceDiagram` syntax — diagrams MUST be syntactically valid
- Reference `ARCH-NNN` IDs as participants
- Model interaction flows from requirements analysis (not from a system design Dependency View — there is none in Path B)
- This view directly feeds **Concurrency & Race Condition Testing** in integration test

#### 6.3 Interface View (IEEE 1016 §5.3 Interface Identification + IEEE 42010)

Define interface contracts for **every** ARCH-NNN element, with explicit external/internal distinction:

**External Interfaces** (CLI args, file I/O, user-facing boundaries):
| ARCH ID | Interface Name | Direction | Protocol | Input | Output | Error Handling |

**Internal Interfaces** (element-to-element communication):
| Source ARCH | Target ARCH | Interface Name | Protocol | Data Format | Error Handling |

**Rules**:
- MUST distinguish between external and internal interfaces — separate tables (per IEEE 1016 §5.3)
- External interfaces focus on protocol compliance, input validation, and error responses
- Internal interfaces focus on contract adherence, data format correctness, and failure propagation
- No "black box" elements — every ARCH module MUST have contract entries
- Cross-cutting elements MUST also have contracts defined
- This view directly feeds **Interface Contract Testing** and **Interface Fault Injection** in integration test

#### 6.4 Data Flow View (IEEE 1016 §5.4 Data Design + IEEE 42010)

Trace data through the architecture pipeline and document data structures:

| Stage | Module | Input Format | Transformation | Output Format |
|-------|--------|-------------|----------------|---------------|

**Data Design supplement** (per IEEE 1016 §5.4):
| Data Entity | Owning ARCH | Storage | Protection | Lifecycle |
|-------------|-------------|---------|------------|-----------|

**Rules**:
- Show intermediate data formats at each pipeline stage
- Document data protection measures (at rest, in transit) where applicable
- Each flow traces input → transformation → output with intermediate formats
- Data flows directly drive **Data Flow Testing** in integration test

### 7. Architecture Evaluation (ISO/IEC 42030:2019 / ISO/IEC 25010:2023)

After generating the four views, perform a scenario-based fitness-for-purpose evaluation. This completes the IEEE 42010 "describe" → ISO 42030 "evaluate" cycle.

#### 7.1 Quality Attribute Cross-Check (ISO/IEC 25010:2023)

For each characteristic implied or explicitly stated in `requirements.md`, confirm at least one ARCH element or view decision covers it:

| Quality Characteristic | ISO/IEC 25010 Ref | Design Evidence Required |
|------------------------|-------------------|--------------------------|
| Functional Suitability (completeness, correctness) | §4.2.1 | Every `REQ-NNN` maps to at least one `ARCH-NNN` |
| Reliability (availability, fault tolerance, recoverability) | §4.2.2 | Interface View documents error handling and failure propagation |
| Performance Efficiency (time behaviour, resource utilisation) | §4.2.3 | Interface View or Data Flow View specifies performance constraints |
| Security (confidentiality, integrity, authenticity) | §4.2.5 | Data Flow View documents protection at rest/in transit for sensitive data |
| Maintainability (modularity, reusability, testability) | §4.2.7 | Logical View separates concerns; every interface is explicitly contracted |
| Safety (if applicable per domain) | §4.2.9 | ARCH elements link to domain-specific safety sections |

**Action on gaps**: If a characteristic implied by the requirements is NOT addressed by any ARCH element or view decision, flag it as `[QUALITY GAP: ISO 25010 §X.X — <characteristic> not explicitly addressed]`.

#### 7.2 Quality Attribute Justification (ISO/IEC 42030:2019)

For each significant architectural decision (one that affects more than one view or introduces a cross-cutting element), document its quality attribute rationale:

| Architecture Decision | Quality Characteristic (ISO 25010) | Trade-off Accepted |
|----------------------|------------------------------------|--------------------|
| e.g., Pipeline architecture | Maintainability §4.2.7 ↑, Performance §4.2.3 ↓ | Sequential dependency accepted for modularity and testability |

#### 7.3 Sensitivity and Trade-off Points

List any **sensitivity points** (where a small change significantly affects quality) and **trade-off points** (where improving one characteristic degrades another). Include these in the Architecture Overview.

### 8. Write Output

Write the final artifact to `{VMODEL_DIR}/software-architecture-design.md` using the template structure. Include:
- header metadata (feature, branch, date)
- source references for `requirements.md`
- IEEE 1016/42010 synthesized architecture views (Logical, Process, Interface, Data Flow)
- Architecture evaluation (ISO 42030 + ISO 25010)
- traceability summary and coverage metrics
- derived requirement/module records

### 9. Finish

If the output is complete and valid, conclude with a summary that confirms:
- `REQ-NNN` → `ARCH-NNN` coverage (forward and backward)
- all four views populated with non-placeholder content (SC-002a)
- architecture evaluation performed (ISO 42030 + ISO 25010)
- no silent derived artifacts — all flagged for human review
- Path A coexistence warning (if `architecture-design.md` was detected)
