# Feature Specification: System Design ↔ System Testing

**Feature Branch**: `002-system-design-testing`  
**Created**: 2026-02-20  
**Status**: Draft  
**Input**: Extend the V-Model Extension Pack down one level — from Requirements ↔ Acceptance Testing (v0.1.0) to System Design ↔ System Testing (v0.2.0). The system design command generates an IEEE 1016-compliant Software Design Description organized into mandatory design views (Decomposition, Dependency, Interface, Data). The system test command generates an ISO/IEC/IEEE 29119-compliant test plan targeting the architectural views with rigorous techniques (Interface Contract Testing, Boundary Value Analysis, Fault Injection). Safety-critical additions (Freedom from Interference, MC/DC Coverage, WCET Analysis) are included as optional sections activated by domain configuration.

## Governing Standards

This feature is guided by the following international standards:

- **IEEE 1016-2009** — Standard for Information Technology—Systems Design—Software Design Descriptions. Defines the mandatory design views (Decomposition, Dependency, Interface, Data) that an auditor expects in a compliant SDD.
- **ISO/IEC/IEEE 29119** — Software Testing standard. Defines the test techniques (Boundary Value Analysis, Equivalence Partitioning, Fault Injection) that system-level test plans must employ.
- **ISO 26262** — Automotive functional safety. Adds Freedom from Interference (FFI) analysis and restricted complexity rules for ASIL-rated components.
- **DO-178C** — Airborne software certification. Adds MC/DC (Modified Condition/Decision Coverage) structural coverage requirements for DAL A/B software.
- **IEC 62304** — Medical device software lifecycle. Requires traceability from software architecture to risk controls.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Generate IEEE 1016-Compliant System Design (Priority: P1)

A safety engineer working on a patient vital signs monitor has 12 traceable requirements (`REQ-001` through `REQ-012`) in `requirements.md`. She runs `/speckit.v-model.system-design` to decompose these requirements into an IEEE 1016-structured Software Design Description. The output is `system-design.md` with `SYS-NNN` identifiers organized into four mandatory design views:

1. **Decomposition View**: Major subsystems and components (e.g., "Sensor Data Acquisition", "Alert Engine", "Display Renderer"), each tracing to parent `REQ-NNN` IDs.
2. **Dependency View**: Inter-component relationships showing which subsystems depend on which, and the failure propagation paths.
3. **Interface View**: Strict API contracts, data formats, protocols, and hardware-software boundaries for each component's inputs and outputs.
4. **Data Design View**: How data is structured, stored, and protected at rest and in transit.

Every requirement is covered by at least one system component, and every component traces back to at least one requirement (many-to-many mapping supported).

**Why this priority**: System design decomposition is the foundational artifact of this V-level. Without it, system tests cannot be generated, the traceability matrix cannot be extended, and no downstream work can proceed. Structuring it into IEEE 1016 views prevents the AI from generating generic "fluff" and forces it to act like a senior systems architect.

**Independent Test**: Can be fully tested by running the command on any existing `requirements.md` and verifying: (1) every `REQ-NNN` is referenced by at least one `SYS-NNN`, (2) the output contains all four mandatory design views, (3) `validate-system-coverage.sh` confirms 100% REQ→SYS forward coverage.

**Acceptance Scenarios**:

1. **Given** a `requirements.md` with 12 requirements (`REQ-001` through `REQ-012`), **When** the user runs `/speckit.v-model.system-design`, **Then** the system produces `system-design.md` with `SYS-NNN` components organized into Decomposition, Dependency, Interface, and Data Design views, with every requirement covered.
2. **Given** a `requirements.md` with functional and non-functional requirements, **When** the user runs `/speckit.v-model.system-design`, **Then** non-functional requirements (performance, security, reliability) are addressed as cross-cutting quality attributes with explicit design decisions in the relevant views.
3. **Given** a complex domain where one requirement spans multiple subsystems, **When** the system design is generated, **Then** the requirement is listed as a parent of multiple `SYS-NNN` components, and the Dependency View shows the interaction between those components.
4. **Given** a project configured for automotive (ISO 26262), **When** the system design is generated, **Then** the output includes an additional **Freedom from Interference** section documenting isolation mechanisms (memory partitioning, time-slicing) between components of different ASIL ratings, and a **Restricted Complexity** section flagging any unsafe constructs.

