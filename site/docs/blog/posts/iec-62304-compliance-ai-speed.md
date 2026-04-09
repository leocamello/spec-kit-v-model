---
date: 2025-04-16
authors:
  - leocamello
categories:
  - Regulated Industries
  - Compliance
  - Spec-Driven Development
description: "Part 2 of 5 — How spec-driven development transforms IEC 62304 compliance for medical device software from a months-long ordeal to a sprint-sized workflow."
---

# From Requirement to Release: IEC 62304 Compliance at AI Speed

A Class C medical device. IEC 62304 mandates deliverables across 11 clauses — requirements, architecture, detailed design, unit verification, integration testing, system testing, risk management, traceability, and release documentation. The traditional approach: assemble a cross-functional team, spend four to six months producing Word documents and Excel spreadsheets, and hope nothing changed between the first deliverable and the last. The spec-driven approach: generate every artifact from a single specification, verify coverage deterministically, and produce an audit-ready package in a single sprint. Same artifacts. Same rigor. Fundamentally different economics.

<!-- more -->

This is the second article in our five-part series on **Spec-Driven Development in Regulated Industries**. If you missed the series opener — [why specifications are your most valuable asset](spec-driven-development-regulated-industries.md) — start there for the conceptual foundation. This article gets practical.

---

## IEC 62304 in 60 Seconds

**IEC 62304:2006+AMD1:2015** is the international standard for medical device software lifecycle processes. If your software runs on, connects to, or controls a medical device, this is the standard that FDA, EU MDR, and regulatory bodies worldwide reference when evaluating your development process.

The standard classifies software by the severity of harm that a failure could cause:

| Safety Class | Hazard Severity | Documentation Rigor |
|---|---|---|
| **Class A** | No injury or damage to health | Minimal — requirements and verification planning |
| **Class B** | Non-serious injury | Moderate — adds architecture and integration testing |
| **Class C** | Death or serious injury | Maximum — every deliverable required |

Class C is the hardest. Infusion pump control software, ventilator algorithms, implant firmware — any software where a failure mode could kill a patient. Class C requires **every** IEC 62304 deliverable: requirements specification, architecture, detailed design, unit verification, integration testing, system testing, risk management, traceability, and release documentation.

For the full deliverables table and artifact mapping, see the [IEC 62304 Compliance page](../../compliance/iec-62304.md).

---

## The Manual Approach vs. Spec-Driven

Here is the workflow most medical device teams follow today, side-by-side with the spec-driven alternative:

| Phase | Manual Approach | Spec-Driven Approach |
|---|---|---|
| **Requirements** | Write SRS in Word (2–4 weeks). Requirements quality varies by author. | `/speckit.v-model.requirements` — structured `REQ-NNN` items generated from spec, validated against 8 quality criteria. Human reviews and commits. |
| **Test Planning** | Manually write test plan in a separate document (1–2 weeks). Hope IDs align. | `/speckit.v-model.acceptance` — paired `ATP-NNN-X` test cases with BDD `SCN-NNN-X#` scenarios. 100% forward coverage validated by script. |
| **Traceability** | Build traceability matrix in Excel (1 week). Manually cross-reference IDs. | `/speckit.v-model.trace` — deterministic matrix computed in seconds. Forward and backward traceability. Gaps flagged automatically. |
| **Architecture** | Write architecture document (2–3 weeks). Diagrams in Visio. | `/speckit.v-model.architecture-design` — IEEE 42010 views with `ARCH-NNN` identifiers. Human reviews structure and decisions. |
| **Hazard Analysis** | Conduct FMEA workshop (1–2 weeks). Record in spreadsheet. | `/speckit.v-model.hazard-analysis` — FMEA register with `HAZ-NNN` items, severity × likelihood matrix, mitigation traceability. |
| **Change Impact** | Grep through documents. Email the team. Hope you found everything. | `/speckit.v-model.impact-analysis` — deterministic blast radius. Every suspect artifact identified across all V-levels. |
| **Audit Report** | Assemble evidence package manually (2–4 weeks). | `/speckit.v-model.audit-report` — point-in-time release audit with compliance gating. |

The difference is not that the spec-driven artifacts are less rigorous. The content is the same — structured requirements, paired test cases, bidirectional traceability. The difference is that generation takes minutes instead of weeks, and verification is deterministic instead of manual.

---

## A Walkthrough: Blood Glucose Monitor

Let's make this concrete. You are building software for a **continuous blood glucose monitoring (CGM) system** — IEC 62304 Class C, because incorrect readings or missed alerts could result in death or serious injury.

### Start with a specification

