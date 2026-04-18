---
description: Generate a three-tier Acceptance Test Plan (Test Cases + BDD Scenarios) with deterministic 100% coverage validation.
handoffs:
  - label: Build Traceability Matrix
    agent: speckit.v-model.trace
    prompt: Build the traceability matrix for these requirements and tests
    send: true
  - label: Back to Requirements
    agent: speckit.v-model.requirements
    prompt: Refine the requirements specification
scripts:
  sh: scripts/bash/setup-v-model.sh --json --require-reqs
  ps: scripts/powershell/setup-v-model.ps1 -Json -RequireReqs
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Generate a **three-tier Acceptance Test Plan** that pairs every requirement (`REQ-NNN`) with:
1. **Test Cases** (`ATP-NNN-X`) — the logical validation conditions
2. **User Scenarios** (`SCN-NNN-X#`) — BDD-style (Given/When/Then) executable test paths

This command enforces the V-Model's core principle: **every development requirement has a simultaneously generated, paired testing artifact**. The output must achieve **100% coverage** — every requirement must have at least one test case, and every test case must have at least one executable scenario.

## Execution Steps

### 1. Setup

Run `{SCRIPT}` from the repository root. The `--require-reqs` flag ensures `requirements.md` exists.

Parse the JSON output for:
- `VMODEL_DIR`: Path to `specs/{feature}/v-model/` directory
- `REQUIREMENTS`: Path to `requirements.md`
- `AVAILABLE_DOCS`: Array of existing documents — check for `"acceptance-plan.md"` to detect existing plan

**Note on script paths**: The helper scripts (`diff-requirements`, `validate-requirement-coverage`) are in the same directory as the setup script. Derive the scripts directory from the `{SCRIPT}` path (i.e., its parent directory).

For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

### 2. Domain Configuration

Load `v-model-config.yml` (if it exists at the repository root).

**If `domain` is set** (e.g., `iso_26262`, `do_178c`, `iec_62304`):
1. Read the command overlay: `commands/overlays/{domain}/acceptance.md`
   - If it exists: note its domain-specific guidance for test case generation — acceptance criteria rigor, structural coverage expectations, and validation methods required by the domain standard
   - If it does not exist: this domain does not extend this command — proceed with base only
2. Read the template overlay: `templates/overlays/{domain}/acceptance-plan-template.md`
   - If it exists: its output sections will be appended after the base template's output — additional sections, mandatory fields, or compliance-specific headings
   - If it does not exist: use the base template only
3. Where the base command has a domain-variant section (marked with "If a domain overlay is loaded, prefer its content"), use the overlay's version instead of the base default (e.g., domain-specific acceptance criteria replace generic criteria)

**If `domain` is empty or absent:**
- Proceed with the base command only
- Do NOT include any safety-critical or domain-specific sections
- Use generic best-practice terminology throughout

### 3. Load Context

1. **Load the template**: Read `templates/acceptance-plan-template.md` from the extension directory.
2. **Read requirements**: Parse `requirements.md` (`REQUIREMENTS` path) to extract all `REQ-NNN` items (all categories: REQ-, REQ-NF-, REQ-IF-, REQ-CN-).
3. **Load existing acceptance plan** (if `AVAILABLE_DOCS` contains `"acceptance-plan.md"`):
   - Read the existing `acceptance-plan.md` to preserve existing ATPs and SCNs.
   - Identify which REQs already have test cases.
   - Identify the existing ATP/SCN IDs to avoid duplicates.

### 4. Detect Incremental Changes (If Updating)

If an existing `acceptance-plan.md` is found, run the diff script to detect what changed:

```bash
{SCRIPTS_DIR}/diff-requirements.sh {VMODEL_DIR}
```
```powershell
{SCRIPTS_DIR}/diff-requirements.ps1 {VMODEL_DIR}
```

Where `{SCRIPTS_DIR}` is the parent directory of the `{SCRIPT}` path (or the equivalent PowerShell directory).

Parse the JSON output for:
- `added`: New REQ IDs that need ATPs/SCNs
- `modified`: Changed REQs whose ATPs/SCNs must be regenerated
- `removed`: Deleted REQs whose ATPs/SCNs should be flagged for removal

**Rules for incremental updates:**
- **Added REQs**: Generate new ATPs and SCNs, appending to the existing file.
- **Modified REQs**: Regenerate ATPs/SCNs for these REQs only. Replace the old sections in-place (match by REQ ID header).
- **Removed REQs**: Add a `[DEPRECATED]` tag to their ATPs/SCNs. Do NOT delete them — the user must confirm removal.
- **Unchanged REQs**: Do NOT touch their ATPs or SCNs. Preserve exactly as-is.
- **Never renumber** existing IDs.

