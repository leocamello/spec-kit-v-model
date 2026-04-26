# V-Model Requirements Specification: Bridge Commands

**Feature Branch**: `feature/007-bridge-commands`
**Created**: 2026-04-26
**Status**: Draft
**Source**: `specs/007-bridge-commands/spec.md`

## Overview

This document formalizes the requirements for adding three bridge commands to the V-Model Extension Pack: `/speckit.v-model.plan` (OPTIONAL), `/speckit.v-model.tasks` (OPTIONAL), and `/speckit.v-model.implement` (CORE). These commands close the spec-to-code gap that has existed since v0.1.0 by consuming a complete V-Model artifact set and emitting outputs that are byte-compatible with spec-kit core's canonical schemas (`plan.md`, `tasks.md`, source code), with V-Model traceability layered as additive enrichment that spec-kit core tools harmlessly ignore. The commands enable three user paths — Full Ceremony (entirely V-Model), Direct Path (V-Model artifacts → `v-model.implement` → code), and Hybrid (mix `v-model.*` and `speckit.*` commands at any layer). `v-model.implement` reuses the existing deterministic scripts (`build-matrix`, `validate-*-coverage`) as its pre-implementation gate; no new wrapper script is introduced.

## Requirements

### Functional Requirements

#### `v-model.plan` (OPTIONAL bridge command)

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-001 | The `v-model.plan` command SHALL read every V-Model artifact present in the feature directory: `requirements.md`, `acceptance-plan.md`, `system-design.md`, `system-test.md`, `architecture-design.md`, `integration-test.md`, `module-design.md`, `unit-test.md`, `hazard-analysis.md`, and `traceability-matrix.md`, plus the project constitution. | P1 | The command must synthesize from the full V-Model artifact set; selectively reading subsets would drop traceability links. (Source: spec.md FR-001) | Test |
| REQ-002 | The `v-model.plan` command SHALL produce a `plan.md` file in the feature directory that conforms to spec-kit core's canonical `plan-template.md` schema. | P1 | Schema conformance is what enables unmodified `speckit.tasks` to consume the output. (Source: spec.md FR-002, User Story 2 acceptance scenario 2) | Test |
| REQ-003 | The `v-model.plan` command SHALL produce a `data-model.md` file extracted from the Data Design view of `system-design.md`. | P1 | The Data Design view is the authoritative source of data model decisions in the V-Model; duplicating elsewhere would create drift. (Source: spec.md FR-003) | Test |
| REQ-004 | The `v-model.plan` command SHALL produce a `contracts/` directory containing interface contract files extracted from the Interface view of `architecture-design.md`. | P1 | The architecture-design Interface view defines component boundaries and contracts; spec-kit core's `contracts/` directory is the canonical location for these artifacts. (Source: spec.md FR-004) | Test |
| REQ-005 | The `v-model.plan` command SHALL produce a `quickstart.md` file extracted from the BDD scenarios of `acceptance-plan.md`, prioritising the top critical user paths. | P2 | The quickstart is intended for new contributors; the most critical acceptance scenarios are the most informative onboarding examples. (Source: spec.md FR-005) | Test |
| REQ-006 | The `v-model.plan` command SHALL produce a `research.md` file populated with any `[DERIVED REQUIREMENT]` or `[DERIVED MODULE]` flags encountered during synthesis, each linked to the artifact that introduced the derivation. | P2 | Spec-kit core's `research.md` is where derivation rationale lives; surfacing V-Model derivation flags here preserves traceability across the schema bridge. (Source: spec.md FR-006) | Test |
| REQ-007 | The `v-model.plan` command SHALL embed V-Model traceability metadata in its outputs as HTML comments and optional Markdown sections such that spec-kit core tooling parses the documents without error and ignores the embedded enrichment. | P1 | The additive-enrichment pattern is the central interoperability mechanism; if it leaked into core-parsed structures it would break the `speckit.*` toolchain. (Source: spec.md FR-007, Key Entity "V-Model enrichment") | Test |
| REQ-008 | When one or more V-Model artifacts are absent from the feature directory, the `v-model.plan` command SHALL omit the corresponding output sections, complete successfully with a non-zero warning indicator in its summary, and list each missing artifact by name. | P2 | Graceful degradation enables progressive adoption; a hard failure would force teams to author all artifacts up front. (Source: spec.md FR-008, User Story 2 acceptance scenario 3) | Test |

