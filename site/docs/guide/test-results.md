---
title: Test Results Ingestion
description: Ingest JUnit XML test results and Cobertura coverage into the traceability matrix — deterministic, script-only, no AI required.
---

# Test Results Ingestion

Test results ingestion is a **100% deterministic, script-only command** — no AI generation needed. The script parses JUnit XML files, matches test case names to V-Model scenario IDs, and updates matrix statuses in-place.

---

## Command

### `/speckit.v-model.test-results`

=== "Bash"

    ```bash
    # Basic: ingest JUnit XML results
    scripts/bash/ingest-test-results.sh \
      --input test-results.xml \
      specs/<feature>/v-model

    # With code coverage (adds Coverage column to Matrix D)
    scripts/bash/ingest-test-results.sh \
      --input results.xml \
      --coverage coverage.xml \
      specs/<feature>/v-model

    # With coverage mapping override
    scripts/bash/ingest-test-results.sh \
      --input results.xml \
      --coverage coverage.xml \
      --coverage-map coverage-map.yml \
      specs/<feature>/v-model

    # With explicit commit SHA
    scripts/bash/ingest-test-results.sh \
      --input results.xml \
      --commit-sha abc1234 \
      specs/<feature>/v-model

    # JSON output for CI
    scripts/bash/ingest-test-results.sh \
      --input results.xml --json \
      specs/<feature>/v-model
    ```

=== "PowerShell"

    ```powershell
    # Basic: ingest JUnit XML results
    scripts/powershell/Ingest-Test-Results.ps1 `
      -InputFile test-results.xml `
      -VModelDir specs/<feature>/v-model

    # With code coverage
    scripts/powershell/Ingest-Test-Results.ps1 `
      -InputFile results.xml `
      -Coverage coverage.xml `
      -VModelDir specs/<feature>/v-model

    # JSON output
    scripts/powershell/Ingest-Test-Results.ps1 `
      -InputFile results.xml -Json `
      -VModelDir specs/<feature>/v-model
    ```

### Arguments

| Argument | Required | Description |
|---|---|---|
| `--input <path>` | Yes | Path to JUnit XML file containing test results |
| `--coverage <path>` | No | Path to Cobertura XML file containing code coverage data |
| `--matrix <path>` | No | Path to `traceability-matrix.md` (defaults to auto-detect) |
| `--coverage-map <path>` | No | Path to `coverage-map.yml` for explicit MOD→files mapping |
| `--commit-sha <sha>` | No | Explicit commit SHA (defaults to `git rev-parse --short=7 HEAD`) |
| `--json` | No | Output structured JSON to stdout |

---

## How It Works

### JUnit XML Parsing

The script reads JUnit XML test results (the standard format produced by most test frameworks) and matches test case names to V-Model scenario IDs:

| JUnit Test Name Pattern | Matched V-Model ID |
|---|---|
| `test_SCN_001_A1_*` | `SCN-001-A1` |
| `STS_002_B1_*` | `STS-002-B1` |
| `ITS_003_A1_*` | `ITS-003-A1` |
| `UTS_005_A2_*` | `UTS-005-A2` |

### Matrix Status Updates

The traceability matrix is updated in-place with test results:

| Before | JUnit Result | After |
|---|---|---|
| ⬜ Untested | `<testcase>` passes | ✅ Passed |
| ⬜ Untested | `<testcase>` fails | ❌ Failed |
| ⬜ Untested | `<testcase>` skipped | ⏭️ Skipped |
| ✅ Passed | `<testcase>` fails | ❌ Failed |

### Audit Metadata

Each matrix update includes audit metadata columns:

| Column | Source | Example |
|---|---|---|
| **Date** | Ingestion timestamp | `2025-01-15` |
| **Commit SHA** | `--commit-sha` or `git rev-parse` | `abc1234` |
| **Coverage** | Cobertura XML (if provided) | `87.3%` |

---

## Coverage Mapping

When `--coverage` is provided, the script maps Cobertura coverage data to `MOD-NNN` modules using one of two strategies:

### Convention-Based Mapping (Default)

The script infers file-to-module mapping from naming conventions:

```
src/parser/validate_schema.py  →  MOD-002 (validate_schema)
src/api/handle_create.py       →  MOD-005 (handle_create)
```

### Explicit Mapping via `coverage-map.yml`

For projects where naming conventions don't match, provide an explicit mapping:

```yaml
# coverage-map.yml
modules:
  MOD-001:
    files:
      - src/parser/parse_input.py
      - src/parser/tokenizer.py
  MOD-002:
    files:
      - src/parser/validate_schema.py
  MOD-005:
    files:
      - src/api/handlers/create.py
      - src/api/handlers/create_helpers.py
```

Use the `--coverage-map` argument to specify this file.

---

## Related Pages

- [V-Model Concepts](concepts.md) — Understanding the traceability matrix
- [Level 4: Module Design ↔ Unit Testing](module-unit.md) — Where unit test coverage feeds Matrix D
- [Audit Report](audit-report.md) — Test results in the release audit
- [CI Integration](ci-integration.md) — Automated test result ingestion
