# V-Model Requirements Specification: Release Audit Report

**Feature Branch**: `feature/005e-audit-report`
**Created**: 2026-04-05
**Status**: Approved
**Source**: `specs/005e-audit-report/spec.md`

## Overview

This document formalizes the requirements for adding a `/speckit.v-model.audit-report` command to the V-Model Extension Pack. The command is a **100% deterministic script** (no AI) that collects all V-Model artifacts, coverage metrics, test execution results, hazard status, and anomaly justifications from a project's V-Model directory, then assembles a monolithic `release-audit-report.md` via template-fill. A `waivers.md` file documents accepted deviations (WAV-NNN entries) that are cross-referenced against failed/skipped tests and open peer-review findings to compute compliance status. Exit codes signal release readiness: 0 = RELEASE READY or RELEASE CANDIDATE, 1 = NOT READY (unwaived anomalies), 2 = error (missing required artifacts).

## Requirements

### Functional Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-001 | The command SHALL accept a V-Model directory path as the primary positional argument and discover all V-Model artifacts within it (requirements.md, acceptance-plan.md, system-design.md, system-test.md, architecture-design.md, integration-test.md, module-design.md, unit-test.md, hazard-analysis.md, traceability-matrix.md, waivers.md). | P1 | The V-Model directory is the single source of all compliance evidence; automated discovery eliminates manual file listing. | Test |
| REQ-002 | For each discovered artifact, the command SHALL extract its Git SHA (abbreviated 7-character commit hash from the last commit that modified the file) and last-modified date (ISO 8601 YYYY-MM-DD from the commit timestamp). | P1 | Git-pinned evidence ensures every artifact in the audit report is traceable to a specific code revision, as required by auditors. | Test |
| REQ-003 | The command SHALL generate an Artifact Inventory table (Section 2) listing each discovered artifact with columns: Artifact name, File path, Git SHA, Last Modified date, and Status. | P1 | The artifact inventory provides the auditor with a complete manifest of all V-Model evidence documents and their revision state. | Test |
| REQ-004 | The command SHALL extract all traceability matrices (A, B, C, D, and H when present) from `traceability-matrix.md` and embed them in the report (Section 3), preserving any test execution status columns (Status, Date, Commit, Coverage). | P1 | The traceability matrices are the core evidence of bidirectional traceability across all V-Model levels. | Test |
| REQ-005 | The command SHALL compute coverage analysis metrics (Section 4) for each matrix: forward coverage (% of design IDs with at least one test), backward coverage (% of test IDs traced to a design ID), gap count (design IDs with no tests), and orphan count (test IDs with no parent design ID). | P1 | Coverage analysis quantifies traceability completeness and identifies gaps that could block certification. | Test |
| REQ-006 | When `hazard-analysis.md` exists, the command SHALL extract all HAZ-NNN entries and generate a Hazard Management Summary (Section 5) showing each hazard's Failure Mode, Severity, Likelihood, Risk Level, Mitigation, and Residual Risk. | P1 | Hazard management evidence is required by ISO 14971 (medical), ISO 26262 (automotive), and DO-178C (aerospace) for release certification. | Test |
| REQ-007 | The command SHALL identify all anomalies: test scenarios with `❌ Failed` status, test scenarios with `⏭️ Skipped` status, and (when `peer-review-*.md` files exist) peer-review findings with Critical or Major severity. | P1 | Anomaly identification is the prerequisite for waiver cross-referencing and release gating. | Test |
| REQ-008 | When `waivers.md` exists, the command SHALL parse it for WAV-NNN entries by matching `### WAV-NNN` headings and extracting the `**Artifact**:` field to identify which artifact ID each waiver covers. | P1 | Waiver parsing enables automated cross-referencing between documented justifications and actual anomalies. | Test |
| REQ-009 | For each identified anomaly, the command SHALL check if a matching waiver exists in `waivers.md` (by matching the anomaly's artifact ID against the waiver's `**Artifact**:` field). Anomalies with matching waivers SHALL be listed as "Waived" in the Known Anomalies section (Section 6); anomalies WITHOUT matching waivers SHALL be listed as "BLOCKING". | P1 | Strict waiver matching ensures no anomaly passes into a release without documented justification, as required by regulatory standards. | Test |
| REQ-010 | The command SHALL compute the compliance status based on anomaly disposition: `✅ RELEASE READY` when zero anomalies exist; `✅ RELEASE CANDIDATE` when all anomalies have matching waivers; `❌ NOT READY` when at least one anomaly has no matching waiver. | P1 | The compliance status is the top-level go/no-go signal for release certification — auditors look at this first. | Test |
| REQ-011 | The command SHALL generate an Executive Summary (Section 1) containing: system name, version, Git tag, date, regulatory context, total requirement count, total test scenario count, pass/fail/skip counts, hazard count with mitigation status, anomaly count with waiver status, and the computed compliance status. | P1 | The executive summary provides a one-page overview that auditors read first to determine release readiness. | Test |
| REQ-012 | The command SHALL generate a Signature Block (Section 7) with blank signature lines for QA Manager and Lead Engineer, plus the Git tag, Git SHA, and generation date. | P2 | The signature block provides the formal approval structure required by regulatory submission processes. | Test |
| REQ-013 | The command SHALL accept a `--system-name` argument for the system name, a `--version` argument for the release version, a `--git-tag` argument for the release tag, and a `--regulatory-context` argument for the applicable standards. | P1 | These metadata fields populate the executive summary and signature block with project-specific information. | Test |
| REQ-014 | The command SHALL accept an `--output` argument specifying the output file path. If not provided, the default SHALL be `release-audit-report.md` in the V-Model directory. | P2 | Explicit output path supports CI pipelines that write artifacts to specific locations. | Test |
| REQ-015 | The command SHALL return exit code 0 when the compliance status is `✅ RELEASE READY` or `✅ RELEASE CANDIDATE`. | P1 | Exit code 0 signals the release is not blocked, allowing CI pipelines to proceed. | Test |
| REQ-016 | The command SHALL return exit code 1 when the compliance status is `❌ NOT READY` (unwaived anomalies detected). | P1 | Exit code 1 blocks the CI pipeline, preventing release of software with unresolved anomalies. | Test |
| REQ-017 | The command SHALL return exit code 2 when required artifacts are missing (at minimum: `requirements.md` and `traceability-matrix.md` must exist). | P1 | Exit code 2 signals configuration error — the V-Model directory is incomplete and cannot produce a meaningful audit report. | Test |
| REQ-018 | The command SHALL support a `--json` flag that outputs the complete audit data as structured JSON to stdout, including: artifact inventory, coverage metrics per matrix, anomaly list with waiver status, compliance status, and all metadata. | P1 | Machine-readable JSON enables CI dashboards, approval gates, and downstream tooling to consume audit data programmatically. | Test |
| REQ-019 | When `waivers.md` contains a WAV-NNN entry whose `**Artifact**:` ID does not match any actual anomaly, the command SHALL report that waiver as "Orphaned" in the Known Anomalies section without affecting the compliance status. | P2 | Orphaned waivers indicate stale justifications that should be cleaned up but do not block releases. | Test |
| REQ-020 | The command SHALL print a human-readable summary to stderr showing: artifact count, matrix count, total coverage percentage, total test count with pass/fail/skip breakdown, anomaly count with waived/blocking breakdown, and the final compliance status. | P1 | The summary provides immediate feedback to engineers on the report result without requiring them to open the generated file. | Test |

