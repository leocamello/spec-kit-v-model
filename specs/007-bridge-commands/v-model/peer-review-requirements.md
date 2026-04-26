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
| Major | 0 |
| Minor | 1 |
| Observation | 1 |
| **Total Findings** | **2** |

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

### PRF-REQ-001 — Open-ended enumeration ("including but not limited to") in REQ-024

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | REQ-024 |
| **Description** | REQ-024 reads: "...by applying overlay-specific output requirements, **including but not limited to** MC/DC unit-test coverage requirements for DO-178C Level A and ASIL-driven test depth for ISO 26262." Per INCOSE Guide for Writing Requirements (R8 — Avoid open-ended/non-verifiable lists) the phrase "including but not limited to" makes the requirement set unbounded: a verification engineer cannot enumerate the full pass condition because the requirement explicitly disclaims completeness. Defect type per ISO/IEC 20246:2017 §6.3: **Ambiguous** (untestable boundary). |
| **Recommendation** | Either (a) replace the open-ended list with the exhaustive set of overlay-driven obligations the v0.7.0 release commits to (e.g., "MC/DC for DO-178C Level A; ASIL-D test depth for ISO 26262; …"), or (b) split REQ-024 into one parent requirement ("...SHALL honour the configured domain overlay...") plus N atomic child requirements, one per overlay-specific obligation, each independently testable. The latter is preferred because it lets each obligation accrue its own verification evidence. |

### PRF-REQ-002 — Transient PRF IDs embedded in requirement rationale

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Location** | REQ-IF-003, REQ-IF-005 |
| **Description** | Both REQ-IF-003 and REQ-IF-005 still contain the parenthetical `; split from prior compound REQ-IF-003 per PRF-REQ-001` in their Rationale fields. Per the peer-review rubric's Operating Constraints, PRF-{ARTIFACT}-NNN IDs are explicitly **stateless and transient** — they are regenerated from scratch on every review and have no persistence across runs. Anchoring durable requirement rationale to a transient ID makes the rationale text immediately stale: in this Pass-3 review, PRF-REQ-001 refers to a different finding (the REQ-024 open-ended list), so the cross-reference embedded in the requirement is already inaccurate. Per ISO/IEC 20246:2017 §6.3 the defect type is **Inconsistent** (rationale text references an ID that no longer points to the original finding). This is documentation hygiene, not a quality defect in the requirement itself. |
| **Recommendation** | Replace the PRF cross-reference with a stable provenance pointer such as the commit hash (`split from prior compound REQ-IF-003 in commit 6f9fcb6`) or simply drop the parenthetical — the git history of `requirements.md` is already the authoritative audit trail for the split. Apply the same convention to any future requirement rationale that needs to reference past review activity. |

## Review Observations

### Pass-2 Remediation Verification

| Pass-2 Finding | Pass-2 Severity | Status in Pass-3 |
|---|---|---|
| PRF-REQ-001 — Stale aggregate counts in footer summary contradict body | Major | **RESOLVED** in commit cd24f25. Footer now reads `Total Requirements: 44 (44 active, 0 deprecated)`, `By Category: Functional: 29 \| Non-Functional: 6 \| Interface: 5 \| Constraint: 4`, `By Priority: P1: 37 \| P2: 7 \| P3: 0`, `By Verification Method: Test: 35 \| Inspection: 7 \| Analysis: 2`. Independently re-counted body: 29 functional + 6 NF + 5 IF + 4 CN = 44 active; 7 P2 (REQ-005, REQ-006, REQ-008, REQ-013, REQ-021, REQ-NF-005, REQ-IF-004) → 37 P1; 7 Inspection + 2 Analysis → 35 Test. All four footer aggregates now agree with the body. |
| PRF-REQ-002 — Open-ended enumeration in REQ-024 | Minor | **STILL PRESENT** — re-flagged as Pass-3 PRF-REQ-001 with identical defect description and recommendation. |
| PRF-REQ-003 — Transient PRF IDs embedded in REQ-IF-003 / REQ-IF-005 rationale | Observation | **STILL PRESENT** — re-flagged as Pass-3 PRF-REQ-002. The cross-reference is now demonstrably stale because Pass-3's PRF-REQ-001 refers to a different finding (REQ-024), confirming the original Observation. |

### Strengths Carried Forward

- **Document self-consistency**: Footer aggregates match body counts in all four dimensions (Total, Category, Priority, Verification Method).
- **Complete priority assignment**: All 44 active requirements carry P1/P2/P3.
- **Precise quantifiers**: ≥95% structural identity (REQ-025), 100% pass rate (REQ-NF-002, REQ-NF-004), zero hallucinated IDs.
- **No INCOSE banned words**: No "user-friendly", "fast", "robust", "seamless", "intuitive", "reasonable", "significant", "adequate", "minimal", "multiple", "several", "many", "few".
- **No TBD markers**.
- **Lifecycle discipline**: Zero deprecated items, zero suspect tags, zero orphaned children.
- **Atomicity**: 44/44 are well-formed atomic statements; the prior compound (REQ-IF-003) remains correctly split.

### Compliance with Rubric

**§4.1 Atomicity**: 44/44 ✓
**§4.1 Testability**: 43/44 ✓ (1 Minor — REQ-024 open-ended list)
**§4.1 Unambiguity**: 43/44 ✓ (1 Minor — REQ-024)
**§4.1 Completeness**: 44/44 ✓
**§4.1 Priority Assignment**: 44/44 ✓
**§4.1 No Subjective Language**: 44/44 ✓
**§4.10 Deprecation Syntax**: N/A (0 deprecated)
**§4.10 Unresolved Suspects**: 0/0 ✓
**§4.10 Orphaned Children**: N/A (0 deprecated parents)
**Document Self-Consistency** (header counts ↔ body): ✓ (Pass-2 Major closed in commit cd24f25)

---

**CI Exit Code**: 2 (Minor finding present, no Critical or Major — warning only).
**Recommendation**: Address PRF-REQ-001 (close the open-ended list in REQ-024) at next convenient edit; PRF-REQ-002 is an observation that may be cleaned up opportunistically. With the Pass-2 Major now resolved, the artifact is no longer release-blocked by peer-review findings. Re-run the review after edits — both findings should disappear.
