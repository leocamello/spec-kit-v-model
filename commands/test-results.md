---
description: Ingest JUnit XML test results and optional Cobertura XML code coverage into the traceability matrix (100% deterministic, no AI).
handoffs:
  - label: View Traceability Matrix
    agent: speckit.v-model.trace
    prompt: Build the full traceability matrix to see current coverage
    send: true
  - label: Run Impact Analysis
    agent: speckit.v-model.impact-analysis
    prompt: Analyze the impact of any failed test results on V-Model artifacts
scripts:
  sh: scripts/bash/ingest-test-results.sh
  ps: scripts/powershell/Ingest-Test-Results.ps1
---

## User Input

```text
$ARGUMENTS
```

## Goal

Ingest **JUnit XML** test results (and optionally **Cobertura XML** code coverage) into the existing `traceability-matrix.md`. This is a **100% deterministic, script-only command** — no AI generation is needed. The script parses XML files, matches test case names to V-Model scenario IDs (SCN, STS, ITS, UTS), and updates matrix statuses in-place.

The ingested results update the test documentation records defined by **ISO/IEC 29119-3:2013** (Test documentation — Test Completion Report and Test Status Report information items). Each matrix row becomes a machine-readable test result record linked to a V-Model scenario ID, satisfying the traceability requirement between test execution evidence and the test cases in the V-Model test plans.

## How to Use

This command is invoked directly via the script, not through AI generation:

### Bash
```bash
# Basic: ingest JUnit XML results
scripts/bash/ingest-test-results.sh --input test-results.xml specs/<feature>/v-model

# With code coverage (adds Coverage column to Matrix D)
scripts/bash/ingest-test-results.sh --input results.xml --coverage coverage.xml specs/<feature>/v-model

# With explicit matrix path
scripts/bash/ingest-test-results.sh --input results.xml --matrix path/to/traceability-matrix.md

# With coverage mapping override
scripts/bash/ingest-test-results.sh --input results.xml --coverage coverage.xml --coverage-map coverage-map.yml specs/<feature>/v-model

# With explicit commit SHA (instead of auto-detecting from HEAD)
scripts/bash/ingest-test-results.sh --input results.xml --commit-sha abc1234 specs/<feature>/v-model

# JSON output to stdout
scripts/bash/ingest-test-results.sh --input results.xml --json specs/<feature>/v-model
```

### PowerShell
```powershell
# Basic: ingest JUnit XML results
scripts/powershell/Ingest-Test-Results.ps1 -InputFile test-results.xml -VModelDir specs/<feature>/v-model

# With code coverage
scripts/powershell/Ingest-Test-Results.ps1 -InputFile results.xml -Coverage coverage.xml -VModelDir specs/<feature>/v-model

# JSON output
scripts/powershell/Ingest-Test-Results.ps1 -InputFile results.xml -Json -VModelDir specs/<feature>/v-model
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `--input <path>` | Yes | Path to JUnit XML file containing test results |
| `--coverage <path>` | No | Path to Cobertura XML file containing code coverage data |
| `--matrix <path>` | No | Path to `traceability-matrix.md` (defaults to `v-model/traceability-matrix.md` in the feature directory) |
| `--coverage-map <path>` | No | Path to `coverage-map.yml` for explicit MOD→files mapping (overrides convention) |
| `--commit-sha <sha>` | No | Explicit commit SHA (defaults to `git rev-parse --short=7 HEAD`) |
| `--json` | No | Output structured JSON to stdout instead of human-readable summary |
| `--help` | No | Display usage information |

## How It Works

### Architecture

```
User invokes:
  ingest-test-results.sh --input junit.xml [--coverage cobertura.xml] [--matrix matrix.md]