**Lifecycle rules (suspect detection):**
- If a parent REQ has been deprecated (`[DEPRECATED]` tag in `requirements.md`),
  mark all linked ATPs and SCNs as `[SUSPECT — Parent REQ-NNN deprecated]`.
  Use the deprecation type to determine resolution:
  - `[DEPRECATED — Superseded by REQ-NNN]`: Re-parent ATPs/SCNs to the superseding REQ
  - `[DEPRECATED — Withdrawn: <reason>]`: Deprecate the linked ATPs/SCNs
- If a parent REQ has been modified (content changed, same ID), mark linked ATPs
  and SCNs as `[SUSPECT — Parent REQ-NNN modified]`. Regenerate test logic to
  match the updated requirement, then remove the SUSPECT tag.
- **Confirm active**: If review determines the modification does not affect test
  validity, remove the SUSPECT tag without regeneration.

If no existing acceptance plan exists, generate from scratch for all REQs.

### 5. Generate Test Cases and Scenarios (Batched)

Process requirements in **batches of 5** to prevent output token bloat and quality degradation. After each batch, append the results to `acceptance-plan.md`.

For **each requirement** in the current batch:

#### 5a. Generate Test Cases (`ATP-NNN-X`)

Create one or more test cases that together fully validate the requirement. Every test case MUST satisfy **all 4 quality criteria** defined in §6a.

- **ID format**: `ATP-{NNN}-{X}` where `NNN` matches the REQ number and `X` is a letter (A, B, C, ...).
- At minimum, generate:
  - **Happy path** (`-A`): The expected, successful behavior.
  - **Error/edge case** (`-B`, `-C`, ...): Boundary conditions, invalid inputs, failure modes.
- Each test case includes: ID, linked REQ, description, validation condition, and expected result.

#### 5b. Generate User Scenarios (`SCN-NNN-X#`)

For each test case, generate one or more **BDD-style executable scenarios**. Every scenario MUST satisfy **all 4 quality criteria** defined in §6b.

- **ID format**: `SCN-{NNN}-{X}{#}` where `NNN-X` matches the parent ATP and `#` is a number (1, 2, 3, ...).
- Use strict **Given/When/Then** format.
- Scenarios must be **concrete, declarative, and executable**.

#### 5c. Output Structure Per Requirement

```markdown
### Requirement Validation: REQ-{NNN} ({Short Description})

#### Test Case: ATP-{NNN}-A ({Test Name})
**Linked Requirement:** REQ-{NNN}
**Description:** {What is being validated}
**Validation Condition:** {Specific pass/fail condition}
**Expected Result:** {The definitive observable outcome that constitutes "pass"}

* **User Scenario: SCN-{NNN}-A1**
  * **Given** {precondition — explicit state, not assumptions}
  * **When** {single user action — declarative, not imperative}
  * **Then** {observable, verifiable outcome}

* **User Scenario: SCN-{NNN}-A2** *(if applicable)*
  * **Given** {different precondition}
  * **When** {same or different action}
  * **Then** {observable outcome}

#### Test Case: ATP-{NNN}-B ({Error/Edge Case Name})
**Linked Requirement:** REQ-{NNN}
**Description:** {What is being validated}
**Validation Condition:** {Specific pass/fail condition}
**Expected Result:** {The definitive observable outcome that constitutes "pass"}

* **User Scenario: SCN-{NNN}-B1**
  * **Given** {precondition}
  * **When** {invalid action or boundary condition}
  * **Then** {expected error handling behavior}
```

### 6. Quality Criteria (Mandatory — IEEE 1012 / ISO 25010)

#### 6a. Test Case Quality Criteria (ATP Tier)

Every test case MUST satisfy ALL 4 criteria. If a test case fails any criterion, rewrite it before including it.

**Criterion 1: Traceable**
The test case maps directly to a single requirement (`REQ-NNN`). If a test case doesn't trace back to a requirement, it is testing undefined behavior — this fails compliance audits. The `ATP-NNN-X` ID schema enforces this structurally.

**Criterion 2: Independent (Isolated)**
A test case MUST be able to run on its own, in any order. It cannot depend on the state left behind by a previous test case. The test must take responsibility for its own preconditions.

- ❌ "Verify the user can log out." (Implies login was performed by a previous test)
- ✅ "Verify a logged-in user can successfully log out and invalidate their session token." (Owns its preconditions)

**Check**: Can this test run first, last, or in the middle of the suite and still pass? If not, rewrite.

**Criterion 3: Repeatable (Deterministic)**
Running the test 100 times on an unchanged system MUST yield the exact same result 100 times. Eliminate variables like current time, live external data, non-deterministic ordering, or fluctuating database state.

