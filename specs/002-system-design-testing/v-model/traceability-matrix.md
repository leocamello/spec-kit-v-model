# Traceability Matrix

**Generated**: 2026-04-19
**Source**: `specs/002-system-design-testing/v-model//`

## Matrix A — Validation (User View)

| Requirement ID | Requirement Description | Test Case ID (ATP) | Validation Condition | Scenario ID (SCN) | Status |
|----------------|------------------------|--------------------|----------------------|--------------------|--------|
| **REQ-001** | The extension SHALL provide a `/speckit.v-model.system-design` command that reads `requirements.md` as input and produces `system-design.md` as output. | ATP-001-A | Happy Path — Command Produces system-design.md | SCN-001-A1 | ⬜ Untested |
| | | ATP-001-B | Error — Missing requirements.md | SCN-001-B1 | ⬜ Untested |
| **REQ-002** | The `/speckit.v-model.system-design` command SHALL assign each system component a unique `SYS-NNN` identifier (e.g., `SYS-001`, `SYS-002`), sequentially numbered and never renumbered once assigned. | ATP-002-A | Sequential SYS-NNN Format | SCN-002-A1 | ⬜ Untested |
| | | ATP-002-B | Identifier Permanence on Re-run | SCN-002-B1 | ⬜ Untested |
| **REQ-003** | The `system-design.md` output SHALL include a **Decomposition View** listing all major subsystems and components, with each component's name, description, and list of parent `REQ-NNN` identifiers. | ATP-003-A | Required Fields Present | SCN-003-A1 | ⬜ Untested |
| **REQ-004** | The `system-design.md` output SHALL include a **Dependency View** documenting inter-component relationships and failure propagation paths between `SYS-NNN` components. | ATP-004-A | Inter-Component Relationships Documented | SCN-004-A1 | ⬜ Untested |
| **REQ-005** | The `system-design.md` output SHALL include an **Interface View** documenting API contracts, data formats, communication protocols, and hardware-software boundaries for each component's inputs and outputs. | ATP-005-A | API Contracts and Protocols Documented | SCN-005-A1 | ⬜ Untested |
| **REQ-006** | The `system-design.md` output SHALL include a **Data Design View** documenting data structures, storage mechanisms, and data protection measures (at rest and in transit). | ATP-006-A | Data Structures and Protection Documented | SCN-006-A1 | ⬜ Untested |
| **REQ-007** | Each `SYS-NNN` component SHALL trace to one or more `REQ-NNN` identifiers via an explicit "Parent Requirements" field in the Decomposition View. | ATP-007-A | Every SYS-NNN Traces to REQ-NNN | SCN-007-A1 | ⬜ Untested |
| | | ATP-007-B | Orphaned Component Detection | SCN-007-B1 | ⬜ Untested |
| **REQ-008** | The system design command SHALL support many-to-many REQ↔SYS relationships: a single `REQ-NNN` MAY map to multiple `SYS-NNN` components, and a single `SYS-NNN` component MAY satisfy multiple `REQ-NNN` identifiers. | ATP-008-A | Single REQ Maps to Multiple SYS | SCN-008-A1 | ⬜ Untested |
| | | ATP-008-B | Single SYS Satisfies Multiple REQs | SCN-008-B1 | ⬜ Untested |
| **REQ-009** | Non-functional requirements (performance, security, reliability) SHALL be addressed as cross-cutting quality attributes with explicit design decisions documented in the relevant IEEE 1016 views, not omitted. | ATP-009-A | Non-Functional REQs Not Omitted | SCN-009-A1 | ⬜ Untested |
| **REQ-010** | The extension SHALL provide a `/speckit.v-model.system-test` command that reads `system-design.md` as input and produces `system-test.md` as output. | ATP-010-A | Happy Path — Command Produces system-test.md | SCN-010-A1 | ⬜ Untested |
| | | ATP-010-B | Error — Missing system-design.md | SCN-010-B1 | ⬜ Untested |
| **REQ-011** | The `/speckit.v-model.system-test` command SHALL assign test case identifiers using the format `STP-NNN-X` (e.g., `STP-001-A`) where NNN matches the parent `SYS-NNN` and X is a sequential letter. | ATP-011-A | Test Case IDs Match Format | SCN-011-A1 | ⬜ Untested |
| **REQ-012** | The `/speckit.v-model.system-test` command SHALL assign test scenario identifiers using the format `STS-NNN-X#` (e.g., `STS-001-A1`) where NNN-X matches the parent `STP-NNN-X` and # is a sequential number. | ATP-012-A | Scenario IDs Match Format | SCN-012-A1 | ⬜ Untested |
| **REQ-013** | Each system test case (`STP-NNN-X`) SHALL reference the specific IEEE 1016 design view it targets (Decomposition, Dependency, Interface, or Data Design). | ATP-013-A | Each STP References a Design View | SCN-013-A1 | ⬜ Untested |
| **REQ-014** | Each system test case (`STP-NNN-X`) SHALL apply a named ISO 29119 test technique: Interface Contract Testing (targeting Interface View), Boundary Value Analysis / Equivalence Partitioning (targeting data limits), or Fault Injection / Negative Testing (targeting Dependency View). | ATP-014-A | Named Technique Applied | SCN-014-A1 | ⬜ Untested |
| **REQ-015** | Interface Contract test cases SHALL explicitly distinguish between **external system interfaces** (APIs exposed to users or external systems) and **internal component interfaces** (inter-module communication). | ATP-015-A | Interface Contract Tests Distinguish External from Internal | SCN-015-A1 | ⬜ Untested |
| **REQ-016** | System test scenarios (`STS-NNN-X#`) SHALL use Given/When/Then BDD structure with **technical, component-oriented language** (e.g., "Given the database connection pool is exhausted, When a new query is submitted, Then the system returns error code 503 within 200ms"), distinct from the user-centric language of acceptance scenarios (`SCN-NNN-X#`). | ATP-016-A | Component-Oriented Language Used | SCN-016-A1 | ⬜ Untested |
| | | ATP-016-B | No User-Centric Language in STS Scenarios | SCN-016-B1 | ⬜ Untested |
| **REQ-017** | The `/speckit.v-model.system-test` command SHALL invoke `validate-system-coverage.sh` as a post-generation coverage gate and include the validation result (pass/fail with coverage summary) in its output. | ATP-017-A | Script Invoked and Result Included | SCN-017-A1 | ⬜ Untested |
| **REQ-018** | The extension SHALL provide a `validate-system-coverage.sh` Bash script that deterministically validates forward coverage: every `REQ-NNN` in `requirements.md` has at least one corresponding `SYS-NNN` in `system-design.md`. | ATP-018-A | Full Forward Coverage | SCN-018-A1 | ⬜ Untested |
| | | ATP-018-B | Missing Forward Coverage Detected | SCN-018-B1 | ⬜ Untested |
| **REQ-019** | The `validate-system-coverage.sh` script SHALL deterministically validate backward coverage: every `SYS-NNN` in `system-design.md` has at least one corresponding `STP-NNN-X` in `system-test.md`. | ATP-019-A | Full Backward Coverage | SCN-019-A1 | ⬜ Untested |
| | | ATP-019-B | Missing Backward Coverage Detected | SCN-019-B1 | ⬜ Untested |
| **REQ-020** | The `validate-system-coverage.sh` script SHALL detect and report orphaned identifiers: any `SYS-NNN` not referenced as a parent in any `REQ-NNN`, and any `STP-NNN-X` whose parent `SYS-NNN` does not exist in `system-design.md`. | ATP-020-A | Orphaned SYS-NNN Without Parent REQ | SCN-020-A1 | ⬜ Untested |
| | | ATP-020-B | Orphaned STP-NNN-X Without Parent SYS | SCN-020-B1 | ⬜ Untested |
| **REQ-021** | The `validate-system-coverage.sh` script SHALL exit with code 0 when all coverage checks pass and code 1 when any gap or orphan is detected. | ATP-021-A | Exit 0 on Full Coverage | SCN-021-A1 | ⬜ Untested |
| | | ATP-021-B | Exit 1 on Any Gap | SCN-021-B1 | ⬜ Untested |
| **REQ-022** | The `validate-system-coverage.sh` script SHALL output human-readable gap reports listing each specific gap or orphan by ID (e.g., "REQ-003: no system component mapping found") suitable for CI log inspection. | ATP-022-A | Specific Gap Identification by ID | SCN-022-A1 | ⬜ Untested |
| **REQ-023** | The ID lineage encoding SHALL be consistent across all tiers: given any `STS-NNN-X#` identifier, a regex SHALL be able to extract the parent `STP-NNN-X`, grandparent `SYS-NNN`, and great-grandparent `REQ-NNN` without consulting any lookup table or external mapping file. | ATP-023-A | Regex Extraction of Full Lineage | SCN-023-A1 | ⬜ Untested |
| **REQ-024** | The `/speckit.v-model.trace` command SHALL be extended to produce **Matrix B (Verification)** — `REQ → SYS → STP → STS` — when `system-design.md` and `system-test.md` exist in the feature directory. | ATP-024-A | Matrix B Produced When System Artifacts Exist | SCN-024-A1 | ⬜ Untested |
| **REQ-025** | The `/speckit.v-model.trace` command SHALL produce **Matrix A (Validation)** — `REQ → ATP → SCN` — as a separate table from Matrix B, to prevent visual bloat in Markdown rendering. | ATP-025-A | Two Distinct Tables | SCN-025-A1 | ⬜ Untested |
| **REQ-026** | The `/speckit.v-model.trace` command SHALL remain backward compatible: when `system-design.md` and `system-test.md` are absent, the command SHALL produce only Matrix A with identical output to v0.1.0. | ATP-026-A | Matrix A Only When System Artifacts Absent | SCN-026-A1 | ⬜ Untested |
| **REQ-027** | Each matrix SHALL include an independently calculated coverage percentage that matches the output of the corresponding deterministic validation script. | ATP-027-A | Matrix Coverage Matches Deterministic Script | SCN-027-A1 | ⬜ Untested |
| **REQ-028** | The `build-matrix.sh` script SHALL be extended to parse `system-design.md` and `system-test.md` to generate Matrix B data. | ATP-028-A | Parses System Design and System Test Files | SCN-028-A1 | ⬜ Untested |
| **REQ-029** | The `build-matrix.ps1` script SHALL be extended with identical Matrix B generation logic as `build-matrix.sh`. | ATP-029-A | Identical Matrix B Output | SCN-029-A1 | ⬜ Untested |
| **REQ-030** | The extension SHALL provide a `system-design-template.md` in the `templates/` directory defining the required structure for IEEE 1016-compliant system design output. | ATP-030-A | Template Available in templates/ Directory | SCN-030-A1 | ⬜ Untested |
| **REQ-031** | The extension SHALL provide a `system-test-template.md` in the `templates/` directory defining the required structure for ISO 29119-compliant system test output with the three-tier STP/STS hierarchy. | ATP-031-A | Template Available with Three-Tier Structure | SCN-031-A1 | ⬜ Untested |
| **REQ-032** | The `/speckit.v-model.system-design` command SHALL follow the strict translator constraint: when deriving from `requirements.md`, the AI SHALL NOT invent, infer, or add system components for capabilities not present in the requirements. | ATP-032-A | No Invented Components | SCN-032-A1 | ⬜ Untested |
| | | ATP-032-B | Hallucinated Component Absent | SCN-032-B1 | ⬜ Untested |
| **REQ-033** | The `/speckit.v-model.system-test` command SHALL follow the strict translator constraint: when deriving from `system-design.md`, the AI SHALL NOT invent test cases for components or interfaces not present in the design. | ATP-033-A | No Invented Test Cases | SCN-033-A1 | ⬜ Untested |
| **REQ-034** | When the system design process identifies a necessary technical capability not present in `requirements.md` (a Derived Requirement), the command SHALL flag it as `[DERIVED REQUIREMENT: description]` in the output instead of silently adding a `SYS-NNN` component. | ATP-034-A | Flag Displayed Instead of Silent Addition | SCN-034-A1 | ⬜ Untested |
| **REQ-035** | [DEPRECATED — Superseded by REQ-038] When the project's `v-model-config.yml` explicitly enables a regulated domain (e.g., `iso_26262`, `do_178c`), the `/speckit.v-model.system-design` command SHALL generate **Freedom from Interference (FFI)** analysis and **Restricted Complexity** assessment sections in `system-design.md` for each `SYS-NNN` component. | ATP-035-A | Sections Generated When Regulated Domain Enabled | SCN-035-A1 | ⬜ Untested |
| | | ATP-035-B | Sections Absent When Domain Not Configured | SCN-035-B1 | ⬜ Untested |
| **REQ-036** | [DEPRECATED — Superseded by REQ-039] When the project's `v-model-config.yml` explicitly enables a regulated domain (e.g., `do_178c`, `iso_26262`), the `/speckit.v-model.system-test` command SHALL generate **Modified Condition/Decision Coverage (MC/DC)** test obligations and **Worst-Case Execution Time (WCET)** verification scenarios in `system-test.md` for each `STP-NNN-X` test case where applicable. | ATP-036-A | Sections Generated When Regulated Domain Enabled | SCN-036-A1 | ⬜ Untested |
| | | ATP-036-B | Sections Absent When Domain Not Configured | SCN-036-B1 | ⬜ Untested |
| **REQ-037** | *(v0.2.1 patch)* The `validate-system-coverage.sh` script SHALL support **partial validation**: when `system-test.md` is absent, the script SHALL validate forward coverage (`REQ→SYS`) only, gracefully bypass `SYS→STP→STS` backward coverage checks, and exit with code 0 if forward coverage is complete. The output SHALL clearly indicate partial validation mode. | ATP-037-A | Forward-Only Validation When system-test.md Absent | SCN-037-A1 | ⬜ Untested |
| | | ATP-037-B | Partial Mode Reports Forward Gaps | SCN-037-B1 | ⬜ Untested |
| **REQ-038** | When `v-model-config.yml` specifies a `domain` value (e.g., `iso_26262`, `do_178c`, `iec_62304`), the `/speckit.v-model.system-design` command SHALL load the corresponding domain overlay from `commands/overlays/{domain}/system-design.md` and include the overlay's safety-critical design sections (e.g., FFI analysis, restricted complexity, safety integrity allocation) in `system-design.md` in preference to the base command's generic guidance. | ATP-038-A | Overlay loaded when domain is set | SCN-038-A1 | ⬜ Untested |
| | | ATP-038-A | Overlay loaded when domain is set | SCN-038-A2 | ⬜ Untested |
| | | ATP-038-B | Graceful fallback when overlay missing | SCN-038-B1 | ⬜ Untested |
| **REQ-039** | When `v-model-config.yml` specifies a `domain` value (e.g., `iso_26262`, `do_178c`, `iec_62304`), the `/speckit.v-model.system-test` command SHALL load the corresponding domain overlay from `commands/overlays/{domain}/system-test.md` and include the overlay's safety-critical test sections (e.g., structural coverage obligations, WCET verification) in `system-test.md` in preference to the base command's generic guidance. | ATP-039-A | Overlay loaded when domain is set | SCN-039-A1 | ⬜ Untested |
| | | ATP-039-A | Overlay loaded when domain is set | SCN-039-A2 | ⬜ Untested |
| | | ATP-039-B | Graceful fallback when overlay missing | SCN-039-B1 | ⬜ Untested |
| **REQ-040** | The `/speckit.v-model.system-design` command description and goal SHALL use generic design framing (e.g., "IEEE 1016 design description") without referencing specific safety standards (ISO 26262, DO-178C) in the base command text. Domain-specific design guidance SHALL be provided only by loaded overlays. | ATP-040-A | Command text uses generic framing | SCN-040-A1 | ⬜ Untested |
| | | ATP-040-A | Command text uses generic framing | SCN-040-A2 | ⬜ Untested |
| | | ATP-040-B | Domain-specific guidance only from overlays | SCN-040-B1 | ⬜ Untested |
| **REQ-041** | The `/speckit.v-model.system-test` command description and goal SHALL use generic testing framing (e.g., "ISO 29119 test design") without referencing specific safety standards (DO-178C, ISO 26262) in the base command text. Domain-specific test guidance SHALL be provided only by loaded overlays. | ATP-041-A | Command text uses generic framing | SCN-041-A1 | ⬜ Untested |
| | | ATP-041-A | Command text uses generic framing | SCN-041-A2 | ⬜ Untested |
| | | ATP-041-B | Domain-specific guidance only from overlays | SCN-041-B1 | ⬜ Untested |
| **REQ-042** | When no `domain` is set in `v-model-config.yml` (or no config file exists), the system-design and system-test commands SHALL produce general-purpose output without loading any domain overlay. Safety-critical sections SHALL be omitted entirely. | ATP-042-A | No overlays loaded when domain absent | SCN-042-A1 | ⬜ Untested |
| | | ATP-042-B | Config exists but domain field absent | SCN-042-B1 | ⬜ Untested |
| **REQ-043** | All generative commands in this feature SHALL support domain overlay loading via the assembly protocol: when `domain` is configured, the system SHALL load domain-specific guidance from `commands/overlays/{domain}/{command}.md` and template overlays from `templates/overlays/{domain}/{template}.md`, applying overlay content alongside the base command. | ATP-043-A | All generative commands support overlay loading | SCN-043-A1 | ⬜ Untested |
| | | ATP-043-B | Assembly protocol graceful when overlay directory missing | SCN-043-B1 | ⬜ Untested |
| **REQ-CN-001** | [DEPRECATED — Superseded by REQ-042] Safety-critical sections (Freedom from Interference, Restricted Complexity, MC/DC Coverage, WCET Analysis) SHALL be omitted by default and only included when the project's `v-model-config.yml` explicitly enables a regulated domain (ISO 26262, DO-178C, or IEC 62304). | ATP-CN-001-A | No Safety Sections Without Config | SCN-CN-001-A1 | ⬜ Untested |
| | | ATP-CN-001-B | Sections Present Only When Explicitly Enabled | SCN-CN-001-B1 | ⬜ Untested |
| **REQ-CN-002** | The extension version in `extension.yml` SHALL be bumped to `0.2.0` and SHALL register exactly 5 commands (3 existing + 2 new) and 1 hook. | ATP-CN-002-A | Version Bumped to 0.2.0 with Correct Command Count | SCN-CN-002-A1 | ⬜ Untested |
| **REQ-CN-003** | The extension SHALL provide `validate-system-coverage.ps1` (PowerShell) with identical behavior, output format, and exit codes as the Bash script, passing the same test fixture suite. | ATP-CN-003-A | Identical Behavior and Output | SCN-CN-003-A1 | ⬜ Untested |
| **REQ-IF-001** | The `/speckit.v-model.system-design` command SHALL read its input exclusively from `{FEATURE_DIR}/v-model/requirements.md` and write its output exclusively to `{FEATURE_DIR}/v-model/system-design.md`. | ATP-IF-001-A | Reads from requirements.md, Writes to system-design.md | SCN-IF-001-A1 | ⬜ Untested |
| **REQ-IF-002** | The `/speckit.v-model.system-test` command SHALL read its input exclusively from `{FEATURE_DIR}/v-model/system-design.md` and write its output exclusively to `{FEATURE_DIR}/v-model/system-test.md`. | ATP-IF-002-A | Reads from system-design.md, Writes to system-test.md | SCN-IF-002-A1 | ⬜ Untested |
| **REQ-IF-003** | The `validate-system-coverage.sh` script SHALL accept three file paths as arguments: `requirements.md`, `system-design.md`, and `system-test.md`, in that order. | ATP-IF-003-A | Accepts Three File Paths as Arguments | SCN-IF-003-A1 | ⬜ Untested |
| **REQ-IF-004** | The `validate-system-coverage.sh` script SHALL output a structured coverage summary to stdout in the same format as `validate-requirement-coverage.sh` (section headers, gap lists, pass/fail verdict, coverage percentages). | ATP-IF-004-A | Consistent Format with validate-requirement-coverage.sh | SCN-IF-004-A1 | ⬜ Untested |
| **REQ-NF-001** | The `validate-system-coverage.sh` script SHALL use regex-based parsing consistent with `validate-requirement-coverage.sh` from v0.1.0, requiring no runtime database or external tooling beyond standard Bash utilities. | ATP-NF-001-A | Script Uses Only Bash Builtins and Standard Utilities | SCN-NF-001-A1 | ⬜ Untested |
| **REQ-NF-002** | The `/speckit.v-model.system-design` and `/speckit.v-model.system-test` commands SHALL handle input files with 200 or more `REQ-NNN` identifiers without truncation, data loss, or degraded output quality. | ATP-NF-002-A | No Truncation with 200 Requirements | SCN-NF-002-A1 | ⬜ Untested |
| **REQ-NF-003** | The `validate-system-coverage.sh` script SHALL accept gaps in `SYS-NNN` numbering (e.g., SYS-001, SYS-003 without SYS-002) without reporting false-positive errors. | ATP-NF-003-A | Gaps Accepted Without False Positives | SCN-NF-003-A1 | ⬜ Untested |
| **REQ-NF-004** | All v0.2.0 commands and scripts SHALL preserve backward compatibility: existing `requirements.md`, `acceptance-plan.md`, and `traceability-matrix.md` files SHALL NOT be modified by any v0.2.0 operation. | ATP-NF-004-A | Existing v0.1.0 Files Unchanged | SCN-NF-004-A1 | ⬜ Untested |
| **REQ-NF-005** | (Internal QA gate — not user-facing) The extension's CI evaluation suite SHALL validate that `/speckit.v-model.system-design` and `/speckit.v-model.system-test` command outputs meet or exceed the quality thresholds established for v0.1.0 artifacts. End users do not interact with the evaluation framework; this requirement ensures prompt quality through automated regression testing in the development pipeline. | ATP-NF-005-A | Evaluation Suite Validates Command Output Quality | SCN-NF-005-A1 | ⬜ Untested |
| **REQ-NF-006** | Commands SHALL be domain-agnostic in their base form; adding a new regulated domain SHALL require only adding overlay files with no modification to base commands or templates. | ATP-NF-006-A | New domain requires only overlay files | SCN-NF-006-A1 | ⬜ Untested |
| | | ATP-NF-006-B | Base commands unchanged after adding domain | SCN-NF-006-B1 | ⬜ Untested |

### Matrix A Coverage

| Metric | Value |
|--------|-------|
| **Total Requirements** | 56 |
| **Total Test Cases (ATP)** | 78 |
| **Total Scenarios (SCN)** | 82 |
| **REQ → ATP Coverage** | 56/56 (100%) |
| **ATP → SCN Coverage** | 78/78 (100%) |


### Uncovered Requirements (REQ without ATP)

None — full coverage.

### Orphaned Test Cases (ATP without valid REQ)

None — all tests trace to requirements.

## Audit Notes

- **Matrix generated by**: `build-matrix.sh` (deterministic regex parser)
- **Source documents**: `requirements.md`, `acceptance-plan.md`, `unit-test.md`
- **Last validated**: 2026-04-19
