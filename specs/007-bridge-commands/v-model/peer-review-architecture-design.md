# Peer Review — architecture-design.md

**Reviewer**: AI Peer Review (spec-kit V-Model)
**Date**: 2026-04-27
**Artifact**: architecture-design.md (21 ARCH entries — 21 active, 0 deprecated, 0 suspect)
**Standard**: IEEE 42010:2011 / Kruchten 4+1 — Technical Review (IEEE 1028:2008 §5)

## Summary

| Severity | Count |
|----------|-------|
| Critical | 0 |
| Major | 2 |
| Minor | 4 |
| Observation | 3 |
| **Total Findings** | **9** |

## Findings

<!--
  Pass 2 of peer review for feature/007-bridge-commands.
  All findings regenerated from scratch per the stateless-linter model.
  PRF IDs are advisory and do not participate in V-Model traceability.
-->

### PRF-ARCH-001 — ARCH-006 Exception Contradicts Pipeline Write Order

| Field | Value |
|-------|-------|
| **Severity** | Major |
| **Location** | ARCH-006: Test Generator (Interface View, lines 272–273) and Data Flow View (lines 419–430) |
| **Description** | Defect type: **Inconsistent**. The Pass-A addition to ARCH-006 declares `Exception | IOError | from ARCH-021 | text + path | propagated unchanged when atomic-write of an emitted test file fails ... aborts the run before ARCH-009 is invoked`. This places the disk write *before* ARCH-009. However, the Implementation Pipeline sequence diagram (lines 138–172) returns `test_set` from ARCH-006 to ARCH-004 in memory and then invokes ARCH-009 with no intervening ARCH-021 call, and the "module-design.md MOD entries → source code files" Data Flow table (Stages 6 → 7) explicitly orders ARCH-009 verification *before* ARCH-021 atomic write. The contract therefore contradicts both the Process View and the Data Flow View regarding when (and by whom) tests reach disk. Per IEEE 42010 §5.3.4 / §5.5, interface contracts must be consistent across views. |
| **Recommendation** | Pick one model and align all three views. Recommended: keep writes centralised in ARCH-021 *after* ARCH-009 verification, and reword ARCH-006's `IOError` row to "raised by ARCH-021 in pipeline Stage 7 (after ARCH-009 returns `valid: true`); aborts the run during the write phase, after verification has already passed". Alternatively, if ARCH-006 truly writes before verification, update the Implementation Pipeline diagram to insert an `A6->>A21: atomic_write(test_set)` step before `A4->>A9` and update Data Flow Stages 6–7 to match. |

### PRF-ARCH-002 — ARCH-014 Interface Lacks Exception Specification

| Field | Value |
|-------|-------|
| **Severity** | Major |
| **Location** | ARCH-014: Reduced-Enrichment Fallback (Interface View, lines 339–344) |
| **Description** | Defect type: **Missing**. ARCH-014's interface defines only `Input upstream_doc` and `Output EnrichmentReport` with no Exception row at all. ARCH-014 detects V-Model enrichment in an upstream Markdown document (e.g., a `plan.md` produced by `speckit.plan`); detection involves parsing Markdown and inspecting HTML-comment metadata, both of which can fail (malformed file, non-UTF-8, truncated input, unexpected schema variant). Per IEEE 42010 §5.3.2, every interface must specify error/exception handling — silence here means callers (ARCH-003) cannot reason about how the Hybrid path degrades when the upstream artifact is itself broken. SYS-010 traceability requires this contract because REQ-028 (Hybrid path) gates on it. |
| **Recommendation** | Add at minimum two rows analogous to ARCH-008 / ARCH-013: `Exception | UpstreamParseError | raised | text + line | when upstream_doc is not valid UTF-8 Markdown or cannot be parsed for enrichment markers; propagated to ARCH-003 (fail-closed)` and `Error-recovery | (none — fail-open on metadata absence) | — | — | A successfully parsed upstream_doc whose enrichment metadata is merely absent yields EnrichmentReport{enriched: false}; this is NOT an error. Only structural parse failure raises.` Document explicitly which condition is fail-closed vs fail-open. |

