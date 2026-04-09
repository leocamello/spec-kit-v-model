---
date: 2025-04-09
authors:
  - leocamello
categories:
  - Spec-Driven Development
  - Regulated Industries
description: "Part 1 of 5 — The compliance chasm between AI-native teams and regulated teams is real. Spec-driven development bridges it."
---

# Spec-Driven Development in Regulated Industries: Why Specifications Are Your Most Valuable Asset

Picture two engineering teams. The first — an AI-native startup — ships features in hours. Engineers prompt an LLM, review the output, push to main, and deploy. Their velocity is extraordinary. Their traceability is nonexistent. The second team builds firmware for a Class C medical device. Every requirement lives in a 300-page Word document. Every test case is manually linked to a requirement ID in a spreadsheet. They have full traceability. They also take six weeks to ship a single feature. Both teams are losing.

<!-- more -->

This is the opening article in a five-part series on **Spec-Driven Development in Regulated Industries** — a methodology that makes rigor and velocity coexist. If you build software that must meet IEC 62304, ISO 26262, DO-178C, or any standard that demands traceability between what you intended to build and what you actually tested, this series is for you.

---

## The Compliance Chasm

The gap between these two worlds is not a minor inconvenience — it is a structural problem in how the software industry has evolved. AI-native teams optimized for speed. Regulated teams optimized for evidence. Neither optimized for both.

| | AI-Native Teams | Regulated Teams |
|---|---|---|
| **Speed** | Hours per feature | Weeks per feature |
| **Traceability** | None | Manual, error-prone |
| **Audit readiness** | Not applicable | Months of prep |
| **Requirement coverage** | Unknown | Manually verified |
| **Cost of change** | Low (code only) | Extreme (documentation) |

The fast team ships without proof of correctness. A single missed edge case in an infusion pump's dosage algorithm could kill a patient — but there is no artifact linking the requirement to a test that verifies it. The compliant team has that artifact, but it took three people two weeks to build the traceability matrix, and it was outdated by the time they finished because a requirement changed mid-sprint.

This is the **compliance chasm**: the structural gap between teams that move fast with AI and teams that move carefully under regulation. And it is widening. Every new LLM capability makes AI-native teams faster. Every new regulatory update makes compliant teams slower. The teams that survive will be the ones that figure out how to be both.

---

## What Is Spec-Driven Development?

Spec-driven development is a methodology built on a single premise: **specifications are first-class artifacts, not afterthoughts**.

In most software projects, specifications are informal. A user story in Jira. A paragraph in a design doc. A conversation on Slack. The specification exists — someone had an intent — but it is scattered, implicit, and disconnected from the code that implements it.

Spec-driven development changes this. Every feature starts with a structured specification. That specification produces formal requirements — each with a persistent identifier like `REQ-001`. Every requirement has a paired test case — `ATP-001-A`, `ATP-001-B` — with concrete BDD scenarios that define what "done" means. The traceability between requirements and tests is not maintained in a spreadsheet or an ALM platform. It is computed deterministically from the artifacts themselves and stored in Git alongside the code.

The three pillars:

1. **Specifications as source of truth.** The spec drives everything downstream — requirements, tests, design documents, hazard analysis. Change the spec, regenerate the downstream artifacts, review the delta.
2. **Paired artifacts.** Every design artifact has a simultaneously generated testing artifact. Requirements pair with acceptance tests. System design pairs with system tests. Architecture pairs with integration tests. Module design pairs with unit tests. No orphans. No gaps.
3. **Embedded traceability.** Traceability is not bolted on after the fact. It is a structural property of the artifact set — IDs link forward from requirements to tests and backward from tests to requirements. A deterministic script verifies completeness at any time.

This is not a new idea. It is the V-Model — the most widely adopted framework in regulated industries — implemented as a developer workflow instead of a document management exercise.

---

## The V-Model: A Framework Older Than Software

The V-Model predates agile. It predates most software methodologies entirely. Its origins trace back to systems engineering in the 1960s and 1970s, where the principle was simple: for every level of decomposition on the left side of the "V" (requirements → system design → architecture → module design → implementation), there must be a corresponding level of verification on the right side (unit tests → integration tests → system tests → acceptance tests).

```
Requirements  ←————————————→  Acceptance Testing
  System Design  ←——————————→  System Testing
    Architecture  ←————————→  Integration Testing
      Module Design  ←————→  Unit Testing
        Implementation
```

The V-Model became the standard in regulated industries for good reason. When the consequences of failure are measured in human lives — a ventilator that miscalculates tidal volume, a braking system that fails to engage, an autopilot that misinterprets altitude — you need mathematical proof that every requirement was tested and every test traces to a requirement.

