# Feature Specification: Software Architecture Design

**Feature Branch**: `007-software-architecture-design`
**Created**: 2026-05-04
**Status**: Approved
**Input**: Add a merged software architecture design command that generates a software architecture artifact from `requirements.md` alone and integrates ASPICE SWE.2 process guidance.

## Governing Standards

This feature synthesizes two complementary international standards into a single artifact:

| Standard | Role | Key Contribution |
|----------|------|------------------|
| **IEEE 1016:2009** — Software Design Description (SDD) | Provides the **design entity model** and decomposition framework. Defines how design entities (components, modules) are identified, named, attributed, and related. | Decomposition View (§5.1): hierarchical breakdown of requirements into design entities with attributes (purpose, function, subordinates). Dependency View (§5.2): relationships and coupling between design entities. Interface View (§5.3): external and internal interface identification. Data Design View (§5.4): data models and schemas. |
| **IEEE 42010:2011** — Architecture Description / **Kruchten 4+1** | Provides the **architecture viewpoint framework**. Defines how architecture views are structured and documented. | Logical View: module responsibilities and domain partitioning (synthesizes IEEE 1016 Decomposition + Dependency). Process View: concurrency and runtime interactions (unique to 42010/4+1). Interface View: module-to-module API contracts (extends IEEE 1016 Interface View with protocol bindings). Data Flow View: transformation chains (extends IEEE 1016 Data Design with pipeline semantics). |
| **ASPICE SWE.2** | Provides **software architectural design process** practices. Included only when `domain: iso_26262`. | BP1–BP9: process structure, requirement allocation, interface definition, dynamic behavior, resource objectives, alternatives evaluation, traceability, consistency, communication. |

> **Fusion note**: The four output views (Logical, Process, Interface, Data Flow) use IEEE 42010 as the structural framework. IEEE 1016 design entity attributes — purpose, function, subordinates, dependencies — are embedded within the Logical View as structured columns. IEEE 1016 interface identification principles inform the Interface View. IEEE 1016 data design concepts inform the Data Flow View. This synthesis enables Path B to cover what Path A achieves through two separate steps (IEEE 1016 system-design + IEEE 42010 architecture-design) in a single artifact.

## Clarifications

### Session 2026-05-04

- Q: Should ASPICE SWE.2 process guidance apply only to `iso_26262`, or to all three regulated domains (`iso_26262`, `do_178c`, `iec_62304`)? → A: SWE.2 guidance applies **only** when domain is `iso_26262`. Other regulated domains (`do_178c`, `iec_62304`) do not trigger SWE.2 sections.
- Q: Should domain overlay files (`commands/overlays/{domain}/software-architecture-design.md`) be created as part of this feature? → A: Yes, create overlay files for all three domains (`iso_26262`, `do_178c`, `iec_62304`). ASPICE SWE.2 is primarily automotive and goes in the `iso_26262` overlay. The `do_178c` and `iec_62304` overlays are prepared as stubs for future domain-specific standards. IEEE 42010 architecture views remain in the base template and are NOT domain-gated.
- Q: What should `software-architecture-design` do when `architecture-design.md` (from Path A) already exists in the v-model directory? → A: Warn but generate anyway. Both artifacts coexist; `integration-test` already has a documented preference rule for `software-architecture-design.md`.
- Q: Should Path B `ARCH-NNN` elements reference `SYS-NNN` parents from `system-design.md` when both exist, or trace strictly to `REQ-NNN`? → A: Strict `REQ → ARCH` only. Path B is independent of `system-design.md`; ARCH elements never reference SYS parents. The combined scope (replacing system-design + architecture-design) is achieved by reading requirements directly, not by layering on SYS decomposition.
- Q: SC-004 (ASPICE SWE.2 compliance score) is only meaningful for `iso_26262`. Should it be gated, or replaced? → A: Gate SC-004 to `iso_26262` only; add a new domain-agnostic SC for IEEE 42010 view completeness (all four views populated with non-empty content).

## Purpose

