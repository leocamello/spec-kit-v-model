---
title: Templates Reference
description: Complete reference for all 12 V-Model artifact templates — structure, sections, ID schemas, and associated commands.
---

# Templates Reference

The V-Model Extension Pack uses **12 templates** to generate consistent, standards-compliant artifacts. Each template defines the structure, metadata, and ID schema that the corresponding command produces.

Templates are located in the `templates/` directory of the extension.

## Template Inventory

| Template | Command | ID Schema | Standard |
|----------|---------|-----------|----------|
| `requirements-template.md` | `requirements` | `REQ[-CAT]-NNN` | INCOSE |
| `acceptance-plan-template.md` | `acceptance` | `ATP-NNN-X`, `SCN-NNN-X#` | ISO 29119 |
| `system-design-template.md` | `system-design` | `SYS-NNN` | IEEE 1016 |
| `system-test-template.md` | `system-test` | `STP-NNN-X`, `STS-NNN-X#` | ISO 29119-4 |
| `architecture-design-template.md` | `architecture-design` | `ARCH-NNN` | IEEE 42010 |
| `integration-test-template.md` | `integration-test` | `ITP-NNN-X`, `ITS-NNN-X#` | ISO 29119-4 |
| `module-design-template.md` | `module-design` | `MOD-NNN` | DO-178C / ISO 26262 |
| `unit-test-template.md` | `unit-test` | `UTP-NNN-X`, `UTS-NNN-X#` | ISO 29119-4 |
| `hazard-analysis-template.md` | `hazard-analysis` | `HAZ-NNN` | ISO 14971 / ISO 26262 |
| `peer-review-template.md` | `peer-review` | `PRF-{ARTIFACT}-NNN` | Per artifact |
| `traceability-matrix-template.md` | `trace` | All ID types | — |
| `audit-report-template.md` | `audit-report` | All ID types | — |

---

## Specification Templates

### `requirements-template.md`

Generates the top-level requirements specification.

| Attribute | Value |
|-----------|-------|
| **Command** | `/speckit.v-model.requirements` |
| **Output file** | `requirements.md` |
| **ID Schema** | `REQ-NNN`, `REQ-NF-NNN`, `REQ-IF-NNN`, `REQ-CN-NNN` |
| **Standard** | INCOSE Guide for Writing Requirements |

**Key sections:**

- **Metadata** — Feature branch, creation date, status, source
- **Overview** — Feature description and business context
- **Functional Requirements** — `REQ-NNN` entries
- **Non-Functional Requirements** — `REQ-NF-NNN` entries
- **Interface Requirements** — `REQ-IF-NNN` entries
- **Constraint Requirements** — `REQ-CN-NNN` entries

