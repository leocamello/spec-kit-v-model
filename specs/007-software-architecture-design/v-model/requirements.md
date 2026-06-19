# V-Model Requirements Specification: Software Architecture Design (Path B)

**Feature Branch**: `007-software-architecture-design`
**Created**: 2026-05-04
**Status**: Approved
**Source**: `specs/007-software-architecture-design/spec.md`

## Overview

This document formalizes the requirements for `/speckit.v-model.software-architecture-design`, the combined Path B command that reads `requirements.md` directly and produces `software-architecture-design.md` with IEEE 42010 architecture views and (when `domain: iso_26262`) ASPICE SWE.2 process guidance. This command replaces the two-step Path A chain (`system-design` → `architecture-design`) with a single consolidated artifact.

Key architectural decisions from clarifications:
- **SWE.2 domain gate**: ASPICE SWE.2 BP1–BP9 sections are generated only when `v-model-config.yml` has `domain: iso_26262`. Other regulated domains (`do_178c`, `iec_62304`) do not trigger SWE.2 content.
- **Domain overlays**: Overlay files are created for all three domains. The `iso_26262` overlay contains SWE.2 guidance; `do_178c` and `iec_62304` overlays are stubs for future domain-specific standards.
- **Path A coexistence**: If `architecture-design.md` from Path A already exists, emit a warning and proceed; both artifacts coexist. `integration-test` already has a documented preference for `software-architecture-design.md`.
- **Strict REQ→ARCH traceability**: Path B ARCH elements trace strictly to `REQ-NNN` — never to `SYS-NNN` parents, even if `system-design.md` exists.
- **IEEE 42010 views are domain-agnostic**: The four mandatory views (Logical, Process, Interface, Data Flow) are always generated regardless of domain configuration.

All requirements are atomized from the feature specification using the strict translator constraint.

## Requirements

