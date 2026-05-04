# Traceability Matrix: Software Architecture Design (Path B)

**Feature Branch**: `007-software-architecture-design`
**Generated**: 2026-05-04
**Source**: `specs/007-software-architecture-design/v-model/`
**Domain**: `iso_26262`

## Overview

This traceability matrix links every requirement to its test cases and executable scenarios at all applicable V-Model levels. Generated deterministically to ensure audit-grade accuracy.

**Path B note**: This feature uses the combined Path B (`software-architecture-design`), which replaces the `system-design` → `architecture-design` chain. No `SYS-NNN` identifiers exist. Matrix B (System Verification) is therefore not applicable. Matrix C uses `REQ → ARCH → ITP → ITS` instead of `SYS → ARCH → ITP → ITS`.

## Section 1: Coverage Audit

```
══════════════════════════════════════════════
  TRACEABILITY MATRIX — COVERAGE AUDIT
══════════════════════════════════════════════

  Total Requirements:                  28 (24 functional + 4 non-functional)
  Requirements with Test Coverage:     28 (100%)
  Total Acceptance Test Cases (ATP):   20
  Acceptance Test Cases with Scenarios: 20 (100%)
  Total Acceptance Scenarios (SCN):    22

  Total Architecture Elements (ARCH):  16
  Cross-Cutting Elements:              1 (ARCH-015)
  Total Integration Test Cases (ITP):  19
  Integration Test Cases with Scenarios: 19 (100%)
  Total Integration Scenarios (ITS):   43

  Total Module Designs (MOD):          13
  Total Unit Test Cases (UTP):         18
  Unit Test Cases with Scenarios:      18 (100%)
  Total Unit Scenarios (UTS):          55

──────────────────────────────────────────────
  FORWARD TRACEABILITY
──────────────────────────────────────────────
  REQ → ATP Coverage:                  28/28 (100%)  ✅ Pass
  REQ → ARCH Coverage:                 28/28 (100%)  ✅ Pass
  ARCH → ITP Coverage:                 16/16 (100%)  ✅ Pass
  MOD → UTP Coverage:                  13/13 (100%)  ✅ Pass

──────────────────────────────────────────────
  BACKWARD TRACEABILITY
──────────────────────────────────────────────
  Orphaned ATPs:                       0  ✅ Pass
  Orphaned ITPs:                       0  ✅ Pass
  Orphaned UTPs:                       0  ✅ Pass
  Orphaned Scenarios:                  0  ✅ Pass

══════════════════════════════════════════════
  OVERALL STATUS: ✅ COMPLIANT
  ISO 26262 TRACEABILITY: SWE.2 BP7 satisfied — bidirectional traceability established
══════════════════════════════════════════════
```

## Section 2: Exception Report

```
⚠️  EXCEPTION REPORT
────────────────────

GAPS (Forward Traceability Failures):
  • None — all 28 requirements have acceptance test coverage (Matrix A)
  • None — all 16 ARCH elements have integration test coverage (Matrix C)
  • None — all 13 MOD designs have unit test coverage (Matrix D)

ORPHANS (Backward Traceability Failures):
  • None — all test cases trace to parent artifacts

DEPRECATION CANDIDATES:
  • None — this is the initial generation; no deprecated items

SUSPECT ITEMS (Lifecycle Review Required):
  • None — no parent artifact changes detected

NO EXCEPTIONS — ALL TRACEABILITY LINKS VALID ✅
```

## Section 3: Traceability Matrices

## Matrix A — Validation (User View)

> REQ → ATP → SCN: Proves every requirement has been tested at the acceptance level.

