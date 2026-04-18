# V-Model Requirements Specification: 006b — ID Lifecycle Model


**Feature Branch**: `feature/006b-id-lifecycle`
**Created**: 2026-04-18
**Status**: Draft
**Source**: `specs/006b-id-lifecycle/spec.md`

## Overview

This specification formalizes requirements for the ID Lifecycle Model — extending spec-kit-v-model's append-only ID scheme with three new lifecycle states (DEPRECATED, MODIFIED, SUSPECT) that enable proper specification evolution while preserving full traceability. Every generative command gains lifecycle awareness so that when upstream artifacts change, downstream artifacts are systematically flagged for review rather than silently becoming stale.

## Requirements

### Functional Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-001 | Each V-Model artifact ID SHALL support four lifecycle states: ACTIVE (default, no annotation), DEPRECATED (annotated), MODIFIED (content changed in-place, downstream notified), and SUSPECT (parent changed, review needed). | P1 | The spec defines a state diagram with four states (Active, Deprecated, Modified, Suspect) as the core lifecycle model. Without formal states, the system cannot distinguish between current, retired, evolved, and stale artifacts. | Test |
| REQ-002 | The DEPRECATED state SHALL support a Supersession type with the syntax `[DEPRECATED — Superseded by {PREFIX}-NNN]`, indicating the capability continues under a new ID. | P1 | The spec defines two deprecation types with distinct syntax. Supersession is the first type — it tells downstream consumers exactly which new ID to re-parent to, enabling traceable evolution. | Test |
| REQ-003 | The DEPRECATED state SHALL support a Withdrawal type with the syntax `[DEPRECATED — Withdrawn: {reason}]`, indicating the capability is removed entirely with a mandatory justification. | P1 | The spec defines withdrawal as the second deprecation type. A reason is always required so auditors can trace why a capability was removed. | Test |
| REQ-004 | When a parent ID transitions to DEPRECATED, all immediate downstream IDs that trace to it SHALL be marked `[SUSPECT — Parent {ID} deprecated]` by the next command invocation that processes those downstream artifacts. | P1 | The spec defines suspect cascade as a core mechanism: "When a parent ID is deprecated, all immediate downstream IDs that trace to it are automatically marked SUSPECT." This prevents silently stale artifacts. | Test |
| REQ-005 | When a parent ID transitions to MODIFIED (content changed, ID preserved), all immediate downstream IDs that trace to it SHALL be marked `[SUSPECT — Parent {ID} modified]` by the next command invocation that processes those downstream artifacts. | P1 | The spec states: "Modification-in-place — When a requirement's content changes but its intent remains, the ID is preserved and content is updated in-place. Downstream artifacts become SUSPECT." | Test |
| REQ-006 | Each SUSPECT item SHALL be resolved through exactly one of three actions: (a) re-parent to the superseding ID if the capability continues under a new ID, (b) deprecate if the capability is removed, or (c) confirm still valid if the item remains correct despite the parent change. | P1 | The spec defines three resolution paths in the suspect state box and in the Lifecycle Rules section. Each path is distinct and traceable. | Test |
| REQ-007 | IDs SHALL never be deleted from V-Model artifacts — lifecycle transitions SHALL preserve the ID in the artifact text with an inline annotation. | P1 | The spec states: "Never delete an ID — This principle is preserved and strengthened. IDs transition between states but are never removed from artifacts." This is the golden rule of traceability. | Inspection |
| REQ-008 | Each of the 9 ID-bearing generative commands (requirements, acceptance, system-design, system-test, architecture-design, integration-test, module-design, unit-test, hazard-analysis) SHALL include a standardized Lifecycle Rules section. | P1 | The spec provides the exact Lifecycle Rules section text and a table mapping all 10 generative commands (excluding peer-review which is stateless) to their ID prefixes and parent artifacts. | Inspection |
| REQ-009 | The Lifecycle Rules section SHALL be positioned between the existing "Load existing artifact" step and the "Generate new content" step in each command's execution flow. | P2 | The spec states: "inserted between the existing 'Load existing artifact' step and the 'Generate new content' step." This ensures lifecycle processing happens after loading but before generation. | Inspection |
| REQ-010 | Each lifecycle-aware command SHALL perform change detection by: (a) reading the parent artifact, (b) reading its own existing output, (c) comparing parent IDs against traced parent links in the existing output, and (d) classifying each parent ID as unchanged, modified, deprecated, or added. | P1 | The spec section "The Detection Mechanism" defines a 5-step comparison process that generalizes the existing diff-based detection from the acceptance command to all generative commands. | Test |
| REQ-011 | The change detection mechanism SHALL be performed by the LLM as part of the command's instruction flow — it SHALL NOT require a new external script for each command. | P2 | The spec states: "This comparison is performed by the LLM as part of the command's instruction flow — it is a natural extension of the existing 'Load existing artifact' step, not a separate script." | Inspection |
| REQ-012 | The existing `diff-requirements.sh` script used by the acceptance command SHALL continue to serve as a deterministic accelerator alongside the LLM's comparison for the requirements→acceptance transition specifically. | P2 | The spec states: "For the acceptance command specifically, the existing diff-requirements.sh script continues to serve as a deterministic accelerator alongside the LLM's comparison." | Inspection |
| REQ-013 | The `trace` command SHALL exclude DEPRECATED items from coverage metric denominators so that retiring requirements does not reduce coverage percentages. | P1 | The spec states: "Lifecycle-aware tracing — deprecated chains are reported separately... coverage metrics exclude deprecated items from denominators." | Test |
| REQ-014 | The `trace` command SHALL report SUSPECT items in a dedicated summary section, listing each suspect item with its parent change reason. | P1 | The spec states the trace command "gains awareness of lifecycle states: deprecated chains are reported separately, suspect items are flagged for review." | Test |
| REQ-015 | The `trace` command SHALL report deprecated chains separately from active chains, showing the full deprecation lineage. | P2 | The spec states: "deprecated chains are reported separately" — this enables auditors to see the full retirement history in the traceability matrix. | Test |
| REQ-016 | The `impact-analysis` command SHALL use formal lifecycle state syntax (`[DEPRECATED]`, `[MODIFIED]`, `[SUSPECT]`) in its output, replacing informal suspect reporting. | P1 | The spec states: "The impact-analysis command already reports suspects. With formal lifecycle states, its output becomes directly consumable by downstream commands." | Test |
| REQ-017 | The `diff-requirements.sh` script SHALL be extended to detect lifecycle transitions: new deprecations, new suspects, and resolved suspects, in addition to its existing content addition and removal detection. | P2 | The spec states: "The diff-requirements.sh script is extended to detect lifecycle transitions (new deprecations, new suspects, resolved suspects) in addition to content additions and removals." | Test |
| REQ-018 | Lifecycle annotations SHALL be embedded as inline text within the Markdown artifact (e.g., appended to the ID's heading or table row), with no external state file or database. | P1 | The spec states: "States are embedded in the Markdown text itself (as inline annotations). There is no external database or state file. Git is the system of record." | Inspection |
| REQ-019 | The Lifecycle Rules section text SHALL be identical across all 9 commands, with only the ID prefix varying (e.g., REQ for requirements, SYS for system-design, ARCH for architecture-design). | P2 | The spec states: "The section is identical across all commands (with ID prefix variations), creating a consistent, predictable pattern." | Inspection |

### Non-Functional Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-NF-001 | During forward development (building a specification from scratch with no pre-existing IDs), the lifecycle model SHALL produce zero lifecycle annotations — commands SHALL work exactly as they do today (preserve and append). | P1 | The spec UX guarantee: "If you never deprecate or modify an existing ID, you never see a lifecycle annotation. The commands work exactly as they do today." This ensures zero regression for existing users. | Test |
| REQ-NF-002 | Git SHALL be the sole system of record for lifecycle transition history — no embedded changelogs or revision tables within artifacts. | P2 | The spec states: "Full history is available through git log on the artifact file. There is no embedded changelog or revision table within the Markdown artifact." | Inspection |

### Constraint Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-CN-001 | Suspect resolution SHALL NOT be automated — every suspect item SHALL require human review (or the next command invocation with human review) before being resolved. | P1 | The spec states: "An agent should never autonomously decide that a suspect item is still valid for safety-critical artifacts." This is a safety constraint. | Inspection |
| REQ-CN-002 | Multi-level suspect cascade SHALL require separate command invocations per V-Model level — there SHALL be no single-command "cascade through all levels" action. | P1 | The spec states: "each level requires a separate command invocation with human review — there is no single-command 'cascade deprecation through all levels' action." | Inspection |
| REQ-CN-003 | This feature SHALL NOT modify, add, or remove any commands — it SHALL only add content (lifecycle rules sections) to existing command files. | P1 | The spec explicitly scopes the feature to adding lifecycle awareness to existing commands, not creating new commands. The 14 existing commands remain unchanged in count. | Inspection |
| REQ-CN-004 | This feature SHALL NOT include domain overlay architecture, bridge commands, or version history within artifacts — those are separate features (006a, M1, and future scope respectively). | P2 | The spec's "What This Feature Does NOT Include" section explicitly excludes these 4 items from scope. | Inspection |

## Assumptions

- The 9 ID-bearing generative commands are: requirements, acceptance, system-design, system-test, architecture-design, integration-test, module-design, unit-test, and hazard-analysis. The peer-review command is stateless (regenerates each run) and does not need lifecycle rules.
- The ACTIVE state is implicit — an ID without any lifecycle annotation is ACTIVE. Only DEPRECATED, MODIFIED, and SUSPECT require explicit annotations.
- The trace and impact-analysis commands are read-only analysis commands — they consume lifecycle states but do not write them to other artifacts.
- The Lifecycle Rules section is additive — it does not replace any existing command content, only inserts a new section.

## Dependencies

- Git version control is available in the project repository (required for lifecycle transition history and diff-based detection).
- The existing `diff-requirements.sh` script is functional (extended, not replaced, by this feature).
- The existing `impact-analysis.md` command is functional (its output format is formalized, not replaced).

## Glossary

| Term | Definition |
|------|-----------|
| ACTIVE | Default lifecycle state for an ID — currently valid and must be satisfied. No annotation needed. |
| DEPRECATED | Lifecycle state indicating an ID is no longer active. Two types: Supersession (replaced by new ID) and Withdrawal (removed entirely). |
| MODIFIED | Lifecycle state indicating an ID's content has changed while the ID itself is preserved. Triggers SUSPECT on downstream IDs. |
| SUSPECT | Lifecycle state indicating an ID's parent has changed (deprecated or modified) and the ID needs human review to determine if it is still valid, needs updating, or should be deprecated. |
| Supersession | Deprecation type where a capability continues under a new ID. Syntax: `[DEPRECATED — Superseded by {PREFIX}-NNN]`. |
| Withdrawal | Deprecation type where a capability is removed entirely. Syntax: `[DEPRECATED — Withdrawn: {reason}]`. |
| Suspect Cascade | The mechanism by which a parent ID's state change (DEPRECATED or MODIFIED) automatically marks immediate downstream IDs as SUSPECT. |
| Lifecycle Rules Section | A standardized text block added to each generative command that defines the 5 lifecycle rules (never delete, deprecation types, suspect detection, suspect resolution, modified items). |
| Forward Development | Building a specification from scratch with no pre-existing IDs. The lifecycle model is invisible in this mode. |

---

**Total Requirements**: 25 (25 active, 0 deprecated)
**By Priority**: P1: 17 | P2: 8 | P3: 0
**By Verification Method**: Test: 13 | Inspection: 12 | Analysis: 0 | Demonstration: 0
