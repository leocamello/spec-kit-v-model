# Contract: ARCH-006 — Test Generator

- **Type**: Prompt section
- **Classification**: NEW-PROMPT-SECTION
- **Realised by**: `commands/implement.md` §Test Generation + §Test Levels
- **Parent system component**: SYS-003 (Implementation)
- **Child modules**: MOD-008 (Test Generator — per-level dispatch), MOD-009 (Per-Level Test Renderer)
- **Parent requirements**: REQ-020

## Preconditions

- `unit-test.md`, `integration-test.md`, `system-test.md`, `acceptance-plan.md` are present.

## Postconditions

- Tests are emitted at all four V-Model levels (unit / integration / system / acceptance) into the project's existing test directories.
- Each test references the source `UTP/ITP/STP/ATP` ID via an `Implements <ID>` comment.
- At least one test file appears under each of `tests/unit/`, `tests/integration/`, `tests/system/`, `tests/acceptance/` per SCN-020-A1.

## Expected sections in `commands/implement.md`

§Test Generation (per-level rules), §Test Levels (mapping artifact → directory).

## Error path

Any test-plan artifact fails to parse ⇒ abort fail-closed.

## Verification

- ATP-020-A / SCN-020-A1
