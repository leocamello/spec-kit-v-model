---
title: Roadmap
description: What's available now in the V-Model Extension Pack, what's been shipped, and what's planned next — from regulatory accelerators to IDE integration.
---

# Roadmap

The V-Model Extension Pack is actively developed. Here's where we are, where we've been, and where we're going.

## Current Release: v0.6.0

The extension provides **14 commands** covering four V-Model levels plus cross-cutting safety and quality concerns:

### V-Model Levels

| Level | Design Command | Test Command | Traceability |
|-------|---------------|-------------|--------------|
| **Requirements ↔ Acceptance** | `requirements` | `acceptance` | Matrix A |
| **System Design ↔ System Test** | `system-design` | `system-test` | Matrix B |
| **Architecture ↔ Integration Test** | `architecture-design` | `integration-test` | Matrix C |
| **Module Design ↔ Unit Test** | `module-design` | `unit-test` | Matrix D |

### Cross-Cutting Commands

| Command | Purpose |
|---------|---------|
| `trace` | Bidirectional traceability matrix (A + B + C + D + H) |
| `hazard-analysis` | ISO 14971/26262 FMEA with `HAZ-NNN` IDs and Matrix H |
| `impact-analysis` | Dependency graph traversal for change impact assessment |
| `peer-review` | AI-powered stateless linter with `PRF-{ARTIFACT}-NNN` findings |
| `test-results` | JUnit XML + Cobertura XML ingestor for matrix status updates |
| `audit-report` | Deterministic release audit report with compliance gating |

!!! success "Test coverage"

    - 364 BATS tests (Bash) · 347 Pester tests (PowerShell)
    - 89 structural evaluations · 42 LLM evaluations
    - Agent definitions for all 14 commands

## Shipped Milestones

| Version | Date | Highlights |
|---------|------|------------|
| **v0.1.0** | 2026-02-19 | Extension scaffold, `requirements`, `acceptance`, `trace` commands, three-tier ID schema, helper scripts (Bash + PowerShell) |
| **v0.2.0** | 2026-02-20 | `system-design`, `system-test` commands, dual-matrix traceability (A + B), golden examples for medical device and automotive ADAS, E2E evaluation harness |
| **v0.3.0** | 2026-02-21 | `architecture-design`, `integration-test` commands, triple-matrix (A + B + C), CROSS-CUTTING module tag, consolidated fixture pattern |
| **v0.4.0** | 2026-02-22 | `module-design`, `unit-test` commands, four-tier ID schema, quadruple-matrix (A + B + C + D), id-schema-guide documentation |
| **v0.5.0** | 2026-04-06 | `hazard-analysis`, `impact-analysis`, `peer-review`, `test-results`, `audit-report` commands, Matrix H, 14 agent definitions, 4× test growth |
| **v0.6.0** | 2026-04-23 | Domain Overlay Architecture (36 overlay files), ID Lifecycle Model (deprecation + suspect cascade), Standards Enrichment (26 standards, Governing Standards sections in all 11 commands), features 002–006 evolved |

For detailed release notes, see the [Changelog](changelog.md).

## What's Next

### Implementation Gating (M1 — Bridge Commands)

The next milestone delivers three commands that read all V-Model artifacts and gate implementation behind verified specifications — preventing code from being written against incomplete or unverified artifact chains:

- **`v-model.plan`** — Reads all V-Model artifacts and produces a structured implementation plan, ordering work by dependency and traceability
- **`v-model.tasks`** — Breaks the implementation plan into concrete, traceable task items, each linked to specific requirements and design artifacts
- **`v-model.implement`** — Reads the full artifact chain and scaffolds implementation, gating code generation behind verified coverage

Together these commands close the loop: specifications flow down the V-Model, then bridge commands ensure implementation is grounded in verified, traceable artifacts. Code cannot proceed until coverage checks pass.

### Pre-built Regulatory Template Packs

Domain-specific templates for **IEC 62304**, **ISO 26262**, and **DO-178C** that pre-populate required sections, terminology, and compliance language. Instead of starting from generic templates, teams get standard-specific boilerplate with the correct ASIL/SIL/Class verbiage pre-filled.

### Bidirectional ALM Synchronization

Two-way sync with enterprise ALM platforms (**Jama Connect**, **IBM DOORS**, **Siemens Polarion**), eliminating the risk of fragmented sources of truth between Git-based artifacts and the enterprise system of record.

### Trend Tracking

Monitor requirement quality scores, coverage percentages, and traceability completeness over time to catch degradation before it becomes an audit finding.

### Future Considerations

!!! note "Under exploration"

    These items are informed by the architecture and community feedback but are not yet committed to the roadmap:

    - **IDE Integration** — Editor extensions for VS Code and JetBrains that surface traceability data, coverage status, and peer review findings directly in the development environment
    - **Additional Domain Standards** — Support for standards beyond IEC 62304, ISO 26262, and DO-178C — such as IEC 61508 (industrial), EN 50128 (railway), and ECSS (space)
    - **Visual Dashboard** — A web-based dashboard for visualizing traceability matrices, coverage trends, impact analysis graphs, and audit readiness status
    - **Report Customization** — Assessor-specific formatting and full customization of the audit report output for different regulatory bodies

## Influence the Roadmap

Your input shapes what we build next:

- **Feature requests** — [Open an issue](https://github.com/leocamello/spec-kit-v-model/issues/new?template=feature_request.md) describing your use case and how it fits the V-Model workflow
- **Discussions** — Join the conversation in [GitHub Discussions](https://github.com/leocamello/spec-kit-v-model/discussions) to share ideas, vote on proposals, and connect with other users
- **Contributions** — See the [Contributing Guide](contributing.md) to get started with code, tests, or documentation

---

!!! quote "The philosophy"

    *The AI drafts. The human decides. The scripts verify. Git remembers.*
