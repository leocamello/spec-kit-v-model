---
title: AI-Powered Peer Review
description: Stateless, standards-based linting for V-Model artifacts — like ESLint for requirements, designs, and test plans.
---

# AI-Powered Peer Review

Peer review acts as an **automated first-pass reviewer** for any V-Model artifact. It evaluates the artifact against standards-based quality criteria and produces a structured report with findings — like ESLint or SonarQube for V-Model documents.

---

## The Stateless Linter Model

Peer review is **stateless** — it is regenerated from scratch each run:

- If a finding is in the report, it is a **current problem**
- If the engineer fixes the issue and re-runs, the finding **disappears**
- There is no `Status: Open` field — Git diff shows what changed between reviews
- Findings are **advisory-only** and do not participate in the traceability chain

!!! tip "Think ESLint, not Jira"

    Peer review findings don't have a lifecycle (open → in progress → closed). They exist only as long as the problem exists. Fix the artifact, re-run the review, and the finding is gone.

---

## Command

### `/speckit.v-model.peer-review`

Reviews a single V-Model artifact against standards-based criteria specific to its type.

```bash
/speckit.v-model.peer-review <artifact.md>
```

**Examples:**

```bash
/speckit.v-model.peer-review requirements.md
/speckit.v-model.peer-review system-design.md
/speckit.v-model.peer-review hazard-analysis.md
```

**Supported artifact types:**

| Artifact File | Abbreviation | Governing Standard |
|---|---|---|
| `requirements.md` | REQ | INCOSE Guide for Writing Requirements |
| `acceptance-plan.md` | ATP | ISO 29119 |
| `system-design.md` | SYS | IEEE 1016 |
| `system-test.md` | STP | ISO 29119 |
| `architecture-design.md` | ARCH | IEEE 42010 / Kruchten 4+1 |
| `integration-test.md` | ITP | ISO 29119-4 |
| `module-design.md` | MOD | DO-178C / ISO 26262 |
| `unit-test.md` | UTP | ISO 29119-4 |
| `hazard-analysis.md` | HAZ | ISO 14971 / ISO 26262 |

---

## Finding IDs

Every finding gets a unique ID using the pattern `PRF-{ARTIFACT}-NNN`:

```
PRF-REQ-001   — First finding in a requirements review
PRF-SYS-003   — Third finding in a system design review
PRF-HAZ-001   — First finding in a hazard analysis review
```

### Severity Classifications

| Severity | Description | CI Impact |
|---|---|---|
| **Critical** | Standards violation or missing mandatory content | Blocks merge (exit code 1) |
| **Major** | Significant quality issue affecting traceability or testability | Blocks merge (exit code 1) |
| **Minor** | Quality improvement opportunity | Warning (exit code 2) |
| **Observation** | Informational note, best practice suggestion | No impact (exit code 0) |

---

## Standards-Based Criteria

Each artifact type is evaluated against criteria specific to its governing standard:

=== "Requirements"

    - IEEE 29148 / INCOSE quality attributes (unambiguous, verifiable, traceable, etc.)
    - Priority assignment completeness
    - Rationale documentation
    - Verification method specified

=== "Design Artifacts"

    - All mandatory views present and populated
    - ID schema compliance
    - Parent traceability fields populated
    - No orphaned or unreferenced components

=== "Test Artifacts"

    - ISO 29119 technique named for each test case
    - Full coverage of paired design elements
    - Scenario completeness (expected results specified)
    - No duplicate or redundant test cases

=== "Hazard Analysis"

    - All system components analyzed
    - Operational states from system design covered
    - Severity/likelihood consistently applied
    - Mitigations reference valid REQ/SYS IDs

---

## CI Integration

### `peer-review-check.sh`

A companion parser script that reads peer review reports and returns CI-compatible exit codes.

=== "Bash"

    ```bash
    scripts/bash/peer-review-check.sh specs/<feature>/v-model/peer-review-requirements.md
    ```

=== "PowerShell"

    ```powershell
    scripts/powershell/Peer-Review-Check.ps1 specs/<feature>/v-model/peer-review-requirements.md
    ```

**Exit codes:**

| Code | Meaning | CI Action |
|---|---|---|
| `0` | Clean — zero findings, or observations only | ✅ Pass |
| `1` | Critical or Major findings detected | ⛔ Block merge |
| `2` | Minor findings only, no Critical/Major | ⚠️ Warning |

### Example: PR Gate

```yaml
- name: Peer review check
  run: |
    for review in specs/v-model/peer-review-*.md; do
      scripts/bash/peer-review-check.sh "$review" || exit 1
    done
```

---

## Related Pages

- [V-Model Concepts](concepts.md) — Understanding artifact types and standards
- [Impact Analysis](impact-analysis.md) — Identify artifacts to review after a change
- [Audit Report](audit-report.md) — Peer review findings in the release audit
- [CI Integration](ci-integration.md) — Full CI pipeline with peer review gates
