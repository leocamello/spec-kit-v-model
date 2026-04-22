# Traceability Matrix

**Generated**: 2026-04-22
**Source**: `specs/005e-audit-report/v-model/`

## Matrix A — Validation (User View)

| Requirement ID | Requirement Description | Test Case ID (ATP) | Validation Condition | Scenario ID (SCN) | Status |
|----------------|------------------------|--------------------|----------------------|--------------------|--------|
| **REQ-001** | The command SHALL accept a V-Model directory path as the primary positional argument and discover all V-Model artifacts within it (requirements.md, acceptance-plan.md, system-design.md, system-test.md, architecture-design.md, integration-test.md, module-design.md, unit-test.md, hazard-analysis.md, traceability-matrix.md, waivers.md). | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-002** | For each discovered artifact, the command SHALL extract its Git SHA (abbreviated 7-character commit hash from the last commit that modified the file) and last-modified date (ISO 8601 YYYY-MM-DD from the commit timestamp). | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-003** | The command SHALL generate an Artifact Inventory table (Section 2) listing each discovered artifact with columns: Artifact name, File path, Git SHA, Last Modified date, and Status. | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-004** | The command SHALL extract all traceability matrices (A, B, C, D, and H when present) from `traceability-matrix.md` and embed them in the report (Section 3), preserving any test execution status columns (Status, Date, Commit, Coverage). | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-005** | The command SHALL compute coverage analysis metrics (Section 4) for each matrix: forward coverage (% of design IDs with at least one test), backward coverage (% of test IDs traced to a design ID), gap count (design IDs with no tests), and orphan count (test IDs with no parent design ID). | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-006** | When `hazard-analysis.md` exists, the command SHALL extract all HAZ-NNN entries and generate a Hazard Management Summary (Section 5) showing each hazard's Failure Mode, Severity, Likelihood, Risk Level, Mitigation, and Residual Risk. | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-007** | The command SHALL identify all anomalies: test scenarios with `❌ Failed` status, test scenarios with `⏭️ Skipped` status, and (when `peer-review-*.md` files exist) peer-review findings with Critical or Major severity. | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-008** | When `waivers.md` exists, the command SHALL parse it for WAV-NNN entries by matching `### WAV-NNN` headings and extracting the `**Artifact**:` field to identify which artifact ID each waiver covers. | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-009** | For each identified anomaly, the command SHALL check if a matching waiver exists in `waivers.md` (by matching the anomaly's artifact ID against the waiver's `**Artifact**:` field). Anomalies with matching waivers SHALL be listed as "Waived" in the Known Anomalies section (Section 6); anomalies WITHOUT matching waivers SHALL be listed as "BLOCKING". | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-010** | The command SHALL compute the compliance status based on anomaly disposition: `✅ RELEASE READY` when zero anomalies exist; `✅ RELEASE CANDIDATE` when all anomalies have matching waivers; `❌ NOT READY` when at least one anomaly has no matching waiver. | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-011** | The command SHALL generate an Executive Summary (Section 1) containing: system name, version, Git tag, date, regulatory context, total requirement count, total test scenario count, pass/fail/skip counts, hazard count with mitigation status, anomaly count with waiver status, and the computed compliance status. | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-012** | The command SHALL generate a Signature Block (Section 7) with blank signature lines for QA Manager and Lead Engineer, plus the Git tag, Git SHA, and generation date. | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-013** | The command SHALL accept a `--system-name` argument for the system name, a `--version` argument for the release version, a `--git-tag` argument for the release tag, and a `--regulatory-context` argument for the applicable standards. | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-014** | The command SHALL accept an `--output` argument specifying the output file path. If not provided, the default SHALL be `release-audit-report.md` in the V-Model directory. | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-015** | The command SHALL return exit code 0 when the compliance status is `✅ RELEASE READY` or `✅ RELEASE CANDIDATE`. | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-016** | The command SHALL return exit code 1 when the compliance status is `❌ NOT READY` (unwaived anomalies detected). | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-017** | The command SHALL return exit code 2 when required artifacts are missing (at minimum: `requirements.md` and `traceability-matrix.md` must exist). | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-018** | The command SHALL support a `--json` flag that outputs the complete audit data as structured JSON to stdout, including: artifact inventory, coverage metrics per matrix, anomaly list with waiver status, compliance status, and all metadata. | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-019** | When `waivers.md` contains a WAV-NNN entry whose `**Artifact**:` ID does not match any actual anomaly, the command SHALL report that waiver as "Orphaned" in the Known Anomalies section without affecting the compliance status. | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-020** | The command SHALL print a human-readable summary to stderr showing: artifact count, matrix count, total coverage percentage, total test count with pass/fail/skip breakdown, anomaly count with waived/blocking breakdown, and the final compliance status. | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-CN-001** | The command SHALL NOT use any AI or LLM — all processing SHALL be performed by deterministic script logic including template-fill, regex parsing, and Git metadata extraction. | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-CN-002** | The command SHALL NOT regenerate or modify any existing V-Model artifacts — it SHALL only read them to assemble the audit report. | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-CN-003** | The waivers.md file SHALL follow a structured format: each waiver begins with a `### WAV-NNN` heading followed by fields `**Artifact**:`, `**Type**:`, `**Justification**:`, `**Approved By**:`, and optionally `**Engineering Change Order**:` and `**Compensating Control**:`. | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-IF-001** | The Bash script SHALL accept the following CLI syntax: `build-audit-report.sh <vmodel-dir> [--system-name <name>] [--version <ver>] [--git-tag <tag>] [--regulatory-context <ctx>] [--output <path>] [--json] [--help]`. | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-IF-002** | The PowerShell script SHALL accept equivalent parameters: `Build-Audit-Report.ps1 -VModelDir <path> [-SystemName <name>] [-Version <ver>] [-GitTag <tag>] [-RegulatoryContext <ctx>] [-Output <path>] [-Json] [-Help]`. | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-NF-001** | REQ-NF-001 mandates 100% deterministic behaviour — identical inputs always produce identical outputs. This directly addresses Reliability §4.2.2 faultlessness and repeatability across CI runs. | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-NF-002** | REQ-NF-002 restricts the toolchain to standard CI runners (Bash 4+, PowerShell 7+, Git, Python 3.x stdlib). This ensures the command co-exists with any CI environment without toolchain conflicts. | ❌ MISSING | — | — | ⬜ Untested |
| **REQ-NF-003** | REQ-NF-003 mandates report generation in under 30 seconds for projects with up to 500 V-Model IDs. No resource utilisation or capacity ceiling beyond this time-bound is specified. | ❌ MISSING | — | — | ⬜ Untested |

