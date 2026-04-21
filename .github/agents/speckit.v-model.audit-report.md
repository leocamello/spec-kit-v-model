---
description: Build a release audit report from V-Model artifacts with waiver cross-referencing and compliance gating (100% deterministic, no AI).
handoffs:
  - label: View Traceability Matrix
    agent: speckit.v-model.trace
    prompt: Build the full traceability matrix to see current coverage
    send: true
  - label: Ingest Test Results
    agent: speckit.v-model.test-results
    prompt: Ingest CI test results before generating the audit report
    send: true
scripts:
  sh: scripts/bash/build-audit-report.sh
  ps: scripts/powershell/Build-Audit-Report.ps1
---

## User Input

```text
$ARGUMENTS
```

## Goal

Build a **release audit report** from the V-Model artifacts directory. This is a **100% deterministic, script-only command** — no AI generation is needed. The script discovers all V-Model artifacts, extracts traceability matrices and coverage metrics, cross-references anomalies with waivers, computes compliance status, and assembles a monolithic `release-audit-report.md`.

The audit report constitutes both a **Functional Configuration Audit (FCA)** — verifying that the software functions correctly per its requirements — and a **Physical Configuration Audit (PCA)** — verifying that the software matches its documentation — as defined by **IEEE 828-2012 §6.4** (Configuration Audits). The exit code directly reflects FCA/PCA pass/fail status, making the output actionable for both internal quality assurance and external certification reviews.

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
  --regulatory-context "Your Applicable Standard Here"

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
  -RegulatoryContext "Your Applicable Standard Here"

# JSON output
scripts/powershell/Build-Audit-Report.ps1 -VModelDir specs/<feature>/v-model -Json
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | ✅ RELEASE READY (no anomalies, no unresolved suspects) or ✅ RELEASE CANDIDATE (all anomalies and suspects waived) |
| 1 | ❌ NOT READY (unwaived anomalies or unresolved suspect items detected — blocks CI pipeline) |
| 2 | Error — required artifacts missing (requirements.md or traceability-matrix.md) |

Per **ISO 19011:2018 §6.4.9** (Audit Conclusions), findings in the generated report are classified as:
- **Major Nonconformity**: Unwaived anomaly or unresolved suspect item — blocks release (exit code 1)
- **Minor Nonconformity**: Waived anomaly or lifecycle warning — noted but does not block release
- **Observation**: Coverage metric below threshold or advisory finding — informational only

## Lifecycle Status Reporting

The audit report includes a **Lifecycle Status Summary** section (§3.1) that provides a per-artifact breakdown of lifecycle states:

```markdown
## 3.1 Lifecycle Status Summary

| Artifact | Active | Deprecated | Suspect | Total |
|----------|--------|------------|---------|-------|
| Requirements (REQ) | 42 | 3 | 0 | 45 |
| Acceptance Tests (ATP) | 38 | 3 | 2 | 43 |
| System Components (SYS) | 18 | 1 | 1 | 20 |
| System Tests (STP) | 16 | 1 | 1 | 18 |
| Architecture Modules (ARCH) | 12 | 0 | 1 | 13 |
| Integration Tests (ITP) | 10 | 0 | 1 | 11 |
| Module Designs (MOD) | 8 | 0 | 0 | 8 |
| Unit Tests (UTP) | 15 | 0 | 0 | 15 |
| Hazards (HAZ) | 6 | 0 | 0 | 6 |

### Unresolved Suspects

| ID | Suspect Reason | Artifact |
|----|---------------|----------|
| SYS-005 | Parent REQ-003 deprecated | system-design.md |
| ATP-003-A | Parent REQ-003 deprecated | acceptance-plan.md |
```

### Compliance Gating on Suspects

Unresolved `[SUSPECT]` items block the release (exit code 1) because they indicate that a change has propagated through the V-Model without verification. Resolution options:

1. **Re-parent** the suspect item to a new active parent
2. **Deprecate** the suspect item (if the parent was withdrawn)
3. **Confirm active** (remove the SUSPECT tag after manual review)
4. **Waive** (see waiver format below)

### Lifecycle Waiver Format

When a suspect item requires temporary acceptance (e.g., manual re-validation completed outside the V-Model tool chain):

```markdown
### WAV-NNN

**Artifact**: SYS-005 [SUSPECT — Parent REQ-003 deprecated]
**Type**: Lifecycle Review
**Justification**: SYS-005 re-parented to REQ-007; manual test verification complete
**Approved By**: Engineering Lead
**Compensating Control**: Test case coverage re-validated in acceptance-plan.md
```

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
- The generated `release-audit-report.md` satisfies the minimum content requirements for a Software Quality Assurance Records information item per **ISO/IEC/IEEE 15289:2019 §D.31** — it documents artifact completeness, traceability, and verification status in a reviewable and archivable format

## Governing Standards

This command is governed by the following standards for audit reporting:

| Standard | Full Name | Role in this Command |
|----------|-----------|----------------------|
| **IEEE 828-2012** | IEEE Standard for Configuration Management in Systems and Software Engineering | Configuration audit baseline: defines Functional Configuration Audit (FCA — verify software functions per requirements) and Physical Configuration Audit (PCA — verify software matches its documentation). Governs the audit scope and finding classification in this command. |
| **ISO 19011:2018** | Guidelines for Auditing Management Systems | Audit methodology and evidence evaluation: audit planning, objective evidence collection, audit finding classification (major nonconformity, minor nonconformity, observation), auditor competence, and audit report structure. Provides the process rigor that makes this command's outputs credible to external auditors. |
| **ISO/IEC/IEEE 15289:2019** | Systems and Software Engineering — Content of Life-Cycle Information Items | Audit report content requirements: specifies the minimum content required in compliance information items. Ensures this command produces audit reports that satisfy the documentation completeness requirements of both open-source and regulated-industry contexts. |

> **Domain extensions:** If a domain overlay is loaded, additional domain-specific audit requirements apply (e.g., ISO 26262-2 §6 Functional Safety Audit and Confirmation Measures, DO-178C §8 SQA and SOI-1–SOI-4 certification liaison, IEC 62304 §8 Configuration Management and §9 Problem Resolution). These are defined in the domain overlay files.