### PRF-ARCH-003 — ARCH-005 Asymmetric With ARCH-006 on Atomic-Write Failure

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | ARCH-005: Code Generator (Interface View, lines 258–264) vs. ARCH-006 (lines 266–273) |
| **Description** | Defect type: **Inconsistent**. ARCH-005 (Code Generator) and ARCH-006 (Test Generator) are sibling emitter modules that both feed `(path, content)` lists into the same downstream pipeline (ARCH-009 verify → ARCH-021 atomic write). Pass A added a comprehensive `IOError` exception row to ARCH-006 but left ARCH-005 with only `RegionConflict`. Whichever resolution PRF-ARCH-001 chooses (writes before or after ARCH-009), the two emitter contracts must be symmetric: either both declare the propagated `IOError` from ARCH-021, or neither does. The asymmetry obscures the architectural symmetry that the Logical View advertises ("orchestration vs. emission" seam, Overview line 12). |
| **Recommendation** | After resolving PRF-ARCH-001, mirror the same `IOError` (and any other ARCH-021-propagated exception) row into ARCH-005's contract. If writes are centralised post-ARCH-009, both rows should read identically modulo the file-set name. |

### PRF-ARCH-004 — ARCH-013 Error-Recovery Row References a Hard-Coded Line Number

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | ARCH-013: Spec-Kit Schema Validator (Interface View, line 336) |
| **Description** | Defect type: **Wrong** (fragile reference). The Pass-A addition to ARCH-013 includes the cross-reference `See ARCH-001 sequence (line 226) for the propagated semantics.` Hard-coded line numbers in a Markdown spec are fragile — any edit above line 226 (e.g., adding a row to ARCH-001 or ARCH-002) silently invalidates the pointer, and reviewers in subsequent passes will chase a stale anchor. The current line 226 happens to be the `Exception | SchemaValidationError | propagated | text + section | when ARCH-013 returns {valid: false}` row of ARCH-001's interface, but a reader following the pointer cannot tell which artifact element was intended. |
| **Recommendation** | Replace `(line 226)` with a structural anchor — either the Markdown heading (`See ARCH-001 § Interface View`) or the row name (`See ARCH-001 Exception "SchemaValidationError" row`). Apply the same convention everywhere a cross-reference is introduced in this artifact. |

### PRF-ARCH-005 — Data Flow View Documents Only Happy Paths

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | Data Flow View — both tables (lines 405–430) |
| **Description** | Defect type: **Incomplete**. Both Data Flow tables (`Requirements → tasks.md` Stages 1–7; `module-design.md → source code` Stages 1–8) document only the success transformation chain. There is a single prose footnote under the Implementation Pipeline diagram acknowledging fail-closed exits "for brevity", but the Data Flow View — which IEEE 42010 §5.4.3 expects to express alternate flows for safety- and reliability-relevant chains — shows nothing about: (a) ARCH-013 returning `valid: false` (does Stage 7 still write?), (b) ARCH-009 returning `valid: false` (Stage 7/8 abort?), (c) ARCH-021 raising `IOError` mid-stage, (d) ARCH-007 returning `passed: false` aborting Stage 3+. This is the same gap flagged in pass 1; Pass A/B did not address it. |
| **Recommendation** | Add a third Data Flow sub-section "Error and Abort Paths" with one row per documented exception: e.g., `If ARCH-013 valid:false at Stage 6 → ARCH-003 raises SchemaValidationError, Stage 7 NOT executed, no tasks.md written` and `If ARCH-009 valid:false at Stage 6 → ARCH-004 raises HallucinationDetected, Stages 7–8 NOT executed, no source files written, no commit produced`. This makes the fail-closed invariant tabular rather than prose-only. |

### PRF-ARCH-006 — ARCH-017 Interface Missing Exception Row Despite Subprocess Dependency

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | ARCH-017: Quality Compliance Harness (Interface View, lines 361–367) |
| **Description** | Defect type: **Missing**. ARCH-017 invokes external test harnesses (BATS, Pester, structural-eval, LLM-eval) via ARCH-020, and ARCH-020's contract explicitly raises `SubprocessFailure` (line 394). ARCH-017's interface, however, declares only `Input feature_dir` and two `Output` rows (`CoverageReport`, `AuditReport`) — no Exception row exists. A caller cannot tell whether a subprocess failure inside one of the four harnesses (a) propagates as an exception, (b) is silently coerced into `merge_gate: "block"`, or (c) yields a partial `CoverageReport`. Per IEEE 42010 §5.3.2 every interface that delegates to a fallible collaborator must surface the propagation rule. |
| **Recommendation** | Add an `Exception | SubprocessFailure | from ARCH-020 | text + harness name + exit code | propagated to caller; merge_gate left undefined when this is raised` row, or — if the design coerces subprocess failures into `merge_gate: "block"` — add an Error-recovery row stating that explicitly. Choose one and document it. |

