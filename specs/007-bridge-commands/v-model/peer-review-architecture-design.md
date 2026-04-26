# Peer Review — architecture-design.md

**Reviewer**: AI Peer Review (spec-kit V-Model)  
**Date**: 2026-04-26  
**Artifact**: architecture-design.md (21 ARCH entries)  
**Standard**: IEEE 42010:2011 / Kruchten 4+1 — Technical Review  

## Summary

| Severity | Count |
|----------|-------|
| Critical | 0 |
| Major | 2 |
| Minor | 2 |
| Observation | 3 |
| **Total Findings** | **7** |

## Findings

### PRF-ARCH-001 — ARCH-006 Interface Missing Exception Specification

| Field | Value |
|-------|-------|
| **Severity** | Major |
| **Location** | ARCH-006: Test Generator |
| **Description** | The interface contract for ARCH-006 (Test Generator) lacks an Exception row despite being a component that reads test-plan artifacts and generates files to the filesystem. Per IEEE 42010 §5.3.2, all interface contracts MUST specify error/exception handling. ARCH-006 is called by ARCH-004 as part of the generation pipeline; without documented exception cases, callers cannot reason about failure modes (file I/O errors, malformed test plans, write conflicts). |
| **Recommendation** | Add an Exception row documenting potential failure scenarios, e.g., `Exception | MalformedTestPlan | raised | text + line | when test-plan artifact fails parse` and `Exception | IOError | from ARCH-021 | text | propagated when atomic write fails`. Verify the interface matches implementation contracts. |

### PRF-ARCH-002 — ARCH-013 Validation Result Semantics Underspecified

| Field | Value |
|-------|-------|
| **Severity** | Major |
| **Location** | ARCH-013: Spec-Kit Schema Validator |
| **Description** | The ARCH-013 interface defines Output `ValidationResult` as `{valid: bool, errors: [{section, line, message}]}`, but does not specify the error-recovery protocol for callers. When `valid == false`, does the caller (a) abort immediately with the error list, (b) log and retry with reduced schema, or (c) emit a warning and proceed? ARCH-001 and ARCH-003 both call ARCH-013 but their exception specifications imply (a) abort. This ambiguity violates IEEE 42010 §5.3.4 (completeness of error contracts). |
| **Recommendation** | Clarify the contract: (1) if `valid == false` is a fatal condition, add `Exception | SchemaValidationError | raised | (errors already in ValidationResult)` and document the abort condition explicitly, or (2) if reduced-schema fallback is possible, document the retry/fallback protocol in the Output constraints. Current state implies hard failure (supports REQ-IF-001 round-trip), so recommend option (1): formalize the exception. |

### PRF-ARCH-003 — ARCH-009 Interface Does Not Specify Return Format for Hallucinations

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | ARCH-009: Hallucination Guard |
| **Description** | The ARCH-009 interface specifies Output `VerifyResult` as `{valid: bool, hallucinations: [{file, line, id}]}`, but does not document the format of the `id` field within each hallucination record. Is `id` a string match extracted from source code, or a fully normalized ID that can be compared directly to `vmodel_id_set`? The constraint says "valid ⟺ len(hallucinations) == 0", implying the caller checks array length rather than the `valid` flag. This ambiguity could lead to caller errors or incorrect hallucination reporting. |
| **Recommendation** | Add a constraint: `hallucinations[].id` is extracted verbatim from the source comment and MUST be a strict string match against an entry in `vmodel_id_set` (after normalization of any whitespace/casing). Clarify whether the caller SHOULD check `valid` or `len(hallucinations)` for fail-closed behavior. Add an example: `hallucinations: [{file: "src/main.py", line: 42, id: "MOD-999"}]` when MOD-999 is not in the artifact set. |

### PRF-ARCH-004 — Data Flow View Missing Error Cases

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | Data Flow View (lines 400–426) |
| **Description** | The data flow tables document the happy-path transformations (e.g., "Stage 6: ARCH-013 → validate_tasks_schema → ValidationResult"), but do not show alternative flows or error states (e.g., what happens if validation fails, who catches the exception, does ARCH-021 still write, or is the write gated on validation success?). IEEE 42010 §5.4.3 recommends that data-flow views include error paths for safety- or reliability-critical components. This is especially important for ARCH-004 (Implementation Pipeline) where ARCH-009 validation failure MUST prevent ARCH-018 commit. |
| **Recommendation** | Add a separate "Data Flow: Error Cases" section documenting: (1) ARCH-013 validation failure → abort ARCH-003 before write, (2) ARCH-009 hallucination detected → abort ARCH-004 before ARCH-018 commit, (3) ARCH-021 atomic-write failure → rollback all side-effects and raise exception. Use conditional flow notation or separate error-path tables (e.g., "If valid == false, ARCH-003 exits 1 and does not invoke ARCH-021"). |

