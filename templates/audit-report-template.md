# Release Audit Report

## 1. Executive Summary

**System**: [SYSTEM_NAME]
**Version**: [VERSION]
**Git Tag**: [GIT_TAG] (commit [GIT_SHA])
**Date**: [DATE]
**Regulatory Context**: [REGULATORY_CONTEXT]

[TOTAL_REQS] requirements traced across [MATRIX_COUNT] traceability matrices.
[TOTAL_TESTS] test scenarios executed: [PASSED_COUNT] passed, [FAILED_COUNT] failed, [SKIPPED_COUNT] skipped.
[TOTAL_HAZARDS] hazards identified; [MITIGATED_HAZARDS] mitigated.
[ANOMALY_COUNT] anomalies detected: [WAIVED_COUNT] waived, [BLOCKING_COUNT] blocking.

**Compliance Status**: [COMPLIANCE_STATUS]

## 2. Artifact Inventory

| Artifact | File | Git SHA | Last Modified | Status |
|----------|------|---------|---------------|--------|
[ARTIFACT_ROWS]

## 3. Traceability Matrices

[MATRIX_SECTIONS]

## 3.1 Lifecycle Status Summary

| Artifact | Active | Deprecated | Suspect | Total |
|----------|--------|------------|---------|-------|
[LIFECYCLE_ROWS]

### Unresolved Suspects

[UNRESOLVED_SUSPECTS_TABLE]

<!-- If no unresolved suspects: "None — all lifecycle states resolved." -->

## 4. Coverage Analysis

| Matrix | Forward Coverage | Backward Coverage | Gaps | Orphans |
|--------|-----------------|-------------------|------|---------|
[COVERAGE_ROWS]

## 5. Hazard Management Summary

[HAZARD_SECTION]

## 6. Known Anomalies

[ANOMALY_SECTION]

## 7. Signature Block

| Role | Name | Signature | Date |
|------|------|-----------|------|
| QA Manager | _________________ | _________________ | __________ |
| Lead Engineer | _________________ | _________________ | __________ |
| Release Tag | [GIT_TAG] | Git SHA: [GIT_SHA] | [DATE] |
