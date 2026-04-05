---
description: AI-powered stateless linter for any V-Model artifact — evaluates against standards-based criteria and produces a structured review with PRF-{ARTIFACT}-NNN findings.
handoffs:
  - label: Run CI Check
    agent: speckit.v-model.trace
    prompt: Validate the peer review findings and traceability
    send: true
  - label: Review Another Artifact
    agent: speckit.v-model.peer-review
    prompt: Review another V-Model artifact
scripts:
  sh: scripts/bash/setup-v-model.sh --json
  ps: scripts/powershell/setup-v-model.ps1 -Json
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Act as an **automated first-pass peer reviewer** for a single V-Model artifact. Read the artifact, evaluate it against standards-based quality criteria specific to its type, and produce a structured review report with findings. The review is **stateless** (regenerated from scratch each run), **advisory-only** (findings do not participate in the traceability chain), and **CI-hookable** (a companion parser script reads the output and returns exit codes).

This command operates like **ESLint or SonarQube for V-Model artifacts** — if a finding is in the report, it is a current problem; if the engineer fixes the issue and re-runs, the finding disappears. There is no `Status: Open` field. Git diff shows what changed between reviews.

## Execution Steps

### 1. Setup

Run `{SCRIPT}` from the repository root and parse the JSON output.

The script returns JSON with these keys:
- `VMODEL_DIR`: Path to `specs/{feature}/v-model/` directory
- `FEATURE_DIR`: Path to `specs/{feature}/` directory
- `BRANCH`: Current branch name
- `AVAILABLE_DOCS`: Array of documents that currently exist

For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

### 2. Identify Target Artifact

1. **Parse `$ARGUMENTS`**: The user specifies a single artifact file name (e.g., `requirements.md`, `system-design.md`, `hazard-analysis.md`).

2. **Resolve the file path**: Look for the artifact in `VMODEL_DIR`. If the file does not exist, check if it exists at the literal path provided by the user.

3. **Validate the artifact type**: The file name MUST match one of the 9 supported types:
   - `requirements.md`
   - `acceptance-plan.md`
   - `system-design.md`
   - `system-test.md`
   - `architecture-design.md`
   - `integration-test.md`
   - `module-design.md`
   - `unit-test.md`
   - `hazard-analysis.md`

   If the file name does not match any supported type, inform the user:
   > "peer-review supports these artifact types: requirements.md, acceptance-plan.md, system-design.md, system-test.md, architecture-design.md, integration-test.md, module-design.md, unit-test.md, hazard-analysis.md."

4. **Determine the artifact abbreviation** for PRF IDs:

   | Artifact File | Abbreviation | Governing Standard |
   |--------------|-------------|-------------------|
   | `requirements.md` | REQ | INCOSE Guide for Writing Requirements |
   | `acceptance-plan.md` | ATP | ISO 29119 |
   | `system-design.md` | SYS | IEEE 1016 |
   | `system-test.md` | STP | ISO 29119 |
   | `architecture-design.md` | ARCH | IEEE 42010 / Kruchten 4+1 |
   | `integration-test.md` | ITP | ISO 29119-4 |
   | `module-design.md` | MOD | DO-178C / ISO 26262 |
   | `unit-test.md` | UTP | ISO 29119-4 |
   | `hazard-analysis.md` | HAZ | ISO 14971 / ISO 26262 |

### 3. Load Context

1. **Load the template**: Read `templates/peer-review-template.md` from the extension directory.

2. **Load the artifact**: Read the target artifact file completely.

3. **Count items**: Count the primary items in the artifact:
   - `requirements.md`: Count `REQ-NNN` IDs (all categories)
   - `acceptance-plan.md`: Count `ATP-NNN` IDs
   - `system-design.md`: Count `SYS-NNN` IDs
   - `system-test.md`: Count `STP-NNN` IDs
   - `architecture-design.md`: Count `ARCH-NNN` IDs
   - `integration-test.md`: Count `ITP-NNN` IDs
   - `module-design.md`: Count `MOD-NNN` IDs
   - `unit-test.md`: Count `UTP-NNN` IDs
   - `hazard-analysis.md`: Count `HAZ-NNN` IDs

### 4. Evaluate Against Standards-Based Criteria

