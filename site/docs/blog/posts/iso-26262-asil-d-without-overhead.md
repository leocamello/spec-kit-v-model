---
date: 2025-04-23
authors:
  - leocamello
categories:
  - Regulated Industries
  - Compliance
  - V-Model
description: "Part 3 of 5 — Achieving ASIL-D functional safety compliance for automotive systems without the traditional overhead of months of manual documentation."
---

# ISO 26262 ASIL-D Without the Overhead: V-Model Meets AI

An Autonomous Emergency Braking system. ASIL-D — the highest automotive safety integrity level. The kind of system where a software defect can mean a fatality. Traditionally, teams building ASIL-D systems spend four to six months producing documentation before writing a single line of production code: safety requirements, FMEA registers, architecture descriptions, test plans at every level, bidirectional traceability matrices, and the structural coverage analysis to tie it all together. With spec-driven development and the V-Model Extension Pack, the same evidence package — structurally complete, deterministically verified, and audit-ready — is produced in a fraction of that time.

<!-- more -->

This is Part 3 of our five-part series, *Spec-Driven Development in Regulated Industries*. In [Part 2](), we walked through IEC 62304 for medical device software. Today we turn to the automotive domain, where ISO 26262 governs functional safety and ASIL-D represents the most demanding bar in the standard.

---

## ISO 26262 in 60 Seconds

ISO 26262:2018 is the functional safety standard for electrical and electronic systems in road vehicles. It assigns an **Automotive Safety Integrity Level (ASIL)** to each safety goal based on three factors:

- **Severity (S)**: How bad is the harm? (S0 – S3, from no injury to life-threatening)
- **Exposure (E)**: How likely is the operational situation? (E0 – E4)
- **Controllability (C)**: Can the driver or others control the outcome? (C0 – C3)

The combination of S × E × C determines the ASIL: **QM** (standard quality management), then **A** through **D** in increasing rigor. ASIL A is the baseline; ASIL D is the ceiling.

For the full ASIL determination tables, deliverables matrices, and artifact mapping, see the [ISO 26262 Compliance](../../compliance/iso-26262.md) page.

---

## ASIL-D: The Highest Bar

What makes ASIL-D different from lower ASILs isn't just "more paperwork." It's a qualitative shift in what the standard demands:

- **Every deliverable is mandatory.** At ASIL A or B, some artifacts are recommended but not required. At ASIL-D, the full table applies — software unit design, back-to-back testing, MC/DC structural coverage, bidirectional traceability at all levels. Nothing is optional.
- **Structural coverage reaches MC/DC.** ASIL A requires statement coverage. ASIL B adds branch coverage. ASIL-D requires Modified Condition/Decision Coverage — every condition in every decision must be shown to independently affect the outcome. This is the same coverage level that DO-178C demands for DAL-A flight software.
- **Formal methods are encouraged.** ISO 26262 Part 6 recommends formal verification techniques for ASIL-D. While not strictly mandatory, auditors increasingly expect to see them — or a documented rationale for their absence.
- **Independent verification is required.** The person (or tool) verifying an artifact cannot be the person who created it. This is where the separation of AI generation and script verification becomes a structural advantage.

The cost of all this in a traditional workflow is staggering. Teams report spending months on documentation alone — not because the engineering is complex, but because the *evidence* of the engineering is complex. Traceability matrices are assembled by hand in spreadsheets. Coverage analysis is a manual mapping exercise. Change impact assessment involves walking through documents page by page.

This is the overhead that spec-driven development eliminates.

---

## Hazard Analysis: Where Safety Starts

Before you can allocate ASILs, you need to know what can go wrong. The `/speckit.v-model.hazard-analysis` command generates an ISO 14971/26262-compliant FMEA register that systematically analyzes every system component for failure modes across all operational states.

Each hazard receives a unique `HAZ-NNN` identifier and is assessed across a severity × likelihood matrix to produce a Risk Priority Number (RPN). Critically, every mitigation references a `REQ-NNN` or `SYS-NNN` for traceability — the chain from hazard to mitigation to verification test is unbroken.