### Non-Functional Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-NF-001 | The command SHALL be 100% deterministic: given the same V-Model directory contents and Git history, it SHALL always produce the same audit report. | P1 | Deterministic behavior ensures reproducible audit evidence — two runs on the same inputs must produce identical reports. | Test |
| REQ-NF-002 | The script SHALL use only standard tools available on CI runners: Bash 4+, PowerShell 7+, Git, and optionally Python 3.x (standard library only). | P1 | Zero external dependencies ensure the script runs on any CI environment without additional setup. | Inspection |
| REQ-NF-003 | The command SHALL generate the complete audit report in under 30 seconds for a project with up to 500 V-Model IDs across all artifacts. | P3 | Performance requirement ensures the script does not become a CI bottleneck. | Test |

### Interface Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-IF-001 | The Bash script SHALL accept the following CLI syntax: `build-audit-report.sh <vmodel-dir> [--system-name <name>] [--version <ver>] [--git-tag <tag>] [--regulatory-context <ctx>] [--output <path>] [--json] [--help]`. | P1 | Consistent CLI interface with positional V-Model directory and named optional arguments. | Test |
| REQ-IF-002 | The PowerShell script SHALL accept equivalent parameters: `Build-Audit-Report.ps1 -VModelDir <path> [-SystemName <name>] [-Version <ver>] [-GitTag <tag>] [-RegulatoryContext <ctx>] [-Output <path>] [-Json] [-Help]`. | P1 | PowerShell parity with idiomatic parameter naming conventions. | Test |

### Constraint Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-CN-001 | The command SHALL NOT use any AI or LLM — all processing SHALL be performed by deterministic script logic including template-fill, regex parsing, and Git metadata extraction. | P1 | The audit report is a compliance document; AI variability is unacceptable for reproducible regulatory evidence. | Inspection |
| REQ-CN-002 | The command SHALL NOT regenerate or modify any existing V-Model artifacts — it SHALL only read them to assemble the audit report. | P1 | The audit report is a read-only aggregation; modifying source artifacts would break their Git-pinned integrity. | Inspection |
| REQ-CN-003 | The waivers.md file SHALL follow a structured format: each waiver begins with a `### WAV-NNN` heading followed by fields `**Artifact**:`, `**Type**:`, `**Justification**:`, `**Approved By**:`, and optionally `**Engineering Change Order**:` and `**Compensating Control**:`. | P2 | A defined schema ensures the waiver file is parseable by the script and consistent across projects. | Inspection |

