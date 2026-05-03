# Contract: ARCH-011 — Domain Overlay Loader

- **Type**: Prompt section
- **Classification**: NEW-PROMPT-SECTION
- **Realised by**: `commands/implement.md` §Domain Overlay
- **Parent system component**: SYS-008 (Domain Overlay)
- **Child modules**: MOD-015 (Domain Overlay Adapter)
- **Parent requirements**: REQ-024

## Preconditions

- None — applies if `v-model-config.yml` is present at the repository root, otherwise no overlay is loaded.

## Postconditions

- Code- and test-generation prompts are augmented (additively only) per the `domain:` value (e.g., `automotive`, `medical`, `aerospace`).
- Base instructions are NEVER overridden.

## Expected sections in `commands/implement.md`

§Domain Overlay (file-presence check + per-domain prompt augmentation rules).

## Side-effects

None at this contract's level — augmented prompts feed ARCH-005 / ARCH-006.

## Error path

`v-model-config.yml` present but malformed (unparseable YAML, missing `domain:` key, or domain dir absent) ⇒ abort fail-closed with non-zero exit.

## Verification

- ATP-024-A (domain overlay load — automotive)
- ATP-024-B (overlay absent — base behavior)
