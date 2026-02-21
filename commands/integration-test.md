---
description: Generate ISO 29119-compliant integration test cases with four mandatory techniques for every architecture module in the design.
handoffs:
  - label: Build Traceability Matrix
    agent: speckit.v-model.trace
    prompt: Build the full traceability matrix including integration-level coverage
    send: true
  - label: Back to Architecture Design
    agent: speckit.v-model.architecture-design
    prompt: Review or update the architecture design
scripts:
  sh: scripts/bash/setup-v-model.sh --json --require-reqs --require-architecture-design
  ps: scripts/powershell/setup-v-model.ps1 -Json -RequireReqs -RequireArchitectureDesign
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Generate an ISO 29119-compliant Integration Test Plan where **every architecture module** (`ARCH-NNN`) from `architecture-design.md` has at least one test case (`ITP-NNN-X`) and every test case has at least one executable integration scenario (`ITS-NNN-X#`). Unlike system tests (which verify design views), integration tests verify the **seams and handshakes between modules** — they target architecture module boundaries using four mandatory techniques.

CRITICAL DISTINCTION: integration tests do NOT test internal module logic (that's unit testing) and do NOT test user journeys (that's acceptance testing). They test the INTERFACES BETWEEN modules.

## Execution Steps

### 1. Setup

Run `{SCRIPT}` from the repository root and parse the JSON output.

The script returns JSON with these keys:
- `VMODEL_DIR`: Path to `specs/{feature}/v-model/` directory
- `FEATURE_DIR`: Path to `specs/{feature}/` directory
- `BRANCH`: Current branch name
- `REQUIREMENTS`: Path to `requirements.md` (MUST exist — script uses `--require-reqs`)
- `ARCH_DESIGN`: Path to `architecture-design.md` (MUST exist — script uses `--require-architecture-design`)
- `AVAILABLE_DOCS`: Array of documents that currently exist

For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

### 2. Load Context

1. **Load the template**: Read `templates/integration-test-template.md` from the extension directory to understand the required output structure.

2. **Load architecture design**: Read `architecture-design.md` from the `VMODEL_DIR` path.
   - If `architecture-design.md` does NOT exist: ERROR — "Architecture design not found. Run `/speckit.v-model.architecture-design` first."
   - Extract ALL `ARCH-NNN` identifiers from the Logical View
   - Extract the Process View (feeds Concurrency & Race Condition tests)
   - Extract the Interface View (feeds Interface Contract Testing + Fault Injection)
   - Extract the Data Flow View (feeds Data Flow Testing)
   - Note the total ARCH count — every ARCH must have at least one ITP

3. **Load requirements**: Read `requirements.md` from the `REQUIREMENTS` path for supplementary domain context.

4. **Load v-model-config.yml** (if it exists at the repository root):
   - If `domain` is set to `iso_26262`, `do_178c`, or `iec_62304`: Enable safety-critical test sections (SIL/HIL, Resource Contention)
   - If absent or `domain` is empty: Skip safety-critical test sections entirely

5. **Load existing integration tests** (if `AVAILABLE_DOCS` contains `"integration-test.md"`):
   - Read the existing `integration-test.md` to preserve existing ITP/ITS IDs and content
   - Identify the highest existing ITP number to continue the sequence
   - New test cases append after existing ones — **never renumber**

### 3. Generate Integration Test Cases

For each `ARCH-NNN` module in the Logical View, generate one or more test cases using the appropriate ISO 29119 technique based on which architecture view the module's boundaries target.

#### 3.1 Technique Selection

Each test case MUST name its ISO 29119 technique explicitly. Select based on the architecture view being verified:

| Architecture View | Primary Technique | What It Tests |
|-------------------|------------------|---------------|
| Interface View | **Interface Contract Testing** | API contract compliance between consumer-provider module pairs |
| Data Flow View | **Data Flow Testing** | Data transformation chain correctness across module boundaries |
| Interface View + Process View | **Interface Fault Injection** | Graceful failure when module interfaces receive invalid/malformed data |
| Process View | **Concurrency & Race Condition Testing** | Thread safety, lock handling, resource contention between modules |

