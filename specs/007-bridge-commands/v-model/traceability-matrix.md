# Traceability Matrix

**Generated**: 2026-04-26
**Source**: `specs/007-bridge-commands/v-model/`

## Matrix A — Validation (User View)

| Requirement ID | Requirement Description | Test Case ID (ATP) | Validation Condition | Scenario ID (SCN) | Status |
|----------------|------------------------|--------------------|----------------------|--------------------|--------|
| **REQ-001** | The `v-model.plan` command SHALL read every V-Model artifact present in the feature directory: `requirements.md`, `acceptance-plan.md`, `system-design.md`, `system-test.md`, `architecture-design.md`, `integration-test.md`, `module-design.md`, `unit-test.md`, `hazard-analysis.md`, and `traceability-matrix.md`, plus the project constitution. | ATP-001-A | Happy path — full artifact set | SCN-001-A1 | ⬜ Untested |
| | | ATP-001-B | Subset — only required artifacts present | SCN-001-B1 | ⬜ Untested |
| **REQ-002** | The `v-model.plan` command SHALL produce a `plan.md` file in the feature directory that conforms to spec-kit core's canonical `plan-template.md` schema. | ATP-002-A | Schema conformance against canonical template | SCN-002-A1 | ⬜ Untested |
| | | ATP-002-B | Section ordering preserved | SCN-002-B1 | ⬜ Untested |
| **REQ-003** | The `v-model.plan` command SHALL produce a `data-model.md` file extracted from the Data Design view of `system-design.md`. | ATP-003-A | Data model extracted faithfully | SCN-003-A1 | ⬜ Untested |
| **REQ-004** | The `v-model.plan` command SHALL produce a `contracts/` directory containing interface contract files extracted from the Interface view of `architecture-design.md`. | ATP-004-A | Contracts directory populated from interfaces | SCN-004-A1 | ⬜ Untested |
| **REQ-005** | The `v-model.plan` command SHALL produce a `quickstart.md` file extracted from the BDD scenarios of `acceptance-plan.md`, prioritising the top critical user paths. | ATP-005-A | Top critical paths included | SCN-005-A1 | ⬜ Untested |
| **REQ-006** | The `v-model.plan` command SHALL produce a `research.md` file populated with any `[DERIVED REQUIREMENT]` or `[DERIVED MODULE]` flags encountered during synthesis, each linked to the artifact that introduced the derivation. | ATP-006-A | Derivation flags surfaced | SCN-006-A1 | ⬜ Untested |
| **REQ-007** | The `v-model.plan` command SHALL embed V-Model traceability metadata in its outputs as HTML comments and optional Markdown sections such that spec-kit core tooling parses the documents without error and ignores the embedded enrichment. | ATP-007-A | HTML comments do not break core parser | SCN-007-A1 | ⬜ Untested |
| | | ATP-007-B | Optional V-Model sections ignored by core | SCN-007-B1 | ⬜ Untested |
| **REQ-008** | When one or more V-Model artifacts are absent from the feature directory, the `v-model.plan` command SHALL omit the corresponding output sections, complete successfully with a non-zero warning indicator in its summary, and list each missing artifact by name. | ATP-008-A | Missing optional artifacts handled cleanly | SCN-008-A1 | ⬜ Untested |
| **REQ-009** | The `v-model.tasks` command SHALL read every V-Model artifact present in the feature directory, plus `plan.md` if it exists, regardless of whether the `plan.md` was produced by `v-model.plan` or by `speckit.plan`. | ATP-009-A | Consumes a `v-model.plan`-produced plan | SCN-009-A1 | ⬜ Untested |
| | | ATP-009-B | Consumes a `speckit.plan`-produced plan | SCN-009-B1 | ⬜ Untested |
| **REQ-010** | The `v-model.tasks` command SHALL produce a `tasks.md` file in the feature directory that conforms to spec-kit core's canonical `tasks-template.md` schema. | ATP-010-A | Schema conformance and round-trip | SCN-010-A1 | ⬜ Untested |
| **REQ-011** | The `v-model.tasks` command SHALL order the emitted tasks TDD-style in the following sequence: write unit tests, implement modules, run unit tests, write integration tests, run integration tests, write system tests, run system tests, write acceptance tests. | ATP-011-A | Order matches the prescribed sequence | SCN-011-A1 | ⬜ Untested |
| **REQ-012** | The `v-model.tasks` command SHALL embed traceability metadata for each task as an HTML comment using the form `<!-- traces-to: MOD-NNN → ARCH-NNN → SYS-NNN → REQ-NNN -->`, naming every upstream V-Model ID the task fulfils. | ATP-012-A | Every task carries a trace-to comment | SCN-012-A1 | ⬜ Untested |
| **REQ-013** | The `v-model.tasks` command SHALL mark independent modules within the same architecture with the `[P]` parallel-execution marker exactly as defined by spec-kit core's tasks schema. | ATP-013-A | Independent modules get the parallel marker | SCN-013-A1 | ⬜ Untested |
| **REQ-014** | When `hazard-analysis.md` is present in the feature directory, the `v-model.tasks` command SHALL flag mitigation tasks as higher priority and SHALL emit dedicated verification tasks that explicitly reference each `HAZ-NNN` identifier. | ATP-014-A | Mitigation tasks flagged higher priority | SCN-014-A1 | ⬜ Untested |
| | | ATP-014-B | Dedicated verification tasks emitted per HAZ | SCN-014-B1 | ⬜ Untested |
| **REQ-015** | The `v-model.implement` command SHALL read all V-Model artifacts directly from the feature directory without requiring a `plan.md` or `tasks.md` to be present. | ATP-015-A | Run without `plan.md` or `tasks.md` | SCN-015-A1 | ⬜ Untested |
| **REQ-016** | The `v-model.implement` command SHALL refuse to start when Matrix A, B, C, D, or H is incomplete, MUST exit with a non-zero exit code, and MUST produce a gap report to stdout naming each incomplete matrix and the rows that are missing required IDs. | ATP-016-A | Refusal on Matrix A gap | SCN-016-A1 | ⬜ Untested |
| | | ATP-016-B | Refusal on Matrix H gap | SCN-016-B1 | ⬜ Untested |
| **REQ-017** | The `v-model.implement` command SHALL invoke the existing `build-matrix`, `validate-requirement-coverage`, `validate-system-coverage`, `validate-architecture-coverage`, `validate-integration-coverage`, and `validate-module-coverage` scripts as its pre-implementation gate. | ATP-017-A | No new wrapper script invoked | SCN-017-A1 | ⬜ Untested |
| **REQ-018** | The `v-model.implement` command SHALL generate source code into the file paths declared by the Target Source File field of each `MOD-NNN` entry in `module-design.md`. | ATP-018-A | Code lands at declared paths | SCN-018-A1 | ⬜ Untested |
| **REQ-019** | Every public function, class, or module produced by `v-model.implement` SHALL carry a comment of the form `// Implements <ID> (traces to <upstream-ID>)` (or the equivalent comment syntax for the target language) linking it to the V-Model identifier it realises. | ATP-019-A | Every public symbol carries an Implements comment | SCN-019-A1 | ⬜ Untested |
| **REQ-020** | The `v-model.implement` command SHALL generate tests at four levels — unit, integration, system, and acceptance — matching the corresponding V-Model test plans (UTP/UTS, ITP/ITS, STP/STS, ATP/SCN). | ATP-020-A | UTS, ITS, STS, SCN all produced | SCN-020-A1 | ⬜ Untested |
| **REQ-021** | Commits produced by `v-model.implement` SHALL include the implementing V-Model identifiers in the commit message, formatted as a comma-separated suffix (e.g., `feat(<scope>): <subject> — MOD-NNN, REQ-NNN`). | ATP-021-A | Commit subject contains the ID list suffix | SCN-021-A1 | ⬜ Untested |
| **REQ-022** | The `v-model.implement` command SHALL NOT overwrite source-file content that lies outside the regions managed by the V-Model, and SHALL preserve user customisations located between V-Model-managed regions when re-running. | ATP-022-A | Code outside managed region untouched | SCN-022-A1 | ⬜ Untested |
| | | ATP-022-B | User customisations between managed regions preserved | SCN-022-B1 | ⬜ Untested |
| **REQ-023** | The `v-model.implement` command SHALL self-verify, before committing any output, that every `// Implements <ID>` comment it generated references an identifier that exists in the feature's V-Model artifacts; if any hallucinated identifier is detected the command MUST exit non-zero and MUST NOT commit. | ATP-023-A | Hallucinated ID detected; no commit | SCN-023-A1 | ⬜ Untested |
| **REQ-024** | The `v-model.implement` command SHALL honour the configured domain overlay (read from `v-model-config.yml`) by applying overlay-specific output requirements, including but not limited to MC/DC unit-test coverage requirements for DO-178C Level A and ASIL-driven test depth for ISO 26262. | ATP-024-A | DO-178C Level A overlay enforces MC/DC tests | SCN-024-A1 | ⬜ Untested |
| | | ATP-024-B | Configured-but-unloadable overlay fails closed without partial application | SCN-024-B1 | ⬜ Untested |
| | | ATP-024-B | Configured-but-unloadable overlay fails closed without partial application | SCN-024-B2 | ⬜ Untested |
| **REQ-025** | The `v-model.implement` command SHALL be idempotent: re-running it on identical inputs MUST produce output that differs only in non-substantive ways (LLM phrasing variability), measured as ≥95% structural identity by the project's structural eval comparison. | ATP-025-A | Re-run produces structurally equivalent output | SCN-025-A1 | ⬜ Untested |
| **REQ-026** | All three bridge commands SHALL be invocable from the spec-kit CLI under the names `/speckit.v-model.plan`, `/speckit.v-model.tasks`, and `/speckit.v-model.implement` respectively. | ATP-026-A | All three names registered | SCN-026-A1 | ⬜ Untested |
| **REQ-027** | All three bridge commands SHALL produce a structured summary on stdout indicating: every input artifact read, every output artifact produced, every optional artifact skipped, and every warning encountered. | ATP-027-A | Summary contains required fields | SCN-027-A1 | ⬜ Untested |
| **REQ-028** | When V-Model enrichment is absent in upstream artifacts (for example, a `plan.md` produced by `speckit.plan` rather than `v-model.plan`), bridge commands that consume those artifacts SHALL proceed with reduced enrichment rather than failing. | ATP-028-A | Pure spec-kit core upstream → reduced enrichment, no failure | SCN-028-A1 | ⬜ Untested |
| **REQ-029** | A `plan.md` produced by `v-model.plan` SHALL be valid input to unmodified `speckit.tasks`, and a `tasks.md` produced by `v-model.tasks` SHALL be valid input to unmodified `speckit.implement`, in 100% of cases covered by the round-trip test fixtures. | ATP-029-A | `v-model.plan` → `speckit.tasks` | SCN-029-A1 | ⬜ Untested |
| | | ATP-029-B | `v-model.tasks` → `speckit.implement` | SCN-029-B1 | ⬜ Untested |
| **REQ-CN-001** | The bridge commands SHALL NOT require any modification to the upstream spec-kit core repository; they MUST function correctly against the unmodified spec-kit core release pinned at v0.7.0 release time. | ATP-CN-001-A | Pinned spec-kit core unchanged at merge time | SCN-CN-001-A1 | ⬜ Untested |
| **REQ-CN-002** | The `v-model.implement` command SHALL NOT introduce any new wrapper script that duplicates the gating logic of `build-matrix` or `validate-*-coverage`; reuse of the existing scripts is mandatory. | ATP-CN-002-A | No new wrapper script under `scripts/` | SCN-CN-002-A1 | ⬜ Untested |
| **REQ-CN-003** | The bridge commands SHALL NOT introduce a new orchestrator agent, supervisor architecture, model tiering, sandbox-execution isolation, correlation log, or workflow-YAML single-command V-cycle orchestrator under v0.7.0; those capabilities are explicitly deferred to milestones M2 and M3. | ATP-CN-003-A | Diff contains none of the deferred capabilities | SCN-CN-003-A1 | ⬜ Untested |
| **REQ-CN-004** | The bridge commands SHALL be developed under the project's "dogfood-driven development" discipline: the V-Model artifacts for `specs/007-bridge-commands/` SHALL be produced and validated before any bridge-command implementation code is written. | ATP-CN-004-A | V-Model artifacts present before any bridge-command code | SCN-CN-004-A1 | ⬜ Untested |
| **REQ-IF-001** | The `v-model.plan` command output `plan.md` SHALL conform exactly to spec-kit core's canonical `plan-template.md` schema as published at v0.7.0 release time, with all required sections present and in the prescribed order. | ATP-IF-001-A | Section presence and order match canonical | SCN-IF-001-A1 | ⬜ Untested |
| **REQ-IF-002** | The `v-model.tasks` command output `tasks.md` SHALL conform exactly to spec-kit core's canonical `tasks-template.md` schema as published at v0.7.0 release time, including the `[P]` parallel-execution marker convention. | ATP-IF-002-A | Schema and parallel marker convention honoured | SCN-IF-002-A1 | ⬜ Untested |
| **REQ-IF-003** | The `v-model.implement` command SHALL register the `before_implement` and `after_implement` extension hooks to invoke the `v-model.trace` command. | ATP-IF-003-A | `extensions.yml` registers `before_implement` and `after_implement` hooks | SCN-IF-003-A1 | ⬜ Untested |
| **REQ-IF-004** | All three bridge commands SHALL emit their structured stdout summary in a format machine-readable by the project's existing summary-parsing tooling (the same conventions used by `v-model.test-results` and `v-model.audit-report`). | ATP-IF-004-A | Summary parser shared with `test-results` and `audit-report` succeeds | SCN-IF-004-A1 | ⬜ Untested |
| **REQ-IF-005** | The `/speckit.v-model.requirements` command SHALL be reachable via the `after_specify` hook. | ATP-IF-005-A | `extensions.yml` registers `after_specify` hook | SCN-IF-005-A1 | ⬜ Untested |
| **REQ-NF-001** | The bridge commands collectively SHALL achieve 100% test coverage across BATS, Pester, structural eval, and LLM eval test suites before merge into `main`. | ATP-NF-001-A | BATS, Pester, structural, LLM evals all present and green | SCN-NF-001-A1 | ⬜ Untested |
| **REQ-NF-002** | The `v-model.implement` command SHALL produce zero hallucinated V-Model identifiers in any generated artifact, measured as 100% pass rate on the structural-eval ID-validation check across all test fixtures. | ATP-NF-002-A | Structural eval reports zero hallucinated IDs across all fixtures | SCN-NF-002-A1 | ⬜ Untested |
| **REQ-NF-003** | All bridge command outputs intended for spec-kit core consumption SHALL parse without error, warning, or unrecognised-token diagnostic when processed by an unmodified spec-kit core release pinned at the version present at v0.7.0 release. | ATP-NF-003-A | Pinned spec-kit core release ingests bridge outputs cleanly | SCN-NF-003-A1 | ⬜ Untested |
| **REQ-NF-004** | When run on a feature with a known-incomplete traceability matrix, the `v-model.implement` command SHALL refuse to proceed in 100% of cases and SHALL produce a gap report identifying every missing matrix. | ATP-NF-004-A | Refusal verified across N gap fixtures | SCN-NF-004-A1 | ⬜ Untested |
| **REQ-NF-005** | When run on a feature missing one or more optional V-Model artifacts (e.g., `hazard-analysis.md`, `system-test.md`), all three bridge commands SHALL complete successfully and SHALL emit a summary that names each skipped artifact. | ATP-NF-005-A | All three commands complete with skipped-artifact summary | SCN-NF-005-A1 | ⬜ Untested |
| **REQ-NF-006** | The bridge commands SHALL NOT introduce any change to the existing extension hook infrastructure; only the registered hooks themselves are subject to modification under this feature. | ATP-NF-006-A | Diff of hook infrastructure code is empty | SCN-NF-006-A1 | ⬜ Untested |

