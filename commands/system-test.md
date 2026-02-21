---
description: Generate ISO 29119-compliant system test cases with named techniques for every system component in the design.
handoffs:
  - label: Build Traceability Matrix
    agent: speckit.v-model.trace
    prompt: Build the full traceability matrix including system-level coverage
    send: true
  - label: Back to System Design
    agent: speckit.v-model.system-design
    prompt: Review or update the system design
scripts:
  sh: scripts/bash/setup-v-model.sh --json --require-reqs --require-system-design
  ps: scripts/powershell/setup-v-model.ps1 -Json -RequireReqs -RequireSystemDesign
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Generate an ISO 29119-compliant System Test Plan where **every system component** (`SYS-NNN`) from `system-design.md` has at least one test case (`STP-NNN-X`) and every test case has at least one executable system scenario (`STS-NNN-X#`). Unlike acceptance tests (which verify user needs), system tests verify that the **architecture works as designed** — they target IEEE 1016 design views using named ISO 29119 techniques.

## Execution Steps

### 1. Setup

Run `{SCRIPT}` from the repository root and parse the JSON output.

The script returns JSON with these keys:
- `VMODEL_DIR`: Path to `specs/{feature}/v-model/` directory
- `FEATURE_DIR`: Path to `specs/{feature}/` directory
- `BRANCH`: Current branch name
- `REQUIREMENTS`: Path to `requirements.md` (MUST exist — script uses `--require-reqs`)
- `SYSTEM_DESIGN`: Path to `system-design.md` (MUST exist — script uses `--require-system-design`)
- `AVAILABLE_DOCS`: Array of documents that currently exist

For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

### 2. Load Context

1. **Load the template**: Read `templates/system-test-template.md` from the extension directory to understand the required output structure.

2. **Load system design**: Read `system-design.md` from the `VMODEL_DIR` path.
   - If `system-design.md` does NOT exist: ERROR — "System design not found. Run `/speckit.v-model.system-design` first."
   - Extract all `SYS-NNN` identifiers from the Decomposition View
   - Extract the Dependency View (feeds Fault Injection tests)
   - Extract the Interface View (feeds Interface Contract tests)
   - Extract the Data Design View (feeds Boundary Value tests)
   - Note the total SYS count — every SYS must have at least one STP

3. **Load requirements**: Read `requirements.md` from the `REQUIREMENTS` path for context on what each requirement demands. This helps generate meaningful test conditions.

4. **Load v-model-config.yml** (if it exists at the repository root):
   - If `domain` is set to `iso_26262`, `do_178c`, or `iec_62304`: Enable safety-critical test sections (MC/DC, WCET)
   - If absent or `domain` is empty: Skip safety-critical test sections entirely

5. **Load existing system tests** (if `AVAILABLE_DOCS` contains `"system-test.md"`):
   - Read the existing `system-test.md` to preserve existing STP/STS IDs and content
   - Identify the highest existing STP number to continue the sequence
   - New test cases append after existing ones — **never renumber**

### 3. Generate System Test Cases

For each `SYS-NNN` component in the Decomposition View, generate one or more test cases using the appropriate ISO 29119 technique based on which design view the component primarily targets.

#### 3.1 Technique Selection

Each test case MUST name its ISO 29119 technique explicitly. Select based on the design view being verified:

| Design View | Primary Technique | What It Tests |
|-------------|------------------|---------------|
| Interface View | **Interface Contract Testing** | API contracts, protocol compliance, error responses |
| Data Design View | **Boundary Value Analysis** | Data limits, thresholds, ranges |
| Data Design View | **Equivalence Partitioning** | Representative data classes |
| Dependency View | **Fault Injection** | Failure propagation, graceful degradation |

**Rules**:
- Every SYS component gets at least one test case from its most relevant design view
- Components appearing in multiple views should have test cases from each view
- A single SYS may have Interface Contract + Boundary Value + Fault Injection test cases

#### 3.2 Interface Contract Testing

For components with entries in the Interface View:

1. **External interfaces**: Test protocol compliance, authentication, input validation, error responses
   - Valid input → expected output
   - Malformed input → appropriate error code
   - Missing authentication → rejected with 401/403
   - Timeout → graceful timeout response

2. **Internal interfaces**: Test contract adherence, data format correctness, failure propagation
   - Valid contract call → correct response format
   - Component unavailable → caller handles gracefully
   - Data format violation → caller detects and reports

**CRITICAL DISTINCTION**: External and internal interface tests are SEPARATE test cases. Auditors expect this distinction to be explicit.

#### 3.3 Boundary Value Analysis

For components with entries in the Data Design View:

1. Test at **exact boundaries**: minimum, minimum+1, maximum-1, maximum
2. Test **one beyond boundaries**: minimum-1 (below), maximum+1 (above)
3. Test **empty/null** conditions where applicable
4. Test **maximum capacity**: largest expected dataset size

#### 3.4 Fault Injection / Negative Testing

For components with entries in the Dependency View:

1. For each dependency relationship, test: **What happens to Source if Target fails?**
2. Test failure modes: unavailable, timeout, corrupted response, partial response
3. Verify isolation: failure in one component does NOT cascade to unrelated components
4. Verify degradation: system remains operational with reduced capability

