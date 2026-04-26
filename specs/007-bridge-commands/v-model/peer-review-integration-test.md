# Peer Review — integration-test.md

**Reviewer**: AI Peer Review (spec-kit V-Model)
**Date**: 2026-04-29
**Artifact**: integration-test.md (42 ITP test cases active / 0 deprecated / 0 suspect; 74 ITS scenarios; 21 ARCH modules covered)
**Standard**: ISO/IEC/IEEE 29119-4:2021 — Technical Review (IEEE 1028:2008 §5)
**Pass**: 3 (post Pass-D remediation, commit `cd24f25`)

## Summary

| Severity | Count |
|----------|-------|
| Critical | 0 |
| Major | 0 |
| Minor | 1 |
| Observation | 3 |
| **Total Findings** | **4** |

---

## Findings

### PRF-ITP-001 — ITS-005-B1 atomicity boundary still ambiguous (carryover from pass 1 / pass 2)

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | ITS-005-B1 (lines 285–288) |
| **Defect Type** | Ambiguous |
| **Description** | This finding has now persisted across three review passes (originally PRF-ITP-003 in pass 1, re-issued as PRF-ITP-005 in pass 2, and re-issued here). The Then clause still reads verbatim: `ARCH-005 propagates the exception, ARCH-021 is NEVER invoked for ANY of the three files (including the first one that would have spliced cleanly), and the file_set is never returned to ARCH-004.` This wording conflates two distinct invariants: (1) **no ARCH-021 rename syscall is reached** for any of the three files (i.e., ARCH-005 evaluates all splices before any disk write, so failure on file 2 prevents file 1 from ever reaching the writer), and (2) **any tmp files produced during a partially-completed first-file write are cleaned up** by a downstream cleanup contract. The scenario does not declare which invariant is the test oracle. A test author could implement against (1) alone and still claim conformance, even if the artifact's intent was (2). Per ISO/IEC 20246:2017 §6.3 *Ambiguous*, more than one valid interpretation exists. Pass-D scope did not include this fix. |
| **Recommendation** | Add a clarifying sentence in the Then clause. Either (a) `"ARCH-021's rename syscall is never reached because ARCH-005 evaluates all three splices before any disk write"` — making invariant (1) explicit and resolving in favour of fail-before-write semantics, or (b) `"any tmp file produced by an attempted first-file splice is cleaned up by the next ARCH-021 invocation per ITP-021-D's cleanup contract"` — making invariant (2) explicit with a cross-reference. Either edit is one sentence and zero implementation cost. |

---

### PRF-ITP-002 — V&V Coverage table for ARCH-019 and ARCH-020 omits new test cases (carryover from pass 2)

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Location** | §V&V Coverage / Architecture Module–to–V&V Activity Mapping, rows ARCH-019 (line 915) and ARCH-020 (line 916) |
| **Defect Type** | Incomplete |
| **Description** | The "ITPs Covering" cell for ARCH-019 still lists `ITP-019-A, ITP-019-B`, and the cell for ARCH-020 still lists `ITP-020-A, ITP-020-B, ITP-020-D`. Neither cell mentions the Pass-B / Pass-D-acknowledged ITP-019-C or ITP-020-C. Pass-D remediation correctly updated the Coverage Summary, the Technique Distribution, and the Test Harness & Mocking Strategy table — but did not propagate the same edit into the V&V Coverage row cells. The ARCH-coverage criterion (every active ARCH has ≥1 ITP) is still satisfied (21/21 = 100%), so this is non-blocking and informational. The incompleteness is descriptive, not normative — but it obscures the actual breadth of integration coverage for the cross-cutting modules whose missing scenarios prompted Pass B in the first place. |
| **Recommendation** | Update the ARCH-019 cell to `ITP-019-A, ITP-019-B, ITP-019-C` and the ARCH-020 cell to `ITP-020-A, ITP-020-B, ITP-020-C, ITP-020-D`. This is a two-cell text edit with no semantic impact on coverage gating. |

---

### PRF-ITP-003 — Pass-D bookkeeping remediation fully verified

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Location** | Coverage Summary (lines 933–940), Technique Distribution (lines 944–949), Test Harness & Mocking Strategy (lines 881, 883) |
| **Defect Type** | Informational |
| **Description** | The three Pass-2 Major findings (PRF-ITP-001, PRF-ITP-002, PRF-ITP-003) and the Pass-2 Minor PRF-ITP-004 are confirmed CLOSED in this pass. Independently verified counts: `grep -cE "^#### Test Case: ITP-"` returns **42** and `grep -cE "Integration Scenario: ITS-"` returns **74** — both match the Coverage Summary cells (`Total Test Cases (ITP) \| 42`, `Total Scenarios (ITS) \| 74`, `Test Cases with ≥1 ITS \| 42 / 42 (100%)`). The Technique Distribution table cells now sum to 42 (21 + 15 + 2 + 4) with percentages 50.0% / 35.7% / 4.8% / 9.5%. The Test Harness & Mocking Strategy table contains an explicit dedicated row for ITP-019-C (real OS threads + `threading.Barrier` + paired writer + coordinated dual-writer) at line 881 and an explicit dedicated row for ITP-020-C (mixed harness — real subprocess for ITS-020-C1, direct file read of malformed fixtures for ITS-020-C2/C3, with explicit acknowledgement that ITS-020-C2/C3 straddle the ARCH-020 / ARCH-011 boundary) at line 883. All Pass-2 Major bookkeeping debt is discharged with no regression in test design or technique selection. |
| **Recommendation** | No action. Recorded as positive evidence that the lint-and-fix loop is functioning as designed across multiple passes. |

