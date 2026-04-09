---
date: 2025-04-30
authors:
  - leocamello
categories:
  - Regulated Industries
  - Compliance
  - V-Model
description: "Part 4 of 5 — In aerospace, certification demands proof that cannot be probabilistic. How deterministic scripts deliver what AI alone cannot for DO-178C DAL-A."
---

# DO-178C Traceability: Deterministic Verification in a Probabilistic Age

A flight management system. DAL-A — catastrophic failure condition. Every high-level requirement must trace to a test. Every test must trace back to a requirement. Every condition in every decision must be shown to independently affect the outcome. The FAA doesn't accept "probably correct." They accept "provably correct." And this is where the separation between what AI generates and what scripts verify stops being an architectural preference and becomes a certification necessity.

<!-- more -->

This is Part 4 of our five-part series, *Spec-Driven Development in Regulated Industries*. In [Part 3](iso-26262-asil-d-without-overhead.md), we covered ISO 26262 ASIL-D for automotive functional safety. Today we enter the domain where the trust model is most explicit and the consequences of getting it wrong are measured in lives aboard an aircraft.

---

## DO-178C in 60 Seconds

DO-178C (*Software Considerations in Airborne Systems and Equipment Certification*) is the standard that civil aviation authorities — FAA, EASA, and others — use to certify software in airborne systems. It assigns a **Design Assurance Level (DAL)** based on the severity of the failure condition the software could contribute to:

| DAL | Failure Condition | Example |
|---|---|---|
| **A** | Catastrophic — may cause loss of the aircraft | Flight control, autopilot, engine control (FADEC) |
| **B** | Hazardous — large reduction in safety margins | Navigation, TCAS |
| **C** | Major — significant reduction in safety margins | Fuel management, mode annunciation |
| **D** | Minor — slight reduction in safety margins | Cabin lighting control |
| **E** | No Effect | In-flight entertainment (non-safety) |

DAL is not self-assigned. It flows down from the aircraft-level Functional Hazard Assessment and System Safety Assessment per ARP 4754A/4761. The software team receives their DAL; they don't choose it.

DO-178C defines objectives across planning, development, verification, configuration management, and quality assurance — with higher DALs requiring more objectives and more of them satisfied with **independence** (verified by someone or something other than the developer). For the full objectives table and deliverables matrix, see the [DO-178C Compliance](../../compliance/do-178c.md) page.

---

## The Trust Problem with AI in Certification

This is the central philosophical question of this article, and arguably the central question for any AI tool used in a certification context: **can a probabilistic system produce evidence that a deterministic process demands?**

Large language models are, by their nature, probabilistic. Given the same prompt twice, they may produce different outputs. The outputs are usually similar — often functionally equivalent — but they are not guaranteed to be identical. The temperature parameter, the random seed, the model version, even the order of tokens in the context window can produce variation.

Certification authorities understand this implicitly. When a Designated Engineering Representative reviews a traceability matrix for a DAL-A flight management system, they are asking a specific question: *is this matrix correct?* Not "is it probably correct" or "is it correct most of the time." Correct. Verifiably. Reproducibly.

If an AI generates your traceability matrix — scanning requirements and tests, determining coverage, computing percentages — can you certify it? The honest answer is no. Not because the AI would necessarily get it wrong, but because you cannot *prove* it will get it right every time. You cannot inspect its reasoning. You cannot write a unit test for its coverage calculation. You cannot guarantee that running it again tomorrow, with the same inputs, produces the same output.

But here is the key insight: you don't have to choose between AI speed and script trustworthiness. You can have both — if you separate their responsibilities correctly.

---

## The Separation of Concerns in Practice

The V-Model Extension Pack is built on a strict architectural principle: **AI generates, scripts verify, humans decide, Git remembers.** In the DO-178C context, this separation maps directly to the certification trust model.

### AI Generates

The LLM handles what it does best: creative translation. It reads a natural-language specification and produces structured requirements (`REQ-NNN`), architecture descriptions (`ARCH-NNN`), module designs with pseudocode and state machines (`MOD-NNN`), and test procedures at every level. This is the step that compresses months into hours — the AI drafts exhaustive, structurally complete artifacts at machine speed.

But the AI's output is a *draft*. It has no authority until a human reviews it and a script verifies its structural properties.

### Scripts Verify

Every compliance-critical calculation is performed by deterministic scripts — Bash and PowerShell, regex-based, fully inspectable. Coverage percentages, traceability matrices, gap detection, impact analysis — all computed by code that can be read line by line, tested (364 BATS tests + 347 Pester tests), and shown to produce the same output from the same input every time.

This is not a minor architectural detail. It is the reason the tool's evidence can be presented to a DER with a straight face. The traceability matrix wasn't "generated by AI." It was *computed by a script* that parsed the artifacts. The script's correctness can be verified. Its behavior is deterministic. It is, in the language of DO-178C, *qualifiable*.

### Humans Review

No artifact enters the verified baseline without human review. The AI acts as an exoskeleton for the systems engineer — it drafts at machine speed, but the engineer decides whether the draft is correct. A hallucinated threshold (250 ms instead of 150 ms) would propagate structurally perfect but functionally dangerous artifacts downstream. The human catches what the AI cannot guarantee.

In DO-178C terms, this is the **review gate** that satisfies the independence requirement. The AI generated the artifact. The human (independent of the AI) reviews it. The script (independent of both) verifies its structural properties. Three independent checks, each doing what it does best.

### Git Remembers

Every artifact is plaintext Markdown stored in Git. Every change is versioned with a cryptographic commit hash. The audit trail — who changed what, when, and why — is immutable and mathematically verifiable. No ALM database required. `git log` is the configuration management record that DO-178C Section 7 demands.

