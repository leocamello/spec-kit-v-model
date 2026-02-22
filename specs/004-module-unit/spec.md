# Feature Specification: Module Design ↔ Unit Testing

**Feature Branch**: `004-module-unit-testing`  
**Created**: 2026-02-21  
**Status**: Draft  
**Input**: Extend the V-Model Extension Pack down to the lowest implementation level — Module Design ↔ Unit Testing (v0.4.0). This is the bottom of the V-Model, where specification meets code. In DO-178C terms, Low-Level Requirements (Module Design) must be so detailed that writing the actual source code is merely a translation exercise requiring no further architectural or design decisions. The module design command translates architecture modules into highly detailed, implementable low-level designs using strict DO-178C and ISO 26262 Part 6 principles (Algorithmic pseudocode, State Machines, Data Structures, Error Handling) and introduces a Source File mapping to bridge specification to code. The unit test command generates ISO/IEC/IEEE 29119-4 white-box test plans employing Statement/Branch Coverage, Boundary Value Analysis, Strict Isolation (via a Dependency & Mock Registry), and State Transition Testing. Safety-critical toggles add MISRA C complexity constraints and MC/DC structural coverage. The commands handle `[CROSS-CUTTING]` modules (full decomposition required) and `[EXTERNAL]` modules (wrapper-only documentation, no deep pseudocode of 3rd-party internals) correctly.

## Governing Standards

This feature is guided by the following international standards:

- **DO-178C (Software Considerations in Airborne Systems)** — Defines Low-Level Requirements (LLR). At this level, requirements must be detailed enough that coding is merely a translation exercise. Requires MC/DC (Modified Condition/Decision Coverage) testing for Level A software. Mandates single point of entry/exit for deterministic execution paths.
- **ISO 26262 Part 6 (Automotive — Product development at the software level)** — Dictates software unit design and testing. Mandates restricted complexity (MISRA C/C++), prohibition of dynamic memory allocation after initialization, no unbounded loops, and variable-level fault injection for ASIL-D.
- **ISO/IEC/IEEE 29119-4 (Software Testing — Test Techniques)** — Defines White-Box testing techniques: Statement Coverage, Branch Coverage, Boundary Value Analysis, Equivalence Partitioning, and State Transition Testing. This is fundamentally different from the black-box techniques at the system and integration levels.
- **MISRA C:2012 / CERT-C** — Safe coding standards that constrain implementation complexity. Module Design must annotate which MISRA/CERT rules apply per module (e.g., cyclomatic complexity ≤ 10, no recursion, no pointer arithmetic).
- **IEC 62304 (Medical device software lifecycle)** — Requires traceability from software unit design to unit test verification. Class C software demands the highest rigor in unit-level documentation.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Generate DO-178C-Compliant Module Design (Priority: P1)

A software engineer working on a patient vital signs monitor has an `architecture-design.md` containing 11 architecture modules (`ARCH-001` through `ARCH-011`, including one `[CROSS-CUTTING]` diagnostic logger). She runs `/speckit.v-model.module-design` to decompose these into Low-Level Designs (`MOD-NNN`) organized into four mandatory views:

1. **Algorithmic / Logic View**: Step-by-step pseudocode defining exactly how each module transforms inputs into outputs. Every branch, loop, and decision point is explicit. Each `MOD-NNN` includes a **Target Source File(s)** property (e.g., `src/sensor/parser.py` or `src/sensor/parser.h, src/sensor/parser.cpp`), bridging the gap between documentation and the actual repository codebase.
2. **State Machine View**: For stateful modules — every state, transition, event, and guard condition explicitly defined using Mermaid `stateDiagram-v2` syntax. Stateless modules are marked `N/A — Stateless` (validated gracefully without failure).
3. **Internal Data Structures**: Local variables, constants, buffers, and object classes with explicit types, sizes, and constraints (e.g., "buffer is exactly 256 bytes, uint8_t array, initialized to 0x00").
4. **Error Handling & Return Codes**: Exactly how the module catches exceptions internally and formats them to honor the contract defined in the Architecture Interface View (inputs, outputs, error codes).

Every `ARCH-NNN` is covered by at least one `MOD-NNN` (including `[CROSS-CUTTING]` modules), and every module traces back to at least one architecture module (many-to-many ARCH↔MOD mapping). Modules wrapping third-party libraries (e.g., PostgreSQL driver, AWS SDK) are tagged `[EXTERNAL]` — the tool documents only the wrapper/configuration interface, omitting deep algorithmic pseudocode to prevent hallucination of 3rd-party internals.

