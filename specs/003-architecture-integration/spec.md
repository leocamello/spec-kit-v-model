# Feature Specification: Architecture Design ↔ Integration Testing

**Feature Branch**: `003-architecture-integration`  
**Created**: 2026-02-21  
**Status**: Draft  
**Input**: Extend the V-Model Extension Pack down one level — from System Design ↔ System Testing (v0.2.0) to Architecture Design ↔ Integration Testing (v0.3.0). The architecture design command decomposes system components into software modules using ISO/IEC/IEEE 42010 and Kruchten's 4+1 View Model (Logical, Process, Interface, Data Flow views). The integration test command generates ISO/IEC/IEEE 29119-4-compliant integration test cases targeting the seams between modules using four mandatory techniques (Interface Contract Testing, Data Flow Testing, Interface Fault Injection, Concurrency & Race Condition Testing). Safety-critical additions (ASIL Decomposition, Defensive Programming, Temporal Constraints, SIL/HIL Compatibility, Resource Contention) are included as optional sections activated by domain configuration.

## Governing Standards

This feature is guided by the following international standards:

- **ISO/IEC/IEEE 42010:2011** — Systems and Software Engineering — Architecture Description. Defines the framework for documenting architecture viewpoints and views that an auditor expects in a compliant architecture description.
- **Kruchten's 4+1 View Model** — Defines the four mandatory architecture views (Logical, Process, Interface/Development, Data Flow/Physical) plus scenarios that link them. Widely adopted in safety-critical and regulated industries.
- **ISO/IEC/IEEE 29119-4** — Software Testing — Test Techniques. Defines the integration test techniques (Contract Testing, Data Flow Testing, Fault Injection) that integration-level test plans must employ.
- **ISO 26262** — Automotive functional safety. Adds ASIL Decomposition (safety integrity allocation per module) and Defensive Programming requirements for architecture-level artifacts.
- **DO-178C** — Airborne software certification. Adds Temporal & Execution Constraints (watchdog timers, execution order, deadlock prevention) for architecture-level artifacts.
- **IEC 62304** — Medical device software lifecycle. Requires traceability from software architecture to integration test verification.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Generate 42010/4+1 Architecture Design (Priority: P1)

A safety engineer working on a patient vital signs monitor has a `system-design.md` with 5 system components (`SYS-001` through `SYS-005`). She runs `/speckit.v-model.architecture-design` to decompose these system components into software modules (`ARCH-NNN`) organized into four mandatory architecture views:

1. **Logical View (Component Breakdown)**: How each `SYS-NNN` is decomposed into software modules (`ARCH-NNN`). Example: `SYS-001` (Sensor Subsystem) → `ARCH-001` (I2C Driver), `ARCH-002` (Data Parser), `ARCH-003` (Event Emitter). Each ARCH module traces to one or more parent SYS components via an explicit "Parent System Components" field (many-to-many SYS↔ARCH traceability).
2. **Process View (Dynamic Behavior)**: Runtime module interactions — sequences, concurrency, thread management. Mermaid sequence diagrams embedded in Markdown showing execution order, synchronization points, and thread/task boundaries.
3. **Interface View (Strict API / Interface Contracts)**: Every `ARCH-NNN` has an explicitly defined contract: inputs accepted (types, formats, ranges), outputs produced (types, guarantees), exceptions thrown (error codes, failure modes). These contracts directly drive Interface Contract Testing.
4. **Data Flow View (Data Control Flow)**: Traces how data moves through the modules — input → transformation chain → output with intermediate formats. Feeds Data Flow Testing technique.

Every system component is covered by at least one architecture module, and every module traces back to at least one system component (many-to-many mapping supported).

**Why this priority**: Architecture design decomposition is the foundational artifact of this V-level. Without it, integration tests cannot be generated, the traceability matrix cannot be extended to Matrix C, and no downstream work can proceed. Structuring it into 42010/4+1 views prevents the AI from generating generic descriptions and forces it to produce concrete, testable module specifications with explicit interface contracts.

