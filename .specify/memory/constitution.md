<!--
  Sync Impact Report
  Version change: 1.0.0 → 1.1.0 (MINOR — additive operational rules absorbing v0.7.x learnings)
  Principles: unchanged (I–V still hold; no semantic redefinition)
  Added sections:
    - Development Workflow → §Bridge Command Discipline (strict mode, single source of truth,
      sibling-file projections, substance over shape, substance validators)
    - Development Workflow → §V-Model Artifact Map (8 paired artifacts + auxiliaries)
  Expanded sections:
    - Development Workflow → §ID Schema and Artifact Naming (extended to full identifier set:
      REQ/ATP/SCN, SYS/STP/STS, ARCH/ITP/ITS, MOD/UTP/UTS, HAZ, PRF, WAV)
  Templates requiring updates:
    - .specify/templates/plan-template.md ✅ (already present)
    - .specify/templates/spec-template.md ✅ (already present)
    - .specify/templates/tasks-template.md ✅ (already present)
    - AGENTS.md ✅ (created in same change; references this constitution as authoritative)
  Follow-up TODOs:
    - Substance validators (validate-test-plan-implementation.sh,
      validate-module-implementation-depth.sh) must be wired into CI
      before they are cited as enforcement in PR reviews.

  Prior history:
    1.0.0 — Initial ratification (2026-02-19): five core principles, regulatory standards,
            development workflow, governance. See git log of this file for full diff.
-->

# Spec Kit V-Model Extension Pack Constitution

**Audience.** This constitution governs the **development of the V-Model
Extension Pack itself**. The maintainer and contributors evolving
`spec-kit-v-model` follow these principles when changing the extension's
prompts, scripts, templates, tests, and documentation.

Teams *using* `spec-kit-v-model` on their own safety-critical project
will maintain their own `.specify/memory/constitution.md` inside their
own repository, governing *their* project. That constitution is theirs
to write. This one is ours.

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

### V-Model Artifact Map

The V-Model is paired across four levels. Each development artifact has a
sibling test artifact at the same level. The eight artifacts below — produced
by their respective `speckit.v-model.<command>` — are the **single source of
truth** for everything downstream (`plan.md`, `tasks.md`, source code, test code).

| Level | Dev-side (left of the V) | Test-side (right of the V) |
|---|---|---|
| L1 — Acceptance | Requirements Specification (`REQ-NNN`) | Acceptance Test Plan (`ATP-NNN-X` → `SCN-NNN-X#`) |
| L2 — System | System Design (`SYS-NNN`) | System Test Plan (`STP-NNN-X` → `STS-NNN-X#`) |
| L3 — Architecture | Architecture Design (`ARCH-NNN`) | Integration Test Plan (`ITP-NNN-X` → `ITS-NNN-X#`) |
| L4 — Module | Module Design (`MOD-NNN`) | Unit Test Plan (`UTP-NNN-X` → `UTS-NNN-X#`) |

**Cross-cutting auxiliaries** (not part of the eight, but governed by the same
principles): Hazard Analysis (`HAZ-NNN`), Peer Review Findings (`PRF-{ARTIFACT}-NNN`),
Waivers (`WAV-NNN`), the Bidirectional Traceability Matrix, and the Release
Audit Report.

### ID Schema and Artifact Naming

| Artifact | Pattern | Example |
|---|---|---|
| Requirement | `REQ-{NNN}` | `REQ-001` |
| Acceptance Test Case | `ATP-{NNN}-{X}` | `ATP-001-A` |
| Acceptance BDD Scenario | `SCN-{NNN}-{X#}` | `SCN-001-A1` |
| System Component | `SYS-{NNN}` | `SYS-001` |
| System Test Case | `STP-{NNN}-{X}` | `STP-001-A` |
| System Test Scenario | `STS-{NNN}-{X#}` | `STS-001-A1` |
| Architecture Module | `ARCH-{NNN}` | `ARCH-001` |
| Integration Test Case | `ITP-{NNN}-{X}` | `ITP-001-A` |
| Integration Test Scenario | `ITS-{NNN}-{X#}` | `ITS-001-A1` |
| Module Design | `MOD-{NNN}` | `MOD-001` |
| Unit Test Case | `UTP-{NNN}-{X}` | `UTP-001-A` |
| Unit Test Scenario | `UTS-{NNN}-{X#}` | `UTS-001-A1` |
| Hazard | `HAZ-{NNN}` | `HAZ-001` |
| Peer Review Finding | `PRF-{ARTIFACT}-{NNN}` | `PRF-REQ-001` |
| Waiver | `WAV-{NNN}` | `WAV-001` |
| Requirement Category | `[FN]`, `[NF]`, `[IF]`, `[CN]` | `[FN] REQ-001` |
| Scope Markers | `[EXTERNAL]`, `[CROSS-CUTTING]` | `[EXTERNAL] REQ-042` |