**Why this priority**: Module Design is the foundational artifact of the bottom V-level. Without it, unit tests cannot be generated, the traceability matrix cannot be extended to Matrix D, and no downstream work can proceed. Requiring concrete pseudocode (not descriptive prose) forces the AI to produce implementation-ready specifications that serve as the direct input to `/speckit.implement`. The Source File mapping makes this the first V-Model artifact that explicitly connects to the repository's file tree.

**Independent Test**: Can be fully tested by running the command on any existing `architecture-design.md` and verifying: (1) every `ARCH-NNN` is referenced by at least one `MOD-NNN`, (2) the output contains all four mandatory views, (3) every MOD has concrete pseudocode in the Algorithmic View (not descriptive prose), (4) every MOD has a Target Source File(s), (5) `[EXTERNAL]` modules have wrapper-only documentation, (6) `validate-module-coverage.sh` confirms 100% ARCH→MOD forward coverage.

**Acceptance Scenarios**:

1. **Given** an `architecture-design.md` with 11 architecture modules (`ARCH-001` through `ARCH-011`), **When** the user runs `/speckit.v-model.module-design`, **Then** the system produces `module-design.md` with `MOD-NNN` items organized into Algorithmic/Logic, State Machine, Internal Data Structures, and Error Handling views, with every architecture module covered and every MOD including a Target Source File(s).
2. **Given** an `architecture-design.md` with a `[CROSS-CUTTING]` diagnostic logger module, **When** the module design is generated, **Then** the logger is fully decomposed into one or more `MOD-NNN` items with complete pseudocode (not bypassed or simplified), because infrastructure code requires unit testing just as much as business logic.
3. **Given** an `architecture-design.md` with an `ARCH-NNN` that wraps a third-party PostgreSQL driver, **When** the module design is generated, **Then** the resulting module is tagged `[EXTERNAL]` and documents only the wrapper configuration interface (connection parameters, retry policy, timeout config) without attempting to decompose the library's internal query engine.
4. **Given** a project configured for aerospace (DO-178C Level A), **When** the module design is generated, **Then** the output includes additional **Complexity Constraints** (cyclomatic complexity ≤ 10 per function), **Memory Management** rules (no dynamic allocation after init, no unbounded loops), **Single Entry/Exit** enforcement (one return point per function), and **MISRA/CERT-C Compliance** annotations per module.
5. **Given** a module that maintains internal state (e.g., a connection pool manager), **When** the module design is generated, **Then** the State Machine View contains a valid Mermaid `stateDiagram-v2` diagram with every state, transition, event, and guard condition.

---

### User Story 2 - Generate ISO 29119-4 White-Box Unit Test Plan (Priority: P1)

After generating the module design, the engineer runs `/speckit.v-model.unit-test` to produce a unit test plan: test cases (`UTP-NNN-X`) and test scenarios (`UTS-NNN-X#`) for every module. Unlike higher-level black-box testing (system, integration), unit tests are **white-box** — they target the internal control flow and data flow of the code, not the external behavior or boundaries.

The command generates tests using four mandatory ISO 29119-4 white-box techniques:

1. **Statement & Branch Coverage**: Tests execute every line of code and every True/False outcome of every conditional (`if/else`, `switch`, ternary). Designed from the Algorithmic/Logic View pseudocode.
2. **Boundary Value Analysis (BVA)**: At the variable level — if an integer must be between 1 and 100, unit tests target 0, 1, 50, 100, and 101. Designed from the Internal Data Structures view (types, sizes, constraints).
3. **Strict Isolation (Mocking/Stubbing)**: A unit test MUST never hit a real database, network, or external hardware. Every dependency outside the module is mocked or stubbed. Each `UTP-NNN-X` includes a **Dependency & Mock Registry** table explicitly listing all external dependencies (from the Architecture Interface View) and their mock/stub strategy.
4. **State Transition Testing**: For stateful modules — covers every state transition (including invalid transitions) as defined in the State Machine View.

The command does NOT generate unit tests for `MOD-NNN` items tagged `[EXTERNAL]` (wrapper behavior is tested at the integration level, not unit level).

**Why this priority**: This is the right side of the V at the lowest level, paired with module design. The V-Model principle (Constitution P1) requires that every development artifact has a simultaneously generated testing artifact. White-box techniques ensure that unit tests target the actual implementation structure (branches, variables, states), not just input/output behavior. The Dependency & Mock Registry prevents the common LLM failure mode of writing tests that accidentally integrate with real infrastructure.

