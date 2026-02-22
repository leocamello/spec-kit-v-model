<!--
  Sync Impact Report
  Version change: N/A → 1.0.0 (initial ratification)
  Added principles:
    - I. V-Model Discipline (TDD bridge to Spec Kit's Test-First Imperative)
    - II. Deterministic Verification
    - III. Specification as Source of Truth
    - IV. Git as Quality Management System
    - V. Human-in-the-Loop (PR-based approval, NEEDS CLARIFICATION mandate)
  Added sections:
    - Regulatory Compliance Standards
    - Development Workflow (with hard-fail CI gates)
    - Governance (equal-weight principles preamble)
  Templates requiring updates:
    - .specify/templates/plan-template.md ✅ (Constitution Check section already present)
    - .specify/templates/spec-template.md ✅ (User Scenarios + Requirements sections align;
      NEEDS CLARIFICATION pattern already demonstrated in FR-006/FR-007 examples)
    - .specify/templates/tasks-template.md ✅ (Phase structure supports V-Model pairing;
      Test-First checkpoint pattern present)
  Follow-up TODOs: None
-->

# Spec Kit V-Model Extension Pack Constitution

## Core Principles

All five principles below carry equal weight and are strictly enforced.
No principle supersedes another; a violation of any single principle is
a blocking issue that MUST be resolved before work proceeds.

### I. V-Model Discipline

Every development specification MUST have a paired test specification.
No requirement exists without a traceable test case; no test case exists
without a parent requirement.

- Requirements use the `REQ-{NNN}` identifier schema.
- Test cases use `ATP-{NNN}-{X}` (linked to their parent REQ).
- BDD scenarios use `SCN-{NNN}-{X#}` (linked to their parent ATP).
- The three-tier ID schema (`REQ → ATP → SCN`) MUST maintain 100%
  bidirectional coverage: every REQ has at least one ATP, every ATP has
  at least one SCN, and no orphaned test artifacts are permitted.
- During implementation, BDD scenarios (`SCN-{NNN}-{X#}`) MUST be
  translated into executable test code (e.g., Cucumber, pytest-bdd)
  following Spec Kit's Test-First Imperative: tests are written and
  approved before implementation begins, and MUST fail before the
  corresponding feature code is written.

### II. Deterministic Verification

Coverage calculations, traceability matrices, and structural validations
MUST be computed by deterministic scripts, never by AI self-assessment.

- Regex-based helper scripts (`validate-requirement-coverage.sh`, `build-matrix.sh`)
  perform mathematically correct coverage analysis.
- AI is used for creative translation (requirements → test cases) but
  MUST NOT be trusted to verify its own output.
- CI pipelines MUST enforce structural validators on every push.

### III. Specification as Source of Truth

The specification document is the authoritative source for all downstream
artifacts. Test plans, traceability matrices, and acceptance criteria
derive from the specification—not the other way around.

- Specifications MUST be written in plaintext Markdown.
- Generated artifacts MUST reference their source specification by ID.
- When a requirement changes, all downstream artifacts MUST be
  re-validated before the change is considered complete.

### IV. Git as Quality Management System

All artifacts MUST be plaintext Markdown stored in Git. Cryptographic
commit hashes provide an immutable, tamper-evident audit trail that
satisfies regulatory record-keeping requirements.

- No binary formats, proprietary databases, or external SaaS tools
  for compliance-critical artifacts.
- Every artifact change MUST be a Git commit with a descriptive message.
- Branch protection and CI gates MUST enforce quality checks before
  merge to the default branch.

### V. Human-in-the-Loop

AI assists with creative translation but a human MUST review and approve
all generated artifacts before they are considered authoritative.

- AI-generated requirements and test cases are drafts until a human
  signs off via a Pull Request review.
- Approval MUST be recorded as a GitHub Pull Request with at least one
  secondary human reviewer. Direct commits to the default branch do
  not constitute approval for compliance-critical artifacts.
- The human is the systems engineer; AI is the exoskeleton that
  accelerates their work, not a replacement for their judgment.
- When requirements are ambiguous or underspecified, the AI MUST insert
  a `[NEEDS CLARIFICATION: <reason>]` marker and stop generating
  dependent artifacts until the human resolves the ambiguity. Guessing
  intent is prohibited.
- The mantra: "The AI drafts. The human decides. The scripts verify.
  Git remembers."

## Regulatory Compliance Standards

This extension targets teams operating under safety-critical and
quality-regulated standards. All design decisions MUST consider
compatibility with the following frameworks:

- **IEC 62304 / FDA 21 CFR Part 820**: Medical device software lifecycle.
  Traceability from software requirements to verification activities.
- **ISO 26262**: Automotive functional safety. ASIL decomposition and
  safety requirement traceability.
- **DO-178C**: Airborne systems software. Forward and backward
  traceability between requirements, design, code, and test cases.
- **IEEE 29148**: Systems and software engineering requirements processes.
  The structural format for all requirement specifications.

The extension does not claim to certify compliance with these standards.
It provides the artifact structure and traceability evidence that
auditors expect, reducing the burden of manual documentation.

## Development Workflow

### ID Schema and Artifact Naming

| Artifact | Pattern | Example |
|---|---|---|
| Requirement | `REQ-{NNN}` | `REQ-001` |
| Test Case | `ATP-{NNN}-{X}` | `ATP-001-A` |
| BDD Scenario | `SCN-{NNN}-{X#}` | `SCN-001-A1` |
| Requirement Category | `[FN]`, `[NF]`, `[IF]`, `[CN]` | `[FN] REQ-001` |

### Quality Gates

1. **Structural Validation**: Every requirements document MUST pass
   `validate-requirement-coverage.sh` (all REQs have ATPs, all ATPs have SCNs).
   A traceability gap MUST cause a hard failure in the CI pipeline—
   incomplete coverage is never a warning, always a blocking error.
2. **Traceability Matrix**: `build-matrix.sh` MUST produce a complete
   matrix with no gaps before a specification is considered final.
   Any missing cell in the matrix MUST fail the pipeline.
3. **LLM-as-Judge Evaluation**: Semantic quality of generated artifacts
   MUST be assessed by DeepEval GEval metrics against golden examples.
4. **CI Enforcement**: All three gates run automatically on every push
   via GitHub Actions (`ci.yml` for structural, `evals.yml` for semantic).
   A red CI status MUST block merge to the default branch.

### Testing Stack

- **BATS** (Bash Automated Testing System): Unit tests for shell scripts.
- **Pester**: Unit tests for PowerShell scripts.
- **pytest + DeepEval**: Structural validators and LLM-as-judge evals.
- **Google Gemini** (`gemini-2.5-flash`): LLM backend for semantic
  evaluation metrics.

## Governance

This constitution is the supreme governance document for the Spec Kit
V-Model Extension Pack. All contributions, reviews, and design decisions
MUST comply with these principles.

### Amendment Procedure

1. Propose the amendment as a pull request modifying this file.
2. The amendment MUST include a rationale in the PR description.
3. Update the Sync Impact Report (HTML comment at top of this file).
4. Increment the version according to semantic versioning:
   - **MAJOR**: Backward-incompatible principle removals or redefinitions.
   - **MINOR**: New principle or section added; material expansion.
   - **PATCH**: Clarifications, wording, typo fixes.
5. Update `LAST_AMENDED_DATE` to the merge date.

### Compliance Review

- Every pull request MUST be checked against the five core principles.
- Reviewers SHOULD reference specific principle numbers (e.g.,
  "Principle II violation: coverage computed by AI") when requesting
  changes.
- The Constitution Check section in `plan-template.md` MUST be completed
  before implementation begins on any new feature.

**Version**: 1.0.0 | **Ratified**: 2026-02-19 | **Last Amended**: 2026-02-19
