# Integration Test Plan: V-Model Extension Pack MVP

**Feature Branch**: `001-v-model-mvp`
**Created**: 2026-04-19
**Status**: Draft
**Source**: `specs/001-v-model-mvp/v-model/architecture-design.md`

## Overview

This document defines the Integration Test Plan for the V-Model Extension Pack MVP. Every architecture module in `architecture-design.md` has one or more Test Cases (ITP), and every Test Case has one or more executable Integration Scenarios (ITS) in module-boundary BDD format (Given/When/Then).

Integration tests verify **seams and handshakes between modules**, not internal logic or user journeys. The strategy focuses on three techniques: Interface Contract Testing for all 22 module boundaries, Interface Fault Injection for modules with explicit error contracts, and Data Flow Testing for modules participating in data transformation chains. Concurrency & Race Condition Testing is not applicable — the architecture explicitly documents all pipelines as sequential with no concurrent interactions.

## ID Schema

- **Integration Test Case**: `ITP-{NNN}-{X}` — where NNN matches the parent ARCH, X is a letter suffix (A, B, C...)
- **Integration Test Scenario**: `ITS-{NNN}-{X}{#}` — nested under the parent ITP, with numeric suffix (1, 2, 3...)
- Example: `ITS-001-A1` → Scenario 1 of Test Case A verifying ARCH-001

## ISO 29119-4 Integration Test Techniques

Each test case MUST identify its technique by name and anchor to a specific architecture view:

| Technique | Source View | What It Tests |
|-----------|------------|---------------|
| **Interface Contract Testing** | Interface View | Module API contracts, data format compliance, error responses |
| **Data Flow Testing** | Data Flow View | End-to-end data transformation chain validation |
| **Interface Fault Injection** | Interface View + Process View | Malformed payloads, timeouts, graceful failure |
| **Concurrency & Race Condition Testing** | Process View | Not applicable — all pipelines are sequential |

## Integration Tests

### Module Verification: ARCH-001 (Spec Parser)

**Parent System Components**: SYS-001

#### Test Case: ITP-001-A (Input Mode Handoff Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the boundary between ARCH-020 (Input Mode Resolver) and ARCH-001 (Spec Parser), and the handoff from ARCH-001 to ARCH-002 (Requirement Synthesizer).

* **Integration Scenario: ITS-001-A1**
  * **Given** ARCH-020 (Input Mode Resolver) has resolved input mode to `spec_only` with primary_content containing valid Markdown spec content
  * **When** ARCH-020 sends the primary_content reference to ARCH-001 (Spec Parser)
  * **Then** ARCH-001 returns a parsed_repr object with non-empty `user_stories`, `functional_reqs`, `quality_attrs`, and `constraints` arrays to ARCH-002

* **Integration Scenario: ITS-001-A2**
  * **Given** ARCH-020 (Input Mode Resolver) has resolved input mode to `combined` with both primary_content and supplementary_content populated
  * **When** ARCH-020 sends both content references to ARCH-001 (Spec Parser)
  * **Then** ARCH-001 returns a parsed_repr that includes entries derived from both the spec.md (primary) and user text (supplementary) sources

#### Test Case: ITP-001-B (Empty Input Fault Propagation)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies that ARCH-001 correctly propagates an EMPTY_INPUT exception to ARCH-021 (Error Formatter) when both inputs are empty.

* **Integration Scenario: ITS-001-B1**
  * **Given** ARCH-020 (Input Mode Resolver) has raised a NO_INPUT exception because both spec_content and user_text are empty
  * **When** ARCH-001 (Spec Parser) receives the empty input condition
  * **Then** ARCH-001 delegates to ARCH-021 (Error Formatter) with error_category `EMPTY_INPUT` and context identifying the requirements command, and no parsed_repr is sent to ARCH-002

---

### Module Verification: ARCH-002 (Requirement Synthesizer)

**Parent System Components**: SYS-001

#### Test Case: ITP-002-A (Synthesizer Output Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the boundary between ARCH-001 (Spec Parser) and ARCH-002, and the handoff from ARCH-002 to ARCH-003 (Quality Validator).

* **Integration Scenario: ITS-002-A1**
  * **Given** ARCH-001 (Spec Parser) has produced a parsed_repr containing 5 user stories and 12 functional requirements
  * **When** ARCH-001 sends the parsed_repr to ARCH-002 (Requirement Synthesizer)
  * **Then** ARCH-002 returns a draft_requirements array where each entry has `id`, `category`, `description`, `priority`, `verification_method`, and `trace_source` fields, with sequential `REQ-NNN` IDs starting from REQ-001

* **Integration Scenario: ITS-002-A2**
  * **Given** ARCH-016 (Overlay File Resolver) has returned non-empty overlay_content for domain `iso_26262`
  * **When** ARCH-002 (Requirement Synthesizer) receives both parsed_repr from ARCH-001 and overlay_content from ARCH-016
  * **Then** ARCH-002 produces draft_requirements that incorporate domain-specific guidance from the overlay alongside base requirements from the parsed input