**Independent Test**: Can be tested by running the command on a valid `module-design.md` and verifying: (1) every `MOD-NNN` (except `[EXTERNAL]`) has at least one `UTP-NNN-X`, (2) test cases reference specific module views and apply named techniques, (3) every UTP includes a Dependency & Mock Registry table, (4) `[EXTERNAL]` modules have zero UTPs, (5) `validate-module-coverage.sh` reports 100% coverage, (6) ID lineage encoding is correct (`UTS-001-A1` → `UTP-001-A` → `MOD-001`).

**Acceptance Scenarios**:

1. **Given** a `module-design.md` with 15 modules (`MOD-001` through `MOD-015`), **When** the user runs `/speckit.v-model.unit-test`, **Then** the system produces `unit-test.md` with at least one `UTP-NNN-X` per non-EXTERNAL module and at least one `UTS-NNN-X#` per test case, with test techniques explicitly named.
2. **Given** a module with complex boolean logic (`if (A and B or C)`), **When** the unit test plan is generated with a safety-critical configuration (DO-178C Level A), **Then** the output includes an MC/DC truth table proving each individual condition (A, B, C) can independently affect the decision outcome.
3. **Given** a module with a Dependency & Mock Registry listing three external dependencies (Database, MessageQueue, Logger), **When** the unit test scenarios are generated, **Then** every scenario explicitly uses the mocked versions and no scenario references real infrastructure.
4. **Given** a `MOD-NNN` tagged `[EXTERNAL]` (wrapping a third-party library), **When** the unit test plan is generated, **Then** the module is skipped with a note: "Module MOD-NNN is [EXTERNAL] — wrapper behavior tested at integration level."
5. **Given** a stateful module with a State Machine View, **When** the unit test plan is generated, **Then** State Transition Testing cases cover every defined transition (including invalid transitions that should be rejected).

---

### User Story 3 - Validate Module-Level Bidirectional Coverage (Priority: P1)

The engineer runs `validate-module-coverage.sh` to deterministically verify three coverage dimensions: (1) forward coverage — every `ARCH-NNN` (including `[CROSS-CUTTING]`) is decomposed into at least one `MOD-NNN`, (2) backward coverage — every `MOD-NNN` (except `[EXTERNAL]`) has at least one `UTP-NNN-X` test case, and (3) orphan detection — no MOD without a parent ARCH, no UTP without a parent MOD. The script correctly bypasses the UTP requirement for `MOD-NNN` items tagged `[EXTERNAL]`. The script exits with a non-zero status code if any gap is found, enabling CI hard-fail enforcement (Constitution P2).

**Why this priority**: Deterministic verification is a non-negotiable constitutional principle. Without this script, coverage claims rely on AI self-assessment, which violates Constitution P2. The `[EXTERNAL]` bypass is critical — requiring unit tests for third-party library internals would generate meaningless, hallucinated test cases.

**Independent Test**: Can be tested with fixture files: a minimal valid set (100% coverage), a set with a missing MOD mapping (gap detected), a set with an orphaned UTP (orphan detected), a set with `[EXTERNAL]` modules correctly bypassed, and verifying correct exit codes and output messages for each.

**Acceptance Scenarios**:

1. **Given** `architecture-design.md`, `module-design.md`, and `unit-test.md` with 100% bidirectional coverage (including `[CROSS-CUTTING]` modules tested), **When** `validate-module-coverage.sh` runs, **Then** it exits with code 0 and prints a coverage summary.
2. **Given** a `module-design.md` where `ARCH-003` has no corresponding `MOD-NNN`, **When** `validate-module-coverage.sh` runs, **Then** it exits with code 1 and reports "ARCH-003: no module design mapping found."
3. **Given** a `unit-test.md` with `UTP-099-A` that references a non-existent `MOD-099`, **When** `validate-module-coverage.sh` runs, **Then** it exits with code 1 and reports "UTP-099-A: orphaned test case — parent MOD-099 not found in module-design.md."
4. **Given** a `module-design.md` containing `MOD-007 [EXTERNAL]` with no corresponding `UTP-007-X`, **When** `validate-module-coverage.sh` runs, **Then** it exits with code 0 (the `[EXTERNAL]` module is correctly bypassed for unit test requirements).
5. **Given** an `architecture-design.md` and a `module-design.md` with 100% ARCH→MOD coverage, but `unit-test.md` does NOT exist, **When** `validate-module-coverage.sh` runs, **Then** it validates only the ARCH→MOD forward coverage leg, gracefully skips the MOD→UTP backward checks, and exits with code 0.

---

### User Story 4 - Extended Traceability Matrix with Implementation Layer (Priority: P2)