**Identifier invariants** (enforced by deterministic scripts, never by AI):

- IDs MUST NOT be renumbered once assigned, even when intervening items are
  deprecated. Stable IDs are a regulatory record-keeping requirement.
- Deprecated artifacts MUST carry the `[DEPRECATED]` lifecycle marker and
  remain in the document for traceability.
- Artifacts in transient inconsistent states MUST carry `[SUSPECT]` until
  a human resolves them.
- The category and scope marker semantics (`[EXTERNAL]`, `[CROSS-CUTTING]`)
  MUST have one authoritative definition shared by all docs, templates, and
  validators. Synonym drift is a documentation defect.

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

### Bridge Command Discipline

The three bridge commands — `speckit.v-model.plan`, `speckit.v-model.tasks`,
`speckit.v-model.implement` — translate the V-Model artifact set into
Spec-Kit-canonical outputs (`plan.md`, `tasks.md`, source code, test code).
They MUST operate under the following rules, established in response to
the v0.7.x failure mode where bridges produced structurally valid outputs
that lacked verification substance ("satisfied shape but missed
substance"):

1. **Strict mode only.** All eight V-Model artifacts MUST exist and MUST
   carry the `[Approved]` status marker before any bridge command runs.
   A missing or non-approved artifact MUST cause the bridge to refuse
   execution and route the user back to fix the upstream artifact. There
   is no permissive mode and no hybrid fallback.

2. **V-Model artifacts are the single source of truth.** The bridge
   commands MUST translate V-Model artifacts faithfully into their
   downstream outputs. The LLM never invents content during translation;
   it only routes (`plan`) or renders (`implement`). When translation is
   not possible because the upstream artifact is silent on a required
   point, the bridge MUST refuse and surface a `[NEEDS CLARIFICATION]`
   marker on the upstream artifact rather than guessing.

3. **Sibling files are editable projections, not parallel sources.**
   Files such as `data-model.md`, `quickstart.md`, `research.md`, and
   `contracts/` are projections of one or more V-Model artifacts. Human
   edits to these files MUST be propagated back to their V-Model source
   via HTML-comment anchors. A divergence between a sibling file and its
   V-Model source MUST be detected and resolved before bridges re-run.

4. **Substance over shape.** Schema validation is necessary but never
   sufficient. The substance validators — `validate-test-plan-implementation.sh`
   and `validate-module-implementation-depth.sh` — MUST run as part of the
   bridge pre-flight and MUST fail closed when substance is missing.
   Examples of substance failures that MUST be caught: a test plan that
   names methods but defines no scenarios; a module design that lists
   functions but specifies no behavior or invariants.

5. **Bridges never modify compliance-critical artifacts.** Bridges read
   the eight V-Model artifacts; they do not write to them. Any change a
   bridge would need to make to an upstream artifact MUST instead be
   surfaced as a `[NEEDS CLARIFICATION]` and routed back to the human via
   the relevant `speckit.v-model.<level>` command.

6. **Report Completion is versioned and persisted.** Every bridge run
   MUST emit a structured JSON Report Completion record with a
   `schema_version` field, written to `.runs/`. The Report Completion
   shape is part of the bridge contract and changes only via PR review.

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

**Version**: 1.1.0 | **Ratified**: 2026-02-19 | **Last Amended**: 2026-05-16
