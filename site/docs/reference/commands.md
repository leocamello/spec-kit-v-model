---
title: Command Reference
description: Complete reference for all 17 V-Model Extension Pack commands — syntax, parameters, inputs, outputs, and related scripts.
---

# Command Reference

The V-Model Extension Pack provides **17 commands** organized into five categories:

| Category | Commands |
|----------|----------|
| **Specification** | `requirements`, `system-design`, `architecture-design`, `module-design` |
| **Test Planning** | `acceptance`, `system-test`, `integration-test`, `unit-test` |
| **Cross-Cutting** | `hazard-analysis`, `impact-analysis`, `peer-review` |
| **Verification** | `trace`, `test-results`, `audit-report` |
| **Bridge to Implementation** | `plan`, `tasks`, `implement` |

!!! tip "Recommended Execution Order"
    Follow the [Proactive Workflow](../guide/concepts.md) for the intended order:
    requirements → acceptance → trace → system-design → system-test → hazard-analysis → trace → architecture-design → integration-test → trace → module-design → unit-test → trace → **plan → tasks → implement** (bridge sequence; see [Bridge Commands](../guide/bridge-commands.md)).

---

## Specification Commands

### `/speckit.v-model.requirements`

Generate a traceable requirements specification from user input or an existing `spec.md`.

| Attribute | Value |
|-----------|-------|
| **Purpose** | Translate natural language or spec.md into structured `REQ-NNN` requirements |
| **Input** | User prompt text **or** existing `spec.md` in the feature directory |
| **Output** | `specs/{feature}/v-model/requirements.md` |
| **ID Schema** | `REQ-NNN`, `REQ-NF-NNN`, `REQ-IF-NNN`, `REQ-CN-NNN` |
| **Validator** | — (this is the root artifact) |
| **Template** | `requirements-template.md` |

**Syntax:**

```bash
/speckit.v-model.requirements [optional natural language description]
```

**Category prefixes** for requirement types:

| Prefix | Category | Example |
|--------|----------|---------|
| *(none)* | Functional | `REQ-001` |
| `NF` | Non-Functional | `REQ-NF-001` |
| `IF` | Interface | `REQ-IF-001` |
| `CN` | Constraint | `REQ-CN-001` |

**Example:**

```bash
/speckit.v-model.requirements Build a vital signs monitor that triggers alarms within 2 seconds
```

