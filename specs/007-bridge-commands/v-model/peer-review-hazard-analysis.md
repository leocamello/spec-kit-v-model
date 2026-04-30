# Peer Review — hazard-analysis.md

**Reviewer**: AI Peer Review (spec-kit V-Model)
**Date**: 2026-04-30
**Pass**: 6 (re-review — verifies Pass-5 finding PRF-HAZ-006 closed by Pass-G fix; independent re-inspection of full artifact at HEAD 18faa11)
**Artifact**: hazard-analysis.md (25 HAZ active, 0 deprecated, 0 suspect — 22 system-level + 3 architecture-level progressive-deepening)
**Standard**: IEC 60812:2018 + ISO 14971:2019 — Inspection class (IEEE 1028:2008 §4)

## Summary

| Severity | Count |
|----------|-------|
| Critical | 0 |
| Major | 0 |
| Minor | 0 |
| Observation | 5 |
| **Total Findings** | **5** |

## Findings

### PRF-HAZ-001 — Likelihood Justification Preamble Cites Post-Mitigation Residual Risk as the Rationale for Excluding Critical Hazards

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Status** | ✅ **CLOSED** (Pass-F fix verified) |
| **Location** | § "Likelihood Justification" preamble, lines 125–127 |
| **Verification** | Pass-F replaced the offending sentence. The current preamble (lines 125–127) at HEAD 18faa11 reads: *"Critical hazards' likelihoods are conservatively bounded by the Risk Acceptability Matrix — any Critical/Occasional or Critical/Probable pairing would be Intolerable pre-mitigation and is therefore excluded by design from the register; only Critical/Remote pairings appear, and their pre-mitigation likelihood is justified inline by the Failure Mode and Operational State columns of the Hazard Register itself."* Closure criteria assessed: (a) The phrase "Tolerable-after-mitigation residual risk" is absent — no post-mitigation residual language remains ✅. (b) The argument is explicitly pre-mitigation and grounded in the Risk Acceptability Matrix bounding rule ("Intolerable pre-mitigation"), satisfying ISO 14971 §5.4 ✅. Fix is logically correct and removes the §5.5/§5.6 cross-contamination identified in Pass-4. The "Triggering Condition column" reference has since been replaced by Pass-G — see PRF-HAZ-006 (CLOSED) and PRF-HAZ-007 (new). |

### PRF-HAZ-002 — HAZ-008 / HAZ-014 State Scoping to COMMITTING Only Lacks Documented Rationale

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Status** | 🔴 **OPEN** — **CARRY-FORWARD** from Pass-3 PRF-HAZ-002; not addressed in Pass-E, Pass-F, or Pass-G |
| **Location** | HAZ-008 (Idempotency failure, COMMITTING — line 90); HAZ-014 (Region-marker corruption, COMMITTING — line 96); cross-reference to system-design.md § "Operational States" State Definitions |
| **Description** | Per the system-design State Definitions table, the DRY-RUN state activates SYS-003, SYS-006, **SYS-007**, and SYS-012. SYS-007 (Source Region Manager) — the component named in HAZ-014's mitigation and implicit in HAZ-008's idempotency contract — is therefore active in both DRY-RUN and COMMITTING. Yet HAZ-008 ("re-run regenerates source code with <95% structural identity") and HAZ-014 ("region-marker corruption: user-authored content overwritten") are both tagged **COMMITTING** only. The defensible argument is that DRY-RUN writes go to a temp scratch path so user code cannot be silently overwritten and idempotency churn cannot manifest as user-visible review noise. This rationale is correct but is not documented anywhere in hazard-analysis.md. An auditor reading the artifact in isolation must infer the scoping from the state definitions. Defect type: **Incomplete**. |
| **Recommendation** | Add a short rationale either (a) as an inline note under the Operational States Reference table (e.g., "HAZ-008 / HAZ-014 are scoped to COMMITTING because SYS-007's DRY-RUN scratch-path writes do not touch the working tree and therefore cannot manifest as user-visible churn or content loss"), or (b) as parenthetical clarifications in the Operational State column of those two rows (e.g., "COMMITTING (DRY-RUN excluded — scratch-path writes only)"). |