### PRF-ARCH-007 — Cross-Cutting Rationale Triplicated Across Three Sections

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Location** | ARCH-019, ARCH-020, ARCH-021 — Overview (lines 17–20), Logical View Description column (lines 85–87), and the inline `Rationale:` text inside the Logical View "Description" cells |
| **Description** | The three `[CROSS-CUTTING]` modules carry their justification rationale in three places: (1) the Overview paragraph naming all three at once, (2) inline `**Rationale:**` text inside each module's Logical View "Description" cell, and (3) the "Parent System Components" cell of the Logical View which itself repeats the cross-cutting rationale ("Drift in parsing rules across commands would directly violate REQ-NF-003" for ARCH-019). This violates DRY and creates three places that must be kept in sync. Pass-1 PRF-ARCH-005 raised this same issue; Pass A/B/C did not address it. |
| **Recommendation** | Consolidate to one canonical site (Overview) and replace the inline rationale in the Logical View table with a short pointer ("See Overview § Cross-Cutting Justification"). Treat as a maintenance task, not a release blocker. |

### PRF-ARCH-008 — Coverage Summary Has No Automated-Validation Note

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Location** | Coverage Summary (lines 470–480) |
| **Description** | The Coverage Summary states "Total Parent System Components Covered: 14 / 14 (100%)" and "Forward Coverage (SYS→ARCH): 100%" as static counts. Nothing in the artifact records that these numbers were produced by an automated validator (e.g., `validate-architecture-coverage.sh`) versus computed by a reviewer at write time. If `system-design.md` adds SYS-015 in a future sprint, this static count will silently become wrong. Pass-1 PRF-ARCH-006 raised the same concern; Pass A/B/C did not address it. |
| **Recommendation** | Append a one-line note: "Counts validated by `scripts/bash/validate-architecture-coverage.sh` (Matrix C) — re-run after any change to `system-design.md` or this file. Coverage drift is detected in CI by the same script." |

### PRF-ARCH-009 — Quality Attribute Justifications Lack Quantitative Bounds

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Location** | Architecture Evaluation § Quality Attribute Justification (lines 438–446) |
| **Description** | The trade-off table provides qualitative direction (`↑` / `↓`) per ISO 25010 characteristic but no quantitative envelope. Per ISO/IEC 42030:2019 §6 (Fitness for Purpose), architecture decisions should carry at least an order-of-magnitude estimate so a future audit can verify the trade-off was honoured (e.g., "subprocess overhead per invocation: ~50ms vs. ~500ms baseline script work" or "atomic-write doubles peak temp-file usage to ~2× the largest emitted artifact"). Currently the rationale terminates at "Acceptable" without stating against what threshold acceptance was judged. Pass-1 PRF-ARCH-007 raised the same concern; Pass A/B/C did not address it. |
| **Recommendation** | For each row where a measurable quantity exists, append a parenthetical bound (e.g., for the subprocess row: "subprocess overhead ≤ ~50 ms per invocation vs. script work ≥ ~500 ms — overhead < 10%"). Where no measurement exists, mark "(no quantitative bound established)" so the gap is explicit rather than implicit. |

---

## Lifecycle & Deprecation Checks (Section 4.10)

- ✅ **Deprecation syntax**: No `[DEPRECATED]` items present in the 21 active ARCH entries; rule N/A.
- ✅ **Unresolved suspects**: No `[SUSPECT — Parent X-NNN deprecated|modified]` tags found; rule N/A.
- ✅ **Coverage exclusion**: 21 / 21 modules are active; coverage computation exercises only active items.
- ✅ **Orphaned deprecation chains**: No deprecated parents in `system-design.md` (SYS-001 through SYS-014 all active per cross-reference); no active children to flag.

## Standards Compliance Snapshot

| Criterion | Status | Notes |
|-----------|--------|-------|
| **4+1 Views Complete** (Logical, Process, Interface, Data Flow, Scenarios) | ✅ Pass | All four IEEE 42010 views present; Scenarios covered by the Fitness-for-Purpose table. |
| **Cross-Cutting Justification** | ✅ Pass | ARCH-019/020/021 rationale present (though over-duplicated — see PRF-ARCH-007). |
| **Interface Completeness** | ⚠️ Partial | ARCH-006 contains an internally inconsistent contract (PRF-ARCH-001); ARCH-014 lacks any exception spec (PRF-ARCH-002); ARCH-005 / ARCH-017 missing rows that should mirror their collaborators (PRF-ARCH-003, PRF-ARCH-006). |
| **SYS Traceability** | ✅ Pass | Forward coverage 14/14 against active SYS set; cross-cutting modules properly tagged. |
| **Interaction Diagrams** | ✅ Pass | Three Mermaid sequence diagrams (Plan, Implementation, Tasks). |
| **Error Handling Coverage** | ⚠️ Partial | Most exceptions named in the Interface View; Data Flow View shows happy paths only (PRF-ARCH-005). |

## Pass-1 Remediation Verification

