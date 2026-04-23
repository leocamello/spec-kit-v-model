---
title: Standards Enrichment
description: How the V-Model Extension Pack applies best-practice IEEE/ISO/IEC standards at each V-cycle layer, with mandatory output sections and quality gates.
---

# Standards Enrichment

Every V-Model command now includes explicit `## Governing Standards` sections that map each output artifact to the international standards governing it. These sections exist not as documentation prose — they are **mandatory output requirements** that every generated artifact must satisfy.

---

## Overview

Standards enrichment (v0.6.0) addressed a gap: earlier command versions referenced standards in prose descriptions but didn't structure their output sections around them. A `system-design.md` command might mention "IEEE 1016" somewhere in its instructions, but the generated artifact didn't have a section explicitly cross-referencing its four views to the IEEE 1016 clauses that require them.

The v0.6.0 release changed this for all 11 base commands. Each command now:

1. Contains a `## Governing Standards` table listing every standard that governs the command's output
2. Enforces standard-specific output sections (not just text references)
3. Produces artifacts that auditors can cross-reference directly to the listed standards

This matters for audits. When a certification authority asks "what standard governs your system design?", the answer is in the artifact itself — with a standards table, not buried in a README.

---

## Standards by V-Cycle Layer

The following table shows the governing standards for each command layer. **Bold** standards were newly integrated in v0.6.0. Safety extensions are delivered by domain overlays and are not listed here — see [Domain Overlay Architecture](domain-overlays.md).

| V-Cycle Layer | Command | Governing Standards |
|---|---|---|
| **Requirements** | `requirements` | IEEE 29148:2018, INCOSE GWR, **ISO/IEC 25010:2023** |
| **Acceptance Test** | `acceptance` | **IEEE 1012:2016**, **ISO/IEC 25010:2023**, ISO/IEC 29119-4:2021 |
| **System Design** | `system-design` | IEEE 1016:2009, **ISO/IEC 25010:2023** |
| **System Test** | `system-test` | ISO/IEC/IEEE 29119, **IEEE 1012:2016** |
| **Architecture Design** | `architecture-design` | IEEE 42010:2011, Kruchten 4+1, **ISO/IEC 42030:2019**, **ISO/IEC 25010:2023** |
| **Integration Test** | `integration-test` | ISO/IEC/IEEE 29119-4:2021, **IEEE 1012:2016** |
| **Module Design** | `module-design` | IEEE 1016:2009, **ISO/IEC/IEEE 12207:2017** |
| **Unit Test** | `unit-test` | ISO/IEC/IEEE 29119-4:2021, **IEEE 1012:2016** |
| **Hazard Analysis** | `hazard-analysis` | **IEC 60812:2018**, ISO 14971:2019 |
| **Peer Review** | `peer-review` | **IEEE 1028:2008**, **ISO/IEC 20246:2017** |
| **Audit Report** | `audit-report` | **IEEE 828-2012**, **ISO 19011:2018**, **ISO/IEC/IEEE 15289:2019** |
| **Impact Analysis** | `impact-analysis` | **IEEE 828-2012** |
| **Test Results** | `test-results` | **ISO/IEC 29119-3:2013** |
| **Traceability** | `trace` | **IEEE 1012:2016**, **ISO/IEC/IEEE 15289:2019**, IEEE 29148:2018 |

**Total:** 26 unique standards (17 best-practice + 9 safety-specific). All 9 standards added in v0.6.0 are now integrated into the base commands.

---

## Governing Standards Section

Every enriched command output now includes a `## Governing Standards` table as a mandatory section. Here is an example from a `system-design.md` artifact:

```markdown
## Governing Standards

| Standard | Scope in This Artifact |
|----------|----------------------|
| IEEE 1016:2009 | Four mandatory design views (§5.1 Decomposition, §5.2 Dependency, §5.3 Interface, §5.4 Data Design) |
| ISO/IEC 25010:2023 | Quality attribute cross-check: each design decision justified against the 9 quality characteristics |
```

The table format is deliberate: it forces the document author (or AI command) to be explicit about which clause of which standard governs each output section. Vague references like "per IEEE 1016" are not sufficient — the specific section must be named.

---

## Quality Characteristics Coverage (ISO/IEC 25010:2023)

ISO/IEC 25010:2023 defines **9 quality characteristics** for software and system products:

| # | Characteristic | Definition |
|---|----------------|------------|
| 1 | **Functional Suitability** | Completeness, correctness, appropriateness |
| 2 | **Performance Efficiency** | Time behaviour, resource utilisation, capacity |
| 3 | **Compatibility** | Co-existence, interoperability |
| 4 | **Interaction Capability** | Operability, user error protection, accessibility |
| 5 | **Reliability** | Maturity, availability, fault tolerance, recoverability |
| 6 | **Security** | Confidentiality, integrity, non-repudiation, authenticity |
| 7 | **Maintainability** | Modularity, reusability, analysability, modifiability, testability |
| 8 | **Flexibility** | Adaptability, scalability, installability, replaceability |
| 9 | **Safety** | Operational constraint, risk identification, fail safety |

