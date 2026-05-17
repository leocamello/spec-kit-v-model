# Feature Specification: Bridge Commands (V-Model ↔ Spec-Kit Core)

**Feature Branch**: `feature/007-bridge-commands`
**Created**: 2026-04-26
**Status**: Approved
**Input**: User description: "Add three bridge commands to spec-kit-v-model that connect V-Model specification artifacts to actual code generation: `v-model.plan`, `v-model.tasks`, and `v-model.implement`. All three must produce outputs that are byte-compatible with spec-kit core's canonical schemas, with V-Model traceability metadata layered as additive enrichment that spec-kit core tools harmlessly ignore. Users can mix and match `v-model.*` and `speckit.*` commands at any layer (full ceremony, direct path, or hybrid). `v-model.implement` uses a hybrid pattern: agent-driven code generation plus reuse of existing deterministic scripts as the pre-implementation gate (Matrix A+B+C+D+H validation)."

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Generate Code Directly From a Complete V-Model Specification (Priority: P1)

A team has just finished the V-cycle for a feature: requirements, acceptance plan, system design, system test plan, architecture, integration test plan, module design, unit test plan, hazard analysis, traceability matrix. Today, the workflow ends here — there is no supported path from these artifacts to actual source code that preserves traceability. The team must either hand-translate the artifacts into spec-kit's `tasks.md` format (losing V-Model semantics) or write code manually with no automated traceability enforcement.

The team runs `/speckit.v-model.implement`. The command reads every V-Model artifact directly, validates that the traceability matrix is complete (Matrix A+B+C+D+H), and generates source code, unit tests, integration tests, system tests, and acceptance tests. Every code artifact carries a comment linking it to the V-Model ID it implements (`// Implements MOD-003 (traces to REQ-005)`). Commits are formatted with V-Model IDs in the message.

**Why this priority**: This is the single most important capability — it closes the spec-to-code gap that has existed since v0.1.0. Without it, the V-Model lifecycle ends at specification and never reaches the code that auditors must certify. Every other story in this feature is enrichment around this core capability.

**Independent Test**: Take an existing feature with a complete V-Model artifact set (e.g., `specs/001-v-model-mvp/`), run `v-model.implement`, and verify that (a) source files are produced under their declared Target Source Files, (b) every public function has a `// Implements MOD-NNN` comment, (c) tests are produced at all four levels (unit/integration/system/acceptance) matching the test plans, and (d) the resulting commit message includes the implementing V-Model IDs.

**Acceptance Scenarios**:

1. **Given** a feature directory with complete V-Model artifacts and a fully validated traceability matrix, **When** the user runs `/speckit.v-model.implement`, **Then** source code is produced with `// Implements <ID>` comments, tests are produced at all levels matching the test plans, and the resulting commit message includes the V-Model IDs covered.
2. **Given** a feature directory with an incomplete traceability matrix (one or more rows missing required IDs), **When** the user runs `/speckit.v-model.implement`, **Then** the command refuses to start, reports which matrices are incomplete, and exits non-zero.
3. **Given** an existing codebase, **When** `v-model.implement` runs against an updated V-Model spec, **Then** new code is added without overwriting hand-written code outside the declared Target Source Files.

---

### User Story 2 — Compile V-Model Artifacts Into a Spec-Kit-Compatible Plan (Priority: P2)

A team has completed the V-cycle but wants to use spec-kit core's familiar `speckit.tasks` → `speckit.implement` workflow for the implementation phase. They need a `plan.md`, `data-model.md`, `contracts/`, `research.md`, and `quickstart.md` in the format spec-kit core expects, but want those artifacts to faithfully reflect the V-Model design decisions (architecture, interface contracts, data design) that the team has already produced.