After all V-Model artifacts exist, the engineer runs the updated `/speckit.v-model.trace` command. The extended traceability matrix now produces **four complementary matrices** completing the full V-Model chain from user need to unit test:

- **Matrix A — Validation (User View)**: `REQ → ATP → SCN` — proves the system does what the user needs.
- **Matrix B — Verification (System View)**: `REQ → SYS → STP → STS` — proves the system architecture works as designed.
- **Matrix C — Verification (Integration View)**: `SYS → ARCH → ITP → ITS` — proves the module boundaries work correctly.
- **Matrix D — Verification (Implementation View)**: `ARCH → MOD → UTP → UTS` — proves the individual modules are correctly implemented and tested.

Each matrix includes its own coverage percentage. The trace command builds matrices progressively: Matrix A alone after acceptance, A+B after system-test, A+B+C after integration-test, A+B+C+D after unit-test.

**Why this priority**: Matrix D completes the full V-Model traceability chain. An auditor can now follow any user requirement from `REQ-001` all the way down to `UTS-001-A1` without gaps. However, Matrix D requires both the module design and unit test commands to exist first.

**Independent Test**: Can be tested by running the updated trace command on a feature directory that has all eight artifacts (requirements, acceptance plan, system design, system test, architecture design, integration test, module design, unit test), then verifying: (1) the matrix includes all four matrices, (2) each matrix has independent coverage percentages, (3) backward compatibility — when module-level artifacts are absent, only Matrix A+B+C is produced.

**Acceptance Scenarios**:

1. **Given** a feature directory with all eight V-Model artifacts, **When** `/speckit.v-model.trace` runs, **Then** the output includes Matrix A, B, C, and D with correct linkages and independent coverage percentages.
2. **Given** a feature directory with only requirements through integration-test (no module-level artifacts), **When** `/speckit.v-model.trace` runs, **Then** only Matrix A, B, and C are generated (backward compatible with v0.3.0 — no Matrix D, no warning).
3. **Given** a many-to-many ARCH↔MOD mapping where one ARCH spawns 3 MODs, **When** Matrix D is generated, **Then** each ARCH row lists all linked MOD modules, and the matrix correctly counts coverage without double-counting.
4. **Given** a `MOD-NNN` tagged `[EXTERNAL]`, **When** Matrix D is generated, **Then** the module appears in the MOD column with an `[EXTERNAL]` annotation and the UTP/UTS columns show "N/A — External" instead of a gap.
5. **Given** an `ARCH-NNN` tagged `[CROSS-CUTTING]` (e.g., a diagnostic logger), **When** Matrix D is generated, **Then** the ARCH cell displays `([CROSS-CUTTING])` in place of the `SYS-NNN` lineage annotation.

---

### User Story 5 - PowerShell Parity for Module Coverage Validation (Priority: P3)

A Windows-based automotive ADAS team runs `validate-module-coverage.ps1` to get the same deterministic coverage validation available on Unix/macOS via the Bash script. The PowerShell script produces identical output format, identical exit codes, handles `[EXTERNAL]` bypass identically, and passes the same test fixtures.

**Why this priority**: Cross-platform parity is important for enterprise adoption but is not a functional blocker. The Bash script delivers the core capability; PowerShell follows as a port.

**Independent Test**: Can be tested by running both the Bash and PowerShell scripts on the same fixture files and verifying identical output and exit codes, including `[EXTERNAL]` bypass behavior.

**Acceptance Scenarios**:

1. **Given** a valid set of module artifacts, **When** `validate-module-coverage.ps1` runs, **Then** it produces the same coverage summary and exit code as `validate-module-coverage.sh` on the same inputs.
2. **Given** a set with coverage gaps, **When** `validate-module-coverage.ps1` runs, **Then** it reports the same gap messages and exits with code 1.
3. **Given** a set with `[EXTERNAL]` modules, **When** `validate-module-coverage.ps1` runs, **Then** it correctly bypasses them, matching the Bash script behavior.

---

### Edge Cases

