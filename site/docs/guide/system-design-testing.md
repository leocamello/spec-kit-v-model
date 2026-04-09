---
title: "Level 2: System Design ↔ System Testing"
description: Decompose requirements into IEEE 1016-compliant system components and validate them with ISO 29119 system test techniques.
---

# Level 2: System Design ↔ System Testing

The second V-Model layer pairs **System Design** (left side) with **System Testing** (right side). While Level 1 validates *what* the system must do, this level validates *how* the system is structured to do it.

---

## When to Use This Level

Use Level 2 when you need to:

- Decompose requirements into **concrete system components** (subsystems, services, modules)
- Define **four IEEE 1016 design views** for each component
- Prove that every component is **tested with named ISO 29119 techniques**
- Establish **many-to-many traceability** between requirements and components

!!! note "Prerequisites"

    Level 2 requires `requirements.md` to exist. Run [`/speckit.v-model.requirements`](requirements-acceptance.md) first.

---

## Standards Alignment

### IEEE 1016:2009 — Software Design Description

The system design uses four mandatory viewpoints:

| Design View | Description |
|---|---|
| **Decomposition View** | System broken into components/modules with `SYS-NNN` IDs |
| **Dependency View** | Relationships and coupling between components |
| **Interface View** | External and internal interface contracts |
| **Data Design View** | Data models, schemas, and data flow |

### ISO 29119-4 — Test Techniques

System tests use named techniques mapped to design views:

| Design View | Primary Technique | What It Tests |
|---|---|---|
| Interface View | **Interface Contract Testing** | API contracts, protocol compliance, error responses |
| Data Design View | **Boundary Value Analysis** | Data limits, thresholds, ranges |
| Data Design View | **Equivalence Partitioning** | Representative data classes |
| Dependency View | **Fault Injection** | Failure propagation, graceful degradation |

---

## Commands

### `/speckit.v-model.system-design`

Decomposes requirements into IEEE 1016-compliant system components with four mandatory design views and many-to-many REQ↔SYS traceability.

```bash
/speckit.v-model.system-design
```

**What it produces:**

- A `system-design.md` file in `specs/{feature}/v-model/`
- Every component gets a unique `SYS-NNN` ID
- Each component maps to one or more parent `REQ-NNN` IDs (many-to-many)
- Four design views: Decomposition, Dependency, Interface, Data Design
- Component types: Subsystem | Module | Service | Library | Utility

### `/speckit.v-model.system-test`

Generates ISO 29119-compliant system test cases with named techniques for every system component.

```bash
/speckit.v-model.system-test
```

**What it produces:**

- A `system-test.md` file in `specs/{feature}/v-model/`
- **Test Procedures** (`STP-NNN-X`) — logical test conditions per `SYS-NNN`
- **Test Steps** (`STS-NNN-X#`) — executable step-by-step procedures
- Each test case names its ISO 29119 technique explicitly

---

## ID Schema

| Tier | ID Format | Example | Meaning |
|---|---|---|---|
| Design Element | `SYS-NNN` | `SYS-001` | A discrete system design element |
| Test Procedure | `STP-NNN-X` | `STP-001-A` | A test procedure for SYS-001 |
| Test Step | `STS-NNN-X#` | `STS-001-A1` | An executable test step for STP-001-A |

Reading `STS-001-A1` tells you: this step validates test procedure `STP-001-A`, which tests design element `SYS-001`. The same self-documenting lineage as the requirements level.

---

## Inter-Level Linking

System components link **upward** to requirements via the `Parent Requirements` metadata field in the Decomposition View:

```markdown
### SYS-003: Alert Engine

| Field | Value |
|---|---|
| **Parent Requirements** | REQ-001, REQ-005, REQ-NF-002 |
| **Type** | Service |
| **Description** | Evaluates sensor data against thresholds and triggers alerts |
```

This creates the inter-level trace: `REQ-NNN` → `SYS-NNN` → `STP-NNN-X` → `STS-NNN-X#`.

!!! info "Many-to-Many Relationships"

    - A single `SYS` may satisfy multiple `REQ`s
    - A single `REQ` may be satisfied by multiple `SYS` components
    - The validator checks both directions

---

## Validator

### `validate-system-coverage.sh`

Validates bi-directional coverage across the REQ → SYS → STP → STS chain.

=== "Bash"

    ```bash
    scripts/bash/validate-system-coverage.sh specs/<feature>/v-model
    ```

=== "PowerShell"

    ```powershell
    scripts/powershell/validate-system-coverage.ps1 specs/<feature>/v-model
    ```

**Checks performed:**

| Check | Direction | What It Validates |
|---|---|---|
| Forward coverage | REQ → SYS | Every requirement maps to at least one system component |
| Backward coverage | SYS → REQ | Every component traces to an existing requirement |
| Test coverage | SYS → STP → STS | Every component has tests, every test has steps |
| No orphans | STP → SYS | No test procedures referencing non-existent components |

**Exit codes:** `0` = full coverage, `1` = gaps found.

!!! tip "Partial mode"

    If `system-test.md` doesn't exist yet, the validator runs in partial mode — checking REQ → SYS forward coverage only and skipping SYS → STP → STS checks.

---

## Matrix B: System Verification

Matrix B extends the traceability chain one level deeper:

- **Forward**: `REQ-NNN` → `SYS-NNN` → `STP-NNN-X` → `STS-NNN-X#` (no gaps)
- **Backward**: Every system test step → traces to a component → traces to a requirement (no orphans)

Matrix B proves that the system architecture is complete (every requirement is decomposed) and verified (every component is tested).

---

## Related Pages

- [Level 1: Requirements ↔ Acceptance](requirements-acceptance.md) — The level above
- [Level 3: Architecture ↔ Integration](architecture-integration.md) — The next level down
- [Impact Analysis](impact-analysis.md) — Trace changes across levels
- [CI Integration](ci-integration.md) — Running validators in your pipeline
