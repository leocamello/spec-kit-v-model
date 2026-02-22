# Artifact ID Schema Guide

This document provides an in-depth explanation of the identifier (ID) system used throughout the V-Model Extension Pack. It covers the format rules, parent-child relationships, lifecycle, cross-level traceability, and the rationale behind the design decisions.

## Why a Disciplined ID Schema Matters

In safety-critical software development, regulators require **bidirectional traceability** — the ability to trace from any requirement down to its test evidence, and from any test back to the requirement it validates. When something goes wrong in the field, the investigation starts with a question: *which requirement governs this behavior, and what test proved it was correct?*

A self-documenting ID schema eliminates the need for lookup tables. Reading `SCN-003-A1` immediately tells you:

- **SCN** → This is a scenario (an executable test step at the acceptance level)
- **003** → It validates Requirement 003
- **A** → It belongs to Test Case A of that requirement
- **1** → It is the first scenario in that test case

No database query needed. No cross-referencing spreadsheets. The ID itself encodes the full lineage.

This same principle applies at every level of the V-Model — from requirements all the way down to unit test scenarios. The result is a four-tier hierarchy of 12 ID types that form an unbroken chain of custody from *what was specified* to *how it was verified*.

## The Four-Tier ID Hierarchy — Overview

| Level | Design Artifact | Test Case | Executable Step | Matrix |
|-------|----------------|-----------|-----------------|--------|
| Requirements ↔ Acceptance | `REQ-NNN` | `ATP-NNN-X` | `SCN-NNN-X#` | A |
| System Design ↔ System Test | `SYS-NNN` | `STP-NNN-X` | `STS-NNN-X#` | B |
| Architecture ↔ Integration Test | `ARCH-NNN` | `ITP-NNN-X` | `ITS-NNN-X#` | C |
| Module Design ↔ Unit Test | `MOD-NNN` | `UTP-NNN-X` | `UTS-NNN-X#` | D |

**Format conventions** (consistent across all levels):

- **`NNN`** — Zero-padded 3-digit number (`001`, `002`, ..., `999`). This is the numeric link to the parent design artifact.
- **`X`** — Single uppercase letter (`A`, `B`, `C`, ...). Identifies a specific test case for the parent. `A` is always the first test case, `B` the second, and so on.
- **`#`** — One or more digits (`1`, `2`, `12`, ...). Identifies a specific executable step within a test case.

The pattern is deliberately uniform: at every level, the test case ID appends a letter to the parent's number, and the executable step appends a digit to the test case. This consistency means anyone who understands the schema at one level automatically understands it at all levels.

## Two Types of Traceability Links

Before diving into each level, it is essential to understand that the V-Model Extension Pack uses **two distinct mechanisms** to record traceability:

### 1. Intra-Level Links — Encoded in the ID

**Within** each V-Model level, the relationship between a design artifact and its test cases is encoded directly in the ID itself. The test case ID contains the parent's number:

```
REQ-003  →  ATP-003-A  →  SCN-003-A1
             ^^^                ^^^
             The "003" IS the link — no lookup needed
```

This applies at every level: `STP-002-A` links to `SYS-002`, `ITP-005-A` links to `ARCH-005`, and `UTP-001-A` links to `MOD-001`. The parent-child relationship is self-documenting — reading the ID is sufficient to trace back.

### 2. Inter-Level Links — Recorded in Artifact Content

**Between** V-Model levels, the relationship is recorded as an **explicit field** in the artifact content. The IDs of different levels are independent — `SYS-001` does not inherently relate to `REQ-001`. Instead, the system design document records which requirements each system component satisfies:

| Cross-Level Link | Document | Section | Field Name | Format |
|-----------------|----------|---------|------------|--------|
| REQ → SYS | `system-design.md` | Decomposition View table | `Parent Requirements` | Comma-separated REQ IDs |
| SYS → ARCH | `architecture-design.md` | Logical View table | `Parent System Components` | Comma-separated SYS IDs |
| ARCH → MOD | `module-design.md` | Module heading metadata | `Parent Architecture Modules` | Comma-separated ARCH IDs |

These explicit fields are what the deterministic scripts parse to build the traceability matrices. The `build-matrix.sh` script extracts these fields using section-scoped regex matching (only parsing the Decomposition View for SYS, only the Logical View for ARCH, etc.) to avoid false positives from IDs appearing in other sections.

This distinction matters because it explains why the schema uses two different mechanisms:

- **Intra-level** (design → test): The link is structural — every test case *must* trace to exactly one parent design artifact, so encoding the parent's number in the test ID is both sufficient and efficient.
- **Inter-level** (design → design): The link is many-to-many — one system component may satisfy multiple requirements, and one requirement may be satisfied by multiple components. A fixed encoding would be insufficient, so the link is recorded as a list of parent IDs in the artifact content.

---

## Level 1: Requirements ↔ Acceptance Testing

This is the top of the V-Model — the starting point for all traceability.

