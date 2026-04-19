# Traceability Matrix

**Generated**: 2026-04-19
**Source**: `specs/001-v-model-mvp/v-model/`

## Matrix A — Validation (User View)

| Requirement ID | Requirement Description | Test Case ID (ATP) | Validation Condition | Scenario ID (SCN) | Status |
|----------------|------------------------|--------------------|----------------------|--------------------|--------|
| **REQ-001** | The system SHALL generate a structured V-Model Requirements Specification document from a feature description or existing `spec.md` in a single command invocation. | ATP-001-A | Generate from spec.md | SCN-001-A1 | ⬜ Untested |
| | | ATP-001-B | Generate from text input | SCN-001-B1 | ⬜ Untested |
| | | ATP-001-B | Generate from text input | SCN-001-B2 | ⬜ Untested |
| **REQ-002** | The system SHALL assign each requirement a unique, permanent identifier using the pattern `REQ-NNN` (zero-padded, sequential numbering starting at 001). | ATP-002-A | Sequential zero-padded numbering | SCN-002-A1 | ⬜ Untested |
| | | ATP-002-B | ID permanence across re-invocations | SCN-002-B1 | ⬜ Untested |
| **REQ-003** | The system SHALL categorize every requirement into exactly one of four types: Functional (`REQ-NNN`), Non-Functional (`REQ-NF-NNN`), Interface (`REQ-IF-NNN`), or Constraint (`REQ-CN-NNN`). | ATP-003-A | All four categories present | SCN-003-A1 | ⬜ Untested |
| | | ATP-003-B | Empty categories omitted | SCN-003-B1 | ⬜ Untested |
| **REQ-004** | The system SHALL validate every generated requirement against eight quality criteria: unambiguous, testable, atomic, complete, consistent, traceable, feasible, and necessary. | ATP-004-A | All criteria satisfied | SCN-004-A1 | ⬜ Untested |
| | | ATP-004-B | Infeasible requirements flagged | SCN-004-B1 | ⬜ Untested |
| **REQ-005** | The system SHALL replace all banned vague terms (fast, user-friendly, robust, seamless, intuitive, efficient, reasonable, significant, adequate, minimal, approximately, scalable, secure, reliable, flexible) with measurable, testable language in generated requirements. | ATP-005-A | Banned terms detected and replaced | SCN-005-A1 | ⬜ Untested |
| | | ATP-005-A | Banned terms detected and replaced | SCN-005-A2 | ⬜ Untested |
| **REQ-006** | The system SHALL generate a three-tier Acceptance Test Plan containing test cases (`ATP-NNN-X`) and BDD scenarios (`SCN-NNN-X#`) for every active requirement in `requirements.md`. | ATP-006-A | Generate ATPs and SCNs for all active requirements | SCN-006-A1 | ⬜ Untested |
| | | ATP-006-B | Deprecated requirements excluded from generation | SCN-006-B1 | ⬜ Untested |
| **REQ-007** | The test artifact ID schema SHALL encode lineage such that `SCN-NNN-X#` traces to `ATP-NNN-X` which traces to `REQ-NNN` (e.g., `SCN-001-A1` traces to `ATP-001-A` traces to `REQ-001`). | ATP-007-A | Functional requirement lineage encoding | SCN-007-A1 | ⬜ Untested |
| | | ATP-007-B | Non-functional requirement lineage encoding | SCN-007-B1 | ⬜ Untested |
| **REQ-008** | The system SHALL enforce 100% bidirectional coverage: every active REQ SHALL have at least one ATP, and every ATP SHALL have at least one SCN. | ATP-008-A | Full coverage achieved | SCN-008-A1 | ⬜ Untested |
| | | ATP-008-B | Coverage gap detection | SCN-008-B1 | ⬜ Untested |
| **REQ-009** | The system SHALL produce a bidirectional Requirements Traceability Matrix with forward tracing (REQ to ATP to SCN) and backward tracing (SCN to ATP to REQ). | ATP-009-A | Forward tracing REQ → ATP → SCN | SCN-009-A1 | ⬜ Untested |
| | | ATP-009-B | Backward tracing SCN → ATP → REQ | SCN-009-B1 | ⬜ Untested |
| **REQ-010** | The traceability matrix SHALL include a coverage audit section (counts and percentages), an exception report (gaps and orphans), and baseline information (timestamps and source file references). | ATP-010-A | All matrix sections present | SCN-010-A1 | ⬜ Untested |
| | | ATP-010-B | Exception report identifies gaps | SCN-010-B1 | ⬜ Untested |
| **REQ-011** | Coverage validation and traceability matrix generation SHALL be performed by deterministic scripts (`validate-requirement-coverage.sh`, `build-matrix.sh`), not by AI self-assessment. | ATP-011-A | Scripts produce consistent results | SCN-011-A1 | ⬜ Untested |
| | | ATP-011-B | AI not used for coverage calculation | SCN-011-B1 | ⬜ Untested |
| **REQ-012** | The system SHALL support incremental updates: existing requirement IDs SHALL never be renumbered; new requirements SHALL receive the next available sequential ID. | ATP-012-A | New requirements receive next sequential ID | SCN-012-A1 | ⬜ Untested |
| | | ATP-012-B | IDs preserved after requirement removal | SCN-012-B1 | ⬜ Untested |
| **REQ-013** | The system SHALL support the full ID lifecycle model with the following states: Active, `[DEPRECATED — Superseded by REQ-NNN]`, `[DEPRECATED — Withdrawn: <reason>]`, `[MODIFIED]`, and `[SUSPECT — Parent ... modified/deprecated]`. | ATP-013-A | DEPRECATED states supported | SCN-013-A1 | ⬜ Untested |
| | | ATP-013-B | SUSPECT propagation to downstream artifacts | SCN-013-B1 | ⬜ Untested |
| **REQ-014** | Deprecated requirements SHALL remain in the document with their original ID and full content history; requirements SHALL never be deleted from the specification. | ATP-014-A | Deprecated requirements remain in document | SCN-014-A1 | ⬜ Untested |
| | | ATP-014-B | Content history preserved for audit trail | SCN-014-B1 | ⬜ Untested |
| **REQ-015** | The system SHALL detect requirement changes (added, modified, removed) by comparing the working copy of `requirements.md` against the last Git-committed version. | ATP-015-A | Added requirements detected | SCN-015-A1 | ⬜ Untested |
| | | ATP-015-B | Modified requirements detected | SCN-015-B1 | ⬜ Untested |
| | | ATP-015-C | Removed requirements detected | SCN-015-C1 | ⬜ Untested |
| **REQ-016** | All generated V-Model artifacts SHALL be plaintext Markdown files stored in a Git-tracked directory at `specs/{feature}/v-model/`. | ATP-016-A | Output format and location | SCN-016-A1 | ⬜ Untested |
| **REQ-017** | All generative commands SHALL support domain overlay loading via the assembly protocol: when `domain` is configured in `v-model-config.yml`, the system SHALL load domain-specific guidance from `commands/overlays/{domain}/{command}.md` and apply it alongside the base command. | ATP-017-A | Overlay loaded when domain configured | SCN-017-A1 | ⬜ Untested |
| | | ATP-017-B | Base-only when no domain configured | SCN-017-B1 | ⬜ Untested |
| **REQ-018** | Commands that use templates SHALL also load template overlays from `templates/overlays/{domain}/{template}.md` when a domain is configured. | ATP-018-A | Template overlay sections appended | SCN-018-A1 | ⬜ Untested |
| **REQ-019** | The acceptance command SHALL validate test plan completeness against IEEE 1012:2016 V&V principles, including entry/exit criteria, validation vs. verification distinction, and V&V traceability. | ATP-019-A | Entry and exit criteria present | SCN-019-A1 | ⬜ Untested |
| | | ATP-019-B | Validation vs verification distinction | SCN-019-B1 | ⬜ Untested |
| **REQ-020** | The `validate-requirement-coverage.sh` script SHALL exit with code 0 when 100% REQ-to-ATP and ATP-to-SCN coverage is achieved, and exit with code 1 when coverage gaps exist. | ATP-020-A | Exit code 0 for full coverage | SCN-020-A1 | ⬜ Untested |
| | | ATP-020-B | Exit code 1 for coverage gaps | SCN-020-B1 | ⬜ Untested |
| **REQ-021** | The `validate-requirement-coverage.sh` script SHALL support a `--json` flag that produces valid JSON output containing `has_gaps`, `reqs_without_atp`, `atps_without_scn`, and coverage percentage fields. | ATP-021-A | Valid JSON with required fields | SCN-021-A1 | ⬜ Untested |
| | | ATP-021-B | JSON output without --json flag | SCN-021-B1 | ⬜ Untested |
| **REQ-022** | The requirements command SHALL return a descriptive error message when invoked with an empty feature description and no existing `spec.md`. | ATP-022-A | Descriptive error for missing input | SCN-022-A1 | ⬜ Untested |
| **REQ-023** | The system SHALL accept gaps in requirement ID numbering (e.g., REQ-001, REQ-003, REQ-007) without renumbering existing IDs. | ATP-023-A | Non-sequential IDs accepted | SCN-023-A1 | ⬜ Untested |
| | | ATP-023-A | Non-sequential IDs accepted | SCN-023-A2 | ⬜ Untested |
| **REQ-024** | Deterministic scripts SHALL fail gracefully with descriptive error messages when encountering malformed Markdown input, rather than producing corrupt output. | ATP-024-A | Malformed Markdown produces descriptive error | SCN-024-A1 | ⬜ Untested |
| | | ATP-024-A | Malformed Markdown produces descriptive error | SCN-024-A2 | ⬜ Untested |
| **REQ-025** | The traceability matrix SHALL be computed by the deterministic `build-matrix.sh` script, not by AI generation. | ATP-025-A | Matrix computed by script | SCN-025-A1 | ⬜ Untested |
| **REQ-CN-001** | The system SHALL operate within a Git repository initialized with Spec Kit and the V-Model extension installed and registered via `specify extension add`. | ATP-CN-001-A | Error in non-Git directory | SCN-CN-001-A1 | ⬜ Untested |
| **REQ-CN-002** | Feature descriptions and all generated artifacts SHALL be in English. | ATP-CN-002-A | Artifacts generated in English | SCN-CN-002-A1 | ⬜ Untested |
| **REQ-CN-003** | The system SHALL require an AI assistant (GitHub Copilot or equivalent) to execute the generative slash commands that invoke the AI-powered generation prompts. | ATP-CN-003-A | Generative commands need AI runtime | SCN-CN-003-A1 | ⬜ Untested |
| **REQ-IF-001** | The requirements command SHALL accept input from either a `spec.md` file (primary), inline user text arguments, or both (`spec.md` as primary with text as supplementary context). | ATP-IF-001-A | spec.md as primary input | SCN-IF-001-A1 | ⬜ Untested |
| | | ATP-IF-001-B | Text argument as input | SCN-IF-001-B1 | ⬜ Untested |
| | | ATP-IF-001-C | Both spec.md and text argument | SCN-IF-001-C1 | ⬜ Untested |
| **REQ-IF-002** | The requirements command output SHALL conform to the structure defined in `templates/requirements-template.md`, including header, requirements tables, assumptions, dependencies, glossary, and summary metrics sections. | ATP-IF-002-A | Output matches template structure | SCN-IF-002-A1 | ⬜ Untested |
| **REQ-IF-003** | The `setup-v-model.sh` script SHALL return a JSON object containing `VMODEL_DIR`, `FEATURE_DIR`, `BRANCH`, `SPEC`, `REQUIREMENTS`, and `AVAILABLE_DOCS` fields. | ATP-IF-003-A | All required JSON fields present | SCN-IF-003-A1 | ⬜ Untested |
| | | ATP-IF-003-B | AVAILABLE_DOCS reflects actual files | SCN-IF-003-B1 | ⬜ Untested |
| **REQ-NF-001** | Commands SHALL be domain-agnostic in their base form; adding a new regulated domain SHALL require only adding overlay files with no modification to base commands. | ATP-NF-001-A | New domain added via overlays only | SCN-NF-001-A1 | ⬜ Untested |
| | | ATP-NF-001-B | Base commands unchanged after overlay addition | SCN-NF-001-B1 | ⬜ Untested |
| **REQ-NF-002** | Coverage validation scripts SHALL produce deterministic results: the same inputs SHALL always produce the same outputs, regardless of AI model version or invocation context. | ATP-NF-002-A | Identical outputs for identical inputs | SCN-NF-002-A1 | ⬜ Untested |
| | | ATP-NF-002-B | Results independent of AI model version | SCN-NF-002-B1 | ⬜ Untested |
| **REQ-NF-003** | When `[SUSPECT]` tags exist in downstream artifacts, the traceability matrix SHALL flag non-compliant status rather than silently accepting the artifacts. | ATP-NF-003-A | Matrix flags non-compliant status for SUSPECT items | SCN-NF-003-A1 | ⬜ Untested |
| **REQ-NF-004** | An engineer SHALL be able to produce a complete Requirements Specification from a feature description in a single command invocation. | ATP-NF-004-A | Complete specification in one command | SCN-NF-004-A1 | ⬜ Untested |