**Independent Test**: Can be fully tested by running the command on any existing `system-design.md` and verifying: (1) every `SYS-NNN` is referenced by at least one `ARCH-NNN`, (2) the output contains all four mandatory architecture views, (3) every ARCH module has explicit interface contracts in the Interface View, (4) `validate-architecture-coverage.sh` confirms 100% SYS→ARCH forward coverage.

**Acceptance Scenarios**:

1. **Given** a `system-design.md` with 5 system components (`SYS-001` through `SYS-005`), **When** the user runs `/speckit.v-model.architecture-design`, **Then** the system produces `architecture-design.md` with `ARCH-NNN` modules organized into Logical, Process, Interface, and Data Flow views, with every system component covered.
2. **Given** a `system-design.md` with a complex component spanning multiple subsystems, **When** the architecture design is generated, **Then** the component is decomposed into multiple `ARCH-NNN` modules, and the Process View shows the runtime interactions between those modules via Mermaid sequence diagrams.
3. **Given** a `system-design.md` with cross-cutting quality attributes (performance, security), **When** the architecture design is generated, **Then** the quality attributes are addressed as explicit constraints in the Interface View (e.g., latency guarantees) and Data Flow View (e.g., encryption at transformation boundaries).
4. **Given** a project configured for automotive (ISO 26262), **When** the architecture design is generated, **Then** the output includes an additional **ASIL Decomposition** section documenting safety integrity allocation per module (e.g., SYS ASIL-D → ARCH-001 ASIL-D + ARCH-002 ASIL-A), a **Defensive Programming** section documenting how invalid inputs from one module are caught before corrupting the next, and a **Temporal & Execution Constraints** section documenting watchdog timers, execution order, and deadlock prevention.

---

### User Story 2 - Generate ISO 29119-4 Integration Test Plan (Priority: P1)

After generating the architecture design, the engineer runs `/speckit.v-model.integration-test` to produce an integration test plan: test cases (`ITP-NNN-X`) and test scenarios (`ITS-NNN-X#`) for every architecture module. Unlike system tests (which verify that the architecture works as designed), integration tests verify the **seams and handshakes between modules** — they specifically target the module boundaries using four mandatory ISO 29119-4 techniques:

1. **Interface Contract Testing**: Module A (Consumer) expects Module B (Provider) to honor a specific data contract. Verifies Module B delivers the exact interface defined in the Interface View. Driven by Interface View contracts.
2. **Data Flow Testing**: Inject data into ARCH-001, verify correct format at ARCH-003. End-to-end data transformation chain validation. Driven by Data Flow View.
3. **Interface Fault Injection ("The Bad Handshake")**: Malformed payloads, timeout scenarios, graceful failure verification. Modules must fail gracefully without taking down the whole system. Driven by Interface View error contracts + Process View timing.
4. **Concurrency & Race Condition Testing**: Simultaneous access patterns, lock handling, queue ordering. Verifies mutex strategies, resource contention resolution. Driven by Process View concurrency model.

The command runs `validate-architecture-coverage.sh` and reports 100% ARCH→ITP bidirectional coverage.

**Why this priority**: This is the right side of the V at the architecture level, paired with the architecture design. The V-Model principle (Constitution P1) requires that every development artifact has a simultaneously generated testing artifact. Anchoring test techniques to ISO 29119-4 prevents the AI from generating weak "verify it works" tests and forces it to produce integration-specific scenarios that test the boundaries between modules.

**Independent Test**: Can be tested by running the command on a valid `architecture-design.md` and verifying: (1) every `ARCH-NNN` has at least one `ITP-NNN-X`, (2) test cases reference specific architecture views and apply named techniques (Interface Contract, Data Flow, Fault Injection, Concurrency), (3) `validate-architecture-coverage.sh` reports 100% coverage, (4) ID lineage encoding is correct (`ITS-001-A1` → `ITP-001-A` → `ARCH-001`).

**Acceptance Scenarios**:

