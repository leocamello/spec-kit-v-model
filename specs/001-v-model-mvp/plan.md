# Implementation Plan: V-Model Extension Pack MVP

**Branch**: `001-v-model-mvp` | **Date**: 2026-02-19 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/001-v-model-mvp/spec.md`
**Status**: Implemented (retroactive documentation)

## Summary

Build three AI-powered Spec Kit slash commands (`/speckit.v-model.requirements`,
`/speckit.v-model.acceptance`, `/speckit.v-model.trace`) that enforce V-Model
paired generation of development specifications and test specifications.
Complement the commands with four deterministic helper scripts for coverage
validation, traceability matrix generation, requirement change detection,
and directory setup. All artifacts are plaintext Markdown stored in Git.

## Technical Context

**Language/Version**: Bash 5.x (scripts), Markdown (commands/templates), Python 3.10+ (testing only)
**Primary Dependencies**: Spec Kit CLI v0.1.0+ (host framework), GitHub Copilot (AI execution engine)
**Storage**: Git-tracked plaintext Markdown files (no database)
**Testing**: BATS 1.11+ (Bash), Pester 5.x (PowerShell), pytest 8.x + DeepEval 2.x (Python evals)
**Target Platform**: Cross-platform (Linux, macOS, Windows via PowerShell equivalents)
**Project Type**: Spec Kit extension (commands + scripts + templates)
**Performance Goals**: Single-command generation of complete artifact sets; deterministic scripts complete in under 5 seconds for documents with up to 100 requirements
**Constraints**: No external services required at runtime (AI runs locally via Copilot); all compliance-critical calculations performed by deterministic scripts, not AI
**Scale/Scope**: Extension targeting regulated-industry teams of 1–50 engineers; documents with 10–100 requirements per specification

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Evidence |
|-----------|--------|----------|
| I. V-Model Discipline | ✅ PASS | Three commands enforce paired generation: requirements → acceptance → trace. ID schema (REQ → ATP → SCN) encodes lineage. |
| II. Deterministic Verification | ✅ PASS | `validate-requirement-coverage.sh` and `build-matrix.sh` use regex parsing for coverage and matrix generation. AI is never trusted to verify its own output. |
| III. Specification as Source of Truth | ✅ PASS | `requirements.md` is the authoritative source; acceptance plan and matrix derive from it. IDs reference source requirements. |
| IV. Git as QMS | ✅ PASS | All artifacts are plaintext Markdown in Git. `diff-requirements.sh` uses `git show` for change detection. |
| V. Human-in-the-Loop | ✅ PASS | Commands generate drafts. Human reviews and commits. `[NEEDS CLARIFICATION]` markers halt dependent generation. |

No violations. No complexity tracking required.

## Project Structure

### Documentation (this feature)

```text
specs/001-v-model-mvp/
├── plan.md              # This file
├── research.md          # Technology decisions and rationale
├── spec.md              # Feature specification (5 user stories, 12 FRs)
├── checklists/
│   └── requirements.md  # Spec quality validation checklist
└── tasks.md             # Implementation tasks (created by /speckit.tasks)
```

### Source Code (repository root)

```text
commands/
├── requirements.md          # /speckit.v-model.requirements command definition
├── acceptance.md            # /speckit.v-model.acceptance command definition
└── trace.md                 # /speckit.v-model.trace command definition

scripts/
├── bash/
│   ├── setup-v-model.sh     # V-Model directory setup + prerequisite checking
│   ├── validate-requirement-coverage.sh # Deterministic coverage gap analysis (regex)
│   ├── build-matrix.sh      # Deterministic traceability matrix builder (regex)
│   └── diff-requirements.sh # Git-based requirement change detection
└── powershell/
    ├── setup-v-model.ps1    # PowerShell equivalent of setup script
    ├── validate-requirement-coverage.ps1
    ├── build-matrix.ps1
    └── diff-requirements.ps1

templates/
├── requirements-template.md         # Requirements document structure
├── acceptance-plan-template.md      # Three-tier test plan structure
└── traceability-matrix-template.md  # Bidirectional RTM structure

docs/
├── v-model-overview.md      # V-Model methodology reference
├── compliance-guide.md      # Regulatory standards mapping
├── usage-examples.md        # Command usage walkthroughs
└── product-vision.md        # Strategic "why" document