### Matrix A Coverage

| Metric | Value |
|--------|-------|
| **Total Requirements** | 28 |
| **Total Test Cases (ATP)** | 0 |
| **Total Scenarios (SCN)** | 45 |
| **REQ → ATP Coverage** | 0/28 (0%) |
| **ATP → SCN Coverage** | 0/0 (0%) |

## Matrix B — Verification (Architectural View)

| Requirement ID | System Component (SYS) | Component Name | Test Case ID (STP) | Technique | Scenario ID (STS) | Status |
|----------------|------------------------|----------------|--------------------|-----------|--------------------|--------|

### Matrix B Coverage

| Metric | Value |
|--------|-------|
| **Total System Components (SYS)** | 8 |
| **Total System Test Cases (STP)** | 0 |
| **Total System Scenarios (STS)** | 35 |
| **REQ → SYS Coverage** | 28/28 (100%) |
| **SYS → STP Coverage** | 0/8 (0%) |

## Matrix C — Integration Verification (Module Boundary View)

| System Component (SYS) | Parent REQs | Architecture Module (ARCH) | Module Name | Test Case ID (ITP) | Technique | Scenario ID (ITS) | Status |
|------------------------|-------------|---------------------------|-------------|--------------------|-----------|--------------------|--------|
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-CN-001, REQ-CN-002) | REQ-001, REQ-002, REQ-003, REQ-CN-001, REQ-CN-002 | ARCH-002 | File Discovery Module | ❌ MISSING | — | — | ⬜ Untested |
| SYS-002 (REQ-004, REQ-005) | REQ-004, REQ-005 | ARCH-003 | Matrix Parser Module | ❌ MISSING | — | — | ⬜ Untested |
| SYS-003 (REQ-006) | REQ-006 | ARCH-004 | Hazard Parser Module | ❌ MISSING | — | — | ⬜ Untested |
| SYS-004 (REQ-007, REQ-008, REQ-009, REQ-019, REQ-CN-003) | REQ-007, REQ-008, REQ-009, REQ-019, REQ-CN-003 | ARCH-005 | Anomaly Scanner Module | ❌ MISSING | — | — | ⬜ Untested |
| SYS-004 (REQ-007, REQ-008, REQ-009, REQ-019, REQ-CN-003) | REQ-007, REQ-008, REQ-009, REQ-019, REQ-CN-003 | ARCH-006 | Waiver Parser Module | ❌ MISSING | — | — | ⬜ Untested |
| SYS-004 (REQ-007, REQ-008, REQ-009, REQ-019, REQ-CN-003) | REQ-007, REQ-008, REQ-009, REQ-019, REQ-CN-003 | ARCH-007 | Cross-Reference Engine | ❌ MISSING | — | — | ⬜ Untested |
| SYS-005 (REQ-010, REQ-015, REQ-016, REQ-017) | REQ-010, REQ-015, REQ-016, REQ-017 | ARCH-007 | Cross-Reference Engine | ❌ MISSING | — | — | ⬜ Untested |
| SYS-006 (REQ-011, REQ-012, REQ-013, REQ-014, REQ-020, REQ-NF-001, REQ-NF-003) | REQ-011, REQ-012, REQ-013, REQ-014, REQ-020, REQ-NF-001, REQ-NF-003 | ARCH-008 | Report Renderer Module | ❌ MISSING | — | — | ⬜ Untested |
| SYS-007 (REQ-018) | REQ-018 | ARCH-009 | JSON Output Module | ❌ MISSING | — | — | ⬜ Untested |
| SYS-008 (REQ-IF-001, REQ-IF-002, REQ-NF-002) | REQ-IF-001, REQ-IF-002, REQ-NF-002 | ARCH-001 | CLI Argument Parser | ❌ MISSING | — | — | ⬜ Untested |
| SYS-008 (REQ-IF-001, REQ-IF-002, REQ-NF-002) | REQ-IF-001, REQ-IF-002, REQ-NF-002 | ARCH-010 | CLI Dispatch Orchestrator | ❌ MISSING | — | — | ⬜ Untested |