---

### User Story 2 - Generate ISO 29119-Compliant System Test Plan (Priority: P1)

After generating the system design, the engineer runs `/speckit.v-model.system-test` to produce a three-tier system test plan: test cases (`STP-NNN-X`) and test scenarios (`STS-NNN-X#`) for every system component. Unlike acceptance tests (which verify user needs), system tests verify that the architecture doesn't collapse — they specifically target the IEEE 1016 design views using ISO 29119 techniques:

1. **Interface Contract Testing**: Every interface defined in the Interface View gets paired tests. The command MUST distinguish between **external system interfaces** (APIs exposed to users or external systems) and **internal component interfaces** (inter-module communication, e.g., Data Acquisition module talking to Display module). ISO 29119 handles both, but auditors expect the distinction to be explicit. External interface tests focus on protocol compliance and input validation; internal interface tests focus on contract adherence and failure propagation.
2. **Boundary Value Analysis & Equivalence Partitioning**: Tests target the absolute edges of data limits (e.g., sensor maximum rated threshold, one degree below, one degree above).
3. **Fault Injection (Negative Testing)**: The test plan explicitly dictates how to break the system — database locks, sensor disconnection mid-read, network partition.

The command runs `validate-system-coverage.sh` and reports 100% SYS→STP bidirectional coverage.

**Why this priority**: This is the right side of the V, paired with the system design. The V-Model principle (Constitution P1) requires that every development artifact has a simultaneously generated testing artifact. Anchoring test techniques to ISO 29119 prevents the AI from generating weak "verify it works" tests and forces it to produce rigorous, auditor-grade scenarios.

**Independent Test**: Can be tested by running the command on a valid `system-design.md` and verifying: (1) every `SYS-NNN` has at least one `STP-NNN-X`, (2) test cases reference specific design views and apply named techniques (Interface Contract, Boundary Value, Fault Injection), (3) `validate-system-coverage.sh` reports 100% coverage, (4) ID lineage encoding is correct (`STS-001-A1` → `STP-001-A` → `SYS-001`).

**Acceptance Scenarios**:

1. **Given** a `system-design.md` with 5 system components (`SYS-001` through `SYS-005`), **When** the user runs `/speckit.v-model.system-test`, **Then** the system produces `system-test.md` with at least one `STP-NNN-X` per component and at least one `STS-NNN-X#` per test case, with test techniques explicitly named.
2. **Given** a system component with multiple interfaces defined in the Interface View, **When** the system test plan is generated, **Then** separate test cases cover each interface with contract tests (valid input, malformed input, timeout, connection drop).
3. **Given** a system component linked to a safety-critical requirement, **When** the system test plan is generated, **Then** test cases include nominal behavior, boundary values, and fault injection scenarios.
4. **Given** a project configured for aerospace (DO-178C DAL A), **When** the system test plan is generated, **Then** the output includes an additional **Structural Coverage** section specifying MC/DC coverage targets and a **Resource Usage Testing** section for WCET, maximum stack depth, and heap usage verification.

---

### User Story 3 - Validate System-Level Bidirectional Coverage (Priority: P1)

The engineer runs `validate-system-coverage.sh` to deterministically verify two coverage dimensions: (1) forward coverage — every `REQ-NNN` is decomposed into at least one `SYS-NNN`, and (2) backward coverage — every `SYS-NNN` has at least one `STP-NNN-X` test case. The script also detects orphaned components (SYS with no parent REQ) and orphaned test cases (STP with no parent SYS). The script exits with a non-zero status code if any gap is found, enabling CI hard-fail enforcement (Constitution P2).

