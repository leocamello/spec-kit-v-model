---
title: Release Audit Report
description: Build a deterministic release audit report with artifact inventory, embedded matrices, waiver cross-referencing, and compliance gating.
---

# Release Audit Report

The audit report is a **100% deterministic report builder** — no AI generation needed. The script discovers all V-Model artifacts, extracts traceability matrices and coverage metrics, cross-references anomalies with waivers, and assembles a monolithic `release-audit-report.md`.

---

## Command

### `/speckit.v-model.audit-report`

=== "Bash"

    ```bash
    # Basic: generate audit report
    scripts/bash/build-audit-report.sh specs/<feature>/v-model

    # With metadata for executive summary
    scripts/bash/build-audit-report.sh specs/<feature>/v-model \
      --system-name "CBGMS" \
      --version "2.1.0" \
      --git-tag "v2.1.0" \
      --regulatory-context "IEC 62304 Class C, ISO 14971"

    # JSON output for CI
    scripts/bash/build-audit-report.sh specs/<feature>/v-model --json
    ```

=== "PowerShell"

    ```powershell
    # Basic: generate audit report
    scripts/powershell/Build-Audit-Report.ps1 -VModelDir specs/<feature>/v-model

    # With metadata
    scripts/powershell/Build-Audit-Report.ps1 -VModelDir specs/<feature>/v-model `
      -SystemName "CBGMS" `
      -Version "2.1.0" `
      -GitTag "v2.1.0" `
      -RegulatoryContext "IEC 62304 Class C, ISO 14971"

    # JSON output
    scripts/powershell/Build-Audit-Report.ps1 -VModelDir specs/<feature>/v-model -Json
    ```

---

## Report Contents

The audit report assembles a complete compliance snapshot:

### 1. Artifact Inventory

Every V-Model artifact with its Git SHA, last modified date, and line count:

| Artifact | Git SHA | Last Modified | Lines |
|---|---|---|---|
| `requirements.md` | `abc1234` | 2025-01-15 | 245 |
| `acceptance-plan.md` | `def5678` | 2025-01-15 | 512 |
| `system-design.md` | `ghi9012` | 2025-01-14 | 380 |
| ... | ... | ... | ... |

### 2. Embedded Traceability Matrices

All matrices (A through D + H) are embedded directly in the report:

- **Matrix A**: REQ → ATP → SCN (requirement coverage)
- **Matrix B**: REQ → SYS → STP → STS (system coverage)
- **Matrix C**: SYS → ARCH → ITP → ITS (architecture coverage)
- **Matrix D**: ARCH → MOD → UTP → UTS (module coverage)
- **Matrix H**: SYS → HAZ → Mitigation (hazard coverage)

### 3. Coverage Analysis

Aggregate coverage statistics per matrix:

| Matrix | Total Items | Covered | Coverage | Status |
|---|---|---|---|---|
| A (Requirements) | 15 | 15 | 100% | ✅ |
| B (System) | 8 | 8 | 100% | ✅ |
| C (Architecture) | 12 | 12 | 100% | ✅ |
| D (Module) | 24 | 23 | 95.8% | ⚠️ |
| H (Hazard) | 8 | 8 | 100% | ✅ |

### 4. Anomaly Detection

The report identifies anomalies — gaps, failures, and inconsistencies:

- Untested requirements (missing test cases)
- Failed test scenarios
- Skipped test scenarios
- Orphaned IDs (test cases without parent design elements)
- Unmitigated hazards

### 5. Waiver Cross-Referencing

When anomalies are found, the script checks for `waivers.md` in the V-Model directory:

```markdown
### WAV-001
- **Anomaly**: MOD-024 has no unit tests
- **Justification**: Third-party FFI wrapper — tested at integration level
- **Approved by**: Jane Smith
- **Date**: 2025-01-10
```

Anomalies matched to a `WAV-NNN` entry are marked as **waived** in the report and do not block the release gate.

---

## Compliance Gating

The audit report computes an overall compliance verdict:

| Verdict | Condition | CI Exit Code |
|---|---|---|
| ✅ **RELEASE READY** | No anomalies detected | `0` |
| ✅ **RELEASE CANDIDATE** | All anomalies have matching waivers | `0` |
| ❌ **NOT READY** | Unwaived anomalies remain | `1` |

!!! warning "Exit code 2"

    Exit code `2` indicates a **script error** — required artifacts (like `requirements.md` or `traceability-matrix.md`) are missing entirely.

---

## CI Integration

### Exit Codes

| Code | Meaning |
|---|---|
| `0` | ✅ RELEASE READY or RELEASE CANDIDATE |
| `1` | ❌ NOT READY (unwaived anomalies — blocks pipeline) |
| `2` | Error — required artifacts missing |

### Example: Release Gate

```yaml
- name: Build audit report
  run: |
    scripts/bash/build-audit-report.sh specs/v-model \
      --system-name "${{ github.event.repository.name }}" \
      --version "${{ github.ref_name }}" \
      --git-tag "${{ github.ref_name }}"
    # Exit code 1 fails the job if unwaived anomalies exist
```

---

## Related Pages

- [V-Model Concepts](concepts.md) — Understanding matrices and traceability
- [Test Results Ingestion](test-results.md) — Feed test results before building the audit report
- [Hazard Analysis](hazard-analysis.md) — Matrix H in the audit report
- [CI Integration](ci-integration.md) — Full pipeline with audit report gating