### PRF-HAZ-003 — Residual Risk Justification for HAZ-022 Lacks an ALARP Statement

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Status** | 🔴 **OPEN** — **CARRY-FORWARD** from Pass-3 PRF-HAZ-003; not addressed in Pass-E, Pass-F, or Pass-G |
| **Location** | HAZ-022 Residual Risk Justification row (line 172) |
| **Description** | HAZ-022 is the only entry in the register where mitigation does *not* reduce the risk class (initial Tolerable, residual Tolerable). The Residual Risk Justification row reads: "the commit-message-template logic is the most defect-prone code in v0.7.0; residual is held at Tolerable by the warning + fallback." This is a candid disclosure but implicitly accepts the Occasional likelihood as a steady-state property. ISO 14971 §5.5 expects residual risk that is *not improved* by mitigation to carry either an As-Low-As-Reasonably-Practicable (ALARP) statement or a documented risk-acceptance decision. Neither is present. Defect type: **Incomplete** (informational — Tolerable residual is acceptable per the project risk matrix without mandatory sign-off, but the ALARP rationale is needed for audit completeness). |
| **Recommendation** | Add a one-sentence ALARP statement, e.g.: "Residual Tolerable is accepted As-Low-As-Reasonably-Practicable: the only further reduction would be to harden the commit-message-template logic (not in v0.7.0 scope); the SYS-012 warning + REQ-021 in-file fallback render the audit gap recoverable." Optionally link a follow-up issue to refactor the template logic in a future release. |

### PRF-HAZ-004 — Operational State Distribution Table Omits Per-State HAZ Enumeration

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Status** | 🔴 **OPEN** — **CARRY-FORWARD** from Pass-3 PRF-HAZ-004; not addressed in Pass-E, Pass-F, or Pass-G |
| **Location** | § "Coverage Summary" → "Operational State Distribution" table (lines 244–249) |
| **Description** | The Operational State Distribution table (NORMAL=15, DRY-RUN=2, COMMITTING=8, ERROR=2 — total 27 due to dual-tagging of HAZ-006/007) is arithmetically correct and the dual-tagging note is helpful. However, the table lists state *counts* without listing *which* HAZs fall into each state. An auditor must scan the full Hazard Register and the Progressive Deepening table and tally manually to verify the counts. Defect type: **Incomplete** (informational). |
| **Recommendation** | Append a column (or sub-rows) listing the HAZ IDs per state, e.g.: "NORMAL — HAZ-001/002/003/004/005/009/010/011/015/016/017/018/019/021/024 (15)"; "DRY-RUN — HAZ-006/007 (2)"; "COMMITTING — HAZ-006/007/008/012/013/014/022/023 (8)"; "ERROR — HAZ-020/025 (2)". This makes the counts line-of-sight verifiable and reduces auditor effort. |

### PRF-HAZ-005 — HAZ-022 Occasional Likelihood Justification Displaced to Residual Risk Section

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Status** | 🔴 **OPEN** — **CARRY-FORWARD** from Pass-4 PRF-HAZ-005; not addressed in Pass-F or Pass-G |
| **Location** | § "Likelihood Justification" preamble (lines 126–127); HAZ-022 Residual Risk Justification row (line 172) |
| **Description** | The Likelihood Justification preamble explicitly excludes Minor hazards ("Minor hazards do not require the same rigour per ISO 14971 risk-acceptability principles"). HAZ-022 is Minor/Occasional — and it is the *only* Minor hazard that is not Remote; all other nine Minor entries are Remote/Acceptable. HAZ-007 (Serious/Occasional) was added to the Likelihood Justification table in Pass-E precisely because its non-Remote likelihood required justification. HAZ-022 carries the identical anomaly at a lower severity tier: its Occasional likelihood — explained as "the commit-message-template logic is the most defect-prone code in v0.7.0" — is buried in the Residual Risk section (line 172) rather than the Likelihood Justification section, and is reachable only by a reader who knows to look there. The Minor/Occasional combination yields Tolerable (not Acceptable), which is not in the ISO 14971 "broadly acceptable" region for which reduced rigour is warranted. Defect type: **Incomplete** — the Likelihood Justification section is structurally inconsistent in its treatment of anomalous likelihood ratings. |
| **Recommendation** | Either (a) add HAZ-022 to the Likelihood Justification table with a row such as "Minor \| Occasional \| The commit-message-template logic is the most defect-prone module in v0.7.0; Occasional is a conservative estimate given observed defect density in pre-release testing. This rating drives the SYS-012 warning + REQ-021 fallback", or (b) update the preamble to note that Minor/Occasional is separately justified inline in the Residual Risk section and cross-reference line 172. Option (a) is preferred for symmetry with HAZ-007. |