**Why this priority**: Deterministic verification is a non-negotiable constitutional principle. Without this script, coverage claims rely on AI self-assessment, which violates Constitution P2. The script is also a dependency of the system test command (which calls it as a coverage gate).

**Independent Test**: Can be tested with fixture files: a minimal valid set (100% coverage), a set with a missing SYS mapping (gap detected), a set with an orphaned STP (orphan detected), and verifying correct exit codes and output messages for each.

**Acceptance Scenarios**:

1. **Given** `requirements.md`, `system-design.md`, and `system-test.md` with 100% bidirectional coverage, **When** `validate-system-coverage.sh` runs, **Then** it exits with code 0 and prints a coverage summary.
2. **Given** a `system-design.md` where `REQ-003` has no corresponding `SYS-NNN`, **When** `validate-system-coverage.sh` runs, **Then** it exits with code 1 and reports "REQ-003: no system component mapping found."
3. **Given** a `system-test.md` with `STP-099-A` that references a non-existent `SYS-099`, **When** `validate-system-coverage.sh` runs, **Then** it exits with code 1 and reports "STP-099-A: orphaned test case — parent SYS-099 not found in system-design.md."

---

### User Story 4 - Extended Traceability Matrix with System Layer (Priority: P2)

After both acceptance and system testing artifacts exist, the engineer runs the updated `/speckit.v-model.trace` command. Rather than creating a single wide table (which becomes unreadable in Markdown), the extended traceability matrix produces **two complementary matrices**:

- **Matrix A — Validation (User View)**: `REQ → ATP → SCN` — proves the system does what the user needs.
- **Matrix B — Verification (Architectural View)**: `REQ → SYS → STP → STS` — proves the architecture works as designed.

Each matrix includes its own coverage percentage. Together, they prove that every requirement is both decomposed into system components AND verified at both the acceptance and system test levels.

**Why this priority**: The traceability matrix is the key audit artifact for regulated industries, but it requires both the system design and system test commands to exist first. It extends the existing trace command rather than creating a new one.

**Independent Test**: Can be tested by running the updated trace command on a feature directory that has `requirements.md`, `acceptance-plan.md`, `system-design.md`, and `system-test.md`, then verifying: (1) the matrix includes the SYS and STP columns, (2) the system coverage percentage is calculated correctly, (3) the matrix is compatible with the existing acceptance-level format.

**Acceptance Scenarios**:

1. **Given** a feature directory with all four artifacts (requirements, acceptance plan, system design, system test), **When** `/speckit.v-model.trace` runs, **Then** the output includes Matrix A (REQ → ATP → SCN) and Matrix B (REQ → SYS → STP → STS), each with correct linkages and independent coverage percentages.
2. **Given** a feature directory with only requirements and acceptance plan (no system-level artifacts), **When** `/speckit.v-model.trace` runs, **Then** only Matrix A is generated (backward compatible with v0.1.0 — no Matrix B, no warning).
3. **Given** a many-to-many REQ↔SYS mapping, **When** Matrix B is generated, **Then** each REQ row lists all linked SYS components, and the matrix correctly counts coverage without double-counting.

---

### User Story 5 - PowerShell Parity for System Coverage Validation (Priority: P3)

A Windows-based automotive ADAS team runs `validate-system-coverage.ps1` to get the same deterministic coverage validation available on Unix/macOS via the Bash script. The PowerShell script produces identical output format, identical exit codes, and passes the same test fixtures.

**Why this priority**: Cross-platform parity is important for enterprise adoption but is not a functional blocker. The Bash script delivers the core capability; PowerShell follows as a port.

**Independent Test**: Can be tested by running both the Bash and PowerShell scripts on the same fixture files and verifying identical output and exit codes.

**Acceptance Scenarios**:

1. **Given** a valid set of system artifacts, **When** `validate-system-coverage.ps1` runs, **Then** it produces the same coverage summary and exit code as `validate-system-coverage.sh` on the same inputs.
2. **Given** a set with coverage gaps, **When** `validate-system-coverage.ps1` runs, **Then** it reports the same gap messages and exits with code 1.