The team runs `/speckit.v-model.plan`. The command reads every V-Model artifact and synthesizes a `plan.md` that follows spec-kit's canonical schema. The data model is extracted from the system-design Data Design view; contracts are extracted from the architecture-design Interface view; the quickstart is extracted from acceptance-plan BDD scenarios. V-Model traceability is layered in as additive enrichment (HTML comments, optional cross-reference sections) that `speckit.tasks` and `speckit.implement` ignore. From this point on, the team can use either V-Model or spec-kit core commands interchangeably.

**Why this priority**: This is the **interoperability** story. It lets teams adopt V-Model selectively for the design phase while keeping their existing spec-kit core implementation workflow. Without it, V-Model is an isolated island; with it, V-Model becomes a richer "front end" for spec-kit core.

**Independent Test**: Run `v-model.plan` on a feature with complete V-Model artifacts. Verify that the resulting `plan.md` contains every section required by spec-kit's `plan-template.md`, that `speckit.tasks` (unmodified spec-kit core) can consume it without errors, and that V-Model traceability metadata is present but takes the form of HTML comments / optional sections that core tooling skips.

**Acceptance Scenarios**:

1. **Given** a feature with complete V-Model artifacts, **When** `/speckit.v-model.plan` runs, **Then** `plan.md`, `data-model.md`, `contracts/`, `research.md`, and `quickstart.md` are produced and conform to spec-kit's canonical schemas.
2. **Given** the artifacts produced by `v-model.plan`, **When** the team subsequently runs unmodified `speckit.tasks`, **Then** it succeeds and produces a valid `tasks.md`.
3. **Given** a feature missing one or more V-Model artifacts (e.g., no integration-test.md), **When** `/speckit.v-model.plan` runs, **Then** it falls back gracefully, omits the corresponding plan sections, and reports what was missing.

---

### User Story 3 — Generate TDD-Ordered Tasks With Full V-Model Traceability (Priority: P2)

A team wants the structured task breakdown that spec-kit's `tasks.md` provides, but enriched with V-Model traceability so that every task explicitly references the design and test specifications it implements. They want tasks ordered TDD-style (write tests first), with parallel-execution markers (`[P]`) where independent modules can be worked on concurrently.

The team runs `/speckit.v-model.tasks`. The command reads every V-Model artifact and writes a `tasks.md` that follows spec-kit's canonical schema. Each task carries traceability metadata (e.g., `<!-- traces-to: MOD-003 → ARCH-001 → SYS-002 → REQ-005 -->`) as HTML comments that don't affect spec-kit's parsing. Tasks are ordered: write unit tests → implement modules → run unit tests → write integration tests → run integration tests → write system tests → run system tests → write acceptance tests. Hazard mitigations from `hazard-analysis.md` are flagged as higher priority and produce dedicated verification tasks.

**Why this priority**: This is the **mid-tier interop** story. Teams who don't want to fully delegate code generation to `v-model.implement` (Story 1) but also don't want to manually write task breakdowns can use this command to bridge spec-kit's task format with V-Model's traceability discipline.

**Independent Test**: Run `v-model.tasks` on a feature with complete V-Model artifacts. Verify the task list (a) follows TDD ordering, (b) carries traceability metadata for every task, (c) marks independent modules as parallel with `[P]`, and (d) is consumable by unmodified `speckit.implement`.

**Acceptance Scenarios**:

1. **Given** a feature with complete V-Model artifacts, **When** `/speckit.v-model.tasks` runs, **Then** `tasks.md` is produced in spec-kit canonical format with traceability metadata as HTML comments and tasks ordered TDD-style.
2. **Given** the `tasks.md` produced by `v-model.tasks`, **When** the team runs unmodified `speckit.implement`, **Then** it succeeds and implements the tasks in the order specified.
3. **Given** a `hazard-analysis.md` with at least one Catastrophic-severity hazard, **When** `/speckit.v-model.tasks` runs, **Then** the corresponding mitigation tasks are flagged as higher priority and verification tasks are emitted that explicitly reference the HAZ-NNN IDs.

---

