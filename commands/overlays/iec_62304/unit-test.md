# Unit Test — IEC 62304 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iec_62304`.
> It provides domain-specific safety-critical unit test sections for the base `unit-test` command.
> Content in this overlay replaces the generic "Safety-Critical Techniques" in the base command when this domain is active.

## Unit Verification by Safety Class (IEC 62304 §5.5)

IEC 62304 §5.5 defines software unit verification requirements that vary by safety class. Unit tests must verify that each software unit implements its requirements correctly.

**Safety-Class-dependent Verification Objectives** (IEC 62304 §5.5):
- **Class C**: Full unit verification required (IEC 62304 §5.5.1–5.5.3): test each unit against its detailed design; code review required; appropriate testing techniques (boundary value analysis, equivalence partitioning, decision coverage); independent review recommended
- **Class B**: Unit verification required; testing techniques appropriate to the design complexity; code coverage documented
- **Class A**: Unit verification recommended; no specific technique mandated

For each `MOD-NNN` unit test plan, document the safety class and corresponding verification completeness:

| Module | Safety Class | Test Techniques Applied | Coverage Achieved | Code Review Performed? | Independent Review? |
|--------|-------------|------------------------|-------------------|----------------------|-------------------|
| MOD-NNN | Class [A/B/C] | [EP / BVA / DC / SC / etc.] | [%] | Yes / No | Class C: Required / Class A–B: Optional |

## Risk Control Verification (IEC 62304 §5.5 + ISO 14971)

For modules that implement risk control measures (modules tracing to HAZ-NNN mitigations), unit tests must verify that the risk control is effective. IEC 62304 §5.5 requires that software implementing risk controls is verified to perform correctly.

| Module | HAZ Mitigation | Risk Control Verified By | Test Scenario | Expected Result | UTS Reference |
|--------|---------------|-------------------------|---------------|-----------------|---------------|
| MOD-NNN | HAZ-NNN | [Unit test / Integration test] | [Fault condition that risk control handles] | [Safe state achieved] | UTS-NNN-X# |

**Rules**:
- Every `MOD-NNN` that traces to a `HAZ-NNN` mitigation MUST have at least one UTP that directly verifies the risk control behavior
- The test scenario must simulate the hazardous condition (or its precursors) and verify the mitigation activates correctly
- Residual risk acceptance: document that the unit test evidence is part of the ISO 14971 risk management file

## Robustness Testing (IEC 62304 §5.5.2 — Anomalous Inputs)

For Class B–C modules, verify robustness against anomalous inputs per IEC 62304 §5.5.2:

| Module | Safety Class | Anomalous Input | Expected Behavior | UTS Reference |
|--------|-------------|-----------------|-------------------|---------------|
| MOD-NNN | Class [B/C] | NULL/undefined input | Safe rejection + error code | UTS-NNN-X# |
| MOD-NNN | Class [B/C] | Out-of-range value | Boundary rejection | UTS-NNN-X# |
| MOD-NNN | Class [B/C] | Concurrent access (if applicable) | Thread-safe handling | UTS-NNN-X# |

**Rules**:
- IEC 62304 §5.5.2 requires testing that software units handle anomalous conditions (incorrect inputs, error states, boundary conditions) without compromising safety
- For Class C modules implementing risk controls: anomalous input handling is a critical path — verify that safety functions are not disabled by invalid inputs
- Document how anomalous input tests relate to the software's Failure Mode and Effects Analysis (FMEA) at module level