This feature introduces `/speckit.v-model.software-architecture-design`, which reads `requirements.md` and produces `software-architecture-design.md`.
The output synthesizes IEEE 1016:2009 design entity description with IEEE 42010 architecture viewpoints, and, when the domain is `iso_26262`, explicit SWE.2 process structure — enabling richer design documentation and traceability in a single artifact that replaces the separate `system-design` + `architecture-design` chain.

## Scope

- New command: `speckit.v-model.software-architecture-design`
- New template: `templates/software-architecture-design-template.md` (synthesizes IEEE 1016 design entities within IEEE 42010 views — domain-agnostic)
- New domain overlays: `commands/overlays/iso_26262/software-architecture-design.md` (ASPICE SWE.2 BP1–BP9), `commands/overlays/do_178c/software-architecture-design.md` (stub), `commands/overlays/iec_62304/software-architecture-design.md` (stub)
- New feature example: `specs/007-software-architecture-design/v-model`
- Setup script adaptation to support `software-architecture-design.md`
- Documentation updates for the new command

## Example Workflow

1. Generate requirements: `/speckit.v-model.requirements`
2. Generate merged software architecture design: `/speckit.v-model.software-architecture-design`
3. Generate integration tests: `/speckit.v-model.integration-test`

## Outcome

A single software architecture document that:
- preserves requirements traceability
- documents architecture element decomposition, interfaces, dynamic behavior, and data flow — synthesizing IEEE 1016:2009 design entity description within IEEE 42010 architecture viewpoints
- captures ASPICE SWE.2 decision rationale and review guidance (only when `domain: iso_26262` in `v-model-config.yml`)

## User Scenarios & Testing

### User Story 1 - Generate Software Architecture Design from Requirements (Priority: P1)

As a software architect, I want to generate a comprehensive software architecture design document directly from the requirements.md file, so that I can quickly create architecture documentation that maintains traceability to requirements.

**Why this priority**: This is the core functionality that enables the primary workflow of creating architecture from requirements, delivering immediate value for architecture design.

**Independent Test**: Can be fully tested by running the command on a valid requirements.md file and verifying the output software-architecture-design.md contains the expected sections and content derived from requirements.

**Acceptance Scenarios**:

1. **Given** a valid requirements.md file exists, **When** I run `/speckit.v-model.software-architecture-design`, **Then** a software-architecture-design.md file is created with four architecture views (Logical, Process, Interface, Data Flow) that synthesize IEEE 1016 design entity attributes within IEEE 42010 viewpoints, populated from the requirements.
2. **Given** requirements.md contains functional and non-functional requirements, **When** the command executes, **Then** the output includes architecture element decomposition with IEEE 1016 design entity attributes (purpose, function, subordinates, dependencies), interfaces, and dynamic behavior derived from those requirements.

### User Story 2 - Integrate ASPICE SWE.2 Process Guidance (iso_26262 domain only) (Priority: P2)

As a quality assurance engineer working on an ISO 26262 automotive project (domain configured as `iso_26262`), I want the software architecture design to include ASPICE SWE.2 process structure and guidance, so that the design process follows industry standards for software engineering excellence. When the domain is not `iso_26262`, the SWE.2 sections are omitted from the output.

**Why this priority**: This adds compliance and quality assurance value for automotive safety projects, enhancing the tool's usefulness for ISO 26262 regulated environments.

**Independent Test**: Can be tested by (a) running with `domain: iso_26262` and verifying SWE.2 sections are present, and (b) running with `domain: do_178c` / `domain: iec_62304` / no domain config and verifying SWE.2 sections are absent.

**Acceptance Scenarios**:

1. **Given** `v-model-config.yml` sets `domain: iso_26262` and requirements.md is processed, **When** the command generates the architecture design, **Then** the output includes explicit SWE.2 process structure (BP1–BP9) with decision rationale and review guidance sections.
2. **Given** `v-model-config.yml` does not set `domain: iso_26262` (e.g., `do_178c`, `iec_62304`, or absent), **When** the command generates the architecture design, **Then** the output does NOT include SWE.2-specific sections; only the base IEEE 42010 views are produced.

### Edge Cases

