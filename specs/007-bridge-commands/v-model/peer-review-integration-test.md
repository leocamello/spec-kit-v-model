# Peer Review — integration-test.md

**Reviewer**: AI Peer Review (spec-kit V-Model)
**Date**: 2026-04-28
**Artifact**: integration-test.md (42 ITP test cases active / 0 deprecated / 0 suspect; 74 ITS scenarios; 21 ARCH modules covered)
**Standard**: ISO/IEC/IEEE 29119-4:2021 — Technical Review (IEEE 1028:2008 §5)
**Pass**: 2 (post Pass-B remediation)

## Summary

| Severity | Count |
|----------|-------|
| Critical | 0 |
| Major | 3 |
| Minor | 2 |
| Observation | 3 |
| **Total Findings** | **8** |

---

## Findings

### PRF-ITP-001 — Stale ITP / ITS counts in artifact header and Coverage Summary

| Field | Value |
|-------|-------|
| **Severity** | Major |
| **Location** | Artifact header (line 5 implied), §Coverage Summary (lines ~929–938), V&V Coverage / Entry Criteria block (line ~921) |
| **Defect Type** | Inconsistent |
| **Description** | After Pass B added two new test cases (ITP-019-C with 3 ITS, ITP-020-C with 3 ITS), the artifact still reports **40 ITP test cases** and **68 ITS scenarios** in the Coverage Summary table ("Total Test Cases (ITP) \| 40", "Total Scenarios (ITS) \| 68", "Test Cases with ≥1 ITS \| 40 / 40 (100%)"). Actual counts derived by `grep -cE "^#### Test Case: ITP-"` and `grep -cE "Integration Scenario: ITS-"` are **42 ITP** and **74 ITS** respectively. The Entry Criteria check still asserts "21/21 = 100% forward coverage" (correct for ARCH count) but the implicit ITP/ITS totals it presupposes are wrong. This violates ISO/IEC 20246:2017 §6.3 *Inconsistent* — the same artifact reports two different counts for the same population, breaking auditability and any downstream consumer that grep-extracts these numbers (e.g., dashboards, traceability scripts). |
| **Recommendation** | Update three lines of the Coverage Summary table to read `Total Test Cases (ITP) \| 42`, `Total Scenarios (ITS) \| 74`, and `Test Cases with ≥1 ITS \| 42 / 42 (100%)`. Also re-check any header / abstract that prints the ITP count and update accordingly. Consider adding a CI check that grep-extracts the count and diffs it against the Coverage Summary cell to prevent future drift. |

---

### PRF-ITP-002 — ITP-019-C absent from Test Harness & Mocking Strategy table