### Design Artifact: `REQ-NNN`

Requirements are the atomic units of specification. Each requirement has a unique, permanent identifier:

```
REQ-001    — First functional requirement
REQ-002    — Second functional requirement
REQ-NF-001 — First non-functional requirement
REQ-IF-001 — First interface requirement
REQ-CN-001 — First constraint requirement
```

**Category prefixes** are unique to the requirements level. They allow auditors to filter requirements by type without reading every description:

| Prefix | Category | Example |
|--------|----------|---------|
| *(none)* | Functional | `REQ-001` |
| `NF` | Non-Functional | `REQ-NF-001` |
| `IF` | Interface | `REQ-IF-001` |
| `CN` | Constraint | `REQ-CN-001` |

Category prefixes propagate to test cases and scenarios. If the requirement is `REQ-NF-001`, its test cases are `ATP-NF-001-A`, `ATP-NF-001-B`, etc., and its scenarios are `SCN-NF-001-A1`, `SCN-NF-001-B1`, etc.

### Test Case: `ATP-NNN-X`

ATP stands for **Acceptance Test Procedure**. Each ATP validates a specific aspect of one requirement:

```
ATP-003-A  — First test case for REQ-003
ATP-003-B  — Second test case for REQ-003
ATP-003-C  — Third test case for REQ-003
```

The number `003` in `ATP-003-A` **is** the link back to `REQ-003`. This is an intra-level link — the relationship is encoded in the ID. Multiple test cases per requirement are expected — a single requirement often needs testing from multiple angles (happy path, boundary conditions, error cases, load conditions).

### Executable Step: `SCN-NNN-X#`

SCN stands for **Scenario** — an executable BDD (Behavior-Driven Development) test step in Given/When/Then format:

```
SCN-003-A1 — First scenario of ATP-003-A
SCN-003-A2 — Second scenario of ATP-003-A
SCN-003-B1 — First scenario of ATP-003-B
```

The `003-A` in `SCN-003-A1` **is** the link back to `ATP-003-A`, which in turn links to `REQ-003`. The entire lineage is readable from the ID alone.

### Traceability Chain

```
REQ-003 (Heart rate alarm within 2.0 seconds)
  │
  │  Intra-level link: "003" encoded in ATP-003-A
  ▼
  ├── ATP-003-A (Alarm triggers at exact threshold crossing)
  │     │
  │     │  Intra-level link: "003-A" encoded in SCN-003-A1
  │     ▼
  │     ├── SCN-003-A1 (Given HR=80, When sensor reports 121, Then alarm within 2.0s)
  │     └── SCN-003-A2 (Given HR=80, When sensor reports 200, Then alarm within 2.0s)
  ├── ATP-003-B (Alarm does NOT trigger at boundary)
  │     └── SCN-003-B1 (Given threshold=120, When HR=120 exactly, Then no alarm)
  └── ATP-003-C (Alarm timing under full sensor load)
        └── SCN-003-C1 (Given all 3 sensors active, When HR=150, Then alarm ≤2.0s)
```

Reading any ID in this tree tells you exactly where it belongs: `SCN-003-B1` → scenario 1 of test case B for requirement 003. No lookup table needed.

### What the Deterministic Validator Checks (Matrix A)

The `validate-requirement-coverage.sh` script performs bidirectional validation:

- **Forward traceability** (no gaps): Every `REQ` has at least one `ATP`, and every `ATP` has at least one `SCN`.
- **Backward traceability** (no orphans): Every `ATP` traces back to an existing `REQ`, and every `SCN` traces back to an existing `ATP`.

Any violation is flagged as a compliance failure. An orphaned test case (e.g., `ATP-999-A` with no matching `REQ-999`) means work was done without a requirement — a finding in any regulated audit.

---

## Level 2: System Design ↔ System Testing

The second level decomposes *what* the system must do (requirements) into *how* the system is structured (design elements).

### Connecting Requirements to System Design

Unlike the intra-level link between `REQ` and `ATP` (where the ID encodes the relationship), the link between requirements and system design is an **inter-level link** recorded explicitly in the artifact content.

The `system-design.md` document contains a **Decomposition View** table with a `Parent Requirements` column that lists which requirements each system component satisfies:

```markdown
### Decomposition View

| SYS ID | Component | Description | Parent Requirements | IEEE 1016 View |
|--------|-----------|-------------|---------------------|----------------|
| SYS-001 | SensorAcquisitionService | Reads HR, BP, SpO2 at 1 Hz | REQ-001, REQ-NF-002 | Decomposition |
| SYS-002 | AlarmEngine | Evaluates thresholds, triggers alarms | REQ-003, REQ-004, REQ-007 | Decomposition |
| SYS-003 | ClinicalDashboard | Displays vitals and alarm states | REQ-002, REQ-006 | Decomposition |
```

This is a **many-to-many mapping**:
- One system component may satisfy multiple requirements (`SYS-002` satisfies `REQ-003`, `REQ-004`, and `REQ-007`)
- One requirement may be satisfied by multiple components (if `REQ-NF-002` appears in both `SYS-001` and `SYS-003`)

