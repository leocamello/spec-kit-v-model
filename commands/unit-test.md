---
description: Generate ISO 29119-4-compliant white-box unit test cases with five mandatory techniques for every module in the design.
handoffs:
  - label: Build Traceability Matrix
    agent: speckit.v-model.trace
    prompt: Build the full traceability matrix including module-level coverage (Matrix D)
    send: true
  - label: Back to Module Design
    agent: speckit.v-model.module-design
    prompt: Review or update the module design
scripts:
  sh: scripts/bash/setup-v-model.sh --json --require-reqs --require-module-design
  ps: scripts/powershell/setup-v-model.ps1 -Json -RequireReqs -RequireModuleDesign
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Generate an ISO 29119-4-compliant Unit Test Plan where **every module** (`MOD-NNN`) from `module-design.md` has at least one test case (`UTP-NNN-X`) and every test case has at least one executable unit scenario (`UTS-NNN-X#`). Unlike higher-level testing layers, unit tests are **white-box** — they verify internal control flow, data transformations, state transitions, and variable boundaries inside each module.

CRITICAL DISTINCTION: Unit tests do NOT test module boundaries or interfaces (that's integration testing), do NOT test user journeys (that's acceptance testing), and do NOT test system-level behavior (that's system testing). They test the **internal logic of individual modules** as documented in the four module design views.

## Execution Steps

### 1. Setup

Run `{SCRIPT}` from the repository root and parse the JSON output.

The script returns JSON with these keys:
- `VMODEL_DIR`: Path to `specs/{feature}/v-model/` directory
- `FEATURE_DIR`: Path to `specs/{feature}/` directory
- `BRANCH`: Current branch name
- `REQUIREMENTS`: Path to `requirements.md` (MUST exist — script uses `--require-reqs`)
- `MODULE_DESIGN`: Path to `module-design.md` (MUST exist — script uses `--require-module-design`)
- `AVAILABLE_DOCS`: Array of documents that currently exist

For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

### 2. Load Context

1. **Load the template**: Read `templates/unit-test-template.md` from the extension directory to understand the required output structure.

2. **Load module design**: Read `module-design.md` from the `MODULE_DESIGN` path.
   - If `module-design.md` does NOT exist: ERROR — "Module design not found. Run `/speckit.v-model.module-design` first."
   - Extract ALL `MOD-NNN` identifiers and their four views
   - Extract Algorithmic/Logic View (drives Statement & Branch Coverage)
   - Extract State Machine View (drives State Transition Testing)
   - Extract Internal Data Structures (drives BVA and Equivalence Partitioning)
   - Extract Error Handling (drives fault-related test cases)
   - Note `[EXTERNAL]` and `[CROSS-CUTTING]` tags
   - Note the total MOD count — every non-`[EXTERNAL]` MOD must have at least one UTP

3. **Load requirements**: Read `requirements.md` from the `REQUIREMENTS` path for supplementary domain context.

4. **Load v-model-config.yml** (if it exists at the repository root):
   - If `domain` is set to `iso_26262`, `do_178c`, or `iec_62304`: Enable safety-critical techniques (MC/DC Coverage, Variable-Level Fault Injection)
   - If absent or `domain` is empty: Skip safety-critical techniques entirely

5. **Load existing unit tests** (if `AVAILABLE_DOCS` contains `"unit-test.md"`):
   - Read the existing `unit-test.md` to preserve existing UTP/UTS IDs and content
   - Identify the highest existing UTP number to continue the sequence
   - New test cases append after existing ones — **never renumber**

### 3. Generate Unit Test Cases

For each `MOD-NNN` module, generate one or more test cases using the appropriate ISO 29119-4 white-box technique based on which module view drives the test.

#### 3.1 External Module Bypass

Modules tagged `[EXTERNAL]` are **skipped entirely** — no UTP is generated. Document each bypass:
> "Module MOD-NNN is [EXTERNAL] — wrapper behavior tested at integration level."

The `[EXTERNAL]` tag applies to the third-party library, not the wrapper. If the wrapper itself contains meaningful logic (retry policy, circuit breaker), that wrapper MOD is NOT `[EXTERNAL]` and MUST have unit tests.

#### 3.2 Technique Selection

Each test case MUST name its ISO 29119-4 technique explicitly. Select based on the module view being verified:

| Module View | Primary Technique | What It Tests |
|-------------|------------------|---------------|
| Algorithmic/Logic View | **Statement & Branch Coverage** | Every line of code and every True/False branch outcome |
| Internal Data Structures | **Boundary Value Analysis** | Variable boundaries: min, min-1, mid, max, max+1 (scalar types) |
| Internal Data Structures | **Equivalence Partitioning** | Discrete non-scalar types: Booleans, Enums (no numeric boundaries) |
| Architecture Interface View | **Strict Isolation** | Every external dependency mocked/stubbed |
| State Machine View | **State Transition Testing** | Every state transition including invalid ones |

**Rules**:
- Every non-`[EXTERNAL]` MOD gets at least one UTP from Statement & Branch Coverage
- Modules with scalar variables in Internal Data Structures get BVA
- Modules with Boolean/Enum types get Equivalence Partitioning instead of BVA
- Modules with external dependencies get Strict Isolation
- Stateful modules (Mermaid diagram in State Machine View) get State Transition Testing
- `[CROSS-CUTTING]` modules get tested with the same rigor as business logic

#### 3.3 Statement & Branch Coverage

For each branch in the Algorithmic/Logic View pseudocode:

1. **True path**: Exercise the condition evaluating to true
2. **False path**: Exercise the condition evaluating to false
3. **Loop zero iterations**: Loop body never executed
4. **Loop one iteration**: Single pass through the loop
5. **Loop N iterations**: Typical multi-pass scenario
6. **Error branches**: Every explicit error path in the pseudocode

#### 3.4 Boundary Value Analysis (BVA)

For each scalar, ordered variable in the Internal Data Structures view:

1. **min-1**: One below the minimum valid value (expect rejection)
2. **min**: The minimum valid value (expect acceptance)
3. **mid**: A typical middle value (nominal case)
4. **max**: The maximum valid value (expect acceptance)
5. **max+1**: One above the maximum valid value (expect rejection)

**Only for scalar ordered types** (integers, floats, array lengths). For Booleans and Enums, use Equivalence Partitioning instead.

#### 3.5 Equivalence Partitioning (EP)

For each discrete, non-scalar variable (Boolean, Enum, discrete set):

1. **Each valid partition**: One test per valid value (e.g., True/False for Boolean, each Enum member)
2. **Invalid partition**: Value outside the valid set (e.g., null, undefined enum value)

#### 3.6 Strict Isolation (Dependency & Mock Registry)

For each `MOD-NNN`, create a **Dependency & Mock Registry** table listing ALL external dependencies:

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| [Name] | [ARCH Interface View] | [Mock type: stub/fake/spy] | [Why this approach] |
| [HW Interface] | [GPIO/Register/Bus] | [Hardware abstraction mock] | [Embedded isolation] |

**Rules:**
- Dependencies come from the Architecture Interface View contracts
- **Hardware interfaces** (GPIO, memory-mapped registers, I2C/SPI buses) MUST be explicitly listed — LLMs often miss these in embedded contexts
- If the module has NO external dependencies: write `"None — module is self-contained"` and proceed with direct invocation (no mocking needed)
- A unit test MUST NEVER hit a real database, network, file system, or hardware interface

#### 3.7 State Transition Testing

For each stateful module with a Mermaid `stateDiagram-v2` in the State Machine View:

1. **Every valid transition**: Exercise each defined transition with proper guard conditions
2. **Every invalid transition**: Attempt transitions not in the state diagram (expect rejection)
3. **Entry/exit actions**: Verify state entry and exit side effects
4. **Initial state**: Verify module starts in the documented initial state
5. **Terminal states**: Verify proper cleanup in terminal states

### 4. Generate Unit Test Scenarios (Arrange/Act/Assert)

For each test case (`UTP-NNN-X`), generate one or more executable scenarios (`UTS-NNN-X#`) in **Arrange/Act/Assert** format.

#### 4.1 White-Box Language Mandate

Unit test scenarios MUST use **white-box, implementation-oriented language** referencing internal code paths, variables, and branches. They verify internal module logic, not boundaries or user journeys.

**PROHIBITED phrases** (these belong in OTHER test levels):
- "the user clicks/sees/navigates/enters/selects/receives" (acceptance test)
- "Module ARCH-NNN sends/receives" (integration test)
- "the interface between modules" (integration test)
- "the system responds/processes" (system test)

**REQUIRED language style**:
- "Arrange: Set `buffer_size` to 256 and `input_length` to 257"
- "Act: Call `parse_sensor_data(input)`"
- "Assert: Returns `ERROR_OVERFLOW` and `buffer` remains unchanged"
- "Arrange: Initialize state machine in `Idle` state"
- "Act: Send `start_event` followed by `invalid_event`"
- "Assert: State transitions to `Processing`, then `invalid_event` is rejected with `InvalidTransitionError`"

**Examples**:

❌ WRONG (user-centric — belongs in acceptance test):
```
Given a logged-in user
When the user submits the form
Then the user sees a success message
```

❌ WRONG (module-boundary — belongs in integration test):
```
Given ARCH-001 sends parsed data to ARCH-003
When ARCH-003 processes the payload
Then ARCH-003 returns the expected schema
```

✅ CORRECT (white-box — unit test):
```
Arrange: Set input_array = [1, 2, 3] and max_size = 3
Act: Call validate_array(input_array, max_size)
Assert: Returns true; internal counter equals 3
```

#### 4.2 Scenario Quality Criteria

Every UTS scenario must satisfy:
1. **Internal focus**: References specific variables, branches, or states from the module design
2. **Measurable outcomes**: Includes exact return values, variable states, error codes
3. **Isolation**: No references to other modules, external services, or user actions
4. **Reproducibility**: Arrange conditions fully specify the internal module state

### 5. Safety-Critical Techniques (Conditional)

**Only generate these sections if `v-model-config.yml` has `domain` set.**

#### 5.1 MC/DC (Modified Condition/Decision Coverage)

For each complex boolean decision in the Algorithmic/Logic View (e.g., `if (A and B or C)`):

- Generate a boolean truth table proving each individual condition (A, B, C) can independently affect the decision outcome
- Each row in the table becomes a UTS scenario
- Table format:

| Test | A | B | C | Decision | Independence Proof |
|------|---|---|---|----------|--------------------|
| 1 | T | T | F | T | A flips: row 1 vs row 3 |
| 2 | T | F | F | F | B flips: row 1 vs row 2 |
| 3 | F | T | F | F | A flips: row 1 vs row 3 |
| 4 | T | F | T | T | C flips: row 2 vs row 4 |

#### 5.2 Variable-Level Fault Injection

For each local variable in the Internal Data Structures view:

1. **Corrupt to NULL/zero**: Force the variable to null/zero after initialization
2. **Corrupt to max**: Force to maximum representable value
3. **Corrupt to negative**: Force to negative value (if unsigned type, verify rejection)
4. **Verify detection**: Internal error handling triggers correctly

### 6. Write Output

Write the complete unit test plan to `{VMODEL_DIR}/unit-test.md` using the template structure. Include:

1. **Header section**: Feature name, branch, date, source reference
2. **Overview**: Brief description of the unit test strategy
3. **ID Schema**: Document the UTP-NNN-X → MOD-NNN relationship encoding
4. **ISO 29119-4 Techniques**: Reference section listing applied techniques
5. **Unit Tests**: All UTP test cases with UTS scenarios, organized by MOD — each UTP names its technique and target view
6. **Dependency & Mock Registry**: Per-UTP isolation table
7. **External Module Bypass**: List of `[EXTERNAL]` modules skipped
8. **Safety-Critical Techniques**: MC/DC and Fault Injection (if domain configured)
9. **Coverage Summary**: Module count, test case count, scenario count, coverage percentage
10. **Technique Distribution**: Statement & Branch [N], BVA [N], EP [N], Strict Isolation [N], State Transition [N]
11. **Uncovered Modules**: List of MOD without UTP (should be empty, excluding `[EXTERNAL]`)

### 7. Coverage Gate

After writing the test plan, run the coverage gate:

1. Run `validate-module-coverage.sh {VMODEL_DIR}` (or `.ps1`) to verify:
   - Forward coverage: every ARCH has at least one MOD
   - Backward coverage: every non-`[EXTERNAL]` MOD has at least one UTP
2. Include the validation result (pass/fail with coverage summary) in the output

If validation fails, include the gap report but do NOT delete the generated file.

### 8. Report Completion

Display a summary:
- Total test cases (UTP) and scenarios (UTS) generated
- Coverage: X/Y MOD modules covered (must be 100%, excluding `[EXTERNAL]`)
- Technique distribution: Statement & Branch [N], BVA [N], EP [N], Strict Isolation [N], State Transition [N]
- Language compliance: Confirm zero user-journey phrases, zero integration phrases, zero system-level phrases
- External modules bypassed: [list]
- Safety-critical techniques included (yes/no, which domain)
- Coverage gate result: pass/fail
- Path to the generated file
- Next step: Recommend running `/speckit.v-model.trace` to build the full traceability matrix (Matrix D)

## Operating Constraints

### Strict Translation Rules

When generating from `module-design.md`:
- **DO NOT** invent test cases for modules or logic not in the module design
- **DO NOT** test module boundaries or interfaces — that is integration testing's job
- **DO NOT** test user journeys — that is acceptance testing's job
- **DO NOT** test system-level behavior — that is system testing's job
- **DO NOT** generate UTP for `[EXTERNAL]` modules
- **DO** generate at least one UTP per non-`[EXTERNAL]` MOD
- **DO** generate at least one UTS per UTP
- **DO** name the ISO 29119-4 technique for every test case
- **DO** reference the module view each test case targets
- **DO** include a Dependency & Mock Registry for every UTP

### ID Rules

- IDs are **permanent** — once assigned, they are never renumbered or reassigned
- Test case numbering mirrors parent MOD: `UTP-001-A` tests `MOD-001`
- Scenario numbering nests under test cases: `UTS-001-A1` is scenario 1 of `UTP-001-A`
- ID lineage: from `UTS-001-A1` a regex can extract `UTP-001-A` and `MOD-001`. To find the `ARCH-NNN` ancestor, the script MUST consult the "Parent Architecture Modules" field in `module-design.md` (many-to-many makes ID-only resolution impossible).
- When updating existing tests, preserve all existing IDs and append new ones
- Gaps in numbering are acceptable

### Technique Rules

- Every UTP MUST declare its ISO 29119-4 technique name
- Every UTP MUST declare which module view it targets
- Valid technique names (exact strings for structural validators):
  - `Statement & Branch Coverage`
  - `Boundary Value Analysis`
  - `Equivalence Partitioning`
  - `Strict Isolation`
  - `State Transition Testing`
  - `MC/DC Coverage` (safety-critical only)
  - `Variable-Level Fault Injection` (safety-critical only)
- BVA applies to scalar ordered types ONLY; use EP for Booleans and Enums

### Language Rules

- UTS scenarios use Arrange/Act/Assert format ONLY (not Given/When/Then BDD)
- White-box, implementation-oriented language referencing internal code constructs
- Zero user-journey phrases, zero integration phrases, zero system-level phrases
- All outcomes must be measurable (exact return values, variable states, error codes)
- Arrange conditions must fully specify internal module state
