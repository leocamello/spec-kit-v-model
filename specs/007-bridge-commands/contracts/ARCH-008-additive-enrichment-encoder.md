# Contract: ARCH-008 — Additive Enrichment Encoder

- **Type**: Prompt section
- **Classification**: NEW-PROMPT-SECTION
- **Realised by**: `commands/plan.md` §Enrichment + `commands/tasks.md` §Traceability
- **Parent system component**: SYS-005 (Additive Enrichment)
- **Child modules**: MOD-011 (Plan Enrichment Encoder), MOD-012 (Tasks Traceability Comment Encoder)
- **Parent requirements**: REQ-007, REQ-012, REQ-NF-003

## Preconditions

- The canonical document being enriched has already been validated by ARCH-013 (Schema Validator).

## Postconditions

- Enrichment is confined to HTML comments (`<!-- v-model: ... -->`) and optional Markdown sections.
- Canonical sections are NEVER modified (REQ-NF-003).
- The document continues to validate by ARCH-013 after enrichment (mitigates HAZ-002 enrichment-overwrites-core, HAZ-011 enrichment-shape-drift).

## Expected sections

- §Enrichment (HTML-comment grammar) in `commands/plan.md`
- §Traceability (comment placement rules) in `commands/tasks.md`

## Error path

Canonical doc fails post-enrichment validation ⇒ abort, do not write.

## Verification

- ATP-007-A (additive enrichment in plan.md)
- ATP-012-A / SCN-012-A1 (every task carries trace-to comment)
