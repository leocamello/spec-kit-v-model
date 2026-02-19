---
description: Generate a V-Model Requirements Specification with traceable REQ-NNN
  IDs from a feature description or existing spec.md.
handoffs:
- label: Generate Acceptance Tests
  agent: speckit.v-model.acceptance
  prompt: Generate the acceptance test plan for these requirements
  send: true
- label: Back to Specify
  agent: speckit.specify
  prompt: Refine the feature specification
scripts:
  sh: scripts/bash/setup-v-model.sh --json
  ps: scripts/powershell/setup-v-model.ps1 -Json
---


<!-- Extension: v-model -->
<!-- Config: .specify/extensions/v-model/ -->
## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Transform a feature description or existing `spec.md` into a structured V-Model Requirements Specification where **every requirement has a unique, traceable ID** (`REQ-NNN`). This document becomes the foundation of the V-Model — every requirement defined here will later be paired with acceptance test cases and executable scenarios.

## Execution Steps

### 1. Setup

Run `{SCRIPT}` from the repository root and parse the JSON output.

The script returns JSON with these keys:
- `VMODEL_DIR`: Path to `specs/{feature}/v-model/` directory
- `FEATURE_DIR`: Path to `specs/{feature}/` directory
- `BRANCH`: Current branch name
- `SPEC`: Path to `spec.md` (file may not exist yet)
- `REQUIREMENTS`: Path to `requirements.md` (file may not exist yet)
- `AVAILABLE_DOCS`: Array of documents that currently exist (e.g., `["spec.md"]`)

For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

### 2. Load Context

1. **Load the template**: Read `templates/requirements-template.md` from the extension directory to understand the required output structure.

2. **Load the source** (in priority order):
   - If `AVAILABLE_DOCS` contains `"spec.md"`: Read `spec.md` from the feature directory (`SPEC` path). This is the primary source of truth.
   - If `$ARGUMENTS` is not empty: Use the user's feature description as the source.
   - If both exist: Use `spec.md` as the primary source, with `$ARGUMENTS` as supplementary context or instructions.
   - If neither exists: ERROR — "No feature description or spec.md found. Run `/speckit.specify` first or provide a feature description."

3. **Load existing requirements** (if `AVAILABLE_DOCS` contains `"requirements.md"`):
   - Read the existing `requirements.md` (`REQUIREMENTS` path) to preserve existing IDs and content.
   - Identify the highest existing REQ number to continue the sequence.
   - New requirements append after existing ones — **never renumber**.

### 3. Generate Requirements

Follow the **strict translator constraint**: You are extracting and formalizing requirements from the source material. You must NOT invent, infer, or add features not present in the source.

For each requirement identified in the source material:

1. **Assign a unique ID** using the naming convention:
   - **Functional**: `REQ-NNN` (e.g., REQ-001, REQ-002)
   - **Non-Functional**: `REQ-NF-NNN` (e.g., REQ-NF-001)
   - **Interface**: `REQ-IF-NNN` (e.g., REQ-IF-001)
   - **Constraint**: `REQ-CN-NNN` (e.g., REQ-CN-001)

2. **Write a requirement description** that satisfies ALL 8 quality criteria (see §4).

3. **Assign priority**: P1 (Critical), P2 (Important), P3 (Nice-to-have).

4. **Document rationale**: Why does this requirement exist? Link to the source section or user need.

5. **Specify verification method**: Test, Inspection, Analysis, or Demonstration.

### 4. Validate Requirements Quality (IEEE 29148 / INCOSE)

Every requirement MUST satisfy **all 8 criteria** before it is included in the output. If a requirement fails any criterion, rewrite it until it passes. These criteria are non-negotiable.

#### Criterion 1: Unambiguous (Clear)

The requirement has exactly **one possible interpretation**. It avoids subjective words: *fast, user-friendly, robust, seamless, approximately, intuitive, efficient, reasonable, significant, adequate, minimal*.

- ❌ "The system shall load the dashboard quickly."
- ✅ "The system shall fully render the user dashboard within 2.0 seconds of a successful authentication."

**Check**: Can two engineers read this requirement and arrive at different implementations? If yes, rewrite.

#### Criterion 2: Testable / Verifiable

You MUST be able to design a definitive **Pass/Fail test** for it. If you cannot measure it or objectively prove it, it is not a valid requirement. This is the direct trigger for `ATP-NNN` generation in the acceptance phase.

- ❌ "The search function shall be highly accurate."
- ✅ "The search function shall return exact text matches in the top 3 results for 95% of queries."

**Check**: Can you write a test case with a concrete pass/fail condition right now? If not, rewrite.

#### Criterion 3: Atomic (Singular)

The requirement describes exactly **one** function or constraint. It must NOT contain conjunctions ("and", "or", "but", "unless") that hide a second requirement. If a compound statement is found in the source, split it into separate REQ-NNN items.

- ❌ "The system shall save the user profile and send a confirmation email."
  (If the save works but the email fails, does this requirement pass or fail?)