### Matrix A Coverage

| Metric | Value |
|--------|-------|
| **Total Requirements** | 44 |
| **Total Test Cases (ATP)** | 53 |
| **Total Scenarios (SCN)** | 54 |
| **REQ → ATP Coverage** | 44/44 (100%) |
| **ATP → SCN Coverage** | 53/53 (100%) |

## Matrix B — Verification (Architectural View)

| Requirement ID | System Component (SYS) | Component Name | Test Case ID (STP) | Technique | Scenario ID (STS) | Status |
|----------------|------------------------|----------------|--------------------|-----------|--------------------|--------|
| **REQ-001** | SYS-001 | Plan Synthesizer | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| **REQ-002** | SYS-001 | Plan Synthesizer | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| **REQ-003** | SYS-001 | Plan Synthesizer | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| **REQ-004** | SYS-001 | Plan Synthesizer | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| **REQ-005** | SYS-001 | Plan Synthesizer | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| **REQ-006** | SYS-001 | Plan Synthesizer | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| **REQ-007** | SYS-005 | Additive-Enrichment Encoder | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Additive-Enrichment Encoder | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Additive-Enrichment Encoder | STP-005-B | Boundary Value Analysis | STS-005-B1 | ⬜ Untested |
| | SYS-005 | Additive-Enrichment Encoder | STP-005-B | Boundary Value Analysis | STS-005-B2 | ⬜ Untested |
| **REQ-008** | SYS-001 | Plan Synthesizer | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| **REQ-009** | SYS-002 | Tasks Synthesizer | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| **REQ-010** | SYS-002 | Tasks Synthesizer | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| **REQ-011** | SYS-002 | Tasks Synthesizer | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| **REQ-012** | SYS-005 | Additive-Enrichment Encoder | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Additive-Enrichment Encoder | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Additive-Enrichment Encoder | STP-005-B | Boundary Value Analysis | STS-005-B1 | ⬜ Untested |
| | SYS-005 | Additive-Enrichment Encoder | STP-005-B | Boundary Value Analysis | STS-005-B2 | ⬜ Untested |
| **REQ-013** | SYS-002 | Tasks Synthesizer | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| **REQ-014** | SYS-002 | Tasks Synthesizer | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| | SYS-009 | Hazard-Driven Task Emitter | STP-009-A | Interface Contract Testing | STS-009-A1 | ⬜ Untested |
| **REQ-015** | SYS-003 | Implementation Engine | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C3 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C4 | ⬜ Untested |
| **REQ-016** | SYS-004 | Pre-Implementation Gate | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Pre-Implementation Gate | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Pre-Implementation Gate | STP-004-B | Equivalence Partitioning | STS-004-B1 | ⬜ Untested |
| | SYS-004 | Pre-Implementation Gate | STP-004-B | Equivalence Partitioning | STS-004-B2 | ⬜ Untested |
| | SYS-004 | Pre-Implementation Gate | STP-004-B | Equivalence Partitioning | STS-004-B3 | ⬜ Untested |
| **REQ-017** | SYS-004 | Pre-Implementation Gate | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Pre-Implementation Gate | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Pre-Implementation Gate | STP-004-B | Equivalence Partitioning | STS-004-B1 | ⬜ Untested |
| | SYS-004 | Pre-Implementation Gate | STP-004-B | Equivalence Partitioning | STS-004-B2 | ⬜ Untested |
| | SYS-004 | Pre-Implementation Gate | STP-004-B | Equivalence Partitioning | STS-004-B3 | ⬜ Untested |
| **REQ-018** | SYS-003 | Implementation Engine | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C3 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C4 | ⬜ Untested |
| **REQ-019** | SYS-003 | Implementation Engine | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C3 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C4 | ⬜ Untested |
| **REQ-020** | SYS-003 | Implementation Engine | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C3 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C4 | ⬜ Untested |
| **REQ-021** | SYS-003 | Implementation Engine | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C3 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C4 | ⬜ Untested |
| | SYS-014 | Commit Annotator | STP-014-A | Interface Contract Testing | STS-014-A1 | ⬜ Untested |
| | SYS-014 | Commit Annotator | STP-014-A | Interface Contract Testing | STS-014-A2 | ⬜ Untested |
| **REQ-022** | SYS-003 | Implementation Engine | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C3 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C4 | ⬜ Untested |
| | SYS-007 | Source Region Manager | STP-007-A | Boundary Value Analysis | STS-007-A1 | ⬜ Untested |
| | SYS-007 | Source Region Manager | STP-007-A | Boundary Value Analysis | STS-007-A2 | ⬜ Untested |
| | SYS-007 | Source Region Manager | STP-007-A | Boundary Value Analysis | STS-007-A3 | ⬜ Untested |
| | SYS-007 | Source Region Manager | STP-007-B | Fault Injection | STS-007-B1 | ⬜ Untested |
| | SYS-007 | Source Region Manager | STP-007-B | Fault Injection | STS-007-B2 | ⬜ Untested |
| **REQ-023** | SYS-006 | Hallucination Guard | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Hallucination Guard | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| | SYS-006 | Hallucination Guard | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Hallucination Guard | STP-006-B | Equivalence Partitioning | STS-006-B2 | ⬜ Untested |
| | SYS-006 | Hallucination Guard | STP-006-B | Equivalence Partitioning | STS-006-B3 | ⬜ Untested |
| **REQ-024** | SYS-003 | Implementation Engine | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C3 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C4 | ⬜ Untested |
| | SYS-008 | Domain Overlay Adapter | STP-008-A | Interface Contract Testing | STS-008-A1 | ⬜ Untested |
| | SYS-008 | Domain Overlay Adapter | STP-008-A | Interface Contract Testing | STS-008-A2 | ⬜ Untested |
| | SYS-008 | Domain Overlay Adapter | STP-008-B | Fault Injection | STS-008-B1 | ⬜ Untested |
| **REQ-025** | SYS-003 | Implementation Engine | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C3 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C4 | ⬜ Untested |
| **REQ-026** | SYS-001 | Plan Synthesizer | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C3 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C4 | ⬜ Untested |
| **REQ-027** | SYS-001 | Plan Synthesizer | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C3 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C4 | ⬜ Untested |
| | SYS-012 | Structured Summary Reporter | STP-012-A | Interface Contract Testing | STS-012-A1 | ⬜ Untested |
| | SYS-012 | Structured Summary Reporter | STP-012-A | Interface Contract Testing | STS-012-A2 | ⬜ Untested |
| **REQ-028** | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-A | Interface Contract Testing | STS-010-A1 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-A | Interface Contract Testing | STS-010-A2 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-A | Interface Contract Testing | STS-010-A3 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-B | Equivalence Partitioning | STS-010-B1 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-B | Equivalence Partitioning | STS-010-B2 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-C | Boundary Value Analysis | STS-010-C1 | ⬜ Untested |
| **REQ-029** | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-A | Interface Contract Testing | STS-010-A1 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-A | Interface Contract Testing | STS-010-A2 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-A | Interface Contract Testing | STS-010-A3 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-B | Equivalence Partitioning | STS-010-B1 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-B | Equivalence Partitioning | STS-010-B2 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-C | Boundary Value Analysis | STS-010-C1 | ⬜ Untested |
| **REQ-CN-001** | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-A | Interface Contract Testing | STS-010-A1 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-A | Interface Contract Testing | STS-010-A2 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-A | Interface Contract Testing | STS-010-A3 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-B | Equivalence Partitioning | STS-010-B1 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-B | Equivalence Partitioning | STS-010-B2 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-C | Boundary Value Analysis | STS-010-C1 | ⬜ Untested |
| **REQ-CN-002** | SYS-004 | Pre-Implementation Gate | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Pre-Implementation Gate | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Pre-Implementation Gate | STP-004-B | Equivalence Partitioning | STS-004-B1 | ⬜ Untested |
| | SYS-004 | Pre-Implementation Gate | STP-004-B | Equivalence Partitioning | STS-004-B2 | ⬜ Untested |
| | SYS-004 | Pre-Implementation Gate | STP-004-B | Equivalence Partitioning | STS-004-B3 | ⬜ Untested |
| **REQ-CN-003** | SYS-013 | Quality & Process Compliance Harness | STP-013-A | Interface Contract Testing | STS-013-A1 | ⬜ Untested |
| | SYS-013 | Quality & Process Compliance Harness | STP-013-A | Interface Contract Testing | STS-013-A2 | ⬜ Untested |
| | SYS-013 | Quality & Process Compliance Harness | STP-013-B | Equivalence Partitioning | STS-013-B1 | ⬜ Untested |
| | SYS-013 | Quality & Process Compliance Harness | STP-013-B | Equivalence Partitioning | STS-013-B2 | ⬜ Untested |
| **REQ-CN-004** | SYS-013 | Quality & Process Compliance Harness | STP-013-A | Interface Contract Testing | STS-013-A1 | ⬜ Untested |
| | SYS-013 | Quality & Process Compliance Harness | STP-013-A | Interface Contract Testing | STS-013-A2 | ⬜ Untested |
| | SYS-013 | Quality & Process Compliance Harness | STP-013-B | Equivalence Partitioning | STS-013-B1 | ⬜ Untested |
| | SYS-013 | Quality & Process Compliance Harness | STP-013-B | Equivalence Partitioning | STS-013-B2 | ⬜ Untested |
| **REQ-IF-001** | SYS-001 | Plan Synthesizer | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| | SYS-005 | Additive-Enrichment Encoder | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Additive-Enrichment Encoder | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Additive-Enrichment Encoder | STP-005-B | Boundary Value Analysis | STS-005-B1 | ⬜ Untested |
| | SYS-005 | Additive-Enrichment Encoder | STP-005-B | Boundary Value Analysis | STS-005-B2 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-A | Interface Contract Testing | STS-010-A1 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-A | Interface Contract Testing | STS-010-A2 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-A | Interface Contract Testing | STS-010-A3 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-B | Equivalence Partitioning | STS-010-B1 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-B | Equivalence Partitioning | STS-010-B2 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-C | Boundary Value Analysis | STS-010-C1 | ⬜ Untested |
| **REQ-IF-002** | SYS-002 | Tasks Synthesizer | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| | SYS-005 | Additive-Enrichment Encoder | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Additive-Enrichment Encoder | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Additive-Enrichment Encoder | STP-005-B | Boundary Value Analysis | STS-005-B1 | ⬜ Untested |
| | SYS-005 | Additive-Enrichment Encoder | STP-005-B | Boundary Value Analysis | STS-005-B2 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-A | Interface Contract Testing | STS-010-A1 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-A | Interface Contract Testing | STS-010-A2 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-A | Interface Contract Testing | STS-010-A3 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-B | Equivalence Partitioning | STS-010-B1 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-B | Equivalence Partitioning | STS-010-B2 | ⬜ Untested |
| | SYS-010 | Spec-Kit Core Compatibility Layer | STP-010-C | Boundary Value Analysis | STS-010-C1 | ⬜ Untested |
| **REQ-IF-003** | SYS-011 | Hook Registrar | STP-011-A | Interface Contract Testing | STS-011-A1 | ⬜ Untested |
| | SYS-011 | Hook Registrar | STP-011-A | Interface Contract Testing | STS-011-A2 | ⬜ Untested |
| **REQ-IF-004** | SYS-012 | Structured Summary Reporter | STP-012-A | Interface Contract Testing | STS-012-A1 | ⬜ Untested |
| | SYS-012 | Structured Summary Reporter | STP-012-A | Interface Contract Testing | STS-012-A2 | ⬜ Untested |
| **REQ-IF-005** | SYS-011 | Hook Registrar | STP-011-A | Interface Contract Testing | STS-011-A1 | ⬜ Untested |
| | SYS-011 | Hook Registrar | STP-011-A | Interface Contract Testing | STS-011-A2 | ⬜ Untested |
| **REQ-NF-001** | SYS-013 | Quality & Process Compliance Harness | STP-013-A | Interface Contract Testing | STS-013-A1 | ⬜ Untested |
| | SYS-013 | Quality & Process Compliance Harness | STP-013-A | Interface Contract Testing | STS-013-A2 | ⬜ Untested |
| | SYS-013 | Quality & Process Compliance Harness | STP-013-B | Equivalence Partitioning | STS-013-B1 | ⬜ Untested |
| | SYS-013 | Quality & Process Compliance Harness | STP-013-B | Equivalence Partitioning | STS-013-B2 | ⬜ Untested |
| **REQ-NF-002** | SYS-006 | Hallucination Guard | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Hallucination Guard | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| | SYS-006 | Hallucination Guard | STP-006-B | Equivalence Partitioning | STS-006-B1 | ⬜ Untested |
| | SYS-006 | Hallucination Guard | STP-006-B | Equivalence Partitioning | STS-006-B2 | ⬜ Untested |
| | SYS-006 | Hallucination Guard | STP-006-B | Equivalence Partitioning | STS-006-B3 | ⬜ Untested |
| **REQ-NF-003** | SYS-005 | Additive-Enrichment Encoder | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Additive-Enrichment Encoder | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Additive-Enrichment Encoder | STP-005-B | Boundary Value Analysis | STS-005-B1 | ⬜ Untested |
| | SYS-005 | Additive-Enrichment Encoder | STP-005-B | Boundary Value Analysis | STS-005-B2 | ⬜ Untested |
| **REQ-NF-004** | SYS-004 | Pre-Implementation Gate | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Pre-Implementation Gate | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Pre-Implementation Gate | STP-004-B | Equivalence Partitioning | STS-004-B1 | ⬜ Untested |
| | SYS-004 | Pre-Implementation Gate | STP-004-B | Equivalence Partitioning | STS-004-B2 | ⬜ Untested |
| | SYS-004 | Pre-Implementation Gate | STP-004-B | Equivalence Partitioning | STS-004-B3 | ⬜ Untested |
| **REQ-NF-005** | SYS-001 | Plan Synthesizer | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Plan Synthesizer | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-B | Equivalence Partitioning | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-B | Equivalence Partitioning | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Tasks Synthesizer | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-B | Equivalence Partitioning | STS-003-B3 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C2 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C3 | ⬜ Untested |
| | SYS-003 | Implementation Engine | STP-003-C | Fault Injection | STS-003-C4 | ⬜ Untested |
| **REQ-NF-006** | SYS-011 | Hook Registrar | STP-011-A | Interface Contract Testing | STS-011-A1 | ⬜ Untested |
| | SYS-011 | Hook Registrar | STP-011-A | Interface Contract Testing | STS-011-A2 | ⬜ Untested |

