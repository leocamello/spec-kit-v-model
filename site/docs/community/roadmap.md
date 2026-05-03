---
title: Roadmap
description: What's available now in the V-Model Extension Pack, what's been shipped, and what's planned next — from regulatory accelerators to IDE integration.
---

# Roadmap

The V-Model Extension Pack is actively developed. Here's where we are, where we've been, and where we're going.

## Current Release: v0.7.0

The extension provides **17 commands** covering four V-Model levels plus cross-cutting safety/quality concerns and the bridge to deterministic, gated implementation:

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

### Bridge to Implementation (v0.7.0)

| Command | Purpose |
|---------|---------|
| `plan` | V-Model-enriched `plan.md` synthesis with pinned-schema validation |
| `tasks` | TDD-ordered `tasks.md` with hazard-driven priority elevation and per-task `Implements`-directive headers |
| `implement` | 12-step gated pipeline: 8-stage `run-v-model-gate.sh` → codegen → 4-level test gen → splice → hallucination guard → trace post-hook |

!!! success "Test coverage"

    - 455 BATS tests (Bash) · 431 Pester tests (PowerShell)
    - 89 structural evaluations · 53 LLM evaluations · 32 E2E tests (advisory in v0.7.0)
    - Agent definitions for all 17 commands

## Shipped Milestones

| Version | Date | Highlights |
|---------|------|------------|
| **v0.1.0** | 2026-02-19 | Extension scaffold, `requirements`, `acceptance`, `trace` commands, three-tier ID schema, helper scripts (Bash + PowerShell) |
| **v0.2.0** | 2026-02-20 | `system-design`, `system-test` commands, dual-matrix traceability (A + B), golden examples for medical device and automotive ADAS, E2E evaluation harness |
| **v0.3.0** | 2026-02-21 | `architecture-design`, `integration-test` commands, triple-matrix (A + B + C), CROSS-CUTTING module tag, consolidated fixture pattern |
| **v0.4.0** | 2026-02-22 | `module-design`, `unit-test` commands, four-tier ID schema, quadruple-matrix (A + B + C + D), id-schema-guide documentation |
| **v0.5.0** | 2026-04-06 | `hazard-analysis`, `impact-analysis`, `peer-review`, `test-results`, `audit-report` commands, Matrix H, 14 agent definitions, 4× test growth |
| **v0.6.0** | 2026-04-23 | Domain Overlay Architecture (36 overlay files), ID Lifecycle Model (deprecation + suspect cascade), Standards Enrichment (26 standards, Governing Standards sections in all 11 commands), features 002–006 evolved |
| **v0.7.0** | 2026-05-03 | Bridge commands (`plan`, `tasks`, `implement`), 8-stage `run-v-model-gate.sh` pipeline, `validate-artifact-status` (MF-6) and `validate-domain-profile` (MF-7) validators, splicer hardening (MF-5: id-match, duplicate detection, `--region-from`, `diff -u` audit trail), hallucination guard `--canonical/--scan/--changed-only`, Compliance & Hybrid Modes documentation, 4 lifecycle hooks |

For detailed release notes, see the [Changelog](changelog.md).

## What's Next

### v0.8.0 Stabilization Backlog

The pre-v0.8.0 architectural audit identified ten Epics that did not fit the v0.7.x patch envelope. They are tracked in `.tmp/pre-v0.8.0-audit/ultimate-stabilization-blueprint.md` and summarised in [the v0.7.0 release notes](https://github.com/leocamello/spec-kit-v-model/blob/main/docs/releases/v0.7.0.md):

- **EPIC-1** — `compliance_mode: strict` profile (flips hook `optional: true` → `false`; makes hybrid mode mechanically detectable in CI).
- **EPIC-2** — Sealed baseline + signed run attestation (append-only ledger, `.specify/v-model/baseline.lock`, `validate-task-provenance.sh`).
- **EPIC-3** — Immutable compliance-artifact protection (snapshot diff in `before_implement` / `after_implement`).
- **EPIC-4** — Semantic directive validation (path/symbol/reachability checks layered onto the existence-only check shipped in v0.7.0).
- **EPIC-5** — Single `v-model verify` aggregator with SARIF/JSON output.
- **EPIC-6** — Authorized managed regions (region IDs encode authorized V IDs; splicer cross-validates against `module-design.md`'s `Target Source File(s)`).
- **EPIC-7** — Deterministic golden-output e2e fixtures (LLM-judge demoted to advisory regression detector).
- **EPIC-8** — Package-install smoke test (assert all 17 commands + 4 hooks register after a clean install).
- **EPIC-9** — Strict prompt-injection containment (net-new linter for prompt-injection patterns in V-Model artifacts).
- **EPIC-10** — Reviewer/signoff schema (per-artifact `reviewers:` and `signoff:` fields validated against domain-specific minimums).

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