#### Test Case: ITP-002-B (Spec-to-Requirements Data Flow)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies end-to-end data transformation from ARCH-001 parsed output through ARCH-002 synthesis to ARCH-003 validation (Flow 1, stages 5→6→7).

* **Integration Scenario: ITS-002-B1**
  * **Given** data enters the chain at ARCH-001 (Spec Parser) as raw Markdown containing 3 user stories
  * **When** data flows from ARCH-001 (intermediate representation) to ARCH-002 (draft requirements array) to ARCH-003 (validated requirements array)
  * **Then** the output at ARCH-003 contains only requirements that passed all 8 quality criteria, with the intermediate parsed_repr format at stage 5 matching the contract between ARCH-001 and ARCH-002

---

### Module Verification: ARCH-003 (Quality Validator)

**Parent System Components**: SYS-001

#### Test Case: ITP-003-A (Validator-to-Writer Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the boundary between ARCH-002 (Requirement Synthesizer) and ARCH-003, and the handoff from ARCH-003 to ARCH-017 (Markdown File Writer).

* **Integration Scenario: ITS-003-A1**
  * **Given** ARCH-002 (Requirement Synthesizer) has produced a draft_requirements array with 10 requirements, 8 passing quality criteria and 2 containing banned vague terms
  * **When** ARCH-002 sends draft_requirements to ARCH-003 (Quality Validator)
  * **Then** ARCH-003 returns a validated_requirements array with 8 entries and a rejection_list with 2 entries identifying the specific banned terms, and only the validated_requirements are forwarded to ARCH-017

#### Test Case: ITP-003-B (Validation Threshold Fault)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies ARCH-003 raises VALIDATION_THRESHOLD when more than 50% of requirements from ARCH-002 fail.

* **Integration Scenario: ITS-003-B1**
  * **Given** ARCH-002 (Requirement Synthesizer) sends a draft_requirements array of 10 requirements to ARCH-003 (Quality Validator)
  * **When** 6 of the 10 requirements fail quality validation (> 50% threshold)
  * **Then** ARCH-003 raises VALIDATION_THRESHOLD to ARCH-021 (Error Formatter) and no output is sent to ARCH-017 (Markdown File Writer)

---

### Module Verification: ARCH-004 (Requirement Batch Processor)

**Parent System Components**: SYS-002

#### Test Case: ITP-004-A (Batch Handoff Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the boundary between the requirements input and ARCH-004, and the handoff from ARCH-004 to ARCH-005 (ATP/SCN Generator).

* **Integration Scenario: ITS-004-A1**
  * **Given** ARCH-004 (Requirement Batch Processor) receives a requirements_list of 12 requirements parsed from requirements.md
  * **When** ARCH-004 splits the list into batches with batch_size 5
  * **Then** ARCH-004 sends 3 ordered batches to ARCH-005 (ATP/SCN Generator): batch 1 with REQ-001 through REQ-005, batch 2 with REQ-006 through REQ-010, batch 3 with REQ-011 through REQ-012, with no requirement omitted or duplicated

* **Integration Scenario: ITS-004-A2**
  * **Given** ARCH-004 (Requirement Batch Processor) receives a requirements_list with exactly 5 requirements (boundary: single full batch)
  * **When** ARCH-004 splits the list
  * **Then** ARCH-004 sends exactly 1 batch containing all 5 requirements to ARCH-005

#### Test Case: ITP-004-B (Empty Requirements Fault)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies ARCH-004 handles empty input from upstream gracefully.

* **Integration Scenario: ITS-004-B1**
  * **Given** ARCH-004 (Requirement Batch Processor) receives an empty requirements_list
  * **When** ARCH-004 attempts to create batches
  * **Then** ARCH-004 raises EMPTY_REQUIREMENTS to ARCH-021 (Error Formatter) and sends no batches to ARCH-005

---

### Module Verification: ARCH-005 (ATP/SCN Generator)

**Parent System Components**: SYS-002

#### Test Case: ITP-005-A (Generator-to-Assembler Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the boundary between ARCH-004 (Batch Processor) and ARCH-005, and the handoff from ARCH-005 to ARCH-006 (Coverage Assembler).

* **Integration Scenario: ITS-005-A1**
  * **Given** ARCH-004 (Requirement Batch Processor) sends a batch of 5 requirements with start_atp_number 1
  * **When** ARCH-005 (ATP/SCN Generator) processes the batch
  * **Then** ARCH-005 returns atp_entries to ARCH-006 (Coverage Assembler) where each requirement has at least one `ATP-NNN-X` with at least one `SCN-NNN-X#` scenario, and the highest ATP number is returned for the next batch's start_atp_number