### 4. Generate System Test Scenarios (BDD)

For each test case (`STP-NNN-X`), generate one or more executable scenarios (`STS-NNN-X#`) in Given/When/Then format.

#### 4.1 Technical Language Mandate

System test scenarios MUST use **technical, component-oriented language**. They verify architectural behavior, not user journeys.

**PROHIBITED phrases** (these belong in acceptance scenarios, not system tests):
- "the user clicks"
- "the user sees"
- "the user navigates"
- "the user enters"
- "the user selects"
- "the user receives"
- "the dashboard shows"
- "the form displays"

**REQUIRED language style**:
- "the [component name] receives [input]"
- "the [component name] returns [output]"
- "the [component name] raises [error/exception]"
- "the [service] processes [data] within [threshold]"
- "the [module] transitions to [state]"
- "the connection to [dependency] is severed"

**Examples**:

❌ WRONG (user-centric — belongs in acceptance test):
```
Given a logged-in user on the dashboard
When the user clicks "Export Report"
Then the user sees a download dialog
```

✅ CORRECT (component-centric — system test):
```
Given the Report Generator service has a valid dataset of 500 records
When the export API receives a GET request to /api/reports/export?format=csv
Then the service returns a 200 response with Content-Type: text/csv within 3 seconds
```

#### 4.2 Scenario Quality Criteria

Every STS scenario must satisfy:
1. **Technical precision**: References specific components, APIs, data formats, or error codes
2. **Measurable outcomes**: Includes thresholds, response codes, or state transitions (not subjective judgments)
3. **Isolation**: Tests one component behavior per scenario (not end-to-end user flows)
4. **Reproducibility**: Given conditions are specific enough to reproduce deterministically

### 5. Safety-Critical Test Sections (Conditional)

**Only generate these sections if `v-model-config.yml` has `domain` set.**

#### 5.1 Structural Coverage (DO-178C §6.4.4.2 / ISO 26262-6 §9.4.5)

| Component | Coverage Target | Technique | Rationale |
|-----------|----------------|-----------|-----------|

- Specify MC/DC (Modified Condition/Decision Coverage) targets per component
- Map to the ASIL/DAL level from the system design's FFI section

#### 5.2 Resource Usage Testing (DO-178C §6.3.4 / ISO 26262-6 §9.4.4)

| Component | Resource | Measurement | Threshold | Verification Method |
|-----------|----------|-------------|-----------|---------------------|

- WCET (Worst Case Execution Time) per critical component
- Maximum stack depth
- Heap usage limits

### 6. Write Output

Write the complete system test plan to `{VMODEL_DIR}/system-test.md` using the template structure. Include:

1. **Header section**: Feature name, branch, date, source reference
2. **Overview**: Brief description of the system test strategy
3. **ID Schema**: Document the STP-NNN-X → SYS-NNN relationship encoding
4. **ISO 29119 Techniques**: Reference section listing applied techniques
5. **System Tests**: All STP test cases with STS scenarios, organized by SYS component
6. **Safety-Critical Sections**: MC/DC and WCET (if domain configured)
7. **Coverage Summary**: Component count, test case count, scenario count, coverage percentage
8. **Uncovered Components**: List of SYS without STP (should be empty)

### 7. Report Completion

Display a summary:
- Total test cases (STP) and scenarios (STS) generated
- Coverage: X/Y SYS components covered (must be 100% or flagged)
- Technique distribution: Interface Contract [N], Boundary Value [N], Fault Injection [N], Equivalence Partitioning [N]
- Language compliance: Confirm zero user-journey phrases in STS scenarios
- Safety-critical sections included (yes/no, which domain)
- Path to the generated file
- Next step: Recommend running `/speckit.v-model.trace` to build the full traceability matrix

## Operating Constraints

### Strict Translation Rules

When generating from `system-design.md`:
- **DO NOT** invent test conditions for capabilities not in the design
- **DO NOT** test user journeys — that is the acceptance test plan's job
- **DO** generate at least one STP per SYS component
- **DO** generate at least one STS per STP test case
- **DO** name the ISO 29119 technique for every test case
- **DO** reference the IEEE 1016 design view each test case targets

### ID Rules

- IDs are **permanent** — once assigned, they are never renumbered or reassigned
- Test case numbering mirrors parent SYS: `STP-001-A` tests `SYS-001`
- Scenario numbering nests under test cases: `STS-001-A1` is scenario 1 of `STP-001-A`
- When updating existing tests, preserve all existing IDs and append new ones
- Gaps in numbering are acceptable

### Technique Rules

- Every STP MUST declare its ISO 29119 technique name
- Every STP MUST declare which IEEE 1016 view it targets
- A single SYS may have test cases from multiple techniques
- External and internal interface tests MUST be separate STP entries
- Fault Injection tests MUST reference specific dependency paths from the Dependency View

### Language Rules

- STS scenarios use technical, component-oriented language ONLY
- Zero user-journey phrases allowed
- All outcomes must be measurable (response codes, thresholds, state transitions)
- Given conditions must be specific enough to reproduce
