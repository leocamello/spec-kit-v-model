---
title: Scripts Reference
description: Complete reference for all validator, checker, parser, and generator scripts in the V-Model Extension Pack.
---

# Scripts Reference

The V-Model Extension Pack includes **34 scripts** — 16 Bash, 16 PowerShell, 1 Python, plus the `run-v-model-gate.sh` 8-stage orchestrator — that handle all compliance-critical calculations deterministically.

!!! tip "Key Principle"
    AI generates content (requirements, test plans). **Scripts verify** coverage, parse results, and build reports. This separation ensures reproducibility and auditability.

## Script Inventory

| Script | Bash | PowerShell | Category |
|--------|------|------------|----------|
| validate-requirement-coverage | ✅ | ✅ | Validator |
| validate-system-coverage | ✅ | ✅ | Validator |
| validate-architecture-coverage | ✅ | ✅ | Validator |
| validate-module-coverage | ✅ | ✅ | Validator |
| validate-hazard-coverage | ✅ | ✅ | Validator |
| validate-artifact-status | ✅ | ✅ | Validator (status gate, MF-6, v0.7.0) |
| validate-domain-profile | ✅ | ✅ | Validator (domain config, MF-7, v0.7.0) |
| validate-implements-ids | ✅ | ✅ | Validator (hallucination guard, v0.7.0) |
| validate-core-schema | ✅ | ✅ | Validator (plan/tasks H2 ordering, MF-4, v0.7.0) |
| validate-level | ✅ | ✅ | Validator (dispatch) |
| run-v-model-gate | ✅ | ✅ | Orchestrator (8-stage pipeline, v0.7.0) |
| splice-managed-regions | ✅ | ✅ | Generator (sentinel splicer, MF-5, v0.7.0) |
| setup-plan / setup-tasks / setup-implement | ✅ | ✅ | Utility (bridge-command wrappers, MF-1, v0.7.0) |
| build-matrix | ✅ | ✅ | Generator |
| build-audit-report | ✅ | ✅ | Generator |
| impact-analysis | ✅ | ✅ | Generator |
| diff-requirements | ✅ | ✅ | Utility |
| setup-v-model | ✅ | ✅ | Utility |
| peer-review-check | ✅ | ✅ | Checker |
| ingest-test-results | ✅ | ✅ | Parser |
| parse_test_results | — | — | Parser (Python) |

---

## Validators

Validators perform bidirectional coverage checks at each V-Model level. They parse markdown artifacts using regex to extract IDs and cross-reference them.

### `validate-requirement-coverage.sh`/`.ps1`

Validates Level 1 (Requirements ↔ Acceptance) coverage.

=== "Bash"

    ```bash
    validate-requirement-coverage.sh [OPTIONS] <vmodel-dir>
    ```

=== "PowerShell"

    ```powershell
    validate-requirement-coverage.ps1 [-VModelDir] <path> [-Json]
    ```

| Parameter | Description |
|-----------|-------------|
| `<vmodel-dir>` | Path to v-model directory containing `requirements.md` and `acceptance-plan.md` |
| `--json` / `-Json` | Output in JSON format |

**Checks performed:**

- **Forward**: Every `REQ` → at least one `ATP` → at least one `SCN`
- **Backward**: Every `ATP` → existing `REQ`; every `SCN` → existing `ATP`

**Exit codes:**

| Code | Meaning |
|------|---------|
| 0 | Full coverage — all requirements have test cases and scenarios |
| 1 | Gaps found — missing test cases, orphaned tests, or incomplete coverage |

---

### `validate-system-coverage.sh`/`.ps1`

Validates Level 2 (System Design ↔ System Test) coverage.

=== "Bash"

    ```bash
    validate-system-coverage.sh [OPTIONS] <vmodel-dir>
    ```

=== "PowerShell"

    ```powershell
    validate-system-coverage.ps1 [-VModelDir] <path> [-Json]
    ```

| Parameter | Description |
|-----------|-------------|
| `<vmodel-dir>` | Path to v-model directory containing `requirements.md`, `system-design.md`, and `system-test.md` |
| `--json` / `-Json` | Output in JSON format |

**Checks performed:**