### PRF-ARCH-005 — CROSS-CUTTING Module Rationale Placement Inconsistent

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Location** | ARCH-019, ARCH-020, ARCH-021 (Logical View table, Overview section) |
| **Description** | The three cross-cutting modules (ARCH-019, ARCH-020, ARCH-021) have rationale documented in two places: (1) inline in the Logical View table under the Description column (tagged with backticks and labeled "Rationale:"), and (2) in the Overview section (lines 17–20) with a general explanation. Additionally, each has a separate rationale block in the Interface View table (lines 85–87). This triple-documentation approach is redundant and violates DRY (Don't Repeat Yourself), increasing maintenance risk if rationale changes. |
| **Recommendation** | Consolidate the rationale: remove the inline "Rationale:" text from the Logical View table Description column and retain only a pointer (e.g., "See Interface View" or "See Overview §Cross-Cutting Justification"). Keep the detailed rationale in the Overview and Interface View sections. This reduces duplication and makes the Logical View table more scannable. |

### PRF-ARCH-006 — Coverage Summary References Future States (Nonexistent Modules)

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Location** | Coverage Summary (lines 465–481) |
| **Description** | The Coverage Summary claims "Total Parent System Components Covered: 14 / 14 (100%)" and "Forward Coverage (SYS→ARCH): 100%". However, this count is static and assumes the system-design.md will not evolve. If a new SYS component is added to system-design.md in a future sprint without a corresponding ARCH module, the forward coverage metric becomes stale and misleading. This is a low-severity issue because the metric is computed at review time, but it highlights that coverage claims are transient unless tied to automated validation. |
| **Recommendation** | Add a note in the Coverage Summary: "Forward coverage (SYS→ARCH) is 100% as of the active SYS set in system-design.md (SYS-001 through SYS-014). Maintenance note: when a new SYS-NNN is added, confirm an ARCH module is created and update this section. Consider adding an automated coverage check in CI to detect gaps." This acknowledges the transient nature of static metrics. |

### PRF-ARCH-007 — Quality Attribute Justification Missing Probability Estimates

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Location** | Architecture Evaluation § Quality Attribute Justification (lines 431–441) |
| **Description** | The table justifies each architecture decision against ISO 25010 quality characteristics but provides only qualitative trade-off statements (e.g., "Acceptable: bridge-command runtime is I/O- and LLM-bound, not CPU-bound"). Per ISO/IEC 42030:2019 §6 (Fitness for Purpose), architecture decisions should include explicit likelihood and impact estimates to support residual-risk acceptance. For example, the single-threaded sequential model trades "Performance Efficiency down" for "Reliability up", but no quantitative boundary is given (e.g., "worst-case latency increase: <5%", "concurrency-bug risk reduction: from N to zero"). |
| **Recommendation** | Where feasible, add quantitative estimates alongside each trade-off. Examples: (1) "Reliability of deterministic execution: current defect rate from concurrency bugs → 0 estimated; latency increase: <3% based on benchmarks", (2) "Subprocess overhead for each validation script invocation: ~50ms, acceptable because baseline script execution is ~500ms." This strengthens the justification and provides measurable acceptance criteria for future audits. |

---

## Lifecycle & Deprecation Checks

- ✅ **No deprecated items found** — artifact contains 21 active ARCH entries, 0 deprecated, 0 suspect.
- ✅ **No deprecation audit-trail defects** — no `[DEPRECATED]` tags without reason.
- ✅ **No unresolved lifecycle suspects** — no `[SUSPECT]` items flagged.
- ✅ **Coverage exclusion rules apply** — no deprecated parents with active children (N/A: no deprecated items).

## Standards Compliance

| Criterion | Status | Notes |
|-----------|--------|-------|
| **4+1 Views Complete** | ✅ Pass | Logical, Process, Interface, Data Flow views all present and populated. |
| **Cross-Cutting Justification** | ✅ Pass | ARCH-019, ARCH-020, ARCH-021 have explicit rationale per IEEE 42010 §5.1.1. |
| **Interface Completeness** | ⚠️ Partial | All 21 ARCH modules have interface contracts. Two modules (ARCH-006, ARCH-013) lack complete exception specifications (see PRF-ARCH-001, PRF-ARCH-002). |
| **SYS Traceability** | ✅ Pass | Forward coverage (SYS→ARCH): 100%. Every active SYS-001 through SYS-014 is covered by 1+ ARCH module. Cross-cutting modules properly tagged and justified. |
| **Interaction Diagrams** | ✅ Pass | Three mermaid sequence diagrams present: Plan Synthesis, Implementation Pipeline, Hazard-Aware Tasks. |
| **Error Handling Coverage** | ⚠️ Partial | Most critical error paths documented (ARCH-004 exceptions, ARCH-007 gate failure, ARCH-009 hallucination). Data flow error cases underspecified (see PRF-ARCH-004). |

## Summary of Required Actions

**Critical:** None.

**Major (must fix before approval):**
1. **PRF-ARCH-001**: Add exception specification to ARCH-006 interface contract.
2. **PRF-ARCH-002**: Clarify ARCH-013 validation failure protocol (abort vs. retry). Recommend formalizing as an exception.

**Minor (should fix):**
1. **PRF-ARCH-003**: Document `hallucinations[].id` format and caller failure-check semantics.
2. **PRF-ARCH-004**: Add error-path data flows for validation failures and commit gating.

**Observations (optional):**
1. **PRF-ARCH-005**: Consolidate cross-cutting rationale to reduce duplication.
2. **PRF-ARCH-006**: Add CI validation note to Coverage Summary.
3. **PRF-ARCH-007**: Strengthen trade-off justifications with quantitative estimates.

## Recommendation

**Conditional Approval**: The architecture-design.md is well-structured and provides comprehensive coverage of the bridge-commands system under IEEE 42010 principles. However, the two **Major** findings (incomplete exception specifications in ARCH-006 and ARCH-013) must be resolved before this artifact can be approved for implementation. These are not fundamental design flaws, but interface-contract gaps that could lead to caller errors or incomplete error handling.

**Next Steps:**
1. Address Major findings in PRF-ARCH-001 and PRF-ARCH-002 (target: immediate fix before merge).
2. Address Minor findings PRF-ARCH-003 and PRF-ARCH-004 (target: before release, may be deferred to M1 if M0 schedule is constrained).
3. Consider Observation items PRF-ARCH-005 through PRF-ARCH-007 as maintenance tasks for future iterations.

---

**Peer Review Exit Criteria:** Per IEEE 1028:2008 §5.5.4, this review exits with **Major findings requiring rework** (exit code would be 1 — does not pass without fixes).