### PRF-HAZ-006 — "Triggering Condition Column" Reference in Likelihood Preamble Names a Non-Existent Column

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Status** | ✅ **CLOSED** (Pass-G fix verified) |
| **Location** | § "Likelihood Justification" preamble, line 126 |
| **Verification** | Pass-G replaced "the Triggering Condition column of the Hazard Register itself" with "the Failure Mode and Operational State columns of the Hazard Register itself." Closure criteria assessed: (a) No column named "Triggering Condition" is cited anywhere in the preamble — absent ✅. (b) Both cited replacement column names — "Failure Mode" (position 3) and "Operational State" (position 4) — exist as actual headers in the Hazard Register table at line 81 (`\| HAZ ID \| Component \| Failure Mode \| Operational State \| Effect \| Severity \| Likelihood \| Risk Level \| Mitigation \| Residual Risk \|`) ✅. The non-existent-column-name defect is resolved. Residual semantic accuracy gap noted as new PRF-HAZ-007 (see below). |

### PRF-HAZ-007 — "Failure Mode and Operational State Columns" Cited as Locus of Pre-Mitigation Likelihood Rationale for Critical/Remote Entries, but Rationale Resides in the Mitigation Column

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Status** | **NEW** (Pass 6) |
| **Location** | § "Likelihood Justification" preamble, line 126: "their pre-mitigation likelihood is justified inline by the Failure Mode and Operational State columns of the Hazard Register itself" |
| **Description** | Pass-G closed PRF-HAZ-006 by replacing the non-existent "Triggering Condition column" with "the Failure Mode and Operational State columns." Both replacement column names exist (PRF-HAZ-006 ✅ CLOSED). However, inspecting every Critical/Remote entry (HAZ-009, HAZ-012, HAZ-014, HAZ-015, HAZ-016, HAZ-018, HAZ-023, HAZ-024), the language that actually justifies Remote pre-mitigation likelihood is uniformly located in the **Mitigation** column, not in the Failure Mode or Operational State columns: HAZ-009 Mitigation — "reuses deterministic `build-matrix` and `validate-*-coverage` scripts"; HAZ-012 Mitigation — "deterministic regex + canonical-set lookup with no LLM call"; HAZ-014 Mitigation — "SYS-003 fail-closed degradation to dry-run + diff report on conflict"; HAZ-015 Mitigation — "SYS-003 fail-closed (non-zero exit when overlay configured but adapter fails)"; HAZ-016 Mitigation — "SYS-002 fail-closed when malformed `hazard-analysis.md` detected"; HAZ-018 Mitigation — "SYS-005 (additive-enrichment guarantees core compatibility)"; HAZ-023 Mitigation — "ARCH-019 contract: scanner consumes file paths emitted by SYS-003 only after fsync barrier"; HAZ-024 Mitigation — "ARCH-020 contract: schema validation MUST raise on parse failure." The Failure Mode column describes *what* could go wrong (functional description); the Operational State column describes *when/in which context* it could arise. Neither column contains "deterministic," "fail-closed," or any language that grounds a Remote likelihood claim. An auditor directed by the preamble to "the Failure Mode and Operational State columns" will not find the pre-mitigation likelihood rationale there, leaving the same audit-trail gap that PRF-HAZ-006 identified in different wording. The Pass-G fix resolved the letter of PRF-HAZ-006 (non-existent column name) but not its spirit (the Mitigation column is the actual locus per the Pass-5 recommendation). Defect type (ISO/IEC 20246 §6.3): **Incorrect** — the column(s) cited do not contain the claimed content. |
| **Recommendation** | Replace "the Failure Mode and Operational State columns of the Hazard Register itself" with "the Mitigation column of each Critical/Remote entry (each Mitigation cell describes the deterministic or fail-closed implementation mechanism that makes higher-than-Remote likelihood structurally implausible pre-mitigation)." This is the exact wording recommended in PRF-HAZ-006 (Pass-5) and directly addresses the navigation gap. |

---

## Verification Checklist (§4.8 + §4.10 Applied)

### §4.8 Hazard Analysis (FMEA — IEC 60812:2018 + ISO 14971:2019)

