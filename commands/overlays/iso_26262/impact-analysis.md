# Impact Analysis — ISO 26262 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iso_26262`.
> It provides domain-specific safety impact assessment and ASIL re-evaluation sections for the base `impact-analysis` command.

## Safety Impact Assessment (ISO 26262-8 §8)

ISO 26262-8 §8 requires that every change to a safety-relevant item is preceded by a safety impact assessment. When running impact analysis in an ISO 26262 project, the report must include a **Safety Impact Assessment** section for each changed ID:

| Changed ID | ASIL Rating | Safety Goal Affected (HAZ-NNN) | Change Type | Safety Impact Level |
|-----------|-------------|-------------------------------|-------------|---------------------|
| REQ-NNN | ASIL [QM/A/B/C/D] | HAZ-NNN / None | [New / Modified / Deprecated] | [Safety-relevant / Non-safety] |
| SYS-NNN | ASIL [QM/A/B/C/D] | HAZ-NNN / None | [New / Modified / Deprecated] | [Safety-relevant / Non-safety] |

**Safety Impact Levels**:
- **Safety-relevant**: The changed item implements or allocates a safety mechanism, safety requirement, or safety goal — requires ASIL re-evaluation (see §2 below)
- **Non-safety (QM)**: The changed item has no ASIL rating and no traceability to a HAZ-NNN — standard change control applies, no ASIL re-evaluation needed

**Rules**:
- Every changed ID that carries an ASIL rating must appear in this table
- A change to a HAZ-NNN item is always safety-relevant and requires escalation to the functional safety manager
- Changes to ASIL D items require independent sign-off before the change is incorporated

## ASIL Re-evaluation (ISO 26262-8 §8.4)

ISO 26262-8 §8.4 requires that when a safety-relevant change is approved, the affected items' ASIL ratings are re-evaluated. For each safety-relevant change identified in §1, assess whether the ASIL assignment remains valid:

| Affected Item | Current ASIL | HARA Parameters Affected | Re-evaluation Required? | New ASIL (if changed) | Justification |
|--------------|-------------|--------------------------|------------------------|----------------------|--------------|
| REQ-NNN | ASIL [A–D] | Severity [S0–S3] / Exposure [E1–E4] / Controllability [C1–C3] | Yes / No | ASIL [A–D] / Unchanged | [Reason ASIL changes or remains the same] |

**When ASIL re-evaluation is required**:
- The change modifies the operational context (changes to Exposure or Controllability parameters)
- The change removes or weakens a safety mechanism (potentially increases Severity impact)
- The change introduces a new failure mode not covered by the existing HARA
- A downstream item's ASIL is elevated by the change (ASIL escalation cascade)

**Rules**:
- An ASIL increase (e.g., ASIL B → ASIL C) on any item triggers re-verification of all verification activities for that item at the new ASIL level
- An ASIL decrease must be justified by the functional safety manager and documented with a formal deviation record
- Re-evaluation results must be fed back into `hazard-analysis.md` before the impact analysis report is finalized

## Re-validation Order for Safety-Relevant Changes (ISO 26262-8 §8.3)

ISO 26262-8 §8.3 requires that the re-validation scope is defined before a safety-relevant change is implemented. Extend the base command's Re-validation Order with ASIL-specific prioritization:

| Priority | Artifact ID | ASIL | Re-validation Activity | Independence Required? |
|----------|------------|------|------------------------|----------------------|
| 1 (highest) | ASIL D items | D | Formal verification / full regression | Yes |
| 2 | ASIL C items | C | Structural coverage re-run + peer review | Yes (independent reviewer) |
| 3 | ASIL B items | B | Requirements-based testing, regression subset | No |
| 4 | ASIL A / QM items | A / QM | Smoke test + traceability check | No |

Re-validation must follow this priority order — ASIL D items must be re-validated and signed off before lower-ASIL items proceed.
