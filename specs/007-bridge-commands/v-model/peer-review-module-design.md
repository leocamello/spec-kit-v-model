# Peer Review — module-design.md

**Reviewer**: AI Peer Review (spec-kit V-Model)
**Date**: 2026-04-27
**Artifact**: module-design.md (27 MOD entries — 27 active, 0 deprecated, 0 suspect)
**Standard**: IEEE 1016:2009 + ISO/IEC/IEEE 12207:2017 §8.4.4 (Technical Review per IEEE 1028:2008 §5)

## Summary

| Severity | Count |
|----------|-------|
| Critical | 0 |
| Major | 1 |
| Minor | 4 |
| Observation | 1 |
| **Total Findings** | **6** |

## Findings

### PRF-MOD-001 — MOD-005 state diagram terminates to `[*]` directly, contradicting pseudocode that always calls `MOD-021.emit_summary` on both success and failure paths

| Field | Value |
|-------|-------|
| **Severity** | Major |
| **Location** | MOD-005, State Machine View (lines 430–445) |
| **Description** | The MOD-005 pseudocode (lines 416, 420, 424) invokes `MOD-021.emit_summary(summary)` *before* every return — both on the success path after `COMMIT` and on every `FAIL` exit (RegionConflict, OverlayParseError, gate failure, hallucination). The accompanying state diagram, however, shows `COMMIT --> [*]` (line 443) and `FAIL --> [*]` (line 444) with **no `REPORT` state** in between. This is the **identical defect** that pass 1 flagged in MOD-003 (PRF-MOD-001) and which has since been fixed there (lines 296–303 now route both terminal paths through `REPORT`). MOD-005 was not updated in pass A/B/C, so the implementation orchestrator's diagram still violates IEEE 1016 §5.2.3 (state-machine completeness) and is now inconsistent with the corrected MOD-001 / MOD-003 patterns. Defect type: **Inconsistent**. |
| **Recommendation** | Update the MOD-005 state diagram to insert a `REPORT` state and route both terminal paths through it, mirroring the now-correct MOD-001 (lines 133–145) and MOD-003 (lines 284–298) patterns. Concretely, replace `COMMIT --> [*]` and `FAIL --> [*]` with `COMMIT --> REPORT`, `FAIL --> REPORT`, `REPORT --> [*]`, and add the same explanatory blockquote ("Both terminal paths flow through REPORT so the structured stdout summary is always emitted — matching the MOD-001 pattern."). |

### PRF-MOD-002 — MOD-003 hybrid-path control flow does not branch on `enrichment_report.enriched` — reduced-enrichment fallback (ARCH-014) is undocumented in the algorithm

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | MOD-003, Algorithmic / Logic View (lines 242–249) |
| **Description** | Line 246 invokes `MOD-019.detect_enrichment(upstream_plan)` and stores the result in `enrichment_report`, then line 249 passes that value to `MOD-004.build_tdd_task_list(...)`. However, the pseudocode never branches on `enrichment_report.enriched` and never describes what the reduced-enrichment path actually does differently — it just hands the report to the next callee. The architecture contract (ARCH-014, Reduced-Enrichment Fallback) explicitly specifies that the hybrid path "falls back to populating downstream traceability from the V-Model artifact set directly". That fallback decision is not represented in the MOD-003 algorithm. This was raised as PRF-MOD-002 in pass 1 and is **not addressed** in the pass A/B/C diff (which only altered the FAIL transition label). Defect type: **Incomplete**. |
| **Recommendation** | After line 246, add an explicit branch: `IF enrichment_report IS NOT NULL AND NOT enrichment_report.enriched: log_warning(f"Reduced-enrichment path — upstream lacks {enrichment_report.missing_metadata_keys}")`. Alternatively, document the contract on `MOD-004` (which is where the actual fallback logic lives per ARCH-014) and state in MOD-003's algorithmic view that the report is opaque transport. Either resolution closes the open contract gap. |

### PRF-MOD-003 — MOD-004 declares `enrichment_report` parameter but the algorithm body never references it — dead parameter or undocumented branch

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | MOD-004, Algorithmic / Logic View (lines 332–348) |
| **Description** | The signature on lines 332–335 is `build_tdd_task_list(artifact_set: ArtifactSet, enrichment_report: EnrichmentReport \| None) -> list[Task]`. The body (lines 336–348) iterates over `artifact_set.module_design.modules`, the four test artifacts, and never reads `enrichment_report` once. Either (a) the parameter is dead and should be removed (which would then require MOD-003 to drop it from the call site at line 249), or (b) the parameter is supposed to drive a behavioural variant per ARCH-014 (Reduced-Enrichment Fallback) and the variant is missing. Combined with PRF-MOD-002 above, this is the same contract gap surfacing from two angles. Defect type: **Inconsistent** (between signature and body) / **Incomplete** (if behavioural variant is intended). |
| **Recommendation** | Resolve in tandem with PRF-MOD-002. Either: (i) remove the parameter from MOD-004 and drop it from the MOD-003 call, documenting that hybrid-path detection lives only in MOD-003's logging; or (ii) add an explicit branch in MOD-004's body, e.g. `IF enrichment_report IS NULL OR enrichment_report.enriched: derive parents from artifact_set; ELSE: derive parents directly from upstream V-Model artifact set per ARCH-014`. |

