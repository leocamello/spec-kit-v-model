# Peer Review — module-design.md

**Reviewer**: AI Peer Review (spec-kit V-Model)
**Date**: 2026-04-28
**Artifact**: module-design.md (27 MOD entries — 27 active, 0 deprecated, 0 suspect)
**Standard**: IEEE 1016:2009 + ISO/IEC/IEEE 12207:2017 §8.4.4 (Technical Review per IEEE 1028:2008 §5)

## Summary

| Severity | Count |
|----------|-------|
| Critical | 0 |
| Major | 0 |
| Minor | 4 |
| Observation | 1 |
| **Total Findings** | **5** |

## Findings

### PRF-MOD-001 — MOD-003 hybrid-path control flow does not branch on `enrichment_report.enriched` — reduced-enrichment fallback (ARCH-014) is undocumented in the algorithm

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | MOD-003, Algorithmic / Logic View (lines 242–249) |
| **Description** | Line 246 invokes `MOD-019.detect_enrichment(upstream_plan)` and stores the result in `enrichment_report`, then line 249 passes that value to `MOD-004.build_tdd_task_list(...)`. However, the pseudocode never branches on `enrichment_report.enriched` and never describes what the reduced-enrichment path actually does differently — it just hands the report to the next callee. The architecture contract (ARCH-014, Reduced-Enrichment Fallback) explicitly specifies that the hybrid path "falls back to populating downstream traceability from the V-Model artifact set directly". That fallback decision is not represented in the MOD-003 algorithm. This was raised as PRF-MOD-002 in pass 1 and as PRF-MOD-002 in pass 2; the Pass-D commit (cd24f25) only addressed the MOD-005 state diagram and did not touch lines 242–249. Defect type: **Incomplete**. |
| **Recommendation** | After line 246, add an explicit branch: `IF enrichment_report IS NOT NULL AND NOT enrichment_report.enriched: log_warning(f"Reduced-enrichment path — upstream lacks {enrichment_report.missing_metadata_keys}")`. Alternatively, document the contract on `MOD-004` (which is where the actual fallback logic lives per ARCH-014) and state in MOD-003's algorithmic view that the report is opaque transport. Either resolution closes the open contract gap. |

### PRF-MOD-002 — MOD-004 declares `enrichment_report` parameter but the algorithm body never references it — dead parameter or undocumented branch

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | MOD-004, Algorithmic / Logic View (lines 332–348) |
| **Description** | The signature on lines 332–335 is `build_tdd_task_list(artifact_set: ArtifactSet, enrichment_report: EnrichmentReport \| None) -> list[Task]`. The body (lines 336–348) iterates over `artifact_set.module_design.modules`, the four test artifacts, and never reads `enrichment_report` once. Either (a) the parameter is dead and should be removed (which would then require MOD-003 to drop it from the call site at line 249), or (b) the parameter is supposed to drive a behavioural variant per ARCH-014 (Reduced-Enrichment Fallback) and the variant is missing. Combined with PRF-MOD-001 above, this is the same contract gap surfacing from two angles. Pass-2 raised this as PRF-MOD-003; the Pass-D commit did not touch MOD-004. Defect type: **Inconsistent** (between signature and body) / **Incomplete** (if behavioural variant is intended). |
| **Recommendation** | Resolve in tandem with PRF-MOD-001. Either: (i) remove the parameter from MOD-004 and drop it from the MOD-003 call, documenting that hybrid-path detection lives only in MOD-003's logging; or (ii) add an explicit branch in MOD-004's body, e.g. `IF enrichment_report IS NULL OR enrichment_report.enriched: derive parents from artifact_set; ELSE: derive parents directly from upstream V-Model artifact set per ARCH-014`. |

### PRF-MOD-003 — MOD-010 internal-data structure documents matrix key `H` that is never written; line 676 contains a no-op statement

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | MOD-010, Algorithmic / Logic View (lines 662–677) and Internal Data Structures (line 698) |
| **Description** | Two related defects in MOD-010 persist after the Pass-D commit (which only touched MOD-005): (1) The Internal Data Structures table on line 698 declares `matrices: dict[str, float] — ≤ 5 keys (A, B, C, D, H)`, but the `SCRIPTS` table on lines 662–669 only contains keys `A`, `B`, `C`, and `D` — the `H` (hazard) matrix is never assigned anywhere in the algorithm. (2) Line 676 reads `matrices[matrix_key] = max(matrices.get(matrix_key, 0), 0)` — since coverage percentages are non-negative and the default returned by `.get(..., 0)` is itself 0, this expression is **always equal to** `matrices.get(matrix_key, 0)` and is immediately overwritten by the `min(...)` on line 677. It is dead code. Defect types: **Inconsistent** (table vs. algorithm) and **Superfluous** (line 676). |
| **Recommendation** | (1) Either add a hazard-coverage script invocation to `SCRIPTS` (e.g., `("H", "scripts/bash/validate-hazard-coverage.sh", [feature_dir/"v-model"])`) or remove the `H` reference from the data-structure table — currently the table over-specifies the key set. (2) Delete line 676 entirely; the `min(...)` on line 677 is sufficient and correct because `.get(..., 100)` already supplies the upper-bound default. |

