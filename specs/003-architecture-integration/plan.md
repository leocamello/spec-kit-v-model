# Implementation Plan: Architecture Design ↔ Integration Testing

**Branch**: `003-architecture-integration` | **Date**: 2026-02-21 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/003-architecture-integration/spec.md`

## Summary

Extend the V-Model Extension Pack from System Design ↔ System Testing (v0.2.0) down one level to Architecture Design ↔ Integration Testing (v0.3.0). Add two new AI-powered commands (`/speckit.v-model.architecture-design` and `/speckit.v-model.integration-test`), a deterministic coverage validation script (`validate-architecture-coverage.sh`), extended traceability matrix support (Matrix C), and corresponding templates. The architecture-design command decomposes system components into IEEE 42010/Kruchten 4+1-compliant architecture modules; the integration-test command generates ISO 29119-4-compliant integration test cases targeting the seams and handshakes between those modules.

## Technical Context

**Language/Version**: Bash 5.x (scripts), Markdown (commands/templates), Python 3.10+ (testing only)
**Primary Dependencies**: Spec Kit CLI v0.1.0+ (host framework), GitHub Copilot (AI execution engine), V-Model Extension v0.2.0 (base commands and scripts)
**Storage**: Git-tracked plaintext Markdown files (no database)
**Testing**: BATS 1.11+ (Bash), Pester 5.x (PowerShell), pytest 8.x + DeepEval 2.x (Python evals)
**Target Platform**: Cross-platform (Linux, macOS, Windows via PowerShell equivalents)
**Project Type**: Spec Kit extension — extending existing v0.2.0 extension with new V-level
**Performance Goals**: Deterministic scripts complete in under 5 seconds for documents with up to 200 ARCH modules; AI commands handle 50+ SYS inputs without truncation
**Constraints**: No external services required at runtime; all coverage calculations by deterministic scripts; backward compatible with v0.1.0 and v0.2.0 artifacts; safety-critical sections gated by `v-model-config.yml`
**Scale/Scope**: Extension targeting regulated-industry teams; documents with 10–200+ architecture modules; many-to-many SYS↔ARCH relationships; cross-cutting infrastructure modules

## Constitution Check

*GATE: Must pass before implementation. Re-check after Phase 2 design.*

| Principle | Status | Evidence |
|-----------|--------|----------|
| I. V-Model Discipline | ✅ PASS | Two new commands enforce paired generation: architecture-design (left side) ↔ integration-test (right side). ID schema extended: `ARCH-NNN` → `ITP-NNN-X` → `ITS-NNN-X#` mirrors `SYS → STP → STS`. 100% bidirectional coverage enforced by `validate-architecture-coverage.sh`. |
| II. Deterministic Verification | ✅ PASS | New `validate-architecture-coverage.sh` uses regex-based parsing for SYS→ARCH and ARCH→ITP coverage. Matrix C built by extending `build-matrix.sh`. AI handles creative decomposition; scripts handle all verification. |
| III. Specification as Source of Truth | ✅ PASS | `system-design.md` is the input to architecture-design; `architecture-design.md` is the input to integration-test. Strict translator constraint prevents AI from inventing capabilities. Derived modules flagged with `[DERIVED MODULE]`, cross-cutting modules tagged `[CROSS-CUTTING]` with rationale. |
| IV. Git as QMS | ✅ PASS | All new artifacts are plaintext Markdown in Git. Feature branch `003-architecture-integration` with PR-based merge. CI gates enforce structural validators on every push. |
| V. Human-in-the-Loop | ✅ PASS | Commands generate drafts. Human reviews via PR. Derived Module flags require human resolution. Anti-Pattern Guards reject black-box descriptions without interface contracts. |

No violations. No complexity tracking required.

## Project Structure

### Documentation (this feature)

```text
specs/003-architecture-integration/
├── plan.md              # This file (/speckit.plan output)
├── research.md          # Phase 0 output — technology decisions
├── spec.md              # Feature specification (5 user stories, 29+ FRs)
├── checklists/
│   └── requirements.md  # Spec quality validation checklist
└── v-model/
    ├── requirements.md          # 61 traceable requirements (REQ-NNN)
    ├── acceptance-plan.md       # 86 ATPs + 86 SCNs (100% coverage)
    ├── system-design.md         # 12 SYS components (100% REQ coverage)
    ├── system-test.md           # 27 STPs + 64 STSs (100% SYS coverage)
    └── traceability-matrix.md   # Matrix A + B (100% bidirectional coverage)
```

### Source Code (new/modified files for v0.3.0)