### Matrix B Coverage

| Metric | Value |
|--------|-------|
| **Total System Components (SYS)** | 14 |
| **Total System Test Cases (STP)** | 28 |
| **Total System Scenarios (STS)** | 60 |
| **REQ → SYS Coverage** | 44/44 (100%) |
| **SYS → STP Coverage** | 14/14 (100%) |

## Matrix C — Integration Verification (Module Boundary View)

| System Component (SYS) | Parent REQs | Architecture Module (ARCH) | Module Name | Test Case ID (ITP) | Technique | Scenario ID (ITS) | Status |
|------------------------|-------------|---------------------------|-------------|--------------------|-----------|--------------------|--------|
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-026, REQ-027, REQ-NF-005, REQ-IF-001) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-026, REQ-027, REQ-NF-005, REQ-IF-001 | ARCH-001 | Plan Synthesis Orchestrator | ITP-001-A | Interface Contract Testing | ITS-001-A1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-026, REQ-027, REQ-NF-005, REQ-IF-001) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-026, REQ-027, REQ-NF-005, REQ-IF-001 | ARCH-001 | Plan Synthesis Orchestrator | ITP-001-A | Interface Contract Testing | ITS-001-A2 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-026, REQ-027, REQ-NF-005, REQ-IF-001) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-026, REQ-027, REQ-NF-005, REQ-IF-001 | ARCH-001 | Plan Synthesis Orchestrator | ITP-001-A | Interface Contract Testing | ITS-001-A3 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-026, REQ-027, REQ-NF-005, REQ-IF-001) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-026, REQ-027, REQ-NF-005, REQ-IF-001 | ARCH-001 | Plan Synthesis Orchestrator | ITP-001-B | Interface Fault Injection | ITS-001-B1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-026, REQ-027, REQ-NF-005, REQ-IF-001) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-026, REQ-027, REQ-NF-005, REQ-IF-001 | ARCH-001 | Plan Synthesis Orchestrator | ITP-001-B | Interface Fault Injection | ITS-001-B2 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-026, REQ-027, REQ-NF-005, REQ-IF-001) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-026, REQ-027, REQ-NF-005, REQ-IF-001 | ARCH-002 | Canonical Artifact Emitter | ITP-002-A | Interface Contract Testing | ITS-002-A1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-026, REQ-027, REQ-NF-005, REQ-IF-001) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-026, REQ-027, REQ-NF-005, REQ-IF-001 | ARCH-002 | Canonical Artifact Emitter | ITP-002-A | Interface Contract Testing | ITS-002-A2 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-026, REQ-027, REQ-NF-005, REQ-IF-001) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-026, REQ-027, REQ-NF-005, REQ-IF-001 | ARCH-002 | Canonical Artifact Emitter | ITP-002-B | Interface Fault Injection | ITS-002-B1 | ⬜ Untested |
| SYS-002 (REQ-009, REQ-010, REQ-011, REQ-013, REQ-014, REQ-026, REQ-027, REQ-NF-005, REQ-IF-002) | REQ-009, REQ-010, REQ-011, REQ-013, REQ-014, REQ-026, REQ-027, REQ-NF-005, REQ-IF-002 | ARCH-003 | Tasks Synthesis Orchestrator | ITP-003-A | Interface Contract Testing | ITS-003-A1 | ⬜ Untested |
| SYS-002 (REQ-009, REQ-010, REQ-011, REQ-013, REQ-014, REQ-026, REQ-027, REQ-NF-005, REQ-IF-002) | REQ-009, REQ-010, REQ-011, REQ-013, REQ-014, REQ-026, REQ-027, REQ-NF-005, REQ-IF-002 | ARCH-003 | Tasks Synthesis Orchestrator | ITP-003-A | Interface Contract Testing | ITS-003-A2 | ⬜ Untested |
| SYS-002 (REQ-009, REQ-010, REQ-011, REQ-013, REQ-014, REQ-026, REQ-027, REQ-NF-005, REQ-IF-002) | REQ-009, REQ-010, REQ-011, REQ-013, REQ-014, REQ-026, REQ-027, REQ-NF-005, REQ-IF-002 | ARCH-003 | Tasks Synthesis Orchestrator | ITP-003-B | Interface Fault Injection | ITS-003-B1 | ⬜ Untested |
| SYS-002 (REQ-009, REQ-010, REQ-011, REQ-013, REQ-014, REQ-026, REQ-027, REQ-NF-005, REQ-IF-002) | REQ-009, REQ-010, REQ-011, REQ-013, REQ-014, REQ-026, REQ-027, REQ-NF-005, REQ-IF-002 | ARCH-003 | Tasks Synthesis Orchestrator | ITP-003-B | Interface Fault Injection | ITS-003-B2 | ⬜ Untested |
| SYS-002 (REQ-009, REQ-010, REQ-011, REQ-013, REQ-014, REQ-026, REQ-027, REQ-NF-005, REQ-IF-002) | REQ-009, REQ-010, REQ-011, REQ-013, REQ-014, REQ-026, REQ-027, REQ-NF-005, REQ-IF-002 | ARCH-003 | Tasks Synthesis Orchestrator | ITP-003-C | Data Flow Testing | ITS-003-C1 | ⬜ Untested |
| SYS-002 (REQ-009, REQ-010, REQ-011, REQ-013, REQ-014, REQ-026, REQ-027, REQ-NF-005, REQ-IF-002) | REQ-009, REQ-010, REQ-011, REQ-013, REQ-014, REQ-026, REQ-027, REQ-NF-005, REQ-IF-002 | ARCH-003 | Tasks Synthesis Orchestrator | ITP-003-C | Data Flow Testing | ITS-003-C2 | ⬜ Untested |
| SYS-003 (REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005) | REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005 | ARCH-004 | Implementation Orchestrator | ITP-004-A | Interface Contract Testing | ITS-004-A1 | ⬜ Untested |
| SYS-003 (REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005) | REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005 | ARCH-004 | Implementation Orchestrator | ITP-004-A | Interface Contract Testing | ITS-004-A2 | ⬜ Untested |
| SYS-003 (REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005) | REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005 | ARCH-004 | Implementation Orchestrator | ITP-004-B | Interface Fault Injection | ITS-004-B1 | ⬜ Untested |
| SYS-003 (REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005) | REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005 | ARCH-004 | Implementation Orchestrator | ITP-004-B | Interface Fault Injection | ITS-004-B2 | ⬜ Untested |
| SYS-003 (REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005) | REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005 | ARCH-004 | Implementation Orchestrator | ITP-004-B | Interface Fault Injection | ITS-004-B3 | ⬜ Untested |
| SYS-003 (REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005) | REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005 | ARCH-004 | Implementation Orchestrator | ITP-004-D | Concurrency & Race Condition Testing | ITS-004-D1 | ⬜ Untested |
| SYS-003 (REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005) | REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005 | ARCH-004 | Implementation Orchestrator | ITP-004-D | Concurrency & Race Condition Testing | ITS-004-D2 | ⬜ Untested |
| SYS-003 (REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005) | REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005 | ARCH-005 | Code Generator | ITP-005-A | Interface Contract Testing | ITS-005-A1 | ⬜ Untested |
| SYS-003 (REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005) | REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005 | ARCH-005 | Code Generator | ITP-005-A | Interface Contract Testing | ITS-005-A2 | ⬜ Untested |
| SYS-003 (REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005) | REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005 | ARCH-005 | Code Generator | ITP-005-B | Interface Fault Injection | ITS-005-B1 | ⬜ Untested |
| SYS-003 (REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005) | REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005 | ARCH-005 | Code Generator | ITP-005-C | Data Flow Testing | ITS-005-C1 | ⬜ Untested |
| SYS-003 (REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005) | REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005 | ARCH-005 | Code Generator | ITP-005-C | Data Flow Testing | ITS-005-C2 | ⬜ Untested |
| SYS-003 (REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005) | REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005 | ARCH-006 | Test Generator | ITP-006-A | Interface Contract Testing | ITS-006-A1 | ⬜ Untested |
| SYS-003 (REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005) | REQ-015, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-024, REQ-025, REQ-026, REQ-027, REQ-NF-005 | ARCH-006 | Test Generator | ITP-006-A | Interface Contract Testing | ITS-006-A2 | ⬜ Untested |
| SYS-004 (REQ-016, REQ-017, REQ-NF-004, REQ-CN-002) | REQ-016, REQ-017, REQ-NF-004, REQ-CN-002 | ARCH-007 | Pre-Implementation Gate Coordinator | ITP-007-A | Interface Contract Testing | ITS-007-A1 | ⬜ Untested |
| SYS-004 (REQ-016, REQ-017, REQ-NF-004, REQ-CN-002) | REQ-016, REQ-017, REQ-NF-004, REQ-CN-002 | ARCH-007 | Pre-Implementation Gate Coordinator | ITP-007-A | Interface Contract Testing | ITS-007-A2 | ⬜ Untested |
| SYS-004 (REQ-016, REQ-017, REQ-NF-004, REQ-CN-002) | REQ-016, REQ-017, REQ-NF-004, REQ-CN-002 | ARCH-007 | Pre-Implementation Gate Coordinator | ITP-007-B | Interface Fault Injection | ITS-007-B1 | ⬜ Untested |
| SYS-005 (REQ-007, REQ-012, REQ-NF-003, REQ-IF-001, REQ-IF-002) | REQ-007, REQ-012, REQ-NF-003, REQ-IF-001, REQ-IF-002 | ARCH-008 | Additive Enrichment Encoder | ITP-008-A | Interface Contract Testing | ITS-008-A1 | ⬜ Untested |
| SYS-005 (REQ-007, REQ-012, REQ-NF-003, REQ-IF-001, REQ-IF-002) | REQ-007, REQ-012, REQ-NF-003, REQ-IF-001, REQ-IF-002 | ARCH-008 | Additive Enrichment Encoder | ITP-008-A | Interface Contract Testing | ITS-008-A2 | ⬜ Untested |
| SYS-005 (REQ-007, REQ-012, REQ-NF-003, REQ-IF-001, REQ-IF-002) | REQ-007, REQ-012, REQ-NF-003, REQ-IF-001, REQ-IF-002 | ARCH-008 | Additive Enrichment Encoder | ITP-008-B | Interface Fault Injection | ITS-008-B1 | ⬜ Untested |
| SYS-006 (REQ-023, REQ-NF-002) | REQ-023, REQ-NF-002 | ARCH-009 | Hallucination Guard | ITP-009-A | Interface Contract Testing | ITS-009-A1 | ⬜ Untested |
| SYS-006 (REQ-023, REQ-NF-002) | REQ-023, REQ-NF-002 | ARCH-009 | Hallucination Guard | ITP-009-A | Interface Contract Testing | ITS-009-A2 | ⬜ Untested |
| SYS-007 (REQ-022) | REQ-022 | ARCH-010 | Source Region Splicer | ITP-010-A | Interface Contract Testing | ITS-010-A1 | ⬜ Untested |
| SYS-007 (REQ-022) | REQ-022 | ARCH-010 | Source Region Splicer | ITP-010-B | Interface Fault Injection | ITS-010-B1 | ⬜ Untested |
| SYS-008 (REQ-024) | REQ-024 | ARCH-011 | Domain Overlay Loader | ITP-011-A | Interface Contract Testing | ITS-011-A1 | ⬜ Untested |
| SYS-008 (REQ-024) | REQ-024 | ARCH-011 | Domain Overlay Loader | ITP-011-B | Interface Fault Injection | ITS-011-B1 | ⬜ Untested |
| SYS-009 (REQ-014) | REQ-014 | ARCH-012 | Hazard Task Emitter | ITP-012-A | Interface Contract Testing | ITS-012-A1 | ⬜ Untested |
| SYS-009 (REQ-014) | REQ-014 | ARCH-012 | Hazard Task Emitter | ITP-012-A | Interface Contract Testing | ITS-012-A2 | ⬜ Untested |
| SYS-009 (REQ-014) | REQ-014 | ARCH-012 | Hazard Task Emitter | ITP-012-B | Interface Fault Injection | ITS-012-B1 | ⬜ Untested |
| SYS-010 (REQ-028, REQ-029, REQ-IF-001, REQ-IF-002, REQ-CN-001) | REQ-028, REQ-029, REQ-IF-001, REQ-IF-002, REQ-CN-001 | ARCH-013 | Spec-Kit Schema Validator | ITP-013-A | Interface Contract Testing | ITS-013-A1 | ⬜ Untested |
| SYS-010 (REQ-028, REQ-029, REQ-IF-001, REQ-IF-002, REQ-CN-001) | REQ-028, REQ-029, REQ-IF-001, REQ-IF-002, REQ-CN-001 | ARCH-013 | Spec-Kit Schema Validator | ITP-013-A | Interface Contract Testing | ITS-013-A2 | ⬜ Untested |
| SYS-010 (REQ-028, REQ-029, REQ-IF-001, REQ-IF-002, REQ-CN-001) | REQ-028, REQ-029, REQ-IF-001, REQ-IF-002, REQ-CN-001 | ARCH-014 | Reduced-Enrichment Fallback | ITP-014-A | Interface Contract Testing | ITS-014-A1 | ⬜ Untested |
| SYS-010 (REQ-028, REQ-029, REQ-IF-001, REQ-IF-002, REQ-CN-001) | REQ-028, REQ-029, REQ-IF-001, REQ-IF-002, REQ-CN-001 | ARCH-014 | Reduced-Enrichment Fallback | ITP-014-A | Interface Contract Testing | ITS-014-A2 | ⬜ Untested |
| SYS-011 (REQ-IF-003, REQ-IF-005, REQ-NF-006) | REQ-IF-003, REQ-IF-005, REQ-NF-006 | ARCH-015 | Hook Registrar | ITP-015-A | Interface Contract Testing | ITS-015-A1 | ⬜ Untested |
| SYS-011 (REQ-IF-003, REQ-IF-005, REQ-NF-006) | REQ-IF-003, REQ-IF-005, REQ-NF-006 | ARCH-015 | Hook Registrar | ITP-015-A | Interface Contract Testing | ITS-015-A2 | ⬜ Untested |
| SYS-011 (REQ-IF-003, REQ-IF-005, REQ-NF-006) | REQ-IF-003, REQ-IF-005, REQ-NF-006 | ARCH-015 | Hook Registrar | ITP-015-B | Interface Fault Injection | ITS-015-B1 | ⬜ Untested |
| SYS-012 (REQ-027, REQ-IF-004) | REQ-027, REQ-IF-004 | ARCH-016 | Structured Summary Reporter | ITP-016-A | Interface Contract Testing | ITS-016-A1 | ⬜ Untested |
| SYS-012 (REQ-027, REQ-IF-004) | REQ-027, REQ-IF-004 | ARCH-016 | Structured Summary Reporter | ITP-016-A | Interface Contract Testing | ITS-016-A2 | ⬜ Untested |
| SYS-013 (REQ-NF-001, REQ-CN-003, REQ-CN-004) | REQ-NF-001, REQ-CN-003, REQ-CN-004 | ARCH-017 | Quality Compliance Harness | ITP-017-A | Interface Contract Testing | ITS-017-A1 | ⬜ Untested |
| SYS-013 (REQ-NF-001, REQ-CN-003, REQ-CN-004) | REQ-NF-001, REQ-CN-003, REQ-CN-004 | ARCH-017 | Quality Compliance Harness | ITP-017-A | Interface Contract Testing | ITS-017-A2 | ⬜ Untested |
| SYS-014 (REQ-021) | REQ-021 | ARCH-018 | Commit Annotator | ITP-018-A | Interface Contract Testing | ITS-018-A1 | ⬜ Untested |
| SYS-014 (REQ-021) | REQ-021 | ARCH-018 | Commit Annotator | ITP-018-A | Interface Contract Testing | ITS-018-A2 | ⬜ Untested |
| N/A (Cross-Cutting) | — | ARCH-019 | V-Model Artifact Reader | ITP-019-A | Interface Contract Testing | ITS-019-A1 | ⬜ Untested |
| N/A (Cross-Cutting) | — | ARCH-019 | V-Model Artifact Reader | ITP-019-A | Interface Contract Testing | ITS-019-A2 | ⬜ Untested |
| N/A (Cross-Cutting) | — | ARCH-019 | V-Model Artifact Reader | ITP-019-B | Interface Fault Injection | ITS-019-B1 | ⬜ Untested |
| N/A (Cross-Cutting) | — | ARCH-019 | V-Model Artifact Reader | ITP-019-C | Concurrency & Race Condition Testing | ITS-019-C1 | ⬜ Untested |
| N/A (Cross-Cutting) | — | ARCH-019 | V-Model Artifact Reader | ITP-019-C | Concurrency & Race Condition Testing | ITS-019-C2 | ⬜ Untested |
| N/A (Cross-Cutting) | — | ARCH-019 | V-Model Artifact Reader | ITP-019-C | Concurrency & Race Condition Testing | ITS-019-C3 | ⬜ Untested |
| N/A (Cross-Cutting) | — | ARCH-020 | Subprocess Runner | ITP-020-A | Interface Contract Testing | ITS-020-A1 | ⬜ Untested |
| N/A (Cross-Cutting) | — | ARCH-020 | Subprocess Runner | ITP-020-B | Interface Fault Injection | ITS-020-B1 | ⬜ Untested |
| N/A (Cross-Cutting) | — | ARCH-020 | Subprocess Runner | ITP-020-B | Interface Fault Injection | ITS-020-B2 | ⬜ Untested |
| N/A (Cross-Cutting) | — | ARCH-020 | Subprocess Runner | ITP-020-C | Interface Fault Injection | ITS-020-C1 | ⬜ Untested |
| N/A (Cross-Cutting) | — | ARCH-020 | Subprocess Runner | ITP-020-C | Interface Fault Injection | ITS-020-C2 | ⬜ Untested |
| N/A (Cross-Cutting) | — | ARCH-020 | Subprocess Runner | ITP-020-C | Interface Fault Injection | ITS-020-C3 | ⬜ Untested |
| N/A (Cross-Cutting) | — | ARCH-020 | Subprocess Runner | ITP-020-D | Concurrency & Race Condition Testing | ITS-020-D1 | ⬜ Untested |
| N/A (Cross-Cutting) | — | ARCH-021 | Filesystem Writer | ITP-021-A | Interface Contract Testing | ITS-021-A1 | ⬜ Untested |
| N/A (Cross-Cutting) | — | ARCH-021 | Filesystem Writer | ITP-021-A | Interface Contract Testing | ITS-021-A2 | ⬜ Untested |
| N/A (Cross-Cutting) | — | ARCH-021 | Filesystem Writer | ITP-021-B | Interface Fault Injection | ITS-021-B1 | ⬜ Untested |
| N/A (Cross-Cutting) | — | ARCH-021 | Filesystem Writer | ITP-021-D | Concurrency & Race Condition Testing | ITS-021-D1 | ⬜ Untested |
| N/A (Cross-Cutting) | — | ARCH-021 | Filesystem Writer | ITP-021-D | Concurrency & Race Condition Testing | ITS-021-D2 | ⬜ Untested |

