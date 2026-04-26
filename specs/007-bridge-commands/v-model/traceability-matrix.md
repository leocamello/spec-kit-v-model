# Traceability Matrix

**Generated**: 2026-04-26
**Source**: `specs/007-bridge-commands/v-model//`

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
| **REQ-IF-003** | The `v-model.implement` command SHALL register the `before_implement` and `after_implement` extension hooks to invoke the `v-model.trace` command, and the `/speckit.v-model.requirements` command SHALL be reachable via the `after_specify` hook. | ATP-IF-003-A | `extensions.yml` registers required hooks | SCN-IF-003-A1 | ⬜ Untested |
| **REQ-IF-004** | All three bridge commands SHALL emit their structured stdout summary in a format machine-readable by the project's existing summary-parsing tooling (the same conventions used by `v-model.test-results` and `v-model.audit-report`). | ATP-IF-004-A | Summary parser shared with `test-results` and `audit-report` succeeds | SCN-IF-004-A1 | ⬜ Untested |
| **REQ-NF-001** | The bridge commands collectively SHALL achieve 100% test coverage across BATS, Pester, structural eval, and LLM eval test suites before merge into `main`. | ATP-NF-001-A | BATS, Pester, structural, LLM evals all present and green | SCN-NF-001-A1 | ⬜ Untested |
| **REQ-NF-002** | The `v-model.implement` command SHALL produce zero hallucinated V-Model identifiers in any generated artifact, measured as 100% pass rate on the structural-eval ID-validation check across all test fixtures. | ATP-NF-002-A | Structural eval reports zero hallucinated IDs across all fixtures | SCN-NF-002-A1 | ⬜ Untested |
| **REQ-NF-003** | All bridge command outputs intended for spec-kit core consumption SHALL parse without error, warning, or unrecognised-token diagnostic when processed by an unmodified spec-kit core release pinned at the version present at v0.7.0 release. | ATP-NF-003-A | Pinned spec-kit core release ingests bridge outputs cleanly | SCN-NF-003-A1 | ⬜ Untested |
| **REQ-NF-004** | When run on a feature with a known-incomplete traceability matrix, the `v-model.implement` command SHALL refuse to proceed in 100% of cases and SHALL produce a gap report identifying every missing matrix. | ATP-NF-004-A | Refusal verified across N gap fixtures | SCN-NF-004-A1 | ⬜ Untested |
| **REQ-NF-005** | When run on a feature missing one or more optional V-Model artifacts (e.g., `hazard-analysis.md`, `system-test.md`), all three bridge commands SHALL complete successfully and SHALL emit a summary that names each skipped artifact. | ATP-NF-005-A | All three commands complete with skipped-artifact summary | SCN-NF-005-A1 | ⬜ Untested |
| **REQ-NF-006** | The bridge commands SHALL NOT introduce any change to the existing extension hook infrastructure; only the registered hooks themselves are subject to modification under this feature. | ATP-NF-006-A | Diff of hook infrastructure code is empty | SCN-NF-006-A1 | ⬜ Untested |

### Matrix A Coverage

| Metric | Value |
|--------|-------|
| **Total Requirements** | 43 |
| **Total Test Cases (ATP)** | 51 |
| **Total Scenarios (SCN)** | 51 |
| **REQ → ATP Coverage** | 43/43 (100%) |
| **ATP → SCN Coverage** | 51/51 (100%) |


### Uncovered Requirements (REQ without ATP)

None — full coverage.

### Orphaned Test Cases (ATP without valid REQ)

None — all tests trace to requirements.

## Audit Notes

- **Matrix generated by**: `build-matrix.sh` (deterministic regex parser)
- **Source documents**: `requirements.md`, `acceptance-plan.md`, `unit-test.md`
- **Last validated**: 2026-04-26
