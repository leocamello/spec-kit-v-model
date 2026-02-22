# Traceability Matrix

**Generated**: 2026-02-22
**Source**: `specs/004-module-unit/v-model//`

## Matrix A — Validation (User View)

| Requirement ID | Requirement Description | Test Case ID (ATP) | Validation Condition | Scenario ID (SCN) | Status |
|----------------|------------------------|--------------------|----------------------|--------------------|--------|
| **REQ-001** | The extension SHALL provide a `/speckit.v-model.module-design` command that reads `architecture-design.md` as input and produces `module-design.md` as output containing `MOD-NNN` identifiers organized into four mandatory views. | ATP-001-A | Happy Path — Command Produces module-design.md | SCN-001-A1 | ⬜ Untested |
| | | ATP-001-B | Error — Missing architecture-design.md | SCN-001-B1 | ⬜ Untested |
| **REQ-002** | The `/speckit.v-model.module-design` command SHALL assign each module a unique `MOD-NNN` identifier (3-digit zero-padded, e.g., `MOD-001`, `MOD-012`), sequentially numbered and never renumbered once assigned. | ATP-002-A | Sequential MOD-NNN Format | SCN-002-A1 | ⬜ Untested |
| | | ATP-002-B | Identifier Permanence on Re-run | SCN-002-B1 | ⬜ Untested |
| **REQ-003** | The `module-design.md` output SHALL include an **Algorithmic / Logic View** containing step-by-step pseudocode enclosed in fenced Markdown code blocks tagged `pseudocode` (i.e., ` ```pseudocode ... ``` `) defining exactly how each module transforms inputs into outputs, with every branch, loop, and decision point explicit. | ATP-003-A | Fenced Pseudocode Block Present | SCN-003-A1 | ⬜ Untested |
| **REQ-004** | Each `MOD-NNN` item SHALL include a **Target Source File(s)** property mapping the module to one or more physical file paths in the repository (e.g., `src/sensor/parser.py` or `src/sensor/parser.h, src/sensor/parser.cpp`), with comma-separated paths supported for languages where a single module spans multiple files (header/implementation pairs). | ATP-004-A | Single Source File Mapping | SCN-004-A1 | ⬜ Untested |
| | | ATP-004-B | Comma-Separated Multi-File Mapping | SCN-004-B1 | ⬜ Untested |
| **REQ-005** | The `module-design.md` output SHALL include a **State Machine View** using Mermaid `stateDiagram-v2` syntax for stateful modules. | ATP-005-A | Stateful Module Has Mermaid Diagram | SCN-005-A1 | ⬜ Untested |
| **REQ-006** | Stateless modules SHALL be marked with a bypass string in the State Machine View that is detectable by a broad, case-insensitive regex pattern (e.g., `(?i)N/?A.*Stateless`). Validation scripts SHALL use this broad pattern rather than exact string matching to accommodate minor LLM punctuation variance (em-dash vs. hyphen, casing differences). | ATP-006-A | Stateless Module Bypasses Mermaid Requirement | SCN-006-A1 | ⬜ Untested |
| **REQ-007** | The `module-design.md` output SHALL include an **Internal Data Structures** section documenting local variables, constants, buffers, and object classes with explicit types, sizes, and constraints (e.g., "buffer is exactly 256 bytes, uint8_t array, initialized to 0x00"). | ATP-007-A | Data Structures with Types, Sizes, Constraints | SCN-007-A1 | ⬜ Untested |
| **REQ-008** | The `module-design.md` output SHALL include an **Error Handling & Return Codes** section documenting exactly how each module catches exceptions internally and formats them to honor the contract defined in the Architecture Interface View. | ATP-008-A | Error Handling Maps to Architecture Interface View | SCN-008-A1 | ⬜ Untested |
| **REQ-009** | Each `MOD-NNN` item SHALL trace to one or more `ARCH-NNN` identifiers via an explicit "Parent Architecture Modules" field. | ATP-009-A | Explicit ARCH-NNN Traceability | SCN-009-A1 | ⬜ Untested |
| **REQ-010** | The module design command SHALL support many-to-many ARCH↔MOD relationships: a single `ARCH-NNN` MAY map to multiple `MOD-NNN` items, and a single `MOD-NNN` MAY satisfy multiple `ARCH-NNN` modules. | ATP-010-A | One ARCH Maps to Multiple MODs | SCN-010-A1 | ⬜ Untested |
| | | ATP-010-B | One MOD Satisfies Multiple ARCHs | SCN-010-B1 | ⬜ Untested |
| **REQ-011** | `ARCH-NNN` modules tagged `[CROSS-CUTTING]` in the architecture design SHALL be fully decomposed into `MOD-NNN` items with complete pseudocode, inheriting the `[CROSS-CUTTING]` tag. Infrastructure code (loggers, error handlers, thread pools) requires the same rigor as business logic. | ATP-011-A | Cross-Cutting Module Gets Complete Pseudocode | SCN-011-A1 | ⬜ Untested |
| **REQ-012** | If an `ARCH-NNN` module represents a third-party library wrapper, the module design command SHALL tag the resulting `MOD-NNN` as `[EXTERNAL]` and document only the wrapper/configuration interface (connection parameters, retry policy, timeout config), omitting deep algorithmic pseudocode of the library internals. | ATP-012-A | External Module Documents Wrapper Only | SCN-012-A1 | ⬜ Untested |
| **REQ-013** | When an `[EXTERNAL]` module's wrapper contains meaningful logic (e.g., retry policy, circuit breaker, connection pooling), that wrapper logic SHALL be documented with pseudocode and unit-tested. Only the third-party library's internal algorithm SHALL be bypassed. | ATP-013-A | Wrapper with Meaningful Logic Gets Pseudocode | SCN-013-A1 | ⬜ Untested |
| **REQ-014** | When the project is configured for a safety-critical domain (DO-178C Level A, ISO 26262, IEC 62304), the module design output SHALL include additional sections: **Complexity Constraints** (cyclomatic complexity ≤ 10 per function, MISRA C/CERT-C rule annotations per module), **Memory Management** (no dynamic allocation after initialization, no unbounded loops), and **Single Entry/Exit** (one return point per function for deterministic execution paths). | ATP-014-A | Safety Sections Present When Configured | SCN-014-A1 | ⬜ Untested |
| **REQ-015** | When the module design process identifies a necessary function or class not traceable to any `ARCH-NNN`, the command SHALL flag it as `[DERIVED MODULE: description]` rather than silently creating a `MOD-NNN`, prompting the user to update `architecture-design.md`. | ATP-015-A | Untraceable Module Flagged as DERIVED | SCN-015-A1 | ⬜ Untested |
| **REQ-016** | The module design Algorithmic/Logic View SHALL NOT contain vague or descriptive prose in place of pseudocode — every `MOD-NNN` (except `[EXTERNAL]`) SHALL contain a fenced ` ```pseudocode ``` ` code block. The absence of this block SHALL be flagged as a structural failure by deterministic validators. | ATP-016-A | Structural Validation of Pseudocode Blocks | SCN-016-A1 | ⬜ Untested |
| **REQ-017** | The extension SHALL provide a `/speckit.v-model.unit-test` command that reads `module-design.md` as input and produces `unit-test.md` as output containing `UTP-NNN-X` test cases and `UTS-NNN-X#` test scenarios. | ATP-017-A | Happy Path — Command Produces unit-test.md | SCN-017-A1 | ⬜ Untested |
| | | ATP-017-B | Error — Missing module-design.md | SCN-017-B1 | ⬜ Untested |
| **REQ-018** | The `/speckit.v-model.unit-test` command SHALL assign test case identifiers using the format `UTP-NNN-X` (e.g., `UTP-001-A`) where NNN matches the parent `MOD-NNN` and X is a sequential uppercase letter. | ATP-018-A | UTP ID Lineage Encoding | SCN-018-A1 | ⬜ Untested |
| **REQ-019** | The `/speckit.v-model.unit-test` command SHALL assign test scenario identifiers using the format `UTS-NNN-X#` (e.g., `UTS-001-A1`) where NNN-X matches the parent `UTP-NNN-X` and # is a sequential number. | ATP-019-A | UTS ID Lineage Encoding | SCN-019-A1 | ⬜ Untested |
| **REQ-020** | Each unit test case (`UTP-NNN-X`) SHALL apply one of the mandatory ISO 29119-4 white-box techniques: **Statement & Branch Coverage** (execute every line and every True/False branch), **Boundary Value Analysis** (at the variable level: min, min-1, mid, max, max+1 for scalar ordered types), **Equivalence Partitioning** (for discrete non-scalar types — Booleans, Enums — where numeric boundaries do not logically exist), **Strict Isolation** (every external dependency mocked), or **State Transition Testing** (every state transition including invalid ones). | ATP-020-A | Technique Named per Test Case | SCN-020-A1 | ⬜ Untested |
| | | ATP-020-B | EP Applied to Non-Scalar Types Instead of BVA | SCN-020-B1 | ⬜ Untested |
| **REQ-021** | Each unit test case (`UTP-NNN-X`) SHALL explicitly name its technique and reference the specific module view that drives it (Algorithmic/Logic View for Statement & Branch Coverage, Internal Data Structures for BVA/EP, Architecture Interface View for Strict Isolation, State Machine View for State Transition Testing). | ATP-021-A | Technique-View Pairing | SCN-021-A1 | ⬜ Untested |
| **REQ-022** | Each unit test case (`UTP-NNN-X`) SHALL include a **Dependency & Mock Registry** table explicitly listing all external dependencies the module has (from Architecture Interface View) and exactly how each is mocked/stubbed (e.g., `Mock: DatabaseConnection → Returns static JSON`). | ATP-022-A | Mock Registry Present per UTP | SCN-022-A1 | ⬜ Untested |
| **REQ-023** | The Dependency & Mock Registry SHALL explicitly include hardware interfaces (e.g., GPIO pins, memory-mapped registers, I2C/SPI buses) as dependencies that require mocking/stubbing — LLMs often fail to recognize hardware registers as "dependencies" in embedded contexts. | ATP-023-A | GPIO/I2C/SPI Listed as Dependencies | SCN-023-A1 | ⬜ Untested |
| **REQ-024** | When a `MOD-NNN` has no external dependencies, the Dependency & Mock Registry SHALL show "None — module is self-contained" and the unit test SHALL proceed with direct invocation (no mocking needed). | ATP-024-A | No Dependencies — Registry Shows None | SCN-024-A1 | ⬜ Untested |
| **REQ-025** | Unit test scenarios (`UTS-NNN-X#`) SHALL use Arrange/Act/Assert structure with **white-box, implementation-oriented language** referencing internal code paths, variables, and branches (e.g., "Arrange: Set buffer_size to 256 and input_length to 257, Act: Call parse_sensor_data(), Assert: Returns ERROR_OVERFLOW and buffer remains unchanged"), distinct from black-box acceptance or integration-level boundary language. | ATP-025-A | Implementation-Oriented Language in UTS | SCN-025-A1 | ⬜ Untested |
| **REQ-026** | The unit test command SHALL NOT generate unit test cases for `MOD-NNN` items tagged `[EXTERNAL]`. Each skipped module SHALL be noted: "Module MOD-NNN is [EXTERNAL] — wrapper behavior tested at integration level." | ATP-026-A | No UTP Generated for EXTERNAL Modules | SCN-026-A1 | ⬜ Untested |
| **REQ-027** | When the project is configured for a safety-critical domain (DO-178C Level A, ISO 26262 ASIL-D), the unit test output SHALL include additional techniques: **MC/DC (Modified Condition/Decision Coverage)** with explicit boolean truth tables for complex conditional branches proving each individual condition can independently affect the decision outcome, and **Variable-Level Fault Injection** forcing local variables into corrupted states to verify internal error handling. | ATP-027-A | MC/DC Truth Tables Generated | SCN-027-A1 | ⬜ Untested |
| | | ATP-027-B | Variable-Level Fault Injection Scenarios | SCN-027-B1 | ⬜ Untested |
| **REQ-028** | The unit test command SHALL invoke `validate-module-coverage.sh` as a post-generation coverage gate and include the validation result (pass/fail with coverage summary) in its output. | ATP-028-A | Coverage Validation Runs After Generation | SCN-028-A1 | ⬜ Untested |
| **REQ-029** | The unit test command SHALL NOT generate tests for user-journey scenarios, integration-level module boundaries, or system-level behavior — only tests that verify internal module logic, branches, data transformations, and state transitions. | ATP-029-A | Unit Tests Target Internal Logic Only | SCN-029-A1 | ⬜ Untested |
| **REQ-030** | For stateful modules with a State Machine View, the State Transition Testing technique SHALL cover every defined transition (including invalid transitions that should be rejected) as defined in the module design. | ATP-030-A | Invalid Transitions Tested | SCN-030-A1 | ⬜ Untested |
| **REQ-031** | The ID lineage encoding SHALL be consistent within the module tier: given any `UTS-NNN-X#` identifier, a regex SHALL be able to extract the parent `UTP-NNN-X` and grandparent `MOD-NNN` without consulting any lookup table. | ATP-031-A | Regex Extracts UTP and MOD from UTS ID | SCN-031-A1 | ⬜ Untested |
| **REQ-032** | To resolve the `ARCH-NNN` ancestor(s) from a `MOD-NNN` identifier, the script SHALL consult the "Parent Architecture Modules" field in `module-design.md`, because many-to-many ARCH↔MOD relationships (REQ-010) make it mathematically impossible to derive the ARCH parent from the ID string alone. | ATP-032-A | ARCH Ancestry Resolved via Parent Field | SCN-032-A1 | ⬜ Untested |
| **REQ-033** | The extension SHALL provide a `validate-module-coverage.sh` Bash script that deterministically validates forward coverage: every `ARCH-NNN` (including `[CROSS-CUTTING]`) in `architecture-design.md` has at least one corresponding `MOD-NNN` in `module-design.md`. | ATP-033-A | All ARCH Modules Have MOD Mappings | SCN-033-A1 | ⬜ Untested |
| | | ATP-033-B | Missing MOD Mapping Detected | SCN-033-B1 | ⬜ Untested |
| **REQ-034** | The `validate-module-coverage.sh` script SHALL deterministically validate backward coverage: every `MOD-NNN` (except `[EXTERNAL]`) in `module-design.md` has at least one corresponding `UTP-NNN-X` in `unit-test.md`. | ATP-034-A | All Non-EXTERNAL MODs Have UTP Mappings | SCN-034-A1 | ⬜ Untested |
| | | ATP-034-B | Missing UTP Mapping Detected | SCN-034-B1 | ⬜ Untested |
| **REQ-035** | The `validate-module-coverage.sh` script SHALL correctly bypass the `UTP` requirement for `MOD-NNN` items tagged `[EXTERNAL]`, counting them as "covered by integration tests" in the summary rather than flagging them as gaps. | ATP-035-A | EXTERNAL Module Counted as Covered | SCN-035-A1 | ⬜ Untested |
| **REQ-036** | The `validate-module-coverage.sh` script SHALL support partial validation: if `unit-test.md` is not present, it SHALL validate only the ARCH → MOD forward coverage leg and gracefully skip the MOD → UTP backward checks, exiting with code 0 if forward coverage is complete. | ATP-036-A | Forward-Only Validation When unit-test.md Absent | SCN-036-A1 | ⬜ Untested |
| **REQ-037** | The `validate-module-coverage.sh` script SHALL detect and report orphaned identifiers: any `MOD-NNN` whose parent `ARCH-NNN` does not exist in `architecture-design.md`, and any `UTP-NNN-X` whose parent `MOD-NNN` does not exist in `module-design.md`. | ATP-037-A | Orphaned MOD Detected | SCN-037-A1 | ⬜ Untested |
| | | ATP-037-B | Orphaned UTP Detected | SCN-037-B1 | ⬜ Untested |
| **REQ-038** | The `validate-module-coverage.sh` script SHALL exit with code 0 when all applicable coverage checks pass and code 1 when any gap or orphan is detected. | ATP-038-A | Exit Code 0 on Full Coverage | SCN-038-A1 | ⬜ Untested |
| | | ATP-038-B | Exit Code 1 on Coverage Gap | SCN-038-B1 | ⬜ Untested |
| **REQ-039** | The `validate-module-coverage.sh` script SHALL output human-readable gap reports listing each specific gap or orphan by ID (e.g., "ARCH-003: no module design mapping found") suitable for CI log inspection. | ATP-039-A | Specific IDs Listed in Gap Report | SCN-039-A1 | ⬜ Untested |
| **REQ-040** | The `validate-module-coverage.sh` script SHALL support `--json` output mode for programmatic consumption by the unit test command. | ATP-040-A | --json Flag Produces Machine-Readable Output | SCN-040-A1 | ⬜ Untested |
| **REQ-041** | The `/speckit.v-model.module-design` command SHALL follow the strict translator constraint: when deriving from `architecture-design.md`, the AI SHALL NOT invent, infer, or add modules for capabilities not present in the architecture design. | ATP-041-A | No Invented Modules | SCN-041-A1 | ⬜ Untested |
| **REQ-042** | The `/speckit.v-model.unit-test` command SHALL follow the strict translator constraint: when deriving from `module-design.md`, the AI SHALL NOT invent test cases for modules or logic not present in the module design. | ATP-042-A | No Invented Test Cases | SCN-042-A1 | ⬜ Untested |
| **REQ-043** | The module design command SHALL fail gracefully with a clear error message ("No architecture modules found in architecture-design.md — cannot generate module design") when `architecture-design.md` is empty or contains zero `ARCH-NNN` identifiers. | ATP-043-A | Clear Error for Empty architecture-design.md | SCN-043-A1 | ⬜ Untested |
| **REQ-044** | The `setup-v-model.sh` script SHALL be extended with `--require-module-design` and `--require-unit-test` flags that verify the respective files exist before proceeding. | ATP-044-A | --require-module-design Flag Validates Existence | SCN-044-A1 | ⬜ Untested |
| | | ATP-044-B | --require-unit-test Flag Validates Existence | SCN-044-B1 | ⬜ Untested |
| **REQ-045** | The `setup-v-model.sh` and `setup-v-model.ps1` scripts SHALL detect `module-design.md` and `unit-test.md` in the available documents list (`AVAILABLE_DOCS`). | ATP-045-A | module-design.md and unit-test.md in AVAILABLE_DOCS | SCN-045-A1 | ⬜ Untested |
| **REQ-046** | The `/speckit.v-model.trace` command SHALL be extended to produce **Matrix D (Implementation Verification)** — `ARCH → MOD → UTP → UTS` — when `module-design.md` and `unit-test.md` exist in the feature directory. | ATP-046-A | Matrix D Produced When Module Artifacts Exist | SCN-046-A1 | ⬜ Untested |
| **REQ-047** | In Matrix D, each `ARCH-NNN` cell SHALL include a comma-separated list of its parent `SYS-NNN` identifiers in parentheses (e.g., `ARCH-001 (SYS-001, SYS-003)`) to provide end-to-end traceability without cross-reference to Matrix C. | ATP-047-A | ARCH Cell Includes SYS Parenthetical | SCN-047-A1 | ⬜ Untested |
| **REQ-048** | If the `ARCH-NNN` is tagged `[CROSS-CUTTING]`, Matrix D SHALL output `([CROSS-CUTTING])` in place of the `SYS-NNN` lineage annotation to prevent parsing errors. | ATP-048-A | Cross-Cutting Shows Tag Instead of SYS | SCN-048-A1 | ⬜ Untested |
| **REQ-049** | `[EXTERNAL]` modules SHALL appear in Matrix D with an `[EXTERNAL]` annotation in the MOD column and "N/A — External" in the UTP/UTS columns instead of a coverage gap. | ATP-049-A | External Module Shows N/A in UTP/UTS Columns | SCN-049-A1 | ⬜ Untested |
| **REQ-050** | The `/speckit.v-model.trace` command SHALL produce **Matrix A (Validation)**, **Matrix B (System Verification)**, **Matrix C (Integration Verification)**, and **Matrix D (Implementation Verification)** as separate tables with independent coverage percentages. | ATP-050-A | Four Distinct Matrix Tables | SCN-050-A1 | ⬜ Untested |
| **REQ-051** | The `/speckit.v-model.trace` command SHALL remain backward compatible: when module-level artifacts are absent, the command SHALL produce the same v0.3.0 output (Matrix A + B + C only, no Matrix D, no warning). | ATP-051-A | v0.3.0 Output Preserved When Module Artifacts Absent | SCN-051-A1 | ⬜ Untested |
| **REQ-052** | The `/speckit.v-model.trace` command SHALL build matrices progressively: Matrix A alone after acceptance, A+B after system-test, A+B+C after integration-test, A+B+C+D after unit-test. | ATP-052-A | Matrices Build Progressively | SCN-052-A1 | ⬜ Untested |
| | | ATP-052-A | Matrices Build Progressively | SCN-052-A2 | ⬜ Untested |
| | | ATP-052-A | Matrices Build Progressively | SCN-052-A3 | ⬜ Untested |
| | | ATP-052-A | Matrices Build Progressively | SCN-052-A4 | ⬜ Untested |
| **REQ-053** | Each matrix SHALL include an independently calculated coverage percentage that matches the output of the corresponding deterministic validation script. | ATP-053-A | Matrix Percentages Match Validation Scripts | SCN-053-A1 | ⬜ Untested |
| **REQ-054** | The `build-matrix.sh` script SHALL be extended to parse `module-design.md`, `unit-test.md`, AND `architecture-design.md` for Matrix D generation. The `architecture-design.md` is required to resolve the ARCH → SYS lineage needed by REQ-047, because `module-design.md` only contains ARCH-NNN references, not SYS-NNN. | ATP-054-A | Matrix D Requires Three Input Files | SCN-054-A1 | ⬜ Untested |
| **REQ-055** | When `module-design.md` exists but `unit-test.md` does not, the trace command SHALL include the MOD column in Matrix D but leave the UTP/UTS columns empty with a note ("Unit test plan not yet generated"). | ATP-055-A | MOD Column Present, UTP/UTS Empty | SCN-055-A1 | ⬜ Untested |
| **REQ-056** | The extension SHALL provide a `module-design-template.md` in the `templates/` directory defining the required structure for DO-178C/ISO 26262-compliant module design output with four mandatory views, Target Source File(s) property, and `[EXTERNAL]` section. | ATP-056-A | Template Exists with Required Structure | SCN-056-A1 | ⬜ Untested |
| **REQ-057** | The extension SHALL provide a `unit-test-template.md` in the `templates/` directory defining the required structure for ISO 29119-4-compliant white-box unit test output with the three-tier UTP/UTS hierarchy and Dependency & Mock Registry per test case. | ATP-057-A | Template Exists with Required Structure | SCN-057-A1 | ⬜ Untested |
| **REQ-CN-001** | Safety-critical sections (Complexity Constraints, Memory Management, Single Entry/Exit, MC/DC, Variable-Level Fault Injection) SHALL be omitted by default and only included when the project's `v-model-config.yml` explicitly enables a regulated domain (DO-178C, ISO 26262, or IEC 62304). | ATP-CN-001-A | Safety Sections Omitted by Default | SCN-CN-001-A1 | ⬜ Untested |
| | | ATP-CN-001-B | Safety Sections Included When Configured | SCN-CN-001-B1 | ⬜ Untested |
| **REQ-CN-002** | The extension version in `extension.yml` SHALL be bumped to `0.4.0` and SHALL register exactly 9 commands (7 existing + 2 new) and 1 hook. | ATP-CN-002-A | extension.yml Updated Correctly | SCN-CN-002-A1 | ⬜ Untested |
| **REQ-CN-003** | The extension SHALL provide `validate-module-coverage.ps1` (PowerShell) with identical behavior, output format, exit codes, `[EXTERNAL]` bypass logic, and partial validation support as the Bash script, passing the same test fixture suite. | ATP-CN-003-A | Identical Behavior and Output | SCN-CN-003-A1 | ⬜ Untested |
| **REQ-CN-004** | The `[EXTERNAL]` tag SHALL be the single canonical tag for third-party library wrappers. No alternative tags (e.g., `[COTS]`) SHALL be recognized by validation scripts, templates, or commands. | ATP-CN-004-A | Only EXTERNAL Tag Recognized | SCN-CN-004-A1 | ⬜ Untested |
| **REQ-CN-005** | The `build-matrix.ps1` script SHALL be extended with identical Matrix D generation logic as `build-matrix.sh`, including the three-file parsing requirement (REQ-054). | ATP-CN-005-A | build-matrix.ps1 Matrix D Logic | SCN-CN-005-A1 | ⬜ Untested |
| **REQ-IF-001** | The `/speckit.v-model.module-design` command SHALL read its input exclusively from `{FEATURE_DIR}/v-model/architecture-design.md` and write its output exclusively to `{FEATURE_DIR}/v-model/module-design.md`. | ATP-IF-001-A | Reads from architecture-design.md, Writes to module-design.md | SCN-IF-001-A1 | ⬜ Untested |
| **REQ-IF-002** | The `/speckit.v-model.unit-test` command SHALL read its input exclusively from `{FEATURE_DIR}/v-model/module-design.md` and write its output exclusively to `{FEATURE_DIR}/v-model/unit-test.md`. | ATP-IF-002-A | Reads from module-design.md, Writes to unit-test.md | SCN-IF-002-A1 | ⬜ Untested |
| **REQ-IF-003** | The `validate-module-coverage.sh` script SHALL accept three file paths as arguments: `architecture-design.md`, `module-design.md`, and `unit-test.md`, in that order. When `unit-test.md` is omitted, the script SHALL operate in partial validation mode (REQ-036). | ATP-IF-003-A | Three File Paths Accepted | SCN-IF-003-A1 | ⬜ Untested |
| | | ATP-IF-003-B | Partial Mode — Two Arguments | SCN-IF-003-B1 | ⬜ Untested |
| **REQ-IF-004** | The `validate-module-coverage.sh` script SHALL output a structured coverage summary to stdout in the same format as `validate-architecture-coverage.sh` (section headers, gap lists, pass/fail verdict, coverage percentages). | ATP-IF-004-A | Consistent Output Format | SCN-IF-004-A1 | ⬜ Untested |
| **REQ-NF-001** | The `validate-module-coverage.sh` script SHALL use regex-based parsing consistent with `validate-architecture-coverage.sh` from v0.3.0, requiring no runtime database or external tooling beyond standard Bash utilities. | ATP-NF-001-A | No External Tooling Required | SCN-NF-001-A1 | ⬜ Untested |
| **REQ-NF-002** | The `/speckit.v-model.module-design` and `/speckit.v-model.unit-test` commands SHALL handle input files with 50 or more `ARCH-NNN` identifiers without truncation, data loss, or degraded output quality. | ATP-NF-002-A | 50+ ARCH Modules Processed | SCN-NF-002-A1 | ⬜ Untested |
| **REQ-NF-003** | The `validate-module-coverage.sh` script SHALL accept gaps in `MOD-NNN` numbering (e.g., MOD-001, MOD-003 without MOD-002) without reporting false-positive errors. | ATP-NF-003-A | Gaps in MOD Numbering Accepted | SCN-NF-003-A1 | ⬜ Untested |
| **REQ-NF-004** | All v0.4.0 commands and scripts SHALL preserve backward compatibility: existing `architecture-design.md`, `integration-test.md`, `system-design.md`, `system-test.md`, `requirements.md`, `acceptance-plan.md`, and `traceability-matrix.md` files SHALL NOT be modified by any v0.4.0 operation. | ATP-NF-004-A | Existing v0.3.0 Artifacts Unchanged | SCN-NF-004-A1 | ⬜ Untested |
| **REQ-NF-005** | (Internal QA gate — not user-facing) The extension's CI evaluation suite SHALL validate that `/speckit.v-model.module-design` and `/speckit.v-model.unit-test` command outputs meet quality thresholds — pseudocode concreteness (fenced ` ```pseudocode ``` ` block presence), technique coverage, mock registry completeness, `[EXTERNAL]` bypass correctness, and State Machine View validity (Mermaid syntax for stateful, broad stateless bypass detection for stateless). | ATP-NF-005-A | Structural Quality Thresholds Met | SCN-NF-005-A1 | ⬜ Untested |

