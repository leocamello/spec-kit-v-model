# Hazard Analysis (FMEA): Clean Fixture

## Hazard Register (FMEA)

| HAZ ID | Component | Failure Mode | Severity | Likelihood | Risk Level | Mitigation | Residual Risk |
|--------|-----------|-------------|----------|-----------|------------|------------|---------------|
| HAZ-001 | SYS-001 | Data Processor returns corrupted readings | Serious | Occasional | Undesirable | REQ-001 (input validation) | Tolerable |
| HAZ-002 | SYS-002 | Alert Engine fails to detect threshold | Critical | Remote | Undesirable | REQ-002 (redundant check) | Tolerable |
| HAZ-003 | SYS-003 | Display fails to update | Minor | Remote | Acceptable | REQ-003 (staleness indicator) | Acceptable |