Apply the review criteria specific to the artifact type. Each criterion that is violated produces one finding.

#### 4.1 Requirements (`requirements.md`) — INCOSE

Check each requirement for:
- **Atomicity**: Does the requirement describe exactly one function? Flag compound statements with "and", "or", "but", "unless".
- **Testability**: Can a definitive pass/fail test be designed? Flag subjective language: "user-friendly", "fast", "robust", "seamless", "intuitive", "efficient", "reasonable", "significant", "adequate", "minimal", "approximately", "scalable", "secure", "reliable", "flexible".
- **Unambiguity**: Is there exactly one interpretation? Flag vague quantifiers ("multiple", "several", "many", "few").
- **Completeness**: Are all conditions, thresholds, and states specified? Flag "TBD", missing priority, or incomplete descriptions.
- **Priority Assignment**: Does every requirement have P1/P2/P3?
- **No Subjective Language**: Are all banned words from the INCOSE list absent?

#### 4.2 System Design (`system-design.md`) — IEEE 1016

Check for:
- **4 Mandatory Views**: Decomposition (§5.1), Dependency (§5.2), Interface (§5.3), Data Design (§5.4) — all present?
- **REQ Traceability**: Does every SYS trace to at least 1 REQ?
- **Interface Completeness**: Do all interfaces specify error handling/responses?
- **Derived Requirements**: Are any SYS components not traceable to a REQ? If so, are they flagged as derived?

#### 4.3 Architecture Design (`architecture-design.md`) — IEEE 42010

Check for:
- **4+1 Views**: Logical, Process, Physical, Development, (+1 Scenarios) — all populated?
- **Cross-Cutting Justification**: Are CROSS-CUTTING modules justified with rationale?
- **Interface Definitions**: Complete for all ARCH modules?
- **SYS Traceability**: Does every ARCH trace to at least 1 SYS?

#### 4.4 System Test (`system-test.md`) — ISO 29119

Check for:
- **Named Techniques**: Are ISO 29119 techniques explicitly named (Equivalence Partitioning, Boundary Value Analysis, State Transition, Error Guessing)?
- **No User-Journey Language**: Are test scenarios free of "As a user, I want..." language?
- **Scenario Independence**: Can each test scenario execute independently (no shared state)?
- **SYS Coverage**: Does every SYS have at least one STP?

#### 4.5 Integration Test (`integration-test.md`) — ISO 29119-4

Check for:
- **CDCT Technique**: Is Consumer-Driven Contract Testing present?
- **Fault Injection**: Are fault injection scenarios present?
- **Interface Coverage**: Is every ARCH module's interface tested?
- **ARCH Coverage**: Does every ARCH have at least one ITP?

#### 4.6 Module Design (`module-design.md`) — DO-178C / ISO 26262

Check for:
- **4 Mandatory Views**: Algorithmic/Logic, State Machine (if applicable), Internal Data Structures, Error Handling — present for each MOD?
- **Algorithm Specifications**: Are algorithms described (pseudocode or prose)?
- **Error Handling**: Is error handling explicitly defined for each MOD?
- **ARCH Traceability**: Does every MOD trace to at least 1 ARCH?

#### 4.7 Unit Test (`unit-test.md`) — ISO 29119-4

Check for:
- **5 Techniques**: Statement Coverage, Branch Coverage, Boundary Value Analysis, Error Guessing, Equivalence Partitioning — are at least 3 present per MOD?
- **Mock Registry**: Is a mock registry defined (if applicable)?
- **Boundary Values**: Are boundary values explicit (not implicit)?
- **MOD Coverage**: Does every MOD have at least one UTP?

#### 4.8 Hazard Analysis (`hazard-analysis.md`) — ISO 14971 / ISO 26262

Check for:
- **Severity Justification**: Are severity classifications reasonable given the failure mode?
- **Mitigation Completeness**: Does every HAZ have at least one mitigation referencing REQ-NNN or SYS-NNN?
- **Operational State Coverage**: Are failure modes analyzed across operational states?
- **Residual Risk Assessment**: Is residual risk assessed for every hazard?
- **SYS Coverage**: Does every SYS have at least one HAZ?

#### 4.9 Acceptance Plan (`acceptance-plan.md`) — ISO 29119