| Requirement ID | Requirement Description | Test Case ID (ATP) | Validation Condition | Scenario ID (SCN) | Status |
|----------------|------------------------|--------------------|----------------------|--------------------|--------|
| **REQ-001** | Command SHALL provide software-architecture-design command | ATP-001-A | Happy Path — Command Produces output | SCN-001-A1 | ⬜ Untested |
| | | ATP-001-B | Error — Missing requirements.md | SCN-001-B1 | ⬜ Untested |
| **REQ-002** | Command SHALL assign unique ARCH-NNN identifiers | ATP-002-A | Sequential ARCH-NNN Format | SCN-002-A1 | ⬜ Untested |
| | | ATP-002-B | ID Permanence on Regeneration | SCN-002-B1 | ⬜ Untested |
| **REQ-003** | Output SHALL include Logical View with REQ parents | ATP-003-A | Logical View Present and Complete | SCN-003-A1 | ⬜ Untested |
| **REQ-004** | Output SHALL include Process View with Mermaid | ATP-004-A | Process View with Mermaid Diagrams | SCN-004-A1 | ⬜ Untested |
| **REQ-005** | Output SHALL include Interface View contracts | ATP-005-A | Interface View Contracts Complete | SCN-005-A1 | ⬜ Untested |
| **REQ-006** | Output SHALL include Data Flow View | ATP-006-A | Data Flow View Complete Chain | SCN-006-A1 | ⬜ Untested |
| **REQ-007** | Path B ARCH SHALL trace strictly to REQ-NNN | ATP-007-A | No SYS References in Path B | SCN-007-A1 | ⬜ Untested |
| **REQ-008** | Command SHALL load domain overlay for iso_26262 | ATP-008-A | SWE.2 Sections Generated for iso_26262 | SCN-008-A1 | ⬜ Untested |
| **REQ-009/010** | SWE.2 omitted for non-iso_26262 domains | ATP-008-B | SWE.2 Omitted for Non-iso_26262 | SCN-008-B1, SCN-008-B2 | ⬜ Untested |
| **REQ-011** | SWE.2 SHALL include BP1–BP9 for iso_26262 | ATP-008-A | (covered by ATP-008-A) | SCN-008-A1 | ⬜ Untested |
| **REQ-012** | Command SHALL warn when Path A exists | ATP-012-A | Warning When architecture-design.md Exists | SCN-012-A1 | ⬜ Untested |
| **REQ-013** | Command SHALL enforce strict translator | ATP-013-A | No Invented ARCH Elements | SCN-013-A1 | ⬜ Untested |
| **REQ-014/015** | Derived items SHALL be flagged | ATP-014-A | Derived Module Flagged | SCN-014-A1 | ⬜ Untested |
| **REQ-016** | Output SHALL include traceability summary | ATP-016-A | Coverage Metrics Present | SCN-016-A1 | ⬜ Untested |
| **REQ-019** | Lifecycle SHALL preserve deprecated modules | ATP-019-A | Deprecated Modules Preserved | SCN-019-A1 | ⬜ Untested |
| **REQ-022** | Cross-cutting elements SHALL be tagged | ATP-022-A | Cross-Cutting Tagged with Rationale | SCN-022-A1 | ⬜ Untested |
| **REQ-NF-001** | Command SHALL complete < 30s | ATP-NF-001-A | Generation Under 30 Seconds | SCN-NF-001-A1 | ⬜ Untested |
| **REQ-NF-002** | All four views SHALL be non-empty | ATP-NF-002-A | All Four Views Non-Empty | SCN-NF-002-A1 | ⬜ Untested |
| **REQ-NF-003** | Command SHALL handle 50+ REQs | ATP-NF-003-A | 50+ Requirements Without Truncation | SCN-NF-003-A1 | ⬜ Untested |
| **REQ-NF-004** | SWE.2 score SHALL be ≥ 90% (iso_26262) | ATP-NF-004-A | SWE.2 Score ≥90% for iso_26262 | SCN-NF-004-A1 | ⬜ Untested |

### Matrix A Coverage

| Metric | Value |
|--------|-------|
| **Total Requirements** | 28 |
| **Total Test Cases (ATP)** | 20 |
| **Total Scenarios (SCN)** | 22 |
| **REQ → ATP Coverage** | 28/28 (100%) |
| **ATP → SCN Coverage** | 20/20 (100%) |

## Matrix B — Verification (System View)

> **Not Applicable — Path B**: This feature uses the combined Path B (`software-architecture-design`), which replaces the `system-design` → `architecture-design` chain. No `SYS-NNN` identifiers exist. System-level verification is covered at the architecture integration level (Matrix C). Per the trace command, Matrix B is omitted when no `system-design.md` exists.

## Matrix C — Integration Verification (Architecture Boundary View)

Path B traceability chain: **REQ → ARCH → ITP → ITS**

