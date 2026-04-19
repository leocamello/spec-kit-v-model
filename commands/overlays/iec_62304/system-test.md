# System Test — IEC 62304 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iec_62304`.
> It provides domain-specific safety-critical test sections for the base `system-test` command.

## Testing Requirements by Safety Class (IEC 62304 §5.7)

Define testing requirements for each component based on its IEC 62304 safety class. IEC 62304 §5.7 specifies the verification activities required at each safety classification level.

| Component | Safety Class | Coverage Target | Test Scope | Verification Activities |
|-----------|-------------|-----------------|------------|-------------------------|
| SYS-NNN | Class C | Branch coverage recommended | Comprehensive functional + structural | IEC 62304 §5.7.1–§5.7.5 — all verification activities required |
| SYS-NNN | Class B | Statement coverage recommended | Functional testing required | IEC 62304 §5.7.1–§5.7.4 — most verification activities required |
| SYS-NNN | Class A | Best effort | Basic functional testing | IEC 62304 §5.7.1 — basic verification sufficient |

**Safety-Class-dependent Testing Requirements**:
- **Class C**: All IEC 62304 §5.7 activities apply — unit testing, integration testing, system testing, regression testing, and risk-based testing for all software safety requirements
- **Class B**: Unit testing, integration testing, and system testing required; regression testing recommended
- **Class A**: Basic functional testing sufficient; no specific structural coverage required

**Rules**:
- Testing scope derives from the safety class assignment in the system design
- Class C components must demonstrate traceability from tests to software safety requirements (SSRs)
- Anomaly resolution per IEC 62304 §9 required for all test failures in Class B and C components
- Document any test exclusions with risk-based justification per ISO 14971

## IEC 62304 §5.7 Verification Requirements

Additional verification activities mandated by IEC 62304 §5.7 for safety-classified software.

| Verification Activity | Class C | Class B | Class A |
|-----------------------|---------|---------|---------|
| Software unit verification (§5.5.5) | Required | Required | — |
| Software integration testing (§5.6.5) | Required | Required | — |
| Software system testing (§5.7.4) | Required | Required | Required |
| Risk-based test case derivation | Required (from ISO 14971 risk controls) | Recommended | — |
| Regression testing after changes | Required | Recommended | — |
| Anomaly resolution (§9) | Required for all failures | Required for all failures | Recommended |

**Rules**:
- Class C components: every software safety requirement (SSR) must have at least one test case
- Class B components: functional requirements must have test coverage
- Anomalies found during testing must be evaluated for their risk impact per IEC 62304 §9
- Test reports must be retained as part of the software development file per IEC 62304 §5.8
