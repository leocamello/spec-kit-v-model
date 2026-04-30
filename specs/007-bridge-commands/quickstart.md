# Quickstart: Bridge Commands

<!-- v-model-enrichment: feature=007-bridge-commands -->
<!-- source: spec.md SC-009, acceptance-plan.md critical-path scenarios, spec.md user stories US-001..US-004 -->

**Feature**: `007-bridge-commands` | **Branch**: `feature/007-bridge-commands`

Bridge Commands connect V-Model design artifacts to spec-kit core's canonical
output schemas through three composable commands. Choose the path that fits
your workflow; all three paths converge on the same well-traced, schema-valid
outputs.

---

## The Three User Paths

### Path 1 — Full Ceremony (US-001 + US-002 + US-003)

Use this path when you are starting a new feature with a complete V-Model
artifact set and want maximum traceability throughout every phase.

```
v-model artifacts → v-model.plan → v-model.tasks → v-model.implement
```

**When to choose it**: New feature, complete V-cycle, full audit-trail required.

#### Step 1 — Plan synthesis

```bash
/speckit.v-model.plan
```

Reads all V-Model artifacts from `specs/<feature>/v-model/` and the project
constitution. Produces:

| Output file | Source V-Model artifact |
|-------------|------------------------|
| `specs/<feature>/plan.md` | `requirements.md` + `system-design.md` |
| `specs/<feature>/data-model.md` | `system-design.md` §Data Design View |
| `specs/<feature>/contracts/<arch>.md` | `architecture-design.md` §Interface View |
| `specs/<feature>/quickstart.md` | `acceptance-plan.md` top critical scenarios |
| `specs/<feature>/research.md` | derivation flags from all artifacts |

Every output section carries a `<!-- traces-to: ... -->` HTML comment that
is invisible to unmodified spec-kit core tools.

**Validated by**: SCN-001-A1 (all inputs read), SCN-002-A1 (plan schema round-trip)

#### Step 2 — Task synthesis

```bash
/speckit.v-model.tasks
```

Reads `plan.md` (plus V-Model artifacts) and produces `tasks.md` with:
- Tasks ordered by TDD discipline: write unit tests → implement → run unit tests → write integration tests → …
- `[P]` markers on architecturally independent modules
- Hazard-driven priority elevation and dedicated verification tasks per `HAZ-NNN`

**Validated by**: SCN-011-A1 (TDD order), SCN-013-A1 (parallel markers), SCN-014-A1 (hazard priority)

#### Step 3 — Implementation

```bash
/speckit.v-model.implement
```

Runs the pre-implementation gate (Matrix A / B / C / D / H — 100% required),
generates source code at the paths declared by MOD-NNN Target Source File
fields, verifies zero hallucinated IDs, and annotates the Git commit.

**Validated by**: SCN-015-A1 (source files emitted), SCN-016-A1 (gate refusal on gap), SCN-018-A1 (target-path mapping)

---

### Path 2 — Direct Path (US-003)

Use this path when you have V-Model artifacts but want to skip the
intermediate `plan.md` / `tasks.md` ceremony and go straight to code.

```
v-model artifacts → v-model.implement
```

**When to choose it**: Experienced team, complete V-cycle, CI-only pipeline,
no intermediate review steps needed.

```bash
/speckit.v-model.implement
```

`v-model.implement` detects that `plan.md` / `tasks.md` are absent, reads
V-Model artifacts directly, runs the gate, and generates code. The structured
stdout summary reports the reduced-enrichment fallback was active.

> **Note**: The gate still requires a complete traceability matrix (Matrices
> A, B, C, D, H all 100%) before any file is written.

**Validated by**: SCN-015-A1 (direct path without plan/tasks)

---

### Path 3 — Hybrid (US-001 + US-003 or US-002 + US-003)

Use this path when you want to mix spec-kit core commands and V-Model bridge
commands at different layers. Any combination is supported.

```
v-model.plan → speckit.tasks → v-model.implement     (example A)
speckit.plan → v-model.tasks → v-model.implement     (example B)
```

**When to choose it**: Migrating an existing spec-kit project to V-Model
tracing incrementally, or when some layers have full V-cycle coverage and
others do not.

