# Peer Review — integration-test.md

**Reviewer**: AI Peer Review (spec-kit V-Model)
**Date**: 2026-04-27
**Artifact**: integration-test.md (40 ITP entries, 68 ITS scenarios)
**Standard**: ISO/IEC/IEEE 29119-4:2021 — Technical Review
**Review Type**: Technical Review per IEEE 1028:2008 §5

## Summary

| Severity | Count |
|----------|-------|
| Critical | 0 |
| Major | 2 |
| Minor | 1 |
| Observation | 3 |
| **Total Findings** | **6** |

---

## Findings

### PRF-ITP-001 — HAZ-023 (Race Condition) Missing Explicit Interleaving Scenario in ITP-019

| Field | Value |
|-------|-------|
| **Severity** | Major |
| **Location** | ITP-019-A, ITP-019-B |
| **Defect Type** | Missing |
| **Description** | HAZ-023 (architecture-level race condition: "Hallucination Guard scanner invoked on stale snapshot of generated files") is documented in `hazard-analysis.md` line 109 as `Critical / Remote / Undesirable` risk. The critical-hazard-verification-profile.md §HAZ-023 explicitly recommends that peer-review confirm "one of the ITP-019 scenarios exercises a write-then-immediately-scan ordering case, not just a sequential happy path." ITP-019-A covers cross-consumer stable representation; ITP-019-B covers malformed artifact propagation. Neither scenario exercises an explicit race-condition / concurrent-execution / inter-process-ordering test case. The fsync-barrier mitigation between SYS-003 file writes and SYS-006 verification cannot be validated without this scenario. |
| **Recommendation** | Add ITP-019-C (Concurrency & Race Condition Testing) exercising a write-then-immediately-scan ordering sequence: Given two in-flight processes (or a simulated interleaving), when one writes new `ArtifactSet` to disk while another reads, then verify the returned set is internally consistent (no half-written artifacts). Rationale: ARCH-019 is a cross-cutting shared contract boundary; its contract must hold even under concurrent load per the architecture-design.md Process View. |

---

### PRF-ITP-002 — HAZ-024 (Malformed Config) Missing Explicit Parse-Failure Scenario in ITP-020

| Field | Value |
|-------|-------|
| **Severity** | Major |
| **Location** | ITP-020-A, ITP-020-B |
| **Defect Type** | Missing |
| **Description** | HAZ-024 (architecture-level protocol failure: "malformed `v-model-config.yml` parsed as empty overlay rather than hard error") is documented in `hazard-analysis.md` line 110 as `Critical / Remote / Undesirable` risk with mitigation "ARCH-020 contract: schema validation MUST raise on parse failure." The critical-hazard-verification-profile.md §HAZ-024 explicitly recommends peer-review verify "ITP-020 must include a malformed YAML negative-path scenario." ITP-020-A covers stdout/stderr/exit-code capture; ITP-020-B covers subprocess-not-found and binary-output rejection. Neither scenario exercises explicit malformed-YAML / parse-failure / corrupted-config parsing. The contract requirement that parse failures raise rather than degrade cannot be validated without this scenario. |
| **Recommendation** | Add ITP-020-B alternative (or new ITP-020-C: Fault Injection) exercising YAML schema validation failure: Given a `v-model-config.yml` with invalid YAML syntax (e.g., unclosed mapping, invalid key syntax), when ARCH-020 is invoked to run the YAML parser subprocess, then verify the subprocess returns non-zero exit code and the caller (ARCH-011 / ARCH-004) receives a `SubprocessFailure` or equivalent, not a silent downgrade to base behavior. Rationale: HAZ-024 is Critical severity; silent regulatory-obligation downgrade is unacceptable. |

---

