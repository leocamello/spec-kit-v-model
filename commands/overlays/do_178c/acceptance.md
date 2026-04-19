# Acceptance — DO-178C Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: do_178c`.
> It provides domain-specific safety-critical acceptance testing sections for the base `acceptance` command.

## Structural Coverage by DAL (§6.4.2, Table A-7)

DO-178C Table A-7 specifies structural coverage criteria by Design Assurance Level. When generating acceptance tests, ensure test cases provide sufficient coverage for the applicable DAL:

| Coverage Criterion | DAL A | DAL B | DAL C | DAL D |
|---|---|---|---|---|
| Statement coverage | ✓ | ✓ | ✓ | — |
| Decision coverage | ✓ | ✓ | — | — |
| MC/DC (Modified Condition/Decision Coverage) | ✓ | — | — | — |

- **DAL A**: Acceptance tests must be designed to support MC/DC structural coverage. Each condition in a decision must be shown to independently affect the decision outcome.
- **DAL B**: Tests must support decision coverage — every decision point must be exercised for both true and false outcomes.
- **DAL C**: Tests must support statement coverage — every executable statement must be exercised.
- **DAL D**: Basic functional testing is sufficient.

Tag test cases with their DAL to indicate the required coverage rigor.

## Test Independence Requirements

DO-178C requires different levels of test independence by DAL:

- **DAL A/B**: Tests should be reviewable by an independent reviewer (not the developer of the tested code).
- **DAL A**: Test results must be independently verified — include verification steps in scenarios.

## Verification of Derived Requirements

- Acceptance tests for derived requirements (`[DERIVED]`) must include additional scenarios verifying that the derived requirement does not introduce unintended functionality.
- These tests help demonstrate to the certification authority that derived requirements are necessary and correct.

## Deactivated Code and Configuration

- If requirements have been deprecated (`[DEPRECATED]`), verify that the deactivated code path cannot be inadvertently activated.
- Generate negative test scenarios that confirm deactivated features remain inactive under all operational conditions.

## Robustness Testing (§6.4.2)

DO-178C §6.4.2 requires robustness testing (also known as normal-range and abnormal-range testing) for DAL A–C software. When generating acceptance tests:

- **Normal-range tests**: Verify correct behavior with valid inputs within the expected operating envelope.
- **Abnormal-range tests**: Verify correct error handling with invalid inputs, out-of-range values, and unexpected sequences.
- **DAL A–B**: Both normal-range and abnormal-range test cases are mandatory per Table A-7.
- **DAL C**: Normal-range testing mandatory; abnormal-range testing recommended.
- Robustness test cases should exercise boundary conditions, overflow scenarios, and timing edge cases.