- **What happens when `architecture-design.md` is empty or has zero ARCH-NNN identifiers?** The module design command should fail gracefully with a clear error message ("No architecture modules found in architecture-design.md — cannot generate module design").
- **What happens when an ARCH-NNN tagged `[CROSS-CUTTING]` has no business-specific logic (pure infrastructure)?** The module design should still decompose it into MOD-NNN items with pseudocode — infrastructure code (loggers, error handlers, thread pools) has implementation logic that requires unit testing.
- **What happens when a module is stateless (pure function, no side effects)?** The State Machine View should be marked "N/A — Stateless" and validation should accept this gracefully without failing.
- **What happens when `module-design.md` exists but `unit-test.md` does not?** The trace command should include the MOD column in Matrix D but leave the UTP column empty with a warning ("Unit test plan not yet generated").
- **What happens when a `MOD-NNN` item has no external dependencies?** The Dependency & Mock Registry should show "None — module is self-contained" and the unit test should proceed with direct invocation (no mocking needed).
- **What happens when the AI identifies pseudocode that implies a missing module (e.g., a helper function not in the architecture)?** The command should flag it as `[DERIVED MODULE: description]` (consistent with v0.3.0 architecture behavior) rather than silently creating a MOD-NNN, prompting the user to update `architecture-design.md`.
- **What happens when an `[EXTERNAL]` module has a thin wrapper that does contain meaningful logic (e.g., retry policy, circuit breaker)?** The wrapper logic IS documented and unit-tested. Only the third-party library internals are bypassed. The `[EXTERNAL]` tag applies to the library, not the wrapper.
- **What happens when the ID numbering in `module-design.md` has gaps (e.g., MOD-001, MOD-003, skipping MOD-002)?** The system should accept gaps in numbering without error — gaps are valid when modules are deleted or reorganized.
- **How does the system handle a large architecture (e.g., 50+ ARCH-NNN)?** The commands should handle large inputs without truncation or performance issues, processing in batches if necessary.
- **What happens when safety-critical sections (MISRA constraints, MC/DC) are requested but the project is not configured for a regulated domain?** The sections should be omitted by default and only included when the domain configuration enables them.

## Requirements *(mandatory)*

### Functional Requirements

**Module Design Command:**

- **FR-001**: The extension MUST provide a `/speckit.v-model.module-design` command that reads `architecture-design.md` and produces `module-design.md` with `MOD-NNN` identifiers organized into four mandatory views.
- **FR-002**: The module design output MUST include four mandatory views: Algorithmic/Logic View (step-by-step pseudocode with explicit branches, loops, and decision points), State Machine View (Mermaid stateDiagram-v2 for stateful modules, "N/A — Stateless" for stateless modules), Internal Data Structures (types, sizes, constraints), and Error Handling & Return Codes (exception paths honoring Architecture Interface View contracts). Note: validation scripts MUST use a broad, case-insensitive pattern (e.g., `(?i)N/?A.*Stateless`) to detect the stateless bypass rather than an exact string literal, to accommodate minor LLM punctuation variance.
- **FR-003**: Each `MOD-NNN` MUST include a "Target Source File(s)" property mapping the module to one or more physical file paths in the repository (e.g., `src/sensor/parser.py` or `src/sensor/parser.h, src/sensor/parser.cpp` for header/implementation pairs). Comma-separated paths are allowed to handle languages where a single module spans multiple files.
- **FR-004**: Each `MOD-NNN` MUST trace to one or more `ARCH-NNN` identifiers via an explicit "Parent Architecture Modules" field (many-to-many ARCH↔MOD traceability).
- **FR-005**: The module design command MUST support many-to-many ARCH↔MOD relationships — a single architecture module MAY map to multiple modules, and a single module MAY satisfy multiple architecture modules.
- **FR-006**: The module design command MUST handle `ARCH-NNN` modules tagged `[CROSS-CUTTING]` by fully decomposing them into `MOD-NNN` items with complete pseudocode. Infrastructure code (loggers, error handlers) requires the same rigor as business logic.
- **FR-007**: If an `ARCH-NNN` module represents a third-party library wrapper, the command MUST tag the resulting module as `[EXTERNAL]` and document only the wrapper/configuration interface (connection parameters, retry policy, timeout config), omitting deep algorithmic pseudocode of the library internals.
- **FR-008**: When the project is configured for a safety-critical domain (DO-178C, ISO 26262, IEC 62304), the module design output MUST include additional sections: Complexity Constraints (cyclomatic complexity ≤ 10 per function, MISRA C/CERT-C rule annotations), Memory Management (no dynamic allocation after init, no unbounded loops), and Single Entry/Exit (one return point per function for deterministic execution).
- **FR-009**: The module design Algorithmic/Logic View MUST contain concrete pseudocode enclosed in fenced Markdown code blocks tagged `pseudocode` (i.e., ` ```pseudocode ... ``` `). Deterministic validators check for the presence of this fenced block within each MOD section; semantic quality of the pseudocode content is evaluated by the LLM-as-judge suite (SC-007).
- **FR-010**: When the module design process identifies a necessary function or class not traceable to any `ARCH-NNN`, the command MUST flag it as `[DERIVED MODULE: description]` rather than silently creating a `MOD-NNN`, prompting the user to update `architecture-design.md`.