For an AEB system, the hazard register includes entries like:

| HAZ ID | Component | Failure Mode | Operational State | Effect | Severity | Mitigation |
|---|---|---|---|---|---|---|
| HAZ-001 | Sensor Fusion | Complete loss of object detection | Highway driving (80+ km/h) | No braking initiated for imminent collision | 5 (Catastrophic) | REQ-005 (fail-safe state within 50 ms) |
| HAZ-002 | Brake Actuator | Delayed actuation > 150 ms | Intersection approach | Braking too late to prevent collision | 5 (Catastrophic) | REQ-001 (150 ms latency bound) |
| HAZ-003 | Object Classifier | Misclassification (vehicle → non-threat) | Urban driving | AEB not triggered for valid threat | 4 (Critical) | REQ-003 (≥ 95% classification confidence) |
| HAZ-004 | Sensor Fusion | False positive detection | Highway cruising | Unnecessary emergency braking causes rear-end collision | 4 (Critical) | REQ-004 (no braking for objects > 100 m) |

Notice the **Operational State** column. Both ISO 26262 Part 3 and ISO 14971 require hazards to be contextualized by operational state — a sensor failure at 30 km/h in a parking lot is a different risk than the same failure at 130 km/h on an autobahn. The hazard analysis command enforces this: every `HAZ-NNN` entry is assessed in the context of the system's operational modes.

The command also supports **progressive deepening**. Run it after system design to capture system-level hazards. Run it again after architecture design, and it supplements the register with architecture-level failure modes — interface failures, concurrency hazards, data flow corruption — while preserving existing `HAZ-NNN` entries.

---

## Impact Analysis: The Change Management Superpower

Here is the scenario every ASIL-D team dreads: a safety requirement changes mid-program. Maybe the braking latency budget tightens from 150 ms to 100 ms. Maybe a new regulatory addendum adds a cyclist-specific detection requirement. In a traditional workflow, a systems engineer spends days — sometimes weeks — manually tracing the change through every artifact it touches.

ISO 26262 Part 8 requires rigorous change management. You must demonstrate that every affected artifact has been identified, reviewed, and re-verified. Miss one, and your audit has a finding.

The `/speckit.v-model.impact-analysis` command eliminates this entirely. It is a **script-only command** — no AI involved, fully deterministic. The script scans all V-Model artifacts, builds a bi-directional dependency graph from every ID reference, and traverses it to produce a complete blast radius report.

Running `--full REQ-003` on our AEB system might produce:

```
Blast Radius:
  REQ: 1 (REQ-003)
  ATP: 2 (ATP-003-A, ATP-003-B)
  SCN: 4 (SCN-003-A1, SCN-003-A2, SCN-003-B1, SCN-003-B2)
  SYS: 1 (SYS-002)
  STP: 1 (STP-002-B)
  STS: 2 (STS-002-B1, STS-002-B2)
  ARCH: 1 (ARCH-004)
  ITP: 1 (ITP-004-A)
  MOD: 2 (MOD-007, MOD-008)
  UTP: 3 (UTP-007-A, UTP-008-A, UTP-008-B)

Re-validation Order:
  1. MOD-007, MOD-008 (update module designs)
  2. UTP-007-A, UTP-008-A, UTP-008-B (regenerate unit tests)
  3. ARCH-004 (review architecture)
  4. ITP-004-A (regenerate integration tests)
  5. SYS-002 (review system design)
  6. STP-002-B (regenerate system test)
  7. ATP-003-A, ATP-003-B (regenerate acceptance tests)
```

In seconds, you know every artifact that REQ-003 touches — across all four V-Model levels, both design and test sides. The re-validation order tells you what to update first (bottom-up, from module designs through integration and up to acceptance tests). No manual tracing. No spreadsheet archaeology. And because the script traverses the actual ID references in the Markdown files, it cannot miss a dependency.