### PRF-MOD-004 — MOD-010 error-handling row understates the fail-closed mechanism: "convert exception to passed=false" is true at the outcome level but the intermediate `matrices[matrix_key] = 0` step is implicit

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | MOD-010, Error Handling & Return Codes table (line 705) |
| **Description** | The pseudocode on lines 680–683 catches `SubprocessFailure`, sets `matrices[matrix_key] = 0`, and appends a gap line. The `passed` flag on line 685 then evaluates `ALL(pct == 100 FOR pct IN matrices.values())` — which is `false` because `matrices[matrix_key] == 0`. The Error Handling row (line 705) summarises this as "catch + convert to `passed=false`", which is correct at the contract level but does not name the mechanism (the explicit `0` assignment) that achieves it. Pass 1 raised this as PRF-MOD-003; pass 2 re-raised it as PRF-MOD-005; the Pass-D commit did not modify MOD-010. Defect type: **Ambiguous** (description leaves mechanism implicit). |
| **Recommendation** | Rephrase line 705's Recovery cell to: `Set matrices[matrix_key] = 0 (which forces the final passed flag to false via the ALL-equals-100 invariant); append failure text to gap_report; do NOT re-raise.` This makes the mechanism explicit and aligns the prose with the pseudocode without adding new behaviour. |

### PRF-MOD-005 — MOD-022 references undefined helper `parse_coverage_pct(run.stdout)` — algorithmic view depends on an unspecified parser

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Location** | MOD-022, Algorithmic / Logic View (line 1251) |
| **Description** | Line 1251 invokes `pct = parse_coverage_pct(run.stdout)` for each of the four harnesses (`bats`, `pester`, `structural_eval`, `llm_eval`). Each harness emits a different stdout shape — BATS JSON, Pester `-PassThru` object dump, the two `--json` eval scripts. The pseudocode does not specify how `parse_coverage_pct` reconciles those four shapes into a single percentage, nor is the helper documented elsewhere in module-design.md. Compare to MOD-010 (line 674), which uses `parse_json` then explicitly reads `payload.get("coverage_pct", ...)` — that pattern is fully specified. Pass-2 raised this as PRF-MOD-006; the Pass-D commit did not modify MOD-022. Defect type: **Incomplete** (helper unspecified) — Observation severity because the harness contracts are external and the helper is a reasonable abstraction at this design level. |
| **Recommendation** | Either inline the per-harness shape (e.g., `IF name == "bats": pct = parse_bats_summary(run.stdout); ELIF name == "pester": pct = parse_pester_summary(run.stdout); ELSE: pct = parse_json(run.stdout).get("coverage_pct", 0)`), or add a brief Internal Data Structures entry describing `parse_coverage_pct`'s contract (input shape per harness, return type, error behaviour). No functional change required. |

## Coverage Summary

| Metric | Result |
|--------|--------|
| **Total Module Designs (MOD)** | 27 (27 active, 0 deprecated, 0 suspect) |
| **Lifecycle Status** | All 27 active; no deprecation or suspect tags present |
| **Cross-Cutting Modules** | 4 (MOD-024, MOD-025, MOD-026, MOD-027) — correctly tagged `[CROSS-CUTTING]` in headings and Module Map |
| **Stateful Modules** | 3 (MOD-001, MOD-003, MOD-005) — all carry state diagrams with `REPORT`-state convergence on terminal paths |
| **Stateless Modules** | 24 — correctly marked "N/A — Stateless" |
| **4 Mandatory Views Present** | Algorithmic/Logic ✓, State Machine (where applicable) ✓, Internal Data Structures ✓, Error Handling ✓ — all 27/27 |
| **Algorithm Specifications** | 27/27 expressed in pseudocode ✓ |
| **Error Handling Definitions** | 27/27 present ✓ |
| **ARCH Traceability (MOD → ARCH)** | 27/27 active MODs trace to ≥1 ARCH; 21/21 ARCHs covered by ≥1 MOD; 100% bidirectional active coverage |
| **Module Map (Summary Index)** | Complete and accurate (lines 44–74) |