## Quality Characteristics Coverage (ISO/IEC 25010:2023)

Per `commands/requirements.md` Step 6, all 9 ISO/IEC 25010:2023 quality characteristics are cross-checked against the requirements in this specification.

### Quality Characteristics Analysis

| Quality Characteristic | ISO 25010 Ref | Covering Requirements | Evidence | Status |
|------------------------|--------------|----------------------|----------|--------|
| Functional Suitability (functional completeness, correctness, appropriateness) | §4.2.1 | REQ-001–REQ-020 | The 20 functional requirements fully specify artifact discovery, matrix extraction, hazard summarization, anomaly detection, waiver cross-referencing, compliance status computation, and report assembly. All primary functions are explicitly stated with SHALL language and testable verification methods. | ✅ Covered |
| Performance Efficiency (time behaviour, resource utilisation, capacity) | §4.2.3 | REQ-NF-003 | REQ-NF-003 mandates report generation in under 30 seconds for projects with up to 500 V-Model IDs. No resource utilisation or capacity ceiling beyond this time-bound is specified. | ✅ Covered |
| Compatibility (co-existence, interoperability) | §4.2.6 | REQ-NF-002 | REQ-NF-002 restricts the toolchain to standard CI runners (Bash 4+, PowerShell 7+, Git, Python 3.x stdlib). This ensures the command co-exists with any CI environment without toolchain conflicts. | ✅ Covered |
| Interaction Capability (accessibility, user engagement, error protection) | §4.2.4 | N/A | The audit-report command is a non-interactive CI script with no graphical user interface. Human interaction is limited to invoking the command via CLI and reading the generated report. This characteristic is not applicable. | N/A |
| Reliability (faultlessness, availability, fault tolerance, recoverability) | §4.2.2 | REQ-NF-001 | REQ-NF-001 mandates 100% deterministic behaviour — identical inputs always produce identical outputs. This directly addresses Reliability §4.2.2 faultlessness and repeatability across CI runs. | ✅ Covered |
| Security (confidentiality, integrity, non-repudiation, accountability, authenticity) | §4.2.5 | — | No security requirement is specified for access control or confidentiality of audit report content. Audit reports contain compliance evidence that may be sensitive (waiver justifications, anomaly details, hazard assessments). Access control is out-of-scope for this CLI tool but is identified as a quality gap. See QG-001 below. | ⚠️ Gap — see QG-001 |
| Maintainability (modularity, reusability, analysability, modifiability, testability) | §4.2.7 | REQ-NF-002, REQ-CN-001 | REQ-NF-002 (standard tools only) ensures the script remains maintainable without proprietary dependencies. REQ-CN-001 (no AI) eliminates AI model drift as a maintenance concern, making behaviour fully predictable and auditable across tool upgrades. | ✅ Covered |
| Flexibility (adaptability, scalability, installability, replaceability) | §4.2.8 | REQ-010, REQ-013, REQ-014 | REQ-010 defines three compliance status levels (RELEASE READY, RELEASE CANDIDATE, NOT READY) providing flexibility in release decision-making. REQ-013 and REQ-014 provide configurable metadata arguments (--system-name, --version, --git-tag, --regulatory-context, --output), adapting the report to different project contexts without script modification. | ✅ Covered |
| Safety (risk identification, risk treatment) | §4.2.9 | REQ-CN-001, REQ-009, REQ-010 | REQ-CN-001 (no AI = no variability) eliminates AI-induced risk of non-reproducible compliance evidence. REQ-009 and REQ-010 enforce strict waiver gate logic: anomalies without waivers produce ❌ NOT READY with exit code 1, preventing accidental release of software with unresolved anomalies. | ✅ Covered |

### Quality Gaps

| Gap ID | ISO 25010 Ref | Characteristic | Description | Recommendation |
|--------|--------------|----------------|-------------|----------------|
| QG-001 | §4.2.5 | Security — Confidentiality | No security requirement is specified for access control or confidentiality of audit report content. Audit reports generated by this command may contain sensitive compliance evidence: waiver justifications documenting known defects, anomaly details listing failed tests, hazard assessments with residual risk levels. In regulated environments (ISO 26262, DO-178C, IEC 62304), release audit reports may be subject to controlled document requirements. The current specification places no restriction on who can read or copy the generated report. | Add `REQ-SEC-001` in a future release: *"The generated audit report file permissions SHALL be set to owner-read-only (mode 0600 equivalent) by default, with a `--world-readable` flag to override."* Map to a new SYS component and add a corresponding system-level test. |