| Pass-1 Finding | Pass-1 Severity | Outcome in This Artifact | New PRF (if any) |
|----------------|-----------------|---------------------------|------------------|
| Pass-1 PRF-ARCH-001 (ARCH-006 missing exception spec) | Major | **Fixed** — ARCH-006 now declares `MalformedTestPlan` and `IOError` exceptions. New issue: the IOError row's timing claim contradicts the pipeline order (re-flagged as PRF-ARCH-001 here, Major). | PRF-ARCH-001 |
| Pass-1 PRF-ARCH-002 (ARCH-013 validation-failure protocol ambiguous) | Major | **Fixed** — ARCH-013 now declares `SchemaValidationError` and an explicit `Error-recovery (none — fail-closed)` row stating callers MUST abort. Residual issue: hard-coded line-number cross-reference (PRF-ARCH-004 here, Minor). | PRF-ARCH-004 |
| Pass-1 PRF-ARCH-003 (ARCH-009 hallucination ID format underspecified) | Minor | **Fixed** — ARCH-009 now specifies `file = absolute path`, `line = 1-indexed`, `id = verbatim claimed identifier`, plus a Determinism row binding it to the SYS-006 algorithm spec. | — |
| Pass-1 PRF-ARCH-004 (Data Flow View missing error cases) | Minor | **Not addressed** — Data Flow tables remain happy-path only. Re-flagged as PRF-ARCH-005 here. | PRF-ARCH-005 |
| Pass-1 PRF-ARCH-005 (Cross-cutting rationale duplicated) | Observation | **Not addressed** — re-flagged as PRF-ARCH-007 here. | PRF-ARCH-007 |
| Pass-1 PRF-ARCH-006 (Coverage Summary not tied to CI) | Observation | **Not addressed** — re-flagged as PRF-ARCH-008 here. | PRF-ARCH-008 |
| Pass-1 PRF-ARCH-007 (Quality attribute trade-offs lack quantitative bounds) | Observation | **Not addressed** — re-flagged as PRF-ARCH-009 here. | PRF-ARCH-009 |

**Net effect of Pass A/B/C on this artifact:** the two pass-1 Majors and one pass-1 Minor were closed; one new Major surfaced as a side-effect of the Pass-A ARCH-006 edit (write-order inconsistency); one previously latent Major (ARCH-014 missing exception spec) and one new Minor (ARCH-017 missing exception row) were exposed by closer review under Section 4.3 criteria.

## Summary of Required Actions

**Critical:** None.

**Major (must fix before approval):**
1. **PRF-ARCH-001** — Reconcile ARCH-006's IOError exception with the Process View / Data Flow View write order.
2. **PRF-ARCH-002** — Add exception specification to ARCH-014.

**Minor (should fix):**
1. **PRF-ARCH-003** — Mirror the resolved IOError row from ARCH-006 onto ARCH-005.
2. **PRF-ARCH-004** — Replace the hard-coded line-number reference in ARCH-013 with a structural anchor.
3. **PRF-ARCH-005** — Add an "Error and Abort Paths" Data Flow sub-section.
4. **PRF-ARCH-006** — Add a SubprocessFailure exception (or fail-closed coercion note) to ARCH-017.

**Observations (optional):**
1. **PRF-ARCH-007** — Consolidate cross-cutting rationale to a single canonical site.
2. **PRF-ARCH-008** — Tie the Coverage Summary counts to `validate-architecture-coverage.sh`.
3. **PRF-ARCH-009** — Append quantitative bounds (or an explicit "no bound established" note) to each Quality Attribute Justification row.

## Recommendation

**Conditional Approval**: Pass A/B/C closed all pass-1 Majors. Two new Majors must be addressed before this artifact can be approved for implementation: the ARCH-006 contract is internally inconsistent (PRF-ARCH-001), and ARCH-014 lacks any exception specification (PRF-ARCH-002). Both are interface-contract gaps rather than fundamental design flaws and should be small surgical edits.

**Next Steps:**
1. Resolve PRF-ARCH-001 by deciding the canonical write-order, then update ARCH-006 (and propagate to ARCH-005 per PRF-ARCH-003).
2. Add the missing exception row to ARCH-014 per PRF-ARCH-002.
3. Address Minor findings PRF-ARCH-004 / PRF-ARCH-005 / PRF-ARCH-006 as part of the same Pass-D edit so the Data Flow View and ARCH-017 contract are no longer stale relative to the rest of the artifact.
4. Defer Observation items PRF-ARCH-007 / PRF-ARCH-008 / PRF-ARCH-009 to a maintenance pass unless an audit deadline forces them sooner.

---

**Peer Review Exit Criteria:** Per IEEE 1028:2008 §5.5.4, this review exits with **Major findings requiring rework** (CI exit code 1).
