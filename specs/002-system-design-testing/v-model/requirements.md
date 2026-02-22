# V-Model Requirements Specification: System Design ↔ System Testing

**Feature Branch**: `002-system-design-testing`  
**Created**: 2026-02-20  
**Status**: Draft  
**Source**: `specs/002-system-design-testing/spec.md`

## Overview

This document formalizes the requirements for extending the V-Model Extension Pack from Requirements ↔ Acceptance Testing (v0.1.0) down to System Design ↔ System Testing (v0.2.0). The extension adds two new commands (`/speckit.v-model.system-design` and `/speckit.v-model.system-test`), a deterministic validation script, extended traceability matrix support, and corresponding templates. All requirements are atomized from the feature specification using the strict translator constraint.

## Requirements

### Functional Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-001 | The extension SHALL provide a `/speckit.v-model.system-design` command that reads `requirements.md` as input and produces `system-design.md` as output. | P1 | US1: System design is the foundational artifact of this V-level; without it, no downstream work can proceed. | Test |
| REQ-002 | The `/speckit.v-model.system-design` command SHALL assign each system component a unique `SYS-NNN` identifier (e.g., `SYS-001`, `SYS-002`), sequentially numbered and never renumbered once assigned. | P1 | US1: Traceable identifiers are required for deterministic coverage validation and traceability matrix generation. | Inspection |
| REQ-003 | The `system-design.md` output SHALL include a **Decomposition View** listing all major subsystems and components, with each component's name, description, and list of parent `REQ-NNN` identifiers. | P1 | US1, IEEE 1016: The Decomposition View proves the system is modular and every component traces to a requirement. | Inspection |
| REQ-004 | The `system-design.md` output SHALL include a **Dependency View** documenting inter-component relationships and failure propagation paths between `SYS-NNN` components. | P1 | US1, IEEE 1016: The Dependency View shows how subsystem failures cascade, which is critical for safety analysis. | Inspection |
| REQ-005 | The `system-design.md` output SHALL include an **Interface View** documenting API contracts, data formats, communication protocols, and hardware-software boundaries for each component's inputs and outputs. | P1 | US1, IEEE 1016: The Interface View defines strict contracts that system tests will verify. | Inspection |
| REQ-006 | The `system-design.md` output SHALL include a **Data Design View** documenting data structures, storage mechanisms, and data protection measures (at rest and in transit). | P1 | US1, IEEE 1016: The Data Design View ensures data integrity and security requirements are architecturally addressed. | Inspection |
| REQ-007 | Each `SYS-NNN` component SHALL trace to one or more `REQ-NNN` identifiers via an explicit "Parent Requirements" field in the Decomposition View. | P1 | US1: Forward traceability from requirements to system components is required for deterministic coverage validation. | Test |
| REQ-008 | The system design command SHALL support many-to-many REQ↔SYS relationships: a single `REQ-NNN` MAY map to multiple `SYS-NNN` components, and a single `SYS-NNN` component MAY satisfy multiple `REQ-NNN` identifiers. | P1 | US1, Scenario 3: Real systems have cross-cutting requirements (e.g., security) that span multiple subsystems. | Test |
| REQ-009 | Non-functional requirements (performance, security, reliability) SHALL be addressed as cross-cutting quality attributes with explicit design decisions documented in the relevant IEEE 1016 views, not omitted. | P1 | US1, Scenario 2: Non-functional requirements affect architecture and must not be silently skipped. | Inspection |
| REQ-010 | The extension SHALL provide a `/speckit.v-model.system-test` command that reads `system-design.md` as input and produces `system-test.md` as output. | P1 | US2: System testing is the right side of the V, paired with system design (Constitution P1). | Test |
| REQ-011 | The `/speckit.v-model.system-test` command SHALL assign test case identifiers using the format `STP-NNN-X` (e.g., `STP-001-A`) where NNN matches the parent `SYS-NNN` and X is a sequential letter. | P1 | US2: ID lineage encoding enables deterministic ancestry tracing from any test case to its parent component. | Test |
| REQ-012 | The `/speckit.v-model.system-test` command SHALL assign test scenario identifiers using the format `STS-NNN-X#` (e.g., `STS-001-A1`) where NNN-X matches the parent `STP-NNN-X` and # is a sequential number. | P1 | US2: Three-tier ID schema (SYS → STP → STS) mirrors the acceptance tier (REQ → ATP → SCN). | Test |
| REQ-013 | Each system test case (`STP-NNN-X`) SHALL reference the specific IEEE 1016 design view it targets (Decomposition, Dependency, Interface, or Data Design). | P1 | US2, ISO 29119: Anchoring tests to design views prevents generic "verify it works" tests. | Inspection |
| REQ-014 | Each system test case (`STP-NNN-X`) SHALL apply a named ISO 29119 test technique: Interface Contract Testing (targeting Interface View), Boundary Value Analysis / Equivalence Partitioning (targeting data limits), or Fault Injection / Negative Testing (targeting Dependency View). | P1 | US2, ISO 29119: Named techniques force rigorous, auditor-grade test design. | Inspection |
| REQ-015 | Interface Contract test cases SHALL explicitly distinguish between **external system interfaces** (APIs exposed to users or external systems) and **internal component interfaces** (inter-module communication). | P1 | US2, refinement: ISO 29119 handles both, but auditors expect the distinction to be explicit. External tests focus on protocol compliance; internal tests focus on contract adherence and failure propagation. | Inspection |
| REQ-016 | System test scenarios (`STS-NNN-X#`) SHALL use Given/When/Then BDD structure with **technical, component-oriented language** (e.g., "Given the database connection pool is exhausted, When a new query is submitted, Then the system returns error code 503 within 200ms"), distinct from the user-centric language of acceptance scenarios (`SCN-NNN-X#`). | P1 | US2, STS entity definition: System tests verify architectural behavior, not user journeys. | Inspection |
| REQ-017 | The `/speckit.v-model.system-test` command SHALL invoke `validate-system-coverage.sh` as a post-generation coverage gate and include the validation result (pass/fail with coverage summary) in its output. | P1 | US2, US3: The coverage gate ensures no system component is left untested. | Test |
| REQ-018 | The extension SHALL provide a `validate-system-coverage.sh` Bash script that deterministically validates forward coverage: every `REQ-NNN` in `requirements.md` has at least one corresponding `SYS-NNN` in `system-design.md`. | P1 | US3: Deterministic verification (Constitution P2) requires script-based, not AI-based, coverage validation. | Test |
| REQ-019 | The `validate-system-coverage.sh` script SHALL deterministically validate backward coverage: every `SYS-NNN` in `system-design.md` has at least one corresponding `STP-NNN-X` in `system-test.md`. | P1 | US3: Backward coverage proves no component was designed without a paired test. | Test |
| REQ-020 | The `validate-system-coverage.sh` script SHALL detect and report orphaned identifiers: any `SYS-NNN` not referenced as a parent in any `REQ-NNN`, and any `STP-NNN-X` whose parent `SYS-NNN` does not exist in `system-design.md`. | P1 | US3, Scenario 3: Orphaned artifacts indicate a broken traceability chain. | Test |
| REQ-021 | The `validate-system-coverage.sh` script SHALL exit with code 0 when all coverage checks pass and code 1 when any gap or orphan is detected. | P1 | US3: Non-zero exit codes enable CI hard-fail enforcement (Constitution P2 quality gate). | Test |
| REQ-022 | The `validate-system-coverage.sh` script SHALL output human-readable gap reports listing each specific gap or orphan by ID (e.g., "REQ-003: no system component mapping found") suitable for CI log inspection. | P1 | US3, Scenario 2-3: Developers must be able to identify and fix specific gaps from the CI output. | Test |
| REQ-023 | The ID lineage encoding SHALL be consistent across all tiers: given any `STS-NNN-X#` identifier, a regex SHALL be able to extract the parent `STP-NNN-X`, grandparent `SYS-NNN`, and great-grandparent `REQ-NNN` without consulting any lookup table or external mapping file. | P1 | SC-003: Machine-parseable lineage is required for deterministic script validation and matrix generation. | Test |
| REQ-024 | The `/speckit.v-model.trace` command SHALL be extended to produce **Matrix B (Verification)** — `REQ → SYS → STP → STS` — when `system-design.md` and `system-test.md` exist in the feature directory. | P2 | US4: The traceability matrix is the key audit artifact for regulated industries. | Test |
| REQ-025 | The `/speckit.v-model.trace` command SHALL produce **Matrix A (Validation)** — `REQ → ATP → SCN` — as a separate table from Matrix B, to prevent visual bloat in Markdown rendering. | P2 | US4, refinement: Enterprise ALM tools present validation and verification traceability separately. | Inspection |
| REQ-026 | The `/speckit.v-model.trace` command SHALL remain backward compatible: when `system-design.md` and `system-test.md` are absent, the command SHALL produce only Matrix A with identical output to v0.1.0. | P2 | US4, Scenario 2, SC-009: Existing v0.1.0 users must not be affected by the v0.2.0 update. | Test |
| REQ-027 | Each matrix SHALL include an independently calculated coverage percentage that matches the output of the corresponding deterministic validation script. | P2 | US4, SC-004: Coverage percentages must be deterministically verified, not AI-estimated. | Test |
| REQ-028 | The `build-matrix.sh` script SHALL be extended to parse `system-design.md` and `system-test.md` to generate Matrix B data. | P2 | US4: The deterministic matrix builder must support the new artifact types. | Test |
| REQ-029 | The `build-matrix.ps1` script SHALL be extended with identical Matrix B generation logic as `build-matrix.sh`. | P3 | US5: Cross-platform parity for deterministic scripts. | Test |
| REQ-030 | The extension SHALL provide a `system-design-template.md` in the `templates/` directory defining the required structure for IEEE 1016-compliant system design output. | P1 | FR-017: Templates enforce consistent output structure across all AI-generated artifacts. | Inspection |
| REQ-031 | The extension SHALL provide a `system-test-template.md` in the `templates/` directory defining the required structure for ISO 29119-compliant system test output with the three-tier STP/STS hierarchy. | P1 | FR-017: Templates enforce consistent output structure. | Inspection |
| REQ-032 | The `/speckit.v-model.system-design` command SHALL follow the strict translator constraint: when deriving from `requirements.md`, the AI SHALL NOT invent, infer, or add system components for capabilities not present in the requirements. | P1 | FR-018, Constitution P5: Prevents AI hallucination of architectural features. | Test |
| REQ-033 | The `/speckit.v-model.system-test` command SHALL follow the strict translator constraint: when deriving from `system-design.md`, the AI SHALL NOT invent test cases for components or interfaces not present in the design. | P1 | FR-018, Constitution P5: Prevents AI hallucination of test scenarios. | Test |
| REQ-034 | When the system design process identifies a necessary technical capability not present in `requirements.md` (a Derived Requirement), the command SHALL flag it as `[DERIVED REQUIREMENT: description]` in the output instead of silently adding a `SYS-NNN` component. | P1 | FR-019, DO-178C/ISO 26262: Derived requirements must flow back up the V-Model for proper traceability. | Test |
| REQ-035 | When the project's `v-model-config.yml` explicitly enables a regulated domain (e.g., `iso_26262`, `do_178c`), the `/speckit.v-model.system-design` command SHALL generate **Freedom from Interference (FFI)** analysis and **Restricted Complexity** assessment sections in `system-design.md` for each `SYS-NNN` component. | P1 | FR-005, ISO 26262/IEC 61508: Safety-critical decomposition requires FFI analysis to prove isolation between components of different ASIL/SIL levels, and restricted complexity to limit cognitive and computational load. | Test |
| REQ-036 | When the project's `v-model-config.yml` explicitly enables a regulated domain (e.g., `do_178c`, `iso_26262`), the `/speckit.v-model.system-test` command SHALL generate **Modified Condition/Decision Coverage (MC/DC)** test obligations and **Worst-Case Execution Time (WCET)** verification scenarios in `system-test.md` for each `STP-NNN-X` test case where applicable. | P1 | FR-008, DO-178C Level A/B: Structural coverage beyond statement and branch coverage is mandatory; WCET verification ensures real-time constraints are met. | Test |
| REQ-037 | *(v0.2.1 patch)* The `validate-system-coverage.sh` script SHALL support **partial validation**: when `system-test.md` is absent, the script SHALL validate forward coverage (`REQ→SYS`) only, gracefully bypass `SYS→STP→STS` backward coverage checks, and exit with code 0 if forward coverage is complete. The output SHALL clearly indicate partial validation mode. | P1 | FR-020, Edge case 9: Enables running the validation script after generating `system-design.md` but before `system-test.md` exists. | Test |