- ❌ "Search for 'shoes' and verify 10 results are returned." (Fails when the database adds an 11th result)
- ✅ "Search for a specific SKU 'SHOE-123' and verify exactly 1 result matching the SKU is returned."

**Check**: Would this test produce a different result tomorrow without code changes? If yes, rewrite.

**Criterion 4: Clear Expected Result**
The test MUST have a **definitive, observable pass/fail state**. "It works" or "the system responds correctly" are NOT expected results.

- ❌ Expected result: "The feature works as expected."
- ✅ Expected result: "The system returns HTTP 200 with a JSON body containing `{"status": "success", "user_id": 42}`."

**Check**: Can a tester (human or automated) objectively determine pass vs. fail with no judgment calls? If not, rewrite.

#### 6b. Scenario Quality Criteria (SCN Tier / BDD)

Every scenario MUST satisfy ALL 4 criteria. These prevent the AI from writing brittle, untestable automation scripts.

**Criterion 1: Declarative, Not Imperative**
Scenarios describe **behavior and business intent**, not UI mechanics. Imperative scenarios break every time a developer changes a button color, CSS class, or page layout.

- ❌ (Imperative/Brittle):
  - `Given` I am on "/login.html"
  - `When` I type "user" into the field with ID "username-input"
  - `And` I click the blue button at x=150, y=300
- ✅ (Declarative/Resilient):
  - `Given` an existing user navigates to the login portal
  - `When` the user authenticates with valid credentials
  - `Then` the user is redirected to their secure dashboard

**Check**: Does this scenario reference specific HTML elements, CSS selectors, or pixel coordinates? If yes, rewrite at the behavioral level.

**Criterion 2: Single Action (The "One When" Rule)**
A scenario tests **one behavior** at a time. There should be only **one `When` statement** (possibly with `And` qualifiers for the same atomic action). If you have multiple unrelated `When`s, split into separate `SCN` blocks.

- ❌ `When` the user updates their profile `And` the user deletes their account. (Two separate behaviors)
- ✅ Split into `SCN-NNN-A1` (profile update) and `SCN-NNN-A2` (account deletion).

**Check**: Does the `When` section describe more than one independent user action? If yes, split.

**Criterion 3: Strict State Preconditions (`Given`)**
The `Given` step MUST explicitly set the stage. It assumes nothing about prior state.

- ❌ `Given` the user wants to buy an item. (Vague, subjective — what is the actual system state?)
- ✅ `Given` the user has an active session `And` their shopping cart contains 1 item with SKU "ITEM-001" priced at $29.99.

**Check**: Does the `Given` fully describe the system state needed for this test? Could a test automation framework set up this state from the `Given` alone? If not, add missing preconditions.

**Criterion 4: Observable Outcomes (`Then`)**
The outcome MUST be something the system can actually verify — a database state, an API response, specific UI text, a status code, or a measurable change.

- ❌ `Then` the system processes the payment quickly. (Not observable or measurable)
- ✅ `Then` the system returns HTTP 200 `And` the payment record in the database has status "Settled".

**Check**: Can an automated test assert on this outcome with zero human judgment? If not, rewrite with a concrete, observable condition.

#### 6c. Validation Completeness (IEEE 1012:2016 V&V)

IEEE 1012:2016 establishes that acceptance testing is a **validation** activity (not just verification) — it confirms the system fulfills its intended use and stakeholder needs, not merely that it conforms to specifications. Apply these V&V principles:

1. **Entry criteria**: Before generating acceptance tests, confirm that requirements.md is baselined and approved. If requirements are still in draft, flag this as a validation risk.
2. **Validation vs. verification distinction**: Acceptance tests validate that the system meets stakeholder needs (the right system), not just that it implements the specification correctly (the system right). At least one SCN per REQ should test from the stakeholder's perspective.
3. **V&V traceability**: Every ATP must trace to its parent REQ (already enforced by ID schema), AND the test approach must be appropriate for the requirement type — functional requirements need behavioral validation, non-functional requirements need measurement-based validation.
4. **Exit criteria**: Acceptance testing is complete when (a) 100% of active requirements have ATP coverage, (b) all ATP quality criteria are met, and (c) no unresolved [SUSPECT] items remain.

#### 6d. Quality-in-Use Coverage (ISO/IEC 25010:2023)

For acceptance testing, verify that the test plan adequately covers **quality-in-use** characteristics where the source requirements imply them. This is NOT a mandate to test every characteristic — only those relevant to the feature:

| Quality-in-Use Characteristic | When to Include | Example SCN Focus |
|---|---|---|
| **Effectiveness** | Feature has task completion goals | Verify user achieves intended outcome |
| **Efficiency** | Feature has time/effort constraints | Verify task completion within time bounds |
| **Satisfaction** | Feature has explicit UX requirements | Verify user experience meets criteria |
| **Freedom from Risk** | Feature has safety or financial risk implications | Verify harm prevention and risk mitigation |
| **Context Coverage** | Feature must work across environments or user populations | Verify behavior across specified contexts |

**If a domain overlay is loaded**, additional acceptance criteria specific to the domain standard are applied (e.g., ASIL-dependent verification methods for ISO 26262, structural coverage by DAL for DO-178C). These supplement, not replace, the base quality criteria.

### 7. Validate Coverage (Deterministic)

After generating all batches, run the coverage validation script:

```bash
{SCRIPTS_DIR}/validate-requirement-coverage.sh --json {VMODEL_DIR}
```
```powershell
{SCRIPTS_DIR}/validate-requirement-coverage.ps1 -Json {VMODEL_DIR}
```

Parse the JSON output for:
- `has_gaps`: Whether any coverage gaps exist
- `reqs_without_atp`: List of REQ IDs missing test cases
- `atps_without_scn`: List of ATP IDs missing scenarios
- `orphaned_atps`: ATPs referencing non-existent REQs
- `req_coverage_pct`: Requirement-to-test-case coverage percentage
- `atp_coverage_pct`: Test-case-to-scenario coverage percentage

**Coverage gate** (MANDATORY):
- If `has_gaps` is true: You MUST generate the missing items. Use the gap report to target exactly the missing REQs/ATPs. Do NOT regenerate items that already exist.
- Re-run the validation script after generating missing items.
- Repeat until `has_gaps` is false (maximum 3 iterations).
- If coverage < 100% after 3 iterations: Report the remaining gaps to the user and flag them in the document with `[COVERAGE GAP: missing ATP/SCN]`.

### 8. Write Coverage Summary

Append a coverage summary section to the end of `acceptance-plan.md`:

```markdown
---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Requirements | {N} |
| Total Test Cases (ATP) | {N} |
| Total Scenarios (SCN) | {N} |
| REQ → ATP Coverage | {N}% |
| ATP → SCN Coverage | {N}% |

**Validation Status**: ✅ Full Coverage / ❌ Gaps Remaining (see flagged items)
**Generated**: {DATE}
**Validated by**: `validate-requirement-coverage.sh` (deterministic)
```

### 9. Report Completion

Display a summary:
- Total ATPs and SCNs generated
- Coverage percentage at each tier
- Any gaps or issues that need attention
- Path to the generated file
- Next step: Recommend running `/speckit.v-model.trace` to build the traceability matrix

If processing was batched, remind the user that all batches are complete and the full file has been assembled.

## Operating Constraints

### Three-Tier ID Schema

The ID encodes its full lineage — no separate mapping needed:
- `SCN-001-A1` → belongs to `ATP-001-A` → validates `REQ-001`
- `SCN-NF-001-B2` → belongs to `ATP-NF-001-B` → validates `REQ-NF-001`

### Append-Only Behavior

- **Never overwrite** existing ATPs or SCNs for unchanged requirements
- **Never renumber** existing IDs
- When adding new items, append after existing content
- When modifying items for changed REQs, replace in-place by matching the `### Requirement Validation: REQ-NNN` header

### Batching Strategy

- Process 5 requirements per batch to prevent token limit issues
- After each batch, write/append results to `acceptance-plan.md`
- If there are remaining requirements, prompt: "Batch {N} complete ({processed}/{total} requirements). Type 'continue' to process the next batch."
- The coverage validation runs only after ALL batches are complete

---

## Governing Standards

This command is governed by the following standards for acceptance test design and validation:

| Standard | Scope | How Used |
|---|---|---|
| **IEEE 1012:2016** | System, software, and hardware V&V | Primary V&V framework: entry/exit criteria, validation vs. verification distinction, V&V traceability (Step 6c) |
| **ISO/IEC 25010:2023** | Systems and software quality models | Quality-in-use characteristics for acceptance criteria coverage (Step 6d) |
| **ISO/IEC/IEEE 29119-4:2021** | Test design techniques | BDD scenario structure, test case design patterns (Step 5) |

> **Note:** If a domain overlay is loaded (Step 2), additional domain-specific standards are applied alongside these base standards (e.g., ISO 26262 Part 6 §6.9 Table 11 for automotive ASIL-dependent verification methods, DO-178C §6.4.2 Table A-7 for aerospace structural coverage by DAL, IEC 62304 §5.7 for medical device safety class–dependent test completeness).