## Pass-2 Remediation Audit

| Pass-2 Finding | Severity | Status in Pass 3 | Notes |
|----------------|----------|------------------|-------|
| PRF-MOD-001 (MOD-005 state diagram terminates `[*]` directly) | Major | **FIXED** | Pass-D commit cd24f25 inserted `COMMIT --> REPORT`, `FAIL --> REPORT`, `REPORT --> [*]` (lines 443–445) and added the explanatory blockquote (lines 448–450). MOD-005 now mirrors the MOD-001 / MOD-003 pattern. Verified directly against current state diagram. |
| PRF-MOD-002 (MOD-003 reduced-enrichment branch) | Minor | **NOT FIXED — re-raised as PRF-MOD-001** | Pass-D commit out of scope (state-diagram-only); lines 242–249 unchanged. |
| PRF-MOD-003 (MOD-004 dead `enrichment_report` parameter) | Minor | **NOT FIXED — re-raised as PRF-MOD-002** | Pass-D commit out of scope; lines 332–348 unchanged. |
| PRF-MOD-004 (MOD-010 unused matrix key `H` + dead `max(...)` line) | Minor | **NOT FIXED — re-raised as PRF-MOD-003** | Pass-D commit out of scope; lines 676 & 698 unchanged. |
| PRF-MOD-005 (MOD-010 fail-closed wording) | Minor | **NOT FIXED — re-raised as PRF-MOD-004** | Pass-D commit out of scope; line 705 unchanged. |
| PRF-MOD-006 (MOD-022 unspecified `parse_coverage_pct` helper) | Observation | **NOT FIXED — re-raised as PRF-MOD-005** | Pass-D commit out of scope; line 1251 unchanged. |

> **Pass-3 delta:** Pass-2 Major (PRF-MOD-001) is **closed**. The four Pass-2 Minors and the single Pass-2 Observation persist (Pass-D commit was scoped exclusively to the MOD-005 state diagram, as documented). No new defects surfaced — header counts shrink from 1 Major / 4 Minor / 1 Observation (6 total) to 0 Major / 4 Minor / 1 Observation (5 total).

## Lifecycle Validation (§4.10)

- **Deprecation syntax**: No `[DEPRECATED]` items present — pass.
- **Unresolved suspects**: No `[SUSPECT]` items present — pass.
- **Coverage exclusion**: N/A — no deprecated items to exclude.
- **Orphaned deprecation chains**: N/A — no deprecated parents.

## Governance Notes

- **IEEE 1016 Compliance**: All 4 mandatory views populated for every active MOD. State-machine completeness (§5.2.3) restored across all three orchestrators (MOD-001, MOD-003, MOD-005) — every terminal path now flows through `REPORT` before reaching `[*]`.
- **ISO/IEC/IEEE 12207:2017 §8.4.4 Compliance**: Formal interfaces (Parent ARCH, Target Source File, Implements REQ list) present on every MOD; algorithmic logic in pseudocode; state machines confined to stateful orchestrators (correct).
- **Domain Overlay**: No `v-model-config.yml` configured; MISRA / Memory Management / Single-Entry-Single-Exit safety-critical sections correctly omitted (declared in Overview lines 32–35).
- **Review Type Applied**: Technical Review (IEEE 1028:2008 §5).
- **Defect Taxonomy**: Per ISO/IEC 20246:2017 §6.3 — 1× Incomplete (PRF-MOD-001), 1× Inconsistent/Incomplete (PRF-MOD-002), 1× Inconsistent + Superfluous (PRF-MOD-003), 1× Ambiguous (PRF-MOD-004), 1× Incomplete-Observation (PRF-MOD-005).

## CI Exit Code

```
EXIT_CODE = 2 (4 Minor findings present; no Critical/Major — warning, does not block PR)
```

**Next Step**: Address the four remaining Minor findings — PRF-MOD-001 and PRF-MOD-002 share a root cause (the hybrid-path contract for `enrichment_report`) and should be resolved together; PRF-MOD-003 and PRF-MOD-004 are independent MOD-010 cleanups. PRF-MOD-005 is advisory only. Re-run `/speckit.v-model.peer-review module-design.md` after fixes; expect all PRF-MOD findings to disappear.

---

**End of Review**
