# Peer Review — hazard-analysis.md

**Reviewer**: AI Peer Review (spec-kit V-Model)
**Date**: 2026-04-27
**Artifact**: hazard-analysis.md (25 HAZ active, 0 deprecated, 0 suspect — 22 system-level + 3 architecture-level progressive-deepening)
**Standard**: IEC 60812:2018 + ISO 14971:2019 — Inspection class (IEEE 1028:2008 §4)

## Summary

| Severity | Count |
|----------|-------|
| Critical | 0 |
| Major | 0 |
| Minor | 1 |
| Observation | 3 |
| **Total Findings** | **4** |

## Findings

### PRF-HAZ-001 — Likelihood Justification Table Excludes the Sole Serious/Occasional Hazard

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | § "Likelihood Justification" (preamble + table); HAZ-007 (Serious / Occasional / Undesirable) |
| **Description** | The new "Likelihood Justification" section (added in Pass A/B/C remediation for old PRF-HAZ-004) is scoped — both in its preamble ("seven Serious-classified hazards rated Remote") and in its table — to Serious/Remote pairings only. HAZ-007 is the *only* Serious hazard in the register that is rated **Occasional** rather than Remote, and its initial Risk Level is consequently **Undesirable** — the highest pre-mitigation risk class held by any Serious entry. ISO 14971 §5.4 requires every Severity/Likelihood pairing to be justified, and IEC 60812 §6 makes the same requirement for FMEA. The HAZ-007 row asserts "Occasional" without a likelihood rationale anywhere in the artifact. The Residual Risk Justification row for HAZ-007 explains the *post-mitigation* reasoning (regex parser correctness, UTP-006 coverage) but not why the *pre-mitigation* likelihood is Occasional in the first place. Defect type (ISO/IEC 20246 §6.3): **Incomplete** — the justification analysis is partially specified. |
| **Recommendation** | Either (a) broaden the Likelihood Justification preamble and table to include HAZ-007 with explicit reasoning (e.g., "LLM-generated `// Implements <ID>` comments inherit the underlying model's hallucination base-rate, which empirical literature places in the 1–5 % range per generated identifier — placing the failure mode in the Occasional band by construction; this rating is the design driver for SYS-006"), or (b) add the rationale inline in the HAZ-007 row (additional sentence in the Effect column or a new "Likelihood Rationale" column applied just to HAZ-007). Option (a) is preferred for symmetry with the existing seven Serious/Remote entries. |

### PRF-HAZ-002 — HAZ-008 / HAZ-014 State Scoping to COMMITTING Only Lacks Documented Rationale

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Location** | HAZ-008 (Idempotency failure, COMMITTING); HAZ-014 (Region-marker corruption, COMMITTING); cross-reference to system-design.md § "Operational States" State Definitions |
| **Description** | Per the system-design State Definitions table (lines 178–181), the DRY-RUN state activates SYS-003, SYS-006, **SYS-007**, and SYS-012. SYS-007 (Source Region Manager) — the component named in HAZ-014's mitigation and implicit in HAZ-008's idempotency contract — is therefore active in both DRY-RUN and COMMITTING. Yet HAZ-008 ("re-run regenerates source code with <95% structural identity") and HAZ-014 ("region-marker corruption: user-authored content overwritten") are both tagged **COMMITTING** only. The defensible argument is that DRY-RUN writes go to a temp scratch path (per the State Definitions: "Files under repo working tree may be touched only when emitted to a temp scratch path") so user code cannot be silently overwritten and idempotency churn cannot manifest as user-visible review noise. This rationale is correct but is not documented anywhere in hazard-analysis.md. An auditor reading the artifact in isolation would have to infer the scoping from the state definitions. Defect type: **Incomplete**. |
| **Recommendation** | Add a short rationale either (a) as an inline note under the Operational States Reference table (e.g., "HAZ-008 / HAZ-014 are scoped to COMMITTING because SYS-007's DRY-RUN scratch-path writes do not touch the working tree and therefore cannot manifest as user-visible churn or content loss"), or (b) as parenthetical clarifications in the Operational State column of those two rows (e.g., "COMMITTING (DRY-RUN excluded — scratch-path writes only)"). |

