# Contract: ARCH-004 — Implementation Orchestrator

- **Type**: Prompt section
- **Classification**: NEW-PROMPT-SECTION
- **Realised by**: `commands/implement.md` §Execution Flow
- **Parent system component**: SYS-003 (Implementation)
- **Child modules**: MOD-005 (Implementation Orchestrator)
- **Parent requirements**: REQ-015, REQ-016, REQ-017, REQ-NF-004

## Preconditions

- `feature_dir` contains `requirements.md`, `module-design.md`, and all four V-Model test plans (`unit-test.md`, `integration-test.md`, `system-test.md`, `acceptance-plan.md`).
- The Pre-Implementation Gate (ARCH-007) exits 0.

## Postconditions

- Source + test files are written through ARCH-005 / ARCH-006 / ARCH-010.
- ARCH-009 (Hallucination Guard) exits 0 before any commit.
- Commit is produced via ARCH-018 (Commit Annotator).

## Expected sections in `commands/implement.md`

§Execution Flow, §Code Generation, §Traceability Comments, §Test Generation, §Test Levels, §Domain Overlay, §Quality Compliance, §Commit Annotation, §Structured Summary.

## Error path

Any of {gate, splicer, hallucination guard} non-zero ⇒ abort before commit; emit `fatal_errors[]`, exit 1. No partial commit is ever produced (ARCH-007 strictly precedes ARCH-005 / ARCH-006; ARCH-009 strictly precedes ARCH-018; HAZ-007, HAZ-009, HAZ-014).

## Verification

- ATP-015-A / SCN-015-A1 (self-sufficient direct path)
- ATP-016-A / ATP-016-B / SCN-016-A1 / SCN-016-B1 (gate refusal)
- See `quickstart.md` Walkthrough 3