!!! info "See Also"
    - [ID Schema — Level 1](id-schema.md#level-1-requirements-acceptance-testing)
    - [Templates — requirements-template.md](templates.md#requirements-templatemd)

---

### `/speckit.v-model.system-design`

Generate an IEEE 1016-compliant system design decomposition.

| Attribute | Value |
|-----------|-------|
| **Purpose** | Decompose requirements into system components across IEEE 1016 views |
| **Input** | `requirements.md` must exist in the v-model directory |
| **Output** | `specs/{feature}/v-model/system-design.md` |
| **ID Schema** | `SYS-NNN` (+ optional `SYS-DR-NNN` derived requirements) |
| **Validator** | `validate-system-coverage.sh` / `.ps1` (partial — forward only until system-test exists) |
| **Template** | `system-design-template.md` |

**Syntax:**

```bash
/speckit.v-model.system-design
```

**IEEE 1016 Design Views generated:**

- **Decomposition View** — component hierarchy with `Parent Requirements` traceability
- **Dependency View** — inter-component relationships
- **Interface View** — API contracts and data schemas
- **Data Design View** — storage, state, and data flow

!!! note "Inter-Level Linking"
    The `Parent Requirements` column in the Decomposition View table records the many-to-many mapping from `SYS-NNN` → `REQ-NNN`. This is an inter-level link — `SYS` numbering is independent of `REQ` numbering.

**Example:**

```bash
/speckit.v-model.system-design
```

!!! info "See Also"
    - [ID Schema — Level 2](id-schema.md#level-2-system-design-system-testing)
    - [Configuration — Domain extras](configuration.md#domain)

---

### `/speckit.v-model.architecture-design`

Generate an IEEE 42010 / Kruchten 4+1 architecture decomposition.

| Attribute | Value |
|-----------|-------|
| **Purpose** | Decompose system components into architecture modules across 4+1 views |
| **Input** | `system-design.md` must exist in the v-model directory |
| **Output** | `specs/{feature}/v-model/architecture-design.md` |
| **ID Schema** | `ARCH-NNN` |
| **Validator** | `validate-architecture-coverage.sh` / `.ps1` (partial — forward only until integration-test exists) |
| **Template** | `architecture-design-template.md` |

**Syntax:**

```bash
/speckit.v-model.architecture-design
```

**IEEE 42010 / Kruchten 4+1 Views generated:**

- **Logical View** — module decomposition with `Parent System Components` traceability
- **Process View** — concurrency, threads, event loops
- **Interface View** — module APIs, event schemas, contracts
- **Data Flow View** — data pipelines and transformations

**Special tags:**

| Tag | Meaning |
|-----|---------|
| `[CROSS-CUTTING]` | Infrastructure module (logging, auth, config) — spans all system components |

!!! info "See Also"
    - [ID Schema — Level 3](id-schema.md#level-3-architecture-design-integration-testing)
    - [Configuration — Domain extras](configuration.md#domain)

---

### `/speckit.v-model.module-design`

Generate detailed module designs with pseudocode, state machines, and data structures.

| Attribute | Value |
|-----------|-------|
| **Purpose** | Specify each module at implementation-ready detail |
| **Input** | `architecture-design.md` must exist in the v-model directory |
| **Output** | `specs/{feature}/v-model/module-design.md` |
| **ID Schema** | `MOD-NNN` |
| **Validator** | `validate-module-coverage.sh` / `.ps1` (partial — forward only until unit-test exists) |
| **Template** | `module-design-template.md` |

**Syntax:**

```bash
/speckit.v-model.module-design
```

**Four mandatory views per module:**

1. **Algorithmic / Logic View** — pseudocode defining the exact logic
2. **State Machine View** — state transitions (or `N/A — Stateless`)
3. **Internal Data Structures** — memory layout, constants, enums
4. **Error Handling & Return Codes** — every error condition and upstream contract

**Special tags:**

| Tag | Meaning | Validation Impact |
|-----|---------|-------------------|
| `[EXTERNAL]` | Third-party library/SDK | Excluded from pseudocode requirements; tested at boundaries only |
| `[CROSS-CUTTING]` | Infrastructure module | Inherited from parent ARCH; validated across dependents |
| `[DERIVED MODULE]` | Not from an ARCH element | Must still have full unit test coverage |

!!! info "See Also"
    - [ID Schema — Level 4](id-schema.md#level-4-module-design-unit-testing)
    - [Configuration — Domain extras](configuration.md#domain)

---

## Test Planning Commands

### `/speckit.v-model.acceptance`

Generate a three-tier Acceptance Test Plan with deterministic 100% coverage validation.

| Attribute | Value |
|-----------|-------|
| **Purpose** | Create test cases (ATP) and BDD scenarios (SCN) for every requirement |
| **Input** | `requirements.md` must exist in the v-model directory |
| **Output** | `specs/{feature}/v-model/acceptance-plan.md` |
| **ID Schema** | `ATP-NNN-X` (test cases), `SCN-NNN-X#` (scenarios) |
| **Validator** | `validate-requirement-coverage.sh` / `.ps1` |
| **Template** | `acceptance-plan-template.md` |

**Syntax:**

```bash
/speckit.v-model.acceptance
```

**Coverage validation** is automatic — the deterministic script verifies:

- **Forward**: Every `REQ` → at least one `ATP` → at least one `SCN`
- **Backward**: Every `ATP` traces to an existing `REQ`; every `SCN` traces to an existing `ATP`

**ID derivation example:**

```
REQ-003 → ATP-003-A, ATP-003-B, ATP-003-C
           ATP-003-A → SCN-003-A1, SCN-003-A2
```

!!! info "See Also"
    - [ID Schema — Level 1](id-schema.md#level-1-requirements-acceptance-testing)
    - [Scripts — validate-requirement-coverage](scripts.md#validate-requirement-coverageshps1)

---

### `/speckit.v-model.system-test`

Generate ISO 29119-4 compliant system test plans.

| Attribute | Value |
|-----------|-------|
| **Purpose** | Create test procedures (STP) and test steps (STS) for every system component |
| **Input** | `system-design.md` must exist in the v-model directory |
| **Output** | `specs/{feature}/v-model/system-test.md` |
| **ID Schema** | `STP-NNN-X` (test procedures), `STS-NNN-X#` (test steps) |
| **Validator** | `validate-system-coverage.sh` / `.ps1` |
| **Template** | `system-test-template.md` |

**Syntax:**

```bash
/speckit.v-model.system-test
```

**ISO 29119-4 techniques applied:**

- Boundary Value Analysis
- Fault Injection
- Interface Contract Testing
- Load / Stress Testing

!!! info "See Also"
    - [ID Schema — Level 2](id-schema.md#level-2-system-design-system-testing)
    - [Scripts — validate-system-coverage](scripts.md#validate-system-coverageshps1)
    - [Configuration — Domain extras](configuration.md#domain)

---

### `/speckit.v-model.integration-test`

Generate ISO 29119-4 integration test plans.

| Attribute | Value |
|-----------|-------|
| **Purpose** | Create test procedures (ITP) and test steps (ITS) for module interactions |
| **Input** | `architecture-design.md` must exist in the v-model directory |
| **Output** | `specs/{feature}/v-model/integration-test.md` |
| **ID Schema** | `ITP-NNN-X` (test procedures), `ITS-NNN-X#` (test steps) |
| **Validator** | `validate-architecture-coverage.sh` / `.ps1` |
| **Template** | `integration-test-template.md` |

**Syntax:**

```bash
/speckit.v-model.integration-test
```

**Four integration techniques:**

| Technique | Purpose |
|-----------|---------|
| Interface Contract Testing | Validate event schemas and API contracts |
| Data Flow Testing | End-to-end pipeline verification |
| Interface Fault Injection | Adapter failure handling |
| Concurrency & Race Condition Testing | Thread safety |

!!! info "See Also"
    - [ID Schema — Level 3](id-schema.md#level-3-architecture-design-integration-testing)
    - [Scripts — validate-architecture-coverage](scripts.md#validate-architecture-coverageshps1)
    - [Configuration — Domain extras](configuration.md#domain)

---

### `/speckit.v-model.unit-test`

Generate white-box unit test plans with strict isolation.

| Attribute | Value |
|-----------|-------|
| **Purpose** | Create test procedures (UTP) and scenarios (UTS) for every module |
| **Input** | `module-design.md` must exist in the v-model directory |
| **Output** | `specs/{feature}/v-model/unit-test.md` |
| **ID Schema** | `UTP-NNN-X` (test procedures), `UTS-NNN-X#` (scenarios) |
| **Validator** | `validate-module-coverage.sh` / `.ps1` |
| **Template** | `unit-test-template.md` |

**Syntax:**

```bash
/speckit.v-model.unit-test
```

**White-box techniques:**

| Technique | Purpose |
|-----------|---------|
| Statement & Branch Coverage | Exercise every line and branch decision |
| Boundary Value Analysis | Test at exact min/max/boundary values |
| Equivalence Partitioning | Test one representative from each input class |
| State Transition Testing | Exercise state machine transitions and guards |
| MC/DC Coverage | Modified Condition/Decision Coverage (safety-critical) |
| Variable-Level Fault Injection | Force local variables into corrupted states |

**Strict isolation:** Every external dependency is listed in a **Dependency & Mock Registry** per test procedure.

!!! info "See Also"
    - [ID Schema — Level 4](id-schema.md#level-4-module-design-unit-testing)
    - [Scripts — validate-module-coverage](scripts.md#validate-module-coverageshps1)
    - [Configuration — Domain extras](configuration.md#domain)

---

## Cross-Cutting Commands

### `/speckit.v-model.hazard-analysis`

Generate an ISO 14971 / ISO 26262 Failure Mode and Effects Analysis (FMEA).

| Attribute | Value |
|-----------|-------|
| **Purpose** | Identify hazards, assess risk, and link mitigations to requirements/design |
| **Input** | `requirements.md` + `system-design.md` (+ optional `architecture-design.md`) |
| **Output** | `specs/{feature}/v-model/hazard-analysis.md` |
| **ID Schema** | `HAZ-NNN` |
| **Validator** | `validate-hazard-coverage.sh` / `.ps1` |
| **Template** | `hazard-analysis-template.md` |

**Syntax:**

```bash
/speckit.v-model.hazard-analysis
```

**Each HAZ entry includes:**

- Failure Mode and Operational State
- Effect, Severity, Likelihood, and Risk Level
- Mitigation (linked to `REQ-NNN` / `SYS-NNN` IDs)
- Residual Risk assessment

!!! tip "Progressive Deepening"
    Re-running after `architecture-design.md` exists appends ARCH-level failure modes to the existing analysis.

**Validation dimensions (Matrix H):**

1. **Forward**: Every `SYS-NNN` has at least one `HAZ-NNN`
2. **Backward**: Every `HAZ` mitigation references a valid `REQ`/`SYS`
3. **State consistency**: Every operational state in HAZ exists in system-design

!!! info "See Also"
    - [ID Schema — HAZ-NNN](id-schema.md#hazard-analysis-haz-nnn)
    - [Scripts — validate-hazard-coverage](scripts.md#validate-hazard-coverageshps1)

---

### `/speckit.v-model.impact-analysis`

Deterministic change impact analysis across the entire V-Model graph.

| Attribute | Value |
|-----------|-------|
| **Purpose** | Given a changed ID, identify all suspect artifacts across V-Model levels |
| **Input** | One or more changed IDs + all V-Model markdown artifacts |
| **Output** | `specs/{feature}/v-model/impact-report.md` (or JSON via `--json`) |
| **ID Schema** | References all ID types |
| **Script** | `impact-analysis.sh` / `.ps1` (100% deterministic, no AI) |

**Syntax:**

```bash
/speckit.v-model.impact-analysis [OPTIONS] <ID...> <vmodel-dir>
```

**Traversal modes:**

| Flag | Direction | Use Case |
|------|-----------|----------|
| `--downward` (default) | Requirements → Tests/Modules | "What breaks if I change this requirement?" |
| `--upward` | Modules/Tests → Requirements | "Which requirements are at risk?" |
| `--full` | Both directions | Complete blast radius |

**Additional options:**

| Option | Description |
|--------|-------------|
| `--json` | Output JSON to stdout instead of markdown |
| `--output <path>` | Custom output file path |

**Examples:**

```bash
# What downstream artifacts are affected by changing REQ-001?
/speckit.v-model.impact-analysis --downward REQ-001 specs/feature/v-model/

# What upstream requirements does MOD-004 trace to?
/speckit.v-model.impact-analysis --upward MOD-004 specs/feature/v-model/

# Full blast radius for a system design change
/speckit.v-model.impact-analysis --full SYS-001 specs/feature/v-model/
```

!!! warning "Deterministic — Not AI"
    Impact analysis uses deterministic graph traversal scripts. The dependency graph is built from explicit ID references and `Parent *` fields in all V-Model markdown files.

!!! info "See Also"
    - [Scripts — impact-analysis](scripts.md#impact-analysisshimpact-analysisps1)

---

### `/speckit.v-model.peer-review`

AI-powered stateless linter for any V-Model artifact.

| Attribute | Value |
|-----------|-------|
| **Purpose** | Evaluate an artifact against standards-based quality criteria |
| **Input** | Any V-Model artifact markdown file |
| **Output** | `specs/{feature}/v-model/peer-review-{artifact}.md` |
| **ID Schema** | `PRF-{ARTIFACT}-NNN` (transient — regenerated each run) |
| **CI Script** | `peer-review-check.sh` / `.ps1` |
| **Template** | `peer-review-template.md` |

**Syntax:**

```bash
/speckit.v-model.peer-review <artifact-file>
```

**Standards applied per artifact type:**

| Artifact | Standard | Abbreviation |
|----------|----------|--------------|
| `requirements.md` | INCOSE Guide for Writing Requirements | `REQ` |
| `acceptance-plan.md` | ISO 29119 | `ATP` |
| `system-design.md` | IEEE 1016 | `SYS` |
| `system-test.md` | ISO 29119 | `STP` |
| `architecture-design.md` | IEEE 42010 / Kruchten 4+1 | `ARCH` |
| `integration-test.md` | ISO 29119-4 | `ITP` |
| `module-design.md` | DO-178C / ISO 26262 | `MOD` |
| `unit-test.md` | ISO 29119-4 | `UTP` |
| `hazard-analysis.md` | ISO 14971 / ISO 26262 | `HAZ` |

**Severity classifications and CI exit codes:**

| Severity | Meaning | CI Exit Code |
|----------|---------|-------------|
| Critical | Correctness or safety issue | Exit 1 (blocks PR) |
| Major | Significant quality issue | Exit 1 (blocks PR) |
| Minor | Style or completeness issue | Exit 2 (warning) |
| Observation | Informational suggestion | Exit 0 (clean) |

!!! note "Advisory Only"
    `PRF` IDs are **transient** (regenerated each run) and do **not** participate in the traceability chain. They are excluded from matrices and coverage metrics.

**Examples:**

```bash
/speckit.v-model.peer-review requirements.md
/speckit.v-model.peer-review system-design.md
/speckit.v-model.peer-review hazard-analysis.md
```

!!! info "See Also"
    - [ID Schema — PRF](id-schema.md#peer-review-finding-prf-artifact-nnn)
    - [Scripts — peer-review-check](scripts.md#peer-review-checkshpeer-review-checkps1)

---

## Verification Commands

### `/speckit.v-model.trace`

Build a regulatory-grade traceability matrix using deterministic scripts.

| Attribute | Value |
|-----------|-------|
| **Purpose** | Build traceability matrices proving bidirectional coverage |
| **Input** | All V-Model artifacts that exist in the directory |
| **Output** | `specs/{feature}/v-model/traceability-matrix.md` |
| **ID Schema** | References all design and test ID types |
| **Script** | `build-matrix.sh` / `.ps1` (100% deterministic, no AI) |
| **Template** | `traceability-matrix-template.md` |

**Syntax:**

```bash
/speckit.v-model.trace
```

**Progressive matrix building:**

| After Running | Matrices Built |
|---------------|---------------|
| `acceptance` | Matrix A |
| `system-test` | Matrix A + B |
| `hazard-analysis` | + Matrix H |
| `integration-test` | Matrix A + B + C (+ H) |
| `unit-test` | Matrix A + B + C + D (+ H) |

**Matrix summary:**

| Matrix | Scope | Link Types |
|--------|-------|------------|
| **A** | REQ → ATP → SCN | Intra-level (ID-encoded) |
| **B** | REQ →(Parent)→ SYS → STP → STS | Inter-level + Intra-level |
| **C** | SYS →(Parent)→ ARCH → ITP → ITS | Inter-level + Intra-level |
| **D** | ARCH →(Parent)→ MOD → UTP → UTS | Inter-level + Intra-level |
| **H** | HAZ → Mitigation → Verification | Cross-cutting |

!!! warning "Deterministic — Not AI"
    The traceability matrix is built by `build-matrix.sh` / `build-matrix.ps1` using regex-based parsing. It produces identical results on every run.

!!! info "See Also"
    - [ID Schema — Cross-Level Traceability](id-schema.md#cross-level-traceability-the-four-matrices)
    - [Scripts — build-matrix](scripts.md#build-matrixshbuild-matrixps1)

---

### `/speckit.v-model.test-results`

Ingest JUnit XML test results (and optional Cobertura coverage) into the traceability matrix.

| Attribute | Value |
|-----------|-------|
| **Purpose** | Bridge "planned to test" → "proved it works" in the matrix |
| **Input** | JUnit XML file + existing `traceability-matrix.md` |
| **Output** | Updated `traceability-matrix.md` (in-place) |
| **Script** | `ingest-test-results.sh` / `.ps1` + `parse_test_results.py` (100% deterministic) |

**Syntax:**

```bash
/speckit.v-model.test-results --input <junit.xml> [OPTIONS]
```

**Options:**

| Option | Description |
|--------|-------------|
| `--input <path>` | Path to JUnit XML file **(required)** |
| `--coverage <path>` | Path to Cobertura XML coverage file |
| `--matrix <path>` | Path to `traceability-matrix.md` (default: auto-detect) |
| `--coverage-map <path>` | Path to `coverage-map.yml` override |
| `--commit-sha <sha>` | Explicit commit SHA (default: `git rev-parse --short=7 HEAD`) |
| `--json` | Output JSON to stdout |

**Status mapping:**

| Before | After | Meaning |
|--------|-------|---------|
| `⬜ Untested` | `✅ Passed` | Test passed |
| `⬜ Untested` | `❌ Failed` | Test failed |
| `⬜ Untested` | `⏭️ Skipped` | Test skipped |

Each updated row includes **Date** and **Commit SHA** for audit trail. Matrix D rows gain a **Coverage** column when `--coverage` is provided (e.g., `95.0% stmt / 88.0% branch`).

**Exit codes:**

| Code | Meaning |
|------|---------|
| 0 | All matched tests passed |
| 1 | At least one failure detected |
| 2 | No V-Model scenario IDs matched |

**Examples:**

```bash
# Basic: ingest test results
/speckit.v-model.test-results --input results.xml

# With coverage data
/speckit.v-model.test-results --input results.xml --coverage cobertura.xml

# JSON output for CI
/speckit.v-model.test-results --input results.xml --json
```

!!! info "See Also"
    - [Scripts — ingest-test-results](scripts.md#ingest-test-resultsshingest-test-resultsps1)
    - [Scripts — parse_test_results.py](scripts.md#parse_test_resultspy)

---

### `/speckit.v-model.audit-report`

Build a point-in-time release audit report — the single document for the auditor.

| Attribute | Value |
|-----------|-------|
| **Purpose** | Assemble all V-Model evidence into a compliance-gated release report |
| **Input** | Complete V-Model directory with all artifacts |
| **Output** | `specs/{feature}/v-model/release-audit-report.md` (or JSON via `--json`) |
| **Script** | `build-audit-report.sh` / `.ps1` (100% deterministic, no AI) |
| **Template** | `audit-report-template.md` |

**Syntax:**

```bash
/speckit.v-model.audit-report <vmodel-dir> [OPTIONS]
```

**Options:**

| Option | Description |
|--------|-------------|
| `--system-name <name>` | System name for executive summary |
| `--version <ver>` | Release version |
| `--git-tag <tag>` | Git release tag |
| `--regulatory-context <ctx>` | Applicable regulatory standards |
| `--output <path>` | Custom output file path |
| `--json` | Output JSON to stdout |

**Report contents:**

1. Executive Summary (system, version, git SHA, date)
2. Artifact Inventory (pinned to Git SHAs and timestamps)
3. Traceability Matrices with coverage analysis
4. Hazard Management Summary
5. Anomaly/Waiver cross-referencing
6. Compliance Status

**Compliance gating:**

| Status | Condition | Exit Code |
|--------|-----------|-----------|
| ✅ RELEASE READY | 0 anomalies | 0 |
| ⚠️ RELEASE CANDIDATE | All anomalies waived | 0 |
| ❌ NOT READY | Unwaived failures exist | 1 |

!!! note "Waiver Cross-Referencing"
    Anomalies without matching `WAV-NNN` entries in `waivers.md` block the release. Orphaned waivers are flagged but non-blocking. See [ID Schema — Waivers](id-schema.md#waiver-wav-nnn).

**Examples:**

```bash
# Basic audit report
/speckit.v-model.audit-report specs/feature/v-model/

# With metadata
/speckit.v-model.audit-report specs/feature/v-model/ \
  --system-name "CBGMS" --version "2.1.0" --git-tag v2.1.0

# JSON for CI gating
/speckit.v-model.audit-report specs/feature/v-model/ --json
```

!!! info "See Also"
    - [ID Schema — Waivers](id-schema.md#waiver-wav-nnn)
    - [Scripts — build-audit-report](scripts.md#build-audit-reportshbuild-audit-reportps1)
    - [Templates — audit-report-template.md](templates.md#audit-report-templatemd)

---

## Bridge to Implementation Commands

The bridge commands (introduced in v0.7.0) close the gap between V-Model artifacts and executable implementation. They wrap the corresponding `spec-kit-core` commands and add V-Model awareness, deterministic gates, and a hallucination guard. See the [Bridge Commands guide](../guide/bridge-commands.md) for the end-to-end workflow and the [Compliance & Hybrid Modes](../guide/bridge-commands.md#compliance-and-hybrid-modes) discussion.

### `/speckit.v-model.plan`

Synthesise a V-Model-enriched `plan.md` from the canonical artifacts produced by the specification and test-planning commands.

| Attribute | Value |
|-----------|-------|
| **Purpose** | Produce a canonical `plan.md` (5 H2 sections in fixed order: Summary, Technical Context, Constitution Check, Project Structure, Complexity Tracking) enriched with additive HTML-comment annotations from V-Model artifacts |
| **Input** | All V-Model artifacts in `specs/{feature}/v-model/` (requirements, designs, tests, hazard analysis) |
| **Output** | `specs/{feature}/plan.md` (schema-validated against pinned `plan-schema-v0.7.0.json`) |
| **Validator** | `validate-core-schema.sh --plan` (three-pass: existence → ordering → wedge rejection) |
| **Gate behaviour** | Pre-flight: read-only artifact ingest. Post-write: schema validation rejects out-of-order H2s and unknown sections via `diff -u`. |

**Syntax:**

```bash
/speckit.v-model.plan
```

**Inputs consumed:** every canonical V-Model artifact present under `specs/{feature}/v-model/` plus `v-model-config.yml` (for domain context).

**Outputs produced:** `specs/{feature}/plan.md` only; HTML-comment enrichment carries V-Model IDs (REQ/SYS/ARCH/MOD/HAZ) into the plan without altering the upstream `spec-kit-core` schema.

**Governing standards:** IEEE 29148:2018 (planning artifacts), the project's pinned `plan-schema-v0.7.0.json`.

### `/speckit.v-model.tasks`

Decompose the plan into TDD-ordered tasks with hazard-driven priority elevation and per-hazard verification tasks.

| Attribute | Value |
|-----------|-------|
| **Purpose** | Generate a `tasks.md` whose 12 H2 sections (preserved verbatim from `spec-kit-core`) are populated in TDD order: tests first, then implementation. Tasks tied to mitigations of `HAZ-NNN` items are elevated in priority and paired with explicit per-HAZ verification tasks. |
| **Input** | `specs/{feature}/plan.md`, all V-Model artifacts, `hazard-analysis.md` |
| **Output** | `specs/{feature}/tasks.md` |
| **Validator** | `validate-core-schema.sh --tasks` (12 H2s, fixed order, no wedges) |
| **Gate behaviour** | Each task includes an `Implements`-directive header listing the V-Model IDs it realises; downstream `implement` validates these directives. |

**Syntax:**

```bash
/speckit.v-model.tasks
```

**Inputs consumed:** `plan.md` plus `requirements.md`, `acceptance-plan.md`, `system-test.md`, `integration-test.md`, `unit-test.md`, and `hazard-analysis.md`.

**Outputs produced:** `specs/{feature}/tasks.md` with each task carrying an `Implements`-directive header (e.g. `` `Implements`-directive citing REQ/SYS/ARCH/MOD/HAZ IDs ``).

**Governing standards:** IEEE 1012:2016 (V&V planning), ISO 29119-4 (test design techniques), IEC 60812:2018 (FMEA-driven priority).

### `/speckit.v-model.implement`

Execute the deterministic, gated 12-step implementation pipeline.

| Attribute | Value |
|-----------|-------|
| **Purpose** | Run the full implement pipeline: setup → 8-stage gate → domain overlay → codegen → 4-level test gen → splice (sentinel-managed regions) → hallucination guard → quality harness → reduced-enrichment fallback → commit annotation → structured summary → handoffs |
| **Input** | `tasks.md`, full V-Model artifact set, existing `src/` and `tests/{unit,integration,system,acceptance}/` |
| **Output** | New / updated source under `src/`, paired tests under each of the four test trees, an annotated commit, a structured run summary |
| **Validator** | `run-v-model-gate.sh` (8 stages); `validate-implements-ids.sh --canonical … --scan … --changed-only` (hallucination guard) |
| **Gate behaviour** | Any non-zero validator exits the pipeline before codegen. The hallucination guard scans the actually-generated files and rejects directives that cite IDs absent from the canonical V-Model artifact set. The em-dash `—` (U+2014, literal) is the commit-subject ID separator. |

**Syntax:**

```bash
/speckit.v-model.implement
```

**Inputs consumed:** `tasks.md`, all V-Model artifacts, `v-model-config.yml`, the existing source tree, the existing test trees.

**Outputs produced:** new and modified files under `src/`, paired tests under each of the four test trees, sentinel-managed regions spliced into existing files (`<<<REGION id="X">>>` … `<<<END>>>`), an annotated commit on the active feature branch, and a structured stdout/stderr summary including a `diff -u` of every spliced file.

**Governing standards:** IEEE 1012:2016 (verification gates), IEEE 1016:2009 (design conformance), ISO 29119 (test execution), the project's `Implements`-directive contract enforced by `validate-implements-ids.sh`.

---

## Hooks

v0.7.0 ships **4 lifecycle hooks** that the bridge commands invoke automatically. They live under `commands/hooks/` and may be made mandatory in v0.8.0 via `compliance_mode: strict` (see [EPIC-1](../community/roadmap.md)). All four are currently `optional: true`.

| Hook | Triggered after | Purpose |
|------|-----------------|---------|
| `after_specify` | `/speckit.specify` | Wire the V-Model directory layout under the new feature folder. |
| `after_tasks` | `/speckit.v-model.tasks` | Re-run `validate-core-schema.sh --tasks` to confirm the H2 order survived edits. |
| `before_implement` | (before) `/speckit.v-model.implement` | Re-run the 8-stage `run-v-model-gate.sh` pipeline as a fail-fast check. |
| `after_implement` | `/speckit.v-model.implement` | Re-run `/speckit.v-model.trace` to update the traceability matrix with the newly produced source/test pairs. |