The `build-matrix.sh` script extracts these `Parent Requirements` values by parsing the Decomposition View table with section-scoped regex matching. This is how Matrix B connects the system design level back to the requirements level — through explicit, auditable, machine-parsable fields, not through implicit ID conventions.

Note that `SYS` numbering is **independent** of `REQ` numbering. `SYS-001` does not relate to `REQ-001` — the relationship is recorded in the `Parent Requirements` column, not in the number.

### Design Artifact: `SYS-NNN`

SYS stands for **System Design Element**. Each element represents a major component or subsystem aligned with IEEE 1016:2009 design views (Decomposition, Dependency, Interface, Data Design):

```
SYS-001    — SensorAcquisitionService (reads sensors at 1 Hz)
SYS-002    — AlarmEngine (evaluates thresholds, triggers alarms)
SYS-003    — ClinicalDashboard (displays real-time vitals)
```

### Test Case: `STP-NNN-X`

STP stands for **System Test Procedure**. Each procedure validates a specific aspect of one system design element using ISO 29119-4 techniques:

```
STP-002-A  — Boundary Value Analysis for AlarmEngine thresholds
STP-002-B  — Fault Injection for sensor communication failure
STP-002-C  — Interface Contract Testing for event schema
```

The number `002` in `STP-002-A` **is** the intra-level link to `SYS-002`. The letter identifies the technique or test focus.

### Executable Step: `STS-NNN-X#`

STS stands for **System Test Step** — an executable test step with concrete preconditions and assertions:

```
STS-002-A1 — Given threshold=120, When HR=119, Then no alarm
STS-002-A2 — Given threshold=120, When HR=121, Then alarm emitted within 2.0s
STS-002-B1 — Given normal readings, When sensor stops for 3.0s, Then SensorDisconnected event
```

### Traceability Chain

```
REQ-003 (Heart rate alarm within 2.0 seconds)
  │
  │  Inter-level link: REQ-003 listed in SYS-002's "Parent Requirements" field
  ▼
SYS-002 (AlarmEngine)
  │
  │  Intra-level link: "002" encoded in STP-002-A
  ▼
  ├── STP-002-A (Boundary Value Analysis — Threshold Crossing)
  │     │
  │     │  Intra-level link: "002-A" encoded in STS-002-A1
  │     ▼
  │     ├── STS-002-A1 (Below threshold: no alarm)
  │     └── STS-002-A2 (Above threshold: alarm within 2.0s)
  └── STP-002-B (Fault Injection — Sensor Failure)
        └── STS-002-B1 (Sensor timeout: disconnect event, not false alarm)
```

### What the Deterministic Validator Checks (Matrix B)

The `validate-system-coverage.sh` script performs bidirectional validation:

- **Forward**: Every `SYS` → at least one `STP` → at least one `STS`
- **Backward**: Every `STP` → traces to an existing `SYS`; every `STS` → traces to an existing `STP`

The `build-matrix.sh` script additionally verifies the inter-level link: every `REQ` must appear in at least one `SYS` element's `Parent Requirements` field.

---

## Level 3: Architecture Design ↔ Integration Testing

The third level decomposes system components into finer-grained architecture modules and validates how they interact.

### Connecting System Design to Architecture

The link from system components to architecture elements follows the same inter-level pattern. The `architecture-design.md` document contains a **Logical View** table with a `Parent System Components` column:

```markdown
### Logical View

| ARCH ID | Module | Description | Parent System Components | IEEE 42010 View |
|---------|--------|-------------|--------------------------|-----------------|
| ARCH-001 | SensorProtocolAdapter | Abstracts vendor protocols | SYS-001 | Logical |
| ARCH-002 | ThresholdEvaluator | Stateless comparison engine | SYS-002 | Logical |
| ARCH-003 | AlarmDispatcher | Routes alarms by severity | SYS-002, SYS-003 | Logical |
| ARCH-007 | AuditLogger | Structured logging for all events | [CROSS-CUTTING] | Logical |
```

This is again a **many-to-many mapping**:
- One architecture module may implement parts of multiple system components (`ARCH-003` implements parts of both `SYS-002` and `SYS-003`)
- One system component may be implemented by multiple architecture modules (`SYS-002` is implemented by both `ARCH-002` and `ARCH-003`)

**Cross-cutting modules** use the `[CROSS-CUTTING]` tag instead of listing parent system components. These are infrastructure modules (logging, authentication, configuration) that span all system components rather than decomposing a specific one.

The `build-matrix.sh` script extracts `Parent System Components` from the Logical View table, scoped to avoid false matches from ARCH IDs appearing in other views (Interface, Process, Data Flow).

### Design Artifact: `ARCH-NNN`

ARCH stands for **Architecture Element**. Each element represents a module-level component aligned with IEEE 42010 / Kruchten 4+1 architecture views (Logical, Process, Interface, Data Flow):