---

### Edge Cases

- **What happens when `requirements.md` is empty or has zero REQ-NNN identifiers?** The system design command should fail gracefully with a clear error message ("No requirements found in requirements.md — cannot generate system design").
- **What happens when a REQ-NNN maps to only non-functional requirements (e.g., performance, security)?** The system design should create cross-cutting or quality-attribute components in the relevant design views, not skip them.
- **How does the system handle circular dependencies in the Dependency View (e.g., SYS-001 depends on SYS-002 which depends on SYS-001)?** The validation script should detect and report cycles without hanging.
- **What happens when `system-design.md` exists but `system-test.md` does not?** The trace command should include the SYS column but leave the STP column empty with a warning ("System test plan not yet generated").
- **What happens when `validate-system-coverage.sh` is invoked before `system-test.md` exists?** The script should validate forward coverage (`REQ→SYS`) only and gracefully skip backward coverage checks (`SYS→STP→STS`), exiting with code 0 if forward coverage is complete. The output should clearly indicate partial validation mode.
- **What happens when the ID numbering in `system-design.md` has gaps (e.g., SYS-001, SYS-003, skipping SYS-002)?** The system should accept gaps in numbering without error — gaps are valid when components are deleted or reorganized.
- **How does the system handle a requirements.md with hundreds of requirements (e.g., 200+ REQ-NNN)?** The commands should handle large inputs without truncation or performance issues, processing in batches if necessary.
- **What happens when safety-critical sections (FFI, MC/DC) are requested but the project is not configured for a regulated domain?** The sections should be omitted by default and only included when the domain configuration enables them.
- **What happens when the AI identifies a necessary technical capability not in requirements.md (a Derived Requirement)?** The command must flag it as `[DERIVED REQUIREMENT: description]` rather than silently creating a SYS-NNN component, prompting the user to update requirements.md and re-run (FR-019).

## Requirements *(mandatory)*

### Functional Requirements

**System Design Command:**

- **FR-001**: The extension MUST provide a `/speckit.v-model.system-design` command that reads `requirements.md` and produces `system-design.md` with `SYS-NNN` identifiers organized into IEEE 1016 design views.
- **FR-002**: The system design output MUST include four mandatory views: Decomposition View (subsystems and components), Dependency View (inter-component relationships and failure propagation), Interface View (API contracts, data formats, protocols, HW/SW boundaries), and Data Design View (data structures, storage, protection).
- **FR-003**: Each `SYS-NNN` component MUST trace to one or more `REQ-NNN` identifiers via an explicit "Parent Requirements" field.
- **FR-004**: The system design command MUST support many-to-many REQ↔SYS relationships — a single requirement MAY map to multiple components, and a single component MAY satisfy multiple requirements.
- **FR-005**: When the project is configured for a safety-critical domain (ISO 26262, DO-178C, IEC 62304), the system design output MUST include additional sections: Freedom from Interference analysis (isolation mechanisms between criticality levels) and Restricted Complexity assessment (flagging unsafe constructs such as unbounded recursion, dynamic memory allocation, unconditional jumps).

**System Test Command:**

- **FR-006**: The extension MUST provide a `/speckit.v-model.system-test` command that reads `system-design.md` and produces `system-test.md` with `STP-NNN-X` test cases and `STS-NNN-X#` test scenarios.
- **FR-007**: System test cases MUST reference specific IEEE 1016 design views and apply named ISO 29119 techniques: Interface Contract Testing (targeting the Interface View), Boundary Value Analysis & Equivalence Partitioning (targeting data limits), and Fault Injection / Negative Testing (targeting the Dependency View).
- **FR-008**: When the project is configured for a safety-critical domain, the system test output MUST include additional sections: Structural Coverage targets (MC/DC for DO-178C DAL A/B) and Resource Usage Testing (WCET, stack depth, heap usage).
- **FR-009**: The system test command MUST invoke `validate-system-coverage.sh` as a coverage gate after generation, reporting the result in its output.