### PRF-HAZ-003 — Residual Risk Justification for HAZ-022 Treats "Occasional" Likelihood as a Permanent Property

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Location** | HAZ-022 row in Hazard Register; Residual Risk Justification row for HAZ-022 |
| **Description** | HAZ-022 is the only Minor/**Occasional** entry in the register (initial Risk = Tolerable, residual Risk = Tolerable — i.e., mitigation does *not* reduce the risk class). The Residual Risk Justification row reads: "the commit-message-template logic is the most defect-prone code in v0.7.0; residual is held at Tolerable by the warning + fallback." This is a candid and useful disclosure, but it implicitly accepts the Occasional likelihood as a steady-state property of v0.7.0 rather than as a temporary condition warranting follow-up risk reduction. ISO 14971 §5.5 expects residual risk that is *not improved* by mitigation to either (a) carry an As-Low-As-Reasonably-Practicable (ALARP) statement or (b) trigger a documented risk-acceptance decision. Neither is present. Defect type: **Incomplete** (informational only — Tolerable residual is acceptable per the project's risk matrix without sign-off). |
| **Recommendation** | Add a one-sentence ALARP statement to the HAZ-022 residual-risk row, e.g.: "Residual Tolerable is accepted As-Low-As-Reasonably-Practicable: the only further reduction would be to harden the commit-message-template logic (not in v0.7.0 scope); the SYS-012 warning + REQ-021 in-file fallback render the audit gap recoverable." Optionally, raise a follow-up issue to refactor the template logic in a future release and link it from this row. |

### PRF-HAZ-004 — Operational State Distribution Table Could Cross-Reference State Definitions

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Location** | § "Coverage Summary" → "Operational State Distribution" table |
| **Description** | The Operational State Distribution table (NORMAL=15, DRY-RUN=2, COMMITTING=8, ERROR=2 — total 27 due to dual-tagging of HAZ-006/007) is correct and the dual-tagging note is helpful. However, the table lists state *counts* without listing *which* HAZs fall into each state. This makes the per-state coverage non-auditable from this section alone — an auditor must scan the full Hazard Register (lines 83–104) and the Progressive Deepening table (lines 116–118) and tally manually to verify the counts. Defect type: **Incomplete** (informational). |
| **Recommendation** | Append a column (or sub-rows) to the Operational State Distribution table listing the HAZ IDs per state, e.g.: "NORMAL — HAZ-001/002/003/004/005/009/010/011/015/016/017/018/019/021/024 (15)"; "DRY-RUN — HAZ-006/007 (2)"; "COMMITTING — HAZ-006/007/008/012/013/014/022/023 (8)"; "ERROR — HAZ-020/025 (2)". This makes the count line-of-sight verifiable and reduces auditor effort. |

---

## Verification Checklist (§4.8 + §4.10 Applied)

### §4.8 Hazard Analysis (FMEA — IEC 60812:2018 + ISO 14971:2019)

- ✅ **Severity Justification**: Implicit through Severity Scale + Risk Matrix; reasonable given failure modes. (Minor gap on HAZ-007 Likelihood — see PRF-HAZ-001.)
- ✅ **Mitigation Completeness**: Every HAZ has at least one REQ-NNN or SYS-NNN mitigation; HAZ-007 mitigation duplicate REQ-NF-002 fixed; REQ-023 added.
- ✅ **Operational State Coverage**: Authoritative state model now defined in `system-design.md § "Operational States (IEEE 1016 §5.2 Behavioural View)"`; every HAZ row carries an explicit Operational State; dual-state tagging (HAZ-006/007) handled correctly. (Minor scoping clarity gap — see PRF-HAZ-002.)
- ✅ **Residual Risk Assessment**: New "Residual Risk Justification" section provides per-hazard residual mechanism for all 25 HAZs. (One ALARP polish — see PRF-HAZ-003.)
- ✅ **SYS Coverage**: 14/14 active SYS components covered. SYS-001 (HAZ-001/002/003), SYS-002 (HAZ-004/005), SYS-003 (HAZ-006/007/008), SYS-004 (HAZ-009/010), SYS-005 (HAZ-011), SYS-006 (HAZ-012/013/023), SYS-007 (HAZ-014), SYS-008 (HAZ-015/024), SYS-009 (HAZ-016), SYS-010 (HAZ-017/018), SYS-011 (HAZ-019), SYS-012 (HAZ-020/025), SYS-013 (HAZ-021), SYS-014 (HAZ-022) — claim "14 / 14 (100%)" verified by enumeration.
- ✅ **Progressive Deepening**: New "Progressive Deepening Cross-References" table makes the architecture-level → system-level refinement relationships explicit (HAZ-023→HAZ-007/012; HAZ-024→HAZ-015; HAZ-025→HAZ-020).
- ✅ **Coverage Summary internal consistency**: Severity (Critical=8, Serious=8, Minor=9 → 25 ✓); Risk Level (Undesirable=9, Tolerable=8, Acceptable=8 → 25 ✓); Residual Risk (Tolerable=9, Acceptable=16 → 25 ✓); Operational State (15+2+8+2=27, matches 25 distinct + 2 dual-tagged HAZ ✓).

### §4.10 Lifecycle Validation

- ✅ **No Deprecated Items**: No HAZ marked `[DEPRECATED]`.
- ✅ **No Unresolved Suspects**: No HAZ tagged `[SUSPECT]`.
- ✅ **Coverage Exclusion**: No deprecated HAZ in coverage counts (none exist).
- ✅ **Mitigation references resolvable**: All mitigation cells reference REQ-NNN, REQ-NF-NNN, REQ-IF-NNN, REQ-CN-NNN, or SYS-NNN identifiers conforming to the canonical patterns; no phantom IDs in this artifact (REQ-999 audit, raised in Pass 1, was an impact-analysis concern outside this artifact's scope and is not present here).

---

## Delta vs Pass 1 (informational only — no bearing on current findings)

Pass 1 produced 3 Critical + 5 Major + 2 Minor + 0 Observation = 10 findings. The current artifact addresses every one of them:

| Old Finding | Old Severity | Status in Current Artifact |
|-------------|--------------|----------------------------|
| PRF-HAZ-001 (SYS-002/SYS-009 coverage gap) | Critical | **Resolved** — SYS-002 covered by HAZ-004/005, SYS-009 by HAZ-016, all 14 SYS verified by enumeration |
| PRF-HAZ-002 (REQ-999 phantom + duplicate REQ-NF-002) | Critical | **Resolved within scope** — HAZ-007 mitigation now reads "REQ-023, REQ-NF-002, SYS-006" (duplicate fixed, REQ-023 added); REQ-999 was an impact-analysis concern, out of scope here |
| PRF-HAZ-003 (Matrix H verification incomplete) | Critical | **Out of scope for hazard-analysis.md** — Matrix H verification belongs to traceability-matrix.md peer review |
| PRF-HAZ-004 (Severity justification for Serious/Remote) | Major | **Resolved** — new "Likelihood Justification" section covers all 7 Serious/Remote entries |
| PRF-HAZ-005 (Residual risk justification absent) | Major | **Resolved** — new "Residual Risk Justification" section covers all 25 HAZs |
| PRF-HAZ-006 (No operational-state analysis) | Major | **Resolved** — state model authoritative in system-design.md; every HAZ row tagged with state(s) |
| PRF-HAZ-007 (SYS-006 algorithm unspecified) | Major | **Resolved** — SYS-006 algorithm specification added to system-design.md; HAZ-012/013 mitigations now reference it |
| PRF-HAZ-008 (Unsupported-domain rationale missing) | Minor | **Resolved** — Coverage Summary blockquote documents fail-closed rationale via HAZ-015 + REQ-024 |
| PRF-HAZ-009 (HAZ-001 conflation) | Minor | **Resolved** — HAZ-001 description narrowed to logic/runtime failures with explicit exclusion of graceful missing-artifact case (REQ-008) |
| PRF-HAZ-010 (Implicit progressive-deepening links) | Observation | **Resolved** — new "Progressive Deepening Cross-References" section makes refinement relationships explicit |

New findings surfaced in Pass 2:

- PRF-HAZ-001 (Minor) — Likelihood Justification scope excludes the sole Serious/Occasional hazard (HAZ-007). Surfaced because the Pass-A/B/C remediation built the new section around the seven Serious/Remote entries explicitly, leaving HAZ-007 outside the scope despite holding the highest initial Risk Level among Serious entries.
- PRF-HAZ-002 (Observation) — HAZ-008/HAZ-014 COMMITTING-only state scoping is correct but undocumented. Surfaced now that the Operational State column is mandatory and auditors can compare per-HAZ state to the State Definitions table.
- PRF-HAZ-003 (Observation) — HAZ-022 lacks an ALARP statement for its no-improvement residual. Surfaced now that the Residual Risk Justification table makes the "no reduction" case visible (residual = initial = Tolerable).
- PRF-HAZ-004 (Observation) — Operational State Distribution table reports counts without HAZ enumeration. Surfaced now that the table exists and merits richer per-state visibility.

---

## Compliance Assessment

**Review Type** (IEEE 1028:2008): **Inspection** — high-risk artifact (`hazard-analysis.md`) where defect detection must be maximised; Inspection-class rigor applied per the Step 2.5 selection rule.

**Governing Standard**: IEC 60812:2018 (FMEA) + ISO 14971:2019 (risk matrix and residual-risk evaluation).

**Artifact Status**: ✅ **READY FOR APPROVAL** — zero Critical, zero Major findings. Pass-A/B/C remediation effectively closed every blocking and significant finding from Pass 1. Remaining issues are 1 Minor (likelihood-justification scope) and 3 Observations (clarity / auditor-friendliness improvements). None block release.

**CI Exit Code**: Exit 2 (warning) — Minor findings only, no Critical/Major.

**Recommended Next Steps**:
1. Address PRF-HAZ-001 (Minor) by extending the Likelihood Justification scope to include HAZ-007.
2. Apply PRF-HAZ-002, PRF-HAZ-003, PRF-HAZ-004 (Observations) in a follow-up polish pass — none are blocking.
3. Re-run peer review after the Minor fix to confirm clean (Exit 0) state.
