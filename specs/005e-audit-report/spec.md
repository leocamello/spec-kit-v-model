# Feature 005e: Release Audit Report

## Problem Statement

When it's time to submit software to the FDA, FAA, or an ISO assessor, they don't want to browse a GitHub repository. They want a single, point-in-time document that proves: every requirement is designed, every design is tested, every test passed, every risk is mitigated. Currently, this evidence is scattered across multiple V-Model artifacts — `requirements.md`, `traceability-matrix.md`, `hazard-analysis.md`, test execution results, and coverage data. Engineers must manually compile this evidence for each release, which is error-prone and time-consuming.

Additionally, regulated releases often have **known anomalies** — tests that were skipped because hardware wasn't available in CI, or minor peer-review findings accepted for a prototype phase. Auditors expect these anomalies to be documented with formal justification (engineering change orders, compensating controls, approvals). Without automated cross-referencing between anomalies and documented waivers, releases risk being flagged as non-compliant.

There is currently no automated way to:
1. Assemble all V-Model evidence into a single, audit-ready document
2. Cross-reference failed/skipped tests against documented waivers in `waivers.md`
3. Gate the release status based on unresolved anomalies (unwaived failures → NOT READY)
4. Produce a point-in-time snapshot pinned to Git SHAs and timestamps

## Proposed Solution

Add a **100% deterministic, script-only** (no AI) `audit-report` command that collects all V-Model artifacts, coverage metrics, test execution results, hazard status, and anomaly justifications — then assembles a monolithic `release-audit-report.md` via template-fill. The script cross-references `waivers.md` (WAV-NNN entries) against all failed/skipped tests and open peer-review findings to compute a compliance status:

- `✅ RELEASE READY` — zero anomalies
- `✅ RELEASE CANDIDATE` — all anomalies have matching waivers
- `❌ NOT READY` — unwaived anomalies detected (exit code 1)

### Key Characteristics

1. **100% deterministic, no AI** — All sections are assembled by script logic (template-fill with computed metrics). No LLM is involved. Given the same inputs, the output is always identical.

2. **7-section report structure** — Executive Summary, Artifact Inventory, Traceability Matrices, Coverage Analysis, Hazard Management Summary, Known Anomalies, Signature Block.

3. **Waiver convention (`waivers.md`)** — A structured Markdown file with `### WAV-NNN` headings, each documenting a justified deviation (skipped test, accepted failure, deferred finding). The script parses this file and matches waivers to anomaly artifact IDs.

4. **Strict gating** — If `build-audit-report.sh` finds a failed or skipped test WITHOUT a matching waiver, the report status is `❌ NOT READY` and the script exits with code 1. This prevents accidental release of software with unresolved anomalies.

5. **Git-pinned evidence** — Every artifact in the inventory includes its Git SHA and last-modified date. The report itself records the Git tag and commit at generation time.

6. **Bash + PowerShell parity** — `build-audit-report.sh` and `Build-Audit-Report.ps1` produce identical output, following the established 1:1 parity convention.

7. **JSON output for CI** — The `--json` flag outputs structured JSON for downstream tooling (dashboards, approval gates, ALM sync).

### What This Feature Does NOT Include

- **Regulatory compliance checklists** (IEC 62304, ISO 26262, DO-178C) — deferred to future version
- **PDF generation** — the Markdown is structured for easy conversion, but the tool outputs only Markdown
- **Digital signatures** — the Signature Block contains blank lines for wet/electronic signatures outside this tool