- ✅ **Likelihood Justification — Serious hazards**: All 8 Serious entries (HAZ-002/003/005/007/008/011/017/021) have dedicated rows in the Likelihood Justification table, including HAZ-007 (Serious/Occasional). Independent count confirms 8 table rows matching 8 Serious register entries.
- ✅ **Likelihood Justification — Critical hazards**: All 8 Critical entries (HAZ-009/012/014/015/016/018/023/024) are Remote. Pass-F preamble correctly grounds the Critical exclusion in the pre-mitigation Risk Acceptability Matrix bounding rule — PRF-HAZ-001 CLOSED. Pass-G replaced the non-existent "Triggering Condition column" reference with "Failure Mode and Operational State columns" — PRF-HAZ-006 CLOSED. Residual semantic navigation gap (auditor directed to Failure Mode/Operational State but rationale is in Mitigation column) noted as PRF-HAZ-007.
- ⚠️ **Likelihood Justification — Minor/Occasional**: HAZ-022 (Minor/Occasional) is excluded from the Likelihood Justification table by the preamble's blanket Minor exclusion, yet its anomalous Occasional rating warrants the same treatment as HAZ-007 — see PRF-HAZ-005.
- ✅ **Risk Matrix Consistency**: All 25 Severity × Likelihood → Risk Level cells verified against the Risk Matrix Definition. HAZ-007 (Serious × Occasional = Undesirable ✓); HAZ-022 (Minor × Occasional = Tolerable ✓); all Critical/Remote = Undesirable ✓; all Serious/Remote = Tolerable ✓; all Minor/Remote = Acceptable ✓. Coverage Summary counts verified: Undesirable=9 ✓, Tolerable=8 ✓, Acceptable=8 ✓ (total 25 ✓).
- ✅ **Residual Risk Consistency**: All 25 residual risk cells in the register verified against the Residual Risk Justification table. Residual distribution: Tolerable=9 (HAZ-009/012/014/015/016/018/022/023/024), Acceptable=16 (total 25 ✓). HAZ-022 uniquely shows no risk-class improvement (Tolerable→Tolerable); ALARP statement absent — see PRF-HAZ-003.
- ✅ **Mitigation Completeness**: Every HAZ has at least one REQ-NNN or SYS-NNN mitigation; all identifiers conform to canonical patterns (REQ-NNN, REQ-NF-NNN, REQ-IF-NNN, REQ-CN-NNN, SYS-NNN, ARCH-NNN). No phantom IDs detected.
- ✅ **Operational State Coverage**: Every HAZ row carries an explicit Operational State; dual-state tagging (HAZ-006/007) is correctly handled. COMMITTING-only scoping for HAZ-008/014 is correct but rationale is undocumented — see PRF-HAZ-002.
- ✅ **SYS Coverage**: 14/14 active SYS components covered by enumeration. SYS-001 (HAZ-001/002/003), SYS-002 (HAZ-004/005), SYS-003 (HAZ-006/007/008), SYS-004 (HAZ-009/010), SYS-005 (HAZ-011), SYS-006 (HAZ-012/013/023), SYS-007 (HAZ-014), SYS-008 (HAZ-015/024), SYS-009 (HAZ-016), SYS-010 (HAZ-017/018), SYS-011 (HAZ-019), SYS-012 (HAZ-020/025), SYS-013 (HAZ-021), SYS-014 (HAZ-022) — claim "14 / 14 (100%)" verified.
- ✅ **Progressive Deepening**: "Progressive Deepening Cross-References" table correctly maps HAZ-023→HAZ-007/012; HAZ-024→HAZ-015; HAZ-025→HAZ-020. No gaps.
- ✅ **State Distribution arithmetic**: NORMAL=15, DRY-RUN=2, COMMITTING=8, ERROR=2; total 27 = 25 distinct + 2 dual-tagged (HAZ-006/007) ✓. Per-state HAZ enumeration absent — see PRF-HAZ-004.

### §4.10 Lifecycle Validation

- ✅ **No Deprecated Items**: No HAZ marked `[DEPRECATED]`.
- ✅ **No Unresolved Suspects**: No HAZ tagged `[SUSPECT]`.
- ✅ **Coverage Exclusion**: No deprecated HAZ in coverage counts (none exist).
- ✅ **Mitigation references resolvable**: All mitigation cells reference identifiers conforming to canonical patterns; no phantom IDs detected in this artifact.

---

## Delta vs Pass 5 (verification of prior findings)

Pass 5 produced 0 Critical + 0 Major + 0 Minor + 5 Observation = 5 findings.

