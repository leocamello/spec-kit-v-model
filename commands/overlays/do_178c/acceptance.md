# DO-178C — Acceptance Command Overlay

## Domain-Specific Acceptance Testing Guidance

### Structural Coverage by DAL (§6.4.2, Table A-7)

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

### Test Independence Requirements

DO-178C requires different levels of test independence by DAL:

- **DAL A/B**: Tests should be reviewable by an independent reviewer (not the developer of the tested code).
- **DAL A**: Test results must be independently verified — include verification steps in scenarios.

### Verification of Derived Requirements

- Acceptance tests for derived requirements (`[DERIVED]`) must include additional scenarios verifying that the derived requirement does not introduce unintended functionality.
- These tests help demonstrate to the certification authority that derived requirements are necessary and correct.

### Deactivated Code and Configuration

- If requirements have been deprecated (`[DEPRECATED]`), verify that the deactivated code path cannot be inadvertently activated.
- Generate negative test scenarios that confirm deactivated features remain inactive under all operational conditions.