### Matrix C Coverage

| Metric | Value |
|--------|-------|
| **Total Architecture Modules (ARCH)** | 21 |
| **Total Cross-Cutting Modules** | 3 |
| **Total Integration Test Cases (ITP)** | 42 |
| **Total Integration Scenarios (ITS)** | 74 |
| **SYS → ARCH Coverage** | 14/14 (100%) |
| **ARCH → ITP Coverage** | 21/21 (100%) |

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

## Matrix D — Implementation Verification (Module View)

| Architecture Module (ARCH) | Parent System | Module Design (MOD) | Module Name | Test Case ID (UTP) | Technique | Scenario ID (UTS) | Status |
|---------------------------|---------------|---------------------|-------------|--------------------|-----------|--------------------|--------|
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | Plan Synthesis Orchestrator — `run` | UTP-001-A | Statement & Branch Coverage | UTS-001-A1 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | Plan Synthesis Orchestrator — `run` | UTP-001-A | Statement & Branch Coverage | UTS-001-A2 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | Plan Synthesis Orchestrator — `run` | UTP-001-A | Statement & Branch Coverage | UTS-001-A3 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | Plan Synthesis Orchestrator — `run` | UTP-001-B | Boundary Value Analysis | UTS-001-B1 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | Plan Synthesis Orchestrator — `run` | UTP-001-B | Boundary Value Analysis | UTS-001-B2 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | Plan Synthesis Orchestrator — `run` | UTP-001-B | Boundary Value Analysis | UTS-001-B3 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | Plan Synthesis Orchestrator — `run` | UTP-001-B | Boundary Value Analysis | UTS-001-B4 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | Plan Synthesis Orchestrator — `run` | UTP-001-B | Boundary Value Analysis | UTS-001-B5 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | Plan Synthesis Orchestrator — `run` | UTP-001-C | Strict Isolation | UTS-001-C1 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | Plan Synthesis Orchestrator — `run` | UTP-001-C | Strict Isolation | UTS-001-C2 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | Plan Synthesis Orchestrator — `run` | UTP-001-D | State Transition Testing | UTS-001-D1 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | Plan Synthesis Orchestrator — `run` | UTP-001-D | State Transition Testing | UTS-001-D2 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | Plan Synthesis Orchestrator — `run` | UTP-001-D | State Transition Testing | UTS-001-D3 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | `emit_canonical_outputs` | UTP-002-A | Statement & Branch Coverage | UTS-002-A1 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | `emit_canonical_outputs` | UTP-002-A | Statement & Branch Coverage | UTS-002-A2 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | `emit_canonical_outputs` | UTP-002-A | Statement & Branch Coverage | UTS-002-A3 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | `emit_canonical_outputs` | UTP-002-B | Boundary Value Analysis | UTS-002-B1 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | `emit_canonical_outputs` | UTP-002-B | Boundary Value Analysis | UTS-002-B2 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | `emit_canonical_outputs` | UTP-002-B | Boundary Value Analysis | UTS-002-B3 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | `emit_canonical_outputs` | UTP-002-B | Boundary Value Analysis | UTS-002-B4 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | `emit_canonical_outputs` | UTP-002-B | Boundary Value Analysis | UTS-002-B5 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | `emit_canonical_outputs` | UTP-002-C | Strict Isolation | UTS-002-C1 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | `emit_canonical_outputs` | UTP-002-C | Strict Isolation | UTS-002-C2 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | Tasks Synthesis Orchestrator — `run` | UTP-003-A | Statement & Branch Coverage | UTS-003-A1 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | Tasks Synthesis Orchestrator — `run` | UTP-003-A | Statement & Branch Coverage | UTS-003-A2 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | Tasks Synthesis Orchestrator — `run` | UTP-003-A | Statement & Branch Coverage | UTS-003-A3 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | Tasks Synthesis Orchestrator — `run` | UTP-003-B | Boundary Value Analysis | UTS-003-B1 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | Tasks Synthesis Orchestrator — `run` | UTP-003-B | Boundary Value Analysis | UTS-003-B2 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | Tasks Synthesis Orchestrator — `run` | UTP-003-B | Boundary Value Analysis | UTS-003-B3 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | Tasks Synthesis Orchestrator — `run` | UTP-003-B | Boundary Value Analysis | UTS-003-B4 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | Tasks Synthesis Orchestrator — `run` | UTP-003-B | Boundary Value Analysis | UTS-003-B5 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | Tasks Synthesis Orchestrator — `run` | UTP-003-C | Strict Isolation | UTS-003-C1 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | Tasks Synthesis Orchestrator — `run` | UTP-003-C | Strict Isolation | UTS-003-C2 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | Tasks Synthesis Orchestrator — `run` | UTP-003-D | State Transition Testing | UTS-003-D1 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | Tasks Synthesis Orchestrator — `run` | UTP-003-D | State Transition Testing | UTS-003-D2 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | Tasks Synthesis Orchestrator — `run` | UTP-003-D | State Transition Testing | UTS-003-D3 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-004 | `build_tdd_task_list` | UTP-004-A | Statement & Branch Coverage | UTS-004-A1 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-004 | `build_tdd_task_list` | UTP-004-A | Statement & Branch Coverage | UTS-004-A2 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-004 | `build_tdd_task_list` | UTP-004-A | Statement & Branch Coverage | UTS-004-A3 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-004 | `build_tdd_task_list` | UTP-004-B | Boundary Value Analysis | UTS-004-B1 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-004 | `build_tdd_task_list` | UTP-004-B | Boundary Value Analysis | UTS-004-B2 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-004 | `build_tdd_task_list` | UTP-004-B | Boundary Value Analysis | UTS-004-B3 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-004 | `build_tdd_task_list` | UTP-004-B | Boundary Value Analysis | UTS-004-B4 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-004 | `build_tdd_task_list` | UTP-004-B | Boundary Value Analysis | UTS-004-B5 | ⬜ Untested |
| ARCH-004 (SYS-003) | SYS-003 | MOD-005 | Implementation Orchestrator — `run` | UTP-005-A | Statement & Branch Coverage | UTS-005-A1 | ⬜ Untested |
| ARCH-004 (SYS-003) | SYS-003 | MOD-005 | Implementation Orchestrator — `run` | UTP-005-A | Statement & Branch Coverage | UTS-005-A2 | ⬜ Untested |
| ARCH-004 (SYS-003) | SYS-003 | MOD-005 | Implementation Orchestrator — `run` | UTP-005-A | Statement & Branch Coverage | UTS-005-A3 | ⬜ Untested |
| ARCH-004 (SYS-003) | SYS-003 | MOD-005 | Implementation Orchestrator — `run` | UTP-005-A | Statement & Branch Coverage | UTS-005-A4 | ⬜ Untested |
| ARCH-004 (SYS-003) | SYS-003 | MOD-005 | Implementation Orchestrator — `run` | UTP-005-B | Equivalence Partitioning | UTS-005-B1 | ⬜ Untested |
| ARCH-004 (SYS-003) | SYS-003 | MOD-005 | Implementation Orchestrator — `run` | UTP-005-B | Equivalence Partitioning | UTS-005-B2 | ⬜ Untested |
| ARCH-004 (SYS-003) | SYS-003 | MOD-005 | Implementation Orchestrator — `run` | UTP-005-B | Equivalence Partitioning | UTS-005-B3 | ⬜ Untested |
| ARCH-004 (SYS-003) | SYS-003 | MOD-005 | Implementation Orchestrator — `run` | UTP-005-B | Equivalence Partitioning | UTS-005-B4 | ⬜ Untested |
| ARCH-004 (SYS-003) | SYS-003 | MOD-005 | Implementation Orchestrator — `run` | UTP-005-C | Strict Isolation | UTS-005-C1 | ⬜ Untested |
| ARCH-004 (SYS-003) | SYS-003 | MOD-005 | Implementation Orchestrator — `run` | UTP-005-C | Strict Isolation | UTS-005-C2 | ⬜ Untested |
| ARCH-004 (SYS-003) | SYS-003 | MOD-005 | Implementation Orchestrator — `run` | UTP-005-D | State Transition Testing | UTS-005-D1 | ⬜ Untested |
| ARCH-004 (SYS-003) | SYS-003 | MOD-005 | Implementation Orchestrator — `run` | UTP-005-D | State Transition Testing | UTS-005-D2 | ⬜ Untested |
| ARCH-004 (SYS-003) | SYS-003 | MOD-005 | Implementation Orchestrator — `run` | UTP-005-D | State Transition Testing | UTS-005-D3 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-006 | `generate_code` — dispatcher | UTP-006-A | Statement & Branch Coverage | UTS-006-A1 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-006 | `generate_code` — dispatcher | UTP-006-A | Statement & Branch Coverage | UTS-006-A2 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-006 | `generate_code` — dispatcher | UTP-006-A | Statement & Branch Coverage | UTS-006-A3 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-006 | `generate_code` — dispatcher | UTP-006-B | Equivalence Partitioning | UTS-006-B1 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-006 | `generate_code` — dispatcher | UTP-006-B | Equivalence Partitioning | UTS-006-B2 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-006 | `generate_code` — dispatcher | UTP-006-B | Equivalence Partitioning | UTS-006-B3 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-007 | `render_module_source` | UTP-007-A | Statement & Branch Coverage | UTS-007-A1 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-007 | `render_module_source` | UTP-007-A | Statement & Branch Coverage | UTS-007-A2 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-007 | `render_module_source` | UTP-007-A | Statement & Branch Coverage | UTS-007-A3 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-007 | `render_module_source` | UTP-007-B | Boundary Value Analysis | UTS-007-B1 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-007 | `render_module_source` | UTP-007-B | Boundary Value Analysis | UTS-007-B2 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-007 | `render_module_source` | UTP-007-B | Boundary Value Analysis | UTS-007-B3 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-007 | `render_module_source` | UTP-007-B | Boundary Value Analysis | UTS-007-B4 | ⬜ Untested |
| ARCH-005 (SYS-003) | SYS-003 | MOD-007 | `render_module_source` | UTP-007-B | Boundary Value Analysis | UTS-007-B5 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-008 | `generate_tests` — dispatcher | UTP-008-A | Statement & Branch Coverage | UTS-008-A1 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-008 | `generate_tests` — dispatcher | UTP-008-A | Statement & Branch Coverage | UTS-008-A2 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-008 | `generate_tests` — dispatcher | UTP-008-A | Statement & Branch Coverage | UTS-008-A3 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-008 | `generate_tests` — dispatcher | UTP-008-B | Equivalence Partitioning | UTS-008-B1 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-008 | `generate_tests` — dispatcher | UTP-008-B | Equivalence Partitioning | UTS-008-B2 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-008 | `generate_tests` — dispatcher | UTP-008-B | Equivalence Partitioning | UTS-008-B3 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-008 | `generate_tests` — dispatcher | UTP-008-B | Equivalence Partitioning | UTS-008-B4 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-008 | `generate_tests` — dispatcher | UTP-008-B | Equivalence Partitioning | UTS-008-B5 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-009 | `render_test_file_for_level` | UTP-009-A | Statement & Branch Coverage | UTS-009-A1 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-009 | `render_test_file_for_level` | UTP-009-A | Statement & Branch Coverage | UTS-009-A2 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-009 | `render_test_file_for_level` | UTP-009-A | Statement & Branch Coverage | UTS-009-A3 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-009 | `render_test_file_for_level` | UTP-009-B | Boundary Value Analysis | UTS-009-B1 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-009 | `render_test_file_for_level` | UTP-009-B | Boundary Value Analysis | UTS-009-B2 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-009 | `render_test_file_for_level` | UTP-009-B | Boundary Value Analysis | UTS-009-B3 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-009 | `render_test_file_for_level` | UTP-009-B | Boundary Value Analysis | UTS-009-B4 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-009 | `render_test_file_for_level` | UTP-009-B | Boundary Value Analysis | UTS-009-B5 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-010 | `evaluate_gate` | UTP-010-A | Statement & Branch Coverage | UTS-010-A1 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-010 | `evaluate_gate` | UTP-010-A | Statement & Branch Coverage | UTS-010-A2 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-010 | `evaluate_gate` | UTP-010-A | Statement & Branch Coverage | UTS-010-A3 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-010 | `evaluate_gate` | UTP-010-B | Equivalence Partitioning | UTS-010-B1 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-010 | `evaluate_gate` | UTP-010-B | Equivalence Partitioning | UTS-010-B2 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-010 | `evaluate_gate` | UTP-010-B | Equivalence Partitioning | UTS-010-B3 | ⬜ Untested |
| ARCH-007 (SYS-004) | SYS-004 | MOD-010 | `evaluate_gate` | UTP-010-B | Equivalence Partitioning | UTS-010-B4 | ⬜ Untested |
| ARCH-008 (SYS-005) | SYS-005 | MOD-011 | `embed_enrichment` | UTP-011-A | Statement & Branch Coverage | UTS-011-A1 | ⬜ Untested |
| ARCH-008 (SYS-005) | SYS-005 | MOD-011 | `embed_enrichment` | UTP-011-A | Statement & Branch Coverage | UTS-011-A2 | ⬜ Untested |
| ARCH-008 (SYS-005) | SYS-005 | MOD-011 | `embed_enrichment` | UTP-011-A | Statement & Branch Coverage | UTS-011-A3 | ⬜ Untested |
| ARCH-008 (SYS-005) | SYS-005 | MOD-011 | `embed_enrichment` | UTP-011-B | Boundary Value Analysis | UTS-011-B1 | ⬜ Untested |
| ARCH-008 (SYS-005) | SYS-005 | MOD-011 | `embed_enrichment` | UTP-011-B | Boundary Value Analysis | UTS-011-B2 | ⬜ Untested |
| ARCH-008 (SYS-005) | SYS-005 | MOD-011 | `embed_enrichment` | UTP-011-B | Boundary Value Analysis | UTS-011-B3 | ⬜ Untested |
| ARCH-008 (SYS-005) | SYS-005 | MOD-011 | `embed_enrichment` | UTP-011-B | Boundary Value Analysis | UTS-011-B4 | ⬜ Untested |
| ARCH-008 (SYS-005) | SYS-005 | MOD-011 | `embed_enrichment` | UTP-011-B | Boundary Value Analysis | UTS-011-B5 | ⬜ Untested |
| ARCH-008 (SYS-005) | SYS-005 | MOD-012 | `embed_traceability_comments` | UTP-012-A | Statement & Branch Coverage | UTS-012-A1 | ⬜ Untested |
| ARCH-008 (SYS-005) | SYS-005 | MOD-012 | `embed_traceability_comments` | UTP-012-A | Statement & Branch Coverage | UTS-012-A2 | ⬜ Untested |
| ARCH-008 (SYS-005) | SYS-005 | MOD-012 | `embed_traceability_comments` | UTP-012-A | Statement & Branch Coverage | UTS-012-A3 | ⬜ Untested |
| ARCH-008 (SYS-005) | SYS-005 | MOD-012 | `embed_traceability_comments` | UTP-012-B | Boundary Value Analysis | UTS-012-B1 | ⬜ Untested |
| ARCH-008 (SYS-005) | SYS-005 | MOD-012 | `embed_traceability_comments` | UTP-012-B | Boundary Value Analysis | UTS-012-B2 | ⬜ Untested |
| ARCH-008 (SYS-005) | SYS-005 | MOD-012 | `embed_traceability_comments` | UTP-012-B | Boundary Value Analysis | UTS-012-B3 | ⬜ Untested |
| ARCH-008 (SYS-005) | SYS-005 | MOD-012 | `embed_traceability_comments` | UTP-012-B | Boundary Value Analysis | UTS-012-B4 | ⬜ Untested |
| ARCH-008 (SYS-005) | SYS-005 | MOD-012 | `embed_traceability_comments` | UTP-012-B | Boundary Value Analysis | UTS-012-B5 | ⬜ Untested |
| ARCH-009 (SYS-006) | SYS-006 | MOD-013 | `verify_ids` | UTP-013-A | Statement & Branch Coverage | UTS-013-A1 | ⬜ Untested |
| ARCH-009 (SYS-006) | SYS-006 | MOD-013 | `verify_ids` | UTP-013-A | Statement & Branch Coverage | UTS-013-A2 | ⬜ Untested |
| ARCH-009 (SYS-006) | SYS-006 | MOD-013 | `verify_ids` | UTP-013-A | Statement & Branch Coverage | UTS-013-A3 | ⬜ Untested |
| ARCH-009 (SYS-006) | SYS-006 | MOD-013 | `verify_ids` | UTP-013-B | Equivalence Partitioning | UTS-013-B1 | ⬜ Untested |
| ARCH-009 (SYS-006) | SYS-006 | MOD-013 | `verify_ids` | UTP-013-B | Equivalence Partitioning | UTS-013-B2 | ⬜ Untested |
| ARCH-009 (SYS-006) | SYS-006 | MOD-013 | `verify_ids` | UTP-013-B | Equivalence Partitioning | UTS-013-B3 | ⬜ Untested |
| ARCH-010 (SYS-007) | SYS-007 | MOD-014 | `splice_managed_regions` | UTP-014-A | Statement & Branch Coverage | UTS-014-A1 | ⬜ Untested |
| ARCH-010 (SYS-007) | SYS-007 | MOD-014 | `splice_managed_regions` | UTP-014-A | Statement & Branch Coverage | UTS-014-A2 | ⬜ Untested |
| ARCH-010 (SYS-007) | SYS-007 | MOD-014 | `splice_managed_regions` | UTP-014-A | Statement & Branch Coverage | UTS-014-A3 | ⬜ Untested |
| ARCH-010 (SYS-007) | SYS-007 | MOD-014 | `splice_managed_regions` | UTP-014-B | Boundary Value Analysis | UTS-014-B1 | ⬜ Untested |
| ARCH-010 (SYS-007) | SYS-007 | MOD-014 | `splice_managed_regions` | UTP-014-B | Boundary Value Analysis | UTS-014-B2 | ⬜ Untested |
| ARCH-010 (SYS-007) | SYS-007 | MOD-014 | `splice_managed_regions` | UTP-014-B | Boundary Value Analysis | UTS-014-B3 | ⬜ Untested |
| ARCH-010 (SYS-007) | SYS-007 | MOD-014 | `splice_managed_regions` | UTP-014-B | Boundary Value Analysis | UTS-014-B4 | ⬜ Untested |
| ARCH-010 (SYS-007) | SYS-007 | MOD-014 | `splice_managed_regions` | UTP-014-B | Boundary Value Analysis | UTS-014-B5 | ⬜ Untested |
| ARCH-011 (SYS-008) | SYS-008 | MOD-015 | `apply_overlay` | UTP-015-A | Statement & Branch Coverage | UTS-015-A1 | ⬜ Untested |
| ARCH-011 (SYS-008) | SYS-008 | MOD-015 | `apply_overlay` | UTP-015-A | Statement & Branch Coverage | UTS-015-A2 | ⬜ Untested |
| ARCH-011 (SYS-008) | SYS-008 | MOD-015 | `apply_overlay` | UTP-015-A | Statement & Branch Coverage | UTS-015-A3 | ⬜ Untested |
| ARCH-011 (SYS-008) | SYS-008 | MOD-015 | `apply_overlay` | UTP-015-B | Equivalence Partitioning | UTS-015-B1 | ⬜ Untested |
| ARCH-011 (SYS-008) | SYS-008 | MOD-015 | `apply_overlay` | UTP-015-B | Equivalence Partitioning | UTS-015-B2 | ⬜ Untested |
| ARCH-011 (SYS-008) | SYS-008 | MOD-015 | `apply_overlay` | UTP-015-B | Equivalence Partitioning | UTS-015-B3 | ⬜ Untested |
| ARCH-012 (SYS-009) | SYS-009 | MOD-016 | `enrich_with_hazards` | UTP-016-A | Statement & Branch Coverage | UTS-016-A1 | ⬜ Untested |
| ARCH-012 (SYS-009) | SYS-009 | MOD-016 | `enrich_with_hazards` | UTP-016-A | Statement & Branch Coverage | UTS-016-A2 | ⬜ Untested |
| ARCH-012 (SYS-009) | SYS-009 | MOD-016 | `enrich_with_hazards` | UTP-016-A | Statement & Branch Coverage | UTS-016-A3 | ⬜ Untested |
| ARCH-012 (SYS-009) | SYS-009 | MOD-016 | `enrich_with_hazards` | UTP-016-B | Equivalence Partitioning | UTS-016-B1 | ⬜ Untested |
| ARCH-012 (SYS-009) | SYS-009 | MOD-016 | `enrich_with_hazards` | UTP-016-B | Equivalence Partitioning | UTS-016-B2 | ⬜ Untested |
| ARCH-012 (SYS-009) | SYS-009 | MOD-016 | `enrich_with_hazards` | UTP-016-B | Equivalence Partitioning | UTS-016-B3 | ⬜ Untested |
| ARCH-013 (SYS-010) | SYS-010 | MOD-017 | `validate_plan_schema` | UTP-017-A | Statement & Branch Coverage | UTS-017-A1 | ⬜ Untested |
| ARCH-013 (SYS-010) | SYS-010 | MOD-017 | `validate_plan_schema` | UTP-017-A | Statement & Branch Coverage | UTS-017-A2 | ⬜ Untested |
| ARCH-013 (SYS-010) | SYS-010 | MOD-017 | `validate_plan_schema` | UTP-017-A | Statement & Branch Coverage | UTS-017-A3 | ⬜ Untested |
| ARCH-013 (SYS-010) | SYS-010 | MOD-017 | `validate_plan_schema` | UTP-017-B | Equivalence Partitioning | UTS-017-B1 | ⬜ Untested |
| ARCH-013 (SYS-010) | SYS-010 | MOD-017 | `validate_plan_schema` | UTP-017-B | Equivalence Partitioning | UTS-017-B2 | ⬜ Untested |
| ARCH-013 (SYS-010) | SYS-010 | MOD-017 | `validate_plan_schema` | UTP-017-B | Equivalence Partitioning | UTS-017-B3 | ⬜ Untested |
| ARCH-013 (SYS-010) | SYS-010 | MOD-018 | `validate_tasks_schema` | UTP-018-A | Statement & Branch Coverage | UTS-018-A1 | ⬜ Untested |
| ARCH-013 (SYS-010) | SYS-010 | MOD-018 | `validate_tasks_schema` | UTP-018-A | Statement & Branch Coverage | UTS-018-A2 | ⬜ Untested |
| ARCH-013 (SYS-010) | SYS-010 | MOD-018 | `validate_tasks_schema` | UTP-018-A | Statement & Branch Coverage | UTS-018-A3 | ⬜ Untested |
| ARCH-013 (SYS-010) | SYS-010 | MOD-018 | `validate_tasks_schema` | UTP-018-B | Equivalence Partitioning | UTS-018-B1 | ⬜ Untested |
| ARCH-013 (SYS-010) | SYS-010 | MOD-018 | `validate_tasks_schema` | UTP-018-B | Equivalence Partitioning | UTS-018-B2 | ⬜ Untested |
| ARCH-013 (SYS-010) | SYS-010 | MOD-018 | `validate_tasks_schema` | UTP-018-B | Equivalence Partitioning | UTS-018-B3 | ⬜ Untested |
| ARCH-014 (SYS-010) | SYS-010 | MOD-019 | `detect_enrichment` | UTP-019-A | Statement & Branch Coverage | UTS-019-A1 | ⬜ Untested |
| ARCH-014 (SYS-010) | SYS-010 | MOD-019 | `detect_enrichment` | UTP-019-A | Statement & Branch Coverage | UTS-019-A2 | ⬜ Untested |
| ARCH-014 (SYS-010) | SYS-010 | MOD-019 | `detect_enrichment` | UTP-019-A | Statement & Branch Coverage | UTS-019-A3 | ⬜ Untested |
| ARCH-014 (SYS-010) | SYS-010 | MOD-019 | `detect_enrichment` | UTP-019-B | Equivalence Partitioning | UTS-019-B1 | ⬜ Untested |
| ARCH-014 (SYS-010) | SYS-010 | MOD-019 | `detect_enrichment` | UTP-019-B | Equivalence Partitioning | UTS-019-B2 | ⬜ Untested |
| ARCH-014 (SYS-010) | SYS-010 | MOD-019 | `detect_enrichment` | UTP-019-B | Equivalence Partitioning | UTS-019-B3 | ⬜ Untested |
| ARCH-015 (SYS-011) | SYS-011 | MOD-020 | `register_hooks` | UTP-020-A | Statement & Branch Coverage | UTS-020-A1 | ⬜ Untested |
| ARCH-015 (SYS-011) | SYS-011 | MOD-020 | `register_hooks` | UTP-020-A | Statement & Branch Coverage | UTS-020-A2 | ⬜ Untested |
| ARCH-015 (SYS-011) | SYS-011 | MOD-020 | `register_hooks` | UTP-020-A | Statement & Branch Coverage | UTS-020-A3 | ⬜ Untested |
| ARCH-015 (SYS-011) | SYS-011 | MOD-020 | `register_hooks` | UTP-020-B | Equivalence Partitioning | UTS-020-B1 | ⬜ Untested |
| ARCH-015 (SYS-011) | SYS-011 | MOD-020 | `register_hooks` | UTP-020-B | Equivalence Partitioning | UTS-020-B2 | ⬜ Untested |
| ARCH-015 (SYS-011) | SYS-011 | MOD-020 | `register_hooks` | UTP-020-B | Equivalence Partitioning | UTS-020-B3 | ⬜ Untested |
| ARCH-015 (SYS-011) | SYS-011 | MOD-020 | `register_hooks` | UTP-020-B | Equivalence Partitioning | UTS-020-B4 | ⬜ Untested |
| ARCH-016 (SYS-012) | SYS-012 | MOD-021 | `emit_summary` | UTP-021-A | Statement & Branch Coverage | UTS-021-A1 | ⬜ Untested |
| ARCH-016 (SYS-012) | SYS-012 | MOD-021 | `emit_summary` | UTP-021-A | Statement & Branch Coverage | UTS-021-A2 | ⬜ Untested |
| ARCH-016 (SYS-012) | SYS-012 | MOD-021 | `emit_summary` | UTP-021-A | Statement & Branch Coverage | UTS-021-A3 | ⬜ Untested |
| ARCH-016 (SYS-012) | SYS-012 | MOD-021 | `emit_summary` | UTP-021-B | Boundary Value Analysis | UTS-021-B1 | ⬜ Untested |
| ARCH-016 (SYS-012) | SYS-012 | MOD-021 | `emit_summary` | UTP-021-B | Boundary Value Analysis | UTS-021-B2 | ⬜ Untested |
| ARCH-016 (SYS-012) | SYS-012 | MOD-021 | `emit_summary` | UTP-021-B | Boundary Value Analysis | UTS-021-B3 | ⬜ Untested |
| ARCH-016 (SYS-012) | SYS-012 | MOD-021 | `emit_summary` | UTP-021-B | Boundary Value Analysis | UTS-021-B4 | ⬜ Untested |
| ARCH-016 (SYS-012) | SYS-012 | MOD-021 | `emit_summary` | UTP-021-B | Boundary Value Analysis | UTS-021-B5 | ⬜ Untested |
| ARCH-017 (SYS-013) | SYS-013 | MOD-022 | `compute_coverage_report` | UTP-022-A | Statement & Branch Coverage | UTS-022-A1 | ⬜ Untested |
| ARCH-017 (SYS-013) | SYS-013 | MOD-022 | `compute_coverage_report` | UTP-022-A | Statement & Branch Coverage | UTS-022-A2 | ⬜ Untested |
| ARCH-017 (SYS-013) | SYS-013 | MOD-022 | `compute_coverage_report` | UTP-022-A | Statement & Branch Coverage | UTS-022-A3 | ⬜ Untested |
| ARCH-017 (SYS-013) | SYS-013 | MOD-022 | `compute_coverage_report` | UTP-022-B | Boundary Value Analysis | UTS-022-B1 | ⬜ Untested |
| ARCH-017 (SYS-013) | SYS-013 | MOD-022 | `compute_coverage_report` | UTP-022-B | Boundary Value Analysis | UTS-022-B2 | ⬜ Untested |
| ARCH-017 (SYS-013) | SYS-013 | MOD-022 | `compute_coverage_report` | UTP-022-B | Boundary Value Analysis | UTS-022-B3 | ⬜ Untested |
| ARCH-017 (SYS-013) | SYS-013 | MOD-022 | `compute_coverage_report` | UTP-022-B | Boundary Value Analysis | UTS-022-B4 | ⬜ Untested |
| ARCH-017 (SYS-013) | SYS-013 | MOD-022 | `compute_coverage_report` | UTP-022-B | Boundary Value Analysis | UTS-022-B5 | ⬜ Untested |
| ARCH-018 (SYS-014) | SYS-014 | MOD-023 | `annotate_commit` | UTP-023-A | Statement & Branch Coverage | UTS-023-A1 | ⬜ Untested |
| ARCH-018 (SYS-014) | SYS-014 | MOD-023 | `annotate_commit` | UTP-023-A | Statement & Branch Coverage | UTS-023-A2 | ⬜ Untested |
| ARCH-018 (SYS-014) | SYS-014 | MOD-023 | `annotate_commit` | UTP-023-A | Statement & Branch Coverage | UTS-023-A3 | ⬜ Untested |
| ARCH-018 (SYS-014) | SYS-014 | MOD-023 | `annotate_commit` | UTP-023-B | Equivalence Partitioning | UTS-023-B1 | ⬜ Untested |
| ARCH-018 (SYS-014) | SYS-014 | MOD-023 | `annotate_commit` | UTP-023-B | Equivalence Partitioning | UTS-023-B2 | ⬜ Untested |
| ARCH-018 (SYS-014) | SYS-014 | MOD-023 | `annotate_commit` | UTP-023-B | Equivalence Partitioning | UTS-023-B3 | ⬜ Untested |
| ARCH-018 (SYS-014) | SYS-014 | MOD-023 | `annotate_commit` | UTP-023-C | Strict Isolation | UTS-023-C1 | ⬜ Untested |
| ARCH-018 (SYS-014) | SYS-014 | MOD-023 | `annotate_commit` | UTP-023-C | Strict Isolation | UTS-023-C2 | ⬜ Untested |
| ARCH-019 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-024 | `load_artifacts` | UTP-024-A | Statement & Branch Coverage | UTS-024-A1 | ⬜ Untested |
| ARCH-019 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-024 | `load_artifacts` | UTP-024-A | Statement & Branch Coverage | UTS-024-A2 | ⬜ Untested |
| ARCH-019 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-024 | `load_artifacts` | UTP-024-A | Statement & Branch Coverage | UTS-024-A3 | ⬜ Untested |
| ARCH-019 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-024 | `load_artifacts` | UTP-024-B | Boundary Value Analysis | UTS-024-B1 | ⬜ Untested |
| ARCH-019 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-024 | `load_artifacts` | UTP-024-B | Boundary Value Analysis | UTS-024-B2 | ⬜ Untested |
| ARCH-019 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-024 | `load_artifacts` | UTP-024-B | Boundary Value Analysis | UTS-024-B3 | ⬜ Untested |
| ARCH-019 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-024 | `load_artifacts` | UTP-024-B | Boundary Value Analysis | UTS-024-B4 | ⬜ Untested |
| ARCH-019 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-024 | `load_artifacts` | UTP-024-B | Boundary Value Analysis | UTS-024-B5 | ⬜ Untested |
| ARCH-019 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-024 | `load_artifacts` | UTP-024-C | Strict Isolation | UTS-024-C1 | ⬜ Untested |
| ARCH-019 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-024 | `load_artifacts` | UTP-024-C | Strict Isolation | UTS-024-C2 | ⬜ Untested |
| ARCH-019 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-025 | `extract_id_set` | UTP-025-A | Statement & Branch Coverage | UTS-025-A1 | ⬜ Untested |
| ARCH-019 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-025 | `extract_id_set` | UTP-025-A | Statement & Branch Coverage | UTS-025-A2 | ⬜ Untested |
| ARCH-019 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-025 | `extract_id_set` | UTP-025-A | Statement & Branch Coverage | UTS-025-A3 | ⬜ Untested |
| ARCH-019 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-025 | `extract_id_set` | UTP-025-B | Equivalence Partitioning | UTS-025-B1 | ⬜ Untested |
| ARCH-019 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-025 | `extract_id_set` | UTP-025-B | Equivalence Partitioning | UTS-025-B2 | ⬜ Untested |
| ARCH-019 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-025 | `extract_id_set` | UTP-025-B | Equivalence Partitioning | UTS-025-B3 | ⬜ Untested |
| ARCH-020 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-026 | `run_subprocess` | UTP-026-A | Statement & Branch Coverage | UTS-026-A1 | ⬜ Untested |
| ARCH-020 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-026 | `run_subprocess` | UTP-026-A | Statement & Branch Coverage | UTS-026-A2 | ⬜ Untested |
| ARCH-020 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-026 | `run_subprocess` | UTP-026-A | Statement & Branch Coverage | UTS-026-A3 | ⬜ Untested |
| ARCH-020 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-026 | `run_subprocess` | UTP-026-B | Boundary Value Analysis | UTS-026-B1 | ⬜ Untested |
| ARCH-020 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-026 | `run_subprocess` | UTP-026-B | Boundary Value Analysis | UTS-026-B2 | ⬜ Untested |
| ARCH-020 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-026 | `run_subprocess` | UTP-026-B | Boundary Value Analysis | UTS-026-B3 | ⬜ Untested |
| ARCH-020 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-026 | `run_subprocess` | UTP-026-B | Boundary Value Analysis | UTS-026-B4 | ⬜ Untested |
| ARCH-020 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-026 | `run_subprocess` | UTP-026-B | Boundary Value Analysis | UTS-026-B5 | ⬜ Untested |
| ARCH-020 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-026 | `run_subprocess` | UTP-026-C | Strict Isolation | UTS-026-C1 | ⬜ Untested |
| ARCH-020 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-026 | `run_subprocess` | UTP-026-C | Strict Isolation | UTS-026-C2 | ⬜ Untested |
| ARCH-021 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-027 | `atomic_write` | UTP-027-A | Statement & Branch Coverage | UTS-027-A1 | ⬜ Untested |
| ARCH-021 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-027 | `atomic_write` | UTP-027-A | Statement & Branch Coverage | UTS-027-A2 | ⬜ Untested |
| ARCH-021 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-027 | `atomic_write` | UTP-027-A | Statement & Branch Coverage | UTS-027-A3 | ⬜ Untested |
| ARCH-021 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-027 | `atomic_write` | UTP-027-B | Boundary Value Analysis | UTS-027-B1 | ⬜ Untested |
| ARCH-021 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-027 | `atomic_write` | UTP-027-B | Boundary Value Analysis | UTS-027-B2 | ⬜ Untested |
| ARCH-021 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-027 | `atomic_write` | UTP-027-B | Boundary Value Analysis | UTS-027-B3 | ⬜ Untested |
| ARCH-021 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-027 | `atomic_write` | UTP-027-B | Boundary Value Analysis | UTS-027-B4 | ⬜ Untested |
| ARCH-021 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-027 | `atomic_write` | UTP-027-B | Boundary Value Analysis | UTS-027-B5 | ⬜ Untested |
| ARCH-021 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-027 | `atomic_write` | UTP-027-C | Strict Isolation | UTS-027-C1 | ⬜ Untested |
| ARCH-021 ([CROSS-CUTTING]) | [CROSS-CUTTING] | MOD-027 | `atomic_write` | UTP-027-C | Strict Isolation | UTS-027-C2 | ⬜ Untested |