### PRF-MOD-004 — MOD-010 internal-data structure documents matrix key `H` that is never written; line 671 contains a no-op statement

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | MOD-010, Algorithmic / Logic View (lines 657–671) and Internal Data Structures (line 693) |
| **Description** | Two related defects in MOD-010: (1) The Internal Data Structures table on line 693 declares `matrices: dict[str, float] — ≤ 5 keys (A, B, C, D, H)`, but the `SCRIPTS` table on lines 657–664 only contains keys `A`, `B`, `C`, and `D` — the `H` (hazard) matrix is never assigned anywhere in the algorithm. (2) Line 671 reads `matrices[matrix_key] = max(matrices.get(matrix_key, 0), 0)` — since coverage percentages are non-negative and the default returned by `.get(..., 0)` is itself 0, this expression is **always equal to** `matrices.get(matrix_key, 0)` and is immediately overwritten by the `min(...)` on line 672. It is dead code. Defect types: **Inconsistent** (table vs. algorithm) and **Superfluous** (line 671). |
| **Recommendation** | (1) Either add a hazard-coverage script invocation to `SCRIPTS` (e.g., `("H", "scripts/bash/validate-hazard-coverage.sh", [feature_dir/"v-model"])`) or remove the `H` reference from the data-structure table — currently the table over-specifies the key set. (2) Delete line 671 entirely; the `min(...)` on line 672 is sufficient and correct because `.get(..., 100)` already supplies the upper-bound default. |

### PRF-MOD-005 — MOD-010 error-handling row understates the fail-closed mechanism: "convert exception to passed=false" is true at the outcome level but the intermediate `matrices[matrix_key] = 0` step is implicit

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | MOD-010, Error Handling & Return Codes table (line 700) |
| **Description** | The pseudocode on lines 675–678 catches `SubprocessFailure`, sets `matrices[matrix_key] = 0`, and appends a gap line. The `passed` flag on line 680 then evaluates `ALL(pct == 100 FOR pct IN matrices.values())` — which is `false` because `matrices[matrix_key] == 0`. The Error Handling row (line 700) summarises this as "catch + convert to `passed=false`", which is correct at the contract level but does not name the mechanism (the explicit `0` assignment) that achieves it. Pass 1 raised this as PRF-MOD-003; the pass A/B/C diff did not modify MOD-010. Defect type: **Ambiguous** (description leaves mechanism implicit). |
| **Recommendation** | Rephrase line 700's Recovery cell to: `Set matrices[matrix_key] = 0 (which forces the final passed flag to false via the ALL-equals-100 invariant); append failure text to gap_report; do NOT re-raise.` This makes the mechanism explicit and aligns the prose with the pseudocode without adding new behaviour. |

### PRF-MOD-006 — MOD-022 references undefined helper `parse_coverage_pct(run.stdout)` — algorithmic view depends on an unspecified parser

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Location** | MOD-022, Algorithmic / Logic View (line 1246) |
| **Description** | Line 1246 invokes `pct = parse_coverage_pct(run.stdout)` for each of the four harnesses (`bats`, `pester`, `structural_eval`, `llm_eval`). Each harness emits a different stdout shape — BATS JSON, Pester `-PassThru` object dump, the two `--json` eval scripts. The pseudocode does not specify how `parse_coverage_pct` reconciles those four shapes into a single percentage, nor is the helper documented elsewhere in module-design.md. Compare to MOD-010 (line 669), which uses `parse_json` then explicitly reads `payload.get("coverage_pct", ...)` — that pattern is fully specified. Defect type: **Incomplete** (helper unspecified) — Observation severity because the harness contracts are external and the helper is a reasonable abstraction at this design level. |
| **Recommendation** | Either inline the per-harness shape (e.g., `IF name == "bats": pct = parse_bats_summary(run.stdout); ELIF name == "pester": pct = parse_pester_summary(run.stdout); ELSE: pct = parse_json(run.stdout).get("coverage_pct", 0)`), or add a brief Internal Data Structures entry describing `parse_coverage_pct`'s contract (input shape per harness, return type, error behaviour). No functional change required. |