1. **Given** an `architecture-design.md` with 8 architecture modules (`ARCH-001` through `ARCH-008`), **When** the user runs `/speckit.v-model.integration-test`, **Then** the system produces `integration-test.md` with at least one `ITP-NNN-X` per module and at least one `ITS-NNN-X#` per test case, with test techniques explicitly named.
2. **Given** an architecture module with explicit interface contracts in the Interface View, **When** the integration test plan is generated, **Then** separate test cases cover the contract with Interface Contract tests (valid input, contract violation, schema mismatch).
3. **Given** two modules that interact concurrently according to the Process View, **When** the integration test plan is generated, **Then** test cases include Concurrency & Race Condition scenarios (simultaneous access, lock contention, queue ordering).
4. **Given** a project configured for aerospace (DO-178C), **When** the integration test plan is generated, **Then** the output includes an additional **SIL/HIL Compatibility** section marking scenarios executable in Software/Hardware-in-the-Loop environments, and a **Resource Contention** section proving modules don't exhaust shared resources during interaction.

---

### User Story 3 - Validate Architecture-Level Bidirectional Coverage (Priority: P1)

The engineer runs `validate-architecture-coverage.sh` to deterministically verify two coverage dimensions: (1) forward coverage — every `SYS-NNN` is decomposed into at least one `ARCH-NNN`, and (2) backward coverage — every `ARCH-NNN` has at least one `ITP-NNN-X` test case. The script also detects orphaned modules (ARCH with no parent SYS) and orphaned test cases (ITP with no parent ARCH). The script exits with a non-zero status code if any gap is found, enabling CI hard-fail enforcement (Constitution P2).

**Why this priority**: Deterministic verification is a non-negotiable constitutional principle. Without this script, coverage claims rely on AI self-assessment, which violates Constitution P2. The script is also a dependency of the integration test command (which calls it as a coverage gate).

**Independent Test**: Can be tested with fixture files: a minimal valid set (100% coverage), a set with a missing ARCH mapping (gap detected), a set with an orphaned ITP (orphan detected), and verifying correct exit codes and output messages for each.

**Acceptance Scenarios**:

1. **Given** `system-design.md`, `architecture-design.md`, and `integration-test.md` with 100% bidirectional coverage, **When** `validate-architecture-coverage.sh` runs, **Then** it exits with code 0 and prints a coverage summary.
2. **Given** an `architecture-design.md` where `SYS-003` has no corresponding `ARCH-NNN`, **When** `validate-architecture-coverage.sh` runs, **Then** it exits with code 1 and reports "SYS-003: no architecture module mapping found."
3. **Given** an `integration-test.md` with `ITP-099-A` that references a non-existent `ARCH-099`, **When** `validate-architecture-coverage.sh` runs, **Then** it exits with code 1 and reports "ITP-099-A: orphaned test case — parent ARCH-099 not found in architecture-design.md."

---

### User Story 4 - Extended Traceability Matrix with Architecture Layer (Priority: P2)

After acceptance, system, and integration testing artifacts exist, the engineer runs the updated `/speckit.v-model.trace` command. The extended traceability matrix now produces **three complementary matrices**:

- **Matrix A — Validation (User View)**: `REQ → ATP → SCN` — proves the system does what the user needs.
- **Matrix B — Verification (Architectural View)**: `REQ → SYS → STP → STS` — proves the architecture works as designed.
- **Matrix C — Verification (Integration View)**: `SYS → ARCH → ITP → ITS` — proves the module boundaries work correctly.

Each matrix includes its own coverage percentage. The trace command builds matrices progressively: Matrix A alone after acceptance, A+B after system-test, A+B+C after integration-test.

**Why this priority**: The traceability matrix is the key audit artifact for regulated industries, but Matrix C requires both the architecture design and integration test commands to exist first. It extends the existing trace command rather than creating a new one.

**Independent Test**: Can be tested by running the updated trace command on a feature directory that has all six artifacts (requirements, acceptance plan, system design, system test, architecture design, integration test), then verifying: (1) the matrix includes all three matrices, (2) each matrix has independent coverage percentages, (3) backward compatibility — when architecture-level artifacts are absent, only Matrix A+B is produced.

**Acceptance Scenarios**:

1. **Given** a feature directory with all six artifacts, **When** `/speckit.v-model.trace` runs, **Then** the output includes Matrix A (REQ → ATP → SCN), Matrix B (REQ → SYS → STP → STS), and Matrix C (SYS → ARCH → ITP → ITS), each with correct linkages and independent coverage percentages.
2. **Given** a feature directory with only requirements, acceptance plan, system design, and system test (no architecture-level artifacts), **When** `/speckit.v-model.trace` runs, **Then** only Matrix A and Matrix B are generated (backward compatible with v0.2.0 — no Matrix C, no warning).
3. **Given** a many-to-many SYS↔ARCH mapping, **When** Matrix C is generated, **Then** each SYS row lists all linked ARCH modules, and the matrix correctly counts coverage without double-counting.

---

### User Story 5 - PowerShell Parity for Integration Coverage Validation (Priority: P3)

A Windows-based automotive ADAS team runs `validate-architecture-coverage.ps1` to get the same deterministic coverage validation available on Unix/macOS via the Bash script. The PowerShell script produces identical output format, identical exit codes, and passes the same test fixtures.

**Why this priority**: Cross-platform parity is important for enterprise adoption but is not a functional blocker. The Bash script delivers the core capability; PowerShell follows as a port.

**Independent Test**: Can be tested by running both the Bash and PowerShell scripts on the same fixture files and verifying identical output and exit codes.

**Acceptance Scenarios**:

1. **Given** a valid set of architecture artifacts, **When** `validate-architecture-coverage.ps1` runs, **Then** it produces the same coverage summary and exit code as `validate-architecture-coverage.sh` on the same inputs.
2. **Given** a set with coverage gaps, **When** `validate-architecture-coverage.ps1` runs, **Then** it reports the same gap messages and exits with code 1.

---

### Edge Cases

- **What happens when `system-design.md` is empty or has zero SYS-NNN identifiers?** The architecture design command should fail gracefully with a clear error message ("No system components found in system-design.md — cannot generate architecture design").
- **What happens when a SYS-NNN maps to only cross-cutting quality attributes (e.g., logging, monitoring)?** The architecture design should create utility or infrastructure modules with explicit interface contracts, not skip them.
- **How does the system handle circular dependencies between ARCH modules in the Process View?** The validation script should detect and report cycles without hanging.
- **What happens when `architecture-design.md` exists but `integration-test.md` does not?** The trace command should include the ARCH column in Matrix C but leave the ITP column empty with a warning ("Integration test plan not yet generated").
- **What happens when the ID numbering in `architecture-design.md` has gaps (e.g., ARCH-001, ARCH-003, skipping ARCH-002)?** The system should accept gaps in numbering without error — gaps are valid when modules are deleted or reorganized.
- **How does the system handle a system-design.md with many components (e.g., 50+ SYS-NNN)?** The commands should handle large inputs without truncation or performance issues, processing in batches if necessary.
- **What happens when safety-critical sections (ASIL Decomposition, SIL/HIL) are requested but the project is not configured for a regulated domain?** The sections should be omitted by default and only included when the domain configuration enables them.
- **What happens when an ARCH module's interface contract is incomplete (missing error handling)?** The anti-pattern guard should reject "black box" descriptions without complete interface contracts (inputs, outputs, exceptions).
- **What happens when the AI identifies a necessary technical module not traceable to any SYS component (a Derived Architecture Module)?** The command must flag it as `[DERIVED MODULE: description]` rather than silently creating an ARCH-NNN, prompting the user to update system-design.md and re-run.

## Requirements *(mandatory)*

### Functional Requirements

**Architecture Design Command:**