### Matrix D Coverage

| Metric | Value |
|--------|-------|
| **Total Module Designs (MOD)** | 27 |
| **External Modules** | 0 |
| **Testable Modules** | 27 |
| **Total Unit Test Cases (UTP)** | 65 |
| **Total Unit Scenarios (UTS)** | 221 |
| **ARCH → MOD Coverage** | 21/21 (100%) |
| **MOD → UTP Coverage** | 27/27 (100%) |

## Matrix H — Hazard Traceability

| HAZ ID | Mitigation | Verification | Status |
|--------|-----------|-------------|--------|
| HAZ-001 | REQ-001 | ATP-001-B ATP-001-A | ⬜ Pending |
| | REQ-008 | ATP-008-A | ⬜ Pending |
| | SYS-012 | STP-012-A | ⬜ Pending |
| HAZ-002 | REQ-007 | ATP-007-A ATP-007-B | ⬜ Pending |
| | REQ-NF-003 | ATP-NF-003-A | ⬜ Pending |
| | SYS-005 | STP-005-A STP-005-B | ⬜ Pending |
| | SYS-010 | STP-010-A STP-010-B STP-010-C | ⬜ Pending |
| HAZ-003 | REQ-008 | ATP-008-A | ⬜ Pending |
| | REQ-026 | ATP-026-A | ⬜ Pending |
| | SYS-012 | STP-012-A | ⬜ Pending |
| HAZ-004 | REQ-009 | ATP-009-B ATP-009-A | ⬜ Pending |
| | SYS-012 | STP-012-A | ⬜ Pending |
| HAZ-005 | REQ-010 | ATP-010-A | ⬜ Pending |
| | REQ-013 | ATP-013-A | ⬜ Pending |
| | REQ-NF-005 | ATP-NF-005-A | ⬜ Pending |
| HAZ-006 | REQ-015 | ATP-015-A | ⬜ Pending |
| | SYS-012 | STP-012-A | ⬜ Pending |
| HAZ-007 | REQ-023 | ATP-023-A | ⬜ Pending |
| | REQ-NF-002 | ATP-NF-002-A | ⬜ Pending |
| | SYS-006 | STP-006-A STP-006-B | ⬜ Pending |
| HAZ-008 | REQ-NF-005 | ATP-NF-005-A | ⬜ Pending |
| | SYS-007 | STP-007-A STP-007-B | ⬜ Pending |
| HAZ-009 | REQ-016 | ATP-016-B ATP-016-A | ⬜ Pending |
| | REQ-017 | ATP-017-A | ⬜ Pending |
| | REQ-NF-004 | ATP-NF-004-A | ⬜ Pending |
| | REQ-CN-002 | ATP-CN-002-A | ⬜ Pending |
| HAZ-010 | REQ-016 | ATP-016-B ATP-016-A | ⬜ Pending |
| HAZ-011 | REQ-007 | ATP-007-A ATP-007-B | ⬜ Pending |
| | REQ-NF-003 | ATP-NF-003-A | ⬜ Pending |
| | REQ-CN-001 | ATP-CN-001-A | ⬜ Pending |
| HAZ-012 | REQ-023 | ATP-023-A | ⬜ Pending |
| | REQ-NF-002 | ATP-NF-002-A | ⬜ Pending |
| | SYS-006 | STP-006-A STP-006-B | ⬜ Pending |
| | SYS-006 | STP-006-A STP-006-B | ⬜ Pending |
| | SYS-013 | STP-013-A STP-013-B | ⬜ Pending |
| HAZ-013 | REQ-023 | ATP-023-A | ⬜ Pending |
| | SYS-006 | STP-006-A STP-006-B | ⬜ Pending |
| | SYS-006 | STP-006-A STP-006-B | ⬜ Pending |
| HAZ-014 | REQ-022 | ATP-022-B ATP-022-A | ⬜ Pending |
| | REQ-NF-005 | ATP-NF-005-A | ⬜ Pending |
| | SYS-003 | STP-003-A STP-003-B STP-003-C | ⬜ Pending |
| HAZ-015 | REQ-024 | ATP-024-A ATP-024-B | ⬜ Pending |
| | SYS-003 | STP-003-A STP-003-B STP-003-C | ⬜ Pending |
| HAZ-016 | REQ-014 | ATP-014-A ATP-014-B | ⬜ Pending |
| | SYS-002 | STP-002-A STP-002-B STP-002-C | ⬜ Pending |
| HAZ-017 | REQ-IF-001 | ATP-IF-001-A | ⬜ Pending |
| | REQ-IF-002 | ATP-IF-002-A | ⬜ Pending |
| | REQ-029 | ATP-029-A ATP-029-B | ⬜ Pending |
| | REQ-CN-001 | ATP-CN-001-A | ⬜ Pending |
| HAZ-018 | REQ-029 | ATP-029-A ATP-029-B | ⬜ Pending |
| | REQ-CN-001 | ATP-CN-001-A | ⬜ Pending |
| | SYS-005 | STP-005-A STP-005-B | ⬜ Pending |
| HAZ-019 | REQ-IF-003 | ATP-IF-003-A | ⬜ Pending |
| | REQ-IF-005 | ATP-IF-005-A | ⬜ Pending |
| | REQ-NF-006 | ATP-NF-006-A | ⬜ Pending |
| HAZ-020 | REQ-027 | ATP-027-A | ⬜ Pending |
| | REQ-IF-004 | ATP-IF-004-A | ⬜ Pending |
| HAZ-021 | REQ-NF-001 | ATP-NF-001-A | ⬜ Pending |
| | REQ-CN-003 | ATP-CN-003-A | ⬜ Pending |
| | REQ-CN-004 | ATP-CN-004-A | ⬜ Pending |
| HAZ-022 | REQ-021 | ATP-021-A | ⬜ Pending |
| | SYS-012 | STP-012-A | ⬜ Pending |
| HAZ-023 | REQ-023 | ATP-023-A | ⬜ Pending |
| | REQ-NF-002 | ATP-NF-002-A | ⬜ Pending |
| | SYS-003 | STP-003-A STP-003-B STP-003-C | ⬜ Pending |
| HAZ-024 | REQ-024 | ATP-024-A ATP-024-B | ⬜ Pending |
| | SYS-003 | STP-003-A STP-003-B STP-003-C | ⬜ Pending |
| HAZ-025 | REQ-027 | ATP-027-A | ⬜ Pending |
| | REQ-IF-004 | ATP-IF-004-A | ⬜ Pending |

### Matrix H Coverage

| Metric | Value |
|--------|-------|
| **Total Hazards (HAZ)** | 25 |
| **HAZ with Verification** | 25/25 (100%) |

## Audit Notes

- **Matrix generated by**: `build-matrix.sh` (deterministic regex parser)
- **Source documents**: `requirements.md`, `acceptance-plan.md`, `system-design.md`, `system-test.md`, `architecture-design.md`, `integration-test.md`, `module-design.md`, `unit-test.md`, `hazard-analysis.md`
- **Last validated**: 2026-04-26
