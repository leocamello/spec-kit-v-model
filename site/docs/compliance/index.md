---
title: "What Auditors Expect: V-Model Compliance Overview"
description: Learn what regulatory auditors look for in safety-critical software projects, how the V-Model Extension Pack closes the compliance gap, and how to satisfy IEC 62304, ISO 26262, and DO-178C requirements.
---

# What Auditors Expect

An auditor doesn't just check that documents exist — they verify evidence of a **systematic, repeatable process**. A folder full of Word documents won't pass muster if the auditor can't trace every requirement to a test, every test to a result, and every design decision to a rationale.

For AI-assisted teams, the bar is even higher. Regulators increasingly ask: *"How do you know the AI didn't hallucinate coverage?"* The V-Model Extension Pack answers that question with **deterministic, script-generated traceability** — not self-assessed claims.

## The Three Pillars of Audit Readiness

Every regulatory audit — whether IEC 62304, ISO 26262, or DO-178C — evaluates three fundamental qualities:

<div class="grid cards" markdown>

-   :material-check-all:{ .lg .middle } **Completeness**

    ---

    Every requirement has a test. Every hazard has a mitigation. No gaps, no orphans.

    The V-Model Extension generates **coverage audits** with exact percentages and flags every gap in the Exception Report.

-   :material-link-variant:{ .lg .middle } **Traceability**

    ---

    Bidirectional links from requirements → design → code → tests — and back.

    The self-documenting ID schema (`REQ-NNN` → `ATP-NNN-X` → `SCN-NNN-X#`) lets auditors trace lineage by reading the ID alone.

-   :material-scale-balance:{ .lg .middle } **Consistency**

    ---

    Artifacts agree with each other. No contradictions between the requirements spec and the test plan.

    Deterministic validation scripts (`validate-requirement-coverage.sh`, `build-matrix.sh`) ensure mathematical consistency across all V-Model levels.

</div>

## The Compliance Gap for AI-Assisted Teams

Traditional manual processes struggle with coverage and consistency. AI-assisted processes introduce a new risk: **unverifiable output**. The V-Model Extension Pack eliminates both problems.

| Dimension | Manual Process | AI-Only (Unstructured) | V-Model Extension Pack |
|---|---|---|---|
| **Time to audit readiness** | Weeks–months | Hours (but unverifiable) | Hours (with verification) |
| **Coverage guarantee** | Depends on diligence | AI may claim 100% — no proof | Deterministic script: exact % |
| **Traceability depth** | Requirements → Tests (one level) | Varies | 4 matrices across all V-Model levels |
| **Consistency check** | Manual review | No built-in validation | Regex-based cross-referencing |
| **Auditor confidence** | Medium — depends on reviewer | Low — "the AI said so" | High — reproducible, deterministic |
| **Change impact analysis** | Spreadsheet-based | Not available | Automated dependency graph traversal |

## How the V-Model Extension Pack Delivers

The extension generates audit-ready artifacts at every level of the V-Model:

| V-Model Level | Command | Artifact | Audit Purpose |
|---|---|---|---|
| Requirements | `requirements` | `requirements.md` | IEEE 29148–validated requirements with persistent IDs |
| System Design | `system-design` | `system-design.md` | IEEE 1016:2009 design views |
| Architecture Design | `architecture-design` | `architecture-design.md` | IEEE 42010 architecture views |
| Module Design | `module-design` | `module-design.md` | Low-level requirements with pseudocode |
| Acceptance Tests | `acceptance` | `acceptance-plan.md` | BDD scenarios traced to requirements |
| System Tests | `system-test` | `system-test-plan.md` | ISO 29119-4 test techniques |
| Integration Tests | `integration-test` | `integration-test.md` | Interface contract & data flow testing |
| Unit Tests | `unit-test` | `unit-test.md` | White-box tests with strict isolation |
| Hazard Analysis | `hazard-analysis` | `hazard-analysis.md` | FMEA register with mitigation tracing |
| Traceability | `trace` | `traceability-matrix.md` | Multi-matrix coverage with exception reports |
| Impact Analysis | `impact-analysis` | `impact-report.md` | Dependency graph traversal for change control |

