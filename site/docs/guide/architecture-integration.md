---
title: "Level 3: Architecture ↔ Integration Testing"
description: Define IEEE 42010 architecture modules with four views and validate module boundaries with ISO 29119-4 integration test techniques.
---

# Level 3: Architecture ↔ Integration Testing

The third V-Model layer pairs **Architecture Design** (left side) with **Integration Testing** (right side). While Level 2 validates *how the system is structured*, this level validates *how modules interact across boundaries* — interfaces, data flows, concurrency, and fault propagation between components.

---

## Standards Alignment

### IEEE 42010:2022 / Kruchten 4+1

Architecture modules are organized into four mandatory viewpoints:

| Architecture View | Description |
|---|---|
| **Logical View** | Module responsibilities, domain partitioning, and encapsulation boundaries |
| **Process View** | Concurrency, threading models, and inter-process communication |
| **Interface View** | Module-to-module API contracts, message schemas, and protocol bindings |
| **Data Flow View** | Data transformations, pipeline stages, and event propagation paths |

### ISO 29119-4 — Integration Test Techniques

Integration tests target module boundaries using four mandatory techniques:

| Architecture View | Primary Technique | What It Tests |
|---|---|---|
| Interface View | **Interface Contract Testing** | API contract compliance between consumer-provider module pairs |
| Data Flow View | **Data Flow Testing** | Data transformation chain correctness across module boundaries |
| Interface View | **Interface Fault Injection** | Failure at integration points — resilience and error propagation |
| Process View | **Concurrency & Race Condition Testing** | Thread safety, deadlocks, and ordering guarantees |

!!! warning "Critical Distinction"

    Integration tests do **not** test internal module logic (that's [unit testing](module-unit.md)) and do **not** test user journeys (that's [acceptance testing](requirements-acceptance.md)). They test the **interfaces between modules**.

---

## Commands

### `/speckit.v-model.architecture-design`

Decomposes system components into IEEE 42010/Kruchten 4+1-compliant architecture modules.

```bash
/speckit.v-model.architecture-design
```

**What it produces:**

- An `architecture-design.md` file in `specs/{feature}/v-model/`
- Every module gets a unique `ARCH-NNN` ID
- Each module maps to one or more parent `SYS-NNN` IDs (many-to-many)
- Four architecture views: Logical, Process, Interface, Data Flow
- Support for `[CROSS-CUTTING]` infrastructure modules (logging, auth, config)
- `[DERIVED MODULE]` flagging for modules not directly traceable to a `SYS` component
- Mermaid sequence diagrams in the Process View

### `/speckit.v-model.integration-test`

Generates ISO 29119-4-compliant integration test cases for every architecture module.

```bash
/speckit.v-model.integration-test
```

**What it produces:**

- An `integration-test.md` file in `specs/{feature}/v-model/`
- **Test Procedures** (`ITP-NNN-X`) — integration test conditions per `ARCH-NNN`
- **Test Steps** (`ITS-NNN-X#`) — executable integration test steps
- Each test case names its ISO 29119 technique explicitly

---

## ID Schema

| Tier | ID Format | Example | Meaning |
|---|---|---|---|
| Architecture Element | `ARCH-NNN` | `ARCH-001` | A discrete architecture module or component |
| Test Procedure | `ITP-NNN-X` | `ITP-001-A` | An integration test procedure for ARCH-001 |
| Test Step | `ITS-NNN-X#` | `ITS-001-A1` | An executable integration test step for ITP-001-A |

Reading `ITS-001-A1` tells you: this step validates test procedure `ITP-001-A`, which tests architecture element `ARCH-001`.

### CROSS-CUTTING Modules

Architecture modules tagged as `[CROSS-CUTTING]` (e.g., logging, authentication, configuration) are validated **across all dependent modules** rather than in isolation. They do not require a direct `SYS` parent — their integration tests verify that all consumers interact with the shared module correctly.

---

## Inter-Level Linking

Architecture modules link **upward** to system components via the `Parent System Components` metadata in the Logical View:

```markdown
### ARCH-005: HTTP Router

| Field | Value |
|---|---|
| **Parent System Components** | SYS-001, SYS-004 |
| **Type** | Component |
| **Tags** | — |
| **Description** | Routes incoming HTTP requests to handler modules |
```

This creates the cross-level chain: `SYS-NNN` → `ARCH-NNN` → `ITP-NNN-X` → `ITS-NNN-X#`.

---

## Validator

### `validate-architecture-coverage.sh`

Validates bi-directional coverage across the SYS → ARCH → ITP → ITS chain.

=== "Bash"

    ```bash
    scripts/bash/validate-architecture-coverage.sh specs/<feature>/v-model
    ```

=== "PowerShell"

    ```powershell
    scripts/powershell/validate-architecture-coverage.ps1 specs/<feature>/v-model
    ```

**Checks performed:**

| Check | Direction | What It Validates |
|---|---|---|
| Forward coverage | SYS → ARCH | Every system component maps to at least one architecture module |
| Backward coverage | ARCH → SYS | Every module traces to an existing component (or is `[CROSS-CUTTING]`) |
| Test coverage | ARCH → ITP → ITS | Every module has tests, every test has steps |
| No orphans | ITP → ARCH | No test procedures referencing non-existent modules |

**Exit codes:** `0` = full coverage, `1` = gaps found.

!!! tip "Partial mode"

    If `integration-test.md` doesn't exist yet, the validator runs forward-only checks (SYS → ARCH) and skips ARCH → ITP → ITS coverage.

---

## Matrix C: Integration Verification

Matrix C extends the traceability chain one level deeper:

- **Forward**: `SYS-NNN` → `ARCH-NNN` → `ITP-NNN-X` → `ITS-NNN-X#` (no gaps)
- **Backward**: Every integration test step → traces to an architecture element → traces to a system design element (no orphans)

Architecture modules tagged as `CROSS-CUTTING` are validated across all dependent modules rather than in isolation.

---

## Related Pages

- [Level 2: System Design ↔ System Testing](system-design-testing.md) — The level above
- [Level 4: Module Design ↔ Unit Testing](module-unit.md) — The next level down
- [Hazard Analysis](hazard-analysis.md) — Architecture-level hazards via progressive deepening
- [CI Integration](ci-integration.md) — Running validators in your pipeline
