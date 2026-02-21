# Traceability Matrix

**Generated**: 2026-02-21
**Source**: `specs/003-architecture-integration/v-model/`

## Matrix A — Validation (User View)

| Requirement ID | Requirement Description | Test Case ID (ATP) | Validation Condition | Scenario ID (SCN) | Status |
|----------------|------------------------|--------------------|----------------------|--------------------|--------|
| **REQ-001** | The extension SHALL provide a `/speckit.v-model.architecture-design` command that reads `system-design.md` as input and produces `architecture-design.md` as output. | ATP-001-A | Happy Path — Command Produces architecture-design.md | SCN-001-A1 | ⬜ Untested |
| | | ATP-001-B | Error — Missing system-design.md | SCN-001-B1 | ⬜ Untested |
| **REQ-002** | The `/speckit.v-model.architecture-design` command SHALL assign each architecture module a unique `ARCH-NNN` identifier (e.g., `ARCH-001`, `ARCH-012`), 3-digit zero-padded, sequentially numbered and never renumbered once assigned. | ATP-002-A | Sequential ARCH-NNN Format | SCN-002-A1 | ⬜ Untested |
| | | ATP-002-B | Identifier Permanence on Re-run | SCN-002-B1 | ⬜ Untested |
| **REQ-003** | The `architecture-design.md` output SHALL include a **Logical View (Component Breakdown)** listing how each `SYS-NNN` is decomposed into software modules (`ARCH-NNN`), with each module's name, description, and list of parent `SYS-NNN` identifiers via an explicit "Parent System Components" field. | ATP-003-A | Logical View Required Fields Present | SCN-003-A1 | ⬜ Untested |
| **REQ-004** | The `architecture-design.md` output SHALL include a **Process View (Dynamic Behavior)** documenting runtime module interactions — sequences, concurrency, thread management — with Mermaid sequence diagrams embedded in Markdown showing execution order, synchronization points, and thread/task boundaries. | ATP-004-A | Process View with Mermaid Sequence Diagrams | SCN-004-A1 | ⬜ Untested |
| **REQ-005** | The `architecture-design.md` output SHALL include an **Interface View (Strict API / Interface Contracts)** documenting for every `ARCH-NNN` module: inputs accepted (types, formats, ranges), outputs produced (types, guarantees), and exceptions thrown (error codes, failure modes). | ATP-005-A | Strict API Contracts Documented | SCN-005-A1 | ⬜ Untested |
| **REQ-006** | The `architecture-design.md` output SHALL include a **Data Flow View (Data Control Flow)** tracing how data moves through modules — input → transformation chain → output with intermediate formats. | ATP-006-A | Data Transformation Chains Documented | SCN-006-A1 | ⬜ Untested |
| **REQ-007** | Each business-logic `ARCH-NNN` module SHALL trace to one or more `SYS-NNN` identifiers via the "Parent System Components" field in the Logical View. | ATP-007-A | Every Business-Logic ARCH Traces to SYS | SCN-007-A1 | ⬜ Untested |
| | | ATP-007-B | Orphaned Business-Logic Module Detection | SCN-007-B1 | ⬜ Untested |
| **REQ-008** | The architecture design command SHALL support many-to-many SYS↔ARCH relationships: a single `SYS-NNN` MAY map to multiple `ARCH-NNN` modules, and a single `ARCH-NNN` module MAY satisfy multiple `SYS-NNN` components. | ATP-008-A | Single SYS Maps to Multiple ARCH | SCN-008-A1 | ⬜ Untested |
| | | ATP-008-B | Single ARCH Satisfies Multiple SYS | SCN-008-B1 | ⬜ Untested |
| **REQ-009** | `ARCH-NNN` modules that represent infrastructure or utility concerns (e.g., logging, secrets management, thread pools, error handling frameworks) SHALL trace to a `[CROSS-CUTTING]` tag instead of a `SYS-NNN` identifier. | ATP-009-A | Infrastructure Modules Use CROSS-CUTTING Tag | SCN-009-A1 | ⬜ Untested |
| **REQ-010** | The Logical View SHALL clearly distinguish business-logic modules (with explicit SYS parents) from cross-cutting modules (with the `[CROSS-CUTTING]` tag and a rationale explaining why the module is system-wide). | ATP-010-A | Clear Visual Distinction in Logical View | SCN-010-A1 | ⬜ Untested |
| **REQ-011** | Cross-cutting modules (`[CROSS-CUTTING]` tag) SHALL still be included in coverage validation: each cross-cutting `ARCH-NNN` MUST have at least one `ITP-NNN-X` integration test case. | ATP-011-A | Cross-Cutting Modules Have Integration Tests | SCN-011-A1 | ⬜ Untested |
| | | ATP-011-B | Coverage Validation Includes Cross-Cutting Modules | SCN-011-B1 | ⬜ Untested |
| **REQ-012** | When the architecture design process identifies a necessary technical module that is neither traceable to any `SYS-NNN` nor qualifies as `[CROSS-CUTTING]`, the command SHALL flag it as `[DERIVED MODULE: description]` rather than silently creating an `ARCH-NNN`, prompting the user to update `system-design.md`. | ATP-012-A | Derived Module Flagged with Warning | SCN-012-A1 | ⬜ Untested |
| | | ATP-012-B | Derived Module Not Silently Assigned ARCH-NNN | SCN-012-B1 | ⬜ Untested |
| **REQ-013** | The architecture design command SHALL reject "black box" descriptions — every `ARCH-NNN` module SHALL have a complete interface contract in the Interface View (inputs, outputs, exceptions). Modules with incomplete contracts SHALL trigger an anti-pattern warning. | ATP-013-A | Incomplete Contracts Trigger Anti-Pattern Warning | SCN-013-A1 | ⬜ Untested |
| | | ATP-013-B | Complete Contracts Pass Without Warning | SCN-013-B1 | ⬜ Untested |
| **REQ-014** | The extension SHALL provide a `/speckit.v-model.integration-test` command that reads `architecture-design.md` as input and produces `integration-test.md` as output. | ATP-014-A | Happy Path — Command Produces integration-test.md | SCN-014-A1 | ⬜ Untested |
| | | ATP-014-B | Error — Missing architecture-design.md | SCN-014-B1 | ⬜ Untested |
| **REQ-015** | The `/speckit.v-model.integration-test` command SHALL assign test case identifiers using the format `ITP-NNN-X` (e.g., `ITP-001-A`) where NNN matches the parent `ARCH-NNN` and X is a sequential uppercase letter. | ATP-015-A | Test Case IDs Match Format | SCN-015-A1 | ⬜ Untested |
| **REQ-016** | The `/speckit.v-model.integration-test` command SHALL assign test scenario identifiers using the format `ITS-NNN-X#` (e.g., `ITS-001-A1`) where NNN-X matches the parent `ITP-NNN-X` and # is a sequential number. | ATP-016-A | Scenario IDs Match Format | SCN-016-A1 | ⬜ Untested |
| **REQ-017** | Each integration test case (`ITP-NNN-X`) SHALL apply one of the four mandatory ISO 29119-4 techniques: Interface Contract Testing (driven by Interface View), Data Flow Testing (driven by Data Flow View), Interface Fault Injection (driven by Interface View error contracts + Process View timing), or Concurrency & Race Condition Testing (driven by Process View concurrency model). | ATP-017-A | Each Test Case Applies One of Four Techniques | SCN-017-A1 | ⬜ Untested |
| **REQ-018** | Each integration test case (`ITP-NNN-X`) SHALL explicitly name its technique and reference the specific architecture view that drives it. | ATP-018-A | Each Test Case Names Technique and Architecture View | SCN-018-A1 | ⬜ Untested |
| **REQ-019** | Integration test scenarios (`ITS-NNN-X#`) SHALL use Given/When/Then BDD structure with **technical, module-boundary-oriented language** (e.g., "Given Module A sends a malformed payload to Module B, When Module B receives the payload, Then Module B rejects it with error code INVALID_SCHEMA and does not propagate the error downstream"), distinct from user-centric acceptance language and system-level test language. | ATP-019-A | Scenarios Use Technical Module-Boundary Language | SCN-019-A1 | ⬜ Untested |
| | | ATP-019-B | Scenarios Do Not Use User-Centric Language | SCN-019-B1 | ⬜ Untested |
| **REQ-020** | The integration test command SHALL NOT generate tests for internal module logic or user-journey scenarios — only tests that verify the boundaries and handshakes between modules. | ATP-020-A | Only Boundary Tests Generated | SCN-020-A1 | ⬜ Untested |
| **REQ-021** | When the project is configured for a safety-critical domain (ISO 26262, DO-178C, IEC 62304), the architecture design output SHALL include additional sections: **ASIL Decomposition** (safety integrity allocation per module, e.g., SYS ASIL-D → ARCH-001 ASIL-D + ARCH-002 ASIL-A), **Defensive Programming** (how invalid inputs from one module are caught before corrupting the next), and **Temporal & Execution Constraints** (watchdog timers, execution order, deadlock prevention). | ATP-021-A | Safety Sections Present When Configured | SCN-021-A1 | ⬜ Untested |
| | | ATP-021-B | Safety Sections Absent When Not Configured | SCN-021-B1 | ⬜ Untested |
| **REQ-022** | When the project is configured for a safety-critical domain, the integration test output SHALL include additional sections: **SIL/HIL Compatibility** (scenarios executable in Software/Hardware-in-the-Loop environments) and **Resource Contention** (proving modules don't exhaust shared resources during interaction). | ATP-022-A | Safety Test Sections Present When Configured | SCN-022-A1 | ⬜ Untested |
| | | ATP-022-B | Safety Test Sections Absent When Not Configured | SCN-022-B1 | ⬜ Untested |
| **REQ-023** | The integration test command SHALL invoke `validate-architecture-coverage.sh` as a post-generation coverage gate and include the validation result (pass/fail with coverage summary) in its output. | ATP-023-A | Validation Invoked and Result Included | SCN-023-A1 | ⬜ Untested |
| | | ATP-023-B | Coverage Failure Reported | SCN-023-B1 | ⬜ Untested |
| **REQ-024** | The extension SHALL provide a `validate-architecture-coverage.sh` Bash script that deterministically validates forward coverage: every `SYS-NNN` in `system-design.md` has at least one corresponding `ARCH-NNN` in `architecture-design.md`. | ATP-024-A | All SYS Have ARCH Mappings | SCN-024-A1 | ⬜ Untested |
| | | ATP-024-B | Missing SYS→ARCH Gap Detected | SCN-024-B1 | ⬜ Untested |
| **REQ-025** | The `validate-architecture-coverage.sh` script SHALL deterministically validate backward coverage: every `ARCH-NNN` in `architecture-design.md` has at least one corresponding `ITP-NNN-X` in `integration-test.md`. | ATP-025-A | All ARCH Have ITP Mappings | SCN-025-A1 | ⬜ Untested |
| | | ATP-025-B | Missing ARCH→ITP Gap Detected | SCN-025-B1 | ⬜ Untested |
| **REQ-026** | The `validate-architecture-coverage.sh` script SHALL detect and report orphaned identifiers: any `ARCH-NNN` not referenced as a parent in any `SYS-NNN` or `[CROSS-CUTTING]` tag, and any `ITP-NNN-X` whose parent `ARCH-NNN` does not exist in `architecture-design.md`. | ATP-026-A | Orphaned ARCH Detected | SCN-026-A1 | ⬜ Untested |
| | | ATP-026-B | Orphaned ITP Detected | SCN-026-B1 | ⬜ Untested |
| **REQ-027** | The `validate-architecture-coverage.sh` script SHALL exit with code 0 when all coverage checks pass and code 1 when any gap or orphan is detected. | ATP-027-A | Exit Code 0 on Full Coverage | SCN-027-A1 | ⬜ Untested |
| | | ATP-027-B | Exit Code 1 on Any Gap or Orphan | SCN-027-B1 | ⬜ Untested |
| **REQ-028** | The `validate-architecture-coverage.sh` script SHALL output human-readable gap reports listing each specific gap or orphan by ID (e.g., "SYS-003: no architecture module mapping found") suitable for CI log inspection. | ATP-028-A | Gap Report Lists Specific IDs | SCN-028-A1 | ⬜ Untested |
| **REQ-029** | The `validate-architecture-coverage.sh` script SHALL support `--json` output mode for programmatic consumption by the integration test command. | ATP-029-A | --json Flag Produces Valid JSON | SCN-029-A1 | ⬜ Untested |
| **REQ-030** | The ID lineage encoding SHALL be consistent within the architecture tier: given any `ITS-NNN-X#` identifier, a regex SHALL be able to extract the parent `ITP-NNN-X` and grandparent `ARCH-NNN` without consulting any lookup table. To resolve the `SYS-NNN` ancestor(s), the script SHALL consult the "Parent System Components" field in `architecture-design.md`, because the many-to-many SYS↔ARCH relationship (REQ-008) makes pure string-based SYS extraction impossible. | ATP-030-A | Regex Extracts Parent ITP from ITS | SCN-030-A1 | ⬜ Untested |
| | | ATP-030-B | SYS Resolution via File Lookup | SCN-030-B1 | ⬜ Untested |
| **REQ-031** | The `/speckit.v-model.trace` command SHALL be extended to produce **Matrix C (Integration Verification)** — `SYS → ARCH → ITP → ITS` — when `architecture-design.md` and `integration-test.md` exist in the feature directory. `ARCH-NNN` modules tagged as `[CROSS-CUTTING]` SHALL appear in Matrix C as pseudo-rows where the `SYS` column displays `N/A (Cross-Cutting)` to ensure infrastructure modules are not excluded from the audit artifact. | ATP-031-A | Matrix C Produced with Correct Columns | SCN-031-A1 | ⬜ Untested |
| | | ATP-031-B | Cross-Cutting Modules in Matrix C | SCN-031-B1 | ⬜ Untested |
| **REQ-032** | In Matrix C, each `SYS-NNN` cell SHALL include a comma-separated list of its parent `REQ-NNN` identifiers in parentheses (e.g., `SYS-001 (REQ-001, REQ-003)`) to provide end-to-end requirement traceability without requiring cross-reference to Matrix B. | ATP-032-A | SYS Cells Include Parent REQ Identifiers | SCN-032-A1 | ⬜ Untested |
| **REQ-033** | The `/speckit.v-model.trace` command SHALL produce **Matrix A (Validation)**, **Matrix B (Verification)**, and **Matrix C (Integration Verification)** as separate tables with independent coverage percentages, to prevent visual bloat in Markdown rendering. | ATP-033-A | Three Separate Tables with Independent Percentages | SCN-033-A1 | ⬜ Untested |
| **REQ-034** | The `/speckit.v-model.trace` command SHALL remain backward compatible: when architecture-level artifacts are absent, the command SHALL produce the same v0.2.0 output (Matrix A + Matrix B only, no Matrix C, no warning). | ATP-034-A | v0.2.0 Output When Architecture Artifacts Absent | SCN-034-A1 | ⬜ Untested |
| **REQ-035** | The `/speckit.v-model.trace` command SHALL build matrices progressively: Matrix A alone after acceptance, A+B after system-test, A+B+C after integration-test. | ATP-035-A | Matrices Build Progressively by V-Level | SCN-035-A1 | ⬜ Untested |
| **REQ-036** | Each matrix SHALL include an independently calculated coverage percentage that matches the output of the corresponding deterministic validation script. | ATP-036-A | Matrix Percentages Match Validation Script | SCN-036-A1 | ⬜ Untested |
| **REQ-037** | The `build-matrix.sh` script SHALL be extended to parse `architecture-design.md` and `integration-test.md` to generate Matrix C data. | ATP-037-A | Script Parses Architecture and Integration Artifacts | SCN-037-A1 | ⬜ Untested |
| **REQ-038** | The `build-matrix.ps1` script SHALL be extended with identical Matrix C generation logic as `build-matrix.sh`. | ATP-038-A | PowerShell Script Generates Matrix C | SCN-038-A1 | ⬜ Untested |
| **REQ-039** | The extension SHALL provide an `architecture-design-template.md` in the `templates/` directory defining the required structure for ISO/IEC/IEEE 42010-compliant architecture design output with four mandatory views. | ATP-039-A | Template Exists with ISO 42010 Structure | SCN-039-A1 | ⬜ Untested |
| **REQ-040** | The extension SHALL provide an `integration-test-template.md` in the `templates/` directory defining the required structure for ISO 29119-4-compliant integration test output with the three-tier ITP/ITS hierarchy. | ATP-040-A | Template Exists with ISO 29119-4 Structure | SCN-040-A1 | ⬜ Untested |
| **REQ-041** | The `/speckit.v-model.architecture-design` command SHALL follow the strict translator constraint: when deriving from `system-design.md`, the AI SHALL NOT invent, infer, or add architecture modules for capabilities not present in the system design. | ATP-041-A | No Invented Modules Beyond System Design | SCN-041-A1 | ⬜ Untested |
| | | ATP-041-B | All ARCH Modules Traceable to System Design | SCN-041-B1 | ⬜ Untested |
| **REQ-042** | The `/speckit.v-model.integration-test` command SHALL follow the strict translator constraint: when deriving from `architecture-design.md`, the AI SHALL NOT invent test cases for modules or interfaces not present in the architecture design. | ATP-042-A | No Invented Test Cases Beyond Architecture Design | SCN-042-A1 | ⬜ Untested |
| | | ATP-042-B | All ITP Test Cases Traceable to Architecture Design | SCN-042-B1 | ⬜ Untested |
| **REQ-043** | The `setup-v-model.sh` script SHALL be extended with a `--require-system-design` flag that verifies `system-design.md` exists before proceeding. | ATP-043-A | Flag Validates system-design.md Exists | SCN-043-A1 | ⬜ Untested |
| | | ATP-043-B | Flag Fails When system-design.md Missing | SCN-043-B1 | ⬜ Untested |
| **REQ-044** | The `setup-v-model.sh` and `setup-v-model.ps1` scripts SHALL detect `architecture-design.md` and `integration-test.md` in the available documents list (`AVAILABLE_DOCS`). | ATP-044-A | Both Architecture Files Detected | SCN-044-A1 | ⬜ Untested |
| | | ATP-044-B | Partial Detection — Only Architecture Design Exists | SCN-044-B1 | ⬜ Untested |
| **REQ-045** | The architecture design command SHALL fail gracefully with a clear error message ("No system components found in system-design.md — cannot generate architecture design") when `system-design.md` is empty or contains zero `SYS-NNN` identifiers. | ATP-045-A | Clear Error on Empty Input | SCN-045-A1 | ⬜ Untested |
| **REQ-046** | The `validate-architecture-coverage.sh` script SHALL detect and report circular dependencies between `ARCH-NNN` modules in the Process View without hanging. | ATP-046-A | Circular Dependency Reported | SCN-046-A1 | ⬜ Untested |
| | | ATP-046-B | Script Does Not Hang on Circular Dependencies | SCN-046-B1 | ⬜ Untested |
| **REQ-047** | When `architecture-design.md` exists but `integration-test.md` does not, the trace command SHALL include the ARCH column in Matrix C but leave the ITP/ITS columns empty with a note ("Integration test plan not yet generated"). | ATP-047-A | ARCH Column Filled, ITP/ITS Empty with Note | SCN-047-A1 | ⬜ Untested |
| **REQ-048** | The `validate-architecture-coverage.sh` script SHALL support partial execution: if `integration-test.md` is omitted or not found, the script SHALL validate only forward coverage (`SYS → ARCH`) and bypass backward coverage and orphan checks for integration artifacts, exiting with code 0 if forward coverage is complete. | ATP-048-A | Forward-Only Validation When integration-test.md Absent | SCN-048-A1 | ⬜ Untested |
| | | ATP-048-B | Full Validation When All Files Present | SCN-048-B1 | ⬜ Untested |
| **REQ-049** | The `integration-test-template.md` SHALL include a **"Test Harness & Mocking Strategy"** section where each `ITP-NNN-X` test case explicitly defines which external interfaces, hardware dependencies, or unresolved module dependencies are stubbed or mocked during execution of its `ITS-NNN-X#` scenarios. | ATP-049-A | Template Includes Test Harness Section | SCN-049-A1 | ⬜ Untested |
| **REQ-CN-001** | Safety-critical sections (ASIL Decomposition, Defensive Programming, Temporal & Execution Constraints, SIL/HIL Compatibility, Resource Contention) SHALL be omitted by default and only included when the project's `v-model-config.yml` explicitly enables a regulated domain (ISO 26262, DO-178C, or IEC 62304). | ATP-CN-001-A | No Safety Sections Without Config | SCN-CN-001-A1 | ⬜ Untested |
| | | ATP-CN-001-B | Sections Present Only When Explicitly Enabled | SCN-CN-001-B1 | ⬜ Untested |
| **REQ-CN-002** | The extension version in `extension.yml` SHALL be bumped to `0.3.0` and SHALL register exactly 7 commands (5 existing + 2 new) and 1 hook. | ATP-CN-002-A | Version Bumped to 0.3.0 with Correct Command Count | SCN-CN-002-A1 | ⬜ Untested |
| **REQ-CN-003** | The extension SHALL provide `validate-architecture-coverage.ps1` (PowerShell) with identical behavior, output format, and exit codes as the Bash script, passing the same test fixture suite. | ATP-CN-003-A | Identical Behavior and Output | SCN-CN-003-A1 | ⬜ Untested |
| **REQ-IF-001** | The `/speckit.v-model.architecture-design` command SHALL read its input exclusively from `{FEATURE_DIR}/v-model/system-design.md` and write its output exclusively to `{FEATURE_DIR}/v-model/architecture-design.md`. | ATP-IF-001-A | Reads from system-design.md, Writes to architecture-design.md | SCN-IF-001-A1 | ⬜ Untested |
| **REQ-IF-002** | The `/speckit.v-model.integration-test` command SHALL read its input exclusively from `{FEATURE_DIR}/v-model/architecture-design.md` and write its output exclusively to `{FEATURE_DIR}/v-model/integration-test.md`. | ATP-IF-002-A | Reads from architecture-design.md, Writes to integration-test.md | SCN-IF-002-A1 | ⬜ Untested |
| **REQ-IF-003** | The `validate-architecture-coverage.sh` script SHALL accept three file paths as arguments: `system-design.md`, `architecture-design.md`, and `integration-test.md`, in that order. | ATP-IF-003-A | Accepts Three File Paths as Arguments | SCN-IF-003-A1 | ⬜ Untested |
| **REQ-IF-004** | The `validate-architecture-coverage.sh` script SHALL output a structured coverage summary to stdout in the same format as `validate-system-coverage.sh` (section headers, gap lists, pass/fail verdict, coverage percentages). | ATP-IF-004-A | Consistent Format with validate-system-coverage.sh | SCN-IF-004-A1 | ⬜ Untested |
| **REQ-NF-001** | The `validate-architecture-coverage.sh` script SHALL use regex-based parsing consistent with `validate-system-coverage.sh` from v0.2.0, requiring no runtime database or external tooling beyond standard Bash utilities. | ATP-NF-001-A | Script Uses Only Bash Builtins and Standard Utilities | SCN-NF-001-A1 | ⬜ Untested |
| **REQ-NF-002** | The `/speckit.v-model.architecture-design` and `/speckit.v-model.integration-test` commands SHALL handle input files with 50 or more `SYS-NNN` identifiers without truncation, data loss, or degraded output quality. | ATP-NF-002-A | No Truncation with 50 SYS Identifiers | SCN-NF-002-A1 | ⬜ Untested |
| **REQ-NF-003** | The `validate-architecture-coverage.sh` script SHALL accept gaps in `ARCH-NNN` numbering (e.g., ARCH-001, ARCH-003 without ARCH-002) without reporting false-positive errors. | ATP-NF-003-A | Gaps Accepted Without False Positives | SCN-NF-003-A1 | ⬜ Untested |
| **REQ-NF-004** | All v0.3.0 commands and scripts SHALL preserve backward compatibility: existing `system-design.md`, `system-test.md`, `requirements.md`, `acceptance-plan.md`, and `traceability-matrix.md` files SHALL NOT be modified by any v0.3.0 operation. | ATP-NF-004-A | Existing v0.2.0 Files Unchanged | SCN-NF-004-A1 | ⬜ Untested |
| **REQ-NF-005** | (Internal QA gate — not user-facing) The extension's CI evaluation suite SHALL validate that `/speckit.v-model.architecture-design` and `/speckit.v-model.integration-test` command outputs meet or exceed the quality thresholds established for v0.2.0 artifacts. The evaluation suite SHALL additionally verify the syntactic validity of generated Mermaid diagrams in the Process View — broken Mermaid syntax is a structural failure. | ATP-NF-005-A | Evaluation Suite Validates Output Quality and Mermaid Syntax | SCN-NF-005-A1 | ⬜ Untested |

### Matrix A Coverage

| Metric | Value |
|--------|-------|
| **Total Requirements** | 61 |
| **Total Test Cases (ATP)** | 86 |
| **Total Scenarios (SCN)** | 86 |
| **REQ → ATP Coverage** | 61/61 (100%) |
| **ATP → SCN Coverage** | 86/86 (100%) |

## Matrix B — Verification (Architectural View)

| Requirement ID | System Component (SYS) | Component Name | Test Case ID (STP) | Technique | Scenario ID (STS) | Status |
|----------------|------------------------|----------------|--------------------|-----------|--------------------|--------|
| **REQ-001** | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C4 | ⬜ Untested |
| **REQ-002** | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C4 | ⬜ Untested |
| **REQ-003** | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C4 | ⬜ Untested |
| | SYS-004 | Architecture Design Template | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Architecture Design Template | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Architecture Design Template | STP-004-B | Boundary Value Analysis | STS-004-B1 | ⬜ Untested |
| **REQ-004** | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C4 | ⬜ Untested |
| | SYS-004 | Architecture Design Template | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Architecture Design Template | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Architecture Design Template | STP-004-B | Boundary Value Analysis | STS-004-B1 | ⬜ Untested |
| **REQ-005** | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C4 | ⬜ Untested |
| | SYS-004 | Architecture Design Template | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Architecture Design Template | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Architecture Design Template | STP-004-B | Boundary Value Analysis | STS-004-B1 | ⬜ Untested |
| **REQ-006** | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C4 | ⬜ Untested |
| | SYS-004 | Architecture Design Template | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Architecture Design Template | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Architecture Design Template | STP-004-B | Boundary Value Analysis | STS-004-B1 | ⬜ Untested |
| **REQ-007** | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C4 | ⬜ Untested |
| **REQ-008** | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C4 | ⬜ Untested |
| **REQ-009** | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C4 | ⬜ Untested |
| | SYS-004 | Architecture Design Template | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Architecture Design Template | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Architecture Design Template | STP-004-B | Boundary Value Analysis | STS-004-B1 | ⬜ Untested |
| **REQ-010** | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C4 | ⬜ Untested |
| | SYS-004 | Architecture Design Template | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Architecture Design Template | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Architecture Design Template | STP-004-B | Boundary Value Analysis | STS-004-B1 | ⬜ Untested |
| **REQ-011** | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-B | Boundary Value Analysis | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A5 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| **REQ-012** | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C4 | ⬜ Untested |
| **REQ-013** | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C4 | ⬜ Untested |
| **REQ-014** | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-B | Boundary Value Analysis | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C3 | ⬜ Untested |
| **REQ-015** | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-B | Boundary Value Analysis | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C3 | ⬜ Untested |
| | SYS-005 | Integration Test Template | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Integration Test Template | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Integration Test Template | STP-005-B | Boundary Value Analysis | STS-005-B1 | ⬜ Untested |
| **REQ-016** | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-B | Boundary Value Analysis | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C3 | ⬜ Untested |
| | SYS-005 | Integration Test Template | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Integration Test Template | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Integration Test Template | STP-005-B | Boundary Value Analysis | STS-005-B1 | ⬜ Untested |
| **REQ-017** | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-B | Boundary Value Analysis | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C3 | ⬜ Untested |
| | SYS-005 | Integration Test Template | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Integration Test Template | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Integration Test Template | STP-005-B | Boundary Value Analysis | STS-005-B1 | ⬜ Untested |
| **REQ-018** | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-B | Boundary Value Analysis | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C3 | ⬜ Untested |
| | SYS-005 | Integration Test Template | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Integration Test Template | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Integration Test Template | STP-005-B | Boundary Value Analysis | STS-005-B1 | ⬜ Untested |
| **REQ-019** | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-B | Boundary Value Analysis | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C3 | ⬜ Untested |
| | SYS-005 | Integration Test Template | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Integration Test Template | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Integration Test Template | STP-005-B | Boundary Value Analysis | STS-005-B1 | ⬜ Untested |
| **REQ-020** | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-B | Boundary Value Analysis | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C3 | ⬜ Untested |
| **REQ-021** | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C4 | ⬜ Untested |
| | SYS-004 | Architecture Design Template | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Architecture Design Template | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Architecture Design Template | STP-004-B | Boundary Value Analysis | STS-004-B1 | ⬜ Untested |
| **REQ-022** | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-B | Boundary Value Analysis | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C3 | ⬜ Untested |
| | SYS-005 | Integration Test Template | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Integration Test Template | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Integration Test Template | STP-005-B | Boundary Value Analysis | STS-005-B1 | ⬜ Untested |
| **REQ-023** | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-B | Boundary Value Analysis | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C3 | ⬜ Untested |
| **REQ-024** | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A5 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| **REQ-025** | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A5 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| **REQ-026** | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A5 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| **REQ-027** | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A5 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| **REQ-028** | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A5 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| **REQ-029** | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A5 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| **REQ-030** | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A5 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| **REQ-031** | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B3 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-C | Fault Injection | STS-006-C1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-C | Fault Injection | STS-006-C2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-C | Fault Injection | STS-006-C3 | ⬜ Untested |
| **REQ-032** | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B3 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-C | Fault Injection | STS-006-C1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-C | Fault Injection | STS-006-C2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-C | Fault Injection | STS-006-C3 | ⬜ Untested |
| **REQ-033** | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B3 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-C | Fault Injection | STS-006-C1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-C | Fault Injection | STS-006-C2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-C | Fault Injection | STS-006-C3 | ⬜ Untested |
| **REQ-034** | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B3 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-C | Fault Injection | STS-006-C1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-C | Fault Injection | STS-006-C2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-C | Fault Injection | STS-006-C3 | ⬜ Untested |
| **REQ-035** | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B3 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-C | Fault Injection | STS-006-C1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-C | Fault Injection | STS-006-C2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-C | Fault Injection | STS-006-C3 | ⬜ Untested |
| **REQ-036** | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B3 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-C | Fault Injection | STS-006-C1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-C | Fault Injection | STS-006-C2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-C | Fault Injection | STS-006-C3 | ⬜ Untested |
| | SYS-007 | Matrix Builder Script Extension (Bash) | STP-007-A | Interface Contract Testing | STS-007-A1 | ⬜ Untested |
| | SYS-007 | Matrix Builder Script Extension (Bash) | STP-007-A | Interface Contract Testing | STS-007-A2 | ⬜ Untested |
| | SYS-007 | Matrix Builder Script Extension (Bash) | STP-007-B | Boundary Value Analysis | STS-007-B1 | ⬜ Untested |
| **REQ-037** | SYS-007 | Matrix Builder Script Extension (Bash) | STP-007-A | Interface Contract Testing | STS-007-A1 | ⬜ Untested |
| | SYS-007 | Matrix Builder Script Extension (Bash) | STP-007-A | Interface Contract Testing | STS-007-A2 | ⬜ Untested |
| | SYS-007 | Matrix Builder Script Extension (Bash) | STP-007-B | Boundary Value Analysis | STS-007-B1 | ⬜ Untested |
| **REQ-038** | SYS-008 | Matrix Builder Script Extension (PowerShell) | STP-008-A | Equivalence Partitioning | STS-008-A1 | ⬜ Untested |
| | SYS-008 | Matrix Builder Script Extension (PowerShell) | STP-008-B | Fault Injection | STS-008-B1 | ⬜ Untested |
| **REQ-039** | SYS-004 | Architecture Design Template | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Architecture Design Template | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Architecture Design Template | STP-004-B | Boundary Value Analysis | STS-004-B1 | ⬜ Untested |
| **REQ-040** | SYS-005 | Integration Test Template | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Integration Test Template | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Integration Test Template | STP-005-B | Boundary Value Analysis | STS-005-B1 | ⬜ Untested |
| **REQ-041** | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C4 | ⬜ Untested |
| **REQ-042** | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-B | Boundary Value Analysis | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C3 | ⬜ Untested |
| **REQ-043** | SYS-009 | Setup Script Extensions | STP-009-A | Interface Contract Testing | STS-009-A1 | ⬜ Untested |
| | SYS-009 | Setup Script Extensions | STP-009-A | Interface Contract Testing | STS-009-A2 | ⬜ Untested |
| | SYS-009 | Setup Script Extensions | STP-009-A | Interface Contract Testing | STS-009-A3 | ⬜ Untested |
| | SYS-009 | Setup Script Extensions | STP-009-B | Fault Injection | STS-009-B1 | ⬜ Untested |
| | SYS-009 | Setup Script Extensions | STP-009-B | Fault Injection | STS-009-B2 | ⬜ Untested |
| **REQ-044** | SYS-009 | Setup Script Extensions | STP-009-A | Interface Contract Testing | STS-009-A1 | ⬜ Untested |
| | SYS-009 | Setup Script Extensions | STP-009-A | Interface Contract Testing | STS-009-A2 | ⬜ Untested |
| | SYS-009 | Setup Script Extensions | STP-009-A | Interface Contract Testing | STS-009-A3 | ⬜ Untested |
| | SYS-009 | Setup Script Extensions | STP-009-B | Fault Injection | STS-009-B1 | ⬜ Untested |
| | SYS-009 | Setup Script Extensions | STP-009-B | Fault Injection | STS-009-B2 | ⬜ Untested |
| **REQ-045** | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C4 | ⬜ Untested |
| **REQ-046** | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A5 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| **REQ-047** | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B3 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-C | Fault Injection | STS-006-C1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-C | Fault Injection | STS-006-C2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-C | Fault Injection | STS-006-C3 | ⬜ Untested |
| **REQ-048** | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A5 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| **REQ-049** | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-B | Boundary Value Analysis | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C3 | ⬜ Untested |
| | SYS-005 | Integration Test Template | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Integration Test Template | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Integration Test Template | STP-005-B | Boundary Value Analysis | STS-005-B1 | ⬜ Untested |
| **REQ-CN-001** | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C4 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-B | Boundary Value Analysis | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C3 | ⬜ Untested |
| **REQ-CN-002** | SYS-011 | Extension Manifest Update | STP-011-A | Boundary Value Analysis | STS-011-A1 | ⬜ Untested |
| | SYS-011 | Extension Manifest Update | STP-011-A | Boundary Value Analysis | STS-011-A2 | ⬜ Untested |
| | SYS-011 | Extension Manifest Update | STP-011-A | Boundary Value Analysis | STS-011-A3 | ⬜ Untested |
| **REQ-CN-003** | SYS-010 | Architecture Coverage Validation Script (PowerShell) | STP-010-A | Interface Contract Testing | STS-010-A1 | ⬜ Untested |
| | SYS-010 | Architecture Coverage Validation Script (PowerShell) | STP-010-A | Interface Contract Testing | STS-010-A2 | ⬜ Untested |
| | SYS-010 | Architecture Coverage Validation Script (PowerShell) | STP-010-B | Fault Injection | STS-010-B1 | ⬜ Untested |
| | SYS-010 | Architecture Coverage Validation Script (PowerShell) | STP-010-B | Fault Injection | STS-010-B2 | ⬜ Untested |
| **REQ-IF-001** | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C4 | ⬜ Untested |
| **REQ-IF-002** | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-B | Boundary Value Analysis | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C3 | ⬜ Untested |
| **REQ-IF-003** | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A5 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| | SYS-010 | Architecture Coverage Validation Script (PowerShell) | STP-010-A | Interface Contract Testing | STS-010-A1 | ⬜ Untested |
| | SYS-010 | Architecture Coverage Validation Script (PowerShell) | STP-010-A | Interface Contract Testing | STS-010-A2 | ⬜ Untested |
| | SYS-010 | Architecture Coverage Validation Script (PowerShell) | STP-010-B | Fault Injection | STS-010-B1 | ⬜ Untested |
| | SYS-010 | Architecture Coverage Validation Script (PowerShell) | STP-010-B | Fault Injection | STS-010-B2 | ⬜ Untested |
| **REQ-IF-004** | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A5 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| | SYS-010 | Architecture Coverage Validation Script (PowerShell) | STP-010-A | Interface Contract Testing | STS-010-A1 | ⬜ Untested |
| | SYS-010 | Architecture Coverage Validation Script (PowerShell) | STP-010-A | Interface Contract Testing | STS-010-A2 | ⬜ Untested |
| | SYS-010 | Architecture Coverage Validation Script (PowerShell) | STP-010-B | Fault Injection | STS-010-B1 | ⬜ Untested |
| | SYS-010 | Architecture Coverage Validation Script (PowerShell) | STP-010-B | Fault Injection | STS-010-B2 | ⬜ Untested |
| **REQ-NF-001** | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A5 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| **REQ-NF-002** | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-A | Interface Contract Testing | STS-001-A4 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C3 | ⬜ Untested |
| | SYS-001 | Architecture Design Command | STP-001-C | Fault Injection | STS-001-C4 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A4 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-A | Interface Contract Testing | STS-002-A5 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-B | Boundary Value Analysis | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| | SYS-002 | Integration Test Command | STP-002-C | Fault Injection | STS-002-C3 | ⬜ Untested |
| **REQ-NF-003** | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A4 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-A | Interface Contract Testing | STS-003-A5 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-B | Boundary Value Analysis | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Architecture Coverage Validation Script (Bash) | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| **REQ-NF-004** | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-B | Equivalence Partitioning | STS-006-B3 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-C | Fault Injection | STS-006-C1 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-C | Fault Injection | STS-006-C2 | ⬜ Untested |
| | SYS-006 | Trace Command Extension | STP-006-C | Fault Injection | STS-006-C3 | ⬜ Untested |
| | SYS-009 | Setup Script Extensions | STP-009-A | Interface Contract Testing | STS-009-A1 | ⬜ Untested |
| | SYS-009 | Setup Script Extensions | STP-009-A | Interface Contract Testing | STS-009-A2 | ⬜ Untested |
| | SYS-009 | Setup Script Extensions | STP-009-A | Interface Contract Testing | STS-009-A3 | ⬜ Untested |
| | SYS-009 | Setup Script Extensions | STP-009-B | Fault Injection | STS-009-B1 | ⬜ Untested |
| | SYS-009 | Setup Script Extensions | STP-009-B | Fault Injection | STS-009-B2 | ⬜ Untested |
| **REQ-NF-005** | SYS-012 | CI Evaluation Suite Extension | STP-012-A | Fault Injection | STS-012-A1 | ⬜ Untested |
| | SYS-012 | CI Evaluation Suite Extension | STP-012-A | Fault Injection | STS-012-A2 | ⬜ Untested |
| | SYS-012 | CI Evaluation Suite Extension | STP-012-A | Fault Injection | STS-012-A3 | ⬜ Untested |
| | SYS-012 | CI Evaluation Suite Extension | STP-012-B | Boundary Value Analysis | STS-012-B1 | ⬜ Untested |
| | SYS-012 | CI Evaluation Suite Extension | STP-012-B | Boundary Value Analysis | STS-012-B2 | ⬜ Untested |

### Matrix B Coverage

| Metric | Value |
|--------|-------|
| **Total System Components (SYS)** | 12 |
| **Total System Test Cases (STP)** | 27 |
| **Total System Scenarios (STS)** | 64 |
| **REQ → SYS Coverage** | 61/61 (100%) |
| **SYS → STP Coverage** | 12/12 (100%) |

## Gap Analysis

### Uncovered Requirements (REQ without ATP)

None — full coverage.

### Orphaned Test Cases (ATP without valid REQ)

None — all tests trace to requirements.

### Uncovered Requirements — System Level (REQ without SYS)

None — full coverage.

### Orphaned System Test Cases (STP without valid SYS)

None — all system tests trace to components.

## Audit Notes

- **Matrix generated by**: `build-matrix.sh` (deterministic regex parser)
- **Source documents**: `requirements.md`, `acceptance-plan.md`, `system-design.md`, `system-test.md`
- **Last validated**: 2026-02-21
