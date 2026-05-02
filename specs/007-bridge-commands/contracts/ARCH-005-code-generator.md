# Contract: ARCH-005 — Code Generator

- **Type**: Prompt section
- **Classification**: NEW-PROMPT-SECTION
- **Realised by**: `commands/implement.md` §Code Generation + §Traceability Comments
- **Parent system component**: SYS-003 (Implementation)
- **Child modules**: MOD-006 (Code Generator — per-MOD dispatch), MOD-007 (Module Source Renderer)
- **Parent requirements**: REQ-018, REQ-019

## Preconditions

- Each `MOD-NNN` row in `module-design.md` declares a Target Source File and a target language.

## Postconditions

- Generated content per `MOD-NNN` is spliced through ARCH-010 (Source Region Splicer).
- Each emitted region carries at least one language-appropriate `Implements <ID>` comment.
- Each public symbol carries an `Implements` comment per REQ-019 / SCN-019-A1.

## Expected sections in `commands/implement.md`

§Code Generation (per-MOD generation rules), §Traceability Comments (comment syntax per language).

## Error path

ARCH-010 non-zero (overlapping markers) ⇒ abort before write (HAZ-014).

## Verification

- ATP-018-A / SCN-018-A1 (target-source-file mapping)
- ATP-019-A / SCN-019-A1 (per-public-symbol coverage)