```
ARCH-001   — SensorProtocolAdapter (abstracts vendor protocols)
ARCH-002   — ThresholdEvaluator (stateless comparison engine)
ARCH-003   — AlarmDispatcher (routes alarms by severity)
ARCH-007   — AuditLogger [CROSS-CUTTING]
```

### Test Case: `ITP-NNN-X`

ITP stands for **Integration Test Procedure**. Each procedure validates the interaction between architecture modules using ISO 29119-4 integration techniques:

```
ITP-004-A  — Interface Contract Testing (event schema validation)
ITP-004-B  — Data Flow Testing (end-to-end pipeline verification)
ITP-004-C  — Interface Fault Injection (adapter failure handling)
ITP-004-D  — Concurrency & Race Condition Testing (thread safety)
```

The number `004` in `ITP-004-A` is the intra-level link to `ARCH-004` (typically an interface element). The letter identifies the integration technique applied.

### Executable Step: `ITS-NNN-X#`

ITS stands for **Integration Test Step**:

```
ITS-004-A1 — Given mock HR sensor, When reading=80, Then VitalSignReading event published
ITS-004-B1 — Given ThresholdEvaluator subscribed, When HR=121 published, Then value received intact
ITS-004-C1 — Given normal publishing, When event bus interrupted 3.0s, Then SensorTimeout event
```

### Traceability Chain

```
SYS-002 (AlarmEngine)
  │
  │  Inter-level link: SYS-002 listed in ARCH-002's "Parent System Components" field
  ▼
ARCH-002 (ThresholdEvaluator) — Parent System Components: SYS-002
  │
  │  Intra-level link: "002" encoded in ITP-002-A
  ▼
  ├── ITP-002-A (Interface Contract Testing — Input Event Schema)
  │     │
  │     │  Intra-level link: "002-A" encoded in ITS-002-A1
  │     ▼
  │     └── ITS-002-A1 (Publish VitalSignReading, verify schema compliance)
  └── ITP-002-B (Data Flow Testing — Evaluation Pipeline)
        └── ITS-002-B1 (Inject HR=121, verify AlarmTrigger emitted)
```

### What the Deterministic Validator Checks (Matrix C)

The `validate-architecture-coverage.sh` script performs bidirectional validation:

- **Forward**: Every `ARCH` → at least one `ITP` → at least one `ITS`
- **Backward**: Every `ITP` → traces to an existing `ARCH`; every `ITS` → traces to an existing `ITP`
- **Cross-cutting validation**: `[CROSS-CUTTING]` modules must have integration tests that span all dependent modules

The `build-matrix.sh` script additionally verifies the inter-level link: every `SYS` must appear in at least one `ARCH` element's `Parent System Components` field.

---

## Level 4: Module Design ↔ Unit Testing

The bottom of the V-Model — the most granular level where individual functions and algorithms are specified and verified in isolation.

### Connecting Architecture to Module Design

The link from architecture elements to module designs uses the same inter-level pattern, but with a different format. Instead of a table column, `module-design.md` records the parent as a **metadata line** below each module heading:

```markdown
### Module: MOD-001 (SensorProtocolParser)

**Parent Architecture Modules:** ARCH-001
**Target Source File(s):** `src/sensor_protocol_parser.py`
```

```markdown
### Module: MOD-003 (ThresholdComparator)

**Parent Architecture Modules:** ARCH-002
**Target Source File(s):** `src/threshold_comparator.py`
```

```markdown
### Module: MOD-007 (AuditLogger) [CROSS-CUTTING]

**Parent Architecture Modules:** ARCH-007 [CROSS-CUTTING]
**Target Source File(s):** `src/logging/audit_logger.py`
```

This is a **many-to-many mapping**:
- One architecture module may decompose into multiple module designs (`ARCH-001` → `MOD-001`, `MOD-002`)
- One module design may implement parts of multiple architecture modules (e.g., a shared utility module)

**Special tags** at this level:

| Tag | Meaning | Validation Impact |
|-----|---------|-------------------|
| `[EXTERNAL]` | Third-party library or SDK — not designed by the team | Excluded from pseudocode/state machine requirements; tested only at boundaries |
| `[CROSS-CUTTING]` | Infrastructure module (logging, auth, config) | Inherited from parent ARCH; validated across all dependent modules |
| `[DERIVED MODULE]` | Not directly traceable to an ARCH element — emerged during design | Must still have full unit test coverage |

The `build-matrix.sh` script extracts `Parent Architecture Modules` from the metadata line below each `### Module: MOD-NNN` heading.

### Design Artifact: `MOD-NNN`

MOD stands for **Module Design**. Each module represents a single implementation unit (function, class, or tightly coupled set of functions) with four mandatory views:

1. **Algorithmic / Logic View** — Pseudocode defining the exact logic
2. **State Machine View** — State transitions (or `N/A — Stateless` for pure functions)
3. **Internal Data Structures** — Memory layout, constants, enums
4. **Error Handling & Return Codes** — Every error condition and its upstream contract

