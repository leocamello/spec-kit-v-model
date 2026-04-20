# Unit Test — ISO 26262 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iso_26262`.
> It provides domain-specific safety-critical unit test sections for the base `unit-test` command.
> Content in this overlay replaces the generic "Safety-Critical Techniques" in the base command when this domain is active.

## MC/DC Coverage (ISO 26262-6 §9.4.4 Table 11)

Modified Condition/Decision Coverage (MC/DC) is required for ASIL D and recommended for ASIL C per ISO 26262-6 §9.4.4 Table 11 (structural coverage of source code).

For each complex boolean decision in the Algorithmic/Logic View of **ASIL C–D modules** (e.g., `if (A and B or C)`):

- Generate a boolean truth table proving each individual condition (A, B, C) can independently affect the decision outcome
- Each row in the table becomes a UTS scenario
- Table format:

| Test | A | B | C | Decision | Independence Proof | ASIL |
|------|---|---|---|----------|--------------------|------|
| 1 | T | T | F | T | A flips: row 1 vs row 3 | [C/D] |
| 2 | T | F | F | F | B flips: row 1 vs row 2 | [C/D] |
| 3 | F | T | F | F | A flips: row 1 vs row 3 | [C/D] |
| 4 | T | F | T | T | C flips: row 2 vs row 4 | [C/D] |

**ASIL-dependent Coverage Requirements** (ISO 26262-6 §9.4.4 Table 11):
- **ASIL D**: MC/DC mandatory for all boolean decisions in safety-relevant code paths
- **ASIL C**: MC/DC recommended; Decision Coverage (DC) at minimum
- **ASIL B**: Branch Coverage (BC) at minimum; MC/DC for critical decisions
- **ASIL A**: Statement Coverage (SC) at minimum

**Rules**:
- Document MC/DC test pairs for every compound boolean decision in ASIL C–D modules
- MC/DC table MUST be included inline in the UTP for each qualifying decision
- Coverage measurement tools must be qualified per ISO 26262-8 §11

## Variable-Level Fault Injection (ISO 26262-6 §9.4.4 + ISO 26262-5 FMEA)

Fault injection testing verifies that internal error handling mechanisms work correctly. Required for ASIL D; recommended for ASIL C. Aligned with ISO 26262-6 §9.4.4 and fault tolerance verification in ISO 26262-5.

For each local variable in the Internal Data Structures view of **ASIL C–D modules**:

| Module | Variable | Fault Scenario | ASIL | Expected Detection | UTS Reference |
|--------|----------|---------------|------|-------------------|---------------|
| MOD-NNN | `var_name` | NULL/zero injection | [C/D] | [Error code / exception / watchdog] | UTS-NNN-X# |
| MOD-NNN | `var_name` | Max value overflow | [C/D] | [Range check / saturation] | UTS-NNN-X# |
| MOD-NNN | `var_name` | Negative (if unsigned) | [C/D] | [Type check / rejection] | UTS-NNN-X# |

**Fault Injection Scenarios**:
1. **Corrupt to NULL/zero**: Force the variable to null/zero after initialization — verify error detection
2. **Corrupt to max**: Force to maximum representable value — verify overflow/saturation handling
3. **Corrupt to negative**: Force to negative value (if unsigned type) — verify type rejection
4. **Corrupt to uninitialised**: Simulate use-before-initialization — verify defensive checks

**ASIL-dependent Rules**:
- **ASIL D**: Fault injection scenarios required for all safety-relevant variables in critical modules; residual fault metrics must meet ISO 26262-5 PMHF targets
- **ASIL C**: Fault injection for critical variables; at minimum boundary and NULL scenarios
- **ASIL A–B**: Fault injection scenarios encouraged; Error Guessing technique sufficient for formal coverage
