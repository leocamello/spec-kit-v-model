# Feature 005d: Test Results Ingestion

## Problem Statement

The V-Model traceability matrix shows test plans — every scenario has `⬜ Untested` status. But auditors need evidence that tests were actually executed and passed. In regulated domains (medical devices, automotive, aerospace), the gap between "we planned to test it" and "we proved it works" is a critical compliance failure. A traceability matrix full of `⬜ Untested` entries is insufficient evidence for release certification.

Additionally, in safety-critical domains like DO-178C and ISO 26262, proving that tests passed is not enough — auditors must also see that the tests achieved sufficient **structural code coverage** (statement, branch, MC/DC). A JUnit XML file proves the test executed; it does not prove the test covered the code.

There is currently no automated way to:
1. Parse CI test results (JUnit XML) and update the traceability matrix with pass/fail/skip status
2. Parse code coverage reports (Cobertura XML) and link coverage metrics to specific module designs (MOD-NNN)
3. Maintain an audit trail of when each test was executed and at which commit

## Proposed Solution

Add a **script-only** (no AI) `test-results` command that ingests JUnit XML test results and optionally Cobertura XML coverage data, then updates the traceability matrix in-place with execution status, timestamps, and code coverage metrics.

### Key Characteristics

1. **100% deterministic, no AI** — This is a pure parsing and transformation script. Unlike `peer-review` or `requirements`, it requires no LLM. The logic is: match test case names to V-Model IDs → update matrix status → compute summary.

2. **JUnit XML as primary input** — JUnit XML is the universal test result format. Every major framework emits it: pytest, JUnit/Maven, Gradle, .NET/xUnit, Go (via gotestsum), Jest, Mocha. This single parser covers the broadest CI ecosystem.

3. **Cobertura XML for coverage** — Cobertura XML is the universal code coverage format. pytest-cov, Istanbul (JS), Go cover, and many others emit it. Coverage data is optionally ingested to add actual coverage metrics to Matrix D (unit test level).

4. **In-place matrix update** — The existing `traceability-matrix.md` is modified, not regenerated. This preserves any manual annotations and ensures the matrix remains the single source of truth.

5. **ID matching via V-Model ID patterns** — Test case names in JUnit XML must contain V-Model scenario IDs (SCN-NNN-X#, STS-NNN-X#, ITS-NNN-X#, UTS-NNN-X#). The script uses regex to extract these IDs and match them to matrix rows.

6. **New matrix columns** — After ingestion, the matrix gains two new columns: Date (ISO 8601 date of the CI run) and Commit (short SHA of the Git commit under test). When coverage data is provided, Matrix D gains an additional Coverage column.

7. **Coverage-to-module mapping** — Cobertura XML reports coverage per source file. To link this to MOD-NNN IDs, the script supports two strategies:
   - **Convention (default)**: Parse `module-design.md` for file path references per MOD-NNN
   - **Override**: An explicit `coverage-map.yml` file maps `MOD-NNN` → source file paths

8. **CI-hookable exit codes**:
   - Exit 0 — All matched tests passed
   - Exit 1 — One or more test failures detected
   - Exit 2 — No V-Model ID matches found in the JUnit XML (likely misconfigured test names)

### Architecture

```
ingest-test-results.sh --input junit.xml [--coverage cobertura.xml] [--matrix traceability-matrix.md]
  │
  ├─ 1. Validate arguments, resolve matrix path
  │
  ├─ 2. Call Python helper:
  │     parse_test_results.py --junit <file> [--cobertura <file>] [--coverage-map <file>]
  │     → Outputs structured JSON to stdout
  │
  ├─ 3. Read JSON, update matrix in-place:
  │     - Replace Status column (⬜ Untested → ✅ Passed / ❌ Failed / ⏭️ Skipped)
  │     - Add/update Date + Commit SHA columns
  │     - For Matrix D with --coverage: add Coverage column
  │
  ├─ 4. Print summary to stdout
  │
  └─ 5. Exit with appropriate code
```

### Output Example

**JUnit XML input** (from any CI runner):
```xml
<testsuite name="acceptance" tests="5" failures="1" time="12.3">
  <testcase name="SCN-001-A1 Given valid sensor data" time="0.5"/>
  <testcase name="STS-002-B1 Given threshold exceeded" time="0.8">
    <failure message="Expected alert within 100ms, got 250ms"/>
  </testcase>
  <testcase name="UTS-004-A1 Boundary value at zero" time="0.1">
    <skipped message="Hardware not available"/>
  </testcase>
</testsuite>
```

**Matrix before**:
```
| REQ-001 | SYS-001 | STP-001-A | STS-001-A1 | ⬜ Untested |
```

**Matrix after**:
```
| REQ-001 | SYS-001 | STP-001-A | STS-001-A1 | ✅ Passed | 2026-03-31 | abc1234 |
```

**Matrix D with coverage**:
```
| ARCH-001 | SYS-001 | MOD-001 | read_artifact | UTP-001-A | Statement | UTS-001-A1 | ✅ Passed | 2026-03-31 | abc1234 | 98.2% stmt / 94.1% branch |
```

### Summary Output

```
Test Results Ingestion Summary
══════════════════════════════
Input:    test-results.xml (47 test cases)
Matrix:   specs/005d-test-results/v-model/traceability-matrix.md
Commit:   abc1234
Date:     2026-03-31

Matrix A (Acceptance):     12 passed, 0 failed, 0 skipped  (12/12 matched)
Matrix B (System):         15 passed, 1 failed, 0 skipped  (16/18 matched)
Matrix C (Integration):     8 passed, 0 failed, 1 skipped  ( 9/10 matched)
Matrix D (Unit):           10 passed, 0 failed, 0 skipped  (10/12 matched)

Overall: 45 passed, 1 failed, 1 skipped (47/52 scenarios matched)

Coverage (from cobertura.xml):
  MOD-001 read_artifact:     98.2% stmt / 94.1% branch
  MOD-002 dispatch_type:    100.0% stmt / 100.0% branch
  MOD-003 evaluate_criteria: 87.5% stmt / 82.3% branch  ⚠ Below threshold
  Overall:                   95.2% stmt / 92.1% branch
```
