# Contract: ARCH-010 — Source Region Splicer

- **Type**: Shell script
- **Classification**: NEW-SHELL
- **Realised by**: `scripts/bash/splice-managed-regions.sh` (PLANNED; `awk`, ~85 lines) + `scripts/powershell/splice-managed-regions.ps1` (PowerShell mirror per D-009)
- **Parent system components**: SYS-007 (Source Region Preservation), SYS-015 (Concurrent Write Safety)
- **Child modules**: MOD-014 (Source Region Splicer)
- **Parent requirements**: REQ-022, REQ-NF-005, REQ-CN-003, REQ-CN-004

## CLI invocation

```bash
bash scripts/bash/splice-managed-regions.sh <target-file> <generated-content> <language>
```

PowerShell mirror:

```powershell
pwsh scripts/powershell/splice-managed-regions.ps1 -Target <target-file> -Content <generated-content> -Language <language>
```

## Input args

- `<target-file>` (path, may not exist)
- `<generated-content>` (path to file containing the generated region)
- `<language>` (one of `bash`, `pwsh`, `python`, `js`, `ts`, …) — selects the comment-marker syntax per D-015

## Marker grammar (D-015)

`<!-- BEGIN MANAGED id="<MOD-NNN>" -->` and `<!-- END MANAGED id="<MOD-NNN>" -->`, or the language-equivalent comment syntax (`# BEGIN MANAGED id="…" #`, `// BEGIN MANAGED id="…" //`, etc.). Sentinels themselves are never rewritten unless the splicer detects an unbalanced or overlapping pair.

## Output — exit code

- `0` on clean splice
- `1` on overlapping or unbalanced markers

## Output — stdout schema

- Success: spliced content written to stdout
- Conflict: no stdout; diff report on stderr

## Side-effects

None — the **caller** is responsible for the atomic write of stdout via the `mktemp` + `mv` 3-line idiom (D-016). This is the SOLE concurrency safeguard delivered for SYS-015 in v0.7.0; process-wide locking is deferred per SYS-015 §Risk Note.

## Error paths

Overlapping V-Model markers ⇒ exit 1 with diff report on stderr; original file untouched.

## Verification

- UTP-014-A (BATS unit tests for the splicer)
- ATP-018-A / SCN-018-A1 (target-source-file mapping)
- ATP-022-A (code outside managed region untouched)
- HAZ-014 (region-marker corruption), HAZ-025 (truncated content)