- **FR-001**: The extension MUST provide a `/speckit.v-model.architecture-design` command that reads `system-design.md` and produces `architecture-design.md` with `ARCH-NNN` identifiers organized into ISO/IEC/IEEE 42010 and Kruchten 4+1 architecture views.
- **FR-002**: The architecture design output MUST include four mandatory views: Logical View (SYS → ARCH component breakdown with many-to-many traceability), Process View (runtime module interactions with Mermaid sequence diagrams), Interface View (strict API contracts per module — inputs, outputs, exceptions), and Data Flow View (data transformation chain tracing).
- **FR-003**: Each `ARCH-NNN` module MUST trace to one or more `SYS-NNN` identifiers via an explicit "Parent System Components" field in the Logical View.
- **FR-004**: The architecture design command MUST support many-to-many SYS↔ARCH relationships — a single system component MAY map to multiple architecture modules, and a single module MAY satisfy multiple system components.
- **FR-005**: When the project is configured for a safety-critical domain (ISO 26262, DO-178C, IEC 62304), the architecture design output MUST include additional sections: ASIL Decomposition (safety integrity allocation per module), Defensive Programming (how invalid inputs between modules are caught), and Temporal & Execution Constraints (watchdog timers, execution order, deadlock prevention).
- **FR-006**: The architecture design command MUST reject "black box" descriptions — every ARCH module MUST have a complete interface contract in the Interface View (inputs, outputs, exceptions). Modules with incomplete contracts trigger an anti-pattern warning.
- **FR-007**: `ARCH-NNN` modules MUST trace to either one or more `SYS-NNN` identifiers (business logic modules) OR a `[CROSS-CUTTING]` tag (infrastructure/utility modules such as logging, secrets management, thread pools, or error handling frameworks). Cross-cutting modules are architecturally necessary but do not trace to a single system component — they serve the system as a whole. The Logical View MUST clearly distinguish business-logic modules (with explicit SYS parents) from cross-cutting modules (with the `[CROSS-CUTTING]` tag and a rationale). Cross-cutting modules are included in coverage validation: they MUST still have ≥1 `ITP-NNN-X` test case.
- **FR-007a**: When the architecture design process identifies a necessary technical module that is neither traceable to any `SYS-NNN` nor qualifies as a `[CROSS-CUTTING]` utility (i.e., it implies a missing system component), the command MUST flag it as `[DERIVED MODULE: description]` rather than silently creating an `ARCH-NNN`, prompting the user to update `system-design.md`.

**Integration Test Command:**

