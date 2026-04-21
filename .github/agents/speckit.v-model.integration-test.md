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

4. **Load existing integration tests** (if `AVAILABLE_DOCS` contains `"integration-test.md"`):
   - Read the existing `integration-test.md` to preserve existing ITP/ITS IDs and content
   - Identify the highest existing ITP number to continue the sequence
   - New test cases append after existing ones — **never renumber**

### 2a. Domain Configuration

Load `v-model-config.yml` (if it exists at the repository root).

**If `domain` is set** (e.g., `iso_26262`, `do_178c`, `iec_62304`):
1. Read the command overlay: `commands/overlays/{domain}/integration-test.md`
   - If it exists: note the safety-critical integration test sections (e.g., SIL/HIL compatibility, resource contention verification)
   - If it does not exist: this domain does not extend this command — proceed with base only
2. Where the base command has a domain-variant section (marked with "If a domain overlay is loaded, prefer its content"), use the overlay's version instead of the base default

**If `domain` is empty or absent:**
- Proceed with the base command only
- Use generic best-practice terminology throughout
- Do NOT include any safety-critical or domain-specific regulatory references

### 3. Lifecycle Rules (When Evolving Existing Artifacts)

When an existing `integration-test.md` is loaded (step 2.4), apply these rules
before generating new content:

1. **Never delete an ID** — mark as `[DEPRECATED]`
2. **Deprecation types:**
   - `[DEPRECATED — Superseded by ITP-NNN]`: Replaced by a new test case
   - `[DEPRECATED — Withdrawn: <reason>]`: Removed entirely with justification
3. **Suspect detection from parent ARCH:** If a parent ARCH (in
   `architecture-design.md`) is deprecated or modified, mark each ITP/ITS that
   traces to it as `[SUSPECT — Parent ARCH-NNN {deprecated|modified}]`.
4. **Suspect resolution:** For each suspect ITP/ITS:
   - **Re-parent** to the superseding ARCH (if module continues under a new ID)
   - **Deprecate** (if the architecture module is withdrawn)
   - **Confirm active** (if still valid despite the parent change — remove the SUSPECT tag)
5. **Modified test cases:** Update content in-place, preserve the original ITP/ITS ID.

If no existing `integration-test.md` is found, skip this step entirely — all
test cases are new.

### 4. Generate Integration Test Cases

For each `ARCH-NNN` module in the Logical View, generate one or more test cases using the appropriate ISO 29119 technique based on which architecture view the module's boundaries target.

#### 4.1 Technique Selection

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

#### 4.2 Interface Contract Testing

For each ARCH↔ARCH interface defined in the Interface View:

1. **Consumer-provider pair**: Test that Module A (consumer) receives the exact contract Module B (provider) promises
2. **Valid contract**: Expected inputs → expected outputs per Interface View table
3. **Contract violation**: Provider returns unexpected format → consumer detects and handles
4. **Missing fields**: Optional vs required field handling across module boundaries

#### 4.3 Data Flow Testing

For each data transformation chain in the Data Flow View:

1. **End-to-end chain**: Inject data at first module, verify correct format at final module
2. **Intermediate verification**: Check format at each transformation stage matches Data Flow View
3. **Invalid data propagation**: Bad data injected at stage 1 → verify detection point in the chain
4. **Empty/null data**: Verify chain handles empty inputs without corruption

#### 4.4 Interface Fault Injection

For each ARCH module's error contracts from the Interface View:

1. **Malformed payloads**: Send invalid data types, truncated messages, oversized inputs
2. **Timeout scenarios**: Module B doesn't respond → Module A handles gracefully
3. **Partial responses**: Incomplete data from provider → consumer detects
4. **Error propagation**: Verify failure in one module does NOT cascade to unrelated modules
5. **Graceful degradation**: System remains operational with reduced capability

#### 4.5 Concurrency & Race Condition Testing

For each concurrent interaction in the Process View:

1. **Simultaneous access**: Two modules accessing same resource → correct lock handling
2. **Queue ordering**: Messages arrive out-of-order → correct reordering
3. **Deadlock avoidance**: Circular dependency scenarios → no deadlock
4. **Resource starvation**: High-throughput scenario → fair resource allocation

### 5. Generate Integration Test Scenarios (BDD)

For each test case (`ITP-NNN-X`), generate one or more executable scenarios (`ITS-NNN-X#`) in Given/When/Then format.

#### 5.1 Module-Boundary Language Mandate

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

#### 5.2 Scenario Quality Criteria

Every ITS scenario must satisfy:
1. **Boundary precision**: References specific ARCH-NNN module pairs and their interface contracts
2. **Measurable outcomes**: Includes data formats, error codes, timing thresholds
3. **Interface focus**: Tests the SEAM between modules, not internal logic
4. **Reproducibility**: Given conditions specify exact module states and inputs