**Unit Test Command:**

- **FR-011**: The extension MUST provide a `/speckit.v-model.unit-test` command that reads `module-design.md` and produces `unit-test.md` with `UTP-NNN-X` test cases and `UTS-NNN-X#` test scenarios.
- **FR-012**: Unit test cases MUST apply four mandatory ISO 29119-4 white-box techniques: Statement & Branch Coverage (execute every line, every True/False branch), Boundary Value Analysis (at the variable level — min, min-1, mid, max, max+1) or Equivalence Partitioning for discrete non-scalar types (Booleans, Enums) where numeric boundaries do not logically exist, Strict Isolation (every external dependency mocked), and State Transition Testing (every state transition including invalid ones).
- **FR-013**: Each unit test case (`UTP-NNN-X`) MUST explicitly name its technique and reference the specific module view that drives it.
- **FR-014**: Each unit test case (`UTP-NNN-X`) MUST include a **Dependency & Mock Registry** table explicitly listing all external dependencies the module has (from Architecture Interface View) and exactly how each is mocked/stubbed (e.g., `Mock: DatabaseConnection → Returns static JSON`). The registry MUST explicitly include hardware interfaces (e.g., GPIO pins, memory-mapped registers, I2C/SPI buses) as dependencies that require mocking/stubbing — LLMs often fail to recognize hardware registers as "dependencies" in embedded contexts.
- **FR-015**: Unit test scenarios (`UTS-NNN-X#`) MUST use Arrange/Act/Assert structure with **white-box, implementation-oriented language** referencing internal code paths, variables, and branches (e.g., "Arrange: Set buffer_size to 256 and input_length to 257, Act: Call parse_sensor_data(), Assert: Returns ERROR_OVERFLOW and buffer remains unchanged"), distinct from black-box acceptance or system-level language.
- **FR-016**: The unit test command MUST NOT generate unit test cases for `MOD-NNN` items tagged `[EXTERNAL]`. The skipped module MUST be noted: "Module MOD-NNN is [EXTERNAL] — wrapper behavior tested at integration level."
- **FR-017**: When the project is configured for a safety-critical domain (DO-178C Level A, ISO 26262 ASIL-D), the unit test output MUST include additional techniques: MC/DC (Modified Condition/Decision Coverage) with explicit boolean truth tables for complex conditional branches, and Variable-Level Fault Injection (forcing local variables into corrupted states to verify internal error handling).
- **FR-018**: The unit test command MUST invoke `validate-module-coverage.sh` as a coverage gate after generation, reporting the result in its output.
- **FR-019**: The unit test command MUST NOT generate tests for user-journey scenarios or integration-level module boundaries — only tests that verify internal module logic, branches, and data transformations.

**ID Schema:**

- **FR-020**: The ID lineage encoding MUST be consistent: `UTS-001-A1` → `UTP-001-A` → `MOD-001`, allowing any unit test ID to be traced up to its parent module by parsing the identifier alone. To resolve the `ARCH-NNN` ancestry, the script MUST consult the "Parent Architecture Modules" field in `module-design.md`, because many-to-many ARCH↔MOD relationships (FR-005) make it mathematically impossible to derive the ARCH parent from the ID string alone.
- **FR-021**: Module identifiers MUST follow the format `MOD-NNN` (3-digit zero-padded, e.g., `MOD-001`, `MOD-012`).
- **FR-022**: Unit test case identifiers MUST follow the format `UTP-NNN-X` where NNN matches the parent `MOD-NNN` and X is a sequential uppercase letter (e.g., `UTP-001-A`, `UTP-001-B`).
- **FR-023**: Unit test scenario identifiers MUST follow the format `UTS-NNN-X#` where NNN-X matches the parent `UTP-NNN-X` and # is a sequential number (e.g., `UTS-001-A1`, `UTS-001-A2`).

**Validation Scripts:**

- **FR-024**: The extension MUST provide `validate-module-coverage.sh` (Bash) that deterministically validates: (a) every `ARCH-NNN` (including `[CROSS-CUTTING]`) has ≥1 `MOD-NNN` mapping (forward), (b) every `MOD-NNN` (except `[EXTERNAL]`) has ≥1 `UTP-NNN-X` test case (backward), (c) no orphaned MOD or UTP identifiers exist.
- **FR-024b**: The validation script MUST support partial validation. If `unit-test.md` is not present, the script MUST validate only the ARCH → MOD forward coverage leg and gracefully skip the MOD → UTP backward checks, exiting with code 0 if forward coverage is complete. This enables CI to run after `/speckit.v-model.module-design` before `/speckit.v-model.unit-test` has been executed.
- **FR-025**: The validation script MUST correctly bypass the `UTP` requirement for `MOD-NNN` items tagged `[EXTERNAL]`, counting them as "covered by integration tests" in the summary.
- **FR-026**: The validation script MUST exit with code 0 on full coverage and code 1 on any gap, with human-readable gap reports suitable for CI logs.
- **FR-027**: The validation script MUST support `--json` output mode for programmatic consumption by the unit test command.
- **FR-028**: The extension MUST provide `validate-module-coverage.ps1` (PowerShell) with identical behavior, output format, exit codes, and `[EXTERNAL]` bypass logic as the Bash script.