#### `v-model.tasks` (OPTIONAL bridge command)

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-009 | The `v-model.tasks` command SHALL read every V-Model artifact present in the feature directory, plus `plan.md` if it exists, regardless of whether the `plan.md` was produced by `v-model.plan` or by `speckit.plan`. | P1 | Bidirectional compatibility requires the command to operate on both V-Model-enriched and pure spec-kit-core plans. (Source: spec.md FR-009, User Story 4) | Test |
| REQ-010 | The `v-model.tasks` command SHALL produce a `tasks.md` file in the feature directory that conforms to spec-kit core's canonical `tasks-template.md` schema. | P1 | Schema conformance is what enables unmodified `speckit.implement` to consume the output. (Source: spec.md FR-010, FR-015, User Story 3 acceptance scenario 2) | Test |
| REQ-011 | The `v-model.tasks` command SHALL order the emitted tasks TDD-style in the following sequence: write unit tests, implement modules, run unit tests, write integration tests, run integration tests, write system tests, run system tests, write acceptance tests. | P1 | TDD ordering enforces that tests precede implementation at every level, mirroring the right side of the V-Model. (Source: spec.md FR-011) | Test |
| REQ-012 | The `v-model.tasks` command SHALL embed traceability metadata for each task as an HTML comment using the form `<!-- traces-to: MOD-NNN → ARCH-NNN → SYS-NNN → REQ-NNN -->`, naming every upstream V-Model ID the task fulfils. | P1 | HTML-comment traceability is invisible to spec-kit core parsers but discoverable by V-Model tooling, satisfying the additive-enrichment principle. (Source: spec.md FR-012) | Test |
| REQ-013 | The `v-model.tasks` command SHALL mark independent modules within the same architecture with the `[P]` parallel-execution marker exactly as defined by spec-kit core's tasks schema. | P2 | Parallel execution is a spec-kit core convention; honouring it preserves the value of the canonical schema for downstream tooling. (Source: spec.md FR-013) | Test |
| REQ-014 | When `hazard-analysis.md` is present in the feature directory, the `v-model.tasks` command SHALL flag mitigation tasks as higher priority and SHALL emit dedicated verification tasks that explicitly reference each `HAZ-NNN` identifier. | P1 | Hazards demand traceable verification evidence; auto-emitting verification tasks ensures no mitigation is silently skipped during implementation. (Source: spec.md FR-014, User Story 3 acceptance scenario 3) | Test |

#### `v-model.implement` (CORE bridge command)

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-015 | The `v-model.implement` command SHALL read all V-Model artifacts directly from the feature directory without requiring a `plan.md` or `tasks.md` to be present. | P1 | The Direct Path is the recommended default; requiring intermediate artifacts would force teams down the Full Ceremony path unnecessarily. (Source: spec.md FR-016, User Story 1) | Test |
| REQ-016 | The `v-model.implement` command SHALL refuse to start when Matrix A, B, C, D, or H is incomplete, MUST exit with a non-zero exit code, and MUST produce a gap report to stdout naming each incomplete matrix and the rows that are missing required IDs. | P1 | Code generation against an incomplete matrix would produce code without verifiable traceability — the exact failure mode V-Model exists to prevent. (Source: spec.md FR-017, User Story 1 acceptance scenario 2) | Test |
| REQ-017 | The `v-model.implement` command SHALL invoke the existing `build-matrix`, `validate-requirement-coverage`, `validate-system-coverage`, `validate-architecture-coverage`, `validate-integration-coverage`, and `validate-module-coverage` scripts as its pre-implementation gate. | P1 | Reusing the deterministic scripts ensures that the gate criterion remains identical to what CI enforces today; introducing a parallel gate would risk drift. (Source: spec.md FR-018) | Test |
| REQ-018 | The `v-model.implement` command SHALL generate source code into the file paths declared by the Target Source File field of each `MOD-NNN` entry in `module-design.md`. | P1 | The Target Source File mapping is the authoritative bridge from module design to source layout; honouring it is what makes traceability physically verifiable in code. (Source: spec.md FR-019, Key Entity "Target Source File mapping") | Test |
| REQ-019 | Every public function, class, or module produced by `v-model.implement` SHALL carry a comment of the form `// Implements <ID> (traces to <upstream-ID>)` (or the equivalent comment syntax for the target language) linking it to the V-Model identifier it realises. | P1 | Embedded traceability comments are how auditors and downstream tooling verify the spec-to-code link without consulting external indices. (Source: spec.md FR-020, User Story 1 acceptance scenario 1) | Test |
| REQ-020 | The `v-model.implement` command SHALL generate tests at four levels — unit, integration, system, and acceptance — matching the corresponding V-Model test plans (UTP/UTS, ITP/ITS, STP/STS, ATP/SCN). | P1 | A code generator that omits tests would invalidate the V-Model premise of paired design-test artifacts at every level. (Source: spec.md FR-021) | Test |
| REQ-021 | Commits produced by `v-model.implement` SHALL include the implementing V-Model identifiers in the commit message, formatted as a comma-separated suffix (e.g., `feat(<scope>): <subject> — MOD-NNN, REQ-NNN`). | P2 | Commit-message identifiers enable git-history-based traceability and integration with audit-report tooling. (Source: spec.md FR-022, User Story 1 acceptance scenario 1) | Inspection |
| REQ-022 | The `v-model.implement` command SHALL NOT overwrite source-file content that lies outside the regions managed by the V-Model, and SHALL preserve user customisations located between V-Model-managed regions when re-running. | P1 | A code generator that destroys hand-written code would prevent the Hybrid user path and erode trust in re-generation. (Source: spec.md FR-023, Edge Case "Existing target source files...", User Story 1 acceptance scenario 3) | Test |
| REQ-023 | The `v-model.implement` command SHALL self-verify, before committing any output, that every `// Implements <ID>` comment it generated references an identifier that exists in the feature's V-Model artifacts; if any hallucinated identifier is detected the command MUST exit non-zero and MUST NOT commit. | P1 | A hallucinated traceability link is worse than no link — it falsely asserts compliance. The pre-commit self-check is the safety net. (Source: spec.md FR-024, Edge Case "Hallucinated V-Model IDs...", spec.md SC-002) | Test |
| REQ-024 | The `v-model.implement` command SHALL honour the configured domain overlay (read from `v-model-config.yml`) by applying overlay-specific output requirements, including but not limited to MC/DC unit-test coverage requirements for DO-178C Level A and ASIL-driven test depth for ISO 26262. | P1 | Domain overlays are the mechanism by which the project encodes regulatory rigor; bridge commands must respect them or the regulated-industry value proposition is lost. (Source: spec.md FR-025, FR-030) | Test |
| REQ-025 | The `v-model.implement` command SHALL be idempotent: re-running it on identical inputs MUST produce output that differs only in non-substantive ways (LLM phrasing variability), measured as ≥95% structural identity by the project's structural eval comparison. | P1 | Idempotency is what makes generated code reviewable as a stable artifact; non-determinism would force every re-run to be re-audited. (Source: spec.md FR-026, SC-007) | Analysis |

