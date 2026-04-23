# Audit Report: Missing Required Artifacts

**Expected Outcome**: ERROR — Exit code 2

The `build-audit-report.sh` script requires `requirements.md` and `traceability-matrix.md`
to be present in the V-Model directory. When these required artifacts are absent, the script
exits immediately with code 2 and the following error on stderr:

```
ERROR: Required artifact missing: requirements.md
```

No audit report file is generated. This is the expected behavior for the `missing-required`
scenario, which contains only `traceability-matrix.md` with no `requirements.md` present.

## Scenario Files

| File | Status |
|------|--------|
| `requirements.md` | ❌ Missing (required) |
| `traceability-matrix.md` | ✅ Present |

## Expected Exit Code

| Exit Code | Meaning |
|-----------|---------|
| 2 | Error — missing required artifact |