### User Story 4 — Mix V-Model and Spec-Kit Core Commands Freely (Priority: P3)

A team is gradually adopting V-Model. They want to start with familiar spec-kit core commands (`speckit.specify`, `speckit.plan`) and progressively introduce V-Model commands (`v-model.tasks`, `v-model.implement`) as they become comfortable. Or they may want to run `v-model.plan` to leverage V-Model design rigor but then continue with `speckit.tasks` and `speckit.implement` because their existing CI tooling expects spec-kit canonical formats.

Every bridge command supports both directions: it reads spec-kit canonical formats when V-Model artifacts are absent, and it produces spec-kit canonical formats that core tooling consumes. There is no "lock-in" — at every step, the user can choose which family of commands to run next. When V-Model enrichment is missing in upstream artifacts, downstream V-Model commands degrade gracefully rather than failing.

**Why this priority**: This story is what makes adoption realistic. It captures a cross-cutting promise — spec-kit interoperability — that all three bridge commands must honour. It is P3 because Stories 1–3 each individually deliver value even before this universal interop is fully realized; this story is the "polish" that turns three commands into a coherent ecosystem.

**Independent Test**: Construct a feature with `speckit.plan` output (no V-Model enrichment). Run `v-model.tasks` against it. Verify that tasks are produced (without V-Model enrichment columns), the command does not error, and the resulting tasks.md is valid spec-kit format. Then construct a feature with `v-model.plan` output. Run `speckit.tasks` against it. Verify success and a valid result.

**Acceptance Scenarios**:

1. **Given** a `plan.md` produced by `speckit.plan` (no V-Model enrichment), **When** `/speckit.v-model.tasks` runs, **Then** it succeeds, omits V-Model-specific traceability sections, and produces a valid spec-kit-format `tasks.md`.
2. **Given** a `plan.md` produced by `/speckit.v-model.plan`, **When** the user runs `speckit.tasks` (unmodified core), **Then** it succeeds and produces a `tasks.md` that respects the plan structure.
3. **Given** any combination of `speckit.*` and `v-model.*` commands run in any order, **When** the user reaches the implement step, **Then** `v-model.implement` reads only the V-Model artifacts it needs and ignores spec-kit-only artifacts; `speckit.implement` reads only the spec-kit artifacts it needs and ignores V-Model-only artifacts.

---

### Edge Cases

- **Incomplete traceability matrix**: `v-model.implement` MUST refuse to start when Matrix A, B, C, D, or H is incomplete. Other bridge commands (`v-model.plan`, `v-model.tasks`) MUST still operate but warn the user that downstream `v-model.implement` will be blocked.
- **Missing V-Model artifacts**: `v-model.plan` and `v-model.tasks` (both OPTIONAL) MUST proceed with reduced enrichment when an artifact is absent and report what was missing in their summary output. `v-model.implement` (CORE) MUST refuse to proceed when **any** of the 8 V-Model artifacts is absent — the four dev-side artifacts (`requirements.md`, `system-design.md`, `architecture-design.md`, `module-design.md`) AND the four test-side artifacts (`acceptance-plan.md`, `system-test.md`, `integration-test.md`, `unit-test.md`) are equally load-bearing: requirements anchor intent, system-design and architecture-design supply boundaries and interface contracts, module-design supplies algorithms and Target Source Files, and the four test plans supply verification at all four levels. Partial implementation contradicts the "fully working and validated software" contract that defines the command's purpose. `hazard-analysis.md` remains auxiliary; its absence is reported as a warning but does not block any bridge.
- **Existing target source files containing hand-written code**: `v-model.implement` MUST NOT overwrite code outside its declared edit zones; it MUST detect and preserve user customisations between V-Model-managed regions.
- **Conflicting MOD-NNN → file mappings**: when two MOD entries declare the same Target Source File, `v-model.implement` MUST refuse to proceed and report the conflict.
- **Hallucinated V-Model IDs in generated code**: every `// Implements <ID>` comment generated by `v-model.implement` MUST reference an ID that actually exists in the V-Model artifacts; the command MUST self-verify before committing.
- **Spec-kit core upgrade changes canonical schema**: bridge commands MUST tolerate reasonable schema evolution in spec-kit core (e.g., new optional fields in `plan-template.md`); they MUST fail loudly only when required fields are removed or renamed.
- **Domain overlay applied**: when a domain overlay (e.g., DO-178C) is configured, bridge commands MUST honour overlay-specific output requirements (e.g., MC/DC coverage requirements in unit tests for DO-178C Level A).
- **Re-running after a partial failure**: bridge commands MUST be idempotent — re-running them on the same inputs produces equivalent output (modulo non-deterministic LLM variability captured by eval-test calibration).