#### Cross-cutting (all three bridge commands)

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-026 | All three bridge commands SHALL be invocable from the spec-kit CLI under the names `/speckit.v-model.plan`, `/speckit.v-model.tasks`, and `/speckit.v-model.implement` respectively. | P1 | Naming conformance with the existing `/speckit.v-model.*` family is required for discoverability and consistency with the rest of the extension pack. (Source: spec.md FR-027) | Test |
| REQ-027 | All three bridge commands SHALL produce a structured summary on stdout indicating: every input artifact read, every output artifact produced, every optional artifact skipped, and every warning encountered. | P1 | The structured summary is what CI tooling and human reviewers consume to verify the command's behaviour without re-reading every output file. (Source: spec.md FR-029) | Test |
| REQ-028 | When V-Model enrichment is absent in upstream artifacts (for example, a `plan.md` produced by `speckit.plan` rather than `v-model.plan`), bridge commands that consume those artifacts SHALL proceed with reduced enrichment rather than failing. | P1 | This is the technical mechanism that makes the Hybrid user path work; without it, mixing `speckit.*` and `v-model.*` would be impossible. (Source: spec.md FR-032, User Story 4 acceptance scenario 1) | Test |
| REQ-029 | A `plan.md` produced by `v-model.plan` SHALL be valid input to unmodified `speckit.tasks`, and a `tasks.md` produced by `v-model.tasks` SHALL be valid input to unmodified `speckit.implement`, in 100% of cases covered by the round-trip test fixtures. | P1 | The round-trip property is what spec-kit bidirectional compatibility means in operational terms; without it, the design principle is unverified. (Source: spec.md FR-031, SC-003, SC-004) | Test |

