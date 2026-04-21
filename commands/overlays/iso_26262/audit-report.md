# Audit Report — ISO 26262 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iso_26262`.
> It provides domain-specific functional safety audit sections for the base `audit-report` command.

## Functional Safety Audit (ISO 26262-2 §6)

ISO 26262-2 §6 requires that a functional safety audit independently confirms that the functional safety management process is implemented correctly. When generating the audit report in an ISO 26262 project, the report must include a **Functional Safety Audit** section verifying:

| Audit Objective | Evidence Source | Finding |
|----------------|-----------------|---------|
| Safety plan is established and followed | `hazard-analysis.md` safety goals, project safety plan | ✅ / ❌ / ⚠️ |
| ASIL allocations are documented and justified | `requirements.md` — ASIL per REQ-NNN | ✅ / ❌ / ⚠️ |
| Safety requirements are verified at each V-Model phase | Traceability matrix — HAZ-NNN → REQ-NNN → SYS-NNN | ✅ / ❌ / ⚠️ |
| Waivers (WAV-NNN) have functional safety justification | `waivers.md` — safety justification field present | ✅ / ❌ / ⚠️ |
| Independence requirements are met for ASIL C–D activities | Peer review records — independent reviewer confirmed | ✅ / ❌ / ⚠️ |

**Rules**:
- Every unresolved HAZ-NNN item must appear in this table and have a finding of ✅ or a waiver reference
- ASIL D findings that are ❌ are a **major nonconformity** — they block release regardless of other audit outcomes
- ASIL A–B findings that are ❌ are a **minor nonconformity** — document corrective action and timeline

## Confirmation Measures (ISO 26262-2 §6.4.6)

ISO 26262-2 §6.4.6 defines four mandatory confirmation measures that must be applied to safety work products at ASIL C–D:

| Confirmation Measure | Applicable ASIL | Applied To | Confirmer (Must Be Independent) | Status |
|---------------------|-----------------|------------|--------------------------------|--------|
| Functional safety assessment | ASIL C, D | Safety goals, HARA, safety case | Functional Safety Assessor | ✅ / ❌ / N/A |
| Confirmation review | ASIL B, C, D | Work products listed in safety plan | Reviewer independent of author | ✅ / ❌ / N/A |
| Software safety audit (this command) | ASIL B, C, D | V-Model artifacts completeness | QA auditor | ✅ / ❌ / N/A |
| Release for production | ASIL A, B, C, D | Release decision | Project manager + safety manager | ✅ / ❌ / N/A |

**Rules**:
- Confirmation measures at ASIL D require documented independence — the confirmer must not be on the development team
- If a confirmation measure was waived, reference the WAV-NNN entry and confirm a compensating control is documented
- The audit report itself constitutes the **software safety audit** confirmation measure — its existence and findings satisfy ISO 26262-2 §6.4.6 item (c)

## Functional Safety Management Assessment (ISO 26262-2 §6.5)

Assess the overall functional safety management by verifying the following items are present and complete in the V-Model artifact set:

| FSM Item | Required Artifact | Present? | Notes |
|----------|------------------|---------|-------|
| Safety lifecycle defined | `hazard-analysis.md` — safety goals section | Yes / No | — |
| Safety requirements complete and ASIL-tagged | `requirements.md` — ASIL column | Yes / No | — |
| Safety mechanisms allocated to components | `system-design.md` ISO 26262 overlay — Safety Mechanisms table | Yes / No | — |
| Verification evidence for each ASIL-tagged requirement | Traceability matrix — REQ-NNN → test IDs | Yes / No | — |
| All open safety anomalies resolved or waived | `waivers.md` — WAV-NNN entries | Yes / No | — |

If any FSM item is **No** and not waived, record it as a major nonconformity in the audit report's Findings section.
