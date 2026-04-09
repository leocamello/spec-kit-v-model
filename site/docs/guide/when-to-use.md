---
title: When (and When Not) to Use the V-Model
description: Decision guide for when the V-Model adds value, when alternatives are better, and how hybrid approaches work.
---

# When (and When Not) to Use the V-Model

The V-Model is a powerful methodology — but it's not the right fit for every project. This guide helps you decide when to use it, when to skip it, and how to combine it with other approaches.

---

## Ideal When

The V-Model excels in these situations:

!!! success "Use the V-Model when..."

    **Requirements are well-defined** and unlikely to change significantly
    :   The V-Model works best when you know *what* you're building before you start. When requirements do change, the [`/speckit.v-model.impact-analysis`](impact-analysis.md) command identifies all suspect artifacts automatically.

    **Regulatory compliance is required**
    :   Medical devices (IEC 62304, ISO 14971), automotive (ISO 26262), aerospace (DO-178C), and industrial systems (IEC 61508) all require traceable verification evidence. The V-Model generates this evidence as a natural byproduct of development.

    **Safety is critical**
    :   When software failures could harm people or property, the V-Model's paired generation ensures every safety requirement has a verified test — no gaps, no assumptions.

    **Audit trails are mandatory**
    :   If you need to prove to an auditor that every requirement was tested, the V-Model's deterministic traceability matrix provides this proof automatically. See [Audit Report](audit-report.md).

    **The technology stack is known**
    :   No major technical exploration needed — you're building with known tools and patterns. The V-Model shines when the *what* and *how* are clear.

---

## Consider Alternatives When

!!! warning "The V-Model may not be the best fit when..."

    **The project is highly exploratory**
    :   If you're prototyping, exploring a new domain, or don't yet know what the final product looks like, the V-Model's upfront specification work may be premature. Consider spiking first, then applying the V-Model once requirements stabilize.

    **You're rapidly iterating on UX**
    :   User-facing interfaces often require fast design-test-learn cycles. The V-Model's formal verification process can slow down UX experimentation. Use lightweight usability testing instead, and reserve the V-Model for the underlying business logic.

    **There are no compliance requirements**
    :   If no regulatory body will audit your work and safety isn't a concern, the V-Model's overhead may not be justified. Standard test-driven development (TDD) or behavior-driven development (BDD) may be sufficient.

    **Requirements are highly volatile**
    :   If requirements change daily, maintaining the full V-Model chain becomes expensive. However, even in volatile environments, the [impact analysis](impact-analysis.md) command helps manage change — so this isn't an absolute disqualifier.

---

## Hybrid Approaches

You don't have to choose all-or-nothing. Many teams use a **hybrid approach**:

### V-Model for Safety-Critical Subsystems

Apply the full V-Model (all 4 levels + hazard analysis) to safety-critical components:

- Medical device firmware
- Automotive ADAS algorithms
- Industrial control logic
- Flight control software

### Agile/TDD for the Rest

Use standard agile practices for non-critical components:

- Admin dashboards
- Reporting modules
- Configuration UIs
- Development tooling

### Where They Meet

The V-Model and agile practices connect at the **interface boundary**:

```
┌─────────────────────────────────┐
│   Safety-Critical Subsystem     │
│   (Full V-Model: REQ→MOD+HAZ)  │
│                                 │
│   ┌───────────┐  ┌───────────┐ │
│   │ REQ-001   │  │ HAZ-001   │ │
│   │ SYS-001   │  │ HAZ-002   │ │
│   │ ARCH-001  │  │           │ │
│   │ MOD-001   │  │           │ │
│   └─────┬─────┘  └───────────┘ │
└─────────┼───────────────────────┘
          │ Interface contracts
┌─────────┼───────────────────────┐
│   Non-Critical Components       │
│   (Agile/TDD)                   │
│                                 │
│   ┌───────────┐  ┌───────────┐ │
│   │ Dashboard  │  │ Reports   │ │
│   │ (React)    │  │ (Python)  │ │
│   └───────────┘  └───────────┘ │
└─────────────────────────────────┘
```

The interface contracts between subsystems can be documented as `REQ-IF-NNN` requirements in the V-Model, ensuring the boundary is traceable even when the non-critical side uses agile practices.

---

## Decision Matrix

| Factor | Full V-Model | Level 1 Only | Agile/TDD |
|---|---|---|---|
| Regulatory compliance required | ✅ | ⚠️ May suffice | ❌ |
| Safety-critical system | ✅ | ❌ | ❌ |
| Stable requirements | ✅ | ✅ | ✅ |
| Volatile requirements | ⚠️ Use impact analysis | ✅ | ✅ |
| Audit trail needed | ✅ | ✅ | ❌ |
| Rapid prototyping | ❌ | ❌ | ✅ |
| UX-heavy iteration | ❌ | ❌ | ✅ |
| Known technology stack | ✅ | ✅ | ✅ |

!!! tip "Start with Level 1"

    If you're unsure, start with [Level 1: Requirements ↔ Acceptance Testing](requirements-acceptance.md) alone. It provides traceable requirements and acceptance tests with minimal overhead. You can always go deeper into Levels 2–4 later if the project warrants it.

---

## Related Pages

- [V-Model Concepts](concepts.md) — Understanding the full V-Model
- [Level 1: Requirements ↔ Acceptance](requirements-acceptance.md) — The minimum viable V-Model
- [Impact Analysis](impact-analysis.md) — Managing requirement changes
- [CI Integration](ci-integration.md) — Automating validation regardless of methodology