### Where it appears

**`requirements` — NFR section:** Each Non-Functional Requirement is tagged with its ISO/IEC 25010 quality characteristic:

```markdown
### Quality Characteristics Coverage (ISO/IEC 25010:2023)

| Characteristic | Requirement IDs |
|----------------|----------------|
| Reliability | REQ-010, REQ-011 |
| Performance Efficiency | REQ-012 |
| Security | REQ-013, REQ-014 |
| Maintainability | REQ-015 |
```

**`system-design` — Quality Attribute Coverage section:** Each design decision is cross-checked against the 9 characteristics:

```markdown
## Quality Attribute Coverage (ISO/IEC 25010:2023)

| Characteristic | Design Decision | Component |
|----------------|----------------|-----------|
| Reliability | Redundant authentication service | SYS-AUTH |
| Performance Efficiency | Cache-first request routing | SYS-CACHE |
```

---

## V&V Coverage Gate (IEEE 1012:2016)

IEEE 1012:2016 defines the Verification and Validation (V&V) activities required at each software lifecycle phase. The standard specifies what must be verified (completeness, consistency, correctness, testability) and how V&V evidence must be structured.

### Where it appears

**`acceptance`, `system-test`, `integration-test`, `unit-test`** — each testing command now includes a mandatory V&V Coverage Gate section:

```markdown
## V&V Coverage Gate (IEEE 1012:2016)

| V&V Activity | Coverage | Status |
|--------------|---------|--------|
| Requirements validation (§5.3.3) | REQ-001 through REQ-015 | ✅ All requirements have paired test cases |
| Interface verification (§5.4.3) | SYS-001 through SYS-008 | ✅ All interfaces have contract tests |
| Completeness check (§5.3.2) | 15/15 requirements covered | ✅ 100% |
| Consistency check (§5.3.2) | No orphaned test cases | ✅ Clean |
```

The gate is mandatory — a command cannot produce a test plan artifact without this section. If coverage is incomplete, the gate shows the gap explicitly rather than allowing it to be silently omitted.

---

## Architecture Evaluation (ISO/IEC 42030:2019)

ISO/IEC 42030:2019 provides a framework for evaluating software architectures against quality attributes and fitness criteria. It defines evaluation activities that should accompany (not replace) the architecture description.

### Where it appears

**`architecture-design`** — includes a mandatory evaluation section alongside the four IEEE 42010 views:

```markdown
## Architecture Evaluation (ISO/IEC 42030:2019 / ISO/IEC 25010:2023)

| Quality Attribute | Architectural Decision | Trade-offs | Evaluation Result |
|-------------------|----------------------|------------|------------------|
| Reliability | Active-passive failover for ARCH-AUTH | Adds complexity to deployment | ✅ Justified — meets REQ-010 availability target |
| Performance | Event-driven message bus for ARCH-MSG | Eventual consistency trade-off | ✅ Justified — within REQ-012 latency budget |
| Maintainability | Layered hexagonal architecture | Learning curve for new contributors | ✅ Justified — aligns with ISO 12207 maintainability |
```

This section ensures that architecture decisions are evaluated, not just described. Auditors reviewing the architecture design can verify that each decision was assessed against measurable criteria.

---

## Standards vs. Safety Domains

Best-practice standards apply to **all projects** regardless of regulatory context. Safety domain extensions apply only when configured.

| Scope | Standards | Activation |
|-------|-----------|-----------|
| **All projects** | IEEE 29148, INCOSE GWR, ISO/IEC 25010, IEEE 1012, IEEE 1016, IEEE 42010, Kruchten 4+1, ISO/IEC 42030, ISO 29119, ISO 29119-4, ISO/IEC 12207, IEC 60812, ISO 14971, IEEE 1028, ISO/IEC 20246, IEEE 828, ISO 19011, ISO/IEC 15289 | Always active |
| **ISO 26262** | ISO 26262:2018, MISRA C/C++ | `domain: iso_26262` |
| **DO-178C** | DO-178C / ED-12C, CERT-C | `domain: do_178c` |
| **IEC 62304** | IEC 62304:2006/AMD1:2015 | `domain: iec_62304` |
| **Cross-domain** | IEC 61508, FDA 21 CFR 820 | Referenced in `trace.md` |

A non-regulated project building a web application benefits from IEEE 29148 requirements structure, ISO/IEC 25010 quality characteristics, and IEEE 1012 V&V gates — just without ASIL tables or DAL coverage matrices.

See [Domain Overlay Architecture](domain-overlays.md) for full details on how safety extensions are loaded at runtime.
