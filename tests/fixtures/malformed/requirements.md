# Requirements Specification

## Requirements

### Functional Requirements

#### REQ001: Missing Dash
**Description:** This ID is missing the dash between REQ and the number.
**Priority:** P1
**Verification Method:** Test

#### REQ-ABC: Non-Numeric ID
**Description:** This ID uses letters instead of numbers.
**Priority:** P1
**Verification Method:** Test

#### REQ-1: Too Few Digits
**Description:** This ID has only 1 digit instead of 3.
**Priority:** P1
**Verification Method:** Test

#### REQ-0001: Too Many Digits
**Description:** This ID has 4 digits instead of 3.
**Priority:** P1
**Verification Method:** Test

#### REQ-001: Valid ID (Duplicate)
**Description:** This is a valid ID format but duplicated intentionally.
**Priority:** P1
**Verification Method:** Test

#### REQ-001: Valid ID (Duplicate)
**Description:** Second occurrence of REQ-001 to test duplicate detection.
**Priority:** P1
**Verification Method:** Test

## Summary

| Category | Count |
|----------|-------|
| Functional | 6 (with formatting issues) |