Everything begins with a narrative spec:

```
/speckit.specify A continuous blood glucose monitoring system that reads
interstitial glucose levels from a subcutaneous electrochemical sensor every
5 minutes. The system transmits readings via Bluetooth Low Energy to a
companion mobile application, which displays the current glucose value,
trend arrows, and a historical graph. The system triggers configurable
audible and haptic alerts when glucose falls below a hypoglycemia threshold
or exceeds a hyperglycemia threshold. All readings are stored locally with
UTC timestamps for a minimum of 90 days. The device must operate on a
single CR2032 battery for at least 14 days. The software is classified
IEC 62304 Class C.
```

This produces `specs/cgm-3000/spec.md` — the single source of truth that drives every downstream artifact.

### Generate requirements (`REQ-NNN`)

```
/speckit.v-model.requirements
```

The AI reads the specification and produces structured requirements — each with a persistent identifier, priority, rationale, and verification method:

| ID | Description | Priority |
|---|---|---|
| REQ-001 | The system SHALL sample interstitial glucose every 5 minutes (±15 sec) | P1 |
| REQ-002 | The system SHALL display current glucose on the companion app within 10 seconds | P1 |
| REQ-003 | The system SHALL trigger alerts within 30 sec when glucose falls below the hypoglycemia threshold | P1 |
| REQ-004 | The system SHALL trigger alerts within 30 sec when glucose exceeds the hyperglycemia threshold | P1 |
| REQ-005 | The system SHALL store readings with UTC timestamps for 90 days minimum | P1 |
| REQ-006 | The system SHALL transmit readings via Bluetooth Low Energy (BLE 5.0+) | P1 |

Every requirement is validated against 8 criteria: unambiguous, testable, atomic, complete, consistent, traceable, feasible, and necessary. "The system should respond quickly" would fail validation. "The system SHALL display the current glucose value within 10 seconds of sensor acquisition" passes.

The human reviews every requirement before committing. A hallucinated threshold — 250ms instead of 150ms — would propagate structurally perfect but functionally dangerous artifacts downstream. The human catches what the AI cannot guarantee.

### Generate acceptance tests (`ATP-NNN-X`)

```
/speckit.v-model.acceptance
```

For every requirement, the extension generates paired test cases with BDD scenarios:

> **ATP-003-A** (Hypoglycemia Alert Triggers Below Threshold)
>
> - **Given** the hypoglycemia threshold is configured to 70 mg/dL
> - **And** the system is receiving normal glucose readings of 100 mg/dL
> - **When** the sensor reports a glucose value of 65 mg/dL
> - **Then** the system activates an audible alert within 30 seconds
> - **And** the system activates a haptic alert within 30 seconds

The critical validation: a deterministic script confirms **100% forward coverage** — every `REQ-NNN` has at least one `ATP-NNN-X` test case. This is not an AI assessment. It is a regex-based computation that produces the same answer every time.

### Build the traceability matrix

```
/speckit.v-model.trace
```

The trace command produces **Matrix A** — the bidirectional mapping between requirements and acceptance tests:

| Requirement | Acceptance Tests | Status |
|---|---|---|
| REQ-001 | ATP-001-A, ATP-001-B | ⬜ Untested |
| REQ-002 | ATP-002-A | ⬜ Untested |
| REQ-003 | ATP-003-A, ATP-003-B | ⬜ Untested |
| REQ-004 | ATP-004-A, ATP-004-B | ⬜ Untested |
| REQ-005 | ATP-005-A, ATP-005-B | ⬜ Untested |
| REQ-006 | ATP-006-A | ⬜ Untested |

**Coverage: 100%** — no gaps, no orphans. This is what you show the auditor for IEC 62304 Clause 5.7.4.

### Go deeper: system design, architecture, modules

For Class C, IEC 62304 requires architecture (Clause 5.3) and detailed design (Clause 5.4). The workflow continues down the left side of the V:

```
/speckit.v-model.system-design        → SYS-NNN (IEEE 1016 views)
/speckit.v-model.architecture-design  → ARCH-NNN (IEEE 42010 / 4+1 views)
/speckit.v-model.module-design        → MOD-NNN (pseudocode, state machines)
```

Each design level gets a paired testing level on the right side of the V:

```
/speckit.v-model.system-test          → STP-NNN-X / STS-NNN-X#
/speckit.v-model.integration-test     → ITP-NNN-X / ITS-NNN-X#
/speckit.v-model.unit-test            → UTP-NNN-X / UTS-NNN-X#
```

After each pair, rerun `/speckit.v-model.trace` to rebuild the traceability matrix. By the time you reach the bottom, you have:

- **Matrix A** — Requirements ↔ Acceptance Tests
- **Matrix B** — System Design ↔ System Tests
- **Matrix C** — Architecture ↔ Integration Tests
- **Matrix D** — Module Design ↔ Unit Tests

Each matrix is deterministically verified for 100% coverage.

### Run hazard analysis

```
/speckit.v-model.hazard-analysis
```

IEC 62304 references **ISO 14971** for risk management. The hazard analysis command produces an FMEA register:

| ID | Hazard | Severity | Likelihood | Risk Level | Mitigation |
|---|---|---|---|---|---|
| HAZ-001 | Sensor fails to report glucose reading | Catastrophic | Occasional | Unacceptable | REQ-003 (alert timeout), SYS-002 (watchdog) |
| HAZ-002 | BLE connection drops during alert transmission | Critical | Probable | Unacceptable | REQ-006 (retry logic), ARCH-004 (store-and-forward) |
| HAZ-003 | Battery depletes without warning | Critical | Remote | Tolerable | REQ-NF-001 (14-day minimum), SYS-005 (low-battery alert) |

Mitigations trace back to `REQ-NNN` and `SYS-NNN` items. The trace command adds **Matrix H** — hazard ↔ mitigation ↔ verification traceability — automatically when `hazard-analysis.md` exists.

### Generate the audit report

```
/speckit.v-model.audit-report
```

The audit report is the capstone: a point-in-time release package that includes artifact inventory pinned to Git SHAs, all traceability matrices, coverage analysis, hazard management summary, and a compliance gate:

```
OVERALL STATUS: ✅ RELEASE READY

Matrices: A ✅ | B ✅ | C ✅ | D ✅ | H ✅
Coverage: Requirements 100% | Hazards 100%
Gaps: 0 | Orphans: 0 | Anomalies: 0
```

If any gap exists — an untested requirement, an orphaned test case, an unmitigated hazard — the status flips to `❌ NOT RELEASE READY` with specific IDs in the exception report.

---

## What Auditors Actually Look For

IEC 62304 auditors evaluate three things above all else:

**Completeness.** Is every required deliverable present? For Class C, that means requirements, architecture, detailed design, unit verification, integration testing, system testing, risk management, and traceability. The V-Model Extension generates all of them from a single specification, with each artifact stored as a Markdown file in `specs/{feature}/v-model/`.

**Traceability.** Can you trace from any requirement forward to its test cases, and from any test case backward to its requirement? The deterministic traceability matrix — computed by script, not by AI — provides this bidirectionally across all four V-levels plus hazard mitigations.

**Consistency.** Do the artifacts agree with each other? If `REQ-003` specifies a 30-second alert threshold, does `ATP-003-A` test for 30 seconds? Impact analysis (`/speckit.v-model.impact-analysis`) catches inconsistencies by tracing change impact across the entire V-Model — if a requirement changes, every downstream artifact that references it is flagged as suspect.

The artifacts that the V-Model Extension produces are not different in kind from what a manual team produces. They are structured requirements, paired test cases, design documents, and traceability matrices. The difference is that they are generated in minutes, verified deterministically, and stored in Git with cryptographic commit hashes — which is, coincidentally, exactly the kind of evidence trail that auditors love.

---

## The Bottom Line

IEC 62304 Class C compliance does not have to be a six-month documentation marathon. The deliverables are the same. The rigor is the same. The evidence is the same — arguably stronger, because coverage is verified by deterministic scripts rather than manual cross-referencing.

What changes is the time. Minutes of generation plus human review, instead of weeks of manual authoring. Seconds of deterministic verification, instead of days of spreadsheet maintenance. A Git history that *is* the audit trail, instead of a separate QMS that has to be kept in sync.

The AI drafts. The human decides. The scripts verify. Git remembers.

---

## Next in the Series

**Part 3 — Automotive Functional Safety with ISO 26262** — ASIL-D is the most demanding automotive safety integrity level, and it requires traceability proportional to risk. We will walk through generating the evidence package that a functional safety assessor expects — from safety goals to unit test traceability — using the same spec-driven methodology.

---

## Get Started

Ready to try this on your own medical device project?

- **[Tutorial: Blood Glucose Monitor (IEC 62304 Class C)](../../tutorials/medical-device.md)** — The full end-to-end walkthrough with every command and example output.
- **[IEC 62304 Compliance Reference](../../compliance/iec-62304.md)** — Detailed artifact mapping by safety class, clause-by-clause.
- **[Getting Started Guide](../../getting-started/index.md)** — Install the extension and generate your first traceable specification in minutes.