Check for:
- **BDD Format**: Are scenarios in proper Given/When/Then format?
- **Measurable Validation**: Are validation conditions measurable (not "works correctly")?
- **REQ Coverage**: Does every REQ have at least one ATP?
- **Scenario Completeness**: Do all ATPs have at least one SCN?

### 5. Generate Findings

For each quality issue identified in Step 4:

1. **Assign a PRF ID**: `PRF-{ARTIFACT}-NNN` — sequential, zero-padded, starting at 001.
   - Example for requirements review: PRF-REQ-001, PRF-REQ-002, PRF-REQ-003

2. **Classify severity** — exactly one of:
   - **Critical**: Fundamental quality violation that blocks release (untestable requirement, missing mandatory view, unmitigated catastrophic hazard, zero coverage for a component).
   - **Major**: Significant quality issue that should be fixed before approval (ambiguous quantifier, incomplete interface contract, missing test technique, orphaned component with no trace).
   - **Minor**: Style or completeness issue that does not affect correctness (inconsistent formatting, verbose description, missing rationale on low-risk item).
   - **Observation**: Informational suggestion, not a defect (alternative decomposition, additional test technique that could add value, formatting preference).

3. **Identify location**: The specific artifact ID (e.g., REQ-007, SYS-003, MOD-005) or section name where the issue was found.

4. **Write description**: Clear, specific statement of what the quality issue is.

5. **Write recommendation**: Actionable guidance on how to resolve it.

### 6. Write Output

Write the peer review report to `{VMODEL_DIR}/peer-review-{artifact}.md` using the template structure:

1. **Header**: Reviewer ("AI Peer Review (spec-kit V-Model)"), date (ISO 8601), artifact name, item count, governing standard.

2. **Summary table**: Counts for each severity (Critical, Major, Minor, Observation) and total.

3. **Findings section**: One subsection per finding with: PRF ID in heading, severity, location, description, recommendation.

**CRITICAL**: Do NOT include a `Status` field in findings. If the finding exists in the report, it is a current problem. Period.

### 7. Report Completion

Display a summary:
- Artifact reviewed (type and file path)
- Governing standard applied
- Item count in the artifact
- Finding counts by severity
- Total findings
- Path to the generated review file
- CI exit code that `peer-review-check.sh` would return:
  - Exit 0 if zero findings or observations only
  - Exit 1 if any Critical or Major findings
  - Exit 2 if Minor findings only (no Critical/Major)
- Next step: If Critical or Major findings exist, recommend fixing them and re-running

## Operating Constraints

### Stateless Linting Model

- Each invocation generates the review **from scratch** — no dependency on prior review files
- The output file is **overwritten** on each run — `git diff` shows what changed
- There is **no Status field** — presence in the report = current problem
- There is **no database or cache** of past findings — Git history is the audit trail

### Advisory-Only Findings

- `PRF-{ARTIFACT}-NNN` IDs are **NOT** part of the V-Model traceability chain
- PRF IDs do NOT appear in traceability matrices
- PRF IDs do NOT affect coverage metrics or validators
- The `PRF` prefix is explicitly excluded from all traceability validation scripts

### Single Artifact Scope

- Each invocation reviews **exactly one** artifact file
- The command does **NOT** modify the input artifact — it is read-only
- To review multiple artifacts, run the command multiple times
- No ordering dependency — review any artifact at any time

### Severity Guidelines

| Severity | Definition | CI Impact |
|----------|-----------|-----------|
| Critical | Fundamental quality violation that blocks release | Exit 1 (blocks PR) |
| Major | Significant quality issue that should be fixed | Exit 1 (blocks PR) |
| Minor | Style/completeness issue, non-blocking | Exit 2 (warning) |
| Observation | Informational suggestion, not a defect | Exit 0 (clean) |

### PRF ID Format

- Pattern: `PRF-{ARTIFACT}-NNN`
- `{ARTIFACT}`: Uppercase abbreviation from the mapping table in Step 2.4
- `NNN`: Zero-padded sequential number starting at 001
- IDs are transient — they are regenerated on each run and have no persistence across runs
- Examples: PRF-REQ-001, PRF-SYS-003, PRF-HAZ-012, PRF-MOD-001