Flow:
  1. Bash/PS1 wrapper validates arguments, resolves matrix path
  2. Calls Python helper: parse_test_results.py --junit <file> [--cobertura <file>] [--coverage-map <file>]
  3. Python helper outputs JSON to stdout:
     {
       "test_results": [{"id": "SCN-001-A1", "matrix": "A", "status": "passed", ...}],
       "coverage": {"MOD-001": {"stmt": 98.2, "branch": 94.1, ...}},
       "summary": {"total": 50, "passed": 48, "failed": 1, "skipped": 1}
     }
  4. Bash/PS1 wrapper reads JSON, updates matrix in-place:
     - Replaces Status column value
     - Adds/updates Date + Commit SHA columns
     - For Matrix D: adds Actual Coverage column when --coverage provided
  5. Prints summary table to stdout
  6. Returns appropriate exit code
```

### ID Matching

Test case names in JUnit XML are matched against V-Model ID patterns:

| Matrix | Pattern | Example Match |
|--------|---------|---------------|
| A (Acceptance) | `SCN-[A-Z]*-?[0-9]{3}-[A-Z][0-9]+` | `SCN-001-A1 Given valid input` |
| B (System) | `STS-[A-Z]*-?[0-9]{3}-[A-Z][0-9]+` | `STS-002-B1 Threshold exceeded` |
| C (Integration) | `ITS-[A-Z]*-?[0-9]{3}-[A-Z][0-9]+` | `ITS-003-A1 Contract validation` |
| D (Unit) | `UTS-[A-Z]*-?[0-9]{3}-[A-Z][0-9]+` | `UTS-004-A1 Boundary at zero` |

### Status Values

| JUnit XML | Matrix Status |
|-----------|---------------|
| No `<failure>`, `<error>`, or `<skipped>` child | `✅ Passed` |
| `<failure>` or `<error>` child present | `❌ Failed` |
| `<skipped>` child present | `⏭️ Skipped` |

### Matrix Column Changes

**Before** (generated by `build-matrix.sh`):
```
| ... | Scenario ID (UTS) | Status |
| ... | UTS-001-A1 | ⬜ Untested |
```

**After** (test results ingested):
```
| ... | Scenario ID (UTS) | Status | Date | Commit |
| ... | UTS-001-A1 | ✅ Passed | 2026-04-05 | abc1234 |
```

**Matrix D with coverage** (when `--coverage` provided):
```
| ... | Scenario ID (UTS) | Status | Date | Commit | Coverage |
| ... | UTS-001-A1 | ✅ Passed | 2026-04-05 | abc1234 | 98.2% stmt / 94.1% branch |
```

### Coverage Mapping (Matrix D only)

When `--coverage` is provided with a Cobertura XML file, the script maps coverage data to MOD-NNN modules using two strategies:

1. **Convention (default)**: Parses `module-design.md` for source file path references per MOD-NNN section, matches against Cobertura `<class filename="...">` attributes.

2. **Override (`coverage-map.yml`)**: When present, takes precedence over convention:
   ```yaml
   mappings:
     - mod_id: MOD-001
       files: ["src/reader.py", "src/reader_utils.py"]
     - mod_id: MOD-002
       files: ["src/writer.py"]
   ```

## Output

### Human-Readable Summary (default)

```
=== Test Results Ingestion ===

Matrix A (Acceptance): 10/12 matched | 9 passed | 1 failed | 0 skipped
Matrix B (System):     8/8 matched  | 8 passed | 0 failed | 0 skipped
Matrix C (Integration): 5/6 matched | 5 passed | 0 failed | 0 skipped
Matrix D (Unit):       20/25 matched | 18 passed | 1 failed | 1 skipped

Total: 43/51 scenarios matched | 40 passed | 2 failed | 1 skipped
Unmatched JUnit tests: 3