### Non-Functional Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-NF-001 | The `validate-system-coverage.sh` script SHALL use regex-based parsing consistent with `validate-requirement-coverage.sh` from v0.1.0, requiring no runtime database or external tooling beyond standard Bash utilities. | P1 | Assumption 3: Deterministic validation must be self-contained and portable. | Inspection |
| REQ-NF-002 | The `/speckit.v-model.system-design` and `/speckit.v-model.system-test` commands SHALL handle input files with 200 or more `REQ-NNN` identifiers without truncation, data loss, or degraded output quality. | P2 | Edge case 6: Large-scale projects (automotive, aerospace) may have hundreds of requirements. | Test |
| REQ-NF-003 | The `validate-system-coverage.sh` script SHALL accept gaps in `SYS-NNN` numbering (e.g., SYS-001, SYS-003 without SYS-002) without reporting false-positive errors. | P1 | Edge case 5: Gaps are valid when components are deleted or reorganized. | Test |
| REQ-NF-004 | All v0.2.0 commands and scripts SHALL preserve backward compatibility: existing `requirements.md`, `acceptance-plan.md`, and `traceability-matrix.md` files SHALL NOT be modified by any v0.2.0 operation. | P1 | Assumption 4, SC-009: Existing v0.1.0 artifacts must remain untouched. | Test |
| REQ-NF-005 | (Internal QA gate — not user-facing) The extension's CI evaluation suite SHALL validate that `/speckit.v-model.system-design` and `/speckit.v-model.system-test` command outputs meet or exceed the quality thresholds established for v0.1.0 artifacts. End users do not interact with the evaluation framework; this requirement ensures prompt quality through automated regression testing in the development pipeline. | P1 | SC-007: Prevents prompt regression; verified by extension developers via `evals.yml` CI workflow, not by end users. | Test |