---

## Structural Coverage: The DAL-A Requirement

DAL-A software requires the most demanding structural coverage metric in either automotive or aerospace: **Modified Condition/Decision Coverage (MC/DC)**. MC/DC requires that:

1. Every **decision** in the program has taken all possible outcomes
2. Every **condition** in a decision has taken all possible outcomes
3. Each condition has been shown to **independently affect** the decision's outcome

| DAL | Statement Coverage | Decision Coverage | MC/DC Coverage |
|---|---|---|---|
| A | Required | Required | Required |
| B | Required | Required | — |
| C | Required | — | — |
| D | — | — | — |

The V-Model Extension does not compute MC/DC itself — that is the job of the coverage tool integrated with your compiler and test harness (gcov, LDRA, VectorCAST, etc.). What the extension does is *integrate* coverage results into the traceability evidence package.

The `/speckit.v-model.test-results` command ingests Cobertura XML coverage data (the de facto interchange format) and maps it to the traceability matrix. The result is a unified view: requirement → test procedure → test result → coverage metric. The DER reviewer sees a single chain from high-level requirement to MC/DC percentage, with every link verified by a deterministic script.

For DAL-A systems, the `unit-test` command generates test procedures that explicitly target MC/DC coverage — identifying all conditions in complex decisions, generating test cases that isolate each condition's effect, and documenting the coverage rationale per `UTP-NNN-X` procedure. The test *procedures* are AI-generated (and human-reviewed). The coverage *analysis* is script-computed.

---

## From Artifacts to Certification

A DAL-A certification involves review by a **Designated Engineering Representative (DER)** — an FAA-authorized engineer who evaluates the software against DO-178C objectives. The DER doesn't care about your development tools. They care about the evidence.

Here is what the V-Model Extension's evidence package provides, mapped to what DER reviewers look for:

| DER Review Focus | DO-178C Section | V-Model Evidence |
|---|---|---|
| Are high-level requirements complete and correct? | 6.3.1 | `requirements.md` — `REQ-NNN` items validated against 8 IEEE 29148 quality criteria |
| Is every requirement traceable to a test? | 6.3.4 | Matrix A — deterministic forward/backward trace, exact coverage % |
| Is every test traceable to a requirement? | 6.3.4 | Matrix A (reverse direction) — orphaned tests flagged as gaps |
| Is low-level design consistent with architecture? | 6.3.2, 6.3.3 | `architecture-design.md` → `module-design.md` — `ARCH-NNN` → `MOD-NNN` trace via Matrix C/D |
| Is structural coverage achieved? | 6.4.4 | Coverage Audit section — Cobertura XML ingested, mapped to `UTP-NNN-X` |
| Is the configuration managed? | 7 | Git commit SHAs per artifact in the audit report |
| Has change impact been assessed? | 7 | `impact-analysis --full` report showing blast radius for any changed ID |

The trace command generates all five matrices (A through D plus H) with exact coverage percentages. The audit report packages these with an artifact inventory, Git SHAs, and a compliance summary. The entire package is regenerable from the `specs/` directory — run the commands again and you get the same evidence, because the scripts are deterministic.

---

## DO-330 and Tool Qualification

DO-178C's companion document, DO-330, addresses **tool qualification** — the process of demonstrating that a development or verification tool can be trusted to perform its function correctly. If a tool's output is used as evidence for certification, the tool itself may need to be qualified.

This is where the V-Model Extension's architecture pays a second dividend. Because all compliance-critical calculations are performed by deterministic scripts — not by the AI — the tool qualification argument is significantly simpler:

- **Scripts are testable.** The 364 BATS tests and 347 Pester tests verify every coverage calculation, matrix generation, gap detection, and impact analysis function. These tests themselves serve as tool qualification evidence.
- **Scripts are inspectable.** They are open-source Bash and PowerShell. A DER or qualification reviewer can read the code line by line, understand what it does, and verify that it does it correctly.
- **Scripts are reproducible.** Same inputs, same outputs, every time. This is the fundamental property that DO-330 requires: the tool's behavior is predictable.

Under DO-330, tools are classified by Tool Qualification Level (TQL-1 through TQL-5), based on how the tool's output is used and whether errors would be detected by other activities. Because the V-Model Extension's scripts serve as **verification tools** — their output is used to verify the correctness of the development artifacts — they fall under Criteria 2 or 3, depending on the specific use case. The deterministic, testable nature of the scripts simplifies qualification at any TQL level.

The AI component (the LLM that generates artifacts) does not require tool qualification in the DO-330 sense, because its output is never used directly as certification evidence. Every AI-generated artifact passes through the human review gate before entering the baseline, and the compliance-critical properties (coverage, traceability) are verified by the qualified scripts.

---

## Next in the Series

In **Part 5**, we step back from specific standards and ask the broader question: *what happens to a team that adopts spec-driven development?* Beyond compliance efficiency, there's a cultural shift — from "writing documentation because we have to" to "maintaining specifications because they make us better." We'll explore how the practice changes team dynamics, code review, and the relationship between engineering and quality assurance.

---

## Get Started

- **Compliance**: [DO-178C Compliance](../../compliance/do-178c.md) — Full artifact mapping, DAL objectives table, MC/DC coverage analysis, and DAL-A workflow
- **About**: [Vision & Philosophy](../../about.md) — The separation of concerns: scripts verify, AI generates, humans decide, Git remembers
- **Getting Started**: [Installation & First Run](../../getting-started/index.md) — Set up the V-Model Extension Pack in under five minutes