**Rules**:
- Every ARCH module gets at least one ITP from its most relevant architecture view
- Modules with interface contracts get Interface Contract Testing + Interface Fault Injection
- Modules in data flows get Data Flow Testing
- Modules with concurrency interactions get Concurrency Testing
- `[CROSS-CUTTING]` modules get tested too — their interfaces are used by many consumers

#### 3.2 Interface Contract Testing

For each ARCH↔ARCH interface defined in the Interface View:

1. **Consumer-provider pair**: Test that Module A (consumer) receives the exact contract Module B (provider) promises
2. **Valid contract**: Expected inputs → expected outputs per Interface View table
3. **Contract violation**: Provider returns unexpected format → consumer detects and handles
4. **Missing fields**: Optional vs required field handling across module boundaries

#### 3.3 Data Flow Testing

For each data transformation chain in the Data Flow View:

1. **End-to-end chain**: Inject data at first module, verify correct format at final module
2. **Intermediate verification**: Check format at each transformation stage matches Data Flow View
3. **Invalid data propagation**: Bad data injected at stage 1 → verify detection point in the chain
4. **Empty/null data**: Verify chain handles empty inputs without corruption

#### 3.4 Interface Fault Injection

For each ARCH module's error contracts from the Interface View:

1. **Malformed payloads**: Send invalid data types, truncated messages, oversized inputs
2. **Timeout scenarios**: Module B doesn't respond → Module A handles gracefully
3. **Partial responses**: Incomplete data from provider → consumer detects
4. **Error propagation**: Verify failure in one module does NOT cascade to unrelated modules
5. **Graceful degradation**: System remains operational with reduced capability

#### 3.5 Concurrency & Race Condition Testing

For each concurrent interaction in the Process View:

1. **Simultaneous access**: Two modules accessing same resource → correct lock handling
2. **Queue ordering**: Messages arrive out-of-order → correct reordering
3. **Deadlock avoidance**: Circular dependency scenarios → no deadlock
4. **Resource starvation**: High-throughput scenario → fair resource allocation

### 4. Generate Integration Test Scenarios (BDD)

For each test case (`ITP-NNN-X`), generate one or more executable scenarios (`ITS-NNN-X#`) in Given/When/Then format.

#### 4.1 Module-Boundary Language Mandate

Integration test scenarios MUST use **module-boundary, interface-oriented language**. They verify interactions between modules, not internal logic or user journeys.

**PROHIBITED phrases** (these belong in OTHER test levels):
- "the user clicks/sees/navigates/enters/selects/receives" (acceptance test)
- "the dashboard shows / the form displays" (acceptance test)
- "the function returns / the method throws" (unit test)
- "the internal state changes" (unit test)

**REQUIRED language style**:
- "ARCH-NNN sends [message] to ARCH-NNN"
- "ARCH-NNN receives [response] from ARCH-NNN"
- "the interface between ARCH-NNN and ARCH-NNN returns [error]"
- "data flowing from ARCH-NNN to ARCH-NNN is transformed from [format A] to [format B]"
- "when ARCH-NNN is unavailable, ARCH-NNN [handles gracefully]"
- "concurrent access to [resource] by ARCH-NNN and ARCH-NNN [resolves correctly]"

**Examples**:

❌ WRONG (user-centric — belongs in acceptance test):
```
Given a logged-in user on the dashboard
When the user clicks "Export Report"
Then the user sees a download dialog
```

❌ WRONG (internal logic — belongs in unit test):
```
Given the parse function receives a JSON string
When the function processes the string
Then the internal parse tree is correctly formed
```

✅ CORRECT (module-boundary — integration test):
```
Given ARCH-001 (HTTP Router) has routed a valid POST request to ARCH-003 (Data Parser)
When ARCH-003 sends a parsed event payload to ARCH-005 (Event Emitter)
Then ARCH-005 publishes the event with the exact schema defined in the Interface View contract
```

#### 4.2 Scenario Quality Criteria

Every ITS scenario must satisfy:
1. **Boundary precision**: References specific ARCH-NNN module pairs and their interface contracts
2. **Measurable outcomes**: Includes data formats, error codes, timing thresholds
3. **Interface focus**: Tests the SEAM between modules, not internal logic
4. **Reproducibility**: Given conditions specify exact module states and inputs