**Traceability & Matrix:**

- **FR-029**: The `/speckit.v-model.trace` command MUST be extended to produce four complementary matrices when module-level artifacts exist: **Matrix A (Validation)** — `REQ → ATP → SCN`, **Matrix B (System Verification)** — `REQ → SYS → STP → STS`, **Matrix C (Integration Verification)** — `SYS → ARCH → ITP → ITS`, and **Matrix D (Implementation Verification)** — `ARCH → MOD → UTP → UTS`, each with independent coverage percentages. In Matrix D, each `ARCH-NNN` cell MUST include a comma-separated list of its parent `SYS-NNN` identifiers in parentheses to provide end-to-end traceability without cross-reference to Matrix C. If the `ARCH-NNN` is tagged `[CROSS-CUTTING]`, Matrix D SHALL output `([CROSS-CUTTING])` in place of the `SYS-NNN` lineage to prevent parsing errors.
- **FR-030**: The extended traceability matrix MUST remain backward compatible — when module-level artifacts are absent, the matrix MUST produce the same v0.3.0 output (Matrix A + B + C only, no Matrix D, no warning).
- **FR-031**: The trace command MUST build matrices progressively: Matrix A alone after acceptance, A+B after system-test, A+B+C after integration-test, A+B+C+D after unit-test.
- **FR-032**: The `build-matrix.sh` and `build-matrix.ps1` scripts MUST be extended to parse `module-design.md`, `unit-test.md`, AND `architecture-design.md` for Matrix D generation. The `architecture-design.md` is required to resolve the ARCH → SYS lineage needed by FR-029 (the parent SYS-NNN annotations in Matrix D), because `module-design.md` only contains ARCH-NNN references, not SYS-NNN.
- **FR-033**: `[EXTERNAL]` modules MUST appear in Matrix D with an `[EXTERNAL]` annotation and "N/A — External" in the UTP/UTS columns instead of a coverage gap.

**Templates & Constraints:**

- **FR-034**: All new templates (`module-design-template.md`, `unit-test-template.md`) MUST be created in the extension's `templates/` directory and referenced by the corresponding commands.
- **FR-035**: All new commands MUST follow the strict translator constraint — when deriving from existing artifacts, the AI MUST NOT invent, infer, or add features not present in the input.
- **FR-036**: The `setup-v-model.sh` and `setup-v-model.ps1` scripts MUST be extended with `--require-module-design` and `--require-unit-test` flags, and MUST detect `module-design.md` and `unit-test.md` in the available documents list.

### Key Entities

