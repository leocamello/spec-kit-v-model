# Contract: ARCH-016 — Structured Summary Reporter

- **Type**: Prompt section
- **Classification**: NEW-PROMPT-SECTION
- **Realised by**: §Structured Summary section in each of `commands/plan.md`, `commands/tasks.md`, `commands/implement.md`
- **Parent system component**: SYS-012 (Structured Summary)
- **Child modules**: MOD-021 (Structured Summary Reporter)
- **Parent requirements**: REQ-025, REQ-026, REQ-IF-004

## Preconditions

- None — emitted on every code path, including failure.

## Postconditions

- stdout contains `inputs_read[]`, `outputs_produced[]`, `artifacts_skipped[]`, `warnings[]`, `fatal_errors[]` per the `v-model.test-results` / `v-model.audit-report` summary grammar.
- The summary is wrapped in `--- v-model run summary ---` … `---` fences.
- Best-effort: never blocks the parent command from completing (system-design.md §Interface View row 433).
- Flushed on every exit path including failures (mitigates HAZ-025 — structured summary truncated).

## Expected sections

§Structured Summary in each command file (identical grammar across the three).

## Error path

n/a — the summary itself is the error reporting surface.

## Verification

- UTP-021-A (structural eval for summary grammar)
- ATP-025-A (summary present on success)
- ATP-026-A (summary present on failure with `fatal_errors[]`)