### Matrix A Coverage

| Metric | Value |
|--------|-------|
| **Total Requirements** | 71 |
| **Total Test Cases (ATP)** | 85 |
| **Total Scenarios (SCN)** | 88 |
| **REQ → ATP Coverage** | 71/71 (100%) |
| **ATP → SCN Coverage** | 85/85 (100%) |

## Matrix B — Verification (Architectural View)

| Requirement ID | System Component (SYS) | Component Name | Test Case ID (STP) | Technique | Scenario ID (STS) | Status |
|----------------|------------------------|----------------|--------------------|-----------|--------------------|--------|
| **REQ-001** | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A5 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A6 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A7 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D4 | ⬜ Untested |
| **REQ-002** | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A5 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A6 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A7 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D4 | ⬜ Untested |
| **REQ-003** | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A5 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A6 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A7 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D4 | ⬜ Untested |
| | SYS-004 | Module Design Template | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Module Design Template | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Module Design Template | STP-004-A | Interface Contract Testing | STS-004-A3 | ⬜ Untested |
| **REQ-004** | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A5 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A6 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A7 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D4 | ⬜ Untested |
| | SYS-004 | Module Design Template | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Module Design Template | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Module Design Template | STP-004-A | Interface Contract Testing | STS-004-A3 | ⬜ Untested |
| **REQ-005** | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A5 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A6 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A7 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D4 | ⬜ Untested |
| | SYS-004 | Module Design Template | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Module Design Template | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Module Design Template | STP-004-A | Interface Contract Testing | STS-004-A3 | ⬜ Untested |
| **REQ-006** | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A5 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A6 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A7 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D4 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D2 | ⬜ Untested |
| | SYS-004 | Module Design Template | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Module Design Template | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Module Design Template | STP-004-A | Interface Contract Testing | STS-004-A3 | ⬜ Untested |
| **REQ-007** | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A5 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A6 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A7 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D4 | ⬜ Untested |
| | SYS-004 | Module Design Template | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Module Design Template | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Module Design Template | STP-004-A | Interface Contract Testing | STS-004-A3 | ⬜ Untested |
| **REQ-008** | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A5 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A6 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A7 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D4 | ⬜ Untested |
| | SYS-004 | Module Design Template | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Module Design Template | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Module Design Template | STP-004-A | Interface Contract Testing | STS-004-A3 | ⬜ Untested |
| **REQ-009** | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A5 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A6 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A7 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D4 | ⬜ Untested |
| **REQ-010** | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A5 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A6 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A7 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D4 | ⬜ Untested |
| **REQ-011** | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A5 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A6 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A7 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D4 | ⬜ Untested |
| **REQ-012** | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A5 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A6 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A7 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D4 | ⬜ Untested |
| **REQ-013** | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A5 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A6 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A7 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D4 | ⬜ Untested |
| **REQ-014** | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A5 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A6 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A7 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D4 | ⬜ Untested |
| | SYS-004 | Module Design Template | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Module Design Template | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Module Design Template | STP-004-A | Interface Contract Testing | STS-004-A3 | ⬜ Untested |
| **REQ-015** | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A5 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A6 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A7 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D4 | ⬜ Untested |
| **REQ-016** | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A5 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A6 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A7 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D4 | ⬜ Untested |
| **REQ-017** | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A10 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A6 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A7 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A8 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A9 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D3 | ⬜ Untested |
| **REQ-018** | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A10 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A6 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A7 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A8 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A9 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D3 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A3 | ⬜ Untested |
| **REQ-019** | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A10 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A6 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A7 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A8 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A9 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D3 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A3 | ⬜ Untested |
| **REQ-020** | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A10 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A6 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A7 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A8 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A9 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D3 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A3 | ⬜ Untested |
| **REQ-021** | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A10 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A6 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A7 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A8 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A9 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D3 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A3 | ⬜ Untested |
| **REQ-022** | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A10 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A6 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A7 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A8 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A9 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D3 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A3 | ⬜ Untested |
| **REQ-023** | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A10 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A6 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A7 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A8 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A9 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D3 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A3 | ⬜ Untested |
| **REQ-024** | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A10 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A6 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A7 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A8 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A9 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D3 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A3 | ⬜ Untested |
| **REQ-025** | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A10 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A6 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A7 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A8 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A9 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D3 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A3 | ⬜ Untested |
| **REQ-026** | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A10 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A6 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A7 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A8 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A9 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D3 | ⬜ Untested |
| **REQ-027** | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A10 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A6 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A7 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A8 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A9 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D3 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A3 | ⬜ Untested |
| **REQ-028** | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A10 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A6 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A7 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A8 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A9 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D3 | ⬜ Untested |
| **REQ-029** | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A10 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A6 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A7 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A8 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A9 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D3 | ⬜ Untested |
| **REQ-030** | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A10 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A6 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A7 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A8 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A9 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D3 | ⬜ Untested |
| **REQ-031** | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A10 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A6 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A7 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A8 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A9 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D2 | ⬜ Untested |
| **REQ-032** | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A10 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A6 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A7 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A8 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A9 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D2 | ⬜ Untested |
| **REQ-033** | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D2 | ⬜ Untested |
| **REQ-034** | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D2 | ⬜ Untested |
| **REQ-035** | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D2 | ⬜ Untested |
| **REQ-036** | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D2 | ⬜ Untested |
| **REQ-037** | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D2 | ⬜ Untested |
| **REQ-038** | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D2 | ⬜ Untested |
| **REQ-039** | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D2 | ⬜ Untested |
| **REQ-040** | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D2 | ⬜ Untested |
| **REQ-041** | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A5 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A6 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A7 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D4 | ⬜ Untested |
| **REQ-042** | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A10 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A6 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A7 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A8 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A9 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D3 | ⬜ Untested |
| **REQ-043** | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A5 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A6 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A7 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D4 | ⬜ Untested |
| **REQ-044** | SYS-009 | Setup Script Extensions | STP-009-A | Interface Contract Testing | STS-009-A1 | ⬜ Untested |
| | SYS-009 | Setup Script Extensions | STP-009-A | Interface Contract Testing | STS-009-A2 | ⬜ Untested |
| | SYS-009 | Setup Script Extensions | STP-009-A | Interface Contract Testing | STS-009-A3 | ⬜ Untested |
| | SYS-009 | Setup Script Extensions | STP-009-B | Equivalence Partitioning | STS-009-B1 | ⬜ Untested |
| | SYS-009 | Setup Script Extensions | STP-009-B | Equivalence Partitioning | STS-009-B2 | ⬜ Untested |
| **REQ-045** | SYS-009 | Setup Script Extensions | STP-009-A | Interface Contract Testing | STS-009-A1 | ⬜ Untested |
| | SYS-009 | Setup Script Extensions | STP-009-A | Interface Contract Testing | STS-009-A2 | ⬜ Untested |
| | SYS-009 | Setup Script Extensions | STP-009-A | Interface Contract Testing | STS-009-A3 | ⬜ Untested |
| | SYS-009 | Setup Script Extensions | STP-009-B | Equivalence Partitioning | STS-009-B1 | ⬜ Untested |
| | SYS-009 | Setup Script Extensions | STP-009-B | Equivalence Partitioning | STS-009-B2 | ⬜ Untested |
| **REQ-046** | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A3 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A4 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B3 | ⬜ Untested |
| **REQ-047** | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A3 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A4 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B3 | ⬜ Untested |
| **REQ-048** | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A3 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A4 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B3 | ⬜ Untested |
| **REQ-049** | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A3 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A4 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B3 | ⬜ Untested |
| **REQ-050** | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A3 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A4 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B3 | ⬜ Untested |
| **REQ-051** | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A3 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A4 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B3 | ⬜ Untested |
| **REQ-052** | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A3 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A4 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B3 | ⬜ Untested |
| **REQ-053** | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A3 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A4 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B3 | ⬜ Untested |
| | SYS-007 | Matrix Builder Script Extension (Bash) | STP-007-A | Interface Contract Testing | STS-007-A1 | ⬜ Untested |
| | SYS-007 | Matrix Builder Script Extension (Bash) | STP-007-A | Interface Contract Testing | STS-007-A2 | ⬜ Untested |
| | SYS-007 | Matrix Builder Script Extension (Bash) | STP-007-B | Fault Injection | STS-007-B1 | ⬜ Untested |
| **REQ-054** | SYS-007 | Matrix Builder Script Extension (Bash) | STP-007-A | Interface Contract Testing | STS-007-A1 | ⬜ Untested |
| | SYS-007 | Matrix Builder Script Extension (Bash) | STP-007-A | Interface Contract Testing | STS-007-A2 | ⬜ Untested |
| | SYS-007 | Matrix Builder Script Extension (Bash) | STP-007-B | Fault Injection | STS-007-B1 | ⬜ Untested |
| **REQ-055** | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A3 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A4 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B3 | ⬜ Untested |
| **REQ-056** | SYS-004 | Module Design Template | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Module Design Template | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Module Design Template | STP-004-A | Interface Contract Testing | STS-004-A3 | ⬜ Untested |
| **REQ-057** | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Unit Test Template | STP-005-A | Interface Contract Testing | STS-005-A3 | ⬜ Untested |
| **REQ-CN-001** | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A5 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A6 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A7 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D4 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A10 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A6 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A7 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A8 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A9 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D3 | ⬜ Untested |
| **REQ-CN-002** | SYS-011 | Extension Manifest Update | STP-011-A | Interface Contract Testing | STS-011-A1 | ⬜ Untested |
| **REQ-CN-003** | SYS-010 | Module Coverage Validation Script (PowerShell) | STP-010-A | Interface Contract Testing | STS-010-A1 | ⬜ Untested |
| | SYS-010 | Module Coverage Validation Script (PowerShell) | STP-010-A | Interface Contract Testing | STS-010-A2 | ⬜ Untested |
| **REQ-CN-004** | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A5 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A6 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A7 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D4 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A10 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A6 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A7 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A8 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A9 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D2 | ⬜ Untested |
| **REQ-CN-005** | SYS-008 | Matrix Builder Script Extension (PowerShell) | STP-008-A | Interface Contract Testing | STS-008-A1 | ⬜ Untested |
| **REQ-IF-001** | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A5 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A6 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A7 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D4 | ⬜ Untested |
| **REQ-IF-002** | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A10 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A6 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A7 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A8 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A9 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D3 | ⬜ Untested |
| **REQ-IF-003** | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D2 | ⬜ Untested |
| | SYS-010 | Module Coverage Validation Script (PowerShell) | STP-010-A | Interface Contract Testing | STS-010-A1 | ⬜ Untested |
| | SYS-010 | Module Coverage Validation Script (PowerShell) | STP-010-A | Interface Contract Testing | STS-010-A2 | ⬜ Untested |
| **REQ-IF-004** | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D2 | ⬜ Untested |
| | SYS-010 | Module Coverage Validation Script (PowerShell) | STP-010-A | Interface Contract Testing | STS-010-A1 | ⬜ Untested |
| | SYS-010 | Module Coverage Validation Script (PowerShell) | STP-010-A | Interface Contract Testing | STS-010-A2 | ⬜ Untested |
| **REQ-NF-001** | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D2 | ⬜ Untested |
| **REQ-NF-002** | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A5 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A6 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-A | Interface Contract Testing | STS-001-A7 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-C | Boundary Value Analysis | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D1 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D2 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D3 | ⬜ Untested |
| | SYS-001 | Module Design Command | STP-001-D | Fault Injection | STS-001-D4 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A10 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A6 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A7 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A8 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-A | Interface Contract Testing | STS-002-A9 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-B | Equivalence Partitioning | STS-002-B3 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-C | Boundary Value Analysis | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D2 | ⬜ Untested |
| | SYS-002 | Unit Test Command | STP-002-D | Fault Injection | STS-002-D3 | ⬜ Untested |
| **REQ-NF-003** | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-C | Equivalence Partitioning | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D1 | ⬜ Untested |
| | SYS-003 | Module Coverage Validation Script (Bash) | STP-003-D | Boundary Value Analysis | STS-003-D2 | ⬜ Untested |
| **REQ-NF-004** | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A3 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A4 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B3 | ⬜ Untested |
| | SYS-009 | Setup Script Extensions | STP-009-A | Interface Contract Testing | STS-009-A1 | ⬜ Untested |
| | SYS-009 | Setup Script Extensions | STP-009-A | Interface Contract Testing | STS-009-A2 | ⬜ Untested |
| | SYS-009 | Setup Script Extensions | STP-009-A | Interface Contract Testing | STS-009-A3 | ⬜ Untested |
| | SYS-009 | Setup Script Extensions | STP-009-B | Equivalence Partitioning | STS-009-B1 | ⬜ Untested |
| | SYS-009 | Setup Script Extensions | STP-009-B | Equivalence Partitioning | STS-009-B2 | ⬜ Untested |
| **REQ-NF-005** | SYS-012 | CI Evaluation Suite Extension | STP-012-A | Interface Contract Testing | STS-012-A1 | ⬜ Untested |
| | SYS-012 | CI Evaluation Suite Extension | STP-012-A | Interface Contract Testing | STS-012-A2 | ⬜ Untested |
| | SYS-012 | CI Evaluation Suite Extension | STP-012-A | Interface Contract Testing | STS-012-A3 | ⬜ Untested |
| | SYS-012 | CI Evaluation Suite Extension | STP-012-A | Interface Contract Testing | STS-012-A4 | ⬜ Untested |
| | SYS-012 | CI Evaluation Suite Extension | STP-012-B | Boundary Value Analysis | STS-012-B1 | ⬜ Untested |
| | SYS-012 | CI Evaluation Suite Extension | STP-012-B | Boundary Value Analysis | STS-012-B2 | ⬜ Untested |

