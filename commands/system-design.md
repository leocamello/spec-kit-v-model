---
description: Decompose requirements into IEEE 1016-compliant system components with four mandatory design views and many-to-many traceability.
handoffs:
  - label: Generate System Tests
    agent: speckit.v-model.system-test
    prompt: Generate the system test plan for this system design
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

Decompose a V-Model Requirements Specification (`requirements.md`) into an IEEE 1016-compliant Software Design Description where **every requirement maps to at least one system component** (`SYS-NNN`). The output organizes components into four mandatory design views (Decomposition, Dependency, Interface, Data Design) and supports many-to-many REQ↔SYS relationships. This document becomes the left side of V-Model Level 2, later paired with system test cases.

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

1. **Load the template**: Read `templates/system-design-template.md` from the extension directory to understand the required output structure.

2. **Load requirements**: Read `requirements.md` from the `REQUIREMENTS` path. This is the **sole source of truth** for what the system must do.
   - Extract all `REQ-NNN` identifiers (all categories: functional, non-functional, interface, constraint)
   - Note the total count — every REQ must appear as a parent in at least one SYS component

3. **Load spec.md** (if `AVAILABLE_DOCS` contains `"spec.md"`): Read for supplementary domain context (user stories, acceptance scenarios, edge cases). This provides architectural insight but does NOT override requirements.

4. **Load v-model-config.yml** (if it exists at the repository root):
   - If `domain` is set to `iso_26262`, `do_178c`, or `iec_62304`: Enable safety-critical sections (FFI, Restricted Complexity)
   - If absent or `domain` is empty: Skip safety-critical sections entirely

5. **Load existing system design** (if `AVAILABLE_DOCS` contains `"system-design.md"`):
   - Read the existing `system-design.md` to preserve existing SYS IDs and content
   - Identify the highest existing SYS number to continue the sequence
   - New components append after existing ones — **never renumber**

### 3. Decompose Requirements into System Components

Follow the **strict translator constraint**: You are decomposing requirements into architectural components. You must NOT invent capabilities not present in `requirements.md`.

For each system component identified during decomposition:

1. **Assign a unique ID**: `SYS-NNN` (e.g., SYS-001, SYS-002). Sequential numbering, never renumbered.

2. **Name the component**: Short, descriptive name (e.g., "Sensor Data Acquisition", "Alert Engine", "API Gateway").

3. **Describe the component**: What it does, its responsibility boundary. Must be specific enough to generate test cases.

4. **Map parent requirements**: List ALL `REQ-NNN` identifiers that this component satisfies as a comma-separated list. Many-to-many mapping is expected:
   - A single SYS may satisfy multiple REQs (e.g., `SYS-003` satisfies `REQ-001, REQ-005, REQ-NF-002`)
   - A single REQ may be satisfied by multiple SYS components (e.g., `REQ-001` is a parent of both `SYS-001` and `SYS-003`)

5. **Classify type**: Subsystem | Module | Service | Library | Utility

#### Decomposition Guidelines

- **Functional requirements** (`REQ-NNN`): Each maps to one or more dedicated components. Group related capabilities into cohesive subsystems.
- **Non-functional requirements** (`REQ-NF-NNN`): Map to cross-cutting components (e.g., logging service, caching layer) or as additional parents on existing components that implement the quality attribute.
- **Interface requirements** (`REQ-IF-NNN`): Map to components that own the interface contract. These will have detailed entries in the Interface View.
- **Constraint requirements** (`REQ-CN-NNN`): Typically map to the same components as their related functional requirements. Constraints modify behavior, not add new components.

### 4. Populate IEEE 1016 Design Views

#### 4.1 Decomposition View (IEEE 1016 §5.1)

The primary view. Fill the Decomposition View table from the template with all SYS components:

| SYS ID | Name | Description | Parent Requirements | Type |
|--------|------|-------------|---------------------|------|

**Rules**:
- Every `REQ-NNN` from `requirements.md` must appear in at least one row's "Parent Requirements" column
- Use comma-separated `REQ-NNN` list for many-to-many (e.g., `REQ-001, REQ-NF-002, REQ-IF-001`)
- No SYS component may have an empty Parent Requirements field

#### 4.2 Dependency View (IEEE 1016 §5.2)

Document inter-component relationships:

| Source | Target | Relationship | Failure Impact |
|--------|--------|-------------|----------------|

**Rules**:
- Identify every pair of components that interact (calls, reads, subscribes, etc.)
- Document the failure propagation path: if Target fails, what happens to Source?
- Include a simple dependency diagram (ASCII or Mermaid format)
- This view directly feeds **Fault Injection** test cases in the system test phase

#### 4.3 Interface View (IEEE 1016 §5.3)

Document API contracts with explicit external/internal distinction:

**External Interfaces** (user-facing, hardware boundaries):
| Component | Interface Name | Protocol | Input | Output | Error Handling |

