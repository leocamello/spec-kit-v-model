# Contract: ARCH-009 — Hallucination Guard

- **Type**: Shell script
- **Classification**: NEW-SHELL
- **Realised by**: `scripts/bash/validate-implements-ids.sh` (PLANNED; `grep` + `awk`, ~80 lines) + `scripts/powershell/validate-implements-ids.ps1` (PowerShell mirror per D-009)
- **Parent system component**: SYS-006 (Hallucination Guard)
- **Child modules**: MOD-013 (Hallucination Guard), MOD-025 (Canonical ID-Set Extractor — inline `grep`)
- **Parent requirements**: REQ-023, REQ-NF-002

## CLI invocation

```bash
bash scripts/bash/validate-implements-ids.sh <feature-dir>
```

PowerShell mirror:

```powershell
pwsh scripts/powershell/validate-implements-ids.ps1 -FeatureDir <feature-dir>
```

## Input args

- `<feature-dir>` (required); the script discovers generated source files and the V-Model artifact set itself.

## Algorithm (D-004)

1. Extract canonical V-Model ID set via `grep -hoE '(REQ|SYS|ARCH|MOD|HAZ|ATP|ITP|UTP|STP)-[A-Z0-9-]+' <feature-dir>/v-model/*.md | sort -u`.
2. Scan every generated source file for `Implements <ID>` (and language-equivalent) comments.
3. Print any unrecognised ID as `<file>:<line>: unknown id <id>`.
4. Exit 1 if any unknown IDs are found (emit `GUARD: FAIL`); exit 0 otherwise (emit `GUARD: PASS`).

No LLM call is involved (Constitution Principle II — determinism).

## Output — exit code

- `0` ⇔ every `Implements <ID>` comment references an ID present in the V-Model artifact set
- `1` otherwise

## Output — stdout schema

One line per offending occurrence: `<file>:<line>: unknown id <id>`. Final line is exactly `GUARD: PASS` or `GUARD: FAIL`.

## Side-effects

None (read-only).

## Error paths

Unknown ID found ⇒ exit 1. Missing feature dir ⇒ exit 1 with diagnostic on stderr.

## Verification

- ATP-019-A / SCN-019-A1
- UTP-013-A, UTP-025-A
- HAZ-007 (hallucinated `Implements` comment), HAZ-012 (false-negative), HAZ-023 (stale snapshot — mitigated by invocation-order constraint in `commands/implement.md` per D-004)
