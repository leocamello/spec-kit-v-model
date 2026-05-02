# Contract: ARCH-018 — Commit Annotator

- **Type**: Prompt section
- **Classification**: NEW-PROMPT-SECTION
- **Realised by**: `commands/implement.md` §Commit Annotation
- **Parent system component**: SYS-014 (Commit Annotator)
- **Child modules**: MOD-023 (Commit Annotator)
- **Parent requirements**: REQ-021

## Preconditions

- ARCH-009 (Hallucination Guard) has exited 0.
- The LLM has the list of V-Model IDs fulfilled by the change.

## Postconditions

- `git commit -m "<message> — <id>, <id>, …"` is issued (em-dash + comma-separated ID suffix).
- Empty ID list ⇒ commit proceeds with the original message and a warning entry in §Structured Summary.

## Expected sections in `commands/implement.md`

§Commit Annotation (suffix grammar + best-effort policy).

## Error path

`git commit` itself fails ⇒ propagate exit 1. Annotation construction failure is a warning, not fatal (best-effort per ATP-021-A).

## Verification

- ATP-021-A / SCN-021-A1 (commit subject regex match)