| Field | Value |
|-------|-------|
| **Severity** | Major |
| **Location** | §Test Harness & Mocking Strategy, ARCH-019 row (line ~880) |
| **Defect Type** | Missing |
| **Description** | The mocking-strategy row for ARCH-019 reads `ITP-019-A, ITP-019-B \| Real filesystem \| Fixture feature_dir trees committed under tests/fixtures/feature-dirs/`. ITP-019-C — the new Concurrency & Race Condition Testing case added in Pass B — is not listed. Concurrency tests have materially different harness requirements from ITP-019-A/B: they require a **shared barrier / thread or process pool** for ITS-019-C1, **a paired writer driven on a tight loop** for ITS-019-C2, and **a coordinated dual-writer harness** for ITS-019-C3. Without an explicit mock/stub strategy entry, an implementer cannot tell whether (a) real OS-level threading + real ARCH-021 writes are required, (b) `pyfakefs` would suffice, or (c) a deterministic scheduler shim is mandated. The omission undermines the reproducibility goal that the Mocking Strategy table exists to satisfy (per the artifact's own framing of the table as "auditable" — see PRF-ITP-005 in pass 1). |
| **Recommendation** | Add an explicit row (or extend the existing ARCH-019 row) for ITP-019-C describing: (i) real OS threads/processes synchronised by `threading.Barrier` (or `multiprocessing.Barrier`) for ITS-019-C1, (ii) a real ARCH-021 atomic-writer driven from a sibling thread/process for ITS-019-C2, and (iii) a coordinated dual-writer harness (two real ARCH-021 invocations against two distinct files) for ITS-019-C3. Note that a mocked filesystem cannot verify the read-during-rename invariant — real OS rename semantics are required. |

---

### PRF-ITP-003 — ITP-020-C absent from Test Harness & Mocking Strategy table

| Field | Value |
|-------|-------|
| **Severity** | Major |
| **Location** | §Test Harness & Mocking Strategy, ARCH-020 row (line ~881) |
| **Defect Type** | Missing |
| **Description** | The mocking-strategy row for ARCH-020 reads `ITP-020-A, ITP-020-B, ITP-020-D \| Real subprocess \| Helper scripts shipped in tests/scripts/`. ITP-020-C — the new Interface Fault Injection case for malformed YAML / corrupted-config payloads added in Pass B to mitigate HAZ-024 — is not listed. ITS-020-C1 needs a helper script that emits malformed YAML on stdout; ITS-020-C2 needs a malformed `v-model-config.yml` fixture file on disk that is read directly by ARCH-011 (no subprocess); ITS-020-C3 needs a well-formed-but-domain-empty fixture. These three scenarios use **two different harness shapes** (subprocess for C1, direct file read for C2/C3) — distinct from the "Real subprocess + helper scripts" pattern that covers A/B/D. Implementers will under-scope the harness without an explicit row. |
| **Recommendation** | Add an explicit row for ITP-020-C describing: (i) a malformed-YAML stdout helper script under `tests/scripts/` for ITS-020-C1, (ii) malformed-YAML fixture files under `tests/fixtures/v-model-config/malformed/` (e.g., `tab-indent.yml`, `unclosed-mapping.yml`, `non-printable-byte.yml`) consumed directly by ARCH-011 for ITS-020-C2, and (iii) a `domain-empty.yml` fixture for ITS-020-C3. Note that for C2/C3 the subprocess machinery of ARCH-020 is *not* on the call path — these scenarios test ARCH-011's direct file read. The artifact may also wish to acknowledge that ITP-020-C straddles the ARCH-020 / ARCH-011 boundary. |

---

### PRF-ITP-004 — Technique Distribution table stale (sums to 40, not 42)

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | §Technique Distribution table (lines ~942–947) |
| **Defect Type** | Inconsistent |
| **Description** | The Technique Distribution table reports: Interface Contract Testing 21 (52.5%), Interface Fault Injection 14 (35.0%), Data Flow Testing 2 (5.0%), Concurrency & Race Condition Testing 3 (7.5%) — total 40. Actual counts after Pass B are **Interface Contract Testing 21 (50.0%)**, **Interface Fault Injection 15 (35.7%)** — adds ITP-020-C, **Data Flow Testing 2 (4.8%)**, **Concurrency & Race Condition Testing 4 (9.5%)** — adds ITP-019-C — total 42. Same root cause as PRF-ITP-001 but in a different table; itemised separately because the cells, percentages, and population mix all need recalculation rather than a single number bump. |
| **Recommendation** | Recompute and replace the four data rows with `21 / 50.0%`, `15 / 35.7%`, `2 / 4.8%`, `4 / 9.5%` (or whichever rounding convention the artifact already uses). Verify the prose elsewhere ("21/40 test cases use this technique (52.5%)" — see e.g., the Coverage Analysis section of any consuming review or README) is not also pinned to the stale numbers. |

---

### PRF-ITP-005 — ITS-005-B1 atomicity boundary still ambiguous (carryover from pass 1)

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | ITS-005-B1 (line ~285–288) |
| **Defect Type** | Ambiguous |
| **Description** | This finding was raised in pass 1 as PRF-ITP-003 (Minor). The current scenario still reads `... ARCH-021 is NEVER invoked for ANY of the three files (including the first one that would have spliced cleanly), and the file_set is never returned to ARCH-004.` This wording conflates two distinct invariants: (1) **no ARCH-021 rename syscall is reached** for any of the three files, and (2) **any tmp files produced during a partially-completed first-file write are cleaned up**. The scenario does not say which one is being tested, and a reader cannot tell whether implementing the test against (1) alone would still satisfy the artifact's intent. The fix from pass 1 was not applied. |
| **Recommendation** | Add a clarifying sentence in the Then clause: either (a) "ARCH-021's rename syscall is never reached because ARCH-005 evaluates all three splices before any disk write" — making the invariant explicit, or (b) "any tmp file produced by an attempted first-file splice is cleaned up by the next ARCH-021 invocation per ITP-021-D's cleanup contract" — making the cross-reference explicit. Either resolves the ambiguity at zero implementation cost. |

---

### PRF-ITP-006 — Pass-1 Major findings PRF-ITP-001/002 fully remediated by Pass B

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Location** | ITP-019-C (lines ~700–727), ITP-020-C (lines ~763–790) |
| **Defect Type** | Informational |
| **Description** | The two pass-1 Major findings — PRF-ITP-001 (HAZ-023 race condition lacked an explicit interleaving scenario) and PRF-ITP-002 (HAZ-024 lacked an explicit malformed-YAML negative path) — have been fully addressed. ITP-019-C contains three scenarios covering N-way concurrent reads (ITS-019-C1), write-during-rename torn-read prevention (ITS-019-C2), and dual-writer cross-file consistency (ITS-019-C3) — exceeding the pass-1 recommendation. ITP-020-C contains three scenarios covering malformed-YAML on subprocess stdout (ITS-020-C1), malformed `v-model-config.yml` on disk (ITS-020-C2), and the well-formed-but-domain-empty edge case (ITS-020-C3) — also exceeding the pass-1 recommendation. Both new test cases explicitly cite their originating PRF IDs in the description, providing an audit trail back to pass 1. This is exemplary remediation. |
| **Recommendation** | No action. Recorded as positive evidence of the lint-and-fix loop working as designed. |

---

### PRF-ITP-007 — Lifecycle clean (no deprecated or suspect items)

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Location** | Entire artifact |
| **Defect Type** | Informational |
| **Description** | Per §4.10 of the rubric, the artifact was scanned for `[DEPRECATED]` and `[SUSPECT]` markers. Zero instances of either marker were found. All 42 ITP test cases and all 74 ITS scenarios are active. There are no orphaned deprecation chains and no unresolved suspect tags. Lifecycle state is clean. |
| **Recommendation** | No action. Noted for the technical review record. |

---

### PRF-ITP-008 — V&V Coverage table for ARCH-019/020/021 omits new test cases

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Location** | §V&V Coverage / Architecture Module–to–V&V Activity Mapping, rows ARCH-019 and ARCH-020 (lines ~913–914) |
| **Defect Type** | Incomplete |
| **Description** | The "ITPs Covering" cell for ARCH-019 lists `ITP-019-A, ITP-019-B` and the cell for ARCH-020 lists `ITP-020-A, ITP-020-B, ITP-020-D`. Neither cell mentions the newly added ITP-019-C or ITP-020-C. While the ARCH coverage criterion (every ARCH has ≥1 ITP) is still met, the table is incomplete and obscures the actual breadth of integration coverage for the cross-cutting modules — particularly relevant since these are the very modules whose missing scenarios prompted Pass B. Recorded as Observation rather than Minor because the table is descriptive (not normative for coverage gating), but it should be brought into sync. |
| **Recommendation** | Update the ARCH-019 cell to `ITP-019-A, ITP-019-B, ITP-019-C` and the ARCH-020 cell to `ITP-020-A, ITP-020-B, ITP-020-C, ITP-020-D`. Same edit pattern as PRF-ITP-001 — a coordinated count refresh would knock out PRF-ITP-001, PRF-ITP-004, and PRF-ITP-008 in one pass. |

---

## Coverage Analysis (§4.5 checklist)

| Criterion | Status | Evidence |
|-----------|--------|----------|
| CDCT / Interface Contract Testing technique present? | ✅ Pass | Explicitly named in §ISO 29119-4 Techniques; 21 of 42 test cases (50.0%) use this technique |
| Fault Injection scenarios present? | ✅ Pass | 15 of 42 test cases (35.7%) use Interface Fault Injection; ITP-020-C now exercises malformed YAML for HAZ-024 |
| Interface Coverage (every ARCH module interface tested)? | ✅ Pass | V&V Coverage table maps all 21 ARCH modules to ≥1 ITP and lists exercised inter-module edges |
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

## Pass-1 → Pass-2 Delta

| Pass-1 Finding | Pass-1 Severity | Pass-2 Status |
|----------------|-----------------|---------------|
| PRF-ITP-001 (HAZ-023 missing race scenario in ITP-019) | Major | **Fixed** — ITP-019-C added with 3 scenarios |
| PRF-ITP-002 (HAZ-024 missing parse-failure scenario in ITP-020) | Major | **Fixed** — ITP-020-C added with 3 scenarios |
| PRF-ITP-003 (ITS-005-B1 atomicity boundary unclear) | Minor | **Open** — re-raised as PRF-ITP-005 (carryover) |
| PRF-ITP-004 (CDCT naming present — informational) | Observation | Still applicable; no re-issue (positive observation) |
| PRF-ITP-005 (Mocking strategy well-documented) | Observation | **Partially regressed** — new ITP-019-C and ITP-020-C are missing from the table; raised as PRF-ITP-002 + PRF-ITP-003 (Major) |
| PRF-ITP-006 (Lifecycle clean) | Observation | Still clean — re-issued as PRF-ITP-007 |

**New defects introduced by Pass B**: 3 (stale counts in two summary tables + missing mocking-strategy rows for the two new test cases). All are bookkeeping defects — no regression in test design or technique selection.

---

## Standards Applied

| Standard | Section | Application |
|----------|---------|-------------|
| IEEE 1028:2008 | §5 | Technical Review process, entry/exit criteria, defect classification |
| ISO/IEC/IEEE 29119-4:2021 | §5–§7 | Integration test technique selection (CDCT, Fault Injection, Data Flow, Concurrency) |
| ISO/IEC 20246:2017 | §6.3 | Defect taxonomy (Missing, Inconsistent, Ambiguous, Incomplete, Wrong, Superfluous) |
| IEEE 1012:2016 | §5.6.1 | Entry criteria for V&V activities at integration layer |