```
MOD-001    — SensorProtocolParser (parses raw sensor bytes)
MOD-002    — ThresholdComparator (compares value against configured limits)
MOD-003    — AlarmPriorityResolver (maps threshold violations to alarm severities)
MOD-005    — ExternalSDK [EXTERNAL]
MOD-007    — AuditLogger [CROSS-CUTTING]
```

### Test Case: `UTP-NNN-X`

UTP stands for **Unit Test Procedure**. Each procedure uses a white-box testing technique to exercise a specific module in strict isolation:

```
UTP-001-A  — Statement & Branch Coverage (exercise every line/branch)
UTP-001-B  — Boundary Value Analysis (test at exact limits)
UTP-001-C  — Equivalence Partitioning (input class testing)
UTP-002-A  — State Transition Testing (verify state machine)
```

The number `001` in `UTP-001-A` is the intra-level link to `MOD-001`.

**Strict isolation** is a core principle at this level. Every external dependency is explicitly listed in a **Dependency & Mock Registry** per test procedure:

```markdown
**Dependency & Mock Registry:**
| Real Dependency | Mock / Stub | Behavior |
|----------------|-------------|----------|
| ThresholdConfigStore | MockConfigStore | Returns fixed thresholds |
| EventBus | StubEventBus | Records emitted events |
```

Modules with no external dependencies use: `**Dependency & Mock Registry:** None — module is self-contained.`

The supported techniques at the unit level are:

| Technique | Purpose |
|-----------|---------|
| Statement & Branch Coverage | Exercise every line and every branch decision |
| Boundary Value Analysis | Test at exact min/max/boundary values |
| Equivalence Partitioning | Test one representative from each input class |
| Strict Isolation | Verify behavior with all dependencies mocked |
| State Transition Testing | Exercise state machine transitions and guards |
| MC/DC Coverage | Modified Condition/Decision Coverage (safety-critical) |
| Variable-Level Fault Injection | Force local variables into corrupted states |

### Executable Step: `UTS-NNN-X#`

UTS stands for **Unit Test Scenario**. Each scenario follows a strict **Arrange / Act / Assert** structure (not Given/When/Then — unit tests are white-box, not behavioral):

```
UTS-001-A1 — Arrange: valid 14-byte HR packet, Act: parse(), Assert: VitalSignReading returned
UTS-001-A2 — Arrange: 4-byte packet (too short), Act: parse(), Assert: Error("Insufficient data")
UTS-001-B1 — Arrange: HR value=0 (minimum), Act: parse(), Assert: accepted
UTS-001-B2 — Arrange: HR value=301 (above max), Act: parse(), Assert: Error("Value out of range")
```

### Traceability Chain

```
ARCH-001 (SensorProtocolAdapter)
  │
  │  Inter-level link: ARCH-001 listed in MOD-001's "Parent Architecture Modules" field
  ▼
MOD-001 (SensorProtocolParser) — Parent Architecture Modules: ARCH-001
  │
  │  Intra-level link: "001" encoded in UTP-001-A
  ▼
  ├── UTP-001-A (Statement & Branch Coverage — parse_vital_reading)
  │     │
  │     │  Intra-level link: "001-A" encoded in UTS-001-A1
  │     ▼
  │     ├── UTS-001-A1 (Valid packet → successful parse)
  │     └── UTS-001-A2 (Short packet → Insufficient data error)
  └── UTP-001-B (Boundary Value Analysis — Value Ranges)
        ├── UTS-001-B1 (HR=0 → accepted at minimum)
        └── UTS-001-B2 (HR=301 → rejected above maximum)
```

### What the Deterministic Validator Checks (Matrix D)

The `validate-module-coverage.sh` script performs bidirectional validation at the module level:

- **Forward**: Every `MOD` → at least one `UTP` → at least one `UTS`
- **Backward**: Every `UTP` → traces to an existing `MOD`; every `UTS` → traces to an existing `UTP`
- **External module handling**: `[EXTERNAL]` modules are validated for boundary tests only
- **Orphan detection**: UTPs referencing non-existent MODs are flagged

The `build-matrix.sh` script additionally verifies the inter-level link: every `ARCH` must appear in at least one `MOD` element's `Parent Architecture Modules` field.

---

## ID Lifecycle

### Creation

IDs are assigned sequentially when an artifact is first generated:

1. `/speckit.v-model.requirements` assigns `REQ-001`, `REQ-002`, etc.
2. `/speckit.v-model.acceptance` reads the REQ IDs and derives `ATP-001-A`, `ATP-001-B`, `SCN-001-A1`, etc.
3. Each subsequent command reads the IDs from the previous level's artifact and derives the next level's IDs.

The numbering is **per-level** — `REQ-001`, `SYS-001`, `ARCH-001`, and `MOD-001` are four completely independent identifiers referring to four different things. Their linkage is recorded in the artifact content (via `Parent Requirements`, `Parent System Components`, and `Parent Architecture Modules` fields), not in the number.

