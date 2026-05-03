# Contract: ARCH-003 — Tasks Synthesis Orchestrator

- **Type**: Prompt section
- **Classification**: NEW-PROMPT-SECTION
- **Realised by**: `commands/tasks.md` §Execution Flow
- **Parent system component**: SYS-002 (Tasks Synthesis)
- **Child modules**: MOD-003 (Tasks Synthesis Orchestrator), MOD-004 (TDD Task List Builder)
- **Parent requirements**: REQ-008, REQ-009, REQ-010, REQ-011, REQ-013

## Preconditions

- `feature_dir` contains `requirements.md`.
- `plan.md` may be absent, V-Model-enriched, or speckit-only (Hybrid path detection by ARCH-014).

## Postconditions

- `feature_dir/tasks.md` is written via inline `mktemp` + `mv` (D-016).
- Tasks are TDD-ordered per REQ-011 / SCN-011-A1 (write-unit-tests → implement → run-unit-tests → write-integration-tests → run-integration-tests → write-system-tests → run-system-tests → write-acceptance-tests).
- Independent modules carry the `[P]` parallel marker per REQ-013 / SCN-013-A1.
- Structured summary (ARCH-016) is printed.
- Exit code 0 on success; 1 on failure with summary still emitted.

## Expected sections in `commands/tasks.md`

§Execution Flow, §Hybrid Path Detection, §TDD Ordering, §Hazard Enrichment, §Traceability, §Structured Summary.

## Error path

ARCH-013 non-zero ⇒ abort before write; ARCH-014 cannot parse upstream ⇒ abort fail-closed.

## Verification

- ATP-008-A through ATP-011-A (per-requirement)
- ATP-013-A / SCN-013-A1 (parallel marker)
- UTP-011-A (structural eval for TDD ordering)
