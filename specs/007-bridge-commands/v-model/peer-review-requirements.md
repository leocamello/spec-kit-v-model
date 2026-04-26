# Peer Review — requirements.md

**Reviewer**: AI Peer Review (spec-kit V-Model)
**Date**: 2026-04-21
**Artifact**: requirements.md (44 REQ — 44 active, 0 deprecated, 0 suspect)
**Review Type**: Inspection (IEEE 1028 §4)
**Standard**: INCOSE Guide for Writing Requirements

## Summary

| Severity | Count |
|----------|-------|
| Critical | 0 |
| Major | 1 |
| Minor | 1 |
| Observation | 1 |
| **Total Findings** | **3** |

### Item Inventory

| Category | Count | Status |
|----------|-------|--------|
| Active Requirements | 44 | ✓ |
| Deprecated Requirements | 0 | ✓ |
| Suspect Requirements | 0 | ✓ |
| **By Category** | | |
| Functional (REQ-NNN) | 29 | ✓ |
| Non-Functional (REQ-NF-NNN) | 6 | ✓ |
| Interface (REQ-IF-NNN) | 5 | ✓ |
| Constraint (REQ-CN-NNN) | 4 | ✓ |
| **By Priority** | | |
| P1 (Critical) | 37 | ✓ |
| P2 (High) | 7 | ✓ |
| P3 (Medium) | 0 | ✓ |
| **By Verification Method** | | |
| Test | 35 | ✓ |
| Inspection | 7 | ✓ |
| Analysis | 2 | ✓ |

## Findings

### PRF-REQ-001 — Stale aggregate counts in footer summary contradict body

| Field | Value |
|-------|-------|
| **Severity** | Major |
| **Location** | Closing summary block (lines 127–130) |
| **Description** | After the Pass B+ split of compound REQ-IF-003 into REQ-IF-003 + REQ-IF-005, the footer aggregates were not updated. The footer states `Total Requirements: 43 (43 active, 0 deprecated)`, `By Category: Functional: 29 \| Non-Functional: 6 \| Interface: 4 \| Constraint: 4`, `By Priority: P1: 36 \| P2: 7 \| P3: 0`, and `By Verification Method: Test: 34 \| Inspection: 7 \| Analysis: 2`. The body actually contains 44 active REQs (Interface: **5**, including new REQ-IF-005), 37 P1 items, and 35 Test-verified items. Per ISO/IEC 20246:2017 §6.3 this is an **Inconsistent** defect — header/body disagreement undermines downstream tooling that may parse either location for matrix planning, coverage budgeting, or release-gate counting. |
| **Recommendation** | Update the footer block to: `Total Requirements: 44 (44 active, 0 deprecated)`; `By Category: Functional: 29 \| Non-Functional: 6 \| Interface: 5 \| Constraint: 4`; `By Priority: P1: 37 \| P2: 7 \| P3: 0`; `By Verification Method: Test: 35 \| Inspection: 7 \| Analysis: 2`. Consider adding a one-line lint check (e.g., a Bats assertion) so future splits/additions cannot leave the footer stale. |

### PRF-REQ-002 — Open-ended enumeration ("including but not limited to") in REQ-024

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | REQ-024 |
| **Description** | REQ-024 reads: "...by applying overlay-specific output requirements, **including but not limited to** MC/DC unit-test coverage requirements for DO-178C Level A and ASIL-driven test depth for ISO 26262." Per INCOSE Guide for Writing Requirements (R8 — Avoid open-ended/non-verifiable lists) the phrase "including but not limited to" makes the requirement set unbounded: a verification engineer cannot enumerate the full pass condition because the requirement explicitly disclaims completeness. Defect type per ISO/IEC 20246:2017 §6.3: **Ambiguous** (untestable boundary). |
| **Recommendation** | Either (a) replace the open-ended list with the exhaustive set of overlay-driven obligations the v0.7.0 release commits to (e.g., "MC/DC for DO-178C Level A; ASIL-D test depth for ISO 26262; …"), or (b) split REQ-024 into one parent requirement ("...SHALL honour the configured domain overlay...") plus N atomic child requirements, one per overlay-specific obligation, each independently testable. The latter is preferred because it lets each obligation accrue its own verification evidence. |