**ID Schema:**

- **FR-010**: The ID lineage encoding MUST be consistent: `STS-001-A1` → `STP-001-A` → `SYS-001` → `REQ-001`, allowing any ID to be traced to its full ancestry by parsing the identifier alone.

**Validation Scripts:**

- **FR-011**: The extension MUST provide `validate-system-coverage.sh` (Bash) that deterministically validates: (a) every `REQ-NNN` has ≥1 `SYS-NNN` mapping (forward), (b) every `SYS-NNN` has ≥1 `STP-NNN-X` test case (backward), (c) no orphaned SYS or STP identifiers exist.
- **FR-012**: The validation script MUST exit with code 0 on full coverage and code 1 on any gap, with human-readable gap reports suitable for CI logs.
- **FR-013**: The extension MUST provide `validate-system-coverage.ps1` (PowerShell) with identical behavior, output format, and exit codes as the Bash script.
- **FR-020** *(v0.2.1 patch)*: The `validate-system-coverage.sh` and `validate-system-coverage.ps1` scripts MUST support **partial validation**: when `system-test.md` is absent, the scripts SHALL validate forward coverage (`REQ→SYS`) only and gracefully bypass `SYS→STP→STS` backward coverage checks, exiting with code 0 if forward coverage is complete. This enables running the validation script after generating `system-design.md` but before generating `system-test.md`.

**Traceability & Matrix:**

- **FR-014**: The `/speckit.v-model.trace` command MUST be extended to produce two complementary matrices when system-level artifacts exist: **Matrix A (Validation)** — `REQ → ATP → SCN` and **Matrix B (Verification)** — `REQ → SYS → STP → STS`, each with independent coverage percentages.
- **FR-015**: The extended traceability matrix MUST remain backward compatible — when system-level artifacts are absent, the matrix MUST produce the same v0.1.0 output (REQ → ATP → SCN only).
- **FR-016**: The `build-matrix.sh` and `build-matrix.ps1` scripts MUST be extended to parse `system-design.md` and `system-test.md` for the extended matrix.

**Templates & Constraints:**

- **FR-017**: All new templates (`system-design-template.md`, `system-test-template.md`) MUST be created in the extension's `templates/` directory and referenced by the corresponding commands.
- **FR-018**: All new commands MUST follow the strict translator constraint — when deriving from existing artifacts, the AI MUST NOT invent, infer, or add features not present in the input.
- **FR-019**: When the system design process identifies a necessary technical capability not present in `requirements.md` (a **Derived Requirement** per DO-178C/ISO 26262 terminology), the command MUST NOT silently add it as a `SYS-NNN` component. Instead, it MUST flag it as `[DERIVED REQUIREMENT: description]` in the output, prompting the user to decide whether to add a new `REQ-NNN` in `requirements.md` and re-run the decomposition. This ensures derived requirements flow back up the V-Model for proper traceability.

### Key Entities