## Requirements *(mandatory)*

### Functional Requirements

#### `v-model.plan` (OPTIONAL bridge command)

- **FR-001**: The command MUST read every V-Model artifact present in the feature directory: `requirements.md`, `acceptance-plan.md`, `system-design.md`, `system-test.md`, `architecture-design.md`, `integration-test.md`, `module-design.md`, `unit-test.md`, `hazard-analysis.md`, `traceability-matrix.md`, plus the project constitution.
- **FR-002**: The command MUST produce `plan.md` that conforms to spec-kit core's canonical `plan-template.md` schema.
- **FR-003**: The command MUST produce `data-model.md` extracted from the system-design Data Design view.
- **FR-004**: The command MUST produce `contracts/` files extracted from the architecture-design Interface view.
- **FR-005**: The command MUST produce `quickstart.md` extracted from the acceptance-plan BDD scenarios (top critical paths).
- **FR-006**: The command MUST produce `research.md` populated with any `[DERIVED REQUIREMENT]` or `[DERIVED MODULE]` flags found during synthesis.
- **FR-007**: V-Model traceability metadata MUST be embedded as HTML comments and optional sections that spec-kit core tools ignore.
- **FR-008**: The command MUST fall back gracefully when one or more V-Model artifacts are absent, omitting the corresponding sections and reporting the gaps in its summary.

#### `v-model.tasks` (OPTIONAL bridge command)

- **FR-009**: The command MUST read every V-Model artifact present, plus `plan.md` if it exists (whether produced by `v-model.plan` or `speckit.plan`).
- **FR-010**: The command MUST produce `tasks.md` that conforms to spec-kit core's canonical `tasks-template.md` schema.
- **FR-011**: Tasks MUST be ordered TDD-style: write unit tests → implement modules → run unit tests → write integration tests → run integration tests → write system tests → run system tests → write acceptance tests.
- **FR-012**: Each task MUST carry V-Model traceability metadata as HTML comments (e.g., `<!-- traces-to: MOD-003 → ARCH-001 → SYS-002 → REQ-005 -->`) that spec-kit core tools ignore.
- **FR-013**: Independent modules within the same architecture MUST be marked with `[P]` for parallel execution.
- **FR-014**: For features that include `hazard-analysis.md`, mitigation tasks MUST be flagged as higher priority and dedicated verification tasks MUST be emitted referencing each HAZ-NNN.
- **FR-015**: The command MUST produce a `tasks.md` that unmodified `speckit.implement` can consume without errors.

#### `v-model.implement` (CORE — P0 bridge command)