Matrix updated: specs/005d-test-results/v-model/traceability-matrix.md
```

### JSON Output (`--json`)

```json
{
  "test_results": [
    {"id": "SCN-001-A1", "matrix": "A", "status": "passed", "duration": 0.5},
    {"id": "STS-002-B1", "matrix": "B", "status": "failed", "duration": 0.8, "message": "Expected alert within 100ms"}
  ],
  "coverage": {
    "MOD-001": {"stmt": 98.2, "branch": 94.1, "below_threshold": false, "formatted": "98.2% stmt / 94.1% branch"}
  },
  "summary": {
    "total": 43,
    "passed": 40,
    "failed": 2,
    "skipped": 1,
    "per_matrix": {
      "A": {"total": 10, "passed": 9, "failed": 1, "skipped": 0},
      "B": {"total": 8, "passed": 8, "failed": 0, "skipped": 0},
      "C": {"total": 5, "passed": 5, "failed": 0, "skipped": 0},
      "D": {"total": 20, "passed": 18, "failed": 1, "skipped": 1}
    },
    "unmatched_count": 3
  },
  "matrix_path": "specs/005d-test-results/v-model/traceability-matrix.md",
  "date": "2026-04-05",
  "commit": "abc1234"
}
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All matched tests passed |
| 1 | At least one matched test failed |
| 2 | No V-Model scenario IDs matched in the JUnit XML |

## Key Behaviors

- **In-place update** — the existing `traceability-matrix.md` is modified, not regenerated; manual annotations are preserved
- **Duplicate handling** — when a scenario ID appears multiple times in JUnit XML (retries), the last occurrence wins
- **Partial ingestion** — only rows matching scenario IDs in the JUnit XML are updated; unmatched rows keep `⬜ Untested`
- **Re-runnable** — subsequent ingestions overwrite previous statuses, dates, and commits with the latest values
- **Coverage threshold** — when `--coverage` is provided and a module's coverage falls below `coverage_threshold` from `extension.yml`, the Coverage column is flagged with `⚠`
- **Deprecated scenario handling** — when a scenario ID's parent artifact (ATP, STP, ITP, or MOD) is marked `[DEPRECATED]` in the corresponding V-Model artifact, the test result is **skipped** (not ingested into the matrix). Skipped scenarios are reported in the summary:
  - Human-readable: `⏭️ 3 scenarios skipped (deprecated parent artifacts)`
  - JSON output includes a `skipped_deprecated` array:
    ```json
    {
      "skipped_deprecated": [
        {"id": "SCN-003-A1", "reason": "Parent ATP-003-A is [DEPRECATED — Superseded by ATP-015-A]"},
        {"id": "STS-005-B1", "reason": "Parent STP-005-B is [DEPRECATED — Withdrawn: component removed]"}
      ]
    }
    ```
  - Deprecated scenarios do not count toward pass/fail/skip totals and do not affect the exit code

## Quality Criteria

- The command is **100% deterministic**: same inputs always produce the same output
- The Python helper uses **only standard library** modules (zero external dependencies)
- The command handles up to **10,000 test cases** within 30 seconds
- Bash and PowerShell produce **identical JSON structure** and exit codes

## Governing Standards

This command is governed by the following standards for test results ingestion:

| Standard | Full Name | Role in this Command |
|----------|-----------|----------------------|
| **ISO/IEC 29119-3:2013** | Software and Systems Engineering — Software Testing — Part 3: Test Documentation | Test documentation governance: the updated traceability matrix constitutes a **Test Status Report** (§9.2) and — after the final test cycle — a **Test Completion Report** (§9.3). Each ingested scenario result provides the execution evidence (date, commit SHA, pass/fail status) required by ISO 29119-3 for test records. |
| **JUnit XML** | Apache Ant JUnit XML Report Format (de facto standard) | Input format for test execution results. The V-Model scenario ID must appear in the JUnit test case `name` attribute for matching to succeed. |
| **Cobertura XML** | Cobertura Code Coverage Report Format (de facto standard) | Optional input format for structural coverage data. Coverage data is mapped to `MOD-NNN` modules and stored in the Matrix D `Coverage` column. |

> **Domain extensions:** If a domain overlay is loaded, coverage threshold values in `extension.yml` may be overridden by domain-specific structural coverage requirements (e.g., MC/DC thresholds per ASIL or DAL), and the `⚠` flag threshold will reflect the domain-mandated minimum.
