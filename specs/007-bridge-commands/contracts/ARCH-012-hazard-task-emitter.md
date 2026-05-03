# Contract: ARCH-012 — Hazard Task Emitter

- **Type**: Prompt section
- **Classification**: NEW-PROMPT-SECTION
- **Realised by**: `commands/tasks.md` §Hazard Enrichment
- **Parent system component**: SYS-009 (Hazard-Driven Tasks)
- **Child modules**: MOD-016 (Hazard-Driven Task Enricher)
- **Parent requirements**: REQ-014

## Preconditions

- `hazard-analysis.md` is present in `feature_dir`.

## Postconditions

- The TDD task list contains exactly one verification task per `HAZ-NNN` whose title begins with `Verify mitigation for HAZ-NNN` (per SCN-014-B1).
- Mitigation tasks have raised priority (per SCN-014-A1).
- Each enriched task carries a `<!-- traces-to: ..., HAZ-NNN -->` comment (ARCH-008).

## Expected sections in `commands/tasks.md`

§Hazard Enrichment (priority-raise rule + verification-task template).

## Error path

`hazard-analysis.md` malformed ⇒ abort fail-closed (HAZ-016 — hazard-driven tasks not emitted).

## Verification

- ATP-014-A / SCN-014-A1 (mitigation tasks flagged higher priority)
- ATP-014-B / SCN-014-B1 (dedicated verification task per HAZ)