### Matrix C Coverage

| Metric | Value |
|--------|-------|
| **Total Architecture Modules (ARCH)** | 10 |
| **Total Cross-Cutting Modules** | 0 |
| **Total Integration Test Cases (ITP)** | 0 |
| **Total Integration Scenarios (ITS)** | 19 |
| **SYS → ARCH Coverage** | 8/8 (100%) |
| **ARCH → ITP Coverage** | 0/10 (0%) |

### Uncovered Requirements (REQ without ATP)

- REQ-001
- REQ-002
- REQ-003
- REQ-004
- REQ-005
- REQ-006
- REQ-007
- REQ-008
- REQ-009
- REQ-010
- REQ-011
- REQ-012
- REQ-013
- REQ-014
- REQ-015
- REQ-016
- REQ-017
- REQ-018
- REQ-019
- REQ-020
- REQ-CN-001
- REQ-CN-002
- REQ-CN-003
- REQ-IF-001
- REQ-IF-002
- REQ-NF-001
- REQ-NF-002
- REQ-NF-003

### Orphaned Test Cases (ATP without valid REQ)

None — all tests trace to requirements.

### Uncovered Requirements — System Level (REQ without SYS)

None — full coverage.

### Orphaned System Test Cases (STP without valid SYS)

None — all system tests trace to components.

### Uncovered System Components — Architecture Level (SYS without ARCH)

None — full coverage.

### Orphaned Integration Test Cases (ITP without valid ARCH)

None — all integration tests trace to modules.

## Matrix D — Implementation Verification (Module View)

| Architecture Module (ARCH) | Parent System | Module Design (MOD) | Module Name | Test Case ID (UTP) | Technique | Scenario ID (UTS) | Status |
|---------------------------|---------------|---------------------|-------------|--------------------|-----------|--------------------|--------|
| ARCH-001 (SYS-008) | SYS-008 | MOD-001 | parse_cli_args | ❌ MISSING | — | — | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | discover_artifacts | ❌ MISSING | — | — | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | parse_matrix_file | ❌ MISSING | — | — | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-004 | compute_coverage_metrics | ❌ MISSING | — | — | ⬜ Untested |
| ARCH-004 (SYS-003) | SYS-003 | MOD-005 | parse_hazards | ❌ MISSING | — | — | ⬜ Untested |
| ARCH-005 (SYS-004) | SYS-004 | MOD-006 | scan_anomalies | ❌ MISSING | — | — | ⬜ Untested |
| ARCH-006 (SYS-004) | SYS-004 | MOD-007 | parse_waivers | ❌ MISSING | — | — | ⬜ Untested |
| ARCH-007 (SYS-004, SYS-005) | SYS-004, SYS-005 | MOD-008 | cross_reference_anomalies | ❌ MISSING | — | — | ⬜ Untested |
| ARCH-008 (SYS-006) | SYS-006 | MOD-009 | render_report | ❌ MISSING | — | — | ⬜ Untested |
| ARCH-009 (SYS-007) | SYS-007 | MOD-010 | render_json | ❌ MISSING | — | — | ⬜ Untested |
| ARCH-010 (SYS-008) | SYS-008 | MOD-011 | dispatch_pipeline | ❌ MISSING | — | — | ⬜ Untested |

### Matrix D Coverage

| Metric | Value |
|--------|-------|
| **Total Module Designs (MOD)** | 11 |
| **External Modules** | 0 |
| **Testable Modules** | 11 |
| **Total Unit Test Cases (UTP)** | 0 |
| **Total Unit Scenarios (UTS)** | 45 |
| **ARCH → MOD Coverage** | 10/10 (100%) |
| **MOD → UTP Coverage** | 0/11 (0%) |

## Audit Notes

- **Matrix generated by**: `build-matrix.sh` (deterministic regex parser)
- **Source documents**: `requirements.md`, `acceptance-plan.md`, `system-design.md`, `system-test.md`, `architecture-design.md`, `integration-test.md`, `module-design.md`, `unit-test.md`
- **Last validated**: 2026-04-22