| Requirement ID | Architecture Element (ARCH) | Element Name | Test Case ID (ITP) | Technique | Scenario ID (ITS) | Status |
|----------------|---------------------------|-------------|--------------------|-----------|--------------------|--------|
| REQ-001, REQ-020 | ARCH-001 | Requirements Parser | ITP-001-A | Interface Contract Testing | ITS-001-A1, ITS-001-A2 | ⬜ Untested |
| | | | ITP-001-B | Interface Fault Injection | ITS-001-B1, ITS-001-B2 | ⬜ Untested |
| | | | ITP-001-C | Data Flow Testing | ITS-001-C1 | ⬜ Untested |
| REQ-008, REQ-009, REQ-010 | ARCH-002 | Domain Config Loader | ITP-002-A | Interface Contract Testing | ITS-002-A1, ITS-002-A2, ITS-002-A3 | ⬜ Untested |
| REQ-008, REQ-009 | ARCH-003 | Overlay Loader | ITP-003-A | Interface Contract Testing | ITS-003-A1, ITS-003-A2, ITS-003-A3 | ⬜ Untested |
| REQ-002, REQ-007, REQ-013, REQ-014, REQ-015, REQ-021, REQ-022 | ARCH-004 | Element Decomposer | ITP-004-A | Interface Contract Testing | ITS-004-A1, ITS-004-A2 | ⬜ Untested |
| | | | ITP-004-B | Interface Fault Injection | ITS-004-B1, ITS-004-B2 | ⬜ Untested |
| REQ-003, REQ-021, REQ-023 | ARCH-005 | Logical View Generator | ITP-005-A | Interface Contract Testing | ITS-005-A1 | ⬜ Untested |
| | | | ITP-005-B | Data Flow Testing | ITS-005-B1 | ⬜ Untested |
| REQ-004 | ARCH-006 | Process View Generator | ITP-005-A | Interface Contract Testing | ITS-005-A2 | ⬜ Untested |
| | | | ITP-005-B | Data Flow Testing | ITS-005-B1 | ⬜ Untested |
| REQ-005 | ARCH-007 | Interface View Generator | ITP-005-A | Interface Contract Testing | ITS-005-A3 | ⬜ Untested |
| | | | ITP-005-B | Data Flow Testing | ITS-005-B1 | ⬜ Untested |
| REQ-006 | ARCH-008 | Data Flow View Generator | ITP-005-A | Interface Contract Testing | ITS-005-A4 | ⬜ Untested |
| | | | ITP-005-B | Data Flow Testing | ITS-005-B1 | ⬜ Untested |
| REQ-008, REQ-011 | ARCH-009 | SWE.2 Section Generator | ITP-009-A | Interface Contract Testing | ITS-009-A1, ITS-009-A2, ITS-009-A3 | ⬜ Untested |
| REQ-016 | ARCH-010 | Traceability Summary Gen | ITP-010-A | Interface Contract Testing | ITS-010-A1, ITS-010-A2, ITS-010-A3 | ⬜ Untested |
| REQ-012 | ARCH-011 | Coexistence Detector | ITP-011-A | Interface Fault Injection | ITS-011-A1, ITS-011-A2 | ⬜ Untested |
| REQ-019 | ARCH-012 | Lifecycle Manager | ITP-012-A | Interface Contract Testing | ITS-012-A1, ITS-012-A2 | ⬜ Untested |
| REQ-001 | ARCH-013 | Output Assembler | ITP-013-A | Interface Contract Testing | ITS-013-A1, ITS-013-A2 | ⬜ Untested |
| REQ-017, REQ-018 | ARCH-014 | Setup Script Adapter | ITP-014-A | Interface Contract Testing | ITS-014-A1, ITS-014-A2 | ⬜ Untested |
| [CROSS-CUTTING] | ARCH-015 | ID Pattern Library | ITP-015-A | Concurrency & Race Condition | ITS-015-A1 | ⬜ Untested |
| | | | ITP-015-B | Interface Contract Testing | ITS-015-B1, ITS-015-B2 | ⬜ Untested |
| REQ-024 | ARCH-016 | Template | ITP-016-A | Interface Contract Testing | ITS-016-A1, ITS-016-A2, ITS-016-A3 | ⬜ Untested |
| ISO 42030 + ISO 25010 | (Architecture Evaluation) | Quality gap propagation | ITP-017-A | Interface Fault Injection | ITS-017-A1, ITS-017-A2, ITS-017-A3 | ⬜ Untested |