- **Module Design (MOD-NNN)**: A low-level specification for a function, class, or script decomposed from one or more architecture modules. Key attributes: ID, Name, Target Source File(s), Parent Architecture Modules (list of ARCH-NNN), Algorithmic Pseudocode, State Machine (or N/A), Data Structures, Error Handling, Tag (`[CROSS-CUTTING]`, `[EXTERNAL]`, or none). Relationship: many-to-many with Architecture Modules; one-to-many with Unit Test Cases.
- **Unit Test Case (UTP-NNN-X)**: A white-box test condition for a module, anchored to a specific module view and ISO 29119-4 technique. Key attributes: ID, Parent Module (MOD-NNN), Description, Target Module View, Test Technique (Statement & Branch Coverage / Boundary Value Analysis / Strict Isolation / State Transition Testing), Dependency & Mock Registry, Validation Condition. Relationship: many-to-one with Modules; one-to-many with Unit Test Scenarios.
- **Unit Test Scenario (UTS-NNN-X#)**: A concrete Arrange/Act/Assert scenario targeting specific lines of code, branches, variables, or memory states. Uses **white-box, implementation-oriented language** referencing internal code paths (e.g., "Arrange: Set buffer_size to 256 and input_length to 257, Act: Call parse_sensor_data(), Assert: Returns ERROR_OVERFLOW"). Key attributes: ID, Parent Test Case (UTP-NNN-X), Arrange/Act/Assert steps, Test Data, Expected Behavior. Relationship: many-to-one with Unit Test Cases.
- **Dependency & Mock Registry**: A table within each UTP defining the isolation perimeter for the unit test — listing every external dependency the module has and exactly how it is mocked/stubbed. Prevents accidental integration in unit tests.
- **Extended Traceability Matrix**: The audit artifact with four complementary matrices: Matrix A (Validation — REQ → ATP → SCN), Matrix B (System Verification — REQ → SYS → STP → STS), Matrix C (Integration Verification — SYS → ARCH → ITP → ITS), and Matrix D (Implementation Verification — ARCH → MOD → UTP → UTS). Key attributes per matrix: linked artifacts per layer, Coverage Status, Coverage Percentage. Progressive behavior: A alone after acceptance, A+B after system-test, A+B+C after integration-test, A+B+C+D after unit-test.
- **Module Coverage Report**: The output of `validate-module-coverage.sh` — a summary of forward coverage (ARCH→MOD), backward coverage (MOD→UTP with `[EXTERNAL]` bypass), orphan detection, and overall pass/fail status with exit codes suitable for CI enforcement.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Running `/speckit.v-model.module-design` on any valid `architecture-design.md` produces a `module-design.md` containing all four mandatory views where `validate-module-coverage.sh` confirms 100% ARCH→MOD forward coverage.
- **SC-002**: Running `/speckit.v-model.unit-test` on any valid `module-design.md` produces a `unit-test.md` where: (a) `validate-module-coverage.sh` confirms 100% MOD→UTP backward coverage (with correct `[EXTERNAL]` bypass) and zero orphans, (b) every test case explicitly names one of the four mandatory white-box techniques, and (c) every test case includes a Dependency & Mock Registry table.
- **SC-003**: The ID lineage encoding is machine-parseable — given any `UTS-NNN-X#` ID, a regex can extract the parent `UTP-NNN-X` and grandparent `MOD-NNN` without consulting any lookup table. To resolve the `ARCH-NNN` ancestry, the script consults the "Parent Architecture Modules" field in `module-design.md` (required by many-to-many ARCH↔MOD relationships).
- **SC-004**: The extended traceability output includes four matrices (A+B+C+D) with independent coverage percentages that match the deterministic script outputs, completing the full V-Model chain.
- **SC-005**: All BATS tests for `validate-module-coverage.sh` pass with 100% fixture coverage (valid, gap, orphan, external-bypass, empty, large-input scenarios).
- **SC-006**: All Pester tests for `validate-module-coverage.ps1` pass with identical results as the BATS tests on the same fixture data.
- **SC-007**: (Internal QA gate) The extension's CI evaluation suite confirms that the new module design and unit test commands produce outputs meeting quality thresholds — pseudocode concreteness, technique coverage, mock registry completeness, and `[EXTERNAL]` bypass correctness.
- **SC-008**: The extension's `extension.yml` registers 9 commands (7 existing + 2 new) and 1 hook, and the version is bumped to `0.4.0`.
- **SC-009**: Backward compatibility verified — running any v0.3.0 command on existing artifacts produces identical output before and after the v0.4.0 update.

### Assumptions

- Users already have a valid `architecture-design.md` generated by `/speckit.v-model.architecture-design` (v0.3.0). The module design command does not generate architecture designs — it decomposes architecture modules into implementation-level specifications.
- The many-to-many ARCH↔MOD relationship is documented in the module design template via a "Parent Architecture Modules" field, not inferred at runtime. Each `MOD-NNN` entry explicitly lists its parent `ARCH-NNN` IDs.
- The `validate-module-coverage.sh` script uses regex-based parsing (consistent with `validate-architecture-coverage.sh` from v0.3.0) — it does not require a runtime database or external tooling.
- Backward compatibility with v0.3.0 artifacts is mandatory — existing artifacts MUST NOT be modified by any v0.4.0 command.
- Safety-critical sections (MISRA constraints, MC/DC, variable-level fault injection) are optional and activated by domain configuration in `v-model-config.yml`. Projects not targeting regulated domains get the four mandatory views/techniques without the safety additions.
- The unit test command generates **specification-level test cases**, not executable test code. The generated `UTS-NNN-X#` scenarios are designed to be consumed by `/speckit.implement`, which writes the actual test code (TDD: tests first, then implementation).
- The `[EXTERNAL]` tag applies to the third-party library internals, not the wrapper. If a wrapper contains meaningful logic (retry policy, circuit breaker), that logic IS documented in MOD and unit-tested. Only the library's internal algorithm is bypassed.