- **FR-016**: The command MUST read all V-Model artifacts directly without requiring `plan.md` or `tasks.md` (self-sufficient direct path).
- **FR-017**: The command MUST refuse to start when Matrix A, B, C, D, or H is incomplete, exiting non-zero with a clear gap report.
- **FR-018**: The command MUST reuse existing deterministic scripts (`build-matrix`, `validate-requirement-coverage`, `validate-system-coverage`, `validate-architecture-coverage`, `validate-integration-coverage`, `validate-module-coverage`) as the pre-implementation gate; no new wrapper script may be introduced.
- **FR-019**: The command MUST generate source code following the Target Source File mappings declared in `module-design.md`.
- **FR-020**: Every generated function, class, or module MUST carry a comment linking it to the V-Model ID it implements (e.g., `// Implements MOD-003 (traces to REQ-005)`).
- **FR-021**: The command MUST generate tests at four levels — unit, integration, system, acceptance — matching the corresponding test plans (UTP/UTS, ITP/ITS, STP/STS, ATP/SCN).
- **FR-022**: Generated commits MUST include the implementing V-Model IDs in their message (e.g., `feat(vital-signs): implement alarm threshold — MOD-003, REQ-005`).
- **FR-023**: The command MUST NOT overwrite hand-written code that lies outside the declared Target Source File regions; existing user customisations within edit zones MUST be preserved between V-Model-managed regions.
- **FR-024**: The command MUST self-verify that every `// Implements <ID>` comment references an ID that exists in the V-Model artifacts; hallucinated IDs MUST cause a non-zero exit before any commit.
- **FR-025**: The command MUST support all configured domain overlays (e.g., DO-178C MC/DC coverage targets, ISO 26262 ASIL-driven test depth) by honouring overlay-specific output requirements.
- **FR-026**: The command MUST be idempotent — re-running it on identical inputs MUST produce equivalent output (modulo controlled LLM non-determinism).

#### Cross-cutting (all three commands)

- **FR-027**: All three bridge commands MUST be invocable from the spec-kit CLI as `/speckit.v-model.plan`, `/speckit.v-model.tasks`, and `/speckit.v-model.implement`.
- **FR-028**: All three bridge commands MUST register the appropriate `extension.yml` hooks: `after_specify` → `v-model.requirements`, `before_implement` → `v-model.trace`, `after_implement` → `v-model.trace`.
- **FR-029**: All three bridge commands MUST produce a structured summary on stdout indicating what was read, what was produced, and any warnings or skipped sections.
- **FR-030**: All three bridge commands MUST honour the project's configured domain overlay (read from `v-model-config.yml`).
- **FR-031**: Bridge command outputs MUST round-trip cleanly with their spec-kit core counterparts: a `plan.md` produced by `v-model.plan` MUST be valid input to `speckit.tasks`; a `tasks.md` produced by `v-model.tasks` MUST be valid input to `speckit.implement`.
- **FR-032**: When V-Model enrichment is absent in upstream artifacts (e.g., `plan.md` was produced by `speckit.plan`, not `v-model.plan`), bridge commands MUST proceed with reduced enrichment rather than failing.

### Key Entities

