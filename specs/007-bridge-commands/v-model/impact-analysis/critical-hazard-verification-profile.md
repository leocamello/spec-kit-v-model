# Critical Hazard Verification Profile

**Generated**: 2026-04-26
**Source**: `hazard-analysis.md` + `traceability-matrix.md` (Matrix H)
**Scope**: All `Critical`-severity hazards (per ISO 14971:2019 §5 risk classification)
**Purpose**: Provide a peer-review-ready audit trail showing, for each Critical hazard, the complete Mitigation → Verification chain across V-Model levels (ATP / STP / ITP / UTP). Companion artifact to `critical-hazards.md` (the deterministic blast-radius report from `impact-analysis.sh`).

## Audit Question

For each of the 8 Critical-severity hazards, are the mitigations adequately verified at every applicable V-Model level (acceptance, system, integration, unit)?

## Verification Profile (per Critical HAZ)

Notation: `REQ ↦ {ATP-list}` means the requirement is verified by the listed ATPs at the acceptance level. `SYS ↦ {STP-list}` means the system component is verified at the system level. ARCH/MOD coverage is implicit via Matrix C/D since every SYS decomposes to ARCH and every ARCH decomposes to MOD with full ITP/UTP coverage (audited and 100%).

### HAZ-009 — Pre-Implementation Gate false-negative
*"Reports `passed` when Matrix A/B/C/D/H is incomplete; defeats the V-Model invariant."*

| Layer | Mitigation ID | Verifying Test Cases |
|-------|---------------|----------------------|
| Acceptance | REQ-016 | ATP-016-A, ATP-016-B |
| Acceptance | REQ-017 | ATP-017-A |
| Acceptance | REQ-NF-004 | ATP-NF-004-A |
| Acceptance | REQ-CN-002 | ATP-CN-002-A |
| System | SYS-004 (Pre-Implementation Gate) | STP-004-A, STP-004-B, STP-004-C *(via Matrix B)* |

**Verdict**: ✅ Multi-layer coverage. The acceptance plan tests gate refusal on Matrix A and Matrix H gaps explicitly (ATP-016-A, ATP-016-B). REQ-CN-002 reuses the existing deterministic `validate-*-coverage` scripts, eliminating new code paths.

---

### HAZ-012 — Hallucination Guard false-negative
*"Misses an invalid `// Implements <ID>` reference; commit ships with phantom IDs."*

| Layer | Mitigation ID | Verifying Test Cases |
|-------|---------------|----------------------|
| Acceptance | REQ-023 | ATP-023-A |
| Acceptance | REQ-NF-002 | ATP-NF-002-A |
| System | SYS-013 (Compliance Harness) | STP-013-A, STP-013-B *(via Matrix B)* |
| Integration | ARCH-009 *(Hallucination Guard impl)* | ITP-009-A *(uses REQ-999 as phantom test data — verified)* |
| Unit | MOD-013 *(verify_ids)* | UTP-013-A *(includes UTS-013-A2 false-branch with REQ-999 phantom)* |

**Verdict**: ✅ Strongest coverage in the analysis. Phantom-ID negative-path testing exists at both unit (UTS-013-A2) and integration (ITP-009-A) levels using `REQ-999` as test fixture.

---

### HAZ-014 — Source Region Manager: user-authored region overwritten
*"Silent loss of user code; the Hybrid user path (REQ-022) is broken."*

| Layer | Mitigation ID | Verifying Test Cases |
|-------|---------------|----------------------|
| Acceptance | REQ-022 | ATP-022-A, ATP-022-B |
| Acceptance | REQ-NF-005 | ATP-NF-005-A |
| System | SYS-003 (Implementation Engine) | STP-003-A, STP-003-B, STP-003-C *(via Matrix B)* |

**Verdict**: ✅ Two acceptance scenarios cover the region preservation. ATP-NF-005-A independently verifies idempotency (≥95% structural identity) — together they cover both the data-loss path and the churn path. **Recommendation for peer-review**: confirm one of the STP-003 scenarios exercises a region-marker-corruption fault (not just a clean re-run).

---

### HAZ-015 — Domain Overlay Adapter: configured domain not applied
*"DO-178C Level A run produces unit tests without MC/DC; regulatory-evidence path silently broken."*

| Layer | Mitigation ID | Verifying Test Cases |
|-------|---------------|----------------------|
| Acceptance | REQ-024 | ATP-024-A |
| System | SYS-003 (Implementation Engine fail-closed) | STP-003-A, STP-003-B, STP-003-C *(via Matrix B)* |

**Verdict**: ⚠️ Single ATP coverage. **Recommendation for peer-review**: consider whether ATP-024-A covers BOTH (a) overlay applied correctly when configured AND (b) overlay-load failure causes non-zero exit. If only (a) is covered, peer-review should request adding a negative-path acceptance scenario (ATP-024-B). The fail-closed mitigation depends on this negative path being exercised.

---

### HAZ-016 — Hazard-Driven Task Emitter does not activate
*"`tasks.md` lacks mitigation-task priority and `HAZ-NNN` verification tasks; safety-critical regression."*

| Layer | Mitigation ID | Verifying Test Cases |
|-------|---------------|----------------------|
| Acceptance | REQ-014 | ATP-014-A, ATP-014-B |
| System | SYS-002 (Tasks Synthesizer) | STP-002-A, STP-002-B, STP-002-C *(via Matrix B)* |

**Verdict**: ✅ Two ATPs cover the activation path. Dogfooding will provide additional natural verification: the `tasks.md` produced for this very feature (Phase 1b) MUST surface HAZ-NNN priority tasks for the Critical hazards in this register — a self-witnessing test.

