---
title: "Level 4: Module Design ↔ Unit Testing"
description: Specify internal module logic with four mandatory views and verify it with ISO 29119-4 white-box unit test techniques — the innermost V-Model level.
---

# Level 4: Module Design ↔ Unit Testing

The fourth and innermost V-Model layer pairs **Module Design** (left side) with **Unit Testing** (right side). This is the bottom of the V — the most detailed level where individual functions, algorithms, and data structures are specified and tested in strict isolation.

---

## Standards Alignment

### Module Design — DO-178C / ISO 26262

Each module is documented with **four mandatory views**, detailed enough that writing the actual source code is merely a translation exercise:

| Module View | Description |
|---|---|
| **Algorithmic / Logic View** | Pseudocode with typed parameters, return types, and control flow |
| **State Machine View** | Stateful modules: all states and transitions in `stateDiagram-v2`. Stateless modules: "N/A — Stateless" bypass |
| **Internal Data Structures** | Typed structs, enums, constants, and constraints |
| **Error Handling & Return Codes** | Concrete error conditions, exceptions, and recovery actions |

### Unit Testing — ISO 29119-4 White-Box Techniques

Unit tests are **white-box** — they verify internal control flow, data transformations, state transitions, and variable boundaries inside each module:

| Module View | Technique | What It Tests |
|---|---|---|
| Algorithmic / Logic | **Statement & Branch Coverage** | All code paths in the logic view |
| Internal Data Structures | **Boundary Value Analysis** | Edge values for numeric or range-based inputs |
| Internal Data Structures | **Equivalence Partitioning** | Representative input equivalence classes |
| State Machine | **State Transition Testing** | Valid/invalid state transitions for stateful modules |
| All Views | **Strict Isolation** | Every external dependency is mocked — no real DB, network, or hardware |

!!! warning "Critical Distinction"

    Module Design describes the **internal logic, state, data structures, and error handling** of each module. It does **not** describe module boundaries, interfaces, or data flows between modules — those are documented in [architecture design](architecture-integration.md).

---

## Commands

### `/speckit.v-model.module-design`

Decomposes architecture modules into DO-178C/ISO 26262-compliant low-level module designs.

```bash
/speckit.v-model.module-design
```

**What it produces:**

- A `module-design.md` file in `specs/{feature}/v-model/`
- Every module gets a unique `MOD-NNN` ID
- Each module maps to a parent `ARCH-NNN` (many-to-many)
- Four mandatory views per module
- Module tags: `[EXTERNAL]`, `[CROSS-CUTTING]`, `[DERIVED MODULE]`

**Decomposition granularity:**

| ARCH Type | Decomposition Rule | Example |
|---|---|---|
| Component | One MOD per major function/class | ARCH-001 (Parser) → MOD-001 (parse_input), MOD-002 (validate_schema) |
| Service | One MOD per endpoint or handler | ARCH-003 (API Service) → MOD-005 (handle_create), MOD-006 (handle_delete) |

### `/speckit.v-model.unit-test`

Generates ISO 29119-4-compliant white-box unit test cases for every module.

```bash
/speckit.v-model.unit-test
```

**What it produces:**

- A `unit-test.md` file in `specs/{feature}/v-model/`
- **Test Procedures** (`UTP-NNN-X`) — unit test conditions per `MOD-NNN`
- **Test Scenarios** (`UTS-NNN-X#`) — executable unit test scenarios
- Each test case names its ISO 29119-4 technique explicitly

---

## ID Schema

| Tier | ID Format | Example | Meaning |
|---|---|---|---|
| Module Design | `MOD-NNN` | `MOD-001` | A discrete module within an architecture element |
| Test Procedure | `UTP-NNN-X` | `UTP-001-A` | A unit test procedure for MOD-001 |
| Test Scenario | `UTS-NNN-X#` | `UTS-001-A1` | A unit test scenario for UTP-001-A |

Reading `UTS-001-A1` tells you: this scenario validates test procedure `UTP-001-A`, which tests module `MOD-001`.

### Module Tags

| Tag | Meaning | Unit Test Impact |
|---|---|---|
| `[EXTERNAL]` | Third-party library or hardware wrapper | **Bypassed** — no UTP generated. Wrapper behavior tested at integration level. |
| `[CROSS-CUTTING]` | Shared infrastructure (logging, diagnostics) | Tested **normally** — full UTP/UTS coverage required |
| `[DERIVED MODULE]` | Not traceable to a parent ARCH | Flagged for traceability review but still tested |

!!! info "EXTERNAL tag scope"

    The `[EXTERNAL]` tag applies to the **third-party library**, not the wrapper. If the wrapper contains meaningful logic (retry policy, circuit breaker), that wrapper MOD is NOT `[EXTERNAL]` and must have unit tests.

---

## Strict Isolation

Every unit test runs in **complete isolation** — no real databases, no network calls, no file system access, no hardware interaction. The module design includes:

- **Dependency Registry** — Lists all external dependencies for each module
- **Mock Registry** — Specifies the mock/stub/fake for each dependency

This ensures unit tests are deterministic and fast, regardless of environment.

---

## Inter-Level Linking

Modules link **upward** to architecture elements via the `Parent Architecture Modules` metadata:

```markdown
### MOD-003: validate_sensor_input

| Field | Value |
|---|---|
| **Parent Architecture Modules** | ARCH-001 |
| **Tags** | — |
| **Description** | Validates raw sensor readings against schema and range constraints |
```

This creates the deepest cross-level chain: `ARCH-NNN` → `MOD-NNN` → `UTP-NNN-X` → `UTS-NNN-X#`.

---

## Validator

### `validate-module-coverage.sh`

Validates bi-directional coverage across the ARCH → MOD → UTP → UTS chain.

=== "Bash"

    ```bash
    scripts/bash/validate-module-coverage.sh specs/<feature>/v-model
    ```

=== "PowerShell"

    ```powershell
    scripts/powershell/validate-module-coverage.ps1 specs/<feature>/v-model
    ```

**Checks performed:**

| Check | Direction | What It Validates |
|---|---|---|
| Forward coverage | ARCH → MOD | Every architecture element maps to at least one module |
| Backward coverage | MOD → ARCH | Every module traces to an existing architecture element |
| Test coverage | MOD → UTP → UTS | Every non-`[EXTERNAL]` module has tests, every test has scenarios |
| External bypass | `[EXTERNAL]` | External modules are skipped for UTP requirement |
| No orphans | UTP → MOD | No test procedures referencing non-existent modules |

**Exit codes:** `0` = full coverage, `1` = gaps found.

!!! tip "Partial mode"

    If `unit-test.md` doesn't exist yet, the validator runs forward-only checks (ARCH → MOD) and skips MOD → UTP → UTS coverage.

---

## Matrix D: Implementation Verification

Matrix D extends the traceability chain to the innermost level:

- **Forward**: `ARCH-NNN` → `MOD-NNN` → `UTP-NNN-X` → `UTS-NNN-X#` (no gaps)
- **Backward**: Every unit test scenario → traces to a module → traces to an architecture element (no orphans)

Modules tagged as `[EXTERNAL]` are bypassed for unit test coverage. Modules tagged as `[CROSS-CUTTING]` are tested normally.

---

## Related Pages

- [Level 3: Architecture ↔ Integration](architecture-integration.md) — The level above
- [V-Model Concepts](concepts.md) — The complete V-Model overview
- [Peer Review](peer-review.md) — AI-powered review of module designs and unit tests
- [CI Integration](ci-integration.md) — Running validators in your pipeline