## Coverage Summary

| Metric | Result |
|--------|--------|
| **Total Module Designs (MOD)** | 27 (27 active, 0 deprecated, 0 suspect) |
| **Lifecycle Status** | All 27 active; no deprecation or suspect tags present |
| **Cross-Cutting Modules** | 4 (MOD-024, MOD-025, MOD-026, MOD-027) — correctly tagged `[CROSS-CUTTING]` in headings and Module Map |
| **Stateful Modules** | 3 (MOD-001, MOD-003, MOD-005) — all carry state diagrams |
| **Stateless Modules** | 24 — correctly marked "N/A — Stateless" |
| **4 Mandatory Views Present** | Algorithmic/Logic ✓, State Machine (where applicable) ✓, Internal Data Structures ✓, Error Handling ✓ — all 27/27 |
| **Algorithm Specifications** | 27/27 expressed in pseudocode ✓ |
| **Error Handling Definitions** | 27/27 present ✓ |
| **ARCH Traceability (MOD → ARCH)** | 27/27 active MODs trace to ≥1 ARCH; 21/21 ARCHs covered by ≥1 MOD; 100% bidirectional active coverage |
| **Module Map (Summary Index)** | Complete and accurate (lines 44–74) |

## Pass-1 Remediation Audit

| Pass-1 Finding | Severity | Status in Pass 2 | Notes |
|----------------|----------|------------------|-------|
| PRF-MOD-001 (MOD-003 FAIL→[*]) | Major | **FIXED** | Diff at lines 296–298 now routes `WRITE → REPORT`, `FAIL → REPORT`, `REPORT → [*]`; explanatory blockquote added at lines 301–303. Verified against current state diagram. |
| PRF-MOD-002 (MOD-003 reduced-enrichment ambiguity) | Minor | **NOT FIXED — re-raised as PRF-MOD-002** | Pass A/B/C diff did not touch lines 242–249. |
| PRF-MOD-003 (MOD-010 fail-closed wording) | Minor | **NOT FIXED — re-raised as PRF-MOD-005** | Pass A/B/C diff did not touch line 700. |
| PRF-MOD-004 (Cross-cutting parent labelling) | Observation | **No action needed (was advisory)** | Convention remains correct and consistent with architecture-design.md. |

> **New defects surfaced in pass 2:** PRF-MOD-001 (Major — MOD-005 state diagram is now the only orchestrator that does not route terminal paths through REPORT, exposing the inconsistency that was hidden when MOD-003 had the same defect), PRF-MOD-003 (Minor — MOD-004 dead `enrichment_report` parameter), PRF-MOD-004 (Minor — MOD-010 unused matrix key `H` and dead `max(...)` line), PRF-MOD-006 (Observation — MOD-022 unspecified `parse_coverage_pct` helper).

## Lifecycle Validation (§4.10)

- **Deprecation syntax**: No `[DEPRECATED]` items present — pass.
- **Unresolved suspects**: No `[SUSPECT]` items present — pass.
- **Coverage exclusion**: N/A — no deprecated items to exclude.
- **Orphaned deprecation chains**: N/A — no deprecated parents.

## Governance Notes

- **IEEE 1016 Compliance**: All 4 mandatory views populated for every active MOD.
- **ISO/IEC/IEEE 12207:2017 §8.4.4 Compliance**: Formal interfaces (Parent ARCH, Target Source File, Implements REQ list) present on every MOD; algorithmic logic in pseudocode; state machines confined to stateful orchestrators (correct).
- **Domain Overlay**: No `v-model-config.yml` configured; MISRA / Memory Management / Single-Entry-Single-Exit safety-critical sections correctly omitted (declared in Overview lines 32–35).
- **Review Type Applied**: Technical Review (IEEE 1028:2008 §5).
- **Defect Taxonomy**: Per ISO/IEC 20246:2017 §6.3 — 1× Inconsistent (PRF-MOD-001), 1× Incomplete (PRF-MOD-002), 1× Inconsistent/Incomplete (PRF-MOD-003), 1× Inconsistent + Superfluous (PRF-MOD-004), 1× Ambiguous (PRF-MOD-005), 1× Incomplete-Observation (PRF-MOD-006).

## CI Exit Code

```
EXIT_CODE = 1 (1 Major finding present; blocks PR approval)
```

**Next Step**: Fix PRF-MOD-001 (mirror the MOD-003 REPORT-state pattern into MOD-005). Then address the four Minor findings — note that PRF-MOD-002 and PRF-MOD-003 share a root cause (the hybrid-path contract for `enrichment_report`) and should be resolved together. Re-run `/speckit.v-model.peer-review module-design.md` after fixes; expect all PRF-MOD findings to disappear.

---

**End of Review**