### Matrix A Coverage

| Metric | Value |
|--------|-------|
| **Total Requirements** | 35 |
| **Total Test Cases (ATP)** | 59 |
| **Total Scenarios (SCN)** | 63 |
| **REQ → ATP Coverage** | 35/35 (100%) |
| **ATP → SCN Coverage** | 59/59 (100%) |

## Matrix B — Verification (Architectural View)

| Requirement ID | System Component (SYS) | Component Name | Test Case ID (STP) | Technique | Scenario ID (STS) | Status |
|----------------|------------------------|----------------|--------------------|-----------|--------------------|--------|
| **REQ-001** | SYS-001 | Requirements Generation Engine | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-B | Boundary Value Analysis | STS-001-B3 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| **REQ-002** | SYS-001 | Requirements Generation Engine | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-B | Boundary Value Analysis | STS-001-B3 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| **REQ-003** | SYS-001 | Requirements Generation Engine | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-B | Boundary Value Analysis | STS-001-B3 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| **REQ-004** | SYS-001 | Requirements Generation Engine | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-B | Boundary Value Analysis | STS-001-B3 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| **REQ-005** | SYS-001 | Requirements Generation Engine | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-B | Boundary Value Analysis | STS-001-B3 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| **REQ-006** | SYS-002 | Acceptance Test Plan Generator | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Acceptance Test Plan Generator | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Acceptance Test Plan Generator | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Acceptance Test Plan Generator | STP-002-B | Boundary Value Analysis | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Acceptance Test Plan Generator | STP-002-B | Boundary Value Analysis | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Acceptance Test Plan Generator | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Acceptance Test Plan Generator | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| **REQ-007** | SYS-002 | Acceptance Test Plan Generator | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Acceptance Test Plan Generator | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Acceptance Test Plan Generator | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Acceptance Test Plan Generator | STP-002-B | Boundary Value Analysis | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Acceptance Test Plan Generator | STP-002-B | Boundary Value Analysis | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Acceptance Test Plan Generator | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Acceptance Test Plan Generator | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| **REQ-008** | SYS-002 | Acceptance Test Plan Generator | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Acceptance Test Plan Generator | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Acceptance Test Plan Generator | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Acceptance Test Plan Generator | STP-002-B | Boundary Value Analysis | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Acceptance Test Plan Generator | STP-002-B | Boundary Value Analysis | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Acceptance Test Plan Generator | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Acceptance Test Plan Generator | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-B | Equivalence Partitioning | STS-004-B1 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-B | Equivalence Partitioning | STS-004-B2 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-B | Equivalence Partitioning | STS-004-B3 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-C | Boundary Value Analysis | STS-004-C1 | ⬜ Untested |
| **REQ-009** | SYS-003 | Traceability Matrix Builder | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Traceability Matrix Builder | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Traceability Matrix Builder | STP-003-B | Boundary Value Analysis | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Traceability Matrix Builder | STP-003-B | Boundary Value Analysis | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Traceability Matrix Builder | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Traceability Matrix Builder | STP-003-C | Fault Injection | STS-003-C2 | ⬜ Untested |
| **REQ-010** | SYS-003 | Traceability Matrix Builder | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Traceability Matrix Builder | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Traceability Matrix Builder | STP-003-B | Boundary Value Analysis | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Traceability Matrix Builder | STP-003-B | Boundary Value Analysis | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Traceability Matrix Builder | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Traceability Matrix Builder | STP-003-C | Fault Injection | STS-003-C2 | ⬜ Untested |
| **REQ-011** | SYS-003 | Traceability Matrix Builder | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Traceability Matrix Builder | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Traceability Matrix Builder | STP-003-B | Boundary Value Analysis | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Traceability Matrix Builder | STP-003-B | Boundary Value Analysis | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Traceability Matrix Builder | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Traceability Matrix Builder | STP-003-C | Fault Injection | STS-003-C2 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-B | Equivalence Partitioning | STS-004-B1 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-B | Equivalence Partitioning | STS-004-B2 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-B | Equivalence Partitioning | STS-004-B3 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-C | Boundary Value Analysis | STS-004-C1 | ⬜ Untested |
| **REQ-012** | SYS-009 | ID Lifecycle Manager | STP-009-A | Interface Contract Testing | STS-009-A1 | ⬜ Untested |
| | SYS-009 | ID Lifecycle Manager | STP-009-A | Interface Contract Testing | STS-009-A2 | ⬜ Untested |
| | SYS-009 | ID Lifecycle Manager | STP-009-A | Interface Contract Testing | STS-009-A3 | ⬜ Untested |
| | SYS-009 | ID Lifecycle Manager | STP-009-B | Equivalence Partitioning | STS-009-B1 | ⬜ Untested |
| | SYS-009 | ID Lifecycle Manager | STP-009-B | Equivalence Partitioning | STS-009-B2 | ⬜ Untested |
| **REQ-013** | SYS-009 | ID Lifecycle Manager | STP-009-A | Interface Contract Testing | STS-009-A1 | ⬜ Untested |
| | SYS-009 | ID Lifecycle Manager | STP-009-A | Interface Contract Testing | STS-009-A2 | ⬜ Untested |
| | SYS-009 | ID Lifecycle Manager | STP-009-A | Interface Contract Testing | STS-009-A3 | ⬜ Untested |
| | SYS-009 | ID Lifecycle Manager | STP-009-B | Equivalence Partitioning | STS-009-B1 | ⬜ Untested |
| | SYS-009 | ID Lifecycle Manager | STP-009-B | Equivalence Partitioning | STS-009-B2 | ⬜ Untested |
| **REQ-014** | SYS-009 | ID Lifecycle Manager | STP-009-A | Interface Contract Testing | STS-009-A1 | ⬜ Untested |
| | SYS-009 | ID Lifecycle Manager | STP-009-A | Interface Contract Testing | STS-009-A2 | ⬜ Untested |
| | SYS-009 | ID Lifecycle Manager | STP-009-A | Interface Contract Testing | STS-009-A3 | ⬜ Untested |
| | SYS-009 | ID Lifecycle Manager | STP-009-B | Equivalence Partitioning | STS-009-B1 | ⬜ Untested |
| | SYS-009 | ID Lifecycle Manager | STP-009-B | Equivalence Partitioning | STS-009-B2 | ⬜ Untested |
| **REQ-015** | SYS-005 | Change Detection Module | STP-005-A | Interface Contract Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Change Detection Module | STP-005-A | Interface Contract Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Change Detection Module | STP-005-A | Interface Contract Testing | STS-005-A3 | ⬜ Untested |
| | SYS-005 | Change Detection Module | STP-005-B | Fault Injection | STS-005-B1 | ⬜ Untested |
| **REQ-016** | SYS-008 | Artifact Storage Manager | STP-008-A | Interface Contract Testing | STS-008-A1 | ⬜ Untested |
| | SYS-008 | Artifact Storage Manager | STP-008-A | Interface Contract Testing | STS-008-A2 | ⬜ Untested |
| | SYS-008 | Artifact Storage Manager | STP-008-B | Boundary Value Analysis | STS-008-B1 | ⬜ Untested |
| | SYS-008 | Artifact Storage Manager | STP-008-B | Boundary Value Analysis | STS-008-B2 | ⬜ Untested |
| **REQ-017** | SYS-007 | Domain Overlay Loader | STP-007-A | Interface Contract Testing | STS-007-A1 | ⬜ Untested |
| | SYS-007 | Domain Overlay Loader | STP-007-A | Interface Contract Testing | STS-007-A2 | ⬜ Untested |
| | SYS-007 | Domain Overlay Loader | STP-007-B | Fault Injection | STS-007-B1 | ⬜ Untested |
| | SYS-007 | Domain Overlay Loader | STP-007-B | Fault Injection | STS-007-B2 | ⬜ Untested |
| **REQ-018** | SYS-007 | Domain Overlay Loader | STP-007-A | Interface Contract Testing | STS-007-A1 | ⬜ Untested |
| | SYS-007 | Domain Overlay Loader | STP-007-A | Interface Contract Testing | STS-007-A2 | ⬜ Untested |
| | SYS-007 | Domain Overlay Loader | STP-007-B | Fault Injection | STS-007-B1 | ⬜ Untested |
| | SYS-007 | Domain Overlay Loader | STP-007-B | Fault Injection | STS-007-B2 | ⬜ Untested |
| **REQ-019** | SYS-002 | Acceptance Test Plan Generator | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Acceptance Test Plan Generator | STP-002-A | Interface Contract Testing | STS-002-A2 | ⬜ Untested |
| | SYS-002 | Acceptance Test Plan Generator | STP-002-A | Interface Contract Testing | STS-002-A3 | ⬜ Untested |
| | SYS-002 | Acceptance Test Plan Generator | STP-002-B | Boundary Value Analysis | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Acceptance Test Plan Generator | STP-002-B | Boundary Value Analysis | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Acceptance Test Plan Generator | STP-002-C | Fault Injection | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Acceptance Test Plan Generator | STP-002-C | Fault Injection | STS-002-C2 | ⬜ Untested |
| **REQ-020** | SYS-004 | Coverage Validation Engine | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-B | Equivalence Partitioning | STS-004-B1 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-B | Equivalence Partitioning | STS-004-B2 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-B | Equivalence Partitioning | STS-004-B3 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-C | Boundary Value Analysis | STS-004-C1 | ⬜ Untested |
| **REQ-021** | SYS-004 | Coverage Validation Engine | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-B | Equivalence Partitioning | STS-004-B1 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-B | Equivalence Partitioning | STS-004-B2 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-B | Equivalence Partitioning | STS-004-B3 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-C | Boundary Value Analysis | STS-004-C1 | ⬜ Untested |
| **REQ-022** | SYS-001 | Requirements Generation Engine | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-B | Boundary Value Analysis | STS-001-B3 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |
| | SYS-011 | Error Handling Framework | STP-011-A | Interface Contract Testing | STS-011-A1 | ⬜ Untested |
| | SYS-011 | Error Handling Framework | STP-011-A | Interface Contract Testing | STS-011-A2 | ⬜ Untested |
| | SYS-011 | Error Handling Framework | STP-011-B | Fault Injection | STS-011-B1 | ⬜ Untested |
| | SYS-011 | Error Handling Framework | STP-011-B | Fault Injection | STS-011-B2 | ⬜ Untested |
| **REQ-023** | SYS-009 | ID Lifecycle Manager | STP-009-A | Interface Contract Testing | STS-009-A1 | ⬜ Untested |
| | SYS-009 | ID Lifecycle Manager | STP-009-A | Interface Contract Testing | STS-009-A2 | ⬜ Untested |
| | SYS-009 | ID Lifecycle Manager | STP-009-A | Interface Contract Testing | STS-009-A3 | ⬜ Untested |
| | SYS-009 | ID Lifecycle Manager | STP-009-B | Equivalence Partitioning | STS-009-B1 | ⬜ Untested |
| | SYS-009 | ID Lifecycle Manager | STP-009-B | Equivalence Partitioning | STS-009-B2 | ⬜ Untested |
| **REQ-024** | SYS-011 | Error Handling Framework | STP-011-A | Interface Contract Testing | STS-011-A1 | ⬜ Untested |
| | SYS-011 | Error Handling Framework | STP-011-A | Interface Contract Testing | STS-011-A2 | ⬜ Untested |
| | SYS-011 | Error Handling Framework | STP-011-B | Fault Injection | STS-011-B1 | ⬜ Untested |
| | SYS-011 | Error Handling Framework | STP-011-B | Fault Injection | STS-011-B2 | ⬜ Untested |
| **REQ-025** | SYS-003 | Traceability Matrix Builder | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Traceability Matrix Builder | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Traceability Matrix Builder | STP-003-B | Boundary Value Analysis | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Traceability Matrix Builder | STP-003-B | Boundary Value Analysis | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Traceability Matrix Builder | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Traceability Matrix Builder | STP-003-C | Fault Injection | STS-003-C2 | ⬜ Untested |
| **REQ-CN-001** | SYS-006 | V-Model Setup Service | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | V-Model Setup Service | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| | SYS-006 | V-Model Setup Service | STP-006-B | Boundary Value Analysis | STS-006-B1 | ⬜ Untested |
| | SYS-006 | V-Model Setup Service | STP-006-B | Boundary Value Analysis | STS-006-B2 | ⬜ Untested |
| | SYS-006 | V-Model Setup Service | STP-006-B | Boundary Value Analysis | STS-006-B3 | ⬜ Untested |
| | SYS-006 | V-Model Setup Service | STP-006-C | Fault Injection | STS-006-C1 | ⬜ Untested |
| **REQ-CN-002** | SYS-008 | Artifact Storage Manager | STP-008-A | Interface Contract Testing | STS-008-A1 | ⬜ Untested |
| | SYS-008 | Artifact Storage Manager | STP-008-A | Interface Contract Testing | STS-008-A2 | ⬜ Untested |
| | SYS-008 | Artifact Storage Manager | STP-008-B | Boundary Value Analysis | STS-008-B1 | ⬜ Untested |
| | SYS-008 | Artifact Storage Manager | STP-008-B | Boundary Value Analysis | STS-008-B2 | ⬜ Untested |
| **REQ-CN-003** | SYS-012 | AI Runtime Interface | STP-012-A | Interface Contract Testing | STS-012-A1 | ⬜ Untested |
| | SYS-012 | AI Runtime Interface | STP-012-A | Interface Contract Testing | STS-012-A2 | ⬜ Untested |
| | SYS-012 | AI Runtime Interface | STP-012-B | Fault Injection | STS-012-B1 | ⬜ Untested |
| | SYS-012 | AI Runtime Interface | STP-012-B | Fault Injection | STS-012-B2 | ⬜ Untested |
| **REQ-IF-001** | SYS-010 | Command Input Processor | STP-010-A | Interface Contract Testing | STS-010-A1 | ⬜ Untested |
| | SYS-010 | Command Input Processor | STP-010-A | Interface Contract Testing | STS-010-A2 | ⬜ Untested |
| | SYS-010 | Command Input Processor | STP-010-A | Interface Contract Testing | STS-010-A3 | ⬜ Untested |
| | SYS-010 | Command Input Processor | STP-010-B | Boundary Value Analysis | STS-010-B1 | ⬜ Untested |
| | SYS-010 | Command Input Processor | STP-010-B | Boundary Value Analysis | STS-010-B2 | ⬜ Untested |
| **REQ-IF-002** | SYS-010 | Command Input Processor | STP-010-A | Interface Contract Testing | STS-010-A1 | ⬜ Untested |
| | SYS-010 | Command Input Processor | STP-010-A | Interface Contract Testing | STS-010-A2 | ⬜ Untested |
| | SYS-010 | Command Input Processor | STP-010-A | Interface Contract Testing | STS-010-A3 | ⬜ Untested |
| | SYS-010 | Command Input Processor | STP-010-B | Boundary Value Analysis | STS-010-B1 | ⬜ Untested |
| | SYS-010 | Command Input Processor | STP-010-B | Boundary Value Analysis | STS-010-B2 | ⬜ Untested |
| **REQ-IF-003** | SYS-006 | V-Model Setup Service | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | V-Model Setup Service | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| | SYS-006 | V-Model Setup Service | STP-006-B | Boundary Value Analysis | STS-006-B1 | ⬜ Untested |
| | SYS-006 | V-Model Setup Service | STP-006-B | Boundary Value Analysis | STS-006-B2 | ⬜ Untested |
| | SYS-006 | V-Model Setup Service | STP-006-B | Boundary Value Analysis | STS-006-B3 | ⬜ Untested |
| | SYS-006 | V-Model Setup Service | STP-006-C | Fault Injection | STS-006-C1 | ⬜ Untested |
| **REQ-NF-001** | SYS-007 | Domain Overlay Loader | STP-007-A | Interface Contract Testing | STS-007-A1 | ⬜ Untested |
| | SYS-007 | Domain Overlay Loader | STP-007-A | Interface Contract Testing | STS-007-A2 | ⬜ Untested |
| | SYS-007 | Domain Overlay Loader | STP-007-B | Fault Injection | STS-007-B1 | ⬜ Untested |
| | SYS-007 | Domain Overlay Loader | STP-007-B | Fault Injection | STS-007-B2 | ⬜ Untested |
| **REQ-NF-002** | SYS-004 | Coverage Validation Engine | STP-004-A | Interface Contract Testing | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-A | Interface Contract Testing | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-B | Equivalence Partitioning | STS-004-B1 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-B | Equivalence Partitioning | STS-004-B2 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-B | Equivalence Partitioning | STS-004-B3 | ⬜ Untested |
| | SYS-004 | Coverage Validation Engine | STP-004-C | Boundary Value Analysis | STS-004-C1 | ⬜ Untested |
| **REQ-NF-003** | SYS-003 | Traceability Matrix Builder | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Traceability Matrix Builder | STP-003-A | Interface Contract Testing | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Traceability Matrix Builder | STP-003-B | Boundary Value Analysis | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Traceability Matrix Builder | STP-003-B | Boundary Value Analysis | STS-003-B2 | ⬜ Untested |
| | SYS-003 | Traceability Matrix Builder | STP-003-C | Fault Injection | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Traceability Matrix Builder | STP-003-C | Fault Injection | STS-003-C2 | ⬜ Untested |
| **REQ-NF-004** | SYS-001 | Requirements Generation Engine | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-B | Boundary Value Analysis | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-B | Boundary Value Analysis | STS-001-B2 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-B | Boundary Value Analysis | STS-001-B3 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | Requirements Generation Engine | STP-001-C | Fault Injection | STS-001-C2 | ⬜ Untested |

