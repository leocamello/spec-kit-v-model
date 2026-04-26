# Peer Review — architecture-design.md

**Reviewer**: AI Peer Review (spec-kit V-Model)
**Date**: 2026-04-28
**Artifact**: architecture-design.md (21 ARCH entries — 21 active, 0 deprecated, 0 suspect)
**Standard**: IEEE 42010:2011 / Kruchten 4+1 — Technical Review (IEEE 1028:2008 §5)

## Summary

| Severity | Count |
|----------|-------|
| Critical | 0 |
| Major | 0 |
| Minor | 4 |
| Observation | 3 |
| **Total Findings** | **7** |

## Findings

<!--
  Pass 3 of peer review for feature/007-bridge-commands.
  All findings regenerated from scratch per the stateless-linter model.
  PRF IDs are advisory and do not participate in V-Model traceability.

  Pass-D remediation (commit cd24f25) closed both Pass-2 Majors:
    - Pass-2 PRF-ARCH-001 (ARCH-006 IOError write-order contradiction): CLOSED.
      ARCH-006's IOError row (line 273) now explicitly states the exception
      is raised by ARCH-021 in pipeline Stage 7 (after ARCH-009 returns
      valid:true) and clarifies "ARCH-006 itself never writes to disk —
      the (path, content) tuples it returns to ARCH-004 are passed through
      ARCH-009 first, then handed to ARCH-021 for atomic write." This is
      now consistent with the Implementation Pipeline diagram (Stage A4->>A9
      precedes A21 atomic_write) and the "module-design.md MOD entries →
      source code files" Data Flow View (Stages 6 verification → 7 write).
    - Pass-2 PRF-ARCH-002 (ARCH-014 missing exception spec): CLOSED.
      ARCH-014 (lines 345–346) now declares `UpstreamParseError` (fail-closed
      on structural parse failure) and an explicit Error-recovery row stating
      that metadata absence yields EnrichmentReport{enriched:false} and is
      NOT an error (fail-open on metadata absence). The fail-closed vs
      fail-open distinction is correctly partitioned by failure mode.

  Four Pass-2 Minors and three Pass-2 Observations are still present in the
  artifact and are re-flagged below with fresh PRF-ARCH IDs (renumbered from
  001).
-->

