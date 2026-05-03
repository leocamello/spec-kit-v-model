# Contract: ARCH-014 — Reduced-Enrichment Fallback

- **Type**: Prompt section
- **Classification**: NEW-PROMPT-SECTION
- **Realised by**: `commands/tasks.md` §Hybrid Path Detection
- **Parent system component**: SYS-010 (Schema Validator) — Hybrid path concern
- **Child modules**: MOD-019 (Hybrid Path Enrichment Detector)
- **Parent requirements**: REQ-028, REQ-029

## Preconditions

- A `plan.md` exists at `feature_dir/plan.md`.

## Postconditions

- If V-Model enrichment markers (Entity 5 of `data-model.md`) are absent ⇒ the LLM derives traceability from the V-Model artifact set directly (Hybrid path, REQ-028).
- If enrichment markers are present ⇒ the LLM consumes them as-is.
- Either way, the resulting `tasks.md` carries complete `<!-- traces-to: -->` comments per ARCH-008 / SCN-012-A1.

## Expected sections in `commands/tasks.md`

§Hybrid Path Detection (decision rule + fallback procedure).

## Error path

Upstream `plan.md` cannot be parsed at all ⇒ abort fail-closed.

## Verification

- ATP-028-A (hybrid path with speckit-only plan.md)
- ATP-029-A (full path with V-Model-enriched plan.md)