tests/
├── bats/                    # BATS unit tests for Bash scripts
├── pester/                  # Pester unit tests for PowerShell scripts
├── evals/                   # DeepEval LLM-as-judge quality metrics
├── fixtures/                # Test fixture sets (minimal, complex, gaps, empty, malformed)
└── validators/              # Python structural validators
```

**Structure Decision**: Extension project — no `src/` directory. Commands are
Markdown prompt definitions executed by GitHub Copilot. Scripts are standalone
shell programs. Templates are Markdown scaffolds. This structure follows the
Spec Kit extension conventions defined in `extension.yml`.

## Research (Phase 0)

### Decision 1: Command Architecture

**Decision**: Commands are Markdown prompt definitions (not executable code).
GitHub Copilot interprets the prompt and generates artifacts using the
templates and helper scripts.

**Rationale**: Spec Kit extensions define commands as `.md` files in
`commands/`. The AI assistant reads the command definition, follows its
instructions, and produces output. This aligns with Spec Kit's architecture
where AI handles creative translation and scripts handle verification.

**Alternatives considered**:
- Executable CLI commands (Python/Node): Rejected — would duplicate Spec Kit's
  own execution model and require a separate runtime.
- Pure templates without commands: Rejected — no enforcement of quality
  criteria or workflow sequencing.

### Decision 2: ID Schema Design

**Decision**: Three-tier hierarchical IDs that encode lineage:
`REQ-001` → `ATP-001-A` → `SCN-001-A1`.

**Rationale**: Embedding the parent ID in child IDs enables bidirectional
traceability without a separate mapping file. A regex can extract the parent
from any child ID (e.g., `SCN-001-A1` → parent ATP is `ATP-001-A` → parent
REQ is `REQ-001`). This makes deterministic scripts simple and reliable.

**Alternatives considered**:
- Flat sequential IDs (TC-001, TC-002): Rejected — no inherent traceability;
  requires a separate mapping table.
- UUID-based IDs: Rejected — not human-readable; makes manual review and
  audit difficult.
- Database-backed IDs: Rejected — violates Constitution Principle IV (Git
  as QMS; no external databases).

### Decision 3: Verification Strategy

**Decision**: Deterministic regex-based scripts for coverage validation and
matrix generation. AI is never trusted to verify its own output.

**Rationale**: Constitution Principle II (Deterministic Verification) requires
that compliance-critical calculations are performed by scripts, not AI. Regex
parsing of the structured Markdown (with well-defined ID patterns) provides
mathematically correct results. This separation ensures auditors can trust
the coverage numbers independently of the AI that generated the artifacts.

**Alternatives considered**:
- AI self-assessment ("check your own work"): Rejected — violates Principle II;
  prone to hallucination.
- External validation service: Rejected — adds a runtime dependency and
  violates the offline-capable constraint.

### Decision 4: Dual Platform Support

**Decision**: All scripts implemented in both Bash and PowerShell.

**Rationale**: Target users span Linux/macOS (Bash) and Windows (PowerShell)
environments. Regulated-industry teams often have mixed environments. Both
implementations produce identical output for the same input.

**Alternatives considered**:
- Bash only with WSL requirement on Windows: Rejected — too high a barrier
  for enterprise Windows environments.
- Python scripts: Rejected — adds a Python runtime dependency for the
  extension itself (Python is only required for the test/eval suite).

### Decision 5: Testing Architecture

**Decision**: Three-tier testing: BATS (Bash scripts), Pester (PowerShell
scripts), DeepEval with Google Gemini (semantic quality of AI-generated
artifacts).

**Rationale**: Each layer tests a different concern. BATS/Pester test
deterministic script correctness. DeepEval tests the quality of AI-generated
output against golden examples using LLM-as-judge metrics. This ensures
both the scripts and the prompts are validated.

**Alternatives considered**:
- Manual review only: Rejected — not repeatable or CI-enforceable.
- OpenAI for LLM evaluation: Rejected — cost and API key management;
  Google Gemini selected for availability and pricing.

## Complexity Tracking

No Constitution Check violations. No complexity justifications required.