| Pass-5 Finding | Pass-5 Severity | Status in Pass-6 Artifact (HEAD 18faa11) |
|----------------|-----------------|------------------------------------------|
| PRF-HAZ-001 — Likelihood preamble cites post-mitigation residual risk as basis for Critical exclusion | Minor | ✅ **CLOSED** — Confirmed closed; Pass-F fix intact at lines 125–127. Pre-mitigation RAM bounding language present; no residual post-mitigation language. |
| PRF-HAZ-002 — HAZ-008/014 COMMITTING-only scoping undocumented | Observation | 🔴 **OPEN** — No inline rationale added. Carried forward as Pass-6 PRF-HAZ-002. |
| PRF-HAZ-003 — HAZ-022 lacks ALARP statement | Observation | 🔴 **OPEN** — No ALARP statement added. Carried forward as Pass-6 PRF-HAZ-003. |
| PRF-HAZ-004 — State Distribution table lacks HAZ enumeration | Observation | 🔴 **OPEN** — Table still shows counts only. Carried forward as Pass-6 PRF-HAZ-004. |
| PRF-HAZ-005 — HAZ-022 Minor/Occasional likelihood justification displaced to Residual Risk section | Observation | 🔴 **OPEN** — HAZ-022 row still absent from Likelihood Justification table; preamble's blanket Minor exclusion unchanged. Carried forward as Pass-6 PRF-HAZ-005. |
| PRF-HAZ-006 — "Triggering Condition column" reference names a non-existent column | Observation | ✅ **CLOSED** — Pass-G replaced "the Triggering Condition column" with "the Failure Mode and Operational State columns." Both cited column names ("Failure Mode" at position 3; "Operational State" at position 4) confirmed to exist in the Hazard Register table header at line 81. Non-existent-column-name defect resolved. |

New finding surfaced in Pass 6:

- **PRF-HAZ-007** (Observation) — The Pass-G fix closes the letter of PRF-HAZ-006 but not its spirit: "the Failure Mode and Operational State columns" do not contain the pre-mitigation Remote likelihood rationale for Critical entries. Inspection of all 8 Critical/Remote entries (HAZ-009/012/014/015/016/018/023/024) confirms the rationale is uniformly located in the Mitigation column (deterministic algorithms, fail-closed contracts). An auditor following the preamble's navigation guidance will not find the rationale in the cited columns. This is the same structural audit-trail gap identified in PRF-HAZ-006 under a different (but now existing) column name. Surfaced in Pass-6 as a direct consequence of the Pass-G edit inspected.

---

## Compliance Assessment

**Review Type** (IEEE 1028:2008): **Inspection** — high-risk artifact (`hazard-analysis.md`); Inspection-class rigor applied per the Step 2.5 selection rule.

**Governing Standard**: IEC 60812:2018 (FMEA) + ISO 14971:2019 (risk matrix and residual-risk evaluation).

**Artifact Status**: ✅ **APPROVED** — zero Critical, zero Major, zero Minor findings. Pass-G correctly and completely closed PRF-HAZ-006 (Observation): the preamble no longer cites a non-existent "Triggering Condition" column; both replacement column names ("Failure Mode" and "Operational State") are confirmed to exist in the Hazard Register table at line 81. All 5 remaining findings are Observations (documentation completeness / auditor-navigation improvements); none block release.

**CI Exit Code**: Exit 0 (clean) — no Critical/Major/Minor findings.

**Convergence Judgment** (IEEE 1028 §4 — third remediation pass): **NOT YET at steady-state.** Pass-G closed PRF-HAZ-006 but introduced PRF-HAZ-007 (same preamble sentence, different semantic inaccuracy: the cited columns exist but do not contain the claimed content). The four carry-forward Observations (PRF-HAZ-002/003/004/005) remain unaddressed across three consecutive passes (Pass-4 through Pass-6), indicating deliberate de-prioritization rather than oversight. Steady-state requires at minimum the closure of PRF-HAZ-007 with a one-word substitution ("Mitigation column") and optionally the four carry-forwards in a single polish pass.

**Recommended Next Steps** (IEEE 1028 §5.5.4):
1. Apply **PRF-HAZ-007** (Observation, new Pass-6) — replace "the Failure Mode and Operational State columns of the Hazard Register itself" with "the Mitigation column of each Critical/Remote entry (each Mitigation cell describes the deterministic or fail-closed implementation mechanism that makes higher-than-Remote likelihood structurally implausible pre-mitigation)." This is the wording recommended in the original PRF-HAZ-006 recommendation and requires a single-sentence edit.
2. Apply **PRF-HAZ-005** (Observation, carried from Pass-4) — add a HAZ-022 row to the Likelihood Justification table for symmetry with HAZ-007 treatment.
3. Apply **PRF-HAZ-002**, **PRF-HAZ-003**, **PRF-HAZ-004** (Observations, carried forward from Pass-3) in a follow-up polish pass — none are blocking; all three have concrete one-line remediation paths documented in the respective finding recommendations.
4. No mandatory re-review required (Exit 0). If PRF-HAZ-007 is addressed, a Pass-7 review is recommended to confirm closure and assess whether the artifact has reached steady-state; it is not required to unblock release.