### PRF-ITP-003 — ITP-005-B Region Conflict Atomicity Boundary Unclear

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | ITP-005-B1 |
| **Defect Type** | Incomplete |
| **Description** | ITP-005-B verifies that a `RegionConflict` from ARCH-010 aborts ARCH-005 before any file is written through ARCH-021. The scenario states "ARCH-021 is NEVER invoked for ANY of the three files (including the first one that would have spliced cleanly)." This is a strong statement but relies on ARCH-005 implementing a fail-fast abort gate. The scenario does not explicitly verify the atomicity contract: if the second-file region conflict is detected but cleanup of the first file (if partially written to tmp) is required, the test should assert that the tmp file is cleaned up. Currently, the scenario only asserts that ARCH-021 is "never invoked," which conflates two concerns: (1) the abort happens before the first file reaches ARCH-021's rename, and (2) any orphaned tmp files are cleaned. |
| **Recommendation** | Clarify the test case intent in ITS-005-B1: Does it verify (1) that ARCH-021's rename syscall is never reached for any of the three files, or (2) that any tmp files created during the first file's attempted write are cleaned up? If (2) is intended, make it explicit in the scenario's **Then** clause. If only (1) is intended, add a note that cleanup is the responsibility of the next ARCH-021 invocation (per the ITP-021-D cleanup contract). This clarification does not require new test code, only a refinement to the scenario description. |

---

### PRF-ITP-004 — CDCT Technique Naming Present; No ISO 29119 Technique Absence

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Location** | §ISO 29119-4 Integration Test Techniques (Overview) |
| **Defect Type** | Informational |
| **Description** | The document explicitly names and maps four ISO 29119-4 integration test techniques to source views (Interface Contract Testing, Data Flow Testing, Interface Fault Injection, Concurrency & Race Condition Testing). The technique distribution table shows: Interface Contract Testing (52.5%), Interface Fault Injection (35.0%), Data Flow Testing (5.0%), Concurrency & Race Condition Testing (7.5%). This is a sound distribution. The rubric §4.5 requires "Named Techniques" to be explicitly identified — this artifact meets the criterion. No finding. |
| **Recommendation** | No action required. Technique selection and naming are explicit and traceable. Consider this a positive observation for the technical review record. |

---

### PRF-ITP-005 — Mocking and Stubbing Strategy Well-Documented

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Location** | Test Harness & Mocking Strategy (§ after coverage table) |
| **Defect Type** | Informational |
| **Description** | The artifact includes a detailed table mapping every ITP test case to its external dependencies and mock/stub strategy. This level of specificity reduces ambiguity during implementation and makes the integration test plan auditable. Examples: ITP-001-A/B use "spy" recorders; ITP-002-B uses a "fake filesystem" (pyfakefs/memfs); ITP-003-C uses real modules end-to-end; ITP-021-D uses real OS rename + signal injection. This is exemplary peer-review evidence that fault injection and concurrency testing approaches are deliberate, not implicit. No finding. |
| **Recommendation** | This is a strong artifact pattern. Document the mocking strategy early in other V-Model artifacts as a best practice. |

---

### PRF-ITP-006 — Lifecycle Validation (§4.10) — No Deprecation or Suspect Items Found

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Location** | Entire artifact |
| **Defect Type** | Informational |
| **Description** | Per §4.10 of the peer-review rubric, every artifact must be checked for lifecycle issues: `[DEPRECATED]`, `[SUSPECT]`, and orphaned deprecation chains. Grep search of integration-test.md found zero instances of `[DEPRECATED]` or `[SUSPECT]` markers. All 40 ITP entries are active; no items are marked for removal or review. This is a clean lifecycle state. No finding. |
| **Recommendation** | No action required. Lifecycle cleanliness confirmed. |

---

## Coverage Analysis

Per §4.5 (integration-test checklist):

| Criterion | Status | Evidence |
|-----------|--------|----------|
| CDCT Technique present? | ✅ Pass | "Interface Contract Testing" explicitly named in § ISO 29119-4 Techniques; 21/40 test cases use this technique (52.5%) |
| Fault Injection scenarios present? | ✅ Pass | 14/40 test cases use "Interface Fault Injection" (35.0%); exception contracts, malformed inputs, disk-full errors, binary output rejection all exercised |
| Interface Coverage (every ARCH module interface tested)? | ✅ Pass | V&V Coverage table (lines 828–859) maps all 21 ARCH modules to ITPs; all inter-module interfaces are exercised |
| ARCH Coverage (every active ARCH has ≥1 ITP)? | ✅ Pass | Coverage Summary: 21/21 = 100% forward coverage (active items only); zero deprecated modules |
| **Entry Criteria (IEEE 1012:2016 §5.6.1)** | ⚠️ Conditional | ✅ architecture-design.md is current (committed 0414411) ✅ Every ARCH-NNN module has ≥1 ITP test case (21/21) ✅ All ITP-NNN-X have ≥1 ITS-NNN-X# scenario (40/40) ⚠️ **Architecture design peer-review pending** — artifact status says "Architecture design peer-review pending (`m1-007-peer-review` in Phase 1a)" but this integration-test artifact itself is ready for review |

