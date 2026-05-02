# Contract: ARCH-007 — Pre-Implementation Gate

- **Type**: Shell script
- **Classification**: NEW-SHELL
- **Realised by**: `scripts/bash/run-v-model-gate.sh` (PLANNED; ~30 lines) + `scripts/powershell/run-v-model-gate.ps1` (PowerShell mirror per D-009)
- **Parent system component**: SYS-004 (Pre-Implementation Gate)
- **Child modules**: MOD-010 (Pre-Implementation Gate Coordinator)
- **Parent requirements**: REQ-016, REQ-017, REQ-NF-004, REQ-CN-002

## CLI invocation

```bash
bash scripts/bash/run-v-model-gate.sh <feature-dir>
```

PowerShell mirror:

```powershell
pwsh scripts/powershell/run-v-model-gate.ps1 -FeatureDir <feature-dir>
```

## Input args

- `<feature-dir>` (required, absolute or repo-relative path)

## Output — exit code

- `0` ⇔ every inner script exits 0
- `1` otherwise

## Output — stdout schema

Concatenated stdout of `build-matrix.sh` + each `validate-*-coverage.sh`, prefixed with `=== <script-name> ===`. Final line is exactly `GATE: PASS` or `GATE: FAIL`.

## Inner-script set (REUSE — D-003)

`scripts/bash/build-matrix.sh`, `scripts/bash/validate-requirement-coverage.sh`, `scripts/bash/validate-system-coverage.sh`, `scripts/bash/validate-architecture-coverage.sh`, `scripts/bash/validate-module-coverage.sh`, `scripts/bash/validate-hazard-coverage.sh`. Build-matrix invocation MUST use `--output <file>` rather than redirected stdout (D-012, REQ-NF-004).

## Side-effects

None (read-only against `<feature-dir>`).

## Error paths

Inner script non-zero ⇒ propagate, exit 1. Missing inner script ⇒ exit 1 with diagnostic on stderr.

## Verification

- ATP-017-A / SCN-017-A1 (process trace shows exactly the inner-script set; no other wrapper)
- UTP-010-A (BATS unit tests for the wrapper)
- HAZ-009 (false-negative gate) and HAZ-010 (false-positive gate) — both mitigated by reuse of validated inner scripts