### Functional Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-001 | The extension SHALL provide a `/speckit.v-model.software-architecture-design` command that reads `requirements.md` as input and produces `software-architecture-design.md` as output. The command does NOT depend on `system-design.md`. | P1 | US1: This is the core combined Path B command that replaces system-design + architecture-design in a single step. | Test |
| REQ-002 | The command SHALL assign each architecture element a unique `ARCH-NNN` identifier (3-digit, zero-padded, e.g., `ARCH-001`), sequentially numbered and never renumbered once assigned. | P1 | US1, FR-002: Traceable identifiers are required for deterministic coverage validation and traceability matrix generation. | Inspection |
| REQ-003 | The `software-architecture-design.md` output SHALL include a **Logical View** listing how functional requirements are decomposed into architecture elements (`ARCH-NNN`), with each element's name, description, parent `REQ-NNN` identifiers, and type classification (Component, Service, Library, Utility, Adapter, Cross-Cutting). | P1 | US1, IEEE 42010: The Logical View proves each requirement is addressed by at least one architecture element. | Inspection |
| REQ-004 | The `software-architecture-design.md` output SHALL include a **Process View** documenting runtime interactions between architecture elements, including concurrency model and interaction patterns, with Mermaid `sequenceDiagram` blocks embedded in Markdown showing execution order and synchronization points. | P1 | US1, Kruchten 4+1: The Process View shows how architecture elements interact at runtime. | Inspection |
| REQ-005 | The `software-architecture-design.md` output SHALL include an **Interface View** documenting for every `ARCH-NNN` element: interface name, direction (Input/Output/Bidirectional), protocol, input format, output format, and error handling strategy. | P1 | US1, IEEE 42010: Interface contracts drive downstream integration testing. | Inspection |
| REQ-006 | The `software-architecture-design.md` output SHALL include a **Data Flow View** tracing how data moves through architecture elements — stage, module, input format, transformation description, and output format. | P1 | US1, IEEE 42010: Data Flow View feeds Data Flow Testing at the integration level. | Inspection |
| REQ-007 | Each `ARCH-NNN` element SHALL trace strictly to one or more `REQ-NNN` identifiers from `requirements.md`. Path B ARCH elements do NOT reference `SYS-NNN` parents — even if `system-design.md` exists in the same v-model directory. | P1 | Clarification Q4: Path B is independent of system-design.md; combined scope is achieved by reading requirements directly. | Test |
| REQ-008 | The command SHALL detect the `domain` field from `v-model-config.yml` at the repository root. When `domain: iso_26262`, the command SHALL load the domain overlay from `commands/overlays/iso_26262/software-architecture-design.md` and include ASPICE SWE.2 BP1–BP9 process guidance in the output. | P1 | US2, clarification Q1/Q2: SWE.2 is automotive-specific and delivered via overlay. | Test |
| REQ-009 | When `domain` is set to `do_178c` or `iec_62304`, the command SHALL attempt to load the corresponding overlay file. Since these overlays are stubs in this feature, the base IEEE 42010 views SHALL still be generated; no SWE.2 sections SHALL appear. | P1 | Clarification Q2: Overlay files exist for all three domains; SWE.2 is only in the iso_26262 overlay. | Test |
| REQ-010 | When `v-model-config.yml` is absent or `domain` is empty/unset, the command SHALL produce industry-neutral output with IEEE 42010 views only and no domain-specific sections. | P1 | Clarification Q1: SWE.2 must not leak into non-automotive outputs. | Inspection |
| REQ-011 | When generating the SWE.2 section (iso_26262 only), the output SHALL include explicit structure for all nine base practices: BP1 (develop architectural design), BP2 (allocate requirements), BP3 (define interfaces), BP4 (describe dynamic behavior), BP5 (define resource consumption objectives), BP6 (evaluate alternatives), BP7 (establish bidirectional traceability), BP8 (ensure consistency), BP9 (communicate agreed design). | P1 | US2, FR-006: Complete SWE.2 coverage is required for ISO 26262 audit readiness. | Inspection |
| REQ-012 | When `architecture-design.md` (Path A artifact) already exists in the v-model directory, the command SHALL emit a warning message and proceed with generating `software-architecture-design.md`; both artifacts coexist without error. | P1 | Clarification Q3, FR-008: Coexistence with warning preserves user choice; integration-test has documented preference. | Test |
| REQ-013 | The command SHALL follow the strict translator constraint: when deriving `ARCH-NNN` elements from `requirements.md`, the AI SHALL NOT invent, infer, or add architecture elements for capabilities not present in the requirements. | P1 | Constitution P5: Prevents AI hallucination of architecture features not grounded in requirements. | Test |
| REQ-014 | When the architecture design identifies a necessary technical element that has no corresponding `REQ-NNN`, the command SHALL flag it as `[DERIVED MODULE: reason]` rather than silently creating an `ARCH-NNN`, prompting the user to update `requirements.md`. | P1 | FR traceability: Derived modules must flow back up the V-Model for proper requirement traceability. | Test |
| REQ-015 | Similarly, when a capability implied by the architecture is not expressed in requirements, the command SHALL flag it as `[DERIVED REQUIREMENT: reason]` rather than silently creating a component. | P1 | FR traceability: Derived requirements must be documented for human review before downstream use. | Test |
| REQ-016 | The command SHALL include a **Traceability Summary** section with a REQ → ARCH mapping table and forward coverage metrics (total requirements, total architecture elements, coverage percentage). | P1 | SC-003: Coverage metrics prove every requirement is addressed by architecture. | Inspection |
| REQ-017 | The `setup-v-model.sh` and `setup-v-model.ps1` scripts SHALL be adapted to include a `--require-reqs` flag (already in command spec) that verifies `requirements.md` exists before the software-architecture-design command proceeds. | P1 | Command execution step: The command depends on requirements.md as sole input. | Test |
| REQ-018 | The setup scripts SHALL detect and return `software-architecture-design.md` in the `AVAILABLE_DOCS` list for downstream commands (e.g., `integration-test`) to consume. | P1 | Downstream compatibility: integration-test needs to know software-architecture-design.md exists. | Test |
| REQ-019 | The command SHALL handle existing `ARCH-NNN` identifiers with lifecycle rules: never renumber existing IDs, mark replaced modules as `[DEPRECATED — Superseded by ARCH-NNN]`, mark removed modules as `[DEPRECATED — Withdrawn: reason]`, and preserve deprecated modules in output. | P2 | Lifecycle integrity: Existing traceability links must not be broken by regeneration. | Test |
| REQ-020 | The command SHALL fail gracefully with a clear error message when `requirements.md` is missing, empty, or contains zero `REQ-NNN` identifiers. | P1 | Edge case: Empty input must not produce malformed output. | Test |
| REQ-021 | The command SHALL support many-to-many REQ↔ARCH relationships: a single `REQ-NNN` MAY map to multiple `ARCH-NNN` elements, and a single `ARCH-NNN` element MAY satisfy multiple `REQ-NNN` identifiers. | P1 | Real systems have cross-cutting requirements that span multiple architecture elements. | Test |
| REQ-022 | `ARCH-NNN` elements that represent infrastructure or utility concerns (e.g., logging, error handling, configuration) SHALL be tagged as `[CROSS-CUTTING]` with a rationale explaining why the element is system-wide. Cross-cutting elements still require at least one parent `REQ-NNN`. | P1 | Cross-cutting elements are architecturally necessary and must remain traceable. | Inspection |
| REQ-023 | The Logical View SHALL clearly distinguish business-logic elements (with explicit REQ parents) from cross-cutting elements (with the `[CROSS-CUTTING]` tag and rationale). | P1 | Auditors need to distinguish domain logic from infrastructure at a glance. | Inspection |
| REQ-024 | The command SHALL include a `templates/software-architecture-design-template.md` defining the required output structure with section headers for all four IEEE 42010 views and conditional SWE.2 section placeholders (populated only when domain overlay is loaded). | P1 | Templates enforce consistent output structure across all AI-generated artifacts. | Inspection |

### Non-Functional Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-NF-001 | The command SHALL complete generation of `software-architecture-design.md` in under 30 seconds for requirements files up to 10,000 words. | P1 | SC-001: Performance target ensures usability in interactive workflows. | Test |
| REQ-NF-002 | All four IEEE 42010 views (Logical, Process, Interface, Data Flow) SHALL be populated with non-empty, non-placeholder content in every generated output. | P1 | SC-002a: Domain-agnostic quality gate ensures no view is left as boilerplate. | Inspection |
| REQ-NF-003 | The command SHALL handle requirements files with 50 or more `REQ-NNN` identifiers without truncation, data loss, or degraded output quality. | P2 | Large-scale projects (automotive, aerospace) may have dozens of requirements. | Test |
| REQ-NF-004 | The SWE.2 compliance score (when `domain: iso_26262`) SHALL be 90% or higher when evaluated against SWE.2 BP1–BP9 criteria. | P1 | SC-004: Automotive audits require demonstrable SWE.2 compliance. | Test |