IEC 62304 (medical devices), ISO 26262 (automotive), and DO-178C (aerospace) all encode some form of this discipline. The standard varies, but the core question is the same: **can you prove that what you built is what you specified?**

The problem was never the V-Model's logic. The problem was its implementation. The V-Model was designed for an era of manual processes — when a systems engineer would spend days writing a requirements document, weeks writing a test plan, and more weeks building a traceability matrix by hand. In that context, the V-Model's overhead was the price of safety. In a world where AI can generate structured content and deterministic scripts can verify it, that price no longer needs to be so high.

---

## AI Changes the Game

When a large language model can read a natural-language specification and produce structured requirements — each with a persistent identifier, a priority, a rationale, and a verification method — the bottleneck shifts from *writing* to *reviewing*.

When a deterministic script can parse every `REQ-NNN` identifier in a requirements document and every `ATP-NNN-X` identifier in a test plan and compute, with mathematical certainty, whether coverage is 100% — the traceability matrix goes from a week-long manual exercise to a sub-second computation.

When an LLM-as-judge can evaluate whether each requirement is unambiguous, testable, atomic, and complete — and produce structured findings with `PRF-REQ-NNN` identifiers — peer review becomes continuous, not ceremonial.

When every artifact is stored in Git as plaintext Markdown — diffable, branchable, and backed by cryptographic commit hashes — the audit trail is built into the development workflow, not maintained in a separate system.

The V-Model goes from "weeks of overhead" to "minutes of generation + human review." The artifacts are the same. The rigor is the same. The time is fundamentally different.

---

## The Core Principle

> **The AI drafts. The human decides. The scripts verify. Git remembers.**

This is not a slogan. It is a strict separation of concerns — and the reason the approach is trustworthy enough for regulated industries.

| Responsibility | Handled By | Why |
|---|---|---|
| **Creative translation** — turning specifications into structured requirements and test scenarios | AI (LLM) + Human review | Requires domain context and natural language interpretation. The human verifies fidelity. |
| **Coverage calculation** — determining whether every requirement has a test case | Deterministic scripts | Must be mathematically correct. AI hallucinations are unacceptable for compliance metrics. |
| **Quality evaluation** — assessing whether requirements are well-written and scenarios are comprehensive | LLM-as-judge | Qualitative assessment where human-like judgment adds value; clearly labeled as advisory. |
| **Audit trail** — proving who changed what and when | Git (cryptographic hashes) | Immutable, mathematically verifiable history. No separate ALM database required. |

A compliance tool that uses AI for *everything* cannot be trusted for compliance. If the AI generates the traceability matrix and also evaluates whether it is correct, you have a system grading its own homework. The separation is non-negotiable: AI does what AI is good at (understanding context and generating structured content), scripts do what scripts are good at (producing the same correct answer every time), and humans do what humans do best (deciding whether the generated content is actually right).

---

## What This Series Covers

This is the first of five articles. Here is where we are going:

**Part 2 — [From Requirement to Release: IEC 62304 Compliance at AI Speed](iec-62304-compliance-ai-speed.md)**
A Class C medical device. IEC 62304 mandates 15+ deliverables. We walk through generating every artifact — requirements, acceptance tests, architecture, hazard analysis, traceability matrices, and an audit report — for a blood glucose monitoring system. Same rigor as the manual approach. A fraction of the time.

**Part 3 — Automotive Functional Safety with ISO 26262**
ASIL-D is the most demanding automotive safety integrity level. We show how spec-driven development produces the evidence package — from safety goals through hardware-software interface requirements to unit test traceability — that a functional safety assessor expects.

**Part 4 — Aerospace DO-178C Compliance**
DO-178C at DAL A requires bidirectional traceability with 100% structural coverage. We demonstrate how the V-Model Extension Pack generates objectives evidence for the certification liaison process — without the ALM platform overhead.

**Part 5 — Building a Culture of Specification**
The hardest part is not the tooling — it is the mindset. We discuss how spec-driven development changes team dynamics, why engineering leads resist it, why QA managers embrace it, and how to introduce it incrementally without disrupting existing workflows.

---

## Getting Started

The [V-Model Extension Pack for Spec Kit](../../index.md) is available now. If the compliance chasm resonates with your team — if you have felt the tension between shipping fast and shipping with evidence — start here:

- **[Getting Started Guide](../../getting-started/index.md)** — Install the extension and generate your first traceable specification in minutes.
- **[Concepts Guide](../../guide/concepts.md)** — Understand the architecture, the separation of concerns, and the ID schema.
- **[About & Philosophy](../../about.md)** — The design decisions behind the tool and why they matter for trust.

The AI drafts. The human decides. The scripts verify. Git remembers. That is the methodology. The rest of this series shows you what it looks like in practice.