- **FR-008**: The extension MUST provide a `/speckit.v-model.integration-test` command that reads `architecture-design.md` and produces `integration-test.md` with `ITP-NNN-X` test cases and `ITS-NNN-X#` test scenarios.
- **FR-009**: Integration test cases MUST apply four mandatory ISO 29119-4 techniques: Interface Contract Testing (driven by Interface View), Data Flow Testing (driven by Data Flow View), Interface Fault Injection (driven by Interface View error contracts + Process View timing), and Concurrency & Race Condition Testing (driven by Process View concurrency model).
- **FR-010**: Each integration test case (`ITP-NNN-X`) MUST explicitly name its technique and reference the specific architecture view that drives it.
- **FR-011**: Integration test scenarios (`ITS-NNN-X#`) MUST use Given/When/Then BDD structure with **technical, module-boundary-oriented language** (e.g., "Given Module A sends a malformed payload to Module B, When Module B receives the payload, Then Module B rejects it with error code INVALID_SCHEMA and does not propagate the error downstream"), distinct from user-centric acceptance language and system-level test language.
- **FR-012**: When the project is configured for a safety-critical domain, the integration test output MUST include additional sections: SIL/HIL Compatibility (scenarios executable in Software/Hardware-in-the-Loop environments) and Resource Contention (proving modules don't exhaust shared resources during interaction).
- **FR-013**: The integration test command MUST invoke `validate-architecture-coverage.sh` as a coverage gate after generation, reporting the result in its output.
- **FR-014**: The integration test command MUST NOT generate tests for internal module logic or user-journey scenarios — only tests that verify the boundaries and handshakes between modules.

**ID Schema:**

- **FR-015**: The ID lineage encoding MUST be consistent: `ITS-001-A1` → `ITP-001-A` → `ARCH-001` → `SYS-001`, allowing any ID to be traced to its full ancestry by parsing the identifier alone.
- **FR-016**: Architecture module identifiers MUST follow the format `ARCH-NNN` (3-digit zero-padded, e.g., `ARCH-001`, `ARCH-012`).
- **FR-017**: Integration test case identifiers MUST follow the format `ITP-NNN-X` where NNN matches the parent `ARCH-NNN` and X is a sequential uppercase letter (e.g., `ITP-001-A`, `ITP-001-B`).
- **FR-018**: Integration test scenario identifiers MUST follow the format `ITS-NNN-X#` where NNN-X matches the parent `ITP-NNN-X` and # is a sequential number (e.g., `ITS-001-A1`, `ITS-001-A2`).

**Validation Scripts:**

- **FR-019**: The extension MUST provide `validate-architecture-coverage.sh` (Bash) that deterministically validates: (a) every `SYS-NNN` has ≥1 `ARCH-NNN` mapping (forward), (b) every `ARCH-NNN` has ≥1 `ITP-NNN-X` test case (backward), (c) no orphaned ARCH or ITP identifiers exist.
- **FR-020**: The validation script MUST exit with code 0 on full coverage and code 1 on any gap, with human-readable gap reports suitable for CI logs.
- **FR-021**: The validation script MUST support `--json` output mode for programmatic consumption by the integration test command.
- **FR-022**: The extension MUST provide `validate-architecture-coverage.ps1` (PowerShell) with identical behavior, output format, and exit codes as the Bash script.

**Traceability & Matrix:**

- **FR-023**: The `/speckit.v-model.trace` command MUST be extended to produce three complementary matrices when architecture-level artifacts exist: **Matrix A (Validation)** — `REQ → ATP → SCN`, **Matrix B (Verification)** — `REQ → SYS → STP → STS`, and **Matrix C (Integration Verification)** — `SYS → ARCH → ITP → ITS`, each with independent coverage percentages. In Matrix C, each `SYS-NNN` cell MUST include a comma-separated list of its parent `REQ-NNN` identifiers in parentheses (e.g., `SYS-001 (REQ-001, REQ-003)`) to provide end-to-end requirement traceability without requiring cross-reference to Matrix B.
- **FR-024**: The extended traceability matrix MUST remain backward compatible — when architecture-level artifacts are absent, the matrix MUST produce the same v0.2.0 output (Matrix A + Matrix B only, no Matrix C, no warning).
- **FR-025**: The trace command MUST build matrices progressively: Matrix A alone after acceptance, A+B after system-test, A+B+C after integration-test.
- **FR-026**: The `build-matrix.sh` and `build-matrix.ps1` scripts MUST be extended to parse `architecture-design.md` and `integration-test.md` for Matrix C.

**Templates & Constraints:**

- **FR-027**: All new templates (`architecture-design-template.md`, `integration-test-template.md`) MUST be created in the extension's `templates/` directory and referenced by the corresponding commands.
- **FR-028**: All new commands MUST follow the strict translator constraint — when deriving from existing artifacts, the AI MUST NOT invent, infer, or add features not present in the input.
- **FR-029**: The `setup-v-model.sh` and `setup-v-model.ps1` scripts MUST be extended with a `--require-system-design` flag and MUST detect `architecture-design.md` and `integration-test.md` in the available documents list.

### Key Entities

- **Architecture Module (ARCH-NNN)**: A discrete software module decomposed from one or more system components, documented across four 42010/4+1 architecture views. Key attributes: ID, Name, Description, Parent System Components (list of SYS-NNN), Interface Contract (inputs/outputs/exceptions), Runtime Behavior (thread/task boundaries, synchronization), Data Transformations (input→output format chain). Relationship: many-to-many with System Components; one-to-many with Integration Test Cases.
- **Integration Test Case (ITP-NNN-X)**: A logical validation condition for an architecture module boundary, anchored to a specific architecture view and ISO 29119-4 test technique. Key attributes: ID, Parent Architecture Module (ARCH-NNN), Description, Target Architecture View, Test Technique (Interface Contract / Data Flow / Fault Injection / Concurrency), Validation Condition. Relationship: many-to-one with Architecture Modules; one-to-many with Integration Test Scenarios.
- **Integration Test Scenario (ITS-NNN-X#)**: A concrete, executable test scenario in Given/When/Then format nested under an integration test case. Uses **technical, module-boundary-oriented language** focused on the seams between modules (e.g., "Given Module A sends a malformed payload to Module B, When Module B receives the payload, Then Module B rejects it with error code INVALID_SCHEMA"). Key attributes: ID, Parent Test Case (ITP-NNN-X), Given/When/Then steps, Test Data, Expected Behavior. Relationship: many-to-one with Integration Test Cases.
- **Extended Traceability Matrix**: The audit artifact with three complementary matrices: Matrix A (Validation — REQ → ATP → SCN), Matrix B (Verification — REQ → SYS → STP → STS), and Matrix C (Integration Verification — SYS → ARCH → ITP → ITS). Key attributes per matrix: linked artifacts per layer, Coverage Status, Coverage Percentage. Progressive behavior: A alone after acceptance, A+B after system-test, A+B+C after integration-test.
- **Integration Coverage Report**: The output of `validate-architecture-coverage.sh` — a summary of forward coverage (SYS→ARCH), backward coverage (ARCH→ITP), orphan detection, and overall pass/fail status with exit codes suitable for CI enforcement.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Running `/speckit.v-model.architecture-design` on any valid `system-design.md` produces an `architecture-design.md` containing all four 42010/4+1 architecture views (Logical, Process, Interface, Data Flow) where `validate-architecture-coverage.sh` confirms 100% SYS→ARCH forward coverage.
- **SC-002**: Running `/speckit.v-model.integration-test` on any valid `architecture-design.md` produces an `integration-test.md` where: (a) `validate-architecture-coverage.sh` confirms 100% ARCH→ITP backward coverage with zero orphans, and (b) every test case explicitly names one of the four mandatory ISO 29119-4 techniques.
- **SC-003**: The ID lineage encoding is machine-parseable — given any `ITS-NNN-X#` ID, a regex can extract the parent `ITP-NNN-X`, grandparent `ARCH-NNN`, and great-grandparent `SYS-NNN` without consulting any lookup table.
- **SC-004**: The extended traceability output includes three matrices (Validation: REQ→ATP→SCN, Verification: REQ→SYS→STP→STS, Integration Verification: SYS→ARCH→ITP→ITS) with independent coverage percentages that match the deterministic script outputs.
- **SC-005**: All BATS tests for `validate-architecture-coverage.sh` pass with 100% fixture coverage (valid, gap, orphan, empty, large-input scenarios).
- **SC-006**: All Pester tests for `validate-architecture-coverage.ps1` pass with identical results as the BATS tests on the same fixture data.
- **SC-007**: (Internal QA gate) The extension's CI evaluation suite confirms that the new architecture design and integration test commands produce outputs matching or exceeding the quality thresholds established for v0.2.0 artifacts (42010 view completeness, ISO 29119-4 technique usage, interface contract completeness). The evaluation suite MUST additionally verify the syntactic validity of generated Mermaid diagrams in the Process View — broken Mermaid syntax is a structural failure.
- **SC-008**: The extension's `extension.yml` registers 7 commands (5 existing + 2 new) and 1 hook, and the version is bumped to `0.3.0`.
- **SC-009**: Backward compatibility verified — running any v0.2.0 command on existing artifacts produces identical output before and after the v0.3.0 update.

### Assumptions

- Users already have a valid `system-design.md` generated by `/speckit.v-model.system-design` (v0.2.0). The architecture design command does not generate system designs — it decomposes system components into software modules.
- The many-to-many SYS↔ARCH relationship is documented in the architecture design template via a "Parent System Components" field, not inferred at runtime. Each `ARCH-NNN` entry explicitly lists its parent `SYS-NNN` IDs.
- The `validate-architecture-coverage.sh` script uses regex-based parsing (consistent with `validate-system-coverage.sh` from v0.2.0) — it does not require a runtime database or external tooling.
- Backward compatibility with v0.2.0 artifacts is mandatory — existing `system-design.md`, `system-test.md`, and `traceability-matrix.md` files MUST NOT be modified by any v0.3.0 command.
- Safety-critical sections (ASIL Decomposition, Defensive Programming, Temporal Constraints, SIL/HIL Compatibility, Resource Contention) are optional and activated by domain configuration in `v-model-config.yml`. Projects not targeting regulated domains get the four mandatory 42010/4+1 views without the safety additions.
- The integration test command tests **module boundaries only** — it does NOT test internal module logic (that is the responsibility of unit tests at the Module Design ↔ Unit Testing level, planned for v0.4.0) and it does NOT test user journeys (that is the responsibility of acceptance tests).