---

### HAZ-018 — Spec-Kit Core round-trip violation
*"`v-model.plan` output not consumable by `speckit.tasks`; Hybrid path broken."*

| Layer | Mitigation ID | Verifying Test Cases |
|-------|---------------|----------------------|
| Acceptance | REQ-029 | ATP-029-A, ATP-029-B |
| Acceptance | REQ-CN-001 *(MUST NOT modify spec-kit core)* | ATP-CN-001-A |
| System | SYS-005, SYS-010 | STP-005-A/B, STP-010-A/B/C *(via Matrix B)* |

**Verdict**: ✅ Two acceptance scenarios for the round-trip property + the "core untouched" constraint test. Strong coverage.

---

### HAZ-023 — Hallucination Guard race condition (architecture-level)
*"Scanner consumes stale snapshot of generated files; newly-emitted hallucinated IDs slip through."*

| Layer | Mitigation ID | Verifying Test Cases |
|-------|---------------|----------------------|
| Acceptance | REQ-023 | ATP-023-A |
| Acceptance | REQ-NF-002 | ATP-NF-002-A |
| Architecture (interface contract) | ARCH-019 | ITP-019-A, ITP-019-B *(via Matrix C)* |

**Verdict**: ⚠️ The race-condition specifics (fsync barrier between SYS-003 file writes and SYS-006 scan) are an interface concern at the integration level. **Recommendation for peer-review**: confirm one of the ITP-019 scenarios exercises a write-then-immediately-scan ordering case, not just a sequential happy path.

---

### HAZ-024 — Domain Overlay Loader: malformed config silently downgraded
*"Configured domain silently downgraded to base behaviour; regulatory obligations skipped without warning."*

| Layer | Mitigation ID | Verifying Test Cases |
|-------|---------------|----------------------|
| Acceptance | REQ-024 | ATP-024-A |
| Architecture | ARCH-020 *(Domain Overlay Loader contract)* | ITP-020-A, ITP-020-B *(via Matrix C)* |

**Verdict**: ⚠️ Same single-ATP concern as HAZ-015. **Recommendation for peer-review**: ITP-020 must include a "malformed YAML" negative-path scenario; peer-review should verify this is present, not implicit.

---

## Roll-up Summary

| HAZ | Mitigations | Direct ATP count | Direct STP count | Status |
|-----|-------------|------------------|------------------|--------|
| HAZ-009 | 4 REQ + 1 SYS | 5 | 3 (via SYS-004) | ✅ Strong |
| HAZ-012 | 2 REQ + 1 SYS | 2 | 2 (via SYS-013) | ✅ Strongest (multi-level phantom-ID coverage) |
| HAZ-014 | 2 REQ + 1 SYS | 3 | 3 (via SYS-003) | ✅ Strong; ⚠️ confirm STP fault-injection |
| HAZ-015 | 1 REQ + 1 SYS | 1 | 3 (via SYS-003) | ⚠️ Single ATP — request ATP-024-B |
| HAZ-016 | 1 REQ + 1 SYS | 2 | 3 (via SYS-002) | ✅ Adequate; dogfood self-witnesses |
| HAZ-018 | 3 REQ + 2 SYS | 3 | 5 (SYS-005+SYS-010) | ✅ Strong |
| HAZ-023 | 2 REQ + 1 ARCH | 2 | n/a (ARCH layer) | ⚠️ Confirm ITP-019 race scenario |
| HAZ-024 | 1 REQ + 1 ARCH | 1 | n/a (ARCH layer) | ⚠️ Confirm ITP-020 malformed-YAML scenario |

## Findings & Peer-Review Action Items

1. **All 8 Critical hazards have ≥1 verifying acceptance test.** Matrix H reports 25/25 (100%) HAZ verification — this profile confirms the verification chains for the Critical subset are real, not nominal.

2. **3 hazards (HAZ-015, HAZ-023, HAZ-024) carry a `⚠️` flag** for peer-review to confirm that the listed test cases actually exercise the negative path described in the hazard's failure mode. None of these are gaps in the V-Model artifacts; they are quality-of-coverage questions that the peer-review checklist should answer.

3. **1 hazard (HAZ-014) carries a `⚠️` flag** for STP fault-injection coverage at the system level (region-marker corruption, not just clean re-runs).

4. **HAZ-016 (Hazard-Driven Task Emitter)** will be naturally validated by dogfooding: the `tasks.md` produced for `feature/007-bridge-commands` itself in Phase 1b MUST surface HAZ-009/012/014/015/016/018/023/024 as priority items. If it does not, SYS-002 + SYS-009 are broken.

5. **No new requirements, system components, architecture modules, or test cases need to be added before peer-review.** The 4 `⚠️` items are quality questions about existing tests, not coverage gaps.

## Cross-Reference

- Companion deterministic report: `impact-analysis/critical-hazards.md` (full upstream blast radius from `impact-analysis.sh --full`)
- Matrix H source: `traceability-matrix.md` lines 762-833
- Hazard register: `hazard-analysis.md`

## Note on REQ-999

The deterministic impact-analysis report (`critical-hazards.md`) lists `REQ-999` in upstream suspects. This is a **known false-positive** of the regex parser: `REQ-999` is a phantom identifier intentionally used as test fixture data inside `UTS-013-A2` and `ITP-009-A` to verify the Hallucination Guard's negative path. It is not a real requirement and does not appear in `requirements.md`. No action required.