```text
commands/
├── system-design.md           # EXISTING — unchanged
├── system-test.md             # EXISTING — unchanged
├── trace.md                   # MODIFIED — add Matrix C (SYS → ARCH → ITP → ITS)
├── architecture-design.md     # NEW — decompose SYS into ARCH modules (42010 + 4+1)
└── integration-test.md        # NEW — generate ISO 29119-4 integration test cases

scripts/
├── bash/
│   ├── setup-v-model.sh                  # MODIFIED — add --require-system-design flag, ARCH/ITP doc detection
│   ├── validate-architecture-coverage.sh # NEW — ARCH→ITP→ITS coverage validation (3-file input)
│   ├── build-matrix.sh                   # MODIFIED — add Matrix C parsing (ARCH→ITP→ITS)
│   ├── validate-requirement-coverage.sh              # EXISTING — unchanged
│   ├── validate-system-coverage.sh       # EXISTING — unchanged
│   └── diff-requirements.sh              # EXISTING — unchanged
└── powershell/
    ├── setup-v-model.ps1                     # MODIFIED — add -RequireSystemDesign, ARCH/ITP doc detection
    ├── validate-architecture-coverage.ps1    # NEW — PowerShell parity
    ├── build-matrix.ps1                      # MODIFIED — add Matrix C parsing
    └── (existing scripts unchanged)

templates/
├── architecture-design-template.md   # NEW — 42010 + 4+1 view structure
├── integration-test-template.md      # NEW — four-technique ITP/ITS structure
├── traceability-matrix-template.md   # MODIFIED — add Matrix C section
└── (existing templates unchanged)

tests/
├── evals/
│   ├── harness.py                             # MODIFIED — add COMMAND_TEMPLATES, COMMAND_AVAILABLE_DOCS
│   ├── conftest.py                            # MODIFIED — add architecture/integration fixture loaders
│   ├── test_architecture_design_eval.py       # NEW — structural evals (Mermaid validation)
│   ├── test_integration_test_eval.py          # NEW — structural evals
│   ├── test_e2e_architecture_design.py        # NEW — E2E (4 tests)
│   └── test_e2e_integration_test.py           # NEW — E2E (4 tests)
├── fixtures/golden/
│   ├── medical-device/
│   │   ├── expected-architecture-design.md    # NEW
│   │   └── expected-integration-test.md       # NEW
│   └── automotive-adas/
│       ├── expected-architecture-design.md    # NEW
│       └── expected-integration-test.md       # NEW
└── validators/
    ├── id_validator.py                        # MODIFIED — add ARCH/ITP/ITS patterns + hierarchy
    ├── template_validator.py                  # MODIFIED — add architecture + integration validators
    └── architecture_validators.py             # NEW — ARCH-specific validators (4 views, SYS trace)

docs/
├── v-model-overview.md      # MODIFIED — add Architecture ↔ Integration Testing level
├── compliance-guide.md      # MODIFIED — add IEEE 42010, ISO 29119-4, ASIL decomposition
└── usage-examples.md        # MODIFIED — add architecture/integration examples

extension.yml                # MODIFIED — version 0.3.0, 7 commands
catalog-entry.json           # MODIFIED — version 0.3.0, commands: 7
CHANGELOG.md                 # MODIFIED — add [0.3.0] section
README.md                    # MODIFIED — update workflow, command table, version badge
```

**Structure Decision**: Extension project — same structure as v0.2.0. New commands, templates, and scripts follow established conventions. No new directories at the top level.

## Research (Phase 0)

See [research.md](research.md) for detailed findings. Key decisions:

1. **Many-to-many SYS↔ARCH mapping** → Explicit "Parent System Components" field in Logical View (comma-separated SYS-NNN list) + `[CROSS-CUTTING]` tag for infrastructure modules (RQ-1).
2. **IEEE 42010 + 4+1 architecture views** → Four mandatory views: Logical, Process, Interface, Data Flow. Mermaid sequence diagrams in Process View (RQ-2).
3. **ISO 29119-4 integration test techniques** → Four techniques: Interface Contract Testing, Data Flow Testing, Interface Fault Injection, Concurrency & Race Condition Testing. Each anchored to a specific view (RQ-3).
4. **Safety-critical gating** → Existing `v-model-config.yml` `domain` field. ASIL Decomposition, Defensive Programming, Temporal Constraints for architecture; SIL/HIL, Resource Contention for integration test (RQ-4).
5. **Coverage validation** → Three-file positional args, partial execution support, cross-cutting module handling (RQ-5).
6. **Matrix C** → Separate table: SYS → ARCH → ITP → ITS with parent REQ annotations. Progressive: A, A+B, A+B+C (RQ-6).
7. **Section-scoped parsing** → build-matrix.sh must scope ARCH extraction to Logical View only, preventing the same bug fixed in v0.2.0's Decomposition View parsing (RQ-7).
8. **Mermaid validation** → Structural evals verify syntactic validity of generated Mermaid diagrams (RQ-8).

## Complexity Tracking

No constitution violations. No complexity justifications needed.