---

## Lifecycle State

- **Active Items**: 40 (ITP-001 through ITP-021, with A/B/C/D sub-cases)
- **Deprecated Items**: 0
- **Suspect Items**: 0
- **Orphaned Chains**: 0

**Lifecycle Status**: Clean. No deprecation or audit-trail issues detected.

---

## Critical Hazard Verification Verdict

### ⚠️ Item 1: HAZ-023 (Race Condition in Bridge State)

**Verdict**: **Major — Fix Required**

**Details**: The critical-hazard-verification-profile.md §HAZ-023 explicitly flags: "confirm one of the ITP-019 scenarios exercises a write-then-immediately-scan ordering case, not just a sequential happy path." 

**Inspection Result**: ITP-019-A (stable in-memory representation) and ITP-019-B (malformed artifact propagation) are both sequential single-threaded scenarios. Neither exercises a race-condition / concurrent-access / inter-process-ordering test.

**Impact**: HAZ-023 is `Critical / Remote / Undesirable` risk; its mitigation (fsync barrier between SYS-003 writes and SYS-006 scan) cannot be validated without an explicit race-condition scenario.

**Recommendation**: Add ITP-019-C (Concurrency & Race Condition Testing) per PRF-ITP-001 above.

---

### ⚠️ Item 2: HAZ-024 (Malformed YAML Config Corrupts Bridge State)

**Verdict**: **Major — Fix Required**

**Details**: The critical-hazard-verification-profile.md §HAZ-024 explicitly recommends: "ITP-020 must include a 'malformed YAML' negative-path scenario; peer-review should verify this is present, not implicit."

**Inspection Result**: ITP-020-A covers stdout/stderr capture; ITP-020-B covers subprocess-not-found and binary-output rejection. Neither exercises malformed-YAML / parse-failure / corrupted-config parsing.

**Impact**: HAZ-024 is `Critical / Remote / Undesirable` risk; silent regulatory-obligation downgrade is unacceptable. The parse-failure exception contract cannot be validated without this scenario.

**Recommendation**: Add ITP-020-C (or alternative within ITP-020-B) exercising malformed YAML schema validation per PRF-ITP-002 above.

---

## Exit Criteria

Per IEEE 1028:2008 §5 (Technical Review Exit Criteria):
- ✅ All findings documented with severity and recommendation
- ✅ Defect metrics collected (2 Major, 1 Minor, 3 Observation)
- ✅ Artifact completeness verified (40/40 ITP, 68/68 ITS scenarios present)
- ⚠️ **2 Major findings block approval** until resolved

**CI Exit Code**: `1` (Major findings present)

---

## Next Steps

1. **Add ITP-019-C** (Concurrency & Race Condition Testing) exercising write-then-immediately-scan ordering to mitigate HAZ-023 race condition.

2. **Add ITP-020-C** (or alternative) exercising malformed YAML parse-failure to mitigate HAZ-024 silent downgrade.

3. **Clarify ITP-005-B1** atomicity boundary (optional, Minor priority) — explicitly state cleanup responsibility if tmp files are created during partial write.

4. **Re-run peer-review** after fixes to confirm all findings resolved.

---

## Standards Applied

| Standard | Section | Application |
|----------|---------|-------------|
| IEEE 1028:2008 | §5 | Technical Review process, entry/exit criteria, defect classification |
| ISO/IEC/IEEE 29119-4:2021 | §5–§7 | Integration test technique selection, CDCT, fault injection, concurrency testing |
| ISO/IEC 20246:2017 | §6.3 | Defect taxonomy (Missing, Wrong, Incomplete, Incomplete, Inconsistent, Ambiguous) |
| ISO 14971:2019 | §5 | Risk matrix severity/likelihood application to critical hazard verification |

---

## Peer Review Classification

**Review Type**: Technical Review (IEEE 1028:2008 §5)  
**Defect Focus**: Missing test scenarios for critical-hazard verification (HAZ-023, HAZ-024)  
**Recommendation**: Fix and resubmit for final approval  

---

*Review completed by: AI Peer Review (spec-kit V-Model) — stateless linting engine per speckit.v-model.peer-review.md*  
*Findings are advisory-only; PRF-ITP-NNN IDs do not participate in the V-Model traceability chain.*
