# Contract: ARCH-020 — Subprocess Runner (Deferred)

- **Type**: Deferred risk note (no functional contract)
- **Classification**: DROP-recharacterized
- **Parent**: `[CROSS-CUTTING] [DEFERRED]`

## Rationale

`[CROSS-CUTTING] [DEFERRED]` — shell scripts invoke other shell scripts via `bash` directly; the implicit allowlist is the contents of `scripts/bash/`. No runtime subprocess module exists. Recorded for traceability only; no functional contract.

## Reference

See `drift-diff-plan.md` §Proposed Net-New Component Inventory (DROP classification rationale).

## Status

No source code, no script, no test scope. Deferred to a future iteration if and when a sandboxed subprocess broker proves necessary.