* **Integration Scenario: ITS-005-A2**
  * **Given** ARCH-004 sends batch 2 with start_atp_number 6 (continuing from batch 1's highest ATP)
  * **When** ARCH-005 processes the batch
  * **Then** ARCH-005 returns atp_entries with IDs starting from ATP-006 (no overlap with batch 1 IDs), maintaining cross-batch ID continuity

#### Test Case: ITP-005-B (AI Runtime Failure During Generation)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies ARCH-005 handles AI runtime failure from ARCH-022 gracefully.

* **Integration Scenario: ITS-005-B1**
  * **Given** ARCH-022 (Runtime Adapter) reports runtime_available as true and ARCH-004 sends a valid batch to ARCH-005
  * **When** ARCH-005 (ATP/SCN Generator) invokes the AI runtime and ARCH-022 raises RUNTIME_UNAVAILABLE mid-generation
  * **Then** ARCH-005 raises GENERATION_FAILURE to ARCH-021 (Error Formatter) and sends no partial atp_entries to ARCH-006

---

### Module Verification: ARCH-006 (Coverage Assembler)

**Parent System Components**: SYS-002

#### Test Case: ITP-006-A (Assembly-to-Writer Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the boundary between ARCH-005 (Generator) batch outputs and ARCH-006, and the handoff to ARCH-017 (File Writer).

* **Integration Scenario: ITS-006-A1**
  * **Given** ARCH-005 (ATP/SCN Generator) has produced 7 batch outputs covering 35 requirements
  * **When** ARCH-006 (Coverage Assembler) receives all batch outputs and the full requirements_list
  * **Then** ARCH-006 produces an acceptance_plan where every REQ-NNN has at least one ATP and every ATP has at least one SCN, and sends the Markdown content to ARCH-017 (Markdown File Writer)

#### Test Case: ITP-006-B (Cross-Batch ID Conflict Fault)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies ARCH-006 detects duplicate IDs produced across batches from ARCH-005.

* **Integration Scenario: ITS-006-B1**
  * **Given** ARCH-005 (ATP/SCN Generator) produces batch 1 output containing ATP-005-A and batch 2 output also containing ATP-005-A (duplicate)
  * **When** ARCH-006 (Coverage Assembler) merges all batch outputs
  * **Then** ARCH-006 raises ID_CONFLICT to ARCH-021 (Error Formatter) identifying the duplicate ATP-005-A, and does not send the plan to ARCH-017

* **Integration Scenario: ITS-006-B2**
  * **Given** ARCH-005 produces 7 batch outputs where batch 3 is missing coverage for REQ-012
  * **When** ARCH-006 (Coverage Assembler) validates bidirectional coverage after merge
  * **Then** ARCH-006 raises COVERAGE_GAP identifying REQ-012 and does not send the plan to ARCH-017

---

### Module Verification: ARCH-007 (ID Regex Extractor)

**Parent System Components**: SYS-003, SYS-004

#### Test Case: ITP-007-A (Extractor-to-Compositor Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the boundary between ARCH-007 and its two consumers: ARCH-008 (Matrix Compositor) and ARCH-010 (Coverage Calculator).

* **Integration Scenario: ITS-007-A1**
  * **Given** ARCH-007 (ID Regex Extractor) receives requirements.md content containing REQ-001, REQ-002, REQ-NF-001 with id_type `REQ`
  * **When** ARCH-007 extracts and sends the id_set to ARCH-008 (Matrix Compositor)
  * **Then** ARCH-008 receives a sorted, deduplicated array `["REQ-001", "REQ-002", "REQ-NF-001"]` matching the Interface View contract

* **Integration Scenario: ITS-007-A2**
  * **Given** ARCH-007 (ID Regex Extractor) receives the same acceptance-plan.md content with id_type `ATP` and then `SCN`
  * **When** ARCH-007 sends the ATP id_set and SCN id_set to ARCH-010 (Coverage Calculator)
  * **Then** ARCH-010 receives two sorted arrays with no duplicates, matching the exact IDs present in the source document

#### Test Case: ITP-007-B (Malformed Markdown Fault)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies ARCH-007 raises MALFORMED_INPUT when receiving corrupt content.

* **Integration Scenario: ITS-007-B1**
  * **Given** ARCH-017 (Markdown File Writer) has written a requirements.md with corrupted table delimiters (missing `|` separators)
  * **When** ARCH-007 (ID Regex Extractor) attempts to extract REQ IDs from the malformed content
  * **Then** ARCH-007 raises MALFORMED_INPUT to ARCH-021 (Error Formatter) and sends no id_set to ARCH-008 or ARCH-010

#### Test Case: ITP-007-C (Extraction Chain Data Flow)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies end-to-end data flow through Flow 3 (Requirements + Acceptance → Traceability Matrix), stages 1–3.

* **Integration Scenario: ITS-007-C1**
  * **Given** requirements.md contains 35 REQ IDs and acceptance-plan.md contains 59 ATP IDs and 63 SCN IDs
  * **When** data flows from ARCH-007 (three extraction passes) to ARCH-008 (Matrix Compositor)
  * **Then** ARCH-008 receives three sorted arrays with counts 35, 59, and 63 respectively, and the intermediate format at each extraction pass matches the `id_set` output contract of ARCH-007

---

### Module Verification: ARCH-008 (Matrix Compositor)

**Parent System Components**: SYS-003

#### Test Case: ITP-008-A (Compositor-to-Analyzer Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the boundary between ARCH-007 (Extractor) outputs and ARCH-008, and the handoff to ARCH-009 (Gap Analyzer).

* **Integration Scenario: ITS-008-A1**
  * **Given** ARCH-007 (ID Regex Extractor) has sent three ID arrays (35 REQs, 59 ATPs, 63 SCNs) to ARCH-008 (Matrix Compositor)
  * **When** ARCH-008 builds the matrix tables
  * **Then** ARCH-008 sends matrix_content to ARCH-009 (Gap Analyzer) containing Matrix A with forward tracing (REQ→ATP→SCN), coverage percentages, and baseline metadata with timestamps

#### Test Case: ITP-008-B (Empty ID Set Fault)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies ARCH-008 handles empty ID arrays from ARCH-007.

* **Integration Scenario: ITS-008-B1**
  * **Given** ARCH-007 (ID Regex Extractor) sends a REQ id_set with 10 entries but an empty ATP id_set (acceptance-plan.md had no ATPs)
  * **When** ARCH-008 (Matrix Compositor) receives the ID arrays
  * **Then** ARCH-008 raises EMPTY_ID_SET to ARCH-021 (Error Formatter) and sends no matrix_content to ARCH-009

---

### Module Verification: ARCH-009 (Gap Analyzer)

**Parent System Components**: SYS-003

#### Test Case: ITP-009-A (Analyzer Output Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the boundary between ARCH-008 (Compositor) and ARCH-009, and the output to ARCH-017 (File Writer).

* **Integration Scenario: ITS-009-A1**
  * **Given** ARCH-008 (Matrix Compositor) sends matrix_content with 100% coverage to ARCH-009 (Gap Analyzer)
  * **When** ARCH-009 analyzes the matrix for gaps
  * **Then** ARCH-009 returns `has_gaps: false` and an empty exception_report section, and the combined matrix + report is sent to ARCH-017

* **Integration Scenario: ITS-009-A2**
  * **Given** ARCH-008 sends matrix_content where REQ-003 has no ATP mapping
  * **When** ARCH-009 (Gap Analyzer) analyzes the matrix
  * **Then** ARCH-009 returns `has_gaps: true` and an exception_report listing REQ-003 under "Uncovered Requirements"

#### Test Case: ITP-009-B (Matrix Pipeline Data Flow)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies end-to-end data flow through Flow 3, stages 4–6 (Compositor → Analyzer → Writer).

* **Integration Scenario: ITS-009-B1**
  * **Given** data enters at ARCH-008 (Matrix Compositor) as three ID arrays from ARCH-007
  * **When** data flows from ARCH-008 (matrix tables) to ARCH-009 (exception report) to ARCH-017 (file output)
  * **Then** the final file at ARCH-017 contains Matrix A tables, coverage percentages, exception report, and audit notes, with no data loss between stages

---

### Module Verification: ARCH-010 (Coverage Calculator)

**Parent System Components**: SYS-004

#### Test Case: ITP-010-A (Calculator Output Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the boundary between ARCH-007 (Extractor) and ARCH-010, and the JSON output contract.

* **Integration Scenario: ITS-010-A1**
  * **Given** ARCH-007 (ID Regex Extractor) sends three ID arrays with full coverage (every REQ has ≥1 ATP, every ATP has ≥1 SCN)
  * **When** ARCH-010 (Coverage Calculator) computes bidirectional coverage
  * **Then** ARCH-010 returns exit_code 0 and json_report with `has_gaps: false`, empty `reqs_without_atp` and `atps_without_scn` arrays, and `req_coverage_pct: 100`

* **Integration Scenario: ITS-010-A2**
  * **Given** ARCH-007 sends ID arrays where REQ-005 has no ATP match
  * **When** ARCH-010 computes coverage
  * **Then** ARCH-010 returns exit_code 1 and json_report with `has_gaps: true` and `reqs_without_atp: ["REQ-005"]`

#### Test Case: ITP-010-B (Coverage Validation Data Flow)

**Technique**: Data Flow Testing
**Target View**: Data Flow View
**Description**: Verifies end-to-end Flow 4 from extraction through coverage computation.

* **Integration Scenario: ITS-010-B1**
  * **Given** data enters at ARCH-007 (ID Regex Extractor) as two Markdown files (requirements.md and acceptance-plan.md)
  * **When** data flows from ARCH-007 (three ID arrays) to ARCH-010 (exit code + JSON report)
  * **Then** the exit code and JSON output from ARCH-010 are deterministic — running the same inputs twice produces byte-identical outputs

---

### Module Verification: ARCH-011 (Git Diff Analyzer)

**Parent System Components**: SYS-005

#### Test Case: ITP-011-A (Change Report Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies ARCH-011 produces a correctly structured change report for consumption by downstream incremental update processes.

* **Integration Scenario: ITS-011-A1**
  * **Given** ARCH-011 (Git Diff Analyzer) receives a vmodel_dir where requirements.md has 1 added REQ, 1 modified REQ, and 1 removed REQ compared to the committed version
  * **When** ARCH-011 executes `git diff` and parses the output
  * **Then** ARCH-011 returns a change_report with `added: ["REQ-011"]`, `modified: ["REQ-003"]`, `removed: ["REQ-007"]`

#### Test Case: ITP-011-B (No Git History Fault)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies ARCH-011 propagates NO_GIT_HISTORY to ARCH-021 when no committed version exists.

* **Integration Scenario: ITS-011-B1**
  * **Given** ARCH-011 (Git Diff Analyzer) receives a vmodel_dir where requirements.md exists in the working copy but has never been committed
  * **When** ARCH-011 attempts to execute `git diff`
  * **Then** ARCH-011 raises NO_GIT_HISTORY to ARCH-021 (Error Formatter) rather than returning an empty or misleading change_report

---

### Module Verification: ARCH-012 (Branch-Feature Resolver)

**Parent System Components**: SYS-006

#### Test Case: ITP-012-A (Resolver-to-Validator-Discovery Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the boundary between ARCH-012 and its consumers: ARCH-013 (Prerequisite Validator) and ARCH-014 (Document Discovery).

* **Integration Scenario: ITS-012-A1**
  * **Given** ARCH-012 (Branch-Feature Resolver) resolves Git branch `feature/006a-paired-spec` using the `^([0-9]{3}[a-z]?)-` pattern
  * **When** ARCH-012 sends the resolved feature_dir and vmodel_dir to ARCH-013 (Prerequisite Validator) and ARCH-014 (Document Discovery)
  * **Then** ARCH-013 receives `specs/006a-paired-spec/v-model/` as vmodel_dir, and ARCH-014 receives the same path, both matching the Interface View contract

* **Integration Scenario: ITS-012-A2**
  * **Given** ARCH-012 receives `SPECIFY_FEATURE=001-v-model-mvp` environment variable override with branch name `feature/evolve-001-v-model-mvp`
  * **When** ARCH-012 resolves the feature directory
  * **Then** ARCH-012 sends `specs/001-v-model-mvp/v-model/` (from override, not branch pattern) to ARCH-013 and ARCH-014

#### Test Case: ITP-012-B (Branch Resolution Failure Fault)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies ARCH-012 raises RESOLUTION_FAILURE when branch doesn't match pattern and no override is set.

* **Integration Scenario: ITS-012-B1**
  * **Given** ARCH-012 (Branch-Feature Resolver) receives branch name `main` (no feature pattern) and no SPECIFY_FEATURE override
  * **When** ARCH-012 attempts resolution
  * **Then** ARCH-012 raises RESOLUTION_FAILURE to ARCH-021 (Error Formatter) and sends no paths to ARCH-013 or ARCH-014

---

### Module Verification: ARCH-013 (Prerequisite Validator)

**Parent System Components**: SYS-006

#### Test Case: ITP-013-A (Prerequisite Validation Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the boundary between ARCH-012 (Resolver) and ARCH-013, and the pass/fail signal to the command pipeline.

* **Integration Scenario: ITS-013-A1**
  * **Given** ARCH-012 (Branch-Feature Resolver) sends vmodel_dir `specs/001-v-model-mvp/v-model/` to ARCH-013, and required_flags include `--require-reqs` and `--require-acceptance`
  * **When** ARCH-013 (Prerequisite Validator) checks and both requirements.md and acceptance-plan.md exist
  * **Then** ARCH-013 returns validation_result `true` and the command pipeline proceeds

#### Test Case: ITP-013-B (Missing Prerequisite Fault)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies ARCH-013 identifies the specific missing document.

* **Integration Scenario: ITS-013-B1**
  * **Given** ARCH-012 sends vmodel_dir to ARCH-013 with required_flags `--require-reqs` and `--require-acceptance`, but only requirements.md exists
  * **When** ARCH-013 (Prerequisite Validator) checks for acceptance-plan.md
  * **Then** ARCH-013 raises MISSING_PREREQUISITE to ARCH-021 (Error Formatter) identifying `acceptance-plan.md` as the missing document, with exit code 1

---

### Module Verification: ARCH-014 (Document Discovery)

**Parent System Components**: SYS-006

#### Test Case: ITP-014-A (Discovery-to-Resolver Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the boundary between ARCH-012 (Resolver) input and ARCH-014 output to the JSON config.

* **Integration Scenario: ITS-014-A1**
  * **Given** ARCH-012 (Branch-Feature Resolver) sends vmodel_dir containing `requirements.md`, `acceptance-plan.md`, and `system-design.md`
  * **When** ARCH-014 (Document Discovery) scans the directory
  * **Then** ARCH-014 returns available_docs `["requirements.md", "acceptance-plan.md", "system-design.md"]` which is included in the JSON config output

* **Integration Scenario: ITS-014-A2**
  * **Given** ARCH-012 sends a vmodel_dir that is an empty directory
  * **When** ARCH-014 scans the directory
  * **Then** ARCH-014 returns an empty available_docs array `[]`

---

### Module Verification: ARCH-015 (Config Reader)

**Parent System Components**: SYS-007

#### Test Case: ITP-015-A (Config-to-Overlay Resolver Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the boundary between ARCH-015 and ARCH-016 (Overlay File Resolver).

* **Integration Scenario: ITS-015-A1**
  * **Given** a `v-model-config.yml` exists at the repository root with `domain: iso_26262`
  * **When** ARCH-015 (Config Reader) reads the file and sends the domain to ARCH-016 (Overlay File Resolver)
  * **Then** ARCH-016 receives the string `"iso_26262"` and proceeds to resolve overlay file paths

* **Integration Scenario: ITS-015-A2**
  * **Given** no `v-model-config.yml` exists at the repository root
  * **When** ARCH-015 (Config Reader) attempts to read the file
  * **Then** ARCH-015 returns `null` domain and ARCH-016 (Overlay File Resolver) is not invoked

#### Test Case: ITP-015-B (Invalid Domain Fault)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies ARCH-015 rejects unrecognized domain values.

* **Integration Scenario: ITS-015-B1**
  * **Given** a `v-model-config.yml` exists with `domain: unknown_standard`
  * **When** ARCH-015 (Config Reader) validates the domain against the allowed set
  * **Then** ARCH-015 raises INVALID_DOMAIN to ARCH-021 (Error Formatter) and does not send any domain to ARCH-016

---

### Module Verification: ARCH-016 (Overlay File Resolver)

**Parent System Components**: SYS-007

#### Test Case: ITP-016-A (Overlay-to-Synthesizer Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the boundary between ARCH-015 (Config Reader) and ARCH-016, and the handoff to ARCH-002/ARCH-005.

* **Integration Scenario: ITS-016-A1**
  * **Given** ARCH-015 (Config Reader) sends domain `iso_26262` and command_name `requirements` to ARCH-016 (Overlay File Resolver), and overlay files exist at expected paths
  * **When** ARCH-016 resolves and reads the overlay files
  * **Then** ARCH-016 returns non-empty command_overlay and template_overlay content to ARCH-002 (Requirement Synthesizer)

#### Test Case: ITP-016-B (Missing Overlay Graceful Degradation)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies ARCH-016 degrades gracefully when overlay files are absent.

* **Integration Scenario: ITS-016-B1**
  * **Given** ARCH-015 sends domain `iec_62304` and command_name `trace` to ARCH-016, but no overlay file exists at `commands/overlays/iec_62304/trace.md`
  * **When** ARCH-016 (Overlay File Resolver) checks the file path
  * **Then** ARCH-016 returns empty strings for both command_overlay and template_overlay, and the consuming module (ARCH-002 or ARCH-005) proceeds with base-only generation without error

---

### Module Verification: ARCH-017 (Markdown File Writer)

**Parent System Components**: SYS-008

#### Test Case: ITP-017-A (Writer Input Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the boundary between upstream producers (ARCH-003, ARCH-006, ARCH-008) and ARCH-017.

* **Integration Scenario: ITS-017-A1**
  * **Given** ARCH-003 (Quality Validator) sends validated Markdown content and target_path `specs/001-v-model-mvp/v-model/requirements.md`
  * **When** ARCH-017 (Markdown File Writer) receives the content
  * **Then** ARCH-017 writes the file at the exact target_path as UTF-8 encoded plaintext Markdown and returns write_confirmation `true`

* **Integration Scenario: ITS-017-A2**
  * **Given** ARCH-006 (Coverage Assembler) sends an 800-line acceptance plan to ARCH-017
  * **When** ARCH-017 writes the file
  * **Then** the written file contains all 800 lines with no truncation, and the file resides within the Git-tracked `specs/{feature}/v-model/` directory

#### Test Case: ITP-017-B (Filesystem Write Failure Fault)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies ARCH-017 propagates WRITE_FAILURE to ARCH-021 on filesystem errors.

* **Integration Scenario: ITS-017-B1**
  * **Given** ARCH-003 sends content to ARCH-017 (Markdown File Writer) with a target_path in a read-only directory
  * **When** ARCH-017 attempts to write the file
  * **Then** ARCH-017 raises WRITE_FAILURE to ARCH-021 (Error Formatter) with context identifying the target path and filesystem error, and no partial file is left on disk

---

### Module Verification: ARCH-018 (Lifecycle Tag Parser)

**Parent System Components**: SYS-009

#### Test Case: ITP-018-A (Parser-to-State Machine Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the boundary between ARCH-018 and ARCH-019 (Lifecycle State Machine).

* **Integration Scenario: ITS-018-A1**
  * **Given** ARCH-018 (Lifecycle Tag Parser) receives requirements.md containing `REQ-001` (active), `REQ-002 [DEPRECATED — Superseded by REQ-010]`, and `REQ-003 [SUSPECT — Parent ... modified]`
  * **When** ARCH-018 parses the lifecycle tags and sends lifecycle_map to ARCH-019 (Lifecycle State Machine)
  * **Then** ARCH-019 receives `{"REQ-001": {state: "ACTIVE"}, "REQ-002": {state: "DEPRECATED_SUPERSEDED", detail: "REQ-010"}, "REQ-003": {state: "SUSPECT", detail: "..."}}`

* **Integration Scenario: ITS-018-A2**
  * **Given** ARCH-018 receives a requirements.md with no lifecycle tags (all items active)
  * **When** ARCH-018 sends lifecycle_map to ARCH-019
  * **Then** ARCH-019 receives a map where every ID has state `ACTIVE`

---

### Module Verification: ARCH-019 (Lifecycle State Machine)

**Parent System Components**: SYS-009

#### Test Case: ITP-019-A (State Machine Transition Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the boundary between ARCH-018 (Tag Parser) and ARCH-019, and the transition output.

* **Integration Scenario: ITS-019-A1**
  * **Given** ARCH-018 (Lifecycle Tag Parser) sends lifecycle_map with REQ-005 as ACTIVE, and parent_changes indicate REQ-005's parent SYS component was modified
  * **When** ARCH-019 (Lifecycle State Machine) evaluates the transitions
  * **Then** ARCH-019 returns transitions array containing `{id: "REQ-005", from_state: "ACTIVE", to_state: "SUSPECT", action: "cascade", reason: "Parent SYS modified"}` and downstream ATPs/SCNs tracing to REQ-005 are also flagged

#### Test Case: ITP-019-B (Invalid Transition Fault)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies ARCH-019 rejects illegal state transitions.

* **Integration Scenario: ITS-019-B1**
  * **Given** ARCH-018 sends lifecycle_map with REQ-002 in state `DEPRECATED_SUPERSEDED`
  * **When** ARCH-019 (Lifecycle State Machine) receives a parent_changes request to transition REQ-002 back to `ACTIVE`
  * **Then** ARCH-019 raises INVALID_TRANSITION to ARCH-021 (Error Formatter) identifying the illegal DEPRECATED→ACTIVE transition for REQ-002

---

### Module Verification: ARCH-020 (Input Mode Resolver)

**Parent System Components**: SYS-010

#### Test Case: ITP-020-A (Resolver-to-Parser Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the boundary between ARCH-014 (Document Discovery) input and ARCH-020 output to ARCH-001 (Spec Parser).

* **Integration Scenario: ITS-020-A1**
  * **Given** ARCH-014 (Document Discovery) has returned available_docs containing `"spec.md"` and user_arguments is empty
  * **When** ARCH-020 (Input Mode Resolver) resolves the input mode
  * **Then** ARCH-020 sends input_mode `spec_only` with primary_content (spec.md content) and supplementary_content `null` to ARCH-001 (Spec Parser)

* **Integration Scenario: ITS-020-A2**
  * **Given** ARCH-014 returns available_docs containing `"spec.md"` and user_arguments is `"Build a CI/CD validator"`
  * **When** ARCH-020 resolves the input mode
  * **Then** ARCH-020 sends input_mode `combined` with primary_content (spec.md) and supplementary_content (user text) to ARCH-001

#### Test Case: ITP-020-B (No Input Available Fault)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies ARCH-020 propagates NO_INPUT when both sources are empty.

* **Integration Scenario: ITS-020-B1**
  * **Given** ARCH-014 returns available_docs without `"spec.md"` and user_arguments is empty
  * **When** ARCH-020 (Input Mode Resolver) evaluates the input sources
  * **Then** ARCH-020 raises NO_INPUT to ARCH-021 (Error Formatter) and sends no content references to ARCH-001

---

### Module Verification: ARCH-021 (Error Formatter)

**Parent System Components**: SYS-011

#### Test Case: ITP-021-A (Error Formatting Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the boundary between error-raising modules and ARCH-021, ensuring formatted messages contain all required context.

* **Integration Scenario: ITS-021-A1**
  * **Given** ARCH-013 (Prerequisite Validator) raises MISSING_PREREQUISITE with context `{component: "acceptance command", operation: "prerequisite check", cause: "acceptance-plan.md not found", guidance: "Run /speckit.v-model.acceptance first"}`
  * **When** ARCH-021 (Error Formatter) formats the error
  * **Then** ARCH-021 writes a message to stderr containing the component name, cause, and guidance, and returns exit_code 1 to halt the pipeline

* **Integration Scenario: ITS-021-A2**
  * **Given** ARCH-007 (ID Regex Extractor) raises MALFORMED_INPUT with context identifying the malformed file and section
  * **When** ARCH-021 formats the error
  * **Then** the formatted message includes the file path, the malformed section reference, and the parsing failure reason

---

### Module Verification: ARCH-022 (Runtime Adapter)

**Parent System Components**: SYS-012

#### Test Case: ITP-022-A (Runtime Binding Contract)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verifies the boundary between ARCH-022 and its consumers (ARCH-002, ARCH-005) for generative commands, and the independence of deterministic modules.

* **Integration Scenario: ITS-022-A1**
  * **Given** ARCH-022 (Runtime Adapter) is bound to an AI assistant with file_read, file_write, and script_exec capabilities
  * **When** ARCH-002 (Requirement Synthesizer) requests capability_check `generative`
  * **Then** ARCH-022 returns runtime_available `true` and tool_access with all three capabilities, allowing ARCH-002 to proceed with AI-driven synthesis

* **Integration Scenario: ITS-022-A2**
  * **Given** ARCH-010 (Coverage Calculator) requests capability_check `deterministic`
  * **When** ARCH-022 evaluates the request
  * **Then** ARCH-022 returns runtime_available `true` regardless of AI assistant availability, confirming deterministic modules bypass the AI runtime

#### Test Case: ITP-022-B (Runtime Unavailable Fault)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verifies ARCH-022 raises RUNTIME_UNAVAILABLE for generative commands when no AI runtime is bound.

* **Integration Scenario: ITS-022-B1**
  * **Given** no AI assistant is bound in the current environment
  * **When** ARCH-002 (Requirement Synthesizer) requests capability_check `generative` from ARCH-022 (Runtime Adapter)
  * **Then** ARCH-022 raises RUNTIME_UNAVAILABLE to ARCH-021 (Error Formatter) and ARCH-002 does not attempt synthesis

---

## Test Harness & Mocking Strategy

| Test Case | External Dependency | Mock/Stub Strategy | Rationale |
|-----------|--------------------|--------------------|-----------|
| ITP-001-A, ITP-001-B | Filesystem (spec.md) | Fixture file — sample spec.md in test directory | Deterministic input; no side effects |
| ITP-002-A, ITP-002-B | AI Runtime (ARCH-022) | Stub — returns predefined draft_requirements array | Isolates synthesis from AI variability; tests boundary contract only |
| ITP-005-A, ITP-005-B | AI Runtime (ARCH-022) | Stub — returns predefined ATP/SCN entries per batch | Same rationale as ITP-002 |
| ITP-007-A, ITP-007-B, ITP-007-C | Filesystem (requirements.md, acceptance-plan.md) | Fixture files — known content with specific ID counts | Deterministic regex extraction verification |
| ITP-011-A, ITP-011-B | Git CLI (`git diff`) | Stub — returns predefined unified diff output | Isolates from actual Git state; tests parsing logic |
| ITP-012-A, ITP-012-B | Git CLI (`git rev-parse`) | Stub — returns predefined branch name | Isolates from actual Git branch |
| ITP-015-A, ITP-015-B | Filesystem (v-model-config.yml) | Fixture files — valid, invalid, and absent config files | Tests all config states without modifying repo |
| ITP-016-A, ITP-016-B | Filesystem (overlay files) | Fixture files — present and absent overlay directories | Tests resolution and graceful degradation |
| ITP-017-A, ITP-017-B | Filesystem (write target) | Temp directory — writable and read-only variants | Tests write success and failure modes safely |
| ITP-022-A, ITP-022-B | AI Runtime | Mock — configurable availability flag | Tests runtime binding without actual AI assistant |

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Architecture Modules (ARCH) | 22 (22 active, 0 deprecated) |
| Total Test Cases (ITP) | 42 |
| Total Scenarios (ITS) | 58 |
| Modules with ≥1 ITP | 22 / 22 (100%) (active items only) |
| Test Cases with ≥1 ITS | 42 / 42 (100%) |
| **Overall Coverage (ARCH→ITP)** | **100%** |

### Technique Distribution

| Technique | Test Cases | Percentage |
|-----------|-----------|------------|
| Interface Contract Testing | 22 | 52% |
| Interface Fault Injection | 16 | 38% |
| Data Flow Testing | 4 | 10% |
| Concurrency & Race Condition Testing | 0 | 0% (not applicable — sequential architecture) |

> Note: Some modules have test cases from multiple techniques, so percentages sum to > 100%.

## Uncovered Modules

None — full coverage achieved.