- **Forward**: Every `REQ` → at least one `SYS` (via `Parent Requirements`)
- **Backward**: Every `SYS` → at least one `STP` → at least one `STS`
- **Orphan detection**: `SYS` referencing non-existent `REQ`; `STP` referencing non-existent `SYS`

!!! note "Partial Validation"
    When `system-test.md` is absent, validates forward coverage (REQ→SYS) only and skips SYS→STP→STS checks.

**Exit codes:**

| Code | Meaning |
|------|---------|
| 0 | Full coverage (or forward-only in partial mode) |
| 1 | Gaps found |

---

### `validate-architecture-coverage.sh`/`.ps1`

Validates Level 3 (Architecture ↔ Integration Test) coverage.

=== "Bash"

    ```bash
    validate-architecture-coverage.sh [OPTIONS] <vmodel-dir>
    ```

=== "PowerShell"

    ```powershell
    validate-architecture-coverage.ps1 [-VModelDir] <path> [-Json]
    ```

| Parameter | Description |
|-----------|-------------|
| `<vmodel-dir>` | Path to v-model directory containing `system-design.md`, `architecture-design.md`, and `integration-test.md` |
| `--json` / `-Json` | Output in JSON format |

**Checks performed:**

- **Forward**: Every `SYS` → at least one `ARCH` (via `Parent System Components`)
- **Backward**: Every `ARCH` → at least one `ITP` → at least one `ITS`
- **Cross-cutting**: `[CROSS-CUTTING]` modules are valid without a `SYS` parent
- **Orphan detection**: `ARCH` referencing non-existent `SYS`; `ITP` referencing non-existent `ARCH`

**Exit codes:**

| Code | Meaning |
|------|---------|
| 0 | Full coverage |
| 1 | Gaps found |

---

### `validate-module-coverage.sh`/`.ps1`

Validates Level 4 (Module Design ↔ Unit Test) coverage.

=== "Bash"

    ```bash
    validate-module-coverage.sh [OPTIONS] <vmodel-dir>
    ```

=== "PowerShell"

    ```powershell
    validate-module-coverage.ps1 [-VModelDir] <path> [-Json]
    ```

| Parameter | Description |
|-----------|-------------|
| `<vmodel-dir>` | Path to v-model directory containing `architecture-design.md`, `module-design.md`, and `unit-test.md` |
| `--json` / `-Json` | Output in JSON format |

**Checks performed:**

- **Forward**: Every `ARCH` → at least one `MOD` (via `Parent Architecture Modules`)
- **Backward**: Every non-`[EXTERNAL]` `MOD` → at least one `UTP` → at least one `UTS`
- **External handling**: `[EXTERNAL]` modules bypassed for UTP requirement
- **Cross-cutting**: `[CROSS-CUTTING]` parent ARCHs tested normally
- **Orphan detection**: `MOD` referencing non-existent `ARCH`; `UTP` referencing non-existent `MOD`

**Exit codes:**

| Code | Meaning |
|------|---------|
| 0 | Full coverage |
| 1 | Gaps found |

---

### `validate-hazard-coverage.sh`/`.ps1`

Validates Hazard Analysis (Matrix H) coverage.

=== "Bash"

    ```bash
    validate-hazard-coverage.sh [OPTIONS] <vmodel-dir>
    ```

=== "PowerShell"

    ```powershell
    validate-hazard-coverage.ps1 [-VModelDir] <path> [-Json] [-Partial]
    ```

| Parameter | Description |
|-----------|-------------|
| `<vmodel-dir>` | Path to v-model directory containing `system-design.md` and `hazard-analysis.md` |
| `--json` / `-Json` | Output in JSON format |
| `--partial` / `-Partial` | Skip backward checks if `requirements.md` is absent |

**Three validation dimensions:**

1. **Forward**: Every `SYS-NNN` → at least one `HAZ-NNN`
2. **Backward**: Every `HAZ` mitigation → valid `REQ`/`SYS`
3. **State consistency**: Every operational state in HAZ → exists in system-design

**Exit codes:**

| Code | Meaning |
|------|---------|
| 0 | All applicable checks pass |
| 1 | Gaps found |

---

### `validate-level.sh`/`Validate-Level.ps1`

Dispatch wrapper that invokes the correct validator for a given V-Model level.

=== "Bash"

    ```bash
    validate-level.sh [OPTIONS] <vmodel-dir> <level>
    ```