- **V-Model artifact set**: The collection of Markdown files in a feature's `v-model/` subdirectory: `requirements.md`, `acceptance-plan.md`, `system-design.md`, `system-test.md`, `architecture-design.md`, `integration-test.md`, `module-design.md`, `unit-test.md`, `hazard-analysis.md` (optional), `traceability-matrix.md`. The primary input to all three bridge commands.
- **Spec-kit canonical artifact set**: `plan.md`, `data-model.md`, `contracts/`, `research.md`, `quickstart.md`, `tasks.md`. The output of `v-model.plan` and `v-model.tasks`. Schema is defined by spec-kit core's templates and consumed by `speckit.tasks` and `speckit.implement`.
- **Traceability matrix**: A table-of-tables structure with five sub-matrices (A: REQ→SCN; B: REQ→SYS→STS; C: ARCH→ITS; D: MOD→UTS; H: HAZ→Mitigation) that the `v-model.implement` pre-implementation gate validates.
- **Target Source File mapping**: A field in each MOD-NNN entry within `module-design.md` declaring which source file(s) the module implements. Drives where `v-model.implement` writes code.
- **Bridge command summary**: A structured stdout report emitted by every bridge command describing inputs read, outputs produced, optional artifacts skipped, and any warnings.
- **V-Model enrichment**: Additive metadata layered onto spec-kit canonical artifacts — HTML comments containing trace links, optional Markdown sections (e.g., "## V-Model Traceability"), or extra columns in tables. Designed so that spec-kit core tools harmlessly ignore it.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A team can take any feature with a complete V-Model artifact set and produce a working, traceability-annotated implementation by running a single command (`v-model.implement`) without manually writing any task breakdown or plan.
- **SC-002**: 100% of generated code carries a comment linking it to a V-Model ID that exists in the artifact set (zero hallucinated IDs in generated output, verified by structural eval).
- **SC-003**: A `plan.md` produced by `v-model.plan` is consumed without error by unmodified `speckit.tasks` in 100% of test cases.
- **SC-004**: A `tasks.md` produced by `v-model.tasks` is consumed without error by unmodified `speckit.implement` in 100% of test cases.
- **SC-005**: When run on a feature with a known-incomplete traceability matrix, `v-model.implement` refuses to proceed in 100% of cases and produces a gap report identifying every missing matrix.
- **SC-006**: When run on a feature missing optional V-Model artifacts, all three bridge commands complete successfully with a clear summary of what was skipped.
- **SC-007**: Re-running any bridge command on identical inputs produces an output that differs only in non-substantive ways (LLM phrasing variability), as measured by structural eval comparison (>95% structural identity).
- **SC-008**: All three bridge commands have full BATS, Pester, structural, and LLM eval test coverage; CI runs green on the resulting branch before merge.
- **SC-009**: Documentation includes a "three user paths" guide covering Full Ceremony, Direct Path, and Hybrid scenarios with worked examples.
- **SC-010**: The bridge commands themselves are dogfood-developed: their own V-Model artifacts (specs/007-bridge-commands/v-model/) are produced and validated before any bridge-command code is written.

## Assumptions

- The team has already completed the V-cycle for the feature being implemented; bridge commands are the **last** step before code, not a substitute for the design phase.
- Spec-kit core's canonical schemas (`plan-template.md`, `tasks-template.md`) remain stable across the v0.7.0 timeframe; bridge commands target the schema present at the time of v0.7.0 release.
- The project's existing deterministic scripts (`build-matrix`, `validate-*-coverage`) are sufficient to enforce the pre-implementation gate without further enhancement; if a gap is discovered during the V-cycle, it will be flagged as a separate feature, not absorbed into 007.
- Code generation is performed by the same LLM tier already used by other generative V-Model commands (no separate model tier is introduced for `v-model.implement` in v0.7.0; model tiering is deferred to M3).
- Bridge commands operate within the existing extension hook system; no changes to the hook infrastructure itself are in scope for this feature (changes to the registered hooks themselves are in scope).
- The "additive enrichment" pattern (HTML comments + optional sections) is sufficient to avoid breaking spec-kit core consumers; this assumption will be empirically validated by tests.
- This feature does not introduce a new orchestrator agent or supervisor architecture; that work is deferred to M2.
- The dogfood for this feature uses the bridge commands' own V-Model artifacts as the implementation source, but the FIRST production of bridge-command code happens before `v-model.implement` itself exists — implementation is performed by the human developer (with AI assistance) following the spec, and only subsequent re-implementations or refinements can leverage `v-model.implement` itself.

## Out of Scope

- Workflow YAML for single-command V-cycle orchestration (deferred to M2).
- Orchestrator/supervisor agent architecture (deferred to M2).
- Adversarial consensus or debate transcripts between design-test pairs (deferred to M2).
- Standalone CI/CD-callable pre-implementation gate script (the gate exists inside `v-model.implement`; a standalone script wrapper is deferred to M3).
- Model tiering for code generation (deferred to M3).
- Padded-room execution isolation for the implement agent (deferred to M3).
- Correlation log for agent decisions (deferred to M3).
- Changes to spec-kit core itself; bridge commands MUST work against unmodified upstream spec-kit.
