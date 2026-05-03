# Contract: ARCH-013 — Schema Validator

- **Type**: Shell script
- **Classification**: NEW-SHELL
- **Realised by**: `scripts/bash/validate-core-schema.sh` (PLANNED; `grep`, ~50 lines) + `scripts/powershell/validate-core-schema.ps1` (PowerShell mirror per D-009)
- **Parent system component**: SYS-010 (Schema Validator)
- **Child modules**: MOD-017 (Plan Schema Validator — `--plan`), MOD-018 (Tasks Schema Validator — `--tasks`)
- **Parent requirements**: REQ-002, REQ-008, REQ-NF-002

## CLI invocation

```bash
bash scripts/bash/validate-core-schema.sh <file> --plan|--tasks
```

PowerShell mirror:

```powershell
pwsh scripts/powershell/validate-core-schema.ps1 -File <file> -Mode plan|tasks
```

## Input args

- `<file>` (path to `plan.md` or `tasks.md`)
- `--plan` or `--tasks` selects the pinned schema (canonical `plan-template.md` / `tasks-template.md` of spec-kit core, pinned at v0.7.0)

## Output — exit code

- `0` ⇔ every required section of the v0.7.0 pinned schema is present in canonical order
- `1` otherwise

## Output — stdout schema

One line per missing or out-of-order section: `<section>: MISSING` or `<section>: OUT_OF_ORDER`. Final line is exactly `SCHEMA: PASS (pinned_version=v0.7.0)` or `SCHEMA: FAIL`.

## Side-effects

None (read-only) — never mutates `<file>`.

## Error paths

Required section missing or out of order ⇒ exit 1.

## Verification

- UTP-017-A (plan schema validation)
- UTP-018-A (tasks schema validation)
- ATP-002-A / ATP-002-B (round-trip + ordering)
- ATP-011-A (TDD ordering through schema)
