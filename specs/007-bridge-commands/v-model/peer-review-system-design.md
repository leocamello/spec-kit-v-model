# Peer Review — system-design.md

**Reviewer**: AI Peer Review (spec-kit V-Model)
**Date**: 2026-04-27
**Artifact**: system-design.md (14 SYS — 14 active, 0 deprecated, 0 suspect)
**Standard**: IEEE 1016:2009
**Review Type**: Technical Review (IEEE 1028:2008 §5)

## Summary

| Severity | Count |
|----------|-------|
| Critical | 0 |
| Major | 0 |
| Minor | 3 |
| Observation | 1 |
| **Total Findings** | **4** |

## Item Inventory

- **Active Components**: 14 (SYS-001 through SYS-014)
- **Deprecated Components**: 0
- **Suspect Components**: 0
- **Forward Coverage (REQ→SYS)**: 43 / 43 active requirements (100%)
- **4 Mandatory IEEE 1016 Views**: Decomposition (§5.1), Dependency (§5.2), Interface (§5.3), Data Design (§5.4) — all present
- **Supplementary Views**: Operational States (Behavioural), SYS-006 Algorithm Specification, Quality Attribute Coverage (ISO/IEC 25010:2023)

## Pass-1 Remediation Status

| Pass-1 Finding | Severity (P1) | Status in Pass 2 |
|----------------|---------------|------------------|
| PRF-SYS-001 — Operational State Coverage Recommendation | Observation | **Resolved.** A dedicated "Operational States (Behavioural View)" section has been added between the Data Design View and the SYS-006 Algorithm Specification, defining four states (NORMAL / DRY-RUN / COMMITTING / ERROR) with an entry-condition table, an ASCII state-transition diagram, and per-state mitigation notes. The new section is properly cross-referenced from `hazard-analysis.md`. The pass-1 observation is retired. New defects discovered inside the added section are recorded below as fresh findings. |

## Findings

### PRF-SYS-001 — Operational States section cites a non-existent IEEE 1016 clause

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | Section heading: "Operational States (IEEE 1016 §5.2 Behavioural View)" (line 166) |
| **Description** | The new section is labelled "IEEE 1016 §5.2 Behavioural View". IEEE 1016:2009 §5.2 is the *Dependency description* viewpoint — the same clause already used (correctly) by the Dependency View at line 54. IEEE 1016:2009 does not define a clause titled "Behavioural View" at §5.2; the standard treats behavioural/state content via the broader §5 design viewpoints framework (typically realised as a supplementary State viewpoint). The current label simultaneously (a) duplicates the §5.2 reference, and (b) misattributes a clause title. Defect type: **Wrong** (ISO/IEC 20246:2017 §6.3) — incorrect standard citation. |
| **Recommendation** | Re-label the heading to one of: "Operational States (IEEE 1016 §5 — Supplementary Behavioural Viewpoint)", or "Operational States (Behavioural View — IEEE 1016 design-viewpoints framework)". The §5.2 citation should remain exclusive to the Dependency View. |

### PRF-SYS-002 — NORMAL state: entry condition includes `v-model.implement` but Active SYS Components omits SYS-003

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | State Definitions table — NORMAL row (line 178) |
| **Description** | The NORMAL row's *Triggering / Entry Condition* column explicitly enumerates `v-model.implement (initial phase before write barrier)` as a valid entry into NORMAL. However, the *Active SYS Components* column for NORMAL lists only SYS-001, SYS-002, SYS-004, SYS-005, SYS-008, SYS-009, SYS-010, SYS-011, SYS-013 (and "SYS-006 in its preparation phase"). SYS-003 (Implementation Engine) is absent — yet by the entry condition it MUST be the active driver of `v-model.implement`'s initial phase in NORMAL. This is an internal contradiction within a single row of the state-definitions table. Defect type: **Inconsistent** (ISO/IEC 20246:2017 §6.3). |
| **Recommendation** | Add `SYS-003 (pre-write-barrier phase)` to the Active SYS Components cell for NORMAL, mirroring the bracketed annotation used for SYS-006. Alternatively, narrow the entry-condition column to remove the `v-model.implement` reference and document the implement-initial phase as its own state. |

### PRF-SYS-003 — ERROR→NORMAL transition is semantically ambiguous (process exit vs. state recovery)