### 5. Safety-Critical Test Sections (Conditional)

**Only generate these sections if `v-model-config.yml` has `domain` set.**

#### 5.1 SIL/HIL Compatibility (ISO 26262-8 §9 / DO-178C §6.4)

| Test ID | Environment | Hardware Dependencies | Stubbed Components |
|---------|------------|----------------------|-------------------|

- Scenarios executable in Software-in-the-Loop / Hardware-in-the-Loop environments
- Document which physical interfaces are stubbed

#### 5.2 Resource Contention (ISO 26262-6 §7.4.11 / DO-178C §6.3.3)

| Module Pair | Shared Resource | Contention Scenario | Expected Resolution |
|-------------|----------------|--------------------|--------------------|

- Prove modules don't exhaust shared resources during interaction
- Memory, CPU, bus bandwidth, IO channels

### 6. Write Output

Write the complete integration test plan to `{VMODEL_DIR}/integration-test.md` using the template structure. Include:

1. **Header section**: Feature name, branch, date, source reference
2. **Overview**: Brief description of the integration test strategy
3. **ID Schema**: Document the ITP-NNN-X → ARCH-NNN relationship encoding
4. **ISO 29119 Techniques**: Reference section listing applied techniques
5. **Integration Tests**: All ITP test cases with ITS scenarios, organized by ARCH module — each ITP names its technique and target architecture view
6. **Test Harness & Mocking Strategy**: Mock/stub definitions per test case
7. **Safety-Critical Sections**: SIL/HIL and Resource Contention (if domain configured)
8. **Coverage Summary**: Module count, test case count, scenario count, coverage percentage
9. **Technique Distribution**: Interface Contract [N], Data Flow [N], Fault Injection [N], Concurrency [N]
10. **Uncovered Modules**: List of ARCH without ITP (should be empty)

### 7. Report Completion

Display a summary:
- Total test cases (ITP) and scenarios (ITS) generated
- Coverage: X/Y ARCH modules covered (must be 100% or flagged)
- Technique distribution: Interface Contract [N], Data Flow [N], Fault Injection [N], Concurrency [N]
- Language compliance: Confirm zero user-journey phrases AND zero internal-logic phrases in ITS scenarios
- Safety-critical sections included (yes/no, which domain)
- Path to the generated file
- Next step: Recommend running `/speckit.v-model.trace` to build the full traceability matrix

### 8. Test Harness & Mocking Strategy

After writing the test plan, include a "Test Harness & Mocking Strategy" section that describes:
1. Which modules need mocks/stubs for integration testing
2. How interface contracts drive mock behavior
3. Test data management strategy for integration scenarios

## Operating Constraints

### Strict Translation Rules

When generating from `architecture-design.md`:
- **DO NOT** invent test conditions for interfaces not in the architecture design
- **DO NOT** test user journeys — that is the acceptance test plan's job
- **DO NOT** test internal module logic — that is the unit test's job
- **DO** generate at least one ITP per ARCH module
- **DO** generate at least one ITS per ITP test case
- **DO** name the ISO 29119 technique for every test case
- **DO** reference the architecture view each test case targets

### ID Rules

- IDs are **permanent** — once assigned, they are never renumbered or reassigned
- Test case numbering mirrors parent ARCH: `ITP-001-A` tests `ARCH-001`
- Scenario numbering nests under test cases: `ITS-001-A1` is scenario 1 of `ITP-001-A`
- When updating existing tests, preserve all existing IDs and append new ones
- Gaps in numbering are acceptable

### Technique Rules

- Every ITP MUST declare its ISO 29119 technique name
- Every ITP MUST declare which architecture view it targets
- External-facing and internal-facing interface tests MUST be separate ITP entries
- Fault Injection tests MUST reference specific interface contracts from the Interface View
- Concurrency tests MUST reference specific interaction paths from the Process View

### Language Rules

- ITS scenarios use module-boundary, interface-oriented language ONLY
- Zero user-journey phrases AND zero internal-logic phrases allowed
- All outcomes must be measurable (data formats, error codes, timing thresholds)
- Given conditions must reference specific ARCH-NNN module pairs