=== "PowerShell"

    ```powershell
    Validate-Level.ps1 [-VModelDir] <path> [-Level] <string> [-Json] [-Partial]
    ```

| Parameter | Description |
|-----------|-------------|
| `<vmodel-dir>` | Path to v-model directory |
| `<level>` | One of: `acceptance`, `system-test`, `integration-test`, `unit-test`, `hazard-analysis` |
| `--json` / `-Json` | Pass `--json` to the underlying validator |
| `--partial` / `-Partial` | Pass `--partial` (only for `hazard-analysis`) |

**Level dispatch table:**

| Level | Invokes |
|-------|---------|
| `acceptance` | `validate-requirement-coverage` |
| `system-test` | `validate-system-coverage` |
| `integration-test` | `validate-architecture-coverage` |
| `unit-test` | `validate-module-coverage` |
| `hazard-analysis` | `validate-hazard-coverage` |

**Exit codes:**

| Code | Meaning |
|------|---------|
| 0 | Underlying validator passed |
| 1 | Underlying validator found gaps |
| 2 | Invalid arguments or unknown level |

---

## Generators

### `build-matrix.sh`/`build-matrix.ps1`

Builds the deterministic traceability matrix from V-Model artifacts.

=== "Bash"

    ```bash
    build-matrix.sh <vmodel-dir> [--output <file>]
    ```

=== "PowerShell"

    ```powershell
    build-matrix.ps1 [-VModelDir] <path> [-Output <path>]
    ```

| Parameter | Description |
|-----------|-------------|
| `<vmodel-dir>` | Path to v-model directory |
| `--output` / `-Output` | Output file path (default: stdout) |

**Matrices built progressively:**

- **Matrix A**: Built when `requirements.md` + `acceptance-plan.md` exist
- **Matrix B**: Added when `system-design.md` + `system-test.md` exist
- **Matrix C**: Added when `architecture-design.md` + `integration-test.md` exist
- **Matrix D**: Added when `module-design.md` + `unit-test.md` exist
- **Matrix H**: Added when `hazard-analysis.md` exists

**Parsing approach:** Section-scoped regex matching — only parses the Decomposition View for SYS parent links, only the Logical View for ARCH parent links, etc. This avoids false positives from IDs appearing in other sections.

---

### `build-audit-report.sh`/`Build-Audit-Report.ps1`

Builds a point-in-time release audit report from V-Model artifacts.

=== "Bash"

    ```bash
    build-audit-report.sh <vmodel-dir> [OPTIONS]
    ```

=== "PowerShell"

    ```powershell
    Build-Audit-Report.ps1 [-VModelDir] <path> [OPTIONS]
    ```

| Parameter | Description |
|-----------|-------------|
| `<vmodel-dir>` | Path to v-model directory **(required)** |
| `--system-name` / `-SystemName` | System name for executive summary |
| `--version` / `-Version` | Release version |
| `--git-tag` / `-GitTag` | Git release tag |
| `--regulatory-context` / `-RegulatoryContext` | Applicable regulatory standards |
| `--output` / `-Output` | Output file path (default: `<vmodel-dir>/release-audit-report.md`) |
| `--json` / `-Json` | Output JSON to stdout |

**Report sections:** Executive Summary, Artifact Inventory (with Git SHAs), Traceability Matrices, Coverage Analysis, Hazard Management Summary, Anomaly/Waiver Cross-Reference, Compliance Status.

**Compliance gating:**

| Status | Condition | Exit Code |
|--------|-----------|-----------|
| RELEASE READY | 0 anomalies | 0 |
| RELEASE CANDIDATE | All anomalies waived | 0 |
| NOT READY | Unwaived anomalies | 1 |

**Exit codes:**

| Code | Meaning |
|------|---------|
| 0 | RELEASE READY or RELEASE CANDIDATE |
| 1 | NOT READY (unwaived anomalies) |
| 2 | Error (missing required artifacts or invalid arguments) |

---

### `impact-analysis.sh`/`impact-analysis.ps1`

Deterministic impact analysis — builds an ID dependency graph and traverses from changed IDs.

=== "Bash"

    ```bash
    impact-analysis.sh [OPTIONS] <ID...> <vmodel-dir>
    ```