### Matrix B Coverage

| Metric | Value |
|--------|-------|
| **Total System Components (SYS)** | 12 |
| **Total System Test Cases (STP)** | 29 |
| **Total System Scenarios (STS)** | 63 |
| **REQ → SYS Coverage** | 35/35 (100%) |
| **SYS → STP Coverage** | 12/12 (100%) |

## Matrix C — Integration Verification (Module Boundary View)

| System Component (SYS) | Parent REQs | Architecture Module (ARCH) | Module Name | Test Case ID (ITP) | Technique | Scenario ID (ITS) | Status |
|------------------------|-------------|---------------------------|-------------|--------------------|-----------|--------------------|--------|
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-022, REQ-NF-004) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-022, REQ-NF-004 | ARCH-001 | Spec Parser | ITP-001-A | Interface Contract Testing | ITS-001-A1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-022, REQ-NF-004) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-022, REQ-NF-004 | ARCH-001 | Spec Parser | ITP-001-A | Interface Contract Testing | ITS-001-A2 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-022, REQ-NF-004) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-022, REQ-NF-004 | ARCH-001 | Spec Parser | ITP-001-B | Interface Fault Injection | ITS-001-B1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-022, REQ-NF-004) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-022, REQ-NF-004 | ARCH-002 | Requirement Synthesizer | ITP-002-A | Interface Contract Testing | ITS-002-A1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-022, REQ-NF-004) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-022, REQ-NF-004 | ARCH-002 | Requirement Synthesizer | ITP-002-A | Interface Contract Testing | ITS-002-A2 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-022, REQ-NF-004) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-022, REQ-NF-004 | ARCH-002 | Requirement Synthesizer | ITP-002-B | Data Flow Testing | ITS-002-B1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-022, REQ-NF-004) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-022, REQ-NF-004 | ARCH-003 | Quality Validator | ITP-003-A | Interface Contract Testing | ITS-003-A1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-022, REQ-NF-004) | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-022, REQ-NF-004 | ARCH-003 | Quality Validator | ITP-003-B | Interface Fault Injection | ITS-003-B1 | ⬜ Untested |
| SYS-002 (REQ-006, REQ-007, REQ-008, REQ-019) | REQ-006, REQ-007, REQ-008, REQ-019 | ARCH-004 | Requirement Batch Processor | ITP-004-A | Interface Contract Testing | ITS-004-A1 | ⬜ Untested |
| SYS-002 (REQ-006, REQ-007, REQ-008, REQ-019) | REQ-006, REQ-007, REQ-008, REQ-019 | ARCH-004 | Requirement Batch Processor | ITP-004-A | Interface Contract Testing | ITS-004-A2 | ⬜ Untested |
| SYS-002 (REQ-006, REQ-007, REQ-008, REQ-019) | REQ-006, REQ-007, REQ-008, REQ-019 | ARCH-004 | Requirement Batch Processor | ITP-004-B | Interface Fault Injection | ITS-004-B1 | ⬜ Untested |
| SYS-002 (REQ-006, REQ-007, REQ-008, REQ-019) | REQ-006, REQ-007, REQ-008, REQ-019 | ARCH-005 | ATP/SCN Generator | ITP-005-A | Interface Contract Testing | ITS-005-A1 | ⬜ Untested |
| SYS-002 (REQ-006, REQ-007, REQ-008, REQ-019) | REQ-006, REQ-007, REQ-008, REQ-019 | ARCH-005 | ATP/SCN Generator | ITP-005-A | Interface Contract Testing | ITS-005-A2 | ⬜ Untested |
| SYS-002 (REQ-006, REQ-007, REQ-008, REQ-019) | REQ-006, REQ-007, REQ-008, REQ-019 | ARCH-005 | ATP/SCN Generator | ITP-005-B | Interface Fault Injection | ITS-005-B1 | ⬜ Untested |
| SYS-002 (REQ-006, REQ-007, REQ-008, REQ-019) | REQ-006, REQ-007, REQ-008, REQ-019 | ARCH-006 | Coverage Assembler | ITP-006-A | Interface Contract Testing | ITS-006-A1 | ⬜ Untested |
| SYS-002 (REQ-006, REQ-007, REQ-008, REQ-019) | REQ-006, REQ-007, REQ-008, REQ-019 | ARCH-006 | Coverage Assembler | ITP-006-B | Interface Fault Injection | ITS-006-B1 | ⬜ Untested |
| SYS-002 (REQ-006, REQ-007, REQ-008, REQ-019) | REQ-006, REQ-007, REQ-008, REQ-019 | ARCH-006 | Coverage Assembler | ITP-006-B | Interface Fault Injection | ITS-006-B2 | ⬜ Untested |
| SYS-003 (REQ-009, REQ-010, REQ-011, REQ-025, REQ-NF-003) | REQ-009, REQ-010, REQ-011, REQ-025, REQ-NF-003 | ARCH-008 | Matrix Compositor | ITP-008-A | Interface Contract Testing | ITS-008-A1 | ⬜ Untested |
| SYS-003 (REQ-009, REQ-010, REQ-011, REQ-025, REQ-NF-003) | REQ-009, REQ-010, REQ-011, REQ-025, REQ-NF-003 | ARCH-008 | Matrix Compositor | ITP-008-B | Interface Fault Injection | ITS-008-B1 | ⬜ Untested |
| SYS-003 (REQ-009, REQ-010, REQ-011, REQ-025, REQ-NF-003) | REQ-009, REQ-010, REQ-011, REQ-025, REQ-NF-003 | ARCH-009 | Gap Analyzer | ITP-009-A | Interface Contract Testing | ITS-009-A1 | ⬜ Untested |
| SYS-003 (REQ-009, REQ-010, REQ-011, REQ-025, REQ-NF-003) | REQ-009, REQ-010, REQ-011, REQ-025, REQ-NF-003 | ARCH-009 | Gap Analyzer | ITP-009-A | Interface Contract Testing | ITS-009-A2 | ⬜ Untested |
| SYS-003 (REQ-009, REQ-010, REQ-011, REQ-025, REQ-NF-003) | REQ-009, REQ-010, REQ-011, REQ-025, REQ-NF-003 | ARCH-009 | Gap Analyzer | ITP-009-B | Data Flow Testing | ITS-009-B1 | ⬜ Untested |
| SYS-004 (REQ-008, REQ-011, REQ-020, REQ-021, REQ-NF-002) | REQ-008, REQ-011, REQ-020, REQ-021, REQ-NF-002 | ARCH-010 | Coverage Calculator | ITP-010-A | Interface Contract Testing | ITS-010-A1 | ⬜ Untested |
| SYS-004 (REQ-008, REQ-011, REQ-020, REQ-021, REQ-NF-002) | REQ-008, REQ-011, REQ-020, REQ-021, REQ-NF-002 | ARCH-010 | Coverage Calculator | ITP-010-A | Interface Contract Testing | ITS-010-A2 | ⬜ Untested |
| SYS-004 (REQ-008, REQ-011, REQ-020, REQ-021, REQ-NF-002) | REQ-008, REQ-011, REQ-020, REQ-021, REQ-NF-002 | ARCH-010 | Coverage Calculator | ITP-010-B | Data Flow Testing | ITS-010-B1 | ⬜ Untested |
| SYS-005 (REQ-015) | REQ-015 | ARCH-011 | Git Diff Analyzer | ITP-011-A | Interface Contract Testing | ITS-011-A1 | ⬜ Untested |
| SYS-005 (REQ-015) | REQ-015 | ARCH-011 | Git Diff Analyzer | ITP-011-B | Interface Fault Injection | ITS-011-B1 | ⬜ Untested |
| SYS-006 (REQ-IF-003, REQ-CN-001) | REQ-IF-003, REQ-CN-001 | ARCH-012 | Branch-Feature Resolver | ITP-012-A | Interface Contract Testing | ITS-012-A1 | ⬜ Untested |
| SYS-006 (REQ-IF-003, REQ-CN-001) | REQ-IF-003, REQ-CN-001 | ARCH-012 | Branch-Feature Resolver | ITP-012-A | Interface Contract Testing | ITS-012-A2 | ⬜ Untested |
| SYS-006 (REQ-IF-003, REQ-CN-001) | REQ-IF-003, REQ-CN-001 | ARCH-012 | Branch-Feature Resolver | ITP-012-B | Interface Fault Injection | ITS-012-B1 | ⬜ Untested |
| SYS-006 (REQ-IF-003, REQ-CN-001) | REQ-IF-003, REQ-CN-001 | ARCH-013 | Prerequisite Validator | ITP-013-A | Interface Contract Testing | ITS-013-A1 | ⬜ Untested |
| SYS-006 (REQ-IF-003, REQ-CN-001) | REQ-IF-003, REQ-CN-001 | ARCH-013 | Prerequisite Validator | ITP-013-B | Interface Fault Injection | ITS-013-B1 | ⬜ Untested |
| SYS-006 (REQ-IF-003, REQ-CN-001) | REQ-IF-003, REQ-CN-001 | ARCH-014 | Document Discovery | ITP-014-A | Interface Contract Testing | ITS-014-A1 | ⬜ Untested |
| SYS-006 (REQ-IF-003, REQ-CN-001) | REQ-IF-003, REQ-CN-001 | ARCH-014 | Document Discovery | ITP-014-A | Interface Contract Testing | ITS-014-A2 | ⬜ Untested |
| SYS-007 (REQ-017, REQ-018, REQ-NF-001) | REQ-017, REQ-018, REQ-NF-001 | ARCH-015 | Config Reader | ITP-015-A | Interface Contract Testing | ITS-015-A1 | ⬜ Untested |
| SYS-007 (REQ-017, REQ-018, REQ-NF-001) | REQ-017, REQ-018, REQ-NF-001 | ARCH-015 | Config Reader | ITP-015-A | Interface Contract Testing | ITS-015-A2 | ⬜ Untested |
| SYS-007 (REQ-017, REQ-018, REQ-NF-001) | REQ-017, REQ-018, REQ-NF-001 | ARCH-015 | Config Reader | ITP-015-B | Interface Fault Injection | ITS-015-B1 | ⬜ Untested |
| SYS-007 (REQ-017, REQ-018, REQ-NF-001) | REQ-017, REQ-018, REQ-NF-001 | ARCH-016 | Overlay File Resolver | ITP-016-A | Interface Contract Testing | ITS-016-A1 | ⬜ Untested |
| SYS-007 (REQ-017, REQ-018, REQ-NF-001) | REQ-017, REQ-018, REQ-NF-001 | ARCH-016 | Overlay File Resolver | ITP-016-B | Interface Fault Injection | ITS-016-B1 | ⬜ Untested |
| SYS-008 (REQ-016, REQ-CN-002) | REQ-016, REQ-CN-002 | ARCH-017 | Markdown File Writer | ITP-017-A | Interface Contract Testing | ITS-017-A1 | ⬜ Untested |
| SYS-008 (REQ-016, REQ-CN-002) | REQ-016, REQ-CN-002 | ARCH-017 | Markdown File Writer | ITP-017-A | Interface Contract Testing | ITS-017-A2 | ⬜ Untested |
| SYS-008 (REQ-016, REQ-CN-002) | REQ-016, REQ-CN-002 | ARCH-017 | Markdown File Writer | ITP-017-B | Interface Fault Injection | ITS-017-B1 | ⬜ Untested |
| SYS-009 (REQ-012, REQ-013, REQ-014, REQ-023) | REQ-012, REQ-013, REQ-014, REQ-023 | ARCH-018 | Lifecycle Tag Parser | ITP-018-A | Interface Contract Testing | ITS-018-A1 | ⬜ Untested |
| SYS-009 (REQ-012, REQ-013, REQ-014, REQ-023) | REQ-012, REQ-013, REQ-014, REQ-023 | ARCH-018 | Lifecycle Tag Parser | ITP-018-A | Interface Contract Testing | ITS-018-A2 | ⬜ Untested |
| SYS-009 (REQ-012, REQ-013, REQ-014, REQ-023) | REQ-012, REQ-013, REQ-014, REQ-023 | ARCH-019 | Lifecycle State Machine | ITP-019-A | Interface Contract Testing | ITS-019-A1 | ⬜ Untested |
| SYS-009 (REQ-012, REQ-013, REQ-014, REQ-023) | REQ-012, REQ-013, REQ-014, REQ-023 | ARCH-019 | Lifecycle State Machine | ITP-019-B | Interface Fault Injection | ITS-019-B1 | ⬜ Untested |
| SYS-010 (REQ-IF-001, REQ-IF-002) | REQ-IF-001, REQ-IF-002 | ARCH-020 | Input Mode Resolver | ITP-020-A | Interface Contract Testing | ITS-020-A1 | ⬜ Untested |
| SYS-010 (REQ-IF-001, REQ-IF-002) | REQ-IF-001, REQ-IF-002 | ARCH-020 | Input Mode Resolver | ITP-020-A | Interface Contract Testing | ITS-020-A2 | ⬜ Untested |
| SYS-010 (REQ-IF-001, REQ-IF-002) | REQ-IF-001, REQ-IF-002 | ARCH-020 | Input Mode Resolver | ITP-020-B | Interface Fault Injection | ITS-020-B1 | ⬜ Untested |
| SYS-011 (REQ-022, REQ-024) | REQ-022, REQ-024 | ARCH-021 | Error Formatter | ITP-021-A | Interface Contract Testing | ITS-021-A1 | ⬜ Untested |
| SYS-011 (REQ-022, REQ-024) | REQ-022, REQ-024 | ARCH-021 | Error Formatter | ITP-021-A | Interface Contract Testing | ITS-021-A2 | ⬜ Untested |
| SYS-012 (REQ-CN-003) | REQ-CN-003 | ARCH-022 | Runtime Adapter | ITP-022-A | Interface Contract Testing | ITS-022-A1 | ⬜ Untested |
| SYS-012 (REQ-CN-003) | REQ-CN-003 | ARCH-022 | Runtime Adapter | ITP-022-A | Interface Contract Testing | ITS-022-A2 | ⬜ Untested |
| SYS-012 (REQ-CN-003) | REQ-CN-003 | ARCH-022 | Runtime Adapter | ITP-022-B | Interface Fault Injection | ITS-022-B1 | ⬜ Untested |

