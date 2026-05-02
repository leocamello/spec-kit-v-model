# Contract: ARCH-021 — Filesystem Writer (Deferred)

- **Type**: Deferred risk note (no functional contract)
- **Classification**: DROP-recharacterized
- **Parent**: `[CROSS-CUTTING] [DEFERRED]`

## Rationale

`[CROSS-CUTTING] [DEFERRED]` — atomic writes are realised by the inline 3-line `mktemp` + `mv` pattern used directly inside shell scripts and at every call site that writes a file produced by ARCH-010 (D-016). No runtime writer module exists. Recorded for traceability only; no functional contract.

## Reference

See `drift-diff-plan.md` §Proposed Net-New Component Inventory ("ARCH-021 dropped — this is a 3-line pattern, not a module") and `plan.md` §Project Structure for the call-site visibility rule.

## Status

No source code, no script, no test scope. The atomic-write idiom is the SOLE concurrency safeguard delivered for SYS-015 in v0.7.0; process-wide locking is deferred per SYS-015 §Risk Note. See ARCH-010 contract for the in-force atomic-write contract at the splicer's call sites.