=== "PowerShell"

    ```powershell
    impact-analysis.ps1 [-Downward] [-Upward] [-Full] [-Json] [-Output <path>] <ID[]> <vmodel-dir>
    ```

| Parameter | Description |
|-----------|-------------|
| `<ID...>` | One or more changed V-Model IDs (e.g., `REQ-001`, `SYS-002`) |
| `<vmodel-dir>` | Path to v-model directory |
| `--downward` / `-Downward` | Trace downstream dependents (default) |
| `--upward` / `-Upward` | Trace upstream parents |
| `--full` / `-Full` | Both directions |
| `--json` / `-Json` | Output JSON to stdout |
| `--output` / `-Output` | Output file path (default: `<vmodel-dir>/impact-report.md`) |

**Output includes:** Blast radius summary, suspect artifact list by V-Model level, and re-validation order.

**Exit codes:**

| Code | Meaning |
|------|---------|
| 0 | Analysis completed successfully |
| 1 | Error (invalid arguments, no artifacts, etc.) |

---

## Checker

### `peer-review-check.sh`/`Peer-Review-Check.ps1`

Deterministic CI gate for peer-review reports. Parses findings and sets exit codes by severity.

=== "Bash"

    ```bash
    peer-review-check.sh [OPTIONS] <review-file>
    ```

=== "PowerShell"

    ```powershell
    Peer-Review-Check.ps1 [-ReviewFile] <path> [-Json]
    ```

| Parameter | Description |
|-----------|-------------|
| `<review-file>` | Path to `peer-review-{artifact}.md` file |
| `--json` / `-Json` | Output in JSON format |

**Exit codes:**

| Code | Meaning | Condition |
|------|---------|-----------|
| 0 | Clean | Zero findings, or observations only |
| 1 | Blocks PR | Critical or Major findings detected |
| 2 | Warning | Minor findings only, no Critical/Major |

---

## Parsers

### `ingest-test-results.sh`/`Ingest-Test-Results.ps1`

Ingests JUnit XML test results (and optional Cobertura XML coverage) into the traceability matrix.

=== "Bash"

    ```bash
    ingest-test-results.sh --input <junit.xml> [OPTIONS] [vmodel-dir]
    ```

=== "PowerShell"

    ```powershell
    Ingest-Test-Results.ps1 -InputFile <path> [-Coverage <path>] [-Matrix <path>] [-CoverageMap <path>] [-CommitSha <sha>] [-Json]
    ```

| Parameter | Description |
|-----------|-------------|
| `--input` / `-InputFile` | Path to JUnit XML file **(required)** |
| `--coverage` / `-Coverage` | Path to Cobertura XML coverage file |
| `--matrix` / `-Matrix` | Path to `traceability-matrix.md` (default: auto-detect) |
| `--coverage-map` / `-CoverageMap` | Path to `coverage-map.yml` override |
| `--commit-sha` / `-CommitSha` | Explicit commit SHA (default: `git rev-parse --short=7 HEAD`) |
| `--json` / `-Json` | Output JSON to stdout |

**Process:** Calls `parse_test_results.py` to parse XML → JSON, then updates the matrix in-place.

**Exit codes:**

| Code | Meaning |
|------|---------|
| 0 | All matched tests passed |
| 1 | At least one failure detected |
| 2 | No V-Model scenario IDs matched |

---

### `parse_test_results.py`

Python helper that parses JUnit XML test results and optional Cobertura XML coverage data.

```bash
python3 parse_test_results.py <junit.xml> [--coverage <cobertura.xml>] [--coverage-map <map.yml>]
```

| Parameter | Description |
|-----------|-------------|
| `<junit.xml>` | Path to JUnit XML file |
| `--coverage` | Path to Cobertura XML coverage file |
| `--coverage-map` | Path to coverage mapping YAML |

**Output:** Structured JSON mapping V-Model scenario IDs (`SCN`, `STS`, `ITS`, `UTS`) to test statuses (`passed`/`failed`/`skipped`), plus optional per-module coverage.

**ID pattern matching:**

| Matrix | Pattern |
|--------|---------|
| A | `SCN-[A-Z]*-?[0-9]{3}-[A-Z][0-9]+` |
| B | `STS-[A-Z]*-?[0-9]{3}-[A-Z][0-9]+` |
| C | `ITS-[A-Z]*-?[0-9]{3}-[A-Z][0-9]+` |
| D | `UTS-[A-Z]*-?[0-9]{3}-[A-Z][0-9]+` |