!!! tip "The audit-report command"

    The `audit-report` command brings everything together — it runs all validation scripts, generates the multi-level traceability matrix, and produces a single consolidated compliance report. This is the artifact you hand to the auditor.

## Supported Industry Standards

The V-Model Extension Pack maps its outputs to the specific clause-level requirements of three major safety standards:

<div class="grid cards" markdown>

-   :material-hospital-box:{ .lg .middle } **IEC 62304 — Medical Devices**

    ---

    Software lifecycle processes for medical device software. Safety classes A, B, and C determine which deliverables are required.

    [:octicons-arrow-right-24: IEC 62304 Compliance Guide](iec-62304.md)

-   :material-car:{ .lg .middle } **ISO 26262 — Automotive**

    ---

    Functional safety for road vehicles. ASIL levels A through D determine rigor and documentation depth.

    [:octicons-arrow-right-24: ISO 26262 Compliance Guide](iso-26262.md)

-   :material-airplane:{ .lg .middle } **DO-178C — Aerospace**

    ---

    Software considerations in airborne systems. Design Assurance Levels (DAL) A through E set objectives and verification depth.

    [:octicons-arrow-right-24: DO-178C Compliance Guide](do-178c.md)

</div>

## The ID Schema: Built for Auditors

The V-Model Extension uses a self-documenting, hierarchical ID schema across all levels:

```
REQ-001 → ATP-001-A → SCN-001-A1    (Requirements ↔ Acceptance)
SYS-001 → STP-001-A → STS-001-A1    (System Design ↔ System Tests)
ARCH-001 → ITP-001-A → ITS-001-A1   (Architecture ↔ Integration Tests)
MOD-001 → UTP-001-A → UTS-001-A1    (Module Design ↔ Unit Tests)
HAZ-001 → REQ-001/SYS-001 → ATP/STP (Hazard ↔ Mitigation ↔ Verification)
```

!!! info "Why this matters to auditors"

    Reading `SCN-001-A1` immediately tells the auditor it validates `ATP-001-A`, which tests `REQ-001`. No lookup table needed. IDs are **never renumbered** — gaps are acceptable because renumbering breaks audit trails.

## Pre-Audit Checklist

Before any regulatory audit, run through this checklist:

1. **Generate the traceability matrix**: Run the `trace` command
2. **Run impact analysis** for any recently modified artifacts: `impact-analysis --full <changed-ID>`
3. **Verify compliance status**: Look for `OVERALL STATUS: ✅ COMPLIANT` in the Coverage Audit
4. **Check for exceptions**: Verify 0 items in the Exception Report
5. **Confirm baselines**: Check timestamps and git commit hashes in the Baseline Information section
6. **Version control**: Ensure all source artifacts are committed
7. **Archive**: Store `traceability-matrix.md` and any `impact-report.md` as formal audit artifacts

!!! warning "Common audit findings the V-Model Extension prevents"

    | Finding | How It's Prevented |
    |---|---|
    | Requirement without test case | Coverage Audit flags gaps in the Exception Report |
    | Test case without requirement (orphan) | Orphans are flagged in the Exception Report |
    | Vague requirement ("the system shall be fast") | Enforced by Criterion 1 (Unambiguous) and Banned Words list |
    | Compound requirement hiding untested behavior | Enforced by Criterion 3 (Atomic) |
    | Test case dependent on other test state | Enforced by Criterion 2 (Independent) |
    | Non-repeatable test | Enforced by Criterion 3 (Repeatable) |

## Next Steps

Choose the standard that applies to your domain and explore the detailed compliance mapping:

- [IEC 62304 — Medical Device Software](iec-62304.md)
- [ISO 26262 — Automotive Functional Safety](iso-26262.md)
- [DO-178C — Aerospace Software](do-178c.md)