---

### PRF-ITP-004 — Lifecycle clean (no deprecated or suspect items)

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Location** | Entire artifact |
| **Defect Type** | Informational |
| **Description** | Per §4.10 of the rubric, the artifact was scanned for `[DEPRECATED]` and `[SUSPECT]` markers. Zero instances of either marker were found (`grep -cE "^#### Test Case: ITP-.*\[DEPRECATED"` returned 0; `grep -cE "\[SUSPECT"` returned no matches). All 42 ITP test cases and all 74 ITS scenarios are active. There are no orphaned deprecation chains and no unresolved suspect tags. Lifecycle state is clean. |
| **Recommendation** | No action. Noted for the technical review record. |

---

## Coverage Analysis (§4.5 checklist)

| Criterion | Status | Evidence |
|-----------|--------|----------|
| CDCT / Interface Contract Testing technique present? | ✅ Pass | Explicitly named in §ISO 29119-4 Techniques; 21 of 42 test cases (50.0%) use this technique |
| Fault Injection scenarios present? | ✅ Pass | 15 of 42 test cases (35.7%) use Interface Fault Injection; ITP-020-C now exercises malformed YAML for HAZ-024 |
| Interface Coverage (every ARCH module interface tested)? | ✅ Pass | V&V Coverage table maps all 21 ARCH modules to ≥1 ITP and lists exercised inter-module edges (subject to PRF-ITP-002 cosmetic update) |
| ARCH Coverage (every active ARCH has ≥1 ITP)? | ✅ Pass | 21/21 = 100% (zero deprecated ARCH modules) |
| Concurrency & Race Condition Testing present? | ✅ Pass | 4 of 42 test cases (9.5%) — ITP-004-D, ITP-019-C, ITP-020-D, ITP-021-D — covering inter-process, write-during-read, stream-interleaving, and interruption-during-rename surfaces |

---

## §4.10 Lifecycle Validation

- **Active ITP test cases**: 42
- **Deprecated ITP test cases**: 0
- **Suspect ITP test cases**: 0
- **Orphaned deprecation chains**: 0
- **Lifecycle status**: Clean

---

## Pass-2 → Pass-3 Delta

| Pass-2 Finding | Pass-2 Severity | Pass-3 Status |
|----------------|-----------------|---------------|
| PRF-ITP-001 (stale ITP/ITS counts in Coverage Summary) | Major | **Fixed** (Pass-D, commit `cd24f25`) — Coverage Summary now reads 42/74/42-of-42 |
| PRF-ITP-002 (ITP-019-C absent from Mocking Strategy table) | Major | **Fixed** (Pass-D) — explicit row at line 881 with `threading.Barrier`, paired writer, dual-writer harness |
| PRF-ITP-003 (ITP-020-C absent from Mocking Strategy table) | Major | **Fixed** (Pass-D) — explicit row at line 883 with mixed harness, ARCH-011 boundary acknowledged |
| PRF-ITP-004 (Technique Distribution table summed to 40) | Minor | **Fixed** (Pass-D) — table now sums to 42 with rebalanced percentages 50.0/35.7/4.8/9.5 |
| PRF-ITP-005 (ITS-005-B1 atomicity boundary ambiguous) | Minor | **Open** — re-raised as PRF-ITP-001 (carryover; out of Pass-D scope) |
| PRF-ITP-006 (Pass-1 Major remediation acknowledgement) | Observation | Superseded by Pass-3 PRF-ITP-003 — same lint-loop-working observation, updated to Pass-D scope |
| PRF-ITP-007 (Lifecycle clean) | Observation | Re-issued as PRF-ITP-004 — still clean |
| PRF-ITP-008 (V&V Coverage row gap for ARCH-019/020) | Observation | **Open** — re-raised as PRF-ITP-002 (out of Pass-D scope; non-blocking, descriptive) |

**New defects introduced by Pass D**: 0 — Pass-D was a surgical bookkeeping pass and introduced no regressions.
**Pass-2 → Pass-3 net change**: −3 Majors (closed), −1 Minor (closed), Minor and Observation carryovers preserved.

---

## Standards Applied

| Standard | Section | Application |
|----------|---------|-------------|
| IEEE 1028:2008 | §5 | Technical Review process, entry/exit criteria, defect classification |
| ISO/IEC/IEEE 29119-4:2021 | §5–§7 | Integration test technique selection (CDCT, Fault Injection, Data Flow, Concurrency) |
| ISO/IEC 20246:2017 | §6.3 | Defect taxonomy (Missing, Inconsistent, Ambiguous, Incomplete, Wrong, Superfluous) |
| IEEE 1012:2016 | §5.6.1 | Entry criteria for V&V activities at integration layer |