### 6. Safety-Critical Integration Test Sections (Conditional)

**If a domain overlay is loaded (Step 2a), include the overlay's safety-critical integration test sections here.** The overlay provides domain-specific content such as SIL/HIL compatibility requirements, resource contention verification, and other domain-mandated integration test criteria — with the appropriate standard references and table structures for the configured domain.

If no domain overlay is loaded, skip this section entirely.

### 7. V&V Coverage Gate (IEEE 1012:2016)

Before writing the final output, verify IEEE 1012:2016 V&V completeness for the integration test layer.

#### 7.1 Architecture Module–to–V&V Activity Coverage

IEEE 1012:2016 §5.6 requires every architecture module interface to be exercised by at least one V&V activity. At integration test level, confirm:

1. **Every `ARCH-NNN`** module has at least one `ITP-NNN-X` test case that exercises its integration boundary
2. **Every inter-module interface** in the Interface View has at least one ITP targeting its contract
3. **No `ARCH-NNN`** is left without any V&V activity — flag gaps as: `[V&V GAP: ARCH-NNN has no integration-level V&V activity — IEEE 1012:2016 §5.6]`

#### 7.2 Entry Criteria Check (IEEE 1012:2016 §5.6.1)

Confirm these entry criteria before the test plan is considered complete:

- `architecture-design.md` is current and has been peer-reviewed
- Every `ARCH-NNN` module has at least one `ITP-NNN-X` test case (100% forward coverage)
- All `ITP-NNN-X` test cases have at least one `ITS-NNN-X#` executable scenario
- V&V gap list is empty (all integration boundaries covered)

List any unmet criteria in the Report Completion summary.

### 8. Write Output

Write the complete integration test plan to `{VMODEL_DIR}/integration-test.md` using the template structure. Include:

1. **Header section**: Feature name, branch, date, source reference
2. **Overview**: Brief description of the integration test strategy
3. **ID Schema**: Document the ITP-NNN-X → ARCH-NNN relationship encoding
4. **ISO 29119 Techniques**: Reference section listing applied techniques
5. **Integration Tests**: All ITP test cases with ITS scenarios, organized by ARCH module — each ITP names its technique and target architecture view
6. **Test Harness & Mocking Strategy**: Mock/stub definitions per test case
7. **Safety-Critical Sections**: Domain-specific integration test sections (if overlay loaded in Step 2a)
8. **V&V Coverage (IEEE 1012:2016)**: ARCH module-to-V&V activity mapping with any flagged gaps (from Step 7)
9. **Coverage Summary**: Module count, test case count, scenario count, coverage percentage
10. **Technique Distribution**: Interface Contract [N], Data Flow [N], Fault Injection [N], Concurrency [N]
11. **Uncovered Modules**: List of ARCH without ITP (should be empty)

### 9. Report Completion

Display a summary:
- Total test cases (ITP) and scenarios (ITS) generated
- Coverage: X/Y ARCH modules covered (must be 100% or flagged)
- Technique distribution: Interface Contract [N], Data Flow [N], Fault Injection [N], Concurrency [N]
- Language compliance: Confirm zero user-journey phrases AND zero internal-logic phrases in ITS scenarios
- Safety-critical sections included (yes/no, overlay loaded yes/no)
- Path to the generated file
- Next step: Recommend running `/speckit.v-model.trace` to build the full traceability matrix

### 10. Test Harness & Mocking Strategy

After writing the test plan, include a "Test Harness & Mocking Strategy" section that describes:
1. Which modules need mocks/stubs for integration testing
2. How interface contracts drive mock behavior
3. Test data management strategy for integration scenarios

## Governing Standards

This command is governed by the following standards for integration testing:

| Standard | Full Name | Role in this Command |
|----------|-----------|----------------------|
| **ISO/IEC/IEEE 29119-4:2021** | Software and Systems Engineering — Software Testing — Part 4: Test Techniques | Primary test technique standard: defines the four mandatory integration test techniques (Interface Contract Testing, Data Flow Testing, Fault Injection, Concurrency Testing) and their application criteria for architecture module boundaries |
| **IEEE 1012:2016** | IEEE Standard for System, Software, and Hardware Verification and Validation | V&V governance: ensures every architecture module interface is exercised by at least one V&V activity (Step 7 — V&V Coverage Gate); distinguishes integration verification ("module interfaces built right") from system validation; prescribes entry/exit criteria for integration test activities (§5.6) |

> **Domain extensions:** If a domain overlay is loaded (Step 2a), additional structural coverage requirements and interface test criteria from the applicable standard (e.g., ISO 26262-6 §9.4.4 interface correctness verification by ASIL, DO-178C §6.4.4.2 structural coverage at component integration level) are applied alongside these best-practice standards.

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