### Non-Functional Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-NF-001 | The bridge commands collectively SHALL achieve 100% test coverage across BATS, Pester, structural eval, and LLM eval test suites before merge into `main`. | P1 | The project's quality bar (established in v0.5.0/v0.6.0) requires four-stack coverage for every command; bridge commands are the most safety-critical addition to date. (Source: spec.md SC-008) | Analysis |
| REQ-NF-002 | The `v-model.implement` command SHALL produce zero hallucinated V-Model identifiers in any generated artifact, measured as 100% pass rate on the structural-eval ID-validation check across all test fixtures. | P1 | Functional Suitability (ISO/IEC 25010 Accuracy): the credibility of the entire V-Model claim depends on the ID-to-code link being verifiable. (Source: spec.md SC-002, FR-024) | Test |
| REQ-NF-003 | All bridge command outputs intended for spec-kit core consumption SHALL parse without error, warning, or unrecognised-token diagnostic when processed by an unmodified spec-kit core release pinned at the version present at v0.7.0 release. | P1 | Compatibility (ISO/IEC 25010): the additive-enrichment promise is empty if it produces parse warnings in core tooling. (Source: spec.md FR-007, FR-012, Key Entity "V-Model enrichment") | Test |
| REQ-NF-004 | When run on a feature with a known-incomplete traceability matrix, the `v-model.implement` command SHALL refuse to proceed in 100% of cases and SHALL produce a gap report identifying every missing matrix. | P1 | Reliability (ISO/IEC 25010 Fault Tolerance): the safety net must never silently fail open. (Source: spec.md SC-005, FR-017) | Test |
| REQ-NF-005 | When run on a feature missing one or more optional V-Model artifacts (e.g., `hazard-analysis.md`, `system-test.md`), all three bridge commands SHALL complete successfully and SHALL emit a summary that names each skipped artifact. | P2 | Reliability (ISO/IEC 25010 Fault Tolerance) and Compatibility: enables progressive adoption. (Source: spec.md SC-006, Edge Case "Missing optional V-Model artifacts") | Test |
| REQ-NF-006 | The bridge commands SHALL NOT introduce any change to the existing extension hook infrastructure; only the registered hooks themselves are subject to modification under this feature. | P1 | Maintainability and scope discipline: hook-infrastructure changes are out of scope per spec.md "Out of Scope". Limiting the surface area protects existing extensions. (Source: spec.md Assumption "Bridge commands operate within the existing extension hook system") | Inspection |

### Interface Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-IF-001 | The `v-model.plan` command output `plan.md` SHALL conform exactly to spec-kit core's canonical `plan-template.md` schema as published at v0.7.0 release time, with all required sections present and in the prescribed order. | P1 | This is the contract that makes `v-model.plan` interchangeable with `speckit.plan` from the consumer's viewpoint. (Source: spec.md FR-002, FR-031) | Test |
| REQ-IF-002 | The `v-model.tasks` command output `tasks.md` SHALL conform exactly to spec-kit core's canonical `tasks-template.md` schema as published at v0.7.0 release time, including the `[P]` parallel-execution marker convention. | P1 | This is the contract that makes `v-model.tasks` interchangeable with `speckit.tasks` from the consumer's viewpoint. (Source: spec.md FR-010, FR-013, FR-015) | Test |
| REQ-IF-003 | The `v-model.implement` command SHALL register the `before_implement` and `after_implement` extension hooks to invoke the `v-model.trace` command, and the `/speckit.v-model.requirements` command SHALL be reachable via the `after_specify` hook. | P1 | Hook registration is what wires the bridge commands into the existing automation graph; without it the commands would be invocable only manually. (Source: spec.md FR-028) | Test |
| REQ-IF-004 | All three bridge commands SHALL emit their structured stdout summary in a format machine-readable by the project's existing summary-parsing tooling (the same conventions used by `v-model.test-results` and `v-model.audit-report`). | P2 | Consistency with existing commands enables downstream tooling reuse and avoids per-command parser maintenance. (Source: spec.md FR-029, prior-art alignment) | Inspection |

### Constraint Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-CN-001 | The bridge commands SHALL NOT require any modification to the upstream spec-kit core repository; they MUST function correctly against the unmodified spec-kit core release pinned at v0.7.0 release time. | P1 | This is the foundational constraint that distinguishes an extension from a fork. Violating it would invalidate the entire extension architecture. (Source: spec.md "Out of Scope" — "Changes to spec-kit core itself") | Inspection |
| REQ-CN-002 | The `v-model.implement` command SHALL NOT introduce any new wrapper script that duplicates the gating logic of `build-matrix` or `validate-*-coverage`; reuse of the existing scripts is mandatory. | P1 | Duplication would create the drift hazard the V-Model is built to prevent and would multiply the test surface. (Source: spec.md FR-018, "Out of Scope" — "Standalone CI/CD-callable pre-implementation gate script") | Inspection |
| REQ-CN-003 | The bridge commands SHALL NOT introduce a new orchestrator agent, supervisor architecture, model tiering, sandbox-execution isolation, correlation log, or workflow-YAML single-command V-cycle orchestrator under v0.7.0; those capabilities are explicitly deferred to milestones M2 and M3. | P1 | Scope discipline: these capabilities are explicitly out of scope per the feature spec. Including them under v0.7.0 would dilute the bridge-commands deliverable and risk schedule slip. (Source: spec.md "Out of Scope" — items 1, 2, 3, 5, 6, 7) | Inspection |
| REQ-CN-004 | The bridge commands SHALL be developed under the project's "dogfood-driven development" discipline: the V-Model artifacts for `specs/007-bridge-commands/` SHALL be produced and validated before any bridge-command implementation code is written. | P1 | Dogfooding is what proves the commands' usefulness on the project's own work and surfaces gaps in the V-Model methodology before they reach external users. (Source: spec.md SC-010, Assumption "the dogfood for this feature uses the bridge commands' own V-Model artifacts...") | Inspection |