!!! tip "Zero Dependencies"
    Uses only the Python standard library — no `pip install` required.

---

## Utilities

### `diff-requirements.sh`/`diff-requirements.ps1`

Detects changed/added requirements for incremental acceptance plan updates.

=== "Bash"

    ```bash
    diff-requirements.sh <vmodel-dir> [--json]
    ```

=== "PowerShell"

    ```powershell
    diff-requirements.ps1 [-VModelDir] <path> [-Json]
    ```

| Parameter | Description |
|-----------|-------------|
| `<vmodel-dir>` | Path to v-model directory containing `requirements.md` |
| `--json` / `-Json` | Output in JSON format |

**Behavior:** Compares current `requirements.md` against its last committed version using Git. Falls back to "all requirements changed" if no Git history.

**Output:** List of changed/added `REQ` IDs.

---

### `setup-v-model.sh`/`setup-v-model.ps1`

V-Model directory setup and prerequisite checking.

=== "Bash"

    ```bash
    setup-v-model.sh [OPTIONS]
    ```

=== "PowerShell"

    ```powershell
    setup-v-model.ps1 [-Json] [-RequireReqs] [-RequireAcceptance] [...]
    ```

| Parameter | Description |
|-----------|-------------|
| `--json` / `-Json` | Output in JSON format |
| `--require-reqs` / `-RequireReqs` | Require `requirements.md` to exist |
| `--require-acceptance` / `-RequireAcceptance` | Require `acceptance-plan.md` to exist |
| `--require-system-design` / `-RequireSystemDesign` | Require `system-design.md` to exist |
| `--require-system-test` / `-RequireSystemTest` | Require `system-test.md` to exist |
| `--require-architecture-design` / `-RequireArchitectureDesign` | Require `architecture-design.md` to exist |
| `--require-integration-test` / `-RequireIntegrationTest` | Require `integration-test.md` to exist |
| `--require-module-design` / `-RequireModuleDesign` | Require `module-design.md` to exist |
| `--require-unit-test` / `-RequireUnitTest` | Require `unit-test.md` to exist |

**Output (JSON mode):**

```json
{
  "FEATURE_DIR": "...",
  "VMODEL_DIR": "...",
  "AVAILABLE_DOCS": ["requirements.md", "acceptance-plan.md"]
}
```

---

## v0.7.0 Bridge & Stabilization Scripts

The v0.7.0 release adds the gate orchestrator, two new validators, the hardened splicer, the hallucination guard, and the bridge-command setup wrappers. These scripts power the [Bridge Commands](../guide/bridge-commands.md) (`/speckit.v-model.{plan,tasks,implement}`).

### `run-v-model-gate.sh`/`.ps1`

Orchestrates the deterministic 8-stage validation pipeline that gates `/speckit.v-model.implement`. Each stage is a single sub-validator; any non-zero exit aborts the pipeline.

| Stage | Sub-validator | What it enforces |
|-------|---------------|------------------|
| 1 | `validate-artifact-status` | Every canonical V-Model artifact carries `**Status**: Approved` (configurable via `--required-status`). |
| 2 | `validate-domain-profile` | `v-model-config.yml` (when present) names a valid domain (`iso_26262`, `do_178c`, `iec_62304`). Absent file → non-fatal SKIP. |
| 3 | `build-matrix --check` | The traceability matrix builds without orphans or cycles. |
| 4 | `validate-requirement-coverage` | REQ ↔ ATP/SCN coverage. |
| 5 | `validate-system-coverage` | SYS ↔ STP coverage. |
| 6 | `validate-architecture-coverage` | ARCH ↔ ITP coverage. |
| 7 | `validate-module-coverage` | MOD ↔ UTP coverage. |
| 8 | `validate-hazard-coverage` | HAZ ↔ mitigation/verification coverage. |

### `validate-artifact-status.sh`/`.ps1` (MF-6)

Approval-status gate. Default: every canonical V-Model artifact must carry `**Status**: Approved`. Flags:

- `--required-status <value>` (repeatable) — accept any of the listed statuses (e.g. `--required-status Draft --required-status Approved` during migration).
- `--vmodel-dir <path>` — explicit V-Model directory; defaults to `specs/<feature>/v-model/`.

Exit 0 on success, 1 on any artifact carrying a disallowed status.

### `validate-domain-profile.sh`/`.ps1` (MF-7)

Validates `v-model-config.yml` against the canonical domain set (`iso_26262`, `do_178c`, `iec_62304`). The companion `v-model-config.yml.example` documents the three valid values.

- **No file present** → exit 0 (non-fatal SKIP). Suitable for non-regulated repositories.
- **File present and valid** → exit 0.
- **File present and invalid** → exit 1 with a precise error message naming the offending key/value.

### `validate-implements-ids.sh`/`.ps1` (hallucination guard)

Validates that every `Implements`-directive header in generated source/tests cites a V-Model ID that exists in the canonical artifact set. v0.7.0 adds three flags critical for the bridge pipeline:

| Flag | Purpose |
|------|---------|
| `--canonical <vmodel-dir>` | The authoritative ID source — typically `specs/<feature>/v-model/`. |
| `--scan <root>` | Where to look for `Implements`-directive headers — typically the repo root, so `src/` and `tests/{unit,integration,system,acceptance}/` are in scope. |
| `--changed-only` | Intersect the scan set with `git diff --name-only` so the guard only inspects files modified in the current branch / working tree. |

Exit 0 on success; exit 1 on any cited ID absent from the canonical set.

### `validate-core-schema.sh`/`.ps1` (MF-4)

Three-pass validator for `plan.md` and `tasks.md`:

1. **Existence** — every required H2 section is present.
2. **Ordering** — sections appear in the pinned order (5 H2s for `plan.md`, 12 H2s for `tasks.md`).
3. **Wedge rejection** — no unknown H2s appear between or around the pinned sections; enforced via `diff -u` against the canonical heading sequence.

Flags: `--plan` (5-H2 ruleset for `plan.md`) or `--tasks` (12-H2 ruleset for `tasks.md`).

### `splice-managed-regions.sh`/`.ps1` (MF-5)

Sentinel-managed region splicer used by `/speckit.v-model.implement` to inject generated code into existing source files without disturbing surrounding hand-written code. Recognises `<<<REGION id="X">>>` … `<<<END>>>` markers.

| Mode / Flag | Behaviour |
|-------------|-----------|
| Single-payload (legacy) | Replace every region in the target with the supplied payload. Stdout byte-identical to v0.6.x. |
| `--region-from <regions-file>` | Replace each region with its matching payload from a regions file (per-region payload mode, new in v0.7.0). |
| `2>&1` capture | Every successful run emits `diff -u original spliced` on **stderr** — capture it (e.g. `2>> tests/.splicer-diffs.log`) for audit-trail evidence. |

Exit codes:

| Code | Cause |
|------|-------|
| 0 | Successful splice. |
| 1 | File not found, unbalanced markers, orphan markers, nested markers, or bad CLI usage. |
| 2 | BEGIN/END `id` mismatch, duplicate region `id`, missing payload for a declared region, or malformed regions file. |

### `setup-plan.sh` / `setup-tasks.sh` / `setup-implement.sh` (and `.ps1` mirrors) (MF-1)

Thin V-Model-aware wrappers around the upstream `spec-kit-core` `setup-*` scripts. They surface `VMODEL_DIR` and the canonical artifact paths to the bridge prompts.

---

## Test Coverage

All scripts are extensively tested:

| Suite | Tests | Framework |
|-------|-------|-----------|
| BATS (Bash) | 455 | [bats-core](https://github.com/bats-core/bats-core) |
| Pester (PowerShell) | 431 | [Pester](https://pester.dev/) |
| Structural evals (pytest) | 89 | [pytest](https://pytest.org) + DeepEval |
| LLM-as-judge evals | 53 | DeepEval GEval |
| End-to-end (E2E) | 32 | Bash + golden-output fixtures (advisory in v0.7.0; hardened to gate in v0.8.0 via [EPIC-7](../community/roadmap.md)) |

The tests validate script logic across all scenarios: gaps, orphans, coverage violations, cross-cutting modules, external modules, partial validation, JSON output, and change impact traversal.