### Immutability

Once an ID is assigned, it is **permanent**:

- **IDs are never renumbered.** If `REQ-003` is removed, the next requirement is still `REQ-004` (or whatever the next number would have been). The gap at `003` remains.
- **Gaps are acceptable.** In regulated environments, renumbering would break every audit trail, every cross-reference, every linked test case. A gap is a harmless artifact of change history; renumbering is a compliance violation.
- **IDs survive modification.** If the description of `REQ-003` changes (e.g., the alarm threshold is updated from 2.0 seconds to 1.5 seconds), the ID stays `REQ-003`. The change is tracked by Git, not by a new ID.

### Deprecation

When a requirement is removed (not just modified), the corresponding artifacts are marked with a `[DEPRECATED]` tag rather than deleted:

```markdown
### ~~REQ-003~~ [DEPRECATED]
**Reason:** Replaced by REQ-012 after clinical risk reassessment.
```

This preserves the ID in the audit trail. An auditor reviewing historical baselines will see that `REQ-003` existed, was tested (via `ATP-003-*`), and was explicitly retired — not silently dropped.

### Incremental Updates

When requirements change after downstream artifacts already exist:

| Change Type | Behavior |
|-------------|----------|
| **Requirement added** | New ATPs/SCNs are generated and appended. The traceability matrix is rebuilt. |
| **Requirement modified** | The corresponding ATPs/SCNs are regenerated in place. The ID stays the same. |
| **Requirement removed** | The ID and its ATPs/SCNs are marked `[DEPRECATED]`. The matrix flags them as inactive. |
| **No change** | The artifact is preserved exactly as-is — character for character. |

The `diff-requirements.sh` script detects which requirements changed between baselines, enabling surgical regeneration of only the affected downstream artifacts.

---

## Cross-Level Traceability: The Four Matrices

The `/speckit.v-model.trace` command builds all four matrices in a single consolidated report. Each matrix validates traceability within its level (via intra-level ID links) and between levels (via explicit parent fields).

### Matrix A — Requirements → Acceptance Testing

```
REQ-NNN  →  ATP-NNN-X  →  SCN-NNN-X#
```

**Link type**: Intra-level (ID-encoded). The `NNN` in `ATP-NNN-X` is the `REQ` number.

**Proves**: Every business requirement has been translated into a testable acceptance criterion with executable scenarios.

**Auditor question answered**: *"Was this requirement tested?"*

### Matrix B — System Design → System Testing

```
REQ-NNN  →(Parent Requirements)→  SYS-NNN  →  STP-NNN-X  →  STS-NNN-X#
```

**Link types**:
- REQ → SYS: Inter-level (explicit `Parent Requirements` column in Decomposition View)
- SYS → STP → STS: Intra-level (ID-encoded)

**Proves**: Every system design decision has been validated through systematic testing, and every design element traces back to its source requirements.

**Auditor question answered**: *"Was this design element verified, and which requirements drove it?"*

### Matrix C — Architecture → Integration Testing

```
SYS-NNN  →(Parent System Components)→  ARCH-NNN  →  ITP-NNN-X  →  ITS-NNN-X#
```

**Link types**:
- SYS → ARCH: Inter-level (explicit `Parent System Components` column in Logical View)
- ARCH → ITP → ITS: Intra-level (ID-encoded)

**Proves**: Every architecture module interacts correctly with its neighbors. Interface contracts are honored, data flows are intact, faults are handled gracefully.

**Auditor question answered**: *"Do the modules work together correctly, and which system components are they implementing?"*

### Matrix D — Module Design → Unit Testing

```
ARCH-NNN  →(Parent Architecture Modules)→  MOD-NNN  →  UTP-NNN-X  →  UTS-NNN-X#
```

**Link types**:
- ARCH → MOD: Inter-level (explicit `Parent Architecture Modules` metadata line)
- MOD → UTP → UTS: Intra-level (ID-encoded)

**Proves**: Every individual module's internal logic is correct — every branch is covered, every boundary is tested, every dependency is isolated.

**Auditor question answered**: *"Does each module work correctly in isolation, and which architecture element does it decompose?"*

### The Complete Chain

When all four matrices are compliant, you have an unbroken chain from business intent to implementation proof. The chain uses both link types — intra-level links within each tier (encoded in IDs) and inter-level links between tiers (recorded in artifact fields):