### PRF-REQ-003 — Transient PRF IDs embedded in requirement rationale

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Location** | REQ-IF-003, REQ-IF-005 |
| **Description** | Both REQ-IF-003 and REQ-IF-005 contain the parenthetical `; split from prior compound REQ-IF-003 per PRF-REQ-001` in their Rationale fields. Per the peer-review rubric's Operating Constraints, PRF-{ARTIFACT}-NNN IDs are explicitly **stateless and transient** — they are regenerated from scratch on every review and have no persistence across runs. Anchoring durable requirement rationale to a transient ID makes the rationale text immediately stale (this very review uses a different PRF-REQ-001 finding for a different defect, so the cross-reference is already inaccurate). This is not a quality defect in the requirement itself but a documentation hygiene issue. |
| **Recommendation** | Replace the PRF cross-reference with a stable provenance pointer such as the commit hash (`split from prior compound REQ-IF-003 in commit 6f9fcb6`) or simply drop the parenthetical — the git history of `requirements.md` is already the authoritative audit trail for the split. Apply the same convention to any future requirement rationale that needs to reference past review activity. |

## Review Observations

### Pass-1 Remediation Verification

| Pass-1 Finding | Pass-1 Severity | Status |
|---|---|---|
| PRF-REQ-001 — Compound REQ-IF-003 (atomicity violation) | Minor | **RESOLVED** in commit 6f9fcb6. REQ-IF-003 now describes only the `before_implement`/`after_implement` hook registration. New REQ-IF-005 is well-formed, atomic, P1, Test-verified, and traces to the same source (spec.md FR-028). Both halves of the split carry independent rationale and are individually testable. |

### Strengths Carried Forward

- **Complete priority assignment**: All 44 active requirements carry P1/P2/P3.
- **Precise quantifiers**: ≥95% structural identity (REQ-025), 100% pass rate (REQ-NF-002, REQ-NF-004), zero hallucinated IDs.
- **No INCOSE banned words**: No "user-friendly", "fast", "robust", "seamless", "intuitive", "reasonable", "significant", "adequate", "minimal", "multiple", "several", "many", "few".
- **No TBD markers**.
- **Lifecycle discipline**: Zero deprecated items, zero suspect tags, zero orphaned children.
- **Atomicity**: 43/44 are well-formed atomic statements; the prior compound (REQ-IF-003) has been split correctly.

### Compliance with Rubric

**§4.1 Atomicity**: 44/44 ✓ (prior compound resolved)
**§4.1 Testability**: 43/44 ✓ (1 Minor — REQ-024 open-ended list)
**§4.1 Unambiguity**: 43/44 ✓ (1 Minor — REQ-024)
**§4.1 Completeness**: 44/44 ✓
**§4.1 Priority Assignment**: 44/44 ✓
**§4.1 No Subjective Language**: 44/44 ✓
**§4.10 Deprecation Syntax**: N/A (0 deprecated)
**§4.10 Unresolved Suspects**: 0/0 ✓
**§4.10 Orphaned Children**: N/A (0 deprecated parents)
**Document Self-Consistency** (header counts ↔ body): ✗ (1 Major — PRF-REQ-001)

---

**CI Exit Code**: 1 (Major finding present — PRF-REQ-001 footer/body inconsistency blocks the gate).
**Recommendation**: Fix PRF-REQ-001 (refresh the four footer aggregate lines) and PRF-REQ-002 (close the open-ended list in REQ-024). PRF-REQ-003 is an observation and may be addressed opportunistically. Re-run review after edits — all three findings should disappear.