- What happens when requirements.md is missing or invalid?
- How does the system handle requirements with conflicting or ambiguous specifications?
- What if the requirements.md contains non-software requirements that don't translate to architecture elements?
- What happens when both `architecture-design.md` (Path A) and `software-architecture-design.md` (Path B) exist in the same v-model directory? (→ Warn but proceed; both coexist. `integration-test` prefers `software-architecture-design.md`.)

## Requirements

### Functional Requirements

- **FR-001**: The system MUST read and parse a valid requirements.md file as input.
- **FR-002**: The system MUST generate a software-architecture-design.md file containing four architecture views (Logical, Process, Interface, Data Flow) that synthesize IEEE 1016:2009 design entity description with IEEE 42010 architecture viewpoints. See Governing Standards for the mapping.
- **FR-003**: The system MUST include architecture element decomposition derived from functional requirements, with each element documenting IEEE 1016 design entity attributes: unique identifier (ARCH-NNN), purpose (name + description), function (what it does), subordinates (none at this level), and dependencies (parent REQ-NNN identifiers).
- **FR-004**: The system MUST document interfaces and dynamic behavior based on requirements analysis.
- **FR-005**: The system MUST preserve traceability links strictly from requirements (`REQ-NNN`) to architecture elements (`ARCH-NNN`). Path B ARCH elements do NOT reference `SYS-NNN` parents — even if `system-design.md` exists in the same v-model directory.
- **FR-006**: The system MUST integrate ASPICE SWE.2 process guidance (BP1–BP9) including decision rationale and review guidance sections ONLY when `v-model-config.yml` has `domain: iso_26262`. When domain is absent or set to any other value, SWE.2 sections MUST be omitted.
- **FR-007**: The system MUST handle edge cases gracefully with appropriate error messages or warnings.
- **FR-008**: When `architecture-design.md` (Path A artifact) already exists in the v-model directory, the system MUST emit a warning and proceed with generating `software-architecture-design.md`; both artifacts coexist.

### Key Entities

- **Requirements**: Functional and non-functional specifications that drive the architecture design.
- **Architecture Elements (Design Entities per IEEE 1016 §4.1)**: Components, modules, and subsystems decomposed from requirements. Each element is a "design entity" with attributes: identifier, purpose, function, subordinates (if any), and dependencies.
- **Interfaces** (per IEEE 1016 §5.3 + IEEE 42010 Interface View): Connections and interactions between architecture elements, including protocol bindings and error handling strategies.
- **Dynamic Behavior** (per IEEE 42010 Process View): Runtime behavior, concurrency model, and interaction patterns derived from requirements.
- **Data Flow** (per IEEE 1016 §5.4 + IEEE 42010 Data Flow View): Data transformations, pipeline stages, and intermediate formats.
- **SWE.2 Guidance**: ASPICE process elements including decision rationale and review criteria.

## Success Criteria

### Measurable Outcomes

- **SC-001**: The command completes generation of software-architecture-design.md in under 30 seconds for typical requirements files (up to 10,000 words).
- **SC-002**: Generated documents contain 100% of required architecture view sections (Logical, Process, Interface, Data Flow — synthesizing IEEE 1016 within IEEE 42010 viewpoints per Governing Standards).
- **SC-002a**: All four views are populated with non-empty, non-placeholder content. Logical View elements SHALL include IEEE 1016 design entity attributes (purpose, function, subordinates, dependencies).
- **SC-003**: All functional requirements from input are traceable to at least one architecture element in the output.
- **SC-004**: When `domain: iso_26262`, ASPICE SWE.2 compliance score of 90% or higher when evaluated against SWE.2 BP1–BP9 criteria. Not applicable to other domains.
- **SC-005**: 95% of users can successfully generate valid architecture designs without manual intervention.

## Assumptions

- Requirements.md follows the expected format and contains valid, unambiguous requirements.
- The system has access to necessary templates and processing logic for IEEE 1016:2009 (design entity identification), IEEE 42010 (viewpoint structuring), and ASPICE SWE.2 (iso_26262 only).
- Users have basic understanding of software architecture concepts. Knowledge of IEEE 1016 design entities and ASPICE process is beneficial for review but not required for generation.