```
REQ-003 (Heart rate alarm within 2.0 seconds)
  │
  │  ← Intra-level: "003" encoded in ATP-003-A
  ▼
ATP-003-A (Alarm triggers at exact threshold crossing)
  │
  │  ← Intra-level: "003-A" encoded in SCN-003-A1
  ▼
SCN-003-A1 (acceptance: Given HR=80, When sensor reports 121, Then alarm within 2.0s)
  ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
  │
  │  ← Inter-level: REQ-003 listed in SYS-002's "Parent Requirements"
  ▼
SYS-002 (AlarmEngine)
  │
  │  ← Intra-level: "002" encoded in STP-002-A
  ▼
STP-002-A (Boundary Value Analysis — Threshold Crossing)
  │
  │  ← Intra-level: "002-A" encoded in STS-002-A2
  ▼
STS-002-A2 (system test: Given threshold=120, When HR=121, Then alarm within 2.0s)
  ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
  │
  │  ← Inter-level: SYS-002 listed in ARCH-002's "Parent System Components"
  ▼
ARCH-002 (ThresholdEvaluator)
  │
  │  ← Intra-level: "002" encoded in ITP-002-A
  ▼
ITP-002-A (Interface Contract Testing — Input Event Schema)
  │
  │  ← Intra-level: "002-A" encoded in ITS-002-A1
  ▼
ITS-002-A1 (integration: VitalSignReading(HR, 121) → AlarmTrigger(HIGH, HR, 121))
  ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
  │
  │  ← Inter-level: ARCH-002 listed in MOD-003's "Parent Architecture Modules"
  ▼
MOD-003 (ThresholdComparator)
  │
  │  ← Intra-level: "003" encoded in UTP-003-A
  ▼
UTP-003-A (Statement & Branch Coverage — compare())
  │
  │  ← Intra-level: "003-A" encoded in UTS-003-A1
  ▼
UTS-003-A1 (unit: Arrange value=121, threshold=120 → Act compare() → Assert EXCEEDED)
```

The dotted lines (┄) mark the boundaries between V-Model levels — each crossing is an inter-level link stored as an explicit field in the artifact content. Within each level, the links are encoded directly in the IDs.

An auditor can trace from `REQ-003` (a business requirement) all the way down to `UTS-003-A1` (a specific unit test scenario) and verify that every intermediate level has been designed and tested. Conversely, they can trace from any unit test back up to the business requirement it ultimately serves — by reading the `Parent Architecture Modules` field to find the ARCH, then the `Parent System Components` field to find the SYS, then the `Parent Requirements` field to find the REQ.

---

## End-to-End Example: Medical Device Vital Signs Monitor

To make the schema concrete, here is a complete trace through all four levels for a single requirement in an IEC 62304 Class C medical device:

### Level 1 — Requirement and Acceptance

```
REQ-003: "The system SHALL trigger an audible alarm within 2.0 seconds
          when heart rate exceeds the configurable upper threshold."

  ATP-003-A: Alarm triggers at exact threshold crossing
    SCN-003-A1: Given threshold=120, When HR=121, Then alarm within 2.0s
  ATP-003-B: Alarm does NOT trigger at boundary
    SCN-003-B1: Given threshold=120, When HR=120, Then no alarm
  ATP-003-C: Alarm timing under full sensor load
    SCN-003-C1: Given 3 sensors active, When HR=150, Then alarm ≤2.0s
```

**Link to next level**: `REQ-003` will appear in a system component's `Parent Requirements` field.

### Level 2 — System Design and System Test

```
SYS-002: AlarmEngine — evaluates vitals against thresholds, triggers alarms
         Parent Requirements: REQ-003, REQ-004, REQ-007

  STP-002-A: Boundary Value Analysis — Threshold Crossing
    STS-002-A1: Given threshold=120, When HR=119, Then no alarm
    STS-002-A2: Given threshold=120, When HR=121, Then alarm within 2.0s
  STP-002-B: Fault Injection — Sensor Failure
    STS-002-B1: Given normal readings, When sensor stops 3.0s, Then SensorDisconnected
```

**Link to next level**: `SYS-002` will appear in architecture elements' `Parent System Components` field.

### Level 3 — Architecture Design and Integration Test

```
ARCH-002: ThresholdEvaluator — stateless comparison engine
          Parent System Components: SYS-002

  ITP-002-A: Interface Contract Testing — Input Event Schema
    ITS-002-A1: Given ThresholdEvaluator subscribed, When VitalSignReading(HR, 121) published,
                Then AlarmTrigger(HIGH, HR, 121) emitted
  ITP-002-B: Data Flow Testing — End-to-End Alarm Pipeline
    ITS-002-B1: Given all modules connected, When HR=121 injected at adapter,
                Then audible alarm dispatched within 2.0s end-to-end
```

**Link to next level**: `ARCH-002` will appear in module designs' `Parent Architecture Modules` field.

### Level 4 — Module Design and Unit Test

```
MOD-003: ThresholdComparator — compares value against configured limits
         Parent Architecture Modules: ARCH-002

  UTP-003-A: Statement & Branch Coverage — compare()
    Dependency & Mock Registry: None — module is self-contained.
    UTS-003-A1: Arrange: value=121, threshold=120
                Act: compare(value, threshold)
                Assert: returns EXCEEDED
    UTS-003-A2: Arrange: value=120, threshold=120
                Act: compare(value, threshold)
                Assert: returns WITHIN_RANGE
  UTP-003-B: Boundary Value Analysis — edge values
    Dependency & Mock Registry: None — module is self-contained.
    UTS-003-B1: Arrange: value=0 (minimum int), threshold=120
                Act: compare(value, threshold)
                Assert: returns WITHIN_RANGE
    UTS-003-B2: Arrange: value=MAX_INT, threshold=120
                Act: compare(value, threshold)
                Assert: returns EXCEEDED
```