| Field | Value |
|-------|-------|
| **Severity** | Minor |
| **Location** | State-Transition Diagram, line 208: `Any state ── on failure / signal ──▶ ERROR ── after summary flush ──▶ NORMAL` |
| **Description** | The diagram models ERROR as recoverable, transitioning back to NORMAL "after summary flush". In reality, the ERROR state is defined (line 181) as "any command exit path with non-zero exit code", which terminates the process — there is no in-process return to NORMAL. The transition arrow conflates two distinct concepts: (a) the post-error housekeeping (SYS-012 summary emission) that completes inside the dying process, and (b) the *next* invocation of a bridge command, which is a fresh process and a separate state-machine instance. As drawn, the diagram suggests recoverable behaviour the system does not actually provide, which would mislead a reader cross-referencing this diagram for hazard-analysis (HAZ rows that depend on whether ERROR is terminal or recoverable). Defect type: **Ambiguous** (ISO/IEC 20246:2017 §6.3). |
| **Recommendation** | Either (a) make ERROR a terminal state in the diagram (`ERROR ──▶ [process exit]` — no arrow back to NORMAL), and add a textual note that a subsequent invocation re-enters NORMAL as a new process; or (b) introduce an explicit `EXIT` pseudo-state and route all terminal paths (NORMAL-completion, COMMITTING-success, ERROR) into it. Update the per-state mitigation note (line 219) accordingly so that the "best-effort summary emission" is described as occurring during the ERROR→EXIT transition rather than ERROR→NORMAL. |

### PRF-SYS-004 — State-definitions table lacks an explicit Exit / Transition-Trigger column

| Field | Value |
|-------|-------|
| **Severity** | Observation |
| **Location** | State Definitions table (lines 176–181) |
| **Description** | The four-state table provides Definition, Entry Condition, and Active Components columns, but no per-state *Exit Condition / Transition Trigger* column. Exit conditions are only inferable from the ASCII diagram. For a behavioural view used as the authoritative source by `hazard-analysis.md` (per the section's own rationale), having entry and exit conditions co-located in the table — rather than split across a table and a diagram — would make state determinism mechanically auditable and would simplify HAZ-row cross-referencing. Defect type: **Incomplete** (ISO/IEC 20246:2017 §6.3) — informational only because the diagram does cover the transitions. |
| **Recommendation** | Add a fifth column "Exit / Transition Trigger" listing, per state: NORMAL → {DRY-RUN on `--no-commit` after gate-pass; COMMITTING on default after gate-pass; ERROR on any uncaught failure}; DRY-RUN → {NORMAL on completion; ERROR on failure}; COMMITTING → {NORMAL on commit success; ERROR on failure}; ERROR → {EXIT after summary flush}. This redundancy with the ASCII diagram is intentional and conventional for behavioural views (e.g., UML state-table notation). |

---

## Design Quality Assessment

### Coverage Metrics

| Metric | Result | Notes |
|--------|--------|-------|
| **4 Mandatory IEEE 1016 Views** | ✓ Present | Decomposition, Dependency, Interface, Data Design — all populated with appropriate detail |
| **Supplementary Behavioural View** | ✓ Present (with defects above) | Operational States section added in pass C; satisfies the structural requirement of an enumerated state model with transition diagram and mitigation mapping |
| **REQ Traceability (SYS→REQ)** | ✓ 100% | 14 active SYS → 43 unique active REQs; no orphans |
| **Interface Error Handling** | ✓ Complete | All 7 external + 13 internal interfaces specify error semantics |
| **Algorithm Specification (SYS-006)** | ✓ Present | Pseudocode + properties table + out-of-scope clauses; supports HAZ-007/012/013 likelihood claims |
| **Derived Requirements** | ✓ None | Explicitly declared "None"; no implicit derivations |
| **Lifecycle Completeness** | ✓ Compliant | Zero deprecated, zero suspect, zero orphaned cascades |
| **Quality Attribute Coverage** | ✓ Mapped | All seven ISO/IEC 25010:2023 characteristics addressed |

### Lifecycle Validation (Section 4.10)

- **Deprecation syntax**: N/A — zero deprecated items.
- **Unresolved suspects**: None.
- **Coverage exclusion**: N/A — no deprecated items affect coverage computation.
- **Orphaned deprecation chains**: N/A — no deprecated parents.

No lifecycle defects identified.

### Standards Compliance

- **IEEE 1016:2009**: All four mandatory design views present; supplementary behavioural and quality-attribute viewpoints added; one citation defect noted (PRF-SYS-001).
- **IEEE 1028:2008 §5 (Technical Review)**: Entry criteria met (artifact complete, defect-detection focus); exit criteria met (all findings logged with severity, location, description, recommendation).
- **ISO/IEC 20246:2017**: Defect taxonomy applied (Wrong, Inconsistent, Ambiguous, Incomplete used in this pass).

---

## Conclusion

The artifact has materially improved since pass 1: the previously-flagged operational-state observation is resolved by a dedicated Behavioural View, and the SYS-006 Algorithm Specification continues to provide the deterministic-control evidence consumed by `hazard-analysis.md`. The four mandatory IEEE 1016 views remain complete and traceable. No Critical or Major defects were identified in this pass; the three Minor findings concentrate on the newly-added Operational States section (incorrect §5.2 citation, NORMAL-state internal inconsistency, and ambiguous ERROR-recovery semantics in the transition diagram), and one Observation suggests tabulating per-state exit triggers to harden the behavioural-view's machine-auditability.

**CI Exit Code**: 2 (Minor findings only; no Critical/Major — non-blocking warning).