**Internal Interfaces** (inter-module communication):
| Source | Target | Interface Name | Protocol | Data Format | Error Handling |

**Rules**:
- MUST distinguish between external and internal interfaces — separate tables
- External interfaces focus on protocol compliance, authentication, input validation
- Internal interfaces focus on contract adherence, data format correctness, failure propagation
- This view directly feeds **Interface Contract Testing** in the system test phase

#### 4.4 Data Design View (IEEE 1016 §5.4)

Document data structures and protection:

| Entity | Component | Storage | Protection at Rest | Protection in Transit | Retention |

**Rules**:
- Cover data-at-rest and data-in-transit security measures
- This view directly feeds **Boundary Value Analysis** in the system test phase
- Include data lifecycle (creation, update, deletion, retention)

### 4.5 Safety-Critical Sections (Conditional)

**Only generate these sections if `v-model-config.yml` has `domain` set.**

#### Freedom from Interference (ISO 26262-6 §7.4.8)

| Component | ASIL Rating | Isolation Mechanism | Verification Method |

- Document how components of different ASIL ratings are isolated
- Cover memory partitioning, time-slicing, and communication protection

#### Restricted Complexity (ISO 26262-6 §7.4.9)

| Component | Complexity Metric | Value | Threshold | Status |

- Flag any components with cyclomatic complexity, nesting depth, or coupling metrics that exceed safety thresholds

### 5. Derived Requirement Detection

During decomposition, the AI may identify a technical capability necessary for the architecture but not explicitly stated in `requirements.md`. These are **derived requirements**.

**Rules**:
- Do NOT silently create a `SYS-NNN` component for an undocumented capability
- Instead, flag it with: `[DERIVED REQUIREMENT: description of the needed capability and why it is architecturally necessary]`
- List all derived requirements in the "Derived Requirements" section of the output
- The human must resolve each one before proceeding to system test generation:
  1. Add the capability to `requirements.md` (creating a new REQ-NNN)
  2. Reject it as unnecessary
  3. Merge it into an existing requirement

### 6. Write Output

Write the complete system design document to `{VMODEL_DIR}/system-design.md` using the template structure. Include:

1. **Header section**: Feature name, branch, date, source reference
2. **Overview**: Brief description of the system architecture and decomposition rationale
3. **ID Schema**: Document the SYS-NNN → REQ-NNN relationship encoding
4. **Decomposition View**: All SYS components with parent REQ mappings
5. **Dependency View**: Inter-component relationships and failure propagation
6. **Interface View**: External and internal interfaces with contracts
7. **Data Design View**: Data structures, storage, and protection
8. **Safety-Critical Sections**: FFI and Restricted Complexity (if domain configured)
9. **Coverage Summary**: Component count, forward coverage percentage
10. **Derived Requirements**: List of flagged items requiring human resolution
11. **Glossary**: Domain-specific terms

### 7. Report Completion

Display a summary:
- Total system components generated (by type: Subsystem/Module/Service/Library/Utility)
- Forward coverage: X/Y REQs covered (must be 100% or flagged)
- Dependency relationships identified
- External vs internal interface count
- Derived requirements flagged (count and brief descriptions)
- Safety-critical sections included (yes/no, which domain)
- Path to the generated file
- Next step: Recommend running `/speckit.v-model.system-test` to generate the paired test plan

## Operating Constraints

### Strict Translation Rules

When decomposing from `requirements.md`:
- **DO NOT** invent capabilities, services, or components not traceable to a REQ-NNN
- **DO NOT** add architectural components based on "common sense" or "best practices"
- **DO** flag genuinely necessary but undocumented capabilities as `[DERIVED REQUIREMENT]`
- **DO** ensure every REQ-NNN appears as a parent in at least one SYS-NNN
- **DO** document inter-component dependencies explicitly in the Dependency View

### ID Rules

- IDs are **permanent** — once assigned, they are never renumbered or reassigned
- Sequential numbering: SYS-001, SYS-002, SYS-003...
- When updating existing designs, preserve all existing IDs and append new ones
- Gaps in numbering are acceptable (e.g., if SYS-003 is removed, SYS-004 stays SYS-004)

### View Completeness Rules

- All four IEEE 1016 views (Decomposition, Dependency, Interface, Data Design) are **mandatory**
- Every SYS component must appear in the Decomposition View
- Every SYS component that interacts with another must appear in the Dependency View
- Every SYS component with an API or data exchange must appear in the Interface View
- Every SYS component that owns data must appear in the Data Design View

### Many-to-Many Mapping Rules

- A single REQ may be decomposed across multiple SYS components
- A single SYS may satisfy multiple REQs
- The Decomposition View's "Parent Requirements" column is the **single source of truth** for this mapping
- The `validate-system-coverage.sh` script parses this column to compute coverage
