---
description: Generate a combined system-level and architecture-level design in one document to preserve traceability and reduce review handoffs.
handoffs:
  - label: Generate System Tests
    agent: speckit.v-model.system-test
    prompt: Generate the system test plan for this combined design
    send: true
  - label: Generate Integration Tests
    agent: speckit.v-model.integration-test
    prompt: Generate the integration test plan for this combined design
    send: true
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

Generate a single, combined system-and-architecture design document that preserves both the outer SWE.2 system decomposition and the inner SWE.2 architectural decomposition in one reviewable artifact. The output must include:

- `SYS-NNN` system components with IEEE 1016 views
- `ARCH-NNN` architecture modules with IEEE 42010/Kruchten 4+1 views
- explicit many-to-many `REQ↔SYS↔ARCH` traceability
- clear separation of system-level and architecture-level rationale

This command is intended for pure-software or SWE-only projects where the separate `system-design.md` and `architecture-design.md` review handoff is too heavy.

## Execution Steps

### 1. Setup

Run `{SCRIPT}` from the repository root and parse the JSON output.

The script returns JSON with these keys:
- `VMODEL_DIR`: Path to `specs/{feature}/v-model/` directory
- `FEATURE_DIR`: Path to `specs/{feature}/` directory
- `BRANCH`: Current branch name
- `REQUIREMENTS`: Path to `requirements.md` (MUST exist — script uses `--require-reqs`)
- `AVAILABLE_DOCS`: Array of documents that currently exist

### 2. Load Context

1. Read `templates/system-architecture-design-template.md` from the extension directory to understand the required output structure.

2. Read `requirements.md` from the `REQUIREMENTS` path. This is the sole source of truth for what the system and architecture must do.
   - Extract all `REQ-NNN` identifiers
   - Note the total count — every REQ must appear in at least one `SYS-NNN` row

3. If `AVAILABLE_DOCS` contains `"spec.md"`, read it for stakeholder and domain context.

4. If `AVAILABLE_DOCS` contains `"system-design.md"` or `"architecture-design.md"`, read them to preserve existing IDs and avoid renumbering.
   - Preserve existing `SYS-NNN` and `ARCH-NNN` IDs
   - Append new IDs after the highest existing sequence

### 3. Load Configuration

If `v-model-config.yml` exists at the repository root:
- If `domain` is set and overlays exist, note domain-specific design sections for both system and architecture as applicable
- If no domain overlay is loaded, proceed with generic best-practice terminology only

### 4. Decompose Requirements into System Components

Follow the system-design rules from `commands/system-design.md`:
- Create `SYS-NNN` components with names, descriptions, parent `REQ` mappings, and type classification
- Populate IEEE 1016 views: Decomposition, Dependency, Interface, Data Design
- Perform ISO/IEC 25010 quality attribute cross-check
- Flag any derived requirements explicitly

### 5. Decompose System Components into Architecture Modules

Follow the architecture-design rules from `commands/architecture-design.md`:
- Create `ARCH-NNN` modules with names, descriptions, parent `SYS` mappings, and type classification
- Populate IEEE 42010/Kruchten 4+1 views: Logical, Process, Interface, Data Flow
- Perform ISO/IEC 42030/25010 architecture evaluation
- Flag any derived modules explicitly

### 6. Preserve and Expose Traceability

Ensure the combined document makes traceability explicit at every layer:
- `REQ-NNN` → `SYS-NNN`
- `SYS-NNN` → `ARCH-NNN`
- `REQ-NNN` → `ARCH-NNN` through parent `SYS` relationships

If a requirement or component changes, mark affected downstream elements as `[SUSPECT]`.

### 7. Write Output

Write the combined design document to `{VMODEL_DIR}/system-architecture-design.md` using the template structure. Include:
1. Header with feature name, branch, date, source references
2. System Design overview and IEEE 1016 views
3. Architecture Design overview and IEEE 42010/Kruchten 4+1 views
4. Traceability summary and coverage status
5. Quality attribute coverage and evaluation
6. Derived requirements / derived modules list

### 8. Report Completion

Summarize:
- total `SYS` and `ARCH` elements generated
- `REQ` coverage percentage
- key dependency and interface counts
- any derived gaps or suspect items
- path to generated file
- recommended next step: run `/speckit.v-model.system-test` or `/speckit.v-model.integration-test`

## Governing Standards

This command bridges the system-level IEEE 1016 viewpoint and the architecture-level IEEE 42010/Kruchten 4+1 viewpoint in a single artifact.
