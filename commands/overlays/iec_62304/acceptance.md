# Acceptance — IEC 62304 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iec_62304`.
> It provides domain-specific safety-critical acceptance testing sections for the base `acceptance` command.

## Safety Class–Dependent Test Completeness (§5.7)

IEC 62304 requires different levels of testing rigor based on the software safety class:

| Activity | Class A | Class B | Class C |
|---|---|---|---|
| Software requirements verification | — | ✓ | ✓ |
| Software acceptance testing | — | ✓ | ✓ |
| Traceability to risk control measures | — | ✓ | ✓ |
| Test against known anomaly lists (SOUP) | — | ✓ | ✓ |
| Independent review of test results | — | — | ✓ |

- **Class C software** requires the most comprehensive acceptance testing — every requirement must have at least one acceptance test, AND test results must be independently reviewed.
- **Class B software** requires acceptance testing with traceability to risk control measures.
- **Class A software** has minimal formal testing requirements, but good practice still recommends functional verification.

## Risk Control Measure Verification

For requirements tagged `[RISK CONTROL: HAZ-NNN]`, generate acceptance tests that specifically verify:

1. **Effectiveness**: The risk control measure reduces the risk to an acceptable level under normal conditions.
2. **Reliability**: The risk control measure functions correctly under foreseeable fault conditions.
3. **No new hazards**: The risk control measure does not introduce new hazards or worsen existing ones (per ISO 14971 §7.4).

These scenarios should reference the specific hazard ID (HAZ-NNN) and the residual risk level after mitigation.

## SOUP Component Acceptance

If acceptance tests cover functionality provided by SOUP components:

- Include scenarios that verify the SOUP component performs as expected for the intended use.
- Include negative scenarios based on the SOUP component's known anomaly list (§7.1.3).
- Verify that SOUP component updates do not regress existing acceptance criteria.

## Usability Validation (IEC 62366-1)

For medical devices with a user interface, acceptance tests should include usability-related scenarios:

- Task completion scenarios aligned with IEC 62366-1 usability engineering.
- Error recovery scenarios for reasonably foreseeable use errors.
- Scenarios verifying that critical safety information is presented clearly to the user.

> **Note:** Usability validation for medical devices is governed by IEC 62366-1:2015. The quality-in-use criteria from the base command (Step 6d) align with this standard.

## Regression Testing After Changes

IEC 62304 §5.7 and §6 require regression testing after software changes to ensure that existing functionality is not adversely affected:

- When requirements are modified, added, or deprecated, generate regression test scenarios that verify unchanged requirements still pass.
- **Class C**: Full regression testing required — all previously passing acceptance tests must be re-executed after any change.
- **Class B**: Regression testing required for affected areas — impact analysis determines the regression scope.
- **Class A**: Regression testing recommended but not mandatory.
- Regression test scope must be documented and justified based on the impact analysis (§6).
