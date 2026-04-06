# Hazard Analysis (FMEA): Waived Fixture

## Hazard Register (FMEA)

| HAZ ID | Component | Failure Mode | Severity | Likelihood | Risk Level | Mitigation | Residual Risk |
|--------|-----------|-------------|----------|-----------|------------|------------|---------------|
| HAZ-001 | SYS-001 | Data Processor returns corrupted readings | Serious | Occasional | Undesirable | REQ-001 (input validation) | Tolerable |
| HAZ-002 | SYS-002 | Alert Engine fails to detect threshold | Critical | Remote | Undesirable | REQ-002 (redundant check) | Tolerable |