### Matrix B Coverage

| Metric | Value |
|--------|-------|
| **Total System Components (SYS)** | 12 |
| **Total System Test Cases (STP)** | 25 |
| **Total System Scenarios (STS)** | 74 |
| **REQ → SYS Coverage** | 71/71 (100%) |
| **SYS → STP Coverage** | 12/12 (100%) |

## Matrix C — Integration Verification (Module Boundary View)

| System Component (SYS) | Parent REQs | Architecture Module (ARCH) | Module Name | Test Case ID (ITP) | Technique | Scenario ID (ITS) | Status |
|------------------------|-------------|---------------------------|-------------|--------------------|-----------|--------------------|--------|
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-041, REQ-043, REQ-NF-002, REQ-IF-001, REQ-CN-001, REQ-CN-004) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-041, REQ-043, REQ-NF-002, REQ-IF-001, REQ-CN-001, REQ-CN-004 | ARCH-001 | Module Design Prompt Orchestrator | ITP-001-A | Interface Contract Testing | ITS-001-A1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-041, REQ-043, REQ-NF-002, REQ-IF-001, REQ-CN-001, REQ-CN-004) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-041, REQ-043, REQ-NF-002, REQ-IF-001, REQ-CN-001, REQ-CN-004 | ARCH-001 | Module Design Prompt Orchestrator | ITP-001-A | Interface Contract Testing | ITS-001-A2 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-041, REQ-043, REQ-NF-002, REQ-IF-001, REQ-CN-001, REQ-CN-004) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-041, REQ-043, REQ-NF-002, REQ-IF-001, REQ-CN-001, REQ-CN-004 | ARCH-001 | Module Design Prompt Orchestrator | ITP-001-B | Data Flow Testing | ITS-001-B1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-041, REQ-043, REQ-NF-002, REQ-IF-001, REQ-CN-001, REQ-CN-004) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-041, REQ-043, REQ-NF-002, REQ-IF-001, REQ-CN-001, REQ-CN-004 | ARCH-001 | Module Design Prompt Orchestrator | ITP-001-B | Data Flow Testing | ITS-001-B2 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-041, REQ-043, REQ-NF-002, REQ-IF-001, REQ-CN-001, REQ-CN-004) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-041, REQ-043, REQ-NF-002, REQ-IF-001, REQ-CN-001, REQ-CN-004 | ARCH-001 | Module Design Prompt Orchestrator | ITP-001-C | Interface Fault Injection | ITS-001-C1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-041, REQ-043, REQ-NF-002, REQ-IF-001, REQ-CN-001, REQ-CN-004) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-041, REQ-043, REQ-NF-002, REQ-IF-001, REQ-CN-001, REQ-CN-004 | ARCH-001 | Module Design Prompt Orchestrator | ITP-001-C | Interface Fault Injection | ITS-001-C2 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-041, REQ-043, REQ-NF-002, REQ-IF-001, REQ-CN-001, REQ-CN-004) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-041, REQ-043, REQ-NF-002, REQ-IF-001, REQ-CN-001, REQ-CN-004 | ARCH-002 | Module Four-View Generator | ITP-002-A | Interface Contract Testing | ITS-002-A1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-041, REQ-043, REQ-NF-002, REQ-IF-001, REQ-CN-001, REQ-CN-004) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-041, REQ-043, REQ-NF-002, REQ-IF-001, REQ-CN-001, REQ-CN-004 | ARCH-002 | Module Four-View Generator | ITP-002-A | Interface Contract Testing | ITS-002-A2 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-041, REQ-043, REQ-NF-002, REQ-IF-001, REQ-CN-001, REQ-CN-004) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015, REQ-016, REQ-041, REQ-043, REQ-NF-002, REQ-IF-001, REQ-CN-001, REQ-CN-004 | ARCH-002 | Module Four-View Generator | ITP-002-B | Data Flow Testing | ITS-002-B1 | ⬜ Untested |
| SYS-002 (REQ-017, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-028, REQ-029, REQ-030, REQ-031, REQ-032, REQ-042, REQ-NF-002, REQ-IF-002, REQ-CN-001, REQ-CN-004) | REQ-017, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-028, REQ-029, REQ-030, REQ-031, REQ-032, REQ-042, REQ-NF-002, REQ-IF-002, REQ-CN-001, REQ-CN-004 | ARCH-003 | Unit Test Prompt Orchestrator | ITP-003-A | Interface Contract Testing | ITS-003-A1 | ⬜ Untested |
| SYS-002 (REQ-017, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-028, REQ-029, REQ-030, REQ-031, REQ-032, REQ-042, REQ-NF-002, REQ-IF-002, REQ-CN-001, REQ-CN-004) | REQ-017, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-028, REQ-029, REQ-030, REQ-031, REQ-032, REQ-042, REQ-NF-002, REQ-IF-002, REQ-CN-001, REQ-CN-004 | ARCH-003 | Unit Test Prompt Orchestrator | ITP-003-B | Data Flow Testing | ITS-003-B1 | ⬜ Untested |
| SYS-002 (REQ-017, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-028, REQ-029, REQ-030, REQ-031, REQ-032, REQ-042, REQ-NF-002, REQ-IF-002, REQ-CN-001, REQ-CN-004) | REQ-017, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-028, REQ-029, REQ-030, REQ-031, REQ-032, REQ-042, REQ-NF-002, REQ-IF-002, REQ-CN-001, REQ-CN-004 | ARCH-003 | Unit Test Prompt Orchestrator | ITP-003-B | Data Flow Testing | ITS-003-B2 | ⬜ Untested |
| SYS-002 (REQ-017, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-028, REQ-029, REQ-030, REQ-031, REQ-032, REQ-042, REQ-NF-002, REQ-IF-002, REQ-CN-001, REQ-CN-004) | REQ-017, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-028, REQ-029, REQ-030, REQ-031, REQ-032, REQ-042, REQ-NF-002, REQ-IF-002, REQ-CN-001, REQ-CN-004 | ARCH-003 | Unit Test Prompt Orchestrator | ITP-003-C | Interface Fault Injection | ITS-003-C1 | ⬜ Untested |
| SYS-002 (REQ-017, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-028, REQ-029, REQ-030, REQ-031, REQ-032, REQ-042, REQ-NF-002, REQ-IF-002, REQ-CN-001, REQ-CN-004) | REQ-017, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-028, REQ-029, REQ-030, REQ-031, REQ-032, REQ-042, REQ-NF-002, REQ-IF-002, REQ-CN-001, REQ-CN-004 | ARCH-004 | White-Box Technique Engine | ITP-004-A | Interface Contract Testing | ITS-004-A1 | ⬜ Untested |
| SYS-002 (REQ-017, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-028, REQ-029, REQ-030, REQ-031, REQ-032, REQ-042, REQ-NF-002, REQ-IF-002, REQ-CN-001, REQ-CN-004) | REQ-017, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-028, REQ-029, REQ-030, REQ-031, REQ-032, REQ-042, REQ-NF-002, REQ-IF-002, REQ-CN-001, REQ-CN-004 | ARCH-004 | White-Box Technique Engine | ITP-004-A | Interface Contract Testing | ITS-004-A2 | ⬜ Untested |
| SYS-002 (REQ-017, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-028, REQ-029, REQ-030, REQ-031, REQ-032, REQ-042, REQ-NF-002, REQ-IF-002, REQ-CN-001, REQ-CN-004) | REQ-017, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-028, REQ-029, REQ-030, REQ-031, REQ-032, REQ-042, REQ-NF-002, REQ-IF-002, REQ-CN-001, REQ-CN-004 | ARCH-004 | White-Box Technique Engine | ITP-004-B | Data Flow Testing | ITS-004-B1 | ⬜ Untested |
| SYS-003 (REQ-033, REQ-034, REQ-035, REQ-036, REQ-037, REQ-038, REQ-039, REQ-040, REQ-006, REQ-031, REQ-032, REQ-NF-001, REQ-NF-003, REQ-IF-003, REQ-IF-004, REQ-CN-004) | REQ-033, REQ-034, REQ-035, REQ-036, REQ-037, REQ-038, REQ-039, REQ-040, REQ-006, REQ-031, REQ-032, REQ-NF-001, REQ-NF-003, REQ-IF-003, REQ-IF-004, REQ-CN-004 | ARCH-007 | Forward Coverage Parser | ITP-007-A | Interface Contract Testing | ITS-007-A1 | ⬜ Untested |
| SYS-003 (REQ-033, REQ-034, REQ-035, REQ-036, REQ-037, REQ-038, REQ-039, REQ-040, REQ-006, REQ-031, REQ-032, REQ-NF-001, REQ-NF-003, REQ-IF-003, REQ-IF-004, REQ-CN-004) | REQ-033, REQ-034, REQ-035, REQ-036, REQ-037, REQ-038, REQ-039, REQ-040, REQ-006, REQ-031, REQ-032, REQ-NF-001, REQ-NF-003, REQ-IF-003, REQ-IF-004, REQ-CN-004 | ARCH-007 | Forward Coverage Parser | ITP-007-A | Interface Contract Testing | ITS-007-A2 | ⬜ Untested |
| SYS-003 (REQ-033, REQ-034, REQ-035, REQ-036, REQ-037, REQ-038, REQ-039, REQ-040, REQ-006, REQ-031, REQ-032, REQ-NF-001, REQ-NF-003, REQ-IF-003, REQ-IF-004, REQ-CN-004) | REQ-033, REQ-034, REQ-035, REQ-036, REQ-037, REQ-038, REQ-039, REQ-040, REQ-006, REQ-031, REQ-032, REQ-NF-001, REQ-NF-003, REQ-IF-003, REQ-IF-004, REQ-CN-004 | ARCH-007 | Forward Coverage Parser | ITP-007-B | Interface Fault Injection | ITS-007-B1 | ⬜ Untested |
| SYS-003 (REQ-033, REQ-034, REQ-035, REQ-036, REQ-037, REQ-038, REQ-039, REQ-040, REQ-006, REQ-031, REQ-032, REQ-NF-001, REQ-NF-003, REQ-IF-003, REQ-IF-004, REQ-CN-004) | REQ-033, REQ-034, REQ-035, REQ-036, REQ-037, REQ-038, REQ-039, REQ-040, REQ-006, REQ-031, REQ-032, REQ-NF-001, REQ-NF-003, REQ-IF-003, REQ-IF-004, REQ-CN-004 | ARCH-007 | Forward Coverage Parser | ITP-007-B | Interface Fault Injection | ITS-007-B2 | ⬜ Untested |
| SYS-003 (REQ-033, REQ-034, REQ-035, REQ-036, REQ-037, REQ-038, REQ-039, REQ-040, REQ-006, REQ-031, REQ-032, REQ-NF-001, REQ-NF-003, REQ-IF-003, REQ-IF-004, REQ-CN-004) | REQ-033, REQ-034, REQ-035, REQ-036, REQ-037, REQ-038, REQ-039, REQ-040, REQ-006, REQ-031, REQ-032, REQ-NF-001, REQ-NF-003, REQ-IF-003, REQ-IF-004, REQ-CN-004 | ARCH-008 | Backward Coverage Parser | ITP-008-A | Interface Contract Testing | ITS-008-A1 | ⬜ Untested |
| SYS-003 (REQ-033, REQ-034, REQ-035, REQ-036, REQ-037, REQ-038, REQ-039, REQ-040, REQ-006, REQ-031, REQ-032, REQ-NF-001, REQ-NF-003, REQ-IF-003, REQ-IF-004, REQ-CN-004) | REQ-033, REQ-034, REQ-035, REQ-036, REQ-037, REQ-038, REQ-039, REQ-040, REQ-006, REQ-031, REQ-032, REQ-NF-001, REQ-NF-003, REQ-IF-003, REQ-IF-004, REQ-CN-004 | ARCH-008 | Backward Coverage Parser | ITP-008-A | Interface Contract Testing | ITS-008-A2 | ⬜ Untested |
| SYS-003 (REQ-033, REQ-034, REQ-035, REQ-036, REQ-037, REQ-038, REQ-039, REQ-040, REQ-006, REQ-031, REQ-032, REQ-NF-001, REQ-NF-003, REQ-IF-003, REQ-IF-004, REQ-CN-004) | REQ-033, REQ-034, REQ-035, REQ-036, REQ-037, REQ-038, REQ-039, REQ-040, REQ-006, REQ-031, REQ-032, REQ-NF-001, REQ-NF-003, REQ-IF-003, REQ-IF-004, REQ-CN-004 | ARCH-008 | Backward Coverage Parser | ITP-008-B | Interface Fault Injection | ITS-008-B1 | ⬜ Untested |
| SYS-004 (REQ-056, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-014) | REQ-056, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-014 | ARCH-002 | Module Four-View Generator | ITP-002-A | Interface Contract Testing | ITS-002-A1 | ⬜ Untested |
| SYS-004 (REQ-056, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-014) | REQ-056, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-014 | ARCH-002 | Module Four-View Generator | ITP-002-A | Interface Contract Testing | ITS-002-A2 | ⬜ Untested |
| SYS-004 (REQ-056, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-014) | REQ-056, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-014 | ARCH-002 | Module Four-View Generator | ITP-002-B | Data Flow Testing | ITS-002-B1 | ⬜ Untested |
| SYS-004 (REQ-056, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-014) | REQ-056, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-014 | ARCH-005 | Module Design Template | ITP-005-A | Interface Contract Testing | ITS-005-A1 | ⬜ Untested |
| SYS-004 (REQ-056, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-014) | REQ-056, REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-014 | ARCH-005 | Module Design Template | ITP-005-A | Interface Contract Testing | ITS-005-A2 | ⬜ Untested |
| SYS-005 (REQ-057, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-027) | REQ-057, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-027 | ARCH-004 | White-Box Technique Engine | ITP-004-A | Interface Contract Testing | ITS-004-A1 | ⬜ Untested |
| SYS-005 (REQ-057, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-027) | REQ-057, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-027 | ARCH-004 | White-Box Technique Engine | ITP-004-A | Interface Contract Testing | ITS-004-A2 | ⬜ Untested |
| SYS-005 (REQ-057, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-027) | REQ-057, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-027 | ARCH-004 | White-Box Technique Engine | ITP-004-B | Data Flow Testing | ITS-004-B1 | ⬜ Untested |
| SYS-005 (REQ-057, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-027) | REQ-057, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-027 | ARCH-006 | Unit Test Template | ITP-006-A | Interface Contract Testing | ITS-006-A1 | ⬜ Untested |
| SYS-005 (REQ-057, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-027) | REQ-057, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-023, REQ-024, REQ-025, REQ-027 | ARCH-006 | Unit Test Template | ITP-006-A | Interface Contract Testing | ITS-006-A2 | ⬜ Untested |
| SYS-006 (REQ-046, REQ-047, REQ-048, REQ-049, REQ-050, REQ-051, REQ-052, REQ-053, REQ-055, REQ-NF-004) | REQ-046, REQ-047, REQ-048, REQ-049, REQ-050, REQ-051, REQ-052, REQ-053, REQ-055, REQ-NF-004 | ARCH-011 | Matrix D Table Renderer | ITP-011-A | Interface Contract Testing | ITS-011-A1 | ⬜ Untested |
| SYS-006 (REQ-046, REQ-047, REQ-048, REQ-049, REQ-050, REQ-051, REQ-052, REQ-053, REQ-055, REQ-NF-004) | REQ-046, REQ-047, REQ-048, REQ-049, REQ-050, REQ-051, REQ-052, REQ-053, REQ-055, REQ-NF-004 | ARCH-011 | Matrix D Table Renderer | ITP-011-A | Interface Contract Testing | ITS-011-A2 | ⬜ Untested |
| SYS-006 (REQ-046, REQ-047, REQ-048, REQ-049, REQ-050, REQ-051, REQ-052, REQ-053, REQ-055, REQ-NF-004) | REQ-046, REQ-047, REQ-048, REQ-049, REQ-050, REQ-051, REQ-052, REQ-053, REQ-055, REQ-NF-004 | ARCH-011 | Matrix D Table Renderer | ITP-011-B | Data Flow Testing | ITS-011-B1 | ⬜ Untested |
| SYS-006 (REQ-046, REQ-047, REQ-048, REQ-049, REQ-050, REQ-051, REQ-052, REQ-053, REQ-055, REQ-NF-004) | REQ-046, REQ-047, REQ-048, REQ-049, REQ-050, REQ-051, REQ-052, REQ-053, REQ-055, REQ-NF-004 | ARCH-011 | Matrix D Table Renderer | ITP-011-B | Data Flow Testing | ITS-011-B2 | ⬜ Untested |
| SYS-007 (REQ-054, REQ-053) | REQ-054, REQ-053 | ARCH-010 | Matrix D Data Extractor (Bash) | ITP-010-A | Interface Contract Testing | ITS-010-A1 | ⬜ Untested |
| SYS-007 (REQ-054, REQ-053) | REQ-054, REQ-053 | ARCH-010 | Matrix D Data Extractor (Bash) | ITP-010-A | Interface Contract Testing | ITS-010-A2 | ⬜ Untested |
| SYS-007 (REQ-054, REQ-053) | REQ-054, REQ-053 | ARCH-010 | Matrix D Data Extractor (Bash) | ITP-010-B | Data Flow Testing | ITS-010-B1 | ⬜ Untested |
| SYS-007 (REQ-054, REQ-053) | REQ-054, REQ-053 | ARCH-010 | Matrix D Data Extractor (Bash) | ITP-010-B | Data Flow Testing | ITS-010-B2 | ⬜ Untested |
| SYS-007 (REQ-054, REQ-053) | REQ-054, REQ-053 | ARCH-010 | Matrix D Data Extractor (Bash) | ITP-010-C | Interface Fault Injection | ITS-010-C1 | ⬜ Untested |
| SYS-008 (REQ-CN-005) | REQ-CN-005 | ARCH-012 | Matrix D Data Extractor (PowerShell) | ITP-012-A | Interface Contract Testing | ITS-012-A1 | ⬜ Untested |
| SYS-009 (REQ-044, REQ-045, REQ-NF-004) | REQ-044, REQ-045, REQ-NF-004 | ARCH-013 | Setup Module-Level Flag Handler | ITP-013-A | Interface Contract Testing | ITS-013-A1 | ⬜ Untested |
| SYS-009 (REQ-044, REQ-045, REQ-NF-004) | REQ-044, REQ-045, REQ-NF-004 | ARCH-013 | Setup Module-Level Flag Handler | ITP-013-A | Interface Contract Testing | ITS-013-A2 | ⬜ Untested |
| SYS-009 (REQ-044, REQ-045, REQ-NF-004) | REQ-044, REQ-045, REQ-NF-004 | ARCH-013 | Setup Module-Level Flag Handler | ITP-013-B | Interface Fault Injection | ITS-013-B1 | ⬜ Untested |
| SYS-009 (REQ-044, REQ-045, REQ-NF-004) | REQ-044, REQ-045, REQ-NF-004 | ARCH-013 | Setup Module-Level Flag Handler | ITP-013-B | Interface Fault Injection | ITS-013-B2 | ⬜ Untested |
| SYS-010 (REQ-CN-003, REQ-IF-003, REQ-IF-004) | REQ-CN-003, REQ-IF-003, REQ-IF-004 | ARCH-009 | Module Coverage Validator (PowerShell) | ITP-009-A | Interface Contract Testing | ITS-009-A1 | ⬜ Untested |
| SYS-010 (REQ-CN-003, REQ-IF-003, REQ-IF-004) | REQ-CN-003, REQ-IF-003, REQ-IF-004 | ARCH-009 | Module Coverage Validator (PowerShell) | ITP-009-A | Interface Contract Testing | ITS-009-A2 | ⬜ Untested |
| SYS-011 (REQ-CN-002) | REQ-CN-002 | ARCH-014 | Extension Manifest v0.4.0 Registrar | ITP-014-A | Interface Contract Testing | ITS-014-A1 | ⬜ Untested |
| SYS-011 (REQ-CN-002) | REQ-CN-002 | ARCH-014 | Extension Manifest v0.4.0 Registrar | ITP-014-A | Interface Contract Testing | ITS-014-A2 | ⬜ Untested |
| SYS-012 (REQ-NF-005) | REQ-NF-005 | ARCH-015 | Structural Evaluation Engine | ITP-015-A | Interface Contract Testing | ITS-015-A1 | ⬜ Untested |
| SYS-012 (REQ-NF-005) | REQ-NF-005 | ARCH-015 | Structural Evaluation Engine | ITP-015-A | Interface Contract Testing | ITS-015-A2 | ⬜ Untested |
| SYS-012 (REQ-NF-005) | REQ-NF-005 | ARCH-015 | Structural Evaluation Engine | ITP-015-B | Data Flow Testing | ITS-015-B1 | ⬜ Untested |
| SYS-012 (REQ-NF-005) | REQ-NF-005 | ARCH-016 | Semantic Quality Evaluator | ITP-016-A | Interface Contract Testing | ITS-016-A1 | ⬜ Untested |
| SYS-012 (REQ-NF-005) | REQ-NF-005 | ARCH-016 | Semantic Quality Evaluator | ITP-016-A | Interface Contract Testing | ITS-016-A2 | ⬜ Untested |
| N/A (Cross-Cutting) | — | ARCH-017 | Tag Routing Logic | ITP-017-A | Interface Contract Testing | ITS-017-A1 | ⬜ Untested |
| N/A (Cross-Cutting) | — | ARCH-017 | Tag Routing Logic | ITP-017-A | Interface Contract Testing | ITS-017-A2 | ⬜ Untested |
| N/A (Cross-Cutting) | — | ARCH-017 | Tag Routing Logic | ITP-017-A | Interface Contract Testing | ITS-017-A3 | ⬜ Untested |
| N/A (Cross-Cutting) | — | ARCH-017 | Tag Routing Logic | ITP-017-B | Data Flow Testing | ITS-017-B1 | ⬜ Untested |
| N/A (Cross-Cutting) | — | ARCH-017 | Tag Routing Logic | ITP-017-B | Data Flow Testing | ITS-017-B2 | ⬜ Untested |
| N/A (Cross-Cutting) | — | ARCH-017 | Tag Routing Logic | ITP-017-C | Interface Fault Injection | ITS-017-C1 | ⬜ Untested |
| N/A (Cross-Cutting) | — | ARCH-017 | Tag Routing Logic | ITP-017-C | Interface Fault Injection | ITS-017-C2 | ⬜ Untested |

### Matrix C Coverage

| Metric | Value |
|--------|-------|
| **Total Architecture Modules (ARCH)** | 17 |
| **Total Cross-Cutting Modules** | 1 |
| **Total Integration Test Cases (ITP)** | 32 |
| **Total Integration Scenarios (ITS)** | 57 |
| **SYS → ARCH Coverage** | 12/12 (100%) |
| **ARCH → ITP Coverage** | 17/17 (100%) |

### Uncovered Requirements (REQ without ATP)

None — full coverage.

### Orphaned Test Cases (ATP without valid REQ)

None — all tests trace to requirements.

### Uncovered Requirements — System Level (REQ without SYS)

None — full coverage.

### Orphaned System Test Cases (STP without valid SYS)

None — all system tests trace to components.

### Uncovered System Components — Architecture Level (SYS without ARCH)

None — full coverage.

### Orphaned Integration Test Cases (ITP without valid ARCH)

None — all integration tests trace to modules.

## Audit Notes

- **Matrix generated by**: `build-matrix.sh` (deterministic regex parser)
- **Source documents**: `requirements.md`, `acceptance-plan.md`, `system-design.md`, `system-test.md`, `architecture-design.md`, `integration-test.md`
- **Last validated**: 2026-02-22
