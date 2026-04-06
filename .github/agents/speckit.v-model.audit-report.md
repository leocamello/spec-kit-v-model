---
description: Build a release audit report from V-Model artifacts with waiver
  cross-referencing and compliance gating (100% deterministic, no AI).
handoffs:
- label: Back to Test Results
  agent: speckit.v-model.test-results
  prompt: Ingest CI test results before generating the audit report
- label: View Traceability Matrix
  agent: speckit.v-model.trace
  prompt: Build the full traceability matrix to see current coverage
scripts:
  sh: scripts/bash/setup-v-model.sh --json --require-reqs
  ps: scripts/powershell/setup-v-model.ps1 -Json -RequireReqs
---


<!-- Extension: v-model -->
<!-- Config: .specify/extensions/v-model/ -->
## User Input

```text
$ARGUMENTS
```

## Goal

Build a **release audit report** from the V-Model artifacts directory. This is a **100% deterministic, script-only command** — no AI generation is needed. The script discovers all V-Model artifacts, extracts traceability matrices and coverage metrics, cross-references anomalies with waivers, computes compliance status, and assembles a monolithic `release-audit-report.md`.

## How to Use

This command is invoked directly via the script, not through AI generation:

### Bash
```bash
# Basic: generate audit report from V-Model directory
scripts/bash/build-audit-report.sh specs/<feature>/v-model

# With metadata for executive summary
scripts/bash/build-audit-report.sh specs/<feature>/v-model \
  --system-name "CBGMS" \
  --version "2.1.0" \
  --git-tag "v2.1.0" \
  --regulatory-context "IEC 62304 Class C, ISO 14971"

# Custom output path
scripts/bash/build-audit-report.sh specs/<feature>/v-model --output /tmp/audit-report.md

# JSON output to stdout (for CI pipelines)
scripts/bash/build-audit-report.sh specs/<feature>/v-model --json
```

### PowerShell
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

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | ✅ RELEASE READY (no anomalies) or ✅ RELEASE CANDIDATE (all anomalies waived) |
| 1 | ❌ NOT READY (unwaived anomalies detected — blocks CI pipeline) |
| 2 | Error — required artifacts missing (requirements.md or traceability-matrix.md) |

## Waiver Convention

When tests fail or are skipped, create a `waivers.md` file in the V-Model directory with entries in this format:

```markdown
### WAV-001

**Artifact**: UTS-012-C2
**Type**: Skipped Test
**Justification**: Hardware sensor not available in CI environment.
**Approved By**: Jane Smith (QA Manager)
**Engineering Change Order**: ECO-2026-014
**Compensating Control**: Manual test executed on target hardware, results in test-report-hw-2026-03-28.pdf.
```

Each `### WAV-NNN` entry must include an `**Artifact**:` field matching the anomaly's scenario ID. Anomalies without matching waivers will block the release (exit code 1).

## Important Notes

- This command is **read-only** — it does not modify any V-Model artifacts
- Run `/speckit.v-model.test-results` first to ingest CI results into the traceability matrix
- The report pins every artifact to its Git SHA and timestamp for audit traceability
- Orphaned waivers (referencing non-existent anomalies) are reported but do not affect compliance status