### Matrix C Coverage

| Metric | Value |
|--------|-------|
| **Total Architecture Modules (ARCH)** | 22 |
| **Total Cross-Cutting Modules** | 0 |
| **Total Integration Test Cases (ITP)** | 42 |
| **Total Integration Scenarios (ITS)** | 58 |
| **SYS → ARCH Coverage** | 12/12 (100%) |
| **ARCH → ITP Coverage** | 22/22 (100%) |

### Uncovered Requirements (REQ without ATP)

None — full coverage.

### Orphaned Test Cases (ATP without valid REQ)

None — all tests trace to requirements.

### Uncovered Requirements — System Level (REQ without SYS)

None — full coverage.

### Orphaned System Test Cases (STP without valid SYS)

None — all system tests trace to components.

### Uncovered System Components — Architecture Level (SYS without ARCH)

None — full coverage.

### Orphaned Integration Test Cases (ITP without valid ARCH)

None — all integration tests trace to modules.

## Matrix D — Implementation Verification (Module View)

| Architecture Module (ARCH) | Parent System | Module Design (MOD) | Module Name | Test Case ID (UTP) | Technique | Scenario ID (UTS) | Status |
|---------------------------|---------------|---------------------|-------------|--------------------|-----------|--------------------|--------|
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | parse_spec_content | UTP-001-A | Statement & Branch Coverage | UTS-001-A1 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | parse_spec_content | UTP-001-A | Statement & Branch Coverage | UTS-001-A2 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | parse_spec_content | UTP-001-A | Statement & Branch Coverage | UTS-001-A3 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | parse_spec_content | UTP-001-A | Statement & Branch Coverage | UTS-001-A4 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | parse_spec_content | UTP-001-B | Equivalence Partitioning | UTS-001-B1 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | parse_spec_content | UTP-001-B | Equivalence Partitioning | UTS-001-B2 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | parse_spec_content | UTP-001-B | Equivalence Partitioning | UTS-001-B3 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | parse_spec_content | UTP-001-B | Equivalence Partitioning | UTS-001-B4 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | synthesize_requirements | UTP-002-A | Statement & Branch Coverage | UTS-002-A1 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | synthesize_requirements | UTP-002-A | Statement & Branch Coverage | UTS-002-A2 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | synthesize_requirements | UTP-002-A | Statement & Branch Coverage | UTS-002-A3 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | synthesize_requirements | UTP-002-A | Statement & Branch Coverage | UTS-002-A4 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | synthesize_requirements | UTP-002-B | Equivalence Partitioning | UTS-002-B1 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | synthesize_requirements | UTP-002-B | Equivalence Partitioning | UTS-002-B2 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | synthesize_requirements | UTP-002-B | Equivalence Partitioning | UTS-002-B3 | ⬜ Untested |
| ARCH-003 (SYS-001) | SYS-001 | MOD-003 | validate_requirement_quality | UTP-003-A | Statement & Branch Coverage | UTS-003-A1 | ⬜ Untested |
| ARCH-003 (SYS-001) | SYS-001 | MOD-003 | validate_requirement_quality | UTP-003-A | Statement & Branch Coverage | UTS-003-A2 | ⬜ Untested |
| ARCH-003 (SYS-001) | SYS-001 | MOD-003 | validate_requirement_quality | UTP-003-A | Statement & Branch Coverage | UTS-003-A3 | ⬜ Untested |
| ARCH-003 (SYS-001) | SYS-001 | MOD-003 | validate_requirement_quality | UTP-003-A | Statement & Branch Coverage | UTS-003-A4 | ⬜ Untested |
| ARCH-003 (SYS-001) | SYS-001 | MOD-003 | validate_requirement_quality | UTP-003-B | Boundary Value Analysis | UTS-003-B1 | ⬜ Untested |
| ARCH-003 (SYS-001) | SYS-001 | MOD-003 | validate_requirement_quality | UTP-003-B | Boundary Value Analysis | UTS-003-B2 | ⬜ Untested |
| ARCH-003 (SYS-001) | SYS-001 | MOD-003 | validate_requirement_quality | UTP-003-B | Boundary Value Analysis | UTS-003-B3 | ⬜ Untested |
| ARCH-003 (SYS-001) | SYS-001 | MOD-003 | validate_requirement_quality | UTP-003-B | Boundary Value Analysis | UTS-003-B4 | ⬜ Untested |
| ARCH-003 (SYS-001) | SYS-001 | MOD-003 | validate_requirement_quality | UTP-003-B | Boundary Value Analysis | UTS-003-B5 | ⬜ Untested |
| ARCH-003 (SYS-001) | SYS-001 | MOD-003 | validate_requirement_quality | UTP-003-C | Strict Isolation | UTS-003-C1 | ⬜ Untested |
| ARCH-003 (SYS-001) | SYS-001 | MOD-003 | validate_requirement_quality | UTP-003-C | Strict Isolation | UTS-003-C2 | ⬜ Untested |
| ARCH-003 (SYS-001) | SYS-001 | MOD-004 | check_banned_terms | UTP-004-A | Statement & Branch Coverage | UTS-004-A1 | ⬜ Untested |
| ARCH-003 (SYS-001) | SYS-001 | MOD-004 | check_banned_terms | UTP-004-A | Statement & Branch Coverage | UTS-004-A2 | ⬜ Untested |
| ARCH-003 (SYS-001) | SYS-001 | MOD-004 | check_banned_terms | UTP-004-A | Statement & Branch Coverage | UTS-004-A3 | ⬜ Untested |
| ARCH-003 (SYS-001) | SYS-001 | MOD-004 | check_banned_terms | UTP-004-A | Statement & Branch Coverage | UTS-004-A4 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-005 | create_requirement_batches | UTP-005-A | Statement & Branch Coverage | UTS-005-A1 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-005 | create_requirement_batches | UTP-005-A | Statement & Branch Coverage | UTS-005-A2 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-005 | create_requirement_batches | UTP-005-A | Statement & Branch Coverage | UTS-005-A3 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-005 | create_requirement_batches | UTP-005-A | Statement & Branch Coverage | UTS-005-A4 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-005 | create_requirement_batches | UTP-005-B | Boundary Value Analysis | UTS-005-B1 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-005 | create_requirement_batches | UTP-005-B | Boundary Value Analysis | UTS-005-B2 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-005 | create_requirement_batches | UTP-005-B | Boundary Value Analysis | UTS-005-B3 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-005 | create_requirement_batches | UTP-005-B | Boundary Value Analysis | UTS-005-B4 | ⬜ Untested |
| ARCH-005 (SYS-002) | SYS-002 | MOD-006 | generate_atp_scn | UTP-006-A | Statement & Branch Coverage | UTS-006-A1 | ⬜ Untested |
| ARCH-005 (SYS-002) | SYS-002 | MOD-006 | generate_atp_scn | UTP-006-A | Statement & Branch Coverage | UTS-006-A2 | ⬜ Untested |
| ARCH-005 (SYS-002) | SYS-002 | MOD-006 | generate_atp_scn | UTP-006-A | Statement & Branch Coverage | UTS-006-A3 | ⬜ Untested |
| ARCH-005 (SYS-002) | SYS-002 | MOD-006 | generate_atp_scn | UTP-006-B | Strict Isolation | UTS-006-B1 | ⬜ Untested |
| ARCH-005 (SYS-002) | SYS-002 | MOD-006 | generate_atp_scn | UTP-006-B | Strict Isolation | UTS-006-B2 | ⬜ Untested |
| ARCH-006 (SYS-002) | SYS-002 | MOD-007 | assemble_acceptance_plan | UTP-007-A | Statement & Branch Coverage | UTS-007-A1 | ⬜ Untested |
| ARCH-006 (SYS-002) | SYS-002 | MOD-007 | assemble_acceptance_plan | UTP-007-A | Statement & Branch Coverage | UTS-007-A2 | ⬜ Untested |
| ARCH-006 (SYS-002) | SYS-002 | MOD-007 | assemble_acceptance_plan | UTP-007-A | Statement & Branch Coverage | UTS-007-A3 | ⬜ Untested |
| ARCH-006 (SYS-002) | SYS-002 | MOD-007 | assemble_acceptance_plan | UTP-007-A | Statement & Branch Coverage | UTS-007-A4 | ⬜ Untested |
| ARCH-007 (IF-\) | IF-\ | MOD-008 | extract_ids | UTP-008-A | Statement & Branch Coverage | UTS-008-A1 | ⬜ Untested |
| ARCH-007 (IF-\) | IF-\ | MOD-008 | extract_ids | UTP-008-A | Statement & Branch Coverage | UTS-008-A2 | ⬜ Untested |
| ARCH-007 (IF-\) | IF-\ | MOD-008 | extract_ids | UTP-008-A | Statement & Branch Coverage | UTS-008-A3 | ⬜ Untested |
| ARCH-007 (IF-\) | IF-\ | MOD-008 | extract_ids | UTP-008-A | Statement & Branch Coverage | UTS-008-A4 | ⬜ Untested |
| ARCH-007 (IF-\) | IF-\ | MOD-008 | extract_ids | UTP-008-B | Equivalence Partitioning | UTS-008-B1 | ⬜ Untested |
| ARCH-007 (IF-\) | IF-\ | MOD-008 | extract_ids | UTP-008-B | Equivalence Partitioning | UTS-008-B2 | ⬜ Untested |
| ARCH-007 (IF-\) | IF-\ | MOD-008 | extract_ids | UTP-008-B | Equivalence Partitioning | UTS-008-B3 | ⬜ Untested |
| ARCH-008 (SYS-003) | SYS-003 | MOD-009 | build_matrix_tables | UTP-009-A | Statement & Branch Coverage | UTS-009-A1 | ⬜ Untested |
| ARCH-008 (SYS-003) | SYS-003 | MOD-009 | build_matrix_tables | UTP-009-A | Statement & Branch Coverage | UTS-009-A2 | ⬜ Untested |
| ARCH-008 (SYS-003) | SYS-003 | MOD-009 | build_matrix_tables | UTP-009-A | Statement & Branch Coverage | UTS-009-A3 | ⬜ Untested |
| ARCH-008 (SYS-003) | SYS-003 | MOD-009 | build_matrix_tables | UTP-009-B | Strict Isolation | UTS-009-B1 | ⬜ Untested |
| ARCH-008 (SYS-003) | SYS-003 | MOD-009 | build_matrix_tables | UTP-009-B | Strict Isolation | UTS-009-B2 | ⬜ Untested |
| ARCH-008 (SYS-003) | SYS-003 | MOD-010 | compute_coverage_stats | UTP-010-A | Statement & Branch Coverage | UTS-010-A1 | ⬜ Untested |
| ARCH-008 (SYS-003) | SYS-003 | MOD-010 | compute_coverage_stats | UTP-010-A | Statement & Branch Coverage | UTS-010-A2 | ⬜ Untested |
| ARCH-008 (SYS-003) | SYS-003 | MOD-010 | compute_coverage_stats | UTP-010-A | Statement & Branch Coverage | UTS-010-A3 | ⬜ Untested |
| ARCH-008 (SYS-003) | SYS-003 | MOD-010 | compute_coverage_stats | UTP-010-B | Boundary Value Analysis | UTS-010-B1 | ⬜ Untested |
| ARCH-008 (SYS-003) | SYS-003 | MOD-010 | compute_coverage_stats | UTP-010-B | Boundary Value Analysis | UTS-010-B2 | ⬜ Untested |
| ARCH-008 (SYS-003) | SYS-003 | MOD-010 | compute_coverage_stats | UTP-010-B | Boundary Value Analysis | UTS-010-B3 | ⬜ Untested |
| ARCH-009 (SYS-003) | SYS-003 | MOD-011 | find_gaps | UTP-011-A | Statement & Branch Coverage | UTS-011-A1 | ⬜ Untested |
| ARCH-009 (SYS-003) | SYS-003 | MOD-011 | find_gaps | UTP-011-A | Statement & Branch Coverage | UTS-011-A2 | ⬜ Untested |
| ARCH-009 (SYS-003) | SYS-003 | MOD-011 | find_gaps | UTP-011-A | Statement & Branch Coverage | UTS-011-A3 | ⬜ Untested |
| ARCH-009 (SYS-003) | SYS-003 | MOD-011 | find_gaps | UTP-011-A | Statement & Branch Coverage | UTS-011-A4 | ⬜ Untested |
| ARCH-009 (SYS-003) | SYS-003 | MOD-012 | format_exception_report | UTP-012-A | Statement & Branch Coverage | UTS-012-A1 | ⬜ Untested |
| ARCH-009 (SYS-003) | SYS-003 | MOD-012 | format_exception_report | UTP-012-A | Statement & Branch Coverage | UTS-012-A2 | ⬜ Untested |
| ARCH-009 (SYS-003) | SYS-003 | MOD-012 | format_exception_report | UTP-012-A | Statement & Branch Coverage | UTS-012-A3 | ⬜ Untested |
| ARCH-010 (SYS-004) | SYS-004 | MOD-013 | compute_bidirectional_coverage | UTP-013-A | Statement & Branch Coverage | UTS-013-A1 | ⬜ Untested |
| ARCH-010 (SYS-004) | SYS-004 | MOD-013 | compute_bidirectional_coverage | UTP-013-A | Statement & Branch Coverage | UTS-013-A2 | ⬜ Untested |
| ARCH-010 (SYS-004) | SYS-004 | MOD-013 | compute_bidirectional_coverage | UTP-013-A | Statement & Branch Coverage | UTS-013-A3 | ⬜ Untested |
| ARCH-010 (SYS-004) | SYS-004 | MOD-013 | compute_bidirectional_coverage | UTP-013-B | Strict Isolation | UTS-013-B1 | ⬜ Untested |
| ARCH-010 (SYS-004) | SYS-004 | MOD-013 | compute_bidirectional_coverage | UTP-013-B | Strict Isolation | UTS-013-B2 | ⬜ Untested |
| ARCH-010 (SYS-004) | SYS-004 | MOD-014 | format_json_report | UTP-014-A | Statement & Branch Coverage | UTS-014-A1 | ⬜ Untested |
| ARCH-010 (SYS-004) | SYS-004 | MOD-014 | format_json_report | UTP-014-A | Statement & Branch Coverage | UTS-014-A2 | ⬜ Untested |
| ARCH-010 (SYS-004) | SYS-004 | MOD-014 | format_json_report | UTP-014-A | Statement & Branch Coverage | UTS-014-A3 | ⬜ Untested |
| ARCH-010 (SYS-004) | SYS-004 | MOD-014 | format_json_report | UTP-014-B | Boundary Value Analysis | UTS-014-B1 | ⬜ Untested |
| ARCH-010 (SYS-004) | SYS-004 | MOD-014 | format_json_report | UTP-014-B | Boundary Value Analysis | UTS-014-B2 | ⬜ Untested |
| ARCH-010 (SYS-004) | SYS-004 | MOD-014 | format_json_report | UTP-014-B | Boundary Value Analysis | UTS-014-B3 | ⬜ Untested |
| ARCH-011 (SYS-005) | SYS-005 | MOD-015 | parse_unified_diff | UTP-015-A | Statement & Branch Coverage | UTS-015-A1 | ⬜ Untested |
| ARCH-011 (SYS-005) | SYS-005 | MOD-015 | parse_unified_diff | UTP-015-A | Statement & Branch Coverage | UTS-015-A2 | ⬜ Untested |
| ARCH-011 (SYS-005) | SYS-005 | MOD-015 | parse_unified_diff | UTP-015-A | Statement & Branch Coverage | UTS-015-A3 | ⬜ Untested |
| ARCH-011 (SYS-005) | SYS-005 | MOD-015 | parse_unified_diff | UTP-015-B | Strict Isolation | UTS-015-B1 | ⬜ Untested |
| ARCH-011 (SYS-005) | SYS-005 | MOD-015 | parse_unified_diff | UTP-015-B | Strict Isolation | UTS-015-B2 | ⬜ Untested |
| ARCH-011 (SYS-005) | SYS-005 | MOD-016 | classify_changes | UTP-016-A | Statement & Branch Coverage | UTS-016-A1 | ⬜ Untested |
| ARCH-011 (SYS-005) | SYS-005 | MOD-016 | classify_changes | UTP-016-A | Statement & Branch Coverage | UTS-016-A2 | ⬜ Untested |
| ARCH-011 (SYS-005) | SYS-005 | MOD-016 | classify_changes | UTP-016-A | Statement & Branch Coverage | UTS-016-A3 | ⬜ Untested |
| ARCH-011 (SYS-005) | SYS-005 | MOD-016 | classify_changes | UTP-016-A | Statement & Branch Coverage | UTS-016-A4 | ⬜ Untested |
| ARCH-011 (SYS-005) | SYS-005 | MOD-016 | classify_changes | UTP-016-B | Strict Isolation | UTS-016-B1 | ⬜ Untested |
| ARCH-012 (SYS-006) | SYS-006 | MOD-017 | resolve_feature_from_branch | UTP-017-A | Statement & Branch Coverage | UTS-017-A1 | ⬜ Untested |
| ARCH-012 (SYS-006) | SYS-006 | MOD-017 | resolve_feature_from_branch | UTP-017-A | Statement & Branch Coverage | UTS-017-A2 | ⬜ Untested |
| ARCH-012 (SYS-006) | SYS-006 | MOD-017 | resolve_feature_from_branch | UTP-017-A | Statement & Branch Coverage | UTS-017-A3 | ⬜ Untested |
| ARCH-012 (SYS-006) | SYS-006 | MOD-017 | resolve_feature_from_branch | UTP-017-A | Statement & Branch Coverage | UTS-017-A4 | ⬜ Untested |
| ARCH-012 (SYS-006) | SYS-006 | MOD-017 | resolve_feature_from_branch | UTP-017-B | Equivalence Partitioning | UTS-017-B1 | ⬜ Untested |
| ARCH-012 (SYS-006) | SYS-006 | MOD-017 | resolve_feature_from_branch | UTP-017-B | Equivalence Partitioning | UTS-017-B2 | ⬜ Untested |
| ARCH-012 (SYS-006) | SYS-006 | MOD-017 | resolve_feature_from_branch | UTP-017-B | Equivalence Partitioning | UTS-017-B3 | ⬜ Untested |
| ARCH-013 (SYS-006) | SYS-006 | MOD-018 | validate_prerequisites | UTP-018-A | Statement & Branch Coverage | UTS-018-A1 | ⬜ Untested |
| ARCH-013 (SYS-006) | SYS-006 | MOD-018 | validate_prerequisites | UTP-018-A | Statement & Branch Coverage | UTS-018-A2 | ⬜ Untested |
| ARCH-013 (SYS-006) | SYS-006 | MOD-018 | validate_prerequisites | UTP-018-A | Statement & Branch Coverage | UTS-018-A3 | ⬜ Untested |
| ARCH-013 (SYS-006) | SYS-006 | MOD-018 | validate_prerequisites | UTP-018-B | Strict Isolation | UTS-018-B1 | ⬜ Untested |
| ARCH-014 (SYS-006) | SYS-006 | MOD-019 | scan_vmodel_directory | UTP-019-A | Statement & Branch Coverage | UTS-019-A1 | ⬜ Untested |
| ARCH-014 (SYS-006) | SYS-006 | MOD-019 | scan_vmodel_directory | UTP-019-A | Statement & Branch Coverage | UTS-019-A2 | ⬜ Untested |
| ARCH-014 (SYS-006) | SYS-006 | MOD-019 | scan_vmodel_directory | UTP-019-A | Statement & Branch Coverage | UTS-019-A3 | ⬜ Untested |
| ARCH-014 (SYS-006) | SYS-006 | MOD-019 | scan_vmodel_directory | UTP-019-B | Boundary Value Analysis | UTS-019-B1 | ⬜ Untested |
| ARCH-014 (SYS-006) | SYS-006 | MOD-019 | scan_vmodel_directory | UTP-019-B | Boundary Value Analysis | UTS-019-B2 | ⬜ Untested |
| ARCH-014 (SYS-006) | SYS-006 | MOD-019 | scan_vmodel_directory | UTP-019-B | Boundary Value Analysis | UTS-019-B3 | ⬜ Untested |
| ARCH-014 (SYS-006) | SYS-006 | MOD-019 | scan_vmodel_directory | UTP-019-C | Strict Isolation | UTS-019-C1 | ⬜ Untested |
| ARCH-015 (SYS-007) | SYS-007 | MOD-020 | read_vmodel_config | UTP-020-A | Statement & Branch Coverage | UTS-020-A1 | ⬜ Untested |
| ARCH-015 (SYS-007) | SYS-007 | MOD-020 | read_vmodel_config | UTP-020-A | Statement & Branch Coverage | UTS-020-A2 | ⬜ Untested |
| ARCH-015 (SYS-007) | SYS-007 | MOD-020 | read_vmodel_config | UTP-020-A | Statement & Branch Coverage | UTS-020-A3 | ⬜ Untested |
| ARCH-015 (SYS-007) | SYS-007 | MOD-020 | read_vmodel_config | UTP-020-A | Statement & Branch Coverage | UTS-020-A4 | ⬜ Untested |
| ARCH-015 (SYS-007) | SYS-007 | MOD-020 | read_vmodel_config | UTP-020-B | Equivalence Partitioning | UTS-020-B1 | ⬜ Untested |
| ARCH-015 (SYS-007) | SYS-007 | MOD-020 | read_vmodel_config | UTP-020-B | Equivalence Partitioning | UTS-020-B2 | ⬜ Untested |
| ARCH-015 (SYS-007) | SYS-007 | MOD-020 | read_vmodel_config | UTP-020-B | Equivalence Partitioning | UTS-020-B3 | ⬜ Untested |
| ARCH-015 (SYS-007) | SYS-007 | MOD-020 | read_vmodel_config | UTP-020-B | Equivalence Partitioning | UTS-020-B4 | ⬜ Untested |
| ARCH-015 (SYS-007) | SYS-007 | MOD-020 | read_vmodel_config | UTP-020-C | Strict Isolation | UTS-020-C1 | ⬜ Untested |
| ARCH-015 (SYS-007) | SYS-007 | MOD-020 | read_vmodel_config | UTP-020-C | Strict Isolation | UTS-020-C2 | ⬜ Untested |
| ARCH-016 (SYS-007) | SYS-007 | MOD-021 | resolve_overlay_paths | UTP-021-A | Statement & Branch Coverage | UTS-021-A1 | ⬜ Untested |
| ARCH-016 (SYS-007) | SYS-007 | MOD-021 | resolve_overlay_paths | UTP-021-A | Statement & Branch Coverage | UTS-021-A2 | ⬜ Untested |
| ARCH-016 (SYS-007) | SYS-007 | MOD-021 | resolve_overlay_paths | UTP-021-A | Statement & Branch Coverage | UTS-021-A3 | ⬜ Untested |
| ARCH-016 (SYS-007) | SYS-007 | MOD-021 | resolve_overlay_paths | UTP-021-B | Strict Isolation | UTS-021-B1 | ⬜ Untested |
| ARCH-017 (SYS-008) | SYS-008 | MOD-022 | write_markdown_file | UTP-022-A | Statement & Branch Coverage | UTS-022-A1 | ⬜ Untested |
| ARCH-017 (SYS-008) | SYS-008 | MOD-022 | write_markdown_file | UTP-022-A | Statement & Branch Coverage | UTS-022-A2 | ⬜ Untested |
| ARCH-017 (SYS-008) | SYS-008 | MOD-022 | write_markdown_file | UTP-022-A | Statement & Branch Coverage | UTS-022-A3 | ⬜ Untested |
| ARCH-017 (SYS-008) | SYS-008 | MOD-022 | write_markdown_file | UTP-022-A | Statement & Branch Coverage | UTS-022-A4 | ⬜ Untested |
| ARCH-017 (SYS-008) | SYS-008 | MOD-022 | write_markdown_file | UTP-022-B | Strict Isolation | UTS-022-B1 | ⬜ Untested |
| ARCH-017 (SYS-008) | SYS-008 | MOD-022 | write_markdown_file | UTP-022-B | Strict Isolation | UTS-022-B2 | ⬜ Untested |
| ARCH-018 (SYS-009) | SYS-009 | MOD-023 | parse_lifecycle_tags | UTP-023-A | Statement & Branch Coverage | UTS-023-A1 | ⬜ Untested |
| ARCH-018 (SYS-009) | SYS-009 | MOD-023 | parse_lifecycle_tags | UTP-023-A | Statement & Branch Coverage | UTS-023-A2 | ⬜ Untested |
| ARCH-018 (SYS-009) | SYS-009 | MOD-023 | parse_lifecycle_tags | UTP-023-A | Statement & Branch Coverage | UTS-023-A3 | ⬜ Untested |
| ARCH-018 (SYS-009) | SYS-009 | MOD-023 | parse_lifecycle_tags | UTP-023-A | Statement & Branch Coverage | UTS-023-A4 | ⬜ Untested |
| ARCH-018 (SYS-009) | SYS-009 | MOD-023 | parse_lifecycle_tags | UTP-023-B | Equivalence Partitioning | UTS-023-B1 | ⬜ Untested |
| ARCH-018 (SYS-009) | SYS-009 | MOD-023 | parse_lifecycle_tags | UTP-023-B | Equivalence Partitioning | UTS-023-B2 | ⬜ Untested |
| ARCH-018 (SYS-009) | SYS-009 | MOD-023 | parse_lifecycle_tags | UTP-023-B | Equivalence Partitioning | UTS-023-B3 | ⬜ Untested |
| ARCH-018 (SYS-009) | SYS-009 | MOD-023 | parse_lifecycle_tags | UTP-023-C | Strict Isolation | UTS-023-C1 | ⬜ Untested |
| ARCH-019 (SYS-009) | SYS-009 | MOD-024 | apply_lifecycle_transitions | UTP-024-A | Statement & Branch Coverage | UTS-024-A1 | ⬜ Untested |
| ARCH-019 (SYS-009) | SYS-009 | MOD-024 | apply_lifecycle_transitions | UTP-024-A | Statement & Branch Coverage | UTS-024-A2 | ⬜ Untested |
| ARCH-019 (SYS-009) | SYS-009 | MOD-024 | apply_lifecycle_transitions | UTP-024-A | Statement & Branch Coverage | UTS-024-A3 | ⬜ Untested |
| ARCH-019 (SYS-009) | SYS-009 | MOD-024 | apply_lifecycle_transitions | UTP-024-A | Statement & Branch Coverage | UTS-024-A4 | ⬜ Untested |
| ARCH-019 (SYS-009) | SYS-009 | MOD-024 | apply_lifecycle_transitions | UTP-024-B | State Transition Testing | UTS-024-B1 | ⬜ Untested |
| ARCH-019 (SYS-009) | SYS-009 | MOD-024 | apply_lifecycle_transitions | UTP-024-B | State Transition Testing | UTS-024-B10 | ⬜ Untested |
| ARCH-019 (SYS-009) | SYS-009 | MOD-024 | apply_lifecycle_transitions | UTP-024-B | State Transition Testing | UTS-024-B2 | ⬜ Untested |
| ARCH-019 (SYS-009) | SYS-009 | MOD-024 | apply_lifecycle_transitions | UTP-024-B | State Transition Testing | UTS-024-B3 | ⬜ Untested |
| ARCH-019 (SYS-009) | SYS-009 | MOD-024 | apply_lifecycle_transitions | UTP-024-B | State Transition Testing | UTS-024-B4 | ⬜ Untested |
| ARCH-019 (SYS-009) | SYS-009 | MOD-024 | apply_lifecycle_transitions | UTP-024-B | State Transition Testing | UTS-024-B5 | ⬜ Untested |
| ARCH-019 (SYS-009) | SYS-009 | MOD-024 | apply_lifecycle_transitions | UTP-024-B | State Transition Testing | UTS-024-B6 | ⬜ Untested |
| ARCH-019 (SYS-009) | SYS-009 | MOD-024 | apply_lifecycle_transitions | UTP-024-B | State Transition Testing | UTS-024-B7 | ⬜ Untested |
| ARCH-019 (SYS-009) | SYS-009 | MOD-024 | apply_lifecycle_transitions | UTP-024-B | State Transition Testing | UTS-024-B8 | ⬜ Untested |
| ARCH-019 (SYS-009) | SYS-009 | MOD-024 | apply_lifecycle_transitions | UTP-024-B | State Transition Testing | UTS-024-B9 | ⬜ Untested |
| ARCH-019 (SYS-009) | SYS-009 | MOD-025 | assign_next_id | UTP-025-A | Statement & Branch Coverage | UTS-025-A1 | ⬜ Untested |
| ARCH-019 (SYS-009) | SYS-009 | MOD-025 | assign_next_id | UTP-025-A | Statement & Branch Coverage | UTS-025-A2 | ⬜ Untested |
| ARCH-019 (SYS-009) | SYS-009 | MOD-025 | assign_next_id | UTP-025-A | Statement & Branch Coverage | UTS-025-A3 | ⬜ Untested |
| ARCH-019 (SYS-009) | SYS-009 | MOD-025 | assign_next_id | UTP-025-A | Statement & Branch Coverage | UTS-025-A4 | ⬜ Untested |
| ARCH-019 (SYS-009) | SYS-009 | MOD-025 | assign_next_id | UTP-025-B | Boundary Value Analysis | UTS-025-B1 | ⬜ Untested |
| ARCH-019 (SYS-009) | SYS-009 | MOD-025 | assign_next_id | UTP-025-B | Boundary Value Analysis | UTS-025-B2 | ⬜ Untested |
| ARCH-019 (SYS-009) | SYS-009 | MOD-025 | assign_next_id | UTP-025-B | Boundary Value Analysis | UTS-025-B3 | ⬜ Untested |
| ARCH-020 (SYS-010) | SYS-010 | MOD-026 | resolve_input_mode | UTP-026-A | Statement & Branch Coverage | UTS-026-A1 | ⬜ Untested |
| ARCH-020 (SYS-010) | SYS-010 | MOD-026 | resolve_input_mode | UTP-026-A | Statement & Branch Coverage | UTS-026-A2 | ⬜ Untested |
| ARCH-020 (SYS-010) | SYS-010 | MOD-026 | resolve_input_mode | UTP-026-A | Statement & Branch Coverage | UTS-026-A3 | ⬜ Untested |
| ARCH-020 (SYS-010) | SYS-010 | MOD-026 | resolve_input_mode | UTP-026-A | Statement & Branch Coverage | UTS-026-A4 | ⬜ Untested |
| ARCH-020 (SYS-010) | SYS-010 | MOD-026 | resolve_input_mode | UTP-026-B | Equivalence Partitioning | UTS-026-B1 | ⬜ Untested |
| ARCH-020 (SYS-010) | SYS-010 | MOD-026 | resolve_input_mode | UTP-026-B | Equivalence Partitioning | UTS-026-B2 | ⬜ Untested |
| ARCH-020 (SYS-010) | SYS-010 | MOD-026 | resolve_input_mode | UTP-026-B | Equivalence Partitioning | UTS-026-B3 | ⬜ Untested |
| ARCH-020 (SYS-010) | SYS-010 | MOD-026 | resolve_input_mode | UTP-026-C | Strict Isolation | UTS-026-C1 | ⬜ Untested |
| ARCH-020 (SYS-010) | SYS-010 | MOD-026 | resolve_input_mode | UTP-026-C | Strict Isolation | UTS-026-C2 | ⬜ Untested |
| ARCH-021 (SYS-011) | SYS-011 | MOD-027 | format_error_message | UTP-027-A | Statement & Branch Coverage | UTS-027-A1 | ⬜ Untested |
| ARCH-021 (SYS-011) | SYS-011 | MOD-027 | format_error_message | UTP-027-A | Statement & Branch Coverage | UTS-027-A2 | ⬜ Untested |
| ARCH-021 (SYS-011) | SYS-011 | MOD-027 | format_error_message | UTP-027-A | Statement & Branch Coverage | UTS-027-A3 | ⬜ Untested |
| ARCH-022 (SYS-012) | SYS-012 | MOD-028 | check_runtime_capability | UTP-028-A | Statement & Branch Coverage | UTS-028-A1 | ⬜ Untested |
| ARCH-022 (SYS-012) | SYS-012 | MOD-028 | check_runtime_capability | UTP-028-A | Statement & Branch Coverage | UTS-028-A2 | ⬜ Untested |
| ARCH-022 (SYS-012) | SYS-012 | MOD-028 | check_runtime_capability | UTP-028-A | Statement & Branch Coverage | UTS-028-A3 | ⬜ Untested |
| ARCH-022 (SYS-012) | SYS-012 | MOD-028 | check_runtime_capability | UTP-028-A | Statement & Branch Coverage | UTS-028-A4 | ⬜ Untested |
| ARCH-022 (SYS-012) | SYS-012 | MOD-028 | check_runtime_capability | UTP-028-B | Equivalence Partitioning | UTS-028-B1 | ⬜ Untested |
| ARCH-022 (SYS-012) | SYS-012 | MOD-028 | check_runtime_capability | UTP-028-B | Equivalence Partitioning | UTS-028-B2 | ⬜ Untested |
| ARCH-022 (SYS-012) | SYS-012 | MOD-028 | check_runtime_capability | UTP-028-B | Equivalence Partitioning | UTS-028-B3 | ⬜ Untested |
| ARCH-022 (SYS-012) | SYS-012 | MOD-028 | check_runtime_capability | UTP-028-C | Strict Isolation | UTS-028-C1 | ⬜ Untested |
| ARCH-022 (SYS-012) | SYS-012 | MOD-028 | check_runtime_capability | UTP-028-C | Strict Isolation | UTS-028-C2 | ⬜ Untested |

### Matrix D Coverage

| Metric | Value |
|--------|-------|
| **Total Module Designs (MOD)** | 28 |
| **External Modules** | 0 |
| **Testable Modules** | 28 |
| **Total Unit Test Cases (UTP)** | 57 |
| **Total Unit Scenarios (UTS)** | 181 |
| **ARCH → MOD Coverage** | 22/22 (100%) |
| **MOD → UTP Coverage** | 28/28 (100%) |

## Audit Notes

- **Matrix generated by**: `build-matrix.sh` (deterministic regex parser)
- **Source documents**: `requirements.md`, `acceptance-plan.md`, `system-design.md`, `system-test.md`, `architecture-design.md`, `integration-test.md`, `module-design.md`, `unit-test.md`
- **Last validated**: 2026-04-19