### Interface Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-IF-001 | The `/speckit.v-model.system-design` command SHALL read its input exclusively from `{FEATURE_DIR}/v-model/requirements.md` and write its output exclusively to `{FEATURE_DIR}/v-model/system-design.md`. | P1 | Consistent with v0.1.0 file layout conventions (`v-model/` subdirectory). | Inspection |
| REQ-IF-002 | The `/speckit.v-model.system-test` command SHALL read its input exclusively from `{FEATURE_DIR}/v-model/system-design.md` and write its output exclusively to `{FEATURE_DIR}/v-model/system-test.md`. | P1 | Consistent with v0.1.0 file layout conventions. | Inspection |
| REQ-IF-003 | The `validate-system-coverage.sh` script SHALL accept three file paths as arguments: `requirements.md`, `system-design.md`, and `system-test.md`, in that order. | P1 | Consistent with `validate-requirement-coverage.sh` argument convention from v0.1.0. | Test |
| REQ-IF-004 | The `validate-system-coverage.sh` script SHALL output a structured coverage summary to stdout in the same format as `validate-requirement-coverage.sh` (section headers, gap lists, pass/fail verdict, coverage percentages). | P1 | Consistent user experience and CI log parsing across validation scripts. | Test |

### Constraint Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-CN-001 | Safety-critical sections (Freedom from Interference, Restricted Complexity, MC/DC Coverage, WCET Analysis) SHALL be omitted by default and only included when the project's `v-model-config.yml` explicitly enables a regulated domain (ISO 26262, DO-178C, or IEC 62304). | P1 | Assumption 5, Edge case 7: Non-regulated projects should not see safety-critical boilerplate. | Test |
| REQ-CN-002 | The extension version in `extension.yml` SHALL be bumped to `0.2.0` and SHALL register exactly 5 commands (3 existing + 2 new) and 1 hook. | P1 | SC-008: Version and command count must match the release specification. | Inspection |
| REQ-CN-003 | The extension SHALL provide `validate-system-coverage.ps1` (PowerShell) with identical behavior, output format, and exit codes as the Bash script, passing the same test fixture suite. | P3 | US5: Cross-platform parity for enterprise Windows teams. | Test |

