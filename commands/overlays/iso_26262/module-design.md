# Module Design — ISO 26262 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iso_26262`.
> It provides domain-specific safety-critical module design sections for the base `module-design` command.
> Content in this overlay replaces the generic "Safety-Critical Sections" in the base command when this domain is active.

## Complexity Constraints (ISO 26262-6 §8.4.5 + MISRA C:2012 / MISRA C++:2023)

For each `MOD-NNN`, document the complexity constraints required for ISO 26262-6 §8.4.5 ("Source Code") and the project's MISRA coding standard compliance:

| Module | ASIL Rating | Cyclomatic Complexity Limit | MISRA/CERT-C Rules Applied | Justified Deviations |
|--------|-------------|----------------------------|---------------------------|----------------------|
| MOD-NNN | ASIL [A–D] | ≤ [10 / 15 / 20] per function | MISRA C:2012 / MISRA C++:2023 | [Deviation ID + rationale] |

**ASIL-dependent Complexity Limits**:
- **ASIL D**: Cyclomatic complexity ≤ 10 per function; MISRA C:2012 mandatory ruleset (all required rules + advisory rules unless explicitly deviated)
- **ASIL C**: Cyclomatic complexity ≤ 15; MISRA C:2012 mandatory ruleset with documented deviations
- **ASIL B**: Cyclomatic complexity ≤ 20; MISRA C:2012 recommended ruleset
- **ASIL A**: Cyclomatic complexity ≤ 25; MISRA guidelines applied as best practice

**Rules**:
- Every deviation from a MISRA required or advisory rule MUST have a Deviation Record (DR-NNN) with: rule ID, location, rationale, impact assessment, and approval reference
- Deviation records are maintained in the project's coding standards deviation log
- Tools used for complexity analysis must be qualified per ISO 26262-8 §11 (TCL1–TCL3)

## Memory Management (ISO 26262-6 §8.4.5 Table 13)

For each `MOD-NNN`, document memory management constraints aligned with ISO 26262-6 §8.4.5 Table 13 (coding guidelines):

| Module | ASIL Rating | Dynamic Allocation Policy | Allocation Phase | Stack Estimate | Heap Budget |
|--------|-------------|--------------------------|-----------------|----------------|-------------|
| MOD-NNN | ASIL [A–D] | Forbidden after init / Init-time only | [Startup / Never] | [bytes] | [bytes or N/A] |

**ASIL-dependent Memory Rules**:
- **ASIL D**: Dynamic memory allocation forbidden after initialization; all allocations during startup only; heap budget statically verified
- **ASIL C**: Dynamic allocation forbidden after initialization; stack usage verified by analysis
- **ASIL B**: Dynamic allocation restricted; unbounded loops forbidden (all loops must have provable termination condition)
- **ASIL A**: Dynamic allocation documented; unbounded loops flagged for review

**Additional Rules**:
- All loops MUST have a provable worst-case iteration count (or `[UNBOUNDED-JUSTIFIED: reason]` annotation)
- Stack depth estimates MUST account for worst-case function call chains
- Freedom from Interference (FFI) — see ISO 26262-6 §7.4.8: document memory partitioning between ASIL-rated and QM components

## Single Entry/Exit and Restricted Control Flow (ISO 26262-6 §8.4.5 + MISRA C:2012 Rule 15.5)

For each `MOD-NNN` with ASIL C or D rating, enforce single entry/exit and restricted control flow per ISO 26262-6 §8.4.5 and MISRA C:2012 Rule 15.5:

| Module | ASIL Rating | Entry Points | Exit Points | Guard Clauses Restructured? | Notes |
|--------|-------------|-------------|-------------|----------------------------|-------|
| MOD-NNN | ASIL [C/D] | 1 | 1 | Yes / No (justified) | [How early-return patterns are handled] |

**Rules**:
- **ASIL D**: Strictly one entry and one exit per function (MISRA C:2012 Rule 15.5 mandatory)
- **ASIL C**: Strongly recommended; deviations require documented rationale
- **ASIL A–B**: Guided by MISRA advisory rules; multiple returns allowed with justification
- Early-return guard clauses must be restructured to use a single return variable pattern
- Document how `goto` (MISRA C:2012 Rule 15.1 — banned) is avoided

## Additional Review Criteria (peer-review overlays only)

### Module Design — ISO 26262 Extensions

When reviewing `module-design.md` under ISO 26262:
- **ASIL Consistency**: Does each MOD-NNN's ASIL rating match the parent ARCH-NNN's ASIL allocation?
- **Complexity Limits**: Are complexity limits set per ASIL level (≤10 for ASIL D)?
- **MISRA Compliance**: Is the applicable MISRA standard identified (MISRA C:2012 or MISRA C++:2023)?
- **Deviation Records**: Are all MISRA deviations formally recorded with DR-NNN identifiers?
- **Memory Rules**: Is dynamic allocation forbidden/restricted per ASIL level?
- **Single Entry/Exit**: Are ASIL D modules strictly single-exit? Are deviations justified?