- **System Component (SYS-NNN)**: A discrete subsystem or module decomposed from one or more requirements, documented across four IEEE 1016 design views. Key attributes: ID, Name, Description, Parent Requirements (list of REQ-NNN), Interfaces (inputs/outputs with contracts), Dependencies (other SYS-NNN components), Data Structures. Relationship: many-to-many with Requirements; one-to-many with System Test Cases.
- **System Test Case (STP-NNN-X)**: A logical validation condition for a system component, anchored to a specific design view and ISO 29119 test technique. Key attributes: ID, Parent System Component (SYS-NNN), Description, Target Design View, Test Technique (Interface Contract / Boundary Value / Fault Injection), Validation Condition. Relationship: many-to-one with System Components; one-to-many with System Test Scenarios.
- **System Test Scenario (STS-NNN-X#)**: A concrete, executable test scenario in Given/When/Then format nested under a system test case. Unlike `SCN-` acceptance scenarios (which use user-centric language), `STS-` scenarios use **technical language** appropriate for system/integration testing (e.g., "Given the database connection pool is exhausted, When a new query is submitted, Then the system returns error code 503 within 200ms"). The BDD structure (Setup, Action, Assertion) is required for clarity, but the vocabulary is component-oriented, not user-oriented. Key attributes: ID, Parent Test Case (STP-NNN-X), Given/When/Then steps, Test Data, Expected Behavior. Relationship: many-to-one with System Test Cases.
- **Extended Traceability Matrix**: The audit artifact split into two complementary matrices to prevent visual bloat: Matrix A (Validation — REQ → ATP → SCN, user view) and Matrix B (Verification — REQ → SYS → STP → STS, architectural view). Key attributes per matrix: Requirement ID, linked artifacts per layer, Coverage Status, Coverage Percentage. The split mirrors how enterprise ALM tools present validation vs. verification traceability.
- **System Coverage Report**: The output of `validate-system-coverage.sh` — a summary of forward coverage (REQ→SYS), backward coverage (SYS→STP), orphan detection, and overall pass/fail status with exit codes suitable for CI enforcement.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Running `/speckit.v-model.system-design` on any valid `requirements.md` produces a `system-design.md` containing all four IEEE 1016 design views (Decomposition, Dependency, Interface, Data) where `validate-system-coverage.sh` confirms 100% REQ→SYS forward coverage.
- **SC-002**: Running `/speckit.v-model.system-test` on any valid `system-design.md` produces a `system-test.md` where: (a) `validate-system-coverage.sh` confirms 100% SYS→STP backward coverage with zero orphans, and (b) every test case explicitly references a named ISO 29119 technique.
- **SC-003**: The ID lineage encoding is machine-parseable — given any `STS-NNN-X#` ID, a regex can extract the parent `STP-NNN-X`, grandparent `SYS-NNN`, and great-grandparent `REQ-NNN` without consulting any lookup table.
- **SC-004**: The extended traceability output includes two matrices (Validation: REQ→ATP→SCN, Verification: REQ→SYS→STP→STS) with independent coverage percentages that match the deterministic script outputs.
- **SC-005**: All BATS tests for `validate-system-coverage.sh` pass with 100% fixture coverage (valid, gap, orphan, empty, large-input scenarios).
- **SC-006**: All Pester tests for `validate-system-coverage.ps1` pass with identical results as the BATS tests on the same fixture data.
- **SC-007**: (Internal QA gate) The extension's CI evaluation suite — which uses LLM-as-judge scoring via DeepEval/GEval — confirms that the new system design and system test commands produce outputs matching or exceeding the quality thresholds established for v0.1.0 artifacts (IEEE 1016 view completeness, ISO 29119 technique usage). This criterion is verified by extension developers in CI; end users do not interact with the evaluation framework.
- **SC-008**: The extension's `extension.yml` registers 5 commands (3 existing + 2 new) and 1 hook, and the version is bumped to `0.2.0`.
- **SC-009**: Backward compatibility verified — running any v0.1.0 command on existing artifacts produces identical output before and after the v0.2.0 update.

### Assumptions

- Users already have a valid `requirements.md` generated by `/speckit.v-model.requirements` (v0.1.0). The system design command does not generate requirements — it decomposes them.
- The many-to-many REQ↔SYS relationship is documented in the system design template, not inferred at runtime. Each `SYS-NNN` entry explicitly lists its parent `REQ-NNN` IDs.
- The `validate-system-coverage.sh` script uses regex-based parsing (consistent with `validate-requirement-coverage.sh` from v0.1.0) — it does not require a runtime database or external tooling.
- Backward compatibility with v0.1.0 artifacts is mandatory — existing `requirements.md`, `acceptance-plan.md`, and `traceability-matrix.md` files MUST NOT be modified by any v0.2.0 command.
- Safety-critical sections (FFI, Restricted Complexity, MC/DC, WCET) are optional and activated by domain configuration in `v-model-config.yml`. Projects not targeting regulated domains get the four mandatory IEEE 1016 views without the safety additions.
