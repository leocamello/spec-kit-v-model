# Standards Reference Guide

> **spec-kit V-Model Extension — Standards Landscape, Rationale & Roadmap**
>
> This document captures the complete standards landscape underpinning the
> spec-kit V-Model extension. It serves three purposes:
>
> 1. **Document the current state** — every standard already referenced in our
>    agents/commands, why it was chosen, and what it brings.
> 2. **Propose enhancements** — new best-practice standards that would raise the
>    quality bar for each V-Cycle layer.
> 3. **Chart a roadmap** — a phased plan to integrate the new standards and the
>    outcomes we expect when the work is complete.

---

## Table of Contents

1. [Current State — Standards Already in Use](#1-current-state--standards-already-in-use)
   1. [Master List of All Standards Referenced](#11-master-list-of-all-standards-referenced)
   2. [Standards Mapped to Each V-Cycle Layer](#12-standards-mapped-to-each-v-cycle-layer)
   3. [Rationale & Benefits per Standard](#13-rationale--benefits-per-standard)
2. [Proposed Enhancements — New Standards](#2-proposed-enhancements--new-standards)
   1. [Suggested New Standards Mapped to Each V-Cycle Layer](#21-suggested-new-standards-mapped-to-each-v-cycle-layer)
   2. [Rationale for Each Suggested Standard](#22-rationale-for-each-suggested-standard)
   3. [Domain-Specific High-Integrity Clauses per V-Model Phase](#23-domain-specific-high-integrity-clauses-per-v-model-phase)
3. [Implementation Roadmap](#3-implementation-roadmap)
4. [Vision — Final Outcomes](#4-vision--final-outcomes)
5. [Summary](#5-summary)

---

## 1. Current State — Standards Already in Use

The spec-kit V-Model extension now references **26 unique standards**
across **14 command files**, their corresponding templates, supporting
documentation, and 36 domain overlay files (12 commands × 3 domains). These
standards fall into two categories:

- **🟢 Best Practice** — govern the core V-Cycle methodology for each layer
  (requirements, design, testing). They apply to every project regardless of
  industry.
- **🔴 Safety-Specific** — extend the best-practice baseline with domain-specific
  safety and regulatory requirements (automotive, aviation, medical, industrial).
  They are activated per project configuration.

> **Standards Enrichment complete (v0.6.0):** All 9 new best-practice standards proposed in
> §2.1–2.2 have been integrated into the base commands. All 3 phases of the
> Implementation Roadmap (§3) are complete. §1.1 and §1.2 below reflect the
> current post-v0.6.0 state.

### 1.1 Master List of All Standards Referenced

| # | Standard | Full Name / Scope | Category | Where Referenced (Commands) |
|---|---------|-------------------|----------|---------------------------|
| 1 | **IEEE 29148:2018** | Systems & Software Engineering — Requirements | 🟢 Best Practice | `requirements.md`, `trace.md`, `peer-review.md` |
| 2 | **INCOSE GWR** | Guide for Writing Requirements | 🟢 Best Practice | `requirements.md`, `peer-review.md` |
| 3 | **ISO/IEC 25010:2023** | Systems & Software Quality Models (9 characteristics) | 🟢 Best Practice | `requirements.md`, `acceptance.md`, `system-design.md`, `architecture-design.md` |
| 4 | **IEEE 1012:2016** | System, Software & Hardware Verification & Validation | 🟢 Best Practice | `acceptance.md`, `system-test.md`, `integration-test.md`, `unit-test.md`, `trace.md` |
| 5 | **IEEE 1016:2009** | Software Design Descriptions | 🟢 Best Practice | `system-design.md`, `module-design.md`, `peer-review.md` |
| 6 | **IEEE 42010:2011** | Architecture Description | 🟢 Best Practice | `architecture-design.md`, `peer-review.md` |
| 7 | **Kruchten 4+1** | 4+1 Architectural View Model | 🟢 Best Practice | `architecture-design.md`, `peer-review.md` |
| 8 | **ISO/IEC 42030:2019** | Architecture Evaluation | 🟢 Best Practice | `architecture-design.md` |
| 9 | **ISO/IEC/IEEE 29119** | Software & Systems Testing | 🟢 Best Practice | `system-test.md`, `peer-review.md` |
| 10 | **ISO/IEC/IEEE 29119-3:2013** | Test Documentation | 🟢 Best Practice | `test-results.md` |
| 11 | **ISO/IEC/IEEE 29119-4:2021** | Test Techniques (white-box & black-box) | 🟢 Best Practice | `acceptance.md`, `unit-test.md`, `integration-test.md`, `peer-review.md` |
| 12 | **ISO/IEC/IEEE 12207:2017** | Software Lifecycle Processes | 🟢 Best Practice | `module-design.md` |
| 13 | **IEC 60812:2018** | FMEA — Failure Modes & Effects Analysis | 🟢 Best Practice | `hazard-analysis.md` |
| 14 | **ISO 14971:2019** | Medical Device Risk Management | 🟢 Best Practice ¹ | `hazard-analysis.md`, `peer-review.md` |
| 15 | **IEEE 1028:2008** | Software Reviews & Audits | 🟢 Best Practice | `peer-review.md` |
| 16 | **ISO/IEC 20246:2017** | Work Product Reviews | 🟢 Best Practice | `peer-review.md` |
| 17 | **IEEE 828-2012** | Configuration Management in Systems & Software Engineering | 🟢 Best Practice | `audit-report.md`, `impact-analysis.md` |
| 18 | **ISO 19011:2018** | Guidelines for Auditing Management Systems | 🟢 Best Practice | `audit-report.md` |
| 19 | **ISO/IEC/IEEE 15289:2019** | Content of Life-Cycle Information Items | 🟢 Best Practice | `audit-report.md`, `trace.md` |
| 20 | **ISO 26262** | Automotive Functional Safety | 🔴 Safety | overlays: `requirements`, `acceptance`, `system-design`, `architecture-design`, `system-test`, `integration-test`, `module-design`, `unit-test`, `hazard-analysis`, `trace`, `peer-review`, `audit-report`, `impact-analysis` |
| 21 | **DO-178C** | Airborne Software Assurance (Aviation) | 🔴 Safety | overlays: `requirements`, `acceptance`, `system-design`, `architecture-design`, `system-test`, `integration-test`, `module-design`, `unit-test`, `hazard-analysis`, `trace`, `peer-review`, `audit-report`, `impact-analysis` |
| 22 | **IEC 62304** | Medical Device Software Lifecycle | 🔴 Safety | overlays: `requirements`, `acceptance`, `system-design`, `architecture-design`, `system-test`, `integration-test`, `module-design`, `unit-test`, `hazard-analysis`, `trace`, `peer-review`, `audit-report`, `impact-analysis` |
| 23 | **IEC 61508** | Industrial Functional Safety | 🔴 Safety | `trace.md` (domain reference) |
| 24 | **FDA 21 CFR 820** | Medical Device Quality Systems | 🔴 Safety | `trace.md` (domain reference) |
| 25 | **MISRA C/C++** | Safety-Critical Coding Rules | 🔴 Safety | overlays: `module-design` (iso_26262, do_178c) |
| 26 | **CERT-C** | Secure Coding Standard | 🔴 Safety | overlays: `module-design` (do_178c) |

> **Note:** ISO 8601 (date formatting) also appears in `peer-review.md` but is a
> utility standard, not a V-Cycle concern. JUnit XML and Cobertura XML are de
> facto formats referenced by `test-results.md`.
>
> ¹ ISO 14971:2019 is listed as Best Practice because the `hazard-analysis.md`
> command uses its risk estimation framework (severity × likelihood matrix) as the
> **general-purpose** base, independently of any safety domain. Domain-specific
> overlays then layer the ISO 26262 HARA, DO-178C FHA, or IEC 62304 safety class
> methodology on top.

### 1.2 Standards Mapped to Each V-Cycle Layer

> **Updated for v0.6.0 (Standards Enrichment complete).** Every column reflects the current
> post-v0.6.0 state of the base commands. Safety extensions are delivered by
> domain overlay files (`commands/overlays/{domain}/`).

| V-Cycle Layer | Command | 🟢 Best Practice Standard | 🔴 Safety Extensions (§-sections) |
|---|---|---|---|
| **Requirements** | `requirements.md` | IEEE 29148:2018 / INCOSE GWR / **ISO/IEC 25010:2023** (Step 6 quality characteristics) | ISO 26262-6 §6.4 (ASIL Allocation + Decomposition), DO-178C §5.2.1 Table A-4 (DAL Traceability, Derived Requirements), IEC 62304 §5.2 + §4.3 (Risk Analysis Input, Safety Class Rigor) |
| **Acceptance Test** | `acceptance.md` | **IEEE 1012:2016** (Step 6c V&V validation) / **ISO/IEC 25010:2023** (Step 6d quality-in-use) / ISO/IEC 29119-4:2021 (Step 5 BDD structure) | ISO 26262-6 §6.9 Table 11 (ASIL-dependent Verification Methods), DO-178C §6.4.2 Table A-7 (Coverage by DAL, Robustness Testing), IEC 62304 §5.7 (Safety Class Test Completeness, Regression) |
| **System Design** | `system-design.md` | IEEE 1016:2009 (§5.1–5.4 four mandatory views) / **ISO/IEC 25010:2023** (Step 6 quality attribute cross-check) | ISO 26262-6 §7.4.8 (Freedom from Interference), §7.4.9 (Restricted Complexity), §6.5 (Safety Mechanisms Allocation); DO-178C §5.2.2 (Partitioning, Data/Control Coupling, Derived Requirements); IEC 62304 §5.3 (Architecture + Risk Control Traceability) |
| **System Test** | `system-test.md` | ISO/IEC/IEEE 29119 (test techniques) / **IEEE 1012:2016** (Step 7 V&V Coverage Gate §5.5) | ISO 26262-6 §6.9 Table 11 (MC/DC by ASIL, Back-to-Back Testing), DO-178C §6.4 Table A-7/A-8 (Structural Coverage by DAL), IEC 62304 §5.7 (Testing by Safety Class) |
| **Architecture Design** | `architecture-design.md` | IEEE 42010:2011 (4 views + rationale) / Kruchten 4+1 / **ISO/IEC 42030:2019** (Step 5.5 evaluation) / **ISO/IEC 25010:2023** (Step 5.5 quality attribute justification) | ISO 26262-9 §5 (ASIL Decomposition), ISO 26262-6 §7.4.2/§7.4.4 (Defensive Programming, Temporal Constraints); DO-178C §5.2.2 Table A-5 (Partitioning, Data/Control Coupling by DAL); IEC 62304 §5.3 (Architecture by Safety Class) |
| **Integration Test** | `integration-test.md` | ISO/IEC/IEEE 29119-4:2021 (4 test techniques) / **IEEE 1012:2016** (Step 7 V&V Coverage Gate §5.6) | ISO 26262-6 §6.8 (SIL/HIL Testing by ASIL, Resource Contention), DO-178C §6.4 Table A-8 (Integration Testing by DAL, Hardware Fidelity), IEC 62304 §5.6 (Integration Testing by Safety Class) |
| **Module Design** | `module-design.md` | IEEE 1016:2009 (detailed design structure) / **ISO/IEC/IEEE 12207:2017** (§8.4.4 §4.0 preamble) | ISO 26262-6 §8.4.5 (MISRA C/C++, Complexity Constraints by ASIL), DO-178C §5.2.3/§6.3.4 Table A-6 (CERT-C, Complexity Limits by DAL), IEC 62304 §5.4 (Detailed Design by Safety Class) |
| **Unit Test** | `unit-test.md` | ISO/IEC/IEEE 29119-4:2021 (5 mandatory white-box techniques) / **IEEE 1012:2016** (Step 8 Coverage Gate §5.7) | ISO 26262-6 §9.4.4 Table 11 (MC/DC by ASIL, Variable-Level Fault Injection), DO-178C §6.4.4 Table A-7 (Structural Coverage by DAL, MC/DC for DAL A), IEC 62304 §5.5 (Verification by Safety Class, Robustness Testing) |
| **Hazard Analysis** | `hazard-analysis.md` | **IEC 60812:2018** (Step 4.0 FMEA procedure §6) / ISO 14971:2019 (§4.6 risk matrix §5) | ISO 26262-3 §7 / ISO 26262-9 §7 (HARA, ASIL Classification S×E×C), DO-178C + ARP 4761 (FHA, Failure Condition Classification, DAL Determination), IEC 62304 §7 + ISO 14971 (Software Safety Classification A–C) |
| **Traceability** | `trace.md` | **IEEE 1012:2016** (V&V activity coverage) / **ISO/IEC/IEEE 15289:2019** (content requirements) / IEEE 29148:2018 (traceability property) | ISO 26262-6 Cl.9 / ISO 26262-8 (Bidirectional Traceability by ASIL), DO-178C §6.3.4 Table A-9 (Traceability by DAL), IEC 62304 §5.7/§8 (Traceability by Safety Class) |
| **Peer Review** | `peer-review.md` | **IEEE 1028:2008** (Step 2.5 review type selection, Step 4 process) / **ISO/IEC 20246:2017** (Step 4 defect taxonomy §6.3) | ISO 26262 Table 1 (Review rigor by ASIL — walkthrough at QM, formal inspection at ASIL D), DO-178C §6.3 (Reviews by DAL — formal inspection at DAL A), IEC 62304 §5.x (Review rigor by Safety Class — independent review at Class C) |
| **Audit Report** | `audit-report.md` | **IEEE 828-2012** (FCA/PCA §6.4) / **ISO 19011:2018** (finding classification §6.4.9) / **ISO/IEC/IEEE 15289:2019** (content §D.31) | ISO 26262-2 §6 (Functional Safety Audit, Confirmation Measures), DO-178C §8 SQA / §9 Certification Liaison (SOI-1–SOI-4), IEC 62304 §8/§9 (CM Audit, Problem Resolution) |
| **Impact Analysis** | `impact-analysis.md` | **IEEE 828-2012** (§6.3 Configuration Control, CCB review) | ISO 26262-8 §8 (Safety-Impacted Item Assessment, ASIL Re-evaluation), DO-178C §7 (Change Control, Problem Reporting), IEC 62304 §6/§8 (Software Maintenance, CM by Safety Class) |
| **Test Results** | `test-results.md` | **ISO/IEC 29119-3:2013** (Test Status Report §9.2, Test Completion Report §9.3) | ISO 26262-6 §6.7 Table 12 (ASIL Coverage Metrics), DO-178C §6.4/§11 (Test Evidence by DAL), IEC 62304 §5.5/§5.6/§5.7 (Test Results by Safety Class) |

> **Bold** standards were added in v0.6.0. Every layer now has at least
> one explicit best-practice governing standard — the original goal of this
> standards programme.

### 1.3 Rationale & Benefits per Standard

#### 🟢 Best Practice Standards

**IEEE 29148 — Requirements Engineering**

- **Rationale:** Provides the internationally recognized framework for eliciting,
  analyzing, specifying, and validating requirements. It supersedes the legacy
  IEEE 830 and defines the structure of a Software Requirements Specification
  (SRS) that supports testability and traceability.
- **Benefits:** Every requirement produced by the `requirements.md` command
  follows a consistent, testable structure. The standard's emphasis on
  unambiguous language, unique identifiers, and completeness criteria directly
  enables downstream traceability to design and test artifacts.

**INCOSE Guide for Writing Requirements**

- **Rationale:** Complements IEEE 29148 with practitioner-level guidance on
  requirement quality. Its "8-criteria" validation (necessary, appropriate,
  unambiguous, complete, singular, feasible, verifiable, correct) and banned-word
  list provide concrete, enforceable rules.
- **Benefits:** The `requirements.md` and `peer-review.md` commands use the
  INCOSE criteria as automated quality gates — any requirement failing the
  criteria is flagged before it propagates into design or test artifacts.

**IEEE 1016 — Software Design Descriptions**

- **Rationale:** Defines four mandatory design views (Decomposition, Dependency,
  Interface, Data Design) that together provide a complete picture of how a
  system is structured, how components relate, what their interfaces look like,
  and how data flows through them.
- **Benefits:** The `system-design.md` command enforces all four views, ensuring
  no design dimension is silently omitted. The `system-test.md` command
  cross-references IEEE 1016 views to ensure test cases cover all design aspects.

**IEEE 42010 / Kruchten 4+1 — Architecture Description**

- **Rationale:** IEEE 42010 provides the meta-model for architecture descriptions
  (stakeholders, concerns, viewpoints, views). The Kruchten 4+1 model
  instantiates it with four concrete views (Logical, Process, Interface, Data
  Flow) plus scenarios, which are well-understood across the industry.
- **Benefits:** The `architecture-design.md` command produces architecture
  documents that any architect can review using familiar viewpoint conventions.
  The four-view structure ensures that static structure, runtime behavior,
  integration contracts, and data transformations are all explicitly documented.

**ISO 29119 — Software Testing**

- **Rationale:** The international standard for software testing, covering test
  processes, documentation, and techniques. It provides a common vocabulary and
  a catalog of named test techniques (Equivalence Partitioning, Boundary Value
  Analysis, State Transition, Error Guessing, etc.).
- **Benefits:** The `system-test.md` and `integration-test.md` commands require
  every test case to name its ISO 29119 technique explicitly. This makes test
  design rationale transparent and auditable, and ensures technique diversity
  across the test suite.

**ISO 29119-4 — Test Techniques**

- **Rationale:** Part 4 of ISO 29119 focuses specifically on test design
  techniques, including white-box methods (Statement Coverage, Branch Coverage,
  Data Flow, MC/DC, and Fault Injection).
- **Benefits:** The `unit-test.md` command mandates five white-box techniques per
  module, ensuring structural coverage at the lowest level. The explicit
  technique naming ties each test case to a recognized method.

#### 🔴 Safety-Specific Standards

**ISO 26262 — Automotive Functional Safety**

- **Rationale:** The primary standard for functional safety in automotive systems.
  Its ASIL classification (A–D + QM) drives the rigor of design, verification,
  and validation activities proportional to the hazard risk.
- **Benefits:** Referenced in safety extension sections across six commands. When
  the `iso_26262` domain is active, it adds ASIL decomposition to architecture,
  freedom-from-interference constraints to system design, and structural coverage
  targets to testing.

**DO-178C — Airborne Software Assurance**

- **Rationale:** The certification standard for airborne software (aviation). Its
  Design Assurance Levels (DAL A–E) determine the required verification
  activities, structural coverage objectives, and documentation depth.
- **Benefits:** When the `do_178c` domain is active, it adds MC/DC coverage
  requirements to unit tests, structural coverage analysis to system tests,
  defensive programming constraints to architecture, and single-entry/exit
  enforcement to module design.

**IEC 62304 — Medical Device Software Lifecycle**

- **Rationale:** Defines the software lifecycle requirements for medical device
  software, with safety classes (A, B, C) that determine the required process
  rigor.
- **Benefits:** Used in hazard analysis for medical domain classification and in
  the traceability command to validate that medical-device traceability
  requirements (Clause 5.7) are satisfied.

**ISO 14971 — Medical Device Risk Management**

- **Rationale:** The foundational risk management standard for medical devices.
  Defines the risk analysis, evaluation, and control process that feeds into
  hazard analysis.
- **Benefits:** The `hazard-analysis.md` command uses ISO 14971's FMEA
  methodology as the basis for hazard identification, severity classification,
  and risk mitigation tracking.

**IEC 61508 — Industrial Functional Safety**

- **Rationale:** The umbrella functional safety standard for industrial
  applications (electrical/electronic/programmable electronic). It provides
  Safety Integrity Levels (SIL 1–4).
- **Benefits:** Referenced in the traceability command to ensure that industrial
  safety projects maintain the required traceability between requirements, design,
  code, and validation (Part 3, Clause 7.9).

**FDA 21 CFR Part 820 — Medical Device Quality Systems**

- **Rationale:** The US federal regulation governing quality systems for medical
  devices. Section 820.30(i) specifically mandates design validation.
- **Benefits:** Referenced in the traceability command to ensure that FDA-regulated
  projects can demonstrate that design validation has been performed and that
  devices conform to defined user needs and intended uses.

**MISRA C/C++ — Safety-Critical Coding Rules**

- **Rationale:** The de facto coding standard for safety-critical C/C++ software
  in automotive, aerospace, and industrial applications. Provides a curated rule
  set that eliminates undefined behavior, implementation-defined behavior, and
  other language pitfalls.
- **Benefits:** The `module-design.md` command annotates module specifications
  with applicable MISRA rules, ensuring that downstream code implementation can
  be verified for compliance.

**CERT-C — Secure Coding Standard**

- **Rationale:** Developed by the SEI/CERT Coordination Center, this standard
  provides coding rules focused on security and reliability. It complements MISRA
  by addressing security-specific concerns (buffer overflows, integer overflows,
  race conditions).
- **Benefits:** Referenced alongside MISRA in the module design complexity
  constraints section, ensuring that security considerations are built into the
  design specification, not bolted on later.

#### Standards Enrichment Additions (v0.6.0)

The following 11 standards were added in v0.6.0. See §2.2 for the
full rationale on ISO/IEC 25010:2023, IEEE 1012:2016, ISO/IEC 42030:2019,
ISO/IEC/IEEE 12207:2017, IEEE 1028:2008, ISO/IEC 20246:2017, IEEE 828-2012,
ISO 19011:2018, and ISO/IEC/IEEE 15289:2019.

**IEC 60812:2018 — Analysis Techniques for System Reliability: FMEA Procedure**

- **Rationale:** Provides the authoritative international standard for Failure
  Mode and Effects Analysis (FMEA) — the systematic procedure for analyzing
  potential failure modes, their causes, and their effects on system operation.
  Supersedes the 2006 edition with a strengthened process structure, clearer
  FMEA types (Design FMEA, Process FMEA), and explicit ordered steps.
- **Benefits:** The `hazard-analysis.md` command now follows IEC 60812:2018 §6
  ordered procedure as its primary FMEA backbone, independent of any
  domain-specific safety standard. Domain overlays then layer ISO 14971 /
  ISO 26262 / ARP 4761 severity scales on top of this neutral FMEA structure.

**ISO/IEC 29119-3:2013 — Software and Systems Engineering — Software Testing,
Part 3: Test Documentation**

- **Rationale:** Prescribes the required content and structure for test status
  reports, test completion reports, incident reports, and test logs. Provides a
  domain-neutral baseline for what information must be captured when recording
  test results.
- **Benefits:** The `test-results.md` command's output now maps to ISO 29119-3
  §9.2 (Test Status Report) and §9.3 (Test Completion Report) fields, ensuring
  test records meet documentation expectations regardless of whether the project
  is subject to safety certification. Domain overlays extend this with
  ASIL/DAL/Safety Class coverage metric requirements.

---

## 2. Implemented Enhancements — New Standards (v0.6.0 Complete)

The following standards were identified through systematic research and have
been integrated into spec-kit-v-model v0.6.0. They fill gaps in layers that
previously lacked an explicit standard and complement existing standards with
orthogonal capabilities.

### 2.1 New Standards — Implementation Status (v0.6.0 ✅)

All standards below are now implemented in the base commands. See §2.2 for full
rationale on each.

| V-Cycle Layer | Command | Integrated Standard | What It Adds | Status |
|---|---|---|---|---|
| **Requirements** | `requirements.md` | **ISO/IEC 25010:2023** (Product Quality Model) | Structured taxonomy (9 characteristics) for quality requirements — completeness checklist for NFRs | ✅ Done |
| **Acceptance Test** | `acceptance.md` | **IEEE 1012:2016** (Verification & Validation) | Formal validation activities, entry/exit criteria, V&V traceability, verification vs validation distinction | ✅ Done |
| **Acceptance Test** | `acceptance.md` | **ISO/IEC 25010:2023** (Product Quality Model) | Quality-in-use acceptance criteria beyond functional pass/fail | ✅ Done |
| **System Design** | `system-design.md` | **ISO/IEC 25010:2023** (Product Quality Model) | Formal basis for design-time quality attribute traceability | ✅ Done |
| **System Test** | `system-test.md` | **IEEE 1012:2016** (Verification & Validation) | V&V coverage analysis — every requirement exercised by at least one V&V activity | ✅ Done |
| **Architecture Design** | `architecture-design.md` | **ISO/IEC 42030:2019** (Architecture Evaluation) | Scenario-based evaluation, trade-off assessment, fitness-for-purpose judgment | ✅ Done |
| **Architecture Design** | `architecture-design.md` | **ISO/IEC 25010:2023** (Product Quality Model) | Quality attribute justification for architecture decisions | ✅ Done |
| **Module Design** | `module-design.md` | **ISO/IEC/IEEE 12207:2017** (Lifecycle Processes) | General-purpose detailed design process independent of safety domain (§8.4.4) | ✅ Done |
| **Hazard Analysis** | `hazard-analysis.md` | **IEC 60812:2018** (FMEA Procedure) | Authoritative domain-neutral FMEA procedure as primary backbone | ✅ Done |
| **Traceability** | `trace.md` | **IEEE 1012:2016** (Verification & Validation) | V&V traceability — verified by appropriate V&V method, not just linked | ✅ Done |
| **Traceability** | `trace.md` | **ISO/IEC/IEEE 15289:2019** (Lifecycle Information Items) | Required content for lifecycle documentation completeness checks | ✅ Done |
| **Peer Review** | `peer-review.md` | **IEEE 1028:2008** (Software Reviews & Audits) | Formal review types with roles, entry/exit criteria, metrics | ✅ Done |
| **Peer Review** | `peer-review.md` | **ISO/IEC 20246:2017** (Work Product Reviews) | Review technique selection, defect taxonomy, follow-up verification | ✅ Done |
| **Audit Report** | `audit-report.md` | **IEEE 828-2012** (Configuration Management) | FCA/PCA configuration audits, audit process, roles, evidence requirements | ✅ Done |
| **Audit Report** | `audit-report.md` | **ISO 19011:2018** (Auditing Management Systems) | Audit principles, auditor competence, finding classification | ✅ Done |
| **Audit Report** | `audit-report.md` | **ISO/IEC/IEEE 15289:2019** (Lifecycle Information Items) | Audit report content requirements | ✅ Done |
| **Impact Analysis** | `impact-analysis.md` | **IEEE 828-2012** (Configuration Management) | Change request evaluation, impact assessment, configuration control formalization | ✅ Done |
| **Test Results** | `test-results.md` | **ISO/IEC 29119-3:2013** (Test Documentation) | Test status/completion report structure, mandatory fields | ✅ Done |

### 2.2 Rationale for Each Integrated Standard

#### ISO/IEC 25010:2023 — Product Quality Model

**What it is.** The 2023 revision of the SQuaRE product quality model, defining 9
top-level quality characteristics (up from 8 in the 2011 edition) and their
sub-characteristics. The new edition notably adds **Safety** as a first-class
characteristic, renames Usability to **Interaction Capability** and Portability to
**Flexibility** (with a new **Scalability** sub-characteristic), and introduces
**Inclusivity** and **Self-descriptiveness**.

**Why we need it.** The spec-kit V-Model currently enforces *functional*
completeness very well (every REQ must have a test, every SYS must map to an
ARCH, etc.) but has no formal taxonomy for *non-functional* quality. When a user
writes requirements, there is no systematic prompt to consider performance,
security, reliability, or maintainability. ISO/IEC 25010:2023 fills this gap by
providing a checklist that applies at every layer:

- **Requirements:** "Have we specified requirements for each relevant 25010
  characteristic?"
- **Design:** "Does our architecture justify decisions against 25010 quality
  attributes?"
- **Acceptance:** "Do our acceptance criteria validate quality-in-use targets?"

**Applicable layers:** Requirements, Acceptance Test, System Design, Architecture
Design.

#### IEEE 1012:2016 — Verification & Validation

**What it is.** The IEEE standard for system, software, and hardware V&V. It
defines V&V activities for each lifecycle phase, emphasizes the distinction
between verification (conformance to specification) and validation (fitness for
intended use), and prescribes V&V traceability, coverage analysis, and
independent V&V for critical systems.

**Why we need it.** The `acceptance.md` command is the **only V-Cycle layer with
no governing standard at all**. IEEE 1012 directly addresses acceptance
validation: it prescribes entry/exit criteria, formal validation activities, and
traceability from acceptance tests to stakeholder needs. Beyond acceptance, it
strengthens system testing (V&V coverage analysis) and traceability (V&V method
verification).

**Applicable layers:** Acceptance Test (primary), System Test, Traceability.

#### ISO/IEC 42030:2019 — Architecture Evaluation

**What it is.** The companion standard to IEEE 42010 (architecture description).
While 42010 defines *how to describe* an architecture, 42030 defines *how to
evaluate* one — using scenario-based analysis, trade-off assessment, and
fitness-for-purpose judgment against stakeholder concerns.

**Why we need it.** The `architecture-design.md` command produces a well-structured
architecture description (four views, traceability to system components). But it
does not currently prescribe *evaluation* of that architecture — there is no
formal step that asks "does this architecture satisfy our quality attribute
scenarios?" or "what are the trade-offs of this decomposition?". ISO 42030 closes
this loop.

**Applicable layers:** Architecture Design.

#### IEEE 1028:2008 — Software Reviews & Audits

**What it is.** Defines five types of software reviews (management review,
technical review, inspection, walkthrough, audit) with prescribed roles,
procedures, entry/exit criteria, and metrics.

**Why we need it.** The `peer-review.md` command currently applies per-artifact
checklists (e.g., "Are all four IEEE 1016 views present?") but does not follow a
formal review process with roles, preparation phases, or defect categorization.
IEEE 1028 would add process rigor. For the `audit-report.md` command, IEEE 1028's
audit procedures (Functional and Physical Configuration Audits) provide the
missing best-practice baseline.

**Applicable layers:** Peer Review, Audit Report.

#### ISO/IEC 20246:2017 — Work Product Reviews

**What it is.** The modern ISO standard for reviewing software work products.
Lighter and more adaptable than IEEE 1028's formal inspections, it provides
guidance on review technique selection, defect logging taxonomy, and follow-up
verification.

**Why we need it.** As a complement to IEEE 1028, it offers a more pragmatic
review framework that aligns well with AI-assisted reviews. Its defect taxonomy
(major/minor/observation) and follow-up verification requirements would
standardize the peer-review output format.

**Applicable layers:** Peer Review.

#### ISO/IEC/IEEE 12207:2017 — Software Lifecycle Processes

**What it is.** The international standard defining software lifecycle processes,
including requirements analysis, architectural design, detailed design,
implementation, integration, testing, and maintenance.

**Why we need it.** The `module-design.md` command is currently governed only by
safety standards (DO-178C / ISO 26262). While this is appropriate for
safety-critical projects, non-regulated projects lack a best-practice baseline
for detailed module design. ISO 12207 Clause 8 prescribes the general-purpose
detailed design process: requirement allocation, algorithm specification,
interface definition, and design verification.

**Applicable layers:** Module Design.

#### ISO/IEC/IEEE 15289:2019 — Lifecycle Information Items

**What it is.** Defines the required content for lifecycle documentation —
plans, specifications, descriptions, reports, and records. It does not mandate
specific documents but specifies what information each type of artifact must
contain.

**Why we need it.** The traceability command currently validates linkage between
artifacts but does not verify that the artifacts themselves contain all required
information. ISO 15289 provides the content requirements that would enable a
"documentation completeness" check — ensuring that every plan has a scope, every
report has findings, and every specification has traceability data.

**Applicable layers:** Traceability, Audit Report.

#### IEEE 828 — Configuration Management

**What it is.** Defines the planning and implementation of software configuration
management: identification, control, status accounting, and auditing of
configuration items.

**Why we need it.** Impact analysis is fundamentally a change-management activity
— it answers "what is affected if I change this?". IEEE 828 formalizes the change
request evaluation and impact assessment process. For audits, it provides the
basis for Functional and Physical Configuration Audits.

**Applicable layers:** Audit Report, Impact Analysis.

#### ISO 19011:2018 — Auditing Management Systems

**What it is.** Provides guidelines for auditing management systems, including
audit principles, auditor competence, audit programs, and the audit process
itself.

**Why we need it.** The `audit-report.md` command currently operates without a
best-practice audit methodology standard. ISO 19011 provides the meta-process:
how to plan an audit, what evidence to collect, how to report findings, and how
to drive continual improvement from audit results.

**Applicable layers:** Audit Report.

### 2.3 Domain-Specific High-Integrity Clauses per V-Model Phase

The sections above (§2.1–2.2) address **best-practice** standards that apply
regardless of industry. This section completes the picture by mapping the
**specific clauses** from each high-integrity domain standard to every V-Model
phase. This mapping drives the domain overlay architecture: each entry below
corresponds to overlay content that activates when a project configures a
specific domain.

> **Key insight:** Every V-Model phase — including Requirements and Acceptance
> Testing — has domain-specific clauses in all three standards. The original
> overlay architecture (v0.5.0) only covered 7 of 13 commands. This analysis
> confirms that **all 9 generative commands plus 4 supporting commands** require
> domain overlay content.

#### V-Model Generative Commands

| V-Model Phase | ISO 26262 (Automotive) | DO-178C (Aerospace) | IEC 62304 (Medical) |
|---|---|---|---|
| **Requirements** | Part 6 §6.4 — ASIL allocation per requirement, derived safety requirements, safety mechanisms, safety goal traceability, fault detection/handling requirements | §5.2.1, Table A-4 — Derived requirements management, bidirectional traceability (DAL A–C), robustness requirements | §5.2 — Requirements linked to system requirements, risk analysis input, safety class–dependent rigor |
| **Acceptance Test** | Part 6 §6.9 — ASIL-dependent verification methods (Table 11), back-to-back testing, functional safety verification | §6.4.2, Table A-7 — Requirements-based testing, robustness testing, structural coverage by DAL (MC/DC for A, decision for B, statement for C) | §5.7 — System testing against requirements, safety class–dependent test completeness, regression after changes |
| **System Design** | Part 6 §6.5 — Freedom from Interference (FFI), restricted complexity, safety mechanisms allocation | §5.2.2 — Partitioning, derived requirements from design, data/control coupling analysis | §5.3 — Software item identification, risk control measures in architecture, interface documentation |
| **System Test** | Part 6 §6.9 + Table 11 — MC/DC, WCET analysis, structural coverage by ASIL, back-to-back testing | §6.4, Table A-7/A-8 — Requirements-based testing, structural coverage analysis by DAL | §5.7 — System testing per safety class, requirements coverage verification |
| **Architecture Design** | Part 9 §5 — ASIL decomposition; Part 6 §6.5 — defensive programming, temporal constraints, restricted complexity | §5.2.2, Table A-5 — DAL-driven architecture verification, partitioning requirements, data/control coupling | §5.3 — Architecture with safety class considerations, interface documentation, risk control traceability |
| **Integration Test** | Part 6 §6.8 — SIL/HIL testing, resource contention, back-to-back testing | §5.4, Table A-8 — Integration process verification, interface testing by DAL | §5.6 — Integration testing per safety class, interface verification |
| **Module Design** | Part 6 §8.4.4 / §8.4.5 (ISO 26262:2018) — MISRA C/C++, single entry/exit, complexity constraints, memory management | §5.2.3, Table A-6 — Low-level requirements, coding standards, complexity limits | §5.4 — Detailed design per safety class, coding standards |
| **Unit Test** | Part 6 §6.7 — MC/DC coverage, variable-level fault injection, equivalence classes by ASIL | §6.4.4, Table A-7 — Structural coverage by DAL (MC/DC for A, decision for B, statement for C) | §5.5 — Unit verification per safety class, code review requirements |
| **Hazard Analysis** | Part 3 §7, Part 9 §7 — HARA, FMEA/FTA, ASIL severity classification (S0–S3 × E1–E4 × C1–C3) | Failure condition classification (Catastrophic, Hazardous, Major, Minor, No Effect) via ARP 4761; safety assessment per §5.1 | §7 + ISO 14971 — Software risk management, safety classification (Class A–C), risk control measures |

#### Supporting Commands

| Command | ISO 26262 (Automotive) | DO-178C (Aerospace) | IEC 62304 (Medical) |
|---|---|---|---|
| **Trace** | Part 6 Cl.9, Part 8 — Bidirectional traceability, ASIL-dependent coverage depth | §6.3.4, Table A-9 — Traceability analysis, bidirectional by DAL (mandatory for A–C) | §5.7, §8 — Traceability and configuration management per safety class |
| **Peer Review** | Part 6, Table 1 — Review method rigor varies by ASIL (walkthrough at QM → formal inspection at ASIL D) | §6.3 — Reviews and analyses, rigor varies by DAL (formal inspection at DAL A, walkthrough at DAL D) | §5.x verification activities — Review rigor varies by safety class (Class C requires independent review) |
| **Impact Analysis** | Part 8 §8 — Change management, safety impact assessment, ASIL re-evaluation | §7 — Configuration management, change impact assessment, problem reporting | §6 — Software maintenance, §8 — Change management per safety class |
| **Audit Report** | Part 2 §6 — Functional safety audit, confirmation measures, assessment of functional safety management | §8 — Quality assurance (SQA), §9 — Certification liaison (SOI-1 through SOI-4 audits) | §8 — CM audit, §9 — Problem resolution tracking, safety class verification |
| **Test Results** | Part 6 §6.7 Table 12 — ASIL-dependent coverage metrics, Part 8 §9 — test documentation evidence | §6.4 — Test execution evidence, §11 — test procedure/results data items by DAL | §5.5/§5.6/§5.7 — Test result documentation per safety class, regression evidence |

#### Key Domain-Specific Differentiators

**ISO 26262 — Automotive**

- **Classification:** ASIL (QM, A–D) determined by Severity × Exposure × Controllability
- **Unique mechanism:** ASIL decomposition (Part 9 §5) — a higher-ASIL function
  can be decomposed across redundant elements with lower individual ASILs
- **Coverage mandate:** MC/DC at ASIL D, branch coverage at ASIL B, statement at
  ASIL A (Part 6 §6.7, Table 12)
- **Critical concept:** Freedom from Interference (FFI) — each ASIL element must
  be protected from interference by lower-ASIL elements

**DO-178C — Aerospace**

- **Classification:** DAL (A–E) derived from system-level failure condition
  severity assessment
- **Unique mechanism:** Objective tables (Tables A-4 through A-10) — each
  lifecycle activity has explicit objectives with independence requirements per DAL
- **Coverage mandate:** MC/DC at DAL A, decision at DAL B, statement at DAL C
  (Table A-7)
- **Critical concept:** Derived requirements — any requirement not directly
  traceable to a higher-level requirement must be fed back to the system safety
  assessment

**IEC 62304 — Medical**

- **Classification:** Safety Class (A–C) based on severity of hazard contribution
  (no injury → serious injury/death)
- **Unique mechanism:** Safety class determines which lifecycle activities are
  mandatory vs. optional (e.g., Class A skips detailed design and unit testing)
- **Coverage mandate:** Rigor scales with safety class; Class C requires full
  lifecycle documentation, Class A requires only requirements + system testing
- **Critical concept:** Integration with ISO 14971 risk management — software
  hazard analysis feeds directly into the product-level risk management file

---

## 3. Implementation Roadmap

The roadmap is organized into three phases, reflecting the priority and
dependency structure of the proposed changes.

### Phase 1 — Fill Critical Gaps ✅ COMPLETE (v0.6.0)

> **Focus:** Address the layers that previously had no governing standard and add
> the cross-cutting quality model.

| Action | Layer(s) Affected | Standard(s) | Status |
|--------|-------------------|-------------|--------|
| **1.1** Add quality attribute taxonomy to requirements | Requirements | ISO/IEC 25010:2023 | ✅ Done — Step 6 "Quality Characteristics Coverage" added to `requirements.md` |
| **1.2** Add V&V governance to acceptance testing | Acceptance Test | IEEE 1012:2016, ISO/IEC 25010:2023 | ✅ Done — Steps 6c (V&V validation) and 6d (quality-in-use) added to `acceptance.md` |
| **1.3** Add architecture evaluation | Architecture Design | ISO/IEC 42030:2019 | ✅ Done — Step 5.5 "Architecture Evaluation (ISO 42030)" added to `architecture-design.md` |

### Phase 2 — Strengthen Existing Layers ✅ COMPLETE (v0.6.0)

> **Focus:** Add complementary standards to layers that already have a
> best-practice baseline, deepening their rigor.

| Action | Layer(s) Affected | Standard(s) | Status |
|--------|-------------------|-------------|--------|
| **2.1** Add quality attributes to system design | System Design | ISO/IEC 25010:2023 | ✅ Done — Step 6 "ISO 25010 Quality Attribute Cross-Check" added to `system-design.md` |
| **2.2** Add V&V coverage to system testing | System Test | IEEE 1012:2016 | ✅ Done — Step 7 "IEEE 1012 V&V Coverage Gate (§5.5)" added to `system-test.md` |
| **2.3** Add lifecycle process basis to module design | Module Design | ISO/IEC/IEEE 12207:2017 | ✅ Done — §4.0 preamble (ISO 12207 §8.4.4) added to `module-design.md` |
| **2.4** Formalize review process | Peer Review | IEEE 1028:2008, ISO/IEC 20246:2017 | ✅ Done — Step 2.5 review-type selection (IEEE 1028) and Step 4 defect taxonomy (ISO 20246) added to `peer-review.md` |

### Phase 3 — Complete the Framework ✅ COMPLETE (v0.6.0)

> **Focus:** Add standards to supporting commands (audit, traceability, impact
> analysis) and ensure end-to-end consistency.

| Action | Layer(s) Affected | Standard(s) | Status |
|--------|-------------------|-------------|--------|
| **3.1** Add V&V traceability analysis | Traceability | IEEE 1012:2016 | ✅ Done — V&V method coverage check added to `trace.md` |
| **3.2** Add documentation completeness checks | Traceability, Audit Report | ISO/IEC/IEEE 15289:2019 | ✅ Done — Information-item completeness section added to both commands |
| **3.3** Formalize audit methodology | Audit Report | ISO 19011:2018 | ✅ Done — Audit principles, finding classification, corrective action tracking added to `audit-report.md` |
| **3.4** Add CM governance to audits and impact analysis | Audit Report, Impact Analysis | IEEE 828-2012 | ✅ Done — FCA/PCA audit steps added to `audit-report.md`; configuration control section added to `impact-analysis.md` |
| **3.5** Add FMEA baseline to hazard analysis | Hazard Analysis | IEC 60812:2018 | ✅ Done — Step 4.0 FMEA procedure (IEC 60812:2018 §6 ordered steps) added to `hazard-analysis.md` |
| **3.6** Add unit-test V&V gate | Unit Test | IEEE 1012:2016 | ✅ Done — Step 8 "IEEE 1012 V&V Coverage Gate (§5.7)" added to `unit-test.md` |
| **3.7** Add integration-test V&V gate | Integration Test | IEEE 1012:2016 | ✅ Done — Step 7 "IEEE 1012 V&V Coverage Gate (§5.6)" added to `integration-test.md` |
| **3.8** Add test result documentation standard | Test Results | ISO/IEC 29119-3:2013 | ✅ Done — Test Status/Completion Report fields referenced in `test-results.md` |

---

## 4. Vision — Achieved Outcomes (v0.6.0)

All three phases are complete. The spec-kit V-Model extension has achieved the
following outcomes:

### Every V-Cycle Layer Has a Governing Standard

Every layer now has at least one best-practice standard, with safety extensions
layered on top. The three previously unstandarded layers (Acceptance Test, Audit
Report, Impact Analysis) are now fully covered.

### Quality Attributes Are First-Class Citizens

ISO/IEC 25010:2023 is woven through four layers (Requirements, Acceptance,
System Design, Architecture), ensuring that non-functional quality is treated
with the same rigor as functional correctness. Every requirement specification
systematically considers performance, security, reliability, interaction
capability, flexibility, maintainability, compatibility, functional suitability,
and safety.

### Describe→Evaluate Loop for Architecture

With ISO 42030 complementing IEEE 42010, architecture descriptions are not only
well-structured but also formally evaluated against stakeholder concerns and
quality scenarios before downstream design work begins.

### V&V as an Overarching Framework

IEEE 1012 provides a V&V umbrella across acceptance testing, system testing,
integration testing, unit testing, and traceability — ensuring that the
distinction between verification and validation is maintained and that coverage
analysis goes beyond simple test linkage.

### Formal Review & Audit Processes

IEEE 1028 and ISO/IEC 20246 formalize the peer-review and audit processes
with recognized roles, procedures, and metrics — making the AI-assisted review
outputs auditable and defensible.

### Best-Practice First, Safety Second

The extension cleanly separates general best-practice standards (applicable to
all projects) from safety-specific extensions (activated per domain). This means:

- A startup building a web application benefits from IEEE 29148, IEEE 1016, ISO
  29119, ISO 25010, and IEEE 1012 without any safety overhead.
- An automotive OEM activates ISO 26262 extensions to add ASIL decomposition,
  structural coverage, and freedom-from-interference constraints.
- An avionics supplier activates DO-178C extensions to add DAL-driven
  verification, MC/DC coverage, and single-entry/exit enforcement.

The best-practice layer and the safety layer are independently valuable and
incrementally composable.

---

## 5. Summary (v0.6.0 — Standards Enrichment Complete)

The spec-kit V-Model extension is built on a comprehensive foundation of
**19 best-practice standards** and **7 safety-specific standards** — 26 total.
v0.6.0 integrated **11 new best-practice standards** that filled all
remaining gaps, deepened rigor across every layer, and extended coverage to
previously unstandarded commands.

The key insight is structural: the extension cleanly separates best-practice
concerns from safety extensions. The v0.6.0 enhancements preserved and
strengthened this architecture — adding cross-cutting quality attributes
(ISO 25010), filling the acceptance-test gap (IEEE 1012), completing the
architecture describe→evaluate cycle (ISO 42030), and formalizing review and
audit processes (IEEE 1028, ISO 20246, ISO 19011).

### Summary: All 11 New Standards — Implemented ✅

| # | Standard | Scope | Layers Improved | Status |
|---|---------|-------|-----------------|--------|
| 1 | **ISO/IEC 25010:2023** | Product Quality Model (9 characteristics) | Requirements, Acceptance, System Design, Architecture | ✅ |
| 2 | **IEEE 1012:2016** | Verification & Validation | Acceptance, System Test, Integration Test, Unit Test, Traceability | ✅ |
| 3 | **ISO/IEC 42030:2019** | Architecture Evaluation | Architecture Design | ✅ |
| 4 | **IEC 60812:2018** | FMEA Procedure | Hazard Analysis | ✅ |
| 5 | **IEEE 1028:2008** | Software Reviews & Audits | Peer Review, Audit Report | ✅ |
| 6 | **ISO/IEC 20246:2017** | Work Product Reviews | Peer Review | ✅ |
| 7 | **ISO/IEC/IEEE 12207:2017** | Software Lifecycle Processes | Module Design | ✅ |
| 8 | **IEEE 828-2012** | Configuration Management | Audit Report, Impact Analysis | ✅ |
| 9 | **ISO 19011:2018** | Auditing Management Systems | Audit Report | ✅ |
| 10 | **ISO/IEC/IEEE 15289:2019** | Lifecycle Information Items | Traceability, Audit Report | ✅ |
| 11 | **ISO/IEC 29119-3:2013** | Software Testing — Test Documentation | Test Results | ✅ |