- ✅ Split into two:
  - `REQ-010`: "The system shall save the user profile to the database upon clicking 'Submit'."
  - `REQ-011`: "The system shall dispatch a confirmation email within 1 minute of a successful profile save."

**Check**: Does the requirement contain "and", "or", "but", or "unless"? If yes, consider splitting.

#### Criterion 4: Complete

The requirement contains **all the information** needed by both the developer and the tester. There are no "TBDs" (To Be Determined), missing conditions, missing thresholds, or undefined states.

- ❌ "The system shall lock the account after too many failed logins."
- ✅ "The system shall lock the user account for 30 minutes after 5 consecutive failed login attempts within a 15-minute window."

**Check**: Does a developer have enough information to implement this without guessing? Does a tester have enough to write a test? If not, add the missing details.

#### Criterion 5: Consistent

The requirement does **not contradict** any other requirement in the specification.

- ❌ `REQ-005` says "Passwords must be exactly 8 characters" while `REQ-042` says "Passwords must be between 10 and 15 characters."

**Check**: After generating all requirements, cross-reference for conflicts. If contradictions are found, flag them with `[CONFLICT: REQ-NNN contradicts REQ-MMM — resolution needed]` and do NOT proceed until resolved.

#### Criterion 6: Traceable

The requirement has a **unique, persistent identifier** (`REQ-NNN`) so it can be tracked:
- **Forward** → to test cases (`ATP-NNN-X`) and code
- **Backward** → to the specific business need, user scenario, or regulatory rule in the source

**Check**: Does every requirement have its ID and rationale filled in? The rationale IS the backward trace.

#### Criterion 7: Feasible

The requirement is **technically, legally, and financially possible** to build within realistic constraints.

- ❌ "The system shall have 100% uptime with zero maintenance windows forever."
- ✅ "The system shall maintain 99.9% availability during business hours (8 AM – 6 PM EST)."

**Check**: Is this requirement physically possible? Can a development team deliver this? If the source contains an infeasible requirement, flag it with `[FEASIBILITY CONCERN: reason]`.

#### Criterion 8: Necessary (Essential)

The requirement traces back to a **real business, user, or safety need**. If you remove this requirement, the system would fail to meet its core objective. This prevents "gold-plating" (adding unnecessary features).

**Check**: The strict translator constraint inherently enforces this — you are forbidden from inventing requirements not in the source. If a requirement feels extraneous, verify it appears in the source material. If it doesn't, remove it.

### 5. Write Output

Write the complete requirements document to `{VMODEL_DIR}/requirements.md` using the template structure. Include:

1. **Header section**: Feature name, branch, date, source reference
2. **Overview**: Brief description of the feature's business context
3. **Requirements tables**: All four categories (Functional, Non-Functional, Interface, Constraint) — omit empty categories entirely
4. **Assumptions**: Any reasonable defaults assumed during extraction
5. **Dependencies**: External systems or conditions
6. **Glossary**: Domain-specific terms used in requirements
7. **Summary metrics**: Total count, by priority, by verification method

### 6. Report Completion

Display a summary:
- Total requirements generated (broken down by category)
- Source used (spec.md, user input, or both)
- Any assumptions made
- Any `[NEEDS CLARIFICATION]` or `[CONFLICT]` flags that need user attention
- Path to the generated file
- Next step: Recommend running `/speckit.v-model.acceptance` to generate the paired test plan

## Operating Constraints

### Strict Translation Rules

When deriving from `spec.md`:
- **DO NOT** invent new features or capabilities not in the source
- **DO NOT** add requirements based on "common sense" or "best practices" unless explicitly stated
- **DO** atomize compound statements into separate requirements (Criterion 3: Atomic)
- **DO** flag genuinely ambiguous items with `[NEEDS CLARIFICATION: specific question]` (maximum 3)
- **DO** document assumptions for reasonable defaults in the Assumptions section

### ID Rules

- IDs are **permanent** — once assigned, they are never renumbered or reassigned
- Sequential numbering within each category (REQ-001, REQ-002, ...)
- When updating existing requirements, preserve all existing IDs and append new ones
- Gaps in numbering are acceptable (e.g., if REQ-003 is removed, REQ-004 stays REQ-004)

### Banned Words (Criterion 1: Unambiguous)

The following words are **banned** from requirement descriptions. If the source uses them, you must translate them into measurable, testable language:

| Banned Word | Replace With |
|-------------|-------------|
| fast | specific time threshold (e.g., "within 2 seconds") |
| user-friendly | specific usability criteria (e.g., "completable in 3 steps") |
| robust | specific failure-handling behavior |
| seamless | specific integration behavior |
| intuitive | specific learnability criteria |
| efficient | specific resource or time metrics |
| reasonable | specific threshold or range |
| significant | specific percentage or quantity |
| adequate | specific minimum criteria |
| minimal | specific maximum value |
| approximately | specific range or tolerance |
| scalable | specific load targets (e.g., "10,000 concurrent users") |
| secure | specific security measures (e.g., "TLS 1.2+ encryption") |
| reliable | specific availability or MTBF targets |
| flexible | specific extensibility or configuration points |