### The Audit Trace

An IEC 62304 auditor reviewing this system can now verify:

1. **REQ-003** exists and is testable ✅
2. **ATP-003-A/B/C** cover the requirement from three angles (intra-level: `003` in ID) ✅
3. **SCN-003-A1/B1/C1** provide executable scenarios (intra-level: `003-A/B/C` in ID) ✅
4. **SYS-002** implements the alarm functionality (inter-level: `Parent Requirements: REQ-003`) ✅
5. **STP-002-A/B** verify boundary and fault conditions (intra-level: `002` in ID) ✅
6. **ARCH-002** refines the evaluator module (inter-level: `Parent System Components: SYS-002`) ✅
7. **ITP-002-A/B** validate the integration interface (intra-level: `002` in ID) ✅
8. **MOD-003** specifies the comparison algorithm (inter-level: `Parent Architecture Modules: ARCH-002`) ✅
9. **UTP-003-A/B** verify every branch of the comparator (intra-level: `003` in ID) ✅

Every link in this chain is deterministically validated by a script — not by human judgment or AI self-assessment. The four traceability matrices provide the mathematical proof.

---

## Why Deterministic Validation — Not AI

A critical design decision: **all traceability validation is performed by deterministic scripts, not by the AI that generated the artifacts.**

The AI generates the content of requirements, test cases, and scenarios — tasks that require understanding of domain context, natural language, and technical intent. But the coverage calculations (how many requirements have test cases, which tests are orphaned, what the coverage percentage is) are performed by regex-based Bash and PowerShell scripts that produce the same answer every time.

This separation exists because:

1. **An AI cannot grade its own homework.** If the same model generates the test plan and evaluates its completeness, there is no independent verification.
2. **Coverage is binary.** Either `REQ-003` has a matching `ATP-003-*` or it doesn't. This is a pattern-matching problem, not a reasoning problem.
3. **Auditors demand reproducibility.** Running the validation script twice must produce identical results. LLMs are stochastic by nature.
4. **Scripts are inspectable.** An auditor can read `validate-requirement-coverage.sh`, understand its logic, and trust its output. An LLM's internal reasoning is opaque.

The validation scripts (`validate-requirement-coverage.sh`, `validate-system-coverage.sh`, `validate-architecture-coverage.sh`, `validate-module-coverage.sh`, `build-matrix.sh`) are themselves tested by 91 BATS tests and 91 Pester tests to ensure they correctly detect gaps, orphans, and coverage violations.

---

## Summary of All 12 ID Types

| ID | Full Name | Format | Example | Intra-Level Parent | Inter-Level Parent | Level |
|----|-----------|--------|---------|--------------------|--------------------|-------|
| `REQ` | Requirement | `REQ[-CAT]-NNN` | `REQ-003`, `REQ-NF-001` | *(none — top level)* | *(none — top level)* | 1 |
| `ATP` | Acceptance Test Procedure | `ATP[-CAT]-NNN-X` | `ATP-003-A` | `REQ` (via `NNN`) | — | 1 |
| `SCN` | Scenario (BDD) | `SCN[-CAT]-NNN-X#` | `SCN-003-A1` | `ATP` (via `NNN-X`) | — | 1 |
| `SYS` | System Design Element | `SYS-NNN` | `SYS-002` | — | `REQ` (via `Parent Requirements`) | 2 |
| `STP` | System Test Procedure | `STP-NNN-X` | `STP-002-A` | `SYS` (via `NNN`) | — | 2 |
| `STS` | System Test Step | `STS-NNN-X#` | `STS-002-A2` | `STP` (via `NNN-X`) | — | 2 |
| `ARCH` | Architecture Element | `ARCH-NNN` | `ARCH-005` | — | `SYS` (via `Parent System Components`) | 3 |
| `ITP` | Integration Test Procedure | `ITP-NNN-X` | `ITP-005-A` | `ARCH` (via `NNN`) | — | 3 |
| `ITS` | Integration Test Step | `ITS-NNN-X#` | `ITS-005-A1` | `ITP` (via `NNN-X`) | — | 3 |
| `MOD` | Module Design | `MOD-NNN` | `MOD-003` | — | `ARCH` (via `Parent Architecture Modules`) | 4 |
| `UTP` | Unit Test Procedure | `UTP-NNN-X` | `UTP-003-A` | `MOD` (via `NNN`) | — | 4 |
| `UTS` | Unit Test Scenario | `UTS-NNN-X#` | `UTS-003-A1` | `UTP` (via `NNN-X`) | — | 4 |
