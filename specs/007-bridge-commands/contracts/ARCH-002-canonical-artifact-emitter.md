# Contract: ARCH-002 — Canonical Artifact Emitter

- **Type**: Prompt section
- **Classification**: NEW-PROMPT-SECTION
- **Realised by**: `commands/plan.md` §Output Artifacts
- **Parent system component**: SYS-001 (Plan Synthesis)
- **Child modules**: MOD-002 (Canonical Output Emitter)
- **Parent requirements**: REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-NF-005

## Preconditions

- The in-memory canonical content for each emitted artifact has been validated by ARCH-013 (Schema Validator).

## Postconditions

- Each of `plan.md`, `data-model.md`, `contracts/<name>.md`, `quickstart.md`, `research.md` is written via the inline `mktemp` + `mv` 3-line idiom (D-016).
- An absent input ⇒ the corresponding artifact is skipped and logged in `artifacts_skipped[]` of §Structured Summary.
- No partial overwrite occurs (atomic-rename semantics).

## Expected sections in `commands/plan.md`

§Output Artifacts (file list + per-file required-sections + write pattern).

## Error path

Write failure ⇒ propagate, emit `fatal_errors[]`, exit 1; no partial overwrite (atomic move semantics, REQ-NF-005, HAZ-014, HAZ-025).

## Verification

- ATP-002-A / SCN-002-A1 (round-trip through unmodified `speckit.tasks`)
- ATP-002-B / SCN-002-B1 (section ordering preserved)
- ATP-003-A through ATP-006-A (per-artifact emission)