!!! info "See Also"
    [Command Reference — requirements](commands.md#speckitv-modelrequirements) · [ID Schema — REQ](id-schema.md#req-nnn-requirement)

---

### `system-design-template.md`

Generates the IEEE 1016-compliant system design decomposition.

| Attribute | Value |
|-----------|-------|
| **Command** | `/speckit.v-model.system-design` |
| **Output file** | `system-design.md` |
| **ID Schema** | `SYS-NNN` (+ `SYS-DR-NNN` for derived requirements) |
| **Standard** | IEEE 1016:2009 |

**Key sections:**

- **Metadata** — Feature branch, date, status, source (`requirements.md`)
- **Overview** — Architecture and decomposition rationale
- **ID Schema** — Component and parent requirements format
- **Decomposition View** — Component table with `Parent Requirements` column
- **Dependency View** — Inter-component relationships
- **Interface View** — API contracts and data schemas
- **Data Design View** — Storage, state, and data flow

!!! note "Traceability Field"
    The `Parent Requirements` column in the Decomposition View table is the authoritative inter-level link parsed by `build-matrix.sh` for Matrix B.

!!! info "See Also"
    [Command Reference — system-design](commands.md#speckitv-modelsystem-design) · [ID Schema — SYS](id-schema.md#sys-nnn-system-design-element)

---

### `architecture-design-template.md`

Generates the IEEE 42010 / Kruchten 4+1 architecture decomposition.

| Attribute | Value |
|-----------|-------|
| **Command** | `/speckit.v-model.architecture-design` |
| **Output file** | `architecture-design.md` |
| **ID Schema** | `ARCH-NNN` |
| **Standard** | IEEE 42010 / Kruchten 4+1 |

**Key sections:**

- **Metadata** — Feature branch, date, status, source (`system-design.md`)
- **Overview** — Architecture decomposition rationale
- **ID Schema** — Module and parent system components format
- **Logical View** — Module table with `Parent System Components` column
- **Process View** — Concurrency, threads, event loops
- **Interface View** — Module APIs, event schemas, contracts
- **Data Flow View** — Data pipelines and transformations

!!! note "Traceability Field"
    The `Parent System Components` column in the Logical View table is the authoritative inter-level link parsed by `build-matrix.sh` for Matrix C. `[CROSS-CUTTING]` modules use a tag instead of parent IDs.

!!! info "See Also"
    [Command Reference — architecture-design](commands.md#speckitv-modelarchitecture-design) · [ID Schema — ARCH](id-schema.md#arch-nnn-architecture-element)

---

### `module-design-template.md`

Generates detailed module designs at implementation-ready granularity.

| Attribute | Value |
|-----------|-------|
| **Command** | `/speckit.v-model.module-design` |
| **Output file** | `module-design.md` |
| **ID Schema** | `MOD-NNN` |
| **Standard** | DO-178C / ISO 26262 |

**Key sections:**

- **Metadata** — Feature branch, date, status, source (`architecture-design.md`)
- **Overview** — Module decomposition rationale
- **ID Schema** — Module and parent architecture modules format
- **Per-module blocks** (each containing):
    - Module heading with `Parent Architecture Modules` metadata
    - Target Source File(s)
    - Algorithmic / Logic View (pseudocode)
    - State Machine View
    - Internal Data Structures
    - Error Handling & Return Codes

**Special tags:** `[EXTERNAL]`, `[CROSS-CUTTING]`, `[DERIVED MODULE]`

!!! note "Traceability Field"
    The `**Parent Architecture Modules:**` metadata line below each module heading is the authoritative inter-level link parsed by `build-matrix.sh` for Matrix D.

!!! info "See Also"
    [Command Reference — module-design](commands.md#speckitv-modelmodule-design) · [ID Schema — MOD](id-schema.md#mod-nnn-module-design)

---

## Test Planning Templates

### `acceptance-plan-template.md`

Generates the three-tier Acceptance Test Plan.

| Attribute | Value |
|-----------|-------|
| **Command** | `/speckit.v-model.acceptance` |
| **Output file** | `acceptance-plan.md` |
| **ID Schema** | `ATP-NNN-X` (test cases), `SCN-NNN-X#` (BDD scenarios) |
| **Standard** | ISO 29119 |

**Key sections:**

- **Metadata** — Feature branch, date, status, source (`requirements.md`)
- **Overview** — Test plan scope and approach
- **ID Schema** — Test case and scenario format documentation
- **Per-requirement blocks** (each containing):
    - Requirement reference
    - Test Cases (`ATP-NNN-A`, `ATP-NNN-B`, ...)
    - BDD Scenarios (`SCN-NNN-A1`, `SCN-NNN-A2`, ...) in Given/When/Then format

!!! info "See Also"
    [Command Reference — acceptance](commands.md#speckitv-modelacceptance) · [ID Schema — ATP / SCN](id-schema.md#atp-nnn-x-acceptance-test-procedure)

---

### `system-test-template.md`

Generates ISO 29119-4 system test plans.

| Attribute | Value |
|-----------|-------|
| **Command** | `/speckit.v-model.system-test` |
| **Output file** | `system-test.md` |
| **ID Schema** | `STP-NNN-X` (test procedures), `STS-NNN-X#` (test steps) |
| **Standard** | ISO 29119-4 |

**Key sections:**

- **Metadata** — Feature branch, date, status, source (`system-design.md`)
- **Overview** — System test scope (architectural behavior, not user journeys)
- **Per-component blocks** (each containing):
    - System component reference
    - Test Procedures (`STP-NNN-A`, `STP-NNN-B`, ...) with technique identification
    - Test Steps (`STS-NNN-A1`, `STS-NNN-A2`, ...) in Given/When/Then format

!!! info "See Also"
    [Command Reference — system-test](commands.md#speckitv-modelsystem-test) · [ID Schema — STP / STS](id-schema.md#stp-nnn-x-system-test-procedure)

---

### `integration-test-template.md`

Generates ISO 29119-4 integration test plans.

| Attribute | Value |
|-----------|-------|
| **Command** | `/speckit.v-model.integration-test` |
| **Output file** | `integration-test.md` |
| **ID Schema** | `ITP-NNN-X` (test procedures), `ITS-NNN-X#` (test steps) |
| **Standard** | ISO 29119-4 |

**Key sections:**

- **Metadata** — Feature branch, date, status, source (`architecture-design.md`)
- **Overview** — Integration test scope (module seams and handshakes)
- **Per-module blocks** (each containing):
    - Architecture module reference
    - Test Procedures (`ITP-NNN-A`, ...) with technique (Interface Contract, Data Flow, Fault Injection, Concurrency)
    - Test Steps (`ITS-NNN-A1`, ...) in module-boundary BDD format

!!! info "See Also"
    [Command Reference — integration-test](commands.md#speckitv-modelintegration-test) · [ID Schema — ITP / ITS](id-schema.md#itp-nnn-x-integration-test-procedure)

---

### `unit-test-template.md`

Generates white-box unit test plans with strict isolation.

| Attribute | Value |
|-----------|-------|
| **Command** | `/speckit.v-model.unit-test` |
| **Output file** | `unit-test.md` |
| **ID Schema** | `UTP-NNN-X` (test procedures), `UTS-NNN-X#` (scenarios) |
| **Standard** | ISO 29119-4 |

**Key sections:**

- **Metadata** — Feature branch, date, status, source (`module-design.md`)
- **Overview** — Unit test scope (internal module logic, not boundaries)
- **Per-module blocks** (each containing):
    - Module reference
    - Test Procedures (`UTP-NNN-A`, ...) with technique identification
    - Dependency & Mock Registry (per procedure)
    - Unit Test Scenarios (`UTS-NNN-A1`, ...) in Arrange/Act/Assert format

!!! note "Arrange/Act/Assert"
    Unit tests use Arrange/Act/Assert (not Given/When/Then) because they are white-box tests exercising internal logic, not behavioral BDD tests.

!!! info "See Also"
    [Command Reference — unit-test](commands.md#speckitv-modelunit-test) · [ID Schema — UTP / UTS](id-schema.md#utp-nnn-x-unit-test-procedure)

---

## Cross-Cutting Templates

### `hazard-analysis-template.md`

Generates the FMEA hazard register.

| Attribute | Value |
|-----------|-------|
| **Command** | `/speckit.v-model.hazard-analysis` |
| **Output file** | `hazard-analysis.md` |
| **ID Schema** | `HAZ-NNN` |
| **Standard** | ISO 14971 (Medical) / ISO 26262 (Automotive) / General FMEA |

**Key sections:**

- **Metadata** — Feature branch, date, status, source (`system-design.md`), standard
- **Overview** — FMEA scope and methodology
- **FMEA Register** — Table with columns:
    - `HAZ-NNN` identifier
    - System Component (`SYS-NNN`)
    - Failure Mode and Operational State
    - Effect, Severity, Likelihood, Risk Level
    - Mitigation (linked to `REQ-NNN` / `SYS-NNN`)
    - Residual Risk

!!! info "See Also"
    [Command Reference — hazard-analysis](commands.md#speckitv-modelhazard-analysis) · [ID Schema — HAZ](id-schema.md#hazard-analysis-haz-nnn)

---

### `peer-review-template.md`

Generates the peer review findings report.

| Attribute | Value |
|-----------|-------|
| **Command** | `/speckit.v-model.peer-review` |
| **Output file** | `peer-review-{artifact}.md` |
| **ID Schema** | `PRF-{ARTIFACT}-NNN` |
| **Standard** | Per artifact type (INCOSE, IEEE 1016, ISO 29119, etc.) |

**Key sections:**

- **Metadata** — Reviewer (AI), date, artifact, item count, governing standard
- **Summary** — Severity count table (Critical, Major, Minor, Observation)
- **Findings** — Individual `PRF-{ARTIFACT}-NNN` entries with:
    - Severity classification
    - Description and location
    - Recommendation

!!! warning "Transient IDs"
    `PRF` IDs are regenerated from scratch on each run. They do not participate in the traceability chain.

!!! info "See Also"
    [Command Reference — peer-review](commands.md#speckitv-modelpeer-review) · [ID Schema — PRF](id-schema.md#peer-review-finding-prf-artifact-nnn)

---

## Verification Templates

### `traceability-matrix-template.md`

Generates the consolidated traceability matrix.

| Attribute | Value |
|-----------|-------|
| **Command** | `/speckit.v-model.trace` |
| **Output file** | `traceability-matrix.md` |
| **ID Schema** | References all design and test ID types |
| **Script** | `build-matrix.sh` / `build-matrix.ps1` |

**Key sections:**

- **Metadata** — Feature branch, generation date, source directory
- **Overview** — Matrix purpose and generation method
- **Matrix A** — Validation: `REQ` → `ATP` → `SCN` (User View)
- **Matrix B** — Verification: `SYS` → `STP` → `STS` (System View)
- **Matrix C** — Integration Verification: `ARCH` → `ITP` → `ITS`
- **Matrix D** — Module Verification: `MOD` → `UTP` → `UTS`
- **Matrix H** — Hazard Traceability: `HAZ` → Mitigation → Verification

!!! note "Progressive Building"
    Matrices are built progressively. Only matrices whose prerequisite artifacts exist are included.

!!! info "See Also"
    [Command Reference — trace](commands.md#speckitv-modeltrace) · [Scripts — build-matrix](scripts.md#build-matrixshbuild-matrixps1)

---

### `audit-report-template.md`

Generates the point-in-time release audit report.

| Attribute | Value |
|-----------|-------|
| **Command** | `/speckit.v-model.audit-report` |
| **Output file** | `release-audit-report.md` |
| **ID Schema** | References all ID types + `WAV-NNN` waivers |
| **Script** | `build-audit-report.sh` / `Build-Audit-Report.ps1` |

**Key sections:**

- **Executive Summary** — System name, version, Git tag/SHA, date, regulatory context
- **Counts** — Total requirements, test scenarios, pass/fail/skip, hazards, anomalies
- **Artifact Inventory** — All V-Model files with Git SHAs and timestamps
- **Traceability Matrices** — Embedded matrices with coverage analysis
- **Hazard Management Summary** — Mitigation status
- **Anomaly/Waiver Cross-Reference** — Failed/skipped tests matched against `WAV-NNN`
- **Compliance Status** — RELEASE READY / RELEASE CANDIDATE / NOT READY

**Template placeholders:**

| Placeholder | Replaced With |
|-------------|---------------|
| `[SYSTEM_NAME]` | `--system-name` option value |
| `[VERSION]` | `--version` option value |
| `[GIT_TAG]` | `--git-tag` option value |
| `[GIT_SHA]` | Current Git HEAD SHA |
| `[DATE]` | Report generation date |
| `[TOTAL_REQS]` | Count of requirements |
| `[TOTAL_TESTS]` | Count of test scenarios |
| `[ANOMALY_COUNT]` | Count of failed/skipped tests |
| `[WAIVED_COUNT]` | Count of waived anomalies |
| `[BLOCKING_COUNT]` | Count of unwaived anomalies |

!!! info "See Also"
    [Command Reference — audit-report](commands.md#speckitv-modelaudit-report) · [ID Schema — WAV](id-schema.md#waiver-wav-nnn)