For CI integration, the `--json` flag produces machine-readable output so you can enforce blast-radius thresholds: if a single requirement change affects more than 20 artifacts, fail the pipeline and force a human review.

---

## The Traceability Evidence Package

When the auditor arrives — and in ASIL-D, they always arrive — the question is straightforward: *can you prove that every requirement was tested, every hazard was mitigated, and every artifact is traceable?*

The `/speckit.v-model.trace` command generates the complete evidence package for an ASIL-D system. For AEB, this means all five traceability matrices:

- **Matrix A**: Requirements → Acceptance Tests (every `REQ-NNN` maps to `ATP-NNN-X` procedures and `SCN-NNN-X#` scenarios)
- **Matrix B**: System Design → System Tests (every `SYS-NNN` maps to `STP-NNN-X` procedures)
- **Matrix C**: Architecture → Integration Tests (every `ARCH-NNN` maps to `ITP-NNN-X` procedures, with ASIL decomposition verification)
- **Matrix D**: Module Design → Unit Tests (every `MOD-NNN` maps to `UTP-NNN-X` procedures)
- **Matrix H**: Hazards → Mitigations → Verification (every `HAZ-NNN` traces through its mitigation to a verified test)

Each matrix includes exact coverage percentages computed by deterministic scripts — regex-based, inspectable, testable. The coverage numbers are not generated by AI. They are computed by the same scripts that are backed by 364 BATS tests and 347 Pester tests. An auditor can inspect the script, run it independently, and get the same number every time.

The audit report also includes an artifact inventory with Git SHAs for every document, so the auditor can verify that the traceability matrix corresponds to a specific, immutable version of every artifact. Git becomes the QMS — no separate ALM database needed for the audit trail.

---

## Traditional vs. Spec-Driven ASIL-D

| Dimension | Traditional Approach | Spec-Driven (V-Model Extension) |
|---|---|---|
| **Time to first evidence package** | 4–6 months | Days to weeks (depends on review cycles) |
| **Coverage verification** | Manual spreadsheet mapping | Deterministic scripts (711 tests) |
| **Change impact assessment** | Days of manual document tracing | Seconds (`impact-analysis --full`) |
| **Audit preparation time** | 2–4 weeks of evidence assembly | Minutes (regenerate trace + audit report) |
| **ASIL decomposition tracking** | Manual architecture-to-ASIL mapping | Automated per `ARCH-NNN` element |
| **Hazard-to-mitigation traceability** | Separate FMEA tool, manual cross-reference | Integrated Matrix H with `HAZ-NNN` → `REQ-NNN` links |
| **Reproducibility** | Dependent on who assembled the evidence | Deterministic — same inputs, same outputs, every time |

The efficiency gain is not about cutting corners. Every artifact still requires human review. Every safety-critical decision still belongs to the engineer. The gain is in eliminating the *mechanical overhead* — the hours spent manually assembling traceability matrices, tracing change impacts through documents, and reformatting evidence for auditors. The V-Model Extension automates the structure so engineers can focus on the substance.

---

## Next in the Series

In **Part 4**, we move from the road to the sky. DO-178C certification for aerospace software demands something that ISO 26262 hints at but doesn't require: *provably deterministic* evidence. The FAA doesn't accept "probably correct." We'll explore how the separation of AI generation and script verification maps to DO-178C's trust model — and why this architectural decision matters more in aerospace than anywhere else.

---

## Get Started

- **Tutorial**: [Emergency Braking System (ISO 26262 ASIL-D)](../../tutorials/automotive-adas.md) — End-to-end walkthrough with an AEB system
- **Compliance**: [ISO 26262 Compliance](../../compliance/iso-26262.md) — Full artifact mapping, ASIL determination tables, and deliverables by ASIL level
- **Getting Started**: [Installation & First Run](../../getting-started/index.md) — Set up the V-Model Extension Pack in under five minutes