## Assumptions

- The team has already completed the V-cycle for the feature being implemented; bridge commands are the **last** step before code, not a substitute for the design phase. (Source: spec.md Assumption 1)
- Spec-kit core's canonical schemas (`plan-template.md`, `tasks-template.md`) remain stable across the v0.7.0 timeframe; bridge commands target the schema present at v0.7.0 release. (Source: spec.md Assumption 2)
- The project's existing deterministic scripts (`build-matrix`, `validate-*-coverage`) are sufficient to enforce the pre-implementation gate without further enhancement. (Source: spec.md Assumption 3)
- Code generation is performed by the same LLM tier already used by other generative V-Model commands; no separate model tier is introduced for `v-model.implement` in v0.7.0. (Source: spec.md Assumption 4)
- The "additive enrichment" pattern (HTML comments + optional sections) is sufficient to avoid breaking spec-kit core consumers; this assumption will be empirically validated by REQ-NF-003. (Source: spec.md Assumption 6)
- The first production of bridge-command code occurs before `v-model.implement` itself exists; that initial implementation is performed by the human developer (with AI assistance) following the spec, and only subsequent re-implementations or refinements can leverage `v-model.implement` itself. (Source: spec.md Assumption 8 — bootstrap clause)

## Dependencies

- Spec-kit core release pinned at the version present at v0.7.0 release time (provides `plan-template.md`, `tasks-template.md`, `speckit.plan`, `speckit.tasks`, `speckit.implement`).
- Existing project deterministic scripts: `build-matrix`, `validate-requirement-coverage`, `validate-system-coverage`, `validate-architecture-coverage`, `validate-integration-coverage`, `validate-module-coverage` (consumed by REQ-017).
- Existing extension hook infrastructure as defined in `.specify/extensions.yml` (consumed unchanged per REQ-NF-006; only hook registrations are modified).
- Existing project test infrastructure: BATS, Pester, structural eval harness, LLM eval harness (required by REQ-NF-001).

## Glossary

| Term | Definition |
|------|-----------|
| Bridge command | A V-Model command that produces output in spec-kit core canonical format, enabling downstream consumption by unmodified `speckit.*` commands. |
| Additive enrichment | The pattern of layering V-Model traceability metadata onto canonical spec-kit artifacts as HTML comments and optional sections that core tooling harmlessly ignores. |
| Direct Path | The user path in which V-Model artifacts feed directly into `v-model.implement` without producing intermediate `plan.md` or `tasks.md`. The recommended default. |
| Full Ceremony | The user path in which every V-Model command (including `v-model.plan` and `v-model.tasks`) is run before `v-model.implement`. |
| Hybrid path | Any user path that mixes `speckit.*` and `v-model.*` commands at any layer of the workflow. |
| Pre-implementation gate | The composite check executed by `v-model.implement` before code generation, comprising `build-matrix` plus the five `validate-*-coverage` scripts (REQ-017). |
| Target Source File | The field within each `MOD-NNN` entry in `module-design.md` declaring the source file path(s) the module implements; drives where `v-model.implement` writes code. |
| Round-trip property | The property that a `plan.md` produced by `v-model.plan` is valid input to `speckit.tasks`, and a `tasks.md` produced by `v-model.tasks` is valid input to `speckit.implement` (REQ-029). |
| Structural eval | The deterministic test harness that checks output structure (presence of sections, IDs, formats) without invoking an LLM judge. |

---

**Total Requirements**: 43 (43 active, 0 deprecated)
**By Category**: Functional: 29 | Non-Functional: 6 | Interface: 4 | Constraint: 4
**By Priority**: P1: 36 | P2: 7 | P3: 0
**By Verification Method**: Test: 34 | Inspection: 7 | Analysis: 2 | Demonstration: 0