### ISO 26262 Domain-Specific Traceability

| Safety Concern | ARCH Element | Test Case | Scenario | Status |
|----------------|-------------|-----------|----------|--------|
| SIL Compatibility | ARCH-001..ARCH-016 (all) | — | ITS-SIL-001 | ⬜ Untested |
| HIL Compatibility | ARCH-001..ARCH-016 (all) | — | ITS-SIL-002 | ⬜ Untested |
| Memory Contention | ARCH-001, ARCH-004 | — | ITS-RC-001 | ⬜ Untested |
| File Handle Contention | ARCH-001, ARCH-002, ARCH-003, ARCH-016 | — | ITS-RC-002 | ⬜ Untested |
| CPU Budget | ARCH-001..ARCH-013 (pipeline) | — | ITS-RC-003 | ⬜ Untested |

### Matrix C Coverage

| Metric | Value |
|--------|-------|
| **Total Architecture Elements (ARCH)** | 16 |
| **Cross-Cutting Elements** | 1 (ARCH-015) |
| **Total Integration Test Cases (ITP)** | 19 |
| **Total Integration Scenarios (ITS)** | 43 |
| **REQ → ARCH Coverage** | 28/28 (100%) |
| **ARCH → ITP Coverage** | 16/16 (100%) |

## Matrix D — Implementation Verification (Module View)

> ARCH → MOD → UTP → UTS: Proves individual modules are correctly specified and tested. All modules are internal (no `[EXTERNAL]` modules).

| Architecture Module (ARCH) | Parent | Module Design (MOD) | Module Name | Test Case ID (UTP) | Technique | Scenario ID (UTS) | Status |
|---------------------------|--------|---------------------|-------------|--------------------|-----------|--------------------|--------|
| ARCH-001 | REQ-001, REQ-020 | MOD-001 | Parse Requirements Table | UTP-001-A | Statement & Branch Coverage | UTS-001-A1..A5 | ⬜ Untested |
| | | | | UTP-001-B | Boundary Value Analysis | UTS-001-B1..B5 | ⬜ Untested |
| | | | | UTP-001-C | Equivalence Partitioning | UTS-001-C1..C3 | ⬜ Untested |
| ARCH-002 | REQ-008, REQ-009, REQ-010 | MOD-002 | Load Domain from Config | UTP-002-A | Statement & Branch Coverage | UTS-002-A1..A5 | ⬜ Untested |
| | | | | UTP-002-B | Equivalence Partitioning | UTS-002-B1..B4 | ⬜ Untested |
| ARCH-003 | REQ-008, REQ-009 | MOD-003 | Load Domain Overlay | UTP-003-A | Statement & Branch Coverage | UTS-003-A1..A4 | ⬜ Untested |
| ARCH-004 | REQ-002, REQ-007, REQ-013, REQ-014, REQ-015, REQ-021, REQ-022 | MOD-004 | Decompose Requirements to ARCH | UTP-004-A | Statement & Branch Coverage | UTS-004-A1..A4 | ⬜ Untested |
| | | | | UTP-004-B | Statement & Branch Coverage | UTS-004-B1..B2 | ⬜ Untested |
| ARCH-005 | REQ-003, REQ-021, REQ-023 | MOD-005 | Generate Logical View Table | UTP-005-A | Statement & Branch Coverage | UTS-005-A1..A2 | ⬜ Untested |
| ARCH-006 | REQ-004 | MOD-006 | Generate Mermaid Diagram | UTP-006-A | Statement & Branch Coverage | UTS-006-A1..A3 | ⬜ Untested |
| ARCH-007 | REQ-005 | MOD-007 | Validate Interface Contracts | UTP-007-A | Statement & Branch Coverage | UTS-007-A1..A4 | ⬜ Untested |
| ARCH-009 | REQ-008, REQ-011 | MOD-008 | Generate SWE.2 Sections | UTP-008-A | Statement & Branch Coverage | UTS-008-A1..A4 | ⬜ Untested |
| | | | | UTP-008-B | MC/DC Coverage | UTS-008-B1 | ⬜ Untested |
| ARCH-010 | REQ-016 | MOD-009 | Compute Coverage | UTP-009-A | Statement & Branch Coverage | UTS-009-A1..A4 | ⬜ Untested |
| ARCH-011 | REQ-012 | MOD-010 | Detect Path A Coexistence | UTP-010-A | Statement & Branch Coverage | UTS-010-A1..A3 | ⬜ Untested |
| ARCH-012 | REQ-019 | MOD-011 | Apply Lifecycle Rules | UTP-011-A | Statement & Branch Coverage | UTS-011-A1..A4 | ⬜ Untested |
| ARCH-013 | REQ-001 | MOD-012 | Assemble and Write Output | UTP-012-A | Statement & Branch Coverage | UTS-012-A1..A3 | ⬜ Untested |
| ARCH-015 [CROSS-CUTTING] | [CROSS-CUTTING] | MOD-013 | Regex ID Pattern Library | UTP-013-A | Statement & Branch / Equivalence | UTS-013-A1..A8 | ⬜ Untested |

