# Implementation Plan: System Design ↔ System Testing

**Branch**: `002-system-design-testing` | **Date**: 2026-02-20 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/002-system-design-testing/spec.md`

## Summary

Extend the V-Model Extension Pack from Requirements ↔ Acceptance Testing (v0.1.0) down one level to System Design ↔ System Testing (v0.2.0). Add two new AI-powered commands (`/speckit.v-model.system-design` and `/speckit.v-model.system-test`), a deterministic coverage validation script (`validate-system-coverage.sh`), extended traceability matrix support (Matrix B), and corresponding templates. The system design command decomposes requirements into IEEE 1016-compliant components; the system test command generates ISO 29119-compliant test cases paired to those components.

## Technical Context

**Language/Version**: Bash 5.x (scripts), Markdown (commands/templates), Python 3.10+ (testing only)
**Primary Dependencies**: Spec Kit CLI v0.1.0+ (host framework), GitHub Copilot (AI execution engine), V-Model Extension v0.1.0 (base commands and scripts)
**Storage**: Git-tracked plaintext Markdown files (no database)
**Testing**: BATS 1.11+ (Bash), Pester 5.x (PowerShell), pytest 8.x + DeepEval 2.x (Python evals)
**Target Platform**: Cross-platform (Linux, macOS, Windows via PowerShell equivalents)
**Project Type**: Spec Kit extension — extending existing v0.1.0 extension with new V-level
**Performance Goals**: Deterministic scripts complete in under 5 seconds for documents with up to 200 requirements; AI commands handle 200+ REQ inputs without truncation
**Constraints**: No external services required at runtime; all coverage calculations by deterministic scripts; backward compatible with v0.1.0 artifacts; safety-critical sections gated by `v-model-config.yml`
**Scale/Scope**: Extension targeting regulated-industry teams; documents with 10–200+ requirements per specification; many-to-many REQ↔SYS relationships

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Evidence |
|-----------|--------|----------|
| I. V-Model Discipline | ✅ PASS | Two new commands enforce paired generation: system-design (left side) ↔ system-test (right side). ID schema extended: `SYS-NNN` → `STP-NNN-X` → `STS-NNN-X#` mirrors `REQ → ATP → SCN`. 100% bidirectional coverage enforced by `validate-system-coverage.sh`. |
| II. Deterministic Verification | ✅ PASS | New `validate-system-coverage.sh` uses regex-based parsing for REQ→SYS and SYS→STP coverage. Matrix B built by extending `build-matrix.sh`. AI handles creative decomposition; scripts handle all verification. |
| III. Specification as Source of Truth | ✅ PASS | `requirements.md` is the input to system-design; `system-design.md` is the input to system-test. Strict translator constraint prevents AI from inventing capabilities not in the source. Derived requirements flagged, not silently added. |
| IV. Git as QMS | ✅ PASS | All new artifacts are plaintext Markdown in Git. Feature branch `002-system-design-testing` with PR-based merge. CI gates enforce structural validators on every push. |
| V. Human-in-the-Loop | ✅ PASS | Commands generate drafts. Human reviews via PR. Derived Requirement flags (`[DERIVED REQUIREMENT: ...]`) require human resolution. Anti-Pattern Guards in requirements command catch AI failure patterns before human review. |

No violations. No complexity tracking required.

## Project Structure

### Documentation (this feature)

```text
specs/002-system-design-testing/
├── plan.md              # This file (/speckit.plan output)
├── research.md          # Phase 0 output — technology decisions
├── spec.md              # Feature specification (5 user stories, 19 FRs)
├── checklists/
│   └── requirements.md  # Spec quality validation checklist
├── v-model/
│   ├── requirements.md      # 48 traceable requirements (REQ-NNN)
│   ├── acceptance-plan.md   # 62 ATPs + 62 SCNs (100% coverage)
│   └── traceability-matrix.md  # Generated after implementation (Step 7)
└── tasks.md             # Implementation tasks (/speckit.tasks output)
```

### Source Code (new/modified files for v0.2.0)

```text
commands/
├── requirements.md          # EXISTING — enhanced with Anti-Pattern Guards §4.5
├── acceptance.md            # EXISTING — unchanged
├── trace.md                 # MODIFIED — extended for Matrix B (REQ→SYS→STP→STS)
├── system-design.md         # NEW — decompose requirements into IEEE 1016 components
└── system-test.md           # NEW — generate ISO 29119 system test cases

scripts/
├── bash/
│   ├── setup-v-model.sh             # EXISTING — unchanged
│   ├── validate-requirement-coverage.sh         # EXISTING — unchanged
│   ├── validate-system-coverage.sh  # NEW — REQ→SYS and SYS→STP coverage validation
│   ├── build-matrix.sh              # MODIFIED — extended for Matrix B data
│   └── diff-requirements.sh         # EXISTING — unchanged
└── powershell/
    ├── validate-system-coverage.ps1  # NEW — PowerShell parity
    └── build-matrix.ps1              # MODIFIED — extended for Matrix B data

templates/
├── requirements-template.md          # EXISTING — Guard 1 comment added
├── acceptance-plan-template.md       # EXISTING — unchanged
├── traceability-matrix-template.md   # MODIFIED — Matrix A + Matrix B sections
├── system-design-template.md         # NEW — IEEE 1016 design view structure
└── system-test-template.md           # NEW — ISO 29119 three-tier STP/STS structure

tests/
├── bats/
│   └── validate-system-coverage.bats  # NEW — BATS tests for new validation script
├── pester/
│   └── validate-system-coverage.tests.ps1  # NEW — Pester tests for PS script
├── evals/
│   ├── test_system_design_eval.py     # NEW — LLM-as-judge for system design quality
│   └── test_system_test_eval.py       # NEW — LLM-as-judge for system test quality
├── fixtures/
│   ├── system-design-minimal/         # NEW — minimal fixture set
│   ├── system-design-complex/         # NEW — many-to-many, cross-cutting NFRs
│   ├── system-design-gaps/            # NEW — orphaned components, missing coverage
│   └── system-design-empty/           # NEW — edge case: empty design
└── validators/
    └── system_validators.py           # NEW — SYS/STP/STS ID format validators

docs/
├── v-model-overview.md      # MODIFIED — add System Design ↔ System Testing level
├── compliance-guide.md      # MODIFIED — add IEEE 1016 and ISO 29119 references
└── usage-examples.md        # MODIFIED — add system design/test command examples

extension.yml                # MODIFIED — version 0.2.0, 5 commands, 1 hook
```

**Structure Decision**: Extension project — same structure as v0.1.0. New
commands, templates, and scripts follow established conventions. No new
directories at the top level. Test fixtures organized by feature complexity.

## Research (Phase 0)

See [research.md](research.md) for detailed findings. Key decisions:

1. **Many-to-many REQ↔SYS mapping** → Explicit "Parent Requirements" field in Decomposition View (comma-separated REQ-NNN list). No lookup tables.
2. **IEEE 1016 design views** → Four mandatory views: Decomposition, Dependency, Interface, Data Design. Each component appears in all relevant views.
3. **ISO 29119 test techniques** → Named techniques mandatory per test case. External vs internal interface distinction enforced.
4. **Safety-critical gating** → `v-model-config.yml` `domain` field controls FFI, Restricted Complexity, MC/DC, WCET sections. Omitted by default.
5. **Derived Requirements** → `[DERIVED REQUIREMENT: description]` flag in output. No silent SYS-NNN addition.
6. **Dual-matrix traceability** → Matrix A (Validation) and Matrix B (Verification) as separate tables in traceability output.

## Complexity Tracking

No constitution violations. No complexity justifications needed.