## Assumptions

- Users already have a valid `requirements.md` generated by `/speckit.v-model.requirements` (v0.1.0). The system design command does not generate requirements — it decomposes them.
- The many-to-many REQ↔SYS relationship is documented explicitly in the Decomposition View's "Parent Requirements" field, not inferred at runtime.
- The `validate-system-coverage.sh` script uses regex-based parsing consistent with `validate-requirement-coverage.sh` from v0.1.0 — no runtime database or external tooling required.
- Backward compatibility with v0.1.0 artifacts is mandatory — existing files are never modified by v0.2.0 operations.
- Safety-critical sections are optional, activated by domain configuration in `v-model-config.yml`.

## Dependencies

- **Spec Kit ≥ 0.1.0**: Required platform version for extension command registration and agent system.
- **V-Model Extension v0.1.0**: Existing `requirements.md`, `acceptance-plan.md`, `validate-requirement-coverage.sh`, `build-matrix.sh`, and `trace.md` command must be present and functional.
- **Bash ≥ 4.0**: Required for `validate-system-coverage.sh` (regex, associative arrays).
- **PowerShell ≥ 7.0**: Required for `validate-system-coverage.ps1` cross-platform parity.

## Glossary

| Term | Definition |
|------|-----------|
| IEEE 1016 | IEEE Standard for Information Technology—Systems Design—Software Design Descriptions. Defines mandatory design views. |
| ISO 29119 | ISO/IEC/IEEE Software Testing standard. Defines test design techniques (Boundary Value Analysis, Equivalence Partitioning, Fault Injection). |
| Decomposition View | IEEE 1016 view showing how the system is partitioned into subsystems and components. |
| Dependency View | IEEE 1016 view showing inter-component relationships and failure propagation paths. |
| Interface View | IEEE 1016 view defining API contracts, data formats, protocols, and HW/SW boundaries. |
| Data Design View | IEEE 1016 view showing data structures, storage, and protection mechanisms. |
| SYS-NNN | System component identifier (e.g., SYS-001). Maps many-to-many with REQ-NNN. |
| STP-NNN-X | System test case identifier (e.g., STP-001-A). Parent: SYS-NNN. |
| STS-NNN-X# | System test scenario identifier (e.g., STS-001-A1). Parent: STP-NNN-X. BDD format with technical language. |
| Derived Requirement | A technical capability identified during design that was not in the original requirements. Must be flagged, not silently added. |
| FFI | Freedom from Interference — ISO 26262 concept proving isolation between components of different criticality levels. |
| MC/DC | Modified Condition/Decision Coverage — DO-178C structural coverage criterion for high-criticality software. |
| WCET | Worst-Case Execution Time — maximum time a code path can take, used in real-time systems verification. |
| Matrix A (Validation) | Traceability matrix: REQ → ATP → SCN. Proves the system does what the user needs. |
| Matrix B (Verification) | Traceability matrix: REQ → SYS → STP → STS. Proves the architecture works as designed. |

---

**Total Requirements**: 49  
**By Priority**: P1: 41 | P2: 6 | P3: 2  
**By Verification Method**: Test: 31 | Inspection: 17 | Analysis: 0 | Demonstration: 0