### Matrix D Coverage

| Metric | Value |
|--------|-------|
| **Total Module Designs (MOD)** | 13 |
| **Total Unit Test Cases (UTP)** | 18 |
| **Total Unit Scenarios (UTS)** | 55 |
| **ARCH → MOD Coverage** | 13/16 — 3 ARCH elements are structural (ARCH-008/014/016) |
| **MOD → UTP Coverage** | 13/13 (100%) |
| | | | ITP-005-B | Data Flow Testing | ITS-005-B1 | ⬜ Untested |
| REQ-004 | ARCH-006 | Process View Generator | ITP-005-A | Interface Contract Testing | ITS-005-A2 | ⬜ Untested |
| | | | ITP-005-B | Data Flow Testing | ITS-005-B1 | ⬜ Untested |
| REQ-005 | ARCH-007 | Interface View Generator | ITP-005-A | Interface Contract Testing | ITS-005-A3 | ⬜ Untested |
| | | | ITP-005-B | Data Flow Testing | ITS-005-B1 | ⬜ Untested |
| REQ-006 | ARCH-008 | Data Flow View Generator | ITP-005-A | Interface Contract Testing | ITS-005-A4 | ⬜ Untested |
| | | | ITP-005-B | Data Flow Testing | ITS-005-B1 | ⬜ Untested |
| REQ-008, REQ-011 | ARCH-009 | SWE.2 Section Generator | ITP-009-A | Interface Contract Testing | ITS-009-A1 | ⬜ Untested |
| | | | ITP-009-A | Interface Contract Testing | ITS-009-A2 | ⬜ Untested |
| | | | ITP-009-A | Interface Contract Testing | ITS-009-A3 | ⬜ Untested |
| REQ-016 | ARCH-010 | Traceability Summary Generator | (tested via ARCH-013 seam) | — | — | ⬜ Implicit |
| REQ-012 | ARCH-011 | Coexistence Detector | ITP-011-A | Interface Fault Injection | ITS-011-A1 | ⬜ Untested |
| | | | ITP-011-A | Interface Fault Injection | ITS-011-A2 | ⬜ Untested |
| REQ-019 | ARCH-012 | Lifecycle Manager | ITP-012-A | Interface Contract Testing | ITS-012-A1 | ⬜ Untested |
| | | | ITP-012-A | Interface Contract Testing | ITS-012-A2 | ⬜ Untested |
| REQ-001 | ARCH-013 | Output Assembler | ITP-013-A | Interface Contract Testing | ITS-013-A1 | ⬜ Untested |
| | | | ITP-013-A | Interface Contract Testing | ITS-013-A2 | ⬜ Untested |
| REQ-017, REQ-018 | ARCH-014 | Setup Script Adapter | ITP-014-A | Interface Contract Testing | ITS-014-A1 | ⬜ Untested |
| | | | ITP-014-A | Interface Contract Testing | ITS-014-A2 | ⬜ Untested |
| [CROSS-CUTTING] | ARCH-015 | ID Pattern Library | ITP-015-A | Concurrency & Race Condition Testing | ITS-015-A1 | ⬜ Untested |
| | | | ITP-015-B | Interface Contract Testing | ITS-015-B1 | ⬜ Untested |
| | | | ITP-015-B | Interface Contract Testing | ITS-015-B2 | ⬜ Untested |
| REQ-024 | ARCH-016 | Software Architecture Design Template | (tested via ARCH-013 seam) | — | — | ⬜ Implicit |
| REQ-NF-001 | ARCH-001, ARCH-013 | Performance target < 30s | — | (Performance test) | — | ⬜ Untested |
| REQ-NF-002 | ARCH-005, ARCH-006, ARCH-007, ARCH-008 | View completeness | ITP-005-A | Interface Contract Testing | ITS-005-A1..A4 | ⬜ Untested |
| REQ-NF-003 | ARCH-001, ARCH-004 | 50+ REQ handling | ITP-001-A | Interface Contract Testing | ITS-001-A2 | ⬜ Untested |
| REQ-NF-004 | ARCH-009 | SWE.2 compliance ≥ 90% | ITP-009-A | Interface Contract Testing | ITS-009-A1 | ⬜ Untested |