#### Example A — V-Model plan → core tasks → V-Model implement

```bash
/speckit.v-model.plan      # produces enriched plan.md with traces-to comments
/speckit.tasks             # unmodified core command; ignores HTML comments
/speckit.v-model.implement # reads V-Model artifacts directly for gate + codegen
```

**Validated by**: SCN-007-A1 (HTML comments ignored by core), SCN-009-B1 (reduced enrichment warning)

#### Example B — Core plan → V-Model tasks → V-Model implement

```bash
/speckit.plan              # unmodified core command; produces plain plan.md
/speckit.v-model.tasks     # detects no enrichment, warns, populates from V-Model artifacts
/speckit.v-model.implement # full gate + codegen
```

The `v-model.tasks` reduced-enrichment fallback (ARCH-014) detects the
absence of `<!-- v-model-enrichment -->` markers in `plan.md`, notes the
warning in the structured summary, and populates trace metadata from V-Model
artifacts directly.

**Validated by**: SCN-009-B1 (pure spec-kit plan consumed), SCN-007-B1 (structural identity of tasks output)

---

## Top Critical Acceptance Scenarios

These five scenarios cover the highest-priority correctness properties. They
form the acceptance smoke-test for every run of `v-model.plan`,
`v-model.tasks`, and `v-model.implement`.

### SCN-001-A1 — Full artifact read on complete input set

**Demonstrates**: REQ-001 (read all V-Model artifacts)

```
Given  a feature directory with all 10 V-Model artifacts + project constitution
When   /speckit.v-model.plan runs
Then   structured stdout lists all 11 paths under inputs_read
       exit code = 0
```

### SCN-002-A1 — Plan schema round-trip through speckit.tasks

**Demonstrates**: REQ-002 (spec-kit-conformant plan.md), REQ-007 (additive enrichment ignored)

```
Given  a complete V-Model fixture
When   /speckit.v-model.plan runs, then unmodified /speckit.tasks runs on the output
Then   /speckit.tasks exits 0 and produces a non-empty tasks.md
```

### SCN-015-A1 — Direct path: implement without plan.md or tasks.md

**Demonstrates**: REQ-015 (self-sufficient direct path)

```
Given  a feature directory with complete V-Model artifacts + complete traceability matrix
       AND no plan.md AND no tasks.md
When   /speckit.v-model.implement runs
Then   exit code = 0
       at least one source file exists at a MOD-NNN Target Source File path
```

### SCN-016-A1 — Gate refuses on Matrix A gap

**Demonstrates**: REQ-016 (non-zero exit + gap report on incomplete matrix)

```
Given  a fixture whose Matrix A has one row with an empty SCN field
When   /speckit.v-model.implement runs
Then   exit code ≠ 0
       stdout gap report names "Matrix A" and the affected REQ ID
       zero source files are created
```

### SCN-012-A1 — Every task carries a trace-to comment

**Demonstrates**: REQ-012 (traceability metadata in tasks.md)

```
Given  a tasks.md produced by v-model.tasks for a fixture with N tasks
When   the structural-eval traceability check runs
Then   exactly N traces-to comments are found
       each comment contains ≥1 ID present in the upstream V-Model artifacts
```

---

## Prerequisites

- spec-kit CLI installed and configured
- A feature directory at `specs/<feature>/` with at minimum `requirements.md`
  under `specs/<feature>/v-model/` (all other V-Model artifacts are optional
  for `v-model.plan` and `v-model.tasks`; `v-model.implement` additionally
  requires `module-design.md` and a complete traceability matrix)
- Project constitution at `.specify/memory/constitution.md`
- Git repository initialised

## Where to Go Next

- **Understand the data entities**: `specs/007-bridge-commands/data-model.md`
- **Inspect interface contracts**: `specs/007-bridge-commands/contracts/`
- **Review design decisions**: `specs/007-bridge-commands/research.md`
- **Review the implementation roadmap**: `specs/007-bridge-commands/plan.md`
- **Trace from requirements to tests**: `specs/007-bridge-commands/v-model/trace-matrix.md`
