# Unit Test — DO-178C Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: do_178c`.
> It provides domain-specific safety-critical unit test sections for the base `unit-test` command.
> Content in this overlay replaces the generic "Safety-Critical Techniques" in the base command when this domain is active.

## Structural Coverage Analysis (DO-178C §6.4.4 Table A-7)

DO-178C §6.4.4 Tables A-7 and A-8 define mandatory structural coverage levels for software unit testing by Design Assurance Level (DAL). Coverage is measured against the low-level requirements (module design).

**DAL-dependent Coverage Objectives** (DO-178C Table A-7):
- **DAL A**: Modified Condition/Decision Coverage (MC/DC) — every boolean condition proven independently influencing
- **DAL B**: Decision Coverage (DC) — every branch in each decision taken at least once
- **DAL C**: Statement Coverage (SC) — every statement executed at least once
- **DAL D**: No structural coverage objective (testing against low-level requirements sufficient)
- **DAL E**: Not applicable

For each complex boolean decision in the Algorithmic/Logic View of **DAL A modules**:

| Test | A | B | C | Decision | Independence Proof | DAL |
|------|---|---|---|----------|--------------------|-----|
| 1 | T | T | F | T | A flips: row 1 vs row 3 | A |
| 2 | T | F | F | F | B flips: row 1 vs row 2 | A |
| 3 | F | T | F | F | A flips: row 1 vs row 3 | A |
| 4 | T | F | T | T | C flips: row 2 vs row 4 | A |

**Rules for DAL A MC/DC**:
- MC/DC table MUST be included inline in the UTP for each qualifying boolean decision in DAL A modules
- Each pair of test cases demonstrating independence must be explicitly referenced (row pairs)
- Coverage measurement tools must be qualified per DO-330 §5 (Tool Qualification Level TQL-1 for DAL A coverage tools)
- Deactivated code: Any code intentionally not activated during testing must be identified and justified in the SW Accomplishment Summary

## Additional Structural Coverage Notes (DO-178C §6.4.4.2)

DO-178C §6.4.4.2 adds requirements beyond basic structural coverage:

| Coverage Item | DAL A Requirement | DAL B Requirement | Notes |
|---------------|------------------|------------------|-------|
| Data coupling | All data coupling paths exercised | Key paths exercised | DO-178C §6.4.4.2a |
| Control coupling | All invocation paths exercised | Key paths exercised | DO-178C §6.4.4.2b |
| Deactivated code | Identified + justified | Identified + justified | DO-178C §6.4.4.3 |

**Data and Control Coupling Coverage** (DO-178C §6.4.4.2):
- **Data coupling**: The unit tests must demonstrate that data communicated between modules (inputs/outputs) is used correctly; for each MOD-NNN output, at least one test must verify correct data propagation
- **Control coupling**: The unit tests must demonstrate that control flows between modules (call sequences, conditional invocations) behave correctly; for each conditional call to an external module, test both taken and not-taken paths

**Deactivated Code Policy** (DO-178C §6.4.4.3):
- Code that cannot be exercised during normal testing (e.g., dead code, defensive error handlers never triggered in test) must be explicitly identified in the unit test plan
- Each deactivated code item must have a justification entry in the Software Accomplishment Summary (SAS)
- Deactivated code that cannot be justified must be removed

## Fault Injection (DO-178C Guidance — Robustness Testing)

While DO-178C does not mandate fault injection by name, robustness testing is required at DAL A–B to ensure incorrect inputs and operational conditions are handled safely. For each `MOD-NNN` at DAL A–B:

| Module | Input/Variable | Fault Scenario | DAL | Expected Handling | UTS Reference |
|--------|---------------|---------------|-----|------------------|---------------|
| MOD-NNN | `param_name` | Out-of-range value | [A/B] | Rejection + error code | UTS-NNN-X# |
| MOD-NNN | `param_name` | NULL pointer | [A/B] | Null check + safe return | UTS-NNN-X# |
| MOD-NNN | `param_name` | Max boundary + 1 | [A/B] | Boundary rejection | UTS-NNN-X# |

**Rules**:
- Robustness tests are part of the requirements-based test suite (DO-178C §6.4.2.1f): "test for robustness including the response to abnormal inputs and environments"
- All robustness test scenarios must trace to low-level requirements in module-design.md (error handling specifications)