### PRF-ARCH-001 — ARCH-005 Asymmetric With ARCH-006 on Atomic-Write Failure

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | ARCH-005: Code Generator (Interface View, lines 258–264) vs. ARCH-006 (lines 266–273) |
| **Description** | Defect type: **Inconsistent**. ARCH-005 (Code Generator) and ARCH-006 (Test Generator) are sibling emitter modules that both feed `list[(path, content)]` into the same downstream pipeline (ARCH-009 verify → ARCH-021 atomic write — see Data Flow View Stages 6→7, lines 430–431). Pass D clarified ARCH-006's `IOError` row to make explicit that ARCH-006 itself never writes — the exception simply propagates back through its call frame from ARCH-021 in Stage 7. By symmetric reasoning ARCH-005 also never writes (Stage 7 of the same data-flow chain handles its `file_set`), yet ARCH-005's contract still declares only `RegionConflict`. The asymmetry obscures the architectural symmetry the Logical View advertises ("orchestration vs. emission" seam, Overview line 11) and forces a reader to chase two different contracts to learn the same propagation rule. Per IEEE 42010 §5.3.4 / §5.5, sibling interfaces must present interface contracts consistently. |
| **Recommendation** | Mirror ARCH-006's `IOError` row onto ARCH-005, using the same wording pattern: `Exception | IOError | from ARCH-021 | text + path | raised by ARCH-021 in pipeline Stage 7 (after ARCH-009 returns valid:true) when atomic-write of an emitted source file fails (e.g., target directory missing, disk full, permission denied); aborts the run during the write phase, after verification has already passed. ARCH-005 itself never writes to disk — the (path, content) tuples it returns to ARCH-004 are passed through ARCH-009 first, then handed to ARCH-021 for atomic write. This row documents the exception that propagates back through ARCH-005's call frame, not a failure mode of ARCH-005 itself.` |

### PRF-ARCH-002 — ARCH-013 Error-Recovery Row References a Hard-Coded Line Number

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | ARCH-013: Spec-Kit Schema Validator (Interface View, line 336) |
| **Description** | Defect type: **Wrong** (fragile reference). The `Exception | SchemaValidationError` row in ARCH-013's contract carries the cross-reference `See ARCH-001 sequence (line 226) for the propagated semantics.` Hard-coded line numbers in a Markdown spec are fragile — any edit above line 226 (e.g., adding a row to ARCH-001 or ARCH-002, the very kind of change PRF-ARCH-001 above recommends) silently invalidates the pointer. The current line 226 happens to be the `Exception | SchemaValidationError | propagated | text + section | when ARCH-013 returns {valid: false}` row of ARCH-001's interface, but a reader following the pointer cannot tell which artifact element was intended once the line shifts. This finding was raised in Pass 2 and has not been addressed. |
| **Recommendation** | Replace `(line 226)` with a structural anchor — either the Markdown heading (`See ARCH-001 § Interface View`) or the row name (`See ARCH-001 Exception "SchemaValidationError" row`). Apply the same convention everywhere a cross-reference is introduced in this artifact. |

### PRF-ARCH-003 — Data Flow View Documents Only Happy Paths

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | Data Flow View — both tables (lines 411–431) |
| **Description** | Defect type: **Incomplete**. Both Data Flow tables (`Requirements → tasks.md` Stages 1–7; `module-design.md → source code` Stages 1–8) document only the success transformation chain. There is a single prose footnote under the Implementation Pipeline diagram (lines 174–177) acknowledging fail-closed exits "for brevity", but the Data Flow View — which IEEE 42010 §5.4.3 expects to express alternate flows for safety- and reliability-relevant chains — shows nothing about: (a) ARCH-013 returning `valid: false` (does Stage 7 still write?), (b) ARCH-009 returning `valid: false` (Stage 7/8 abort?), (c) ARCH-021 raising `IOError` mid-stage (now a documented propagation per Pass-D's ARCH-006 clarification — but the Data Flow View doesn't reflect it), (d) ARCH-007 returning `passed: false` aborting Stage 3+, (e) ARCH-014 raising the new `UpstreamParseError` at Stage 2 of the tasks data flow. This finding was raised in Pass 1 and Pass 2 and remains unaddressed; it is now slightly more visible because Pass D added two new exception rows whose propagation is invisible in the data-flow tabular form. |
| **Recommendation** | Add a third Data Flow sub-section "Error and Abort Paths" with one row per documented exception, e.g.: `If ARCH-013 valid:false at Stage 6 → ARCH-003 raises SchemaValidationError, Stage 7 NOT executed, no tasks.md written`; `If ARCH-009 valid:false at Stage 6 → ARCH-004 raises HallucinationDetected, Stages 7–8 NOT executed, no source files written, no commit produced`; `If ARCH-021 raises IOError at Stage 7 → ARCH-004 propagates, no commit at Stage 8, partial files left in tmp namespace per ARCH-021 atomic semantics`; `If ARCH-014 raises UpstreamParseError at Stage 2 of tasks flow → ARCH-003 propagates fail-closed, Stages 3–7 NOT executed, no tasks.md written`. This makes the fail-closed invariant tabular rather than prose-only. |

### PRF-ARCH-004 — ARCH-017 Interface Missing Exception Row Despite Subprocess Dependency

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | ARCH-017: Quality Compliance Harness (Interface View, lines 363–369) |
| **Description** | Defect type: **Missing**. ARCH-017 invokes external test harnesses (BATS, Pester, structural-eval, LLM-eval) via ARCH-020, and ARCH-020's contract explicitly raises `SubprocessFailure` (line 396). ARCH-017's interface, however, declares only `Input feature_dir` and two `Output` rows (`CoverageReport`, `AuditReport`) — no Exception row exists. A caller cannot tell whether a subprocess failure inside one of the four harnesses (a) propagates as an exception, (b) is silently coerced into `merge_gate: "block"`, or (c) yields a partial `CoverageReport`. Per IEEE 42010 §5.3.2 every interface that delegates to a fallible collaborator must surface the propagation rule. ARCH-007 (the sibling subprocess-driving module) handled this explicitly at line 282: `Exception | SubprocessFailure | from ARCH-020 | text + exit code | propagated as {passed: false} (fail-closed)`. The same treatment is required here. This finding was raised in Pass 2 and has not been addressed. |
| **Recommendation** | Add an `Exception | SubprocessFailure | from ARCH-020 | text + harness name + exit code | propagated to caller; merge_gate left undefined when this is raised` row, OR — if the design coerces subprocess failures into `merge_gate: "block"` analogous to ARCH-007's `passed: false` coercion — add an `Error-recovery | (subprocess failure → merge_gate:"block")` row stating that explicitly. Choose one and document it. |

### PRF-ARCH-005 — Cross-Cutting Rationale Triplicated Across Three Sections

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Location** | ARCH-019, ARCH-020, ARCH-021 — Overview (lines 17–20), Logical View Description column (lines 85–87), and the Logical View "Parent System Components" cell which itself repeats the cross-cutting rationale |
| **Description** | The three `[CROSS-CUTTING]` modules carry their justification rationale in three places: (1) the Overview paragraph naming all three at once, (2) inline `**Rationale:**` text inside each module's Logical View "Description" cell, and (3) the "Parent System Components" cell of the Logical View which itself repeats the cross-cutting rationale (e.g., "Drift in parsing rules across commands would directly violate REQ-NF-003" appears in ARCH-019's row twice). This violates DRY and creates three places that must be kept in sync. Pass-1 PRF-ARCH-005 and Pass-2 PRF-ARCH-007 raised the same issue; Pass A/B/C/D have not addressed it. |
| **Recommendation** | Consolidate to one canonical site (Overview) and replace the inline rationale in the Logical View table with a short pointer ("See Overview § Cross-Cutting Justification"). Treat as a maintenance task, not a release blocker. |

### PRF-ARCH-006 — Coverage Summary Has No Automated-Validation Note

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Location** | Coverage Summary (lines 472–482) |
| **Description** | The Coverage Summary states "Total Parent System Components Covered: 14 / 14 (100%)" and "Forward Coverage (SYS→ARCH): 100%" as static counts. Nothing in the artifact records that these numbers were produced by an automated validator (e.g., `validate-architecture-coverage.sh`) versus computed by a reviewer at write time. If `system-design.md` adds SYS-015 in a future sprint, this static count will silently become wrong. Pass-1 PRF-ARCH-006 and Pass-2 PRF-ARCH-008 raised the same concern; Pass A/B/C/D have not addressed it. |
| **Recommendation** | Append a one-line note: "Counts validated by `scripts/bash/validate-architecture-coverage.sh` (Matrix C) — re-run after any change to `system-design.md` or this file. Coverage drift is detected in CI by the same script." |

### PRF-ARCH-007 — Quality Attribute Justifications Lack Quantitative Bounds

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Location** | Architecture Evaluation § Quality Attribute Justification (lines 440–448) |
| **Description** | The trade-off table provides qualitative direction (`↑` / `↓`) per ISO 25010 characteristic but no quantitative envelope. Per ISO/IEC 42030:2019 §6 (Fitness for Purpose), architecture decisions should carry at least an order-of-magnitude estimate so a future audit can verify the trade-off was honoured (e.g., "subprocess overhead per invocation: ~50ms vs. ~500ms baseline script work" or "atomic-write doubles peak temp-file usage to ~2× the largest emitted artifact"). Currently the rationale terminates at "Acceptable" without stating against what threshold acceptance was judged. Pass-1 PRF-ARCH-007 and Pass-2 PRF-ARCH-009 raised the same concern; Pass A/B/C/D have not addressed it. |
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
| **Cross-Cutting Justification** | ✅ Pass | ARCH-019/020/021 rationale present (though over-duplicated — see PRF-ARCH-005). |
| **Interface Completeness** | ⚠️ Partial | ARCH-005 and ARCH-017 still missing rows that should mirror their collaborators (PRF-ARCH-001, PRF-ARCH-004). ARCH-006 and ARCH-014 contracts now consistent and complete after Pass-D remediation. |
| **SYS Traceability** | ✅ Pass | Forward coverage 14/14 against active SYS set; cross-cutting modules properly tagged. |
| **Interaction Diagrams** | ✅ Pass | Three Mermaid sequence diagrams (Plan, Implementation, Tasks) present and now consistent with ARCH-006's Pass-D clarification. |
| **Error Handling Coverage** | ⚠️ Partial | Most exceptions named in the Interface View (ARCH-014's spec now complete after Pass D); Data Flow View still shows happy paths only (PRF-ARCH-003). |

## Pass-2 Remediation Verification

| Pass-2 Finding | Pass-2 Severity | Outcome in This Artifact (Pass 3) | New PRF (if any) |
|----------------|-----------------|-----------------------------------|------------------|
| Pass-2 PRF-ARCH-001 (ARCH-006 IOError contradicts pipeline write order) | Major | **Fixed (Pass D, commit cd24f25)** — ARCH-006's IOError row reworded to make explicit that ARCH-006 never writes; exception is raised by ARCH-021 in Stage 7 after ARCH-009 returns `valid:true`. Now consistent with the Implementation Pipeline diagram and Data Flow Stages 6→7. | — |
| Pass-2 PRF-ARCH-002 (ARCH-014 missing exception specification) | Major | **Fixed (Pass D, commit cd24f25)** — ARCH-014 now declares `UpstreamParseError` (fail-closed on structural parse failure) and an Error-recovery row stating metadata absence is fail-open and yields `EnrichmentReport{enriched:false}`. Failure-mode partition is correct. | — |
| Pass-2 PRF-ARCH-003 (ARCH-005 asymmetric with ARCH-006 on IOError) | Minor | **Not addressed** — ARCH-005 still declares only `RegionConflict`; the now-canonical IOError-from-ARCH-021 row was added only to ARCH-006. Re-flagged as PRF-ARCH-001 here. | PRF-ARCH-001 |
| Pass-2 PRF-ARCH-004 (ARCH-013 hard-coded line-number reference) | Minor | **Not addressed** — line 336 still contains `See ARCH-001 sequence (line 226)`. Re-flagged as PRF-ARCH-002 here. | PRF-ARCH-002 |
| Pass-2 PRF-ARCH-005 (Data Flow View happy-paths only) | Minor | **Not addressed** — both Data Flow tables remain success-only. The new Pass-D exceptions on ARCH-006 / ARCH-014 are not reflected in the data-flow tabular form. Re-flagged as PRF-ARCH-003 here. | PRF-ARCH-003 |
| Pass-2 PRF-ARCH-006 (ARCH-017 missing SubprocessFailure exception row) | Minor | **Not addressed** — ARCH-017 still has no Exception row despite delegating to ARCH-020. Re-flagged as PRF-ARCH-004 here. | PRF-ARCH-004 |
| Pass-2 PRF-ARCH-007 (cross-cutting rationale duplicated) | Observation | **Not addressed** — re-flagged as PRF-ARCH-005 here. | PRF-ARCH-005 |
| Pass-2 PRF-ARCH-008 (Coverage Summary not tied to CI validator) | Observation | **Not addressed** — re-flagged as PRF-ARCH-006 here. | PRF-ARCH-006 |
| Pass-2 PRF-ARCH-009 (Quality attribute trade-offs lack quantitative bounds) | Observation | **Not addressed** — re-flagged as PRF-ARCH-007 here. | PRF-ARCH-007 |

**Net effect of Pass D on this artifact:** both Pass-2 Majors (PRF-ARCH-001 IOError write-order contradiction; PRF-ARCH-002 ARCH-014 missing exception spec) are CLOSED. The four Pass-2 Minors and three Pass-2 Observations carry forward unchanged and are renumbered as PRF-ARCH-001 through PRF-ARCH-007 for this pass. Total finding count drops from 9 → 7; severity profile improves from `0 / 2 / 4 / 3` to `0 / 0 / 4 / 3`; CI exit code drops from 1 (Major present) to 2 (Minors only).

## Summary of Required Actions

**Critical:** None.

**Major:** None.

**Minor (should fix):**
1. **PRF-ARCH-001** — Mirror ARCH-006's clarified IOError-from-ARCH-021 row onto ARCH-005 so the two emitter contracts are symmetric.
2. **PRF-ARCH-002** — Replace the hard-coded `(line 226)` reference in ARCH-013 with a structural anchor.
3. **PRF-ARCH-003** — Add an "Error and Abort Paths" Data Flow sub-section reflecting all documented exceptions (including the new Pass-D additions on ARCH-006 / ARCH-014).
4. **PRF-ARCH-004** — Add a `SubprocessFailure` exception row (or fail-closed coercion note) to ARCH-017, mirroring ARCH-007's treatment.

**Observations (optional):**
1. **PRF-ARCH-005** — Consolidate cross-cutting rationale to a single canonical site.
2. **PRF-ARCH-006** — Tie the Coverage Summary counts to `validate-architecture-coverage.sh`.
3. **PRF-ARCH-007** — Append quantitative bounds (or an explicit "no bound established" note) to each Quality Attribute Justification row.

## Recommendation

**Approve with Minor follow-ups**: Pass D successfully closed both Pass-2 Majors with surgical edits — ARCH-006's IOError row now sits consistently with the Implementation Pipeline diagram and Data Flow View (the propagation-only narrative is correct), and ARCH-014's new exception specification correctly partitions fail-closed (structural parse failure → `UpstreamParseError`) from fail-open (metadata absence → `EnrichmentReport{enriched:false}`, NOT an error). The artifact no longer carries any blocking defects.

The four remaining Minor findings are all consistency/completeness items that have persisted across multiple passes and are now the most cost-effective candidates for a Pass-E sweep. None of them block release; CI exit code is 2 (warning, not blocking).

**Next Steps:**
1. Address the four Minor findings as a single small Pass-E edit — they are clustered in the Interface View and Data Flow View and cross-reference each other (PRF-ARCH-001 and PRF-ARCH-003 in particular share the IOError propagation theme).
2. Defer the three Observations to a maintenance pass unless an audit deadline forces them sooner.

---

**Peer Review Exit Criteria:** Per IEEE 1028:2008 §5.5.4, this review exits with **Minor findings only — rework optional, advisory** (CI exit code 2).