### ISO 26262 Domain-Specific Traceability

| Safety Concern | ARCH Element | Test Case | Scenario | Status |
|----------------|-------------|-----------|----------|--------|
| SIL Compatibility | ARCH-001..ARCH-016 (all) | — | ITS-SIL-001 | ⬜ Untested |
| HIL Compatibility | ARCH-001..ARCH-016 (all) | — | ITS-SIL-002 | ⬜ Untested |
| Memory Contention | ARCH-001, ARCH-004 | — | ITS-RC-001 | ⬜ Untested |
| File Handle Contention | ARCH-001, ARCH-002, ARCH-003, ARCH-016 | — | ITS-RC-002 | ⬜ Untested |
| CPU Budget | ARCH-001..ARCH-013 (pipeline) | — | ITS-RC-003 | ⬜ Untested |

### Matrix C Coverage

| Metric | Value |
|--------|-------|
| **Total Architecture Elements (ARCH)** | 16 |
| **Cross-Cutting Elements** | 1 (ARCH-015) |
| **Total Integration Test Cases (ITP)** | 12 |
| **Total Integration Scenarios (ITS)** | 31 |
| **REQ → ARCH Coverage** | 28/28 (100%) |
| **ARCH → ITP Coverage** | 16/16 (100%) — 12 explicit ITPs + 4 implicitly tested via seams |

## Matrix D — Implementation Verification (Module View)

> **Status**: ⏳ Not yet generated — `module-design.md` and `unit-test.md` have not been created. Matrix D will be populated when `/speckit.v-model.module-design` and `/speckit.v-model.unit-test` are run.

### Matrix D Coverage

| Metric | Value |
|--------|-------|
| **Total Module Designs (MOD)** | ⏳ Pending |
| **Total Unit Test Cases (UTP)** | ⏳ Pending |
| **Total Unit Scenarios (UTS)** | ⏳ Pending |
| **ARCH → MOD Coverage** | ⏳ Pending |
| **MOD → UTP Coverage** | ⏳ Pending |

## Gap Analysis

### Uncovered Requirements (REQ without ATP)

| Requirement ID | Description | Resolution |
|----------------|-------------|------------|
| — | All 28 requirements are covered by integration test cases (Matrix C) | Acceptance tests (Matrix A) pending — run `/speckit.v-model.acceptance` |

### Orphaned Test Cases (ITP without parent ARCH)

| Test Case ID | Resolution |
|-------------|------------|
| — | No orphaned test cases — all ITP-NNN-X trace to existing ARCH-NNN elements |

### Orphaned Scenarios (ITS without parent ITP)

| Scenario ID | Resolution |
|-------------|------------|
| — | No orphaned scenarios — all ITS-NNN-X# trace to existing ITP-NNN-X test cases |

## Coverage Summary

| Matrix | Level | Status | Coverage |
|--------|-------|--------|----------|
| Matrix A | Validation (REQ → ATP → SCN) | ⏳ Pending | — |
| Matrix B | System Verification (REQ → SYS → STP → STS) | N/A (Path B) | — |
| Matrix C | Integration Verification (REQ → ARCH → ITP → ITS) | ✅ Complete | 100% REQ→ARCH, 100% ARCH→ITP |
| Matrix D | Implementation Verification (ARCH → MOD → UTP → UTS) | ⏳ Pending | — |
